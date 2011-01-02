From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2.6.36] vlan: Avoid hwaccel vlan packets when vid not
 used
Date: Sun, 02 Jan 2011 17:05:48 +0100
Message-ID: <1293984348.2535.101.camel@edumazet-laptop>
References: <1291536233.2806.102.camel@edumazet-laptop>
	 <20101205105528.49fa9a9f@xenia.leun.net>
	 <20101205114404.7c0cddc2@xenia.leun.net>
	 <AANLkTikrDTCDxsyOG4m0XcrOY=3pTRwWqnPGsio9cBFj@mail.gmail.com>
	 <20101206203437.54b550e0@xenia.leun.net>
	 <AANLkTikKkAesHc4Fi4SwAkV0e65D0TQRztrRYoDNu3MP@mail.gmail.com>
	 <20101206222703.32fbe852@xenia.leun.net>
	 <AANLkTinLMCzKz7n45HdeAwNxsWjCADAkgfK+MjXVcFqh@mail.gmail.com>
	 <20101213224510.GB17400@mcarlson.broadcom.com>
	 <AANLkTi=9BYt=vkNkAiTBxnfnCjCX7AqCG=ML6coc4vdZ@mail.gmail.com>
	 <20101214191500.GD19951@mcarlson.broadcom.com>
	 <1293901393.2535.49.camel@edumazet-laptop>
	 <AANLkTinq9ABi0prxe0m1Ma6rno4UnAOzuW-b5L362ij9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Michael Leun <lkml20101129@newton.leun.net>,
	Michael Chan <mchan@broadcom.com>,
	David Miller <davem@davemloft.net>,
	Ben Greear <greearb@candelatech.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTinq9ABi0prxe0m1Ma6rno4UnAOzuW-b5L362ij9@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le samedi 01 janvier 2011 =C3=A0 19:27 -0500, Jesse Gross a =C3=A9crit =
:
> On Sat, Jan 1, 2011 at 12:03 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> > Le mardi 14 d=C3=A9cembre 2010 =C3=A0 11:15 -0800, Matt Carlson a =C3=
=A9crit :
> >
> >> Thanks for the comments Jesse.  Below is an updated patch.
> >>
> >> Michael, I'm wondering if the difference in behavior can be explai=
ned by
> >> the presence or absence of management firmware.  Can you look at t=
he
> >> driver sign-on messages in your syslogs for ASF[]?  I'm half expec=
ting
> >> the 5752 to show "ASF[0]" and the 5714 to show "ASF[1]".  If you s=
ee
> >> this, and the below patch doesn't fix the problem, let me know.  I=
 have
> >> another test I'd like you to run.
> >>
> >> ----
> >>
> >> [PATCH] tg3: Use new VLAN code
> >>
> >> This patch pivots the tg3 driver to the new VLAN infrastructure.
> >> All references to vlgrp have been removed and all VLAN code is
> >> unconditionally active.
> >>
> >> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
>=20
> [...]
>=20
> > Hi Matt.
> >
> > Any news on this patch ?
> >
> > Without it, net-next-2.6 doesnt work for me on a vlan setup on top =
of
> > bonding.
> >
> > (bond0 : eth1 & eth2, eth1 being bnx2, eth2 beging tg3)
> >
> > ip link add link bond0 vlan.103 type vlan id 103
> > ip addr add 192.168.20.110/24 dev vlan.103
> > ip link set vlan.103 up
> >
> >
> > If active slave is eth1 (bnx2), everything works, but if active sla=
ve is
> > eth2 (tg3), incoming tagged frames (on vlan 103) are lost.
>=20
> This patch isn't quite right - it always disables vlan stripping
> unless management firmware is in use, so it's not really a correct
> fix.
>=20
> You said that this used to work correctly on this NIC?  Does it work
> without a bond, just a vlan on the tg3 device?  It sounds like Michae=
l
> has a problem with vlan stripping on one of his NICs but if it works
> with just a vlan or on older kernels, it's probably not the same
> thing.
>=20

1) current linux-2.6 works OK for me (and previous versions as well, I
am using this vlan/bonding setup since 3 years or so on one of my dev
machine)

Only net-next-2.6 has the problem.

If I remove bonding of the equation, I still have the problem, and can
see the 'dropped' counter increasing while I send packets to eth2 (tg3)

$ ifconfig eth2
eth2      Link encap:Ethernet  HWaddr 00:1E:0B:92:78:50 =20
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:94 errors:0 dropped:38686 overruns:0 frame:0
          TX packets:18 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000=20
          RX bytes:8332 (8.1 Kb)  TX bytes:1392 (1.3 Kb)
          Interrupt:19=20
$ ifconfig vlan.103
vlan.103  Link encap:Ethernet  HWaddr 00:1E:0B:92:78:50 =20
          inet addr:192.168.20.110  Bcast:0.0.0.0  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:15 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0=20
          RX bytes:0 (0.0 b)  TX bytes:846 (846.0 b)





> If it works on bnx2, it would seem to be a driver problem but it woul=
d
> be good to confirm that the tag in skb->vlan_tci is not being
> delievered to the networking core in this case.

Hmm, where do you want me to check this ?
