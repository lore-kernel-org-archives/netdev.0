From: John Rigby <jrigby@freescale.com>
Subject: [PATCH 2/2][Rev4] fs_enet: add MPC5121 FEC support
Date: Wed, 18 Jun 2008 09:15:54 -0600
Message-ID: <1213802154-28968-3-git-send-email-jrigby@freescale.com>
References: <1213802154-28968-1-git-send-email-jrigby@freescale.com>
 <1213802154-28968-2-git-send-email-jrigby@freescale.com>
Cc: netdev@vger.kernel.org, John Rigby <jrigby@freescale.com>
To: Scott Wood <scottwood@freescale.com>, linuxppc-dev@ozlabs.org,
	jeff@garzik.org, Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:43887 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751596AbYFTTiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 15:38:03 -0400
In-Reply-To: <1213802154-28968-2-git-send-email-jrigby@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for MPC512x to fs_enet driver

MPC5121 has an FEC core that is nearly identical to the FEC
in 8xx.  The only problem is that the registers locations have
been shuffled.  Because of this shuffling of registers, one needs
a different structure to describe the 5121 FEC. This is not a huge
problem since CPM2 and FEC are mutually exclusive, and therefore
we can use CONFIG_CPM1 to distinguish between 5121 and 8xx.

  arch/powerpc/boot/dts/mpc5121ads.dts
    Fix a typo in the file header and add ethernet and
    mdio nodes.

  drivers/net/fs_enet/Kconfig
    Add PPC_MPC512x to depends.
    Adds select PPC_CPM_NEW_BINDING if PPC_MPC512x
      This is just until the PPC_CPM_NEW_BINDING goes away

  drivers/net/fs_enet/fec_mpc5121.h
    This contains a struct fec with the appropriate
    order of fields for 5121.

  drivers/net/fs_enet/fs_enet-main.c
    Add a routine for conditionally copying TX skb's that
    are not aligned.  Only do this if fep->fpi->align_tx_packets is set.
    In fs_enet_probe set fpi->align_tx_packets to the value of
    fsl,align-tx-packets property in the device node.
    Add a new entry to match table with compatible set to
    "fsl,mpc5121-fec".

  drivers/net/fs_enet/fs_enet.h
    Include fec_mpc5121.h.

  drivers/net/fs_enet/mac-fec.c
    Any code that is differnet between old 8xx fec
    and 512x fec is ifdef'd with CONFIG_CPM1.
    The file already had CONFIG_CPM1's in it so this isn't
    any more evil than what is already there.

  drivers/net/fs_enet/mii-fec.c
    Add a new entry to match table with compatible set to
    "fsl,mpc5121-fec-mdio".

  include/linux/fs_enet_pd.h
    Add an new field called align_tx_packets to
    struct fs_platform_info which is used in fs_enet_main.c
    as described above.

Signed-off-by: John Rigby <jrigby@freescale.com>
---
 arch/powerpc/boot/dts/mpc5121ads.dts |   24 ++++++++++++-
 drivers/net/fs_enet/Kconfig          |    7 ++--
 drivers/net/fs_enet/fec_mpc5121.h    |   63 ++++++++++++++++++++++++++++++++++
 drivers/net/fs_enet/fs_enet-main.c   |   41 ++++++++++++++++++++++
 drivers/net/fs_enet/fs_enet.h        |    8 ++++-
 drivers/net/fs_enet/mac-fec.c        |   22 +++++++++++-
 drivers/net/fs_enet/mii-fec.c        |    7 ++++
 include/linux/fs_enet_pd.h           |    2 +
 8 files changed, 167 insertions(+), 7 deletions(-)
 create mode 100644 drivers/net/fs_enet/fec_mpc5121.h

