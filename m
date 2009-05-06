From: Wolfgang Denk <wd@denx.de>
Subject: [PATCH 02/12] fs_enet: Add MPC5121 FEC support.
Date: Wed,  6 May 2009 22:15:09 +0200
Message-ID: <1241640919-4650-3-git-send-email-wd@denx.de>
References: <1241640919-4650-1-git-send-email-wd@denx.de>
Cc: John Rigby <jrigby@freescale.com>,
	Piotr Ziecik <kosmo@semihalf.com>, Wolfgang Denk <wd@denx.de>,
	<netdev@vger.kernel.org>, Grant Likely <grant.likely@secretlab.ca>,
	John Rigby <jcrigby@gmail.com>
To: linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:34891 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755567AbZEFUPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 16:15:23 -0400
In-Reply-To: <1241640919-4650-1-git-send-email-wd@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Rigby <jrigby@freescale.com>

Add support for MPC512x to fs_enet driver

    drivers/net/fs_enet/*
        Enable fs_enet driver to work 5121 FEC
        Enable it with CONFIG_FS_ENET_MPC5121_FEC

Signed-off-by: John Rigby <jrigby@freescale.com>
Signed-off-by: Piotr Ziecik <kosmo@semihalf.com>
Signed-off-by: Wolfgang Denk <wd@denx.de>
Cc: <netdev@vger.kernel.org>
Cc: Grant Likely <grant.likely@secretlab.ca>
Cc: John Rigby <jcrigby@gmail.com>
---
 arch/powerpc/include/asm/mpc5121_fec.h |  111 ++++++++++++++++++++++++++++++++
 drivers/net/fs_enet/Kconfig            |   10 ++-
 drivers/net/fs_enet/fs_enet-main.c     |    7 ++
 drivers/net/fs_enet/fs_enet.h          |    6 ++
 drivers/net/fs_enet/mac-fec.c          |   30 ++++++++-
 drivers/net/fs_enet/mii-fec.c          |    7 ++
 6 files changed, 166 insertions(+), 5 deletions(-)
 create mode 100644 arch/powerpc/include/asm/mpc5121_fec.h

diff --git a/arch/powerpc/include/asm/mpc5121_fec.h b/arch/powerpc/include/asm/mpc5121_fec.h
new file mode 100644
index 0000000..6bddf0b
--- /dev/null
+++ b/arch/powerpc/include/asm/mpc5121_fec.h
@@ -0,0 +1,111 @@
+/*
+ * Copyright (C) 2007,2008 Freescale Semiconductor, Inc. All rights reserved.
+ *
+ * Author: John Rigby, <jrigby@freescale.com>
+ *
+ * Modified version of drivers/net/fec.h:
+ *
+ *	fec.h  --  Fast Ethernet Controller for Motorola ColdFire SoC
+ *		   processors.
+ *
+ *	(C) Copyright 2000-2005, Greg Ungerer (gerg@snapgear.com)
+ *	(C) Copyright 2000-2001, Lineo (www.lineo.com)
+ *
+ * This is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+#ifndef MPC5121_FEC_H
+#define MPC5121_FEC_H
+
+typedef struct fec {
+	u32 fec_reserved0;
+	u32 fec_ievent;			/* Interrupt event reg */
+	u32 fec_imask;			/* Interrupt mask reg */
+	u32 fec_reserved1;
+	u32 fec_r_des_active;		/* Receive descriptor reg */
+	u32 fec_x_des_active;		/* Transmit descriptor reg */
+	u32 fec_reserved2[3];
+	u32 fec_ecntrl;			/* Ethernet control reg */
+	u32 fec_reserved3[6];
+	u32 fec_mii_data;		/* MII manage frame reg */
+	u32 fec_mii_speed;		/* MII speed control reg */
+	u32 fec_reserved4[7];
+	u32 fec_mib_ctrlstat;		/* MIB control/status reg */
+	u32 fec_reserved5[7];
+	u32 fec_r_cntrl;		/* Receive control reg */
+	u32 fec_reserved6[15];
+	u32 fec_x_cntrl;		/* Transmit Control reg */
+	u32 fec_reserved7[7];
+	u32 fec_addr_low;		/* Low 32bits MAC address */
+	u32 fec_addr_high;		/* High 16bits MAC address */
+	u32 fec_opd;			/* Opcode + Pause duration */
+	u32 fec_reserved8[10];
+	u32 fec_hash_table_high;	/* High 32bits hash table */
+	u32 fec_hash_table_low;		/* Low 32bits hash table */
+	u32 fec_grp_hash_table_high;	/* High 32bits hash table */
+	u32 fec_grp_hash_table_low;	/* Low 32bits hash table */
+	u32 fec_reserved9[7];
+	u32 fec_x_wmrk;			/* FIFO transmit water mark */
+	u32 fec_reserved10;
+	u32 fec_r_bound;		/* FIFO receive bound reg */
+	u32 fec_r_fstart;		/* FIFO receive start reg */
+	u32 fec_reserved11[11];
+	u32 fec_r_des_start;		/* Receive descriptor ring */
+	u32 fec_x_des_start;		/* Transmit descriptor ring */
+	u32 fec_r_buff_size;		/* Maximum receive buff size */
+	u32 fec_reserved12[26];
+	u32 fec_dma_control;		/* DMA Endian and other ctrl */
+} fec_t;
+
+/*
+ *	Define the buffer descriptor structure.
+ */
+typedef struct bufdesc {
+	ushort	cbd_sc;			/* Control and status info */
+	ushort	cbd_datlen;		/* Data length */
+	uint	cbd_bufaddr;		/* Buffer address */
+} cbd_t;
+
+/*
+ *	The following definitions courtesy of commproc.h, which where
+ *	Copyright (c) 1997 Dan Malek (dmalek@jlc.net).
+ */
+#define BD_SC_WRAP		((ushort)0x2000)
+
+/*
+ * Buffer descriptor control/status used by Ethernet receive.
+ */
+#define BD_ENET_RX_EMPTY	((ushort)0x8000)
+#define BD_ENET_RX_WRAP		((ushort)0x2000)
+#define BD_ENET_RX_INTR		((ushort)0x1000)
+#define BD_ENET_RX_LAST		((ushort)0x0800)
+#define BD_ENET_RX_FIRST	((ushort)0x0400)
+#define BD_ENET_RX_MISS		((ushort)0x0100)
+#define BD_ENET_RX_LG		((ushort)0x0020)
+#define BD_ENET_RX_NO		((ushort)0x0010)
+#define BD_ENET_RX_SH		((ushort)0x0008)
+#define BD_ENET_RX_CR		((ushort)0x0004)
+#define BD_ENET_RX_OV		((ushort)0x0002)
+#define BD_ENET_RX_CL		((ushort)0x0001)
+#define BD_ENET_RX_STATS	((ushort)0x013f)	/* All status bits */
+
+/*
+ * Buffer descriptor control/status used by Ethernet transmit.
+ */
+#define BD_ENET_TX_READY	((ushort)0x8000)
+#define BD_ENET_TX_PAD		((ushort)0x4000)
+#define BD_ENET_TX_WRAP		((ushort)0x2000)
+#define BD_ENET_TX_INTR		((ushort)0x1000)
+#define BD_ENET_TX_LAST		((ushort)0x0800)
+#define BD_ENET_TX_TC		((ushort)0x0400)
+#define BD_ENET_TX_DEF		((ushort)0x0200)
+#define BD_ENET_TX_HB		((ushort)0x0100)
+#define BD_ENET_TX_LC		((ushort)0x0080)
+#define BD_ENET_TX_RL		((ushort)0x0040)
+#define BD_ENET_TX_UN		((ushort)0x0002)
+#define BD_ENET_TX_CSL		((ushort)0x0001)
+#define BD_ENET_TX_STATS	((ushort)0x03ff)	/* All status bits */
+
+#endif /* MPC5121_FEC_H */
diff --git a/drivers/net/fs_enet/Kconfig b/drivers/net/fs_enet/Kconfig
index 562ea68..fc073b5 100644
--- a/drivers/net/fs_enet/Kconfig
+++ b/drivers/net/fs_enet/Kconfig
@@ -1,9 +1,13 @@
 config FS_ENET
        tristate "Freescale Ethernet Driver"
