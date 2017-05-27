From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/3] net: phy: Create sysfs reciprocal links for
 attached_dev/phydev
Date: Fri, 26 May 2017 18:26:02 -0700
Message-ID: <dc4a3f50-3ff3-e690-9893-0575ddea42f6@gmail.com>
References: <20170524193354.10739-1-f.fainelli@gmail.com>
 <20170524193354.10739-2-f.fainelli@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D40A9DAA2@CHN-SV-EXMX02.mchp-main.com>
 <d2d97683-3fcc-6603-09e1-13818464de18@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D40A9DACE@CHN-SV-EXMX02.mchp-main.com>
 <44f24fbd-5093-faa2-02cd-f8d4d835b59d@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D40A9DAF6@CHN-SV-EXMX02.mchp-main.com>
 <05a159af-6689-70db-9506-09059a09f1a5@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D40A9DB14@CHN-SV-EXMX02.mchp-main.com>
 <0413eb98-61cc-2fca-a4d6-7f4ef91843ba@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D40A9DB32@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, andrew@lunn.ch
To: Woojung.Huh@microchip.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:34259 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932457AbdE0B0F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 21:26:05 -0400
Received: by mail-oi0-f66.google.com with SMTP id w10so4144518oif.1
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 18:26:05 -0700 (PDT)
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40A9DB32@CHN-SV-EXMX02.mchp-main.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 05/26/2017 06:00 PM, Woojung.Huh@microchip.com wrote:
> Hi Florian,
>>>> OK, so here is what is happening: macb_mii_init() calls macb_mii_probe()
>>>> and so by the time we call phy_connect_direct(), we have not called
>>>> register_netdevice() yet, netdev_register_kobject() has not been called
>>>> either, and so sysfs_create_link() fails....
>>> I just found same thing.
>>> Yes, register_netdev() was not called at phy_connect_direct() time.
>>>
>>>> Let me think about a way to solve that, even though I am leaning towards
>>>> ignoring the errors from sysfs_create_link() rather than fixing each and
>>>> every Ethernet driver to make it probe its MII bus *after* calling
>>>> register_netdevice()....
>>> Agree.
>>
>> Thanks, would the following work for you? I don't want to do something
>> more complex than that, although, if we really wanted to see this
>> information, we could imagine having netdev_register_kobject() check
>> whether phydev->dev.kobj is valid, and set the symbolic link at that
>> point... The problem with that approach is that we are no longer
>> symetrical within the core PHYLIB code (phy_attach_direct and phy_detach).
>>
>> Let me know if this works so I can make a formal submission:
>>
>> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
>> index f84414b8f2ee..daad816ee1d1 100644
>> --- a/drivers/net/phy/phy_device.c
>> +++ b/drivers/net/phy/phy_device.c
>> @@ -960,14 +960,20 @@ int phy_attach_direct(struct net_device *dev,
>> struct phy_device *phydev,
>>
>>         phydev->attached_dev = dev;
>>         dev->phydev = phydev;
>> +
>> +       /* Some Ethernet drivers try to connect to a PHY device before
>> +        * calling register_netdevice(). register_netdevice() does
>> ultimately
>> +        * lead to netdev_register_kobject() which would do the
>> dev->dev.kobj
>> +        * initialization. Here we explicitly ignore those particular errors
>> +        */
>>         err = sysfs_create_link(&phydev->mdio.dev.kobj, &dev->dev.kobj,
>>                                 "attached_dev");
>> -       if (err)
>> +       if (err && err != -ENOENT)
>>                 goto error;
> This one fine. However, next one returns -14 (-EFAULT)
> 
>>         err = sysfs_create_link(&dev->dev.kobj, &phydev->mdio.dev.kobj,
>>                                 "phydev");
>> -       if (err)
>> +       if (err && err != -ENOENT)
>>                 goto error;
> No need to call 2nd sysfs_create_link(), how about following?
> 
> 	err = sysfs_create_link(&phydev->mdio.dev.kobj, &dev->dev.kobj,
>  				"attached_dev");
> -	if (err)
> +	if (err && err != -ENOENT)
>  		goto error;
>  
> -	err = sysfs_create_link(&dev->dev.kobj, &phydev->mdio.dev.kobj,
> -				"phydev");
> -	if (err)
> -		goto error;
> +	if (!err) {
> +		err = sysfs_create_link(&dev->dev.kobj, &phydev->mdio.dev.kobj,
> +					"phydev");
> +		if (err)
> +			goto error;
> +	}

Yes, that's a very valid point, how about we even do this:

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index f84414b8f2ee..dc666ec13651 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -960,15 +960,21 @@ int phy_attach_direct(struct net_device *dev,
struct phy_device *phydev,

        phydev->attached_dev = dev;
        dev->phydev = phydev;
+
+       /* Some Ethernet drivers try to connect to a PHY device before
+        * calling register_netdevice() -> netdev_register_kobject() and
+        * does the dev->dev.kobj initialization. Here we only check for
+        * success which indicates that the network device kobject is
+        * ready.
+        */
        err = sysfs_create_link(&phydev->mdio.dev.kobj, &dev->dev.kobj,
                                "attached_dev");
-       if (err)
-               goto error;
-
-       err = sysfs_create_link(&dev->dev.kobj, &phydev->mdio.dev.kobj,
-                               "phydev");
-       if (err)
-               goto error;
+       if (!err) {
+               err = sysfs_create_link(&dev->dev.kobj,
&phydev->mdio.dev.kobj,
+                                       "phydev");
+               if (err)
+                       goto error;
+       }

        phydev->dev_flags = flags;

-- 
Florian
