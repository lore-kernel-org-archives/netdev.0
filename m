From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next PATCH v2 3/3] bnx2x: Added EEE Ethtool support.
Date: Wed, 6 Jun 2012 11:58:18 +0300
Message-ID: <1338973098-16439-4-git-send-email-yuvalmin@broadcom.com>
References: <1338973098-16439-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, bhutchings@solarflare.com,
	peppe.cavallaro@st.com, "Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4653 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755070Ab2FFJAR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jun 2012 05:00:17 -0400
In-Reply-To: <1338973098-16439-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch extends the bnx2x's ethtool interface to enable
control in the eee feature, as well as report statistic information
about it.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |  134 ++++++++++++++++++++
 1 files changed, 134 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index ddc18ee..bf30e28 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -177,6 +177,8 @@ static const struct {
 			4, STATS_FLAGS_FUNC, "recoverable_errors" },
 	{ STATS_OFFSET32(unrecoverable_error),
 			4, STATS_FLAGS_FUNC, "unrecoverable_errors" },
+	{ STATS_OFFSET32(eee_tx_lpi),
+			4, STATS_FLAGS_PORT, "Tx LPI entry count"}
 };
 
 #define BNX2X_NUM_STATS		ARRAY_SIZE(bnx2x_stats_arr)
@@ -1543,6 +1545,136 @@ static const struct {
 	{ "idle check (online)" }
 };
 
