From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net v1 1/2] amd-xgbe: Treat certain counter registers as 64 bit
Date: Fri, 5 Sep 2014 18:02:30 -0500
Message-ID: <20140905230230.27896.12195.stgit@tlendack-t1.amdoffice.net>
References: <20140905230224.27896.64932.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0146.outbound.protection.outlook.com ([157.56.110.146]:53696
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751352AbaIEXRA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2014 19:17:00 -0400
In-Reply-To: <20140905230224.27896.64932.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even if the management counters are configured to be 32 bit register
values, the [rt]xoctetcount_gb and [rt]xoctetcount_g counters are
always 64 bit counter registers.  Since they are not being treated as
64 bit values, these statistics are being reported incorrectly (ifconfig,
ethtool, etc.).

Update the routines used to read the registers to access the "hi"
register (an offset of 4 from the "lo" register) to create a 64 bit
value for these 64 bit counters.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c |  190 +++++++++++++++++-------------
 1 file changed, 108 insertions(+), 82 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 6d0207e..f3d04f1 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1954,6 +1954,32 @@ static void xgbe_config_vlan_support(struct xgbe_prv_data *pdata)
 		xgbe_disable_rx_vlan_stripping(pdata);
 }
 
+static u64 xgbe_mmc_read(struct xgbe_prv_data *pdata, unsigned int reg_lo)
+{
+	bool read_hi;
+	u64 val;
+
+	switch (reg_lo) {
+	/* These registers are always 64 bit */
+	case MMC_TXOCTETCOUNT_GB_LO:
+	case MMC_TXOCTETCOUNT_G_LO:
+	case MMC_RXOCTETCOUNT_GB_LO:
+	case MMC_RXOCTETCOUNT_G_LO:
+		read_hi = true;
+		break;
+
+	default:
+		read_hi = false;
+	};
+
+	val = XGMAC_IOREAD(pdata, reg_lo);
+
+	if (read_hi)
+		val |= ((u64)XGMAC_IOREAD(pdata, reg_lo + 4) << 32);
+
+	return val;
+}
+
 static void xgbe_tx_mmc_int(struct xgbe_prv_data *pdata)
 {
 	struct xgbe_mmc_stats *stats = &pdata->mmc_stats;
@@ -1961,75 +1987,75 @@ static void xgbe_tx_mmc_int(struct xgbe_prv_data *pdata)
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TXOCTETCOUNT_GB))
 		stats->txoctetcount_gb +=
-			XGMAC_IOREAD(pdata, MMC_TXOCTETCOUNT_GB_LO);
+			xgbe_mmc_read(pdata, MMC_TXOCTETCOUNT_GB_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TXFRAMECOUNT_GB))
 		stats->txframecount_gb +=
-			XGMAC_IOREAD(pdata, MMC_TXFRAMECOUNT_GB_LO);
+			xgbe_mmc_read(pdata, MMC_TXFRAMECOUNT_GB_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TXBROADCASTFRAMES_G))
 		stats->txbroadcastframes_g +=
-			XGMAC_IOREAD(pdata, MMC_TXBROADCASTFRAMES_G_LO);
+			xgbe_mmc_read(pdata, MMC_TXBROADCASTFRAMES_G_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TXMULTICASTFRAMES_G))
 		stats->txmulticastframes_g +=
-			XGMAC_IOREAD(pdata, MMC_TXMULTICASTFRAMES_G_LO);
+			xgbe_mmc_read(pdata, MMC_TXMULTICASTFRAMES_G_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TX64OCTETS_GB))
 		stats->tx64octets_gb +=
-			XGMAC_IOREAD(pdata, MMC_TX64OCTETS_GB_LO);
+			xgbe_mmc_read(pdata, MMC_TX64OCTETS_GB_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TX65TO127OCTETS_GB))
 		stats->tx65to127octets_gb +=
-			XGMAC_IOREAD(pdata, MMC_TX65TO127OCTETS_GB_LO);
+			xgbe_mmc_read(pdata, MMC_TX65TO127OCTETS_GB_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TX128TO255OCTETS_GB))
 		stats->tx128to255octets_gb +=
