From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v2 1/2] atm: nicstar: re-use native mac_pton() helper
Date: Tue,  3 Sep 2013 15:13:43 +0300
Message-ID: <1378210424-14781-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andy.shevchenko@gmail.com>
To: Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net,
	inux Net Dev <netdev@vger.kernel.org>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8608 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752390Ab3ICMOC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 08:14:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andy.shevchenko@gmail.com>

There is a nice helper to parse MAC. Let's use it and remove custom
implementation.

Signed-off-by: Andy Shevchenko <andy.shevchenko@gmail.com>
---
 drivers/atm/nicstar.c | 26 +-------------------------
 1 file changed, 1 insertion(+), 25 deletions(-)

diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index 6587dc2..409502a 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -153,7 +153,6 @@ static int ns_ioctl(struct atm_dev *dev, unsigned int cmd, void __user * arg);
 static void which_list(ns_dev * card, struct sk_buff *skb);
 #endif
 static void ns_poll(unsigned long arg);
-static int ns_parse_mac(char *mac, unsigned char *esi);
 static void ns_phy_put(struct atm_dev *dev, unsigned char value,
 		       unsigned long addr);
 static unsigned char ns_phy_get(struct atm_dev *dev, unsigned long addr);
@@ -779,7 +778,7 @@ static int ns_init_card(int i, struct pci_dev *pcidev)
 		return error;
 	}
 
-	if (ns_parse_mac(mac[i], card->atmdev->esi)) {
+	if (mac[i] == NULL || mac_pton(mac[i], card->atmdev->esi)) {
 		nicstar_read_eprom(card->membase, NICSTAR_EPROM_MAC_ADDR_OFFSET,
 				   card->atmdev->esi, 6);
 		if (memcmp(card->atmdev->esi, "\x00\x00\x00\x00\x00\x00", 6) ==
@@ -2802,29 +2801,6 @@ static void ns_poll(unsigned long arg)
 	PRINTK("nicstar: Leaving ns_poll().\n");
 }
 
-static int ns_parse_mac(char *mac, unsigned char *esi)
-{
-	int i, j;
-	short byte1, byte0;
-
-	if (mac == NULL || esi == NULL)
-		return -1;
-	j = 0;
-	for (i = 0; i < 6; i++) {
-		if ((byte1 = hex_to_bin(mac[j++])) < 0)
-			return -1;
-		if ((byte0 = hex_to_bin(mac[j++])) < 0)
-			return -1;
-		esi[i] = (unsigned char)(byte1 * 16 + byte0);
-		if (i < 5) {
-			if (mac[j++] != ':')
-				return -1;
-		}
-	}
-	return 0;
-}
-
-
 static void ns_phy_put(struct atm_dev *dev, unsigned char value,
 		       unsigned long addr)
 {
-- 
1.8.4.rc3
