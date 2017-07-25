From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Problem with PHY state machine when using interrupts
Date: Mon, 24 Jul 2017 17:30:13 -0700
Message-ID: <8d13509d-7b3e-650e-81ea-7846ec4a825d@gmail.com>
References: <65b9f1f5-724c-cd03-1c39-59405e773efa@free.fr>
 <849513d9-c981-ec20-5a10-08c663d0aa37@free.fr>
 <02e9e171-ec22-e491-5bc8-ef4b3ad7fec2@gmail.com>
 <e6a7a5df-b735-6f9c-6a2b-cded86ec6525@free.fr>
 <b0410a73-ff2d-ca06-93fa-17af2040c41c@gmail.com>
 <0f56083f-d43e-a141-1470-b76546af6d58@gmail.com>
 <c81e12bc-0f89-5eab-547e-f0c1ec389ad8@free.fr>
 <62085f48-df18-f987-f521-dcdfbd7f574b@gmail.com>
 <843eb3cd-3cc0-0b06-2aa8-709f25308437@free.fr>
 <93dcc629-8a9e-9576-7074-aaf2b31b9bfb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Mason <slash.tmp@free.fr>, Andrew Lunn <andrew@lunn.ch>,
        Mans Rullgard <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:37845 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756049AbdGYAaR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 20:30:17 -0400
