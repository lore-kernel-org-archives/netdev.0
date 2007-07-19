From: Li Yang <leoli@freescale.com>
Subject: [PATCH 1/2] ucc_geth: add ethtool support
Date: Thu, 19 Jul 2007 11:47:47 +0800
Message-ID: <11848168673403-git-send-email-leoli@freescale.com>
Cc: netdev@vger.kernel.org, Li Yang <leoli@freescale.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:41871 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757004AbXGSDgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 23:36:52 -0400
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw01.freescale.net (8.12.11/az33egw01) with ESMTP id l6J3al9S023616
	for <netdev@vger.kernel.org>; Wed, 18 Jul 2007 20:36:48 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id l6J3akNd026405
	for <netdev@vger.kernel.org>; Wed, 18 Jul 2007 22:36:47 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch enables statistics in ucc_geth and adds ethtool support to
ucc_geth driver.

Signed-off-by: Li Yang <leoli@freescale.com>
---
 drivers/net/Makefile           |    2 +-
 drivers/net/ucc_geth.c         |   19 +-
 drivers/net/ucc_geth.h         |    6 +
 drivers/net/ucc_geth_ethtool.c |  388 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/ucc_geth_mii.c     |    6 +-
 5 files changed, 407 insertions(+), 14 deletions(-)
 create mode 100644 drivers/net/ucc_geth_ethtool.c

diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index eb41676..d69f07c 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -18,7 +18,7 @@ gianfar_driver-objs := gianfar.o \
 		gianfar_sysfs.o
 
 obj-$(CONFIG_UCC_GETH) += ucc_geth_driver.o
-ucc_geth_driver-objs := ucc_geth.o ucc_geth_mii.o
+ucc_geth_driver-objs := ucc_geth.o ucc_geth_mii.o ucc_geth_ethtool.o
 
 #
 # link order important here
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index e4736a3..4a3fd62 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -43,10 +43,6 @@
 
 #undef DEBUG
 
