From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 01/10] net: dsa: mv88e6xxx: add global1 helpers
Date: Thu, 29 Sep 2016 12:21:53 -0400
Message-ID: <20160929162202.10685-2-vivien.didelot@savoirfairelinux.com>
References: <20160929162202.10685-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160929162202.10685-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Global (1) internal SMI device is an extended set of registers
containing ATU, PPU, VTU, STU, etc.

It is present on every switches, usually at SMI address 0x1B. But old
models such as 88E6060 access it at address 0xF, thus using REG_GLOBAL
is erroneous.

Add a global1_addr info member used by mv88e6xxx_g1_{read,write} and
mv88e6xxx_g1_wait helpers in a new global1.c file.

This patch finally removes _mv88e6xxx_reg_{read,write}, in favor on the
appropriate helpers. No functional changes here.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/Makefile    |   1 +
 drivers/net/dsa/mv88e6xxx/chip.c      | 505 +++++++++++++++++-----------------
 drivers/net/dsa/mv88e6xxx/global1.c   |  34 +++
 drivers/net/dsa/mv88e6xxx/global1.h   |  23 ++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |   2 +-
 5 files changed, 306 insertions(+), 259 deletions(-)
 create mode 100644 drivers/net/dsa/mv88e6xxx/global1.c
 create mode 100644 drivers/net/dsa/mv88e6xxx/global1.h

diff --git a/drivers/net/dsa/mv88e6xxx/Makefile b/drivers/net/dsa/mv88e6xxx/Makefile
index 6971039..10ce820 100644
--- a/drivers/net/dsa/mv88e6xxx/Makefile
+++ b/drivers/net/dsa/mv88e6xxx/Makefile
@@ -1,3 +1,4 @@
 obj-$(CONFIG_NET_DSA_MV88E6XXX) += mv88e6xxx.o
 mv88e6xxx-objs := chip.o
+mv88e6xxx-objs += global1.o
 mv88e6xxx-$(CONFIG_NET_DSA_MV88E6XXX_GLOBAL2) += global2.o
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index b2c25da..98dee2c 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -31,6 +31,7 @@
 #include <net/switchdev.h>
 
 #include "mv88e6xxx.h"
+#include "global1.h"
 #include "global2.h"
 
 static void assert_reg_lock(struct mv88e6xxx_chip *chip)
@@ -361,46 +362,27 @@ int mv88e6xxx_update(struct mv88e6xxx_chip *chip, int addr, int reg, u16 update)
 	return mv88e6xxx_write(chip, addr, reg, val);
 }
 
-static int _mv88e6xxx_reg_read(struct mv88e6xxx_chip *chip, int addr, int reg)
+static int mv88e6xxx_ppu_disable(struct mv88e6xxx_chip *chip)
 {
 	u16 val;
-	int err;
+	int i, err;
 
-	err = mv88e6xxx_read(chip, addr, reg, &val);
+	err = mv88e6xxx_g1_read(chip, GLOBAL_CONTROL, &val);
 	if (err)
 		return err;
 
-	return val;
-}
-
-static int _mv88e6xxx_reg_write(struct mv88e6xxx_chip *chip, int addr,
-				int reg, u16 val)
-{
-	return mv88e6xxx_write(chip, addr, reg, val);
-}
-
-static int mv88e6xxx_ppu_disable(struct mv88e6xxx_chip *chip)
-{
-	int ret;
-	int i;
-
-	ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL, GLOBAL_CONTROL);
-	if (ret < 0)
-		return ret;
-
-	ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_CONTROL,
-				   ret & ~GLOBAL_CONTROL_PPU_ENABLE);
-	if (ret)
-		return ret;
+	err = mv88e6xxx_g1_write(chip, GLOBAL_CONTROL,
+				 val & ~GLOBAL_CONTROL_PPU_ENABLE);
+	if (err)
+		return err;
 
 	for (i = 0; i < 16; i++) {
-		ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL, GLOBAL_STATUS);
-		if (ret < 0)
-			return ret;
+		err = mv88e6xxx_g1_read(chip, GLOBAL_STATUS, &val);
+		if (err)
+			return err;
 
 		usleep_range(1000, 2000);
-		if ((ret & GLOBAL_STATUS_PPU_MASK) !=
-		    GLOBAL_STATUS_PPU_POLLING)
+		if ((val & GLOBAL_STATUS_PPU_MASK) != GLOBAL_STATUS_PPU_POLLING)
 			return 0;
 	}
 
@@ -409,25 +391,25 @@ static int mv88e6xxx_ppu_disable(struct mv88e6xxx_chip *chip)
 
 static int mv88e6xxx_ppu_enable(struct mv88e6xxx_chip *chip)
 {
-	int ret, err, i;
+	u16 val;
+	int i, err;
 
-	ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL, GLOBAL_CONTROL);
-	if (ret < 0)
-		return ret;
+	err = mv88e6xxx_g1_read(chip, GLOBAL_CONTROL, &val);
+	if (err)
+		return err;
 
-	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_CONTROL,
-				   ret | GLOBAL_CONTROL_PPU_ENABLE);
+	err = mv88e6xxx_g1_write(chip, GLOBAL_CONTROL,
+				 val | GLOBAL_CONTROL_PPU_ENABLE);
 	if (err)
 		return err;
 
 	for (i = 0; i < 16; i++) {
-		ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL, GLOBAL_STATUS);
-		if (ret < 0)
-			return ret;
+		err = mv88e6xxx_g1_read(chip, GLOBAL_STATUS, &val);
+		if (err)
+			return err;
 
 		usleep_range(1000, 2000);
