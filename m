From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/24] [IPV6]: Move nfheader_len into rt6_info
Date: Wed, 07 Nov 2007 22:08:19 +0800
Message-ID: <E1IplZr-0001GC-00@gondolin.me.apana.org.au>
References: <20071107140701.GA4685@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3520 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757568AbXKGOIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 09:08:22 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPV6]: Move nfheader_len into rt6_info

The dst member nfheader_len is only used by IPv6.  It's also currently
creating a rather ugly alignment hole in struct dst.  Therefore this patch
moves it from there into struct rt6_info.

It also reorders the fields in rt6_info to minimize holes.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/dst.h       |    1 -
 include/net/ip6_fib.h   |   11 ++++++++---
 net/ipv4/xfrm4_policy.c |    1 -
 net/ipv6/ip6_output.c   |    5 +++--
 net/ipv6/xfrm6_policy.c |    3 ++-
 5 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index e9ff4a4..8f88c52 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -50,7 +50,6 @@ struct dst_entry
 	unsigned long		expires;
 
 	unsigned short		header_len;	/* more space at head required */
-	unsigned short		nfheader_len;	/* more non-fragment space at head required */
 	unsigned short		trailer_len;	/* space to reserve at tail */
 
 	u32			metrics[RTAX_MAX];
diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 8578213..4cefcff 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -99,16 +99,21 @@ struct rt6_info
 	u32				rt6i_flags;
 	u32				rt6i_metric;
 	atomic_t			rt6i_ref;
-	struct fib6_table		*rt6i_table;
 
-	struct rt6key			rt6i_dst;
-	struct rt6key			rt6i_src;
+	/* more non-fragment space at head required */
+	unsigned short			nfheader_len;
 
 	u8				rt6i_protocol;
 
+	struct fib6_table		*rt6i_table;
+
+	struct rt6key			rt6i_dst;
+
 #ifdef CONFIG_XFRM
 	u32				rt6i_flow_cache_genid;
 #endif
+
+	struct rt6key			rt6i_src;
 };
 
 static inline struct inet6_dev *ip6_dst_idev(struct dst_entry *dst)
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index cc86fb1..5ee3a2f 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -161,7 +161,6 @@ __xfrm4_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 		dst_prev->flags	       |= DST_HOST;
 		dst_prev->lastuse	= jiffies;
 		dst_prev->header_len	= header_len;
-		dst_prev->nfheader_len	= 0;
 		dst_prev->trailer_len	= trailer_len;
 		memcpy(&dst_prev->metrics, &x->route->metrics, sizeof(dst_prev->metrics));
 
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 6289dfc..698d9d2 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1097,7 +1097,7 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 		sk->sk_sndmsg_page = NULL;
 		sk->sk_sndmsg_off = 0;
 		exthdrlen = rt->u.dst.header_len + (opt ? opt->opt_flen : 0) -
-			    rt->u.dst.nfheader_len;
+			    rt->nfheader_len;
 		length += exthdrlen;
 		transhdrlen += exthdrlen;
 	} else {
@@ -1112,7 +1112,8 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 
 	hh_len = LL_RESERVED_SPACE(rt->u.dst.dev);
 
-	fragheaderlen = sizeof(struct ipv6hdr) + rt->u.dst.nfheader_len + (opt ? opt->opt_nflen : 0);
+	fragheaderlen = sizeof(struct ipv6hdr) + rt->nfheader_len +
+			(opt ? opt->opt_nflen : 0);
 	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen - sizeof(struct frag_hdr);
 
 	if (mtu <= sizeof(struct ipv6hdr) + IPV6_MAXPLEN) {
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index e5170bc..9095dfc 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -157,7 +157,8 @@ __xfrm6_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 		dst_prev = dst1;
 
 		if (xfrm[i]->type->flags & XFRM_TYPE_NON_FRAGMENT)
-			dst->nfheader_len += xfrm[i]->props.header_len;
+			((struct rt6_info *)dst)->nfheader_len +=
+				xfrm[i]->props.header_len;
 		header_len += xfrm[i]->props.header_len;
 		trailer_len += xfrm[i]->props.trailer_len;
 
