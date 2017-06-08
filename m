From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/7] net: dsa: mv88e6xxx: provide printing macros
Date: Thu,  8 Jun 2017 15:04:39 -0400
Message-ID: <20170608190445.24443-2-vivien.didelot@savoirfairelinux.com>
References: <20170608190445.24443-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170608190445.24443-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The mv88e6xxx driver accesses a port's netdev mostly for printing.

This is bad for 2 reasons: DSA and CPU ports do not have a netdev
pointer; it doesn't give us a correct picture of why a DSA driver might
need to access a port's netdev.

Introduce mv88e6xxx_{dbg,err,warn} macros to print messages with a
prefix containing the real switch name (not the compatible one),
as well as the switch and port indexes.

These are examples of output in dmesg with this patch:

    [  103.488407] Marvell 88E6352 1.6: DefaultVID set to 42
    [  103.562586] Marvell 88E6185 2.0: 802.1QMode set to Secure
    [  103.559690] Marvell 88E6390X 1.2: PortState set to Forwarding

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 31 +++++++++++++++----------------
 drivers/net/dsa/mv88e6xxx/chip.h | 12 ++++++++++++
 drivers/net/dsa/mv88e6xxx/port.c | 39 ++++++++++++++++++---------------------
 3 files changed, 45 insertions(+), 37 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 0534eb706caa..4a442d5bbc99 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -489,8 +489,7 @@ static int mv88e6xxx_port_setup_mac(struct mv88e6xxx_chip *chip, int port,
 	err = 0;
 restore_link:
 	if (chip->info->ops->port_set_link(chip, port, link))
-		netdev_err(chip->ds->ports[port].netdev,
-			   "failed to restore MAC's link\n");
+		mv88e6xxx_err(chip, port, "failed to restore MAC's link");
 
 	return err;
 }
@@ -514,7 +513,7 @@ static void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
 	mutex_unlock(&chip->reg_lock);
 
 	if (err && err != -EOPNOTSUPP)
-		netdev_err(ds->ports[port].netdev, "failed to configure MAC\n");
+		mv88e6xxx_err(chip, port, "failed to configure MAC");
 }
 
 static int mv88e6xxx_stats_snapshot(struct mv88e6xxx_chip *chip, int port)
@@ -941,7 +940,7 @@ static void mv88e6xxx_port_stp_state_set(struct dsa_switch *ds, int port,
 	mutex_unlock(&chip->reg_lock);
 
 	if (err)
-		netdev_err(ds->ports[port].netdev, "failed to update state\n");
+		mv88e6xxx_err(chip, port, "failed to update state");
 }
 
 static int mv88e6xxx_atu_setup(struct mv88e6xxx_chip *chip)
@@ -1009,7 +1008,7 @@ static void mv88e6xxx_port_fast_age(struct dsa_switch *ds, int port)
 	mutex_unlock(&chip->reg_lock);
 
 	if (err)
-		netdev_err(ds->ports[port].netdev, "failed to flush ATU\n");
+		mv88e6xxx_err(chip, port, "failed to flush ATU");
 }
 
 static int mv88e6xxx_vtu_setup(struct mv88e6xxx_chip *chip)
@@ -1214,10 +1213,10 @@ static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 			if (!ds->ports[i].bridge_dev)
 				continue;
 
-			netdev_warn(ds->ports[port].netdev,
-				    "hardware VLAN %d already used by %s\n",
-				    vlan.vid,
-				    netdev_name(ds->ports[i].bridge_dev));
+			mv88e6xxx_warn(chip, port,
+				       "hardware VLAN %d already used by %s",
+				       vlan.vid,
+				       netdev_name(ds->ports[i].bridge_dev));
 			err = -EOPNOTSUPP;
 			goto unlock;
 		}
@@ -1311,13 +1310,12 @@ static void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
 
 	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid)
 		if (_mv88e6xxx_port_vlan_add(chip, port, vid, member))
-			netdev_err(ds->ports[port].netdev,
-				   "failed to add VLAN %d%c\n",
-				   vid, untagged ? 'u' : 't');
+			mv88e6xxx_err(chip, port, "failed to add VLAN %d%c",
+				      vid, untagged ? 'u' : 't');
 
 	if (pvid && mv88e6xxx_port_set_pvid(chip, port, vlan->vid_end))
