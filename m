From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [9/*] [IPSEC] Check dst validity harder in xfrm_bundle_ok
Date: Mon, 7 Mar 2005 21:35:36 +1100
Message-ID: <20050307103536.GB7137@gondor.apana.org.au>
References: <20050214221006.GA18415@gondor.apana.org.au> <20050214221200.GA18465@gondor.apana.org.au> <20050214221433.GB18465@gondor.apana.org.au> <20050214221607.GC18465@gondor.apana.org.au> <20050306213214.7d8a143d.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ikeVEW9yuYc//A+q"
Cc: kuznet@ms2.inr.ac.ru, jmorris@redhat.com, yoshfuji@linux-ipv6.org,
        netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050306213214.7d8a143d.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--ikeVEW9yuYc//A+q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Mar 06, 2005 at 09:32:14PM -0800, David S. Miller wrote:
> 
> Applied, but with a bug fix:
> 
> +		mtu = dst_pmtu(xdst->route);
> +		if (xdst->child_mtu_cached != mtu) {
> +			last = xdst;
> +			xdst->route_mtu_cached = mtu;
> +		}
> 
> You obviously meant "route_mtu_cached" in the test,
> not child_mtu_cached.

Thanks for catching this.

There is another bug in xfrm_bundle_ok where I forgot to
check the validity of xdst->route.  In fact, the check
on dst->path isn't strong enough either.  For IPv6 entries,
dst->path->obsolete is always negative until you call
ipv6_dst_check.  So we really need to do that here.

Here's the patch to fix those two problems.  Yes I know
my dst_check implementation is lame.  I'll come back and
fix up all the dst_check functions by moving their dst_release
calls out.  It proves that you were right in that IPv6 dst
leak thread :)

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--ikeVEW9yuYc//A+q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-9

===== include/net/dst.h 1.27 vs edited =====
--- 1.27/include/net/dst.h	2005-03-07 16:33:59 +11:00
+++ edited/include/net/dst.h	2005-03-07 21:06:13 +11:00
@@ -259,6 +259,15 @@
 	}
 }
 
+static inline struct dst_entry *dst_check(struct dst_entry *dst, u32 cookie)
+{
+	dst_hold(dst);
+	if (dst->obsolete)
+		dst = dst->ops->check(dst, cookie);
+	dst_release(dst);
+	return dst;
+}
+
 extern void		dst_init(void);
 
 struct flowi;
===== net/xfrm/xfrm_policy.c 1.70 vs edited =====
--- 1.70/net/xfrm/xfrm_policy.c	2005-03-07 21:17:35 +11:00
+++ edited/net/xfrm/xfrm_policy.c	2005-03-07 21:26:28 +11:00
@@ -1147,7 +1147,7 @@
 	struct xfrm_dst *last;
 	u32 mtu;
 
-	if (dst->path->obsolete > 0 ||
+	if (!dst_check(dst->path, 0) ||
 	    (dst->dev && !netif_running(dst->dev)))
 		return 0;
 
@@ -1167,6 +1167,8 @@
 			xdst->child_mtu_cached = mtu;
 		}
 
+		if (!dst_check(xdst->route, 0))
+			return 0;
 		mtu = dst_pmtu(xdst->route);
 		if (xdst->route_mtu_cached != mtu) {
 			last = xdst;

--ikeVEW9yuYc//A+q--
