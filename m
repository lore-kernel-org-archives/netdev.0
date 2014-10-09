From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH RFT 4/8] net: pxa168_eth: Remove HW auto-negotiaion
Date: Thu,  9 Oct 2014 14:39:02 +0200
Message-ID: <1412858346-11334-5-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1412858346-11334-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	=?UTF-8?q?Antoine=20T=C3=A9nart?=
	<antoine.tenart@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Eric Miao <eric.y.miao@gmail.com>,
	Haojian Zhuang <haojian.zhuang@gmail.com>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:65211 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754972AbaJIMjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 08:39:23 -0400
In-Reply-To: <1412858346-11334-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marvell Ethernet IP supports PHY negotiation driven by HW. This
fundamentally clashes with libphy (software) driven negotiation and
also cannot cope with quirky PHYs. Therefore, always disable any HW
negotiation features and properly use libphy's phy_device.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
---
Cc: "David S. Miller" <davem@davemloft.net>
Cc: "Antoine T=C3=A9nart" <antoine.tenart@free-electrons.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: Eric Miao <eric.y.miao@gmail.com>
Cc: Haojian Zhuang <haojian.zhuang@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/ethernet/marvell/pxa168_eth.c | 94 +++++++++++++++++++++++=
+++-----
 1 file changed, 79 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/et=
hernet/marvell/pxa168_eth.c
index 332700144d81..a406a91812c5 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -106,6 +106,7 @@
 #define SDMA_CMD_ERD		(1 << 7)
=20
 /* Bit definitions of the Port Config Reg */
+#define PCR_DUPLEX_FULL		(1 << 15)
 #define PCR_HS			(1 << 12)
 #define PCR_EN			(1 << 7)
 #define PCR_PM			(1 << 0)
@@ -113,11 +114,17 @@
 /* Bit definitions of the Port Config Extend Reg */
 #define PCXR_2BSM		(1 << 28)
 #define PCXR_DSCP_EN		(1 << 21)
+#define PCXR_RMII_EN		(1 << 20)
+#define PCXR_AN_SPEED_DIS	(1 << 19)
+#define PCXR_SPEED_100		(1 << 18)
 #define PCXR_MFL_1518		(0 << 14)
 #define PCXR_MFL_1536		(1 << 14)
 #define PCXR_MFL_2048		(2 << 14)
 #define PCXR_MFL_64K		(3 << 14)
+#define PCXR_FLOWCTL_DIS	(1 << 12)
 #define PCXR_FLP		(1 << 11)
+#define PCXR_AN_FLOWCTL_DIS	(1 << 10)
+#define PCXR_AN_DUPLEX_DIS	(1 << 9)
 #define PCXR_PRIO_TX_OFF	3
 #define PCXR_TX_HIGH_PRI	(7 << PCXR_PRIO_TX_OFF)
=20
@@ -272,6 +279,7 @@ enum hash_table_entry {
 static int pxa168_get_settings(struct net_device *dev, struct ethtool_=
cmd *cmd);
 static int pxa168_set_settings(struct net_device *dev, struct ethtool_=
cmd *cmd);
 static int pxa168_init_hw(struct pxa168_eth_private *pep);
+static int pxa168_init_phy(struct net_device *dev);
 static void eth_port_reset(struct net_device *dev);
 static void eth_port_start(struct net_device *dev);
 static int pxa168_eth_open(struct net_device *dev);
@@ -658,14 +666,7 @@ static void eth_port_start(struct net_device *dev)
 	struct pxa168_eth_private *pep =3D netdev_priv(dev);
 	int tx_curr_desc, rx_curr_desc;
=20
-	/* Perform PHY reset, if there is a PHY. */
-	if (pep->phy !=3D NULL) {
-		struct ethtool_cmd cmd;
-
-		pxa168_get_settings(pep->dev, &cmd);
-		phy_init_hw(pep->phy);
-		pxa168_set_settings(pep->dev, &cmd);
-	}
+	phy_start(pep->phy);
=20
 	/* Assignment of Tx CTRP of given queue */
 	tx_curr_desc =3D pep->tx_curr_desc_q;
@@ -720,6 +721,8 @@ static void eth_port_reset(struct net_device *dev)
 	val =3D rdl(pep, PORT_CONFIG);
 	val &=3D ~PCR_EN;
 	wrl(pep, PORT_CONFIG, val);
+
+	phy_stop(pep->phy);
 }
=20
 /*
@@ -981,8 +984,11 @@ static int set_port_config_ext(struct pxa168_eth_p=
rivate *pep)
 		skb_size =3D PCXR_MFL_64K;
=20
 	/* Extended Port Configuration */
