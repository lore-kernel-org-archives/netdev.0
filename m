From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [11/*] [NET] Move dst_release out of dst->ops->check
Date: Tue, 8 Mar 2005 21:27:41 +1100
Message-ID: <20050308102741.GA23468@gondor.apana.org.au>
References: <20050214221006.GA18415@gondor.apana.org.au> <20050214221200.GA18465@gondor.apana.org.au> <20050214221433.GB18465@gondor.apana.org.au> <20050214221607.GC18465@gondor.apana.org.au> <20050306213214.7d8a143d.davem@davemloft.net> <20050307103536.GB7137@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="IJpNTDwzlM2Ie8A6"
Cc: kuznet@ms2.inr.ac.ru, jmorris@redhat.com, yoshfuji@linux-ipv6.org,
        netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050307103536.GB7137@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--IJpNTDwzlM2Ie8A6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Mar 07, 2005 at 09:35:36PM +1100, herbert wrote:
> 
> Here's the patch to fix those two problems.  Yes I know
> my dst_check implementation is lame.  I'll come back and
> fix up all the dst_check functions by moving their dst_release
> calls out.  It proves that you were right in that IPv6 dst
> leak thread :)

As promised here is the patch that moves dst_release out of
dst->ops->check.  It bloats sk_dst_check/__sk_dst_check slightly
but they're only used in a handful of places so it isn't too bad.
I actually counted, it's about a few hundred bytes.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--IJpNTDwzlM2Ie8A6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-11

===== include/net/dst.h 1.28 vs edited =====
--- 1.28/include/net/dst.h	2005-03-07 22:03:36 +11:00
+++ edited/include/net/dst.h	2005-03-08 21:04:46 +11:00
@@ -261,10 +261,8 @@
 
 static inline struct dst_entry *dst_check(struct dst_entry *dst, u32 cookie)
 {
-	dst_hold(dst);
 	if (dst->obsolete)
 		dst = dst->ops->check(dst, cookie);
-	dst_release(dst);
 	return dst;
 }
 
===== include/net/sock.h 1.90 vs edited =====
--- 1.90/include/net/sock.h	2005-01-11 07:23:55 +11:00
+++ edited/include/net/sock.h	2005-03-08 21:05:42 +11:00
@@ -983,6 +983,7 @@
 
 	if (dst && dst->obsolete && dst->ops->check(dst, cookie) == NULL) {
 		sk->sk_dst_cache = NULL;
+		dst_release(dst);
 		return NULL;
 	}
 
@@ -996,6 +997,7 @@
 
 	if (dst && dst->obsolete && dst->ops->check(dst, cookie) == NULL) {
 		sk_dst_reset(sk);
+		dst_release(dst);
 		return NULL;
 	}
 
===== net/decnet/dn_route.c 1.31 vs edited =====
--- 1.31/net/decnet/dn_route.c	2005-01-14 16:03:01 +11:00
+++ edited/net/decnet/dn_route.c	2005-03-08 21:04:46 +11:00
@@ -253,7 +253,6 @@
  */
 static struct dst_entry *dn_dst_check(struct dst_entry *dst, __u32 cookie)
 {
-	dst_release(dst);
 	return NULL;
 }
 
===== net/ipv4/route.c 1.104 vs edited =====
--- 1.104/net/ipv4/route.c	2005-03-06 15:43:44 +11:00
+++ edited/net/ipv4/route.c	2005-03-08 21:04:46 +11:00
@@ -1326,7 +1326,6 @@
 
 static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
 {
-	dst_release(dst);
 	return NULL;
 }
 
===== net/ipv4/ipvs/ip_vs_xmit.c 1.11 vs edited =====
--- 1.11/net/ipv4/ipvs/ip_vs_xmit.c	2004-09-13 09:25:50 +10:00
+++ edited/net/ipv4/ipvs/ip_vs_xmit.c	2005-03-08 21:04:46 +11:00
@@ -52,6 +52,7 @@
 	if ((dst->obsolete || rtos != dest->dst_rtos) &&
 	    dst->ops->check(dst, cookie) == NULL) {
 		dest->dst_cache = NULL;
+		dst_release(dst);
 		return NULL;
 	}
 	dst_hold(dst);
===== net/ipv6/ip6_tunnel.c 1.28 vs edited =====
--- 1.28/net/ipv6/ip6_tunnel.c	2005-02-07 16:40:51 +11:00
+++ edited/net/ipv6/ip6_tunnel.c	2005-03-08 21:04:47 +11:00
@@ -94,6 +94,7 @@
 	if (dst && dst->obsolete && 
 	    dst->ops->check(dst, t->dst_cookie) == NULL) {
 		t->dst_cache = NULL;
+		dst_release(dst);
 		return NULL;
 	}
 
===== net/ipv6/route.c 1.106 vs edited =====
--- 1.106/net/ipv6/route.c	2005-02-16 09:23:11 +11:00
+++ edited/net/ipv6/route.c	2005-03-08 21:04:47 +11:00
@@ -589,7 +589,6 @@
 	if (rt && rt->rt6i_node && (rt->rt6i_node->fn_sernum == cookie))
 		return dst;
 
-	dst_release(dst);
 	return NULL;
 }
 
===== net/xfrm/xfrm_policy.c 1.71 vs edited =====
--- 1.71/net/xfrm/xfrm_policy.c	2005-03-07 22:03:36 +11:00
+++ edited/net/xfrm/xfrm_policy.c	2005-03-08 21:04:47 +11:00
@@ -1015,7 +1015,6 @@
 	if (!stale_bundle(dst))
 		return dst;
 
-	dst_release(dst);
 	return NULL;
 }
 

--IJpNTDwzlM2Ie8A6--
