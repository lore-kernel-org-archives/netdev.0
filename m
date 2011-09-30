From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH next 1/7] bnx2: don't request firmware when there's no userspace.
Date: Fri, 30 Sep 2011 12:36:52 +0200
Message-ID: <20110930103652.GB26727@electric-eye.fr.zoreil.com>
References: <20110930103604.GA26727@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54222 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754105Ab1I3Ki1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2011 06:38:27 -0400
Content-Disposition: inline
In-Reply-To: <20110930103604.GA26727@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The firmware is cached during the first successful call to open() and
released once the network device is unregistered. The driver uses the
cached firmware between open() and unregister_netdev().

It's similar to 953a12cc2889d1be92e80a2d0bab5ffef4942300 but the
firmware is mandatory.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |   67 +++++++++++++++++++++-------------
 1 files changed, 41 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 9afb653..21bdda3 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -3623,7 +3623,7 @@ bnx2_set_rx_mode(struct net_device *dev)
 	spin_unlock_bh(&bp->phy_lock);
 }
 
-static int __devinit
+static int
 check_fw_section(const struct firmware *fw,
 		 const struct bnx2_fw_file_section *section,
 		 u32 alignment, bool non_empty)
@@ -3639,7 +3639,7 @@ check_fw_section(const struct firmware *fw,
 	return 0;
 }
 
-static int __devinit
+static int
 check_mips_fw_entry(const struct firmware *fw,
 		    const struct bnx2_mips_fw_file_entry *entry)
 {
@@ -3650,8 +3650,16 @@ check_mips_fw_entry(const struct firmware *fw,
 	return 0;
 }
 
-static int __devinit
-bnx2_request_firmware(struct bnx2 *bp)
+static void bnx2_release_firmware(struct bnx2 *bp)
+{
+	if (bp->rv2p_firmware) {
+		release_firmware(bp->mips_firmware);
+		release_firmware(bp->rv2p_firmware);
+		bp->rv2p_firmware = NULL;
+	}
+}
+
+static int bnx2_request_uncached_firmware(struct bnx2 *bp)
 {
 	const char *mips_fw_file, *rv2p_fw_file;
 	const struct bnx2_mips_fw_file *mips_fw;
@@ -3673,13 +3681,13 @@ bnx2_request_firmware(struct bnx2 *bp)
 	rc = request_firmware(&bp->mips_firmware, mips_fw_file, &bp->pdev->dev);
 	if (rc) {
 		pr_err("Can't load firmware file \"%s\"\n", mips_fw_file);
-		return rc;
+		goto out;
 	}
 
 	rc = request_firmware(&bp->rv2p_firmware, rv2p_fw_file, &bp->pdev->dev);
 	if (rc) {
 		pr_err("Can't load firmware file \"%s\"\n", rv2p_fw_file);
-		return rc;
+		goto err_release_mips_firmware;
 	}
 	mips_fw = (const struct bnx2_mips_fw_file *) bp->mips_firmware->data;
 	rv2p_fw = (const struct bnx2_rv2p_fw_file *) bp->rv2p_firmware->data;
@@ -3690,16 +3698,30 @@ bnx2_request_firmware(struct bnx2 *bp)
 	    check_mips_fw_entry(bp->mips_firmware, &mips_fw->tpat) ||
 	    check_mips_fw_entry(bp->mips_firmware, &mips_fw->txp)) {
 		pr_err("Firmware file \"%s\" is invalid\n", mips_fw_file);
-		return -EINVAL;
+		rc = -EINVAL;
+		goto err_release_firmware;
 	}
 	if (bp->rv2p_firmware->size < sizeof(*rv2p_fw) ||
 	    check_fw_section(bp->rv2p_firmware, &rv2p_fw->proc1.rv2p, 8, true) ||
 	    check_fw_section(bp->rv2p_firmware, &rv2p_fw->proc2.rv2p, 8, true)) {
 		pr_err("Firmware file \"%s\" is invalid\n", rv2p_fw_file);
-		return -EINVAL;
+		rc = -EINVAL;
+		goto err_release_firmware;
 	}
+out:
+	return rc;
 
-	return 0;
+err_release_firmware:
+	release_firmware(bp->rv2p_firmware);
+	bp->rv2p_firmware = NULL;
+err_release_mips_firmware:
+	release_firmware(bp->mips_firmware);
+	goto out;
+}
+
+static int bnx2_request_firmware(struct bnx2 *bp)
+{
+	return bp->rv2p_firmware ? 0 : bnx2_request_uncached_firmware(bp);
 }
 
 static u32
@@ -6267,6 +6289,10 @@ bnx2_open(struct net_device *dev)
 	struct bnx2 *bp = netdev_priv(dev);
 	int rc;
 
+	rc = bnx2_request_firmware(bp);
+	if (rc < 0)
+		goto out;
+
 	netif_carrier_off(dev);
 
 	bnx2_set_power_state(bp, PCI_D0);
@@ -6327,8 +6353,8 @@ bnx2_open(struct net_device *dev)
 		netdev_info(dev, "using MSIX\n");
 
 	netif_tx_start_all_queues(dev);
-
-	return 0;
+out:
+	return rc;
 
 open_err:
 	bnx2_napi_disable(bp);
@@ -6336,7 +6362,8 @@ open_err:
 	bnx2_free_irq(bp);
 	bnx2_free_mem(bp);
 	bnx2_del_napi(bp);
-	return rc;
+	bnx2_release_firmware(bp);
+	goto out;
 }
 
 static void
@@ -8354,10 +8381,6 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	pci_set_drvdata(pdev, dev);
 
-	rc = bnx2_request_firmware(bp);
-	if (rc)
-		goto error;
-
 	memcpy(dev->dev_addr, bp->mac_addr, 6);
 	memcpy(dev->perm_addr, bp->mac_addr, 6);
 
@@ -8389,11 +8412,6 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	return 0;
 
 error:
-	if (bp->mips_firmware)
-		release_firmware(bp->mips_firmware);
-	if (bp->rv2p_firmware)
-		release_firmware(bp->rv2p_firmware);
-
 	if (bp->regview)
 		iounmap(bp->regview);
 	pci_release_regions(pdev);
@@ -8414,11 +8432,6 @@ bnx2_remove_one(struct pci_dev *pdev)
 	del_timer_sync(&bp->timer);
 	cancel_work_sync(&bp->reset_task);
 
-	if (bp->mips_firmware)
-		release_firmware(bp->mips_firmware);
-	if (bp->rv2p_firmware)
-		release_firmware(bp->rv2p_firmware);
-
 	if (bp->regview)
 		iounmap(bp->regview);
 
@@ -8429,6 +8442,8 @@ bnx2_remove_one(struct pci_dev *pdev)
 		bp->flags &= ~BNX2_FLAG_AER_ENABLED;
 	}
 
+	bnx2_release_firmware(bp);
+
 	free_netdev(dev);
 
 	pci_release_regions(pdev);
-- 
1.7.6.2
