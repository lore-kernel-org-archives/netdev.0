From: David Daney <ddaney.cavm@gmail.com>
Subject: Re: [PATCH net] Revert "net: phy: Correctly process PHY_HALTED in
 phy_stop_machine()"
Date: Thu, 31 Aug 2017 09:36:19 -0700
Message-ID: <e24693e8-d8ae-188a-2a38-c9a83fdc94e3@gmail.com>
References: <1504140569-2063-1-git-send-email-f.fainelli@gmail.com>
 <f4bb5ac8-dae8-c0af-7aa6-e546fc0783fa@sigmadesigns.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        David Miller <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>,
        Mason <slash.tmp@free.fr>
To: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:33466 "EHLO
        mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751667AbdHaQgW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 12:36:22 -0400
Received: by mail-yw0-f195.google.com with SMTP id w138so115189yww.0
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 09:36:22 -0700 (PDT)
In-Reply-To: <f4bb5ac8-dae8-c0af-7aa6-e546fc0783fa@sigmadesigns.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/31/2017 05:29 AM, Marc Gonzalez wrote:
> On 31/08/2017 02:49, Florian Fainelli wrote:
> 
>> This reverts commit 7ad813f208533cebfcc32d3d7474dc1677d1b09a ("net: phy:
>> Correctly process PHY_HALTED in phy_stop_machine()") because it is
>> creating the possibility for a NULL pointer dereference.
>>
>> David Daney provide the following call trace and diagram of events:
>>
>> When ndo_stop() is called we call:
>>
>>   phy_disconnect()
>>      +---> phy_stop_interrupts() implies: phydev->irq = PHY_POLL;
> 
> What does this mean?

I meant that after the call to phy_stop_interrupts(), phydev->irq = 
PHY_POLL;


> 
> On the contrary, phy_stop_interrupts() is only called when *not* polling.

That is the case I have.  We are using interrupts from the phy.


> 
> 	if (phydev->irq > 0)
> 		phy_stop_interrupts(phydev);
> 
>>      +---> phy_stop_machine()
>>      |      +---> phy_state_machine()
>>      |              +----> queue_delayed_work(): Work queued.
> 
> You're referring to the fact that, at the end of phy_state_machine()
> (in polling mode) the code reschedules itself through:
> 
> 	if (phydev->irq == PHY_POLL)
> 		queue_delayed_work(system_power_efficient_wq, &phydev->state_queue, PHY_STATE_TIME * HZ);

Exactly.  The call to phy_disconnect() ensures that there are no more 
interrupts and also that phydev->irq = PHY_POLL

The call to cancel_delayed_work_sync() at the top of phy_stop_machine() 
was meant to ensure that phy_state_machine() was never run again.  No 
interrupts + no queued work means that it should be save to do...

> 
>>      +--->phy_detach() implies: phydev->attached_dev = NULL;

The problem is that by calling phy_state_machine() again (which the 
offending patch added) we now have work scheduled that will try to 
dereference the pointer that was set to NULL as a result of the phy_detach()


>>
>> Now at a later time the queued work does:
>>
>>   phy_state_machine()
>>      +---->netif_carrier_off(phydev->attached_dev): Oh no! It is NULL:
> 
> I tested a sequence of 500 link up / link down in polling mode,
> and saw no such issue. Race condition?
> 

You were lucky.

> For what case in phy_state_machine() is netif_carrier_off()
> being called? Surely not PHY_HALTED?
> 

The phy can be in a variety of states.  It is connected to something 
outside of the system that we don't control, so you cannot assume any 
particular state.  We must have code that doesn't crash the system no 
matter what state the phy is in.

I suspect, but have not checked, that the phy is in PHY_RUNNING.  I 
think that means that because this patch turned the state machine back 
on, it will start transitioning through PHY_UP, PHY_AN, ... and 
eventually get to the crash we see because phydev->attached_dev = NULL


> 
>> The original motivation for this change originated from Marc Gonzales
>> indicating that his network driver did not have its adjust_link callback
>> executing with phydev->link = 0 while he was expecting it.
> 
> I expect the core to call phy_adjust_link() for link changes.
> This used to work back in 3.4 and was broken somewhere along
> the way.
> 
>> PHYLIB has never made any such guarantees ever because phy_stop() merely
>> just tells the workqueue to move into PHY_HALTED state which will happen
>> asynchronously.
> 
> My original proposal was to fix the issue in the driver.
> I'll try locating it in my archives.
> 
> Regards.
> 
