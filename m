From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next PATCH 1/5] bnx2x: EEE status is read locally
Date: Mon, 10 Sep 2012 18:51:04 +0300
Message-ID: <1347292268-30348-2-git-send-email-yuvalmin@broadcom.com>
References: <1347292268-30348-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3451 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754379Ab2IJQPQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2012 12:15:16 -0400
In-Reply-To: <1347292268-30348-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch aligns the EEE status with that of all other link properties,
by changing the way its accessed - instead of a direct read to the shared
memory, each function maintain its own copy locally.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |    4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c   |    4 ++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c  |   35 +++++++++++++++++---
 3 files changed, 36 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index c37a68d..5bafcd9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1647,7 +1647,7 @@ static int bnx2x_get_eee(struct net_device *dev, struct ethtool_eee *edata)
 		return -EOPNOTSUPP;
 	}
 
-	eee_cfg = SHMEM2_RD(bp, eee_status[BP_PORT(bp)]);
+	eee_cfg = bp->link_vars.eee_status;
 
 	edata->supported =
 		bnx2x_eee_to_adv((eee_cfg & SHMEM_EEE_SUPPORTED_MASK) >>
@@ -1684,7 +1684,7 @@ static int bnx2x_set_eee(struct net_device *dev, struct ethtool_eee *edata)
 		return -EOPNOTSUPP;
 	}
 
-	eee_cfg = SHMEM2_RD(bp, eee_status[BP_PORT(bp)]);
+	eee_cfg = bp->link_vars.eee_status;
 
 	if (!(eee_cfg & SHMEM_EEE_SUPPORTED_MASK)) {
 		DP(BNX2X_MSG_ETHTOOL, "Board does not support EEE!\n");
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index f4beb46..14afa17 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -4716,6 +4716,10 @@ void bnx2x_link_status_update(struct link_params *params,
 	vars->link_status = REG_RD(bp, params->shmem_base +
 				   offsetof(struct shmem_region,
 					    port_mb[port].link_status));
+	if (bnx2x_eee_has_cap(params))
+		vars->eee_status = REG_RD(bp, params->shmem2_base +
+					  offsetof(struct shmem2_region,
+						   eee_status[params->port]));
 
 	vars->phy_flags = PHY_XGXS_FLAG;
 	bnx2x_sync_link(params, vars);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index 332db64..ab00b35 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -39,14 +39,39 @@ static inline long bnx2x_hilo(u32 *hiref)
 #endif
 }
 
-static u16 bnx2x_get_port_stats_dma_len(struct bnx2x *bp)
+static inline u16 bnx2x_get_port_stats_dma_len(struct bnx2x *bp)
 {
-	u16 res = sizeof(struct host_port_stats) >> 2;
+	u16 res = 0;
 
-	/* if PFC stats are not supported by the MFW, don't DMA them */
-	if (!(bp->flags &  BC_SUPPORTS_PFC_STATS))
-		res -= (sizeof(u32)*4) >> 2;
+	/* 'newest' convention - shmem2 cotains the size of the port stats */
+	if (SHMEM2_HAS(bp, sizeof_port_stats)) {
+		u32 size = SHMEM2_RD(bp, sizeof_port_stats);
+		if (size)
+			res = size;
 
+		/* prevent newer BC from causing buffer overflow */
+		if (res > sizeof(struct host_port_stats))
+			res = sizeof(struct host_port_stats);
+	}
+
+	/* Older convention - all BCs support the port stats' fields up until
+	 * the 'not_used' field
+	 */
+	if (!res) {
+		res = offsetof(struct host_port_stats, not_used) + 4;
+
+		/* if PFC stats are supported by the MFW, DMA them as well */
+		if (bp->flags & BC_SUPPORTS_PFC_STATS) {
+			res += offsetof(struct host_port_stats,
+					pfc_frames_rx_lo) -
+			       offsetof(struct host_port_stats,
+					pfc_frames_tx_hi) + 4 ;
+		}
+	}
+
+	res >>= 2;
+
+	WARN_ON(res > 2 * DMAE_LEN32_RD_MAX);
 	return res;
 }
 
-- 
1.7.9.rc2
