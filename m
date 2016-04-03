From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH v2 06/15] wcn36xx: Add helper macros to cast sta to priv
Date: Sun,  3 Apr 2016 15:16:37 -0700
Message-ID: <1459721806-11817-6-git-send-email-bjorn.andersson@linaro.org>
References: <1459721806-11817-1-git-send-email-bjorn.andersson@linaro.org>
Cc: Pontus Fuchs <pontus.fuchs@gmail.com>, wcn36xx@lists.infradead.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eugene Krasnikov <k.eugene.e@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459721806-11817-1-git-send-email-bjorn.andersson@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pontus Fuchs <pontus.fuchs@gmail.com>

While poking at this I also change two related things. I rename one
variable to make the names consistent. I also move one assignment of
priv_sta to the declaration to save a few lines.

Signed-off-by: Pontus Fuchs <pontus.fuchs@gmail.com>
Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---
 drivers/net/wireless/ath/wcn36xx/main.c    | 14 ++++++--------
 drivers/net/wireless/ath/wcn36xx/smd.c     | 12 ++++++------
 drivers/net/wireless/ath/wcn36xx/wcn36xx.h |  6 ++++++
 3 files changed, 18 insertions(+), 14 deletions(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/main.c b/drivers/net/wireless/ath/wcn36xx/main.c
index 4781b5e8deb3..30f015d3a9e6 100644
--- a/drivers/net/wireless/ath/wcn36xx/main.c
+++ b/drivers/net/wireless/ath/wcn36xx/main.c
@@ -373,7 +373,7 @@ static void wcn36xx_tx(struct ieee80211_hw *hw,
 	struct wcn36xx_sta *sta_priv = NULL;
 
 	if (control->sta)
-		sta_priv = (struct wcn36xx_sta *)control->sta->drv_priv;
+		sta_priv = wcn36xx_sta_to_priv(control->sta);
 
 	if (wcn36xx_start_tx(wcn, sta_priv, skb))
 		ieee80211_free_txskb(wcn->hw, skb);
@@ -518,7 +518,7 @@ static void wcn36xx_update_allowed_rates(struct ieee80211_sta *sta,
 {
 	int i, size;
 	u16 *rates_table;
-	struct wcn36xx_sta *sta_priv = (struct wcn36xx_sta *)sta->drv_priv;
+	struct wcn36xx_sta *sta_priv = wcn36xx_sta_to_priv(sta);
 	u32 rates = sta->supp_rates[band];
 
 	memset(&sta_priv->supported_rates, 0,
@@ -661,7 +661,7 @@ static void wcn36xx_bss_info_changed(struct ieee80211_hw *hw,
 				rcu_read_unlock();
 				goto out;
 			}
-			sta_priv = (struct wcn36xx_sta *)sta->drv_priv;
+			sta_priv = wcn36xx_sta_to_priv(sta);
 
 			wcn36xx_update_allowed_rates(sta, WCN36XX_BAND(wcn));
 
@@ -791,7 +791,7 @@ static int wcn36xx_sta_add(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
 {
 	struct wcn36xx *wcn = hw->priv;
 	struct wcn36xx_vif *vif_priv = wcn36xx_vif_to_priv(vif);
-	struct wcn36xx_sta *sta_priv = (struct wcn36xx_sta *)sta->drv_priv;
+	struct wcn36xx_sta *sta_priv = wcn36xx_sta_to_priv(sta);
 	wcn36xx_dbg(WCN36XX_DBG_MAC, "mac sta add vif %p sta %pM\n",
 		    vif, sta->addr);
 
@@ -816,7 +816,7 @@ static int wcn36xx_sta_remove(struct ieee80211_hw *hw,
 {
 	struct wcn36xx *wcn = hw->priv;
 	struct wcn36xx_vif *vif_priv = wcn36xx_vif_to_priv(vif);
-	struct wcn36xx_sta *sta_priv = (struct wcn36xx_sta *)sta->drv_priv;
+	struct wcn36xx_sta *sta_priv = wcn36xx_sta_to_priv(sta);
 
 	wcn36xx_dbg(WCN36XX_DBG_MAC, "mac sta remove vif %p sta %pM index %d\n",
 		    vif, sta->addr, sta_priv->sta_index);
@@ -858,7 +858,7 @@ static int wcn36xx_ampdu_action(struct ieee80211_hw *hw,
 		    struct ieee80211_ampdu_params *params)
 {
 	struct wcn36xx *wcn = hw->priv;
-	struct wcn36xx_sta *sta_priv = NULL;
+	struct wcn36xx_sta *sta_priv = wcn36xx_sta_to_priv(params->sta);
 	struct ieee80211_sta *sta = params->sta;
 	enum ieee80211_ampdu_mlme_action action = params->action;
 	u16 tid = params->tid;
@@ -867,8 +867,6 @@ static int wcn36xx_ampdu_action(struct ieee80211_hw *hw,
 	wcn36xx_dbg(WCN36XX_DBG_MAC, "mac ampdu action action %d tid %d\n",
 		    action, tid);
 
-	sta_priv = (struct wcn36xx_sta *)sta->drv_priv;
-
 	switch (action) {
 	case IEEE80211_AMPDU_RX_START:
 		sta_priv->tid = tid;
diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/ath/wcn36xx/smd.c
index 6d4aa9250ca8..ff56138528b6 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.c
+++ b/drivers/net/wireless/ath/wcn36xx/smd.c
@@ -192,7 +192,7 @@ static void wcn36xx_smd_set_sta_params(struct wcn36xx *wcn,
 		struct wcn36xx_hal_config_sta_params *sta_params)
 {
 	struct wcn36xx_vif *vif_priv = wcn36xx_vif_to_priv(vif);
-	struct wcn36xx_sta *priv_sta = NULL;
+	struct wcn36xx_sta *sta_priv = NULL;
 	if (vif->type == NL80211_IFTYPE_ADHOC ||
 	    vif->type == NL80211_IFTYPE_AP ||
 	    vif->type == NL80211_IFTYPE_MESH_POINT) {
@@ -228,17 +228,17 @@ static void wcn36xx_smd_set_sta_params(struct wcn36xx *wcn,
 	sta_params->p2p = 0;
 
 	if (sta) {
-		priv_sta = (struct wcn36xx_sta *)sta->drv_priv;
+		sta_priv = wcn36xx_sta_to_priv(sta);
 		if (NL80211_IFTYPE_STATION == vif->type)
 			memcpy(&sta_params->bssid, sta->addr, ETH_ALEN);
 		else
 			memcpy(&sta_params->mac, sta->addr, ETH_ALEN);
 		sta_params->wmm_enabled = sta->wme;
 		sta_params->max_sp_len = sta->max_sp;
-		sta_params->aid = priv_sta->aid;
+		sta_params->aid = sta_priv->aid;
 		wcn36xx_smd_set_sta_ht_params(sta, sta_params);
-		memcpy(&sta_params->supported_rates, &priv_sta->supported_rates,
-			sizeof(priv_sta->supported_rates));
+		memcpy(&sta_params->supported_rates, &sta_priv->supported_rates,
+			sizeof(sta_priv->supported_rates));
 	} else {
 		wcn36xx_set_default_rates(&sta_params->supported_rates);
 		wcn36xx_smd_set_sta_default_ht_params(sta_params);
@@ -969,7 +969,7 @@ static int wcn36xx_smd_config_sta_rsp(struct wcn36xx *wcn,
 {
 	struct wcn36xx_hal_config_sta_rsp_msg *rsp;
 	struct config_sta_rsp_params *params;
-	struct wcn36xx_sta *sta_priv = (struct wcn36xx_sta *)sta->drv_priv;
+	struct wcn36xx_sta *sta_priv = wcn36xx_sta_to_priv(sta);
 
 	if (len < sizeof(*rsp))
 		return -EINVAL;
diff --git a/drivers/net/wireless/ath/wcn36xx/wcn36xx.h b/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
index c3ba07ed1db5..c368a34c8de7 100644
--- a/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
+++ b/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
@@ -275,4 +275,10 @@ struct ieee80211_vif *wcn36xx_priv_to_vif(struct wcn36xx_vif *vif_priv)
 	return container_of((void *) vif_priv, struct ieee80211_vif, drv_priv);
 }
 
+static inline
+struct wcn36xx_sta *wcn36xx_sta_to_priv(struct ieee80211_sta *sta)
+{
+	return (struct wcn36xx_sta *)sta->drv_priv;
+}
+
 #endif	/* _WCN36XX_H_ */
-- 
2.5.0
