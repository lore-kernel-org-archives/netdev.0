From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/3] net: ethernet: socionext: add AVE ethernet
 driver
Date: Fri, 8 Sep 2017 15:50:30 +0200
Message-ID: <20170908135030.GA25219@lunn.ch>
References: <1504875731-3680-1-git-send-email-hayashi.kunihiko@socionext.com>
 <1504875731-3680-3-git-send-email-hayashi.kunihiko@socionext.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        devicetree@vger.kernel.org,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Masami Hiramatsu <masami.hiramatsu@linaro.org>,
        Jassi Brar <jaswinder.singh@linaro.org>
To: Kunihiko Hayashi <hayashi.kunihiko@socionext.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:32971 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751780AbdIHNuj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 8 Sep 2017 09:50:39 -0400
Content-Disposition: inline
In-Reply-To: <1504875731-3680-3-git-send-email-hayashi.kunihiko@socionext.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static int ave_mdio_busywait(struct net_device *ndev)
> +{
> +	int ret = 1, loop = 100;
> +	u32 mdiosr;
> +
> +	/* wait until completion */
> +	while (1) {
> +		mdiosr = ave_r32(ndev, AVE_MDIOSR);
> +		if (!(mdiosr & AVE_MDIOSR_STS))
> +			break;
> +
> +		usleep_range(10, 20);
> +		if (!loop--) {
> +			netdev_err(ndev,
> +				   "failed to read from MDIO (status:0x%08x)\n",
> +				   mdiosr);
> +			ret = 0;

ETIMEDOUT would be better.

> +			break;
> +		}
> +	}
> +
> +	return ret;

and then return 0 on success. That is the normal convention for return
values. An error code, and 0.

> +static int ave_mdiobus_write(struct mii_bus *bus,
> +			     int phyid, int regnum, u16 val)
> +{
> +	struct net_device *ndev = bus->priv;
> +	u32 mdioctl;
> +
> +	/* write address */
> +	ave_w32(ndev, AVE_MDIOAR, (phyid << 8) | regnum);
> +
> +	/* write data */
> +	ave_w32(ndev, AVE_MDIOWDR, val);
> +
> +	/* write request */
> +	mdioctl = ave_r32(ndev, AVE_MDIOCTR);
> +	ave_w32(ndev, AVE_MDIOCTR, mdioctl | AVE_MDIOCTR_WREQ);
> +
> +	if (!ave_mdio_busywait(ndev)) {
> +		netdev_err(ndev, "phy-%d reg-%x write failed\n",
> +			   phyid, regnum);
> +		return -1;

If ave_mdio_busywait() returns ETIMEDOUT, you can just return
it. Returning -1 is not good.

> +	}
> +
> +	return 0;
> +}
> +
> +static irqreturn_t ave_interrupt(int irq, void *netdev)
> +{
> +	struct net_device *ndev = (struct net_device *)netdev;
> +	struct ave_private *priv = netdev_priv(ndev);
> +	u32 gimr_val, gisr_val;
> +
> +	gimr_val = ave_irq_disable_all(ndev);
> +
> +	/* get interrupt status */
> +	gisr_val = ave_r32(ndev, AVE_GISR);
> +
> +	/* PHY */
> +	if (gisr_val & AVE_GI_PHY) {
> +		ave_w32(ndev, AVE_GISR, AVE_GI_PHY);
> +		if (priv->internal_phy_interrupt)
> +			phy_mac_interrupt(ndev->phydev, ndev->phydev->link);

Humm. I don't think this is correct. You are supposed to give it the
new link state, not the old.

What does a PHY interrupt mean here? 

> +static void ave_adjust_link(struct net_device *ndev)
> +{
> +	struct ave_private *priv = netdev_priv(ndev);
> +	struct phy_device *phydev = ndev->phydev;
> +	u32 val, txcr, rxcr, rxcr_org;
> +
> +	/* set RGMII speed */
> +	val = ave_r32(ndev, AVE_TXCR);
> +	val &= ~(AVE_TXCR_TXSPD_100 | AVE_TXCR_TXSPD_1G);
> +
> +	if (priv->phy_mode == PHY_INTERFACE_MODE_RGMII &&
> +	    phydev->speed == SPEED_1000)

phy_interface_mode_is_rgmii(), so that you handle all the RGMII modes.

> +		val |= AVE_TXCR_TXSPD_1G;
> +	else if (phydev->speed == SPEED_100)
> +		val |= AVE_TXCR_TXSPD_100;
> +
> +	ave_w32(ndev, AVE_TXCR, val);
> +
> +	/* set RMII speed (100M/10M only) */
> +	if (priv->phy_mode != PHY_INTERFACE_MODE_RGMII) {

Not so safe. It would be better to check for the modes you actually
support.

> +	if (phydev->link)
> +		netif_carrier_on(ndev);
> +	else
> +		netif_carrier_off(ndev);

I don't think you need this. The phylib should do it for you.

> +
> +	phy_print_status(phydev);
> +}
> +
> +static int ave_init(struct net_device *ndev)
> +{
> +	struct ave_private *priv = netdev_priv(ndev);
> +	struct device *dev = ndev->dev.parent;
> +	struct device_node *phy_node, *np = dev->of_node;
> +	struct phy_device *phydev;
> +	const void *mac_addr;
> +	u32 supported;
> +
> +	/* get mac address */
> +	mac_addr = of_get_mac_address(np);
> +	if (mac_addr)
> +		ether_addr_copy(ndev->dev_addr, mac_addr);
> +
> +	/* if the mac address is invalid, use random mac address */
> +	if (!is_valid_ether_addr(ndev->dev_addr)) {
> +		eth_hw_addr_random(ndev);
> +		dev_warn(dev, "Using random MAC address: %pM\n",
> +			 ndev->dev_addr);
> +	}
> +
> +	/* attach PHY with MAC */
> +	phy_node =  of_get_next_available_child(np, NULL);

???

Should this not be looking for a phy-handle property?
Documentation/devicetree/binds/net/ethernet.txt:

- phy-handle: phandle, specifies a reference to a node representing a PHY
  device; this property is described in the Devicetree Specification and so
  preferred;


> +	phydev = of_phy_connect(ndev, phy_node,
> +				ave_adjust_link, 0, priv->phy_mode);
> +	if (!phydev) {
> +		dev_err(dev, "could not attach to PHY\n");
> +		return -ENODEV;
> +	}
> +	of_node_put(phy_node);
> +
> +	priv->phydev = phydev;
> +	phydev->autoneg = AUTONEG_ENABLE;
> +	phydev->speed = 0;
> +	phydev->duplex = 0;

And this should not be needed.

> +
> +	dev_info(dev, "connected to %s phy with id 0x%x\n",
> +		 phydev->drv->name, phydev->phy_id);

phy_attached_info()

> +
> +	if (priv->phy_mode != PHY_INTERFACE_MODE_RGMII) {

Same comment as above.

> +		supported = phydev->supported;
> +		phydev->supported &= ~PHY_GBIT_FEATURES;
> +		phydev->supported |= supported & PHY_BASIC_FEATURES;
> +	}
> +
> +	/* PHY interrupt stop instruction is needed because the interrupt
> +	 * continues to assert.
> +	 */
> +	phy_stop_interrupts(phydev);

Could you explain this some more? It sounds like your interrupt
controller is broken.

> +
> +	/* When PHY driver can't handle its interrupt directly,
> +	 * interrupt request always fails and polling method is used
> +	 * alternatively. In this case, the libphy says
> +	 * "libphy: uniphier-mdio: Can't get IRQ -1 (PHY)".
> +	 */
> +	phy_start_interrupts(phydev);

-1 is PHY_POLL. So calling phy_start_interrupts() is wrong. In fact,
you should not be calling phy_start_interrupts() at all. No other
Ethernet driver does.

> +
> +	phy_start_aneg(phydev);
> +
> +	return 0;
> +}
> +
> +static void ave_uninit(struct net_device *ndev)
> +{
> +	struct ave_private *priv = netdev_priv(ndev);
> +
> +	phy_stop_interrupts(priv->phydev);

And no other Ethernet driver calls phy_stop_interrupts either.
Please take a look at this.

> +	phy_disconnect(priv->phydev);
> +}
> +

  Andrew
