From: "Ariel Elior" <ariele@broadcom.com>
Subject: [PATCH net-next 09/10] bnx2x: Recoverable and unrecoverable
 error statistics
Date: Thu, 26 Jan 2012 18:01:53 +0200
Message-ID: <1327593714-18358-10-git-send-email-ariele@broadcom.com>
References: <1327593714-18358-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Ariel Elior" <ariele@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1867 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752004Ab2AZQCD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jan 2012 11:02:03 -0500
In-Reply-To: <1327593714-18358-1-git-send-email-ariele@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add statistics for tracking parity errors from which we successfully
recovered and those which were deemed unrecoverable.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |   12 +++++++++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |   13 +++++++++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h  |    4 ++++
 3 files changed, 26 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 37a5c52..06cb244 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -175,7 +175,11 @@ static const struct {
 	{ STATS_OFFSET32(total_tpa_aggregated_frames_hi),
 			8, STATS_FLAGS_FUNC, "tpa_aggregated_frames"},
 	{ STATS_OFFSET32(total_tpa_bytes_hi),
-			8, STATS_FLAGS_FUNC, "tpa_bytes"}
+			8, STATS_FLAGS_FUNC, "tpa_bytes"},
+	{ STATS_OFFSET32(recoverable_error),
+			4, STATS_FLAGS_FUNC, "recoverable_errors" },
+	{ STATS_OFFSET32(unrecoverable_error),
+			4, STATS_FLAGS_FUNC, "unrecoverable_errors" },
 };
 
 #define BNX2X_NUM_STATS		ARRAY_SIZE(bnx2x_stats_arr)
@@ -1388,7 +1392,8 @@ static int bnx2x_set_ringparam(struct net_device *dev,
 	struct bnx2x *bp = netdev_priv(dev);
 
 	if (bp->recovery_state != BNX2X_RECOVERY_DONE) {
-		pr_err("Handling parity error recovery. Try again later\n");
+		netdev_err(dev, "Handling parity error recovery. "
+				"Try again later\n");
 		return -EAGAIN;
 	}
 
@@ -2042,7 +2047,8 @@ static void bnx2x_self_test(struct net_device *dev,
 	struct bnx2x *bp = netdev_priv(dev);
 	u8 is_serdes;
 	if (bp->recovery_state != BNX2X_RECOVERY_DONE) {
-		pr_err("Handling parity error recovery. Try again later\n");
+		netdev_err(bp->dev, "Handling parity error recovery. "
+				    "Try again later\n");
 		etest->flags |= ETH_TEST_FL_FAILED;
 		return;
 	}
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index c945df0..cdce766 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -784,6 +784,7 @@ void bnx2x_panic_dump(struct bnx2x *bp)
 #endif
 
 	bp->stats_state = STATS_STATE_DISABLED;
+	bp->eth_stats.unrecoverable_error++;
 	DP(BNX2X_MSG_STATS, "stats_state - DISABLED\n");
 
 	BNX2X_ERR("begin crash dump -----------------\n");
@@ -5441,6 +5442,7 @@ static void bnx2x_init_eth_fp(struct bnx2x *bp, int fp_idx)
 
 	/* init shortcut */
 	fp->ustorm_rx_prods_offset = bnx2x_rx_ustorm_prods_offset(fp);
+
 	/* Setup SB indicies */
 	fp->rx_cons_sb = BNX2X_RX_SB_INDEX;
 
@@ -8563,6 +8565,7 @@ static inline void bnx2x_recovery_failed(struct bnx2x *bp)
 static void bnx2x_parity_recover(struct bnx2x *bp)
 {
 	bool global = false;
+	u32 error_recovered, error_unrecovered;
 	bool is_parity;
 
 	DP(NETIF_MSG_HW, "Handling parity\n");
@@ -8678,9 +8681,14 @@ static void bnx2x_parity_recover(struct bnx2x *bp)
 						return;
 					}
 
+					error_recovered =
+					  bp->eth_stats.recoverable_error;
+					error_unrecovered =
+					  bp->eth_stats.unrecoverable_error;
 					bp->recovery_state =
 						BNX2X_RECOVERY_NIC_LOADING;
 					if (bnx2x_nic_load(bp, LOAD_NORMAL)) {
+						error_unrecovered++;
 						netdev_err(bp->dev,
 							   "Recovery failed. "
 							   "Power cycle "
@@ -8694,8 +8702,13 @@ static void bnx2x_parity_recover(struct bnx2x *bp)
 					} else {
 						bp->recovery_state =
 							BNX2X_RECOVERY_DONE;
+						error_recovered++;
 						smp_mb();
 					}
+					bp->eth_stats.recoverable_error =
+						error_recovered;
+					bp->eth_stats.unrecoverable_error =
+						error_unrecovered;
 
 					return;
 				}
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
index 683deb0..9c28db1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
@@ -199,6 +199,10 @@ struct bnx2x_eth_stats {
 	u32 pfc_frames_received_lo;
 	u32 pfc_frames_sent_hi;
 	u32 pfc_frames_sent_lo;
+
+	/* Recovery */
+	u32 recoverable_error;
+	u32 unrecoverable_error;
 };
 
 
-- 
1.7.1
