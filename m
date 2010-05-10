From: kaber@trash.net
Subject: [PATCH 68/84] netfilter: bridge-netfilter: simplify IP DNAT
Date: Mon, 10 May 2010 22:18:39 +0200
Message-ID: <1273522735-24672-69-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54509 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756936Ab0EJUT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:19:27 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bart De Schuymer <bdschuym@pandora.be>

Remove br_netfilter.c::br_nf_local_out(). The function
br_nf_local_out() was needed because the PF_BRIDGE::LOCAL_OUT hook
could be called when IP DNAT happens on to-be-bridged traffic. The
new scheme eliminates this mess.

Signed-off-by: Bart De Schuymer <bdschuym@pandora.be>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter_bridge.h |   17 +++++-
 net/bridge/br_device.c           |    9 +++-
 net/bridge/br_netfilter.c        |  114 ++++++--------------------------------
 3 files changed, 40 insertions(+), 100 deletions(-)

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index f8105e5..ffab6c4 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -41,9 +41,8 @@ enum nf_br_hook_priorities {
 
 #define BRNF_PKT_TYPE			0x01
 #define BRNF_BRIDGED_DNAT		0x02
-#define BRNF_DONT_TAKE_PARENT		0x04
-#define BRNF_BRIDGED			0x08
-#define BRNF_NF_BRIDGE_PREROUTING	0x10
+#define BRNF_BRIDGED			0x04
+#define BRNF_NF_BRIDGE_PREROUTING	0x08
 
 
 /* Only used in br_forward.c */
@@ -68,6 +67,18 @@ static inline unsigned int nf_bridge_encap_header_len(const struct sk_buff *skb)
 	}
 }
 
+extern int br_handle_frame_finish(struct sk_buff *skb);
+/* Only used in br_device.c */
+static inline int br_nf_pre_routing_finish_bridge_slow(struct sk_buff *skb)
+{
+	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
+
+	skb_pull(skb, ETH_HLEN);
+	nf_bridge->mask ^= BRNF_BRIDGED_DNAT;
+	skb->dev = nf_bridge->physindev;
+	return br_handle_frame_finish(skb);
+}
+
 /* This is called by the IP fragmenting code and it ensures there is
  * enough room for the encapsulating header (if there is one). */
 static inline unsigned int nf_bridge_pad(const struct sk_buff *skb)
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 5b8a6e7..007bde8 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -15,7 +15,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
-
+#include <linux/netfilter_bridge.h>
 #include <asm/uaccess.h>
 #include "br_private.h"
 
@@ -28,6 +28,13 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct net_bridge_mdb_entry *mdst;
 	struct br_cpu_netstats *brstats = this_cpu_ptr(br->stats);
 
