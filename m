From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: mv643xx(3/20): use MII library for ethtool functions
Date: Mon, 28 Mar 2005 16:43:27 -0700
Message-ID: <20050328234327.GC29098@xyzzy>
References: <20050328233807.GA28423@xyzzy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ralf Baechle <ralf@linux-mips.org>, Manish Lachwani <mlachwani@mvista.com>,
        Brian Waite <brian@waitefamily.us>,
        "Steven J. Hill" <sjhill@realitydiluted.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        James Chapman <jchapman@katalix.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050328233807.GA28423@xyzzy>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use the common ethtool support functions of the MII library.
Add generic MII ioctl handler.
Add PHY parameter (speed/duplex/negotiation etc) modification support.

Signed-off-by: James Chapman <jchapman@katalix.com>
Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

Index: linux-2.5-enet/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.5-enet.orig/drivers/net/mv643xx_eth.c
+++ linux-2.5-enet/drivers/net/mv643xx_eth.c
@@ -89,6 +89,7 @@
 static int ethernet_phy_detect(unsigned int eth_port_num);
 static int mv643xx_mdio_read(struct net_device *dev, int phy_id, int location);
 static void mv643xx_mdio_write(struct net_device *dev, int phy_id, int location, int val);
+static int mv643xx_eth_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
 static struct ethtool_ops mv643xx_ethtool_ops;
 
 static char mv643xx_driver_name[] = "mv643xx_eth";
@@ -670,6 +671,115 @@
 	return coal;
 }
 
+/* Set the mv643xx port configuration for the speed/duplex mode. 
+ * In the MV643XX PSCR, the following bits are defined:
+ * Bit2  - AN_Duplex, autoneg duplex, 0=>enable
+ * Bit13 - AN_Speed, autoneg speed, 0=>enable
+ * Bit21 - Set_Fdx, set full duplex. 1=>FD
+ * Bit23 - Set_GMII_Speed, 0=>10/100, 1=>1000
+ * Bit24 - Set_MII_Speed, 0=>10, 1=>100
+ */
+static void mv643xx_eth_update_pscr(struct net_device *dev,
+				   struct ethtool_cmd *cmd)
+{
+	struct mv643xx_private *mp = netdev_priv(dev);
+
+	mp->port_serial_control &= ~(BIT2 | BIT13 | BIT21 | BIT23 | BIT24);
+	if (!cmd->autoneg)
+		mp->port_serial_control |= BIT2 | BIT13;
+
+	if (cmd->duplex)
+		mp->port_serial_control |= BIT21;
+
+	if (cmd->speed == SPEED_100)
+		mp->port_serial_control |= BIT24;
+	else if (cmd->speed == SPEED_1000)
+		mp->port_serial_control |= BIT23;
+}
+
+static int mv643xx_set_settings(struct net_device *dev,
+				    struct ethtool_cmd *cmd)
+{
+	struct mv643xx_private *mp = netdev_priv(dev);
+	int err;
+
+	/* If we get here, the user wants to configure specific
+	 * settings.  There are 2 cases: autonegotiation on/off. When
+	 * autoneg is off, the PHY is forced to a specific mode. When
+	 * autoneg is on, we enable/disable specified negotiation
+	 * parameters.
+	 */
+	cmd->advertising &= ~(ADVERTISED_10baseT_Half |
+			      ADVERTISED_10baseT_Full |
+			      ADVERTISED_100baseT_Half |
+			      ADVERTISED_100baseT_Full |
+			      ADVERTISED_1000baseT_Half |
+			      ADVERTISED_1000baseT_Full);
+	if (!cmd->autoneg) {
+		switch (cmd->speed) {
+		case SPEED_10:
+			cmd->advertising |= ADVERTISED_10baseT_Half;
+			if (cmd->duplex == DUPLEX_FULL)
+				cmd->advertising |= ADVERTISED_10baseT_Full;
+			break;
+		case SPEED_100:
+			cmd->advertising |= ADVERTISED_100baseT_Half;
+			if (cmd->duplex == DUPLEX_FULL)
+				cmd->advertising |= ADVERTISED_100baseT_Full;
+			break;
+		case SPEED_1000:
+			if (cmd->duplex == DUPLEX_FULL)
+				cmd->advertising |= ADVERTISED_1000baseT_Full;
+			else
+				return -EINVAL;
+			break;
+		}
+	} else {
+		switch (cmd->speed) {
+		default:
+		case SPEED_1000:
+			if (cmd->duplex == DUPLEX_FULL)
+				cmd->advertising |= ADVERTISED_1000baseT_Full;
+			else
+				return -EINVAL;
+			/* NOBREAK */
+		case SPEED_100:
+			cmd->advertising |= ADVERTISED_100baseT_Half;
+			if (cmd->duplex == DUPLEX_FULL)
+				cmd->advertising |= ADVERTISED_100baseT_Full;
+			/* NOBREAK */
+		case SPEED_10:
+			cmd->advertising |= ADVERTISED_10baseT_Half;
+			if (cmd->duplex == DUPLEX_FULL)
+				cmd->advertising |= ADVERTISED_10baseT_Full;
+			/* NOBREAK */
+		}
+	}
+
+	/* Reconfigure the PHY */
+	err = mii_ethtool_sset(&mp->mii, cmd);
+	if (err)
+		return err;
+
+	mv643xx_eth_update_pscr(dev, cmd);
+
+	memcpy(&mp->ethtool_cmd, cmd, sizeof *cmd);
+
+	/* Restart the port with new settings. This will use the value
+	 * of port_serial_control that was configured above.
+	 */
+	if (netif_running(dev)) {
+		if (mv643xx_eth_real_stop(dev))
+			printk(KERN_ERR "%s: Fatal error on stopping "
+			       "device\n", dev->name);
+		if (mv643xx_eth_real_open(dev))
+			printk(KERN_ERR "%s: Fatal error on opening "
+			       "device\n", dev->name);
+	}
+
+	return 0;
+}
+
 /*
  * mv643xx_eth_open
  *
@@ -708,6 +818,9 @@
 	}
 
 	spin_unlock_irq(&mp->lock);
+	
+	if (mp->ethtool_cmd.autoneg || mp->ethtool_cmd.speed)
+		mv643xx_set_settings(dev, &mp->ethtool_cmd);
 
 	return 0;
 
@@ -1394,6 +1507,7 @@
 	u8 *p;
 	struct resource *res;
 	int err;
+	struct ethtool_cmd *ecmd;
 
 	dev = alloc_etherdev(sizeof(struct mv643xx_private));
 	if (!dev)
@@ -1431,6 +1545,7 @@
 	dev->tx_queue_len = mp->tx_ring_size;
 	dev->base_addr = 0;
 	dev->change_mtu = mv643xx_eth_change_mtu;
+	dev->do_ioctl = mv643xx_eth_do_ioctl;
 	SET_ETHTOOL_OPS(dev, &mv643xx_ethtool_ops);
 
 #ifdef MV643XX_CHECKSUM_OFFLOAD_TX
@@ -1443,15 +1558,6 @@
 #endif
 #endif
 
-	/* Hook up MII support for ethtool */
-	mp->mii.dev = dev;
-	mp->mii.mdio_read = mv643xx_mdio_read;
-	mp->mii.mdio_write = mv643xx_mdio_write;
-	mp->mii.phy_id = ethernet_phy_get(mp->port_num);
-	mp->mii.phy_id_mask = 0x3f;
-	mp->mii.reg_num_mask = 0x1f;
-	mp->mii.supports_gmii = 1;
-
 	/* Configure the timeout task */
 	INIT_WORK(&mp->tx_timeout_task,
 			(void (*)(void *))mv643xx_eth_tx_timeout_task, dev);
