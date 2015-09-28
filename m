From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 6/6] net/ethernet: make apple/macmace.c driver explicitly non-modular
Date: Mon, 28 Sep 2015 15:51:30 -0400
Message-ID: <1443469890-19485-7-git-send-email-paul.gortmaker@windriver.com>
References: <1443469890-19485-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-m68k@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:40476 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752017AbbI1TwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 15:52:04 -0400
In-Reply-To: <1443469890-19485-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Kconfig for this option is currently:

config MACMACE
        bool "Macintosh (AV) onboard MACE ethernet"

...meaning that it currently is not being built as a module by anyone.
Lets remove the modular code that is essentially orphaned, so when
reading the driver there should be no doubt it is builtin-only.

Since module_init translates to device_initcall in the non-modular
case, the init ordering remains unchanged with this commit.

We also delete the MODULE_LICENSE tag etc. since all that information
is already contained at the top of the file in the comments.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: linux-m68k@lists.linux-m68k.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/ethernet/apple/macmace.c | 38 +++---------------------------------
 1 file changed, 3 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/apple/macmace.c b/drivers/net/ethernet/apple/macmace.c
index 89914ca17a49..1f78bc1d04ce 100644
--- a/drivers/net/ethernet/apple/macmace.c
+++ b/drivers/net/ethernet/apple/macmace.c
@@ -21,7 +21,7 @@
 
 
 #include <linux/kernel.h>
-#include <linux/module.h>
+#include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/delay.h>
@@ -739,50 +739,18 @@ static irqreturn_t mace_dma_intr(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-MODULE_LICENSE("GPL");
-MODULE_DESCRIPTION("Macintosh MACE ethernet driver");
-MODULE_ALIAS("platform:macmace");
-
-static int mac_mace_device_remove(struct platform_device *pdev)
-{
-	struct net_device *dev = platform_get_drvdata(pdev);
-	struct mace_data *mp = netdev_priv(dev);
-
-	unregister_netdev(dev);
-
-	free_irq(dev->irq, dev);
-	free_irq(IRQ_MAC_MACE_DMA, dev);
-
-	dma_free_coherent(mp->device, N_RX_RING * MACE_BUFF_SIZE,
-	                  mp->rx_ring, mp->rx_ring_phys);
-	dma_free_coherent(mp->device, N_TX_RING * MACE_BUFF_SIZE,
-	                  mp->tx_ring, mp->tx_ring_phys);
-
-	free_netdev(dev);
-
-	return 0;
-}
-
 static struct platform_driver mac_mace_driver = {
 	.probe  = mace_probe,
-	.remove = mac_mace_device_remove,
 	.driver	= {
 		.name	= mac_mace_string,
 	},
 };
 
-static int __init mac_mace_init_module(void)
+static int __init mac_mace_init(void)
 {
 	if (!MACH_IS_MAC)
 		return -ENODEV;
 
 	return platform_driver_register(&mac_mace_driver);
 }
-
-static void __exit mac_mace_cleanup_module(void)
-{
-	platform_driver_unregister(&mac_mace_driver);
-}
-
-module_init(mac_mace_init_module);
-module_exit(mac_mace_cleanup_module);
+device_initcall(mac_mace_init);
-- 
2.6.0.rc3
