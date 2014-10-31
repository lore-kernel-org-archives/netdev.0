From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/6] netfilter: nft_reject_bridge: don't use IP stack to reject traffic
Date: Fri, 31 Oct 2014 13:18:31 +0100
Message-ID: <1414757912-29150-6-git-send-email-pablo@netfilter.org>
References: <1414757912-29150-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48031 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758202AbaJaMRK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2014 08:17:10 -0400
In-Reply-To: <1414757912-29150-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the packet is received via the bridge stack, this cannot reject
packets from the IP stack.

This adds functions to build the reject packet and send it from the
bridge stack. Comments and assumptions on this patch:

1) Validate the IPv4 and IPv6 headers before further processing,
   given that the packet comes from the bridge stack, we cannot assume
   they are clean. Truncated packets are dropped, we follow similar
   approach in the existing iptables match/target extensions that need
   to inspect layer 4 headers that is not available. This also includes
   packets that are directed to multicast and broadcast ethernet
   addresses.

2) br_deliver() is exported to inject the reject packet via
   bridge localout -> postrouting. So the approach is similar to what
   we already do in the iptables reject target. The reject packet is
   sent to the bridge port from which we have received the original
   packet.

3) The reject packet is forged based on the original packet. The TTL
   is set based on sysctl_ip_default_ttl for IPv4 and per-net
   ipv6.devconf_all hoplimit for IPv6.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/br_forward.c                  |    1 +
 net/bridge/netfilter/nft_reject_bridge.c |  263 ++++++++++++++++++++++++++++--
 2 files changed, 254 insertions(+), 10 deletions(-)

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 992ec49..44cb786 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -112,6 +112,7 @@ void br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 
 	kfree_skb(skb);
 }
+EXPORT_SYMBOL_GPL(br_deliver);
 
 /* called with rcu_read_lock */
 void br_forward(const struct net_bridge_port *to, struct sk_buff *skb, struct sk_buff *skb0)
diff --git a/net/bridge/netfilter/nft_reject_bridge.c b/net/bridge/netfilter/nft_reject_bridge.c
index a764795..31b27e1 100644
--- a/net/bridge/netfilter/nft_reject_bridge.c
+++ b/net/bridge/netfilter/nft_reject_bridge.c
@@ -16,6 +16,237 @@
 #include <net/netfilter/nft_reject.h>
 #include <net/netfilter/ipv4/nf_reject.h>
 #include <net/netfilter/ipv6/nf_reject.h>
