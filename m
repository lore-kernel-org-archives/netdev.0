From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [XFRM] Make XFRM core subsystem af-independent
Date: Fri, 17 Sep 2004 15:35:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040917153536.6acec52e.davem@davemloft.net>
References: <20040917.205038.61628907.yoshfuji@linux-ipv6.org>
	<E1C8I2m-0005BS-00@gondolin.me.apana.org.au>
	<20040917.231127.114842301.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040917.231127.114842301.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 17 Sep 2004 23:11:27 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> In article <E1C8I2m-0005BS-00@gondolin.me.apana.org.au> (at Fri, 17 Sep 2004 22:40:52 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:
> 
> > Please provide ip_route_output_key() as an inline wrapper around
> > ip_route_output_flow() so that its users don't have to change.
> 
> No.  Because I've succesfully changed all users (AFAIK),
> there's no need to keep it.
> And, I believe the name "ip_route_output_key()" itself was the bug.

Herbert is right this time Yoshifuji-san.

Now all these call sites must pass 2 more parameters when
calling ip_route_output_flow() than when they called
ip_route_output_key() with only 2 parameters.

Let's redo this first patch, putting ip_route_output_key()
into net/ipv4/route.c, and have that function pass the
"NULL, 0" final 2 args to ip_route_output_flow().

I see no problem with ip_route_output_key(), you merely made
a textual replacement that made no improvement of any kind
as far as I can see.  Instead it made the generated code larger
for each of those call sites you changed (needed to pass in the extra
NULL, 0 arguments).  All this was merely so that you only needed
to change one function in your second changeset, but you chould
have achieved that by simply changing ip_route_output_key() into:

int ip_route_output_key(struct rtable **rp, struct flowi *flp)
{
	return ip_route_output_flow(rp, flp, NULL, 0);
}

And you therefore could have combined both efforts into
one simple changeset looking like this, which is what I'm
checking into my tree:

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/17 15:17:53-07:00 davem@nuts.davemloft.net 
#   [XFRM] make xfrm_lookup() fully af-independent.
#   
#   Simplified from 2 patches by Hideaki YOSHIFUJI
#   <yoshfuji@linux-ipv6.org>
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/xfrm/xfrm_policy.c
#   2004/09/17 15:16:56-07:00 davem@nuts.davemloft.net +6 -20
#   [XFRM] make xfrm_lookup() fully af-independent.
# 
# net/ipv4/route.c
#   2004/09/17 15:16:56-07:00 davem@nuts.davemloft.net +13 -8
#   [XFRM] make xfrm_lookup() fully af-independent.
# 
diff -Nru a/net/ipv4/route.c b/net/ipv4/route.c
--- a/net/ipv4/route.c	2004-09-17 15:18:14 -07:00
+++ b/net/ipv4/route.c	2004-09-17 15:18:14 -07:00
@@ -2206,22 +2206,27 @@
 	return ip_route_output_slow(rp, flp);
 }
 
-int ip_route_output_key(struct rtable **rp, struct flowi *flp)
+int ip_route_output_flow(struct rtable **rp, struct flowi *flp, struct sock *sk, int flags)
 {
 	int err;
 
 	if ((err = __ip_route_output_key(rp, flp)) != 0)
 		return err;
-	return flp->proto ? xfrm_lookup((struct dst_entry**)rp, flp, NULL, 0) : 0;
+
+	if (flp->proto) {
+		if (!flp->fl4_src)
+			flp->fl4_src = (*rp)->rt_src;
+		if (!flp->fl4_dst)
+			flp->fl4_dst = (*rp)->rt_dst;
+		return xfrm_lookup((struct dst_entry **)rp, flp, sk, flags);
+	}
+
+	return 0;
 }
 
-int ip_route_output_flow(struct rtable **rp, struct flowi *flp, struct sock *sk, int flags)
+int ip_route_output_key(struct rtable **rp, struct flowi *flp)
 {
-	int err;
-
-	if ((err = __ip_route_output_key(rp, flp)) != 0)
-		return err;
-	return flp->proto ? xfrm_lookup((struct dst_entry**)rp, flp, sk, flags) : 0;
+	return ip_route_output_flow(rp, flp, NULL, 0);
 }
 
 static int rt_fill_info(struct sk_buff *skb, u32 pid, u32 seq, int event,
diff -Nru a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
--- a/net/xfrm/xfrm_policy.c	2004-09-17 15:18:14 -07:00
+++ b/net/xfrm/xfrm_policy.c	2004-09-17 15:18:14 -07:00
@@ -711,25 +711,11 @@
 {
 	struct xfrm_policy *policy;
 	struct xfrm_state *xfrm[XFRM_MAX_DEPTH];
-	struct rtable *rt = (struct rtable*)*dst_p;
-	struct dst_entry *dst;
+	struct dst_entry *dst, *dst_orig = *dst_p;
 	int nx = 0;
 	int err;
 	u32 genid;
-	u16 family = (*dst_p)->ops->family;
-
-	switch (family) {
-	case AF_INET:
-		if (!fl->fl4_src)
-			fl->fl4_src = rt->rt_src;
-		if (!fl->fl4_dst)
-			fl->fl4_dst = rt->rt_dst;
-	case AF_INET6:
-		/* Still not clear... */
-	default:
-		/* nothing */;
-	}
-
+	u16 family = dst_orig->ops->family;
 restart:
 	genid = atomic_read(&flow_cache_genid);
 	policy = NULL;
@@ -738,7 +724,7 @@
 
 	if (!policy) {
 		/* To accelerate a bit...  */
-		if ((rt->u.dst.flags & DST_NOXFRM) || !xfrm_policy_list[XFRM_POLICY_OUT])
+		if ((dst_orig->flags & DST_NOXFRM) || !xfrm_policy_list[XFRM_POLICY_OUT])
 			return 0;
 
 		policy = flow_cache_lookup(fl, family,
@@ -813,7 +799,7 @@
 			return 0;
 		}
 
-		dst = &rt->u.dst;
+		dst = dst_orig;
 		err = xfrm_bundle_create(policy, xfrm, nx, fl, &dst, family);
 
 		if (unlikely(err)) {
@@ -843,12 +829,12 @@
 		write_unlock_bh(&policy->lock);
 	}
 	*dst_p = dst;
-	ip_rt_put(rt);
+	dst_release(dst_orig);
 	xfrm_pol_put(policy);
 	return 0;
 
 error:
-	ip_rt_put(rt);
+	dst_release(dst_orig);
 	xfrm_pol_put(policy);
 	*dst_p = NULL;
 	return err;
