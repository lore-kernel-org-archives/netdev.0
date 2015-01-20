From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 4/7] be2net: add a log message for POST timeout in Lancer
Date: Tue, 20 Jan 2015 03:51:46 -0500
Message-ID: <1421743909-14716-5-git-send-email-sathya.perla@emulex.com>
References: <1421743909-14716-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.emulex.com ([138.239.224.99]:11712 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752144AbbATItH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 03:49:07 -0500
In-Reply-To: <1421743909-14716-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

This patch adds a log message in case of POST timeout in Lancer to
help debugging failure cases. It also logs sliport_status register value in
case of POST timeout.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 9772f49..2021eb0 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -573,7 +573,7 @@ static int lancer_wait_ready(struct be_adapter *adapter)
 {
 #define SLIPORT_READY_TIMEOUT 30
 	u32 sliport_status;
-	int status = 0, i;
+	int i;
 
 	for (i = 0; i < SLIPORT_READY_TIMEOUT; i++) {
 		sliport_status = ioread32(adapter->db + SLIPORT_STATUS_OFFSET);
@@ -584,9 +584,9 @@ static int lancer_wait_ready(struct be_adapter *adapter)
 	}
 
 	if (i == SLIPORT_READY_TIMEOUT)
-		status = -1;
+		return sliport_status ? : -1;
 
-	return status;
+	return 0;
 }
 
 static bool lancer_provisioning_error(struct be_adapter *adapter)
@@ -624,7 +624,7 @@ int lancer_test_and_set_rdy_state(struct be_adapter *adapter)
 			iowrite32(SLI_PORT_CONTROL_IP_MASK,
 				  adapter->db + SLIPORT_CONTROL_OFFSET);
 
-			/* check adapter has corrected the error */
+			/* check if adapter has corrected the error */
 			status = lancer_wait_ready(adapter);
 			sliport_status = ioread32(adapter->db +
 						  SLIPORT_STATUS_OFFSET);
@@ -655,7 +655,11 @@ int be_fw_wait_ready(struct be_adapter *adapter)
 
 	if (lancer_chip(adapter)) {
 		status = lancer_wait_ready(adapter);
-		return status;
+		if (status) {
+			stage = status;
+			goto err;
+		}
+		return 0;
 	}
 
 	do {
@@ -671,7 +675,8 @@ int be_fw_wait_ready(struct be_adapter *adapter)
 		timeout += 2;
 	} while (timeout < 60);
 
-	dev_err(dev, "POST timeout; stage=0x%x\n", stage);
+err:
+	dev_err(dev, "POST timeout; stage=%#x\n", stage);
 	return -1;
 }
 
-- 
2.2.0
