From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 4/x: [NETDRV] Merge register_netdev calls
Date: Fri, 25 Jun 2004 20:12:54 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040625101254.GA10459@gondor.apana.org.au>
References: <20040313025859.GA8186@gondor.apana.org.au> <405C294D.5040508@pobox.com> <20040520111937.GA21804@gondor.apana.org.au> <20040522074435.GA9628@gondor.apana.org.au> <20040529084109.GA13032@gondor.apana.org.au> <40BE3778.1020404@pobox.com> <20040605052737.GA27406@gondor.apana.org.au> <40C8F824.50904@pobox.com> <20040611020855.GA5480@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="tThc/1wpZn/ma/RB"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20040611020855.GA5480@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--tThc/1wpZn/ma/RB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Jun 11, 2004 at 12:08:55PM +1000, herbert wrote:
> 
> In fact it's really making these ISA/MCA probe() functions more
> like the ones we have for PCI.

To illustrate this, let's take the first driver touched by 4/x.
In 3c503, the function init_module() essentially does

for each ioaddr
	if (do_el2_probe(ioaddr) == 0)
		return 0

And do_el2_probe() just calls el2_probe1() which is similar
to your average PCI probe function except that the first thing
it does is to make sure that the device exists at ioaddr.

This is not that different from PCI where it would look
like

for each PCI device matching the vendor/product numbers
	if (do_el2_probe(device) == 0)
		return 0

Now before my patch, register_netdev was being called just
after do_el2_probe() returns.  My patch simply moves it to
the end of el2_probe1() which is exactly what would happen
if this were a PCI driver.

I've rediffed it against today's BK tree.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--tThc/1wpZn/ma/RB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== drivers/net/3c503.c 1.20 vs edited =====
--- 1.20/drivers/net/3c503.c	2004-05-23 03:40:55 +10:00
+++ edited/drivers/net/3c503.c	2004-06-25 20:01:08 +10:00
@@ -162,12 +162,7 @@
 	err = do_el2_probe(dev);
 	if (err)
 		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	return dev;
-out1:
-	cleanup_card(dev);
 out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -343,6 +338,10 @@
     dev->poll_controller = ei_poll;
 #endif
 