@@ -1460,33 +1566,20 @@
 
 	/* set default config values */
 	eth_port_uc_addr_get(dev, dev->dev_addr);
-	mp->port_config = MV643XX_ETH_PORT_CONFIG_DEFAULT_VALUE;
-	mp->port_config_extend = MV643XX_ETH_PORT_CONFIG_EXTEND_DEFAULT_VALUE;
-	mp->port_sdma_config = MV643XX_ETH_PORT_SDMA_CONFIG_DEFAULT_VALUE;
-	mp->port_serial_control = MV643XX_ETH_PORT_SERIAL_CONTROL_DEFAULT_VALUE;
+	mp->port_serial_control =
+		mv_read(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num));
+	mp->port_serial_control &= ~MV643XX_ETH_SERIAL_PORT_ENABLE;
+	mp->port_serial_control |= MV643XX_ETH_DISABLE_AUTO_NEG_FOR_FLOW_CTRL |
+				   MV643XX_ETH_SERIAL_PORT_CONTROL_RESERVED   |
+				   MV643XX_ETH_DO_NOT_FORCE_LINK_FAIL;
 	mp->rx_ring_size = MV643XX_ETH_PORT_DEFAULT_RECEIVE_QUEUE_SIZE;
 	mp->tx_ring_size = MV643XX_ETH_PORT_DEFAULT_TRANSMIT_QUEUE_SIZE;
 
 	pd = pdev->dev.platform_data;
 	if (pd) {
-		if (pd->mac_addr != NULL)
+		if (pd->mac_addr)
 			memcpy(dev->dev_addr, pd->mac_addr, 6);
 
-		if (pd->phy_addr || pd->force_phy_addr)
-			ethernet_phy_set(port_num, pd->phy_addr);
-
-		if (pd->port_config || pd->force_port_config)
-			mp->port_config = pd->port_config;
-
-		if (pd->port_config_extend || pd->force_port_config_extend)
-			mp->port_config_extend = pd->port_config_extend;
-
-		if (pd->port_sdma_config || pd->force_port_sdma_config)
-			mp->port_sdma_config = pd->port_sdma_config;
-
-		if (pd->port_serial_control || pd->force_port_serial_control)
-			mp->port_serial_control = pd->port_serial_control;
-
 		if (pd->rx_queue_size)
 			mp->rx_ring_size = pd->rx_queue_size;
 
@@ -1502,8 +1595,32 @@
 			mp->rx_sram_size = pd->rx_sram_size;
 			mp->rx_sram_addr = pd->rx_sram_addr;
 		}
+
+		if (pd->ethtool_cmd) {
+			ecmd = pd->ethtool_cmd;
+			if (ecmd->advertising == 0)
+				ecmd->advertising = ADVERTISED_10baseT_Half   |
+						    ADVERTISED_10baseT_Full   |
+						    ADVERTISED_100baseT_Half  |
+						    ADVERTISED_100baseT_Full  |
+						    ADVERTISED_1000baseT_Full |
+						    ADVERTISED_Autoneg	      |
+						    ADVERTISED_MII;
+
+			ethernet_phy_set(port_num, ecmd->phy_address);
+			memcpy(&mp->ethtool_cmd, ecmd, sizeof *ecmd);
+			mv643xx_eth_update_pscr(dev, ecmd);
+		}
 	}
 
+	/* Hook up MII support for ethtool */
+	mp->mii.dev = dev;
+	mp->mii.mdio_read = mv643xx_mdio_read;
+	mp->mii.mdio_write = mv643xx_mdio_write;
+	mp->mii.phy_id = ethernet_phy_get(port_num);
+	mp->mii.phy_id_mask = 0x3f;
+	mp->mii.reg_num_mask = 0x1f;
+
 	err = ethernet_phy_detect(port_num);
 	if (err) {
 		pr_debug("MV643xx ethernet port %d: "
@@ -1516,6 +1633,8 @@
 	if (err)
 		goto out;
 
+	mp->mii.supports_gmii = mii_check_gmii_support(&mp->mii);
+
 	p = dev->dev_addr;
 	printk(KERN_NOTICE
 		"%s: port %d with MAC address %02x:%02x:%02x:%02x:%02x:%02x\n",
@@ -1888,10 +2007,15 @@
 	eth_port_uc_addr_set(port_num, mp->port_mac_addr);
 
 	/* Assign port configuration and command. */
-	mv_write(MV643XX_ETH_PORT_CONFIG_REG(port_num), mp->port_config);
+	mv_write(MV643XX_ETH_PORT_CONFIG_REG(port_num),
+			  MV643XX_ETH_PORT_CONFIG_DEFAULT_VALUE);
 
 	mv_write(MV643XX_ETH_PORT_CONFIG_EXTEND_REG(port_num),
-						mp->port_config_extend);
+			  MV643XX_ETH_PORT_CONFIG_EXTEND_DEFAULT_VALUE);
+
+	/* the mv643xx users manual says the following read/write are needed */
+	mv_read(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num));
+	mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num), 0);
 
 
 	/* Increase the Rx side buffer size if supporting GigE */
