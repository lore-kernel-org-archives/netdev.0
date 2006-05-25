From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 9/9] Resending NetXen 1G/10G NIC driver patch
Date: Thu, 25 May 2006 10:19:33 -0700
Message-ID: <20060525101933.53426bd7@dxpl.pdx.osdl.net>
References: <Pine.LNX.4.33.0605250357330.5844-100000@unmsrvr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sanjeev@netxen.com, unmproj@linsyssoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:50592 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030239AbWEYRTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 13:19:44 -0400
To: "Linsys Contractor Amit S. Kale" <amitkale@unminc.com>
In-Reply-To: <Pine.LNX.4.33.0605250357330.5844-100000@unmsrvr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> +void netxen_delay(int value)
> +{
> +	unsigned long remainder;
> +
> +	remainder = value / 50000;
> +	do {
> +		if (remainder > 1000) {
> +			udelay(1000);
> +			remainder -= 1000;
> +		} else {
> +			udelay(remainder + 1);
> +			remainder = 0;
> +		}
> +	} while (remainder > 0);
> +}
> +


Defined, but never used.  Why not just use mdelay if you
really are waiting that long?

+
+
+/** 
+ * netxen_niu_gbe_set_mii_mode- Set 10/100 Mbit Mode for GbE MAC
+ *
+ **/
+void netxen_niu_gbe_set_mii_mode(struct netxen_adapter *adapter,
+				 long port, long enable)
+{
+	netxen_crb_writelit_adapter(adapter, NETXEN_NIU_MODE, 0x2);
+	netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
+				    0x80000000);
+	netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
+				    0x0000f0025);
+	netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB_MAC_CONFIG_1(port),
+				    0xf1ff);
+	netxen_crb_writelit_adapter(adapter,
+				    NETXEN_NIU_GB0_GMII_MODE + (port << 3), 0);
+	netxen_crb_writelit_adapter(adapter,
+				    NETXEN_NIU_GB0_MII_MODE + (port << 3), 1);
+	netxen_crb_writelit_adapter(adapter,
+				    (NETXEN_NIU_GB0_HALF_DUPLEX + port * 4), 0);
+	netxen_crb_writelit_adapter(adapter,
+				    NETXEN_NIU_GB_MII_MGMT_CONFIG(port), 0x7);
+
+	if (enable) {
+		/* 
+		 * Do NOT enable flow control until a suitable solution for 
+		 *  shutting down pause frames is found. 
+		 */
+		netxen_crb_writelit_adapter(adapter,
+					    NETXEN_NIU_GB_MAC_CONFIG_0(port),
+					    0x5);
+	}
+
>
> +	if (netxen_niu_gbe_enable_phy_interrupts(adapter, port))
> +		printk("<1>ERROR enabling PHY interrupts\n");

Please use KERN_ERR not <1>

> +	if (netxen_niu_gbe_clear_phy_interrupts(adapter, port))
> +		printk("<1>ERROR clearing PHY interrupts\n");
> +}
> +
> +long netxen_niu_gbe_init_port(struct netxen_adapter *adapter, long port)
> +{
> +	long result = 0;
> +	struct netxen_niu_phy_status status;
> +
> +	if (0 ==
> +	    netxen_niu_gbe_phy_read(adapter, port,
> +				    NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
> +				    (netxen_crbword_t *) & status)) {

You seem to like the style:
	if (0 == foo())
It is not the current kernel fashion, but I'm okay with it.

> +		if (status.link) {
> +			if (status.speed == 2) {
> +				netxen_niu_gbe_set_gmii_mode(adapter, port, 1);
> +			} else if ((status.speed == 1) || (status.speed == 0)) {
> +				netxen_niu_gbe_set_mii_mode(adapter, port, 1);
> +			} else {
> +				result = -1;
> +			}
> +
> +		} else {
> +			/* We don't have link. Cable  must be unconnected. */
> +			/* Enable phy interrupts so we take action when plugged in */
> +			netxen_crb_writelit_adapter(adapter,
> +						    NETXEN_NIU_GB_MAC_CONFIG_0
> +						    (port), 0x80000000);
> +			netxen_crb_writelit_adapter(adapter,
> +						    NETXEN_NIU_GB_MAC_CONFIG_0
> +						    (port), 0x0000f0025);
> +			if (netxen_niu_gbe_clear_phy_interrupts(adapter, port))
> +				printk("<1>ERROR clearing PHY interrupts\n");
> +			if (netxen_niu_gbe_enable_phy_interrupts(adapter, port))
> +				printk("<1>ERROR enabling PHY interrupts\n");
> +			if (netxen_niu_gbe_clear_phy_interrupts(adapter, port))
> +				printk("<1>ERROR clearing PHY interrupts\n");
> +			result = -1;
> +		}
> +	} else {
> +		result = -1;
> +	}
> +	return result;
> +}

