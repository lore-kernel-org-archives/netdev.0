From: John Fastabend <john.r.fastabend@intel.com>
Subject: [PATCH v2] net: deliver skbs on inactive slaves to exact matches
Date: Thu, 03 Jun 2010 12:30:11 -0700
Message-ID: <20100603193011.4916.12354.stgit@jf-dev2-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, nhorman@tuxdriver.com,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: fubar@us.ibm.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:26148 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753010Ab0FCTcX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jun 2010 15:32:23 -0400
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
logic to check for the deliver_no_wcard flag and if it
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

 include/linux/skbuff.h |    5 ++++-
 net/8021q/vlan_core.c  |    4 ++--
 net/core/dev.c         |   17 ++++++++++++++---
 3 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index bf243fc..f89e7fd 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -380,7 +380,10 @@ struct sk_buff {
 	kmemcheck_bitfield_begin(flags2);
 	__u16			queue_mapping:16;
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
-	__u8			ndisc_nodetype:2;
+	__u8			ndisc_nodetype:2,
+				deliver_no_wcard:1;
+#else
+	__u8			deliver_no_wcard:1;
 #endif
 	kmemcheck_bitfield_end(flags2);
 
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index bd537fc..50f58f5 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -12,7 +12,7 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 		return NET_RX_DROP;
 
 	if (skb_bond_should_drop(skb, ACCESS_ONCE(skb->dev->master)))
-		goto drop;
+		skb->deliver_no_wcard = 1;
 
 	skb->skb_iif = skb->dev->ifindex;
 	__vlan_hwaccel_put_tag(skb, vlan_tci);
@@ -84,7 +84,7 @@ vlan_gro_common(struct napi_struct *napi, struct vlan_group *grp,
 	struct sk_buff *p;
 
 	if (skb_bond_should_drop(skb, ACCESS_ONCE(skb->dev->master)))
-		goto drop;
+		skb->deliver_no_wcard = 1;
 
 	skb->skb_iif = skb->dev->ifindex;
 	__vlan_hwaccel_put_tag(skb, vlan_tci);
diff --git a/net/core/dev.c b/net/core/dev.c
index ccba781..9c356fd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2821,13 +2821,24 @@ static int __netif_receive_skb(struct sk_buff *skb)
 	if (!skb->skb_iif)
 		skb->skb_iif = skb->dev->ifindex;
 
+	/*
+	 * bonding note: skbs received on inactive slaves should only
+	 * be delivered to pkt handlers that are exact matches.  Also
+	 * the deliver_no_wcard flag will be set.  If packet handlers
+	 * are sensitive to duplicate packets these skbs will need to
+	 * be dropped at the handler.  The vlan accel path may have
+	 * already set the deliver_no_wcard flag.
+	 */
 	null_or_orig = NULL;
 	orig_dev = skb->dev;
 	master = ACCESS_ONCE(orig_dev->master);
-	if (master) {
-		if (skb_bond_should_drop(skb, master))
+	if (skb->deliver_no_wcard)
+		null_or_orig = orig_dev;
+	else if (master) {
+		if (skb_bond_should_drop(skb, master)) {
+			skb->deliver_no_wcard = 1;
 			null_or_orig = orig_dev; /* deliver only exact match */
-		else
+		} else
 			skb->dev = master;
 	}
 

