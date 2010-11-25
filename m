From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] The new jhash implementation
Date: Thu, 25 Nov 2010 18:21:09 +0100
Message-ID: <1290705669.2858.381.camel@edumazet-laptop>
References: <1290690908-794-1-git-send-email-kadlec@blackhole.kfki.hu>
	 <1290690908-794-2-git-send-email-kadlec@blackhole.kfki.hu>
	 <1290690908-794-3-git-send-email-kadlec@blackhole.kfki.hu>
	 <1290692943.2858.303.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1011251520270.1198@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Linus Torvalds <torvalds@osdl.org>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1011251520270.1198@blackhole.kfki.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 25 novembre 2010 =C3=A0 15:41 +0100, Jozsef Kadlecsik a =C3=A9=
crit :

=2E..

> +/* __jhash_mix -- mix 3 32-bit values reversibly. */
> +#define __jhash_mix(a, b, c)			\
> +{						\
> +	a -=3D c;  a ^=3D rol32(c, 4);  c +=3D b;	\
> +	b -=3D a;  b ^=3D rol32(a, 6);  a +=3D c;	\
> +	c -=3D b;  c ^=3D rol32(b, 8);  b +=3D a;	\
> +	a -=3D c;  a ^=3D rol32(c, 16); c +=3D b;	\
> +	b -=3D a;  b ^=3D rol32(a, 19); a +=3D c;	\
> +	c -=3D b;  c ^=3D rol32(b, 4);  b +=3D a;	\
> +}
> +
> +/* __jhash_final - final mixing of 3 32-bit values (a,b,c) into c */
> +#define __jhash_final(a, b, c)			\
> +{						\
> +	c ^=3D b; c -=3D rol32(b, 14);		\
> +	a ^=3D c; a -=3D rol32(c, 11);		\
> +	b ^=3D a; b -=3D rol32(a, 25);		\
> +	c ^=3D b; c -=3D rol32(b, 16);		\
> +	a ^=3D c; a -=3D rol32(c, 4);		\
> +	b ^=3D a; b -=3D rol32(a, 14);		\
> +	c ^=3D b; c -=3D rol32(b, 24);		\
> +}
> +

So we now have a special __jhash_final(a, b, c) thing for the last
values.



> +/* jhash_3words - hash exactly 3, 2 or 1 word(s) */
> +u32 jhash_3words(u32 a, u32 b, u32 c, u32 initval)
> +{
> +	a +=3D JHASH_INITVAL;
> +	b +=3D JHASH_INITVAL;
> +	c +=3D initval;
> +
> +	__jhash_mix(a, b, c);
> +
> +	return c;
> +}
> +EXPORT_SYMBOL(jhash_3words);


But you dont use it in jhash_3words().


I do think jhash_3words() should stay inlined, unless maybe
CONFIG_CC_OPTIMIZE_FOR_SIZE=3Dy

We hit it several time per packet in network stack in RX path.

Once in skb_get_rxhash() (unless device fills skb->rxhash)
Once at least in conntrack (if used).
Once in UDP or TCP stack



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
