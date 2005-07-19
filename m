From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch linux-2.6.13-rc2-gitXX 1/1] zatm: mailbox converted to pci_alloc_consistent()
Date: Wed, 20 Jul 2005 00:36:55 +0200
Message-ID: <20050719223655.GA27724@electric-eye.fr.zoreil.com>
References: <200507192044.j6JKirFb027183@ginger.cmf.nrl.navy.mil> <20050719223134.GA24535@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: chas williams <chas@cmf.nrl.navy.mil>
Content-Disposition: inline
In-Reply-To: <20050719223134.GA24535@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

mailbox converted to pci_alloc_consistent()

- request_region() is not needed: zatm_init_one() issues
  pci_request_regions();
- the warning related to kfree(zatm_dev->mbx_start) disappears;

Compiled with i386 and sparc64 as target.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/atm/zatm.c~drivers-atm-zatm-mbx drivers/atm/zatm.c
--- linux-2.6.13-rc2-gitXX/drivers/atm/zatm.c~drivers-atm-zatm-mbx	2005-07-19 23:40:48.696490366 +0200
+++ linux-2.6.13-rc2-gitXX-fr/drivers/atm/zatm.c	2005-07-20 00:27:48.263131297 +0200
@@ -16,9 +16,9 @@
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 #include <linux/delay.h>
-#include <linux/ioport.h> /* for request_region */
 #include <linux/uio.h>
 #include <linux/init.h>
+#include <linux/dma-mapping.h>
 #include <linux/atm_zatm.h>
 #include <linux/capability.h>
 #include <linux/bitops.h>
