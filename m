From: Daniele Venzano <webvenza@libero.it>
Subject: [PATCH 1/5] sis900 printk and stack usage audit
Date: Wed, 8 Dec 2004 12:01:56 +0100
Message-ID: <20041208110156.GB31707@picchio.gall.it>
References: <20041208104721.GA31707@picchio.gall.it>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="XOIedfhf+7KOe/yw"
Return-path: <netdev-bounce@oss.sgi.com>
To: NetDev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20041208104721.GA31707@picchio.gall.it>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--XOIedfhf+7KOe/yw
Content-Type: multipart/mixed; boundary="huq684BweRXVnRxX"
Content-Disposition: inline


--huq684BweRXVnRxX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Audit of current printk() calls
Changed debug levels to 0,1,2,3 as follows:
 0 No debug
 1 load/probe/unload/suspend/resume stuff
 2 rx/tx errors
 3 rx/tx packets and every interrupt are logged (very verbose)
Debug levels are incremental
Removed double printing of version string in module_init and in sis900_probe
Made the sis900_debug parameter modifiable at runtime

Signed-off-by: Daniele Venzano <webvenza@libero.it>

-- 
-----------------------------
Daniele Venzano
Web: http://teg.homeunix.org


--huq684BweRXVnRxX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="sis900-debug1.diff"

Index: sis900.c
===================================================================
--- a/drivers/net/sis900.c	(revision 39)
+++ b/drivers/net/sis900.c	(revision 40)
@@ -183,10 +183,10 @@
 
 module_param(multicast_filter_limit, int, 0444);
 module_param(max_interrupt_work, int, 0444);
-module_param(debug, int, 0444);
+module_param(debug, int, 0644);
 MODULE_PARM_DESC(multicast_filter_limit, "SiS 900/7016 maximum number of filtered multicast addresses");
 MODULE_PARM_DESC(max_interrupt_work, "SiS 900/7016 maximum events handled per interrupt");
-MODULE_PARM_DESC(debug, "SiS 900/7016 debug level (2-4)");
+MODULE_PARM_DESC(debug, "SiS 900/7016 debug level (0-3)");
 
 static int sis900_open(struct net_device *net_dev);
 static int sis900_mii_probe (struct net_device * net_dev);
