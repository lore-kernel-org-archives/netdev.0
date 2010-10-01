From: Jesse Gross <jesse@nicira.com>
Subject: Re: VLAN packets silently dropped in promiscuous mode
Date: Thu, 30 Sep 2010 19:37:13 -0700
Message-ID: <AANLkTi=Vdcn7xzJMPxkugvEVy32N7Bp=KVtir6NESnDF@mail.gmail.com>
References: <20100929113757.GA23755@core.hellgate.ch>
	<AANLkTi=QAoVH9KU8FAH6iscWt_mKnZpU3P9QqgFRLqXM@mail.gmail.com>
	<20100930080703.GA10827@core.hellgate.ch>
	<AANLkTikrfx1T3ay0AGWkS6Ab28J4O_er2TsbRinBSGen@mail.gmail.com>
	<1285884253.2705.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roger Luethi <rl@hellgate.ch>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:45882 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751410Ab0JAChN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 22:37:13 -0400
Received: by iwn5 with SMTP id 5so3217511iwn.19
        for <netdev@vger.kernel.org>; Thu, 30 Sep 2010 19:37:13 -0700 (PDT)
In-Reply-To: <1285884253.2705.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 30, 2010 at 3:04 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le jeudi 30 septembre 2010 =E0 14:21 -0700, Jesse Gross a =E9crit :
>> On Thu, Sep 30, 2010 at 1:07 AM, Roger Luethi <rl@hellgate.ch> wrote=
:
>> > On Wed, 29 Sep 2010 10:44:26 -0700, Jesse Gross wrote:
>> >> On Wed, Sep 29, 2010 at 4:37 AM, Roger Luethi <rl@hellgate.ch> wr=
ote:
>> >> > I noticed packets for unknown VLANs getting silently dropped ev=
en in
>> >> > promiscuous mode (this is true only for the hardware accelerate=
d path).
>> >> > netif_nit_deliver was introduced specifically to prevent that, =
but the
>> >> > function gets called only _after_ packets from unknown VLANs ha=
ve been
>> >> > dropped.
>> >>
>> >> Some drivers are fixing this on a case by case basis by disabling
>> >> hardware accelerated VLAN stripping when in promiscuous mode, i.e=
=2E:
>> >> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.gi=
t;a=3Dcommit;h=3D5f6c01819979afbfec7e0b15fe52371b8eed87e8
>> >>
>> >> However, at this point it is more or less random which drivers do
>> >> this. =A0It would obviously be much better if it were consistent.
>> >
>> > My understanding is this. Hardware VLAN tagging and stripping can =
always be
>> > enabled. The kernel passes 802.1Q information along with the strip=
ped
>> > header to libpcap which reassembles the original header where nece=
ssary.
>> > Works for me.
>>
>> Sorry, I misread your original post as saying that the VLAN header
>> gets dropped, rather than the entire packet. =A0I agree that this is=
 how
>> it should work but not necessarily how it does work (again, dependin=
g
>> on the driver). =A0Here's the problem that I was talking about:
>>
>> Most drivers have a snippet of code that looks something like this
>> (taken from ixgbe):
>>
>> if (adapter->vlgrp && is_vlan && (tag & VLAN_VID_MASK))
>> =A0 =A0 =A0 vlan_gro_receive(napi, adapter->vlgrp, tag, skb);
>> else
>> =A0 =A0 =A0 napi_gro_receive(napi, skb);
>>
>> At this point the VLAN has already been stripped in hardware. =A0If
>> there is no VLAN group configured on the device then we hit the seco=
nd
>> case. =A0The VLAN header was removed from the SKB and the tag variab=
le
>> is unused. =A0It is no longer possible for libpcap to reconstruct th=
e
>> header because the information was thrown away (even the fact that
>> there was a VLAN tag at all).
>>
>> There are a couple ways to fix this:
>>
>> * Turn off VLAN stripping when in promiscuous mode (as done by the i=
xgbe driver)
>> * Reconstruct the VLAN header when there is no VLAN group (as done b=
y
>> the tg3 driver)
>>
>> A bunch of drivers do neither (bnx2x, for example) and exhibit this
>> problem. =A0It's getting better but it seems like a common issue.
>
> tg3 is not perfect, because it does the reconstruction of VLAN header
> even if device is not in promiscuous mode.
>
> It could drop the frame instead.
>
> I wonder which SNMP counter is incremented in this case.
>
> Apparently, none :(

That's true.  Dropping here seems roughly equivalent to the effects of
a hardware VLAN filter, which will also not be tracked by a counter,
so that seems not too bad to me.

The thing that concerns me though is why so many drivers seem to have
this problem with completely dropping the VLAN header.  I know that
even several of the ones that work now were broken initially and had
to be fixed.  Seeing as the driver drops the VLAN information before
it gets to the general networking code I don't see a generic fix to
this as it is currently setup.  However, perhaps we could make it so
that it is harder to get wrong.  Something like this:

* Allow vlan_gro_receive() to take a NULL VLAN group and a tag of 0
(and do the same thing for vlan_hwaccel_rx())
* Now that the vlan functions can deal with non-VLAN packets, merge
them into their non-VLAN counterparts.
* We can now demultiplex between the VLAN/non-VLAN case in core
networking.  This is done anyways, it just prevents every driver from
needing that code block I copied above and allows us to fix these
types of problems centrally.
* Dump the VLAN tag into the SKB and hand off the packet to the
various consumers: VLAN devices, libpcap, bridge hook (not currently
done but should be for trunking).

I see a number of advantages of this:
* Fixes all the problems with cards dropping VLAN headers at once.
* Avoids having to disable VLAN acceleration when in promiscuous mode
(good for bridging since it always puts devices in promiscuous mode).
* Keeps VLAN tag separate until given to ultimate consumer, which
avoids needing to do header reconstruction as in tg3 unless absolutely
necessary.
* Consolidates common driver code in core networking.
