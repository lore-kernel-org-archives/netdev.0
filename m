From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next v2 2/4] net: mvpp2: make the phy optional
Date: Fri,  1 Sep 2017 11:04:53 +0200
Message-ID: <20170901090455.32316-3-antoine.tenart@free-electrons.com>
References: <20170901090455.32316-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170901090455.32316-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is not necessarily a PHY between the GoP and the physical port.
However, the driver currently makes the "phy" property mandatory,
contrary to what is stated in the device tree bindings. This patch makes
the PHY optional, and aligns the PPv2 driver on its device tree
documentation. However if a PHY is provided, the GoP link interrupt
won't be used.

With this patch switches directly connected to the serdes lanes and SFP
ports on the Armada 8040-db and Armada 7040-db can be used if the link
interrupt is described in the device tree.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
Tested-by: Marcin Wojtas <mw@semihalf.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index f93d3a332c60..b4d4759ddc25 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -6475,7 +6475,8 @@ static void mvpp2_start_dev(struct mvpp2_port *port)
 
 	mvpp2_port_mii_set(port);
 	mvpp2_port_enable(port);
-	phy_start(ndev->phydev);
+	if (ndev->phydev)
+		phy_start(ndev->phydev);
 	netif_tx_start_all_queues(port->dev);
 }
 
@@ -6501,7 +6502,8 @@ static void mvpp2_stop_dev(struct mvpp2_port *port)
 
 	mvpp2_egress_disable(port);
 	mvpp2_port_disable(port);
-	phy_stop(ndev->phydev);
+	if (ndev->phydev)
+		phy_stop(ndev->phydev);
 	phy_power_off(port->comphy);
 }
 
@@ -6558,6 +6560,10 @@ static int mvpp2_phy_connect(struct mvpp2_port *port)
 {
 	struct phy_device *phy_dev;
 
+	/* No PHY is attached */
+	if (!port->phy_node)
+		return 0;
+
 	phy_dev = of_phy_connect(port->dev, port->phy_node, mvpp2_link_event, 0,
 				 port->phy_interface);
 	if (!phy_dev) {
@@ -6578,6 +6584,9 @@ static void mvpp2_phy_disconnect(struct mvpp2_port *port)
 {
 	struct net_device *ndev = port->dev;
 
+	if (!ndev->phydev)
+		return;
+
 	phy_disconnect(ndev->phydev);
 }
 
@@ -7366,12 +7375,6 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 		return -ENOMEM;
 
 	phy_node = of_parse_phandle(port_node, "phy", 0);
-	if (!phy_node) {
-		dev_err(&pdev->dev, "missing phy\n");
-		err = -ENODEV;
-		goto err_free_netdev;
-	}
-
 	phy_mode = of_get_phy_mode(port_node);
 	if (phy_mode < 0) {
 		dev_err(&pdev->dev, "incorrect phy mode\n");
-- 
2.13.5