-		if ((ret & GLOBAL_STATUS_PPU_MASK) ==
-		    GLOBAL_STATUS_PPU_POLLING)
+		if ((val & GLOBAL_STATUS_PPU_MASK) == GLOBAL_STATUS_PPU_POLLING)
 			return 0;
 	}
 
@@ -663,12 +645,12 @@ out:
 
 static int _mv88e6xxx_stats_wait(struct mv88e6xxx_chip *chip)
 {
-	int ret;
-	int i;
+	u16 val;
+	int i, err;
 
 	for (i = 0; i < 10; i++) {
-		ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL, GLOBAL_STATS_OP);
-		if ((ret & GLOBAL_STATS_OP_BUSY) == 0)
+		err = mv88e6xxx_g1_read(chip, GLOBAL_STATS_OP, &val);
+		if ((val & GLOBAL_STATS_OP_BUSY) == 0)
 			return 0;
 	}
 
@@ -677,55 +659,52 @@ static int _mv88e6xxx_stats_wait(struct mv88e6xxx_chip *chip)
 
 static int _mv88e6xxx_stats_snapshot(struct mv88e6xxx_chip *chip, int port)
 {
-	int ret;
+	int err;
 
 	if (mv88e6xxx_6320_family(chip) || mv88e6xxx_6352_family(chip))
 		port = (port + 1) << 5;
 
 	/* Snapshot the hardware statistics counters for this port. */
-	ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_STATS_OP,
-				   GLOBAL_STATS_OP_CAPTURE_PORT |
-				   GLOBAL_STATS_OP_HIST_RX_TX | port);
-	if (ret < 0)
-		return ret;
+	err = mv88e6xxx_g1_write(chip, GLOBAL_STATS_OP,
+				 GLOBAL_STATS_OP_CAPTURE_PORT |
+				 GLOBAL_STATS_OP_HIST_RX_TX | port);
+	if (err)
+		return err;
 
 	/* Wait for the snapshotting to complete. */
-	ret = _mv88e6xxx_stats_wait(chip);
-	if (ret < 0)
-		return ret;
-
-	return 0;
+	return _mv88e6xxx_stats_wait(chip);
 }
 
 static void _mv88e6xxx_stats_read(struct mv88e6xxx_chip *chip,
 				  int stat, u32 *val)
 {
-	u32 _val;
-	int ret;
+	u32 value;
+	u16 reg;
+	int err;
 
 	*val = 0;
 
-	ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_STATS_OP,
-				   GLOBAL_STATS_OP_READ_CAPTURED |
-				   GLOBAL_STATS_OP_HIST_RX_TX | stat);
-	if (ret < 0)
+	err = mv88e6xxx_g1_write(chip, GLOBAL_STATS_OP,
+				 GLOBAL_STATS_OP_READ_CAPTURED |
+				 GLOBAL_STATS_OP_HIST_RX_TX | stat);
+	if (err)
 		return;
 
-	ret = _mv88e6xxx_stats_wait(chip);
-	if (ret < 0)
+	err = _mv88e6xxx_stats_wait(chip);
+	if (err)
 		return;
 
-	ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL, GLOBAL_STATS_COUNTER_32);
-	if (ret < 0)
+	err = mv88e6xxx_g1_read(chip, GLOBAL_STATS_COUNTER_32, &reg);
+	if (err)
 		return;
 
-	_val = ret << 16;
+	value = reg << 16;
 
-	ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL, GLOBAL_STATS_COUNTER_01);
-	if (ret < 0)
+	err = mv88e6xxx_g1_read(chip, GLOBAL_STATS_COUNTER_01, &reg);
+	if (err)
 		return;
 
-	*val = _val | ret;
+	*val = value | reg;
 }
 
 static struct mv88e6xxx_hw_stat mv88e6xxx_hw_stats[] = {
@@ -932,8 +911,7 @@ static void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
 
 static int _mv88e6xxx_atu_wait(struct mv88e6xxx_chip *chip)
 {
-	return mv88e6xxx_wait(chip, REG_GLOBAL, GLOBAL_ATU_OP,
-			      GLOBAL_ATU_OP_BUSY);
+	return mv88e6xxx_g1_wait(chip, GLOBAL_ATU_OP, GLOBAL_ATU_OP_BUSY);
 }
 
 static int mv88e6xxx_get_eee(struct dsa_switch *ds, int port,
@@ -997,32 +975,31 @@ out:
 
 static int _mv88e6xxx_atu_cmd(struct mv88e6xxx_chip *chip, u16 fid, u16 cmd)
 {
-	int ret;
+	u16 val;
+	int err;
 
 	if (mv88e6xxx_has_fid_reg(chip)) {
-		ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_ATU_FID,
-					   fid);
-		if (ret < 0)
-			return ret;
+		err = mv88e6xxx_g1_write(chip, GLOBAL_ATU_FID, fid);
+		if (err)
+			return err;
 	} else if (mv88e6xxx_num_databases(chip) == 256) {
 		/* ATU DBNum[7:4] are located in ATU Control 15:12 */
-		ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL, GLOBAL_ATU_CONTROL);
-		if (ret < 0)
-			return ret;
+		err = mv88e6xxx_g1_read(chip, GLOBAL_ATU_CONTROL, &val);
+		if (err)
+			return err;
 
-		ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_ATU_CONTROL,
-					   (ret & 0xfff) |
-					   ((fid << 8) & 0xf000));
-		if (ret < 0)
-			return ret;
+		err = mv88e6xxx_g1_write(chip, GLOBAL_ATU_CONTROL,
+					 (val & 0xfff) | ((fid << 8) & 0xf000));
+		if (err)
+			return err;
 
 		/* ATU DBNum[3:0] are located in ATU Operation 3:0 */
 		cmd |= fid & 0xf;
 	}
 
