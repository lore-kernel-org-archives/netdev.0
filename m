From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: mv643xx(11/20): rename all functions to have a common mv643xx_eth prefix
Date: Mon, 28 Mar 2005 16:51:05 -0700
Message-ID: <20050328235105.GK29098@xyzzy>
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

This patch just establishes consistent function naming. No functional
changes here.

Signed-off-by: James Chapman <jchapman@katalix.com>
Acked-by: Dale Farnsworth <dale@farnsworth.org>

Index: linux-2.5-enet/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.5-enet.orig/drivers/net/mv643xx_eth.c
+++ linux-2.5-enet/drivers/net/mv643xx_eth.c
@@ -74,57 +74,56 @@
 #define PHY_WAIT_MICRO_SECONDS	10
 
 /* Static function declarations */
-static void eth_port_uc_addr_get(struct net_device *dev,
-						unsigned char *MacAddr);
 static int mv643xx_eth_real_open(struct net_device *);
 static int mv643xx_eth_real_stop(struct net_device *);
 static int mv643xx_eth_change_mtu(struct net_device *, int);
 static struct net_device_stats *mv643xx_eth_get_stats(struct net_device *);
-static void eth_port_init_mac_tables(struct net_device *dev);
+static void mv643xx_eth_port_init_mac_tables(struct net_device *dev);
 #ifdef MV643XX_NAPI
-static int mv643xx_poll(struct net_device *dev, int *budget);
+static int mv643xx_eth_poll(struct net_device *dev, int *budget);
 #endif
-static int ethernet_phy_get(struct net_device *dev);
-static void ethernet_phy_set(struct net_device *dev, int phy_addr);
-static void ethernet_phy_reset(struct net_device *dev);
-static int ethernet_phy_detect(struct net_device *dev);
-static int mv643xx_mdio_read(struct net_device *dev, int phy_id, int location);
-static void mv643xx_mdio_write(struct net_device *dev, int phy_id, int location, int val);
+static int mv643xx_eth_phy_get(struct net_device *dev);
+static void mv643xx_eth_phy_set(struct net_device *dev, int phy_addr);
+static void mv643xx_eth_phy_reset(struct net_device *dev);
+static int mv643xx_eth_phy_detect(struct net_device *dev);
+static int mv643xx_eth_mdio_read(struct net_device *dev, int phy_id, int location);
+static void mv643xx_eth_mdio_write(struct net_device *dev, int phy_id, int location, int val);
 static int mv643xx_eth_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
 static struct ethtool_ops mv643xx_ethtool_ops;
 
 /* Port operation control routines */
-static void eth_port_init(struct net_device *dev);
-static void eth_port_reset(struct net_device *dev);
-static void eth_port_start(struct net_device *dev);
+static void mv643xx_eth_port_init(struct net_device *dev);
+static void mv643xx_eth_port_reset(struct net_device *dev);
+static void mv643xx_eth_port_start(struct net_device *dev);
 
