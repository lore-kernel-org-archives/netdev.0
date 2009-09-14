From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: ipv4 regression in 2.6.31 ?
Date: Mon, 14 Sep 2009 09:31:28 -0700
Message-ID: <20090914093128.4d709ff6@nehalam>
References: <20090914150935.cc895a3c.skraw@ithnet.com>
	<4AAE4BAF.2010406@gmail.com>
	<20090914175505.a3f132ee.skraw@ithnet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephan von Krawczynski <skraw@ithnet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36967 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750867AbZINQbb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 12:31:31 -0400
In-Reply-To: <20090914175505.a3f132ee.skraw@ithnet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 14 Sep 2009 17:55:05 +0200
Stephan von Krawczynski <skraw@ithnet.com> wrote:

> On Mon, 14 Sep 2009 15:57:03 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > Stephan von Krawczynski a =C3=A9crit :
> > > Hello all,
> > >=20
> > > today we experienced some sort of regression in 2.6.31 ipv4 imple=
mentation, or
> > > at least some incompatibility with former 2.6.30.X kernels.
> > >=20
> > > We have the following situation:
> > >=20
> > >                                        ---------- vlan1@eth0 192.=
168.2.1/24
> > >                                       /
> > > host A 192.168.1.1/24 eth0  -------<router>            host B
> > >                                       \
> > >                                        ---------- eth1 192.168.3.=
1/24
> > >=20
> > >=20
> > > Now, if you route 192.168.1.0/24 via interface vlan1@eth0 on host=
 B and let
> > > host A ping 192.168.2.1 everything works. But if you route 192.16=
8.1.0/24 via
> > > interface eth1 on host B and let host A ping 192.168.2.1 you get =
no reply.
> > > With tcpdump we see the icmp packets arrive at vlan1@eth0, but no=
 icmp echo
> > > reply being generated neither on vlan1 nor eth1.
> > > Kernels 2.6.30.X and below do not show this behaviour.
> > > Is this intended? Do we need to reconfigure something to restore =
the old
> > > behaviour?
> > >=20
> >=20
> > Asymetric routing ?
> >=20
> > Check your rp_filter settings
> >=20
> > grep . `find /proc/sys/net -name rp_filter`
> >=20
> > rp_filter - INTEGER
> >         0 - No source validation.
> >         1 - Strict mode as defined in RFC3704 Strict Reverse Path
> >             Each incoming packet is tested against the FIB and if t=
he interface
> >             is not the best reverse path the packet check will fail=
=2E
> >             By default failed packets are discarded.
> >         2 - Loose mode as defined in RFC3704 Loose Reverse Path
> >             Each incoming packet's source address is also tested ag=
ainst the FIB
> >             and if the source address is not reachable via any inte=
rface
> >             the packet check will fail.
> >=20
> >         Current recommended practice in RFC3704 is to enable strict=
 mode
> >         to prevent IP spoofing from DDos attacks. If using asymmetr=
ic routing
> >         or other complicated routing, then loose mode is recommende=
d.
> >=20
> >         conf/all/rp_filter must also be set to non-zero to do sourc=
e validation
> >         on the interface
> >=20
> >         Default value is 0. Note that some distributions enable it
> >         in startup scripts.
>=20
> Ok, here you can see 2.6.31 values from the discussed box:
> (remember, no ping reply in this setup)
>=20
> /proc/sys/net/ipv4/conf/all/rp_filter:1
> /proc/sys/net/ipv4/conf/default/rp_filter:0
> /proc/sys/net/ipv4/conf/lo/rp_filter:0
> /proc/sys/net/ipv4/conf/eth2/rp_filter:0
> /proc/sys/net/ipv4/conf/eth0/rp_filter:0
> /proc/sys/net/ipv4/conf/eth1/rp_filter:0
> /proc/sys/net/ipv4/conf/vlan1/rp_filter:0
>=20
>=20
> And these are from the same box with 2.6.30.5:
> (ping reply works)
>=20
> /proc/sys/net/ipv4/conf/all/rp_filter:1
> /proc/sys/net/ipv4/conf/default/rp_filter:0
> /proc/sys/net/ipv4/conf/lo/rp_filter:0
> /proc/sys/net/ipv4/conf/eth2/rp_filter:0
> /proc/sys/net/ipv4/conf/eth0/rp_filter:0
> /proc/sys/net/ipv4/conf/eth1/rp_filter:0
> /proc/sys/net/ipv4/conf/vlan1/rp_filter:0
>=20
> As you can see they're all the same. Does this mean that rp_filter ne=
ver
> really worked as intended before 2.6.31 ? Or does it mean that rp_fil=
ter=3D0
> (eth1 and vlan1) gets overriden by all/rp_filter=3D1 in 2.6.31 and no=
t before?

RP filter did not work correctly in 2.6.30. The code added to to the lo=
ose
mode caused a bug; the rp_filter value was being computed as:
  rp_filter =3D interface_value & all_value;
So in order to get reverse path filter both would have to be set.

In 2.6.31 this was change to:
   rp_filter =3D max(interface_value, all_value);

This was the intended behaviour, if user asks all interfaces to have rp
filtering turned on, then set /proc/sys/net/ipv4/conf/all/rp_filter =3D=
 1
or to turn on just one interface, set it for just that interface.

Sorry for any confusion this caused.



--=20
