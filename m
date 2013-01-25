From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [net-next PATCH 4/8] qlcnic: avoid mixed mode interrupts for some adapter types
Date: Fri, 25 Jan 2013 15:20:37 -0500
Message-ID: <1359145241-5175-5-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1359145241-5175-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Manish chopra <manish.chopra@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:54600 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752331Ab3AYUl0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 15:41:26 -0500
In-Reply-To: <1359145241-5175-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish chopra <manish.chopra@qlogic.com>

o Some adapter types do not support co-existence of Legacy Interrupt with
  MSI-x or MSI among multiple functions. For those adapters, prevent attaching
  to a function during normal load, if MSI-x or MSI vectors are not available.
o Using module parameters use_msi=0 and use_msi_x=0, driver can be loaded in 
  legacy mode for all functions in the adapter.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   35 ++++++++++++++++-----
 1 files changed, 26 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index e460401..5cbf8c6 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -395,8 +395,9 @@ int qlcnic_enable_msix(struct qlcnic_adapter *adapter, u32 num_msix)
 	return err;
 }
 
-static void qlcnic_enable_msi_legacy(struct qlcnic_adapter *adapter)
+static int qlcnic_enable_msi_legacy(struct qlcnic_adapter *adapter)
 {
+	int err = 0;
 	u32 offset, mask_reg;
 	const struct qlcnic_legacy_intr_set *legacy_intrp;
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
@@ -409,8 +410,10 @@ static void qlcnic_enable_msi_legacy(struct qlcnic_adapter *adapter)
 							    offset);
 		dev_info(&pdev->dev, "using msi interrupts\n");
 		adapter->msix_entries[0].vector = pdev->irq;
-		return;
+		return err;
 	}
+	if (qlcnic_use_msi || qlcnic_use_msi_x)
+		return -EOPNOTSUPP;
 
 	legacy_intrp = &legacy_intr[adapter->ahw->pci_func];
 	adapter->ahw->int_vec_bit = legacy_intrp->int_vec_bit;
@@ -422,11 +425,12 @@ static void qlcnic_enable_msi_legacy(struct qlcnic_adapter *adapter)
 	adapter->crb_int_state_reg = qlcnic_get_ioaddr(ahw, ISR_INT_STATE_REG);
 	dev_info(&pdev->dev, "using legacy interrupts\n");
 	adapter->msix_entries[0].vector = pdev->irq;
+	return err;
 }
 
 int qlcnic_82xx_setup_intr(struct qlcnic_adapter *adapter, u8 num_intr)
 {
-	int num_msix, err;
+	int num_msix, err = 0;
 
 	if (!num_intr)
 		num_intr = QLCNIC_DEF_NUM_STS_DESC_RINGS;
@@ -441,8 +445,11 @@ int qlcnic_82xx_setup_intr(struct qlcnic_adapter *adapter, u8 num_intr)
 	if (err == -ENOMEM || !err)
 		return err;
 
-	qlcnic_enable_msi_legacy(adapter);
-	return 0;
+	err = qlcnic_enable_msi_legacy(adapter);
+	if (!err)
+		return err;
+
+	return -EIO;
 }
 
 void qlcnic_teardown_intr(struct qlcnic_adapter *adapter)
@@ -1843,8 +1850,10 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			board_name, adapter->ahw->revision_id);
 	}
 	err = qlcnic_setup_intr(adapter, 0);
-	if (err)
+	if (err) {
+		dev_err(&pdev->dev, "Failed to setup interrupt\n");
 		goto err_out_disable_msi;
+	}
 
 	if (qlcnic_83xx_check(adapter)) {
 		err = qlcnic_83xx_setup_mbx_intr(adapter);
@@ -2976,6 +2985,12 @@ static int qlcnic_attach_func(struct pci_dev *pdev)
 	adapter->msix_entries = NULL;
 	err = qlcnic_setup_intr(adapter, 0);
 
+	if (err) {
+		kfree(adapter->msix_entries);
+		netdev_err(netdev, "failed to setup interrupt\n");
+		return err;
+	}
+
 	if (qlcnic_83xx_check(adapter)) {
 		err = qlcnic_83xx_setup_mbx_intr(adapter);
 		if (err) {
@@ -3131,9 +3146,11 @@ int qlcnic_set_max_rss(struct qlcnic_adapter *adapter, u8 data, size_t len)
 	qlcnic_detach(adapter);
 	qlcnic_teardown_intr(adapter);
 	err = qlcnic_setup_intr(adapter, data);
-	if (err)
-		dev_err(&adapter->pdev->dev,
-			"failed setting max_rss; rss disabled\n");
+	if (err) {
+		kfree(adapter->msix_entries);
+		netdev_err(netdev, "failed to setup interrupt\n");
+		return err;
+	}
 
 	if (qlcnic_83xx_check(adapter)) {
 		err = qlcnic_83xx_setup_mbx_intr(adapter);
-- 
1.7.1
