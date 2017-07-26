From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] net: phy: Run state machine to completion
Date: Wed, 26 Jul 2017 12:53:28 -0700
Message-ID: <9be259d0-fddf-c185-2d77-5eede69a54bb@gmail.com>
References: <20170726192446.32045-1-f.fainelli@gmail.com>
 <8413cb0c-a304-7698-5cbe-94a420b74cb7@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: rmk+kernel@armlinux.org.uk, slash.tmp@free.fr, zach.brown@ni.com,
        nathan.sullivan@ni.com, Andrew Lunn <andrew@lunn.ch>,
        open list <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8413cb0c-a304-7698-5cbe-94a420b74cb7@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/26/2017 12:34 PM, Florian Fainelli wrote:
> On 07/26/2017 12:24 PM, Florian Fainelli wrote:
>> Marc reported that he was not getting the PHY library adjust_link()
>> callback function to run when calling phy_stop() + phy_disconnect()
>> which does not indeed happen because we don't make sure we flush the
>> PHYLIB delayed work and let it run to completion. We also need to have
>> a synchronous call to phy_state_machine() in order to have the state
>> machine actually act on PHY_HALTED, set the PHY device's link down, turn
>> the network device's carrier off and finally call the adjust_link()
>> function.
>>
>> Reported-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
>> Fixes: a390d1f379cf ("phylib: convert state_queue work to delayed_work")
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>> David, this dates back from before the commit mentioned in Fixes but it would
>> be hard to backport to earlier kernels if we flagged the original design flaw
>> that used timers. Also, I am not clear on the timer API whether there was a way
>> to ensure timers would run to completion before they would be cancelled.
>>
>> Marc, please add your Signed-off-by tag since you contributed the second line.
>>
>> Thanks!
> 
> David, please hold off before applying this, I found a corner case with
> power management where we may be accessing clock gated registers and
> cause bus errors, will report back here.

This was a downstream only problem because I was missing these two commits:

49d52e8108a21749dc2114b924c907db43358984 ("net: phy: handle state
correctly in phy_stop_machine")
d5c3d84657db57bd23ecd58b97f1c99dd42a7b80 ("net: phy: Avoid polling PHY
with PHY_IGNORE_INTERRUPTS")

This was tested with bcmgenet (PHY_IGNORE_INTERRUPT and PHY_POLL) and
with bcm_sf2 (net/dsa/slave.c), would appreciate some review/testing
from others as well.

> 
>>
>>  drivers/net/phy/phy.c | 5 +++++
>>  1 file changed, 5 insertions(+)
>>
>> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
>> index d0626bf5c540..30e7c43e0d87 100644
>> --- a/drivers/net/phy/phy.c
>> +++ b/drivers/net/phy/phy.c
>> @@ -743,12 +743,17 @@ void phy_trigger_machine(struct phy_device *phydev, bool sync)
>>   */
>>  void phy_stop_machine(struct phy_device *phydev)
>>  {
>> +	/* Run the state machine to completion */
>> +	flush_delayed_work(&phydev->state_queue);
>>  	cancel_delayed_work_sync(&phydev->state_queue);
>>  
>>  	mutex_lock(&phydev->lock);
>>  	if (phydev->state > PHY_UP && phydev->state != PHY_HALTED)
>>  		phydev->state = PHY_UP;
>>  	mutex_unlock(&phydev->lock);
>> +
>> +	/* Now we can run the state machine synchronously */
>> +	phy_state_machine(&phydev->state_queue.work);
>>  }
>>  
>>  /**
>>
> 
> 


-- 
Florian
