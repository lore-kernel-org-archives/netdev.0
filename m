From: Timur Tabi <timur@freescale.com>
Subject: [PATCH 1/7] net/freescale: do not export any functions from fsl_pq_mdio.c
Date: Wed, 29 Aug 2012 13:07:57 -0500
Message-ID: <1346263683-3664-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
To: Andy Fleming <afleming@freescale.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe003.messaging.microsoft.com ([216.32.180.186]:13163
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754459Ab2H2SIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2012 14:08:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

None of the functions in fsl_pq_mdio.c are used by any other source file,
so there's no point in exporting them.  Merge the header file into the
source file, make all the functions static, remove any EXPORT_SYMBOL
statements, and delete any #include "fsl_pq_mdio.h" statements.

Signed-off-by: Timur Tabi <timur@freescale.com>
---
 drivers/net/ethernet/freescale/fsl_pq_mdio.c |   38 +++++++++++++++---
 drivers/net/ethernet/freescale/fsl_pq_mdio.h |   52 --------------------------
 drivers/net/ethernet/freescale/gianfar.c     |    1 -
 drivers/net/ethernet/freescale/ucc_geth.c    |    1 -
 4 files changed, 31 insertions(+), 61 deletions(-)
 delete mode 100644 drivers/net/ethernet/freescale/fsl_pq_mdio.h

diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
index 9527b28..bc19fe0 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -45,7 +45,31 @@
 #include <asm/ucc.h>
 
 #include "gianfar.h"
-#include "fsl_pq_mdio.h"
+
+#define MIIMIND_BUSY		0x00000001
+#define MIIMIND_NOTVALID	0x00000004
+#define MIIMCFG_INIT_VALUE	0x00000007
+#define MIIMCFG_RESET		0x80000000
+
+#define MII_READ_COMMAND	0x00000001
+
+struct fsl_pq_mdio {
+	u8 res1[16];
+	u32 ieventm;	/* MDIO Interrupt event register (for etsec2)*/
+	u32 imaskm;	/* MDIO Interrupt mask register (for etsec2)*/
+	u8 res2[4];
+	u32 emapm;	/* MDIO Event mapping register (for etsec2)*/
+	u8 res3[1280];
+	u32 miimcfg;	/* MII management configuration reg */
+	u32 miimcom;	/* MII management command reg */
+	u32 miimadd;	/* MII management address reg */
+	u32 miimcon;	/* MII management control reg */
+	u32 miimstat;	/* MII management status reg */
+	u32 miimind;	/* MII management indication reg */
+	u8 res4[28];
+	u32 utbipar;	/* TBI phy address reg (only on UCC) */
+	u8 res5[2728];
+} __packed;
 
 /* Number of microseconds to wait for an MII register to respond */
 #define MII_TIMEOUT	1000
@@ -64,7 +88,7 @@ struct fsl_pq_mdio_priv {
  * the local mdio pins, which may not be the same as system mdio bus, used for
  * controlling the external PHYs, for example.
  */
-int fsl_pq_local_mdio_write(struct fsl_pq_mdio __iomem *regs, int mii_id,
+static int fsl_pq_local_mdio_write(struct fsl_pq_mdio __iomem *regs, int mii_id,
 		int regnum, u16 value)
 {
 	u32 status;
@@ -92,7 +116,7 @@ int fsl_pq_local_mdio_write(struct fsl_pq_mdio __iomem *regs, int mii_id,
  * and are always tied to the local mdio pins, which may not be the
  * same as system mdio bus, used for controlling the external PHYs, for eg.
  */
-int fsl_pq_local_mdio_read(struct fsl_pq_mdio __iomem *regs,
+static int fsl_pq_local_mdio_read(struct fsl_pq_mdio __iomem *regs,
 		int mii_id, int regnum)
 {
 	u16 value;
@@ -129,7 +153,8 @@ static struct fsl_pq_mdio __iomem *fsl_pq_mdio_get_regs(struct mii_bus *bus)
  * Write value to the PHY at mii_id at register regnum,
  * on the bus, waiting until the write is done before returning.
  */
-int fsl_pq_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value)
+static int fsl_pq_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
+		u16 value)
 {
 	struct fsl_pq_mdio __iomem *regs = fsl_pq_mdio_get_regs(bus);
 
@@ -141,7 +166,7 @@ int fsl_pq_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value)
  * Read the bus for PHY at addr mii_id, register regnum, and
  * return the value.  Clears miimcom first.
  */
-int fsl_pq_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
+static int fsl_pq_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 {
 	struct fsl_pq_mdio __iomem *regs = fsl_pq_mdio_get_regs(bus);
 
@@ -178,7 +203,7 @@ static int fsl_pq_mdio_reset(struct mii_bus *bus)
 	return 0;
 }
 
-void fsl_pq_mdio_bus_name(char *name, struct device_node *np)
+static void fsl_pq_mdio_bus_name(char *name, struct device_node *np)
 {
 	const u32 *addr;
 	u64 taddr = OF_BAD_ADDR;
@@ -190,7 +215,6 @@ void fsl_pq_mdio_bus_name(char *name, struct device_node *np)
 	snprintf(name, MII_BUS_ID_SIZE, "%s@%llx", np->name,
 		(unsigned long long)taddr);
 }
-EXPORT_SYMBOL_GPL(fsl_pq_mdio_bus_name);
 
 
 static u32 __iomem *get_gfar_tbipa(struct fsl_pq_mdio __iomem *regs, struct device_node *np)
diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.h b/drivers/net/ethernet/freescale/fsl_pq_mdio.h
deleted file mode 100644
index bd17a2a..0000000
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.h
+++ /dev/null
@@ -1,52 +0,0 @@
-/*
- * Freescale PowerQUICC MDIO Driver -- MII Management Bus Implementation
- * Driver for the MDIO bus controller on Freescale PowerQUICC processors
- *
- * Author: Andy Fleming
- * Modifier: Sandeep Gopalpet
- *
- * Copyright 2002-2004, 2008-2009 Freescale Semiconductor, Inc.
- *
- * This program is free software; you can redistribute  it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
- *
- */
-#ifndef __FSL_PQ_MDIO_H
-#define __FSL_PQ_MDIO_H
-
-#define MIIMIND_BUSY            0x00000001
-#define MIIMIND_NOTVALID        0x00000004
-#define MIIMCFG_INIT_VALUE	0x00000007
-#define MIIMCFG_RESET           0x80000000
-
-#define MII_READ_COMMAND       0x00000001
-
-struct fsl_pq_mdio {
-	u8 res1[16];
-	u32 ieventm;	/* MDIO Interrupt event register (for etsec2)*/
-	u32 imaskm;	/* MDIO Interrupt mask register (for etsec2)*/
-	u8 res2[4];
-	u32 emapm;	/* MDIO Event mapping register (for etsec2)*/
-	u8 res3[1280];
-	u32 miimcfg;		/* MII management configuration reg */
-	u32 miimcom;		/* MII management command reg */
-	u32 miimadd;		/* MII management address reg */
-	u32 miimcon;		/* MII management control reg */
-	u32 miimstat;		/* MII management status reg */
-	u32 miimind;		/* MII management indication reg */
-	u8 reserved[28];	/* Space holder */
-	u32 utbipar;		/* TBI phy address reg (only on UCC) */
-	u8 res4[2728];
-} __packed;
-
-int fsl_pq_mdio_read(struct mii_bus *bus, int mii_id, int regnum);
-int fsl_pq_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value);
-int fsl_pq_local_mdio_write(struct fsl_pq_mdio __iomem *regs, int mii_id,
-			  int regnum, u16 value);
-int fsl_pq_local_mdio_read(struct fsl_pq_mdio __iomem *regs, int mii_id, int regnum);
-int __init fsl_pq_mdio_init(void);
-void fsl_pq_mdio_exit(void);
-void fsl_pq_mdio_bus_name(char *name, struct device_node *np);
-#endif /* FSL_PQ_MDIO_H */
diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 4605f72..f762a7f 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -100,7 +100,6 @@
 #include <linux/of_net.h>
 
 #include "gianfar.h"
-#include "fsl_pq_mdio.h"
 
 #define TX_TIMEOUT      (1*HZ)
 
diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index 21c6574..1642884 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -42,7 +42,6 @@
 #include <asm/machdep.h>
 
 #include "ucc_geth.h"
-#include "fsl_pq_mdio.h"
 
 #undef DEBUG
 
-- 
1.7.3.4