@@ -236,7 +236,7 @@
 	/* check to see if we have sane EEPROM */
 	signature = (u16) read_eeprom(ioaddr, EEPROMSignature);    
 	if (signature == 0xffff || signature == 0x0000) {
-		printk (KERN_INFO "%s: Error EERPOM read %x\n", 
+		printk (KERN_WARNING "%s: Error: EEPROM signature is %x\n", 
 			net_dev->name, signature);
 		return 0;
 	}
@@ -269,7 +269,7 @@
 	if (!isa_bridge) {
 		isa_bridge = pci_find_device(PCI_VENDOR_ID_SI, 0x0018, isa_bridge);
 		if (!isa_bridge) {
-			printk("%s: Can not find ISA bridge\n", net_dev->name);
+			printk(KERN_WARNING "%s: Can not find ISA bridge\n", net_dev->name);
 			return 0;
 		}
 	}
@@ -390,13 +390,6 @@
 	u8 revision;
 	char *card_name = card_names[pci_id->driver_data];
 
-/* when built into the kernel, we only print version if device is found */
-#ifndef MODULE
-	static int printed_version;
-	if (!printed_version++)
-		printk(version);
-#endif
-
 	/* setup various bits in PCI command register */
 	ret = pci_enable_device(pci_dev);
 	if(ret) return ret;
@@ -554,7 +547,7 @@
 			continue;
 		
 		if ((mii_phy = kmalloc(sizeof(struct mii_phy), GFP_KERNEL)) == NULL) {
-			printk(KERN_INFO "Cannot allocate mem for struct mii_phy\n");
+			printk(KERN_WARNING "Cannot allocate mem for struct mii_phy\n");
 			mii_phy = sis_priv->first_mii;
 			while (mii_phy) {
 				struct mii_phy *phy;
@@ -1015,8 +1008,8 @@
 		outl((i << RFADDR_shift), ioaddr + rfcr);
 		outl(w, ioaddr + rfdr);
 
-		if (sis900_debug > 2) {
-			printk(KERN_INFO "%s: Receive Filter Addrss[%d]=%x\n",
+		if (sis900_debug > 0) {
+			printk(KERN_DEBUG "%s: Receive Filter Addrss[%d]=%x\n",
 			       net_dev->name, i, inl(ioaddr + rfdr));
 		}
 	}
@@ -1053,8 +1046,8 @@
 
 	/* load Transmit Descriptor Register */
 	outl(sis_priv->tx_ring_dma, ioaddr + txdp);
-	if (sis900_debug > 2)
-		printk(KERN_INFO "%s: TX descriptor register loaded with: %8.8x\n",
+	if (sis900_debug > 0)
+		printk(KERN_DEBUG "%s: TX descriptor register loaded with: %8.8x\n",
 		       net_dev->name, inl(ioaddr + txdp));
 }
 
@@ -1107,8 +1100,8 @@
 
 	/* load Receive Descriptor Register */
 	outl(sis_priv->rx_ring_dma, ioaddr + rxdp);
-	if (sis900_debug > 2)
-		printk(KERN_INFO "%s: RX descriptor register loaded with: %8.8x\n",
+	if (sis900_debug > 0)
+		printk(KERN_DEBUG "%s: RX descriptor register loaded with: %8.8x\n",
 		       net_dev->name, inl(ioaddr + rxdp));
 }
 
@@ -1557,8 +1550,8 @@
 
 	net_dev->trans_start = jiffies;
 
-	if (sis900_debug > 3)
-		printk(KERN_INFO "%s: Queued Tx packet at %p size %d "
+	if (sis900_debug > 2)
+		printk(KERN_DEBUG "%s: Queued Tx packet at %p size %d "
 		       "to slot %d.\n",
 		       net_dev->name, skb->data, (int)skb->len, entry);
 
@@ -1617,8 +1610,8 @@
 		}
 	} while (1);
 
-	if (sis900_debug > 3)
-		printk(KERN_INFO "%s: exiting interrupt, "
+	if (sis900_debug > 2)
+		printk(KERN_DEBUG "%s: exiting interrupt, "
 		       "interrupt status = 0x%#8.8x.\n",
 		       net_dev->name, inl(ioaddr + isr));
 	
@@ -1643,8 +1636,8 @@
 	unsigned int entry = sis_priv->cur_rx % NUM_RX_DESC;
 	u32 rx_status = sis_priv->rx_ring[entry].cmdsts;
 
-	if (sis900_debug > 3)
-		printk(KERN_INFO "sis900_rx, cur_rx:%4.4d, dirty_rx:%4.4d "
+	if (sis900_debug > 2)
+		printk(KERN_DEBUG "sis900_rx, cur_rx:%4.4d, dirty_rx:%4.4d "
 		       "status:0x%8.8x\n",
 		       sis_priv->cur_rx, sis_priv->dirty_rx, rx_status);
 
@@ -1655,8 +1648,8 @@
 
 		if (rx_status & (ABORT|OVERRUN|TOOLONG|RUNT|RXISERR|CRCERR|FAERR)) {
 			/* corrupted packet received */
-			if (sis900_debug > 3)
-				printk(KERN_INFO "%s: Corrupted packet "
+			if (sis900_debug > 1)
+				printk(KERN_DEBUG "%s: Corrupted packet "
 				       "received, buffer status = 0x%8.8x.\n",
 				       net_dev->name, rx_status);
 			sis_priv->stats.rx_errors++;
@@ -1793,8 +1786,8 @@
 
 		if (tx_status & (ABORT | UNDERRUN | OWCOLL)) {
 			/* packet unsuccessfully transmitted */
-			if (sis900_debug > 3)
-				printk(KERN_INFO "%s: Transmit "
+			if (sis900_debug > 1)
+				printk(KERN_DEBUG "%s: Transmit "
 				       "error, Tx status %8.8x.\n",
 				       net_dev->name, tx_status);
 			sis_priv->stats.tx_errors++;
@@ -2047,12 +2040,10 @@
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

--huq684BweRXVnRxX--

--XOIedfhf+7KOe/yw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBtt8j2rmHZCWzV+0RAmGtAKCQJtoDkJz7VUY3Ncq/bRxVLpjcSwCgsEd2
xsqL2EXJ+V8uQT8Ln6mT5uE=
=r8bb
-----END PGP SIGNATURE-----

--XOIedfhf+7KOe/yw--