diff --git a/arch/powerpc/boot/dts/mpc5121ads.dts b/arch/powerpc/boot/dts/mpc5121ads.dts
index 94ad7b2..bc9629e 100644
--- a/arch/powerpc/boot/dts/mpc5121ads.dts
+++ b/arch/powerpc/boot/dts/mpc5121ads.dts
@@ -1,5 +1,5 @@
 /*
- * MPC5121E MDS Device Tree Source
+ * MPC5121E ADS Device Tree Source
  *
  * Copyright 2007 Freescale Semiconductor Inc.
  *
@@ -85,6 +85,28 @@
 			reg = <0xc00 0x100>;
 		};
 
+		mdio@2800 {
+			compatible = "fsl,mpc5121-fec-mdio";
+			reg = <0x2800 0x800>;
+			#address-cells = <1>;
+			#size-cells = <0>;
+			phy: ethernet-phy@0 {
+				reg = <1>;
+				device_type = "ethernet-phy";
+			};
+		};
+
+		ethernet@2800 {
+			device_type = "network";
+			compatible = "fsl,mpc5121-fec";
+			reg = <0x2800 0x800>;
+			local-mac-address = [ 00 00 00 00 00 00 ];
+			interrupts = <4 0x8>;
+			interrupt-parent = < &ipic >;
+			phy-handle = < &phy >;
+			fsl,align-tx-packets = <4>;
+		};
+
 		// 512x PSCs are not 52xx PSCs compatible
 		// PSC3 serial port A aka ttyPSC0
 		serial@11300 {
diff --git a/drivers/net/fs_enet/Kconfig b/drivers/net/fs_enet/Kconfig
index 562ea68..bcf89b0 100644
--- a/drivers/net/fs_enet/Kconfig
+++ b/drivers/net/fs_enet/Kconfig
@@ -1,8 +1,9 @@
 config FS_ENET
        tristate "Freescale Ethernet Driver"
-       depends on CPM1 || CPM2
+       depends on CPM1 || CPM2 || PPC_MPC512x
        select MII
        select PHYLIB
+       select PPC_CPM_NEW_BINDING if PPC_MPC512x
 
 config FS_ENET_HAS_SCC
 	bool "Chip has an SCC usable for ethernet"
@@ -16,13 +17,13 @@ config FS_ENET_HAS_FCC
 
 config FS_ENET_HAS_FEC
 	bool "Chip has an FEC usable for ethernet"
-	depends on FS_ENET && CPM1
+	depends on FS_ENET && (CPM1 || PPC_MPC512x)
 	select FS_ENET_MDIO_FEC
 	default y
 
 config FS_ENET_MDIO_FEC
 	tristate "MDIO driver for FEC"
-	depends on FS_ENET && CPM1
+	depends on FS_ENET && (CPM1 || PPC_MPC512x)
 
 config FS_ENET_MDIO_FCC
 	tristate "MDIO driver for FCC"
diff --git a/drivers/net/fs_enet/fec_mpc5121.h b/drivers/net/fs_enet/fec_mpc5121.h
new file mode 100644
index 0000000..b44ca37
--- /dev/null
+++ b/drivers/net/fs_enet/fec_mpc5121.h
@@ -0,0 +1,63 @@
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
+#ifndef FEC_MPC5121_H
+#define FEC_MPC5121_H
+
+#include <linux/types.h>
+
+struct fec {
+	u32 fec_reserved0;
+	u32 fec_ievent;		/* Interrupt event reg */
+	u32 fec_imask;		/* Interrupt mask reg */
+	u32 fec_reserved1;
+	u32 fec_r_des_active;	/* Receive descriptor reg */
+	u32 fec_x_des_active;	/* Transmit descriptor reg */
+	u32 fec_reserved2[3];
+	u32 fec_ecntrl;		/* Ethernet control reg */
+	u32 fec_reserved3[6];
+	u32 fec_mii_data;		/* MII manage frame reg */
+	u32 fec_mii_speed;		/* MII speed control reg */
+	u32 fec_reserved4[7];
+	u32 fec_mib_ctrlstat;	/* MIB control/status reg */
+	u32 fec_reserved5[7];
+	u32 fec_r_cntrl;		/* Receive control reg */
+	u32 fec_reserved6[15];
+	u32 fec_x_cntrl;		/* Transmit Control reg */
+	u32 fec_reserved7[7];
+	u32 fec_addr_low;		/* Low 32bits MAC address */
+	u32 fec_addr_high;		/* High 16bits MAC address */
+	u32 fec_opd;		/* Opcode + Pause duration */
+	u32 fec_reserved8[10];
+	u32 fec_hash_table_high;	/* High 32bits hash table */
+	u32 fec_hash_table_low;	/* Low 32bits hash table */
+	u32 fec_grp_hash_table_high;/* High 32bits hash table */
+	u32 fec_grp_hash_table_low;	/* Low 32bits hash table */
+	u32 fec_reserved9[7];
+	u32 fec_x_wmrk;		/* FIFO transmit water mark */
+	u32 fec_reserved10;
+	u32 fec_r_bound;		/* FIFO receive bound reg */
+	u32 fec_r_fstart;		/* FIFO receive start reg */
+	u32 fec_reserved11[11];
+	u32 fec_r_des_start;	/* Receive descriptor ring */
+	u32 fec_x_des_start;	/* Transmit descriptor ring */
+	u32 fec_r_buff_size;	/* Maximum receive buff size */
+	u32 fec_dma_control;	/* DMA Endian and other ctrl */
+};
+
+#endif /* FEC_MPC5121_H */
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index a5baaf5..7c3391c 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -592,6 +592,37 @@ void fs_cleanup_bds(struct net_device *dev)
 
 /**********************************************************************************/
 