@@ -1903,12 +2027,12 @@
 						mp->port_serial_control);
 
 	mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num),
-		mv_read(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num)) |
-						MV643XX_ETH_SERIAL_PORT_ENABLE);
+			mp->port_serial_control |
+			MV643XX_ETH_SERIAL_PORT_ENABLE);
 
 	/* Assign port SDMA configuration */
 	mv_write(MV643XX_ETH_SDMA_CONFIG_REG(port_num),
-							mp->port_sdma_config);
+			  MV643XX_ETH_PORT_SDMA_CONFIG_DEFAULT_VALUE);
 
 	/* Enable port Rx. */
 	mv_write(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num),
@@ -2351,15 +2475,6 @@
 	mv_write(MV643XX_ETH_PORT_CONFIG_REG(eth_port_num), eth_config_reg);
 }
 
-static int eth_port_autoneg_supported(unsigned int eth_port_num)
-{
-	unsigned int phy_reg_data0;
-
-	eth_port_read_smi_reg(eth_port_num, 0, &phy_reg_data0);
-
-	return phy_reg_data0 & 0x1000;
-}
-
 /*
  * ethernet_get_config_reg - Get the port configuration register
  *
@@ -2908,106 +3023,17 @@
 static int
 mv643xx_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 {
-	struct mv643xx_private *mp = netdev->priv;
-	int port_num = mp->port_num;
-	int autoneg = eth_port_autoneg_supported(port_num);
-	int mode_10_bit;
-	int auto_duplex;
-	int half_duplex = 0;
-	int full_duplex = 0;
-	int auto_speed;
-	int speed_10 = 0;
-	int speed_100 = 0;
-	int speed_1000 = 0;
-
-	u32 pcs = mv_read(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num));
-	u32 psr = mv_read(MV643XX_ETH_PORT_STATUS_REG(port_num));
-
-	mode_10_bit = psr & MV643XX_ETH_PORT_STATUS_MODE_10_BIT;
-
-	if (mode_10_bit) {
-		ecmd->supported = SUPPORTED_10baseT_Half;
-	} else {
-		ecmd->supported = (SUPPORTED_10baseT_Half		|
-				   SUPPORTED_10baseT_Full		|
-				   SUPPORTED_100baseT_Half		|
-				   SUPPORTED_100baseT_Full		|
-				   SUPPORTED_1000baseT_Full		|
-				   (autoneg ? SUPPORTED_Autoneg : 0)	|
-				   SUPPORTED_TP);
-
-		auto_duplex = !(pcs & MV643XX_ETH_DISABLE_AUTO_NEG_FOR_DUPLX);
-		auto_speed = !(pcs & MV643XX_ETH_DISABLE_AUTO_NEG_SPEED_GMII);
-
-		ecmd->advertising = ADVERTISED_TP;
-
-		if (autoneg) {
-			ecmd->advertising |= ADVERTISED_Autoneg;
-
-			if (auto_duplex) {
-				half_duplex = 1;
-				full_duplex = 1;
-			} else {
-				if (pcs & MV643XX_ETH_SET_FULL_DUPLEX_MODE)
-					full_duplex = 1;
-				else
-					half_duplex = 1;
-			}
-
-			if (auto_speed) {
-				speed_10 = 1;
-				speed_100 = 1;
-				speed_1000 = 1;
-			} else {
-				if (pcs & MV643XX_ETH_SET_GMII_SPEED_TO_1000)
-					speed_1000 = 1;
-				else if (pcs & MV643XX_ETH_SET_MII_SPEED_TO_100)
-					speed_100 = 1;
-				else
-					speed_10 = 1;
-			}
-
-			if (speed_10 & half_duplex)
-				ecmd->advertising |= ADVERTISED_10baseT_Half;
-			if (speed_10 & full_duplex)
-				ecmd->advertising |= ADVERTISED_10baseT_Full;
-			if (speed_100 & half_duplex)
-				ecmd->advertising |= ADVERTISED_100baseT_Half;
-			if (speed_100 & full_duplex)
-				ecmd->advertising |= ADVERTISED_100baseT_Full;
-			if (speed_1000)
-				ecmd->advertising |= ADVERTISED_1000baseT_Full;
-		}
-	}
+	int rc;
+	struct mv643xx_private *mp = netdev_priv(netdev);
 
-	ecmd->port = PORT_TP;
-	ecmd->phy_address = ethernet_phy_get(port_num);
-
-	ecmd->transceiver = XCVR_EXTERNAL;
-
-	if (netif_carrier_ok(netdev)) {
-		if (mode_10_bit)
-			ecmd->speed = SPEED_10;
-		else {
-			if (psr & MV643XX_ETH_PORT_STATUS_GMII_1000)
-				ecmd->speed = SPEED_1000;
-			else if (psr & MV643XX_ETH_PORT_STATUS_MII_100)
-				ecmd->speed = SPEED_100;
-			else
-				ecmd->speed = SPEED_10;
-		}
+	ecmd->supported = SUPPORTED_MII;
+	ecmd->port = PORT_MII;
+	rc = mii_ethtool_gset(&mp->mii, ecmd);
 
-		if (psr & MV643XX_ETH_PORT_STATUS_FULL_DUPLEX)
-			ecmd->duplex = DUPLEX_FULL;
-		else
-			ecmd->duplex = DUPLEX_HALF;
-	} else {
-		ecmd->speed = -1;
-		ecmd->duplex = -1;
-	}
+	ecmd->supported &= ~SUPPORTED_1000baseT_Half;
+	ecmd->advertising &= ~ADVERTISED_1000baseT_Half;
 
-	ecmd->autoneg = autoneg ? AUTONEG_ENABLE : AUTONEG_DISABLE;
-	return 0;
+	return rc;
 }
 
 static void
@@ -3059,15 +3085,54 @@
 	}
 }
 
+static u32 mv643xx_eth_get_msglevel(struct net_device *dev)
+{
+	struct mv643xx_private *mp = netdev_priv(dev);
+	return mp->msg_enable;
+}
+
+static void mv643xx_eth_set_msglevel(struct net_device *dev, u32 value)
+{
+	struct mv643xx_private *mp = netdev_priv(dev);
+	mp->msg_enable = value;
+}
+
+static u32 mv643xx_eth_get_link(struct net_device *dev)
+{
+	struct mv643xx_private *mp = netdev_priv(dev);
+	return mii_link_ok(&mp->mii);
+}
+
+static int mv643xx_eth_nway_restart(struct net_device *dev)
+{
+	struct mv643xx_private *mp = netdev_priv(dev);
+
+	return mii_nway_restart(&mp->mii);
+}
+
+static int mv643xx_eth_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+{
+	struct mv643xx_private *mp = netdev_priv(dev);
+
+	return generic_mii_ioctl(&mp->mii, if_mii(ifr), cmd, NULL);
+}
+
 static struct ethtool_ops mv643xx_ethtool_ops = {
 	.get_settings           = mv643xx_get_settings,
+	.set_settings           = mv643xx_set_settings,
 	.get_drvinfo            = mv643xx_get_drvinfo,
-	.get_link               = ethtool_op_get_link,
+	.get_link               = mv643xx_eth_get_link,
 	.get_sg			= ethtool_op_get_sg,
 	.set_sg			= ethtool_op_set_sg,
 	.get_strings            = mv643xx_get_strings,
 	.get_stats_count        = mv643xx_get_stats_count,
 	.get_ethtool_stats      = mv643xx_get_ethtool_stats,
+	.get_strings            = mv643xx_get_strings,
+	.get_stats_count        = mv643xx_get_stats_count,
+	.get_ethtool_stats      = mv643xx_get_ethtool_stats,
+	.get_msglevel		= mv643xx_eth_get_msglevel,
+	.set_msglevel		= mv643xx_eth_set_msglevel,
+	.nway_reset		= mv643xx_eth_nway_restart,
 };
 
 /************* End ethtool support *************************/