-static void ethernet_set_config_reg(struct net_device *dev,
+static void mv643xx_eth_set_config_reg(struct net_device *dev,
 				    unsigned int value);
-static unsigned int ethernet_get_config_reg(struct net_device *dev);
+static unsigned int mv643xx_eth_get_config_reg(struct net_device *dev);
 
 /* Port MAC address routines */
-static void eth_port_uc_addr_set(struct net_device *dev,
+static void mv643xx_eth_port_mac_addr_get(struct net_device *dev, unsigned char *p_addr);
+static void mv643xx_eth_port_mac_addr_set(struct net_device *dev,
 				 unsigned char *p_addr);
 
 /* PHY and MIB routines */
-static void ethernet_phy_reset(struct net_device *dev);
+static void mv643xx_eth_phy_reset(struct net_device *dev);
 
-static void eth_port_write_smi_reg(struct net_device *dev,
+static void mv643xx_eth_write_smi_reg(struct net_device *dev,
 				   unsigned int phy_reg, unsigned int value);
 
-static void eth_port_read_smi_reg(struct net_device *dev,
+static void mv643xx_eth_read_smi_reg(struct net_device *dev,
 				  unsigned int phy_reg, unsigned int *value);
 
-static void eth_clear_mib_counters(struct net_device *dev);
+static void mv643xx_eth_clear_mib_counters(struct net_device *dev);
 
 /* Port data flow control routines */
-static int eth_port_send(struct net_device *dev,
+static int mv643xx_eth_tx_packet(struct net_device *dev,
 			 struct pkt_info *p_pkt_info);
-static int eth_tx_return_desc(struct net_device *dev,
+static int mv643xx_eth_tx_return_desc(struct net_device *dev,
 			      struct pkt_info *p_pkt_info);
-static int eth_port_receive(struct net_device *dev,
+static int mv643xx_eth_rx_packet(struct net_device *dev,
 			    struct pkt_info *p_pkt_info);
-static void eth_rx_return_buff(struct net_device *dev,
+static void mv643xx_eth_rx_return_buff(struct net_device *dev,
 			       struct pkt_info *p_pkt_info);
 
 static char mv643xx_driver_name[] = "mv643xx_eth";
@@ -135,7 +134,7 @@
 /* used to protect MV643XX_ETH_SMI_REG, which is shared across ports */
 static spinlock_t mv643xx_eth_phy_lock = SPIN_LOCK_UNLOCKED;
 
-static inline u32 mv_read(int offset)
+static inline u32 mv643xx_eth_read(int offset)
 {
 	void *__iomem reg_base;
 
@@ -144,7 +143,7 @@
 	return readl(reg_base + offset);
 }
 
-static inline void mv_write(int offset, u32 data)
+static inline void mv643xx_eth_write(int offset, u32 data)
 {
 	void * __iomem reg_base;
 
@@ -221,7 +220,7 @@
 		pkt_info.buf_ptr = dma_map_single(NULL, skb->data, RX_SKB_SIZE,
 							DMA_FROM_DEVICE);
 		pkt_info.return_info = skb;
-		eth_rx_return_buff(dev, &pkt_info);
+		mv643xx_eth_rx_return_buff(dev, &pkt_info);
 		skb_reserve(skb, 2);
 	}
 	clear_bit(0, &mp->rx_task_busy);
@@ -240,7 +239,7 @@
 #ifdef MV643XX_RX_QUEUE_FILL_ON_TASK
 	else {
 		/* Return interrupts */
-		mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(mp->port_num),
+		mv643xx_eth_write(MV643XX_ETH_INTERRUPT_MASK_REG(mp->port_num),
 							INT_CAUSE_UNMASK_ALL);
 	}
 #endif
@@ -277,9 +276,9 @@
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 
-	eth_port_init_mac_tables(dev);
+	mv643xx_eth_port_init_mac_tables(dev);
 	memcpy(mp->port_mac_addr, dev->dev_addr, 6);
-	eth_port_uc_addr_set(dev, mp->port_mac_addr);
+	mv643xx_eth_port_mac_addr_set(dev, mp->port_mac_addr);
 }
 
 /*
@@ -294,12 +293,12 @@
 {
 	u32 config_reg;
 
-	config_reg = ethernet_get_config_reg(dev);
+	config_reg = mv643xx_eth_get_config_reg(dev);
 	if (dev->flags & IFF_PROMISC)
 		config_reg |= (u32) MV643XX_ETH_UNICAST_PROMISCUOUS_MODE;
 	else
 		config_reg &= ~(u32) MV643XX_ETH_UNICAST_PROMISCUOUS_MODE;
-	ethernet_set_config_reg(dev, config_reg);
+	mv643xx_eth_set_config_reg(dev, config_reg);
 }
 
 /*
@@ -351,8 +350,8 @@
 static void mv643xx_eth_tx_timeout_task(struct net_device *dev)
 {
 	netif_device_detach(dev);
-	eth_port_reset(dev);
-	eth_port_start(dev);
+	mv643xx_eth_port_reset(dev);
+	mv643xx_eth_port_start(dev);
 	netif_device_attach(dev);
 }
 
@@ -377,7 +376,7 @@
 	spin_lock(&mp->lock);
 
 	/* Check only queue 0 */
-	while (eth_tx_return_desc(dev, &pkt_info) == 0) {
+	while (mv643xx_eth_tx_return_desc(dev, &pkt_info) == 0) {
 		if (pkt_info.cmd_sts & BIT0) {
 			if (netif_msg_tx_err(mp))
 				printk(KERN_WARNING "%s: Error in TX: cmd_sts=%08x\n",
@@ -446,9 +445,9 @@
 	struct pkt_info pkt_info;
 
 #ifdef MV643XX_NAPI
-	while (eth_port_receive(dev, &pkt_info) == 0 && budget > 0) {
+	while (mv643xx_eth_rx_packet(dev, &pkt_info) == 0 && budget > 0) {
 #else
-	while (eth_port_receive(dev, &pkt_info) == 0) {
+	while (mv643xx_eth_rx_packet(dev, &pkt_info) == 0) {
 #endif
 		mp->rx_ring_skbs--;
 		received_packets++;
@@ -525,11 +524,11 @@
 	unsigned int port_num = mp->port_num;
 
 	/* Read interrupt cause registers */
-	eth_int_cause = mv_read(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num)) &
+	eth_int_cause = mv643xx_eth_read(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num)) &
 						INT_CAUSE_UNMASK_ALL;
 
 	if (eth_int_cause & BIT1)
-		eth_int_cause_ext = mv_read(
+		eth_int_cause_ext = mv643xx_eth_read(
 			MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num)) &
 						INT_CAUSE_UNMASK_ALL_EXT;
 
@@ -541,10 +540,10 @@
 		 * Clear specific ethernet port intrerrupt registers by
 		 * acknowleding relevant bits.
 		 */
-		mv_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num),
+		mv643xx_eth_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num),
 							~eth_int_cause);
 		if (eth_int_cause_ext != 0x0)
-			mv_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG
+			mv643xx_eth_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG
 					(port_num), ~eth_int_cause_ext);
 
 		/* UDP change : We may need this */
@@ -556,8 +555,8 @@
 	} else {
 		if (netif_rx_schedule_prep(dev)) {
 			/* Mask all the interrupts */
-			mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num), 0);
-			mv_write(MV643XX_ETH_INTERRUPT_EXTEND_MASK_REG
+			mv643xx_eth_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num), 0);
+			mv643xx_eth_write(MV643XX_ETH_INTERRUPT_EXTEND_MASK_REG
 								(port_num), 0);
 			__netif_rx_schedule(dev);
 		}
@@ -573,7 +572,7 @@
 		 */
 #ifdef MV643XX_RX_QUEUE_FILL_ON_TASK
 		/* Unmask all interrupts on ethernet port */
-		mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num),
+		mv643xx_eth_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num),
 							INT_CAUSE_MASK_ALL);
 		queue_task(&mp->rx_task, &tq_immediate);
 		mark_bh(IMMEDIATE_BH);
@@ -606,7 +605,7 @@
 
 			netif_wake_queue(dev);
 			/* Start TX queue */
-			mv_write(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num), 1);
+			mv643xx_eth_write(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num), 1);
 
 		} else if(!mii_link_ok(&mp->mii) && netif_carrier_ok(dev)) {
 			netif_stop_queue(dev);
@@ -652,15 +651,15 @@
  *	The interrupt coalescing value set in the gigE port.
  *
  */
-static unsigned int eth_port_set_rx_coal(unsigned int eth_port_num,
+static unsigned int mv643xx_eth_port_set_rx_coal(unsigned int eth_port_num,
 					unsigned int t_clk, unsigned int delay)
 {
 	unsigned int coal = ((t_clk / 1000000) * delay) / 64;
 
 	/* Set RX Coalescing mechanism */
-	mv_write(MV643XX_ETH_SDMA_CONFIG_REG(eth_port_num),
+	mv643xx_eth_write(MV643XX_ETH_SDMA_CONFIG_REG(eth_port_num),
 		((coal & 0x3fff) << 8) |
-		(mv_read(MV643XX_ETH_SDMA_CONFIG_REG(eth_port_num))
+		(mv643xx_eth_read(MV643XX_ETH_SDMA_CONFIG_REG(eth_port_num))
 			& 0xffc000ff));
 
 	return coal;
@@ -690,13 +689,13 @@
  *	The interrupt coalescing value set in the gigE port.
  *
  */
-static unsigned int eth_port_set_tx_coal(unsigned int eth_port_num,
+static unsigned int mv643xx_eth_port_set_tx_coal(unsigned int eth_port_num,
 					unsigned int t_clk, unsigned int delay)
 {
 	unsigned int coal;
 	coal = ((t_clk / 1000000) * delay) / 64;
 	/* Set TX Coalescing mechanism */
-	mv_write(MV643XX_ETH_TX_FIFO_URGENT_THRESHOLD_REG(eth_port_num),
+	mv643xx_eth_write(MV643XX_ETH_TX_FIFO_URGENT_THRESHOLD_REG(eth_port_num),
 								coal << 4);
 	return coal;
 }
@@ -727,7 +726,7 @@
 		mp->port_serial_control |= BIT23;
 }
 
-static int mv643xx_set_settings(struct net_device *dev,
+static int mv643xx_eth_set_settings(struct net_device *dev,
 				    struct ethtool_cmd *cmd)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
@@ -849,7 +848,7 @@
 	spin_unlock_irq(&mp->lock);
 	
 	if (mp->ethtool_cmd.autoneg || mp->ethtool_cmd.speed)
-		mv643xx_set_settings(dev, &mp->ethtool_cmd);
+		mv643xx_eth_set_settings(dev, &mp->ethtool_cmd);
 
 	return 0;
 
@@ -884,7 +883,7 @@
  * RETURN:
  *	None.
  */
-static void ether_init_rx_desc_ring(struct net_device *dev)
+static void mv643xx_eth_init_rx_desc_ring(struct net_device *dev)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 	volatile struct eth_rx_desc *p_rx_desc;
@@ -930,7 +929,7 @@
  * RETURN:
  *	None.
  */
-static void ether_init_tx_desc_ring(struct net_device *dev)
+static void mv643xx_eth_init_tx_desc_ring(struct net_device *dev)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 	int tx_desc_num = mp->tx_ring_size;
@@ -964,24 +963,24 @@
 	unsigned int size;
 
 	/* Stop RX Queues */
-	mv_write(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num), 0x0000ff00);
+	mv643xx_eth_write(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num), 0x0000ff00);
 
 	/* Clear the ethernet port interrupts */
-	mv_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num), 0);
-	mv_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
+	mv643xx_eth_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num), 0);
+	mv643xx_eth_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
 
 	/* Unmask RX buffer and TX end interrupt */
-	mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num),
+	mv643xx_eth_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num),
 						INT_CAUSE_UNMASK_ALL);
 
 	/* Unmask phy and link status changes interrupts */
