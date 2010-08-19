From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [PATCH net-next-2.6] net: build_ehash_secret() and
	rt_bind_peer() cleanups
Date: Thu, 19 Aug 2010 12:13:26 -0400
Message-ID: <20100819161326.GB24357@Krystal>
References: <1282232815.2549.61.camel@edumazet-laptop> <AANLkTinpqNa3cgEb=86H0sYXdLmo-RP1G2icJgWpfyN1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tomts22.bellnexxia.net ([209.226.175.184]:65147 "EHLO
	tomts22-srv.bellnexxia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752497Ab0HSQNj convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Aug 2010 12:13:39 -0400
Received: from toip4.srvr.bell.ca ([209.226.175.87])
          by tomts22-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20100819161338.KXDN16376.tomts22-srv.bellnexxia.net@toip4.srvr.bell.ca>
          for <netdev@vger.kernel.org>; Thu, 19 Aug 2010 12:13:38 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTinpqNa3cgEb=86H0sYXdLmo-RP1G2icJgWpfyN1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Changli Gao (xiaosuo@gmail.com) wrote:
> On Thu, Aug 19, 2010 at 11:46 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
> > Now cmpxchg() is available on all arches, we can use it in
> > build_ehash_secret() and rt_bind_peer() instead of using spinlocks.
> >
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > CC: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
> > ---
[...]
> > =A0void rt_bind_peer(struct rtable *rt, int create)
> > =A0{
> > - =A0 =A0 =A0 static DEFINE_SPINLOCK(rt_peer_lock);
> > =A0 =A0 =A0 =A0struct inet_peer *peer;
> >
> > =A0 =A0 =A0 =A0peer =3D inet_getpeer(rt->rt_dst, create);
> >
> > - =A0 =A0 =A0 spin_lock_bh(&rt_peer_lock);
> > - =A0 =A0 =A0 if (rt->peer =3D=3D NULL) {
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rt->peer =3D peer;
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 peer =3D NULL;
> > - =A0 =A0 =A0 }
> > - =A0 =A0 =A0 spin_unlock_bh(&rt_peer_lock);
> > - =A0 =A0 =A0 if (peer)
> > + =A0 =A0 =A0 peer =3D cmpxchg(&rt->peer, NULL, peer);
> > +
> > + =A0 =A0 =A0 if (unlikely(peer))
>=20
> It isn't correct, and should be
>      if (unlikely(cmpxchg(&rt->peer, NULL, peer) !=3D NULL))
>=20
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0inet_putpeer(peer);
> > =A0}

What do you mean by "It isn't correct" ? Eric code and yours perform th=
e
exact same thing. So I assume this is just a code style issue here.

Thanks,

Mathieu


--=20
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com
