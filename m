From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/6] netfilter: nf_reject_ipv4: split nf_send_reset() in smaller functions
Date: Fri, 31 Oct 2014 13:18:29 +0100
Message-ID: <1414757912-29150-4-git-send-email-pablo@netfilter.org>
References: <1414757912-29150-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48011 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759307AbaJaMRJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2014 08:17:09 -0400
In-Reply-To: <1414757912-29150-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

That can be reused by the reject bridge expression to build the reject
packet. The new functions are:

* nf_reject_ip_tcphdr_get(): to sanitize and to obtain the TCP header.
* nf_reject_iphdr_put(): to build the IPv4 header.
* nf_reject_ip_tcphdr_put(): to build the TCP header.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/ipv4/nf_reject.h |   10 ++++
 net/ipv4/netfilter/nf_reject_ipv4.c    |   88 ++++++++++++++++++++++----------
 2 files changed, 72 insertions(+), 26 deletions(-)

diff --git a/include/net/netfilter/ipv4/nf_reject.h b/include/net/netfilter/ipv4/nf_reject.h
index e842719..03e928a 100644
--- a/include/net/netfilter/ipv4/nf_reject.h
+++ b/include/net/netfilter/ipv4/nf_reject.h
@@ -1,6 +1,8 @@
 #ifndef _IPV4_NF_REJECT_H
 #define _IPV4_NF_REJECT_H
 
+#include <linux/skbuff.h>
+#include <net/ip.h>
 #include <net/icmp.h>
 
 static inline void nf_send_unreach(struct sk_buff *skb_in, int code)
@@ -10,4 +12,12 @@ static inline void nf_send_unreach(struct sk_buff *skb_in, int code)
 
 void nf_send_reset(struct sk_buff *oldskb, int hook);
 
+const struct tcphdr *nf_reject_ip_tcphdr_get(struct sk_buff *oldskb,
+					     struct tcphdr *_oth, int hook);
+struct iphdr *nf_reject_iphdr_put(struct sk_buff *nskb,
+				  const struct sk_buff *oldskb,
+				  __be16 protocol, int ttl);
+void nf_reject_ip_tcphdr_put(struct sk_buff *nskb, const struct sk_buff *oldskb,
+			     const struct tcphdr *oth);
+
 #endif /* _IPV4_NF_REJECT_H */
diff --git a/net/ipv4/netfilter/nf_reject_ipv4.c b/net/ipv4/netfilter/nf_reject_ipv4.c
index 92b303d..1baaa83 100644
--- a/net/ipv4/netfilter/nf_reject_ipv4.c
+++ b/net/ipv4/netfilter/nf_reject_ipv4.c
@@ -12,43 +12,39 @@
 #include <net/route.h>
 #include <net/dst.h>
 #include <linux/netfilter_ipv4.h>
+#include <net/netfilter/ipv4/nf_reject.h>
 
-/* Send RST reply */
-void nf_send_reset(struct sk_buff *oldskb, int hook)
+const struct tcphdr *nf_reject_ip_tcphdr_get(struct sk_buff *oldskb,
+					     struct tcphdr *_oth, int hook)
 {
-	struct sk_buff *nskb;
-	const struct iphdr *oiph;
-	struct iphdr *niph;
 	const struct tcphdr *oth;
-	struct tcphdr _otcph, *tcph;
 
 	/* IP header checks: fragment. */
 	if (ip_hdr(oldskb)->frag_off & htons(IP_OFFSET))
-		return;
+		return NULL;
 
 	oth = skb_header_pointer(oldskb, ip_hdrlen(oldskb),
-				 sizeof(_otcph), &_otcph);
+				 sizeof(struct tcphdr), _oth);
 	if (oth == NULL)
-		return;
+		return NULL;
 
 	/* No RST for RST. */
 	if (oth->rst)
-		return;
-
-	if (skb_rtable(oldskb)->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST))
-		return;
+		return NULL;
 
 	/* Check checksum */
 	if (nf_ip_checksum(oldskb, hook, ip_hdrlen(oldskb), IPPROTO_TCP))
-		return;
-	oiph = ip_hdr(oldskb);
+		return NULL;
 
-	nskb = alloc_skb(sizeof(struct iphdr) + sizeof(struct tcphdr) +
-			 LL_MAX_HEADER, GFP_ATOMIC);
-	if (!nskb)
-		return;
+	return oth;
+}
+EXPORT_SYMBOL_GPL(nf_reject_ip_tcphdr_get);
 
