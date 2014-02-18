From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] of_mdio: fix phy interrupt passing
Date: Tue, 18 Feb 2014 21:06:02 +0300
Message-ID: <5303A10A.3060106@cogentembedded.com>
References: <1392654580-3706-1-git-send-email-ben.dooks@codethink.co.uk> < 20140218093024.D0E94C403C8@trevor.secretlab.ca> <53032A97.8050201@codethink .co.uk> <20140218170202.424D7C40517@trevor.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@lists.codethink.co.uk, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
To: Grant Likely <grant.likely@linaro.org>,
	Ben Dooks <ben.dooks@codethink.co.uk>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20140218170202.424D7C40517@trevor.secretlab.ca>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 02/18/2014 08:02 PM, Grant Likely wrote:

>>> On Mon, 17 Feb 2014 16:29:40 +0000, Ben Dooks <ben.dooks@codethink.co.uk> wrote:
>>>> The of_mdiobus_register_phy() is not setting phy->irq this causing
>>>> some drivers to incorrectly assume that the PHY does not have an
>>>> IRQ associated with it or install an interrupt handler for the
>>>> PHY.

>>>> Simplify the code setting irq and set the phy->irq at the same
>>>> time so that the case if mdio->irq is not NULL is easier to read.

>>>> This fixes the issue:
>>>>    net eth0: attached PHY 1 (IRQ -1) to driver Micrel KSZ8041RNLI

>>>> to the correct:
>>>>    net eth0: attached PHY 1 (IRQ 416) to driver Micrel KSZ8041RNLI

>>>> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
>>>> ---
>>>>    drivers/of/of_mdio.c | 12 ++++++------
>>>>    1 file changed, 6 insertions(+), 6 deletions(-)

>>>> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
>>>> index 875b7b6..7b3e7b0 100644
>>>> --- a/drivers/of/of_mdio.c
>>>> +++ b/drivers/of/of_mdio.c
>>>> @@ -44,7 +44,7 @@ static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *chi
>>>>    {
>>>>    	struct phy_device *phy;
>>>>    	bool is_c45;
>>>> -	int rc, prev_irq;
>>>> +	int rc;
>>>>    	u32 max_speed = 0;
>>>>
>>>>    	is_c45 = of_device_is_compatible(child,
>>>> @@ -55,11 +55,11 @@ static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *chi
>>>>    		return 1;
>>>>
>>>>    	if (mdio->irq) {
>>>> -		prev_irq = mdio->irq[addr];
>>>> -		mdio->irq[addr] =
>>>> -			irq_of_parse_and_map(child, 0);
>>>> -		if (!mdio->irq[addr])
>>>> -			mdio->irq[addr] = prev_irq;

>>> I cannot for the life for me remeber why the code was structured that
>>> way. Your change is better.

>>>> +		rc = irq_of_parse_and_map(child, 0);
>>>> +		if (rc > 0) {
>>>> +			mdio->irq[addr] = rc;
>>>> +			phy->irq = rc;
>>>> +		}
>>>>    	}

>>> The outer if is merely protecting against no irq array being allocated
>>> for the bus. Would not the following be better:

>>> 	rc = irq_of_parse_and_map(child, 0);
>>> 	if (rc > 0) {
>>> 		phy->irq = rc;
>>> 		if (mdio->irq)
>>> 			mdio->irq[addr] = rc;
>>> 	}

>> Thanks, that makes sense, although we've both failed to work
>> out if mdio->irq is set, and rc <= 0 case, so:

>>    	rc = irq_of_parse_and_map(child, 0);
>>    	if (rc > 0) {
>>    		phy->irq = rc;
>>    		if (mdio->irq)
>>    			mdio->irq[addr] = rc;
>>    	} else {
>> 		if (mdio->irq)
>> 			phy->irq = mdio->irq[addr];
>> 	}

> Is this actually a valid thing to do? I think the only time mdio->irq[]
> is non-zero is when it is set to PHY_POLL. Is it valid to set phy->irq
> to PHY_POLL? I didn't think it was.

    It is valid, AFAIK.

> g.

>> --
>> Ben Dooks				http://www.codethink.co.uk/
>> Senior Engineer				Codethink - Providing Genius

WBR, Sergei

