From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 10/14] net: dsa: mv88e6xxx: rework port mode setup
Date: Thu,  9 Mar 2017 18:33:20 -0500
Message-ID: <20170309233324.18539-11-vivien.didelot@savoirfairelinux.com>
References: <20170309233324.18539-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170309233324.18539-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A switch port mode is defined by the association of its egress mode, its
frame mode and if supported or required, the ether type value.

Pack all this in a mv88e6xxx_set_port_mode function and provide helpers
for the Normal Network mode, the DSA mode, and the Ether Type DSA mode,
as well as an helper to setup a port's mode depending on its nature.

This way all related bits are written regardless of the port mode.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 118 +++++++++++++++++++++------------------
 1 file changed, 64 insertions(+), 54 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index ef20b33d9a06..2bbd5649f126 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2201,69 +2201,80 @@ static int mv88e6xxx_serdes_power_on(struct mv88e6xxx_chip *chip)
 	return err;
 }
 
+static int mv88e6xxx_set_port_mode(struct mv88e6xxx_chip *chip, int port,
+				   enum mv88e6xxx_frame_mode frame, u16 egress,
+				   u16 etype)
+{
+	int err;
+
+	if (!chip->info->ops->port_set_frame_mode)
+		return -EOPNOTSUPP;
+
+	err = mv88e6xxx_port_set_egress_mode(chip, port, egress);
+	if (err)
+		return err;
+
+	err = chip->info->ops->port_set_frame_mode(chip, port, frame);
+	if (err)
+		return err;
+
+	if (chip->info->ops->port_set_ether_type)
+		return chip->info->ops->port_set_ether_type(chip, port, etype);
+
+	return 0;
+}
+
+static int mv88e6xxx_set_port_mode_normal(struct mv88e6xxx_chip *chip, int port)
+{
+	return mv88e6xxx_set_port_mode(chip, port, MV88E6XXX_FRAME_MODE_NORMAL,
+				       PORT_CONTROL_EGRESS_UNMODIFIED, 0x9100);
+}
+
+static int mv88e6xxx_set_port_mode_dsa(struct mv88e6xxx_chip *chip, int port)
+{
+	return mv88e6xxx_set_port_mode(chip, port, MV88E6XXX_FRAME_MODE_DSA,
+				       PORT_CONTROL_EGRESS_UNMODIFIED, 0x9100);
+}
+
+static int mv88e6xxx_set_port_mode_edsa(struct mv88e6xxx_chip *chip, int port)
+{
+	return mv88e6xxx_set_port_mode(chip, port,
+				       MV88E6XXX_FRAME_MODE_ETHERTYPE,
+				       PORT_CONTROL_EGRESS_ADD_TAG, ETH_P_EDSA);
+}
+
+static int mv88e6xxx_setup_port_mode(struct mv88e6xxx_chip *chip, int port)
+{
+	if (dsa_is_dsa_port(chip->ds, port))
+		return mv88e6xxx_set_port_mode_dsa(chip, port);
+
+	if (!dsa_is_cpu_port(chip->ds, port))
+		return mv88e6xxx_set_port_mode_normal(chip, port);
+
+	/* Setup CPU port mode depending on its supported tag format */
+	if (chip->info->tag_protocol == DSA_TAG_PROTO_DSA)
+		return mv88e6xxx_set_port_mode_dsa(chip, port);
+
+	if (chip->info->tag_protocol == DSA_TAG_PROTO_EDSA)
+		return mv88e6xxx_set_port_mode_edsa(chip, port);
+
+	return -EINVAL;
+}
+
 static int mv88e6xxx_setup_port_dsa(struct mv88e6xxx_chip *chip, int port,
 				    int upstream_port)
 {
-	int err;
-
-	err = chip->info->ops->port_set_frame_mode(
-		chip, port, MV88E6XXX_FRAME_MODE_DSA);
-	if (err)
-		return err;
-
 	return chip->info->ops->port_set_egress_unknowns(
 		chip, port, port == upstream_port);
 }
 
 static int mv88e6xxx_setup_port_cpu(struct mv88e6xxx_chip *chip, int port)
 {
-	int err;
-
-	switch (chip->info->tag_protocol) {
-	case DSA_TAG_PROTO_EDSA:
-		err = chip->info->ops->port_set_frame_mode(
-			chip, port, MV88E6XXX_FRAME_MODE_ETHERTYPE);
-		if (err)
-			return err;
-
-		err = mv88e6xxx_port_set_egress_mode(
-			chip, port, PORT_CONTROL_EGRESS_ADD_TAG);
-		if (err)
-			return err;
-
-		if (chip->info->ops->port_set_ether_type)
-			err = chip->info->ops->port_set_ether_type(
-				chip, port, ETH_P_EDSA);
-		break;
-
-	case DSA_TAG_PROTO_DSA:
-		err = chip->info->ops->port_set_frame_mode(
-			chip, port, MV88E6XXX_FRAME_MODE_DSA);
-		if (err)
-			return err;
-
-		err = mv88e6xxx_port_set_egress_mode(
-			chip, port, PORT_CONTROL_EGRESS_UNMODIFIED);
-		break;
-	default:
-		err = -EINVAL;
-	}
-
-	if (err)
-		return err;
-
 	return chip->info->ops->port_set_egress_unknowns(chip, port, true);
 }
 
 static int mv88e6xxx_setup_port_normal(struct mv88e6xxx_chip *chip, int port)
 {
-	int err;
-
-	err = chip->info->ops->port_set_frame_mode(
-		chip, port, MV88E6XXX_FRAME_MODE_NORMAL);
-	if (err)
-		return err;
-
 	return chip->info->ops->port_set_egress_unknowns(chip, port, false);
 }
 
@@ -2330,6 +2341,10 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	if (err)
 		return err;
 
+	err = mv88e6xxx_setup_port_mode(chip, port);
+	if (err)
+		return err;
+
 	/* If this port is connected to a SerDes, make sure the SerDes is not
 	 * powered down.
 	 */
@@ -3559,11 +3574,6 @@ static const struct mv88e6xxx_ops mv88e6391_ops = {
 static int mv88e6xxx_verify_madatory_ops(struct mv88e6xxx_chip *chip,
 					 const struct mv88e6xxx_ops *ops)
 {
-	if (!ops->port_set_frame_mode) {
-		dev_err(chip->dev, "Missing port_set_frame_mode");
-		return -EINVAL;
-	}
-
 	if (!ops->port_set_egress_unknowns) {
 		dev_err(chip->dev, "Missing port_set_egress_mode");
 		return -EINVAL;
-- 
2.12.0
