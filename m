From: Nicholas Mc Guire <der.herr-kA1LtwSENNE@public.gmane.org>
Subject: [PATCH v3] ath10k: fixup wait_for_completion_timeout return handling
Date: Thu,  8 Jan 2015 13:27:34 +0100
Message-ID: <1420720054-27870-1-git-send-email-der.herr@hofr.at>
Cc: Michal Kazior <michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org>,
	Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>,
	Chun-Yeow Yeoh <yeohchunyeow-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Yanbo Li <yanbol-Rm6X0d1/PG5y9aJCnZT0Uw@public.gmane.org>,
	Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
	ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Nicholas Mc Guire <der.herr-kA1LtwSENNE@public.gmane.org>
To: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

wait_for_completion_timeout does not return negative values so the tests
for <= 0 are not needed and the case differentiation in the error handling
path unnecessary.

v2: all wait_for_completion_timeout changes in a single patch
v3: patch formatting cleanups - no change of actual patch

Signed-off-by: Nicholas Mc Guire <der.herr-kA1LtwSENNE@public.gmane.org>
---
patch was only compile tested x86_64_defconfig + CONFIG_ATH_CARDS=m
CONFIG_ATH10K=m

patch is against linux-next 3.19.0-rc1 -next-20141226

None of the proposed cleanups are critical.
All changes should only be removing unreachable cases.

 drivers/net/wireless/ath/ath10k/debug.c |    2 +-
 drivers/net/wireless/ath/ath10k/htc.c   |    6 ++----
 drivers/net/wireless/ath/ath10k/htt.c   |    2 +-
 drivers/net/wireless/ath/ath10k/mac.c   |    2 +-
 4 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/debug.c b/drivers/net/wireless/ath/ath10k/debug.c
index a716758..7e1fe93 100644
--- a/drivers/net/wireless/ath/ath10k/debug.c
+++ b/drivers/net/wireless/ath/ath10k/debug.c
@@ -373,7 +373,7 @@ static int ath10k_debug_fw_stats_request(struct ath10k *ar)
 
 		ret = wait_for_completion_timeout(&ar->debug.fw_stats_complete,
 						  1*HZ);
-		if (ret <= 0)
+		if (ret == 0)
 			return -ETIMEDOUT;
 
 		spin_lock_bh(&ar->data_lock);
diff --git a/drivers/net/wireless/ath/ath10k/htc.c b/drivers/net/wireless/ath/ath10k/htc.c
index f1946a6..2fd9e18 100644
--- a/drivers/net/wireless/ath/ath10k/htc.c
+++ b/drivers/net/wireless/ath/ath10k/htc.c
@@ -703,11 +703,9 @@ int ath10k_htc_connect_service(struct ath10k_htc *htc,
 	/* wait for response */
 	status = wait_for_completion_timeout(&htc->ctl_resp,
 					     ATH10K_HTC_CONN_SVC_TIMEOUT_HZ);
-	if (status <= 0) {
-		if (status == 0)
-			status = -ETIMEDOUT;
+	if (status == 0) {
 		ath10k_err(ar, "Service connect timeout: %d\n", status);
-		return status;
+		return -ETIMEDOUT;
 	}
 
 	/* we controlled the buffer creation, it's aligned */
diff --git a/drivers/net/wireless/ath/ath10k/htt.c b/drivers/net/wireless/ath/ath10k/htt.c
index 56cb4ac..58b6fc1 100644
--- a/drivers/net/wireless/ath/ath10k/htt.c
+++ b/drivers/net/wireless/ath/ath10k/htt.c
@@ -102,7 +102,7 @@ int ath10k_htt_setup(struct ath10k_htt *htt)
 
 	status = wait_for_completion_timeout(&htt->target_version_received,
 					     HTT_TARGET_VERSION_TIMEOUT_HZ);
-	if (status <= 0) {
+	if (status == 0) {
 		ath10k_warn(ar, "htt version request timed out\n");
 		return -ETIMEDOUT;
 	}
diff --git a/drivers/net/wireless/ath/ath10k/mac.c b/drivers/net/wireless/ath/ath10k/mac.c
index c400567..f9d7dbb 100644
--- a/drivers/net/wireless/ath/ath10k/mac.c
+++ b/drivers/net/wireless/ath/ath10k/mac.c
@@ -2151,7 +2151,7 @@ void ath10k_offchan_tx_work(struct work_struct *work)
 
 		ret = wait_for_completion_timeout(&ar->offchan_tx_completed,
 						  3 * HZ);
-		if (ret <= 0)
+		if (ret == 0)
 			ath10k_warn(ar, "timed out waiting for offchannel skb %p\n",
 				    skb);
 
-- 
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
