From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH] bgmac: connect to PHY and make use of PHY device
Date: Sat,  7 Dec 2013 00:53:55 +0100
Message-ID: <1386374035-31762-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hauke Mehrtens <hauke@hauke-m.de>,
	=?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:49650 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161722Ab3LFXyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 18:54:06 -0500
Received: by mail-ee0-f47.google.com with SMTP id e51so565136eek.20
        for <netdev@vger.kernel.org>; Fri, 06 Dec 2013 15:54:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We were already registering MDIO bus, but we were not connecting bgmac
to the PHY. Add proper call and implement adjust link function to switc=
h
MAC into requested state.
At the same time it's possible to drop our internal PHY management.
This is a "standard" PHY, so the "Generic PHY" driver works perfectly
fine with this. Don't duplicate the code.
=46inally make use of phy_ethtool_[gs]set functions instead implementin=
g
them from scratch.

This change was successfully tested on BCM5357. I was able to
autonegotiate 1000Mb/s full duplex, as well as force any of the
10/100/1000 half/full modes.

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
 drivers/net/ethernet/broadcom/bgmac.c |  190 +++++++++++--------------=
--------
 drivers/net/ethernet/broadcom/bgmac.h |   12 +--
 2 files changed, 64 insertions(+), 138 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethern=
et/broadcom/bgmac.c
index e2aa09c..0452937 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -682,70 +682,6 @@ static int bgmac_phy_write(struct bgmac *bgmac, u8=
 phyaddr, u8 reg, u16 value)
 	return 0;
 }
=20
-/* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipphyforce */
-static void bgmac_phy_force(struct bgmac *bgmac)
-{
-	u16 ctl;
-	u16 mask =3D ~(BGMAC_PHY_CTL_SPEED | BGMAC_PHY_CTL_SPEED_MSB |
-		     BGMAC_PHY_CTL_ANENAB | BGMAC_PHY_CTL_DUPLEX);
-
-	if (bgmac->phyaddr =3D=3D BGMAC_PHY_NOREGS)
-		return;
-
-	if (bgmac->autoneg)
-		return;
-
-	ctl =3D bgmac_phy_read(bgmac, bgmac->phyaddr, BGMAC_PHY_CTL);
-	ctl &=3D mask;
-	if (bgmac->full_duplex)
-		ctl |=3D BGMAC_PHY_CTL_DUPLEX;
-	if (bgmac->speed =3D=3D BGMAC_SPEED_100)
-		ctl |=3D BGMAC_PHY_CTL_SPEED_100;
-	else if (bgmac->speed =3D=3D BGMAC_SPEED_1000)
-		ctl |=3D BGMAC_PHY_CTL_SPEED_1000;
-	bgmac_phy_write(bgmac, bgmac->phyaddr, BGMAC_PHY_CTL, ctl);
-}
-
-/* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipphyadvertise */
-static void bgmac_phy_advertise(struct bgmac *bgmac)
-{
-	u16 adv;
-
-	if (bgmac->phyaddr =3D=3D BGMAC_PHY_NOREGS)
-		return;
-
-	if (!bgmac->autoneg)
-		return;
-
-	/* Adv selected 10/100 speeds */
-	adv =3D bgmac_phy_read(bgmac, bgmac->phyaddr, BGMAC_PHY_ADV);
-	adv &=3D ~(BGMAC_PHY_ADV_10HALF | BGMAC_PHY_ADV_10FULL |
-		 BGMAC_PHY_ADV_100HALF | BGMAC_PHY_ADV_100FULL);
-	if (!bgmac->full_duplex && bgmac->speed & BGMAC_SPEED_10)
-		adv |=3D BGMAC_PHY_ADV_10HALF;
-	if (!bgmac->full_duplex && bgmac->speed & BGMAC_SPEED_100)
-		adv |=3D BGMAC_PHY_ADV_100HALF;
-	if (bgmac->full_duplex && bgmac->speed & BGMAC_SPEED_10)
-		adv |=3D BGMAC_PHY_ADV_10FULL;
-	if (bgmac->full_duplex && bgmac->speed & BGMAC_SPEED_100)
-		adv |=3D BGMAC_PHY_ADV_100FULL;
-	bgmac_phy_write(bgmac, bgmac->phyaddr, BGMAC_PHY_ADV, adv);
-
-	/* Adv selected 1000 speeds */
-	adv =3D bgmac_phy_read(bgmac, bgmac->phyaddr, BGMAC_PHY_ADV2);
-	adv &=3D ~(BGMAC_PHY_ADV2_1000HALF | BGMAC_PHY_ADV2_1000FULL);
-	if (!bgmac->full_duplex && bgmac->speed & BGMAC_SPEED_1000)
-		adv |=3D BGMAC_PHY_ADV2_1000HALF;
-	if (bgmac->full_duplex && bgmac->speed & BGMAC_SPEED_1000)
-		adv |=3D BGMAC_PHY_ADV2_1000FULL;
-	bgmac_phy_write(bgmac, bgmac->phyaddr, BGMAC_PHY_ADV2, adv);
-
-	/* Restart */
-	bgmac_phy_write(bgmac, bgmac->phyaddr, BGMAC_PHY_CTL,
-			bgmac_phy_read(bgmac, bgmac->phyaddr, BGMAC_PHY_CTL) |
-			BGMAC_PHY_CTL_RESTART);
-}
-
 /* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipphyinit */
 static void bgmac_phy_init(struct bgmac *bgmac)
 {
@@ -876,19 +812,28 @@ static void bgmac_clear_mib(struct bgmac *bgmac)
 }
