From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 7/9] net: dsa: mv88e6xxx: use dsa_port's bridge pointer
Date: Fri, 27 Jan 2017 15:29:42 -0500
Message-ID: <20170127202944.28598-8-vivien.didelot@savoirfairelinux.com>
References: <20170127202944.28598-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, John Crispin <john@phrozen.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170127202944.28598-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that DSA exposes the bridge device pointer to which a port belongs,
use it when programming the port based VLANs and thus remove the cache.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 27 +++++++++++----------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  6 ------
 2 files changed, 11 insertions(+), 22 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 8eb0dc063f4e..84cba32443de 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1247,8 +1247,8 @@ static int _mv88e6xxx_atu_remove(struct mv88e6xxx_chip *chip, u16 fid,
 
 static int _mv88e6xxx_port_based_vlan_map(struct mv88e6xxx_chip *chip, int port)
 {
-	struct net_device *bridge = chip->ports[port].bridge_dev;
 	struct dsa_switch *ds = chip->ds;
+	struct net_device *bridge = ds->ports[port].bridge_dev;
 	u16 output_ports = 0;
 	int i;
 
@@ -1258,7 +1258,7 @@ static int _mv88e6xxx_port_based_vlan_map(struct mv88e6xxx_chip *chip, int port)
 	} else {
 		for (i = 0; i < mv88e6xxx_num_ports(chip); ++i) {
 			/* allow sending frames to every group member */
-			if (bridge && chip->ports[i].bridge_dev == bridge)
+			if (bridge && ds->ports[i].bridge_dev == bridge)
 				output_ports |= BIT(i);
 
 			/* allow sending frames to CPU port and DSA link(s) */
@@ -1820,17 +1820,17 @@ static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 			    GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER)
 				continue;
 
-			if (chip->ports[i].bridge_dev ==
-			    chip->ports[port].bridge_dev)
+			if (ds->ports[i].bridge_dev ==
+			    ds->ports[port].bridge_dev)
 				break; /* same bridge, check next VLAN */
 
-			if (!chip->ports[i].bridge_dev)
+			if (!ds->ports[i].bridge_dev)
 				continue;
 
 			netdev_warn(ds->ports[port].netdev,
 				    "hardware VLAN %d already used by %s\n",
 				    vlan.vid,
-				    netdev_name(chip->ports[i].bridge_dev));
+				    netdev_name(ds->ports[i].bridge_dev));
 			err = -EOPNOTSUPP;
 			goto unlock;
 		}
@@ -2320,18 +2320,16 @@ static int mv88e6xxx_port_fdb_dump(struct dsa_switch *ds, int port,
 }
 
 static int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port,
-				      struct net_device *bridge)
+				      struct net_device *br)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
 	int i, err = 0;
 
 	mutex_lock(&chip->reg_lock);
 
-	/* Assign the bridge and remap each port's VLANTable */
-	chip->ports[port].bridge_dev = bridge;
-
+	/* Remap each port's VLANTable */
 	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i) {
-		if (chip->ports[i].bridge_dev == bridge) {
+		if (ds->ports[i].bridge_dev == br) {
 			err = _mv88e6xxx_port_based_vlan_map(chip, i);
 			if (err)
 				break;
@@ -2347,16 +2345,13 @@ static void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port,
 					struct net_device *br)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
-	struct net_device *bridge = chip->ports[port].bridge_dev;
 	int i;
 
 	mutex_lock(&chip->reg_lock);
 
-	/* Unassign the bridge and remap each port's VLANTable */
-	chip->ports[port].bridge_dev = NULL;
-
+	/* Remap each port's VLANTable */
 	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i)
-		if (i == port || chip->ports[i].bridge_dev == bridge)
+		if (i == port || ds->ports[i].bridge_dev == br)
 			if (_mv88e6xxx_port_based_vlan_map(chip, i))
 				netdev_warn(ds->ports[i].netdev,
 					    "failed to remap\n");
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 572d585dc1e2..e126ed00937b 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -676,10 +676,6 @@ struct mv88e6xxx_vtu_entry {
 
 struct mv88e6xxx_bus_ops;
 
-struct mv88e6xxx_priv_port {
-	struct net_device *bridge_dev;
-};
-
 struct mv88e6xxx_irq {
 	u16 masked;
 	struct irq_chip chip;
@@ -720,8 +716,6 @@ struct mv88e6xxx_chip {
 	 */
 	struct mutex	stats_mutex;
 
-	struct mv88e6xxx_priv_port	ports[DSA_MAX_PORTS];
-
 	/* A switch may have a GPIO line tied to its reset pin. Parse
 	 * this from the device tree, and use it before performing
 	 * switch soft reset.
-- 
2.11.0
