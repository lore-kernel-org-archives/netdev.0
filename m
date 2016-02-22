From: Colin King <colin.king@canonical.com>
Subject: [PATCH][V2] rtlwifi: pass struct rtl_stats by reference as it is more efficient
Date: Mon, 22 Feb 2016 11:35:46 +0000
Message-ID: <1456140946-12509-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Kalle Valo <kvalo@codeaurora.org>,
	Priit Laes <plaes@plaes.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

passing rtl_stats by value is inefficient; the structure is over 300
bytes in size and generally just one field (packet_report_type)
is being accessed, so the pass by value is a relatively large overhead.
This change just affects just the rx_command_packet calls.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/realtek/rtlwifi/pci.c           | 2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8188ee/trx.c | 2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8188ee/trx.h | 2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8192ee/trx.c | 6 +++---
 drivers/net/wireless/realtek/rtlwifi/rtl8192ee/trx.h | 2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8723ae/trx.c | 2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8723ae/trx.h | 2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8723be/trx.c | 4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8723be/trx.h | 2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8821ae/trx.c | 4 ++--
 drivers/net/wireless/realtek/rtlwifi/rtl8821ae/trx.h | 2 +-
 drivers/net/wireless/realtek/rtlwifi/wifi.h          | 2 +-
 12 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/pci.c b/drivers/net/wireless/realtek/rtlwifi/pci.c
