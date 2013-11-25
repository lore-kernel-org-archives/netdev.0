From: Jonas Jensen <jonas.jensen@gmail.com>
Subject: [PATCH v2 2/6] net: MOXA ART: connect to PHY
Date: Mon, 25 Nov 2013 16:27:04 +0100
Message-ID: <1385393228-22416-2-git-send-email-jonas.jensen@gmail.com>
References: <1385393228-22416-1-git-send-email-jonas.jensen@gmail.com>
Cc: davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, f.fainelli@gmail.com,
	bhutchings@solarflare.com, Jonas Jensen <jonas.jensen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1385393228-22416-1-git-send-email-jonas.jensen@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The kernel now has a MDIO bus driver and a phy_driver (RTL8201CP),
connect to this PHY using OF.

Signed-off-by: Jonas Jensen <jonas.jensen@gmail.com>
---

Notes:
    Thanks for reviewing!
    
    Changes since v1:
    
    1. split ethtool support to separate patch
    2. changes to devicetree binding document
    3. add moxart_mac_update_duplex()
    4. compare previous link state/speed/duplex on link adjust
    5. use of_get_phy_mode() not PHY_INTERFACE_MODE_MII
    6. bail on of_parse_phandle() failure
    7. remove "if (!priv->phy_dev) return -ENODEV;"
       moxart_do_ioctl()
    8. remove "if (priv->phy_dev)"
       moxart_mac_open(), moxart_mac_stop()
    
    Applies to next-20131125

 .../devicetree/bindings/net/moxa,moxart-mac.txt    | 47 ++++++++++-
 drivers/net/ethernet/moxa/moxart_ether.c           | 92 +++++++++++++++++++++-
 drivers/net/ethernet/moxa/moxart_ether.h           |  2 +
 3 files changed, 138 insertions(+), 3 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/moxa,moxart-mac.txt b/Documentation/devicetree/bindings/net/moxa,moxart-mac.txt
index 583418b..56f0374 100644
--- a/Documentation/devicetree/bindings/net/moxa,moxart-mac.txt
+++ b/Documentation/devicetree/bindings/net/moxa,moxart-mac.txt
@@ -1,21 +1,64 @@
 MOXA ART Ethernet Controller
 
+Integrated MDIO bus node:
+
+- compatible: "moxa,moxart-mdio"
+- Inherets from MDIO bus node binding[1]
+
+[1] Documentation/devicetree/bindings/net/phy.txt
+
+
+Ethernet node:
+
 Required properties:
 
 - compatible : Must be "moxa,moxart-mac"
 - reg : Should contain register location and length
 - interrupts : Should contain the mac interrupt number
 
+Optional Properties:
+
+- phy-handle : the phandle to a PHY node
+
+
 Example:
 
+	mdio0: mdio@90900090 {
+		compatible = "moxa,moxart-mdio";
+		reg = <0x90900090 0x8>;
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		ethphy0: ethernet-phy@1 {
+			device_type = "ethernet-phy";
+			compatible = "moxa,moxart-rtl8201cp", "ethernet-phy-ieee802.3-c22";
+			reg = <1>;
+		};
+	};
+
+	mdio1: mdio@92000090 {
+		compatible = "moxa,moxart-mdio";
+		reg = <0x92000090 0x8>;
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		ethphy1: ethernet-phy@1 {
+			device_type = "ethernet-phy";
+			compatible = "moxa,moxart-rtl8201cp", "ethernet-phy-ieee802.3-c22";
+			reg = <1>;
+		};
+	};
+
 	mac0: mac@90900000 {
 		compatible = "moxa,moxart-mac";
-		reg =	<0x90900000 0x100>;
+		reg = <0x90900000 0x90>;
 		interrupts = <25 0>;
+		phy-handle = <&ethphy0>;
 	};
 
 	mac1: mac@92000000 {
 		compatible = "moxa,moxart-mac";
-		reg =	<0x92000000 0x100>;
+		reg = <0x92000000 0x90>;
 		interrupts = <27 0>;
+		phy-handle = <&ethphy1>;
 	};
diff --git a/drivers/net/ethernet/moxa/moxart_ether.c b/drivers/net/ethernet/moxa/moxart_ether.c
index 3c14afd..1b87034 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.c
+++ b/drivers/net/ethernet/moxa/moxart_ether.c
@@ -26,6 +26,9 @@
 #include <linux/of_irq.h>
 #include <linux/crc32.h>
 #include <linux/crc32c.h>
+#include <linux/phy.h>
+#include <linux/of_mdio.h>
+#include <linux/of_net.h>
 
 #include "moxart_ether.h"
 
@@ -61,6 +64,16 @@ static int moxart_set_mac_address(struct net_device *ndev, void *addr)
 	return 0;
 }
 
