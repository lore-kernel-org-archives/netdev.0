From: Sathya Perla <sathyap@serverengines.com>
Subject: [net-next-2.6 PATCH 5/5] be2net: delete unnecessary code from
	be_cmd_POST()
Date: Tue, 28 Jul 2009 14:23:30 +0530
Message-ID: <20090728085330.GA5025@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:4748 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752187AbZG1Ixk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 04:53:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the driver loads the POST stage of the card is expected to be
POST_STAGE_ARMFW_RDY.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_cmds.c |   45 +++---------------------------------------
 1 files changed, 4 insertions(+), 41 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index ebf65c7..de10773 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -227,54 +227,17 @@ static int be_POST_stage_get(struct be_adapter *adapter, u16 *stage)
 		return 0;
 }
 
-static int be_POST_stage_poll(struct be_adapter *adapter, u16 poll_stage)
-{
-	u16 stage, cnt, error;
-	for (cnt = 0; cnt < 5000; cnt++) {
-		error = be_POST_stage_get(adapter, &stage);
-		if (error)
-			return -1;
-
-		if (stage == poll_stage)
-			break;
-		udelay(1000);
-	}
-	if (stage != poll_stage)
-		return -1;
-	return 0;
-}
-
-
 int be_cmd_POST(struct be_adapter *adapter)
 {
 	u16 stage, error;
 
 	error = be_POST_stage_get(adapter, &stage);
-	if (error)
-		goto err;
-
-	if (stage == POST_STAGE_ARMFW_RDY)
-		return 0;
-
-	if (stage != POST_STAGE_AWAITING_HOST_RDY)
-		goto err;
-
-	/* On awaiting host rdy, reset and again poll on awaiting host rdy */
-	iowrite32(POST_STAGE_BE_RESET, adapter->csr + MPU_EP_SEMAPHORE_OFFSET);
-	error = be_POST_stage_poll(adapter, POST_STAGE_AWAITING_HOST_RDY);
-	if (error)
-		goto err;
-
-	/* Now kickoff POST and poll on armfw ready */
-	iowrite32(POST_STAGE_HOST_RDY, adapter->csr + MPU_EP_SEMAPHORE_OFFSET);
-	error = be_POST_stage_poll(adapter, POST_STAGE_ARMFW_RDY);
-	if (error)
-		goto err;
+	if (error || stage != POST_STAGE_ARMFW_RDY) {
+		dev_err(&adapter->pdev->dev, "POST failed.\n");
+		return -1;
+	}
 
 	return 0;
-err:
-	printk(KERN_WARNING DRV_NAME ": ERROR, stage=%d\n", stage);
-	return -1;
 }
 
 static inline void *embedded_payload(struct be_mcc_wrb *wrb)
-- 
1.6.0.4

