From: Alban <albeu@free.fr>
Subject: [PATCH 6/7] ath9k: Allow using the reset API for the external reset
Date: Mon, 13 Mar 2017 22:05:14 +0100
Message-ID: <1489439116-4233-6-git-send-email-albeu@free.fr>
References: <1489439116-4233-1-git-send-email-albeu@free.fr>
Cc: John Crispin <john@phrozen.org>, Alban Bedel <albeu@free.fr>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489439116-4233-1-git-send-email-albeu@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alban Bedel <albeu@free.fr>

Allow using the reset API instead of a platform specific callback to
reset the device.

Signed-off-by: Alban Bedel <albeu@free.fr>
---
 drivers/net/wireless/ath/ath9k/hw.c   | 26 +++++++++++++++++++++-----
 drivers/net/wireless/ath/ath9k/hw.h   |  1 +
 drivers/net/wireless/ath/ath9k/init.c | 10 ++++++++++
 3 files changed, 32 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath/ath9k/hw.c
index 8c5c2dd..efc0435 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -21,6 +21,7 @@
 #include <linux/bitops.h>
 #include <linux/etherdevice.h>
 #include <linux/gpio.h>
+#include <linux/reset.h>
 #include <asm/unaligned.h>
 
 #include "hw.h"
@@ -551,6 +552,24 @@ static int ath9k_hw_attach_ops(struct ath_hw *ah)
 	return 0;
 }
 
+static int ath9k_hw_external_reset(struct ath_hw *ah)
+{
+	int ret = 0;
+
+	ath_dbg(ath9k_hw_common(ah), RESET,
+		"reset MAC via external reset\n");
+
+	if (ah->external_reset) {
+		ret = ah->external_reset();
+	} else if (ah->reset) {
+		ret = reset_control_assert(ah->reset);
+		if (!ret)
+			ret = reset_control_deassert(ah->reset);
+	}
+
+	return ret;
+}
+
 /* Called for all hardware families */
 static int __ath9k_hw_init(struct ath_hw *ah)
 {
@@ -1286,14 +1305,11 @@ static bool ath9k_hw_ar9330_reset_war(struct ath_hw *ah, int type)
 			break;
 	}
 
-	if (ah->external_reset &&
+	if ((ah->reset || ah->external_reset) &&
 	    (npend || type == ATH9K_RESET_COLD)) {
 		int reset_err = 0;
 
-		ath_dbg(ath9k_hw_common(ah), RESET,
-			"reset MAC via external reset\n");
-
-		reset_err = ah->external_reset();
+		reset_err = ath9k_hw_external_reset(ah);
 		if (reset_err) {
 			ath_err(ath9k_hw_common(ah),
 				"External reset failed, err=%d\n",
diff --git a/drivers/net/wireless/ath/ath9k/hw.h b/drivers/net/wireless/ath/ath9k/hw.h
index 7f17c2a..53b67e3 100644
--- a/drivers/net/wireless/ath/ath9k/hw.h
+++ b/drivers/net/wireless/ath/ath9k/hw.h
@@ -966,6 +966,7 @@ struct ath_hw {
 	bool is_clk_25mhz;
 	int (*get_mac_revision)(void);
 	int (*external_reset)(void);
+	struct reset_control *reset;
 	bool disable_2ghz;
 	bool disable_5ghz;
 
diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/ath/ath9k/init.c
index 5cb9c61..f1cb806 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -25,6 +25,7 @@
 #include <linux/nvmem-consumer.h>
 #include <linux/relay.h>
 #include <linux/clk.h>
+#include <linux/reset.h>
 #include <net/ieee80211_radiotap.h>
 
 #include "ath9k.h"
@@ -697,6 +698,15 @@ static int ath9k_init_softc(u16 devid, struct ath_softc *sc,
 	if (!is_valid_ether_addr(common->macaddr))
 		ath9k_get_nvmem_address(sc);
 
+	/* Try to get a reset controller */
+	ah->reset = devm_reset_control_get_optional(sc->dev, NULL);
+	if (IS_ERR(ah->reset)) {
+		if (PTR_ERR(ah->reset) != -ENOENT &&
+		    PTR_ERR(ah->reset) != -ENOTSUPP)
+			return PTR_ERR(ah->reset);
+		ah->reset = NULL;
+	}
+
 	/* If the EEPROM hasn't been retrieved via firmware request
 	 * use the nvmem API insted.
 	 */
-- 
2.7.4