+static u32 bnx2x_eee_to_adv(u32 eee_adv)
+{
+	u32 modes = 0;
+
+	if (eee_adv & SHMEM_EEE_100M_ADV)
+		modes |= ADVERTISED_100baseT_Full;
+	if (eee_adv & SHMEM_EEE_1G_ADV)
+		modes |= ADVERTISED_1000baseT_Full;
+	if (eee_adv & SHMEM_EEE_10G_ADV)
+		modes |= ADVERTISED_10000baseT_Full;
+
+	return modes;
+}
+
+static u32 bnx2x_adv_to_eee(u32 modes, u32 shift)
+{
+	u32 eee_adv = 0;
+	if (modes & ADVERTISED_100baseT_Full)
+		eee_adv |= SHMEM_EEE_100M_ADV;
+	if (modes & ADVERTISED_1000baseT_Full)
+		eee_adv |= SHMEM_EEE_1G_ADV;
+	if (modes & ADVERTISED_10000baseT_Full)
+		eee_adv |= SHMEM_EEE_10G_ADV;
+
+	return eee_adv << shift;
+}
+
+static int bnx2x_get_eee(struct net_device *dev, struct ethtool_eee *edata)
+{
+	struct bnx2x *bp = netdev_priv(dev);
+	u32 eee_cfg;
+
+	if (!SHMEM2_HAS(bp, eee_status[BP_PORT(bp)])) {
+		DP(BNX2X_MSG_ETHTOOL, "BC Version does not support EEE\n");
+		return -EOPNOTSUPP;
+	}
+
+	eee_cfg = SHMEM2_RD(bp, eee_status[BP_PORT(bp)]);
+
+	edata->supported =
+		bnx2x_eee_to_adv((eee_cfg & SHMEM_EEE_SUPPORTED_MASK) >>
+				 SHMEM_EEE_SUPPORTED_SHIFT);
+
+	edata->advertised =
+		bnx2x_eee_to_adv((eee_cfg & SHMEM_EEE_ADV_STATUS_MASK) >>
+				 SHMEM_EEE_ADV_STATUS_SHIFT);
+	edata->lp_advertised =
+		bnx2x_eee_to_adv((eee_cfg & SHMEM_EEE_LP_ADV_STATUS_MASK) >>
+				 SHMEM_EEE_LP_ADV_STATUS_SHIFT);
+
+	/* SHMEM value is in 16u units --> Convert to 1u units. */
+	edata->tx_lpi_timer = (eee_cfg & SHMEM_EEE_TIMER_MASK) << 4;
+
+	edata->eee_enabled    = (eee_cfg & SHMEM_EEE_REQUESTED_BIT)	? 1 : 0;
+	edata->eee_active     = (eee_cfg & SHMEM_EEE_ACTIVE_BIT)	? 1 : 0;
+	edata->tx_lpi_enabled = (eee_cfg & SHMEM_EEE_LPI_REQUESTED_BIT) ? 1 : 0;
+
+	return 0;
+}
+
+static int bnx2x_set_eee(struct net_device *dev, struct ethtool_eee *edata)
+{
+	struct bnx2x *bp = netdev_priv(dev);
+	u32 eee_cfg;
+	u32 advertised;
+
+	if (IS_MF(bp))
+		return 0;
+
+	if (!SHMEM2_HAS(bp, eee_status[BP_PORT(bp)])) {
+		DP(BNX2X_MSG_ETHTOOL, "BC Version does not support EEE\n");
+		return -EOPNOTSUPP;
+	}
+
+	eee_cfg = SHMEM2_RD(bp, eee_status[BP_PORT(bp)]);
+
+	if (!(eee_cfg & SHMEM_EEE_SUPPORTED_MASK)) {
+		DP(BNX2X_MSG_ETHTOOL, "Board does not support EEE!\n");
+		return -EOPNOTSUPP;
+	}
+
+	advertised = bnx2x_adv_to_eee(edata->advertised,
+				      SHMEM_EEE_ADV_STATUS_SHIFT);
+	if ((advertised != (eee_cfg & SHMEM_EEE_ADV_STATUS_MASK))) {
+		DP(BNX2X_MSG_ETHTOOL,
+		   "Direct manipulation of EEE advertisment is not supported\n");
+		return -EINVAL;
+	}
+
+	if (edata->tx_lpi_timer > EEE_MODE_TIMER_MASK) {
+		DP(BNX2X_MSG_ETHTOOL,
+		   "Maximal Tx Lpi timer supported is %x(u)\n",
+		   EEE_MODE_TIMER_MASK);
+		return -EINVAL;
+	}
+	if (edata->tx_lpi_enabled &&
+	    (edata->tx_lpi_timer < EEE_MODE_NVRAM_AGGRESSIVE_TIME)) {
+		DP(BNX2X_MSG_ETHTOOL,
+		   "Minimal Tx Lpi timer supported is %d(u)\n",
+		   EEE_MODE_NVRAM_AGGRESSIVE_TIME);
+		return -EINVAL;
+	}
+
+	/* All is well; Apply changes*/
+	if (edata->eee_enabled)
+		bp->link_params.eee_mode |= EEE_MODE_ADV_LPI;
+	else
+		bp->link_params.eee_mode &= ~EEE_MODE_ADV_LPI;
+
+	if (edata->tx_lpi_enabled)
+		bp->link_params.eee_mode |= EEE_MODE_ENABLE_LPI;
+	else
+		bp->link_params.eee_mode &= ~EEE_MODE_ENABLE_LPI;
+
+	bp->link_params.eee_mode &= ~EEE_MODE_TIMER_MASK;
+	bp->link_params.eee_mode |= (edata->tx_lpi_timer &
+				    EEE_MODE_TIMER_MASK) |
+				    EEE_MODE_OVERRIDE_NVRAM |
+				    EEE_MODE_OUTPUT_TIME;
+
+	/* Restart link to propogate changes */
+	if (netif_running(dev)) {
+		bnx2x_stats_handle(bp, STATS_EVENT_STOP);
+		bnx2x_link_set(bp);
+	}
+
+	return 0;
+}
+
+
 enum {
 	BNX2X_CHIP_E1_OFST = 0,
 	BNX2X_CHIP_E1H_OFST,
@@ -2472,6 +2604,8 @@ static const struct ethtool_ops bnx2x_ethtool_ops = {
 	.get_rxfh_indir_size	= bnx2x_get_rxfh_indir_size,
 	.get_rxfh_indir		= bnx2x_get_rxfh_indir,
 	.set_rxfh_indir		= bnx2x_set_rxfh_indir,
+	.get_eee		= bnx2x_get_eee,
+	.set_eee		= bnx2x_set_eee,
 };
 
 void bnx2x_set_ethtool_ops(struct net_device *netdev)
-- 
1.7.9.rc2
