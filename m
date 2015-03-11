From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] ath10k: match wait_for_completion_timeout return type
Date: Wed, 11 Mar 2015 13:14:36 -0400
Message-ID: <1426094076-10134-1-git-send-email-hofrat@osadl.org>
Cc: ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicholas Mc Guire <hofrat@osadl.org>
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Return type of wait_for_completion_timeout is unsigned long not int.
An appropriately named unsigned long is added and the assignments fixed up.

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

While at it the missing spaces 3*HZ -> 3 * HZ were added as well (should
this be in a separate patch ?)

Patch was only compile tested with x86_64_defconfig + CONFIG_ATH_CARDS=m,
CONFIG_ATH10K=m

Patch is against 4.0-rc3 (localversion-next is -next-20150311)

 drivers/net/wireless/ath/ath10k/mac.c |   35 +++++++++++++++++++--------------
 1 file changed, 20 insertions(+), 15 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/mac.c b/drivers/net/wireless/ath/ath10k/mac.c
index e8cc19f..7db8b81 100644
--- a/drivers/net/wireless/ath/ath10k/mac.c
+++ b/drivers/net/wireless/ath/ath10k/mac.c
@@ -98,6 +98,7 @@ static int ath10k_install_key(struct ath10k_vif *arvif,
 			      const u8 *macaddr, bool def_idx)
 {
 	struct ath10k *ar = arvif->ar;
+	unsigned long time_left;
 	int ret;
 
 	lockdep_assert_held(&ar->conf_mutex);
@@ -108,8 +109,8 @@ static int ath10k_install_key(struct ath10k_vif *arvif,
 	if (ret)
 		return ret;
 
-	ret = wait_for_completion_timeout(&ar->install_key_done, 3*HZ);
-	if (ret == 0)
+	time_left = wait_for_completion_timeout(&ar->install_key_done, 3 * HZ);
+	if (!time_left)
 		return -ETIMEDOUT;
 
 	return 0;
@@ -561,16 +562,16 @@ static void ath10k_mac_vif_beacon_cleanup(struct ath10k_vif *arvif)
 
 static inline int ath10k_vdev_setup_sync(struct ath10k *ar)
 {
-	int ret;
+	unsigned long time_left;
 
 	lockdep_assert_held(&ar->conf_mutex);
 
 	if (test_bit(ATH10K_FLAG_CRASH_FLUSH, &ar->dev_flags))
 		return -ESHUTDOWN;
 
-	ret = wait_for_completion_timeout(&ar->vdev_setup_done,
+	time_left = wait_for_completion_timeout(&ar->vdev_setup_done,
 						ATH10K_VDEV_SETUP_TIMEOUT_HZ);
-	if (ret == 0)
+	if (!time_left)
 		return -ETIMEDOUT;
 
 	return 0;
@@ -2432,6 +2433,7 @@ void ath10k_offchan_tx_work(struct work_struct *work)
 	const u8 *peer_addr;
 	int vdev_id;
 	int ret;
+	unsigned long time_left;
 
 	/* FW requirement: We must create a peer before FW will send out
 	 * an offchannel frame. Otherwise the frame will be stuck and
@@ -2477,9 +2479,9 @@ void ath10k_offchan_tx_work(struct work_struct *work)
 
 		ath10k_tx_htt(ar, skb);
 
-		ret = wait_for_completion_timeout(&ar->offchan_tx_completed,
-						  3 * HZ);
-		if (ret == 0)
+		time_left = wait_for_completion_timeout(
+					&ar->offchan_tx_completed, 3 * HZ);
+		if (!time_left)
 			ath10k_warn(ar, "timed out waiting for offchannel skb %p\n",
 				    skb);
 
@@ -2573,6 +2575,7 @@ static int ath10k_scan_stop(struct ath10k *ar)
 		.u.scan_id = ATH10K_SCAN_ID,
 	};
 	int ret;
+	unsigned long time_left;
 
 	lockdep_assert_held(&ar->conf_mutex);
 
@@ -2582,11 +2585,11 @@ static int ath10k_scan_stop(struct ath10k *ar)
 		goto out;
 	}
 
-	ret = wait_for_completion_timeout(&ar->scan.completed, 3*HZ);
-	if (ret == 0) {
+	time_left = wait_for_completion_timeout(&ar->scan.completed, 3 * HZ);
+	if (!time_left) {
 		ath10k_warn(ar, "failed to receive scan abortion completion: timed out\n");
 		ret = -ETIMEDOUT;
-	} else if (ret > 0) {
+	} else if (time_left > 0) {
 		ret = 0;
 	}
 
@@ -2655,6 +2658,7 @@ static int ath10k_start_scan(struct ath10k *ar,
 			     const struct wmi_start_scan_arg *arg)
 {
 	int ret;
+	unsigned long time_left;
 
 	lockdep_assert_held(&ar->conf_mutex);
 
@@ -2662,8 +2666,8 @@ static int ath10k_start_scan(struct ath10k *ar,
 	if (ret)
 		return ret;
 
-	ret = wait_for_completion_timeout(&ar->scan.started, 1*HZ);
-	if (ret == 0) {
+	time_left = wait_for_completion_timeout(&ar->scan.started, 1 * HZ);
+	if (!time_left) {
 		ret = ath10k_scan_stop(ar);
 		if (ret)
 			ath10k_warn(ar, "failed to stop scan: %d\n", ret);
@@ -4355,6 +4359,7 @@ static int ath10k_remain_on_channel(struct ieee80211_hw *hw,
 	struct ath10k_vif *arvif = ath10k_vif_to_arvif(vif);
 	struct wmi_start_scan_arg arg;
 	int ret = 0;
+	unsigned long time_left;
 
 	mutex_lock(&ar->conf_mutex);
 
@@ -4404,8 +4409,8 @@ static int ath10k_remain_on_channel(struct ieee80211_hw *hw,
 		goto exit;
 	}
 
-	ret = wait_for_completion_timeout(&ar->scan.on_channel, 3*HZ);
-	if (ret == 0) {
+	time_left = wait_for_completion_timeout(&ar->scan.on_channel, 3 * HZ);
+	if (!time_left) {
 		ath10k_warn(ar, "failed to switch to channel for roc scan\n");
 
 		ret = ath10k_scan_stop(ar);
-- 
1.7.10.4
