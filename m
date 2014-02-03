From: Max Filippov <jcmvbkbc@gmail.com>
Subject: [PATCH v3 2/2] net: ethoc: set up MII management bus clock
Date: Tue,  4 Feb 2014 03:33:10 +0400
Message-ID: <1391470390-31569-3-git-send-email-jcmvbkbc@gmail.com>
References: <1391470390-31569-1-git-send-email-jcmvbkbc@gmail.com>
Cc: Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@cadence.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Max Filippov <jcmvbkbc@gmail.com>
To: linux-xtensa@linux-xtensa.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:43394 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754362AbaBCXdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Feb 2014 18:33:45 -0500
Received: by mail-la0-f54.google.com with SMTP id y1so6022109lam.13
        for <netdev@vger.kernel.org>; Mon, 03 Feb 2014 15:33:44 -0800 (PST)
In-Reply-To: <1391470390-31569-1-git-send-email-jcmvbkbc@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MII management bus clock is derived from the MAC clock by dividing it by
MIIMODER register CLKDIV field value. This value may need to be set up
in case it is undefined or its default value is too high (and
communication with PHY is too slow) or too low (and communication with
PHY is impossible). The value of CLKDIV is not specified directly, but
is derived from the MAC clock for the default MII management bus frequency
of 2.5MHz. The MAC clock may be specified in the platform data, or in
the 'clocks' device tree attribute.

Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>
---
Changes v2->v3:
- drop clock-frequency property support.

Changes v1->v2:
- drop MDIO bus frequency configurability, always configure for standard
  2.5MHz;
- allow using common clock framework to provide ethoc clock.

 drivers/net/ethernet/ethoc.c | 32 ++++++++++++++++++++++++++++++--
 include/net/ethoc.h          |  1 +
 2 files changed, 31 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 6aef639..41ca15d 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -13,6 +13,7 @@
 
 #include <linux/dma-mapping.h>
 #include <linux/etherdevice.h>
+#include <linux/clk.h>
 #include <linux/crc32.h>
 #include <linux/interrupt.h>
 #include <linux/io.h>
@@ -219,6 +220,7 @@ struct ethoc {
 
 	struct phy_device *phy;
 	struct mii_bus *mdio;
+	struct clk *clk;
 	s8 phy_id;
 };
 
@@ -1021,6 +1023,8 @@ static int ethoc_probe(struct platform_device *pdev)
 	int num_bd;
 	int ret = 0;
 	bool random_mac = false;
+	struct ethoc_platform_data *pdata = dev_get_platdata(&pdev->dev);
+	u32 eth_clkfreq = pdata ? pdata->eth_clkfreq : 0;
 
 	/* allocate networking device */
 	netdev = alloc_etherdev(sizeof(struct ethoc));
@@ -1135,8 +1139,7 @@ static int ethoc_probe(struct platform_device *pdev)
 	}
 
 	/* Allow the platform setup code to pass in a MAC address. */
-	if (dev_get_platdata(&pdev->dev)) {
-		struct ethoc_platform_data *pdata = dev_get_platdata(&pdev->dev);
+	if (pdata) {
 		memcpy(netdev->dev_addr, pdata->hwaddr, IFHWADDRLEN);
 		priv->phy_id = pdata->phy_id;
 	} else {
@@ -1174,6 +1177,27 @@ static int ethoc_probe(struct platform_device *pdev)
 	if (random_mac)
 		netdev->addr_assign_type = NET_ADDR_RANDOM;
 
+	/* Allow the platform setup code to adjust MII management bus clock. */
+	if (!eth_clkfreq) {
+		struct clk *clk = devm_clk_get(&pdev->dev, NULL);
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
@@ -1239,6 +1263,8 @@ free_mdio:
 	kfree(priv->mdio->irq);
 	mdiobus_free(priv->mdio);
 free:
+	if (priv->clk)
+		clk_disable_unprepare(priv->clk);
 	free_netdev(netdev);
 out:
 	return ret;
@@ -1263,6 +1289,8 @@ static int ethoc_remove(struct platform_device *pdev)
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
