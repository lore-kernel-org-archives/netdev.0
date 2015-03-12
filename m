From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH 2/3 RFC] ath10k: wmi: match wait_for_completion_timeout return
 type
Date: Thu, 12 Mar 2015 11:49:22 -0400
Message-ID: <1426175362-8640-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
 linux-kernel@vger.kernel.org, ath10k@lists.infradead.org,
 Nicholas Mc Guire <hofrat@osadl.org>
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/ath10k/>
List-Post: <mailto:ath10k@lists.infradead.org>
List-Help: <mailto:ath10k-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=subscribe>
Sender: "ath10k" <ath10k-bounces@lists.infradead.org>
Errors-To: ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Return type of wait_for_completion_timeout is unsigned long not int.
An appropriately named unsigned long is added and the assignments fixed up.
Rather than returning 0 (timeout) or a more or less random remaining time
(completion success) this return 0 or 1 which also resolves the type of the
functions being int.

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

Checking the call-sites of ath10k_wmi_wait_for_unified_ready and 
ath10k_wmi_wait_for_service_ready the positive return value (remaining
time in jiffies) is never passed up the call-chain nor used so it is 
cleaner to treat this like a boolean success/fail only (actually the two
functions should probably be of type bool - but that does not seem to be
common practice in the ath10k code base)

Patch was only compile tested with x86_64_defconfig + CONFIG_ATH_CARDS=m,
CONFIG_ATH10K=m

Patch is against 4.0-rc3 (localversion-next is -next-20150312)
:
 drivers/net/wireless/ath/ath10k/wmi.c |   20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/wmi.c b/drivers/net/wireless/ath/ath10k/wmi.c
index c7ea77e..a1cdcba 100644
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
+	if(!time_left)
+		return 0;
+	return 1;
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
+	if(!time_left)
+		return 0;
+	return 1;
 }
 
 struct sk_buff *ath10k_wmi_alloc_skb(struct ath10k *ar, u32 len)
-- 
1.7.10.4
