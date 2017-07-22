From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH V3 net-next 6/8] net: hns3: Add MDIO support to HNS3
 Ethernet driver for hip08 SoC
Date: Sat, 22 Jul 2017 23:53:32 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B81CCFE@FRAEML521-MBX.china.huawei.com>
References: <20170617172431.177044-1-salil.mehta@huawei.com>
 <20170617172431.177044-7-salil.mehta@huawei.com>
 <20170619035244.GC13292@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        huangdaode <huangdaode@hisilicon.com>,
        "lipeng (Y)" <lipeng321@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170619035244.GC13292@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Monday, June 19, 2017 4:53 AM
> To: Salil Mehta
> Cc: davem@davemloft.net; Zhuangyuzeng (Yisen); huangdaode; lipeng (Y);
> mehta.salil.lnk@gmail.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH V3 net-next 6/8] net: hns3: Add MDIO support to
> HNS3 Ethernet driver for hip08 SoC
> 
> On Sat, Jun 17, 2017 at 06:24:29PM +0100, Salil Mehta wrote:
> > This patch adds the support of MDIO bus interface for HNS3 driver.
> > Code provides various interfaces to start and stop the PHY layer
> > and to read and write the MDIO bus or PHY.
> >
> > Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
> > Signed-off-by: lipeng <lipeng321@huawei.com>
> > Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
> > Signed-off-by: Yisen Zhuang <yisen.zhuang@huawei.com>
> > ---
> > Patch V3: Addressed Below comments:
> >  1. Florian Fainelli: https://lkml.org/lkml/2017/6/13/963
> >  2. Andrew Lunn: https://lkml.org/lkml/2017/6/13/1039
> 
> It is normal to say what you actually changed.
> 
> > Patch V2: Addressed below comments:
> >  1. Florian Fainelli: https://lkml.org/lkml/2017/6/10/130
> >  2. Andrew Lunn: https://lkml.org/lkml/2017/6/10/168
> > Patch V1: Initial Submit
> > ---
> >  .../ethernet/hisilicon/hns3/hns3pf/hclge_mdio.c    | 249
> +++++++++++++++++++++
> >  1 file changed, 249 insertions(+)
> >  create mode 100644
> drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_mdio.c
> >
> > diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_mdio.c
> b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_mdio.c
> > new file mode 100644
> > index 0000000..5b21c50
> > --- /dev/null
> > +++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_mdio.c
> > @@ -0,0 +1,249 @@
> > +/*
> > + * Copyright (c) 2016~2017 Hisilicon Limited.
> > + *
> > + * This program is free software; you can redistribute it and/or
> modify
> > + * it under the terms of the GNU General Public License as published
> by
> > + * the Free Software Foundation; either version 2 of the License, or
> > + * (at your option) any later version.
> > + */
> > +
> > +#include <linux/etherdevice.h>
> > +#include <linux/kernel.h>
> > +
> > +#include "hclge_cmd.h"
> > +#include "hclge_main.h"
> > +
> > +enum hclge_mdio_c22_op_seq {
> > +	HCLGE_MDIO_C22_WRITE = 1,
> > +	HCLGE_MDIO_C22_READ = 2
> > +};
> > +
> > +#define HCLGE_MDIO_CTRL_START_BIT       BIT(0)
> > +#define HCLGE_MDIO_CTRL_ST_MSK  GENMASK(2, 1)
> > +#define HCLGE_MDIO_CTRL_ST_LSH  1
> > +#define HCLGE_MDIO_IS_C22(c22)  (((c22) << HCLGE_MDIO_CTRL_ST_LSH) &
> \
> > +	HCLGE_MDIO_CTRL_ST_MSK)
> > +
> > +#define HCLGE_MDIO_CTRL_OP_MSK  GENMASK(4, 3)
> > +#define HCLGE_MDIO_CTRL_OP_LSH  3
> > +#define HCLGE_MDIO_CTRL_OP(access) \
> > +	(((access) << HCLGE_MDIO_CTRL_OP_LSH) &	HCLGE_MDIO_CTRL_OP_MSK)
> > +#define HCLGE_MDIO_CTRL_PRTAD_MSK       GENMASK(4, 0)
> > +#define HCLGE_MDIO_CTRL_DEVAD_MSK       GENMASK(4, 0)
> 
> This all seems overly complex. How about
> 
> #define HCLGE_MDIO_CTRL_START_BIT       BIT(0)
> #define HCLGE_MDIO_C22			BIT(1)
> #define HCLGE_MDIO_WRITE		(1 << 3)
> #define HCLGE_MDIO_READ			(2 << 3)
> #define HCLGE_MDIO_C22_WRITE		(HCLGE_MDIO_CTRL_START_BIT |
> HCLGE_MDIO_C22 | HCLGE_MDIO_WRITE)
> #define HCLGE_MDIO_C22_READ		(HCLGE_MDIO_CTRL_START_BIT |
> HCLGE_MDIO_C22 | HCLGE_MDIO_READ)
> #define HCLGE_MDIO_C45_WRITE		(HCLGE_MDIO_CTRL_START_BIT |
> HCLGE_MDIO_WRITE)
> #define HCLGE_MDIO_C45_READ		(HCLGE_MDIO_CTRL_START_BIT |
> HCLGE_MDIO_READ)
> 
> #define HCLGE_MDIO_STATUS_ERROR		BIT(0)
> 
> Keep it simple, don't have more defines than what you need.
Sure, changed in V4 Patch, Thanks!

