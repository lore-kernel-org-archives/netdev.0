From: Chaehyun Lim <chaehyun.lim@gmail.com>
Subject: [PATCH 2/2] ath6kl: replace semaphore with mutex
Date: Tue, 21 Jun 2016 20:45:39 +0900
Message-ID: <20160621114539.15313-2-chaehyun.lim@gmail.com>
References: <20160621114539.15313-1-chaehyun.lim@gmail.com>
Cc: ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Chaehyun Lim <chaehyun.lim@gmail.com>
To: kvalo@qca.qualcomm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33355 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751728AbcFULpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 07:45:51 -0400
In-Reply-To: <20160621114539.15313-1-chaehyun.lim@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It replaces struct semaphore sem with struct mutex mutex

Signed-off-by: Chaehyun Lim <chaehyun.lim@gmail.com>
---
 drivers/net/wireless/ath/ath6kl/cfg80211.c | 30 +++++++++++++++---------------
 drivers/net/wireless/ath/ath6kl/core.c     |  2 +-
 drivers/net/wireless/ath/ath6kl/core.h     |  2 +-
 drivers/net/wireless/ath/ath6kl/debug.c    | 12 ++++++------
 drivers/net/wireless/ath/ath6kl/init.c     |  6 +++---
 5 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/cfg80211.c b/drivers/net/wireless/ath/ath6kl/cfg80211.c
index f6b5390..d4eb066 100644
--- a/drivers/net/wireless/ath/ath6kl/cfg80211.c
+++ b/drivers/net/wireless/ath/ath6kl/cfg80211.c
@@ -480,14 +480,14 @@ static int ath6kl_cfg80211_connect(struct wiphy *wiphy, struct net_device *dev,
 		return -EINVAL;
 	}
 
-	if (down_interruptible(&ar->sem)) {
+	if (mutex_lock_interruptible(&ar->mutex)) {
 		ath6kl_err("busy, couldn't get access\n");
 		return -ERESTARTSYS;
 	}
 
 	if (test_bit(DESTROY_IN_PROGRESS, &ar->flag)) {
 		ath6kl_err("busy, destroy in progress\n");
-		up(&ar->sem);
+		mutex_unlock(&ar->mutex);
 		return -EBUSY;
 	}
 
@@ -500,14 +500,14 @@ static int ath6kl_cfg80211_connect(struct wiphy *wiphy, struct net_device *dev,
 						 WMI_TIMEOUT);
 		if (signal_pending(current)) {
 			ath6kl_err("cmd queue drain timeout\n");
-			up(&ar->sem);
+			mutex_unlock(&ar->mutex);
 			return -EINTR;
 		}
 	}
 
 	status = ath6kl_set_assoc_req_ies(vif, sme->ie, sme->ie_len);
 	if (status) {
-		up(&ar->sem);
+		mutex_unlock(&ar->mutex);
 		return status;
 	}
 
@@ -522,7 +522,7 @@ static int ath6kl_cfg80211_connect(struct wiphy *wiphy, struct net_device *dev,
 						  vif->req_bssid,
 						  vif->ch_hint);
 
