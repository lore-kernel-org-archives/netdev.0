From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 1/7] net: dsa: mv888e6xxx: do not use netdev printing
Date: Thu,  8 Jun 2017 18:34:08 -0400
Message-ID: <20170608223414.594-2-vivien.didelot@savoirfairelinux.com>
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

The mv888e6xxx driver accesses a port's netdev mostly for printing.

This is bad for 2 reasons: DSA and CPU ports do not have a netdev
pointer; it doesn't give us a correct picture of why a DSA driver might
need to access a port's netdev.

Instead simply use dev_* printing functions with chip->dev (or ds->dev
depending on the scope, both guaranteed to exist), with a p%d prefix for
the target port.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 31 +++++++++++++++----------------
 drivers/net/dsa/mv88e6xxx/port.c | 39 ++++++++++++++++++---------------------
 2 files changed, 33 insertions(+), 37 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 0534eb706caa..bf7ad2e8b4d7 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -489,8 +489,7 @@ static int mv88e6xxx_port_setup_mac(struct mv88e6xxx_chip *chip, int port,
 	err = 0;
 restore_link:
 	if (chip->info->ops->port_set_link(chip, port, link))
-		netdev_err(chip->ds->ports[port].netdev,
-			   "failed to restore MAC's link\n");
+		dev_err(chip->dev, "p%d: failed to restore MAC's link\n", port);
 
 	return err;
 }
@@ -514,7 +513,7 @@ static void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
 	mutex_unlock(&chip->reg_lock);
 
 	if (err && err != -EOPNOTSUPP)
-		netdev_err(ds->ports[port].netdev, "failed to configure MAC\n");
+		dev_err(ds->dev, "p%d: failed to configure MAC\n", port);
 }
 
 static int mv88e6xxx_stats_snapshot(struct mv88e6xxx_chip *chip, int port)
@@ -941,7 +940,7 @@ static void mv88e6xxx_port_stp_state_set(struct dsa_switch *ds, int port,
 	mutex_unlock(&chip->reg_lock);
 
 	if (err)
-		netdev_err(ds->ports[port].netdev, "failed to update state\n");
+		dev_err(ds->dev, "p%d: failed to update state\n", port);
 }
 
 static int mv88e6xxx_atu_setup(struct mv88e6xxx_chip *chip)
@@ -1009,7 +1008,7 @@ static void mv88e6xxx_port_fast_age(struct dsa_switch *ds, int port)
 	mutex_unlock(&chip->reg_lock);
 
 	if (err)
-		netdev_err(ds->ports[port].netdev, "failed to flush ATU\n");
+		dev_err(ds->dev, "p%d: failed to flush ATU\n", port);
 }
 
 static int mv88e6xxx_vtu_setup(struct mv88e6xxx_chip *chip)
@@ -1214,10 +1213,9 @@ static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 			if (!ds->ports[i].bridge_dev)
 				continue;
 
-			netdev_warn(ds->ports[port].netdev,
-				    "hardware VLAN %d already used by %s\n",
-				    vlan.vid,
-				    netdev_name(ds->ports[i].bridge_dev));
+			dev_err(ds->dev, "p%d: hw VLAN %d already used by %s\n",
+				port, vlan.vid,
+				netdev_name(ds->ports[i].bridge_dev));
 			err = -EOPNOTSUPP;
 			goto unlock;
 		}
@@ -1311,13 +1309,12 @@ static void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
 
 	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid)
 		if (_mv88e6xxx_port_vlan_add(chip, port, vid, member))
-			netdev_err(ds->ports[port].netdev,
-				   "failed to add VLAN %d%c\n",
-				   vid, untagged ? 'u' : 't');
+			dev_err(ds->dev, "p%d: failed to add VLAN %d%c\n", port,
+				vid, untagged ? 'u' : 't');
 
 	if (pvid && mv88e6xxx_port_set_pvid(chip, port, vlan->vid_end))
-		netdev_err(ds->ports[port].netdev, "failed to set PVID %d\n",
-			   vlan->vid_end);
+		dev_err(ds->dev, "p%d: failed to set PVID %d\n", port,
+			vlan->vid_end);
 
 	mutex_unlock(&chip->reg_lock);
 }
@@ -1451,7 +1448,8 @@ static void mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 	mutex_lock(&chip->reg_lock);
 	if (mv88e6xxx_port_db_load_purge(chip, port, fdb->addr, fdb->vid,
 					 GLOBAL_ATU_DATA_STATE_UC_STATIC))
-		netdev_err(ds->ports[port].netdev, "failed to load unicast MAC address\n");
+		dev_err(ds->dev, "p%d: failed to load unicast MAC address\n",
+			port);
 	mutex_unlock(&chip->reg_lock);
 }
 
