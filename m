From: "Fu, Zhonghui" <zhonghui.fu@linux.intel.com>
Subject: [PATCH v3] brcmfmac: prohibit ACPI power management for brcmfmac
 driver
Date: Mon, 11 May 2015 10:41:32 +0800
Message-ID: <555016DC.804@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: "brudley@broadcom.com" <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	Franky Lin <frankyl@broadcom.com>,
	"meuleman@broadcom.com" <meuleman@broadcom.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	"pieterpg@broadcom.com" <pieterpg@broadcom.com>,
	"hdegoede@redhat.com" <hdegoede@redhat.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"brcm80211-dev-list@broadcom.com" <brcm80211-dev-list@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:50364 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751561AbbEKCll (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 May 2015 22:41:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ACPI will manage WiFi chip's power state during suspend/resume
process on some tablet platforms(such as ASUS T100TA). This is
not supported by brcmfmac driver now, and the context of WiFi
chip will be damaged after resume. This patch informs ACPI not
to manage WiFi chip's power state.

Signed-off-by: Zhonghui Fu <zhonghui.fu@linux.intel.com>
Acked-by: Arend van Spriel <arend@broadcom.com>
---
Changes in v3:
- Have the assignment separate for the if statement.

 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
index 9b508bd..c960a12 100644
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
@@ -1121,6 +1124,12 @@ static int brcmf_ops_sdio_probe(struct sdio_func *func,
 	brcmf_dbg(SDIO, "sdio device ID: 0x%04x\n", func->device);
 	brcmf_dbg(SDIO, "Function#: %d\n", func->num);
 
+	/* prohibit ACPI power management for this device */
+	dev = &func->dev;
+	adev = ACPI_COMPANION(dev);
+	if (adev)
+		adev->flags.power_manageable = 0;
+
 	/* Consume func num 1 but dont do anything with it. */
 	if (func->num == 1)
 		return 0;
-- 1.7.1
