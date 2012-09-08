From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 3/5] cnic: Add function pointers to arm IRQ for
 different devices.
Date: Sat, 8 Sep 2012 09:01:03 -0700
Message-ID: <1347120065-26492-3-git-send-email-mchan@broadcom.com>
References: <1347120065-26492-1-git-send-email-mchan@broadcom.com>
 <1347120065-26492-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3150 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754953Ab2IHPsV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Sep 2012 11:48:21 -0400
In-Reply-To: <1347120065-26492-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will make it easier to exit IRQ loop and re-arm IRQ on devices that
don't support FCoE.

Reviewed-by: Eddie Wai <eddie.wai@broadcom.com>
Reviewed-by: Bhanu Prakash Gollapudi <bprakash@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c |   26 ++++++++++++++++++++++----
 drivers/net/ethernet/broadcom/cnic.h |    1 +
 2 files changed, 23 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 38be4d9..ac08b8e 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -3078,6 +3078,22 @@ static void cnic_ack_bnx2x_e2_msix(struct cnic_dev *dev)
 			IGU_INT_DISABLE, 0);
 }
 
+static void cnic_arm_bnx2x_msix(struct cnic_dev *dev, u32 idx)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+
+	cnic_ack_bnx2x_int(dev, cp->bnx2x_igu_sb_id, CSTORM_ID, idx,
+			   IGU_INT_ENABLE, 1);
+}
+
+static void cnic_arm_bnx2x_e2_msix(struct cnic_dev *dev, u32 idx)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+
+	cnic_ack_igu_sb(dev, cp->bnx2x_igu_sb_id, IGU_SEG_ACCESS_DEF, idx,
+			IGU_INT_ENABLE, 1);
+}
+
 static u32 cnic_service_bnx2x_kcq(struct cnic_dev *dev, struct kcq_info *info)
 {
 	u32 last_status = *info->status_idx_ptr;
@@ -3115,8 +3131,7 @@ static void cnic_service_bnx2x_bh(unsigned long data)
 			  cp->kcq1.sw_prod_idx + MAX_KCQ_IDX);
 
 		if (!BNX2X_CHIP_IS_E2_PLUS(cp->chip_id)) {
-			cnic_ack_bnx2x_int(dev, cp->bnx2x_igu_sb_id, USTORM_ID,
-					   status_idx, IGU_INT_ENABLE, 1);
+			cp->arm_int(dev, status_idx);
 			break;
 		}
 
@@ -5520,10 +5535,13 @@ static struct cnic_dev *init_bnx2x_cnic(struct net_device *dev)
 	cp->stop_cm = cnic_cm_stop_bnx2x_hw;
 	cp->enable_int = cnic_enable_bnx2x_int;
 	cp->disable_int_sync = cnic_disable_bnx2x_int_sync;
-	if (BNX2X_CHIP_IS_E2_PLUS(cp->chip_id))
+	if (BNX2X_CHIP_IS_E2_PLUS(cp->chip_id)) {
 		cp->ack_int = cnic_ack_bnx2x_e2_msix;
-	else
+		cp->arm_int = cnic_arm_bnx2x_e2_msix;
+	} else {
 		cp->ack_int = cnic_ack_bnx2x_msix;
+		cp->arm_int = cnic_arm_bnx2x_msix;
+	}
 	cp->close_conn = cnic_close_bnx2x_conn;
 	return cdev;
 }
diff --git a/drivers/net/ethernet/broadcom/cnic.h b/drivers/net/ethernet/broadcom/cnic.h
index 3032809..9643e3a 100644
--- a/drivers/net/ethernet/broadcom/cnic.h
+++ b/drivers/net/ethernet/broadcom/cnic.h
@@ -334,6 +334,7 @@ struct cnic_local {
 	void			(*enable_int)(struct cnic_dev *);
 	void			(*disable_int_sync)(struct cnic_dev *);
 	void			(*ack_int)(struct cnic_dev *);
+	void			(*arm_int)(struct cnic_dev *, u32 index);
 	void			(*close_conn)(struct cnic_sock *, u32 opcode);
 };
 
-- 
1.7.1
