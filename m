From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bugme-new] [Bug 4223] New: sis900 kernel oop at boot
Date: Sat, 5 Mar 2005 19:45:37 +1100
Message-ID: <20050305084537.GA12678@gondor.apana.org.au>
References: <20050217134440.44f591e2.akpm@osdl.org> <E1D26BP-0005Lg-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="CE+1k2dSO48ffgeK"
Cc: netdev@oss.sgi.com, mangus@deprecated.it, jgarzik@pobox.com,
        webvenza@libero.it
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <E1D26BP-0005Lg-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

Here is the version that moves the necessary code above register_netdev
instead of using init.  It's against netdev-2.6.

> Feb 15 18:26:20 saturno kernel: Unable to handle kernel NULL pointer
> dereference at virtual address 0000000e
> Feb 15 18:26:20 saturno kernel:  printing eip:
> Feb 15 18:26:20 saturno kernel: e1113417
> Feb 15 18:26:20 saturno kernel: *pde = 00000000
> Feb 15 18:26:20 saturno kernel: Oops: 0000 [#1]
> Feb 15 18:26:20 saturno kernel: PREEMPT
> Feb 15 18:26:20 saturno kernel: Modules linked in: sis900 nvidia 8250_pci 8250
> serial_core psmouse
> Feb 15 18:26:20 saturno kernel: CPU:    0
> Feb 15 18:26:20 saturno kernel: EIP:    0060:[<e1113417>]    Tainted: P
> VLI
> Feb 15 18:26:20 saturno kernel: EFLAGS: 00010296   (2.6.10-M7)
> Feb 15 18:26:20 saturno kernel: EIP is at sis900_check_mode+0x17/0xa0 [sis900]

OK, this happened because we got preempted before sis900_mii_probe
finished setting the sis_priv->mii.  Theoretically this can happen
with SMP as well but I suppose the number of SMP machines with sis900
is fairly small.

Anyway, the fix is to make sure that sis900_mii_probe is done before
the device can be opened.  This patch does it by moving the setup
before register_netdevice.

Since the netdev name is not available before register_netdev, I've
changed the relevant printk's to use pci_name instead.  Note that
one of those printk's may be called after register_netdev as well.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== drivers/net/sis900.c 1.69 vs edited =====
--- 1.69/drivers/net/sis900.c	2005-03-03 17:34:44 +11:00
+++ edited/drivers/net/sis900.c	2005-03-05 19:32:29 +11:00
@@ -245,7 +245,7 @@
 	signature = (u16) read_eeprom(ioaddr, EEPROMSignature);    
 	if (signature == 0xffff || signature == 0x0000) {
 		printk (KERN_WARNING "%s: Error EERPOM read %x\n", 
-			net_dev->name, signature);
+			pci_name(pci_dev), signature);
 		return 0;
 	}
 
@@ -277,7 +277,8 @@
 	if (!isa_bridge)
 		isa_bridge = pci_get_device(PCI_VENDOR_ID_SI, 0x0018, isa_bridge);
 	if (!isa_bridge) {
-		printk(KERN_WARNING "%s: Can not find ISA bridge\n", net_dev->name);
+		printk(KERN_WARNING "%s: Can not find ISA bridge\n",
+		       pci_name(pci_dev));
 		return 0;
 	}
 	pci_read_config_byte(isa_bridge, 0x48, &reg);
@@ -396,6 +397,7 @@
 	long ioaddr;
 	int i, ret;
 	char *card_name = card_names[pci_id->driver_data];
+	const char *dev_name = pci_name(pci_dev);
 
 /* when built into the kernel, we only print version if device is found */
 #ifndef MODULE
@@ -473,17 +475,13 @@
 		sis_priv->msg_enable = sis900_debug;
 	else
 		sis_priv->msg_enable = SIS900_DEF_MSG;
-
-	ret = register_netdev(net_dev);
-	if (ret)
-		goto err_unmap_rx;
 		
 	/* Get Mac address according to the chip revision */
 	pci_read_config_byte(pci_dev, PCI_CLASS_REVISION, &(sis_priv->chipset_rev));
 	if(netif_msg_probe(sis_priv))
 		printk(KERN_DEBUG "%s: detected revision %2.2x, "
 				"trying to get MAC address...\n",
-				net_dev->name, sis_priv->chipset_rev);
+				dev_name, sis_priv->chipset_rev);
 	
 	ret = 0;
 	if (sis_priv->chipset_rev == SIS630E_900_REV)
