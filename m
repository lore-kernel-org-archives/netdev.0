From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 05/18] net: dsa: mv88e6xxx: move VTU FID accessors
Date: Mon,  1 May 2017 14:05:14 -0400
Message-ID: <20170501180527.11756-6-vivien.didelot@savoirfairelinux.com>
References: <20170501180527.11756-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170501180527.11756-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add helpers to access the VTU FID register in the global1_vtu.c file.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c        |  7 ++-----
 drivers/net/dsa/mv88e6xxx/global1.h     |  4 ++++
 drivers/net/dsa/mv88e6xxx/global1_vtu.c | 25 +++++++++++++++++++++++++
 3 files changed, 31 insertions(+), 5 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index d244c2283138..0452543a2463 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1371,11 +1371,9 @@ static int _mv88e6xxx_vtu_getnext(struct mv88e6xxx_chip *chip,
 			return err;
 
 		if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G1_VTU_FID)) {
-			err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_FID, &val);
+			err = mv88e6xxx_g1_vtu_fid_read(chip, &next);
 			if (err)
 				return err;
-
-			next.fid = val & GLOBAL_VTU_FID_MASK;
 		} else if (mv88e6xxx_num_databases(chip) == 256) {
 			/* VTU DBNum[7:4] are located in VTU Operation 11:8, and
 			 * VTU DBNum[3:0] are located in VTU Operation 3:0
@@ -1491,8 +1489,7 @@ static int _mv88e6xxx_vtu_loadpurge(struct mv88e6xxx_chip *chip,
 	}
 
 	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_G1_VTU_FID)) {
-		reg = entry->fid & GLOBAL_VTU_FID_MASK;
-		err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_FID, reg);
+		err = mv88e6xxx_g1_vtu_fid_write(chip, entry);
 		if (err)
 			return err;
 	} else if (mv88e6xxx_num_databases(chip) == 256) {
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index ed40e5557bbc..353de283362f 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -50,6 +50,10 @@ int mv88e6xxx_g1_atu_flush(struct mv88e6xxx_chip *chip, u16 fid, bool all);
 int mv88e6xxx_g1_atu_remove(struct mv88e6xxx_chip *chip, u16 fid, int port,
 			    bool all);
 
+int mv88e6xxx_g1_vtu_fid_read(struct mv88e6xxx_chip *chip,
+			      struct mv88e6xxx_vtu_entry *entry);
+int mv88e6xxx_g1_vtu_fid_write(struct mv88e6xxx_chip *chip,
+			       struct mv88e6xxx_vtu_entry *entry);
 int mv88e6xxx_g1_vtu_op_wait(struct mv88e6xxx_chip *chip);
 int mv88e6xxx_g1_vtu_op(struct mv88e6xxx_chip *chip, u16 op);
 int mv88e6xxx_g1_vtu_flush(struct mv88e6xxx_chip *chip);
diff --git a/drivers/net/dsa/mv88e6xxx/global1_vtu.c b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
index c41ca28da084..81d6f9f3c84a 100644
--- a/drivers/net/dsa/mv88e6xxx/global1_vtu.c
+++ b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
@@ -14,6 +14,31 @@
 #include "mv88e6xxx.h"
 #include "global1.h"
 
+/* Offset 0x02: VTU FID Register */
+
+int mv88e6xxx_g1_vtu_fid_read(struct mv88e6xxx_chip *chip,
+			      struct mv88e6xxx_vtu_entry *entry)
+{
+	u16 val;
+	int err;
+
+	err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_FID, &val);
+	if (err)
+		return err;
+
+	entry->fid = val & GLOBAL_VTU_FID_MASK;
+
+	return 0;
+}
+
+int mv88e6xxx_g1_vtu_fid_write(struct mv88e6xxx_chip *chip,
+			       struct mv88e6xxx_vtu_entry *entry)
+{
+	u16 val = entry->fid & GLOBAL_VTU_FID_MASK;
+
+	return mv88e6xxx_g1_write(chip, GLOBAL_VTU_FID, val);
+}
+
 /* Offset 0x05: VTU Operation Register */
 
 int mv88e6xxx_g1_vtu_op_wait(struct mv88e6xxx_chip *chip)
-- 
2.12.2
