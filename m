From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH v4 net-next 5/5] net: dsa: lan9303: refactor lan9303_get_ethtool_stats
Date: Sat,  5 Aug 2017 13:05:50 +0200
Message-ID: <20170805110550.26337-6-privat@egil-hjelmeland.no>
References: <20170805110550.26337-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170805110550.26337-1-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In lan9303_get_ethtool_stats: Get rid of 0x400 constant magic
by using new lan9303_read_switch_reg() inside loop.
Reduced scope of two variables.

Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/lan9303-core.c | 26 ++++++++++++++++----------
 1 file changed, 16 insertions(+), 10 deletions(-)

diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index 444958bb19f6..15befd155251 100644
--- a/drivers/net/dsa/lan9303-core.c
+++ b/drivers/net/dsa/lan9303-core.c
@@ -435,6 +435,13 @@ static int lan9303_write_switch_port(struct lan9303 *chip, int port,
 		chip, LAN9303_SWITCH_PORT_REG(port, regnum), val);
 }
 
+static int lan9303_read_switch_port(struct lan9303 *chip, int port,
+				    u16 regnum, u32 *val)
+{
+	return lan9303_read_switch_reg(
+		chip, LAN9303_SWITCH_PORT_REG(port, regnum), val);
+}
+
 static int lan9303_detect_phy_setup(struct lan9303 *chip)
 {
 	int reg;
@@ -705,19 +712,18 @@ static void lan9303_get_ethtool_stats(struct dsa_switch *ds, int port,
 				      uint64_t *data)
 {
 	struct lan9303 *chip = ds->priv;
-	u32 reg;
-	unsigned int u, poff;
-	int ret;
-
-	poff = port * 0x400;
+	unsigned int u;
 
 	for (u = 0; u < ARRAY_SIZE(lan9303_mib); u++) {
-		ret = lan9303_read_switch_reg(chip,
-					      lan9303_mib[u].offset + poff,
-					      &reg);
+		u32 reg;
+		int ret;
+
+		ret = lan9303_read_switch_port(
+			chip, port, lan9303_mib[u].offset, &reg);
+
 		if (ret)
-			dev_warn(chip->dev, "Reading status reg %u failed\n",
-				 lan9303_mib[u].offset + poff);
+			dev_warn(chip->dev, "Reading status port %d reg %u failed\n",
+				 port, lan9303_mib[u].offset);
 		data[u] = reg;
 	}
 }
-- 
2.11.0
