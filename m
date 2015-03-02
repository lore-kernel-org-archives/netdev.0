From: Florian Westphal <fw@strlen.de>
Subject: [PATCH RFC 07/14] net: wireless: iwlwifi: shrink status private area
Date: Mon,  2 Mar 2015 18:40:21 +0100
Message-ID: <1425318028-26531-8-git-send-email-fw@strlen.de>
References: <1425318028-26531-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>, linux-wireless@vger.kernel.org
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:54113 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754640AbbCBRkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 12:40:46 -0500
In-Reply-To: <1425318028-26531-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

iwlwifi is only driver to use status_driver_data, and it only wants to
store u8 counter.

This is one patch needed to reduce size of ieee80211_tx_info,
which in turn is needed to allow reducing size of skb->cb[].

Cc: linux-wireless@vger.kernel.org
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 drivers/net/wireless/iwlwifi/mvm/rs.c | 2 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c | 8 +++-----
 include/net/mac80211.h                | 2 +-
 3 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/mvm/rs.c b/drivers/net/wireless/iwlwifi/mvm/rs.c
index 194bd1f..e29092b 100644
--- a/drivers/net/wireless/iwlwifi/mvm/rs.c
+++ b/drivers/net/wireless/iwlwifi/mvm/rs.c
@@ -1054,7 +1054,7 @@ void iwl_mvm_rs_tx_status(struct iwl_mvm *mvm, struct ieee80211_sta *sta,
 	u32 ucode_rate;
 	struct rs_rate rate;
 	struct iwl_scale_tbl_info *curr_tbl, *other_tbl, *tmp_tbl;
-	u8 reduced_txp = (uintptr_t)info->status.status_driver_data[0];
+	u8 reduced_txp = (u8)info->status.status_driver_data[0];
 	struct iwl_mvm_sta *mvmsta = iwl_mvm_sta_from_mac80211(sta);
 	struct iwl_lq_sta *lq_sta = &mvmsta->lq_sta;
 
diff --git a/drivers/net/wireless/iwlwifi/mvm/tx.c b/drivers/net/wireless/iwlwifi/mvm/tx.c
index 07304e1..450635f 100644
--- a/drivers/net/wireless/iwlwifi/mvm/tx.c
+++ b/drivers/net/wireless/iwlwifi/mvm/tx.c
@@ -683,9 +683,8 @@ static void iwl_mvm_rx_tx_cmd_single(struct iwl_mvm *mvm,
 		 */
 		info->status.tx_time =
 			le16_to_cpu(tx_resp->wireless_media_time);
-		BUILD_BUG_ON(ARRAY_SIZE(info->status.status_driver_data) < 1);
-		info->status.status_driver_data[0] =
-				(void *)(uintptr_t)tx_resp->reduced_tpc;
+		BUILD_BUG_ON(sizeof(info->status.status_driver_data) < 1);
+		info->status.status_driver_data[0] = tx_resp->reduced_tpc;
 
 		ieee80211_tx_status(mvm->hw, skb);
 	}
@@ -907,8 +906,7 @@ static void iwl_mvm_tx_info_from_ba_notif(struct ieee80211_tx_info *info,
 				    info);
 	/* TODO: not accounted if the whole A-MPDU failed */
 	info->status.tx_time = tid_data->tx_time;
-	info->status.status_driver_data[0] =
-		(void *)(uintptr_t)tid_data->reduced_tpc;
+	info->status.status_driver_data[0] = tid_data->reduced_tpc;
 }
 
 int iwl_mvm_rx_ba_notif(struct iwl_mvm *mvm, struct iwl_rx_cmd_buffer *rxb,
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index d52914b..63c3708 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -755,7 +755,7 @@ struct ieee80211_tx_info {
 			u8 ampdu_len;
 			u8 antenna;
 			u16 tx_time;
-			void *status_driver_data[19 / sizeof(void *)];
+			u8 status_driver_data[1];
 		} status;
 		struct {
 			struct ieee80211_tx_rate driver_rates[
-- 
2.0.5
