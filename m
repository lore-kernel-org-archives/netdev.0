From: "Fu, Zhonghui" <zhonghui.fu@linux.intel.com>
Subject: [PATCH v3] brcmfmac: avoid duplicated suspend/resume operation
Date: Thu, 12 Feb 2015 11:26:53 +0800
Message-ID: <54DC1D7D.5050407@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Kalle Valo <kvalo@codeaurora.org>, brudley@broadcom.com,
	Arend van Spriel <arend@broadcom.com>,
	Franky Lin <frankyl@broadcom.com>, meuleman@broadcom.com,
	linville@tuxdriver.com, pieterpg@broadcom.com, hdegoede@redhat.com,
	wens@csie.org, linux-wireless@vger.kernel.org,
	brcm80211-dev-list@broadcom.com, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From a05d35ab334c20970c236fb971dae88810078c88 Mon Sep 17 00:00:00 2001
From: Fu Zhonghui <zhonghui.fu@linux.intel.com>
Date: Thu, 12 Feb 2015 10:49:35 +0800
Subject: [PATCH v3] brcmfmac: avoid duplicated suspend/resume operation

WiFi chip has 2 SDIO functions, and PM core will trigger
twice suspend/resume operations for one WiFi chip to do
the same things. This patch avoid this case.

Acked-by: Arend van Spriel <arend@broadcom.com>
Signed-off-by: Fu Zhonghui <zhonghui.fu@linux.intel.com>
---
Changes in v3:
- Rebase to wireless-drivers-next/master branch

 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
index 7944224..b8832a7 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
@@ -1117,9 +1117,13 @@ static int brcmf_ops_sdio_suspend(struct device *dev)
 	struct brcmf_bus *bus_if;
 	struct brcmf_sdio_dev *sdiodev;
 	mmc_pm_flag_t sdio_flags;
+	struct sdio_func *func = dev_to_sdio_func(dev);
 
 	brcmf_dbg(SDIO, "Enter\n");
 
+	if (func->num == 2)
+		return 0;
+
 	bus_if = dev_get_drvdata(dev);
 	sdiodev = bus_if->bus_priv.sdio;
 
@@ -1148,9 +1152,16 @@ static int brcmf_ops_sdio_suspend(struct device *dev)
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
-- 1.9.1