=20
 /* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/gmac_speed */
-static void bgmac_speed(struct bgmac *bgmac, int speed)
+static void bgmac_mac_speed(struct bgmac *bgmac)
 {
 	u32 mask =3D ~(BGMAC_CMDCFG_ES_MASK | BGMAC_CMDCFG_HD);
 	u32 set =3D 0;
=20
-	if (speed & BGMAC_SPEED_10)
+	switch (bgmac->mac_speed) {
+	case SPEED_10:
 		set |=3D BGMAC_CMDCFG_ES_10;
-	if (speed & BGMAC_SPEED_100)
+		break;
+	case SPEED_100:
 		set |=3D BGMAC_CMDCFG_ES_100;
-	if (speed & BGMAC_SPEED_1000)
+		break;
+	case SPEED_1000:
 		set |=3D BGMAC_CMDCFG_ES_1000;
-	if (!bgmac->full_duplex)
+		break;
+	default:
+		bgmac_err(bgmac, "Unsupported speed: %d\n", bgmac->mac_speed);
+	}
+
+	if (bgmac->mac_duplex =3D=3D DUPLEX_HALF)
 		set |=3D BGMAC_CMDCFG_HD;
+
 	bgmac_cmdcfg_maskset(bgmac, mask, set, true);
 }
=20
@@ -897,10 +842,9 @@ static void bgmac_miiconfig(struct bgmac *bgmac)
 	u8 imode =3D (bgmac_read(bgmac, BGMAC_DEV_STATUS) & BGMAC_DS_MM_MASK)=
 >>
 			BGMAC_DS_MM_SHIFT;
 	if (imode =3D=3D 0 || imode =3D=3D 1) {
-		if (bgmac->autoneg)
-			bgmac_speed(bgmac, BGMAC_SPEED_100);
-		else
-			bgmac_speed(bgmac, bgmac->speed);
+		bgmac->mac_speed =3D SPEED_100;
+		bgmac->mac_duplex =3D DUPLEX_FULL;
+		bgmac_mac_speed(bgmac);
 	}
 }
=20
@@ -1108,13 +1052,6 @@ static void bgmac_chip_init(struct bgmac *bgmac,=
 bool full_init)
=20
 	bgmac_write(bgmac, BGMAC_RXMAX_LENGTH, 32 + ETHER_MAX_LEN);
