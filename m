From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next] bnx2x: properly initialize L5 features
Date: Thu, 8 Dec 2011 20:04:07 +0200
Message-ID: <1323367447-28074-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, barak@broadcom.com,
	"Dmitry Kravkov" <dmitry@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3979 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752214Ab1LHSEU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Dec 2011 13:04:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code is missing initialization of NO_FCOE_FLAG and NO_ISCSI*FLAGS
when CONFIG_CNIC is not selected.
This causes panic during driver load since commit
1d187b34daaecbb87aa523ba46b92930a388cb21 where NO_FCOE tested 
unconditionally (outside #ifdef BCM_CNIC  structure) and
accessed fp[FCOE_IDX] which is not allocated.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com> 

---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |    2 --
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   12 ++++++++----
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 2891cdc..bf27c54 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -1491,7 +1491,6 @@ static inline u16 bnx2x_extract_max_cfg(struct bnx2x *bp, u32 mf_cfg)
 	return max_cfg;
 }
 
-#ifdef BCM_CNIC
 /**
  * bnx2x_get_iscsi_info - update iSCSI params according to licensing info.
  *
@@ -1499,7 +1498,6 @@ static inline u16 bnx2x_extract_max_cfg(struct bnx2x *bp, u32 mf_cfg)
  *
  */
 void bnx2x_get_iscsi_info(struct bnx2x *bp);
-#endif
 
 /* returns func by VN for current port */
 static inline int func_by_vn(struct bnx2x *bp, int vn)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 62aa3a8..b45baf9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -9478,9 +9478,9 @@ static void __devinit bnx2x_get_port_hwinfo(struct bnx2x *bp)
 							bp->common.shmem2_base);
 }
 
-#ifdef BCM_CNIC
 void bnx2x_get_iscsi_info(struct bnx2x *bp)
 {
+#ifdef BCM_CNIC
 	int port = BP_PORT(bp);
 
 	u32 max_iscsi_conn = FW_ENCODE_32BIT_PATTERN ^ SHMEM_RD(bp,
@@ -9500,10 +9500,14 @@ void bnx2x_get_iscsi_info(struct bnx2x *bp)
 	 */
 	if (!bp->cnic_eth_dev.max_iscsi_conn)
 		bp->flags |= NO_ISCSI_FLAG;
+#else
+	bp->flags |= NO_ISCSI_FLAG;
+#endif
 }
 
 static void __devinit bnx2x_get_fcoe_info(struct bnx2x *bp)
 {
+#ifdef BCM_CNIC
 	int port = BP_PORT(bp);
 	int func = BP_ABS_FUNC(bp);
 
@@ -9570,6 +9574,9 @@ static void __devinit bnx2x_get_fcoe_info(struct bnx2x *bp)
 	 */
 	if (!bp->cnic_eth_dev.max_fcoe_conn)
 		bp->flags |= NO_FCOE_FLAG;
+#else
+	bp->flags |= NO_FCOE_FLAG;
+#endif
 }
 
 static void __devinit bnx2x_get_cnic_info(struct bnx2x *bp)
@@ -9582,7 +9589,6 @@ static void __devinit bnx2x_get_cnic_info(struct bnx2x *bp)
 	bnx2x_get_iscsi_info(bp);
 	bnx2x_get_fcoe_info(bp);
 }
-#endif
 
 static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 {
@@ -9907,9 +9913,7 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 	/* Get MAC addresses */
 	bnx2x_get_mac_hwinfo(bp);
 
-#ifdef BCM_CNIC
 	bnx2x_get_cnic_info(bp);
-#endif
 
 	/* Get current FW pulse sequence */
 	if (!BP_NOMCP(bp)) {
-- 
1.7.7.2
