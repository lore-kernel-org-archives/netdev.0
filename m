From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 2/3] sha512: reduce stack usage to safe number
Date: Sat, 14 Jan 2012 23:41:27 +0300
Message-ID: <20120114204127.GA4100@p183.telecom.by>
References: <20120113070813.GA20068@gondor.apana.org.au>
 <1326450942.2272.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1326451301.2272.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1326452246.2272.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CACVxJT9FOYdRFZJ0WRe+5ty4t4XLwgHKWaoZBWB+Zjm-yCEMEA@mail.gmail.com>
 <1326458053.3826.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20120114182024.GA4207@p183.telecom.by>
 <20120114182737.GB4207@p183.telecom.by>
 <20120114184057.GA5516@p183.telecom.by>
 <CA+55aFziQSzTpfnxQ+k83Ui-65TDHu5GZFoJhhPoR504K_d7pw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	ken@codelabs.ch, Steffen Klassert <steffen.klassert@secunet.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, security@kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFziQSzTpfnxQ+k83Ui-65TDHu5GZFoJhhPoR504K_d7pw@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 14, 2012 at 11:08:45AM -0800, Linus Torvalds wrote:
> On Sat, Jan 14, 2012 at 10:40 AM, Alexey Dobriyan <adobriyan@gmail.co=
m> wrote:
> >
> > Line by line explanation:
> > * BLEND_OP
> > =A0array is "circular" now, all indexes have to be modulo 16.
> > =A0Round number is positive, so remainder operation should be
> > =A0without surprises.
>=20
> Don't use "%" except on unsigned values. Even if it's positive, if
> it's a signed number and the compiler doesn't *see* that it is
> absolutely positive, division is nontrivial. Even when you divide by =
a
> constant.
>=20
> For example, "% 16" on an 'int' on x86-64 will generate
>=20
> 	movl	%edi, %edx
> 	sarl	$31, %edx
> 	shrl	$28, %edx
> 	leal	(%rdi,%rdx), %eax
> 	andl	$15, %eax
> 	subl	%edx, %eax
>=20
> in order to get the signed case right. The fact that the end result i=
s
> correct for unsigned numbers is irrelevant: it's still stupid and
> slow.
>=20
> With an unsigned int, '% 16' will generate the obvious
>=20
> 	andl	$15, %eax
>=20
> instead.
>=20
> Quite frankly, stop using division in the first place. Dividing by
> powers-of-two and expecting the compiler to fix things up is just
> stupid, *exactly* because of issues like these: you either have to
> think about it carefully, or the compiler may end up creating crap
> code.

=46or the record, it generates "andl $15" here.

> So just use "& 15" instead. That doesn't have these kinds of issues.
> It is a *good* thing when the C code is close to the end result you
> want to generate. It is *not* a good thing to write code that looks
> nothing like the end result and just expect the compiler to do the
> right thing. Even if the compiler does do the right thing, what was
> the advantage?

Here is updated patch which explicitly uses & (equally tested):
---------------------------------------------------------------

=46or rounds 16--79, W[i] only depends on W[i - 2], W[i - 7], W[i - 15]
and W[i - 16]. Consequently, keeping all W[80] array on stack is
unnecessary, only 16 values are really needed.

Using W[16] instead of W[80] greatly reduces stack usage
(~750 bytes to ~340 bytes on x86_64).

Line by line explanation:
* BLEND_OP
  array is "circular" now, all indexes have to be modulo 16.

* initial full message scheduling is trimmed to first 16 values which
  come from data block, the rest is calculated right before it's needed=
=2E

* original loop body is unrolled version of new SHA512_0_15 and
  SHA512_16_79 macros, unrolling was done to not do explicit variable
  renaming. Otherwise it's the very same code after preprocessing.
  See sha1_transform() code which does the same trick.