=20
-	if (!bgmac->autoneg) {
-		bgmac_speed(bgmac, bgmac->speed);
-		bgmac_phy_force(bgmac);
-	} else if (bgmac->speed) { /* if there is anything to adv */
-		bgmac_phy_advertise(bgmac);
-	}
-
 	if (full_init) {
 		bgmac_dma_init(bgmac);
 		if (1) /* FIXME: is there any case we don't want IRQs? */
@@ -1294,61 +1231,16 @@ static int bgmac_get_settings(struct net_device=
 *net_dev,
 {
 	struct bgmac *bgmac =3D netdev_priv(net_dev);
=20
-	cmd->supported =3D SUPPORTED_10baseT_Half |
-			 SUPPORTED_10baseT_Full |
-			 SUPPORTED_100baseT_Half |
-			 SUPPORTED_100baseT_Full |
-			 SUPPORTED_1000baseT_Half |
-			 SUPPORTED_1000baseT_Full |
-			 SUPPORTED_Autoneg;
-
-	if (bgmac->autoneg) {
-		WARN_ON(cmd->advertising);
-		if (bgmac->full_duplex) {
-			if (bgmac->speed & BGMAC_SPEED_10)
-				cmd->advertising |=3D ADVERTISED_10baseT_Full;
-			if (bgmac->speed & BGMAC_SPEED_100)
-				cmd->advertising |=3D ADVERTISED_100baseT_Full;
-			if (bgmac->speed & BGMAC_SPEED_1000)
-				cmd->advertising |=3D ADVERTISED_1000baseT_Full;
-		} else {
-			if (bgmac->speed & BGMAC_SPEED_10)
-				cmd->advertising |=3D ADVERTISED_10baseT_Half;
-			if (bgmac->speed & BGMAC_SPEED_100)
-				cmd->advertising |=3D ADVERTISED_100baseT_Half;
-			if (bgmac->speed & BGMAC_SPEED_1000)
-				cmd->advertising |=3D ADVERTISED_1000baseT_Half;
-		}
-	} else {
-		switch (bgmac->speed) {
-		case BGMAC_SPEED_10:
-			ethtool_cmd_speed_set(cmd, SPEED_10);
-			break;
-		case BGMAC_SPEED_100:
-			ethtool_cmd_speed_set(cmd, SPEED_100);
-			break;
-		case BGMAC_SPEED_1000:
-			ethtool_cmd_speed_set(cmd, SPEED_1000);
-			break;
-		}
-	}
-
-	cmd->duplex =3D bgmac->full_duplex ? DUPLEX_FULL : DUPLEX_HALF;
-
-	cmd->autoneg =3D bgmac->autoneg;
-
-	return 0;
+	return phy_ethtool_gset(bgmac->phy_dev, cmd);
 }
=20
-#if 0
 static int bgmac_set_settings(struct net_device *net_dev,
 			      struct ethtool_cmd *cmd)
 {
 	struct bgmac *bgmac =3D netdev_priv(net_dev);
=20
-	return -1;
+	return phy_ethtool_sset(bgmac->phy_dev, cmd);
 }
-#endif
=20
 static void bgmac_get_drvinfo(struct net_device *net_dev,
 			      struct ethtool_drvinfo *info)
@@ -1359,6 +1251,7 @@ static void bgmac_get_drvinfo(struct net_device *=
net_dev,
=20
 static const struct ethtool_ops bgmac_ethtool_ops =3D {
 	.get_settings		=3D bgmac_get_settings,
+	.set_settings		=3D bgmac_set_settings,
 	.get_drvinfo		=3D bgmac_get_drvinfo,
 };
=20
@@ -1377,9 +1270,35 @@ static int bgmac_mii_write(struct mii_bus *bus, =
int mii_id, int regnum,
 	return bgmac_phy_write(bus->priv, mii_id, regnum, value);
 }
=20
+static void bgmac_adjust_link(struct net_device *net_dev)
+{
+	struct bgmac *bgmac =3D netdev_priv(net_dev);
+	struct phy_device *phy_dev =3D bgmac->phy_dev;
+	bool update =3D false;
+
+	if (phy_dev->link) {
+		if (phy_dev->speed !=3D bgmac->mac_speed) {
+			bgmac->mac_speed =3D phy_dev->speed;
+			update =3D true;
+		}
+
+		if (phy_dev->duplex !=3D bgmac->mac_duplex) {
+			bgmac->mac_duplex =3D phy_dev->duplex;
+			update =3D true;
+		}
+	}
+
+	if (update) {
+		bgmac_mac_speed(bgmac);
+		phy_print_status(phy_dev);
+	}
+}
+
 static int bgmac_mii_register(struct bgmac *bgmac)
 {
 	struct mii_bus *mii_bus;
+	struct phy_device *phy_dev;
+	char bus_id[MII_BUS_ID_SIZE + 3];
 	int i, err =3D 0;
=20
 	mii_bus =3D mdiobus_alloc();
@@ -1411,8 +1330,22 @@ static int bgmac_mii_register(struct bgmac *bgma=
c)
=20
 	bgmac->mii_bus =3D mii_bus;
=20
+	/* Connect to the PHY */
+	snprintf(bus_id, sizeof(bus_id), PHY_ID_FMT, mii_bus->id,
+		 bgmac->phyaddr);
+	phy_dev =3D phy_connect(bgmac->net_dev, bus_id, &bgmac_adjust_link,
+			      PHY_INTERFACE_MODE_MII);
+	if (IS_ERR(phy_dev)) {
+		bgmac_err(bgmac, "PHY connecton failed\n");
+		err =3D PTR_ERR(phy_dev);
+		goto err_unregister_bus;
+	}
+	bgmac->phy_dev =3D phy_dev;
+
 	return err;
=20
+err_unregister_bus:
+	mdiobus_unregister(mii_bus);
 err_free_irq:
 	kfree(mii_bus->irq);
 err_free_bus:
@@ -1467,9 +1400,6 @@ static int bgmac_probe(struct bcma_device *core)
 	bcma_set_drvdata(core, bgmac);
=20
 	/* Defaults */
-	bgmac->autoneg =3D true;
-	bgmac->full_duplex =3D true;
-	bgmac->speed =3D BGMAC_SPEED_10 | BGMAC_SPEED_100 | BGMAC_SPEED_1000;
 	memcpy(bgmac->net_dev->dev_addr, mac, ETH_ALEN);
=20
 	/* On BCM4706 we need common core to access PHY */
diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethern=
et/broadcom/bgmac.h
index 66c8afb..550f2a8 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -342,10 +342,6 @@
 #define BGMAC_CHIPCTL_1_SW_TYPE_RGMII		0x000000C0
 #define BGMAC_CHIPCTL_1_RXC_DLL_BYPASS		0x00010000
=20
-#define BGMAC_SPEED_10				0x0001
-#define BGMAC_SPEED_100				0x0002
-#define BGMAC_SPEED_1000			0x0004
-
 #define BGMAC_WEIGHT	64
=20
 #define ETHER_MAX_LEN   1518
@@ -402,6 +398,7 @@ struct bgmac {
 	struct net_device *net_dev;
 	struct napi_struct napi;
 	struct mii_bus *mii_bus;
+	struct phy_device *phy_dev;
=20
 	/* DMA */
 	struct bgmac_dma_ring tx_ring[BGMAC_MAX_TX_RINGS];
@@ -416,10 +413,9 @@ struct bgmac {
 	u32 int_mask;
 	u32 int_status;
=20
-	/* Speed-related */
-	int speed;
-	bool autoneg;
-	bool full_duplex;
+	/* Current MAC state */
+	int mac_speed;
+	int mac_duplex;
=20
 	u8 phyaddr;
 	bool has_robosw;
--=20
1.7.10.4
