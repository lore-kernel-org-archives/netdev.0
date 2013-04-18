From: Florian Westphal <fw@strlen.de>
Subject: [PATCH] bridge: fix IP DNAT handling when packet is sent back via same bport
Date: Thu, 18 Apr 2013 11:37:13 +0200
Message-ID: <1366277833-1405-1-git-send-email-fw@strlen.de>
Cc: netfilter-devel@vger.kernel.org, Florian Westphal <fw@strlen.de>,
	Bart De Schuymer <bdschuym@pandora.be>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:50768 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S967443Ab3DRJfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 05:35:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit e179e6322ac334e21a3c6d669d95bc967e5d0a80
(netfilter: bridge-netfilter: Fix MAC header handling with IP DNAT)
breaks DNAT when the destination address sits on the same bridgeport
the packet originally arrived on.  Example:

( Network1 ) -- [ eth1-Bridge-eth0 ] -- ( Network2 )

Lets assume bridge has ip 192.168.10.8, and following netfilter rules
are active:

-A PREROUTING  -s 192.168.10.1 -d 192.168.10.8 -p tcp --dport 21 -j DNAT --to-destination 192.168.10.1
-A POSTROUTING -s 192.168.10.1 -d 192.168.10.1 -p tcp --dport 21 -j SNAT --to-source 192.168.10.8

With kernels before 2.6.35, this makes host 192.168.10.1 connecting to
the bridge on port 21 connect-to-self.

>From 2.6.35 onwards this no longer works since the natted packet travels
through the bridge forward logic, where should_deliver() refuses to send
the packet because the destination bridge port is the same as the
originating port.

Enabling hairpin mode on eth1 makes it work, but still causes
problems because the original client finds its own mac address as the
packets source (it used to be the bridge MAC).

This patch tries to fix this in the following manner:
- tag all skbs with dnat-applied with BRDIGED_DNAT flag
- modify bridge fwd logic to detect "same-bridgeport-and-dnat'd"
  condition, permit this, and flag skb accordingly
- in bridge postrouting, replace source mac with bridge mac addess
  if skb is such a dnat-to-same-port.

Cc: Bart De Schuymer <bdschuym@pandora.be>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Bart,

 it would be great if you could look into this, as I am not very familiar
 with net/bridge/.

 Especially,
 1) is it safe to set BRNF_BRIDGED_DNAT unconditionally in br_nf_pre_routing_finish_bridge() ?
 2) is it ok to memcpy to eth_hdr() in br_nf_post_routing() [ considering there might be encap headers
    that were removed? ]

 include/linux/netfilter_bridge.h |    2 ++
 net/bridge/br_forward.c          |   16 +++++++++++++++-
 net/bridge/br_netfilter.c        |   13 +++++++++++--
 3 files changed, 28 insertions(+), 3 deletions(-)

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index dfb4d9e..eacd206 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -23,6 +23,8 @@ enum nf_br_hook_priorities {
 #define BRNF_NF_BRIDGE_PREROUTING	0x08
 #define BRNF_8021Q			0x10
 #define BRNF_PPPoE			0x20
+/* DNAT'd packet is to be sent back on same bridge port: */
+#define BRNF_BRIDGED_DNAT_DODGY		0x40
 
 /* Only used in br_forward.c */
 extern int nf_bridge_copy_header(struct sk_buff *skb);
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 092b20e..a0d3c56 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -116,10 +116,24 @@ void br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 	kfree_skb(skb);
 }
 
+static int forward_should_deliver(const struct net_bridge_port *to,
+				  struct sk_buff *skb)
+{
+#ifdef CONFIG_BRIDGE_NETFILTER
+	if (skb->dev == to->dev &&
+	    skb->nf_bridge && (skb->nf_bridge->mask & BRNF_BRIDGED_DNAT)) {
+		skb->nf_bridge->mask |= BRNF_BRIDGED_DNAT_DODGY;
+		return to->state == BR_STATE_FORWARDING &&
+			br_allowed_egress(to->br, nbp_get_vlan_info(to), skb);
+	}
+#endif
+	return should_deliver(to, skb);
+}
+
 /* called with rcu_read_lock */
 void br_forward(const struct net_bridge_port *to, struct sk_buff *skb, struct sk_buff *skb0)
 {
-	if (should_deliver(to, skb)) {
+	if (forward_should_deliver(to, skb)) {
 		if (skb0)
 			deliver_clone(to, skb, __br_forward);
 		else
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index fe43bc7..4830c4c 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -389,6 +389,10 @@ static int br_nf_pre_routing_finish_bridge(struct sk_buff *skb)
 	if (neigh) {
 		int ret;
 
+		/* tell br_dev_xmit to continue with forwarding, make
+		 * fwd path handle inport == outport case
+		 */
+		nf_bridge->mask |= BRNF_BRIDGED_DNAT;
 		if (neigh->hh.hh_len) {
 			neigh_hh_bridge(&neigh->hh, skb);
 			skb->dev = nf_bridge->physindev;
@@ -402,8 +406,6 @@ static int br_nf_pre_routing_finish_bridge(struct sk_buff *skb)
 							 -(ETH_HLEN-ETH_ALEN),
 							 skb->nf_bridge->data,
 							 ETH_HLEN-ETH_ALEN);
-			/* tell br_dev_xmit to continue with forwarding */
-			nf_bridge->mask |= BRNF_BRIDGED_DNAT;
 			ret = neigh->output(neigh, skb);
 		}
 		neigh_release(neigh);
@@ -906,6 +908,13 @@ static unsigned int br_nf_post_routing(unsigned int hook, struct sk_buff *skb,
 		nf_bridge->mask |= BRNF_PKT_TYPE;
 	}
 
+	/* special case: packet is sent on same bridge port it arrived on
+	 * due to DNAT; need to substitute original source mac with bridge mac
+	 * so further packets are also sent to the bridge.
+	 */
+	if (nf_bridge->mask & BRNF_BRIDGED_DNAT_DODGY)
+		memcpy(eth_hdr(skb)->h_source, realoutdev->dev_addr, ETH_ALEN);
+
 	nf_bridge_pull_encap_header(skb);
 	nf_bridge_save_header(skb);
 	if (pf == NFPROTO_IPV4)
-- 
1.7.8.6
