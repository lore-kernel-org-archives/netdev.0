From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: at803x: the Atheros 8031 supports pause frames
Date: Fri, 28 Oct 2016 14:03:59 -0700
Message-ID: <144cc092-f04d-f5eb-503c-51e87c214b66@gmail.com>
References: <1477605901-30906-1-git-send-email-timur@codeaurora.org>
 <f34cd143-bf04-c17f-b3d6-e3077715a72a@gmail.com>
 <58127E8E.4020301@codeaurora.org>
 <9b817af9-a519-9010-e57b-8de8972088b8@gmail.com>
 <5813AFC1.50506@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: Timur Tabi <timur@codeaurora.org>, netdev@vger.kernel.org,
        zefir.kurtisi@neratec.com, scampbel@codeaurora.org,
        alokc@codeaurora.org, shankerd@codeaurora.org, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34821 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761918AbcJ1VED (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 17:04:03 -0400
Received: by mail-pf0-f193.google.com with SMTP id s8so2154969pfj.2
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 14:04:03 -0700 (PDT)
In-Reply-To: <5813AFC1.50506@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/28/2016 01:06 PM, Timur Tabi wrote:
> Florian Fainelli wrote:
>> On 10/27/2016 03:24 PM, Timur Tabi wrote:
>>> Florian Fainelli wrote:
>>>
>>>> Hu? In my experience that should not come from supporting Pause frames
>>>> or not, but rather properly configuring a (RG)MII delay, but your
>>>> mileage may vary.
>>>
>>> I can assure you, I'm more confused than you.  I've been working in this
>>> for almost two weeks, and not only does this patch align with other phy
>>> drivers, but it does fix my bug.  Without this patch, phylib does not
>>> set the pause frame bits (10 and 11) in MII_ADVERTISE.
>>
>> And that's expected, but if your MAC does not act upon phydev->pause and
>> phydev->asym_pause, then chances are that you can indeed lose packets
>> every once in a while.
> 
> Can you give me more details on that?  I'm not really an expert on our
> MAC, so I'm not sure how it's supposed to work.  The MAC supports the
> concept of "flow control".  The non-upstream version of my driver reads
> PHY register 0x11, which apparently is a PHY-specific status register
> that says whether or not "transmit pause" and "receive pause" is
> enabled.  (The AT8031 datasheet is here, if you'd like to read it:
> http://www.datasheet-pdf.com/datasheet/AtherosCommunications/734720/AR8031.pdf.html).

How it works is that you read phydev->pause and phydev->asym_pause to
know what your link partner advertises in terms of flow control/pause
frame (they are the same thing here). Based on that, and your local
settings (from ethool -A) you advertise/enable flow control as well or
don't do it, and the result is either both agree on what is being used,
flow control is enabled, end-to-end, or it is not. It's exactly the same
thing as speed, except that there is a possibly to do asymetric things,
where flow control is only enabled in one direction or the other.

The way this works is this:

You transmit data, faster than your link partner can process it (busy
receiving, loaded, you name it), it sends back Pause frames back at you
(see below for how this is typically implemented), your MAC gets these
Pause frames back, which feed into the transmit logic, your TX
completion interrupt gets signaled slower than the actual data rate you
are pushing to your link partner, you call dev_kfree_skb() a little
slower from your TX completion handler, the networking stack knows this
means to back off, your transmission rate adjusts to your link partner's
processing capability, no packets get lost.

Conversely, if you were receiving a stream of packets that you have a
hard time keeping up with, the part of your Ethernet MAC that fills
system memory with packets should realize that it is producing them
faster than you are consuming them, this triggers the flow control
mechanism of your MAC receiver, and it sends Pause frames back at the
link partner.

> 
> 
> If both are enabled in the PHY, then the driver enables the same
> features in the MAC.  Unfortunately, I don't have any documentation that
> explains that that really means.  I've tried enabling and disabling this
> feature in the MAC, and it makes no difference.  You would think that if
> the feature is disabled in both the MAC and the PHY, then no packets
> would be lost, but that's not the case.

The PHY does not participate in flow control, other than passing frames
through (and your Atheros PHY may have a register to control that
passthrough, but that would be surprising, could not find one).

> 
>> The part that is totally crappy about Pause frames and PHYLIB is that we
>> need some information about whether this should be supported or not,
>> such that we can change MII_ADVERTISE accordingly to reflect that, and
>> what best way to do this than use one of these SUPPORTED_* bits to set
>> that, except, that unlike speed (which is both a MAC and PHY property),
>> Pause is exclusively MAC, yet, it transpires in PHYLIB.
> 
> Then what do those bits in register 0x11 do?  If I don't set them, I
> lose packets, no matter how my MAC is programmed.

This is just a status register, as you can see, all bits are read-only,
it just aggregates the resolution of what is advertised and what is
negotiated, which is not without value, but PHYLIB does the same
intersection here.

> 
> It's like that joke, "Doctor, if I hold my arm like this, then it
> hurts!", "Well, then don't hold your arm like that."  If I don't program
> those PHY register bits, then my hardware doesn't work.
> 
>> MACs that I work with for instance need to be told to ignore pause
>> frames, or not ignore them, it all depends on what you want to
>> advertise/support.
> 
> That's the problem, I don't know what I "want", except that I want my
> hardware to work. :-)  99% of my knowledge of the hardware comes from
> scanning the source code of the internal version of the driver that 1)
> does not support phylib,  and 2) is hard-coded to initialize the Atheros
> 8031 PHY.