+/*
+ * The 5121 FEC doc says transmit buffers must have 4 byte alignment.
+ * We get alignement from the device tree in case this changes on future
+ * platforms.
+ */
+static struct sk_buff *align_tx_skb(struct net_device *dev, struct sk_buff *skb,
+			    int align)
+{
+	struct sk_buff *skbn;
+
+	if ((((unsigned long)skb->data) & (align-1)) == 0)
+		return skb;
+
+	skbn = dev_alloc_skb(ENET_RX_FRSIZE+align);
+	if (skbn)
+		skb_align(skbn, align);
+
+	if (!skbn) {
+		printk(KERN_WARNING DRV_MODULE_NAME
+			": %s Memory squeeze, dropping tx packet.\n",
+			dev->name);
+		dev_kfree_skb_any(skb);
+		return NULL;
+	}
+
+	skb_copy_from_linear_data(skb, skbn->data, skb->len);
+	skb_put(skbn, skb->len);
+	dev_kfree_skb_any(skb);
+	return skbn;
+}
+
 static int fs_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
@@ -600,6 +631,8 @@ static int fs_enet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	u16 sc;
 	unsigned long flags;
 
+	if (fep->fpi->align_tx_packets)
+		skb = align_tx_skb(dev, skb, fep->fpi->align_tx_packets);
 	spin_lock_irqsave(&fep->tx_lock, flags);
 
 	/*
@@ -1239,6 +1272,10 @@ static int __devinit fs_enet_probe(struct of_device *ofdev,
 		fpi->cp_command = *data;
 	}
 
+	data = of_get_property(ofdev->node, "fsl,align-tx-packets", &len);
+	if (data && len == 4)
+		fpi->align_tx_packets = *data;
+
 	fpi->rx_ring = 32;
 	fpi->tx_ring = 32;
 	fpi->rx_copybreak = 240;
@@ -1366,6 +1403,10 @@ static struct of_device_id fs_enet_match[] = {
 		.compatible = "fsl,pq1-fec-enet",
 		.data = (void *)&fs_fec_ops,
 	},
+	{
+		.compatible = "fsl,mpc5121-fec",
+		.data = (void *)&fs_fec_ops,
+	},
 #endif
 	{}
 };
diff --git a/drivers/net/fs_enet/fs_enet.h b/drivers/net/fs_enet/fs_enet.h
index e05389c..5fa78cf 100644
--- a/drivers/net/fs_enet/fs_enet.h
+++ b/drivers/net/fs_enet/fs_enet.h
@@ -10,12 +10,18 @@
 
 #include <linux/fs_enet_pd.h>
 #include <asm/fs_pd.h>
+#ifdef CONFIG_PPC_MPC512x
+#include "fec_mpc5121.h"
+#include <asm/cpm.h>
+#endif
 
 #ifdef CONFIG_CPM1
 #include <asm/cpm1.h>
+#endif
 
+#if defined(CONFIG_FS_ENET_HAS_FEC)
 struct fec_info {
-	fec_t __iomem *fecp;
+	struct fec __iomem *fecp;
 	u32 mii_speed;
 };
 #endif
diff --git a/drivers/net/fs_enet/mac-fec.c b/drivers/net/fs_enet/mac-fec.c
index 053b360..657208a 100644
--- a/drivers/net/fs_enet/mac-fec.c
+++ b/drivers/net/fs_enet/mac-fec.c
@@ -42,6 +42,9 @@
 #include <asm/mpc8xx.h>
 #include <asm/cpm1.h>
 #endif
+#ifdef CONFIG_PPC_MPC512x
+#include "fec_mpc5121.h"
+#endif
 
 #ifdef CONFIG_PPC_CPM_NEW_BINDING
 #include <asm/of_device.h>
@@ -306,7 +309,9 @@ static void restart(struct net_device *dev)
 	 * Set maximum receive buffer size.
 	 */
 	FW(fecp, r_buff_size, PKT_MAXBLR_SIZE);
