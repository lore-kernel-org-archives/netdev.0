From: Joel Stanley <joel@jms.id.au>
Subject: [PATCH net-next v2 5/6] net/faraday: Configure old MDIO interface on Aspeed SoCs
Date: Thu, 22 Sep 2016 08:35:02 +0930
Message-ID: <20160921230503.23309-6-joel@jms.id.au>
References: <20160921230503.23309-1-joel@jms.id.au>
Cc: clg@kaod.org, gwshan@linux.vnet.ibm.com, andrew@lunn.ch,
        andrew@aj.id.au, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, benh@kernel.crashing.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160921230503.23309-1-joel@jms.id.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Aspeed SoCs have a new MDIO interface as an option in the G4 and G5
SoCs. The old one is still available, so select it in order to remain
compatible with the ftgmac100 driver.

Signed-off-by: Joel Stanley <joel@jms.id.au>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 9 +++++++++
 drivers/net/ethernet/faraday/ftgmac100.h | 5 +++++
 2 files changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 189373743ddf..e3653b14008a 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1252,12 +1252,21 @@ static int ftgmac100_setup_mdio(struct net_device *netdev)
 	struct ftgmac100 *priv = netdev_priv(netdev);
 	struct platform_device *pdev = to_platform_device(priv->dev);
 	int i, err = 0;
+	u32 reg;
 
 	/* initialize mdio bus */
 	priv->mii_bus = mdiobus_alloc();
 	if (!priv->mii_bus)
 		return -EIO;
 
+	if (of_machine_is_compatible("aspeed,ast2400") ||
+	    of_machine_is_compatible("aspeed,ast2500")) {
+		/* This driver supports the old MDIO interface */
+		reg = ioread32(priv->base + FTGMAC100_OFFSET_REVR);
+		reg &= ~FTGMAC100_REVR_NEW_MDIO_INTERFACE;
+		iowrite32(reg, priv->base + FTGMAC100_OFFSET_REVR);
+	};
+
 	priv->mii_bus->name = "ftgmac100_mdio";
 	snprintf(priv->mii_bus->id, MII_BUS_ID_SIZE, "%s-%d",
 		 pdev->name, pdev->id);
diff --git a/drivers/net/ethernet/faraday/ftgmac100.h b/drivers/net/ethernet/faraday/ftgmac100.h
index c258586ce4a4..8a377ab1d127 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.h
+++ b/drivers/net/ethernet/faraday/ftgmac100.h
@@ -134,6 +134,11 @@
 #define FTGMAC100_DMAFIFOS_TXDMA_REQ		(1 << 31)
 
 /*
+ * Feature Register
+ */
+#define FTGMAC100_REVR_NEW_MDIO_INTERFACE	BIT(31)
+
+/*
  * Receive buffer size register
  */
 #define FTGMAC100_RBSR_SIZE(x)		((x) & 0x3fff)
-- 
2.9.3