@@ -3793,7 +3791,8 @@ static void mv88e6xxx_port_mdb_add(struct dsa_switch *ds, int port,
 	mutex_lock(&chip->reg_lock);
 	if (mv88e6xxx_port_db_load_purge(chip, port, mdb->addr, mdb->vid,
 					 GLOBAL_ATU_DATA_STATE_MC_STATIC))
-		netdev_err(ds->ports[port].netdev, "failed to load multicast MAC address\n");
+		dev_err(ds->dev, "p%d: failed to load multicast MAC address\n",
+			port);
 	mutex_unlock(&chip->reg_lock);
 }
 
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 3719ece60c61..fc09b26f9b49 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -76,9 +76,9 @@ static int mv88e6xxx_port_set_rgmii_delay(struct mv88e6xxx_chip *chip, int port,
 	if (err)
 		return err;
 
-	netdev_dbg(chip->ds->ports[port].netdev, "delay RXCLK %s, TXCLK %s\n",
-		   reg & PORT_PCS_CTRL_RGMII_DELAY_RXCLK ? "yes" : "no",
-		   reg & PORT_PCS_CTRL_RGMII_DELAY_TXCLK ? "yes" : "no");
+	dev_dbg(chip->dev, "p%d: delay RXCLK %s, TXCLK %s\n", port,
+		reg & PORT_PCS_CTRL_RGMII_DELAY_RXCLK ? "yes" : "no",
+		reg & PORT_PCS_CTRL_RGMII_DELAY_TXCLK ? "yes" : "no");
 
 	return 0;
 }
@@ -130,9 +130,9 @@ int mv88e6xxx_port_set_link(struct mv88e6xxx_chip *chip, int port, int link)
 	if (err)
 		return err;
 
-	netdev_dbg(chip->ds->ports[port].netdev, "%s link %s\n",
-		   reg & PORT_PCS_CTRL_FORCE_LINK ? "Force" : "Unforce",
-		   reg & PORT_PCS_CTRL_LINK_UP ? "up" : "down");
+	dev_dbg(chip->dev, "p%d: %s link %s\n", port,
+		reg & PORT_PCS_CTRL_FORCE_LINK ? "Force" : "Unforce",
+		reg & PORT_PCS_CTRL_LINK_UP ? "up" : "down");
 
 	return 0;
 }
@@ -166,9 +166,9 @@ int mv88e6xxx_port_set_duplex(struct mv88e6xxx_chip *chip, int port, int dup)
 	if (err)
 		return err;
 
-	netdev_dbg(chip->ds->ports[port].netdev, "%s %s duplex\n",
-		   reg & PORT_PCS_CTRL_FORCE_DUPLEX ? "Force" : "Unforce",
-		   reg & PORT_PCS_CTRL_DUPLEX_FULL ? "full" : "half");
+	dev_dbg(chip->dev, "p%d: %s %s duplex\n", port,
+		reg & PORT_PCS_CTRL_FORCE_DUPLEX ? "Force" : "Unforce",
+		reg & PORT_PCS_CTRL_DUPLEX_FULL ? "full" : "half");
 
 	return 0;
 }
@@ -226,10 +226,9 @@ static int mv88e6xxx_port_set_speed(struct mv88e6xxx_chip *chip, int port,
 		return err;
 
 	if (speed)
-		netdev_dbg(chip->ds->ports[port].netdev,
-			   "Speed set to %d Mbps\n", speed);
+		dev_dbg(chip->dev, "p%d: Speed set to %d Mbps\n", port, speed);
 	else
-		netdev_dbg(chip->ds->ports[port].netdev, "Speed unforced\n");
+		dev_dbg(chip->dev, "p%d: Speed unforced\n", port);
 
 	return 0;
 }
@@ -419,8 +418,8 @@ int mv88e6xxx_port_set_state(struct mv88e6xxx_chip *chip, int port, u8 state)
 	if (err)
 		return err;
 
-	netdev_dbg(chip->ds->ports[port].netdev, "PortState set to %s\n",
-		   mv88e6xxx_port_state_names[state]);
+	dev_dbg(chip->dev, "p%d: PortState set to %s\n", port,
+		mv88e6xxx_port_state_names[state]);
 
 	return 0;
 }
@@ -580,8 +579,7 @@ int mv88e6xxx_port_set_vlan_map(struct mv88e6xxx_chip *chip, int port, u16 map)
 	if (err)
 		return err;
 
-	netdev_dbg(chip->ds->ports[port].netdev, "VLANTable set to %.3x\n",
-		   map);
+	dev_dbg(chip->dev, "p%d: VLANTable set to %.3x\n", port, map);
 
 	return 0;
 }
@@ -646,7 +644,7 @@ int mv88e6xxx_port_set_fid(struct mv88e6xxx_chip *chip, int port, u16 fid)
 			return err;
 	}
 
-	netdev_dbg(chip->ds->ports[port].netdev, "FID set to %u\n", fid);
+	dev_dbg(chip->dev, "p%d: FID set to %u\n", port, fid);
 
 	return 0;
 }
@@ -683,8 +681,7 @@ int mv88e6xxx_port_set_pvid(struct mv88e6xxx_chip *chip, int port, u16 pvid)
 	if (err)
 		return err;
 
-	netdev_dbg(chip->ds->ports[port].netdev, "DefaultVID set to %u\n",
-		   pvid);
+	dev_dbg(chip->dev, "p%d: DefaultVID set to %u\n", port, pvid);
 
 	return 0;
 }
@@ -761,8 +758,8 @@ int mv88e6xxx_port_set_8021q_mode(struct mv88e6xxx_chip *chip, int port,
 	if (err)
 		return err;
 
-	netdev_dbg(chip->ds->ports[port].netdev, "802.1QMode set to %s\n",
-		   mv88e6xxx_port_8021q_mode_names[mode]);
+	dev_dbg(chip->dev, "p%d: 802.1QMode set to %s\n", port,
+		mv88e6xxx_port_8021q_mode_names[mode]);
 
 	return 0;
 }
-- 
2.13.1
