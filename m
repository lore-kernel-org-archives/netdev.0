From: Amol Lad <amol@verismonetworks.com>
Subject: [PATCH] ioremap balanced with iounmap for drivers/net
Date: Mon, 25 Sep 2006 11:42:29 +0530
Message-ID: <1159164749.25016.26.camel@amol.verismonetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail01.verismonetworks.com ([164.164.99.228]:30651 "EHLO
	mail01.verismonetworks.com") by vger.kernel.org with ESMTP
	id S1751298AbWIYGJL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Sep 2006 02:09:11 -0400
Received: from romer.verismonetworks.com (romer.verismonetworks.com [192.168.1.8])
	by mail01.verismonetworks.com (Postfix) with ESMTP id C9BBE346B9
	for <netdev@vger.kernel.org>; Mon, 25 Sep 2006 11:39:07 +0530 (IST)
Received: from [192.168.1.159] (unknown [192.168.1.159])
	by romer.verismonetworks.com (Postfix) with ESMTP id C3E43207075
	for <netdev@vger.kernel.org>; Mon, 25 Sep 2006 11:39:07 +0530 (IST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Incorporated Auke's comments

ioremap must be balanced by an iounmap and failing to do so can result
in a memory leak.

Tested (compilation only) with:
- allmodconfig
- Modifying drivers/net/Kconfig to make sure that the changed file is
compiling without warning

Signed-off-by: Amol Lad <amol@verismonetworks.com>
---
 e2100.c                       |    2 ++
 es3210.c                      |    2 ++
 fs_enet/mac-fcc.c             |   25 +++++++++++++++++++++----
 fs_enet/mii-fec.c             |    4 ++++
 ioc3-eth.c                    |    1 +
 myri_sbus.c                   |    7 +++++++
 pcmcia/ibmtr_cs.c             |    1 +
 smc-ultra.c                   |    2 ++
 tokenring/ibmtr.c             |   11 +++++++++--
 wan/farsync.c                 |    1 +
 wd.c                          |    4 +++-
 wireless/ipw2100.c            |    3 +++
 wireless/prism54/islpci_dev.c |    2 ++
---
diff -uprN -X linux-2.6.18-orig/Documentation/dontdiff linux-2.6.18-orig/drivers/net/e2100.c linux-2.6.18/drivers/net/e2100.c
--- linux-2.6.18-orig/drivers/net/e2100.c	2006-09-21 10:15:36.000000000 +0530
+++ linux-2.6.18/drivers/net/e2100.c	2006-09-22 12:16:18.000000000 +0530
@@ -279,6 +279,8 @@ static int __init e21_probe1(struct net_
 		goto out;
 	return 0;
 out:
+	if (ei_status.mem)
+		iounmap(ei_status.mem);
 	release_region(ioaddr, E21_IO_EXTENT);
 	return retval;
 }
diff -uprN -X linux-2.6.18-orig/Documentation/dontdiff linux-2.6.18-orig/drivers/net/es3210.c linux-2.6.18/drivers/net/es3210.c
--- linux-2.6.18-orig/drivers/net/es3210.c	2006-09-21 10:15:36.000000000 +0530
+++ linux-2.6.18/drivers/net/es3210.c	2006-09-22 12:18:22.000000000 +0530
@@ -306,6 +306,8 @@ static int __init es_probe1(struct net_d
 out1:
 	free_irq(dev->irq, dev);
 out:
+	if (ei_status.mem)
+		iounmap(ei_status.mem);
 	release_region(ioaddr + ES_SA_PROM, ES_IO_EXTENT);
 	return retval;
 }
diff -uprN -X linux-2.6.18-orig/Documentation/dontdiff linux-2.6.18-orig/drivers/net/fs_enet/mac-fcc.c linux-2.6.18/drivers/net/fs_enet/mac-fcc.c
--- linux-2.6.18-orig/drivers/net/fs_enet/mac-fcc.c	2006-09-21 10:15:36.000000000 +0530
+++ linux-2.6.18/drivers/net/fs_enet/mac-fcc.c	2006-09-22 18:46:46.000000000 +0530
@@ -129,8 +129,10 @@ static int do_pd_setup(struct fs_enet_pr
 
 	r = platform_get_resource_byname(pdev, IORESOURCE_MEM, "fcc_regs");
 	fep->fcc.fccp = (void *)ioremap(r->start, r->end - r->start + 1);
-	if (fep->fcc.fccp == NULL)
+	if (fep->fcc.fccp == NULL) {
+		iounmap(fep->fcc.ep);
 		return -EINVAL;
+	}
 
 	if (fep->fpi->fcc_regs_c) {
 
@@ -142,12 +144,20 @@ static int do_pd_setup(struct fs_enet_pr
 				r->end - r->start + 1);
 	}
 
-	if (fep->fcc.fcccp == NULL)
+	if (fep->fcc.fcccp == NULL) {
+		iounmap(fep->fcc.ep);
+		iounmap(fep->fcc.fccp);
 		return -EINVAL;
+	}
 
 	fep->fcc.mem = (void *)fep->fpi->mem_offset;
-	if (fep->fcc.mem == NULL)
+	if (fep->fcc.mem == NULL) {
+		iounmap(fep->fcc.ep);
+		iounmap(fep->fcc.fccp);
+		if (!fep->fpi->fcc_regs_c)
+			iounmap(fep->fcc.fcccp);
 		return -EINVAL;
+	}
 
 	return 0;
 }
@@ -205,7 +215,14 @@ static void free_bd(struct net_device *d
 
 static void cleanup_data(struct net_device *dev)
 {
-	/* nothing */
+	struct fs_enet_private *fep = netdev_priv(dev);
+
+	if (fep->fcc.ep)
+		iounmap(fep->fcc.ep);
+	if (fep->fcc.fccp)
+		iounmap(fep->fcc.fccp);
+	if (!fep->fpi->fcc_regs_c && fep->fcc.fcccp)
+		iounmap(fep->fcc.fcccp);
 }
 
 static void set_promiscuous_mode(struct net_device *dev)
diff -uprN -X linux-2.6.18-orig/Documentation/dontdiff linux-2.6.18-orig/drivers/net/fs_enet/mii-fec.c linux-2.6.18/drivers/net/fs_enet/mii-fec.c
--- linux-2.6.18-orig/drivers/net/fs_enet/mii-fec.c	2006-09-21 10:15:36.000000000 +0530
+++ linux-2.6.18/drivers/net/fs_enet/mii-fec.c	2006-09-22 12:42:12.000000000 +0530
@@ -212,9 +212,13 @@ bus_register_fail:
 static int fs_enet_fec_mdio_remove(struct device *dev)
 {
 	struct mii_bus *bus = dev_get_drvdata(dev);
+	struct fec_info *fec = (struct fec_info *) bus->priv;
 
 	mdiobus_unregister(bus);
 
+	if (fec && fec->fecp)
+		iounmap(fec->fecp);		
+
 	dev_set_drvdata(dev, NULL);
 	kfree(bus->priv);
 
diff -uprN -X linux-2.6.18-orig/Documentation/dontdiff linux-2.6.18-orig/drivers/net/ioc3-eth.c linux-2.6.18/drivers/net/ioc3-eth.c
--- linux-2.6.18-orig/drivers/net/ioc3-eth.c	2006-09-21 10:15:36.000000000 +0530
+++ linux-2.6.18/drivers/net/ioc3-eth.c	2006-09-22 16:27:34.000000000 +0530
@@ -1314,6 +1314,7 @@ static int ioc3_probe(struct pci_dev *pd
 	return 0;
 
 out_stop:
+	iounmap(ioc3);
 	ioc3_stop(ip);
 	ioc3_free_rings(ip);
 out_res:
diff -uprN -X linux-2.6.18-orig/Documentation/dontdiff linux-2.6.18-orig/drivers/net/myri_sbus.c linux-2.6.18/drivers/net/myri_sbus.c
--- linux-2.6.18-orig/drivers/net/myri_sbus.c	2006-09-21 10:15:36.000000000 +0530
+++ linux-2.6.18/drivers/net/myri_sbus.c	2006-09-22 17:59:16.000000000 +0530
@@ -1107,6 +1107,13 @@ static int __init myri_ether_init(struct
 err_free_irq:
 	free_irq(dev->irq, dev);
 err:
+	if (mp->eeprom.cpuvers < CPUVERS_4_0) {
+		sbus_iounmap(mp->regs, mp->reg_size);
+	} else {
+		sbus_iounmap(mp->cregs, PAGE_SIZE);
+		sbus_iounmap(mp->lregs, (256 * 1024));
+		sbus_iounmap(mp->lanai, (512 * 1024));
+	}
 	/* This will also free the co-allocated 'dev->priv' */
 	free_netdev(dev);
 	return -ENODEV;
diff -uprN -X linux-2.6.18-orig/Documentation/dontdiff linux-2.6.18-orig/drivers/net/pcmcia/ibmtr_cs.c linux-2.6.18/drivers/net/pcmcia/ibmtr_cs.c
--- linux-2.6.18-orig/drivers/net/pcmcia/ibmtr_cs.c	2006-08-24 02:46:33.000000000 +0530
+++ linux-2.6.18/drivers/net/pcmcia/ibmtr_cs.c	2006-09-22 18:06:31.000000000 +0530
@@ -320,6 +320,7 @@ static int ibmtr_config(struct pcmcia_de
 cs_failed:
     cs_error(link, last_fn, last_ret);
 failed:
+    iounmap(ti->sram_virt);
     ibmtr_release(link);
     return -ENODEV;
 } /* ibmtr_config */
diff -uprN -X linux-2.6.18-orig/Documentation/dontdiff linux-2.6.18-orig/drivers/net/smc-ultra.c linux-2.6.18/drivers/net/smc-ultra.c
--- linux-2.6.18-orig/drivers/net/smc-ultra.c	2006-09-21 10:15:36.000000000 +0530
+++ linux-2.6.18/drivers/net/smc-ultra.c	2006-09-22 16:48:53.000000000 +0530
@@ -313,6 +313,8 @@ static int __init ultra_probe1(struct ne
 		goto out;
 	return 0;
 out:
+	if (ei_status.mem)
+		iounmap(ei_status.mem);
 	release_region(ioaddr, ULTRA_IO_EXTENT);
 	return retval;
 }
diff -uprN -X linux-2.6.18-orig/Documentation/dontdiff linux-2.6.18-orig/drivers/net/tokenring/ibmtr.c linux-2.6.18/drivers/net/tokenring/ibmtr.c
--- linux-2.6.18-orig/drivers/net/tokenring/ibmtr.c	2006-09-21 10:15:37.000000000 +0530
+++ linux-2.6.18/drivers/net/tokenring/ibmtr.c	2006-09-22 17:10:17.000000000 +0530
@@ -263,14 +263,20 @@ static void __devinit find_turbo_adapter
 		chanid=(CHANNEL_ID + ram_mapped);
 		tchanid=pcchannelid;
 		ctemp=readb(chanid) & 0x0f;
-		if (ctemp != *tchanid) continue;
+		if (ctemp != *tchanid) {
+			iounmap(ram_mapped);
+			continue;
+		}
 		for (i=2,j=1; i<=46; i=i+2,j++) {
 			if ((readb(chanid+i) & 0x0f) != tchanid[j]){
 				found_turbo=0;
 				break;
 			}
 		}
-		if (!found_turbo) continue;
+		if (!found_turbo) {
+			iounmap(ram_mapped);
+			continue;
+		}
 
 		writeb(0x90, ram_mapped+0x1E01);
 		for(i=2; i<0x0f; i++) {
@@ -295,6 +301,7 @@ static void __devinit find_turbo_adapter
 			for(jif=jiffies+TR_RST_TIME;time_before_eq(jiffies,jif););
 			outb(0, turbo_io[index] + ADAPTRESETREL);
 			index++;
+			iounmap(ram_mapped);
 			continue;
 		}
 #if IBMTR_DEBUG_MESSAGES 
diff -uprN -X linux-2.6.18-orig/Documentation/dontdiff linux-2.6.18-orig/drivers/net/wan/farsync.c linux-2.6.18/drivers/net/wan/farsync.c
--- linux-2.6.18-orig/drivers/net/wan/farsync.c	2006-09-21 10:15:37.000000000 +0530
+++ linux-2.6.18/drivers/net/wan/farsync.c	2006-09-22 17:16:06.000000000 +0530
@@ -2513,6 +2513,7 @@ fst_add_one(struct pci_dev *pdev, const 
 		printk_err("Control memory remap failed\n");
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
+		iounmap(card->mem);
 		kfree(card);
 		return -ENODEV;
 	}
diff -uprN -X linux-2.6.18-orig/Documentation/dontdiff linux-2.6.18-orig/drivers/net/wd.c linux-2.6.18/drivers/net/wd.c
--- linux-2.6.18-orig/drivers/net/wd.c	2006-09-21 10:15:37.000000000 +0530
+++ linux-2.6.18/drivers/net/wd.c	2006-09-22 17:19:45.000000000 +0530
@@ -346,8 +346,10 @@ static int __init wd_probe1(struct net_d
 #endif
 
 	err = register_netdev(dev);
-	if (err)
+	if (err) {
+		iounmap(ei_status.mem);
 		free_irq(dev->irq, dev);
+	}
 	return err;
 }
 
diff -uprN -X linux-2.6.18-orig/Documentation/dontdiff linux-2.6.18-orig/drivers/net/wireless/ipw2100.c linux-2.6.18/drivers/net/wireless/ipw2100.c
--- linux-2.6.18-orig/drivers/net/wireless/ipw2100.c	2006-09-21 10:15:37.000000000 +0530
+++ linux-2.6.18/drivers/net/wireless/ipw2100.c	2006-09-22 18:41:20.000000000 +0530
@@ -6174,6 +6174,7 @@ static int ipw2100_pci_init_one(struct p
 	if (err) {
 		printk(KERN_WARNING DRV_NAME
 		       "Error calling pci_enable_device.\n");
+		iounmap(base_addr);
 		return err;
 	}
 
@@ -6187,6 +6188,7 @@ static int ipw2100_pci_init_one(struct p
 		printk(KERN_WARNING DRV_NAME
 		       "Error calling pci_set_dma_mask.\n");
 		pci_disable_device(pci_dev);
+		iounmap(base_addr);
 		return err;
 	}
 
@@ -6195,6 +6197,7 @@ static int ipw2100_pci_init_one(struct p
 		printk(KERN_WARNING DRV_NAME
 		       "Error calling pci_request_regions.\n");
 		pci_disable_device(pci_dev);
+		iounmap(base_addr);
 		return err;
 	}
 
diff -uprN -X linux-2.6.18-orig/Documentation/dontdiff linux-2.6.18-orig/drivers/net/wireless/prism54/islpci_dev.c linux-2.6.18/drivers/net/wireless/prism54/islpci_dev.c
--- linux-2.6.18-orig/drivers/net/wireless/prism54/islpci_dev.c	2006-08-24 02:46:33.000000000 +0530
+++ linux-2.6.18/drivers/net/wireless/prism54/islpci_dev.c	2006-09-22 17:25:27.000000000 +0530
@@ -656,6 +656,8 @@ islpci_alloc_memory(islpci_private *priv
 		/* error allocating the block of PCI memory */
 		printk(KERN_ERR "%s: could not allocate DMA memory, aborting!",
 		       "prism54");
+		iounmap(priv->device_base);
+		priv->device_base = NULL;
 		return -1;
 	}