Received: by mail-qk0-f194.google.com with SMTP id q130so11393042qka.4
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 17:30:17 -0700 (PDT)
In-Reply-To: <93dcc629-8a9e-9576-7074-aaf2b31b9bfb@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/24/2017 03:59 PM, Florian Fainelli wrote:
> On 07/24/2017 03:53 PM, Mason wrote:
>> On 25/07/2017 00:36, Florian Fainelli wrote:
>>> On 07/24/2017 02:20 PM, Mason wrote:
>>>> On 24/07/2017 21:53, Florian Fainelli wrote:
>>>>
>>>>> Well now that I see the possible interrupts generated, I indeed don't
>>>>> see how you can get a link down notification unless you somehow force
>>>>> the link down yourself, which would certainly happen in phy_suspend()
>>>>> when we set BMCR.pwrdwn, but that may be too late.
>>>>>
>>>>> You should still expect the adjust_link() function to be called though
>>>>> with PHY_HALTED being set and that takes care of doing phydev->link = 0
>>>>> and netif_carrier_off(). If that still does not work, then see whether
>>>>> removing the call to phy_stop() does help (it really should).
>>>>
>>>> The only functions setting phydev->state to PHY_HALTED
>>>> are phy_error() and phy_stop() AFAICT.
>>>>
>>>> I am aware that when phy_state_machine() handles the
>>>> PHY_HALTED state, it will set phydev->link = 0;
>>>> and call netif_carrier_off() -- because that's where
>>>> I copied that code from.
>>>>
>>>> My issue is that phy_state_machine() does not run when
>>>> I run 'ip set link dev eth0 down' from the command line.
>>>
>>> Yes, that much is clear, which is why I suggested earlier you try the
>>> patch at the end now.
>>>
>>>>
>>>> If I'm reading the code right, phy_disconnect() actually
>>>> stops the state machine.
>>>>
>>>> In interrupt mode, phy_state_machine() doesn't run
>>>> because no interrupt is generated.
>>>>
>>>> In polling mode, phy_state_machine() doesn't run
>>>> because phy_disconnect() stops the state machine.
>>>>
>>>> Introducing a sleep before phy_disconnect() gives
>>>> the state machine a chance to run in polling mode,
>>>> but it doesn't feel right, and doesn't fix the
>>>> other mode, which I'm using.
>>>
>>> There are several problems it seems:
>>>
>>> - the PHY state machine cannot move solely based on the PHY generating
>>> interrupts during phy_stop() if none of the changing conditions for the
>>> HW have changed, come to think about it, I doubt any PHY would be
>>> capable of doing something like that
>>>
>>> - there is an expectation from your driver to have adjust_link() run
>>> sometime during ndo_stop() to do something, but why?
>>>
>>> What is special about nb8800 that interrupts should be generated during
>>> ndo_stop(), and why do you think this is going to solve your problem?
>>>
>>>>
>>>> Looking at bcm_enet_stop() it calls phy_stop() and
>>>> phy_disconnect() just like the nb8800 driver...
>>>>
>>>> I'm stumped.
>>>
>>> My suggestion of not using phy_stop() was not a good one, but
>>> functionally there is little difference in doing phy_stop() +
>>> phy_disconnect() or just phy_disconnect() alone. What matters is that we
>>> restart the PHY properly when phy_connect() or phy_start() is called.
>>>
>>> What I understand now from your "bug report" is that you want
>>> adjust_link to run with phydev->link = 0 to do something during
>>> ndo_close() but you have not explained why, but I suspect such that upon
>>> ndo_open() things work again.
>>>
>>> What I suspect your bug is, is that the really was no change in link
>>> status, no interrupt was generated because there should not be one, yet
>>> some of what nb8800_stop() does is not properly balanced by
>>> nb8800_open(). How about the following patch:
>>>
>>> diff --git a/drivers/net/ethernet/aurora/nb8800.c
>>> b/drivers/net/ethernet/aurora/nb8800.c
>>> index 041cfb7952f8..b07dea3ab019 100644
>>> --- a/drivers/net/ethernet/aurora/nb8800.c
>>> +++ b/drivers/net/ethernet/aurora/nb8800.c
>>> @@ -972,6 +972,10 @@ static int nb8800_open(struct net_device *dev)
>>>         nb8800_mac_rx(dev, true);
>>>         nb8800_mac_tx(dev, true);
>>>
>>> +       priv->speed = -1;
>>> +       priv->link = -1;
>>> +       priv->duplex = -1;
>>> +
>>>         phydev = of_phy_connect(dev, priv->phy_node,
>>>                                 nb8800_link_reconfigure, 0,
>>>                                 priv->phy_mode);
>>>
>>
>> I will test your two patches ASAP.
>>
>> For the record, I have two (maybe related) issues:
>>
>> 1) After a sequence of
>> ip set link dev eth0 up
>> ip set link dev eth0 down
>> ip set link dev eth0 up
>> RX engine is hosed, thus network connectivity is borked.
>> The work-around is resetting the MAC in ndo_open
>> => mac_init in my proposed patch.
>> This is by far the biggest issue.
>> Also, resetting the MAC in ndo_open will make it easy
>> to implement suspend/resume, as I can just ndo_stop
>> in suspend, and ndo_open in resume.
> 
> OK.
> 
>>
>> 2) The system does not print "Link down" when I run
>> 'ip set link dev eth0 down'
>> This is a symptom of nb8800_link_reconfigure()
>> not being called at all (or being called
>> with phydev->link == priv->link when I tried
>> skipping phy_stop)
> 
> Correct, and there is actually a timing hazard that I could also
> reproduce here in that phy_stop() + phy_disconnect(), will try to cook a
> patch fixing that as well, since that seems highly undesirable.
> 
>>
>> Again, thanks for your patches and suggestions,
>> which I will test in the morning.
>>
>> I will also try to understand why I didn't have
>> these issues on the other board...
> 
> The timing hazard would most certainly be more prominent on certain
> configurations that others.

This should help make sure that you get your adjust_link callback run
when phy_stop() + phy_disconnect() is executed because we would now
properly wait for the state machine transition to complete. Since we use
cancel_delayed_work_sync() this should be safe we won't have room for
the state machine to run again between a call to flush_delayed_work()
and cancel_delayed_work_sync() and even if we did,
cancel_delayed_work_sync() should now take care of that.

This should take care of the polling case, but you probably still need
the other patch for the interrupt-driven case.

Let me know how your testing goes with this.

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index d0626bf5c540..485488d25f5e 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -743,6 +743,7 @@ void phy_trigger_machine(struct phy_device *phydev,
bool sync)
  */
 void phy_stop_machine(struct phy_device *phydev)
 {
+       flush_delayed_work(&phydev->state_queue);
        cancel_delayed_work_sync(&phydev->state_queue);

        mutex_lock(&phydev->lock);

> 


-- 
Florian
