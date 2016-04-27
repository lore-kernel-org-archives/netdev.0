From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/5] phylib: don't return NULL from get_phy_device()
Date: Wed, 27 Apr 2016 14:47:29 -0700
Message-ID: <57213371.1020905@gmail.com>
References: <56219623.1S7UfcqQqc@wasted.cogentembedded.com>
 <16806435.OmqP10ba8M@wasted.cogentembedded.com>
 <874mamzw5q.fsf@ketchup.mtl.sfl> <20160427194932.GF29024@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	arnd@arndb.de, netdev@vger.kernel.org, kernel@savoirfairelinux.com
To: Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35285 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752626AbcD0Vtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 17:49:47 -0400
Received: by mail-pf0-f170.google.com with SMTP id n1so28154601pfn.2
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 14:49:47 -0700 (PDT)
In-Reply-To: <20160427194932.GF29024@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/04/16 12:49, Andrew Lunn wrote:
> On Wed, Apr 27, 2016 at 03:30:57PM -0400, Vivien Didelot wrote:
>> Hi David, All,
>>
>> Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> writes:
>>
>>> Arnd Bergmann asked that get_phy_device() returns either NULL or the error
>>> value,  not both on error.  Do as he said, return ERR_PTR(-ENODEV) instead
>>> of NULL when the PHY ID registers read as  all ones.
>>>
>>> Suggested-by: Arnd Bergmann <arnd@arndb.de>
>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>>>
>>> ---
>>>  drivers/net/phy/phy_device.c |    2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> Index: net-next/drivers/net/phy/phy_device.c
>>> ===================================================================
>>> --- net-next.orig/drivers/net/phy/phy_device.c
>>> +++ net-next/drivers/net/phy/phy_device.c
>>> @@ -529,7 +529,7 @@ struct phy_device *get_phy_device(struct
>>>  
>>>  	/* If the phy_id is mostly Fs, there is no device there */
>>>  	if ((phy_id & 0x1fffffff) == 0x1fffffff)
>>> -		return NULL;
>>> +		return ERR_PTR(-ENODEV);
>>>  
>>>  	return phy_device_create(bus, addr, phy_id, is_c45, &c45_ids);
>>>  }
> 
> This change is wrong, it needs reverting, or the call sights need
> fixing to expect ENODEV.
> 
> The point is, the device not being there is not an error, with respect
> to the code calling this function.
> 
> It gets called by mdiobus_scan()
> 
> struct phy_device *mdiobus_scan(struct mii_bus *bus, int addr)
> {
>         struct phy_device *phydev;
>         int err;
> 
>         phydev = get_phy_device(bus, addr, false);
>         if (IS_ERR(phydev) || phydev == NULL)
>                 return phydev;
> 
> So before, we return NULL, if the device was not there. Now we return
> ERR_PTR(-ENODEV).
> 
> This is being called by:
> 
> int __mdiobus_register(struct mii_bus *bus, struct module *owner)
> {
>         struct mdio_device *mdiodev;
> ...
>         for (i = 0; i < PHY_MAX_ADDR; i++) {
>                 if ((bus->phy_mask & (1 << i)) == 0) {
>                         struct phy_device *phydev;
> 
>                         phydev = mdiobus_scan(bus, i);
>                         if (IS_ERR(phydev)) {
>                                 err = PTR_ERR(phydev);
>                                 goto error;
>                         }
>                 }
>         }
> 
> This is treating ERR_PTR(-ENODEV) as a fatal error, where as before
> IS_ERR(NULL) would be false and it would continue scanning other
> addresses on the bus.
> 
> Please revert this, or fix all the callsites such that ENODEV is not a
> fatal error.

So the one you pointed out in __mdiobus_register() is definitively
needed, though I did get a different issue than Vivien's (-EBUSY vs.
-EINVAL). The get_phy_device() in drivers/of/of_mdio.c probably needs
something similar too, here is what I locally have for the moment:

diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 499003ee8055..94a27b028dd8 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -333,7 +333,7 @@ int __mdiobus_register(struct mii_bus *bus, struct
module *owner)
                        struct phy_device *phydev;

                        phydev = mdiobus_scan(bus, i);
-                       if (IS_ERR(phydev)) {
+                       if (IS_ERR(phydev) && PTR_ERR(phydev) != -ENODEV) {
                                err = PTR_ERR(phydev);
                                goto error;
                        }

-- 
Florian
