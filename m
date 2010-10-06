From: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH wireless-2.6 or stable] iwlwifi: return error when fail to
 start scanning
Date: Wed, 6 Oct 2010 18:04:35 +0200
Message-ID: <20101006160434.GB24581@redhat.com>
References: <20101005085717.GA18012@redhat.com>
 <1286317292-10679-1-git-send-email-florian@mickler.org>
 <20101006090228.GA2523@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ben.m.cahill-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Florian Mickler <florian-sVu6HhrpSfRAfugRpC6u6w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20101006090228.GA2523-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is stable friendly backport of wireless-testing commit
3eecce527c7434dfd16517ce08b49632c8a26717 "iwlwifi: unify scan start
checks". Wireless-testing version include also a lot of cleanups.

On error case in {iwl3945,iwlagn}_request_scan we queue abort_scan work,
which in a fact do nothing, so we never complete the scan. Thats gives
"WARNING: at net/wireless/core.c:614 wdev_cleanup_work" and stopped
network connection until reload iwlwifi modules. Return of -EIO, and
stopping queuing any work is a fix.

Note there are still many cases when we can get: 

WARNING: at net/wireless/core.c:614 wdev_cleanup_work  
WARNING: at net/mac80211/scan.c:266 ieee80211_scan_completed
WARNING: at net/mac80211/scan.c:269 ieee80211_scan_complete

which are not fixed. Unfortunately does not exist single, small fix
for that problems, and we probably will see some more bug reports
with scan warnings. As solution we rewrite iwl-scan.c code to avoid
all possible race conditions. That quite big patch set is queued
for 2.6.37 .

Signed-off-by: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
Patch is intended for wireless-2.6, or in case when it does not
make 2.6.36 release, for -stable 2.6.36.y 

 drivers/net/wireless/iwlwifi/iwl-3945.h     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c  |   18 ++++++------------
 drivers/net/wireless/iwlwifi/iwl-agn.h      |    2 +-
 drivers/net/wireless/iwlwifi/iwl-core.h     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c     |   14 +++++++++++---
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   19 ++++++-------------
 6 files changed, 26 insertions(+), 31 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.h b/drivers/net/wireless/iwlwifi/iwl-3945.h
