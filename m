From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: mv643xx(6/20): use netif_msg_xxx() to control log messages where appropriate
Date: Mon, 28 Mar 2005 16:46:53 -0700
Message-ID: <20050328234653.GF29098@xyzzy>
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

Network driver messages can be controlled using ethtool msglvl via the
netif_msg_xxx() macros. This patch allows mv643xx's driver message
verbosity to be controlled by ethtool.

Some debug messages have also been added (not enabled by default) to
trace low-level (per packet) device access.

Signed-off-by: James Chapman <jchapman@katalix.com>
Acked-by: Dale Farnsworth <dale@farnsworth.org>


Index: linux-2.5-enet/drivers/net/mv643xx_eth.h
===================================================================
--- linux-2.5-enet.orig/drivers/net/mv643xx_eth.h
+++ linux-2.5-enet/drivers/net/mv643xx_eth.h
@@ -564,6 +564,7 @@
 
 	u32 msg_enable;
 	struct mii_if_info mii;
+	struct net_device *netdev;
 };
 
 /* ethernet.h API list */
@@ -582,12 +583,12 @@
 				 unsigned char *p_addr);
 
 /* PHY and MIB routines */
-static void ethernet_phy_reset(unsigned int eth_port_num);
+static void ethernet_phy_reset(struct mv643xx_private *mp);
 