Patch survives in-tree crypto test and original bugreport test
(ping flood with hmac(sha512).

See FIPS 180-2 for SHA-512 definition
http://csrc.nist.gov/publications/fips/fips180-2/fips180-2withchangenot=
ice.pdf

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
Cc: stable@vger.kernel.org
---

 This is patch is for stable if 750 byte stack usage is not
 considered safe.

 crypto/sha512_generic.c |   58 ++++++++++++++++++++++++++++-----------=
---------
 1 file changed, 34 insertions(+), 24 deletions(-)

--- a/crypto/sha512_generic.c
+++ b/crypto/sha512_generic.c
@@ -78,7 +78,7 @@ static inline void LOAD_OP(int I, u64 *W, const u8 *i=
nput)
=20
 static inline void BLEND_OP(int I, u64 *W)
 {
-	W[I] =3D s1(W[I-2]) + W[I-7] + s0(W[I-15]) + W[I-16];
+	W[I & 15] +=3D s1(W[(I-2) & 15]) + W[(I-7) & 15] + s0(W[(I-15) & 15])=
;
 }
=20
 static void
@@ -87,38 +87,48 @@ sha512_transform(u64 *state, const u8 *input)
 	u64 a, b, c, d, e, f, g, h, t1, t2;
=20
 	int i;
-	u64 W[80];
+	u64 W[16];
=20
 	/* load the input */
         for (i =3D 0; i < 16; i++)
                 LOAD_OP(i, W, input);
=20
-        for (i =3D 16; i < 80; i++) {
-                BLEND_OP(i, W);
-        }
-
 	/* load the state into our registers */
 	a=3Dstate[0];   b=3Dstate[1];   c=3Dstate[2];   d=3Dstate[3];
 	e=3Dstate[4];   f=3Dstate[5];   g=3Dstate[6];   h=3Dstate[7];
=20
-	/* now iterate */
-	for (i=3D0; i<80; i+=3D8) {
-		t1 =3D h + e1(e) + Ch(e,f,g) + sha512_K[i  ] + W[i  ];
-		t2 =3D e0(a) + Maj(a,b,c);    d+=3Dt1;    h=3Dt1+t2;
-		t1 =3D g + e1(d) + Ch(d,e,f) + sha512_K[i+1] + W[i+1];
-		t2 =3D e0(h) + Maj(h,a,b);    c+=3Dt1;    g=3Dt1+t2;
-		t1 =3D f + e1(c) + Ch(c,d,e) + sha512_K[i+2] + W[i+2];
-		t2 =3D e0(g) + Maj(g,h,a);    b+=3Dt1;    f=3Dt1+t2;
-		t1 =3D e + e1(b) + Ch(b,c,d) + sha512_K[i+3] + W[i+3];
-		t2 =3D e0(f) + Maj(f,g,h);    a+=3Dt1;    e=3Dt1+t2;
-		t1 =3D d + e1(a) + Ch(a,b,c) + sha512_K[i+4] + W[i+4];
-		t2 =3D e0(e) + Maj(e,f,g);    h+=3Dt1;    d=3Dt1+t2;
-		t1 =3D c + e1(h) + Ch(h,a,b) + sha512_K[i+5] + W[i+5];
-		t2 =3D e0(d) + Maj(d,e,f);    g+=3Dt1;    c=3Dt1+t2;
-		t1 =3D b + e1(g) + Ch(g,h,a) + sha512_K[i+6] + W[i+6];
-		t2 =3D e0(c) + Maj(c,d,e);    f+=3Dt1;    b=3Dt1+t2;
-		t1 =3D a + e1(f) + Ch(f,g,h) + sha512_K[i+7] + W[i+7];
-		t2 =3D e0(b) + Maj(b,c,d);    e+=3Dt1;    a=3Dt1+t2;
+#define SHA512_0_15(i, a, b, c, d, e, f, g, h)			\
+	t1 =3D h + e1(e) + Ch(e, f, g) + sha512_K[i] + W[i];	\
+	t2 =3D e0(a) + Maj(a, b, c);				\
+	d +=3D t1;						\
+	h =3D t1 + t2
+
+#define SHA512_16_79(i, a, b, c, d, e, f, g, h)			\
+	BLEND_OP(i, W);						\
+	t1 =3D h + e1(e) + Ch(e, f, g) + sha512_K[i] + W[(i)&15];	\
+	t2 =3D e0(a) + Maj(a, b, c);				\
+	d +=3D t1;						\
+	h =3D t1 + t2
+
+	for (i =3D 0; i < 16; i +=3D 8) {
+		SHA512_0_15(i, a, b, c, d, e, f, g, h);
+		SHA512_0_15(i + 1, h, a, b, c, d, e, f, g);
+		SHA512_0_15(i + 2, g, h, a, b, c, d, e, f);
+		SHA512_0_15(i + 3, f, g, h, a, b, c, d, e);
+		SHA512_0_15(i + 4, e, f, g, h, a, b, c, d);
+		SHA512_0_15(i + 5, d, e, f, g, h, a, b, c);
+		SHA512_0_15(i + 6, c, d, e, f, g, h, a, b);
+		SHA512_0_15(i + 7, b, c, d, e, f, g, h, a);
+	}
+	for (i =3D 16; i < 80; i +=3D 8) {
+		SHA512_16_79(i, a, b, c, d, e, f, g, h);
+		SHA512_16_79(i + 1, h, a, b, c, d, e, f, g);
+		SHA512_16_79(i + 2, g, h, a, b, c, d, e, f);
+		SHA512_16_79(i + 3, f, g, h, a, b, c, d, e);
+		SHA512_16_79(i + 4, e, f, g, h, a, b, c, d);
+		SHA512_16_79(i + 5, d, e, f, g, h, a, b, c);
+		SHA512_16_79(i + 6, c, d, e, f, g, h, a, b);
+		SHA512_16_79(i + 7, b, c, d, e, f, g, h, a);
 	}
=20
 	state[0] +=3D a; state[1] +=3D b; state[2] +=3D c; state[3] +=3D d;