Index: linux-2.5-enet/drivers/net/mv643xx_eth.h
===================================================================
--- linux-2.5-enet.orig/drivers/net/mv643xx_eth.h
+++ linux-2.5-enet/drivers/net/mv643xx_eth.h
@@ -156,6 +156,171 @@
 #define ETH_PORT_TX_FIFO_NOT_EMPTY		0
 #define ETH_PORT_TX_FIFO_EMPTY			BIT10
 
+/* These macros describe Ethernet Port configuration reg (Px_cR) bits */
+#define MV643XX_ETH_UNICAST_NORMAL_MODE		0
+#define MV643XX_ETH_UNICAST_PROMISCUOUS_MODE	(1<<0)
+#define MV643XX_ETH_DEFAULT_RX_QUEUE_0		0
+#define MV643XX_ETH_DEFAULT_RX_QUEUE_1		(1<<1)
+#define MV643XX_ETH_DEFAULT_RX_QUEUE_2		(1<<2)
+#define MV643XX_ETH_DEFAULT_RX_QUEUE_3		((1<<2) | (1<<1))
+#define MV643XX_ETH_DEFAULT_RX_QUEUE_4		(1<<3)
+#define MV643XX_ETH_DEFAULT_RX_QUEUE_5		((1<<3) | (1<<1))
+#define MV643XX_ETH_DEFAULT_RX_QUEUE_6		((1<<3) | (1<<2))
+#define MV643XX_ETH_DEFAULT_RX_QUEUE_7		((1<<3) | (1<<2) | (1<<1))
+#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_0	0
+#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_1	(1<<4)
+#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_2	(1<<5)
+#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_3	((1<<5) | (1<<4))
+#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_4	(1<<6)
+#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_5	((1<<6) | (1<<4))
+#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_6	((1<<6) | (1<<5))
+#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_7	((1<<6) | (1<<5) | (1<<4))
+#define MV643XX_ETH_RECEIVE_BC_IF_NOT_IP_OR_ARP	0
+#define MV643XX_ETH_REJECT_BC_IF_NOT_IP_OR_ARP	(1<<7)
+#define MV643XX_ETH_RECEIVE_BC_IF_IP		0
+#define MV643XX_ETH_REJECT_BC_IF_IP		(1<<8)
+#define MV643XX_ETH_RECEIVE_BC_IF_ARP		0
+#define MV643XX_ETH_REJECT_BC_IF_ARP		(1<<9)
+#define MV643XX_ETH_TX_AM_NO_UPDATE_ERROR_SUMMARY (1<<12)
+#define MV643XX_ETH_CAPTURE_TCP_FRAMES_DIS	0
+#define MV643XX_ETH_CAPTURE_TCP_FRAMES_EN	(1<<14)
+#define MV643XX_ETH_CAPTURE_UDP_FRAMES_DIS	0
+#define MV643XX_ETH_CAPTURE_UDP_FRAMES_EN	(1<<15)
+#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_0	0
+#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_1	(1<<16)
+#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_2	(1<<17)
+#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_3	((1<<17) | (1<<16))
+#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_4	(1<<18)
+#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_5	((1<<18) | (1<<16))
+#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_6	((1<<18) | (1<<17))
+#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_7	((1<<18) | (1<<17) | (1<<16))
+#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_0	0
+#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_1	(1<<19)
+#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_2	(1<<20)
+#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_3	((1<<20) | (1<<19))
+#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_4	((1<<21)
+#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_5	((1<<21) | (1<<19))
+#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_6	((1<<21) | (1<<20))
+#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_7	((1<<21) | (1<<20) | (1<<19))
+#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_0	0
+#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_1	(1<<22)
+#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_2	(1<<23)
+#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_3	((1<<23) | (1<<22))
+#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_4	(1<<24)
+#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_5	((1<<24) | (1<<22))
+#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_6	((1<<24) | (1<<23))
+#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_7	((1<<24) | (1<<23) | (1<<22))
+
+#define	MV643XX_ETH_PORT_CONFIG_DEFAULT_VALUE			\
+		MV643XX_ETH_UNICAST_NORMAL_MODE		|	\
+		MV643XX_ETH_DEFAULT_RX_QUEUE_0		|	\
+		MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_0	|	\
+		MV643XX_ETH_RECEIVE_BC_IF_NOT_IP_OR_ARP	|	\
+		MV643XX_ETH_RECEIVE_BC_IF_IP		|	\
+		MV643XX_ETH_RECEIVE_BC_IF_ARP		|	\
+		MV643XX_ETH_CAPTURE_TCP_FRAMES_DIS	|	\
+		MV643XX_ETH_CAPTURE_UDP_FRAMES_DIS	|	\
+		MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_0	|	\
+		MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_0	|	\
+		MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_0
+
+/* These macros describe Ethernet Port configuration extend reg (Px_cXR) bits*/
+#define MV643XX_ETH_CLASSIFY_EN				(1<<0)
+#define MV643XX_ETH_SPAN_BPDU_PACKETS_AS_NORMAL		0
+#define MV643XX_ETH_SPAN_BPDU_PACKETS_TO_RX_QUEUE_7	(1<<1)
+#define MV643XX_ETH_PARTITION_DISABLE			0
+#define MV643XX_ETH_PARTITION_ENABLE			(1<<2)
+
+#define	MV643XX_ETH_PORT_CONFIG_EXTEND_DEFAULT_VALUE		\
+		MV643XX_ETH_SPAN_BPDU_PACKETS_AS_NORMAL	|	\
+		MV643XX_ETH_PARTITION_DISABLE
+
+/* These macros describe Ethernet Port Sdma configuration reg (SDCR) bits */
+#define MV643XX_ETH_RIFB			(1<<0)
+#define MV643XX_ETH_RX_BURST_SIZE_1_64BIT		0
+#define MV643XX_ETH_RX_BURST_SIZE_2_64BIT		(1<<1)
+#define MV643XX_ETH_RX_BURST_SIZE_4_64BIT		(1<<2)
+#define MV643XX_ETH_RX_BURST_SIZE_8_64BIT		((1<<2) | (1<<1))
+#define MV643XX_ETH_RX_BURST_SIZE_16_64BIT		(1<<3)
+#define MV643XX_ETH_BLM_RX_NO_SWAP			(1<<4)
+#define MV643XX_ETH_BLM_RX_BYTE_SWAP			0
+#define MV643XX_ETH_BLM_TX_NO_SWAP			(1<<5)
+#define MV643XX_ETH_BLM_TX_BYTE_SWAP			0
+#define MV643XX_ETH_DESCRIPTORS_BYTE_SWAP		(1<<6)
+#define MV643XX_ETH_DESCRIPTORS_NO_SWAP			0
+#define MV643XX_ETH_TX_BURST_SIZE_1_64BIT		0
+#define MV643XX_ETH_TX_BURST_SIZE_2_64BIT		(1<<22)
+#define MV643XX_ETH_TX_BURST_SIZE_4_64BIT		(1<<23)
+#define MV643XX_ETH_TX_BURST_SIZE_8_64BIT		((1<<23) | (1<<22))
+#define MV643XX_ETH_TX_BURST_SIZE_16_64BIT		(1<<24)
+
+#define	MV643XX_ETH_IPG_INT_RX(value) ((value & 0x3fff) << 8)
+
+#define	MV643XX_ETH_PORT_SDMA_CONFIG_DEFAULT_VALUE		\
+		MV643XX_ETH_RX_BURST_SIZE_4_64BIT	|	\
+		MV643XX_ETH_IPG_INT_RX(0)		|	\
+		MV643XX_ETH_TX_BURST_SIZE_4_64BIT
+
+/* These macros describe Ethernet Port serial control reg (PSCR) bits */
+#define MV643XX_ETH_SERIAL_PORT_DISABLE			0
+#define MV643XX_ETH_SERIAL_PORT_ENABLE			(1<<0)
+#define MV643XX_ETH_FORCE_LINK_PASS			(1<<1)
+#define MV643XX_ETH_DO_NOT_FORCE_LINK_PASS		0
+#define MV643XX_ETH_ENABLE_AUTO_NEG_FOR_DUPLX		0
+#define MV643XX_ETH_DISABLE_AUTO_NEG_FOR_DUPLX		(1<<2)
+#define MV643XX_ETH_ENABLE_AUTO_NEG_FOR_FLOW_CTRL	0
+#define MV643XX_ETH_DISABLE_AUTO_NEG_FOR_FLOW_CTRL	(1<<3)
+#define MV643XX_ETH_ADV_NO_FLOW_CTRL			0
+#define MV643XX_ETH_ADV_SYMMETRIC_FLOW_CTRL		(1<<4)
+#define MV643XX_ETH_FORCE_FC_MODE_NO_PAUSE_DIS_TX	0
+#define MV643XX_ETH_FORCE_FC_MODE_TX_PAUSE_DIS		(1<<5)
+#define MV643XX_ETH_FORCE_BP_MODE_NO_JAM		0
+#define MV643XX_ETH_FORCE_BP_MODE_JAM_TX		(1<<7)
+#define MV643XX_ETH_FORCE_BP_MODE_JAM_TX_ON_RX_ERR	(1<<8)
+#define MV643XX_ETH_FORCE_LINK_FAIL			0
+#define MV643XX_ETH_SERIAL_PORT_CONTROL_RESERVED	(1<<9)
+#define MV643XX_ETH_DO_NOT_FORCE_LINK_FAIL		(1<<10)
+#define MV643XX_ETH_RETRANSMIT_16_ATTEMPTS		0
+#define MV643XX_ETH_RETRANSMIT_FOREVER			(1<<11)
+#define MV643XX_ETH_DISABLE_AUTO_NEG_SPEED_GMII		(1<<13)
+#define MV643XX_ETH_ENABLE_AUTO_NEG_SPEED_GMII		0
+#define MV643XX_ETH_DTE_ADV_0				0
+#define MV643XX_ETH_DTE_ADV_1				(1<<14)
+#define MV643XX_ETH_DISABLE_AUTO_NEG_BYPASS		0
+#define MV643XX_ETH_ENABLE_AUTO_NEG_BYPASS		(1<<15)
+#define MV643XX_ETH_AUTO_NEG_NO_CHANGE			0
+#define MV643XX_ETH_RESTART_AUTO_NEG			(1<<16)
+#define MV643XX_ETH_MAX_RX_PACKET_1518BYTE		0
+#define MV643XX_ETH_MAX_RX_PACKET_1522BYTE		(1<<17)
+#define MV643XX_ETH_MAX_RX_PACKET_1552BYTE		(1<<18)
+#define MV643XX_ETH_MAX_RX_PACKET_9022BYTE		((1<<18) | (1<<17))
+#define MV643XX_ETH_MAX_RX_PACKET_9192BYTE		(1<<19)
+#define MV643XX_ETH_MAX_RX_PACKET_9700BYTE		((1<<19) | (1<<17))
+#define MV643XX_ETH_SET_EXT_LOOPBACK			(1<<20)
+#define MV643XX_ETH_CLR_EXT_LOOPBACK			0
+#define MV643XX_ETH_SET_FULL_DUPLEX_MODE		(1<<21)
+#define MV643XX_ETH_SET_HALF_DUPLEX_MODE		0
+#define MV643XX_ETH_ENABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX (1<<22)
+#define MV643XX_ETH_DISABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX 0
+#define MV643XX_ETH_SET_GMII_SPEED_TO_10_100		0
+#define MV643XX_ETH_SET_GMII_SPEED_TO_1000		(1<<23)
+#define MV643XX_ETH_SET_MII_SPEED_TO_10			0
+#define MV643XX_ETH_SET_MII_SPEED_TO_100		(1<<24)
+
+/* These macros describe Ethernet Serial Status reg (PSR) bits */
+#define MV643XX_ETH_PORT_STATUS_MODE_10_BIT		(1<<0)
+#define MV643XX_ETH_PORT_STATUS_LINK_UP			(1<<1)
+#define MV643XX_ETH_PORT_STATUS_FULL_DUPLEX		(1<<2)
+#define MV643XX_ETH_PORT_STATUS_FLOW_CONTROL		(1<<3)
+#define MV643XX_ETH_PORT_STATUS_GMII_1000		(1<<4)
+#define MV643XX_ETH_PORT_STATUS_MII_100			(1<<5)
+/* PSR bit 6 is undocumented */
+#define MV643XX_ETH_PORT_STATUS_TX_IN_PROGRESS		(1<<7)
+#define MV643XX_ETH_PORT_STATUS_AUTONEG_BYPASSED	(1<<8)
+#define MV643XX_ETH_PORT_STATUS_PARTITION		(1<<9)
+#define MV643XX_ETH_PORT_STATUS_TX_FIFO_EMPTY		(1<<10)
+/* PSR bits 11-31 are reserved */
+
 #define ETH_DEFAULT_RX_BPDU_QUEUE_3		(BIT23 | BIT22)
 #define ETH_DEFAULT_RX_BPDU_QUEUE_4		BIT24
 #define ETH_DEFAULT_RX_BPDU_QUEUE_5		(BIT24 | BIT22)
