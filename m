From: Daniele Venzano <webvenza@libero.it>
Subject: [PATCH 3/5] sis900 debugging and revision code
Date: Sun, 12 Dec 2004 13:32:14 +0100
Message-ID: <20041212123214.GD16325@gateway.milesteg.arr>
References: <20041212121852.GA16325@gateway.milesteg.arr>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="fCcDWlUEdh43YKr8"
Return-path: <netdev-bounce@oss.sgi.com>
To: NetDev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20041212121852.GA16325@gateway.milesteg.arr>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--fCcDWlUEdh43YKr8
Content-Type: multipart/mixed; boundary="/aVve/J9H4Wl5yVO"
Content-Disposition: inline


--/aVve/J9H4Wl5yVO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Add sis900: prefix to all messages to do simpler greps in logs
Change priority of printk to KERN_DEBUG where appropriate
Remove two cryptic and useless printk

Signed-off-by: Daniele Venzano <webvenza@libero.it>

-- 
-----------------------------
Daniele Venzano
Web: http://teg.homeunix.org


--/aVve/J9H4Wl5yVO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="patch_62.diff"

Index: sis900.c
===================================================================
--- a/drivers/net/sis900.c	(revision 61)
+++ b/drivers/net/sis900.c	(revision 62)
@@ -76,12 +76,8 @@
 #define SIS900_MODULE_NAME "sis900"
 #define SIS900_DRV_VERSION "v1.08.08 Dec. 12 2004"
 
-static char version[] __devinitdata =
-KERN_INFO "sis900.c: " SIS900_DRV_VERSION "\n";
-
 static int max_interrupt_work = 40;
 static int multicast_filter_limit = 128;
-
 static int sis900_debug = -1; /* Use SIS900_DEF_MSG as value */
 
 #define SIS900_DEF_MSG \
@@ -90,6 +86,11 @@
 	 NETIF_MSG_RX_ERR	| \
 	 NETIF_MSG_TX_ERR)
 
+#define PFX "sis900: " /* Prefix common to all sis900 output messages */
+
+static char version[] __devinitdata =
+KERN_INFO PFX SIS900_DRV_VERSION "\n";
+
 /* Time in jiffies before concluding the transmitter is hung. */
 #define TX_TIMEOUT  (4*HZ)
 /* SiS 900 is capable of 32 bits BM DMA */
