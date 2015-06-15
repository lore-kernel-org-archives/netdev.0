From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/32] netfilter: bridge: forward IPv6 fragmented packets
Date: Mon, 15 Jun 2015 23:26:05 +0200
Message-ID: <1434403589-24796-9-git-send-email-pablo@netfilter.org>
References: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58754 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756106AbbFOVV1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2015 17:21:27 -0400
In-Reply-To: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bernhard Thaler <bernhard.thaler@wvnet.at>

IPv6 fragmented packets are not forwarded on an ethernet bridge
with netfilter ip6_tables loaded. e.g. steps to reproduce

1) create a simple bridge like this

        modprobe br_netfilter
        brctl addbr br0
        brctl addif br0 eth0
        brctl addif br0 eth2
        ifconfig eth0 up
        ifconfig eth2 up
        ifconfig br0 up

2) place a host with an IPv6 address on each side of the bridge

        set IPv6 address on host A:
        ip -6 addr add fd01:2345:6789:1::1/64 dev eth0

        set IPv6 address on host B:
        ip -6 addr add fd01:2345:6789:1::2/64 dev eth0

3) run a simple ping command on host A with packets > MTU

        ping6 -s 4000 fd01:2345:6789:1::2

4) wait some time and run e.g. "ip6tables -t nat -nvL" on the bridge

IPv6 fragmented packets traverse the bridge cleanly until somebody runs.
"ip6tables -t nat -nvL". As soon as it is run (and netfilter modules are
loaded) IPv6 fragmented packets do not traverse the bridge any more (you
see no more responses in ping's output).

After applying this patch IPv6 fragmented packets traverse the bridge
cleanly in above scenario.

Signed-off-by: Bernhard Thaler <bernhard.thaler@wvnet.at>
[pablo@netfilter.org: small changes to br_nf_dev_queue_xmit]
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter_ipv6.h |    2 +
 net/bridge/br_netfilter.c      |  139 ++++++++++++++++++++++++++++------------
 net/bridge/br_private.h        |    6 +-
 net/ipv6/netfilter.c           |    3 +-
 4 files changed, 108 insertions(+), 42 deletions(-)

diff --git a/include/linux/netfilter_ipv6.h b/include/linux/netfilter_ipv6.h
index e2d1969..8b7d28f 100644
--- a/include/linux/netfilter_ipv6.h
+++ b/include/linux/netfilter_ipv6.h
@@ -26,6 +26,8 @@ struct nf_ipv6_ops {
 	int (*chk_addr)(struct net *net, const struct in6_addr *addr,
 			const struct net_device *dev, int strict);
 	void (*route_input)(struct sk_buff *skb);
+	int (*fragment)(struct sock *sk, struct sk_buff *skb,
+			int (*output)(struct sock *, struct sk_buff *));
 };
 
 extern const struct nf_ipv6_ops __rcu *nf_ipv6_ops;
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index d201ea4..535f9da 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -34,6 +34,7 @@
 
 #include <net/ip.h>
 #include <net/ipv6.h>
+#include <net/addrconf.h>
 #include <net/route.h>
 #include <net/netfilter/br_netfilter.h>
 
@@ -320,6 +321,55 @@ bad:
 	return -1;
 }
 
