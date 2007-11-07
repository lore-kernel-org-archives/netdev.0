From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 8/24] [IPSEC]: Make sure idev is consistent with dev in xfrm_dst
Date: Wed, 07 Nov 2007 22:08:24 +0800
Message-ID: <E1IplZw-0001Gx-00@gondolin.me.apana.org.au>
References: <20071107140701.GA4685@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3536 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758462AbXKGOIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 09:08:31 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Make sure idev is consistent with dev in xfrm_dst

Previously we took the device from the bottom route and idev from the top
route.  This is bad because idev may well point to a different device.
This patch changes it so that we get the idev from the device directly.

It also makes it an error if either dev or idev is NULL.  This is consistent
with the rest of the routing code which also treats these cases as errors.

I've removed the err initialisation in xfrm6_policy.c because it achieves
no purpose and hid a bug when an initial version of this patch neglected
to set err to -ENODEV (fortunately the IPv4 version warned about it).

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv4/xfrm4_policy.c |   13 +++++++++----
 net/ipv6/xfrm6_policy.c |   15 ++++++++++-----
 2 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index c40a71b..d903c8b 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -153,14 +153,21 @@ __xfrm4_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 
 	dst_prev = *dst_p;
 	i = 0;
+	err = -ENODEV;
 	for (; dst_prev != &rt->u.dst; dst_prev = dst_prev->child) {
 		struct xfrm_dst *x = (struct xfrm_dst*)dst_prev;
 		x->u.rt.fl = *fl;
 
 		dst_prev->xfrm = xfrm[i++];
 		dst_prev->dev = rt->u.dst.dev;
-		if (rt->u.dst.dev)
-			dev_hold(rt->u.dst.dev);
+		if (!rt->u.dst.dev)
+			goto error;
+		dev_hold(rt->u.dst.dev);
+
+		x->u.rt.idev = in_dev_get(rt->u.dst.dev);
+		if (!x->u.rt.idev)
+			goto error;
+
 		dst_prev->obsolete	= -1;
 		dst_prev->flags	       |= DST_HOST;
 		dst_prev->lastuse	= jiffies;
@@ -181,8 +188,6 @@ __xfrm4_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 		x->u.rt.rt_dst = rt0->rt_dst;
 		x->u.rt.rt_gateway = rt0->rt_gateway;
 		x->u.rt.rt_spec_dst = rt0->rt_spec_dst;
-		x->u.rt.idev = rt0->idev;
-		in_dev_hold(rt0->idev);
 		header_len -= x->u.dst.xfrm->props.header_len;
 		trailer_len -= x->u.dst.xfrm->props.trailer_len;
 	}
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index a1c6b7c..f04e718 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -123,7 +123,7 @@ __xfrm6_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 		}
 	};
 	int i;
-	int err = 0;
+	int err;
 	int header_len = 0;
 	int trailer_len = 0;
 
@@ -201,13 +201,20 @@ __xfrm6_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 
 	dst_prev = *dst_p;
 	i = 0;
+	err = -ENODEV;
 	for (; dst_prev != &rt->u.dst; dst_prev = dst_prev->child) {
 		struct xfrm_dst *x = (struct xfrm_dst*)dst_prev;
 
 		dst_prev->xfrm = xfrm[i++];
 		dst_prev->dev = rt->u.dst.dev;
-		if (rt->u.dst.dev)
-			dev_hold(rt->u.dst.dev);
+		if (!rt->u.dst.dev)
+			goto error;
+		dev_hold(rt->u.dst.dev);
+
+		x->u.rt6.rt6i_idev = in6_dev_get(rt->u.dst.dev);
+		if (!x->u.rt6.rt6i_idev)
+			goto error;
+
 		dst_prev->obsolete	= -1;
 		dst_prev->flags	       |= DST_HOST;
 		dst_prev->lastuse	= jiffies;
@@ -226,8 +233,6 @@ __xfrm6_bundle_create(struct xfrm_policy *policy, struct xfrm_state **xfrm, int
 		memcpy(&x->u.rt6.rt6i_gateway, &rt0->rt6i_gateway, sizeof(x->u.rt6.rt6i_gateway));
 		x->u.rt6.rt6i_dst      = rt0->rt6i_dst;
 		x->u.rt6.rt6i_src      = rt0->rt6i_src;
-		x->u.rt6.rt6i_idev     = rt0->rt6i_idev;
-		in6_dev_hold(rt0->rt6i_idev);
 		header_len -= x->u.dst.xfrm->props.header_len;
 		trailer_len -= x->u.dst.xfrm->props.trailer_len;
 	}
