From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/2] cnic: Convert cnic_local_flags to atomic ops.
Date: Tue, 18 May 2010 14:32:52 -0700
Message-ID: <1274218373-16324-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3037 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754062Ab0ERVbc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 May 2010 17:31:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is easier to expand the flags for other purposes because it does
not require a spin_lock.  The next bug fix patch needs a flag in
cnic_local_flags.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |    6 +++---
 drivers/net/cnic.h |    5 ++---
 2 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 4b08b18..7c6d325 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -1143,12 +1143,12 @@ static int cnic_submit_bnx2_kwqes(struct cnic_dev *dev, struct kwqe *wqes[],
 
 	spin_lock_bh(&cp->cnic_ulp_lock);
 	if (num_wqes > cnic_kwq_avail(cp) &&
-	    !(cp->cnic_local_flags & CNIC_LCL_FL_KWQ_INIT)) {
+	    !test_bit(CNIC_LCL_FL_KWQ_INIT, &cp->cnic_local_flags)) {
 		spin_unlock_bh(&cp->cnic_ulp_lock);
 		return -EAGAIN;
 	}
 
-	cp->cnic_local_flags &= ~CNIC_LCL_FL_KWQ_INIT;
+	clear_bit(CNIC_LCL_FL_KWQ_INIT, &cp->cnic_local_flags);
 
 	prod = cp->kwq_prod_idx;
 	sw_prod = prod & MAX_KWQ_IDX;
@@ -3690,7 +3690,7 @@ static int cnic_start_bnx2_hw(struct cnic_dev *dev)
 	cp->max_kwq_idx = MAX_KWQ_IDX;
 	cp->kwq_prod_idx = 0;
 	cp->kwq_con_idx = 0;
-	cp->cnic_local_flags |= CNIC_LCL_FL_KWQ_INIT;
+	set_bit(CNIC_LCL_FL_KWQ_INIT, &cp->cnic_local_flags);
 
 	if (CHIP_NUM(cp) == CHIP_NUM_5706 || CHIP_NUM(cp) == CHIP_NUM_5708)
 		cp->kwq_con_idx_ptr = &sblk->status_rx_quick_consumer_index15;
diff --git a/drivers/net/cnic.h b/drivers/net/cnic.h
index a0d853d..4422497 100644
--- a/drivers/net/cnic.h
+++ b/drivers/net/cnic.h
@@ -179,9 +179,8 @@ struct cnic_local {
 #define ULP_F_CALL_PENDING	2
 	struct cnic_ulp_ops *ulp_ops[MAX_CNIC_ULP_TYPE];
 
-	/* protected by ulp_lock */
-	u32 cnic_local_flags;
-#define	CNIC_LCL_FL_KWQ_INIT	0x00000001
+	unsigned long cnic_local_flags;
+#define	CNIC_LCL_FL_KWQ_INIT		0x0
 
 	struct cnic_dev *dev;
 
-- 
1.6.4.GIT


