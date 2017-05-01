From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 03/18] net: dsa: mv88e6xxx: move VTU Operation accessors
Date: Mon,  1 May 2017 14:05:12 -0400
Message-ID: <20170501180527.11756-4-vivien.didelot@savoirfairelinux.com>
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

Move the helper functions to access the Global 1 VTU Operation register
to a new global1_vtu.c file, and get rid of the old underscore prefix
naming convention. This file will be extended will all VTU/STU related
code.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/Makefile      |  1 +
 drivers/net/dsa/mv88e6xxx/chip.c        | 39 +++++++++------------------------
 drivers/net/dsa/mv88e6xxx/global1.h     |  3 +++
 drivers/net/dsa/mv88e6xxx/global1_vtu.c | 33 ++++++++++++++++++++++++++++
 4 files changed, 47 insertions(+), 29 deletions(-)
 create mode 100644 drivers/net/dsa/mv88e6xxx/global1_vtu.c

diff --git a/drivers/net/dsa/mv88e6xxx/Makefile b/drivers/net/dsa/mv88e6xxx/Makefile
index 31d37a90cec7..6edd869c8d6f 100644
--- a/drivers/net/dsa/mv88e6xxx/Makefile
+++ b/drivers/net/dsa/mv88e6xxx/Makefile
@@ -2,5 +2,6 @@ obj-$(CONFIG_NET_DSA_MV88E6XXX) += mv88e6xxx.o
 mv88e6xxx-objs := chip.o
 mv88e6xxx-objs += global1.o
 mv88e6xxx-objs += global1_atu.o
+mv88e6xxx-objs += global1_vtu.o
 mv88e6xxx-$(CONFIG_NET_DSA_MV88E6XXX_GLOBAL2) += global2.o
 mv88e6xxx-objs += port.o
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index f025d3c22dba..bf0350432337 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -3,9 +3,6 @@
  *
  * Copyright (c) 2008 Marvell Semiconductor
  *
- * Copyright (c) 2015 CMC Electronics, Inc.
- *	Added support for VLAN Table Unit operations
- *
  * Copyright (c) 2016 Andrew Lunn <andrew@lunn.ch>
  *
  * Copyright (c) 2016-2017 Savoir-faire Linux Inc.
@@ -1266,31 +1263,15 @@ static void mv88e6xxx_port_fast_age(struct dsa_switch *ds, int port)
 		netdev_err(ds->ports[port].netdev, "failed to flush ATU\n");
 }
 
