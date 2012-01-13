From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: sha512: make it work, undo percpu message schedule
Date: Fri, 13 Jan 2012 13:33:43 +0200
Message-ID: <CACVxJT9FOYdRFZJ0WRe+5ty4t4XLwgHKWaoZBWB+Zjm-yCEMEA@mail.gmail.com>
References: <20120111000040.GA3801@p183.telecom.by>
	<20120111003611.GA12257@gondor.apana.org.au>
	<20120112235514.GA5065@p183.telecom.by>
	<20120113070813.GA20068@gondor.apana.org.au>
	<1326450942.2272.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1326451301.2272.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1326452246.2272.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	ken@codelabs.ch, Steffen Klassert <steffen.klassert@secunet.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1326452246.2272.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/13/12, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> +	static u64 msg_schedule[80];
> +	static DEFINE_SPINLOCK(msg_schedule_lock);

No guys, no.

SHA-512 only needs u64[16] running window for message scheduling.

I'm sending whitespace mangled patch which is only tested
with selfcryptotest passed, so you won't apply something complex.

Stackspace usage drops down to like this:

    -139:   48 81 ec c8 02 00 00    sub    $0x2c8,%rsp
    +136:       48 81 ec 18 01 00 00    sub    $0x118,%rsp

--- a/crypto/sha512_generic.c
+++ b/crypto/sha512_generic.c
@@ -21,8 +21,6 @@
 #include <linux/percpu.h>
 #include <asm/byteorder.h>

-static DEFINE_PER_CPU(u64[80], msg_schedule);
-
 static inline u64 Ch(u64 x, u64 y, u64 z)
 {
         return z ^ (x & (y ^ z));
@@ -80,7 +78,7 @@ static inline void LOAD_OP(int I, u64 *W, const u8 *input)

 static inline void BLEND_OP(int I, u64 *W)
 {
-	W[I] = s1(W[I-2]) + W[I-7] + s0(W[I-15]) + W[I-16];
+	W[I%16] = s1(W[(I-2)%16]) + W[(I-7)%16] + s0(W[(I-15)%16]) + W[I%16];
 }

 static void
@@ -89,38 +87,48 @@ sha512_transform(u64 *state, const u8 *input)
 	u64 a, b, c, d, e, f, g, h, t1, t2;

 	int i;
-	u64 *W = get_cpu_var(msg_schedule);
+	u64 W[16];

 	/* load the input */
         for (i = 0; i < 16; i++)
                 LOAD_OP(i, W, input);

-        for (i = 16; i < 80; i++) {
-                BLEND_OP(i, W);
-        }
-
 	/* load the state into our registers */
 	a=state[0];   b=state[1];   c=state[2];   d=state[3];
 	e=state[4];   f=state[5];   g=state[6];   h=state[7];

-	/* now iterate */
-	for (i=0; i<80; i+=8) {
-		t1 = h + e1(e) + Ch(e,f,g) + sha512_K[i  ] + W[i  ];
-		t2 = e0(a) + Maj(a,b,c);    d+=t1;    h=t1+t2;
-		t1 = g + e1(d) + Ch(d,e,f) + sha512_K[i+1] + W[i+1];
-		t2 = e0(h) + Maj(h,a,b);    c+=t1;    g=t1+t2;
-		t1 = f + e1(c) + Ch(c,d,e) + sha512_K[i+2] + W[i+2];
-		t2 = e0(g) + Maj(g,h,a);    b+=t1;    f=t1+t2;
-		t1 = e + e1(b) + Ch(b,c,d) + sha512_K[i+3] + W[i+3];
-		t2 = e0(f) + Maj(f,g,h);    a+=t1;    e=t1+t2;
-		t1 = d + e1(a) + Ch(a,b,c) + sha512_K[i+4] + W[i+4];
-		t2 = e0(e) + Maj(e,f,g);    h+=t1;    d=t1+t2;
-		t1 = c + e1(h) + Ch(h,a,b) + sha512_K[i+5] + W[i+5];
-		t2 = e0(d) + Maj(d,e,f);    g+=t1;    c=t1+t2;
-		t1 = b + e1(g) + Ch(g,h,a) + sha512_K[i+6] + W[i+6];
-		t2 = e0(c) + Maj(c,d,e);    f+=t1;    b=t1+t2;
-		t1 = a + e1(f) + Ch(f,g,h) + sha512_K[i+7] + W[i+7];
-		t2 = e0(b) + Maj(b,c,d);    e+=t1;    a=t1+t2;
+#define SHA512_0_15(i, a, b, c, d, e, f, g, h)			\
+	t1 = h + e1(e) + Ch(e, f, g) + sha512_K[i] + W[i];	\
+	t2 = e0(a) + Maj(a,b,c);				\
+	d += t1;						\
+	h = t1 + t2
+
+#define SHA512_16_79(i, a, b, c, d, e, f, g, h)			\
+	BLEND_OP(i, W);						\
+	t1 = h + e1(e) + Ch(e, f, g) + sha512_K[i] + W[(i)%16];	\
+	t2 = e0(a) + Maj(a,b,c);				\
+	d += t1;						\
+	h = t1 + t2
+
+	for (i = 0; i < 16; i += 8) {
+		SHA512_0_15(i, a, b, c, d, e, f, g, h);
+		SHA512_0_15(i + 1, h, a, b, c, d, e, f, g);
+		SHA512_0_15(i + 2, g, h, a, b, c, d, e, f);
+		SHA512_0_15(i + 3, f, g, h, a, b, c, d, e);
+		SHA512_0_15(i + 4, e, f, g, h, a, b, c, d);
+		SHA512_0_15(i + 5, d, e, f, g, h, a, b, c);
+		SHA512_0_15(i + 6, c, d, e, f, g, h, a, b);
+		SHA512_0_15(i + 7, b, c, d, e, f, g, h, a);
+	}
+	for (i = 16; i < 80; i += 8) {
+		SHA512_16_79(i, a, b, c, d, e, f, g, h);
+		SHA512_16_79(i + 1, h, a, b, c, d, e, f, g);
+		SHA512_16_79(i + 2, g, h, a, b, c, d, e, f);
+		SHA512_16_79(i + 3, f, g, h, a, b, c, d, e);
+		SHA512_16_79(i + 4, e, f, g, h, a, b, c, d);
+		SHA512_16_79(i + 5, d, e, f, g, h, a, b, c);
+		SHA512_16_79(i + 6, c, d, e, f, g, h, a, b);
+		SHA512_16_79(i + 7, b, c, d, e, f, g, h, a);
 	}

 	state[0] += a; state[1] += b; state[2] += c; state[3] += d;
@@ -128,8 +136,6 @@ sha512_transform(u64 *state, const u8 *input)

 	/* erase our data */
 	a = b = c = d = e = f = g = h = t1 = t2 = 0;
-	memset(W, 0, sizeof(__get_cpu_var(msg_schedule)));
-	put_cpu_var(msg_schedule);
 }

 static int
