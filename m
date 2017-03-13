From: Alban <albeu@free.fr>
Subject: [PATCH 3/7] ath9k: Add support for reading the EEPROM data using the nvmem API
Date: Mon, 13 Mar 2017 22:05:11 +0100
Message-ID: <1489439116-4233-3-git-send-email-albeu@free.fr>
References: <1489439116-4233-1-git-send-email-albeu@free.fr>
Cc: John Crispin <john@phrozen.org>, Alban <albeu@free.fr>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489439116-4233-1-git-send-email-albeu@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently SoC platforms use a firmware request to get the EEPROM data.
This is mostly a hack and rely on using a user-helper scripts which is
deprecated. A nicer alternative is to use the nvmem API which was
designed for this kind of task.

Furthermore we let CONFIG_ATH9K_AHB select CONFIG_NVMEM as such
devices will generally use this method for loading the EEPROM data.

Signed-off-by: Alban <albeu@free.fr>
---
 drivers/net/wireless/ath/ath9k/Kconfig  |  1 +
 drivers/net/wireless/ath/ath9k/eeprom.c | 10 ++++++++++
 drivers/net/wireless/ath/ath9k/hw.h     |  2 ++
 drivers/net/wireless/ath/ath9k/init.c   | 21 +++++++++++++++++++++
 4 files changed, 34 insertions(+)

diff --git a/drivers/net/wireless/ath/ath9k/Kconfig b/drivers/net/wireless/ath/ath9k/Kconfig
index 783a38f..1558c03 100644
--- a/drivers/net/wireless/ath/ath9k/Kconfig
+++ b/drivers/net/wireless/ath/ath9k/Kconfig
@@ -49,6 +49,7 @@ config ATH9K_PCI
 config ATH9K_AHB
 	bool "Atheros ath9k AHB bus support"
 	depends on ATH9K
+	select NVMEM
 	default n
 	---help---
 	  This option enables the AHB bus support in ath9k.
diff --git a/drivers/net/wireless/ath/ath9k/eeprom.c b/drivers/net/wireless/ath/ath9k/eeprom.c
index fb80ec8..1f28222 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom.c
@@ -127,6 +127,14 @@ static bool ath9k_hw_nvram_read_pdata(struct ath9k_platform_data *pdata,
 					 offset, data);
 }
 
+static bool ath9k_hw_nvram_read_data(struct ath_hw *ah,
+				     off_t offset, u16 *data)
+{
+	return ath9k_hw_nvram_read_array(ah->eeprom_data,
+					 ah->eeprom_size / 2,
+					 offset, data);
+}
+
 static bool ath9k_hw_nvram_read_firmware(const struct firmware *eeprom_blob,
 					 off_t offset, u16 *data)
 {
@@ -143,6 +151,8 @@ bool ath9k_hw_nvram_read(struct ath_hw *ah, u32 off, u16 *data)
 
 	if (ah->eeprom_blob)
 		ret = ath9k_hw_nvram_read_firmware(ah->eeprom_blob, off, data);
+	else if (ah->eeprom_data)
+		ret = ath9k_hw_nvram_read_data(ah, off, data);
 	else if (pdata && !pdata->use_eeprom && pdata->eeprom_data)
 		ret = ath9k_hw_nvram_read_pdata(pdata, off, data);
 	else
diff --git a/drivers/net/wireless/ath/ath9k/hw.h b/drivers/net/wireless/ath/ath9k/hw.h
index 9cbca12..7f17c2a 100644
--- a/drivers/net/wireless/ath/ath9k/hw.h
+++ b/drivers/net/wireless/ath/ath9k/hw.h
@@ -970,6 +970,8 @@ struct ath_hw {
 	bool disable_5ghz;
 
 	const struct firmware *eeprom_blob;
+	void *eeprom_data;
+	size_t eeprom_size;
 
 	struct ath_dynack dynack;
 
diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/ath/ath9k/init.c
index fa4b3cc..054f254 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -22,6 +22,7 @@
 #include <linux/module.h>
 #include <linux/of.h>
 #include <linux/of_net.h>
+#include <linux/nvmem-consumer.h>
 #include <linux/relay.h>
 #include <net/ieee80211_radiotap.h>
 
@@ -511,6 +512,7 @@ static int ath9k_eeprom_request(struct ath_softc *sc, const char *name)
 static void ath9k_eeprom_release(struct ath_softc *sc)
 {
 	release_firmware(sc->sc_ah->eeprom_blob);
+	kfree(sc->sc_ah->eeprom_data);
 }
 
 static int ath9k_init_platform(struct ath_softc *sc)
@@ -654,6 +656,25 @@ static int ath9k_init_softc(u16 devid, struct ath_softc *sc,
 	if (ret)
 		return ret;
 
+	/* If the EEPROM hasn't been retrieved via firmware request
+	 * use the nvmem API insted.
+	 */
+	if (!ah->eeprom_blob) {
+		struct nvmem_cell *eeprom_cell;
+
+		eeprom_cell = nvmem_cell_get(ah->dev, "eeprom");
+		if (!IS_ERR(eeprom_cell)) {
+			ah->eeprom_data = nvmem_cell_read(
+				eeprom_cell, &ah->eeprom_size);
+			nvmem_cell_put(eeprom_cell);
+
+			if (IS_ERR(ah->eeprom_data)) {
+				dev_err(ah->dev, "failed to read eeprom");
+				return PTR_ERR(ah->eeprom_data);
+			}
+		}
+	}
+
 	if (ath9k_led_active_high != -1)
 		ah->config.led_active_high = ath9k_led_active_high == 1;
 
-- 
2.7.4