-	mv_write(MV643XX_ETH_INTERRUPT_EXTEND_MASK_REG(port_num),
+	mv643xx_eth_write(MV643XX_ETH_INTERRUPT_EXTEND_MASK_REG(port_num),
 						INT_CAUSE_UNMASK_ALL_EXT);
 
 	/* Set the MAC Address */
 	memcpy(mp->port_mac_addr, dev->dev_addr, 6);
 
-	eth_port_init(dev);
+	mv643xx_eth_port_init(dev);
 
 	INIT_WORK(&mp->rx_task, (void (*)(void *))mv643xx_eth_rx_task, dev);
 
@@ -1031,7 +1030,7 @@
 	BUG_ON((u32) mp->p_tx_desc_area & 0xf);	/* check 16-byte alignment */
 	memset((void *)mp->p_tx_desc_area, 0, mp->tx_desc_area_size);
 
-	ether_init_tx_desc_ring(dev);
+	mv643xx_eth_init_tx_desc_ring(dev);
 
 	/* Allocate RX ring */
 	mp->rx_ring_skbs = 0;
@@ -1061,21 +1060,21 @@
 	}
 	memset((void *)mp->p_rx_desc_area, 0, size);
 
-	ether_init_rx_desc_ring(dev);
+	mv643xx_eth_init_rx_desc_ring(dev);
 
 	mv643xx_eth_rx_task(dev);	/* Fill RX ring with skb's */
 
-	eth_port_start(dev);
+	mv643xx_eth_port_start(dev);
 
 	/* Interrupt Coalescing */
 
 #ifdef MV643XX_COAL
 	mp->rx_int_coal =
-		eth_port_set_rx_coal(port_num, 133000000, MV643XX_RX_COAL);
+		mv643xx_eth_port_set_rx_coal(port_num, 133000000, MV643XX_RX_COAL);
 #endif
 
 	mp->tx_int_coal =
-		eth_port_set_tx_coal(port_num, 133000000, MV643XX_TX_COAL);
+		mv643xx_eth_port_set_tx_coal(port_num, 133000000, MV643XX_TX_COAL);
 
 	netif_start_queue(dev);
 
@@ -1088,7 +1087,7 @@
 	unsigned int curr;
 
 	/* Stop Tx Queues */
-	mv_write(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(mp->port_num), 0x0000ff00);
+	mv643xx_eth_write(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(mp->port_num), 0x0000ff00);
 
 	/* Free outstanding skb's on TX rings */
 	for (curr = 0; mp->tx_ring_skbs && curr < mp->tx_ring_size; curr++) {
@@ -1115,7 +1114,7 @@
 	int curr;
 
 	/* Stop RX Queues */
-	mv_write(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(mp->port_num), 0x0000ff00);
+	mv643xx_eth_write(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(mp->port_num), 0x0000ff00);
 
 	/* Free preallocated skb's on RX rings */
 	for (curr = 0; mp->rx_ring_skbs && curr < mp->rx_ring_size; curr++) {
@@ -1161,17 +1160,17 @@
 	mv643xx_eth_free_tx_rings(dev);
 	mv643xx_eth_free_rx_rings(dev);
 
-	eth_port_reset(dev);
+	mv643xx_eth_port_reset(dev);
 
 	/* Disable ethernet port interrupts */
-	mv_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num), 0);
-	mv_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
+	mv643xx_eth_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num), 0);
+	mv643xx_eth_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
 
 	/* Mask RX buffer and TX end interrupt */
-	mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num), 0);
+	mv643xx_eth_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num), 0);
 
 	/* Mask phy and link status changes interrupts */
-	mv_write(MV643XX_ETH_INTERRUPT_EXTEND_MASK_REG(port_num), 0);
+	mv643xx_eth_write(MV643XX_ETH_INTERRUPT_EXTEND_MASK_REG(port_num), 0);
 
 	return 0;
 }
@@ -1191,12 +1190,12 @@
 }
 
 #ifdef MV643XX_NAPI
-static void mv643xx_tx(struct net_device *dev)
+static void mv643xx_eth_tx(struct net_device *dev)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 	struct pkt_info pkt_info;
 
-	while (eth_tx_return_desc(dev, &pkt_info) == 0) {
+	while (mv643xx_eth_tx_return_desc(dev, &pkt_info) == 0) {
 		if (pkt_info.return_info) {
 			if (skb_shinfo(pkt_info.return_info)->nr_frags)
 				dma_unmap_page(NULL, pkt_info.buf_ptr,
@@ -1226,7 +1225,7 @@
  *
  * This function is used in case of NAPI
  */
-static int mv643xx_poll(struct net_device *dev, int *budget)
+static int mv643xx_eth_poll(struct net_device *dev, int *budget)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 	int done = 1, orig_budget, work_done;
@@ -1236,13 +1235,13 @@
 #ifdef MV643XX_TX_FAST_REFILL
 	if (++mp->tx_clean_threshold > 5) {
 		spin_lock_irqsave(&mp->lock, flags);
-		mv643xx_tx(dev);
+		mv643xx_eth_tx(dev);
 		mp->tx_clean_threshold = 0;
 		spin_unlock_irqrestore(&mp->lock, flags);
 	}
 #endif
 
-	if ((mv_read(MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_0(port_num)))
+	if ((mv643xx_eth_read(MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_0(port_num)))
 						!= (u32) mp->rx_used_desc_q) {
 		orig_budget = *budget;
 		if (orig_budget > dev->quota)
@@ -1258,11 +1257,11 @@
 	if (done) {
 		spin_lock_irqsave(&mp->lock, flags);
 		__netif_rx_complete(dev);
-		mv_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num), 0);
-		mv_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
-		mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num),
+		mv643xx_eth_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num), 0);
+		mv643xx_eth_write(MV643XX_ETH_INTERRUPT_CAUSE_EXTEND_REG(port_num), 0);
+		mv643xx_eth_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num),
 						INT_CAUSE_UNMASK_ALL);
-		mv_write(MV643XX_ETH_INTERRUPT_EXTEND_MASK_REG(port_num),
+		mv643xx_eth_write(MV643XX_ETH_INTERRUPT_EXTEND_MASK_REG(port_num),
 						INT_CAUSE_UNMASK_ALL_EXT);
 		spin_unlock_irqrestore(&mp->lock, flags);
 	}
@@ -1347,7 +1346,7 @@
 							DMA_TO_DEVICE);
 		pkt_info.return_info = skb;
 		mp->tx_ring_skbs++;
-		status = eth_port_send(dev, &pkt_info);
+		status = mv643xx_eth_tx_packet(dev, &pkt_info);
 		if (status < 0)
 			goto out;
 
