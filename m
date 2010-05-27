From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH] cnic: Fix context memory init. on 5709.
Date: Thu, 27 May 2010 13:24:18 -0700
Message-ID: <1274991858-6201-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2317 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756752Ab0E0UWj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 May 2010 16:22:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to zero context memory on 5709 in the function cnic_init_context().
Without this, iscsid restart on 5709 will not work because of stale data.
TX context blocks should not be initialized by cnic_init_context() because
of the special remapping on 5709.

Update version to 2.1.2.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c    |   10 +++-------
 drivers/net/cnic_if.h |    4 ++--
 2 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index be90d35..fe92566 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -3367,13 +3367,9 @@ static int cnic_cm_shutdown(struct cnic_dev *dev)
 
 static void cnic_init_context(struct cnic_dev *dev, u32 cid)
 {
-	struct cnic_local *cp = dev->cnic_priv;
 	u32 cid_addr;
 	int i;
 
-	if (CHIP_NUM(cp) == CHIP_NUM_5709)
-		return;
-
 	cid_addr = GET_CID_ADDR(cid);
 
 	for (i = 0; i < CTX_SIZE; i += 4)
@@ -3530,14 +3526,11 @@ static void cnic_init_bnx2_tx_ring(struct cnic_dev *dev)
 
 	sb_id = cp->status_blk_num;
 	tx_cid = 20;
-	cnic_init_context(dev, tx_cid);
-	cnic_init_context(dev, tx_cid + 1);
 	cp->tx_cons_ptr = &s_blk->status_tx_quick_consumer_index2;
 	if (ethdev->drv_state & CNIC_DRV_STATE_USING_MSIX) {
 		struct status_block_msix *sblk = cp->status_blk.bnx2;
 
 		tx_cid = TX_TSS_CID + sb_id - 1;
-		cnic_init_context(dev, tx_cid);
 		CNIC_WR(dev, BNX2_TSCH_TSS_CFG, (sb_id << 24) |
 			(TX_TSS_CID << 7));
 		cp->tx_cons_ptr = &sblk->status_tx_quick_consumer_index;
@@ -3556,6 +3549,9 @@ static void cnic_init_bnx2_tx_ring(struct cnic_dev *dev)
 		offset2 = BNX2_L2CTX_TBDR_BHADDR_HI_XI;
 		offset3 = BNX2_L2CTX_TBDR_BHADDR_LO_XI;
 	} else {
+		cnic_init_context(dev, tx_cid);
+		cnic_init_context(dev, tx_cid + 1);
+
 		offset0 = BNX2_L2CTX_TYPE;
 		offset1 = BNX2_L2CTX_CMD_TYPE;
 		offset2 = BNX2_L2CTX_TBDR_BHADDR_HI;
diff --git a/drivers/net/cnic_if.h b/drivers/net/cnic_if.h
index 110c620..0c55177 100644
--- a/drivers/net/cnic_if.h
+++ b/drivers/net/cnic_if.h
@@ -12,8 +12,8 @@
 #ifndef CNIC_IF_H
 #define CNIC_IF_H
 
-#define CNIC_MODULE_VERSION	"2.1.1"
-#define CNIC_MODULE_RELDATE	"Feb 22, 2010"
+#define CNIC_MODULE_VERSION	"2.1.2"
+#define CNIC_MODULE_RELDATE	"May 26, 2010"
 
 #define CNIC_ULP_RDMA		0
 #define CNIC_ULP_ISCSI		1
-- 
1.6.4.GIT