+#ifdef CONFIG_BRIDGE_NETFILTER
+	if (skb->nf_bridge && (skb->nf_bridge->mask & BRNF_BRIDGED_DNAT)) {
+		br_nf_pre_routing_finish_bridge_slow(skb);
+		return NETDEV_TX_OK;
+	}
+#endif
+
 	brstats->tx_packets++;
 	brstats->tx_bytes += skb->len;
 
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index dd6f538..05dc630 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -246,8 +246,7 @@ static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
 }
 
 /* This requires some explaining. If DNAT has taken place,
- * we will need to fix up the destination Ethernet address,
- * and this is a tricky process.
+ * we will need to fix up the destination Ethernet address.
  *
  * There are two cases to consider:
  * 1. The packet was DNAT'ed to a device in the same bridge
@@ -261,52 +260,38 @@ static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
  * call ip_route_input() and to look at skb->dst->dev, which is
  * changed to the destination device if ip_route_input() succeeds.
  *
- * Let us first consider the case that ip_route_input() succeeds:
- *
- * If skb->dst->dev equals the logical bridge device the packet
- * came in on, we can consider this bridging. The packet is passed
- * through the neighbour output function to build a new destination
- * MAC address, which will make the packet enter br_nf_local_out()
- * not much later. In that function it is assured that the iptables
- * FORWARD chain is traversed for the packet.
+ * Let's first consider the case that ip_route_input() succeeds:
  *
+ * If the output device equals the logical bridge device the packet
+ * came in on, we can consider this bridging. The corresponding MAC
+ * address will be obtained in br_nf_pre_routing_finish_bridge.
  * Otherwise, the packet is considered to be routed and we just
  * change the destination MAC address so that the packet will
  * later be passed up to the IP stack to be routed. For a redirected
  * packet, ip_route_input() will give back the localhost as output device,
  * which differs from the bridge device.
  *
- * Let us now consider the case that ip_route_input() fails:
+ * Let's now consider the case that ip_route_input() fails:
  *
  * This can be because the destination address is martian, in which case
  * the packet will be dropped.
- * After a "echo '0' > /proc/sys/net/ipv4/ip_forward" ip_route_input()
- * will fail, while __ip_route_output_key() will return success. The source
- * address for __ip_route_output_key() is set to zero, so __ip_route_output_key
+ * If IP forwarding is disabled, ip_route_input() will fail, while
+ * ip_route_output_key() can return success. The source
+ * address for ip_route_output_key() is set to zero, so ip_route_output_key()
  * thinks we're handling a locally generated packet and won't care
- * if IP forwarding is allowed. We send a warning message to the users's
- * log telling her to put IP forwarding on.
- *
- * ip_route_input() will also fail if there is no route available.
- * In that case we just drop the packet.
- *
- * --Lennert, 20020411
- * --Bart, 20020416 (updated)
- * --Bart, 20021007 (updated)
- * --Bart, 20062711 (updated) */
+ * if IP forwarding is enabled. If the output device equals the logical bridge
+ * device, we proceed as if ip_route_input() succeeded. If it differs from the
+ * logical bridge port or if ip_route_output_key() fails we drop the packet.
+ */
+
 static int br_nf_pre_routing_finish_bridge(struct sk_buff *skb)
 {
-	if (skb->pkt_type == PACKET_OTHERHOST) {
-		skb->pkt_type = PACKET_HOST;
-		skb->nf_bridge->mask |= BRNF_PKT_TYPE;
-	}
-	skb->nf_bridge->mask ^= BRNF_NF_BRIDGE_PREROUTING;
-
 	skb->dev = bridge_parent(skb->dev);
 	if (skb->dev) {
 		struct dst_entry *dst = skb_dst(skb);
 
 		nf_bridge_pull_encap_header(skb);
+		skb->nf_bridge->mask |= BRNF_BRIDGED_DNAT;
 
 		if (dst->hh)
 			return neigh_hh_output(dst->hh, skb);
@@ -368,9 +353,6 @@ free_skb:
 		} else {
 			if (skb_dst(skb)->dev == dev) {
 bridged_dnat:
-				/* Tell br_nf_local_out this is a
-				 * bridged frame */
-				nf_bridge->mask |= BRNF_BRIDGED_DNAT;
 				skb->dev = nf_bridge->physindev;
 				nf_bridge_push_encap_header(skb);
 				NF_HOOK_THRESH(NFPROTO_BRIDGE,
@@ -721,54 +703,6 @@ static unsigned int br_nf_forward_arp(unsigned int hook, struct sk_buff *skb,
 	return NF_STOLEN;
 }
 
-/* PF_BRIDGE/LOCAL_OUT ***********************************************
- *
- * This function sees both locally originated IP packets and forwarded
- * IP packets (in both cases the destination device is a bridge
- * device). It also sees bridged-and-DNAT'ed packets.
- *
- * If (nf_bridge->mask & BRNF_BRIDGED_DNAT) then the packet is bridged
- * and we fake the PF_BRIDGE/FORWARD hook. The function br_nf_forward()
- * will then fake the PF_INET/FORWARD hook. br_nf_local_out() has priority
- * NF_BR_PRI_FIRST, so no relevant PF_BRIDGE/INPUT functions have been nor
- * will be executed.
- */
-static unsigned int br_nf_local_out(unsigned int hook, struct sk_buff *skb,
-				    const struct net_device *in,
-				    const struct net_device *out,
-				    int (*okfn)(struct sk_buff *))
-{
-	struct net_device *realindev;
-	struct nf_bridge_info *nf_bridge;
-
-	if (!skb->nf_bridge)
-		return NF_ACCEPT;
-
-	/* Need exclusive nf_bridge_info since we might have multiple
-	 * different physoutdevs. */
-	if (!nf_bridge_unshare(skb))
-		return NF_DROP;
-
-	nf_bridge = skb->nf_bridge;
-	if (!(nf_bridge->mask & BRNF_BRIDGED_DNAT))
-		return NF_ACCEPT;
-
-	/* Bridged, take PF_BRIDGE/FORWARD.
-	 * (see big note in front of br_nf_pre_routing_finish) */
-	nf_bridge->physoutdev = skb->dev;
-	realindev = nf_bridge->physindev;
-
-	if (nf_bridge->mask & BRNF_PKT_TYPE) {
-		skb->pkt_type = PACKET_OTHERHOST;
-		nf_bridge->mask ^= BRNF_PKT_TYPE;
-	}
-	nf_bridge_push_encap_header(skb);
-
-	NF_HOOK(NFPROTO_BRIDGE, NF_BR_FORWARD, skb, realindev, skb->dev,
-		br_forward_finish);
-	return NF_STOLEN;
-}
-
 #if defined(CONFIG_NF_CONNTRACK_IPV4) || defined(CONFIG_NF_CONNTRACK_IPV4_MODULE)
 static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 {
@@ -797,10 +731,7 @@ static unsigned int br_nf_post_routing(unsigned int hook, struct sk_buff *skb,
 	struct net_device *realoutdev = bridge_parent(skb->dev);
 	u_int8_t pf;
 
-	if (!nf_bridge)
-		return NF_ACCEPT;
-
-	if (!(nf_bridge->mask & (BRNF_BRIDGED | BRNF_BRIDGED_DNAT)))
+	if (!nf_bridge || !(nf_bridge->mask & BRNF_BRIDGED))
 		return NF_ACCEPT;
 
 	if (!realoutdev)
@@ -847,10 +778,8 @@ static unsigned int ip_sabotage_in(unsigned int hook, struct sk_buff *skb,
 	return NF_ACCEPT;
 }
 
-/* For br_nf_local_out we need (prio = NF_BR_PRI_FIRST), to insure that innocent
- * PF_BRIDGE/NF_BR_LOCAL_OUT functions don't get bridged traffic as input.
- * For br_nf_post_routing, we need (prio = NF_BR_PRI_LAST), because
- * ip_refrag() can return NF_STOLEN. */
+/* For br_nf_post_routing, we need (prio = NF_BR_PRI_LAST), because
+ * br_dev_queue_push_xmit is called afterwards */
 static struct nf_hook_ops br_nf_ops[] __read_mostly = {
 	{
 		.hook = br_nf_pre_routing,
@@ -881,13 +810,6 @@ static struct nf_hook_ops br_nf_ops[] __read_mostly = {
 		.priority = NF_BR_PRI_BRNF,
 	},
 	{
-		.hook = br_nf_local_out,
-		.owner = THIS_MODULE,
-		.pf = PF_BRIDGE,
-		.hooknum = NF_BR_LOCAL_OUT,
-		.priority = NF_BR_PRI_FIRST,
-	},
-	{
 		.hook = br_nf_post_routing,
 		.owner = THIS_MODULE,
 		.pf = PF_BRIDGE,
-- 
1.7.0.4

