From: Daniele Venzano <webvenza@libero.it>
Subject: [PATCH 4/5] sis900 debugging and revision code
Date: Sun, 12 Dec 2004 13:33:12 +0100
Message-ID: <20041212123312.GE16325@gateway.milesteg.arr>
References: <20041212121852.GA16325@gateway.milesteg.arr>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LYw3s/afESlflPpp"
Return-path: <netdev-bounce@oss.sgi.com>
To: NetDev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20041212121852.GA16325@gateway.milesteg.arr>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--LYw3s/afESlflPpp
Content-Type: multipart/mixed; boundary="Bg2esWel0ueIH/G/"
Content-Disposition: inline


--Bg2esWel0ueIH/G/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Add some init debugging printk
Use netif_msg macros before printing debug messages

Signed-off-by: Daniele Venzano <webvenza@libero.it>

-- 
-----------------------------
Daniele Venzano
Web: http://teg.homeunix.org


--Bg2esWel0ueIH/G/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="patch_63.diff"

Index: sis900.c
===================================================================
--- a/drivers/net/sis900.c	(revision 62)
+++ b/drivers/net/sis900.c	(revision 63)
@@ -477,8 +477,13 @@
 		
 	/* Get Mac address according to the chip revision */
 	pci_read_config_byte(pci_dev, PCI_CLASS_REVISION, &revision);
+
+	if(netif_msg_probe(sis_priv))
+		printk(KERN_DEBUG PFX "%s: detected revision %2.2x, "
+				"trying to get MAC address...\n",
+				net_dev->name, revision);
+	
 	ret = 0;
-
 	if (revision == SIS630E_900_REV)
 		ret = sis630e_get_mac_addr(pci_dev, net_dev);
 	else if ((revision > 0x81) && (revision <= 0x90) )
@@ -489,6 +494,7 @@
 		ret = sis900_get_mac_addr(pci_dev, net_dev);
 
 	if (ret == 0) {
+		printk(KERN_WARNING PFX "%s: Cannot read MAC address.\n", net_dev->name);
 		ret = -ENODEV;
 		goto err_out_unregister;
 	}
@@ -499,6 +505,7 @@
 
 	/* probe for mii transceiver */
 	if (sis900_mii_probe(net_dev) == 0) {
+		printk(KERN_WARNING PFX "%s: Error probing MII device.\n", net_dev->name);
 		ret = -ENODEV;
 		goto err_out_unregister;
 	}
@@ -562,9 +569,13 @@
 		for(i = 0; i < 2; i++)
 			mii_status = mdio_read(net_dev, phy_addr, MII_STATUS);
 
-		if (mii_status == 0xffff || mii_status == 0x0000)
-			/* the mii is not accessible, try next one */
+		if (mii_status == 0xffff || mii_status == 0x0000) {
+			if (netif_msg_probe(sis_priv))
+				printk(KERN_DEBUG PFX "%s: MII at address %d"
+						" not accessible\n",
+						net_dev->name, phy_addr);
 			continue;
+		}
 		
 		if ((mii_phy = kmalloc(sizeof(struct mii_phy), GFP_KERNEL)) == NULL) {
 			printk(KERN_WARNING PFX "Cannot allocate mem for struct mii_phy\n");
@@ -593,9 +604,11 @@
 				if (mii_chip_table[i].phy_types == MIX)
 					mii_phy->phy_types =
 					    (mii_status & (MII_STAT_CAN_TX_FDX | MII_STAT_CAN_TX)) ? LAN : HOME;
-				printk(KERN_INFO PFX "%s: %s transceiver found at address %d.\n",
-				       net_dev->name, mii_chip_table[i].name,
-				       phy_addr);
+				printk(KERN_INFO PFX "%s: %s transceiver found "
+							"at address %d.\n",
+							net_dev->name,
+							mii_chip_table[i].name,
+							phy_addr);
 				break;
 			}
 			