-			XGMAC_IOREAD(pdata, MMC_TX128TO255OCTETS_GB_LO);
+			xgbe_mmc_read(pdata, MMC_TX128TO255OCTETS_GB_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TX256TO511OCTETS_GB))
 		stats->tx256to511octets_gb +=
-			XGMAC_IOREAD(pdata, MMC_TX256TO511OCTETS_GB_LO);
+			xgbe_mmc_read(pdata, MMC_TX256TO511OCTETS_GB_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TX512TO1023OCTETS_GB))
 		stats->tx512to1023octets_gb +=
-			XGMAC_IOREAD(pdata, MMC_TX512TO1023OCTETS_GB_LO);
+			xgbe_mmc_read(pdata, MMC_TX512TO1023OCTETS_GB_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TX1024TOMAXOCTETS_GB))
 		stats->tx1024tomaxoctets_gb +=
-			XGMAC_IOREAD(pdata, MMC_TX1024TOMAXOCTETS_GB_LO);
+			xgbe_mmc_read(pdata, MMC_TX1024TOMAXOCTETS_GB_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TXUNICASTFRAMES_GB))
 		stats->txunicastframes_gb +=
-			XGMAC_IOREAD(pdata, MMC_TXUNICASTFRAMES_GB_LO);
+			xgbe_mmc_read(pdata, MMC_TXUNICASTFRAMES_GB_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TXMULTICASTFRAMES_GB))
 		stats->txmulticastframes_gb +=
-			XGMAC_IOREAD(pdata, MMC_TXMULTICASTFRAMES_GB_LO);
+			xgbe_mmc_read(pdata, MMC_TXMULTICASTFRAMES_GB_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TXBROADCASTFRAMES_GB))
 		stats->txbroadcastframes_g +=
-			XGMAC_IOREAD(pdata, MMC_TXBROADCASTFRAMES_GB_LO);
+			xgbe_mmc_read(pdata, MMC_TXBROADCASTFRAMES_GB_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TXUNDERFLOWERROR))
 		stats->txunderflowerror +=
-			XGMAC_IOREAD(pdata, MMC_TXUNDERFLOWERROR_LO);
+			xgbe_mmc_read(pdata, MMC_TXUNDERFLOWERROR_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TXOCTETCOUNT_G))
 		stats->txoctetcount_g +=
-			XGMAC_IOREAD(pdata, MMC_TXOCTETCOUNT_G_LO);
+			xgbe_mmc_read(pdata, MMC_TXOCTETCOUNT_G_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TXFRAMECOUNT_G))
 		stats->txframecount_g +=
-			XGMAC_IOREAD(pdata, MMC_TXFRAMECOUNT_G_LO);
+			xgbe_mmc_read(pdata, MMC_TXFRAMECOUNT_G_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TXPAUSEFRAMES))
 		stats->txpauseframes +=
-			XGMAC_IOREAD(pdata, MMC_TXPAUSEFRAMES_LO);
+			xgbe_mmc_read(pdata, MMC_TXPAUSEFRAMES_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TXVLANFRAMES_G))
 		stats->txvlanframes_g +=
-			XGMAC_IOREAD(pdata, MMC_TXVLANFRAMES_G_LO);
+			xgbe_mmc_read(pdata, MMC_TXVLANFRAMES_G_LO);
 }
 
 static void xgbe_rx_mmc_int(struct xgbe_prv_data *pdata)
@@ -2039,95 +2065,95 @@ static void xgbe_rx_mmc_int(struct xgbe_prv_data *pdata)
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXFRAMECOUNT_GB))
 		stats->rxframecount_gb +=
-			XGMAC_IOREAD(pdata, MMC_RXFRAMECOUNT_GB_LO);
+			xgbe_mmc_read(pdata, MMC_RXFRAMECOUNT_GB_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXOCTETCOUNT_GB))
 		stats->rxoctetcount_gb +=
