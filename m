From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: fix auto-negotiation stall due to unavailable
 interrupt
Date: Wed, 19 Apr 2017 09:32:51 -0700
Message-ID: <754f7cfe-6914-570a-d0e5-4a26b6787281@gmail.com>
References: <1492609604-16359-1-git-send-email-al.kochet@gmail.com>
 <24E19B31-CCD8-4032-B17B-D226D4DB881D@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: Alexander Kochetkov <al.kochet@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, andrew@lunn.ch,
        Roger Quadros <rogerq@ti.com>, nsekhar@ti.com,
        kyle.roeschley@ni.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:32839 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938133AbdDSQc4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Apr 2017 12:32:56 -0400
In-Reply-To: <24E19B31-CCD8-4032-B17B-D226D4DB881D@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/19/2017 07:05 AM, Alexander Kochetkov wrote:
> Just found similar problem fixed in another PHY. See commit 99f81afc139c
> ("phy: micrel: Disable auto negotiation on startup»)

This specific commit was really a "this works for me, but I have not
investigated what needs fixing in PHYLIB".

Roger has been submitting a couple of patches to fix the same issue and
yours seems to be better in that it also addresses his concerns that
after his fix there was still a 1s delay (the HZ parameter to the
queue_delayed_work call) being seen:

http://patchwork.ozlabs.org/patch/743773/

Roger can you also test Alexander's patch?

> 
>> 19 апр. 2017 г., в 16:46, Alexander Kochetkov <al.kochet@gmail.com> написал(а):
>>
>> The problem I fix related to SMSC LAN8710/LAN8720 PHY handled using
>> interrupts. During power-up cycle the PHY do auto-negotiation, generate
>> interrupt and set BMSR_ANEGCOMPLETE flag. Interrupt is handled by PHY
>> state machine but doesn't update link because PHY is in PHY_READY state.
>> After some time MAC bring up and connect with PHY. It start PHY using
>> phy_start(). During startup PHY change state to PHY_AN but doesn't
>> set BMCR_ANRESTART flag due to genphy_config_aneg() doesn't update MII_BMCR
>> because there no new to advertising. As a result, state machine wait for
>> interrupt from PHY and nether get "link is up". Because BMSR_ANEGCOMPLETE
>> already set the patch schedule check link without waiting interrupt.
>> In case genphy_config_aneg() update MII_BMCR and set BMCR_ANRESTART
>> flag, BMSR_ANEGCOMPLETE will be cleared and state machine will continue
>> on auto-negotiation interrupt.
>>
>> Signed-off-by: Alexander Kochetkov <al.kochet@gmail.com>
>> ---
>> drivers/net/phy/phy.c |   12 ++++++++++++
>> 1 file changed, 12 insertions(+)
>>
>> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
>> index 7cc1b7d..da8f03d 100644
>> --- a/drivers/net/phy/phy.c
>> +++ b/drivers/net/phy/phy.c
>> @@ -1169,6 +1169,18 @@ void phy_state_machine(struct work_struct *work)
>> 	if (phydev->irq == PHY_POLL)
>> 		queue_delayed_work(system_power_efficient_wq, &phydev->state_queue,
>> 				   PHY_STATE_TIME * HZ);
>> +
>> +	/* Re-schedule a PHY state machine to check PHY status because
>> +	 * negotiation already done and aneg interrupt may not be generated.
>> +	 */
>> +	if (needs_aneg && (phydev->irq > 0) && (phydev->state == PHY_AN)) {
>> +		err = phy_aneg_done(phydev);
>> +		if (err > 0)
>> +			queue_delayed_work(system_power_efficient_wq,
>> +					   &phydev->state_queue, 0);
>> +		if (err < 0)
>> +			phy_error(phydev);
>> +	}
>> }
>>
>> /**
>> -- 
>> 1.7.9.5
>>
> 


-- 
Florian