-static int _mv88e6xxx_vtu_wait(struct mv88e6xxx_chip *chip)
-{
-	return mv88e6xxx_g1_wait(chip, GLOBAL_VTU_OP, GLOBAL_VTU_OP_BUSY);
-}
-
-static int _mv88e6xxx_vtu_cmd(struct mv88e6xxx_chip *chip, u16 op)
-{
-	int err;
-
-	err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_OP, op);
-	if (err)
-		return err;
-
-	return _mv88e6xxx_vtu_wait(chip);
-}
-
 static int _mv88e6xxx_vtu_stu_flush(struct mv88e6xxx_chip *chip)
 {
 	int ret;
 
-	ret = _mv88e6xxx_vtu_wait(chip);
+	ret = mv88e6xxx_g1_vtu_op_wait(chip);
 	if (ret < 0)
 		return ret;
 
-	return _mv88e6xxx_vtu_cmd(chip, GLOBAL_VTU_OP_FLUSH_ALL);
+	return mv88e6xxx_g1_vtu_op(chip, GLOBAL_VTU_OP_FLUSH_ALL);
 }
 
 static int _mv88e6xxx_vtu_stu_data_read(struct mv88e6xxx_chip *chip,
@@ -1380,11 +1361,11 @@ static int _mv88e6xxx_vtu_getnext(struct mv88e6xxx_chip *chip,
 	u16 val;
 	int err;
 
-	err = _mv88e6xxx_vtu_wait(chip);
+	err = mv88e6xxx_g1_vtu_op_wait(chip);
 	if (err)
 		return err;
 
-	err = _mv88e6xxx_vtu_cmd(chip, GLOBAL_VTU_OP_VTU_GET_NEXT);
+	err = mv88e6xxx_g1_vtu_op(chip, GLOBAL_VTU_OP_VTU_GET_NEXT);
 	if (err)
 		return err;
 
@@ -1493,7 +1474,7 @@ static int _mv88e6xxx_vtu_loadpurge(struct mv88e6xxx_chip *chip,
 	u16 reg = 0;
 	int err;
 
-	err = _mv88e6xxx_vtu_wait(chip);
+	err = mv88e6xxx_g1_vtu_op_wait(chip);
 	if (err)
 		return err;
 
@@ -1532,7 +1513,7 @@ static int _mv88e6xxx_vtu_loadpurge(struct mv88e6xxx_chip *chip,
 	if (err)
 		return err;
 
-	return _mv88e6xxx_vtu_cmd(chip, op);
+	return mv88e6xxx_g1_vtu_op(chip, op);
 }
 
 static int _mv88e6xxx_stu_getnext(struct mv88e6xxx_chip *chip, u8 sid,
@@ -1542,7 +1523,7 @@ static int _mv88e6xxx_stu_getnext(struct mv88e6xxx_chip *chip, u8 sid,
 	u16 val;
 	int err;
 
-	err = _mv88e6xxx_vtu_wait(chip);
+	err = mv88e6xxx_g1_vtu_op_wait(chip);
 	if (err)
 		return err;
 
@@ -1551,7 +1532,7 @@ static int _mv88e6xxx_stu_getnext(struct mv88e6xxx_chip *chip, u8 sid,
 	if (err)
 		return err;
 
-	err = _mv88e6xxx_vtu_cmd(chip, GLOBAL_VTU_OP_STU_GET_NEXT);
+	err = mv88e6xxx_g1_vtu_op(chip, GLOBAL_VTU_OP_STU_GET_NEXT);
 	if (err)
 		return err;
 
@@ -1583,7 +1564,7 @@ static int _mv88e6xxx_stu_loadpurge(struct mv88e6xxx_chip *chip,
 	u16 reg = 0;
 	int err;
 
-	err = _mv88e6xxx_vtu_wait(chip);
+	err = mv88e6xxx_g1_vtu_op_wait(chip);
 	if (err)
 		return err;
 
@@ -1606,7 +1587,7 @@ static int _mv88e6xxx_stu_loadpurge(struct mv88e6xxx_chip *chip,
 	if (err)
 		return err;
 
-	return _mv88e6xxx_vtu_cmd(chip, GLOBAL_VTU_OP_STU_LOAD_PURGE);
+	return mv88e6xxx_g1_vtu_op(chip, GLOBAL_VTU_OP_STU_LOAD_PURGE);
 }
 
 static int mv88e6xxx_atu_new(struct mv88e6xxx_chip *chip, u16 *fid)
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
index e30cbe480d5b..c153d07d2065 100644
--- a/drivers/net/dsa/mv88e6xxx/global1.h
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -50,4 +50,7 @@ int mv88e6xxx_g1_atu_flush(struct mv88e6xxx_chip *chip, u16 fid, bool all);
 int mv88e6xxx_g1_atu_remove(struct mv88e6xxx_chip *chip, u16 fid, int port,
 			    bool all);
 
+int mv88e6xxx_g1_vtu_op_wait(struct mv88e6xxx_chip *chip);
+int mv88e6xxx_g1_vtu_op(struct mv88e6xxx_chip *chip, u16 op);
+
 #endif /* _MV88E6XXX_GLOBAL1_H */
diff --git a/drivers/net/dsa/mv88e6xxx/global1_vtu.c b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
new file mode 100644
index 000000000000..20dfdcbda238
--- /dev/null
+++ b/drivers/net/dsa/mv88e6xxx/global1_vtu.c
@@ -0,0 +1,33 @@
+/*
+ * Marvell 88E6xxx VLAN [Spanning Tree] Translation Unit (VTU [STU]) support
+ *
+ * Copyright (c) 2008 Marvell Semiconductor
+ * Copyright (c) 2015 CMC Electronics, Inc.
+ * Copyright (c) 2017 Savoir-faire Linux, Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include "mv88e6xxx.h"
+#include "global1.h"
+
+/* Offset 0x05: VTU Operation Register */
+
+int mv88e6xxx_g1_vtu_op_wait(struct mv88e6xxx_chip *chip)
+{
+	return mv88e6xxx_g1_wait(chip, GLOBAL_VTU_OP, GLOBAL_VTU_OP_BUSY);
+}
+
+int mv88e6xxx_g1_vtu_op(struct mv88e6xxx_chip *chip, u16 op)
+{
+	int err;
+
+	err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_OP, op);
+	if (err)
+		return err;
+
+	return mv88e6xxx_g1_vtu_op_wait(chip);
+}
-- 
2.12.2
