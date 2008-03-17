From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 3/7][MV643XX_ETH] identify ports by struct mv643xx_private *
Date: Mon, 17 Mar 2008 20:18:24 +0100
Message-ID: <20080317191823.GD17828@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>,
	Nicolas Pitre <nico@marvell.com>,
	Tzachi Perelstein <tzachi@marvell.com>,
	Saeed Bishara <saeed@marvell.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:37945 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752754AbYCQTS0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 15:18:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of identifying individual mv643xx ethernet ports by only
their port number, identify them by their struct mv643xx_private *,
as just a port number has no meaning when there are multiple
mv643xx_eth silicon blocks in the system.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Index: linux-2.6.25-rc6/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.6.25-rc6.orig/drivers/net/mv643xx_eth.c
+++ linux-2.6.25-rc6/drivers/net/mv643xx_eth.c
@@ -564,42 +564,44 @@ struct mv643xx_private {
 
 /* Static function declarations */
 static void eth_port_init(struct mv643xx_private *mp);
-static void eth_port_reset(unsigned int eth_port_num);
+static void eth_port_reset(struct mv643xx_private *mp);
 static void eth_port_start(struct net_device *dev);
 
-static void ethernet_phy_reset(unsigned int eth_port_num);
+static void ethernet_phy_reset(struct mv643xx_private *mp);
 
-static void eth_port_write_smi_reg(unsigned int eth_port_num,
+static void eth_port_write_smi_reg(struct mv643xx_private *mp,
 				   unsigned int phy_reg, unsigned int value);
 
-static void eth_port_read_smi_reg(unsigned int eth_port_num,
+static void eth_port_read_smi_reg(struct mv643xx_private *mp,
 				  unsigned int phy_reg, unsigned int *value);
 
-static void eth_clear_mib_counters(unsigned int eth_port_num);
+static void eth_clear_mib_counters(struct mv643xx_private *mp);
 
 static ETH_FUNC_RET_STATUS eth_port_receive(struct mv643xx_private *mp,
 					    struct pkt_info *p_pkt_info);
 static ETH_FUNC_RET_STATUS eth_rx_return_buff(struct mv643xx_private *mp,
 					      struct pkt_info *p_pkt_info);
 
-static void eth_port_uc_addr_get(unsigned int port_num, unsigned char *p_addr);
-static void eth_port_uc_addr_set(unsigned int port_num, unsigned char *p_addr);
+static void eth_port_uc_addr_get(struct mv643xx_private *mp,
+				 unsigned char *p_addr);
+static void eth_port_uc_addr_set(struct mv643xx_private *mp,
+				 unsigned char *p_addr);
 static void eth_port_set_multicast_list(struct net_device *);
-static void mv643xx_eth_port_enable_tx(unsigned int port_num,
+static void mv643xx_eth_port_enable_tx(struct mv643xx_private *mp,
 						unsigned int queues);
-static void mv643xx_eth_port_enable_rx(unsigned int port_num,
+static void mv643xx_eth_port_enable_rx(struct mv643xx_private *mp,
 						unsigned int queues);
-static unsigned int mv643xx_eth_port_disable_tx(unsigned int port_num);
-static unsigned int mv643xx_eth_port_disable_rx(unsigned int port_num);
+static unsigned int mv643xx_eth_port_disable_tx(struct mv643xx_private *mp);
+static unsigned int mv643xx_eth_port_disable_rx(struct mv643xx_private *mp);
 static int mv643xx_eth_open(struct net_device *);
 static int mv643xx_eth_stop(struct net_device *);
-static void eth_port_init_mac_tables(unsigned int eth_port_num);
+static void eth_port_init_mac_tables(struct mv643xx_private *mp);
 #ifdef MV643XX_NAPI
 static int mv643xx_poll(struct napi_struct *napi, int budget);
 #endif
-static int ethernet_phy_get(unsigned int eth_port_num);
-static void ethernet_phy_set(unsigned int eth_port_num, int phy_addr);
-static int ethernet_phy_detect(unsigned int eth_port_num);
+static int ethernet_phy_get(struct mv643xx_private *mp);
+static void ethernet_phy_set(struct mv643xx_private *mp, int phy_addr);
+static int ethernet_phy_detect(struct mv643xx_private *mp);
 static int mv643xx_mdio_read(struct net_device *dev, int phy_id, int location);
 static void mv643xx_mdio_write(struct net_device *dev, int phy_id, int location, int val);
 static int mv643xx_eth_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
@@ -726,10 +728,9 @@ static inline void mv643xx_eth_rx_refill
 static void mv643xx_eth_update_mac_address(struct net_device *dev)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
-	unsigned int port_num = mp->port_num;
 
-	eth_port_init_mac_tables(port_num);
-	eth_port_uc_addr_set(port_num, dev->dev_addr);
+	eth_port_init_mac_tables(mp);
+	eth_port_uc_addr_set(mp, dev->dev_addr);
 }
 
 /*
@@ -811,7 +812,7 @@ static void mv643xx_eth_tx_timeout_task(
 
 	netif_stop_queue(dev);
 
-	eth_port_reset(mp->port_num);
+	eth_port_reset(mp);
 	eth_port_start(dev);
 
 	if (mp->tx_ring_size - mp->tx_desc_count >= MAX_DESCS_PER_SKB)
@@ -1011,14 +1012,14 @@ static void mv643xx_eth_update_pscr(stru
 		if ((o_pscr & SERIAL_PORT_ENABLE) == 0)
 			mv_write(PORT_SERIAL_CONTROL_REG(port_num), n_pscr);
 		else {
-			queues = mv643xx_eth_port_disable_tx(port_num);
+			queues = mv643xx_eth_port_disable_tx(mp);
 
 			o_pscr &= ~SERIAL_PORT_ENABLE;
 			mv_write(PORT_SERIAL_CONTROL_REG(port_num), o_pscr);
 			mv_write(PORT_SERIAL_CONTROL_REG(port_num), n_pscr);
 			mv_write(PORT_SERIAL_CONTROL_REG(port_num), n_pscr);
 			if (queues)
-				mv643xx_eth_port_enable_tx(port_num, queues);
+				mv643xx_eth_port_enable_tx(mp, queues);
 		}
 	}
 }
@@ -1059,8 +1060,7 @@ static irqreturn_t mv643xx_eth_int_handl
 		if (mii_link_ok(&mp->mii)) {
 			mii_ethtool_gset(&mp->mii, &cmd);
 			mv643xx_eth_update_pscr(dev, &cmd);
-			mv643xx_eth_port_enable_tx(port_num,
-						   ETH_TX_QUEUES_ENABLED);
+			mv643xx_eth_port_enable_tx(mp, ETH_TX_QUEUES_ENABLED);
 			if (!netif_carrier_ok(dev)) {
 				netif_carrier_on(dev);
 				if (mp->tx_ring_size - mp->tx_desc_count >=
@@ -1114,7 +1114,7 @@ static irqreturn_t mv643xx_eth_int_handl
  *	, and the required delay of the interrupt in usec.
  *
  * INPUT:
- *	unsigned int eth_port_num	Ethernet port number
+ *	struct mv643xx_private *mp	Ethernet port
  *	unsigned int t_clk		t_clk of the MV-643xx chip in HZ units
  *	unsigned int delay		Delay in usec
  *
@@ -1125,15 +1125,16 @@ static irqreturn_t mv643xx_eth_int_handl
  *	The interrupt coalescing value set in the gigE port.
  *
  */
-static unsigned int eth_port_set_rx_coal(unsigned int eth_port_num,
+static unsigned int eth_port_set_rx_coal(struct mv643xx_private *mp,
 					unsigned int t_clk, unsigned int delay)
 {
+	unsigned int port_num = mp->port_num;
 	unsigned int coal = ((t_clk / 1000000) * delay) / 64;
 
 	/* Set RX Coalescing mechanism */
-	mv_write(SDMA_CONFIG_REG(eth_port_num),
+	mv_write(SDMA_CONFIG_REG(port_num),
 		((coal & 0x3fff) << 8) |
-		(mv_read(SDMA_CONFIG_REG(eth_port_num))
+		(mv_read(SDMA_CONFIG_REG(port_num))
 			& 0xffc000ff));
 
 	return coal;
@@ -1152,7 +1153,7 @@ static unsigned int eth_port_set_rx_coal
  *	MV-643xx chip and the required delay in the interrupt in uSec
  *
  * INPUT:
- *	unsigned int eth_port_num	Ethernet port number
+ *	struct mv643xx_private *mp	Ethernet port
  *	unsigned int t_clk		t_clk of the MV-643xx chip in HZ units
  *	unsigned int delay		Delay in uSeconds
  *
@@ -1163,13 +1164,14 @@ static unsigned int eth_port_set_rx_coal
  *	The interrupt coalescing value set in the gigE port.
  *
  */
-static unsigned int eth_port_set_tx_coal(unsigned int eth_port_num,
+static unsigned int eth_port_set_tx_coal(struct mv643xx_private *mp,
 					unsigned int t_clk, unsigned int delay)
 {
-	unsigned int coal;
-	coal = ((t_clk / 1000000) * delay) / 64;
+	unsigned int coal = ((t_clk / 1000000) * delay) / 64;
+
 	/* Set TX Coalescing mechanism */
-	mv_write(TX_FIFO_URGENT_THRESHOLD_REG(eth_port_num), coal << 4);
+	mv_write(TX_FIFO_URGENT_THRESHOLD_REG(mp->port_num), coal << 4);
+
 	return coal;
 }
 
@@ -1408,11 +1410,11 @@ static int mv643xx_eth_open(struct net_d
 
 #ifdef MV643XX_COAL
 	mp->rx_int_coal =
-		eth_port_set_rx_coal(port_num, 133000000, MV643XX_RX_COAL);
+		eth_port_set_rx_coal(mp, 133000000, MV643XX_RX_COAL);
 #endif
 
 	mp->tx_int_coal =
-		eth_port_set_tx_coal(port_num, 133000000, MV643XX_TX_COAL);
+		eth_port_set_tx_coal(mp, 133000000, MV643XX_TX_COAL);
 
 	/* Unmask phy and link status changes interrupts */
 	mv_write(INTERRUPT_EXTEND_MASK_REG(port_num), ETH_INT_UNMASK_ALL_EXT);
@@ -1437,7 +1439,7 @@ static void mv643xx_eth_free_tx_rings(st
 	struct mv643xx_private *mp = netdev_priv(dev);
 
 	/* Stop Tx Queues */
-	mv643xx_eth_port_disable_tx(mp->port_num);
+	mv643xx_eth_port_disable_tx(mp);
 
 	/* Free outstanding skb's on TX ring */
 	mv643xx_eth_free_all_tx_descs(dev);
@@ -1455,11 +1457,10 @@ static void mv643xx_eth_free_tx_rings(st
 static void mv643xx_eth_free_rx_rings(struct net_device *dev)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
-	unsigned int port_num = mp->port_num;
 	int curr;
 
 	/* Stop RX Queues */
-	mv643xx_eth_port_disable_rx(port_num);
+	mv643xx_eth_port_disable_rx(mp);
 
 	/* Free preallocated skb's on RX rings */
 	for (curr = 0; mp->rx_desc_count && curr < mp->rx_ring_size; curr++) {
@@ -1508,7 +1509,7 @@ static int mv643xx_eth_stop(struct net_d
 	netif_carrier_off(dev);
 	netif_stop_queue(dev);
 
-	eth_port_reset(mp->port_num);
+	eth_port_reset(mp);
 
 	mv643xx_eth_free_tx_rings(dev);
 	mv643xx_eth_free_rx_rings(dev);
@@ -1701,7 +1702,7 @@ static void eth_tx_submit_descs_for_skb(
 
 	/* ensure all descriptors are written before poking hardware */
 	wmb();
-	mv643xx_eth_port_enable_tx(mp->port_num, ETH_TX_QUEUES_ENABLED);
+	mv643xx_eth_port_enable_tx(mp, ETH_TX_QUEUES_ENABLED);
 
 	mp->tx_desc_count += nr_frags + 1;
 }
@@ -1876,7 +1877,7 @@ static int mv643xx_eth_probe(struct plat
 	port_num = mp->port_num = pd->port_number;
 
 	/* set default config values */
-	eth_port_uc_addr_get(port_num, dev->dev_addr);
+	eth_port_uc_addr_get(mp, dev->dev_addr);
 	mp->rx_ring_size = PORT_DEFAULT_RECEIVE_QUEUE_SIZE;
 	mp->tx_ring_size = PORT_DEFAULT_TRANSMIT_QUEUE_SIZE;
 
@@ -1884,7 +1885,7 @@ static int mv643xx_eth_probe(struct plat
 		memcpy(dev->dev_addr, pd->mac_addr, 6);
 
 	if (pd->phy_addr || pd->force_phy_addr)
-		ethernet_phy_set(port_num, pd->phy_addr);
+		ethernet_phy_set(mp, pd->phy_addr);
 
 	if (pd->rx_queue_size)
 		mp->rx_ring_size = pd->rx_queue_size;
@@ -1909,19 +1910,19 @@ static int mv643xx_eth_probe(struct plat
 	mp->mii.dev = dev;
 	mp->mii.mdio_read = mv643xx_mdio_read;
 	mp->mii.mdio_write = mv643xx_mdio_write;
-	mp->mii.phy_id = ethernet_phy_get(port_num);
+	mp->mii.phy_id = ethernet_phy_get(mp);
 	mp->mii.phy_id_mask = 0x3f;
 	mp->mii.reg_num_mask = 0x1f;
 
-	err = ethernet_phy_detect(port_num);
+	err = ethernet_phy_detect(mp);
 	if (err) {
 		pr_debug("MV643xx ethernet port %d: "
 					"No PHY detected at addr %d\n",
-					port_num, ethernet_phy_get(port_num));
+					port_num, ethernet_phy_get(mp));
 		goto out;
 	}
 
-	ethernet_phy_reset(port_num);
+	ethernet_phy_reset(mp);
 	mp->mii.supports_gmii = mii_check_gmii_support(&mp->mii);
 	mv643xx_init_ethtool_cmd(dev, mp->mii.phy_id, speed, duplex, &cmd);
 	mv643xx_eth_update_pscr(dev, &cmd);
@@ -2016,7 +2017,7 @@ static void mv643xx_eth_shutdown(struct 
 	mv_write(INTERRUPT_MASK_REG(port_num), 0);
 	mv_read (INTERRUPT_MASK_REG(port_num));
 
-	eth_port_reset(port_num);
+	eth_port_reset(mp);
 }
 
 static struct platform_driver mv643xx_eth_driver = {
@@ -2205,12 +2206,9 @@ MODULE_ALIAS("platform:mv643xx_eth");
  *		return_info	Tx/Rx user resource return information.
  */
 
-/* PHY routines */
-static int ethernet_phy_get(unsigned int eth_port_num);
-static void ethernet_phy_set(unsigned int eth_port_num, int phy_addr);
-
 /* Ethernet Port routines */
-static void eth_port_set_filter_table_entry(int table, unsigned char entry);
+static void eth_port_set_filter_table_entry(struct mv643xx_private *mp,
+					    int table, unsigned char entry);
 
 /*
  * eth_port_init - Initialize the Ethernet port driver
@@ -2240,9 +2238,9 @@ static void eth_port_init(struct mv643xx
 {
 	mp->rx_resource_err = 0;
 
-	eth_port_reset(mp->port_num);
+	eth_port_reset(mp);
 
-	eth_port_init_mac_tables(mp->port_num);
+	eth_port_init_mac_tables(mp);
 }
 
 /*
@@ -2291,7 +2289,7 @@ static void eth_port_start(struct net_de
 		(u32)((struct eth_rx_desc *)mp->rx_desc_dma + rx_curr_desc));
 
 	/* Add the assigned Ethernet address to the port's address table */
-	eth_port_uc_addr_set(port_num, dev->dev_addr);
+	eth_port_uc_addr_set(mp, dev->dev_addr);
 
 	/* Assign port configuration and command. */
 	mv_write(PORT_CONFIG_REG(port_num),
@@ -2321,22 +2319,24 @@ static void eth_port_start(struct net_de
 			  PORT_SDMA_CONFIG_DEFAULT_VALUE);
 
 	/* Enable port Rx. */
-	mv643xx_eth_port_enable_rx(port_num, ETH_RX_QUEUES_ENABLED);
+	mv643xx_eth_port_enable_rx(mp, ETH_RX_QUEUES_ENABLED);
 
 	/* Disable port bandwidth limits by clearing MTU register */
 	mv_write(MAXIMUM_TRANSMIT_UNIT(port_num), 0);
 
 	/* save phy settings across reset */
 	mv643xx_get_settings(dev, &ethtool_cmd);
-	ethernet_phy_reset(mp->port_num);
+	ethernet_phy_reset(mp);
 	mv643xx_set_settings(dev, &ethtool_cmd);
 }
 
 /*
  * eth_port_uc_addr_set - Write a MAC address into the port's hw registers
  */
-static void eth_port_uc_addr_set(unsigned int port_num, unsigned char *p_addr)
+static void eth_port_uc_addr_set(struct mv643xx_private *mp,
+				 unsigned char *p_addr)
 {
+	unsigned int port_num = mp->port_num;
 	unsigned int mac_h;
 	unsigned int mac_l;
 	int table;
@@ -2350,14 +2350,16 @@ static void eth_port_uc_addr_set(unsigne
 
 	/* Accept frames with this address */
 	table = DA_FILTER_UNICAST_TABLE_BASE(port_num);
-	eth_port_set_filter_table_entry(table, p_addr[5] & 0x0f);
+	eth_port_set_filter_table_entry(mp, table, p_addr[5] & 0x0f);
 }
 
 /*
  * eth_port_uc_addr_get - Read the MAC address from the port's hw registers
  */
-static void eth_port_uc_addr_get(unsigned int port_num, unsigned char *p_addr)
+static void eth_port_uc_addr_get(struct mv643xx_private *mp,
+				 unsigned char *p_addr)
 {
+	unsigned int port_num = mp->port_num;
 	unsigned int mac_h;
 	unsigned int mac_l;
 
@@ -2381,7 +2383,8 @@ static void eth_port_uc_addr_get(unsigne
  *	3-1	Queue			(ETH_Q0=0)
  *	7-4	Reserved = 0;
  */
-static void eth_port_set_filter_table_entry(int table, unsigned char entry)
+static void eth_port_set_filter_table_entry(struct mv643xx_private *mp,
+					    int table, unsigned char entry)
 {
 	unsigned int table_reg;
 	unsigned int tbl_offset;
@@ -2410,8 +2413,9 @@ static void eth_port_set_filter_table_en
  * In either case, eth_port_set_filter_table_entry() is then called
  * to set to set the actual table entry.
  */
-static void eth_port_mc_addr(unsigned int eth_port_num, unsigned char *p_addr)
+static void eth_port_mc_addr(struct mv643xx_private *mp, unsigned char *p_addr)
 {
+	unsigned int port_num = mp->port_num;
 	unsigned int mac_h;
 	unsigned int mac_l;
 	unsigned char crc_result = 0;
@@ -2422,9 +2426,8 @@ static void eth_port_mc_addr(unsigned in
 
 	if ((p_addr[0] == 0x01) && (p_addr[1] == 0x00) &&
 	    (p_addr[2] == 0x5E) && (p_addr[3] == 0x00) && (p_addr[4] == 0x00)) {
-		table = DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE
-					(eth_port_num);
-		eth_port_set_filter_table_entry(table, p_addr[5]);
+		table = DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(port_num);
+		eth_port_set_filter_table_entry(mp, table, p_addr[5]);
 		return;
 	}
 
@@ -2496,8 +2499,8 @@ static void eth_port_mc_addr(unsigned in
 	for (i = 0; i < 8; i++)
 		crc_result = crc_result | (crc[i] << i);
 
-	table = DA_FILTER_OTHER_MULTICAST_TABLE_BASE(eth_port_num);
-	eth_port_set_filter_table_entry(table, crc_result);
+	table = DA_FILTER_OTHER_MULTICAST_TABLE_BASE(port_num);
+	eth_port_set_filter_table_entry(mp, table, crc_result);
 }
 
 /*
@@ -2559,7 +2562,7 @@ static void eth_port_set_multicast_list(
 			(i < 256) && (mc_list != NULL) && (i < dev->mc_count);
 			i++, mc_list = mc_list->next)
 		if (mc_list->dmi_addrlen == 6)
-			eth_port_mc_addr(eth_port_num, mc_list->dmi_addr);
+			eth_port_mc_addr(mp, mc_list->dmi_addr);
 }
 
 /*
@@ -2570,7 +2573,7 @@ static void eth_port_set_multicast_list(
  *	Other Multicast) and set each entry to 0.
  *
  * INPUT:
- *	unsigned int	eth_port_num	Ethernet Port number.
+ *	struct mv643xx_private *mp	Ethernet Port.
  *
  * OUTPUT:
  *	Multicast and Unicast packets are rejected.
@@ -2578,22 +2581,23 @@ static void eth_port_set_multicast_list(
  * RETURN:
  *	None.
  */
-static void eth_port_init_mac_tables(unsigned int eth_port_num)
+static void eth_port_init_mac_tables(struct mv643xx_private *mp)
 {
+	unsigned int port_num = mp->port_num;
 	int table_index;
 
 	/* Clear DA filter unicast table (Ex_dFUT) */
 	for (table_index = 0; table_index <= 0xC; table_index += 4)
-		mv_write(DA_FILTER_UNICAST_TABLE_BASE
-					(eth_port_num) + table_index, 0);
+		mv_write(DA_FILTER_UNICAST_TABLE_BASE(port_num) +
+					table_index, 0);
 
 	for (table_index = 0; table_index <= 0xFC; table_index += 4) {
 		/* Clear DA filter special multicast table (Ex_dFSMT) */
-		mv_write(DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE
-					(eth_port_num) + table_index, 0);
+		mv_write(DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(port_num) +
+					table_index, 0);
 		/* Clear DA filter other multicast table (Ex_dFOMT) */
-		mv_write(DA_FILTER_OTHER_MULTICAST_TABLE_BASE
-					(eth_port_num) + table_index, 0);
+		mv_write(DA_FILTER_OTHER_MULTICAST_TABLE_BASE(port_num) +
+					table_index, 0);
 	}
 }
 
@@ -2605,7 +2609,7 @@ static void eth_port_init_mac_tables(uns
  *	A read from the MIB counter will reset the counter.
  *
  * INPUT:
- *	unsigned int	eth_port_num	Ethernet Port number.
+ *	struct mv643xx_private *mp	Ethernet Port.
  *
  * OUTPUT:
  *	After reading all MIB counters, the counters resets.
@@ -2614,14 +2618,15 @@ static void eth_port_init_mac_tables(uns
  *	MIB counter value.
  *
  */
-static void eth_clear_mib_counters(unsigned int eth_port_num)
+static void eth_clear_mib_counters(struct mv643xx_private *mp)
 {
+	unsigned int port_num = mp->port_num;
 	int i;
 
 	/* Perform dummy reads from MIB counters */
 	for (i = ETH_MIB_GOOD_OCTETS_RECEIVED_LOW; i < ETH_MIB_LATE_COLLISION;
 									i += 4)
-		mv_read(MIB_COUNTERS_BASE(eth_port_num) + i);
+		mv_read(MIB_COUNTERS_BASE(port_num) + i);
 }
 
 static inline u32 read_mib(struct mv643xx_private *mp, int offset)
@@ -2662,7 +2667,7 @@ static void eth_update_mib_counters(stru
  *	the specified port.
  *
  * INPUT:
- *	unsigned int	eth_port_num	Ethernet Port number.
+ *	struct mv643xx_private *mp	Ethernet Port.
  *
  * OUTPUT:
  *	None
@@ -2672,22 +2677,22 @@ static void eth_update_mib_counters(stru
  *	-ENODEV on failure
  *
  */
-static int ethernet_phy_detect(unsigned int port_num)
+static int ethernet_phy_detect(struct mv643xx_private *mp)
 {
 	unsigned int phy_reg_data0;
 	int auto_neg;
 
-	eth_port_read_smi_reg(port_num, 0, &phy_reg_data0);
+	eth_port_read_smi_reg(mp, 0, &phy_reg_data0);
 	auto_neg = phy_reg_data0 & 0x1000;
 	phy_reg_data0 ^= 0x1000;	/* invert auto_neg */
-	eth_port_write_smi_reg(port_num, 0, phy_reg_data0);
+	eth_port_write_smi_reg(mp, 0, phy_reg_data0);
 
-	eth_port_read_smi_reg(port_num, 0, &phy_reg_data0);
+	eth_port_read_smi_reg(mp, 0, &phy_reg_data0);
 	if ((phy_reg_data0 & 0x1000) == auto_neg)
 		return -ENODEV;				/* change didn't take */
 
 	phy_reg_data0 ^= 0x1000;
-	eth_port_write_smi_reg(port_num, 0, phy_reg_data0);
+	eth_port_write_smi_reg(mp, 0, phy_reg_data0);
 	return 0;
 }
 
@@ -2698,7 +2703,7 @@ static int ethernet_phy_detect(unsigned 
  *	This routine returns the given ethernet port PHY address.
  *
  * INPUT:
- *	unsigned int	eth_port_num	Ethernet Port number.
+ *	struct mv643xx_private *mp	Ethernet Port.
  *
  * OUTPUT:
  *	None.
@@ -2707,13 +2712,13 @@ static int ethernet_phy_detect(unsigned 
  *	PHY address.
  *
  */
-static int ethernet_phy_get(unsigned int eth_port_num)
+static int ethernet_phy_get(struct mv643xx_private *mp)
 {
 	unsigned int reg_data;
 
 	reg_data = mv_read(PHY_ADDR_REG);
 
-	return ((reg_data >> (5 * eth_port_num)) & 0x1f);
+	return ((reg_data >> (5 * mp->port_num)) & 0x1f);
 }
 
 /*
@@ -2723,7 +2728,7 @@ static int ethernet_phy_get(unsigned int
  *	This routine sets the given ethernet port PHY address.
  *
  * INPUT:
- *	unsigned int	eth_port_num	Ethernet Port number.
+ *	struct mv643xx_private *mp	Ethernet Port.
  *	int		phy_addr	PHY address.
  *
  * OUTPUT:
@@ -2733,10 +2738,10 @@ static int ethernet_phy_get(unsigned int
  *	None.
  *
  */
-static void ethernet_phy_set(unsigned int eth_port_num, int phy_addr)
+static void ethernet_phy_set(struct mv643xx_private *mp, int phy_addr)
 {
 	u32 reg_data;
-	int addr_shift = 5 * eth_port_num;
+	int addr_shift = 5 * mp->port_num;
 
 	reg_data = mv_read(PHY_ADDR_REG);
 	reg_data &= ~(0x1f << addr_shift);
@@ -2751,7 +2756,7 @@ static void ethernet_phy_set(unsigned in
  *	This routine utilizes the SMI interface to reset the ethernet port PHY.
  *
  * INPUT:
- *	unsigned int	eth_port_num	Ethernet Port number.
+ *	struct mv643xx_private *mp	Ethernet Port.
  *
  * OUTPUT:
  *	The PHY is reset.
@@ -2760,36 +2765,37 @@ static void ethernet_phy_set(unsigned in
  *	None.
  *
  */
-static void ethernet_phy_reset(unsigned int eth_port_num)
+static void ethernet_phy_reset(struct mv643xx_private *mp)
 {
 	unsigned int phy_reg_data;
 
 	/* Reset the PHY */
-	eth_port_read_smi_reg(eth_port_num, 0, &phy_reg_data);
+	eth_port_read_smi_reg(mp, 0, &phy_reg_data);
 	phy_reg_data |= 0x8000;	/* Set bit 15 to reset the PHY */
-	eth_port_write_smi_reg(eth_port_num, 0, phy_reg_data);
+	eth_port_write_smi_reg(mp, 0, phy_reg_data);
 
 	/* wait for PHY to come out of reset */
 	do {
 		udelay(1);
-		eth_port_read_smi_reg(eth_port_num, 0, &phy_reg_data);
+		eth_port_read_smi_reg(mp, 0, &phy_reg_data);
 	} while (phy_reg_data & 0x8000);
 }
 
-static void mv643xx_eth_port_enable_tx(unsigned int port_num,
+static void mv643xx_eth_port_enable_tx(struct mv643xx_private *mp,
 					unsigned int queues)
 {
-	mv_write(TRANSMIT_QUEUE_COMMAND_REG(port_num), queues);
+	mv_write(TRANSMIT_QUEUE_COMMAND_REG(mp->port_num), queues);
 }
 
-static void mv643xx_eth_port_enable_rx(unsigned int port_num,
+static void mv643xx_eth_port_enable_rx(struct mv643xx_private *mp,
 					unsigned int queues)
 {
-	mv_write(RECEIVE_QUEUE_COMMAND_REG(port_num), queues);
+	mv_write(RECEIVE_QUEUE_COMMAND_REG(mp->port_num), queues);
 }
 
-static unsigned int mv643xx_eth_port_disable_tx(unsigned int port_num)
+static unsigned int mv643xx_eth_port_disable_tx(struct mv643xx_private *mp)
 {
+	unsigned int port_num = mp->port_num;
 	u32 queues;
 
 	/* Stop Tx port activity. Check port Tx activity. */
@@ -2812,8 +2818,9 @@ static unsigned int mv643xx_eth_port_dis
 	return queues;
 }
 
-static unsigned int mv643xx_eth_port_disable_rx(unsigned int port_num)
+static unsigned int mv643xx_eth_port_disable_rx(struct mv643xx_private *mp)
 {
+	unsigned int port_num = mp->port_num;
 	u32 queues;
 
 	/* Stop Rx port activity. Check port Rx activity. */
@@ -2840,7 +2847,7 @@ static unsigned int mv643xx_eth_port_dis
  *	idle state after this command is performed and the port is disabled.
  *
  * INPUT:
- *	unsigned int	eth_port_num	Ethernet Port number.
+ *	struct mv643xx_private *mp	Ethernet Port.
  *
  * OUTPUT:
  *	Channel activity is halted.
@@ -2849,15 +2856,16 @@ static unsigned int mv643xx_eth_port_dis
  *	None.
  *
  */
-static void eth_port_reset(unsigned int port_num)
+static void eth_port_reset(struct mv643xx_private *mp)
 {
+	unsigned int port_num = mp->port_num;
 	unsigned int reg_data;
 
-	mv643xx_eth_port_disable_tx(port_num);
-	mv643xx_eth_port_disable_rx(port_num);
+	mv643xx_eth_port_disable_tx(mp);
+	mv643xx_eth_port_disable_rx(mp);
 
 	/* Clear all MIB counters */
-	eth_clear_mib_counters(port_num);
+	eth_clear_mib_counters(mp);
 
 	/* Reset the Enable bit in the Configuration Register */
 	reg_data = mv_read(PORT_SERIAL_CONTROL_REG(port_num));
@@ -2876,7 +2884,7 @@ static void eth_port_reset(unsigned int 
  *	order to perform PHY register read.
  *
  * INPUT:
- *	unsigned int	port_num	Ethernet Port number.
+ *	struct mv643xx_private *mp	Ethernet Port.
  *	unsigned int	phy_reg		PHY register address offset.
  *	unsigned int	*value		Register value buffer.
  *
@@ -2888,10 +2896,10 @@ static void eth_port_reset(unsigned int 
  *	true otherwise.
  *
  */
-static void eth_port_read_smi_reg(unsigned int port_num,
+static void eth_port_read_smi_reg(struct mv643xx_private *mp,
 				unsigned int phy_reg, unsigned int *value)
 {
-	int phy_addr = ethernet_phy_get(port_num);
+	int phy_addr = ethernet_phy_get(mp);
 	unsigned long flags;
 	int i;
 
@@ -2932,7 +2940,7 @@ out:
  *	order to perform writes to PHY registers.
  *
  * INPUT:
- *	unsigned int	eth_port_num	Ethernet Port number.
+ *	struct mv643xx_private *mp	Ethernet Port.
  *	unsigned int	phy_reg		PHY register address offset.
  *	unsigned int	value		Register value.
  *
@@ -2944,14 +2952,14 @@ out:
  *	true otherwise.
  *
  */
-static void eth_port_write_smi_reg(unsigned int eth_port_num,
+static void eth_port_write_smi_reg(struct mv643xx_private *mp,
 				   unsigned int phy_reg, unsigned int value)
 {
 	int phy_addr;
 	int i;
 	unsigned long flags;
 
-	phy_addr = ethernet_phy_get(eth_port_num);
+	phy_addr = ethernet_phy_get(mp);
 
 	/* the SMI register is a shared resource */
 	spin_lock_irqsave(&mv643xx_eth_phy_lock, flags);
@@ -2977,17 +2985,17 @@ out:
  */
 static int mv643xx_mdio_read(struct net_device *dev, int phy_id, int location)
 {
-	int val;
 	struct mv643xx_private *mp = netdev_priv(dev);
+	int val;
 
-	eth_port_read_smi_reg(mp->port_num, location, &val);
+	eth_port_read_smi_reg(mp, location, &val);
 	return val;
 }
 
 static void mv643xx_mdio_write(struct net_device *dev, int phy_id, int location, int val)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
-	eth_port_write_smi_reg(mp->port_num, location, val);
+	eth_port_write_smi_reg(mp, location, val);
 }
 
 /*
