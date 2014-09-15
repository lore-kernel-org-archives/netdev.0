From: Bernhard Thaler <bernhard.thaler@wvnet.at>
Subject: [PATCH 1/1] bridge: Fix NAT66ed IPv6 packets not being bridged correctly
Date: Mon, 15 Sep 2014 23:27:28 +0200
Message-ID: <1410816448-4401-1-git-send-email-bernhard.thaler@wvnet.at>
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org,
	Bernhard Thaler <bernhard.thaler@wvnet.at>
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	stephen@networkplumber.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ethernet frames are not bridged to correct interface when packets have
been NAT66ed; compared to IPv4 logic in code, IPv6 code does not store
original address (before NAT) on transmit to determine if packet was
NAT66ed on receive to swap addresses back.

Changes added in br_netfilter.c to store original address, compare
against it and determine correct output interface. Changes needed in
netfilter_bridge.h to store IPv6 address in pre-existing union.
Export of ip6_route_input needed to use it in br_netfilter.c.

Problem may only affect systems doing NAT66 and ethernet bridging at
the same time. Tested in NAT66 setup on base of an ethernet bridge.

Signed-off-by: Bernhard Thaler <bernhard.thaler@wvnet.at>
---
 include/linux/netfilter_bridge.h |    2 +
 net/bridge/br_netfilter.c        |  136 ++++++++++++++++++++++++++++----------
 net/ipv6/route.c                 |    1 +
 3 files changed, 105 insertions(+), 34 deletions(-)

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
index a615264..2ae3888 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -35,6 +35,9 @@
 #include <net/ip.h>
 #include <net/ipv6.h>
 #include <net/route.h>
+#include <net/ip6_route.h>
+#include <net/flow.h>
+#include <net/dst.h>
 
 #include <asm/uaccess.h>
 #include "br_private.h"
@@ -42,10 +45,18 @@
 #include <linux/sysctl.h>
 #endif
 
-#define skb_origaddr(skb)	 (((struct bridge_skb_cb *) \
-				 (skb->nf_bridge->data))->daddr.ipv4)
-#define store_orig_dstaddr(skb)	 (skb_origaddr(skb) = ip_hdr(skb)->daddr)
-#define dnat_took_place(skb)	 (skb_origaddr(skb) != ip_hdr(skb)->daddr)
+#define skb_origaddr(skb)		(((struct bridge_skb_cb *)\
+					(skb->nf_bridge->data))->daddr.ipv4)
+#define skb_origaddr_ipv6(skb)		(((struct bridge_skb_cb *)\
+					(skb->nf_bridge->data))->daddr.ipv6)
+#define store_orig_dstaddr(skb)		(skb_origaddr(skb) = ip_hdr(skb)->daddr)
+#define store_orig_dstaddr_ipv6(skb)	(skb_origaddr_ipv6(skb) = \
+					ipv6_hdr(skb)->daddr)
+#define dnat_took_place(skb)		(skb_origaddr(skb) != \
+					ip_hdr(skb)->daddr)
+#define dnat_took_place_ipv6(skb)	(memcmp(&skb_origaddr_ipv6(skb), \
+					&(ipv6_hdr(skb)->daddr), \
+					sizeof(struct in6_addr)) != 0)
 
 #ifdef CONFIG_SYSCTL
 static struct ctl_table_header *brnf_sysctl_header;
@@ -340,36 +351,6 @@ int nf_bridge_copy_header(struct sk_buff *skb)
 	return 0;
 }
 
