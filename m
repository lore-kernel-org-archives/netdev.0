From: Roger Quadros <rogerq@ti.com>
Subject: Re: [RFC PATCH] net: phy: Don't miss phy_suspend() on PHY_HALTED for
 PHYs with interrupts
Date: Tue, 21 Mar 2017 12:09:55 +0200
Message-ID: <625a9ee1-ea65-3991-2f5c-df95ddf12700@ti.com>
References: <1489585887-8683-1-git-send-email-rogerq@ti.com>
 <20170315140811.GD21021@lunn.ch>
 <6ec42ad7-0be3-f6c5-2ded-27bf3adbab23@ti.com>
 <20170315154912.GE21021@lunn.ch>
 <6d3f2d3c-69e0-43a4-9862-126a7c173934@ti.com>
 <e69e9b50-3223-d5d4-e003-dd04e741387d@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <davem@davemloft.net>, <kyle.roeschley@ni.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx209.ext.ti.com ([198.47.19.16]:40368 "EHLO
        fllnx209.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932263AbdCUKSf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 06:18:35 -0400
In-Reply-To: <e69e9b50-3223-d5d4-e003-dd04e741387d@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20/03/17 18:41, Florian Fainelli wrote:
> On 03/16/2017 12:46 AM, Roger Quadros wrote:
>> On 15/03/17 17:49, Andrew Lunn wrote:
>>> On Wed, Mar 15, 2017 at 05:00:08PM +0200, Roger Quadros wrote:
>>>> Andrew,
>>>>
>>>> On 15/03/17 16:08, Andrew Lunn wrote:
>>>>> On Wed, Mar 15, 2017 at 03:51:27PM +0200, Roger Quadros wrote:
>>>>>> Since commit 3c293f4e08b5 ("net: phy: Trigger state machine on state change and not polling.")
>>>>>> phy_suspend() doesn't get called as part of phy_stop() for PHYs using
>>>>>> interrupts because the phy state machine is never triggered after a phy_stop().
>>>>>>
>>>>>> Explicitly trigger the PHY state machine so that it can
>>>>>> see the new PHY state (HALTED) and suspend the PHY.
>>>>>>
>>>>>> Signed-off-by: Roger Quadros <rogerq@ti.com>
>>>>>
>>>>> Hi Roger
>>>>>
>>>>> This seems sensible. It mirrors what phy_start() does.
>>>>>
>>>>> Reviewed-by: Andrew Lunn <andrew@lunn.ch>
>>>>
>>>> The reason for this being an RFC was the following comment just before
>>>> where I add the phy_trigger_machine()
>>>>
>>>>         /* Cannot call flush_scheduled_work() here as desired because
>>>>          * of rtnl_lock(), but PHY_HALTED shall guarantee phy_change()
>>>>          * will not reenable interrupts.
>>>>          */
>>>>
>>>> Is this comment still applicable? If yes, is it OK to call
>>>> phy_trigger_machine() there?
>>>
>>> Humm, good question.
>>>
>>> My _guess_ would be, calling it with sync=True could
>>> deadlock. sync=False is probably safe. But lets see what Florian says.
>>
>> I agree that we should use phy_trigger_machine() with sync=False.
>>
>>>
>>>>
>>>>>
>>>>> It does however lead to a follow up question. Are there other places
>>>>> phydev->state is changed and it is missing a phy_trigger_machine()?
>>>>>
>>>>
>>>> One other place I think we should add phy_trigger_machine() is phy_start_aneg().
>>>
>>> Humm, that might get us into a tight loop.
>>>
>>> phy_start_aneg() kicks the phy driver to start autoneg and sets
>>> phydev->state = PHY_AN.
>>>
>>> phy_trigger_machine() triggers the state machine immediately. 
>>>
>>> In state PHY_AN, we check if aneg is done. If not, it sets needs_aneg
>>> = true. At the end of the state machine, this then calls
>>> phy_start_aneg(), and it all starts again.
>>>
>>> We are missing the 1s delay we have with polling. So for
>>> phy_start_aneg(), we might need a phy_delayed_trigger_machine(), which
>>> waits a second before doing anything?
>>
>> I think that should do the trick.
>>
>> How about this?
> 
> This sounds like a possible fix indeed, however I would like to better
> assess the impact on non interrupt driven PHYs before rolling such a change.

Is it safer if I add a check to do this only for interrupt driven PHYs?

e.g.

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 4b855f2..e0f5755 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -630,6 +630,9 @@ int phy_start_aneg(struct phy_device *phydev)
 
 out_unlock:
 	mutex_unlock(&phydev->lock);
+	if (!err && phy_interrupt_is_valid(phydev))
+		queue_delayed_work(system_power_efficient_wq, &phydev->state_queue, HZ);
+
 	return err;
 }
 EXPORT_SYMBOL(phy_start_aneg);
-- 
2.7.4

-- 
cheers,
-roger