-	ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_ATU_OP, cmd);
-	if (ret < 0)
-		return ret;
+	err = mv88e6xxx_g1_write(chip, GLOBAL_ATU_OP, cmd);
+	if (err)
+		return err;
 
 	return _mv88e6xxx_atu_wait(chip);
 }
@@ -1047,7 +1024,7 @@ static int _mv88e6xxx_atu_data_write(struct mv88e6xxx_chip *chip,
 		data |= (entry->portv_trunkid << shift) & mask;
 	}
 
-	return _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_ATU_DATA, data);
+	return mv88e6xxx_g1_write(chip, GLOBAL_ATU_DATA, data);
 }
 
 static int _mv88e6xxx_atu_flush_move(struct mv88e6xxx_chip *chip,
@@ -1277,17 +1254,16 @@ static int _mv88e6xxx_port_pvid_set(struct mv88e6xxx_chip *chip,
 
 static int _mv88e6xxx_vtu_wait(struct mv88e6xxx_chip *chip)
 {
-	return mv88e6xxx_wait(chip, REG_GLOBAL, GLOBAL_VTU_OP,
-			      GLOBAL_VTU_OP_BUSY);
+	return mv88e6xxx_g1_wait(chip, GLOBAL_VTU_OP, GLOBAL_VTU_OP_BUSY);
 }
 
 static int _mv88e6xxx_vtu_cmd(struct mv88e6xxx_chip *chip, u16 op)
 {
-	int ret;
+	int err;
 
-	ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_VTU_OP, op);
-	if (ret < 0)
-		return ret;
+	err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_OP, op);
+	if (err)
+		return err;
 
 	return _mv88e6xxx_vtu_wait(chip);
 }
@@ -1308,16 +1284,14 @@ static int _mv88e6xxx_vtu_stu_data_read(struct mv88e6xxx_chip *chip,
 					unsigned int nibble_offset)
 {
 	u16 regs[3];
-	int i;
-	int ret;
+	int i, err;
 
 	for (i = 0; i < 3; ++i) {
-		ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL,
-					  GLOBAL_VTU_DATA_0_3 + i);
-		if (ret < 0)
-			return ret;
+		u16 *reg = &regs[i];
 
-		regs[i] = ret;
+		err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_DATA_0_3 + i, reg);
+		if (err)
+			return err;
 	}
 
 	for (i = 0; i < chip->info->num_ports; ++i) {
@@ -1347,8 +1321,7 @@ static int _mv88e6xxx_vtu_stu_data_write(struct mv88e6xxx_chip *chip,
 					 unsigned int nibble_offset)
 {
 	u16 regs[3] = { 0 };
-	int i;
-	int ret;
+	int i, err;
 
 	for (i = 0; i < chip->info->num_ports; ++i) {
 		unsigned int shift = (i % 4) * 4 + nibble_offset;
@@ -1358,10 +1331,11 @@ static int _mv88e6xxx_vtu_stu_data_write(struct mv88e6xxx_chip *chip,
 	}
 
 	for (i = 0; i < 3; ++i) {
-		ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL,
-					   GLOBAL_VTU_DATA_0_3 + i, regs[i]);
-		if (ret < 0)
-			return ret;
+		u16 reg = regs[i];
+
+		err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_DATA_0_3 + i, reg);
+		if (err)
+			return err;
 	}
 
 	return 0;
@@ -1381,63 +1355,61 @@ static int mv88e6xxx_stu_data_write(struct mv88e6xxx_chip *chip,
 
 static int _mv88e6xxx_vtu_vid_write(struct mv88e6xxx_chip *chip, u16 vid)
 {
-	return _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_VTU_VID,
-				    vid & GLOBAL_VTU_VID_MASK);
+	return mv88e6xxx_g1_write(chip, GLOBAL_VTU_VID,
+				  vid & GLOBAL_VTU_VID_MASK);
 }
 
 static int _mv88e6xxx_vtu_getnext(struct mv88e6xxx_chip *chip,
 				  struct mv88e6xxx_vtu_stu_entry *entry)
 {
 	struct mv88e6xxx_vtu_stu_entry next = { 0 };
-	int ret;
+	u16 val;
+	int err;
 
-	ret = _mv88e6xxx_vtu_wait(chip);
-	if (ret < 0)
-		return ret;
+	err = _mv88e6xxx_vtu_wait(chip);
+	if (err)
+		return err;
 
-	ret = _mv88e6xxx_vtu_cmd(chip, GLOBAL_VTU_OP_VTU_GET_NEXT);
-	if (ret < 0)
-		return ret;
+	err = _mv88e6xxx_vtu_cmd(chip, GLOBAL_VTU_OP_VTU_GET_NEXT);
+	if (err)
+		return err;
 
-	ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL, GLOBAL_VTU_VID);
-	if (ret < 0)
-		return ret;
+	err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_VID, &val);
+	if (err)
+		return err;
 
