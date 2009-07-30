From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Subject: [PATCH] pcnet32: remove superfluous NULL pointer check in pcnet32_probe1()
Date: Thu, 30 Jul 2009 23:19:17 +0200
Message-ID: <200907302319.18150.bzolnier@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dan Carpenter <error27@gmail.com>, corbet@lwn.net,
	eteo@redhat.com, Julia Lawall <julia@diku.dk>
To: Don Fry <pcnet32@verizon.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752621AbZG3VWg@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Subject: [PATCH] pcnet32: remove superfluous NULL pointer check in pcnet32_probe1()

Move the debug printk() into the proper place and remove superfluous
NULL pointer check in pcnet32_probe1().

This takes care of the following entry from Dan's list:

drivers/net/pcnet32.c +1889 pcnet32_probe1(298) warning: variable derefenced before check 'pdev'

Reported-by: Dan Carpenter <error27@gmail.com>
Cc: corbet@lwn.net
Cc: eteo@redhat.com
Cc: Julia Lawall <julia@diku.dk>
Signed-off-by: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
---
 drivers/net/pcnet32.c |   18 +++++++-----------
 1 file changed, 7 insertions(+), 11 deletions(-)

Index: b/drivers/net/pcnet32.c
===================================================================
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -1611,8 +1611,11 @@ pcnet32_probe1(unsigned long ioaddr, int
 		if (pcnet32_dwio_read_csr(ioaddr, 0) == 4
 		    && pcnet32_dwio_check(ioaddr)) {
 			a = &pcnet32_dwio;
-		} else
+		} else {
+			if (pcnet32_debug & NETIF_MSG_PROBE)
+				printk(KERN_ERR PFX "No access methods\n");
 			goto err_release_region;
+		}
 	}
 
 	chip_version =
@@ -1853,12 +1856,6 @@ pcnet32_probe1(unsigned long ioaddr, int
 	    ((cards_found >= MAX_UNITS) || full_duplex[cards_found]))
 		lp->options |= PCNET32_PORT_FD;
 
-	if (!a) {
-		if (pcnet32_debug & NETIF_MSG_PROBE)
-			printk(KERN_ERR PFX "No access methods\n");
-		ret = -ENODEV;
-		goto err_free_consistent;
-	}
 	lp->a = *a;
 
 	/* prior to register_netdev, dev->name is not yet correct */
@@ -1974,14 +1971,13 @@ pcnet32_probe1(unsigned long ioaddr, int
 
 	return 0;
 
-      err_free_ring:
+err_free_ring:
 	pcnet32_free_ring(dev);
-      err_free_consistent:
 	pci_free_consistent(lp->pci_dev, sizeof(*lp->init_block),
 			    lp->init_block, lp->init_dma_addr);
-      err_free_netdev:
+err_free_netdev:
 	free_netdev(dev);
-      err_release_region:
+err_release_region:
 	release_region(ioaddr, PCNET32_TOTAL_SIZE);
 	return ret;
 }
