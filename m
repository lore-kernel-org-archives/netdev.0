From: Florian Westphal <fw@strlen.de>
Subject: [PATCH RFC 03/14] ipv6: use flag instead of u16 for hop in inet6_skb_parm
Date: Mon,  2 Mar 2015 18:40:17 +0100
Message-ID: <1425318028-26531-4-git-send-email-fw@strlen.de>
References: <1425318028-26531-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:54106 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754540AbbCBRkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 12:40:41 -0500
In-Reply-To: <1425318028-26531-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

reduces size by 2 bytes.  hop was always either 0 or sizeof(struct ipv6hdr).

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/ipv6.h | 2 +-
 net/ipv6/af_inet6.c  | 4 ++--
 net/ipv6/datagram.c  | 8 ++++----
 net/ipv6/exthdrs.c   | 2 +-
 4 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 4d5169f..61b9169 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -90,7 +90,6 @@ static inline struct ipv6hdr *ipipv6_hdr(const struct sk_buff *skb)
 struct inet6_skb_parm {
 	int			iif;
 	__be16			ra;
-	__u16			hop;
 	__u16			dst0;
 	__u16			srcrt;
 	__u16			dst1;
@@ -107,6 +106,7 @@ struct inet6_skb_parm {
 #define IP6SKB_REROUTED		4
 #define IP6SKB_ROUTERALERT	8
 #define IP6SKB_FRAGMENTED      16
+#define IP6SKB_HOPBYHOP        32
 };
 
 #define IP6CB(skb)	((struct inet6_skb_parm*)((skb)->cb))
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 6bafcc2..b96dd8d 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -678,8 +678,8 @@ bool ipv6_opt_accepted(const struct sock *sk, const struct sk_buff *skb,
 	const struct ipv6_pinfo *np = inet6_sk(sk);
 
 	if (np->rxopt.all) {
-		if ((opt->hop && (np->rxopt.bits.hopopts ||
-				  np->rxopt.bits.ohopopts)) ||
+		if (((opt->flags & IP6SKB_HOPBYHOP) &&
+		     (np->rxopt.bits.hopopts || np->rxopt.bits.ohopopts)) ||
 		    (ip6_flowinfo((struct ipv6hdr *) skb_network_header(skb)) &&
 		     np->rxopt.bits.rxflow) ||
 		    (opt->srcrt && (np->rxopt.bits.srcrt ||
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index c215be7..8b6391e 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -531,8 +531,8 @@ void ip6_datagram_recv_specific_ctl(struct sock *sk, struct msghdr *msg,
 	}
 
 	/* HbH is allowed only once */
-	if (np->rxopt.bits.hopopts && opt->hop) {
-		u8 *ptr = nh + opt->hop;
+	if (np->rxopt.bits.hopopts && (opt->flags & IP6SKB_HOPBYHOP)) {
+		u8 *ptr = nh + sizeof(struct ipv6hdr);
 		put_cmsg(msg, SOL_IPV6, IPV6_HOPOPTS, (ptr[1]+1)<<3, ptr);
 	}
 
@@ -593,8 +593,8 @@ void ip6_datagram_recv_specific_ctl(struct sock *sk, struct msghdr *msg,
 		int hlim = ipv6_hdr(skb)->hop_limit;
 		put_cmsg(msg, SOL_IPV6, IPV6_2292HOPLIMIT, sizeof(hlim), &hlim);
 	}
-	if (np->rxopt.bits.ohopopts && opt->hop) {
-		u8 *ptr = nh + opt->hop;
+	if (np->rxopt.bits.ohopopts && (opt->flags & IP6SKB_HOPBYHOP)) {
+		u8 *ptr = nh + sizeof(struct ipv6hdr);
 		put_cmsg(msg, SOL_IPV6, IPV6_2292HOPOPTS, (ptr[1]+1)<<3, ptr);
 	}
 	if (np->rxopt.bits.odstopts && opt->dst0) {
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index a7bbbe4..ce203b0 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -632,7 +632,7 @@ int ipv6_parse_hopopts(struct sk_buff *skb)
 		return -1;
 	}
 
-	opt->hop = sizeof(struct ipv6hdr);
+	opt->flags |= IP6SKB_HOPBYHOP;
 	if (ip6_parse_tlv(tlvprochopopt_lst, skb)) {
 		skb->transport_header += (skb_transport_header(skb)[1] + 1) << 3;
 		opt = IP6CB(skb);
-- 
2.0.5