-/* PF_BRIDGE/PRE_ROUTING *********************************************/
-/* Undo the changes made for ip6tables PREROUTING and continue the
- * bridge PRE_ROUTING hook. */
-static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
-{
-	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
-	struct rtable *rt;
-
-	if (nf_bridge->mask & BRNF_PKT_TYPE) {
-		skb->pkt_type = PACKET_OTHERHOST;
-		nf_bridge->mask ^= BRNF_PKT_TYPE;
-	}
-	nf_bridge->mask ^= BRNF_NF_BRIDGE_PREROUTING;
-
-	rt = bridge_parent_rtable(nf_bridge->physindev);
-	if (!rt) {
-		kfree_skb(skb);
-		return 0;
-	}
-	skb_dst_set_noref(skb, &rt->dst);
-
-	skb->dev = nf_bridge->physindev;
-	nf_bridge_update_protocol(skb);
-	nf_bridge_push_encap_header(skb);
-	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
-		       br_handle_frame_finish, 1);
-
-	return 0;
-}
-
 /* Obtain the correct destination MAC address, while preserving the original
  * source MAC address. If we already know this address, we just copy it. If we
  * don't, we use the neighbour framework to find out. In both cases, we make
@@ -527,6 +508,92 @@ bridged_dnat:
 	return 0;
 }
 
+/* PF_BRIDGE/PRE_ROUTING *********************************************
+ * Undo the changes made for ip6tables PREROUTING and continue the
+ * bridge PRE_ROUTING hook.
+ */
+static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
+{
+	struct net_device *dev = skb->dev;
+	struct ipv6hdr *iph = ipv6_hdr(skb);
+	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
+	struct rtable *rt;
+	struct dst_entry *dst;
+	struct flowi6 fl6 = {
+		.flowi6_iif = skb->dev->ifindex,
+		.daddr = iph->daddr,
+		.saddr = iph->saddr,
+		.flowlabel = ip6_flowinfo(iph),
+		.flowi6_mark = skb->mark,
+		.flowi6_proto = iph->nexthdr,
+	};
+
+	if (nf_bridge->mask & BRNF_PKT_TYPE) {
+		skb->pkt_type = PACKET_OTHERHOST;
+		nf_bridge->mask ^= BRNF_PKT_TYPE;
+	}
+	nf_bridge->mask ^= BRNF_NF_BRIDGE_PREROUTING;
+
+	if (dnat_took_place_ipv6(skb)) {
+		ip6_route_input(skb);
+		/* ip6_route_input is void function,
+		 * no int returned as in ip4_route_input
+		 * changes value of skb->_skb_refdst) on success
+		 */
+		if (skb->_skb_refdst == 0) {
+			struct in_device *in_dev = __in_dev_get_rcu(dev);
+
+			if (!in_dev || IN_DEV_FORWARD(in_dev))
+				goto free_skb;
+
+			dst = ip6_route_output(dev_net(dev), skb->sk, &fl6);
+			if (!IS_ERR(dst)) {
+				/* - Bridged-and-DNAT'ed traffic doesn't
+				 *   require ip_forwarding.
+				 */
+				if (dst->dev == dev) {
+					skb_dst_set(skb, dst);
+					goto bridged_dnat;
+				}
+				dst_release(dst);
+			}
+free_skb:
+			kfree_skb(skb);
+			return 0;
+		} else {
+			if (skb_dst(skb)->dev == dev) {
+bridged_dnat:
+				skb->dev = nf_bridge->physindev;
+				nf_bridge_update_protocol(skb);
+				nf_bridge_push_encap_header(skb);
+				NF_HOOK_THRESH(NFPROTO_BRIDGE,
+					       NF_BR_PRE_ROUTING,
+					       skb, skb->dev, NULL,
+					       br_nf_pre_routing_finish_bridge,
+					       1);
+				return 0;
+			}
+			memcpy(eth_hdr(skb)->h_dest, dev->dev_addr, ETH_ALEN);
+			skb->pkt_type = PACKET_HOST;
+		}
+	} else {
+		rt = bridge_parent_rtable(nf_bridge->physindev);
+		if (!rt) {
+			kfree_skb(skb);
+			return 0;
+		}
+		skb_dst_set_noref(skb, &rt->dst);
+	}
+
+	skb->dev = nf_bridge->physindev;
+	nf_bridge_update_protocol(skb);
+	nf_bridge_push_encap_header(skb);
+	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
+		       br_handle_frame_finish, 1);
+
+	return 0;
+}
+
 static struct net_device *brnf_get_logical_dev(struct sk_buff *skb, const struct net_device *dev)
 {
 	struct net_device *vlan, *br;
@@ -658,6 +725,7 @@ static unsigned int br_nf_pre_routing_ipv6(const struct nf_hook_ops *ops,
 	if (!setup_pre_routing(skb))
 		return NF_DROP;
 
+	store_orig_dstaddr_ipv6(skb);
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
1.7.10.4
