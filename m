From: Roger Quadros <rogerq@ti.com>
Subject: Re: [PATCH v3 1/2] net: phy: Fix PHY AN done state machine for
 interrupt driven PHYs
Date: Tue, 11 Apr 2017 14:17:12 +0300
Message-ID: <203afff4-7dd7-e185-000a-1689a97dfb67@ti.com>
References: <1490180524-28675-1-git-send-email-rogerq@ti.com>
 <1490180524-28675-2-git-send-email-rogerq@ti.com>
 <078917ad-77a1-a722-1688-6203ae183a46@ti.com>
 <bfaac2be-175b-c370-43ce-7a11b2933e1c@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <kyle.roeschley@ni.com>, <nsekhar@ti.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        "stable # v4 . 9+" <stable@vger.kernel.org>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "Andrew F. Davis" <afd@ti.com>
To: <f.fainelli@gmail.com>, <andrew@lunn.ch>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <bfaac2be-175b-c370-43ce-7a11b2933e1c@ti.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 28/03/17 13:05, Roger Quadros wrote:
> +Andrew Davis & Sekhar.
> 
> Hi,
> 
> Andrew Davis posted a few comments offline which I'm clarifying here.
> 
> On 27/03/17 14:59, Roger Quadros wrote:
>> The Ethernet link on an interrupt driven PHY was not coming up if the
>> Ethernet cable was plugged before the Ethernet interface was brought up.
>>
>> The PHY state machine seems to be stuck from RUNNING to AN state
>> with no new interrupts from the PHY. So it doesn't know when the
>> PHY Auto-negotiation has been completed and doesn't transition to RUNNING
>> state with ANEG done thus netif_carrier_on() is never called.
>>
>> NOTE: genphy_config_aneg() will not restart PHY Auto-negotiation of
>> advertisement parameters didn't change.
> 
> Is phy->config_aneg expected to *always* restart auto-negotiation even if
> advertisement parameters didn't change?
> If so then we'll need to fix genphy_config_aneg().
> 
>>
>> Fix this by scheduling the PHY state machine in phy_start_aneg().
>> There is no way of knowing in phy.c whether auto-negotiation was
>> restarted or not by the PHY driver so we just wait for the next
>> poll/interrupt to update the PHY state machine.
>>
>> Fixes: 3c293f4e08b5 ("net: phy: Trigger state machine on state change and not polling.")
>> Cc: stable <stable@vger.kernel.org> # v4.9+
>> Signed-off-by: Roger Quadros <rogerq@ti.com>
>> ---
>> v3: Fix typo in commit message
>>
>>  drivers/net/phy/phy.c | 4 ++++
>>  1 file changed, 4 insertions(+)
>>
>> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
>> index 1be69d8..49dedf8 100644
>> --- a/drivers/net/phy/phy.c
>> +++ b/drivers/net/phy/phy.c
>> @@ -630,6 +630,10 @@ int phy_start_aneg(struct phy_device *phydev)
>>  
>>  out_unlock:
>>  	mutex_unlock(&phydev->lock);
>> +	if (!err && phy_interrupt_is_valid(phydev))
>> +		queue_delayed_work(system_power_efficient_wq,
>> +				   &phydev->state_queue, HZ);
>> +
>>  	return err;
>>  }
>>  EXPORT_SYMBOL(phy_start_aneg);
>>
> 
> There is still room for optimization for interrupt driven PHYs as I still
> see a delay of 1 second between "ifconfig ethx up" and link status coming up
> if cable was already plugged in. In fact if Auto-negotiation was already completed
> and not required to be restarted, the PHY state machine should have move from
> AN to RUNNING instantly without expecting a PHY interrupt.
> 
> How can we get rid of the unnecessary delay in the case where auto-negotiation
> is not restarted?
> Should we check for phy_aneg_done() immediately after issuing a phy_start_aneg()
> in phy_state_machine() and switch from PHY_AN to PHY_RUNNING?
> 
> This should avoid the need to re-schedule the state machine in phy_start_angeg().

Any comments on my questions?

cheers,
-roger
