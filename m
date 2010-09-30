From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: VLAN packets silently dropped in promiscuous mode
Date: Fri, 01 Oct 2010 00:04:13 +0200
Message-ID: <1285884253.2705.25.camel@edumazet-laptop>
References: <20100929113757.GA23755@core.hellgate.ch>
	 <AANLkTi=QAoVH9KU8FAH6iscWt_mKnZpU3P9QqgFRLqXM@mail.gmail.com>
	 <20100930080703.GA10827@core.hellgate.ch>
	 <AANLkTikrfx1T3ay0AGWkS6Ab28J4O_er2TsbRinBSGen@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:42185 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756068Ab0I3WEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 18:04:20 -0400
Received: by fxm14 with SMTP id 14so277512fxm.19
        for <netdev@vger.kernel.org>; Thu, 30 Sep 2010 15:04:18 -0700 (PDT)
In-Reply-To: <AANLkTikrfx1T3ay0AGWkS6Ab28J4O_er2TsbRinBSGen@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 30 septembre 2010 =C3=A0 14:21 -0700, Jesse Gross a =C3=A9crit=
 :
> On Thu, Sep 30, 2010 at 1:07 AM, Roger Luethi <rl@hellgate.ch> wrote:
> > On Wed, 29 Sep 2010 10:44:26 -0700, Jesse Gross wrote:
> >> On Wed, Sep 29, 2010 at 4:37 AM, Roger Luethi <rl@hellgate.ch> wro=
te:
> >> > I noticed packets for unknown VLANs getting silently dropped eve=
n in
> >> > promiscuous mode (this is true only for the hardware accelerated=
 path).
> >> > netif_nit_deliver was introduced specifically to prevent that, b=
ut the
> >> > function gets called only _after_ packets from unknown VLANs hav=
e been
> >> > dropped.
> >>
> >> Some drivers are fixing this on a case by case basis by disabling
> >> hardware accelerated VLAN stripping when in promiscuous mode, i.e.=
:
> >> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git=
;a=3Dcommit;h=3D5f6c01819979afbfec7e0b15fe52371b8eed87e8
> >>
> >> However, at this point it is more or less random which drivers do
> >> this.  It would obviously be much better if it were consistent.
> >
> > My understanding is this. Hardware VLAN tagging and stripping can a=
lways be
> > enabled. The kernel passes 802.1Q information along with the stripp=
ed
> > header to libpcap which reassembles the original header where neces=
sary.
> > Works for me.
>=20
> Sorry, I misread your original post as saying that the VLAN header
> gets dropped, rather than the entire packet.  I agree that this is ho=
w
> it should work but not necessarily how it does work (again, depending
> on the driver).  Here's the problem that I was talking about:
>=20
> Most drivers have a snippet of code that looks something like this
> (taken from ixgbe):
>=20
> if (adapter->vlgrp && is_vlan && (tag & VLAN_VID_MASK))
> 	vlan_gro_receive(napi, adapter->vlgrp, tag, skb);
> else
> 	napi_gro_receive(napi, skb);
>=20
> At this point the VLAN has already been stripped in hardware.  If
> there is no VLAN group configured on the device then we hit the secon=
d
> case.  The VLAN header was removed from the SKB and the tag variable
> is unused.  It is no longer possible for libpcap to reconstruct the
> header because the information was thrown away (even the fact that
> there was a VLAN tag at all).
>=20
> There are a couple ways to fix this:
>=20
> * Turn off VLAN stripping when in promiscuous mode (as done by the ix=
gbe driver)
> * Reconstruct the VLAN header when there is no VLAN group (as done by
> the tg3 driver)
>=20
> A bunch of drivers do neither (bnx2x, for example) and exhibit this
> problem.  It's getting better but it seems like a common issue.

tg3 is not perfect, because it does the reconstruction of VLAN header
even if device is not in promiscuous mode.

It could drop the frame instead.

I wonder which SNMP counter is incremented in this case.

Apparently, none :(



