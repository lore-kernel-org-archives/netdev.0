From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] ath10k: harmonize error case handling in ath10k_core_start
Date: Mon, 16 Mar 2015 04:48:57 -0400
Message-ID: <1426495737-18691-1-git-send-email-hofrat@osadl.org>
Cc: Michal Kazior <michal.kazior@tieto.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	ath10k@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicholas Mc Guire <hofrat@osadl.org>
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All of the bringup/init functions called in ath10k_core_start return 0 
on success and != 0 on failure. ath10k_wmi_wait_for_service_ready(),
ath10k_wmi_wait_for_unified_ready() and their call sites were adjusted
to fit this model.
The return type of wait_for_completion_timeout is unsigned long not int so
ath10k_wmi_wait_for_service_ready() and ath10k_wmi_wait_for_unified_ready()
were fixed up accordingly.

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

This was initially in two separate patches which were joined as suggested
by Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> to ensure that it
will not break bisection - thanks!

Patch was only compile test with x86_64_defconfig + CONFIG_ATH_CARDS=m,
CONFIG_ATH10K=m

Patch is against 4.0-rc3 (localversion-next is -next-20150316)

 drivers/net/wireless/ath/ath10k/core.c |    6 ++----
 drivers/net/wireless/ath/ath10k/wmi.c  |   20 ++++++++++++--------
 2 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/core.c b/drivers/net/wireless/ath/ath10k/core.c
index c0e454b..e97069f 100644
--- a/drivers/net/wireless/ath/ath10k/core.c
+++ b/drivers/net/wireless/ath/ath10k/core.c
@@ -1080,9 +1080,8 @@ int ath10k_core_start(struct ath10k *ar, enum ath10k_firmware_mode mode)
 
 	if (mode == ATH10K_FIRMWARE_MODE_NORMAL) {
 		status = ath10k_wmi_wait_for_service_ready(ar);
-		if (status <= 0) {
+		if (status) {
 			ath10k_warn(ar, "wmi service ready event not received");
-			status = -ETIMEDOUT;
 			goto err_hif_stop;
 		}
 	}
@@ -1098,9 +1097,8 @@ int ath10k_core_start(struct ath10k *ar, enum ath10k_firmware_mode mode)
 	}
 
 	status = ath10k_wmi_wait_for_unified_ready(ar);
-	if (status <= 0) {
+	if (status) {
 		ath10k_err(ar, "wmi unified ready event not received\n");
-		status = -ETIMEDOUT;
 		goto err_hif_stop;
 	}
 
diff --git a/drivers/net/wireless/ath/ath10k/wmi.c b/drivers/net/wireless/ath/ath10k/wmi.c
index c7ea77e..19ed27a 100644
--- a/drivers/net/wireless/ath/ath10k/wmi.c
+++ b/drivers/net/wireless/ath/ath10k/wmi.c
@@ -884,20 +884,24 @@ void ath10k_wmi_put_wmi_channel(struct wmi_channel *ch,
 
 int ath10k_wmi_wait_for_service_ready(struct ath10k *ar)
 {
-	int ret;
+	unsigned long time_left;
 
-	ret = wait_for_completion_timeout(&ar->wmi.service_ready,
-					  WMI_SERVICE_READY_TIMEOUT_HZ);
-	return ret;
+	time_left = wait_for_completion_timeout(&ar->wmi.service_ready,
+						WMI_SERVICE_READY_TIMEOUT_HZ);
+	if (!time_left)
+		return -ETIMEDOUT;
+	return 0;
 }
 
 int ath10k_wmi_wait_for_unified_ready(struct ath10k *ar)
 {
-	int ret;
+	unsigned long time_left;
 
-	ret = wait_for_completion_timeout(&ar->wmi.unified_ready,
-					  WMI_UNIFIED_READY_TIMEOUT_HZ);
-	return ret;
+	time_left = wait_for_completion_timeout(&ar->wmi.unified_ready,
+						WMI_UNIFIED_READY_TIMEOUT_HZ);
+	if (!time_left)
+		return -ETIMEDOUT;
+	return 0;
 }
 
 struct sk_buff *ath10k_wmi_alloc_skb(struct ath10k *ar, u32 len)
-- 
1.7.10.4
