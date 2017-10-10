From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH v2 net-next 2/2] net: dsa: lan9303: Add basic offloading of unicast traffic
Date: Tue, 10 Oct 2017 14:49:53 +0200
Message-ID: <20171010124953.386-3-privat@egil-hjelmeland.no>
References: <20171010124953.386-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171010124953.386-1-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When both user ports are joined to the same bridge, the normal
HW MAC learning is enabled. This means that unicast traffic is forwarded
in HW.

If one of the user ports leave the bridge,
the ports goes back to the initial separated operation.

Port separation relies on disabled HW MAC learning. Hence the condition
that both ports must join same bridge.

Add brigde methods port_bridge_join, port_bridge_leave and
port_stp_state_set.

Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
---
 drivers/net/dsa/lan9303-core.c | 82 ++++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/lan9303.h      |  2 ++
 2 files changed, 84 insertions(+)

diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index 2215ec1fbe1e..fecfe1fe67ea 100644
--- a/drivers/net/dsa/lan9303-core.c
+++ b/drivers/net/dsa/lan9303-core.c
@@ -18,6 +18,7 @@
 #include <linux/mutex.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
+#include <linux/if_bridge.h>
 
 #include "lan9303.h"
 
@@ -146,6 +147,7 @@
 # define LAN9303_SWE_PORT_STATE_FORWARDING_PORT0 (0)
 # define LAN9303_SWE_PORT_STATE_LEARNING_PORT0 BIT(1)
 # define LAN9303_SWE_PORT_STATE_BLOCKING_PORT0 BIT(0)
+# define LAN9303_SWE_PORT_STATE_DISABLED_PORT0 (3)
 #define LAN9303_SWE_PORT_MIRROR 0x1846
 # define LAN9303_SWE_PORT_MIRROR_SNIFF_ALL BIT(8)
 # define LAN9303_SWE_PORT_MIRROR_SNIFFER_PORT2 BIT(7)
@@ -156,6 +158,7 @@
 # define LAN9303_SWE_PORT_MIRROR_MIRRORED_PORT0 BIT(2)
 # define LAN9303_SWE_PORT_MIRROR_ENABLE_RX_MIRRORING BIT(1)
 # define LAN9303_SWE_PORT_MIRROR_ENABLE_TX_MIRRORING BIT(0)
+# define LAN9303_SWE_PORT_MIRROR_DISABLED 0
 #define LAN9303_SWE_INGRESS_PORT_TYPE 0x1847
 #define  LAN9303_SWE_INGRESS_PORT_TYPE_VLAN 3
 #define LAN9303_BM_CFG 0x1c00
@@ -556,6 +559,16 @@ static int lan9303_separate_ports(struct lan9303 *chip)
 				LAN9303_SWE_PORT_STATE_BLOCKING_PORT2);
 }
 
+static void lan9303_bridge_ports(struct lan9303 *chip)
+{
+	/* ports bridged: remove mirroring */
+	lan9303_write_switch_reg(chip, LAN9303_SWE_PORT_MIRROR,
+				 LAN9303_SWE_PORT_MIRROR_DISABLED);
+
+	lan9303_write_switch_reg(chip, LAN9303_SWE_PORT_STATE,
+				 chip->swe_port_state);
+}
+
 static int lan9303_handle_reset(struct lan9303 *chip)
 {
 	if (!chip->reset_gpio)
@@ -844,6 +857,72 @@ static void lan9303_port_disable(struct dsa_switch *ds, int port,
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
+		portstate = LAN9303_SWE_PORT_STATE_DISABLED_PORT0;
+		dev_err(chip->dev, "unknown stp state: port %d, state %d\n",
+			port, state);
+	}
+
+	portmask = 0x3 << (port * 2);
+	portstate <<= (port * 2);
+
+	chip->swe_port_state = (chip->swe_port_state & ~portmask) | portstate;
+
+	if (chip->is_bridged)
+		lan9303_write_switch_reg(chip, LAN9303_SWE_PORT_STATE,
+					 chip->swe_port_state);
+	/* else: touching SWE_PORT_STATE would break port separation */
+}
+
 static const struct dsa_switch_ops lan9303_switch_ops = {
 	.get_tag_protocol = lan9303_get_tag_protocol,
 	.setup = lan9303_setup,
@@ -855,6 +934,9 @@ static const struct dsa_switch_ops lan9303_switch_ops = {
 	.get_sset_count = lan9303_get_sset_count,
 	.port_enable = lan9303_port_enable,
 	.port_disable = lan9303_port_disable,
+	.port_bridge_join       = lan9303_port_bridge_join,
+	.port_bridge_leave      = lan9303_port_bridge_leave,
+	.port_stp_state_set     = lan9303_port_stp_state_set,
 };
 
 static int lan9303_register_switch(struct lan9303 *chip)
diff --git a/drivers/net/dsa/lan9303.h b/drivers/net/dsa/lan9303.h
index 4d8be555ff4d..68ecd544b658 100644
--- a/drivers/net/dsa/lan9303.h
+++ b/drivers/net/dsa/lan9303.h
@@ -21,6 +21,8 @@ struct lan9303 {
 	struct dsa_switch *ds;
 	struct mutex indirect_mutex; /* protect indexed register access */
 	const struct lan9303_phy_ops *ops;
+	bool is_bridged; /* true if port 1 and 2 are bridged */
+	u32 swe_port_state; /* remember SWE_PORT_STATE while not bridged */
 };
 
 extern const struct regmap_access_table lan9303_register_set;
-- 
2.11.0