+    retval = register_netdev(dev);
+    if (retval)
+	goto out1;
+
     if (dev->mem_start)
 	printk("%s: %s - %dkB RAM, 8kB shared mem window at %#6lx-%#6lx.\n",
 		dev->name, ei_status.name, (wordlength+1)<<3,
@@ -702,11 +701,8 @@
 		dev->base_addr = io[this_dev];
 		dev->mem_end = xcvr[this_dev];	/* low 4bits = xcvr sel. */
 		if (do_el2_probe(dev) == 0) {
-			if (register_netdev(dev) == 0) {
-				dev_el2[found++] = dev;
-				continue;
-			}
-			cleanup_card(dev);
+			dev_el2[found++] = dev;
+			continue;
 		}
 		free_netdev(dev);
 		printk(KERN_WARNING "3c503.c: No 3c503 card found (i/o = 0x%x).\n", io[this_dev]);
===== drivers/net/3c515.c 1.29 vs edited =====
--- 1.29/drivers/net/3c515.c	2004-03-30 20:17:59 +10:00
+++ edited/drivers/net/3c515.c	2004-06-25 20:01:08 +10:00
@@ -373,7 +373,7 @@
 #endif /* __ISAPNP__ */
 
 static struct net_device *corkscrew_scan(int unit);
-static void corkscrew_setup(struct net_device *dev, int ioaddr,
+static int corkscrew_setup(struct net_device *dev, int ioaddr,
 			    struct pnp_dev *idev, int card_number);
 static int corkscrew_open(struct net_device *dev);
 static void corkscrew_timer(unsigned long arg);
@@ -537,10 +537,9 @@
 			printk(KERN_INFO "3c515 Resource configuration register %#4.4x, DCR %4.4x.\n",
 		     		inl(ioaddr + 0x2002), inw(ioaddr + 0x2000));
 			/* irq = inw(ioaddr + 0x2002) & 15; */ /* Use the irq from isapnp */
-			corkscrew_setup(dev, ioaddr, idev, cards_found++);
 			SET_NETDEV_DEV(dev, &idev->dev);
 			pnp_cards++;
-			err = register_netdev(dev);
+			err = corkscrew_setup(dev, ioaddr, idev, cards_found++);
 			if (!err)
 				return dev;
 			cleanup_card(dev);
@@ -556,8 +555,7 @@
 
 		printk(KERN_INFO "3c515 Resource configuration register %#4.4x, DCR %4.4x.\n",
 		     inl(ioaddr + 0x2002), inw(ioaddr + 0x2000));
-		corkscrew_setup(dev, ioaddr, NULL, cards_found++);
-		err = register_netdev(dev);
+		err = corkscrew_setup(dev, ioaddr, NULL, cards_found++);
 		if (!err)
 			return dev;
 		cleanup_card(dev);
@@ -566,7 +564,7 @@
 	return NULL;
 }
 
-static void corkscrew_setup(struct net_device *dev, int ioaddr,
+static int corkscrew_setup(struct net_device *dev, int ioaddr,
 			    struct pnp_dev *idev, int card_number)
 {
 	struct corkscrew_private *vp = (struct corkscrew_private *) dev->priv;
@@ -689,6 +687,8 @@
 	dev->get_stats = &corkscrew_get_stats;
 	dev->set_multicast_list = &set_rx_mode;
 	dev->ethtool_ops = &netdev_ethtool_ops;
+
+	return register_netdev(dev);
 }
 
 
===== drivers/net/3c523.c 1.16 vs edited =====
--- 1.16/drivers/net/3c523.c	2004-05-23 03:40:55 +10:00
+++ edited/drivers/net/3c523.c	2004-06-25 20:01:09 +10:00
@@ -572,6 +572,10 @@
         dev->flags&=~IFF_MULTICAST;     /* Multicast doesn't work */
 #endif
 
+	retval = register_netdev(dev);
+	if (retval)
+		goto err_out;
+
 	return 0;
 err_out:
 	mca_set_adapter_procfn(slot, NULL, NULL);
@@ -600,12 +604,7 @@
 	err = do_elmc_probe(dev);
 	if (err)
 		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	return dev;
-out1:
-	cleanup_card(dev);
 out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -1288,12 +1287,9 @@
 		dev->irq=irq[this_dev];
 		dev->base_addr=io[this_dev];
 		if (do_elmc_probe(dev) == 0) {
-			if (register_netdev(dev) == 0) {
-				dev_elmc[this_dev] = dev;
-				found++;
-				continue;
-			}
-			cleanup_card(dev);
+			dev_elmc[this_dev] = dev;
+			found++;
+			continue;
 		}
 		free_netdev(dev);
 		if (io[this_dev]==0)
===== drivers/net/ac3200.c 1.19 vs edited =====
--- 1.19/drivers/net/ac3200.c	2004-05-23 03:40:55 +10:00
+++ edited/drivers/net/ac3200.c	2004-06-25 20:01:09 +10:00
@@ -147,12 +147,7 @@
 	err = do_ac3200_probe(dev);
 	if (err)
 		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	return dev;
-out1:
-	cleanup_card(dev);
 out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -284,7 +279,14 @@
 	dev->poll_controller = ei_poll;
 #endif
 	NS8390_init(dev, 0);
+
+	retval = register_netdev(dev);
+	if (retval)
+		goto out2;
 	return 0;
+out2:
+	if (ei_status.reg0)
+		iounmap((void *)dev->mem_start);
 out1:
 	free_irq(dev->irq, dev);
 out:
@@ -402,11 +404,8 @@
 		dev->base_addr = io[this_dev];
 		dev->mem_start = mem[this_dev];		/* Currently ignored by driver */
 		if (do_ac3200_probe(dev) == 0) {
-			if (register_netdev(dev) == 0) {
-				dev_ac32[found++] = dev;
-				continue;
-			}
-			cleanup_card(dev);
+			dev_ac32[found++] = dev;
+			continue;
 		}
 		free_netdev(dev);
 		printk(KERN_WARNING "ac3200.c: No ac3200 card found (i/o = 0x%x).\n", io[this_dev]);
===== drivers/net/cs89x0.c 1.24 vs edited =====
--- 1.24/drivers/net/cs89x0.c	2004-05-23 03:40:55 +10:00
+++ edited/drivers/net/cs89x0.c	2004-06-25 20:01:09 +10:00
@@ -307,13 +307,7 @@
 	}
 	if (err)
 		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	return dev;
-out1:
-	outw(PP_ChipID, dev->base_addr + ADD_PORT);
-	release_region(dev->base_addr, NETCARD_IO_EXTENT);
 out:
 	free_netdev(dev);
 	printk(KERN_WARNING "cs89x0: no cs8900 or cs8920 detected.  Be sure to disable PnP with SETUP\n");
@@ -718,7 +712,13 @@
 	printk("\n");
 	if (net_debug)
 		printk("cs89x0_probe1() successful\n");
+
+	retval = register_netdev(dev);
+	if (retval)
+		goto out3;
 	return 0;
+out3:
+	outw(PP_ChipID, dev->base_addr + ADD_PORT);
 out2:
 	release_region(ioaddr & ~3, NETCARD_IO_EXTENT);
 out1:
@@ -1806,13 +1806,6 @@
 	if (ret)
 		goto out;
 
-        if (register_netdev(dev) != 0) {
-                printk(KERN_ERR "cs89x0.c: No card found at 0x%x\n", io);
-                ret = -ENXIO;
-		outw(PP_ChipID, dev->base_addr + ADD_PORT);
-		release_region(dev->base_addr, NETCARD_IO_EXTENT);
-		goto out;
-        }
 	dev_cs89x0 = dev;
 	return 0;
 out:
===== drivers/net/e2100.c 1.18 vs edited =====
--- 1.18/drivers/net/e2100.c	2004-05-23 03:40:55 +10:00
+++ edited/drivers/net/e2100.c	2004-06-25 20:01:09 +10:00
@@ -161,12 +161,7 @@
 	err = do_e2100_probe(dev);
 	if (err)
 		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	return dev;
-out1:
-	cleanup_card(dev);
 out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -278,6 +273,9 @@
 #endif
 	NS8390_init(dev, 0);
 
+	retval = register_netdev(dev);
+	if (retval)
+		goto out;
 	return 0;
 out:
 	release_region(ioaddr, E21_IO_EXTENT);
@@ -445,11 +443,8 @@
 		dev->mem_start = mem[this_dev];
 		dev->mem_end = xcvr[this_dev];	/* low 4bits = xcvr sel. */
 		if (do_e2100_probe(dev) == 0) {
-			if (register_netdev(dev) == 0) {
-				dev_e21[found++] = dev;
-				continue;
-			}
-			cleanup_card(dev);
+			dev_e21[found++] = dev;
+			continue;
 		}
 		free_netdev(dev);
 		printk(KERN_WARNING "e2100.c: No E2100 card found (i/o = 0x%x).\n", io[this_dev]);
===== drivers/net/eepro.c 1.25 vs edited =====
--- 1.25/drivers/net/eepro.c	2004-05-23 03:40:55 +10:00
+++ edited/drivers/net/eepro.c	2004-06-25 20:01:10 +10:00
@@ -596,12 +596,7 @@
 	err = do_eepro_probe(dev);
 	if (err)
 		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	return dev;
-out1:
-	release_region(dev->base_addr, EEPRO_IO_EXTENT);
 out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -747,6 +742,7 @@
 	struct eepro_local *lp;
 	enum iftype { AUI=0, BNC=1, TPE=2 };
 	int ioaddr = dev->base_addr;
+	int err;
 
 	/* Grab the region so we can find another board if autoIRQ fails. */
 	if (!request_region(ioaddr, EEPRO_IO_EXTENT, DRV_NAME)) { 
@@ -856,10 +852,16 @@
 
 	/* reset 82595 */
 	eepro_reset(ioaddr);
+
+	err = register_netdev(dev);
+	if (err)
+		goto err;
 	return 0;
 exit:
+	err = -ENODEV;
+err:
  	release_region(dev->base_addr, EEPRO_IO_EXTENT);
- 	return -ENODEV;
+ 	return err;
 }
 
 /* Open/initialize the board.  This is called (in the current kernel)
@@ -1756,11 +1758,8 @@
 		dev->irq = irq[i];
 
 		if (do_eepro_probe(dev) == 0) {
-			if (register_netdev(dev) == 0) {
-				dev_eepro[n_eepro++] = dev;
-				continue;
-			}
-			release_region(dev->base_addr, EEPRO_IO_EXTENT);
+			dev_eepro[n_eepro++] = dev;
+			continue;
 		}
 		free_netdev(dev);
 		break;
===== drivers/net/eexpress.c 1.18 vs edited =====
--- 1.18/drivers/net/eexpress.c	2004-05-21 07:16:23 +10:00
+++ edited/drivers/net/eexpress.c	2004-06-25 20:01:10 +10:00
@@ -436,11 +436,8 @@
 	netdev_boot_setup_check(dev);
 
 	err = do_express_probe(dev);
-	if (!err) {
-		err = register_netdev(dev);
-		if (!err)
-			return dev;
-	}
+	if (!err)
+		return dev;
 	free_netdev(dev);
 	return ERR_PTR(err);
 }
@@ -1205,7 +1202,8 @@
 	dev->set_multicast_list = &eexp_set_multicast;
 	dev->tx_timeout = eexp_timeout;
 	dev->watchdog_timeo = 2*HZ;
-	return 0;
+
+	return register_netdev(dev);
 }
 
 /*
@@ -1716,7 +1714,7 @@
 				break;
 			printk(KERN_NOTICE "eexpress.c: Module autoprobe not recommended, give io=xx.\n");
 		}
-		if (do_express_probe(dev) == 0 && register_netdev(dev) == 0) {
+		if (do_express_probe(dev) == 0) {
 			dev_eexp[this_dev] = dev;
 			found++;
 			continue;
===== drivers/net/es3210.c 1.13 vs edited =====
--- 1.13/drivers/net/es3210.c	2004-05-21 07:16:23 +10:00
+++ edited/drivers/net/es3210.c	2004-06-25 20:01:10 +10:00
@@ -176,12 +176,7 @@
 	err = do_es_probe(dev);
 	if (err)
 		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	return dev;
-out1:
-	cleanup_card(dev);
 out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -304,6 +299,10 @@
 	dev->poll_controller = ei_poll;
 #endif
 	NS8390_init(dev, 0);
+
+	retval = register_netdev(dev);
+	if (retval)
+		goto out1;
 	return 0;
 out1:
 	free_irq(dev->irq, dev);
@@ -439,11 +438,8 @@
 		dev->base_addr = io[this_dev];
 		dev->mem_start = mem[this_dev];
 		if (do_es_probe(dev) == 0) {
-			if (register_netdev(dev) == 0) {
-				dev_es3210[found++] = dev;
-				continue;
-			}
-			cleanup_card(dev);
+			dev_es3210[found++] = dev;
+			continue;
 		}
 		free_netdev(dev);
 		printk(KERN_WARNING "es3210.c: No es3210 card found (i/o = 0x%x).\n", io[this_dev]);
===== drivers/net/eth16i.c 1.19 vs edited =====
--- 1.19/drivers/net/eth16i.c	2004-05-23 03:40:55 +10:00
+++ edited/drivers/net/eth16i.c	2004-06-25 20:01:10 +10:00
@@ -473,13 +473,7 @@
 	err = do_eth16i_probe(dev);
 	if (err)
 		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	return dev;
-out1:
-	free_irq(dev->irq, dev);
-	release_region(dev->base_addr, ETH16I_IO_EXTENT);
 out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -569,7 +563,13 @@
 	dev->tx_timeout 	= eth16i_timeout;
 	dev->watchdog_timeo	= TX_TIMEOUT;
 	spin_lock_init(&lp->lock);
+
+	retval = register_netdev(dev);
+	if (retval)
+		goto out1;
 	return 0;
+out1:
+	free_irq(dev->irq, dev);
 out:
 	release_region(ioaddr, ETH16I_IO_EXTENT);
 	return retval;
@@ -1462,12 +1462,8 @@
 		}
 
 		if (do_eth16i_probe(dev) == 0) {
-			if (register_netdev(dev) == 0) {
-				dev_eth16i[found++] = dev;
-				continue;
-			}
-			free_irq(dev->irq, dev);
-			release_region(dev->base_addr, ETH16I_IO_EXTENT);
+			dev_eth16i[found++] = dev;
+			continue;
 		}
 		printk(KERN_WARNING "eth16i.c No Eth16i card found (i/o = 0x%x).\n",
 		       io[this_dev]);
===== drivers/net/hp-plus.c 1.16 vs edited =====
--- 1.16/drivers/net/hp-plus.c	2004-05-23 03:40:55 +10:00
+++ edited/drivers/net/hp-plus.c	2004-06-25 20:01:10 +10:00
@@ -159,12 +159,7 @@
 	err = do_hpp_probe(dev);
 	if (err)
 		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	return dev;
-out1:
-	cleanup_card(dev);
 out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -271,6 +266,9 @@
 	/* Leave the 8390 and HP chip reset. */
 	outw(inw(ioaddr + HPP_OPTION) & ~EnableIRQ, ioaddr + HPP_OPTION);
 
+	retval = register_netdev(dev);
+	if (retval)
+		goto out;
 	return 0;
 out:
 	release_region(ioaddr, HP_IO_EXTENT);
@@ -463,11 +461,8 @@
 		dev->irq = irq[this_dev];
 		dev->base_addr = io[this_dev];
 		if (do_hpp_probe(dev) == 0) {
-			if (register_netdev(dev) == 0) {
-				dev_hpp[found++] = dev;
-				continue;
-			}
-			cleanup_card(dev);
+			dev_hpp[found++] = dev;
+			continue;
 		}
 		free_netdev(dev);
 		printk(KERN_WARNING "hp-plus.c: No HP-Plus card found (i/o = 0x%x).\n", io[this_dev]);
===== drivers/net/hp.c 1.14 vs edited =====
--- 1.14/drivers/net/hp.c	2004-05-23 03:40:55 +10:00
+++ edited/drivers/net/hp.c	2004-06-25 20:01:10 +10:00
@@ -123,12 +123,7 @@
 	err = do_hp_probe(dev);
 	if (err)
 		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	return dev;
-out1:
-	cleanup_card(dev);
 out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -227,7 +222,12 @@
 	ei_status.block_output = &hp_block_output;
 	hp_init_card(dev);
 
+	retval = register_netdev(dev);
+	if (retval)
+		goto out1;
 	return 0;
+out1:
+	free_irq(dev->irq, dev);
 out:
 	release_region(ioaddr, HP_IO_EXTENT);
 	return retval;
@@ -432,11 +432,8 @@
 		dev->irq = irq[this_dev];
 		dev->base_addr = io[this_dev];
 		if (do_hp_probe(dev) == 0) {
-			if (register_netdev(dev) == 0) {
-				dev_hp[found++] = dev;
-				continue;
-			}
-			cleanup_card(dev);
+			dev_hp[found++] = dev;
+			continue;
 		}
 		free_netdev(dev);
 		printk(KERN_WARNING "hp.c: No HP card found (i/o = 0x%x).\n", io[this_dev]);
===== drivers/net/hp100.c 1.28 vs edited =====
--- 1.28/drivers/net/hp100.c	2004-05-21 07:16:23 +10:00
+++ edited/drivers/net/hp100.c	2004-06-25 20:01:11 +10:00
@@ -411,12 +411,7 @@
 	if (err)
 		goto out;
 
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	return dev;
- out1:
-	release_region(dev->base_addr, HP100_REGION_SIZE);
  out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -770,11 +765,22 @@
 		printk("Warning! Link down.\n");
 	}
 
