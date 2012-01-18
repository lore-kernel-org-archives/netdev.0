From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 4/3] sha512: reduce stack usage even on i386
Date: Wed, 18 Jan 2012 21:02:10 +0300
Message-ID: <20120118180210.GA22733@p183.telecom.by>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AF43@saturn3.aculab.com>
 <1326709382.2255.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CACVxJT_cZAdxNOFTpK5seUXFZU+YB3zbe6LF1nnyzo32ae14xw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@aculab.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	ken@codelabs.ch, Steffen Klassert <steffen.klassert@secunet.com>,
	security@kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACVxJT_cZAdxNOFTpK5seUXFZU+YB3zbe6LF1nnyzo32ae14xw@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix still excessive stack usage on i386.

There is too much loop unrolling going on, despite W[16] being used,
gcc screws up this for some reason. So, don't be smart, use simple code
from SHA-512 definition, this keeps code size _and_ stack usage back
under control even on i386:

	-14b:   81 ec 9c 03 00 00       sub    $0x39c,%esp
	+149:   81 ec 64 01 00 00       sub    $0x164,%esp

	$ size ../sha512_generic-i386-00*
	   text    data     bss     dec     hex filename
	  15521     712       0   16233    3f69 ../sha512_generic-i386-000.o
	   4225     712       0    4937    1349 ../sha512_generic-i386-001.o

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
Cc: stable@vger.kernel.org
---

 crypto/sha512_generic.c |   42 ++++++++++++++++++++----------------------
 1 file changed, 20 insertions(+), 22 deletions(-)

--- a/crypto/sha512_generic.c
+++ b/crypto/sha512_generic.c
@@ -95,35 +95,33 @@ sha512_transform(u64 *state, const u8 *input)
 #define SHA512_0_15(i, a, b, c, d, e, f, g, h)			\
 	t1 = h + e1(e) + Ch(e, f, g) + sha512_K[i] + W[i];	\
 	t2 = e0(a) + Maj(a, b, c);				\
-	d += t1;						\
-	h = t1 + t2
+	h = g;							\
+	g = f;							\
+	f = e;							\
+	e = d + t1;						\
+	d = c;							\
+	c = b;							\
+	b = a;							\
+	a = t1 + t2
 
 #define SHA512_16_79(i, a, b, c, d, e, f, g, h)			\
 	BLEND_OP(i, W);						\
-	t1 = h + e1(e) + Ch(e, f, g) + sha512_K[i] + W[(i)&15];	\
+	t1 = h + e1(e) + Ch(e, f, g) + sha512_K[i] + W[i & 15];	\
 	t2 = e0(a) + Maj(a, b, c);				\
-	d += t1;						\
-	h = t1 + t2
-
-	for (i = 0; i < 16; i += 8) {
+	h = g;							\
+	g = f;							\
+	f = e;							\
+	e = d + t1;						\
+	d = c;							\
+	c = b;							\
+	b = a;							\
+	a = t1 + t2
+
+	for (i = 0; i < 16; i++) {
 		SHA512_0_15(i, a, b, c, d, e, f, g, h);
-		SHA512_0_15(i + 1, h, a, b, c, d, e, f, g);
-		SHA512_0_15(i + 2, g, h, a, b, c, d, e, f);
-		SHA512_0_15(i + 3, f, g, h, a, b, c, d, e);
-		SHA512_0_15(i + 4, e, f, g, h, a, b, c, d);
-		SHA512_0_15(i + 5, d, e, f, g, h, a, b, c);
-		SHA512_0_15(i + 6, c, d, e, f, g, h, a, b);
-		SHA512_0_15(i + 7, b, c, d, e, f, g, h, a);
 	}
-	for (i = 16; i < 80; i += 8) {
+	for (i = 16; i < 80; i++) {
 		SHA512_16_79(i, a, b, c, d, e, f, g, h);
-		SHA512_16_79(i + 1, h, a, b, c, d, e, f, g);
-		SHA512_16_79(i + 2, g, h, a, b, c, d, e, f);
-		SHA512_16_79(i + 3, f, g, h, a, b, c, d, e);
-		SHA512_16_79(i + 4, e, f, g, h, a, b, c, d);
-		SHA512_16_79(i + 5, d, e, f, g, h, a, b, c);
-		SHA512_16_79(i + 6, c, d, e, f, g, h, a, b);
-		SHA512_16_79(i + 7, b, c, d, e, f, g, h, a);
 	}
 
 	state[0] += a; state[1] += b; state[2] += c; state[3] += d;