index 7f471bf..4153e7f 100644
--- a/drivers/net/wireless/realtek/rtlwifi/pci.c
+++ b/drivers/net/wireless/realtek/rtlwifi/pci.c
@@ -855,7 +855,7 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *hw)
 		}
 		/* handle command packet here */
 		if (rtlpriv->cfg->ops->rx_command_packet &&
-		    rtlpriv->cfg->ops->rx_command_packet(hw, stats, skb)) {
+		    rtlpriv->cfg->ops->rx_command_packet(hw, &stats, skb)) {
 				dev_kfree_skb_any(skb);
 				goto new_trx_end;
 		}
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/trx.c b/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/trx.c
index 791efbe..1170106 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/trx.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/trx.c
@@ -851,7 +851,7 @@ void rtl88ee_tx_polling(struct ieee80211_hw *hw, u8 hw_queue)
 }
 
 u32 rtl88ee_rx_command_packet(struct ieee80211_hw *hw,
-			      struct rtl_stats status,
+			      const struct rtl_stats *status,
 			      struct sk_buff *skb)
 {
 	return 0;
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/trx.h b/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/trx.h
index eab5ae0..5a24d19 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/trx.h
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8188ee/trx.h
@@ -790,7 +790,7 @@ void rtl88ee_tx_fill_cmddesc(struct ieee80211_hw *hw, u8 *pdesc,
 			     bool firstseg, bool lastseg,
 			     struct sk_buff *skb);
 u32 rtl88ee_rx_command_packet(struct ieee80211_hw *hw,
-			      struct rtl_stats status,
+			      const struct rtl_stats *status,
 			      struct sk_buff *skb);
 
 #endif
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/trx.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/trx.c
index d39ee67..24eff8e 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/trx.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/trx.c
@@ -1105,13 +1105,13 @@ void rtl92ee_tx_polling(struct ieee80211_hw *hw, u8 hw_queue)
 }
 
 u32 rtl92ee_rx_command_packet(struct ieee80211_hw *hw,
-			      struct rtl_stats status,
+			      const struct rtl_stats *status,
 			      struct sk_buff *skb)
 {
 	u32 result = 0;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
-	switch (status.packet_report_type) {
+	switch (status->packet_report_type) {
 	case NORMAL_RX:
 		result = 0;
 		break;
@@ -1121,7 +1121,7 @@ u32 rtl92ee_rx_command_packet(struct ieee80211_hw *hw,
 		break;
 	default:
 		RT_TRACE(rtlpriv, COMP_RECV, DBG_TRACE,
-			 "Unknown packet type %d\n", status.packet_report_type);
+			 "Unknown packet type %d\n", status->packet_report_type);
 		break;
 	}
 
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/trx.h b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/trx.h
index 8f78ac9..a4c3834 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/trx.h
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192ee/trx.h
@@ -857,6 +857,6 @@ void rtl92ee_tx_fill_cmddesc(struct ieee80211_hw *hw, u8 *pdesc,
 			     bool firstseg, bool lastseg,
 			     struct sk_buff *skb);
 u32 rtl92ee_rx_command_packet(struct ieee80211_hw *hw,
-			      struct rtl_stats status,
+			      const struct rtl_stats *status,
 			      struct sk_buff *skb);
 #endif
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/trx.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/trx.c
index 2f7c144..7b4a9b6 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/trx.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/trx.c
@@ -710,7 +710,7 @@ void rtl8723e_tx_polling(struct ieee80211_hw *hw, u8 hw_queue)
 }
 
 u32 rtl8723e_rx_command_packet(struct ieee80211_hw *hw,
-			       struct rtl_stats status,
+			       const struct rtl_stats *status,
 			       struct sk_buff *skb)
 {
 	return 0;
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/trx.h b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/trx.h
index 017da7e..32970bf 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/trx.h
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723ae/trx.h
@@ -716,6 +716,6 @@ void rtl8723e_tx_fill_cmddesc(struct ieee80211_hw *hw, u8 *pdesc,
 			      bool firstseg, bool lastseg,
 			      struct sk_buff *skb);
 u32 rtl8723e_rx_command_packet(struct ieee80211_hw *hw,
-			       struct rtl_stats status,
+			       const struct rtl_stats *status,
 			       struct sk_buff *skb);
 #endif
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/trx.c b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/trx.c
index 338ec9a..6034597 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/trx.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/trx.c
@@ -758,13 +758,13 @@ void rtl8723be_tx_polling(struct ieee80211_hw *hw, u8 hw_queue)
 }
 
 u32 rtl8723be_rx_command_packet(struct ieee80211_hw *hw,
-				struct rtl_stats status,
+				const struct rtl_stats *status,
 				struct sk_buff *skb)
 {
 	u32 result = 0;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
-	switch (status.packet_report_type) {
+	switch (status->packet_report_type) {
 	case NORMAL_RX:
 			result = 0;
 			break;
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/trx.h b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/trx.h
index 45949ac..40c36607 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8723be/trx.h
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8723be/trx.h
@@ -620,6 +620,6 @@ void rtl8723be_tx_fill_cmddesc(struct ieee80211_hw *hw, u8 *pdesc,
 			       bool firstseg, bool lastseg,
 			       struct sk_buff *skb);
 u32 rtl8723be_rx_command_packet(struct ieee80211_hw *hw,
-				struct rtl_stats status,
+				const struct rtl_stats *status,
 				struct sk_buff *skb);
 #endif
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/trx.c b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/trx.c
index 174743a..41efaa1 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/trx.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/trx.c
@@ -998,13 +998,13 @@ void rtl8821ae_tx_polling(struct ieee80211_hw *hw, u8 hw_queue)
 }
 
 u32 rtl8821ae_rx_command_packet(struct ieee80211_hw *hw,
-				struct rtl_stats status,
+				const struct rtl_stats *status,
 				struct sk_buff *skb)
 {
 	u32 result = 0;
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 
-	switch (status.packet_report_type) {
+	switch (status->packet_report_type) {
 	case NORMAL_RX:
 		result = 0;
 		break;
diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/trx.h b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/trx.h
index 3140904..ad565be 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/trx.h
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/trx.h
@@ -615,6 +615,6 @@ void rtl8821ae_tx_fill_cmddesc(struct ieee80211_hw *hw, u8 *pdesc,
 			       bool firstseg, bool lastseg,
 			       struct sk_buff *skb);
 u32 rtl8821ae_rx_command_packet(struct ieee80211_hw *hw,
-				struct rtl_stats status,
+				const struct rtl_stats *status,
 				struct sk_buff *skb);
 #endif
diff --git a/drivers/net/wireless/realtek/rtlwifi/wifi.h b/drivers/net/wireless/realtek/rtlwifi/wifi.h
index 4544752..1a79082 100644
--- a/drivers/net/wireless/realtek/rtlwifi/wifi.h
+++ b/drivers/net/wireless/realtek/rtlwifi/wifi.h
@@ -2194,7 +2194,7 @@ struct rtl_hal_ops {
 	bool (*get_btc_status) (void);
 	bool (*is_fw_header)(struct rtlwifi_firmware_header *hdr);
 	u32 (*rx_command_packet)(struct ieee80211_hw *hw,
-				 struct rtl_stats status, struct sk_buff *skb);
+				 const struct rtl_stats *status, struct sk_buff *skb);
 	void (*add_wowlan_pattern)(struct ieee80211_hw *hw,
 				   struct rtl_wow_pattern *rtl_pattern,
 				   u8 index);
-- 
2.7.0