+#ifdef CONFIG_CPM1
 	FW(fecp, r_hash, PKT_MAXBUF_SIZE);
+#endif
 
 	/* get physical address */
 	rx_bd_base_phys = fep->ring_mem_addr;
@@ -320,10 +325,17 @@ static void restart(struct net_device *dev)
 
 	fs_init_bds(dev);
 
+#ifdef CONFIG_CPM1
 	/*
 	 * Enable big endian and don't care about SDMA FC.
 	 */
 	FW(fecp, fun_code, 0x78000000);
+#else
+	/*
+	 * Set DATA_BO and DESC_BO and leave the rest unchanged
+	 */
+	FS(fecp, dma_control, 0xc0000000);
+#endif
 
 	/*
 	 * Set MII speed.
@@ -334,11 +346,13 @@ static void restart(struct net_device *dev)
 	 * Clear any outstanding interrupt.
 	 */
 	FW(fecp, ievent, 0xffc0);
+#ifdef CONFIG_CPM1
 #ifndef CONFIG_PPC_MERGE
 	FW(fecp, ivec, (fep->interrupt / 2) << 29);
 #else
 	FW(fecp, ivec, (virq_to_hw(fep->interrupt) / 2) << 29);
 #endif
+#endif
 
 	/*
 	 * adjust to speed (only for DUET & RMII)
@@ -368,9 +382,13 @@ static void restart(struct net_device *dev)
 		out_be32(&immap->im_cpm.cp_cptr, cptr);
 	}
 #endif
-
-
+#ifdef CONFIG_CPM1
 	FW(fecp, r_cntrl, FEC_RCNTRL_MII_MODE);	/* MII enable */
+#else
+	FW(fecp, r_cntrl, PKT_MAXBUF_SIZE<<16);	/* max frame size */
+	FS(fecp, r_cntrl, FEC_RCNTRL_MII_MODE); /* MII enable */
+#endif
+
 	/*
 	 * adjust to duplex mode
 	 */
diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/fs_enet/mii-fec.c
index 83fe5e9..0d76a5a 100644
--- a/drivers/net/fs_enet/mii-fec.c
+++ b/drivers/net/fs_enet/mii-fec.c
@@ -261,9 +261,16 @@ static int fs_enet_mdio_remove(struct of_device *ofdev)
 }
 
 static struct of_device_id fs_enet_mdio_fec_match[] = {
+#ifdef CONFIG_CPM1
 	{
 		.compatible = "fsl,pq1-fec-mdio",
 	},
+#endif
+#ifdef CONFIG_PPC_MPC512x
+	{
+		.compatible = "fsl,mpc5121-fec-mdio",
+	},
+#endif
 	{},
 };
 
diff --git a/include/linux/fs_enet_pd.h b/include/linux/fs_enet_pd.h
index 9bc045b..4042f23 100644
--- a/include/linux/fs_enet_pd.h
+++ b/include/linux/fs_enet_pd.h
@@ -152,6 +152,8 @@ struct fs_platform_info {
 
 	int use_rmii;		/* use RMII mode 	       */
 	int has_phy;            /* if the network is phy container as well...*/
+
+	int align_tx_packets;	/* align transmit skb's */
 };
 struct fs_mii_fec_platform_info {
 	u32 irq[32];
-- 
1.5.6.rc0.46.gd2b3

