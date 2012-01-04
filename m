From: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: [PATCH 3/6] ath6kl: create core.c
Date: Thu, 05 Jan 2012 01:08:51 +0200
Message-ID: <20120104230850.32306.46075.stgit@x201>
References: <20120104230429.32306.75965.stgit@x201>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-next-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath6kl-devel-zC7DfRvBq/JWk0Htik3J/w@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120104230429.32306.75965.stgit@x201>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Currently core functions are spread between various files, group all
the functions into file and rename the functions to follow the style
used elsewhere in the driver. This will make it easier to a separate core
module.

Also fix a bug where wiphy is freed too early.

Signed-off-by: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
---
 drivers/net/wireless/ath/ath6kl/Makefile   |    2 
 drivers/net/wireless/ath/ath6kl/cfg80211.c |   94 ++-------
 drivers/net/wireless/ath/ath6kl/cfg80211.h |    4 
 drivers/net/wireless/ath/ath6kl/common.h   |    3 
 drivers/net/wireless/ath/ath6kl/core.c     |  288 ++++++++++++++++++++++++++++
 drivers/net/wireless/ath/ath6kl/core.h     |    9 +
 drivers/net/wireless/ath/ath6kl/init.c     |  205 --------------------
 drivers/net/wireless/ath/ath6kl/sdio.c     |    4 
 drivers/net/wireless/ath/ath6kl/usb.c      |    8 -
 9 files changed, 333 insertions(+), 284 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath6kl/core.c

diff --git a/drivers/net/wireless/ath/ath6kl/Makefile b/drivers/net/wireless/ath/ath6kl/Makefile
index e14cef9..9bb69a8 100644
--- a/drivers/net/wireless/ath/ath6kl/Makefile
+++ b/drivers/net/wireless/ath/ath6kl/Makefile
@@ -31,6 +31,7 @@ ath6kl_sdio-y += init.o
 ath6kl_sdio-y += main.o
 ath6kl_sdio-y += txrx.o
 ath6kl_sdio-y += wmi.o
+ath6kl_sdio-y += core.o
 ath6kl_sdio-y += sdio.o
 ath6kl_sdio-$(CONFIG_NL80211_TESTMODE) += testmode.o
 
@@ -44,6 +45,7 @@ ath6kl_usb-y += init.o
 ath6kl_usb-y += main.o
 ath6kl_usb-y += txrx.o
 ath6kl_usb-y += wmi.o
+ath6kl_usb-y += core.o
 ath6kl_usb-y += usb.o
 ath6kl_usb-$(CONFIG_NL80211_TESTMODE) += testmode.o
 
diff --git a/drivers/net/wireless/ath/ath6kl/cfg80211.c b/drivers/net/wireless/ath/ath6kl/cfg80211.c
index 5f2c137..64043f8 100644
--- a/drivers/net/wireless/ath/ath6kl/cfg80211.c
+++ b/drivers/net/wireless/ath/ath6kl/cfg80211.c
@@ -22,10 +22,6 @@
 #include "hif-ops.h"
 #include "testmode.h"
 
-static unsigned int ath6kl_p2p;
-
-module_param(ath6kl_p2p, uint, 0644);
-
 #define RATETAB_ENT(_rate, _rateid, _flags) {   \
 	.bitrate    = (_rate),                  \
 	.flags      = (_flags),                 \
@@ -2629,68 +2625,6 @@ void ath6kl_cfg80211_stop_all(struct ath6kl *ar)
 		ath6kl_cfg80211_stop(vif);
 }
 