@@ -1405,7 +1404,7 @@
 			}
 		}
 
-		status = eth_port_send(dev, &pkt_info);
+		status = mv643xx_eth_tx_packet(dev, &pkt_info);
 		if (status < 0)
 			goto out;
 
@@ -1434,7 +1433,7 @@
 							this_frag->size,
 							DMA_TO_DEVICE);
 
-			status = eth_port_send(dev, &pkt_info);
+			status = mv643xx_eth_tx_packet(dev, &pkt_info);
 			if (status < 0)
 				goto out;
 
@@ -1450,7 +1449,7 @@
 								DMA_TO_DEVICE);
 	pkt_info.return_info = skb;
 	mp->tx_ring_skbs++;
-	status = eth_port_send(dev, &pkt_info);
+	status = mv643xx_eth_tx_packet(dev, &pkt_info);
 	if (status < 0)
 		goto out;
 
@@ -1495,7 +1494,7 @@
 	return &mp->stats;
 }
 
-/*/
+/*
  * mv643xx_eth_probe
  *
  * First function called after registering the network device.
@@ -1549,7 +1548,7 @@
 	/* No need to Tx Timeout */
 	dev->tx_timeout = mv643xx_eth_tx_timeout;
 #ifdef MV643XX_NAPI
-	dev->poll = mv643xx_poll;
+	dev->poll = mv643xx_eth_poll;
 	dev->weight = 64;
 #endif
 
@@ -1577,9 +1576,9 @@
 	spin_lock_init(&mp->lock);
 
 	/* set default config values */
-	eth_port_uc_addr_get(dev, dev->dev_addr);
+	mv643xx_eth_port_mac_addr_get(dev, dev->dev_addr);
 	mp->port_serial_control =
-		mv_read(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num));
+		mv643xx_eth_read(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num));
 	mp->port_serial_control &= ~MV643XX_ETH_SERIAL_PORT_ENABLE;
 	mp->port_serial_control |= MV643XX_ETH_DISABLE_AUTO_NEG_FOR_FLOW_CTRL |
 				   MV643XX_ETH_SERIAL_PORT_CONTROL_RESERVED   |
@@ -1619,25 +1618,25 @@
 						    ADVERTISED_Autoneg	      |
 						    ADVERTISED_MII;
 
-			ethernet_phy_set(dev, ecmd->phy_address);
+			mv643xx_eth_phy_set(dev, ecmd->phy_address);
 			memcpy(&mp->ethtool_cmd, ecmd, sizeof *ecmd);
 			mv643xx_eth_update_pscr(dev, ecmd);
 		}
 	}
-
 	/* Hook up MII support for ethtool */
 	mp->mii.dev = dev;
-	mp->mii.mdio_read = mv643xx_mdio_read;
-	mp->mii.mdio_write = mv643xx_mdio_write;
-	mp->mii.phy_id = ethernet_phy_get(dev);
+	mp->mii.mdio_read = mv643xx_eth_mdio_read;
+	mp->mii.mdio_write = mv643xx_eth_mdio_write;
+	mp->mii.phy_id = mv643xx_eth_phy_get(dev);
 	mp->mii.phy_id_mask = 0x3f;
 	mp->mii.reg_num_mask = 0x1f;
 
-	err = ethernet_phy_detect(dev);
+	err = mv643xx_eth_phy_detect(dev);
+
 	if (err) {
 		printk(KERN_ERR "MV643xx ethernet port %d: "
 		       "No PHY detected at addr %d\n",
-		       port_num, ethernet_phy_get(dev));
+		       port_num, mv643xx_eth_phy_get(dev));
 		return err;
 	}
 
@@ -1751,7 +1750,7 @@
  *
  * Output :	N/A
  */
-static int __init mv643xx_init_module(void)
+static int __init mv643xx_eth_init_module(void)
 {
 	int rc;
 
@@ -1773,14 +1772,14 @@
  *
  * Output :	N/A
  */
-static void __exit mv643xx_cleanup_module(void)
+static void __exit mv643xx_eth_cleanup_module(void)
 {
 	driver_unregister(&mv643xx_eth_driver);
 	driver_unregister(&mv643xx_eth_shared_driver);
 }
 
-module_init(mv643xx_init_module);
-module_exit(mv643xx_cleanup_module);
+module_init(mv643xx_eth_init_module);
+module_exit(mv643xx_eth_cleanup_module);
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR(	"Rabeeh Khoury, Assaf Hoffman, Matthew Dharm, Manish Lachwani"
@@ -1930,12 +1929,10 @@
 /* defines */
 /* SDMA command macros */
 #define ETH_ENABLE_TX_QUEUE(eth_port) \
-	mv_write(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(eth_port), 1)
-
-/* locals */
+	mv643xx_eth_write(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(eth_port), 1)
 
 /* Ethernet Port routines */
-static int eth_port_uc_addr(unsigned int eth_port_num, unsigned char uc_nibble,
+static int mv643xx_eth_port_mac_addr(unsigned int eth_port_num, unsigned char uc_nibble,
 								int option);
 
 /*
@@ -1962,7 +1959,7 @@
  * RETURN:
  *	None.
  */
-static void eth_port_init(struct net_device *dev)
+static void mv643xx_eth_port_init(struct net_device *dev)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 
@@ -1972,11 +1969,11 @@
 	mp->rx_resource_err = 0;
 	mp->tx_resource_err = 0;
 
-	eth_port_reset(dev);
+	mv643xx_eth_port_reset(dev);
 
-	eth_port_init_mac_tables(dev);
+	mv643xx_eth_port_init_mac_tables(dev);
 
-	ethernet_phy_reset(dev);
+	mv643xx_eth_phy_reset(dev);
 }
 
 /*
@@ -2006,7 +2003,7 @@
  * RETURN:
  *	None.
  */
-static void eth_port_start(struct net_device *dev)
+static void mv643xx_eth_port_start(struct net_device *dev)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 	unsigned int port_num = mp->port_num;
@@ -2014,47 +2011,46 @@
 
 	/* Assignment of Tx CTRP of given queue */
 	tx_curr_desc = mp->tx_curr_desc_q;
-	mv_write(MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_0(port_num),
+	mv643xx_eth_write(MV643XX_ETH_TX_CURRENT_QUEUE_DESC_PTR_0(port_num),
 		(u32)((struct eth_tx_desc *)mp->tx_desc_dma + tx_curr_desc));
 
 	/* Assignment of Rx CRDP of given queue */
 	rx_curr_desc = mp->rx_curr_desc_q;
-	mv_write(MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_0(port_num),
+	mv643xx_eth_write(MV643XX_ETH_RX_CURRENT_QUEUE_DESC_PTR_0(port_num),
 		(u32)((struct eth_rx_desc *)mp->rx_desc_dma + rx_curr_desc));
 
 	/* Add the assigned Ethernet address to the port's address table */
-	eth_port_uc_addr_set(dev, mp->port_mac_addr);
+	mv643xx_eth_port_mac_addr_set(dev, mp->port_mac_addr);
 
 	/* Assign port configuration and command. */
-	mv_write(MV643XX_ETH_PORT_CONFIG_REG(port_num),
+	mv643xx_eth_write(MV643XX_ETH_PORT_CONFIG_REG(port_num),
 			  MV643XX_ETH_PORT_CONFIG_DEFAULT_VALUE);
 
-	mv_write(MV643XX_ETH_PORT_CONFIG_EXTEND_REG(port_num),
+	mv643xx_eth_write(MV643XX_ETH_PORT_CONFIG_EXTEND_REG(port_num),
 			  MV643XX_ETH_PORT_CONFIG_EXTEND_DEFAULT_VALUE);
 
 	/* the mv643xx users manual says the following read/write are needed */
-	mv_read(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num));
-	mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num), 0);
-
+	mv643xx_eth_read(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num));
+	mv643xx_eth_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num), 0);
 
 	/* Increase the Rx side buffer size if supporting GigE */
 	if (mp->port_serial_control & MV643XX_ETH_SET_GMII_SPEED_TO_1000)
