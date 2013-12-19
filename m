From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: Re: [PATCH v2 1/9] fixed-phy: register fixed PHY as platform driver
Date: Thu, 19 Dec 2013 12:23:10 +0100
Message-ID: <52B2D71E.5070101@hauke-m.de>
References: <1387416526-7394-1-git-send-email-hauke@hauke-m.de> <1387416526-7394-2-git-send-email-hauke@hauke-m.de> <CAGVrzcYfhu1fatpPH8njc_Wh5PVpSG92aGwgsSqkaoNxEFPXxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, zambrano@broadcom.com,
	netdev <netdev@vger.kernel.org>,
	Vitaly Bordug <vbordug@ru.mvista.com>,
	Anton Vorontsov <avorontsov@ru.mvista.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:49708 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751455Ab3LSLX3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 06:23:29 -0500
In-Reply-To: <CAGVrzcYfhu1fatpPH8njc_Wh5PVpSG92aGwgsSqkaoNxEFPXxw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/19/2013 02:48 AM, Florian Fainelli wrote:
> 2013/12/18 Hauke Mehrtens <hauke@hauke-m.de>:
>> This changes the fixed phy driver from registering the mdio bus when
>> the module gets loaded to registering it when a device was registered.
>> A phy has to get registered to this driver before it registered the
>> mdio bus, but this only worked when the phys are registered in some
>> arch code before the system booted completely. Now we want to do so
>> when the Ethernet driver gets initialized which could be happen every
>> time.
>>
>> To make this driver work with such a case, convert it to a platform
>> driver which could be registered every time with the phys which should
>> be on the bus.
>>
>> This was only tested on BCM47XX, but not on AR7 because I do not have
>> such a device.
> 
> I do understand why you would want to do it that way, but I believe
> this is should be addressed separately, outside of the actual b44
> changes. Converting the fixed PHY driver into a platform driver also
> has an impact on how Device Tree callers such as PowerPC would be
> dealing with this.

For the ADM switch we could initialize the fixed phy in the arch code,
because with that switch fixed phys are always needed, but this is also
needed for some Broadcom switches and I can not automatically detect if
that is the case. The detection could be done  based on the board the
kernel was booted on, but there are some hundreds different ones for
BCM47XX.

Sorry I missed some calls to fixed_phy_ads() in the arch code where it
is used by the device tree platforms, but that could be easily converted
to a platform device as well.

> Can you submit the required changes to arch/mips/bcm47xx/ for now and
> get this change merged via David's tree? This would buy us some time
> to discuss how to best deal with fixed PHY, and also take Device Tree
> aware platform into account since that part has been an on-going
> discussion for a while.

What changes to arch/mips/bcm47xx/ are you talking about?
Do you mean I should send the b44 patches without the fixed phy stuff
first and then we can discuss the fixed phy stuff separately, that would
be my next strategy? ;-)