+	err = register_netdev(dev);
+	if (err)
+		goto out3;
+
 	return 0;
+out3:
+	if (local_mode == 1)
+		pci_free_consistent(lp->pci_dev, MAX_RINGSIZE + 0x0f, 
+				    lp->page_vaddr_algn, 
+				    virt_to_whatever(dev, lp->page_vaddr_algn));
+	if (mem_ptr_virt)
+		iounmap(mem_ptr_virt);
 out2:
 	release_region(ioaddr, HP100_REGION_SIZE);
 out1:
-	return -ENODEV;
+	return err;
 }
 
 /* This procedure puts the card into a stable init state */
@@ -2868,18 +2874,12 @@
 	if (err)
 		goto out1;
 
-	err = register_netdev(dev);
-	if (err)
-		goto out2;
-	
 #ifdef HP100_DEBUG
 	printk("hp100: %s: EISA adapter found at 0x%x\n", dev->name, 
 	       dev->base_addr);
 #endif
 	gendev->driver_data = dev;
 	return 0;
- out2:
-	release_region(dev->base_addr, HP100_REGION_SIZE);
  out1:
 	free_netdev(dev);
 	return err;
@@ -2938,17 +2938,12 @@
 	err = hp100_probe1(dev, ioaddr, HP100_BUS_PCI, pdev);
 	if (err) 
 		goto out1;