@@ -325,10 +490,8 @@
 struct mv643xx_private {
 	int port_num;			/* User Ethernet port number	*/
 	u8 port_mac_addr[6];		/* User defined port MAC address.*/
-	u32 port_config;		/* User port configuration value*/
-	u32 port_config_extend;		/* User port config extend value*/
-	u32 port_sdma_config;		/* User port SDMA config value	*/
-	u32 port_serial_control;	/* User port serial control value */
+	u32 port_serial_control;	/* Port serial control value */
+	struct ethtool_cmd ethtool_cmd;	/* ethtool_cmd used at open */
 	u32 port_tx_queue_command;	/* Port active Tx queues summary*/
 	u32 port_rx_queue_command;	/* Port active Rx queues summary*/
 
Index: linux-2.5-enet/include/linux/mv643xx.h
===================================================================
--- linux-2.5-enet.orig/include/linux/mv643xx.h
+++ linux-2.5-enet/include/linux/mv643xx.h
@@ -1093,189 +1093,6 @@
 	u32	retries;
 };
 
-/* These macros describe Ethernet Port configuration reg (Px_cR) bits */
-#define MV643XX_ETH_UNICAST_NORMAL_MODE		0
-#define MV643XX_ETH_UNICAST_PROMISCUOUS_MODE	(1<<0)
-#define MV643XX_ETH_DEFAULT_RX_QUEUE_0		0
-#define MV643XX_ETH_DEFAULT_RX_QUEUE_1		(1<<1)
-#define MV643XX_ETH_DEFAULT_RX_QUEUE_2		(1<<2)
-#define MV643XX_ETH_DEFAULT_RX_QUEUE_3		((1<<2) | (1<<1))
-#define MV643XX_ETH_DEFAULT_RX_QUEUE_4		(1<<3)
-#define MV643XX_ETH_DEFAULT_RX_QUEUE_5		((1<<3) | (1<<1))
-#define MV643XX_ETH_DEFAULT_RX_QUEUE_6		((1<<3) | (1<<2))
-#define MV643XX_ETH_DEFAULT_RX_QUEUE_7		((1<<3) | (1<<2) | (1<<1))
-#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_0	0
-#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_1	(1<<4)
-#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_2	(1<<5)
-#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_3	((1<<5) | (1<<4))
-#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_4	(1<<6)
-#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_5	((1<<6) | (1<<4))
-#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_6	((1<<6) | (1<<5))
-#define MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_7	((1<<6) | (1<<5) | (1<<4))
-#define MV643XX_ETH_RECEIVE_BC_IF_NOT_IP_OR_ARP	0
-#define MV643XX_ETH_REJECT_BC_IF_NOT_IP_OR_ARP	(1<<7)
-#define MV643XX_ETH_RECEIVE_BC_IF_IP		0
-#define MV643XX_ETH_REJECT_BC_IF_IP		(1<<8)
-#define MV643XX_ETH_RECEIVE_BC_IF_ARP		0
-#define MV643XX_ETH_REJECT_BC_IF_ARP		(1<<9)
-#define MV643XX_ETH_TX_AM_NO_UPDATE_ERROR_SUMMARY (1<<12)
-#define MV643XX_ETH_CAPTURE_TCP_FRAMES_DIS	0
-#define MV643XX_ETH_CAPTURE_TCP_FRAMES_EN	(1<<14)
-#define MV643XX_ETH_CAPTURE_UDP_FRAMES_DIS	0
-#define MV643XX_ETH_CAPTURE_UDP_FRAMES_EN	(1<<15)
-#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_0	0
-#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_1	(1<<16)
-#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_2	(1<<17)
-#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_3	((1<<17) | (1<<16))
-#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_4	(1<<18)
-#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_5	((1<<18) | (1<<16))
-#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_6	((1<<18) | (1<<17))
-#define MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_7	((1<<18) | (1<<17) | (1<<16))
-#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_0	0
-#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_1	(1<<19)
-#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_2	(1<<20)
-#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_3	((1<<20) | (1<<19))
-#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_4	((1<<21)
-#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_5	((1<<21) | (1<<19))
-#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_6	((1<<21) | (1<<20))
-#define MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_7	((1<<21) | (1<<20) | (1<<19))
-#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_0	0
-#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_1	(1<<22)
-#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_2	(1<<23)
-#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_3	((1<<23) | (1<<22))
-#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_4	(1<<24)
-#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_5	((1<<24) | (1<<22))
-#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_6	((1<<24) | (1<<23))
-#define MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_7	((1<<24) | (1<<23) | (1<<22))
-
-#define	MV643XX_ETH_PORT_CONFIG_DEFAULT_VALUE			\
-		MV643XX_ETH_UNICAST_NORMAL_MODE		|	\
-		MV643XX_ETH_DEFAULT_RX_QUEUE_0		|	\
-		MV643XX_ETH_DEFAULT_RX_ARP_QUEUE_0	|	\
-		MV643XX_ETH_RECEIVE_BC_IF_NOT_IP_OR_ARP	|	\
-		MV643XX_ETH_RECEIVE_BC_IF_IP		|	\
-		MV643XX_ETH_RECEIVE_BC_IF_ARP		|	\
-		MV643XX_ETH_CAPTURE_TCP_FRAMES_DIS	|	\
-		MV643XX_ETH_CAPTURE_UDP_FRAMES_DIS	|	\
-		MV643XX_ETH_DEFAULT_RX_TCP_QUEUE_0	|	\
-		MV643XX_ETH_DEFAULT_RX_UDP_QUEUE_0	|	\
-		MV643XX_ETH_DEFAULT_RX_BPDU_QUEUE_0
-
-/* These macros describe Ethernet Port configuration extend reg (Px_cXR) bits*/
-#define MV643XX_ETH_CLASSIFY_EN				(1<<0)
-#define MV643XX_ETH_SPAN_BPDU_PACKETS_AS_NORMAL		0
-#define MV643XX_ETH_SPAN_BPDU_PACKETS_TO_RX_QUEUE_7	(1<<1)
-#define MV643XX_ETH_PARTITION_DISABLE			0
-#define MV643XX_ETH_PARTITION_ENABLE			(1<<2)
-
-#define	MV643XX_ETH_PORT_CONFIG_EXTEND_DEFAULT_VALUE		\
-		MV643XX_ETH_SPAN_BPDU_PACKETS_AS_NORMAL	|	\
-		MV643XX_ETH_PARTITION_DISABLE
-
-/* These macros describe Ethernet Port Sdma configuration reg (SDCR) bits */
-#define MV643XX_ETH_RIFB			(1<<0)
-#define MV643XX_ETH_RX_BURST_SIZE_1_64BIT		0
-#define MV643XX_ETH_RX_BURST_SIZE_2_64BIT		(1<<1)
-#define MV643XX_ETH_RX_BURST_SIZE_4_64BIT		(1<<2)
-#define MV643XX_ETH_RX_BURST_SIZE_8_64BIT		((1<<2) | (1<<1))
-#define MV643XX_ETH_RX_BURST_SIZE_16_64BIT		(1<<3)
-#define MV643XX_ETH_BLM_RX_NO_SWAP			(1<<4)
-#define MV643XX_ETH_BLM_RX_BYTE_SWAP			0
-#define MV643XX_ETH_BLM_TX_NO_SWAP			(1<<5)
-#define MV643XX_ETH_BLM_TX_BYTE_SWAP			0
-#define MV643XX_ETH_DESCRIPTORS_BYTE_SWAP		(1<<6)
-#define MV643XX_ETH_DESCRIPTORS_NO_SWAP			0
-#define MV643XX_ETH_TX_BURST_SIZE_1_64BIT		0
-#define MV643XX_ETH_TX_BURST_SIZE_2_64BIT		(1<<22)
-#define MV643XX_ETH_TX_BURST_SIZE_4_64BIT		(1<<23)
-#define MV643XX_ETH_TX_BURST_SIZE_8_64BIT		((1<<23) | (1<<22))
-#define MV643XX_ETH_TX_BURST_SIZE_16_64BIT		(1<<24)
-
-#define	MV643XX_ETH_IPG_INT_RX(value) ((value & 0x3fff) << 8)
-
-#define	MV643XX_ETH_PORT_SDMA_CONFIG_DEFAULT_VALUE		\
-		MV643XX_ETH_RX_BURST_SIZE_4_64BIT	|	\
-		MV643XX_ETH_IPG_INT_RX(0)		|	\
-		MV643XX_ETH_TX_BURST_SIZE_4_64BIT
-
-/* These macros describe Ethernet Port serial control reg (PSCR) bits */
-#define MV643XX_ETH_SERIAL_PORT_DISABLE			0
-#define MV643XX_ETH_SERIAL_PORT_ENABLE			(1<<0)
-#define MV643XX_ETH_FORCE_LINK_PASS			(1<<1)
-#define MV643XX_ETH_DO_NOT_FORCE_LINK_PASS		0
-#define MV643XX_ETH_ENABLE_AUTO_NEG_FOR_DUPLX		0
-#define MV643XX_ETH_DISABLE_AUTO_NEG_FOR_DUPLX		(1<<2)
-#define MV643XX_ETH_ENABLE_AUTO_NEG_FOR_FLOW_CTRL	0
-#define MV643XX_ETH_DISABLE_AUTO_NEG_FOR_FLOW_CTRL	(1<<3)
-#define MV643XX_ETH_ADV_NO_FLOW_CTRL			0
-#define MV643XX_ETH_ADV_SYMMETRIC_FLOW_CTRL		(1<<4)
-#define MV643XX_ETH_FORCE_FC_MODE_NO_PAUSE_DIS_TX	0
-#define MV643XX_ETH_FORCE_FC_MODE_TX_PAUSE_DIS		(1<<5)
-#define MV643XX_ETH_FORCE_BP_MODE_NO_JAM		0
-#define MV643XX_ETH_FORCE_BP_MODE_JAM_TX		(1<<7)
-#define MV643XX_ETH_FORCE_BP_MODE_JAM_TX_ON_RX_ERR	(1<<8)
-#define MV643XX_ETH_FORCE_LINK_FAIL			0
-#define MV643XX_ETH_DO_NOT_FORCE_LINK_FAIL		(1<<10)
-#define MV643XX_ETH_RETRANSMIT_16_ATTEMPTS		0
-#define MV643XX_ETH_RETRANSMIT_FOREVER			(1<<11)
-#define MV643XX_ETH_DISABLE_AUTO_NEG_SPEED_GMII		(1<<13)
-#define MV643XX_ETH_ENABLE_AUTO_NEG_SPEED_GMII		0
-#define MV643XX_ETH_DTE_ADV_0				0
-#define MV643XX_ETH_DTE_ADV_1				(1<<14)
-#define MV643XX_ETH_DISABLE_AUTO_NEG_BYPASS		0
-#define MV643XX_ETH_ENABLE_AUTO_NEG_BYPASS		(1<<15)
-#define MV643XX_ETH_AUTO_NEG_NO_CHANGE			0
-#define MV643XX_ETH_RESTART_AUTO_NEG			(1<<16)
-#define MV643XX_ETH_MAX_RX_PACKET_1518BYTE		0
-#define MV643XX_ETH_MAX_RX_PACKET_1522BYTE		(1<<17)
-#define MV643XX_ETH_MAX_RX_PACKET_1552BYTE		(1<<18)
-#define MV643XX_ETH_MAX_RX_PACKET_9022BYTE		((1<<18) | (1<<17))
-#define MV643XX_ETH_MAX_RX_PACKET_9192BYTE		(1<<19)
-#define MV643XX_ETH_MAX_RX_PACKET_9700BYTE		((1<<19) | (1<<17))
-#define MV643XX_ETH_SET_EXT_LOOPBACK			(1<<20)
-#define MV643XX_ETH_CLR_EXT_LOOPBACK			0
-#define MV643XX_ETH_SET_FULL_DUPLEX_MODE		(1<<21)
-#define MV643XX_ETH_SET_HALF_DUPLEX_MODE		0
-#define MV643XX_ETH_ENABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX (1<<22)
-#define MV643XX_ETH_DISABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX 0
-#define MV643XX_ETH_SET_GMII_SPEED_TO_10_100		0
-#define MV643XX_ETH_SET_GMII_SPEED_TO_1000		(1<<23)
-#define MV643XX_ETH_SET_MII_SPEED_TO_10			0
-#define MV643XX_ETH_SET_MII_SPEED_TO_100		(1<<24)
-
-#define	MV643XX_ETH_PORT_SERIAL_CONTROL_DEFAULT_VALUE		\
-		MV643XX_ETH_DO_NOT_FORCE_LINK_PASS	|	\
-		MV643XX_ETH_ENABLE_AUTO_NEG_FOR_DUPLX	|	\
-		MV643XX_ETH_DISABLE_AUTO_NEG_FOR_FLOW_CTRL |	\
-		MV643XX_ETH_ADV_SYMMETRIC_FLOW_CTRL	|	\
-		MV643XX_ETH_FORCE_FC_MODE_NO_PAUSE_DIS_TX |	\
-		MV643XX_ETH_FORCE_BP_MODE_NO_JAM	|	\
-		(1<<9)	/* reserved */			|	\
-		MV643XX_ETH_DO_NOT_FORCE_LINK_FAIL	|	\
-		MV643XX_ETH_RETRANSMIT_16_ATTEMPTS	|	\
-		MV643XX_ETH_ENABLE_AUTO_NEG_SPEED_GMII	|	\
-		MV643XX_ETH_DTE_ADV_0			|	\
-		MV643XX_ETH_DISABLE_AUTO_NEG_BYPASS	|	\
-		MV643XX_ETH_AUTO_NEG_NO_CHANGE		|	\
-		MV643XX_ETH_MAX_RX_PACKET_9700BYTE	|	\
-		MV643XX_ETH_CLR_EXT_LOOPBACK		|	\
-		MV643XX_ETH_SET_FULL_DUPLEX_MODE	|	\
-		MV643XX_ETH_ENABLE_FLOW_CTRL_TX_RX_IN_FULL_DUPLEX
-
-/* These macros describe Ethernet Serial Status reg (PSR) bits */
-#define MV643XX_ETH_PORT_STATUS_MODE_10_BIT		(1<<0)
-#define MV643XX_ETH_PORT_STATUS_LINK_UP			(1<<1)
-#define MV643XX_ETH_PORT_STATUS_FULL_DUPLEX		(1<<2)
-#define MV643XX_ETH_PORT_STATUS_FLOW_CONTROL		(1<<3)
-#define MV643XX_ETH_PORT_STATUS_GMII_1000		(1<<4)
-#define MV643XX_ETH_PORT_STATUS_MII_100			(1<<5)
-/* PSR bit 6 is undocumented */
-#define MV643XX_ETH_PORT_STATUS_TX_IN_PROGRESS		(1<<7)
-#define MV643XX_ETH_PORT_STATUS_AUTONEG_BYPASSED	(1<<8)
-#define MV643XX_ETH_PORT_STATUS_PARTITION		(1<<9)
-#define MV643XX_ETH_PORT_STATUS_TX_FIFO_EMPTY		(1<<10)
-/* PSR bits 11-31 are reserved */
-
 #define	MV643XX_ETH_PORT_DEFAULT_TRANSMIT_QUEUE_SIZE	800
 #define	MV643XX_ETH_PORT_DEFAULT_RECEIVE_QUEUE_SIZE	400
 
