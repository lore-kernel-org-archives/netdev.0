From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [BUG REPORT]  Unencrypted packets after SNAT, allthough
 IPSEC-Policies are present
Date: Tue, 16 Sep 2014 10:39:44 +0200
Message-ID: <20140916083944.GS6390@secunet.com>
References: <541089DD.6060307@sirrix.com>
 <20140911115401.GL6390@secunet.com>
 <54119F75.8090305@sirrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<herbert@gondor.apana.org.au>
To: Konstantinos Kolelis <k.kolelis@sirrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:47131 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751071AbaIPIjv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2014 04:39:51 -0400
Content-Disposition: inline
In-Reply-To: <54119F75.8090305@sirrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 11, 2014 at 03:11:17PM +0200, Konstantinos Kolelis wrote:
> 
> You should also check what happens if xfrm_larval_drop is false.
> Allthough blackhole route was not used, you could still run into the
> same problem. It just took a while longer.
> 

This one should fix the xfrm_larval_drop false case. It applies
on top of my previous patch. Both patches are currenty in the
ipsec testing branch at:

git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git testing

Subject: [PATCH] xfrm: Generate queueing routes only from route lookup
 functions

Currently we genarate a queueing route if we have matching policies
but can not resolve the states and the sysctl xfrm_larval_drop is
disabled. Here we assume that dst_output() is called to kill the
queued packets. Unfortunately this assumption is not true in all
cases, so it is possible that these packets leave the system unwanted.

We fix this by generating queueing routes only from the
route lookup functions, here we can guarantee a call to
dst_output() afterwards.

Fixes: a0073fe18e71 ("xfrm: Add a state resolution packet queue")
Reported-by: Konstantinos Kolelis <k.kolelis@sirrix.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/dst.h      |  1 +
 net/xfrm/xfrm_policy.c | 32 ++++++++++++++++++++++++--------
 2 files changed, 25 insertions(+), 8 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index fa11c90..a8ae4e7 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -480,6 +480,7 @@ void dst_init(void);
 /* Flags for xfrm_lookup flags argument. */
 enum {
 	XFRM_LOOKUP_ICMP = 1 << 0,
+	XFRM_LOOKUP_QUEUE = 1 << 1,
 };
 
 struct flowi;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 7505674..fdde51f 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -39,6 +39,11 @@
 #define XFRM_QUEUE_TMO_MAX ((unsigned)(60*HZ))
 #define XFRM_MAX_QUEUE_LEN	100
 
+struct xfrm_flo {
+	struct dst_entry *dst_orig;
+	u8 flags;
+};
+
 static DEFINE_SPINLOCK(xfrm_policy_afinfo_lock);
 static struct xfrm_policy_afinfo __rcu *xfrm_policy_afinfo[NPROTO]
 						__read_mostly;
@@ -1877,13 +1882,14 @@ static int xdst_queue_output(struct sock *sk, struct sk_buff *skb)
 }
 
 static struct xfrm_dst *xfrm_create_dummy_bundle(struct net *net,
-						 struct dst_entry *dst,
+						 struct xfrm_flo *xflo,
 						 const struct flowi *fl,
 						 int num_xfrms,
 						 u16 family)
 {
 	int err;
 	struct net_device *dev;
+	struct dst_entry *dst;
 	struct dst_entry *dst1;
 	struct xfrm_dst *xdst;
 
@@ -1891,9 +1897,12 @@ static struct xfrm_dst *xfrm_create_dummy_bundle(struct net *net,
 	if (IS_ERR(xdst))
 		return xdst;
 
-	if (net->xfrm.sysctl_larval_drop || num_xfrms <= 0)
+	if (!(xflo->flags & XFRM_LOOKUP_QUEUE) ||
+	    net->xfrm.sysctl_larval_drop ||
+	    num_xfrms <= 0)
 		return xdst;
 
+	dst = xflo->dst_orig;
 	dst1 = &xdst->u.dst;
 	dst_hold(dst);
 	xdst->route = dst;
@@ -1935,7 +1944,7 @@ static struct flow_cache_object *
 xfrm_bundle_lookup(struct net *net, const struct flowi *fl, u16 family, u8 dir,
 		   struct flow_cache_object *oldflo, void *ctx)
 {
-	struct dst_entry *dst_orig = (struct dst_entry *)ctx;
+	struct xfrm_flo *xflo = (struct xfrm_flo *)ctx;
 	struct xfrm_policy *pols[XFRM_POLICY_TYPE_MAX];
 	struct xfrm_dst *xdst, *new_xdst;
 	int num_pols = 0, num_xfrms = 0, i, err, pol_dead;
@@ -1976,7 +1985,8 @@ xfrm_bundle_lookup(struct net *net, const struct flowi *fl, u16 family, u8 dir,
 			goto make_dummy_bundle;
 	}
 
-	new_xdst = xfrm_resolve_and_create_bundle(pols, num_pols, fl, family, dst_orig);
+	new_xdst = xfrm_resolve_and_create_bundle(pols, num_pols, fl, family,
+						  xflo->dst_orig);
 	if (IS_ERR(new_xdst)) {
 		err = PTR_ERR(new_xdst);
 		if (err != -EAGAIN)
@@ -2010,7 +2020,7 @@ make_dummy_bundle:
 	/* We found policies, but there's no bundles to instantiate:
 	 * either because the policy blocks, has no transformations or
 	 * we could not build template (no xfrm_states).*/
-	xdst = xfrm_create_dummy_bundle(net, dst_orig, fl, num_xfrms, family);
+	xdst = xfrm_create_dummy_bundle(net, xflo, fl, num_xfrms, family);
 	if (IS_ERR(xdst)) {
 		xfrm_pols_put(pols, num_pols);
 		return ERR_CAST(xdst);
@@ -2104,13 +2114,18 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
 	}
 
 	if (xdst == NULL) {
+		struct xfrm_flo xflo;
+
+		xflo.dst_orig = dst_orig;
+		xflo.flags = flags;
+
 		/* To accelerate a bit...  */
 		if ((dst_orig->flags & DST_NOXFRM) ||
 		    !net->xfrm.policy_count[XFRM_POLICY_OUT])
 			goto nopol;
 
 		flo = flow_cache_lookup(net, fl, family, dir,
-					xfrm_bundle_lookup, dst_orig);
+					xfrm_bundle_lookup, &xflo);
 		if (flo == NULL)
 			goto nopol;
 		if (IS_ERR(flo)) {
@@ -2202,7 +2217,8 @@ struct dst_entry *xfrm_lookup_route(struct net *net, struct dst_entry *dst_orig,
 				    const struct flowi *fl,
 				    struct sock *sk, int flags)
 {
-	struct dst_entry *dst = xfrm_lookup(net, dst_orig, fl, sk, flags);
+	struct dst_entry *dst = xfrm_lookup(net, dst_orig, fl, sk,
+					    flags | XFRM_LOOKUP_QUEUE);
 
 	if (IS_ERR(dst) && PTR_ERR(dst) == -EREMOTE)
 		return make_blackhole(net, dst_orig->ops->family, dst_orig);
@@ -2476,7 +2492,7 @@ int __xfrm_route_forward(struct sk_buff *skb, unsigned short family)
 
 	skb_dst_force(skb);
 
-	dst = xfrm_lookup(net, skb_dst(skb), &fl, NULL, 0);
+	dst = xfrm_lookup(net, skb_dst(skb), &fl, NULL, XFRM_LOOKUP_QUEUE);
 	if (IS_ERR(dst)) {
 		res = 0;
 		dst = NULL;
-- 
1.9.1