-		up(&ar->sem);
+		mutex_unlock(&ar->mutex);
 		if (status) {
 			ath6kl_err("wmi_reconnect_cmd failed\n");
 			return -EIO;
@@ -548,7 +548,7 @@ static int ath6kl_cfg80211_connect(struct wiphy *wiphy, struct net_device *dev,
 
 	status = ath6kl_set_auth_type(vif, sme->auth_type);
 	if (status) {
-		up(&ar->sem);
+		mutex_unlock(&ar->mutex);
 		return status;
 	}
 
@@ -570,7 +570,7 @@ static int ath6kl_cfg80211_connect(struct wiphy *wiphy, struct net_device *dev,
 		if (sme->key_idx > WMI_MAX_KEY_INDEX) {
 			ath6kl_err("key index %d out of bounds\n",
 				   sme->key_idx);
-			up(&ar->sem);
+			mutex_unlock(&ar->mutex);
 			return -ENOENT;
 		}
 
@@ -594,7 +594,7 @@ static int ath6kl_cfg80211_connect(struct wiphy *wiphy, struct net_device *dev,
 		if (ath6kl_wmi_bssfilter_cmd(ar->wmi, vif->fw_vif_idx,
 					     ALL_BSS_FILTER, 0) != 0) {
 			ath6kl_err("couldn't set bss filtering\n");
-			up(&ar->sem);
+			mutex_unlock(&ar->mutex);
 			return -EIO;
 		}
 	}
@@ -626,7 +626,7 @@ static int ath6kl_cfg80211_connect(struct wiphy *wiphy, struct net_device *dev,
 						       0);
 		if (status) {
 			ath6kl_err("couldn't set listen intervel\n");
-			up(&ar->sem);
+			mutex_unlock(&ar->mutex);
 			return status;
 		}
 	}
@@ -651,7 +651,7 @@ static int ath6kl_cfg80211_connect(struct wiphy *wiphy, struct net_device *dev,
 	ath6kl_wmi_scanparams_cmd(ar->wmi, vif->fw_vif_idx, 0, 0,
 				  sme->bg_scan_period, 0, 0, 0, 3, 0, 0, 0);
 
-	up(&ar->sem);
+	mutex_unlock(&ar->mutex);
 
 	if (status == -EINVAL) {
 		memset(vif->ssid, 0, sizeof(vif->ssid));
@@ -832,7 +832,7 @@ static int ath6kl_cfg80211_disconnect(struct wiphy *wiphy,
 		return -EBUSY;
 	}
 
-	if (down_interruptible(&ar->sem)) {
+	if (mutex_lock_interruptible(&ar->mutex)) {
 		ath6kl_err("busy, couldn't get access\n");
 		return -ERESTARTSYS;
 	}
@@ -845,7 +845,7 @@ static int ath6kl_cfg80211_disconnect(struct wiphy *wiphy,
 	if (!test_bit(SKIP_SCAN, &ar->flag))
 		memset(vif->req_bssid, 0, sizeof(vif->req_bssid));
 
-	up(&ar->sem);
+	mutex_unlock(&ar->mutex);
 
 	vif->sme_state = SME_DISCONNECTED;
 
@@ -1775,7 +1775,7 @@ static int ath6kl_get_station(struct wiphy *wiphy, struct net_device *dev,
 	if (memcmp(mac, vif->bssid, ETH_ALEN) != 0)
 		return -ENOENT;
 
-	if (down_interruptible(&ar->sem))
+	if (mutex_lock_interruptible(&ar->mutex))
 		return -EBUSY;
 
 	set_bit(STATS_UPDATE_PEND, &vif->flags);
@@ -1783,7 +1783,7 @@ static int ath6kl_get_station(struct wiphy *wiphy, struct net_device *dev,
 	ret = ath6kl_wmi_get_stats_cmd(ar->wmi, vif->fw_vif_idx);
 
 	if (ret != 0) {
-		up(&ar->sem);
+		mutex_unlock(&ar->mutex);
 		return -EIO;
 	}
 
@@ -1792,7 +1792,7 @@ static int ath6kl_get_station(struct wiphy *wiphy, struct net_device *dev,
 							  &vif->flags),
 						WMI_TIMEOUT);
 
-	up(&ar->sem);
+	mutex_unlock(&ar->mutex);
 
 	if (left == 0)
 		return -ETIMEDOUT;
diff --git a/drivers/net/wireless/ath/ath6kl/core.c b/drivers/net/wireless/ath/ath6kl/core.c
index ebb9f16..0da253a 100644
--- a/drivers/net/wireless/ath/ath6kl/core.c
+++ b/drivers/net/wireless/ath/ath6kl/core.c
@@ -283,7 +283,7 @@ struct ath6kl *ath6kl_core_create(struct device *dev)
 	spin_lock_init(&ar->list_lock);
 
 	init_waitqueue_head(&ar->event_wq);
-	sema_init(&ar->sem, 1);
+	mutex_init(&ar->mutex);
 
 	INIT_LIST_HEAD(&ar->amsdu_rx_buffer_queue);
 	INIT_LIST_HEAD(&ar->vif_list);
diff --git a/drivers/net/wireless/ath/ath6kl/core.h b/drivers/net/wireless/ath/ath6kl/core.h
index ac25f17..42848bd 100644
--- a/drivers/net/wireless/ath/ath6kl/core.h
+++ b/drivers/net/wireless/ath/ath6kl/core.h
@@ -722,7 +722,7 @@ struct ath6kl {
 	 */
 	spinlock_t lock;
 
-	struct semaphore sem;
+	struct mutex mutex;
 	u8 lrssi_roam_threshold;
 	struct ath6kl_version version;
 	u32 target_type;
diff --git a/drivers/net/wireless/ath/ath6kl/debug.c b/drivers/net/wireless/ath/ath6kl/debug.c
index e2b7809..9c1e709 100644
--- a/drivers/net/wireless/ath/ath6kl/debug.c
+++ b/drivers/net/wireless/ath/ath6kl/debug.c
@@ -102,13 +102,13 @@ int ath6kl_read_tgt_stats(struct ath6kl *ar, struct ath6kl_vif *vif)
 {
 	long left;
 
-	if (down_interruptible(&ar->sem))
+	if (mutex_lock_interruptible(&ar->mutex))
 		return -EBUSY;
 
 	set_bit(STATS_UPDATE_PEND, &vif->flags);
 
 	if (ath6kl_wmi_get_stats_cmd(ar->wmi, 0)) {
-		up(&ar->sem);
+		mutex_unlock(&ar->mutex);
 		return -EIO;
 	}
 
@@ -116,7 +116,7 @@ int ath6kl_read_tgt_stats(struct ath6kl *ar, struct ath6kl_vif *vif)
 						!test_bit(STATS_UPDATE_PEND,
 						&vif->flags), WMI_TIMEOUT);
 
-	up(&ar->sem);
+	mutex_unlock(&ar->mutex);
 
 	if (left <= 0)
 		return -ETIMEDOUT;
@@ -1167,20 +1167,20 @@ static ssize_t ath6kl_roam_table_read(struct file *file, char __user *user_buf,
 	unsigned int len, buf_len;
 	ssize_t ret_cnt;
 
-	if (down_interruptible(&ar->sem))
+	if (mutex_lock_interruptible(&ar->mutex))
 		return -EBUSY;
 
 	set_bit(ROAM_TBL_PEND, &ar->flag);
 
 	ret = ath6kl_wmi_get_roam_tbl_cmd(ar->wmi);
 	if (ret) {
-		up(&ar->sem);
+		mutex_unlock(&ar->sem);
 		return ret;
 	}
 
 	left = wait_event_interruptible_timeout(
 		ar->event_wq, !test_bit(ROAM_TBL_PEND, &ar->flag), WMI_TIMEOUT);
-	up(&ar->sem);
+	mutex_unlock(&ar->mutex);
 
 	if (left <= 0)
 		return -ETIMEDOUT;
diff --git a/drivers/net/wireless/ath/ath6kl/init.c b/drivers/net/wireless/ath/ath6kl/init.c
index 58fb227..377f1fa 100644
--- a/drivers/net/wireless/ath/ath6kl/init.c
+++ b/drivers/net/wireless/ath/ath6kl/init.c
@@ -1890,8 +1890,8 @@ void ath6kl_stop_txrx(struct ath6kl *ar)
 
 	set_bit(DESTROY_IN_PROGRESS, &ar->flag);
 
-	if (down_interruptible(&ar->sem)) {
-		ath6kl_err("down_interruptible failed\n");
+	if (mutex_lock_interruptible(&ar->mutex)) {
+		ath6kl_err("mutex_lock_interruptible failed\n");
 		return;
 	}
 
@@ -1938,6 +1938,6 @@ void ath6kl_stop_txrx(struct ath6kl *ar)
 	 */
 	ath6kl_init_hw_reset(ar);
 
-	up(&ar->sem);
+	mutex_unlock(&ar->mutex);
 }
 EXPORT_SYMBOL(ath6kl_stop_txrx);
-- 
2.9.0