@@ -496,9 +494,9 @@
 		ret = sis900_get_mac_addr(pci_dev, net_dev);
 
 	if (ret == 0) {
-		printk(KERN_WARNING "%s: Cannot read MAC address.\n", net_dev->name);
+		printk(KERN_WARNING "%s: Cannot read MAC address.\n", dev_name);
 		ret = -ENODEV;
-		goto err_out_unregister;
+		goto err_unmap_rx;
 	}
 	
 	/* 630ET : set the mii access mode as software-mode */
@@ -507,9 +505,10 @@
 
 	/* probe for mii transceiver */
 	if (sis900_mii_probe(net_dev) == 0) {
-		printk(KERN_WARNING "%s: Error probing MII device.\n", net_dev->name);
+		printk(KERN_WARNING "%s: Error probing MII device.\n",
+		       dev_name);
 		ret = -ENODEV;
-		goto err_out_unregister;
+		goto err_unmap_rx;
 	}
 
 	/* save our host bridge revision */
@@ -519,6 +518,10 @@
 		pci_dev_put(dev);
 	}
 
+	ret = register_netdev(net_dev);
+	if (ret)
+		goto err_unmap_rx;
+
 	/* print some information about our NIC */
 	printk(KERN_INFO "%s: %s at %#lx, IRQ %d, ", net_dev->name,
 	       card_name, ioaddr, net_dev->irq);
@@ -528,8 +531,6 @@
 
 	return 0;
 
- err_out_unregister:
- 	unregister_netdev(net_dev);
  err_unmap_rx:
 	pci_free_consistent(pci_dev, RX_TOTAL_SIZE, sis_priv->rx_ring,
 		sis_priv->rx_ring_dma);
@@ -556,6 +557,7 @@
 static int __init sis900_mii_probe(struct net_device * net_dev)
 {
 	struct sis900_private * sis_priv = net_dev->priv;
+	const char *dev_name = pci_name(sis_priv->pci_dev);
 	u16 poll_bit = MII_STAT_LINK, status = 0;
 	unsigned long timeout = jiffies + 5 * HZ;
 	int phy_addr;
@@ -576,7 +578,7 @@
 			if (netif_msg_probe(sis_priv))
 				printk(KERN_DEBUG "%s: MII at address %d"
 						" not accessible\n",
-						net_dev->name, phy_addr);
+						dev_name, phy_addr);
 			continue;
 		}
 		
@@ -609,7 +611,7 @@
 					    (mii_status & (MII_STAT_CAN_TX_FDX | MII_STAT_CAN_TX)) ? LAN : HOME;
 				printk(KERN_INFO "%s: %s transceiver found "
 							"at address %d.\n",
-							net_dev->name,
+							dev_name,
 							mii_chip_table[i].name,
 							phy_addr);
 				break;
@@ -617,14 +619,13 @@
 			
 		if( !mii_chip_table[i].phy_id1 ) {
 			printk(KERN_INFO "%s: Unknown PHY transceiver found at address %d.\n",
-			       net_dev->name, phy_addr);
+			       dev_name, phy_addr);
 			mii_phy->phy_types = UNKNOWN;
 		}
 	}
 	
 	if (sis_priv->mii == NULL) {
-		printk(KERN_INFO "%s: No MII transceivers found!\n",
-			net_dev->name);
+		printk(KERN_INFO "%s: No MII transceivers found!\n", dev_name);
 		return 0;
 	}
 
@@ -649,7 +650,7 @@
 			poll_bit ^= (mdio_read(net_dev, sis_priv->cur_phy, MII_STATUS) & poll_bit);
 			if (time_after_eq(jiffies, timeout)) {
 				printk(KERN_WARNING "%s: reset phy and link down now\n",
-					net_dev->name);
+				       dev_name);
 				return -ETIME;
 			}
 		}
@@ -718,7 +719,7 @@
 		sis_priv->mii = default_phy;
 		sis_priv->cur_phy = default_phy->phy_addr;
 		printk(KERN_INFO "%s: Using transceiver found at address %d as default\n",
-					net_dev->name,sis_priv->cur_phy);
+		       pci_name(sis_priv->pci_dev), sis_priv->cur_phy);
 	}
 	
 	status = mdio_read(net_dev, sis_priv->cur_phy, MII_CONTROL);

--CE+1k2dSO48ffgeK--
