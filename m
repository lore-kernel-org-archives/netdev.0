From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC PATCH net-next 14/20] net: dsa: mv88e6xxx: factorize VLAN Ethertype
Date: Thu,  5 May 2016 18:40:58 -0400
Message-ID: <1462488064-1841-15-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1462488064-1841-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462488064-1841-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Only the 6131 driver was setting the VLAN Ethertype to 0x8100. Set it to
all models.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6131.c | 9 ++++-----
 drivers/net/dsa/mv88e6xxx.c | 8 ++++++++
 drivers/net/dsa/mv88e6xxx.h | 7 +++++++
 3 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 013668c..4c0b1e9 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -25,6 +25,7 @@ static const struct mv88e6xxx_info mv88e6131_table[] = {
 		.num_databases = 256,
 		.num_ports = 11,
 		.flags = MV88E6XXX_FLAG_ATU |
+			MV88E6XXX_FLAG_CORE_TAG_TYPE |
 			MV88E6XXX_FLAG_PPU |
 			MV88E6XXX_FLAG_VLANTABLE |
 			MV88E6XXX_FLAG_VTU,
@@ -35,6 +36,7 @@ static const struct mv88e6xxx_info mv88e6131_table[] = {
 		.num_databases = 4096,
 		.num_ports = 10,
 		.flags = MV88E6XXX_FLAG_ATU |
+			MV88E6XXX_FLAG_CORE_TAG_TYPE |
 			MV88E6XXX_FLAG_PPU |
 			MV88E6XXX_FLAG_VLANTABLE |
 			MV88E6XXX_FLAG_VTU,
@@ -45,6 +47,7 @@ static const struct mv88e6xxx_info mv88e6131_table[] = {
 		.num_databases = 256,
 		.num_ports = 8,
 		.flags = MV88E6XXX_FLAG_ATU |
+			MV88E6XXX_FLAG_CORE_TAG_TYPE |
 			MV88E6XXX_FLAG_PPU |
 			MV88E6XXX_FLAG_VLANTABLE |
 			MV88E6XXX_FLAG_VTU,
@@ -55,6 +58,7 @@ static const struct mv88e6xxx_info mv88e6131_table[] = {
 		.num_databases = 256,
 		.num_ports = 10,
 		.flags = MV88E6XXX_FLAG_ATU |
+			MV88E6XXX_FLAG_CORE_TAG_TYPE |
 			MV88E6XXX_FLAG_PPU |
 			MV88E6XXX_FLAG_VLANTABLE |
 			MV88E6XXX_FLAG_VTU,
@@ -77,11 +81,6 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
 	int ret;
 	u32 reg;
 
-	/* Set the VLAN ethertype to 0x8100. */
-	ret = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CORE_TAG_TYPE, 0x8100);
-	if (ret)
-		return ret;
-
 	/* Disable ARP mirroring, and configure the upstream port as
 	 * the port to which ingress and egress monitor frames are to
 	 * be sent.
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 1cba078..f7fca3e 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2929,6 +2929,14 @@ static int _mv88e6xxx_setup_global(struct mv88e6xxx_priv_state *ps)
 	if (err)
 		return err;
 
+	/* Set the VLAN ethertype to 0x8100. */
+	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_CORE_TAG_TYPE)) {
+		err = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CORE_TAG_TYPE,
+					   0x8100);
+		if (err)
+			return err;
+	}
+
 	/* Set the default address aging time to 5 minutes, and
 	 * enable address learn messages to be sent to all message
 	 * ports.
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 119271e..c8677dd 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -365,6 +365,12 @@ enum mv88e6xxx_cap {
 	 */
 	MV88E6XXX_CAP_EEPROM,
 
+	/* Core Tag Type.
+	 * Used with Double Tagged frames and ports in UseCoreTag mode.
+	 * See GLOBAL_CORE_TAG_TYPE.
+	 */
+	MV88E6XXX_CAP_CORE_TAG_TYPE,
+
 	/* Port State Filtering for 802.1D Spanning Tree.
 	 * See PORT_CONTROL_STATE_* values in the PORT_CONTROL register.
 	 */
@@ -411,6 +417,7 @@ enum mv88e6xxx_cap {
 #define MV88E6XXX_FLAG_ATU		BIT(MV88E6XXX_CAP_ATU)
 #define MV88E6XXX_FLAG_EEE		BIT(MV88E6XXX_CAP_EEE)
 #define MV88E6XXX_FLAG_EEPROM		BIT(MV88E6XXX_CAP_EEPROM)
+#define MV88E6XXX_FLAG_CORE_TAG_TYPE	BIT(MV88E6XXX_CAP_CORE_TAG_TYPE)
 #define MV88E6XXX_FLAG_PORTSTATE	BIT(MV88E6XXX_CAP_PORTSTATE)
 #define MV88E6XXX_FLAG_PPU		BIT(MV88E6XXX_CAP_PPU)
 #define MV88E6XXX_FLAG_PPU_ACTIVE	BIT(MV88E6XXX_CAP_PPU_ACTIVE)
-- 
2.8.2
