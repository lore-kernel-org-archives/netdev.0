From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH 1/5] net: mac8390: Allow modular build
Date: Tue, 29 Sep 2015 10:24:02 +0200
Message-ID: <1443515046-13968-2-git-send-email-geert@linux-m68k.org>
References: <1443515046-13968-1-git-send-email-geert@linux-m68k.org>
Cc: Finn Thain <fthain@telegraphics.com.au>,
	Joshua Thompson <funaho@jurai.org>,
	Philip Blundell <philb@gnu.org>, netdev@vger.kernel.org,
	linux-m68k@lists.linux-m68k.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: "David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from baptiste.telenet-ops.be ([195.130.132.51]:56004 "EHLO
	baptiste.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933035AbbI2IYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 04:24:10 -0400
In-Reply-To: <1443515046-13968-1-git-send-email-geert@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The modular driver supports only one card, just like the built-in
driver.

Note that this limitation is a problem which affects all Nubus card
drivers, because they have to do all their own bus matching, because
Nubus still lacks the necessary driver model support.

Suggested-by: Finn Thain <fthain@telegraphics.com.au>
Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/ethernet/8390/Kconfig   |  2 +-
 drivers/net/ethernet/8390/mac8390.c | 32 ++++++++++----------------------
 2 files changed, 11 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/8390/Kconfig b/drivers/net/ethernet/8390/Kconfig
index edf72258ab1ddabe..29c3075bfb052f1d 100644
--- a/drivers/net/ethernet/8390/Kconfig
+++ b/drivers/net/ethernet/8390/Kconfig
@@ -64,7 +64,7 @@ config ARM_ETHERH
 	  should say Y to this option if you wish to use it with Linux.
 
 config MAC8390
-	bool "Macintosh NS 8390 based ethernet cards"
+	tristate "Macintosh NS 8390 based ethernet cards"
 	depends on MAC
 	select CRC32
 	---help---
diff --git a/drivers/net/ethernet/8390/mac8390.c b/drivers/net/ethernet/8390/mac8390.c
index 65cf60f6718c52fa..b9283901136e974a 100644
--- a/drivers/net/ethernet/8390/mac8390.c
+++ b/drivers/net/ethernet/8390/mac8390.c
@@ -454,34 +454,22 @@ MODULE_AUTHOR("David Huggins-Daines <dhd@debian.org> and others");
 MODULE_DESCRIPTION("Macintosh NS8390-based Nubus Ethernet driver");
 MODULE_LICENSE("GPL");
 
-/* overkill, of course */
-static struct net_device *dev_mac8390[15];
-int init_module(void)
+static struct net_device *dev_mac8390;
+
+int __init init_module(void)
 {
-	int i;
-	for (i = 0; i < 15; i++) {
-		struct net_device *dev = mac8390_probe(-1);
-		if (IS_ERR(dev))
-			break;
-		dev_mac890[i] = dev;
-	}
-	if (!i) {
-		pr_notice("No useable cards found, driver NOT installed.\n");
-		return -ENODEV;
+	dev_mac8390 = mac8390_probe(-1);
+	if (IS_ERR(dev_mac8390)) {
+		pr_warn("mac8390: No card found\n");
+		return PTR_ERR(dev_mac8390);
 	}
 	return 0;
 }
 
-void cleanup_module(void)
+void __exit cleanup_module(void)
 {
-	int i;
-	for (i = 0; i < 15; i++) {
-		struct net_device *dev = dev_mac890[i];
-		if (dev) {
-			unregister_netdev(dev);
-			free_netdev(dev);
-		}
-	}
+	unregister_netdev(dev_mac8390);
+	free_netdev(dev_mac8390);
 }
 
 #endif /* MODULE */
-- 
1.9.1
