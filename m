From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH] bnx2x: suppress repeated error messages about Max BW
Date: Fri, 12 Aug 2011 16:33:25 +0200
Message-ID: <20110812143324.5740.45824.stgit@dhcp-29-224.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dmitry@broadcom.com, vladz@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57172 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752943Ab1HLOd2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2011 10:33:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a VN is configured with invalid Max BW, the error does not have to
be logged repeatedly and fill the logs.
Warn only once when the bad configuration is detected on boot, or when
the configuration changes dynamically from good to bad.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---

 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |    5 ++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |   21 +++++++++++----------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    2 +-
 4 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index c423504..648e165 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1220,6 +1220,7 @@ struct bnx2x {
 	struct cmng_struct_per_port cmng;
 	u32			vn_weight_sum;
 	u32			mf_config[E1HVN_MAX];
+	bool			prev_max_cfg_invalid[E1HVN_MAX];
 	u32			mf2_config[E2_FUNC_MAX];
 	u32			path_has_ovlan; /* E3 */
 	u16			mf_ov;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index d724a18..a5216a9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -841,8 +841,7 @@ u16 bnx2x_get_mf_speed(struct bnx2x *bp)
 {
 	u16 line_speed = bp->link_vars.line_speed;
 	if (IS_MF(bp)) {
-		u16 maxCfg = bnx2x_extract_max_cfg(bp,
-						   bp->mf_config[BP_VN(bp)]);
+		u16 maxCfg = bnx2x_extract_max_cfg(bp, BP_VN(bp));
 
 		/* Calculate the current MAX line speed limit for the MF
 		 * devices
@@ -1153,7 +1152,7 @@ void bnx2x_update_max_mf_config(struct bnx2x *bp, u32 value)
 	/* load old values */
 	u32 mf_cfg = bp->mf_config[BP_VN(bp)];
 
-	if (value != bnx2x_extract_max_cfg(bp, mf_cfg)) {
+	if (value != bnx2x_extract_max_cfg(bp, BP_VN(bp))) {
 		/* leave all but MAX value */
 		mf_cfg &= ~FUNC_MF_CFG_MAX_BW_MASK;
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 223bfee..6e75c42 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -1473,19 +1473,20 @@ void bnx2x_release_phy_lock(struct bnx2x *bp);
  * bnx2x_extract_max_cfg - extract MAX BW part from MF configuration.
  *
  * @bp:		driver handle
- * @mf_cfg:	MF configuration
+ * @vn:		vnic index
  *
  */
-static inline u16 bnx2x_extract_max_cfg(struct bnx2x *bp, u32 mf_cfg)
+static inline u16 bnx2x_extract_max_cfg(struct bnx2x *bp, int vn)
 {
-	u16 max_cfg = (mf_cfg & FUNC_MF_CFG_MAX_BW_MASK) >>
-			      FUNC_MF_CFG_MAX_BW_SHIFT;
-	if (!max_cfg) {
-		BNX2X_ERR("Illegal configuration detected for Max BW - "
-			  "using 100 instead\n");
-		max_cfg = 100;
-	}
-	return max_cfg;
+	u16 max_cfg = (bp->mf_config[vn] & FUNC_MF_CFG_MAX_BW_MASK) >>
+					 FUNC_MF_CFG_MAX_BW_SHIFT;
+
+	if (!max_cfg && !bp->prev_max_cfg_invalid[vn])
+		BNX2X_ERR("Illegal configuration detected for Max BW "
+			  "on vn %d - using 100 instead\n", vn);
+	bp->prev_max_cfg_invalid[vn] = !max_cfg;
+
+	return max_cfg ?: 100;
 }
 
 #endif /* BNX2X_CMN_H */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 1507091..a952f84 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -2335,7 +2335,7 @@ static void bnx2x_init_vn_minmax(struct bnx2x *bp, int vn)
 		vn_max_rate = 0;
 
 	} else {
-		u32 maxCfg = bnx2x_extract_max_cfg(bp, vn_cfg);
+		u32 maxCfg = bnx2x_extract_max_cfg(bp, vn);
 
 		vn_min_rate = ((vn_cfg & FUNC_MF_CFG_MIN_BW_MASK) >>
 				FUNC_MF_CFG_MIN_BW_SHIFT) * 100;

