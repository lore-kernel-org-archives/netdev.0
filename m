From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 06/10] chelsio: cleanup pm3393 code
Date: Fri, 01 Dec 2006 16:36:18 -0800
Message-ID: <20061202003707.591450000@osdl.org>
References: <20061202003612.573260000@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:48354 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1162422AbWLBAjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Dec 2006 19:39:40 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=pm3393-rmon.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace macro with function for updating RMON values

Cleanups:
	* remove unused enum's
	* Fix comment format

Signed-off-by: Stephen HEmminger <shemminger@osdl.org>

---
 drivers/net/chelsio/pm3393.c |   69 ++++++++++++++++++-------------------------
 1 file changed, 29 insertions(+), 40 deletions(-)

--- chelsio-t2.orig/drivers/net/chelsio/pm3393.c
+++ chelsio-t2/drivers/net/chelsio/pm3393.c
@@ -43,22 +43,6 @@
 #include "elmer0.h"
 #include "suni1x10gexp_regs.h"
 
-/* 802.3ae 10Gb/s MDIO Manageable Device(MMD)
- */
-enum {
-	MMD_RESERVED,
-	MMD_PMAPMD,
-	MMD_WIS,
-	MMD_PCS,
-	MMD_PHY_XGXS,	/* XGMII Extender Sublayer */
-	MMD_DTE_XGXS,
-};
-
-enum {
-	PHY_XGXS_CTRL_1,
-	PHY_XGXS_STATUS_1
-};
-
 #define OFFSET(REG_ADDR)    (REG_ADDR << 2)
 
 /* Max frame size PM3393 can handle. Includes Ethernet header and CRC. */
@@ -128,12 +112,12 @@ static int pm3393_reset(struct cmac *cma
 
 /*
  * Enable interrupts for the PM3393
-
-	1. Enable PM3393 BLOCK interrupts.
-	2. Enable PM3393 Master Interrupt bit(INTE)
-	3. Enable ELMER's PM3393 bit.
-	4. Enable Terminator external interrupt.
-*/
+ *
+ *	1. Enable PM3393 BLOCK interrupts.
+ *	2. Enable PM3393 Master Interrupt bit(INTE)
+ *	3. Enable ELMER's PM3393 bit.
+ *	4. Enable Terminator external interrupt.
+ */
 static int pm3393_interrupt_enable(struct cmac *cmac)
 {
 	u32 pl_intr;
@@ -261,11 +245,7 @@ static int pm3393_interrupt_clear(struct
 static int pm3393_interrupt_handler(struct cmac *cmac)
 {
 	u32 master_intr_status;
-/*
-	1. Read master interrupt register.
-	2. Read BLOCK's interrupt status registers.
-	3. Handle BLOCK interrupts.
-*/
+
 	/* Read the master interrupt status register. */
 	pmread(cmac, SUNI1x10GEXP_REG_MASTER_INTERRUPT_STATUS,
 	       &master_intr_status);
@@ -473,20 +453,29 @@ static int pm3393_set_speed_duplex_fc(st
 	return 0;
 }
 
+static void pm3393_rmon_update(struct adapter *adapter, u32 offs, u64 *val,
+			       int over)
+{
+	u32 val0, val1, val2;
+
+	t1_tpi_read(adapter, offs, &val0);
+	t1_tpi_read(adapter, offs + 4, &val1);
+	t1_tpi_read(adapter, offs + 8, &val2);
+
+	*val &= ~0ull << 40;
+	*val |= val0 & 0xffff;
+	*val |= (val1 & 0xffff) << 16;
+	*val |= (u64)(val2 & 0xff) << 32;
+
+	if (over)
+		*val += 1ull << 40;
+}
+
 #define RMON_UPDATE(mac, name, stat_name) \
-	{ \
-		t1_tpi_read((mac)->adapter, OFFSET(name), &val0);	\
-		t1_tpi_read((mac)->adapter, OFFSET(((name)+1)), &val1); \
-		t1_tpi_read((mac)->adapter, OFFSET(((name)+2)), &val2); \
-		(mac)->stats.stat_name = ((u64)val0 & 0xffff) | \
-						(((u64)val1 & 0xffff) << 16) | \
-						(((u64)val2 & 0xff) << 32) | \
-						((mac)->stats.stat_name & \
-							(~(u64)0 << 40)); \
-		if (ro &	\
-			((name -  SUNI1x10GEXP_REG_MSTAT_COUNTER_0_LOW) >> 2)) \
-			(mac)->stats.stat_name += ((u64)1 << 40); \
-	}
+	pm3393_rmon_update((mac)->adapter, OFFSET(name), 		\
+			   &(mac)->stats.stat_name,			\
+		   (ro &((name - SUNI1x10GEXP_REG_MSTAT_COUNTER_0_LOW) >> 2)))
+
 
 static const struct cmac_statistics *pm3393_update_statistics(struct cmac *mac,
 							      int flag)

-- 

