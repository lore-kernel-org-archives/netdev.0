From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 08/13] bnx2x: IGU parse error cause probe
 failure
Date: Sun, 2 Dec 2012 16:05:52 +0200
Message-ID: <1354457157-4730-9-git-send-email-yuvalmin@broadcom.com>
References: <1354457157-4730-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Barak Witkowski" <barak@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2561 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753266Ab2LBOFK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Dec 2012 09:05:10 -0500
In-Reply-To: <1354457157-4730-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Barak Witkowski <barak@broadcom.com>

If IGU parse error is encountered during the probing process, the error
propagates and the probe gracefully fails (until now, such errors were ignored,
later causing mischief).

Signed-off-by: Barak Witkowski <barak@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 571508d..5ff0bcb 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -9974,7 +9974,7 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 #define IGU_FID(val)	GET_FIELD((val), IGU_REG_MAPPING_MEMORY_FID)
 #define IGU_VEC(val)	GET_FIELD((val), IGU_REG_MAPPING_MEMORY_VECTOR)
 
-static void __devinit bnx2x_get_igu_cam_info(struct bnx2x *bp)
+static int __devinit bnx2x_get_igu_cam_info(struct bnx2x *bp)
 {
 	int pfid = BP_FUNC(bp);
 	int igu_sb_id;
@@ -9991,7 +9991,7 @@ static void __devinit bnx2x_get_igu_cam_info(struct bnx2x *bp)
 		bp->igu_dsb_id =  E1HVN_MAX * FP_SB_MAX_E1x +
 			(CHIP_MODE_IS_4_PORT(bp) ? pfid : vn);
 
-		return;
+		return 0;
 	}
 
 	/* IGU in normal mode - read CAM */
@@ -10025,8 +10025,12 @@ static void __devinit bnx2x_get_igu_cam_info(struct bnx2x *bp)
 	bp->igu_sb_cnt = min_t(int, bp->igu_sb_cnt, igu_sb_cnt);
 #endif
 
-	if (igu_sb_cnt == 0)
+	if (igu_sb_cnt == 0) {
 		BNX2X_ERR("CAM configuration error\n");
+		return -EINVAL;
+	}
+
+	return 0;
 }
 
 static void __devinit bnx2x_link_settings_supported(struct bnx2x *bp,
@@ -10706,6 +10710,8 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 			if (REG_RD(bp, IGU_REG_RESET_MEMORIES)) {
 				dev_err(&bp->pdev->dev,
 					"FORCING Normal Mode failed!!!\n");
+				bnx2x_release_hw_lock(bp,
+						      HW_LOCK_RESOURCE_RESET);
 				return -EPERM;
 			}
 		}
@@ -10716,9 +10722,10 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 		} else
 			BNX2X_DEV_INFO("IGU Normal Mode\n");
 
-		bnx2x_get_igu_cam_info(bp);
-
+		rc = bnx2x_get_igu_cam_info(bp);
 		bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_RESET);
+		if (rc)
+			return rc;
 	}
 
 	/*
-- 
1.7.1
