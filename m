From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 3/7] net: dsa: mv88e6xxx: write FID in ATU command
Date: Sat, 26 Mar 2016 21:59:39 -0400
Message-ID: <1459043983-12088-4-git-send-email-vivien.didelot@savoirfairelinux.com>
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

Some switch models don't have a separate ATU FID register, but bury it
in the ATU Operation register.

Factorize the write of the FID and opcode in the ATU command function.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 31 ++++++++++++++-----------------
 1 file changed, 14 insertions(+), 17 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 1d9b5dd..df3f219 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -951,10 +951,20 @@ out:
 	return ret;
 }
 
-static int _mv88e6xxx_atu_cmd(struct dsa_switch *ds, u16 cmd)
+static int _mv88e6xxx_atu_cmd(struct dsa_switch *ds, u16 fid, u16 cmd)
 {
 	int ret;
 
+	if (mv88e6xxx_6097_family(ds) || mv88e6xxx_6165_family(ds) ||
+	    mv88e6xxx_6351_family(ds) || mv88e6xxx_6352_family(ds)) {
+		/* 88E6352 and similar have their own ATU FID register */
+		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_FID, fid);
+		if (ret < 0)
+			return ret;
+	} else {
+		return -EOPNOTSUPP;
+	}
+
 	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_OP, cmd);
 	if (ret < 0)
 		return ret;
@@ -1001,11 +1011,6 @@ static int _mv88e6xxx_atu_flush_move(struct dsa_switch *ds,
 		return err;
 
 	if (entry->fid) {
-		err = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_FID,
-					   entry->fid);
-		if (err)
-			return err;
-
 		op = static_too ? GLOBAL_ATU_OP_FLUSH_MOVE_ALL_DB :
 			GLOBAL_ATU_OP_FLUSH_MOVE_NON_STATIC_DB;
 	} else {
@@ -1013,7 +1018,7 @@ static int _mv88e6xxx_atu_flush_move(struct dsa_switch *ds,
 			GLOBAL_ATU_OP_FLUSH_MOVE_NON_STATIC;
 	}
 
-	return _mv88e6xxx_atu_cmd(ds, op);
+	return _mv88e6xxx_atu_cmd(ds, entry->fid, op);
 }
 
 static int _mv88e6xxx_atu_flush(struct dsa_switch *ds, u16 fid, bool static_too)
@@ -1973,11 +1978,7 @@ static int _mv88e6xxx_atu_load(struct dsa_switch *ds,
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_FID, entry->fid);
-	if (ret < 0)
-		return ret;
-
-	return _mv88e6xxx_atu_cmd(ds, GLOBAL_ATU_OP_LOAD_DB);
+	return _mv88e6xxx_atu_cmd(ds, entry->fid, GLOBAL_ATU_OP_LOAD_DB);
 }
 
 static int _mv88e6xxx_port_fdb_load(struct dsa_switch *ds, int port,
@@ -2060,11 +2061,7 @@ static int _mv88e6xxx_atu_getnext(struct dsa_switch *ds, u16 fid,
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_FID, fid);
-	if (ret < 0)
-		return ret;
-
-	ret = _mv88e6xxx_atu_cmd(ds, GLOBAL_ATU_OP_GET_NEXT_DB);
+	ret = _mv88e6xxx_atu_cmd(ds, fid, GLOBAL_ATU_OP_GET_NEXT_DB);
 	if (ret < 0)
 		return ret;
 
-- 
2.7.4