-static void eth_port_write_smi_reg(unsigned int eth_port_num,
+static void eth_port_write_smi_reg(struct mv643xx_private *mp,
 				   unsigned int phy_reg, unsigned int value);
 
-static void eth_port_read_smi_reg(unsigned int eth_port_num,
+static void eth_port_read_smi_reg(struct mv643xx_private *mp,
 				  unsigned int phy_reg, unsigned int *value);
 
 static void eth_clear_mib_counters(unsigned int eth_port_num);
Index: linux-2.5-enet/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.5-enet.orig/drivers/net/mv643xx_eth.c
+++ linux-2.5-enet/drivers/net/mv643xx_eth.c
@@ -86,7 +86,7 @@
 #endif
 static int ethernet_phy_get(unsigned int eth_port_num);
 static void ethernet_phy_set(unsigned int eth_port_num, int phy_addr);
-static int ethernet_phy_detect(unsigned int eth_port_num);
+static int ethernet_phy_detect(struct mv643xx_private *mp);
 static int mv643xx_mdio_read(struct net_device *dev, int phy_id, int location);
 static void mv643xx_mdio_write(struct net_device *dev, int phy_id, int location, int val);
 static int mv643xx_eth_do_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
@@ -199,7 +199,8 @@
 	 * again in a later time .
 	 */
 	if ((mp->rx_ring_skbs == 0) && (mp->rx_timer_flag == 0)) {
-		printk(KERN_INFO "%s: Rx ring is empty\n", dev->name);
+		if (netif_msg_rx_status(mp))
+			printk(KERN_INFO "%s: Rx ring is empty\n", dev->name);
 		/* After 100mSec */
 		mp->timeout.expires = jiffies + (HZ / 10);
 		add_timer(&mp->timeout);
@@ -306,7 +307,8 @@
 {
 	struct mv643xx_private *mp = netdev_priv(dev);
 
-	printk(KERN_INFO "%s: TX timeout  ", dev->name);
+	if (netif_msg_tx_err(mp))
+		printk(KERN_INFO "%s: TX timeout  ", dev->name);
 
 	/* Do the reset outside of interrupt context */
 	schedule_work(&mp->tx_timeout_task);
@@ -350,7 +352,9 @@
 	/* Check only queue 0 */
 	while (eth_tx_return_desc(mp, &pkt_info) == ETH_OK) {
 		if (pkt_info.cmd_sts & BIT0) {
-			printk("%s: Error in TX\n", dev->name);
+			if (netif_msg_tx_err(mp))
+				printk(KERN_WARNING "%s: Error in TX: cmd_sts=%08x\n",
+				       dev->name, pkt_info.cmd_sts);
 			stats->tx_errors++;
 		}
 
@@ -440,11 +444,10 @@
 			if ((pkt_info.cmd_sts & (ETH_RX_FIRST_DESC |
 							ETH_RX_LAST_DESC)) !=
 				(ETH_RX_FIRST_DESC | ETH_RX_LAST_DESC)) {
-				if (net_ratelimit())
-					printk(KERN_ERR
-						"%s: Received packet spread "
-						"on multiple descriptors\n",
-						dev->name);
+				if (net_ratelimit() && netif_msg_rx_err(mp))
+					printk(KERN_WARNING "%s: Received "
+					       "packet spread on multiple "
+					       "descriptors\n", dev->name);
 			}
 			if (pkt_info.cmd_sts & ETH_ERROR_SUMMARY)
 				stats->rx_errors++;
@@ -812,7 +815,7 @@
 	}
 
 	if (mv643xx_eth_real_open(dev)) {
-		printk("%s: Error opening interface\n", dev->name);
+		printk(KERN_ERR "%s: Error opening interface\n", dev->name);
 		err = -EBUSY;
 		goto out_free;
 	}
@@ -1019,8 +1022,6 @@
 	if (!mp->p_rx_desc_area) {
 		printk(KERN_ERR "%s: Cannot allocate Rx ring (size %d bytes)\n",
 							dev->name, size);
-		printk(KERN_ERR "%s: Freeing previously allocated TX queues...",
-							dev->name);
 		if (mp->rx_sram_size)
 			iounmap(mp->p_rx_desc_area);
 		else
@@ -1070,8 +1071,8 @@
 		}
 	}
 	if (mp->tx_ring_skbs)
-		printk("%s: Error on Tx descriptor free - could not free %d"
-				" descriptors\n", dev->name, mp->tx_ring_skbs);
+		printk(KERN_ERR "%s: Error on Tx descriptor free - could not "
+		       "free %d descriptors\n", dev->name, mp->tx_ring_skbs);
 
 	/* Free TX ring */
 	if (mp->tx_sram_size)
@@ -1099,10 +1100,10 @@
 	}
 
 	if (mp->rx_ring_skbs)
-		printk(KERN_ERR
-			"%s: Error in freeing Rx Ring. %d skb's still"
-			" stuck in RX Ring - ignoring them\n", dev->name,
-			mp->rx_ring_skbs);
+		printk(KERN_ERR "%s: Error in freeing Rx Ring. "
+		       "%d skb's still stuck in RX Ring - "
+		       "ignoring them\n", dev->name, mp->rx_ring_skbs);
+
 	/* Free RX ring */
 	if (mp->rx_sram_size)
 		iounmap(mp->p_rx_desc_area);
@@ -1264,9 +1265,8 @@
 	struct pkt_info pkt_info;
 
 	if (netif_queue_stopped(dev)) {
-		printk(KERN_ERR
-			"%s: Tried sending packet when interface is stopped\n",
-			dev->name);
+		printk(KERN_ERR "%s: Tried sending packet when interface is "
+		       "stopped\n", dev->name);
 		return 1;
 	}
 
@@ -1274,16 +1274,15 @@
 	if ((mp->tx_ring_size - mp->tx_ring_skbs) <=
 					(skb_shinfo(skb)->nr_frags + 1)) {
 		netif_stop_queue(dev);
-		printk(KERN_ERR
-			"%s: Bug in mv643xx_eth - Trying to transmit when"
-			" queue full !\n", dev->name);
+		printk(KERN_ERR "%s: Trying to transmit when queue full!\n", 
+		       dev->name);
 		return 1;
 	}
 
 	/* Paranoid check - this shouldn't happen */
 	if (skb == NULL) {
 		stats->tx_dropped++;
-		printk(KERN_ERR "mv64320_eth paranoid check failed\n");
+		printk(KERN_ERR "%s: paranoid check failed\n", dev->name);
 		return 1;
 	}
 
@@ -1311,9 +1310,8 @@
 			} else if (skb->nh.iph->protocol == IPPROTO_TCP)
 				pkt_info.l4i_chk = skb->h.th->check;
 			else {
-				printk(KERN_ERR
-					"%s: chksum proto != TCP or UDP\n",
-					dev->name);
+				printk(KERN_ERR "%s: chksum proto != TCP "
+				       "or UDP\n", dev->name);
 				spin_unlock_irqrestore(&mp->lock, flags);
 				return 1;
 			}
@@ -1325,8 +1323,9 @@
 		mp->tx_ring_skbs++;
 		status = eth_port_send(mp, &pkt_info);
 		if ((status == ETH_ERROR) || (status == ETH_QUEUE_FULL))
-			printk(KERN_ERR "%s: Error on transmitting packet\n",
-								dev->name);
+			if (netif_msg_tx_err(mp))
+				printk(KERN_WARNING "%s: Error on transmitting "
+				       "packet\n", dev->name);
 		stats->tx_bytes += pkt_info.byte_cnt;
 	} else {
 		unsigned int frag;
@@ -1344,10 +1343,12 @@
 			fragp = &skb_shinfo(skb)->frags[frag];
 			if (fragp->size <= 8 && fragp->page_offset & 0x7) {
 				skb_linearize(skb, GFP_ATOMIC);
-				printk(KERN_DEBUG "%s: unaligned tiny fragment"
-						"%d of %d, fixed\n",
-						dev->name, frag,
-						skb_shinfo(skb)->nr_frags);
+				if (netif_msg_pktdata(mp))
+					printk(KERN_DEBUG "%s: unaligned "
+					       "tiny fragment"
+					       "%d of %d, fixed\n",
+					       dev->name, frag,
+					       skb_shinfo(skb)->nr_frags);
 				goto linear;
 			}
 		}