-       depends on CPM1 || CPM2
+       depends on CPM1 || CPM2 || PPC_MPC512x
        select MII
        select PHYLIB
 
+config FS_ENET_MPC5121_FEC
+	def_bool y if (FS_ENET && PPC_MPC512x)
+	select FS_ENET_HAS_FEC
+
 config FS_ENET_HAS_SCC
 	bool "Chip has an SCC usable for ethernet"
 	depends on FS_ENET && (CPM1 || CPM2)
@@ -16,13 +20,13 @@ config FS_ENET_HAS_FCC
 
 config FS_ENET_HAS_FEC
 	bool "Chip has an FEC usable for ethernet"
-	depends on FS_ENET && CPM1
+	depends on FS_ENET && (CPM1 || FS_ENET_MPC5121_FEC)
 	select FS_ENET_MDIO_FEC
 	default y
 
 config FS_ENET_MDIO_FEC
 	tristate "MDIO driver for FEC"
-	depends on FS_ENET && CPM1
+	depends on FS_ENET && (CPM1 || FS_ENET_MPC5121_FEC)
 
 config FS_ENET_MDIO_FCC
 	tristate "MDIO driver for FCC"
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index f996a1a..4170d33 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -1183,11 +1183,18 @@ static struct of_device_id fs_enet_match[] = {
 	},
 #endif
 #ifdef CONFIG_FS_ENET_HAS_FEC
