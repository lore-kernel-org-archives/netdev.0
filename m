From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 1/6] net: dsa: mv88e6xxx: protect SID register access
Date: Thu, 31 Mar 2016 16:53:41 -0400
Message-ID: <1459457626-30082-2-git-send-email-vivien.didelot@savoirfairelinux.com>
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

Introduce a mv88e6xxx_has_stu() helper to protect the access to the
GLOBAL_VTU_SID register, instead of checking switch families.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index fa086e0..19a8208 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -482,6 +482,16 @@ static bool mv88e6xxx_6352_family(struct dsa_switch *ds)
 	return false;
 }
 
+static bool mv88e6xxx_has_stu(struct dsa_switch *ds)
+{
+	/* Does the device have STU and dedicated SID registers for VTU ops? */
+	if (mv88e6xxx_6097_family(ds) || mv88e6xxx_6165_family(ds) ||
+	    mv88e6xxx_6351_family(ds) || mv88e6xxx_6352_family(ds))
+		return true;
+
+	return false;
+}
+
 /* We expect the switch to perform auto negotiation if there is a real
  * phy. However, in the case of a fixed link phy, we force the port
  * settings from the fixed link settings.
@@ -1329,7 +1339,9 @@ static int _mv88e6xxx_vtu_getnext(struct dsa_switch *ds,
 				return ret;
 
 			next.fid = ret & GLOBAL_VTU_FID_MASK;
+		}
 
+		if (mv88e6xxx_has_stu(ds)) {
 			ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL,
 						  GLOBAL_VTU_SID);
 			if (ret < 0)
@@ -1412,8 +1424,7 @@ static int _mv88e6xxx_vtu_loadpurge(struct dsa_switch *ds,
 	if (ret < 0)
 		return ret;
 
-	if (mv88e6xxx_6097_family(ds) || mv88e6xxx_6165_family(ds) ||
-	    mv88e6xxx_6351_family(ds) || mv88e6xxx_6352_family(ds)) {
+	if (mv88e6xxx_has_stu(ds)) {
 		reg = entry->sid & GLOBAL_VTU_SID_MASK;
 		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_SID, reg);
 		if (ret < 0)
-- 
2.7.4