@@ -1372,9 +1373,8 @@
 			} else if (skb->nh.iph->protocol == IPPROTO_TCP)
 				pkt_info.l4i_chk = skb->h.th->check;
 			else {
-				printk(KERN_ERR
-					"%s: chksum proto != TCP or UDP\n",
-					dev->name);
+				printk(KERN_ERR "%s: chksum proto != TCP "
+				       "or UDP\n", dev->name);
 				spin_unlock_irqrestore(&mp->lock, flags);
 				return 1;
 			}
@@ -1383,13 +1383,16 @@
 		status = eth_port_send(mp, &pkt_info);
 		if (status != ETH_OK) {
 			if ((status == ETH_ERROR))
-				printk(KERN_ERR
-					"%s: Error on transmitting packet\n",
-					dev->name);
+				printk(KERN_WARNING "%s: Error on "
+					       "transmitting packet\n",
+					       dev->name);
 			if (status == ETH_QUEUE_FULL)
-				printk("Error on Queue Full \n");
+				printk(KERN_WARNING "%s: Error on "
+					       "Queue Full\n",
+					       dev->name);
 			if (status == ETH_QUEUE_LAST_RESOURCE)
-				printk("Tx resource error \n");
+				printk(KERN_WARNING "%s: Tx resource error\n",
+					       dev->name);
 		}
 		stats->tx_bytes += pkt_info.byte_cnt;
 
@@ -1420,15 +1423,20 @@
 
 			if (status != ETH_OK) {
 				if ((status == ETH_ERROR))
-					printk(KERN_ERR "%s: Error on "
-							"transmitting packet\n",
-							dev->name);
+					if (netif_msg_tx_err(mp))
+						printk(KERN_WARNING "%s: Error on "
+						       "transmitting packet\n",
+						       dev->name);
 
 				if (status == ETH_QUEUE_LAST_RESOURCE)
-					printk("Tx resource error \n");
+					if (netif_msg_tx_err(mp))
+						printk(KERN_WARNING "%s: Tx resource "
+						       "error\n", dev->name);
 
 				if (status == ETH_QUEUE_FULL)
-					printk("Queue is full \n");
+					if (netif_msg_tx_err(mp))
+						printk(KERN_WARNING "%s: Queue is full\n",
+						       dev->name);
 			}
 			stats->tx_bytes += pkt_info.byte_cnt;
 		}
@@ -1444,8 +1452,10 @@
 	mp->tx_ring_skbs++;
 	status = eth_port_send(mp, &pkt_info);
 	if ((status == ETH_ERROR) || (status == ETH_QUEUE_FULL))
-		printk(KERN_ERR "%s: Error on transmitting packet\n",
-								dev->name);
+		if (netif_msg_tx_err(mp))
+			printk(KERN_WARNING "%s: Error on transmitting packet\n",
+			       dev->name);
+
 	stats->tx_bytes += pkt_info.byte_cnt;
 #endif
 
@@ -1516,6 +1526,7 @@
 	dev_set_drvdata(ddev, dev);
 
 	mp = netdev_priv(dev);
+	mp->netdev = dev;
 
 	/* By default, log probe, interface up/down and error events */
 	mp->msg_enable = NETIF_MSG_PROBE | NETIF_MSG_IFUP | NETIF_MSG_IFDOWN |
@@ -1621,11 +1632,11 @@
 	mp->mii.phy_id_mask = 0x3f;
 	mp->mii.reg_num_mask = 0x1f;
 
