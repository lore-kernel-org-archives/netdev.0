From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 4/4] net: dsa: mv88e6xxx: implement DSA port fast ageing
Date: Thu, 22 Sep 2016 16:49:24 -0400
Message-ID: <20160922204924.16229-5-vivien.didelot@savoirfairelinux.com>
References: <20160922204924.16229-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, John Crispin <john@phrozen.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160922204924.16229-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that the DSA layer handles port fast ageing on correct STP change,
simplify _mv88e6xxx_port_state and implement mv88e6xxx_port_fast_age.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 45 ++++++++++++++++++++--------------------
 1 file changed, 23 insertions(+), 22 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 25bd3fa..122876c 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1133,31 +1133,18 @@ static int _mv88e6xxx_port_state(struct mv88e6xxx_chip *chip, int port,
 
 	oldstate = reg & PORT_CONTROL_STATE_MASK;
 
-	if (oldstate != state) {
-		/* Flush forwarding database if we're moving a port
-		 * from Learning or Forwarding state to Disabled or
-		 * Blocking or Listening state.
-		 */
-		if ((oldstate == PORT_CONTROL_STATE_LEARNING ||
-		     oldstate == PORT_CONTROL_STATE_FORWARDING) &&
-		    (state == PORT_CONTROL_STATE_DISABLED ||
-		     state == PORT_CONTROL_STATE_BLOCKING)) {
-			err = _mv88e6xxx_atu_remove(chip, 0, port, false);
-			if (err)
-				return err;
-		}
+	reg &= ~PORT_CONTROL_STATE_MASK;
+	reg |= state;
 
-		reg = (reg & ~PORT_CONTROL_STATE_MASK) | state;
-		err = mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
-		if (err)
-			return err;
+	err = mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
+	if (err)
+		return err;
 
-		netdev_dbg(ds->ports[port].netdev, "PortState %s (was %s)\n",
-			   mv88e6xxx_port_state_names[state],
-			   mv88e6xxx_port_state_names[oldstate]);
-	}
+	netdev_dbg(ds->ports[port].netdev, "PortState %s (was %s)\n",
+		   mv88e6xxx_port_state_names[state],
+		   mv88e6xxx_port_state_names[oldstate]);
 
-	return err;
+	return 0;
 }
 
 static int _mv88e6xxx_port_based_vlan_map(struct mv88e6xxx_chip *chip, int port)
@@ -1232,6 +1219,19 @@ static void mv88e6xxx_port_stp_state_set(struct dsa_switch *ds, int port,
 			   mv88e6xxx_port_state_names[stp_state]);
 }
 
+static void mv88e6xxx_port_fast_age(struct dsa_switch *ds, int port)
+{
+	struct mv88e6xxx_chip *chip = ds->priv;
+	int err;
+
+	mutex_lock(&chip->reg_lock);
+	err = _mv88e6xxx_atu_remove(chip, 0, port, false);
+	mutex_unlock(&chip->reg_lock);
+
+	if (err)
+		netdev_err(ds->ports[port].netdev, "failed to flush ATU\n");
+}
+
 static int _mv88e6xxx_port_pvid(struct mv88e6xxx_chip *chip, int port,
 				u16 *new, u16 *old)
 {
@@ -3684,6 +3684,7 @@ static struct dsa_switch_ops mv88e6xxx_switch_ops = {
 	.port_bridge_join	= mv88e6xxx_port_bridge_join,
 	.port_bridge_leave	= mv88e6xxx_port_bridge_leave,
 	.port_stp_state_set	= mv88e6xxx_port_stp_state_set,
+	.port_fast_age		= mv88e6xxx_port_fast_age,
 	.port_vlan_filtering	= mv88e6xxx_port_vlan_filtering,
 	.port_vlan_prepare	= mv88e6xxx_port_vlan_prepare,
 	.port_vlan_add		= mv88e6xxx_port_vlan_add,
-- 
2.10.0
