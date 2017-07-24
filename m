From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 08/18] net: mvpp2: make the phy optional
Date: Mon, 24 Jul 2017 15:48:38 +0200
Message-ID: <20170724134848.19330-9-antoine.tenart@free-electrons.com>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com, sebastian.hesselbarth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:47372 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755792AbdGXNuF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 09:50:05 -0400
In-Reply-To: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SFP ports do not necessarily need to have an Ethernet PHY between the
SoC and the actual physical port. However, the driver currently makes
the "phy" property mandatory, contrary to what is stated in the Device
Tree binding.

To allow handling the PPv2 controller on those boards, this patch makes
the PHY optional, and aligns the PPv2 driver on its device tree
documentation.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 948f5bd4ab18..f6eb98d38ced 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -6094,7 +6094,8 @@ static void mvpp2_start_dev(struct mvpp2_port *port)
 
 	mvpp2_port_mii_set(port);
 	mvpp2_port_enable(port);
-	phy_start(ndev->phydev);
+	if (ndev->phydev)
+		phy_start(ndev->phydev);
 	netif_tx_start_all_queues(port->dev);
 }
 
@@ -6118,7 +6119,8 @@ static void mvpp2_stop_dev(struct mvpp2_port *port)
 
 	mvpp2_egress_disable(port);
 	mvpp2_port_disable(port);
-	phy_stop(ndev->phydev);
+	if (ndev->phydev)
+		phy_stop(ndev->phydev);
 }
 
 static int mvpp2_check_ringparam_valid(struct net_device *dev,
@@ -6176,6 +6178,10 @@ static int mvpp2_phy_connect(struct mvpp2_port *port)
 	struct phy_device *phy_dev;
 	u32 phy_addr;
 
+	/* No PHY is attached */
+	if (!port->phy_node)
+		return 0;
+
 	phy_dev = of_phy_connect(port->dev, port->phy_node, mvpp2_link_event, 0,
 				 port->phy_interface);
 	if (!phy_dev) {
@@ -6206,6 +6212,9 @@ static void mvpp2_phy_disconnect(struct mvpp2_port *port)
 {
 	struct net_device *ndev = port->dev;
 
+	if (!ndev->phydev)
+		return;
+
 	phy_disconnect(ndev->phydev);
 }
 
@@ -6760,12 +6769,6 @@ static int mvpp2_port_probe(struct platform_device *pdev,
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
2.13.3