-	wrl(pep,
-	    PORT_CONFIG_EXT, PCXR_2BSM | /* Two byte prefix aligns IP hdr */
+	wrl(pep, PORT_CONFIG_EXT,
+	    PCXR_AN_SPEED_DIS |		 /* Disable HW AN */
+	    PCXR_AN_DUPLEX_DIS |
+	    PCXR_AN_FLOWCTL_DIS |
+	    PCXR_2BSM |			 /* Two byte prefix aligns IP hdr */
 	    PCXR_DSCP_EN |		 /* Enable DSCP in IP */
 	    skb_size | PCXR_FLP |	 /* do not force link pass */
 	    PCXR_TX_HIGH_PRI);		 /* Transmit - high priority queue */
@@ -990,6 +996,63 @@ static int set_port_config_ext(struct pxa168_eth_p=
rivate *pep)
 	return 0;
 }
=20
+static void pxa168_eth_adjust_link(struct net_device *dev)
+{
+	struct pxa168_eth_private *pep =3D netdev_priv(dev);
+	struct phy_device *phy =3D pep->phy;
+	u32 cfg =3D rdl(pep, PORT_CONFIG);
+	u32 cfgext =3D rdl(pep, PORT_CONFIG_EXT);
+
+	cfg &=3D ~PCR_DUPLEX_FULL;
+	cfgext &=3D ~(PCXR_SPEED_100 | PCXR_FLOWCTL_DIS | PCXR_RMII_EN);
+
+	if (phy->interface =3D=3D PHY_INTERFACE_MODE_RMII)
+		cfgext |=3D PCXR_RMII_EN;
+	if (phy->speed =3D=3D SPEED_100)
+		cfgext |=3D PCXR_SPEED_100;
+	if (phy->duplex)
+		cfg |=3D PCR_DUPLEX_FULL;
+	if (!phy->pause)
+		cfgext |=3D PCXR_FLOWCTL_DIS;
+
+	wrl(pep, PORT_CONFIG, cfg);
+	wrl(pep, PORT_CONFIG_EXT, cfgext);
+}
+
+static int pxa168_init_phy(struct net_device *dev)
+{
+	struct pxa168_eth_private *pep =3D netdev_priv(dev);
+	struct ethtool_cmd cmd;
+	int err;
+
+	if (pep->phy)
+		return 0;
+
+	pep->phy =3D mdiobus_scan(pep->smi_bus, pep->phy_addr);
+	if (!pep->phy)
+		return -ENODEV;
+
+	err =3D phy_connect_direct(dev, pep->phy, pxa168_eth_adjust_link,
+				 pep->phy_intf);
+	if (err)
+		return err;
+
+	err =3D pxa168_get_settings(dev, &cmd);
+	if (err)
+		return err;
+
+	cmd.phy_address =3D pep->phy_addr;
+	cmd.speed =3D pep->phy_speed;
+	cmd.duplex =3D pep->phy_duplex;
+	cmd.advertising =3D PHY_BASIC_FEATURES;
+	cmd.autoneg =3D AUTONEG_ENABLE;
+
+	if (cmd.speed !=3D 0)
+		cmd.autoneg =3D AUTONEG_DISABLE;
+
+	return pxa168_set_settings(dev, &cmd);
+}
+
 static int pxa168_init_hw(struct pxa168_eth_private *pep)
 {
 	int err =3D 0;
@@ -1136,6 +1199,10 @@ static int pxa168_eth_open(struct net_device *de=
v)
 	struct pxa168_eth_private *pep =3D netdev_priv(dev);
 	int err;
=20
+	err =3D pxa168_init_phy(dev);
+	if (err)
+		return err;
+
 	err =3D request_irq(dev->irq, pxa168_eth_int_handler, 0, dev->name, d=
ev);
 	if (err) {
 		dev_err(&dev->dev, "can't assign irq\n");
@@ -1596,9 +1663,6 @@ static int pxa168_eth_probe(struct platform_devic=
e *pdev)
 		goto err_free_mdio;
=20
 	pxa168_init_hw(pep);
-	err =3D ethernet_phy_setup(dev);
-	if (err)
-		goto err_mdiobus;
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	err =3D register_netdev(dev);
 	if (err)
@@ -1629,13 +1693,13 @@ static int pxa168_eth_remove(struct platform_de=
vice *pdev)
 				  pep->htpr, pep->htpr_dma);
 		pep->htpr =3D NULL;
 	}
+	if (pep->phy)
+		phy_disconnect(pep->phy);
 	if (pep->clk) {
 		clk_disable(pep->clk);
 		clk_put(pep->clk);
 		pep->clk =3D NULL;
 	}
-	if (pep->phy !=3D NULL)
-		phy_detach(pep->phy);
=20
 	iounmap(pep->base);
 	pep->base =3D NULL;
--=20
2.1.1
