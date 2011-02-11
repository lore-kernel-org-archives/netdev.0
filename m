From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 13/15] be2net: gracefully handle situations when
 UE is detected
Date: Fri, 11 Feb 2011 17:38:17 -0600
Message-ID: <20110211233817.GA18491@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:51244 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758107Ab1BKXiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 18:38:25 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid accessing the hardware when UE is detected.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be_cmds.c |   15 +++++++++++++++
 drivers/net/benet/be_main.c |    1 +
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 8fa9a70..619ebc2 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -23,6 +23,12 @@ static void be_mcc_notify(struct be_adapter *adapter)
 	struct be_queue_info *mccq = &adapter->mcc_obj.q;
 	u32 val = 0;
 
+	if (adapter->eeh_err) {
+		dev_info(&adapter->pdev->dev,
+			"Error in Card Detected! Cannot issue commands\n");
+		return;
+	}
+
 	val |= mccq->id & DB_MCCQ_RING_ID_MASK;
 	val |= 1 << DB_MCCQ_NUM_POSTED_SHIFT;
 
@@ -217,6 +223,9 @@ static int be_mcc_wait_compl(struct be_adapter *adapter)
 	int i, num, status = 0;
 	struct be_mcc_obj *mcc_obj = &adapter->mcc_obj;
 
+	if (adapter->eeh_err)
+		return -EIO;
+
 	for (i = 0; i < mcc_timeout; i++) {
 		num = be_process_mcc(adapter, &status);
 		if (num)
@@ -246,6 +255,12 @@ static int be_mbox_db_ready_wait(struct be_adapter *adapter, void __iomem *db)
 	int msecs = 0;
 	u32 ready;
 
+	if (adapter->eeh_err) {
+		dev_err(&adapter->pdev->dev,
+			"Error detected in card.Cannot issue commands\n");
+		return -EIO;
+	}
+
 	do {
 		ready = ioread32(db);
 		if (ready == 0xffffffff) {
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 7e83c06..1f5e342 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1827,6 +1827,7 @@ void be_detect_dump_ue(struct be_adapter *adapter)
 
 	if (ue_status_lo || ue_status_hi) {
 		adapter->ue_detected = true;
+		adapter->eeh_err = true;
 		dev_err(&adapter->pdev->dev, "UE Detected!!\n");
 	}
 
-- 
1.7.1

