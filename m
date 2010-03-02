From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH]xfrm: fix perpetual bundles
Date: Tue, 2 Mar 2010 20:51:56 +0800
Message-ID: <20100302125156.GA2420@gondor.apana.org.au>
References: <1267017564.3973.790.camel@bigi> <20100302112754.GA1513@gondor.apana.org.au> <1267531905.21749.21.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kaber@trash.net, yoshfuji@linux-ipv6.org,
	nakam@linux-ipv6.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47424 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752798Ab0CBMwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Mar 2010 07:52:14 -0500
Content-Disposition: inline
In-Reply-To: <1267531905.21749.21.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 02, 2010 at 07:11:45AM -0500, jamal wrote:
>
> fl->fl4_src is valid non-zero. But in xfrm4_fill_dst()

I see, so problem #1 doesn't exist.

> we do wholesale copy of xdst->u.rt.fl = rt->fl; and rt->fl.fl4_src is
> 0.0.0.0.

Heh, you've just discovered a bug that I carefully planted back
in 2007, while merging the v4/v6 policy code :)

It is a clear merging error, where *fl became rt->fl which is
totally different.  So please try this patch:

ipsec: Fix bogus bundle flowi

When I merged the bundle creation code, I introduced a bogus
flowi value in the bundle.  Instead of getting from the caller,
it was instead set to the flow in the route object, which is
totally different.

The end result is that the bundles we created never match, and
we instead end up with an ever growing bundle list.

Thanks to Jamal for find this problem.

Reported-by: Jamal Hadi Salim <hadi@cyberus.ca>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 60c2770..1e355d8 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -274,7 +274,8 @@ struct xfrm_policy_afinfo {
 					     struct dst_entry *dst,
 					     int nfheader_len);
 	int			(*fill_dst)(struct xfrm_dst *xdst,
-					    struct net_device *dev);
+					    struct net_device *dev,
+					    struct flowi *fl);
 };
 
 extern int xfrm_policy_register_afinfo(struct xfrm_policy_afinfo *afinfo);
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 67107d6..e4a1483 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -91,11 +91,12 @@ static int xfrm4_init_path(struct xfrm_dst *path, struct dst_entry *dst,
 	return 0;
 }
 
-static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev)
+static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
+			  struct flowi *fl)
 {
 	struct rtable *rt = (struct rtable *)xdst->route;
 
-	xdst->u.rt.fl = rt->fl;
+	xdst->u.rt.fl = *fl;
 
 	xdst->u.dst.dev = dev;
 	dev_hold(dev);
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index dbdc696..ae18165 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -116,7 +116,8 @@ static int xfrm6_init_path(struct xfrm_dst *path, struct dst_entry *dst,
 	return 0;
 }
 
-static int xfrm6_fill_dst(struct xfrm_dst *xdst, struct net_device *dev)
+static int xfrm6_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
+			  struct flowi *fl)
 {
 	struct rt6_info *rt = (struct rt6_info*)xdst->route;
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 0ecb16a..f12dd3d 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1354,7 +1354,8 @@ static inline int xfrm_init_path(struct xfrm_dst *path, struct dst_entry *dst,
 	return err;
 }
 
-static inline int xfrm_fill_dst(struct xfrm_dst *xdst, struct net_device *dev)
+static inline int xfrm_fill_dst(struct xfrm_dst *xdst, struct net_device *dev,
+				struct flowi *fl)
 {
 	struct xfrm_policy_afinfo *afinfo =
 		xfrm_policy_get_afinfo(xdst->u.dst.ops->family);
@@ -1363,7 +1364,7 @@ static inline int xfrm_fill_dst(struct xfrm_dst *xdst, struct net_device *dev)
 	if (!afinfo)
 		return -EINVAL;
 
-	err = afinfo->fill_dst(xdst, dev);
+	err = afinfo->fill_dst(xdst, dev, fl);
 
 	xfrm_policy_put_afinfo(afinfo);
 
@@ -1468,7 +1469,7 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 	for (dst_prev = dst0; dst_prev != dst; dst_prev = dst_prev->child) {
 		struct xfrm_dst *xdst = (struct xfrm_dst *)dst_prev;
 
-		err = xfrm_fill_dst(xdst, dev);
+		err = xfrm_fill_dst(xdst, dev, fl);
 		if (err)
 			goto free_dst;
 
Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
