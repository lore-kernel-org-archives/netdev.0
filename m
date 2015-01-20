From: "Fu, Zhonghui" <zhonghui.fu@linux.intel.com>
Subject: [PATCH] brcmfmac: avoid duplicated suspend/resume operation
Date: Tue, 20 Jan 2015 11:31:18 +0800
Message-ID: <54BDCC06.8090107@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: brudley@broadcom.com, Arend van Spriel <arend@broadcom.com>,
	Franky Lin <frankyl@broadcom.com>, meuleman@broadcom.com,
	kvalo@codeaurora.org, linville@tuxdriver.com,
	pieterpg@broadcom.com, hdegoede@redhat.com, wens@csie.org,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From 04d3fa673897ca4ccbea6c76836d0092dba2484a Mon Sep 17 00:00:00 2001
From: Zhonghui Fu <zhonghui.fu@linux.intel.com>
Date: Tue, 20 Jan 2015 11:14:13 +0800
Subject: [PATCH] brcmfmac: avoid duplicated suspend/resume operation

WiFi chip has 2 SDIO functions, and PM core will trigger
twice suspend/resume operations for one WiFi chip to do
the same things. This patch avoid this case.

Acked-by: Arend van Spriel <arend@broadcom.com>
Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Acked-by: Kalle Valo <kvalo@codeaurora.org>
Signed-off-by: Zhonghui Fu <zhonghui.fu@linux.intel.com>
---
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
index 9880dae..618b545 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
@@ -1139,11 +1139,17 @@ void brcmf_sdio_wowl_config(struct device *dev, bool enabled)
 static int brcmf_ops_sdio_suspend(struct device *dev)
 {
 	struct brcmf_bus *bus_if = dev_get_drvdata(dev);
-	struct brcmf_sdio_dev *sdiodev = bus_if->bus_priv.sdio;
+	struct brcmf_sdio_dev *sdiodev;
 	mmc_pm_flag_t sdio_flags;
+	struct sdio_func *func = dev_to_sdio_func(dev);
 
 	brcmf_dbg(SDIO, "Enter\n");
 
+	if (func->num == 2)
+		return 0;
+
+	sdiodev = bus_if->bus_priv.sdio;
+
 	atomic_set(&sdiodev->suspend, true);
 
 	if (sdiodev->wowl_enabled) {
@@ -1164,9 +1170,16 @@ static int brcmf_ops_sdio_suspend(struct device *dev)
 static int brcmf_ops_sdio_resume(struct device *dev)
 {
 	struct brcmf_bus *bus_if = dev_get_drvdata(dev);
-	struct brcmf_sdio_dev *sdiodev = bus_if->bus_priv.sdio;
+	struct brcmf_sdio_dev *sdiodev;
+	struct sdio_func *func = dev_to_sdio_func(dev);
 
 	brcmf_dbg(SDIO, "Enter\n");
+
+	if (func->num == 2)
+		return 0;
+
+	sdiodev = bus_if->bus_priv.sdio;
+
 	if (sdiodev->pdata && sdiodev->pdata->oob_irq_supported)
 		disable_irq_wake(sdiodev->pdata->oob_irq_nr);
 	brcmf_sdio_wd_timer(sdiodev->bus, BRCMF_WD_POLL_MS);
-- 1.7.1