-		mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num),
+		mv643xx_eth_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num),
 			(mp->port_serial_control & 0xfff1ffff) | (0x5 << 17));
 	else
-		mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num),
+		mv643xx_eth_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num),
 						mp->port_serial_control);
 
-	mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num),
-			mp->port_serial_control |
-			MV643XX_ETH_SERIAL_PORT_ENABLE);
+	mv643xx_eth_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num),
+			  mp->port_serial_control |
+			  MV643XX_ETH_SERIAL_PORT_ENABLE);
 
 	/* Assign port SDMA configuration */
-	mv_write(MV643XX_ETH_SDMA_CONFIG_REG(port_num),
+	mv643xx_eth_write(MV643XX_ETH_SDMA_CONFIG_REG(port_num),
 			  MV643XX_ETH_PORT_SDMA_CONFIG_DEFAULT_VALUE);
 
 	/* Enable port Rx. */
-	mv_write(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num),
+	mv643xx_eth_write(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num),
 						mp->port_rx_queue_command);
 }
 
@@ -2076,8 +2072,8 @@
  *	N/A.
  *
  */
-static void eth_port_uc_addr_set(struct net_device *dev,
-				 unsigned char *p_addr)
+static void mv643xx_eth_port_mac_addr_set(struct net_device *dev,
+					  unsigned char *p_addr)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 	unsigned int eth_port_num = mp->port_num;
@@ -2088,11 +2084,11 @@
 	mac_h = (p_addr[0] << 24) | (p_addr[1] << 16) | (p_addr[2] << 8) |
 							(p_addr[3] << 0);
 
-	mv_write(MV643XX_ETH_MAC_ADDR_LOW(eth_port_num), mac_l);
-	mv_write(MV643XX_ETH_MAC_ADDR_HIGH(eth_port_num), mac_h);
+	mv643xx_eth_write(MV643XX_ETH_MAC_ADDR_LOW(eth_port_num), mac_l);
+	mv643xx_eth_write(MV643XX_ETH_MAC_ADDR_HIGH(eth_port_num), mac_h);
 
 	/* Accept frames of this address */
-	eth_port_uc_addr(eth_port_num, p_addr[5], ACCEPT_MAC_ADDR);
+	mv643xx_eth_port_mac_addr(eth_port_num, p_addr[5], ACCEPT_MAC_ADDR);
 
 	return;
 }
@@ -2115,14 +2111,14 @@
  *	N/A.
  *
  */
-static void eth_port_uc_addr_get(struct net_device *dev, unsigned char *p_addr)
+static void mv643xx_eth_port_mac_addr_get(struct net_device *dev, unsigned char *p_addr)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 	unsigned int mac_h;
 	unsigned int mac_l;
 
-	mac_h = mv_read(MV643XX_ETH_MAC_ADDR_HIGH(mp->port_num));
-	mac_l = mv_read(MV643XX_ETH_MAC_ADDR_LOW(mp->port_num));
+	mac_h = mv643xx_eth_read(MV643XX_ETH_MAC_ADDR_HIGH(mp->port_num));
+	mac_l = mv643xx_eth_read(MV643XX_ETH_MAC_ADDR_LOW(mp->port_num));
 
 	p_addr[0] = (mac_h >> 24) & 0xff;
 	p_addr[1] = (mac_h >> 16) & 0xff;
@@ -2154,7 +2150,7 @@
  *	false if option parameter is invalid.
  *
  */
