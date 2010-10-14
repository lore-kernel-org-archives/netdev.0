From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/8 net-next] cnic: Add common cnic_request_irq()
Date: Wed, 13 Oct 2010 17:06:44 -0700
Message-ID: <1287014811-10979-2-git-send-email-mchan@broadcom.com>
References: <1287014811-10979-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1626 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752935Ab0JNBD4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Oct 2010 21:03:56 -0400
In-Reply-To: <1287014811-10979-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

to reduce some duplicate code.  Also, use tasklet_kill() in
cnic_free_irq() to wait for the cnic_irq_task to complete.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |   32 ++++++++++++++++++++------------
 1 files changed, 20 insertions(+), 12 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 27449bf..0fab720 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -3428,11 +3428,24 @@ static void cnic_free_irq(struct cnic_dev *dev)
 
 	if (ethdev->drv_state & CNIC_DRV_STATE_USING_MSIX) {
 		cp->disable_int_sync(dev);
-		tasklet_disable(&cp->cnic_irq_task);
+		tasklet_kill(&cp->cnic_irq_task);
 		free_irq(ethdev->irq_arr[0].vector, dev);
 	}
 }
 
+static int cnic_request_irq(struct cnic_dev *dev)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	struct cnic_eth_dev *ethdev = cp->ethdev;
+	int err;
+
+	err = request_irq(ethdev->irq_arr[0].vector, cnic_irq, 0, "cnic", dev);
+	if (err)
+		tasklet_disable(&cp->cnic_irq_task);
+
+	return err;
+}
+
 static int cnic_init_bnx2_irq(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
@@ -3453,12 +3466,10 @@ static int cnic_init_bnx2_irq(struct cnic_dev *dev)
 		cp->last_status_idx = cp->status_blk.bnx2->status_idx;
 		tasklet_init(&cp->cnic_irq_task, cnic_service_bnx2_msix,
 			     (unsigned long) dev);
-		err = request_irq(ethdev->irq_arr[0].vector, cnic_irq, 0,
-				  "cnic", dev);
-		if (err) {
-			tasklet_disable(&cp->cnic_irq_task);
+		err = cnic_request_irq(dev);
+		if (err)
 			return err;
-		}
+
 		while (cp->status_blk.bnx2->status_completion_producer_index &&
 		       i < 10) {
 			CNIC_WR(dev, BNX2_HC_COALESCE_NOW,
@@ -3860,12 +3871,9 @@ static int cnic_init_bnx2x_irq(struct cnic_dev *dev)
 
 	tasklet_init(&cp->cnic_irq_task, cnic_service_bnx2x_bh,
 		     (unsigned long) dev);
-	if (ethdev->drv_state & CNIC_DRV_STATE_USING_MSIX) {
-		err = request_irq(ethdev->irq_arr[0].vector, cnic_irq, 0,
-				  "cnic", dev);
-		if (err)
-			tasklet_disable(&cp->cnic_irq_task);
-	}
+	if (ethdev->drv_state & CNIC_DRV_STATE_USING_MSIX)
+		err = cnic_request_irq(dev);
+
 	return err;
 }
 
-- 
1.6.4.GIT