-		netdev_err(ds->ports[port].netdev, "failed to set PVID %d\n",
-			   vlan->vid_end);
+		mv88e6xxx_err(chip, port, "failed to set PVID %d",
+			      vlan->vid_end);
 
 	mutex_unlock(&chip->reg_lock);
 }
@@ -1451,7 +1449,7 @@ static void mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 	mutex_lock(&chip->reg_lock);
 	if (mv88e6xxx_port_db_load_purge(chip, port, fdb->addr, fdb->vid,
 					 GLOBAL_ATU_DATA_STATE_UC_STATIC))
-		netdev_err(ds->ports[port].netdev, "failed to load unicast MAC address\n");
+		mv88e6xxx_err(chip, port, "failed to load unicast MAC address");
 	mutex_unlock(&chip->reg_lock);
 }
 
@@ -3793,7 +3791,8 @@ static void mv88e6xxx_port_mdb_add(struct dsa_switch *ds, int port,
 	mutex_lock(&chip->reg_lock);
 	if (mv88e6xxx_port_db_load_purge(chip, port, mdb->addr, mdb->vid,
 					 GLOBAL_ATU_DATA_STATE_MC_STATIC))
-		netdev_err(ds->ports[port].netdev, "failed to load multicast MAC address\n");
+		mv88e6xxx_err(chip, port,
+			      "failed to load multicast MAC address");
 	mutex_unlock(&chip->reg_lock);
 }
 
diff --git a/drivers/net/dsa/mv88e6xxx/chip.h b/drivers/net/dsa/mv88e6xxx/chip.h
index 98c24af977fd..bd099edf0eb5 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.h
+++ b/drivers/net/dsa/mv88e6xxx/chip.h
@@ -18,6 +18,18 @@
 #include <linux/phy.h>
 #include <net/dsa.h>
 
