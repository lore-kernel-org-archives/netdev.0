From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: Re: [PATCH v4] net: sh_eth: Add support of device tree probe
Date: Wed, 27 Feb 2013 08:34:36 +0900
Message-ID: <512D468C.4080309@renesas.com>
References: <1360893205-12004-1-git-send-email-iwamatsu@nigauri.org>
 <CAOJe8K0BdhLUjkjpjdJH-tjBHbXJHdV-mWAkMFJ96zahhAfwOg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nobuhiro Iwamatsu <iwamatsu@nigauri.org>, netdev@vger.kernel.org,
	horms+renesas@verge.net.au, magnus.damm@gmail.com,
	devicetree-discuss@lists.ozlabs.org,
	kuninori.morimoto.gx@renesas.com
To: Denis Kirjanov <kda@linux-powerpc.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor4.renesas.com ([210.160.252.174]:57648 "EHLO
	relmlor4.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752226Ab3BZXey (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 18:34:54 -0500
Received: from relmlir1.idc.renesas.com ([10.200.68.151])
 by relmlor4.idc.renesas.com ( SJSMS)
 with ESMTP id <0MIU002SXPI4Z720@relmlor4.idc.renesas.com> for
 netdev@vger.kernel.org; Wed, 27 Feb 2013 08:34:52 +0900 (JST)
Received: from relmlac1.idc.renesas.com ([10.200.69.21])
 by relmlir1.idc.renesas.com (SJSMS)
 with ESMTP id <0MIU007AKPI4L310@relmlir1.idc.renesas.com> for
 netdev@vger.kernel.org; Wed, 27 Feb 2013 08:34:52 +0900 (JST)
In-reply-to: <CAOJe8K0BdhLUjkjpjdJH-tjBHbXJHdV-mWAkMFJ96zahhAfwOg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2013/02/16 0:02), Denis Kirjanov wrote:
> On 2/15/13, Nobuhiro Iwamatsu<iwamatsu@nigauri.org>  wrote:
>> From: Nobuhiro Iwamatsu<nobuhiro.iwamatsu.yj@renesas.com>
>>
>> This adds support of device tree probe for Renesas sh-ether driver.
>>
>> Signed-off-by: Nobuhiro Iwamatsu<nobuhiro.iwamatsu.yj@renesas.com>
>>
>> V4: - Remove empty sh_eth_parse_dt().
>> V3: - Removed sentnece of "needs-init" from document.
>> V2: - Removed ether_setup().
>>      - Fixed typo from "sh-etn" to "sh-eth".
>> 	- Removed "needs-init" and sh-eth,endian from definition of DT.
>> 	- Changed "sh-eth,edmac-endian" instead of "sh-eth,edmac-big-endain"
>> 	  in definition of DT.
>> ---
>>   Documentation/devicetree/bindings/net/sh_ether.txt |   39 +++++
>>   drivers/net/ethernet/renesas/sh_eth.c              |  150
>> ++++++++++++++++----
>>   2 files changed, 165 insertions(+), 24 deletions(-)
>>   create mode 100644 Documentation/devicetree/bindings/net/sh_ether.txt
>>
<snip>

>> diff --git a/drivers/net/ethernet/renesas/sh_eth.c
>> b/drivers/net/ethernet/renesas/sh_eth.c
>> index 3d70586..b41249a 100644
>> --- a/drivers/net/ethernet/renesas/sh_eth.c
>> +++ b/drivers/net/ethernet/renesas/sh_eth.c
>> @@ -1,7 +1,7 @@
>>   /*
>>    *  SuperH Ethernet device driver
>>    *
>> - *  Copyright (C) 2006-2012 Nobuhiro Iwamatsu
>> + *  Copyright (C) 2006-2013 Nobuhiro Iwamatsu
>>    *  Copyright (C) 2008-2012 Renesas Solutions Corp.
>>    *
>>    *  This program is free software; you can redistribute it and/or modify
>> it
>> @@ -31,6 +31,12 @@
>>   #include<linux/platform_device.h>
>>   #include<linux/mdio-bitbang.h>
>>   #include<linux/netdevice.h>
>> +#include<linux/of.h>
>> +#include<linux/of_device.h>
>> +#include<linux/of_platform.h>
>> +#include<linux/of_address.h>
>> +#include<linux/of_irq.h>
>> +#include<linux/of_net.h>
>>   #include<linux/phy.h>
>>   #include<linux/cache.h>
>>   #include<linux/io.h>
>> @@ -2347,26 +2353,103 @@ static const struct net_device_ops
>> sh_eth_netdev_ops = {
>>   	.ndo_change_mtu		= eth_change_mtu,
>>   };
>>
>> +#ifdef CONFIG_OF
>> +
>> +static int
>> +sh_eth_of_get_register_type(struct device_node *np)
>> +{
>> +	const char *of_str;
>> +	int ret = of_property_read_string(np, "sh-eth,register-type",&of_str);
>> +	if (ret)
>> +		return ret;
>> +
>> +	if (of_str&&  !strcmp(of_str, "gigabit"))
>> +		return SH_ETH_REG_GIGABIT;
>> +
>> +	else if (of_str&&  !strcmp(of_str, "fast-sh4"))
>> +		return SH_ETH_REG_FAST_SH4;
>> +	else if (of_str&&  !strcmp(of_str, "fast-sh3-sh2"))
>> +		return SH_ETH_REG_FAST_SH3_SH2;
>> +	else
>> +		return -EINVAL;
>> +}
>> +
>> +static struct sh_eth_plat_data *
>> +sh_eth_parse_dt(struct device *dev, struct net_device *ndev)
>> +{
>> +	int ret;
>> +	struct device_node *np = dev->of_node;
>> +	struct sh_eth_plat_data *pdata;
>> +
>> +	pdata = devm_kzalloc(dev, sizeof(struct sh_eth_plat_data),
>> +					GFP_KERNEL);
>> +	if (!pdata) {
>> +		dev_err(dev, "%s: failed to allocate config data\n", __func__);
>> +		return NULL;
>> +	}
>> +
>> +	pdata->phy_interface = of_get_phy_mode(np);
>> +
>> +	of_property_read_u32(np, "sh-eth,phy-id",&pdata->phy);
>> +
>> +	if (of_find_property(np, "sh-eth,edmac-big-endian", NULL))
>> +		pdata->edmac_endian = EDMAC_BIG_ENDIAN;
>> +	else
>> +		pdata->edmac_endian = EDMAC_LITTLE_ENDIAN;
>> +
>> +	if (of_find_property(np, "sh-eth,no-ether-link", NULL))
>> +		pdata->no_ether_link = 1;
>> +	else
>> +		pdata->no_ether_link = 0;
>> +
>> +	if (of_find_property(np, "sh-eth,ether-link-active-low", NULL))
>> +		pdata->ether_link_active_low = 1;
>> +	else
>> +		pdata->ether_link_active_low = 0;
>> +
>> +	ret = sh_eth_of_get_register_type(np);
>> +	if (ret<  0)
>> +		goto error;
>> +	pdata->register_type = ret;
>> +
>> +#ifdef CONFIG_OF_NET
>> +	if (!is_valid_ether_addr(ndev->dev_addr)) {
>> +		const char *macaddr = of_get_mac_address(np);
>> +		if (macaddr)
>> +			memcpy(pdata->mac_addr, macaddr, ETH_ALEN);
>> +	}
>> +#endif
>> +
>> +	return pdata;
>> +
>> +error:
>> +	devm_kfree(dev, pdata);
>> +	return NULL;
>> +}
>> +#endif
>> +
>>   static int sh_eth_drv_probe(struct platform_device *pdev)
>>   {
>> -	int ret, devno = 0;
>> +	int ret = 0, devno = 0;
>>   	struct resource *res;
>>   	struct net_device *ndev = NULL;
>>   	struct sh_eth_private *mdp = NULL;
>>   	struct sh_eth_plat_data *pd;
>> +	struct device_node *np = pdev->dev.of_node;
>> +
>> +	ndev = alloc_etherdev(sizeof(struct sh_eth_private));
>> +	if (!ndev) {
>> +		ret = -ENOMEM;
>> +		goto out;
>> +	}
>>
>> +	mdp = netdev_priv(ndev);
>>   	/* get base addr */
>>   	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>>   	if (unlikely(res == NULL)) {
>>   		dev_err(&pdev->dev, "invalid resource\n");
>>   		ret = -EINVAL;
>> -		goto out;
>> -	}
>> -
>> -	ndev = alloc_etherdev(sizeof(struct sh_eth_private));
>> -	if (!ndev) {
>> -		ret = -ENOMEM;
>> -		goto out;
>> +		goto out_release;
>>   	}
>>
>>   	/* The sh Ether-specific entries in the device structure. */
>> @@ -2383,27 +2466,41 @@ static int sh_eth_drv_probe(struct platform_device
>> *pdev)
>>   	}
>>   	ndev->irq = ret;
>>
>> -	SET_NETDEV_DEV(ndev,&pdev->dev);
>> -
>> -	/* Fill in the fields of the device structure with ethernet values. */
>> -	ether_setup(ndev);
>> -
>> -	mdp = netdev_priv(ndev);
>> -	mdp->num_tx_ring = TX_RING_SIZE;
>> -	mdp->num_rx_ring = RX_RING_SIZE;
>>   	mdp->addr = ioremap(res->start, resource_size(res));
>>   	if (mdp->addr == NULL) {
>>   		ret = -ENOMEM;
>>   		dev_err(&pdev->dev, "ioremap failed.\n");
>>   		goto out_release;
>>   	}
>> +#ifdef CONFIG_OF
>> +	if (np&&  of_device_is_available(np)) {
>> +		pd = sh_eth_parse_dt(&pdev->dev, ndev);
>> +		if (pdev->dev.platform_data) {
>> +			struct sh_eth_plat_data *tmp =
>> +				pdev->dev.platform_data;
>> +			pd->set_mdio_gate = tmp->set_mdio_gate;
>> +			pd->needs_init = tmp->needs_init;
>> +		}
>> +	} else
>> +#endif
>> +		pd = (struct sh_eth_plat_data *)(pdev->dev.platform_data);
>> +
>> +	if (!pd) {
>> +		dev_err(&pdev->dev, "no setup data defined\n");
>> +		ret = -EINVAL;
>> +		goto out_release;
>> +	}
>> +
>> +	SET_NETDEV_DEV(ndev,&pdev->dev);
>> +
>> +	mdp->num_tx_ring = TX_RING_SIZE;
>> +	mdp->num_rx_ring = RX_RING_SIZE;
>>
>>   	spin_lock_init(&mdp->lock);
>>   	mdp->pdev = pdev;
>>   	pm_runtime_enable(&pdev->dev);
>>   	pm_runtime_resume(&pdev->dev);
>>
>> -	pd = (struct sh_eth_plat_data *)(pdev->dev.platform_data);
>>   	/* get PHY ID */
>>   	mdp->phy_id = pd->phy;
>>   	mdp->phy_interface = pd->phy_interface;
>> @@ -2412,6 +2509,8 @@ static int sh_eth_drv_probe(struct platform_device
>> *pdev)
>>   	mdp->no_ether_link = pd->no_ether_link;
>>   	mdp->ether_link_active_low = pd->ether_link_active_low;
>>   	mdp->reg_offset = sh_eth_get_register_offset(pd->register_type);
>> +	/* read and set MAC address */
>> +	read_mac_address(ndev, pd->mac_addr);
>>
>>   	/* set cpu data */
>>   #if defined(SH_ETH_HAS_BOTH_MODULES)
>> @@ -2429,20 +2528,16 @@ static int sh_eth_drv_probe(struct platform_device
>> *pdev)
>>   	/* debug message level */
>>   	mdp->msg_enable = SH_ETH_DEF_MSG_ENABLE;
>>
>> -	/* read and set MAC address */
>> -	read_mac_address(ndev, pd->mac_addr);
>> -
>>   	/* ioremap the TSU registers */
>>   	if (mdp->cd->tsu) {
>>   		struct resource *rtsu;
>>   		rtsu = platform_get_resource(pdev, IORESOURCE_MEM, 1);
>>   		if (!rtsu) {
>>   			dev_err(&pdev->dev, "Not found TSU resource\n");
>> -			ret = -ENODEV;
>>   			goto out_release;
>>   		}
>>   		mdp->tsu_addr = ioremap(rtsu->start,
>> -					resource_size(rtsu));
>> +				resource_size(rtsu));
>>   		mdp->port = devno % 2;
>>   		ndev->features = NETIF_F_HW_VLAN_FILTER;
>>   	}
>> @@ -2522,17 +2617,24 @@ static int sh_eth_runtime_nop(struct device *dev)
>>   	return 0;
>>   }
>>
>> -static struct dev_pm_ops sh_eth_dev_pm_ops = {
> CONFIG_PM?

Yes, I will add this.

>
>> +static const struct dev_pm_ops sh_eth_dev_pm_ops = {
>>   	.runtime_suspend = sh_eth_runtime_nop,
>>   	.runtime_resume = sh_eth_runtime_nop,
>>   };
>>
>> +static struct of_device_id sh_eth_match[] = {
>
> You have missed the const specifier here

OK, I will fix.

>
>> +	{ .compatible = "renesas,sh-eth",},
>> +	{},
>> +};
>> +MODULE_DEVICE_TABLE(of, sh_eth_match);
>> +
>
> if CONFIG_OF is not defined it's not needed.
>

OK, I will add CONFIG_OF and update platform_driver.

>>   static struct platform_driver sh_eth_driver = {
>>   	.probe = sh_eth_drv_probe,
>>   	.remove = sh_eth_drv_remove,
>>   	.driver = {
>>   		   .name = CARDNAME,
>>   		   .pm =&sh_eth_dev_pm_ops,
>> +		   .of_match_table = sh_eth_match,
>>   	},
>>   };

Thank you for your review.

Best regards,
   Nobuhiro
