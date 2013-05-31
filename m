From: Michal Simek <michal.simek@xilinx.com>
Subject: [PATCH v2 4/5] phy: Add Marvell 88E1116R phy ID
Date: Fri, 31 May 2013 08:08:26 +0200
Message-ID: <fe731ed9f2d4fe71b44af91da7ef9cdc0d4ecdf1.1369980470.git.michal.simek@xilinx.com>
References: <cover.1369980470.git.michal.simek@xilinx.com>
Content-Type: multipart/signed;
    boundary="=_mimegpg-monstr-desktop-1714-1369980519-0001";
    micalg=pgp-sha1; protocol="application/pgp-signature"
Cc: Michal Simek <monstr@monstr.eu>,
	Michal Simek <michal.simek@xilinx.com>,
	"David S. Miller" <davem@davemloft.net>,
	Lars-Peter Clausen <lars@metafoo.de>,
	Christian Hohnstaedt <chohnstaedt@innominate.com>,
	Rick Hoover <RHoover@digilentinc.com>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	Steven Wang <steven.wang@digilentinc.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1369980470.git.michal.simek@xilinx.com>
In-Reply-To: <cover.1369980470.git.michal.simek@xilinx.com>
References: <cover.1369980470.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a MIME GnuPG-signed message.  If you see this text, it means that
your E-mail or Usenet software does not support MIME signed messages.
The Internet standard for MIME PGP messages, RFC 2015, was published in 1996.
To open this message correctly you will need to install E-mail or Usenet
software that supports modern Internet standards.

--=_mimegpg-monstr-desktop-1714-1369980519-0001

This phy is on Xilinx ZC702 zynq development board.

Signed-off-by: Anirudha Sarangi <anirudh@xilinx.com>
Signed-off-by: Michal Simek <michal.simek@xilinx.com>
---
Changes in v2: None

 drivers/net/phy/marvell.c   | 65 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/marvell_phy.h |  1 +
 2 files changed, 66 insertions(+)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 371353c..df5a9f6 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -116,6 +116,8 @@
 #define MII_M1011_PHY_STATUS_RESOLVED	0x0800
 #define MII_M1011_PHY_STATUS_LINK	0x0400

+#define MII_M1116R_CONTROL_REG_MAC	21
+

 MODULE_DESCRIPTION("Marvell PHY driver");
 MODULE_AUTHOR("Andy Fleming");
@@ -372,6 +374,55 @@ static int m88e1318_config_aneg(struct phy_device *phydev)
 	return m88e1121_config_aneg(phydev);
 }

+static int m88e1116r_config_init(struct phy_device *phydev)
+{
+	int temp;
+	int err;
+
+	temp = phy_read(phydev, MII_BMCR);
+	temp |= BMCR_RESET;
+	err = phy_write(phydev, MII_BMCR, temp);
+	if (err < 0)
+		return err;
+
+	mdelay(500);
+
+	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, 0);
+	if (err < 0)
+		return err;
+
+	temp = phy_read(phydev, MII_M1011_PHY_SCR);
+	temp |= (7 << 12);	/* max number of gigabit attempts */
+	temp |= (1 << 11);	/* enable downshift */
+	temp |= MII_M1011_PHY_SCR_AUTO_CROSS;
+	err = phy_write(phydev, MII_M1011_PHY_SCR, temp);
+	if (err < 0)
+		return err;
+
+	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, 2);
+	if (err < 0)
+		return err;
+	temp = phy_read(phydev, MII_M1116R_CONTROL_REG_MAC);
+	temp |= (1 << 5);
+	temp |= (1 << 4);
+	err = phy_write(phydev, MII_M1116R_CONTROL_REG_MAC, temp);
+	if (err < 0)
+		return err;
+	err = phy_write(phydev, MII_MARVELL_PHY_PAGE, 0);
+	if (err < 0)
+		return err;
+
+	temp = phy_read(phydev, MII_BMCR);
+	temp |= BMCR_RESET;
+	err = phy_write(phydev, MII_BMCR, temp);
+	if (err < 0)
+		return err;
+
+	mdelay(500);
+
+	return 0;
+}
+
 static int m88e1111_config_init(struct phy_device *phydev)
 {
 	int err;
@@ -940,6 +991,19 @@ static struct phy_driver marvell_drivers[] = {
 		.config_intr = &marvell_config_intr,
 		.driver = { .owner = THIS_MODULE },
 	},
+	{
+		.phy_id = MARVELL_PHY_ID_88E1116R,
+		.phy_id_mask = MARVELL_PHY_ID_MASK,
+		.name = "Marvell 88E1116R",
+		.features = PHY_GBIT_FEATURES,
+		.flags = PHY_HAS_INTERRUPT,
+		.config_init = &m88e1116r_config_init,
+		.config_aneg = &genphy_config_aneg,
+		.read_status = &genphy_read_status,
+		.ack_interrupt = &marvell_ack_interrupt,
+		.config_intr = &marvell_config_intr,
+		.driver = { .owner = THIS_MODULE },
+	},
 };

 static int __init marvell_init(void)
@@ -967,6 +1031,7 @@ static struct mdio_device_id __maybe_unused marvell_tbl[] = {
 	{ MARVELL_PHY_ID_88E1149R, MARVELL_PHY_ID_MASK },
 	{ MARVELL_PHY_ID_88E1240, MARVELL_PHY_ID_MASK },
 	{ MARVELL_PHY_ID_88E1318S, MARVELL_PHY_ID_MASK },
+	{ MARVELL_PHY_ID_88E1116R, MARVELL_PHY_ID_MASK },
 	{ }
 };

diff --git a/include/linux/marvell_phy.h b/include/linux/marvell_phy.h
index dd3c34e..ec41025 100644
--- a/include/linux/marvell_phy.h
+++ b/include/linux/marvell_phy.h
@@ -14,6 +14,7 @@
 #define MARVELL_PHY_ID_88E1149R		0x01410e50
 #define MARVELL_PHY_ID_88E1240		0x01410e30
 #define MARVELL_PHY_ID_88E1318S		0x01410e90
+#define MARVELL_PHY_ID_88E1116R		0x01410e40

 /* struct phy_device dev_flags definitions */
 #define MARVELL_PHY_M1145_FLAGS_RESISTANCE	0x00000001
--
1.8.2.3


--=_mimegpg-monstr-desktop-1714-1369980519-0001
Content-Type: application/pgp-signature
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEABECAAYFAlGoPmcACgkQykllyylKDCF1mwCfRj3Abq6qYDq1K9XwIYTsMfMF
YRcAn23BxoD4LvFdPA/2LyUJysAOfBG6
=1/S0
-----END PGP SIGNATURE-----

--=_mimegpg-monstr-desktop-1714-1369980519-0001--
