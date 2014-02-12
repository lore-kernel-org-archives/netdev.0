From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH 1/3] be2net: Log a kernel message when UE is detected in BE & Skyhawk
Date: Wed, 12 Feb 2014 16:07:54 +0530
Message-ID: <d97754ad-2377-4520-b87f-aab71d740af8@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:28888 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460AbaBLKje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 05:39:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch logs a kernel message when a HW error(SLIPORT_ERROR in Lancer and UE
in BEx/Skyhawk) is detected. The log message for BE3 was missing earlier.
This patch also refactors the code by segregating error-detection and reporting
code for Lancer and BEx/SH.

Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   82 +++++++++++++-------------
 1 files changed, 41 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 04ac9c6..7057545 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2423,6 +2423,9 @@ void be_detect_error(struct be_adapter *adapter)
 	u32 ue_lo = 0, ue_hi = 0, ue_lo_mask = 0, ue_hi_mask = 0;
 	u32 sliport_status = 0, sliport_err1 = 0, sliport_err2 = 0;
 	u32 i;
+	bool error_detected = false;
+	struct device *dev = &adapter->pdev->dev;
+	struct net_device *netdev = adapter->netdev;
 
 	if (be_hw_error(adapter))
 		return;
@@ -2434,6 +2437,21 @@ void be_detect_error(struct be_adapter *adapter)
 					SLIPORT_ERROR1_OFFSET);
 			sliport_err2 = ioread32(adapter->db +
 					SLIPORT_ERROR2_OFFSET);
+			adapter->hw_error = true;
+			/* Do not log error messages if its a FW reset */
+			if (sliport_err1 == SLIPORT_ERROR_FW_RESET1 &&
+			    sliport_err2 == SLIPORT_ERROR_FW_RESET2) {
+				dev_info(dev, "Firmware update in progress\n");
+			} else {
+				error_detected = true;
+				dev_err(dev, "Error detected in the card\n");
+				dev_err(dev, "ERR: sliport status 0x%x\n",
+					sliport_status);
+				dev_err(dev, "ERR: sliport error1 0x%x\n",
+					sliport_err1);
+				dev_err(dev, "ERR: sliport error2 0x%x\n",
+					sliport_err2);
+			}
 		}
 	} else {
 		pci_read_config_dword(adapter->pdev,
@@ -2447,51 +2465,33 @@ void be_detect_error(struct be_adapter *adapter)
 
 		ue_lo = (ue_lo & ~ue_lo_mask);
 		ue_hi = (ue_hi & ~ue_hi_mask);
-	}
-
-	/* On certain platforms BE hardware can indicate spurious UEs.
-	 * Allow the h/w to stop working completely in case of a real UE.
-	 * Hence not setting the hw_error for UE detection.
-	 */
-	if (sliport_status & SLIPORT_STATUS_ERR_MASK) {
-		adapter->hw_error = true;
-		/* Do not log error messages if its a FW reset */
-		if (sliport_err1 == SLIPORT_ERROR_FW_RESET1 &&
-		    sliport_err2 == SLIPORT_ERROR_FW_RESET2) {
-			dev_info(&adapter->pdev->dev,
-				 "Firmware update in progress\n");
-			return;
-		} else {
-			dev_err(&adapter->pdev->dev,
-				"Error detected in the card\n");
-		}
-	}
 
-	if (sliport_status & SLIPORT_STATUS_ERR_MASK) {
-		dev_err(&adapter->pdev->dev,
-			"ERR: sliport status 0x%x\n", sliport_status);
-		dev_err(&adapter->pdev->dev,
-			"ERR: sliport error1 0x%x\n", sliport_err1);
-		dev_err(&adapter->pdev->dev,
-			"ERR: sliport error2 0x%x\n", sliport_err2);
-	}
-
-	if (ue_lo) {
-		for (i = 0; ue_lo; ue_lo >>= 1, i++) {
-			if (ue_lo & 1)
-				dev_err(&adapter->pdev->dev,
-				"UE: %s bit set\n", ue_status_low_desc[i]);
-		}
-	}
+		/* On certain platforms BE hardware can indicate spurious UEs.
+		 * Allow HW to stop working completely in case of a real UE.
+		 * Hence not setting the hw_error for UE detection.
+		 */
 
-	if (ue_hi) {
-		for (i = 0; ue_hi; ue_hi >>= 1, i++) {
-			if (ue_hi & 1)
-				dev_err(&adapter->pdev->dev,
-				"UE: %s bit set\n", ue_status_hi_desc[i]);
+		if (ue_lo || ue_hi) {
+			error_detected = true;
+			dev_err(dev,
+				"Unrecoverable Error detected in the adapter");
+			dev_err(dev, "Please reboot server to recover");
+			if (skyhawk_chip(adapter))
+				adapter->hw_error = true;
+			for (i = 0; ue_lo; ue_lo >>= 1, i++) {
+				if (ue_lo & 1)
+					dev_err(dev, "UE: %s bit set\n",
+						ue_status_low_desc[i]);
+			}
+			for (i = 0; ue_hi; ue_hi >>= 1, i++) {
+				if (ue_hi & 1)
+					dev_err(dev, "UE: %s bit set\n",
+						ue_status_hi_desc[i]);
+			}
 		}
 	}
-
+	if (error_detected)
+		netif_carrier_off(netdev);
 }
 
 static void be_msix_disable(struct be_adapter *adapter)
-- 
1.5.6.1
