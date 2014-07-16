From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v2 2/2] net: davinci_mdio: allow to create phys from dt
Date: Wed, 16 Jul 2014 15:13:03 +0300
Message-ID: <1405512783-20307-3-git-send-email-grygorii.strashko@ti.com>
References: <1405512783-20307-1-git-send-email-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <prabhakar.csengg@gmail.com>, Sekhar Nori <nsekhar@ti.com>,
	Rob Herring <robh+dt@kernel.org>,
	<linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
	<davinci-linux-open-source@linux.davincidsp.com>,
	<mugunthanvnm@ti.com>, Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	<santosh.shilimkar@ti.com>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405512783-20307-1-git-send-email-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch allows to create PHYs from DT in case
if they are explicitly defined. The of_mdiobus_register() is
used for such purposes.

For backward compatibility, call  of_mdiobus_register() only in case
if at least one PHY's child is defined in DT, otherwise rollback to
mdiobus_register().

Reviewed-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
Acked-by: Mugunthan V N <mugunthanvnm@ti.com>
Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
Hi Santosh,

I haven't changed style for long-comments, because Networking subsystem
requires first line of comment not to be empty:
WARNING:NETWORKING_BLOCK_COMMENT_STYLE: networking block comments don't use an empty /* line, use /* Comment...

 drivers/net/ethernet/ti/davinci_mdio.c |   21 +++++++++++++++++++--
 1 file changed, 19 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index 735dc53..2791f6f 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -38,6 +38,7 @@
 #include <linux/davinci_emac.h>
 #include <linux/of.h>
 #include <linux/of_device.h>
+#include <linux/of_mdio.h>
 #include <linux/pinctrl/consumer.h>
 
 /*
@@ -95,6 +96,10 @@ struct davinci_mdio_data {
 	struct mii_bus	*bus;
 	bool		suspended;
 	unsigned long	access_time; /* jiffies */
+	/* Indicates that driver shouldn't modify phy_mask in case
+	 * if MDIO bus is registered from DT.
+	 */
+	bool		skip_scan;
 };
 
 static void __davinci_mdio_reset(struct davinci_mdio_data *data)
@@ -144,6 +149,9 @@ static int davinci_mdio_reset(struct mii_bus *bus)
 	dev_info(data->dev, "davinci mdio revision %d.%d\n",
 		 (ver >> 8) & 0xff, ver & 0xff);
 
+	if (data->skip_scan)
+		return 0;
+
 	/* get phy mask from the alive register */
 	phy_mask = __raw_readl(&data->regs->alive);
 	if (phy_mask) {
@@ -369,8 +377,17 @@ static int davinci_mdio_probe(struct platform_device *pdev)
 		goto bail_out;
 	}
 
-	/* register the mii bus */
-	ret = mdiobus_register(data->bus);
+	/* register the mii bus
+	 * Create PHYs from DT only in case if PHY child nodes are explicitly
+	 * defined to support backward compatibility with DTs which assume that
+	 * Davinci MDIO will always scan the bus for PHYs detection.
+	 */
+	if (dev->of_node && of_get_child_count(dev->of_node)) {
+		data->skip_scan = true;
+		ret = of_mdiobus_register(data->bus, dev->of_node);
+	} else {
+		ret = mdiobus_register(data->bus);
+	}
 	if (ret)
 		goto bail_out;
 
-- 
1.7.9.5
