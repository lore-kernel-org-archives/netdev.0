From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 3/9] qlcnic: fix caching window register
Date: Thu, 13 May 2010 06:07:44 -0700
Message-ID: <1273756070-7205-4-git-send-email-amit.salecha@qlogic.com>
References: <1273756070-7205-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:54342 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1758584Ab0EMNHx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 09:07:53 -0400
In-Reply-To: <1273756070-7205-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Window register is not per pci-func, so caching can
result in expected result.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    3 ---
 drivers/net/qlcnic/qlcnic_hw.c   |    5 -----
 drivers/net/qlcnic/qlcnic_main.c |   10 ----------
 3 files changed, 0 insertions(+), 18 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 2fba9cd..cfedcbd 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -399,9 +399,6 @@ struct qlcnic_hardware_context {
 
 	unsigned long pci_len0;
 
-	u32 ocm_win;
-	u32 crb_win;
-
 	rwlock_t crb_lock;
 	struct mutex mem_lock;
 
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index 7a72b8d..0c2e1f0 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -776,9 +776,6 @@ qlcnic_pci_set_crbwindow_2M(struct qlcnic_adapter *adapter, ulong off)
 
 	window = CRB_HI(off);
 
-	if (adapter->ahw.crb_win == window)
-		return;
-
 	writel(window, addr);
 	if (readl(addr) != window) {
 		if (printk_ratelimit())
@@ -786,7 +783,6 @@ qlcnic_pci_set_crbwindow_2M(struct qlcnic_adapter *adapter, ulong off)
 				"failed to set CRB window to %d off 0x%lx\n",
 				window, off);
 	}
-	adapter->ahw.crb_win = window;
 }
 
 int
@@ -874,7 +870,6 @@ qlcnic_pci_set_window_2M(struct qlcnic_adapter *adapter,
 	/* read back to flush */
 	readl(adapter->ahw.ocm_win_crb);
 
-	adapter->ahw.ocm_win = window;
 	*start = QLCNIC_PCI_OCM0_2M + GET_MEM_OFFS_2M(addr);
 	return 0;
 }
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index dc791d5..4652c7b 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -518,13 +518,6 @@ qlcnic_setup_pci_map(struct qlcnic_adapter *adapter)
 	struct pci_dev *pdev = adapter->pdev;
 	int pci_func = adapter->ahw.pci_func;
 
-	/*
-	 * Set the CRB window to invalid. If any register in window 0 is
-	 * accessed it should set the window to 0 and then reset it to 1.
-	 */
-	adapter->ahw.crb_win = -1;
-	adapter->ahw.ocm_win = -1;
-
 	/* remap phys address */
 	mem_base = pci_resource_start(pdev, 0);	/* 0 is for BAR 0 */
 	mem_len = pci_resource_len(pdev, 0);
@@ -1312,9 +1305,6 @@ qlcnic_resume(struct pci_dev *pdev)
 	pci_set_master(pdev);
 	pci_restore_state(pdev);
 
-	adapter->ahw.crb_win = -1;
-	adapter->ahw.ocm_win = -1;
-
 	err = qlcnic_start_firmware(adapter);
 	if (err) {
 		dev_err(&pdev->dev, "failed to start firmware\n");
-- 
1.6.0.2