Wouldn't this just be clearer with:

long netxen_niu_gbe_init_port(struct netxen_adapter *adapter, long port)
{
	int err;
	struct netxen_niu_phy_status status;

	err = netxen_niu_gbe_phy_read(adapter, port,
				      NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
				      (netxen_crbword_t *) & status);
	if (err)
		return err;

	if (status.link) {
		if (status.speed == 2)
			netxen_niu_gbe_set_gmii_mode(adapter, port, 1);
		else if ((status.speed == 1) || (status.speed == 0))
			netxen_niu_gbe_set_mii_mode(adapter, port, 1);
		else
			return -EINVAL;
		return 0;
	}

	/* We don't have link. Cable  must be unconnected. */
	/* Enable phy interrupts so we take action when plugged in */
	netxen_crb_writelit_adapter(adapter,
				    NETXEN_NIU_GB_MAC_CONFIG_0
				    (port), 0x80000000);
	netxen_crb_writelit_adapter(adapter,
				    NETXEN_NIU_GB_MAC_CONFIG_0
				    (port), 0x0000f0025);
	if (netxen_niu_gbe_clear_phy_interrupts(adapter, port))
		printk(KERN_ERR PFX "error clearing PHY interrupts\n");
	if (netxen_niu_gbe_enable_phy_interrupts(adapter, port))
		printk(KERN_ERR PFX "error enabling PHY interrupts\n");
	if (netxen_niu_gbe_clear_phy_interrupts(adapter, port))
		printk(KERN_ERR PFX "error clearing PHY interrupts\n");

	return -ENOTCONNECTED;
}


