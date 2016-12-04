From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/3] net: ethoc: Account for duplex changes
Date: Sun,  4 Dec 2016 12:40:28 -0800
Message-ID: <20161204204030.9853-2-f.fainelli@gmail.com>
References: <20161204204030.9853-1-f.fainelli@gmail.com>
Cc: tremyfr@gmail.com, tklauser@distanz.ch, davem@davemloft.net,
        thierry.reding@gmail.com, andrew@lunn.ch,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:33472 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751070AbcLDUkh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 15:40:37 -0500
Received: by mail-oi0-f66.google.com with SMTP id f201so34061558oib.0
        for <netdev@vger.kernel.org>; Sun, 04 Dec 2016 12:40:36 -0800 (PST)
In-Reply-To: <20161204204030.9853-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ethoc_mdio_poll() which is our PHYLIB adjust_link callback does nothing,
we should at least react to duplex changes and change MODER accordingly.
Speed changes is not a problem, since the OpenCores Ethernet core seems
to be reacting okay without us telling it.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/ethoc.c | 35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 6456c180114b..877c02a36c85 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -221,6 +221,9 @@ struct ethoc {
 	struct mii_bus *mdio;
 	struct clk *clk;
 	s8 phy_id;
+
+	int old_link;
+	int old_duplex;
 };
 
 /**
@@ -667,6 +670,32 @@ static int ethoc_mdio_write(struct mii_bus *bus, int phy, int reg, u16 val)
 
 static void ethoc_mdio_poll(struct net_device *dev)
 {
+	struct ethoc *priv = netdev_priv(dev);
+	struct phy_device *phydev = dev->phydev;
+	bool changed = false;
+	u32 mode;
+
+	if (priv->old_link != phydev->link) {
+		changed = true;
+		priv->old_link = phydev->link;
+	}
+
+	if (priv->old_duplex != phydev->duplex) {
+		changed = true;
+		priv->old_duplex = phydev->duplex;
+	}
+
+	if (!changed)
+		return;
+
+	mode = ethoc_read(priv, MODER);
+	if (phydev->duplex == DUPLEX_FULL)
+		mode |= MODER_FULLD;
+	else
+		mode &= ~MODER_FULLD;
+	ethoc_write(priv, MODER, mode);
+
+	phy_print_status(phydev);
 }
 
 static int ethoc_mdio_probe(struct net_device *dev)
@@ -685,6 +714,9 @@ static int ethoc_mdio_probe(struct net_device *dev)
 		return -ENXIO;
 	}
 
+	priv->old_duplex = -1;
+	priv->old_link = -1;
+
 	err = phy_connect_direct(dev, phy, ethoc_mdio_poll,
 				 PHY_INTERFACE_MODE_GMII);
 	if (err) {
@@ -721,6 +753,9 @@ static int ethoc_open(struct net_device *dev)
 		netif_start_queue(dev);
 	}
 
+	priv->old_link = -1;
+	priv->old_duplex = -1;
+
 	phy_start(dev->phydev);
 	napi_enable(&priv->napi);
 
-- 
2.9.3