-			XGMAC_IOREAD(pdata, MMC_RXOCTETCOUNT_GB_LO);
+			xgbe_mmc_read(pdata, MMC_RXOCTETCOUNT_GB_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXOCTETCOUNT_G))
 		stats->rxoctetcount_g +=
-			XGMAC_IOREAD(pdata, MMC_RXOCTETCOUNT_G_LO);
+			xgbe_mmc_read(pdata, MMC_RXOCTETCOUNT_G_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXBROADCASTFRAMES_G))
 		stats->rxbroadcastframes_g +=
-			XGMAC_IOREAD(pdata, MMC_RXBROADCASTFRAMES_G_LO);
+			xgbe_mmc_read(pdata, MMC_RXBROADCASTFRAMES_G_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXMULTICASTFRAMES_G))
 		stats->rxmulticastframes_g +=
-			XGMAC_IOREAD(pdata, MMC_RXMULTICASTFRAMES_G_LO);
+			xgbe_mmc_read(pdata, MMC_RXMULTICASTFRAMES_G_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXCRCERROR))
 		stats->rxcrcerror +=
-			XGMAC_IOREAD(pdata, MMC_RXCRCERROR_LO);
+			xgbe_mmc_read(pdata, MMC_RXCRCERROR_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXRUNTERROR))
 		stats->rxrunterror +=
-			XGMAC_IOREAD(pdata, MMC_RXRUNTERROR);
+			xgbe_mmc_read(pdata, MMC_RXRUNTERROR);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXJABBERERROR))
 		stats->rxjabbererror +=
-			XGMAC_IOREAD(pdata, MMC_RXJABBERERROR);
+			xgbe_mmc_read(pdata, MMC_RXJABBERERROR);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXUNDERSIZE_G))
 		stats->rxundersize_g +=
-			XGMAC_IOREAD(pdata, MMC_RXUNDERSIZE_G);
+			xgbe_mmc_read(pdata, MMC_RXUNDERSIZE_G);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXOVERSIZE_G))
 		stats->rxoversize_g +=
-			XGMAC_IOREAD(pdata, MMC_RXOVERSIZE_G);
+			xgbe_mmc_read(pdata, MMC_RXOVERSIZE_G);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RX64OCTETS_GB))
 		stats->rx64octets_gb +=
-			XGMAC_IOREAD(pdata, MMC_RX64OCTETS_GB_LO);
+			xgbe_mmc_read(pdata, MMC_RX64OCTETS_GB_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RX65TO127OCTETS_GB))
 		stats->rx65to127octets_gb +=
-			XGMAC_IOREAD(pdata, MMC_RX65TO127OCTETS_GB_LO);
+			xgbe_mmc_read(pdata, MMC_RX65TO127OCTETS_GB_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RX128TO255OCTETS_GB))
 		stats->rx128to255octets_gb +=
-			XGMAC_IOREAD(pdata, MMC_RX128TO255OCTETS_GB_LO);
+			xgbe_mmc_read(pdata, MMC_RX128TO255OCTETS_GB_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RX256TO511OCTETS_GB))
 		stats->rx256to511octets_gb +=
-			XGMAC_IOREAD(pdata, MMC_RX256TO511OCTETS_GB_LO);
+			xgbe_mmc_read(pdata, MMC_RX256TO511OCTETS_GB_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RX512TO1023OCTETS_GB))
 		stats->rx512to1023octets_gb +=
-			XGMAC_IOREAD(pdata, MMC_RX512TO1023OCTETS_GB_LO);
+			xgbe_mmc_read(pdata, MMC_RX512TO1023OCTETS_GB_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RX1024TOMAXOCTETS_GB))
 		stats->rx1024tomaxoctets_gb +=
-			XGMAC_IOREAD(pdata, MMC_RX1024TOMAXOCTETS_GB_LO);
+			xgbe_mmc_read(pdata, MMC_RX1024TOMAXOCTETS_GB_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXUNICASTFRAMES_G))
 		stats->rxunicastframes_g +=
-			XGMAC_IOREAD(pdata, MMC_RXUNICASTFRAMES_G_LO);
+			xgbe_mmc_read(pdata, MMC_RXUNICASTFRAMES_G_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXLENGTHERROR))
 		stats->rxlengtherror +=