@@ -243,7 +244,7 @@
 	/* check to see if we have sane EEPROM */
 	signature = (u16) read_eeprom(ioaddr, EEPROMSignature);    
 	if (signature == 0xffff || signature == 0x0000) {
-		printk (KERN_INFO "%s: Error EERPOM read %x\n", 
+		printk (KERN_WARNING PFX "%s: Error EERPOM read %x\n", 
 			net_dev->name, signature);
 		return 0;
 	}
@@ -276,7 +277,7 @@
 	if (!isa_bridge) {
 		isa_bridge = pci_find_device(PCI_VENDOR_ID_SI, 0x0018, isa_bridge);
 		if (!isa_bridge) {
-			printk("%s: Can not find ISA bridge\n", net_dev->name);
+			printk(KERN_WARNING PFX "%s: Cannot find ISA bridge\n", net_dev->name);
 			return 0;
 		}
 	}
@@ -410,7 +411,7 @@
 	
 	i = pci_set_dma_mask(pci_dev, SIS900_DMA_MASK);
 	if(i){
-		printk(KERN_ERR "sis900.c: architecture does not support"
+		printk(KERN_ERR PFX "sis900.c: architecture does not support"
 			"32bit PCI busmaster DMA\n");
 		return i;
 	}
@@ -508,7 +509,7 @@
 		pci_read_config_byte(dev, PCI_CLASS_REVISION, &sis_priv->host_bridge_rev);
 
 	/* print some information about our NIC */
-	printk(KERN_INFO "%s: %s at %#lx, IRQ %d, ", net_dev->name,
+	printk(KERN_INFO PFX "%s: %s at %#lx, IRQ %d, ", net_dev->name,
 	       card_name, ioaddr, net_dev->irq);
 	for (i = 0; i < 5; i++)
 		printk("%2.2x:", (u8)net_dev->dev_addr[i]);
@@ -566,7 +567,7 @@
 			continue;
 		
 		if ((mii_phy = kmalloc(sizeof(struct mii_phy), GFP_KERNEL)) == NULL) {
-			printk(KERN_INFO "Cannot allocate mem for struct mii_phy\n");
+			printk(KERN_WARNING PFX "Cannot allocate mem for struct mii_phy\n");
 			mii_phy = sis_priv->first_mii;
 			while (mii_phy) {
 				struct mii_phy *phy;
@@ -592,21 +593,21 @@
 				if (mii_chip_table[i].phy_types == MIX)
 					mii_phy->phy_types =
 					    (mii_status & (MII_STAT_CAN_TX_FDX | MII_STAT_CAN_TX)) ? LAN : HOME;
-				printk(KERN_INFO "%s: %s transceiver found at address %d.\n",
+				printk(KERN_INFO PFX "%s: %s transceiver found at address %d.\n",
 				       net_dev->name, mii_chip_table[i].name,
 				       phy_addr);
 				break;
 			}
 			
 		if( !mii_chip_table[i].phy_id1 ) {
-			printk(KERN_INFO "%s: Unknown PHY transceiver found at address %d.\n",
+			printk(KERN_INFO PFX "%s: Unknown PHY transceiver found at address %d.\n",
 			       net_dev->name, phy_addr);
 			mii_phy->phy_types = UNKNOWN;
 		}
 	}
 	
 	if (sis_priv->mii == NULL) {
-		printk(KERN_INFO "%s: No MII transceivers found!\n",
+		printk(KERN_INFO PFX "%s: No MII transceivers found!\n",
 			net_dev->name);
 		return 0;
 	}
@@ -631,7 +632,7 @@
 
 			poll_bit ^= (mdio_read(net_dev, sis_priv->cur_phy, MII_STATUS) & poll_bit);
 			if (time_after_eq(jiffies, timeout)) {
-				printk(KERN_WARNING "%s: reset phy and link down now\n",
+				printk(KERN_WARNING PFX "%s: reset phy and link down now\n",
 					net_dev->name);
 				return -ETIME;
 			}
@@ -701,7 +702,7 @@
 	if (sis_priv->mii != default_phy) {
 		sis_priv->mii = default_phy;
 		sis_priv->cur_phy = default_phy->phy_addr;
-		printk(KERN_INFO "%s: Using transceiver found at address %d as default\n",
+		printk(KERN_INFO PFX "%s: Using transceiver found at address %d as default\n",
 					net_dev->name,sis_priv->cur_phy);
 	}
 	
@@ -1028,7 +1029,7 @@
 		outl(w, ioaddr + rfdr);
 
 		if (sis900_debug > 2) {
-			printk(KERN_INFO "%s: Receive Filter Addrss[%d]=%x\n",
+			printk(KERN_DEBUG PFX "%s: Receive Filter Addrss[%d]=%x\n",
 			       net_dev->name, i, inl(ioaddr + rfdr));
 		}
 	}
@@ -1066,7 +1067,7 @@
 	/* load Transmit Descriptor Register */
 	outl(sis_priv->tx_ring_dma, ioaddr + txdp);
 	if (sis900_debug > 2)
-		printk(KERN_INFO "%s: TX descriptor register loaded with: %8.8x\n",
+		printk(KERN_DEBUG PFX "%s: TX descriptor register loaded with: %8.8x\n",
 		       net_dev->name, inl(ioaddr + txdp));
 }
 
@@ -1120,7 +1121,7 @@
 	/* load Receive Descriptor Register */
 	outl(sis_priv->rx_ring_dma, ioaddr + rxdp);
 	if (sis900_debug > 2)
-		printk(KERN_INFO "%s: RX descriptor register loaded with: %8.8x\n",
+		printk(KERN_DEBUG PFX "%s: RX descriptor register loaded with: %8.8x\n",
 		       net_dev->name, inl(ioaddr + rxdp));
 }
 
@@ -1267,7 +1268,7 @@
 	/* Link ON -> OFF */
                 if (!(status & MII_STAT_LINK)){
                 	netif_carrier_off(net_dev);
-                	printk(KERN_INFO "%s: Media Link Off\n", net_dev->name);
+                	printk(KERN_INFO PFX "%s: Media Link Off\n", net_dev->name);
 
                 	/* Change mode issue */
                 	if ((mii_phy->phy_id0 == 0x001D) && 
@@ -1382,7 +1383,7 @@
 		status = mdio_read(net_dev, phy_addr, MII_STATUS);
 
 	if (!(status & MII_STAT_LINK)){
-		printk(KERN_INFO "%s: Media Link Off\n", net_dev->name);
+		printk(KERN_INFO PFX "%s: Media Link Off\n", net_dev->name);
 		sis_priv->autong_complete = 1;
 		netif_carrier_off(net_dev);
 		return;
@@ -1444,7 +1445,7 @@
 			*speed = HW_SPEED_100_MBPS;
 	}
 
-	printk(KERN_INFO "%s: Media Link On %s %s-duplex \n",
+	printk(KERN_INFO PFX "%s: Media Link On %s %s-duplex \n",
 	       				net_dev->name,
 	       				*speed == HW_SPEED_100_MBPS ?
 	       					"100mbps" : "10mbps",
@@ -1467,7 +1468,7 @@
 	unsigned long flags;
 	int i;
 
-	printk(KERN_INFO "%s: Transmit timeout, status %8.8x %8.8x \n",
+	printk(KERN_INFO PFX "%s: Transmit timeout, status %8.8x %8.8x \n",
 	       net_dev->name, inl(ioaddr + cr), inl(ioaddr + isr));
 
 	/* Disable interrupts by clearing the interrupt mask. */
@@ -1570,7 +1571,7 @@
 	net_dev->trans_start = jiffies;
 
 	if (sis900_debug > 3)
-		printk(KERN_INFO "%s: Queued Tx packet at %p size %d "
+		printk(KERN_DEBUG PFX "%s: Queued Tx packet at %p size %d "
 		       "to slot %d.\n",
 		       net_dev->name, skb->data, (int)skb->len, entry);
 
@@ -1617,12 +1618,12 @@
 
 		/* something strange happened !!! */
 		if (status & HIBERR) {
-			printk(KERN_INFO "%s: Abnormal interrupt,"
+			printk(KERN_INFO PFX "%s: Abnormal interrupt,"
 			       "status %#8.8x.\n", net_dev->name, status);
 			break;
 		}
 		if (--boguscnt < 0) {
-			printk(KERN_INFO "%s: Too much work at interrupt, "
+			printk(KERN_INFO PFX "%s: Too much work at interrupt, "
 			       "interrupt status = %#8.8x.\n",
 			       net_dev->name, status);
 			break;
@@ -1630,7 +1631,7 @@
 	} while (1);
 
 	if (sis900_debug > 3)
-		printk(KERN_INFO "%s: exiting interrupt, "
+		printk(KERN_DEBUG PFX "%s: exiting interrupt, "
 		       "interrupt status = 0x%#8.8x.\n",
 		       net_dev->name, inl(ioaddr + isr));
 	
@@ -1656,7 +1657,7 @@
 	u32 rx_status = sis_priv->rx_ring[entry].cmdsts;
 
 	if (sis900_debug > 3)
-		printk(KERN_INFO "sis900_rx, cur_rx:%4.4d, dirty_rx:%4.4d "
+		printk(KERN_DEBUG PFX "sis900_rx, cur_rx:%4.4d, dirty_rx:%4.4d "
 		       "status:0x%8.8x\n",
 		       sis_priv->cur_rx, sis_priv->dirty_rx, rx_status);
 
@@ -1668,7 +1669,7 @@
 		if (rx_status & (ABORT|OVERRUN|TOOLONG|RUNT|RXISERR|CRCERR|FAERR)) {
 			/* corrupted packet received */
 			if (sis900_debug > 3)
-				printk(KERN_INFO "%s: Corrupted packet "
+				printk(KERN_DEBUG PFX "%s: Corrupted packet "
 				       "received, buffer status = 0x%8.8x.\n",
 				       net_dev->name, rx_status);
 			sis_priv->stats.rx_errors++;
@@ -1689,7 +1690,7 @@
 			   some unknow bugs, it is possible that
 			   we are working on NULL sk_buff :-( */
 			if (sis_priv->rx_skbuff[entry] == NULL) {
-				printk(KERN_INFO "%s: NULL pointer " 
+				printk(KERN_INFO PFX "%s: NULL pointer " 
 				       "encountered in Rx ring, skipping\n",
 				       net_dev->name);
 				break;
@@ -1718,7 +1719,7 @@
 				 * "hole" on the buffer ring, it is not clear
 				 * how the hardware will react to this kind
 				 * of degenerated buffer */
-				printk(KERN_INFO "%s: Memory squeeze,"
+				printk(KERN_INFO PFX "%s: Memory squeeze,"
 				       "deferring packet.\n",
 				       net_dev->name);
 				sis_priv->rx_skbuff[entry] = NULL;
@@ -1754,7 +1755,7 @@
 				 * "hole" on the buffer ring, it is not clear
 				 * how the hardware will react to this kind
 				 * of degenerated buffer */
-				printk(KERN_INFO "%s: Memory squeeze,"
+				printk(KERN_INFO PFX "%s: Memory squeeze,"
 				       "deferring packet.\n",
 				       net_dev->name);
 				sis_priv->stats.rx_dropped++;
@@ -1806,7 +1807,7 @@
 		if (tx_status & (ABORT | UNDERRUN | OWCOLL)) {
 			/* packet unsuccessfully transmitted */
 			if (sis900_debug > 3)
-				printk(KERN_INFO "%s: Transmit "
+				printk(KERN_DEBUG PFX "%s: Transmit "
 				       "error, Tx status %8.8x.\n",
 				       net_dev->name, tx_status);
 			sis_priv->stats.tx_errors++;
@@ -2073,12 +2074,10 @@
 		case IF_PORT_AUI: /* AUI */
 		case IF_PORT_100BASEFX: /* 100BaseFx */
                 	/* These Modes are not supported (are they?)*/
-			printk(KERN_INFO "Not supported");
 			return -EOPNOTSUPP;
 			break;
             
 		default:
-			printk(KERN_INFO "Invalid");
 			return -EINVAL;
 		}
 	}

--/aVve/J9H4Wl5yVO--

--fCcDWlUEdh43YKr8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBvDpO2rmHZCWzV+0RAsB1AJ9tfdParizZ6dnsLNzF27RqC+emxACeMXP2
pvIgmbKSzQ0GtEqEtKUhkoI=
=E3NF
-----END PGP SIGNATURE-----

--fCcDWlUEdh43YKr8--
