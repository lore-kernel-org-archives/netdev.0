From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next 1/2] enic: handle spurious error interrupt
Date: Thu,  1 Oct 2015 14:18:46 +0530
Message-ID: <1443689327-15776-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:51930 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750954AbbJAItJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2015 04:49:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some of the enic adaptors are know to generate spurious interrupts. When
error interrupt is generated, driver just resets the device. This patch
resets the device only when an error is occurred.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 3352d02..0b54429 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -178,13 +178,15 @@ static int enic_wq_service(struct vnic_dev *vdev, struct cq_desc *cq_desc,
 	return 0;
 }
 
-static void enic_log_q_error(struct enic *enic)
+static bool enic_log_q_error(struct enic *enic)
 {
 	unsigned int i;
 	u32 error_status;
+	bool err = false;
 
 	for (i = 0; i < enic->wq_count; i++) {
 		error_status = vnic_wq_error_status(&enic->wq[i]);
+		err |= error_status;
 		if (error_status)
 			netdev_err(enic->netdev, "WQ[%d] error_status %d\n",
 				i, error_status);
@@ -192,10 +194,13 @@ static void enic_log_q_error(struct enic *enic)
 
 	for (i = 0; i < enic->rq_count; i++) {
 		error_status = vnic_rq_error_status(&enic->rq[i]);
+		err |= error_status;
 		if (error_status)
 			netdev_err(enic->netdev, "RQ[%d] error_status %d\n",
 				i, error_status);
 	}
+
+	return err;
 }
 
 static void enic_msglvl_check(struct enic *enic)
@@ -333,10 +338,9 @@ static irqreturn_t enic_isr_msix_err(int irq, void *data)
 
 	vnic_intr_return_all_credits(&enic->intr[intr]);
 
-	enic_log_q_error(enic);
-
-	/* schedule recovery from WQ/RQ error */
-	schedule_work(&enic->reset);
+	if (enic_log_q_error(enic))
+		/* schedule recovery from WQ/RQ error */
+		schedule_work(&enic->reset);
 
 	return IRQ_HANDLED;
 }
-- 
2.6.0
