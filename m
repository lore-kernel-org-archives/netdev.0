From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: sha512: make it work, undo percpu message schedule
Date: Fri, 13 Jan 2012 11:41:41 +0100
Message-ID: <1326451301.2272.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20120111000040.GA3801@p183.telecom.by>
	 <20120111003611.GA12257@gondor.apana.org.au>
	 <20120112235514.GA5065@p183.telecom.by>
	 <20120113070813.GA20068@gondor.apana.org.au>
	 <1326450942.2272.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	ken@codelabs.ch, Steffen Klassert <steffen.klassert@secunet.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1326450942.2272.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 13 janvier 2012 =C3=A0 11:35 +0100, Eric Dumazet a =C3=A9cr=
it :

> I wonder ...
>=20
> With 4096 cpus, do we really want to reserve 5242880 bytes of memory =
for
> this function ?
>=20
> What about following patch instead ?
>=20
> (Trying a dynamic memory allocation, and fallback on a single
> pre-allocated bloc of memory, shared by all cpus, protected by a
> spinlock)
>=20
> diff --git a/crypto/sha512_generic.c b/crypto/sha512_generic.c
> index 9ed9f60..5c80a76 100644
> --- a/crypto/sha512_generic.c
> +++ b/crypto/sha512_generic.c
> @@ -21,7 +21,6 @@
>  #include <linux/percpu.h>
>  #include <asm/byteorder.h>
> =20
> -static DEFINE_PER_CPU(u64[80], msg_schedule);
> =20
>  static inline u64 Ch(u64 x, u64 y, u64 z)
>  {
> @@ -87,10 +86,16 @@ static void
>  sha512_transform(u64 *state, const u8 *input)
>  {
>  	u64 a, b, c, d, e, f, g, h, t1, t2;
> -
> +	static u64 msg_schedule[80];
> +	static DEFINE_SPINLOCK(msg_schedule_lock);
>  	int i;
> -	u64 *W =3D get_cpu_var(msg_schedule);
> +	u64 *W =3D kzalloc(sizeof(msg_schedule), GFP_ATOMIC | __GFP_NOWARN)=
;
> =20

And a plain kmalloc() is enough, since we fully initialize the array a
bit later.

	for (i =3D 0; i < 16; i++)
		LOAD_OP(i, W, input);
	for (i =3D 16; i < 80; i++) {
		BLEND_OP(i, W);
	}
