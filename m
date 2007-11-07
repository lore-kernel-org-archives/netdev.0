From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 9/24] [IPSEC]: Replace x->type->{local,remote}_addr with flags
Date: Wed, 07 Nov 2007 22:08:25 +0800
Message-ID: <E1IplZx-0001H5-00@gondolin.me.apana.org.au>
References: <20071107140701.GA4685@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3545 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758563AbXKGOIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 09:08:37 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Replace x->type->{local,remote}_addr with flags

The functions local_addr and remote_addr are more than what they're needed
for.  The same thing can be done easily with flags on the type object.
This patch does that and simplifies the wrapper functions in xfrm6_policy
accordingly.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/xfrm.h      |    4 ++--
 net/ipv6/mip6.c         |   11 ++---------
 net/ipv6/xfrm6_policy.c |   20 ++++++++------------
 3 files changed, 12 insertions(+), 23 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 58dfa82..f96bae2 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -282,6 +282,8 @@ struct xfrm_type
 	__u8			flags;
 #define XFRM_TYPE_NON_FRAGMENT	1
 #define XFRM_TYPE_REPLAY_PROT	2
+#define XFRM_TYPE_LOCAL_COADDR	4
+#define XFRM_TYPE_REMOTE_COADDR	8
 
 	int			(*init_state)(struct xfrm_state *x);
 	void			(*destructor)(struct xfrm_state *);
@@ -289,8 +291,6 @@ struct xfrm_type
 	int			(*output)(struct xfrm_state *, struct sk_buff *pskb);
 	int			(*reject)(struct xfrm_state *, struct sk_buff *, struct flowi *);
 	int			(*hdr_offset)(struct xfrm_state *, struct sk_buff *, u8 **);
-	xfrm_address_t		*(*local_addr)(struct xfrm_state *, xfrm_address_t *);
-	xfrm_address_t		*(*remote_addr)(struct xfrm_state *, xfrm_address_t *);
 	/* Estimate maximal size of result of transformation of a dgram */
 	u32			(*get_mtu)(struct xfrm_state *, int size);
 };
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index 7fd841d..edfd9cd 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -34,11 +34,6 @@
 #include <net/xfrm.h>
 #include <net/mip6.h>
 
-static xfrm_address_t *mip6_xfrm_addr(struct xfrm_state *x, xfrm_address_t *addr)
-{
-	return x->coaddr;
-}
-
 static inline unsigned int calc_padlen(unsigned int len, unsigned int n)
 {
 	return (n - len + 16) & 0x7;
@@ -337,14 +332,13 @@ static struct xfrm_type mip6_destopt_type =
 	.description	= "MIP6DESTOPT",
 	.owner		= THIS_MODULE,
 	.proto	     	= IPPROTO_DSTOPTS,
-	.flags		= XFRM_TYPE_NON_FRAGMENT,
+	.flags		= XFRM_TYPE_NON_FRAGMENT | XFRM_TYPE_LOCAL_COADDR,
 	.init_state	= mip6_destopt_init_state,
 	.destructor	= mip6_destopt_destroy,
 	.input		= mip6_destopt_input,
 	.output		= mip6_destopt_output,
 	.reject		= mip6_destopt_reject,
 	.hdr_offset	= mip6_destopt_offset,
-	.local_addr	= mip6_xfrm_addr,
 };
 
 static int mip6_rthdr_input(struct xfrm_state *x, struct sk_buff *skb)
@@ -467,13 +461,12 @@ static struct xfrm_type mip6_rthdr_type =
 	.description	= "MIP6RT",
 	.owner		= THIS_MODULE,
 	.proto	     	= IPPROTO_ROUTING,
-	.flags		= XFRM_TYPE_NON_FRAGMENT,
+	.flags		= XFRM_TYPE_NON_FRAGMENT | XFRM_TYPE_REMOTE_COADDR,
 	.init_state	= mip6_rthdr_init_state,
 	.destructor	= mip6_rthdr_destroy,
 	.input		= mip6_rthdr_input,
 	.output		= mip6_rthdr_output,
 	.hdr_offset	= mip6_rthdr_offset,
-	.remote_addr	= mip6_xfrm_addr,
 };
 
 static int __init mip6_init(void)
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index f04e718..ed29bef 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -87,20 +87,16 @@ __xfrm6_find_bundle(struct flowi *fl, struct xfrm_policy *policy)
 	return dst;
 }
 
-static inline struct in6_addr*
-__xfrm6_bundle_addr_remote(struct xfrm_state *x, struct in6_addr *addr)
+static inline xfrm_address_t *__xfrm6_bundle_addr_remote(struct xfrm_state *x)
 {
-	return (x->type->remote_addr) ?
-		(struct in6_addr*)x->type->remote_addr(x, (xfrm_address_t *)addr) :
-		(struct in6_addr*)&x->id.daddr;
+	return (x->type->flags & XFRM_TYPE_REMOTE_COADDR) ? x->coaddr :
+							    &x->id.daddr;
 }
 
-static inline struct in6_addr*
-__xfrm6_bundle_addr_local(struct xfrm_state *x, struct in6_addr *addr)
+static inline xfrm_address_t *__xfrm6_bundle_addr_local(struct xfrm_state *x)
 {
-	return (x->type->local_addr) ?
-		(struct in6_addr*)x->type->local_addr(x, (xfrm_address_t *)addr) :
-		(struct in6_addr*)&x->props.saddr;
+	return (x->type->flags & XFRM_TYPE_LOCAL_COADDR) ? x->coaddr :
+							   &x->props.saddr;
 }
 
 /* Allocate chain of dst_entry's, attach known xfrm's, calculate
@@ -171,9 +167,9 @@ __xfrm6_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 				fl_tunnel.fl4_src = xfrm[i]->props.saddr.a4;
 				break;
 			case AF_INET6:
-				ipv6_addr_copy(&fl_tunnel.fl6_dst, __xfrm6_bundle_addr_remote(xfrm[i], &fl->fl6_dst));
+				ipv6_addr_copy(&fl_tunnel.fl6_dst, (struct in6_addr *)__xfrm6_bundle_addr_remote(xfrm[i]));
 
-				ipv6_addr_copy(&fl_tunnel.fl6_src, __xfrm6_bundle_addr_local(xfrm[i], &fl->fl6_src));
+				ipv6_addr_copy(&fl_tunnel.fl6_src, (struct in6_addr *)__xfrm6_bundle_addr_local(xfrm[i]));
 				break;
 			default:
 				BUG_ON(1);