-struct ath6kl *ath6kl_core_alloc(struct device *dev)
-{
-	struct ath6kl *ar;
-	struct wiphy *wiphy;
-	u8 ctr;
-
-	/* create a new wiphy for use with cfg80211 */
-	wiphy = wiphy_new(&ath6kl_cfg80211_ops, sizeof(struct ath6kl));
-
-	if (!wiphy) {
-		ath6kl_err("couldn't allocate wiphy device\n");
-		return NULL;
-	}
-
-	ar = wiphy_priv(wiphy);
-	ar->p2p = !!ath6kl_p2p;
-	ar->wiphy = wiphy;
-	ar->dev = dev;
-
-	ar->vif_max = 1;
-
-	ar->max_norm_iface = 1;
-
-	spin_lock_init(&ar->lock);
-	spin_lock_init(&ar->mcastpsq_lock);
-	spin_lock_init(&ar->list_lock);
-
-	init_waitqueue_head(&ar->event_wq);
-	sema_init(&ar->sem, 1);
-
-	INIT_LIST_HEAD(&ar->amsdu_rx_buffer_queue);
-	INIT_LIST_HEAD(&ar->vif_list);
-
-	clear_bit(WMI_ENABLED, &ar->flag);
-	clear_bit(SKIP_SCAN, &ar->flag);
-	clear_bit(DESTROY_IN_PROGRESS, &ar->flag);
-
-	ar->listen_intvl_t = A_DEFAULT_LISTEN_INTERVAL;
-	ar->listen_intvl_b = 0;
-	ar->tx_pwr = 0;
-
-	ar->intra_bss = 1;
-	ar->lrssi_roam_threshold = DEF_LRSSI_ROAM_THRESHOLD;
-
-	ar->state = ATH6KL_STATE_OFF;
-
-	memset((u8 *)ar->sta_list, 0,
-	       AP_MAX_NUM_STA * sizeof(struct ath6kl_sta));
-
-	/* Init the PS queues */
-	for (ctr = 0; ctr < AP_MAX_NUM_STA; ctr++) {
-		spin_lock_init(&ar->sta_list[ctr].psq_lock);
-		skb_queue_head_init(&ar->sta_list[ctr].psq);
-	}
-
-	skb_queue_head_init(&ar->mcastpsq);
-
-	memcpy(ar->ap_country_code, DEF_AP_COUNTRY_CODE, 3);
-
-	return ar;
-}
-
 static int ath6kl_cfg80211_vif_init(struct ath6kl_vif *vif)
 {
 	vif->aggr_cntxt = aggr_init(vif->ndev);
@@ -2838,10 +2772,30 @@ int ath6kl_cfg80211_init(struct ath6kl *ar)
 void ath6kl_cfg80211_cleanup(struct ath6kl *ar)
 {
 	wiphy_unregister(ar->wiphy);
+}
 
-	/*
-	 * FIXME: should be removed as we remove wiphy in
-	 * ath6kl_core_free(). Most likely this causes a use after free.
-	 */
+struct ath6kl *ath6kl_cfg80211_create(void)
+{
+	struct ath6kl *ar;
+	struct wiphy *wiphy;
+
+	/* create a new wiphy for use with cfg80211 */
+	wiphy = wiphy_new(&ath6kl_cfg80211_ops, sizeof(struct ath6kl));
+
+	if (!wiphy) {
+		ath6kl_err("couldn't allocate wiphy device\n");
+		return NULL;
+	}
+
+	ar = wiphy_priv(wiphy);
+	ar->wiphy = wiphy;
+
+	return ar;
+}
+
+/* Note: ar variable must not be accessed after calling this! */
+void ath6kl_cfg80211_destroy(struct ath6kl *ar)
+{
 	wiphy_free(ar->wiphy);
 }
+
diff --git a/drivers/net/wireless/ath/ath6kl/cfg80211.h b/drivers/net/wireless/ath/ath6kl/cfg80211.h
index 08d9769..3c693b7 100644
--- a/drivers/net/wireless/ath/ath6kl/cfg80211.h
+++ b/drivers/net/wireless/ath/ath6kl/cfg80211.h
@@ -27,7 +27,6 @@ enum ath6kl_cfg_suspend_mode {
 struct net_device *ath6kl_interface_add(struct ath6kl *ar, char *name,
 					enum nl80211_iftype type,
 					u8 fw_vif_idx, u8 nw_type);
-struct ath6kl *ath6kl_core_alloc(struct device *dev);
 void ath6kl_cfg80211_scan_complete_event(struct ath6kl_vif *vif, bool aborted);
 
 void ath6kl_cfg80211_connect_event(struct ath6kl_vif *vif, u16 channel,
@@ -58,4 +57,7 @@ void ath6kl_cfg80211_stop_all(struct ath6kl *ar);
 int ath6kl_cfg80211_init(struct ath6kl *ar);
 void ath6kl_cfg80211_cleanup(struct ath6kl *ar);
 
+struct ath6kl *ath6kl_cfg80211_create(void);
+void ath6kl_cfg80211_destroy(struct ath6kl *ar);
+
 #endif /* ATH6KL_CFG80211_H */
diff --git a/drivers/net/wireless/ath/ath6kl/common.h b/drivers/net/wireless/ath/ath6kl/common.h
index bfd6597..f89f1e1 100644
--- a/drivers/net/wireless/ath/ath6kl/common.h
+++ b/drivers/net/wireless/ath/ath6kl/common.h
@@ -79,8 +79,5 @@ struct ath6kl;
 enum htc_credit_dist_reason;
 struct ath6kl_htc_credit_info;
 
-struct ath6kl *ath6kl_core_alloc(struct device *sdev);
-int ath6kl_core_init(struct ath6kl *ar);
-void ath6kl_core_cleanup(struct ath6kl *ar);
 struct sk_buff *ath6kl_buf_alloc(int size);
 #endif /* COMMON_H */
diff --git a/drivers/net/wireless/ath/ath6kl/core.c b/drivers/net/wireless/ath/ath6kl/core.c
new file mode 100644
index 0000000..7e3574e
--- /dev/null
+++ b/drivers/net/wireless/ath/ath6kl/core.c
@@ -0,0 +1,288 @@
+/*
+ * Copyright (c) 2004-2011 Atheros Communications Inc.
+ *
+ * Permission to use, copy, modify, and/or distribute this software for any
+ * purpose with or without fee is hereby granted, provided that the above
+ * copyright notice and this permission notice appear in all copies.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
+ * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
+ * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
+ * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
+ * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
+ * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
+ */
+
+#include "core.h"
+
+#include <linux/moduleparam.h>
+
+#include "debug.h"
+#include "hif-ops.h"
+#include "cfg80211.h"
+
+unsigned int debug_mask;
+static bool suspend_cutpower;
+static unsigned int uart_debug;
+static unsigned int ath6kl_p2p;
+
+module_param(debug_mask, uint, 0644);
+module_param(suspend_cutpower, bool, 0444);
+module_param(uart_debug, uint, 0644);
+module_param(ath6kl_p2p, uint, 0644);
+
+int ath6kl_core_init(struct ath6kl *ar)
+{
+	struct ath6kl_bmi_target_info targ_info;
+	struct net_device *ndev;
+	int ret = 0, i;
+
+	ar->ath6kl_wq = create_singlethread_workqueue("ath6kl");
+	if (!ar->ath6kl_wq)
+		return -ENOMEM;
+
+	ret = ath6kl_bmi_init(ar);
+	if (ret)
+		goto err_wq;
+
+	/*
+	 * Turn on power to get hardware (target) version and leave power
+	 * on delibrately as we will boot the hardware anyway within few
+	 * seconds.
+	 */
+	ret = ath6kl_hif_power_on(ar);
+	if (ret)
+		goto err_bmi_cleanup;
+
+	ret = ath6kl_bmi_get_target_info(ar, &targ_info);
+	if (ret)
+		goto err_power_off;
+
+	ar->version.target_ver = le32_to_cpu(targ_info.version);
+	ar->target_type = le32_to_cpu(targ_info.type);
+	ar->wiphy->hw_version = le32_to_cpu(targ_info.version);
+
+	ret = ath6kl_init_hw_params(ar);
+	if (ret)
+		goto err_power_off;
+
+	ar->htc_target = ath6kl_htc_create(ar);
+
+	if (!ar->htc_target) {
+		ret = -ENOMEM;
+		goto err_power_off;
+	}
+
+	ret = ath6kl_init_fetch_firmwares(ar);
+	if (ret)
+		goto err_htc_cleanup;
+
+	/* FIXME: we should free all firmwares in the error cases below */
+
+	/* Indicate that WMI is enabled (although not ready yet) */
+	set_bit(WMI_ENABLED, &ar->flag);
+	ar->wmi = ath6kl_wmi_init(ar);
+	if (!ar->wmi) {
+		ath6kl_err("failed to initialize wmi\n");
+		ret = -EIO;
+		goto err_htc_cleanup;
+	}
+
+	ath6kl_dbg(ATH6KL_DBG_TRC, "%s: got wmi @ 0x%p.\n", __func__, ar->wmi);
+
+	ret = ath6kl_cfg80211_init(ar);
+	if (ret)
+		goto err_node_cleanup;
+
+	ret = ath6kl_debug_init(ar);
+	if (ret) {
+		wiphy_unregister(ar->wiphy);
+		goto err_node_cleanup;
+	}
+
+	for (i = 0; i < ar->vif_max; i++)
+		ar->avail_idx_map |= BIT(i);
+
+	rtnl_lock();
+
+	/* Add an initial station interface */
+	ndev = ath6kl_interface_add(ar, "wlan%d", NL80211_IFTYPE_STATION, 0,
+				    INFRA_NETWORK);
+
+	rtnl_unlock();
+
+	if (!ndev) {
+		ath6kl_err("Failed to instantiate a network device\n");
+		ret = -ENOMEM;
+		wiphy_unregister(ar->wiphy);
+		goto err_debug_init;
+	}
+
+
+	ath6kl_dbg(ATH6KL_DBG_TRC, "%s: name=%s dev=0x%p, ar=0x%p\n",
+			__func__, ndev->name, ndev, ar);
+
+	/* setup access class priority mappings */
+	ar->ac_stream_pri_map[WMM_AC_BK] = 0; /* lowest  */
+	ar->ac_stream_pri_map[WMM_AC_BE] = 1;
+	ar->ac_stream_pri_map[WMM_AC_VI] = 2;
+	ar->ac_stream_pri_map[WMM_AC_VO] = 3; /* highest */
+
+	/* give our connected endpoints some buffers */
+	ath6kl_rx_refill(ar->htc_target, ar->ctrl_ep);
+	ath6kl_rx_refill(ar->htc_target, ar->ac2ep_map[WMM_AC_BE]);
+
+	/* allocate some buffers that handle larger AMSDU frames */
+	ath6kl_refill_amsdu_rxbufs(ar, ATH6KL_MAX_AMSDU_RX_BUFFERS);
+
+	ath6kl_cookie_init(ar);
+
+	ar->conf_flags = ATH6KL_CONF_IGNORE_ERP_BARKER |
+			 ATH6KL_CONF_ENABLE_11N | ATH6KL_CONF_ENABLE_TX_BURST;
+
+	if (suspend_cutpower)
+		ar->conf_flags |= ATH6KL_CONF_SUSPEND_CUTPOWER;
+
+	ar->wiphy->flags |= WIPHY_FLAG_SUPPORTS_FW_ROAM |
+			    WIPHY_FLAG_HAVE_AP_SME |
+			    WIPHY_FLAG_HAS_REMAIN_ON_CHANNEL |
+			    WIPHY_FLAG_AP_PROBE_RESP_OFFLOAD;
+
+	if (test_bit(ATH6KL_FW_CAPABILITY_SCHED_SCAN, ar->fw_capabilities))
+		ar->wiphy->flags |= WIPHY_FLAG_SUPPORTS_SCHED_SCAN;
+
+	ar->wiphy->probe_resp_offload =
+		NL80211_PROBE_RESP_OFFLOAD_SUPPORT_WPS |
+		NL80211_PROBE_RESP_OFFLOAD_SUPPORT_WPS2 |
+		NL80211_PROBE_RESP_OFFLOAD_SUPPORT_P2P |
+		NL80211_PROBE_RESP_OFFLOAD_SUPPORT_80211U;
+
+	set_bit(FIRST_BOOT, &ar->flag);
+
+	ret = ath6kl_init_hw_start(ar);
+	if (ret) {
+		ath6kl_err("Failed to start hardware: %d\n", ret);
+		goto err_rxbuf_cleanup;
+	}
+
+	/*
+	 * Set mac address which is received in ready event
+	 * FIXME: Move to ath6kl_interface_add()
+	 */
+	memcpy(ndev->dev_addr, ar->mac_addr, ETH_ALEN);
+
+	return ret;
+
+err_rxbuf_cleanup:
+	ath6kl_htc_flush_rx_buf(ar->htc_target);
+	ath6kl_cleanup_amsdu_rxbufs(ar);
+	rtnl_lock();
+	ath6kl_cfg80211_vif_cleanup(netdev_priv(ndev));
+	rtnl_unlock();
+	wiphy_unregister(ar->wiphy);
+err_debug_init:
+	ath6kl_debug_cleanup(ar);
+err_node_cleanup:
+	ath6kl_wmi_shutdown(ar->wmi);
+	clear_bit(WMI_ENABLED, &ar->flag);
+	ar->wmi = NULL;
+err_htc_cleanup:
+	ath6kl_htc_cleanup(ar->htc_target);
+err_power_off:
+	ath6kl_hif_power_off(ar);
+err_bmi_cleanup:
+	ath6kl_bmi_cleanup(ar);
+err_wq:
+	destroy_workqueue(ar->ath6kl_wq);
+
+	return ret;
+}
+
+struct ath6kl *ath6kl_core_create(struct device *dev)
+{
+	struct ath6kl *ar;
+	u8 ctr;
+
+	ar = ath6kl_cfg80211_create();
+
+	if (!ar)
+		return NULL;
+
+	ar->p2p = !!ath6kl_p2p;
+	ar->dev = dev;
+
+	ar->vif_max = 1;
+
+	ar->max_norm_iface = 1;
+
+	spin_lock_init(&ar->lock);
+	spin_lock_init(&ar->mcastpsq_lock);
+	spin_lock_init(&ar->list_lock);
+
+	init_waitqueue_head(&ar->event_wq);
+	sema_init(&ar->sem, 1);
+
+	INIT_LIST_HEAD(&ar->amsdu_rx_buffer_queue);
+	INIT_LIST_HEAD(&ar->vif_list);
+
+	clear_bit(WMI_ENABLED, &ar->flag);
+	clear_bit(SKIP_SCAN, &ar->flag);
+	clear_bit(DESTROY_IN_PROGRESS, &ar->flag);
+
+	ar->listen_intvl_t = A_DEFAULT_LISTEN_INTERVAL;
+	ar->listen_intvl_b = 0;
+	ar->tx_pwr = 0;
+
+	ar->intra_bss = 1;
+	ar->lrssi_roam_threshold = DEF_LRSSI_ROAM_THRESHOLD;
+
+	ar->state = ATH6KL_STATE_OFF;
+
+	memset((u8 *)ar->sta_list, 0,
+	       AP_MAX_NUM_STA * sizeof(struct ath6kl_sta));
+
+	/* Init the PS queues */
+	for (ctr = 0; ctr < AP_MAX_NUM_STA; ctr++) {
+		spin_lock_init(&ar->sta_list[ctr].psq_lock);
+		skb_queue_head_init(&ar->sta_list[ctr].psq);
+	}
+
+	skb_queue_head_init(&ar->mcastpsq);
+
+	memcpy(ar->ap_country_code, DEF_AP_COUNTRY_CODE, 3);
+
+	return ar;
+}
+
+void ath6kl_core_cleanup(struct ath6kl *ar)
+{
+	ath6kl_hif_power_off(ar);
+
+	destroy_workqueue(ar->ath6kl_wq);
+
+	if (ar->htc_target)
+		ath6kl_htc_cleanup(ar->htc_target);
+
+	ath6kl_cookie_cleanup(ar);
+
+	ath6kl_cleanup_amsdu_rxbufs(ar);
+
+	ath6kl_bmi_cleanup(ar);
+
+	ath6kl_debug_cleanup(ar);
+
+	kfree(ar->fw_board);
+	kfree(ar->fw_otp);
+	kfree(ar->fw);
+	kfree(ar->fw_patch);
+
+	ath6kl_cfg80211_cleanup(ar);
+	ath6kl_cfg80211_destroy(ar);
+}
+
+void ath6kl_core_destroy(struct ath6kl *ar)
+{
+	ath6kl_cfg80211_destroy(ar);
+}
+
diff --git a/drivers/net/wireless/ath/ath6kl/core.h b/drivers/net/wireless/ath/ath6kl/core.h
index 93d05c0..5415358 100644
--- a/drivers/net/wireless/ath/ath6kl/core.h
+++ b/drivers/net/wireless/ath/ath6kl/core.h
@@ -723,11 +723,18 @@ void ath6kl_wakeup_event(void *dev);
 void ath6kl_reset_device(struct ath6kl *ar, u32 target_type,
 			 bool wait_fot_compltn, bool cold_reset);
 void ath6kl_init_control_info(struct ath6kl_vif *vif);
-void ath6kl_core_free(struct ath6kl *ar);
 struct ath6kl_vif *ath6kl_vif_first(struct ath6kl *ar);
 void ath6kl_cleanup_vif(struct ath6kl_vif *vif, bool wmi_ready);
 int ath6kl_init_hw_start(struct ath6kl *ar);
 int ath6kl_init_hw_stop(struct ath6kl *ar);
+int ath6kl_init_fetch_firmwares(struct ath6kl *ar);
+int ath6kl_init_hw_params(struct ath6kl *ar);
+
 void ath6kl_check_wow_status(struct ath6kl *ar);
 
+struct ath6kl *ath6kl_core_create(struct device *dev);
+int ath6kl_core_init(struct ath6kl *ar);
+void ath6kl_core_cleanup(struct ath6kl *ar);
+void ath6kl_core_destroy(struct ath6kl *ar);
+
 #endif /* CORE_H */
diff --git a/drivers/net/wireless/ath/ath6kl/init.c b/drivers/net/wireless/ath/ath6kl/init.c
index 32bd111..5a92307 100644
--- a/drivers/net/wireless/ath/ath6kl/init.c
+++ b/drivers/net/wireless/ath/ath6kl/init.c
@@ -25,13 +25,9 @@
 #include "debug.h"
 #include "hif-ops.h"
 
-unsigned int debug_mask;
 static unsigned int testmode;
-static bool suspend_cutpower;
 
-module_param(debug_mask, uint, 0644);
 module_param(testmode, uint, 0644);
-module_param(suspend_cutpower, bool, 0444);
 
 static const struct ath6kl_hw hw_list[] = {
 	{
@@ -573,36 +569,6 @@ int ath6kl_configure_target(struct ath6kl *ar)
 	return 0;
 }
 
-void ath6kl_core_free(struct ath6kl *ar)
-{
-	wiphy_free(ar->wiphy);
-}
-
-void ath6kl_core_cleanup(struct ath6kl *ar)
-{
-	ath6kl_hif_power_off(ar);
-
-	destroy_workqueue(ar->ath6kl_wq);
-
-	if (ar->htc_target)
-		ath6kl_htc_cleanup(ar->htc_target);
-
-	ath6kl_cookie_cleanup(ar);
-
-	ath6kl_cleanup_amsdu_rxbufs(ar);
-
-	ath6kl_bmi_cleanup(ar);
-
-	ath6kl_debug_cleanup(ar);
-
-	kfree(ar->fw_board);
-	kfree(ar->fw_otp);
-	kfree(ar->fw);
-	kfree(ar->fw_patch);
-
-	ath6kl_cfg80211_cleanup(ar);
-}
-
 /* firmware upload */
 static int ath6kl_get_fw(struct ath6kl *ar, const char *filename,
 			 u8 **fw, size_t *fw_len)
@@ -1010,7 +976,7 @@ out:
 	return ret;
 }
 
-static int ath6kl_fetch_firmwares(struct ath6kl *ar)
+int ath6kl_init_fetch_firmwares(struct ath6kl *ar)
 {
 	int ret;
 
@@ -1372,7 +1338,7 @@ static int ath6kl_init_upload(struct ath6kl *ar)
 	return status;
 }
 
-static int ath6kl_init_hw_params(struct ath6kl *ar)
+int ath6kl_init_hw_params(struct ath6kl *ar)
 {
 	const struct ath6kl_hw *hw;
 	int i;
@@ -1549,173 +1515,6 @@ int ath6kl_init_hw_stop(struct ath6kl *ar)
 	return 0;
 }
 
-int ath6kl_core_init(struct ath6kl *ar)
-{
-	struct ath6kl_bmi_target_info targ_info;
-	struct net_device *ndev;
-	int ret = 0, i;
-
-	ar->ath6kl_wq = create_singlethread_workqueue("ath6kl");
-	if (!ar->ath6kl_wq)
-		return -ENOMEM;
-
-	ret = ath6kl_bmi_init(ar);
-	if (ret)
-		goto err_wq;
-
-	/*
-	 * Turn on power to get hardware (target) version and leave power
-	 * on delibrately as we will boot the hardware anyway within few
-	 * seconds.
-	 */
-	ret = ath6kl_hif_power_on(ar);
-	if (ret)
-		goto err_bmi_cleanup;
-
-	ret = ath6kl_bmi_get_target_info(ar, &targ_info);
-	if (ret)
-		goto err_power_off;
-
-	ar->version.target_ver = le32_to_cpu(targ_info.version);
-	ar->target_type = le32_to_cpu(targ_info.type);
-	ar->wiphy->hw_version = le32_to_cpu(targ_info.version);
-
-	ret = ath6kl_init_hw_params(ar);
-	if (ret)
-		goto err_power_off;
-
-	ar->htc_target = ath6kl_htc_create(ar);
-
-	if (!ar->htc_target) {
-		ret = -ENOMEM;
-		goto err_power_off;
-	}
-
-	ret = ath6kl_fetch_firmwares(ar);
-	if (ret)
-		goto err_htc_cleanup;
-
-	/* FIXME: we should free all firmwares in the error cases below */
-
-	/* Indicate that WMI is enabled (although not ready yet) */
-	set_bit(WMI_ENABLED, &ar->flag);
-	ar->wmi = ath6kl_wmi_init(ar);
-	if (!ar->wmi) {
-		ath6kl_err("failed to initialize wmi\n");
-		ret = -EIO;
-		goto err_htc_cleanup;
-	}
-
-	ath6kl_dbg(ATH6KL_DBG_TRC, "%s: got wmi @ 0x%p.\n", __func__, ar->wmi);
-
-	ret = ath6kl_cfg80211_init(ar);
-	if (ret)
-		goto err_node_cleanup;
-
-	ret = ath6kl_debug_init(ar);
-	if (ret) {
-		wiphy_unregister(ar->wiphy);
-		goto err_node_cleanup;
-	}
-
-	for (i = 0; i < ar->vif_max; i++)
-		ar->avail_idx_map |= BIT(i);
-
-	rtnl_lock();
-
-	/* Add an initial station interface */
-	ndev = ath6kl_interface_add(ar, "wlan%d", NL80211_IFTYPE_STATION, 0,
-				    INFRA_NETWORK);
-
-	rtnl_unlock();
-
-	if (!ndev) {
-		ath6kl_err("Failed to instantiate a network device\n");
-		ret = -ENOMEM;
-		wiphy_unregister(ar->wiphy);
-		goto err_debug_init;
-	}
-
-
-	ath6kl_dbg(ATH6KL_DBG_TRC, "%s: name=%s dev=0x%p, ar=0x%p\n",
-			__func__, ndev->name, ndev, ar);
-
-	/* setup access class priority mappings */
-	ar->ac_stream_pri_map[WMM_AC_BK] = 0; /* lowest  */
-	ar->ac_stream_pri_map[WMM_AC_BE] = 1;
-	ar->ac_stream_pri_map[WMM_AC_VI] = 2;
-	ar->ac_stream_pri_map[WMM_AC_VO] = 3; /* highest */
-
-	/* give our connected endpoints some buffers */
-	ath6kl_rx_refill(ar->htc_target, ar->ctrl_ep);
-	ath6kl_rx_refill(ar->htc_target, ar->ac2ep_map[WMM_AC_BE]);
-
-	/* allocate some buffers that handle larger AMSDU frames */
-	ath6kl_refill_amsdu_rxbufs(ar, ATH6KL_MAX_AMSDU_RX_BUFFERS);
-
-	ath6kl_cookie_init(ar);
-
-	ar->conf_flags = ATH6KL_CONF_IGNORE_ERP_BARKER |
-			 ATH6KL_CONF_ENABLE_11N | ATH6KL_CONF_ENABLE_TX_BURST;
-
-	if (suspend_cutpower)
-		ar->conf_flags |= ATH6KL_CONF_SUSPEND_CUTPOWER;
-
-	ar->wiphy->flags |= WIPHY_FLAG_SUPPORTS_FW_ROAM |
-			    WIPHY_FLAG_HAVE_AP_SME |
-			    WIPHY_FLAG_HAS_REMAIN_ON_CHANNEL |
-			    WIPHY_FLAG_AP_PROBE_RESP_OFFLOAD;
-
-	if (test_bit(ATH6KL_FW_CAPABILITY_SCHED_SCAN, ar->fw_capabilities))
-		ar->wiphy->flags |= WIPHY_FLAG_SUPPORTS_SCHED_SCAN;
-
-	ar->wiphy->probe_resp_offload =
-		NL80211_PROBE_RESP_OFFLOAD_SUPPORT_WPS |
-		NL80211_PROBE_RESP_OFFLOAD_SUPPORT_WPS2 |
-		NL80211_PROBE_RESP_OFFLOAD_SUPPORT_P2P |
-		NL80211_PROBE_RESP_OFFLOAD_SUPPORT_80211U;
-
-	set_bit(FIRST_BOOT, &ar->flag);
-
-	ret = ath6kl_init_hw_start(ar);
-	if (ret) {
-		ath6kl_err("Failed to start hardware: %d\n", ret);
-		goto err_rxbuf_cleanup;
-	}
-
-	/*
-	 * Set mac address which is received in ready event
-	 * FIXME: Move to ath6kl_interface_add()
-	 */
-	memcpy(ndev->dev_addr, ar->mac_addr, ETH_ALEN);
-
-	return ret;
-
-err_rxbuf_cleanup:
-	ath6kl_htc_flush_rx_buf(ar->htc_target);
-	ath6kl_cleanup_amsdu_rxbufs(ar);
-	rtnl_lock();
-	ath6kl_cfg80211_vif_cleanup(netdev_priv(ndev));
-	rtnl_unlock();
-	wiphy_unregister(ar->wiphy);
-err_debug_init:
-	ath6kl_debug_cleanup(ar);
-err_node_cleanup:
-	ath6kl_wmi_shutdown(ar->wmi);
-	clear_bit(WMI_ENABLED, &ar->flag);
-	ar->wmi = NULL;
-err_htc_cleanup:
-	ath6kl_htc_cleanup(ar->htc_target);
-err_power_off:
-	ath6kl_hif_power_off(ar);
-err_bmi_cleanup:
-	ath6kl_bmi_cleanup(ar);
-err_wq:
-	destroy_workqueue(ar->ath6kl_wq);
-
-	return ret;
-}
-
 /* FIXME: move this to cfg80211.c and rename to ath6kl_cfg80211_vif_stop() */
 void ath6kl_cleanup_vif(struct ath6kl_vif *vif, bool wmi_ready)
 {
diff --git a/drivers/net/wireless/ath/ath6kl/sdio.c b/drivers/net/wireless/ath/ath6kl/sdio.c
index 15c3f56..08d2db4 100644
--- a/drivers/net/wireless/ath/ath6kl/sdio.c
+++ b/drivers/net/wireless/ath/ath6kl/sdio.c
@@ -1263,7 +1263,7 @@ static int ath6kl_sdio_probe(struct sdio_func *func,
 	for (count = 0; count < BUS_REQUEST_MAX_NUM; count++)
 		ath6kl_sdio_free_bus_req(ar_sdio, &ar_sdio->bus_req[count]);
 
-	ar = ath6kl_core_alloc(&ar_sdio->func->dev);
+	ar = ath6kl_core_create(&ar_sdio->func->dev);
 	if (!ar) {
 		ath6kl_err("Failed to alloc ath6kl core\n");
 		ret = -ENOMEM;
@@ -1293,7 +1293,7 @@ static int ath6kl_sdio_probe(struct sdio_func *func,
 	return ret;
 
 err_core_alloc:
-	ath6kl_core_free(ar_sdio->ar);
+	ath6kl_core_destroy(ar_sdio->ar);
 err_dma:
 	kfree(ar_sdio->dma_buffer);
 err_hif:
diff --git a/drivers/net/wireless/ath/ath6kl/usb.c b/drivers/net/wireless/ath/ath6kl/usb.c
index e3cf397..38ac253 100644
--- a/drivers/net/wireless/ath/ath6kl/usb.c
+++ b/drivers/net/wireless/ath/ath6kl/usb.c
@@ -352,7 +352,7 @@ static int ath6kl_usb_probe(struct usb_interface *interface,
 		goto err_usb_put;
 	}
 
-	ar = ath6kl_core_alloc(&ar_usb->udev->dev);
+	ar = ath6kl_core_create(&ar_usb->udev->dev);
 	if (ar == NULL) {
 		ath6kl_err("Failed to alloc ath6kl core\n");
 		ret = -ENOMEM;
@@ -370,13 +370,13 @@ static int ath6kl_usb_probe(struct usb_interface *interface,
 	ret = ath6kl_core_init(ar);
 	if (ret) {
 		ath6kl_err("Failed to init ath6kl core: %d\n", ret);
-		goto err_core_free;
+		goto err_core_destroy;
 	}
 
 	return ret;
 
-err_core_free:
-	ath6kl_core_free(ar);
+err_core_destroy:
+	ath6kl_core_destroy(ar);
 err_usb_destroy:
 	ath6kl_usb_destroy(ar_usb);
 err_usb_put:

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
