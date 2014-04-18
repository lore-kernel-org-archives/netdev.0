From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH] net: sxgbe: Added phy_found error path
Date: Fri, 18 Apr 2014 20:59:39 +0900
Message-ID: <000701cf5afd$ad1e65f0$075b31d0$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ks.giri@samsung.com, vipul.pandya@samsung.com
To: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
Content-language: ko
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch adds phy_found error path when there is no phy device 
and changes bus_name.

Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 drivers/net/ethernet/samsung/sxgbe/sxgbe_mdio.c |   14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/samsung/sxgbe/sxgbe_mdio.c b/drivers/net/ethernet/samsung/sxgbe/sxgbe_mdio.c
index 01af2cb..7dcaf1a 100644
--- a/drivers/net/ethernet/samsung/sxgbe/sxgbe_mdio.c
+++ b/drivers/net/ethernet/samsung/sxgbe/sxgbe_mdio.c
@@ -27,7 +27,7 @@
 #define SXGBE_SMA_PREAD_CMD	0x02 /* post read  increament address */
 #define SXGBE_SMA_READ_CMD	0x03 /* read command */
 #define SXGBE_SMA_SKIP_ADDRFRM	0x00040000 /* skip the address frame */
-#define SXGBE_MII_BUSY		0x00800000 /* mii busy */
+#define SXGBE_MII_BUSY		0x00400000 /* mii busy */
 
 static int sxgbe_mdio_busy_wait(void __iomem *ioaddr, unsigned int mii_data)
 {
@@ -147,6 +147,7 @@ int sxgbe_mdio_register(struct net_device *ndev)
 	struct sxgbe_mdio_bus_data *mdio_data = priv->plat->mdio_bus_data;
 	int err, phy_addr;
 	int *irqlist;
+	bool phy_found = false;
 	bool act;
 
 	/* allocate the new mdio bus */
@@ -162,7 +163,7 @@ int sxgbe_mdio_register(struct net_device *ndev)
 		irqlist = priv->mii_irq;
 
 	/* assign mii bus fields */
-	mdio_bus->name = "samsxgbe";
+	mdio_bus->name = "sxgbe";
 	mdio_bus->read = &sxgbe_mdio_read;
 	mdio_bus->write = &sxgbe_mdio_write;
 	snprintf(mdio_bus->id, MII_BUS_ID_SIZE, "%s-%x",
@@ -216,13 +217,22 @@ int sxgbe_mdio_register(struct net_device *ndev)
 			netdev_info(ndev, "PHY ID %08x at %d IRQ %s (%s)%s\n",
 				    phy->phy_id, phy_addr, irq_str,
 				    dev_name(&phy->dev), act ? " active" : "");
+			phy_found = true;
 		}
 	}
 
+	if (!phy_found) {
+		netdev_err(ndev, "PHY not found\n");
+		goto phyfound_err;
+	}
+
 	priv->mii = mdio_bus;
 
 	return 0;
 
+phyfound_err:
+	err = -ENODEV;
+	mdiobus_unregister(mdio_bus);
 mdiobus_err:
 	mdiobus_free(mdio_bus);
 	return err;
-- 
1.7.10.4
