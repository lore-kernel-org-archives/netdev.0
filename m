From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH v2 net-next 06/12] be2net: fix log messages in lancer FW download path
Date: Tue, 2 Sep 2014 09:56:51 +0530
Message-ID: <1409632017-15655-7-git-send-email-sathya.perla@emulex.com>
References: <1409632017-15655-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:30325 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752429AbaIBEYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 00:24:23 -0400
In-Reply-To: <1409632017-15655-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

Log messages in the Lancer FW download path have issues such as:
- a single message spanning multiple lines
- the success message is logged even in failure cases
- status codes are already logged in the FW cmd routines
This patch fixes these issues.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   30 +++++++++-----------------
 1 files changed, 11 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index c95998f..7e89e5b 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4076,6 +4076,7 @@ static int lancer_fw_download(struct be_adapter *adapter,
 {
 #define LANCER_FW_DOWNLOAD_CHUNK      (32 * 1024)
 #define LANCER_FW_DOWNLOAD_LOCATION   "/prg"
+	struct device *dev = &adapter->pdev->dev;
 	struct be_dma_mem flash_cmd;
 	const u8 *data_ptr = NULL;
 	u8 *dest_image_ptr = NULL;
@@ -4088,16 +4089,14 @@ static int lancer_fw_download(struct be_adapter *adapter,
 	u8 change_status;
 
 	if (!IS_ALIGNED(fw->size, sizeof(u32))) {
-		dev_err(&adapter->pdev->dev,
-			"FW Image not properly aligned. "
-			"Length must be 4 byte aligned.\n");
+		dev_err(dev, "FW image size should be multiple of 4\n");
 		status = -EINVAL;
 		goto lancer_fw_exit;
 	}
 
 	flash_cmd.size = sizeof(struct lancer_cmd_req_write_object)
 				+ LANCER_FW_DOWNLOAD_CHUNK;
-	flash_cmd.va = dma_alloc_coherent(&adapter->pdev->dev, flash_cmd.size,
+	flash_cmd.va = dma_alloc_coherent(dev, flash_cmd.size,
 					  &flash_cmd.dma, GFP_KERNEL);
 	if (!flash_cmd.va) {
 		status = -ENOMEM;
@@ -4137,33 +4136,26 @@ static int lancer_fw_download(struct be_adapter *adapter,
 						 &add_status);
 	}
 
-	dma_free_coherent(&adapter->pdev->dev, flash_cmd.size, flash_cmd.va,
-			  flash_cmd.dma);
+	dma_free_coherent(dev, flash_cmd.size, flash_cmd.va, flash_cmd.dma);
 	if (status) {
-		dev_err(&adapter->pdev->dev,
-			"Firmware load error. "
-			"Status code: 0x%x Additional Status: 0x%x\n",
-			status, add_status);
+		dev_err(dev, "Firmware load error\n");
 		goto lancer_fw_exit;
 	}
 
+	dev_info(dev, "Firmware flashed successfully\n");
+
 	if (change_status == LANCER_FW_RESET_NEEDED) {
-		dev_info(&adapter->pdev->dev,
-			 "Resetting adapter to activate new FW\n");
+		dev_info(dev, "Resetting adapter to activate new FW\n");
 		status = lancer_physdev_ctrl(adapter,
 					     PHYSDEV_CONTROL_FW_RESET_MASK);
 		if (status) {
-			dev_err(&adapter->pdev->dev,
-				"Adapter busy for FW reset.\n"
-				"New FW will not be active.\n");
+			dev_err(dev, "Adapter busy, could not reset FW\n");
+			dev_err(dev, "Reboot server to activate new FW\n");
 			goto lancer_fw_exit;
 		}
 	} else if (change_status != LANCER_NO_RESET_NEEDED) {
-		dev_err(&adapter->pdev->dev,
-			"System reboot required for new FW to be active\n");
+		dev_info(dev, "Reboot server to activate new FW\n");
 	}
-
-	dev_info(&adapter->pdev->dev, "Firmware flashed successfully\n");
 lancer_fw_exit:
 	return status;
 }
-- 
1.7.1