-static int eth_port_uc_addr(unsigned int eth_port_num, unsigned char uc_nibble,
+static int mv643xx_eth_port_mac_addr(unsigned int eth_port_num, unsigned char uc_nibble,
 								int option)
 {
 	unsigned int unicast_reg;
@@ -2169,24 +2165,24 @@
 	switch (option) {
 	case REJECT_MAC_ADDR:
 		/* Clear accepts frame bit at given unicast DA table entry */
-		unicast_reg = mv_read((MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE
+		unicast_reg = mv643xx_eth_read((MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE
 						(eth_port_num) + tbl_offset));
 
 		unicast_reg &= (0x0E << (8 * reg_offset));
 
-		mv_write((MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE
+		mv643xx_eth_write((MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE
 				(eth_port_num) + tbl_offset), unicast_reg);
 		break;
 
 	case ACCEPT_MAC_ADDR:
 		/* Set accepts frame bit at unicast DA filter table entry */
 		unicast_reg =
-			mv_read((MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE
+			mv643xx_eth_read((MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE
 						(eth_port_num) + tbl_offset));
 
 		unicast_reg |= (0x01 << (8 * reg_offset));
 
-		mv_write((MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE
+		mv643xx_eth_write((MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE
 				(eth_port_num) + tbl_offset), unicast_reg);
 
 		break;
@@ -2214,7 +2210,7 @@
  * RETURN:
  *	None.
  */
-static void eth_port_init_mac_tables(struct net_device *dev)
+static void mv643xx_eth_port_init_mac_tables(struct net_device *dev)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 	int table_index;
@@ -2222,15 +2218,15 @@
 
 	/* Clear DA filter unicast table (Ex_dFUT) */
 	for (table_index = 0; table_index <= 0xC; table_index += 4)
-		mv_write((MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE
+		mv643xx_eth_write((MV643XX_ETH_DA_FILTER_UNICAST_TABLE_BASE
 					(eth_port_num) + table_index), 0);
 
 	for (table_index = 0; table_index <= 0xFC; table_index += 4) {
 		/* Clear DA filter special multicast table (Ex_dFSMT) */
-		mv_write((MV643XX_ETH_DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE
+		mv643xx_eth_write((MV643XX_ETH_DA_FILTER_SPECIAL_MULTICAST_TABLE_BASE
 					(eth_port_num) + table_index), 0);
 		/* Clear DA filter other multicast table (Ex_dFOMT) */
-		mv_write((MV643XX_ETH_DA_FILTER_OTHER_MULTICAST_TABLE_BASE
+		mv643xx_eth_write((MV643XX_ETH_DA_FILTER_OTHER_MULTICAST_TABLE_BASE
 					(eth_port_num) + table_index), 0);
 	}
 }
@@ -2252,7 +2248,7 @@
  *	MIB counter value.
  *
  */
-static void eth_clear_mib_counters(struct net_device *dev)
+static void mv643xx_eth_clear_mib_counters(struct net_device *dev)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 	unsigned int eth_port_num = mp->port_num;
@@ -2261,40 +2257,45 @@
 	/* Perform dummy reads from MIB counters */
 	for (i = ETH_MIB_GOOD_OCTETS_RECEIVED_LOW; i < ETH_MIB_LATE_COLLISION;
 									i += 4)
-		mv_read(MV643XX_ETH_MIB_COUNTERS_BASE(eth_port_num) + i);
+		mv643xx_eth_read(MV643XX_ETH_MIB_COUNTERS_BASE(eth_port_num) + i);
 }
 
-static inline u32 read_mib(struct net_device *dev, int offset)
+static inline u32 mv643xx_eth_read_mib_counter(struct net_device *dev,
+					       int offset)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 
-	return mv_read(MV643XX_ETH_MIB_COUNTERS_BASE(mp->port_num) + offset);
+	return mv643xx_eth_read(MV643XX_ETH_MIB_COUNTERS_BASE(mp->port_num) + offset);
 }
 
-static void eth_update_mib_counters(struct net_device *dev)
+static void mv643xx_eth_update_mib_counters(struct net_device *dev)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 	struct mv643xx_mib_counters *p = &mp->mib_counters;
 	int offset;
 
 	p->good_octets_received +=
-		read_mib(dev, ETH_MIB_GOOD_OCTETS_RECEIVED_LOW);
+	    mv643xx_eth_read_mib_counter(dev, ETH_MIB_GOOD_OCTETS_RECEIVED_LOW);
 	p->good_octets_received +=
-		(u64)read_mib(dev, ETH_MIB_GOOD_OCTETS_RECEIVED_HIGH) << 32;
-
+	    (u64) mv643xx_eth_read_mib_counter(dev,
+					       ETH_MIB_GOOD_OCTETS_RECEIVED_HIGH)
+	    << 32;
 	for (offset = ETH_MIB_BAD_OCTETS_RECEIVED;
 			offset <= ETH_MIB_FRAMES_1024_TO_MAX_OCTETS;
 			offset += 4)
-		*(u32 *)((char *)p + offset) = read_mib(dev, offset);
+		*(u32 *)((char *)p + offset) =
+		    mv643xx_eth_read_mib_counter(dev, offset);
 
-	p->good_octets_sent += read_mib(dev, ETH_MIB_GOOD_OCTETS_SENT_LOW);
 	p->good_octets_sent +=
-		(u64)read_mib(dev, ETH_MIB_GOOD_OCTETS_SENT_HIGH) << 32;
+	    mv643xx_eth_read_mib_counter(dev, ETH_MIB_GOOD_OCTETS_SENT_LOW);
+	p->good_octets_sent +=
+	    (u64) mv643xx_eth_read_mib_counter(dev, ETH_MIB_GOOD_OCTETS_SENT_HIGH) << 32;
 
 	for (offset = ETH_MIB_GOOD_FRAMES_SENT;
 			offset <= ETH_MIB_LATE_COLLISION;
 			offset += 4)
-		*(u32 *)((char *)p + offset) = read_mib(dev, offset);
+		*(u32 *)((char *)p + offset) =
+		    mv643xx_eth_read_mib_counter(dev, offset);
 }
 
 /*
@@ -2315,22 +2316,22 @@
  *	-ENODEV on failure
  *
  */
-static int ethernet_phy_detect(struct net_device *dev)
+static int mv643xx_eth_phy_detect(struct net_device *dev)
 {
 	unsigned int phy_reg_data0;
 	int auto_neg;
 
-	eth_port_read_smi_reg(dev, 0, &phy_reg_data0);
+	mv643xx_eth_read_smi_reg(dev, 0, &phy_reg_data0);
 	auto_neg = phy_reg_data0 & 0x1000;
 	phy_reg_data0 ^= 0x1000;	/* invert auto_neg */
-	eth_port_write_smi_reg(dev, 0, phy_reg_data0);
+	mv643xx_eth_write_smi_reg(dev, 0, phy_reg_data0);
 
-	eth_port_read_smi_reg(dev, 0, &phy_reg_data0);
+	mv643xx_eth_read_smi_reg(dev, 0, &phy_reg_data0);
 	if ((phy_reg_data0 & 0x1000) == auto_neg)
 		return -ENODEV;				/* change didn't take */
 
 	phy_reg_data0 ^= 0x1000;
-	eth_port_write_smi_reg(dev, 0, phy_reg_data0);
+	mv643xx_eth_write_smi_reg(dev, 0, phy_reg_data0);
 	return 0;
 }
 
@@ -2350,12 +2351,12 @@
  *	PHY address.
  *
  */
-static int ethernet_phy_get(struct net_device *dev)
+static int mv643xx_eth_phy_get(struct net_device *dev)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 	unsigned int reg_data;
 
-	reg_data = mv_read(MV643XX_ETH_PHY_ADDR_REG);
+	reg_data = mv643xx_eth_read(MV643XX_ETH_PHY_ADDR_REG);
 
 	return ((reg_data >> (5 * mp->port_num)) & 0x1f);
 }
@@ -2377,16 +2378,16 @@
  *	None.
  *
  */
-static void ethernet_phy_set(struct net_device *dev, int phy_addr)
+static void mv643xx_eth_phy_set(struct net_device *dev, int phy_addr)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 	u32 reg_data;
 	int addr_shift = 5 * mp->port_num;
 
-	reg_data = mv_read(MV643XX_ETH_PHY_ADDR_REG);
+	reg_data = mv643xx_eth_read(MV643XX_ETH_PHY_ADDR_REG);
 	reg_data &= ~(0x1f << addr_shift);
 	reg_data |= (phy_addr & 0x1f) << addr_shift;
-	mv_write(MV643XX_ETH_PHY_ADDR_REG, reg_data);
+	mv643xx_eth_write(MV643XX_ETH_PHY_ADDR_REG, reg_data);
 }
 
 /*
@@ -2405,14 +2406,14 @@
  *	None.
  *
  */
-static void ethernet_phy_reset(struct net_device *dev)
+static void mv643xx_eth_phy_reset(struct net_device *dev)
 {
 	unsigned int phy_reg_data;
 
 	/* Reset the PHY */
-	eth_port_read_smi_reg(dev, 0, &phy_reg_data);
+	mv643xx_eth_read_smi_reg(dev, 0, &phy_reg_data);
 	phy_reg_data |= 0x8000;	/* Set bit 15 to reset the PHY */
-	eth_port_write_smi_reg(dev, 0, phy_reg_data);
+	mv643xx_eth_write_smi_reg(dev, 0, phy_reg_data);
 }
 
 /*
@@ -2433,49 +2434,49 @@
  *	None.
  *
  */
-static void eth_port_reset(struct net_device *dev)
+static void mv643xx_eth_port_reset(struct net_device *dev)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 	unsigned int port_num = mp->port_num;
 	unsigned int reg_data;
 
 	/* Stop Tx port activity. Check port Tx activity. */
-	reg_data = mv_read(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num));
+	reg_data = mv643xx_eth_read(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num));
 
 	if (reg_data & 0xFF) {
 		/* Issue stop command for active channels only */
-		mv_write(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num),
+		mv643xx_eth_write(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num),
 							(reg_data << 8));
 
 		/* Wait for all Tx activity to terminate. */
 		/* Check port cause register that all Tx queues are stopped */
-		while (mv_read(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num))
+		while (mv643xx_eth_read(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num))
 									& 0xFF)
 			udelay(10);
 	}
 
 	/* Stop Rx port activity. Check port Rx activity. */
-	reg_data = mv_read(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num));
+	reg_data = mv643xx_eth_read(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num));
 
 	if (reg_data & 0xFF) {
 		/* Issue stop command for active channels only */
-		mv_write(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num),
+		mv643xx_eth_write(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num),
 							(reg_data << 8));
 
 		/* Wait for all Rx activity to terminate. */
 		/* Check port cause register that all Rx queues are stopped */
-		while (mv_read(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num))
+		while (mv643xx_eth_read(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num))
 									& 0xFF)
 			udelay(10);
 	}
 
 	/* Clear all MIB counters */
-	eth_clear_mib_counters(dev);
+	mv643xx_eth_clear_mib_counters(dev);
 
 	/* Reset the Enable bit in the Configuration Register */
-	reg_data = mv_read(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num));
+	reg_data = mv643xx_eth_read(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num));
 	reg_data &= ~MV643XX_ETH_SERIAL_PORT_ENABLE;
-	mv_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num), reg_data);
+	mv643xx_eth_write(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num), reg_data);
 }
 
 /*
@@ -2497,16 +2498,16 @@
  *	None.
  *
  */
