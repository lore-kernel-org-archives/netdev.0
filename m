From: "Arce, Abraham" <x0066660@ti.com>
Subject: [PATCH] ks8851: suspend resume support
Date: Thu, 28 Oct 2010 23:57:20 -0500
Message-ID: <27F9C60D11D683428E133F85D2BB4A530468882D59@dlee03.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:46328 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751078Ab0J2E53 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 00:57:29 -0400
Received: from dlep35.itg.ti.com ([157.170.170.118])
	by arroyo.ext.ti.com (8.13.7/8.13.7) with ESMTP id o9T4vTq7008703
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 23:57:29 -0500
Received: from dlep26.itg.ti.com (localhost [127.0.0.1])
	by dlep35.itg.ti.com (8.13.7/8.13.7) with ESMTP id o9T4vPEx029966
	for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 23:57:26 -0500 (CDT)
Received: from dlee73.ent.ti.com (localhost [127.0.0.1])
	by dlep26.itg.ti.com (8.13.8/8.13.8) with ESMTP id o9T4vL2u011825
	for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 23:57:21 -0500 (CDT)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add suspend/resume support using default open/stop interface methods
to do hardware dependant operations.

On suspend, same low power state (soft power mode) will be kept, the
following blocks will be disabled:

 - Internal PLL Clock
 - Tx/Rx PHY
 - MAC
 - SPI Interface

Signed-off-by: Abraham Arce <x0066660@ti.com>
---
 drivers/net/ks8851.c |   33 +++++++++++++++++++++++++++++++++
 1 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ks8851.c b/drivers/net/ks8851.c
index 8a178bc..9d40e33 100644
--- a/drivers/net/ks8851.c
+++ b/drivers/net/ks8851.c
@@ -1570,6 +1570,37 @@ static int ks8851_read_selftest(struct ks8851_net *ks)
 
 /* driver bus management functions */
 
+#ifdef CONFIG_PM
+static int ks8851_suspend(struct spi_device *spi, pm_message_t state)
+{
+	struct ks8851_net *ks = dev_get_drvdata(&spi->dev);
+	struct net_device *dev = ks->netdev;
+
+	if (netif_running(dev)) {
+		netif_device_detach(dev);
+		ks8851_net_stop(dev);
+	}
+
+	return 0;
+}
+
+static int ks8851_resume(struct spi_device *spi)
+{
+	struct ks8851_net *ks = dev_get_drvdata(&spi->dev);
+	struct net_device *dev = ks->netdev;
+
+	if (netif_running(dev)) {
+		ks8851_net_open(dev);
+		netif_device_attach(dev);
+	}
+
+	return 0;
+}
+#else
+#define ks8851_suspend NULL
+#define ks8851_resume NULL
+#endif
+
 static int __devinit ks8851_probe(struct spi_device *spi)
 {
 	struct net_device *ndev;
@@ -1710,6 +1741,8 @@ static struct spi_driver ks8851_driver = {
 	},
 	.probe = ks8851_probe,
 	.remove = __devexit_p(ks8851_remove),
+	.suspend = ks8851_suspend,
+	.resume = ks8851_resume,
 };
 
 static int __init ks8851_init(void)
-- 
1.5.4.3