-	err = register_netdev(dev);
-	if (err)
-		goto out2;
 	
 #ifdef HP100_DEBUG
 	printk("hp100: %s: PCI adapter found at 0x%x\n", dev->name, ioaddr);
 #endif
 	pci_set_drvdata(pdev, dev);
 	return 0;
- out2:
-	release_region(dev->base_addr, HP100_REGION_SIZE);
  out1:
 	free_netdev(dev);
 	return err;
@@ -3016,15 +3011,9 @@
 		SET_MODULE_OWNER(dev);
 
 		err = hp100_isa_probe(dev, hp100_port[i]);
-		if (!err) {
-			err = register_netdev(dev);
-			if (!err) 
-				hp100_devlist[cards++] = dev;
-			else
-				release_region(dev->base_addr, HP100_REGION_SIZE);
-		}
-
-		if (err)
+		if (!err)
+			hp100_devlist[cards++] = dev;
+		else
 			free_netdev(dev);
 	}
 
===== drivers/net/isa-skeleton.c 1.13 vs edited =====
--- 1.13/drivers/net/isa-skeleton.c	2004-05-21 07:16:23 +10:00
+++ edited/drivers/net/isa-skeleton.c	2004-06-25 20:01:11 +10:00
@@ -176,12 +176,7 @@
 	err = do_netcard_probe(dev);
 	if (err)
 		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	return dev;
