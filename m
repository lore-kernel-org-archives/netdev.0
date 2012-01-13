From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: [PATCH 3/5] bcma: connect the bcma bus suspend/resume to the bcma
 driver suspend/resume
Date: Fri, 13 Jan 2012 00:01:23 -0800 (PST)
Message-ID: <alpine.LNX.2.00.1201130000490.5860@air.linux-foundation.org>
References: <CA+55aFzm21ZKs7e_ocVA1bQQ=Js2dJpbiycwHR3v8yNvb0MgTw@mail.gmail.com> <1326440480-26271-1-git-send-email-zajec5@gmail.com> <alpine.LNX.2.00.1201122354430.5860@air.linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: =?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>,
	Arend van Spriel <arend@broadcom.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Alwin Beukers <alwin@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:58139 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751196Ab2AMIAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 03:00:47 -0500
Received: by obcva7 with SMTP id va7so1847389obc.19
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2012 00:00:46 -0800 (PST)
In-Reply-To: <alpine.LNX.2.00.1201122354430.5860@air.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 12 Jan 2012 23:15:41 -0800

Now the low-level driver actually gets informed that it is getting suspended and resumed.

Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
---
 drivers/bcma/main.c                                |   19 +++++++++++++++++++
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |    2 +-
 include/linux/bcma/bcma.h                          |    2 +-
 3 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/drivers/bcma/main.c b/drivers/bcma/main.c
index b711d9d634a7..febbc0a1222a 100644
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
index d106576ce338..213130afdaf7 100644
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
index f4b8346b1a33..83c209f39493 100644
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
1.7.8.rc2.3.g0911
