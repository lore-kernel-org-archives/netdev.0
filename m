From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 05/11] net: dsa: mv88e6xxx: add port PVID accessors
Date: Fri,  4 Nov 2016 03:23:30 +0100
Message-ID: <20161104022336.14273-6-vivien.didelot@savoirfairelinux.com>
References: <20161104022336.14273-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:51554 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757188AbcKDCYW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 22:24:22 -0400
In-Reply-To: <20161104022336.14273-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add port functions to access the ports default VID.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 51 ++++------------------------------------
 drivers/net/dsa/mv88e6xxx/port.c | 38 ++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/port.h |  3 +++
 3 files changed, 45 insertions(+), 47 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 20f59f1..9c0a028 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1288,49 +1288,6 @@ static void mv88e6xxx_port_fast_age(struct dsa_switch *ds, int port)
 		netdev_err(ds->ports[port].netdev, "failed to flush ATU\n");
 }
 
-static int _mv88e6xxx_port_pvid(struct mv88e6xxx_chip *chip, int port,
-				u16 *new, u16 *old)
-{
-	struct dsa_switch *ds = chip->ds;
-	u16 pvid, reg;
-	int err;
-
-	err = mv88e6xxx_port_read(chip, port, PORT_DEFAULT_VLAN, &reg);
-	if (err)
-		return err;
-
-	pvid = reg & PORT_DEFAULT_VLAN_MASK;
-
-	if (new) {
-		reg &= ~PORT_DEFAULT_VLAN_MASK;
-		reg |= *new & PORT_DEFAULT_VLAN_MASK;
-
-		err = mv88e6xxx_port_write(chip, port, PORT_DEFAULT_VLAN, reg);
-		if (err)
-			return err;
-
-		netdev_dbg(ds->ports[port].netdev,
-			   "DefaultVID %d (was %d)\n", *new, pvid);
-	}
-
-	if (old)
-		*old = pvid;
-
-	return 0;
-}
-
-static int _mv88e6xxx_port_pvid_get(struct mv88e6xxx_chip *chip,
-				    int port, u16 *pvid)
-{
-	return _mv88e6xxx_port_pvid(chip, port, NULL, pvid);
-}
-
-static int _mv88e6xxx_port_pvid_set(struct mv88e6xxx_chip *chip,
-				    int port, u16 pvid)
-{
-	return _mv88e6xxx_port_pvid(chip, port, &pvid, NULL);
-}
-
 static int _mv88e6xxx_vtu_wait(struct mv88e6xxx_chip *chip)
 {
 	return mv88e6xxx_g1_wait(chip, GLOBAL_VTU_OP, GLOBAL_VTU_OP_BUSY);
@@ -1510,7 +1467,7 @@ static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 
 	mutex_lock(&chip->reg_lock);
 
-	err = _mv88e6xxx_port_pvid_get(chip, port, &pvid);
+	err = mv88e6xxx_port_get_pvid(chip, port, &pvid);
 	if (err)
 		goto unlock;
 
@@ -1958,7 +1915,7 @@ static void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
 				   "failed to add VLAN %d%c\n",
 				   vid, untagged ? 'u' : 't');
 
-	if (pvid && _mv88e6xxx_port_pvid_set(chip, port, vlan->vid_end))
+	if (pvid && mv88e6xxx_port_set_pvid(chip, port, vlan->vid_end))
 		netdev_err(ds->ports[port].netdev, "failed to set PVID %d\n",
 			   vlan->vid_end);
 
@@ -2013,7 +1970,7 @@ static int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port,
 
 	mutex_lock(&chip->reg_lock);
 
-	err = _mv88e6xxx_port_pvid_get(chip, port, &pvid);
+	err = mv88e6xxx_port_get_pvid(chip, port, &pvid);
 	if (err)
 		goto unlock;
 
@@ -2023,7 +1980,7 @@ static int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port,
 			goto unlock;
 
 		if (vid == pvid) {
-			err = _mv88e6xxx_port_pvid_set(chip, port, 0);
+			err = mv88e6xxx_port_set_pvid(chip, port, 0);
 			if (err)
 				goto unlock;
 		}
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index a7da812..104fe2d 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -152,3 +152,41 @@ int mv88e6xxx_port_set_fid(struct mv88e6xxx_chip *chip, int port, u16 fid)
 
 	return 0;
 }
+
+/* Offset 0x07: Default Port VLAN ID & Priority */
+
+int mv88e6xxx_port_get_pvid(struct mv88e6xxx_chip *chip, int port, u16 *pvid)
+{
+	u16 reg;
+	int err;
+
+	err = mv88e6xxx_port_read(chip, port, PORT_DEFAULT_VLAN, &reg);
+	if (err)
+		return err;
+
+	*pvid = reg & PORT_DEFAULT_VLAN_MASK;
+
+	return 0;
+}
+
+int mv88e6xxx_port_set_pvid(struct mv88e6xxx_chip *chip, int port, u16 pvid)
+{
+	u16 reg;
+	int err;
+
+	err = mv88e6xxx_port_read(chip, port, PORT_DEFAULT_VLAN, &reg);
+	if (err)
+		return err;
+
+	reg &= ~PORT_DEFAULT_VLAN_MASK;
+	reg |= pvid & PORT_DEFAULT_VLAN_MASK;
+
+	err = mv88e6xxx_port_write(chip, port, PORT_DEFAULT_VLAN, reg);
+	if (err)
+		return err;
+
+	netdev_dbg(chip->ds->ports[port].netdev, "DefaultVID set to %u\n",
+		   pvid);
+
+	return 0;
+}
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 0df29b9..4489d9e 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -28,4 +28,7 @@ int mv88e6xxx_port_set_vlan_map(struct mv88e6xxx_chip *chip, int port, u16 map);
 int mv88e6xxx_port_get_fid(struct mv88e6xxx_chip *chip, int port, u16 *fid);
 int mv88e6xxx_port_set_fid(struct mv88e6xxx_chip *chip, int port, u16 fid);
 
+int mv88e6xxx_port_get_pvid(struct mv88e6xxx_chip *chip, int port, u16 *pvid);
+int mv88e6xxx_port_set_pvid(struct mv88e6xxx_chip *chip, int port, u16 pvid);
+
 #endif /* _MV88E6XXX_PORT_H */
-- 
2.10.2