@@ -1285,29 +1102,16 @@
 #define MV643XX_ETH_NAME	"mv643xx_eth"
 
 struct mv643xx_eth_platform_data {
-	/* 
-	 * Non-values for mac_addr, phy_addr, port_config, etc.
-	 * override the default value.  Setting the corresponding
-	 * force_* field, causes the default value to be overridden
-	 * even when zero.
-	 */
-	unsigned int	force_phy_addr:1;
-	unsigned int	force_port_config:1;
-	unsigned int	force_port_config_extend:1;
-	unsigned int	force_port_sdma_config:1;
-	unsigned int	force_port_serial_control:1;
-	int		phy_addr;
-	char		*mac_addr;	/* pointer to mac address */
-	u32		port_config;
-	u32		port_config_extend;
-	u32		port_sdma_config;
-	u32		port_serial_control;
+	/* non-zero values of these fields override defaults */
+	char		*mac_addr;
 	u32		tx_queue_size;
 	u32		rx_queue_size;
 	u32		tx_sram_addr;
 	u32		tx_sram_size;
 	u32		rx_sram_addr;
 	u32		rx_sram_size;
+	/* ethtool_cmd can be used to initialize the phy_addr, speed, etc. */
+	struct ethtool_cmd *ethtool_cmd;
 };
 
 #endif /* __ASM_MV643XX_H */
