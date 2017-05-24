From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/2] at803x: double check SGMII side autoneg
Date: Wed, 24 May 2017 14:19:58 -0700
Message-ID: <e2fbb91e-95ef-49a0-dfd9-0e6cc23925fa@gmail.com>
References: <20170522213206.GT29447@lunn.ch>
 <a8415b8b-1713-053d-41d3-2577c5a53c8b@codeaurora.org>
 <20170523160722.GC21169@lunn.ch>
 <3dc4f9cf-3172-0227-f03c-1ccfdad3e15e@codeaurora.org>
 <a87a7309-e15e-286f-08d0-83535c094358@neratec.com>
 <a88a111d-5e3a-0999-14ef-0ada06febb3f@codeaurora.org>
 <20170524134021.GA26577@lunn.ch>
 <8cf4ca6d-3e1e-3c9c-605f-5d6baf3c7588@codeaurora.org>
 <20170524140929.GC26577@lunn.ch>
 <c2a54e2e-a1b6-24b4-d125-95fa9648fe95@codeaurora.org>
 <20170524193450.GC1788@lunn.ch>
 <d6a23db1-2465-b315-f520-63aba0341fbe@quicinc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Matthias May <matthias.may@neratec.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
        Manoj Iyer <manoj.iyer@canonical.com>, jhugo@codeaurora.org
To: Timur Tabi <timur@qti.qualcomm.com>, Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:34188 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032657AbdEXVUG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 17:20:06 -0400
Received: by mail-qk0-f193.google.com with SMTP id u75so28020571qka.1
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 14:20:05 -0700 (PDT)
In-Reply-To: <d6a23db1-2465-b315-f520-63aba0341fbe@quicinc.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/24/2017 01:57 PM, Timur Tabi wrote:
> On 05/24/2017 02:34 PM, Andrew Lunn wrote:
>>> Ok, I'm going to debug this some more.  It turns out that the MAC
>>> side of
>>> the SGMII link can send an interrupt when it thinks that
>>> auto-negotiation is
>>> done.  I might be able to use this.
>>
>> You can use this for your board. But it still leaves the phy driver
>> broken for everybody else.
> 
> Wait, I thought you said the at803x driver was not broken, since it
> returns 0 when the SGMII side of the link hasn't finished auto-negotiating?
> 
>>> What function should my MAC driver call when it wants the phy core to
>>> call
>>> at803x_aneg_done again to see if autonegotiation is done?
>>
>> You want to trigger the PHY state machine. There is only one exported
>> API call to do this, phy_mac_interrupt(). But you are supposed to pass
>> the new link state. And your MAC driver has no idea of that, it does
>> not know if the copper side of the PHY is up.
> 
> My NIC has a feature called autopolling where it takes over the MDIO bus
> and regularly polls the link state.  When it detects that the link state
> has changed, it generates a MAC interrupt.  This is when I call
> phy_mac_interrupt() normally.
> 
> I think I can use the SGMII interrupt to also call phy_mac_interrupt().
> The problem is the from the copper side, the link is already up, so if I
> call phy_mac_interrupt() again and say the link is up, the phy core is
> going to ignore that.

The question is what the HW is auto-polling on? Most HW implementations
that I have seen either auto-poll and assume that BMSR.LINKSTATUS will
reflect what they want to, or they even let you specify which register
and bit(s) to monitor for link status. So which one is it here?

As Andrew already responded, this clashes with any reads/writes that the
PHY library could do, unless your HW is smart enough to serialize MDIO
reads/writes?

> 
>> So it might be better if you export phy_trigger_machine().
> 
> I'll test that, but that does seem a bit hackish.
> 
>>> Also, is there a way for the MAC driver to know that at803x_aneg_done()
>>> previously returned 0, and that it needs to tell the phy core to
>>> check again?
>>
>> Not that i know of. The MAC layer is not supposed to be messing around
>> in the PHY layer. However, just triggering the PHY state machine
>> should be enough.
> 
> Can you tell my how PHY_HAS_INTERRUPT is supposed to work?  How does the
> PHY send an interrupt?

PHY_HAS_INTERRUPT indicates that you have a dedicated interrupt line for
your PHY device and that you have the ability to implement a custom
interrupt handling callback in the PHY driver (ack_interrupt) that lets
you deal with all possible sorts of the interrupts that the PHY could
generate.

> 
> I'm starting to think that my NIC's autopolling feature is not
> compatible with phylib, and that I should use polling mode.

That's pretty much what Andrew told you about 5 emails ago...
-- 
Florian