@@ -1011,6 +1024,7 @@
 static void
 sis900_init_rxfilter (struct net_device * net_dev)
 {
+	struct sis900_private *sis_priv = net_dev->priv;
 	long ioaddr = net_dev->base_addr;
 	u32 rfcrSave;
 	u32 i;
@@ -1028,7 +1042,7 @@
 		outl((i << RFADDR_shift), ioaddr + rfcr);
 		outl(w, ioaddr + rfdr);
 
-		if (sis900_debug > 2) {
+		if (netif_msg_hw(sis_priv)) {
 			printk(KERN_DEBUG PFX "%s: Receive Filter Addrss[%d]=%x\n",
 			       net_dev->name, i, inl(ioaddr + rfdr));
 		}
@@ -1066,7 +1080,7 @@
 
 	/* load Transmit Descriptor Register */
 	outl(sis_priv->tx_ring_dma, ioaddr + txdp);
-	if (sis900_debug > 2)
+	if (netif_msg_hw(sis_priv))
 		printk(KERN_DEBUG PFX "%s: TX descriptor register loaded with: %8.8x\n",
 		       net_dev->name, inl(ioaddr + txdp));
 }
@@ -1120,7 +1134,7 @@
 
 	/* load Receive Descriptor Register */
 	outl(sis_priv->rx_ring_dma, ioaddr + rxdp);
-	if (sis900_debug > 2)
+	if (netif_msg_hw(sis_priv))
 		printk(KERN_DEBUG PFX "%s: RX descriptor register loaded with: %8.8x\n",
 		       net_dev->name, inl(ioaddr + rxdp));
 }
