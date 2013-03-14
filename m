From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 1/4 v2] net: mvmdio: allow platform device style registration
Date: Thu, 14 Mar 2013 19:11:23 +0100
Message-ID: <1363284683-9953-1-git-send-email-florian@openwrt.org>
References: <1363284515-9865-1-git-send-email-florian@openwrt.org>
Cc: Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	Rob Landley <rob@landley.net>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Russell King <linux@arm.linux.org.uk>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Florian Fainelli <florian@openwrt.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	devicetree-discuss@lists.ozlabs.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:39530 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932979Ab3CNSO6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Mar 2013 14:14:58 -0400
In-Reply-To: <1363284515-9865-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the mvmdio driver not to use device tree
helper functions such as of_mdiobus_register() and of_iomap() so we can
instantiate this driver using a classic platform_device approach. Use
the device manager helper to ioremap() the base register cookie so we
get automatic freeing upon error and removal. This change is harmless
for Device Tree platforms because they will get the driver be registered
the same way as it was before.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
Changes since v1:
- use device managed helpers to fix an ioremap leak in remove function
- remove the use of Device Tree specific helpers to allow platform-style
  registration

 drivers/net/ethernet/marvell/mvmdio.c |   18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvmdio.c b/drivers/net/ethernet/marvell/mvmdio.c
index 77b7c80..8a182f1 100644
--- a/drivers/net/ethernet/marvell/mvmdio.c
+++ b/drivers/net/ethernet/marvell/mvmdio.c
@@ -24,10 +24,9 @@
 #include <linux/module.h>
 #include <linux/mutex.h>
 #include <linux/phy.h>
-#include <linux/of_address.h>
-#include <linux/of_mdio.h>
 #include <linux/platform_device.h>
 #include <linux/delay.h>
+#include <linux/io.h>
 
 #define MVMDIO_SMI_DATA_SHIFT              0
 #define MVMDIO_SMI_PHY_ADDR_SHIFT          16
@@ -143,11 +142,17 @@ static int orion_mdio_reset(struct mii_bus *bus)
 
 static int orion_mdio_probe(struct platform_device *pdev)
 {
-	struct device_node *np = pdev->dev.of_node;
+	struct resource *r;
 	struct mii_bus *bus;
 	struct orion_mdio_dev *dev;
 	int i, ret;
 
+	r = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!r) {
+		dev_err(&pdev->dev, "No SMI register address given\n");
+		return -ENODEV;
+	}
+
 	bus = mdiobus_alloc_size(sizeof(struct orion_mdio_dev));
 	if (!bus) {
 		dev_err(&pdev->dev, "Cannot allocate MDIO bus\n");
@@ -172,9 +177,9 @@ static int orion_mdio_probe(struct platform_device *pdev)
 		bus->irq[i] = PHY_POLL;
 
 	dev = bus->priv;
-	dev->smireg = of_iomap(pdev->dev.of_node, 0);
+	dev->smireg = devm_ioremap(&pdev->dev, r->start, resource_size(r));
 	if (!dev->smireg) {
-		dev_err(&pdev->dev, "No SMI register address given in DT\n");
+		dev_err(&pdev->dev, "Unable to remap SMI register\n");
 		kfree(bus->irq);
 		mdiobus_free(bus);
 		return -ENODEV;
@@ -182,10 +187,9 @@ static int orion_mdio_probe(struct platform_device *pdev)
 
 	mutex_init(&dev->lock);
 
-	ret = of_mdiobus_register(bus, np);
+	ret = mdiobus_register(bus);
 	if (ret < 0) {
 		dev_err(&pdev->dev, "Cannot register MDIO bus (%d)\n", ret);
-		iounmap(dev->smireg);
 		kfree(bus->irq);
 		mdiobus_free(bus);
 		return ret;
-- 
1.7.10.4
