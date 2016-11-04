From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 04/11] net: dsa: mv88e6xxx: add port FID accessors
Date: Fri,  4 Nov 2016 03:23:29 +0100
Message-ID: <20161104022336.14273-5-vivien.didelot@savoirfairelinux.com>
References: <20161104022336.14273-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:51518 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753772AbcKDCYU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 22:24:20 -0400
In-Reply-To: <20161104022336.14273-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add functions to port files to access the ports default FID.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 77 +++-------------------------------------
 drivers/net/dsa/mv88e6xxx/port.c | 67 ++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/port.h |  3 ++
 3 files changed, 74 insertions(+), 73 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 0877777..20f59f1 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1674,75 +1674,6 @@ static int _mv88e6xxx_stu_loadpurge(struct mv88e6xxx_chip *chip,
 	return _mv88e6xxx_vtu_cmd(chip, GLOBAL_VTU_OP_STU_LOAD_PURGE);
 }
 
-static int _mv88e6xxx_port_fid(struct mv88e6xxx_chip *chip, int port,
-			       u16 *new, u16 *old)
-{
-	struct dsa_switch *ds = chip->ds;
-	u16 upper_mask;
-	u16 fid;
-	u16 reg;
-	int err;
-
-	if (mv88e6xxx_num_databases(chip) == 4096)
-		upper_mask = 0xff;
-	else if (mv88e6xxx_num_databases(chip) == 256)
-		upper_mask = 0xf;
-	else
-		return -EOPNOTSUPP;
-
-	/* Port's default FID bits 3:0 are located in reg 0x06, offset 12 */
-	err = mv88e6xxx_port_read(chip, port, PORT_BASE_VLAN, &reg);
-	if (err)
-		return err;
-
-	fid = (reg & PORT_BASE_VLAN_FID_3_0_MASK) >> 12;
-
-	if (new) {
-		reg &= ~PORT_BASE_VLAN_FID_3_0_MASK;
-		reg |= (*new << 12) & PORT_BASE_VLAN_FID_3_0_MASK;
-
-		err = mv88e6xxx_port_write(chip, port, PORT_BASE_VLAN, reg);
-		if (err)
-			return err;
-	}
-
-	/* Port's default FID bits 11:4 are located in reg 0x05, offset 0 */
-	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL_1, &reg);
-	if (err)
-		return err;
-
-	fid |= (reg & upper_mask) << 4;
-
-	if (new) {
-		reg &= ~upper_mask;
-		reg |= (*new >> 4) & upper_mask;
-
-		err = mv88e6xxx_port_write(chip, port, PORT_CONTROL_1, reg);
-		if (err)
-			return err;
-
-		netdev_dbg(ds->ports[port].netdev,
-			   "FID %d (was %d)\n", *new, fid);
-	}
-
-	if (old)
-		*old = fid;
-
-	return 0;
-}
-
-static int _mv88e6xxx_port_fid_get(struct mv88e6xxx_chip *chip,
-				   int port, u16 *fid)
-{
-	return _mv88e6xxx_port_fid(chip, port, NULL, fid);
-}
-
-static int _mv88e6xxx_port_fid_set(struct mv88e6xxx_chip *chip,
-				   int port, u16 fid)
-{
-	return _mv88e6xxx_port_fid(chip, port, &fid, NULL);
-}
-
 static int _mv88e6xxx_fid_new(struct mv88e6xxx_chip *chip, u16 *fid)
 {
 	DECLARE_BITMAP(fid_bitmap, MV88E6XXX_N_FID);
@@ -1753,7 +1684,7 @@ static int _mv88e6xxx_fid_new(struct mv88e6xxx_chip *chip, u16 *fid)
 
 	/* Set every FID bit used by the (un)bridged ports */
 	for (i = 0; i < mv88e6xxx_num_ports(chip); ++i) {
-		err = _mv88e6xxx_port_fid_get(chip, i, fid);
+		err = mv88e6xxx_port_get_fid(chip, i, fid);
 		if (err)
 			return err;
 
@@ -2203,7 +2134,7 @@ static int mv88e6xxx_port_db_load_purge(struct mv88e6xxx_chip *chip, int port,
 
 	/* Null VLAN ID corresponds to the port private database */
 	if (vid == 0)
-		err = _mv88e6xxx_port_fid_get(chip, port, &vlan.fid);
+		err = mv88e6xxx_port_get_fid(chip, port, &vlan.fid);
 	else
 		err = _mv88e6xxx_vtu_get(chip, vid, &vlan, false);
 	if (err)
@@ -2379,7 +2310,7 @@ static int mv88e6xxx_port_db_dump(struct mv88e6xxx_chip *chip, int port,
 	int err;
 
 	/* Dump port's default Filtering Information Database (VLAN ID 0) */
-	err = _mv88e6xxx_port_fid_get(chip, port, &fid);
+	err = mv88e6xxx_port_get_fid(chip, port, &fid);
 	if (err)
 		return err;
 
@@ -2782,7 +2713,7 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	 * database, and allow bidirectional communication between the
 	 * CPU and DSA port(s), and the other ports.
 	 */
-	err = _mv88e6xxx_port_fid_set(chip, port, 0);
+	err = mv88e6xxx_port_set_fid(chip, port, 0);
 	if (err)
 		return err;
 
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index c6a22ae..a7da812 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -61,6 +61,8 @@ int mv88e6xxx_port_set_state(struct mv88e6xxx_chip *chip, int port, u8 state)
 	return 0;
 }
 
+/* Offset 0x05: Port Control 1 */
+
 /* Offset 0x06: Port Based VLAN Map */
 
 int mv88e6xxx_port_set_vlan_map(struct mv88e6xxx_chip *chip, int port, u16 map)
@@ -85,3 +87,68 @@ int mv88e6xxx_port_set_vlan_map(struct mv88e6xxx_chip *chip, int port, u16 map)
 
 	return 0;
 }
+
+int mv88e6xxx_port_get_fid(struct mv88e6xxx_chip *chip, int port, u16 *fid)
+{
+	const u16 upper_mask = (mv88e6xxx_num_databases(chip) - 1) >> 4;
+	u16 reg;
+	int err;
+
+	/* Port's default FID lower 4 bits are located in reg 0x06, offset 12 */
+	err = mv88e6xxx_port_read(chip, port, PORT_BASE_VLAN, &reg);
+	if (err)
+		return err;
+
+	*fid = (reg & 0xf000) >> 12;
+
+	/* Port's default FID upper bits are located in reg 0x05, offset 0 */
+	if (upper_mask) {
+		err = mv88e6xxx_port_read(chip, port, PORT_CONTROL_1, &reg);
+		if (err)
+			return err;
+
+		*fid |= (reg & upper_mask) << 4;
+	}
+
+	return 0;
+}
+
+int mv88e6xxx_port_set_fid(struct mv88e6xxx_chip *chip, int port, u16 fid)
+{
+	const u16 upper_mask = (mv88e6xxx_num_databases(chip) - 1) >> 4;
+	u16 reg;
+	int err;
+
+	if (fid >= mv88e6xxx_num_databases(chip))
+		return -EINVAL;
+
+	/* Port's default FID lower 4 bits are located in reg 0x06, offset 12 */
+	err = mv88e6xxx_port_read(chip, port, PORT_BASE_VLAN, &reg);
+	if (err)
+		return err;
+
+	reg &= 0x0fff;
+	reg |= (fid & 0x000f) << 12;
+
+	err = mv88e6xxx_port_write(chip, port, PORT_BASE_VLAN, reg);
+	if (err)
+		return err;
+
+	/* Port's default FID upper bits are located in reg 0x05, offset 0 */
+	if (upper_mask) {
+		err = mv88e6xxx_port_read(chip, port, PORT_CONTROL_1, &reg);
+		if (err)
+			return err;
+
+		reg &= ~upper_mask;
+		reg |= (fid >> 4) & upper_mask;
+
+		err = mv88e6xxx_port_write(chip, port, PORT_CONTROL_1, reg);
+		if (err)
+			return err;
+	}
+
+	netdev_dbg(chip->ds->ports[port].netdev, "FID set to %u\n", fid);
+
+	return 0;
+}
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 037d638..0df29b9 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -25,4 +25,7 @@ int mv88e6xxx_port_set_state(struct mv88e6xxx_chip *chip, int port, u8 state);
 
 int mv88e6xxx_port_set_vlan_map(struct mv88e6xxx_chip *chip, int port, u16 map);
 
+int mv88e6xxx_port_get_fid(struct mv88e6xxx_chip *chip, int port, u16 *fid);
+int mv88e6xxx_port_set_fid(struct mv88e6xxx_chip *chip, int port, u16 fid);
+
 #endif /* _MV88E6XXX_PORT_H */
-- 
2.10.2
