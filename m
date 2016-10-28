From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] net: phy: at803x: the Atheros 8031 supports pause frames
Date: Fri, 28 Oct 2016 15:06:25 -0500
Message-ID: <5813AFC1.50506@codeaurora.org>
References: <1477605901-30906-1-git-send-email-timur@codeaurora.org>
 <f34cd143-bf04-c17f-b3d6-e3077715a72a@gmail.com>
 <58127E8E.4020301@codeaurora.org>
 <9b817af9-a519-9010-e57b-8de8972088b8@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        zefir.kurtisi@neratec.com, scampbel@codeaurora.org,
        alokc@codeaurora.org, shankerd@codeaurora.org, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:38026 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760727AbcJ1UG2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 16:06:28 -0400
In-Reply-To: <9b817af9-a519-9010-e57b-8de8972088b8@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli wrote:
> On 10/27/2016 03:24 PM, Timur Tabi wrote:
>> Florian Fainelli wrote:
>>
>>> Hu? In my experience that should not come from supporting Pause frames
>>> or not, but rather properly configuring a (RG)MII delay, but your
>>> mileage may vary.
>>
>> I can assure you, I'm more confused than you.  I've been working in this
>> for almost two weeks, and not only does this patch align with other phy
>> drivers, but it does fix my bug.  Without this patch, phylib does not
>> set the pause frame bits (10 and 11) in MII_ADVERTISE.
>
> And that's expected, but if your MAC does not act upon phydev->pause and
> phydev->asym_pause, then chances are that you can indeed lose packets
> every once in a while.

Can you give me more details on that?  I'm not really an expert on our 
MAC, so I'm not sure how it's supposed to work.  The MAC supports the 
concept of "flow control".  The non-upstream version of my driver reads 
PHY register 0x11, which apparently is a PHY-specific status register 
that says whether or not "transmit pause" and "receive pause" is 
enabled.  (The AT8031 datasheet is here, if you'd like to read it: 
http://www.datasheet-pdf.com/datasheet/AtherosCommunications/734720/AR8031.pdf.html).

If both are enabled in the PHY, then the driver enables the same 
features in the MAC.  Unfortunately, I don't have any documentation that 
explains that that really means.  I've tried enabling and disabling this 
feature in the MAC, and it makes no difference.  You would think that if 
the feature is disabled in both the MAC and the PHY, then no packets 
would be lost, but that's not the case.

> The part that is totally crappy about Pause frames and PHYLIB is that we
> need some information about whether this should be supported or not,
> such that we can change MII_ADVERTISE accordingly to reflect that, and
> what best way to do this than use one of these SUPPORTED_* bits to set
> that, except, that unlike speed (which is both a MAC and PHY property),
> Pause is exclusively MAC, yet, it transpires in PHYLIB.

Then what do those bits in register 0x11 do?  If I don't set them, I 
lose packets, no matter how my MAC is programmed.

It's like that joke, "Doctor, if I hold my arm like this, then it 
hurts!", "Well, then don't hold your arm like that."  If I don't program 
those PHY register bits, then my hardware doesn't work.

> MACs that I work with for instance need to be told to ignore pause
> frames, or not ignore them, it all depends on what you want to
> advertise/support.

That's the problem, I don't know what I "want", except that I want my 
hardware to work. :-)  99% of my knowledge of the hardware comes from 
scanning the source code of the internal version of the driver that 1) 
does not support phylib,  and 2) is hard-coded to initialize the Atheros 
8031 PHY.

>>> It does not, support for Pause frames is a MAC-level feature, yet,
>>> PHYLIB (and that's been on my todo for a while now) insists on reporting
>>> the confusing phydev->pause and phydev->asym_pause, which really is what
>>> has been determined from auto-negotiating with your partner, as opposed
>>> to being a supported thing or not. The PHY has absolutely not business
>>> in that.
>>
>> But there are pause frame bits in the MII_ADVERTISE register, and this
>> setting directly impacts whether those bits are set.  I don't see how
>> this is a MAC-level feature.
>
> This is a MAC level feature, that needs to be auto-negotiated with your
> link partner, which is why there is room for this in MII_ADVERTISE, but
> the PHY absolutely does not participate in Pause frames, other than
> passing them through the MAC, like normal frames. Whether your MAC acts
> upon that or not is a MAC dependent feature.

Ok, to me that means that the PHY driver must tell phylib whether or not 
it supports pause frames.  The question becomes:

1) Is my patch correct?
2) Is my patch necessary?
3) Is my patch sufficient?

1) I believe my patch is correct, because many other PHY drivers do the 
same thing for the same reason.  If the PHY supports register 4 bits 10 
and 11, then those SUPPORTED_xxx bits should be set.

2) I don't know why my patch appears to be necessary, because I don't 
understand why a 1Gb NIC on a 2Ghz processor drops frames.  I suspect 
the program is not performance but rather a mis-programming.

4) Is my patch sufficient?  The internal driver always enables pause 
frame support in the PHY if the PHY says that pause frames are enabled. 
  In fact, I can't even turn off flow control in the internal driver:

$ sudo ethtool -A eth1 tx off rx off
$ sudo ethtool -a eth1
Pause parameters for eth1:
Autonegotiate:  on
RX:             on
TX:             on

The driver insists on leaving flow control enabled if autonegotiation is 
enabled.

> Yes I am sure you should set these bits, the documentation is not
> necessarily the authoritative source here (although it should). What
> this probably meant to be written is something like: don't set any bits
> that are not defined in ethtool.h, i.e: do not use this to store
> persistent states.

So when I do that, it works.  I force those bits on in my driver, and 
pause frames are enabled and everything works correctly.

I still would like to know what those bits in register 4 really are for. 
  My understanding is that pause frames are an extension to the 802.3 
standard, and not every PHY supports them, so not even PHY supports 
setting bits 10 and 11 in register 4.  That's why the PHY driver should 
be setting them, not the MAC.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
