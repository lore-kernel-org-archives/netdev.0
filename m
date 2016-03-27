From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 5/7] net: dsa: mv88e6xxx: fix VTU FID access for 6185
Date: Sat, 26 Mar 2016 21:59:41 -0400
Message-ID: <1459043983-12088-6-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1459043983-12088-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Patrick Uiterwijk <patrick@puiterwijk.org>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:51514 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754778AbcC0CAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Mar 2016 22:00:19 -0400
In-Reply-To: <1459043983-12088-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 6352 family has an entire register for its 12-bit FID used by the
VTU operations. The 6185 family has no such register. Its 8-bit FID
(called DBNum) is split in the VTU Operation register.

Modify the VTU read and write access to support this switch family.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 20 +++++++++++++++++++-
 drivers/net/dsa/mv88e6xxx.h |  2 +-
 2 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 4b3c466..366fda1 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1355,6 +1355,17 @@ static int _mv88e6xxx_vtu_getnext(struct dsa_switch *ds,
 				return ret;
 
 			next.sid = ret & GLOBAL_VTU_SID_MASK;
+		} else if (mv88e6xxx_6185_family(ds)) {
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
 	}
 
@@ -1416,6 +1427,7 @@ unlock:
 static int _mv88e6xxx_vtu_loadpurge(struct dsa_switch *ds,
 				    struct mv88e6xxx_vtu_stu_entry *entry)
 {
+	u16 op = GLOBAL_VTU_OP_VTU_LOAD_PURGE;
 	u16 reg = 0;
 	int ret;
 
@@ -1442,6 +1454,12 @@ static int _mv88e6xxx_vtu_loadpurge(struct dsa_switch *ds,
 		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_FID, reg);
 		if (ret < 0)
 			return ret;
+	} else if (mv88e6xxx_6185_family(ds)) {
+		/* VTU DBNum[7:4] are located in VTU Operation 11:8, and
+		 * VTU DBNum[3:0] are located in VTU Operation 3:0
+		 */
+		op |= (entry->fid & 0xf0) << 8;
+		op |= entry->fid & 0xf;
 	}
 
 	reg = GLOBAL_VTU_VID_VALID;
@@ -1451,7 +1469,7 @@ loadpurge:
 	if (ret < 0)
 		return ret;
 
-	return _mv88e6xxx_vtu_cmd(ds, GLOBAL_VTU_OP_VTU_LOAD_PURGE);
+	return _mv88e6xxx_vtu_cmd(ds, op);
 }
 
 static int _mv88e6xxx_stu_getnext(struct dsa_switch *ds, u8 sid,
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 94d3cb3..b1f1269 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -376,7 +376,7 @@ struct mv88e6xxx_atu_entry {
 struct mv88e6xxx_vtu_stu_entry {
 	/* VTU only */
 	u16	vid;
-	u16	fid;
+	u16	fid; /* 8-bit DBNum in 88E6185 family */
 
 	/* VTU and STU */
 	u8	sid;
-- 
2.7.4
