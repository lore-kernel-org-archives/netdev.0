From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 11/18] net: dsa: mv88e6xxx: get STU entry on VTU GetNext
Date: Mon,  1 May 2017 14:05:20 -0400
Message-ID: <20170501180527.11756-12-vivien.didelot@savoirfairelinux.com>
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

Now that the code reads both VTU and STU data on VTU GetNext operation,
fetch the STU entry data of a VTU entry at the same time.

The STU data bits are masked with the VTU data bits and they are now all
read at the same time a VTU GetNext operation is issued.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/chip.c        |  2 +-
 drivers/net/dsa/mv88e6xxx/global1.h     |  2 ++
 drivers/net/dsa/mv88e6xxx/global1_vtu.c | 22 ++++++++++++++++++++++
 3 files changed, 25 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 5441b05f519b..38c3e047fbf9 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1292,7 +1292,7 @@ static int _mv88e6xxx_vtu_getnext(struct mv88e6xxx_chip *chip,
 		}
 
 		if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_STU)) {
-			err = mv88e6xxx_g1_vtu_sid_read(chip, &next);
+			err = mv88e6xxx_g1_vtu_stu_get(chip, &next);
 			if (err)
 				return err;
 		}
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index 5d276cc4262b..76b49a3a4701 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -72,6 +72,8 @@ int mv88e6xxx_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
 			     struct mv88e6xxx_vtu_entry *entry);
 int mv88e6xxx_g1_vtu_stu_getnext(struct mv88e6xxx_chip *chip,
 				 struct mv88e6xxx_vtu_entry *vtu);
+int mv88e6xxx_g1_vtu_stu_get(struct mv88e6xxx_chip *chip,
+			     struct mv88e6xxx_vtu_entry *vtu);
 int mv88e6xxx_g1_vtu_flush(struct mv88e6xxx_chip *chip);
 
 #endif /* _MV88E6XXX_GLOBAL1_H */
diff --git a/drivers/net/dsa/mv88e6xxx/global1_vtu.c b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
index cf572ba76195..710f86fa3b4e 100644
--- a/drivers/net/dsa/mv88e6xxx/global1_vtu.c
+++ b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
@@ -194,6 +194,28 @@ int mv88e6xxx_g1_vtu_stu_getnext(struct mv88e6xxx_chip *chip,
 	return mv88e6xxx_g1_vtu_vid_read(chip, entry);
 }
 
+int mv88e6xxx_g1_vtu_stu_get(struct mv88e6xxx_chip *chip,
+			     struct mv88e6xxx_vtu_entry *vtu)
+{
+	struct mv88e6xxx_vtu_entry stu;
+	int err;
+
+	err = mv88e6xxx_g1_vtu_sid_read(chip, vtu);
+	if (err)
+		return err;
+
+	stu.sid = vtu->sid - 1;
+
+	err = mv88e6xxx_g1_vtu_stu_getnext(chip, &stu);
+	if (err)
+		return err;
+
+	if (stu.sid != vtu->sid || !stu.valid)
+		return -EINVAL;
+
+	return 0;
+}
+
 int mv88e6xxx_g1_vtu_getnext(struct mv88e6xxx_chip *chip,
 			     struct mv88e6xxx_vtu_entry *entry)
 {
-- 
2.12.2
