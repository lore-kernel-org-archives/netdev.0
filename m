From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH RFT 1/8] phy: marvell: Add support for 88E3016 FastEthernet PHY
Date: Thu,  9 Oct 2014 14:38:59 +0200
Message-ID: <1412858346-11334-2-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1412858346-11334-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	=?UTF-8?q?Antoine=20T=C3=A9nart?=
	<antoine.tenart@free-electrons.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:37555 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751195AbaJIMjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 08:39:18 -0400
In-Reply-To: <1412858346-11334-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marvell 88E3016 is a FastEthernet PHY that also can be found in Marvell
Berlin SoCs as integrated PHY.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
---
Cc: "David S. Miller" <davem@davemloft.net>
Cc: "Antoine T=C3=A9nart" <antoine.tenart@free-electrons.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/phy/marvell.c   | 46 +++++++++++++++++++++++++++++++++++++=
++++++++
 include/linux/marvell_phy.h |  1 +
 2 files changed, 47 insertions(+)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index bd37e45c89c0..d2b2f2f795d5 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -118,6 +118,9 @@
=20
 #define MII_M1116R_CONTROL_REG_MAC	21
=20
+#define MII_88E3016_PHY_SPEC_CTRL	0x10
+#define MII_88E3016_DISABLE_SCRAMBLER	0x0200
+#define MII_88E3016_AUTO_MDIX_CROSSOVER	0x0030
=20
 MODULE_DESCRIPTION("Marvell PHY driver");
 MODULE_AUTHOR("Andy Fleming");
@@ -434,6 +437,25 @@ static int m88e1116r_config_init(struct phy_device=
 *phydev)
 	return 0;
 }
=20
+static int m88e3016_config_init(struct phy_device *phydev)
+{
+	int reg;
+
+	/* Enable Scrambler and Auto-Crossover */
+	reg =3D phy_read(phydev, MII_88E3016_PHY_SPEC_CTRL);
+	if (reg < 0)
+		return reg;
+
+	reg &=3D ~MII_88E3016_DISABLE_SCRAMBLER;
+	reg |=3D MII_88E3016_AUTO_MDIX_CROSSOVER;
+
+	reg =3D phy_write(phydev, MII_88E3016_PHY_SPEC_CTRL, reg);
+	if (reg < 0)
+		return reg;
+
+	return 0;
+}
+
 static int m88e1111_config_init(struct phy_device *phydev)
 {
 	int err;
@@ -770,6 +792,12 @@ static int marvell_read_status(struct phy_device *=
phydev)
 	return 0;
 }
=20
+static int marvell_aneg_done(struct phy_device *phydev)
+{
+	int retval =3D phy_read(phydev, MII_M1011_PHY_STATUS);
+	return (retval < 0) ? retval : (retval & MII_M1011_PHY_STATUS_RESOLVE=
D);
+}
+
 static int m88e1121_did_interrupt(struct phy_device *phydev)
 {
 	int imask;
@@ -1050,6 +1078,23 @@ static struct phy_driver marvell_drivers[] =3D {
 		.suspend =3D &genphy_suspend,
 		.driver =3D { .owner =3D THIS_MODULE },
 	},
+	{
+		.phy_id =3D MARVELL_PHY_ID_88E3016,
+		.phy_id_mask =3D MARVELL_PHY_ID_MASK,
+		.name =3D "Marvell 88E3016",
+		.features =3D PHY_BASIC_FEATURES,
+		.flags =3D PHY_HAS_INTERRUPT,
+		.config_aneg =3D &genphy_config_aneg,
+		.config_init =3D &m88e3016_config_init,
+		.aneg_done =3D &marvell_aneg_done,
+		.read_status =3D &marvell_read_status,
+		.ack_interrupt =3D &marvell_ack_interrupt,
+		.config_intr =3D &marvell_config_intr,
+		.did_interrupt =3D &m88e1121_did_interrupt,
+		.resume =3D &genphy_resume,
+		.suspend =3D &genphy_suspend,
+		.driver =3D { .owner =3D THIS_MODULE },
+	},
 };
=20
 static int __init marvell_init(void)
@@ -1079,6 +1124,7 @@ static struct mdio_device_id __maybe_unused marve=
ll_tbl[] =3D {
 	{ MARVELL_PHY_ID_88E1318S, MARVELL_PHY_ID_MASK },
 	{ MARVELL_PHY_ID_88E1116R, MARVELL_PHY_ID_MASK },
 	{ MARVELL_PHY_ID_88E1510, MARVELL_PHY_ID_MASK },
+	{ MARVELL_PHY_ID_88E3016, MARVELL_PHY_ID_MASK },
 	{ }
 };
=20
diff --git a/include/linux/marvell_phy.h b/include/linux/marvell_phy.h
index 8e9a029e093d..e6982ac3200d 100644
--- a/include/linux/marvell_phy.h
+++ b/include/linux/marvell_phy.h
@@ -16,6 +16,7 @@
 #define MARVELL_PHY_ID_88E1318S		0x01410e90
 #define MARVELL_PHY_ID_88E1116R		0x01410e40
 #define MARVELL_PHY_ID_88E1510		0x01410dd0
+#define MARVELL_PHY_ID_88E3016		0x01410e60
=20
 /* struct phy_device dev_flags definitions */
 #define MARVELL_PHY_M1145_FLAGS_RESISTANCE	0x00000001
--=20
2.1.1
