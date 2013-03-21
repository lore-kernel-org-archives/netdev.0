From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: Re: [PATCH v6] net: sh_eth: Add support of device tree probe
Date: Thu, 21 Mar 2013 16:03:39 +0900
Message-ID: <514AB0CB.2030808@renesas.com>
References: <1363675196-8940-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
 <51486699.6000908@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	magnus.damm@gmail.com, kda@linux-powerpc.org,
	horms+renesas@verge.net.au, mark.rutland@arm.com,
	grant.likely@secretlab.ca
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor3.renesas.com ([210.160.252.173]:51101 "EHLO
	relmlor3.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752198Ab3CUHDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 03:03:42 -0400
Received: from relmlir2.idc.renesas.com ([10.200.68.152])
 by relmlor3.idc.renesas.com ( SJSMS)
 with ESMTP id <0MK0000SQ0Y4G1D0@relmlor3.idc.renesas.com> for
 netdev@vger.kernel.org; Thu, 21 Mar 2013 16:03:40 +0900 (JST)
Received: from relmlac4.idc.renesas.com ([10.200.69.24])
 by relmlir2.idc.renesas.com ( SJSMS)
 with ESMTP id <0MK00026S0Y4JI80@relmlir2.idc.renesas.com> for
 netdev@vger.kernel.org; Thu, 21 Mar 2013 16:03:40 +0900 (JST)
In-reply-to: <51486699.6000908@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Thank you for your comment.

(2013/03/19 22:22), Sergei Shtylyov wrote:
> On 19-03-2013 10:39, Nobuhiro Iwamatsu wrote:
>
>> This adds support of device tree probe for Renesas sh-ether driver.
>
>> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
>
>> V6: - Add renesas,sh-eth-gigabit, renesas,sh-eth-sh4 and
>> renesas,sh-eth-sh3-sh2 to compatible string.
>> - Remove sh-eth,register-type. This is supplemented by the
>> compatible string.
>> - Use the of_property_read_bool instead of of_find_property.
>> - Add sanity chheck for of_property_read_u32.
>> - Update document.
>> V5: - Rewrite sh_eth_parse_dt().
>> Remove of_device_is_available() and CONFIG_OF from support OF
>> checking function and re-add empty sh_eth_parse_dt().
>> - Add CONFIG_PM to definition of dev_pm_ops.
>> - Add CONFIG_OF to definition of of_device_id.
>> V4: - Remove empty sh_eth_parse_dt().
>> V3: - Remove empty sh_eth_parse_dt().
>> V3: - Removed sentnece of "needs-init" from document.
>> V2: - Removed ether_setup().
>> - Fixed typo from "sh-etn" to "sh-eth".
>> - Removed "needs-init" and sh-eth,endian from definition of DT.
>> - Changed "sh-eth,edmac-endian" instead of "sh-eth,edmac-big-endain"
>> in definition of DT.
>> ---
>> Documentation/devicetree/bindings/net/sh_ether.txt | 48 +++++++
>> drivers/net/ethernet/renesas/sh_eth.c | 145 ++++++++++++++++----
>> 2 files changed, 168 insertions(+), 25 deletions(-)
>> create mode 100644 Documentation/devicetree/bindings/net/sh_ether.txt
>
>> diff --git a/Documentation/devicetree/bindings/net/sh_ether.txt b/Documentation/devicetree/bindings/net/sh_ether.txt
>> new file mode 100644
>> index 0000000..d1f961c
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/sh_ether.txt
>> @@ -0,0 +1,48 @@
>> +* Renesas Electronics SuperH EMAC
>> +
>> +This file provides information, what the device node
>> +for the sh_eth interface contains.
>> +
>> +Required properties:
>> +- compatible: "renesas,sh-eth-gigabit": If a device has
>> + a function of gigabit, you should
>> + set this.
>> + "renesas,sh-eth-sh4": If this is provided by
>> + SH4, you should set this.
>> + "renesas,sh-eth-sh3-sh2": If this is provided
>> + by SH3 or SH2, you should set this.
>> +
>> +- interrupt-parent: The phandle for the interrupt controller that
>> + services interrupts for this device.
>> +
>> +- reg: Offset and length of the register set for the
>> + device. If device has TSU registers, you need
>> + to set up two register information here.
>> +
>> +- interrupts: Interrupt mapping for the sh_eth interrupt
>> + sources (vector id). You can set one value.
>> +
>> +- phy-mode: String, operation mode of the PHY interface
>> + (a string that of_get_phy_mode() can understand).
>> +
>> +- sh-eth,phy-id: PHY id.
>> +
>> +Optional properties:
>> +- local-mac-address: 6 bytes, mac address
>> +- sh-eth,no-ether-link: Set link control by software. When device does
>
> I got the impression that usually the vendor name, not driver name is used as a property prefix.

Ok, I will change to vendor name.

>
>> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
>> index 7a6471d..d9df68e 100644
>> --- a/drivers/net/ethernet/renesas/sh_eth.c
>> +++ b/drivers/net/ethernet/renesas/sh_eth.c
>> @@ -1,7 +1,7 @@
>> /*
>> * SuperH Ethernet device driver
>> *
>> - * Copyright (C) 2006-2012 Nobuhiro Iwamatsu
>> + * Copyright (C) 2006-2013 Nobuhiro Iwamatsu
>> * Copyright (C) 2008-2012 Renesas Solutions Corp.
>
> Don't you want to extend the copyright of Renesas also -- you seem to be still working there. :-)
>

Thanks, I will fix.

>> @@ -2391,12 +2451,33 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
>> goto out_release;
>> }
>>
>> + if (np) {
>> + pd = sh_eth_parse_dt(&pdev->dev, ndev, np);
>> + if (pdev->dev.platform_data && pd) {
>> + struct sh_eth_plat_data *tmp =
>> + pdev->dev.platform_data;
>> + pd->set_mdio_gate = tmp->set_mdio_gate;
>> + pd->needs_init = tmp->needs_init;
>
> OK, so we can't fully convert this driver to the device tree due to procedural platform data.
 > I then would advice just using OF_DEV_AUXDATA() in the platform data instead of trying to convert the driver to device tree.

Yes, I knew about this.

>
> [...]
>> @@ -2422,20 +2505,16 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
> [...]
>> mdp->tsu_addr = ioremap(rtsu->start,
>> - resource_size(rtsu));
>> + resource_size(rtsu));
>
> Why? It was indented perfectly before. Anyway, you shouldn't be doing collateral whitespace changes.
>

Ok, I will remove this change from this patch.

>> mdp->port = devno % 2;
>> ndev->features = NETIF_F_HW_VLAN_FILTER;
>> }
>> @@ -2502,6 +2581,7 @@ static int sh_eth_drv_remove(struct platform_device *pdev)
>> return 0;
>> }
>>
>> +#ifdef CONFIG_PM
>
> Unrelated change.
>
>> static int sh_eth_runtime_nop(struct device *dev)
>> {
>> /*
>> @@ -2515,17 +2595,32 @@ static int sh_eth_runtime_nop(struct device *dev)
>> return 0;
>> }
>>
>> -static struct dev_pm_ops sh_eth_dev_pm_ops = {
>> +static const struct dev_pm_ops sh_eth_dev_pm_ops = {
>> .runtime_suspend = sh_eth_runtime_nop,
>> .runtime_resume = sh_eth_runtime_nop,
>> };
>> +#define SH_ETH_PM_OPS (&sh_eth_dev_pm_ops)
>
> () not needed.
>
>> +#else
>> +#define SH_ETH_PM_OPS NULL
>> +#endif
>
> Unrelated change. Should be in a different patch.

Yes, I will remove these changes from this patch.

>
>> +
>> +#ifdef CONFIG_OF
>> +static const struct of_device_id sh_eth_match[] = {
>> + { .compatible = "renesas,sh-eth-gigabit", },
>> + { .compatible = "renesas,sh-eth-sh4", },
>> + { .compatible = "renesas,sh-eth-sh3-sh2", },
>
> Biut this is not really enough: the driver supports much more variations of the SH and ARM SoCs
> all of which have difference not only in register layout but also in the registers bits or even
 > presence of the whole register blocks. All this IMO should be reflected in the different values
 > of the compatible "property". BTW, it seems another register layout and instance needs to be added
 > for the R-Car SoCs (instead of the current ugly hack).

I see.
Latest source code was defined compatible as renesas,sh-eth-gigabit,
sh-eth-sh4 and sh-eth-sh3-sh2. I will change ito renesas,<CPU>-sh-eth.
And I think that we should define the sh7757-sh-eth-gitabit and
sh7757-sh-eth-fast for this. Becauase sh7757 is special device.
There is a device that supports only devices that support fast
ether and gigabit ether on single CPU.

Therefore, the compatible property of this device becomes <CPU>-sh-eth
or <CPU>-sh-eth-<ETHER TYPE>.

How about this?

>
>> + {},
>> +};
>> +MODULE_DEVICE_TABLE(of, sh_eth_match);
>> +#endif
>>
>> static struct platform_driver sh_eth_driver = {
>> .probe = sh_eth_drv_probe,
>> .remove = sh_eth_drv_remove,
>> .driver = {
>> .name = CARDNAME,
>> - .pm = &sh_eth_dev_pm_ops,
>> + .pm = SH_ETH_PM_OPS,
>
> Unrelated as well.
>

Yes, this is too.

> WBR, Sergei
>
>
