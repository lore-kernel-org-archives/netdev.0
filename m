From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] Revert "net: phy: Correctly process PHY_HALTED in
 phy_stop_machine()"
Date: Thu, 31 Aug 2017 09:57:58 -0700
Message-ID: <931bf454-81ff-94dc-82e6-bc2b889bd43a@gmail.com>
References: <1504140569-2063-1-git-send-email-f.fainelli@gmail.com>
 <f4bb5ac8-dae8-c0af-7aa6-e546fc0783fa@sigmadesigns.com>
 <e24693e8-d8ae-188a-2a38-c9a83fdc94e3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        David Miller <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>,
        Mason <slash.tmp@free.fr>
To: David Daney <ddaney.cavm@gmail.com>,
        Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:37217 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751834AbdHaQ6I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 12:58:08 -0400
Received: by mail-wm0-f66.google.com with SMTP id x189so191178wmg.4
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 09:58:07 -0700 (PDT)
In-Reply-To: <e24693e8-d8ae-188a-2a38-c9a83fdc94e3@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/31/2017 09:36 AM, David Daney wrote:
> On 08/31/2017 05:29 AM, Marc Gonzalez wrote:
>> On 31/08/2017 02:49, Florian Fainelli wrote:
>>
>>> This reverts commit 7ad813f208533cebfcc32d3d7474dc1677d1b09a ("net: phy:
>>> Correctly process PHY_HALTED in phy_stop_machine()") because it is
>>> creating the possibility for a NULL pointer dereference.
>>>
>>> David Daney provide the following call trace and diagram of events:
>>>
>>> When ndo_stop() is called we call:
>>>
>>>   phy_disconnect()
>>>      +---> phy_stop_interrupts() implies: phydev->irq = PHY_POLL;
>>
>> What does this mean?
> 
> I meant that after the call to phy_stop_interrupts(), phydev->irq =
> PHY_POLL;
> 
> 
>>
>> On the contrary, phy_stop_interrupts() is only called when *not* polling.
> 
> That is the case I have.  We are using interrupts from the phy.
> 
> 
>>
>>     if (phydev->irq > 0)
>>         phy_stop_interrupts(phydev);
>>
>>>      +---> phy_stop_machine()
>>>      |      +---> phy_state_machine()
>>>      |              +----> queue_delayed_work(): Work queued.
>>
>> You're referring to the fact that, at the end of phy_state_machine()
>> (in polling mode) the code reschedules itself through:
>>
>>     if (phydev->irq == PHY_POLL)
>>         queue_delayed_work(system_power_efficient_wq,
>> &phydev->state_queue, PHY_STATE_TIME * HZ);
> 
> Exactly.  The call to phy_disconnect() ensures that there are no more
> interrupts and also that phydev->irq = PHY_POLL
> 
> The call to cancel_delayed_work_sync() at the top of phy_stop_machine()
> was meant to ensure that phy_state_machine() was never run again.  No
> interrupts + no queued work means that it should be save to do...
> 
>>
>>>      +--->phy_detach() implies: phydev->attached_dev = NULL;
> 
> The problem is that by calling phy_state_machine() again (which the
> offending patch added) we now have work scheduled that will try to
> dereference the pointer that was set to NULL as a result of the
> phy_detach()

And the race is between phy_detach() setting phydev->attached_dev = NULL
and phy_state_machine() running in PHY_HALTED state and calling
netif_carrier_off().

> 
> 
>>>
>>> Now at a later time the queued work does:
>>>
>>>   phy_state_machine()
>>>      +---->netif_carrier_off(phydev->attached_dev): Oh no! It is NULL:
>>
>> I tested a sequence of 500 link up / link down in polling mode,
>> and saw no such issue. Race condition?
>>
> 
> You were lucky.

I too tested this a number of times on a 2 core and 4 core system, but
the race is there, both of us just were lucky enough we did not see any
crash. I suspect the race is easier to reproduce on a (at least 12 core)
system with possibly a higher clock speed.

> 
>> For what case in phy_state_machine() is netif_carrier_off()
>> being called? Surely not PHY_HALTED?
>>
> 
> The phy can be in a variety of states.  It is connected to something
> outside of the system that we don't control, so you cannot assume any
> particular state.  We must have code that doesn't crash the system no
> matter what state the phy is in.
> 
> I suspect, but have not checked, that the phy is in PHY_RUNNING.  I
> think that means that because this patch turned the state machine back
> on, it will start transitioning through PHY_UP, PHY_AN, ... and
> eventually get to the crash we see because phydev->attached_dev = NULL

I actually think the PHY remains in PHY_HALTED but just re-schedules
itself and keeps being in PHY_HALTED again until a call to phy_resume or
phy_start() moves it back to another state. This is largely inefficient,
and we should look into using the patch I posted yesterday which would
prevent a re-schedule when moved to PHY_HALTED:

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index d0626bf5c540..78168e19bd5d 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -1234,7 +1234,7 @@ void phy_state_machine(struct work_struct *work)
         * PHY, if PHY_IGNORE_INTERRUPT is set, then we will be moving
         * between states from phy_mac_interrupt()
         */
-       if (phydev->irq == PHY_POLL)
+       if (phydev->irq == PHY_POLL && phydev->state != PHY_HALTED)
                queue_delayed_work(system_power_efficient_wq,
&phydev->state_queue,
                                   PHY_STATE_TIME * HZ);
 }



-- 
Florian
