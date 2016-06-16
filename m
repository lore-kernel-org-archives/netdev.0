From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] mwifiex: fix link error against sdio
Date: Thu, 16 Jun 2016 11:01:10 +0200
Message-ID: <20160616090206.932870-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	Wei-Ning Huang <wnhuang@chromium.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Calling sdio_claim_host() from the interface independent part of
the mwifiex driver is not only a layering violation, but also causes
a link error if MMC support is disabled, or if CONFIG_MMC=m
and CONFIG_MWIFIEX=y:

drivers/net/built-in.o: In function `mwifiex_fw_dpc':
:(.text+0xff138): undefined reference to `sdio_claim_host'
:(.text+0xff158): undefined reference to `sdio_release_host'

The right way to do this is to have the sdio specific code in the
sdio driver front-end, and we already have a callback pointer that
we can use for this after exporting the generic fw download
function from the core driver.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 65c71efe1c59 ("mwifiex: fix racing condition when downloading firmware")
---
 drivers/net/wireless/marvell/mwifiex/init.c |  1 +
 drivers/net/wireless/marvell/mwifiex/main.c |  6 ------
 drivers/net/wireless/marvell/mwifiex/sdio.c | 14 ++++++++++++++
 3 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/init.c b/drivers/net/wireless/marvell/mwifiex/init.c
index 78c532f0d286..a6d86d4ccd22 100644
--- a/drivers/net/wireless/marvell/mwifiex/init.c
+++ b/drivers/net/wireless/marvell/mwifiex/init.c
@@ -788,3 +788,4 @@ poll_fw:
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mwifiex_dnld_fw);
diff --git a/drivers/net/wireless/marvell/mwifiex/main.c b/drivers/net/wireless/marvell/mwifiex/main.c
index 2b65334235ca..0e280f879b58 100644
--- a/drivers/net/wireless/marvell/mwifiex/main.c
+++ b/drivers/net/wireless/marvell/mwifiex/main.c
@@ -21,7 +21,6 @@
 #include "wmm.h"
 #include "cfg80211.h"
 #include "11n.h"
-#include "sdio.h"
 
 #define VERSION	"1.0"
 
@@ -515,7 +514,6 @@ static void mwifiex_fw_dpc(const struct firmware *firmware, void *context)
 	struct semaphore *sem = adapter->card_sem;
 	bool init_failed = false;
 	struct wireless_dev *wdev;
-	struct sdio_mmc_card *card = adapter->card;
 
 	if (!firmware) {
 		mwifiex_dbg(adapter, ERROR,
@@ -531,11 +529,7 @@ static void mwifiex_fw_dpc(const struct firmware *firmware, void *context)
 	if (adapter->if_ops.dnld_fw) {
 		ret = adapter->if_ops.dnld_fw(adapter, &fw);
 	} else {
-		if (adapter->iface_type == MWIFIEX_SDIO)
-			sdio_claim_host(card->func);
 		ret = mwifiex_dnld_fw(adapter, &fw);
-		if (adapter->iface_type == MWIFIEX_SDIO)
-			sdio_release_host(card->func);
 	}
 
 	if (ret == -1)
diff --git a/drivers/net/wireless/marvell/mwifiex/sdio.c b/drivers/net/wireless/marvell/mwifiex/sdio.c
index 674465e0d837..5f8a07e38d64 100644
--- a/drivers/net/wireless/marvell/mwifiex/sdio.c
+++ b/drivers/net/wireless/marvell/mwifiex/sdio.c
@@ -544,6 +544,19 @@ static int mwifiex_pm_wakeup_card_complete(struct mwifiex_adapter *adapter)
 	return mwifiex_write_reg(adapter, CONFIGURATION_REG, 0);
 }
 
+static int mwifiex_sdio_dnld_fw(struct mwifiex_adapter *adapter,
+			struct mwifiex_fw_image *fw)
+{
+	struct sdio_mmc_card *card = adapter->card;
+	int ret;
+
+	sdio_claim_host(card->func);
+	ret = mwifiex_dnld_fw(adapter, fw);
+	sdio_release_host(card->func);
+
+	return ret;
+}
+
 /*
  * This function is used to initialize IO ports for the
  * chipsets supporting SDIO new mode eg SD8897.
@@ -2732,6 +2745,7 @@ static struct mwifiex_if_ops sdio_ops = {
 	.cleanup_mpa_buf = mwifiex_cleanup_mpa_buf,
 	.cmdrsp_complete = mwifiex_sdio_cmdrsp_complete,
 	.event_complete = mwifiex_sdio_event_complete,
+	.dnld_fw = mwifiex_sdio_dnld_fw,
 	.card_reset = mwifiex_sdio_card_reset,
 	.reg_dump = mwifiex_sdio_reg_dump,
 	.device_dump = mwifiex_sdio_device_dump,
-- 
2.9.0
