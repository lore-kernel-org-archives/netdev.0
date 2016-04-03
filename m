From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH v2 03/15] wcn36xx: Add helper macros to cast vif to private vif and vice versa
Date: Sun,  3 Apr 2016 15:16:34 -0700
Message-ID: <1459721806-11817-3-git-send-email-bjorn.andersson@linaro.org>
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

Makes the code a little easier to read.

Signed-off-by: Pontus Fuchs <pontus.fuchs@gmail.com>
Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
---
 drivers/net/wireless/ath/wcn36xx/debug.c   | 12 +++---------
 drivers/net/wireless/ath/wcn36xx/main.c    | 16 +++++++---------
 drivers/net/wireless/ath/wcn36xx/pmc.c     |  4 ++--
 drivers/net/wireless/ath/wcn36xx/smd.c     | 24 ++++++++++--------------
 drivers/net/wireless/ath/wcn36xx/txrx.c    |  8 ++------
 drivers/net/wireless/ath/wcn36xx/wcn36xx.h | 12 ++++++++++++
 6 files changed, 36 insertions(+), 40 deletions(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/debug.c b/drivers/net/wireless/ath/wcn36xx/debug.c
index ef44a2da644d..2a6bb62e785c 100644
--- a/drivers/net/wireless/ath/wcn36xx/debug.c
+++ b/drivers/net/wireless/ath/wcn36xx/debug.c
@@ -33,9 +33,7 @@ static ssize_t read_file_bool_bmps(struct file *file, char __user *user_buf,
 	char buf[3];
 
 	list_for_each_entry(vif_priv, &wcn->vif_list, list) {
-			vif = container_of((void *)vif_priv,
-				   struct ieee80211_vif,
-				   drv_priv);
+			vif = wcn36xx_priv_to_vif(vif_priv);
 			if (NL80211_IFTYPE_STATION == vif->type) {
 				if (vif_priv->pw_state == WCN36XX_BMPS)
 					buf[0] = '1';
@@ -70,9 +68,7 @@ static ssize_t write_file_bool_bmps(struct file *file,
 	case 'Y':
 	case '1':
 		list_for_each_entry(vif_priv, &wcn->vif_list, list) {
-			vif = container_of((void *)vif_priv,
-				   struct ieee80211_vif,
-				   drv_priv);
+			vif = wcn36xx_priv_to_vif(vif_priv);
 			if (NL80211_IFTYPE_STATION == vif->type) {
 				wcn36xx_enable_keep_alive_null_packet(wcn, vif);
 				wcn36xx_pmc_enter_bmps_state(wcn, vif);
@@ -83,9 +79,7 @@ static ssize_t write_file_bool_bmps(struct file *file,
 	case 'N':
 	case '0':
 		list_for_each_entry(vif_priv, &wcn->vif_list, list) {
-			vif = container_of((void *)vif_priv,
-				   struct ieee80211_vif,
-				   drv_priv);
+			vif = wcn36xx_priv_to_vif(vif_priv);
 			if (NL80211_IFTYPE_STATION == vif->type)
 				wcn36xx_pmc_exit_bmps_state(wcn, vif);
 		}
diff --git a/drivers/net/wireless/ath/wcn36xx/main.c b/drivers/net/wireless/ath/wcn36xx/main.c
index a27279c2c695..62cb9ffd854c 100644
--- a/drivers/net/wireless/ath/wcn36xx/main.c
+++ b/drivers/net/wireless/ath/wcn36xx/main.c
@@ -346,9 +346,7 @@ static int wcn36xx_config(struct ieee80211_hw *hw, u32 changed)
 		wcn36xx_dbg(WCN36XX_DBG_MAC, "wcn36xx_config channel switch=%d\n",
 			    ch);
 		list_for_each_entry(tmp, &wcn->vif_list, list) {
-			vif = container_of((void *)tmp,
-					   struct ieee80211_vif,
-					   drv_priv);
+			vif = wcn36xx_priv_to_vif(tmp);
 			wcn36xx_smd_switch_channel(wcn, vif, ch);
 		}
 	}
@@ -387,7 +385,7 @@ static int wcn36xx_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 			   struct ieee80211_key_conf *key_conf)
 {
 	struct wcn36xx *wcn = hw->priv;
-	struct wcn36xx_vif *vif_priv = (struct wcn36xx_vif *)vif->drv_priv;
+	struct wcn36xx_vif *vif_priv = wcn36xx_vif_to_priv(vif);
 	struct wcn36xx_sta *sta_priv = vif_priv->sta;
 	int ret = 0;
 	u8 key[WLAN_MAX_KEY_LEN];
@@ -590,7 +588,7 @@ static void wcn36xx_bss_info_changed(struct ieee80211_hw *hw,
 	struct sk_buff *skb = NULL;
 	u16 tim_off, tim_len;
 	enum wcn36xx_hal_link_state link_state;
-	struct wcn36xx_vif *vif_priv = (struct wcn36xx_vif *)vif->drv_priv;
+	struct wcn36xx_vif *vif_priv = wcn36xx_vif_to_priv(vif);
 
 	wcn36xx_dbg(WCN36XX_DBG_MAC, "mac bss info changed vif %p changed 0x%08x\n",
 		    vif, changed);
@@ -757,7 +755,7 @@ static void wcn36xx_remove_interface(struct ieee80211_hw *hw,
 				     struct ieee80211_vif *vif)
 {
 	struct wcn36xx *wcn = hw->priv;
-	struct wcn36xx_vif *vif_priv = (struct wcn36xx_vif *)vif->drv_priv;
+	struct wcn36xx_vif *vif_priv = wcn36xx_vif_to_priv(vif);
 	wcn36xx_dbg(WCN36XX_DBG_MAC, "mac remove interface vif %p\n", vif);
 
 	list_del(&vif_priv->list);
@@ -768,7 +766,7 @@ static int wcn36xx_add_interface(struct ieee80211_hw *hw,
 				 struct ieee80211_vif *vif)
 {
 	struct wcn36xx *wcn = hw->priv;
-	struct wcn36xx_vif *vif_priv = (struct wcn36xx_vif *)vif->drv_priv;
+	struct wcn36xx_vif *vif_priv = wcn36xx_vif_to_priv(vif);
 
 	wcn36xx_dbg(WCN36XX_DBG_MAC, "mac add interface vif %p type %d\n",
 		    vif, vif->type);
@@ -792,7 +790,7 @@ static int wcn36xx_sta_add(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
 			   struct ieee80211_sta *sta)
 {
 	struct wcn36xx *wcn = hw->priv;
-	struct wcn36xx_vif *vif_priv = (struct wcn36xx_vif *)vif->drv_priv;
+	struct wcn36xx_vif *vif_priv = wcn36xx_vif_to_priv(vif);
 	struct wcn36xx_sta *sta_priv = (struct wcn36xx_sta *)sta->drv_priv;
 	wcn36xx_dbg(WCN36XX_DBG_MAC, "mac sta add vif %p sta %pM\n",
 		    vif, sta->addr);
@@ -817,7 +815,7 @@ static int wcn36xx_sta_remove(struct ieee80211_hw *hw,
 			      struct ieee80211_sta *sta)
 {
 	struct wcn36xx *wcn = hw->priv;
-	struct wcn36xx_vif *vif_priv = (struct wcn36xx_vif *)vif->drv_priv;
+	struct wcn36xx_vif *vif_priv = wcn36xx_vif_to_priv(vif);
 	struct wcn36xx_sta *sta_priv = (struct wcn36xx_sta *)sta->drv_priv;
 
 	wcn36xx_dbg(WCN36XX_DBG_MAC, "mac sta remove vif %p sta %pM index %d\n",
diff --git a/drivers/net/wireless/ath/wcn36xx/pmc.c b/drivers/net/wireless/ath/wcn36xx/pmc.c
index 28b515c81b0e..589fe5f70971 100644
--- a/drivers/net/wireless/ath/wcn36xx/pmc.c
+++ b/drivers/net/wireless/ath/wcn36xx/pmc.c
@@ -22,7 +22,7 @@ int wcn36xx_pmc_enter_bmps_state(struct wcn36xx *wcn,
 				 struct ieee80211_vif *vif)
 {
 	int ret = 0;
-	struct wcn36xx_vif *vif_priv = (struct wcn36xx_vif *)vif->drv_priv;
+	struct wcn36xx_vif *vif_priv = wcn36xx_vif_to_priv(vif);
 	/* TODO: Make sure the TX chain clean */
 	ret = wcn36xx_smd_enter_bmps(wcn, vif);
 	if (!ret) {
@@ -42,7 +42,7 @@ int wcn36xx_pmc_enter_bmps_state(struct wcn36xx *wcn,
 int wcn36xx_pmc_exit_bmps_state(struct wcn36xx *wcn,
 				struct ieee80211_vif *vif)
 {
-	struct wcn36xx_vif *vif_priv = (struct wcn36xx_vif *)vif->drv_priv;
+	struct wcn36xx_vif *vif_priv = wcn36xx_vif_to_priv(vif);
 
 	if (WCN36XX_BMPS != vif_priv->pw_state) {
 		wcn36xx_err("Not in BMPS mode, no need to exit from BMPS mode!\n");
diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/ath/wcn36xx/smd.c
index 089a7e445cd6..cc1b3b7a4ff9 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.c
+++ b/drivers/net/wireless/ath/wcn36xx/smd.c
@@ -191,7 +191,7 @@ static void wcn36xx_smd_set_sta_params(struct wcn36xx *wcn,
 		struct ieee80211_sta *sta,
 		struct wcn36xx_hal_config_sta_params *sta_params)
 {
-	struct wcn36xx_vif *priv_vif = (struct wcn36xx_vif *)vif->drv_priv;
+	struct wcn36xx_vif *priv_vif = wcn36xx_vif_to_priv(vif);
 	struct wcn36xx_sta *priv_sta = NULL;
 	if (vif->type == NL80211_IFTYPE_ADHOC ||
 	    vif->type == NL80211_IFTYPE_AP ||
@@ -726,7 +726,7 @@ static int wcn36xx_smd_add_sta_self_rsp(struct wcn36xx *wcn,
 					size_t len)
 {
 	struct wcn36xx_hal_add_sta_self_rsp_msg *rsp;
-	struct wcn36xx_vif *priv_vif = (struct wcn36xx_vif *)vif->drv_priv;
+	struct wcn36xx_vif *priv_vif = wcn36xx_vif_to_priv(vif);
 
 	if (len < sizeof(*rsp))
 		return -EINVAL;
@@ -1175,7 +1175,7 @@ static int wcn36xx_smd_config_bss_rsp(struct wcn36xx *wcn,
 {
 	struct wcn36xx_hal_config_bss_rsp_msg *rsp;
 	struct wcn36xx_hal_config_bss_rsp_params *params;
-	struct wcn36xx_vif *priv_vif = (struct wcn36xx_vif *)vif->drv_priv;
+	struct wcn36xx_vif *priv_vif = wcn36xx_vif_to_priv(vif);
 
 	if (len < sizeof(*rsp))
 		return -EINVAL;
@@ -1217,7 +1217,7 @@ int wcn36xx_smd_config_bss(struct wcn36xx *wcn, struct ieee80211_vif *vif,
 	struct wcn36xx_hal_config_bss_req_msg msg;
 	struct wcn36xx_hal_config_bss_params *bss;
 	struct wcn36xx_hal_config_sta_params *sta_params;
-	struct wcn36xx_vif *vif_priv = (struct wcn36xx_vif *)vif->drv_priv;
+	struct wcn36xx_vif *vif_priv = wcn36xx_vif_to_priv(vif);
 	int ret = 0;
 
 	mutex_lock(&wcn->hal_mutex);
@@ -1343,7 +1343,7 @@ out:
 int wcn36xx_smd_delete_bss(struct wcn36xx *wcn, struct ieee80211_vif *vif)
 {
 	struct wcn36xx_hal_delete_bss_req_msg msg_body;
-	struct wcn36xx_vif *priv_vif = (struct wcn36xx_vif *)vif->drv_priv;
+	struct wcn36xx_vif *priv_vif = wcn36xx_vif_to_priv(vif);
 	int ret = 0;
 
 	mutex_lock(&wcn->hal_mutex);
@@ -1633,7 +1633,7 @@ out:
 int wcn36xx_smd_enter_bmps(struct wcn36xx *wcn, struct ieee80211_vif *vif)
 {
 	struct wcn36xx_hal_enter_bmps_req_msg msg_body;
-	struct wcn36xx_vif *vif_priv = (struct wcn36xx_vif *)vif->drv_priv;
+	struct wcn36xx_vif *vif_priv = wcn36xx_vif_to_priv(vif);
 	int ret = 0;
 
 	mutex_lock(&wcn->hal_mutex);
@@ -1663,7 +1663,7 @@ out:
 int wcn36xx_smd_exit_bmps(struct wcn36xx *wcn, struct ieee80211_vif *vif)
 {
 	struct wcn36xx_hal_enter_bmps_req_msg msg_body;
-	struct wcn36xx_vif *vif_priv = (struct wcn36xx_vif *)vif->drv_priv;
+	struct wcn36xx_vif *vif_priv = wcn36xx_vif_to_priv(vif);
 	int ret = 0;
 
 	mutex_lock(&wcn->hal_mutex);
@@ -1724,7 +1724,7 @@ int wcn36xx_smd_keep_alive_req(struct wcn36xx *wcn,
 			       int packet_type)
 {
 	struct wcn36xx_hal_keep_alive_req_msg msg_body;
-	struct wcn36xx_vif *vif_priv = (struct wcn36xx_vif *)vif->drv_priv;
+	struct wcn36xx_vif *vif_priv = wcn36xx_vif_to_priv(vif);
 	int ret = 0;
 
 	mutex_lock(&wcn->hal_mutex);
@@ -2027,9 +2027,7 @@ static int wcn36xx_smd_missed_beacon_ind(struct wcn36xx *wcn,
 		list_for_each_entry(tmp, &wcn->vif_list, list) {
 			wcn36xx_dbg(WCN36XX_DBG_HAL, "beacon missed bss_index %d\n",
 				    tmp->bss_index);
-			vif = container_of((void *)tmp,
-						 struct ieee80211_vif,
-						 drv_priv);
+			vif = wcn36xx_priv_to_vif(tmp);
 			ieee80211_connection_loss(vif);
 		}
 		return 0;
@@ -2044,9 +2042,7 @@ static int wcn36xx_smd_missed_beacon_ind(struct wcn36xx *wcn,
 		if (tmp->bss_index == rsp->bss_index) {
 			wcn36xx_dbg(WCN36XX_DBG_HAL, "beacon missed bss_index %d\n",
 				    rsp->bss_index);
-			vif = container_of((void *)tmp,
-						 struct ieee80211_vif,
-						 drv_priv);
+			vif = wcn36xx_priv_to_vif(tmp);
 			ieee80211_connection_loss(vif);
 			return 0;
 		}
diff --git a/drivers/net/wireless/ath/wcn36xx/txrx.c b/drivers/net/wireless/ath/wcn36xx/txrx.c
index 9bec8237231d..37f13410e633 100644
--- a/drivers/net/wireless/ath/wcn36xx/txrx.c
+++ b/drivers/net/wireless/ath/wcn36xx/txrx.c
@@ -102,9 +102,7 @@ static inline struct wcn36xx_vif *get_vif_by_addr(struct wcn36xx *wcn,
 	struct wcn36xx_vif *vif_priv = NULL;
 	struct ieee80211_vif *vif = NULL;
 	list_for_each_entry(vif_priv, &wcn->vif_list, list) {
-			vif = container_of((void *)vif_priv,
-				   struct ieee80211_vif,
-				   drv_priv);
+			vif = wcn36xx_priv_to_vif(vif_priv);
 			if (memcmp(vif->addr, addr, ETH_ALEN) == 0)
 				return vif_priv;
 	}
@@ -167,9 +165,7 @@ static void wcn36xx_set_tx_data(struct wcn36xx_tx_bd *bd,
 	 */
 	if (sta_priv) {
 		__vif_priv = sta_priv->vif;
-		vif = container_of((void *)__vif_priv,
-				   struct ieee80211_vif,
-				   drv_priv);
+		vif = wcn36xx_priv_to_vif(__vif_priv);
 
 		bd->dpu_sign = sta_priv->ucast_dpu_sign;
 		if (vif->type == NL80211_IFTYPE_STATION) {
diff --git a/drivers/net/wireless/ath/wcn36xx/wcn36xx.h b/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
index 7b41e833e18c..c3ba07ed1db5 100644
--- a/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
+++ b/drivers/net/wireless/ath/wcn36xx/wcn36xx.h
@@ -263,4 +263,16 @@ struct ieee80211_sta *wcn36xx_priv_to_sta(struct wcn36xx_sta *sta_priv)
 	return container_of((void *)sta_priv, struct ieee80211_sta, drv_priv);
 }
 
+static inline
+struct wcn36xx_vif *wcn36xx_vif_to_priv(struct ieee80211_vif *vif)
+{
+	return (struct wcn36xx_vif *) vif->drv_priv;
+}
+
+static inline
+struct ieee80211_vif *wcn36xx_priv_to_vif(struct wcn36xx_vif *vif_priv)
+{
+	return container_of((void *) vif_priv, struct ieee80211_vif, drv_priv);
+}
+
 #endif	/* _WCN36XX_H_ */
-- 
2.5.0
