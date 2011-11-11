From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 3/4] be2net: don't log more than one error on detecting EEH/UE errors
Date: Fri, 11 Nov 2011 10:47:59 +0530
Message-ID: <1320988680-7842-4-git-send-email-sathya.perla@emulex.com>
References: <1320988680-7842-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:4695 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751107Ab1KKFUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2011 00:20:35 -0500
In-Reply-To: <1320988680-7842-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we're spamming error messages each time a FW cmd call is made
while in EEH/UE error state. One log msg on error detection is enough.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |   15 +++------------
 drivers/net/ethernet/emulex/benet/be_main.c |    3 ++-
 2 files changed, 5 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index c5912c4..94cd77c 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -31,11 +31,8 @@ static void be_mcc_notify(struct be_adapter *adapter)
 	struct be_queue_info *mccq = &adapter->mcc_obj.q;
 	u32 val = 0;
 
-	if (adapter->eeh_err) {
-		dev_info(&adapter->pdev->dev,
-			"Error in Card Detected! Cannot issue commands\n");
+	if (adapter->eeh_err)
 		return;
-	}
 
 	val |= mccq->id & DB_MCCQ_RING_ID_MASK;
 	val |= 1 << DB_MCCQ_NUM_POSTED_SHIFT;
@@ -298,19 +295,13 @@ static int be_mbox_db_ready_wait(struct be_adapter *adapter, void __iomem *db)
 	int msecs = 0;
 	u32 ready;
 
-	if (adapter->eeh_err) {
-		dev_err(&adapter->pdev->dev,
-			"Error detected in card.Cannot issue commands\n");
+	if (adapter->eeh_err)
 		return -EIO;
-	}
 
 	do {
 		ready = ioread32(db);
-		if (ready == 0xffffffff) {
-			dev_err(&adapter->pdev->dev,
-				"pci slot disconnected\n");
+		if (ready == 0xffffffff)
 			return -1;
-		}
 
 		ready &= MPU_MAILBOX_DB_RDY_MASK;
 		if (ready)
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 99da07f..0e97b6d 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2007,7 +2007,8 @@ void be_detect_dump_ue(struct be_adapter *adapter)
 		sliport_status & SLIPORT_STATUS_ERR_MASK) {
 		adapter->ue_detected = true;
 		adapter->eeh_err = true;
-		dev_err(&adapter->pdev->dev, "UE Detected!!\n");
+		dev_err(&adapter->pdev->dev,
+			"Unrecoverable error in the card\n");
 	}
 
 	if (ue_lo) {
-- 
1.7.4
