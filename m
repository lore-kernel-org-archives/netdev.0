From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 15/21] net: dsa: mv88e6xxx: factorize VLAN Ethertype
Date: Fri,  6 May 2016 17:57:17 -0400
Message-ID: <1462571843-14397-16-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1462571843-14397-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462571843-14397-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 6131 switch models have a Core Tag Type register. Add a
MV88E6XXX_FLAG_CORE_TAG_TYPE flag and set the VLAN Ethertype to 0x8100
in the shared setup code if it is present.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6131.c |  5 -----
 drivers/net/dsa/mv88e6xxx.c |  8 ++++++++
 drivers/net/dsa/mv88e6xxx.h | 10 ++++++++++
 3 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index d05fc79..1c3b245 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -65,11 +65,6 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
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
index 1572719..b0245e7 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2930,6 +2930,14 @@ static int _mv88e6xxx_setup_global(struct mv88e6xxx_priv_state *ps)
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
index 62f6fc9..555903f 100644
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
@@ -423,12 +430,14 @@ enum mv88e6xxx_cap {
 
 #define MV88E6XXX_FLAGS_FAMILY_6095	\
 	(MV88E6XXX_FLAG_ATU |		\
+	 MV88E6XXX_FLAG_CORE_TAG_TYPE |	\
 	 MV88E6XXX_FLAG_PPU |		\
 	 MV88E6XXX_FLAG_VLANTABLE |	\
 	 MV88E6XXX_FLAG_VTU)
 
 #define MV88E6XXX_FLAGS_FAMILY_6097	\
 	(MV88E6XXX_FLAG_ATU |		\
+	 MV88E6XXX_FLAG_CORE_TAG_TYPE |	\
 	 MV88E6XXX_FLAG_PPU |		\
 	 MV88E6XXX_FLAG_VLANTABLE |	\
 	 MV88E6XXX_FLAG_VTU)
@@ -439,6 +448,7 @@ enum mv88e6xxx_cap {
 
 #define MV88E6XXX_FLAGS_FAMILY_6185	\
 	(MV88E6XXX_FLAG_ATU |		\
+	 MV88E6XXX_FLAG_CORE_TAG_TYPE |	\
 	 MV88E6XXX_FLAG_PPU |		\
 	 MV88E6XXX_FLAG_VLANTABLE |	\
 	 MV88E6XXX_FLAG_VTU)
-- 
2.8.2
