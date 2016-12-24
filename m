From: =?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: [PATCH 4/6] wl1251: Generate random MAC address only if driver does not have valid
Date: Sat, 24 Dec 2016 17:52:59 +0100
Message-ID: <1482598381-16513-5-git-send-email-pali.rohar@gmail.com>
References: <1482598381-16513-1-git-send-email-pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org,
        =?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar@gmail.com>
To: Ming Lei <ming.lei@canonical.com>,
        "Luis R. Rodriguez" <mcgrof@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        David Gnedt <david.gnedt@davizone.at>,
        Michal Kazior <michal.kazior@tieto.com>,
        Daniel Wagner <wagi@monom.org>,
        Tony Lindgren <tony@atomide.com>,
        Sebastian Reichel <sre@kernel.org>,
        Pavel Machek <pavel@ucw.cz>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Grazvydas Ignotas <notasas@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482598381-16513-1-git-send-email-pali.rohar@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Before this patch driver generated random MAC address every time when was
doing initialization. And after that random MAC address could be
overwritten with fixed one if provided.

This patch changes order. First it tries to read fixed MAC address and if
it fails then driver generates random MAC address.

Signed-off-by: Pali Rohár <pali.rohar@gmail.com>
---
 drivers/net/wireless/ti/wl1251/main.c |   27 ++++++++++++++++++---------
 1 file changed, 18 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wireless/ti/wl1251/main.c
index 8971b64..c3fa0b6 100644
--- a/drivers/net/wireless/ti/wl1251/main.c
+++ b/drivers/net/wireless/ti/wl1251/main.c
@@ -1582,7 +1582,24 @@ int wl1251_init_ieee80211(struct wl1251 *wl)
 	wl->hw->queues = 4;
 
 	if (wl->use_eeprom)
-		wl1251_read_eeprom_mac(wl);
+		ret = wl1251_read_eeprom_mac(wl);
+	else
+		ret = -EINVAL;
+
+	if (ret == 0 && !is_valid_ether_addr(wl->mac_addr))
+		ret = -EINVAL;
+
+	if (ret < 0) {
+		/*
+		 * In case our MAC address is not correctly set,
+		 * we use a random but Nokia MAC.
+		 */
+		static const u8 nokia_oui[3] = {0x00, 0x1f, 0xdf};
+		memcpy(wl->mac_addr, nokia_oui, 3);
+		get_random_bytes(wl->mac_addr + 3, 3);
+		wl1251_warning("MAC address in eeprom or nvs data is not valid");
+		wl1251_warning("Setting random MAC address: %pM", wl->mac_addr);
+	}
 
 	ret = wl1251_register_hw(wl);
 	if (ret)
@@ -1623,7 +1640,6 @@ struct ieee80211_hw *wl1251_alloc_hw(void)
 	struct ieee80211_hw *hw;
 	struct wl1251 *wl;
 	int i;
-	static const u8 nokia_oui[3] = {0x00, 0x1f, 0xdf};
 
 	hw = ieee80211_alloc_hw(sizeof(*wl), &wl1251_ops);
 	if (!hw) {
@@ -1674,13 +1690,6 @@ struct ieee80211_hw *wl1251_alloc_hw(void)
 	INIT_WORK(&wl->irq_work, wl1251_irq_work);
 	INIT_WORK(&wl->tx_work, wl1251_tx_work);
 
-	/*
-	 * In case our MAC address is not correctly set,
-	 * we use a random but Nokia MAC.
-	 */
-	memcpy(wl->mac_addr, nokia_oui, 3);
-	get_random_bytes(wl->mac_addr + 3, 3);
-
 	wl->state = WL1251_STATE_OFF;
 	mutex_init(&wl->mutex);
 
-- 
1.7.9.5
