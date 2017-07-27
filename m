From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH V4 net-next 6/8] net: hns3: Add MDIO support to HNS3
 Ethernet driver for hip08 SoC
Date: Thu, 27 Jul 2017 17:56:09 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B8283BC@FRAEML521-MBX.china.huawei.com>
References: <20170722220942.78852-1-salil.mehta@huawei.com>
 <20170722220942.78852-7-salil.mehta@huawei.com>
 <24043b65-27d3-13b9-1a25-8692ea9467af@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        huangdaode <huangdaode@hisilicon.com>,
        "lipeng (Y)" <lipeng321@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <24043b65-27d3-13b9-1a25-8692ea9467af@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Florian,

> -----Original Message-----
> From: Florian Fainelli [mailto:f.fainelli@gmail.com]
> Sent: Sunday, July 23, 2017 5:54 PM
> To: Salil Mehta; davem@davemloft.net
> Cc: Zhuangyuzeng (Yisen); huangdaode; lipeng (Y);
> mehta.salil.lnk@gmail.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; linux-rdma@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH V4 net-next 6/8] net: hns3: Add MDIO support to
> HNS3 Ethernet driver for hip08 SoC
> 
> 
> 
> On 07/22/2017 03:09 PM, Salil Mehta wrote:
> > This patch adds the support of MDIO bus interface for HNS3 driver.
> > Code provides various interfaces to start and stop the PHY layer
> > and to read and write the MDIO bus or PHY.
> >
> > Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
> > Signed-off-by: lipeng <lipeng321@huawei.com>
> > Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
> > Signed-off-by: Yisen Zhuang <yisen.zhuang@huawei.com>
> > ---
> > Patch V4: Addressed following comments:
> >  1. Andrew Lunn:
> >     https://lkml.org/lkml/2017/6/17/208
> > Patch V3: Addressed Below comments:
> >  1. Florian Fainelli:
> >     https://lkml.org/lkml/2017/6/13/963
> >  2. Andrew Lunn:
> >     https://lkml.org/lkml/2017/6/13/1039
> > Patch V2: Addressed below comments:
> >  1. Florian Fainelli:
> >     https://lkml.org/lkml/2017/6/10/130
> >  2. Andrew Lunn:
> >     https://lkml.org/lkml/2017/6/10/168
> > Patch V1: Initial Submit
> > ---
> >  .../ethernet/hisilicon/hns3/hns3pf/hclge_mdio.c    | 230
> +++++++++++++++++++++
> >  1 file changed, 230 insertions(+)
> >  create mode 100644
> drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_mdio.c
> >
> > diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_mdio.c
> b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_mdio.c
> > new file mode 100644
> > index 000000000000..6036a97f7de5
> > --- /dev/null
> > +++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hclge_mdio.c
> > @@ -0,0 +1,230 @@
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
> > +#define HCLGE_MDIO_CTRL_START_B		0
> > +#define HCLGE_MDIO_CTRL_ST_S		1
> > +#define HCLGE_MDIO_CTRL_ST_M		(0x3 << HCLGE_MDIO_CTRL_ST_S)
> > +#define HCLGE_MDIO_CTRL_OP_S		3
> > +#define HCLGE_MDIO_CTRL_OP_M		(0x3 << HCLGE_MDIO_CTRL_OP_S)
> > +
> > +#define HCLGE_MDIO_PHYID_S		0
> > +#define HCLGE_MDIO_PHYID_M		(0x1f << HCLGE_MDIO_PHYID_S)
> > +
> > +#define HCLGE_MDIO_PHYREG_S		0
> > +#define HCLGE_MDIO_PHYREG_M		(0x1f << HCLGE_MDIO_PHYREG_S)
> > +
> > +#define HCLGE_MDIO_STA_B		0
> > +
> > +struct hclge_mdio_cfg_cmd {
> > +	u8 ctrl_bit;
> > +	u8 phyid;
> > +	u8 phyad;
> > +	u8 rsvd;
> > +	__le16 reserve;
> > +	__le16 data_wr;
> > +	__le16 data_rd;
> > +	__le16 sta;
> > +};
> > +
> > +static int hclge_mdio_write(struct mii_bus *bus, int phyid, int
> regnum,
> > +			    u16 data)
> > +{
> > +	struct hclge_dev *hdev = (struct hclge_dev *)bus->priv;
> 
> Cast is not needed here since bus->priv is already a void *.
> 
> > +	struct hclge_mdio_cfg_cmd *mdio_cmd;
> > +	enum hclge_cmd_status status;
> > +	struct hclge_desc desc;
> > +
> > +	if (!bus)
> > +		return -EINVAL;
> 
> How can this be possible?
Agreed, will remove.

> 
> > +
> > +	hclge_cmd_setup_basic_desc(&desc, HCLGE_OPC_MDIO_CONFIG, false);
> > +
> > +	mdio_cmd = (struct hclge_mdio_cfg_cmd *)desc.data;
> 
> Same here, can we not cast this into a struct hclge_mdio_cfg_cmd?
You mean should we assign directly without casting?

> 
> > +
> > +	hnae_set_field(mdio_cmd->phyid, HCLGE_MDIO_PHYID_M,
> > +		       HCLGE_MDIO_PHYID_S, phyid);
> > +	hnae_set_field(mdio_cmd->phyad, HCLGE_MDIO_PHYREG_M,
> > +		       HCLGE_MDIO_PHYREG_S, regnum);
> > +
> > +	hnae_set_bit(mdio_cmd->ctrl_bit, HCLGE_MDIO_CTRL_START_B, 1);
> > +	hnae_set_field(mdio_cmd->ctrl_bit, HCLGE_MDIO_CTRL_ST_M,
> > +		       HCLGE_MDIO_CTRL_ST_S, 1);
> > +	hnae_set_field(mdio_cmd->ctrl_bit, HCLGE_MDIO_CTRL_OP_M,
> > +		       HCLGE_MDIO_CTRL_OP_S, HCLGE_MDIO_C22_WRITE);
> > +
> > +	mdio_cmd->data_wr = cpu_to_le16(data);
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
> > +static int hclge_mdio_read(struct mii_bus *bus, int phyid, int
> regnum)
> > +{
> > +	struct hclge_dev *hdev = (struct hclge_dev *)bus->priv;
> 
> Same here.
No cast required you mean?

> 
> > +	struct hclge_mdio_cfg_cmd *mdio_cmd;
> > +	enum hclge_cmd_status status;
> > +	struct hclge_desc desc;
> > +
> > +	if (!bus)
> > +		return -EINVAL;
> 
> And here.
Ok.

> 
> > +
> > +	hclge_cmd_setup_basic_desc(&desc, HCLGE_OPC_MDIO_CONFIG, true);
> > +
> > +	mdio_cmd = (struct hclge_mdio_cfg_cmd *)desc.data;
> 
> And here.
Ok.

> 
> > +
> > +	hnae_set_field(mdio_cmd->phyid, HCLGE_MDIO_PHYID_M,
> > +		       HCLGE_MDIO_PHYID_S, phyid);
> > +	hnae_set_field(mdio_cmd->phyad, HCLGE_MDIO_PHYREG_M,
> > +		       HCLGE_MDIO_PHYREG_S, regnum);
> > +
> > +	hnae_set_bit(mdio_cmd->ctrl_bit, HCLGE_MDIO_CTRL_START_B, 1);
> > +	hnae_set_field(mdio_cmd->ctrl_bit, HCLGE_MDIO_CTRL_ST_M,
> > +		       HCLGE_MDIO_CTRL_ST_S, 1);
> > +	hnae_set_field(mdio_cmd->ctrl_bit, HCLGE_MDIO_CTRL_OP_M,
> > +		       HCLGE_MDIO_CTRL_OP_S, HCLGE_MDIO_C22_READ);
> > +
> > +	/* Read out phy data */
> > +	status = hclge_cmd_send(&hdev->hw, &desc, 1);
> > +	if (status) {
> > +		dev_err(&hdev->pdev->dev,
> > +			"mdio read fail when get data, status is %d.\n",
> > +			status);
> > +		return status;
> > +	}
> > +
> > +	if (hnae_get_bit(le16_to_cpu(mdio_cmd->sta), HCLGE_MDIO_STA_B)) {
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
> > +	struct phy_device *phydev;
> > +	struct mii_bus *mdio_bus;
> > +	int ret;
> > +
> > +	if (hdev->hw.mac.phy_addr >= PHY_MAX_ADDR)
> > +		return 0;
> 
> Should not this be treated as a hard error instead?
What if SFP is not plugged in and our hardware treats
this as 0xff a special condition? I think we are trying
to detect that condition here.

> 
> > +
> > +	mdio_bus = devm_mdiobus_alloc(&hdev->pdev->dev);
> > +	if (!mdio_bus)
> > +		return -ENOMEM;
> > +
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
> > +		return ret;
> > +	}
> > +
> > +	phydev = mdiobus_get_phy(mdio_bus, mac->phy_addr);
> > +	if (!phydev || IS_ERR(phydev)) {
> > +		dev_err(mdio_bus->parent, "Failed to get phy device\n");
> > +		mdiobus_unregister(mdio_bus);
> > +		return -EIO;
> > +	}
> > +
> > +	mac->phydev = phydev;
> > +	mac->mdio_bus = mdio_bus;
> > +
> > +	return 0;
> > +}
> > +
> > +static void hclge_mac_adjust_link(struct net_device *netdev)
> > +{
> > +	struct hclge_mac *hw_mac;
> > +	struct hclge_dev *hdev;
> > +	struct hclge_hw *hw;
> > +	int duplex;
> > +	int speed;
> > +
> > +	if (!netdev)
> > +		return;
> 
> This should not happen, don't let your drivers register unless the
> net_device object is fully set up.
Agreed. Will remove.

> 
> > +
> > +	hw_mac = container_of(netdev, struct hclge_mac, netdev);
> > +	hw = container_of(hw_mac, struct hclge_hw, mac);
> > +	hdev = hw->back;
> > +
> > +	speed = netdev->phydev->speed;
> > +	duplex = netdev->phydev->duplex;
> > +
> > +	/* update antoneg. */
> > +	hw_mac->autoneg = netdev->phydev->autoneg;
> > +
> > +	if ((hw_mac->speed != speed) || (hw_mac->duplex != duplex))
> > +		(void)hclge_cfg_mac_speed_dup(hdev, speed, !!duplex);
> > +}
> > +
> > +int hclge_mac_start_phy(struct hclge_dev *hdev)
> > +{
> > +	struct hclge_mac *mac = &hdev->hw.mac;
> > +	struct net_device *netdev = &mac->netdev;
> > +	struct phy_device *phydev = mac->phydev;
> > +	int ret;
> > +
> > +	if (!phydev)
> > +		return 0;
> 
> Same thing here, this should not happen.
This is again when SFP is not present phydev will be NULL.

> 
> > +
> > +	phydev->dev_flags = 0;
> 
> This is the default.
Sure, will remove

> 
> > +
> > +	ret = phy_connect_direct(netdev, phydev,
> > +				 hclge_mac_adjust_link,
> > +				 PHY_INTERFACE_MODE_SGMII);
> > +	if (ret) {
> > +		pr_info("phy_connect_direct err");
> > +		return ret;
> > +	}
> > +
> > +	phy_start(phydev);
> > +
> > +	return 0;
> > +}
> > +
> > +void hclge_mac_stop_phy(struct hclge_dev *hdev)
> > +{
> > +	struct hclge_mac *mac = &hdev->hw.mac;
> > +	struct net_device *netdev = &mac->netdev;
> > +	struct phy_device *phydev = netdev->phydev;
> > +
> > +	if (!phydev)
> > +		return;
> 
> You should be symmetrical here, if you could phy_connect() +
> phy_start()
> then you should call phy_stop() + phy_disconnect().
Got it. Will fix it.

Thanks!
> 
> > +
> > +	phy_disconnect(phydev);
> > +}
> >
> 
> --
> Florian