> +
> +/** 
> + * netxen_niu_gbe_handle_phy_interrupt - Handles GbE PHY interrupts
> + * @param enable 0 means don't enable the port
> + *               1 means enable (or re-enable) the port
> + **/
> +long netxen_niu_gbe_handle_phy_interrupt(struct netxen_adapter *adapter,
> +					 long port, long enable)
> +{
> +	long result = 0;
> +	struct netxen_niu_phy_interrupt int_src;
> +
> +	printk
> +	    ("<1>NETXEN: Handling PHY interrupt on port %d (device enable = %d)\n",
> +	     (int)port, (int)enable);
> +
> +	/* The read of the PHY INT status will clear the pending interrupt status */
> +	if (netxen_niu_gbe_phy_read(adapter, port,
> +				    NETXEN_NIU_GB_MII_MGMT_ADDR_INT_STATUS,
> +				    (netxen_crbword_t *) & int_src) != 0)
> +		result = -1;
> +	else {
> +		printk("<1>PHY Interrupt source = 0x%x \n", *(u32 *) & int_src);

These are debug messages, not a KERN_CRITICAL message..

> +		if (int_src.jabber)
> +			printk("<1>jabber Interrupt ");
> +		if (int_src.polarity_changed)
> +			printk("<1>polarity changed ");
> +		if (int_src.energy_detect)
> +			printk("<1>energy detect \n");
> +		if (int_src.downshift)
> +			printk("<1>downshift \n");
> +		if (int_src.mdi_xover_changed)
> +			printk("<1>mdi_xover_changed ");
> +		if (int_src.fifo_over_underflow)
> +			printk("<1>fifo_over_underflow ");
> +		if (int_src.false_carrier)
> +			printk("<1>false_carrier ");
> +		if (int_src.symbol_error)
> +			printk("<1>symbol_error ");
> +		if (int_src.autoneg_completed)
> +			printk("<1>autoneg_completed ");
> +		if (int_src.page_received)
> +			printk("<1>page_received ");
> +		if (int_src.duplex_changed)
> +			printk("<1>duplex_changed ");
> +		if (int_src.autoneg_error)
> +			printk("<1>autoneg_error ");
> +		if ((int_src.speed_changed) || (int_src.link_status_changed)) {
> +			struct netxen_niu_phy_status status;
> +
> +			printk("<1>speed_changed or link status changed");
> +			if (netxen_niu_gbe_phy_read(adapter, port,
> +						    NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS,
> +						    (netxen_crbword_t *) &
> +						    status) == 0) {
> +				printk("<1>\n");
> +				if (status.speed == 2) {
> +					printk
> +					    ("<1>Link speed changed to 1000 Mbps\n");
> +					netxen_niu_gbe_set_gmii_mode(adapter,
> +								     port,
> +								     enable);
> +				} else if (status.speed == 1) {
> +					printk
> +					    ("<1>Link speed changed to 100 Mbps\n");
> +					netxen_niu_gbe_set_mii_mode(adapter,
> +								    port,
> +								    enable);
> +				} else if (status.speed == 0) {
> +					printk
> +					    ("<1>Link speed changed to 10 Mbps\n");
> +					netxen_niu_gbe_set_mii_mode(adapter,
> +								    port,
> +								    enable);
> +				} else {
> +					printk
> +					    ("<1>ERROR reading PHY status. Illegal speed.\n");
> +					result = -1;
> +				}
> +			} else {
> +				printk("<1>ERROR reading PHY status.\n");
> +				result = -1;
> +			}
> +
> +		}
> +		printk("<1>\n");
> +	}
> +	return result;
> +}
> +
> +/**
> + * Return the current station MAC address.
> + * Note that the passed-in value must already be in network byte order.
> + **/
> +int netxen_niu_macaddr_get(struct netxen_adapter *adapter,
> +			   int phy, netxen_ethernet_macaddr_t * addr)
> +{
> +	u64 result = 0;
> +	struct netxen_niu_gb_station_address_high stationhigh;
> +	struct netxen_niu_gb_station_address_low stationlow;
> +
> +	if (addr == NULL)
> +		return -1;
> +	if ((phy < 0) || (phy > 3))
> +		return -1;
> +
> +	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_GB_STATION_ADDR_0(phy),
> +				  &stationhigh, 4))
> +		return -1;
> +	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_GB_STATION_ADDR_1(phy),
> +				  &stationlow, 4))
> +		return -1;
> +
> +	result = (u64) stationlow.address;
> +	result |= (u64) stationhigh.address << 16;
> +	memcpy(*addr, &result, sizeof(netxen_ethernet_macaddr_t));
> +
> +	return 0;
> +}
> +
> +/**
> + * Set the station MAC address.
> + * Note that the passed-in value must already be in network byte order.
> + **/
> +int netxen_niu_macaddr_set(struct netxen_adapter *adapter, int phy,
> +			   netxen_ethernet_macaddr_t addr)
> +{
> +	netxen_crbword_t temp = 0;
> +
> +	if ((phy < 0) || (phy > 3))
> +		return -1;
> +
> +	memcpy(&temp, addr, 2);
> +	temp <<= 16;
> +	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_STATION_ADDR_1(phy),
> +				   &temp, 4))
> +		return -1;
> +
> +	temp = 0;
> +
> +	memcpy(&temp, ((u8 *) addr) + 2, sizeof(netxen_crbword_t));
> +	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_STATION_ADDR_0(phy),
> +				   &temp, 4))
> +		return -2;

Please use -ERRNO style returns.

