From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 6/8] amd-xgbe: Add receive buffer unavailable
 statistic
Date: Wed, 30 Sep 2015 08:53:10 -0500
Message-ID: <20150930135310.12605.71695.stgit@tlendack-t1.amdoffice.net>
References: <20150930135232.12605.15604.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0077.outbound.protection.outlook.com ([65.55.169.77]:12038
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753711AbbI3OH2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 10:07:28 -0400
In-Reply-To: <20150930135232.12605.15604.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a statistic that tracks how many times an interrupt is generated for
a receive buffer not being available to the hardware which prevents the
hardware from being able to DMA the received data.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c     |    3 +++
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c |    1 +
 drivers/net/ethernet/amd/xgbe/xgbe.h         |    1 +
 3 files changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index aae9d5e..24212d2 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -360,6 +360,9 @@ static irqreturn_t xgbe_isr(int irq, void *data)
 			}
 		}
 
+		if (XGMAC_GET_BITS(dma_ch_isr, DMA_CH_SR, RBU))
+			pdata->ext_stats.rx_buffer_unavailable++;
+
 		/* Restart the device on a Fatal Bus Error */
 		if (XGMAC_GET_BITS(dma_ch_isr, DMA_CH_SR, FBE))
 			schedule_work(&pdata->restart_work);
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
index 95b6373..204fb3a 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
@@ -179,6 +179,7 @@ static const struct xgbe_stats xgbe_gstring_stats[] = {
 	XGMAC_MMC_STAT("rx_watchdog_errors", rxwatchdogerror),
 	XGMAC_MMC_STAT("rx_pause_frames", rxpauseframes),
 	XGMAC_EXT_STAT("rx_split_header_packets", rx_split_header_packets),
+	XGMAC_EXT_STAT("rx_buffer_unavailable", rx_buffer_unavailable),
 };
 
 #define XGBE_STATS_COUNT	ARRAY_SIZE(xgbe_gstring_stats)
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index 5f9a1ab..a5f5a78 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -582,6 +582,7 @@ struct xgbe_mmc_stats {
 struct xgbe_ext_stats {
 	u64 tx_tso_packets;
 	u64 rx_split_header_packets;
+	u64 rx_buffer_unavailable;
 };
 
 struct xgbe_hw_if {
