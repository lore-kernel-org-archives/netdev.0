From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next 04/13] net: mvpp2: initialize the comphy
Date: Thu, 24 Aug 2017 10:38:14 +0200
Message-ID: <20170824083823.16826-5-antoine.tenart@free-electrons.com>
References: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: davem@davemloft.net, kishon@ti.com, andrew@lunn.ch,
        jason@lakedaemon.net, sebastian.hesselbarth@gmail.com,
        gregory.clement@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170824083823.16826-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On some platforms, the comphy is between the MAC GoP and the PHYs. The
mvpp2 driver currently relies on the firmware/bootloader to configure
the comphy. As a comphy driver was added to the generic PHY framework,
this patch uses it in the mvpp2 driver to configure the comphy at boot
time to avoid relying on the bootloader.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 44 +++++++++++++++++++++++++++++++++++-
 1 file changed, 43 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 7fa251bf91ae..5f188de63caf 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -28,6 +28,7 @@
 #include <linux/of_address.h>
 #include <linux/of_device.h>
 #include <linux/phy.h>
+#include <linux/phy/phy.h>
 #include <linux/clk.h>
 #include <linux/hrtimer.h>
 #include <linux/ktime.h>
@@ -861,6 +862,7 @@ struct mvpp2_port {
 
 	phy_interface_t phy_interface;
 	struct device_node *phy_node;
+	struct phy *comphy;
 	unsigned int link;
 	unsigned int duplex;
 	unsigned int speed;
@@ -4420,6 +4422,32 @@ static int mvpp22_gop_init(struct mvpp2_port *port)
 	return -EINVAL;
 }
 
+static int mvpp22_comphy_init(struct mvpp2_port *port)
+{
+	enum phy_mode mode;
+	int ret;
+
+	if (!port->comphy)
+		return 0;
+
+	switch (port->phy_interface) {
+	case PHY_INTERFACE_MODE_SGMII:
+		mode = PHY_MODE_SGMII;
+		break;
+	case PHY_INTERFACE_MODE_10GKR:
+		mode = PHY_MODE_10GKR;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	ret = phy_set_mode(port->comphy, mode);
+	if (ret)
+		return ret;
+
+	return phy_power_on(port->comphy);
+}
+
 static void mvpp2_port_mii_gmac_configure_mode(struct mvpp2_port *port)
 {
 	u32 val;
@@ -6404,8 +6432,10 @@ static void mvpp2_start_dev(struct mvpp2_port *port)
 	/* Enable interrupts on all CPUs */
 	mvpp2_interrupts_enable(port);
 
-	if (port->priv->hw_version == MVPP22)
+	if (port->priv->hw_version == MVPP22) {
+		mvpp22_comphy_init(port);
 		mvpp22_gop_init(port);
+	}
 
 	mvpp2_port_mii_set(port);
 	mvpp2_port_enable(port);
@@ -6436,6 +6466,7 @@ static void mvpp2_stop_dev(struct mvpp2_port *port)
 	mvpp2_egress_disable(port);
 	mvpp2_port_disable(port);
 	phy_stop(ndev->phydev);
+	phy_power_off(port->comphy);
 }
 
 static int mvpp2_check_ringparam_valid(struct net_device *dev,
@@ -7242,6 +7273,7 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 			    struct mvpp2 *priv)
 {
 	struct device_node *phy_node;
+	struct phy *comphy;
 	struct mvpp2_port *port;
 	struct mvpp2_port_pcpu *port_pcpu;
 	struct net_device *dev;
@@ -7285,6 +7317,15 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 		goto err_free_netdev;
 	}
 
+	comphy = devm_of_phy_get(&pdev->dev, port_node, NULL);
+	if (IS_ERR(comphy)) {
+		if (PTR_ERR(comphy) == -EPROBE_DEFER) {
+			err = -EPROBE_DEFER;
+			goto err_free_netdev;
+		}
+		comphy = NULL;
+	}
+
 	if (of_property_read_u32(port_node, "port-id", &id)) {
 		err = -EINVAL;
 		dev_err(&pdev->dev, "missing port-id value\n");
@@ -7318,6 +7359,7 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 
 	port->phy_node = phy_node;
 	port->phy_interface = phy_mode;
+	port->comphy = comphy;
 
 	if (priv->hw_version == MVPP21) {
 		res = platform_get_resource(pdev, IORESOURCE_MEM, 2 + id);
-- 
2.13.5
