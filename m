From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 3/7] net: dsa: mv88e6xxx: use bridge state values
Date: Thu,  8 Jun 2017 18:34:10 -0400
Message-ID: <20170608223414.594-4-vivien.didelot@savoirfairelinux.com>
References: <20170608223414.594-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170608223414.594-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reuse the BR_STATE_* values to abstract a port STP state value.

This provides shorter names and better control over the DSA switch
operation call.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 23 ++---------------------
 drivers/net/dsa/mv88e6xxx/port.c | 20 ++++++++++++++++++++
 2 files changed, 22 insertions(+), 21 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index b610429f7516..e25d48ecf880 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -915,28 +915,10 @@ static void mv88e6xxx_port_stp_state_set(struct dsa_switch *ds, int port,
 					 u8 state)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
-	int stp_state;
 	int err;
 
-	switch (state) {
-	case BR_STATE_DISABLED:
-		stp_state = PORT_CONTROL_STATE_DISABLED;
-		break;
-	case BR_STATE_BLOCKING:
-	case BR_STATE_LISTENING:
-		stp_state = PORT_CONTROL_STATE_BLOCKING;
-		break;
-	case BR_STATE_LEARNING:
-		stp_state = PORT_CONTROL_STATE_LEARNING;
-		break;
-	case BR_STATE_FORWARDING:
-	default:
-		stp_state = PORT_CONTROL_STATE_FORWARDING;
-		break;
-	}
-
 	mutex_lock(&chip->reg_lock);
-	err = mv88e6xxx_port_set_state(chip, port, stp_state);
+	err = mv88e6xxx_port_set_state(chip, port, state);
 	mutex_unlock(&chip->reg_lock);
 
 	if (err)
@@ -1694,8 +1676,7 @@ static int mv88e6xxx_disable_ports(struct mv88e6xxx_chip *chip)
 
 	/* Set all ports to the Disabled state */
 	for (i = 0; i < mv88e6xxx_num_ports(chip); i++) {
-		err = mv88e6xxx_port_set_state(chip, i,
-					       PORT_CONTROL_STATE_DISABLED);
+		err = mv88e6xxx_port_set_state(chip, i, BR_STATE_DISABLED);
 		if (err)
 			return err;
 	}
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 09e17131a6bd..46e73ca0ac4d 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -12,6 +12,7 @@
  * (at your option) any later version.
  */
 
+#include <linux/if_bridge.h>
 #include <linux/phy.h>
 
 #include "chip.h"
@@ -412,6 +413,25 @@ int mv88e6xxx_port_set_state(struct mv88e6xxx_chip *chip, int port, u8 state)
 		return err;
 
 	reg &= ~PORT_CONTROL_STATE_MASK;
+
+	switch (state) {
+	case BR_STATE_DISABLED:
+		state = PORT_CONTROL_STATE_DISABLED;
+		break;
+	case BR_STATE_BLOCKING:
+	case BR_STATE_LISTENING:
+		state = PORT_CONTROL_STATE_BLOCKING;
+		break;
+	case BR_STATE_LEARNING:
+		state = PORT_CONTROL_STATE_LEARNING;
+		break;
+	case BR_STATE_FORWARDING:
+		state = PORT_CONTROL_STATE_FORWARDING;
+		break;
+	default:
+		return -EINVAL;
+	}
+
 	reg |= state;
 
 	err = mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
-- 
2.13.1