-	next.vid = ret & GLOBAL_VTU_VID_MASK;
-	next.valid = !!(ret & GLOBAL_VTU_VID_VALID);
+	next.vid = val & GLOBAL_VTU_VID_MASK;
+	next.valid = !!(val & GLOBAL_VTU_VID_VALID);
 
 	if (next.valid) {
-		ret = mv88e6xxx_vtu_data_read(chip, &next);
-		if (ret < 0)
-			return ret;
+		err = mv88e6xxx_vtu_data_read(chip, &next);
+		if (err)
+			return err;
 
 		if (mv88e6xxx_has_fid_reg(chip)) {
-			ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL,
-						  GLOBAL_VTU_FID);
-			if (ret < 0)
-				return ret;
+			err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_FID, &val);
+			if (err)
+				return err;
 
-			next.fid = ret & GLOBAL_VTU_FID_MASK;
+			next.fid = val & GLOBAL_VTU_FID_MASK;
 		} else if (mv88e6xxx_num_databases(chip) == 256) {
 			/* VTU DBNum[7:4] are located in VTU Operation 11:8, and
 			 * VTU DBNum[3:0] are located in VTU Operation 3:0
 			 */
-			ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL,
-						  GLOBAL_VTU_OP);
-			if (ret < 0)
-				return ret;
+			err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_OP, &val);
+			if (err)
+				return err;
 
-			next.fid = (ret & 0xf00) >> 4;
-			next.fid |= ret & 0xf;
+			next.fid = (val & 0xf00) >> 4;
+			next.fid |= val & 0xf;
 		}
 
 		if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_STU)) {
-			ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL,
-						  GLOBAL_VTU_SID);
-			if (ret < 0)
-				return ret;
+			err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_SID, &val);
+			if (err)
+				return err;
 
-			next.sid = ret & GLOBAL_VTU_SID_MASK;
+			next.sid = val & GLOBAL_VTU_SID_MASK;
 		}
 	}
 
@@ -1505,34 +1477,32 @@ static int _mv88e6xxx_vtu_loadpurge(struct mv88e6xxx_chip *chip,
 {
 	u16 op = GLOBAL_VTU_OP_VTU_LOAD_PURGE;
 	u16 reg = 0;
-	int ret;
+	int err;
 
-	ret = _mv88e6xxx_vtu_wait(chip);
-	if (ret < 0)
-		return ret;
+	err = _mv88e6xxx_vtu_wait(chip);
+	if (err)
+		return err;
 
 	if (!entry->valid)
 		goto loadpurge;
 
 	/* Write port member tags */
-	ret = mv88e6xxx_vtu_data_write(chip, entry);
-	if (ret < 0)
-		return ret;
+	err = mv88e6xxx_vtu_data_write(chip, entry);
+	if (err)
+		return err;
 
 	if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_STU)) {
 		reg = entry->sid & GLOBAL_VTU_SID_MASK;
-		ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_VTU_SID,
-					   reg);
-		if (ret < 0)
-			return ret;
+		err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_SID, reg);
+		if (err)
+			return err;
 	}
 
 	if (mv88e6xxx_has_fid_reg(chip)) {
 		reg = entry->fid & GLOBAL_VTU_FID_MASK;
-		ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_VTU_FID,
-					   reg);
-		if (ret < 0)
-			return ret;
+		err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_FID, reg);
+		if (err)
+			return err;
 	} else if (mv88e6xxx_num_databases(chip) == 256) {
 		/* VTU DBNum[7:4] are located in VTU Operation 11:8, and
 		 * VTU DBNum[3:0] are located in VTU Operation 3:0
@@ -1544,9 +1514,9 @@ static int _mv88e6xxx_vtu_loadpurge(struct mv88e6xxx_chip *chip,
 	reg = GLOBAL_VTU_VID_VALID;
 loadpurge:
 	reg |= entry->vid & GLOBAL_VTU_VID_MASK;
-	ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_VTU_VID, reg);
-	if (ret < 0)
-		return ret;
+	err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_VID, reg);
+	if (err)
+		return err;
 
 	return _mv88e6xxx_vtu_cmd(chip, op);
 }
@@ -1555,37 +1525,38 @@ static int _mv88e6xxx_stu_getnext(struct mv88e6xxx_chip *chip, u8 sid,
 				  struct mv88e6xxx_vtu_stu_entry *entry)
 {
 	struct mv88e6xxx_vtu_stu_entry next = { 0 };
-	int ret;
+	u16 val;
+	int err;
 
-	ret = _mv88e6xxx_vtu_wait(chip);
-	if (ret < 0)
-		return ret;
+	err = _mv88e6xxx_vtu_wait(chip);
+	if (err)
+		return err;
 
-	ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_VTU_SID,
-				   sid & GLOBAL_VTU_SID_MASK);
-	if (ret < 0)
-		return ret;
+	err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_SID,
+				 sid & GLOBAL_VTU_SID_MASK);
+	if (err)
+		return err;
 
-	ret = _mv88e6xxx_vtu_cmd(chip, GLOBAL_VTU_OP_STU_GET_NEXT);
-	if (ret < 0)
-		return ret;
+	err = _mv88e6xxx_vtu_cmd(chip, GLOBAL_VTU_OP_STU_GET_NEXT);
+	if (err)
+		return err;
 
-	ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL, GLOBAL_VTU_SID);
-	if (ret < 0)
-		return ret;
+	err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_SID, &val);
+	if (err)
+		return err;
 
-	next.sid = ret & GLOBAL_VTU_SID_MASK;
+	next.sid = val & GLOBAL_VTU_SID_MASK;
 
-	ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL, GLOBAL_VTU_VID);
-	if (ret < 0)
-		return ret;
+	err = mv88e6xxx_g1_read(chip, GLOBAL_VTU_VID, &val);
+	if (err)
+		return err;
 
-	next.valid = !!(ret & GLOBAL_VTU_VID_VALID);
+	next.valid = !!(val & GLOBAL_VTU_VID_VALID);
 
 	if (next.valid) {
-		ret = mv88e6xxx_stu_data_read(chip, &next);
-		if (ret < 0)
-			return ret;
+		err = mv88e6xxx_stu_data_read(chip, &next);
+		if (err)
+			return err;
 	}
 
 	*entry = next;
@@ -1596,30 +1567,30 @@ static int _mv88e6xxx_stu_loadpurge(struct mv88e6xxx_chip *chip,
 				    struct mv88e6xxx_vtu_stu_entry *entry)
 {
 	u16 reg = 0;
-	int ret;
+	int err;
 
-	ret = _mv88e6xxx_vtu_wait(chip);
-	if (ret < 0)
-		return ret;
+	err = _mv88e6xxx_vtu_wait(chip);
+	if (err)
+		return err;
 
 	if (!entry->valid)
 		goto loadpurge;
 
 	/* Write port states */
-	ret = mv88e6xxx_stu_data_write(chip, entry);
-	if (ret < 0)
-		return ret;
+	err = mv88e6xxx_stu_data_write(chip, entry);
+	if (err)
+		return err;
 
 	reg = GLOBAL_VTU_VID_VALID;
 loadpurge:
-	ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_VTU_VID, reg);
-	if (ret < 0)
-		return ret;
+	err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_VID, reg);
+	if (err)
+		return err;
 
 	reg = entry->sid & GLOBAL_VTU_SID_MASK;
