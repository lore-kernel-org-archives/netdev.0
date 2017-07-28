From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH V5 net-next 6/8] net: hns3: Add MDIO support to HNS3
 Ethernet driver for hip08 SoC
Date: Sat, 29 Jul 2017 01:24:28 +0200
Message-ID: <20170728232428.GA16080@lunn.ch>
References: <20170728222652.118448-1-salil.mehta@huawei.com>
 <20170728222652.118448-7-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, yisen.zhuang@huawei.com,
        huangdaode@hisilicon.com, lipeng321@huawei.com,
        mehta.salil.lnk@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-rdma@vger.kernel.org,
        linuxarm@huawei.com
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170728222652.118448-7-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +static void hclge_mac_adjust_link(struct net_device *netdev)
> +{
> +	struct hnae3_handle *h = *((void **)netdev_priv(netdev));
> +	struct hclge_vport *vport = hclge_get_vport(h);
> +	struct hclge_dev *hdev = vport->back;
> +	int duplex, speed;
> +	int ret;
> +
> +	speed = netdev->phydev->speed;
> +	duplex = netdev->phydev->duplex;
> +
> +	ret = hclge_cfg_mac_speed_dup(hdev, speed, duplex);
> +	if (ret)
> +		dev_err(&hdev->pdev->dev, "adjust link fail.\n");

Here and hclge_mac_start_phy() you have a netdev, so you should be
using netdev_err()

> +}
> +
> +int hclge_mac_start_phy(struct hclge_dev *hdev)
> +{
> +	struct net_device *netdev = hdev->vport[0].nic.netdev;
> +	struct phy_device *phydev = hdev->hw.mac.phydev;
> +	int ret;
> +
> +	if (!phydev)
> +		return 0;
> +
> +	ret = phy_connect_direct(netdev, phydev,
> +				 hclge_mac_adjust_link,
> +				 PHY_INTERFACE_MODE_SGMII);
> +	if (ret) {
> +		pr_info("phy_connect_direct err");
> +		return ret;

netdev_err(). checkpatch probably gave you a warning about this?

> +	}
> +
> +	phy_start(phydev);
> +
> +	return 0;
> +}
> +
> +void hclge_mac_stop_phy(struct hclge_dev *hdev)
> +{
> +	struct net_device *netdev = hdev->vport[0].nic.netdev;
> +	struct phy_device *phydev = netdev->phydev;
> +
> +	phy_stop(phydev);
> +	phy_disconnect(phydev);
> +}

In hclge_mac_start_phy() you check for !phydev. Here you
unconditionally use phydev. Seems inconsistent.

	Andrew
