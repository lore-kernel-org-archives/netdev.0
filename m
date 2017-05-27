From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/3] net: phy: Create sysfs reciprocal links for
 attached_dev/phydev
Date: Fri, 26 May 2017 20:22:16 -0700
Message-ID: <6ccadb96-bdbb-a789-234c-374bf18d5162@gmail.com>
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
 <dc4a3f50-3ff3-e690-9893-0575ddea42f6@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D40A9DB6A@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, andrew@lunn.ch
To: Woojung.Huh@microchip.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:34170 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751391AbdE0DWT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 23:22:19 -0400
Received: by mail-oi0-f68.google.com with SMTP id w10so4361377oif.1
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 20:22:19 -0700 (PDT)
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40A9DB6A@CHN-SV-EXMX02.mchp-main.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 05/26/2017 06:31 PM, Woojung.Huh@microchip.com wrote:
>>
>> Yes, that's a very valid point, how about we even do this:
>>
>> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
>> index f84414b8f2ee..dc666ec13651 100644
>> --- a/drivers/net/phy/phy_device.c
>> +++ b/drivers/net/phy/phy_device.c
>> @@ -960,15 +960,21 @@ int phy_attach_direct(struct net_device *dev,
>> struct phy_device *phydev,
>>
>>         phydev->attached_dev = dev;
>>         dev->phydev = phydev;
>> +
>> +       /* Some Ethernet drivers try to connect to a PHY device before
>> +        * calling register_netdevice() -> netdev_register_kobject() and
>> +        * does the dev->dev.kobj initialization. Here we only check for
>> +        * success which indicates that the network device kobject is
>> +        * ready.
>> +        */
>>         err = sysfs_create_link(&phydev->mdio.dev.kobj, &dev->dev.kobj,
>>                                 "attached_dev");
>> -       if (err)
>> -               goto error;
>> -
>> -       err = sysfs_create_link(&dev->dev.kobj, &phydev->mdio.dev.kobj,
>> -                               "phydev");
>> -       if (err)
>> -               goto error;
>> +       if (!err) {
>> +               err = sysfs_create_link(&dev->dev.kobj,
>> &phydev->mdio.dev.kobj,
>> +                                       "phydev");
>> +               if (err)
>> +                       goto error;
>> +       }
>>
>>         phydev->dev_flags = flags;
>>
> Looks better and clean.
> 
> How about sysfs_remove_link() in phy_detach()?

Good catch, I was able to reproduce the situation in which macb calls
phy_connect_direct(), will submit a patch shortly. Thanks!
-- 
Florian
