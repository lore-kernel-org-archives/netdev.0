From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 2/3] sha512: reduce stack usage to safe number
Date: Tue, 17 Jan 2012 14:03:09 +0200
Message-ID: <CACVxJT_cZAdxNOFTpK5seUXFZU+YB3zbe6LF1nnyzo32ae14xw@mail.gmail.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AF43@saturn3.aculab.com>
	<1326709382.2255.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Laight <David.Laight@aculab.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	ken@codelabs.ch, Steffen Klassert <steffen.klassert@secunet.com>,
	security@kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1326709382.2255.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/16/12, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Le lundi 16 janvier 2012 =E0 09:56 +0000, David Laight a =E9crit :
>> Doesn't this badly overflow W[] ..
>>
>> > +#define SHA512_0_15(i, a, b, c, d, e, f, g, h) \
>> > +	t1 =3D h + e1(e) + Ch(e, f, g) + sha512_K[i] + W[i];	\
>> ...
>> > +	for (i =3D 0; i < 16; i +=3D 8) {
>> ...
>> > +		SHA512_0_15(i + 7, b, c, d, e, f, g, h, a);
>> > +	}
>>
>> 	David
>>
>>
>
> No overflow since loop is done for only i=3D0 and i=3D8
>
> By the way, I suspect previous code was chosen years ago because this
> version uses less stack but adds much more code bloat.

I think W[80] was use because it's the most straightforward way to
write this code
by following spec.

All SHA definitions have full message schedule pseudocoded
before hash computation.

> size crypto/sha512_generic.o crypto/sha512_generic_old.o
>    text	   data	    bss	    dec	    hex	filename
>   17369	    704	      0	  18073	   4699	crypto/sha512_generic.o
>    8249	    704	      0	   8953	   22f9	crypto/sha512_generic_old.o

This is because SHA-512 is fundamentally 64-bit algorithm multiplied by
excessive unrolling.

Surprisingly, doing variable renaming by hand like in spec:
t1 =3D ...
t2 =3D ...
h =3D g;
g =3D f;
f =3D e;
e =3D d + T1;
d =3D c;
c =3D b;
b =3D a;
a =3D t1 + t2;

bring stack space on i386 under control too.