-out1:
-	cleanup_card(dev);
 out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -316,7 +311,15 @@
 
         dev->tx_timeout		= &net_tx_timeout;
         dev->watchdog_timeo	= MY_TX_TIMEOUT; 
+
+	err = register_netdev(dev);
+	if (err)
+		goto out2;
 	return 0;
+out2:
+#ifdef jumpered_dma
+	free_dma(dev->dma);
+#endif
 out1:
 #ifdef jumpered_interrupts
 	free_irq(dev->irq, dev);
@@ -691,11 +694,8 @@
 	dev->dma       = dma;
 	dev->mem_start = mem;
 	if (do_netcard_probe(dev) == 0) {
-		if (register_netdev(dev) == 0)
-			this_device = dev;
-			return 0;
-		}
-		cleanup_card(dev);
+		this_device = dev;
+		return 0;
 	}
 	free_netdev(dev);
 	return -ENXIO;
===== drivers/net/lance.c 1.22 vs edited =====
--- 1.22/drivers/net/lance.c	2004-05-21 07:16:23 +10:00
+++ edited/drivers/net/lance.c	2004-06-25 20:01:11 +10:00
@@ -355,11 +355,8 @@
 		dev->base_addr = io[this_dev];
 		dev->dma = dma[this_dev];
 		if (do_lance_probe(dev) == 0) {
-			if (register_netdev(dev) == 0) {
-				dev_lance[found++] = dev;
-				continue;
-			}
-			cleanup_card(dev);
+			dev_lance[found++] = dev;
+			continue;
 		}
 		free_netdev(dev);
 		break;
