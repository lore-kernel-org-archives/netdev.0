From: "Yankejian (Hackim Yim)" <yankejian@huawei.com>
Subject: Re: [patch net-next 01/11] net: hisilicon: add support of acpi for
 hns-mdio
Date: Mon, 16 May 2016 15:10:32 +0800
Message-ID: <57397268.4090305@huawei.com>
References: <1463127557-90824-1-git-send-email-Yisen.Zhuang@huawei.com>
 <1463127557-90824-2-git-send-email-Yisen.Zhuang@huawei.com>
 <1463144371.17131.336.camel@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <arnd@arndb.de>, <andrew@lunn.ch>, <geliangtang@163.com>,
	<ivecera@redhat.com>, <fengguang.wu@intel.com>,
	<charles.chenxin@huawei.com>, <haifeng.wei@huawei.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linuxarm@huawei.com>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Yisen Zhuang <Yisen.Zhuang@huawei.com>, <davem@davemloft.net>,
	<rjw@rjwysocki.net>, <lenb@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463144371.17131.336.camel@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016/5/13 20:59, Andy Shevchenko wrote:
> On Fri, 2016-05-13 at 16:19 +0800, Yisen Zhuang wrote:
>> From: Kejian Yan <yankejian@huawei.com>
>>
>> hns-mdio needs to register itself to mii-bus. The info of the device
>> can
>> be read by both OF and ACPI.
>> HNS tries to call Linux PHY driver to help access PHY-devices, the HNS
>> hardware topology is as below. The MDIO controller may control several
>> PHY-devices, and each PHY-device connects to a MAC device. The MDIO
>> will
>> be registered to mdiobus, then PHY-devices will register when each mac
>> find PHY device.
>>                        cpu
>>                         |
>>                         |
>>      -------------------------------------------
>>     |                   |                       |
>>     |                   |                       |
>>     |                  dsaf                     |
>>    MDIO                 |                      MDIO
>>     |      ---------------------------          |
>>     |     |         |         |       |         |
>>     |     |         |         |       |         |
>>     |    MAC       MAC       MAC     MAC        |
>>     |     |         |         |       |         |
>>      ---- |-------- |-------- |       | --------
>>          ||        ||        ||       ||
>>          PHY       PHY       PHY     PHY
>>
>> And the driver can handle reset sequence by _DSD method in DSDT in
>> ACPI case.
>>
>> Signed-off-by: Kejian Yan <yankejian@huawei.com>
>> Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
>> ---
>>  drivers/net/ethernet/hisilicon/hns_mdio.c | 145 ++++++++++++++++++---
>> ---------
>>  1 file changed, 90 insertions(+), 55 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/hisilicon/hns_mdio.c
>> b/drivers/net/ethernet/hisilicon/hns_mdio.c
>> index 765ddb3..4b779df 100644
>> --- a/drivers/net/ethernet/hisilicon/hns_mdio.c
>> +++ b/drivers/net/ethernet/hisilicon/hns_mdio.c
>> @@ -7,6 +7,7 @@
>>   * (at your option) any later version.
>>   */
>>  
>> +#include <linux/acpi.h>
>>  #include <linux/errno.h>
>>  #include <linux/etherdevice.h>
>>  #include <linux/init.h>
>> @@ -354,64 +355,72 @@ static int hns_mdio_reset(struct mii_bus *bus)
>>  	struct hns_mdio_device *mdio_dev = (struct hns_mdio_device
>> *)bus->priv;
>>  	int ret;
>>  
>> -	if (!mdio_dev->subctrl_vbase) {
>> -		dev_err(&bus->dev, "mdio sys ctl reg has not
>> maped\n");
>> -		return -ENODEV;
>> -	}
>> -
>> -	/*1. reset req, and read reset st check*/
>> -	ret = mdio_sc_cfg_reg_write(mdio_dev, MDIO_SC_RESET_REQ, 0x1,
>> -				    MDIO_SC_RESET_ST, 0x1,
>> -				    MDIO_CHECK_SET_ST);
>> -	if (ret) {
>> -		dev_err(&bus->dev, "MDIO reset fail\n");
>> -		return ret;
>> -	}
>> +	if (IS_ENABLED(CONFIG_OF) && bus->parent->of_node) {
> Can you keep indentation the same?
>
> Also I suggest to use struct fwnode_handle, and this will be something
> like
>
> if (is_of_node(...))
ok, thanks Andy. i will fix it in next submit

>
>> +		if (!mdio_dev->subctrl_vbase) {
>> +			dev_err(&bus->dev, "mdio sys ctl reg has not
>> maped\n");
>> +			return -ENODEV;
>> +		}
>>  
>> -	/*2. dis clk, and read clk st check*/
>> -	ret = mdio_sc_cfg_reg_write(mdio_dev, MDIO_SC_CLK_DIS,
>> -				    0x1, MDIO_SC_CLK_ST, 0x1,
>> -				    MDIO_CHECK_CLR_ST);
>> -	if (ret) {
>> -		dev_err(&bus->dev, "MDIO dis clk fail\n");
>> -		return ret;
>> -	}
>> +		/*1. reset req, and read reset st check*/
>> +		ret = mdio_sc_cfg_reg_write(mdio_dev,
>> MDIO_SC_RESET_REQ, 0x1,
>> +					    MDIO_SC_RESET_ST, 0x1,
>> +					    MDIO_CHECK_SET_ST);
>> +		if (ret) {
>> +			dev_err(&bus->dev, "MDIO reset fail\n");
>> +			return ret;
>> +		}
>>  
>> -	/*3. reset dreq, and read reset st check*/
>> -	ret = mdio_sc_cfg_reg_write(mdio_dev, MDIO_SC_RESET_DREQ,
>> 0x1,
>> -				    MDIO_SC_RESET_ST, 0x1,
>> -				    MDIO_CHECK_CLR_ST);
>> -	if (ret) {
>> -		dev_err(&bus->dev, "MDIO dis clk fail\n");
>> -		return ret;
>> -	}
>> +		/*2. dis clk, and read clk st check*/
>> +		ret = mdio_sc_cfg_reg_write(mdio_dev,
>> MDIO_SC_CLK_DIS,
>> +					    0x1, MDIO_SC_CLK_ST, 0x1,
>> +					    MDIO_CHECK_CLR_ST);
>> +		if (ret) {
>> +			dev_err(&bus->dev, "MDIO dis clk fail\n");
>> +			return ret;
>> +		}
>>  
>> -	/*4. en clk, and read clk st check*/
>> -	ret = mdio_sc_cfg_reg_write(mdio_dev, MDIO_SC_CLK_EN,
>> -				    0x1, MDIO_SC_CLK_ST, 0x1,
>> -				    MDIO_CHECK_SET_ST);
>> -	if (ret)
>> -		dev_err(&bus->dev, "MDIO en clk fail\n");
>> +		/*3. reset dreq, and read reset st check*/
>> +		ret = mdio_sc_cfg_reg_write(mdio_dev,
>> MDIO_SC_RESET_DREQ, 0x1,
>> +					    MDIO_SC_RESET_ST, 0x1,
>> +					    MDIO_CHECK_CLR_ST);
>> +		if (ret) {
>> +			dev_err(&bus->dev, "MDIO dis clk fail\n");
>> +			return ret;
>> +		}
>>  
>> +		/*4. en clk, and read clk st check*/
>> +		ret = mdio_sc_cfg_reg_write(mdio_dev, MDIO_SC_CLK_EN,
>> +					    0x1, MDIO_SC_CLK_ST, 0x1,
>> +					    MDIO_CHECK_SET_ST);
>> +		if (ret)
>> +			dev_err(&bus->dev, "MDIO en clk fail\n");
>> +	} else if (ACPI_COMPANION(bus->parent)) {
>> +		acpi_status s;
>> +
>> +		s = acpi_evaluate_object(ACPI_HANDLE(bus->parent),
>> +					 "_RST", NULL, NULL);
>> +		if (ACPI_FAILURE(s)) {
>> +			dev_err(&bus->dev, "Reset failed,
>> return:%#x\n", s);
>> +			ret = -EBUSY;
>> +		} else {
>> +			ret = 0;
>> +		}
>> +	} else {
>> +		dev_err(&bus->dev, "cannot get cfd data from of or
>> acpi\n");
> cannot -> Can not
>
> WTF cfd?
>
> of or acpi -> DT or ACPI

ok, thanks Andy. i will fix it in next submit

>> +		ret = -ENXIO;
>> +	}
>>  	return ret;
>>  }
>>  
>>  /**
>>   * hns_mdio_bus_name - get mdio bus name
>>   * @name: mdio bus name
>> - * @np: mdio device node pointer
>> + * @addr: mdio physical address
>>   */
>> -static void hns_mdio_bus_name(char *name, struct device_node *np)
>> +static void hns_mdio_bus_name(char *name, phys_addr_t addr)
>>  {
>> -	const u32 *addr;
>> -	u64 taddr = OF_BAD_ADDR;
>> -
>> -	addr = of_get_address(np, 0, NULL, NULL);
>> -	if (addr)
>> -		taddr = of_translate_address(np, addr);
>> -
>> -	snprintf(name, MII_BUS_ID_SIZE, "%s@%llx", np->name,
>> -		 (unsigned long long)taddr);
>> +	snprintf(name, MII_BUS_ID_SIZE,
>> +		 "hns-mdio@%llx", (unsigned long long)addr);
>>  }
>>  
>>  /**
>> @@ -422,7 +431,6 @@ static void hns_mdio_bus_name(char *name, struct
>> device_node *np)
>>   */
>>  static int hns_mdio_probe(struct platform_device *pdev)
>>  {
>> -	struct device_node *np;
>>  	struct hns_mdio_device *mdio_dev;
>>  	struct mii_bus *new_bus;
>>  	struct resource *res;
>> @@ -432,7 +440,7 @@ static int hns_mdio_probe(struct platform_device
>> *pdev)
>>  		dev_err(NULL, "pdev is NULL!\r\n");
>>  		return -ENODEV;
>>  	}
>> -	np = pdev->dev.of_node;
>> +
>>  	mdio_dev = devm_kzalloc(&pdev->dev, sizeof(*mdio_dev),
>> GFP_KERNEL);
>>  	if (!mdio_dev)
>>  		return -ENOMEM;
>> @@ -448,7 +456,6 @@ static int hns_mdio_probe(struct platform_device
>> *pdev)
>>  	new_bus->write = hns_mdio_write;
>>  	new_bus->reset = hns_mdio_reset;
>>  	new_bus->priv = mdio_dev;
>> -	hns_mdio_bus_name(new_bus->id, np);
>>  
>>  	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>>  	mdio_dev->vbase = devm_ioremap_resource(&pdev->dev, res);
>> @@ -457,16 +464,37 @@ static int hns_mdio_probe(struct platform_device
>> *pdev)
>>  		return ret;
>>  	}
>>  
>> -	mdio_dev->subctrl_vbase =
>> -		syscon_node_to_regmap(of_parse_phandle(np, "subctrl-
>> vbase", 0));
>> -	if (IS_ERR(mdio_dev->subctrl_vbase)) {
>> -		dev_warn(&pdev->dev, "no syscon hisilicon,peri-c-
>> subctrl\n");
>> -		mdio_dev->subctrl_vbase = NULL;
>> +	hns_mdio_bus_name(new_bus->id, res->start);
>> +	if (IS_ENABLED(CONFIG_OF) && pdev->dev.of_node) {
> is_of_node()

ok, thanks Andy. i will fix it in next submit

>> +		mdio_dev->subctrl_vbase = syscon_node_to_regmap(
>> +			of_parse_phandle(pdev->dev.of_node,
>> +					 "subctrl-vbase", 0));
>> +		if (IS_ERR(mdio_dev->subctrl_vbase)) {
>> +			dev_warn(&pdev->dev, "no syscon
>> hisilicon,peri-c-subctrl\n");
>> +			mdio_dev->subctrl_vbase = NULL;
>> +		}
>>  	}
>>  	new_bus->parent = &pdev->dev;
>>  	platform_set_drvdata(pdev, new_bus);
>>  
>> -	ret = of_mdiobus_register(new_bus, np);
>> +	if (IS_ENABLED(CONFIG_OF) && pdev->dev.of_node) {
> Ditto
>
>> +		ret = of_mdiobus_register(new_bus, pdev-
>>> dev.of_node);
>> +	} else if (ACPI_COMPANION(&pdev->dev)) {
> is_acpi_node()
>
>> +		/* Clear all the IRQ properties */
>> +		memset(new_bus->irq, PHY_POLL, 4 * PHY_MAX_ADDR);
>> +
>> +		/* Mask out all PHYs from auto probing. */
>> +		new_bus->phy_mask = ~0;
>> +
>> +		/* Register the MDIO bus */
>> +		ret = mdiobus_register(new_bus);
>> +		if (ret)
>> +			return ret;
>> +	} else {
>> +		dev_err(&pdev->dev, "cannot get cfd data from of or
>> acpi\n");
> Same as for previous message.
>
>> +		return -ENXIO;
>> +	}
>> +
>>  	if (ret) {
>>  		dev_err(&pdev->dev, "Cannot register as MDIO
>> bus!\n");
>>  		platform_set_drvdata(pdev, NULL);
>> @@ -499,12 +527,19 @@ static const struct of_device_id
>> hns_mdio_match[] = {
>>  	{}
>>  };
>>  
>> +static const struct acpi_device_id hns_mdio_acpi_match[] = {
>> +	{ "HISI0141", 0 },
>> +	{ },
>> +};
>> +MODULE_DEVICE_TABLE(acpi, hns_mdio_acpi_match);
>> +
>>  static struct platform_driver hns_mdio_driver = {
>>  	.probe = hns_mdio_probe,
>>  	.remove = hns_mdio_remove,
>>  	.driver = {
>>  		   .name = MDIO_DRV_NAME,
>>  		   .of_match_table = hns_mdio_match,
>> +		   .acpi_match_table = ACPI_PTR(hns_mdio_acpi_match),
>>  		   },
>>  };
>>  
>
> So, I suggest to split this to two logical changes:
>
> 1. Move to use fwnode_handle
> 2. Add ACPI bits

ok, thanks Andy. i will fix it in next submit

MBR,
Kejian
