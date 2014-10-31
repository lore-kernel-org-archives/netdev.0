From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/6] netfilter: nf_reject_ipv6: split nf_send_reset6() in smaller functions
Date: Fri, 31 Oct 2014 13:18:30 +0100
Message-ID: <1414757912-29150-5-git-send-email-pablo@netfilter.org>
References: <1414757912-29150-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48104 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759318AbaJaMRS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2014 08:17:18 -0400
In-Reply-To: <1414757912-29150-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

That can be reused by the reject bridge expression to build the reject
packet. The new functions are:

* nf_reject_ip6_tcphdr_get(): to sanitize and to obtain the TCP header.
* nf_reject_ip6hdr_put(): to build the IPv6 header.
* nf_reject_ip6_tcphdr_put(): to build the TCP header.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/ipv6/nf_reject.h |   10 ++
 net/ipv6/netfilter/nf_reject_ipv6.c    |  175 ++++++++++++++++++++------------
 2 files changed, 119 insertions(+), 66 deletions(-)

diff --git a/include/net/netfilter/ipv6/nf_reject.h b/include/net/netfilter/ipv6/nf_reject.h
index 48e1881..23216d4 100644
--- a/include/net/netfilter/ipv6/nf_reject.h
+++ b/include/net/netfilter/ipv6/nf_reject.h
@@ -15,4 +15,14 @@ nf_send_unreach6(struct net *net, struct sk_buff *skb_in, unsigned char code,
 
 void nf_send_reset6(struct net *net, struct sk_buff *oldskb, int hook);
 
+const struct tcphdr *nf_reject_ip6_tcphdr_get(struct sk_buff *oldskb,
+					      struct tcphdr *otcph,
+					      unsigned int *otcplen, int hook);
+struct ipv6hdr *nf_reject_ip6hdr_put(struct sk_buff *nskb,
+				     const struct sk_buff *oldskb,
+				     __be16 protocol, int hoplimit);
+void nf_reject_ip6_tcphdr_put(struct sk_buff *nskb,
+			      const struct sk_buff *oldskb,
+			      const struct tcphdr *oth, unsigned int otcplen);
+
 #endif /* _IPV6_NF_REJECT_H */
diff --git a/net/ipv6/netfilter/nf_reject_ipv6.c b/net/ipv6/netfilter/nf_reject_ipv6.c
index 20d9def..015eb8a 100644
--- a/net/ipv6/netfilter/nf_reject_ipv6.c
+++ b/net/ipv6/netfilter/nf_reject_ipv6.c
@@ -12,116 +12,102 @@
 #include <net/ip6_fib.h>
 #include <net/ip6_checksum.h>
 #include <linux/netfilter_ipv6.h>
+#include <net/netfilter/ipv6/nf_reject.h>
 
-void nf_send_reset6(struct net *net, struct sk_buff *oldskb, int hook)
+const struct tcphdr *nf_reject_ip6_tcphdr_get(struct sk_buff *oldskb,
+					      struct tcphdr *otcph,
+					      unsigned int *otcplen, int hook)
 {
-	struct sk_buff *nskb;
-	struct tcphdr otcph, *tcph;
-	unsigned int otcplen, hh_len;
-	int tcphoff, needs_ack;
 	const struct ipv6hdr *oip6h = ipv6_hdr(oldskb);
-	struct ipv6hdr *ip6h;
-#define DEFAULT_TOS_VALUE	0x0U
-	const __u8 tclass = DEFAULT_TOS_VALUE;
-	struct dst_entry *dst = NULL;
 	u8 proto;
 	__be16 frag_off;
-	struct flowi6 fl6;
-
-	if ((!(ipv6_addr_type(&oip6h->saddr) & IPV6_ADDR_UNICAST)) ||
-	    (!(ipv6_addr_type(&oip6h->daddr) & IPV6_ADDR_UNICAST))) {
-		pr_debug("addr is not unicast.\n");
-		return;
-	}
+	int tcphoff;
 
 	proto = oip6h->nexthdr;
-	tcphoff = ipv6_skip_exthdr(oldskb, ((u8*)(oip6h+1) - oldskb->data), &proto, &frag_off);
+	tcphoff = ipv6_skip_exthdr(oldskb, ((u8*)(oip6h+1) - oldskb->data),
+				   &proto, &frag_off);
 
 	if ((tcphoff < 0) || (tcphoff > oldskb->len)) {
 		pr_debug("Cannot get TCP header.\n");
-		return;
+		return NULL;
 	}
 
-	otcplen = oldskb->len - tcphoff;
+	*otcplen = oldskb->len - tcphoff;
 
 	/* IP header checks: fragment, too short. */
-	if (proto != IPPROTO_TCP || otcplen < sizeof(struct tcphdr)) {
-		pr_debug("proto(%d) != IPPROTO_TCP, "
-			 "or too short. otcplen = %d\n",
-			 proto, otcplen);
-		return;
+	if (proto != IPPROTO_TCP || *otcplen < sizeof(struct tcphdr)) {
+		pr_debug("proto(%d) != IPPROTO_TCP or too short (len = %d)\n",
+			 proto, *otcplen);
+		return NULL;
 	}
 
-	if (skb_copy_bits(oldskb, tcphoff, &otcph, sizeof(struct tcphdr)))
-		BUG();
+	otcph = skb_header_pointer(oldskb, tcphoff, sizeof(struct tcphdr),
+				   otcph);
+	if (otcph == NULL)
+		return NULL;
 
 	/* No RST for RST. */
-	if (otcph.rst) {
+	if (otcph->rst) {
 		pr_debug("RST is set\n");
-		return;
+		return NULL;
 	}
 
 	/* Check checksum. */
 	if (nf_ip6_checksum(oldskb, hook, tcphoff, IPPROTO_TCP)) {
 		pr_debug("TCP checksum is invalid\n");
-		return;
-	}
-
-	memset(&fl6, 0, sizeof(fl6));
-	fl6.flowi6_proto = IPPROTO_TCP;
-	fl6.saddr = oip6h->daddr;
-	fl6.daddr = oip6h->saddr;
-	fl6.fl6_sport = otcph.dest;
-	fl6.fl6_dport = otcph.source;
-	security_skb_classify_flow(oldskb, flowi6_to_flowi(&fl6));
-	dst = ip6_route_output(net, NULL, &fl6);
-	if (dst == NULL || dst->error) {
-		dst_release(dst);
-		return;
-	}
-	dst = xfrm_lookup(net, dst, flowi6_to_flowi(&fl6), NULL, 0);
-	if (IS_ERR(dst))
-		return;
-
-	hh_len = (dst->dev->hard_header_len + 15)&~15;
-	nskb = alloc_skb(hh_len + 15 + dst->header_len + sizeof(struct ipv6hdr)
-			 + sizeof(struct tcphdr) + dst->trailer_len,
-			 GFP_ATOMIC);
-
-	if (!nskb) {
-		net_dbg_ratelimited("cannot alloc skb\n");
-		dst_release(dst);
-		return;
+		return NULL;
 	}
 
-	skb_dst_set(nskb, dst);
+	return otcph;
+}
+EXPORT_SYMBOL_GPL(nf_reject_ip6_tcphdr_get);
 
-	skb_reserve(nskb, hh_len + dst->header_len);
+struct ipv6hdr *nf_reject_ip6hdr_put(struct sk_buff *nskb,
+				     const struct sk_buff *oldskb,
+				     __be16 protocol, int hoplimit)
+{
+	struct ipv6hdr *ip6h;
+	const struct ipv6hdr *oip6h = ipv6_hdr(oldskb);
+#define DEFAULT_TOS_VALUE	0x0U
+	const __u8 tclass = DEFAULT_TOS_VALUE;
 
 	skb_put(nskb, sizeof(struct ipv6hdr));
 	skb_reset_network_header(nskb);
 	ip6h = ipv6_hdr(nskb);
 	ip6_flow_hdr(ip6h, tclass, 0);
-	ip6h->hop_limit = ip6_dst_hoplimit(dst);
-	ip6h->nexthdr = IPPROTO_TCP;
+	ip6h->hop_limit = hoplimit;
+	ip6h->nexthdr = protocol;
 	ip6h->saddr = oip6h->daddr;
 	ip6h->daddr = oip6h->saddr;
 
+	nskb->protocol = htons(ETH_P_IPV6);
+
+	return ip6h;
+}
+EXPORT_SYMBOL_GPL(nf_reject_ip6hdr_put);
+
+void nf_reject_ip6_tcphdr_put(struct sk_buff *nskb,
+			      const struct sk_buff *oldskb,
+			      const struct tcphdr *oth, unsigned int otcplen)
+{
+	struct tcphdr *tcph;
+	int needs_ack;
+
 	skb_reset_transport_header(nskb);
 	tcph = (struct tcphdr *)skb_put(nskb, sizeof(struct tcphdr));
 	/* Truncate to length (no data) */
 	tcph->doff = sizeof(struct tcphdr)/4;
-	tcph->source = otcph.dest;
-	tcph->dest = otcph.source;
+	tcph->source = oth->dest;
+	tcph->dest = oth->source;
 
-	if (otcph.ack) {
+	if (oth->ack) {
 		needs_ack = 0;
-		tcph->seq = otcph.ack_seq;
+		tcph->seq = oth->ack_seq;
 		tcph->ack_seq = 0;
 	} else {
 		needs_ack = 1;
-		tcph->ack_seq = htonl(ntohl(otcph.seq) + otcph.syn + otcph.fin
-				      + otcplen - (otcph.doff<<2));
+		tcph->ack_seq = htonl(ntohl(oth->seq) + oth->syn + oth->fin +
+				      otcplen - (oth->doff<<2));
 		tcph->seq = 0;
 	}
 
@@ -139,6 +125,63 @@ void nf_send_reset6(struct net *net, struct sk_buff *oldskb, int hook)
 				      sizeof(struct tcphdr), IPPROTO_TCP,
 				      csum_partial(tcph,
 						   sizeof(struct tcphdr), 0));
+}
+EXPORT_SYMBOL_GPL(nf_reject_ip6_tcphdr_put);
+
+void nf_send_reset6(struct net *net, struct sk_buff *oldskb, int hook)
+{
+	struct sk_buff *nskb;
+	struct tcphdr _otcph;
+	const struct tcphdr *otcph;
+	unsigned int otcplen, hh_len;
+	const struct ipv6hdr *oip6h = ipv6_hdr(oldskb);
+	struct ipv6hdr *ip6h;
+	struct dst_entry *dst = NULL;
+	struct flowi6 fl6;
+
+	if ((!(ipv6_addr_type(&oip6h->saddr) & IPV6_ADDR_UNICAST)) ||
+	    (!(ipv6_addr_type(&oip6h->daddr) & IPV6_ADDR_UNICAST))) {
+		pr_debug("addr is not unicast.\n");
+		return;
+	}
+
+	otcph = nf_reject_ip6_tcphdr_get(oldskb, &_otcph, &otcplen, hook);
+	if (!otcph)
+		return;
+
+	memset(&fl6, 0, sizeof(fl6));
+	fl6.flowi6_proto = IPPROTO_TCP;
+	fl6.saddr = oip6h->daddr;
+	fl6.daddr = oip6h->saddr;
+	fl6.fl6_sport = otcph->dest;
+	fl6.fl6_dport = otcph->source;
+	security_skb_classify_flow(oldskb, flowi6_to_flowi(&fl6));
+	dst = ip6_route_output(net, NULL, &fl6);
+	if (dst == NULL || dst->error) {
+		dst_release(dst);
+		return;
+	}
+	dst = xfrm_lookup(net, dst, flowi6_to_flowi(&fl6), NULL, 0);
+	if (IS_ERR(dst))
+		return;
+
+	hh_len = (dst->dev->hard_header_len + 15)&~15;
+	nskb = alloc_skb(hh_len + 15 + dst->header_len + sizeof(struct ipv6hdr)
+			 + sizeof(struct tcphdr) + dst->trailer_len,
+			 GFP_ATOMIC);
+
+	if (!nskb) {
+		net_dbg_ratelimited("cannot alloc skb\n");
+		dst_release(dst);
+		return;
+	}
+
+	skb_dst_set(nskb, dst);
+
+	skb_reserve(nskb, hh_len + dst->header_len);
+	ip6h = nf_reject_ip6hdr_put(nskb, oldskb, IPPROTO_TCP,
+				    ip6_dst_hoplimit(dst));
+	nf_reject_ip6_tcphdr_put(nskb, oldskb, otcph, otcplen);
 
 	nf_ct_attach(nskb, oldskb);
 
-- 
1.7.10.4
