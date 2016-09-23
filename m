From: Jaedon Shin <jaedon.shin@gmail.com>
Subject: [PATCH] net: bcmgenet: Fix EPHY reset in power up
Date: Fri, 23 Sep 2016 22:20:04 +0900
Message-ID: <20160923132004.5734-1-jaedon.shin@gmail.com>
Cc: Philippe Reynes <tremyfr@gmail.com>, netdev@vger.kernel.org,
        Jaedon Shin <jaedon.shin@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:36579 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759938AbcIWNUO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 09:20:14 -0400
Received: by mail-pa0-f67.google.com with SMTP id my20so5097604pab.3
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 06:20:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bcmgenet_mii_reset() is always not running in power up sequence
after 'commit 62469c76007e ("net: ethernet: bcmgenet: use phydev from
struct net_device")'. This'll show extremely high latency and duplicate
packets while interface down and up repeatedly.

For now, adds again a private phydev for mii reset when runs power up to
open interface.

Signed-off-by: Jaedon Shin <jaedon.shin@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.h | 1 +
 drivers/net/ethernet/broadcom/genet/bcmmii.c   | 9 ++++++---
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 0f0868c56f05..1e2dc34d331a 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -597,6 +597,7 @@ struct bcmgenet_priv {
 
 	/* MDIO bus variables */
 	wait_queue_head_t wq;
+	struct phy_device *phydev;
 	bool internal_phy;
 	struct device_node *phy_dn;
 	struct device_node *mdio_dn;
diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index e907acd81da9..b2bd5302c478 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -183,9 +183,9 @@ void bcmgenet_mii_reset(struct net_device *dev)
 	if (GENET_IS_V4(priv))
 		return;
 
-	if (dev->phydev) {
-		phy_init_hw(dev->phydev);
-		phy_start_aneg(dev->phydev);
+	if (priv->phydev) {
+		phy_init_hw(priv->phydev);
+		phy_start_aneg(priv->phydev);
 	}
 }
 
@@ -383,6 +383,8 @@ int bcmgenet_mii_probe(struct net_device *dev)
 		}
 	}
 
+	priv->phydev = phydev;
+
 	/* Configure port multiplexer based on what the probed PHY device since
 	 * reading the 'max-speed' property determines the maximum supported
 	 * PHY speed which is needed for bcmgenet_mii_config() to configure
@@ -605,6 +607,7 @@ static int bcmgenet_mii_pd_init(struct bcmgenet_priv *priv)
 
 	}
 
+	priv->phydev = phydev;
 	priv->phy_interface = pd->phy_interface;
 
 	return 0;
-- 
2.10.0
