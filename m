From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-2.6 2/2] cnic: Fix lost interrupt on bnx2x
Date: Wed, 2 Mar 2011 15:00:50 -0800
Message-ID: <1299106850-23645-2-git-send-email-mchan@broadcom.com>
References: <1299106850-23645-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4693 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755955Ab1CBXzI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 18:55:08 -0500
In-Reply-To: <1299106850-23645-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We service 2 queues (kcq1 and kcq2) in cnic_service_bnx2x_bh().  If
the status block index has changed when servicing the kcq2, we must
go back and check kcq1.  The latest status block index will be used
to acknowledge the interrupt, and without looping back to check kcq1,
we may miss events on kcq1.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |   25 +++++++++++++++++--------
 1 files changed, 17 insertions(+), 8 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index b0d9e4a..302be4a 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -2914,26 +2914,35 @@ static void cnic_service_bnx2x_bh(unsigned long data)
 {
 	struct cnic_dev *dev = (struct cnic_dev *) data;
 	struct cnic_local *cp = dev->cnic_priv;
-	u32 status_idx;
+	u32 status_idx, new_status_idx;
 
 	if (unlikely(!test_bit(CNIC_F_CNIC_UP, &dev->flags)))
 		return;
 
-	status_idx = cnic_service_bnx2x_kcq(dev, &cp->kcq1);
+	while (1) {
+		status_idx = cnic_service_bnx2x_kcq(dev, &cp->kcq1);
 
-	CNIC_WR16(dev, cp->kcq1.io_addr, cp->kcq1.sw_prod_idx + MAX_KCQ_IDX);
+		CNIC_WR16(dev, cp->kcq1.io_addr,
+			  cp->kcq1.sw_prod_idx + MAX_KCQ_IDX);
 
-	if (BNX2X_CHIP_IS_E2(cp->chip_id)) {
-		status_idx = cnic_service_bnx2x_kcq(dev, &cp->kcq2);
+		if (!BNX2X_CHIP_IS_E2(cp->chip_id)) {
+			cnic_ack_bnx2x_int(dev, cp->bnx2x_igu_sb_id, USTORM_ID,
+					   status_idx, IGU_INT_ENABLE, 1);
+			break;
+		}
+
+		new_status_idx = cnic_service_bnx2x_kcq(dev, &cp->kcq2);
+
+		if (new_status_idx != status_idx)
+			continue;
 
 		CNIC_WR16(dev, cp->kcq2.io_addr, cp->kcq2.sw_prod_idx +
 			  MAX_KCQ_IDX);
 
 		cnic_ack_igu_sb(dev, cp->bnx2x_igu_sb_id, IGU_SEG_ACCESS_DEF,
 				status_idx, IGU_INT_ENABLE, 1);
-	} else {
-		cnic_ack_bnx2x_int(dev, cp->bnx2x_igu_sb_id, USTORM_ID,
-				   status_idx, IGU_INT_ENABLE, 1);
+
+		break;
 	}
 }
 
-- 
1.6.4.GIT


