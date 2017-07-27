From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH net-next v2 04/10] net: dsa: lan9303: Added adjust_link()
 method
Date: Thu, 27 Jul 2017 12:45:59 +0200
Message-ID: <e5de6f96-b37f-ad63-7541-a2f894b6127d@egil-hjelmeland.no>
References: <20170725161553.30147-1-privat@egil-hjelmeland.no>
 <20170725161553.30147-5-privat@egil-hjelmeland.no>
 <20170726170928.GP12049@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: corbet@lwn.net, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, davem@davemloft.net, kernel@pengutronix.de,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20170726170928.GP12049@lunn.ch>
Content-Language: en-US
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26. juli 2017 19:09, Andrew Lunn wrote:
> On Tue, Jul 25, 2017 at 06:15:47PM +0200, Egil Hjelmeland wrote:
>> This makes the driver react to device tree "fixed-link" declaration
>> on CPU port.
>>
>> - turn off autonegotiation
>> - force speed 10 or 100 mb/s
>> - force duplex mode
>>
>> Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
>> ---
>>   drivers/net/dsa/lan9303-core.c | 33 +++++++++++++++++++++++++++++++++
>>   1 file changed, 33 insertions(+)
>>
>> diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
>> index 0806a0684d55..be6d78f45a5f 100644
>> --- a/drivers/net/dsa/lan9303-core.c
>> +++ b/drivers/net/dsa/lan9303-core.c
>> @@ -17,6 +17,7 @@
>>   #include <linux/regmap.h>
>>   #include <linux/mutex.h>
>>   #include <linux/mii.h>
>> +#include <linux/phy.h>
>>   
>>   #include "lan9303.h"
>>   
>> @@ -746,6 +747,37 @@ static int lan9303_phy_write(struct dsa_switch *ds, int phy, int regnum,
>>   	return chip->ops->phy_write(chip, phy, regnum, val);
>>   }
>>   
>> +static void lan9303_adjust_link(struct dsa_switch *ds, int port,
>> +				struct phy_device *phydev)
>> +{
>> +	struct lan9303 *chip = ds->priv;
>> +
>> +	int ctl, res;
>> +
>> +	ctl = lan9303_phy_read(ds, port, MII_BMCR);
>> +
>> +	if (!phy_is_pseudo_fixed_link(phydev))
>> +		return;
>> +
> 
> Hi Egil
> 
> Maybe do this check before reading MII_BMCR?
> 

OK

>> +	ctl &= ~BMCR_ANENABLE;
> 
> Should this also mask out BMCR_SPEED100 and DUPLEX_FULL? Otherwise how
> do you select 10/Half if it is already configured for 100/Full?
> 

Yes you are right. I started out with setting ctl to the fixed default
value, and later changed code to start by reading it from HW.


>> +	if (phydev->speed == SPEED_100)
>> +		ctl |= BMCR_SPEED100;
>> +
>> +	if (phydev->duplex == DUPLEX_FULL)
>> +		ctl |= BMCR_FULLDPLX;
>> +
>> +	res =  lan9303_phy_write(ds, port, MII_BMCR, ctl);
>> +
>> +	if (port == chip->phy_addr_sel_strap) {
>> +		/* Virtual Phy: Remove Turbo 200Mbit mode */
>> +		lan9303_read(chip->regmap, LAN9303_VIRT_SPECIAL_CTRL, &ctl);
>> +
>> +		ctl &= ~(1 << 10); // TURBO BIT
> 
> BIT(10), or better still something like BIT(LAN9303_VIRT_SPECIAL_TURBO)
> 

Agree

>> +		res =  regmap_write(chip->regmap,
>> +				    LAN9303_VIRT_SPECIAL_CTRL, ctl);
>> +	}
>> +}
> 
>    Andrew
> 

