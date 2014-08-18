From: Sven Eckelmann <sven@open-mesh.com>
Subject: [RFC] bridge: Allow to redirect IPv6 traffic to local machine
Date: Mon, 18 Aug 2014 16:36:55 +0200
Message-ID: <1408372615-16383-1-git-send-email-sven@open-mesh.com>
References: <1392920071.66303.YahooMailNeo@web172306.mail.ir2.yahoo.com>
Cc: bridge@lists.linux-foundation.org, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	marek@open-mesh.com, Sven Eckelmann <sven@open-mesh.com>
To: artiemhamilton@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:53929 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751066AbaHROhP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Aug 2014 10:37:15 -0400
In-Reply-To: <1392920071.66303.YahooMailNeo@web172306.mail.ir2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv4 allows to redirect any traffic over a bridge to the local machine using
iptables.

$ sysctl -w net.bridge.bridge-nf-call-iptables=1
$ iptables -t nat -A PREROUTING -p tcp -m tcp --dport 8080 \
  -j REDIRECT --to-ports 81

This didn't work with ip6tables because the redirect was not correctly detected.
The bridge pre-routing (finish) netfilter hook has to check for a possible
redirect and then fix the destination mac address. This makes it possible to
use the ip6tables rules for local DNAT REDIRECT similar to the IPv4 version.

$ sysctl -w net.bridge.bridge-nf-call-ip6tables=1
$ ip6tables -t nat -A PREROUTING -p tcp -m tcp --dport 8080 \
  -j REDIRECT --to-ports 81

Signed-off-by: Sven Eckelmann <sven@open-mesh.com>
---
Hi Artie Hamilton,

I just had the same problem and modified br_netfilter.c to work in a similar
setup. Maybe this is also helps you.

I've used your example in the patch description because it was simple and easy.

Kind regards,
	Sven



 include/linux/netfilter_bridge.h |  2 +
 net/bridge/br_netfilter.c        | 80 +++++++++++++++++++++++++++++++++++++---
 net/ipv6/route.c                 |  1 +
 3 files changed, 78 insertions(+), 5 deletions(-)

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index 8ab1c27..3a9cdcd 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -2,6 +2,7 @@
 #define __LINUX_BRIDGE_NETFILTER_H
 
 #include <uapi/linux/netfilter_bridge.h>
+#include <uapi/linux/in6.h>
 
 
 enum nf_br_hook_priorities {
@@ -79,6 +80,7 @@ static inline unsigned int nf_bridge_pad(const struct sk_buff *skb)
 struct bridge_skb_cb {
 	union {
 		__be32 ipv4;
+		struct in6_addr ipv6;
 	} daddr;
 };
 
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index a615264..ef8c0ac 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -18,6 +18,7 @@
 #include <linux/kernel.h>
 #include <linux/slab.h>
 #include <linux/ip.h>
+#include <linux/ipv6.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <linux/if_arp.h>
@@ -30,11 +31,13 @@
 #include <linux/netfilter_ipv6.h>
 #include <linux/netfilter_arp.h>
 #include <linux/in_route.h>
+#include <linux/ipv6_route.h>
 #include <linux/inetdevice.h>
 
 #include <net/ip.h>
 #include <net/ipv6.h>
 #include <net/route.h>
+#include <net/ip6_route.h>
 
 #include <asm/uaccess.h>
 #include "br_private.h"
@@ -47,6 +50,13 @@
 #define store_orig_dstaddr(skb)	 (skb_origaddr(skb) = ip_hdr(skb)->daddr)
 #define dnat_took_place(skb)	 (skb_origaddr(skb) != ip_hdr(skb)->daddr)
 
+#define skb_origaddr6(skb)	 (((struct bridge_skb_cb *) \
+				   (skb->nf_bridge->data))->daddr.ipv6)
+#define store_orig_dstaddr6(skb) (skb_origaddr6(skb) = ipv6_hdr(skb)->daddr)
+#define dnat_took_place6(skb)	 (memcmp(&skb_origaddr6(skb), \
+					 &ipv6_hdr(skb)->daddr, \
+					 sizeof(ipv6_hdr(skb)->daddr)) != 0)
+
 #ifdef CONFIG_SYSCTL
 static struct ctl_table_header *brnf_sysctl_header;
 static int brnf_call_iptables __read_mostly = 1;
