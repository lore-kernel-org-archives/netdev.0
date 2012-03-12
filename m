From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net 4/4] bnx2x: FCoE statistics id fixed
Date: Mon, 12 Mar 2012 17:22:07 -0400
Message-ID: <1331587327-26279-5-git-send-email-yuvalmin@broadcom.com>
References: <1331587327-26279-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4394 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754075Ab2CLO2W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2012 10:28:22 -0400
In-Reply-To: <1331587327-26279-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FCoE statistics ids were distinguished from the L2's statistics ids.
However, not all of the change was committed. This causes a possible
collision of indices when FCoE is present. 

This patch fixes the issue.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index bf27c54..0f4d034 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -1179,10 +1179,16 @@ static inline int bnx2x_alloc_rx_bds(struct bnx2x_fastpath *fp,
  */
 static inline u8 bnx2x_stats_id(struct bnx2x_fastpath *fp)
 {
-	if (!CHIP_IS_E1x(fp->bp))
+	struct bnx2x *bp = fp->bp;
+	if (!CHIP_IS_E1x(bp)) {
+#ifdef BCM_CNIC
+		/* there are special statistics counters for FCoE 136..140 */
+		if (IS_FCOE_FP(fp))
+			return bp->cnic_base_cl_id + (bp->pf_num >> 1);
+#endif
 		return fp->cl_id;
-	else
-		return fp->cl_id + BP_PORT(fp->bp) * FP_SB_MAX_E1x;
+	}
+	return fp->cl_id + BP_PORT(bp) * FP_SB_MAX_E1x;
 }
 
 static inline void bnx2x_init_vlan_mac_fp_objs(struct bnx2x_fastpath *fp,
-- 
1.7.9.rc2
