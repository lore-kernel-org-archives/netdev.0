From: Bernhard Walle <walle@corscience.de>
Subject: [PATCH] [RFC] ath9k: Fix reporting of RX STBC streams to userspace
Date: Tue, 11 Jan 2011 17:59:54 +0100
Message-ID: <1294765194-30542-1-git-send-email-walle@corscience.de>
Cc: linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: lrodriguez@atheros.com, jmalinen@atheros.com, vasanth@atheros.com,
	senthilkumar@atheros.com, linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While the driver reports

        ath: TX streams 2, RX streams: 2

in the kernel log (with ATH_DBG_CONFIG set in the debug module
parameter), "iw list" only reported

[...]
        Capabilities: 0x12ce
                HT20/HT40
                SM Power Save disabled
                RX HT40 SGI
                TX STBC
                RX STBC 1-streams
[...]

The driver seems to set the value as flag while the iw tool interprets
it as number. This patch fixes that.

Signed-off-by: Bernhard Walle <walle@corscience.de>
---
 drivers/net/wireless/ath/ath9k/init.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/ath/ath9k/init.c
index 639dc93..935b6c3 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -215,17 +215,17 @@ static void setup_ht_cap(struct ath_softc *sc,
 	else
 		max_streams = 2;
 
-	if (AR_SREV_9280_20_OR_LATER(ah)) {
-		if (max_streams >= 2)
-			ht_info->cap |= IEEE80211_HT_CAP_TX_STBC;
-		ht_info->cap |= (1 << IEEE80211_HT_CAP_RX_STBC_SHIFT);
-	}
-
 	/* set up supported mcs set */
 	memset(&ht_info->mcs, 0, sizeof(ht_info->mcs));
 	tx_streams = ath9k_cmn_count_streams(common->tx_chainmask, max_streams);
 	rx_streams = ath9k_cmn_count_streams(common->rx_chainmask, max_streams);
 
+	if (AR_SREV_9280_20_OR_LATER(ah)) {
+		if (max_streams >= 2)
+			ht_info->cap |= IEEE80211_HT_CAP_TX_STBC;
+		ht_info->cap |= (rx_streams << IEEE80211_HT_CAP_RX_STBC_SHIFT);
+	}
+
 	ath_print(common, ATH_DBG_CONFIG,
 		  "TX streams %d, RX streams: %d\n",
 		  tx_streams, rx_streams);
-- 
1.7.1
