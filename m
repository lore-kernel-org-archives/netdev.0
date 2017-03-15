From: Roger Quadros <rogerq@ti.com>
Subject: Re: [RFC PATCH] net: phy: Don't miss phy_suspend() on PHY_HALTED for
 PHYs with interrupts
Date: Wed, 15 Mar 2017 17:00:08 +0200
Message-ID: <6ec42ad7-0be3-f6c5-2ded-27bf3adbab23@ti.com>
References: <1489585887-8683-1-git-send-email-rogerq@ti.com>
 <20170315140811.GD21021@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <f.fainelli@gmail.com>, <davem@davemloft.net>,
        <kyle.roeschley@ni.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx210.ext.ti.com ([198.47.19.17]:18736 "EHLO
        fllnx210.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752040AbdCOPAY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 11:00:24 -0400
In-Reply-To: <20170315140811.GD21021@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew,

On 15/03/17 16:08, Andrew Lunn wrote:
> On Wed, Mar 15, 2017 at 03:51:27PM +0200, Roger Quadros wrote:
>> Since commit 3c293f4e08b5 ("net: phy: Trigger state machine on state change and not polling.")
>> phy_suspend() doesn't get called as part of phy_stop() for PHYs using
>> interrupts because the phy state machine is never triggered after a phy_stop().
>>
>> Explicitly trigger the PHY state machine so that it can
>> see the new PHY state (HALTED) and suspend the PHY.
>>
>> Signed-off-by: Roger Quadros <rogerq@ti.com>
> 
> Hi Roger
> 
> This seems sensible. It mirrors what phy_start() does.
> 
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>

The reason for this being an RFC was the following comment just before
where I add the phy_trigger_machine()

        /* Cannot call flush_scheduled_work() here as desired because
         * of rtnl_lock(), but PHY_HALTED shall guarantee phy_change()
         * will not reenable interrupts.
         */

Is this comment still applicable? If yes, is it OK to call
phy_trigger_machine() there?

> 
> It does however lead to a follow up question. Are there other places
> phydev->state is changed and it is missing a phy_trigger_machine()?
> 

One other place I think we should add phy_trigger_machine() is phy_start_aneg().

Since commit 3c293f4e08b5 I was not getting my ethernet link to come up if
ethernet cable was plugged before the ethernet interface was brought up.
The PHY seems to be stuck from RUNNING to AN state with no new interrupts from the
PHY.

I could workaround it on my board by doing either of the following:

1) explicitly halt the PHY at ethernet driver probe time. Then when
network interface is brought up it resumes the PHY and we see the
Link/ANEG done interrupt.

2) force BMCR_ANRESTART every time from .config_aneg in the PHY driver.

I will still keep approach 1 as it is desirable to put the PHY in low power mode
for us but I need a second opinion if we should call phy_trigger_machine()
from phy_start_aneg() or not.

-- 
cheers,
-roger
