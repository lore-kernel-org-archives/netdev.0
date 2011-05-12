From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next-2.6 1/2] be2net: handle signal reception while waiting for POST
Date: Thu, 12 May 2011 11:41:02 +0530
Message-ID: <dbce599d-9729-4dff-8d60-932efb56400d@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:37713 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755406Ab1ELGHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 02:07:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If schedule_timeout() returns prematurely (due to a signal), abort polling and return an error.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be_cmds.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 5fedc27..bff41ed 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -375,23 +375,26 @@ int be_cmd_POST(struct be_adapter *adapter)
 {
 	u16 stage;
 	int status, timeout = 0;
+	struct device *dev = &adapter->pdev->dev;
 
 	do {
 		status = be_POST_stage_get(adapter, &stage);
 		if (status) {
-			dev_err(&adapter->pdev->dev, "POST error; stage=0x%x\n",
-				stage);
+			dev_err(dev, "POST error; stage=0x%x\n", stage);
 			return -1;
 		} else if (stage != POST_STAGE_ARMFW_RDY) {
 			set_current_state(TASK_INTERRUPTIBLE);
-			schedule_timeout(2 * HZ);
+			if (schedule_timeout(2 * HZ)) {
+				dev_err(dev, "Waiting for POST aborted\n");
+				return -EINTR;
+			}
 			timeout += 2;
 		} else {
 			return 0;
 		}
 	} while (timeout < 40);
 
-	dev_err(&adapter->pdev->dev, "POST timeout; stage=0x%x\n", stage);
+	dev_err(dev, "POST timeout; stage=0x%x\n", stage);
 	return -1;
 }
 
-- 
1.7.4

