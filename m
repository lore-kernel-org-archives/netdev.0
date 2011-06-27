From: Jon Mason <jdmason@kudzu.us>
Subject: [PATCH 11/19] bnx2x: remove unnecessary read of PCI_CAP_ID_EXP
Date: Mon, 27 Jun 2011 12:45:12 -0500
Message-ID: <1309196712-16081-1-git-send-email-jdmason@kudzu.us>
Cc: netdev@vger.kernel.org
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:45691 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752862Ab1F0RpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 13:45:17 -0400
Received: by pwj7 with SMTP id 7so3084631pwj.19
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2011 10:45:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PCIE capability offset is saved during PCI bus walking.  It will
remove an unnecessary search in the PCI configuration space if this
value is referenced instead of reacquiring it.  Also, pci_is_pcie is a
better way of determining if the device is PCIE or not (as it uses the
same saved PCIE capability offset).

Signed-off-by: Jon Mason <jdmason@kudzu.us>
---
 drivers/net/bnx2x/bnx2x.h      |    1 -
 drivers/net/bnx2x/bnx2x_main.c |   10 ++++------
 2 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index eff78a4..0d4b981 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -1156,7 +1156,6 @@ struct bnx2x {
 #define NO_FCOE(bp)		((bp)->flags & NO_FCOE_FLAG)
 
 	int			pm_cap;
-	int			pcie_cap;
 	int			mrrs;
 
 	struct delayed_work	sp_task;
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index af57217..b6f82eb 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -1222,7 +1222,7 @@ static inline u8 bnx2x_is_pcie_pending(struct pci_dev *dev)
 	int pos;
 	u16 status;
 
-	pos = pci_find_capability(dev, PCI_CAP_ID_EXP);
+	pos = pci_pcie_cap(dev);
 	if (!pos)
 		return false;
 
@@ -5498,7 +5498,7 @@ static void bnx2x_init_pxp(struct bnx2x *bp)
 	int r_order, w_order;
 
 	pci_read_config_word(bp->pdev,
-			     bp->pcie_cap + PCI_EXP_DEVCTL, &devctl);
+			     bp->pdev->pcie_cap + PCI_EXP_DEVCTL, &devctl);
 	DP(NETIF_MSG_HW, "read 0x%x from devctl\n", devctl);
 	w_order = ((devctl & PCI_EXP_DEVCTL_PAYLOAD) >> 5);
 	if (bp->mrrs == -1)
@@ -9759,10 +9759,8 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 		goto err_out_release;
 	}
 
-	bp->pcie_cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
-	if (bp->pcie_cap == 0) {
-		dev_err(&bp->pdev->dev,
-			"Cannot find PCI Express capability, aborting\n");
+	if (!pci_is_pcie(pdev)) {
+		dev_err(&bp->pdev->dev,	"Not PCI Express, aborting\n");
 		rc = -EIO;
 		goto err_out_release;
 	}
-- 
1.7.5.4