@@ -343,10 +353,45 @@ int nf_bridge_copy_header(struct sk_buff *skb)
 /* PF_BRIDGE/PRE_ROUTING *********************************************/
 /* Undo the changes made for ip6tables PREROUTING and continue the
  * bridge PRE_ROUTING hook. */
+
+static int br_nf_pre_routing_finish_bridge(struct sk_buff *skb);
+
+/* This requires some explaining. If DNAT has taken place,
+ * we will need to fix up the destination Ethernet address.
+ *
+ * There are two cases to consider:
+ * 1. The packet was DNAT'ed to a device in the same bridge
+ *    port group as it was received on. We can still bridge
+ *    the packet.
+ * 2. The packet was DNAT'ed to a different device, either
+ *    a non-bridged device or another bridge port group.
+ *    The packet will need to be routed.
+ *
+ * The correct way of distinguishing between these two cases is to
+ * call ip6_route_input() and to look at skb->dst->dev, which is
+ * changed to the destination device if ip6_route_input() succeeds.
+ *
+ * Let's first consider the case that ip6_route_input() succeeds:
+ *
+ * If the output device equals the logical bridge device the packet
+ * came in on, we can consider this bridging. The corresponding MAC
+ * address will be obtained in br_nf_pre_routing_finish_bridge.
+ * Otherwise, the packet is considered to be routed and we just
+ * change the destination MAC address so that the packet will
+ * later be passed up to the IP stack to be routed. For a redirected
+ * packet, ip6_route_input() will give back the localhost as output device,
+ * which differs from the bridge device.
+ *
+ * Let's now consider the case that ip6_route_input() fails:
+ *
+ * This can be because the destination address is martian, in which case
+ * the packet will be dropped.
+ */
 static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
 {
 	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
 	struct rtable *rt;
+	struct net_device *dev = skb->dev;
 
 	if (nf_bridge->mask & BRNF_PKT_TYPE) {
 		skb->pkt_type = PACKET_OTHERHOST;
@@ -354,12 +399,36 @@ static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
 	}
 	nf_bridge->mask ^= BRNF_NF_BRIDGE_PREROUTING;
 
-	rt = bridge_parent_rtable(nf_bridge->physindev);
-	if (!rt) {
-		kfree_skb(skb);
-		return 0;
+	if (dnat_took_place6(skb)) {
+		skb_dst_drop(skb);
+		ip6_route_input(skb);
+
+		if (skb_dst(skb)->error) {
+			kfree_skb(skb);
+			return 0;
+		}
+
+		if (skb_dst(skb)->dev == dev) {
+			skb->dev = nf_bridge->physindev;
+			nf_bridge_update_protocol(skb);
+			nf_bridge_push_encap_header(skb);
+			NF_HOOK_THRESH(NFPROTO_BRIDGE,
+				       NF_BR_PRE_ROUTING,
+				       skb, skb->dev, NULL,
+				       br_nf_pre_routing_finish_bridge,
+				       1);
+			return 0;
+		}
+		memcpy(eth_hdr(skb)->h_dest, dev->dev_addr, ETH_ALEN);
+		skb->pkt_type = PACKET_HOST;
+	} else {
+		rt = bridge_parent_rtable(nf_bridge->physindev);
+		if (!rt) {
+			kfree_skb(skb);
+			return 0;
+		}
+		skb_dst_set_noref(skb, &rt->dst);
 	}
-	skb_dst_set_noref(skb, &rt->dst);
 
 	skb->dev = nf_bridge->physindev;
 	nf_bridge_update_protocol(skb);
@@ -658,6 +727,7 @@ static unsigned int br_nf_pre_routing_ipv6(const struct nf_hook_ops *ops,
 	if (!setup_pre_routing(skb))
 		return NF_DROP;
 
+	store_orig_dstaddr6(skb);
 	skb->protocol = htons(ETH_P_IPV6);
 	NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING, skb, skb->dev, NULL,
 		br_nf_pre_routing_finish_ipv6);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f23fbd2..e328905 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1017,6 +1017,7 @@ void ip6_route_input(struct sk_buff *skb)
 
 	skb_dst_set(skb, ip6_route_input_lookup(net, skb->dev, &fl6, flags));
 }
+EXPORT_SYMBOL(ip6_route_input);
 
 static struct rt6_info *ip6_pol_route_output(struct net *net, struct fib6_table *table,
 					     struct flowi6 *fl6, int flags)
-- 
2.1.0
