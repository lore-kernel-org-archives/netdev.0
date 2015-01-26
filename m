From: "Fu, Zhonghui" <zhonghui.fu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: [PATCH] brcmfmac: avoid duplicated suspend/resume operation
Date: Mon, 26 Jan 2015 10:46:36 +0800
Message-ID: <54C5AA8C.4010005@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Franky Lin <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>From ff39ed4af9f1c50358fe92ec4c8eaac9db183e00 Mon Sep 17 00:00:00 2001
From: Zhonghui Fu <zhonghui.fu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date: Mon, 26 Jan 2015 10:13:21 +0800
Subject: [PATCH] brcmfmac: avoid duplicated suspend/resume operation

WiFi chip has 2 SDIO functions, and PM core will trigger
twice suspend/resume operations for one WiFi chip to do
the same things. This patch avoid this case.

Acked-by: Arend van Spriel<arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Zhonghui Fu <zhonghui.fu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