+#include <linux/ip.h>
+#include <net/ip.h>
+#include "../br_private.h"
+
+static void nft_reject_br_push_etherhdr(struct sk_buff *oldskb,
+					struct sk_buff *nskb)
+{
+	struct ethhdr *eth;
+
+	eth = (struct ethhdr *)skb_push(nskb, ETH_HLEN);
+	skb_reset_mac_header(nskb);
+	ether_addr_copy(eth->h_source, eth_hdr(oldskb)->h_dest);
+	ether_addr_copy(eth->h_dest, eth_hdr(oldskb)->h_source);
+	eth->h_proto = eth_hdr(oldskb)->h_proto;
+	skb_pull(nskb, ETH_HLEN);
+}
+
+static int nft_reject_iphdr_validate(struct sk_buff *oldskb)
+{
+	struct iphdr *iph;
+	u32 len;
+
+	if (!pskb_may_pull(oldskb, sizeof(struct iphdr)))
+		return 0;
+
+	iph = ip_hdr(oldskb);
+	if (iph->ihl < 5 || iph->version != 4)
+		return 0;
+
+	len = ntohs(iph->tot_len);
+	if (oldskb->len < len)
+		return 0;
+	else if (len < (iph->ihl*4))
+		return 0;
+
+	if (!pskb_may_pull(oldskb, iph->ihl*4))
+		return 0;
+
+	return 1;
+}
+
+static void nft_reject_br_send_v4_tcp_reset(struct sk_buff *oldskb, int hook)
+{
+	struct sk_buff *nskb;
+	struct iphdr *niph;
+	const struct tcphdr *oth;
+	struct tcphdr _oth;
+
+	if (!nft_reject_iphdr_validate(oldskb))
+		return;
+
+	oth = nf_reject_ip_tcphdr_get(oldskb, &_oth, hook);
+	if (!oth)
+		return;
+
+	nskb = alloc_skb(sizeof(struct iphdr) + sizeof(struct tcphdr) +
+			 LL_MAX_HEADER, GFP_ATOMIC);
+	if (!nskb)
+		return;
+
+	skb_reserve(nskb, LL_MAX_HEADER);
+	niph = nf_reject_iphdr_put(nskb, oldskb, IPPROTO_TCP,
+				   sysctl_ip_default_ttl);
+	nf_reject_ip_tcphdr_put(nskb, oldskb, oth);
+	niph->ttl	= sysctl_ip_default_ttl;
+	niph->tot_len	= htons(nskb->len);
+	ip_send_check(niph);
+
+	nft_reject_br_push_etherhdr(oldskb, nskb);
+
+	br_deliver(br_port_get_rcu(oldskb->dev), nskb);
+}
+
+static void nft_reject_br_send_v4_unreach(struct sk_buff *oldskb, int hook,
+					  u8 code)
+{
+	struct sk_buff *nskb;
+	struct iphdr *niph;
+	struct icmphdr *icmph;
+	unsigned int len;
+	void *payload;
+	__wsum csum;
+
+	if (!nft_reject_iphdr_validate(oldskb))
+		return;
+
+	/* IP header checks: fragment. */
+	if (ip_hdr(oldskb)->frag_off & htons(IP_OFFSET))
+		return;
+
+	/* RFC says return as much as we can without exceeding 576 bytes. */
+	len = min_t(unsigned int, 536, oldskb->len);
+
+	if (!pskb_may_pull(oldskb, len))
+		return;
+
+	if (nf_ip_checksum(oldskb, hook, ip_hdrlen(oldskb), 0))
+		return;
+
+	nskb = alloc_skb(sizeof(struct iphdr) + sizeof(struct icmphdr) +
+			 LL_MAX_HEADER + len, GFP_ATOMIC);
+	if (!nskb)
+		return;
+
+	skb_reserve(nskb, LL_MAX_HEADER);
+	niph = nf_reject_iphdr_put(nskb, oldskb, IPPROTO_ICMP,
+				   sysctl_ip_default_ttl);
+
+	skb_reset_transport_header(nskb);
+	icmph = (struct icmphdr *)skb_put(nskb, sizeof(struct icmphdr));
+	memset(icmph, 0, sizeof(*icmph));
+	icmph->type     = ICMP_DEST_UNREACH;
+	icmph->code	= code;
+
+	payload = skb_put(nskb, len);
+	memcpy(payload, skb_network_header(oldskb), len);
+
+	csum = csum_partial((void *)icmph, len + sizeof(struct icmphdr), 0);
+	icmph->checksum = csum_fold(csum);
+
+	niph->tot_len	= htons(nskb->len);
+	ip_send_check(niph);
+
+	nft_reject_br_push_etherhdr(oldskb, nskb);
+
+	br_deliver(br_port_get_rcu(oldskb->dev), nskb);
+}
+
+static int nft_reject_ip6hdr_validate(struct sk_buff *oldskb)
+{
+	struct ipv6hdr *hdr;
+	u32 pkt_len;
+
+	if (!pskb_may_pull(oldskb, sizeof(struct ipv6hdr)))
+		return 0;
+
+	hdr = ipv6_hdr(oldskb);
+	if (hdr->version != 6)
+		return 0;
+
+	pkt_len = ntohs(hdr->payload_len);
+	if (pkt_len + sizeof(struct ipv6hdr) > oldskb->len)
+		return 0;
+
+	return 1;
+}
+
+static void nft_reject_br_send_v6_tcp_reset(struct net *net,
+					    struct sk_buff *oldskb, int hook)
+{
+	struct sk_buff *nskb;
+	const struct tcphdr *oth;
+	struct tcphdr _oth;
+	unsigned int otcplen;
+	struct ipv6hdr *nip6h;
+
+	if (!nft_reject_ip6hdr_validate(oldskb))
+		return;
+
+	oth = nf_reject_ip6_tcphdr_get(oldskb, &_oth, &otcplen, hook);
+	if (!oth)
+		return;
+
+	nskb = alloc_skb(sizeof(struct ipv6hdr) + sizeof(struct tcphdr) +
+			 LL_MAX_HEADER, GFP_ATOMIC);
+	if (!nskb)
+		return;
+
+	skb_reserve(nskb, LL_MAX_HEADER);
+	nip6h = nf_reject_ip6hdr_put(nskb, oldskb, IPPROTO_TCP,
+				     net->ipv6.devconf_all->hop_limit);
+	nf_reject_ip6_tcphdr_put(nskb, oldskb, oth, otcplen);
+	nip6h->payload_len = htons(nskb->len - sizeof(struct ipv6hdr));
+
+	nft_reject_br_push_etherhdr(oldskb, nskb);
+
+	br_deliver(br_port_get_rcu(oldskb->dev), nskb);
+}
+
+static void nft_reject_br_send_v6_unreach(struct net *net,
+					  struct sk_buff *oldskb, int hook,
+					  u8 code)
+{
+	struct sk_buff *nskb;
+	struct ipv6hdr *nip6h;
+	struct icmp6hdr *icmp6h;
+	unsigned int len;
+	void *payload;
+
+	if (!nft_reject_ip6hdr_validate(oldskb))
+		return;
+
+	/* Include "As much of invoking packet as possible without the ICMPv6
+	 * packet exceeding the minimum IPv6 MTU" in the ICMP payload.
+	 */
+	len = min_t(unsigned int, 1220, oldskb->len);
+
+	if (!pskb_may_pull(oldskb, len))
+		return;
+
+	nskb = alloc_skb(sizeof(struct iphdr) + sizeof(struct icmp6hdr) +
+			 LL_MAX_HEADER + len, GFP_ATOMIC);
+	if (!nskb)
+		return;
+
+	skb_reserve(nskb, LL_MAX_HEADER);
+	nip6h = nf_reject_ip6hdr_put(nskb, oldskb, IPPROTO_ICMPV6,
+				     net->ipv6.devconf_all->hop_limit);
+
+	skb_reset_transport_header(nskb);
+	icmp6h = (struct icmp6hdr *)skb_put(nskb, sizeof(struct icmp6hdr));
+	memset(icmp6h, 0, sizeof(*icmp6h));
+	icmp6h->icmp6_type = ICMPV6_DEST_UNREACH;
+	icmp6h->icmp6_code = code;
+
+	payload = skb_put(nskb, len);
+	memcpy(payload, skb_network_header(oldskb), len);
+	nip6h->payload_len = htons(nskb->len - sizeof(struct ipv6hdr));
+
+	icmp6h->icmp6_cksum =
+		csum_ipv6_magic(&nip6h->saddr, &nip6h->daddr,
+				nskb->len - sizeof(struct ipv6hdr),
+				IPPROTO_ICMPV6,
+				csum_partial(icmp6h,
+					     nskb->len - sizeof(struct ipv6hdr),
+					     0));
+
+	nft_reject_br_push_etherhdr(oldskb, nskb);
+
+	br_deliver(br_port_get_rcu(oldskb->dev), nskb);
+}
 
 static void nft_reject_bridge_eval(const struct nft_expr *expr,
 				 struct nft_data data[NFT_REG_MAX + 1],
@@ -23,35 +254,46 @@ static void nft_reject_bridge_eval(const struct nft_expr *expr,
 {
 	struct nft_reject *priv = nft_expr_priv(expr);
 	struct net *net = dev_net((pkt->in != NULL) ? pkt->in : pkt->out);
+	const unsigned char *dest = eth_hdr(pkt->skb)->h_dest;
+
+	if (is_broadcast_ether_addr(dest) ||
+	    is_multicast_ether_addr(dest))
+		goto out;
 
 	switch (eth_hdr(pkt->skb)->h_proto) {
 	case htons(ETH_P_IP):
 		switch (priv->type) {
 		case NFT_REJECT_ICMP_UNREACH:
-			nf_send_unreach(pkt->skb, priv->icmp_code);
+			nft_reject_br_send_v4_unreach(pkt->skb,
+						      pkt->ops->hooknum,
+						      priv->icmp_code);
 			break;
 		case NFT_REJECT_TCP_RST:
-			nf_send_reset(pkt->skb, pkt->ops->hooknum);
+			nft_reject_br_send_v4_tcp_reset(pkt->skb,
+							pkt->ops->hooknum);
 			break;
 		case NFT_REJECT_ICMPX_UNREACH:
-			nf_send_unreach(pkt->skb,
-					nft_reject_icmp_code(priv->icmp_code));
+			nft_reject_br_send_v4_unreach(pkt->skb,
+						      pkt->ops->hooknum,
+						      nft_reject_icmp_code(priv->icmp_code));
 			break;
 		}
 		break;
 	case htons(ETH_P_IPV6):
 		switch (priv->type) {
 		case NFT_REJECT_ICMP_UNREACH:
-			nf_send_unreach6(net, pkt->skb, priv->icmp_code,
-					 pkt->ops->hooknum);
+			nft_reject_br_send_v6_unreach(net, pkt->skb,
+						      pkt->ops->hooknum,
+						      priv->icmp_code);
 			break;
 		case NFT_REJECT_TCP_RST:
-			nf_send_reset6(net, pkt->skb, pkt->ops->hooknum);
+			nft_reject_br_send_v6_tcp_reset(net, pkt->skb,
+							pkt->ops->hooknum);
 			break;
 		case NFT_REJECT_ICMPX_UNREACH:
-			nf_send_unreach6(net, pkt->skb,
-					 nft_reject_icmpv6_code(priv->icmp_code),
-					 pkt->ops->hooknum);
+			nft_reject_br_send_v6_unreach(net, pkt->skb,
+						      pkt->ops->hooknum,
+						      nft_reject_icmpv6_code(priv->icmp_code));
 			break;
 		}
 		break;
@@ -59,6 +301,7 @@ static void nft_reject_bridge_eval(const struct nft_expr *expr,
 		/* No explicit way to reject this protocol, drop it. */
 		break;
 	}
+out:
 	data[NFT_REG_VERDICT].verdict = NF_DROP;
 }
 
-- 
1.7.10.4
