From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: mv643xx(9/20): make internal functions take device pointer param consistently
Date: Mon, 28 Mar 2005 16:49:13 -0700
Message-ID: <20050328234913.GI29098@xyzzy>
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

Some internal driver functions take int port_num as a parameter to
identify the device. It makes no sense to hide the internal device
structure data from these routines so pass a pointer to the net_device
structure instead. Although in many cases the device data is needed only
to get the port number, this change makes the code more consistent and
easier to maintain.

Signed-off-by: James Chapman <jchapman@katalix.com>
Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

Index: linux-2.5-enet/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.5-enet.orig/drivers/net/mv643xx_eth.c
+++ linux-2.5-enet/drivers/net/mv643xx_eth.c
@@ -80,50 +80,51 @@
 static int mv643xx_eth_real_stop(struct net_device *);
 static int mv643xx_eth_change_mtu(struct net_device *, int);
 static struct net_device_stats *mv643xx_eth_get_stats(struct net_device *);
-static void eth_port_init_mac_tables(unsigned int eth_port_num);
+static void eth_port_init_mac_tables(struct net_device *dev);
 #ifdef MV643XX_NAPI
 static int mv643xx_poll(struct net_device *dev, int *budget);
 #endif
-static int ethernet_phy_get(unsigned int eth_port_num);
-static void ethernet_phy_set(unsigned int eth_port_num, int phy_addr);
-static int ethernet_phy_detect(struct mv643xx_private *mp);
+static int ethernet_phy_get(struct net_device *dev);
+static void ethernet_phy_set(struct net_device *dev, int phy_addr);
+static void ethernet_phy_reset(struct net_device *dev);
+static int ethernet_phy_detect(struct net_device *dev);
 static int mv643xx_mdio_read(struct net_device *dev, int phy_id, int location);
 static void mv643xx_mdio_write(struct net_device *dev, int phy_id, int location, int val);
 static int mv643xx_eth_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
 static struct ethtool_ops mv643xx_ethtool_ops;
 
 /* Port operation control routines */
-static void eth_port_init(struct mv643xx_private *mp);
-static void eth_port_reset(unsigned int eth_port_num);
-static void eth_port_start(struct mv643xx_private *mp);
+static void eth_port_init(struct net_device *dev);
+static void eth_port_reset(struct net_device *dev);
+static void eth_port_start(struct net_device *dev);
 
