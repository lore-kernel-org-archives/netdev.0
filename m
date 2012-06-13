From: "Merav Sicron" <meravs@broadcom.com>
Subject: [net-next patch 8/12] bnx2x: Allow up to 63 RSS queues default
 8 queues
Date: Wed, 13 Jun 2012 15:44:20 +0300
Message-ID: <1339591464-10554-9-git-send-email-meravs@broadcom.com>
References: <1339591464-10554-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Merav Sicron" <meravs@broadcom.com>
To: eilong@broadcom.com, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2749 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752792Ab2FMJmx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2012 05:42:53 -0400
In-Reply-To: <1339591464-10554-1-git-send-email-meravs@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removed the limitation in the code for 16 RSS queues. The default
(without other instruction from the user) number of queues is determined
according to the number of MSI-X vectors supported for that function, the number
of CPUs in the system, and a maximum of 8 queues.

Signed-off-by: Merav Sicron <meravs@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |    4 +++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   13 +++----------
 3 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 60a72f5..4dde45a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1643,7 +1643,7 @@ extern int num_queues;
 
 #define BNX2X_MAX_QUEUES(bp)	BNX2X_MAX_RSS_COUNT(bp)
 /* #define is_eth_multi(bp)	(BNX2X_NUM_ETH_QUEUES(bp) > 1) */
-
+#define BNX2X_DEFAULT_NUM_QUEUES	8
 #define RSS_IPV4_CAP_MASK						\
 	TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_CAPABILITY
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 11afe5d..2865575 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -815,9 +815,11 @@ static inline void bnx2x_disable_msi(struct bnx2x *bp)
 
 static inline int bnx2x_calc_num_queues(struct bnx2x *bp)
 {
+	int num = min_t(int, num_online_cpus(), BNX2X_DEFAULT_NUM_QUEUES);
+
 	return  num_queues ?
 		 min_t(int, num_queues, BNX2X_MAX_QUEUES(bp)) :
-		 min_t(int, num_online_cpus(), BNX2X_MAX_QUEUES(bp));
+		 min_t(int, num, BNX2X_MAX_QUEUES(bp));
 }
 
 static inline void bnx2x_clear_sge_mask_next_elems(struct bnx2x_fastpath *fp)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index fbade5c..11bd0b6 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -11813,13 +11813,6 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 
 	max_non_def_sbs = bnx2x_get_num_non_def_sbs(pdev);
 
-	/* !!! FIXME !!!
-	 * Do not allow the maximum SB count to grow above 16
-	 * since Special CIDs starts from 16*BNX2X_MULTI_TX_COS=48.
-	 * We will use the FP_SB_MAX_E1x macro for this matter.
-	 */
-	max_non_def_sbs = min_t(int, FP_SB_MAX_E1x, max_non_def_sbs);
-
 	WARN_ON(!max_non_def_sbs);
 
 	/* Maximum number of RSS queues: one IGU SB goes to CNIC */
@@ -11841,9 +11834,6 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 
 	bp = netdev_priv(dev);
 
-	BNX2X_DEV_INFO("Allocated netdev with %d tx and %d rx queues\n",
-			  tx_count, rx_count);
-
 	bp->igu_sb_cnt = max_non_def_sbs;
 	bp->msg_enable = debug;
 	pci_set_drvdata(pdev, dev);
@@ -11856,6 +11846,9 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 
 	BNX2X_DEV_INFO("max_non_def_sbs %d\n", max_non_def_sbs);
 
+	BNX2X_DEV_INFO("Allocated netdev with %d tx and %d rx queues\n",
+			  tx_count, rx_count);
+
 	rc = bnx2x_init_bp(bp);
 	if (rc)
 		goto init_one_exit;
-- 
1.7.10