-static void ethernet_set_config_reg(struct net_device *dev,
-				    unsigned int value)
+static void mv643xx_eth_set_config_reg(struct net_device *dev,
+				       unsigned int value)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 	unsigned int eth_port_num = mp->port_num;
 	unsigned int eth_config_reg;
 
-	eth_config_reg = mv_read(MV643XX_ETH_PORT_CONFIG_REG(eth_port_num));
+	eth_config_reg = mv643xx_eth_read(MV643XX_ETH_PORT_CONFIG_REG(eth_port_num));
 	eth_config_reg |= value;
-	mv_write(MV643XX_ETH_PORT_CONFIG_REG(eth_port_num), eth_config_reg);
+	mv643xx_eth_write(MV643XX_ETH_PORT_CONFIG_REG(eth_port_num), eth_config_reg);
 }
 
 /*
@@ -2525,12 +2526,12 @@
  * RETURN:
  *	Port configuration register value.
  */
-static unsigned int ethernet_get_config_reg(struct net_device *dev)
+static unsigned int mv643xx_eth_get_config_reg(struct net_device *dev)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 	unsigned int eth_config_reg;
 
-	eth_config_reg = mv_read(MV643XX_ETH_PORT_CONFIG_EXTEND_REG
+	eth_config_reg = mv643xx_eth_read(MV643XX_ETH_PORT_CONFIG_EXTEND_REG
 								(mp->port_num));
 	return eth_config_reg;
 }
@@ -2555,10 +2556,10 @@
  *	true otherwise.
  *
  */
