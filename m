From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 4/3] sha512: reduce stack usage even on i386
Date: Mon, 30 Jan 2012 13:10:48 +0200
Message-ID: <CACVxJT8phQxQHSBDJ_zOzdO9QVMmVK=v-mFTac2gn9+xZZSQkQ@mail.gmail.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AF43@saturn3.aculab.com>
	<1326709382.2255.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CACVxJT_cZAdxNOFTpK5seUXFZU+YB3zbe6LF1nnyzo32ae14xw@mail.gmail.com>
	<20120118180210.GA22733@p183.telecom.by>
	<20120126023502.GA10696@gondor.apana.org.au>
	<20120127175130.GA742@p183.telecom.by>
	<20120127223250.GA9384@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Laight <David.Laight@aculab.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	ken@codelabs.ch, Steffen Klassert <steffen.klassert@secunet.com>,
	security@kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20120127223250.GA9384@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/28/12, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Fri, Jan 27, 2012 at 08:51:30PM +0300, Alexey Dobriyan wrote:
>>
>> I think this is because your tree contained "%16" code instead if "&15".
>> Now that it contains "&15" it should become applicable.
>
> OK.
>
>> --------------------------------------------------------------------------
>> [PATCH] sha512: reduce stack usage even on i386
>
> Can you try the approach that git takes with using asm to read
> and write W (see previous email from Linus in respone to my push
> request)? As it stands your patch is simply relying on gcc's
> ability to optimise.  At least with asm volatile we know that
> gcc will leave it alone.

For some reason it doesn't. :-( I've also tried full barriers.

With this patch, stack usage is still ~900 bytes.

diff --git a/crypto/sha512_generic.c b/crypto/sha512_generic.c
index dd0439d..35e7ae7 100644
--- a/crypto/sha512_generic.c
+++ b/crypto/sha512_generic.c
@@ -66,16 +66,6 @@ static const u64 sha512_K[80] = {
 #define s0(x)       (ror64(x, 1) ^ ror64(x, 8) ^ (x >> 7))
 #define s1(x)       (ror64(x,19) ^ ror64(x,61) ^ (x >> 6))

-static inline void LOAD_OP(int I, u64 *W, const u8 *input)
-{
-	W[I] = __be64_to_cpu( ((__be64*)(input))[I] );
-}
-
-static inline void BLEND_OP(int I, u64 *W)
-{
-	W[I & 15] += s1(W[(I-2) & 15]) + W[(I-7) & 15] + s0(W[(I-15) & 15]);
-}
-
 static void
 sha512_transform(u64 *state, const u8 *input)
 {
@@ -84,26 +74,29 @@ sha512_transform(u64 *state, const u8 *input)
 	int i;
 	u64 W[16];

-	/* load the input */
-        for (i = 0; i < 16; i++)
-                LOAD_OP(i, W, input);
-
 	/* load the state into our registers */
 	a=state[0];   b=state[1];   c=state[2];   d=state[3];
 	e=state[4];   f=state[5];   g=state[6];   h=state[7];

 #define SHA512_0_15(i, a, b, c, d, e, f, g, h)			\
-	t1 = h + e1(e) + Ch(e, f, g) + sha512_K[i] + W[i];	\
+	{							\
+	u64 tmp = be64_to_cpu(*((__be64 *)input + (i)));	\
+	*(volatile u64 *)&W[i] = tmp;				\
+	t1 = h + e1(e) + Ch(e, f, g) + sha512_K[i] + tmp;	\
 	t2 = e0(a) + Maj(a, b, c);				\
 	d += t1;						\
-	h = t1 + t2
+	h = t1 + t2;						\
+	}

 #define SHA512_16_79(i, a, b, c, d, e, f, g, h)			\
-	BLEND_OP(i, W);						\
-	t1 = h + e1(e) + Ch(e, f, g) + sha512_K[i] + W[(i)&15];\
+	{							\
+	u64 tmp = W[(i) & 15] + s1(W[(i-2) & 15]) + W[(i-7) & 15] +
s0(W[(i-15) & 15]);\
+	*(volatile u64 *)&W[(i) & 15] = tmp;			\
+	t1 = h + e1(e) + Ch(e, f, g) + sha512_K[i] + tmp;	\
 	t2 = e0(a) + Maj(a, b, c);				\
 	d += t1;						\
-	h = t1 + t2
+	h = t1 + t2;						\
+	}

 	for (i = 0; i < 16; i += 8) {
 		SHA512_0_15(i, a, b, c, d, e, f, g, h);
