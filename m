From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH] net: phy: Don't miss phy_suspend() on PHY_HALTED for
 PHYs with interrupts
Date: Mon, 20 Mar 2017 09:42:43 -0700
Message-ID: <73c622c8-5dd3-43a2-df60-b0195241bf0d@gmail.com>
References: <1489585887-8683-1-git-send-email-rogerq@ti.com>
 <20170315140811.GD21021@lunn.ch>
 <6ec42ad7-0be3-f6c5-2ded-27bf3adbab23@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kyle.roeschley@ni.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Roger Quadros <rogerq@ti.com>, Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6ec42ad7-0be3-f6c5-2ded-27bf3adbab23@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/15/2017 08:00 AM, Roger Quadros wrote:
> Andrew,
> 
> On 15/03/17 16:08, Andrew Lunn wrote:
>> On Wed, Mar 15, 2017 at 03:51:27PM +0200, Roger Quadros wrote:
>>> Since commit 3c293f4e08b5 ("net: phy: Trigger state machine on state change and not polling.")
>>> phy_suspend() doesn't get called as part of phy_stop() for PHYs using
>>> interrupts because the phy state machine is never triggered after a phy_stop().
>>>
>>> Explicitly trigger the PHY state machine so that it can
>>> see the new PHY state (HALTED) and suspend the PHY.
>>>
>>> Signed-off-by: Roger Quadros <rogerq@ti.com>
>>
>> Hi Roger
>>
>> This seems sensible. It mirrors what phy_start() does.
>>
>> Reviewed-by: Andrew Lunn <andrew@lunn.ch>
> 
> The reason for this being an RFC was the following comment just before
> where I add the phy_trigger_machine()
> 
>         /* Cannot call flush_scheduled_work() here as desired because
>          * of rtnl_lock(), but PHY_HALTED shall guarantee phy_change()
>          * will not reenable interrupts.
>          */
> 
> Is this comment still applicable? If yes, is it OK to call
> phy_trigger_machine() there?

I think the comment is still applicable, most PHYLIB consumers will call
this with rtnl_lock() held from ndo_close() for instance.

> 
>>
>> It does however lead to a follow up question. Are there other places
>> phydev->state is changed and it is missing a phy_trigger_machine()?
>>
> 
> One other place I think we should add phy_trigger_machine() is phy_start_aneg().
> 
> Since commit 3c293f4e08b5 I was not getting my ethernet link to come up if
> ethernet cable was plugged before the ethernet interface was brought up.
> The PHY seems to be stuck from RUNNING to AN state with no new interrupts from the
> PHY.
> 
> I could workaround it on my board by doing either of the following:
> 
> 1) explicitly halt the PHY at ethernet driver probe time. Then when
> network interface is brought up it resumes the PHY and we see the
> Link/ANEG done interrupt.
> 
> 2) force BMCR_ANRESTART every time from .config_aneg in the PHY driver.
> 
> I will still keep approach 1 as it is desirable to put the PHY in low power mode
> for us but I need a second opinion if we should call phy_trigger_machine()
> from phy_start_aneg() or not.
> 


-- 
Florian