-#define DRV_DESC "QE UCC Gigabit Ethernet Controller"
-#define DRV_NAME "ucc_geth"
-#define DRV_VERSION "1.1"
-
 #define ugeth_printk(level, format, arg...)  \
         printk(level format "\n", ## arg)
 
@@ -65,6 +61,8 @@
 #define ugeth_vdbg(fmt, args...) do { } while (0)
 #endif				/* UGETH_VERBOSE_DEBUG */
 
+void uec_set_ethtool_ops(struct net_device *netdev);
+	
 static DEFINE_SPINLOCK(ugeth_lock);
 
 static struct ucc_geth_info ugeth_primary_info = {
@@ -104,6 +102,7 @@ static struct ucc_geth_info ugeth_primary_info = {
 	.maxRetransmission = 0xf,
 	.collisionWindow = 0x37,
 	.receiveFlowControl = 1,
+	.transmitFlowControl = 1,
 	.maxGroupAddrInHash = 4,
 	.maxIndAddrInHash = 4,
 	.prel = 7,
@@ -139,7 +138,9 @@ static struct ucc_geth_info ugeth_primary_info = {
 	.numStationAddresses = UCC_GETH_NUM_OF_STATION_ADDRESSES_1,
 	.largestexternallookupkeysize =
 	    QE_FLTR_LARGEST_EXTERNAL_TABLE_LOOKUP_KEY_SIZE_NONE,
-	.statisticsMode = UCC_GETH_STATISTICS_GATHERING_MODE_NONE,
+	.statisticsMode = UCC_GETH_STATISTICS_GATHERING_MODE_HARDWARE |
+		UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_TX |
+		UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_RX,
 	.vlanOperationTagged = UCC_GETH_VLAN_OPERATION_TAGGED_NOP,
 	.vlanOperationNonTagged = UCC_GETH_VLAN_OPERATION_NON_TAGGED_NOP,
 	.rxQoSMode = UCC_GETH_QOS_MODE_DEFAULT,
@@ -1200,7 +1201,7 @@ static int init_inter_frame_gap_params(u8 non_btb_cs_ipg,
 	return 0;
 }
 
-static int init_flow_control_params(u32 automatic_flow_control_mode,
+int init_flow_control_params(u32 automatic_flow_control_mode,
 				    int rx_flow_control_enable,
 				    int tx_flow_control_enable,
 				    u16 pause_period,
@@ -2507,7 +2508,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	/* For more details see the hardware spec.           */
 	init_flow_control_params(ug_info->aufc,
 				 ug_info->receiveFlowControl,
-				 1,
+				 ug_info->transmitFlowControl,
 				 ug_info->pausePeriod,
 				 ug_info->extensionField,
 				 &uf_regs->upsmr,
@@ -3732,8 +3733,6 @@ static int ucc_geth_close(struct net_device *dev)
 	return 0;
 }
 
-const struct ethtool_ops ucc_geth_ethtool_ops = { };
-
 static phy_interface_t to_phy_interface(const char *phy_connection_type)
 {
 	if (strcasecmp(phy_connection_type, "mii") == 0)
@@ -3896,6 +3895,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	SET_NETDEV_DEV(dev, device);
 
 	/* Fill in the dev structure */
+	uec_set_ethtool_ops(dev);
 	dev->open = ucc_geth_open;
 	dev->hard_start_xmit = ucc_geth_start_xmit;
 	dev->tx_timeout = ucc_geth_timeout;
@@ -3909,7 +3909,6 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 //    dev->change_mtu = ucc_geth_change_mtu;
 	dev->mtu = 1500;
 	dev->set_multicast_list = ucc_geth_set_multi;
-	dev->ethtool_ops = &ucc_geth_ethtool_ops;
 
 	ugeth->msg_enable = (NETIF_MSG_IFUP << 1 ) - 1;
 	ugeth->phy_interface = phy_interface;
diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h
index a29e1c3..bb4dac8 100644
--- a/drivers/net/ucc_geth.h
+++ b/drivers/net/ucc_geth.h
@@ -30,6 +30,10 @@
 
 #include "ucc_geth_mii.h"
 
+#define DRV_DESC "QE UCC Gigabit Ethernet Controller"
+#define DRV_NAME "ucc_geth"
+#define DRV_VERSION "1.1"
+
 #define NUM_TX_QUEUES                   8
 #define NUM_RX_QUEUES                   8
 #define NUM_BDS_IN_PREFETCHED_BDS       4
@@ -896,6 +900,7 @@ struct ucc_geth_hardware_statistics {
 #define UCC_GETH_TX_VTAG_TABLE_ENTRY_MAX        8
 #define UCC_GETH_RX_BD_RING_SIZE_MIN            8
 #define UCC_GETH_TX_BD_RING_SIZE_MIN            2
+#define UCC_GETH_BD_RING_SIZE_MAX		0xffff
 
 #define UCC_GETH_SIZE_OF_BD                     QE_SIZEOF_BD
 
@@ -1135,6 +1140,7 @@ struct ucc_geth_info {
 	int bro;
 	int ecm;
 	int receiveFlowControl;
+	int transmitFlowControl;
 	u8 maxGroupAddrInHash;
 	u8 maxIndAddrInHash;
 	u8 prel;
diff --git a/drivers/net/ucc_geth_ethtool.c b/drivers/net/ucc_geth_ethtool.c
new file mode 100644
index 0000000..a8994c7
--- /dev/null
+++ b/drivers/net/ucc_geth_ethtool.c
@@ -0,0 +1,388 @@
+/*
+ * Copyright (c) 2007 Freescale Semiconductor, Inc. All rights reserved.
+ *
+ * Description: QE UCC Gigabit Ethernet Ethtool API Set
+ *
+ * Author: Li Yang <leoli@freescale.com>
+ *
+ * Limitation: 
+ * Can only get/set setttings of the first queue.
+ * Need to re-open the interface manually after changing some paramters.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ */
+
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/errno.h>
+#include <linux/slab.h>
+#include <linux/stddef.h>
+#include <linux/interrupt.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/delay.h>
+#include <linux/dma-mapping.h>
+#include <linux/fsl_devices.h>
+#include <linux/ethtool.h>
+#include <linux/mii.h>
+#include <linux/phy.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/uaccess.h>
+#include <asm/types.h>
+#include <asm/uaccess.h>
+
+#include "ucc_geth.h"
+#include "ucc_geth_mii.h"
+
+static char hw_stat_gstrings[][ETH_GSTRING_LEN] = {
+	"tx-64-frames",
+	"tx-65-127-frames",
+	"tx-128-255-frames",
+	"rx-64-frames",
+	"rx-65-127-frames",
+	"rx-128-255-frames",
+	"tx-bytes-ok",
+	"tx-pause-frames",
+	"tx-multicast-frames",
+	"tx-broadcast-frames",
+	"rx-frames",
+	"rx-bytes-ok",
+	"rx-bytes-all",
+	"rx-multicast-frames",
+	"rx-broadcast-frames",
+	"stats-counter-carry",
+	"stats-counter-mask",
+	"rx-dropped-frames",
+};
+
+static char tx_fw_stat_gstrings[][ETH_GSTRING_LEN] = {
+	"tx-single-collision",
+	"tx-multiple-collision",
+	"tx-late-collsion",
+	"tx-aborted-frames",
+	"tx-lost-frames",
+	"tx-carrier-sense-errors",
+	"tx-frames-ok",
+	"tx-excessive-differ-frames",
+	"tx-256-511-frames",
+	"tx-1024-1518-frames",
+	"tx-jumbo-frames",
+};
+
+static char rx_fw_stat_gstrings[][ETH_GSTRING_LEN] = {
+	"rx-crc-errors",
+	"rx-alignment-errors",
+	"rx-in-range-length-errors",
+	"rx-out-of-range-length-errors",
+	"rx-too-long-frames",
+	"rx-runt",
+	"rx-very-long-event",
+	"rx-symbol-errors",
+	"rx-busy-drop-frames",
+	"reserved",
+	"reserved",
+	"rx-mismatch-drop-frames",
+	"rx-small-than-64",
+	"rx-256-511-frames",
+	"rx-512-1023-frames",
+	"rx-1024-1518-frames",
+	"rx-jumbo-frames",
+	"rx-mac-error-loss",
+	"rx-pause-frames",
+	"reserved",
+	"rx-vlan-removed",
+	"rx-vlan-replaced",
+	"rx-vlan-inserted",
+	"rx-ip-checksum-errors",
+};
+
+#define UEC_HW_STATS_LEN ARRAY_SIZE(hw_stat_gstrings)
+#define UEC_TX_FW_STATS_LEN ARRAY_SIZE(tx_fw_stat_gstrings)
+#define UEC_RX_FW_STATS_LEN ARRAY_SIZE(rx_fw_stat_gstrings)
+
+extern int init_flow_control_params(u32 automatic_flow_control_mode,
+		int rx_flow_control_enable,
+		int tx_flow_control_enable, u16 pause_period,
+		u16 extension_field, volatile u32 *upsmr_register,
+		volatile u32 *uempr_register, volatile u32 *maccfg1_register);
+
+static int
+uec_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(netdev);
+	struct phy_device *phydev = ugeth->phydev;
+	struct ucc_geth_info *ug_info = ugeth->ug_info;
+
+	if (!phydev)
+		return -ENODEV;
+
+	ecmd->maxtxpkt = 1;
+	ecmd->maxrxpkt = ug_info->interruptcoalescingmaxvalue[0];
+
+	return phy_ethtool_gset(phydev, ecmd);
+}
+
+static int
+uec_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(netdev);
+	struct phy_device *phydev = ugeth->phydev;
+
+	if (!phydev)
+		return -ENODEV;
+
+	return phy_ethtool_sset(phydev, ecmd);
+}
+
+static void
+uec_get_pauseparam(struct net_device *netdev,
+                     struct ethtool_pauseparam *pause)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(netdev);
+
+	pause->autoneg = ugeth->phydev->autoneg;
+
+	if (ugeth->ug_info->receiveFlowControl)
+		pause->rx_pause = 1;
+	if (ugeth->ug_info->transmitFlowControl)
+		pause->tx_pause = 1;
+}
+
+static int
+uec_set_pauseparam(struct net_device *netdev,
+                     struct ethtool_pauseparam *pause)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(netdev);
+	int ret = 0;
+
+	ugeth->ug_info->receiveFlowControl = pause->rx_pause;
+	ugeth->ug_info->transmitFlowControl = pause->tx_pause;
+	
+	if (ugeth->phydev->autoneg) {
+		if (netif_running(netdev)) {
+			/* FIXME: automatically restart */
+			printk(KERN_INFO
+				"Please re-open the interface.\n");
+		}
+	} else {
+		struct ucc_geth_info *ug_info = ugeth->ug_info;
+
+		ret = init_flow_control_params(ug_info->aufc,
+					ug_info->receiveFlowControl,
+					ug_info->transmitFlowControl,
+					ug_info->pausePeriod,
+					ug_info->extensionField,
+					&ugeth->uccf->uf_regs->upsmr,
+					&ugeth->ug_regs->uempr,
+					&ugeth->ug_regs->maccfg1);
+	}
+
+	return ret;
+}
+
+static uint32_t
+uec_get_msglevel(struct net_device *netdev)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(netdev);
+	return ugeth->msg_enable;
+}
+
+static void
+uec_set_msglevel(struct net_device *netdev, uint32_t data)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(netdev);
+	ugeth->msg_enable = data;
+}
+
+static int
+uec_get_regs_len(struct net_device *netdev)
+{
+	return sizeof(struct ucc_geth);
+}
+
+static void
+uec_get_regs(struct net_device *netdev,
+               struct ethtool_regs *regs, void *p)
+{
+	int i;
+	struct ucc_geth_private *ugeth = netdev_priv(netdev);
+	u32 __iomem *ug_regs = (u32 __iomem *)ugeth->ug_regs;
+	u32 *buff = p;
+
+	for (i = 0; i < sizeof(struct ucc_geth) / sizeof(u32); i++)
+		buff[i] = in_be32(&ug_regs[i]);
+}
+
+static void
+uec_get_ringparam(struct net_device *netdev,
+                    struct ethtool_ringparam *ring)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(netdev);
+	struct ucc_geth_info *ug_info = ugeth->ug_info;
+	int queue = 0;
+
+	ring->rx_max_pending = UCC_GETH_BD_RING_SIZE_MAX;
+	ring->rx_mini_max_pending = UCC_GETH_BD_RING_SIZE_MAX;
+	ring->rx_jumbo_max_pending = UCC_GETH_BD_RING_SIZE_MAX;
+	ring->tx_max_pending = UCC_GETH_BD_RING_SIZE_MAX;
+
+	ring->rx_pending = ug_info->bdRingLenRx[queue];
+	ring->rx_mini_pending = ug_info->bdRingLenRx[queue];
+	ring->rx_jumbo_pending = ug_info->bdRingLenRx[queue];
+	ring->tx_pending = ug_info->bdRingLenTx[queue];
+}
+
+static int
+uec_set_ringparam(struct net_device *netdev,
+                    struct ethtool_ringparam *ring)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(netdev);
+	struct ucc_geth_info *ug_info = ugeth->ug_info;
+	int queue = 0, ret = 0;
+
+	if (ring->rx_pending < UCC_GETH_RX_BD_RING_SIZE_MIN) {
+		printk("%s: RxBD ring size must be no smaller than %d.\n",
+			       	netdev->name, UCC_GETH_RX_BD_RING_SIZE_MIN);
+		return -EINVAL;
+	}
+	if (ring->rx_pending % UCC_GETH_RX_BD_RING_SIZE_ALIGNMENT) {
+		printk("%s: RxBD ring size must be multiple of %d.\n",
+			netdev->name, UCC_GETH_RX_BD_RING_SIZE_ALIGNMENT);
+		return -EINVAL;
+	}
+	if (ring->tx_pending < UCC_GETH_TX_BD_RING_SIZE_MIN) {
+		printk("%s: TxBD ring size must be no smaller than %d.\n",
+				netdev->name, UCC_GETH_TX_BD_RING_SIZE_MIN);
+		return -EINVAL;
+	}
+
+	ug_info->bdRingLenRx[queue] = ring->rx_pending;
+	ug_info->bdRingLenTx[queue] = ring->tx_pending;
+
+	if (netif_running(netdev)) {
+		/* FIXME: restart automatically */
+		printk(KERN_INFO
+			"Please re-open the interface.\n");
+	}
+
+	return ret;
+}
+
+static int uec_get_stats_count(struct net_device *netdev)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(netdev);
+	u32 stats_mode = ugeth->ug_info->statisticsMode;
+	int len = 0;
+
+	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_HARDWARE)
+		len += UEC_HW_STATS_LEN;
+	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_TX)
+		len += UEC_TX_FW_STATS_LEN;
+	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_RX)
+		len += UEC_RX_FW_STATS_LEN;
+
+	return len;
+}
+
+static void uec_get_strings(struct net_device *netdev, u32 stringset, u8 *buf)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(netdev);
+	u32 stats_mode = ugeth->ug_info->statisticsMode;
+
+	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_HARDWARE) {
+		memcpy(buf, hw_stat_gstrings, UEC_HW_STATS_LEN *
+			       	ETH_GSTRING_LEN);
+		buf += UEC_HW_STATS_LEN * ETH_GSTRING_LEN;
+	}
+	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_TX) {
+		memcpy(buf, tx_fw_stat_gstrings, UEC_TX_FW_STATS_LEN *
+			       	ETH_GSTRING_LEN);
+		buf += UEC_TX_FW_STATS_LEN * ETH_GSTRING_LEN;
+	}
+	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_RX)
+		memcpy(buf, tx_fw_stat_gstrings, UEC_RX_FW_STATS_LEN *
+			       	ETH_GSTRING_LEN);
+}
+
+static void uec_get_ethtool_stats(struct net_device *netdev,
+		struct ethtool_stats *stats, uint64_t *data)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(netdev);
+	u32 stats_mode = ugeth->ug_info->statisticsMode;
+	u32 __iomem *base;
+	int i, j = 0;
+
+	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_HARDWARE) {
+		base = (u32 __iomem *)&ugeth->ug_regs->tx64;
+		for (i = 0; i < UEC_HW_STATS_LEN; i++)
+			data[j++] = (u64)in_be32(&base[i]);
+	}
+	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_TX) {
+		base = (u32 __iomem *)ugeth->p_tx_fw_statistics_pram;
+		for (i = 0; i < UEC_TX_FW_STATS_LEN; i++)
+			data[j++] = (u64)in_be32(&base[i]);
+	}
+	if (stats_mode & UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_RX) {
+		base = (u32 __iomem *)ugeth->p_rx_fw_statistics_pram;
+		for (i = 0; i < UEC_RX_FW_STATS_LEN; i++)
+			data[j++] = (u64)in_be32(&base[i]);
+	}
+}
+
+static int uec_nway_reset(struct net_device *netdev)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(netdev);
+
+	return phy_start_aneg(ugeth->phydev);
+}
+
+/* Report driver information */
+static void
+uec_get_drvinfo(struct net_device *netdev,
+                       struct ethtool_drvinfo *drvinfo)
+{
+	strncpy(drvinfo->driver, DRV_NAME, 32);
+	strncpy(drvinfo->version, DRV_VERSION, 32);
+	strncpy(drvinfo->fw_version, "N/A", 32);
+	strncpy(drvinfo->bus_info, "QUICC ENGINE", 32);
+	drvinfo->n_stats = uec_get_stats_count(netdev);
+	drvinfo->testinfo_len = 0;
+	drvinfo->eedump_len = 0;
+	drvinfo->regdump_len = uec_get_regs_len(netdev);
+}
+
+static const struct ethtool_ops uec_ethtool_ops = {
+	.get_settings           = uec_get_settings,
+	.set_settings           = uec_set_settings,
+	.get_drvinfo            = uec_get_drvinfo,
+	.get_regs_len           = uec_get_regs_len,
+	.get_regs               = uec_get_regs,
+	.get_msglevel           = uec_get_msglevel,
+	.set_msglevel           = uec_set_msglevel,
+	.nway_reset             = uec_nway_reset,
+	.get_link               = ethtool_op_get_link,
+	.get_ringparam          = uec_get_ringparam,
+	.set_ringparam          = uec_set_ringparam,
+	.get_pauseparam         = uec_get_pauseparam,
+	.set_pauseparam         = uec_set_pauseparam,
+	.get_sg                 = ethtool_op_get_sg,
+	.set_sg                 = ethtool_op_set_sg,
+	.get_tso                = ethtool_op_get_tso,
+	.get_stats_count        = uec_get_stats_count,
+	.get_strings            = uec_get_strings,
+	.get_ethtool_stats      = uec_get_ethtool_stats,
+	.get_perm_addr          = ethtool_op_get_perm_addr,
+};
+
+void uec_set_ethtool_ops(struct net_device *netdev)
+{
+	SET_ETHTOOL_OPS(netdev, &uec_ethtool_ops);
+}
diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
index 7bcb82f..5f8c2d3 100644
--- a/drivers/net/ucc_geth_mii.c
+++ b/drivers/net/ucc_geth_mii.c
@@ -54,8 +54,8 @@
 #define vdbg(format, arg...) do {} while(0)
 #endif
 
-#define DRV_DESC "QE UCC Ethernet Controller MII Bus"
-#define DRV_NAME "fsl-uec_mdio"
+#define MII_DRV_DESC "QE UCC Ethernet Controller MII Bus"
+#define MII_DRV_NAME "fsl-uec_mdio"
 
 /* Write value to the PHY for this device to the register at regnum, */
 /* waiting until the write is done before it returns.  All PHY */
@@ -261,7 +261,7 @@ static struct of_device_id uec_mdio_match[] = {
 };
 
 static struct of_platform_driver uec_mdio_driver = {
-	.name	= DRV_NAME,
+	.name	= MII_DRV_NAME,
 	.probe	= uec_mdio_probe,
 	.remove	= uec_mdio_remove,
 	.match_table	= uec_mdio_match,
-- 
1.5.2.GIT

