From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net PATCH v2 7/7] bnx2x: Add missing afex code
Date: Tue, 11 Sep 2012 17:34:14 +0300
Message-ID: <1347374054-16730-8-git-send-email-yuvalmin@broadcom.com>
References: <1347374054-16730-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Barak Witkowski" <barak@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1815 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757495Ab2IKO7U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2012 10:59:20 -0400
In-Reply-To: <1347374054-16730-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit a334872224a67b614dc888460377862621f3dac7 added afex support but lacked
several logical changes. This lack can cause afex to crash, and also
have a slight effect on other flows (i.e., driver always assumes the Tx ring
has less available buffers than what it actually has).

This patch adds the missing segments, fixing said issues.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Barak Witkowski <barak@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |   11 +++++------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   21 ++++++++++++++++-----
 2 files changed, 21 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 21b5532..dfd86a5 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -710,17 +710,15 @@ static inline u16 bnx2x_tx_avail(struct bnx2x *bp,
 	prod = txdata->tx_bd_prod;
 	cons = txdata->tx_bd_cons;
 
-	/* NUM_TX_RINGS = number of "next-page" entries
-	   It will be used as a threshold */
-	used = SUB_S16(prod, cons) + (s16)NUM_TX_RINGS;
+	used = SUB_S16(prod, cons);
 
 #ifdef BNX2X_STOP_ON_ERROR
 	WARN_ON(used < 0);
-	WARN_ON(used > bp->tx_ring_size);
-	WARN_ON((bp->tx_ring_size - used) > MAX_TX_AVAIL);
+	WARN_ON(used > txdata->tx_ring_size);
+	WARN_ON((txdata->tx_ring_size - used) > MAX_TX_AVAIL);
 #endif
 
-	return (s16)(bp->tx_ring_size) - used;
+	return (s16)(txdata->tx_ring_size) - used;
 }
 
 static inline int bnx2x_tx_queue_has_work(struct bnx2x_fp_txdata *txdata)
@@ -1088,6 +1086,7 @@ static inline void bnx2x_init_txdata(struct bnx2x *bp,
 	txdata->txq_index = txq_index;
 	txdata->tx_cons_sb = tx_cons_sb;
 	txdata->parent_fp = fp;
+	txdata->tx_ring_size = IS_FCOE_FP(fp) ? MAX_TX_AVAIL : bp->tx_ring_size;
 
 	DP(NETIF_MSG_IFUP, "created tx data cid %d, txq %d\n",
 	   txdata->cid, txdata->txq_index);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 2105498..211753e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -7561,8 +7561,14 @@ int bnx2x_set_mac_one(struct bnx2x *bp, u8 *mac,
 	}
 
 	rc = bnx2x_config_vlan_mac(bp, &ramrod_param);
-	if (rc < 0)
+
+	if (rc == -EEXIST) {
+		DP(BNX2X_MSG_SP, "Failed to schedule ADD operations: %d\n", rc);
+		/* do not treat adding same MAC as error */
+		rc = 0;
+	} else if (rc < 0)
 		BNX2X_ERR("%s MAC failed\n", (set ? "Set" : "Del"));
+
 	return rc;
 }
 
@@ -10294,13 +10300,11 @@ static void __devinit bnx2x_get_fcoe_info(struct bnx2x *bp)
 				dev_info.port_hw_config[port].
 				 fcoe_wwn_node_name_lower);
 	} else if (!IS_MF_SD(bp)) {
-		u32 cfg = MF_CFG_RD(bp, func_ext_config[func].func_cfg);
-
 		/*
 		 * Read the WWN info only if the FCoE feature is enabled for
 		 * this function.
 		 */
-		if (cfg & MACP_FUNC_CFG_FLAGS_FCOE_OFFLOAD)
+		if (BNX2X_MF_EXT_PROTOCOL_FCOE(bp) && !CHIP_IS_E1x(bp))
 			bnx2x_get_ext_wwn_info(bp, func);
 
 	} else if (IS_MF_FCOE_SD(bp))
@@ -11073,7 +11077,14 @@ static int bnx2x_set_uc_list(struct bnx2x *bp)
 	netdev_for_each_uc_addr(ha, dev) {
 		rc = bnx2x_set_mac_one(bp, bnx2x_uc_addr(ha), mac_obj, true,
 				       BNX2X_UC_LIST_MAC, &ramrod_flags);
-		if (rc < 0) {
+		if (rc == -EEXIST) {
+			DP(BNX2X_MSG_SP,
+			   "Failed to schedule ADD operations: %d\n", rc);
+			/* do not treat adding same MAC as error */
+			rc = 0;
+
+		} else if (rc < 0) {
+
 			BNX2X_ERR("Failed to schedule ADD operations: %d\n",
 				  rc);
 			return rc;
-- 
1.7.9.rc2
