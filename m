From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [TCP]: TCP_DEFER_ACCEPT causes leak sockets
Date: Fri, 13 Jun 2008 08:30:37 +0200
Message-ID: <20080613063037.GA16943@elte.hu>
References: <200806111658.41182.vgusev@openvz.org> <20080611135718.GA26914@ms2.inr.ac.ru> <20080611.165255.242691774.davem@davemloft.net> <20080612.163212.148965080.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kuznet@ms2.inr.ac.ru, vgusev@openvz.org, mcmanus@ducksong.com,
	xemul@openvz.org, netdev@vger.kernel.org,
	ilpo.jarvinen@helsinki.fi, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:60645 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753051AbYFMGaz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jun 2008 02:30:55 -0400
Content-Disposition: inline
In-Reply-To: <20080612.163212.148965080.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* David Miller <davem@davemloft.net> wrote:

> From: David Miller <davem@davemloft.net>
> Date: Wed, 11 Jun 2008 16:52:55 -0700 (PDT)
>=20
> > More and more, the arguments are mounting to completely revert the=20
> > established code path changes, and frankly that is likely what I am=
=20
> > going to do by the end of today.
>=20
> Here is the revert patch I intend to send to Linus:
>=20
> tcp: Revert 'process defer accept as established' changes.
>=20
> This reverts two changesets, ec3c0982a2dd1e671bad8e9d26c28dcba0039d87
> ("[TCP]: TCP_DEFER_ACCEPT updates - process as established") and
> the follow-on bug fix 9ae27e0adbf471c7a6b80102e38e1d5a346b3b38
> ("tcp: Fix slab corruption with ipv6 and tcp6fuzz").
>=20
> This change causes several problems, first reported by Ingo Molnar
> as a distcc-over-loopback regression where connections were getting
> stuck.
>=20
> Ilpo J=E4rvinen first spotted the locking problems.  The new function
> added by this code, tcp_defer_accept_check(), only has the
> child socket locked, yet it is modifying state of the parent
> listening socket.
>=20
> Fixing that is non-trivial at best, because we can't simply just grab
> the parent listening socket lock at this point, because it would
> create an ABBA deadlock.  The normal ordering is parent listening
> socket --> child socket, but this code path would require the
> reverse lock ordering.
>=20
> Next is a problem noticed by Vitaliy Gusev, he noted:
>=20
> ----------------------------------------
> >--- a/net/ipv4/tcp_timer.c
> >+++ b/net/ipv4/tcp_timer.c
> >@@ -481,6 +481,11 @@ static void tcp_keepalive_timer (unsigned long =
data)
> > 		goto death;
> > 	}
> >
> >+	if (tp->defer_tcp_accept.request && sk->sk_state =3D=3D TCP_ESTABL=
ISHED) {
> >+		tcp_send_active_reset(sk, GFP_ATOMIC);
> >+		goto death;
>=20
> Here socket sk is not attached to listening socket's request queue. t=
cp_done()
> will not call inet_csk_destroy_sock() (and tcp_v4_destroy_sock() whic=
h should
> release this sk) as socket is not DEAD. Therefore socket sk will be l=
ost for
> freeing.
> ----------------------------------------
>=20
> Finally, Alexey Kuznetsov argues that there might not even be any
> real value or advantage to these new semantics even if we fix all
> of the bugs:
>=20
> ----------------------------------------
> Hiding from accept() sockets with only out-of-order data only
> is the only thing which is impossible with old approach. Is this real=
ly
> so valuable? My opinion: no, this is nothing but a new loophole
> to consume memory without control.
> ----------------------------------------
>=20
> So revert this thing for now.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>

the 3 reverts have been extensively tested in -tip via:

 # tip/out-of-tree: 9e5b6ca: tcp: revert DEFER_ACCEPT modifications

and the distcc problems are fixed. (The locking fix alone did not fix i=
t=20
conclusively in my testing, possibly due to the follow-on observations=20
outlined in your description.)

Tested-by: Ingo Molnar <mingo@elte.hu>

	Ingo
