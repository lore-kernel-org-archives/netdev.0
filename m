From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [6/*] [IPSEC] Fix xfrm[46]_update_pmtu to update top dst
Date: Wed, 16 Feb 2005 22:08:42 +1100
Message-ID: <20050216110842.GA1024@gondor.apana.org.au>
References: <20050214221006.GA18415@gondor.apana.org.au> <20050214221200.GA18465@gondor.apana.org.au> <20050214221433.GB18465@gondor.apana.org.au> <20050214221607.GC18465@gondor.apana.org.au> <20050216103744.GA476@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="cWoXeonUoKmBZSoM"
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@redhat.com>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050216103744.GA476@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--cWoXeonUoKmBZSoM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Let's also fix IPsec PMTU storage.  When we get an MTU update for an
xfrm_dst, it should be done to the top dst, not the bottom dst.

For example, when we get a need-to-frag message for host C behind
a our IPsec peer B, we should be updating the dst entry for C and
not B as we do now.

I've removed the boundary checks since the same checks are done
in ipv[46]/route.c already.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--cWoXeonUoKmBZSoM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-6

===== net/ipv4/xfrm4_policy.c 1.16 vs edited =====
--- 1.16/net/ipv4/xfrm4_policy.c	2005-02-14 14:59:25 +11:00
+++ edited/net/ipv4/xfrm4_policy.c	2005-02-16 22:01:56 +11:00
@@ -235,10 +235,8 @@
 
 static void xfrm4_update_pmtu(struct dst_entry *dst, u32 mtu)
 {
-	struct dst_entry *path = dst->path;
-
-	if (mtu < 68 + dst->header_len)
-		return;
+	struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
+	struct dst_entry *path = xdst->route;
 
 	path->ops->update_pmtu(path, mtu);
 }
===== net/ipv6/xfrm6_policy.c 1.27 vs edited =====
--- 1.27/net/ipv6/xfrm6_policy.c	2005-02-14 14:59:25 +11:00
+++ edited/net/ipv6/xfrm6_policy.c	2005-02-16 22:03:06 +11:00
@@ -243,12 +243,10 @@
 
 static void xfrm6_update_pmtu(struct dst_entry *dst, u32 mtu)
 {
-	struct dst_entry *path = dst->path;
+	struct xfrm_dst *xdst = (struct xfrm_dst *)dst;
+	struct dst_entry *path = xdst->route;
 
-	if (mtu >= IPV6_MIN_MTU && mtu < dst_pmtu(dst))
-		path->ops->update_pmtu(path, mtu);
-	
-	return;
+	path->ops->update_pmtu(path, mtu);
 }
 
 static struct dst_ops xfrm6_dst_ops = {

--cWoXeonUoKmBZSoM--