-	skb_reserve(nskb, LL_MAX_HEADER);
+struct iphdr *nf_reject_iphdr_put(struct sk_buff *nskb,
+				  const struct sk_buff *oldskb,
+				  __be16 protocol, int ttl)
+{
+	struct iphdr *niph, *oiph = ip_hdr(oldskb);
 
 	skb_reset_network_header(nskb);
 	niph = (struct iphdr *)skb_put(nskb, sizeof(struct iphdr));
@@ -57,10 +53,23 @@ void nf_send_reset(struct sk_buff *oldskb, int hook)
 	niph->tos	= 0;
 	niph->id	= 0;
 	niph->frag_off	= htons(IP_DF);
-	niph->protocol	= IPPROTO_TCP;
+	niph->protocol	= protocol;
 	niph->check	= 0;
 	niph->saddr	= oiph->daddr;
 	niph->daddr	= oiph->saddr;
+	niph->ttl	= ttl;
+
+	nskb->protocol = htons(ETH_P_IP);
+
+	return niph;
+}
+EXPORT_SYMBOL_GPL(nf_reject_iphdr_put);
+
+void nf_reject_ip_tcphdr_put(struct sk_buff *nskb, const struct sk_buff *oldskb,
+			  const struct tcphdr *oth)
+{
+	struct iphdr *niph = ip_hdr(nskb);
+	struct tcphdr *tcph;
 
 	skb_reset_transport_header(nskb);
 	tcph = (struct tcphdr *)skb_put(nskb, sizeof(struct tcphdr));
@@ -69,9 +78,9 @@ void nf_send_reset(struct sk_buff *oldskb, int hook)
 	tcph->dest	= oth->source;
 	tcph->doff	= sizeof(struct tcphdr) / 4;
 
-	if (oth->ack)
+	if (oth->ack) {
 		tcph->seq = oth->ack_seq;
-	else {
+	} else {
 		tcph->ack_seq = htonl(ntohl(oth->seq) + oth->syn + oth->fin +
 				      oldskb->len - ip_hdrlen(oldskb) -
 				      (oth->doff << 2));
@@ -84,16 +93,43 @@ void nf_send_reset(struct sk_buff *oldskb, int hook)
 	nskb->ip_summed = CHECKSUM_PARTIAL;
 	nskb->csum_start = (unsigned char *)tcph - nskb->head;
 	nskb->csum_offset = offsetof(struct tcphdr, check);
+}
+EXPORT_SYMBOL_GPL(nf_reject_ip_tcphdr_put);
+
+/* Send RST reply */
+void nf_send_reset(struct sk_buff *oldskb, int hook)
+{
+	struct sk_buff *nskb;
+	const struct iphdr *oiph;
+	struct iphdr *niph;
+	const struct tcphdr *oth;
+	struct tcphdr _oth;
+
+	oth = nf_reject_ip_tcphdr_get(oldskb, &_oth, hook);
+	if (!oth)
+		return;
+
+	if (skb_rtable(oldskb)->rt_flags & (RTCF_BROADCAST | RTCF_MULTICAST))
+		return;
+
+	oiph = ip_hdr(oldskb);
+
+	nskb = alloc_skb(sizeof(struct iphdr) + sizeof(struct tcphdr) +
+			 LL_MAX_HEADER, GFP_ATOMIC);
+	if (!nskb)
+		return;
 
 	/* ip_route_me_harder expects skb->dst to be set */
 	skb_dst_set_noref(nskb, skb_dst(oldskb));
 
-	nskb->protocol = htons(ETH_P_IP);
+	skb_reserve(nskb, LL_MAX_HEADER);
+	niph = nf_reject_iphdr_put(nskb, oldskb, IPPROTO_TCP,
+				   ip4_dst_hoplimit(skb_dst(nskb)));
+	nf_reject_ip_tcphdr_put(nskb, oldskb, oth);
+
 	if (ip_route_me_harder(nskb, RTN_UNSPEC))
 		goto free_nskb;
 
-	niph->ttl	= ip4_dst_hoplimit(skb_dst(nskb));
-
 	/* "Never happens" */
 	if (nskb->len > dst_mtu(skb_dst(nskb)))
 		goto free_nskb;
-- 
1.7.10.4
