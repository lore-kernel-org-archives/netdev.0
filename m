From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH v2 net-next 1/2] net: dsa: lan9303: Move tag setup to new lan9303_setup_tagging
Date: Tue, 10 Oct 2017 14:49:52 +0200
Message-ID: <20171010124953.386-2-privat@egil-hjelmeland.no>
References: <20171010124953.386-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171010124953.386-1-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Prepare for next patch:
Move tag setup from lan9303_separate_ports() to new function
lan9303_setup_tagging()

Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
---
 drivers/net/dsa/lan9303-core.c | 42 +++++++++++++++++++++++++-----------------
 1 file changed, 25 insertions(+), 17 deletions(-)

diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index 07355db2ad81..2215ec1fbe1e 100644
--- a/drivers/net/dsa/lan9303-core.c
+++ b/drivers/net/dsa/lan9303-core.c
@@ -157,6 +157,7 @@
 # define LAN9303_SWE_PORT_MIRROR_ENABLE_RX_MIRRORING BIT(1)
 # define LAN9303_SWE_PORT_MIRROR_ENABLE_TX_MIRRORING BIT(0)
 #define LAN9303_SWE_INGRESS_PORT_TYPE 0x1847
+#define  LAN9303_SWE_INGRESS_PORT_TYPE_VLAN 3
 #define LAN9303_BM_CFG 0x1c00
 #define LAN9303_BM_EGRSS_PORT_TYPE 0x1c0c
 # define LAN9303_BM_EGRSS_PORT_TYPE_SPECIAL_TAG_PORT2 (BIT(17) | BIT(16))
@@ -510,11 +511,30 @@ static int lan9303_enable_processing_port(struct lan9303 *chip,
 				LAN9303_MAC_TX_CFG_X_TX_ENABLE);
 }
 
+/* forward special tagged packets from port 0 to port 1 *or* port 2 */
+static int lan9303_setup_tagging(struct lan9303 *chip)
+{
+	int ret;
+	u32 val;
+	/* enable defining the destination port via special VLAN tagging
+	 * for port 0
+	 */
+	ret = lan9303_write_switch_reg(chip, LAN9303_SWE_INGRESS_PORT_TYPE,
+				       LAN9303_SWE_INGRESS_PORT_TYPE_VLAN);
+	if (ret)
+		return ret;
+
+	/* tag incoming packets at port 1 and 2 on their way to port 0 to be
+	 * able to discover their source port
+	 */
+	val = LAN9303_BM_EGRSS_PORT_TYPE_SPECIAL_TAG_PORT0;
+	return lan9303_write_switch_reg(chip, LAN9303_BM_EGRSS_PORT_TYPE, val);
+}
+
 /* We want a special working switch:
  * - do not forward packets between port 1 and 2
  * - forward everything from port 1 to port 0
  * - forward everything from port 2 to port 0
- * - forward special tagged packets from port 0 to port 1 *or* port 2
  */
 static int lan9303_separate_ports(struct lan9303 *chip)
 {
@@ -529,22 +549,6 @@ static int lan9303_separate_ports(struct lan9303 *chip)
 	if (ret)
 		return ret;
 
-	/* enable defining the destination port via special VLAN tagging
-	 * for port 0
-	 */
-	ret = lan9303_write_switch_reg(chip, LAN9303_SWE_INGRESS_PORT_TYPE,
-				       0x03);
-	if (ret)
-		return ret;
-
-	/* tag incoming packets at port 1 and 2 on their way to port 0 to be
-	 * able to discover their source port
-	 */
-	ret = lan9303_write_switch_reg(chip, LAN9303_BM_EGRSS_PORT_TYPE,
-			LAN9303_BM_EGRSS_PORT_TYPE_SPECIAL_TAG_PORT0);
-	if (ret)
-		return ret;
-
 	/* prevent port 1 and 2 from forwarding packets by their own */
 	return lan9303_write_switch_reg(chip, LAN9303_SWE_PORT_STATE,
 				LAN9303_SWE_PORT_STATE_FORWARDING_PORT0 |
@@ -644,6 +648,10 @@ static int lan9303_setup(struct dsa_switch *ds)
 		return -EINVAL;
 	}
 
+	ret = lan9303_setup_tagging(chip);
+	if (ret)
+		dev_err(chip->dev, "failed to setup port tagging %d\n", ret);
+
 	ret = lan9303_separate_ports(chip);
 	if (ret)
 		dev_err(chip->dev, "failed to separate ports %d\n", ret);
-- 
2.11.0
