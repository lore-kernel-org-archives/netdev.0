From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] ath10k: htc: match wait_for_completion_timeout return type
Date: Fri, 13 Mar 2015 14:38:21 -0400
Message-ID: <1426271901-20596-1-git-send-email-hofrat@osadl.org>
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

Patch was only compile tested with x86_64_defconfig + CONFIG_ATH_CARDS=m,
CONFIG_ATH10K=m

Patch is against 4.0-rc3 (localversion-next is -next-20150313)

 drivers/net/wireless/ath/ath10k/htc.c |   23 +++++++++++++----------
 1 file changed, 13 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/htc.c b/drivers/net/wireless/ath/ath10k/htc.c
index 2fd9e18..690a2f5 100644
--- a/drivers/net/wireless/ath/ath10k/htc.c
+++ b/drivers/net/wireless/ath/ath10k/htc.c
@@ -548,6 +548,7 @@ int ath10k_htc_wait_target(struct ath10k_htc *htc)
 {
 	struct ath10k *ar = htc->ar;
 	int i, status = 0;
+	unsigned long time_left;
 	struct ath10k_htc_svc_conn_req conn_req;
 	struct ath10k_htc_svc_conn_resp conn_resp;
 	struct ath10k_htc_msg *msg;
@@ -555,9 +556,9 @@ int ath10k_htc_wait_target(struct ath10k_htc *htc)
 	u16 credit_count;
 	u16 credit_size;
 
-	status = wait_for_completion_timeout(&htc->ctl_resp,
-					     ATH10K_HTC_WAIT_TIMEOUT_HZ);
-	if (status == 0) {
+	time_left = wait_for_completion_timeout(&htc->ctl_resp,
+						ATH10K_HTC_WAIT_TIMEOUT_HZ);
+	if (!time_left) {
 		/* Workaround: In some cases the PCI HIF doesn't
 		 * receive interrupt for the control response message
 		 * even if the buffer was completed. It is suspected
@@ -569,10 +570,11 @@ int ath10k_htc_wait_target(struct ath10k_htc *htc)
 		for (i = 0; i < CE_COUNT; i++)
 			ath10k_hif_send_complete_check(htc->ar, i, 1);
 
-		status = wait_for_completion_timeout(&htc->ctl_resp,
-						     ATH10K_HTC_WAIT_TIMEOUT_HZ);
+		time_left =
+		wait_for_completion_timeout(&htc->ctl_resp,
+					    ATH10K_HTC_WAIT_TIMEOUT_HZ);
 
-		if (status == 0)
+		if (!time_left)
 			status = -ETIMEDOUT;
 	}
 
@@ -646,6 +648,7 @@ int ath10k_htc_connect_service(struct ath10k_htc *htc,
 	struct sk_buff *skb;
 	unsigned int max_msg_size = 0;
 	int length, status;
+	unsigned long time_left;
 	bool disable_credit_flow_ctrl = false;
 	u16 message_id, service_id, flags = 0;
 	u8 tx_alloc = 0;
@@ -701,10 +704,10 @@ int ath10k_htc_connect_service(struct ath10k_htc *htc,
 	}
 
 	/* wait for response */
-	status = wait_for_completion_timeout(&htc->ctl_resp,
-					     ATH10K_HTC_CONN_SVC_TIMEOUT_HZ);
-	if (status == 0) {
-		ath10k_err(ar, "Service connect timeout: %d\n", status);
+	time_left = wait_for_completion_timeout(&htc->ctl_resp,
+						ATH10K_HTC_CONN_SVC_TIMEOUT_HZ);
+	if (!time_left) {
+		ath10k_err(ar, "Service connect timeout\n");
 		return -ETIMEDOUT;
 	}
 
-- 
1.7.10.4
