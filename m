From: "Fu, Zhonghui" <zhonghui.fu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: [PATCH v2] brcmfmac: prohibit ACPI power management for brcmfmac
 driver
Date: Sun, 03 May 2015 23:26:17 +0800
Message-ID: <55463E19.7070709@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: "brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org" <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Franky Lin <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org" <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	"pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org" <pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org" <brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

ACPI will manage WiFi chip's power state during suspend/resume
process on some tablet platforms(such as ASUS T100TA). This is
not supported by brcmfmac driver now, and the context of WiFi
chip will be damaged after resume. This patch informs ACPI not
to manage WiFi chip's power state.

Signed-off-by: Zhonghui Fu <zhonghui.fu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
---
Changes in v2:
- Another implementation.

 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
index 9b508bd..6c519e3 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
@@ -33,6 +33,7 @@
 #include <linux/suspend.h>
 #include <linux/errno.h>
 #include <linux/module.h>
+#include <linux/acpi.h>
 #include <net/cfg80211.h>
 
 #include <defs.h>
@@ -1114,6 +1115,8 @@ static int brcmf_ops_sdio_probe(struct sdio_func *func,
 	int err;
 	struct brcmf_sdio_dev *sdiodev;
 	struct brcmf_bus *bus_if;
+	struct device *dev;
+	struct acpi_device *adev;
 
 	brcmf_dbg(SDIO, "Enter\n");
 	brcmf_dbg(SDIO, "Class=%x\n", func->class);
@@ -1121,6 +1124,11 @@ static int brcmf_ops_sdio_probe(struct sdio_func *func,
 	brcmf_dbg(SDIO, "sdio device ID: 0x%04x\n", func->device);
 	brcmf_dbg(SDIO, "Function#: %d\n", func->num);
 
+	/* prohibit ACPI power management for this device */
+	dev = &func->dev;
+	if (adev = ACPI_COMPANION(dev))
+		adev->flags.power_manageable = 0;
+
 	/* Consume func num 1 but dont do anything with it. */
 	if (func->num == 1)
 		return 0;
-- 1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
