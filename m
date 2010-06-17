From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 5/5] qlcnic: fix register access
Date: Thu, 17 Jun 2010 05:56:42 -0700
Message-ID: <1276779402-496-6-git-send-email-amit.salecha@qlogic.com>
References: <1276779402-496-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:54478 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752600Ab0FQM4o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jun 2010 08:56:44 -0400
In-Reply-To: <1276779402-496-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For certain set of register, base window addresses are not defined.
In such cases window should not set.
Return with error for such cases to avoid NMI.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_hw.c |   21 ++++++++++++++-------
 1 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index d9becb9..10ba723 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -766,7 +766,7 @@ qlcnic_pci_get_crb_addr_2M(struct qlcnic_adapter *adapter,
  * Out: 'off' is 2M pci map addr
  * side effect: lock crb window
  */
-static void
+static int
 qlcnic_pci_set_crbwindow_2M(struct qlcnic_adapter *adapter, ulong off)
 {
 	u32 window;
@@ -775,6 +775,10 @@ qlcnic_pci_set_crbwindow_2M(struct qlcnic_adapter *adapter, ulong off)
 	off -= QLCNIC_PCI_CRBSPACE;
 
 	window = CRB_HI(off);
+	if (window == 0) {
+		dev_err(&adapter->pdev->dev, "Invalid offset 0x%lx\n", off);
+		return -EIO;
+	}
 
 	writel(window, addr);
 	if (readl(addr) != window) {
@@ -782,7 +786,9 @@ qlcnic_pci_set_crbwindow_2M(struct qlcnic_adapter *adapter, ulong off)
 			dev_warn(&adapter->pdev->dev,
 				"failed to set CRB window to %d off 0x%lx\n",
 				window, off);
+		return -EIO;
 	}
+	return 0;
 }
 
 int
@@ -803,11 +809,12 @@ qlcnic_hw_write_wx_2M(struct qlcnic_adapter *adapter, ulong off, u32 data)
 		/* indirect access */
 		write_lock_irqsave(&adapter->ahw.crb_lock, flags);
 		crb_win_lock(adapter);
-		qlcnic_pci_set_crbwindow_2M(adapter, off);
-		writel(data, addr);
+		rv = qlcnic_pci_set_crbwindow_2M(adapter, off);
+		if (!rv)
+			writel(data, addr);
 		crb_win_unlock(adapter);
 		write_unlock_irqrestore(&adapter->ahw.crb_lock, flags);
-		return 0;
+		return rv;
 	}
 
 	dev_err(&adapter->pdev->dev,
@@ -821,7 +828,7 @@ qlcnic_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off)
 {
 	unsigned long flags;
 	int rv;
-	u32 data;
+	u32 data = -1;
 	void __iomem *addr = NULL;
 
 	rv = qlcnic_pci_get_crb_addr_2M(adapter, off, &addr);
@@ -833,8 +840,8 @@ qlcnic_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off)
 		/* indirect access */
 		write_lock_irqsave(&adapter->ahw.crb_lock, flags);
 		crb_win_lock(adapter);
-		qlcnic_pci_set_crbwindow_2M(adapter, off);
-		data = readl(addr);
+		if (!qlcnic_pci_set_crbwindow_2M(adapter, off))
+			data = readl(addr);
 		crb_win_unlock(adapter);
 		write_unlock_irqrestore(&adapter->ahw.crb_lock, flags);
 		return data;
-- 
1.6.0.2

