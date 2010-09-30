From: Jesse Gross <jesse@nicira.com>
Subject: Re: VLAN packets silently dropped in promiscuous mode
Date: Thu, 30 Sep 2010 14:21:15 -0700
Message-ID: <AANLkTikrfx1T3ay0AGWkS6Ab28J4O_er2TsbRinBSGen@mail.gmail.com>
References: <20100929113757.GA23755@core.hellgate.ch>
	<AANLkTi=QAoVH9KU8FAH6iscWt_mKnZpU3P9QqgFRLqXM@mail.gmail.com>
	<20100930080703.GA10827@core.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Roger Luethi <rl@hellgate.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:46818 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932218Ab0I3VVQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 17:21:16 -0400
Received: by iwn5 with SMTP id 5so2910985iwn.19
        for <netdev@vger.kernel.org>; Thu, 30 Sep 2010 14:21:16 -0700 (PDT)
In-Reply-To: <20100930080703.GA10827@core.hellgate.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 30, 2010 at 1:07 AM, Roger Luethi <rl@hellgate.ch> wrote:
> On Wed, 29 Sep 2010 10:44:26 -0700, Jesse Gross wrote:
>> On Wed, Sep 29, 2010 at 4:37 AM, Roger Luethi <rl@hellgate.ch> wrote=
:
>> > I noticed packets for unknown VLANs getting silently dropped even =
in
>> > promiscuous mode (this is true only for the hardware accelerated p=
ath).
>> > netif_nit_deliver was introduced specifically to prevent that, but=
 the
>> > function gets called only _after_ packets from unknown VLANs have =
been
>> > dropped.
>>
>> Some drivers are fixing this on a case by case basis by disabling
>> hardware accelerated VLAN stripping when in promiscuous mode, i.e.:
>> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=
=3Dcommit;h=3D5f6c01819979afbfec7e0b15fe52371b8eed87e8
>>
>> However, at this point it is more or less random which drivers do
>> this. =A0It would obviously be much better if it were consistent.
>
> My understanding is this. Hardware VLAN tagging and stripping can alw=
ays be
> enabled. The kernel passes 802.1Q information along with the stripped
> header to libpcap which reassembles the original header where necessa=
ry.
> Works for me.

Sorry, I misread your original post as saying that the VLAN header
gets dropped, rather than the entire packet.  I agree that this is how
it should work but not necessarily how it does work (again, depending
on the driver).  Here's the problem that I was talking about:

Most drivers have a snippet of code that looks something like this
(taken from ixgbe):

if (adapter->vlgrp && is_vlan && (tag & VLAN_VID_MASK))
	vlan_gro_receive(napi, adapter->vlgrp, tag, skb);
else
	napi_gro_receive(napi, skb);

At this point the VLAN has already been stripped in hardware.  If
there is no VLAN group configured on the device then we hit the second
case.  The VLAN header was removed from the SKB and the tag variable
is unused.  It is no longer possible for libpcap to reconstruct the
header because the information was thrown away (even the fact that
there was a VLAN tag at all).

There are a couple ways to fix this:

* Turn off VLAN stripping when in promiscuous mode (as done by the ixgb=
e driver)
* Reconstruct the VLAN header when there is no VLAN group (as done by
the tg3 driver)

A bunch of drivers do neither (bnx2x, for example) and exhibit this
problem.  It's getting better but it seems like a common issue.
