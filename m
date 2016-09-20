From: Joel Stanley <joel@jms.id.au>
Subject: [PATCH net-next 7/7] net/faraday: Configure old MDIO interface on Aspeed SoCs
Date: Tue, 20 Sep 2016 16:00:07 +0930
Message-ID: <20160920063007.24291-8-joel@jms.id.au>
References: <20160920063007.24291-1-joel@jms.id.au>
Cc: gwshan@linux.vnet.ibm.com, andrew@lunn.ch, andrew@aj.id.au,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        benh@kernel.crashing.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:36830 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754020AbcITGbP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 02:31:15 -0400
In-Reply-To: <20160920063007.24291-1-joel@jms.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Aspeed SoCs have a new MDIO interface as an option in the G4 and G5
SoCs. The old one is still available, so select it in order to remain
compatible with the ftgmac100 driver.

Signed-off-by: Joel Stanley <joel@jms.id.au>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 9 +++++++++
 drivers/net/ethernet/faraday/ftgmac100.h | 5 +++++
 2 files changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 5466df028381..54c6ba3632a3 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1257,12 +1257,21 @@ static int ftgmac100_setup_mdio(struct net_device *netdev)
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
index d07b6ea5d1b5..a7ce0ac8858a 100644
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
