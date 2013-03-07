From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 6/9] stmmac: add missing supported filters to get_ts_info
Date: Thu,  7 Mar 2013 11:50:16 +0100
Message-ID: <1362653419-1047-7-git-send-email-peppe.cavallaro@st.com>
References: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com>
Cc: bh74.an@samsung.com, ayagond@vayavyalabs.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from beta.dmz-us.st.com ([167.4.1.35]:56693 "EHLO beta.dmz-us.st.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932690Ab3CGLrJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 06:47:09 -0500
In-Reply-To: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the filters for ethtool's get_ts_info to return support for
all filters which can be supported after having added the PTP support.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h       |    1 +
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |   37 +++++++++++++++++++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |    1 -
 3 files changed, 37 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 2d6e2e1..a9a10dd 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -34,6 +34,7 @@
 
 #ifdef CONFIG_STMMAC_USE_HWSTAMP
 #include <linux/ptp_clock_kernel.h>
+#include <linux/net_tstamp.h>
 #endif
 
 struct stmmac_priv {
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index 5698bf3..88d2d25 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -629,6 +629,41 @@ static int stmmac_set_coalesce(struct net_device *dev,
 	return 0;
 }
 
+static int stmmac_get_ts_info(struct net_device *dev,
+			      struct ethtool_ts_info *info)
+{
+#ifdef CONFIG_STMMAC_USE_HWSTAMP
+	struct stmmac_priv *priv = netdev_priv(dev);
+
+	if (priv->dma_cap.atime_stamp) {
+
+		info->so_timestamping = SOF_TIMESTAMPING_TX_HARDWARE |
+					SOF_TIMESTAMPING_RX_HARDWARE |
+					SOF_TIMESTAMPING_RAW_HARDWARE;
+
+		if (priv->ptp_clock)
+			info->phc_index = ptp_clock_index(priv->ptp_clock);
+
+		info->tx_types = (1 << HWTSTAMP_TX_OFF) | (1 << HWTSTAMP_TX_ON);
+
+		info->rx_filters = ((1 << HWTSTAMP_FILTER_NONE) |
+				    (1 << HWTSTAMP_FILTER_PTP_V1_L4_EVENT) |
+				    (1 << HWTSTAMP_FILTER_PTP_V1_L4_SYNC) |
+				    (1 << HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ) |
+				    (1 << HWTSTAMP_FILTER_PTP_V2_L4_EVENT) |
+				    (1 << HWTSTAMP_FILTER_PTP_V2_L4_SYNC) |
+				    (1 << HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ) |
+				    (1 << HWTSTAMP_FILTER_PTP_V2_EVENT) |
+				    (1 << HWTSTAMP_FILTER_PTP_V2_SYNC) |
+				    (1 << HWTSTAMP_FILTER_PTP_V2_DELAY_REQ) |
+				    (1 << HWTSTAMP_FILTER_ALL));
+	}
+	return 0;
+#else
+	return ethtool_op_get_ts_info(dev, info);
+#endif /* CONFIG_STMMAC_USE_HWSTAMP */
+}
+
 static const struct ethtool_ops stmmac_ethtool_ops = {
 	.begin = stmmac_check_if_running,
 	.get_drvinfo = stmmac_ethtool_getdrvinfo,
@@ -648,7 +683,7 @@ static const struct ethtool_ops stmmac_ethtool_ops = {
 	.get_eee = stmmac_ethtool_op_get_eee,
 	.set_eee = stmmac_ethtool_op_set_eee,
 	.get_sset_count	= stmmac_get_sset_count,
-	.get_ts_info = ethtool_op_get_ts_info,
+	.get_ts_info = stmmac_get_ts_info,
 	.get_coalesce = stmmac_get_coalesce,
 	.set_coalesce = stmmac_set_coalesce,
 };
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index ae92191..8786939 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -48,7 +48,6 @@
 #include <linux/seq_file.h>
 #endif
 #ifdef CONFIG_STMMAC_USE_HWSTAMP
-#include <linux/net_tstamp.h>
 #include "stmmac_ptp.h"
 #endif
 #include "stmmac.h"
-- 
1.7.4.4
