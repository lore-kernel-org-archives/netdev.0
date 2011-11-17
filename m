From: Flavio Leitner <fbl@redhat.com>
Subject: Re: Unable to flush ICMP redirect routes in kernel 3.0+
Date: Thu, 17 Nov 2011 15:01:45 -0200
Message-ID: <20111117150145.25e01a75@asterix.rh>
References: <4EC2CA52.6020104@icdsoft.com>
	<1321391355.2602.0.camel@edumazet-laptop>
	<4EC439F2.3080809@icdsoft.com>
	<20111116223330.08de9e52@asterix.rh>
	<4EC4C160.6010804@icdsoft.com>
	<20111117111145.252924f5@asterix.rh>
	<1321535747.2751.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1321540820.2751.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111117133724.59684d28@asterix.rh>
	<1321547510.2751.66.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111117144038.61b0525b@asterix.rh>
	<1321548319.2751.70.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Ivan Zahariev <famzah@icdsoft.com>, netdev@vger.kernel.org,
	Vasiliy Kulikov <segoon@openwall.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20631 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756754Ab1KQRCD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 12:02:03 -0500
In-Reply-To: <1321548319.2751.70.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Nov 2011 17:45:19 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le jeudi 17 novembre 2011 =C3=A0 14:40 -0200, Flavio Leitner a =C3=A9=
crit :
> > On Thu, 17 Nov 2011 17:31:50 +0100
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >=20
> > > Le jeudi 17 novembre 2011 =C3=A0 13:37 -0200, Flavio Leitner a =C3=
=A9crit :
> > > > On Thu, 17 Nov 2011 15:40:20 +0100
> > > > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > >=20
> > > > > [PATCH] ping: dont increment ICMP_MIB_INERRORS
> > > > >=20
> > > > > ping module incorrectly increments ICMP_MIB_INERRORS if feede=
d
> > > > > with a frame not belonging to its own sockets.
> > > > >=20
> > > > > RFC 2011 states that ICMP_MIB_INERRORS should count "the
> > > > > number of ICMP messages which the entiry received but
> > > > > determined as having ICMP-specific errors (bad ICMP
> > > > > checksums, bad length, etc.)."
> > > > >=20
> > > > > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > > > > CC: Vasiliy Kulikov <segoon@openwall.com>
> > > >=20
> > > > Yeah, they aren't ICMP specific errors and the callers already
> > > > checked for checksum, lengths, and etc.. increasing that counte=
r
> > > > when necessary.
> > > >=20
> > > > Acked-by: Flavio Leitner <fbl@redhat.com>
> > >=20
> > > Thanks
> > >=20
> > > By the way, redirects dont work at all in net-next
> >=20
> > Could you be more specific? It seems to be working here.
> >=20
> > > Probably coming from your commit 7cc9150ebe8ec0
> > > (route: fix ICMP redirect validation)
> > >=20
> > > Since calling __ip_route_output_key() will create the route with
> > > s =3D 0, l =3D 0  (forcing saddr and dev->ifindex) selectors...
> > >=20
> > > We have to add a 'create' parameter to __ip_route_output_key() so
> > > that ip_rt_redirect() doesnt create a route, only find the
> > > existing one in cache ?
> >=20
> > It should receive redirect after sending a packet, so the route
> > should be ready at this point.=20
>=20
> I receive the redirect, but the rt->peer is updated on a different
> route than the one used by my ping command.
>=20
> Its updated on the specific route (source address forced, output
> device forced), not on the wildcarded route my ping is using.
>=20
> So next packets are still sent on old gateway...

Right, so the loop trying different oif and saddr isn't working at
all because __ip_route_output_key() will create a route in the first
attempt.  Looks like you're right and we need the 'create' parameter
in __ip_route_output_key().

thanks,
fbl
