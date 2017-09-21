From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH net-next 2/2] net: dsa: lan9303: Add basic offloading of unicast traffic
Date: Thu, 21 Sep 2017 11:41:39 +0200
Message-ID: <20170921094139.4250-3-privat@egil-hjelmeland.no>
References: <20170921094139.4250-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170921094139.4250-1-privat@egil-hjelmeland.no>
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
 drivers/net/dsa/lan9303-core.c | 88 ++++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/lan9303.h      |  1 +
 2 files changed, 89 insertions(+)

diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index bba875e114e7..76112674fe6a 100644
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
@@ -431,6 +433,20 @@ static int lan9303_read_switch_reg(struct lan9303 *chip, u16 regnum, u32 *val)
 	return ret;
 }
 
+static int lan9303_write_switch_reg_mask(
+	struct lan9303 *chip, u16 regnum, u32 val, u32 mask)
+{
+	int ret;
+	u32 reg;
+
+	ret = lan9303_read_switch_reg(chip, regnum, &reg);
+	if (ret)
+		return ret;
+	reg = (reg & ~mask) | val;
+
+	return lan9303_write_switch_reg(chip, regnum, reg);
+}
+
 static int lan9303_write_switch_port(struct lan9303 *chip, int port,
 				     u16 regnum, u32 val)
 {
@@ -556,6 +572,12 @@ static int lan9303_separate_ports(struct lan9303 *chip)
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
@@ -844,6 +866,69 @@ static void lan9303_port_disable(struct dsa_switch *ds, int port,
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
+		return; /* touching SWE_PORT_STATE will break port separation */
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
+	portstate     <<= (port * 2);
+	lan9303_write_switch_reg_mask(chip, LAN9303_SWE_PORT_STATE,
+				      portstate, portmask);
+}
+
 static const struct dsa_switch_ops lan9303_switch_ops = {
 	.get_tag_protocol = lan9303_get_tag_protocol,
 	.setup = lan9303_setup,
@@ -855,6 +940,9 @@ static const struct dsa_switch_ops lan9303_switch_ops = {
 	.get_sset_count = lan9303_get_sset_count,
 	.port_enable = lan9303_port_enable,
 	.port_disable = lan9303_port_disable,
+	.port_bridge_join       = lan9303_port_bridge_join,
+	.port_bridge_leave      = lan9303_port_bridge_leave,
+	.port_stp_state_set     = lan9303_port_stp_state_set,
 };
 
 static int lan9303_register_switch(struct lan9303 *chip)
diff --git a/drivers/net/dsa/lan9303.h b/drivers/net/dsa/lan9303.h
index 4d8be555ff4d..5be246f05965 100644
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
