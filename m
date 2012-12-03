From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 1/1] bnx2x: recognize fan failure
Date: Mon, 3 Dec 2012 11:56:49 +0200
Message-ID: <1354528609-17486-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, "Yaniv Rosner" <yaniv.rosner@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4859 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754244Ab2LCJzf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2012 04:55:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <yaniv.rosner@broadcom.com>

If fan failure is detected, MCP prevents PCI I/O registers from being
mapped to the bar, causing a fatal error as driver is unaware.

This patch recognizes such an event occurred and gracefully terminates
the probe process.

Signed-off-by: Yaniv Rosner <yaniv.rosner@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
Hi Dave,

This patch prevents a fatal error on newer bnx2x boards.

Please consider applying it to 'net'.
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    8 ++++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h  |    4 +++-
 2 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 01611b3..101392b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -11346,6 +11346,14 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 		goto err_out_disable;
 	}
 
+	pci_read_config_dword(pdev, PCICFG_REVISION_ID_OFFSET, &pci_cfg_dword);
+	if ((pci_cfg_dword & PCICFG_REVESION_ID_MASK) ==
+	    PCICFG_REVESION_ID_ERROR_VAL) {
+		pr_err("PCI device error, probably due to fan failure, aborting\n");
+		rc = -ENODEV;
+		goto err_out_disable;
+	}
+
 	if (atomic_read(&pdev->enable_cnt) == 1) {
 		rc = pci_request_regions(pdev, DRV_MODULE_NAME);
 		if (rc) {
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index 1b1999d..698cbf7 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -6130,7 +6130,9 @@
 #define PCICFG_COMMAND_INT_DISABLE		(1<<10)
 #define PCICFG_COMMAND_RESERVED 		(0x1f<<11)
 #define PCICFG_STATUS_OFFSET				0x06
-#define PCICFG_REVESION_ID_OFFSET			0x08
+#define PCICFG_REVISION_ID_OFFSET			0x08
+#define PCICFG_REVESION_ID_MASK			0xff
+#define PCICFG_REVESION_ID_ERROR_VAL		0xff
 #define PCICFG_CACHE_LINE_SIZE				0x0c
 #define PCICFG_LATENCY_TIMER				0x0d
 #define PCICFG_BAR_1_LOW				0x10
-- 
1.7.1
