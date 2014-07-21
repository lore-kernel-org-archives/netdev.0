From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [RFC 2/2] net: mvneta: Ensure the MDIO bus module is held
Date: Mon, 21 Jul 2014 15:26:10 -0300
Message-ID: <1405967170-19353-3-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1405967170-19353-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:55874 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933219AbaGUS1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 14:27:14 -0400
In-Reply-To: <1405967170-19353-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit adds proper module_{get,put} to prevent the MDIO bus module
from being unloaded while the phydev is connected. By doing so, we fix
a kernel panic produced when the mvmdio driver is removed, and one of
the ethernet interfaces using it is "up".

Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index dadd9a5..98d0cd1 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -297,6 +297,7 @@ struct mvneta_port {
 	struct mvneta_pcpu_stats *stats;
 
 	struct mii_bus *mii_bus;
+	struct module *phy_module;
 	struct phy_device *phy_dev;
 	phy_interface_t phy_interface;
 	struct device_node *phy_node;
@@ -2575,6 +2576,15 @@ static int mvneta_mdio_probe(struct mvneta_port *pp)
 		return -ENODEV;
 	}
 
+	/* Get the MDIO driver so it can't be removed beneath our feet */
+	pp->phy_module = phy_dev->bus->dev.driver ?
+			 phy_dev->bus->dev.driver->owner : NULL;
+	if (!try_module_get(pp->phy_module)) {
+		netdev_err(pp->dev, "could not get the MDIO module\n");
+		phy_disconnect(phy_dev);
+		return -EIO;
+	}
+
 	phy_dev->supported &= PHY_GBIT_FEATURES;
 	phy_dev->advertising = phy_dev->supported;
 
@@ -2590,6 +2600,8 @@ static void mvneta_mdio_remove(struct mvneta_port *pp)
 {
 	phy_disconnect(pp->phy_dev);
 	pp->phy_dev = NULL;
+	module_put(pp->phy_module);
+	pp->phy_module = NULL;
 }
 
 static int mvneta_open(struct net_device *dev)
-- 
2.0.1