-	err = ethernet_phy_detect(port_num);
+	err = ethernet_phy_detect(mp);
 	if (err) {
-		pr_debug("MV643xx ethernet port %d: "
-					"No PHY detected at addr %d\n",
-					port_num, ethernet_phy_get(port_num));
+		printk(KERN_ERR "MV643xx ethernet port %d: "
+		       "No PHY detected at addr %d\n",
+		       port_num, ethernet_phy_get(port_num));
 		return err;
 	}
 
@@ -1636,28 +1647,36 @@
 	mp->mii.supports_gmii = mii_check_gmii_support(&mp->mii);
 
 	p = dev->dev_addr;
-	printk(KERN_NOTICE
-		"%s: port %d with MAC address %02x:%02x:%02x:%02x:%02x:%02x\n",
-		dev->name, port_num, p[0], p[1], p[2], p[3], p[4], p[5]);
+	if (netif_msg_probe(mp))
+		printk(KERN_NOTICE "%s: has MAC address "
+		       "%02x:%02x:%02x:%02x:%02x:%02x\n",
+		       dev->name, p[0], p[1], p[2], p[3], p[4], p[5]);
 
 	if (dev->features & NETIF_F_SG)
-		printk(KERN_NOTICE "%s: Scatter Gather Enabled\n", dev->name);
+		if (netif_msg_probe(mp))
+			printk(KERN_NOTICE "%s: Scatter Gather Enabled\n", 
+			       dev->name);
 
 	if (dev->features & NETIF_F_IP_CSUM)
-		printk(KERN_NOTICE "%s: TX TCP/IP Checksumming Supported\n",
-								dev->name);
+		if (netif_msg_probe(mp))
+			printk(KERN_NOTICE "%s: TX TCP/IP Checksumming Supported\n",
+			       dev->name);
 
 #ifdef MV643XX_CHECKSUM_OFFLOAD_TX
-	printk(KERN_NOTICE "%s: RX TCP/UDP Checksum Offload ON \n", dev->name);
+	if (netif_msg_probe(mp))
+		printk(KERN_NOTICE "%s: RX TCP/UDP Checksum Offload ON\n", 
+		       dev->name);
 #endif
 
 #ifdef MV643XX_COAL
-	printk(KERN_NOTICE "%s: TX and RX Interrupt Coalescing ON \n",
-								dev->name);
+	if (netif_msg_probe(mp))
+		printk(KERN_NOTICE "%s: TX and RX Interrupt Coalescing ON\n",
+		       dev->name);
 #endif
 
 #ifdef MV643XX_NAPI
-	printk(KERN_NOTICE "%s: RX NAPI Enabled \n", dev->name);
+	if (netif_msg_probe(mp))
+		printk(KERN_NOTICE "%s: RX NAPI Enabled\n", dev->name);
 #endif
 
 	return 0;
@@ -1958,7 +1977,7 @@
 
 	eth_port_init_mac_tables(mp->port_num);
 
-	ethernet_phy_reset(mp->port_num);
+	ethernet_phy_reset(mp);
 }
 
 /*
@@ -2287,22 +2306,22 @@
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
 
@@ -2375,14 +2394,14 @@
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
 }
 
 /*
@@ -2520,9 +2539,10 @@
  *	true otherwise.
  *
  */
