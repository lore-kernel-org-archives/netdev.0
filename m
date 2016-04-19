From: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH v3 14/18] wcn36xx: Implement multicast filtering
Date: Mon, 18 Apr 2016 22:00:52 -0700
Message-ID: <1461042056-10607-15-git-send-email-bjorn.andersson@linaro.org>
References: <1461042056-10607-1-git-send-email-bjorn.andersson@linaro.org>
Cc: Pontus Fuchs <pontus.fuchs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eugene Krasnikov <k.eugene.e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1461042056-10607-1-git-send-email-bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Pontus Fuchs <pontus.fuchs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Pass the multicast list to FW.

This patch also adds a way to build the smd command in place. This is
needed because the MC list command is too big for the stack.

Signed-off-by: Pontus Fuchs <pontus.fuchs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
[bjorn: dropped FIF_PROMISC_IN_BSS usage]
Signed-off-by: Bjorn Andersson <bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 drivers/net/wireless/ath/wcn36xx/hal.h  |  6 ++--
 drivers/net/wireless/ath/wcn36xx/main.c | 50 ++++++++++++++++++++++++++++++--
 drivers/net/wireless/ath/wcn36xx/smd.c  | 51 +++++++++++++++++++++++++++++++++
 drivers/net/wireless/ath/wcn36xx/smd.h  |  3 ++
 4 files changed, 104 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/hal.h b/drivers/net/wireless/ath/wcn36xx/hal.h
index 433d9801a0ae..ec64c47f918b 100644
--- a/drivers/net/wireless/ath/wcn36xx/hal.h
+++ b/drivers/net/wireless/ath/wcn36xx/hal.h
@@ -4267,9 +4267,9 @@ struct wcn36xx_hal_rcv_flt_mc_addr_list_type {
 	u8 data_offset;
 
 	u32 mc_addr_count;
-	u8 mc_addr[ETH_ALEN][WCN36XX_HAL_MAX_NUM_MULTICAST_ADDRESS];
+	u8 mc_addr[WCN36XX_HAL_MAX_NUM_MULTICAST_ADDRESS][ETH_ALEN];
 	u8 bss_index;
-};
+} __packed;
 
 struct wcn36xx_hal_set_pkt_filter_rsp_msg {
 	struct wcn36xx_hal_msg_header header;
@@ -4323,7 +4323,7 @@ struct wcn36xx_hal_rcv_flt_pkt_clear_rsp_msg {
 struct wcn36xx_hal_rcv_flt_pkt_set_mc_list_req_msg {
 	struct wcn36xx_hal_msg_header header;
 	struct wcn36xx_hal_rcv_flt_mc_addr_list_type mc_addr_list;
-};
+} __packed;
 
 struct wcn36xx_hal_rcv_flt_pkt_set_mc_list_rsp_msg {
 	struct wcn36xx_hal_msg_header header;
diff --git a/drivers/net/wireless/ath/wcn36xx/main.c b/drivers/net/wireless/ath/wcn36xx/main.c
index 253cece1b660..c0ba7b0775b3 100644
--- a/drivers/net/wireless/ath/wcn36xx/main.c
+++ b/drivers/net/wireless/ath/wcn36xx/main.c
@@ -287,6 +287,7 @@ static int wcn36xx_start(struct ieee80211_hw *hw)
 	}
 
 	wcn36xx_detect_chip_version(wcn);
+	wcn36xx_smd_update_cfg(wcn, WCN36XX_HAL_CFG_ENABLE_MC_ADDR_LIST, 1);
 
 	/* DMA channel initialization */
 	ret = wcn36xx_dxe_init(wcn);
@@ -354,15 +355,57 @@ static int wcn36xx_config(struct ieee80211_hw *hw, u32 changed)
 	return 0;
 }
 
