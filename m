From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH V2 net-next 6/8] net: hns3: Add MDIO support to HNS3
 Ethernet driver for hip08 SoC
Date: Tue, 13 Jun 2017 16:46:16 -0700
Message-ID: <cc35a067-3395-7653-e2c7-46c60644f0ad@gmail.com>
References: <20170613231035.494020-1-salil.mehta@huawei.com>
 <20170613231035.494020-7-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, huangdaode@hisilicon.com,
        lipeng321@huawei.com, mehta.salil.lnk@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linuxarm@huawei.com
To: Salil Mehta <salil.mehta@huawei.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170613231035.494020-7-salil.mehta@huawei.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/13/2017 04:10 PM, Salil Mehta wrote:
> This patch adds the support of MDIO bus interface for HNS3 driver.
> Code provides various interfaces to start and stop the PHY layer
> and to read and write the MDIO bus or PHY.
> 
> Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
> Signed-off-by: lipeng <lipeng321@huawei.com>
> Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
> Signed-off-by: Yisen Zhuang <yisen.zhuang@huawei.com>
> ---

> +	phy = get_phy_device(mdio_bus, mac->phy_addr, mac->is_c45);
> +	if (!phy || IS_ERR(phy)) {
> +		dev_err(mdio_bus->parent, "Failed to get phy device\n");
> +		ret = -EIO;
> +		goto err_mdio_register;
> +	}
> +
> +	phy->irq = mdio_bus->irq[mac->phy_addr];
> +
> +	/* All data is now stored in the phy struct;
> +	 * register it
> +	 */
> +	ret = phy_device_register(phy);
> +	if (ret) {
> +		ret = -ENODEV;
> +		goto err_phy_register;
> +	}

Until this gets fixed in the core PHY library, it's okay to do that, but
please fix the

> +
> +	mac->phy_dev = phy;
> +
> +	return 0;
> +
> +err_phy_register:
> +	phy_device_free(phy);
> +
> +err_mdio_register:
> +	mdiobus_unregister(mdio_bus);
> +	mdiobus_free(mdio_bus);
> +err_miibus_alloc:
> +	return ret;
> +}
> +
> +static void hclge_mac_adjust_link(struct net_device *net_dev)
> +{
> +	int duplex;
> +	int speed;
> +	struct hclge_mac *hw_mac;
> +	struct hclge_hw *hw;
> +	struct hclge_dev *hdev;
> +
> +	if (!net_dev)
> +		return;
> +
> +	hw_mac = container_of(net_dev, struct hclge_mac, ndev);
> +	hw = container_of(hw_mac, struct hclge_hw, mac);
> +	hdev = hw->back;
> +
> +	speed = hw_mac->phy_dev->speed;
> +	duplex = hw_mac->phy_dev->duplex;
> +
> +	/* update antoneg. */
> +	hw_mac->autoneg = hw_mac->phy_dev->autoneg;
> +
> +	if ((hw_mac->speed != speed) || (hw_mac->duplex != duplex))
> +		(void)hclge_cfg_mac_speed_dup(hdev, speed, !!duplex);
> +}
> +
> +int hclge_mac_start_phy(struct hclge_dev *hdev)
> +{
> +	struct hclge_mac *mac = &hdev->hw.mac;
> +	struct phy_device *phy_dev = mac->phy_dev;
> +	int ret;
> +
> +	if (!phy_dev)
> +		return 0;
> +
> +	if (mac->phy_if != PHY_INTERFACE_MODE_XGMII) {
> +		phy_dev->dev_flags = 0;
> +
> +		ret = phy_connect_direct(&mac->ndev, phy_dev,
> +					 hclge_mac_adjust_link,
> +					 mac->phy_if);
> +		phy_dev->supported = SUPPORTED_10baseT_Half |
> +				SUPPORTED_10baseT_Full |
> +				SUPPORTED_100baseT_Half |
> +				SUPPORTED_100baseT_Full |
> +				SUPPORTED_Autoneg |
> +				SUPPORTED_1000baseT_Full;
> +
> +		phy_dev->autoneg = false;
> +	} else {
> +		ret = phy_attach_direct(&mac->ndev, phy_dev, 0, mac->phy_if);
> +		phy_dev->supported = SUPPORTED_10000baseR_FEC |
> +				SUPPORTED_10000baseKR_Full;
> +	}

I really don't see why you don't take the exact same path whether it's
XGMII or not, just like you are not masking with that the PHY driver
already supports, this needs fixing.

> +	if (unlikely(ret))
> +		return -ENODEV;
> +
> +	phy_start(phy_dev);
> +
> +	return 0;
> +}
> +
> +void hclge_mac_stop_phy(struct hclge_dev *hdev)
> +{
> +	struct hclge_mac *mac = &hdev->hw.mac;
> +	struct phy_device *phy_dev = mac->phy_dev;
> +
> +	if (!phy_dev)
> +		return;
> +
> +	phy_stop(phy_dev);
> +
> +	if (mac->phy_if != PHY_INTERFACE_MODE_XGMII)
> +		phy_disconnect(phy_dev);
> +	else
> +		phy_detach(phy_dev);

Same here.
-- 
Florian
