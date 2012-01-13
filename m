From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH V2 4/5] bcma: connect the bcma bus suspend/resume to the bcma driver suspend/resume
Date: Fri, 13 Jan 2012 23:58:41 +0100
Message-ID: <1326495522-6024-4-git-send-email-zajec5@gmail.com>
References: <1326495522-6024-1-git-send-email-zajec5@gmail.com>
Cc: Network Development <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Arend van Spriel <arend@broadcom.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Alwin Beukers <alwin@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:42276 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754113Ab2AMW7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 17:59:01 -0500
Received: by mail-ee0-f46.google.com with SMTP id d4so1238257eek.19
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2012 14:59:01 -0800 (PST)
In-Reply-To: <1326495522-6024-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>

Now the low-level driver actually gets informed that it is getting suspended and resumed.

Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
---
 drivers/bcma/main.c                                |   19 +++++++++++++++++++
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |    2 +-
 include/linux/bcma/bcma.h                          |    2 +-
 3 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/drivers/bcma/main.c b/drivers/bcma/main.c
index b711d9d..febbc0a 100644
--- a/drivers/bcma/main.c
+++ b/drivers/bcma/main.c
@@ -243,6 +243,16 @@ int __init bcma_bus_early_register(struct bcma_bus *bus,
 #ifdef CONFIG_PM
 int bcma_bus_suspend(struct bcma_bus *bus)
 {
+	struct bcma_device *core;
+
+	list_for_each_entry(core, &bus->cores, list) {
+		struct device_driver *drv = core->dev.driver;
+		if (drv) {
+			struct bcma_driver *adrv = container_of(drv, struct bcma_driver, drv);
+			if (adrv->suspend)
+				adrv->suspend(core);
+		}
+	}
 	return 0;
 }
 
@@ -257,6 +267,15 @@ int bcma_bus_resume(struct bcma_bus *bus)
 		bcma_core_chipcommon_init(&bus->drv_cc);
 	}
 
+	list_for_each_entry(core, &bus->cores, list) {
+		struct device_driver *drv = core->dev.driver;
+		if (drv) {
+			struct bcma_driver *adrv = container_of(drv, struct bcma_driver, drv);
+			if (adrv->resume)
+				adrv->resume(core);
+		}
+	}
+
 	return 0;
 }
 #endif
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
index 77fdc45..19721db 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
@@ -1135,7 +1135,7 @@ static int brcms_pci_suspend(struct pci_dev *pdev)
 	return pci_set_power_state(pdev, PCI_D3hot);
 }
 
-static int brcms_suspend(struct bcma_device *pdev, pm_message_t state)
+static int brcms_suspend(struct bcma_device *pdev)
 {
 	struct brcms_info *wl;
 	struct ieee80211_hw *hw;
diff --git a/include/linux/bcma/bcma.h b/include/linux/bcma/bcma.h
index f4b8346..83c209f 100644
--- a/include/linux/bcma/bcma.h
+++ b/include/linux/bcma/bcma.h
@@ -162,7 +162,7 @@ struct bcma_driver {
 
 	int (*probe)(struct bcma_device *dev);
 	void (*remove)(struct bcma_device *dev);
-	int (*suspend)(struct bcma_device *dev, pm_message_t state);
+	int (*suspend)(struct bcma_device *dev);
 	int (*resume)(struct bcma_device *dev);
 	void (*shutdown)(struct bcma_device *dev);
 
-- 
1.7.7
