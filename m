From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 4/7][MV643XX_ETH] pass port identifier to register accessors
Date: Mon, 17 Mar 2008 20:18:40 +0100
Message-ID: <20080317191840.GE17828@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>,
	Nicolas Pitre <nico@marvell.com>,
	Tzachi Perelstein <tzachi@marvell.com>,
	Saeed Bishara <saeed@marvell.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:37949 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752884AbYCQTSn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 15:18:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pass a struct mv643xx_private * to the register accessor functions,
as a preparation for having multiple mv643xx_eth silicon blocks.

(Since this causes some 80 column straddling, and the mv_ prefix
is useless anyway, rename mv_read to rdl and mv_write to wrl to
compensate.)

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Index: linux-2.6.25-rc6/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.6.25-rc6.orig/drivers/net/mv643xx_eth.c
+++ linux-2.6.25-rc6/drivers/net/mv643xx_eth.c
@@ -615,12 +615,12 @@ static void __iomem *mv643xx_eth_base;
 /* used to protect SMI_REG, which is shared across ports */
 static DEFINE_SPINLOCK(mv643xx_eth_phy_lock);
 
-static inline u32 mv_read(int offset)
+static inline u32 rdl(struct mv643xx_private *mp, int offset)
 {
 	return readl(mv643xx_eth_base + offset);
 }
 
-static inline void mv_write(int offset, u32 data)
+static inline void wrl(struct mv643xx_private *mp, int offset, u32 data)
 {
 	writel(data, mv643xx_eth_base + offset);
 }
@@ -746,12 +746,12 @@ static void mv643xx_eth_set_rx_mode(stru
 	struct mv643xx_private *mp = netdev_priv(dev);
 	u32 config_reg;
 
-	config_reg = mv_read(PORT_CONFIG_REG(mp->port_num));
+	config_reg = rdl(mp, PORT_CONFIG_REG(mp->port_num));
 	if (dev->flags & IFF_PROMISC)
 		config_reg |= (u32) UNICAST_PROMISCUOUS_MODE;
 	else
 		config_reg &= ~(u32) UNICAST_PROMISCUOUS_MODE;
-	mv_write(PORT_CONFIG_REG(mp->port_num), config_reg);
+	wrl(mp, PORT_CONFIG_REG(mp->port_num), config_reg);
 
 	eth_port_set_multicast_list(dev);
 }
