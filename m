From: Jesse Gross <jesse@nicira.com>
Subject: Re: [BUG] bnx2 + vlan + TSO : doesnt work
Date: Tue, 18 Jan 2011 01:32:33 -0500
Message-ID: <AANLkTi=zvsmnemO+9OggD01i==3mZnb_-09CjAcRS94w@mail.gmail.com>
References: <1295308844.3362.135.camel@edumazet-laptop>
	<1295309365.6264.23.camel@bwh-desktop>
	<AANLkTincFt4fKLvtity=MgQ2+cuvNFrBHqu3+bMLsypc@mail.gmail.com>
	<20110117.220927.189715926.davem@davemloft.net>
	<1295331690.3362.522.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:41281 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752445Ab1ARGce convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 01:32:34 -0500
Received: by ywl5 with SMTP id 5so1940520ywl.19
        for <netdev@vger.kernel.org>; Mon, 17 Jan 2011 22:32:34 -0800 (PST)
In-Reply-To: <1295331690.3362.522.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 18, 2011 at 1:21 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le lundi 17 janvier 2011 =E0 22:09 -0800, David Miller a =E9crit :
>> From: Jesse Gross <jesse@nicira.com>
>> Date: Mon, 17 Jan 2011 16:13:18 -0800
>>
>> > I think it is better for netif_skb_features() to actually return t=
he
>> > correct features rather than bypass it here. =A0NETIF_F_HW_VLAN_TX
>> > doesn't depend on any other offloads, so we can always include it =
if
>> > it is in dev->features.
>> >
>> > Separately, this means there is a problem with bnx2 because it all=
ows
>> > vlan insertion to be turned off, which would have the same effect.
>> > Maybe it is looking directly at skb->protocol or similar for TSO.
>>
>> Please, someone cons up an acceptable fix fast.
>>
>
> I just woke up, and honestly dont understand why only bnx2 is affecte=
d
> by this problem of masking NETIF_F_HW_VLAN_TX

If NETIF_F_HW_VLAN_TX is masked then the tag will be inserted in
software, which is generally OK.  The problem is that some drivers
assume that if they can do vlan tagging in hardware it will always be
used and therefore don't expect vlan tags when setting up TSO, etc.

>
> And I dont understand all this netif_skb_features() stuff : if we wan=
t
> to actually test dev->features & NETIF_F_HW_VLAN_TX, and this flag
> doesnt depend on other offloads, why are we doing features &
> vlan_features.

The idea is to put all of the logic in one place rather than having
pieces that are really interdependent scattered around in the
different offloads.  So we could test dev->features directly for vlans
but I would rather just have netif_skb_features() return the right
values to start off with.

>
> Jesse, I dont understand why you say "bnx2 allows vlan insertion to b=
e
> turned off". Really.

You can disable it using Ethtool, which will turn off
NETIF_F_HW_VLAN_TX the same as this bug.

I'm running a quick test on a patch to always allow NETIF_F_HW_VLAN_TX
to be returned from netif_skb_features().
