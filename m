From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net v2 5/5] net: qcom/emac: fix of_node and phydev leaks
Date: Thu, 24 Nov 2016 19:21:31 +0100
Message-ID: <1480011691-13278-6-git-send-email-johan@kernel.org>
References: <1480011691-13278-1-git-send-email-johan@kernel.org>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Madalin Bucur <madalin.bucur@nxp.com>,
        Timur Tabi <timur@codeaurora.org>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Johan Hovold <johan@kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480011691-13278-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make sure to drop the reference taken by of_phy_find_device() during
probe on probe errors and on driver unbind.

Also drop the of_node reference taken by of_parse_phandle() in the same
path.

Fixes: b9b17debc69d ("net: emac: emac gigabit ethernet controller driver")
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/net/ethernet/qualcomm/emac/emac-phy.c | 1 +
 drivers/net/ethernet/qualcomm/emac/emac.c     | 4 ++++
 2 files changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac-phy.c b/drivers/net/ethernet/qualcomm/emac/emac-phy.c
index da4e90db4d98..99a14df28b96 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-phy.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-phy.c
@@ -212,6 +212,7 @@ int emac_phy_config(struct platform_device *pdev, struct emac_adapter *adpt)
 
 		phy_np = of_parse_phandle(np, "phy-handle", 0);
 		adpt->phydev = of_phy_find_device(phy_np);
+		of_node_put(phy_np);
 	}
 
 	if (!adpt->phydev) {
diff --git a/drivers/net/ethernet/qualcomm/emac/emac.c b/drivers/net/ethernet/qualcomm/emac/emac.c
index 4fede4b86538..57b35aeac51a 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac.c
@@ -711,6 +711,8 @@ static int emac_probe(struct platform_device *pdev)
 err_undo_napi:
 	netif_napi_del(&adpt->rx_q.napi);
 err_undo_mdiobus:
+	if (!has_acpi_companion(&pdev->dev))
+		put_device(&adpt->phydev->mdio.dev);
 	mdiobus_unregister(adpt->mii_bus);
 err_undo_clocks:
 	emac_clks_teardown(adpt);
@@ -730,6 +732,8 @@ static int emac_remove(struct platform_device *pdev)
 
 	emac_clks_teardown(adpt);
 
+	if (!has_acpi_companion(&pdev->dev))
+		put_device(&adpt->phydev->mdio.dev);
 	mdiobus_unregister(adpt->mii_bus);
 	free_netdev(netdev);
 
-- 
2.7.3
