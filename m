From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: System call 'sendmsg' of process ospfd (quagga) causes
 kernel oops
Date: Tue, 18 Oct 2011 04:30:32 +0200
Message-ID: <1318905032.2571.35.camel@edumazet-laptop>
References: <CA+0Zf5Be5JUSvssH9CrDQq=jtETZr=veAPC7jriM8B-FZKbbpg@mail.gmail.com>
	 <1318604266.2223.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CA+0Zf5A-8X5MaXC4+BbLKtMb8S8B-Ln_a3JNfz0jR4O-ruefuw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Timo =?ISO-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Elmar Vonlanthen <evonlanthen@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+0Zf5A-8X5MaXC4+BbLKtMb8S8B-Ln_a3JNfz0jR4O-ruefuw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 17 octobre 2011 =C3=A0 09:16 +0200, Elmar Vonlanthen a =C3=A9c=
rit :
> 2011/10/14 Eric Dumazet <eric.dumazet@gmail.com>:
> > Please try following patch :
> >
> > [PATCH] ip_gre: dont increase dev->needed_headroom on a live device
> >
> > It seems ip_gre is able to change dev->needed_headroom on the fly.
> >
> > Its is not legal unfortunately and triggers a BUG in raw_sendmsg()
> >
> > skb =3D sock_alloc_send_skb(sk, ... + LL_ALLOCATED_SPACE(rt->dst.de=
v)
> >
> > < another cpu change dev->needed_headromm (making it bigger)
> >
> > ...
> > skb_reserve(skb, LL_RESERVED_SPACE(rt->dst.dev));
> >
> > We end with LL_RESERVED_SPACE() being bigger than LL_ALLOCATED_SPAC=
E()
> > -> we crash later because skb head is exhausted.
> >
> > Bug introduced in commit 243aad83 in 2.6.34 (ip_gre: include route
> > header_len in max_headroom calculation)
> >
> > Reported-by: Elmar Vonlanthen <evonlanthen@gmail.com>
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > CC: Timo Ter=C3=A4s <timo.teras@iki.fi>
> > CC: Herbert Xu <herbert@gondor.apana.org.au>
> > ---
> > diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> > index 8871067..1505dcf 100644
> > --- a/net/ipv4/ip_gre.c
> > +++ b/net/ipv4/ip_gre.c
> > @@ -835,8 +835,6 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_=
buff *skb, struct net_device *dev
> >        if (skb_headroom(skb) < max_headroom || skb_shared(skb)||
> >            (skb_cloned(skb) && !skb_clone_writable(skb, 0))) {
> >                struct sk_buff *new_skb =3D skb_realloc_headroom(skb=
, max_headroom);
> > -               if (max_headroom > dev->needed_headroom)
> > -                       dev->needed_headroom =3D max_headroom;
> >                if (!new_skb) {
> >                        ip_rt_put(rt);
> >                        dev->stats.tx_dropped++;
>=20
> Hello
>=20
> I tried this patch and I was not able anymore to reproduce the kernel
> oops. So the patch solved the bug.
> Thank you very much!
>=20
> Would it be possible to add the patch to the long term kernel 2.6.35
> as well? Because this is the one I use at the moment in production.
>=20

Thanks for testing.

If David/Herbert/Timo agree, then patch should find its way into curren=
t
kernel, then to stable trees as well.

Thanks
