From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 4/5] cnic: Allocate kcq resource only on
 devices that support FCoE.
Date: Sat, 8 Sep 2012 09:01:04 -0700
Message-ID: <1347120065-26492-4-git-send-email-mchan@broadcom.com>
References: <1347120065-26492-1-git-send-email-mchan@broadcom.com>
 <1347120065-26492-2-git-send-email-mchan@broadcom.com>
 <1347120065-26492-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2169 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754812Ab2IHPsV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Sep 2012 11:48:21 -0400
In-Reply-To: <1347120065-26492-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To save memory and to exit IRQ loop quicker on devices that don't support
FCoE.

Reviewed-by: Eddie Wai <eddie.wai@broadcom.com>
Reviewed-by: Bhanu Prakash Gollapudi <bprakash@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c |    7 +++----
 drivers/net/ethernet/broadcom/cnic.h |    4 ++++
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index ac08b8e..c223314 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -1288,7 +1288,7 @@ static int cnic_alloc_bnx2x_resc(struct cnic_dev *dev)
 	if (ret)
 		goto error;
 
-	if (BNX2X_CHIP_IS_E2_PLUS(cp->chip_id)) {
+	if (CNIC_SUPPORTS_FCOE(cp)) {
 		ret = cnic_alloc_kcq(dev, &cp->kcq2, true);
 		if (ret)
 			goto error;
@@ -3130,7 +3130,7 @@ static void cnic_service_bnx2x_bh(unsigned long data)
 		CNIC_WR16(dev, cp->kcq1.io_addr,
 			  cp->kcq1.sw_prod_idx + MAX_KCQ_IDX);
 
-		if (!BNX2X_CHIP_IS_E2_PLUS(cp->chip_id)) {
+		if (cp->ethdev->drv_state & CNIC_DRV_STATE_NO_FCOE) {
 			cp->arm_int(dev, status_idx);
 			break;
 		}
@@ -5516,8 +5516,7 @@ static struct cnic_dev *init_bnx2x_cnic(struct net_device *dev)
 
 	if (!(ethdev->drv_state & CNIC_DRV_STATE_NO_ISCSI))
 		cdev->max_iscsi_conn = ethdev->max_iscsi_conn;
-	if (BNX2X_CHIP_IS_E2_PLUS(cp->chip_id) &&
-	    !(ethdev->drv_state & CNIC_DRV_STATE_NO_FCOE))
+	if (CNIC_SUPPORTS_FCOE(cp))
 		cdev->max_fcoe_conn = ethdev->max_fcoe_conn;
 
 	if (cdev->max_fcoe_conn > BNX2X_FCOE_NUM_CONNECTIONS)
diff --git a/drivers/net/ethernet/broadcom/cnic.h b/drivers/net/ethernet/broadcom/cnic.h
index 9643e3a..148604c 100644
--- a/drivers/net/ethernet/broadcom/cnic.h
+++ b/drivers/net/ethernet/broadcom/cnic.h
@@ -475,6 +475,10 @@ struct bnx2x_bd_chain_next {
 	  MAX_STAT_COUNTER_ID_E1))
 #endif
 
+#define CNIC_SUPPORTS_FCOE(cp)					\
+	(BNX2X_CHIP_IS_E2_PLUS((cp)->chip_id) &&		\
+	 !((cp)->ethdev->drv_state & CNIC_DRV_STATE_NO_FCOE))
+
 #define CNIC_RAMROD_TMO			(HZ / 4)
 
 #endif
-- 
1.7.1