+#define mv88e6xxx_dbg(chip, port, fmt, ...) \
+	pr_debug("%s %d.%d: " fmt "\n", (chip)->info->name, \
+		 (chip)->ds->index, port, ##__VA_ARGS__)
+
+#define mv88e6xxx_err(chip, port, fmt, ...) \
+	pr_err("%s %d.%d: " fmt "\n", (chip)->info->name, \
+	       (chip)->ds->index, port, ##__VA_ARGS__)
+
+#define mv88e6xxx_warn(chip, port, fmt, ...) \
+	pr_warn("%s %d.%d: " fmt "\n", (chip)->info->name, \
+		(chip)->ds->index, port, ##__VA_ARGS__)
+
 #ifndef UINT64_MAX
 #define UINT64_MAX		(u64)(~((u64)0))
 #endif
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 3719ece60c61..69e25ed03a83 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -76,9 +76,9 @@ static int mv88e6xxx_port_set_rgmii_delay(struct mv88e6xxx_chip *chip, int port,
 	if (err)
 		return err;
 
-	netdev_dbg(chip->ds->ports[port].netdev, "delay RXCLK %s, TXCLK %s\n",
-		   reg & PORT_PCS_CTRL_RGMII_DELAY_RXCLK ? "yes" : "no",
-		   reg & PORT_PCS_CTRL_RGMII_DELAY_TXCLK ? "yes" : "no");
+	mv88e6xxx_dbg(chip, port, "delay RXCLK %s, TXCLK %s",
+		      reg & PORT_PCS_CTRL_RGMII_DELAY_RXCLK ? "yes" : "no",
+		      reg & PORT_PCS_CTRL_RGMII_DELAY_TXCLK ? "yes" : "no");
 
 	return 0;
 }
@@ -130,9 +130,9 @@ int mv88e6xxx_port_set_link(struct mv88e6xxx_chip *chip, int port, int link)
 	if (err)
 		return err;
 
-	netdev_dbg(chip->ds->ports[port].netdev, "%s link %s\n",
-		   reg & PORT_PCS_CTRL_FORCE_LINK ? "Force" : "Unforce",
-		   reg & PORT_PCS_CTRL_LINK_UP ? "up" : "down");
+	mv88e6xxx_dbg(chip, port, "%s link %s",
+		      reg & PORT_PCS_CTRL_FORCE_LINK ? "Force" : "Unforce",
+		      reg & PORT_PCS_CTRL_LINK_UP ? "up" : "down");
 
 	return 0;
 }
@@ -166,9 +166,9 @@ int mv88e6xxx_port_set_duplex(struct mv88e6xxx_chip *chip, int port, int dup)
 	if (err)
 		return err;
 
-	netdev_dbg(chip->ds->ports[port].netdev, "%s %s duplex\n",
-		   reg & PORT_PCS_CTRL_FORCE_DUPLEX ? "Force" : "Unforce",
-		   reg & PORT_PCS_CTRL_DUPLEX_FULL ? "full" : "half");
+	mv88e6xxx_dbg(chip, port, "%s %s duplex",
+		      reg & PORT_PCS_CTRL_FORCE_DUPLEX ? "Force" : "Unforce",
+		      reg & PORT_PCS_CTRL_DUPLEX_FULL ? "full" : "half");
 
 	return 0;
 }
@@ -226,10 +226,9 @@ static int mv88e6xxx_port_set_speed(struct mv88e6xxx_chip *chip, int port,
 		return err;
 
 	if (speed)
-		netdev_dbg(chip->ds->ports[port].netdev,
-			   "Speed set to %d Mbps\n", speed);
+		mv88e6xxx_dbg(chip, port, "Speed set to %d Mbps", speed);
 	else
-		netdev_dbg(chip->ds->ports[port].netdev, "Speed unforced\n");
+		mv88e6xxx_dbg(chip, port, "Speed unforced");
 
 	return 0;
 }
@@ -419,8 +418,8 @@ int mv88e6xxx_port_set_state(struct mv88e6xxx_chip *chip, int port, u8 state)
 	if (err)
 		return err;
 
-	netdev_dbg(chip->ds->ports[port].netdev, "PortState set to %s\n",
-		   mv88e6xxx_port_state_names[state]);
+	mv88e6xxx_dbg(chip, port, "PortState set to %s",
+		      mv88e6xxx_port_state_names[state]);
 
 	return 0;
 }
@@ -580,8 +579,7 @@ int mv88e6xxx_port_set_vlan_map(struct mv88e6xxx_chip *chip, int port, u16 map)
 	if (err)
 		return err;
 
-	netdev_dbg(chip->ds->ports[port].netdev, "VLANTable set to %.3x\n",
-		   map);
+	mv88e6xxx_dbg(chip, port, "VLANTable set to %.3x", map);
 
 	return 0;
 }
@@ -646,7 +644,7 @@ int mv88e6xxx_port_set_fid(struct mv88e6xxx_chip *chip, int port, u16 fid)
 			return err;
 	}
 
-	netdev_dbg(chip->ds->ports[port].netdev, "FID set to %u\n", fid);
+	mv88e6xxx_dbg(chip, port, "FID set to %u", fid);
 
 	return 0;
 }
@@ -683,8 +681,7 @@ int mv88e6xxx_port_set_pvid(struct mv88e6xxx_chip *chip, int port, u16 pvid)
 	if (err)
 		return err;
 
-	netdev_dbg(chip->ds->ports[port].netdev, "DefaultVID set to %u\n",
-		   pvid);
+	mv88e6xxx_dbg(chip, port, "DefaultVID set to %u", pvid);
 
 	return 0;
 }
@@ -761,8 +758,8 @@ int mv88e6xxx_port_set_8021q_mode(struct mv88e6xxx_chip *chip, int port,
 	if (err)
 		return err;
 
-	netdev_dbg(chip->ds->ports[port].netdev, "802.1QMode set to %s\n",
-		   mv88e6xxx_port_8021q_mode_names[mode]);
+	mv88e6xxx_dbg(chip, port, "802.1QMode set to %s",
+		      mv88e6xxx_port_8021q_mode_names[mode]);
 
 	return 0;
 }
-- 
2.13.1