@@ -447,12 +444,7 @@
 	err = do_lance_probe(dev);
 	if (err)
 		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	return dev;
-out1:
-	cleanup_card(dev);
 out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -723,6 +715,9 @@
 	dev->tx_timeout = lance_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
+	err = register_netdev(dev);
+	if (err)
+		goto out_dma;
 	return 0;
 out_dma:
 	if (dev->dma != 4)
===== drivers/net/lne390.c 1.14 vs edited =====
--- 1.14/drivers/net/lne390.c	2004-05-23 03:40:55 +10:00
+++ edited/drivers/net/lne390.c	2004-06-25 20:01:12 +10:00
@@ -168,12 +168,7 @@
 	err = do_lne390_probe(dev);
 	if (err)
 		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	return dev;
-out1:
-	cleanup_card(dev);
 out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -307,7 +302,14 @@
 	dev->poll_controller = ei_poll;
 #endif
 	NS8390_init(dev, 0);
+
+	ret = register_netdev(dev);
+	if (ret)
+		goto unmap;
 	return 0;
+unmap:
+	if (ei_status.reg0)
+		iounmap((void *)dev->mem_start);
 cleanup:
 	free_irq(dev->irq, dev);
 	return ret;
@@ -436,11 +438,8 @@
 		dev->base_addr = io[this_dev];
 		dev->mem_start = mem[this_dev];
 		if (do_lne390_probe(dev) == 0) {
-			if (register_netdev(dev) == 0) {
-				dev_lne[found++] = dev;
-				continue;
-			}
-			cleanup_card(dev);
+			dev_lne[found++] = dev;
+			continue;
 		}
 		free_netdev(dev);
 		printk(KERN_WARNING "lne390.c: No LNE390 card found (i/o = 0x%x).\n", io[this_dev]);
