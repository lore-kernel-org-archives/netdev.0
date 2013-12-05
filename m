From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net 1/3] be2net: Fix Lancer error recovery to distinguish FW download
Date: Thu, 5 Dec 2013 10:34:20 +0530
Message-ID: <e995008d-8fee-4e1f-a516-b475b4c4c17b@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath Kotur <somnath.kotur@emulex.com>,
	Kalesh AP <kalesh.purayil@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:49641 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751109Ab3LEFFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 00:05:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Firmware update would be detected by looking at the sliport_error1/
sliport_error2 register values(0x02/0x00). If its not a FW reset the current
messaging would take place. If the error is due to FW reset, log a message to
user that "Firmware update in progress" and also do not log sliport_status and
sliport_error register values.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Somnath kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_hw.h   |    3 +++
 drivers/net/ethernet/emulex/benet/be_main.c |   18 ++++++++++++++----
 2 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_hw.h b/drivers/net/ethernet/emulex/benet/be_hw.h
index 3e21621..dc88782 100644
--- a/drivers/net/ethernet/emulex/benet/be_hw.h
+++ b/drivers/net/ethernet/emulex/benet/be_hw.h
@@ -64,6 +64,9 @@
 #define SLIPORT_ERROR_NO_RESOURCE1	0x2
 #define SLIPORT_ERROR_NO_RESOURCE2	0x9
 
+#define SLIPORT_ERROR_FW_RESET1		0x2
+#define SLIPORT_ERROR_FW_RESET2		0x0
+
 /********* Memory BAR register ************/
 #define PCICFG_MEMBAR_CTRL_INT_CTRL_OFFSET 	0xfc
 /* Host Interrupt Enable, if set interrupts are enabled although "PCI Interrupt
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index fee64bf..a2302dc 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2464,8 +2464,16 @@ void be_detect_error(struct be_adapter *adapter)
 	 */
 	if (sliport_status & SLIPORT_STATUS_ERR_MASK) {
 		adapter->hw_error = true;
-		dev_err(&adapter->pdev->dev,
-			"Error detected in the card\n");
+		/* Do not log error messages if its a FW reset */
+		if (sliport_err1 == SLIPORT_ERROR_FW_RESET1 &&
+		    sliport_err2 == SLIPORT_ERROR_FW_RESET2) {
+			dev_info(&adapter->pdev->dev,
+				 "Firmware update in progress\n");
+			return;
+		} else {
+			dev_err(&adapter->pdev->dev,
+				"Error detected in the card\n");
+		}
 	}
 
 	if (sliport_status & SLIPORT_STATUS_ERR_MASK) {
@@ -3812,6 +3820,8 @@ static int lancer_fw_download(struct be_adapter *adapter,
 	}
 
 	if (change_status == LANCER_FW_RESET_NEEDED) {
+		dev_info(&adapter->pdev->dev,
+			 "Resetting adapter to activate new FW\n");
 		status = lancer_physdev_ctrl(adapter,
 					     PHYSDEV_CONTROL_FW_RESET_MASK);
 		if (status) {
@@ -4363,13 +4373,13 @@ static int lancer_recover_func(struct be_adapter *adapter)
 			goto err;
 	}
 
-	dev_err(dev, "Error recovery successful\n");
+	dev_err(dev, "Adapter recovery successful\n");
 	return 0;
 err:
 	if (status == -EAGAIN)
 		dev_err(dev, "Waiting for resource provisioning\n");
 	else
-		dev_err(dev, "Error recovery failed\n");
+		dev_err(dev, "Adapter recovery failed\n");
 
 	return status;
 }
-- 
1.6.0.2
