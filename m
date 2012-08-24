From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH net-next 13/15] qlcnic: create new file for 82xx firmware commands
Date: Thu, 23 Aug 2012 21:07:17 -0400
Message-ID: <1345770439-30517-14-git-send-email-sony.chacko@qlogic.com>
References: <1345770439-30517-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:33175 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754989Ab2HXBYT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 21:24:19 -0400
In-Reply-To: <1345770439-30517-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Modify 82xx driver to support new adapter - Qlogic 83XX CNA
Create new file for 82xx firmware interface commands

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/Makefile        |    4 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |   25 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_82xx_hw.c    | 2590 ++++++++++++++++++++
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |   94 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |    8 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |   56 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c  |    1 -
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    | 1179 ---------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h    |   12 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     | 1431 -----------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h     |   17 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c   |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |    9 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  108 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_minidump.c   |   25 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c  |   51 +-
 16 files changed, 2837 insertions(+), 2775 deletions(-)
 create mode 100644 drivers/net/ethernet/qlogic/qlcnic/qlcnic_82xx_hw.c
 delete mode 100644 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
 delete mode 100644 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c

diff --git a/drivers/net/ethernet/qlogic/qlcnic/Makefile b/drivers/net/ethernet/qlogic/qlcnic/Makefile
index 25b73f1..fe61793 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/Makefile
+++ b/drivers/net/ethernet/qlogic/qlcnic/Makefile
@@ -4,7 +4,7 @@
 
 obj-$(CONFIG_QLCNIC) := qlcnic.o
 
-qlcnic-y := qlcnic_hw.o qlcnic_main.o qlcnic_init.o \
-	qlcnic_ethtool.o qlcnic_ctx.o qlcnic_io.o \
+qlcnic-y := qlcnic_82xx_hw.o qlcnic_main.o qlcnic_init.o \
+	qlcnic_ethtool.o qlcnic_io.o \
 	qlcnic_sysfs.o qlcnic_minidump.o qlcnic_83xx_hw.o \
 	qlcnic_83xx_init.o qlcnic_83xx_vnic.o
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index eaaa049..ddd8795 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -49,6 +49,8 @@
 #define _minor(v)	(((v) >> 16) & 0xff)
 #define _build(v)	((v) & 0xffff)
 
+#define QLCNIC_DBG_LEVEL_MASK (NETIF_MSG_DRV | NETIF_MSG_HW | NETIF_MSG_PKTDATA)
+
 /* version in image has weird encoding:
  *  7:0  - major
  * 15:8  - minor
@@ -142,6 +144,8 @@
 #define DEFAULT_RCV_DESCRIPTORS_10G	4096
 #define DEFAULT_RCV_DESCRIPTORS_VF	1024
 #define MAX_RDS_RINGS                   2
+#define MAX_SDS_RINGS                   8
+
 
 #define get_next_index(index, length)	\
 	(((index) + 1) & ((length) - 1))
@@ -259,6 +263,8 @@ struct rcv_desc {
 	(((sts_data) >> 52) & 0x1)
 #define qlcnic_get_lro_sts_seq_number(sts_data)		\
 	((sts_data) & 0x0FFFFFFFF)
+#define qlcnic_get_lro_sts_mss(sts_data1)		\
+	((sts_data1 >> 32) & 0x0FFFF)
 
 
 struct status_desc {
@@ -524,7 +530,7 @@ struct qlcnic_hardware_context {
 	u16 max_tx_ques;
 	u16 max_rx_ques;
 	u16 max_mtu;
-	u16 msg_enable;
+	u32 msg_enable;
 	u16 act_pci_func;
 
 	u32 capabilities;
@@ -675,6 +681,7 @@ struct qlcnic_recv_context {
 #define QLCNIC_CAP0_JUMBO_CONTIGUOUS	(1 << 7)
 #define QLCNIC_CAP0_LRO_CONTIGUOUS	(1 << 8)
 #define QLCNIC_CAP0_VALIDOFF		(1 << 11)
+#define QLCNIC_CAP0_LRO_MSS            (1 << 21)
 
 /*
  * Context state
@@ -881,6 +888,9 @@ struct qlcnic_mac_list_s {
 #define QLCNIC_FW_CAPABILITY_FVLANTX		BIT_9
 #define QLCNIC_FW_CAPABILITY_HW_LRO		BIT_10
 #define QLCNIC_FW_CAPABILITY_MULTI_LOOPBACK	BIT_27
+#define QLCNIC_FW_CAPABILITY_MORE_CAPS		BIT_31
+#define QLCNIC_FW_CAPABILITY_2_LRO_MAX_TCP_SEG	BIT_2
+#define QLCNIC_FW_CAPABILITY_2_OCBB		BIT_5
 
 /* module types */
 #define LINKEVENT_MODULE_NOT_PRESENT			1
