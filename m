From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] network: return errors if we know tcp_connect
 failed
Date: Thu, 11 Nov 2010 22:14:38 +0100
Message-ID: <1289510078.17691.1724.camel@edumazet-laptop>
References: <20101111210341.31350.86916.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: Eric Paris <eparis@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54905 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753090Ab0KKVOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 16:14:43 -0500
In-Reply-To: <20101111210341.31350.86916.stgit@paris.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 11 novembre 2010 =C3=A0 16:03 -0500, Eric Paris a =C3=A9crit :
> THIS PATCH IS VERY POSSIBLY WRONG!  But if it is I want some feedback=
=2E
>=20
> Basically what I found was that if I added an iptables rule like so:
>=20
> iptables -A OUTPUT -p tcp --dport 80 -j DROP
>=20
> And then ran a web browser like links it would just hang on 'establis=
hing
> connection.'  I expected that the application would immediately, or a=
t least
> very quickly, get notified that the connect failed.   This waiting fo=
r timeout
> would be expected if something else dropped the SYN or if we were dro=
pping the
> SYN/ACK packet coming back, but I figured if we knew we threw away th=
e SYN we knew
> right away that the connection was denied and we should be able to in=
dicate
> that to the application.  Yes, I realize this is little different tha=
n if the
> SYN was dropped in the first network device, but it is different beca=
use we
> know what happened!  We know that connect() call failed and that ther=
e isn't
> anything coming back.
>=20
> What I discovered was that we actually had 2 problems in making it po=
ssible.
> For userspace to quickly realize the connect failed.  The first was a=
 problem
> in the netfilter code which wasn't passing errors back up the stack c=
orrectly,
> due to what I believe to be a mistake in precedence rules.
>=20
> http://marc.info/?l=3Dnetfilter-devel&m=3D128950262021804&w=3D2
>=20
> And the second was that tcp_connect() was just ignoring the return va=
lue from
> tcp_transmit_skb().  Maybe this was intentional but I really wish we =
could
> find out that connect failed long before the minutes long timeout.  O=
nce I
> fixed both of those issues I find that links gets denied (with EPERM)
> immediately when it calls connect().  Is this wrong?  Is this bad to =
tell
> userspace more quickly what happened?  Does passing this error code b=
ack up
> the stack here break something else?  Why do some functions seem to p=
ay
> attention to tcp_transmit_skb() return codes and some functions just =
ignore
> it?  What do others think?
>=20


I think its an interesting idea, but a temporary memory shortage would
abort the connect().

We could imagine some special handling of the first packet of a flow
being DROPED for whatever reason (flow control...)

So it needs some refinement I think.

SYN packets should be allowed to be re-transmitted before saying a TCP
connect() cannot succeed.