-static void ethernet_set_config_reg(unsigned int eth_port_num,
+static void ethernet_set_config_reg(struct net_device *dev,
 				    unsigned int value);
-static unsigned int ethernet_get_config_reg(unsigned int eth_port_num);
+static unsigned int ethernet_get_config_reg(struct net_device *dev);
 
 /* Port MAC address routines */
-static void eth_port_uc_addr_set(unsigned int eth_port_num,
+static void eth_port_uc_addr_set(struct net_device *dev,
 				 unsigned char *p_addr);
 
 /* PHY and MIB routines */
-static void ethernet_phy_reset(struct mv643xx_private *mp);
+static void ethernet_phy_reset(struct net_device *dev);
 
-static void eth_port_write_smi_reg(struct mv643xx_private *mp,
+static void eth_port_write_smi_reg(struct net_device *dev,
 				   unsigned int phy_reg, unsigned int value);
 
-static void eth_port_read_smi_reg(struct mv643xx_private *mp,
+static void eth_port_read_smi_reg(struct net_device *dev,
 				  unsigned int phy_reg, unsigned int *value);
 
-static void eth_clear_mib_counters(unsigned int eth_port_num);
+static void eth_clear_mib_counters(struct net_device *dev);
 
 /* Port data flow control routines */
-static int eth_port_send(struct mv643xx_private *mp,
+static int eth_port_send(struct net_device *dev,
 			 struct pkt_info *p_pkt_info);
-static int eth_tx_return_desc(struct mv643xx_private *mp,
+static int eth_tx_return_desc(struct net_device *dev,
 			      struct pkt_info *p_pkt_info);
-static int eth_port_receive(struct mv643xx_private *mp,
+static int eth_port_receive(struct net_device *dev,
 			    struct pkt_info *p_pkt_info);
-static void eth_rx_return_buff(struct mv643xx_private *mp,
+static void eth_rx_return_buff(struct net_device *dev,
 			       struct pkt_info *p_pkt_info);
 
 static char mv643xx_driver_name[] = "mv643xx_eth";
@@ -220,7 +221,7 @@
 		pkt_info.buf_ptr = dma_map_single(NULL, skb->data, RX_SKB_SIZE,
 							DMA_FROM_DEVICE);
 		pkt_info.return_info = skb;
-		eth_rx_return_buff(mp, &pkt_info);
+		eth_rx_return_buff(dev, &pkt_info);
 		skb_reserve(skb, 2);
 	}
 	clear_bit(0, &mp->rx_task_busy);
@@ -275,11 +276,10 @@
 static void mv643xx_eth_update_mac_address(struct net_device *dev)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
-	unsigned int port_num = mp->port_num;
 
-	eth_port_init_mac_tables(port_num);
+	eth_port_init_mac_tables(dev);
 	memcpy(mp->port_mac_addr, dev->dev_addr, 6);
-	eth_port_uc_addr_set(port_num, mp->port_mac_addr);
+	eth_port_uc_addr_set(dev, mp->port_mac_addr);
 }
 
 /*
@@ -292,15 +292,14 @@
  */
 static void mv643xx_eth_set_rx_mode(struct net_device *dev)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
 	u32 config_reg;
 
-	config_reg = ethernet_get_config_reg(mp->port_num);
+	config_reg = ethernet_get_config_reg(dev);
 	if (dev->flags & IFF_PROMISC)
 		config_reg |= (u32) MV643XX_ETH_UNICAST_PROMISCUOUS_MODE;
 	else
 		config_reg &= ~(u32) MV643XX_ETH_UNICAST_PROMISCUOUS_MODE;
-	ethernet_set_config_reg(mp->port_num, config_reg);
+	ethernet_set_config_reg(dev, config_reg);
 }
 
 /*
@@ -351,11 +350,9 @@
  */
 static void mv643xx_eth_tx_timeout_task(struct net_device *dev)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
-
 	netif_device_detach(dev);
-	eth_port_reset(mp->port_num);
-	eth_port_start(mp);
+	eth_port_reset(dev);
+	eth_port_start(dev);
 	netif_device_attach(dev);
 }
 
@@ -380,7 +377,7 @@
 	spin_lock(&mp->lock);
 
 	/* Check only queue 0 */
-	while (eth_tx_return_desc(mp, &pkt_info) == 0) {
+	while (eth_tx_return_desc(dev, &pkt_info) == 0) {
 		if (pkt_info.cmd_sts & BIT0) {
 			if (netif_msg_tx_err(mp))
 				printk(KERN_WARNING "%s: Error in TX: cmd_sts=%08x\n",
@@ -449,9 +446,9 @@
 	struct pkt_info pkt_info;
 
 #ifdef MV643XX_NAPI
-	while (eth_port_receive(mp, &pkt_info) == 0 && budget > 0) {
+	while (eth_port_receive(dev, &pkt_info) == 0 && budget > 0) {
 #else
-	while (eth_port_receive(mp, &pkt_info) == 0) {
+	while (eth_port_receive(dev, &pkt_info) == 0) {
 #endif
 		mp->rx_ring_skbs--;
 		received_packets++;
@@ -829,7 +826,6 @@
 static int mv643xx_eth_open(struct net_device *dev)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
-	unsigned int port_num = mp->port_num;
 	int err;
 
 	spin_lock_irq(&mp->lock);
@@ -838,8 +834,8 @@
 			SA_SHIRQ | SA_SAMPLE_RANDOM, dev->name, dev);
 
 	if (err) {
-		printk(KERN_ERR "Can not assign IRQ number to MV643XX_eth%d\n",
-								port_num);
+		printk(KERN_ERR "%s: Cannot assign IRQ number\n",
+		       dev->name);
 		err = -EAGAIN;
 		goto out;
 	}
@@ -879,7 +875,7 @@
  *	with physical addresses.
  *
  * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port Control srtuct.
+ *	struct net_device *dev	Ethernet Port Control srtuct.
  *
  * OUTPUT:
  *	The routine updates the Ethernet port control struct with information
@@ -888,8 +884,9 @@
  * RETURN:
  *	None.
  */
-static void ether_init_rx_desc_ring(struct mv643xx_private *mp)
+static void ether_init_rx_desc_ring(struct net_device *dev)
 {
+	struct mv643xx_private *mp = netdev_priv(dev);
 	volatile struct eth_rx_desc *p_rx_desc;
 	int rx_desc_num = mp->rx_ring_size;
 	int i;
@@ -924,7 +921,7 @@
  *	with physical addresses.
  *
  * INPUT:
- *	struct mv643xx_private *mp	Ethernet Port Control srtuct.
+ *	struct net_device *dev	Ethernet Port Control srtuct.
  *
  * OUTPUT:
  *	The routine updates the Ethernet port control struct with information
@@ -933,8 +930,9 @@
  * RETURN:
  *	None.
  */
-static void ether_init_tx_desc_ring(struct mv643xx_private *mp)
+static void ether_init_tx_desc_ring(struct net_device *dev)
 {
+	struct mv643xx_private *mp = netdev_priv(dev);
 	int tx_desc_num = mp->tx_ring_size;
 	struct eth_tx_desc *p_tx_desc;
 	int i;
@@ -983,7 +981,7 @@
 	/* Set the MAC Address */
 	memcpy(mp->port_mac_addr, dev->dev_addr, 6);
 
-	eth_port_init(mp);
+	eth_port_init(dev);
 
 	INIT_WORK(&mp->rx_task, (void (*)(void *))mv643xx_eth_rx_task, dev);
 
@@ -1033,7 +1031,7 @@
 	BUG_ON((u32) mp->p_tx_desc_area & 0xf);	/* check 16-byte alignment */
 	memset((void *)mp->p_tx_desc_area, 0, mp->tx_desc_area_size);
 
-	ether_init_tx_desc_ring(mp);
+	ether_init_tx_desc_ring(dev);
 
 	/* Allocate RX ring */
 	mp->rx_ring_skbs = 0;
@@ -1063,11 +1061,11 @@
 	}
 	memset((void *)mp->p_rx_desc_area, 0, size);
 
-	ether_init_rx_desc_ring(mp);
+	ether_init_rx_desc_ring(dev);
 
 	mv643xx_eth_rx_task(dev);	/* Fill RX ring with skb's */
 
-	eth_port_start(mp);
+	eth_port_start(dev);
 
 	/* Interrupt Coalescing */
 
@@ -1087,11 +1085,10 @@
 static void mv643xx_eth_free_tx_rings(struct net_device *dev)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
-	unsigned int port_num = mp->port_num;
 	unsigned int curr;
 
 	/* Stop Tx Queues */
-	mv_write(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(port_num), 0x0000ff00);
+	mv_write(MV643XX_ETH_TRANSMIT_QUEUE_COMMAND_REG(mp->port_num), 0x0000ff00);
 
 	/* Free outstanding skb's on TX rings */
 	for (curr = 0; mp->tx_ring_skbs && curr < mp->tx_ring_size; curr++) {
@@ -1115,11 +1112,10 @@
 static void mv643xx_eth_free_rx_rings(struct net_device *dev)
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
-	unsigned int port_num = mp->port_num;
 	int curr;
 
 	/* Stop RX Queues */
-	mv_write(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(port_num), 0x0000ff00);
+	mv_write(MV643XX_ETH_RECEIVE_QUEUE_COMMAND_REG(mp->port_num), 0x0000ff00);
 
 	/* Free preallocated skb's on RX rings */
 	for (curr = 0; mp->rx_ring_skbs && curr < mp->rx_ring_size; curr++) {
@@ -1165,7 +1161,7 @@
 	mv643xx_eth_free_tx_rings(dev);
 	mv643xx_eth_free_rx_rings(dev);
 
-	eth_port_reset(mp->port_num);
+	eth_port_reset(dev);
 
 	/* Disable ethernet port interrupts */
 	mv_write(MV643XX_ETH_INTERRUPT_CAUSE_REG(port_num), 0);
@@ -1200,7 +1196,7 @@
 	struct mv643xx_private *mp = netdev_priv(dev);
 	struct pkt_info pkt_info;
 
-	while (eth_tx_return_desc(mp, &pkt_info) == 0) {
+	while (eth_tx_return_desc(dev, &pkt_info) == 0) {
 		if (pkt_info.return_info) {
 			if (skb_shinfo(pkt_info.return_info)->nr_frags)
 				dma_unmap_page(NULL, pkt_info.buf_ptr,
@@ -1351,7 +1347,7 @@
 							DMA_TO_DEVICE);
 		pkt_info.return_info = skb;
 		mp->tx_ring_skbs++;
-		status = eth_port_send(mp, &pkt_info);
+		status = eth_port_send(dev, &pkt_info);
 		if (status < 0)
 			goto out;
 
@@ -1409,7 +1405,7 @@
 			}
 		}
 
-		status = eth_port_send(mp, &pkt_info);
+		status = eth_port_send(dev, &pkt_info);
 		if (status < 0)
 			goto out;
 
@@ -1438,7 +1434,7 @@
 							this_frag->size,
 							DMA_TO_DEVICE);
 
-			status = eth_port_send(mp, &pkt_info);
+			status = eth_port_send(dev, &pkt_info);
 			if (status < 0)
 				goto out;
 
@@ -1454,8 +1450,8 @@
 								DMA_TO_DEVICE);
 	pkt_info.return_info = skb;
 	mp->tx_ring_skbs++;
-	status = eth_port_send(mp, &pkt_info);
-	if (status == 0)
+	status = eth_port_send(dev, &pkt_info);
+	if (status < 0)
 		goto out;
 
 	stats->tx_bytes += pkt_info.byte_cnt;
@@ -1532,7 +1528,6 @@
 	dev_set_drvdata(ddev, dev);
 
 	mp = netdev_priv(dev);
-	mp->netdev = dev;
 
 	/* By default, log probe, interface up/down and error events */
 	mp->msg_enable = NETIF_MSG_PROBE | NETIF_MSG_IFUP | NETIF_MSG_IFDOWN |
@@ -1624,7 +1619,7 @@
 						    ADVERTISED_Autoneg	      |
 						    ADVERTISED_MII;
 
-			ethernet_phy_set(port_num, ecmd->phy_address);
+			ethernet_phy_set(dev, ecmd->phy_address);
 			memcpy(&mp->ethtool_cmd, ecmd, sizeof *ecmd);
 			mv643xx_eth_update_pscr(dev, ecmd);
 		}
@@ -1634,15 +1629,15 @@
 	mp->mii.dev = dev;
 	mp->mii.mdio_read = mv643xx_mdio_read;
 	mp->mii.mdio_write = mv643xx_mdio_write;
-	mp->mii.phy_id = ethernet_phy_get(port_num);
+	mp->mii.phy_id = ethernet_phy_get(dev);
 	mp->mii.phy_id_mask = 0x3f;
 	mp->mii.reg_num_mask = 0x1f;
 
-	err = ethernet_phy_detect(mp);
+	err = ethernet_phy_detect(dev);
 	if (err) {
 		printk(KERN_ERR "MV643xx ethernet port %d: "
 		       "No PHY detected at addr %d\n",
-		       port_num, ethernet_phy_get(port_num));
+		       port_num, ethernet_phy_get(dev));
 		return err;
 	}
 
@@ -1939,10 +1934,6 @@
 
 /* locals */
 
-/* PHY routines */
-static int ethernet_phy_get(unsigned int eth_port_num);
-static void ethernet_phy_set(unsigned int eth_port_num, int phy_addr);
-
 /* Ethernet Port routines */
 static int eth_port_uc_addr(unsigned int eth_port_num, unsigned char uc_nibble,
 								int option);
@@ -1963,7 +1954,7 @@
  *	struct.
  *
  * INPUT:
- *	struct mv643xx_private *mp	Ethernet port control struct
+ *	struct net_device *dev	Ethernet port control struct
  *
  * OUTPUT:
  *	See description.
@@ -1971,19 +1962,21 @@
  * RETURN:
  *	None.
  */
-static void eth_port_init(struct mv643xx_private *mp)
+static void eth_port_init(struct net_device *dev)
 {
+	struct mv643xx_private *mp = netdev_priv(dev);
+
 	mp->port_rx_queue_command = 0;
 	mp->port_tx_queue_command = 0;
 
 	mp->rx_resource_err = 0;
 	mp->tx_resource_err = 0;
 
-	eth_port_reset(mp->port_num);
+	eth_port_reset(dev);
 
-	eth_port_init_mac_tables(mp->port_num);
+	eth_port_init_mac_tables(dev);
 
-	ethernet_phy_reset(mp);
+	ethernet_phy_reset(dev);
 }
 
 /*
@@ -2005,7 +1998,7 @@
  *	and ether_init_rx_desc_ring for Rx queues).
  *
  * INPUT:
- *	struct mv643xx_private *mp	Ethernet port control struct
+ *	struct net_device *dev	Ethernet port control struct
  *
  * OUTPUT:
  *	Ethernet port is ready to receive and transmit.
@@ -2013,8 +2006,9 @@
  * RETURN:
  *	None.
  */
-static void eth_port_start(struct mv643xx_private *mp)
+static void eth_port_start(struct net_device *dev)
 {
+	struct mv643xx_private *mp = netdev_priv(dev);
 	unsigned int port_num = mp->port_num;
 	int tx_curr_desc, rx_curr_desc;
 
@@ -2029,7 +2023,7 @@
 		(u32)((struct eth_rx_desc *)mp->rx_desc_dma + rx_curr_desc));
 
 	/* Add the assigned Ethernet address to the port's address table */
-	eth_port_uc_addr_set(port_num, mp->port_mac_addr);
+	eth_port_uc_addr_set(dev, mp->port_mac_addr);
 
 	/* Assign port configuration and command. */
 	mv_write(MV643XX_ETH_PORT_CONFIG_REG(port_num),
@@ -2082,9 +2076,11 @@
  *	N/A.
  *
  */
-static void eth_port_uc_addr_set(unsigned int eth_port_num,
-							unsigned char *p_addr)
+static void eth_port_uc_addr_set(struct net_device *dev,
+				 unsigned char *p_addr)
 {
+	struct mv643xx_private *mp = netdev_priv(dev);
+	unsigned int eth_port_num = mp->port_num;
 	unsigned int mac_h;
 	unsigned int mac_l;
 
@@ -2218,9 +2214,11 @@
  * RETURN:
  *	None.
  */
-static void eth_port_init_mac_tables(unsigned int eth_port_num)
+static void eth_port_init_mac_tables(struct net_device *dev)
 {
+	struct mv643xx_private *mp = netdev_priv(dev);
 	int table_index;
+	unsigned int eth_port_num = mp->port_num;
 
 	/* Clear DA filter unicast table (Ex_dFUT) */
 	for (table_index = 0; table_index <= 0xC; table_index += 4)
@@ -2254,8 +2252,10 @@
  *	MIB counter value.
  *
  */
-static void eth_clear_mib_counters(unsigned int eth_port_num)
+static void eth_clear_mib_counters(struct net_device *dev)
 {
+	struct mv643xx_private *mp = netdev_priv(dev);
+	unsigned int eth_port_num = mp->port_num;
 	int i;
 
 	/* Perform dummy reads from MIB counters */
@@ -2264,34 +2264,37 @@
 		mv_read(MV643XX_ETH_MIB_COUNTERS_BASE(eth_port_num) + i);
 }
 
-static inline u32 read_mib(struct mv643xx_private *mp, int offset)
+static inline u32 read_mib(struct net_device *dev, int offset)
 {
+	struct mv643xx_private *mp = netdev_priv(dev);
+
 	return mv_read(MV643XX_ETH_MIB_COUNTERS_BASE(mp->port_num) + offset);
 }
 
-static void eth_update_mib_counters(struct mv643xx_private *mp)
+static void eth_update_mib_counters(struct net_device *dev)
 {
+	struct mv643xx_private *mp = netdev_priv(dev);
 	struct mv643xx_mib_counters *p = &mp->mib_counters;
 	int offset;
 
 	p->good_octets_received +=
-		read_mib(mp, ETH_MIB_GOOD_OCTETS_RECEIVED_LOW);
+		read_mib(dev, ETH_MIB_GOOD_OCTETS_RECEIVED_LOW);
 	p->good_octets_received +=
-		(u64)read_mib(mp, ETH_MIB_GOOD_OCTETS_RECEIVED_HIGH) << 32;
+		(u64)read_mib(dev, ETH_MIB_GOOD_OCTETS_RECEIVED_HIGH) << 32;
 
 	for (offset = ETH_MIB_BAD_OCTETS_RECEIVED;
 			offset <= ETH_MIB_FRAMES_1024_TO_MAX_OCTETS;
 			offset += 4)
-		*(u32 *)((char *)p + offset) = read_mib(mp, offset);
+		*(u32 *)((char *)p + offset) = read_mib(dev, offset);
 
-	p->good_octets_sent += read_mib(mp, ETH_MIB_GOOD_OCTETS_SENT_LOW);
+	p->good_octets_sent += read_mib(dev, ETH_MIB_GOOD_OCTETS_SENT_LOW);
 	p->good_octets_sent +=
-		(u64)read_mib(mp, ETH_MIB_GOOD_OCTETS_SENT_HIGH) << 32;
+		(u64)read_mib(dev, ETH_MIB_GOOD_OCTETS_SENT_HIGH) << 32;
 
 	for (offset = ETH_MIB_GOOD_FRAMES_SENT;
 			offset <= ETH_MIB_LATE_COLLISION;
 			offset += 4)
-		*(u32 *)((char *)p + offset) = read_mib(mp, offset);
+		*(u32 *)((char *)p + offset) = read_mib(dev, offset);
 }
 
 /*
@@ -2312,22 +2315,22 @@
  *	-ENODEV on failure
  *
  */
-static int ethernet_phy_detect(struct mv643xx_private *mp)
+static int ethernet_phy_detect(struct net_device *dev)
 {
 	unsigned int phy_reg_data0;
 	int auto_neg;
 
-	eth_port_read_smi_reg(mp, 0, &phy_reg_data0);
+	eth_port_read_smi_reg(dev, 0, &phy_reg_data0);
 	auto_neg = phy_reg_data0 & 0x1000;
 	phy_reg_data0 ^= 0x1000;	/* invert auto_neg */
-	eth_port_write_smi_reg(mp, 0, phy_reg_data0);
+	eth_port_write_smi_reg(dev, 0, phy_reg_data0);
 
-	eth_port_read_smi_reg(mp, 0, &phy_reg_data0);
+	eth_port_read_smi_reg(dev, 0, &phy_reg_data0);
 	if ((phy_reg_data0 & 0x1000) == auto_neg)
 		return -ENODEV;				/* change didn't take */
 
 	phy_reg_data0 ^= 0x1000;
-	eth_port_write_smi_reg(mp, 0, phy_reg_data0);
+	eth_port_write_smi_reg(dev, 0, phy_reg_data0);
 	return 0;
 }
 
@@ -2347,13 +2350,14 @@
  *	PHY address.
  *
  */
-static int ethernet_phy_get(unsigned int eth_port_num)
+static int ethernet_phy_get(struct net_device *dev)
 {
+	struct mv643xx_private *mp = netdev_priv(dev);
 	unsigned int reg_data;
 
 	reg_data = mv_read(MV643XX_ETH_PHY_ADDR_REG);
 
-	return ((reg_data >> (5 * eth_port_num)) & 0x1f);
+	return ((reg_data >> (5 * mp->port_num)) & 0x1f);
 }
 
 /*
@@ -2373,10 +2377,11 @@
  *	None.
  *
  */
-static void ethernet_phy_set(unsigned int eth_port_num, int phy_addr)
+static void ethernet_phy_set(struct net_device *dev, int phy_addr)
 {
+	struct mv643xx_private *mp = netdev_priv(dev);
 	u32 reg_data;
-	int addr_shift = 5 * eth_port_num;
+	int addr_shift = 5 * mp->port_num;
 
 	reg_data = mv_read(MV643XX_ETH_PHY_ADDR_REG);
 	reg_data &= ~(0x1f << addr_shift);
@@ -2400,14 +2405,14 @@
  *	None.
  *
  */
-static void ethernet_phy_reset(struct mv643xx_private *mp)
+static void ethernet_phy_reset(struct net_device *dev)
 {
 	unsigned int phy_reg_data;
 
 	/* Reset the PHY */
-	eth_port_read_smi_reg(mp, 0, &phy_reg_data);
+	eth_port_read_smi_reg(dev, 0, &phy_reg_data);
 	phy_reg_data |= 0x8000;	/* Set bit 15 to reset the PHY */
-	eth_port_write_smi_reg(mp, 0, phy_reg_data);
+	eth_port_write_smi_reg(dev, 0, phy_reg_data);
 }
 
 /*
@@ -2428,8 +2433,10 @@
  *	None.
  *
  */
-static void eth_port_reset(unsigned int port_num)
+static void eth_port_reset(struct net_device *dev)
 {
+	struct mv643xx_private *mp = netdev_priv(dev);
+	unsigned int port_num = mp->port_num;
 	unsigned int reg_data;
 
 	/* Stop Tx port activity. Check port Tx activity. */
@@ -2463,7 +2470,7 @@
 	}
 
 	/* Clear all MIB counters */
-	eth_clear_mib_counters(port_num);
+	eth_clear_mib_counters(dev);
 
 	/* Reset the Enable bit in the Configuration Register */
 	reg_data = mv_read(MV643XX_ETH_PORT_SERIAL_CONTROL_REG(port_num));
@@ -2490,9 +2497,11 @@
  *	None.
  *
  */
-static void ethernet_set_config_reg(unsigned int eth_port_num,
-							unsigned int value)
+static void ethernet_set_config_reg(struct net_device *dev,
+				    unsigned int value)
 {
+	struct mv643xx_private *mp = netdev_priv(dev);
+	unsigned int eth_port_num = mp->port_num;
 	unsigned int eth_config_reg;
 
 	eth_config_reg = mv_read(MV643XX_ETH_PORT_CONFIG_REG(eth_port_num));
@@ -2516,12 +2525,13 @@
  * RETURN:
  *	Port configuration register value.
  */
-static unsigned int ethernet_get_config_reg(unsigned int eth_port_num)
+static unsigned int ethernet_get_config_reg(struct net_device *dev)
 {
+	struct mv643xx_private *mp = netdev_priv(dev);
 	unsigned int eth_config_reg;
 
 	eth_config_reg = mv_read(MV643XX_ETH_PORT_CONFIG_EXTEND_REG
-								(eth_port_num));
+								(mp->port_num));
 	return eth_config_reg;
 }
 
@@ -2545,11 +2555,10 @@
  *	true otherwise.
  *
  */
-static void eth_port_read_smi_reg(struct mv643xx_private *mp,
+static void eth_port_read_smi_reg(struct net_device *dev,
 				unsigned int phy_reg, unsigned int *value)
 {
-	unsigned int port_num = mp->port_num;
-	int phy_addr = ethernet_phy_get(port_num);
+	int phy_addr = ethernet_phy_get(dev);
 	unsigned long flags;
 	int i;
 
@@ -2560,7 +2569,7 @@
 	for (i = 0; mv_read(MV643XX_ETH_SMI_REG) & ETH_SMI_BUSY; i++) {
 		if (i == PHY_WAIT_ITERATIONS) {
 			printk(KERN_ERR "%s: PHY busy timeout\n", 
-			       mp->netdev->name);
+			       dev->name);
 			goto out;
 		}
 		udelay(PHY_WAIT_MICRO_SECONDS);
@@ -2573,7 +2582,7 @@
 	for (i = 0; !(mv_read(MV643XX_ETH_SMI_REG) & ETH_SMI_READ_VALID); i++) {
 		if (i == PHY_WAIT_ITERATIONS) {
 			printk(KERN_ERR "%s: PHY read timeout\n",
-			       mp->netdev->name);
+			       dev->name);
 			goto out;
 		}
 		udelay(PHY_WAIT_MICRO_SECONDS);
@@ -2604,15 +2613,14 @@
  *	true otherwise.
  *
  */
-static void eth_port_write_smi_reg(struct mv643xx_private *mp,
+static void eth_port_write_smi_reg(struct net_device *dev,
 				   unsigned int phy_reg, unsigned int value)
 {
 	int phy_addr;
 	int i;
 	unsigned long flags;
-	unsigned int eth_port_num = mp->port_num;
 
-	phy_addr = ethernet_phy_get(eth_port_num);
+	phy_addr = ethernet_phy_get(dev);
 
 	/* the SMI register is a shared resource */
 	spin_lock_irqsave(&mv643xx_eth_phy_lock, flags);
@@ -2621,7 +2629,7 @@
 	for (i = 0; mv_read(MV643XX_ETH_SMI_REG) & ETH_SMI_BUSY; i++) {
 		if (i == PHY_WAIT_ITERATIONS) {
 			printk(KERN_ERR "%s: PHY busy timeout\n", 
-			       mp->netdev->name);
+			       dev->name);
 			goto out;
 		}
 		udelay(PHY_WAIT_MICRO_SECONDS);
@@ -2639,16 +2647,14 @@
 static int mv643xx_mdio_read(struct net_device *dev, int phy_id, int location)
 {
 	int val;
-	struct mv643xx_private *mp = netdev_priv(dev);
 
-	eth_port_read_smi_reg(mp, location, &val);
+	eth_port_read_smi_reg(dev, location, &val);
 	return val;
 }
 
 static void mv643xx_mdio_write(struct net_device *dev, int phy_id, int location, int val)
 {
-	struct mv643xx_private *mp = netdev_priv(dev);
-	eth_port_write_smi_reg(mp, location, val);
+	eth_port_write_smi_reg(dev, location, val);
 }
 
 /*
@@ -2682,7 +2688,7 @@
 /*
  * Modified to include the first descriptor pointer in case of SG
  */
-static int eth_port_send(struct mv643xx_private *mp,
+static int eth_port_send(struct net_device *dev,
 			 struct pkt_info *p_pkt_info)
 {
 	int tx_desc_curr, tx_desc_used, tx_first_desc, tx_next_desc;
@@ -2774,9 +2780,10 @@
 	return status;
 }
 #else
-static int eth_port_send(struct mv643xx_private *mp,
+static int eth_port_send(struct net_device *dev,
 			 struct pkt_info *p_pkt_info)
 {
+	struct mv643xx_private *mp = netdev_priv(dev);
 	int tx_desc_curr;
 	int tx_desc_used;
 	struct eth_tx_desc *current_descriptor;
@@ -2801,7 +2808,7 @@
 
 	if (netif_msg_tx_queued(mp))
 		printk(KERN_DEBUG "%s: send pkt: desc=%d len=%d, f/l=%d/%d\n",
-		       mp->netdev->name, tx_desc_curr,
+		       dev->name, tx_desc_curr,
 		       p_pkt_info->byte_cnt, 
 		       ((command_status & ETH_TX_FIRST_DESC) != 0),
 		       ((command_status & ETH_TX_LAST_DESC) != 0));
@@ -2831,7 +2838,7 @@
 
 out:
 	if (status == -ENOBUFS)
-		printk(KERN_ERR "%s: Error on Queue Full\n", mp->netdev->name);
+		printk(KERN_ERR "%s: Error on Queue Full\n", dev->name);
 
 	return status;
 }
@@ -2861,9 +2868,10 @@
  *	ETH_OK otherwise.
  *
  */
-static int eth_tx_return_desc(struct mv643xx_private *mp,
+static int eth_tx_return_desc(struct net_device *dev,
 			      struct pkt_info *p_pkt_info)
 {
+	struct mv643xx_private *mp = netdev_priv(dev);
 	int tx_desc_used;
 #ifdef MV643XX_CHECKSUM_OFFLOAD_TX
 	int tx_busy_desc = mp->tx_first_desc_q;
@@ -2929,9 +2937,10 @@
  *	ETH_END_OF_JOB if there is no received data.
  *	ETH_OK otherwise.
  */
-static int eth_port_receive(struct mv643xx_private *mp,
+static int eth_port_receive(struct net_device *dev,
 						struct pkt_info *p_pkt_info)
 {
+	struct mv643xx_private *mp = netdev_priv(dev);
 	int rx_next_curr_desc, rx_curr_desc, rx_used_desc;
 	volatile struct eth_rx_desc *p_rx_desc;
 	unsigned int command_status;
@@ -2962,7 +2971,7 @@
 
 	if (netif_msg_rx_status(mp))
 		printk(KERN_DEBUG "%s: rcv pkt: len=%d, desc=%d, f/l=%d/%d\n",
-		       mp->netdev->name, 
+		       dev->name, 
 		       p_pkt_info->byte_cnt, rx_curr_desc,
 		       ((command_status & ETH_RX_FIRST_DESC) != 0),
 		       ((command_status & ETH_RX_LAST_DESC) != 0));
@@ -3002,9 +3011,10 @@
  *	ETH_ERROR in case the routine can not access Rx desc ring.
  *	ETH_OK otherwise.
  */
-static void eth_rx_return_buff(struct mv643xx_private *mp,
+static void eth_rx_return_buff(struct net_device *dev,
 			       struct pkt_info *p_pkt_info)
 {
+	struct mv643xx_private *mp = netdev_priv(dev);
 	int used_rx_desc;	/* Where to return Rx resource */
 	volatile struct eth_rx_desc *p_used_rx_desc;
 
@@ -3018,7 +3028,7 @@
 
 	if (netif_msg_rx_status(mp))
 		printk(KERN_DEBUG "%s: rx done, len=%d, desc=%d, status=%08x\n",
-		       mp->netdev->name, p_pkt_info->byte_cnt, used_rx_desc,
+		       dev->name, p_pkt_info->byte_cnt, used_rx_desc,
 		       p_used_rx_desc->cmd_sts);
 
 	/* Flush the write pipe */
@@ -3131,7 +3141,7 @@
 	struct mv643xx_private *mp = netdev->priv;
 	int i;
 
-	eth_update_mib_counters(mp);
+	eth_update_mib_counters(netdev);
 
 	for(i = 0; i < MV643XX_STATS_LEN; i++) {
 		char *p = (char *)mp+mv643xx_gstrings_stats[i].stat_offset;	
Index: linux-2.5-enet/drivers/net/mv643xx_eth.h
===================================================================
--- linux-2.5-enet.orig/drivers/net/mv643xx_eth.h
+++ linux-2.5-enet/drivers/net/mv643xx_eth.h
@@ -547,7 +547,6 @@
 
 	u32 msg_enable;
 	struct mii_if_info mii;
-	struct net_device *netdev;
 };
 
 #endif				/* __MV643XX_ETH_H__ */
