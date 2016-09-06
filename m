From: Masahiro Yamada <yamada.masahiro@socionext.com>
Subject: [PATCH 2/3] ath10k: use devm_reset_control_get() instead of
 reset_control_get()
Date: Tue,  6 Sep 2016 21:39:57 +0900
Message-ID: <1473165598-28683-3-git-send-email-yamada.masahiro@socionext.com>
References: <1473165598-28683-1-git-send-email-yamada.masahiro@socionext.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, ath10k@lists.infradead.org,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 Kalle Valo <kvalo@qca.qualcomm.com>, Johannes Berg <johannes@sipsolutions.net>
To: linux-wireless@vger.kernel.org
Return-path: <ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org>
In-Reply-To: <1473165598-28683-1-git-send-email-yamada.masahiro@socionext.com>
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

Use the managed variant of reset_control_get() to simplify the
failure path and the .remove callback.

Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>
---

 drivers/net/wireless/ath/ath10k/ahb.c | 56 +++++++----------------------------
 1 file changed, 10 insertions(+), 46 deletions(-)

diff --git a/drivers/net/wireless/ath/ath10k/ahb.c b/drivers/net/wireless/ath/ath10k/ahb.c
index 8a55c0c..6b355ee 100644
--- a/drivers/net/wireless/ath/ath10k/ahb.c
+++ b/drivers/net/wireless/ath/ath10k/ahb.c
@@ -191,92 +191,56 @@ static int ath10k_ahb_rst_ctrl_init(struct ath10k *ar)
 {
 	struct ath10k_ahb *ar_ahb = ath10k_ahb_priv(ar);
 	struct device *dev;
-	int ret;
 
 	dev = &ar_ahb->pdev->dev;
 
-	ar_ahb->core_cold_rst = reset_control_get(dev, "wifi_core_cold");
+	ar_ahb->core_cold_rst = devm_reset_control_get(dev, "wifi_core_cold");
 	if (IS_ERR_OR_NULL(ar_ahb->core_cold_rst)) {
 		ath10k_err(ar, "failed to get core cold rst ctrl: %ld\n",
 			   PTR_ERR(ar_ahb->core_cold_rst));
-		ret = ar_ahb->core_cold_rst ?
+		return ar_ahb->core_cold_rst ?
 			PTR_ERR(ar_ahb->core_cold_rst) : -ENODEV;
-		goto out;
 	}
 
-	ar_ahb->radio_cold_rst = reset_control_get(dev, "wifi_radio_cold");
+	ar_ahb->radio_cold_rst = devm_reset_control_get(dev, "wifi_radio_cold");
 	if (IS_ERR_OR_NULL(ar_ahb->radio_cold_rst)) {
 		ath10k_err(ar, "failed to get radio cold rst ctrl: %ld\n",
 			   PTR_ERR(ar_ahb->radio_cold_rst));
-		ret = ar_ahb->radio_cold_rst ?
+		return ar_ahb->radio_cold_rst ?
 			PTR_ERR(ar_ahb->radio_cold_rst) : -ENODEV;
-		goto err_core_cold_rst_put;
 	}
 
-	ar_ahb->radio_warm_rst = reset_control_get(dev, "wifi_radio_warm");
+	ar_ahb->radio_warm_rst = devm_reset_control_get(dev, "wifi_radio_warm");
 	if (IS_ERR_OR_NULL(ar_ahb->radio_warm_rst)) {
 		ath10k_err(ar, "failed to get radio warm rst ctrl: %ld\n",
 			   PTR_ERR(ar_ahb->radio_warm_rst));
-		ret = ar_ahb->radio_warm_rst ?
+		return ar_ahb->radio_warm_rst ?
 			PTR_ERR(ar_ahb->radio_warm_rst) : -ENODEV;
-		goto err_radio_cold_rst_put;
 	}
 
-	ar_ahb->radio_srif_rst = reset_control_get(dev, "wifi_radio_srif");
+	ar_ahb->radio_srif_rst = devm_reset_control_get(dev, "wifi_radio_srif");
 	if (IS_ERR_OR_NULL(ar_ahb->radio_srif_rst)) {
 		ath10k_err(ar, "failed to get radio srif rst ctrl: %ld\n",
 			   PTR_ERR(ar_ahb->radio_srif_rst));
-		ret = ar_ahb->radio_srif_rst ?
+		return ar_ahb->radio_srif_rst ?
 			PTR_ERR(ar_ahb->radio_srif_rst) : -ENODEV;
-		goto err_radio_warm_rst_put;
 	}
 
-	ar_ahb->cpu_init_rst = reset_control_get(dev, "wifi_cpu_init");
+	ar_ahb->cpu_init_rst = devm_reset_control_get(dev, "wifi_cpu_init");
 	if (IS_ERR_OR_NULL(ar_ahb->cpu_init_rst)) {
 		ath10k_err(ar, "failed to get cpu init rst ctrl: %ld\n",
 			   PTR_ERR(ar_ahb->cpu_init_rst));
-		ret = ar_ahb->cpu_init_rst ?
+		return ar_ahb->cpu_init_rst ?
 			PTR_ERR(ar_ahb->cpu_init_rst) : -ENODEV;
-		goto err_radio_srif_rst_put;
 	}
 
 	return 0;
-
-err_radio_srif_rst_put:
-	reset_control_put(ar_ahb->radio_srif_rst);
-
-err_radio_warm_rst_put:
-	reset_control_put(ar_ahb->radio_warm_rst);
-
-err_radio_cold_rst_put:
-	reset_control_put(ar_ahb->radio_cold_rst);
-
-err_core_cold_rst_put:
-	reset_control_put(ar_ahb->core_cold_rst);
-
-out:
-	return ret;
 }
 
 static void ath10k_ahb_rst_ctrl_deinit(struct ath10k *ar)
 {
 	struct ath10k_ahb *ar_ahb = ath10k_ahb_priv(ar);
 
-	if (!IS_ERR_OR_NULL(ar_ahb->core_cold_rst))
-		reset_control_put(ar_ahb->core_cold_rst);
-
-	if (!IS_ERR_OR_NULL(ar_ahb->radio_cold_rst))
-		reset_control_put(ar_ahb->radio_cold_rst);
-
-	if (!IS_ERR_OR_NULL(ar_ahb->radio_warm_rst))
-		reset_control_put(ar_ahb->radio_warm_rst);
-
-	if (!IS_ERR_OR_NULL(ar_ahb->radio_srif_rst))
-		reset_control_put(ar_ahb->radio_srif_rst);
-
-	if (!IS_ERR_OR_NULL(ar_ahb->cpu_init_rst))
-		reset_control_put(ar_ahb->cpu_init_rst);
-
 	ar_ahb->core_cold_rst = NULL;
 	ar_ahb->radio_cold_rst = NULL;
 	ar_ahb->radio_warm_rst = NULL;
-- 
1.9.1
