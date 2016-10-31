From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: at803x: the Atheros 8031 supports pause frames
Date: Mon, 31 Oct 2016 10:55:32 -0700
Message-ID: <39bda1bc-255b-64d0-3e7a-d3a6f00786c3@gmail.com>
References: <1477605901-30906-1-git-send-email-timur@codeaurora.org>
 <f34cd143-bf04-c17f-b3d6-e3077715a72a@gmail.com>
 <58127E8E.4020301@codeaurora.org>
 <9b817af9-a519-9010-e57b-8de8972088b8@gmail.com>
 <5813AFC1.50506@codeaurora.org>
 <144cc092-f04d-f5eb-503c-51e87c214b66@gmail.com>
 <58177E17.6070704@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: Timur Tabi <timur@codeaurora.org>, netdev@vger.kernel.org,
        zefir.kurtisi@neratec.com, scampbel@codeaurora.org,
        alokc@codeaurora.org, shankerd@codeaurora.org, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34700 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S945202AbcJaRzf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 13:55:35 -0400
Received: by mail-pf0-f193.google.com with SMTP id y68so3439139pfb.1
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 10:55:35 -0700 (PDT)
In-Reply-To: <58177E17.6070704@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/31/2016 10:23 AM, Timur Tabi wrote:
> Florian Fainelli wrote:
> 
>> May I suggest reading about standards a bit more, or just looking at
>> other drivers, like tg3.c.
> 
> I have been doing that for over six months now.  There's only so much I
> can glean from reading source code and standards documents.  The inner
> workings of our NIC are a mystery lost to time.
> 
>>> Ok, to me that means that the PHY driver must tell phylib whether or not
>>> it supports pause frames.  The question becomes:
>>>
>>> 1) Is my patch correct?
>>> 2) Is my patch necessary?
>>> 3) Is my patch sufficient?
>>
>> Your patch is correct but also insufficient, although, as indicated
>> before, there is an misconception with PHY drivers that they should be
>> setting SUPPORTED_*Pause* bits,
> 
> If that's a misconception, then why is my patch correct?  It modifies
> the PHY driver to set those bits.  These drivers do the same thing:

Your patch is not correct nor incorrect, but results in PHYLIB to
advertise pause frames to your link partner, and since you also have
flow control enabled, this produces the desired effect of getting what
you need, and the state is consistend. But as indicated before, this is
not how you are supposed to fix that.

> 
> bcm63xx.c
> bcm7xxx.c
> bcm-cygnus.c
> broadcom.c
> icplus.c
> micrel.c
> microchip.c
> national.c
> smsc.c
> ste10Xp.c

Ever heard of cargo cult programming?

> 
>>  the MAC should do that, based on what it
>> does, anyway, but more importantly you need to have your Ethernet MAC
>> react properly upon what the auto-negotiation and locally configured
>> pause/flow control settings are, and configure the Ethernet MAC
>> accordingly.
> 
> Ok, so I should enable support for pause frames in my MAC if
> phydev->pause and/or phydev->asym_pause is set, and disable it otherwise?

You don't read my emails do you? By setting phydev->supported and
phydev->features to include SUPPORTED_Pause and SUPPORTED_AsymPause when
you have *connected* to the PHY.

> 
> If I read the spec correct (tx=MAC sends pause frames, rx=MAC
> understands received pause frames),
> 
> pause    asym_pause    enable tx?    enable rx?
> -----    ----------    ----------    ----------
>   0           0           No             No
>   0           1           Yes            No
>   1           0           Yes            Yes
>   1           1           No             Yes
> 
> The last two seem backwards.  The internal driver enables RX and TX if
> pause and asym_pause is enabled.
> 
>> When you want pause frames to be enabled, you need to advertise them,
>> and in order to do so, you need to set phydev->supported to have
>> SUPPORTED_Pause and SUPPORTED_AsymPause, and call genphy_restart_aneg()
>> to transfer that to a write to the MII_ADVERTISE register, resulting in
>> your link partner to see that you now support Pause frames. Since pause
>> frames are now in use, you want your Ethernet MAC, not to ignore pause
>> frames (have flow control enabled).
> 
> Is there a way to enable pause frames without ethtool?  I intend to add
> ethtool support to my driver, but I want to fix this last bug first.

Auto-negotiation, with a forced policy to have flow control enabled is
certainly one of these cases.

