From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH] ssb: fix nvram_get on bcm47xx platform
Date: Sat, 27 Nov 2010 17:50:12 +0100
Message-ID: <1290876612-4440-1-git-send-email-hauke@hauke-m.de>
Cc: netdev@vger.kernel.org, Hauke Mehrtens <hauke@hauke-m.de>
To: mb@bu3sch.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:34308 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752824Ab0K0RBH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Nov 2010 12:01:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The nvram_get function was never in the mainline kernel, it only
existed in an external OpenWrt patch. Use nvram_getenv function, which
is in mainline and use an include instead of an extra function
declaration.
et0macaddr contains the mac address in text from like
00:11:22:33:44:55. We have to parse it before adding it into macaddr.

nvram_parse_macaddr will be merged into asm/mach-bcm47xx/nvram.h though
the MIPS git tree and will be available soon. It will not build now
without nvram_parse_macaddr, but it haven't done before.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 include/linux/ssb/ssb_driver_gige.h |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/include/linux/ssb/ssb_driver_gige.h b/include/linux/ssb/ssb_driver_gige.h
index 942e387..eba52a1 100644
--- a/include/linux/ssb/ssb_driver_gige.h
+++ b/include/linux/ssb/ssb_driver_gige.h
@@ -96,16 +96,21 @@ static inline bool ssb_gige_must_flush_posted_writes(struct pci_dev *pdev)
 	return 0;
 }
 
-extern char * nvram_get(const char *name);
+#ifdef CONFIG_BCM47XX
+#include <asm/mach-bcm47xx/nvram.h>
 /* Get the device MAC address */
 static inline void ssb_gige_get_macaddr(struct pci_dev *pdev, u8 *macaddr)
 {
-#ifdef CONFIG_BCM47XX
-	char *res = nvram_get("et0macaddr");
-	if (res)
-		memcpy(macaddr, res, 6);
-#endif
+	char buf[20];
+	if (nvram_getenv("et0macaddr", buf, sizeof(buf)) < 0)
+		return;
+	nvram_parse_macaddr(buf, macaddr);
 }
+#else
+static inline void ssb_gige_get_macaddr(struct pci_dev *pdev, u8 *macaddr)
+{
+}
+#endif
 
 extern int ssb_gige_pcibios_plat_dev_init(struct ssb_device *sdev,
 					  struct pci_dev *pdev);
-- 
1.7.1

