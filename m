From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Subject: [PATCH] wan: lmc: Switch to using managed resources
Date: Sat, 27 Feb 2016 22:34:16 +0530
Message-ID: <20160227170416.GA1339@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36485 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756600AbcB0REV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2016 12:04:21 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use managed resource functions devm_kzalloc and pcim_enable_device
to simplify error handling. Subsequently, remove unnecessary
kfree, pci_disable_device and pci_release_regions.

To be compatible with the change, various gotos are replaced with
direct returns and unneeded labels are dropped.

Also, `sc` was only being freed in the probe function and not the
remove function before the change. By using devm_kzalloc this patch
also fixes this memory leak.

Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
---
I was not able to find anywhere that `sc` might be freed. However, 
if a free has been overlooked, there will be a double free, due to 
the free implicitly performed by devm_kzalloc.

 drivers/net/wan/lmc/lmc_main.c | 27 +++++++--------------------
 1 file changed, 7 insertions(+), 20 deletions(-)

diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index 317bc79..bb33b24 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -826,7 +826,7 @@ static int lmc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* lmc_trace(dev, "lmc_init_one in"); */
 
-	err = pci_enable_device(pdev);
+	err = pcim_enable_device(pdev);
 	if (err) {
 		printk(KERN_ERR "lmc: pci enable failed: %d\n", err);
 		return err;
@@ -835,23 +835,20 @@ static int lmc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	err = pci_request_regions(pdev, "lmc");
 	if (err) {
 		printk(KERN_ERR "lmc: pci_request_region failed\n");
-		goto err_req_io;
+		return err;
 	}
 
 	/*
 	 * Allocate our own device structure
 	 */
-	sc = kzalloc(sizeof(lmc_softc_t), GFP_KERNEL);
-	if (!sc) {
-		err = -ENOMEM;
-		goto err_kzalloc;
-	}
+	sc = devm_kzalloc(&pdev->dev, sizeof(lmc_softc_t), GFP_KERNEL);
+	if (!sc)
+		return -ENOMEM;
 
 	dev = alloc_hdlcdev(sc);
 	if (!dev) {
 		printk(KERN_ERR "lmc:alloc_netdev for device failed\n");
-		err = -ENOMEM;
-		goto err_hdlcdev;
+		return -ENOMEM;
 	}
 
 
@@ -888,7 +885,7 @@ static int lmc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err) {
 		printk(KERN_ERR "%s: register_netdev failed.\n", dev->name);
 		free_netdev(dev);
-		goto err_hdlcdev;
+		return err;
 	}
 
     sc->lmc_cardtype = LMC_CARDTYPE_UNKNOWN;
@@ -971,14 +968,6 @@ static int lmc_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
     lmc_trace(dev, "lmc_init_one out");
     return 0;
-
-err_hdlcdev:
-	kfree(sc);
-err_kzalloc:
-	pci_release_regions(pdev);
-err_req_io:
-	pci_disable_device(pdev);
-	return err;
 }
 
 /*
@@ -992,8 +981,6 @@ static void lmc_remove_one(struct pci_dev *pdev)
 		printk(KERN_DEBUG "%s: removing...\n", dev->name);
 		unregister_hdlc_device(dev);
 		free_netdev(dev);
-		pci_release_regions(pdev);
-		pci_disable_device(pdev);
 	}
 }
 
-- 
1.9.1
