From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 13/17] net: dsa: mv88e6xxx: rework port mode setup
Date: Sat, 11 Mar 2017 16:12:59 -0500
Message-ID: <20170311211303.24560-14-vivien.didelot@savoirfairelinux.com>
References: <20170311211303.24560-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:55118 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755500AbdCKVPF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Mar 2017 16:15:05 -0500
In-Reply-To: <20170311211303.24560-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A switch port mode is defined by the association of its egress mode, its
frame mode and if supported or required, the ether type value.

Pack all this in a mv88e6xxx_set_port_mode function and provide helpers
for the Normal Network mode, the DSA mode, and the Ether Type DSA mode,
as well as an helper to setup a port's mode depending on its nature.

Define PORT_ETH_TYPE_DEFAULT for the 0x9100 reset value of port E Type.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 120 +++++++++++++++++++---------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |   1 +
 2 files changed, 67 insertions(+), 54 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index e9533d4919bc..5f5023215ce1 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2199,69 +2199,82 @@ static int mv88e6xxx_serdes_power_on(struct mv88e6xxx_chip *chip)
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
+				       PORT_CONTROL_EGRESS_UNMODIFIED,
+				       PORT_ETH_TYPE_DEFAULT);
+}
+
+static int mv88e6xxx_set_port_mode_dsa(struct mv88e6xxx_chip *chip, int port)
+{
+	return mv88e6xxx_set_port_mode(chip, port, MV88E6XXX_FRAME_MODE_DSA,
+				       PORT_CONTROL_EGRESS_UNMODIFIED,
+				       PORT_ETH_TYPE_DEFAULT);
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
+	if (dsa_is_normal_port(chip->ds, port))
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
 
@@ -2325,6 +2338,10 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	if (err)
 		return err;
 
+	err = mv88e6xxx_setup_port_mode(chip, port);
+	if (err)
+		return err;
+
 	/* If this port is connected to a SerDes, make sure the SerDes is not
 	 * powered down.
 	 */
@@ -3554,11 +3571,6 @@ static const struct mv88e6xxx_ops mv88e6391_ops = {
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
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 69acb4c40fdc..185be5434980 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -182,6 +182,7 @@
 #define PORT_ATU_CONTROL	0x0c
 #define PORT_PRI_OVERRIDE	0x0d
 #define PORT_ETH_TYPE		0x0f
+#define PORT_ETH_TYPE_DEFAULT	0x9100
 #define PORT_IN_DISCARD_LO	0x10
 #define PORT_IN_DISCARD_HI	0x11
 #define PORT_IN_FILTERED	0x12
-- 
2.12.0
