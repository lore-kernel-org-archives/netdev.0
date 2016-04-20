From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC 2/3] net: dsa: mv88e6xxx: initialize PVT
Date: Wed, 20 Apr 2016 16:26:08 -0400
Message-ID: <1461183969-24610-3-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1461183969-24610-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461183969-24610-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Expand the Cross-chip Port Based VLAN Table initilization code, and make
sure the "5 Bit Port" bit is cleared.

This commit doesn't make any functional change to the current code.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 48 ++++++++++++++++++++++++++++++++++++++++-----
 drivers/net/dsa/mv88e6xxx.h |  5 +++++
 2 files changed, 48 insertions(+), 5 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 1dd525d..e35bc9f 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2203,6 +2203,47 @@ unlock:
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
+	/* Allow any external frame to egress any internal port */
+	return _mv88e6xxx_pvt_cmd(ds, 0, 0, GLOBAL2_PVT_ADDR_OP_INIT_ONES);
+}
+
 int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port,
 			       struct net_device *bridge)
 {
@@ -2747,11 +2788,8 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
 		if (err)
 			goto unlock;
 
-		/* Initialise cross-chip port VLAN table to reset
-		 * defaults.
-		 */
-		err = _mv88e6xxx_reg_write(ds, REG_GLOBAL2,
-					   GLOBAL2_PVT_ADDR, 0x9000);
+		/* Initialize Cross-chip Port VLAN Table (PVT) */
+		err = _mv88e6xxx_pvt_init(ds);
 		if (err)
 			goto unlock;
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 0dbe2d1..dd63377 100644
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
@@ -335,6 +339,7 @@
 #define GLOBAL2_WDOG_CONTROL	0x1b
 #define GLOBAL2_QOS_WEIGHT	0x1c
 #define GLOBAL2_MISC		0x1d
+#define GLOBAL2_MISC_5_BIT_PORT	BIT(14)
 
 #define MV88E6XXX_N_FID		4096
 
-- 
2.8.0