===== drivers/net/ne-h8300.c 1.4 vs edited =====
--- 1.4/drivers/net/ne-h8300.c	2004-05-23 03:40:55 +10:00
+++ edited/drivers/net/ne-h8300.c	2004-06-25 20:01:11 +10:00
@@ -180,12 +180,7 @@
 	err = do_ne_probe(dev);
 	if (err)
 		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	return dev;
-out1:
-	cleanup_card(dev);
 out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -325,8 +320,13 @@
 	dev->poll_controller = ei_poll;
 #endif
 	NS8390_init(dev, 0);
-	return 0;
 
+	ret = register_netdev(dev);
+	if (ret)
+		goto out_irq;
+	return 0;
+out_irq:
+	free_irq(dev->irq, dev);
 err_out:
 	release_region(ioaddr, NE_IO_EXTENT);
 	return ret;
@@ -633,11 +633,8 @@
 		err = init_reg_offset(dev, dev->base_addr);
 		if (!err) {
 			if (do_ne_probe(dev) == 0) {
-				if (register_netdev(dev) == 0) {
-					dev_ne[found++] = dev;
-					continue;
-				}
-				cleanup_card(dev);
+				dev_ne[found++] = dev;
+				continue;
 			}
 		}
 		free_netdev(dev);
===== drivers/net/ne.c 1.22 vs edited =====
--- 1.22/drivers/net/ne.c	2004-05-23 03:40:55 +10:00
+++ edited/drivers/net/ne.c	2004-06-25 20:01:12 +10:00
@@ -220,12 +220,7 @@
 	err = do_ne_probe(dev);
 	if (err)
 		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	return dev;
-out1:
-	cleanup_card(dev);
 out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -506,8 +501,14 @@
 	dev->poll_controller = ei_poll;
 #endif
 	NS8390_init(dev, 0);
+
+	ret = register_netdev(dev);
+	if (ret)
+		goto out_irq;
 	return 0;
 
+out_irq:
+	free_irq(dev->irq, dev);
 err_out:
 	release_region(ioaddr, NE_IO_EXTENT);
 	return ret;
@@ -798,11 +799,8 @@
 		dev->mem_end = bad[this_dev];
 		dev->base_addr = io[this_dev];
 		if (do_ne_probe(dev) == 0) {
-			if (register_netdev(dev) == 0) {
-				dev_ne[found++] = dev;
-				continue;
-			}
-			cleanup_card(dev);
+			dev_ne[found++] = dev;
+			continue;
 		}
 		free_netdev(dev);
 		if (found)
===== drivers/net/ne2.c 1.16 vs edited =====
--- 1.16/drivers/net/ne2.c	2004-05-23 03:40:55 +10:00
+++ edited/drivers/net/ne2.c	2004-06-25 20:01:12 +10:00
@@ -301,12 +301,7 @@
 	err = do_ne2_probe(dev);
 	if (err)
 		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	return dev;