@@ -1268,7 +1282,8 @@
 	/* Link ON -> OFF */
                 if (!(status & MII_STAT_LINK)){
                 	netif_carrier_off(net_dev);
-                	printk(KERN_INFO PFX "%s: Media Link Off\n", net_dev->name);
+			if(netif_msg_link(sis_priv))
+                		printk(KERN_INFO PFX "%s: Media Link Off\n", net_dev->name);
 
                 	/* Change mode issue */
                 	if ((mii_phy->phy_id0 == 0x001D) && 
@@ -1383,7 +1398,8 @@
 		status = mdio_read(net_dev, phy_addr, MII_STATUS);
 
 	if (!(status & MII_STAT_LINK)){
-		printk(KERN_INFO PFX "%s: Media Link Off\n", net_dev->name);
+		if(netif_msg_link(sis_priv))
+			printk(KERN_INFO PFX "%s: Media Link Off\n", net_dev->name);
 		sis_priv->autong_complete = 1;
 		netif_carrier_off(net_dev);
 		return;
@@ -1445,7 +1461,8 @@
 			*speed = HW_SPEED_100_MBPS;
 	}
 
-	printk(KERN_INFO PFX "%s: Media Link On %s %s-duplex \n",
+	if(netif_msg_link(sis_priv))
+		printk(KERN_INFO PFX "%s: Media Link On %s %s-duplex \n",
 	       				net_dev->name,
 	       				*speed == HW_SPEED_100_MBPS ?
 	       					"100mbps" : "10mbps",
@@ -1468,8 +1485,9 @@
 	unsigned long flags;
 	int i;
 
-	printk(KERN_INFO PFX "%s: Transmit timeout, status %8.8x %8.8x \n",
-	       net_dev->name, inl(ioaddr + cr), inl(ioaddr + isr));
+	if(netif_msg_tx_err(sis_priv))
+		printk(KERN_INFO PFX "%s: Transmit timeout, status %8.8x %8.8x \n",
+	       		net_dev->name, inl(ioaddr + cr), inl(ioaddr + isr));
 
 	/* Disable interrupts by clearing the interrupt mask. */
 	outl(0x0000, ioaddr + imr);
@@ -1570,7 +1588,7 @@
 
 	net_dev->trans_start = jiffies;
 
-	if (sis900_debug > 3)
+	if (netif_msg_tx_queued(sis_priv))
 		printk(KERN_DEBUG PFX "%s: Queued Tx packet at %p size %d "
 		       "to slot %d.\n",
 		       net_dev->name, skb->data, (int)skb->len, entry);
@@ -1618,19 +1636,21 @@
 
 		/* something strange happened !!! */
 		if (status & HIBERR) {
-			printk(KERN_INFO PFX "%s: Abnormal interrupt,"
-			       "status %#8.8x.\n", net_dev->name, status);
+			if(netif_msg_intr(sis_priv))
+				printk(KERN_INFO PFX "%s: Abnormal interrupt,"
+					"status %#8.8x.\n", net_dev->name, status);
 			break;
 		}
 		if (--boguscnt < 0) {
-			printk(KERN_INFO PFX "%s: Too much work at interrupt, "
-			       "interrupt status = %#8.8x.\n",
-			       net_dev->name, status);
+			if(netif_msg_intr(sis_priv))
+				printk(KERN_INFO PFX "%s: Too much work at interrupt, "
+					"interrupt status = %#8.8x.\n",
+					net_dev->name, status);
 			break;
 		}
 	} while (1);
 
-	if (sis900_debug > 3)
+	if(netif_msg_intr(sis_priv))
 		printk(KERN_DEBUG PFX "%s: exiting interrupt, "
 		       "interrupt status = 0x%#8.8x.\n",
 		       net_dev->name, inl(ioaddr + isr));
@@ -1656,7 +1676,7 @@
 	unsigned int entry = sis_priv->cur_rx % NUM_RX_DESC;
 	u32 rx_status = sis_priv->rx_ring[entry].cmdsts;
 
-	if (sis900_debug > 3)
+	if (netif_msg_rx_status(sis_priv))
 		printk(KERN_DEBUG PFX "sis900_rx, cur_rx:%4.4d, dirty_rx:%4.4d "
 		       "status:0x%8.8x\n",
 		       sis_priv->cur_rx, sis_priv->dirty_rx, rx_status);
@@ -1668,7 +1688,7 @@
 
 		if (rx_status & (ABORT|OVERRUN|TOOLONG|RUNT|RXISERR|CRCERR|FAERR)) {
 			/* corrupted packet received */
-			if (sis900_debug > 3)
+			if (netif_msg_rx_err(sis_priv))
 				printk(KERN_DEBUG PFX "%s: Corrupted packet "
 				       "received, buffer status = 0x%8.8x.\n",
 				       net_dev->name, rx_status);
@@ -1690,9 +1710,10 @@
 			   some unknow bugs, it is possible that
 			   we are working on NULL sk_buff :-( */
 			if (sis_priv->rx_skbuff[entry] == NULL) {
-				printk(KERN_INFO PFX "%s: NULL pointer " 
-				       "encountered in Rx ring, skipping\n",
-				       net_dev->name);
+				if (netif_msg_rx_err(sis_priv))
+					printk(KERN_INFO PFX "%s: NULL pointer " 
+						"encountered in Rx ring, skipping\n",
+						net_dev->name);
 				break;
 			}
 
@@ -1719,9 +1740,10 @@
 				 * "hole" on the buffer ring, it is not clear
 				 * how the hardware will react to this kind
 				 * of degenerated buffer */
-				printk(KERN_INFO PFX "%s: Memory squeeze,"
-				       "deferring packet.\n",
-				       net_dev->name);
+				if (netif_msg_rx_status(sis_priv))
+					printk(KERN_INFO PFX "%s: Memory squeeze,"
+						"deferring packet.\n",
+						net_dev->name);
 				sis_priv->rx_skbuff[entry] = NULL;
 				/* reset buffer descriptor state */
 				sis_priv->rx_ring[entry].cmdsts = 0;
@@ -1755,9 +1777,10 @@
 				 * "hole" on the buffer ring, it is not clear
 				 * how the hardware will react to this kind
 				 * of degenerated buffer */
-				printk(KERN_INFO PFX "%s: Memory squeeze,"
-				       "deferring packet.\n",
-				       net_dev->name);
+				if (netif_msg_rx_err(sis_priv))
+					printk(KERN_INFO PFX "%s: Memory squeeze,"
+						"deferring packet.\n",
+						net_dev->name);
 				sis_priv->stats.rx_dropped++;
 				break;
 			}
@@ -1806,7 +1829,7 @@
 
 		if (tx_status & (ABORT | UNDERRUN | OWCOLL)) {
 			/* packet unsuccessfully transmitted */
-			if (sis900_debug > 3)
+			if (netif_msg_tx_err(sis_priv))
 				printk(KERN_DEBUG PFX "%s: Transmit "
 				       "error, Tx status %8.8x.\n",
 				       net_dev->name, tx_status);

--Bg2esWel0ueIH/G/--

--LYw3s/afESlflPpp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBvDqI2rmHZCWzV+0RApd/AJsF9W/acatHchRiHAKPWHJBKYtWzgCfTT6/
Rc2GjJ//NocK3qfndTJNkic=
=HuL+
-----END PGP SIGNATURE-----

--LYw3s/afESlflPpp--
