From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 4/3] sha512: reduce stack usage even on i386
Date: Fri, 3 Feb 2012 14:34:50 +1100
Message-ID: <20120203033450.GA17668@gondor.apana.org.au>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AF43@saturn3.aculab.com> <1326709382.2255.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <CACVxJT_cZAdxNOFTpK5seUXFZU+YB3zbe6LF1nnyzo32ae14xw@mail.gmail.com> <20120118180210.GA22733@p183.telecom.by> <20120126023502.GA10696@gondor.apana.org.au> <20120127175130.GA742@p183.telecom.by> <20120127223250.GA9384@gondor.apana.org.au> <CACVxJT8phQxQHSBDJ_zOzdO9QVMmVK=v-mFTac2gn9+xZZSQkQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Laight <David.Laight@aculab.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	ken@codelabs.ch, Steffen Klassert <steffen.klassert@secunet.com>,
	security@kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACVxJT8phQxQHSBDJ_zOzdO9QVMmVK=v-mFTac2gn9+xZZSQkQ@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 30, 2012 at 01:10:48PM +0200, Alexey Dobriyan wrote:
> 
> For some reason it doesn't. :-( I've also tried full barriers.

OK, I don't think it worked in the sha1 case either, as on my
i386 here lib/sha1.c ends up using nearly 500 bytes of stack
space.

It appears that the crux of the issue here is the use of 64-bit
ops.  gcc just doesn't like that at all on i386 and ends up
putting every other intermediate result on the stack in its own
unique place.

While you de-unrolling patch does reduce the stack use, it also
incurs a speed penalty of around 15%, and that's on top of the
4% we've already added by getting rid of per_cpu.

However, this patch seems to work for me, and reduces the stack
usage to a level about the same as lib/sha1.c + crypto/sha1_generic.c
without adding any new overhead.

So let me know if you have any better ideas.

diff --git a/crypto/sha512_generic.c b/crypto/sha512_generic.c
index 3edebfd..f04af93 100644
--- a/crypto/sha512_generic.c
+++ b/crypto/sha512_generic.c
@@ -89,46 +89,42 @@ sha512_transform(u64 *state, const u8 *input)
 	int i;
 	u64 W[16];
 
-	/* load the input */
-        for (i = 0; i < 16; i++)
-                LOAD_OP(i, W, input);
-
 	/* load the state into our registers */
 	a=state[0];   b=state[1];   c=state[2];   d=state[3];
 	e=state[4];   f=state[5];   g=state[6];   h=state[7];
 
-#define SHA512_0_15(i, a, b, c, d, e, f, g, h)			\
-	t1 = h + e1(e) + Ch(e, f, g) + sha512_K[i] + W[i];	\
-	t2 = e0(a) + Maj(a, b, c);				\
-	d += t1;						\
-	h = t1 + t2
-
-#define SHA512_16_79(i, a, b, c, d, e, f, g, h)			\
-	BLEND_OP(i, W);						\
-	t1 = h + e1(e) + Ch(e, f, g) + sha512_K[i] + W[(i)&15];	\
-	t2 = e0(a) + Maj(a, b, c);				\
-	d += t1;						\
-	h = t1 + t2
-
-	for (i = 0; i < 16; i += 8) {
-		SHA512_0_15(i, a, b, c, d, e, f, g, h);
-		SHA512_0_15(i + 1, h, a, b, c, d, e, f, g);
-		SHA512_0_15(i + 2, g, h, a, b, c, d, e, f);
-		SHA512_0_15(i + 3, f, g, h, a, b, c, d, e);
-		SHA512_0_15(i + 4, e, f, g, h, a, b, c, d);
-		SHA512_0_15(i + 5, d, e, f, g, h, a, b, c);
-		SHA512_0_15(i + 6, c, d, e, f, g, h, a, b);
-		SHA512_0_15(i + 7, b, c, d, e, f, g, h, a);
-	}
-	for (i = 16; i < 80; i += 8) {
-		SHA512_16_79(i, a, b, c, d, e, f, g, h);
-		SHA512_16_79(i + 1, h, a, b, c, d, e, f, g);
-		SHA512_16_79(i + 2, g, h, a, b, c, d, e, f);
-		SHA512_16_79(i + 3, f, g, h, a, b, c, d, e);
-		SHA512_16_79(i + 4, e, f, g, h, a, b, c, d);
-		SHA512_16_79(i + 5, d, e, f, g, h, a, b, c);
-		SHA512_16_79(i + 6, c, d, e, f, g, h, a, b);
-		SHA512_16_79(i + 7, b, c, d, e, f, g, h, a);
+	/* now iterate */
+	for (i=0; i<80; i+=8) {
+		if (!(i & 8)) {
+			int j;
+
+			if (i < 16) {
+				/* load the input */
+				for (j = 0; j < 16; j++)
+					LOAD_OP(i + j, W, input);
+			} else {
+				for (j = 0; j < 16; j++) {
+					BLEND_OP(i + j, W);
+				}
+			}
+		}
+
+		t1 = h + e1(e) + Ch(e,f,g) + sha512_K[i  ] + W[(i & 15)];
+		t2 = e0(a) + Maj(a,b,c);    d+=t1;    h=t1+t2;
+		t1 = g + e1(d) + Ch(d,e,f) + sha512_K[i+1] + W[(i & 15) + 1];
+		t2 = e0(h) + Maj(h,a,b);    c+=t1;    g=t1+t2;
+		t1 = f + e1(c) + Ch(c,d,e) + sha512_K[i+2] + W[(i & 15) + 2];
+		t2 = e0(g) + Maj(g,h,a);    b+=t1;    f=t1+t2;
+		t1 = e + e1(b) + Ch(b,c,d) + sha512_K[i+3] + W[(i & 15) + 3];
+		t2 = e0(f) + Maj(f,g,h);    a+=t1;    e=t1+t2;
+		t1 = d + e1(a) + Ch(a,b,c) + sha512_K[i+4] + W[(i & 15) + 4];
+		t2 = e0(e) + Maj(e,f,g);    h+=t1;    d=t1+t2;
+		t1 = c + e1(h) + Ch(h,a,b) + sha512_K[i+5] + W[(i & 15) + 5];
+		t2 = e0(d) + Maj(d,e,f);    g+=t1;    c=t1+t2;
+		t1 = b + e1(g) + Ch(g,h,a) + sha512_K[i+6] + W[(i & 15) + 6];
+		t2 = e0(c) + Maj(c,d,e);    f+=t1;    b=t1+t2;
+		t1 = a + e1(f) + Ch(f,g,h) + sha512_K[i+7] + W[(i & 15) + 7];
+		t2 = e0(b) + Maj(b,c,d);    e+=t1;    a=t1+t2;
 	}
 
 	state[0] += a; state[1] += b; state[2] += c; state[3] += d;

Thanks!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
