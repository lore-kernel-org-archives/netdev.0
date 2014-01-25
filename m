From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] xfrm: fix potential incorrect pointer dereference in
 xfrm_bundle_create
Date: Sat, 25 Jan 2014 11:32:58 -0800
Message-ID: <1390678378.20150.5.camel@joe-AO722>
References: <1390675673-20682-1-git-send-email-horia.geanta@freescale.com>
	 <20140125.110745.939440249416819926.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: horia.geanta@freescale.com, steffen.klassert@secunet.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0083.hostedemail.com ([216.40.44.83]:60648 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751600AbaAYTdD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jan 2014 14:33:03 -0500
In-Reply-To: <20140125.110745.939440249416819926.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-01-25 at 11:07 -0800, David Miller wrote:
> From: Horia Geanta <horia.geanta@freescale.com>
> Date: Sat, 25 Jan 2014 20:47:53 +0200
> 
> > Return value of xfrm_alloc_dst might be an error code.
> > Need to check this before using the pointer safely.
> > 
> > Signed-off-by: Horia Geanta <horia.geanta@freescale.com>
> > ---
> >  net/xfrm/xfrm_policy.c | 4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> > 
> > diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> > index 9a91f74..f230f2a 100644
> > --- a/net/xfrm/xfrm_policy.c
> > +++ b/net/xfrm/xfrm_policy.c
> > @@ -1541,7 +1541,7 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
> >  
> >  	for (; i < nx; i++) {
> >  		struct xfrm_dst *xdst = xfrm_alloc_dst(net, family);
> > -		struct dst_entry *dst1 = &xdst->u.dst;
> > +		struct dst_entry *dst1;
> 
> There is no harm in taking the address of a bad pointer.  The only
> trouble is if we actually dereference it, which we are not doing here.
> 
> I'm not applying this patch, sorry.

trivia:

Yes, but perhaps the failure test be done before the
assignment anyway.  There are more paths below the test
where the value is not yet used.

Perhaps something like this would be more readable.

(with a few more miscellaneous cleanups)

Use a normal for loop, add braces, remove unnecessary
out: label, move automatic declarations, move error
assignments.

---

 net/xfrm/xfrm_policy.c | 40 +++++++++++++++++++++++-----------------
 1 file changed, 23 insertions(+), 17 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 4b98b25..29ce9fc 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1526,7 +1526,9 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 	struct xfrm_mode *inner_mode;
 	struct dst_entry *dst_prev = NULL;
 	struct dst_entry *dst0 = NULL;
-	int i = 0;
+	struct dst_entry *dst1;
+	struct xfrm_dst *xdst;
+	int i;
 	int err;
 	int header_len = 0;
 	int nfheader_len = 0;
@@ -1538,18 +1540,17 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 	xfrm_flowi_addr_get(fl, &saddr, &daddr, family);
 
 	tos = xfrm_get_tos(fl, family);
-	err = tos;
-	if (tos < 0)
+	if (tos < 0) {
+		err = tos;
 		goto put_states;
+	}
 
 	dst_hold(dst);
 
-	for (; i < nx; i++) {
-		struct xfrm_dst *xdst = xfrm_alloc_dst(net, family);
-		struct dst_entry *dst1 = &xdst->u.dst;
-
-		err = PTR_ERR(xdst);
+	for (i = 0; i < nx; i++) {
+		xdst = xfrm_alloc_dst(net, family);
 		if (IS_ERR(xdst)) {
+			err = PTR_ERR(xdst);
 			dst_release(dst);
 			goto put_states;
 		}
@@ -1562,8 +1563,11 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 				dst_release(dst);
 				goto put_states;
 			}
-		} else
+		} else {
 			inner_mode = xfrm[i]->inner_mode;
+		}
+
+		dst1 = &xdst->u.dst;
 
 		if (!dst_prev)
 			dst0 = dst1;
@@ -1579,11 +1583,13 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 			family = xfrm[i]->props.family;
 			dst = xfrm_dst_lookup(xfrm[i], tos, &saddr, &daddr,
 					      family);
-			err = PTR_ERR(dst);
-			if (IS_ERR(dst))
+			if (IS_ERR(dst)) {
+				err = PTR_ERR(dst);
 				goto put_states;
-		} else
+			}
+		} else {
 			dst_hold(dst);
+		}
 
 		dst1->xfrm = xfrm[i];
 		xdst->xfrm_genid = xfrm[i]->genid;
@@ -1607,10 +1613,11 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 	dst_prev->child = dst;
 	dst0->path = dst;
 
-	err = -ENODEV;
 	dev = dst->dev;
-	if (!dev)
+	if (!dev) {
+		err = -ENODEV;
 		goto free_dst;
+	}
 
 	xfrm_init_path((struct xfrm_dst *)dst0, dst, nfheader_len);
 	xfrm_init_pmtu(dst_prev);
@@ -1628,7 +1635,6 @@ static struct dst_entry *xfrm_bundle_create(struct xfrm_policy *policy,
 		trailer_len -= xdst->u.dst.xfrm->props.trailer_len;
 	}
 
-out:
 	return dst0;
 
 put_states:
@@ -1637,8 +1643,8 @@ put_states:
 free_dst:
 	if (dst0)
 		dst_free(dst0);
-	dst0 = ERR_PTR(err);
-	goto out;
+
+	return ERR_PTR(err);
 }
 
 #ifdef CONFIG_XFRM_SUB_POLICY