-	ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_VTU_SID, reg);
-	if (ret < 0)
-		return ret;
+	err = mv88e6xxx_g1_write(chip, GLOBAL_VTU_SID, reg);
+	if (err)
+		return err;
 
 	return _mv88e6xxx_vtu_cmd(chip, GLOBAL_VTU_OP_STU_LOAD_PURGE);
 }
@@ -2057,14 +2028,13 @@ unlock:
 static int _mv88e6xxx_atu_mac_write(struct mv88e6xxx_chip *chip,
 				    const unsigned char *addr)
 {
-	int i, ret;
+	int i, err;
 
 	for (i = 0; i < 3; i++) {
-		ret = _mv88e6xxx_reg_write(
-			chip, REG_GLOBAL, GLOBAL_ATU_MAC_01 + i,
-			(addr[i * 2] << 8) | addr[i * 2 + 1]);
-		if (ret < 0)
-			return ret;
+		err = mv88e6xxx_g1_write(chip, GLOBAL_ATU_MAC_01 + i,
+					 (addr[i * 2] << 8) | addr[i * 2 + 1]);
+		if (err)
+			return err;
 	}
 
 	return 0;
@@ -2073,15 +2043,16 @@ static int _mv88e6xxx_atu_mac_write(struct mv88e6xxx_chip *chip,
 static int _mv88e6xxx_atu_mac_read(struct mv88e6xxx_chip *chip,
 				   unsigned char *addr)
 {
-	int i, ret;
+	u16 val;
+	int i, err;
 
 	for (i = 0; i < 3; i++) {
-		ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL,
-					  GLOBAL_ATU_MAC_01 + i);
-		if (ret < 0)
-			return ret;
-		addr[i * 2] = ret >> 8;
-		addr[i * 2 + 1] = ret & 0xff;
+		err = mv88e6xxx_g1_read(chip, GLOBAL_ATU_MAC_01 + i, &val);
+		if (err)
+			return err;
+
+		addr[i * 2] = val >> 8;
+		addr[i * 2 + 1] = val & 0xff;
 	}
 
 	return 0;
@@ -2217,31 +2188,32 @@ static int _mv88e6xxx_atu_getnext(struct mv88e6xxx_chip *chip, u16 fid,
 				  struct mv88e6xxx_atu_entry *entry)
 {
 	struct mv88e6xxx_atu_entry next = { 0 };
-	int ret;
+	u16 val;
+	int err;
 
 	next.fid = fid;
 
-	ret = _mv88e6xxx_atu_wait(chip);
-	if (ret < 0)
-		return ret;
+	err = _mv88e6xxx_atu_wait(chip);
+	if (err)
+		return err;
 
-	ret = _mv88e6xxx_atu_cmd(chip, fid, GLOBAL_ATU_OP_GET_NEXT_DB);
-	if (ret < 0)
-		return ret;
+	err = _mv88e6xxx_atu_cmd(chip, fid, GLOBAL_ATU_OP_GET_NEXT_DB);
+	if (err)
+		return err;
 
-	ret = _mv88e6xxx_atu_mac_read(chip, next.mac);
-	if (ret < 0)
-		return ret;
+	err = _mv88e6xxx_atu_mac_read(chip, next.mac);
+	if (err)
+		return err;
 
-	ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL, GLOBAL_ATU_DATA);
-	if (ret < 0)
-		return ret;
+	err = mv88e6xxx_g1_read(chip, GLOBAL_ATU_DATA, &val);
+	if (err)
+		return err;
 
-	next.state = ret & GLOBAL_ATU_DATA_STATE_MASK;
+	next.state = val & GLOBAL_ATU_DATA_STATE_MASK;
 	if (next.state != GLOBAL_ATU_DATA_STATE_UNUSED) {
 		unsigned int mask, shift;
 
-		if (ret & GLOBAL_ATU_DATA_TRUNK) {
+		if (val & GLOBAL_ATU_DATA_TRUNK) {
 			next.trunk = true;
 			mask = GLOBAL_ATU_DATA_TRUNK_ID_MASK;
 			shift = GLOBAL_ATU_DATA_TRUNK_ID_SHIFT;
@@ -2251,7 +2223,7 @@ static int _mv88e6xxx_atu_getnext(struct mv88e6xxx_chip *chip, u16 fid,
 			shift = GLOBAL_ATU_DATA_PORT_VECTOR_SHIFT;
 		}
 
-		next.portv_trunkid = (ret & mask) >> shift;
+		next.portv_trunkid = (val & mask) >> shift;
 	}
 
 	*entry = next;
@@ -2422,8 +2394,8 @@ static int mv88e6xxx_switch_reset(struct mv88e6xxx_chip *chip)
 	u16 is_reset = (ppu_active ? 0x8800 : 0xc800);
 	struct gpio_desc *gpiod = chip->reset;
 	unsigned long timeout;
-	int err, ret;
 	u16 reg;
+	int err;
 	int i;
 
 	/* Set all ports to the disabled state. */
@@ -2454,20 +2426,20 @@ static int mv88e6xxx_switch_reset(struct mv88e6xxx_chip *chip)
 	 * through global registers 0x18 and 0x19.
 	 */
 	if (ppu_active)
-		err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, 0x04, 0xc000);
+		err = mv88e6xxx_g1_write(chip, 0x04, 0xc000);
 	else
-		err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, 0x04, 0xc400);
+		err = mv88e6xxx_g1_write(chip, 0x04, 0xc400);
 	if (err)
 		return err;
 
 	/* Wait up to one second for reset to complete. */
 	timeout = jiffies + 1 * HZ;
 	while (time_before(jiffies, timeout)) {
-		ret = _mv88e6xxx_reg_read(chip, REG_GLOBAL, 0x00);
-		if (ret < 0)
-			return ret;
+		err = mv88e6xxx_g1_read(chip, 0x00, &reg);
+		if (err)
+			return err;
 
-		if ((ret & is_reset) == is_reset)
+		if ((reg & is_reset) == is_reset)
 			break;
 		usleep_range(1000, 2000);
 	}
@@ -2749,22 +2721,23 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	return mv88e6xxx_port_write(chip, port, PORT_DEFAULT_VLAN, 0x0000);
 }
 
-static int mv88e6xxx_g1_set_switch_mac(struct mv88e6xxx_chip *chip, u8 *addr)
+int mv88e6xxx_g1_set_switch_mac(struct mv88e6xxx_chip *chip, u8 *addr)
 {
 	int err;
 
-	err = mv88e6xxx_write(chip, REG_GLOBAL, GLOBAL_MAC_01,
-			      (addr[0] << 8) | addr[1]);
+	err = mv88e6xxx_g1_write(chip, GLOBAL_MAC_01, (addr[0] << 8) | addr[1]);
 	if (err)
 		return err;
 
-	err = mv88e6xxx_write(chip, REG_GLOBAL, GLOBAL_MAC_23,
-			      (addr[2] << 8) | addr[3]);
+	err = mv88e6xxx_g1_write(chip, GLOBAL_MAC_23, (addr[2] << 8) | addr[3]);
 	if (err)
 		return err;
 
-	return mv88e6xxx_write(chip, REG_GLOBAL, GLOBAL_MAC_45,
-			       (addr[4] << 8) | addr[5]);
+	err = mv88e6xxx_g1_write(chip, GLOBAL_MAC_45, (addr[4] << 8) | addr[5]);
+	if (err)
+		return err;
+
+	return 0;
 }
 
 static int mv88e6xxx_g1_set_age_time(struct mv88e6xxx_chip *chip,
@@ -2783,7 +2756,7 @@ static int mv88e6xxx_g1_set_age_time(struct mv88e6xxx_chip *chip,
 	/* Round to nearest multiple of coeff */
 	age_time = (msecs + coeff / 2) / coeff;
 
-	err = mv88e6xxx_read(chip, REG_GLOBAL, GLOBAL_ATU_CONTROL, &val);
+	err = mv88e6xxx_g1_read(chip, GLOBAL_ATU_CONTROL, &val);
 	if (err)
 		return err;
 
@@ -2791,7 +2764,7 @@ static int mv88e6xxx_g1_set_age_time(struct mv88e6xxx_chip *chip,
 	val &= ~0xff0;
 	val |= age_time << 4;
 
-	return mv88e6xxx_write(chip, REG_GLOBAL, GLOBAL_ATU_CONTROL, val);
+	return mv88e6xxx_g1_write(chip, GLOBAL_ATU_CONTROL, val);
 }
 
 static int mv88e6xxx_set_ageing_time(struct dsa_switch *ds,
@@ -2822,7 +2795,7 @@ static int mv88e6xxx_g1_setup(struct mv88e6xxx_chip *chip)
 	    mv88e6xxx_has(chip, MV88E6XXX_FLAG_PPU_ACTIVE))
 		reg |= GLOBAL_CONTROL_PPU_ENABLE;
 
-	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_CONTROL, reg);
+	err = mv88e6xxx_g1_write(chip, GLOBAL_CONTROL, reg);
 	if (err)
 		return err;
 
@@ -2832,15 +2805,14 @@ static int mv88e6xxx_g1_setup(struct mv88e6xxx_chip *chip)
 	reg = upstream_port << GLOBAL_MONITOR_CONTROL_INGRESS_SHIFT |
 		upstream_port << GLOBAL_MONITOR_CONTROL_EGRESS_SHIFT |
 		upstream_port << GLOBAL_MONITOR_CONTROL_ARP_SHIFT;
-	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_MONITOR_CONTROL,
-				   reg);
+	err = mv88e6xxx_g1_write(chip, GLOBAL_MONITOR_CONTROL, reg);
 	if (err)
 		return err;
 
 	/* Disable remote management, and set the switch's DSA device number. */
-	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_CONTROL_2,
-				   GLOBAL_CONTROL_2_MULTIPLE_CASCADE |
-				   (ds->index & 0x1f));
+	err = mv88e6xxx_g1_write(chip, GLOBAL_CONTROL_2,
+				 GLOBAL_CONTROL_2_MULTIPLE_CASCADE |
+				 (ds->index & 0x1f));
 	if (err)
 		return err;
 
