From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net v2 1/3] net: phy: Fix PHY module checks
Date: Wed, 8 Feb 2017 09:55:49 -0800
Message-ID: <a068e619-5288-7007-b172-cb5d4417b758@gmail.com>
References: <20170208073746.10963-1-f.fainelli@gmail.com>
 <20170208073746.10963-2-f.fainelli@gmail.com>
 <20170208165713.GD13281@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        rmk+kernel@armlinux.org.uk, maowenan@huawei.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35101 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751809AbdBHRzz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 12:55:55 -0500
Received: by mail-wr0-f194.google.com with SMTP id o16so9447831wra.2
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 09:55:54 -0800 (PST)
In-Reply-To: <20170208165713.GD13281@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/08/2017 08:57 AM, Andrew Lunn wrote:
>> --- a/drivers/net/phy/phy_device.c
>> +++ b/drivers/net/phy/phy_device.c
>> @@ -920,7 +920,7 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
>>  		return -EIO;
>>  	}
>>  
>> -	if (!try_module_get(d->driver->owner)) {
>> +	if (d->driver && !try_module_get(d->driver->owner)) {
>>  		dev_err(&dev->dev, "failed to get the device driver module\n");
>>  		return -EIO;
>>  	}
>> @@ -943,7 +943,7 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
>>  			err = device_bind_driver(d);
>>  
>>  		if (err)
>> -			goto error;
>> +			goto error_put_device;
>>  	}
>>  
>>  	if (phydev->attached_dev) {
>> @@ -981,6 +981,7 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
>>  
>>  error:
>>  	phy_detach(phydev);
>> +error_put_device:
>>  	put_device(d);
>>  	module_put(d->driver->owner);
> 
> Can we get into problems here? Maybe we did not do a get?

Humm yes, that seems possible too.

> 
> 
>>  	if (ndev_owner != bus->owner)
>> @@ -1065,7 +1066,8 @@ void phy_detach(struct phy_device *phydev)
>>  	bus = phydev->mdio.bus;
>>  
>>  	put_device(&phydev->mdio.dev);
>> -	module_put(phydev->mdio.dev.driver->owner);
>> +	if (phydev->mdio.dev.driver)
>> +		module_put(phydev->mdio.dev.driver->owner);
> 
> Humm. By this point, havn't we assigned d->driver to genphy_driver?
> So this decrements something we never incremented?

Not really, the generic PHY drivers are built into libphy, so all PHY
drivers de facto going to depend on libphy.ko being loaded first, that's
why we can take shortcuts and not increment the refcount on the
genphy/libphy module here.

> 
> To me, it seems better to move the try_module_get() after assigning
> genphy_driver if needed. We then don't have any special conditions.

Sounds fair, let me fix that (and the problem reported by Mao about
error handling).

Thanks!
-- 
Florian
