From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next-2.6 1/2] be2net: handle signal reception while waiting for POST
Date: Fri, 13 May 2011 11:02:15 +0530
Message-ID: <e99a88fd-b35f-4c23-92b8-c61400501257@exht1.ad.emulex.com>
References: <1305264736-18358-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:53988 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755916Ab1EMF2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 01:28:46 -0400
In-Reply-To: <1305264736-18358-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If waiting on POST returns prematurely (due to a signal), abort polling and return an error.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be_cmds.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 0dbb4cb..d558b90 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -376,23 +376,25 @@ int be_cmd_POST(struct be_adapter *adapter)
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
-			set_current_state(TASK_INTERRUPTIBLE);
-			schedule_timeout(2 * HZ);
+			if (msleep_interruptible(2000)) {
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