@@ -2853,8 +2825,8 @@ static int mv88e6xxx_g1_setup(struct mv88e6xxx_chip *chip)
 	 * enable address learn messages to be sent to all message
 	 * ports.
 	 */
-	err = mv88e6xxx_write(chip, REG_GLOBAL, GLOBAL_ATU_CONTROL,
-			      GLOBAL_ATU_CONTROL_LEARN2ALL);
+	err = mv88e6xxx_g1_write(chip, GLOBAL_ATU_CONTROL,
+				 GLOBAL_ATU_CONTROL_LEARN2ALL);
 	if (err)
 		return err;
 
@@ -2868,39 +2840,39 @@ static int mv88e6xxx_g1_setup(struct mv88e6xxx_chip *chip)
 		return err;
 
 	/* Configure the IP ToS mapping registers. */
-	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_IP_PRI_0, 0x0000);
+	err = mv88e6xxx_g1_write(chip, GLOBAL_IP_PRI_0, 0x0000);
 	if (err)
 		return err;
-	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_IP_PRI_1, 0x0000);
+	err = mv88e6xxx_g1_write(chip, GLOBAL_IP_PRI_1, 0x0000);
 	if (err)
 		return err;
-	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_IP_PRI_2, 0x5555);
+	err = mv88e6xxx_g1_write(chip, GLOBAL_IP_PRI_2, 0x5555);
 	if (err)
 		return err;