+#ifdef CONFIG_FS_ENET_MPC5121_FEC
+	{
+		.compatible = "fsl,mpc5121-fec",
+		.data = (void *)&fs_fec_ops,
+	},
+#else
 	{
 		.compatible = "fsl,pq1-fec-enet",
 		.data = (void *)&fs_fec_ops,
 	},
 #endif
+#endif
 	{}
 };
 
diff --git a/drivers/net/fs_enet/fs_enet.h b/drivers/net/fs_enet/fs_enet.h
index 85a4bab..5d8258e 100644
--- a/drivers/net/fs_enet/fs_enet.h
+++ b/drivers/net/fs_enet/fs_enet.h
@@ -13,7 +13,13 @@
 
 #ifdef CONFIG_CPM1
 #include <asm/cpm1.h>
+#endif
+
+#ifdef CONFIG_FS_ENET_MPC5121_FEC
+#include <asm/mpc5121_fec.h>
+#endif
 
+#if defined(CONFIG_CPM1) || defined(CONFIG_FS_ENET_MPC5121_FEC)
 struct fec_info {
 	fec_t __iomem *fecp;
 	u32 mii_speed;
diff --git a/drivers/net/fs_enet/mac-fec.c b/drivers/net/fs_enet/mac-fec.c
index 14e5753..b069088 100644
--- a/drivers/net/fs_enet/mac-fec.c
+++ b/drivers/net/fs_enet/mac-fec.c
@@ -44,6 +44,10 @@
 #include <asm/cpm1.h>
 #endif
 
+#ifdef CONFIG_FS_ENET_MPC5121_FEC
+#include <asm/mpc5121_fec.h>
+#endif
+
 #include "fs_enet.h"
 #include "fec.h"
 
@@ -285,7 +289,11 @@ static void restart(struct net_device *dev)
 	 * Set maximum receive buffer size.
 	 */
 	FW(fecp, r_buff_size, PKT_MAXBLR_SIZE);
+#ifdef CONFIG_FS_ENET_MPC5121_FEC
+	FW(fecp, r_cntrl, PKT_MAXBUF_SIZE << 16);
+#else
 	FW(fecp, r_hash, PKT_MAXBUF_SIZE);
+#endif
 
 	/* get physical address */
 	rx_bd_base_phys = fep->ring_mem_addr;
@@ -300,9 +308,14 @@ static void restart(struct net_device *dev)
 	fs_init_bds(dev);
 
 	/*
-	 * Enable big endian and don't care about SDMA FC.
+	 * Enable big endian.
 	 */
+#ifndef CONFIG_FS_ENET_MPC5121_FEC
+	/* Don't care about SDMA FC. */
 	FW(fecp, fun_code, 0x78000000);
+#else
+	FS(fecp, dma_control, 0xC0000000);
+#endif
 
 	/*
 	 * Set MII speed.
@@ -313,7 +326,9 @@ static void restart(struct net_device *dev)
 	 * Clear any outstanding interrupt.
 	 */
 	FW(fecp, ievent, 0xffc0);
+#ifndef CONFIG_FS_ENET_MPC5121_FEC
 	FW(fecp, ivec, (virq_to_hw(fep->interrupt) / 2) << 29);
+#endif
 
 	/*
 	 * adjust to speed (only for DUET & RMII)
@@ -344,8 +359,19 @@ static void restart(struct net_device *dev)
 	}
 #endif
 
+	/*
+	 * Enable MII
+	 */
+#ifdef CONFIG_FS_ENET_MPC5121_FEC
+	/*
+	 * Only set requested bit - do not touch maximum packet size
+	 * configured earlier.
+	 */
+	FS(fecp, r_cntrl, FEC_RCNTRL_MII_MODE);
+#else
+	FW(fecp, r_cntrl, FEC_RCNTRL_MII_MODE);
+#endif
 
-	FW(fecp, r_cntrl, FEC_RCNTRL_MII_MODE);	/* MII enable */
 	/*
 	 * adjust to duplex mode
 	 */
diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/fs_enet/mii-fec.c
index 28077cc..9d8bd97 100644
--- a/drivers/net/fs_enet/mii-fec.c
+++ b/drivers/net/fs_enet/mii-fec.c
@@ -32,6 +32,7 @@
 #include <linux/bitops.h>
 #include <linux/platform_device.h>
 #include <linux/of_platform.h>
+#include <linux/time.h>
 
 #include <asm/pgtable.h>
 #include <asm/irq.h>
@@ -211,9 +212,15 @@ static int fs_enet_mdio_remove(struct of_device *ofdev)
 }
 
 static struct of_device_id fs_enet_mdio_fec_match[] = {
+#ifdef CONFIG_FS_ENET_MPC5121_FEC
+	{
+		.compatible = "fsl,mpc5121-fec-mdio",
+	},
+#else
 	{
 		.compatible = "fsl,pq1-fec-mdio",
 	},
+#endif
 	{},
 };
 
-- 
1.6.0.6