@@ -961,6 +971,8 @@ struct qlcnic_ipaddr {
 #define QLCNIC_NEED_FLR			0x1000
 #define QLCNIC_FW_RESET_OWNER		0x2000
 #define QLCNIC_FW_HANG			0x4000
+#define QLCNIC_FW_LRO_MSS_CAP          0x8000
+
 #define QLCNIC_IS_MSI_FAMILY(adapter) \
 	((adapter)->flags & (QLCNIC_MSI_ENABLED | QLCNIC_MSIX_ENABLED))
 
@@ -1598,8 +1610,10 @@ int qlcnic_nic_set_promisc(struct qlcnic_adapter *, u32);
 void qlcnic_config_intr_coalesce(struct qlcnic_adapter *);
 int qlcnic_config_rss(struct qlcnic_adapter *, int);
 void qlcnic_config_ipaddr(struct qlcnic_adapter *, __be32, int);
+void qlcnic_83xx_config_ipaddr(struct qlcnic_adapter *, __be32, int);
 int qlcnic_linkevent_request(struct qlcnic_adapter *, int);
 int qlcnic_fw_cmd_set_mtu(struct qlcnic_adapter *, int);
+int qlcnic_fw_cmd_set_drv_version(struct qlcnic_adapter *);
 int qlcnic_change_mtu(struct net_device *, int);
 int qlcnic_change_mtu(struct net_device *netdev, int new_mtu);
 netdev_features_t qlcnic_fix_features(struct net_device *netdev,
@@ -1703,7 +1717,7 @@ int qlcnic_set_default_offload_settings(struct qlcnic_adapter *);
 int qlcnic_reset_npar_config(struct qlcnic_adapter *);
 int qlcnic_alloc_mbx_args(struct qlcnic_cmd_args *,
 			struct qlcnic_adapter *, u32);
-int qlcnic_is_valid_nic_func(struct qlcnic_adapter *, u8);
+
 /*
  * QLOGIC Board information
  */
@@ -1780,11 +1794,4 @@ struct qlcnic_hardware_ops {
 
 extern struct qlcnic_nic_template qlcnic_vf_ops;
 
-#define QLCDB(adapter, lvl, _fmt, _args...) do {	\
-	if (NETIF_MSG_##lvl & adapter->ahw->msg_enable)	\
-		printk(KERN_INFO "%s: %s: " _fmt,	\
-			dev_name(&adapter->pdev->dev),	\
-			__func__, ##_args);		\
-	} while (0)
-
 #endif				/* __QLCNIC_H_ */
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_82xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_82xx_hw.c
new file mode 100644
index 0000000..93a3c18
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_82xx_hw.c
@@ -0,0 +1,2590 @@
+/*
+ * QLogic qlcnic NIC Driver
+ * Copyright (c)  2009-2010 QLogic Corporation
+ *
+ * See LICENSE.qlcnic for copyright and licensing details.
+ */
+
+#include "qlcnic.h"
+#include "qlcnic_hdr.h"
+#include "qlcnic_hw.h"
+
+#include <linux/slab.h>
+#include <net/ip.h>
+#include <linux/bitops.h>
+
+#ifndef readq
+static inline u64 readq(void __iomem *addr)
+{
+	return readl(addr) | (((u64) readl(addr + 4)) << 32LL);
+}
+#endif
+
+#ifndef writeq
+static inline void writeq(u64 val, void __iomem *addr)
+{
+	writel(((u32) (val)), (addr));
+	writel(((u32) (val >> 32)), (addr + 4));
+}
+#endif
+
+static const struct crb_128M_2M_block_map
+crb_128M_2M_map[64] __cacheline_aligned_in_smp = {
+	{{{0, 0,         0,         0} } },		/* 0: PCI */
+	{{{1, 0x0100000, 0x0102000, 0x120000},	/* 1: PCIE */
+	{1, 0x0110000, 0x0120000, 0x130000},
+	{1, 0x0120000, 0x0122000, 0x124000},
+	{1, 0x0130000, 0x0132000, 0x126000},
+	{1, 0x0140000, 0x0142000, 0x128000},
+	{1, 0x0150000, 0x0152000, 0x12a000},
+	{1, 0x0160000, 0x0170000, 0x110000},
+	{1, 0x0170000, 0x0172000, 0x12e000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{1, 0x01e0000, 0x01e0800, 0x122000},
+	{0, 0x0000000, 0x0000000, 0x000000} } },
+	{{{1, 0x0200000, 0x0210000, 0x180000} } },/* 2: MN */
+	{{{0, 0,         0,         0} } },	    /* 3: */
+	{{{1, 0x0400000, 0x0401000, 0x169000} } },/* 4: P2NR1 */
+	{{{1, 0x0500000, 0x0510000, 0x140000} } },/* 5: SRE   */
+	{{{1, 0x0600000, 0x0610000, 0x1c0000} } },/* 6: NIU   */
+	{{{1, 0x0700000, 0x0704000, 0x1b8000} } },/* 7: QM    */
+	{{{1, 0x0800000, 0x0802000, 0x170000},  /* 8: SQM0  */
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{1, 0x08f0000, 0x08f2000, 0x172000} } },
+	{{{1, 0x0900000, 0x0902000, 0x174000},	/* 9: SQM1*/
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{1, 0x09f0000, 0x09f2000, 0x176000} } },
+	{{{0, 0x0a00000, 0x0a02000, 0x178000},	/* 10: SQM2*/
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{1, 0x0af0000, 0x0af2000, 0x17a000} } },
+	{{{0, 0x0b00000, 0x0b02000, 0x17c000},	/* 11: SQM3*/
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{1, 0x0bf0000, 0x0bf2000, 0x17e000} } },
+	{{{1, 0x0c00000, 0x0c04000, 0x1d4000} } },/* 12: I2Q */
+	{{{1, 0x0d00000, 0x0d04000, 0x1a4000} } },/* 13: TMR */
+	{{{1, 0x0e00000, 0x0e04000, 0x1a0000} } },/* 14: ROMUSB */
+	{{{1, 0x0f00000, 0x0f01000, 0x164000} } },/* 15: PEG4 */
+	{{{0, 0x1000000, 0x1004000, 0x1a8000} } },/* 16: XDMA */
+	{{{1, 0x1100000, 0x1101000, 0x160000} } },/* 17: PEG0 */
+	{{{1, 0x1200000, 0x1201000, 0x161000} } },/* 18: PEG1 */
+	{{{1, 0x1300000, 0x1301000, 0x162000} } },/* 19: PEG2 */
+	{{{1, 0x1400000, 0x1401000, 0x163000} } },/* 20: PEG3 */
+	{{{1, 0x1500000, 0x1501000, 0x165000} } },/* 21: P2ND */
+	{{{1, 0x1600000, 0x1601000, 0x166000} } },/* 22: P2NI */
+	{{{0, 0,         0,         0} } },	/* 23: */
+	{{{0, 0,         0,         0} } },	/* 24: */
+	{{{0, 0,         0,         0} } },	/* 25: */
+	{{{0, 0,         0,         0} } },	/* 26: */
+	{{{0, 0,         0,         0} } },	/* 27: */
+	{{{0, 0,         0,         0} } },	/* 28: */
+	{{{1, 0x1d00000, 0x1d10000, 0x190000} } },/* 29: MS */
+	{{{1, 0x1e00000, 0x1e01000, 0x16a000} } },/* 30: P2NR2 */
+	{{{1, 0x1f00000, 0x1f10000, 0x150000} } },/* 31: EPG */
+	{{{0} } },				/* 32: PCI */
+	{{{1, 0x2100000, 0x2102000, 0x120000},	/* 33: PCIE */
+	{1, 0x2110000, 0x2120000, 0x130000},
+	{1, 0x2120000, 0x2122000, 0x124000},
+	{1, 0x2130000, 0x2132000, 0x126000},
+	{1, 0x2140000, 0x2142000, 0x128000},
+	{1, 0x2150000, 0x2152000, 0x12a000},
+	{1, 0x2160000, 0x2170000, 0x110000},
+	{1, 0x2170000, 0x2172000, 0x12e000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000},
+	{0, 0x0000000, 0x0000000, 0x000000} } },
+	{{{1, 0x2200000, 0x2204000, 0x1b0000} } },/* 34: CAM */
+	{{{0} } },				/* 35: */
+	{{{0} } },				/* 36: */
+	{{{0} } },				/* 37: */
+	{{{0} } },				/* 38: */
+	{{{0} } },				/* 39: */
+	{{{1, 0x2800000, 0x2804000, 0x1a4000} } },/* 40: TMR */
+	{{{1, 0x2900000, 0x2901000, 0x16b000} } },/* 41: P2NR3 */
+	{{{1, 0x2a00000, 0x2a00400, 0x1ac400} } },/* 42: RPMX1 */
+	{{{1, 0x2b00000, 0x2b00400, 0x1ac800} } },/* 43: RPMX2 */
+	{{{1, 0x2c00000, 0x2c00400, 0x1acc00} } },/* 44: RPMX3 */
+	{{{1, 0x2d00000, 0x2d00400, 0x1ad000} } },/* 45: RPMX4 */
+	{{{1, 0x2e00000, 0x2e00400, 0x1ad400} } },/* 46: RPMX5 */
+	{{{1, 0x2f00000, 0x2f00400, 0x1ad800} } },/* 47: RPMX6 */
+	{{{1, 0x3000000, 0x3000400, 0x1adc00} } },/* 48: RPMX7 */
+	{{{0, 0x3100000, 0x3104000, 0x1a8000} } },/* 49: XDMA */
+	{{{1, 0x3200000, 0x3204000, 0x1d4000} } },/* 50: I2Q */
+	{{{1, 0x3300000, 0x3304000, 0x1a0000} } },/* 51: ROMUSB */
+	{{{0} } },				/* 52: */
+	{{{1, 0x3500000, 0x3500400, 0x1ac000} } },/* 53: RPMX0 */
+	{{{1, 0x3600000, 0x3600400, 0x1ae000} } },/* 54: RPMX8 */
+	{{{1, 0x3700000, 0x3700400, 0x1ae400} } },/* 55: RPMX9 */
+	{{{1, 0x3800000, 0x3804000, 0x1d0000} } },/* 56: OCM0 */
+	{{{1, 0x3900000, 0x3904000, 0x1b4000} } },/* 57: CRYPTO */
+	{{{1, 0x3a00000, 0x3a04000, 0x1d8000} } },/* 58: SMB */
+	{{{0} } },				/* 59: I2C0 */
+	{{{0} } },				/* 60: I2C1 */
+	{{{1, 0x3d00000, 0x3d04000, 0x1d8000} } },/* 61: LPC */
+	{{{1, 0x3e00000, 0x3e01000, 0x167000} } },/* 62: P2NC */
+	{{{1, 0x3f00000, 0x3f01000, 0x168000} } }	/* 63: P2NR0 */
+};
+
+/*
+ * Top 12 bits of Command Regiser Block (CRB) internal address (hub, agent)
+ */
+static const unsigned crb_hub_agt[64] = {
+	0,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_PS,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_MN,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_MS,
+	0,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_SRE,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_NIU,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_QMN,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_SQN0,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_SQN1,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_SQN2,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_SQN3,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_I2Q,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_TIMR,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_ROMUSB,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_PGN4,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_XDMA,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_PGN0,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_PGN1,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_PGN2,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_PGN3,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_PGND,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_PGNI,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_PGS0,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_PGS1,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_PGS2,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_PGS3,
+	0,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_PGSI,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_SN,
+	0,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_EG,
+	0,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_PS,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_CAM,
+	0,
+	0,
+	0,
+	0,
+	0,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_TIMR,
+	0,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_RPMX1,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_RPMX2,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_RPMX3,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_RPMX4,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_RPMX5,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_RPMX6,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_RPMX7,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_XDMA,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_I2Q,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_ROMUSB,
+	0,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_RPMX0,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_RPMX8,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_RPMX9,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_OCM0,
+	0,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_SMB,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_I2C0,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_I2C1,
+	0,
+	QLCNIC_HW_CRB_HUB_AGT_ADR_PGNC,
+	0,
+};
+
+static const u32 msi_tgt_status[8] = {
+	ISR_INT_TARGET_STATUS, ISR_INT_TARGET_STATUS_F1,
+	ISR_INT_TARGET_STATUS_F2, ISR_INT_TARGET_STATUS_F3,
+	ISR_INT_TARGET_STATUS_F4, ISR_INT_TARGET_STATUS_F5,
+	ISR_INT_TARGET_STATUS_F6, ISR_INT_TARGET_STATUS_F7
+};
+
+/* PCI windowing for DDR regions.  */
+static void
+qlcnic_read_reg_indirect(u32 addr, void __iomem *bar0, u32 *data)
+{
+	u32 dest;
+	void __iomem *val;
+
+	dest = addr & 0xFFFF0000;
+	val = bar0 + QLCNIC_CRB_WINDOW_2M;
+	writel(dest, val);
+	readl(val);
+	val = bar0 + QLCNIC_INDIRECT_MEM_START + LSW(addr);
+	*data = readl(val);
+}
+
+static void
+qlcnic_write_reg_indirect(u32 addr, void __iomem *bar0, u32 data)
+{
+	u32 dest;
+	void __iomem *val;
+
+	dest = addr & 0xFFFF0000;
+	val = bar0 + QLCNIC_CRB_WINDOW_2M;
+	writel(dest, val);
+	readl(val);
+	val = bar0 + QLCNIC_INDIRECT_MEM_START + LSW(addr);
+	writel(data, val);
+	readl(val);
+}
+
+int
+qlcnic_pcie_sem_lock(struct qlcnic_adapter *adapter, int sem, u32 id_reg)
+{
+	int err, done = 0, timeout = 0;
+
+	while (!done) {
+		done = QLCRD32(adapter,
+			QLCNIC_PCIE_REG(PCIE_SEM_LOCK(sem)), &err);
+		if (done == 1)
+			break;
+		if (++timeout >= QLCNIC_PCIE_SEM_TIMEOUT) {
+			dev_err(&adapter->pdev->dev,
+				"Failed to acquire sem=%d lock; held by=%d\n",
+				sem,
+				id_reg ? QLCRD32(adapter, id_reg, &err) : -1);
+			return -EIO;
+		}
+		usleep_range(1000, 2000);
+	}
+
+	if (id_reg)
+		QLCWR32(adapter, id_reg, adapter->portnum);
+
+	return 0;
+}
+
+u32 qlcnic_ind_rd(struct qlcnic_adapter *adapter, u32 addr)
+{
+	int err;
+	u32 data;
+
+	if (QLCNIC_IS_82XX(adapter))
+		qlcnic_read_reg_indirect(addr, adapter->ahw->pci_base0, &data);
+	else
+		data = qlcnic_83xx_rd_reg_indirect(adapter, addr, &err);
+
+	return data;
+}
+
+void qlcnic_ind_wr(struct qlcnic_adapter *adapter, u32 addr, u32 data)
+{
+	if (QLCNIC_IS_82XX(adapter))
+		qlcnic_write_reg_indirect(addr, adapter->ahw->pci_base0, data);
+	else
+		qlcnic_83xx_wrt_reg_indirect(adapter, addr, data);
+}
+
+void
+qlcnic_pcie_sem_unlock(struct qlcnic_adapter *adapter, int sem)
+{
+	int err;
+
+	QLCRD32(adapter, QLCNIC_PCIE_REG(PCIE_SEM_UNLOCK(sem)), &err);
+}
+
+static int
+qlcnic_send_cmd_descs(struct qlcnic_adapter *adapter,
+		struct cmd_desc_type0 *cmd_desc_arr, int nr_desc)
+{
+	u32 i, producer, consumer;
+	struct qlcnic_cmd_buffer *pbuf;
+	struct cmd_desc_type0 *cmd_desc;
+	struct qlcnic_host_tx_ring *tx_ring;
+
+	i = 0;
+
+	if (!test_bit(__QLCNIC_FW_ATTACHED, &adapter->state))
+		return -EIO;
+
+	tx_ring = adapter->tx_ring;
+	__netif_tx_lock_bh(tx_ring->txq);
+
+	producer = tx_ring->producer;
+	consumer = tx_ring->sw_consumer;
+
+	if (nr_desc >= qlcnic_tx_avail(tx_ring)) {
+		netif_tx_stop_queue(tx_ring->txq);
+		smp_mb();
+		if (qlcnic_tx_avail(tx_ring) > nr_desc) {
+			if (qlcnic_tx_avail(tx_ring) > TX_STOP_THRESH)
+				netif_tx_wake_queue(tx_ring->txq);
+		} else {
+			adapter->stats.xmit_off++;
+			__netif_tx_unlock_bh(tx_ring->txq);
+			return -EBUSY;
+		}
+	}
+
+	do {
+		cmd_desc = &cmd_desc_arr[i];
+
+		pbuf = &tx_ring->cmd_buf_arr[producer];
+		pbuf->skb = NULL;
+		pbuf->frag_count = 0;
+
+		memcpy(&tx_ring->desc_head[producer],
+			&cmd_desc_arr[i], sizeof(struct cmd_desc_type0));
+
+		producer = get_next_index(producer, tx_ring->num_desc);
+		i++;
+
+	} while (i != nr_desc);
+
+	tx_ring->producer = producer;
+
+	qlcnic_update_cmd_producer(adapter, tx_ring);
+
+	__netif_tx_unlock_bh(tx_ring->txq);
+
+	return 0;
+}
+
+int
+qlcnic_sre_macaddr_change(struct qlcnic_adapter *adapter, u8 *addr,
+				__le16 vlan_id, u8 op)
+{
+	struct qlcnic_nic_req req;
+	struct qlcnic_mac_req *mac_req;
+	struct qlcnic_vlan_req *vlan_req;
+	u64 word;
+
+	memset(&req, 0, sizeof(struct qlcnic_nic_req));
+	req.qhdr = cpu_to_le64(QLCNIC_REQUEST << 23);
+
+	word = QLCNIC_MAC_EVENT | ((u64)adapter->portnum << 16);
+	req.req_hdr = cpu_to_le64(word);
+
+	mac_req = (struct qlcnic_mac_req *)&req.words[0];
+	mac_req->op = op;
+	memcpy(mac_req->mac_addr, addr, 6);
+
+	vlan_req = (struct qlcnic_vlan_req *)&req.words[1];
+	vlan_req->vlan_id = vlan_id;
+
+	return qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
+}
+
+static int qlcnic_nic_add_mac(struct qlcnic_adapter *adapter, const u8 *addr)
+{
+	struct list_head *head;
+	struct qlcnic_mac_list_s *cur;
+
+	/* look up if already exists */
+	list_for_each(head, &adapter->mac_list) {
+		cur = list_entry(head, struct qlcnic_mac_list_s, list);
+		if (memcmp(addr, cur->mac_addr, ETH_ALEN) == 0)
+			return 0;
+	}
+
+	cur = kzalloc(sizeof(struct qlcnic_mac_list_s), GFP_ATOMIC);
+	if (cur == NULL) {
+		dev_err(&adapter->netdev->dev,
+			"failed to add mac address filter\n");
+		return -ENOMEM;
+	}
+	memcpy(cur->mac_addr, addr, ETH_ALEN);
+
+	if (adapter->ahw->hw_ops->change_macvlan(adapter,
+				cur->mac_addr, 0, QLCNIC_MAC_ADD)) {
+		kfree(cur);
+		return -EIO;
+	}
+
+	list_add_tail(&cur->list, &adapter->mac_list);
+	return 0;
+}
+
+void qlcnic_set_multi(struct net_device *netdev)
+{
+	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+	struct netdev_hw_addr *ha;
+	static const u8 bcast_addr[ETH_ALEN] = {
+		0xff, 0xff, 0xff, 0xff, 0xff, 0xff
+	};
+	u32 mode = VPORT_MISS_MODE_DROP;
+
+	if (!test_bit(__QLCNIC_FW_ATTACHED, &adapter->state))
+		return;
+
+	qlcnic_nic_add_mac(adapter, adapter->mac_addr);
+	qlcnic_nic_add_mac(adapter, bcast_addr);
+
+	if (netdev->flags & IFF_PROMISC) {
+		if (!(adapter->flags & QLCNIC_PROMISC_DISABLED))
+			mode = VPORT_MISS_MODE_ACCEPT_ALL;
+		goto send_fw_cmd;
+	}
+
+	if ((netdev->flags & IFF_ALLMULTI) ||
+	    (netdev_mc_count(netdev) > adapter->ahw->max_mc_count)) {
+		mode = VPORT_MISS_MODE_ACCEPT_MULTI;
+		goto send_fw_cmd;
+	}
+
+	if (!netdev_mc_empty(netdev)) {
+		netdev_for_each_mc_addr(ha, netdev) {
+			qlcnic_nic_add_mac(adapter, ha->addr);
+		}
+	}
+
+send_fw_cmd:
+	if (mode == VPORT_MISS_MODE_ACCEPT_ALL) {
+		qlcnic_alloc_lb_filters_mem(adapter);
+		adapter->mac_learn = 1;
+	} else {
+		adapter->mac_learn = 0;
+	}
+
+	adapter->ahw->hw_ops->config_promisc_mode(adapter, mode);
+}
+
+int qlcnic_nic_set_promisc(struct qlcnic_adapter *adapter, u32 mode)
+{
+	struct qlcnic_nic_req req;
+	u64 word;
+
+	memset(&req, 0, sizeof(struct qlcnic_nic_req));
+
+	req.qhdr = cpu_to_le64(QLCNIC_HOST_REQUEST << 23);
+
+	word = QLCNIC_H2C_OPCODE_SET_MAC_RECEIVE_MODE |
+			((u64)adapter->portnum << 16);
+	req.req_hdr = cpu_to_le64(word);
+
+	req.words[0] = cpu_to_le64(mode);
+
+	return qlcnic_send_cmd_descs(adapter,
+				(struct cmd_desc_type0 *)&req, 1);
+}
+
+void qlcnic_free_mac_list(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_mac_list_s *cur;
+	struct list_head *head = &adapter->mac_list;
+
+	while (!list_empty(head)) {
+		cur = list_entry(head->next, struct qlcnic_mac_list_s, list);
+		adapter->ahw->hw_ops->change_macvlan(adapter,
+				cur->mac_addr, 0, QLCNIC_MAC_DEL);
+		list_del(&cur->list);
+		kfree(cur);
+	}
+}
+
+void qlcnic_prune_lb_filters(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_filter *tmp_fil;
+	struct hlist_node *tmp_hnode, *n;
+	struct hlist_head *head;
+	int i;
+
+	for (i = 0; i < adapter->fhash.fmax; i++) {
+		head = &(adapter->fhash.fhead[i]);
+
+		hlist_for_each_entry_safe(tmp_fil, tmp_hnode, n, head, fnode)
+		{
+			if (jiffies >
+				(QLCNIC_FILTER_AGE * HZ + tmp_fil->ftime)) {
+				adapter->ahw->hw_ops->change_macvlan(adapter,
+					tmp_fil->faddr, tmp_fil->vlan_id,
+					tmp_fil->vlan_id ? QLCNIC_MAC_VLAN_DEL :
+					QLCNIC_MAC_DEL);
+				spin_lock_bh(&adapter->mac_learn_lock);
+				adapter->fhash.fnum--;
+				hlist_del(&tmp_fil->fnode);
+				spin_unlock_bh(&adapter->mac_learn_lock);
+				kfree(tmp_fil);
+			}
+		}
+	}
+}
+
+void qlcnic_delete_lb_filters(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_filter *tmp_fil;
+	struct hlist_node *tmp_hnode, *n;
+	struct hlist_head *head;
+	int i;
+
+	for (i = 0; i < adapter->fhash.fmax; i++) {
+		head = &(adapter->fhash.fhead[i]);
+
+		hlist_for_each_entry_safe(tmp_fil, tmp_hnode, n, head, fnode) {
+			adapter->ahw->hw_ops->change_macvlan(adapter,
+				tmp_fil->faddr, tmp_fil->vlan_id,
+				tmp_fil->vlan_id ?  QLCNIC_MAC_VLAN_DEL :
+				QLCNIC_MAC_DEL);
+			spin_lock_bh(&adapter->mac_learn_lock);
+			adapter->fhash.fnum--;
+			hlist_del(&tmp_fil->fnode);
+			spin_unlock_bh(&adapter->mac_learn_lock);
+			kfree(tmp_fil);
+		}
+	}
+}
+
+int qlcnic_set_fw_loopback(struct qlcnic_adapter *adapter, u8 flag)
+{
+	struct qlcnic_nic_req req;
+	int rv;
+
+	memset(&req, 0, sizeof(struct qlcnic_nic_req));
+
+	req.qhdr = cpu_to_le64(QLCNIC_HOST_REQUEST << 23);
+	req.req_hdr = cpu_to_le64(QLCNIC_H2C_OPCODE_CONFIG_LOOPBACK |
+		((u64) adapter->portnum << 16) | ((u64) 0x1 << 32));
+
+	req.words[0] = cpu_to_le64(flag);
+
+	rv = qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
+	if (rv != 0)
+		dev_err(&adapter->pdev->dev, "%sting loopback mode failed\n",
+				flag ? "Set" : "Reset");
+	return rv;
+}
+
+int qlcnic_set_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
+{
+	if (qlcnic_set_fw_loopback(adapter, mode))
+		return -EIO;
+
+	if (adapter->ahw->hw_ops->config_promisc_mode(adapter,
+		VPORT_MISS_MODE_ACCEPT_ALL)) {
+		qlcnic_set_fw_loopback(adapter, 0);
+		return -EIO;
+	}
+
+	msleep(1000);
+	return 0;
+}
+
+int qlcnic_clear_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
+{
+	struct net_device *netdev = adapter->netdev;
+
+	mode = VPORT_MISS_MODE_DROP;
+	qlcnic_set_fw_loopback(adapter, 0);
+
+	if (netdev->flags & IFF_PROMISC)
+		mode = VPORT_MISS_MODE_ACCEPT_ALL;
+	else if (netdev->flags & IFF_ALLMULTI)
+		mode = VPORT_MISS_MODE_ACCEPT_MULTI;
+
+	adapter->ahw->hw_ops->config_promisc_mode(adapter, mode);
+	msleep(1000);
+	return 0;
+}
+
+void qlcnic_config_intr_coalesce(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_nic_req req;
+	int rv;
+
+	memset(&req, 0, sizeof(struct qlcnic_nic_req));
+
+	req.qhdr = cpu_to_le64(QLCNIC_HOST_REQUEST << 23);
+
+	req.req_hdr = cpu_to_le64(QLCNIC_CONFIG_INTR_COALESCE |
+		((u64) adapter->portnum << 16));
+
+	req.words[0] = cpu_to_le64(((u64) adapter->ahw->coal.flag) << 32);
+	req.words[2] = cpu_to_le64(adapter->ahw->coal.rx_packets |
+			((u64) adapter->ahw->coal.rx_time_us) << 16);
+	req.words[5] = cpu_to_le64(adapter->ahw->coal.timer_out |
+			((u64) adapter->ahw->coal.type) << 32 |
+			((u64) adapter->ahw->coal.sts_ring_mask) << 40);
+	rv = qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
+	if (rv != 0)
+		dev_err(&adapter->netdev->dev,
+			"Could not send interrupt coalescing parameters\n");
+}
+
+int qlcnic_config_hw_lro(struct qlcnic_adapter *adapter, int enable)
+{
+	struct qlcnic_nic_req req;
+	u64 word;
+	int rv;
+
+	if (!test_bit(__QLCNIC_FW_ATTACHED, &adapter->state))
+		return 0;
+
+	memset(&req, 0, sizeof(struct qlcnic_nic_req));
+
+	req.qhdr = cpu_to_le64(QLCNIC_HOST_REQUEST << 23);
+
+	word = QLCNIC_H2C_OPCODE_CONFIG_HW_LRO | ((u64)adapter->portnum << 16);
+	req.req_hdr = cpu_to_le64(word);
+
+	req.words[0] = cpu_to_le64(enable);
+
+	rv = qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
+	if (rv != 0)
+		dev_err(&adapter->netdev->dev,
+			"Could not send configure hw lro request\n");
+
+	return rv;
+}
+
+int qlcnic_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable)
+{
+	struct qlcnic_nic_req req;
+	u64 word;
+	int rv;
+
+	if (!!(adapter->flags & QLCNIC_BRIDGE_ENABLED) == enable)
+		return 0;
+
+	memset(&req, 0, sizeof(struct qlcnic_nic_req));
+
+	req.qhdr = cpu_to_le64(QLCNIC_HOST_REQUEST << 23);
+
+	word = QLCNIC_H2C_OPCODE_CONFIG_BRIDGING |
+		((u64)adapter->portnum << 16);
+	req.req_hdr = cpu_to_le64(word);
+
+	req.words[0] = cpu_to_le64(enable);
+
+	rv = qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
+	if (rv != 0)
+		dev_err(&adapter->netdev->dev,
+			"Could not send configure bridge mode request\n");
+
+	adapter->flags ^= QLCNIC_BRIDGE_ENABLED;
+
+	return rv;
+}
+
+int qlcnic_config_rss(struct qlcnic_adapter *adapter, int enable)
+{
+	struct qlcnic_nic_req req;
+	u64 word;
+	int i, rv;
+
+	static const u64 key[] = {
+		0xbeac01fa6a42b73bULL, 0x8030f20c77cb2da3ULL,
+		0xae7b30b4d0ca2bcbULL, 0x43a38fb04167253dULL,
+		0x255b0ec26d5a56daULL
+	};
+
+	memset(&req, 0, sizeof(struct qlcnic_nic_req));
+	req.qhdr = cpu_to_le64(QLCNIC_HOST_REQUEST << 23);
+
+	word = QLCNIC_H2C_OPCODE_CONFIG_RSS | ((u64)adapter->portnum << 16);
+	req.req_hdr = cpu_to_le64(word);
+
+	/*
+	 * RSS request:
+	 * bits 3-0: hash_method
+	 *      5-4: hash_type_ipv4
+	 *	7-6: hash_type_ipv6
+	 *	  8: enable
+	 *        9: use indirection table
+	 *    47-10: reserved
+	 *    63-48: indirection table mask
+	 */
+	word =  ((u64)(RSS_HASHTYPE_IP_TCP & 0x3) << 4) |
+		((u64)(RSS_HASHTYPE_IP_TCP & 0x3) << 6) |
+		((u64)(enable & 0x1) << 8) |
+		((0x7ULL) << 48);
+	req.words[0] = cpu_to_le64(word);
+	for (i = 0; i < 5; i++)
+		req.words[i+1] = cpu_to_le64(key[i]);
+
+	rv = qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
+	if (rv != 0)
+		dev_err(&adapter->netdev->dev, "could not configure RSS\n");
+
+	return rv;
+}
+
+void qlcnic_config_ipaddr(struct qlcnic_adapter *adapter, __be32 ip, int cmd)
+{
+	struct qlcnic_nic_req req;
+	struct qlcnic_ipaddr *ipa;
+	u64 word;
+	int rv;
+
+	memset(&req, 0, sizeof(struct qlcnic_nic_req));
+	req.qhdr = cpu_to_le64(QLCNIC_HOST_REQUEST << 23);
+
+	word = QLCNIC_H2C_OPCODE_CONFIG_IPADDR | ((u64)adapter->portnum << 16);
+	req.req_hdr = cpu_to_le64(word);
+
+	req.words[0] = cpu_to_le64(cmd);
+	ipa = (struct qlcnic_ipaddr *)&req.words[1];
+	ipa->ipv4 = ip;
+
+	rv = qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
+	if (rv != 0)
+		dev_err(&adapter->netdev->dev,
+				"could not notify %s IP 0x%x request\n",
+				(cmd == QLCNIC_IP_UP) ? "Add" : "Remove", ip);
+}
+
+int qlcnic_linkevent_request(struct qlcnic_adapter *adapter, int enable)
+{
+	struct qlcnic_nic_req req;
+	u64 word;
+	int rv;
+	memset(&req, 0, sizeof(struct qlcnic_nic_req));
+	req.qhdr = cpu_to_le64(QLCNIC_HOST_REQUEST << 23);
+
+	word = QLCNIC_H2C_OPCODE_GET_LINKEVENT | ((u64)adapter->portnum << 16);
+	req.req_hdr = cpu_to_le64(word);
+	req.words[0] = cpu_to_le64(enable | (enable << 8));
+	rv = qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
+	if (rv != 0)
+		dev_err(&adapter->netdev->dev,
+				"could not configure link notification\n");
+
+	return rv;
+}
+
+int qlcnic_send_lro_cleanup(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_nic_req req;
+	u64 word;
+	int rv;
+
+	if (!test_bit(__QLCNIC_FW_ATTACHED, &adapter->state))
+		return 0;
+
+	memset(&req, 0, sizeof(struct qlcnic_nic_req));
+	req.qhdr = cpu_to_le64(QLCNIC_HOST_REQUEST << 23);
+
+	word = QLCNIC_H2C_OPCODE_LRO_REQUEST |
+		((u64)adapter->portnum << 16) |
+		((u64)QLCNIC_LRO_REQUEST_CLEANUP << 56) ;
+
+	req.req_hdr = cpu_to_le64(word);
+
+	rv = qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
+	if (rv != 0)
+		dev_err(&adapter->netdev->dev,
+				 "could not cleanup lro flows\n");
+
+	return rv;
+}
+
+int qlcnic_change_mtu(struct net_device *netdev, int mtu)
+{
+	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+	int rc = 0;
+
+	if (mtu < P3P_MIN_MTU || mtu > P3P_MAX_MTU) {
+		dev_err(&adapter->netdev->dev,
+			"%d bytes < mtu < %d bytes not supported\n",
+						P3P_MAX_MTU, P3P_MIN_MTU);
+		return -EINVAL;
+	}
+
+	rc = qlcnic_fw_cmd_set_mtu(adapter, mtu);
+
+	if (!rc)
+		netdev->mtu = mtu;
+
+	return rc;
+}
+
+netdev_features_t qlcnic_fix_features(struct net_device *netdev,
+	netdev_features_t features)
+{
+	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+
+	if ((adapter->flags & QLCNIC_ESWITCH_ENABLED)) {
+		netdev_features_t changed = features ^ netdev->features;
+		features ^= changed & (NETIF_F_ALL_CSUM | NETIF_F_RXCSUM);
+	}
+
+	if (!(features & NETIF_F_RXCSUM))
+		features &= ~NETIF_F_LRO;
+
+	return features;
+}
+
+int qlcnic_set_features(struct net_device *netdev, netdev_features_t features)
+{
+	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+	netdev_features_t changed = netdev->features ^ features;
+	int hw_lro = (features & NETIF_F_LRO) ? QLCNIC_LRO_ENABLED : 0;
+
+	if (!(changed & NETIF_F_LRO))
+		return 0;
+
+	netdev->features = features ^ NETIF_F_LRO;
+
+	if (qlcnic_config_hw_lro(adapter, hw_lro))
+		return -EIO;
+
+	if ((hw_lro == 0) && qlcnic_send_lro_cleanup(adapter))
+		return -EIO;
+
+	return 0;
+}
+
+static int
+qlcnic_pci_get_crb_addr_2M(struct qlcnic_hardware_context *ahw,
+		ulong off, void __iomem **addr)
+{
+	const struct crb_128M_2M_sub_block_map *map;
+
+	if ((off >= QLCNIC_CRB_MAX) || (off < QLCNIC_PCI_CRBSPACE))
+		return -EINVAL;
+
+	off -= QLCNIC_PCI_CRBSPACE;
+
+	/* Try direct map */
+	map = &crb_128M_2M_map[CRB_BLK(off)].sub_block[CRB_SUBBLK(off)];
+
+	if (map->valid && (map->start_128M <= off) && (map->end_128M > off)) {
+		*addr = ahw->pci_base0 + map->start_2M +
+			(off - map->start_128M);
+		return 0;
+	}
+
+	/* Not in direct map, use crb window */
+	*addr = ahw->pci_base0 + CRB_INDIRECT_2M + (off & MASK(16));
+	return 1;
+}
+
+static int
+qlcnic_pci_set_crbwindow_2M(struct qlcnic_adapter *adapter, ulong off)
+{
+	u32 window;
+	void __iomem *addr = adapter->ahw->pci_base0 + CRB_WINDOW_2M;
+
+	off -= QLCNIC_PCI_CRBSPACE;
+
+	window = CRB_HI(off);
+	if (window == 0) {
+		dev_err(&adapter->pdev->dev, "Invalid offset 0x%lx\n", off);
+		return -EIO;
+	}
+
+	writel(window, addr);
+	if (readl(addr) != window) {
+		printk_ratelimited(KERN_WARNING
+				"failed to set CRB window to %d off 0x%lx\n",
+				window, off);
+		return -EIO;
+	}
+	return 0;
+}
+
+int
+qlcnic_hw_write_wx_2M(struct qlcnic_adapter *adapter, ulong off, u32 data)
+{
+	unsigned long flags;
+	int rv;
+	void __iomem *addr = NULL;
+
+	rv = qlcnic_pci_get_crb_addr_2M(adapter->ahw, off, &addr);
+
+	if (rv == 0) {
+		writel(data, addr);
+		return 0;
+	}
+
+	if (rv > 0) {
+		/* indirect access */
+		write_lock_irqsave(&adapter->ahw->crb_lock, flags);
+		crb_win_lock(adapter);
+		rv = qlcnic_pci_set_crbwindow_2M(adapter, off);
+		if (!rv)
+			writel(data, addr);
+		crb_win_unlock(adapter);
+		write_unlock_irqrestore(&adapter->ahw->crb_lock, flags);
+		return rv;
+	}
+
+	dev_err(&adapter->pdev->dev,
+			"%s: invalid offset: 0x%016lx\n", __func__, off);
+	dump_stack();
+	return -EIO;
+}
+
+u32
+qlcnic_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off, int *err)
+{
+	unsigned long flags;
+	int rv;
+	u32 data = -1;
+	void __iomem *addr = NULL;
+
+	rv = qlcnic_pci_get_crb_addr_2M(adapter->ahw, off, &addr);
+
+	if (rv == 0)
+		return readl(addr);
+
+	if (rv > 0) {
+		/* indirect access */
+		write_lock_irqsave(&adapter->ahw->crb_lock, flags);
+		crb_win_lock(adapter);
+		if (!qlcnic_pci_set_crbwindow_2M(adapter, off))
+			data = readl(addr);
+		crb_win_unlock(adapter);
+		write_unlock_irqrestore(&adapter->ahw->crb_lock, flags);
+		return data;
+	}
+
+	dev_err(&adapter->pdev->dev,
+			"%s: invalid offset: 0x%016lx\n", __func__, off);
+	dump_stack();
+	if (err)
+		*err = -1;
+
+	return -1;
+}
+
+
+void __iomem *
+qlcnic_get_ioaddr(struct qlcnic_hardware_context *ahw, u32 offset)
+{
+	void __iomem *addr = NULL;
+
+	WARN_ON(qlcnic_pci_get_crb_addr_2M(ahw, offset, &addr));
+
+	return addr;
+}
+
+static int
+qlcnic_pci_mem_access_direct(struct qlcnic_adapter *adapter, u32 window,
+	u64 off, u64 *data, int op)
+{
+	void __iomem *addr;
+	u32 start;
+
+	mutex_lock(&adapter->ahw->mem_lock);
+
+	writel(window, adapter->ahw->ocm_win_crb);
+	/* read back to flush */
+	readl(adapter->ahw->ocm_win_crb);
+	start = QLCNIC_PCI_OCM0_2M + off;
+
+	addr = adapter->ahw->pci_base0 + start;
+
+	if (op == 0)
+		*data = readq(addr);
+	else
+		writeq(*data, addr);
+
+	/* Set window to 0 */
+	writel(0, adapter->ahw->ocm_win_crb);
+	readl(adapter->ahw->ocm_win_crb);
+
+	mutex_unlock(&adapter->ahw->mem_lock);
+	return 0;
+}
+
+void
+qlcnic_pci_camqm_read_2M(struct qlcnic_adapter *adapter, u64 off, u64 *data)
+{
+	void __iomem *addr = adapter->ahw->pci_base0 +
+		QLCNIC_PCI_CAMQM_2M_BASE + (off - QLCNIC_PCI_CAMQM);
+
+	mutex_lock(&adapter->ahw->mem_lock);
+	*data = readq(addr);
+	mutex_unlock(&adapter->ahw->mem_lock);
+}
+
+void
+qlcnic_pci_camqm_write_2M(struct qlcnic_adapter *adapter, u64 off, u64 data)
+{
+	void __iomem *addr = adapter->ahw->pci_base0 +
+		QLCNIC_PCI_CAMQM_2M_BASE + (off - QLCNIC_PCI_CAMQM);
+
+	mutex_lock(&adapter->ahw->mem_lock);
+	writeq(data, addr);
+	mutex_unlock(&adapter->ahw->mem_lock);
+}
+
+#define MAX_CTL_CHECK   1000
+
+/* Set MS memory control data for different chip type*/
+static void
+qlcnic_set_ms_controls(struct qlcnic_adapter *adapter, u64 off,
+	struct qlcnic_ms_reg_ctrl *ms)
+{
+	ms->control = QLCNIC_MS_CTRL;
+	ms->low = QLCNIC_MS_ADDR_LO;
+	ms->hi = QLCNIC_MS_ADDR_HI;
+	if (off & 0xf) {
+		ms->wd[0] = QLCNIC_MS_WRTDATA_LO;
+		ms->rd[0] = QLCNIC_MS_RDDATA_LO;
+		ms->wd[1] = QLCNIC_MS_WRTDATA_HI;
+		ms->rd[1] = QLCNIC_MS_RDDATA_HI;
+		ms->wd[2] = QLCNIC_MS_WRTDATA_ULO;
+		ms->wd[3] = QLCNIC_MS_WRTDATA_UHI;
+		ms->rd[2] = QLCNIC_MS_RDDATA_ULO;
+		ms->rd[3] = QLCNIC_MS_RDDATA_UHI;
+	} else {
+		ms->wd[0] = QLCNIC_MS_WRTDATA_ULO;
+		ms->rd[0] = QLCNIC_MS_RDDATA_ULO;
+		ms->wd[1] = QLCNIC_MS_WRTDATA_UHI;
+		ms->rd[1] = QLCNIC_MS_RDDATA_UHI;
+		ms->wd[2] = QLCNIC_MS_WRTDATA_LO;
+		ms->wd[3] = QLCNIC_MS_WRTDATA_HI;
+		ms->rd[2] = QLCNIC_MS_RDDATA_LO;
+		ms->rd[3] = QLCNIC_MS_RDDATA_HI;
+	}
+	if (QLCNIC_IS_83XX(adapter)) {
+		ms->ocm_window = OCM_WIN_83XX(off);
+		ms->off = GET_83XX_OCM_OFFSET(off);
+	} else {
+		ms->ocm_window = OCM_WIN_P3P(off);
+		ms->off = GET_MEM_OFFS_2M(off);
+	}
+}
+
+int
+qlcnic_pci_mem_write_2M(struct qlcnic_adapter *adapter,
+		u64 off, u64 data)
+{
+	int j, ret = 0;
+	u32 temp, off8;
+	struct qlcnic_ms_reg_ctrl ms;
+
+	/* Only 64-bit aligned access */
+	if (off & 7)
+		return -EIO;
+
+	memset(&ms, 0, sizeof(struct qlcnic_ms_reg_ctrl));
+	if (!((ADDR_IN_RANGE(off, QLCNIC_ADDR_QDR_NET,
+		QLCNIC_ADDR_QDR_NET_MAX)) ||
+			(ADDR_IN_RANGE(off, QLCNIC_ADDR_DDR_NET,
+				QLCNIC_ADDR_DDR_NET_MAX))))
+		return -EIO;
+
+	qlcnic_set_ms_controls(adapter, off, &ms);
+
+	if (ADDR_IN_RANGE(off, QLCNIC_ADDR_OCM0, QLCNIC_ADDR_OCM0_MAX))
+		return qlcnic_pci_mem_access_direct(adapter, ms.ocm_window,
+			ms.off, &data, 1);
+
+	off8 = off & ~0xf;
+
+	mutex_lock(&adapter->ahw->mem_lock);
+
+	qlcnic_ind_wr(adapter, ms.low, off8);
+	qlcnic_ind_wr(adapter, ms.hi, 0);
+
+	qlcnic_ind_wr(adapter, ms.control, TA_CTL_ENABLE);
+	qlcnic_ind_wr(adapter, ms.control, QLC_TA_START_ENABLE);
+
+	for (j = 0; j < MAX_CTL_CHECK; j++) {
+		temp = qlcnic_ind_rd(adapter, ms.control);
+		if ((temp & TA_CTL_BUSY) == 0)
+			break;
+	}
+
+	if (j >= MAX_CTL_CHECK) {
+		ret = -EIO;
+		goto done;
+	}
+
+	/* This is the modify part of read-modify-write */
+	qlcnic_ind_wr(adapter, ms.wd[0], qlcnic_ind_rd(adapter, ms.rd[0]));
+	qlcnic_ind_wr(adapter, ms.wd[1], qlcnic_ind_rd(adapter, ms.rd[1]));
+	/* This is the write part of read-modify-write */
+	qlcnic_ind_wr(adapter, ms.wd[2], data & 0xffffffff);
+	qlcnic_ind_wr(adapter, ms.wd[3], (data >> 32) & 0xffffffff);
+
+	qlcnic_ind_wr(adapter, ms.control, QLC_TA_WRITE_ENABLE);
+	qlcnic_ind_wr(adapter, ms.control, QLC_TA_WRITE_START);
+
+	for (j = 0; j < MAX_CTL_CHECK; j++) {
+		temp = qlcnic_ind_rd(adapter, ms.control);
+		if ((temp & TA_CTL_BUSY) == 0)
+			break;
+	}
+
+	if (j >= MAX_CTL_CHECK) {
+		printk_ratelimited(KERN_WARNING
+				"failed to write through agent\n");
+		ret = -EIO;
+	} else
+		ret = 0;
+
+done:
+	mutex_unlock(&adapter->ahw->mem_lock);
+
+	return ret;
+}
+
+int
+qlcnic_pci_mem_read_2M(struct qlcnic_adapter *adapter,
+		u64 off, u64 *data)
+{
+	int j, ret;
+	u32 temp, off8;
+	u64 val;
+	struct qlcnic_ms_reg_ctrl ms;
+
+	/* Only 64-bit aligned access */
+	if (off & 7)
+		return -EIO;
+	if (!((ADDR_IN_RANGE(off, QLCNIC_ADDR_QDR_NET,
+		QLCNIC_ADDR_QDR_NET_MAX)) ||
+			(ADDR_IN_RANGE(off, QLCNIC_ADDR_DDR_NET,
+				QLCNIC_ADDR_DDR_NET_MAX))))
+		return -EIO ;
+
+	memset(&ms, 0, sizeof(struct qlcnic_ms_reg_ctrl));
+	qlcnic_set_ms_controls(adapter, off, &ms);
+
+	if (ADDR_IN_RANGE(off, QLCNIC_ADDR_OCM0, QLCNIC_ADDR_OCM0_MAX))
+		return qlcnic_pci_mem_access_direct(adapter, ms.ocm_window,
+			ms.off, data, 0);
+
+	mutex_lock(&adapter->ahw->mem_lock);
+
+	off8 = off & ~0xf;
+
+	qlcnic_ind_wr(adapter, ms.low, off8);
+	qlcnic_ind_wr(adapter, ms.hi, 0);
+
+	qlcnic_ind_wr(adapter, ms.control, TA_CTL_ENABLE);
+	qlcnic_ind_wr(adapter, ms.control, QLC_TA_START_ENABLE);
+
+	for (j = 0; j < MAX_CTL_CHECK; j++) {
+		temp = qlcnic_ind_rd(adapter, ms.control);
+		if ((temp & TA_CTL_BUSY) == 0)
+			break;
+	}
+
+	if (j >= MAX_CTL_CHECK) {
+		printk_ratelimited(KERN_WARNING
+				"failed to read through agent\n");
+		ret = -EIO;
+	} else {
+
+		temp = qlcnic_ind_rd(adapter, ms.rd[3]);
+		val = (u64)temp << 32;
+		val |= qlcnic_ind_rd(adapter, ms.rd[2]);
+		*data = val;
+		ret = 0;
+	}
+
+	mutex_unlock(&adapter->ahw->mem_lock);
+
+	return ret;
+}
+
+int qlcnic_get_board_info(struct qlcnic_adapter *adapter)
+{
+	int offset, board_type, magic, err;
+	struct pci_dev *pdev = adapter->pdev;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+
+	offset = QLCNIC_FW_MAGIC_OFFSET;
+	if (qlcnic_rom_fast_read(adapter, offset, &magic))
+		return -EIO;
+
+	if (magic != QLCNIC_BDINFO_MAGIC) {
+		dev_err(&pdev->dev, "invalid board config, magic=%08x\n",
+			magic);
+		return -EIO;
+	}
+
+	offset = QLCNIC_BRDTYPE_OFFSET;
+	if (qlcnic_rom_fast_read(adapter, offset, &board_type))
+		return -EIO;
+
+	ahw->board_type = board_type;
+
+	if (board_type == QLCNIC_BRDTYPE_P3P_4_GB_MM) {
+		u32 gpio = QLCRD32(adapter, QLCNIC_ROMUSB_GLB_PAD_GPIO_I, &err);
+		if ((gpio & 0x8000) == 0)
+			board_type = QLCNIC_BRDTYPE_P3P_10G_TP;
+	}
+
+	switch (board_type) {
+	case QLCNIC_BRDTYPE_P3P_HMEZ:
+	case QLCNIC_BRDTYPE_P3P_XG_LOM:
+	case QLCNIC_BRDTYPE_P3P_10G_CX4:
+	case QLCNIC_BRDTYPE_P3P_10G_CX4_LP:
+	case QLCNIC_BRDTYPE_P3P_IMEZ:
+	case QLCNIC_BRDTYPE_P3P_10G_SFP_PLUS:
+	case QLCNIC_BRDTYPE_P3P_10G_SFP_CT:
+	case QLCNIC_BRDTYPE_P3P_10G_SFP_QT:
+	case QLCNIC_BRDTYPE_P3P_10G_XFP:
+	case QLCNIC_BRDTYPE_P3P_10000_BASE_T:
+		ahw->port_type = QLCNIC_XGBE;
+		break;
+	case QLCNIC_BRDTYPE_P3P_REF_QG:
+	case QLCNIC_BRDTYPE_P3P_4_GB:
+	case QLCNIC_BRDTYPE_P3P_4_GB_MM:
+		ahw->port_type = QLCNIC_GBE;
+		break;
+	case QLCNIC_BRDTYPE_P3P_10G_TP:
+		ahw->port_type = (adapter->portnum < 2) ?
+			QLCNIC_XGBE : QLCNIC_GBE;
+		break;
+	default:
+		dev_err(&pdev->dev, "unknown board type %x\n", board_type);
+		ahw->port_type = QLCNIC_XGBE;
+		break;
+	}
+
+	return 0;
+}
+
+int
+qlcnic_wol_supported(struct qlcnic_adapter *adapter)
+{
+	int err;
+	u32 wol_cfg;
+
+	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG_NV, &err);
+	if (wol_cfg & (1UL << adapter->portnum)) {
+		wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG, &err);
+		if (wol_cfg & (1 << adapter->portnum))
+			return 1;
+	}
+
+	return 0;
+}
+
+int qlcnic_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate)
+{
+	struct qlcnic_nic_req   req;
+	int rv;
+	u64 word;
+
+	memset(&req, 0, sizeof(struct qlcnic_nic_req));
+	req.qhdr = cpu_to_le64(QLCNIC_HOST_REQUEST << 23);
+
+	word = QLCNIC_H2C_OPCODE_CONFIG_LED | ((u64)adapter->portnum << 16);
+	req.req_hdr = cpu_to_le64(word);
+
+	req.words[0] = cpu_to_le64((u64)rate << 32);
+	req.words[1] = cpu_to_le64(state);
+
+	rv = qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
+	if (rv)
+		dev_err(&adapter->pdev->dev, "LED configuration failed.\n");
+
+	return rv;
+}
+
+void qlcnic_get_func_no(struct qlcnic_adapter *adapter)
+{
+	void __iomem *msix_base_addr;
+	u32 func;
+	u32 msix_base;
+
+	pci_read_config_dword(adapter->pdev, QLCNIC_MSIX_TABLE_OFFSET, &func);
+	msix_base_addr = adapter->ahw->pci_base0 + QLCNIC_MSIX_BASE;
+	msix_base = readl(msix_base_addr);
+	func = (func - msix_base)/QLCNIC_MSIX_TBL_PGSIZE;
+	adapter->ahw->pci_func = func;
+}
+
+void qlcnic_get_ocm_win(struct qlcnic_hardware_context *ahw)
+{
+	ahw->ocm_win_crb = qlcnic_get_ioaddr(ahw, QLCNIC_PCIX_PS_REG(
+				PCIX_OCM_WINDOW_REG(ahw->pci_func)));
+}
+
+void qlcnic_read_crb(struct qlcnic_adapter *adapter, char *buf,
+	loff_t offset, size_t size)
+{
+	int err;
+	u32 data;
+	u64 qmdata;
+
+	if (ADDR_IN_RANGE(offset, QLCNIC_PCI_CAMQM, QLCNIC_PCI_CAMQM_END)) {
+		qlcnic_pci_camqm_read_2M(adapter, offset, &qmdata);
+		memcpy(buf, &qmdata, size);
+	} else {
+		data = QLCRD32(adapter, offset, &err);
+		memcpy(buf, &data, size);
+	}
+}
+
+void qlcnic_write_crb(struct qlcnic_adapter *adapter, char *buf,
+	loff_t offset, size_t size)
+{
+	u32 data;
+	u64 qmdata;
+
+	if (ADDR_IN_RANGE(offset, QLCNIC_PCI_CAMQM, QLCNIC_PCI_CAMQM_END)) {
+		memcpy(&qmdata, buf, size);
+		qlcnic_pci_camqm_write_2M(adapter, offset, qmdata);
+	} else {
+		memcpy(&data, buf, size);
+		QLCWR32(adapter, offset, data);
+	}
+}
+
+int qlcnic_api_lock(struct qlcnic_adapter *adapter)
+{
+	return qlcnic_pcie_sem_lock(adapter, 5, 0);
+}
+
+void qlcnic_api_unlock(struct qlcnic_adapter *adapter)
+{
+	qlcnic_pcie_sem_unlock(adapter, 5);
+}
+
+void qlcnic_add_sysfs(struct qlcnic_adapter *adapter)
+{
+	qlcnic_create_diag_entries(adapter);
+}
+
+void qlcnic_remove_sysfs(struct qlcnic_adapter *adapter)
+{
+	qlcnic_remove_diag_entries(adapter);
+}
+
+/* Array of FW control command structs with command type and required
+ * number of input and output arguments respectively.
+*/
+static const struct qlcnic_mailbox_metadata qlcnic_mbx_tbl[] = {
+	{ QLCNIC_CMD_CREATE_RX_CTX, 4, 1 },
+	{ QLCNIC_CMD_DESTROY_RX_CTX, 2, 1 },
+	{ QLCNIC_CMD_CREATE_TX_CTX, 4, 1 },
+	{ QLCNIC_CMD_DESTROY_TX_CTX, 2, 1 },
+	{ QLCNIC_CMD_INTRPT_TEST, 4, 1 },
+	{ QLCNIC_CMD_SET_MTU, 4, 1 },
+	{ QLCNIC_CMD_READ_PHY, 4, 2 },
+	{ QLCNIC_CMD_WRITE_PHY, 5, 1 },
+	{ QLCNIC_CMD_READ_HW_REG, 4, 1 },
+	{ QLCNIC_CMD_GET_FLOW_CTL, 4, 2 },
+	{ QLCNIC_CMD_SET_FLOW_CTL, 4, 1 },
+	{ QLCNIC_CMD_READ_MAX_MTU, 4, 2 },
+	{ QLCNIC_CMD_READ_MAX_LRO, 4, 2 },
+	{ QLCNIC_CMD_MAC_ADDRESS, 4, 3 },
+	{ QLCNIC_CMD_GET_PCI_INFO, 4, 1 },
+	{ QLCNIC_CMD_GET_NIC_INFO, 4, 1 },
+	{ QLCNIC_CMD_SET_NIC_INFO, 4, 1 },
+	{ QLCNIC_CMD_GET_ESWITCH_CAPABILITY, 4, 3 },
+	{ QLCNIC_CMD_TOGGLE_ESWITCH, 4, 1 },
+	{ QLCNIC_CMD_GET_ESWITCH_STATUS, 4, 3 },
+	{ QLCNIC_CMD_SET_PORTMIRRORING, 4, 1 },
+	{ QLCNIC_CMD_CONFIGURE_ESWITCH, 4, 1 },
+	{ QLCNIC_CMD_GET_MAC_STATS, 4, 1 },
+	{ QLCNIC_CMD_GET_ESWITCH_PORT_CONFIG, 4, 3 },
+	{ QLCNIC_CMD_GET_ESWITCH_STATS, 5, 1 },
+	{ QLCNIC_CMD_CONFIG_PORT, 4, 1 },
+	{ QLCNIC_CMD_TEMP_SIZE, 4, 4 },
+	{ QLCNIC_CMD_GET_TEMP_HDR, 4, 1 },
+	{ QLCNIC_CMD_SET_DRV_VER, 4, 1 },
+};
+
+/* Allocate mailbox incoming and outgoing registers. It should be used with a
+ * follow up call to qlcnic_free_mbx_args
+ */
+int qlcnic_alloc_mbx_args(struct qlcnic_cmd_args *mbx,
+		struct qlcnic_adapter *adapter, u32 type)
+{
+	int i, size;
+	const struct qlcnic_mailbox_metadata *mbx_tbl;
+
+	mbx_tbl = qlcnic_mbx_tbl;
+	size = ARRAY_SIZE(qlcnic_mbx_tbl);
+	for (i = 0; i < size; i++) {
+		if (type == mbx_tbl[i].cmd) {
+			mbx->req.num = mbx_tbl[i].in_args;
+			mbx->rsp.num = mbx_tbl[i].out_args;
+			mbx->req.arg = kcalloc(mbx->req.num,
+				sizeof(u32), GFP_ATOMIC);
+			if (!mbx->req.arg)
+				return -ENOMEM;
+			mbx->rsp.arg = kcalloc(mbx->rsp.num,
+				sizeof(u32), GFP_ATOMIC);
+			if (!mbx->rsp.arg) {
+				kfree(mbx->req.arg);
+				mbx->req.arg = NULL;
+				return -ENOMEM;
+			}
+			memset(mbx->req.arg, 0, sizeof(u32) * mbx->req.num);
+			memset(mbx->rsp.arg, 0, sizeof(u32) * mbx->rsp.num);
+			mbx->req.arg[0] = type;
+			break;
+		}
+	}
+	return 0;
+}
+
+void qlcnic_free_mbx_args(struct qlcnic_cmd_args *cmd)
+{
+	kfree(cmd->req.arg);
+	cmd->req.arg = NULL;
+	kfree(cmd->rsp.arg);
+	cmd->rsp.arg = NULL;
+}
+
+
+static u32
+qlcnic_poll_rsp(struct qlcnic_adapter *adapter)
+{
+	u32 rsp;
+	int err, timeout = 0;
+
+	do {
+		/* give atleast 1ms for firmware to respond */
+		usleep_range(1000, 2000);
+
+		if (++timeout > QLCNIC_OS_CRB_RETRY_COUNT)
+			return QLCNIC_CDRP_RSP_TIMEOUT;
+
+		rsp = QLCRD32(adapter, QLCNIC_CDRP_CRB_OFFSET, &err);
+	} while (!QLCNIC_CDRP_IS_RSP(rsp));
+
+	return rsp;
+}
+
+int
+qlcnic_issue_cmd(struct qlcnic_adapter *adapter, struct qlcnic_cmd_args *cmd)
+{
+	int i, err;
+	u32 rsp;
+	u32 signature;
+	struct pci_dev *pdev = adapter->pdev;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+
+	signature = QLCNIC_CDRP_SIGNATURE_MAKE(ahw);
+
+	/* Acquire semaphore before accessing CRB */
+	if (ahw->hw_ops->api_lock(adapter)) {
+		cmd->rsp.arg[0] = QLCNIC_RCODE_TIMEOUT;
+		return cmd->rsp.arg[0];
+	}
+
+	QLCWR32(adapter, QLCNIC_SIGN_CRB_OFFSET, signature);
+	for (i = 1; i < QLCNIC_CDRP_MAX_ARGS; i++)
+		QLCWR32(adapter, QLCNIC_CDRP_ARG(i), cmd->req.arg[i]);
+	QLCWR32(adapter, QLCNIC_CDRP_CRB_OFFSET,
+		QLCNIC_CDRP_FORM_CMD(cmd->req.arg[0]));
+	rsp = qlcnic_poll_rsp(adapter);
+
+	if (rsp == QLCNIC_CDRP_RSP_TIMEOUT) {
+		dev_err(&pdev->dev, "card response timeout.\n");
+		cmd->rsp.arg[0] = QLCNIC_RCODE_TIMEOUT;
+	} else if (rsp == QLCNIC_CDRP_RSP_FAIL) {
+		cmd->rsp.arg[0] = QLCRD32(adapter, QLCNIC_CDRP_ARG(1), &err);
+		dev_err(&pdev->dev, "failed card response code:0x%x\n",
+				cmd->rsp.arg[0]);
+	} else if (rsp == QLCNIC_CDRP_RSP_OK)
+		cmd->rsp.arg[0] = QLCNIC_RCODE_SUCCESS;
+
+	for (i = 1; i < cmd->rsp.num; i++)
+		cmd->rsp.arg[i] = QLCRD32(adapter, QLCNIC_CDRP_ARG(i), &err);
+
+	/* Release semaphore */
+	ahw->hw_ops->api_unlock(adapter);
+	return cmd->rsp.arg[0];
+}
+
+int
+qlcnic_fw_cmd_set_mtu(struct qlcnic_adapter *adapter, int mtu)
+{
+	int err = 0;
+	struct qlcnic_cmd_args cmd;
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
+
+	if (recv_ctx->state != QLCNIC_HOST_CTX_STATE_ACTIVE)
+		return err;
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+						QLCNIC_CMD_SET_MTU);
+	cmd.req.arg[1] = recv_ctx->context_id;
+	cmd.req.arg[2] = mtu;
+
+	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
+	if (err) {
+		dev_err(&adapter->pdev->dev, "Failed to set mtu\n");
+		err = -EIO;
+	}
+	qlcnic_free_mbx_args(&cmd);
+	return err;
+}
+
+int
+qlcnic_fw_cmd_set_drv_version(struct qlcnic_adapter *adapter)
+{
+	int err = 0;
+	struct qlcnic_cmd_args cmd;
+	char drv_string[12];
+
+	memset(drv_string, 0 , sizeof(drv_string));
+	snprintf(drv_string, sizeof(drv_string), "%d"".""%d"".""%d",
+		_QLCNIC_LINUX_MAJOR, _QLCNIC_LINUX_MINOR,
+			_QLCNIC_LINUX_SUBVERSION);
+
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+						QLCNIC_CMD_SET_DRV_VER);
+	memcpy(&cmd.req.arg[1], drv_string, sizeof(u32));
+	memcpy(&cmd.req.arg[2], drv_string + 4, sizeof(u32));
+	memcpy(&cmd.req.arg[3], drv_string + 8, sizeof(u32));
+
+	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
+	if (err) {
+		dev_err(&adapter->pdev->dev, "Failed to drv ver in fw\n");
+		err = -EIO;
+	}
+	qlcnic_free_mbx_args(&cmd);
+	return err;
+}
+
+int
+qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
+{
+	void *addr;
+	struct qlcnic_hostrq_rx_ctx *prq;
+	struct qlcnic_cardrsp_rx_ctx *prsp;
+	struct qlcnic_hostrq_rds_ring *prq_rds;
+	struct qlcnic_hostrq_sds_ring *prq_sds;
+	struct qlcnic_cardrsp_rds_ring *prsp_rds;
+	struct qlcnic_cardrsp_sds_ring *prsp_sds;
+	struct qlcnic_host_rds_ring *rds_ring;
+	struct qlcnic_host_sds_ring *sds_ring;
+	struct qlcnic_cmd_args cmd;
+
+	dma_addr_t hostrq_phys_addr, cardrsp_phys_addr;
+	u64 phys_addr;
+
+	u8 i, nrds_rings, nsds_rings;
+	size_t rq_size, rsp_size;
+	u32 cap, reg, val, reg2;
+	int err;
+
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
+
+	nrds_rings = adapter->max_rds_rings;
+	nsds_rings = adapter->max_sds_rings;
+
+	rq_size =
+		SIZEOF_HOSTRQ_RX(struct qlcnic_hostrq_rx_ctx, nrds_rings,
+						nsds_rings);
+	rsp_size =
+		SIZEOF_CARDRSP_RX(struct qlcnic_cardrsp_rx_ctx, nrds_rings,
+						nsds_rings);
+
+	addr = dma_alloc_coherent(&adapter->pdev->dev, rq_size,
+			&hostrq_phys_addr, GFP_KERNEL);
+	if (addr == NULL)
+		return -ENOMEM;
+	prq = addr;
+
+	addr = dma_alloc_coherent(&adapter->pdev->dev, rsp_size,
+			&cardrsp_phys_addr, GFP_KERNEL);
+	if (addr == NULL) {
+		err = -ENOMEM;
+		goto out_free_rq;
+	}
+	prsp = addr;
+
+	prq->host_rsp_dma_addr = cpu_to_le64(cardrsp_phys_addr);
+
+	cap = (QLCNIC_CAP0_LEGACY_CONTEXT | QLCNIC_CAP0_LEGACY_MN
+						| QLCNIC_CAP0_VALIDOFF);
+	cap |= (QLCNIC_CAP0_JUMBO_CONTIGUOUS | QLCNIC_CAP0_LRO_CONTIGUOUS);
+
+	if (adapter->flags & QLCNIC_FW_LRO_MSS_CAP)
+		cap |= QLCNIC_CAP0_LRO_MSS;
+
+	prq->valid_field_offset = offsetof(struct qlcnic_hostrq_rx_ctx,
+							 msix_handler);
+	prq->txrx_sds_binding = nsds_rings - 1;
+
+	prq->capabilities[0] = cpu_to_le32(cap);
+	prq->host_int_crb_mode =
+		cpu_to_le32(QLCNIC_HOST_INT_CRB_MODE_SHARED);
+	prq->host_rds_crb_mode =
+		cpu_to_le32(QLCNIC_HOST_RDS_CRB_MODE_UNIQUE);
+
+	prq->num_rds_rings = cpu_to_le16(nrds_rings);
+	prq->num_sds_rings = cpu_to_le16(nsds_rings);
+	prq->rds_ring_offset = 0;
+
+	val = le32_to_cpu(prq->rds_ring_offset) +
+		(sizeof(struct qlcnic_hostrq_rds_ring) * nrds_rings);
+	prq->sds_ring_offset = cpu_to_le32(val);
+
+	prq_rds = (struct qlcnic_hostrq_rds_ring *)(prq->data +
+			le32_to_cpu(prq->rds_ring_offset));
+
+	for (i = 0; i < nrds_rings; i++) {
+
+		rds_ring = &recv_ctx->rds_rings[i];
+		rds_ring->producer = 0;
+
+		prq_rds[i].host_phys_addr = cpu_to_le64(rds_ring->phys_addr);
+		prq_rds[i].ring_size = cpu_to_le32(rds_ring->num_desc);
+		prq_rds[i].ring_kind = cpu_to_le32(i);
+		prq_rds[i].buff_size = cpu_to_le64(rds_ring->dma_size);
+	}
+
+	prq_sds = (struct qlcnic_hostrq_sds_ring *)(prq->data +
+			le32_to_cpu(prq->sds_ring_offset));
+
+	for (i = 0; i < nsds_rings; i++) {
+
+		sds_ring = &recv_ctx->sds_rings[i];
+		sds_ring->consumer = 0;
+		memset(sds_ring->desc_head, 0, STATUS_DESC_RINGSIZE(sds_ring));
+
+		prq_sds[i].host_phys_addr = cpu_to_le64(sds_ring->phys_addr);
+		prq_sds[i].ring_size = cpu_to_le32(sds_ring->num_desc);
+		prq_sds[i].msi_index = cpu_to_le16(i);
+	}
+
+	phys_addr = hostrq_phys_addr;
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+						QLCNIC_CMD_CREATE_RX_CTX);
+	cmd.req.arg[1] = MSD(phys_addr);
+	cmd.req.arg[2] = LSD(phys_addr);
+	cmd.req.arg[3] = rq_size;
+	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
+	if (err) {
+		dev_err(&adapter->pdev->dev,
+			"Failed to create rx ctx in firmware%d\n", err);
+		goto out_free_rsp;
+	}
+
+	prsp_rds = ((struct qlcnic_cardrsp_rds_ring *)
+			 &prsp->data[le32_to_cpu(prsp->rds_ring_offset)]);
+
+	for (i = 0; i < le16_to_cpu(prsp->num_rds_rings); i++) {
+		rds_ring = &recv_ctx->rds_rings[i];
+
+		reg = le32_to_cpu(prsp_rds[i].host_producer_crb);
+		rds_ring->crb_rcv_producer = adapter->ahw->pci_base0 + reg;
+	}
+
+	prsp_sds = ((struct qlcnic_cardrsp_sds_ring *)
+			&prsp->data[le32_to_cpu(prsp->sds_ring_offset)]);
+
+	for (i = 0; i < le16_to_cpu(prsp->num_sds_rings); i++) {
+		sds_ring = &recv_ctx->sds_rings[i];
+
+		reg = le32_to_cpu(prsp_sds[i].host_consumer_crb);
+		reg2 = le32_to_cpu(prsp_sds[i].interrupt_crb);
+
+		sds_ring->crb_sts_consumer = adapter->ahw->pci_base0 + reg;
+		sds_ring->crb_intr_mask = adapter->ahw->pci_base0 + reg2;
+	}
+
+	recv_ctx->state = le32_to_cpu(prsp->host_ctx_state);
+	recv_ctx->context_id = le16_to_cpu(prsp->context_id);
+	recv_ctx->virt_port = prsp->virt_port;
+
+out_free_rsp:
+	dma_free_coherent(&adapter->pdev->dev, rsp_size, prsp,
+		cardrsp_phys_addr);
+	qlcnic_free_mbx_args(&cmd);
+out_free_rq:
+	dma_free_coherent(&adapter->pdev->dev, rq_size, prq, hostrq_phys_addr);
+	return err;
+}
+
+static void
+qlcnic_fw_cmd_destroy_rx_ctx(struct qlcnic_adapter *adapter)
+{
+	int err;
+	struct qlcnic_cmd_args cmd;
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
+
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+					QLCNIC_CMD_DESTROY_RX_CTX);
+	cmd.req.arg[1] = recv_ctx->context_id;
+	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
+	if (err)
+		dev_err(&adapter->pdev->dev,
+			"Failed to destroy rx ctx in firmware\n");
+
+	recv_ctx->state = QLCNIC_HOST_CTX_STATE_FREED;
+	qlcnic_free_mbx_args(&cmd);
+}
+
+int
+qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter,
+	struct qlcnic_host_tx_ring *tx_ring, int ring)
+{
+	struct qlcnic_hostrq_tx_ctx	*prq;
+	struct qlcnic_hostrq_cds_ring	*prq_cds;
+	struct qlcnic_cardrsp_tx_ctx	*prsp;
+	void	*rq_addr, *rsp_addr;
+	size_t	rq_size, rsp_size;
+	u32	temp;
+	struct qlcnic_cmd_args cmd;
+	int	err;
+	u64	phys_addr;
+	dma_addr_t	rq_phys_addr, rsp_phys_addr;
+
+	/* reset host resources */
+	tx_ring->producer = 0;
+	tx_ring->sw_consumer = 0;
+	*(tx_ring->hw_consumer) = 0;
+
+	rq_size = SIZEOF_HOSTRQ_TX(struct qlcnic_hostrq_tx_ctx);
+	rq_addr = dma_alloc_coherent(&adapter->pdev->dev, rq_size,
+			&rq_phys_addr, GFP_KERNEL);
+	if (!rq_addr)
+		return -ENOMEM;
+
+	rsp_size = SIZEOF_CARDRSP_TX(struct qlcnic_cardrsp_tx_ctx);
+	rsp_addr = dma_alloc_coherent(&adapter->pdev->dev, rsp_size,
+			&rsp_phys_addr, GFP_KERNEL);
+	if (!rsp_addr) {
+		err = -ENOMEM;
+		goto out_free_rq;
+	}
+
+	memset(rq_addr, 0, rq_size);
+	prq = rq_addr;
+
+	memset(rsp_addr, 0, rsp_size);
+	prsp = rsp_addr;
+
+	prq->host_rsp_dma_addr = cpu_to_le64(rsp_phys_addr);
+
+	temp = (QLCNIC_CAP0_LEGACY_CONTEXT | QLCNIC_CAP0_LEGACY_MN |
+					QLCNIC_CAP0_LSO);
+	prq->capabilities[0] = cpu_to_le32(temp);
+
+	prq->host_int_crb_mode =
+		cpu_to_le32(QLCNIC_HOST_INT_CRB_MODE_SHARED);
+	prq->msi_index = 0;
+
+	prq->interrupt_ctl = 0;
+	prq->cmd_cons_dma_addr = cpu_to_le64(tx_ring->hw_cons_phys_addr);
+
+	prq_cds = &prq->cds_ring;
+
+	prq_cds->host_phys_addr = cpu_to_le64(tx_ring->phys_addr);
+	prq_cds->ring_size = cpu_to_le32(tx_ring->num_desc);
+
+	phys_addr = rq_phys_addr;
+
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+					QLCNIC_CMD_CREATE_TX_CTX);
+	cmd.req.arg[1] = MSD(phys_addr);
+	cmd.req.arg[2] = LSD(phys_addr);
+	cmd.req.arg[3] = rq_size;
+	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
+
+	if (err == QLCNIC_RCODE_SUCCESS) {
+		temp = le32_to_cpu(prsp->cds_ring.host_producer_crb);
+		tx_ring->crb_cmd_producer = adapter->ahw->pci_base0 + temp;
+		tx_ring->ctx_id = le16_to_cpu(prsp->context_id);
+	} else {
+		dev_err(&adapter->pdev->dev,
+			"Failed to create tx ctx in firmware%d\n", err);
+		err = -EIO;
+	}
+
+	dma_free_coherent(&adapter->pdev->dev, rsp_size, rsp_addr,
+		rsp_phys_addr);
+
+out_free_rq:
+	dma_free_coherent(&adapter->pdev->dev, rq_size, rq_addr, rq_phys_addr);
+	qlcnic_free_mbx_args(&cmd);
+
+	return err;
+}
+
+static void
+qlcnic_fw_cmd_destroy_tx_ctx(struct qlcnic_adapter *adapter,
+	struct qlcnic_host_tx_ring *tx_ring)
+{
+	struct qlcnic_cmd_args cmd;
+
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+					QLCNIC_CMD_DESTROY_TX_CTX);
+	cmd.req.arg[1] = tx_ring->ctx_id;
+	if (adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd))
+		dev_err(&adapter->pdev->dev,
+			"Failed to destroy tx ctx in firmware\n");
+	qlcnic_free_mbx_args(&cmd);
+}
+
+int
+qlcnic_fw_cmd_set_port(struct qlcnic_adapter *adapter, u32 config)
+{
+	int err;
+	struct qlcnic_cmd_args cmd;
+
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+						QLCNIC_CMD_CONFIG_PORT);
+	cmd.req.arg[1] = config;
+	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
+	qlcnic_free_mbx_args(&cmd);
+	return err;
+}
+
+int qlcnic_alloc_hw_resources(struct qlcnic_adapter *adapter)
+{
+	void *addr;
+	int err, ring;
+	struct qlcnic_recv_context *recv_ctx;
+	struct qlcnic_host_rds_ring *rds_ring;
+	struct qlcnic_host_sds_ring *sds_ring;
+	struct qlcnic_host_tx_ring *tx_ring;
+
+	struct pci_dev *pdev = adapter->pdev;
+
+	recv_ctx = adapter->recv_ctx;
+
+	for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
+		tx_ring = &adapter->tx_ring[ring];
+		tx_ring->hw_consumer = (__le32 *) dma_alloc_coherent(&pdev->dev,
+			sizeof(u32), &tx_ring->hw_cons_phys_addr, GFP_KERNEL);
+		if (tx_ring->hw_consumer == NULL) {
+			dev_err(&pdev->dev, "failed to allocate tx consumer\n");
+			return -ENOMEM;
+		}
+		/* cmd desc ring */
+		addr = dma_alloc_coherent(&pdev->dev, TX_DESC_RINGSIZE(tx_ring),
+			&tx_ring->phys_addr, GFP_KERNEL);
+
+		if (addr == NULL) {
+			dev_err(&pdev->dev,
+				 "failed to allocate tx desc ring\n");
+			err = -ENOMEM;
+			goto err_out_free;
+		}
+
+		tx_ring->desc_head = addr;
+	}
+
+	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
+		rds_ring = &recv_ctx->rds_rings[ring];
+		addr = dma_alloc_coherent(&adapter->pdev->dev,
+				RCV_DESC_RINGSIZE(rds_ring),
+				&rds_ring->phys_addr, GFP_KERNEL);
+		if (addr == NULL) {
+			dev_err(&pdev->dev,
+				"failed to allocate rds ring [%d]\n", ring);
+			err = -ENOMEM;
+			goto err_out_free;
+		}
+		rds_ring->desc_head = addr;
+
+	}
+
+	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+		sds_ring = &recv_ctx->sds_rings[ring];
+
+		addr = dma_alloc_coherent(&adapter->pdev->dev,
+				STATUS_DESC_RINGSIZE(sds_ring),
+				&sds_ring->phys_addr, GFP_KERNEL);
+		if (addr == NULL) {
+			dev_err(&pdev->dev,
+				"failed to allocate sds ring [%d]\n", ring);
+			err = -ENOMEM;
+			goto err_out_free;
+		}
+		sds_ring->desc_head = addr;
+	}
+
+	return 0;
+
+err_out_free:
+	qlcnic_free_hw_resources(adapter);
+	return err;
+}
+
+int qlcnic_fw_create_ctx(struct qlcnic_adapter *adapter)
+{
+	int i, err, ring;
+
+	if (adapter->flags & QLCNIC_NEED_FLR) {
+		pci_reset_function(adapter->pdev);
+		adapter->flags &= ~QLCNIC_NEED_FLR;
+	}
+
+	err = adapter->ahw->hw_ops->create_rx_ctx(adapter);
+	if (err)
+		return err;
+
+	for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
+		err = adapter->ahw->hw_ops->create_tx_ctx(adapter,
+			 &adapter->tx_ring[ring], ring);
+		if (err) {
+			qlcnic_fw_cmd_destroy_rx_ctx(adapter);
+			if (ring == 0)
+				return err;
+			for (i = 0; i < ring; i++)
+				qlcnic_fw_cmd_destroy_tx_ctx(adapter,
+					 &adapter->tx_ring[i]);
+			return err;
+		}
+	}
+
+	set_bit(__QLCNIC_FW_ATTACHED, &adapter->state);
+	return 0;
+}
+
+void qlcnic_fw_destroy_ctx(struct qlcnic_adapter *adapter)
+{
+	int ring;
+
+	if (test_and_clear_bit(__QLCNIC_FW_ATTACHED, &adapter->state)) {
+		qlcnic_fw_cmd_destroy_rx_ctx(adapter);
+		for (ring = 0; ring < adapter->max_drv_tx_rings; ring++)
+			qlcnic_fw_cmd_destroy_tx_ctx(adapter,
+					&adapter->tx_ring[ring]);
+
+		/* Allow dma queues to drain after context reset */
+		msleep(20);
+	}
+}
+
+void qlcnic_free_hw_resources(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_recv_context *recv_ctx;
+	struct qlcnic_host_rds_ring *rds_ring;
+	struct qlcnic_host_sds_ring *sds_ring;
+	struct qlcnic_host_tx_ring *tx_ring;
+	int ring;
+
+	recv_ctx = adapter->recv_ctx;
+
+	for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
+		tx_ring = &adapter->tx_ring[ring];
+		if (tx_ring->hw_consumer != NULL) {
+			dma_free_coherent(&adapter->pdev->dev,
+					sizeof(u32),
+					tx_ring->hw_consumer,
+					tx_ring->hw_cons_phys_addr);
+			tx_ring->hw_consumer = NULL;
+		}
+
+		if (tx_ring->desc_head != NULL) {
+			dma_free_coherent(&adapter->pdev->dev,
+					TX_DESC_RINGSIZE(tx_ring),
+					tx_ring->desc_head, tx_ring->phys_addr);
+			tx_ring->desc_head = NULL;
+		}
+	}
+
+	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
+		rds_ring = &recv_ctx->rds_rings[ring];
+
+		if (rds_ring->desc_head != NULL) {
+			dma_free_coherent(&adapter->pdev->dev,
+					RCV_DESC_RINGSIZE(rds_ring),
+					rds_ring->desc_head,
+					rds_ring->phys_addr);
+			rds_ring->desc_head = NULL;
+		}
+	}
+
+	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+		sds_ring = &recv_ctx->sds_rings[ring];
+
+		if (sds_ring->desc_head != NULL) {
+			dma_free_coherent(&adapter->pdev->dev,
+				STATUS_DESC_RINGSIZE(sds_ring),
+				sds_ring->desc_head,
+				sds_ring->phys_addr);
+			sds_ring->desc_head = NULL;
+		}
+	}
+}
+
+/* Get MAC address of a NIC partition */
+int qlcnic_get_mac_address(struct qlcnic_adapter *adapter, u8 *mac)
+{
+	int err, i;
+	struct qlcnic_cmd_args cmd;
+	u32 mac_low, mac_high;
+
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+						QLCNIC_CMD_MAC_ADDRESS);
+	cmd.req.arg[1] = adapter->ahw->pci_func | BIT_8;
+	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
+
+	if (err == QLCNIC_RCODE_SUCCESS) {
+		mac_low = cmd.rsp.arg[1];
+		mac_high = cmd.rsp.arg[2];
+
+		for (i = 0; i < 2; i++)
+			mac[i] = (u8) (mac_high >> ((1 - i) * 8));
+		for (i = 2; i < 6; i++)
+			mac[i] = (u8) (mac_low >> ((5 - i) * 8));
+	} else {
+		dev_err(&adapter->pdev->dev,
+			"Failed to get mac address%d\n", err);
+		err = -EIO;
+	}
+	qlcnic_free_mbx_args(&cmd);
+	return err;
+}
+
+int qlcnic_get_nic_info(struct qlcnic_adapter *adapter,
+				struct qlcnic_info *npar_info, u8 func_id)
+{
+	int	err;
+	dma_addr_t nic_dma_t;
+	const struct qlcnic_info *nic_info;
+	void *nic_info_addr;
+	struct qlcnic_cmd_args cmd;
+	size_t	nic_size = sizeof(struct qlcnic_info);
+
+	nic_info_addr = dma_alloc_coherent(&adapter->pdev->dev, nic_size,
+				&nic_dma_t, GFP_KERNEL);
+	if (!nic_info_addr)
+		return -ENOMEM;
+	memset(nic_info_addr, 0, nic_size);
+
+	nic_info = nic_info_addr;
+
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+					QLCNIC_CMD_GET_NIC_INFO);
+	cmd.req.arg[1] = MSD(nic_dma_t);
+	cmd.req.arg[2] = LSD(nic_dma_t);
+	cmd.req.arg[3] = (func_id << 16 | nic_size);
+	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
+	if (err == QLCNIC_RCODE_SUCCESS)
+		qlcnic_set_npar_data(adapter, nic_info, npar_info);
+	else {
+		dev_err(&adapter->pdev->dev,
+			"Failed to get nic info%d\n", err);
+		err = -EIO;
+	}
+
+	dma_free_coherent(&adapter->pdev->dev, nic_size, nic_info_addr,
+		nic_dma_t);
+	qlcnic_free_mbx_args(&cmd);
+
+	return err;
+}
+
+int qlcnic_set_nic_info(struct qlcnic_adapter *adapter, struct qlcnic_info *nic)
+{
+	int err = -EIO;
+	dma_addr_t nic_dma_t;
+	void *nic_info_addr;
+	struct qlcnic_cmd_args cmd;
+	struct qlcnic_info *nic_info;
+	size_t nic_size = sizeof(struct qlcnic_info);
+
+	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
+		return err;
+
+	nic_info_addr = dma_alloc_coherent(&adapter->pdev->dev, nic_size,
+			&nic_dma_t, GFP_KERNEL);
+	if (!nic_info_addr)
+		return -ENOMEM;
+
+	memset(nic_info_addr, 0, nic_size);
+	nic_info = nic_info_addr;
+
+	nic_info->pci_func = cpu_to_le16(nic->pci_func);
+	nic_info->op_mode = cpu_to_le16(nic->op_mode);
+	nic_info->phys_port = cpu_to_le16(nic->phys_port);
+	nic_info->switch_mode = cpu_to_le16(nic->switch_mode);
+	nic_info->capabilities = cpu_to_le32(nic->capabilities);
+	nic_info->max_mac_filters = nic->max_mac_filters;
+	nic_info->max_tx_ques = cpu_to_le16(nic->max_tx_ques);
+	nic_info->max_rx_ques = cpu_to_le16(nic->max_rx_ques);
+	nic_info->min_tx_bw = cpu_to_le16(nic->min_tx_bw);
+	nic_info->max_tx_bw = cpu_to_le16(nic->max_tx_bw);
+
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+						QLCNIC_CMD_SET_NIC_INFO);
+	cmd.req.arg[1] = MSD(nic_dma_t);
+	cmd.req.arg[2] = LSD(nic_dma_t);
+	cmd.req.arg[3] = ((nic->pci_func << 16) | nic_size);
+	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
+
+	if (err != QLCNIC_RCODE_SUCCESS) {
+		dev_err(&adapter->pdev->dev,
+			"Failed to set nic info%d\n", err);
+		err = -EIO;
+	}
+
+	dma_free_coherent(&adapter->pdev->dev, nic_size, nic_info_addr,
+		nic_dma_t);
+	qlcnic_free_mbx_args(&cmd);
+
+	return err;
+}
+
+int qlcnic_get_pci_info(struct qlcnic_adapter *adapter,
+				struct qlcnic_pci_info *pci_info)
+{
+	int err = 0, i;
+	struct qlcnic_cmd_args cmd;
+	dma_addr_t pci_info_dma_t;
+	struct qlcnic_pci_info *npar;
+	void *pci_info_addr;
+	size_t npar_size = sizeof(struct qlcnic_pci_info);
+	size_t pci_size = npar_size * QLCNIC_MAX_PCI_FUNC;
+
+	pci_info_addr = dma_alloc_coherent(&adapter->pdev->dev, pci_size,
+			&pci_info_dma_t, GFP_KERNEL);
+	if (!pci_info_addr)
+		return -ENOMEM;
+	memset(pci_info_addr, 0, pci_size);
+
+	npar = pci_info_addr;
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+						QLCNIC_CMD_GET_PCI_INFO);
+	cmd.req.arg[1] = MSD(pci_info_dma_t);
+	cmd.req.arg[2] = LSD(pci_info_dma_t);
+	cmd.req.arg[3] = pci_size;
+	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
+
+	adapter->ahw->act_pci_func = 0;
+	if (err == QLCNIC_RCODE_SUCCESS) {
+		for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++, npar++, pci_info++) {
+			pci_info->id = le16_to_cpu(npar->id);
+			pci_info->active = le16_to_cpu(npar->active);
+			pci_info->type = le16_to_cpu(npar->type);
+			if (pci_info->type == QLCNIC_TYPE_NIC)
+				adapter->ahw->act_pci_func++;
+			pci_info->default_port =
+				le16_to_cpu(npar->default_port);
+			pci_info->tx_min_bw =
+				le16_to_cpu(npar->tx_min_bw);
+			pci_info->tx_max_bw =
+				le16_to_cpu(npar->tx_max_bw);
+			memcpy(pci_info->mac, npar->mac, ETH_ALEN);
+		}
+	} else {
+		dev_err(&adapter->pdev->dev,
+			"Failed to get PCI Info%d\n", err);
+		err = -EIO;
+	}
+
+	dma_free_coherent(&adapter->pdev->dev, pci_size, pci_info_addr,
+		pci_info_dma_t);
+	qlcnic_free_mbx_args(&cmd);
+
+	return err;
+}
+
+int qlcnic_config_port_mirroring(struct qlcnic_adapter *adapter, u8 id,
+				u8 enable_mirroring, u8 pci_func)
+{
+	int err = -EIO;
+	u32 arg1;
+	struct qlcnic_cmd_args cmd;
+
+	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC ||
+		!(adapter->eswitch[id].flags & QLCNIC_SWITCH_ENABLE))
+		return err;
+
+	arg1 = id | (enable_mirroring ? BIT_4 : 0);
+	arg1 |= pci_func << 8;
+
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+					QLCNIC_CMD_SET_PORTMIRRORING);
+	cmd.req.arg[1] = arg1;
+	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
+
+	if (err != QLCNIC_RCODE_SUCCESS)
+		dev_err(&adapter->pdev->dev,
+			"Failed to configure port mirroring%d on eswitch:%d\n",
+			pci_func, id);
+	else
+		dev_info(&adapter->pdev->dev,
+			"Configured eSwitch %d for port mirroring:%d\n",
+			id, pci_func);
+	qlcnic_free_mbx_args(&cmd);
+
+	return err;
+}
+
+int qlcnic_get_port_stats(struct qlcnic_adapter *adapter, const u8 func,
+		const u8 rx_tx, struct __qlcnic_esw_statistics *esw_stats) {
+
+	size_t stats_size = sizeof(struct __qlcnic_esw_statistics);
+	struct __qlcnic_esw_statistics *stats;
+	dma_addr_t stats_dma_t;
+	void *stats_addr;
+	u32 arg1;
+	struct qlcnic_cmd_args cmd;
+	int err;
+
+	if (esw_stats == NULL)
+		return -ENOMEM;
+
+	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC &&
+		func != adapter->ahw->pci_func) {
+		dev_err(&adapter->pdev->dev,
+			"Not privilege to query stats for func=%d", func);
+		return -EIO;
+	}
+
+	stats_addr = dma_alloc_coherent(&adapter->pdev->dev, stats_size,
+			&stats_dma_t, GFP_KERNEL);
+	if (!stats_addr) {
+		dev_err(&adapter->pdev->dev, "Unable to allocate memory\n");
+		return -ENOMEM;
+	}
+	memset(stats_addr, 0, stats_size);
+
+	arg1 = func | QLCNIC_STATS_VERSION << 8 | QLCNIC_STATS_PORT << 12;
+	arg1 |= rx_tx << 15 | stats_size << 16;
+
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+					QLCNIC_CMD_GET_ESWITCH_STATS);
+	cmd.req.arg[1] = arg1;
+	cmd.req.arg[2] = MSD(stats_dma_t);
+	cmd.req.arg[3] = LSD(stats_dma_t);
+	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
+
+	if (!err) {
+		stats = stats_addr;
+		esw_stats->context_id = le16_to_cpu(stats->context_id);
+		esw_stats->version = le16_to_cpu(stats->version);
+		esw_stats->size = le16_to_cpu(stats->size);
+		esw_stats->multicast_frames =
+				le64_to_cpu(stats->multicast_frames);
+		esw_stats->broadcast_frames =
+				le64_to_cpu(stats->broadcast_frames);
+		esw_stats->unicast_frames = le64_to_cpu(stats->unicast_frames);
+		esw_stats->dropped_frames = le64_to_cpu(stats->dropped_frames);
+		esw_stats->local_frames = le64_to_cpu(stats->local_frames);
+		esw_stats->errors = le64_to_cpu(stats->errors);
+		esw_stats->numbytes = le64_to_cpu(stats->numbytes);
+	}
+
+	dma_free_coherent(&adapter->pdev->dev, stats_size, stats_addr,
+		stats_dma_t);
+	qlcnic_free_mbx_args(&cmd);
+
+	return err;
+}
+
+int qlcnic_get_mac_stats(struct qlcnic_adapter *adapter,
+		struct qlcnic_mac_statistics *mac_stats)
+{
+	struct qlcnic_mac_statistics *stats;
+	struct qlcnic_cmd_args cmd;
+	size_t stats_size = sizeof(struct qlcnic_mac_statistics);
+	dma_addr_t stats_dma_t;
+	void *stats_addr;
+	int err;
+
+	if (mac_stats == NULL)
+		return -ENOMEM;
+
+	stats_addr = dma_alloc_coherent(&adapter->pdev->dev, stats_size,
+			&stats_dma_t, GFP_KERNEL);
+	if (!stats_addr) {
+		dev_err(&adapter->pdev->dev,
+			"%s: Unable to allocate memory.\n", __func__);
+		return -ENOMEM;
+	}
+	memset(stats_addr, 0, stats_size);
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+					QLCNIC_CMD_GET_MAC_STATS);
+	cmd.req.arg[1] = stats_size << 16;
+	cmd.req.arg[2] = MSD(stats_dma_t);
+	cmd.req.arg[3] = LSD(stats_dma_t);
+	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
+	if (!err) {
+		stats = stats_addr;
+		mac_stats->mac_tx_frames = le64_to_cpu(stats->mac_tx_frames);
+		mac_stats->mac_tx_bytes = le64_to_cpu(stats->mac_tx_bytes);
+		mac_stats->mac_tx_mcast_pkts =
+					le64_to_cpu(stats->mac_tx_mcast_pkts);
+		mac_stats->mac_tx_bcast_pkts =
+					le64_to_cpu(stats->mac_tx_bcast_pkts);
+		mac_stats->mac_rx_frames = le64_to_cpu(stats->mac_rx_frames);
+		mac_stats->mac_rx_bytes = le64_to_cpu(stats->mac_rx_bytes);
+		mac_stats->mac_rx_mcast_pkts =
+					le64_to_cpu(stats->mac_rx_mcast_pkts);
+		mac_stats->mac_rx_length_error =
+				le64_to_cpu(stats->mac_rx_length_error);
+		mac_stats->mac_rx_length_small =
+				le64_to_cpu(stats->mac_rx_length_small);
+		mac_stats->mac_rx_length_large =
+				le64_to_cpu(stats->mac_rx_length_large);
+		mac_stats->mac_rx_jabber = le64_to_cpu(stats->mac_rx_jabber);
+		mac_stats->mac_rx_dropped = le64_to_cpu(stats->mac_rx_dropped);
+		mac_stats->mac_FCS_error = le64_to_cpu(stats->mac_FCS_error);
+	}
+
+	dma_free_coherent(&adapter->pdev->dev, stats_size, stats_addr,
+		stats_dma_t);
+	qlcnic_free_mbx_args(&cmd);
+	return err;
+}
+
+int qlcnic_get_eswitch_stats(struct qlcnic_adapter *adapter, const u8 eswitch,
+		const u8 rx_tx, struct __qlcnic_esw_statistics *esw_stats) {
+
+	struct __qlcnic_esw_statistics port_stats;
+	u8 i;
+	int ret = -EIO;
+
+	if (esw_stats == NULL)
+		return -ENOMEM;
+	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
+		return -EIO;
+	if (adapter->npars == NULL)
+		return -EIO;
+
+	memset(esw_stats, 0, sizeof(u64));
+	esw_stats->unicast_frames = QLCNIC_STATS_NOT_AVAIL;
+	esw_stats->multicast_frames = QLCNIC_STATS_NOT_AVAIL;
+	esw_stats->broadcast_frames = QLCNIC_STATS_NOT_AVAIL;
+	esw_stats->dropped_frames = QLCNIC_STATS_NOT_AVAIL;
+	esw_stats->errors = QLCNIC_STATS_NOT_AVAIL;
+	esw_stats->local_frames = QLCNIC_STATS_NOT_AVAIL;
+	esw_stats->numbytes = QLCNIC_STATS_NOT_AVAIL;
+	esw_stats->context_id = eswitch;
+
+	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
+		if (adapter->npars[i].phy_port != eswitch)
+			continue;
+
+		memset(&port_stats, 0, sizeof(struct __qlcnic_esw_statistics));
+		if (qlcnic_get_port_stats(adapter, i, rx_tx, &port_stats))
+			continue;
+
+		esw_stats->size = port_stats.size;
+		esw_stats->version = port_stats.version;
+		QLCNIC_ADD_ESW_STATS(esw_stats->unicast_frames,
+						port_stats.unicast_frames);
+		QLCNIC_ADD_ESW_STATS(esw_stats->multicast_frames,
+						port_stats.multicast_frames);
+		QLCNIC_ADD_ESW_STATS(esw_stats->broadcast_frames,
+						port_stats.broadcast_frames);
+		QLCNIC_ADD_ESW_STATS(esw_stats->dropped_frames,
+						port_stats.dropped_frames);
+		QLCNIC_ADD_ESW_STATS(esw_stats->errors,
+						port_stats.errors);
+		QLCNIC_ADD_ESW_STATS(esw_stats->local_frames,
+						port_stats.local_frames);
+		QLCNIC_ADD_ESW_STATS(esw_stats->numbytes,
+						port_stats.numbytes);
+		ret = 0;
+	}
+	return ret;
+}
+
+int qlcnic_clear_esw_stats(struct qlcnic_adapter *adapter, const u8 func_esw,
+		const u8 port, const u8 rx_tx)
+{
+	int err;
+	u32 arg1;
+	struct qlcnic_cmd_args cmd;
+
+	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
+		return -EIO;
+
+	if (func_esw == QLCNIC_STATS_PORT) {
+		if (port >= QLCNIC_MAX_PCI_FUNC)
+			goto err_ret;
+	} else if (func_esw == QLCNIC_STATS_ESWITCH) {
+		if (port >= QLCNIC_NIU_MAX_XG_PORTS)
+			goto err_ret;
+	} else {
+		goto err_ret;
+	}
+
+	if (rx_tx > QLCNIC_QUERY_TX_COUNTER)
+		goto err_ret;
+
+	arg1 = port | QLCNIC_STATS_VERSION << 8 | func_esw << 12;
+	arg1 |= BIT_14 | rx_tx << 15;
+
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+					QLCNIC_CMD_GET_ESWITCH_STATS);
+	cmd.req.arg[1] = arg1;
+	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
+	qlcnic_free_mbx_args(&cmd);
+	return err;
+
+err_ret:
+	dev_err(&adapter->pdev->dev,
+		"Invalid arguments func_esw=%d port=%d rx_ctx=%d\n",
+						func_esw, port, rx_tx);
+	return -EIO;
+}
+
+static int
+__qlcnic_get_eswitch_port_config(struct qlcnic_adapter *adapter,
+					u32 *arg1, u32 *arg2)
+{
+	int err = -EIO;
+	struct qlcnic_cmd_args cmd;
+	u8 pci_func;
+	pci_func = (*arg1 >> 8);
+
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+		QLCNIC_CMD_GET_ESWITCH_PORT_CONFIG);
+	cmd.req.arg[1] = *arg1;
+	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
+	*arg1 = cmd.rsp.arg[1];
+	*arg2 = cmd.rsp.arg[2];
+	qlcnic_free_mbx_args(&cmd);
+
+	if (err == QLCNIC_RCODE_SUCCESS)
+		dev_info(&adapter->pdev->dev,
+			"eSwitch port config for pci func %d\n", pci_func);
+	else
+		dev_err(&adapter->pdev->dev,
+			"Failed to get eswitch port config for pci func %d\n",
+								pci_func);
+	return err;
+}
+
+int qlcnic_config_switch_port(struct qlcnic_adapter *adapter,
+		struct qlcnic_esw_func_cfg *esw_cfg)
+{
+	int err = -EIO;
+	u32 arg1, arg2 = 0;
+	struct qlcnic_cmd_args cmd;
+	u8 pci_func;
+
+	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
+		return err;
+	pci_func = esw_cfg->pci_func;
+	arg1 = (adapter->npars[pci_func].phy_port & BIT_0);
+	arg1 |= (pci_func << 8);
+
+	if (__qlcnic_get_eswitch_port_config(adapter, &arg1, &arg2))
+		return err;
+	arg1 &= ~(0x0ff << 8);
+	arg1 |= (pci_func << 8);
+	arg1 &= ~(BIT_2 | BIT_3);
+	switch (esw_cfg->op_mode) {
+	case QLCNIC_PORT_DEFAULTS:
+		arg1 |= (BIT_4 | BIT_6 | BIT_7);
+		arg2 |= (BIT_0 | BIT_1);
+		if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_TSO)
+			arg2 |= (BIT_2 | BIT_3);
+		if (!(esw_cfg->discard_tagged))
+			arg1 &= ~BIT_4;
+		if (!(esw_cfg->promisc_mode))
+			arg1 &= ~BIT_6;
+		if (!(esw_cfg->mac_override))
+			arg1 &= ~BIT_7;
+		if (!(esw_cfg->mac_anti_spoof))
+			arg2 &= ~BIT_0;
+		if (!(esw_cfg->offload_flags & BIT_0))
+			arg2 &= ~(BIT_1 | BIT_2 | BIT_3);
+		if (!(esw_cfg->offload_flags & BIT_1))
+			arg2 &= ~BIT_2;
+		if (!(esw_cfg->offload_flags & BIT_2))
+			arg2 &= ~BIT_3;
+		break;
+	case QLCNIC_ADD_VLAN:
+			arg1 |= (BIT_2 | BIT_5);
+			arg1 |= (esw_cfg->vlan_id << 16);
+			break;
+	case QLCNIC_DEL_VLAN:
+			arg1 |= (BIT_3 | BIT_5);
+			arg1 &= ~(0x0ffff << 16);
+			break;
+	default:
+		return err;
+	}
+
+	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
+					QLCNIC_CMD_CONFIGURE_ESWITCH);
+	cmd.req.arg[1] = arg1;
+	cmd.req.arg[2] = arg2;
+	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
+	qlcnic_free_mbx_args(&cmd);
+
+	if (err != QLCNIC_RCODE_SUCCESS)
+		dev_err(&adapter->pdev->dev,
+			"Failed to configure eswitch pci func %d\n", pci_func);
+	else
+		dev_info(&adapter->pdev->dev,
+			"Configured eSwitch for pci func %d\n", pci_func);
+
+	return err;
+}
+
+int
+qlcnic_get_eswitch_port_config(struct qlcnic_adapter *adapter,
+			struct qlcnic_esw_func_cfg *esw_cfg)
+{
+	u32 arg1, arg2;
+	u8 phy_port;
+	if (adapter->ahw->op_mode == QLCNIC_MGMT_FUNC)
+		phy_port = adapter->npars[esw_cfg->pci_func].phy_port;
+	else
+		phy_port = adapter->ahw->physical_port;
+	arg1 = phy_port;
+	arg1 |= (esw_cfg->pci_func << 8);
+	if (__qlcnic_get_eswitch_port_config(adapter, &arg1, &arg2))
+		return -EIO;
+
+	esw_cfg->discard_tagged = !!(arg1 & BIT_4);
+	esw_cfg->host_vlan_tag = !!(arg1 & BIT_5);
+	esw_cfg->promisc_mode = !!(arg1 & BIT_6);
+	esw_cfg->mac_override = !!(arg1 & BIT_7);
+	esw_cfg->vlan_id = LSW(arg1 >> 16);
+	esw_cfg->mac_anti_spoof = (arg2 & 0x1);
+	esw_cfg->offload_flags = ((arg2 >> 1) & 0x7);
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index fc50e1d..118b2b2 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -52,7 +52,8 @@ static const struct qlcnic_mailbox_metadata qlcnic_83xx_mbx_tbl[] = {
 	{ QLCNIC_CMD_SET_LED_CONFIG, 5, 1},
 	{ QLCNIC_CMD_GET_LED_CONFIG, 1, 5},
 };
-const u32 qlcnic_83xx_ext_reg_tbl[] = {
+
+static const u32 qlcnic_83xx_ext_reg_tbl[] = {
 	0x38CC, /* Global Reset */
 	0x38F0, /* Wildcard */
 	0x38FC, /* Informant */
@@ -98,18 +99,18 @@ const u32 qlcnic_83xx_ext_reg_tbl[] = {
 	0x34A4, /* QLC_83XX_ASIC_TEMP */
 };
 
-const u32 qlcnic_83xx_reg_tbl[] = {
+static const u32 qlcnic_83xx_reg_tbl[] = {
 	0x34A8, /* PEG_HALT_STAT1 */
 	0x34AC, /* PEG_HALT_STAT2 */
 	0x34B0, /* FW_HEARTBEAT */
 	0x3500, /* FLASH LOCK_ID */
 	0x3528, /* FW_CAPABILITIES */
-	0x3538, /* drv active, DRV_REG0 */
-	0x3540, /* dev state, DRV_REG1 */
-	0x3544, /* drv state, DRV_REG2 */
-	0x3548, /* drv scratch, DRV_REG3 */
-	0x354C, /* dev part info, DRV_REG4 */
-	0x3524, /* drv IDC ver, DRV_REG5 */
+	0x3538, /* Driver active, DRV_REG0 */
+	0x3540, /* Device state, DRV_REG1 */
+	0x3544, /* Driver state, DRV_REG2 */
+	0x3548, /* Driver scratch, DRV_REG3 */
+	0x354C, /* Device partiton info, DRV_REG4 */
+	0x3524, /* Driver IDC ver, DRV_REG5 */
 	0x3550, /* FW_VER_MAJOR */
 	0x3554, /* FW_VER_MINOR */
 	0x3558, /* FW_VER_SUB */
@@ -124,7 +125,7 @@ const u32 qlcnic_83xx_reg_tbl[] = {
 	0x3854, /* FLASH UNLOCK */
 };
 
-struct qlcnic_hardware_ops qlcnic_83xx_hw_ops = {
+static struct qlcnic_hardware_ops qlcnic_83xx_hw_ops = {
 	.read_crb = qlcnic_83xx_read_crb,
 	.write_crb = qlcnic_83xx_write_crb,
 	.rdreg = qlcnic_83xx_rd_reg_indirect,
@@ -158,7 +159,7 @@ struct qlcnic_hardware_ops qlcnic_83xx_hw_ops = {
 	.get_board_info = qlcnic_83xx_get_port_info,
 };
 
-struct qlcnic_nic_template qlcnic_83xx_ops = {
+static struct qlcnic_nic_template qlcnic_83xx_ops = {
 	.config_bridged_mode = qlcnic_config_bridged_mode,
 	.config_led = qlcnic_config_led,
 	.request_reset = qlcnic_83xx_idc_request_reset,
@@ -426,7 +427,8 @@ qlcnic_83xx_setup_mbx_intr(struct qlcnic_adapter *adapter)
 	if (adapter->flags & QLCNIC_MSIX_ENABLED) {
 		handler = qlcnic_83xx_handle_aen;
 		val = adapter->msix_entries[adapter->ahw->num_msix - 1].vector;
-		sprintf(name, "%s[%s]", adapter->netdev->name, "aen");
+		snprintf(name, (IFNAMSIZ + 4),
+			"%s[%s]", adapter->netdev->name, "aen");
 		err = request_irq(val, handler, flags, name, adapter);
 		if (err) {
 			dev_err(&adapter->pdev->dev,
@@ -1378,18 +1380,10 @@ void qlcnic_set_npar_data(struct qlcnic_adapter *adapter,
 	npar_info->capabilities = le32_to_cpu(nic_info->capabilities);
 	npar_info->max_mtu = le16_to_cpu(nic_info->max_mtu);
 
-	dev_info(&adapter->pdev->dev,
-		"phy port: %d switch_mode: %d,\n"
-		"\tmax_tx_q: %d max_rx_q: %d min_tx_bw: 0x%x,\n"
-		"\tmax_tx_bw: 0x%x max_mtu:0x%x, capabilities: 0x%x\n",
-		npar_info->phys_port, npar_info->switch_mode,
-		npar_info->max_tx_ques, npar_info->max_rx_ques,
-		npar_info->min_tx_bw, npar_info->max_tx_bw,
-		npar_info->max_mtu, npar_info->capabilities);
 }
 
 int
-qlcnic_83xx_ms_mem_write_128b(struct qlcnic_adapter *adapter,
+qlcnic_83xx_ms_mem_write128(struct qlcnic_adapter *adapter,
 					u64 addr, u32 *data, u32 count)
 {
 	int i, j, err, ret = 0;
@@ -2468,18 +2462,6 @@ int qlcnic_83xx_get_nic_info(struct qlcnic_adapter *adapter,
 		npar_info->max_linkspeed_reg_offset =
 				(cmd.rsp.arg[8] & 0x7FFE0000) >> 17;
 
-	dev_info(&adapter->pdev->dev,
-		"\n\top_type: %d, phy port: %d switch_mode: %d,\n"
-		"\tmax_tx_q: %d max_rx_q: %d min_tx_bw: 0x%x, max_tx_bw: %d,\n"
-		"\tmax_bw_offset: 0x%x max_link_speed_offset: 0x%x,\n"
-		"\tmax_mtu:0x%x, capabilities: 0x%x\n",
-		npar_info->op_type,
-		npar_info->phys_port, npar_info->switch_mode,
-		npar_info->max_tx_ques, npar_info->max_rx_ques,
-		npar_info->min_tx_bw, npar_info->max_tx_bw,
-		npar_info->max_bw_reg_offset,
-		npar_info->max_linkspeed_reg_offset,
-		npar_info->max_mtu, npar_info->capabilities);
 out:
 	qlcnic_free_mbx_args(&cmd);
 	return err;
@@ -2623,11 +2605,11 @@ qlcnic_83xx_unlock_flash(struct qlcnic_adapter *adapter)
 }
 
 int
-qlcnic_83xx_flash_read_u32(struct qlcnic_adapter *adapter, u32 flash_addr,
-						u8 *p_data, int u32_word_count)
+qlcnic_83xx_flash_read32(struct qlcnic_adapter *adapter, u32 flash_addr,
+						u8 *p_data, int count)
 {
 	int i, err;
-	u32 u32_word;
+	u32 word;
 	u32 addr = flash_addr;
 
 	if (qlcnic_83xx_lock_flash(adapter) != 0)
@@ -2639,16 +2621,16 @@ qlcnic_83xx_flash_read_u32(struct qlcnic_adapter *adapter, u32 flash_addr,
 		return -EIO;
 	}
 
-	for (i = 0; i < u32_word_count; i++) {
+	for (i = 0; i < count; i++) {
 		if (qlcnic_83xx_wrt_reg_indirect(adapter,
 					QLC_83XX_FLASH_DIRECT_WINDOW, (addr))) {
 			qlcnic_83xx_unlock_flash(adapter);
 			return -EIO;
 		}
 
-		u32_word = qlcnic_83xx_rd_reg_indirect(adapter,
+		word = qlcnic_83xx_rd_reg_indirect(adapter,
 					QLC_83XX_FLASH_DIRECT_DATA(addr), &err);
-		*(__le32 *)p_data  = le32_to_cpu(u32_word);
+		*(__le32 *)p_data  = le32_to_cpu(word);
 		p_data = p_data + 4;
 		addr = addr + 4;
 	}
@@ -2659,11 +2641,11 @@ qlcnic_83xx_flash_read_u32(struct qlcnic_adapter *adapter, u32 flash_addr,
 }
 
 int
-qlcnic_83xx_lockless_flash_read_u32(struct qlcnic_adapter *adapter,
-			 u32 flash_addr, u8 *p_data, int u32_word_count)
+qlcnic_83xx_lockless_flash_read32(struct qlcnic_adapter *adapter,
+			 u32 flash_addr, u8 *p_data, int count)
 {
 	int err;
-	u32 i, u32_word, flash_offset;
+	u32 i, word, flash_offset;
 	u32 addr = flash_addr;
 
 	flash_offset = addr & (QLCNIC_FLASH_SECTOR_SIZE - 1);
@@ -2677,15 +2659,15 @@ qlcnic_83xx_lockless_flash_read_u32(struct qlcnic_adapter *adapter,
 			QLC_83XX_FLASH_DIRECT_WINDOW, (addr));
 
 	/* Check if data is spread across multiple sectors  */
-	if ((flash_offset + (u32_word_count * sizeof(u32))) >
+	if ((flash_offset + (count * sizeof(u32))) >
 				(QLCNIC_FLASH_SECTOR_SIZE - 1)) {
 
 		/* Multi sector read */
-		for (i = 0; i < u32_word_count; i++) {
-			u32_word = qlcnic_83xx_rd_reg_indirect(adapter,
+		for (i = 0; i < count; i++) {
+			word = qlcnic_83xx_rd_reg_indirect(adapter,
 					QLC_83XX_FLASH_DIRECT_DATA(addr), &err);
 
-			*(__le32 *)p_data  = le32_to_cpu(u32_word);
+			*(__le32 *)p_data  = le32_to_cpu(word);
 			p_data = p_data + 4;
 			addr = addr + 4;
 			flash_offset = flash_offset + 4;
@@ -2699,10 +2681,10 @@ qlcnic_83xx_lockless_flash_read_u32(struct qlcnic_adapter *adapter,
 		}
 	} else {
 		/* Single sector read */
-		for (i = 0; i < u32_word_count; i++) {
-			u32_word = qlcnic_83xx_rd_reg_indirect(adapter,
+		for (i = 0; i < count; i++) {
+			word = qlcnic_83xx_rd_reg_indirect(adapter,
 					QLC_83XX_FLASH_DIRECT_DATA(addr), &err);
-			*(__le32 *)p_data  = cpu_to_le32(u32_word);
+			*(__le32 *)p_data  = cpu_to_le32(word);
 			p_data = p_data + 4;
 			addr = addr + 4;
 		}
@@ -2813,7 +2795,7 @@ qlcnic_83xx_read_flash_descriptor_table(struct qlcnic_adapter *adapter)
 		return -EIO;
 
 	memset(&adapter->ahw->flash_fdt, 0, fdt_size);
-	ret = qlcnic_83xx_lockless_flash_read_u32(adapter,
+	ret = qlcnic_83xx_lockless_flash_read32(adapter,
 				QLCNIC_FDT_LOCATION,
 				(u8 *)&adapter->ahw->flash_fdt,
 				count);
@@ -2891,7 +2873,7 @@ qlcnic_83xx_erase_flash_sector(struct qlcnic_adapter *adapter,
 }
 
 int
-qlcnic_83xx_flash_write_u32(struct qlcnic_adapter *adapter, u32 addr,
+qlcnic_83xx_flash_write32(struct qlcnic_adapter *adapter, u32 addr,
 					u32 *p_data)
 {
 	int ret = -EIO;
@@ -2913,13 +2895,13 @@ qlcnic_83xx_flash_write_u32(struct qlcnic_adapter *adapter, u32 addr,
 
 int
 qlcnic_83xx_flash_bulk_write(struct qlcnic_adapter *adapter, u32 addr,
-					u32 *p_data, int u32_word_count)
+					u32 *p_data, int count)
 {
 	u32 temp;
 	int ret = -EIO, err;
 
-	if ((u32_word_count <  QLC_83XX_FLASH_BULK_WRITE_MIN) ||
-	(u32_word_count >  QLC_83XX_FLASH_BULK_WRITE_MAX)) {
+	if ((count <  QLC_83XX_FLASH_BULK_WRITE_MIN) ||
+	(count >  QLC_83XX_FLASH_BULK_WRITE_MAX)) {
 		dev_err(&adapter->pdev->dev,
 			 " %s: Invalid word count\n", __func__);
 		return -EIO;
@@ -2944,13 +2926,13 @@ qlcnic_83xx_flash_bulk_write(struct qlcnic_adapter *adapter, u32 addr,
 		return -EIO;
 	}
 
-	u32_word_count--;
+	count--;
 
 	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_ADDR,
 			QLC_83XX_FLASH_ADDR_SECOND_TEMP_VAL);
 
 	/* Second to N-1 DWORD writes */
-	while (u32_word_count != 1) {
+	while (count != 1) {
 		qlcnic_83xx_wrt_reg_indirect(adapter,
 					QLC_83XX_FLASH_WRDATA, *p_data++);
 		qlcnic_83xx_wrt_reg_indirect(adapter,
@@ -2962,7 +2944,7 @@ qlcnic_83xx_flash_bulk_write(struct qlcnic_adapter *adapter, u32 addr,
 				 " %s: failed at %d\n", __func__, __LINE__);
 			return -EIO;
 		}
-		u32_word_count--;
+		count--;
 	}
 
 	qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_ADDR,
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index 6cd4877..c725b07 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -532,17 +532,17 @@ void qlcnic_83xx_register_nic_idc_func(struct qlcnic_adapter *, int);
 void qlcnic_83xx_config_led(struct qlcnic_adapter *, u32, u32);
 
 /* 83xx MS memory access API's */
-int qlcnic_83xx_ms_mem_write_128b(struct qlcnic_adapter *, u64, u32 *, u32);
+int qlcnic_83xx_ms_mem_write128(struct qlcnic_adapter *, u64, u32 *, u32);
 void qlcnic_ind_wr(struct qlcnic_adapter *, u32, u32);
 u32 qlcnic_ind_rd(struct qlcnic_adapter *, u32);
 
 /* 83xx flash operations */
-int qlcnic_83xx_flash_read_u32(struct qlcnic_adapter *, u32, u8 *, int);
-int qlcnic_83xx_lockless_flash_read_u32(struct qlcnic_adapter *,
+int qlcnic_83xx_flash_read32(struct qlcnic_adapter *, u32, u8 *, int);
+int qlcnic_83xx_lockless_flash_read32(struct qlcnic_adapter *,
 						u32, u8 *, int);
 int qlcnic_83xx_erase_flash_sector(struct qlcnic_adapter *, u32);
 int qlcnic_83xx_flash_bulk_write(struct qlcnic_adapter *, u32, u32 *, int);
-int qlcnic_83xx_flash_write_u32(struct qlcnic_adapter *, u32, u32 *);
+int qlcnic_83xx_flash_write32(struct qlcnic_adapter *, u32, u32 *);
 int qlcnic_83xx_lock_flash(struct qlcnic_adapter *);
 void qlcnic_83xx_unlock_flash(struct qlcnic_adapter *);
 void qlcnic_83xx_get_stats(struct qlcnic_adapter *,
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index 6e14662..ffd1028 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -994,7 +994,7 @@ qlcnic_83xx_setup_idc_parameters(struct qlcnic_adapter *adapter)
 {
 	u32 idc_params, val;
 
-	if (qlcnic_83xx_lockless_flash_read_u32(adapter,
+	if (qlcnic_83xx_lockless_flash_read32(adapter,
 			QLC_83XX_IDC_FLASH_PARAM_ADDR,
 					(u8 *)&idc_params, 1)) {
 		dev_info(&adapter->pdev->dev,
@@ -1195,7 +1195,7 @@ qlcnic_83xx_copy_bootloader(struct qlcnic_adapter *adapter)
 		return -ENOMEM;
 	}
 
-	ret = qlcnic_83xx_lockless_flash_read_u32(adapter, src,
+	ret = qlcnic_83xx_lockless_flash_read32(adapter, src,
 					p_cache, size/sizeof(u32));
 	if (ret) {
 		kfree(p_cache);
@@ -1203,7 +1203,7 @@ qlcnic_83xx_copy_bootloader(struct qlcnic_adapter *adapter)
 	}
 
 	/* 16 byte write to MS memory */
-	ret = qlcnic_83xx_ms_mem_write_128b(adapter, dest,
+	ret = qlcnic_83xx_ms_mem_write128(adapter, dest,
 					(u32 *)p_cache, size/16);
 	if (ret) {
 		kfree(p_cache);
@@ -1230,7 +1230,7 @@ qlcnic_83xx_copy_fw_file(struct qlcnic_adapter *adapter)
 	p_cache = (u32 *)adapter->ahw->fw_info.fw->data;
 	addr = (u64)dest;
 
-	ret = qlcnic_83xx_ms_mem_write_128b(adapter, addr,
+	ret = qlcnic_83xx_ms_mem_write128(adapter, addr,
 					(u32 *)p_cache, size/16);
 	if (ret) {
 		dev_err(&adapter->pdev->dev, "MS memory write failed\n");
@@ -1239,7 +1239,7 @@ qlcnic_83xx_copy_fw_file(struct qlcnic_adapter *adapter)
 		return -EIO;
 	}
 
-	/* Check 128 bit alignment  */
+	/* bit alignment check  */
 	if (adapter->ahw->fw_info.fw->size & 0xF) {
 		addr = dest + size;
 		for (i = 0; i < (adapter->ahw->fw_info.fw->size & 0xF); i++)
@@ -1248,7 +1248,7 @@ qlcnic_83xx_copy_fw_file(struct qlcnic_adapter *adapter)
 		for (; i < 16 ; i++)
 			data[i] = 0;
 
-		ret = qlcnic_83xx_ms_mem_write_128b(adapter, addr,
+		ret = qlcnic_83xx_ms_mem_write128(adapter, addr,
 							(u32 *)data, 1);
 		if (ret) {
 			dev_err(&adapter->pdev->dev,
@@ -1397,7 +1397,7 @@ int qlcnic_83xx_get_reset_instruction_template(struct qlcnic_adapter *p_dev)
 	u32_count = sizeof(struct qlcnic_83xx_reset_template_hdr) / sizeof(u32);
 
 	/* Copy template header from flash */
-	if (qlcnic_83xx_flash_read_u32(p_dev, addr, p_buff, u32_count)) {
+	if (qlcnic_83xx_flash_read32(p_dev, addr, p_buff, u32_count)) {
 		dev_err(&p_dev->pdev->dev, "%s: flash read failed\n", __func__);
 		return -EIO;
 	}
@@ -1411,7 +1411,7 @@ int qlcnic_83xx_get_reset_instruction_template(struct qlcnic_adapter *p_dev)
 			p_dev->ahw->reset.hdr->hdr_size)/sizeof(u32);
 
 	/* Copy rest of the template */
-	if (qlcnic_83xx_flash_read_u32(p_dev, addr, p_buff, u32_count)) {
+	if (qlcnic_83xx_flash_read32(p_dev, addr, p_buff, u32_count)) {
 		dev_err(&p_dev->pdev->dev, "%s: flash read failed\n", __func__);
 		return -EIO;
 	}
@@ -1762,6 +1762,27 @@ qlcnic_83xx_init_hw(struct qlcnic_adapter *p_dev)
 		dev_err(&p_dev->pdev->dev, "%s: failed\n", __func__);
 }
 
+static int
+qlcnic_83xx_load_fw_image_from_host(struct qlcnic_adapter *adapter)
+{
+	int err = -EIO;
+
+	if (request_firmware(&adapter->ahw->fw_info.fw,
+		QLC_83XX_FW_FILE_NAME, &(adapter->pdev->dev))) {
+		dev_err(&adapter->pdev->dev,
+			"No file FW image, loading flash FW image.\n");
+		QLCWR(adapter, QLCNIC_FW_IMG_VALID,
+				QLC_83XX_BOOT_FROM_FLASH);
+	} else {
+		if (qlcnic_83xx_copy_fw_file(adapter))
+			return err;
+		QLCWR(adapter, QLCNIC_FW_IMG_VALID,
+				QLC_83XX_BOOT_FROM_FILE);
+	}
+
+	return 0;
+}
+
 int qlcnic_83xx_restart_hw(struct qlcnic_adapter *adapter)
 {
 	u32 val;
@@ -1777,23 +1798,15 @@ int qlcnic_83xx_restart_hw(struct qlcnic_adapter *adapter)
 	qlcnic_83xx_init_hw(adapter);
 	if (qlcnic_83xx_copy_bootloader(adapter))
 		return err;
+
 	/* Boot either flash image or firmware image from host file system */
 	if (adapter->ahw->fw_info.load_from_file) {
-		if (request_firmware(&adapter->ahw->fw_info.fw,
-				QLC_83XX_FW_FILE_NAME, &(adapter->pdev->dev))) {
-			dev_err(&adapter->pdev->dev,
-				"No file FW image, loading flash FW image.\n");
-			QLCWR(adapter, QLCNIC_FW_IMG_VALID,
-					QLC_83XX_BOOT_FROM_FLASH);
-		} else {
-			if (qlcnic_83xx_copy_fw_file(adapter))
-				return err;
-			QLCWR(adapter, QLCNIC_FW_IMG_VALID,
-					QLC_83XX_BOOT_FROM_FILE);
-		}
+		if (qlcnic_83xx_load_fw_image_from_host(adapter))
+			return err;
 	} else {
 		QLCWR(adapter, QLCNIC_FW_IMG_VALID, QLC_83XX_BOOT_FROM_FLASH);
 	}
+
 	qlcnic_83xx_start_hw(adapter);
 	if (qlcnic_83xx_check_hw_status(adapter))
 		return -EIO;
@@ -1835,6 +1848,7 @@ int qlcnic_83xx_get_nic_configuration(struct qlcnic_adapter *adapter)
 	int err;
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
+	memset(&nic_info, 0, sizeof(struct qlcnic_info));
 	err = ahw->hw_ops->get_nic_info(adapter, &nic_info, ahw->pci_func);
 	if (err)
 		return -EIO;
@@ -1987,7 +2001,7 @@ qlcnic_83xx_init(struct qlcnic_adapter *adapter)
 
 	INIT_DELAYED_WORK(&adapter->idc_aen_work, qlcnic_83xx_idc_aen_work);
 
-	/* register for NIC IDC AEN Events */
+	/* Register for NIC IDC AEN events */
 	qlcnic_83xx_register_nic_idc_func(adapter, 1);
 
 	/* Periodically monitor device status */
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
index 1b3b637..ab843d8 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
@@ -118,7 +118,6 @@ qlcnic_83xx_init_mgmt_vnic(struct qlcnic_adapter *adapter)
 {
 	int err = -EIO;
 
-	/*qlcnic_83xx_get_minidump_template(adapter);*/
 	if (!(adapter->flags & QLCNIC_ADAPTER_INITIALIZED)) {
 		if (qlcnic_init_pci_info(adapter))
 			return err;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
deleted file mode 100644
index 4b885c4..0000000
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ /dev/null
@@ -1,1179 +0,0 @@
-/*
- * QLogic qlcnic NIC Driver
- * Copyright (c)  2009-2010 QLogic Corporation
- *
- * See LICENSE.qlcnic for copyright and licensing details.
- */
-
-#include "qlcnic.h"
-
-/* Array of FW control command structs with command type and required
- * number of input and output arguments respectively.
-*/
-static const struct qlcnic_mailbox_metadata qlcnic_mbx_tbl[] = {
-	{ QLCNIC_CMD_CREATE_RX_CTX, 4, 1 },
-	{ QLCNIC_CMD_DESTROY_RX_CTX, 2, 1 },
-	{ QLCNIC_CMD_CREATE_TX_CTX, 4, 1 },
-	{ QLCNIC_CMD_DESTROY_TX_CTX, 2, 1 },
-	{ QLCNIC_CMD_INTRPT_TEST, 4, 1 },
-	{ QLCNIC_CMD_SET_MTU, 4, 1 },
-	{ QLCNIC_CMD_READ_PHY, 4, 2 },
-	{ QLCNIC_CMD_WRITE_PHY, 5, 1 },
-	{ QLCNIC_CMD_READ_HW_REG, 4, 1 },
-	{ QLCNIC_CMD_GET_FLOW_CTL, 4, 2 },
-	{ QLCNIC_CMD_SET_FLOW_CTL, 4, 1 },
-	{ QLCNIC_CMD_READ_MAX_MTU, 4, 2 },
-	{ QLCNIC_CMD_READ_MAX_LRO, 4, 2 },
-	{ QLCNIC_CMD_MAC_ADDRESS, 4, 3 },
-	{ QLCNIC_CMD_GET_PCI_INFO, 4, 1 },
-	{ QLCNIC_CMD_GET_NIC_INFO, 4, 1 },
-	{ QLCNIC_CMD_SET_NIC_INFO, 4, 1 },
-	{ QLCNIC_CMD_GET_ESWITCH_CAPABILITY, 4, 3 },
-	{ QLCNIC_CMD_TOGGLE_ESWITCH, 4, 1 },
-	{ QLCNIC_CMD_GET_ESWITCH_STATUS, 4, 3 },
-	{ QLCNIC_CMD_SET_PORTMIRRORING, 4, 1 },
-	{ QLCNIC_CMD_CONFIGURE_ESWITCH, 4, 1 },
-	{ QLCNIC_CMD_GET_MAC_STATS, 4, 1 },
-	{ QLCNIC_CMD_GET_ESWITCH_PORT_CONFIG, 4, 3 },
-	{ QLCNIC_CMD_GET_ESWITCH_STATS, 5, 1 },
-	{ QLCNIC_CMD_CONFIG_PORT, 4, 1 },
-	{ QLCNIC_CMD_TEMP_SIZE, 4, 4 },
-	{ QLCNIC_CMD_GET_TEMP_HDR, 4, 1 },
-};
-
-/* Allocate mailbox incoming and outgoing registers. It should be used with a
- * follow up call to qlcnic_free_mbx_args
- */
-int qlcnic_alloc_mbx_args(struct qlcnic_cmd_args *mbx,
-		struct qlcnic_adapter *adapter, u32 type)
-{
-	int i, size;
-	const struct qlcnic_mailbox_metadata *mbx_tbl;
-
-	mbx_tbl = qlcnic_mbx_tbl;
-	size = ARRAY_SIZE(qlcnic_mbx_tbl);
-	for (i = 0; i < size; i++) {
-		if (type == mbx_tbl[i].cmd) {
-			mbx->req.num = mbx_tbl[i].in_args;
-			mbx->rsp.num = mbx_tbl[i].out_args;
-			mbx->req.arg = kcalloc(mbx->req.num,
-				sizeof(u32), GFP_ATOMIC);
-			if (!mbx->req.arg)
-				return -ENOMEM;
-			mbx->rsp.arg = kcalloc(mbx->rsp.num,
-				sizeof(u32), GFP_ATOMIC);
-			if (!mbx->rsp.arg) {
-				kfree(mbx->req.arg);
-				mbx->req.arg = NULL;
-				return -ENOMEM;
-			}
-			memset(mbx->req.arg, 0, sizeof(u32) * mbx->req.num);
-			memset(mbx->rsp.arg, 0, sizeof(u32) * mbx->rsp.num);
-			mbx->req.arg[0] = type;
-			break;
-		}
-	}
-	return 0;
-}
-
-/* Free up mailbox registers
- *  */
-void qlcnic_free_mbx_args(struct qlcnic_cmd_args *cmd)
-{
-	kfree(cmd->req.arg);
-	cmd->req.arg = NULL;
-	kfree(cmd->rsp.arg);
-	cmd->rsp.arg = NULL;
-}
-
-
-static u32
-qlcnic_poll_rsp(struct qlcnic_adapter *adapter)
-{
-	u32 rsp;
-	int err, timeout = 0;
-
-	do {
-		/* give atleast 1ms for firmware to respond */
-		msleep(1);
-
-		if (++timeout > QLCNIC_OS_CRB_RETRY_COUNT)
-			return QLCNIC_CDRP_RSP_TIMEOUT;
-
-		rsp = QLCRD32(adapter, QLCNIC_CDRP_CRB_OFFSET, &err);
-	} while (!QLCNIC_CDRP_IS_RSP(rsp));
-
-	return rsp;
-}
-
-int
-qlcnic_issue_cmd(struct qlcnic_adapter *adapter, struct qlcnic_cmd_args *cmd)
-{
-	int i, err;
-	u32 rsp;
-	u32 signature;
-	struct pci_dev *pdev = adapter->pdev;
-	struct qlcnic_hardware_context *ahw = adapter->ahw;
-
-	signature = QLCNIC_CDRP_SIGNATURE_MAKE(ahw);
-
-	/* Acquire semaphore before accessing CRB */
-	if (ahw->hw_ops->api_lock(adapter)) {
-		cmd->rsp.arg[0] = QLCNIC_RCODE_TIMEOUT;
-		return cmd->rsp.arg[0];
-	}
-
-	QLCWR32(adapter, QLCNIC_SIGN_CRB_OFFSET, signature);
-	for (i = 1; i < QLCNIC_CDRP_MAX_ARGS; i++)
-		QLCWR32(adapter, QLCNIC_CDRP_ARG(i), cmd->req.arg[i]);
-	QLCWR32(adapter, QLCNIC_CDRP_CRB_OFFSET,
-		QLCNIC_CDRP_FORM_CMD(cmd->req.arg[0]));
-	rsp = qlcnic_poll_rsp(adapter);
-
-	if (rsp == QLCNIC_CDRP_RSP_TIMEOUT) {
-		dev_err(&pdev->dev, "card response timeout.\n");
-		cmd->rsp.arg[0] = QLCNIC_RCODE_TIMEOUT;
-	} else if (rsp == QLCNIC_CDRP_RSP_FAIL) {
-		cmd->rsp.arg[0] = QLCRD32(adapter, QLCNIC_CDRP_ARG(1), &err);
-		dev_err(&pdev->dev, "failed card response code:0x%x\n",
-				cmd->rsp.arg[0]);
-	} else if (rsp == QLCNIC_CDRP_RSP_OK)
-		cmd->rsp.arg[0] = QLCNIC_RCODE_SUCCESS;
-
-	for (i = 1; i < cmd->rsp.num; i++)
-		cmd->rsp.arg[i] = QLCRD32(adapter, QLCNIC_CDRP_ARG(i), &err);
-
-	/* Release semaphore */
-	ahw->hw_ops->api_unlock(adapter);
-	return cmd->rsp.arg[0];
-}
-
-int
-qlcnic_fw_cmd_set_mtu(struct qlcnic_adapter *adapter, int mtu)
-{
-	int err = 0;
-	struct qlcnic_cmd_args cmd;
-	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
-
-	if (recv_ctx->state != QLCNIC_HOST_CTX_STATE_ACTIVE)
-		return err;
-	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
-						QLCNIC_CMD_SET_MTU);
-	cmd.req.arg[1] = recv_ctx->context_id;
-	cmd.req.arg[2] = mtu;
-
-	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
-	if (err) {
-		dev_err(&adapter->pdev->dev, "Failed to set mtu\n");
-		err = -EIO;
-	}
-	qlcnic_free_mbx_args(&cmd);
-	return err;
-}
-
-int
-qlcnic_fw_cmd_create_rx_ctx(struct qlcnic_adapter *adapter)
-{
-	void *addr;
-	struct qlcnic_hostrq_rx_ctx *prq;
-	struct qlcnic_cardrsp_rx_ctx *prsp;
-	struct qlcnic_hostrq_rds_ring *prq_rds;
-	struct qlcnic_hostrq_sds_ring *prq_sds;
-	struct qlcnic_cardrsp_rds_ring *prsp_rds;
-	struct qlcnic_cardrsp_sds_ring *prsp_sds;
-	struct qlcnic_host_rds_ring *rds_ring;
-	struct qlcnic_host_sds_ring *sds_ring;
-	struct qlcnic_cmd_args cmd;
-
-	dma_addr_t hostrq_phys_addr, cardrsp_phys_addr;
-	u64 phys_addr;
-
-	u8 i, nrds_rings, nsds_rings;
-	size_t rq_size, rsp_size;
-	u32 cap, reg, val, reg2;
-	int err;
-
-	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
-
-	nrds_rings = adapter->max_rds_rings;
-	nsds_rings = adapter->max_sds_rings;
-
-	rq_size =
-		SIZEOF_HOSTRQ_RX(struct qlcnic_hostrq_rx_ctx, nrds_rings,
-						nsds_rings);
-	rsp_size =
-		SIZEOF_CARDRSP_RX(struct qlcnic_cardrsp_rx_ctx, nrds_rings,
-						nsds_rings);
-
-	addr = dma_alloc_coherent(&adapter->pdev->dev, rq_size,
-			&hostrq_phys_addr, GFP_KERNEL);
-	if (addr == NULL)
-		return -ENOMEM;
-	prq = addr;
-
-	addr = dma_alloc_coherent(&adapter->pdev->dev, rsp_size,
-			&cardrsp_phys_addr, GFP_KERNEL);
-	if (addr == NULL) {
-		err = -ENOMEM;
-		goto out_free_rq;
-	}
-	prsp = addr;
-
-	prq->host_rsp_dma_addr = cpu_to_le64(cardrsp_phys_addr);
-
-	cap = (QLCNIC_CAP0_LEGACY_CONTEXT | QLCNIC_CAP0_LEGACY_MN
-						| QLCNIC_CAP0_VALIDOFF);
-	cap |= (QLCNIC_CAP0_JUMBO_CONTIGUOUS | QLCNIC_CAP0_LRO_CONTIGUOUS);
-
-	prq->valid_field_offset = offsetof(struct qlcnic_hostrq_rx_ctx,
-							 msix_handler);
-	prq->txrx_sds_binding = nsds_rings - 1;
-
-	prq->capabilities[0] = cpu_to_le32(cap);
-	prq->host_int_crb_mode =
-		cpu_to_le32(QLCNIC_HOST_INT_CRB_MODE_SHARED);
-	prq->host_rds_crb_mode =
-		cpu_to_le32(QLCNIC_HOST_RDS_CRB_MODE_UNIQUE);
-
-	prq->num_rds_rings = cpu_to_le16(nrds_rings);
-	prq->num_sds_rings = cpu_to_le16(nsds_rings);
-	prq->rds_ring_offset = 0;
-
-	val = le32_to_cpu(prq->rds_ring_offset) +
-		(sizeof(struct qlcnic_hostrq_rds_ring) * nrds_rings);
-	prq->sds_ring_offset = cpu_to_le32(val);
-
-	prq_rds = (struct qlcnic_hostrq_rds_ring *)(prq->data +
-			le32_to_cpu(prq->rds_ring_offset));
-
-	for (i = 0; i < nrds_rings; i++) {
-
-		rds_ring = &recv_ctx->rds_rings[i];
-		rds_ring->producer = 0;
-
-		prq_rds[i].host_phys_addr = cpu_to_le64(rds_ring->phys_addr);
-		prq_rds[i].ring_size = cpu_to_le32(rds_ring->num_desc);
-		prq_rds[i].ring_kind = cpu_to_le32(i);
-		prq_rds[i].buff_size = cpu_to_le64(rds_ring->dma_size);
-	}
-
-	prq_sds = (struct qlcnic_hostrq_sds_ring *)(prq->data +
-			le32_to_cpu(prq->sds_ring_offset));
-
-	for (i = 0; i < nsds_rings; i++) {
-
-		sds_ring = &recv_ctx->sds_rings[i];
-		sds_ring->consumer = 0;
-		memset(sds_ring->desc_head, 0, STATUS_DESC_RINGSIZE(sds_ring));
-
-		prq_sds[i].host_phys_addr = cpu_to_le64(sds_ring->phys_addr);
-		prq_sds[i].ring_size = cpu_to_le32(sds_ring->num_desc);
-		prq_sds[i].msi_index = cpu_to_le16(i);
-	}
-
-	phys_addr = hostrq_phys_addr;
-	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
-						QLCNIC_CMD_CREATE_RX_CTX);
-	cmd.req.arg[1] = MSD(phys_addr);
-	cmd.req.arg[2] = LSD(phys_addr);
-	cmd.req.arg[3] = rq_size;
-	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
-	if (err) {
-		dev_err(&adapter->pdev->dev,
-			"Failed to create rx ctx in firmware%d\n", err);
-		goto out_free_rsp;
-	}
-
-	prsp_rds = ((struct qlcnic_cardrsp_rds_ring *)
-			 &prsp->data[le32_to_cpu(prsp->rds_ring_offset)]);
-
-	for (i = 0; i < le16_to_cpu(prsp->num_rds_rings); i++) {
-		rds_ring = &recv_ctx->rds_rings[i];
-
-		reg = le32_to_cpu(prsp_rds[i].host_producer_crb);
-		rds_ring->crb_rcv_producer = adapter->ahw->pci_base0 + reg;
-	}
-
-	prsp_sds = ((struct qlcnic_cardrsp_sds_ring *)
-			&prsp->data[le32_to_cpu(prsp->sds_ring_offset)]);
-
-	for (i = 0; i < le16_to_cpu(prsp->num_sds_rings); i++) {
-		sds_ring = &recv_ctx->sds_rings[i];
-
-		reg = le32_to_cpu(prsp_sds[i].host_consumer_crb);
-		reg2 = le32_to_cpu(prsp_sds[i].interrupt_crb);
-
-		sds_ring->crb_sts_consumer = adapter->ahw->pci_base0 + reg;
-		sds_ring->crb_intr_mask = adapter->ahw->pci_base0 + reg2;
-	}
-
-	recv_ctx->state = le32_to_cpu(prsp->host_ctx_state);
-	recv_ctx->context_id = le16_to_cpu(prsp->context_id);
-	recv_ctx->virt_port = prsp->virt_port;
-
-out_free_rsp:
-	dma_free_coherent(&adapter->pdev->dev, rsp_size, prsp,
-		cardrsp_phys_addr);
-	qlcnic_free_mbx_args(&cmd);
-out_free_rq:
-	dma_free_coherent(&adapter->pdev->dev, rq_size, prq, hostrq_phys_addr);
-	return err;
-}
-
-static void
-qlcnic_fw_cmd_destroy_rx_ctx(struct qlcnic_adapter *adapter)
-{
-	int err;
-	struct qlcnic_cmd_args cmd;
-	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
-
-	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
-					QLCNIC_CMD_DESTROY_RX_CTX);
-	cmd.req.arg[1] = recv_ctx->context_id;
-	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
-	if (err)
-		dev_err(&adapter->pdev->dev,
-			"Failed to destroy rx ctx in firmware\n");
-
-	recv_ctx->state = QLCNIC_HOST_CTX_STATE_FREED;
-	qlcnic_free_mbx_args(&cmd);
-}
-
-int
-qlcnic_fw_cmd_create_tx_ctx(struct qlcnic_adapter *adapter,
-	struct qlcnic_host_tx_ring *tx_ring, int ring)
-{
-	struct qlcnic_hostrq_tx_ctx	*prq;
-	struct qlcnic_hostrq_cds_ring	*prq_cds;
-	struct qlcnic_cardrsp_tx_ctx	*prsp;
-	void	*rq_addr, *rsp_addr;
-	size_t	rq_size, rsp_size;
-	u32	temp;
-	struct qlcnic_cmd_args cmd;
-	int	err;
-	u64	phys_addr;
-	dma_addr_t	rq_phys_addr, rsp_phys_addr;
-
-	/* reset host resources */
-	tx_ring->producer = 0;
-	tx_ring->sw_consumer = 0;
-	*(tx_ring->hw_consumer) = 0;
-
-	rq_size = SIZEOF_HOSTRQ_TX(struct qlcnic_hostrq_tx_ctx);
-	rq_addr = dma_alloc_coherent(&adapter->pdev->dev, rq_size,
-			&rq_phys_addr, GFP_KERNEL);
-	if (!rq_addr)
-		return -ENOMEM;
-
-	rsp_size = SIZEOF_CARDRSP_TX(struct qlcnic_cardrsp_tx_ctx);
-	rsp_addr = dma_alloc_coherent(&adapter->pdev->dev, rsp_size,
-			&rsp_phys_addr, GFP_KERNEL);
-	if (!rsp_addr) {
-		err = -ENOMEM;
-		goto out_free_rq;
-	}
-
-	memset(rq_addr, 0, rq_size);
-	prq = rq_addr;
-
-	memset(rsp_addr, 0, rsp_size);
-	prsp = rsp_addr;
-
-	prq->host_rsp_dma_addr = cpu_to_le64(rsp_phys_addr);
-
-	temp = (QLCNIC_CAP0_LEGACY_CONTEXT | QLCNIC_CAP0_LEGACY_MN |
-					QLCNIC_CAP0_LSO);
-	prq->capabilities[0] = cpu_to_le32(temp);
-
-	prq->host_int_crb_mode =
-		cpu_to_le32(QLCNIC_HOST_INT_CRB_MODE_SHARED);
-	prq->msi_index = 0;
-
-	prq->interrupt_ctl = 0;
-	prq->cmd_cons_dma_addr = cpu_to_le64(tx_ring->hw_cons_phys_addr);
-
-	prq_cds = &prq->cds_ring;
-
-	prq_cds->host_phys_addr = cpu_to_le64(tx_ring->phys_addr);
-	prq_cds->ring_size = cpu_to_le32(tx_ring->num_desc);
-
-	phys_addr = rq_phys_addr;
-
-	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
-					QLCNIC_CMD_CREATE_TX_CTX);
-	cmd.req.arg[1] = MSD(phys_addr);
-	cmd.req.arg[2] = LSD(phys_addr);
-	cmd.req.arg[3] = rq_size;
-	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
-
-	if (err == QLCNIC_RCODE_SUCCESS) {
-		temp = le32_to_cpu(prsp->cds_ring.host_producer_crb);
-		tx_ring->crb_cmd_producer = adapter->ahw->pci_base0 + temp;
-		tx_ring->ctx_id = le16_to_cpu(prsp->context_id);
-	} else {
-		dev_err(&adapter->pdev->dev,
-			"Failed to create tx ctx in firmware%d\n", err);
-		err = -EIO;
-	}
-
-	dma_free_coherent(&adapter->pdev->dev, rsp_size, rsp_addr,
-		rsp_phys_addr);
-
-out_free_rq:
-	dma_free_coherent(&adapter->pdev->dev, rq_size, rq_addr, rq_phys_addr);
-	qlcnic_free_mbx_args(&cmd);
-
-	return err;
-}
-
-static void
-qlcnic_fw_cmd_destroy_tx_ctx(struct qlcnic_adapter *adapter,
-	struct qlcnic_host_tx_ring *tx_ring)
-{
-	struct qlcnic_cmd_args cmd;
-
-	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
-					QLCNIC_CMD_DESTROY_TX_CTX);
-	cmd.req.arg[1] = tx_ring->ctx_id;
-	if (adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd))
-		dev_err(&adapter->pdev->dev,
-			"Failed to destroy tx ctx in firmware\n");
-	qlcnic_free_mbx_args(&cmd);
-}
-
-int
-qlcnic_fw_cmd_set_port(struct qlcnic_adapter *adapter, u32 config)
-{
-	int err;
-	struct qlcnic_cmd_args cmd;
-
-	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
-						QLCNIC_CMD_CONFIG_PORT);
-	cmd.req.arg[1] = config;
-	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
-	qlcnic_free_mbx_args(&cmd);
-	return err;
-}
-
-int qlcnic_alloc_hw_resources(struct qlcnic_adapter *adapter)
-{
-	void *addr;
-	int err, ring;
-	struct qlcnic_recv_context *recv_ctx;
-	struct qlcnic_host_rds_ring *rds_ring;
-	struct qlcnic_host_sds_ring *sds_ring;
-	struct qlcnic_host_tx_ring *tx_ring;
-
-	struct pci_dev *pdev = adapter->pdev;
-
-	recv_ctx = adapter->recv_ctx;
-
-	for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
-		tx_ring = &adapter->tx_ring[ring];
-		tx_ring->hw_consumer = (__le32 *) dma_alloc_coherent(&pdev->dev,
-			sizeof(u32), &tx_ring->hw_cons_phys_addr, GFP_KERNEL);
-		if (tx_ring->hw_consumer == NULL) {
-			dev_err(&pdev->dev, "failed to allocate tx consumer\n");
-			return -ENOMEM;
-		}
-		/* cmd desc ring */
-		addr = dma_alloc_coherent(&pdev->dev, TX_DESC_RINGSIZE(tx_ring),
-			&tx_ring->phys_addr, GFP_KERNEL);
-
-		if (addr == NULL) {
-			dev_err(&pdev->dev,
-				 "failed to allocate tx desc ring\n");
-			err = -ENOMEM;
-			goto err_out_free;
-		}
-
-		tx_ring->desc_head = addr;
-	}
-
-	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
-		rds_ring = &recv_ctx->rds_rings[ring];
-		addr = dma_alloc_coherent(&adapter->pdev->dev,
-				RCV_DESC_RINGSIZE(rds_ring),
-				&rds_ring->phys_addr, GFP_KERNEL);
-		if (addr == NULL) {
-			dev_err(&pdev->dev,
-				"failed to allocate rds ring [%d]\n", ring);
-			err = -ENOMEM;
-			goto err_out_free;
-		}
-		rds_ring->desc_head = addr;
-
-	}
-
-	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
-		sds_ring = &recv_ctx->sds_rings[ring];
-
-		addr = dma_alloc_coherent(&adapter->pdev->dev,
-				STATUS_DESC_RINGSIZE(sds_ring),
-				&sds_ring->phys_addr, GFP_KERNEL);
-		if (addr == NULL) {
-			dev_err(&pdev->dev,
-				"failed to allocate sds ring [%d]\n", ring);
-			err = -ENOMEM;
-			goto err_out_free;
-		}
-		sds_ring->desc_head = addr;
-	}
-
-	return 0;
-
-err_out_free:
-	qlcnic_free_hw_resources(adapter);
-	return err;
-}
-
-int qlcnic_fw_create_ctx(struct qlcnic_adapter *adapter)
-{
-	int i, err, ring;
-
-	if (adapter->flags & QLCNIC_NEED_FLR) {
-		pci_reset_function(adapter->pdev);
-		adapter->flags &= ~QLCNIC_NEED_FLR;
-	}
-
-	err = adapter->ahw->hw_ops->create_rx_ctx(adapter);
-	if (err)
-		return err;
-
-	for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
-		err = adapter->ahw->hw_ops->create_tx_ctx(adapter,
-			 &adapter->tx_ring[ring], ring);
-		if (err) {
-			qlcnic_fw_cmd_destroy_rx_ctx(adapter);
-			if (ring == 0)
-				return err;
-			for (i = 0; i < ring; i++)
-				qlcnic_fw_cmd_destroy_tx_ctx(adapter,
-					 &adapter->tx_ring[i]);
-			return err;
-		}
-	}
-
-	set_bit(__QLCNIC_FW_ATTACHED, &adapter->state);
-	return 0;
-}
-
-void qlcnic_fw_destroy_ctx(struct qlcnic_adapter *adapter)
-{
-	int ring;
-
-	if (test_and_clear_bit(__QLCNIC_FW_ATTACHED, &adapter->state)) {
-		qlcnic_fw_cmd_destroy_rx_ctx(adapter);
-		for (ring = 0; ring < adapter->max_drv_tx_rings; ring++)
-			qlcnic_fw_cmd_destroy_tx_ctx(adapter,
-					&adapter->tx_ring[ring]);
-
-		/* Allow dma queues to drain after context reset */
-		msleep(20);
-	}
-}
-
-void qlcnic_free_hw_resources(struct qlcnic_adapter *adapter)
-{
-	struct qlcnic_recv_context *recv_ctx;
-	struct qlcnic_host_rds_ring *rds_ring;
-	struct qlcnic_host_sds_ring *sds_ring;
-	struct qlcnic_host_tx_ring *tx_ring;
-	int ring;
-
-	recv_ctx = adapter->recv_ctx;
-
-	for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
-		tx_ring = &adapter->tx_ring[ring];
-		if (tx_ring->hw_consumer != NULL) {
-			dma_free_coherent(&adapter->pdev->dev,
-					sizeof(u32),
-					tx_ring->hw_consumer,
-					tx_ring->hw_cons_phys_addr);
-			tx_ring->hw_consumer = NULL;
-		}
-
-		if (tx_ring->desc_head != NULL) {
-			dma_free_coherent(&adapter->pdev->dev,
-					TX_DESC_RINGSIZE(tx_ring),
-					tx_ring->desc_head, tx_ring->phys_addr);
-			tx_ring->desc_head = NULL;
-		}
-	}
-
-	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
-		rds_ring = &recv_ctx->rds_rings[ring];
-
-		if (rds_ring->desc_head != NULL) {
-			dma_free_coherent(&adapter->pdev->dev,
-					RCV_DESC_RINGSIZE(rds_ring),
-					rds_ring->desc_head,
-					rds_ring->phys_addr);
-			rds_ring->desc_head = NULL;
-		}
-	}
-
-	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
-		sds_ring = &recv_ctx->sds_rings[ring];
-
-		if (sds_ring->desc_head != NULL) {
-			dma_free_coherent(&adapter->pdev->dev,
-				STATUS_DESC_RINGSIZE(sds_ring),
-				sds_ring->desc_head,
-				sds_ring->phys_addr);
-			sds_ring->desc_head = NULL;
-		}
-	}
-}
-
-/* Get MAC address of a NIC partition */
-int qlcnic_get_mac_address(struct qlcnic_adapter *adapter, u8 *mac)
-{
-	int err, i;
-	struct qlcnic_cmd_args cmd;
-	u32 mac_low, mac_high;
-
-	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
-						QLCNIC_CMD_MAC_ADDRESS);
-	cmd.req.arg[1] = adapter->ahw->pci_func | BIT_8;
-	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
-
-	if (err == QLCNIC_RCODE_SUCCESS) {
-		mac_low = cmd.rsp.arg[1];
-		mac_high = cmd.rsp.arg[2];
-
-		for (i = 0; i < 2; i++)
-			mac[i] = (u8) (mac_high >> ((1 - i) * 8));
-		for (i = 2; i < 6; i++)
-			mac[i] = (u8) (mac_low >> ((5 - i) * 8));
-	} else {
-		dev_err(&adapter->pdev->dev,
-			"Failed to get mac address%d\n", err);
-		err = -EIO;
-	}
-	qlcnic_free_mbx_args(&cmd);
-	return err;
-}
-
-/* Get info of a NIC partition */
-int qlcnic_get_nic_info(struct qlcnic_adapter *adapter,
-				struct qlcnic_info *npar_info, u8 func_id)
-{
-	int	err;
-	dma_addr_t nic_dma_t;
-	const struct qlcnic_info *nic_info;
-	void *nic_info_addr;
-	struct qlcnic_cmd_args cmd;
-	size_t	nic_size = sizeof(struct qlcnic_info);
-
-	nic_info_addr = dma_alloc_coherent(&adapter->pdev->dev, nic_size,
-				&nic_dma_t, GFP_KERNEL);
-	if (!nic_info_addr)
-		return -ENOMEM;
-	memset(nic_info_addr, 0, nic_size);
-
-	nic_info = nic_info_addr;
-
-	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
-					QLCNIC_CMD_GET_NIC_INFO);
-	cmd.req.arg[1] = MSD(nic_dma_t);
-	cmd.req.arg[2] = LSD(nic_dma_t);
-	cmd.req.arg[3] = (func_id << 16 | nic_size);
-	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
-	if (err == QLCNIC_RCODE_SUCCESS)
-		qlcnic_set_npar_data(adapter, nic_info, npar_info);
-	else {
-		dev_err(&adapter->pdev->dev,
-			"Failed to get nic info%d\n", err);
-		err = -EIO;
-	}
-
-	dma_free_coherent(&adapter->pdev->dev, nic_size, nic_info_addr,
-		nic_dma_t);
-	qlcnic_free_mbx_args(&cmd);
-
-	return err;
-}
-
-/* Configure a NIC partition */
-int qlcnic_set_nic_info(struct qlcnic_adapter *adapter, struct qlcnic_info *nic)
-{
-	int err = -EIO;
-	dma_addr_t nic_dma_t;
-	void *nic_info_addr;
-	struct qlcnic_cmd_args cmd;
-	struct qlcnic_info *nic_info;
-	size_t nic_size = sizeof(struct qlcnic_info);
-
-	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
-		return err;
-
-	nic_info_addr = dma_alloc_coherent(&adapter->pdev->dev, nic_size,
-			&nic_dma_t, GFP_KERNEL);
-	if (!nic_info_addr)
-		return -ENOMEM;
-
-	memset(nic_info_addr, 0, nic_size);
-	nic_info = nic_info_addr;
-
-	nic_info->pci_func = cpu_to_le16(nic->pci_func);
-	nic_info->op_mode = cpu_to_le16(nic->op_mode);
-	nic_info->phys_port = cpu_to_le16(nic->phys_port);
-	nic_info->switch_mode = cpu_to_le16(nic->switch_mode);
-	nic_info->capabilities = cpu_to_le32(nic->capabilities);
-	nic_info->max_mac_filters = nic->max_mac_filters;
-	nic_info->max_tx_ques = cpu_to_le16(nic->max_tx_ques);
-	nic_info->max_rx_ques = cpu_to_le16(nic->max_rx_ques);
-	nic_info->min_tx_bw = cpu_to_le16(nic->min_tx_bw);
-	nic_info->max_tx_bw = cpu_to_le16(nic->max_tx_bw);
-
-	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
-						QLCNIC_CMD_SET_NIC_INFO);
-	cmd.req.arg[1] = MSD(nic_dma_t);
-	cmd.req.arg[2] = LSD(nic_dma_t);
-	cmd.req.arg[3] = ((nic->pci_func << 16) | nic_size);
-	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
-
-	if (err != QLCNIC_RCODE_SUCCESS) {
-		dev_err(&adapter->pdev->dev,
-			"Failed to set nic info%d\n", err);
-		err = -EIO;
-	}
-
-	dma_free_coherent(&adapter->pdev->dev, nic_size, nic_info_addr,
-		nic_dma_t);
-	qlcnic_free_mbx_args(&cmd);
-
-	return err;
-}
-
-/* Get PCI Info of a partition */
-int qlcnic_get_pci_info(struct qlcnic_adapter *adapter,
-				struct qlcnic_pci_info *pci_info)
-{
-	int err = 0, i;
-	struct qlcnic_cmd_args cmd;
-	dma_addr_t pci_info_dma_t;
-	struct qlcnic_pci_info *npar;
-	void *pci_info_addr;
-	size_t npar_size = sizeof(struct qlcnic_pci_info);
-	size_t pci_size = npar_size * QLCNIC_MAX_PCI_FUNC;
-
-	pci_info_addr = dma_alloc_coherent(&adapter->pdev->dev, pci_size,
-			&pci_info_dma_t, GFP_KERNEL);
-	if (!pci_info_addr)
-		return -ENOMEM;
-	memset(pci_info_addr, 0, pci_size);
-
-	npar = pci_info_addr;
-	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
-						QLCNIC_CMD_GET_PCI_INFO);
-	cmd.req.arg[1] = MSD(pci_info_dma_t);
-	cmd.req.arg[2] = LSD(pci_info_dma_t);
-	cmd.req.arg[3] = pci_size;
-	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
-
-	adapter->ahw->act_pci_func = 0;
-	if (err == QLCNIC_RCODE_SUCCESS) {
-		for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++, npar++, pci_info++) {
-			pci_info->id = le16_to_cpu(npar->id);
-			pci_info->active = le16_to_cpu(npar->active);
-			pci_info->type = le16_to_cpu(npar->type);
-			if (pci_info->type == QLCNIC_TYPE_NIC)
-				adapter->ahw->act_pci_func++;
-			pci_info->default_port =
-				le16_to_cpu(npar->default_port);
-			pci_info->tx_min_bw =
-				le16_to_cpu(npar->tx_min_bw);
-			pci_info->tx_max_bw =
-				le16_to_cpu(npar->tx_max_bw);
-			memcpy(pci_info->mac, npar->mac, ETH_ALEN);
-		}
-	} else {
-		dev_err(&adapter->pdev->dev,
-			"Failed to get PCI Info%d\n", err);
-		err = -EIO;
-	}
-
-	dma_free_coherent(&adapter->pdev->dev, pci_size, pci_info_addr,
-		pci_info_dma_t);
-	qlcnic_free_mbx_args(&cmd);
-
-	return err;
-}
-
-/* Configure eSwitch for port mirroring */
-int qlcnic_config_port_mirroring(struct qlcnic_adapter *adapter, u8 id,
-				u8 enable_mirroring, u8 pci_func)
-{
-	int err = -EIO;
-	u32 arg1;
-	struct qlcnic_cmd_args cmd;
-
-	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC ||
-		!(adapter->eswitch[id].flags & QLCNIC_SWITCH_ENABLE))
-		return err;
-
-	arg1 = id | (enable_mirroring ? BIT_4 : 0);
-	arg1 |= pci_func << 8;
-
-	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
-					QLCNIC_CMD_SET_PORTMIRRORING);
-	cmd.req.arg[1] = arg1;
-	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
-
-	if (err != QLCNIC_RCODE_SUCCESS)
-		dev_err(&adapter->pdev->dev,
-			"Failed to configure port mirroring%d on eswitch:%d\n",
-			pci_func, id);
-	else
-		dev_info(&adapter->pdev->dev,
-			"Configured eSwitch %d for port mirroring:%d\n",
-			id, pci_func);
-	qlcnic_free_mbx_args(&cmd);
-
-	return err;
-}
-
-int qlcnic_get_port_stats(struct qlcnic_adapter *adapter, const u8 func,
-		const u8 rx_tx, struct __qlcnic_esw_statistics *esw_stats) {
-
-	size_t stats_size = sizeof(struct __qlcnic_esw_statistics);
-	struct __qlcnic_esw_statistics *stats;
-	dma_addr_t stats_dma_t;
-	void *stats_addr;
-	u32 arg1;
-	struct qlcnic_cmd_args cmd;
-	int err;
-
-	if (esw_stats == NULL)
-		return -ENOMEM;
-
-	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC &&
-		func != adapter->ahw->pci_func) {
-		dev_err(&adapter->pdev->dev,
-			"Not privilege to query stats for func=%d", func);
-		return -EIO;
-	}
-
-	stats_addr = dma_alloc_coherent(&adapter->pdev->dev, stats_size,
-			&stats_dma_t, GFP_KERNEL);
-	if (!stats_addr) {
-		dev_err(&adapter->pdev->dev, "Unable to allocate memory\n");
-		return -ENOMEM;
-	}
-	memset(stats_addr, 0, stats_size);
-
-	arg1 = func | QLCNIC_STATS_VERSION << 8 | QLCNIC_STATS_PORT << 12;
-	arg1 |= rx_tx << 15 | stats_size << 16;
-
-	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
-					QLCNIC_CMD_GET_ESWITCH_STATS);
-	cmd.req.arg[1] = arg1;
-	cmd.req.arg[2] = MSD(stats_dma_t);
-	cmd.req.arg[3] = LSD(stats_dma_t);
-	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
-
-	if (!err) {
-		stats = stats_addr;
-		esw_stats->context_id = le16_to_cpu(stats->context_id);
-		esw_stats->version = le16_to_cpu(stats->version);
-		esw_stats->size = le16_to_cpu(stats->size);
-		esw_stats->multicast_frames =
-				le64_to_cpu(stats->multicast_frames);
-		esw_stats->broadcast_frames =
-				le64_to_cpu(stats->broadcast_frames);
-		esw_stats->unicast_frames = le64_to_cpu(stats->unicast_frames);
-		esw_stats->dropped_frames = le64_to_cpu(stats->dropped_frames);
-		esw_stats->local_frames = le64_to_cpu(stats->local_frames);
-		esw_stats->errors = le64_to_cpu(stats->errors);
-		esw_stats->numbytes = le64_to_cpu(stats->numbytes);
-	}
-
-	dma_free_coherent(&adapter->pdev->dev, stats_size, stats_addr,
-		stats_dma_t);
-	qlcnic_free_mbx_args(&cmd);
-
-	return err;
-}
-
-/* This routine will retrieve the MAC statistics from firmware */
-int qlcnic_get_mac_stats(struct qlcnic_adapter *adapter,
-		struct qlcnic_mac_statistics *mac_stats)
-{
-	struct qlcnic_mac_statistics *stats;
-	struct qlcnic_cmd_args cmd;
-	size_t stats_size = sizeof(struct qlcnic_mac_statistics);
-	dma_addr_t stats_dma_t;
-	void *stats_addr;
-	int err;
-
-	if (mac_stats == NULL)
-		return -ENOMEM;
-
-	stats_addr = dma_alloc_coherent(&adapter->pdev->dev, stats_size,
-			&stats_dma_t, GFP_KERNEL);
-	if (!stats_addr) {
-		dev_err(&adapter->pdev->dev,
-			"%s: Unable to allocate memory.\n", __func__);
-		return -ENOMEM;
-	}
-	memset(stats_addr, 0, stats_size);
-	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
-					QLCNIC_CMD_GET_MAC_STATS);
-	cmd.req.arg[1] = stats_size << 16;
-	cmd.req.arg[2] = MSD(stats_dma_t);
-	cmd.req.arg[3] = LSD(stats_dma_t);
-	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
-	if (!err) {
-		stats = stats_addr;
-		mac_stats->mac_tx_frames = le64_to_cpu(stats->mac_tx_frames);
-		mac_stats->mac_tx_bytes = le64_to_cpu(stats->mac_tx_bytes);
-		mac_stats->mac_tx_mcast_pkts =
-					le64_to_cpu(stats->mac_tx_mcast_pkts);
-		mac_stats->mac_tx_bcast_pkts =
-					le64_to_cpu(stats->mac_tx_bcast_pkts);
-		mac_stats->mac_rx_frames = le64_to_cpu(stats->mac_rx_frames);
-		mac_stats->mac_rx_bytes = le64_to_cpu(stats->mac_rx_bytes);
-		mac_stats->mac_rx_mcast_pkts =
-					le64_to_cpu(stats->mac_rx_mcast_pkts);
-		mac_stats->mac_rx_length_error =
-				le64_to_cpu(stats->mac_rx_length_error);
-		mac_stats->mac_rx_length_small =
-				le64_to_cpu(stats->mac_rx_length_small);
-		mac_stats->mac_rx_length_large =
-				le64_to_cpu(stats->mac_rx_length_large);
-		mac_stats->mac_rx_jabber = le64_to_cpu(stats->mac_rx_jabber);
-		mac_stats->mac_rx_dropped = le64_to_cpu(stats->mac_rx_dropped);
-		mac_stats->mac_FCS_error = le64_to_cpu(stats->mac_FCS_error);
-	} else {
-		dev_err(&adapter->pdev->dev,
-			"%s: Get mac stats failed, err=%d.\n", __func__, err);
-	}
-
-	dma_free_coherent(&adapter->pdev->dev, stats_size, stats_addr,
-		stats_dma_t);
-	qlcnic_free_mbx_args(&cmd);
-	return err;
-}
-
-int qlcnic_get_eswitch_stats(struct qlcnic_adapter *adapter, const u8 eswitch,
-		const u8 rx_tx, struct __qlcnic_esw_statistics *esw_stats) {
-
-	struct __qlcnic_esw_statistics port_stats;
-	u8 i;
-	int ret = -EIO;
-
-	if (esw_stats == NULL)
-		return -ENOMEM;
-	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
-		return -EIO;
-	if (adapter->npars == NULL)
-		return -EIO;
-
-	memset(esw_stats, 0, sizeof(u64));
-	esw_stats->unicast_frames = QLCNIC_STATS_NOT_AVAIL;
-	esw_stats->multicast_frames = QLCNIC_STATS_NOT_AVAIL;
-	esw_stats->broadcast_frames = QLCNIC_STATS_NOT_AVAIL;
-	esw_stats->dropped_frames = QLCNIC_STATS_NOT_AVAIL;
-	esw_stats->errors = QLCNIC_STATS_NOT_AVAIL;
-	esw_stats->local_frames = QLCNIC_STATS_NOT_AVAIL;
-	esw_stats->numbytes = QLCNIC_STATS_NOT_AVAIL;
-	esw_stats->context_id = eswitch;
-
-	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
-		if (adapter->npars[i].phy_port != eswitch)
-			continue;
-
-		memset(&port_stats, 0, sizeof(struct __qlcnic_esw_statistics));
-		if (qlcnic_get_port_stats(adapter, i, rx_tx, &port_stats))
-			continue;
-
-		esw_stats->size = port_stats.size;
-		esw_stats->version = port_stats.version;
-		QLCNIC_ADD_ESW_STATS(esw_stats->unicast_frames,
-						port_stats.unicast_frames);
-		QLCNIC_ADD_ESW_STATS(esw_stats->multicast_frames,
-						port_stats.multicast_frames);
-		QLCNIC_ADD_ESW_STATS(esw_stats->broadcast_frames,
-						port_stats.broadcast_frames);
-		QLCNIC_ADD_ESW_STATS(esw_stats->dropped_frames,
-						port_stats.dropped_frames);
-		QLCNIC_ADD_ESW_STATS(esw_stats->errors,
-						port_stats.errors);
-		QLCNIC_ADD_ESW_STATS(esw_stats->local_frames,
-						port_stats.local_frames);
-		QLCNIC_ADD_ESW_STATS(esw_stats->numbytes,
-						port_stats.numbytes);
-		ret = 0;
-	}
-	return ret;
-}
-
-int qlcnic_clear_esw_stats(struct qlcnic_adapter *adapter, const u8 func_esw,
-		const u8 port, const u8 rx_tx)
-{
-	int err;
-	u32 arg1;
-	struct qlcnic_cmd_args cmd;
-
-	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
-		return -EIO;
-
-	if (func_esw == QLCNIC_STATS_PORT) {
-		if (port >= QLCNIC_MAX_PCI_FUNC)
-			goto err_ret;
-	} else if (func_esw == QLCNIC_STATS_ESWITCH) {
-		if (port >= QLCNIC_NIU_MAX_XG_PORTS)
-			goto err_ret;
-	} else {
-		goto err_ret;
-	}
-
-	if (rx_tx > QLCNIC_QUERY_TX_COUNTER)
-		goto err_ret;
-
-	arg1 = port | QLCNIC_STATS_VERSION << 8 | func_esw << 12;
-	arg1 |= BIT_14 | rx_tx << 15;
-
-	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
-					QLCNIC_CMD_GET_ESWITCH_STATS);
-	cmd.req.arg[1] = arg1;
-	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
-	qlcnic_free_mbx_args(&cmd);
-	return err;
-
-err_ret:
-	dev_err(&adapter->pdev->dev,
-		"Invalid arguments func_esw=%d port=%d rx_ctx=%d\n",
-						func_esw, port, rx_tx);
-	return -EIO;
-}
-
-static int
-__qlcnic_get_eswitch_port_config(struct qlcnic_adapter *adapter,
-					u32 *arg1, u32 *arg2)
-{
-	int err = -EIO;
-	struct qlcnic_cmd_args cmd;
-	u8 pci_func;
-	pci_func = (*arg1 >> 8);
-
-	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
-		QLCNIC_CMD_GET_ESWITCH_PORT_CONFIG);
-	cmd.req.arg[1] = *arg1;
-	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
-	*arg1 = cmd.rsp.arg[1];
-	*arg2 = cmd.rsp.arg[2];
-	qlcnic_free_mbx_args(&cmd);
-
-	if (err == QLCNIC_RCODE_SUCCESS)
-		dev_info(&adapter->pdev->dev,
-			"eSwitch port config for pci func %d\n", pci_func);
-	else
-		dev_err(&adapter->pdev->dev,
-			"Failed to get eswitch port config for pci func %d\n",
-								pci_func);
-	return err;
-}
-/* Configure eSwitch port
-op_mode = 0 for setting default port behavior
-op_mode = 1 for setting  vlan id
-op_mode = 2 for deleting vlan id
-op_type = 0 for vlan_id
-op_type = 1 for port vlan_id
-*/
-int qlcnic_config_switch_port(struct qlcnic_adapter *adapter,
-		struct qlcnic_esw_func_cfg *esw_cfg)
-{
-	int err = -EIO;
-	u32 arg1, arg2 = 0;
-	struct qlcnic_cmd_args cmd;
-	u8 pci_func;
-
-	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
-		return err;
-	pci_func = esw_cfg->pci_func;
-	arg1 = (adapter->npars[pci_func].phy_port & BIT_0);
-	arg1 |= (pci_func << 8);
-
-	if (__qlcnic_get_eswitch_port_config(adapter, &arg1, &arg2))
-		return err;
-	arg1 &= ~(0x0ff << 8);
-	arg1 |= (pci_func << 8);
-	arg1 &= ~(BIT_2 | BIT_3);
-	switch (esw_cfg->op_mode) {
-	case QLCNIC_PORT_DEFAULTS:
-		arg1 |= (BIT_4 | BIT_6 | BIT_7);
-		arg2 |= (BIT_0 | BIT_1);
-		if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_TSO)
-			arg2 |= (BIT_2 | BIT_3);
-		if (!(esw_cfg->discard_tagged))
-			arg1 &= ~BIT_4;
-		if (!(esw_cfg->promisc_mode))
-			arg1 &= ~BIT_6;
-		if (!(esw_cfg->mac_override))
-			arg1 &= ~BIT_7;
-		if (!(esw_cfg->mac_anti_spoof))
-			arg2 &= ~BIT_0;
-		if (!(esw_cfg->offload_flags & BIT_0))
-			arg2 &= ~(BIT_1 | BIT_2 | BIT_3);
-		if (!(esw_cfg->offload_flags & BIT_1))
-			arg2 &= ~BIT_2;
-		if (!(esw_cfg->offload_flags & BIT_2))
-			arg2 &= ~BIT_3;
-		break;
-	case QLCNIC_ADD_VLAN:
-			arg1 |= (BIT_2 | BIT_5);
-			arg1 |= (esw_cfg->vlan_id << 16);
-			break;
-	case QLCNIC_DEL_VLAN:
-			arg1 |= (BIT_3 | BIT_5);
-			arg1 &= ~(0x0ffff << 16);
-			break;
-	default:
-		return err;
-	}
-
-	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
-					QLCNIC_CMD_CONFIGURE_ESWITCH);
-	cmd.req.arg[1] = arg1;
-	cmd.req.arg[2] = arg2;
-	err = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
-	qlcnic_free_mbx_args(&cmd);
-
-	if (err != QLCNIC_RCODE_SUCCESS)
-		dev_err(&adapter->pdev->dev,
-			"Failed to configure eswitch pci func %d\n", pci_func);
-	else
-		dev_info(&adapter->pdev->dev,
-			"Configured eSwitch for pci func %d\n", pci_func);
-
-	return err;
-}
-
-int
-qlcnic_get_eswitch_port_config(struct qlcnic_adapter *adapter,
-			struct qlcnic_esw_func_cfg *esw_cfg)
-{
-	u32 arg1, arg2;
-	u8 phy_port;
-	if (adapter->ahw->op_mode == QLCNIC_MGMT_FUNC)
-		phy_port = adapter->npars[esw_cfg->pci_func].phy_port;
-	else
-		phy_port = adapter->ahw->physical_port;
-	arg1 = phy_port;
-	arg1 |= (esw_cfg->pci_func << 8);
-	if (__qlcnic_get_eswitch_port_config(adapter, &arg1, &arg2))
-		return -EIO;
-
-	esw_cfg->discard_tagged = !!(arg1 & BIT_4);
-	esw_cfg->host_vlan_tag = !!(arg1 & BIT_5);
-	esw_cfg->promisc_mode = !!(arg1 & BIT_6);
-	esw_cfg->mac_override = !!(arg1 & BIT_7);
-	esw_cfg->vlan_id = LSW(arg1 >> 16);
-	esw_cfg->mac_anti_spoof = (arg2 & 0x1);
-	esw_cfg->offload_flags = ((arg2 >> 1) & 0x7);
-
-	return 0;
-}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
index 8264722..ece5825 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
@@ -554,10 +554,10 @@ static const u32 QLCNIC_MS_READ_DATA[] = {
 #define CRB_XG_STATE_P3P		(QLCNIC_REG(0x98))
 #define CRB_PF_LINK_SPEED_1		(QLCNIC_REG(0xe8))
 
-
-#define CRB_DRIVER_VERSION		(QLCNIC_REG(0x2a0))
-
-#define CRB_FW_CAPABILITIES_2		(QLCNIC_CAM_RAM(0x12c))
+#define CRB_DRIVER_VERSION	(QLCNIC_REG(0x2a0))
+#define CRB_FW_CAPABILITIES_1	(QLCNIC_CAM_RAM(0x128))
+#define CRB_FW_CAPABILITIES_2	(QLCNIC_CAM_RAM(0x12c))
+#define CRB_MAC_BLOCK_START	(QLCNIC_CAM_RAM(0x1c0))
 
 /*
  * CrbPortPhanCntrHi/Lo is used to pass the address of HostPhantomIndex address
@@ -727,8 +727,8 @@ struct qlcnic_legacy_intr_set {
 #define FLASH_ROM_WINDOW	0x42110030
 #define FLASH_ROM_DATA		0x42150000
 
-#define QLCNIC_FW_DUMP_REG1	0x00130060
-#define QLCNIC_FW_DUMP_REG2	0x001e0000
+#define QLCNIC_CRB_WINDOW_2M		0x00130060
+#define QLCNIC_INDIRECT_MEM_START	0x001e0000
 #define QLCNIC_FLASH_SEM2_LK	0x0013C010
 #define QLCNIC_FLASH_SEM2_ULK	0x0013C014
 #define QLCNIC_FLASH_LOCK_ID	0x001B2100
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
deleted file mode 100644
index 958ad02..0000000
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ /dev/null
@@ -1,1431 +0,0 @@
-/*
- * QLogic qlcnic NIC Driver
- * Copyright (c)  2009-2010 QLogic Corporation
- *
- * See LICENSE.qlcnic for copyright and licensing details.
- */
-
-#include "qlcnic.h"
-#include "qlcnic_hdr.h"
-#include "qlcnic_hw.h"
-
-#include <linux/slab.h>
-#include <net/ip.h>
-#include <linux/bitops.h>
-
-#ifndef readq
-static inline u64 readq(void __iomem *addr)
-{
-	return readl(addr) | (((u64) readl(addr + 4)) << 32LL);
-}
-#endif
-
-#ifndef writeq
-static inline void writeq(u64 val, void __iomem *addr)
-{
-	writel(((u32) (val)), (addr));
-	writel(((u32) (val >> 32)), (addr + 4));
-}
-#endif
-
-static const struct crb_128M_2M_block_map
-crb_128M_2M_map[64] __cacheline_aligned_in_smp = {
-    {{{0, 0,         0,         0} } },		/* 0: PCI */
-    {{{1, 0x0100000, 0x0102000, 0x120000},	/* 1: PCIE */
-	  {1, 0x0110000, 0x0120000, 0x130000},
-	  {1, 0x0120000, 0x0122000, 0x124000},
-	  {1, 0x0130000, 0x0132000, 0x126000},
-	  {1, 0x0140000, 0x0142000, 0x128000},
-	  {1, 0x0150000, 0x0152000, 0x12a000},
-	  {1, 0x0160000, 0x0170000, 0x110000},
-	  {1, 0x0170000, 0x0172000, 0x12e000},
-	  {0, 0x0000000, 0x0000000, 0x000000},
-	  {0, 0x0000000, 0x0000000, 0x000000},
-	  {0, 0x0000000, 0x0000000, 0x000000},
-	  {0, 0x0000000, 0x0000000, 0x000000},
-	  {0, 0x0000000, 0x0000000, 0x000000},
-	  {0, 0x0000000, 0x0000000, 0x000000},
-	  {1, 0x01e0000, 0x01e0800, 0x122000},
-	  {0, 0x0000000, 0x0000000, 0x000000} } },
-	{{{1, 0x0200000, 0x0210000, 0x180000} } },/* 2: MN */
-    {{{0, 0,         0,         0} } },	    /* 3: */
-    {{{1, 0x0400000, 0x0401000, 0x169000} } },/* 4: P2NR1 */
-    {{{1, 0x0500000, 0x0510000, 0x140000} } },/* 5: SRE   */
-    {{{1, 0x0600000, 0x0610000, 0x1c0000} } },/* 6: NIU   */
-    {{{1, 0x0700000, 0x0704000, 0x1b8000} } },/* 7: QM    */
-    {{{1, 0x0800000, 0x0802000, 0x170000},  /* 8: SQM0  */
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {1, 0x08f0000, 0x08f2000, 0x172000} } },
-    {{{1, 0x0900000, 0x0902000, 0x174000},	/* 9: SQM1*/
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {1, 0x09f0000, 0x09f2000, 0x176000} } },
-    {{{0, 0x0a00000, 0x0a02000, 0x178000},	/* 10: SQM2*/
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {1, 0x0af0000, 0x0af2000, 0x17a000} } },
-    {{{0, 0x0b00000, 0x0b02000, 0x17c000},	/* 11: SQM3*/
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {0, 0x0000000, 0x0000000, 0x000000},
-      {1, 0x0bf0000, 0x0bf2000, 0x17e000} } },
-	{{{1, 0x0c00000, 0x0c04000, 0x1d4000} } },/* 12: I2Q */
-	{{{1, 0x0d00000, 0x0d04000, 0x1a4000} } },/* 13: TMR */
-	{{{1, 0x0e00000, 0x0e04000, 0x1a0000} } },/* 14: ROMUSB */
-	{{{1, 0x0f00000, 0x0f01000, 0x164000} } },/* 15: PEG4 */
-	{{{0, 0x1000000, 0x1004000, 0x1a8000} } },/* 16: XDMA */
-	{{{1, 0x1100000, 0x1101000, 0x160000} } },/* 17: PEG0 */
-	{{{1, 0x1200000, 0x1201000, 0x161000} } },/* 18: PEG1 */
-	{{{1, 0x1300000, 0x1301000, 0x162000} } },/* 19: PEG2 */
-	{{{1, 0x1400000, 0x1401000, 0x163000} } },/* 20: PEG3 */
-	{{{1, 0x1500000, 0x1501000, 0x165000} } },/* 21: P2ND */
-	{{{1, 0x1600000, 0x1601000, 0x166000} } },/* 22: P2NI */
-	{{{0, 0,         0,         0} } },	/* 23: */
-	{{{0, 0,         0,         0} } },	/* 24: */
-	{{{0, 0,         0,         0} } },	/* 25: */
-	{{{0, 0,         0,         0} } },	/* 26: */
-	{{{0, 0,         0,         0} } },	/* 27: */
-	{{{0, 0,         0,         0} } },	/* 28: */
-	{{{1, 0x1d00000, 0x1d10000, 0x190000} } },/* 29: MS */
-    {{{1, 0x1e00000, 0x1e01000, 0x16a000} } },/* 30: P2NR2 */
-    {{{1, 0x1f00000, 0x1f10000, 0x150000} } },/* 31: EPG */
-	{{{0} } },				/* 32: PCI */
-	{{{1, 0x2100000, 0x2102000, 0x120000},	/* 33: PCIE */
-	  {1, 0x2110000, 0x2120000, 0x130000},
-	  {1, 0x2120000, 0x2122000, 0x124000},
-	  {1, 0x2130000, 0x2132000, 0x126000},
-	  {1, 0x2140000, 0x2142000, 0x128000},
-	  {1, 0x2150000, 0x2152000, 0x12a000},
-	  {1, 0x2160000, 0x2170000, 0x110000},
-	  {1, 0x2170000, 0x2172000, 0x12e000},
-	  {0, 0x0000000, 0x0000000, 0x000000},
-	  {0, 0x0000000, 0x0000000, 0x000000},
-	  {0, 0x0000000, 0x0000000, 0x000000},
-	  {0, 0x0000000, 0x0000000, 0x000000},
-	  {0, 0x0000000, 0x0000000, 0x000000},
-	  {0, 0x0000000, 0x0000000, 0x000000},
-	  {0, 0x0000000, 0x0000000, 0x000000},
-	  {0, 0x0000000, 0x0000000, 0x000000} } },
-	{{{1, 0x2200000, 0x2204000, 0x1b0000} } },/* 34: CAM */
-	{{{0} } },				/* 35: */
-	{{{0} } },				/* 36: */
-	{{{0} } },				/* 37: */
-	{{{0} } },				/* 38: */
-	{{{0} } },				/* 39: */
-	{{{1, 0x2800000, 0x2804000, 0x1a4000} } },/* 40: TMR */
-	{{{1, 0x2900000, 0x2901000, 0x16b000} } },/* 41: P2NR3 */
-	{{{1, 0x2a00000, 0x2a00400, 0x1ac400} } },/* 42: RPMX1 */
-	{{{1, 0x2b00000, 0x2b00400, 0x1ac800} } },/* 43: RPMX2 */
-	{{{1, 0x2c00000, 0x2c00400, 0x1acc00} } },/* 44: RPMX3 */
-	{{{1, 0x2d00000, 0x2d00400, 0x1ad000} } },/* 45: RPMX4 */
-	{{{1, 0x2e00000, 0x2e00400, 0x1ad400} } },/* 46: RPMX5 */
-	{{{1, 0x2f00000, 0x2f00400, 0x1ad800} } },/* 47: RPMX6 */
-	{{{1, 0x3000000, 0x3000400, 0x1adc00} } },/* 48: RPMX7 */
-	{{{0, 0x3100000, 0x3104000, 0x1a8000} } },/* 49: XDMA */
-	{{{1, 0x3200000, 0x3204000, 0x1d4000} } },/* 50: I2Q */
-	{{{1, 0x3300000, 0x3304000, 0x1a0000} } },/* 51: ROMUSB */
-	{{{0} } },				/* 52: */
-	{{{1, 0x3500000, 0x3500400, 0x1ac000} } },/* 53: RPMX0 */
-	{{{1, 0x3600000, 0x3600400, 0x1ae000} } },/* 54: RPMX8 */
-	{{{1, 0x3700000, 0x3700400, 0x1ae400} } },/* 55: RPMX9 */
-	{{{1, 0x3800000, 0x3804000, 0x1d0000} } },/* 56: OCM0 */
-	{{{1, 0x3900000, 0x3904000, 0x1b4000} } },/* 57: CRYPTO */
-	{{{1, 0x3a00000, 0x3a04000, 0x1d8000} } },/* 58: SMB */
-	{{{0} } },				/* 59: I2C0 */
-	{{{0} } },				/* 60: I2C1 */
-	{{{1, 0x3d00000, 0x3d04000, 0x1d8000} } },/* 61: LPC */
-	{{{1, 0x3e00000, 0x3e01000, 0x167000} } },/* 62: P2NC */
-	{{{1, 0x3f00000, 0x3f01000, 0x168000} } }	/* 63: P2NR0 */
-};
-
-/*
- * top 12 bits of crb internal address (hub, agent)
- */
-static const unsigned crb_hub_agt[64] = {
-	0,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_PS,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_MN,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_MS,
-	0,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_SRE,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_NIU,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_QMN,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_SQN0,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_SQN1,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_SQN2,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_SQN3,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_I2Q,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_TIMR,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_ROMUSB,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_PGN4,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_XDMA,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_PGN0,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_PGN1,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_PGN2,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_PGN3,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_PGND,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_PGNI,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_PGS0,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_PGS1,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_PGS2,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_PGS3,
-	0,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_PGSI,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_SN,
-	0,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_EG,
-	0,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_PS,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_CAM,
-	0,
-	0,
-	0,
-	0,
-	0,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_TIMR,
-	0,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_RPMX1,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_RPMX2,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_RPMX3,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_RPMX4,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_RPMX5,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_RPMX6,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_RPMX7,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_XDMA,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_I2Q,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_ROMUSB,
-	0,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_RPMX0,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_RPMX8,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_RPMX9,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_OCM0,
-	0,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_SMB,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_I2C0,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_I2C1,
-	0,
-	QLCNIC_HW_CRB_HUB_AGT_ADR_PGNC,
-	0,
-};
-
-static const u32 msi_tgt_status[8] = {
-	ISR_INT_TARGET_STATUS, ISR_INT_TARGET_STATUS_F1,
-	ISR_INT_TARGET_STATUS_F2, ISR_INT_TARGET_STATUS_F3,
-	ISR_INT_TARGET_STATUS_F4, ISR_INT_TARGET_STATUS_F5,
-	ISR_INT_TARGET_STATUS_F6, ISR_INT_TARGET_STATUS_F7
-};
-
-/*  PCI Windowing for DDR regions.  */
-
-static void
-qlcnic_read_dump_reg(u32 addr, void __iomem *bar0, u32 *data)
-{
-	u32 dest;
-	void __iomem *val;
-
-	dest = addr & 0xFFFF0000;
-	val = bar0 + QLCNIC_FW_DUMP_REG1;
-	writel(dest, val);
-	readl(val);
-	val = bar0 + QLCNIC_FW_DUMP_REG2 + LSW(addr);
-	*data = readl(val);
-}
-
-static void
-qlcnic_write_dump_reg(u32 addr, void __iomem *bar0, u32 data)
-{
-	u32 dest;
-	void __iomem *val;
-
-	dest = addr & 0xFFFF0000;
-	val = bar0 + QLCNIC_FW_DUMP_REG1;
-	writel(dest, val);
-	readl(val);
-	val = bar0 + QLCNIC_FW_DUMP_REG2 + LSW(addr);
-	writel(data, val);
-	readl(val);
-}
-
-int
-qlcnic_pcie_sem_lock(struct qlcnic_adapter *adapter, int sem, u32 id_reg)
-{
-	int err, done = 0, timeout = 0;
-
-	while (!done) {
-		done = QLCRD32(adapter,
-			QLCNIC_PCIE_REG(PCIE_SEM_LOCK(sem)), &err);
-		if (done == 1)
-			break;
-		if (++timeout >= QLCNIC_PCIE_SEM_TIMEOUT) {
-			dev_err(&adapter->pdev->dev,
-				"Failed to acquire sem=%d lock; held by=%d\n",
-				sem,
-				id_reg ? QLCRD32(adapter, id_reg, &err) : -1);
-			return -EIO;
-		}
-		msleep(1);
-	}
-
-	if (id_reg)
-		QLCWR32(adapter, id_reg, adapter->portnum);
-
-	return 0;
-}
-
-u32 qlcnic_ind_rd(struct qlcnic_adapter *adapter, u32 addr)
-{
-	int err;
-	u32 data;
-
-	if (QLCNIC_IS_82XX(adapter))
-		qlcnic_read_dump_reg(addr, adapter->ahw->pci_base0, &data);
-	else
-		data = qlcnic_83xx_rd_reg_indirect(adapter, addr, &err);
-	return data;
-}
-
-void qlcnic_ind_wr(struct qlcnic_adapter *adapter, u32 addr, u32 data)
-{
-	if (QLCNIC_IS_82XX(adapter))
-		qlcnic_write_dump_reg(addr, adapter->ahw->pci_base0, data);
-	else
-		qlcnic_83xx_wrt_reg_indirect(adapter, addr, data);
-}
-
-void
-qlcnic_pcie_sem_unlock(struct qlcnic_adapter *adapter, int sem)
-{
-	int err;
-	QLCRD32(adapter, QLCNIC_PCIE_REG(PCIE_SEM_UNLOCK(sem)), &err);
-}
-
-static int
-qlcnic_send_cmd_descs(struct qlcnic_adapter *adapter,
-		struct cmd_desc_type0 *cmd_desc_arr, int nr_desc)
-{
-	u32 i, producer, consumer;
-	struct qlcnic_cmd_buffer *pbuf;
-	struct cmd_desc_type0 *cmd_desc;
-	struct qlcnic_host_tx_ring *tx_ring;
-
-	i = 0;
-
-	if (!test_bit(__QLCNIC_FW_ATTACHED, &adapter->state))
-		return -EIO;
-
-	tx_ring = adapter->tx_ring;
-	__netif_tx_lock_bh(tx_ring->txq);
-
-	producer = tx_ring->producer;
-	consumer = tx_ring->sw_consumer;
-
-	if (nr_desc >= qlcnic_tx_avail(tx_ring)) {
-		netif_tx_stop_queue(tx_ring->txq);
-		smp_mb();
-		if (qlcnic_tx_avail(tx_ring) > nr_desc) {
-			if (qlcnic_tx_avail(tx_ring) > TX_STOP_THRESH)
-				netif_tx_wake_queue(tx_ring->txq);
-		} else {
-			adapter->stats.xmit_off++;
-			__netif_tx_unlock_bh(tx_ring->txq);
-			return -EBUSY;
-		}
-	}
-
-	do {
-		cmd_desc = &cmd_desc_arr[i];
-
-		pbuf = &tx_ring->cmd_buf_arr[producer];
-		pbuf->skb = NULL;
-		pbuf->frag_count = 0;
-
-		memcpy(&tx_ring->desc_head[producer],
-			&cmd_desc_arr[i], sizeof(struct cmd_desc_type0));
-
-		producer = get_next_index(producer, tx_ring->num_desc);
-		i++;
-
-	} while (i != nr_desc);
-
-	tx_ring->producer = producer;
-
-	qlcnic_update_cmd_producer(adapter, tx_ring);
-
-	__netif_tx_unlock_bh(tx_ring->txq);
-
-	return 0;
-}
-
-int
-qlcnic_sre_macaddr_change(struct qlcnic_adapter *adapter, u8 *addr,
-				__le16 vlan_id, u8 op)
-{
-	struct qlcnic_nic_req req;
-	struct qlcnic_mac_req *mac_req;
-	struct qlcnic_vlan_req *vlan_req;
-	u64 word;
-
-	memset(&req, 0, sizeof(struct qlcnic_nic_req));
-	req.qhdr = cpu_to_le64(QLCNIC_REQUEST << 23);
-
-	word = QLCNIC_MAC_EVENT | ((u64)adapter->portnum << 16);
-	req.req_hdr = cpu_to_le64(word);
-
-	mac_req = (struct qlcnic_mac_req *)&req.words[0];
-	mac_req->op = op;
-	memcpy(mac_req->mac_addr, addr, 6);
-
-	vlan_req = (struct qlcnic_vlan_req *)&req.words[1];
-	vlan_req->vlan_id = vlan_id;
-
-	return qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
-}
-
-static int qlcnic_nic_add_mac(struct qlcnic_adapter *adapter, const u8 *addr)
-{
-	struct list_head *head;
-	struct qlcnic_mac_list_s *cur;
-
-	/* look up if already exists */
-	list_for_each(head, &adapter->mac_list) {
-		cur = list_entry(head, struct qlcnic_mac_list_s, list);
-		if (memcmp(addr, cur->mac_addr, ETH_ALEN) == 0)
-			return 0;
-	}
-
-	cur = kzalloc(sizeof(struct qlcnic_mac_list_s), GFP_ATOMIC);
-	if (cur == NULL) {
-		dev_err(&adapter->netdev->dev,
-			"failed to add mac address filter\n");
-		return -ENOMEM;
-	}
-	memcpy(cur->mac_addr, addr, ETH_ALEN);
-
-	if (adapter->ahw->hw_ops->change_macvlan(adapter,
-				cur->mac_addr, 0, QLCNIC_MAC_ADD)) {
-		kfree(cur);
-		return -EIO;
-	}
-
-	list_add_tail(&cur->list, &adapter->mac_list);
-	return 0;
-}
-
-void qlcnic_set_multi(struct net_device *netdev)
-{
-	struct qlcnic_adapter *adapter = netdev_priv(netdev);
-	struct netdev_hw_addr *ha;
-	static const u8 bcast_addr[ETH_ALEN] = {
-		0xff, 0xff, 0xff, 0xff, 0xff, 0xff
-	};
-	u32 mode = VPORT_MISS_MODE_DROP;
-
-	if (!test_bit(__QLCNIC_FW_ATTACHED, &adapter->state))
-		return;
-
-	qlcnic_nic_add_mac(adapter, adapter->mac_addr);
-	qlcnic_nic_add_mac(adapter, bcast_addr);
-
-	if (netdev->flags & IFF_PROMISC) {
-		if (!(adapter->flags & QLCNIC_PROMISC_DISABLED))
-			mode = VPORT_MISS_MODE_ACCEPT_ALL;
-		goto send_fw_cmd;
-	}
-
-	if ((netdev->flags & IFF_ALLMULTI) ||
-	    (netdev_mc_count(netdev) > adapter->ahw->max_mc_count)) {
-		mode = VPORT_MISS_MODE_ACCEPT_MULTI;
-		goto send_fw_cmd;
-	}
-
-	if (!netdev_mc_empty(netdev)) {
-		netdev_for_each_mc_addr(ha, netdev) {
-			qlcnic_nic_add_mac(adapter, ha->addr);
-		}
-	}
-
-send_fw_cmd:
-	if (mode == VPORT_MISS_MODE_ACCEPT_ALL) {
-		qlcnic_alloc_lb_filters_mem(adapter);
-		adapter->mac_learn = 1;
-	} else {
-		adapter->mac_learn = 0;
-	}
-
-	adapter->ahw->hw_ops->config_promisc_mode(adapter, mode);
-}
-
-int qlcnic_nic_set_promisc(struct qlcnic_adapter *adapter, u32 mode)
-{
-	struct qlcnic_nic_req req;
-	u64 word;
-
-	memset(&req, 0, sizeof(struct qlcnic_nic_req));
-
-	req.qhdr = cpu_to_le64(QLCNIC_HOST_REQUEST << 23);
-
-	word = QLCNIC_H2C_OPCODE_SET_MAC_RECEIVE_MODE |
-			((u64)adapter->portnum << 16);
-	req.req_hdr = cpu_to_le64(word);
-
-	req.words[0] = cpu_to_le64(mode);
-
-	return qlcnic_send_cmd_descs(adapter,
-				(struct cmd_desc_type0 *)&req, 1);
-}
-
-void qlcnic_free_mac_list(struct qlcnic_adapter *adapter)
-{
-	struct qlcnic_mac_list_s *cur;
-	struct list_head *head = &adapter->mac_list;
-
-	while (!list_empty(head)) {
-		cur = list_entry(head->next, struct qlcnic_mac_list_s, list);
-		adapter->ahw->hw_ops->change_macvlan(adapter,
-				cur->mac_addr, 0, QLCNIC_MAC_DEL);
-		list_del(&cur->list);
-		kfree(cur);
-	}
-}
-
-void qlcnic_prune_lb_filters(struct qlcnic_adapter *adapter)
-{
-	struct qlcnic_filter *tmp_fil;
-	struct hlist_node *tmp_hnode, *n;
-	struct hlist_head *head;
-	int i;
-
-	for (i = 0; i < adapter->fhash.fmax; i++) {
-		head = &(adapter->fhash.fhead[i]);
-
-		hlist_for_each_entry_safe(tmp_fil, tmp_hnode, n, head, fnode)
-		{
-			if (jiffies >
-				(QLCNIC_FILTER_AGE * HZ + tmp_fil->ftime)) {
-				adapter->ahw->hw_ops->change_macvlan(adapter,
-					tmp_fil->faddr, tmp_fil->vlan_id,
-					tmp_fil->vlan_id ? QLCNIC_MAC_VLAN_DEL :
-					QLCNIC_MAC_DEL);
-				spin_lock_bh(&adapter->mac_learn_lock);
-				adapter->fhash.fnum--;
-				hlist_del(&tmp_fil->fnode);
-				spin_unlock_bh(&adapter->mac_learn_lock);
-				kfree(tmp_fil);
-			}
-		}
-	}
-}
-
-void qlcnic_delete_lb_filters(struct qlcnic_adapter *adapter)
-{
-	struct qlcnic_filter *tmp_fil;
-	struct hlist_node *tmp_hnode, *n;
-	struct hlist_head *head;
-	int i;
-
-	for (i = 0; i < adapter->fhash.fmax; i++) {
-		head = &(adapter->fhash.fhead[i]);
-
-		hlist_for_each_entry_safe(tmp_fil, tmp_hnode, n, head, fnode) {
-			adapter->ahw->hw_ops->change_macvlan(adapter,
-				tmp_fil->faddr, tmp_fil->vlan_id,
-				tmp_fil->vlan_id ?  QLCNIC_MAC_VLAN_DEL :
-				QLCNIC_MAC_DEL);
-			spin_lock_bh(&adapter->mac_learn_lock);
-			adapter->fhash.fnum--;
-			hlist_del(&tmp_fil->fnode);
-			spin_unlock_bh(&adapter->mac_learn_lock);
-			kfree(tmp_fil);
-		}
-	}
-}
-
-int qlcnic_set_fw_loopback(struct qlcnic_adapter *adapter, u8 flag)
-{
-	struct qlcnic_nic_req req;
-	int rv;
-
-	memset(&req, 0, sizeof(struct qlcnic_nic_req));
-
-	req.qhdr = cpu_to_le64(QLCNIC_HOST_REQUEST << 23);
-	req.req_hdr = cpu_to_le64(QLCNIC_H2C_OPCODE_CONFIG_LOOPBACK |
-		((u64) adapter->portnum << 16) | ((u64) 0x1 << 32));
-
-	req.words[0] = cpu_to_le64(flag);
-
-	rv = qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
-	if (rv != 0)
-		dev_err(&adapter->pdev->dev, "%sting loopback mode failed\n",
-				flag ? "Set" : "Reset");
-	return rv;
-}
-
-int qlcnic_set_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
-{
-	if (qlcnic_set_fw_loopback(adapter, mode))
-		return -EIO;
-
-	if (adapter->ahw->hw_ops->config_promisc_mode(adapter,
-		VPORT_MISS_MODE_ACCEPT_ALL)) {
-		qlcnic_set_fw_loopback(adapter, 0);
-		return -EIO;
-	}
-
-	msleep(1000);
-	return 0;
-}
-
-int qlcnic_clear_lb_mode(struct qlcnic_adapter *adapter, u8 mode)
-{
-	struct net_device *netdev = adapter->netdev;
-
-	mode = VPORT_MISS_MODE_DROP;
-	qlcnic_set_fw_loopback(adapter, 0);
-
-	if (netdev->flags & IFF_PROMISC)
-		mode = VPORT_MISS_MODE_ACCEPT_ALL;
-	else if (netdev->flags & IFF_ALLMULTI)
-		mode = VPORT_MISS_MODE_ACCEPT_MULTI;
-
-	adapter->ahw->hw_ops->config_promisc_mode(adapter, mode);
-	msleep(1000);
-	return 0;
-}
-
-/*
- * Send the interrupt coalescing parameter set by ethtool to the card.
- */
-void qlcnic_config_intr_coalesce(struct qlcnic_adapter *adapter)
-{
-	struct qlcnic_nic_req req;
-	int rv;
-
-	memset(&req, 0, sizeof(struct qlcnic_nic_req));
-
-	req.qhdr = cpu_to_le64(QLCNIC_HOST_REQUEST << 23);
-
-	req.req_hdr = cpu_to_le64(QLCNIC_CONFIG_INTR_COALESCE |
-		((u64) adapter->portnum << 16));
-
-	req.words[0] = cpu_to_le64(((u64) adapter->ahw->coal.flag) << 32);
-	req.words[2] = cpu_to_le64(adapter->ahw->coal.rx_packets |
-			((u64) adapter->ahw->coal.rx_time_us) << 16);
-	req.words[5] = cpu_to_le64(adapter->ahw->coal.timer_out |
-			((u64) adapter->ahw->coal.type) << 32 |
-			((u64) adapter->ahw->coal.sts_ring_mask) << 40);
-	rv = qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
-	if (rv != 0)
-		dev_err(&adapter->netdev->dev,
-			"Could not send interrupt coalescing parameters\n");
-}
-
-int qlcnic_config_hw_lro(struct qlcnic_adapter *adapter, int enable)
-{
-	struct qlcnic_nic_req req;
-	u64 word;
-	int rv;
-
-	if (!test_bit(__QLCNIC_FW_ATTACHED, &adapter->state))
-		return 0;
-
-	memset(&req, 0, sizeof(struct qlcnic_nic_req));
-
-	req.qhdr = cpu_to_le64(QLCNIC_HOST_REQUEST << 23);
-
-	word = QLCNIC_H2C_OPCODE_CONFIG_HW_LRO | ((u64)adapter->portnum << 16);
-	req.req_hdr = cpu_to_le64(word);
-
-	req.words[0] = cpu_to_le64(enable);
-
-	rv = qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
-	if (rv != 0)
-		dev_err(&adapter->netdev->dev,
-			"Could not send configure hw lro request\n");
-
-	return rv;
-}
-
-int qlcnic_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable)
-{
-	struct qlcnic_nic_req req;
-	u64 word;
-	int rv;
-
-	if (!!(adapter->flags & QLCNIC_BRIDGE_ENABLED) == enable)
-		return 0;
-
-	memset(&req, 0, sizeof(struct qlcnic_nic_req));
-
-	req.qhdr = cpu_to_le64(QLCNIC_HOST_REQUEST << 23);
-
-	word = QLCNIC_H2C_OPCODE_CONFIG_BRIDGING |
-		((u64)adapter->portnum << 16);
-	req.req_hdr = cpu_to_le64(word);
-
-	req.words[0] = cpu_to_le64(enable);
-
-	rv = qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
-	if (rv != 0)
-		dev_err(&adapter->netdev->dev,
-			"Could not send configure bridge mode request\n");
-
-	adapter->flags ^= QLCNIC_BRIDGE_ENABLED;
-
-	return rv;
-}
-
-int qlcnic_config_rss(struct qlcnic_adapter *adapter, int enable)
-{
-	struct qlcnic_nic_req req;
-	u64 word;
-	int i, rv;
-
-	static const u64 key[] = {
-		0xbeac01fa6a42b73bULL, 0x8030f20c77cb2da3ULL,
-		0xae7b30b4d0ca2bcbULL, 0x43a38fb04167253dULL,
-		0x255b0ec26d5a56daULL
-	};
-
-	memset(&req, 0, sizeof(struct qlcnic_nic_req));
-	req.qhdr = cpu_to_le64(QLCNIC_HOST_REQUEST << 23);
-
-	word = QLCNIC_H2C_OPCODE_CONFIG_RSS | ((u64)adapter->portnum << 16);
-	req.req_hdr = cpu_to_le64(word);
-
-	/*
-	 * RSS request:
-	 * bits 3-0: hash_method
-	 *      5-4: hash_type_ipv4
-	 *	7-6: hash_type_ipv6
-	 *	  8: enable
-	 *        9: use indirection table
-	 *    47-10: reserved
-	 *    63-48: indirection table mask
-	 */
-	word =  ((u64)(RSS_HASHTYPE_IP_TCP & 0x3) << 4) |
-		((u64)(RSS_HASHTYPE_IP_TCP & 0x3) << 6) |
-		((u64)(enable & 0x1) << 8) |
-		((0x7ULL) << 48);
-	req.words[0] = cpu_to_le64(word);
-	for (i = 0; i < 5; i++)
-		req.words[i+1] = cpu_to_le64(key[i]);
-
-	rv = qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
-	if (rv != 0)
-		dev_err(&adapter->netdev->dev, "could not configure RSS\n");
-
-	return rv;
-}
-
-void qlcnic_config_ipaddr(struct qlcnic_adapter *adapter, __be32 ip, int cmd)
-{
-	struct qlcnic_nic_req req;
-	struct qlcnic_ipaddr *ipa;
-	u64 word;
-	int rv;
-
-	memset(&req, 0, sizeof(struct qlcnic_nic_req));
-	req.qhdr = cpu_to_le64(QLCNIC_HOST_REQUEST << 23);
-
-	word = QLCNIC_H2C_OPCODE_CONFIG_IPADDR | ((u64)adapter->portnum << 16);
-	req.req_hdr = cpu_to_le64(word);
-
-	req.words[0] = cpu_to_le64(cmd);
-	ipa = (struct qlcnic_ipaddr *)&req.words[1];
-	ipa->ipv4 = ip;
-
-	rv = qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
-	if (rv != 0)
-		dev_err(&adapter->netdev->dev,
-				"could not notify %s IP 0x%x request\n",
-				(cmd == QLCNIC_IP_UP) ? "Add" : "Remove", ip);
-}
-
-int qlcnic_linkevent_request(struct qlcnic_adapter *adapter, int enable)
-{
-	struct qlcnic_nic_req req;
-	u64 word;
-	int rv;
-	memset(&req, 0, sizeof(struct qlcnic_nic_req));
-	req.qhdr = cpu_to_le64(QLCNIC_HOST_REQUEST << 23);
-
-	word = QLCNIC_H2C_OPCODE_GET_LINKEVENT | ((u64)adapter->portnum << 16);
-	req.req_hdr = cpu_to_le64(word);
-	req.words[0] = cpu_to_le64(enable | (enable << 8));
-	rv = qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
-	if (rv != 0)
-		dev_err(&adapter->netdev->dev,
-				"could not configure link notification\n");
-
-	return rv;
-}
-
-int qlcnic_send_lro_cleanup(struct qlcnic_adapter *adapter)
-{
-	struct qlcnic_nic_req req;
-	u64 word;
-	int rv;
-
-	if (!test_bit(__QLCNIC_FW_ATTACHED, &adapter->state))
-		return 0;
-
-	memset(&req, 0, sizeof(struct qlcnic_nic_req));
-	req.qhdr = cpu_to_le64(QLCNIC_HOST_REQUEST << 23);
-
-	word = QLCNIC_H2C_OPCODE_LRO_REQUEST |
-		((u64)adapter->portnum << 16) |
-		((u64)QLCNIC_LRO_REQUEST_CLEANUP << 56) ;
-
-	req.req_hdr = cpu_to_le64(word);
-
-	rv = qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
-	if (rv != 0)
-		dev_err(&adapter->netdev->dev,
-				 "could not cleanup lro flows\n");
-
-	return rv;
-}
-
-/*
- * qlcnic_change_mtu - Change the Maximum Transfer Unit
- * @returns 0 on success, negative on failure
- */
-
-int qlcnic_change_mtu(struct net_device *netdev, int mtu)
-{
-	struct qlcnic_adapter *adapter = netdev_priv(netdev);
-	int rc = 0;
-
-	if (mtu < P3P_MIN_MTU || mtu > P3P_MAX_MTU) {
-		dev_err(&adapter->netdev->dev, "%d bytes < mtu < %d bytes"
-			" not supported\n", P3P_MAX_MTU, P3P_MIN_MTU);
-		return -EINVAL;
-	}
-
-	rc = qlcnic_fw_cmd_set_mtu(adapter, mtu);
-
-	if (!rc)
-		netdev->mtu = mtu;
-
-	return rc;
-}
-
-
-netdev_features_t qlcnic_fix_features(struct net_device *netdev,
-	netdev_features_t features)
-{
-	struct qlcnic_adapter *adapter = netdev_priv(netdev);
-
-	if ((adapter->flags & QLCNIC_ESWITCH_ENABLED)) {
-		netdev_features_t changed = features ^ netdev->features;
-		features ^= changed & (NETIF_F_ALL_CSUM | NETIF_F_RXCSUM);
-	}
-
-	if (!(features & NETIF_F_RXCSUM))
-		features &= ~NETIF_F_LRO;
-
-	return features;
-}
-
-
-int qlcnic_set_features(struct net_device *netdev, netdev_features_t features)
-{
-	struct qlcnic_adapter *adapter = netdev_priv(netdev);
-	netdev_features_t changed = netdev->features ^ features;
-	int hw_lro = (features & NETIF_F_LRO) ? QLCNIC_LRO_ENABLED : 0;
-
-	if (!(changed & NETIF_F_LRO))
-		return 0;
-
-	netdev->features = features ^ NETIF_F_LRO;
-
-	if (qlcnic_config_hw_lro(adapter, hw_lro))
-		return -EIO;
-
-	if ((hw_lro == 0) && qlcnic_send_lro_cleanup(adapter))
-		return -EIO;
-
-	return 0;
-}
-
-/*
- * Changes the CRB window to the specified window.
- */
- /* Returns < 0 if off is not valid,
- *	 1 if window access is needed. 'off' is set to offset from
- *	   CRB space in 128M pci map
- *	 0 if no window access is needed. 'off' is set to 2M addr
- * In: 'off' is offset from base in 128M pci map
- */
-static int
-qlcnic_pci_get_crb_addr_2M(struct qlcnic_hardware_context *ahw,
-		ulong off, void __iomem **addr)
-{
-	const struct crb_128M_2M_sub_block_map *m;
-
-	if ((off >= QLCNIC_CRB_MAX) || (off < QLCNIC_PCI_CRBSPACE))
-		return -EINVAL;
-
-	off -= QLCNIC_PCI_CRBSPACE;
-
-	/*
-	 * Try direct map
-	 */
-	m = &crb_128M_2M_map[CRB_BLK(off)].sub_block[CRB_SUBBLK(off)];
-
-	if (m->valid && (m->start_128M <= off) && (m->end_128M > off)) {
-		*addr = ahw->pci_base0 + m->start_2M +
-			(off - m->start_128M);
-		return 0;
-	}
-
-	/*
-	 * Not in direct map, use crb window
-	 */
-	*addr = ahw->pci_base0 + CRB_INDIRECT_2M + (off & MASK(16));
-	return 1;
-}
-
-/*
- * In: 'off' is offset from CRB space in 128M pci map
- * Out: 'off' is 2M pci map addr
- * side effect: lock crb window
- */
-static int
-qlcnic_pci_set_crbwindow_2M(struct qlcnic_adapter *adapter, ulong off)
-{
-	u32 window;
-	void __iomem *addr = adapter->ahw->pci_base0 + CRB_WINDOW_2M;
-
-	off -= QLCNIC_PCI_CRBSPACE;
-
-	window = CRB_HI(off);
-	if (window == 0) {
-		dev_err(&adapter->pdev->dev, "Invalid offset 0x%lx\n", off);
-		return -EIO;
-	}
-
-	writel(window, addr);
-	if (readl(addr) != window) {
-		printk_ratelimited(KERN_WARNING
-			"failed to set CRB window to %d off 0x%lx\n",
-				window, off);
-		return -EIO;
-	}
-	return 0;
-}
-
-int
-qlcnic_hw_write_wx_2M(struct qlcnic_adapter *adapter, ulong off, u32 data)
-{
-	unsigned long flags;
-	int rv;
-	void __iomem *addr = NULL;
-
-	rv = qlcnic_pci_get_crb_addr_2M(adapter->ahw, off, &addr);
-
-	if (rv == 0) {
-		writel(data, addr);
-		return 0;
-	}
-
-	if (rv > 0) {
-		/* indirect access */
-		write_lock_irqsave(&adapter->ahw->crb_lock, flags);
-		crb_win_lock(adapter);
-		rv = qlcnic_pci_set_crbwindow_2M(adapter, off);
-		if (!rv)
-			writel(data, addr);
-		crb_win_unlock(adapter);
-		write_unlock_irqrestore(&adapter->ahw->crb_lock, flags);
-		return rv;
-	}
-
-	dev_err(&adapter->pdev->dev,
-			"%s: invalid offset: 0x%016lx\n", __func__, off);
-	dump_stack();
-	return -EIO;
-}
-
-u32
-qlcnic_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off, int *err)
-{
-	unsigned long flags;
-	int rv;
-	u32 data = -1;
-	void __iomem *addr = NULL;
-
-	rv = qlcnic_pci_get_crb_addr_2M(adapter->ahw, off, &addr);
-
-	if (rv == 0)
-		return readl(addr);
-
-	if (rv > 0) {
-		/* indirect access */
-		write_lock_irqsave(&adapter->ahw->crb_lock, flags);
-		crb_win_lock(adapter);
-		if (!qlcnic_pci_set_crbwindow_2M(adapter, off))
-			data = readl(addr);
-		crb_win_unlock(adapter);
-		write_unlock_irqrestore(&adapter->ahw->crb_lock, flags);
-		return data;
-	}
-
-	dev_err(&adapter->pdev->dev,
-			"%s: invalid offset: 0x%016lx\n", __func__, off);
-	dump_stack();
-	if (err)
-		*err = -1;
-
-	return -1;
-}
-
-
-void __iomem *
-qlcnic_get_ioaddr(struct qlcnic_hardware_context *ahw, u32 offset)
-{
-	void __iomem *addr = NULL;
-
-	WARN_ON(qlcnic_pci_get_crb_addr_2M(ahw, offset, &addr));
-
-	return addr;
-}
-
-static int
-qlcnic_pci_mem_access_direct(struct qlcnic_adapter *adapter, u32 window,
-	u64 off, u64 *data, int op)
-{
-	void __iomem *addr;
-	u32 start;
-
-	mutex_lock(&adapter->ahw->mem_lock);
-
-	writel(window, adapter->ahw->ocm_win_crb);
-	/* read back to flush */
-	readl(adapter->ahw->ocm_win_crb);
-	start = QLCNIC_PCI_OCM0_2M + off;
-
-	addr = adapter->ahw->pci_base0 + start;
-
-	if (op == 0)	/* read */
-		*data = readq(addr);
-	else		/* write */
-		writeq(*data, addr);
-
-	/* Set window to 0 */
-	writel(0, adapter->ahw->ocm_win_crb);
-	readl(adapter->ahw->ocm_win_crb);
-
-	mutex_unlock(&adapter->ahw->mem_lock);
-	return 0;
-}
-
-void
-qlcnic_pci_camqm_read_2M(struct qlcnic_adapter *adapter, u64 off, u64 *data)
-{
-	void __iomem *addr = adapter->ahw->pci_base0 +
-		QLCNIC_PCI_CAMQM_2M_BASE + (off - QLCNIC_PCI_CAMQM);
-
-	mutex_lock(&adapter->ahw->mem_lock);
-	*data = readq(addr);
-	mutex_unlock(&adapter->ahw->mem_lock);
-}
-
-void
-qlcnic_pci_camqm_write_2M(struct qlcnic_adapter *adapter, u64 off, u64 data)
-{
-	void __iomem *addr = adapter->ahw->pci_base0 +
-		QLCNIC_PCI_CAMQM_2M_BASE + (off - QLCNIC_PCI_CAMQM);
-
-	mutex_lock(&adapter->ahw->mem_lock);
-	writeq(data, addr);
-	mutex_unlock(&adapter->ahw->mem_lock);
-}
-
-#define MAX_CTL_CHECK   1000
-
-/* Set MS memory control data for different chip type*/
-static void
-qlcnic_set_ms_controls(struct qlcnic_adapter *adapter, u64 off,
-	struct qlcnic_ms_reg_ctrl *ms)
-{
-	ms->control = QLCNIC_MS_CTRL;
-	ms->low = QLCNIC_MS_ADDR_LO;
-	ms->hi = QLCNIC_MS_ADDR_HI;
-	if (off & 0xf) {
-		ms->wd[0] = QLCNIC_MS_WRTDATA_LO;
-		ms->rd[0] = QLCNIC_MS_RDDATA_LO;
-		ms->wd[1] = QLCNIC_MS_WRTDATA_HI;
-		ms->rd[1] = QLCNIC_MS_RDDATA_HI;
-		ms->wd[2] = QLCNIC_MS_WRTDATA_ULO;
-		ms->wd[3] = QLCNIC_MS_WRTDATA_UHI;
-		ms->rd[2] = QLCNIC_MS_RDDATA_ULO;
-		ms->rd[3] = QLCNIC_MS_RDDATA_UHI;
-	} else {
-		ms->wd[0] = QLCNIC_MS_WRTDATA_ULO;
-		ms->rd[0] = QLCNIC_MS_RDDATA_ULO;
-		ms->wd[1] = QLCNIC_MS_WRTDATA_UHI;
-		ms->rd[1] = QLCNIC_MS_RDDATA_UHI;
-		ms->wd[2] = QLCNIC_MS_WRTDATA_LO;
-		ms->wd[3] = QLCNIC_MS_WRTDATA_HI;
-		ms->rd[2] = QLCNIC_MS_RDDATA_LO;
-		ms->rd[3] = QLCNIC_MS_RDDATA_HI;
-	}
-	if (QLCNIC_IS_83XX(adapter)) {
-		ms->ocm_window = OCM_WIN_83XX(off);
-		ms->off = GET_83XX_OCM_OFFSET(off);
-	} else {
-		ms->ocm_window = OCM_WIN_P3P(off);
-		ms->off = GET_MEM_OFFS_2M(off);
-	}
-}
-
-int
-qlcnic_pci_mem_write_2M(struct qlcnic_adapter *adapter,
-		u64 off, u64 data)
-{
-	int j, ret = 0;
-	u32 temp, off8;
-	struct qlcnic_ms_reg_ctrl ms;
-
-	/* Only 64-bit aligned access */
-	if (off & 7)
-		return -EIO;
-
-	memset(&ms, 0, sizeof(struct qlcnic_ms_reg_ctrl));
-	if (!((ADDR_IN_RANGE(off, QLCNIC_ADDR_QDR_NET,
-		QLCNIC_ADDR_QDR_NET_MAX)) ||
-			(ADDR_IN_RANGE(off, QLCNIC_ADDR_DDR_NET,
-				QLCNIC_ADDR_DDR_NET_MAX))))
-		return -EIO;
-
-	qlcnic_set_ms_controls(adapter, off, &ms);
-
-	if (ADDR_IN_RANGE(off, QLCNIC_ADDR_OCM0, QLCNIC_ADDR_OCM0_MAX))
-		return qlcnic_pci_mem_access_direct(adapter, ms.ocm_window,
-			ms.off, &data, 1);
-
-	off8 = off & ~0xf;
-
-	mutex_lock(&adapter->ahw->mem_lock);
-
-	qlcnic_ind_wr(adapter, ms.low, off8);
-	qlcnic_ind_wr(adapter, ms.hi, 0);
-
-	qlcnic_ind_wr(adapter, ms.control, TA_CTL_ENABLE);
-	qlcnic_ind_wr(adapter, ms.control, QLC_TA_START_ENABLE);
-
-	for (j = 0; j < MAX_CTL_CHECK; j++) {
-		temp = qlcnic_ind_rd(adapter, ms.control);
-		if ((temp & TA_CTL_BUSY) == 0)
-			break;
-	}
-
-	if (j >= MAX_CTL_CHECK) {
-		ret = -EIO;
-		goto done;
-	}
-
-	/* This is the modify part of read-modify-write */
-	qlcnic_ind_wr(adapter, ms.wd[0], qlcnic_ind_rd(adapter, ms.rd[0]));
-	qlcnic_ind_wr(adapter, ms.wd[1], qlcnic_ind_rd(adapter, ms.rd[1]));
-	/* This is the write part of read-modify-write */
-	qlcnic_ind_wr(adapter, ms.wd[2], data & 0xffffffff);
-	qlcnic_ind_wr(adapter, ms.wd[3], (data >> 32) & 0xffffffff);
-
-	qlcnic_ind_wr(adapter, ms.control, QLC_TA_WRITE_ENABLE);
-	qlcnic_ind_wr(adapter, ms.control, QLC_TA_WRITE_START);
-
-	for (j = 0; j < MAX_CTL_CHECK; j++) {
-		temp = qlcnic_ind_rd(adapter, ms.control);
-		if ((temp & TA_CTL_BUSY) == 0)
-			break;
-	}
-
-	if (j >= MAX_CTL_CHECK) {
-		printk_ratelimited(KERN_WARNING
-				"failed to write through agent\n");
-		ret = -EIO;
-	} else {
-		ret = 0;
-	}
-
-done:
-	mutex_unlock(&adapter->ahw->mem_lock);
-
-	return ret;
-}
-
-int
-qlcnic_pci_mem_read_2M(struct qlcnic_adapter *adapter,
-		u64 off, u64 *data)
-{
-	int j, ret;
-	u32 temp, off8;
-	u64 val;
-	struct qlcnic_ms_reg_ctrl ms;
-
-	/* Only 64-bit aligned access */
-	if (off & 7)
-		return -EIO;
-	if (!((ADDR_IN_RANGE(off, QLCNIC_ADDR_QDR_NET,
-		QLCNIC_ADDR_QDR_NET_MAX)) ||
-			(ADDR_IN_RANGE(off, QLCNIC_ADDR_DDR_NET,
-				QLCNIC_ADDR_DDR_NET_MAX))))
-		return -EIO ;
-
-	memset(&ms, 0, sizeof(struct qlcnic_ms_reg_ctrl));
-	qlcnic_set_ms_controls(adapter, off, &ms);
-
-	if (ADDR_IN_RANGE(off, QLCNIC_ADDR_OCM0, QLCNIC_ADDR_OCM0_MAX))
-		return qlcnic_pci_mem_access_direct(adapter, ms.ocm_window,
-			ms.off, data, 0);
-
-	mutex_lock(&adapter->ahw->mem_lock);
-
-	off8 = off & ~0xf;
-
-	qlcnic_ind_wr(adapter, ms.low, off8);
-	qlcnic_ind_wr(adapter, ms.hi, 0);
-
-	qlcnic_ind_wr(adapter, ms.control, TA_CTL_ENABLE);
-	qlcnic_ind_wr(adapter, ms.control, QLC_TA_START_ENABLE);
-
-	for (j = 0; j < MAX_CTL_CHECK; j++) {
-		temp = qlcnic_ind_rd(adapter, ms.control);
-		if ((temp & TA_CTL_BUSY) == 0)
-			break;
-	}
-
-	if (j >= MAX_CTL_CHECK) {
-		printk_ratelimited(KERN_WARNING
-				"failed to read through agent\n");
-		ret = -EIO;
-	} else {
-
-		temp = qlcnic_ind_rd(adapter, ms.rd[3]);
-		val = (u64)temp << 32;
-		val |= qlcnic_ind_rd(adapter, ms.rd[2]);
-		*data = val;
-		ret = 0;
-	}
-
-	mutex_unlock(&adapter->ahw->mem_lock);
-
-	return ret;
-}
-
-int qlcnic_get_board_info(struct qlcnic_adapter *adapter)
-{
-	int offset, board_type, magic, err;
-	struct pci_dev *pdev = adapter->pdev;
-	struct qlcnic_hardware_context *ahw = adapter->ahw;
-
-	offset = QLCNIC_FW_MAGIC_OFFSET;
-	if (qlcnic_rom_fast_read(adapter, offset, &magic))
-		return -EIO;
-
-	if (magic != QLCNIC_BDINFO_MAGIC) {
-		dev_err(&pdev->dev, "invalid board config, magic=%08x\n",
-			magic);
-		return -EIO;
-	}
-
-	offset = QLCNIC_BRDTYPE_OFFSET;
-	if (qlcnic_rom_fast_read(adapter, offset, &board_type))
-		return -EIO;
-
-	ahw->board_type = board_type;
-
-	if (board_type == QLCNIC_BRDTYPE_P3P_4_GB_MM) {
-		u32 gpio = QLCRD32(adapter, QLCNIC_ROMUSB_GLB_PAD_GPIO_I, &err);
-		if ((gpio & 0x8000) == 0)
-			board_type = QLCNIC_BRDTYPE_P3P_10G_TP;
-	}
-
-	switch (board_type) {
-	case QLCNIC_BRDTYPE_P3P_HMEZ:
-	case QLCNIC_BRDTYPE_P3P_XG_LOM:
-	case QLCNIC_BRDTYPE_P3P_10G_CX4:
-	case QLCNIC_BRDTYPE_P3P_10G_CX4_LP:
-	case QLCNIC_BRDTYPE_P3P_IMEZ:
-	case QLCNIC_BRDTYPE_P3P_10G_SFP_PLUS:
-	case QLCNIC_BRDTYPE_P3P_10G_SFP_CT:
-	case QLCNIC_BRDTYPE_P3P_10G_SFP_QT:
-	case QLCNIC_BRDTYPE_P3P_10G_XFP:
-	case QLCNIC_BRDTYPE_P3P_10000_BASE_T:
-		ahw->port_type = QLCNIC_XGBE;
-		break;
-	case QLCNIC_BRDTYPE_P3P_REF_QG:
-	case QLCNIC_BRDTYPE_P3P_4_GB:
-	case QLCNIC_BRDTYPE_P3P_4_GB_MM:
-		ahw->port_type = QLCNIC_GBE;
-		break;
-	case QLCNIC_BRDTYPE_P3P_10G_TP:
-		ahw->port_type = (adapter->portnum < 2) ?
-			QLCNIC_XGBE : QLCNIC_GBE;
-		break;
-	default:
-		dev_err(&pdev->dev, "unknown board type %x\n", board_type);
-		ahw->port_type = QLCNIC_XGBE;
-		break;
-	}
-
-	return 0;
-}
-
-int
-qlcnic_wol_supported(struct qlcnic_adapter *adapter)
-{
-	int err;
-	u32 wol_cfg;
-
-	wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG_NV, &err);
-	if (wol_cfg & (1UL << adapter->portnum)) {
-		wol_cfg = QLCRD32(adapter, QLCNIC_WOL_CONFIG, &err);
-		if (wol_cfg & (1 << adapter->portnum))
-			return 1;
-	}
-
-	return 0;
-}
-
-int qlcnic_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate)
-{
-	struct qlcnic_nic_req   req;
-	int rv;
-	u64 word;
-
-	memset(&req, 0, sizeof(struct qlcnic_nic_req));
-	req.qhdr = cpu_to_le64(QLCNIC_HOST_REQUEST << 23);
-
-	word = QLCNIC_H2C_OPCODE_CONFIG_LED | ((u64)adapter->portnum << 16);
-	req.req_hdr = cpu_to_le64(word);
-
-	req.words[0] = cpu_to_le64((u64)rate << 32);
-	req.words[1] = cpu_to_le64(state);
-
-	rv = qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
-	if (rv)
-		dev_err(&adapter->pdev->dev, "LED configuration failed.\n");
-
-	return rv;
-}
-
-void qlcnic_get_func_no(struct qlcnic_adapter *adapter)
-{
-	void __iomem *msix_base_addr;
-	u32 func;
-	u32 msix_base;
-
-	pci_read_config_dword(adapter->pdev, QLCNIC_MSIX_TABLE_OFFSET, &func);
-	msix_base_addr = adapter->ahw->pci_base0 + QLCNIC_MSIX_BASE;
-	msix_base = readl(msix_base_addr);
-	func = (func - msix_base)/QLCNIC_MSIX_TBL_PGSIZE;
-	adapter->ahw->pci_func = func;
-}
-
-void qlcnic_get_ocm_win(struct qlcnic_hardware_context *ahw)
-{
-	ahw->ocm_win_crb = qlcnic_get_ioaddr(ahw, QLCNIC_PCIX_PS_REG(
-				PCIX_OCM_WINDOW_REG(ahw->pci_func)));
-}
-
-void qlcnic_read_crb(struct qlcnic_adapter *adapter, char *buf,
-	loff_t offset, size_t size)
-{
-	int err;
-	u32 data;
-	u64 qmdata;
-
-	if (ADDR_IN_RANGE(offset, QLCNIC_PCI_CAMQM, QLCNIC_PCI_CAMQM_END)) {
-		qlcnic_pci_camqm_read_2M(adapter, offset, &qmdata);
-		memcpy(buf, &qmdata, size);
-	} else {
-		data = QLCRD32(adapter, offset, &err);
-		memcpy(buf, &data, size);
-	}
-}
-
-void qlcnic_write_crb(struct qlcnic_adapter *adapter, char *buf,
-	loff_t offset, size_t size)
-{
-	u32 data;
-	u64 qmdata;
-
-	if (ADDR_IN_RANGE(offset, QLCNIC_PCI_CAMQM, QLCNIC_PCI_CAMQM_END)) {
-		memcpy(&qmdata, buf, size);
-		qlcnic_pci_camqm_write_2M(adapter, offset, qmdata);
-	} else {
-		memcpy(&data, buf, size);
-		QLCWR32(adapter, offset, data);
-	}
-}
-
-int qlcnic_api_lock(struct qlcnic_adapter *adapter)
-{
-	return qlcnic_pcie_sem_lock(adapter, 5, 0);
-}
-
-void qlcnic_api_unlock(struct qlcnic_adapter *adapter)
-{
-	qlcnic_pcie_sem_unlock(adapter, 5);
-}
-
-void qlcnic_add_sysfs(struct qlcnic_adapter *adapter)
-{
-	qlcnic_create_diag_entries(adapter);
-}
-
-void qlcnic_remove_sysfs(struct qlcnic_adapter *adapter)
-{
-	qlcnic_remove_diag_entries(adapter);
-}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
index 2f3966e..d9551a3 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.h
@@ -1,8 +1,6 @@
 #ifndef __QLCNIC_HW_H
 #define __QLCNIC_HW_H
 
-#include "qlcnic.h"
-
 #define MASK(n) ((1ULL<<(n))-1)
 #define OCM_WIN_P3P(addr) (addr & 0xffc0000)
 #define OCM_WIN_83XX(addr)	(addr & 0xFFE0000)
@@ -22,7 +20,7 @@
 #define PCI_DEVICE_ID_QLOGIC_QLE824X	0x8020
 #define PCI_DEVICE_ID_QLOGIC_QLE834X	0x8030
 #define QLCNIC_82XX_BAR0_LENGTH	0x00200000UL
-#define QLCNIC_83XX_BAR0_LENGTH	0x4000
+#define QLC_83XX_BAR0_LENGTH	0x4000
 
 #define QLCNIC_IS_83XX(adapter)	\
 	(((adapter)->pdev->device == PCI_DEVICE_ID_QLOGIC_QLE834X) ? 1 : 0)
@@ -82,7 +80,11 @@ struct qlcnic_ms_reg_ctrl {
 	writel(value, (((ahw)->pci_base0) + ((ahw)->ext_reg_tbl[addr])))
 
 #define QLCNIC_READ_LINK_SPEED(adapter, pcifn, err)\
-	QLCRD32(adapter, P3P_LINK_SPEED_REG(pcifn), err)
+	(QLCNIC_IS_83XX(adapter) ?\
+	(((readl(adapter->ahw->pci_base0 + QLC_83XX_LINK_SPEED(pcifn)) >> \
+	((pcifn % 4) << 4)) & 0xFFFF) * QLC_83XX_LINK_SPEED_FACTOR) :\
+	(P3P_LINK_SPEED_MHZ * P3P_LINK_SPEED_VAL(pcifn, \
+	QLCRD32(adapter, P3P_LINK_SPEED_REG(pcifn), err))))
 
 /* Mailbox ownership */
 #define QLCNIC_GET_OWNER(val)	\
@@ -124,6 +126,7 @@ struct qlcnic_ms_reg_ctrl {
 #define QLCNIC_CMD_TEMP_SIZE			0x2f
 #define QLCNIC_CMD_GET_TEMP_HDR			0x30
 #define QLCNIC_CMD_GET_MAC_STATS		0x37
+#define QLCNIC_CMD_SET_DRV_VER			0x38
 #define QLCNIC_CMD_CONFIGURE_RSS		0x41
 #define QLCNIC_CMD_CONFIG_INTR_COAL		0x43
 #define QLCNIC_CMD_CONFIGURE_LED		0x44
@@ -175,7 +178,7 @@ do {							\
 		*bar = QLCNIC_82XX_BAR0_LENGTH;		\
 		break;					\
 	case PCI_DEVICE_ID_QLOGIC_QLE834X:		\
-		*bar = QLCNIC_83XX_BAR0_LENGTH;	\
+		*bar = QLC_83XX_BAR0_LENGTH;	\
 		break;					\
 	default:					\
 		*bar = 0;				\
@@ -219,7 +222,9 @@ do {							\
 	((ahw)->pci_base0 + 0x800 + ((i) * 4))
 
 #define QLCNIC_IS_TSO_CAPABLE(adapter)\
-	((adapter)->ahw->capabilities & QLCNIC_FW_CAPABILITY_TSO)
+	((QLCNIC_IS_82XX(adapter)) ?\
+	((adapter)->ahw->capabilities & QLCNIC_FW_CAPABILITY_TSO) :\
+	((adapter)->ahw->capabilities & QLCNIC_FW_83XX_CAPABILITY_TSO))
 
 #define QLCNIC_IS_VLAN_TX_CAPABLE(adapter) \
 	((QLCNIC_IS_82XX(adapter)) ?\
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
index 737adea..3b10acc 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
@@ -662,7 +662,7 @@ static int qlcnic_get_flt_entry(struct qlcnic_adapter *adapter, u8 region,
 	entry_size = flt_hdr.len - sizeof(struct qlcnic_flt_header);
 	flt_entry = vmalloc(entry_size);
 	if (flt_entry == NULL) {
-		dev_warn(&adapter->pdev->dev, "error allocating memory\n");
+		dev_err(&adapter->pdev->dev, "error allocating memory\n");
 		return -EIO;
 	}
 	memset(flt_entry, 0, entry_size);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index 1c384f1..ce8a4e0 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -115,6 +115,7 @@ qlcnic_tx_pkt(struct qlcnic_adapter *adapter,
 		vh = (struct vlan_ethhdr *)skb->data;
 		flags = FLAGS_VLAN_TAGGED;
 		vlan_tci = vh->h_vlan_TCI;
+		protocol = ntohs(vh->h_vlan_encapsulated_proto);
 	} else if (vlan_tx_tag_present(skb)) {
 		flags = FLAGS_VLAN_OOB;
 		vlan_tci = vlan_tx_tag_get(skb);
@@ -724,8 +725,6 @@ struct sk_buff *qlcnic_process_rxbuf(struct qlcnic_adapter *adapter,
 		skb_checksum_none_assert(skb);
 	}
 
-	skb->dev = adapter->netdev;
-
 	buffer->skb = NULL;
 
 	return skb;
@@ -885,6 +884,9 @@ qlcnic_process_lro(struct qlcnic_adapter *adapter,
 
 	length = skb->len;
 
+	if (adapter->flags & QLCNIC_FW_LRO_MSS_CAP)
+		skb_shinfo(skb)->gso_size = qlcnic_get_lro_sts_mss(sts_data1);
+
 	if (vid != 0xffff)
 		__vlan_hwaccel_put_tag(skb, vid);
 	netif_receive_skb(skb);
@@ -1075,7 +1077,8 @@ void dump_skb(struct sk_buff *skb, struct qlcnic_adapter *adapter)
 
 	pr_info("\n");
 	for (i = 0; i < skb->len; i++) {
-		QLCDB(adapter, DRV, "%02x ", data[i]);
+		netif_info(adapter->ahw, pktdata, adapter->netdev,
+			"%02x ", data[i]);
 		if ((i & 0x0f) == 8)
 			pr_info("\n");
 	}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 9d1962f..5d423c1 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -35,6 +35,10 @@ char qlcnic_driver_name[] = "qlcnic";
 static const char qlcnic_driver_string[] = "QLogic 1/10 GbE "
 	"Converged/Intelligent Ethernet Driver v" QLCNIC_LINUX_VERSIONID;
 
+static int qlcnic_debug_level = -1;
+module_param(qlcnic_debug_level, int, 0664);
+MODULE_PARM_DESC(qlcnic_debug_level, "Debug level (0=none,...,16=all)");
+
 static int qlcnic_mac_learn;
 module_param(qlcnic_mac_learn, int, 0444);
 MODULE_PARM_DESC(qlcnic_mac_learn, "Mac Filter (0=disabled, 1=enabled)");
@@ -252,7 +256,7 @@ qlcnic_alloc_tx_rings(struct qlcnic_adapter *adapter, struct net_device *netdev)
 	return 0;
 }
 
-int
+static int
 qlcnic_napi_add(struct qlcnic_adapter *adapter, struct net_device *netdev)
 {
 	int ring;
@@ -653,7 +657,7 @@ qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
 	for (i = 0; i < QLCNIC_MAX_PCI_FUNC; i++) {
 		pfn = pci_info[i].id;
 
-		if (pfn > QLCNIC_MAX_PCI_FUNC) {
+		if (pfn >= QLCNIC_MAX_PCI_FUNC) {
 			ret = QL_STATUS_INVALID_PARAM;
 			goto err_eswitch;
 		}
@@ -727,7 +731,7 @@ err_lock:
 	return ret;
 }
 
-void
+static void
 qlcnic_check_vf(struct qlcnic_adapter *adapter, const struct pci_device_id *ent)
 {
 	void __iomem *priv_op;
@@ -803,17 +807,18 @@ static void qlcnic_get_brd_name(struct qlcnic_adapter *adapter, char *name)
 			qlcnic_boards[i].device == pdev->device &&
 			qlcnic_boards[i].sub_vendor == pdev->subsystem_vendor &&
 			qlcnic_boards[i].sub_device == pdev->subsystem_device) {
-				sprintf(name, "%pM: %s" ,
-					adapter->mac_addr,
-					qlcnic_boards[i].short_name);
-				found = 1;
-				break;
+			snprintf(name, QLCNIC_MAX_BOARD_NAME_LEN, "%pM: %s",
+				adapter->mac_addr,
+				qlcnic_boards[i].short_name);
+			found = 1;
+			break;
 		}
 
 	}
 
 	if (!found)
-		sprintf(name, "%pM Gigabit Ethernet", adapter->mac_addr);
+		snprintf(name, ETH_ALEN, "%pM Gigabit Ethernet",
+			adapter->mac_addr);
 }
 
 void
@@ -849,8 +854,8 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 		}
 	}
 
-	dev_info(&pdev->dev, "firmware v%d.%d.%d\n",
-			fw_major, fw_minor, fw_build);
+	dev_info(&pdev->dev, "Driver v%s, firmware v%d.%d.%d\n",
+		QLCNIC_LINUX_VERSIONID, fw_major, fw_minor, fw_build);
 	if (ahw->port_type == QLCNIC_XGBE) {
 		if (adapter->flags & QLCNIC_ESWITCH_ENABLED) {
 			adapter->num_rxd = DEFAULT_RCV_DESCRIPTORS_VF;
@@ -884,6 +889,7 @@ qlcnic_initialize_nic(struct qlcnic_adapter *adapter)
 	struct qlcnic_info nic_info;
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
+	memset(&nic_info, 0, sizeof(struct qlcnic_info));
 	err = ahw->hw_ops->get_nic_info(adapter, &nic_info, ahw->pci_func);
 	if (err)
 		return err;
@@ -1118,6 +1124,7 @@ qlcnic_reset_npar_config(struct qlcnic_adapter *adapter)
 	for (i = 0; i < adapter->ahw->act_pci_func; i++) {
 		npar = &adapter->npars[i];
 		pci_func = npar->pci_func;
+		memset(&nic_info, 0, sizeof(struct qlcnic_info));
 		err = ahw->hw_ops->get_nic_info(adapter, &nic_info, pci_func);
 		if (err)
 			return err;
@@ -1287,8 +1294,8 @@ qlcnic_request_irq(struct qlcnic_adapter *adapter)
 	if (adapter->ahw->diag_test != QLCNIC_LOOPBACK_TEST) {
 		for (ring = 0; ring < adapter->max_sds_rings; ring++) {
 			sds_ring = &recv_ctx->sds_rings[ring];
-			sprintf(sds_ring->name, "%s[%d]",
-						netdev->name, ring);
+			snprintf(sds_ring->name, sizeof(int) + IFNAMSIZ,
+				"%s[%d]", netdev->name, ring);
 			err = request_irq(sds_ring->irq, handler, flags,
 					sds_ring->name, sds_ring);
 			if (err)
@@ -1300,7 +1307,8 @@ qlcnic_request_irq(struct qlcnic_adapter *adapter)
 			for (ring = 0; ring < adapter->max_drv_tx_rings;
 								ring++) {
 				tx_ring = &adapter->tx_ring[ring];
-				sprintf(tx_ring->name, "%s[%d]", netdev->name,
+				snprintf(tx_ring->name, sizeof(int) + IFNAMSIZ,
+					"%s[%d]", netdev->name,
 					adapter->max_sds_rings + ring);
 				err = request_irq(tx_ring->irq, handler, flags,
 					tx_ring->name, tx_ring);
@@ -1341,7 +1349,10 @@ qlcnic_free_irq(struct qlcnic_adapter *adapter)
 static int
 __qlcnic_up(struct qlcnic_adapter *adapter, struct net_device *netdev)
 {
+	int err;
 	u8 ring;
+	u32 capab2;
+
 	struct qlcnic_host_rds_ring *rds_ring;
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
@@ -1354,6 +1365,12 @@ __qlcnic_up(struct qlcnic_adapter *adapter, struct net_device *netdev)
 	if (qlcnic_set_eswitch_port_config(adapter))
 		return -EIO;
 
+	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_MORE_CAPS) {
+		capab2 = QLCRD32(adapter, CRB_FW_CAPABILITIES_2, &err);
+		if (capab2 & QLCNIC_FW_CAPABILITY_2_LRO_MAX_TCP_SEG)
+			adapter->flags |= QLCNIC_FW_LRO_MSS_CAP;
+	}
+
 	if (qlcnic_fw_create_ctx(adapter))
 		return -EIO;
 
@@ -1424,6 +1441,7 @@ __qlcnic_down(struct qlcnic_adapter *adapter, struct net_device *netdev)
 	adapter->ahw->hw_ops->napi_disable(adapter);
 
 	qlcnic_fw_destroy_ctx(adapter);
+	adapter->flags &= ~QLCNIC_FW_LRO_MSS_CAP;
 
 	qlcnic_reset_rx_buffers_list(adapter);
 	qlcnic_release_tx_buffers(adapter);
@@ -1632,7 +1650,7 @@ int qlcnic_diag_alloc_res(struct net_device *netdev, int test)
 }
 
 /* Reset context in hardware only */
-int
+static int
 qlcnic_reset_hw_context(struct qlcnic_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
@@ -1766,14 +1784,16 @@ int qlcnic_is_valid_nic_func(struct qlcnic_adapter *adapter, u8 pci_func)
 static int __devinit
 qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
+	u32 capab2;
 	struct net_device *netdev = NULL;
 	struct qlcnic_adapter *adapter = NULL;
 	struct qlcnic_hardware_context *ahw;
 	int err;
-	uint8_t pci_using_dac;
+	uint8_t pci_using_dac = 0;
 	char brd_name[QLCNIC_MAX_BOARD_NAME_LEN];
 
 	err = pci_enable_device(pdev);
+
 	if (err)
 		return err;
 
@@ -1823,6 +1843,9 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	adapter->pdev    = pdev;
 	adapter->ahw = ahw;
 
+	adapter->ahw->msg_enable =
+		netif_msg_init(qlcnic_debug_level, QLCNIC_DBG_LEVEL_MASK);
+
 	adapter->qlcnic_wq = create_singlethread_workqueue("qlcnic");
 	if (adapter->qlcnic_wq == NULL) {
 		dev_err(&pdev->dev, "Failed to create workqueue\n");
@@ -1883,6 +1906,14 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 				module_name(THIS_MODULE),
 				brd_name, adapter->ahw->revision_id);
 	}
+
+	if ((QLCNIC_IS_82XX(adapter)) && (adapter->ahw->capabilities &
+			QLCNIC_FW_CAPABILITY_MORE_CAPS)) {
+		capab2 = QLCRD32(adapter, CRB_FW_CAPABILITIES_2, &err);
+		if (capab2 & QLCNIC_FW_CAPABILITY_2_OCBB)
+			qlcnic_fw_cmd_set_drv_version(adapter);
+	}
+
 	err = ahw->hw_ops->setup_intr(adapter, 0);
 	if (err)
 		goto err_out_disable_msi;
@@ -2178,6 +2209,9 @@ int qlcnic_check_temp(struct qlcnic_adapter *adapter)
 
 	temp = 0;
 
+	if (QLCNIC_IS_83XX(adapter))
+		temp = QLCRDX(adapter->ahw, QLC_83XX_ASIC_TEMP);
+
 	if (QLCNIC_IS_82XX(adapter))
 		temp = QLCRD(adapter, QLCNIC_ASIC_TEMP);
 
@@ -2482,7 +2516,8 @@ qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
 	}
 
 	prev_state = QLCRD(adapter, QLCNIC_CRB_DEV_STATE);
-	QLCDB(adapter, HW, "Device state = %u\n", prev_state);
+	netif_info(adapter->ahw, hw, adapter->netdev,
+		"Device state = %u\n", prev_state);
 
 	switch (prev_state) {
 	case QLCNIC_DEV_COLD:
@@ -2595,7 +2630,8 @@ skip_ack_check:
 			QLCWR(adapter, QLCNIC_CRB_DEV_STATE,
 						QLCNIC_DEV_INITIALIZING);
 			set_bit(__QLCNIC_START_FW, &adapter->state);
-			QLCDB(adapter, DRV, "Restarting fw\n");
+			netif_info(adapter->ahw, drv, adapter->netdev,
+				"Restarting fw\n");
 			qlcnic_idc_debug_info(adapter, 0);
 			val = QLCRD(adapter, QLCNIC_CRB_DRV_STATE);
 			QLC_DEV_SET_RST_RDY(val, adapter->portnum);
@@ -2623,7 +2659,8 @@ skip_ack_check:
 
 wait_npar:
 	dev_state = QLCRD(adapter, QLCNIC_CRB_DEV_STATE);
-	QLCDB(adapter, HW, "Func waiting: Device state=%u\n", dev_state);
+	netif_info(adapter->ahw, hw, adapter->netdev,
+		"Func waiting: Device state=%u\n", dev_state);
 
 	switch (dev_state) {
 	case QLCNIC_DEV_READY:
@@ -2751,7 +2788,8 @@ qlcnic_dev_request_reset(struct qlcnic_adapter *adapter, u32 key)
 	if (state == QLCNIC_DEV_READY) {
 		QLCWR(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_NEED_RESET);
 		adapter->flags |= QLCNIC_FW_RESET_OWNER;
-		QLCDB(adapter, DRV, "NEED_RESET state set\n");
+		netif_info(adapter->ahw, drv, adapter->netdev,
+			"NEED_RESET state set\n");
 		qlcnic_idc_debug_info(adapter, 0);
 	}
 
@@ -2768,7 +2806,8 @@ qlcnic_dev_set_npar_ready(struct qlcnic_adapter *adapter)
 		return;
 
 	QLCWR(adapter, QLCNIC_CRB_DEV_NPAR_STATE, QLCNIC_DEV_NPAR_OPER);
-	QLCDB(adapter, DRV, "NPAR operational state set\n");
+	netif_info(adapter->ahw, drv, adapter->netdev,
+		"NPAR operational state set\n");
 
 	adapter->ahw->hw_ops->api_unlock(adapter);
 }
@@ -2802,7 +2841,8 @@ qlcnic_attach_work(struct work_struct *work)
 							FW_POLL_DELAY);
 		else
 			goto attach;
-		QLCDB(adapter, DRV, "Waiting for NPAR state to operational\n");
+		netif_info(adapter->ahw, drv, netdev,
+			"Waiting for NPAR state to operational\n");
 		return;
 	}
 attach:
@@ -2895,7 +2935,8 @@ detach:
 		!test_and_set_bit(__QLCNIC_RESETTING, &adapter->state)) {
 
 		qlcnic_schedule_work(adapter, qlcnic_detach_work, 0);
-		QLCDB(adapter, DRV, "fw recovery scheduled.\n");
+		netif_info(adapter->ahw, drv, adapter->netdev,
+			"fw recovery scheduled.\n");
 	}
 
 	return 1;
@@ -2981,7 +3022,8 @@ static int qlcnic_attach_func(struct pci_dev *pdev)
 		adapter->need_fw_reset = 1;
 		set_bit(__QLCNIC_START_FW, &adapter->state);
 		QLCWR(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_INITIALIZING);
-		QLCDB(adapter, DRV, "Restarting fw\n");
+		netif_info(adapter->ahw, drv, adapter->netdev,
+			"Restarting fw\n");
 	}
 	ahw->hw_ops->api_unlock(adapter);
 
@@ -3122,8 +3164,15 @@ qlcnicvf_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate)
 
 int qlcnic_validate_max_rss(u8 max_hw, u8 val)
 {
-	u32 max_allowed = rounddown_pow_of_two(
-				min_t(int, max_hw, num_online_cpus()));
+	u32 max_allowed;
+
+	if (max_hw > MAX_SDS_RINGS) {
+		max_hw = MAX_SDS_RINGS;
+		pr_info("max rss reset to %d\n", MAX_SDS_RINGS);
+	}
+
+	max_allowed = rounddown_pow_of_two(
+		min_t(int, max_hw, num_online_cpus()));
 
 	if ((val > max_allowed) || (val <  2) || !is_power_of_2(val)) {
 		pr_info("rss_ring valid range [2 - %x] in powers of 2\n",
@@ -3139,7 +3188,9 @@ qlcnic_set_max_rss(struct qlcnic_adapter *adapter, u8 data, size_t len)
 	int err;
 	struct net_device *netdev = adapter->netdev;
 
-	rtnl_lock();
+	if (test_bit(__QLCNIC_RESETTING, &adapter->state))
+		return -EBUSY;
+
 	netif_device_detach(netdev);
 	if (netif_running(netdev))
 		__qlcnic_down(adapter, netdev);
@@ -3179,7 +3230,6 @@ qlcnic_set_max_rss(struct qlcnic_adapter *adapter, u8 data, size_t len)
 	err = len;
  done:
 	netif_device_attach(netdev);
-	rtnl_unlock();
 	return err;
 
 }
@@ -3188,7 +3238,7 @@ qlcnic_set_max_rss(struct qlcnic_adapter *adapter, u8 data, size_t len)
 
 #define is_qlcnic_netdev(dev) (dev->netdev_ops == &qlcnic_netdev_ops)
 
-void
+static void
 qlcnic_config_indev_addr(struct qlcnic_adapter *adapter,
 			struct net_device *dev, unsigned long event)
 {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
index c1d5a6a..1720afc 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
@@ -75,7 +75,7 @@ qlcnic_dump_ctrl(struct qlcnic_adapter *adapter,
 					timeout++;
 				}
 				if (timeout > ctr->timeout) {
-					dev_info(&adapter->pdev->dev,
+					dev_err(&adapter->pdev->dev,
 					"Timed out, aborting poll CRB\n");
 					return 0;
 				}
@@ -106,7 +106,7 @@ qlcnic_dump_ctrl(struct qlcnic_adapter *adapter,
 				t_hdr->saved_state[ctr->index_v] = data;
 				break;
 			default:
-				dev_info(&adapter->pdev->dev,
+				dev_err(&adapter->pdev->dev,
 					"Unknown opcode\n");
 				break;
 			}
@@ -293,7 +293,7 @@ qlcnic_read_memory(struct qlcnic_adapter *adapter,
 	addr = mem->addr;
 	/* check for data size of multiple of 16 and 16 byte alignment */
 	if ((addr & 0xf) || (reg_read%16)) {
-		dev_info(&adapter->pdev->dev,
+		dev_err(&adapter->pdev->dev,
 			"Unaligned memory addr:0x%x size:0x%x\n",
 			addr, reg_read);
 		return 0;
@@ -344,7 +344,7 @@ qlcnic_valid_dump_entry(struct device *dev, struct qlcnic_dump_entry *entry,
 {
 	int ret = 1;
 	if (size != entry->hdr.cap_size) {
-		dev_info(dev,
+		dev_err(dev,
 		"Invalid entry, Type:%d\tMask:%d\tSize:%dCap_size:%d\n",
 		entry->hdr.type, entry->hdr.mask, size, entry->hdr.cap_size);
 		ret = 0;
@@ -475,7 +475,7 @@ qlcnic_83xx_dump_rom(struct qlcnic_adapter *adapter,
 	fl_addr = rom->addr;
 	size = rom->size/4;
 
-	if (!qlcnic_83xx_lockless_flash_read_u32(adapter,
+	if (!qlcnic_83xx_lockless_flash_read32(adapter,
 					fl_addr, (u8 *)buffer, size))
 		return rom->size;
 
@@ -554,7 +554,7 @@ qlcnic_fw_flash_get_minidump_temp(struct qlcnic_adapter *adapter,
 	if (qlcnic_83xx_lock_flash(adapter))
 		return -EIO;
 
-	ret = qlcnic_83xx_lockless_flash_read_u32(adapter,
+	ret = qlcnic_83xx_lockless_flash_read32(adapter,
 			QLC_83XX_MINIDUMP_FLASH, buffer, size/sizeof(u32));
 
 	qlcnic_83xx_unlock_flash(adapter);
@@ -576,7 +576,7 @@ qlcnic_fw_flash_get_minidump_temp_size(struct qlcnic_adapter *adapter,
 	if (qlcnic_83xx_lock_flash(adapter))
 		return -EIO;
 
-	ret = qlcnic_83xx_lockless_flash_read_u32(adapter,
+	ret = qlcnic_83xx_lockless_flash_read32(adapter,
 			QLC_83XX_MINIDUMP_FLASH, (u8 *)&tmp_hdr, size);
 
 	qlcnic_83xx_unlock_flash(adapter);
@@ -678,7 +678,7 @@ qlcnic_fw_cmd_get_minidump_temp(struct qlcnic_adapter *adapter)
 					&temp_size, &use_flash_temp);
 
 	if (err) {
-		dev_info(&adapter->pdev->dev,
+		dev_err(&adapter->pdev->dev,
 			"Can't get template size %d\n", err);
 		return -EIO;
 	}
@@ -752,7 +752,8 @@ int qlcnic_dump_fw(struct qlcnic_adapter *adapter)
 		return -EIO;
 	}
 
-	QLCDB(adapter, DRV, "Take FW dump\n");
+	netif_info(adapter->ahw, drv, adapter->netdev,
+		"Take FW dump\n");
 	/* Calculate the size for dump data area only */
 	for (i = 2, k = 1; (i & QLCNIC_DUMP_MASK_MAX); i <<= 1, k++)
 		if (i & tmpl_hdr->drv_cap_mask)
@@ -762,7 +763,7 @@ int qlcnic_dump_fw(struct qlcnic_adapter *adapter)
 
 	fw_dump->data = vmalloc(dump_size);
 	if (!fw_dump->data) {
-		dev_info(&adapter->pdev->dev,
+		dev_err(&adapter->pdev->dev,
 			"Unable to allocate (%d KB) for fw dump\n",
 			dump_size/1024);
 		return -ENOMEM;
@@ -804,7 +805,7 @@ int qlcnic_dump_fw(struct qlcnic_adapter *adapter)
 		}
 
 		if (ops_index == ops_cnt) {
-			dev_info(&adapter->pdev->dev,
+			dev_err(&adapter->pdev->dev,
 				"Invalid entry type %d, exiting dump\n",
 				entry->hdr.type);
 			goto error;
@@ -819,7 +820,7 @@ int qlcnic_dump_fw(struct qlcnic_adapter *adapter)
 		buffer = fw_dump->data + buf_offset;
 	}
 	if (dump_size != buf_offset) {
-		dev_info(&adapter->pdev->dev,
+		dev_err(&adapter->pdev->dev,
 			"Captured(%d) and expected size(%d) do not match\n",
 			buf_offset, dump_size);
 		goto error;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
index 9f743bf..e8f021b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
@@ -35,7 +35,7 @@ qlcnic_show_bridged_mode(struct device *dev,
 	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_BDG)
 		bridged_mode = !!(adapter->flags & QLCNIC_BRIDGE_ENABLED);
 
-	return sprintf(buf, "%d\n", bridged_mode);
+	return snprintf(buf, sizeof(int), "%d\n", bridged_mode);
 }
 
 static struct device_attribute dev_attr_bridged_mode = {
@@ -66,7 +66,7 @@ qlcnic_show_diag_mode(struct device *dev,
 {
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 
-	return sprintf(buf, "%d\n",
+	return snprintf(buf, sizeof(u32), "%d\n",
 			!!(adapter->flags & QLCNIC_DIAG_ENABLED));
 }
 
@@ -83,7 +83,8 @@ qlcnic_validate_beacon(struct qlcnic_adapter *adapter, u16 beacon, u8 *state,
 	*rate = LSB(beacon);
 	*state = MSB(beacon);
 
-	QLCDB(adapter, DRV, "rate %x state %x\n", *rate, *state);
+	netif_info(adapter->ahw, drv, adapter->netdev,
+		"rate %x state %x\n", *rate, *state);
 
 	if (!*state) {
 		*rate = __QLCNIC_MAX_LED_RATE;
@@ -159,7 +160,7 @@ qlcnic_show_beacon(struct device *dev,
 {
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 
-	return sprintf(buf, "%d\n", adapter->ahw->beacon_state);
+	return snprintf(buf, sizeof(u8), "%d\n", adapter->ahw->beacon_state);
 }
 
 static struct device_attribute dev_attr_beacon = {
@@ -380,6 +381,9 @@ qlcnic_sysfs_read_pm_config(struct file *filp, struct kobject *kobj,
 	if (size != sizeof(pm_cfg))
 		return QL_STATUS_INVALID_PARAM;
 
+	memset(&pm_cfg, 0,
+		sizeof(struct qlcnic_pm_func_cfg) * QLCNIC_MAX_PCI_FUNC);
+
 	for (i = 0; i < adapter->ahw->act_pci_func; i++) {
 		pci_func = adapter->npars[i].pci_func;
 		pm_cfg[pci_func].action = adapter->npars[i].enable_pm;
@@ -401,6 +405,8 @@ validate_esw_config(struct qlcnic_adapter *adapter,
 
 	if (QLCNIC_IS_82XX(adapter))
 		op_mode = readl(adapter->ahw->pci_base0 + QLCNIC_DRV_OP_MODE);
+	else
+		op_mode = QLCRDX(adapter->ahw, QLC_83XX_DRV_OP_MODE);
 
 	for (i = 0; i < count; i++) {
 		pci_func = esw_cfg[i].pci_func;
@@ -415,6 +421,10 @@ validate_esw_config(struct qlcnic_adapter *adapter,
 		case QLCNIC_PORT_DEFAULTS:
 			if (QLCNIC_IS_82XX(adapter)) {
 				ret = QLC_DEV_GET_DRV(op_mode, pci_func);
+			} else {
+				ret = QLC_83XX_GET_FUNC_PRIVILEGE_LEVEL(
+							op_mode, pci_func);
+				esw_cfg[i].offload_flags = 0;
 			}
 
 			if (ret !=  QLCNIC_NON_PRIV_FUNC) {
@@ -531,6 +541,9 @@ qlcnic_sysfs_read_esw_config(struct file *file, struct kobject *kobj,
 	if (size != sizeof(esw_cfg))
 		return QL_STATUS_INVALID_PARAM;
 
+	memset(&esw_cfg, 0,
+		sizeof(struct qlcnic_esw_func_cfg) * QLCNIC_MAX_PCI_FUNC);
+
 	for (i = 0; i < adapter->ahw->act_pci_func; i++) {
 		pci_func = adapter->npars[i].pci_func;
 		esw_cfg[pci_func].pci_func = pci_func;
@@ -583,6 +596,7 @@ qlcnic_sysfs_write_npar_config(struct file *file, struct kobject *kobj,
 
 	for (i = 0; i < count ; i++) {
 		pci_func = np_cfg[i].pci_func;
+		memset(&nic_info, 0, sizeof(struct qlcnic_info));
 		ret = adapter->ahw->hw_ops->get_nic_info(adapter,
 						&nic_info, pci_func);
 		if (ret)
@@ -615,6 +629,10 @@ qlcnic_sysfs_read_npar_config(struct file *file, struct kobject *kobj,
 	if (size != sizeof(np_cfg))
 		return QL_STATUS_INVALID_PARAM;
 
+	memset(&nic_info, 0, sizeof(struct qlcnic_info));
+	memset(&np_cfg, 0, sizeof(struct qlcnic_npar_func_cfg) *
+			QLCNIC_MAX_PCI_FUNC);
+
 	for (i = 0; i < QLCNIC_MAX_PCI_FUNC ; i++) {
 		if (qlcnic_is_valid_nic_func(adapter, i) < 0)
 			continue;
@@ -771,6 +789,9 @@ qlcnic_sysfs_read_pci_config(struct file *file, struct kobject *kobj,
 	if (size != sizeof(pci_cfg))
 		return QL_STATUS_INVALID_PARAM;
 
+	memset(&pci_cfg, 0,
+		sizeof(struct qlcnic_pci_func_cfg) * QLCNIC_MAX_PCI_FUNC);
+
 	pci_info = kcalloc(QLCNIC_MAX_PCI_FUNC, sizeof(*pci_info), GFP_KERNEL);
 	if (!pci_info)
 		return -ENOMEM;
@@ -862,32 +883,32 @@ qlcnic_create_diag_entries(struct qlcnic_adapter *adapter)
 	struct device *dev = &adapter->pdev->dev;
 
 	if (device_create_bin_file(dev, &bin_attr_port_stats))
-		dev_info(dev, "failed to create port stats sysfs entry");
+		dev_err(dev, "failed to create port stats sysfs entry");
 
 	if (adapter->ahw->op_mode == QLCNIC_NON_PRIV_FUNC)
 		return;
 	if (device_create_file(dev, &dev_attr_diag_mode))
-		dev_info(dev, "failed to create diag_mode sysfs entry\n");
+		dev_err(dev, "failed to create diag_mode sysfs entry\n");
 	if (device_create_file(dev, &dev_attr_beacon))
-		dev_info(dev, "failed to create beacon sysfs entry");
+		dev_err(dev, "failed to create beacon sysfs entry");
 	if (device_create_bin_file(dev, &bin_attr_crb))
-		dev_info(dev, "failed to create crb sysfs entry\n");
+		dev_err(dev, "failed to create crb sysfs entry\n");
 	if (device_create_bin_file(dev, &bin_attr_mem))
-		dev_info(dev, "failed to create mem sysfs entry\n");
+		dev_err(dev, "failed to create mem sysfs entry\n");
 	if (device_create_bin_file(dev, &bin_attr_pci_config))
-		dev_info(dev, "failed to create pci config sysfs entry");
+		dev_err(dev, "failed to create pci config sysfs entry");
 	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED))
 		return;
 	if (device_create_bin_file(dev, &bin_attr_esw_config))
-		dev_info(dev, "failed to create esw config sysfs entry");
+		dev_err(dev, "failed to create esw config sysfs entry");
 	if (adapter->ahw->op_mode != QLCNIC_MGMT_FUNC)
 		return;
 	if (device_create_bin_file(dev, &bin_attr_npar_config))
-		dev_info(dev, "failed to create npar config sysfs entry");
+		dev_err(dev, "failed to create npar config sysfs entry");
 	if (device_create_bin_file(dev, &bin_attr_pm_config))
-		dev_info(dev, "failed to create pm config sysfs entry");
+		dev_err(dev, "failed to create pm config sysfs entry");
 	if (device_create_bin_file(dev, &bin_attr_esw_stats))
-		dev_info(dev, "failed to create eswitch stats sysfs entry");
+		dev_err(dev, "failed to create eswitch stats sysfs entry");
 }
 
 void
@@ -923,7 +944,7 @@ qlcnic_sysfs_validate_bar(struct qlcnic_adapter *adapter, loff_t offset,
 	if (!(adapter->flags & QLCNIC_DIAG_ENABLED))
 		return -EIO;
 
-	if (offset >= QLCNIC_83XX_BAR0_LENGTH || (offset & (bar - 1)) ||
+	if (offset >= QLC_83XX_BAR0_LENGTH || (offset & (bar - 1)) ||
 		(size != bar))
 		return -EINVAL;
 	return 0;
-- 
1.7.1
