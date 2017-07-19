From: Egil Hjelmeland <egil.hjelmeland@zenitel.com>
Subject: [PATCH 07/13] net: dsa: lan9303: Added basic offloading of unicast
 traffic
Date: Wed, 19 Jul 2017 14:32:45 +0200
Message-ID: <1b0633b15660414eaf4ede8ede468d14@nooslMX1.zenitelcss.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <egil.hjelmeland@zenitel.com>
To: <corbet@lwn.net>, <andrew@lunn.ch>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <davem@davemloft.net>, <kernel@pengutronix.de>,
        <linux-doc@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When both user ports are joined to the same bridge, the normal
HW MAC learning is enabled. This means that unicast traffic is forwarded
in HW. Support for STP is also added.

If one of the user ports leave the bridge,
the ports goes back to the initial separated operation.

Added brigde methods port_bridge_join, port_bridge_leave and
port_stp_state_set.

Signed-off-by: Egil Hjelmeland <egil.hjelmeland@zenitel.com>
---
 drivers/net/dsa/lan9303-core.c | 115 ++++++++++++++++++++++++++++++++++-------
 drivers/net/dsa/lan9303.h      |   1 +
 2 files changed, 98 insertions(+), 18 deletions(-)

diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index b70acb73aad6..426a75bd89f4 100644
--- a/drivers/net/dsa/lan9303-core.c
+++ b/drivers/net/dsa/lan9303-core.c
@@ -18,6 +18,7 @@
 #include <linux/mutex.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
+#include <linux/if_bridge.h>
 
 #include "lan9303.h"
 
@@ -143,6 +144,7 @@
 # define LAN9303_SWE_PORT_STATE_FORWARDING_PORT0 (0)
 # define LAN9303_SWE_PORT_STATE_LEARNING_PORT0 BIT(1)
 # define LAN9303_SWE_PORT_STATE_BLOCKING_PORT0 BIT(0)
+# define LAN9303_SWE_PORT_STATE_DISABLED_PORT0 (3)
 #define LAN9303_SWE_PORT_MIRROR 0x1846
 # define LAN9303_SWE_PORT_MIRROR_SNIFF_ALL BIT(8)
 # define LAN9303_SWE_PORT_MIRROR_SNIFFER_PORT2 BIT(7)
@@ -515,11 +517,30 @@ static int lan9303_enable_packet_processing(struct lan9303 *chip,
 			LAN9303_MAC_TX_CFG_X_TX_ENABLE);
 }
 
+/* forward special tagged packets from port 0 to port 1 *or* port 2 */
+static int lan9303_setup_tagging(struct lan9303 *chip)
+{
+	int ret;
+	/* enable defining the destination port via special VLAN tagging
+	 * for port 0
+	 */
+	ret = lan9303_write_switch_reg(chip, LAN9303_SWE_INGRESS_PORT_TYPE,
+				       0x03);
+	if (ret)
+		return ret;
+
+	/* tag incoming packets at port 1 and 2 on their way to port 0 to be
+	 * able to discover their source port
+	 */
+	return lan9303_write_switch_reg(
+		chip, LAN9303_BM_EGRSS_PORT_TYPE,
+		LAN9303_BM_EGRSS_PORT_TYPE_SPECIAL_TAG_PORT0);
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
@@ -534,22 +555,6 @@ static int lan9303_separate_ports(struct lan9303 *chip)
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
@@ -557,6 +562,12 @@ static int lan9303_separate_ports(struct lan9303 *chip)
 				LAN9303_SWE_PORT_STATE_BLOCKING_PORT2);
 }
 
+static void lan9303_bridge_ports(struct lan9303 *chip)
+{
+	/* ports bridged: remove mirroring */
+	lan9303_write_switch_reg(chip, LAN9303_SWE_PORT_MIRROR, 0);
+}
+
 static int lan9303_handle_reset(struct lan9303 *chip)
 {
 	if (!chip->reset_gpio)
@@ -707,6 +718,10 @@ static int lan9303_setup(struct dsa_switch *ds)
 		return -EINVAL;
 	}
 
+	ret = lan9303_setup_tagging(chip);
+	if (ret)
+		dev_err(chip->dev, "failed to setup port tagging %d\n", ret);
+
 	ret = lan9303_separate_ports(chip);
 	if (ret)
 		dev_err(chip->dev, "failed to separate ports %d\n", ret);
