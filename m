From: "Tomi Orava" <tomimo@ncircle.nullnet.fi>
Subject: Re: [Bugme-new] [Bug 12886] New: skge wake on lan
Date: Thu, 19 Mar 2009 15:03:44 +0200 (EET)
Message-ID: <5763d224db6e790c6faf971d1754dca2.squirrel@ncircle.nullnet.fi>
References: <bug-12886-10286@http.bugzilla.kernel.org/>
    <200903172223.14608.rjw@sisk.pl>
    <919358a27b164c5f76cf42d3b3063050.squirrel@ncircle.nullnet.fi>
    <200903181614.08724.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	"Stephen Hemminger" <shemminger@linux-foundation.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xdsl-83-150-88-111.nebulazone.fi ([83.150.88.111]:56455 "EHLO
	ncircle.nullnet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754763AbZCSNDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 09:03:49 -0400
In-Reply-To: <200903181614.08724.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,


> Hm, are you sure the commit in question _is_ in 2.6.28.y?  I can't see it
> in
> there.  It is in the current Linus' tree, but not in v2.6.28 and surely
> not in
> -stable.  Do you use a distro kernel?

My bad! It seems that I've got it backwards and therefore must
retest everything. The fact is that the stable series 2.6.28.x
kernels did not have a working WOL in my motherboard.
However, I think I messed up initially by patching instead of
reverting the mentioned commit into the stable series 2.6.28.x
kernel which seemed to fix the problem.

Therefore, could you wait for a short while, and I'll try to run
the couple of tests again in the evening and then get back to
you.

Regards,
Tomi Orava

>
>> Settings for eth0:
>>         Supported ports: [ TP ]
>>         Supported link modes:   10baseT/Half 10baseT/Full
>>                                 100baseT/Half 100baseT/Full
>>                                 1000baseT/Half 1000baseT/Full
>>         Supports auto-negotiation: Yes
>>         Advertised link modes:  10baseT/Half 10baseT/Full
>>                                 100baseT/Half 100baseT/Full
>>                                 1000baseT/Half 1000baseT/Full
>>         Advertised auto-negotiation: Yes
>>         Speed: 1000Mb/s
>>         Duplex: Full
>>         Port: Twisted Pair
>>         PHYAD: 0
>>         Transceiver: internal
>>         Auto-negotiation: on
>>         Supports Wake-on: pg
>>         Wake-on: g
>>         Current message level: 0x00000037 (55)
>>         Link detected: yes
>>
>> Ie. looks like exactly the same as with the commit reverted.
>
> OK
>
>> >
>> > Also, please check if the appended patch helps (of course, without
>> > reverting
>> > the commit).
>> >
>> > ---
>> >  drivers/net/skge.c |    5 +++--
>> >  1 file changed, 3 insertions(+), 2 deletions(-)
>> >
>> > Index: linux-2.6/drivers/net/skge.c
>> > ===================================================================
>> > --- linux-2.6.orig/drivers/net/skge.c
>> > +++ linux-2.6/drivers/net/skge.c
>> > @@ -3856,8 +3856,9 @@ static struct net_device *skge_devinit(s
>> >  	skge->speed = -1;
>> >  	skge->advertising = skge_supported_modes(hw);
>> >
>> > -	if (device_may_wakeup(&hw->pdev->dev))
>> > -		skge->wol = wol_supported(hw) & WAKE_MAGIC;
>> > +	skge->wol = wol_supported(hw) & WAKE_MAGIC;
>> > +	if (skge->wol && device_can_wakeup(&hw->pdev->dev))
>> > +		device_set_wakeup_enable(&hw->pdev->dev, true);
>> >
>> >  	hw->dev[port] = dev;
>>
>> Hmm, looks like this patch is against a 2.6.28.8 tree with the commit
>> reverted. I merged the couple lines as following.
>>
>> line 3859:
>>
>>         // if (pci_wake_enabled(hw->pdev))
>>         //      skge->wol = wol_supported(hw) & WAKE_MAGIC;
>>         skge->wol = wol_supported(hw) & WAKE_MAGIC;
>>         if (skge->wol && device_can_wakeup(&hw->pdev->dev))
>>                 device_set_wakeup_enable(&hw->pdev->dev, true);
>>
>> and this really seems to fix the problem. The system is able to wake
>> up via etherwake just fine.
>
> Well, that's because commit 5177b3240a6608fc0c9c05cc32f4855c6540f8d5
> changed
> the default from "wake-up enabled by default" to "wake-up disabled by
> default".
> The latter is safer IMO, but I'll prepare a (better) patch to change it
> back to
> the old behavior.
>
> You should be able to set up WoL by running 'ethtool -s eth0 wol g' from
> your
> init scripts even without reverting the patch.  Please verify if that
> works.
>


-- 


