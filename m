From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [5/*] [IPSEC] Use dst_mtu in xfrm[46]_output
Date: Wed, 16 Feb 2005 21:37:44 +1100
Message-ID: <20050216103744.GA476@gondor.apana.org.au>
References: <20050214221006.GA18415@gondor.apana.org.au> <20050214221200.GA18465@gondor.apana.org.au> <20050214221433.GB18465@gondor.apana.org.au> <20050214221607.GC18465@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="dDRMvlgZJXvWKvBx"
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@redhat.com>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050214221607.GC18465@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--dDRMvlgZJXvWKvBx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

There was a lot of fun in laying the foundations.  Now it's time
to start using it.

This patch fixes the calculations in xfrm[46]_output so that we don't
reject properly sized packets from the TCP stack.  The previous
calculation is wrong because the xfrm overhead is not constant.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

After this I'll start cleaning stuff up.  For example, tcp's
ext2_header_len and dst's path can both be removed.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--dDRMvlgZJXvWKvBx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-5

===== include/net/dst.h 1.25 vs edited =====
--- 1.25/include/net/dst.h	2005-02-06 14:23:59 +11:00
+++ edited/include/net/dst.h	2005-02-16 21:29:56 +11:00
@@ -123,6 +123,16 @@
 	return mtu;
 }
 
+static inline u32 dst_mtu(const struct dst_entry *dst)
+{
+	u32 mtu = dst_metric(dst, RTAX_MTU);
+	/*
+	 * Alexey put it here, so ask him about it :)
+	 */
+	barrier();
+	return mtu;
+}
+
 static inline int
 dst_metric_locked(struct dst_entry *dst, int metric)
 {
===== net/ipv4/xfrm4_output.c 1.5 vs edited =====
--- 1.5/net/ipv4/xfrm4_output.c	2004-10-26 09:10:25 +10:00
+++ edited/net/ipv4/xfrm4_output.c	2005-02-16 21:31:32 +11:00
@@ -82,7 +82,7 @@
 		goto out;
 
 	dst = skb->dst;
-	mtu = dst_pmtu(dst) - dst->header_len - dst->trailer_len;
+	mtu = dst_mtu(dst);
 	if (skb->len > mtu) {
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
 		ret = -EMSGSIZE;
===== net/ipv6/xfrm6_output.c 1.7 vs edited =====
--- 1.7/net/ipv6/xfrm6_output.c	2004-11-16 13:52:34 +11:00
+++ edited/net/ipv6/xfrm6_output.c	2005-02-16 21:31:46 +11:00
@@ -79,7 +79,7 @@
 	int mtu, ret = 0;
 	struct dst_entry *dst = skb->dst;
 
-	mtu = dst_pmtu(dst) - dst->header_len - dst->trailer_len;
+	mtu = dst_mtu(dst);
 	if (mtu < IPV6_MIN_MTU)
 		mtu = IPV6_MIN_MTU;
 

--dDRMvlgZJXvWKvBx--
