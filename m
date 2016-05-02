From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] net: macb: do not scan PHYs manually
Date: Mon, 2 May 2016 12:08:50 -0700
Message-ID: <5727A5C2.804@gmail.com>
References: <20160428163207.GP29024@lunn.ch>
 <20160428175619.GA8791@nathan3500-linux-VM> <20160428184303.GR29024@lunn.ch>
 <20160428185527.GA8851@nathan3500-linux-VM> <20160428185932.GU29024@lunn.ch>
 <20160428210357.GB30217@jcartwri.amer.corp.natinst.com>
 <20160428212315.GC12753@lunn.ch>
 <20160429003459.GC30217@jcartwri.amer.corp.natinst.com>
 <20160429122501.GD30217@jcartwri.amer.corp.natinst.com>
 <57235655.3030104@atmel.com>
 <20160502183626.GC31001@jcartwri.amer.corp.natinst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>,
	Nathan Sullivan <nathan.sullivan@ni.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>
To: Josh Cartwright <joshc@ni.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160502183626.GC31001@jcartwri.amer.corp.natinst.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/05/16 11:36, Josh Cartwright wrote:
> On Fri, Apr 29, 2016 at 02:40:53PM +0200, Nicolas Ferre wrote:
> [..]
>>>  static int macb_mii_init(struct macb *bp)
>>>  {
>>>  	struct macb_platform_data *pdata;
>>>  	struct device_node *np;
>>> -	int err = -ENXIO, i;
>>> +	int err = -ENXIO;
>>>  
>>>  	/* Enable management port */
>>>  	macb_writel(bp, NCR, MACB_BIT(MPE));
>>> @@ -446,33 +497,10 @@ static int macb_mii_init(struct macb *bp)
>>>  	dev_set_drvdata(&bp->dev->dev, bp->mii_bus);
>>>  
>>>  	np = bp->pdev->dev.of_node;
>>> -	if (np) {
>>> -		/* try dt phy registration */
>>> -		err = of_mdiobus_register(bp->mii_bus, np);
>>> -
>>> -		/* fallback to standard phy registration if no phy were
>>> -		 * found during dt phy registration
>>> -		 */
>>> -		if (!err && !phy_find_first(bp->mii_bus)) {
>>> -			for (i = 0; i < PHY_MAX_ADDR; i++) {
>>> -				struct phy_device *phydev;
>>> -
>>> -				phydev = mdiobus_scan(bp->mii_bus, i);
>>> -				if (IS_ERR(phydev)) {
>>> -					err = PTR_ERR(phydev);
>>> -					break;
>>> -				}
>>> -			}
>>> -
>>> -			if (err)
>>> -				goto err_out_unregister_bus;
>>> -		}
>>> -	} else {
>>> -		if (pdata)
>>> -			bp->mii_bus->phy_mask = pdata->phy_mask;
>>> -
>>> -		err = mdiobus_register(bp->mii_bus);
>>> -	}
>>> +	if (np)
>>> +		err = macb_mii_of_init(bp, np);
>>> +	else
>>> +		err = macb_mii_pdata_init(bp, pdata);
>>>  
>>>  	if (err)
>>>  		goto err_out_free_mdiobus;
>>
>> I'm okay with this. Thanks for having taken the initiative to implement it.
> 
> Unfortunately, I don't think it's going to be as straightforward
> as I originally thought.  Still doable, but more complicated.
> 
> In particular, the macb bindings allow for a user to specify a
> 'reset-gpios' property _at the PHY_ level, which is consumed by the
> macb to adjust the PHY reset state on remove.

In fact, not just on remove, anytime there is an opportunity to save
power (interface down, closed) and putting the PHY into reset is usually
guaranteed to be saving more power than e.g: a BMCR power down.

> 
> My question is: why is the PHY reset GPIO management not the
> responsibility of the PHY driver/core itself?

Well, this is actually being worked on at the moment by Sergei, since
there is not necessarily a reason why PHYLIB can't deal with that:

https://lkml.org/lkml/2016/4/28/831
-- 
Florian