> +
> +	return 0;
> +}
> +
> +/* Enable a GbE interface */
> +long netxen_niu_enable_gbe_port(struct netxen_adapter *adapter,
> +				long port, netxen_niu_gbe_ifmode_t mode)
> +{
> +	struct netxen_niu_gb_mac_config_0_t mac_cfg0;
> +	struct netxen_niu_gb_mac_config_1_t mac_cfg1;
> +	struct netxen_niu_gb_mii_mgmt_config mii_cfg;
> +
> +	if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
> +		return -1;
> +
> +	*(netxen_crbword_t *) & mac_cfg0 = 0;
> +	mac_cfg0.soft_reset = 1;
> +	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
> +				   &mac_cfg0, 4))
> +		return -1;
> +	*(netxen_crbword_t *) & mac_cfg0 = 0;
> +	mac_cfg0.tx_enable = 1;
> +	mac_cfg0.rx_enable = 1;
> +	mac_cfg0.rx_flowctl = 0;
> +	mac_cfg0.tx_reset_pb = 1;
> +	mac_cfg0.rx_reset_pb = 1;
> +	mac_cfg0.tx_reset_mac = 1;
> +	mac_cfg0.rx_reset_mac = 1;
> +
> +	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
> +				   &mac_cfg0, 4))
> +		return -1;
> +	*(netxen_crbword_t *) & mac_cfg1 = 0;
> +	mac_cfg1.preamblelen = 0xf;
> +	mac_cfg1.duplex = 1;
> +	mac_cfg1.crc_enable = 1;
> +	mac_cfg1.padshort = 1;
> +	mac_cfg1.checklength = 1;
> +	mac_cfg1.hugeframes = 1;
> +
> +	if (mode == NETXEN_NIU_10_100_MB) {
> +		mac_cfg1.intfmode = 1;
> +		if (netxen_nic_hw_write_wx(adapter,
> +					   NETXEN_NIU_GB_MAC_CONFIG_1(port),
> +					   &mac_cfg1, 4))
> +			return -1;
> +
> +		/* set mii mode */
> +		netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB0_GMII_MODE +
> +					    (port << 3), 0);
> +		netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB0_MII_MODE +
> +					    (port << 3), 1);
> +
> +	} else if (mode == NETXEN_NIU_1000_MB) {
> +		mac_cfg1.intfmode = 2;
> +		if (netxen_nic_hw_write_wx(adapter,
> +					   NETXEN_NIU_GB_MAC_CONFIG_1(port),
> +					   &mac_cfg1, 4))
> +			return -1;
> +		/* set gmii mode */
> +		netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB0_MII_MODE +
> +					    (port << 3), 0);
> +		netxen_crb_writelit_adapter(adapter, NETXEN_NIU_GB0_GMII_MODE +
> +					    (port << 3), 1);
> +	}
> +	*(netxen_crbword_t *) & mii_cfg = 0;
> +	mii_cfg.clockselect = 7;
> +	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MII_MGMT_CONFIG(port),
> +				   &mii_cfg, 4))
> +		return -1;
> +
> +	*(netxen_crbword_t *) & mac_cfg0 = 0;
> +	mac_cfg0.tx_enable = 1;
> +	mac_cfg0.rx_enable = 1;
> +	mac_cfg0.tx_flowctl = 0;
> +	mac_cfg0.rx_flowctl = 0;
> +	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
> +				   &mac_cfg0, 4))
> +		return -1;
> +	return 0;
> +}
> +
> +/* Disable a GbE interface */
> +long netxen_niu_disable_gbe_port(struct netxen_adapter *adapter, long port)
> +{
> +	struct netxen_niu_gb_mac_config_0_t mac_cfg0;
> +
> +	if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
> +		return -1;
	return -EINVAL?

> +
> +	*(netxen_crbword_t *) & mac_cfg0 = 0;
> +	mac_cfg0.soft_reset = 1;
> +	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_MAC_CONFIG_0(port),
> +				   &mac_cfg0, 4))
> +		return -1;
> +	return 0;

how about just
	return netxen_nic_hw_write_wx(...)

