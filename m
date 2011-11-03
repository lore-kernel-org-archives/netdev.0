From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 4/4] be2net: Add detect UE feature for Lancer
Date: Thu, 3 Nov 2011 17:20:08 +0530
Message-ID: <869ff89d-7ae0-4044-af53-82b278e66ef2@exht2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:24424 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755802Ab1KCLuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 07:50:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add code to detect UE in case of Lancer.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    3 +-
 drivers/net/ethernet/emulex/benet/be_hw.h   |    2 +
 drivers/net/ethernet/emulex/benet/be_main.c |   60 ++++++++++++++++++---------
 3 files changed, 43 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 03fe7cd..2c7b366 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -318,8 +318,7 @@ static int be_mbox_db_ready_wait(struct be_adapter *adapter, void __iomem *db)
 
 		if (msecs > 4000) {
 			dev_err(&adapter->pdev->dev, "mbox poll timed out\n");
-			if (!lancer_chip(adapter))
-				be_detect_dump_ue(adapter);
+			be_detect_dump_ue(adapter);
 			return -1;
 		}
 
diff --git a/drivers/net/ethernet/emulex/benet/be_hw.h b/drivers/net/ethernet/emulex/benet/be_hw.h
index fbc8a91..f2c89e3 100644
--- a/drivers/net/ethernet/emulex/benet/be_hw.h
+++ b/drivers/net/ethernet/emulex/benet/be_hw.h
@@ -48,6 +48,8 @@
 /* Lancer SLIPORT_CONTROL SLIPORT_STATUS registers */
 #define SLIPORT_STATUS_OFFSET		0x404
 #define SLIPORT_CONTROL_OFFSET		0x408
+#define SLIPORT_ERROR1_OFFSET		0x40C
+#define SLIPORT_ERROR2_OFFSET		0x410
 
 #define SLIPORT_STATUS_ERR_MASK		0x80000000
 #define SLIPORT_STATUS_RN_MASK		0x01000000
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 30606f5..e0aed18 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1977,42 +1977,62 @@ static int be_poll_tx_mcc(struct napi_struct *napi, int budget)
 
 void be_detect_dump_ue(struct be_adapter *adapter)
 {
-	u32 ue_status_lo, ue_status_hi, ue_status_lo_mask, ue_status_hi_mask;
+	u32 ue_lo = 0, ue_hi = 0, ue_lo_mask = 0, ue_hi_mask = 0;
+	u32 sliport_status = 0, sliport_err1 = 0, sliport_err2 = 0;
 	u32 i;
 
-	pci_read_config_dword(adapter->pdev,
-				PCICFG_UE_STATUS_LOW, &ue_status_lo);
-	pci_read_config_dword(adapter->pdev,
-				PCICFG_UE_STATUS_HIGH, &ue_status_hi);
-	pci_read_config_dword(adapter->pdev,
-				PCICFG_UE_STATUS_LOW_MASK, &ue_status_lo_mask);
-	pci_read_config_dword(adapter->pdev,
-				PCICFG_UE_STATUS_HI_MASK, &ue_status_hi_mask);
+	if (lancer_chip(adapter)) {
+		sliport_status = ioread32(adapter->db + SLIPORT_STATUS_OFFSET);
+		if (sliport_status & SLIPORT_STATUS_ERR_MASK) {
+			sliport_err1 = ioread32(adapter->db +
+					SLIPORT_ERROR1_OFFSET);
+			sliport_err2 = ioread32(adapter->db +
+					SLIPORT_ERROR2_OFFSET);
+		}
+	} else {
+		pci_read_config_dword(adapter->pdev,
+				PCICFG_UE_STATUS_LOW, &ue_lo);
+		pci_read_config_dword(adapter->pdev,
+				PCICFG_UE_STATUS_HIGH, &ue_hi);
+		pci_read_config_dword(adapter->pdev,
+				PCICFG_UE_STATUS_LOW_MASK, &ue_lo_mask);
+		pci_read_config_dword(adapter->pdev,
+				PCICFG_UE_STATUS_HI_MASK, &ue_hi_mask);
 
-	ue_status_lo = (ue_status_lo & (~ue_status_lo_mask));
-	ue_status_hi = (ue_status_hi & (~ue_status_hi_mask));
+		ue_lo = (ue_lo & (~ue_lo_mask));
+		ue_hi = (ue_hi & (~ue_hi_mask));
+	}
 
-	if (ue_status_lo || ue_status_hi) {
+	if (ue_lo || ue_hi ||
+		sliport_status & SLIPORT_STATUS_ERR_MASK) {
 		adapter->ue_detected = true;
 		adapter->eeh_err = true;
 		dev_err(&adapter->pdev->dev, "UE Detected!!\n");
 	}
 
-	if (ue_status_lo) {
-		for (i = 0; ue_status_lo; ue_status_lo >>= 1, i++) {
-			if (ue_status_lo & 1)
+	if (ue_lo) {
+		for (i = 0; ue_lo; ue_lo >>= 1, i++) {
+			if (ue_lo & 1)
 				dev_err(&adapter->pdev->dev,
 				"UE: %s bit set\n", ue_status_low_desc[i]);
 		}
 	}
-	if (ue_status_hi) {
-		for (i = 0; ue_status_hi; ue_status_hi >>= 1, i++) {
-			if (ue_status_hi & 1)
+	if (ue_hi) {
+		for (i = 0; ue_hi; ue_hi >>= 1, i++) {
+			if (ue_hi & 1)
 				dev_err(&adapter->pdev->dev,
 				"UE: %s bit set\n", ue_status_hi_desc[i]);
 		}
 	}
 
+	if (sliport_status & SLIPORT_STATUS_ERR_MASK) {
+		dev_err(&adapter->pdev->dev,
+			"sliport status 0x%x\n", sliport_status);
+		dev_err(&adapter->pdev->dev,
+			"sliport error1 0x%x\n", sliport_err1);
+		dev_err(&adapter->pdev->dev,
+			"sliport error2 0x%x\n", sliport_err2);
+	}
 }
 
 static void be_worker(struct work_struct *work)
@@ -2022,7 +2042,7 @@ static void be_worker(struct work_struct *work)
 	struct be_rx_obj *rxo;
 	int i;
 
-	if (!adapter->ue_detected && !lancer_chip(adapter))
+	if (!adapter->ue_detected)
 		be_detect_dump_ue(adapter);
 
 	/* when interrupts are not yet enabled, just reap any pending
-- 
1.6.0.2