> 
> Thanks!
> 
>>
>> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
>> CC: Florian Fainelli <florian@openwrt.org>
>> CC: Vitaly Bordug <vbordug@ru.mvista.com>
>> CC: Anton Vorontsov <avorontsov@ru.mvista.com>
>> ---
>>  arch/mips/ar7/platform.c  |   39 ++++++++++++++++++----
>>  drivers/net/phy/fixed.c   |   79 ++++++++++++++++++++++-----------------------
>>  include/linux/phy_fixed.h |   21 ++++++------
>>  3 files changed, 83 insertions(+), 56 deletions(-)
>>
>> diff --git a/arch/mips/ar7/platform.c b/arch/mips/ar7/platform.c
>> index 7e2356f..26ea35a 100644
>> --- a/arch/mips/ar7/platform.c
>> +++ b/arch/mips/ar7/platform.c
>> @@ -251,10 +251,35 @@ static struct resource cpmac_high_res[] = {
>>         },
>>  };
>>
>> -static struct fixed_phy_status fixed_phy_status __initdata = {
>> -       .link           = 1,
>> -       .speed          = 100,
>> -       .duplex         = 1,
>> +static struct pdata_fixed_phy cpmac_phy_data = {
>> +       .name           = "fixed-0",
>> +       .phys_num       = 1,
>> +       .phys           = {{
>> +               .phy_id = 1,
>> +               .irq    = PHY_POLL,
>> +               .status = {
>> +                       .link   = 1,
>> +                       .speed  = 100,
>> +                       .duplex = 1,
>> +               },
>> +       },
>> +       {
>> +               .phy_id = 1,
>> +               .irq    = PHY_POLL,
>> +               .status = {
>> +                       .link   = 1,
>> +                       .speed  = 100,
>> +                       .duplex = 1,
>> +               },
>> +       }},
>> +};
>> +
>> +static struct platform_device cpmac_phy = {
>> +       .id             = 0,
>> +       .name           = "fixed-phy",
>> +       .dev = {
>> +               .platform_data  = &cpmac_phy_data,
>> +       },
>>  };
>>
>>  static struct plat_cpmac_data cpmac_low_data = {
>> @@ -683,7 +708,8 @@ static int __init ar7_register_devices(void)
>>         }
>>
>>         if (ar7_has_high_cpmac()) {
>> -               res = fixed_phy_add(PHY_POLL, cpmac_high.id, &fixed_phy_status);
>> +               cpmac_phy_data.phys[1].phy_id = cpmac_high.id;
>> +               cpmac_phy_data.phys_num = 2;
>>                 if (!res) {
>>                         cpmac_get_mac(1, cpmac_high_data.dev_addr);
>>
>> @@ -695,7 +721,8 @@ static int __init ar7_register_devices(void)
>>         } else
>>                 cpmac_low_data.phy_mask = 0xffffffff;
>>
>> -       res = fixed_phy_add(PHY_POLL, cpmac_low.id, &fixed_phy_status);
>> +       cpmac_phy_data.phys[0].phy_id = cpmac_low.id;
>> +       res = platform_device_register(&cpmac_phy);
>>         if (!res) {
>>                 cpmac_get_mac(0, cpmac_low_data.dev_addr);
>>                 res = platform_device_register(&cpmac_low);
>> diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
>> index ba55adf..dd5154b 100644
>> --- a/drivers/net/phy/fixed.c
>> +++ b/drivers/net/phy/fixed.c
>> @@ -5,6 +5,7 @@
>>   *         Anton Vorontsov <avorontsov@ru.mvista.com>
>>   *
>>   * Copyright (c) 2006-2007 MontaVista Software, Inc.
>> + * Copyright (C) 2013 Hauke Mehrtens <hauke@hauke-m.de>
>>   *
>>   * This program is free software; you can redistribute  it and/or modify it
>>   * under  the terms of  the GNU General  Public License as published by the
>> @@ -39,11 +40,6 @@ struct fixed_phy {
>>         struct list_head node;
>>  };
>>
>> -static struct platform_device *pdev;
>> -static struct fixed_mdio_bus platform_fmb = {
>> -       .phys = LIST_HEAD_INIT(platform_fmb.phys),
>> -};
>> -
>>  static int fixed_phy_update_regs(struct fixed_phy *fp)
>>  {
>>         u16 bmsr = BMSR_ANEGCAPABLE;
>> @@ -153,7 +149,7 @@ int fixed_phy_set_link_update(struct phy_device *phydev,
>>                               int (*link_update)(struct net_device *,
>>                                                  struct fixed_phy_status *))
>>  {
>> -       struct fixed_mdio_bus *fmb = &platform_fmb;
>> +       struct fixed_mdio_bus *fmb = phydev->bus->priv;
>>         struct fixed_phy *fp;
>>
>>         if (!link_update || !phydev || !phydev->bus)
>> @@ -171,14 +167,14 @@ int fixed_phy_set_link_update(struct phy_device *phydev,
>>  }
>>  EXPORT_SYMBOL_GPL(fixed_phy_set_link_update);
>>
>> -int fixed_phy_add(unsigned int irq, int phy_id,
>> -                 struct fixed_phy_status *status)
>> +static int fixed_phy_add(struct device *dev, struct fixed_mdio_bus *fmb,
>> +                        unsigned int irq, int phy_id,
>> +                        struct fixed_phy_status *status)
>>  {
>>         int ret;
>> -       struct fixed_mdio_bus *fmb = &platform_fmb;
>>         struct fixed_phy *fp;
>>
>> -       fp = kzalloc(sizeof(*fp), GFP_KERNEL);
>> +       fp = devm_kzalloc(dev, sizeof(struct fixed_phy), GFP_KERNEL);
>>         if (!fp)
>>                 return -ENOMEM;
>>
>> @@ -191,36 +187,41 @@ int fixed_phy_add(unsigned int irq, int phy_id,
>>
>>         ret = fixed_phy_update_regs(fp);
>>         if (ret)
>> -               goto err_regs;
>> +               return ret;
>>
>>         list_add_tail(&fp->node, &fmb->phys);
>>
>>         return 0;
>> -
>> -err_regs:
>> -       kfree(fp);
>> -       return ret;
>>  }
>> -EXPORT_SYMBOL_GPL(fixed_phy_add);
>>
>> -static int __init fixed_mdio_bus_init(void)
>> +static int fixed_phy_probe(struct platform_device *pdev)
>>  {
>> -       struct fixed_mdio_bus *fmb = &platform_fmb;
>> +       struct pdata_fixed_phy *pdata = dev_get_platdata(&pdev->dev);
>> +       struct fixed_mdio_bus *fmb;
>> +       struct fixed_phy_conf *phy;
>>         int ret;
>> +       int i;
>>
>> -       pdev = platform_device_register_simple("Fixed MDIO bus", 0, NULL, 0);
>> -       if (IS_ERR(pdev)) {
>> -               ret = PTR_ERR(pdev);
>> -               goto err_pdev;
>> +       fmb = devm_kzalloc(&pdev->dev, sizeof(struct fixed_mdio_bus), GFP_KERNEL);
>> +       if (!fmb)
>> +               return -ENOMEM;
>> +       INIT_LIST_HEAD(&fmb->phys);
>> +       platform_set_drvdata(pdev, fmb);
>> +
>> +       for (i = 0; i < pdata->phys_num; i++) {
>> +               phy = &pdata->phys[i];
>> +               ret = fixed_phy_add(&pdev->dev, fmb, phy->irq, phy->phy_id,
>> +                                   &phy->status);
>> +               if (ret < 0)
>> +                       return ret;
>>         }
>>
>>         fmb->mii_bus = mdiobus_alloc();
>> -       if (fmb->mii_bus == NULL) {
>> -               ret = -ENOMEM;
>> -               goto err_mdiobus_reg;
>> +       if (!fmb->mii_bus) {
>> +               return -ENOMEM;
>>         }
>>
>> -       snprintf(fmb->mii_bus->id, MII_BUS_ID_SIZE, "fixed-0");
>> +       snprintf(fmb->mii_bus->id, MII_BUS_ID_SIZE, pdata->name);
>>         fmb->mii_bus->name = "Fixed MDIO Bus";
>>         fmb->mii_bus->priv = fmb;
>>         fmb->mii_bus->parent = &pdev->dev;
>> @@ -236,29 +237,27 @@ static int __init fixed_mdio_bus_init(void)
>>
>>  err_mdiobus_alloc:
>>         mdiobus_free(fmb->mii_bus);
>> -err_mdiobus_reg:
>> -       platform_device_unregister(pdev);
>> -err_pdev:
>>         return ret;
>>  }
>> -module_init(fixed_mdio_bus_init);
>>
>> -static void __exit fixed_mdio_bus_exit(void)
>> +static int fixed_phy_remove(struct platform_device *pdev)
>>  {
>> -       struct fixed_mdio_bus *fmb = &platform_fmb;
>> -       struct fixed_phy *fp, *tmp;
>> +       struct fixed_mdio_bus *fmb = platform_get_drvdata(pdev);
>>
>>         mdiobus_unregister(fmb->mii_bus);
>>         mdiobus_free(fmb->mii_bus);
>> -       platform_device_unregister(pdev);
>> -
>> -       list_for_each_entry_safe(fp, tmp, &fmb->phys, node) {
>> -               list_del(&fp->node);
>> -               kfree(fp);
>> -       }
>> +       return 0;
>>  }
>> -module_exit(fixed_mdio_bus_exit);
>>
>> +static struct platform_driver fixed_phy_driver = {
>> +       .probe = fixed_phy_probe,
>> +       .remove = fixed_phy_remove,
>> +       .driver = {
>> +               .name = "fixed-phy",
>> +       },
>> +};
>> +
>> +module_platform_driver(fixed_phy_driver);
>>  MODULE_DESCRIPTION("Fixed MDIO bus (MDIO bus emulation with fixed PHYs)");
>>  MODULE_AUTHOR("Vitaly Bordug");
>>  MODULE_LICENSE("GPL");
>> diff --git a/include/linux/phy_fixed.h b/include/linux/phy_fixed.h
>> index 509d8f5..f41140e 100644
>> --- a/include/linux/phy_fixed.h
>> +++ b/include/linux/phy_fixed.h
>> @@ -9,16 +9,17 @@ struct fixed_phy_status {
>>         int asym_pause;
>>  };
>>
>> -#ifdef CONFIG_FIXED_PHY
>> -extern int fixed_phy_add(unsigned int irq, int phy_id,
>> -                        struct fixed_phy_status *status);
>> -#else
>> -static inline int fixed_phy_add(unsigned int irq, int phy_id,
>> -                               struct fixed_phy_status *status)
>> -{
>> -       return -ENODEV;
>> -}
>> -#endif /* CONFIG_FIXED_PHY */
>> +struct fixed_phy_conf {
>> +       int phy_id;
>> +       unsigned int irq;
>> +       struct fixed_phy_status status;
>> +};
>> +
>> +struct pdata_fixed_phy {
>> +       char *name;
>> +       unsigned int phys_num;
>> +       struct fixed_phy_conf phys[];
>> +};
>>
>>  /*
>>   * This function issued only by fixed_phy-aware drivers, no need
>> --
>> 1.7.10.4
> 
> 
> 
