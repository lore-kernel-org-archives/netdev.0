From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/5] phylib: don't return NULL from get_phy_device()
Date: Wed, 27 Apr 2016 23:09:37 +0300
Message-ID: <57211C81.4000903@cogentembedded.com>
References: <56219623.1S7UfcqQqc@wasted.cogentembedded.com>
 <16806435.OmqP10ba8M@wasted.cogentembedded.com>
 <874mamzw5q.fsf@ketchup.mtl.sfl> <20160427194932.GF29024@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, f.fainelli@gmail.com,
	arnd@arndb.de, netdev@vger.kernel.org, kernel@savoirfairelinux.com
To: Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:35241 "EHLO
	mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752249AbcD0UJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 16:09:41 -0400
Received: by mail-lf0-f54.google.com with SMTP id c126so70442605lfb.2
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 13:09:40 -0700 (PDT)
In-Reply-To: <20160427194932.GF29024@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 04/27/2016 10:49 PM, Andrew Lunn wrote:

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
>>>   drivers/net/phy/phy_device.c |    2 +-
>>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> Index: net-next/drivers/net/phy/phy_device.c
>>> ===================================================================
>>> --- net-next.orig/drivers/net/phy/phy_device.c
>>> +++ net-next/drivers/net/phy/phy_device.c
>>> @@ -529,7 +529,7 @@ struct phy_device *get_phy_device(struct
>>>
>>>   	/* If the phy_id is mostly Fs, there is no device there */
>>>   	if ((phy_id & 0x1fffffff) == 0x1fffffff)
>>> -		return NULL;
>>> +		return ERR_PTR(-ENODEV);
>>>
>>>   	return phy_device_create(bus, addr, phy_id, is_c45, &c45_ids);
>>>   }
>
> This change is wrong, it needs reverting, or the call sights need
> fixing to expect ENODEV.

    So this function had a good reason to return NULL, as it turned out... :-(

> The point is, the device not being there is not an error, with respect
> to the code calling this function.
>
> It gets called by mdiobus_scan()
>
> struct phy_device *mdiobus_scan(struct mii_bus *bus, int addr)
> {
>          struct phy_device *phydev;
>          int err;
>
>          phydev = get_phy_device(bus, addr, false);
>          if (IS_ERR(phydev) || phydev == NULL)
>                  return phydev;
>
> So before, we return NULL, if the device was not there. Now we return
> ERR_PTR(-ENODEV).
>
> This is being called by:
>
> int __mdiobus_register(struct mii_bus *bus, struct module *owner)
> {
>          struct mdio_device *mdiodev;
> ...
>          for (i = 0; i < PHY_MAX_ADDR; i++) {
>                  if ((bus->phy_mask & (1 << i)) == 0) {
>                          struct phy_device *phydev;
>
>                          phydev = mdiobus_scan(bus, i);
>                          if (IS_ERR(phydev)) {
>                                  err = PTR_ERR(phydev);
>                                  goto error;
>                          }
>                  }
>          }
>
> This is treating ERR_PTR(-ENODEV) as a fatal error, where as before
> IS_ERR(NULL) would be false and it would continue scanning other
> addresses on the bus.

    Thank you for the detailed analysis! (And shame on me for the lack of it.)

> Please revert this, or fix all the callsites such that ENODEV is not a
> fatal error.

    OK, I'll do what DaveM decides.

> 	     Andrew

MBR, Sergei
