From: Radu Rendec <radu.rendec@mindbit.ro>
Subject: Re: TUN interfaces loopback
Date: Sun, 29 Nov 2015 23:56:14 +0200
Message-ID: <1448834174.3668.27.camel@mindbit.ro>
References: <1448470693.7801.41.camel@mindbit.ro>
	 <CAKD1Yr1eh5nawO3793Z61-UOYr5uXiT8FFksGeEZ2F1A8e=u3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.mindbit.ro ([80.86.127.26]:59067 "EHLO ns2.local.mindbit.ro"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752674AbbK2V4R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Nov 2015 16:56:17 -0500
In-Reply-To: <CAKD1Yr1eh5nawO3793Z61-UOYr5uXiT8FFksGeEZ2F1A8e=u3g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-11-29 at 17:40 +0900, Lorenzo Colitti wrote:
> On Thu, Nov 26, 2015 at 1:58 AM, Radu Rendec <radu.rendec@mindbit.ro>=
 wrote:
> > I tracked down the problem to ip_route_input_slow() in net/ipv4/rou=
te.c
> > [...]
> > The next problem is that packets are seen as "martians" and dropped=
,
> > most probably because of __fib_validate_source() failing due to the
> > fact that the input interface is not the expected one.
>=20
> Have you tried setting this?
>=20
> accept_local - BOOLEAN
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0Accept packets with l=
ocal source addresses. In combination with
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0suitable routing, thi=
s can be used to direct packets between two
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0local interfaces over=
 the wire and have them accepted properly.
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0default FALSE

I have tried it, but with no luck. I also tried with=C2=A0rp_filter=3D0=
, which
seems to be even more permissive than accept_local.

However, after reading the code more carefully, I finally figured it
out. It turns out that it's enough to have different (and correct)
routes for the outgoing and incoming routing decisions.

So in the following configuration:
tun0 [192.168.1.1 point-to-point 192.168.1.2]
^
|
v
tun1 [192.168.1.2 point-to-point 192.168.1.1]

it's enough to do the following:

 * Remove the automatically added routes from the "local" table.
 * Add two rules (one for each tun interface) *matching the input
   interface* and directing to a custom routing table (i.e. "ip rule
   add iif tunX lookup Y").
 * Add *local* routes for each tun interface to the custom routing
   table.
The trick here is that iif is set to 0 during the outgoing route
lookup, so the outgoing routing decision will not "see" the local
routes in the custom table. It will see the implicitly added routes in
the "main" table (these will route packets through the tun interfaces).

When the packet pops out of the opposite tun interface, the incoming
routing decision has iif set properly and will match the *local* routes
in the custom table. It is essential to match a local route at this
point, or else the packet will not be processed locally (as a packet
addressed to "this host").

With routing configured this way, not only that the martians problem
went away, but it works even with rp_filter=3D1 and accept_local=3D0.
