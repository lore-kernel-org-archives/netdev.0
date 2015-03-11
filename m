From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH RFC v2] ath10k: move code from parameter list into a function
Date: Wed, 11 Mar 2015 15:01:59 -0400
Message-ID: <1426100519-20636-1-git-send-email-hofrat@osadl.org>
Cc: Valdis.Kletnieks@vt.edu, Bj??rn Mork <bjorn@mork.no>,
	Jeff Haran <Jeff.Haran@citrix.com>,
	Pat Erley <pat-lkml@erley.org>, ath10k@lists.infradead.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Nicholas Mc Guire <hofrat@osadl.org>
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Putting code into the parameter list of wait_event_timeout() might be
legal C-code but not really readable - the "inline" code is simply
moved into a function and that passed to wait_event_timeout() as the
condition. As wait_event_timeout will always return >= 0 the following
timeout check is fixed up to  ret == 0 .

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

Thanks to Bjorn Mork <bjorn@mork.no> for clarifying my initial confusion !

v2: Thanks to Pat Erley <pat-lkml@erley.org> for catching the botched skip
    parameter - should have been call by reference not value - fixed here.

As Bjorn Mork <bjorn@mork.no> pointed out, a patch like this is hard to
verify by testing - but I do think that the code readability is much
better (if the patch is correct with respect to code behavior) and helps
simplify/automate API usage checking so its worth the effort.

Comments on if this is functionally equivalent to the original code as well
as if the helper func name is suitable would be appreciated.

Patch was only compile tested with x86_64_defconfig + CONFIG_ATH_CARDS=m,
CONFIG_ATH10K=m and the generated mac.i file code reviewed.

Patch is against 4.0-rc3 (localversion-next is -next-20150311)

 drivers/net/wireless/ath/ath10k/mac.c |   34 ++++++++++++++++++---------------
 1 file changed, 19 insertions(+), 15 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/mac.c b/drivers/net/wireless/ath/ath10k/mac.c
index e8cc19f..a7a12cc 100644
--- a/drivers/net/wireless/ath/ath10k/mac.c
+++ b/drivers/net/wireless/ath/ath10k/mac.c
@@ -4463,11 +4463,25 @@ static int ath10k_set_rts_threshold(struct ieee80211_hw *hw, u32 value)
 	return ret;
 }
 
+static bool check_htt_state(struct ath10k *ar, bool *skip)
+{
+	bool empty;
+
+	spin_lock_bh(&ar->htt.tx_lock);
+	empty = (ar->htt.num_pending_tx == 0);
+	spin_unlock_bh(&ar->htt.tx_lock);
+
+	*skip = (ar->state == ATH10K_STATE_WEDGED) ||
+		test_bit(ATH10K_FLAG_CRASH_FLUSH,
+			 &ar->dev_flags);
+	return (empty || *skip);
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
@@ -4480,21 +4494,11 @@ static void ath10k_flush(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
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
+				 check_htt_state(ar, &skip),
+				 ATH10K_FLUSH_TIMEOUT_HZ);
 
-	if (ret <= 0 || skip)
+	if (ret == 0 || skip)
 		ath10k_warn(ar, "failed to flush transmit queue (skip %i ar-state %i): %i\n",
 			    skip, ar->state, ret);
 
-- 
1.7.10.4
