From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [INET] Optimise away a branch in IP_ECN_set_ce
Date: Thu, 9 Sep 2004 10:03:31 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040909000330.GA5581@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="lrZ03NoBR/3+SXJZ"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--lrZ03NoBR/3+SXJZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

I was bored so here is a patch that optimises away a branch in
IP_ECN_set_ce.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--lrZ03NoBR/3+SXJZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== include/net/inet_ecn.h 1.7 vs edited =====
--- 1.7/include/net/inet_ecn.h	2004-09-09 08:04:37 +10:00
+++ edited/include/net/inet_ecn.h	2004-09-09 09:51:08 +10:00
@@ -49,19 +49,27 @@
 static inline void IP_ECN_set_ce(struct iphdr *iph)
 {
 	u32 check = iph->check;
+	u32 ecn = (iph->tos + 1) & INET_ECN_MASK;
 
-	switch (iph->tos & INET_ECN_MASK) {
-	default:
-	case INET_ECN_NOT_ECT:
-	case INET_ECN_CE:
+	/*
+	 * After the last operation we have (in binary):
+	 * INET_ECN_NOT_ECT => 01
+	 * INET_ECN_ECT_1   => 10
+	 * INET_ECN_ECT_0   => 11
+	 * INET_ECN_CE      => 00
+	 */
+	if (!(ecn & 2))
 		return;
-	case INET_ECN_ECT_1:
-		check += __constant_htons(0xFFFD);
-		break;
-	case INET_ECN_ECT_0:
-		check += __constant_htons(0xFFFE);
-		break;
-	}
+
+	/*
+	 * The following gives us:
+	 * INET_ECN_ECT_1 => check += __constant_htons(0xFFFD)
+	 * INET_ECN_ECT_0 => check += __constant_htons(0xFFFE)
+	 */
+	if (__constant_htons(1) != 1)
+		ecn <<= 8;
+	check += __constant_htons(0xFFFB) + ecn;
+
 	iph->check = check + (check>=0xFFFF);
 	iph->tos |= INET_ECN_CE;
 }

--lrZ03NoBR/3+SXJZ--
