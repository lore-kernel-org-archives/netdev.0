From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH -next 1/2] net: tc35815: Fix build error due to missed API
 change
Date: Sat, 9 Jan 2016 13:50:02 -0800
Message-ID: <5691808A.1010301@roeck-us.net>
References: <1452374494-18752-1-git-send-email-linux@roeck-us.net>
 <20160109213614.GC6877@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160109213614.GC6877@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/09/2016 01:36 PM, Andrew Lunn wrote:
> On Sat, Jan 09, 2016 at 01:21:33PM -0800, Guenter Roeck wrote:
>> Commit 7f854420fbfe ("phy: Add API for {un}registering an mdio device to
>> a bus") introduces an API to access mii_bus structures, but missed to
>> update the tc35815 driver. This results in the following error message.
>>
>> drivers/net/ethernet/toshiba/tc35815.c: In function 'tc_mii_probe':
>> drivers/net/ethernet/toshiba/tc35815.c:617:18: error:
>> 	'struct mii_bus' has no member named 'phy_map'
>> drivers/net/ethernet/toshiba/tc35815.c:623:24: error:
>> 	'struct mii_bus' has no member named 'phy_map'
>>
>> Fixes: 7f854420fbfe ("phy: Add API for {un}registering an mdio device to a bus")
>> Cc: Andrew Lunn <andrew@lunn.ch>
>> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
>> ---
>>   drivers/net/ethernet/toshiba/tc35815.c | 7 +++++--
>>   1 file changed, 5 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
>> index fed5e3dfbc8f..5b5e7dcf9a99 100644
>> --- a/drivers/net/ethernet/toshiba/tc35815.c
>> +++ b/drivers/net/ethernet/toshiba/tc35815.c
>> @@ -614,13 +614,16 @@ static int tc_mii_probe(struct net_device *dev)
>>
>>   	/* find the first phy */
>>   	for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
>> -		if (lp->mii_bus->phy_map[phy_addr]) {
>> +		struct phy_device *tmp_phy;
>> +
>> +		tmp_phy = mdiobus_get_phy(lp->mii_bus, phy_addr);
>> +		if (tmp_phy) {
>>   			if (phydev) {
>>   				printk(KERN_ERR "%s: multiple PHYs found\n",
>>   				       dev->name);
>>   				return -EINVAL;
>>   			}
>> -			phydev = lp->mii_bus->phy_map[phy_addr];
>> +			phydev = tmp_phy;
>>   			break;
>>   		}
>>   	}
>
> Hi Guenter
>
> You fix looks right, but i'm wondering about the code which is being
> fixed.
>
> How can phydev ever evaluate to true, given the break statement?  Can
> this code every detect multiple PHYs? I think not.
>
> Either the break needs to be removed, or we just replace the whole lot
> with phy_find_first().
>

Hi Andrew,

you are right, the current code is pretty pointless.

I would suggest to use phy_find_first(). Even though that changes the intent
of the code, it doesn't change its current semantics. Plus, apparently
the intent wasn't important enough to actually test it. Add to it the
resulting simplification, and I think we have a clear winner.

Should I submit a separate patch, or replace my patch with v2 ?
And which way to go ?

Thoughts ?

Guenter
