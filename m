From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 19/20] net: dsa: mv88e6xxx: conditionally init PVT
Date: Wed, 27 Apr 2016 18:30:16 -0400
Message-ID: <1461796217-18893-20-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461796217-18893-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current code initialize the Cross-chip Port VLAN Table to all ones,
even tough the switch model doesn't have one.

It also assumes that the switch is configured to support up to
32-switch/16-port cross-chip devices.

Implement the access to the PVT and initialize it only if the switch has
such feature. Support only 88E6352 for the moment.

This commit brings no functional change for devices with a PVT.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6352.c |  1 +
 drivers/net/dsa/mv88e6xxx.c | 54 +++++++++++++++++++++++++++++++++++++++------
 drivers/net/dsa/mv88e6xxx.h |  6 +++++
 3 files changed, 54 insertions(+), 7 deletions(-)

diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 4afc24d..29d9fd76 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -59,6 +59,7 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.name = "Marvell 88E6352",
 		.num_databases = 4096,
 		.num_ports = 7,
+		.flags = BIT(MV88E6XXX_FLAG_PVT),
 	}
 };
 
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 25852ee..4341ffd 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2247,6 +2247,47 @@ unlock:
 	return err;
 }
 
+static int _mv88e6xxx_pvt_wait(struct dsa_switch *ds)
+{
+	return _mv88e6xxx_wait(ds, REG_GLOBAL2, GLOBAL2_PVT_ADDR,
+			       GLOBAL2_PVT_ADDR_BUSY);
+}
+
+static int _mv88e6xxx_pvt_cmd(struct dsa_switch *ds, int src_dev, int src_port,
+			      u16 op)
+{
+	u16 reg = op;
+	int err;
+
+	/* 9-bit Cross-chip PVT pointer: with GLOBAL2_MISC_5_BIT_PORT cleared,
+	 * source device is 5-bit, source port is 4-bit.
+	 */
+	reg |= (src_dev & 0x1f) << 4;
+	reg |= (src_port & 0xf);
+
+	err = _mv88e6xxx_reg_write(ds, REG_GLOBAL2, GLOBAL2_PVT_ADDR, reg);
+	if (err)
+		return err;
+
+	return _mv88e6xxx_pvt_wait(ds);
+}
+
+static int _mv88e6xxx_pvt_init(struct dsa_switch *ds)
+{
+	int err;
+
+	/* Clear 5 Bit Port for usage with Marvell Link Street devices:
+	 * use 4 bits for the Src_Port/Src_Trunk and 5 bits for the Src_Dev.
+	 */
+	err = _mv88e6xxx_reg_write(ds, REG_GLOBAL2, GLOBAL2_MISC,
+				   0 & ~GLOBAL2_MISC_5_BIT_PORT);
+	if (err)
+		return err;
+
+	/* Allow any cross-chip frames to egress any internal ports */
+	return _mv88e6xxx_pvt_cmd(ds, 0, 0, GLOBAL2_PVT_ADDR_OP_INIT_ONES);
+}
+
 int mv88e6xxx_port_bridge_change(struct dsa_switch *ds, struct dsa_port *dp,
 				 struct net_device *bridge)
 {
@@ -2770,13 +2811,12 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
 		if (err)
 			goto unlock;
 
-		/* Initialise cross-chip port VLAN table to reset
-		 * defaults.
-		 */
-		err = _mv88e6xxx_reg_write(ds, REG_GLOBAL2,
-					   GLOBAL2_PVT_ADDR, 0x9000);
-		if (err)
-			goto unlock;
+		/* Initialize Cross-chip Port VLAN Table (PVT) */
+		if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_PVT)) {
+			err = _mv88e6xxx_pvt_init(ds);
+			if (err)
+				goto unlock;
+		}
 
 		/* Clear the priority override table. */
 		for (i = 0; i < 16; i++) {
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 325caf8..fbde8b4 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -298,6 +298,10 @@
 #define GLOBAL2_INGRESS_OP	0x09
 #define GLOBAL2_INGRESS_DATA	0x0a
 #define GLOBAL2_PVT_ADDR	0x0b
+#define GLOBAL2_PVT_ADDR_BUSY	BIT(15)
+#define GLOBAL2_PVT_ADDR_OP_INIT_ONES	((0x01 << 12) | GLOBAL2_PVT_ADDR_BUSY)
+#define GLOBAL2_PVT_ADDR_OP_WRITE_PVLAN	((0x03 << 12) | GLOBAL2_PVT_ADDR_BUSY)
+#define GLOBAL2_PVT_ADDR_OP_READ	((0x04 << 12) | GLOBAL2_PVT_ADDR_BUSY)
 #define GLOBAL2_PVT_DATA	0x0c
 #define GLOBAL2_SWITCH_MAC	0x0d
 #define GLOBAL2_SWITCH_MAC_BUSY BIT(15)
@@ -335,10 +339,12 @@
 #define GLOBAL2_WDOG_CONTROL	0x1b
 #define GLOBAL2_QOS_WEIGHT	0x1c
 #define GLOBAL2_MISC		0x1d
+#define GLOBAL2_MISC_5_BIT_PORT	BIT(14)
 
 #define MV88E6XXX_N_FID		4096
 
 enum mv88e6xxx_flag {
+	MV88E6XXX_FLAG_PVT,
 	MV88E6XXX_NUM_FLAGS,
 };
 
-- 
2.8.0