@@ -987,7 +987,7 @@ static void mv643xx_eth_update_pscr(stru
 	u32 o_pscr, n_pscr;
 	unsigned int queues;
 
-	o_pscr = mv_read(PORT_SERIAL_CONTROL_REG(port_num));
+	o_pscr = rdl(mp, PORT_SERIAL_CONTROL_REG(port_num));
 	n_pscr = o_pscr;
 
 	/* clear speed, duplex and rx buffer size fields */
@@ -1010,14 +1010,14 @@ static void mv643xx_eth_update_pscr(stru
 
 	if (n_pscr != o_pscr) {
 		if ((o_pscr & SERIAL_PORT_ENABLE) == 0)
-			mv_write(PORT_SERIAL_CONTROL_REG(port_num), n_pscr);
+			wrl(mp, PORT_SERIAL_CONTROL_REG(port_num), n_pscr);
 		else {
 			queues = mv643xx_eth_port_disable_tx(mp);
 
 			o_pscr &= ~SERIAL_PORT_ENABLE;
-			mv_write(PORT_SERIAL_CONTROL_REG(port_num), o_pscr);
-			mv_write(PORT_SERIAL_CONTROL_REG(port_num), n_pscr);
-			mv_write(PORT_SERIAL_CONTROL_REG(port_num), n_pscr);
+			wrl(mp, PORT_SERIAL_CONTROL_REG(port_num), o_pscr);
+			wrl(mp, PORT_SERIAL_CONTROL_REG(port_num), n_pscr);
+			wrl(mp, PORT_SERIAL_CONTROL_REG(port_num), n_pscr);
 			if (queues)
 				mv643xx_eth_port_enable_tx(mp, queues);
 		}
@@ -1043,13 +1043,13 @@ static irqreturn_t mv643xx_eth_int_handl
 	unsigned int port_num = mp->port_num;
 
 	/* Read interrupt cause registers */
-	eth_int_cause = mv_read(INTERRUPT_CAUSE_REG(port_num)) &
+	eth_int_cause = rdl(mp, INTERRUPT_CAUSE_REG(port_num)) &
 						ETH_INT_UNMASK_ALL;
 	if (eth_int_cause & ETH_INT_CAUSE_EXT) {
-		eth_int_cause_ext = mv_read(
+		eth_int_cause_ext = rdl(mp,
 			INTERRUPT_CAUSE_EXTEND_REG(port_num)) &
 						ETH_INT_UNMASK_ALL_EXT;
-		mv_write(INTERRUPT_CAUSE_EXTEND_REG(port_num),
+		wrl(mp, INTERRUPT_CAUSE_EXTEND_REG(port_num),
 							~eth_int_cause_ext);
 	}
 
@@ -1076,10 +1076,10 @@ static irqreturn_t mv643xx_eth_int_handl
 #ifdef MV643XX_NAPI
 	if (eth_int_cause & ETH_INT_CAUSE_RX) {
 		/* schedule the NAPI poll routine to maintain port */
-		mv_write(INTERRUPT_MASK_REG(port_num), ETH_INT_MASK_ALL);
+		wrl(mp, INTERRUPT_MASK_REG(port_num), ETH_INT_MASK_ALL);
 
 		/* wait for previous write to complete */
-		mv_read(INTERRUPT_MASK_REG(port_num));
+		rdl(mp, INTERRUPT_MASK_REG(port_num));
 
 		netif_rx_schedule(dev, &mp->napi);
 	}
@@ -1132,9 +1132,9 @@ static unsigned int eth_port_set_rx_coal
 	unsigned int coal = ((t_clk / 1000000) * delay) / 64;
 
 	/* Set RX Coalescing mechanism */
-	mv_write(SDMA_CONFIG_REG(port_num),
+	wrl(mp, SDMA_CONFIG_REG(port_num),
 		((coal & 0x3fff) << 8) |
-		(mv_read(SDMA_CONFIG_REG(port_num))
+		(rdl(mp, SDMA_CONFIG_REG(port_num))
 			& 0xffc000ff));
 
 	return coal;
@@ -1170,7 +1170,7 @@ static unsigned int eth_port_set_tx_coal
 	unsigned int coal = ((t_clk / 1000000) * delay) / 64;
 
 	/* Set TX Coalescing mechanism */
-	mv_write(TX_FIFO_URGENT_THRESHOLD_REG(mp->port_num), coal << 4);
+	wrl(mp, TX_FIFO_URGENT_THRESHOLD_REG(mp->port_num), coal << 4);
 
 	return coal;
 }
@@ -1307,10 +1307,10 @@ static int mv643xx_eth_open(struct net_d
 	int err;
 
 	/* Clear any pending ethernet port interrupts */
-	mv_write(INTERRUPT_CAUSE_REG(port_num), 0);
-	mv_write(INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
+	wrl(mp, INTERRUPT_CAUSE_REG(port_num), 0);
+	wrl(mp, INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
 	/* wait for previous write to complete */
-	mv_read (INTERRUPT_CAUSE_EXTEND_REG(port_num));
+	rdl(mp, INTERRUPT_CAUSE_EXTEND_REG(port_num));
 
 	err = request_irq(dev->irq, mv643xx_eth_int_handler,
 			IRQF_SHARED | IRQF_SAMPLE_RANDOM, dev->name, dev);
@@ -1417,10 +1417,10 @@ static int mv643xx_eth_open(struct net_d
 		eth_port_set_tx_coal(mp, 133000000, MV643XX_TX_COAL);
 
 	/* Unmask phy and link status changes interrupts */
-	mv_write(INTERRUPT_EXTEND_MASK_REG(port_num), ETH_INT_UNMASK_ALL_EXT);
+	wrl(mp, INTERRUPT_EXTEND_MASK_REG(port_num), ETH_INT_UNMASK_ALL_EXT);
 
 	/* Unmask RX buffer and TX end interrupt */
-	mv_write(INTERRUPT_MASK_REG(port_num), ETH_INT_UNMASK_ALL);
+	wrl(mp, INTERRUPT_MASK_REG(port_num), ETH_INT_UNMASK_ALL);
 
 	return 0;
 
@@ -1499,9 +1499,9 @@ static int mv643xx_eth_stop(struct net_d
 	unsigned int port_num = mp->port_num;
 
 	/* Mask all interrupts on ethernet port */
-	mv_write(INTERRUPT_MASK_REG(port_num), ETH_INT_MASK_ALL);
+	wrl(mp, INTERRUPT_MASK_REG(port_num), ETH_INT_MASK_ALL);
 	/* wait for previous write to complete */
-	mv_read(INTERRUPT_MASK_REG(port_num));
+	rdl(mp, INTERRUPT_MASK_REG(port_num));
 
 #ifdef MV643XX_NAPI
 	napi_disable(&mp->napi);
@@ -1540,15 +1540,15 @@ static int mv643xx_poll(struct napi_stru
 #endif
 
 	work_done = 0;
-	if ((mv_read(RX_CURRENT_QUEUE_DESC_PTR_0(port_num)))
+	if ((rdl(mp, RX_CURRENT_QUEUE_DESC_PTR_0(port_num)))
 	    != (u32) mp->rx_used_desc_q)
 		work_done = mv643xx_eth_receive_queue(dev, budget);
 
 	if (work_done < budget) {
 		netif_rx_complete(dev, napi);
-		mv_write(INTERRUPT_CAUSE_REG(port_num), 0);
-		mv_write(INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
-		mv_write(INTERRUPT_MASK_REG(port_num), ETH_INT_UNMASK_ALL);
+		wrl(mp, INTERRUPT_CAUSE_REG(port_num), 0);
+		wrl(mp, INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
+		wrl(mp, INTERRUPT_MASK_REG(port_num), ETH_INT_UNMASK_ALL);
 	}
 
 	return work_done;
@@ -1754,13 +1754,13 @@ static void mv643xx_netpoll(struct net_d
 	struct mv643xx_private *mp = netdev_priv(netdev);
 	int port_num = mp->port_num;
 
-	mv_write(INTERRUPT_MASK_REG(port_num), ETH_INT_MASK_ALL);
+	wrl(mp, INTERRUPT_MASK_REG(port_num), ETH_INT_MASK_ALL);
 	/* wait for previous write to complete */
-	mv_read(INTERRUPT_MASK_REG(port_num));
+	rdl(mp, INTERRUPT_MASK_REG(port_num));
 
 	mv643xx_eth_int_handler(netdev->irq, netdev);
 
-	mv_write(INTERRUPT_MASK_REG(port_num), ETH_INT_UNMASK_ALL);
+	wrl(mp, INTERRUPT_MASK_REG(port_num), ETH_INT_UNMASK_ALL);
 }
 #endif
 
@@ -2014,8 +2014,8 @@ static void mv643xx_eth_shutdown(struct 
 	unsigned int port_num = mp->port_num;
 
 	/* Mask all interrupts on ethernet port */
-	mv_write(INTERRUPT_MASK_REG(port_num), 0);
-	mv_read (INTERRUPT_MASK_REG(port_num));
+	wrl(mp, INTERRUPT_MASK_REG(port_num), 0);
+	rdl(mp, INTERRUPT_MASK_REG(port_num));
 
 	eth_port_reset(mp);
 }
@@ -2280,28 +2280,28 @@ static void eth_port_start(struct net_de
 
 	/* Assignment of Tx CTRP of given queue */
 	tx_curr_desc = mp->tx_curr_desc_q;
-	mv_write(TX_CURRENT_QUEUE_DESC_PTR_0(port_num),
+	wrl(mp, TX_CURRENT_QUEUE_DESC_PTR_0(port_num),
 		(u32)((struct eth_tx_desc *)mp->tx_desc_dma + tx_curr_desc));
 
 	/* Assignment of Rx CRDP of given queue */
 	rx_curr_desc = mp->rx_curr_desc_q;
-	mv_write(RX_CURRENT_QUEUE_DESC_PTR_0(port_num),
+	wrl(mp, RX_CURRENT_QUEUE_DESC_PTR_0(port_num),
 		(u32)((struct eth_rx_desc *)mp->rx_desc_dma + rx_curr_desc));
 
 	/* Add the assigned Ethernet address to the port's address table */
 	eth_port_uc_addr_set(mp, dev->dev_addr);
 
 	/* Assign port configuration and command. */
-	mv_write(PORT_CONFIG_REG(port_num),
+	wrl(mp, PORT_CONFIG_REG(port_num),
 			  PORT_CONFIG_DEFAULT_VALUE);
 
-	mv_write(PORT_CONFIG_EXTEND_REG(port_num),
+	wrl(mp, PORT_CONFIG_EXTEND_REG(port_num),
 			  PORT_CONFIG_EXTEND_DEFAULT_VALUE);
 
-	pscr = mv_read(PORT_SERIAL_CONTROL_REG(port_num));
+	pscr = rdl(mp, PORT_SERIAL_CONTROL_REG(port_num));
 
 	pscr &= ~(SERIAL_PORT_ENABLE | FORCE_LINK_PASS);
-	mv_write(PORT_SERIAL_CONTROL_REG(port_num), pscr);
+	wrl(mp, PORT_SERIAL_CONTROL_REG(port_num), pscr);
 
 	pscr |= DISABLE_AUTO_NEG_FOR_FLOW_CTRL |
 		DISABLE_AUTO_NEG_SPEED_GMII    |
@@ -2309,20 +2309,20 @@ static void eth_port_start(struct net_de
 		DO_NOT_FORCE_LINK_FAIL	   |
 		SERIAL_PORT_CONTROL_RESERVED;
 
-	mv_write(PORT_SERIAL_CONTROL_REG(port_num), pscr);
+	wrl(mp, PORT_SERIAL_CONTROL_REG(port_num), pscr);
 
 	pscr |= SERIAL_PORT_ENABLE;
-	mv_write(PORT_SERIAL_CONTROL_REG(port_num), pscr);
+	wrl(mp, PORT_SERIAL_CONTROL_REG(port_num), pscr);
 
 	/* Assign port SDMA configuration */
-	mv_write(SDMA_CONFIG_REG(port_num),
+	wrl(mp, SDMA_CONFIG_REG(port_num),
 			  PORT_SDMA_CONFIG_DEFAULT_VALUE);
 
 	/* Enable port Rx. */
 	mv643xx_eth_port_enable_rx(mp, ETH_RX_QUEUES_ENABLED);
 
 	/* Disable port bandwidth limits by clearing MTU register */
-	mv_write(MAXIMUM_TRANSMIT_UNIT(port_num), 0);
+	wrl(mp, MAXIMUM_TRANSMIT_UNIT(port_num), 0);
 
 	/* save phy settings across reset */
 	mv643xx_get_settings(dev, &ethtool_cmd);
@@ -2345,8 +2345,8 @@ static void eth_port_uc_addr_set(struct 
 	mac_h = (p_addr[0] << 24) | (p_addr[1] << 16) | (p_addr[2] << 8) |
 							(p_addr[3] << 0);
 
-	mv_write(MAC_ADDR_LOW(port_num), mac_l);
-	mv_write(MAC_ADDR_HIGH(port_num), mac_h);
+	wrl(mp, MAC_ADDR_LOW(port_num), mac_l);
+	wrl(mp, MAC_ADDR_HIGH(port_num), mac_h);
 
 	/* Accept frames with this address */
 	table = DA_FILTER_UNICAST_TABLE_BASE(port_num);
@@ -2363,8 +2363,8 @@ static void eth_port_uc_addr_get(struct 
 	unsigned int mac_h;
 	unsigned int mac_l;
 
-	mac_h = mv_read(MAC_ADDR_HIGH(port_num));
-	mac_l = mv_read(MAC_ADDR_LOW(port_num));
+	mac_h = rdl(mp, MAC_ADDR_HIGH(port_num));
+	mac_l = rdl(mp, MAC_ADDR_LOW(port_num));
 
 	p_addr[0] = (mac_h >> 24) & 0xff;
 	p_addr[1] = (mac_h >> 16) & 0xff;
@@ -2394,9 +2394,9 @@ static void eth_port_set_filter_table_en
 	reg_offset = entry % 4;		/* Entry offset within the register */
 
 	/* Set "accepts frame bit" at specified table entry */
-	table_reg = mv_read(table + tbl_offset);
+	table_reg = rdl(mp, table + tbl_offset);
 	table_reg |= 0x01 << (8 * reg_offset);
-	mv_write(table + tbl_offset, table_reg);
+	wrl(mp, table + tbl_offset, table_reg);
 }
 
 /*
@@ -2529,7 +2529,7 @@ static void eth_port_set_multicast_list(
 			 * 3-1  Queue	 ETH_Q0=0
 			 * 7-4  Reserved = 0;
 			 */
-			mv_write(DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(eth_port_num) + table_index, 0x01010101);
+			wrl(mp, DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(eth_port_num) + table_index, 0x01010101);
 
 			/* Set all entries in DA filter other multicast
 			 * table (Ex_dFOMT)
@@ -2539,7 +2539,7 @@ static void eth_port_set_multicast_list(
 			 * 3-1  Queue	 ETH_Q0=0
 			 * 7-4  Reserved = 0;
 			 */
-			mv_write(DA_FILTER_OTHER_MULTICAST_TABLE_BASE(eth_port_num) + table_index, 0x01010101);
+			wrl(mp, DA_FILTER_OTHER_MULTICAST_TABLE_BASE(eth_port_num) + table_index, 0x01010101);
 		}
 		return;
 	}
@@ -2549,11 +2549,11 @@ static void eth_port_set_multicast_list(
 	 */
 	for (table_index = 0; table_index <= 0xFC; table_index += 4) {
 		/* Clear DA filter special multicast table (Ex_dFSMT) */
-		mv_write(DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE
+		wrl(mp, DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE
 				(eth_port_num) + table_index, 0);
 
 		/* Clear DA filter other multicast table (Ex_dFOMT) */
-		mv_write(DA_FILTER_OTHER_MULTICAST_TABLE_BASE
+		wrl(mp, DA_FILTER_OTHER_MULTICAST_TABLE_BASE
 				(eth_port_num) + table_index, 0);
 	}
 
@@ -2588,15 +2588,15 @@ static void eth_port_init_mac_tables(str
 
 	/* Clear DA filter unicast table (Ex_dFUT) */
 	for (table_index = 0; table_index <= 0xC; table_index += 4)
-		mv_write(DA_FILTER_UNICAST_TABLE_BASE(port_num) +
+		wrl(mp, DA_FILTER_UNICAST_TABLE_BASE(port_num) +
 					table_index, 0);
 
 	for (table_index = 0; table_index <= 0xFC; table_index += 4) {
 		/* Clear DA filter special multicast table (Ex_dFSMT) */
-		mv_write(DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(port_num) +
+		wrl(mp, DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE(port_num) +
 					table_index, 0);
 		/* Clear DA filter other multicast table (Ex_dFOMT) */
-		mv_write(DA_FILTER_OTHER_MULTICAST_TABLE_BASE(port_num) +
+		wrl(mp, DA_FILTER_OTHER_MULTICAST_TABLE_BASE(port_num) +
 					table_index, 0);
 	}
 }
@@ -2626,12 +2626,12 @@ static void eth_clear_mib_counters(struc
 	/* Perform dummy reads from MIB counters */
 	for (i = ETH_MIB_GOOD_OCTETS_RECEIVED_LOW; i < ETH_MIB_LATE_COLLISION;
 									i += 4)
-		mv_read(MIB_COUNTERS_BASE(port_num) + i);
+		rdl(mp, MIB_COUNTERS_BASE(port_num) + i);
 }
 
 static inline u32 read_mib(struct mv643xx_private *mp, int offset)
 {
-	return mv_read(MIB_COUNTERS_BASE(mp->port_num) + offset);
+	return rdl(mp, MIB_COUNTERS_BASE(mp->port_num) + offset);
 }
 
 static void eth_update_mib_counters(struct mv643xx_private *mp)
@@ -2716,7 +2716,7 @@ static int ethernet_phy_get(struct mv643
 {
 	unsigned int reg_data;
 
-	reg_data = mv_read(PHY_ADDR_REG);
+	reg_data = rdl(mp, PHY_ADDR_REG);
 
 	return ((reg_data >> (5 * mp->port_num)) & 0x1f);
 }
@@ -2743,10 +2743,10 @@ static void ethernet_phy_set(struct mv64
 	u32 reg_data;
 	int addr_shift = 5 * mp->port_num;
 
-	reg_data = mv_read(PHY_ADDR_REG);
+	reg_data = rdl(mp, PHY_ADDR_REG);
 	reg_data &= ~(0x1f << addr_shift);
 	reg_data |= (phy_addr & 0x1f) << addr_shift;
-	mv_write(PHY_ADDR_REG, reg_data);
+	wrl(mp, PHY_ADDR_REG, reg_data);
 }
 
 /*
@@ -2784,13 +2784,13 @@ static void ethernet_phy_reset(struct mv
 static void mv643xx_eth_port_enable_tx(struct mv643xx_private *mp,
 					unsigned int queues)
 {
-	mv_write(TRANSMIT_QUEUE_COMMAND_REG(mp->port_num), queues);
+	wrl(mp, TRANSMIT_QUEUE_COMMAND_REG(mp->port_num), queues);
 }
 
 static void mv643xx_eth_port_enable_rx(struct mv643xx_private *mp,
 					unsigned int queues)
 {
-	mv_write(RECEIVE_QUEUE_COMMAND_REG(mp->port_num), queues);
+	wrl(mp, RECEIVE_QUEUE_COMMAND_REG(mp->port_num), queues);
 }
 
 static unsigned int mv643xx_eth_port_disable_tx(struct mv643xx_private *mp)
@@ -2799,18 +2799,18 @@ static unsigned int mv643xx_eth_port_dis
 	u32 queues;
 
 	/* Stop Tx port activity. Check port Tx activity. */
-	queues = mv_read(TRANSMIT_QUEUE_COMMAND_REG(port_num)) & 0xFF;
+	queues = rdl(mp, TRANSMIT_QUEUE_COMMAND_REG(port_num)) & 0xFF;
 	if (queues) {
 		/* Issue stop command for active queues only */
-		mv_write(TRANSMIT_QUEUE_COMMAND_REG(port_num), (queues << 8));
+		wrl(mp, TRANSMIT_QUEUE_COMMAND_REG(port_num), (queues << 8));
 
 		/* Wait for all Tx activity to terminate. */
 		/* Check port cause register that all Tx queues are stopped */
-		while (mv_read(TRANSMIT_QUEUE_COMMAND_REG(port_num)) & 0xFF)
+		while (rdl(mp, TRANSMIT_QUEUE_COMMAND_REG(port_num)) & 0xFF)
 			udelay(PHY_WAIT_MICRO_SECONDS);
 
 		/* Wait for Tx FIFO to empty */
-		while (mv_read(PORT_STATUS_REG(port_num)) &
+		while (rdl(mp, PORT_STATUS_REG(port_num)) &
 							ETH_PORT_TX_FIFO_EMPTY)
 			udelay(PHY_WAIT_MICRO_SECONDS);
 	}
@@ -2824,14 +2824,14 @@ static unsigned int mv643xx_eth_port_dis
 	u32 queues;
 
 	/* Stop Rx port activity. Check port Rx activity. */
-	queues = mv_read(RECEIVE_QUEUE_COMMAND_REG(port_num)) & 0xFF;
+	queues = rdl(mp, RECEIVE_QUEUE_COMMAND_REG(port_num)) & 0xFF;
 	if (queues) {
 		/* Issue stop command for active queues only */
-		mv_write(RECEIVE_QUEUE_COMMAND_REG(port_num), (queues << 8));
+		wrl(mp, RECEIVE_QUEUE_COMMAND_REG(port_num), (queues << 8));
 
 		/* Wait for all Rx activity to terminate. */
 		/* Check port cause register that all Rx queues are stopped */
-		while (mv_read(RECEIVE_QUEUE_COMMAND_REG(port_num)) & 0xFF)
+		while (rdl(mp, RECEIVE_QUEUE_COMMAND_REG(port_num)) & 0xFF)
 			udelay(PHY_WAIT_MICRO_SECONDS);
 	}
 
@@ -2868,11 +2868,11 @@ static void eth_port_reset(struct mv643x
 	eth_clear_mib_counters(mp);
 
 	/* Reset the Enable bit in the Configuration Register */
-	reg_data = mv_read(PORT_SERIAL_CONTROL_REG(port_num));
+	reg_data = rdl(mp, PORT_SERIAL_CONTROL_REG(port_num));
 	reg_data &= ~(SERIAL_PORT_ENABLE		|
 			DO_NOT_FORCE_LINK_FAIL	|
 			FORCE_LINK_PASS);
-	mv_write(PORT_SERIAL_CONTROL_REG(port_num), reg_data);
+	wrl(mp, PORT_SERIAL_CONTROL_REG(port_num), reg_data);
 }
 
 
@@ -2907,7 +2907,7 @@ static void eth_port_read_smi_reg(struct
 	spin_lock_irqsave(&mv643xx_eth_phy_lock, flags);
 
 	/* wait for the SMI register to become available */
-	for (i = 0; mv_read(SMI_REG) & ETH_SMI_BUSY; i++) {
+	for (i = 0; rdl(mp, SMI_REG) & ETH_SMI_BUSY; i++) {
 		if (i == PHY_WAIT_ITERATIONS) {
 			printk("mv643xx PHY busy timeout, port %d\n", port_num);
 			goto out;
@@ -2915,11 +2915,11 @@ static void eth_port_read_smi_reg(struct
 		udelay(PHY_WAIT_MICRO_SECONDS);
 	}
 
-	mv_write(SMI_REG,
+	wrl(mp, SMI_REG,
 		(phy_addr << 16) | (phy_reg << 21) | ETH_SMI_OPCODE_READ);
 
 	/* now wait for the data to be valid */
-	for (i = 0; !(mv_read(SMI_REG) & ETH_SMI_READ_VALID); i++) {
+	for (i = 0; !(rdl(mp, SMI_REG) & ETH_SMI_READ_VALID); i++) {
 		if (i == PHY_WAIT_ITERATIONS) {
 			printk("mv643xx PHY read timeout, port %d\n", port_num);
 			goto out;
@@ -2927,7 +2927,7 @@ static void eth_port_read_smi_reg(struct
 		udelay(PHY_WAIT_MICRO_SECONDS);
 	}
 
-	*value = mv_read(SMI_REG) & 0xffff;
+	*value = rdl(mp, SMI_REG) & 0xffff;
 out:
 	spin_unlock_irqrestore(&mv643xx_eth_phy_lock, flags);
 }
@@ -2965,7 +2965,7 @@ static void eth_port_write_smi_reg(struc
 	spin_lock_irqsave(&mv643xx_eth_phy_lock, flags);
 
 	/* wait for the SMI register to become available */
-	for (i = 0; mv_read(SMI_REG) & ETH_SMI_BUSY; i++) {
+	for (i = 0; rdl(mp, SMI_REG) & ETH_SMI_BUSY; i++) {
 		if (i == PHY_WAIT_ITERATIONS) {
 			printk("mv643xx PHY busy timeout, port %d\n",
 								eth_port_num);
@@ -2974,7 +2974,7 @@ static void eth_port_write_smi_reg(struc
 		udelay(PHY_WAIT_MICRO_SECONDS);
 	}
 
-	mv_write(SMI_REG, (phy_addr << 16) | (phy_reg << 21) |
+	wrl(mp, SMI_REG, (phy_addr << 16) | (phy_reg << 21) |
 				ETH_SMI_OPCODE_WRITE | (value & 0xffff));
 out:
 	spin_unlock_irqrestore(&mv643xx_eth_phy_lock, flags);
