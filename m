From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [INET] Create enum of ECN bits
Date: Thu, 22 Jul 2004 22:00:21 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040722120021.GA18293@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="2fHTh5uZTiUOsy+g"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--2fHTh5uZTiUOsy+g
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This patch is a preparation for an update of the ECN encap/decap
code with respect to RFC3168.

It creates an enum of the four code-points defined by RFC3168
and uses them throughout the inet_ecn.h file.

The only non-trivial bit is in IP_ECN_set_ce/IP6_ECN_set_ce where
the patch uses INET_ECN_CE instead of 1.  This is OK as those
functions assume that the ECT bit is already set.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--2fHTh5uZTiUOsy+g
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

diff -Nru a/include/net/inet_ecn.h b/include/net/inet_ecn.h
--- a/include/net/inet_ecn.h	2004-07-22 21:35:12 +10:00
+++ b/include/net/inet_ecn.h	2004-07-22 21:35:12 +10:00
@@ -3,39 +3,48 @@
 
 #include <linux/ip.h>
 
+enum {
+	INET_ECN_NOT_ECT = 0,
+	INET_ECN_ECT_1 = 1,
+	INET_ECN_ECT_0 = 2,
+	INET_ECN_CE = 3,
+	INET_ECN_MASK = 3,
+};
+
 static inline int INET_ECN_is_ce(__u8 dsfield)
 {
-	return (dsfield&3) == 3;
+	return (dsfield & INET_ECN_MASK) == INET_ECN_CE;
 }
 
 static inline int INET_ECN_is_not_ce(__u8 dsfield)
 {
-	return (dsfield&3) == 2;
+	return (dsfield & INET_ECN_MASK) == INET_ECN_ECT_0;
 }
 
 static inline int INET_ECN_is_capable(__u8 dsfield)
 {
-	return (dsfield&2);
+	return (dsfield & INET_ECN_ECT_0);
 }
 
 static inline __u8 INET_ECN_encapsulate(__u8 outer, __u8 inner)
 {
-	outer &= ~3;
+	outer &= ~INET_ECN_MASK;
 	if (INET_ECN_is_capable(inner))
-		outer |= (inner & 3);
+		outer |= (inner & INET_ECN_MASK);
 	return outer;
 }
 
-#define	INET_ECN_xmit(sk) do { inet_sk(sk)->tos |= 2; } while (0)
-#define	INET_ECN_dontxmit(sk) do { inet_sk(sk)->tos &= ~3; } while (0)
+#define	INET_ECN_xmit(sk) do { inet_sk(sk)->tos |= INET_ECN_ECT_0; } while (0)
+#define	INET_ECN_dontxmit(sk) \
+	do { inet_sk(sk)->tos &= ~INET_ECN_MASK; } while (0)
 
-#define IP6_ECN_flow_init(label) do {	\
-      (label) &= ~htonl(3<<20);		\
+#define IP6_ECN_flow_init(label) do {		\
+      (label) &= ~htonl(INET_ECN_MASK << 20);	\
     } while (0)
 
-#define	IP6_ECN_flow_xmit(sk, label) do {			\
-	if (INET_ECN_is_capable(inet_sk(sk)->tos))		\
-		(label) |= __constant_htons(2 << 4);		\
+#define	IP6_ECN_flow_xmit(sk, label) do {				\
+	if (INET_ECN_is_capable(inet_sk(sk)->tos))			\
+		(label) |= __constant_htons(INET_ECN_ECT_0 << 4);	\
     } while (0)
 
 static inline void IP_ECN_set_ce(struct iphdr *iph)
@@ -43,24 +52,24 @@
 	u32 check = iph->check;
 	check += __constant_htons(0xFFFE);
 	iph->check = check + (check>=0xFFFF);
-	iph->tos |= 1;
+	iph->tos |= INET_ECN_CE;
 }
 
 static inline void IP_ECN_clear(struct iphdr *iph)
 {
-	iph->tos &= ~3;
+	iph->tos &= ~INET_ECN_MASK;
 }
 
 struct ipv6hdr;
 
 static inline void IP6_ECN_set_ce(struct ipv6hdr *iph)
 {
-	*(u32*)iph |= htonl(1<<20);
+	*(u32*)iph |= htonl(INET_ECN_CE << 20);
 }
 
 static inline void IP6_ECN_clear(struct ipv6hdr *iph)
 {
-	*(u32*)iph &= ~htonl(3<<20);
+	*(u32*)iph &= ~htonl(INET_ECN_MASK << 20);
 }
 
 #define ip6_get_dsfield(iph) ((ntohs(*(u16*)(iph)) >> 4) & 0xFF)

--2fHTh5uZTiUOsy+g--