-out1:
-	cleanup_card(dev);
 out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -517,7 +512,14 @@
 	dev->poll_controller = ei_poll;
 #endif
 	NS8390_init(dev, 0);
+
+	retval = register_netdev(dev);
+	if (retval)
+		goto out1;
 	return 0;
+out1:
+	mca_set_adapter_procfn( ei_status.priv, NULL, NULL);
+	free_irq(dev->irq, dev);
 out:
 	release_region(base_addr, NE_IO_EXTENT);
 	return retval;
@@ -800,11 +802,8 @@
 		dev->mem_end = bad[this_dev];
 		dev->base_addr = io[this_dev];
 		if (do_ne2_probe(dev) == 0) {
-			if (register_netdev(dev) == 0) {
-				dev_ne[found++] = dev;
-				continue;
-			}
-			cleanup_card(dev);
+			dev_ne[found++] = dev;
+			continue;
 		}
 		free_netdev(dev);
 		break;
===== drivers/net/smc-ultra.c 1.22 vs edited =====
--- 1.22/drivers/net/smc-ultra.c	2004-05-23 03:40:55 +10:00
+++ edited/drivers/net/smc-ultra.c	2004-06-25 20:01:14 +10:00
@@ -195,12 +195,7 @@
 	err = do_ultra_probe(dev);
 	if (err)
 		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	return dev;
-out1:
-	cleanup_card(dev);
 out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -321,6 +316,9 @@
 #endif
 	NS8390_init(dev, 0);
 
+	retval = register_netdev(dev);
+	if (retval)
+		goto out;
 	return 0;
 out:
 	release_region(ioaddr, ULTRA_IO_EXTENT);
@@ -579,11 +577,8 @@
 		dev->irq = irq[this_dev];
 		dev->base_addr = io[this_dev];
 		if (do_ultra_probe(dev) == 0) {
-			if (register_netdev(dev) == 0) {
-				dev_ultra[found++] = dev;
-				continue;
-			}
-			cleanup_card(dev);
+			dev_ultra[found++] = dev;
+			continue;
 		}
 		free_netdev(dev);
 		printk(KERN_WARNING "smc-ultra.c: No SMC Ultra card found (i/o = 0x%x).\n", io[this_dev]);
===== drivers/net/wd.c 1.19 vs edited =====
--- 1.19/drivers/net/wd.c	2004-05-23 03:40:55 +10:00
+++ edited/drivers/net/wd.c	2004-06-25 20:01:15 +10:00
@@ -148,12 +148,7 @@
 	err = do_wd_probe(dev);
 	if (err)
 		goto out;
-	err = register_netdev(dev);
-	if (err)
-		goto out1;
 	return dev;
-out1:
-	cleanup_card(dev);
 out:
 	free_netdev(dev);
 	return ERR_PTR(err);
@@ -163,6 +158,7 @@
 static int __init wd_probe1(struct net_device *dev, int ioaddr)
 {
 	int i;
+	int err;
 	int checksum = 0;
 	int ancient = 0;			/* An old card without config registers. */
 	int word16 = 0;				/* 0 = 8 bit, 1 = 16 bit */
@@ -349,7 +345,10 @@
 		outb(inb(ioaddr+4)|0x80, ioaddr+4);
 #endif
 
-	return 0;
+	err = register_netdev(dev);
+	if (err)
+		free_irq(dev->irq, dev);
+	return err;
 }
 
 static int
@@ -519,11 +518,8 @@
 		dev->mem_start = mem[this_dev];
 		dev->mem_end = mem_end[this_dev];
 		if (do_wd_probe(dev) == 0) {
-			if (register_netdev(dev) == 0) {
-				dev_wd[found++] = dev;
-				continue;
-			}
-			cleanup_card(dev);
+			dev_wd[found++] = dev;
+			continue;
 		}
 		free_netdev(dev);
 		printk(KERN_WARNING "wd.c: No wd80x3 card found (i/o = 0x%x).\n", io[this_dev]);

--tThc/1wpZn/ma/RB--