Salil
> 
> > +static int hclge_mdio_write(struct mii_bus *bus, int phy_id, int
> regnum,
> > +			    u16 data)
> > +{
> > +	struct hclge_dev *hdev = (struct hclge_dev *)bus->priv;
> > +	struct hclge_mdio_cfg_cmd *mdio_cmd;
> > +	enum hclge_cmd_status status;
> > +	struct hclge_desc desc;
> > +	u8 devad;
> > +
> > +	if (!bus)
> > +		return -EINVAL;
> > +
> > +	devad = ((regnum >> 16) & 0x1f);
> 
> So you have changed this to only support C22. Which means devad is not
> needed, since that is c45 only.
Thanks for catching. Removed this from MDIO file.

Best regards
Salil
> 
> > +
> > +	dev_dbg(&bus->dev, "phy id=%d, devad=%d\n", phy_id, devad);
> > +
> > +	hclge_cmd_setup_basic_desc(&desc, HCLGE_OPC_MDIO_CONFIG, false);
> > +
> > +	mdio_cmd = (struct hclge_mdio_cfg_cmd *)desc.data;
> > +
> > +	mdio_cmd->prtad = phy_id & HCLGE_MDIO_CTRL_PRTAD_MSK;
> > +	mdio_cmd->data_wr = cpu_to_le16(data);
> > +	mdio_cmd->devad = devad & HCLGE_MDIO_CTRL_DEVAD_MSK;
> > +
> > +	/* Write reg and data */
> > +	mdio_cmd->ctrl_bit = HCLGE_MDIO_IS_C22(1);
> 
> Passing the parameter is now pointless if you are only doing C22.
Sure, changed.

> 
> > +	mdio_cmd->ctrl_bit |= HCLGE_MDIO_CTRL_OP(HCLGE_MDIO_C22_WRITE);
> > +	mdio_cmd->ctrl_bit |= HCLGE_MDIO_CTRL_START_BIT;
> 
> Given the above defines, this now becomes
> 
> 	mdio_cmd->ctrl_bit = HCLGE_MDIO_C22_WRITE;

Sure, changed.

> 
> > +
> > +	status = hclge_cmd_send(&hdev->hw, &desc, 1);
> > +	if (status) {
> > +		dev_err(&hdev->pdev->dev,
> > +			"mdio write fail when sending cmd, status is %d.\n",
> > +			status);
> > +		return -EIO;
> > +	}
> > +
> > +	return 0;
> > +}
> > +
> > +static int hclge_mdio_read(struct mii_bus *bus, int phy_id, int
> regnum)
> > +{
> > +	struct hclge_dev *hdev = (struct hclge_dev *)bus->priv;
> > +	struct hclge_mdio_cfg_cmd *mdio_cmd;
> > +	enum hclge_cmd_status status;
> > +	struct hclge_desc desc;
> > +	u8 devad;
> > +
> > +	if (!bus)
> > +		return -EINVAL;
> > +
> > +	devad = ((regnum >> 16) & GENMASK(4, 0));
> > +
> > +	hclge_cmd_setup_basic_desc(&desc, HCLGE_OPC_MDIO_CONFIG, true);
> > +
> > +	mdio_cmd = (struct hclge_mdio_cfg_cmd *)desc.data;
> > +
> > +	dev_dbg(&bus->dev, "phy id=%d, devad=%d\n", phy_id, devad);
> 
> Generally, you would do this after the read has completed, so you can
> include the value read.
Ok, yes. Changed in V4 patch.

Thanks
> 
> > +
> > +	mdio_cmd->prtad = phy_id & HCLGE_MDIO_CTRL_PRTAD_MSK;
> > +	mdio_cmd->devad = devad & HCLGE_MDIO_CTRL_DEVAD_MSK;
> > +
> > +	/* Write reg and data */
> > +	mdio_cmd->ctrl_bit = HCLGE_MDIO_IS_C22(1);
> > +	mdio_cmd->ctrl_bit |= HCLGE_MDIO_CTRL_OP(HCLGE_MDIO_C22_WRITE);
> > +	mdio_cmd->ctrl_bit |= HCLGE_MDIO_CTRL_START_BIT;
> > +
> > +	/* Read out phy data */
> > +	status = hclge_cmd_send(&hdev->hw, &desc, 1);
> > +	if (status) {
> > +		dev_err(&hdev->pdev->dev,
> 
> Be consistent. With dev_dbg() you used bus->dev.
I agree usage had been not uniform. Changed !

Thanks
Salil
> 
> > +			"mdio read fail when get data, status is %d.\n",
> > +			status);
> > +		return status;
> > +	}
> > +
> > +	if (HCLGE_MDIO_STA_VAL(mdio_cmd->sta)) {
> 
>   	if (mdio_cmd->status & HCLGE_MDIO_STATUS_ERROR) {
> 
> is much more readable.
Sure.

> 
> > +		dev_err(&hdev->pdev->dev, "mdio read data error\n");
> > +		return -EIO;
> > +	}
> > +
> > +	return le16_to_cpu(mdio_cmd->data_rd);
> > +}
> > +
> > +int hclge_mac_mdio_config(struct hclge_dev *hdev)
> > +{
> > +	struct hclge_mac *mac = &hdev->hw.mac;
> > +	struct net_device *ndev = &mac->ndev;
> > +	struct phy_device *phy_dev;
> 
> It is normal to call this phydev.
Yes, I checked other driver as well. You are correct it is
quite common to be called as phydev. Changed!

Salil
> 
> > +	struct mii_bus *mdio_bus;
> > +	int ret;
> > +
> > +	if (hdev->hw.mac.phy_addr >= PHY_MAX_ADDR)
> > +		return 0;
> > +
> > +	SET_NETDEV_DEV(ndev, &hdev->pdev->dev);
> 
> It seems odd doing this here. It is normally done in the probe()
> function.
This was stray. It is already being done inside of the init of client function.

Thanks for catching.
Salil
> 
> > +
> > +	mdio_bus = devm_mdiobus_alloc(&hdev->pdev->dev);
> > +	if (!mdio_bus) {
> > +		ret = -ENOMEM;
> > +		goto err_miibus_alloc;
> > +	}
> > +
> 
> Just
> 		return -ENOMEM;
Sure, changed.

Thanks
> 
> > +	mdio_bus->name = "hisilicon MII bus";
> > +	mdio_bus->read = hclge_mdio_read;
> > +	mdio_bus->write = hclge_mdio_write;
> > +	snprintf(mdio_bus->id, MII_BUS_ID_SIZE, "%s-%s", "mii",
> > +		 dev_name(&hdev->pdev->dev));
> > +
> > +	mdio_bus->parent = &hdev->pdev->dev;
> > +	mdio_bus->priv = hdev;
> > +	mdio_bus->phy_mask = ~(1 << mac->phy_addr);
> > +	ret = mdiobus_register(mdio_bus);
> > +	if (ret) {
> > +		dev_err(mdio_bus->parent,
> > +			"Failed to register MDIO bus ret = %#x\n", ret);
> > +		goto err_mdio_register;
> 
> If register failed, you don't want to call unregister.
Yes sure.

> 
> > +	}
> > +
> > +	phy_dev = mdiobus_get_phy(mdio_bus, mac->phy_addr);
> > +	if (!phy_dev || IS_ERR(phy_dev)) {
> > +		dev_err(mdio_bus->parent, "Failed to get phy device\n");
> > +		ret = -EIO;
> > +		goto err_mdio_register;
> > +	}
> > +
> > +	phy_dev->irq = mdio_bus->irq[mac->phy_addr];
> 
> The core will do this for you in phy_device_create().
Yes agreed. Intact in our case it would be through below path?
  midobus_register->
		mdiobus_scan->
		     get_phy_device->
			      get_device_create()

Thanks
Salil
> 
> > +	mac->phy_dev = phy_dev;
> 
> After you have attached the phydev to the netdev, you can use
> ndev->phydev. It is better to use that, than keep it in the priv
> structure.
We don't have netdev coming to lower layers.

> 
> > +
> > +	return 0;
> > +
> > +err_mdio_register:
> > +	mdiobus_unregister(mdio_bus);
> > +	mdiobus_free(mdio_bus);
> 
> You allocated it using devm_mdiobus_alloc(). So this is going to cause
> a double free of the memory.
Removed

> 
> > +err_miibus_alloc:
> > +	return ret;
> > +}
> > +
> > +static void hclge_mac_adjust_link(struct net_device *net_dev)
> 
> ndev is the most used name for the net_device.
Changed.

> 
> > +{
> > +	struct hclge_mac *hw_mac;
> > +	struct hclge_dev *hdev;
> > +	struct hclge_hw *hw;
> > +	int duplex;
> > +	int speed;
> > +
> > +	if (!net_dev)
> > +		return;
> > +
> > +	hw_mac = container_of(net_dev, struct hclge_mac, ndev);
> > +	hw = container_of(hw_mac, struct hclge_hw, mac);
> > +	hdev = hw->back;
> > +
> > +	speed = hw_mac->phy_dev->speed;
> > +	duplex = hw_mac->phy_dev->duplex;
> 
> speed = ndev->phydev->speed
> duplex = ndev->phydev->duplex
Sure, thanks changed.

Salil
> 
> > +
> > +	/* update antoneg. */
> > +	hw_mac->autoneg = hw_mac->phy_dev->autoneg;
> > +
> > +	if ((hw_mac->speed != speed) || (hw_mac->duplex != duplex))
> > +		(void)hclge_cfg_mac_speed_dup(hdev, speed, !!duplex);
> > +}
> > +
> > +int hclge_mac_start_phy(struct hclge_dev *hdev)
> > +{
> > +	struct hclge_mac *mac = &hdev->hw.mac;
> > +	struct phy_device *phy_dev = mac->phy_dev;
> > +	struct net_device *ndev = &mac->ndev;
> > +	int ret;
> > +
> > +	if (!phy_dev)
> > +		return 0;
> > +
> > +	phy_dev->dev_flags = 0;
> 
> It is pretty unusual to do this. So a comment would be good explaining
> why it is needed.
> 
> > +
> > +	ret = phy_connect_direct(ndev, phy_dev,
> > +				 hclge_mac_adjust_link,
> > +				 PHY_INTERFACE_MODE_SGMII);
> > +	if (unlikely(ret)) {
> 
> If this was on the hotpath, handling 10 million packets per second,
> using unlikely() might bring some benefit. But this function is only
> going to be called once when the interface is opened. Don't use
> unlikely().
> 
> > +		pr_info("phy_connect_direct err");
> 
> 	netdev_dbg(ndev, "phy_connect_direct %d\n", ret);
> 
> > +		return -ENODEV;
> 
Yes, agreed.

> Use the error code which phy_connect_direct() gave you.
> 
> > +	}
> > +
> > +	phy_dev->supported = SUPPORTED_10baseT_Half |
> > +			SUPPORTED_10baseT_Full |
> > +			SUPPORTED_100baseT_Half |
> > +			SUPPORTED_100baseT_Full |
> > +			SUPPORTED_Autoneg |
> > +			SUPPORTED_1000baseT_Full;
> > +
> 
> phydev->supported &= PHY_GBIT_FEATURES;
> 
> > +	phy_start(mac->phy_dev);
> 
> phy_start(ndev->phydev)
> 
> > +
> > +	return 0;
> > +}
> > +
> > +void hclge_mac_stop_phy(struct hclge_dev *hdev)
> > +{
> > +	if (!hdev->hw.mac.phy_dev)
> > +		return;
> > +
> > +	phy_disconnect(hdev->hw.mac.phy_dev);
> > +	phy_stop(hdev->hw.mac.phy_dev);
> 
> No need to call phy_stop() if you have called phy_disconnect():
Yes, true. Thanks!

Salil
> 
> /**
>  * phy_disconnect - disable interrupts, stop state machine, and detach
> a PHY
>  *                  device
>  * @phydev: target phy_device struct
>  */
> 
>  Andrew
