From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: System call 'sendmsg' of process ospfd (quagga) causes
 kernel oops
Date: Tue, 18 Oct 2011 13:37:58 +0200
Message-ID: <1318937878.2657.50.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CA+0Zf5Be5JUSvssH9CrDQq=jtETZr=veAPC7jriM8B-FZKbbpg@mail.gmail.com>
	 <1318604266.2223.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CA+0Zf5A-8X5MaXC4+BbLKtMb8S8B-Ln_a3JNfz0jR4O-ruefuw@mail.gmail.com>
	 <1318905032.2571.35.camel@edumazet-laptop>
	 <20111018093411.GA15165@gondor.apana.org.au>
	 <1318932093.2657.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111018100527.GA15383@gondor.apana.org.au>
	 <1318933423.2657.44.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111018104504.GA15913@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Elmar Vonlanthen <evonlanthen@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Timo =?ISO-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111018104504.GA15913@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 18 octobre 2011 =C3=A0 12:45 +0200, Herbert Xu a =C3=A9crit :
> On Tue, Oct 18, 2011 at 12:23:43PM +0200, Eric Dumazet wrote:
> >=20
> > You're right, if reallocations are OK in all paths.
>=20
> If it wasn't OK then making needed_headroom constant won't work
> anyway.
>=20
> > We'll need to change LL_RESERVED_SPACE() / LL_RESERVED_SPACE_EXTRA(=
) /
> > LL_ALLOCATED_SPACE() macros and provide the [read once] values, ins=
tead
> > of a [read once] pointer to values.
>=20
> I'm not sure what you mean here.  I don't see any need to change
> these macros.  All we need is to save the value in a local variable:
>=20
> 	hh_len =3D LL_RESERVED_SPACE(dev);
>=20
> 	skb =3D alloc_skb(hh_len + len);
> 	skb_reserve(skb, hh_len);
>=20

Not really Herbert. Please read again my patch changelog.

In the bug we try to fix, we have :

skb =3D sock_alloc_send_skb(sk, ... + LL_ALLOCATED_SPACE(rt->dst.dev)=20

=2E.. < increase of dev->needed_headroom by another cpu/task >

skb_reserve(skb, LL_RESERVED_SPACE(rt->dst.dev));

skb_put() -> crash because we reserved too much space

So we really want LL_ALLOCATED_SPACE() and LL_RESERVED_SPACE() use the
same needed_headroom, or else you can have LL_RESERVED_SPACE() >
LL_ALLOCATED_SPACE().

There are several way to fix this, but this kind of code assumed the
dev->needed... values were consistent for the whole block.
