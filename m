From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH 1/2 RFC] ath10k: move code out of the parameter list
Date: Wed, 11 Mar 2015 13:19:29 -0400
Message-ID: <1426094369-10213-1-git-send-email-hofrat@osadl.org>
Cc: Valdis.Kletnieks@vt.edu, Bj??rn Mork <bjorn@mork.no>,
	ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicholas Mc Guire <hofrat@osadl.org>
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.osadl.org ([62.245.132.105]:58035 "EHLO www.osadl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750820AbbCKRYR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2015 13:24:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Putting code into the parameter list of wait_event_timeout() might be 
legal C-code but not really readable - the "inline" code is simply
moved into a function and that passed to wait_event_timeout() as the
condition.

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

Thanks to Bjorn Mork <bjorn@mork.no> for clarifying my initial confusion !

Patch was only compile tested with x86_64_defconfig + CONFIG_ATH_CARDS=m,
CONFIG_ATH10K=m

Patch is against 4.0-rc3 (localversion-next is -next-20150311)

 drivers/net/wireless/ath/ath10k/mac.c |   32 ++++++++++++++++++--------------
 1 file changed, 18 insertions(+), 14 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/mac.c b/drivers/net/wireless/ath/ath10k/mac.c
index e8cc19f..7b27d99 100644
--- a/drivers/net/wireless/ath/ath10k/mac.c
+++ b/drivers/net/wireless/ath/ath10k/mac.c
@@ -4463,11 +4463,25 @@ static int ath10k_set_rts_threshold(struct ieee80211_hw *hw, u32 value)
 	return ret;
 }
 
+static bool check_htt_state(struct ath10k *ar, bool skip)
+{
+	bool empty;
+
+	spin_lock_bh(&ar->htt.tx_lock);
+	empty = (ar->htt.num_pending_tx == 0);
+	spin_unlock_bh(&ar->htt.tx_lock);
+
+	skip = (ar->state == ATH10K_STATE_WEDGED) ||
+		test_bit(ATH10K_FLAG_CRASH_FLUSH,
+			 &ar->dev_flags);
+	return (empty || skip);
+}
+
 static void ath10k_flush(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
 			 u32 queues, bool drop)
 {
 	struct ath10k *ar = hw->priv;
-	bool skip;
+	bool skip = false;
 	int ret;
 
 	/* mac80211 doesn't care if we really xmit queued frames or not
@@ -4480,19 +4494,9 @@ static void ath10k_flush(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
 	if (ar->state == ATH10K_STATE_WEDGED)
 		goto skip;
 
-	ret = wait_event_timeout(ar->htt.empty_tx_wq, ({
-			bool empty;
-
-			spin_lock_bh(&ar->htt.tx_lock);
-			empty = (ar->htt.num_pending_tx == 0);
-			spin_unlock_bh(&ar->htt.tx_lock);
-
-			skip = (ar->state == ATH10K_STATE_WEDGED) ||
-			       test_bit(ATH10K_FLAG_CRASH_FLUSH,
-					&ar->dev_flags);
-
-			(empty || skip);
-		}), ATH10K_FLUSH_TIMEOUT_HZ);
+	ret = wait_event_timeout(ar->htt.empty_tx_wq,
+				 check_htt_state(ar, skip),
+				 ATH10K_FLUSH_TIMEOUT_HZ);
 
 	if (ret <= 0 || skip)
 		ath10k_warn(ar, "failed to flush transmit queue (skip %i ar-state %i): %i\n",
-- 
1.7.10.4
