From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH net-next] net: mvpp2: phylink support
Date: Fri, 22 Sep 2017 12:07:31 +0100
Message-ID: <20170922110731.GG20805@n2100.armlinux.org.uk>
References: <20170921134522.10993-1-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com,
        miquel.raynal@free-electrons.com, nadavh@marvell.com,
        linux-kernel@vger.kernel.org, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170921134522.10993-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 21, 2017 at 03:45:22PM +0200, Antoine Tenart wrote:
> Convert the PPv2 driver to use phylink, which models the MAC to PHY
> link. The phylink support is made such a way the GoP link IRQ can still
> be used: the two modes are incompatible and the GoP link IRQ will be
> used if no PHY is described in the device tree. This is the same
> behaviour as before.

This makes no sense.  The point of phylink is to be able to support SFP
cages, and SFP cages do not have a PHY described in DT.  So, when you
want to use phylink because of SFP, you can't, because if you omit
the PHY the driver avoids using phylink.

> +static void mvpp2_phylink_validate(struct net_device *dev,
> +				   unsigned long *supported,
> +				   struct phylink_link_state *state)
> +{
> +	__ETHTOOL_DECLARE_LINK_MODE_MASK(mask) = { 0, };
> +
> +	phylink_set_port_modes(mask);
> +
> +	phylink_set(mask, Autoneg);
> +	phylink_set(mask, Pause);
> +	phylink_set(mask, Asym_Pause);
> +
> +	phylink_set(mask, 10baseT_Half);
> +	phylink_set(mask, 10baseT_Full);
> +	phylink_set(mask, 100baseT_Half);
> +	phylink_set(mask, 100baseT_Full);
> +	phylink_set(mask, 1000baseT_Half);
> +	phylink_set(mask, 1000baseT_Full);
> +	phylink_set(mask, 1000baseX_Full);
> +	phylink_set(mask, 10000baseKR_Full);
> +
> +	bitmap_and(supported, supported, mask, __ETHTOOL_LINK_MODE_MASK_NBITS);
> +	bitmap_and(state->advertising, state->advertising, mask,
> +		   __ETHTOOL_LINK_MODE_MASK_NBITS);
> +}

I don't think you've understood this despite the comments in the header
file.  What you describe above basically means you don't support any
kind of copper connection at 10G speeds, or any fiber modes at 10G
speeds either.

You need to set 10000baseT_Full for copper, 10000baseSR_Full,
10000baseLR_Full, 10000baseLRM_Full etc for fiber.  Had you looked at
my modifications for Marvell's mvpp2x driver you'd have spotted this...

