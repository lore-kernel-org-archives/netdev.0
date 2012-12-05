From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/2 net-next] cnic: Reset iSCSI EQ during shutdown.
Date: Wed, 5 Dec 2012 12:10:14 -0800
Message-ID: <1354738215-6644-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3813 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752131Ab2LETzD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2012 14:55:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without the reset, reloading the cnic driver can cause the iSCSI
Event Queue to be out of sync with the driver and cause intermittent
crash.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Acked-by: Ariel Elior <ariele@broadcom.com>
---
 .../net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h    |    5 +++++
 drivers/net/ethernet/broadcom/cnic.c               |   19 +++++++++++++++++++
 2 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h
index 620fe93..60a83ad 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h
@@ -23,6 +23,11 @@
 	(IRO[159].base + ((funcId) * IRO[159].m1))
 #define CSTORM_FUNC_EN_OFFSET(funcId) \
 	(IRO[149].base + ((funcId) * IRO[149].m1))
+#define CSTORM_HC_SYNC_LINE_INDEX_E1X_OFFSET(hcIndex, sbId) \
+	(IRO[139].base + ((hcIndex) * IRO[139].m1) + ((sbId) * IRO[139].m2))
+#define CSTORM_HC_SYNC_LINE_INDEX_E2_OFFSET(hcIndex, sbId) \
+	(IRO[138].base + (((hcIndex)>>2) * IRO[138].m1) + (((hcIndex)&3) \
+	* IRO[138].m2) + ((sbId) * IRO[138].m3))
 #define CSTORM_IGU_MODE_OFFSET (IRO[157].base)
 #define CSTORM_ISCSI_CQ_SIZE_OFFSET(pfId) \
 	(IRO[316].base + ((pfId) * IRO[316].m1))
diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index cc8434f..2c1f66d 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -5344,8 +5344,27 @@ static void cnic_stop_bnx2_hw(struct cnic_dev *dev)
 static void cnic_stop_bnx2x_hw(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
+	u32 hc_index = HC_INDEX_ISCSI_EQ_CONS;
+	u32 sb_id = cp->status_blk_num;
+	u32 idx_off, syn_off;
 
 	cnic_free_irq(dev);
+
+	if (BNX2X_CHIP_IS_E2_PLUS(cp->chip_id)) {
+		idx_off = offsetof(struct hc_status_block_e2, index_values) +
+			  (hc_index * sizeof(u16));
+
+		syn_off = CSTORM_HC_SYNC_LINE_INDEX_E2_OFFSET(hc_index, sb_id);
+	} else {
+		idx_off = offsetof(struct hc_status_block_e1x, index_values) +
+			  (hc_index * sizeof(u16));
+
+		syn_off = CSTORM_HC_SYNC_LINE_INDEX_E1X_OFFSET(hc_index, sb_id);
+	}
+	CNIC_WR16(dev, BAR_CSTRORM_INTMEM + syn_off, 0);
+	CNIC_WR16(dev, BAR_CSTRORM_INTMEM + CSTORM_STATUS_BLOCK_OFFSET(sb_id) +
+		  idx_off, 0);
+
 	*cp->kcq1.hw_prod_idx_ptr = 0;
 	CNIC_WR(dev, BAR_CSTRORM_INTMEM +
 		CSTORM_ISCSI_EQ_CONS_OFFSET(cp->pfid, 0), 0);
-- 
1.7.1
