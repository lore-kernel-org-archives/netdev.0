From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Problem with PHY state machine when using interrupts
Date: Mon, 24 Jul 2017 12:53:58 -0700
Message-ID: <0f56083f-d43e-a141-1470-b76546af6d58@gmail.com>
References: <65b9f1f5-724c-cd03-1c39-59405e773efa@free.fr>
 <849513d9-c981-ec20-5a10-08c663d0aa37@free.fr>
 <02e9e171-ec22-e491-5bc8-ef4b3ad7fec2@gmail.com>
 <e6a7a5df-b735-6f9c-6a2b-cded86ec6525@free.fr>
 <b0410a73-ff2d-ca06-93fa-17af2040c41c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Mason <slash.tmp@free.fr>, Andrew Lunn <andrew@lunn.ch>,
        Mans Rullgard <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:38243 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750796AbdGXTyD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 15:54:03 -0400
Received: by mail-wm0-f49.google.com with SMTP id m85so26040844wma.1
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 12:54:03 -0700 (PDT)
In-Reply-To: <b0410a73-ff2d-ca06-93fa-17af2040c41c@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/24/2017 12:32 PM, Florian Fainelli wrote:
> On 07/24/2017 12:13 PM, Mason wrote:
>> On 24/07/2017 18:49, Florian Fainelli wrote:
>>
>>> On 07/24/2017 08:01 AM, Mason wrote:
>>>
>>>>> When I set the link down via 'ip link set eth0 down'
>>>>> (as opposed to pulling the Ethernet cable) things don't happen as expected:
>>>>>
>>>>> The driver's adjust_link() callback is never called, and doesn't
>>>>> get a chance make some required changes. And when I set the link
>>>>> up again, there is no network connectivity.
>>>>>
>>>>> I get this problem only if I enable interrupts on my PHY.
>>>>> If I use polling, things work as expected.
>>>>>
>>>>>
>>>>> When I set the link down, devinet_ioctl() eventually calls
>>>>> ndo_set_rx_mode() and ndo_stop()
>>>>>
>>>>> In ndo_stop() the driver calls
>>>>> phy_stop(phydev);
>>>>> which disables interrupts and sets the state to HALTED.
>>>>>
>>>>> In phy_state_machine()
>>>>> the PHY_HALTED case does call the adjust_link() callback:
>>>>>
>>>>> 		if (phydev->link) {
>>>>> 			phydev->link = 0;
>>>>> 			netif_carrier_off(phydev->attached_dev);
>>>>> 			phy_adjust_link(phydev);
>>>>> 			do_suspend = true;
>>>>> 		}
>>>>>
>>>>> But it's not called when I use interrupts...
>>>>>
>>>>> Perhaps because there are no interrupts generated?
>>>>> Or even if there were, they have been turned off by phy_stop?
>>>>>
>>>>> Basically, it seems like when I use interrupts,
>>>>> the phy_state_machine() is not called on link down,
>>>>> which breaks the MAC driver's expectations.
>>>>>
>>>>> Am I barking up the wrong tree?
>>>>
>>>> FWIW, the patch below solves my issue.
>>>> Basically, we reset the MAC in open(), instead of probe().
>>>>
>>>> I also had to solve the issue of adjust_link() not being
>>>> called by calling it explicitly in stop() instead of
>>>> relying on phy_stop() to do it indirectly.
>>>
>>> Which is of course absolutely not how it is intended to be used.
>>> phy_stop() does the following:
>>>
>>> - if the PHY was already HALTED do nothing and exit
>>> - if it was not and an interrupt is valid for this PHY:  disable and
>>> clear these interrupts
>>> - set state to PHY_HALTED
>>>
>>> somehow an interrupt should be generated from doing this such that
>>> phy_change(), invoked from phy_interrupt() should have a chance to run
>>> and make the PHY state machine transition properly to PHY_HALTED.
>>
>> I'm totally confused. Are you saying that phy_stop itself
>> should trigger an interrupt, or that the process of setting
>> the link down should generate an interrupt *before* we reach
>> phy_stop?
> 
> My reading of the code, and because I don't actually have a system where
> PHY interrupts proper are used (only polling or PHY_IGNORE INTERRUPT) is
> that, yes, somehow calling phy_stop() should result in a PHY interrupt
> to be generated making the state machine move to PHY_HALTED.
> 
>>
>> I'm also perplex over this synchronous IRQ business.
>> Should I be looking for a way to trigger an IRQ in
>> software in the Atheros PHY?
> 
> No, first understand the problem and what is going on before trying to
> workaround things in the PHY driver, there were questions for you as to
> what state the PHY state machine is left in we need to see that to
> understand how to possibly fix what you are seeing.
> 
>>
>> Before I forget: there is also an issue when using the PHY
>> in polling mode. The ndo_stop callback runs through phy_stop
>> and phy_disconnect too fast for the adjust_link() callback
>> to be called. My patch fixed that too, by calling
>> nb8800_link_reconfigure() explicitly.
> 
> Most, if not all drivers should have this:
> 
> ndo_open() calls phy_connect() or phy_attach() + phy_start() because
> that allows you to properly manage the PHY's power state and the state
> machine, the reciprocal is to have ndo_stop() call phy_disconnect() (and
> just that) which properly waits for the PHY state machine to be fully
> stopped.
> 
> phy_stop() returns immediately but the PHY state machine only gets
> stopped asynchronously at a later time, either with an interrupt or with
> an explicit work queue scheduling. If you call phy_disconnect() right
> after, this cancels the work queue and it may not have run the
> adjust_link callback yet.
> 
>>
>>
>>> So from there can you check a few things:
>>>
>>> - is such an interrupt actually generated?
>>> - if you turn on dynamic debug prints for drivers/net/phy/phy.c where do
>>> we leave the PHY state machine and what state is it in when you call
>>> ifconfig up again?
>>
>> The only interrupts I've ever seen the PHY generate are
>> on plugging/unplugging the Ethernet cable.
>>
>> Looking at the driver and datasheet...
>> http://elixir.free-electrons.com/linux/v4.13-rc2/source/drivers/net/phy/at803x.c#L312
>> 		value |= AT803X_INTR_ENABLE_AUTONEG_ERR;
>> 		value |= AT803X_INTR_ENABLE_SPEED_CHANGED;
>> 		value |= AT803X_INTR_ENABLE_DUPLEX_CHANGED;
>> 		value |= AT803X_INTR_ENABLE_LINK_FAIL;
>> 		value |= AT803X_INTR_ENABLE_LINK_SUCCESS;
>>
>> And the interrupts reasons supported by the PHY are:
>> #define AT803X_INTR_ENABLE_AUTONEG_ERR		BIT(15)
>> #define AT803X_INTR_ENABLE_SPEED_CHANGED	BIT(14)
>> #define AT803X_INTR_ENABLE_DUPLEX_CHANGED	BIT(13)
>> #define AT803X_INTR_ENABLE_PAGE_RECEIVED	BIT(12)
>> #define AT803X_INTR_ENABLE_LINK_FAIL		BIT(11)
>> #define AT803X_INTR_ENABLE_LINK_SUCCESS		BIT(10)
>> #define AT803X_INTR_ENABLE_WIRESPEED_DOWNGRADE	BIT(5)
>> #define AT803X_INTR_ENABLE_POLARITY_CHANGED	BIT(1)
>> #define AT803X_INTR_ENABLE_WOL			BIT(0)
>>
>> These all seem to be external reasons (from the peer).
>>
>> I did enable debug logs in drivers/net/phy/phy.c
>> to trace the state machine, and it is not called
>> at all on set link down, so it remains in state
>> RUNNING (both in polling and interrupt modes).

Well now that I see the possible interrupts generated, I indeed don't
see how you can get a link down notification unless you somehow force
the link down yourself, which would certainly happen in phy_suspend()
when we set BMCR.pwrdwn, but that may be too late.

You should still expect the adjust_link() function to be called though
with PHY_HALTED being set and that takes care of doing phydev->link = 0
and netif_carrier_off(). If that still does not work, then see whether
removing the call to phy_stop() does help (it really should).
-- 
Florian
