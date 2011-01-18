From: Jesse Gross <jesse@nicira.com>
Subject: Re: [BUG] bnx2 + vlan + TSO : doesnt work
Date: Mon, 17 Jan 2011 16:13:18 -0800
Message-ID: <AANLkTincFt4fKLvtity=MgQ2+cuvNFrBHqu3+bMLsypc@mail.gmail.com>
References: <1295307669.3362.106.camel@edumazet-laptop>
	<1295308041.6264.22.camel@bwh-desktop>
	<1295308844.3362.135.camel@edumazet-laptop>
	<1295309365.6264.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:38014 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752575Ab1ARAVF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jan 2011 19:21:05 -0500
Received: by gxk9 with SMTP id 9so2129246gxk.19
        for <netdev@vger.kernel.org>; Mon, 17 Jan 2011 16:21:03 -0800 (PST)
In-Reply-To: <1295309365.6264.23.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 17, 2011 at 4:09 PM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Tue, 2011-01-18 at 01:00 +0100, Eric Dumazet wrote:
>> Le lundi 17 janvier 2011 =E0 23:47 +0000, Ben Hutchings a =E9crit :
>> > On Tue, 2011-01-18 at 00:41 +0100, Eric Dumazet wrote:
>> > > Oh well, my dev machine, with bnx2 and tg3 NICs, isnt working at=
 all
>> > > with current linux-2.6 tree (I need vlans on my setup)
>> > >
>> > > tg3 : vlan not working
>> > >
>> > > bnx2 : vlan + TSO not working (or very slowly, since only non GS=
O frames
>> > > are OK)
>> > >
>> > > I suspect recent commits from Jesse are the problem.
>> > > (bnx2_xmit() is feeded with zeroed vlan_tci skbs)
>> > >
>> > > Maybe f01a5236bd4b1401 (net offloading: Generalize
>> > > netif_get_vlan_features().) ?
>> > >
>> > > I dont see NETIF_F_HW_VLAN_TX being set in vlan_features in net =
drivers.
>> > > They only set this flag in dev->features
>> > >
>> > > I dont think changing all drivers to also set vlan_features make=
s sense.
>> > >
>> > > Is following patch the right path ? (It does solve my problem)
>> >
>> > This isn't right. =A0NETIF_F_HW_VLAN_TX in vlan_features would mea=
n that
>> > the hardware can do two levels of VLAN tag insertion, which is gen=
erally
>> > not true.
>> >
>>
>> So should we revert part of Jesse patch ? I want my vlan back ;)
>
> Yeah, that looks right.

I think it is better for netif_skb_features() to actually return the
correct features rather than bypass it here.  NETIF_F_HW_VLAN_TX
doesn't depend on any other offloads, so we can always include it if
it is in dev->features.

Separately, this means there is a problem with bnx2 because it allows
vlan insertion to be turned off, which would have the same effect.
Maybe it is looking directly at skb->protocol or similar for TSO.
