From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-2.6] bonding: drop frames received with master's
	source MAC
Date: Tue, 1 Mar 2011 13:16:24 -0500
Message-ID: <20110301181624.GM11864@gospo.rdu.redhat.com>
References: <1298668408-14849-1-git-send-email-andy@greyhouse.net> <4D68276B.90104@gmail.com> <20110225222455.GI11864@gospo.rdu.redhat.com> <4D683653.4050409@gmail.com> <20110228163255.GJ11864@gospo.rdu.redhat.com> <4D6C1764.1040008@gmail.com> <20110301023525.GK11864@gospo.rdu.redhat.com> <9882.1298958366@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Nicolas de =?us-ascii?B?PT9pc28tODg1OS0xP1E/UGVzbG89RkNhbj89?=
	<nicolas.2p.debian@gmail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Jiri Pirko <jpirko@redhat.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28088 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756425Ab1CASQh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2011 13:16:37 -0500
Content-Disposition: inline
In-Reply-To: <9882.1298958366@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 28, 2011 at 09:46:06PM -0800, Jay Vosburgh wrote:
> Andy Gospodarek <andy@greyhouse.net> wrote:
>=20
> >On Mon, Feb 28, 2011 at 10:45:08PM +0100, Nicolas de Peslo=FCan wrot=
e:
> >> Le 28/02/2011 17:32, Andy Gospodarek a =E9crit :
> >>> On Sat, Feb 26, 2011 at 12:08:03AM +0100, Nicolas de Peslo=FCan w=
rote:
> >>>> Le 25/02/2011 23:24, Andy Gospodarek a =E9crit :
> >>> [...]
> >>>>>
> >>>>> I confirmed your suspicion, this breaks ARP monitoring.  I woul=
d still
> >>>>> welcome other opinions though as I think it would be nice to fi=
x this as
> >>>>> low as possible.
> >>>>
> >>>> Why do you want to fix it earlier that in ndisc_recv_ns drop? Yo=
ur
> >>>> original idea of silently dropping the frame there seems perfect=
 to me.
> >>>>
> >>>
> >>> Maybe it's just me, but I cannot understand why we want a bunch o=
f extra
> >>> packets floating up into the stack when they may only create issu=
es for
> >>> the recipients of these duplicate frames.
> >>>
> >>> Clearly my original patch needs to be refined so ARP monitoring s=
till
> >>> works, but I would rather fix the issue there than in a higher la=
yer.
> >>
> >> Jay explained that the current implementation should already trap =
those=20
> >> frames, on inactive slaves, in modes where inactive slaves exist. =
I agree=20
> >> with him.
> >>
> >> What mode are you seeing this problem in? If the current "should d=
rop"=20
> >> logic is leaking, then yes, we should fix it. But we currently don=
't see=20
> >> where it is leaking.
> >>
> >
> >Use round-robin.  To reproduce just take the interface down and brin=
g it
> >back up.  You should see the messages right away.
>=20
> 	What is the bond connected to?  The -rr and -xor modes are meant
> to interoperate with switch ports configured for Etherchannel (or an
> equivalent).  In that case, I wouldn't expect the switch to turn the
> broadcasts / multicasts around and send them back out to a member of =
the
> channel group they originated from.
>=20
> 	If the switch isn't configured properly, then I'd expect it to
> complain about MAC flapping or the like.  Unless it's an unmanaged
> switch that doesn't do Etherchannel (etc), or you're setting up an
> unusual topology.
>=20

My system is connected to an unmanaged switch, but I guess I don't
generally consider that to be an unual topology.  While balance-rr does
work well when the switch is configured for etherchannel, it can also
work just fine without.=20

> >I've been doing some more testing on a new patch and should have
> >something ready tomorrow.  My latest patch actually replaces the fin=
al
> >'return 0' with a call to a function that will return true if the se=
nder
> >was the device that received it.  This will hopefully prevent some o=
f
> >the failures with the first patch I posted.  I'll know a bit more
> >tomorrow if this approach seems reasonable.
>=20
> 	How do you figure that out?  In -rr mode, all of the slaves
> should have the same MAC address, and the slaves shouldn't be running
> IPv6 addrconf separately from the master anyway.  Something magic jus=
t
> for NA/NS packets?
>=20

Knowing that I'm using an unmanaged switch with balance-rr probably
helps understand how this is happening.  I'll clarify this however, so
we are all on the same page.

In my situation, eth2 and eth3 are in bond0.  When bond0 transmits the
NS, let's say it goes out eth3.  Since it is a multicast frame my switc=
h
will broadcast this to all ports and eth2 will receive the frame with
the source MAC address being the same as bond0's MAC address.  This
frame is passed up the stack to the ipv6 layer and appears to be a
response to the NS from another host and is dropped.

