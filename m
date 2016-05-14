From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH -next v2 4/4] net: w5100-spi: add support to specify MAC address by device tree
Date: Sat, 14 May 2016 14:55:50 +0900
Message-ID: <1463205350-7089-5-git-send-email-akinobu.mita@gmail.com>
References: <1463205350-7089-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	Mike Sinkovsky <msink@permonline.ru>,
	"David S . Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:35008 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751735AbcENF4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 01:56:40 -0400
Received: by mail-pa0-f65.google.com with SMTP id zy2so11786958pac.2
        for <netdev@vger.kernel.org>; Fri, 13 May 2016 22:56:40 -0700 (PDT)
In-Reply-To: <1463205350-7089-1-git-send-email-akinobu.mita@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support to specify the MAC address by 'mac-address' or
'local-mac-address' properties in the device tree.  These are common
properties for the Ethernet controller.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Mike Sinkovsky <msink@permonline.ru>
Cc: David S. Miller <davem@davemloft.net>
---
* No changes from v1

 drivers/net/ethernet/wiznet/w5100-spi.c | 4 +++-
 drivers/net/ethernet/wiznet/w5100.c     | 5 +++--
 drivers/net/ethernet/wiznet/w5100.h     | 3 ++-
 3 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/wiznet/w5100-spi.c b/drivers/net/ethernet/wiznet/w5100-spi.c
index b868e45..93a2d3c 100644
--- a/drivers/net/ethernet/wiznet/w5100-spi.c
+++ b/drivers/net/ethernet/wiznet/w5100-spi.c
@@ -15,6 +15,7 @@
 #include <linux/module.h>
 #include <linux/delay.h>
 #include <linux/netdevice.h>
+#include <linux/of_net.h>
 #include <linux/spi/spi.h>
 
 #include "w5100.h"
@@ -414,6 +415,7 @@ static int w5100_spi_probe(struct spi_device *spi)
 	const struct spi_device_id *id = spi_get_device_id(spi);
 	const struct w5100_ops *ops;
 	int priv_size;
+	const void *mac = of_get_mac_address(spi->dev.of_node);
 
 	switch (id->driver_data) {
 	case W5100:
@@ -432,7 +434,7 @@ static int w5100_spi_probe(struct spi_device *spi)
 		return -EINVAL;
 	}
 
-	return w5100_probe(&spi->dev, ops, priv_size, NULL, spi->irq, -EINVAL);
+	return w5100_probe(&spi->dev, ops, priv_size, mac, spi->irq, -EINVAL);
 }
 
 static int w5100_spi_remove(struct spi_device *spi)
diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index 43fdf88..e9ae7e6 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -1052,7 +1052,7 @@ static const struct net_device_ops w5100_netdev_ops = {
 static int w5100_mmio_probe(struct platform_device *pdev)
 {
 	struct wiznet_platform_data *data = dev_get_platdata(&pdev->dev);
-	u8 *mac_addr = NULL;
+	const void *mac_addr = NULL;
 	struct resource *mem;
 	const struct w5100_ops *ops;
 	int irq;
@@ -1087,7 +1087,8 @@ void *w5100_ops_priv(const struct net_device *ndev)
 EXPORT_SYMBOL_GPL(w5100_ops_priv);
 
 int w5100_probe(struct device *dev, const struct w5100_ops *ops,
-		int sizeof_ops_priv, u8 *mac_addr, int irq, int link_gpio)
+		int sizeof_ops_priv, const void *mac_addr, int irq,
+		int link_gpio)
 {
 	struct w5100_priv *priv;
 	struct net_device *ndev;
diff --git a/drivers/net/ethernet/wiznet/w5100.h b/drivers/net/ethernet/wiznet/w5100.h
index f8a16fa..17983a3 100644
--- a/drivers/net/ethernet/wiznet/w5100.h
+++ b/drivers/net/ethernet/wiznet/w5100.h
@@ -30,7 +30,8 @@ struct w5100_ops {
 void *w5100_ops_priv(const struct net_device *ndev);
 
 int w5100_probe(struct device *dev, const struct w5100_ops *ops,
-		int sizeof_ops_priv, u8 *mac_addr, int irq, int link_gpio);
+		int sizeof_ops_priv, const void *mac_addr, int irq,
+		int link_gpio);
 int w5100_remove(struct device *dev);
 
 extern const struct dev_pm_ops w5100_pm_ops;
-- 
2.7.4