-#define WCN36XX_SUPPORTED_FILTERS (0)
-
 static void wcn36xx_configure_filter(struct ieee80211_hw *hw,
 				     unsigned int changed,
 				     unsigned int *total, u64 multicast)
 {
+	struct wcn36xx_hal_rcv_flt_mc_addr_list_type *fp;
+	struct wcn36xx *wcn = hw->priv;
+	struct wcn36xx_vif *tmp;
+	struct ieee80211_vif *vif = NULL;
+
 	wcn36xx_dbg(WCN36XX_DBG_MAC, "mac configure filter\n");
 
-	*total &= WCN36XX_SUPPORTED_FILTERS;
+	*total &= FIF_ALLMULTI;
+
+	fp = (void *)(unsigned long)multicast;
+	list_for_each_entry(tmp, &wcn->vif_list, list) {
+		vif = wcn36xx_priv_to_vif(tmp);
+
+		/* FW handles MC filtering only when connected as STA */
+		if (*total & FIF_ALLMULTI)
+			wcn36xx_smd_set_mc_list(wcn, vif, NULL);
+		else if (NL80211_IFTYPE_STATION == vif->type && tmp->sta_assoc)
+			wcn36xx_smd_set_mc_list(wcn, vif, fp);
+	}
+	kfree(fp);
+}
+
+static u64 wcn36xx_prepare_multicast(struct ieee80211_hw *hw,
+				     struct netdev_hw_addr_list *mc_list)
+{
+	struct wcn36xx_hal_rcv_flt_mc_addr_list_type *fp;
+	struct netdev_hw_addr *ha;
+
+	wcn36xx_dbg(WCN36XX_DBG_MAC, "mac prepare multicast list\n");
+	fp = kzalloc(sizeof(*fp), GFP_ATOMIC);
+	if (!fp) {
+		wcn36xx_err("Out of memory setting filters.\n");
+		return 0;
+	}
+
+	fp->mc_addr_count = 0;
+	/* update multicast filtering parameters */
+	if (netdev_hw_addr_list_count(mc_list) <=
+	    WCN36XX_HAL_MAX_NUM_MULTICAST_ADDRESS) {
+		netdev_hw_addr_list_for_each(ha, mc_list) {
+			memcpy(fp->mc_addr[fp->mc_addr_count],
+					ha->addr, ETH_ALEN);
+			fp->mc_addr_count++;
+		}
+	}
+
+	return (u64)(unsigned long)fp;
 }
 
 static void wcn36xx_tx(struct ieee80211_hw *hw,
@@ -920,6 +963,7 @@ static const struct ieee80211_ops wcn36xx_ops = {
 	.resume			= wcn36xx_resume,
 #endif
 	.config			= wcn36xx_config,
+	.prepare_multicast	= wcn36xx_prepare_multicast,
 	.configure_filter       = wcn36xx_configure_filter,
 	.tx			= wcn36xx_tx,
 	.set_key		= wcn36xx_set_key,
diff --git a/drivers/net/wireless/ath/wcn36xx/smd.c b/drivers/net/wireless/ath/wcn36xx/smd.c
index e0d5631657c1..b1bdc229e560 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.c
+++ b/drivers/net/wireless/ath/wcn36xx/smd.c
@@ -271,6 +271,16 @@ out:
 	return ret;
 }
 
+static void init_hal_msg(struct wcn36xx_hal_msg_header *hdr,
+			 enum wcn36xx_hal_host_msg_type msg_type,
+			 size_t msg_size)
+{
+	memset(hdr, 0, msg_size + sizeof(*hdr));
+	hdr->msg_type = msg_type;
+	hdr->msg_version = WCN36XX_HAL_MSG_VERSION0;
+	hdr->len = msg_size + sizeof(*hdr);
+}
+
 #define INIT_HAL_MSG(msg_body, type) \
 	do {								\
 		memset(&msg_body, 0, sizeof(msg_body));			\
@@ -2144,6 +2154,46 @@ out:
 	mutex_unlock(&wcn->hal_mutex);
 	return ret;
 }
+
+int wcn36xx_smd_set_mc_list(struct wcn36xx *wcn,
+			    struct ieee80211_vif *vif,
+			    struct wcn36xx_hal_rcv_flt_mc_addr_list_type *fp)
+{
+	struct wcn36xx_vif *vif_priv = wcn36xx_vif_to_priv(vif);
+	struct wcn36xx_hal_rcv_flt_pkt_set_mc_list_req_msg *msg_body = NULL;
+	int ret = 0;
+
+	mutex_lock(&wcn->hal_mutex);
+
+	msg_body = (struct wcn36xx_hal_rcv_flt_pkt_set_mc_list_req_msg *)
+		   wcn->hal_buf;
+	init_hal_msg(&msg_body->header, WCN36XX_HAL_8023_MULTICAST_LIST_REQ,
+		     sizeof(msg_body->mc_addr_list));
+
+	/* An empty list means all mc traffic will be received */
+	if (fp)
+		memcpy(&msg_body->mc_addr_list, fp,
+		       sizeof(msg_body->mc_addr_list));
+	else
+		msg_body->mc_addr_list.mc_addr_count = 0;
+
+	msg_body->mc_addr_list.bss_index = vif_priv->bss_index;
+
+	ret = wcn36xx_smd_send_and_wait(wcn, msg_body->header.len);
+	if (ret) {
+		wcn36xx_err("Sending HAL_8023_MULTICAST_LIST failed\n");
+		goto out;
+	}
+	ret = wcn36xx_smd_rsp_status_check(wcn->hal_buf, wcn->hal_rsp_len);
+	if (ret) {
+		wcn36xx_err("HAL_8023_MULTICAST_LIST rsp failed err=%d\n", ret);
+		goto out;
+	}
+out:
+	mutex_unlock(&wcn->hal_mutex);
+	return ret;
+}
+
 static void wcn36xx_smd_rsp_process(struct wcn36xx *wcn, void *buf, size_t len)
 {
 	struct wcn36xx_hal_msg_header *msg_header = buf;
@@ -2185,6 +2235,7 @@ static void wcn36xx_smd_rsp_process(struct wcn36xx *wcn, void *buf, size_t len)
 	case WCN36XX_HAL_UPDATE_SCAN_PARAM_RSP:
 	case WCN36XX_HAL_CH_SWITCH_RSP:
 	case WCN36XX_HAL_FEATURE_CAPS_EXCHANGE_RSP:
+	case WCN36XX_HAL_8023_MULTICAST_LIST_RSP:
 		memcpy(wcn->hal_buf, buf, len);
 		wcn->hal_rsp_len = len;
 		complete(&wcn->hal_rsp_compl);
diff --git a/drivers/net/wireless/ath/wcn36xx/smd.h b/drivers/net/wireless/ath/wcn36xx/smd.h
index 8361f9e3995b..c1b76d75cf85 100644
--- a/drivers/net/wireless/ath/wcn36xx/smd.h
+++ b/drivers/net/wireless/ath/wcn36xx/smd.h
@@ -136,4 +136,7 @@ int wcn36xx_smd_del_ba(struct wcn36xx *wcn, u16 tid, u8 sta_index);
 int wcn36xx_smd_trigger_ba(struct wcn36xx *wcn, u8 sta_index);
 
 int wcn36xx_smd_update_cfg(struct wcn36xx *wcn, u32 cfg_id, u32 value);
+int wcn36xx_smd_set_mc_list(struct wcn36xx *wcn,
+			    struct ieee80211_vif *vif,
+			    struct wcn36xx_hal_rcv_flt_mc_addr_list_type *fp);
 #endif	/* _SMD_H_ */
-- 
2.5.0

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