+/* Equivalent to br_validate_ipv4 for IPv6 */
+static int br_validate_ipv6(struct sk_buff *skb)
+{
+	const struct ipv6hdr *hdr;
+	struct net_device *dev = skb->dev;
+	struct inet6_dev *idev = in6_dev_get(skb->dev);
+	u32 pkt_len;
+	u8 ip6h_len = sizeof(struct ipv6hdr);
+
+	if (!pskb_may_pull(skb, ip6h_len))
+		goto inhdr_error;
+
+	if (skb->len < ip6h_len)
+		goto drop;
+
+	hdr = ipv6_hdr(skb);
+
+	if (hdr->version != 6)
+		goto inhdr_error;
+
+	pkt_len = ntohs(hdr->payload_len);
+
+	if (pkt_len || hdr->nexthdr != NEXTHDR_HOP) {
+		if (pkt_len + ip6h_len > skb->len) {
+			IP6_INC_STATS_BH(dev_net(dev), idev,
+					 IPSTATS_MIB_INTRUNCATEDPKTS);
+			goto drop;
+		}
+		if (pskb_trim_rcsum(skb, pkt_len + ip6h_len)) {
+			IP6_INC_STATS_BH(dev_net(dev), idev,
+					 IPSTATS_MIB_INDISCARDS);
+			goto drop;
+		}
+	}
+	if (hdr->nexthdr == NEXTHDR_HOP && check_hbh_len(skb))
+		goto drop;
+
+	memset(IP6CB(skb), 0, sizeof(struct inet6_skb_parm));
+	/* No IP options in IPv6 header; however it should be
+	 * checked if some next headers need special treatment
+	 */
+	return 0;
+
+inhdr_error:
+	IP6_INC_STATS_BH(dev_net(dev), idev, IPSTATS_MIB_INHDRERRORS);
+drop:
+	return -1;
+}
+
 static void nf_bridge_update_protocol(struct sk_buff *skb)
 {
 	switch (skb->nf_bridge->orig_proto) {
@@ -405,6 +455,8 @@ static int br_nf_pre_routing_finish_ipv6(struct sock *sk, struct sk_buff *skb)
 	struct net_device *dev = skb->dev;
 	const struct nf_ipv6_ops *v6ops = nf_get_ipv6_ops();
 
+	nf_bridge->frag_max_size = IP6CB(skb)->frag_max_size;
+
 	if (nf_bridge->pkt_otherhost) {
 		skb->pkt_type = PACKET_OTHERHOST;
 		nf_bridge->pkt_otherhost = false;
@@ -606,35 +658,15 @@ static struct net_device *setup_pre_routing(struct sk_buff *skb)
 }
 
 /* Replicate the checks that IPv6 does on packet reception and pass the packet
- * to ip6tables, which doesn't support NAT, so things are fairly simple. */
+ * to ip6tables.
+ */
 static unsigned int br_nf_pre_routing_ipv6(const struct nf_hook_ops *ops,
 					   struct sk_buff *skb,
 					   const struct nf_hook_state *state)
 {
 	struct nf_bridge_info *nf_bridge;
-	const struct ipv6hdr *hdr;
-	u32 pkt_len;
-
-	if (skb->len < sizeof(struct ipv6hdr))
-		return NF_DROP;
-
-	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
-		return NF_DROP;
-
-	hdr = ipv6_hdr(skb);
-
-	if (hdr->version != 6)
-		return NF_DROP;
 
-	pkt_len = ntohs(hdr->payload_len);
-
-	if (pkt_len || hdr->nexthdr != NEXTHDR_HOP) {
-		if (pkt_len + sizeof(struct ipv6hdr) > skb->len)
-			return NF_DROP;
-		if (pskb_trim_rcsum(skb, pkt_len + sizeof(struct ipv6hdr)))
-			return NF_DROP;
-	}
-	if (hdr->nexthdr == NEXTHDR_HOP && check_hbh_len(skb))
+	if (br_validate_ipv6(skb))
 		return NF_DROP;
 
 	nf_bridge_put(skb->nf_bridge);
@@ -738,9 +770,11 @@ static int br_nf_forward_finish(struct sock *sk, struct sk_buff *skb)
 
 	if (!IS_ARP(skb) && !IS_VLAN_ARP(skb)) {
 
-		if (skb->protocol == htons(ETH_P_IP)) {
+		if (skb->protocol == htons(ETH_P_IP))
 			nf_bridge->frag_max_size = IPCB(skb)->frag_max_size;
-		}
+
+		if (skb->protocol == htons(ETH_P_IPV6))
+			nf_bridge->frag_max_size = IP6CB(skb)->frag_max_size;
 
 		in = nf_bridge->physindev;
 		if (nf_bridge->pkt_otherhost) {
@@ -808,6 +842,12 @@ static unsigned int br_nf_forward_ip(const struct nf_hook_ops *ops,
 		IPCB(skb)->frag_max_size = nf_bridge->frag_max_size;
 	}
 
+	if (pf == NFPROTO_IPV6) {
+		if (br_validate_ipv6(skb))
+			return NF_DROP;
+		IP6CB(skb)->frag_max_size = nf_bridge->frag_max_size;
+	}
+
 	nf_bridge->physoutdev = skb->dev;
 	if (pf == NFPROTO_IPV4)
 		skb->protocol = htons(ETH_P_IP);
@@ -855,7 +895,7 @@ static unsigned int br_nf_forward_arp(const struct nf_hook_ops *ops,
 	return NF_STOLEN;
 }
 
-#if IS_ENABLED(CONFIG_NF_DEFRAG_IPV4)
+#if IS_ENABLED(CONFIG_NF_DEFRAG_IPV4) || IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
 static int br_nf_push_frag_xmit(struct sock *sk, struct sk_buff *skb)
 {
 	struct brnf_frag_data *data;
@@ -875,6 +915,7 @@ static int br_nf_push_frag_xmit(struct sock *sk, struct sk_buff *skb)
 	nf_bridge_info_free(skb);
 	return br_dev_queue_push_xmit(sk, skb);
 }
+#endif
 
 static int br_nf_ip_fragment(struct sock *sk, struct sk_buff *skb,
 			     int (*output)(struct sock *, struct sk_buff *))
@@ -897,21 +938,23 @@ static int br_nf_ip_fragment(struct sock *sk, struct sk_buff *skb,
 
 static int br_nf_dev_queue_xmit(struct sock *sk, struct sk_buff *skb)
 {
-	int ret;
 	struct nf_bridge_info *nf_bridge;
 	unsigned int mtu_reserved;
 
-	if (skb_is_gso(skb) || skb->protocol != htons(ETH_P_IP)) {
+	mtu_reserved = nf_bridge_mtu_reduction(skb);
+
+	if (skb_is_gso(skb) || skb->len + mtu_reserved <= skb->dev->mtu) {
 		nf_bridge_info_free(skb);
 		return br_dev_queue_push_xmit(sk, skb);
 	}
 
-	mtu_reserved = nf_bridge_mtu_reduction(skb);
 	nf_bridge = nf_bridge_info_get(skb);
+
+#if IS_ENABLED(CONFIG_NF_DEFRAG_IPV4)
 	/* This is wrong! We should preserve the original fragment
 	 * boundaries by preserving frag_list rather than refragmenting.
 	 */
-	if (skb->len + mtu_reserved > skb->dev->mtu) {
+	if (skb->protocol == htons(ETH_P_IP)) {
 		struct brnf_frag_data *data;
 
 		if (br_validate_ipv4(skb))
@@ -928,21 +971,37 @@ static int br_nf_dev_queue_xmit(struct sock *sk, struct sk_buff *skb)
 		skb_copy_from_linear_data_offset(skb, -data->size, data->mac,
 						 data->size);
 
-		ret = br_nf_ip_fragment(sk, skb, br_nf_push_frag_xmit);
-	} else {
-		nf_bridge_info_free(skb);
-		ret = br_dev_queue_push_xmit(sk, skb);
+		return br_nf_ip_fragment(sk, skb, br_nf_push_frag_xmit);
 	}
+#endif
+#if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
+	if (skb->protocol == htons(ETH_P_IPV6)) {
+		const struct nf_ipv6_ops *v6ops = nf_get_ipv6_ops();
+		struct brnf_frag_data *data;
 
-	return ret;
-}
-#else
-static int br_nf_dev_queue_xmit(struct sock *sk, struct sk_buff *skb)
-{
+		if (br_validate_ipv6(skb))
+			return NF_DROP;
+
+		IP6CB(skb)->frag_max_size = nf_bridge->frag_max_size;
+
+		nf_bridge_update_protocol(skb);
+
+		data = this_cpu_ptr(&brnf_frag_data_storage);
+		data->encap_size = nf_bridge_encap_header_len(skb);
+		data->size = ETH_HLEN + data->encap_size;
+
+		skb_copy_from_linear_data_offset(skb, -data->size, data->mac,
+						 data->size);
+
+		if (v6ops)
+			return v6ops->fragment(sk, skb, br_nf_push_frag_xmit);
+		else
+			return -EMSGSIZE;
+	}
+#endif
 	nf_bridge_info_free(skb);
 	return br_dev_queue_push_xmit(sk, skb);
 }
-#endif
 
 /* PF_BRIDGE/POST_ROUTING ********************************************/
 static unsigned int br_nf_post_routing(const struct nf_hook_ops *ops,
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 8cde96e..5dccced 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -18,6 +18,7 @@
 #include <linux/netpoll.h>
 #include <linux/u64_stats_sync.h>
 #include <net/route.h>
+#include <net/ip6_fib.h>
 #include <linux/if_vlan.h>
 
 #define BR_HASH_BITS 8
@@ -214,7 +215,10 @@ struct net_bridge
 	spinlock_t			hash_lock;
 	struct hlist_head		hash[BR_HASH_SIZE];
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
-	struct rtable 			fake_rtable;
+	union {
+		struct rtable		fake_rtable;
+		struct rt6_info		fake_rt6_info;
+	};
 	bool				nf_call_iptables;
 	bool				nf_call_ip6tables;
 	bool				nf_call_arptables;
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index bbca09f..b4de08a 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -191,7 +191,8 @@ static __sum16 nf_ip6_checksum_partial(struct sk_buff *skb, unsigned int hook,
 
 static const struct nf_ipv6_ops ipv6ops = {
 	.chk_addr	= ipv6_chk_addr,
-	.route_input    = ip6_route_input
+	.route_input    = ip6_route_input,
+	.fragment	= ip6_fragment
 };
 
 static const struct nf_afinfo nf_ip6_afinfo = {
-- 
1.7.10.4