-			XGMAC_IOREAD(pdata, MMC_RXLENGTHERROR_LO);
+			xgbe_mmc_read(pdata, MMC_RXLENGTHERROR_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXOUTOFRANGETYPE))
 		stats->rxoutofrangetype +=
-			XGMAC_IOREAD(pdata, MMC_RXOUTOFRANGETYPE_LO);
+			xgbe_mmc_read(pdata, MMC_RXOUTOFRANGETYPE_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXPAUSEFRAMES))
 		stats->rxpauseframes +=
-			XGMAC_IOREAD(pdata, MMC_RXPAUSEFRAMES_LO);
+			xgbe_mmc_read(pdata, MMC_RXPAUSEFRAMES_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXFIFOOVERFLOW))
 		stats->rxfifooverflow +=
-			XGMAC_IOREAD(pdata, MMC_RXFIFOOVERFLOW_LO);
+			xgbe_mmc_read(pdata, MMC_RXFIFOOVERFLOW_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXVLANFRAMES_GB))
 		stats->rxvlanframes_gb +=
-			XGMAC_IOREAD(pdata, MMC_RXVLANFRAMES_GB_LO);
+			xgbe_mmc_read(pdata, MMC_RXVLANFRAMES_GB_LO);
 
 	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXWATCHDOGERROR))
 		stats->rxwatchdogerror +=
-			XGMAC_IOREAD(pdata, MMC_RXWATCHDOGERROR);
+			xgbe_mmc_read(pdata, MMC_RXWATCHDOGERROR);
 }
 
 static void xgbe_read_mmc_stats(struct xgbe_prv_data *pdata)
@@ -2138,127 +2164,127 @@ static void xgbe_read_mmc_stats(struct xgbe_prv_data *pdata)
 	XGMAC_IOWRITE_BITS(pdata, MMC_CR, MCF, 1);
 
 	stats->txoctetcount_gb +=
-		XGMAC_IOREAD(pdata, MMC_TXOCTETCOUNT_GB_LO);
+		xgbe_mmc_read(pdata, MMC_TXOCTETCOUNT_GB_LO);
 
 	stats->txframecount_gb +=
-		XGMAC_IOREAD(pdata, MMC_TXFRAMECOUNT_GB_LO);
+		xgbe_mmc_read(pdata, MMC_TXFRAMECOUNT_GB_LO);
 
 	stats->txbroadcastframes_g +=
-		XGMAC_IOREAD(pdata, MMC_TXBROADCASTFRAMES_G_LO);
+		xgbe_mmc_read(pdata, MMC_TXBROADCASTFRAMES_G_LO);
 
 	stats->txmulticastframes_g +=
-		XGMAC_IOREAD(pdata, MMC_TXMULTICASTFRAMES_G_LO);
+		xgbe_mmc_read(pdata, MMC_TXMULTICASTFRAMES_G_LO);
 
 	stats->tx64octets_gb +=
-		XGMAC_IOREAD(pdata, MMC_TX64OCTETS_GB_LO);
+		xgbe_mmc_read(pdata, MMC_TX64OCTETS_GB_LO);
 
 	stats->tx65to127octets_gb +=
-		XGMAC_IOREAD(pdata, MMC_TX65TO127OCTETS_GB_LO);
+		xgbe_mmc_read(pdata, MMC_TX65TO127OCTETS_GB_LO);
 
 	stats->tx128to255octets_gb +=
-		XGMAC_IOREAD(pdata, MMC_TX128TO255OCTETS_GB_LO);
+		xgbe_mmc_read(pdata, MMC_TX128TO255OCTETS_GB_LO);
 
 	stats->tx256to511octets_gb +=
-		XGMAC_IOREAD(pdata, MMC_TX256TO511OCTETS_GB_LO);
+		xgbe_mmc_read(pdata, MMC_TX256TO511OCTETS_GB_LO);
 
 	stats->tx512to1023octets_gb +=