+static int moxart_do_ioctl(struct net_device *ndev, struct ifreq *ir, int cmd)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+
+	if (!netif_running(ndev))
+		return -EINVAL;
+
+	return phy_mii_ioctl(priv->phy_dev, ir, cmd);
+}
+
 static void moxart_mac_free_memory(struct net_device *ndev)
 {
 	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
@@ -110,6 +123,19 @@ static void moxart_mac_enable(struct net_device *ndev)
 	writel(priv->reg_maccr, priv->base + REG_MAC_CTRL);
 }
 
+static void moxart_mac_update_duplex(struct net_device *ndev)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+
+	priv->reg_maccr &= ~(FULLDUP | ENRX_IN_HALFTX);
+	if (priv->duplex)
+		priv->reg_maccr |= FULLDUP;
+	else
+		priv->reg_maccr |= ENRX_IN_HALFTX;
+
+	writel(priv->reg_maccr, priv->base + REG_MAC_CTRL);
+}
+
 static void moxart_mac_setup_desc_ring(struct net_device *ndev)
 {
 	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
@@ -169,6 +195,9 @@ static int moxart_mac_open(struct net_device *ndev)
 	moxart_update_mac_address(ndev);
 	moxart_mac_setup_desc_ring(ndev);
 	moxart_mac_enable(ndev);
+
+	phy_start(priv->phy_dev);
+
 	netif_start_queue(ndev);
 
 	netdev_dbg(ndev, "%s: IMR=0x%x, MACCR=0x%x\n",
@@ -184,6 +213,8 @@ static int moxart_mac_stop(struct net_device *ndev)
 
 	napi_disable(&priv->napi);
 
+	phy_stop(priv->phy_dev);
+
 	netif_stop_queue(ndev);
 
 	/* disable all interrupts */
@@ -429,12 +460,49 @@ static struct net_device_ops moxart_netdev_ops = {
 	.ndo_set_mac_address	= moxart_set_mac_address,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_do_ioctl		= moxart_do_ioctl,
 };
 
+static void moxart_adjust_link(struct net_device *ndev)
+{
+	struct moxart_mac_priv_t *priv = netdev_priv(ndev);
+	unsigned long flags;
+	int status_change = 0;
+
+	if (priv->phy_dev->link) {
+		if (priv->speed != priv->phy_dev->speed) {
+			priv->speed = priv->phy_dev->speed;
+			status_change = 1;
+		}
+
+		if (priv->duplex != priv->phy_dev->duplex) {
+			spin_lock_irqsave(&priv->txlock, flags);
+
+			priv->duplex = priv->phy_dev->duplex;
+			moxart_mac_update_duplex(ndev);
+
+			spin_unlock_irqrestore(&priv->txlock, flags);
+			status_change = 1;
+		}
+	}
+
+	if (priv->link != priv->phy_dev->link) {
+		if (!priv->phy_dev->link) {
+			priv->speed = 0;
+			priv->duplex = -1;
+		}
+		priv->link = priv->phy_dev->link;
+		status_change = 1;
+	}
+
+	if (status_change)
+		phy_print_status(priv->phy_dev);
+}
+
 static int moxart_mac_probe(struct platform_device *pdev)
 {
 	struct device *p_dev = &pdev->dev;
-	struct device_node *node = p_dev->of_node;
+	struct device_node *node = p_dev->of_node, *phy_node;
 	struct net_device *ndev;
 	struct moxart_mac_priv_t *priv;
 	struct resource *res;
@@ -455,6 +523,28 @@ static int moxart_mac_probe(struct platform_device *pdev)
 	priv = netdev_priv(ndev);
 	priv->ndev = ndev;
 
+	priv->link = 0;
+	priv->speed = 0;
+	priv->duplex = -1;
+
+	phy_node = of_parse_phandle(node, "phy-handle", 0);
+	if (!phy_node) {
+		dev_err(p_dev, "of_parse_phandle failed\n");
+		ret = -ENODEV;
+		goto init_fail;
+	}
+
+	if (phy_node) {
+		priv->phy_dev = of_phy_connect(priv->ndev, phy_node,
+					       &moxart_adjust_link,
+					       0, of_get_phy_mode(node));
+		if (!priv->phy_dev) {
+			dev_err(p_dev, "of_phy_connect failed\n");
+			ret = -ENODEV;
+			goto init_fail;
+		}
+	}
+
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	ndev->base_addr = res->start;
 	priv->base = devm_ioremap_resource(p_dev, res);
diff --git a/drivers/net/ethernet/moxa/moxart_ether.h b/drivers/net/ethernet/moxa/moxart_ether.h
index 2be9280..b8877bf 100644
--- a/drivers/net/ethernet/moxa/moxart_ether.h
+++ b/drivers/net/ethernet/moxa/moxart_ether.h
@@ -297,6 +297,8 @@ struct moxart_mac_priv_t {
 	unsigned int reg_imr;
 	struct napi_struct napi;
 	struct net_device *ndev;
+	struct phy_device *phy_dev;
+	int speed, duplex, link;
 
 	dma_addr_t rx_base;
 	dma_addr_t rx_mapping[RX_DESC_NUM];
-- 
1.8.2.1
