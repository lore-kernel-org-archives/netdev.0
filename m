From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 4/6] net: dsa: mv88e6xxx: support 256 databases
Date: Thu, 31 Mar 2016 16:53:44 -0400
Message-ID: <1459457626-30082-5-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1459457626-30082-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459457626-30082-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 6185 family of devices has only 256 address databases. Their 8-bit
FID for ATU and VTU operations are split into ATU Control and ATU/VTU
Operation registers.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 36 +++++++++++++++++++++++++++++++++++-
 1 file changed, 35 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 888c66b..52c3e17 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1003,6 +1003,20 @@ static int _mv88e6xxx_atu_cmd(struct dsa_switch *ds, u16 fid, u16 cmd)
 		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_FID, fid);
 		if (ret < 0)
 			return ret;
+	} else if (mv88e6xxx_num_databases(ds) == 256) {
+		/* ATU DBNum[7:4] are located in ATU Control 15:12 */
+		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_ATU_CONTROL);
+		if (ret < 0)
+			return ret;
+
+		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_CONTROL,
+					   (ret & 0xfff) |
+					   ((fid << 8) & 0xf000));
+		if (ret < 0)
+			return ret;
+
+		/* ATU DBNum[3:0] are located in ATU Operation 3:0 */
+		cmd |= fid & 0xf;
 	}
 
 	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_OP, cmd);
@@ -1373,6 +1387,17 @@ static int _mv88e6xxx_vtu_getnext(struct dsa_switch *ds,
 				return ret;
 
 			next.fid = ret & GLOBAL_VTU_FID_MASK;
+		} else if (mv88e6xxx_num_databases(ds) == 256) {
+			/* VTU DBNum[7:4] are located in VTU Operation 11:8, and
+			 * VTU DBNum[3:0] are located in VTU Operation 3:0
+			 */
+			ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL,
+						  GLOBAL_VTU_OP);
+			if (ret < 0)
+				return ret;
+
+			next.fid = (ret & 0xf00) >> 4;
+			next.fid |= ret & 0xf;
 		}
 
 		if (mv88e6xxx_has_stu(ds)) {
@@ -1443,6 +1468,7 @@ unlock:
 static int _mv88e6xxx_vtu_loadpurge(struct dsa_switch *ds,
 				    struct mv88e6xxx_vtu_stu_entry *entry)
 {
+	u16 op = GLOBAL_VTU_OP_VTU_LOAD_PURGE;
 	u16 reg = 0;
 	int ret;
 
@@ -1470,6 +1496,12 @@ static int _mv88e6xxx_vtu_loadpurge(struct dsa_switch *ds,
 		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_FID, reg);
 		if (ret < 0)
 			return ret;
+	} else if (mv88e6xxx_num_databases(ds) == 256) {
+		/* VTU DBNum[7:4] are located in VTU Operation 11:8, and
+		 * VTU DBNum[3:0] are located in VTU Operation 3:0
+		 */
+		op |= (entry->fid & 0xf0) << 8;
+		op |= entry->fid & 0xf;
 	}
 
 	reg = GLOBAL_VTU_VID_VALID;
@@ -1479,7 +1511,7 @@ loadpurge:
 	if (ret < 0)
 		return ret;
 
-	return _mv88e6xxx_vtu_cmd(ds, GLOBAL_VTU_OP_VTU_LOAD_PURGE);
+	return _mv88e6xxx_vtu_cmd(ds, op);
 }
 
 static int _mv88e6xxx_stu_getnext(struct dsa_switch *ds, u8 sid,
@@ -1564,6 +1596,8 @@ static int _mv88e6xxx_port_fid(struct dsa_switch *ds, int port, u16 *new,
 
 	if (mv88e6xxx_num_databases(ds) == 4096)
 		upper_mask = 0xff;
+	else if (mv88e6xxx_num_databases(ds) == 256)
+		upper_mask = 0xf;
 	else
 		return -EOPNOTSUPP;
 
-- 
2.7.4
