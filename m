From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] The new jhash implementation
Date: Thu, 25 Nov 2010 14:49:03 +0100
Message-ID: <1290692943.2858.303.camel@edumazet-laptop>
References: <1290690908-794-1-git-send-email-kadlec@blackhole.kfki.hu>
	 <1290690908-794-2-git-send-email-kadlec@blackhole.kfki.hu>
	 <1290690908-794-3-git-send-email-kadlec@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Linus Torvalds <torvalds@osdl.org>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1290690908-794-3-git-send-email-kadlec@blackhole.kfki.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 25 novembre 2010 =C3=A0 14:15 +0100, Jozsef Kadlecsik a =C3=A9=
crit :
> The current jhash.h implements the lookup2() hash function by Bob Jen=
kins.
> However, lookup2() is outdated as Bob wrote a new hash function calle=
d
> lookup3(). The new hash function
>=20
> - mixes better than lookup2(): it passes the check that every input b=
it
>   changes every output bit 50% of the time, while lookup2() failed it=
=2E
> - performs better: compiled with -O2 on Core2 Duo, lookup3() 20-40% f=
aster
>   than lookup2() depending on the key length.
>=20
> The patch replaces the lookup2() implementation of the 'jhash*'
> functions with that of lookup3().
>=20
> You can read a longer comparison of the two and other hash functions =
at
> http://burtleburtle.net/bob/hash/doobs.html.
>=20
> Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
> ---
>  include/linux/jhash.h |  136 +++------------------------------------=
-----
>  lib/Makefile          |    2 +-
>  lib/jhash.c           |  153 +++++++++++++++++++++++++++++++++++++++=
++++++++++
>  3 files changed, 162 insertions(+), 129 deletions(-)
>  create mode 100644 lib/jhash.c
>=20
=2E..

I agree jhash() should be not be inlined.

I am not sure for other variants.

> +u32 jhash(const void *key, u32 length, u32 initval)
> +{
> +	u32 a, b, c;
> +	const u8 *k =3D key;
> +
> +	/* Set up the internal state */
> +	a =3D b =3D c =3D JHASH_INITVAL + length + initval;
> +
> +	/* All but the last block: affect some 32 bits of (a,b,c) */
> +	while (length > 12) {
> +		a +=3D k[0] + ((u32)k[1]<<8) + ((u32)k[2]<<16) + ((u32)k[3]<<24);

disassembly code on x86_32 for the previous line :

  26:	66 90                	xchg   %ax,%ax
  28:	0f b6 72 01          	movzbl 0x1(%edx),%esi
  2c:	0f b6 4a 02          	movzbl 0x2(%edx),%ecx
  30:	c1 e6 08             	shl    $0x8,%esi
  33:	c1 e1 10             	shl    $0x10,%ecx
  36:	8d 0c 0e             	lea    (%esi,%ecx,1),%ecx
  39:	0f b6 32             	movzbl (%edx),%esi
  3c:	8d 34 31             	lea    (%ecx,%esi,1),%esi
  3f:	0f b6 4a 03          	movzbl 0x3(%edx),%ecx
  43:	c1 e1 18             	shl    $0x18,%ecx
  46:	8d 0c 0e             	lea    (%esi,%ecx,1),%ecx

or (CONFIG_CC_OPTIMIZE_FOR_SIZE=3Dy) :

  1b:	0f b6 7b 01          	movzbl 0x1(%ebx),%edi
  1f:	c1 e7 08             	shl    $0x8,%edi
  22:	89 7d f0             	mov    %edi,-0x10(%ebp)
  25:	0f b6 7b 02          	movzbl 0x2(%ebx),%edi
  29:	c1 e7 10             	shl    $0x10,%edi
  2c:	03 7d f0             	add    -0x10(%ebp),%edi
  2f:	89 7d f0             	mov    %edi,-0x10(%ebp)
  32:	0f b6 3b             	movzbl (%ebx),%edi
  35:	03 7d f0             	add    -0x10(%ebp),%edi
  38:	89 7d f0             	mov    %edi,-0x10(%ebp)
  3b:	0f b6 7b 03          	movzbl 0x3(%ebx),%edi
  3f:	c1 e7 18             	shl    $0x18,%edi
  42:	03 7d f0             	add    -0x10(%ebp),%edi


I suggest :

#include <linux/unaligned/packed_struct.h>
=2E..
	a +=3D __get_unaligned_cpu32(k);
	b +=3D __get_unaligned_cpu32(k+4);
	c +=3D __get_unaligned_cpu32(k+8);

=46its nicely in registers.
=20



> +		b +=3D k[4] + ((u32)k[5]<<8) + ((u32)k[6]<<16) + ((u32)k[7]<<24);
> +		c +=3D k[8] + ((u32)k[9]<<8) + ((u32)k[10]<<16) + ((u32)k[11]<<24)=
;
> +		__jhash_mix(a, b, c);
> +		length -=3D 12;
> +		k +=3D 12;
> +	}
> +	/* Last block: affect all 32 bits of (c) */
> +	/* All the case statements fall through */
> +	switch (length) {
> +	case 12: c +=3D (u32)k[11]<<24;
> +	case 11: c +=3D (u32)k[10]<<16;
> +	case 10: c +=3D (u32)k[9]<<8;
> +	case 9:  c +=3D k[8];
> +	case 8:  b +=3D (u32)k[7]<<24;
> +	case 7:  b +=3D (u32)k[6]<<16;
> +	case 6:  b +=3D (u32)k[5]<<8;
> +	case 5:  b +=3D k[4];
> +	case 4:  a +=3D (u32)k[3]<<24;
> +	case 3:  a +=3D (u32)k[2]<<16;
> +	case 2:  a +=3D (u32)k[1]<<8;
> +	case 1:  a +=3D k[0];
> +		 __jhash_final(a, b, c);
> +	case 0: /* Nothing left to add */
> +		break;
> +	}
> +
> +	return c;
> +}
> +EXPORT_SYMBOL(jhash);