-static void eth_port_read_smi_reg(unsigned int port_num,
+static void eth_port_read_smi_reg(struct mv643xx_private *mp,
 				unsigned int phy_reg, unsigned int *value)
 {
+	unsigned int port_num = mp->port_num;
 	int phy_addr = ethernet_phy_get(port_num);
 	unsigned long flags;
 	int i;
@@ -2533,7 +2553,8 @@
 	/* wait for the SMI register to become available */
 	for (i = 0; mv_read(MV643XX_ETH_SMI_REG) & ETH_SMI_BUSY; i++) {
 		if (i == PHY_WAIT_ITERATIONS) {
-			printk("mv643xx PHY busy timeout, port %d\n", port_num);
+			printk(KERN_ERR "%s: PHY busy timeout\n", 
+			       mp->netdev->name);
 			goto out;
 		}
 		udelay(PHY_WAIT_MICRO_SECONDS);
@@ -2545,7 +2566,8 @@
 	/* now wait for the data to be valid */
 	for (i = 0; !(mv_read(MV643XX_ETH_SMI_REG) & ETH_SMI_READ_VALID); i++) {
 		if (i == PHY_WAIT_ITERATIONS) {
-			printk("mv643xx PHY read timeout, port %d\n", port_num);
+			printk(KERN_ERR "%s: PHY read timeout\n",
+			       mp->netdev->name);
 			goto out;
 		}
 		udelay(PHY_WAIT_MICRO_SECONDS);
@@ -2576,12 +2598,13 @@
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
+	unsigned int eth_port_num = mp->port_num;
 
 	phy_addr = ethernet_phy_get(eth_port_num);
 
@@ -2591,8 +2614,8 @@
 	/* wait for the SMI register to become available */
 	for (i = 0; mv_read(MV643XX_ETH_SMI_REG) & ETH_SMI_BUSY; i++) {
 		if (i == PHY_WAIT_ITERATIONS) {
-			printk("mv643xx PHY busy timeout, port %d\n",
-								eth_port_num);
+			printk(KERN_ERR "%s: PHY busy timeout\n", 
+			       mp->netdev->name);
 			goto out;
 		}
 		udelay(PHY_WAIT_MICRO_SECONDS);
@@ -2612,14 +2635,14 @@
 	int val;
 	struct mv643xx_private *mp = netdev_priv(dev);
 
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
@@ -2670,9 +2693,8 @@
 	 * in length must be aligned on an 8 byte boundary.
 	 */
 	if (p_pkt_info->byte_cnt <= 8 && p_pkt_info->buf_ptr & 0x7) {
-		printk(KERN_ERR
-			"mv643xx_eth port %d: packet size <= 8 problem\n",
-			mp->port_num);
+		printk(KERN_ERR "%s: packet size <= 8 (%d) problem\n",
+		       dev->name, p_pkt_info->byte_cnt);
 		return ETH_ERROR;
 	}
 
@@ -2703,6 +2725,13 @@
 		current_descriptor->cmd_sts = command;
 	}
 
+	if (netif_msg_txqueued(mp))
+		printk( KERN_DEBUG "%s: send pkt: len=%d, desc=%d, "
+			"f/l=%d/%d\n", dev->name,
+			p_pkt_info->byte_cnt, tx_desc_curr, 
+			((command & ETH_TX_FIRST_DESC) != 0),
+			((command & ETH_TX_LAST_DESC) != 0));
+
 	if (command & ETH_TX_LAST_DESC) {
 		wmb();
 		first_descriptor->cmd_sts = mp->tx_first_command;
@@ -2752,6 +2781,13 @@
 	current_descriptor->byte_cnt = p_pkt_info->byte_cnt;
 	mp->tx_skb[tx_desc_curr] = p_pkt_info->return_info;
 
+	if (netif_msg_tx_queued(mp))
+		printk(KERN_DEBUG "%s: send pkt: desc=%d len=%d, f/l=%d/%d\n",
+		       mp->netdev->name, tx_desc_curr,
+		       p_pkt_info->byte_cnt, 
+		       ((command_status & ETH_TX_FIRST_DESC) != 0),
+		       ((command_status & ETH_TX_LAST_DESC) != 0));
+
 	/* Set last desc with DMA ownership and interrupt enable. */
 	wmb();
 	current_descriptor->cmd_sts = command_status |
@@ -2899,6 +2935,13 @@
 	p_pkt_info->return_info = mp->rx_skb[rx_curr_desc];
 	p_pkt_info->l4i_chk = p_rx_desc->buf_size;
 
+	if (netif_msg_rx_status(mp))
+		printk(KERN_DEBUG "%s: rcv pkt: len=%d, desc=%d, f/l=%d/%d\n",
+		       mp->netdev->name, 
+		       p_pkt_info->byte_cnt, rx_curr_desc,
+		       ((command_status & ETH_RX_FIRST_DESC) != 0),
+		       ((command_status & ETH_RX_LAST_DESC) != 0));
+
 	/* Clean the return info field to indicate that the packet has been */
 	/* moved to the upper layers					    */
 	mp->rx_skb[rx_curr_desc] = NULL;
@@ -2948,6 +2991,11 @@
 	p_used_rx_desc->buf_size = p_pkt_info->byte_cnt;
 	mp->rx_skb[used_rx_desc] = p_pkt_info->return_info;
 
+	if (netif_msg_rx_status(mp))
+		printk(KERN_DEBUG "%s: rx done, len=%d, desc=%d, status=%08x\n",
+		       mp->netdev->name, p_pkt_info->byte_cnt, used_rx_desc,
+		       p_used_rx_desc->cmd_sts);
+
 	/* Flush the write pipe */
 
 	/* Return the descriptor to DMA ownership */
