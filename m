From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/7] net: dsa: mv88e6xxx: add egress mode enumeration
Date: Thu,  8 Jun 2017 15:04:40 -0400
Message-ID: <20170608190445.24443-3-vivien.didelot@savoirfairelinux.com>
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

As for the frame mode, add a mv88e6xxx_egress_mode enumeration instead
of a 16-bit register mask.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 11 ++++++-----
 drivers/net/dsa/mv88e6xxx/chip.h |  7 +++++++
 drivers/net/dsa/mv88e6xxx/port.c | 20 ++++++++++++++++++--
 drivers/net/dsa/mv88e6xxx/port.h |  2 +-
 4 files changed, 32 insertions(+), 8 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 4a442d5bbc99..42dd5560c131 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1722,8 +1722,8 @@ static int mv88e6xxx_switch_reset(struct mv88e6xxx_chip *chip)
 }
 
 static int mv88e6xxx_set_port_mode(struct mv88e6xxx_chip *chip, int port,
-				   enum mv88e6xxx_frame_mode frame, u16 egress,
-				   u16 etype)
+				   enum mv88e6xxx_frame_mode frame,
+				   enum mv88e6xxx_egress_mode egress, u16 etype)
 {
 	int err;
 
@@ -1747,14 +1747,14 @@ static int mv88e6xxx_set_port_mode(struct mv88e6xxx_chip *chip, int port,
 static int mv88e6xxx_set_port_mode_normal(struct mv88e6xxx_chip *chip, int port)
 {
 	return mv88e6xxx_set_port_mode(chip, port, MV88E6XXX_FRAME_MODE_NORMAL,
-				       PORT_CONTROL_EGRESS_UNMODIFIED,
+				       MV88E6XXX_EGRESS_MODE_UNMODIFIED,
 				       PORT_ETH_TYPE_DEFAULT);
 }
 
 static int mv88e6xxx_set_port_mode_dsa(struct mv88e6xxx_chip *chip, int port)
 {
 	return mv88e6xxx_set_port_mode(chip, port, MV88E6XXX_FRAME_MODE_DSA,
-				       PORT_CONTROL_EGRESS_UNMODIFIED,
+				       MV88E6XXX_EGRESS_MODE_UNMODIFIED,
 				       PORT_ETH_TYPE_DEFAULT);
 }
 
@@ -1762,7 +1762,8 @@ static int mv88e6xxx_set_port_mode_edsa(struct mv88e6xxx_chip *chip, int port)
 {
 	return mv88e6xxx_set_port_mode(chip, port,
 				       MV88E6XXX_FRAME_MODE_ETHERTYPE,
-				       PORT_CONTROL_EGRESS_ADD_TAG, ETH_P_EDSA);
+				       MV88E6XXX_EGRESS_MODE_ETHERTYPE,
+				       ETH_P_EDSA);
 }
 
 static int mv88e6xxx_setup_port_mode(struct mv88e6xxx_chip *chip, int port)
diff --git a/drivers/net/dsa/mv88e6xxx/chip.h b/drivers/net/dsa/mv88e6xxx/chip.h
index bd099edf0eb5..33f8814e8a48 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.h
+++ b/drivers/net/dsa/mv88e6xxx/chip.h
@@ -51,6 +51,13 @@
 #define MV88E6XXX_MAX_PVT_SWITCHES	32
 #define MV88E6XXX_MAX_PVT_PORTS		16
 
+enum mv88e6xxx_egress_mode {
+	MV88E6XXX_EGRESS_MODE_UNMODIFIED,
+	MV88E6XXX_EGRESS_MODE_UNTAGGED,
+	MV88E6XXX_EGRESS_MODE_TAGGED,
+	MV88E6XXX_EGRESS_MODE_ETHERTYPE,
+};
+
 enum mv88e6xxx_frame_mode {
 	MV88E6XXX_FRAME_MODE_NORMAL,
 	MV88E6XXX_FRAME_MODE_DSA,
diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 69e25ed03a83..8e49c5584a53 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -425,7 +425,7 @@ int mv88e6xxx_port_set_state(struct mv88e6xxx_chip *chip, int port, u8 state)
 }
 
 int mv88e6xxx_port_set_egress_mode(struct mv88e6xxx_chip *chip, int port,
-				   u16 mode)
+				   enum mv88e6xxx_egress_mode mode)
 {
 	int err;
 	u16 reg;
@@ -435,7 +435,23 @@ int mv88e6xxx_port_set_egress_mode(struct mv88e6xxx_chip *chip, int port,
 		return err;
 
 	reg &= ~PORT_CONTROL_EGRESS_MASK;
-	reg |= mode;
+
+	switch (mode) {
+	case MV88E6XXX_EGRESS_MODE_UNMODIFIED:
+		reg |= PORT_CONTROL_EGRESS_UNMODIFIED;
+		break;
+	case MV88E6XXX_EGRESS_MODE_UNTAGGED:
+		reg |= PORT_CONTROL_EGRESS_UNTAGGED;
+		break;
+	case MV88E6XXX_EGRESS_MODE_TAGGED:
+		reg |= PORT_CONTROL_EGRESS_TAGGED;
+		break;
+	case MV88E6XXX_EGRESS_MODE_ETHERTYPE:
+		reg |= PORT_CONTROL_EGRESS_ADD_TAG;
+		break;
+	default:
+		return -EINVAL;
+	}
 
 	return mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
 }
diff --git a/drivers/net/dsa/mv88e6xxx/port.h b/drivers/net/dsa/mv88e6xxx/port.h
index 4f5e1ccfadc6..1de200074e21 100644
--- a/drivers/net/dsa/mv88e6xxx/port.h
+++ b/drivers/net/dsa/mv88e6xxx/port.h
@@ -212,7 +212,7 @@ int mv88e6xxx_port_set_8021q_mode(struct mv88e6xxx_chip *chip, int port,
 int mv88e6095_port_tag_remap(struct mv88e6xxx_chip *chip, int port);
 int mv88e6390_port_tag_remap(struct mv88e6xxx_chip *chip, int port);
 int mv88e6xxx_port_set_egress_mode(struct mv88e6xxx_chip *chip, int port,
-				   u16 mode);
+				   enum mv88e6xxx_egress_mode mode);
 int mv88e6085_port_set_frame_mode(struct mv88e6xxx_chip *chip, int port,
 				  enum mv88e6xxx_frame_mode mode);
 int mv88e6351_port_set_frame_mode(struct mv88e6xxx_chip *chip, int port,
-- 
2.13.1
