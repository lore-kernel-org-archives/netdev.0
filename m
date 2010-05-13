From: John Fastabend <john.r.fastabend@intel.com>
Subject: [PATCH 3/3] net: deliver skbs on inactive slaves to exact matches
Date: Thu, 13 May 2010 00:31:17 -0700
Message-ID: <20100513073117.3528.33132.stgit@jf-dev2-dcblab>
References: <20100513073106.3528.45412.stgit@jf-dev2-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com
To: andy@greyhouse.net, fubar@us.ibm.com, nhorman@tuxdriver.com,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:18534 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756232Ab0EMHaq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 03:30:46 -0400
In-Reply-To: <20100513073106.3528.45412.stgit@jf-dev2-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the accelerated receive path for VLAN's will
drop packets if the real device is an inactive slave and
is not one of the special pkts tested for in
skb_bond_should_drop().  This behavior is different then
the non-accelerated path and for pkts over a bonded vlan.

For example,

vlanx -> bond0 -> ethx

will be dropped in the vlan path and not delivered to any
packet handlers at all.  However,

bond0 -> vlanx -> ethx

and

bond0 -> ethx

will be delivered to handlers that match the exact dev,
because the VLAN path checks the real_dev which is not a
slave and netif_recv_skb() doesn't drop frames but only
delivers them to exact matches.

This patch adds a sk_buff flag which is used for tagging
skbs that would previously been dropped and allows the
skb to continue to skb_netif_recv().  Here we add
logic to check for the bond_should_drop flag and if it
is set only deliver to handlers that match exactly.  This
makes both paths above consistent and gives pkt handlers
a way to identify skbs that come from inactive slaves.
Without this patch in some configurations skbs will be
delivered to handlers with exact matches and in others
be dropped out right in the vlan path.

I have tested the following 4 configurations in failover modes
and load balancing modes.

# bond0 -> ethx

# vlanx -> bond0 -> ethx

# bond0 -> vlanx -> ethx

# bond0 -> ethx
            |
  vlanx -> --

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 include/linux/skbuff.h |    8 +++++++-
 net/8021q/vlan_core.c  |    8 ++++++--
 net/core/dev.c         |   23 +++++++++++++++++++----
 3 files changed, 32 insertions(+), 7 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c9525bc..5ba4fd5 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -379,8 +379,14 @@ struct sk_buff {
 
 	kmemcheck_bitfield_begin(flags2);
 	__u16			queue_mapping:16;
-#ifdef CONFIG_IPV6_NDISC_NODETYPE
+#if defined(CONFIG_IPV6_NDISC_NODETYPE) && \
+    (defined(CONFIG_BONDING) || defined(CONFIG_BONDING_MODULE))
+	__u8			ndisc_nodetype:2,
+				bond_should_drop:1;
+#elif defined(CONFIG_IPV6_NDISC_NODETYPE)
 	__u8			ndisc_nodetype:2;
+#elif defined(CONFIG_BONDING) || defined(CONFIG_BONDING_MODULE)
+	__u8			bond_should_drop:1;
 #endif
 	kmemcheck_bitfield_end(flags2);
 
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index c584a0a..57ac2d3 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -11,8 +11,10 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 	if (netpoll_rx(skb))
 		return NET_RX_DROP;
 
+#if defined(CONFIG_BONDING) || defined(CONFIG_BONDING_MODULE)
 	if (skb_bond_should_drop(skb, ACCESS_ONCE(skb->dev->master)))
-		goto drop;
+		skb->bond_should_drop = 1;
+#endif
 
 	skb->skb_iif = skb->dev->ifindex;
 	__vlan_hwaccel_put_tag(skb, vlan_tci);
@@ -83,8 +85,10 @@ vlan_gro_common(struct napi_struct *napi, struct vlan_group *grp,
 {
 	struct sk_buff *p;
 
+#if defined(CONFIG_BONDING) || defined(CONFIG_BONDING_MODULE)
 	if (skb_bond_should_drop(skb, ACCESS_ONCE(skb->dev->master)))
-		goto drop;
+		skb->bond_should_drop = 1;
+#endif
 
 	skb->skb_iif = skb->dev->ifindex;
 	__vlan_hwaccel_put_tag(skb, vlan_tci);
diff --git a/net/core/dev.c b/net/core/dev.c
index 3dc691d..92fdff4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2782,11 +2782,13 @@ static int __netif_receive_skb(struct sk_buff *skb)
 {
 	struct packet_type *ptype, *pt_prev;
 	struct net_device *orig_dev;
-	struct net_device *master;
 	struct net_device *null_or_orig;
 	struct net_device *orig_or_bond;
 	int ret = NET_RX_DROP;
 	__be16 type;
+#if defined(CONFIG_BONDING) || defined(CONFIG_BONDING_MODULE)
+	struct net_device *master;
+#endif
 
 	if (!skb->tstamp.tv64)
 		net_timestamp(skb);
@@ -2801,15 +2803,28 @@ static int __netif_receive_skb(struct sk_buff *skb)
 	if (!skb->skb_iif)
 		skb->skb_iif = skb->dev->ifindex;
 
+	/*
+	 * bonding note: skbs received on inactive slaves should only
+	 * be delivered to pkt handlers that are exact matches.  Also
+	 * the bond_should_drop flag will be set.  If packet handlers
+	 * are sensitive to duplicate packets these skbs will need to
+	 * be dropped at the handler.  The vlan accel path may have
+	 * already set the bond_should_drop flag.
+	 */
 	null_or_orig = NULL;
 	orig_dev = skb->dev;
+#if defined(CONFIG_BONDING) || defined(CONFIG_BONDING_MODULE)
 	master = ACCESS_ONCE(orig_dev->master);
-	if (master) {
-		if (skb_bond_should_drop(skb, master))
+	if (skb->bond_should_drop)
+		null_or_orig = orig_dev;
+	else if (master) {
+		if (skb_bond_should_drop(skb, master)) {
+			skb->bond_should_drop = 1;
 			null_or_orig = orig_dev; /* deliver only exact match */
-		else
+		} else
 			skb->dev = master;
 	}
+#endif
 
 	__get_cpu_var(softnet_data).processed++;
 

