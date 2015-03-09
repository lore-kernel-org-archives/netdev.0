From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/12] netfilter: reject: don't send icmp error if csum is invalid
Date: Mon,  9 Mar 2015 18:14:24 +0100
Message-ID: <1425921275-9171-2-git-send-email-pablo@netfilter.org>
References: <1425921275-9171-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47178 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753647AbbCIRLA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2015 13:11:00 -0400
In-Reply-To: <1425921275-9171-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

tcp resets are never emitted if the packet that triggers the
reject/reset has an invalid checksum.

For icmp error responses there was no such check.
It allows to distinguish icmp response generated via

iptables -I INPUT -p udp --dport 42 -j REJECT

and those emitted by network stack (won't respond if csum is invalid,
REJECT does).

Arguably its possible to avoid this by using conntrack and only
using REJECT with -m conntrack NEW/RELATED.

However, this doesn't work when connection tracking is not in use
or when using nf_conntrack_checksum=0.

Furthermore, sending errors in response to invalid csums doesn't make
much sense so just add similar test as in nf_send_reset.

Validate csum if needed and only send the response if it is ok.

Reference: http://bugzilla.redhat.com/show_bug.cgi?id=1169829
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/ipv4/nf_reject.h |    6 +-----
 include/net/netfilter/ipv6/nf_reject.h |   11 ++--------
 net/ipv4/netfilter/ipt_REJECT.c        |   17 ++++++++--------
 net/ipv4/netfilter/nf_reject_ipv4.c    |   23 +++++++++++++++++++++
 net/ipv4/netfilter/nft_reject_ipv4.c   |    3 ++-
 net/ipv6/netfilter/nf_reject_ipv6.c    |   35 ++++++++++++++++++++++++++++++++
 net/netfilter/nft_reject_inet.c        |    6 ++++--
 7 files changed, 76 insertions(+), 25 deletions(-)

diff --git a/include/net/netfilter/ipv4/nf_reject.h b/include/net/netfilter/ipv4/nf_reject.h
index 03e928a..8641275 100644
--- a/include/net/netfilter/ipv4/nf_reject.h
+++ b/include/net/netfilter/ipv4/nf_reject.h
@@ -5,11 +5,7 @@
 #include <net/ip.h>
 #include <net/icmp.h>
 
