From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 6/7][ATM]: [drivers] ioremap balanced with iounmap
Date: Mon, 16 Jul 2007 12:31:43 -0400
Message-ID: <200707161631.l6GGVhAt009387@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:47466 "EHLO
	ginger.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760185AbXGPREq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 13:04:46 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ATM]: [drivers] ioremap balanced with iounmap

Signed-off-by: Amol Lad <amol@verismonetworks.com>
Signed-off-by: chas williams <chas@cmf.nrl.navy.mil>

---
commit 15fa4d7e8fda822d42bc202fe390b52309ee9d86
tree bb741ef4aba074d449f6199522f746a64c3ab244
parent 9b3515b17a74eff9aad7409dd64888cf0cd03d4d
author Amol Lad <amol@verismonetworks.com> Thu, 12 Jul 2007 14:47:50 -0400
committer chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Thu, 12 Jul 2007 14:47:50 -0400

 drivers/atm/eni.c        |   19 +++++++++++++++----
 drivers/atm/firestream.c |   14 +++++++++-----
 2 files changed, 24 insertions(+), 9 deletions(-)

diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
index 0d3a38b..0789528 100644
--- a/drivers/atm/eni.c
+++ b/drivers/atm/eni.c
@@ -1745,7 +1745,8 @@ static int __devinit eni_do_init(struct atm_dev *dev)
 			printk(KERN_ERR KERN_ERR DEV_LABEL "(itf %d): bad "
 			    "magic - expected 0x%x, got 0x%x\n",dev->number,
 			    ENI155_MAGIC,(unsigned) readl(&eprom->magic));
-			return -EINVAL;
+			error = -EINVAL;
+			goto unmap;
 		}
 	}
 	eni_dev->phy = base+PHY_BASE;
@@ -1772,17 +1773,27 @@ static int __devinit eni_do_init(struct atm_dev *dev)
 		printk(")\n");
 		printk(KERN_ERR DEV_LABEL "(itf %d): ERROR - wrong id 0x%x\n",
 		    dev->number,(unsigned) eni_in(MID_RES_ID_MCON));
-		return -EINVAL;
+		error = -EINVAL;
+		goto unmap;
 	}
 	error = eni_dev->asic ? get_esi_asic(dev) : get_esi_fpga(dev,base);
-	if (error) return error;
+	if (error)
+		goto unmap;
 	for (i = 0; i < ESI_LEN; i++)
 		printk("%s%02X",i ? "-" : "",dev->esi[i]);
 	printk(")\n");
 	printk(KERN_NOTICE DEV_LABEL "(itf %d): %s,%s\n",dev->number,
 	    eni_in(MID_RES_ID_MCON) & 0x200 ? "ASIC" : "FPGA",
 	    media_name[eni_in(MID_RES_ID_MCON) & DAUGTHER_ID]);
-	return suni_init(dev);
+
+	error = suni_init(dev);
+	if (error)
+		goto unmap;
+out:
+	return error;
+unmap:
+	iounmap(base);
+	goto out;
 }
 
 
diff --git a/drivers/atm/firestream.c b/drivers/atm/firestream.c
index 38b688f..737cea4 100644
--- a/drivers/atm/firestream.c
+++ b/drivers/atm/firestream.c
@@ -1710,7 +1710,7 @@ static int __devinit fs_init (struct fs_dev *dev)
 		/* This bit is documented as "RESERVED" */
 		if (isr & ISR_INIT_ERR) {
 			printk (KERN_ERR "Error initializing the FS... \n");
-			return 1;
+			goto unmap;
 		}
 		if (isr & ISR_INIT) {
 			fs_dprintk (FS_DEBUG_INIT, "Ha! Initialized OK!\n");
@@ -1723,7 +1723,7 @@ static int __devinit fs_init (struct fs_dev *dev)
 
 	if (!to) {
 		printk (KERN_ERR "timeout initializing the FS... \n");
-		return 1;
+		goto unmap;
 	}
 
 	/* XXX fix for fs155 */
@@ -1803,7 +1803,7 @@ static int __devinit fs_init (struct fs_dev *dev)
 	if (!dev->atm_vccs) {
 		printk (KERN_WARNING "Couldn't allocate memory for VCC buffers. Woops!\n");
 		/* XXX Clean up..... */
-		return 1;
+		goto unmap;
 	}
 
 	dev->tx_inuse = kzalloc (dev->nchannels / 8 /* bits/byte */ , GFP_KERNEL);
@@ -1813,7 +1813,7 @@ static int __devinit fs_init (struct fs_dev *dev)
 	if (!dev->tx_inuse) {
 		printk (KERN_WARNING "Couldn't allocate memory for tx_inuse bits!\n");
 		/* XXX Clean up..... */
-		return 1;
+		goto unmap;
 	}
 	/* -- RAS1 : FS155 and 50 differ. Default (0) should be OK for both */
 	/* -- RAS2 : FS50 only: Default is OK. */
@@ -1840,7 +1840,7 @@ static int __devinit fs_init (struct fs_dev *dev)
 	if (request_irq (dev->irq, fs_irq, IRQF_SHARED, "firestream", dev)) {
 		printk (KERN_WARNING "couldn't get irq %d for firestream.\n", pci_dev->irq);
 		/* XXX undo all previous stuff... */
-		return 1;
+		goto unmap;
 	}
 	fs_dprintk (FS_DEBUG_INIT, "Grabbed irq %d for dev at %p.\n", dev->irq, dev);
   
@@ -1890,6 +1890,9 @@ static int __devinit fs_init (struct fs_dev *dev)
   
 	func_exit ();
 	return 0;
+unmap:
+	iounmap(dev->base);
+	return 1;
 }
 
 static int __devinit firestream_init_one (struct pci_dev *pci_dev,
@@ -2012,6 +2015,7 @@ static void __devexit firestream_remove_one (struct pci_dev *pdev)
 		for (i=0;i < FS_NR_RX_QUEUES;i++)
 			free_queue (dev, &dev->rx_rq[i]);
 
+		iounmap(dev->base);
 		fs_dprintk (FS_DEBUG_ALLOC, "Free fs-dev: %p\n", dev);
 		nxtdev = dev->next;
 		kfree (dev);
