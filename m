From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: mv643xx(20/20): Fix promiscuous mode handling
Date: Mon, 28 Mar 2005 17:01:00 -0700
Message-ID: <20050329000100.GT29098@xyzzy>
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

mv643xx_eth_get_config_reg() was reading the wrong register.
mv643xx_eth_set_config_reg() was or'ing instead of setting the
register.  These functions are trivial and both are called only from
mv643xx_eth_set_rx_mode() when changing the promiscuous mode.  Remove both
functions and do the operations directly in mv643xx_eth_set_rx_mode().

Also, maintain promiscuous mode setting across port resets.

Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

Index: linux-2.5-enet/drivers/net/mv643xx_eth.h
===================================================================
--- linux-2.5-enet.orig/drivers/net/mv643xx_eth.h
+++ linux-2.5-enet/drivers/net/mv643xx_eth.h
@@ -474,6 +474,7 @@
 	int port_num;			/* User Ethernet port number	*/
 	u8 port_mac_addr[6];		/* User defined port MAC address.*/
 	u32 port_serial_control;	/* Port serial control value */
+	u32 port_config;		/* Port config register value */
 	struct ethtool_cmd ethtool_cmd;	/* ethtool_cmd used at open */
 	u32 port_tx_queue_command;	/* Port active Tx queues summary*/
 	u32 port_rx_queue_command;	/* Port active Rx queues summary*/
Index: linux-2.5-enet/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.5-enet.orig/drivers/net/mv643xx_eth.c
+++ linux-2.5-enet/drivers/net/mv643xx_eth.c
@@ -390,7 +390,7 @@
 
 	/* Assign port configuration and command. */
 	mv643xx_eth_write(MV643XX_ETH_PORT_CONFIG_REG(port_num),
-			  MV643XX_ETH_PORT_CONFIG_DEFAULT_VALUE);
+			  mp->port_config);
 
 	mv643xx_eth_write(MV643XX_ETH_PORT_CONFIG_EXTEND_REG(port_num),
 			  MV643XX_ETH_PORT_CONFIG_EXTEND_DEFAULT_VALUE);
@@ -683,38 +683,6 @@
 	return 0;
 }
 
-/*
- * This function sets specified bits in the given ethernet
- * configuration register.
- */
-static void mv643xx_eth_set_config_reg(struct net_device *dev,
-				       unsigned int value)
-{
-	struct mv643xx_private *mp = netdev_priv(dev);
-	unsigned int eth_port_num = mp->port_num;
-	unsigned int eth_config_reg;
-
-	eth_config_reg =
-		mv643xx_eth_read(MV643XX_ETH_PORT_CONFIG_REG(eth_port_num));
-	eth_config_reg |= value;
-	mv643xx_eth_write(MV643XX_ETH_PORT_CONFIG_REG(eth_port_num),
-			  eth_config_reg);
-}
-
-/*
- * This function returns the configuration register value of the given
- * ethernet port.
- */
-static unsigned int mv643xx_eth_get_config_reg(struct net_device *dev)
-{
-	struct mv643xx_private *mp = netdev_priv(dev);
-	unsigned int eth_config_reg;
-
-	eth_config_reg =
-	    mv643xx_eth_read(MV643XX_ETH_PORT_CONFIG_EXTEND_REG(mp->port_num));
-	return eth_config_reg;
-}
-
 /*****************************************************************************
  * Device init and shutdown
  *****************************************************************************/
@@ -2027,14 +1995,14 @@
 
 static void mv643xx_eth_set_rx_mode(struct net_device *dev)
 {
-	u32 config_reg;
+	struct mv643xx_private *mp = netdev_priv(dev);
 
-	config_reg = mv643xx_eth_get_config_reg(dev);
 	if (dev->flags & IFF_PROMISC)
-		config_reg |= (u32) MV643XX_ETH_UNICAST_PROMISCUOUS_MODE;
+		mp->port_config |= MV643XX_ETH_UNICAST_PROMISCUOUS_MODE;
 	else
-		config_reg &= ~(u32) MV643XX_ETH_UNICAST_PROMISCUOUS_MODE;
-	mv643xx_eth_set_config_reg(dev, config_reg);
+		mp->port_config &= ~MV643XX_ETH_UNICAST_PROMISCUOUS_MODE;
+	mv643xx_eth_write(MV643XX_ETH_PORT_CONFIG_REG(mp->port_num),
+			  mp->port_config);
 }
 
 /*
@@ -2562,6 +2530,7 @@
 	mp->port_serial_control |= MV643XX_ETH_DISABLE_AUTO_NEG_FOR_FLOW_CTRL |
 				   MV643XX_ETH_SERIAL_PORT_CONTROL_RESERVED   |
 				   MV643XX_ETH_DO_NOT_FORCE_LINK_FAIL;
+	mp->port_config = MV643XX_ETH_PORT_CONFIG_DEFAULT_VALUE;
 	mp->rx_ring_size = MV643XX_ETH_PORT_DEFAULT_RECEIVE_QUEUE_SIZE;
 	mp->tx_ring_size = MV643XX_ETH_PORT_DEFAULT_TRANSMIT_QUEUE_SIZE;
 