@@ -898,17 +913,81 @@ static void lan9303_port_disable(struct dsa_switch *ds, int port,
 	}
 }
 
+static int lan9303_port_bridge_join(struct dsa_switch *ds, int port,
+				    struct net_device *br)
+{
+	struct lan9303 *chip = ds->priv;
+
+	dev_dbg(chip->dev, "%s(port %d)\n", __func__, port);
+	if (ds->ports[1].bridge_dev ==  ds->ports[2].bridge_dev) {
+		lan9303_bridge_ports(chip);
+		chip->is_bridged = true;  /* unleash stp_state_set() */
+	}
+
+	return 0;
+}
+
+static void lan9303_port_bridge_leave(struct dsa_switch *ds, int port,
+				      struct net_device *br)
+{
+	struct lan9303 *chip = ds->priv;
+
+	dev_dbg(chip->dev, "%s(port %d)\n", __func__, port);
+	if (chip->is_bridged) {
+		lan9303_separate_ports(chip);
+		chip->is_bridged = false;
+	}
+}
+
+static void lan9303_port_stp_state_set(struct dsa_switch *ds, int port,
+				       u8 state)
+{
+	int portmask, portstate;
+	struct lan9303 *chip = ds->priv;
+
+	dev_dbg(chip->dev, "%s(port %d, state %d)\n",
+		__func__, port, state);
+	if (!chip->is_bridged)
+		return;
+
+	switch (state) {
+	case BR_STATE_DISABLED:
+		portstate = LAN9303_SWE_PORT_STATE_DISABLED_PORT0;
+		break;
+	case BR_STATE_BLOCKING:
+	case BR_STATE_LISTENING:
+		portstate = LAN9303_SWE_PORT_STATE_BLOCKING_PORT0;
+		break;
+	case BR_STATE_LEARNING:
+		portstate = LAN9303_SWE_PORT_STATE_LEARNING_PORT0;
+		break;
+	case BR_STATE_FORWARDING:
+		portstate = LAN9303_SWE_PORT_STATE_FORWARDING_PORT0;
+		break;
+	default:
+		dev_err(chip->dev, "%s(port %d, state %d)\n",
+			__func__, port, state);
+	}
+	portmask = 0x3 << (port * 2);
+	portstate     <<= (port * 2);
+	lan9303_write_switch_reg_mask(chip, LAN9303_SWE_PORT_STATE,
+				      portstate, portmask);
+}
+
 static struct dsa_switch_ops lan9303_switch_ops = {
 	.get_tag_protocol = lan9303_get_tag_protocol,
 	.setup = lan9303_setup,
-	.get_strings = lan9303_get_strings,
 	.phy_read = lan9303_phy_read,
 	.phy_write = lan9303_phy_write,
 	.adjust_link = lan9303_adjust_link,
+	.get_strings = lan9303_get_strings,
 	.get_ethtool_stats = lan9303_get_ethtool_stats,
 	.get_sset_count = lan9303_get_sset_count,
 	.port_enable = lan9303_port_enable,
 	.port_disable = lan9303_port_disable,
+	.port_bridge_join       = lan9303_port_bridge_join,
+	.port_bridge_leave      = lan9303_port_bridge_leave,
+	.port_stp_state_set     = lan9303_port_stp_state_set,
 };
 
 static int lan9303_register_switch(struct lan9303 *chip)
diff --git a/drivers/net/dsa/lan9303.h b/drivers/net/dsa/lan9303.h
index 444d00b460e1..2d74d02c9cef 100644
--- a/drivers/net/dsa/lan9303.h
+++ b/drivers/net/dsa/lan9303.h
@@ -21,6 +21,7 @@ struct lan9303 {
 	struct dsa_switch *ds;
 	struct mutex indirect_mutex; /* protect indexed register access */
 	const struct lan9303_phy_ops *ops;
+	bool is_bridged; /* true if port 1 and 2 is bridged */
 };
 
 extern const struct regmap_access_table lan9303_register_set;
-- 
2.11.0


DISCLAIMER:
This e-mail may contain confidential and privileged material for the sole use of the intended recipient. Any review, use, distribution or disclosure by others is strictly prohibited. If you are not the intended recipient (or authorized to receive for the recipient), please contact the sender by reply e-mail and delete all copies of this message.