-	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_IP_PRI_3, 0x5555);
+	err = mv88e6xxx_g1_write(chip, GLOBAL_IP_PRI_3, 0x5555);
 	if (err)
 		return err;
-	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_IP_PRI_4, 0xaaaa);
+	err = mv88e6xxx_g1_write(chip, GLOBAL_IP_PRI_4, 0xaaaa);
 	if (err)
 		return err;
-	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_IP_PRI_5, 0xaaaa);
+	err = mv88e6xxx_g1_write(chip, GLOBAL_IP_PRI_5, 0xaaaa);
 	if (err)
 		return err;
-	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_IP_PRI_6, 0xffff);
+	err = mv88e6xxx_g1_write(chip, GLOBAL_IP_PRI_6, 0xffff);
 	if (err)
 		return err;
-	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_IP_PRI_7, 0xffff);
+	err = mv88e6xxx_g1_write(chip, GLOBAL_IP_PRI_7, 0xffff);
 	if (err)
 		return err;
 
 	/* Configure the IEEE 802.1p priority mapping register. */
-	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_IEEE_PRI, 0xfa41);
+	err = mv88e6xxx_g1_write(chip, GLOBAL_IEEE_PRI, 0xfa41);
 	if (err)
 		return err;
 
 	/* Clear the statistics counters for all ports */
-	err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, GLOBAL_STATS_OP,
-				   GLOBAL_STATS_OP_FLUSH_ALL);
+	err = mv88e6xxx_g1_write(chip, GLOBAL_STATS_OP,
+				 GLOBAL_STATS_OP_FLUSH_ALL);
 	if (err)
 		return err;
 
@@ -3265,6 +3237,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 4096,
 		.num_ports = 10,
 		.port_base_addr = 0x10,
+		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6097,
 	},
@@ -3276,6 +3249,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 256,
 		.num_ports = 11,
 		.port_base_addr = 0x10,
+		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6095,
 	},
@@ -3287,6 +3261,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 4096,
 		.num_ports = 3,
 		.port_base_addr = 0x10,
+		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 	},
@@ -3298,6 +3273,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 256,
 		.num_ports = 8,
 		.port_base_addr = 0x10,
