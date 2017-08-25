From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net v2 2/4] net: mvpp2: move the mac retrieval/copy logic into its own function
Date: Fri, 25 Aug 2017 16:14:18 +0200
Message-ID: <20170825141420.14027-3-antoine.tenart@free-electrons.com>
References: <20170825141420.14027-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>, andrew@lunn.ch,
        gregory.clement@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com, netdev@vger.kernel.org
To: davem@davemloft.net, thomas.petazzoni@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170825141420.14027-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The MAC retrieval has a quite complicated logic (which is broken). Moves
it to its own function to prepare for patches fixing its logic, so that
reviews are easier.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 45 +++++++++++++++++++++---------------
 1 file changed, 27 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 4d598ca8503a..a1593134ed96 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -6492,6 +6492,31 @@ static int mvpp2_port_init(struct mvpp2_port *port)
 	return err;
 }
 
+static void mvpp2_port_copy_mac_addr(struct net_device *dev, struct mvpp2 *priv,
+				     struct device_node *port_node,
+				     char **mac_from)
+{
+	struct mvpp2_port *port = netdev_priv(dev);
+	char hw_mac_addr[ETH_ALEN] = {0};
+	const char *dt_mac_addr;
+
+	dt_mac_addr = of_get_mac_address(port_node);
+	if (dt_mac_addr && is_valid_ether_addr(dt_mac_addr)) {
+		*mac_from = "device tree";
+		ether_addr_copy(dev->dev_addr, dt_mac_addr);
+	} else {
+		if (priv->hw_version == MVPP21)
+			mvpp21_get_mac_address(port, hw_mac_addr);
+		if (is_valid_ether_addr(hw_mac_addr)) {
+			*mac_from = "hardware";
+			ether_addr_copy(dev->dev_addr, hw_mac_addr);
+		} else {
+			*mac_from = "random";
+			eth_hw_addr_random(dev);
+		}
+	}
+}
+
 /* Ports initialization */
 static int mvpp2_port_probe(struct platform_device *pdev,
 			    struct device_node *port_node,
@@ -6502,9 +6527,7 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 	struct mvpp2_port_pcpu *port_pcpu;
 	struct net_device *dev;
 	struct resource *res;
-	const char *dt_mac_addr;
-	const char *mac_from;
-	char hw_mac_addr[ETH_ALEN] = {0};
+	char *mac_from = "";
 	u32 id;
 	int features;
 	int phy_mode;
@@ -6585,21 +6608,7 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 		goto err_free_irq;
 	}
 
-	dt_mac_addr = of_get_mac_address(port_node);
-	if (dt_mac_addr && is_valid_ether_addr(dt_mac_addr)) {
-		mac_from = "device tree";
-		ether_addr_copy(dev->dev_addr, dt_mac_addr);
-	} else {
-		if (priv->hw_version == MVPP21)
-			mvpp21_get_mac_address(port, hw_mac_addr);
-		if (is_valid_ether_addr(hw_mac_addr)) {
-			mac_from = "hardware";
-			ether_addr_copy(dev->dev_addr, hw_mac_addr);
-		} else {
-			mac_from = "random";
-			eth_hw_addr_random(dev);
-		}
-	}
+	mvpp2_port_copy_mac_addr(dev, priv, port_node, &mac_from);
 
 	port->tx_ring_size = MVPP2_MAX_TXD;
 	port->rx_ring_size = MVPP2_MAX_RXD;
-- 
2.13.5
