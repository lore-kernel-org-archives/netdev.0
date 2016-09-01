From: =?UTF-8?q?Giedrius=20Statkevi=C4=8Dius?=
        <giedrius.statkevicius@gmail.com>
Subject: [PATCH] ath9k: bring back direction setting in ath9k_{start_stop}
Date: Thu,  1 Sep 2016 20:47:02 +0300
Message-ID: <20160901174702.8645-1-giedrius.statkevicius@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: ath9k-devel@qca.qualcomm.com, linux-wireless@vger.kernel.org,
        ath9k-devel@lists.ath9k.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Miaoqing Pan <miaoqing@codeaurora.org>,
        Kalle Valo <kvalo@qca.qualcomm.com>, stable@vger.kernel.org,
        =?UTF-8?q?Giedrius=20Statkevi=C4=8Dius?=
        <giedrius.statkevicius@gmail.com>
To: kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A regression was introduced in commit id 79d4db1214a ("ath9k: cleanup
led_pin initial") that broken the WLAN status led on my laptop with
AR9287 after suspending and resuming.

Steps to reproduce:
* Suspend (laptop)
* Resume (laptop)
* Observe that the WLAN led no longer turns ON/OFF depending on the
  status and is always red

Even though for my case it only needs to be set to OUT in ath9k_start
but for consistency bring back the IN direction setting as well.

Cc: Miaoqing Pan <miaoqing@codeaurora.org>
Cc: Kalle Valo <kvalo@qca.qualcomm.com>
Cc: <stable@vger.kernel.org>
Signed-off-by: Giedrius Statkevičius <giedrius.statkevicius@gmail.com>
---
This patch should be applied to all 4.7 and later kernels

Another user complaining about probably the same problem:
https://bugzilla.kernel.org/show_bug.cgi?id=151711

 drivers/net/wireless/ath/ath9k/main.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index 8b63988..121dc05 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -718,9 +718,12 @@ static int ath9k_start(struct ieee80211_hw *hw)
 	if (!ath_complete_reset(sc, false))
 		ah->reset_power_on = false;
 
-	if (ah->led_pin >= 0)
+	if (ah->led_pin >= 0) {
 		ath9k_hw_set_gpio(ah, ah->led_pin,
 				  (ah->config.led_active_high) ? 1 : 0);
+		ath9k_hw_gpio_request_out(ah, ah->led_pin, NULL,
+					  AR_GPIO_OUTPUT_MUX_AS_OUTPUT);
+	}
 
 	/*
 	 * Reset key cache to sane defaults (all entries cleared) instead of
@@ -864,9 +867,11 @@ static void ath9k_stop(struct ieee80211_hw *hw)
 
 	spin_lock_bh(&sc->sc_pcu_lock);
 
-	if (ah->led_pin >= 0)
+	if (ah->led_pin >= 0) {
 		ath9k_hw_set_gpio(ah, ah->led_pin,
 				  (ah->config.led_active_high) ? 0 : 1);
+		ath9k_hw_gpio_request_in(ah, ah->led_pin, NULL);
+	}
 
 	ath_prepare_reset(sc);
 
-- 
2.9.3
