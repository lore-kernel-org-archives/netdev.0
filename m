From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 6/7] stmmac: allow mmc usage only if feature actually available (V3)
Date: Tue, 18 Oct 2011 10:42:10 +0200
Message-ID: <1318927331-20855-7-git-send-email-peppe.cavallaro@st.com>
References: <1318927331-20855-1-git-send-email-peppe.cavallaro@st.com>
Cc: davem@davemloft.net, Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Rayagond Kokatanur <rayagond@vayavyalabs.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:41723 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754034Ab1JRIxk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 04:53:40 -0400
In-Reply-To: <1318927331-20855-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable the MMC support if it is actually available from the
HW capability register.

Signed-off-by: Rayagond Kokatanur <rayagond@vayavyalabs.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |   24 +++++++++++--------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |    3 +-
 2 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index aedff9a..406404f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -96,7 +96,7 @@ static const struct stmmac_stats stmmac_gstrings_stats[] = {
 	{ #m, FIELD_SIZEOF(struct stmmac_counters, m),	\
 	offsetof(struct stmmac_priv, mmc.m)}
 
-static const struct stmmac_stats stmmac_gstr_mmc[] = {
+static const struct stmmac_stats stmmac_mmc[] = {
 	STMMAC_MMC_STAT(mmc_tx_octetcount_gb),
 	STMMAC_MMC_STAT(mmc_tx_framecount_gb),
 	STMMAC_MMC_STAT(mmc_tx_broadcastframe_g),
@@ -177,7 +177,7 @@ static const struct stmmac_stats stmmac_gstr_mmc[] = {
 	STMMAC_MMC_STAT(mmc_rx_icmp_gd_octets),
 	STMMAC_MMC_STAT(mmc_rx_icmp_err_octets),
 };
-#define STMMAC_MMC_STATS_LEN ARRAY_SIZE(stmmac_gstr_mmc)
+#define STMMAC_MMC_STATS_LEN ARRAY_SIZE(stmmac_mmc)
 
 static void stmmac_ethtool_getdrvinfo(struct net_device *dev,
 				      struct ethtool_drvinfo *info)
@@ -348,13 +348,17 @@ static void stmmac_get_ethtool_stats(struct net_device *dev,
 						 priv->ioaddr);
 	else {
 		/* If supported, for new GMAC chips expose the MMC counters */
-		dwmac_mmc_read(priv->ioaddr, &priv->mmc);
+		if (priv->dma_cap.rmon) {
+			dwmac_mmc_read(priv->ioaddr, &priv->mmc);
 
-		for (i = 0; i < STMMAC_MMC_STATS_LEN; i++) {
-			char *p = (char *)priv + stmmac_gstr_mmc[i].stat_offset;
+			for (i = 0; i < STMMAC_MMC_STATS_LEN; i++) {
+				char *p;
+				p = (char *)priv + stmmac_mmc[i].stat_offset;
 
-			data[j++] = (stmmac_gstr_mmc[i].sizeof_stat ==
-				     sizeof(u64)) ? (*(u64 *)p) : (*(u32 *)p);
+				data[j++] = (stmmac_mmc[i].sizeof_stat ==
+					     sizeof(u64)) ? (*(u64 *)p) :
+					     (*(u32 *)p);
+			}
 		}
 	}
 	for (i = 0; i < STMMAC_STATS_LEN; i++) {
@@ -373,7 +377,7 @@ static int stmmac_get_sset_count(struct net_device *netdev, int sset)
 	case ETH_SS_STATS:
 		len = STMMAC_STATS_LEN;
 
-		if (priv->plat->has_gmac)
+		if (priv->dma_cap.rmon)
 			len += STMMAC_MMC_STATS_LEN;
 
 		return len;
@@ -390,9 +394,9 @@ static void stmmac_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 
 	switch (stringset) {
 	case ETH_SS_STATS:
-		if (priv->plat->has_gmac)
+		if (priv->dma_cap.rmon)
 			for (i = 0; i < STMMAC_MMC_STATS_LEN; i++) {
-				memcpy(p, stmmac_gstr_mmc[i].stat_string,
+				memcpy(p, stmmac_mmc[i].stat_string,
 				       ETH_GSTRING_LEN);
 				p += ETH_GSTRING_LEN;
 			}
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 125a177..7325256 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -946,7 +946,8 @@ static int stmmac_open(struct net_device *dev)
 	memset(&priv->xstats, 0, sizeof(struct stmmac_extra_stats));
 	priv->xstats.threshold = tc;
 
-	stmmac_mmc_setup(priv);
+	if (priv->dma_cap.rmon)
+		stmmac_mmc_setup(priv);
 
 	/* Start the ball rolling... */
 	DBG(probe, DEBUG, "%s: DMA RX/TX processes started...\n", dev->name);
-- 
1.7.4.4
