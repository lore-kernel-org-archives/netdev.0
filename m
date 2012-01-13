From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: sha512: make it work, undo percpu message schedule
Date: Fri, 13 Jan 2012 13:34:13 +0100
Message-ID: <1326458053.3826.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20120111000040.GA3801@p183.telecom.by>
	 <20120111003611.GA12257@gondor.apana.org.au>
	 <20120112235514.GA5065@p183.telecom.by>
	 <20120113070813.GA20068@gondor.apana.org.au>
	 <1326450942.2272.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1326451301.2272.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1326452246.2272.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CACVxJT9FOYdRFZJ0WRe+5ty4t4XLwgHKWaoZBWB+Zjm-yCEMEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	ken@codelabs.ch, Steffen Klassert <steffen.klassert@secunet.com>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CACVxJT9FOYdRFZJ0WRe+5ty4t4XLwgHKWaoZBWB+Zjm-yCEMEA@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 13 janvier 2012 =C3=A0 13:33 +0200, Alexey Dobriyan a =C3=A9=
crit :
> On 1/13/12, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > +	static u64 msg_schedule[80];
> > +	static DEFINE_SPINLOCK(msg_schedule_lock);
>=20
> No guys, no.
>=20
> SHA-512 only needs u64[16] running window for message scheduling.
>=20
> I'm sending whitespace mangled patch which is only tested
> with selfcryptotest passed, so you won't apply something complex.
>=20
> Stackspace usage drops down to like this:
>=20
>     -139:   48 81 ec c8 02 00 00    sub    $0x2c8,%rsp
>     +136:       48 81 ec 18 01 00 00    sub    $0x118,%rsp
>=20
> --- a/crypto/sha512_generic.c
> +++ b/crypto/sha512_generic.c
> @@ -21,8 +21,6 @@
>  #include <linux/percpu.h>
>  #include <asm/byteorder.h>
>=20
> -static DEFINE_PER_CPU(u64[80], msg_schedule);
> -
>  static inline u64 Ch(u64 x, u64 y, u64 z)
>  {
>          return z ^ (x & (y ^ z));
> @@ -80,7 +78,7 @@ static inline void LOAD_OP(int I, u64 *W, const u8 =
*input)
>=20
>  static inline void BLEND_OP(int I, u64 *W)
>  {
> -	W[I] =3D s1(W[I-2]) + W[I-7] + s0(W[I-15]) + W[I-16];
> +	W[I%16] =3D s1(W[(I-2)%16]) + W[(I-7)%16] + s0(W[(I-15)%16]) + W[I%=
16];
>  }
>=20
>  static void
> @@ -89,38 +87,48 @@ sha512_transform(u64 *state, const u8 *input)
>  	u64 a, b, c, d, e, f, g, h, t1, t2;
>=20
>  	int i;
> -	u64 *W =3D get_cpu_var(msg_schedule);
> +	u64 W[16];
>=20
>  	/* load the input */
>          for (i =3D 0; i < 16; i++)
>                  LOAD_OP(i, W, input);
>=20
> -        for (i =3D 16; i < 80; i++) {
> -                BLEND_OP(i, W);
> -        }
> -
>  	/* load the state into our registers */
>  	a=3Dstate[0];   b=3Dstate[1];   c=3Dstate[2];   d=3Dstate[3];
>  	e=3Dstate[4];   f=3Dstate[5];   g=3Dstate[6];   h=3Dstate[7];
>=20
> -	/* now iterate */
> -	for (i=3D0; i<80; i+=3D8) {
> -		t1 =3D h + e1(e) + Ch(e,f,g) + sha512_K[i  ] + W[i  ];
> -		t2 =3D e0(a) + Maj(a,b,c);    d+=3Dt1;    h=3Dt1+t2;
> -		t1 =3D g + e1(d) + Ch(d,e,f) + sha512_K[i+1] + W[i+1];
> -		t2 =3D e0(h) + Maj(h,a,b);    c+=3Dt1;    g=3Dt1+t2;
> -		t1 =3D f + e1(c) + Ch(c,d,e) + sha512_K[i+2] + W[i+2];
> -		t2 =3D e0(g) + Maj(g,h,a);    b+=3Dt1;    f=3Dt1+t2;
> -		t1 =3D e + e1(b) + Ch(b,c,d) + sha512_K[i+3] + W[i+3];
> -		t2 =3D e0(f) + Maj(f,g,h);    a+=3Dt1;    e=3Dt1+t2;
> -		t1 =3D d + e1(a) + Ch(a,b,c) + sha512_K[i+4] + W[i+4];
> -		t2 =3D e0(e) + Maj(e,f,g);    h+=3Dt1;    d=3Dt1+t2;
> -		t1 =3D c + e1(h) + Ch(h,a,b) + sha512_K[i+5] + W[i+5];
> -		t2 =3D e0(d) + Maj(d,e,f);    g+=3Dt1;    c=3Dt1+t2;
> -		t1 =3D b + e1(g) + Ch(g,h,a) + sha512_K[i+6] + W[i+6];
> -		t2 =3D e0(c) + Maj(c,d,e);    f+=3Dt1;    b=3Dt1+t2;
> -		t1 =3D a + e1(f) + Ch(f,g,h) + sha512_K[i+7] + W[i+7];
> -		t2 =3D e0(b) + Maj(b,c,d);    e+=3Dt1;    a=3Dt1+t2;
> +#define SHA512_0_15(i, a, b, c, d, e, f, g, h)			\
> +	t1 =3D h + e1(e) + Ch(e, f, g) + sha512_K[i] + W[i];	\
> +	t2 =3D e0(a) + Maj(a,b,c);				\
> +	d +=3D t1;						\
> +	h =3D t1 + t2
> +
> +#define SHA512_16_79(i, a, b, c, d, e, f, g, h)			\
> +	BLEND_OP(i, W);						\
> +	t1 =3D h + e1(e) + Ch(e, f, g) + sha512_K[i] + W[(i)%16];	\
> +	t2 =3D e0(a) + Maj(a,b,c);				\
> +	d +=3D t1;						\
> +	h =3D t1 + t2
> +
> +	for (i =3D 0; i < 16; i +=3D 8) {
> +		SHA512_0_15(i, a, b, c, d, e, f, g, h);
> +		SHA512_0_15(i + 1, h, a, b, c, d, e, f, g);
> +		SHA512_0_15(i + 2, g, h, a, b, c, d, e, f);
> +		SHA512_0_15(i + 3, f, g, h, a, b, c, d, e);
> +		SHA512_0_15(i + 4, e, f, g, h, a, b, c, d);
> +		SHA512_0_15(i + 5, d, e, f, g, h, a, b, c);
> +		SHA512_0_15(i + 6, c, d, e, f, g, h, a, b);
> +		SHA512_0_15(i + 7, b, c, d, e, f, g, h, a);
> +	}
> +	for (i =3D 16; i < 80; i +=3D 8) {
> +		SHA512_16_79(i, a, b, c, d, e, f, g, h);
> +		SHA512_16_79(i + 1, h, a, b, c, d, e, f, g);
> +		SHA512_16_79(i + 2, g, h, a, b, c, d, e, f);
> +		SHA512_16_79(i + 3, f, g, h, a, b, c, d, e);
> +		SHA512_16_79(i + 4, e, f, g, h, a, b, c, d);
> +		SHA512_16_79(i + 5, d, e, f, g, h, a, b, c);
> +		SHA512_16_79(i + 6, c, d, e, f, g, h, a, b);
> +		SHA512_16_79(i + 7, b, c, d, e, f, g, h, a);
>  	}
>=20
>  	state[0] +=3D a; state[1] +=3D b; state[2] +=3D c; state[3] +=3D d;
> @@ -128,8 +136,6 @@ sha512_transform(u64 *state, const u8 *input)
>=20
>  	/* erase our data */
>  	a =3D b =3D c =3D d =3D e =3D f =3D g =3D h =3D t1 =3D t2 =3D 0;
> -	memset(W, 0, sizeof(__get_cpu_var(msg_schedule)));
> -	put_cpu_var(msg_schedule);
>  }
>=20
>  static int


Even if its true, its not stable material.

stable teams want obvious patches.
