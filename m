From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 4/8] net: ethernet: add the Alpine Ethernet
 driver
Date: Fri, 3 Feb 2017 21:58:23 +0100
Message-ID: <20170203205823.GA22572@lunn.ch>
References: <20170203181216.30214-1-antoine.tenart@free-electrons.com>
 <20170203181216.30214-5-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        linux-arm-kernel@lists.infradead.org, tsahee@annapurnalabs.com,
        rshitrit@annapurnalabs.com, saeed@annapurnalabs.com,
        barak@annapurnalabs.com, talz@annapurnalabs.com,
        thomas.petazzoni@free-electrons.com, arnd@arndb.de
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55257 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752276AbdBCU62 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 15:58:28 -0500
Content-Disposition: inline
In-Reply-To: <20170203181216.30214-5-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +/* MDIO */
> +#define AL_ETH_MDIO_C45_DEV_MASK	0x1f0000
> +#define AL_ETH_MDIO_C45_DEV_SHIFT	16
> +#define AL_ETH_MDIO_C45_REG_MASK	0xffff
> +
> +static int al_mdio_read(struct mii_bus *bp, int mii_id, int reg)
> +{
> +	struct al_eth_adapter *adapter = bp->priv;
> +	u16 value = 0;
> +	int rc;
> +	int timeout = MDIO_TIMEOUT_MSEC;
> +
> +	while (timeout > 0) {
> +		if (reg & MII_ADDR_C45) {
> +			netdev_dbg(adapter->netdev, "[c45]: dev %x reg %x val %x\n",
> +				   ((reg & AL_ETH_MDIO_C45_DEV_MASK) >> AL_ETH_MDIO_C45_DEV_SHIFT),
> +				   (reg & AL_ETH_MDIO_C45_REG_MASK), value);
> +			rc = al_eth_mdio_read(&adapter->hw_adapter, adapter->phy_addr,
> +				((reg & AL_ETH_MDIO_C45_DEV_MASK) >> AL_ETH_MDIO_C45_DEV_SHIFT),
> +				(reg & AL_ETH_MDIO_C45_REG_MASK), &value);
> +		} else {
> +			rc = al_eth_mdio_read(&adapter->hw_adapter, adapter->phy_addr,
> +					      MDIO_DEVAD_NONE, reg, &value);
> +		}
> +
> +		if (rc == 0)
> +			return value;
> +
> +		netdev_dbg(adapter->netdev,
> +			   "mdio read failed. try again in 10 msec\n");
> +
> +		timeout -= 10;
> +		msleep(10);
> +	}

This is rather unusual, retrying MDIO operations. Are you working
around a hardware bug? I suspect this also opens up race conditions,
in particular with PHY interrupts, which can be clear on read.

> +
> +static int al_eth_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
> +{
> +	struct al_eth_adapter *adapter = netdev_priv(netdev);
> +	struct mii_ioctl_data *mdio = if_mii(ifr);
> +	struct phy_device *phydev;
> +
> +	netdev_info(adapter->netdev, "ioctl: phy id 0x%x, reg 0x%x, val_in 0x%x\n",
> +		    mdio->phy_id, mdio->reg_num, mdio->val_in);

netdev_info() for an ioctl?

> +static int al_eth_flow_ctrl_config(struct al_eth_adapter *adapter);
> +static u8 al_eth_flow_ctrl_mutual_cap_get(struct al_eth_adapter *adapter);
> +static void al_eth_down(struct al_eth_adapter *adapter);
> +static int al_eth_up(struct al_eth_adapter *adapter);

Forward declarations are generally not liked. Can you move the code
around to remove them?

> +
> +static void al_eth_adjust_link(struct net_device *dev)
> +{
> +	struct al_eth_adapter *adapter = netdev_priv(dev);
> +	struct al_eth_link_config *link_config = &adapter->link_config;
> +	struct phy_device *phydev = adapter->phydev;
> +	enum al_eth_mac_mode mac_mode_needed = AL_ETH_MAC_MODE_RGMII;
> +	int new_state = 0;
> +	bool force_1000_base_x = false;
> +
> +	if (phydev->link) {
> +		if (phydev->duplex != link_config->active_duplex) {
> +			new_state = 1;
> +			link_config->active_duplex = phydev->duplex;
> +		}
> +
> +		if (phydev->speed != link_config->active_speed) {
> +			new_state = 1;
> +			switch (phydev->speed) {
> +			case SPEED_1000:
> +			case SPEED_100:
> +			case SPEED_10:
> +				mac_mode_needed = (adapter->mac_mode == AL_ETH_MAC_MODE_RGMII) ?
> +					AL_ETH_MAC_MODE_RGMII : AL_ETH_MAC_MODE_SGMII;
> +				break;
> +			case SPEED_10000:
> +			case SPEED_2500:
> +				mac_mode_needed = AL_ETH_MAC_MODE_10GbE_Serial;
> +				break;
> +			default:
> +				if (netif_msg_link(adapter))
> +					netdev_warn(adapter->netdev,
> +						    "Ack!  Speed (%d) is not 10/100/1000!",

Not particularly accurate, since 2.5G and 10G is supported.

> +						    phydev->speed);
> +static int al_eth_phy_init(struct al_eth_adapter *adapter)
> +{
> +	struct phy_device *phydev = mdiobus_get_phy(adapter->mdio_bus, adapter->phy_addr);
> +
> +	adapter->link_config.old_link = 0;
> +	adapter->link_config.active_duplex = DUPLEX_UNKNOWN;
> +	adapter->link_config.active_speed = SPEED_UNKNOWN;
> +
> +	/* Attach the MAC to the PHY. */
> +	phydev = phy_connect(adapter->netdev, dev_name(&phydev->mdio.dev), al_eth_adjust_link,
> +			     PHY_INTERFACE_MODE_RGMII);
> +	if (IS_ERR(phydev)) {
> +		netdev_err(adapter->netdev, "Could not attach to PHY\n");
> +		return PTR_ERR(phydev);
> +	}
> +
> +	netdev_info(adapter->netdev, "phy[%d]: device %s, driver %s\n",
> +		    phydev->mdio.addr, dev_name(&phydev->mdio.dev),
> +		    phydev->drv ? phydev->drv->name : "unknown");
> +

phy_attached_info()?

> +	/* Mask with MAC supported features. */
> +	phydev->supported &= (PHY_GBIT_FEATURES |
> +				SUPPORTED_Pause |
> +				SUPPORTED_Asym_Pause);
> +
> +	phydev->advertising = phydev->supported;
> +
> +	netdev_info(adapter->netdev, "phy[%d]:supported %x adv %x\n",
> +		    phydev->mdio.addr, phydev->supported, phydev->advertising);
> +

More output?

> +	adapter->phydev = phydev;
> +	/* Bring the PHY up */
> +	phy_start(adapter->phydev);

This is normally done in the open() call.

> +/* al_eth_mdiobus_setup - initialize mdiobus and register to kernel */
> +static int al_eth_mdiobus_setup(struct al_eth_adapter *adapter)
> +{
> +	struct phy_device *phydev;
> +	int i;
> +	int ret = 0;
> +
> +	adapter->mdio_bus = mdiobus_alloc();
> +	if (!adapter->mdio_bus)
> +		return -ENOMEM;
> +
> +	adapter->mdio_bus->name     = "al mdio bus";
> +	snprintf(adapter->mdio_bus->id, MII_BUS_ID_SIZE, "%x",
> +		 (adapter->pdev->bus->number << 8) | adapter->pdev->devfn);
> +	adapter->mdio_bus->priv     = adapter;
> +	adapter->mdio_bus->parent   = &adapter->pdev->dev;
> +	adapter->mdio_bus->read     = &al_mdio_read;
> +	adapter->mdio_bus->write    = &al_mdio_write;
> +	adapter->mdio_bus->phy_mask = ~BIT(adapter->phy_addr);

Why do this?


> +	for (i = 0; i < PHY_MAX_ADDR; i++)
> +		adapter->mdio_bus->irq[i] = PHY_POLL;

Not needed. The core will do this.

> +
> +	if (adapter->phy_if != AL_ETH_BOARD_PHY_IF_XMDIO) {
> +		i = mdiobus_register(adapter->mdio_bus);
> +		if (i) {
> +			netdev_warn(adapter->netdev,
> +				    "mdiobus_reg failed (0x%x)\n", i);
> +			mdiobus_free(adapter->mdio_bus);
> +			return i;
> +		}
> +
> +		phydev = mdiobus_get_phy(adapter->mdio_bus, adapter->phy_addr);
> +	} else {
> +		adapter->mdio_bus->phy_mask = 0xffffffff;
> +		i = mdiobus_register(adapter->mdio_bus);
> +		if (i) {
> +			netdev_warn(adapter->netdev,
> +				    "mdiobus_reg failed (0x%x)\n", i);
> +			mdiobus_free(adapter->mdio_bus);
> +			return i;
> +		}
> +
> +		phydev = get_phy_device(adapter->mdio_bus, adapter->phy_addr,
> +					true);
> +		if (!phydev) {
> +			netdev_err(adapter->netdev, "phy device get failed\n");
> +			goto error;
> +		}
> +
> +		ret = phy_device_register(phydev);
> +		if (ret) {
> +			netdev_err(adapter->netdev,
> +				   "phy device register failed\n");
> +			goto error;
> +		}
> +	}

It seems like this should be split up into two. One function to
register the MDIO bus, and a second to handle the PHY on the mdio bus.

> +
> +	if (!phydev || !phydev->drv)
> +		goto error;
> +
> +	return 0;
> +
> +error:
> +	netdev_warn(adapter->netdev, "No PHY devices\n");

Yet more warnings....

> +	mdiobus_unregister(adapter->mdio_bus);
> +	mdiobus_free(adapter->mdio_bus);
> +	return -ENODEV;
> +}
> +
> +/* al_eth_mdiobus_teardown - mdiobus unregister */
> +static void al_eth_mdiobus_teardown(struct al_eth_adapter *adapter)
> +{
> +	if (!adapter->mdio_bus)
> +		return;
> +
> +	mdiobus_unregister(adapter->mdio_bus);
> +	mdiobus_free(adapter->mdio_bus);
> +	phy_device_free(adapter->phydev);

Humm, you might want to think about the ordering here.

> +}
> +
> +static void al_eth_tx_timeout(struct net_device *dev)
> +{
> +	struct al_eth_adapter *adapter = netdev_priv(dev);
> +
> +	if (netif_msg_tx_err(adapter))
> +		netdev_err(dev, "transmit timed out!!!!\n");
> +}
> +
> +static int al_eth_change_mtu(struct net_device *dev, int new_mtu)
> +{
> +	struct al_eth_adapter *adapter = netdev_priv(dev);
> +	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
> +
> +	if ((new_mtu < AL_ETH_MIN_FRAME_LEN) || (new_mtu > AL_ETH_MAX_MTU) ||
> +	    (max_frame > AL_ETH_MAX_FRAME_LEN)) {
> +		netdev_err(dev, "Invalid MTU setting\n");
> +		return -EINVAL;
> +	}

The core will do this check for you, if you tell it to.

> +		switch (params.speed) {
> +		default:
> +			dev_warn(&adapter->pdev->dev,
> +				 "invalid speed (%d)\n", params.speed);

It is a bit unusual having the default first. And that leads me to a C
question. Can it fall through into the next case statement if there is no break?

> +static int al_eth_nway_reset(struct net_device *netdev)
> +{
> +	struct al_eth_adapter *adapter = netdev_priv(netdev);
> +	struct phy_device *phydev = adapter->phydev;
> +
> +	if (!phydev)
> +		return -ENODEV;
> +
> +	return phy_start_aneg(phydev);
> +}

phy_ethtool_nway_reset() should be used.

> +static int al_eth_set_mac_addr(struct net_device *dev, void *p)
> +{
> +	struct al_eth_adapter *adapter = netdev_priv(dev);
> +	struct sockaddr *addr = p;
> +	int err = 0;
> +
> +	if (!is_valid_ether_addr(addr->sa_data))
> +		return -EADDRNOTAVAIL;

Seems like the core should be doing that for you. Not checked though.
If it does not, i suggest you do add it to the core.

> +static void al_eth_mdio_1g_mac_read(struct al_hw_eth_adapter *adapter,
> +				    u32 phy_addr, u32 reg, u16 *val)
> +{
> +	*val = readl(&adapter->mac_regs_base->mac_1g.phy_regs_base + reg);
> +}
> +
> +static void al_eth_mdio_1g_mac_write(struct al_hw_eth_adapter *adapter,
> +				     u32 phy_addr, u32 reg, u16 val)
> +{
> +	writel(val, &adapter->mac_regs_base->mac_1g.phy_regs_base + reg);
> +}

Are there range checks made on reg before these functions are called?
Just thinking about SIOCSMIIREG ioctl.

> +
> +static int al_eth_mdio_10g_mac_wait_busy(struct al_hw_eth_adapter *adapter)
> +{
> +	int count = 0;
> +	u32 mdio_cfg_status;
> +
> +	do {
> +		mdio_cfg_status = readl(&adapter->mac_regs_base->mac_10g.mdio_cfg_status);
> +		if (mdio_cfg_status & BIT(0)) {

Would be nice to have a #define for this 0 bit, and it seems bit 1 is an error?

> +			if (count > 0)
> +				netdev_dbg(adapter->netdev,
> +					   "eth [%s] mdio: still busy!\n",
> +					   adapter->name);
> +		} else {
> +			return 0;
> +		}
> +		udelay(AL_ETH_MDIO_DELAY_PERIOD);
> +	} while (count++ < AL_ETH_MDIO_DELAY_COUNT);
> +
> +	return -ETIMEDOUT;
> +}
> +
> +static int al_eth_mdio_10g_mac_type22(struct al_hw_eth_adapter *adapter,
> +				      int read, u32 phy_addr, u32 reg, u16 *val)
> +{
> +	int rc;
> +	const char *op = (read == 1) ? "read" : "write";
> +	u32 mdio_cfg_status;
> +	u16 mdio_cmd;
> +
> +	/* wait if the HW is busy */
> +	rc = al_eth_mdio_10g_mac_wait_busy(adapter);
> +	if (rc) {
> +		netdev_err(adapter->netdev,
> +			   " eth [%s] mdio %s failed. HW is busy\n",
> +			   adapter->name, op);

How about moving this netdev_err() inside
al_eth_mdio_10g_mac_wait_busy() so you only need it once?

> +		return rc;
> +	}
> +
> +	mdio_cmd = (u16)(0x1F & reg);
> +	mdio_cmd |= (0x1F & phy_addr) << 5;
> +
> +	if (read)
> +		mdio_cmd |= BIT(15); /* READ command */

Another #define please.

> + * acquire mdio interface ownership
> + * when mdio interface shared between multiple eth controllers, this function waits until the ownership granted for this controller.
> + * this function does nothing when the mdio interface is used only by this controller.
> + *
> + * @param adapter
> + * @return 0 on success, -ETIMEDOUT  on timeout.
> + */
> +static int al_eth_mdio_lock(struct al_hw_eth_adapter *adapter)
> +{
> +	int count = 0;
> +	u32 mdio_ctrl_1;
> +
> +	if (!adapter->shared_mdio_if)
> +		return 0; /* nothing to do when interface is not shared */
> +
> +	do {
> +		mdio_ctrl_1 = readl(&adapter->mac_regs_base->gen.mdio_ctrl_1);
> +		if (mdio_ctrl_1 & BIT(0)) {
> +			if (count > 0)
> +				netdev_dbg(adapter->netdev,
> +					   "eth %s mdio interface still busy!\n",
> +					   adapter->name);
> +		} else {
> +			return 0;
> +		}
> +		udelay(AL_ETH_MDIO_DELAY_PERIOD);
> +	} while (count++ < (AL_ETH_MDIO_DELAY_COUNT * 4));

This needs explaining. How can a read alone perform a lock? How is
this race free? 

> +		if (adapter->mdio_type == AL_ETH_MDIO_TYPE_CLAUSE_22)
> +			rc = al_eth_mdio_10g_mac_type22(adapter, 1, phy_addr,
> +							reg, val);
> +		else
> +			rc = al_eth_mdio_10g_mac_type45(adapter, 1, phy_addr,
> +							device, reg, val);

This seems odd. My understanding is that the device on the MDIO bus,
the PHY, is either c22 or c45. The PHY driver will tell you this, not
the adaptor.

    Andrew
