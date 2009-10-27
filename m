From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH] cnic: Fix L2CTX_STATUSB_NUM offset in context memory.
Date: Tue, 27 Oct 2009 08:58:48 -0800
Message-ID: <1256662728-21864-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benli@broadcom.com
To: davem@davmloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2467 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756069AbZJ0Qww (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Oct 2009 12:52:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The BNX2_L2CTX_STATUSB_NUM definition needs to be changed to match
the recent firmware update:

commit 078b0735881c7969aaf21469f3577831cddd9f8c
bnx2: Update firmware to 5.0.0.j3.

Without the fix, bnx2 can crash intermittently in bnx2_rx_int() when
iSCSI is enabled.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/bnx2.h |    9 ++++++---
 drivers/net/cnic.c |    6 +++---
 2 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 6c7f795..a4d8340 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -361,9 +361,12 @@ struct l2_fhdr {
 #define BNX2_L2CTX_CTX_TYPE_CTX_BD_CHN_TYPE_VALUE	 (1<<28)
 
 #define BNX2_L2CTX_HOST_BDIDX				0x00000004
-#define BNX2_L2CTX_STATUSB_NUM_SHIFT			 16
-#define BNX2_L2CTX_STATUSB_NUM(sb_id)			 \
-	(((sb_id) > 0) ? (((sb_id) + 7) << BNX2_L2CTX_STATUSB_NUM_SHIFT) : 0)
+#define BNX2_L2CTX_L5_STATUSB_NUM_SHIFT			 16
+#define BNX2_L2CTX_L2_STATUSB_NUM_SHIFT			 24
+#define BNX2_L2CTX_L5_STATUSB_NUM(sb_id)		\
+	(((sb_id) > 0) ? (((sb_id) + 7) << BNX2_L2CTX_L5_STATUSB_NUM_SHIFT) : 0)
+#define BNX2_L2CTX_L2_STATUSB_NUM(sb_id)		\
+	(((sb_id) > 0) ? (((sb_id) + 7) << BNX2_L2CTX_L2_STATUSB_NUM_SHIFT) : 0)
 #define BNX2_L2CTX_HOST_BSEQ				0x00000008
 #define BNX2_L2CTX_NX_BSEQ				0x0000000c
 #define BNX2_L2CTX_NX_BDHADDR_HI			0x00000010
diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 46c87ec..3bf1b04 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -2264,9 +2264,9 @@ static void cnic_init_bnx2_rx_ring(struct cnic_dev *dev)
 	cnic_ctx_wr(dev, cid_addr, BNX2_L2CTX_CTX_TYPE, val);
 
 	if (sb_id == 0)
-		val = 2 << BNX2_L2CTX_STATUSB_NUM_SHIFT;
+		val = 2 << BNX2_L2CTX_L2_STATUSB_NUM_SHIFT;
 	else
-		val = BNX2_L2CTX_STATUSB_NUM(sb_id);
+		val = BNX2_L2CTX_L2_STATUSB_NUM(sb_id);
 	cnic_ctx_wr(dev, cid_addr, BNX2_L2CTX_HOST_BDIDX, val);
 
 	rxbd = (struct rx_bd *) (cp->l2_ring + BCM_PAGE_SIZE);
@@ -2423,7 +2423,7 @@ static int cnic_start_bnx2_hw(struct cnic_dev *dev)
 	cp->int_num = 0;
 	if (ethdev->drv_state & CNIC_DRV_STATE_USING_MSIX) {
 		u32 sb_id = cp->status_blk_num;
-		u32 sb = BNX2_L2CTX_STATUSB_NUM(sb_id);
+		u32 sb = BNX2_L2CTX_L5_STATUSB_NUM(sb_id);
 
 		cp->int_num = sb_id << BNX2_PCICFG_INT_ACK_CMD_INT_NUM_SHIFT;
 		cnic_ctx_wr(dev, cp->kwq_cid_addr, L5_KRNLQ_HOST_QIDX, sb);
-- 
1.6.4.GIT


