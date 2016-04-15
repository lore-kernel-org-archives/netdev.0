From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/7] net: dsa: mv88e6xxx: drop revision probing
Date: Fri, 15 Apr 2016 14:25:45 -0400
Message-ID: <1460744750-13896-3-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1460744750-13896-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460744750-13896-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no point in having special case for the revision when probing a
switch model. The code gets cluttered with unnecessary defines, and
leads to errors when code such as mv88e6131_setup compares
PORT_SWITCH_ID_6131_B2 to ps->id which mask the revision.

Drop every revision definitions, add a ps->rev variable for eventual
runtime checking and lookup only the product number.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6123.c |  6 ------
 drivers/net/dsa/mv88e6131.c |  2 --
 drivers/net/dsa/mv88e6352.c |  6 ------
 drivers/net/dsa/mv88e6xxx.c | 19 ++++++-------------
 drivers/net/dsa/mv88e6xxx.h | 15 ++-------------
 5 files changed, 8 insertions(+), 40 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index 88a812d..00c1121 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -19,14 +19,8 @@
 
 static const struct mv88e6xxx_switch_id mv88e6123_table[] = {
 	{ PORT_SWITCH_ID_6123, "Marvell 88E6123" },
-	{ PORT_SWITCH_ID_6123_A1, "Marvell 88E6123 (A1)" },
-	{ PORT_SWITCH_ID_6123_A2, "Marvell 88E6123 (A2)" },
 	{ PORT_SWITCH_ID_6161, "Marvell 88E6161" },
-	{ PORT_SWITCH_ID_6161_A1, "Marvell 88E6161 (A1)" },
-	{ PORT_SWITCH_ID_6161_A2, "Marvell 88E6161 (A2)" },
 	{ PORT_SWITCH_ID_6165, "Marvell 88E6165" },
-	{ PORT_SWITCH_ID_6165_A1, "Marvell 88E6165 (A1)" },
-	{ PORT_SWITCH_ID_6165_A2, "Marvell 88e6165 (A2)" },
 };
 
 static char *mv88e6123_drv_probe(struct device *dsa_dev,
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 6b2bcb0..df534da 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -21,7 +21,6 @@ static const struct mv88e6xxx_switch_id mv88e6131_table[] = {
 	{ PORT_SWITCH_ID_6085, "Marvell 88E6085" },
 	{ PORT_SWITCH_ID_6095, "Marvell 88E6095/88E6095F" },
 	{ PORT_SWITCH_ID_6131, "Marvell 88E6131" },
-	{ PORT_SWITCH_ID_6131_B2, "Marvell 88E6131 (B2)" },
 	{ PORT_SWITCH_ID_6185, "Marvell 88E6185" },
 };
 
@@ -109,7 +108,6 @@ static int mv88e6131_setup(struct dsa_switch *ds)
 		ps->num_ports = 11;
 		break;
 	case PORT_SWITCH_ID_6131:
-	case PORT_SWITCH_ID_6131_B2:
 		ps->num_ports = 8;
 		break;
 	default:
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index dbd920e..30fc5f6 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -27,14 +27,8 @@ static const struct mv88e6xxx_switch_id mv88e6352_table[] = {
 	{ PORT_SWITCH_ID_6176, "Marvell 88E6176" },
 	{ PORT_SWITCH_ID_6240, "Marvell 88E6240" },
 	{ PORT_SWITCH_ID_6320, "Marvell 88E6320" },
-	{ PORT_SWITCH_ID_6320_A1, "Marvell 88E6320 (A1)" },
-	{ PORT_SWITCH_ID_6320_A2, "Marvell 88e6320 (A2)" },
 	{ PORT_SWITCH_ID_6321, "Marvell 88E6321" },
-	{ PORT_SWITCH_ID_6321_A1, "Marvell 88E6321 (A1)" },
-	{ PORT_SWITCH_ID_6321_A2, "Marvell 88e6321 (A2)" },
 	{ PORT_SWITCH_ID_6352, "Marvell 88E6352" },
-	{ PORT_SWITCH_ID_6352_A0, "Marvell 88E6352 (A0)" },
-	{ PORT_SWITCH_ID_6352_A1, "Marvell 88E6352 (A1)" },
 };
 
 static char *mv88e6352_drv_probe(struct device *dsa_dev,
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 9985a0c..ad29040 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2663,11 +2663,15 @@ int mv88e6xxx_setup_ports(struct dsa_switch *ds)
 int mv88e6xxx_setup_common(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int id;
 
 	ps->ds = ds;
 	mutex_init(&ps->smi_mutex);
 
-	ps->id = REG_READ(REG_PORT(0), PORT_SWITCH_ID) & 0xfff0;
+	id = REG_READ(REG_PORT(0), PORT_SWITCH_ID);
+
+	ps->id = id & 0xfff0;
+	ps->rev = id & 0xf;
 
 	INIT_WORK(&ps->bridge_work, mv88e6xxx_bridge_work);
 
@@ -3083,19 +3087,8 @@ static char *mv88e6xxx_lookup_name(struct mii_bus *bus, int sw_addr,
 
 	/* Look up the exact switch ID */
 	for (i = 0; i < num; ++i)
-		if (table[i].id == ret)
-			return table[i].name;
-
-	/* Look up only the product number */
-	for (i = 0; i < num; ++i) {
-		if (table[i].id == (ret & PORT_SWITCH_ID_PROD_NUM_MASK)) {
-			dev_warn(&bus->dev,
-				 "unknown revision %d, using base switch 0x%x\n",
-				 ret & PORT_SWITCH_ID_REV_MASK,
-				 ret & PORT_SWITCH_ID_PROD_NUM_MASK);
+		if (table[i].id == (ret & 0xfff0))
 			return table[i].name;
-		}
-	}
 
 	return NULL;
 }
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 5d27dec..7304f88 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -84,18 +84,11 @@
 #define PORT_SWITCH_ID_6121	0x1040
 #define PORT_SWITCH_ID_6122	0x1050
 #define PORT_SWITCH_ID_6123	0x1210
-#define PORT_SWITCH_ID_6123_A1	0x1212
-#define PORT_SWITCH_ID_6123_A2	0x1213
 #define PORT_SWITCH_ID_6131	0x1060
-#define PORT_SWITCH_ID_6131_B2	0x1066
 #define PORT_SWITCH_ID_6152	0x1a40
 #define PORT_SWITCH_ID_6155	0x1a50
 #define PORT_SWITCH_ID_6161	0x1610
-#define PORT_SWITCH_ID_6161_A1	0x1612
-#define PORT_SWITCH_ID_6161_A2	0x1613
 #define PORT_SWITCH_ID_6165	0x1650
-#define PORT_SWITCH_ID_6165_A1	0x1652
-#define PORT_SWITCH_ID_6165_A2	0x1653
 #define PORT_SWITCH_ID_6171	0x1710
 #define PORT_SWITCH_ID_6172	0x1720
 #define PORT_SWITCH_ID_6175	0x1750
@@ -104,16 +97,10 @@
 #define PORT_SWITCH_ID_6185	0x1a70
 #define PORT_SWITCH_ID_6240	0x2400
 #define PORT_SWITCH_ID_6320	0x1150
-#define PORT_SWITCH_ID_6320_A1	0x1151
-#define PORT_SWITCH_ID_6320_A2	0x1152
 #define PORT_SWITCH_ID_6321	0x3100
-#define PORT_SWITCH_ID_6321_A1	0x3101
-#define PORT_SWITCH_ID_6321_A2	0x3102
 #define PORT_SWITCH_ID_6350	0x3710
 #define PORT_SWITCH_ID_6351	0x3750
 #define PORT_SWITCH_ID_6352	0x3520
-#define PORT_SWITCH_ID_6352_A0	0x3521
-#define PORT_SWITCH_ID_6352_A1	0x3522
 #define PORT_CONTROL		0x04
 #define PORT_CONTROL_USE_CORE_TAG	BIT(15)
 #define PORT_CONTROL_DROP_ON_LOCK	BIT(14)
@@ -397,6 +384,8 @@ struct mv88e6xxx_priv_port {
 };
 
 struct mv88e6xxx_priv_state {
+	int rev;
+
 	/* The dsa_switch this private structure is related to */
 	struct dsa_switch *ds;
 
-- 
2.8.0