+		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6185,
 	},
@@ -3309,6 +3285,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 4096,
 		.num_ports = 6,
 		.port_base_addr = 0x10,
+		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 	},
@@ -3320,6 +3297,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 4096,
 		.num_ports = 6,
 		.port_base_addr = 0x10,
+		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6165,
 	},
@@ -3331,6 +3309,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 4096,
 		.num_ports = 7,
 		.port_base_addr = 0x10,
+		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 	},
@@ -3342,6 +3321,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 4096,
 		.num_ports = 7,
 		.port_base_addr = 0x10,
+		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 	},
@@ -3353,6 +3333,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 4096,
 		.num_ports = 7,
 		.port_base_addr = 0x10,
+		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 	},
@@ -3364,6 +3345,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 4096,
 		.num_ports = 7,
 		.port_base_addr = 0x10,
+		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 	},
@@ -3375,6 +3357,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 256,
 		.num_ports = 10,
 		.port_base_addr = 0x10,
+		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6185,
 	},
@@ -3386,6 +3369,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 4096,
 		.num_ports = 7,
 		.port_base_addr = 0x10,
+		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 	},
@@ -3397,6 +3381,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 4096,
 		.num_ports = 7,
 		.port_base_addr = 0x10,
+		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6320,
 	},
@@ -3408,6 +3393,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 4096,
 		.num_ports = 7,
 		.port_base_addr = 0x10,
+		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6320,
 	},
@@ -3419,6 +3405,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 4096,
 		.num_ports = 7,
 		.port_base_addr = 0x10,
+		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 	},
@@ -3430,6 +3417,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 4096,
 		.num_ports = 7,
 		.port_base_addr = 0x10,
+		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6351,
 	},
@@ -3441,6 +3429,7 @@ static const struct mv88e6xxx_info mv88e6xxx_table[] = {
 		.num_databases = 4096,
 		.num_ports = 7,
 		.port_base_addr = 0x10,
+		.global1_addr = 0x1b,
 		.age_time_coeff = 15000,
 		.flags = MV88E6XXX_FLAGS_FAMILY_6352,
 	},
diff --git a/drivers/net/dsa/mv88e6xxx/global1.c b/drivers/net/dsa/mv88e6xxx/global1.c
new file mode 100644
index 0000000..d358720
--- /dev/null
+++ b/drivers/net/dsa/mv88e6xxx/global1.c
@@ -0,0 +1,34 @@
+/*
+ * Marvell 88E6xxx Switch Global (1) Registers support
+ *
+ * Copyright (c) 2008 Marvell Semiconductor
+ *
+ * Copyright (c) 2016 Vivien Didelot <vivien.didelot@savoirfairelinux.com>
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
+int mv88e6xxx_g1_read(struct mv88e6xxx_chip *chip, int reg, u16 *val)
+{
+	int addr = chip->info->global1_addr;
+
+	return mv88e6xxx_read(chip, addr, reg, val);
+}
+
+int mv88e6xxx_g1_write(struct mv88e6xxx_chip *chip, int reg, u16 val)
+{
+	int addr = chip->info->global1_addr;
+
+	return mv88e6xxx_write(chip, addr, reg, val);
+}
+
+int mv88e6xxx_g1_wait(struct mv88e6xxx_chip *chip, int reg, u16 mask)
+{
+	return mv88e6xxx_wait(chip, chip->info->global1_addr, reg, mask);
+}
diff --git a/drivers/net/dsa/mv88e6xxx/global1.h b/drivers/net/dsa/mv88e6xxx/global1.h
new file mode 100644
index 0000000..62291e6
--- /dev/null
+++ b/drivers/net/dsa/mv88e6xxx/global1.h
@@ -0,0 +1,23 @@
+/*
+ * Marvell 88E6xxx Switch Global (1) Registers support
+ *
+ * Copyright (c) 2008 Marvell Semiconductor
+ *
+ * Copyright (c) 2016 Vivien Didelot <vivien.didelot@savoirfairelinux.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _MV88E6XXX_GLOBAL1_H
+#define _MV88E6XXX_GLOBAL1_H
+
+#include "mv88e6xxx.h"
+
+int mv88e6xxx_g1_read(struct mv88e6xxx_chip *chip, int reg, u16 *val);
+int mv88e6xxx_g1_write(struct mv88e6xxx_chip *chip, int reg, u16 val);
+int mv88e6xxx_g1_wait(struct mv88e6xxx_chip *chip, int reg, u16 mask);
+
+#endif /* _MV88E6XXX_GLOBAL1_H */
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 8279883..bf78f6d 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -159,7 +159,6 @@
 #define PORT_TAG_REGMAP_0123	0x18
 #define PORT_TAG_REGMAP_4567	0x19
 
-#define REG_GLOBAL		0x1b
 #define GLOBAL_STATUS		0x00
 #define GLOBAL_STATUS_PPU_STATE BIT(15) /* 6351 and 6171 */
 /* Two bits for 6165, 6185 etc */
@@ -613,6 +612,7 @@ struct mv88e6xxx_info {
 	unsigned int num_databases;
 	unsigned int num_ports;
 	unsigned int port_base_addr;
+	unsigned int global1_addr;
 	unsigned int age_time_coeff;
 	unsigned long long flags;
 };
-- 
2.10.0
