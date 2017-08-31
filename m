From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] Revert "net: phy: Correctly process PHY_HALTED in
 phy_stop_machine()"
Date: Thu, 31 Aug 2017 10:03:21 -0700
Message-ID: <a75691d9-c22a-9b89-2cce-604315062739@gmail.com>
References: <1504140569-2063-1-git-send-email-f.fainelli@gmail.com>
 <f4bb5ac8-dae8-c0af-7aa6-e546fc0783fa@sigmadesigns.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        David Miller <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>,
        Mason <slash.tmp@free.fr>
To: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        David Daney <ddaney.cavm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:34038 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750815AbdHaRD2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 13:03:28 -0400
Received: by mail-qk0-f194.google.com with SMTP id a77so179203qkb.1
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 10:03:27 -0700 (PDT)
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
>>  phy_disconnect()
>>     +---> phy_stop_interrupts() implies: phydev->irq = PHY_POLL;
> 
> What does this mean?
> 
> On the contrary, phy_stop_interrupts() is only called when *not* polling.
> 
> 	if (phydev->irq > 0)
> 		phy_stop_interrupts(phydev);
> 
>>     +---> phy_stop_machine()
>>     |      +---> phy_state_machine()
>>     |              +----> queue_delayed_work(): Work queued.
> 
> You're referring to the fact that, at the end of phy_state_machine()
> (in polling mode) the code reschedules itself through:
> 
> 	if (phydev->irq == PHY_POLL)
> 		queue_delayed_work(system_power_efficient_wq, &phydev->state_queue, PHY_STATE_TIME * HZ);
> 
>>     +--->phy_detach() implies: phydev->attached_dev = NULL;
>>
>> Now at a later time the queued work does:
>>
>>  phy_state_machine()
>>     +---->netif_carrier_off(phydev->attached_dev): Oh no! It is NULL:
> 
> I tested a sequence of 500 link up / link down in polling mode,
> and saw no such issue. Race condition?
> 
> For what case in phy_state_machine() is netif_carrier_off()
> being called? Surely not PHY_HALTED?
> 
> 
>> The original motivation for this change originated from Marc Gonzales
>> indicating that his network driver did not have its adjust_link callback
>> executing with phydev->link = 0 while he was expecting it.
> 
> I expect the core to call phy_adjust_link() for link changes.
> This used to work back in 3.4 and was broken somewhere along
> the way.

If that was working correctly in 3.4 surely we can look at the diff and
figure out what changed, even maybe find the offending commit, can you
do that?

> 
>> PHYLIB has never made any such guarantees ever because phy_stop() merely
>> just tells the workqueue to move into PHY_HALTED state which will happen
>> asynchronously.
> 
> My original proposal was to fix the issue in the driver.
> I'll try locating it in my archives.

Yes I remember you telling that, by the way I don't think you ever
provided a clear explanation why this is absolutely necessary for your
driver though?
-- 
Florian