index bb2aeeb..98509c5 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.h
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.h
@@ -295,7 +295,7 @@ extern const struct iwl_channel_info *iwl3945_get_channel_info(
 extern int iwl3945_rs_next_rate(struct iwl_priv *priv, int rate);
 
 /* scanning */
-void iwl3945_request_scan(struct iwl_priv *priv, struct ieee80211_vif *vif);
+int iwl3945_request_scan(struct iwl_priv *priv, struct ieee80211_vif *vif);
 
 /* Requires full declaration of iwl_priv before including */
 #include "iwl-io.h"
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-lib.c b/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
index 8fd00a6..2be8faa 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
@@ -1147,7 +1147,7 @@ static int iwl_get_channels_for_scan(struct iwl_priv *priv,
 	return added;
 }
 
-void iwlagn_request_scan(struct iwl_priv *priv, struct ieee80211_vif *vif)
+int iwlagn_request_scan(struct iwl_priv *priv, struct ieee80211_vif *vif)
 {
 	struct iwl_host_cmd cmd = {
 		.id = REPLY_SCAN_CMD,
@@ -1394,24 +1394,18 @@ void iwlagn_request_scan(struct iwl_priv *priv, struct ieee80211_vif *vif)
 	scan->len = cpu_to_le16(cmd.len);
 
 	set_bit(STATUS_SCAN_HW, &priv->status);
-	if (iwl_send_cmd_sync(priv, &cmd))
+	if (iwl_send_cmd_sync(priv, &cmd)) {
+		clear_bit(STATUS_SCAN_HW, &priv->status);
 		goto done;
+	}
 
 	queue_delayed_work(priv->workqueue, &priv->scan_check,
 			   IWL_SCAN_CHECK_WATCHDOG);
 
-	return;
+	return 0;
 
  done:
-	/* Cannot perform scan. Make sure we clear scanning
-	* bits from status so next scan request can be performed.
-	* If we don't clear scanning status bit here all next scan
-	* will fail
-	*/
-	clear_bit(STATUS_SCAN_HW, &priv->status);
-	clear_bit(STATUS_SCANNING, &priv->status);
-	/* inform mac80211 scan aborted */
-	queue_work(priv->workqueue, &priv->abort_scan);
+	return -EIO;
 }
 
 int iwlagn_manage_ibss_station(struct iwl_priv *priv,
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.h b/drivers/net/wireless/iwlwifi/iwl-agn.h
index cc6464d..015da26 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.h
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.h
@@ -216,7 +216,7 @@ void iwl_reply_statistics(struct iwl_priv *priv,
 			  struct iwl_rx_mem_buffer *rxb);
 
 /* scan */
-void iwlagn_request_scan(struct iwl_priv *priv, struct ieee80211_vif *vif);
+int iwlagn_request_scan(struct iwl_priv *priv, struct ieee80211_vif *vif);
 
 /* station mgmt */
 int iwlagn_manage_ibss_station(struct iwl_priv *priv,
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.h b/drivers/net/wireless/iwlwifi/iwl-core.h
index 5e6ee3d..110de0f 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.h
+++ b/drivers/net/wireless/iwlwifi/iwl-core.h
@@ -109,7 +109,7 @@ struct iwl_hcmd_utils_ops {
 				  __le16 fc, __le32 *tx_flags);
 	int  (*calc_rssi)(struct iwl_priv *priv,
 			  struct iwl_rx_phy_res *rx_resp);
-	void (*request_scan)(struct iwl_priv *priv, struct ieee80211_vif *vif);
+	int (*request_scan)(struct iwl_priv *priv, struct ieee80211_vif *vif);
 };
 
 struct iwl_apm_ops {
diff --git a/drivers/net/wireless/iwlwifi/iwl-scan.c b/drivers/net/wireless/iwlwifi/iwl-scan.c
index a4b3663..290140a 100644
--- a/drivers/net/wireless/iwlwifi/iwl-scan.c
+++ b/drivers/net/wireless/iwlwifi/iwl-scan.c
@@ -298,6 +298,7 @@ EXPORT_SYMBOL(iwl_init_scan_params);
 
 static int iwl_scan_initiate(struct iwl_priv *priv, struct ieee80211_vif *vif)
 {
+	int ret;
 	lockdep_assert_held(&priv->mutex);
 
 	IWL_DEBUG_INFO(priv, "Starting scan...\n");
@@ -308,9 +309,11 @@ static int iwl_scan_initiate(struct iwl_priv *priv, struct ieee80211_vif *vif)
 	if (WARN_ON(!priv->cfg->ops->utils->request_scan))
 		return -EOPNOTSUPP;
 
-	priv->cfg->ops->utils->request_scan(priv, vif);
+	ret = priv->cfg->ops->utils->request_scan(priv, vif);
+	if (ret)
+		clear_bit(STATUS_SCANNING, &priv->status);
+	return ret;
 
-	return 0;
 }
 
 int iwl_mac_hw_scan(struct ieee80211_hw *hw,
@@ -380,6 +383,7 @@ void iwl_internal_short_hw_scan(struct iwl_priv *priv)
 
 void iwl_bg_start_internal_scan(struct work_struct *work)
 {
+	int ret;
 	struct iwl_priv *priv =
 		container_of(work, struct iwl_priv, start_internal_scan);
 
@@ -414,7 +418,11 @@ void iwl_bg_start_internal_scan(struct work_struct *work)
 	if (WARN_ON(!priv->cfg->ops->utils->request_scan))
 		goto unlock;
 
-	priv->cfg->ops->utils->request_scan(priv, NULL);
+	ret = priv->cfg->ops->utils->request_scan(priv, NULL);
+	if (ret) {
+		clear_bit(STATUS_SCANNING, &priv->status);
+		priv->is_internal_short_scan = false;
+	}
  unlock:
 	mutex_unlock(&priv->mutex);
 }
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index d31661c..fc82da0 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -2799,7 +2799,7 @@ static void iwl3945_rfkill_poll(struct work_struct *data)
 
 }
 
-void iwl3945_request_scan(struct iwl_priv *priv, struct ieee80211_vif *vif)
+int iwl3945_request_scan(struct iwl_priv *priv, struct ieee80211_vif *vif)
 {
 	struct iwl_host_cmd cmd = {
 		.id = REPLY_SCAN_CMD,
@@ -3000,25 +3000,18 @@ void iwl3945_request_scan(struct iwl_priv *priv, struct ieee80211_vif *vif)
 	scan->len = cpu_to_le16(cmd.len);
 
 	set_bit(STATUS_SCAN_HW, &priv->status);
-	if (iwl_send_cmd_sync(priv, &cmd))
+	if (iwl_send_cmd_sync(priv, &cmd)) {
+		clear_bit(STATUS_SCAN_HW, &priv->status);
 		goto done;
+	}
 
 	queue_delayed_work(priv->workqueue, &priv->scan_check,
 			   IWL_SCAN_CHECK_WATCHDOG);
 
-	return;
+	return 0;
 
  done:
-	/* can not perform scan make sure we clear scanning
-	 * bits from status so next scan request can be performed.
-	 * if we dont clear scanning status bit here all next scan
-	 * will fail
-	*/
-	clear_bit(STATUS_SCAN_HW, &priv->status);
-	clear_bit(STATUS_SCANNING, &priv->status);
