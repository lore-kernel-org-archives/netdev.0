From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH v2 08/15] wcn36xx: Remove sta pointer in private vif struct
Date: Sun,  3 Apr 2016 15:16:39 -0700
Message-ID: <1459721806-11817-8-git-send-email-bjorn.andersson@linaro.org>
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

This does not work with multiple sta's in a vif.

Signed-off-by: Pontus Fuchs <pontus.fuchs@gmail.com>
Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---
 drivers/net/wireless/ath/wcn36xx/main.c    |  3 ---
 drivers/net/wireless/ath/wcn36xx/smd.c     | 28 +++++++++++++++-------------
 drivers/net/wireless/ath/wcn36xx/wcn36xx.h |  1 -
 3 files changed, 15 insertions(+), 17 deletions(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/main.c b/drivers/net/wireless/ath/wcn36xx/main.c
index a23738deb5b3..7c06ca9fdd2c 100644
--- a/drivers/net/wireless/ath/wcn36xx/main.c
+++ b/drivers/net/wireless/ath/wcn36xx/main.c
@@ -796,7 +796,6 @@ static int wcn36xx_sta_add(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
 		    vif, sta->addr);
 
 	spin_lock_init(&sta_priv->ampdu_lock);
-	vif_priv->sta = sta_priv;
 	sta_priv->vif = vif_priv;
 	/*
 	 * For STA mode HW will be configured on BSS_CHANGED_ASSOC because
@@ -815,14 +814,12 @@ static int wcn36xx_sta_remove(struct ieee80211_hw *hw,
 			      struct ieee80211_sta *sta)
 {
 	struct wcn36xx *wcn = hw->priv;
-	struct wcn36xx_vif *vif_priv = wcn36xx_vif_to_priv(vif);
 	struct wcn36xx_sta *sta_priv = wcn36xx_sta_to_priv(sta);
 
 	wcn36xx_dbg(WCN36XX_DBG_MAC, "mac sta remove vif %p sta %pM index %d\n",
 		    vif, sta->addr, sta_priv->sta_index);
 
 	wcn36xx_smd_delete_sta(wcn, sta_priv->sta_index);
-	vif_priv->sta = NULL;
 	sta_priv->vif = NULL;
 	return 0;
 }
diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/ath/wcn36xx/smd.c
index ff56138528b6..76c6856ed932 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.c
+++ b/drivers/net/wireless/ath/wcn36xx/smd.c
@@ -1170,6 +1170,7 @@ static int wcn36xx_smd_config_bss_v1(struct wcn36xx *wcn,
 
 static int wcn36xx_smd_config_bss_rsp(struct wcn36xx *wcn,
 				      struct ieee80211_vif *vif,
+				      struct ieee80211_sta *sta,
 				      void *buf,
 				      size_t len)
 {
@@ -1200,9 +1201,10 @@ static int wcn36xx_smd_config_bss_rsp(struct wcn36xx *wcn,
 
 	vif_priv->bss_index = params->bss_index;
 
-	if (vif_priv->sta) {
-		vif_priv->sta->bss_sta_index =  params->bss_sta_index;
-		vif_priv->sta->bss_dpu_desc_index = params->dpu_desc_index;
+	if (sta) {
+		struct wcn36xx_sta *sta_priv = wcn36xx_sta_to_priv(sta);
+		sta_priv->bss_sta_index = params->bss_sta_index;
+		sta_priv->bss_dpu_desc_index = params->dpu_desc_index;
 	}
 
 	vif_priv->self_ucast_dpu_sign = params->ucast_dpu_signature;
@@ -1329,6 +1331,7 @@ int wcn36xx_smd_config_bss(struct wcn36xx *wcn, struct ieee80211_vif *vif,
 	}
 	ret = wcn36xx_smd_config_bss_rsp(wcn,
 					 vif,
+					 sta,
 					 wcn->hal_buf,
 					 wcn->hal_rsp_len);
 	if (ret) {
@@ -2058,25 +2061,24 @@ static int wcn36xx_smd_delete_sta_context_ind(struct wcn36xx *wcn,
 {
 	struct wcn36xx_hal_delete_sta_context_ind_msg *rsp = buf;
 	struct wcn36xx_vif *tmp;
-	struct ieee80211_sta *sta = NULL;
+	struct ieee80211_sta *sta;
 
 	if (len != sizeof(*rsp)) {
 		wcn36xx_warn("Corrupted delete sta indication\n");
 		return -EIO;
 	}
 
+	wcn36xx_dbg(WCN36XX_DBG_HAL, "delete station indication %pM index %d\n",
+		    rsp->addr2, rsp->sta_id);
+
 	list_for_each_entry(tmp, &wcn->vif_list, list) {
-		if (sta && (tmp->sta->sta_index == rsp->sta_id)) {
-			sta = container_of((void *)tmp->sta,
-						 struct ieee80211_sta,
-						 drv_priv);
-			wcn36xx_dbg(WCN36XX_DBG_HAL,
-				    "delete station indication %pM index %d\n",
-				    rsp->addr2,
-				    rsp->sta_id);
+		rcu_read_lock();
+		sta = ieee80211_find_sta(wcn36xx_priv_to_vif(tmp), rsp->addr2);
+		if (sta)
 			ieee80211_report_low_ack(sta, 0);
+		rcu_read_unlock();
+		if (sta)
 			return 0;
-		}
 	}
 
 	wcn36xx_warn("STA with addr %pM and index %d not found\n",
diff --git a/drivers/net/wireless/ath/wcn36xx/wcn36xx.h b/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
index c368a34c8de7..54000db0af1a 100644
--- a/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
+++ b/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
@@ -125,7 +125,6 @@ struct wcn36xx_platform_ctrl_ops {
  */
 struct wcn36xx_vif {
 	struct list_head list;
-	struct wcn36xx_sta *sta;
 	u8 dtim_period;
 	enum ani_ed_type encrypt_type;
 	bool is_joining;
-- 
2.5.0
