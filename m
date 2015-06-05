From: Jaeden Amero <jaeden.amero@ni.com>
Subject: [PATCH v2 3/3] net/phy: micrel: Center FLP timing at 16ms
Date: Fri, 5 Jun 2015 14:55:30 -0500
Message-ID: <1433534130-16323-4-git-send-email-jaeden.amero@ni.com>
References: <1433534130-16323-1-git-send-email-jaeden.amero@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jaeden Amero <jaeden.amero@ni.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433534130-16323-1-git-send-email-jaeden.amero@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Link failures have been observed when using the KSZ9031 with HP 1810-8G
and HP 1910-8G network switches. Center the FLP timing at 16ms to help
avoid intermittent link failures.

=46rom the KSZ9031RNX and KSZ9031MNX data sheets revision 2.2, section
"Auto-Negotiation Timing":
	The KSZ9031[RNX or MNX] Fast Link Pulse (FLP) burst-to-burst
	transmit timing for Auto-Negotiation defaults to 8ms. IEEE 802.3
	Standard specifies this timing to be 16ms +/-8ms. Some PHY link
	partners need to receive the FLP with 16ms centered timing;
	otherwise, there can be intermittent link failures and long
	link-up times.

	After KSZ9031[RNX or MNX] power-up/reset, program the following
	register sequence to set the FLP timing to 16ms

	Write Register Dh =3D 0x0000 // Set up register address for MMD =E2=80=
=93 Device Address 0h
	Write Register Eh =3D 0x0004 // Select Register 4h of MMD =E2=80=93 De=
vice Address 0h
	Write Register Dh =3D 0x4000 // Select register data for MMD =E2=80=93=
 Device Address 0h, Register 4h
	Write Register Eh =3D 0x0006 // Write value 0x0006 to MMD =E2=80=93 De=
vice Address 0h, Register 4h
	Write Register Dh =3D 0x0000 // Set up register address for MMD =E2=80=
=93 Device Address 0h
	Write Register Eh =3D 0x0003 // Select Register 3h of MMD =E2=80=93 De=
vice Address 0h
	Write Register Dh =3D 0x4000 // Select register data for MMD =E2=80=93=
 Device Address 0h, Register 3h
	Write Register Eh =3D 0x1A80 // Write value 0x1A80 to MMD =E2=80=93 De=
vice Address 0h, Register 3h
	Write Register 0h, Bit [9] =3D 1 // Restart Auto-Negotiation

Signed-off-by: Jaeden Amero <jaeden.amero@ni.com>
---
 drivers/net/phy/micrel.c | 26 +++++++++++++++++++++++++-
 1 file changed, 25 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index f23765e..e156e36 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -366,6 +366,10 @@ static int ksz9021_config_init(struct phy_device *=
phydev)
 #define KSZ9031_PS_TO_REG		60
=20
 /* Extended registers */
+/* MMD Address 0x0 */
+#define MII_KSZ9031RN_FLP_BURST_TX_LO	3
+#define MII_KSZ9031RN_FLP_BURST_TX_HI	4
+
 /* MMD Address 0x2 */
 #define MII_KSZ9031RN_CONTROL_PAD_SKEW	4
 #define MII_KSZ9031RN_RX_DATA_PAD_SKEW	5
@@ -427,6 +431,22 @@ static int ksz9031_of_load_skew_values(struct phy_=
device *phydev,
 	return ksz9031_extended_write(phydev, OP_DATA, 2, reg, newval);
 }
=20
+static int ksz9031_center_flp_timing(struct phy_device *phydev)
+{
+	int result;
+
+	/* Center KSZ9031RNX FLP timing at 16ms. */
+	result =3D ksz9031_extended_write(phydev, OP_DATA, 0,
+					MII_KSZ9031RN_FLP_BURST_TX_HI, 0x0006);
+	result =3D ksz9031_extended_write(phydev, OP_DATA, 0,
+					MII_KSZ9031RN_FLP_BURST_TX_LO, 0x1A80);
+
+	if (result)
+		return result;
+
+	return genphy_restart_aneg(phydev);
+}
+
 static int ksz9031_config_init(struct phy_device *phydev)
 {
 	const struct device *dev =3D &phydev->dev;
@@ -441,6 +461,7 @@ static int ksz9031_config_init(struct phy_device *p=
hydev)
 		"txd2-skew-ps", "txd3-skew-ps"
 	};
 	static const char *control_skews[2] =3D {"txen-skew-ps", "rxdv-skew-p=
s"};
+	int result;
=20
 	if (!of_node && dev->parent->of_node)
 		of_node =3D dev->parent->of_node;
@@ -462,7 +483,10 @@ static int ksz9031_config_init(struct phy_device *=
phydev)
 				MII_KSZ9031RN_TX_DATA_PAD_SKEW, 4,
 				tx_data_skews, 4);
 	}
-	return 0;
+
+	result =3D ksz9031_center_flp_timing(phydev);
+
+	return result;
 }
=20
 #define KSZ8873MLL_GLOBAL_CONTROL_4	0x06
--=20
2.1.4
