From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 3/3] cxgb4: Wait for device to get ready before reading any register
Date: Thu,  9 Oct 2014 05:48:47 +0530
Message-ID: <1412813927-24951-4-git-send-email-hariprasad@chelsio.com>
References: <1412813927-24951-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, kumaras@chelsio.com,
	nirranjan@chelsio.com, santosh@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:59663
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755199AbaJIAOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 20:14:38 -0400
In-Reply-To: <1412813927-24951-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call t4_wait_dev_ready() before attempting to read the PL_WHOAMI register
(to determine which function we have been attached to). This prevents us from
failing on that read if it comes right after a RESET.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |    2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    6 +++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |   17 ++++++++++-------
 3 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 9b2c669..410ed58 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -968,7 +968,7 @@ void t4_intr_enable(struct adapter *adapter);
 void t4_intr_disable(struct adapter *adapter);
 int t4_slow_intr_handler(struct adapter *adapter);
 
-int t4_wait_dev_ready(struct adapter *adap);
+int t4_wait_dev_ready(void __iomem *regs);
 int t4_link_start(struct adapter *adap, unsigned int mbox, unsigned int port,
 		  struct link_config *lc);
 int t4_restart_aneg(struct adapter *adap, unsigned int mbox, unsigned int port);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 321f3d9..5b38e95 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -6137,7 +6137,7 @@ static pci_ers_result_t eeh_slot_reset(struct pci_dev *pdev)
 	pci_save_state(pdev);
 	pci_cleanup_aer_uncorrect_error_status(pdev);
 
-	if (t4_wait_dev_ready(adap) < 0)
+	if (t4_wait_dev_ready(adap->regs) < 0)
 		return PCI_ERS_RESULT_DISCONNECT;
 	if (t4_fw_hello(adap, adap->fn, adap->fn, MASTER_MUST, NULL) < 0)
 		return PCI_ERS_RESULT_DISCONNECT;
@@ -6530,6 +6530,10 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto out_disable_device;
 	}
 
+	err = t4_wait_dev_ready(regs);
+	if (err < 0)
+		goto out_unmap_bar0;
+
 	/* We control everything through one PF */
 	func = SOURCEPF_GET(readl(regs + PL_WHOAMI));
 	if (func != ent->driver_data) {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 22d7581..1fff149 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -3845,12 +3845,19 @@ static void init_link_config(struct link_config *lc, unsigned int caps)
 	}
 }
 
-int t4_wait_dev_ready(struct adapter *adap)
+#define CIM_PF_NOACCESS 0xeeeeeeee
+
+int t4_wait_dev_ready(void __iomem *regs)
 {
-	if (t4_read_reg(adap, PL_WHOAMI) != 0xffffffff)
+	u32 whoami;
+
+	whoami = readl(regs + PL_WHOAMI);
+	if (whoami != 0xffffffff && whoami != CIM_PF_NOACCESS)
 		return 0;
+
 	msleep(500);
-	return t4_read_reg(adap, PL_WHOAMI) != 0xffffffff ? 0 : -EIO;
+	whoami = readl(regs + PL_WHOAMI);
+	return (whoami != 0xffffffff && whoami != CIM_PF_NOACCESS ? 0 : -EIO);
 }
 
 struct flash_desc {
@@ -3919,10 +3926,6 @@ int t4_prep_adapter(struct adapter *adapter)
 	uint16_t device_id;
 	u32 pl_rev;
 
-	ret = t4_wait_dev_ready(adapter);
-	if (ret < 0)
-		return ret;
-
 	get_pci_mode(adapter, &adapter->params.pci);
 	pl_rev = G_REV(t4_read_reg(adapter, PL_REV));
 
-- 
1.7.1
