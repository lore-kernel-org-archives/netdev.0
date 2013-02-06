From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH v3 1/3] ssb: get mac address from sprom struct for gige driver
Date: Wed,  6 Feb 2013 23:46:06 +0100
Message-ID: <1360190768-390-2-git-send-email-hauke@hauke-m.de>
References: <1360190768-390-1-git-send-email-hauke@hauke-m.de>
Cc: mcarlson@broadcom.com, mchan@broadcom.com, nsujir@broadcom.com,
	netdev@vger.kernel.org, m@bues.ch,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:36060 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756368Ab3BFWqY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 17:46:24 -0500
In-Reply-To: <1360190768-390-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mac address is already stored in the sprom structure by the
platform code of the SoC this Ethernet core is found on, it just has to
be fetched from this structure instead of accessing the nvram here.
This patch also adds a return value to indicate if a mac address could
be fetched from the sprom structure.
When CONFIG_SSB_DRIVER_GIGE is not set the header file now also declares
ssb_gige_get_macaddr().

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
Acked-by: Michael Buesch <m@bues.ch>
---

This patch could cause merge problems with the mips tree. This version, 
removing the usage of nvram_getenv() and nvram_parse_macaddr(), should be 
used.

 include/linux/ssb/ssb_driver_gige.h |   23 +++++++++++------------
 1 file changed, 11 insertions(+), 12 deletions(-)

diff --git a/include/linux/ssb/ssb_driver_gige.h b/include/linux/ssb/ssb_driver_gige.h
index 6b05dcd..86a12b0 100644
--- a/include/linux/ssb/ssb_driver_gige.h
+++ b/include/linux/ssb/ssb_driver_gige.h
@@ -97,21 +97,16 @@ static inline bool ssb_gige_must_flush_posted_writes(struct pci_dev *pdev)
 	return 0;
 }
 
-#ifdef CONFIG_BCM47XX
-#include <asm/mach-bcm47xx/nvram.h>
 /* Get the device MAC address */
-static inline void ssb_gige_get_macaddr(struct pci_dev *pdev, u8 *macaddr)
-{
-	char buf[20];
-	if (nvram_getenv("et0macaddr", buf, sizeof(buf)) < 0)
-		return;
-	nvram_parse_macaddr(buf, macaddr);
-}
-#else
-static inline void ssb_gige_get_macaddr(struct pci_dev *pdev, u8 *macaddr)
+static inline int ssb_gige_get_macaddr(struct pci_dev *pdev, u8 *macaddr)
 {
+	struct ssb_gige *dev = pdev_to_ssb_gige(pdev);
+	if (!dev)
+		return -ENODEV;
+
+	memcpy(macaddr, dev->dev->bus->sprom.et0mac, 6);
+	return 0;
 }
-#endif
 
 extern int ssb_gige_pcibios_plat_dev_init(struct ssb_device *sdev,
 					  struct pci_dev *pdev);
@@ -175,6 +170,10 @@ static inline bool ssb_gige_must_flush_posted_writes(struct pci_dev *pdev)
 {
 	return 0;
 }
+static inline int ssb_gige_get_macaddr(struct pci_dev *pdev, u8 *macaddr)
+{
+	return -ENODEV;
+}
 
 #endif /* CONFIG_SSB_DRIVER_GIGE */
 #endif /* LINUX_SSB_DRIVER_GIGE_H_ */
-- 
1.7.10.4
