From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 04/18] net: dsa: mv88e6xxx: move VTU flush
Date: Wed, 26 Apr 2017 11:53:22 -0400
Message-ID: <20170426155336.5937-5-vivien.didelot@savoirfairelinux.com>
References: <20170426155336.5937-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:38904 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935045AbdDZPzd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 11:55:33 -0400
In-Reply-To: <20170426155336.5937-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the VTU flush operation to global1_vtu.c and call it from a
mv88e6xxx_vtu_setup helper, similarly to the ATU and PVT setup.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c        | 28 ++++++++++++----------------
 drivers/net/dsa/mv88e6xxx/global1.h     |  1 +
 drivers/net/dsa/mv88e6xxx/global1_vtu.c | 13 +++++++++++++
 3 files changed, 26 insertions(+), 16 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index bf0350432337..d244c2283138 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1263,17 +1263,6 @@ static void mv88e6xxx_port_fast_age(struct dsa_switch *ds, int port)
 		netdev_err(ds->ports[port].netdev, "failed to flush ATU\n");
 }
 
-static int _mv88e6xxx_vtu_stu_flush(struct mv88e6xxx_chip *chip)
-{
-	int ret;
-
-	ret = mv88e6xxx_g1_vtu_op_wait(chip);
-	if (ret < 0)
-		return ret;
-
-	return mv88e6xxx_g1_vtu_op(chip, GLOBAL_VTU_OP_FLUSH_ALL);
-}
-
 static int _mv88e6xxx_vtu_stu_data_read(struct mv88e6xxx_chip *chip,
 					struct mv88e6xxx_vtu_entry *entry,
 					unsigned int nibble_offset)
@@ -1412,6 +1401,14 @@ static int _mv88e6xxx_vtu_getnext(struct mv88e6xxx_chip *chip,
 	return 0;
 }
 
+static int mv88e6xxx_vtu_setup(struct mv88e6xxx_chip *chip)
+{
+	if (!chip->info->max_vid)
+		return 0;
+
+	return mv88e6xxx_g1_vtu_flush(chip);
+}
+
 static int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 				    struct switchdev_obj_port_vlan *vlan,
 				    int (*cb)(struct switchdev_obj *obj))
@@ -2599,11 +2596,6 @@ static int mv88e6xxx_g1_setup(struct mv88e6xxx_chip *chip)
 	if (err)
 		return err;
 
-	/* Clear all the VTU and STU entries */
-	err = _mv88e6xxx_vtu_stu_flush(chip);
-	if (err < 0)
-		return err;
-
 	/* Configure the IP ToS mapping registers. */
 	err = mv88e6xxx_g1_write(chip, GLOBAL_IP_PRI_0, 0x0000);
 	if (err)
@@ -2684,6 +2676,10 @@ static int mv88e6xxx_setup(struct dsa_switch *ds)
 			goto unlock;
 	}
 
+	err = mv88e6xxx_vtu_setup(chip);
+	if (err)
+		goto unlock;
+
 	err = mv88e6xxx_pvt_setup(chip);
 	if (err)
 		goto unlock;
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index c153d07d2065..ed40e5557bbc 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -52,5 +52,6 @@ int mv88e6xxx_g1_atu_remove(struct mv88e6xxx_chip *chip, u16 fid, int port,
 
 int mv88e6xxx_g1_vtu_op_wait(struct mv88e6xxx_chip *chip);
 int mv88e6xxx_g1_vtu_op(struct mv88e6xxx_chip *chip, u16 op);
+int mv88e6xxx_g1_vtu_flush(struct mv88e6xxx_chip *chip);
 
 #endif /* _MV88E6XXX_GLOBAL1_H */
diff --git a/drivers/net/dsa/mv88e6xxx/global1_vtu.c b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
index 20dfdcbda238..c41ca28da084 100644
--- a/drivers/net/dsa/mv88e6xxx/global1_vtu.c
+++ b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
@@ -31,3 +31,16 @@ int mv88e6xxx_g1_vtu_op(struct mv88e6xxx_chip *chip, u16 op)
 
 	return mv88e6xxx_g1_vtu_op_wait(chip);
 }
+
+/* VLAN Translation Unit Operations */
+
+int mv88e6xxx_g1_vtu_flush(struct mv88e6xxx_chip *chip)
+{
+	int err;
+
+	err = mv88e6xxx_g1_vtu_op_wait(chip);
+	if (err)
+		return err;
+
+	return mv88e6xxx_g1_vtu_op(chip, GLOBAL_VTU_OP_FLUSH_ALL);
+}
-- 
2.12.2