-static inline void nf_send_unreach(struct sk_buff *skb_in, int code)
-{
-	icmp_send(skb_in, ICMP_DEST_UNREACH, code, 0);
-}
-
+void nf_send_unreach(struct sk_buff *skb_in, int code, int hook);
 void nf_send_reset(struct sk_buff *oldskb, int hook);
 
 const struct tcphdr *nf_reject_ip_tcphdr_get(struct sk_buff *oldskb,
diff --git a/include/net/netfilter/ipv6/nf_reject.h b/include/net/netfilter/ipv6/nf_reject.h
index 23216d4..0ae445d 100644
--- a/include/net/netfilter/ipv6/nf_reject.h
+++ b/include/net/netfilter/ipv6/nf_reject.h
@@ -3,15 +3,8 @@
 
 #include <linux/icmpv6.h>
 
-static inline void
-nf_send_unreach6(struct net *net, struct sk_buff *skb_in, unsigned char code,
-	     unsigned int hooknum)
-{
-	if (hooknum == NF_INET_LOCAL_OUT && skb_in->dev == NULL)
-		skb_in->dev = net->loopback_dev;
-
-	icmpv6_send(skb_in, ICMPV6_DEST_UNREACH, code, 0);
-}
+void nf_send_unreach6(struct net *net, struct sk_buff *skb_in, unsigned char code,
+		      unsigned int hooknum);
 
 void nf_send_reset6(struct net *net, struct sk_buff *oldskb, int hook);
 
diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.c
index 8f48f55..87907d4 100644
--- a/net/ipv4/netfilter/ipt_REJECT.c
+++ b/net/ipv4/netfilter/ipt_REJECT.c
@@ -34,31 +34,32 @@ static unsigned int
 reject_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct ipt_reject_info *reject = par->targinfo;
+	int hook = par->hooknum;
 
 	switch (reject->with) {
 	case IPT_ICMP_NET_UNREACHABLE:
-		nf_send_unreach(skb, ICMP_NET_UNREACH);
+		nf_send_unreach(skb, ICMP_NET_UNREACH, hook);
 		break;
 	case IPT_ICMP_HOST_UNREACHABLE:
-		nf_send_unreach(skb, ICMP_HOST_UNREACH);
+		nf_send_unreach(skb, ICMP_HOST_UNREACH, hook);
 		break;
 	case IPT_ICMP_PROT_UNREACHABLE:
-		nf_send_unreach(skb, ICMP_PROT_UNREACH);
+		nf_send_unreach(skb, ICMP_PROT_UNREACH, hook);
 		break;
 	case IPT_ICMP_PORT_UNREACHABLE:
-		nf_send_unreach(skb, ICMP_PORT_UNREACH);
+		nf_send_unreach(skb, ICMP_PORT_UNREACH, hook);
 		break;
 	case IPT_ICMP_NET_PROHIBITED:
-		nf_send_unreach(skb, ICMP_NET_ANO);
+		nf_send_unreach(skb, ICMP_NET_ANO, hook);
 		break;
 	case IPT_ICMP_HOST_PROHIBITED:
-		nf_send_unreach(skb, ICMP_HOST_ANO);
+		nf_send_unreach(skb, ICMP_HOST_ANO, hook);
 		break;
 	case IPT_ICMP_ADMIN_PROHIBITED:
-		nf_send_unreach(skb, ICMP_PKT_FILTERED);
+		nf_send_unreach(skb, ICMP_PKT_FILTERED, hook);
 		break;
 	case IPT_TCP_RESET:
-		nf_send_reset(skb, par->hooknum);
+		nf_send_reset(skb, hook);
 	case IPT_ICMP_ECHOREPLY:
 		/* Doesn't happen. */
 		break;
diff --git a/net/ipv4/netfilter/nf_reject_ipv4.c b/net/ipv4/netfilter/nf_reject_ipv4.c
index 536da7b..b7405eb 100644
--- a/net/ipv4/netfilter/nf_reject_ipv4.c
+++ b/net/ipv4/netfilter/nf_reject_ipv4.c
@@ -164,4 +164,27 @@ void nf_send_reset(struct sk_buff *oldskb, int hook)
 }
 EXPORT_SYMBOL_GPL(nf_send_reset);
 
+void nf_send_unreach(struct sk_buff *skb_in, int code, int hook)
+{
+	struct iphdr *iph = ip_hdr(skb_in);
+	u8 proto;
+
+	if (skb_in->csum_bad || iph->frag_off & htons(IP_OFFSET))
+		return;
+
+	if (skb_csum_unnecessary(skb_in)) {
+		icmp_send(skb_in, ICMP_DEST_UNREACH, code, 0);
+		return;
+	}
+
+	if (iph->protocol == IPPROTO_TCP || iph->protocol == IPPROTO_UDP)
+		proto = iph->protocol;
+	else
+		proto = 0;
+
+	if (nf_ip_checksum(skb_in, hook, ip_hdrlen(skb_in), proto) == 0)
+		icmp_send(skb_in, ICMP_DEST_UNREACH, code, 0);
+}
+EXPORT_SYMBOL_GPL(nf_send_unreach);
+
 MODULE_LICENSE("GPL");
diff --git a/net/ipv4/netfilter/nft_reject_ipv4.c b/net/ipv4/netfilter/nft_reject_ipv4.c
index d729542..16a5d4d 100644
--- a/net/ipv4/netfilter/nft_reject_ipv4.c
+++ b/net/ipv4/netfilter/nft_reject_ipv4.c
@@ -27,7 +27,8 @@ static void nft_reject_ipv4_eval(const struct nft_expr *expr,
 
 	switch (priv->type) {
 	case NFT_REJECT_ICMP_UNREACH:
-		nf_send_unreach(pkt->skb, priv->icmp_code);
+		nf_send_unreach(pkt->skb, priv->icmp_code,
+				pkt->ops->hooknum);
 		break;
 	case NFT_REJECT_TCP_RST:
 		nf_send_reset(pkt->skb, pkt->ops->hooknum);
diff --git a/net/ipv6/netfilter/nf_reject_ipv6.c b/net/ipv6/netfilter/nf_reject_ipv6.c
index d05b364..68e0bb4 100644
--- a/net/ipv6/netfilter/nf_reject_ipv6.c
+++ b/net/ipv6/netfilter/nf_reject_ipv6.c
@@ -208,4 +208,39 @@ void nf_send_reset6(struct net *net, struct sk_buff *oldskb, int hook)
 }
 EXPORT_SYMBOL_GPL(nf_send_reset6);
 
+static bool reject6_csum_ok(struct sk_buff *skb, int hook)
+{
+	const struct ipv6hdr *ip6h = ipv6_hdr(skb);
+	int thoff;
+	__be16 fo;
+	u8 proto;
+
+	if (skb->csum_bad)
+		return false;
+
+	if (skb_csum_unnecessary(skb))
+		return true;
+
+	proto = ip6h->nexthdr;
+	thoff = ipv6_skip_exthdr(skb, ((u8*)(ip6h+1) - skb->data), &proto, &fo);
+
+	if (thoff < 0 || thoff >= skb->len || (fo & htons(~0x7)) != 0)
+		return false;
+
+	return nf_ip6_checksum(skb, hook, thoff, proto) == 0;
+}
+
+void nf_send_unreach6(struct net *net, struct sk_buff *skb_in,
+		      unsigned char code, unsigned int hooknum)
+{
+	if (!reject6_csum_ok(skb_in, hooknum))
+		return;
+
+	if (hooknum == NF_INET_LOCAL_OUT && skb_in->dev == NULL)
+		skb_in->dev = net->loopback_dev;
+
+	icmpv6_send(skb_in, ICMPV6_DEST_UNREACH, code, 0);
+}
+EXPORT_SYMBOL_GPL(nf_send_unreach6);
+
 MODULE_LICENSE("GPL");
diff --git a/net/netfilter/nft_reject_inet.c b/net/netfilter/nft_reject_inet.c
index 7b5f9d5..9287711 100644
--- a/net/netfilter/nft_reject_inet.c
+++ b/net/netfilter/nft_reject_inet.c
@@ -28,14 +28,16 @@ static void nft_reject_inet_eval(const struct nft_expr *expr,
 	case NFPROTO_IPV4:
 		switch (priv->type) {
 		case NFT_REJECT_ICMP_UNREACH:
-			nf_send_unreach(pkt->skb, priv->icmp_code);
+			nf_send_unreach(pkt->skb, priv->icmp_code,
+					pkt->ops->hooknum);
 			break;
 		case NFT_REJECT_TCP_RST:
 			nf_send_reset(pkt->skb, pkt->ops->hooknum);
 			break;
 		case NFT_REJECT_ICMPX_UNREACH:
 			nf_send_unreach(pkt->skb,
-					nft_reject_icmp_code(priv->icmp_code));
+					nft_reject_icmp_code(priv->icmp_code),
+					pkt->ops->hooknum);
 			break;
 		}
 		break;
-- 
1.7.10.4
