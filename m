From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: tbench wrt. loopback TSO
Date: Mon, 27 Oct 2008 20:03:14 +0300
Message-ID: <20081027170314.GA25148@ioremap.net>
References: <20081015.171408.193701292.davem@davemloft.net> <20081026123442.GA31506@ioremap.net> <20081026.185911.193696873.davem@davemloft.net> <Pine.LNX.4.64.0810270942430.1290@wrl-59.cs.helsinki.fi> <20081027141332.GA4691@ioremap.net> <Pine.LNX.4.64.0810271704530.7072@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, efault@gmx.de, mingo@elte.hu,
	a.p.zijlstra@chello.nl, Herbert Xu <herbert@gondor.apana.org.au>
To: Ilpo =?utf-8?B?SsOkcnZpbmVu?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kandzendo.ru ([195.178.208.66]:38372 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750866AbYJ0RDR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2008 13:03:17 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0810271704530.7072@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 27, 2008 at 05:19:17PM +0200, Ilpo J=C3=A4rvinen (ilpo.jarv=
inen@helsinki.fi) wrote:
> On Mon, 27 Oct 2008, Evgeniy Polyakov wrote:
>=20
> > On Mon, Oct 27, 2008 at 09:49:21AM +0200, Ilpo J=C3=A4rvinen (ilpo.=
jarvinen@helsinki.fi) wrote:
> > > > > That's what I got with the current tree for 8 threads on a 4-=
way 32-bit
> > > > > Xeons (2 physical CPUs) and 8gb of ram:
> > > > > gso/tso off: 361.367
> > > > > tso/gso on:  354.635
> > > >=20
> > > > Yes, it might do this, in which case tcp_tso_should_defer() sim=
ply needs
> > > > some tweaking.
> > >=20
> > > Good point, could you Evgeniy verify first if simple goto send_no=
w; in=20
> > > beginning there recovers it all...
> >=20
> > With direct goto at the begining of the tcp_tso_should_defer()
> > and 4403b406 commit git tree (was current yesterday night)
> > I got following numbers:=20
> >=20
> > with goto:
> > tso/gso  on: 358.976, 357.699
> > tso/gso off: 368.016, 367.079
> >=20
> > no goto
> > tso/gso  on: 353.656, 354.791
> > tso/gso off: 364.8, 365.85
> >=20
> > So tcp_tso_should_defer() adds additional problems not counted in
> > tso/gso changes.
>=20
> Noticed that tcp_current_mss does modulo with tso and that it is=20
> being called from a non-trivial number of places, though ovbiously on=
ly=20
> part of them should be relevant here. ...I'm not sure if that can sho=
w=20
> up though.

That's why when I see modulo something screams inside me...
I used following patch (without goto in the tcp_tso_should_defer():

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index e4c5ac9..8ee7597 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1075,7 +1075,6 @@ unsigned int tcp_current_mss(struct sock *sk, int=
 large_allowed)
 				  tp->tcp_header_len);
=20
 		xmit_size_goal =3D tcp_bound_to_half_wnd(tp, xmit_size_goal);
-		xmit_size_goal -=3D (xmit_size_goal % mss_now);
 	}
 	tp->xmit_size_goal =3D xmit_size_goal;
=20

tso/gso  on: 361.866 362.662
tso/gso off: 370.038 368.768

So this is another improvement hidden and not accounted in the tso/gso =
stuff.
Another modulo sits in tcp_mss_split_point().
Also found one in the scheduler's find_next_best_node(), which is under
CONFIG_NUMA though.

--=20
	Evgeniy Polyakov
