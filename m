From: Max Filippov <jcmvbkbc@gmail.com>
Subject: [PATCH v2 3/4] net: ethoc: set up MII management bus clock
Date: Wed, 29 Jan 2014 10:00:17 +0400
Message-ID: <1390975218-13863-4-git-send-email-jcmvbkbc@gmail.com>
References: <1390975218-13863-1-git-send-email-jcmvbkbc@gmail.com>
Cc: Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@cadence.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Max Filippov <jcmvbkbc@gmail.com>
To: linux-xtensa@linux-xtensa.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1390975218-13863-1-git-send-email-jcmvbkbc@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

MII management bus clock is derived from the MAC clock by dividing it by
MIIMODER register CLKDIV field value. This value may need to be set up
in case it is undefined or its default value is too high (and
communication with PHY is too slow) or too low (and communication with
PHY is impossible). The value of CLKDIV is not specified directly, but
is derived from the MAC clock for the default MII management bus frequency
of 2.5MHz. The MAC clock may be specified in the platform data, or as
either 'clock-frequency' or 'clocks' device tree attribute.

Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>
---
Changes v1->v2:
- drop MDIO bus frequency configurability, always configure for standard
  2.5MHz;
- allow using common clock framework to provide ethoc clock.

 drivers/net/ethernet/ethoc.c | 37 +++++++++++++++++++++++++++++++++++--
 include/net/ethoc.h          |  1 +
 2 files changed, 36 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 5643b2d..5854d41 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -13,6 +13,7 @@
 
 #include <linux/dma-mapping.h>
 #include <linux/etherdevice.h>
+#include <linux/clk.h>
 #include <linux/crc32.h>
 #include <linux/interrupt.h>
 #include <linux/io.h>
@@ -216,6 +217,7 @@ struct ethoc {
 
 	struct phy_device *phy;
 	struct mii_bus *mdio;
+	struct clk *clk;
 	s8 phy_id;
 };
 
@@ -925,6 +927,8 @@ static int ethoc_probe(struct platform_device *pdev)
 	int num_bd;
 	int ret = 0;
 	bool random_mac = false;
+	u32 eth_clkfreq = 0;
+	struct ethoc_platform_data *pdata = dev_get_platdata(&pdev->dev);
 
 	/* allocate networking device */
 	netdev = alloc_etherdev(sizeof(struct ethoc));
@@ -1038,8 +1042,7 @@ static int ethoc_probe(struct platform_device *pdev)
 	}
 
 	/* Allow the platform setup code to pass in a MAC address. */
-	if (dev_get_platdata(&pdev->dev)) {
-		struct ethoc_platform_data *pdata = dev_get_platdata(&pdev->dev);
+	if (pdata) {
 		memcpy(netdev->dev_addr, pdata->hwaddr, IFHWADDRLEN);
 		priv->phy_id = pdata->phy_id;
 	} else {
@@ -1077,6 +1080,32 @@ static int ethoc_probe(struct platform_device *pdev)
 	if (random_mac)
 		netdev->addr_assign_type = NET_ADDR_RANDOM;
 
+	/* Allow the platform setup code to adjust MII management bus clock. */
+	if (pdata)
+		eth_clkfreq = pdata->eth_clkfreq;
+	else
+		of_property_read_u32(pdev->dev.of_node,
+				     "clock-frequency", &eth_clkfreq);
+	if (!eth_clkfreq) {
+		struct clk *clk = clk_get(&pdev->dev, NULL);
+
+		if (!IS_ERR(clk)) {
+			priv->clk = clk;
+			clk_prepare_enable(clk);
+			eth_clkfreq = clk_get_rate(clk);
+		}
+	}
+	if (eth_clkfreq) {
+		u32 clkdiv = MIIMODER_CLKDIV(eth_clkfreq / 2500000 + 1);
+
+		if (!clkdiv)
+			clkdiv = 2;
+		dev_dbg(&pdev->dev, "setting MII clkdiv to %u\n", clkdiv);
+		ethoc_write(priv, MIIMODER,
+			    (ethoc_read(priv, MIIMODER) & MIIMODER_NOPRE) |
+			    clkdiv);
+	}
+
 	/* register MII bus */
 	priv->mdio = mdiobus_alloc();
 	if (!priv->mdio) {
@@ -1141,6 +1170,8 @@ free_mdio:
 	kfree(priv->mdio->irq);
 	mdiobus_free(priv->mdio);
 free:
+	if (priv->clk)
+		clk_disable_unprepare(priv->clk);
 	free_netdev(netdev);
 out:
 	return ret;
@@ -1165,6 +1196,8 @@ static int ethoc_remove(struct platform_device *pdev)
 			kfree(priv->mdio->irq);
 			mdiobus_free(priv->mdio);
 		}
+		if (priv->clk)
+			clk_disable_unprepare(priv->clk);
 		unregister_netdev(netdev);
 		free_netdev(netdev);
 	}
diff --git a/include/net/ethoc.h b/include/net/ethoc.h
index 96f3789..2a2d6bb 100644
--- a/include/net/ethoc.h
+++ b/include/net/ethoc.h
@@ -16,6 +16,7 @@
 struct ethoc_platform_data {
 	u8 hwaddr[IFHWADDRLEN];
 	s8 phy_id;
+	u32 eth_clkfreq;
 };
 
 #endif /* !LINUX_NET_ETHOC_H */
-- 
1.8.1.4