-		XGMAC_IOREAD(pdata, MMC_TX512TO1023OCTETS_GB_LO);
+		xgbe_mmc_read(pdata, MMC_TX512TO1023OCTETS_GB_LO);
 
 	stats->tx1024tomaxoctets_gb +=
-		XGMAC_IOREAD(pdata, MMC_TX1024TOMAXOCTETS_GB_LO);
+		xgbe_mmc_read(pdata, MMC_TX1024TOMAXOCTETS_GB_LO);
 
 	stats->txunicastframes_gb +=
-		XGMAC_IOREAD(pdata, MMC_TXUNICASTFRAMES_GB_LO);
+		xgbe_mmc_read(pdata, MMC_TXUNICASTFRAMES_GB_LO);
 
 	stats->txmulticastframes_gb +=
-		XGMAC_IOREAD(pdata, MMC_TXMULTICASTFRAMES_GB_LO);
+		xgbe_mmc_read(pdata, MMC_TXMULTICASTFRAMES_GB_LO);
 
 	stats->txbroadcastframes_g +=
-		XGMAC_IOREAD(pdata, MMC_TXBROADCASTFRAMES_GB_LO);
+		xgbe_mmc_read(pdata, MMC_TXBROADCASTFRAMES_GB_LO);
 
 	stats->txunderflowerror +=
-		XGMAC_IOREAD(pdata, MMC_TXUNDERFLOWERROR_LO);
+		xgbe_mmc_read(pdata, MMC_TXUNDERFLOWERROR_LO);
 
 	stats->txoctetcount_g +=
-		XGMAC_IOREAD(pdata, MMC_TXOCTETCOUNT_G_LO);
+		xgbe_mmc_read(pdata, MMC_TXOCTETCOUNT_G_LO);
 
 	stats->txframecount_g +=
-		XGMAC_IOREAD(pdata, MMC_TXFRAMECOUNT_G_LO);
+		xgbe_mmc_read(pdata, MMC_TXFRAMECOUNT_G_LO);
 
 	stats->txpauseframes +=
-		XGMAC_IOREAD(pdata, MMC_TXPAUSEFRAMES_LO);
+		xgbe_mmc_read(pdata, MMC_TXPAUSEFRAMES_LO);
 
 	stats->txvlanframes_g +=
-		XGMAC_IOREAD(pdata, MMC_TXVLANFRAMES_G_LO);
+		xgbe_mmc_read(pdata, MMC_TXVLANFRAMES_G_LO);
 
 	stats->rxframecount_gb +=
-		XGMAC_IOREAD(pdata, MMC_RXFRAMECOUNT_GB_LO);
+		xgbe_mmc_read(pdata, MMC_RXFRAMECOUNT_GB_LO);
 
 	stats->rxoctetcount_gb +=
-		XGMAC_IOREAD(pdata, MMC_RXOCTETCOUNT_GB_LO);
+		xgbe_mmc_read(pdata, MMC_RXOCTETCOUNT_GB_LO);
 
 	stats->rxoctetcount_g +=
-		XGMAC_IOREAD(pdata, MMC_RXOCTETCOUNT_G_LO);
+		xgbe_mmc_read(pdata, MMC_RXOCTETCOUNT_G_LO);
 
 	stats->rxbroadcastframes_g +=
-		XGMAC_IOREAD(pdata, MMC_RXBROADCASTFRAMES_G_LO);
+		xgbe_mmc_read(pdata, MMC_RXBROADCASTFRAMES_G_LO);
 
 	stats->rxmulticastframes_g +=
-		XGMAC_IOREAD(pdata, MMC_RXMULTICASTFRAMES_G_LO);
+		xgbe_mmc_read(pdata, MMC_RXMULTICASTFRAMES_G_LO);
 
 	stats->rxcrcerror +=
-		XGMAC_IOREAD(pdata, MMC_RXCRCERROR_LO);
+		xgbe_mmc_read(pdata, MMC_RXCRCERROR_LO);
 
 	stats->rxrunterror +=
-		XGMAC_IOREAD(pdata, MMC_RXRUNTERROR);
+		xgbe_mmc_read(pdata, MMC_RXRUNTERROR);
 
 	stats->rxjabbererror +=
