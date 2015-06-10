From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next 19/19] bna: use netdev_* and dev_* instead of printk and pr_*
Date: Wed, 10 Jun 2015 18:43:25 +0200
Message-ID: <1433954605-22813-20-git-send-email-ivecera@redhat.com>
References: <1433954605-22813-1-git-send-email-ivecera@redhat.com>
Cc: rasesh.mody@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57827 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965374AbbFJQnU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2015 12:43:20 -0400
In-Reply-To: <1433954605-22813-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c         | 46 +++++++++----------------
 drivers/net/ethernet/brocade/bna/bnad_debugfs.c | 34 ++++++++----------
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c |  9 ++---
 drivers/net/ethernet/brocade/bna/cna_fwimg.c    |  2 +-
 4 files changed, 36 insertions(+), 55 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index ddda6f1..d9e0f81 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -945,8 +945,7 @@ bnad_cb_ethport_link_status(struct bnad *bnad,
 	if (link_up) {
 		if (!netif_carrier_ok(bnad->netdev)) {
 			uint tx_id, tcb_id;
-			printk(KERN_WARNING "bna: %s link up\n",
-				bnad->netdev->name);
+			netdev_info(bnad->netdev, "link up\n");
 			netif_carrier_on(bnad->netdev);
 			BNAD_UPDATE_CTR(bnad, link_toggle);
 			for (tx_id = 0; tx_id < bnad->num_tx; tx_id++) {
@@ -965,10 +964,6 @@ bnad_cb_ethport_link_status(struct bnad *bnad,
 						/*
 						 * Force an immediate
 						 * Transmit Schedule */
-						printk(KERN_INFO "bna: %s %d "
-						      "TXQ_STARTED\n",
-						       bnad->netdev->name,
-						       txq_id);
 						netif_wake_subqueue(
 								bnad->netdev,
 								txq_id);
@@ -986,8 +981,7 @@ bnad_cb_ethport_link_status(struct bnad *bnad,
 		}
 	} else {
 		if (netif_carrier_ok(bnad->netdev)) {
-			printk(KERN_WARNING "bna: %s link down\n",
-				bnad->netdev->name);
+			netdev_info(bnad->netdev, "link down\n");
 			netif_carrier_off(bnad->netdev);
 			BNAD_UPDATE_CTR(bnad, link_toggle);
 		}
@@ -1057,8 +1051,6 @@ bnad_cb_tx_stall(struct bnad *bnad, struct bna_tx *tx)
 		txq_id = tcb->id;
 		clear_bit(BNAD_TXQ_TX_STARTED, &tcb->flags);
 		netif_stop_subqueue(bnad->netdev, txq_id);
-		printk(KERN_INFO "bna: %s %d TXQ_STOPPED\n",
-			bnad->netdev->name, txq_id);
 	}
 }
 
@@ -1081,8 +1073,6 @@ bnad_cb_tx_resume(struct bnad *bnad, struct bna_tx *tx)
 		BUG_ON(*(tcb->hw_consumer_index) != 0);
 
 		if (netif_carrier_ok(bnad->netdev)) {
-			printk(KERN_INFO "bna: %s %d TXQ_STARTED\n",
-				bnad->netdev->name, txq_id);
 			netif_wake_subqueue(bnad->netdev, txq_id);
 			BNAD_UPDATE_CTR(bnad, netif_queue_wakeup);
 		}
@@ -2135,7 +2125,7 @@ bnad_reinit_rx(struct bnad *bnad)
 		current_err = bnad_setup_rx(bnad, rx_id);
 		if (current_err && !err) {
 			err = current_err;
-			pr_err("RXQ:%u setup failed\n", rx_id);
+			netdev_err(netdev, "RXQ:%u setup failed\n", rx_id);
 		}
 	}
 
@@ -2671,8 +2661,9 @@ bnad_enable_msix(struct bnad *bnad)
 	if (ret < 0) {
 		goto intx_mode;
 	} else if (ret < bnad->msix_num) {
-		pr_warn("BNA: %d MSI-X vectors allocated < %d requested\n",
-			ret, bnad->msix_num);
+		dev_warn(&bnad->pcidev->dev,
+			 "%d MSI-X vectors allocated < %d requested\n",
+			 ret, bnad->msix_num);
 
 		spin_lock_irqsave(&bnad->bna_lock, flags);
 		/* ret = #of vectors that we got */
@@ -2694,7 +2685,8 @@ bnad_enable_msix(struct bnad *bnad)
 	return;
 
 intx_mode:
-	pr_warn("BNA: MSI-X enable failed - operating in INTx mode\n");
+	dev_warn(&bnad->pcidev->dev,
+		 "MSI-X enable failed - operating in INTx mode\n");
 
 	kfree(bnad->msix_table);
 	bnad->msix_table = NULL;
@@ -3482,8 +3474,8 @@ bnad_init(struct bnad *bnad,
 		dev_err(&pdev->dev, "ioremap for bar0 failed\n");
 		return -ENOMEM;
 	}
-	pr_info("bar0 mapped to %p, len %llu\n", bnad->bar0,
-	       (unsigned long long) bnad->mmio_len);
+	dev_info(&pdev->dev, "bar0 mapped to %p, len %llu\n", bnad->bar0,
+		 (unsigned long long) bnad->mmio_len);
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	if (!bnad_msix_disable)
@@ -3604,13 +3596,10 @@ bnad_pci_probe(struct pci_dev *pdev,
 	struct bfa_pcidev pcidev_info;
 	unsigned long flags;
 
-	pr_info("bnad_pci_probe : (0x%p, 0x%p) PCI Func : (%d)\n",
-	       pdev, pcidev_id, PCI_FUNC(pdev->devfn));
-
 	mutex_lock(&bnad_fwimg_mutex);
 	if (!cna_get_firmware_buf(pdev)) {
 		mutex_unlock(&bnad_fwimg_mutex);
-		pr_warn("Failed to load Firmware Image!\n");
+		dev_err(&pdev->dev, "failed to load firmware image!\n");
 		return -ENODEV;
 	}
 	mutex_unlock(&bnad_fwimg_mutex);
@@ -3703,8 +3692,7 @@ bnad_pci_probe(struct pci_dev *pdev,
 	 */
 	err = bnad_ioceth_enable(bnad);
 	if (err) {
-		pr_err("BNA: Initialization failed err=%d\n",
-		       err);
+		dev_err(&pdev->dev, "initialization failed err=%d\n", err);
 		goto probe_success;
 	}
 
@@ -3746,7 +3734,7 @@ bnad_pci_probe(struct pci_dev *pdev,
 	/* Finally, reguister with net_device layer */
 	err = register_netdev(netdev);
 	if (err) {
-		pr_err("BNA : Registering with netdev failed\n");
+		dev_err(&pdev->dev, "registering net device failed\n");
 		goto probe_uninit;
 	}
 	set_bit(BNAD_RF_NETDEV_REGISTERED, &bnad->run_flags);
@@ -3798,7 +3786,6 @@ bnad_pci_remove(struct pci_dev *pdev)
 	if (!netdev)
 		return;
 
-	pr_info("%s bnad_pci_remove\n", netdev->name);
 	bnad = netdev_priv(netdev);
 	bna = &bnad->bna;
 
@@ -3859,15 +3846,14 @@ bnad_module_init(void)
 {
 	int err;
 
-	pr_info("QLogic BR-series 10G Ethernet driver - version: %s\n",
-			BNAD_VERSION);
+	pr_info("bna: QLogic BR-series 10G Ethernet driver - version: %s\n",
+		BNAD_VERSION);
 
 	bfa_nw_ioc_auto_recover(bnad_ioc_auto_recover);
 
 	err = pci_register_driver(&bnad_pci_driver);
 	if (err < 0) {
-		pr_err("bna : PCI registration failed in module init "
-		       "(%d)\n", err);
+		pr_err("bna: PCI driver registration failed err=%d\n", err);
 		return err;
 	}
 
diff --git a/drivers/net/ethernet/brocade/bna/bnad_debugfs.c b/drivers/net/ethernet/brocade/bna/bnad_debugfs.c
index ad7af5c..c0fd737 100644
--- a/drivers/net/ethernet/brocade/bna/bnad_debugfs.c
+++ b/drivers/net/ethernet/brocade/bna/bnad_debugfs.c
@@ -76,8 +76,7 @@ bnad_debugfs_open_fwtrc(struct inode *inode, struct file *file)
 		fw_debug->debug_buffer = NULL;
 		kfree(fw_debug);
 		fw_debug = NULL;
-		pr_warn("bnad %s: Failed to collect fwtrc\n",
-			pci_name(bnad->pcidev));
+		netdev_warn(bnad->netdev, "failed to collect fwtrc\n");
 		return -ENOMEM;
 	}
 
@@ -117,8 +116,7 @@ bnad_debugfs_open_fwsave(struct inode *inode, struct file *file)
 		fw_debug->debug_buffer = NULL;
 		kfree(fw_debug);
 		fw_debug = NULL;
-		pr_warn("bna %s: Failed to collect fwsave\n",
-			pci_name(bnad->pcidev));
+		netdev_warn(bnad->netdev, "failed to collect fwsave\n");
 		return -ENOMEM;
 	}
 
@@ -217,8 +215,7 @@ bnad_debugfs_open_drvinfo(struct inode *inode, struct file *file)
 		drv_info->debug_buffer = NULL;
 		kfree(drv_info);
 		drv_info = NULL;
-		pr_warn("bna %s: Failed to collect drvinfo\n",
-			pci_name(bnad->pcidev));
+		netdev_warn(bnad->netdev, "failed to collect drvinfo\n");
 		return -ENOMEM;
 	}
 
@@ -328,8 +325,7 @@ bnad_debugfs_write_regrd(struct file *file, const char __user *buf,
 
 	rc = sscanf(kern_buf, "%x:%x", &addr, &len);
 	if (rc < 2) {
-		pr_warn("bna %s: Failed to read user buffer\n",
-			pci_name(bnad->pcidev));
+		netdev_warn(bnad->netdev, "failed to read user buffer\n");
 		kfree(kern_buf);
 		return -EINVAL;
 	}
@@ -349,8 +345,7 @@ bnad_debugfs_write_regrd(struct file *file, const char __user *buf,
 	/* offset and len sanity check */
 	rc = bna_reg_offset_check(ioc, addr, len);
 	if (rc) {
-		pr_warn("bna %s: Failed reg offset check\n",
-			pci_name(bnad->pcidev));
+		netdev_warn(bnad->netdev, "failed reg offset check\n");
 		kfree(bnad->regdata);
 		bnad->regdata = NULL;
 		bnad->reglen = 0;
@@ -389,8 +384,7 @@ bnad_debugfs_write_regwr(struct file *file, const char __user *buf,
 
 	rc = sscanf(kern_buf, "%x:%x", &addr, &val);
 	if (rc < 2) {
-		pr_warn("bna %s: Failed to read user buffer\n",
-			pci_name(bnad->pcidev));
+		netdev_warn(bnad->netdev, "failed to read user buffer\n");
 		kfree(kern_buf);
 		return -EINVAL;
 	}
@@ -401,8 +395,7 @@ bnad_debugfs_write_regwr(struct file *file, const char __user *buf,
 	/* offset and len sanity check */
 	rc = bna_reg_offset_check(ioc, addr, 1);
 	if (rc) {
-		pr_warn("bna %s: Failed reg offset check\n",
-			pci_name(bnad->pcidev));
+		netdev_warn(bnad->netdev, "failed reg offset check\n");
 		return -EINVAL;
 	}
 
@@ -514,7 +507,8 @@ bnad_debugfs_init(struct bnad *bnad)
 		bna_debugfs_root = debugfs_create_dir("bna", NULL);
 		atomic_set(&bna_debugfs_port_count, 0);
 		if (!bna_debugfs_root) {
-			pr_warn("BNA: debugfs root dir creation failed\n");
+			netdev_warn(bnad->netdev,
+				    "debugfs root dir creation failed\n");
 			return;
 		}
 	}
@@ -525,8 +519,8 @@ bnad_debugfs_init(struct bnad *bnad)
 		bnad->port_debugfs_root =
 			debugfs_create_dir(name, bna_debugfs_root);
 		if (!bnad->port_debugfs_root) {
-			pr_warn("bna pci_dev %s: root dir creation failed\n",
-				pci_name(bnad->pcidev));
+			netdev_warn(bnad->netdev,
+				    "debugfs root dir creation failed\n");
 			return;
 		}
 
@@ -541,9 +535,9 @@ bnad_debugfs_init(struct bnad *bnad)
 							bnad,
 							file->fops);
 			if (!bnad->bnad_dentry_files[i]) {
-				pr_warn(
-				     "BNA pci_dev:%s: create %s entry failed\n",
-				     pci_name(bnad->pcidev), file->name);
+				netdev_warn(bnad->netdev,
+					    "create %s entry failed\n",
+					    file->name);
 				return;
 			}
 		}
diff --git a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
index 088062a..2bdfc5d 100644
--- a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
+++ b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
@@ -1080,7 +1080,7 @@ bnad_flash_device(struct net_device *netdev, struct ethtool_flash *eflash)
 
 	ret = request_firmware(&fw, eflash->data, &bnad->pcidev->dev);
 	if (ret) {
-		pr_err("BNA: Can't locate firmware %s\n", eflash->data);
+		netdev_err(netdev, "can't load firmware %s\n", eflash->data);
 		goto out;
 	}
 
@@ -1093,7 +1093,7 @@ bnad_flash_device(struct net_device *netdev, struct ethtool_flash *eflash)
 				bnad->id, (u8 *)fw->data, fw->size, 0,
 				bnad_cb_completion, &fcomp);
 	if (ret != BFA_STATUS_OK) {
-		pr_warn("BNA: Flash update failed with err: %d\n", ret);
+		netdev_warn(netdev, "flash update failed with err=%d\n", ret);
 		ret = -EIO;
 		spin_unlock_irq(&bnad->bna_lock);
 		goto out;
@@ -1103,8 +1103,9 @@ bnad_flash_device(struct net_device *netdev, struct ethtool_flash *eflash)
 	wait_for_completion(&fcomp.comp);
 	if (fcomp.comp_status != BFA_STATUS_OK) {
 		ret = -EIO;
-		pr_warn("BNA: Firmware image update to flash failed with: %d\n",
-			fcomp.comp_status);
+		netdev_warn(netdev,
+			    "firmware image update failed with err=%d\n",
+			    fcomp.comp_status);
 	}
 out:
 	release_firmware(fw);
diff --git a/drivers/net/ethernet/brocade/bna/cna_fwimg.c b/drivers/net/ethernet/brocade/bna/cna_fwimg.c
index badea36..2e7fb97 100644
--- a/drivers/net/ethernet/brocade/bna/cna_fwimg.c
+++ b/drivers/net/ethernet/brocade/bna/cna_fwimg.c
@@ -33,7 +33,7 @@ cna_read_firmware(struct pci_dev *pdev, u32 **bfi_image,
 	u32 n;
 
 	if (request_firmware(&fw, fw_name, &pdev->dev)) {
-		pr_alert("Can't locate firmware %s\n", fw_name);
+		dev_alert(&pdev->dev, "can't load firmware %s\n", fw_name);
 		goto error;
 	}
 
-- 
2.3.6