May I suggest reading about standards a bit more, or just looking at
other drivers, like tg3.c.

> 
>>>> It does not, support for Pause frames is a MAC-level feature, yet,
>>>> PHYLIB (and that's been on my todo for a while now) insists on
>>>> reporting
>>>> the confusing phydev->pause and phydev->asym_pause, which really is
>>>> what
>>>> has been determined from auto-negotiating with your partner, as opposed
>>>> to being a supported thing or not. The PHY has absolutely not business
>>>> in that.
>>>
>>> But there are pause frame bits in the MII_ADVERTISE register, and this
>>> setting directly impacts whether those bits are set.  I don't see how
>>> this is a MAC-level feature.
>>
>> This is a MAC level feature, that needs to be auto-negotiated with your
>> link partner, which is why there is room for this in MII_ADVERTISE, but
>> the PHY absolutely does not participate in Pause frames, other than
>> passing them through the MAC, like normal frames. Whether your MAC acts
>> upon that or not is a MAC dependent feature.
> 
> Ok, to me that means that the PHY driver must tell phylib whether or not
> it supports pause frames.  The question becomes:
> 
> 1) Is my patch correct?
> 2) Is my patch necessary?
> 3) Is my patch sufficient?

Your patch is correct but also insufficient, although, as indicated
before, there is an misconception with PHY drivers that they should be
setting SUPPORTED_*Pause* bits, the MAC should do that, based on what it
does, anyway, but more importantly you need to have your Ethernet MAC
react properly upon what the auto-negotiation and locally configured
pause/flow control settings are, and configure the Ethernet MAC accordingly.

When you want pause frames to be enabled, you need to advertise them,
and in order to do so, you need to set phydev->supported to have
SUPPORTED_Pause and SUPPORTED_AsymPause, and call genphy_restart_aneg()
to transfer that to a write to the MII_ADVERTISE register, resulting in
your link partner to see that you now support Pause frames. Since pause
frames are now in use, you want your Ethernet MAC, not to ignore pause
frames (have flow control enabled).

> 
> 1) I believe my patch is correct, because many other PHY drivers do the
> same thing for the same reason.  If the PHY supports register 4 bits 10
> and 11, then those SUPPORTED_xxx bits should be set.
> 
> 2) I don't know why my patch appears to be necessary, because I don't
> understand why a 1Gb NIC on a 2Ghz processor drops frames.  I suspect
> the program is not performance but rather a mis-programming.
> 
> 4) Is my patch sufficient?  The internal driver always enables pause
> frame support in the PHY if the PHY says that pause frames are enabled.
>  In fact, I can't even turn off flow control in the internal driver:

Please stop abusing this "PHY says", the PHY advertises what it is being
told to advertise, by the MAC...

> 
> $ sudo ethtool -A eth1 tx off rx off
> $ sudo ethtool -a eth1
> Pause parameters for eth1:
> Autonegotiate:  on
> RX:             on
> TX:             on
> 
> The driver insists on leaving flow control enabled if autonegotiation is
> enabled.

Actually, the driver forces the enabling of flow control in the MAC,
period, but does not do anything with the auto-negotiation results, or I
could not spot it.

This was spotted in the review, but not addressed, but your adjust_link
callback seems completely bogus, it does a full MAC stop,
reconfiguration and restart, that is at best unnecessary and costly, but
it also misses a few things and does not act upon reading phydev->pause
and phydev->asym_pause to set or clear TXFC and RXFC, that really seems
to be your problem here.

Here is what could possibly go wrong right now:

- your Ethernet MAC unconditionally enables flow control at the MAC
level, but does not advertise support for that in MII_ADVERTISE until
you set SUPPORTED_Pause and SUPPORTED_Asym_Pause in the PHY driver, fair
enough

- the link partner you are testing against does not keep up well with
your transmit rates, but supports flow control, so Pause frames that it
sends back at you to tell you to stop transmitting so quickly just get
ignored, because not being advertised, you experience packet loss
-- 
Florian
