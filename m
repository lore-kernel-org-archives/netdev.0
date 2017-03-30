From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 6/9] net: dsa: mv88e6xxx: factorize in-chip bridge map
Date: Thu, 30 Mar 2017 17:37:12 -0400
Message-ID: <20170330213715.9666-7-vivien.didelot@savoirfairelinux.com>
References: <20170330213715.9666-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:39388 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934076AbdC3Vjo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 17:39:44 -0400
In-Reply-To: <20170330213715.9666-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Factorize the code in the DSA port_bridge_{join,leave} routines used to
program the port VLAN map of all local ports of a given bridge group.

At the same time shorten the _mv88e6xxx_port_based_vlan_map to get rid
of the old underscore prefix naming convention.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 47 +++++++++++++++++++++-------------------
 1 file changed, 25 insertions(+), 22 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 9b2d369715d7..3802e1bdd111 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1156,7 +1156,7 @@ static u16 mv88e6xxx_port_vlan(struct mv88e6xxx_chip *chip, int dev, int port)
 	return pvlan;
 }
 
-static int _mv88e6xxx_port_based_vlan_map(struct mv88e6xxx_chip *chip, int port)
+static int mv88e6xxx_port_vlan_map(struct mv88e6xxx_chip *chip, int port)
 {
 	u16 output_ports = mv88e6xxx_port_vlan(chip, chip->ds->index, port);
 
@@ -2140,23 +2140,32 @@ static int mv88e6xxx_port_fdb_dump(struct dsa_switch *ds, int port,
 	return err;
 }
 
+static int mv88e6xxx_bridge_map(struct mv88e6xxx_chip *chip,
+				struct net_device *br)
+{
+	int port;
+	int err;
+
+	/* Remap the Port VLAN of each local bridge group member */
+	for (port = 0; port < mv88e6xxx_num_ports(chip); ++port) {
+		if (chip->ds->ports[port].bridge_dev == br) {
+			err = mv88e6xxx_port_vlan_map(chip, port);
+			if (err)
+				return err;
+		}
+	}
+
+	return 0;
+}
+
 static int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port,
 				      struct net_device *br)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
-	int i, err = 0;
+	int err;
 
 	mutex_lock(&chip->reg_lock);
-
-	/* Remap each port's VLANTable */
-	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i) {
-		if (ds->ports[i].bridge_dev == br) {
-			err = _mv88e6xxx_port_based_vlan_map(chip, i);
-			if (err)
-				break;
-		}
-	}
-
+	err = mv88e6xxx_bridge_map(chip, br);
 	mutex_unlock(&chip->reg_lock);
 
 	return err;
@@ -2166,17 +2175,11 @@ static void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port,
 					struct net_device *br)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
-	int i;
 
 	mutex_lock(&chip->reg_lock);
-
-	/* Remap each port's VLANTable */
-	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i)
-		if (i == port || ds->ports[i].bridge_dev == br)
-			if (_mv88e6xxx_port_based_vlan_map(chip, i))
-				netdev_warn(ds->ports[i].netdev,
-					    "failed to remap\n");
-
+	if (mv88e6xxx_bridge_map(chip, br) ||
+	    mv88e6xxx_port_vlan_map(chip, port))
+		dev_err(ds->dev, "failed to remap in-chip Port VLAN\n");
 	mutex_unlock(&chip->reg_lock);
 }
 
@@ -2490,7 +2493,7 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	if (err)
 		return err;
 
-	err = _mv88e6xxx_port_based_vlan_map(chip, port);
+	err = mv88e6xxx_port_vlan_map(chip, port);
 	if (err)
 		return err;
 
-- 
2.12.1
