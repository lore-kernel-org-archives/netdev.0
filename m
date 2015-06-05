From: Jaeden Amero <jaeden.amero@ni.com>
Subject: [PATCH v4 3/3] net/phy: micrel: Center FLP timing at 16ms
Date: Fri, 5 Jun 2015 18:00:26 -0500
Message-ID: <1433545226-18324-4-git-send-email-jaeden.amero@ni.com>
References: <1433545226-18324-1-git-send-email-jaeden.amero@ni.com>
Cc: Jaeden Amero <jaeden.amero@ni.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433545226-18324-1-git-send-email-jaeden.amero@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Link failures have been observed when using the KSZ9031 with HP 1810-8G
and HP 1910-8G network switches. Center the FLP timing at 16ms to help
avoid intermittent link failures.

>From the KSZ9031RNX and KSZ9031MNX data sheets revision 2.2, section
"Auto-Negotiation Timing":
	The KSZ9031[RNX or MNX] Fast Link Pulse (FLP) burst-to-burst
	transmit timing for Auto-Negotiation defaults to 8ms. IEEE 802.3
	Standard specifies this timing to be 16ms +/-8ms. Some PHY link
	partners need to receive the FLP with 16ms centered timing;
	otherwise, there can be intermittent link failures and long
	link-up times.

The PHY data sheet recommends configuring the FLP burst registers after
power-up/reset and immediately thereafter restarting auto-negotiation, so
we center the FLP timing at 16ms and then restart auto-negotiation in the
config_init for KSZ9031.

Signed-off-by: Jaeden Amero <jaeden.amero@ni.com>
---
 drivers/net/phy/micrel.c | 23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index f23765e..499185e 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -366,6 +366,10 @@ static int ksz9021_config_init(struct phy_device *phydev)
 #define KSZ9031_PS_TO_REG		60
 
 /* Extended registers */
+/* MMD Address 0x0 */
+#define MII_KSZ9031RN_FLP_BURST_TX_LO	3
+#define MII_KSZ9031RN_FLP_BURST_TX_HI	4
+
 /* MMD Address 0x2 */
 #define MII_KSZ9031RN_CONTROL_PAD_SKEW	4
 #define MII_KSZ9031RN_RX_DATA_PAD_SKEW	5
@@ -427,6 +431,22 @@ static int ksz9031_of_load_skew_values(struct phy_device *phydev,
 	return ksz9031_extended_write(phydev, OP_DATA, 2, reg, newval);
 }
 
+static int ksz9031_center_flp_timing(struct phy_device *phydev)
+{
+	int result;
+
+	/* Center KSZ9031RNX FLP timing at 16ms. */
+	result = ksz9031_extended_write(phydev, OP_DATA, 0,
+					MII_KSZ9031RN_FLP_BURST_TX_HI, 0x0006);
+	result = ksz9031_extended_write(phydev, OP_DATA, 0,
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
 	const struct device *dev = &phydev->dev;
@@ -462,7 +482,8 @@ static int ksz9031_config_init(struct phy_device *phydev)
 				MII_KSZ9031RN_TX_DATA_PAD_SKEW, 4,
 				tx_data_skews, 4);
 	}
-	return 0;
+
+	return ksz9031_center_flp_timing(phydev);
 }
 
 #define KSZ8873MLL_GLOBAL_CONTROL_4	0x06
-- 
2.1.4
