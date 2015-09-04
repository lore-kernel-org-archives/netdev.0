From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/7] net: dsa: mv88e6xxx: extract FID write from ATU command
Date: Fri,  4 Sep 2015 14:34:10 -0400
Message-ID: <1441391656-22574-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1441391656-22574-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip-208-88-110-44.savoirfairelinux.net ([208.88.110.44]:57187
	"EHLO mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760370AbbIDSfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2015 14:35:10 -0400
In-Reply-To: <1441391656-22574-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not every ATU commands apply to an FID, thus remove the FID writing from
mv88e6xxx_atu_cmd and write it explicitly where needed, in order to ease
introduction of such commands.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 32 +++++++++++++++++++++++---------
 1 file changed, 23 insertions(+), 9 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 6f13f72..bf455f9 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1036,14 +1036,10 @@ out:
 	return ret;
 }
 
-static int _mv88e6xxx_atu_cmd(struct dsa_switch *ds, int fid, u16 cmd)
+static int _mv88e6xxx_atu_cmd(struct dsa_switch *ds, u16 cmd)
 {
 	int ret;
 
-	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_FID, fid);
-	if (ret < 0)
-		return ret;
-
 	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_OP, cmd);
 	if (ret < 0)
 		return ret;
@@ -1059,7 +1055,11 @@ static int _mv88e6xxx_flush_fid(struct dsa_switch *ds, int fid)
 	if (ret < 0)
 		return ret;
 
-	return _mv88e6xxx_atu_cmd(ds, fid, GLOBAL_ATU_OP_FLUSH_NON_STATIC_DB);
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_FID, fid);
+	if (ret < 0)
+		return ret;
+
+	return _mv88e6xxx_atu_cmd(ds, GLOBAL_ATU_OP_FLUSH_NON_STATIC_DB);
 }
 
 static int mv88e6xxx_set_port_state(struct dsa_switch *ds, int port, u8 state)
@@ -1793,7 +1793,11 @@ static int _mv88e6xxx_atu_load(struct dsa_switch *ds,
 	if (ret < 0)
 		return ret;
 
-	return _mv88e6xxx_atu_cmd(ds, entry->fid, GLOBAL_ATU_OP_LOAD_DB);
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_FID, entry->fid);
+	if (ret < 0)
+		return ret;
+
+	return _mv88e6xxx_atu_cmd(ds, GLOBAL_ATU_OP_LOAD_DB);
 }
 
 static int _mv88e6xxx_port_vid_to_fid(struct dsa_switch *ds, int port, u16 vid)
@@ -1884,7 +1888,11 @@ static int _mv88e6xxx_atu_getnext(struct dsa_switch *ds, u16 fid,
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_atu_cmd(ds, fid, GLOBAL_ATU_OP_GET_NEXT_DB);
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_FID, fid);
+	if (ret < 0)
+		return ret;
+
+	ret = _mv88e6xxx_atu_cmd(ds, GLOBAL_ATU_OP_GET_NEXT_DB);
 	if (ret < 0)
 		return ret;
 
@@ -2308,9 +2316,15 @@ static int mv88e6xxx_atu_show_db(struct seq_file *s, struct dsa_switch *ds,
 		return ret;
 
 	do {
-		ret = _mv88e6xxx_atu_cmd(ds, dbnum, GLOBAL_ATU_OP_GET_NEXT_DB);
+		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_FID,
+					   dbnum);
 		if (ret < 0)
 			return ret;
+
+		ret = _mv88e6xxx_atu_cmd(ds, GLOBAL_ATU_OP_GET_NEXT_DB);
+		if (ret < 0)
+			return ret;
+
 		data = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_ATU_DATA);
 		if (data < 0)
 			return data;
-- 
2.5.1
