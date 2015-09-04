From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/7] net: dsa: mv88e6xxx: extract ATU data write access
Date: Fri,  4 Sep 2015 14:34:11 -0400
Message-ID: <1441391656-22574-3-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1441391656-22574-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441391656-22574-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Other ATU commands need to write the ATU data register. To ease the
introduction of such commands, extract the ATU data write access from
_mv88e6xxx_atu_load to its own function.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 43 ++++++++++++++++++++++++-------------------
 1 file changed, 24 insertions(+), 19 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index bf455f9..25e103c 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1047,6 +1047,29 @@ static int _mv88e6xxx_atu_cmd(struct dsa_switch *ds, u16 cmd)
 	return _mv88e6xxx_atu_wait(ds);
 }
 
+static int _mv88e6xxx_atu_data_write(struct dsa_switch *ds,
+				     struct mv88e6xxx_atu_entry *entry)
+{
+	u16 data = entry->state & GLOBAL_ATU_DATA_STATE_MASK;
+
+	if (entry->state != GLOBAL_ATU_DATA_STATE_UNUSED) {
+		unsigned int mask, shift;
+
+		if (entry->trunk) {
+			data |= GLOBAL_ATU_DATA_TRUNK;
+			mask = GLOBAL_ATU_DATA_TRUNK_ID_MASK;
+			shift = GLOBAL_ATU_DATA_TRUNK_ID_SHIFT;
+		} else {
+			mask = GLOBAL_ATU_DATA_PORT_VECTOR_MASK;
+			shift = GLOBAL_ATU_DATA_PORT_VECTOR_SHIFT;
+		}
+
+		data |= (entry->portv_trunkid << shift) & mask;
+	}
+
+	return _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_DATA, data);
+}
+
 static int _mv88e6xxx_flush_fid(struct dsa_switch *ds, int fid)
 {
 	int ret;
@@ -1761,7 +1784,6 @@ static int _mv88e6xxx_atu_mac_read(struct dsa_switch *ds, unsigned char *addr)
 static int _mv88e6xxx_atu_load(struct dsa_switch *ds,
 			       struct mv88e6xxx_atu_entry *entry)
 {
-	u16 reg = 0;
 	int ret;
 
 	ret = _mv88e6xxx_atu_wait(ds);
@@ -1772,24 +1794,7 @@ static int _mv88e6xxx_atu_load(struct dsa_switch *ds,
 	if (ret < 0)
 		return ret;
 
-	if (entry->state != GLOBAL_ATU_DATA_STATE_UNUSED) {
-		unsigned int mask, shift;
-
-		if (entry->trunk) {
-			reg |= GLOBAL_ATU_DATA_TRUNK;
-			mask = GLOBAL_ATU_DATA_TRUNK_ID_MASK;
-			shift = GLOBAL_ATU_DATA_TRUNK_ID_SHIFT;
-		} else {
-			mask = GLOBAL_ATU_DATA_PORT_VECTOR_MASK;
-			shift = GLOBAL_ATU_DATA_PORT_VECTOR_SHIFT;
-		}
-
-		reg |= (entry->portv_trunkid << shift) & mask;
-	}
-
-	reg |= entry->state & GLOBAL_ATU_DATA_STATE_MASK;
-
-	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_DATA, reg);
+	ret = _mv88e6xxx_atu_data_write(ds, entry);
 	if (ret < 0)
 		return ret;
 
-- 
2.5.1
