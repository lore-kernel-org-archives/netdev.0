From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: at803x: the Atheros 8031 supports pause frames
Date: Thu, 27 Oct 2016 15:39:20 -0700
Message-ID: <9b817af9-a519-9010-e57b-8de8972088b8@gmail.com>
References: <1477605901-30906-1-git-send-email-timur@codeaurora.org>
 <f34cd143-bf04-c17f-b3d6-e3077715a72a@gmail.com>
 <58127E8E.4020301@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: Timur Tabi <timur@codeaurora.org>, netdev@vger.kernel.org,
        zefir.kurtisi@neratec.com, scampbel@codeaurora.org,
        alokc@codeaurora.org, shankerd@codeaurora.org, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33093 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S943004AbcJ0WjY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 18:39:24 -0400
Received: by mail-pf0-f196.google.com with SMTP id i85so3732732pfa.0
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 15:39:24 -0700 (PDT)
In-Reply-To: <58127E8E.4020301@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/2016 03:24 PM, Timur Tabi wrote:
> Florian Fainelli wrote:
> 
>> Hu? In my experience that should not come from supporting Pause frames
>> or not, but rather properly configuring a (RG)MII delay, but your
>> mileage may vary.
> 
> I can assure you, I'm more confused than you.  I've been working in this
> for almost two weeks, and not only does this patch align with other phy
> drivers, but it does fix my bug.  Without this patch, phylib does not
> set the pause frame bits (10 and 11) in MII_ADVERTISE.

And that's expected, but if your MAC does not act upon phydev->pause and
phydev->asym_pause, then chances are that you can indeed lose packets
every once in a while.

The part that is totally crappy about Pause frames and PHYLIB is that we
need some information about whether this should be supported or not,
such that we can change MII_ADVERTISE accordingly to reflect that, and
what best way to do this than use one of these SUPPORTED_* bits to set
that, except, that unlike speed (which is both a MAC and PHY property),
Pause is exclusively MAC, yet, it transpires in PHYLIB.

MACs that I work with for instance need to be told to ignore pause
frames, or not ignore them, it all depends on what you want to
advertise/support.

> 
>> It does not, support for Pause frames is a MAC-level feature, yet,
>> PHYLIB (and that's been on my todo for a while now) insists on reporting
>> the confusing phydev->pause and phydev->asym_pause, which really is what
>> has been determined from auto-negotiating with your partner, as opposed
>> to being a supported thing or not. The PHY has absolutely not business
>> in that.
> 
> But there are pause frame bits in the MII_ADVERTISE register, and this
> setting directly impacts whether those bits are set.  I don't see how
> this is a MAC-level feature.

This is a MAC level feature, that needs to be auto-negotiated with your
link partner, which is why there is room for this in MII_ADVERTISE, but
the PHY absolutely does not participate in Pause frames, other than
passing them through the MAC, like normal frames. Whether your MAC acts
upon that or not is a MAC dependent feature.

> 
>> Your change should probably be in the Ethernet MAC driver, when you have
>> successfully connected to the PHY, update phydev->supported to include
>> SUPPORTED_Pause | SUPPORTED_Asym_pause.
> 
> The phylib documentation (networking/phy.txt) says:
> 
>  Now just make sure that phydev->supported and phydev->advertising have any
>  values pruned from them which don't make sense for your controller (a
> 10/100
>  controller may be connected to a gigabit capable PHY, so you would need to
>  mask off SUPPORTED_1000baseT*).  See include/linux/ethtool.h for
> definitions
>  for these bitfields.
> 
> and then it says:
> 
>> Note that you should not SET any bits, or the PHY may
>>  get put into an unsupported state.
> 
> So are you sure I'm supposed to set those bits?

Yes I am sure you should set these bits, the documentation is not
necessarily the authoritative source here (although it should). What
this probably meant to be written is something like: don't set any bits
that are not defined in ethtool.h, i.e: do not use this to store
persistent states.
-- 
Florian