@@ -1260,22 +1260,22 @@ static int __init zatm_init(struct atm_d
 
 static int __init zatm_start(struct atm_dev *dev)
 {
-	struct zatm_dev *zatm_dev;
+	struct zatm_dev *zatm_dev = ZATM_DEV(dev);
+	struct pci_dev *pdev = zatm_dev->pci_dev;
 	unsigned long curr;
 	int pools,vccs,rx;
-	int error,i,ld;
+	int error, i, ld;
 
 	DPRINTK("zatm_start\n");
-	zatm_dev = ZATM_DEV(dev);
 	zatm_dev->rx_map = zatm_dev->tx_map = NULL;
-	for (i = 0; i < NR_MBX; i++)
-		zatm_dev->mbx_start[i] = 0;
-	if (request_irq(zatm_dev->irq,&zatm_int,SA_SHIRQ,DEV_LABEL,dev)) {
-		printk(KERN_ERR DEV_LABEL "(itf %d): IRQ%d is already in use\n",
-		    dev->number,zatm_dev->irq);
-		return -EAGAIN;
+ 	for (i = 0; i < NR_MBX; i++)
+ 		zatm_dev->mbx_start[i] = 0;
+ 	error = request_irq(zatm_dev->irq, zatm_int, SA_SHIRQ, DEV_LABEL, dev);
+	if (error < 0) {
+ 		printk(KERN_ERR DEV_LABEL "(itf %d): IRQ%d is already in use\n",
+ 		    dev->number,zatm_dev->irq);
+		goto done;
 	}
-	request_region(zatm_dev->base,uPD98401_PORTS,DEV_LABEL);
 	/* define memory regions */
 	pools = NR_POOLS;
 	if (NR_SHAPERS*SHAPER_SIZE > pools*POOL_SIZE)
@@ -1302,51 +1302,66 @@ static int __init zatm_start(struct atm_
 	    "%ld VCs\n",dev->number,NR_SHAPERS,pools,rx,
 	    (zatm_dev->mem-curr*4)/VC_SIZE);
 	/* create mailboxes */
-	for (i = 0; i < NR_MBX; i++)
-		if (mbx_entries[i]) {
-			unsigned long here;
-
-			here = (unsigned long) kmalloc(2*MBX_SIZE(i),
-			    GFP_KERNEL);
-			if (!here) {
-				error = -ENOMEM;
-				goto out;
-			}
-			if ((here^(here+MBX_SIZE(i))) & ~0xffffUL)/* paranoia */
-				here = (here & ~0xffffUL)+0x10000;
-			zatm_dev->mbx_start[i] = here;
-			if ((here^virt_to_bus((void *) here)) & 0xffff) {
-				printk(KERN_ERR DEV_LABEL "(itf %d): system "
-				    "bus incompatible with driver\n",
-				    dev->number);
-				error = -ENODEV;
-				goto out;
-			}
-			DPRINTK("mbx@0x%08lx-0x%08lx\n",here,here+MBX_SIZE(i));
-			zatm_dev->mbx_end[i] = (here+MBX_SIZE(i)) & 0xffff;
-			zout(virt_to_bus((void *) here) >> 16,MSH(i));
-			zout(virt_to_bus((void *) here),MSL(i));
-			zout((here+MBX_SIZE(i)) & 0xffff,MBA(i));
-			zout(here & 0xffff,MTA(i));
-			zout(here & 0xffff,MWA(i));
-		}
+	for (i = 0; i < NR_MBX; i++) {
+		void *mbx;
+		dma_addr_t mbx_dma;
+
+		if (!mbx_entries[i])
+			continue;
+		mbx = pci_alloc_consistent(pdev, 2*MBX_SIZE(i), &mbx_dma);
+		if (!mbx) {
+			error = -ENOMEM;
+			goto out;
+		}
+		/*
+		 * Alignment provided by pci_alloc_consistent() isn't enough
+		 * for this device.
+		 */
+		if (((unsigned long)mbx ^ mbx_dma) & 0xffff) {
+			printk(KERN_ERR DEV_LABEL "(itf %d): system "
+			       "bus incompatible with driver\n", dev->number);
+			pci_free_consistent(pdev, 2*MBX_SIZE(i), mbx, mbx_dma);
+			error = -ENODEV;
+			goto out;
+		}
+		DPRINTK("mbx@0x%08lx-0x%08lx\n", mbx, mbx + MBX_SIZE(i));
+		zatm_dev->mbx_start[i] = (unsigned long)mbx;
+		zatm_dev->mbx_dma[i] = mbx_dma;
+		zatm_dev->mbx_end[i] = (zatm_dev->mbx_start[i] + MBX_SIZE(i)) &
+					0xffff;
+		zout(mbx_dma >> 16, MSH(i));
+		zout(mbx_dma, MSL(i));
+		zout(zatm_dev->mbx_end[i], MBA(i));
+		zout((unsigned long)mbx & 0xffff, MTA(i));
+		zout((unsigned long)mbx & 0xffff, MWA(i));
+	}
 	error = start_tx(dev);
-	if (error) goto out;
+	if (error)
+		goto out;
 	error = start_rx(dev);
-	if (error) goto out;
+	if (error)
+		goto out_tx;
 	error = dev->phy->start(dev);
-	if (error) goto out;
+	if (error)
+		goto out_rx;
 	zout(0xffffffff,IMR); /* enable interrupts */
 	/* enable TX & RX */
 	zout(zin(GMR) | uPD98401_GMR_SE | uPD98401_GMR_RE,GMR);
-	return 0;
-    out:
-	for (i = 0; i < NR_MBX; i++)
-		kfree(zatm_dev->mbx_start[i]);
+done:
+	return error;
+
+out_rx:
 	kfree(zatm_dev->rx_map);
+out_tx:
 	kfree(zatm_dev->tx_map);
+out:
+	while (i-- > 0) {
+		pci_free_consistent(pdev, 2*MBX_SIZE(i), 
+				    (void *)zatm_dev->mbx_start[i],
+				    zatm_dev->mbx_dma[i]);
+	}
 	free_irq(zatm_dev->irq, dev);
-	return error;
+	goto done;
 }
 
 
diff -puN drivers/atm/zatm.h~drivers-atm-zatm-mbx drivers/atm/zatm.h
--- linux-2.6.13-rc2-gitXX/drivers/atm/zatm.h~drivers-atm-zatm-mbx	2005-07-19 23:40:48.711487946 +0200
+++ linux-2.6.13-rc2-gitXX-fr/drivers/atm/zatm.h	2005-07-19 23:40:48.764479397 +0200
@@ -73,6 +73,7 @@ struct zatm_dev {
 	int chans;			/* map size, must be 2^n */
 	/*-------------------------------- mailboxes */
 	unsigned long mbx_start[NR_MBX];/* start addresses */
+	dma_addr_t mbx_dma[NR_MBX];
 	u16 mbx_end[NR_MBX];		/* end offset (in bytes) */
 	/*-------------------------------- other pointers */
 	u32 pool_base;			/* Free buffer pool dsc (word addr) */

_