> +
> +static int mvpp2_phylink_mac_link_state(struct net_device *dev,
> +					struct phylink_link_state *state)
> +{
> +	struct mvpp2_port *port = netdev_priv(dev);
> +	u32 val;
> +
> +	if (!phy_interface_mode_is_rgmii(port->phy_interface) &&
> +	    port->phy_interface != PHY_INTERFACE_MODE_SGMII)
> +		return 0;

You're blocking this for 1000base-X and 10G connections, which is not
correct.  The expectation is that this function returns the current
MAC state irrespective of the interface mode.

> +
> +	val = readl(port->base + MVPP2_GMAC_STATUS0);
> +
> +	state->an_complete = !!(val & MVPP2_GMAC_STATUS0_AN_COMPLETE);
> +	state->link = !!(val & MVPP2_GMAC_STATUS0_LINK_UP);
> +	state->duplex = !!(val & MVPP2_GMAC_STATUS0_FULL_DUPLEX);
> +
> +	if (val & MVPP2_GMAC_STATUS0_GMII_SPEED)
> +		state->speed = SPEED_1000;
> +	else
> +		state->speed = (val & MVPP2_GMAC_STATUS0_MII_SPEED) ?
> +			       SPEED_100 : SPEED_10;
> +
> +	state->pause = 0;
> +	if (val & MVPP2_GMAC_STATUS0_RX_PAUSE)
> +		state->pause |= MLO_PAUSE_RX;
> +	if (val & MVPP2_GMAC_STATUS0_TX_PAUSE)
> +		state->pause |= MLO_PAUSE_TX;
> +
> +	return 1;
> +}
> +
> +static void mvpp2_mac_an_restart(struct net_device *dev)
> +{
> +	struct mvpp2_port *port = netdev_priv(dev);
> +	u32 val;
> +
> +	if (!phy_interface_mode_is_rgmii(port->phy_interface) &&
> +	    port->phy_interface != PHY_INTERFACE_MODE_SGMII)
> +		return;

This prevents AN restart in 1000base-X mode, which is exactly the
mode that you need to do this.  SGMII doesn't care, and RGMII doesn't
have inband AN.

> +
> +	val = readl(port->base + MVPP2_GMAC_AUTONEG_CONFIG);
> +	val |= MVPP2_GMAC_IN_BAND_RESTART_AN;
> +	writel(val, port->base + MVPP2_GMAC_AUTONEG_CONFIG);
> +}
> +
> +static void mvpp2_mac_config(struct net_device *dev, unsigned int mode,
> +			     const struct phylink_link_state *state)
> +{
> +	struct mvpp2_port *port = netdev_priv(dev);
> +	u32 val;
> +
> +	/* disable current port for reconfiguration */
> +	mvpp2_interrupts_disable(port);
> +	netif_carrier_off(port->dev);
> +	mvpp2_port_disable(port);
> +	phy_power_off(port->comphy);
> +
> +	/* comphy reconfiguration */
> +	port->phy_interface = state->interface;
> +	mvpp22_comphy_init(port);
> +
> +	/* gop/mac reconfiguration */
> +	mvpp22_gop_init(port);
> +	mvpp2_port_mii_set(port);
> +
> +	if (!phy_interface_mode_is_rgmii(port->phy_interface) &&
> +	    port->phy_interface != PHY_INTERFACE_MODE_SGMII)
> +		return;

Again, 1000base-X is excluded, which will break it.  You do need
to avoid touching the GMAC for 10G connections however.

> +
> +	val = readl(port->base + MVPP2_GMAC_AUTONEG_CONFIG);
> +	val &= ~(MVPP2_GMAC_CONFIG_MII_SPEED |
> +		 MVPP2_GMAC_CONFIG_GMII_SPEED |
> +		 MVPP2_GMAC_CONFIG_FULL_DUPLEX |
> +		 MVPP2_GMAC_AN_SPEED_EN |
> +		 MVPP2_GMAC_AN_DUPLEX_EN);
> +
> +	if (state->duplex)
> +		val |= MVPP2_GMAC_CONFIG_FULL_DUPLEX;
> +
> +	if (state->speed == SPEED_1000)
> +		val |= MVPP2_GMAC_CONFIG_GMII_SPEED;
> +	else if (state->speed == SPEED_100)
> +		val |= MVPP2_GMAC_CONFIG_MII_SPEED;
> +
> +	writel(val, port->base + MVPP2_GMAC_AUTONEG_CONFIG);

You're assuming that this function only sets the current parameters for
the MAC.  That's incorrect - it also needs to deal with autonegotiation
for inband AN, such as SGMII and 1000base-X.

> +
> +	if (port->priv->hw_version == MVPP21 && port->flags & MVPP2_F_LOOPBACK)
> +		mvpp2_port_loopback_set(port, state);
> +}
> +
> +static void mvpp2_mac_link_down(struct net_device *dev, unsigned int mode)
> +{
> +	struct mvpp2_port *port = netdev_priv(dev);
> +	u32 val;
> +
> +	netif_tx_stop_all_queues(dev);
> +	netif_carrier_off(dev);
> +	mvpp2_ingress_disable(port);
> +	mvpp2_egress_disable(port);
> +
> +	mvpp2_port_disable(port);
> +	mvpp2_interrupts_disable(port);
> +
> +	if (!phylink_autoneg_inband(mode)) {
> +		val = readl(port->base + MVPP2_GMAC_AUTONEG_CONFIG);
> +		val &= ~MVPP2_GMAC_FORCE_LINK_PASS;
> +		val |= MVPP2_GMAC_FORCE_LINK_DOWN;
> +		writel(val, port->base + MVPP2_GMAC_AUTONEG_CONFIG);
> +	}

Please explain why you think its necessary to force the link down when
the link is already down - if there's no media connected, we only
need to stop the ingress and egress.

It's certainly wrong to disable interrupts - how do we end up with
link status changes reported from the MAC to phylink if interrupts
have been disabled?

phylink in the presence of a PHY checks that both the PHY _and_ MAC
are reporting link before it calls mac_link_up(), so if you've
disabled interrupts...


You guys know that I have working example code for both mvneta and the
Marvell PP2x driver.  It probably would help if you looked at those
examples.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up