> 
>>> 1) I believe my patch is correct, because many other PHY drivers do the
>>> same thing for the same reason.  If the PHY supports register 4 bits 10
>>> and 11, then those SUPPORTED_xxx bits should be set.
>>>
>>> 2) I don't know why my patch appears to be necessary, because I don't
>>> understand why a 1Gb NIC on a 2Ghz processor drops frames.  I suspect
>>> the program is not performance but rather a mis-programming.
>>>
>>> 4) Is my patch sufficient?  The internal driver always enables pause
>>> frame support in the PHY if the PHY says that pause frames are enabled.
>>>   In fact, I can't even turn off flow control in the internal driver:
>>
>> Please stop abusing this "PHY says", the PHY advertises what it is being
>> told to advertise, by the MAC...
> 
> Then I need help understanding why there are 10 other PHY drivers that
> set the SUPPORTED_Pause and SUPPORTED_Asym_Pause bits in their .features
> flags.

Cargo cult programming, replicating something you thought was right, or
did the job at the time, did not look back on it, and nobody cared
fixing it.

> 
>>> $ sudo ethtool -A eth1 tx off rx off
>>> $ sudo ethtool -a eth1
>>> Pause parameters for eth1:
>>> Autonegotiate:  on
>>> RX:             on
>>> TX:             on
>>>
>>> The driver insists on leaving flow control enabled if autonegotiation is
>>> enabled.
>>
>> Actually, the driver forces the enabling of flow control in the MAC,
>> period, but does not do anything with the auto-negotiation results, or I
>> could not spot it.
> 
> Sorry, the internal driver is very different that the external one.  It
> lacks phylib support.  You can see the internal driver here:
> 
> https://source.codeaurora.org/external/thundersoft/kernel/msm-3.10/tree/drivers/net/ethernet/msm/emac?h=caf/LA.BF.2.1.2_rb1.2

I have no interest in looking into something that is not upstream.

> 
> 
> Flow control is enabled or disabled via the TXFC and RXFC bits in
> function emac_hw_config_fc():
> 
> https://source.codeaurora.org/external/thundersoft/kernel/msm-3.10/tree/drivers/net/ethernet/msm/emac/emac_hw.c?h=caf/LA.BF.2.1.2_rb1.2#n1306
> 
> 
>> This was spotted in the review, but not addressed, but your adjust_link
>> callback seems completely bogus, it does a full MAC stop,
>> reconfiguration and restart,
> 
> I've been struggling to figure out what exactly the driver should do
> during adjust_link, although I don't see where it's doing a full
> restart.  If the link is up, it just calls emac_mac_start(), which just
> starts the MAC.

"just starts" the MAC is not quite what emac_mac_start() does, it does a
lot more than just programming the duplex and flow control settings, it
also deals with receiver/transmitter enable, touching some queue
configuration, interrupt etc., programs a handful of MAC bits relating
to packet processing etc.. all of this should be unnecessary at the time
you react to a link change, and presumably also needs to be done in a
controlled manner, as the hardware may be acting on a packet boundary
(you may have to wait for a full packet to drain before doing this or that).

All of this is much more than what is expected for a link up/down event.

> 
>> that is at best unnecessary and costly, but
>> it also misses a few things and does not act upon reading phydev->pause
>> and phydev->asym_pause to set or clear TXFC and RXFC, that really seems
>> to be your problem here.
> 
> Now that I understand (barely) what phydev->pause and phydev->asym_pause
> do, I can modify emac_mac_start() to use those values to set TXFC and RXFC.
> 
> Unfortunately, that won't explain why my driver needs the PHY to pass
> those frames to avoid 10% packet loss.  You would think a 1Gb NIC on a
> 24-core 2Ghz SOC could handle 900 Mbps.
> 
> Note that if I throttle my bandwidth to 90 Mbps, I still get packet
> loss.  However, if I switch the link from gigabit to 100Mbps, then I
> don't get packet loss.  So it's not the actual throughput that's the
> problem.  I get CRC errors in gigabit mode no matter what, if the pause
> frames are blocked by the PHY.

Then really this needs more investigation from your side instead of just
enabling pause frames and making the problem go away.

> 
>> Here is what could possibly go wrong right now:
>>
>> - your Ethernet MAC unconditionally enables flow control at the MAC
>> level, but does not advertise support for that in MII_ADVERTISE until
>> you set SUPPORTED_Pause and SUPPORTED_Asym_Pause in the PHY driver, fair
>> enough
>>
>> - the link partner you are testing against does not keep up well with
>> your transmit rates, but supports flow control, so Pause frames that it
>> sends back at you to tell you to stop transmitting so quickly just get
>> ignored, because not being advertised, you experience packet loss
> 
> The link partner is an e1000 NIC on an 8-core 3.6GHz PC .  Is it
> conceivable that I'm overloading it?

Yes it is, and if you are not directly connected to it, maybe it is the
switch in between, depending on how it deals with flow control you could
run into a problem with the switch. Not all switches support end-to-end
pause frames, and will terminate it locally, and then try to also apply
flow control with the otehr link partner: your e1000 NIC on the other PC.

Flow control issues are kind of difficult to resolve for sure, but
David's reply from a few minutes ago is also how I would approach the
problem.
-- 
Florian
