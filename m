From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 4/4] fsl_pq_mdio: Fix iomem unmapping for non-eTSEC2.0
 controllers
Date: Wed, 30 Dec 2009 21:23:34 +0300
Message-ID: <20091230182334.GD13162@oksana.dev.rtsoft.ru>
References: <20091230182146.GA4515@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Andy Fleming <afleming@freescale.com>,
	Li Yang <leoli@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.dev.rtsoft.ru ([213.79.90.226]:43765 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752796AbZL3SXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2009 13:23:35 -0500
Content-Disposition: inline
In-Reply-To: <20091230182146.GA4515@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We use a rather complicated logic to support eTSEC and eTSEC2.0
registers maps in a single driver. Currently, the code tries to
unmap 'regs', but for non-eTSEC2.0 controllers 'regs' doesn't
point to a mapping start, and this might cause badness on probe
failure or module removal:

 Freescale PowerQUICC MII Bus: probed
 Trying to vfree() nonexistent vm area (e107f000)
 ------------[ cut here ]------------
 Badness at c00a7754 [verbose debug info unavailable]
 NIP: c00a7754 LR: c00a7754 CTR: c02231ec
 [...]
 NIP [c00a7754] __vunmap+0xec/0xf4
 LR [c00a7754] __vunmap+0xec/0xf4
 Call Trace:
 [df827e50] [c00a7754] __vunmap+0xec/0xf4 (unreliable)
 [df827e70] [c001519c] iounmap+0x44/0x54
 [df827e80] [c028b924] fsl_pq_mdio_probe+0x1cc/0x2fc
 [df827eb0] [c02fb9b4] of_platform_device_probe+0x5c/0x84
 [df827ed0] [c0229928] really_probe+0x78/0x1a8
 [df827ef0] [c0229b20] __driver_attach+0xa4/0xa8

Fix this by introducing a proper priv structure (finally!), which
now holds 'regs' and 'map' fields separately.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/fsl_pq_mdio.c |   30 +++++++++++++++++++++++-------
 1 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/drivers/net/fsl_pq_mdio.c b/drivers/net/fsl_pq_mdio.c
index 25fabb3..d5160ed 100644
--- a/drivers/net/fsl_pq_mdio.c
+++ b/drivers/net/fsl_pq_mdio.c
@@ -46,6 +46,11 @@
 #include "gianfar.h"
 #include "fsl_pq_mdio.h"
 
+struct fsl_pq_mdio_priv {
+	void __iomem *map;
+	struct fsl_pq_mdio __iomem *regs;
+};
+
 /*
  * Write value to the PHY at mii_id at register regnum,
  * on the bus attached to the local interface, which may be different from the
@@ -105,7 +110,9 @@ int fsl_pq_local_mdio_read(struct fsl_pq_mdio __iomem *regs,
 
 static struct fsl_pq_mdio __iomem *fsl_pq_mdio_get_regs(struct mii_bus *bus)
 {
-	return (void __iomem __force *)bus->priv;
+	struct fsl_pq_mdio_priv *priv = bus->priv;
+
+	return priv->regs;
 }
 
 /*
@@ -266,6 +273,7 @@ static int fsl_pq_mdio_probe(struct of_device *ofdev,
 {
 	struct device_node *np = ofdev->node;
 	struct device_node *tbi;
+	struct fsl_pq_mdio_priv *priv;
 	struct fsl_pq_mdio __iomem *regs = NULL;
 	void __iomem *map;
 	u32 __iomem *tbipa;
@@ -274,14 +282,19 @@ static int fsl_pq_mdio_probe(struct of_device *ofdev,
 	u64 addr = 0, size = 0;
 	int err = 0;
 
+	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
+	if (!priv)
+		return -ENOMEM;
+
 	new_bus = mdiobus_alloc();
 	if (NULL == new_bus)
-		return -ENOMEM;
+		goto err_free_priv;
 
 	new_bus->name = "Freescale PowerQUICC MII Bus",
 	new_bus->read = &fsl_pq_mdio_read,
 	new_bus->write = &fsl_pq_mdio_write,
 	new_bus->reset = &fsl_pq_mdio_reset,
+	new_bus->priv = priv;
 	fsl_pq_mdio_bus_name(new_bus->id, np);
 
 	/* Set the PHY base address */
@@ -291,6 +304,7 @@ static int fsl_pq_mdio_probe(struct of_device *ofdev,
 		err = -ENOMEM;
 		goto err_free_bus;
 	}
+	priv->map = map;
 
 	if (of_device_is_compatible(np, "fsl,gianfar-mdio") ||
 			of_device_is_compatible(np, "fsl,gianfar-tbi") ||
@@ -298,8 +312,7 @@ static int fsl_pq_mdio_probe(struct of_device *ofdev,
 			of_device_is_compatible(np, "ucc_geth_phy"))
 		map -= offsetof(struct fsl_pq_mdio, miimcfg);
 	regs = map;
-
-	new_bus->priv = (void __force *)regs;
+	priv->regs = regs;
 
 	new_bus->irq = kcalloc(PHY_MAX_ADDR, sizeof(int), GFP_KERNEL);
 
@@ -392,10 +405,11 @@ static int fsl_pq_mdio_probe(struct of_device *ofdev,
 err_free_irqs:
 	kfree(new_bus->irq);
 err_unmap_regs:
-	iounmap(regs);
+	iounmap(priv->map);
 err_free_bus:
 	kfree(new_bus);
-
+err_free_priv:
+	kfree(priv);
 	return err;
 }
 
@@ -404,14 +418,16 @@ static int fsl_pq_mdio_remove(struct of_device *ofdev)
 {
 	struct device *device = &ofdev->dev;
 	struct mii_bus *bus = dev_get_drvdata(device);
+	struct fsl_pq_mdio_priv *priv = bus->priv;
 
 	mdiobus_unregister(bus);
 
 	dev_set_drvdata(device, NULL);
 
-	iounmap(fsl_pq_mdio_get_regs(bus));
+	iounmap(priv->map);
 	bus->priv = NULL;
 	mdiobus_free(bus);
+	kfree(priv);
 
 	return 0;
 }
-- 
1.6.5.7
