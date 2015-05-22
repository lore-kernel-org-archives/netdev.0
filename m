From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next 1/2] net: ipv4: avoid repeated calls to ip_skb_dst_mtu helper
Date: Fri, 22 May 2015 16:32:50 +0200
Message-ID: <1432305171-21932-2-git-send-email-fw@strlen.de>
References: <1432305171-21932-1-git-send-email-fw@strlen.de>
Cc: hannes@stressinduktion.org, Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:38010 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757220AbbEVOdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 10:33:13 -0400
In-Reply-To: <1432305171-21932-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip_skb_dst_mtu is small inline helper, but its called in several places.

before: 17061      44       0   17105    42d1 net/ipv4/ip_output.o
after:  16805      44       0   16849    41d1 net/ipv4/ip_output.o

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/ip_output.c | 19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 8d91b92..e84a389 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -84,6 +84,7 @@ int sysctl_ip_default_ttl __read_mostly = IPDEFTTL;
 EXPORT_SYMBOL(sysctl_ip_default_ttl);
 
 static int ip_fragment(struct sock *sk, struct sk_buff *skb,
+		       unsigned int mtu,
 		       int (*output)(struct sock *, struct sk_buff *));
 
 /* Generate a checksum for an outgoing IP datagram. */
@@ -219,7 +220,8 @@ static inline int ip_finish_output2(struct sock *sk, struct sk_buff *skb)
 	return -EINVAL;
 }
 
-static int ip_finish_output_gso(struct sock *sk, struct sk_buff *skb)
+static int ip_finish_output_gso(struct sock *sk, struct sk_buff *skb,
+				unsigned int mtu)
 {
 	netdev_features_t features;
 	struct sk_buff *segs;
@@ -227,7 +229,7 @@ static int ip_finish_output_gso(struct sock *sk, struct sk_buff *skb)
 
 	/* common case: locally created skb or seglen is <= mtu */
 	if (((IPCB(skb)->flags & IPSKB_FORWARDED) == 0) ||
-	      skb_gso_network_seglen(skb) <= ip_skb_dst_mtu(skb))
+	      skb_gso_network_seglen(skb) <= mtu)
 		return ip_finish_output2(sk, skb);
 
 	/* Slowpath -  GSO segment length is exceeding the dst MTU.
@@ -251,7 +253,7 @@ static int ip_finish_output_gso(struct sock *sk, struct sk_buff *skb)
 		int err;
 
 		segs->next = NULL;
-		err = ip_fragment(sk, segs, ip_finish_output2);
+		err = ip_fragment(sk, segs, mtu, ip_finish_output2);
 
 		if (err && ret == 0)
 			ret = err;
@@ -263,6 +265,8 @@ static int ip_finish_output_gso(struct sock *sk, struct sk_buff *skb)
 
 static int ip_finish_output(struct sock *sk, struct sk_buff *skb)
 {
+	unsigned int mtu;
+
 #if defined(CONFIG_NETFILTER) && defined(CONFIG_XFRM)
 	/* Policy lookup after SNAT yielded a new policy */
 	if (skb_dst(skb)->xfrm) {
@@ -270,11 +274,12 @@ static int ip_finish_output(struct sock *sk, struct sk_buff *skb)
 		return dst_output_sk(sk, skb);
 	}
 #endif
+	mtu = ip_skb_dst_mtu(skb);
 	if (skb_is_gso(skb))
-		return ip_finish_output_gso(sk, skb);
+		return ip_finish_output_gso(sk, skb, mtu);
 
-	if (skb->len > ip_skb_dst_mtu(skb))
-		return ip_fragment(sk, skb, ip_finish_output2);
+	if (skb->len > mtu)
+		return ip_fragment(sk, skb, mtu, ip_finish_output2);
 
 	return ip_finish_output2(sk, skb);
 }
@@ -482,10 +487,10 @@ static void ip_copy_metadata(struct sk_buff *to, struct sk_buff *from)
 }
 
 static int ip_fragment(struct sock *sk, struct sk_buff *skb,
+		       unsigned int mtu,
 		       int (*output)(struct sock *, struct sk_buff *))
 {
 	struct iphdr *iph = ip_hdr(skb);
-	unsigned int mtu = ip_skb_dst_mtu(skb);
 
 	if (unlikely(((iph->frag_off & htons(IP_DF)) && !skb->ignore_df) ||
 		     (IPCB(skb)->frag_max_size &&
-- 
2.0.5