-		XGMAC_IOREAD(pdata, MMC_RXJABBERERROR);
+		xgbe_mmc_read(pdata, MMC_RXJABBERERROR);
 
 	stats->rxundersize_g +=
-		XGMAC_IOREAD(pdata, MMC_RXUNDERSIZE_G);
+		xgbe_mmc_read(pdata, MMC_RXUNDERSIZE_G);
 
 	stats->rxoversize_g +=
-		XGMAC_IOREAD(pdata, MMC_RXOVERSIZE_G);
+		xgbe_mmc_read(pdata, MMC_RXOVERSIZE_G);
 
 	stats->rx64octets_gb +=
-		XGMAC_IOREAD(pdata, MMC_RX64OCTETS_GB_LO);
+		xgbe_mmc_read(pdata, MMC_RX64OCTETS_GB_LO);
 
 	stats->rx65to127octets_gb +=
-		XGMAC_IOREAD(pdata, MMC_RX65TO127OCTETS_GB_LO);
+		xgbe_mmc_read(pdata, MMC_RX65TO127OCTETS_GB_LO);
 
 	stats->rx128to255octets_gb +=
-		XGMAC_IOREAD(pdata, MMC_RX128TO255OCTETS_GB_LO);
+		xgbe_mmc_read(pdata, MMC_RX128TO255OCTETS_GB_LO);
 
 	stats->rx256to511octets_gb +=
-		XGMAC_IOREAD(pdata, MMC_RX256TO511OCTETS_GB_LO);
+		xgbe_mmc_read(pdata, MMC_RX256TO511OCTETS_GB_LO);
 
 	stats->rx512to1023octets_gb +=
-		XGMAC_IOREAD(pdata, MMC_RX512TO1023OCTETS_GB_LO);
+		xgbe_mmc_read(pdata, MMC_RX512TO1023OCTETS_GB_LO);
 
 	stats->rx1024tomaxoctets_gb +=
-		XGMAC_IOREAD(pdata, MMC_RX1024TOMAXOCTETS_GB_LO);
+		xgbe_mmc_read(pdata, MMC_RX1024TOMAXOCTETS_GB_LO);
 
 	stats->rxunicastframes_g +=
-		XGMAC_IOREAD(pdata, MMC_RXUNICASTFRAMES_G_LO);
+		xgbe_mmc_read(pdata, MMC_RXUNICASTFRAMES_G_LO);
 
 	stats->rxlengtherror +=
-		XGMAC_IOREAD(pdata, MMC_RXLENGTHERROR_LO);
+		xgbe_mmc_read(pdata, MMC_RXLENGTHERROR_LO);
 
 	stats->rxoutofrangetype +=
-		XGMAC_IOREAD(pdata, MMC_RXOUTOFRANGETYPE_LO);
+		xgbe_mmc_read(pdata, MMC_RXOUTOFRANGETYPE_LO);
 
 	stats->rxpauseframes +=
-		XGMAC_IOREAD(pdata, MMC_RXPAUSEFRAMES_LO);
+		xgbe_mmc_read(pdata, MMC_RXPAUSEFRAMES_LO);
 
 	stats->rxfifooverflow +=
-		XGMAC_IOREAD(pdata, MMC_RXFIFOOVERFLOW_LO);
+		xgbe_mmc_read(pdata, MMC_RXFIFOOVERFLOW_LO);
 
 	stats->rxvlanframes_gb +=
-		XGMAC_IOREAD(pdata, MMC_RXVLANFRAMES_GB_LO);
+		xgbe_mmc_read(pdata, MMC_RXVLANFRAMES_GB_LO);
 
 	stats->rxwatchdogerror +=
-		XGMAC_IOREAD(pdata, MMC_RXWATCHDOGERROR);
+		xgbe_mmc_read(pdata, MMC_RXWATCHDOGERROR);
 
 	/* Un-freeze counters */
 	XGMAC_IOWRITE_BITS(pdata, MMC_CR, MCF, 0);
