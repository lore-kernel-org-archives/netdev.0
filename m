From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/7] net: dsa: mv88e6xxx: 6185 port default FID is 8-bit
Date: Sat, 26 Mar 2016 21:59:37 -0400
Message-ID: <1459043983-12088-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1459043983-12088-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Patrick Uiterwijk <patrick@puiterwijk.org>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459043983-12088-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the 6352 family, FIDs are 12-bit. In the 6185 family, they are 8-bit.

Fix the upper mask, which was overlapping on the port Trunk ID (even
though it is not used yet).

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 10 +++++++---
 drivers/net/dsa/mv88e6xxx.h |  3 ++-
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index fa086e0..1d9ae48 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1511,9 +1511,13 @@ loadpurge:
 static int _mv88e6xxx_port_fid(struct dsa_switch *ds, int port, u16 *new,
 			       u16 *old)
 {
+	u16 upper_mask = PORT_CONTROL_1_FID_11_4_MASK;
 	u16 fid;
 	int ret;
 
+	if (mv88e6xxx_6185_family(ds))
+		upper_mask = PORT_CONTROL_1_DBNUM_7_4_MASK;
+
 	/* Port's default FID bits 3:0 are located in reg 0x06, offset 12 */
 	ret = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_BASE_VLAN);
 	if (ret < 0)
@@ -1536,11 +1540,11 @@ static int _mv88e6xxx_port_fid(struct dsa_switch *ds, int port, u16 *new,
 	if (ret < 0)
 		return ret;
 
-	fid |= (ret & PORT_CONTROL_1_FID_11_4_MASK) << 4;
+	fid |= (ret & upper_mask) << 4;
 
 	if (new) {
-		ret &= ~PORT_CONTROL_1_FID_11_4_MASK;
-		ret |= (*new >> 4) & PORT_CONTROL_1_FID_11_4_MASK;
+		ret &= ~upper_mask;
+		ret |= (*new >> 4) & upper_mask;
 
 		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_CONTROL_1,
 					   ret);
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 9a038ab..febab76 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -133,7 +133,8 @@
 #define PORT_CONTROL_STATE_LEARNING	0x02
 #define PORT_CONTROL_STATE_FORWARDING	0x03
 #define PORT_CONTROL_1		0x05
-#define PORT_CONTROL_1_FID_11_4_MASK	(0xff << 0)
+#define PORT_CONTROL_1_DBNUM_7_4_MASK	(0xf << 0)	/* 6185 */
+#define PORT_CONTROL_1_FID_11_4_MASK	(0xff << 0)	/* 6352 */
 #define PORT_BASE_VLAN		0x06
 #define PORT_BASE_VLAN_FID_3_0_MASK	(0xf << 12)
 #define PORT_DEFAULT_VLAN	0x07
-- 
2.7.4