-static void eth_port_read_smi_reg(struct net_device *dev,
+static void mv643xx_eth_read_smi_reg(struct net_device *dev,
 				unsigned int phy_reg, unsigned int *value)
 {
-	int phy_addr = ethernet_phy_get(dev);
+	int phy_addr = mv643xx_eth_phy_get(dev);
 	unsigned long flags;
 	int i;
 
@@ -2566,7 +2567,7 @@
 	spin_lock_irqsave(&mv643xx_eth_phy_lock, flags);
 
 	/* wait for the SMI register to become available */
-	for (i = 0; mv_read(MV643XX_ETH_SMI_REG) & ETH_SMI_BUSY; i++) {
+	for (i = 0; mv643xx_eth_read(MV643XX_ETH_SMI_REG) & ETH_SMI_BUSY; i++) {
 		if (i == PHY_WAIT_ITERATIONS) {
 			printk(KERN_ERR "%s: PHY busy timeout\n", 
 			       dev->name);
@@ -2575,11 +2576,11 @@
 		udelay(PHY_WAIT_MICRO_SECONDS);
 	}
 
-	mv_write(MV643XX_ETH_SMI_REG,
+	mv643xx_eth_write(MV643XX_ETH_SMI_REG,
 		(phy_addr << 16) | (phy_reg << 21) | ETH_SMI_OPCODE_READ);
 
 	/* now wait for the data to be valid */
-	for (i = 0; !(mv_read(MV643XX_ETH_SMI_REG) & ETH_SMI_READ_VALID); i++) {
+	for (i = 0; !(mv643xx_eth_read(MV643XX_ETH_SMI_REG) & ETH_SMI_READ_VALID); i++) {
 		if (i == PHY_WAIT_ITERATIONS) {
 			printk(KERN_ERR "%s: PHY read timeout\n",
 			       dev->name);
@@ -2588,7 +2589,7 @@
 		udelay(PHY_WAIT_MICRO_SECONDS);
 	}
 
-	*value = mv_read(MV643XX_ETH_SMI_REG) & 0xffff;
+	*value = mv643xx_eth_read(MV643XX_ETH_SMI_REG) & 0xffff;
 out:
 	spin_unlock_irqrestore(&mv643xx_eth_phy_lock, flags);
 }
@@ -2613,20 +2614,20 @@
  *	true otherwise.
  *
  */
-static void eth_port_write_smi_reg(struct net_device *dev,
-				   unsigned int phy_reg, unsigned int value)
+static void mv643xx_eth_write_smi_reg(struct net_device *dev,
+				      unsigned int phy_reg, unsigned int value)
 {
 	int phy_addr;
 	int i;
 	unsigned long flags;
 
-	phy_addr = ethernet_phy_get(dev);
+	phy_addr = mv643xx_eth_phy_get(dev);
 
 	/* the SMI register is a shared resource */
 	spin_lock_irqsave(&mv643xx_eth_phy_lock, flags);
 
 	/* wait for the SMI register to become available */
-	for (i = 0; mv_read(MV643XX_ETH_SMI_REG) & ETH_SMI_BUSY; i++) {
+	for (i = 0; mv643xx_eth_read(MV643XX_ETH_SMI_REG) & ETH_SMI_BUSY; i++) {
 		if (i == PHY_WAIT_ITERATIONS) {
 			printk(KERN_ERR "%s: PHY busy timeout\n", 
 			       dev->name);
@@ -2635,7 +2636,7 @@
 		udelay(PHY_WAIT_MICRO_SECONDS);
 	}
 
-	mv_write(MV643XX_ETH_SMI_REG, (phy_addr << 16) | (phy_reg << 21) |
+	mv643xx_eth_write(MV643XX_ETH_SMI_REG, (phy_addr << 16) | (phy_reg << 21) |
 				ETH_SMI_OPCODE_WRITE | (value & 0xffff));
 out:
 	spin_unlock_irqrestore(&mv643xx_eth_phy_lock, flags);
@@ -2644,17 +2645,17 @@
 /*
  * Wrappers for MII support library.
  */
-static int mv643xx_mdio_read(struct net_device *dev, int phy_id, int location)
+static int mv643xx_eth_mdio_read(struct net_device *dev, int phy_id, int location)
 {
 	int val;
 
-	eth_port_read_smi_reg(dev, location, &val);
+	mv643xx_eth_read_smi_reg(dev, location, &val);
 	return val;
 }
 
-static void mv643xx_mdio_write(struct net_device *dev, int phy_id, int location, int val)
+static void mv643xx_eth_mdio_write(struct net_device *dev, int phy_id, int location, int val)
 {
-	eth_port_write_smi_reg(dev, location, val);
+	mv643xx_eth_write_smi_reg(dev, location, val);
 }
 
 /*
@@ -2688,9 +2689,10 @@
 /*
  * Modified to include the first descriptor pointer in case of SG
  */
-static int eth_port_send(struct net_device *dev,
+static int mv643xx_eth_tx_packet(struct net_device *dev,
 			 struct pkt_info *p_pkt_info)
 {
+	struct mv643xx_private *mp = netdev_priv(dev);
 	int tx_desc_curr, tx_desc_used, tx_first_desc, tx_next_desc;
 	struct eth_tx_desc *current_descriptor;
 	struct eth_tx_desc *first_descriptor;
@@ -2780,8 +2782,8 @@
 	return status;
 }
 #else
-static int eth_port_send(struct net_device *dev,
-			 struct pkt_info *p_pkt_info)
+static int mv643xx_eth_tx_packet(struct net_device *dev,
+			 	 struct pkt_info *p_pkt_info)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 	int tx_desc_curr;
@@ -2808,8 +2810,7 @@
 
 	if (netif_msg_tx_queued(mp))
 		printk(KERN_DEBUG "%s: send pkt: desc=%d len=%d, f/l=%d/%d\n",
-		       dev->name, tx_desc_curr,
-		       p_pkt_info->byte_cnt, 
+		       dev->name, tx_desc_curr, p_pkt_info->byte_cnt,
 		       ((command_status & ETH_TX_FIRST_DESC) != 0),
 		       ((command_status & ETH_TX_LAST_DESC) != 0));
 
@@ -2868,8 +2869,8 @@
  *	ETH_OK otherwise.
  *
  */
-static int eth_tx_return_desc(struct net_device *dev,
-			      struct pkt_info *p_pkt_info)
+static int mv643xx_eth_tx_return_desc(struct net_device *dev,
+				      struct pkt_info *p_pkt_info)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 	int tx_desc_used;
@@ -2937,8 +2938,8 @@
  *	ETH_END_OF_JOB if there is no received data.
  *	ETH_OK otherwise.
  */
-static int eth_port_receive(struct net_device *dev,
-						struct pkt_info *p_pkt_info)
+static int mv643xx_eth_rx_packet(struct net_device *dev,
+				 struct pkt_info *p_pkt_info)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 	int rx_next_curr_desc, rx_curr_desc, rx_used_desc;
@@ -2971,8 +2972,7 @@
 
 	if (netif_msg_rx_status(mp))
 		printk(KERN_DEBUG "%s: rcv pkt: len=%d, desc=%d, f/l=%d/%d\n",
-		       dev->name, 
-		       p_pkt_info->byte_cnt, rx_curr_desc,
+		       dev->name, p_pkt_info->byte_cnt, rx_curr_desc,
 		       ((command_status & ETH_RX_FIRST_DESC) != 0),
 		       ((command_status & ETH_RX_LAST_DESC) != 0));
 
@@ -3011,8 +3011,8 @@
  *	ETH_ERROR in case the routine can not access Rx desc ring.
  *	ETH_OK otherwise.
  */
-static void eth_rx_return_buff(struct net_device *dev,
-			       struct pkt_info *p_pkt_info)
+static void mv643xx_eth_rx_return_buff(struct net_device *dev,
+				       struct pkt_info *p_pkt_info)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 	int used_rx_desc;	/* Where to return Rx resource */
@@ -3102,7 +3102,7 @@
 	sizeof(mv643xx_gstrings_stats) / sizeof(struct mv643xx_stats)
 
 static int
-mv643xx_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
+mv643xx_eth_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 {
 	int rc;
 	struct mv643xx_private *mp = netdev_priv(netdev);
@@ -3118,7 +3118,7 @@
 }
 
 static void
-mv643xx_get_drvinfo(struct net_device *netdev,
+mv643xx_eth_get_drvinfo(struct net_device *netdev,
                        struct ethtool_drvinfo *drvinfo)
 {
 	strncpy(drvinfo->driver,  mv643xx_driver_name, 32);
@@ -3129,19 +3129,18 @@
 }
 
 static int 
-mv643xx_get_stats_count(struct net_device *netdev)
+mv643xx_eth_get_stats_count(struct net_device *netdev)
 {
 	return MV643XX_STATS_LEN;
 }
 
-static void 
-mv643xx_get_ethtool_stats(struct net_device *netdev, 
-		struct ethtool_stats *stats, uint64_t *data)
+static void mv643xx_eth_get_ethtool_stats(struct net_device *dev,
+				struct ethtool_stats *stats, uint64_t *data)
 {
-	struct mv643xx_private *mp = netdev->priv;
+	struct mv643xx_private *mp = netdev_priv(dev);
 	int i;
 
-	eth_update_mib_counters(netdev);
+	mv643xx_eth_update_mib_counters(dev);
 
 	for(i = 0; i < MV643XX_STATS_LEN; i++) {
 		char *p = (char *)mp+mv643xx_gstrings_stats[i].stat_offset;	
@@ -3151,7 +3150,7 @@
 }
 
 static void 
-mv643xx_get_strings(struct net_device *netdev, uint32_t stringset, uint8_t *data)
+mv643xx_eth_get_strings(struct net_device *netdev, uint32_t stringset, uint8_t *data)
 {
 	int i;
 
@@ -3199,18 +3198,15 @@
 }
 
 static struct ethtool_ops mv643xx_ethtool_ops = {
-	.get_settings           = mv643xx_get_settings,
-	.set_settings           = mv643xx_set_settings,
-	.get_drvinfo            = mv643xx_get_drvinfo,
-	.get_link               = mv643xx_eth_get_link,
+	.get_settings           = mv643xx_eth_get_settings,
+	.set_settings           = mv643xx_eth_set_settings,
+	.get_drvinfo            = mv643xx_eth_get_drvinfo,
+	.get_link		= mv643xx_eth_get_link,
 	.get_sg			= ethtool_op_get_sg,
 	.set_sg			= ethtool_op_set_sg,
-	.get_strings            = mv643xx_get_strings,
-	.get_stats_count        = mv643xx_get_stats_count,
-	.get_ethtool_stats      = mv643xx_get_ethtool_stats,
-	.get_strings            = mv643xx_get_strings,
-	.get_stats_count        = mv643xx_get_stats_count,
-	.get_ethtool_stats      = mv643xx_get_ethtool_stats,
+	.get_strings            = mv643xx_eth_get_strings,
+	.get_stats_count        = mv643xx_eth_get_stats_count,
+	.get_ethtool_stats      = mv643xx_eth_get_ethtool_stats,
 	.get_msglevel		= mv643xx_eth_get_msglevel,
 	.set_msglevel		= mv643xx_eth_set_msglevel,
 	.nway_reset		= mv643xx_eth_nway_restart,
