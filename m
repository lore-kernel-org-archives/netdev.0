From: Romain Perier <romain.perier@collabora.com>
Subject: [PATCH v3] net: stmmac: Use the right logging function in stmmac_mdio_register
Date: Thu, 10 Aug 2017 16:56:05 +0200
Message-ID: <20170810145605.27048-1-romain.perier@collabora.com>
Cc: Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Romain Perier <romain.perier@collabora.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, the function stmmac_mdio_register() is only used by
stmmac_dvr_probe() from stmmac_main.c, in order to register the MDIO bus
and probe information about the PHY. As this function is called before
calling register_netdev(), all messages logged from stmmac_mdio_register
are prefixed by "(unnamed net_device)". The goal of netdev_info or
netdev_err is to dump useful infos about a net_device, when this data
structure is partially initialized, there is no point for using these
functions.

This commit fixes the issue by replacing all netdev_*() by the
corresponding dev_*() function for logging. The last netdev_info is
replaced by phy_attached_info(), as a valid phydev can be used at this
point.

Signed-off-by: Romain Perier <romain.perier@collabora.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---

Changes in v3:
- Replaced phy_attached_print by phy_attached_info, makes more sense
- Added Reviewed-by tag by Andrew

Changes in v2:
- Replaced dev_info() by phy_attached_print()
- Simplified message because informations were redudant
- Updated commit message

 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index db157a47000c..72ec711fcba2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -204,6 +204,7 @@ int stmmac_mdio_register(struct net_device *ndev)
 	struct stmmac_priv *priv = netdev_priv(ndev);
 	struct stmmac_mdio_bus_data *mdio_bus_data = priv->plat->mdio_bus_data;
 	struct device_node *mdio_node = priv->plat->mdio_node;
+	struct device *dev = ndev->dev.parent;
 	int addr, found;
 
 	if (!mdio_bus_data)
@@ -237,7 +238,7 @@ int stmmac_mdio_register(struct net_device *ndev)
 	else
 		err = mdiobus_register(new_bus);
 	if (err != 0) {
-		netdev_err(ndev, "Cannot register the MDIO bus\n");
+		dev_err(dev, "Cannot register the MDIO bus\n");
 		goto bus_register_fail;
 	}
 
@@ -285,14 +286,12 @@ int stmmac_mdio_register(struct net_device *ndev)
 			irq_str = irq_num;
 			break;
 		}
-		netdev_info(ndev, "PHY ID %08x at %d IRQ %s (%s)%s\n",
-			    phydev->phy_id, addr, irq_str, phydev_name(phydev),
-			    act ? " active" : "");
+		phy_attached_info(phydev);
 		found = 1;
 	}
 
 	if (!found && !mdio_node) {
-		netdev_warn(ndev, "No PHY found\n");
+		dev_warn(dev, "No PHY found\n");
 		mdiobus_unregister(new_bus);
 		mdiobus_free(new_bus);
 		return -ENODEV;
-- 
2.11.0