> +}
> +
> +/* Disable an XG interface */
> +long netxen_niu_disable_xg_port(struct netxen_adapter *adapter, long port)
> +{
> +	struct netxen_niu_xg_mac_config_0_t mac_cfg;
> +
> +	if (port != 0)
> +		return -1;
> +
> +	*(netxen_crbword_t *) & mac_cfg = 0;
> +	mac_cfg.soft_reset = 1;
> +	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_XGE_CONFIG_0,
> +				   &mac_cfg, 4))
> +		return -1;
> +	return 0;
> +}
> +
> +/* Set promiscuous mode for a GbE interface */
> +long netxen_niu_set_promiscuous_mode(struct netxen_adapter *adapter, long port,
> +				     netxen_niu_prom_mode_t mode)
> +{
> +	struct netxen_niu_gb_drop_crc reg;
> +	long data;
> +
> +	if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
> +		return -1;
> +
> +	if (mode == NETXEN_NIU_PROMISCOUS_MODE)
> +		data = 0;
> +	else
> +		data = 1;
> +
> +	/* save previous contents */
> +	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_GB_DROP_WRONGADDR,
> +				  &reg, 4))
> +		return -1;
> +	switch (port) {
> +	case 0:
> +		reg.drop_gb0 = data;
> +		break;
> +	case 1:
> +		reg.drop_gb0 = data;
> +		break;
> +	case 2:
> +		reg.drop_gb0 = data;
> +		break;
> +	case 3:
> +		reg.drop_gb0 = data;
> +		break;
> +	default:
> +		return -1;
> +	}
> +	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_GB_DROP_WRONGADDR,
> +				   &reg, 4))
> +		return -1;
> +	return 0;
> +}
> +
> +/**
> + * Set the MAC address for an XG port
> + * Note that the passed-in value must already be in network byte order.
> + **/
> +int netxen_niu_xg_macaddr_set(struct netxen_adapter *adapter, int phy,
> +			      netxen_ethernet_macaddr_t addr)
> +{
> +	netxen_crbword_t temp = 0;
> +
> +	if ((phy < 0) || (phy > 3))
> +		return -1;
> +
> +	memcpy(&temp, addr, 2);
> +	temp <<= 16;
> +	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_1,
> +				   &temp, 4))
> +		return -1;
> +
> +	temp = 0;
> +
> +	memcpy(&temp, ((u8 *) addr) + 2, sizeof(netxen_crbword_t));
> +	if (netxen_nic_hw_write_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_HI,
> +				   &temp, 4))
> +		return -1;
> +
> +	return 0;
> +}
> +
> +/**
> + * Return the current station MAC address.
> + * Note that the passed-in value must already be in network byte order.
> + **/
> +int netxen_niu_xg_macaddr_get(struct netxen_adapter *adapter, int phy,
> +			      netxen_ethernet_macaddr_t * addr)
> +{
> +	netxen_crbword_t stationhigh;
> +	netxen_crbword_t stationlow;
> +	u64 result;
> +
> +	if (addr == NULL)
> +		return -1;
> +	if (phy != 0)
> +		return -1;
> +
> +	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_HI,
> +				  &stationhigh, 4))
> +		return -1;
> +	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_XGE_STATION_ADDR_0_1,
> +				  &stationlow, 4))
> +		return -1;
> +
> +	result = ((u64) stationlow) >> 16;
> +	result |= (u64) stationhigh << 16;
> +	memcpy(*addr, &result, sizeof(netxen_ethernet_macaddr_t));
> +
> +	return 0;
> +}
> +
> +long netxen_niu_xg_set_promiscuous_mode(struct netxen_adapter *adapter,
> +					long port, netxen_niu_prom_mode_t mode)
> +{
> +	long reg;
> +
> +	if ((port < 0) || (port > NETXEN_NIU_MAX_GBE_PORTS))
> +		return -1;
> +
> +	if (netxen_nic_hw_read_wx(adapter, NETXEN_NIU_XGE_CONFIG_1, &reg, 4))
> +		return -1;
> +	if (mode == NETXEN_NIU_PROMISCOUS_MODE)
> +		reg = (reg | 0x2000UL);
> +	else
> +		reg = (reg & ~0x2000UL);
> +
> +	netxen_crb_writelit_adapter(adapter, NETXEN_NIU_XGE_CONFIG_1, reg);
> +
> +	return 0;
> +}
>
