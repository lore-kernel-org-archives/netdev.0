From: Robert Richter <rric@kernel.org>
Subject: [PATCH v2] VNIC: Adding support for Cavium ThunderX network controller
Date: Sun,  9 Nov 2014 21:14:05 -0800
Message-ID: <1415596445-10061-1-git-send-email-rric@kernel.org>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Stefan Assmann <sassmann@redhat.com>,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, Sunil Goutham <sgoutham@cavium.com>,
	Robert Richter <rrichter@cavium.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:57538 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833AbaKJFO3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 00:14:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sunil Goutham <sgoutham@cavium.com>

This patch adds support for the Cavium ThunderX network controller.
The driver is on the pci bus and thus requires the Thunder PCIe host
controller driver to be enabled.

v2:
 * non-generic module parameters removed
 * ethtool support added (nicvf_set_rxnfc())

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
Signed-off-by: Robert Richter <rrichter@cavium.com>
---
 MAINTAINERS                                        |    7 +
 arch/arm64/Kconfig                                 |    1 +
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/cavium/Kconfig                |   40 +
 drivers/net/ethernet/cavium/Makefile               |    5 +
 drivers/net/ethernet/cavium/thunder/Makefile       |   13 +
 drivers/net/ethernet/cavium/thunder/nic.h          |  434 +++++++
 drivers/net/ethernet/cavium/thunder/nic_main.c     |  807 ++++++++++++
 drivers/net/ethernet/cavium/thunder/nic_reg.h      |  214 ++++
 .../net/ethernet/cavium/thunder/nicvf_ethtool.c    |  559 +++++++++
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   | 1323 ++++++++++++++++++++
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 1302 +++++++++++++++++++
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h |  355 ++++++
 drivers/net/ethernet/cavium/thunder/q_struct.h     |  702 +++++++++++
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c  |  386 ++++++
 drivers/net/ethernet/cavium/thunder/thunder_bgx.h  |   78 ++
 include/linux/pci_ids.h                            |    2 +
 18 files changed, 6230 insertions(+)
 create mode 100644 drivers/net/ethernet/cavium/Kconfig
 create mode 100644 drivers/net/ethernet/cavium/Makefile
 create mode 100644 drivers/net/ethernet/cavium/thunder/Makefile
 create mode 100644 drivers/net/ethernet/cavium/thunder/nic.h
 create mode 100644 drivers/net/ethernet/cavium/thunder/nic_main.c
 create mode 100644 drivers/net/ethernet/cavium/thunder/nic_reg.h
 create mode 100644 drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
 create mode 100644 drivers/net/ethernet/cavium/thunder/nicvf_main.c
 create mode 100644 drivers/net/ethernet/cavium/thunder/nicvf_queues.c
 create mode 100644 drivers/net/ethernet/cavium/thunder/nicvf_queues.h
 create mode 100644 drivers/net/ethernet/cavium/thunder/q_struct.h
 create mode 100644 drivers/net/ethernet/cavium/thunder/thunder_bgx.c
 create mode 100644 drivers/net/ethernet/cavium/thunder/thunder_bgx.h

diff --git a/MAINTAINERS b/MAINTAINERS
index a20df9bf8ab0..9a36569d75df 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -882,6 +882,13 @@ M:	Krzysztof Halasa <khalasa@piap.pl>
 S:	Maintained
 F:	arch/arm/mach-cns3xxx/
 
+ARM/CAVIUM THUNDER ARCHITECTURE
+M:	Sunil Goutham <sgoutham@cavium.com>
+M:	Robert Richter <rric@kernel.org>
+L:	linux-arm-kernel@lists.infradead.org (moderated for non-subscribers)
+S:	Supported
+F:	drivers/net/ethernet/cavium/
+
 ARM/CIRRUS LOGIC CLPS711X ARM ARCHITECTURE
 M:	Alexander Shiyan <shc_work@mail.ru>
 L:	linux-arm-kernel@lists.infradead.org (moderated for non-subscribers)
diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index ac9afde76dea..bc14b1a78ae2 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -145,6 +145,7 @@ config ARCH_THUNDER
 	bool "Cavium Inc. Thunder SoC Family"
 	help
 	  This enables support for Cavium's Thunder Family of SoCs.
+	select NET_VENDOR_CAVIUM
 
 config ARCH_VEXPRESS
 	bool "ARMv8 software model (Versatile Express)"
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 1ed1fbba5d58..7c872ff82aed 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -34,6 +34,7 @@ source "drivers/net/ethernet/adi/Kconfig"
 source "drivers/net/ethernet/broadcom/Kconfig"
 source "drivers/net/ethernet/brocade/Kconfig"
 source "drivers/net/ethernet/calxeda/Kconfig"
+source "drivers/net/ethernet/cavium/Kconfig"
 source "drivers/net/ethernet/chelsio/Kconfig"
 source "drivers/net/ethernet/cirrus/Kconfig"
 source "drivers/net/ethernet/cisco/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 6e0b629e9859..7a9f7d7b55bf 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -20,6 +20,7 @@ obj-$(CONFIG_NET_BFIN) += adi/
 obj-$(CONFIG_NET_VENDOR_BROADCOM) += broadcom/
 obj-$(CONFIG_NET_VENDOR_BROCADE) += brocade/
 obj-$(CONFIG_NET_CALXEDA_XGMAC) += calxeda/
+obj-$(CONFIG_NET_VENDOR_CAVIUM) += cavium/
 obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
 obj-$(CONFIG_NET_VENDOR_CIRRUS) += cirrus/
 obj-$(CONFIG_NET_VENDOR_CISCO) += cisco/
diff --git a/drivers/net/ethernet/cavium/Kconfig b/drivers/net/ethernet/cavium/Kconfig
new file mode 100644
index 000000000000..6365fb4242be
--- /dev/null
+++ b/drivers/net/ethernet/cavium/Kconfig
@@ -0,0 +1,40 @@
+#
+# Cavium ethernet device configuration
+#
+
+config NET_VENDOR_CAVIUM
+	tristate "Cavium ethernet drivers"
+	depends on PCI
+	---help---
+	  Enable support for the Cavium ThunderX Network Interface
+	  Controller (NIC). The NIC provides the controller and DMA
+	  engines to move network traffic to/from the memory. The NIC
+	  works closely with TNS, BGX and SerDes to implement the
+	  functions replacing and virtualizing those of a typical
+	  standalone PCIe NIC chip.
+
+	  If you have a Cavium Thunder board, say Y.
+
+if NET_VENDOR_CAVIUM
+
+config THUNDER_NIC_PF
+	tristate "Thunder Physical function driver"
+	default NET_VENDOR_CAVIUM
+	select THUNDER_NIC_BGX
+	---help---
+	  This driver supports Thunder's NIC physical function.
+
+config THUNDER_NIC_VF
+	tristate "Thunder Virtual function driver"
+	default NET_VENDOR_CAVIUM
+	---help---
+	  This driver supports Thunder's NIC virtual function
+
+config	THUNDER_NIC_BGX
+	tristate "Thunder MAC interface driver (BGX)"
+	default NET_VENDOR_CAVIUM
+	---help---
+	  This driver supports programming and controlling of MAC
+	  interface from NIC physical function driver.
+
+endif # NET_VENDOR_CAVIUM
diff --git a/drivers/net/ethernet/cavium/Makefile b/drivers/net/ethernet/cavium/Makefile
new file mode 100644
index 000000000000..7aac4780d050
--- /dev/null
+++ b/drivers/net/ethernet/cavium/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the Cavium ethernet device drivers.
+#
+
+obj-$(CONFIG_NET_VENDOR_CAVIUM) += thunder/
diff --git a/drivers/net/ethernet/cavium/thunder/Makefile b/drivers/net/ethernet/cavium/thunder/Makefile
new file mode 100644
index 000000000000..8ee6e043f8ff
--- /dev/null
+++ b/drivers/net/ethernet/cavium/thunder/Makefile
@@ -0,0 +1,13 @@
+#
+# Makefile for Cavium's Thunder ethernet device
+#
+
+
+# Don't change the order, NICPF driver is dependent on BGX driver init
+obj-$(CONFIG_THUNDER_NIC_BGX) += thunder_bgx.o
+obj-$(CONFIG_THUNDER_NIC_PF) += nicpf.o
+obj-$(CONFIG_THUNDER_NIC_VF) += nicvf.o
+
+nicpf-y := nic_main.o
+nicvf-y := nicvf_main.o nicvf_queues.o
+nicvf-y += nicvf_ethtool.o
diff --git a/drivers/net/ethernet/cavium/thunder/nic.h b/drivers/net/ethernet/cavium/thunder/nic.h
new file mode 100644
index 000000000000..be3530ca9cf2
--- /dev/null
+++ b/drivers/net/ethernet/cavium/thunder/nic.h
@@ -0,0 +1,434 @@
+/*
+ * Copyright (C) 2014 Cavium, Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of
+ * the License, or (at your option) any later version.
+ */
+
+#ifndef NIC_H
+#define	NIC_H
+
+#include <linux/netdevice.h>
+#include <linux/interrupt.h>
+#include "thunder_bgx.h"
+
+/* PCI device IDs */
+#define	PCI_DEVICE_ID_THUNDER_NIC_PF	0xA01E
+#define	PCI_DEVICE_ID_THUNDER_NIC_VF	0x0011
+#define	PCI_DEVICE_ID_THUNDER_BGX	0xA026
+
+/* PCI BAR nos */
+#define	PCI_CFG_REG_BAR_NUM		0
+#define	PCI_MSIX_REG_BAR_NUM		4
+
+/* NIC SRIOV VF count */
+#define	MAX_NUM_VFS_SUPPORTED		128
+#define	DEFAULT_NUM_VF_ENABLED		8
+
+#define	NIC_TNS_BYPASS_MODE		0
+#define	NIC_TNS_MODE			1
+
+/* NIC priv flags */
+#define	NIC_SRIOV_ENABLED		(1 << 0)
+#define	NIC_TNS_ENABLED			(1 << 1)
+
+/* VNIC HW optimiation features */
+#undef	VNIC_RX_CSUM_OFFLOAD_SUPPORT
+#undef	VNIC_TX_CSUM_OFFLOAD_SUPPORT
+#define	VNIC_SG_SUPPORT
+#define	VNIC_TSO_SUPPORT
+#undef	VNIC_LRO_SUPPORT
+#undef  VNIC_RSS_SUPPORT
+
+/* TSO not supported in Thunder pass1 */
+#ifdef	VNIC_TSO_SUPPORT
+#define	VNIC_SW_TSO_SUPPORT
+#undef	VNIC_HW_TSO_SUPPORT
+#endif
+
+/* ETHTOOL enable or disable, undef this to disable */
+#define	NICVF_ETHTOOL_ENABLE
+
+/* Min/Max packet size */
+#define	NIC_HW_MIN_FRS			64
+#define	NIC_HW_MAX_FRS			9194 /* 9216 max packet including FCS */
+
+/* Max pkinds */
+#define	NIC_MAX_PKIND			16
+
+/* Rx Channels */
+/* Receive channel configuration in TNS bypass mode
+ * Below is configuration in TNS bypass mode
+ * BGX0-LMAC0-CHAN0 - VNIC CHAN0
+ * BGX0-LMAC1-CHAN0 - VNIC CHAN16
+ * ...
+ * BGX1-LMAC0-CHAN0 - VNIC CHAN128
+ * ...
+ * BGX1-LMAC3-CHAN0 - VNIC CHAN174
+ */
+#define	NIC_INF_COUNT			2  /* No of interfaces */
+#define	NIC_CHANS_PER_INF		128
+#define	NIC_MAX_CHANS			(NIC_INF_COUNT * NIC_CHANS_PER_INF)
+#define	NIC_CPI_COUNT			2048 /* No of channel parse indices */
+
+/* TNS bypass mode: 1-1 mapping between VNIC and BGX:LMAC */
+#define NIC_MAX_BGX			MAX_BGX_PER_CN88XX
+#define	NIC_CPI_PER_BGX			(NIC_CPI_COUNT / NIC_MAX_BGX)
+#define	NIC_MAX_CPI_PER_LMAC		64 /* Max when CPI_ALG is IP diffserv */
+#define	NIC_RSSI_PER_BGX		(NIC_RSSI_COUNT / NIC_MAX_BGX)
+
+/* Tx scheduling */
+#define	NIC_MAX_TL4			1024
+#define	NIC_MAX_TL4_SHAPERS		256 /* 1 shaper for 4 TL4s */
+#define	NIC_MAX_TL3			256
+#define	NIC_MAX_TL3_SHAPERS		64  /* 1 shaper for 4 TL3s */
+#define	NIC_MAX_TL2			64
+#define	NIC_MAX_TL2_SHAPERS		2  /* 1 shaper for 32 TL2s */
+#define	NIC_MAX_TL1			2
+
+/* TNS bypass mode */
+#define	NIC_TL4_PER_BGX			(NIC_MAX_TL4 / NIC_MAX_BGX)
+#define	NIC_TL4_PER_LMAC		(NIC_MAX_TL4 / NIC_CHANS_PER_INF)
+
+/* NIC VF Interrupts */
+#define	NICVF_INTR_CQ			0
+#define	NICVF_INTR_SQ			1
+#define	NICVF_INTR_RBDR			2
+#define	NICVF_INTR_PKT_DROP		3
+#define	NICVF_INTR_TCP_TIMER		4
+#define	NICVF_INTR_MBOX			5
+#define	NICVF_INTR_QS_ERR		6
+
+#define	NICVF_INTR_CQ_SHIFT		0
+#define	NICVF_INTR_SQ_SHIFT		8
+#define	NICVF_INTR_RBDR_SHIFT		16
+#define	NICVF_INTR_PKT_DROP_SHIFT	20
+#define	NICVF_INTR_TCP_TIMER_SHIFT	21
+#define	NICVF_INTR_MBOX_SHIFT		22
+#define	NICVF_INTR_QS_ERR_SHIFT		23
+
+#define	NICVF_INTR_CQ_MASK		(0xFF << NICVF_INTR_CQ_SHIFT)
+#define	NICVF_INTR_SQ_MASK		(0xFF << NICVF_INTR_SQ_SHIFT)
+#define	NICVF_INTR_RBDR_MASK		(0x03 << NICVF_INTR_RBDR_SHIFT)
+#define	NICVF_INTR_PKT_DROP_MASK	(1 << NICVF_INTR_PKT_DROP_SHIFT)
+#define	NICVF_INTR_TCP_TIMER_MASK	(1 << NICVF_INTR_TCP_TIMER_SHIFT)
+#define	NICVF_INTR_MBOX_MASK		(1 << NICVF_INTR_MBOX_SHIFT)
+#define	NICVF_INTR_QS_ERR_MASK		(1 << NICVF_INTR_QS_ERR_SHIFT)
+
+/* MSI-X interrupts */
+#define	NIC_PF_MSIX_VECTORS		10
+#define	NIC_VF_MSIX_VECTORS		20
+
+#define NIC_PF_INTR_ID_ECC0_SBE		0
+#define NIC_PF_INTR_ID_ECC0_DBE		1
+#define NIC_PF_INTR_ID_ECC1_SBE		2
+#define NIC_PF_INTR_ID_ECC1_DBE		3
+#define NIC_PF_INTR_ID_ECC2_SBE		4
+#define NIC_PF_INTR_ID_ECC2_DBE		5
+#define NIC_PF_INTR_ID_ECC3_SBE		6
+#define NIC_PF_INTR_ID_ECC3_DBE		7
+#define NIC_PF_INTR_ID_MBOX0		8
+#define NIC_PF_INTR_ID_MBOX1		9
+
+/* For CQ timer threshold interrupt */
+#define NIC_NS_PER_100_SYETEM_CLK	125
+#define NICPF_CLK_PER_INT_TICK		100
+
+struct nicvf_cq_poll {
+	uint8_t	cq_idx;		/* Completion queue index */
+	struct napi_struct napi;
+};
+
+#define	NIC_RSSI_COUNT			4096 /* Total no of RSS indices */
+#define NIC_MAX_RSS_HASH_BITS		8
+#define NIC_MAX_RSS_IDR_TBL_SIZE	(1 << NIC_MAX_RSS_HASH_BITS)
+#define RSS_HASH_KEY_SIZE		5 /* 320 bit key */
+
+#ifdef VNIC_RSS_SUPPORT
+struct nicvf_rss_info {
+	bool enable;
+#define	RSS_L2_EXTENDED_HASH_ENA	(1 << 0)
+#define	RSS_IP_HASH_ENA			(1 << 1)
+#define	RSS_TCP_HASH_ENA		(1 << 2)
+#define	RSS_TCP_SYN_DIS			(1 << 3)
+#define	RSS_UDP_HASH_ENA		(1 << 4)
+#define RSS_L4_EXTENDED_HASH_ENA	(1 << 5)
+#define	RSS_ROCE_ENA			(1 << 6)
+#define	RSS_L3_BI_DIRECTION_ENA		(1 << 7)
+#define	RSS_L4_BI_DIRECTION_ENA		(1 << 8)
+	uint64_t cfg;
+	uint8_t  hash_bits;
+	uint16_t rss_size;
+	uint8_t  ind_tbl[NIC_MAX_RSS_IDR_TBL_SIZE];
+	uint64_t key[RSS_HASH_KEY_SIZE];
+};
+#endif
+
+enum rx_stats_reg_offset {
+	RX_OCTS = 0x0,
+	RX_UCAST = 0x1,
+	RX_BCAST = 0x2,
+	RX_MCAST = 0x3,
+	RX_RED = 0x4,
+	RX_RED_OCTS = 0x5,
+	RX_ORUN = 0x6,
+	RX_ORUN_OCTS = 0x7,
+	RX_FCS = 0x8,
+	RX_L2ERR = 0x9,
+	RX_DRP_BCAST = 0xa,
+	RX_DRP_MCAST = 0xb,
+	RX_DRP_L3BCAST = 0xc,
+	RX_DRP_L3MCAST = 0xd,
+	RX_STATS_ENUM_LAST,
+};
+
+enum tx_stats_reg_offset {
+	TX_OCTS = 0x0,
+	TX_UCAST = 0x1,
+	TX_BCAST = 0x2,
+	TX_MCAST = 0x3,
+	TX_DROP = 0x4,
+	TX_STATS_ENUM_LAST,
+};
+
+struct nicvf_hw_stats {
+	u64 rx_bytes_ok;
+	u64 rx_ucast_frames_ok;
+	u64 rx_bcast_frames_ok;
+	u64 rx_mcast_frames_ok;
+	u64 rx_fcs_errors;
+	u64 rx_l2_errors;
+	u64 rx_drop_red;
+	u64 rx_drop_red_bytes;
+	u64 rx_drop_overrun;
+	u64 rx_drop_overrun_bytes;
+	u64 rx_drop_bcast;
+	u64 rx_drop_mcast;
+	u64 rx_drop_l3_bcast;
+	u64 rx_drop_l3_mcast;
+	u64 tx_bytes_ok;
+	u64 tx_ucast_frames_ok;
+	u64 tx_bcast_frames_ok;
+	u64 tx_mcast_frames_ok;
+	u64 tx_drops;
+};
+
+struct nicvf_drv_stats {
+	/* Rx */
+	u64 rx_frames_ok;
+	u64 rx_frames_64;
+	u64 rx_frames_127;
+	u64 rx_frames_255;
+	u64 rx_frames_511;
+	u64 rx_frames_1023;
+	u64 rx_frames_1518;
+	u64 rx_frames_jumbo;
+	u64 rx_drops;
+	/* Tx */
+	u64 tx_frames_ok;
+	u64 tx_drops;
+	u64 tx_busy;
+	u64 tx_tso;
+};
+
+struct nicvf {
+	struct net_device	*netdev;
+	struct pci_dev		*pdev;
+	uint8_t			vf_id;
+	uint8_t			tns_mode;
+	uint16_t		mtu;
+	struct queue_set	*qs;
+	uint8_t			num_qs;
+	void			*addnl_qs;
+	uint16_t		vf_mtu;
+	uint64_t		reg_base;
+	struct tasklet_struct	rbdr_task;
+	struct tasklet_struct	qs_err_task;
+	struct nicvf_cq_poll	*napi[8];
+#ifdef VNIC_RSS_SUPPORT
+	struct nicvf_rss_info	rss_info;
+#endif
+	uint8_t			cpi_alg;
+
+	struct nicvf_hw_stats   stats;
+	struct nicvf_drv_stats  drv_stats;
+	struct work_struct	reset_task;
+
+	/* MSI-X  */
+	bool			msix_enabled;
+	uint16_t		num_vec;
+	struct msix_entry	msix_entries[NIC_VF_MSIX_VECTORS];
+	char			irq_name[NIC_VF_MSIX_VECTORS][20];
+	uint8_t			irq_allocated[NIC_VF_MSIX_VECTORS];
+};
+
+struct nicpf {
+	struct net_device	*netdev;
+	struct pci_dev		*pdev;
+#define NIC_NODE_ID_MASK	0x300000000000
+#define NIC_NODE_ID(x)		((x & NODE_ID_MASK) >> 44)
+	uint8_t			node;
+	unsigned int		flags;
+	uint16_t		total_vf_cnt;   /* Total num of VF supported */
+	uint16_t		num_vf_en;      /* No of VF enabled */
+	uint64_t		reg_base;       /* Register start address */
+	struct pkind_cfg	pkind;
+	uint8_t			bgx_cnt;
+#define	NIC_SET_VF_LMAC_MAP(bgx, lmac)	(((bgx & 0xF) << 4) | (lmac & 0xF))
+#define	NIC_GET_BGX_FROM_VF_LMAC_MAP(map)	((map >> 4) & 0xF)
+#define	NIC_GET_LMAC_FROM_VF_LMAC_MAP(map)	(map & 0xF)
+	uint8_t			vf_lmac_map[MAX_LMAC];
+	uint16_t		cpi_base[MAX_NUM_VFS_SUPPORTED];
+	uint16_t		rss_ind_tbl_size;
+
+	/* MSI-X */
+	bool			msix_enabled;
+	uint16_t		num_vec;
+	struct msix_entry	msix_entries[NIC_PF_MSIX_VECTORS];
+	uint8_t			irq_allocated[NIC_PF_MSIX_VECTORS];
+};
+
+/* PF <--> VF Mailbox communication
+ * Eight 64bit registers are shared between PF and VF.
+ * Separate set for each VF.
+ * Writing '1' into last register mbx7 means end of message.
+ */
+
+/* PF <--> VF mailbox communication */
+#define	NIC_PF_VF_MAILBOX_SIZE		8
+#define	NIC_PF_VF_MBX_TIMEOUT		5000 /* ms */
+
+/* Mailbox message types */
+#define	NIC_PF_VF_MSG_READY		0x01	/* Is PF ready to rcv msgs */
+#define	NIC_PF_VF_MSG_ACK		0x02	/* ACK the message received */
+#define	NIC_PF_VF_MSG_NACK		0x03	/* NACK the message received */
+#define	NIC_PF_VF_MSG_QS_CFG		0x04	/* Configure Qset */
+#define	NIC_PF_VF_MSG_RQ_CFG		0x05	/* Configure receive queue */
+#define	NIC_PF_VF_MSG_SQ_CFG		0x06	/* Configure Send queue */
+#define	NIC_PF_VF_MSG_RQ_DROP_CFG	0x07	/* Configure receive queue */
+#define	NIC_PF_VF_MSG_SET_MAC		0x08	/* Add MAC ID to DMAC filter */
+#define	NIC_PF_VF_MSG_SET_MAX_FRS	0x09	/* Set max frame size */
+#define	NIC_PF_VF_MSG_CPI_CFG		0x0A	/* Config CPI, RSSI */
+#define	NIC_PF_VF_MSG_RSS_SIZE		0x0B	/* Get RSS indir_tbl size */
+#define	NIC_PF_VF_MSG_RSS_CFG		0x0C	/* Config RSS table */
+#define	NIC_PF_VF_MSG_RSS_CFG_CONT	0x0D	/* RSS config continuation */
+
+struct nic_cfg_msg {
+	uint64_t   vf_id;
+	uint64_t   tns_mode;
+	uint64_t   mac_addr;
+};
+
+/* Qset configuration */
+struct qs_cfg_msg {
+	uint64_t   num;
+	uint64_t   cfg;
+};
+
+/* Receive queue configuration */
+struct rq_cfg_msg {
+	uint64_t   qs_num;
+	uint64_t   rq_num;
+	uint64_t   cfg;
+};
+
+/* Send queue configuration */
+struct sq_cfg_msg {
+	uint64_t   qs_num;
+	uint64_t   sq_num;
+	uint64_t   cfg;
+};
+
+/* Set VF's MAC address */
+struct set_mac_msg {
+	uint64_t   vf_id;
+	uint64_t   addr;
+};
+
+/* Set Maximum frame size */
+struct set_frs_msg {
+	uint64_t   vf_id;
+	uint64_t   max_frs;
+};
+
+/* Set CPI algorithm type */
+struct cpi_cfg_msg {
+	uint64_t   vf_id;
+	uint64_t   rq_cnt;
+	uint64_t   cpi_alg;
+};
+
+#ifdef VNIC_RSS_SUPPORT
+/* Get RSS table size */
+struct rss_sz_msg {
+	uint64_t   vf_id;
+	uint64_t   ind_tbl_size;
+};
+
+/* Set RSS configuration */
+struct rss_cfg_msg {
+	uint8_t   vf_id;
+	uint8_t   hash_bits;
+	uint16_t  tbl_len;
+	uint16_t  tbl_offset;
+#define RSS_IND_TBL_LEN_PER_MBX_MSG	42
+	uint8_t   ind_tbl[RSS_IND_TBL_LEN_PER_MBX_MSG];
+};
+#endif
+
+/* Maximum 8 64bit locations */
+struct nic_mbx {
+#define	NIC_PF_VF_MBX_MSG_MASK		0xFFFF
+	uint16_t	   msg;
+#define	NIC_PF_VF_MBX_LOCK_OFFSET	0
+#define	NIC_PF_VF_MBX_LOCK_VAL(x)	((x >> 16) & 0xFFFF)
+#define	NIC_PF_VF_MBX_LOCK_CLEAR(x)	(x & ~(0xFFFF0000))
+#define	NIC_PF_VF_MBX_LOCK_SET(x)\
+	(NIC_PF_VF_MBX_LOCK_CLEAR(x) | (1 << 16))
+	uint16_t	   mbx_lock;
+	uint32_t	   unused;
+	union	{
+		struct nic_cfg_msg	nic_cfg;
+		struct qs_cfg_msg	qs;
+		struct rq_cfg_msg	rq;
+		struct sq_cfg_msg	sq;
+		struct set_mac_msg	mac;
+		struct set_frs_msg	frs;
+		struct cpi_cfg_msg	cpi_cfg;
+#ifdef VNIC_RSS_SUPPORT
+		struct rss_sz_msg	rss_size;
+		struct rss_cfg_msg	rss_cfg;
+#endif
+		uint64_t		rsvd[6];
+	} data;
+	uint64_t	   mbx_trigger_intr;
+};
+
+int nicvf_set_real_num_queues(struct net_device *netdev,
+			      int tx_queues, int rx_queues);
+int nicvf_open(struct net_device *netdev);
+int nicvf_stop(struct net_device *netdev);
+int nicvf_send_msg_to_pf(struct nicvf *vf, struct nic_mbx *mbx);
+void nicvf_config_cpi(struct nicvf *nic);
+#ifdef VNIC_RSS_SUPPORT
+void nicvf_config_rss(struct nicvf *nic);
+#endif
+void nicvf_free_skb(struct nicvf *nic, struct sk_buff *skb);
+#ifdef NICVF_ETHTOOL_ENABLE
+void nicvf_set_ethtool_ops(struct net_device *netdev);
+#endif
+void nicvf_update_stats(struct nicvf *nic);
+
+/* Debug */
+#undef	NIC_DEBUG
+
+#ifdef	NIC_DEBUG
+#define	nic_dbg(dev, fmt, arg...) \
+		dev_info(dev, fmt, ##arg)
+#else
+#define	nic_dbg(dev, fmt, arg...) do {} while (0)
+#endif
+
+#endif /* NIC_H */
diff --git a/drivers/net/ethernet/cavium/thunder/nic_main.c b/drivers/net/ethernet/cavium/thunder/nic_main.c
new file mode 100644
index 000000000000..ce43deec5014
--- /dev/null
+++ b/drivers/net/ethernet/cavium/thunder/nic_main.c
@@ -0,0 +1,807 @@
+/*
+ * Copyright (C) 2014 Cavium, Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of
+ * the License, or (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/interrupt.h>
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+
+#include "nic_reg.h"
+#include "nic.h"
+#include "q_struct.h"
+#include "thunder_bgx.h"
+
+#define DRV_NAME	"thunder-nic"
+#define DRV_VERSION	"1.0"
+
+static void nic_config_cpi(struct nicpf *nic, struct cpi_cfg_msg *cfg);
+#ifdef VNIC_RSS_SUPPORT
+static void nic_send_rss_size(struct nicpf *nic, int vf);
+static void nic_config_rss(struct nicpf *nic, struct rss_cfg_msg *cfg);
+#endif
+static void nic_tx_channel_cfg(struct nicpf *nic, int vnic, int sq_idx);
+static int nic_update_hw_frs(struct nicpf *nic, int new_frs, int vf);
+
+/* Supported devices */
+static const struct pci_device_id nic_id_table[] = {
+	{ PCI_DEVICE(PCI_VENDOR_ID_CAVIUM, PCI_DEVICE_ID_THUNDER_NIC_PF) },
+	{ 0, }  /* end of table */
+};
+
+MODULE_AUTHOR("Sunil Goutham");
+MODULE_DESCRIPTION("Cavium Thunder NIC Physical Function Driver");
+MODULE_LICENSE("GPL v2");
+MODULE_VERSION(DRV_VERSION);
+MODULE_DEVICE_TABLE(pci, nic_id_table);
+
+/* Register read/write APIs */
+static void nic_reg_write(struct nicpf *nic, uint64_t offset, uint64_t val)
+{
+	uint64_t addr = nic->reg_base + offset;
+
+	writeq_relaxed(val, (void *)addr);
+}
+
+static uint64_t nic_reg_read(struct nicpf *nic, uint64_t offset)
+{
+	uint64_t addr = nic->reg_base + offset;
+
+	return readq_relaxed((void *)addr);
+}
+
+/* PF -> VF mailbox communication APIs */
+static void nic_enable_mbx_intr(struct nicpf *nic)
+{
+	/* Enable mailbox interrupt for all 128 VFs */
+	nic_reg_write(nic, NIC_PF_MAILBOX_ENA_W1S, ~0x00ull);
+	nic_reg_write(nic, NIC_PF_MAILBOX_ENA_W1S + (1 << 3), ~0x00ull);
+}
+
+static uint64_t nic_get_mbx_intr_status(struct nicpf *nic, int mbx_reg)
+{
+	return nic_reg_read(nic, NIC_PF_MAILBOX_INT + (mbx_reg << 3));
+}
+
+static void nic_clear_mbx_intr(struct nicpf *nic, int vf, int mbx_reg)
+{
+	nic_reg_write(nic, NIC_PF_MAILBOX_INT + (mbx_reg << 3), (1ULL << vf));
+}
+
+static uint64_t nic_get_mbx_addr(int vf)
+{
+	return NIC_PF_VF_0_127_MAILBOX_0_7 + (vf << NIC_VF_NUM_SHIFT);
+}
+
+static int nic_lock_mbox(struct nicpf *nic, int vf)
+{
+	int timeout = NIC_PF_VF_MBX_TIMEOUT;
+	int sleep = 10;
+	uint64_t lock, mbx_addr;
+
+	mbx_addr = nic_get_mbx_addr(vf) + NIC_PF_VF_MBX_LOCK_OFFSET;
+	lock = NIC_PF_VF_MBX_LOCK_VAL(nic_reg_read(nic, mbx_addr));
+	while (lock) {
+		msleep(sleep);
+		lock = NIC_PF_VF_MBX_LOCK_VAL(nic_reg_read(nic, mbx_addr));
+		timeout -= sleep;
+		if (!timeout) {
+			netdev_err(nic->netdev, "PF couldn't lock mailbox\n");
+			return 0;
+		}
+	}
+	lock = nic_reg_read(nic, mbx_addr);
+	nic_reg_write(nic, mbx_addr, NIC_PF_VF_MBX_LOCK_SET(lock));
+	return 1;
+}
+
+void nic_release_mbx(struct nicpf *nic, int vf)
+{
+	uint64_t mbx_addr, lock;
+
+	mbx_addr = nic_get_mbx_addr(vf) + NIC_PF_VF_MBX_LOCK_OFFSET;
+	lock = nic_reg_read(nic, mbx_addr);
+	nic_reg_write(nic, mbx_addr, NIC_PF_VF_MBX_LOCK_CLEAR(lock));
+}
+
+static int nic_send_msg_to_vf(struct nicpf *nic, int vf,
+			      struct nic_mbx *mbx, bool lock_needed)
+{
+	int i;
+	uint64_t *msg;
+	uint64_t mbx_addr;
+
+	if (lock_needed && (!nic_lock_mbox(nic, vf)))
+		return -EBUSY;
+
+	mbx->mbx_trigger_intr = 1;
+	msg = (uint64_t *)mbx;
+	mbx_addr = nic->reg_base + nic_get_mbx_addr(vf);
+
+	for (i = 0; i < NIC_PF_VF_MAILBOX_SIZE; i++)
+		writeq_relaxed(*(msg + i), (void *)(mbx_addr + (i * 8)));
+
+	if (lock_needed)
+		nic_release_mbx(nic, vf);
+	return 0;
+}
+
+static void nic_mbx_send_ready(struct nicpf *nic, int vf)
+{
+	struct nic_mbx mbx = {};
+
+	/* Respond with VNIC ID */
+	mbx.msg = NIC_PF_VF_MSG_READY;
+	mbx.data.nic_cfg.vf_id = vf;
+
+	if (nic->flags & NIC_TNS_ENABLED)
+		mbx.data.nic_cfg.tns_mode = NIC_TNS_MODE;
+	else
+		mbx.data.nic_cfg.tns_mode = NIC_TNS_BYPASS_MODE;
+
+	nic_send_msg_to_vf(nic, vf, &mbx, false);
+}
+
+static void nic_mbx_send_ack(struct nicpf *nic, int vf)
+{
+	struct nic_mbx mbx = {};
+
+	mbx.msg = NIC_PF_VF_MSG_ACK;
+	nic_send_msg_to_vf(nic, vf, &mbx, false);
+}
+
+static void nic_mbx_send_nack(struct nicpf *nic, int vf)
+{
+	struct nic_mbx mbx = {};
+
+	mbx.msg = NIC_PF_VF_MSG_NACK;
+	nic_send_msg_to_vf(nic, vf, &mbx, false);
+}
+
+/* Handle Mailbox messages from VF and ack the message. */
+static void nic_handle_mbx_intr(struct nicpf *nic, int vf)
+{
+	struct nic_mbx mbx = {};
+	uint64_t *mbx_data;
+	uint64_t mbx_addr;
+	uint64_t reg_addr;
+	int bgx, lmac;
+	int i;
+	int ret = 0;
+
+	mbx_addr = nic_get_mbx_addr(vf);
+	mbx_data = (uint64_t *)&mbx;
+
+	for (i = 0; i < NIC_PF_VF_MAILBOX_SIZE; i++) {
+		*mbx_data = nic_reg_read(nic, mbx_addr);
+		mbx_data++;
+		mbx_addr += NIC_PF_VF_MAILBOX_SIZE;
+	}
+
+	mbx.msg &= NIC_PF_VF_MBX_MSG_MASK;
+	nic_dbg(&nic->pdev->dev, "%s: Mailbox msg %d from VF%d\n",
+		__func__, mbx.msg, vf);
+	switch (mbx.msg) {
+	case NIC_PF_VF_MSG_READY:
+		nic_mbx_send_ready(nic, vf);
+		ret = 1;
+		break;
+	case NIC_PF_VF_MSG_QS_CFG:
+		reg_addr = NIC_PF_QSET_0_127_CFG |
+			   (mbx.data.qs.num << NIC_QS_ID_SHIFT);
+		nic_reg_write(nic, reg_addr, mbx.data.qs.cfg);
+		break;
+	case NIC_PF_VF_MSG_RQ_CFG:
+		reg_addr = NIC_PF_QSET_0_127_RQ_0_7_CFG |
+			   (mbx.data.rq.qs_num << NIC_QS_ID_SHIFT) |
+			   (mbx.data.rq.rq_num << NIC_Q_NUM_SHIFT);
+		nic_reg_write(nic, reg_addr, mbx.data.rq.cfg);
+		break;
+	case NIC_PF_VF_MSG_RQ_DROP_CFG:
+		reg_addr = NIC_PF_QSET_0_127_RQ_0_7_DROP_CFG |
+			   (mbx.data.rq.qs_num << NIC_QS_ID_SHIFT) |
+			   (mbx.data.rq.rq_num << NIC_Q_NUM_SHIFT);
+		nic_reg_write(nic, reg_addr, mbx.data.rq.cfg);
+		break;
+	case NIC_PF_VF_MSG_SQ_CFG:
+		reg_addr = NIC_PF_QSET_0_127_SQ_0_7_CFG |
+			   (mbx.data.sq.qs_num << NIC_QS_ID_SHIFT) |
+			   (mbx.data.sq.sq_num << NIC_Q_NUM_SHIFT);
+		nic_reg_write(nic, reg_addr, mbx.data.sq.cfg);
+		nic_tx_channel_cfg(nic, mbx.data.qs.num, mbx.data.sq.sq_num);
+		break;
+	case NIC_PF_VF_MSG_SET_MAC:
+		lmac = mbx.data.mac.vf_id;
+		bgx = NIC_GET_BGX_FROM_VF_LMAC_MAP(nic->vf_lmac_map[lmac]);
+		lmac = NIC_GET_LMAC_FROM_VF_LMAC_MAP(nic->vf_lmac_map[lmac]);
+		bgx_add_dmac_addr(mbx.data.mac.addr, nic->node, bgx, lmac);
+		break;
+	case NIC_PF_VF_MSG_SET_MAX_FRS:
+		ret = nic_update_hw_frs(nic, mbx.data.frs.max_frs,
+					mbx.data.frs.vf_id);
+		break;
+	case NIC_PF_VF_MSG_CPI_CFG:
+		nic_config_cpi(nic, &mbx.data.cpi_cfg);
+		break;
+#ifdef VNIC_RSS_SUPPORT
+	case NIC_PF_VF_MSG_RSS_SIZE:
+		nic_send_rss_size(nic, vf);
+		break;
+	case NIC_PF_VF_MSG_RSS_CFG:
+	case NIC_PF_VF_MSG_RSS_CFG_CONT:
+		nic_config_rss(nic, &mbx.data.rss_cfg);
+		break;
+#endif
+	default:
+		netdev_err(nic->netdev,
+			   "Invalid msg from VF%d, msg 0x%x\n", vf, mbx.msg);
+		break;
+	}
+
+	if (!ret)
+		nic_mbx_send_ack(nic, vf);
+	else if (mbx.msg != NIC_PF_VF_MSG_READY)
+		nic_mbx_send_nack(nic, vf);
+}
+
+static int nic_update_hw_frs(struct nicpf *nic, int new_frs, int vf)
+{
+	if ((new_frs > NIC_HW_MAX_FRS) || (new_frs < NIC_HW_MIN_FRS)) {
+		netdev_err(nic->netdev,
+			   "Invalid MTU setting from VF%d rejected, should be between %d and %d\n",
+			   vf, NIC_HW_MIN_FRS, NIC_HW_MAX_FRS);
+		return 1;
+	}
+	new_frs += ETH_HLEN;
+	if (new_frs <= nic->pkind.maxlen)
+		return 0;
+
+	nic->pkind.maxlen = new_frs;
+	nic_reg_write(nic, NIC_PF_PKIND_0_15_CFG, *(uint64_t *)&nic->pkind);
+	return 0;
+}
+
+/* Set minimum transmit packet size */
+static void nic_set_tx_pkt_pad(struct nicpf *nic, int size)
+{
+	int lmac;
+	uint64_t lmac_cfg;
+
+	/* Max value that can be set is 60 */
+	if (size > 60)
+		size = 60;
+
+	for (lmac = 0; lmac < (MAX_BGX_PER_CN88XX * MAX_LMAC_PER_BGX); lmac++) {
+		lmac_cfg = nic_reg_read(nic, NIC_PF_LMAC_0_7_CFG | (lmac << 3));
+		lmac_cfg &= ~(0xF << 2);
+		lmac_cfg |= ((size / 4) << 2);
+		nic_reg_write(nic, NIC_PF_LMAC_0_7_CFG | (lmac << 3), lmac_cfg);
+	}
+}
+
+/* Function to check number of LMACs present and set VF to LMAC mapping.
+ * Mapping will be used while initializing channels.
+ */
+static void nic_set_lmac_vf_mapping(struct nicpf *nic)
+{
+	int bgx, bgx_count, next_bgx_lmac = 0;
+	int lmac, lmac_cnt = 0;
+
+	nic->num_vf_en = 0;
+	if (nic->flags & NIC_TNS_ENABLED) {
+		nic->num_vf_en = DEFAULT_NUM_VF_ENABLED;
+		return;
+	}
+
+	bgx_get_count(nic->node, &bgx_count);
+	for (bgx = 0; bgx < NIC_MAX_BGX; bgx++) {
+		if (!(bgx_count & (1 << bgx)))
+			continue;
+		nic->bgx_cnt++;
+		lmac_cnt = bgx_get_lmac_count(nic->node, bgx);
+		for (lmac = 0; lmac < lmac_cnt; lmac++)
+			nic->vf_lmac_map[next_bgx_lmac++] =
+						NIC_SET_VF_LMAC_MAP(bgx, lmac);
+		nic->num_vf_en += lmac_cnt;
+	}
+}
+
+static void nic_init_hw(struct nicpf *nic)
+{
+	int i;
+	uint64_t reg;
+
+	/* Reset NIC, incase if driver is repeatedly inserted and removed */
+	nic_reg_write(nic, NIC_PF_SOFT_RESET, 1);
+
+	/* Enable NIC HW block */
+	nic_reg_write(nic, NIC_PF_CFG, 1);
+
+	if (nic->flags & NIC_TNS_ENABLED) {
+		reg = NIC_TNS_MODE << 7;
+		reg |= 0x06;
+		nic_reg_write(nic, NIC_PF_INTF_0_1_SEND_CFG, reg);
+		reg &= ~0xFull;
+		reg |= 0x07;
+		nic_reg_write(nic, NIC_PF_INTF_0_1_SEND_CFG | (1 << 8), reg);
+	} else {
+		/* Disable TNS mode on both interfaces */
+		reg = NIC_TNS_BYPASS_MODE << 7;
+		reg |= 0x08; /* Block identifier */
+		nic_reg_write(nic, NIC_PF_INTF_0_1_SEND_CFG, reg);
+		reg &= ~0xFull;
+		reg |= 0x09;
+		nic_reg_write(nic, NIC_PF_INTF_0_1_SEND_CFG | (1 << 8), reg);
+	}
+
+	/* PKIND configuration */
+	nic->pkind.minlen = 0;
+	nic->pkind.maxlen = NIC_HW_MAX_FRS + ETH_HLEN;
+	nic->pkind.lenerr_en = 1;
+	nic->pkind.rx_hdr = 0;
+	nic->pkind.hdr_sl = 0;
+
+	for (i = 0; i < NIC_MAX_PKIND; i++)
+		nic_reg_write(nic, NIC_PF_PKIND_0_15_CFG | (i << 3),
+			      *(uint64_t *)&nic->pkind);
+
+	nic_set_tx_pkt_pad(nic, NIC_HW_MIN_FRS);
+
+	/* Disable backpressure for now */
+	for (i = 0; i < NIC_MAX_CHANS; i++)
+		nic_reg_write(nic, NIC_PF_CHAN_0_255_TX_CFG | (i << 3), 0);
+
+	/* Timer config */
+	nic_reg_write(nic, NIC_PF_INTR_TIMER_CFG, NICPF_CLK_PER_INT_TICK);
+}
+
+static void nic_config_cpi(struct nicpf *nic, struct cpi_cfg_msg *cfg)
+{
+	uint32_t vnic, bgx, lmac, chan;
+	uint32_t padd, cpi_count = 0;
+	uint64_t cpi_base, cpi, rssi_base, rssi;
+	uint8_t qset, rq_idx = 0;
+
+	vnic = cfg->vf_id;
+	bgx = NIC_GET_BGX_FROM_VF_LMAC_MAP(nic->vf_lmac_map[vnic]);
+	lmac = NIC_GET_LMAC_FROM_VF_LMAC_MAP(nic->vf_lmac_map[vnic]);
+
+	chan = (lmac * MAX_BGX_CHANS_PER_LMAC) + (bgx * NIC_CHANS_PER_INF);
+	cpi_base = (lmac * NIC_MAX_CPI_PER_LMAC) + (bgx * NIC_CPI_PER_BGX);
+	rssi_base = (lmac * nic->rss_ind_tbl_size) + (bgx * NIC_RSSI_PER_BGX);
+
+	/* Rx channel configuration */
+	nic_reg_write(nic, NIC_PF_CHAN_0_255_RX_CFG | (chan << 3),
+		      (cfg->cpi_alg << 62) | (cpi_base << 48));
+
+	if (cfg->cpi_alg == CPI_ALG_NONE)
+		cpi_count = 1;
+	else if (cfg->cpi_alg == CPI_ALG_VLAN) /* 3 bits of PCP */
+		cpi_count = 8;
+	else if (cfg->cpi_alg == CPI_ALG_VLAN16) /* 3 bits PCP + DEI */
+		cpi_count = 16;
+	else if (cfg->cpi_alg == CPI_ALG_DIFF) /* 6bits DSCP */
+		cpi_count = NIC_MAX_CPI_PER_LMAC;
+
+	/* RSS Qset, Qidx mapping */
+	qset = cfg->vf_id;
+	rssi = rssi_base;
+	for (; rssi < (rssi_base + cfg->rq_cnt); rssi++) {
+		nic_reg_write(nic, NIC_PF_RSSI_0_4097_RQ | (rssi << 3),
+			      (qset << 3) | rq_idx);
+		rq_idx++;
+	}
+
+	rssi = 0;
+	cpi = cpi_base;
+	for (; cpi < (cpi_base + cpi_count); cpi++) {
+		/* Determine port to channel adder */
+		if (cfg->cpi_alg != CPI_ALG_DIFF)
+			padd = cpi % cpi_count;
+		else
+			padd = cpi % 8; /* 3 bits CS out of 6bits DSCP */
+
+		/* Leave RSS_SIZE as '0' to disable RSS */
+		nic_reg_write(nic, NIC_PF_CPI_0_2047_CFG | (cpi << 3),
+			      (vnic << 24) | (padd << 16) | (rssi_base + rssi));
+
+		if ((rssi + 1) >= cfg->rq_cnt)
+			continue;
+
+		if (cfg->cpi_alg == CPI_ALG_VLAN)
+			rssi++;
+		else if (cfg->cpi_alg == CPI_ALG_VLAN16)
+			rssi = ((cpi - cpi_base) & 0xe) >> 1;
+		else if (cfg->cpi_alg == CPI_ALG_DIFF)
+			rssi = ((cpi - cpi_base) & 0x38) >> 3;
+	}
+	nic->cpi_base[cfg->vf_id] = cpi_base;
+}
+
+#ifdef VNIC_RSS_SUPPORT
+static void nic_send_rss_size(struct nicpf *nic, int vf)
+{
+	struct nic_mbx mbx = {};
+
+	mbx.msg = NIC_PF_VF_MSG_RSS_SIZE;
+	mbx.data.rss_size.ind_tbl_size = nic->rss_ind_tbl_size;
+	nic_send_msg_to_vf(nic, vf, &mbx, false);
+}
+
+static void nic_config_rss(struct nicpf *nic, struct rss_cfg_msg *cfg)
+{
+	uint64_t cpi_cfg, cpi_base, rssi_base, rssi;
+	uint8_t qset, idx = 0;
+
+	cpi_base = nic->cpi_base[cfg->vf_id];
+	cpi_cfg = nic_reg_read(nic, NIC_PF_CPI_0_2047_CFG | (cpi_base << 3));
+	rssi_base = cpi_cfg & 0x0FFF;
+
+	rssi = rssi_base + cfg->tbl_offset;
+	qset = cfg->vf_id;
+
+	for (; rssi < (rssi_base + cfg->tbl_len); rssi++) {
+		nic_reg_write(nic, NIC_PF_RSSI_0_4097_RQ | (rssi << 3),
+			      (qset << 3) | cfg->ind_tbl[idx]);
+		idx++;
+	}
+
+	cpi_cfg &= ~(0xFULL << 20);
+	cpi_cfg |= (cfg->hash_bits << 20);
+	nic_reg_write(nic, NIC_PF_CPI_0_2047_CFG | (cpi_base << 3), cpi_cfg);
+}
+#endif
+
+/* Transmit channel configuration (TL4 -> TL3 -> Chan)
+ * VNIC0-SQ0 -> TL4(0)  -> TL4A(0) -> TL3[0] -> BGX0/LMAC0/Chan0
+ * VNIC1-SQ0 -> TL4(8)  -> TL4A(2) -> TL3[2] -> BGX0/LMAC1/Chan0
+ * VNIC2-SQ0 -> TL4(16) -> TL4A(4) -> TL3[4] -> BGX0/LMAC2/Chan0
+ * VNIC3-SQ0 -> TL4(32) -> TL4A(6) -> TL3[6] -> BGX0/LMAC3/Chan0
+ * VNIC4-SQ0 -> TL4(512)  -> TL4A(128) -> TL3[128] -> BGX1/LMAC0/Chan0
+ * VNIC5-SQ0 -> TL4(520)  -> TL4A(130) -> TL3[130] -> BGX1/LMAC1/Chan0
+ * VNIC6-SQ0 -> TL4(528)  -> TL4A(132) -> TL3[132] -> BGX1/LMAC2/Chan0
+ * VNIC7-SQ0 -> TL4(536)  -> TL4A(134) -> TL3[134] -> BGX1/LMAC3/Chan0
+ */
+static void nic_tx_channel_cfg(struct nicpf *nic, int vnic, int sq_idx)
+{
+	uint32_t bgx, lmac, tl3, tl4;
+
+	bgx = NIC_GET_BGX_FROM_VF_LMAC_MAP(nic->vf_lmac_map[vnic]);
+	lmac = NIC_GET_LMAC_FROM_VF_LMAC_MAP(nic->vf_lmac_map[vnic]);
+
+	tl4 = (lmac * NIC_TL4_PER_LMAC) + (bgx * NIC_TL4_PER_BGX);
+	tl4 += sq_idx;
+
+	tl3 = tl4 / (NIC_MAX_TL4 / NIC_MAX_TL3);
+	nic_reg_write(nic, NIC_PF_QSET_0_127_SQ_0_7_CFG2 |
+				(vnic << NIC_QS_ID_SHIFT) |
+				(sq_idx << NIC_Q_NUM_SHIFT), tl4);
+	nic_reg_write(nic, NIC_PF_TL4_0_1023_CFG | (tl4 << 3),
+		      (vnic << 27) | (sq_idx << 24));
+	nic_reg_write(nic, NIC_PF_TL4A_0_255_CFG | (tl3 << 3), tl3);
+	nic_reg_write(nic, NIC_PF_TL3_0_255_CHAN | (tl3 << 3), lmac << 4);
+}
+
+static irqreturn_t nic_mbx0_intr_handler (int irq, void *nic_irq)
+{
+	int vf;
+	uint16_t vf_per_mbx_reg = 64;
+	uint64_t intr;
+	struct nicpf *nic = (struct nicpf *)nic_irq;
+
+	intr = nic_get_mbx_intr_status(nic, 0);
+	nic_dbg(&nic->pdev->dev, "PF MSIX interrupt Mbox0 0x%llx\n", intr);
+	for (vf = 0; vf < min(nic->num_vf_en, vf_per_mbx_reg); vf++) {
+		if (intr & (1ULL << vf)) {
+			nic_dbg(&nic->pdev->dev, "Intr from VF %d\n", vf);
+			nic_handle_mbx_intr(nic, vf);
+			nic_clear_mbx_intr(nic, vf, 0);
+		}
+	}
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t nic_mbx1_intr_handler (int irq, void *nic_irq)
+{
+	int vf;
+	uint16_t vf_per_mbx_reg = 64;
+	uint64_t intr;
+	struct nicpf *nic = (struct nicpf *)nic_irq;
+
+	if (nic->num_vf_en <= vf_per_mbx_reg)
+		return IRQ_HANDLED;
+
+	intr = nic_get_mbx_intr_status(nic, 1);
+	nic_dbg(&nic->pdev->dev, "PF MSIX interrupt Mbox1 0x%llx\n", intr);
+	for (vf = 0; vf < (nic->num_vf_en - vf_per_mbx_reg); vf++) {
+		if (intr & (1ULL << vf)) {
+			nic_dbg(&nic->pdev->dev,
+				"Intr from VF %d\n", vf + vf_per_mbx_reg);
+			nic_handle_mbx_intr(nic, vf + vf_per_mbx_reg);
+			nic_clear_mbx_intr(nic, vf, 1);
+		}
+	}
+
+	return IRQ_HANDLED;
+}
+
+static int nic_enable_msix(struct nicpf *nic)
+{
+	int i, ret;
+
+	nic->num_vec = NIC_PF_MSIX_VECTORS;
+
+	for (i = 0; i < nic->num_vec; i++)
+		nic->msix_entries[i].entry = i;
+
+	ret = pci_enable_msix(nic->pdev, nic->msix_entries, nic->num_vec);
+	if (ret) {
+		netdev_err(nic->netdev,
+			   "Request for #%d msix vectors failed\n",
+			   nic->num_vec);
+		return 0;
+	}
+
+	nic->msix_enabled = 1;
+	return 1;
+}
+
+static void nic_disable_msix(struct nicpf *nic)
+{
+	if (nic->msix_enabled) {
+		pci_disable_msix(nic->pdev);
+		nic->msix_enabled = 0;
+		nic->num_vec = 0;
+	}
+}
+
+static int nic_register_interrupts(struct nicpf *nic)
+{
+	int irq, ret = 0;
+
+	/* Enable MSI-X */
+	if (!nic_enable_msix(nic))
+		return 1;
+
+	/* Register mailbox interrupt handlers */
+	ret = request_irq(nic->msix_entries[NIC_PF_INTR_ID_MBOX0].vector,
+			  nic_mbx0_intr_handler, 0 , "NIC Mbox0", nic);
+	if (ret)
+		goto fail;
+	else
+		nic->irq_allocated[NIC_PF_INTR_ID_MBOX0] = 1;
+
+	ret = request_irq(nic->msix_entries[NIC_PF_INTR_ID_MBOX1].vector,
+			  nic_mbx1_intr_handler, 0 , "NIC Mbox1", nic);
+	if (ret)
+		goto fail;
+	else
+		nic->irq_allocated[NIC_PF_INTR_ID_MBOX1] = 1;
+
+	/* Enable mailbox interrupt */
+	nic_enable_mbx_intr(nic);
+	return 0;
+fail:
+	netdev_err(nic->netdev, "Request irq failed\n");
+	for (irq = 0; irq < nic->num_vec; irq++) {
+		if (nic->irq_allocated[irq])
+			free_irq(nic->msix_entries[irq].vector, nic);
+		nic->irq_allocated[irq] = 0;
+	}
+	return 1;
+}
+
+static void nic_unregister_interrupts(struct nicpf *nic)
+{
+	int irq;
+
+	/* Free registered interrupts */
+	for (irq = 0; irq < nic->num_vec; irq++) {
+		if (nic->irq_allocated[irq])
+			free_irq(nic->msix_entries[irq].vector, nic);
+		nic->irq_allocated[irq] = 0;
+	}
+
+	/* Disable MSI-X */
+	nic_disable_msix(nic);
+}
+
+int nic_sriov_configure(struct pci_dev *pdev, int num_vfs_requested)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct nicpf *nic = netdev_priv(netdev);
+	int err;
+
+	if (nic->num_vf_en == num_vfs_requested)
+		return num_vfs_requested;
+
+	if (nic->flags & NIC_SRIOV_ENABLED) {
+		pci_disable_sriov(pdev);
+		nic->flags &= ~NIC_SRIOV_ENABLED;
+	}
+
+	nic->num_vf_en = 0;
+	if (num_vfs_requested > MAX_NUM_VFS_SUPPORTED)
+		return -EPERM;
+
+	if (num_vfs_requested) {
+		err = pci_enable_sriov(pdev, num_vfs_requested);
+		if (err) {
+			dev_err(&pdev->dev, "SRIOV, Failed to enable %d VFs\n",
+				num_vfs_requested);
+			return err;
+		}
+		nic->num_vf_en = num_vfs_requested;
+		nic->flags |= NIC_SRIOV_ENABLED;
+	}
+
+	return num_vfs_requested;
+}
+
+static int nic_sriov_init(struct pci_dev *pdev, struct nicpf *nic)
+{
+	int    pos = 0;
+
+	pos = pci_find_ext_capability(pdev, PCI_EXT_CAP_ID_SRIOV);
+	if (!pos) {
+		dev_err(&pdev->dev, "SRIOV capability is not found in PCIe config space\n");
+		return 0;
+	}
+
+	pci_read_config_word(pdev, (pos + PCI_SRIOV_TOTAL_VF),
+			     &nic->total_vf_cnt);
+	if (nic->total_vf_cnt < nic->num_vf_en)
+		nic->num_vf_en = nic->total_vf_cnt;
+
+	if (nic->total_vf_cnt && pci_enable_sriov(pdev, nic->num_vf_en)) {
+		dev_err(&pdev->dev, "SRIOV enable failed, num VF is %d\n",
+			nic->num_vf_en);
+		nic->num_vf_en = 0;
+		return 0;
+	}
+	dev_info(&pdev->dev, "SRIOV enabled, numer of VF available %d\n",
+		 nic->num_vf_en);
+
+	nic->flags |= NIC_SRIOV_ENABLED;
+	return 1;
+}
+
+static int nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
+{
+	struct device *dev = &pdev->dev;
+	struct net_device *netdev;
+	struct nicpf *nic;
+	int    err;
+
+	netdev = alloc_etherdev(sizeof(struct nicpf));
+	if (!netdev)
+		return -ENOMEM;
+
+	pci_set_drvdata(pdev, netdev);
+
+	SET_NETDEV_DEV(netdev, &pdev->dev);
+
+	nic = netdev_priv(netdev);
+	nic->netdev = netdev;
+	nic->pdev = pdev;
+
+	err = pci_enable_device(pdev);
+	if (err) {
+		dev_err(dev, "Failed to enable PCI device\n");
+		goto exit;
+	}
+
+	err = pci_request_regions(pdev, DRV_NAME);
+	if (err) {
+		dev_err(dev, "PCI request regions failed 0x%x\n", err);
+		goto err_disable_device;
+	}
+
+	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(48));
+	if (err) {
+		dev_err(dev, "Unable to get usable DMA configuration\n");
+		goto err_release_regions;
+	}
+
+	err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(48));
+	if (err) {
+		dev_err(dev, "unable to get 48-bit DMA for consistent allocations\n");
+		goto err_release_regions;
+	}
+
+	/* MAP PF's configuration registers */
+	nic->reg_base = (uint64_t)pci_ioremap_bar(pdev, PCI_CFG_REG_BAR_NUM);
+	if (!nic->reg_base) {
+		dev_err(dev, "Cannot map config register space, aborting\n");
+		err = -ENOMEM;
+		goto err_release_regions;
+	}
+	nic->node = NIC_NODE_ID(pci_resource_start(pdev, PCI_CFG_REG_BAR_NUM));
+
+	/* By default set NIC in TNS bypass mode */
+	nic->flags &= ~NIC_TNS_ENABLED;
+	nic_set_lmac_vf_mapping(nic);
+
+	/* Initialize hardware */
+	nic_init_hw(nic);
+
+	/* Set RSS TBL size for each VF */
+	nic->rss_ind_tbl_size = max((NIC_RSSI_COUNT / nic->num_vf_en),
+				    NIC_MAX_RSS_IDR_TBL_SIZE);
+	nic->rss_ind_tbl_size = rounddown_pow_of_two(nic->rss_ind_tbl_size);
+
+	/* Register interrupts */
+	if (nic_register_interrupts(nic))
+		goto err_unmap_resources;
+
+	/* Configure SRIOV */
+	if (!nic_sriov_init(pdev, nic))
+		goto err_unmap_resources;
+
+	goto exit;
+
+err_unmap_resources:
+	if (nic->reg_base)
+		iounmap((void *)nic->reg_base);
+err_release_regions:
+	pci_release_regions(pdev);
+err_disable_device:
+	pci_disable_device(pdev);
+exit:
+	return err;
+}
+
+static void nic_remove(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct nicpf *nic;
+
+	if (!netdev)
+		return;
+
+	nic = netdev_priv(netdev);
+
+	nic_unregister_interrupts(nic);
+
+	if (nic->flags & NIC_SRIOV_ENABLED)
+		pci_disable_sriov(pdev);
+
+	pci_set_drvdata(pdev, NULL);
+
+	if (nic->reg_base)
+		iounmap((void *)nic->reg_base);
+
+	pci_release_regions(pdev);
+	pci_disable_device(pdev);
+	free_netdev(netdev);
+}
+
+static struct pci_driver nic_driver = {
+	.name = DRV_NAME,
+	.id_table = nic_id_table,
+	.probe = nic_probe,
+	.remove = nic_remove,
+	.sriov_configure = nic_sriov_configure,
+};
+
+static int __init nic_init_module(void)
+{
+	pr_info("%s, ver %s\n", DRV_NAME, DRV_VERSION);
+
+	return pci_register_driver(&nic_driver);
+}
+
+static void __exit nic_cleanup_module(void)
+{
+	pci_unregister_driver(&nic_driver);
+}
+
+module_init(nic_init_module);
+module_exit(nic_cleanup_module);
diff --git a/drivers/net/ethernet/cavium/thunder/nic_reg.h b/drivers/net/ethernet/cavium/thunder/nic_reg.h
new file mode 100644
index 000000000000..cbf1c9f73ef1
--- /dev/null
+++ b/drivers/net/ethernet/cavium/thunder/nic_reg.h
@@ -0,0 +1,214 @@
+/*
+ * Copyright (C) 2014 Cavium, Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of
+ * the License, or (at your option) any later version.
+ */
+
+#ifndef NIC_REG_H
+#define NIC_REG_H
+
+#define   NIC_PF_REG_COUNT			29573
+#define   NIC_VF_REG_COUNT			249
+
+/* Physical function register offsets */
+#define   NIC_PF_CFG				(0x0000)
+#define   NIC_PF_STATUS				(0x0010)
+#define   NIC_PF_INTR_TIMER_CFG			(0x0030)
+#define   NIC_PF_BIST_STATUS			(0x0040)
+#define   NIC_PF_SOFT_RESET			(0x0050)
+#define   NIC_PF_TCP_TIMER			(0x0060)
+#define   NIC_PF_BP_CFG				(0x0080)
+#define   NIC_PF_RRM_CFG			(0x0088)
+#define   NIC_PF_CQM_CF				(0x00A0)
+#define   NIC_PF_CNM_CF				(0x00A8)
+#define   NIC_PF_CNM_STATUS			(0x00B0)
+#define   NIC_PF_CQ_AVG_CFG			(0x00C0)
+#define   NIC_PF_RRM_AVG_CFG			(0x00C8)
+#define   NIC_PF_INTF_0_1_SEND_CFG		(0x0200)
+#define   NIC_PF_INTF_0_1_BP_CFG		(0x0208)
+#define   NIC_PF_INTF_0_1_BP_DIS_0_1		(0x0210)
+#define   NIC_PF_INTF_0_1_BP_SW_0_1		(0x0220)
+#define   NIC_PF_RBDR_BP_STATE_0_3		(0x0240)
+#define   NIC_PF_MAILBOX_INT			(0x0410)
+#define   NIC_PF_MAILBOX_INT_W1S		(0x0430)
+#define   NIC_PF_MAILBOX_ENA_W1C		(0x0450)
+#define   NIC_PF_MAILBOX_ENA_W1S		(0x0470)
+#define   NIC_PF_RX_ETYPE_0_7			(0x0500)
+#define   NIC_PF_PKIND_0_15_CFG			(0x0600)
+#define   NIC_PF_ECC0_FLIP0			(0x1000)
+#define   NIC_PF_ECC1_FLIP0			(0x1008)
+#define   NIC_PF_ECC2_FLIP0			(0x1010)
+#define   NIC_PF_ECC3_FLIP0			(0x1018)
+#define   NIC_PF_ECC0_FLIP1			(0x1080)
+#define   NIC_PF_ECC1_FLIP1			(0x1088)
+#define   NIC_PF_ECC2_FLIP1			(0x1090)
+#define   NIC_PF_ECC3_FLIP1			(0x1098)
+#define   NIC_PF_ECC0_CDIS			(0x1100)
+#define   NIC_PF_ECC1_CDIS			(0x1108)
+#define   NIC_PF_ECC2_CDIS			(0x1110)
+#define   NIC_PF_ECC3_CDIS			(0x1118)
+#define   NIC_PF_BIST0_STATUS			(0x1280)
+#define   NIC_PF_BIST1_STATUS			(0x1288)
+#define   NIC_PF_BIST2_STATUS			(0x1290)
+#define   NIC_PF_BIST3_STATUS			(0x1298)
+#define   NIC_PF_ECC0_SBE_INT			(0x2000)
+#define   NIC_PF_ECC0_SBE_INT_W1S		(0x2008)
+#define   NIC_PF_ECC0_SBE_ENA_W1C		(0x2010)
+#define   NIC_PF_ECC0_SBE_ENA_W1S		(0x2018)
+#define   NIC_PF_ECC0_DBE_INT			(0x2100)
+#define   NIC_PF_ECC0_DBE_INT_W1S		(0x2108)
+#define   NIC_PF_ECC0_DBE_ENA_W1C		(0x2110)
+#define   NIC_PF_ECC0_DBE_ENA_W1S		(0x2118)
+#define   NIC_PF_ECC1_SBE_INT			(0x2200)
+#define   NIC_PF_ECC1_SBE_INT_W1S		(0x2208)
+#define   NIC_PF_ECC1_SBE_ENA_W1C		(0x2210)
+#define   NIC_PF_ECC1_SBE_ENA_W1S		(0x2218)
+#define   NIC_PF_ECC1_DBE_INT			(0x2300)
+#define   NIC_PF_ECC1_DBE_INT_W1S		(0x2308)
+#define   NIC_PF_ECC1_DBE_ENA_W1C		(0x2310)
+#define   NIC_PF_ECC1_DBE_ENA_W1S		(0x2318)
+#define   NIC_PF_ECC2_SBE_INT			(0x2400)
+#define   NIC_PF_ECC2_SBE_INT_W1S		(0x2408)
+#define   NIC_PF_ECC2_SBE_ENA_W1C		(0x2410)
+#define   NIC_PF_ECC2_SBE_ENA_W1S		(0x2418)
+#define   NIC_PF_ECC2_DBE_INT			(0x2500)
+#define   NIC_PF_ECC2_DBE_INT_W1S		(0x2508)
+#define   NIC_PF_ECC2_DBE_ENA_W1C		(0x2510)
+#define   NIC_PF_ECC2_DBE_ENA_W1S		(0x2518)
+#define   NIC_PF_ECC3_SBE_INT			(0x2600)
+#define   NIC_PF_ECC3_SBE_INT_W1S		(0x2608)
+#define   NIC_PF_ECC3_SBE_ENA_W1C		(0x2610)
+#define   NIC_PF_ECC3_SBE_ENA_W1S		(0x2618)
+#define   NIC_PF_ECC3_DBE_INT			(0x2700)
+#define   NIC_PF_ECC3_DBE_INT_W1S		(0x2708)
+#define   NIC_PF_ECC3_DBE_ENA_W1C		(0x2710)
+#define   NIC_PF_ECC3_DBE_ENA_W1S		(0x2718)
+#define   NIC_PF_CPI_0_2047_CFG			(0x200000)
+#define   NIC_PF_RSSI_0_4097_RQ			(0x220000)
+#define   NIC_PF_LMAC_0_7_CFG			(0x240000)
+#define   NIC_PF_LMAC_0_7_SW_XOFF		(0x242000)
+#define   NIC_PF_LMAC_0_7_CREDIT		(0x244000)
+#define   NIC_PF_CHAN_0_255_TX_CFG		(0x400000)
+#define   NIC_PF_CHAN_0_255_RX_CFG		(0x420000)
+#define   NIC_PF_CHAN_0_255_SW_XOFF		(0x440000)
+#define   NIC_PF_CHAN_0_255_CREDIT		(0x460000)
+#define   NIC_PF_CHAN_0_255_RX_BP_CFG		(0x480000)
+#define   NIC_PF_SW_SYNC_RX			(0x490000)
+#define   NIC_PF_SW_SYNC_RX_DONE		(0x490008)
+#define   NIC_PF_TL2_0_63_CFG			(0x500000)
+#define   NIC_PF_TL2_0_63_PRI			(0x520000)
+#define   NIC_PF_TL2_0_63_SH_STATUS		(0x580000)
+#define   NIC_PF_TL3A_0_63_CFG			(0x5F0000)
+#define   NIC_PF_TL3_0_255_CFG			(0x600000)
+#define   NIC_PF_TL3_0_255_CHAN			(0x620000)
+#define   NIC_PF_TL3_0_255_PIR			(0x640000)
+#define   NIC_PF_TL3_0_255_SW_XOFF		(0x660000)
+#define   NIC_PF_TL3_0_255_CNM_RATE		(0x680000)
+#define   NIC_PF_TL3_0_255_SH_STATUS		(0x6A0000)
+#define   NIC_PF_TL4A_0_255_CFG			(0x6F0000)
+#define   NIC_PF_TL4_0_1023_CFG			(0x800000)
+#define   NIC_PF_TL4_0_1023_SW_XOFF		(0x820000)
+#define   NIC_PF_TL4_0_1023_SH_STATUS		(0x840000)
+#define   NIC_PF_TL4A_0_1023_CNM_RATE		(0x880000)
+#define   NIC_PF_TL4A_0_1023_CNM_STATUS		(0x8A0000)
+#define   NIC_PF_VF_0_127_MAILBOX_0_7		(0x20002000)
+#define   NIC_PF_VNIC_0_127_TX_STAT_0_4		(0x20004000)
+#define   NIC_PF_VNIC_0_127_RX_STAT_0_13	(0x20004100)
+#define   NIC_PF_QSET_0_127_LOCK_0_15		(0x20006000)
+#define   NIC_PF_QSET_0_127_CFG			(0x20010000)
+#define   NIC_PF_QSET_0_127_RQ_0_7_CFG		(0x20010400)
+#define   NIC_PF_QSET_0_127_RQ_0_7_DROP_CFG	(0x20010420)
+#define   NIC_PF_QSET_0_127_RQ_0_7_BP_CFG	(0x20010500)
+#define   NIC_PF_QSET_0_127_RQ_0_7_STAT_0_1	(0x20010600)
+#define   NIC_PF_QSET_0_127_SQ_0_7_CFG		(0x20010C00)
+#define   NIC_PF_QSET_0_127_SQ_0_7_CFG2		(0x20010C08)
+#define   NIC_PF_QSET_0_127_SQ_0_7_STAT_0_1	(0x20010D00)
+
+#define   NIC_PF_MSIX_VEC_0_18_ADDR		(0x000000)
+#define   NIC_PF_MSIX_VEC_0_CTL			(0x000008)
+#define   NIC_PF_MSIX_PBA_0			(0x0F0000)
+
+/* Virtual function register offsets */
+#define   NIC_VNIC_CFG				(0x000020)
+#define   NIC_VF_PF_MAILBOX_0_7			(0x000100)
+#define   NIC_VF_INT				(0x000200)
+#define   NIC_VF_INT_W1S			(0x000220)
+#define   NIC_VF_ENA_W1C			(0x000240)
+#define   NIC_VF_ENA_W1S			(0x000260)
+
+#define   NIC_VNIC_RSS_CFG			(0x0020E0)
+#define   NIC_VNIC_RSS_KEY_0_4			(0x002200)
+#define   NIC_VNIC_TX_STAT_0_4			(0x004000)
+#define   NIC_VNIC_RX_STAT_0_13			(0x004100)
+#define   NIC_QSET_RQ_GEN_CFG			(0x010010)
+
+#define   NIC_QSET_CQ_0_7_CFG			(0x010400)
+#define   NIC_QSET_CQ_0_7_CFG2			(0x010408)
+#define   NIC_QSET_CQ_0_7_THRESH		(0x010410)
+#define   NIC_QSET_CQ_0_7_BASE			(0x010420)
+#define   NIC_QSET_CQ_0_7_HEAD			(0x010428)
+#define   NIC_QSET_CQ_0_7_TAIL			(0x010430)
+#define   NIC_QSET_CQ_0_7_DOOR			(0x010438)
+#define   NIC_QSET_CQ_0_7_STATUS		(0x010440)
+#define   NIC_QSET_CQ_0_7_STATUS2		(0x010448)
+#define   NIC_QSET_CQ_0_7_DEBUG			(0x010450)
+
+#define   NIC_QSET_RQ_0_7_CFG			(0x010600)
+#define   NIC_QSET_RQ_0_7_STAT_0_1		(0x010700)
+
+#define   NIC_QSET_SQ_0_7_CFG			(0x010800)
+#define   NIC_QSET_SQ_0_7_THRESH		(0x010810)
+#define   NIC_QSET_SQ_0_7_BASE			(0x010820)
+#define   NIC_QSET_SQ_0_7_HEAD			(0x010828)
+#define   NIC_QSET_SQ_0_7_TAIL			(0x010830)
+#define   NIC_QSET_SQ_0_7_DOOR			(0x010838)
+#define   NIC_QSET_SQ_0_7_STATUS		(0x010840)
+#define   NIC_QSET_SQ_0_7_DEBUG			(0x010848)
+#define   NIC_QSET_SQ_0_7_CNM_CHG		(0x010860)
+#define   NIC_QSET_SQ_0_7_STAT_0_1		(0x010900)
+
+#define   NIC_QSET_RBDR_0_1_CFG			(0x010C00)
+#define   NIC_QSET_RBDR_0_1_THRESH		(0x010C10)
+#define   NIC_QSET_RBDR_0_1_BASE		(0x010C20)
+#define   NIC_QSET_RBDR_0_1_HEAD		(0x010C28)
+#define   NIC_QSET_RBDR_0_1_TAIL		(0x010C30)
+#define   NIC_QSET_RBDR_0_1_DOOR		(0x010C38)
+#define   NIC_QSET_RBDR_0_1_STATUS0		(0x010C40)
+#define   NIC_QSET_RBDR_0_1_STATUS1		(0x010C48)
+#define   NIC_QSET_RBDR_0_1_PREFETCH_STATUS	(0x010C50)
+
+#define   NIC_VF_MSIX_VECTOR_0_19_ADDR		(0x000000)
+#define   NIC_VF_MSIX_VECTOR_0_19_CTL		(0x000008)
+#define   NIC_VF_MSIX_PBA			(0x0F0000)
+
+/* Offsets within registers */
+#define   NIC_MSIX_VEC_SHIFT			4
+#define   NIC_Q_NUM_SHIFT			18
+#define   NIC_QS_ID_SHIFT			21
+#define   NIC_VF_NUM_SHIFT			21
+
+/* Port kind configuration register */
+struct pkind_cfg {
+#if defined(__BIG_ENDIAN_BITFIELD)
+	uint64_t reserved_42_63:22;
+	uint64_t hdr_sl:5;	/* Header skip length */
+	uint64_t rx_hdr:3;	/* TNS Receive header present */
+	uint64_t lenerr_en:1;	/* L2 length error check enable */
+	uint64_t reserved_32_32:1;
+	uint64_t maxlen:16;	/* Max frame size */
+	uint64_t minlen:16;	/* Min frame size */
+#elif defined(__LITTLE_ENDIAN_BITFIELD)
+	uint64_t minlen:16;
+	uint64_t maxlen:16;
+	uint64_t reserved_32_32:1;
+	uint64_t lenerr_en:1;
+	uint64_t rx_hdr:3;
+	uint64_t hdr_sl:5;
+	uint64_t reserved_42_63:22;
+#endif
+};
+
+#endif /* NIC_REG_H */
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c b/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
new file mode 100644
index 000000000000..14a9ebaf043a
--- /dev/null
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
@@ -0,0 +1,559 @@
+/*
+ * Copyright (C) 2014 Cavium, Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of
+ * the License, or (at your option) any later version.
+ */
+
+/* ETHTOOL Support for VNIC_VF Device*/
+
+#include <linux/pci.h>
+
+#include "nic_reg.h"
+#include "nic.h"
+#include "nicvf_queues.h"
+#include "q_struct.h"
+
+#define DRV_NAME	"thunder-nicvf"
+#define DRV_VERSION     "1.0"
+
+struct nicvf_stat {
+	char name[ETH_GSTRING_LEN];
+	unsigned int index;
+};
+
+#define NICVF_HW_STAT(stat) { \
+	.name = #stat, \
+	.index = offsetof(struct nicvf_hw_stats, stat) / sizeof(u64), \
+}
+
+#define NICVF_DRV_STAT(stat) { \
+	.name = #stat, \
+	.index = offsetof(struct nicvf_drv_stats, stat) / sizeof(u64), \
+}
+
+static const struct nicvf_stat nicvf_hw_stats[] = {
+	NICVF_HW_STAT(rx_bytes_ok),
+	NICVF_HW_STAT(rx_ucast_frames_ok),
+	NICVF_HW_STAT(rx_bcast_frames_ok),
+	NICVF_HW_STAT(rx_mcast_frames_ok),
+	NICVF_HW_STAT(rx_fcs_errors),
+	NICVF_HW_STAT(rx_l2_errors),
+	NICVF_HW_STAT(rx_drop_red),
+	NICVF_HW_STAT(rx_drop_red_bytes),
+	NICVF_HW_STAT(rx_drop_overrun),
+	NICVF_HW_STAT(rx_drop_overrun_bytes),
+	NICVF_HW_STAT(rx_drop_bcast),
+	NICVF_HW_STAT(rx_drop_mcast),
+	NICVF_HW_STAT(rx_drop_l3_bcast),
+	NICVF_HW_STAT(rx_drop_l3_mcast),
+	NICVF_HW_STAT(tx_bytes_ok),
+	NICVF_HW_STAT(tx_ucast_frames_ok),
+	NICVF_HW_STAT(tx_bcast_frames_ok),
+	NICVF_HW_STAT(tx_mcast_frames_ok),
+};
+
+static const struct nicvf_stat nicvf_drv_stats[] = {
+	NICVF_DRV_STAT(rx_frames_ok),
+	NICVF_DRV_STAT(rx_frames_64),
+	NICVF_DRV_STAT(rx_frames_127),
+	NICVF_DRV_STAT(rx_frames_255),
+	NICVF_DRV_STAT(rx_frames_511),
+	NICVF_DRV_STAT(rx_frames_1023),
+	NICVF_DRV_STAT(rx_frames_1518),
+	NICVF_DRV_STAT(rx_frames_jumbo),
+	NICVF_DRV_STAT(rx_drops),
+	NICVF_DRV_STAT(tx_frames_ok),
+	NICVF_DRV_STAT(tx_busy),
+	NICVF_DRV_STAT(tx_tso),
+	NICVF_DRV_STAT(tx_drops),
+};
+
+static const struct nicvf_stat nicvf_queue_stats[] = {
+	{ "bytes", 0 },
+	{ "frames", 1 },
+};
+
+static const unsigned int nicvf_n_hw_stats = ARRAY_SIZE(nicvf_hw_stats);
+static const unsigned int nicvf_n_drv_stats = ARRAY_SIZE(nicvf_drv_stats);
+static const unsigned int nicvf_n_queue_stats = ARRAY_SIZE(nicvf_queue_stats);
+
+static int nicvf_get_settings(struct net_device *netdev,
+			      struct ethtool_cmd *cmd)
+{
+	cmd->supported = (SUPPORTED_1000baseT_Full |
+			SUPPORTED_100baseT_Full |
+			SUPPORTED_10baseT_Full |
+			SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
+
+	cmd->advertising = (ADVERTISED_1000baseT_Full |
+			ADVERTISED_100baseT_Full |
+			ADVERTISED_10baseT_Full |
+			ADVERTISED_10000baseT_Full | ADVERTISED_FIBRE);
+
+	cmd->port = PORT_FIBRE;
+	cmd->transceiver = XCVR_EXTERNAL;
+	if (netif_carrier_ok(netdev)) {
+		ethtool_cmd_speed_set(cmd, SPEED_10000);
+		cmd->duplex = DUPLEX_FULL;
+	} else {
+		ethtool_cmd_speed_set(cmd, -1);
+		cmd->duplex = -1;
+	}
+
+	cmd->autoneg = AUTONEG_DISABLE;
+	ethtool_cmd_speed_set(cmd, SPEED_1000);
+	return 0;
+}
+
+static int nicvf_set_settings(struct net_device *netdev,
+			      struct ethtool_cmd *cmd)
+{
+	return -EOPNOTSUPP;
+
+	/* 10G full duplex setting supported only */
+	if (cmd->autoneg == AUTONEG_ENABLE)
+		return -EOPNOTSUPP;
+
+	if (ethtool_cmd_speed(cmd) != SPEED_10000)
+		return -EOPNOTSUPP;
+
+	if (cmd->duplex != DUPLEX_FULL)
+		return -EOPNOTSUPP;
+
+	return 0;
+}
+
+static void nicvf_get_drvinfo(struct net_device *netdev,
+			      struct ethtool_drvinfo *info)
+{
+	struct nicvf *nic = netdev_priv(netdev);
+
+	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, pci_name(nic->pdev), sizeof(info->bus_info));
+}
+
+static void nicvf_get_strings(struct net_device *netdev, u32 sset, u8 *data)
+{
+	int stats, qidx;
+
+	if (sset != ETH_SS_STATS)
+		return;
+
+	for (stats = 0; stats < nicvf_n_hw_stats; stats++) {
+		memcpy(data, nicvf_hw_stats[stats].name, ETH_GSTRING_LEN);
+		data += ETH_GSTRING_LEN;
+	}
+
+	for (stats = 0; stats < nicvf_n_drv_stats; stats++) {
+		memcpy(data, nicvf_drv_stats[stats].name, ETH_GSTRING_LEN);
+		data += ETH_GSTRING_LEN;
+	}
+
+	for (qidx = 0; qidx < MAX_RCV_QUEUES_PER_QS; qidx++) {
+		for (stats = 0; stats < nicvf_n_queue_stats; stats++) {
+			sprintf(data, "rxq%d: %s", qidx,
+				nicvf_queue_stats[stats].name);
+			data += ETH_GSTRING_LEN;
+		}
+	}
+
+	for (qidx = 0; qidx < MAX_SND_QUEUES_PER_QS; qidx++) {
+		for (stats = 0; stats < nicvf_n_queue_stats; stats++) {
+			sprintf(data, "txq%d: %s", qidx,
+				nicvf_queue_stats[stats].name);
+			data += ETH_GSTRING_LEN;
+		}
+	}
+}
+
+static int nicvf_get_sset_count(struct net_device *netdev, int sset)
+{
+	if (sset != ETH_SS_STATS)
+		return -EINVAL;
+
+	return nicvf_n_hw_stats + nicvf_n_drv_stats +
+		(nicvf_n_queue_stats *
+		 (MAX_RCV_QUEUES_PER_QS + MAX_SND_QUEUES_PER_QS));
+}
+
+static void nicvf_get_ethtool_stats(struct net_device *netdev,
+				    struct ethtool_stats *stats, u64 *data)
+{
+	struct nicvf *nic = netdev_priv(netdev);
+	int stat, qidx;
+
+	nicvf_update_stats(nic);
+
+	for (stat = 0; stat < nicvf_n_hw_stats; stat++)
+		*(data++) = ((u64 *)&nic->stats)
+				[nicvf_hw_stats[stat].index];
+	for (stat = 0; stat < nicvf_n_drv_stats; stat++)
+		*(data++) = ((u64 *)&nic->drv_stats)
+				[nicvf_drv_stats[stat].index];
+
+	for (qidx = 0; qidx < MAX_RCV_QUEUES_PER_QS; qidx++) {
+		for (stat = 0; stat < nicvf_n_queue_stats; stat++)
+			*(data++) = ((u64 *)&nic->qs->rq[qidx].stats)
+					[nicvf_queue_stats[stat].index];
+	}
+
+	for (qidx = 0; qidx < MAX_SND_QUEUES_PER_QS; qidx++) {
+		for (stat = 0; stat < nicvf_n_queue_stats; stat++)
+			*(data++) = ((u64 *)&nic->qs->sq[qidx].stats)
+					[nicvf_queue_stats[stat].index];
+	}
+}
+
+static int nicvf_get_regs_len(struct net_device *dev)
+{
+	return sizeof(uint64_t) * NIC_VF_REG_COUNT;
+}
+
+static void nicvf_get_regs(struct net_device *dev,
+			   struct ethtool_regs *regs, void *reg)
+{
+	struct nicvf *nic = netdev_priv(dev);
+	uint64_t *p = (uint64_t *)reg;
+	uint64_t reg_offset;
+	int mbox, key, stat, q;
+	int i = 0;
+
+	regs->version = 0;
+	memset(p, 0, NIC_VF_REG_COUNT);
+
+	p[i++] = nicvf_reg_read(nic, NIC_VNIC_CFG);
+	/* Mailbox registers */
+	for (mbox = 0; mbox < NIC_PF_VF_MAILBOX_SIZE; mbox++)
+		p[i++] = nicvf_reg_read(nic,
+					NIC_VF_PF_MAILBOX_0_7 | (mbox << 3));
+
+	p[i++] = nicvf_reg_read(nic, NIC_VF_INT);
+	p[i++] = nicvf_reg_read(nic, NIC_VF_INT_W1S);
+	p[i++] = nicvf_reg_read(nic, NIC_VF_ENA_W1C);
+	p[i++] = nicvf_reg_read(nic, NIC_VF_ENA_W1S);
+	p[i++] = nicvf_reg_read(nic, NIC_VNIC_RSS_CFG);
+
+	for (key = 0; key < RSS_HASH_KEY_SIZE; key++)
+		p[i++] = nicvf_reg_read(nic, NIC_VNIC_RSS_KEY_0_4 | (key << 3));
+
+	/* Tx/Rx statistics */
+	for (stat = 0; stat < TX_STATS_ENUM_LAST; stat++)
+		p[i++] = nicvf_reg_read(nic,
+					NIC_VNIC_TX_STAT_0_4 | (stat << 3));
+
+	for (i = 0; i < RX_STATS_ENUM_LAST; i++)
+		p[i++] = nicvf_reg_read(nic,
+					NIC_VNIC_RX_STAT_0_13 | (stat << 3));
+
+	p[i++] = nicvf_reg_read(nic, NIC_QSET_RQ_GEN_CFG);
+
+	/* All completion queue's registers */
+	for (q = 0; q < MAX_CMP_QUEUES_PER_QS; q++) {
+		p[i++] = nicvf_queue_reg_read(nic, NIC_QSET_CQ_0_7_CFG, q);
+		p[i++] = nicvf_queue_reg_read(nic, NIC_QSET_CQ_0_7_CFG2, q);
+		p[i++] = nicvf_queue_reg_read(nic, NIC_QSET_CQ_0_7_THRESH, q);
+		p[i++] = nicvf_queue_reg_read(nic, NIC_QSET_CQ_0_7_BASE, q);
+		p[i++] = nicvf_queue_reg_read(nic, NIC_QSET_CQ_0_7_HEAD, q);
+		p[i++] = nicvf_queue_reg_read(nic, NIC_QSET_CQ_0_7_TAIL, q);
+		p[i++] = nicvf_queue_reg_read(nic, NIC_QSET_CQ_0_7_DOOR, q);
+		p[i++] = nicvf_queue_reg_read(nic, NIC_QSET_CQ_0_7_STATUS, q);
+		p[i++] = nicvf_queue_reg_read(nic, NIC_QSET_CQ_0_7_STATUS2, q);
+		p[i++] = nicvf_queue_reg_read(nic, NIC_QSET_CQ_0_7_DEBUG, q);
+	}
+
+	/* All receive queue's registers */
+	for (q = 0; q < MAX_RCV_QUEUES_PER_QS; q++) {
+		p[i++] = nicvf_queue_reg_read(nic, NIC_QSET_RQ_0_7_CFG, q);
+		p[i++] = nicvf_queue_reg_read(nic,
+						  NIC_QSET_RQ_0_7_STAT_0_1, q);
+		reg_offset = NIC_QSET_RQ_0_7_STAT_0_1 | (1 << 3);
+		p[i++] = nicvf_queue_reg_read(nic, reg_offset, q);
+	}
+
+	for (q = 0; q < MAX_SND_QUEUES_PER_QS; q++) {
+		p[i++] = nicvf_queue_reg_read(nic, NIC_QSET_SQ_0_7_CFG, q);
+		p[i++] = nicvf_queue_reg_read(nic, NIC_QSET_SQ_0_7_THRESH, q);
+		p[i++] = nicvf_queue_reg_read(nic, NIC_QSET_SQ_0_7_BASE, q);
+		p[i++] = nicvf_queue_reg_read(nic, NIC_QSET_SQ_0_7_HEAD, q);
+		p[i++] = nicvf_queue_reg_read(nic, NIC_QSET_SQ_0_7_TAIL, q);
+		p[i++] = nicvf_queue_reg_read(nic, NIC_QSET_SQ_0_7_DOOR, q);
+		p[i++] = nicvf_queue_reg_read(nic, NIC_QSET_SQ_0_7_STATUS, q);
+		p[i++] = nicvf_queue_reg_read(nic, NIC_QSET_SQ_0_7_DEBUG, q);
+		p[i++] = nicvf_queue_reg_read(nic, NIC_QSET_SQ_0_7_CNM_CHG, q);
+		p[i++] = nicvf_queue_reg_read(nic, NIC_QSET_SQ_0_7_STAT_0_1, q);
+		reg_offset = NIC_QSET_SQ_0_7_STAT_0_1 | (1 << 3);
+		p[i++] = nicvf_queue_reg_read(nic, reg_offset, q);
+	}
+
+	for (q = 0; q < MAX_RCV_BUF_DESC_RINGS_PER_QS; q++) {
+		p[i++] = nicvf_queue_reg_read(nic, NIC_QSET_RBDR_0_1_CFG, q);
+		p[i++] = nicvf_queue_reg_read(nic, NIC_QSET_RBDR_0_1_THRESH, q);
+		p[i++] = nicvf_queue_reg_read(nic, NIC_QSET_RBDR_0_1_BASE, q);
+		p[i++] = nicvf_queue_reg_read(nic, NIC_QSET_RBDR_0_1_HEAD, q);
+		p[i++] = nicvf_queue_reg_read(nic, NIC_QSET_RBDR_0_1_TAIL, q);
+		p[i++] = nicvf_queue_reg_read(nic, NIC_QSET_RBDR_0_1_DOOR, q);
+		p[i++] = nicvf_queue_reg_read(nic,
+					      NIC_QSET_RBDR_0_1_STATUS0, q);
+		p[i++] = nicvf_queue_reg_read(nic,
+					      NIC_QSET_RBDR_0_1_STATUS1, q);
+		reg_offset = NIC_QSET_RBDR_0_1_PREFETCH_STATUS;
+		p[i++] = nicvf_queue_reg_read(nic, reg_offset, q);
+	}
+}
+
+#ifdef VNIC_RSS_SUPPORT
+static int nicvf_get_rss_hash_opts(struct nicvf *nic,
+				   struct ethtool_rxnfc *info)
+{
+	info->data = 0;
+
+	switch (info->flow_type) {
+	case TCP_V4_FLOW:
+	case TCP_V6_FLOW:
+	case UDP_V4_FLOW:
+	case UDP_V6_FLOW:
+	case SCTP_V4_FLOW:
+	case SCTP_V6_FLOW:
+		info->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+	case IPV4_FLOW:
+	case IPV6_FLOW:
+		info->data |= RXH_IP_SRC | RXH_IP_DST;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int nicvf_get_rxnfc(struct net_device *dev,
+			   struct ethtool_rxnfc *info, uint32_t *rules)
+{
+	struct nicvf *nic = netdev_priv(dev);
+	int ret = -EOPNOTSUPP;
+
+	switch (info->cmd) {
+	case ETHTOOL_GRXRINGS:
+		info->data = nic->qs->rq_cnt;
+		ret = 0;
+		break;
+	case ETHTOOL_GRXFH:
+		return nicvf_get_rss_hash_opts(nic, info);
+	default:
+		break;
+	}
+	return ret;
+}
+
+static int nicvf_set_rss_hash_opts(struct nicvf *nic,
+				   struct ethtool_rxnfc *info)
+{
+	struct nicvf_rss_info *rss = &nic->rss_info;
+	uint64_t rss_cfg = nicvf_reg_read(nic, NIC_VNIC_RSS_CFG);
+
+	if (!rss->enable)
+		netdev_err(dev, "RSS is disabled, hash cannot be set\n");
+
+	netdev_info(dev, "Set RSS flow type = %d, data = %d\n",
+		    info->flow_type, info->data);
+
+	if (!(info->data & RXH_IP_SRC) || !(info->data & RXH_IP_DST))
+		return -EINVAL;
+
+	switch (cmd->flow_type) {
+	case TCP_V4_FLOW:
+	case TCP_V6_FLOW:
+		switch (info->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
+		case 0:
+			rss_cfg &= ~(1ULL << RSS_HASH_TCP);
+			break;
+		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
+			rss_cfg |= (1ULL << RSS_HASH_TCP);
+			break;
+		default:
+			return -EINVAL;
+		}
+		break;
+	case UDP_V4_FLOW:
+	case UDP_V6_FLOW:
+		switch (info->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
+		case 0:
+			rss_cfg &= ~(1ULL << RSS_HASH_UDP);
+			break;
+		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
+			rss_cfg |= (1ULL << RSS_HASH_UDP);
+			break;
+		default:
+			return -EINVAL;
+		}
+		break;
+	case SCTP_V4_FLOW:
+	case SCTP_V6_FLOW:
+		switch (info->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
+		case 0:
+			rss_cfg &= ~(1ULL << RSS_HASH_L4ETC);
+			break;
+		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
+			rss_cfg |= (1ULL << RSS_HASH_L4ETC);
+			break;
+		default:
+			return -EINVAL;
+		}
+		break;
+	case IPV4_FLOW:
+	case IPV6_FLOW:
+		rss_cfg = RSS_HASH_IP;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	nicvf_reg_read(nic, NIC_VNIC_RSS_CFG, rss_cfg);
+	return 0;
+}
+
+static int nicvf_set_rxnfc(struct net_device *dev, struct ethtool_rxnfc *info)
+{
+	struct nicvf *nic = netdev_priv(dev);
+
+	switch (info->cmd) {
+	case ETHTOOL_SRXFH:
+		return nicvf_set_rss_hash_opts(nic, info);
+	default:
+		break;
+	}
+	return -EOPNOTSUPP;
+}
+
+static u32 nicvf_get_rxfh_key_size(struct net_device *netdev)
+{
+	return RSS_HASH_KEY_SIZE;
+}
+
+static u32 nicvf_get_rxfh_indir_size(struct net_device *dev)
+{
+	struct nicvf *nic = netdev_priv(dev);
+
+	return nic->rss_info.rss_size;
+}
+
+static int nicvf_get_rxfh(struct net_device *dev, u32 *indir, u8 *hkey)
+{
+	struct nicvf *nic = netdev_priv(dev);
+	struct nicvf_rss_info *rss = &nic->rss_info;
+	int idx;
+
+	if (indir) {
+		for (idx = 0; idx < rss->rss_size; idx++)
+			indir[idx] = rss->ind_tbl[idx];
+	}
+
+	if (hkey)
+		memcpy(hkey, rss->key, RSS_HASH_KEY_SIZE);
+
+	return 0;
+}
+
+static int nicvf_set_rxfh(struct net_device *dev, const u32 *indir,
+			  const u8 *hkey)
+{
+	struct nicvf *nic = netdev_priv(dev);
+	struct nicvf_rss_info *rss = &nic->rss_info;
+	int idx;
+
+	if ((nic->qs->rq_cnt <= 1) || (nic->cpi_alg != CPI_ALG_NONE)) {
+		rss->enable = false;
+		rss->hash_bits = 0;
+		return -EIO;
+	}
+
+	rss->enable = true;
+	if (indir) {
+		for (idx = 0; idx < rss->rss_size; idx++)
+			rss->ind_tbl[idx] = indir[idx];
+	}
+
+	nicvf_config_rss(nic);
+	return 0;
+}
+#endif
+
+/* Get no of queues device supports and current queue count */
+static void nicvf_get_channels(struct net_device *dev,
+			       struct ethtool_channels *channel)
+{
+	struct nicvf *nic = netdev_priv(dev);
+
+	memset(channel, 0, sizeof(*channel));
+
+	channel->max_rx = MAX_RCV_QUEUES_PER_QS;
+	channel->max_tx = MAX_SND_QUEUES_PER_QS;
+
+	channel->rx_count = nic->qs->rq_cnt;
+	channel->tx_count = nic->qs->sq_cnt;
+}
+
+/* Set no of Tx, Rx queues to be used */
+static int nicvf_set_channels(struct net_device *dev,
+			      struct ethtool_channels *channel)
+{
+	struct nicvf *nic = netdev_priv(dev);
+	int err = 0;
+
+	if (!channel->rx_count || !channel->tx_count)
+		return -EINVAL;
+	if (channel->rx_count > MAX_RCV_QUEUES_PER_QS)
+		return -EINVAL;
+	if (channel->tx_count > MAX_SND_QUEUES_PER_QS)
+		return -EINVAL;
+
+	nic->qs->rq_cnt = channel->rx_count;
+	nic->qs->sq_cnt = channel->tx_count;
+	nic->qs->cq_cnt = nic->qs->sq_cnt;
+
+	err = nicvf_set_real_num_queues(dev, nic->qs->sq_cnt, nic->qs->rq_cnt);
+	if (err)
+		return err;
+
+	if (!netif_running(dev))
+		return err;
+
+	nicvf_stop(dev);
+	nicvf_open(dev);
+	netdev_info(dev, "Setting num Tx rings to %d, Rx rings to %d success\n",
+		    nic->qs->sq_cnt, nic->qs->rq_cnt);
+
+	return err;
+}
+
+static const struct ethtool_ops nicvf_ethtool_ops = {
+	.get_settings		= nicvf_get_settings,
+	.set_settings		= nicvf_set_settings,
+	.get_link		= ethtool_op_get_link,
+	.get_drvinfo		= nicvf_get_drvinfo,
+	.get_strings		= nicvf_get_strings,
+	.get_sset_count		= nicvf_get_sset_count,
+	.get_ethtool_stats	= nicvf_get_ethtool_stats,
+	.get_regs_len		= nicvf_get_regs_len,
+	.get_regs		= nicvf_get_regs,
+#ifdef VNIC_RSS_SUPPORT
+	.get_rxnfc		= nicvf_get_rxnfc,
+	.set_rxnfc		= nicvf_set_rxnfc,
+	.get_rxfh_key_size	= nicvf_get_rxfh_key_size,
+	.get_rxfh_indir_size	= nicvf_get_rxfh_indir_size,
+	.get_rxfh		= nicvf_get_rxfh,
+	.set_rxfh		= nicvf_set_rxfh,
+#endif
+	.get_channels		= nicvf_get_channels,
+	.set_channels		= nicvf_set_channels,
+	.get_ts_info		= ethtool_op_get_ts_info,
+};
+
+void nicvf_set_ethtool_ops(struct net_device *netdev)
+{
+	netdev->ethtool_ops = &nicvf_ethtool_ops;
+}
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
new file mode 100644
index 000000000000..b920812ec2dd
--- /dev/null
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -0,0 +1,1323 @@
+/*
+ * Copyright (C) 2014 Cavium, Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of
+ * the License, or (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/interrupt.h>
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/log2.h>
+
+#include "nic_reg.h"
+#include "nic.h"
+#include "nicvf_queues.h"
+
+#define DRV_NAME	"thunder-nicvf"
+#define DRV_VERSION	"1.0"
+
+/* Supported devices */
+static const struct pci_device_id nicvf_id_table[] = {
+	{ PCI_DEVICE(PCI_VENDOR_ID_CAVIUM, PCI_DEVICE_ID_THUNDER_NIC_VF) },
+	{ 0, }  /* end of table */
+};
+
+MODULE_AUTHOR("Sunil Goutham");
+MODULE_DESCRIPTION("Cavium Thunder NIC Virtual Function Driver");
+MODULE_LICENSE("GPL v2");
+MODULE_VERSION(DRV_VERSION);
+MODULE_DEVICE_TABLE(pci, nicvf_id_table);
+
+static int cpi_alg = CPI_ALG_NONE;
+module_param(cpi_alg, int, S_IRUGO);
+MODULE_PARM_DESC(cpi_alg,
+		 "PFC algorithm (0=none, 1=VLAN, 2=VLAN16, 3=IP Diffserv)");
+#ifdef	VNIC_RSS_SUPPORT
+static int rss_config = RSS_IP_HASH_ENA | RSS_TCP_HASH_ENA | RSS_UDP_HASH_ENA;
+#endif
+
+static int nicvf_enable_msix(struct nicvf *nic);
+static netdev_tx_t nicvf_xmit(struct sk_buff *skb, struct net_device *netdev);
+
+static void nicvf_dump_packet(struct sk_buff *skb)
+{
+#ifdef NICVF_DUMP_PACKET
+	int i;
+
+	for (i = 0; i < skb->len; i++) {
+		if (!(i % 16))
+			pr_cont("\n");
+		pr_debug("%02x ", (u_char)skb->data[i]);
+	}
+#endif
+}
+
+#ifdef NICVF_ETHTOOL_ENABLE
+static void nicvf_set_rx_frame_cnt(struct nicvf *nic, struct sk_buff *skb)
+{
+	if (skb->len <= 64)
+		nic->drv_stats.rx_frames_64++;
+	else if ((skb->len > 64) && (skb->len <= 127))
+		nic->drv_stats.rx_frames_127++;
+	else if ((skb->len > 127) && (skb->len <= 255))
+		nic->drv_stats.rx_frames_255++;
+	else if ((skb->len > 255) && (skb->len <= 511))
+		nic->drv_stats.rx_frames_511++;
+	else if ((skb->len > 511) && (skb->len <= 1023))
+		nic->drv_stats.rx_frames_1023++;
+	else if ((skb->len > 1023) && (skb->len <= 1518))
+		nic->drv_stats.rx_frames_1518++;
+	else if (skb->len > 1518)
+		nic->drv_stats.rx_frames_jumbo++;
+}
+#endif
+
+/* Register read/write APIs */
+void nicvf_reg_write(struct nicvf *nic, uint64_t offset, uint64_t val)
+{
+	uint64_t addr = nic->reg_base + offset;
+
+	writeq_relaxed(val, (void *)addr);
+}
+
+uint64_t nicvf_reg_read(struct nicvf *nic, uint64_t offset)
+{
+	uint64_t addr = nic->reg_base + offset;
+
+	return readq_relaxed((void *)addr);
+}
+
+void nicvf_queue_reg_write(struct nicvf *nic, uint64_t offset,
+			   uint64_t qidx, uint64_t val)
+{
+	uint64_t addr = nic->reg_base + offset;
+
+	writeq_relaxed(val, (void *)(addr + (qidx << NIC_Q_NUM_SHIFT)));
+}
+
+uint64_t nicvf_queue_reg_read(struct nicvf *nic, uint64_t offset, uint64_t qidx)
+{
+	uint64_t addr = nic->reg_base + offset;
+
+	return readq_relaxed((void *)(addr + (qidx << NIC_Q_NUM_SHIFT)));
+}
+
+/* VF -> PF mailbox communication */
+static bool pf_ready_to_rcv_msg;
+static bool pf_acked;
+static bool pf_nacked;
+
+int nicvf_lock_mbox(struct nicvf *nic)
+{
+	int timeout = NIC_PF_VF_MBX_TIMEOUT;
+	int sleep = 10;
+	uint64_t lock, mbx_addr;
+
+	mbx_addr = NIC_VF_PF_MAILBOX_0_7 + NIC_PF_VF_MBX_LOCK_OFFSET;
+	lock = NIC_PF_VF_MBX_LOCK_VAL(nicvf_reg_read(nic, mbx_addr));
+	while (lock) {
+		msleep(sleep);
+		lock = NIC_PF_VF_MBX_LOCK_VAL(nicvf_reg_read(nic, mbx_addr));
+		timeout -= sleep;
+		if (!timeout) {
+			netdev_err(nic->netdev,
+				   "VF%d Couldn't lock mailbox\n", nic->vf_id);
+			return 0;
+		}
+	}
+	nicvf_reg_write(nic, mbx_addr, NIC_PF_VF_MBX_LOCK_SET(lock));
+	return 1;
+}
+
+void nicvf_release_mbx(struct nicvf *nic)
+{
+	uint64_t mbx_addr, lock;
+
+	mbx_addr = NIC_VF_PF_MAILBOX_0_7 + NIC_PF_VF_MBX_LOCK_OFFSET;
+	lock = nicvf_reg_read(nic, mbx_addr);
+	nicvf_reg_write(nic, mbx_addr, NIC_PF_VF_MBX_LOCK_CLEAR(lock));
+}
+
+int nicvf_send_msg_to_pf(struct nicvf *nic, struct nic_mbx *mbx)
+{
+	int i, timeout = NIC_PF_VF_MBX_TIMEOUT;
+	int sleep = 10;
+	uint64_t *msg;
+	uint64_t mbx_addr;
+
+	if (!nicvf_lock_mbox(nic))
+		return -EBUSY;
+
+	pf_acked = false;
+	pf_nacked = false;
+	mbx->mbx_trigger_intr = 1;
+	msg = (uint64_t *)mbx;
+	mbx_addr = nic->reg_base + NIC_VF_PF_MAILBOX_0_7;
+
+	for (i = 0; i < NIC_PF_VF_MAILBOX_SIZE; i++)
+		writeq_relaxed(*(msg + i), (void *)(mbx_addr + (i * 8)));
+	nicvf_release_mbx(nic);
+
+	/* Wait for previous message to be acked, timeout 5sec */
+	while (!pf_acked) {
+		if (pf_nacked)
+			return -EINVAL;
+		msleep(sleep);
+		if (pf_acked)
+			break;
+		timeout -= sleep;
+		if (!timeout) {
+			netdev_err(nic->netdev,
+				   "PF didn't ack to mbox msg %d from VF%d\n",
+				   (mbx->msg & 0xFF), nic->vf_id);
+			return -EBUSY;
+		}
+	}
+	return 0;
+}
+
+/* Checks if VF is able to comminicate with PF
+* and also gets the VNIC number this VF is associated to.
+*/
+static int nicvf_check_pf_ready(struct nicvf *nic)
+{
+	int timeout = 5000, sleep = 20;
+	uint64_t mbx_addr = NIC_VF_PF_MAILBOX_0_7;
+
+	pf_ready_to_rcv_msg = false;
+
+	nicvf_reg_write(nic, mbx_addr, NIC_PF_VF_MSG_READY);
+
+	mbx_addr += (NIC_PF_VF_MAILBOX_SIZE - 1) * 8;
+	nicvf_reg_write(nic, mbx_addr, 1ULL);
+
+	while (!pf_ready_to_rcv_msg) {
+		msleep(sleep);
+		if (pf_ready_to_rcv_msg)
+			break;
+		timeout -= sleep;
+		if (!timeout) {
+			netdev_err(nic->netdev,
+				   "PF didn't respond to READY msg\n");
+			return 0;
+		}
+	}
+	return 1;
+}
+
+static void  nicvf_handle_mbx_intr(struct nicvf *nic)
+{
+	struct nic_mbx mbx = {};
+	uint64_t *mbx_data;
+	uint64_t mbx_addr;
+	int i;
+
+	mbx_addr = NIC_VF_PF_MAILBOX_0_7;
+	mbx_data = (uint64_t *)&mbx;
+
+	for (i = 0; i < NIC_PF_VF_MAILBOX_SIZE; i++) {
+		*mbx_data = nicvf_reg_read(nic, mbx_addr);
+		mbx_data++;
+		mbx_addr += NIC_PF_VF_MAILBOX_SIZE;
+	}
+
+	switch (mbx.msg & NIC_PF_VF_MBX_MSG_MASK) {
+	case NIC_PF_VF_MSG_READY:
+		pf_ready_to_rcv_msg = true;
+		nic->vf_id = mbx.data.nic_cfg.vf_id & 0x7F;
+		nic->tns_mode = mbx.data.nic_cfg.tns_mode & 0x7F;
+		break;
+	case NIC_PF_VF_MSG_ACK:
+		pf_acked = true;
+		break;
+	case NIC_PF_VF_MSG_NACK:
+		pf_nacked = true;
+		break;
+#ifdef VNIC_RSS_SUPPORT
+	case NIC_PF_VF_MSG_RSS_SIZE:
+		nic->rss_info.rss_size = mbx.data.rss_size.ind_tbl_size;
+		break;
+#endif
+	default:
+		netdev_err(nic->netdev,
+			   "Invalid message from PF, msg 0x%x\n", mbx.msg);
+		break;
+	}
+	nicvf_clear_intr(nic, NICVF_INTR_MBOX, 0);
+}
+
+static int nicvf_hw_set_mac_addr(struct nicvf *nic, struct net_device *netdev)
+{
+	struct nic_mbx mbx = {};
+	int i;
+
+	mbx.msg = NIC_PF_VF_MSG_SET_MAC;
+	mbx.data.mac.vf_id = nic->vf_id;
+	for (i = 0; i < ETH_ALEN; i++)
+		mbx.data.mac.addr = (mbx.data.mac.addr << 8) |
+				     netdev->dev_addr[i];
+
+	return nicvf_send_msg_to_pf(nic, &mbx);
+}
+
+static int nicvf_is_link_active(struct nicvf *nic)
+{
+	return 1;
+}
+
+void nicvf_config_cpi(struct nicvf *nic)
+{
+	struct nic_mbx mbx = {};
+
+	mbx.msg = NIC_PF_VF_MSG_CPI_CFG;
+	mbx.data.cpi_cfg.vf_id = nic->vf_id;
+	mbx.data.cpi_cfg.cpi_alg = nic->cpi_alg;
+	mbx.data.cpi_cfg.rq_cnt = nic->qs->rq_cnt;
+
+	nicvf_send_msg_to_pf(nic, &mbx);
+}
+
+#ifdef	VNIC_RSS_SUPPORT
+void nicvf_get_rss_size(struct nicvf *nic)
+{
+	struct nic_mbx mbx = {};
+
+	mbx.msg = NIC_PF_VF_MSG_RSS_SIZE;
+	mbx.data.rss_size.vf_id = nic->vf_id;
+	nicvf_send_msg_to_pf(nic, &mbx);
+}
+
+void nicvf_config_rss(struct nicvf *nic)
+{
+	struct nic_mbx mbx = {};
+	struct nicvf_rss_info *rss = &nic->rss_info;
+	int ind_tbl_len = rss->rss_size;
+	bool cont = false;
+	int i;
+
+	mbx.msg = NIC_PF_VF_MSG_RSS_CFG;
+	mbx.data.rss_cfg.vf_id = nic->vf_id;
+	mbx.data.rss_cfg.hash_bits = rss->hash_bits;
+	mbx.data.rss_cfg.tbl_len = 0;
+	mbx.data.rss_cfg.tbl_offset = 0;
+	while (ind_tbl_len) {
+		mbx.data.rss_cfg.tbl_offset += mbx.data.rss_cfg.tbl_len;
+		if (ind_tbl_len > RSS_IND_TBL_LEN_PER_MBX_MSG)
+			mbx.data.rss_cfg.tbl_len = RSS_IND_TBL_LEN_PER_MBX_MSG;
+		else
+			mbx.data.rss_cfg.tbl_len = ind_tbl_len;
+
+		for (i = mbx.data.rss_cfg.tbl_offset;
+		     i < (mbx.data.rss_cfg.tbl_offset +
+		     mbx.data.rss_cfg.tbl_len); i++)
+			mbx.data.rss_cfg.ind_tbl[i] = rss->ind_tbl[i];
+
+		if (cont)
+			mbx.msg = NIC_PF_VF_MSG_RSS_CFG_CONT;
+
+		nicvf_send_msg_to_pf(nic, &mbx);
+
+		ind_tbl_len -= mbx.data.rss_cfg.tbl_len;
+		if (!ind_tbl_len)
+			return;
+		cont = true;
+	}
+}
+
+static void nicvf_set_rss_key(struct nicvf *nic)
+{
+	struct nicvf_rss_info *rss = &nic->rss_info;
+	int idx;
+
+	for (idx = 0; idx < RSS_HASH_KEY_SIZE; idx++)
+		nicvf_reg_write(nic, NIC_VNIC_RSS_KEY_0_4, rss->key[idx]);
+}
+
+static int nicvf_rss_init(struct nicvf *nic)
+{
+	struct nicvf_rss_info *rss = &nic->rss_info;
+	int idx;
+
+	nicvf_get_rss_size(nic);
+
+	if ((nic->qs->rq_cnt <= 1) || (cpi_alg != CPI_ALG_NONE)) {
+		rss->enable = false;
+		rss->hash_bits = 0;
+		return 0;
+	}
+
+	rss->enable = true;
+
+	/* Using the HW reset value for now */
+	rss->key[0] = 0xFEED0BADFEED0BAD;
+	rss->key[1] = 0xFEED0BADFEED0BAD;
+	rss->key[2] = 0xFEED0BADFEED0BAD;
+	rss->key[3] = 0xFEED0BADFEED0BAD;
+	rss->key[4] = 0xFEED0BADFEED0BAD;
+
+	nicvf_set_rss_key(nic);
+
+	rss->cfg = rss_config;
+	nicvf_reg_write(nic, NIC_VNIC_RSS_CFG, rss->cfg);
+
+	rss->hash_bits =  ilog2(rounddown_pow_of_two(rss->rss_size));
+
+	for (idx = 0; idx < rss->rss_size; idx++)
+		rss->ind_tbl[idx] = ethtool_rxfh_indir_default(idx,
+							       nic->qs->rq_cnt);
+	nicvf_config_rss(nic);
+	return 1;
+}
+#endif
+
+int nicvf_set_real_num_queues(struct net_device *netdev,
+			      int tx_queues, int rx_queues)
+{
+	int err = 0;
+
+	err = netif_set_real_num_tx_queues(netdev, tx_queues);
+	if (err) {
+		netdev_err(netdev,
+			   "Failed to set no of Tx queues: %d\n", tx_queues);
+		return err;
+	}
+
+	err = netif_set_real_num_rx_queues(netdev, rx_queues);
+	if (err)
+		netdev_err(netdev,
+			   "Failed to set no of Rx queues: %d\n", rx_queues);
+	return err;
+}
+
+static int nicvf_init_resources(struct nicvf *nic)
+{
+	int err;
+
+	nic->num_qs = 1;
+
+	/* Initialize queues and HW for data transfer */
+	err = nicvf_config_data_transfer(nic, true);
+	if (err) {
+		netdev_err(nic->netdev,
+			   "Failed to alloc/config VF's QSet resources\n");
+		return err;
+	}
+	/* Enable Qset */
+	nicvf_qset_config(nic, true);
+
+	return 0;
+}
+
+void nicvf_free_skb(struct nicvf *nic, struct sk_buff *skb)
+{
+	int i;
+
+	if (!skb_shinfo(skb)->nr_frags)
+		goto free_skb;
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		const struct skb_frag_struct *frag;
+
+		frag = &skb_shinfo(skb)->frags[i];
+		pci_unmap_single(nic->pdev, (dma_addr_t)skb_frag_address(frag),
+				 skb_frag_size(frag), PCI_DMA_TODEVICE);
+	}
+free_skb:
+	pci_unmap_single(nic->pdev, (dma_addr_t)skb->data,
+			 skb_headlen(skb), PCI_DMA_TODEVICE);
+	dev_kfree_skb_any(skb);
+}
+
+static void nicvf_snd_pkt_handler(struct net_device *netdev,
+				  struct cmp_queue *cq,
+				  void *cq_desc, int cqe_type)
+{
+	struct sk_buff *skb = NULL;
+	struct cqe_send_t *cqe_tx;
+	struct nicvf *nic = netdev_priv(netdev);
+	struct snd_queue *sq;
+	struct sq_hdr_subdesc *hdr;
+
+	cqe_tx = (struct cqe_send_t *)cq_desc;
+	sq = &nic->qs->sq[cqe_tx->sq_idx];
+
+	hdr = (struct sq_hdr_subdesc *)GET_SQ_DESC(sq, cqe_tx->sqe_ptr);
+	if (hdr->subdesc_type != SQ_DESC_TYPE_HEADER)
+		return;
+
+	nic_dbg(&nic->pdev->dev,
+		"%s Qset #%d SQ #%d SQ ptr #%d subdesc count %d\n",
+		__func__, cqe_tx->sq_qs, cqe_tx->sq_idx,
+		cqe_tx->sqe_ptr, hdr->subdesc_cnt);
+
+	skb = (struct sk_buff *)sq->skbuff[cqe_tx->sqe_ptr];
+	nicvf_free_skb(nic, skb);
+	nicvf_put_sq_desc(sq, hdr->subdesc_cnt + 1);
+	nicvf_check_cqe_tx_errs(nic, cq, cq_desc);
+}
+
+static void nicvf_rcv_pkt_handler(struct net_device *netdev,
+				  struct napi_struct *napi,
+				  struct cmp_queue *cq,
+				  void *cq_desc, int cqe_type)
+{
+	struct sk_buff *skb;
+	struct nicvf *nic = netdev_priv(netdev);
+	struct cqe_rx_t *cqe_rx = (struct cqe_rx_t *)cq_desc;
+	int err = 0;
+
+	/* Check for errors */
+	err = nicvf_check_cqe_rx_errs(nic, cq, cq_desc);
+	if (err && !cqe_rx->rb_cnt)
+		return;
+
+	skb = nicvf_get_rcv_skb(nic, cq_desc);
+	if (!skb) {
+		nic_dbg(&nic->pdev->dev, "Packet not received\n");
+		return;
+	}
+
+	nicvf_dump_packet(skb);
+
+#ifdef NICVF_ETHTOOL_ENABLE
+	nicvf_set_rx_frame_cnt(nic, skb);
+#endif
+
+	skb->protocol = eth_type_trans(skb, netdev);
+
+#ifdef VNIC_RX_CHKSUM_SUPPORTED
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
+#else
+	skb_checksum_none_assert(skb);
+#endif
+
+	if (napi && (netdev->features & NETIF_F_GRO))
+		napi_gro_receive(napi, skb);
+	else
+		netif_receive_skb(skb);
+}
+
+static int nicvf_cq_intr_handler(struct net_device *netdev, uint8_t cq_idx,
+				 struct napi_struct *napi, int budget)
+{
+	int processed_cqe = 0, work_done = 0;
+	int cqe_count, cqe_head;
+	struct nicvf *nic = netdev_priv(netdev);
+	struct queue_set *qs = nic->qs;
+	struct cmp_queue *cq = &qs->cq[cq_idx];
+	struct cqe_rx_t *cq_desc;
+
+	spin_lock(&cq->cq_lock);
+	/* Get no of valid CQ entries to process */
+	cqe_count = nicvf_queue_reg_read(nic, NIC_QSET_CQ_0_7_STATUS, cq_idx);
+	cqe_count &= CQ_CQE_COUNT;
+	if (!cqe_count)
+		goto done;
+
+	/* Get head of the valid CQ entries */
+	cqe_head = nicvf_queue_reg_read(nic, NIC_QSET_CQ_0_7_HEAD, cq_idx) >> 9;
+	cqe_head &= 0xFFFF;
+
+	nic_dbg(&nic->pdev->dev, "%s cqe_count %d cqe_head %d\n",
+		__func__, cqe_count, cqe_head);
+	while (processed_cqe < cqe_count) {
+		/* Get the CQ descriptor */
+		cq_desc = (struct cqe_rx_t *)GET_CQ_DESC(cq, cqe_head);
+
+		if (napi && (work_done >= budget) &&
+		    (cq_desc->cqe_type != CQE_TYPE_SEND)) {
+			break;
+		}
+
+		nic_dbg(&nic->pdev->dev, "cq_desc->cqe_type %d\n",
+			cq_desc->cqe_type);
+		switch (cq_desc->cqe_type) {
+		case CQE_TYPE_RX:
+			nicvf_rcv_pkt_handler(netdev, napi, cq,
+					      cq_desc, CQE_TYPE_RX);
+			work_done++;
+		break;
+		case CQE_TYPE_SEND:
+			nicvf_snd_pkt_handler(netdev, cq,
+					      cq_desc, CQE_TYPE_SEND);
+		break;
+		case CQE_TYPE_INVALID:
+		case CQE_TYPE_RX_SPLIT:
+		case CQE_TYPE_RX_TCP:
+		case CQE_TYPE_SEND_PTP:
+			/* Ignore for now */
+		break;
+		}
+		cq_desc->cqe_type = CQE_TYPE_INVALID;
+		processed_cqe++;
+		cqe_head++;
+		cqe_head &= (cq->dmem.q_len - 1);
+		memset(cq_desc, 0, sizeof(struct cqe_rx_t));
+	}
+	nic_dbg(&nic->pdev->dev, "%s processed_cqe %d work_done %d budget %d\n",
+		__func__, processed_cqe, work_done, budget);
+
+	/* Ring doorbell to inform H/W to reuse processed CQEs */
+	nicvf_queue_reg_write(nic, NIC_QSET_CQ_0_7_DOOR,
+			      cq_idx, processed_cqe);
+done:
+	spin_unlock(&cq->cq_lock);
+	return work_done;
+}
+
+static int nicvf_poll(struct napi_struct *napi, int budget)
+{
+	int  work_done = 0;
+	struct net_device *netdev = napi->dev;
+	struct nicvf *nic = netdev_priv(netdev);
+	struct nicvf_cq_poll *cq;
+	struct netdev_queue *txq;
+
+	cq = container_of(napi, struct nicvf_cq_poll, napi);
+	work_done = nicvf_cq_intr_handler(netdev, cq->cq_idx, napi, budget);
+
+	txq = netdev_get_tx_queue(netdev, cq->cq_idx);
+	if (netif_tx_queue_stopped(txq))
+		netif_tx_wake_queue(txq);
+
+	if (work_done < budget) {
+		/* Slow packet rate, exit polling */
+		napi_complete(napi);
+		/* Re-enable interrupts */
+		nicvf_enable_intr(nic, NICVF_INTR_CQ, cq->cq_idx);
+	}
+	return work_done;
+}
+
+/* Qset error interrupt handler
+ *
+ * As of now only CQ errors are handled
+ */
+void nicvf_handle_qs_err(unsigned long data)
+{
+	struct nicvf *nic = (struct nicvf *)data;
+	struct queue_set *qs = nic->qs;
+	int qidx;
+	uint64_t status;
+
+	netif_tx_disable(nic->netdev);
+
+	/* Check if it is CQ err */
+	for (qidx = 0; qidx < qs->cq_cnt; qidx++) {
+		status = nicvf_queue_reg_read(nic, NIC_QSET_CQ_0_7_STATUS,
+					      qidx);
+		if (!(status & CQ_ERR_MASK))
+			continue;
+		/* Process already queued CQEs and reconfig CQ */
+		nicvf_disable_intr(nic, NICVF_INTR_CQ, qidx);
+		nicvf_sq_disable(nic, qidx);
+		nicvf_cq_intr_handler(nic->netdev, qidx, NULL, 0);
+		nicvf_cmp_queue_config(nic, qs, qidx, true);
+		nicvf_sq_free_used_descs(nic->netdev, &qs->sq[qidx], qidx);
+		nicvf_sq_enable(nic, &qs->sq[qidx], qidx);
+
+		nicvf_enable_intr(nic, NICVF_INTR_CQ, qidx);
+	}
+
+	netif_tx_start_all_queues(nic->netdev);
+	/* Re-enable Qset error interrupt */
+	nicvf_enable_intr(nic, NICVF_INTR_QS_ERR, 0);
+}
+
+static irqreturn_t nicvf_misc_intr_handler(int irq, void *nicvf_irq)
+{
+	struct nicvf *nic = (struct nicvf *)nicvf_irq;
+	uint64_t intr;
+
+	intr = nicvf_reg_read(nic, NIC_VF_INT);
+	/* Check for spurious interrupt */
+	if (!(intr & NICVF_INTR_MBOX_MASK))
+		return IRQ_HANDLED;
+
+	nicvf_handle_mbx_intr(nic);
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t nicvf_intr_handler(int irq, void *nicvf_irq)
+{
+	uint64_t qidx, intr;
+	uint64_t cq_intr, rbdr_intr, qs_err_intr;
+	struct nicvf *nic = (struct nicvf *)nicvf_irq;
+	struct queue_set *qs = nic->qs;
+	struct nicvf_cq_poll *cq_poll = NULL;
+
+	intr = nicvf_reg_read(nic, NIC_VF_INT);
+	nic_dbg(&nic->pdev->dev, "%s intr status 0x%llx\n", __func__, intr);
+
+	cq_intr = (intr & NICVF_INTR_CQ_MASK) >> NICVF_INTR_CQ_SHIFT;
+	qs_err_intr = intr & NICVF_INTR_QS_ERR_MASK;
+	if (qs_err_intr) {
+		/* Disable Qset err interrupt and schedule softirq */
+		nicvf_disable_intr(nic, NICVF_INTR_QS_ERR, 0);
+		tasklet_hi_schedule(&nic->qs_err_task);
+	}
+
+	/* Disable interrupts and start polling */
+	for (qidx = 0; qidx < qs->cq_cnt; qidx++) {
+		if (!(cq_intr & (1 << qidx)))
+			continue;
+		if (!nicvf_is_intr_enabled(nic, NICVF_INTR_CQ, qidx))
+			continue;
+		nicvf_disable_intr(nic, NICVF_INTR_CQ, qidx);
+		cq_poll = nic->napi[qidx];
+		/* Schedule NAPI */
+		napi_schedule(&cq_poll->napi);
+	}
+
+	/* Handle RBDR interrupts */
+	rbdr_intr = (intr & NICVF_INTR_RBDR_MASK) >> NICVF_INTR_RBDR_SHIFT;
+	if (rbdr_intr) {
+		/* Disable RBDR interrupt and schedule softirq */
+		for (qidx = 0; qidx < qs->rbdr_cnt; qidx++)
+			nicvf_disable_intr(nic, NICVF_INTR_RBDR, qidx);
+
+		tasklet_hi_schedule(&nic->rbdr_task);
+	}
+
+	/* Clear interrupts */
+	nicvf_reg_write(nic, NIC_VF_INT, intr);
+	return IRQ_HANDLED;
+}
+
+static int nicvf_enable_msix(struct nicvf *nic)
+{
+	int i, ret, vec;
+	struct queue_set *qs = nic->qs;
+
+	nic->num_vec = NIC_VF_MSIX_VECTORS;
+	vec = qs->cq_cnt + qs->rbdr_cnt + qs->sq_cnt;
+	vec = NIC_VF_MSIX_VECTORS;
+	if (vec > NIC_VF_MSIX_VECTORS)
+		nic->num_vec = vec;
+
+	for (i = 0; i < nic->num_vec; i++)
+		nic->msix_entries[i].entry = i;
+
+	ret = pci_enable_msix(nic->pdev, nic->msix_entries, nic->num_vec);
+	if (ret) {
+		netdev_err(nic->netdev,
+			   "Req for #%d msix vectors failed\n", nic->num_vec);
+		return 0;
+	}
+	nic->msix_enabled = 1;
+	return 1;
+}
+
+static void nicvf_disable_msix(struct nicvf *nic)
+{
+	if (nic->msix_enabled) {
+		pci_disable_msix(nic->pdev);
+		nic->msix_enabled = 0;
+		nic->num_vec = 0;
+	}
+}
+
+static int nicvf_register_interrupts(struct nicvf *nic)
+{
+	int irq, free, ret = 0;
+	int vector;
+
+	for_each_cq_irq(irq)
+		sprintf(nic->irq_name[irq], "%s%d CQ%d", "NICVF",
+			nic->vf_id, irq);
+
+	for_each_sq_irq(irq)
+		sprintf(nic->irq_name[irq], "%s%d SQ%d", "NICVF",
+			nic->vf_id, irq - NICVF_INTR_ID_SQ);
+
+	for_each_rbdr_irq(irq)
+		sprintf(nic->irq_name[irq], "%s%d RBDR%d", "NICVF",
+			nic->vf_id, irq - NICVF_INTR_ID_RBDR);
+
+	/* Register all interrupts except mailbox */
+	for (irq = 0; irq < NICVF_INTR_ID_MISC; irq++) {
+		vector = nic->msix_entries[irq].vector;
+		ret = request_irq(vector, nicvf_intr_handler,
+				  0, nic->irq_name[irq], nic);
+		if (ret)
+			break;
+		nic->irq_allocated[irq] = 1;
+	}
+
+	sprintf(nic->irq_name[NICVF_INTR_ID_QS_ERR],
+		"%s%d Qset error", "NICVF", nic->vf_id);
+	if (!ret) {
+		vector = nic->msix_entries[NICVF_INTR_ID_QS_ERR].vector;
+		irq = NICVF_INTR_ID_QS_ERR;
+		ret = request_irq(vector, nicvf_intr_handler,
+				  0, nic->irq_name[irq], nic);
+		if (!ret)
+			nic->irq_allocated[irq] = 1;
+	}
+
+	if (ret) {
+		netdev_err(nic->netdev, "Request irq failed\n");
+		for (free = 0; free < irq; free++)
+			free_irq(nic->msix_entries[free].vector, nic);
+		return ret;
+	}
+
+	return 0;
+}
+
+static void nicvf_unregister_interrupts(struct nicvf *nic)
+{
+	int irq;
+
+	/* Free registered interrupts */
+	for (irq = 0; irq < nic->num_vec; irq++) {
+		if (nic->irq_allocated[irq])
+			free_irq(nic->msix_entries[irq].vector, nic);
+		nic->irq_allocated[irq] = 0;
+	}
+
+	/* Disable MSI-X */
+	nicvf_disable_msix(nic);
+}
+
+static int nicvf_register_misc_interrupt(struct nicvf *nic)
+{
+	int ret = 0;
+	int irq = NICVF_INTR_ID_MISC;
+
+	/* Enable MSI-X */
+	if (!nicvf_enable_msix(nic))
+		return 1;
+
+	sprintf(nic->irq_name[irq], "%s Mbox", "NICVF");
+	/* Register Misc interrupt */
+	ret = request_irq(nic->msix_entries[irq].vector,
+			  nicvf_misc_intr_handler, 0, nic->irq_name[irq], nic);
+
+	if (ret)
+		return ret;
+	nic->irq_allocated[irq] = 1;
+
+	/* Enable mailbox interrupt */
+	nicvf_enable_intr(nic, NICVF_INTR_MBOX, 0);
+
+	/* Check if VF is able to communicate with PF */
+	if (!nicvf_check_pf_ready(nic)) {
+		nicvf_disable_intr(nic, NICVF_INTR_MBOX, 0);
+		nicvf_unregister_interrupts(nic);
+		return 1;
+	}
+
+	return 0;
+}
+
+#ifdef VNIC_SW_TSO_SUPPORT
+static int nicvf_sw_tso(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct sk_buff *segs, *nskb;
+	struct nicvf *nic = netdev_priv(netdev);
+
+	if (!skb_shinfo(skb)->gso_size)
+		return 1;
+
+	nic->drv_stats.tx_tso++;
+	/* Segment the large frame */
+	segs = skb_gso_segment(skb, netdev->features & ~NETIF_F_TSO);
+	if (IS_ERR(segs))
+		goto gso_err;
+
+	do {
+		nskb = segs;
+		segs = segs->next;
+		nskb->next = NULL;
+		nicvf_xmit(nskb, netdev);
+	} while (segs);
+
+gso_err:
+	dev_kfree_skb(skb);
+
+	return NETDEV_TX_OK;
+}
+#endif
+
+static netdev_tx_t nicvf_xmit(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct nicvf *nic = netdev_priv(netdev);
+	int qid = skb_get_queue_mapping(skb);
+	struct netdev_queue *txq = netdev_get_tx_queue(netdev, qid);
+	int ret = 1;
+
+	/* Check for minimum packet length */
+	if (skb->len <= ETH_HLEN) {
+		dev_kfree_skb(skb);
+		return NETDEV_TX_OK;
+	}
+
+#ifdef VNIC_SW_TSO_SUPPORT
+	if (netdev->features & NETIF_F_TSO)
+		ret = nicvf_sw_tso(skb, netdev);
+#endif
+	if (ret == NETDEV_TX_OK)
+		return NETDEV_TX_OK;
+
+#ifndef VNIC_TX_CSUM_OFFLOAD_SUPPORT
+	/* Calculate checksum in software */
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		if (unlikely(skb_checksum_help(skb))) {
+			netdev_dbg(netdev, "unable to do checksum\n");
+			dev_kfree_skb_any(skb);
+			return NETDEV_TX_OK;
+		}
+	}
+#endif
+#ifdef VNIC_HW_TSO_SUPPORT
+	if (skb_shinfo(skb)->gso_size && (skb->protocol == ETH_P_IP) &&
+	    (ip_hdr(skb)->protocol != IPPROTO_TCP)) {
+		netdev_dbg(netdev,
+			   "Only TCP segmentation is supported, dropping packet\n");
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
+	}
+#endif
+	if (!nicvf_sq_append_skb(nic, skb) && !netif_tx_queue_stopped(txq)) {
+		netif_tx_stop_queue(txq);
+		nic->drv_stats.tx_busy++;
+		netdev_err(netdev, "VF%d: TX ring full, stopping queue%d\n",
+			   nic->vf_id, qid);
+		return NETDEV_TX_BUSY;
+	}
+
+	return NETDEV_TX_OK;
+}
+
+int nicvf_stop(struct net_device *netdev)
+{
+	int qidx;
+	struct nicvf *nic = netdev_priv(netdev);
+	struct queue_set *qs = nic->qs;
+
+	netif_carrier_off(netdev);
+	netif_tx_disable(netdev);
+
+	/* Disable HW Qset, to stop receiving packets */
+	nicvf_qset_config(nic, false);
+
+	/* disable mailbox interrupt */
+	nicvf_disable_intr(nic, NICVF_INTR_MBOX, 0);
+
+	/* Disable interrupts */
+	for (qidx = 0; qidx < qs->cq_cnt; qidx++)
+		nicvf_disable_intr(nic, NICVF_INTR_CQ, qidx);
+	for (qidx = 0; qidx < qs->rbdr_cnt; qidx++)
+		nicvf_disable_intr(nic, NICVF_INTR_RBDR, qidx);
+	nicvf_disable_intr(nic, NICVF_INTR_QS_ERR, 0);
+
+	tasklet_kill(&nic->rbdr_task);
+	tasklet_kill(&nic->qs_err_task);
+
+	nicvf_unregister_interrupts(nic);
+	for (qidx = 0; qidx < nic->qs->cq_cnt; qidx++) {
+		napi_synchronize(&nic->napi[qidx]->napi);
+		napi_disable(&nic->napi[qidx]->napi);
+		netif_napi_del(&nic->napi[qidx]->napi);
+		kfree(nic->napi[qidx]);
+		nic->napi[qidx] = NULL;
+	}
+	/* Free resources */
+	nicvf_config_data_transfer(nic, false);
+
+	return 0;
+}
+
+int nicvf_open(struct net_device *netdev)
+{
+	int err, qidx;
+	struct nicvf *nic = netdev_priv(netdev);
+	struct queue_set *qs = nic->qs;
+	struct nicvf_cq_poll *cq_poll = NULL;
+
+	nic->mtu = netdev->mtu;
+
+	netif_carrier_off(netdev);
+
+	err = nicvf_register_misc_interrupt(nic);
+	if (err)
+		return err;
+
+	err = nicvf_init_resources(nic);
+	if (err) {
+		nicvf_disable_intr(nic, NICVF_INTR_MBOX, 0);
+		nicvf_unregister_interrupts(nic);
+		return err;
+	}
+
+	err = nicvf_register_interrupts(nic);
+	if (err) {
+		nicvf_stop(netdev);
+		return err;
+	}
+
+	for (qidx = 0; qidx < qs->cq_cnt; qidx++) {
+		cq_poll = kzalloc(sizeof(*cq_poll), GFP_KERNEL);
+		if (!cq_poll)
+			goto napi_del;
+		cq_poll->cq_idx = qidx;
+		netif_napi_add(netdev, &cq_poll->napi, nicvf_poll,
+			       NAPI_POLL_WEIGHT);
+		napi_enable(&cq_poll->napi);
+		nic->napi[qidx] = cq_poll;
+	}
+	goto no_err;
+napi_del:
+	while (qidx) {
+		qidx--;
+		cq_poll = nic->napi[qidx];
+		napi_disable(&cq_poll->napi);
+		netif_napi_del(&cq_poll->napi);
+		kfree(cq_poll);
+		nic->napi[qidx] = NULL;
+	}
+	return -ENOMEM;
+no_err:
+	/* Set MAC-ID */
+	if (is_zero_ether_addr(netdev->dev_addr))
+		eth_hw_addr_random(netdev);
+
+	nicvf_hw_set_mac_addr(nic, netdev);
+
+	/* Init tasklet for handling Qset err interrupt */
+	tasklet_init(&nic->qs_err_task, nicvf_handle_qs_err,
+		     (unsigned long)nic);
+
+	/* Enable Qset err interrupt */
+	nicvf_enable_intr(nic, NICVF_INTR_QS_ERR, 0);
+
+	/* Enable completion queue interrupt */
+	for (qidx = 0; qidx < qs->cq_cnt; qidx++)
+		nicvf_enable_intr(nic, NICVF_INTR_CQ, qidx);
+
+	/* Init RBDR tasklet and enable RBDR threshold interrupt */
+	tasklet_init(&nic->rbdr_task, nicvf_refill_rbdr,
+		     (unsigned long)nic);
+
+	for (qidx = 0; qidx < qs->rbdr_cnt; qidx++)
+		nicvf_enable_intr(nic, NICVF_INTR_RBDR, qidx);
+
+	/* Configure CPI alorithm */
+	nic->cpi_alg = cpi_alg;
+	nicvf_config_cpi(nic);
+
+#ifdef	VNIC_RSS_SUPPORT
+	/* Configure receive side scaling */
+	nicvf_rss_init(nic);
+#endif
+
+	if (nicvf_is_link_active(nic)) {
+		netif_carrier_on(netdev);
+		netif_tx_start_all_queues(netdev);
+	}
+
+	return 0;
+}
+
+static int nicvf_update_hw_max_frs(struct nicvf *nic, int mtu)
+{
+	struct nic_mbx mbx = {};
+
+	mbx.msg = NIC_PF_VF_MSG_SET_MAX_FRS;
+	mbx.data.frs.max_frs = mtu;
+	mbx.data.frs.vf_id = nic->vf_id;
+
+	return nicvf_send_msg_to_pf(nic, &mbx);
+}
+
+static int nicvf_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	struct nicvf *nic = netdev_priv(netdev);
+
+	if (new_mtu > NIC_HW_MAX_FRS)
+		return -EINVAL;
+
+	if (new_mtu < NIC_HW_MIN_FRS)
+		return -EINVAL;
+
+	if (nicvf_update_hw_max_frs(nic, new_mtu))
+		return -EINVAL;
+	netdev->mtu = new_mtu;
+
+	return 0;
+}
+
+static int nicvf_set_mac_address(struct net_device *netdev, void *p)
+{
+	struct sockaddr *addr = p;
+	struct nicvf *nic = netdev_priv(netdev);
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	if (nicvf_hw_set_mac_addr(nic, netdev))
+		return -EBUSY;
+
+	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
+
+	return 0;
+}
+
+void nicvf_update_stats(struct nicvf *nic)
+{
+	int qidx;
+	struct nicvf_hw_stats *stats = &nic->stats;
+	struct nicvf_drv_stats *drv_stats = &nic->drv_stats;
+	struct queue_set *qs = nic->qs;
+
+#define GET_RX_STATS(reg) \
+	nicvf_reg_read(nic, NIC_VNIC_RX_STAT_0_13 | (reg << 3))
+#define GET_TX_STATS(reg) \
+	nicvf_reg_read(nic, NIC_VNIC_TX_STAT_0_4 | (reg << 3))
+
+	stats->rx_bytes_ok = GET_RX_STATS(RX_OCTS);
+	stats->rx_ucast_frames_ok = GET_RX_STATS(RX_UCAST);
+	stats->rx_bcast_frames_ok = GET_RX_STATS(RX_BCAST);
+	stats->rx_mcast_frames_ok = GET_RX_STATS(RX_MCAST);
+	stats->rx_fcs_errors = GET_RX_STATS(RX_FCS);
+	stats->rx_l2_errors = GET_RX_STATS(RX_L2ERR);
+	stats->rx_drop_red = GET_RX_STATS(RX_RED);
+	stats->rx_drop_overrun = GET_RX_STATS(RX_ORUN);
+	stats->rx_drop_bcast = GET_RX_STATS(RX_DRP_BCAST);
+	stats->rx_drop_mcast = GET_RX_STATS(RX_DRP_MCAST);
+	stats->rx_drop_l3_bcast = GET_RX_STATS(RX_DRP_L3BCAST);
+	stats->rx_drop_l3_mcast = GET_RX_STATS(RX_DRP_L3MCAST);
+
+	stats->tx_bytes_ok = GET_TX_STATS(TX_OCTS);
+	stats->tx_ucast_frames_ok = GET_TX_STATS(TX_UCAST);
+	stats->tx_bcast_frames_ok = GET_TX_STATS(TX_BCAST);
+	stats->tx_mcast_frames_ok = GET_TX_STATS(TX_MCAST);
+	stats->tx_drops = GET_RX_STATS(TX_DROP);
+
+	drv_stats->rx_frames_ok = stats->rx_ucast_frames_ok +
+				  stats->rx_bcast_frames_ok +
+				  stats->rx_mcast_frames_ok;
+	drv_stats->tx_frames_ok = stats->tx_ucast_frames_ok +
+				  stats->tx_bcast_frames_ok +
+				  stats->tx_mcast_frames_ok;
+	drv_stats->rx_drops = stats->rx_drop_red +
+			      stats->rx_drop_overrun;
+	drv_stats->rx_drops = stats->tx_drops;
+
+	/* Update RQ and SQ stats */
+	for (qidx = 0; qidx < qs->rq_cnt; qidx++)
+		nicvf_update_rq_stats(nic, qidx);
+	for (qidx = 0; qidx < qs->sq_cnt; qidx++)
+		nicvf_update_sq_stats(nic, qidx);
+}
+
+struct rtnl_link_stats64 *nicvf_get_stats64(struct net_device *netdev,
+					    struct rtnl_link_stats64 *stats)
+{
+	struct nicvf *nic = netdev_priv(netdev);
+	struct nicvf_hw_stats *hw_stats = &nic->stats;
+	struct nicvf_drv_stats *drv_stats = &nic->drv_stats;
+
+	nicvf_update_stats(nic);
+
+	stats->rx_bytes = hw_stats->rx_bytes_ok;
+	stats->rx_packets = drv_stats->rx_frames_ok;
+	stats->rx_dropped = drv_stats->rx_drops;
+
+	stats->tx_bytes = hw_stats->tx_bytes_ok;
+	stats->tx_packets = drv_stats->tx_frames_ok;
+	stats->tx_dropped = drv_stats->tx_drops;
+
+	return stats;
+}
+
+static void nicvf_tx_timeout(struct net_device *dev)
+{
+	struct nicvf *nic = netdev_priv(dev);
+
+	netdev_info(dev, "tx timeout\n");
+
+	schedule_work(&nic->reset_task);
+}
+
+static void nicvf_reset_task(struct work_struct *work)
+{
+	struct nicvf *nic;
+
+	nic = container_of(work, struct nicvf, reset_task);
+
+	if (!netif_running(nic->netdev))
+		return;
+
+	nicvf_stop(nic->netdev);
+	nicvf_open(nic->netdev);
+}
+
+static const struct net_device_ops nicvf_netdev_ops = {
+	.ndo_open		= nicvf_open,
+	.ndo_stop		= nicvf_stop,
+	.ndo_start_xmit		= nicvf_xmit,
+	.ndo_change_mtu		= nicvf_change_mtu,
+	.ndo_set_mac_address	= nicvf_set_mac_address,
+	.ndo_get_stats64	= nicvf_get_stats64,
+	.ndo_tx_timeout         = nicvf_tx_timeout,
+};
+
+static int nicvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
+{
+	struct device *dev = &pdev->dev;
+	struct net_device *netdev;
+	struct nicvf *nic;
+	struct queue_set *qs;
+	int    err;
+
+	err = pci_enable_device(pdev);
+	if (err) {
+		dev_err(dev, "Failed to enable PCI device\n");
+		goto exit;
+	}
+
+	err = pci_request_regions(pdev, DRV_NAME);
+	if (err) {
+		dev_err(dev, "PCI request regions failed 0x%x\n", err);
+		goto err_disable_device;
+	}
+
+	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(48));
+	if (err) {
+		dev_err(dev, "Unable to get usable DMA configuration\n");
+		goto err_release_regions;
+	}
+
+	err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(48));
+	if (err) {
+		dev_err(dev, "unable to get 48-bit DMA for consistent allocations\n");
+		goto err_release_regions;
+	}
+
+	netdev = alloc_etherdev_mqs(sizeof(struct nicvf),
+				    MAX_RCV_QUEUES_PER_QS,
+				    MAX_SND_QUEUES_PER_QS);
+	if (!netdev) {
+		err = -ENOMEM;
+		goto err_release_regions;
+	}
+
+	pci_set_drvdata(pdev, netdev);
+
+	SET_NETDEV_DEV(netdev, &pdev->dev);
+
+	nic = netdev_priv(netdev);
+	nic->netdev = netdev;
+	nic->pdev = pdev;
+
+	/* MAP VF's configuration registers */
+	nic->reg_base = (uint64_t)pci_ioremap_bar(pdev, PCI_CFG_REG_BAR_NUM);
+	if (!nic->reg_base) {
+		dev_err(dev, "Cannot map config register space, aborting\n");
+		err = -ENOMEM;
+		goto err_release_regions;
+	}
+
+	err = nicvf_set_qset_resources(nic);
+	if (err)
+		goto err_unmap_resources;
+
+	qs = nic->qs;
+
+	err = nicvf_set_real_num_queues(netdev, qs->sq_cnt, qs->rq_cnt);
+	if (err)
+		goto err_unmap_resources;
+
+#ifdef VNIC_RX_CSUM_OFFLOAD_SUPPORT
+	netdev->hw_features |= NETIF_F_RXCSUM;
+#endif
+#ifdef VNIC_TX_CSUM_OFFLOAD_SUPPORT
+	netdev->hw_features |= NETIF_F_IP_CSUM;
+#endif
+#ifdef VNIC_SG_SUPPORT
+	netdev->hw_features |= NETIF_F_SG;
+#endif
+#ifdef VNIC_TSO_SUPPORT
+	netdev->hw_features |= NETIF_F_TSO | NETIF_F_SG | NETIF_F_IP_CSUM;
+#endif
+	netdev->features |= netdev->hw_features;
+	netdev->netdev_ops = &nicvf_netdev_ops;
+
+	INIT_WORK(&nic->reset_task, nicvf_reset_task);
+
+	err = register_netdev(netdev);
+	if (err) {
+		dev_err(dev, "Failed to register netdevice\n");
+		goto err_unmap_resources;
+	}
+
+#ifdef NICVF_ETHTOOL_ENABLE
+	nicvf_set_ethtool_ops(netdev);
+#endif
+	goto exit;
+
+err_unmap_resources:
+	if (nic->reg_base)
+		iounmap((void *)nic->reg_base);
+err_release_regions:
+	pci_release_regions(pdev);
+err_disable_device:
+	pci_disable_device(pdev);
+exit:
+	return err;
+}
+
+static void nicvf_remove(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct nicvf *nic;
+
+	if (!netdev)
+		return;
+
+	nic = netdev_priv(netdev);
+	unregister_netdev(netdev);
+
+	pci_set_drvdata(pdev, NULL);
+
+	if (nic->reg_base)
+		iounmap((void *)nic->reg_base);
+
+	/* Free Qset */
+	kfree(nic->qs);
+
+	pci_release_regions(pdev);
+	pci_disable_device(pdev);
+	free_netdev(netdev);
+}
+
+static struct pci_driver nicvf_driver = {
+	.name = DRV_NAME,
+	.id_table = nicvf_id_table,
+	.probe = nicvf_probe,
+	.remove = nicvf_remove,
+};
+
+static int __init nicvf_init_module(void)
+{
+	pr_info("%s, ver %s\n", DRV_NAME, DRV_VERSION);
+
+	return pci_register_driver(&nicvf_driver);
+}
+
+static void __exit nicvf_cleanup_module(void)
+{
+	pci_unregister_driver(&nicvf_driver);
+}
+
+module_init(nicvf_init_module);
+module_exit(nicvf_cleanup_module);
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
new file mode 100644
index 000000000000..ffbfe7425c61
--- /dev/null
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -0,0 +1,1302 @@
+/*
+ * Copyright (C) 2014 Cavium, Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of
+ * the License, or (at your option) any later version.
+ */
+
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+
+#include "nic_reg.h"
+#include "nic.h"
+#include "q_struct.h"
+#include "nicvf_queues.h"
+
+#define  MIN_SND_QUEUE_DESC_FOR_PKT_XMIT 2
+
+static int nicvf_alloc_q_desc_mem(struct nicvf *nic, struct q_desc_mem *dmem,
+				  int q_len, int desc_size, int align_bytes)
+{
+	dmem->q_len = q_len;
+	dmem->size = (desc_size * q_len) + align_bytes;
+	dmem->unalign_base = dma_alloc_coherent(&nic->pdev->dev, dmem->size,
+						&dmem->dma, GFP_KERNEL);
+	if (!dmem->unalign_base)
+		return -1;
+
+	dmem->phys_base = NICVF_ALIGNED_ADDR((uint64_t)dmem->dma, align_bytes);
+	dmem->base = (void *)((u8 *)dmem->unalign_base +
+			      (dmem->phys_base - dmem->dma));
+	return 0;
+}
+
+static void nicvf_free_q_desc_mem(struct nicvf *nic, struct q_desc_mem *dmem)
+{
+	if (!dmem)
+		return;
+
+	dma_free_coherent(&nic->pdev->dev, dmem->size,
+			  dmem->unalign_base, dmem->dma);
+	dmem->unalign_base = NULL;
+	dmem->base = NULL;
+}
+
+static int nicvf_alloc_rcv_buffer(struct nicvf *nic,
+				  uint64_t buf_len, unsigned char **rbuf)
+{
+	struct sk_buff *skb = NULL;
+
+	buf_len += NICVF_RCV_BUF_ALIGN_BYTES + sizeof(void *);
+
+	skb = netdev_alloc_skb(nic->netdev, buf_len);
+	if (!skb) {
+		netdev_err(nic->netdev, "Failed to allocate new rcv buffer\n");
+		return -ENOMEM;
+	}
+
+	/* Reserve bytes for storing skb address */
+	skb_reserve(skb, sizeof(void *));
+	/* Align buffer addr to cache line i.e 128 bytes */
+	skb_reserve(skb, NICVF_RCV_BUF_ALIGN_LEN((uint64_t)skb->data));
+
+	/* Store skb address */
+	*(struct sk_buff **)(skb->data - sizeof(void *)) = skb;
+
+	/* Return buffer address */
+	*rbuf = skb->data;
+	return 0;
+}
+
+static struct sk_buff *nicvf_rb_ptr_to_skb(struct nicvf *nic, uint64_t rb_ptr)
+{
+	struct sk_buff *skb;
+
+	rb_ptr = (uint64_t)phys_to_virt(dma_to_phys(&nic->pdev->dev, rb_ptr));
+	skb = (struct sk_buff *)*(uint64_t *)(rb_ptr - sizeof(void *));
+	return skb;
+}
+
+static int  nicvf_init_rbdr(struct nicvf *nic, struct rbdr *rbdr,
+			    int ring_len, int buf_size)
+{
+	int idx;
+	unsigned char *rbuf;
+	struct rbdr_entry_t *desc;
+
+	if (nicvf_alloc_q_desc_mem(nic, &rbdr->dmem, ring_len,
+				   sizeof(struct rbdr_entry_t),
+				   NICVF_RCV_BUF_ALIGN_BYTES)) {
+		netdev_err(nic->netdev,
+			   "Unable to allocate memory for rcv buffer ring\n");
+		return -ENOMEM;
+	}
+
+	rbdr->desc = rbdr->dmem.base;
+	/* Buffer size has to be in multiples of 128 bytes */
+	rbdr->buf_size = buf_size;
+	rbdr->enable = true;
+	rbdr->thresh = RBDR_THRESH;
+
+	for (idx = 0; idx < ring_len; idx++) {
+		if (nicvf_alloc_rcv_buffer(nic, rbdr->buf_size, &rbuf))
+			return -ENOMEM;
+
+		desc = GET_RBDR_DESC(rbdr, idx);
+		desc->buf_addr = pci_map_single(nic->pdev, rbuf,
+						rbdr->buf_size,
+						PCI_DMA_FROMDEVICE) >>
+						NICVF_RCV_BUF_ALIGN;
+	}
+	return 0;
+}
+
+static void nicvf_free_rbdr(struct nicvf *nic, struct rbdr *rbdr, int rbdr_qidx)
+{
+	int head, tail;
+	struct sk_buff *skb;
+	uint64_t buf_addr;
+	struct rbdr_entry_t *desc;
+
+	if (!rbdr)
+		return;
+
+	rbdr->enable = false;
+	if (!rbdr->dmem.base)
+		return;
+
+	head = nicvf_queue_reg_read(nic,
+				    NIC_QSET_RBDR_0_1_HEAD, rbdr_qidx) >> 3;
+	tail = nicvf_queue_reg_read(nic,
+				    NIC_QSET_RBDR_0_1_TAIL, rbdr_qidx) >> 3;
+	/* Free SKBs */
+	while (head != tail) {
+		desc = GET_RBDR_DESC(rbdr, head);
+		buf_addr = desc->buf_addr << NICVF_RCV_BUF_ALIGN;
+		skb = nicvf_rb_ptr_to_skb(nic, buf_addr);
+		pci_unmap_single(nic->pdev, (dma_addr_t)buf_addr,
+				 rbdr->buf_size, PCI_DMA_FROMDEVICE);
+		dev_kfree_skb(skb);
+		head++;
+		head &= (rbdr->dmem.q_len - 1);
+	}
+	/* Free SKB of tail desc */
+	desc = GET_RBDR_DESC(rbdr, tail);
+	buf_addr = desc->buf_addr << NICVF_RCV_BUF_ALIGN;
+	skb = nicvf_rb_ptr_to_skb(nic, buf_addr);
+	pci_unmap_single(nic->pdev, (dma_addr_t)buf_addr,
+			 rbdr->buf_size, PCI_DMA_FROMDEVICE);
+	dev_kfree_skb(skb);
+
+	/* Free RBDR ring */
+	nicvf_free_q_desc_mem(nic, &rbdr->dmem);
+}
+
+/* Refill receive buffer descriptors with new buffers.
+ * This runs in softirq context .
+ */
+void nicvf_refill_rbdr(unsigned long data)
+{
+	struct nicvf *nic = (struct nicvf *)data;
+	struct queue_set *qs = nic->qs;
+	int rbdr_idx = qs->rbdr_cnt;
+	int tail, qcount;
+	int refill_rb_cnt;
+	struct rbdr *rbdr;
+	unsigned char *rbuf;
+	struct rbdr_entry_t *desc;
+
+refill:
+	if (!rbdr_idx)
+		return;
+	rbdr_idx--;
+	rbdr = &qs->rbdr[rbdr_idx];
+	/* Check if it's enabled */
+	if (!rbdr->enable)
+		goto next_rbdr;
+
+	/* check if valid descs reached or crossed threshold level */
+	qcount = nicvf_queue_reg_read(nic, NIC_QSET_RBDR_0_1_STATUS0, rbdr_idx);
+	qcount &= 0x7FFFF;
+	if (qcount > rbdr->thresh)
+		goto next_rbdr;
+
+	/* Get no of desc's to be refilled */
+	refill_rb_cnt = rbdr->thresh;
+
+	/* Start filling descs from tail */
+	tail = nicvf_queue_reg_read(nic, NIC_QSET_RBDR_0_1_TAIL, rbdr_idx) >> 3;
+	while (refill_rb_cnt) {
+		tail++;
+		tail &= (rbdr->dmem.q_len - 1);
+
+		if (nicvf_alloc_rcv_buffer(nic, rbdr->buf_size, &rbuf))
+			break;
+
+		desc = GET_RBDR_DESC(rbdr, tail);
+		desc->buf_addr = pci_map_single(nic->pdev, rbuf, rbdr->buf_size,
+						PCI_DMA_FROMDEVICE) >>
+						NICVF_RCV_BUF_ALIGN;
+		refill_rb_cnt--;
+	}
+	/* Notify HW */
+	nicvf_queue_reg_write(nic, NIC_QSET_RBDR_0_1_DOOR,
+			      rbdr_idx, rbdr->thresh);
+next_rbdr:
+	if (rbdr_idx)
+		goto refill;
+
+	/* Re-enable RBDR interrupts */
+	for (rbdr_idx = 0; rbdr_idx < qs->rbdr_cnt; rbdr_idx++)
+		nicvf_enable_intr(nic, NICVF_INTR_RBDR, rbdr_idx);
+}
+
+/* TBD: how to handle full packets received in CQ
+ * i.e conversion of buffers into SKBs
+ */
+static int nicvf_init_cmp_queue(struct nicvf *nic,
+				struct cmp_queue *cq, int q_len)
+{
+	int time;
+
+	if (nicvf_alloc_q_desc_mem(nic, &cq->dmem, q_len,
+				   CMP_QUEUE_DESC_SIZE,
+				   NICVF_CQ_BASE_ALIGN_BYTES)) {
+		netdev_err(nic->netdev,
+			   "Unable to allocate memory for completion queue\n");
+		return -ENOMEM;
+	}
+	cq->desc = cq->dmem.base;
+	cq->thresh = CMP_QUEUE_CQE_THRESH;
+
+	time = NIC_NS_PER_100_SYETEM_CLK / 100;
+	time = CMP_QUEUE_TIMER_THRESH / (NICPF_CLK_PER_INT_TICK * time);
+	cq->intr_timer_thresh = time;
+
+	return 0;
+}
+
+static void nicvf_free_cmp_queue(struct nicvf *nic, struct cmp_queue *cq)
+{
+	if (!cq)
+		return;
+	if (!cq->dmem.base)
+		return;
+
+	nicvf_free_q_desc_mem(nic, &cq->dmem);
+}
+
+static int nicvf_init_snd_queue(struct nicvf *nic,
+				struct snd_queue *sq, int q_len)
+{
+	if (nicvf_alloc_q_desc_mem(nic, &sq->dmem, q_len,
+				   SND_QUEUE_DESC_SIZE,
+				   NICVF_SQ_BASE_ALIGN_BYTES)) {
+		netdev_err(nic->netdev,
+			   "Unable to allocate memory for send queue\n");
+		return -ENOMEM;
+	}
+
+	sq->desc = sq->dmem.base;
+	sq->skbuff = kcalloc(q_len, sizeof(uint64_t), GFP_ATOMIC);
+	sq->head = 0;
+	sq->tail = 0;
+	sq->free_cnt = q_len;
+	sq->thresh = SND_QUEUE_THRESH;
+
+	return 0;
+}
+
+static void nicvf_free_snd_queue(struct nicvf *nic, struct snd_queue *sq)
+{
+	if (!sq)
+		return;
+	if (!sq->dmem.base)
+		return;
+
+	kfree(sq->skbuff);
+	nicvf_free_q_desc_mem(nic, &sq->dmem);
+}
+
+static void nicvf_rcv_queue_config(struct nicvf *nic, struct queue_set *qs,
+				   int qidx, bool enable)
+{
+	struct nic_mbx mbx = {};
+	struct rcv_queue *rq;
+	struct rq_cfg rq_cfg;
+
+	rq = &qs->rq[qidx];
+	rq->enable = enable;
+
+	if (!rq->enable) {
+		/* Disable receive queue */
+		nicvf_queue_reg_write(nic, NIC_QSET_RQ_0_7_CFG, qidx, 0);
+		return;
+	}
+
+	rq->cq_qs = qs->vnic_id;
+	rq->cq_idx = qidx;
+	rq->start_rbdr_qs = qs->vnic_id;
+	rq->start_qs_rbdr_idx = qs->rbdr_cnt - 1;
+	rq->cont_rbdr_qs = qs->vnic_id;
+	rq->cont_qs_rbdr_idx = qs->rbdr_cnt - 1;
+	rq->caching = 1;
+
+	/* Send a mailbox msg to PF to config RQ */
+	mbx.msg = NIC_PF_VF_MSG_RQ_CFG;
+	mbx.data.rq.qs_num = qs->vnic_id;
+	mbx.data.rq.rq_num = qidx;
+	mbx.data.rq.cfg = (rq->caching << 26) | (rq->cq_qs << 19) |
+			  (rq->cq_idx << 16) | (rq->cont_rbdr_qs << 9) |
+			  (rq->cont_qs_rbdr_idx << 8) |
+			  (rq->start_rbdr_qs << 1) | (rq->start_qs_rbdr_idx);
+	nicvf_send_msg_to_pf(nic, &mbx);
+
+	/* RQ drop config
+	 * Enable CQ drop to reserve sufficient CQEs for all tx packets
+	 */
+	mbx.msg = NIC_PF_VF_MSG_RQ_DROP_CFG;
+	mbx.data.rq.cfg = (1ULL << 62) | (RQ_CQ_DROP << 8);
+	nicvf_send_msg_to_pf(nic, &mbx);
+
+	nicvf_queue_reg_write(nic, NIC_QSET_RQ_GEN_CFG, qidx, 0x00);
+
+	/* Enable Receive queue */
+	rq_cfg.ena = 1;
+	rq_cfg.tcp_ena = 0;
+	nicvf_queue_reg_write(nic, NIC_QSET_RQ_0_7_CFG, qidx, *(u64 *)&rq_cfg);
+}
+
+void nicvf_cmp_queue_config(struct nicvf *nic, struct queue_set *qs,
+			    int qidx, bool enable)
+{
+	struct cmp_queue *cq;
+	struct cq_cfg cq_cfg;
+
+	cq = &qs->cq[qidx];
+	cq->enable = enable;
+	if (!cq->enable) {
+		/* Disable completion queue */
+		nicvf_queue_reg_write(nic, NIC_QSET_CQ_0_7_CFG, qidx, 0);
+		return;
+	}
+
+	/* Reset completion queue */
+	nicvf_queue_reg_write(nic, NIC_QSET_CQ_0_7_CFG, qidx, NICVF_CQ_RESET);
+
+	/* Set completion queue base address */
+	nicvf_queue_reg_write(nic, NIC_QSET_CQ_0_7_BASE,
+			      qidx, (uint64_t)(cq->dmem.phys_base));
+
+	/* Enable Completion queue */
+	cq_cfg.ena = 1;
+	cq_cfg.reset = 0;
+	cq_cfg.caching = 1;
+	cq_cfg.qsize = (qs->cq_len >> 10) - 1;
+	cq_cfg.avg_con = 0;
+	nicvf_queue_reg_write(nic, NIC_QSET_CQ_0_7_CFG, qidx, *(u64 *)&cq_cfg);
+
+	/* Set threshold value for interrupt generation */
+	nicvf_queue_reg_write(nic, NIC_QSET_CQ_0_7_THRESH, qidx, cq->thresh);
+	nicvf_queue_reg_write(nic, NIC_QSET_CQ_0_7_CFG2,
+			      qidx, cq->intr_timer_thresh);
+}
+
+static void nicvf_snd_queue_config(struct nicvf *nic, struct queue_set *qs,
+				   int qidx, bool enable)
+{
+	struct nic_mbx mbx = {};
+	struct snd_queue *sq;
+	struct sq_cfg sq_cfg;
+
+	sq = &qs->sq[qidx];
+	sq->enable = enable;
+	if (!sq->enable) {
+		/* Disable send queue */
+		nicvf_queue_reg_write(nic, NIC_QSET_SQ_0_7_CFG, qidx, 0);
+		return;
+	}
+
+	/* Reset send queue */
+	nicvf_queue_reg_write(nic, NIC_QSET_SQ_0_7_CFG, qidx, NICVF_SQ_RESET);
+
+	sq->cq_qs = qs->vnic_id;
+	sq->cq_idx = qidx;
+
+	/* Send a mailbox msg to PF to config SQ */
+	mbx.msg = NIC_PF_VF_MSG_SQ_CFG;
+	mbx.data.sq.qs_num = qs->vnic_id;
+	mbx.data.sq.sq_num = qidx;
+	mbx.data.sq.cfg = (sq->cq_qs << 3) | sq->cq_idx;
+	nicvf_send_msg_to_pf(nic, &mbx);
+
+	/* Set queue base address */
+	nicvf_queue_reg_write(nic, NIC_QSET_SQ_0_7_BASE,
+			      qidx, (uint64_t)(sq->dmem.phys_base));
+
+	/* Enable send queue  & set queue size */
+	sq_cfg.ena = 1;
+	sq_cfg.reset = 0;
+	sq_cfg.ldwb = 0;
+	sq_cfg.qsize = (qs->sq_len >> 10) - 1;
+	sq_cfg.tstmp_bgx_intf = 0;
+	nicvf_queue_reg_write(nic, NIC_QSET_SQ_0_7_CFG, qidx, *(u64 *)&sq_cfg);
+
+	/* Set threshold value for interrupt generation */
+	nicvf_queue_reg_write(nic, NIC_QSET_SQ_0_7_THRESH, qidx, sq->thresh);
+}
+
+static void nicvf_rbdr_config(struct nicvf *nic, struct queue_set *qs,
+			      int qidx, bool enable)
+{
+	int reset, timeout = 10;
+	struct rbdr *rbdr;
+	struct rbdr_cfg rbdr_cfg;
+
+	rbdr = &qs->rbdr[qidx];
+	if (!enable) {
+		/* Disable RBDR */
+		nicvf_queue_reg_write(nic, NIC_QSET_RBDR_0_1_CFG, qidx, 0);
+		return;
+	}
+
+	/* Reset RBDR */
+	nicvf_queue_reg_write(nic, NIC_QSET_RBDR_0_1_CFG,
+			      qidx, NICVF_RBDR_RESET);
+	/* Wait for reset to finish */
+	while (1) {
+		usleep_range(2000, 3000);
+		reset = nicvf_queue_reg_read(nic, NIC_QSET_RBDR_0_1_CFG, qidx);
+		if (!(reset & NICVF_RBDR_RESET))
+			break;
+		timeout--;
+		if (!timeout) {
+			netdev_err(nic->netdev,
+				   "RBDR%d didn't come out of reset\n", qidx);
+			return;
+		}
+	}
+
+	/* Set descriptor base address */
+	nicvf_queue_reg_write(nic, NIC_QSET_RBDR_0_1_BASE,
+			      qidx, (uint64_t)(rbdr->dmem.phys_base));
+
+	/* Enable RBDR  & set queue size */
+	/* Buffer size should be in multiples of 128 bytes */
+	rbdr_cfg.ena = 1;
+	rbdr_cfg.reset = 0;
+	rbdr_cfg.ldwb = 0;
+	rbdr_cfg.qsize = (qs->rbdr_len >> 13) - 1;
+	rbdr_cfg.avg_con = 0;
+	rbdr_cfg.lines = rbdr->buf_size / 128;
+	nicvf_queue_reg_write(nic, NIC_QSET_RBDR_0_1_CFG,
+			      qidx, *(u64 *)&rbdr_cfg);
+
+	/* Notify HW */
+	nicvf_queue_reg_write(nic, NIC_QSET_RBDR_0_1_DOOR,
+			      qidx, qs->rbdr_len - 1);
+
+	/* Set threshold value for interrupt generation */
+	nicvf_queue_reg_write(nic, NIC_QSET_RBDR_0_1_THRESH,
+			      qidx, rbdr->thresh - 1);
+}
+
+void nicvf_qset_config(struct nicvf *nic, bool enable)
+{
+	struct  nic_mbx mbx = {};
+	struct queue_set *qs = nic->qs;
+	struct qs_cfg *qs_cfg;
+
+	qs->enable = enable;
+
+	/* Send a mailbox msg to PF to config Qset */
+	mbx.msg = NIC_PF_VF_MSG_QS_CFG;
+	mbx.data.qs.num = qs->vnic_id;
+
+	mbx.data.qs.cfg = 0;
+	qs_cfg = (struct qs_cfg *)&mbx.data.qs.cfg;
+	if (qs->enable) {
+		qs_cfg->ena = 1;
+#ifdef __BIG_ENDIAN
+		qs_cfg->be = 1;
+#endif
+		qs_cfg->vnic = qs->vnic_id;
+	}
+	nicvf_send_msg_to_pf(nic, &mbx);
+}
+
+static void nicvf_free_resources(struct nicvf *nic)
+{
+	int qidx;
+	struct queue_set *qs = nic->qs;
+
+	if (!qs)
+		return;
+
+	/* Free receive buffer descriptor ring */
+	for (qidx = 0; qidx < qs->rbdr_cnt; qidx++)
+		nicvf_free_rbdr(nic, &qs->rbdr[qidx], qidx);
+
+	/* Free completion queue */
+	for (qidx = 0; qidx < qs->cq_cnt; qidx++)
+		nicvf_free_cmp_queue(nic, &qs->cq[qidx]);
+
+	/* Free send queue */
+	for (qidx = 0; qidx < qs->sq_cnt; qidx++)
+		nicvf_free_snd_queue(nic, &qs->sq[qidx]);
+}
+
+static int nicvf_alloc_resources(struct nicvf *nic)
+{
+	int qidx;
+	struct queue_set *qs = nic->qs;
+
+	/* Alloc receive buffer descriptor ring */
+	for (qidx = 0; qidx < qs->rbdr_cnt; qidx++) {
+		if (nicvf_init_rbdr(nic, &qs->rbdr[qidx], qs->rbdr_len,
+				    RCV_BUFFER_LEN))
+			goto alloc_fail;
+	}
+
+	/* Alloc send queue */
+	for (qidx = 0; qidx < qs->sq_cnt; qidx++) {
+		if (nicvf_init_snd_queue(nic, &qs->sq[qidx], qs->sq_len))
+			goto alloc_fail;
+	}
+
+	/* Alloc completion queue */
+	for (qidx = 0; qidx < qs->cq_cnt; qidx++) {
+		if (nicvf_init_cmp_queue(nic, &qs->cq[qidx], qs->cq_len))
+			goto alloc_fail;
+	}
+
+	return 0;
+alloc_fail:
+	nicvf_free_resources(nic);
+	return -ENOMEM;
+}
+
+int nicvf_set_qset_resources(struct nicvf *nic)
+{
+	struct queue_set *qs;
+
+	qs = kzalloc(sizeof(*qs), GFP_ATOMIC);
+	if (!qs)
+		return -ENOMEM;
+	nic->qs = qs;
+
+	/* Set count of each queue */
+	qs->rbdr_cnt = RBDR_CNT;
+	qs->rq_cnt = RCV_QUEUE_CNT;
+	qs->sq_cnt = SND_QUEUE_CNT;
+	qs->cq_cnt = CMP_QUEUE_CNT;
+
+	/* Set queue lengths */
+	qs->rbdr_len = RCV_BUF_COUNT;
+	qs->sq_len = SND_QUEUE_LEN;
+	qs->cq_len = CMP_QUEUE_LEN;
+	return 0;
+}
+
+int nicvf_config_data_transfer(struct nicvf *nic, bool enable)
+{
+	bool disable = false;
+	struct queue_set *qs = nic->qs;
+	int qidx;
+
+	if (enable) {
+		qs->vnic_id = nic->vf_id;
+		nic->qs = qs;
+
+		if (nicvf_alloc_resources(nic))
+			return -ENOMEM;
+
+		for (qidx = 0; qidx < qs->rbdr_cnt; qidx++)
+			nicvf_rbdr_config(nic, qs, qidx, enable);
+		for (qidx = 0; qidx < qs->rq_cnt; qidx++)
+			nicvf_rcv_queue_config(nic, qs, qidx, enable);
+		for (qidx = 0; qidx < qs->sq_cnt; qidx++)
+			nicvf_snd_queue_config(nic, qs, qidx, enable);
+		for (qidx = 0; qidx < qs->cq_cnt; qidx++)
+			nicvf_cmp_queue_config(nic, qs, qidx, enable);
+
+	} else {
+		qs = nic->qs;
+		if (!qs)
+			return 0;
+
+		for (qidx = 0; qidx < qs->rbdr_cnt; qidx++)
+			nicvf_rbdr_config(nic, qs, qidx, disable);
+		for (qidx = 0; qidx < qs->rq_cnt; qidx++)
+			nicvf_rcv_queue_config(nic, qs, qidx, disable);
+		for (qidx = 0; qidx < qs->sq_cnt; qidx++)
+			nicvf_snd_queue_config(nic, qs, qidx, disable);
+		for (qidx = 0; qidx < qs->cq_cnt; qidx++)
+			nicvf_cmp_queue_config(nic, qs, qidx, disable);
+
+		nicvf_free_resources(nic);
+	}
+
+	return 0;
+}
+
+/* Get a free desc from send queue
+ * @qs:   Qset from which to get a SQ descriptor
+ * @qnum: SQ number (0...7) in the Qset
+ *
+ * returns descriptor ponter & descriptor number
+ */
+static int nicvf_get_sq_desc(struct queue_set *qs, int qnum, void **desc)
+{
+	int qentry;
+	struct snd_queue *sq = &qs->sq[qnum];
+
+	if (!sq->free_cnt)
+		return 0;
+
+	qentry = sq->tail++;
+	sq->free_cnt--;
+	sq->tail &= (sq->dmem.q_len - 1);
+	*desc = GET_SQ_DESC(sq, qentry);
+	return qentry;
+}
+
+void nicvf_put_sq_desc(struct snd_queue *sq, int desc_cnt)
+{
+	while (desc_cnt--) {
+		sq->free_cnt++;
+		sq->head++;
+		sq->head &= (sq->dmem.q_len - 1);
+	}
+}
+
+void nicvf_sq_enable(struct nicvf *nic, struct snd_queue *sq, int qidx)
+{
+	uint64_t sq_cfg;
+
+	sq_cfg = nicvf_queue_reg_read(nic, NIC_QSET_SQ_0_7_CFG, qidx);
+	sq_cfg |= NICVF_SQ_EN;
+	nicvf_queue_reg_write(nic, NIC_QSET_SQ_0_7_CFG, qidx, sq_cfg);
+	/* Ring doorbell so that H/W restarts processing SQEs */
+	nicvf_queue_reg_write(nic, NIC_QSET_SQ_0_7_DOOR, qidx, 0);
+}
+
+void nicvf_sq_disable(struct nicvf *nic, int qidx)
+{
+	uint64_t sq_cfg;
+
+	sq_cfg = nicvf_queue_reg_read(nic, NIC_QSET_SQ_0_7_CFG, qidx);
+	sq_cfg &= ~NICVF_SQ_EN;
+	nicvf_queue_reg_write(nic, NIC_QSET_SQ_0_7_CFG, qidx, sq_cfg);
+}
+
+void nicvf_sq_free_used_descs(struct net_device *netdev, struct snd_queue *sq,
+			      int qidx)
+{
+	uint64_t head, tail;
+	struct sk_buff *skb;
+	struct nicvf *nic = netdev_priv(netdev);
+	struct sq_hdr_subdesc *hdr;
+
+	head = nicvf_queue_reg_read(nic, NIC_QSET_SQ_0_7_HEAD, qidx) >> 4;
+	tail = nicvf_queue_reg_read(nic, NIC_QSET_SQ_0_7_TAIL, qidx) >> 4;
+	while (sq->head != head) {
+		hdr = (struct sq_hdr_subdesc *)GET_SQ_DESC(sq, sq->head);
+		if (hdr->subdesc_type != SQ_DESC_TYPE_HEADER) {
+			nicvf_put_sq_desc(sq, 1);
+			continue;
+		}
+		skb = (struct sk_buff *)sq->skbuff[sq->head];
+		atomic64_add(1, (atomic64_t *)&netdev->stats.tx_packets);
+		atomic64_add(hdr->tot_len,
+			     (atomic64_t *)&netdev->stats.tx_bytes);
+		nicvf_free_skb(nic, skb);
+		nicvf_put_sq_desc(sq, hdr->subdesc_cnt + 1);
+	}
+}
+
+static int nicvf_sq_subdesc_required(struct nicvf *nic, struct sk_buff *skb)
+{
+	int subdesc_cnt = MIN_SND_QUEUE_DESC_FOR_PKT_XMIT;
+
+	if (skb_shinfo(skb)->nr_frags)
+		subdesc_cnt += skb_shinfo(skb)->nr_frags;
+
+#ifdef VNIC_TX_CSUM_OFFLOAD_SUPPORT
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		if (skb->protocol == htons(ETH_P_IP))
+			subdesc_cnt++;
+		if ((ip_hdr(skb)->protocol == IPPROTO_TCP) ||
+		    (ip_hdr(skb)->protocol == IPPROTO_UDP))
+			subdesc_cnt++;
+	}
+#endif
+
+	return subdesc_cnt;
+}
+
+/* Add SQ HEADER subdescriptor.
+ * First subdescriptor for every send descriptor.
+ */
+struct sq_hdr_subdesc *
+nicvf_sq_add_hdr_subdesc(struct queue_set *qs, int sq_num,
+			 int subdesc_cnt, struct sk_buff *skb)
+{
+	int qentry;
+	void *desc;
+	struct snd_queue *sq;
+	struct sq_hdr_subdesc *hdr;
+
+	sq = &qs->sq[sq_num];
+	qentry = nicvf_get_sq_desc(qs, sq_num, &desc);
+	sq->skbuff[qentry] = (uint64_t)skb;
+
+	hdr = (struct sq_hdr_subdesc *)desc;
+
+	memset(hdr, 0, SND_QUEUE_DESC_SIZE);
+	hdr->subdesc_type = SQ_DESC_TYPE_HEADER;
+	hdr->post_cqe = 1;
+	hdr->subdesc_cnt = subdesc_cnt;
+	hdr->tot_len = skb->len;
+
+#ifdef VNIC_HW_TSO_SUPPORT
+	if (!skb_shinfo(skb)->gso_size)
+		return hdr;
+
+	/* Packet to be subjected to TSO */
+	hdr->tso = 1;
+	hdr->tso_l4_offset = (int)(skb_transport_header(skb) - skb->data) +
+				tcp_hdrlen(skb);
+	hdr->tso_max_paysize = skb_shinfo(skb)->gso_size + hdr->tso_l4_offset;
+	/* TBD: These fields have to be setup properly */
+	hdr->tso_sdc_first	= 0;
+	hdr->tso_sdc_cont	= 0;
+	hdr->tso_flags_first	= 0;
+	hdr->tso_flags_last	= 0;
+#endif
+	return hdr;
+}
+
+/* SQ GATHER subdescriptor
+ * Must follow HDR descriptor
+ */
+static void nicvf_sq_add_gather_subdesc(struct nicvf *nic, struct queue_set *qs,
+					int sq_num, struct sk_buff *skb)
+{
+	int i;
+	void *desc;
+	struct sq_gather_subdesc *gather;
+
+	nicvf_get_sq_desc(qs, sq_num, &desc);
+	gather = (struct sq_gather_subdesc *)desc;
+
+	memset(gather, 0, SND_QUEUE_DESC_SIZE);
+	gather->subdesc_type = SQ_DESC_TYPE_GATHER;
+	gather->ld_type = NIC_SEND_LD_TYPE_E_LDD;
+	gather->size = skb_is_nonlinear(skb) ? skb_headlen(skb) : skb->len;
+	gather->addr = pci_map_single(nic->pdev, skb->data,
+				gather->size, PCI_DMA_TODEVICE);
+
+	if (!skb_is_nonlinear(skb))
+		return;
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		const struct skb_frag_struct *frag;
+
+		frag = &skb_shinfo(skb)->frags[i];
+
+		nicvf_get_sq_desc(qs, sq_num, &desc);
+		gather = (struct sq_gather_subdesc *)desc;
+
+		memset(gather, 0, SND_QUEUE_DESC_SIZE);
+		gather->subdesc_type = SQ_DESC_TYPE_GATHER;
+		gather->ld_type = NIC_SEND_LD_TYPE_E_LDD;
+		gather->size = skb_frag_size(frag);
+		gather->addr = pci_map_single(nic->pdev, skb_frag_address(frag),
+						gather->size, PCI_DMA_TODEVICE);
+	}
+}
+
+#ifdef VNIC_TX_CSUM_OFFLOAD_SUPPORT
+static void nicvf_fill_l3_crc_subdesc(struct sq_crc_subdesc *l3,
+				      struct sk_buff *skb)
+{
+	int crc_pos;
+
+	crc_pos = skb_network_header(skb) - skb_mac_header(skb);
+	crc_pos += offsetof(struct iphdr, check);
+
+	l3->subdesc_type = SQ_DESC_TYPE_CRC;
+	l3->crc_alg = SEND_CRCALG_CRC32;
+	l3->crc_insert_pos = crc_pos;
+	l3->hdr_start = skb_network_offset(skb);
+	l3->crc_len = skb_transport_header(skb) - skb_network_header(skb);
+	l3->crc_ival = 0;
+}
+
+static void nicvf_fill_l4_crc_subdesc(struct sq_crc_subdesc *l4,
+				      struct sk_buff *skb)
+{
+	l4->subdesc_type = SQ_DESC_TYPE_CRC;
+	l4->crc_alg = SEND_CRCALG_CRC32;
+	l4->crc_insert_pos = skb->csum_start + skb->csum_offset;
+	l4->hdr_start = skb->csum_start;
+	l4->crc_len = skb->len - skb_transport_offset(skb);
+	l4->crc_ival = 0;
+}
+
+/* SQ CRC subdescriptor
+ * Must follow HDR and precede GATHER, IMM subdescriptors
+ */
+static void nicvf_sq_add_crc_subdesc(struct nicvf *nic, struct queue_set *qs,
+				     int sq_num, struct sk_buff *skb)
+{
+	int proto;
+	void *desc;
+	struct sq_crc_subdesc *crc;
+	struct snd_queue *sq;
+
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		return;
+
+	if (skb->protocol != htons(ETH_P_IP))
+		return;
+
+	sq = &qs->sq[sq_num];
+	nicvf_get_sq_desc(qs, sq_num, &desc);
+
+	crc = (struct sq_crc_subdesc *)desc;
+
+	nicvf_fill_l3_crc_subdesc(crc, skb);
+
+	proto = ip_hdr(skb)->protocol;
+	if ((proto == IPPROTO_TCP) || (proto == IPPROTO_UDP)) {
+		nicvf_get_sq_desc(qs, sq_num, &desc);
+		crc = (struct sq_crc_subdesc *)desc;
+		nicvf_fill_l4_crc_subdesc(crc, skb);
+	}
+}
+#endif
+
+/* Append an skb to a SQ for packet transfer. */
+int nicvf_sq_append_skb(struct nicvf *nic, struct sk_buff *skb)
+{
+	int subdesc_cnt;
+	int sq_num;
+	struct queue_set *qs = nic->qs;
+	struct snd_queue *sq;
+	struct sq_hdr_subdesc *hdr_desc;
+
+	sq_num = skb_get_queue_mapping(skb);
+	sq = &qs->sq[sq_num];
+
+	subdesc_cnt = nicvf_sq_subdesc_required(nic, skb);
+
+	if (subdesc_cnt > sq->free_cnt)
+		goto append_fail;
+
+	/* Add SQ header subdesc */
+	hdr_desc = nicvf_sq_add_hdr_subdesc(qs, sq_num, subdesc_cnt - 1, skb);
+
+#ifdef VNIC_TX_CSUM_OFFLOAD_SUPPORT
+	/* Add CRC subdescriptor for IP/TCP/UDP (L3/L4) crc calculation */
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		nicvf_sq_add_crc_subdesc(nic, qs, sq_num, skb);
+#endif
+
+	/* Add SQ gather subdesc */
+	nicvf_sq_add_gather_subdesc(nic, qs, sq_num, skb);
+
+	/* Inform HW to xmit new packet */
+	nicvf_queue_reg_write(nic, NIC_QSET_SQ_0_7_DOOR,
+			      sq_num, subdesc_cnt);
+	return 1;
+
+append_fail:
+	nic_dbg(&nic->pdev->dev, "Not enough SQ descriptors to xmit pkt\n");
+	return 0;
+}
+
+static unsigned frag_num(unsigned i)
+{
+#ifdef __BIG_ENDIAN
+	return (i & ~3) + 3 - (i & 3);
+#else
+	return i;
+#endif
+}
+
+struct sk_buff *nicvf_get_rcv_skb(struct nicvf *nic, void *cq_desc)
+{
+	int frag;
+	int payload_len = 0;
+	struct sk_buff *skb = NULL;
+	struct sk_buff *skb_frag = NULL;
+	struct sk_buff *prev_frag = NULL;
+	struct cqe_rx_t *cqe_rx;
+	struct rbdr *rbdr;
+	struct rcv_queue *rq;
+	struct queue_set *qs = nic->qs;
+	uint16_t *rb_lens = NULL;
+	uint64_t *rb_ptrs = NULL;
+
+	cqe_rx = (struct cqe_rx_t *)cq_desc;
+
+	rq = &qs->rq[cqe_rx->rq_idx];
+	rbdr = &qs->rbdr[rq->start_qs_rbdr_idx];
+	rb_lens = cq_desc + (3 * sizeof(uint64_t)); /* Use offsetof */
+	rb_ptrs = cq_desc + (6 * sizeof(uint64_t));
+	nic_dbg(&nic->pdev->dev, "%s rb_cnt %d rb0_ptr %llx rb0_sz %d\n",
+		__func__, cqe_rx->rb_cnt, cqe_rx->rb0_ptr, cqe_rx->rb0_sz);
+
+	for (frag = 0; frag < cqe_rx->rb_cnt; frag++) {
+		payload_len = rb_lens[frag_num(frag)];
+		if (!frag) {
+			/* First fragment */
+			pci_unmap_single(nic->pdev, (dma_addr_t)(*rb_ptrs),
+					 rbdr->buf_size, PCI_DMA_FROMDEVICE);
+			skb = nicvf_rb_ptr_to_skb(nic, *rb_ptrs);
+			if (cqe_rx->align_pad) {
+				skb->data += cqe_rx->align_pad;
+				skb->tail += cqe_rx->align_pad;
+			}
+			skb_put(skb, payload_len);
+		} else {
+			/* Add fragments */
+			pci_unmap_single(nic->pdev, (dma_addr_t)(*rb_ptrs),
+					 rbdr->buf_size, PCI_DMA_FROMDEVICE);
+			skb_frag = nicvf_rb_ptr_to_skb(nic, *rb_ptrs);
+
+			if (!skb_shinfo(skb)->frag_list)
+				skb_shinfo(skb)->frag_list = skb_frag;
+			else
+				prev_frag->next = skb_frag;
+
+			prev_frag = skb_frag;
+			skb->len += payload_len;
+			skb->data_len += payload_len;
+			skb_frag->len = payload_len;
+		}
+		/* Next buffer pointer */
+		rb_ptrs++;
+	}
+	return skb;
+}
+
+/* Enable interrupt */
+void nicvf_enable_intr(struct nicvf *nic, int int_type, int q_idx)
+{
+	uint64_t reg_val;
+
+	reg_val = nicvf_reg_read(nic, NIC_VF_ENA_W1S);
+
+	switch (int_type) {
+	case NICVF_INTR_CQ:
+		reg_val |= ((1ULL << q_idx) << NICVF_INTR_CQ_SHIFT);
+	break;
+	case NICVF_INTR_SQ:
+		reg_val |= ((1ULL << q_idx) << NICVF_INTR_SQ_SHIFT);
+	break;
+	case NICVF_INTR_RBDR:
+		reg_val |= ((1ULL << q_idx) << NICVF_INTR_RBDR_SHIFT);
+	break;
+	case NICVF_INTR_PKT_DROP:
+		reg_val |= (1ULL << NICVF_INTR_PKT_DROP_SHIFT);
+	break;
+	case NICVF_INTR_TCP_TIMER:
+		reg_val |= (1ULL << NICVF_INTR_TCP_TIMER_SHIFT);
+	break;
+	case NICVF_INTR_MBOX:
+		reg_val |= (1ULL << NICVF_INTR_MBOX_SHIFT);
+	break;
+	case NICVF_INTR_QS_ERR:
+		reg_val |= (1ULL << NICVF_INTR_QS_ERR_SHIFT);
+	break;
+	default:
+		netdev_err(nic->netdev,
+			   "Failed to enable interrupt: unknown type\n");
+	break;
+	}
+
+	nicvf_reg_write(nic, NIC_VF_ENA_W1S, reg_val);
+}
+
+/* Disable interrupt */
+void nicvf_disable_intr(struct nicvf *nic, int int_type, int q_idx)
+{
+	uint64_t reg_val = 0;
+
+	switch (int_type) {
+	case NICVF_INTR_CQ:
+		reg_val |= ((1ULL << q_idx) << NICVF_INTR_CQ_SHIFT);
+	break;
+	case NICVF_INTR_SQ:
+		reg_val |= ((1ULL << q_idx) << NICVF_INTR_SQ_SHIFT);
+	break;
+	case NICVF_INTR_RBDR:
+		reg_val |= ((1ULL << q_idx) << NICVF_INTR_RBDR_SHIFT);
+	break;
+	case NICVF_INTR_PKT_DROP:
+		reg_val |= (1ULL << NICVF_INTR_PKT_DROP_SHIFT);
+	break;
+	case NICVF_INTR_TCP_TIMER:
+		reg_val |= (1ULL << NICVF_INTR_TCP_TIMER_SHIFT);
+	break;
+	case NICVF_INTR_MBOX:
+		reg_val |= (1ULL << NICVF_INTR_MBOX_SHIFT);
+	break;
+	case NICVF_INTR_QS_ERR:
+		reg_val |= (1ULL << NICVF_INTR_QS_ERR_SHIFT);
+	break;
+	default:
+		netdev_err(nic->netdev,
+			   "Failed to disable interrupt: unknown type\n");
+	break;
+	}
+
+	nicvf_reg_write(nic, NIC_VF_ENA_W1C, reg_val);
+}
+
+/* Clear interrupt */
+void nicvf_clear_intr(struct nicvf *nic, int int_type, int q_idx)
+{
+	uint64_t reg_val = 0;
+
+	switch (int_type) {
+	case NICVF_INTR_CQ:
+		reg_val = ((1ULL << q_idx) << NICVF_INTR_CQ_SHIFT);
+	break;
+	case NICVF_INTR_SQ:
+		reg_val = ((1ULL << q_idx) << NICVF_INTR_SQ_SHIFT);
+	break;
+	case NICVF_INTR_RBDR:
+		reg_val = ((1ULL << q_idx) << NICVF_INTR_RBDR_SHIFT);
+	break;
+	case NICVF_INTR_PKT_DROP:
+		reg_val = (1ULL << NICVF_INTR_PKT_DROP_SHIFT);
+	break;
+	case NICVF_INTR_TCP_TIMER:
+		reg_val = (1ULL << NICVF_INTR_TCP_TIMER_SHIFT);
+	break;
+	case NICVF_INTR_MBOX:
+		reg_val = (1ULL << NICVF_INTR_MBOX_SHIFT);
+	break;
+	case NICVF_INTR_QS_ERR:
+		reg_val |= (1ULL << NICVF_INTR_QS_ERR_SHIFT);
+	break;
+	default:
+		netdev_err(nic->netdev,
+			   "Failed to clear interrupt: unknown type\n");
+	break;
+	}
+
+	nicvf_reg_write(nic, NIC_VF_INT, reg_val);
+}
+
+/* Check if interrupt is enabled */
+int nicvf_is_intr_enabled(struct nicvf *nic, int int_type, int q_idx)
+{
+	uint64_t reg_val;
+	uint64_t mask = 0xff;
+
+	reg_val = nicvf_reg_read(nic, NIC_VF_ENA_W1S);
+
+	switch (int_type) {
+	case NICVF_INTR_CQ:
+		mask = ((1ULL << q_idx) << NICVF_INTR_CQ_SHIFT);
+	break;
+	case NICVF_INTR_SQ:
+		mask = ((1ULL << q_idx) << NICVF_INTR_SQ_SHIFT);
+	break;
+	case NICVF_INTR_RBDR:
+		mask = ((1ULL << q_idx) << NICVF_INTR_RBDR_SHIFT);
+	break;
+	case NICVF_INTR_PKT_DROP:
+		mask = NICVF_INTR_PKT_DROP_MASK;
+	break;
+	case NICVF_INTR_TCP_TIMER:
+		mask = NICVF_INTR_TCP_TIMER_MASK;
+	break;
+	case NICVF_INTR_MBOX:
+		mask = NICVF_INTR_MBOX_MASK;
+	break;
+	case NICVF_INTR_QS_ERR:
+		mask = NICVF_INTR_QS_ERR_MASK;
+	break;
+	default:
+		netdev_err(nic->netdev,
+			   "Failed to check interrupt enable: unknown type\n");
+	break;
+	}
+
+	return (reg_val & mask);
+}
+
+void nicvf_update_rq_stats(struct nicvf *nic, int rq_idx)
+{
+	struct rcv_queue *rq;
+
+#define GET_RQ_STATS(reg) \
+	nicvf_reg_read(nic, NIC_QSET_RQ_0_7_STAT_0_1 |\
+			    (rq_idx << NIC_Q_NUM_SHIFT) | (reg << 3))
+
+	rq = &nic->qs->rq[rq_idx];
+	rq->stats.bytes = GET_RQ_STATS(RQ_SQ_STATS_OCTS);
+	rq->stats.pkts = GET_RQ_STATS(RQ_SQ_STATS_PKTS);
+}
+
+void nicvf_update_sq_stats(struct nicvf *nic, int sq_idx)
+{
+	struct snd_queue *sq;
+
+#define GET_SQ_STATS(reg) \
+	nicvf_reg_read(nic, NIC_QSET_SQ_0_7_STAT_0_1 |\
+			    (sq_idx << NIC_Q_NUM_SHIFT) | (reg << 3))
+
+	sq = &nic->qs->sq[sq_idx];
+	sq->stats.bytes = GET_SQ_STATS(RQ_SQ_STATS_OCTS);
+	sq->stats.pkts = GET_SQ_STATS(RQ_SQ_STATS_PKTS);
+}
+
+/* Check for errors in the receive cmp.queue entry */
+int nicvf_check_cqe_rx_errs(struct nicvf *nic,
+			    struct cmp_queue *cq, void *cq_desc)
+{
+	struct cqe_rx_t *cqe_rx;
+	struct cmp_queue_stats *stats = &cq->stats;
+
+	cqe_rx = (struct cqe_rx_t *)cq_desc;
+	if (!cqe_rx->err_level && !cqe_rx->err_opcode) {
+		stats->rx.errop.good++;
+		return 0;
+	}
+
+	switch (cqe_rx->err_level) {
+	case CQ_ERRLVL_MAC:
+		stats->rx.errlvl.mac_errs++;
+	break;
+	case CQ_ERRLVL_L2:
+		stats->rx.errlvl.l2_errs++;
+	break;
+	case CQ_ERRLVL_L3:
+		stats->rx.errlvl.l3_errs++;
+	break;
+	case CQ_ERRLVL_L4:
+		stats->rx.errlvl.l4_errs++;
+	break;
+	}
+
+	switch (cqe_rx->err_opcode) {
+	case CQ_RX_ERROP_RE_PARTIAL:
+		stats->rx.errop.partial_pkts++;
+	break;
+	case CQ_RX_ERROP_RE_JABBER:
+		stats->rx.errop.jabber_errs++;
+	break;
+	case CQ_RX_ERROP_RE_FCS:
+		stats->rx.errop.fcs_errs++;
+	break;
+	case CQ_RX_ERROP_RE_TERMINATE:
+		stats->rx.errop.terminate_errs++;
+	break;
+	case CQ_RX_ERROP_RE_RX_CTL:
+		stats->rx.errop.bgx_rx_errs++;
+	break;
+	case CQ_RX_ERROP_PREL2_ERR:
+		stats->rx.errop.prel2_errs++;
+	break;
+	case CQ_RX_ERROP_L2_FRAGMENT:
+		stats->rx.errop.l2_frags++;
+	break;
+	case CQ_RX_ERROP_L2_OVERRUN:
+		stats->rx.errop.l2_overruns++;
+	break;
+	case CQ_RX_ERROP_L2_PFCS:
+		stats->rx.errop.l2_pfcs++;
+	break;
+	case CQ_RX_ERROP_L2_PUNY:
+		stats->rx.errop.l2_puny++;
+	break;
+	case CQ_RX_ERROP_L2_MAL:
+		stats->rx.errop.l2_hdr_malformed++;
+	break;
+	case CQ_RX_ERROP_L2_OVERSIZE:
+		stats->rx.errop.l2_oversize++;
+	break;
+	case CQ_RX_ERROP_L2_UNDERSIZE:
+		stats->rx.errop.l2_undersize++;
+	break;
+	case CQ_RX_ERROP_L2_LENMISM:
+		stats->rx.errop.l2_len_mismatch++;
+	break;
+	case CQ_RX_ERROP_L2_PCLP:
+		stats->rx.errop.l2_pclp++;
+	break;
+	case CQ_RX_ERROP_IP_NOT:
+		stats->rx.errop.non_ip++;
+	break;
+	case CQ_RX_ERROP_IP_CSUM_ERR:
+		stats->rx.errop.ip_csum_err++;
+	break;
+	case CQ_RX_ERROP_IP_MAL:
+		stats->rx.errop.ip_hdr_malformed++;
+	break;
+	case CQ_RX_ERROP_IP_MALD:
+		stats->rx.errop.ip_payload_malformed++;
+	break;
+	case CQ_RX_ERROP_IP_HOP:
+		stats->rx.errop.ip_hop_errs++;
+	break;
+	case CQ_RX_ERROP_L3_ICRC:
+		stats->rx.errop.l3_icrc_errs++;
+	break;
+	case CQ_RX_ERROP_L3_PCLP:
+		stats->rx.errop.l3_pclp++;
+	break;
+	case CQ_RX_ERROP_L4_MAL:
+		stats->rx.errop.l4_malformed++;
+	break;
+	case CQ_RX_ERROP_L4_CHK:
+		stats->rx.errop.l4_csum_errs++;
+	break;
+	case CQ_RX_ERROP_UDP_LEN:
+		stats->rx.errop.udp_len_err++;
+	break;
+	case CQ_RX_ERROP_L4_PORT:
+		stats->rx.errop.bad_l4_port++;
+	break;
+	case CQ_RX_ERROP_TCP_FLAG:
+		stats->rx.errop.bad_tcp_flag++;
+	break;
+	case CQ_RX_ERROP_TCP_OFFSET:
+		stats->rx.errop.tcp_offset_errs++;
+	break;
+	case CQ_RX_ERROP_L4_PCLP:
+		stats->rx.errop.l4_pclp++;
+	break;
+	case CQ_RX_ERROP_RBDR_TRUNC:
+		stats->rx.errop.pkt_truncated++;
+	break;
+	}
+
+	return 1;
+}
+
+/* Check for errors in the send cmp.queue entry */
+int nicvf_check_cqe_tx_errs(struct nicvf *nic,
+			    struct cmp_queue *cq, void *cq_desc)
+{
+	struct cqe_send_t *cqe_tx;
+	struct cmp_queue_stats *stats = &cq->stats;
+
+	cqe_tx = (struct cqe_send_t *)cq_desc;
+	switch (cqe_tx->send_status) {
+	case CQ_TX_ERROP_GOOD:
+		stats->tx.good++;
+		return 0;
+	break;
+	case CQ_TX_ERROP_DESC_FAULT:
+		stats->tx.desc_fault++;
+	break;
+	case CQ_TX_ERROP_HDR_CONS_ERR:
+		stats->tx.hdr_cons_err++;
+	break;
+	case CQ_TX_ERROP_SUBDC_ERR:
+		stats->tx.subdesc_err++;
+	break;
+	case CQ_TX_ERROP_IMM_SIZE_OFLOW:
+		stats->tx.imm_size_oflow++;
+	break;
+	case CQ_TX_ERROP_DATA_SEQUENCE_ERR:
+		stats->tx.data_seq_err++;
+	break;
+	case CQ_TX_ERROP_MEM_SEQUENCE_ERR:
+		stats->tx.mem_seq_err++;
+	break;
+	case CQ_TX_ERROP_LOCK_VIOL:
+		stats->tx.lock_viol++;
+	break;
+	case CQ_TX_ERROP_DATA_FAULT:
+		stats->tx.data_fault++;
+	break;
+	case CQ_TX_ERROP_TSTMP_CONFLICT:
+		stats->tx.tstmp_conflict++;
+	break;
+	case CQ_TX_ERROP_TSTMP_TIMEOUT:
+		stats->tx.tstmp_timeout++;
+	break;
+	case CQ_TX_ERROP_MEM_FAULT:
+		stats->tx.mem_fault++;
+	break;
+	case CQ_TX_ERROP_CK_OVERLAP:
+		stats->tx.csum_overlap++;
+	break;
+	case CQ_TX_ERROP_CK_OFLOW:
+		stats->tx.csum_overflow++;
+	break;
+	}
+
+	return 1;
+}
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.h b/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
new file mode 100644
index 000000000000..f3383492d114
--- /dev/null
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
@@ -0,0 +1,355 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (C) 2014 Cavium, Inc.
+ */
+
+#ifndef NICVF_QUEUES_H
+#define NICVF_QUEUES_H
+
+#include "q_struct.h"
+
+#define MAX_QUEUE_SET			128
+#define MAX_RCV_QUEUES_PER_QS		8
+#define MAX_RCV_BUF_DESC_RINGS_PER_QS	2
+#define MAX_SND_QUEUES_PER_QS		8
+#define MAX_CMP_QUEUES_PER_QS		8
+
+/* VF's queue interrupt ranges */
+#define	NICVF_INTR_ID_CQ		0
+#define	NICVF_INTR_ID_SQ		8
+#define	NICVF_INTR_ID_RBDR		16
+#define	NICVF_INTR_ID_MISC		18
+#define	NICVF_INTR_ID_QS_ERR		19
+
+#define	for_each_cq_irq(irq)	\
+	for (irq = NICVF_INTR_ID_CQ; irq < NICVF_INTR_ID_SQ; irq++)
+#define	for_each_sq_irq(irq)	\
+	for (irq = NICVF_INTR_ID_SQ; irq < NICVF_INTR_ID_RBDR; irq++)
+#define	for_each_rbdr_irq(irq)	\
+	for (irq = NICVF_INTR_ID_RBDR; irq < NICVF_INTR_ID_MISC; irq++)
+
+#define RBDR_SIZE0		0ULL /* 8K entries */
+#define RBDR_SIZE1		1ULL /* 16K entries */
+#define RBDR_SIZE2		2ULL /* 32K entries */
+#define RBDR_SIZE3		3ULL /* 64K entries */
+#define RBDR_SIZE4		4ULL /* 126K entries */
+#define RBDR_SIZE5		5ULL /* 256K entries */
+#define RBDR_SIZE6		6ULL /* 512K entries */
+
+#define SND_QUEUE_SIZE0		0ULL /* 1K entries */
+#define SND_QUEUE_SIZE1		1ULL /* 2K entries */
+#define SND_QUEUE_SIZE2		2ULL /* 4K entries */
+#define SND_QUEUE_SIZE3		3ULL /* 8K entries */
+#define SND_QUEUE_SIZE4		4ULL /* 16K entries */
+#define SND_QUEUE_SIZE5		5ULL /* 32K entries */
+#define SND_QUEUE_SIZE6		6ULL /* 64K entries */
+
+#define CMP_QUEUE_SIZE0		0ULL /* 1K entries */
+#define CMP_QUEUE_SIZE1		1ULL /* 2K entries */
+#define CMP_QUEUE_SIZE2		2ULL /* 4K entries */
+#define CMP_QUEUE_SIZE3		3ULL /* 8K entries */
+#define CMP_QUEUE_SIZE4		4ULL /* 16K entries */
+#define CMP_QUEUE_SIZE5		5ULL /* 32K entries */
+#define CMP_QUEUE_SIZE6		6ULL /* 64K entries */
+
+/* Default queue count per QS, its lengths and threshold values */
+#define RBDR_CNT		1
+#define RCV_QUEUE_CNT		1
+#define SND_QUEUE_CNT		8
+#define CMP_QUEUE_CNT		8 /* Max of RCV and SND qcount */
+
+#define SND_QUEUE_LEN		(1ULL << (SND_QUEUE_SIZE0 + 10))
+#define SND_QUEUE_THRESH	2ULL
+
+#define CMP_QUEUE_LEN		(1ULL << (CMP_QUEUE_SIZE1 + 10))
+#define CMP_QUEUE_CQE_THRESH	10
+#define CMP_QUEUE_TIMER_THRESH	1000 /* 1 ms */
+
+#define RCV_BUF_COUNT		(1ULL << (RBDR_SIZE0 + 13))
+#define RBDR_THRESH		(RCV_BUF_COUNT / 2)
+#define RCV_BUFFER_LEN		2048 /* In multiples of 128bytes */
+#define RQ_CQ_DROP		((CMP_QUEUE_LEN - SND_QUEUE_LEN) / 256)
+
+/* Descriptor size */
+#define SND_QUEUE_DESC_SIZE	16   /* 128 bits */
+#define CMP_QUEUE_DESC_SIZE	512
+
+/* Buffer / descriptor alignments */
+#define NICVF_RCV_BUF_ALIGN		7
+#define NICVF_RCV_BUF_ALIGN_BYTES	(1ULL << NICVF_RCV_BUF_ALIGN)
+#define NICVF_CQ_BASE_ALIGN_BYTES	512  /* 9 bits */
+#define NICVF_SQ_BASE_ALIGN_BYTES	128  /* 7 bits */
+
+#define NICVF_ALIGNED_ADDR(ADDR, ALIGN_BYTES)	ALIGN(ADDR, ALIGN_BYTES)
+#define NICVF_ADDR_ALIGN_LEN(ADDR, BYTES)\
+	(NICVF_ALIGNED_ADDR(ADDR, BYTES) - BYTES)
+#define NICVF_RCV_BUF_ALIGN_LEN(X)\
+	(NICVF_ALIGNED_ADDR(X, NICVF_RCV_BUF_ALIGN_BYTES) - X)
+
+/* Queue enable/disable */
+#define NICVF_SQ_EN            (1ULL << 19)
+
+/* Queue reset */
+#define NICVF_CQ_RESET		(1ULL << 41)
+#define NICVF_SQ_RESET		(1ULL << 17)
+#define NICVF_RBDR_RESET	(1ULL << 43)
+
+enum CQ_RX_ERRLVL_E {
+	CQ_ERRLVL_MAC,
+	CQ_ERRLVL_L2,
+	CQ_ERRLVL_L3,
+	CQ_ERRLVL_L4,
+};
+
+enum CQ_RX_ERROP_E {
+	CQ_RX_ERROP_RE_NONE = 0x0,
+	CQ_RX_ERROP_RE_PARTIAL = 0x1,
+	CQ_RX_ERROP_RE_JABBER = 0x2,
+	CQ_RX_ERROP_RE_FCS = 0x7,
+	CQ_RX_ERROP_RE_TERMINATE = 0x9,
+	CQ_RX_ERROP_RE_RX_CTL = 0xb,
+	CQ_RX_ERROP_PREL2_ERR = 0x1f,
+	CQ_RX_ERROP_L2_FRAGMENT = 0x20,
+	CQ_RX_ERROP_L2_OVERRUN = 0x21,
+	CQ_RX_ERROP_L2_PFCS = 0x22,
+	CQ_RX_ERROP_L2_PUNY = 0x23,
+	CQ_RX_ERROP_L2_MAL = 0x24,
+	CQ_RX_ERROP_L2_OVERSIZE = 0x25,
+	CQ_RX_ERROP_L2_UNDERSIZE = 0x26,
+	CQ_RX_ERROP_L2_LENMISM = 0x27,
+	CQ_RX_ERROP_L2_PCLP = 0x28,
+	CQ_RX_ERROP_IP_NOT = 0x41,
+	CQ_RX_ERROP_IP_CSUM_ERR = 0x42,
+	CQ_RX_ERROP_IP_MAL = 0x43,
+	CQ_RX_ERROP_IP_MALD = 0x44,
+	CQ_RX_ERROP_IP_HOP = 0x45,
+	CQ_RX_ERROP_L3_ICRC = 0x46,
+	CQ_RX_ERROP_L3_PCLP = 0x47,
+	CQ_RX_ERROP_L4_MAL = 0x61,
+	CQ_RX_ERROP_L4_CHK = 0x62,
+	CQ_RX_ERROP_UDP_LEN = 0x63,
+	CQ_RX_ERROP_L4_PORT = 0x64,
+	CQ_RX_ERROP_TCP_FLAG = 0x65,
+	CQ_RX_ERROP_TCP_OFFSET = 0x66,
+	CQ_RX_ERROP_L4_PCLP = 0x67,
+	CQ_RX_ERROP_RBDR_TRUNC = 0x70,
+};
+
+enum CQ_TX_ERROP_E {
+	CQ_TX_ERROP_GOOD = 0x0,
+	CQ_TX_ERROP_DESC_FAULT = 0x10,
+	CQ_TX_ERROP_HDR_CONS_ERR = 0x11,
+	CQ_TX_ERROP_SUBDC_ERR = 0x12,
+	CQ_TX_ERROP_IMM_SIZE_OFLOW = 0x80,
+	CQ_TX_ERROP_DATA_SEQUENCE_ERR = 0x81,
+	CQ_TX_ERROP_MEM_SEQUENCE_ERR = 0x82,
+	CQ_TX_ERROP_LOCK_VIOL = 0x83,
+	CQ_TX_ERROP_DATA_FAULT = 0x84,
+	CQ_TX_ERROP_TSTMP_CONFLICT = 0x85,
+	CQ_TX_ERROP_TSTMP_TIMEOUT = 0x86,
+	CQ_TX_ERROP_MEM_FAULT = 0x87,
+	CQ_TX_ERROP_CK_OVERLAP = 0x88,
+	CQ_TX_ERROP_CK_OFLOW = 0x89,
+	CQ_TX_ERROP_ENUM_LAST = 0x8a,
+};
+
+struct cmp_queue_stats {
+	struct rx_stats {
+		struct {
+			u64 mac_errs;
+			u64 l2_errs;
+			u64 l3_errs;
+			u64 l4_errs;
+		} errlvl;
+		struct {
+			u64 good;
+			u64 partial_pkts;
+			u64 jabber_errs;
+			u64 fcs_errs;
+			u64 terminate_errs;
+			u64 bgx_rx_errs;
+			u64 prel2_errs;
+			u64 l2_frags;
+			u64 l2_overruns;
+			u64 l2_pfcs;
+			u64 l2_puny;
+			u64 l2_hdr_malformed;
+			u64 l2_oversize;
+			u64 l2_undersize;
+			u64 l2_len_mismatch;
+			u64 l2_pclp;
+			u64 non_ip;
+			u64 ip_csum_err;
+			u64 ip_hdr_malformed;
+			u64 ip_payload_malformed;
+			u64 ip_hop_errs;
+			u64 l3_icrc_errs;
+			u64 l3_pclp;
+			u64 l4_malformed;
+			u64 l4_csum_errs;
+			u64 udp_len_err;
+			u64 bad_l4_port;
+			u64 bad_tcp_flag;
+			u64 tcp_offset_errs;
+			u64 l4_pclp;
+			u64 pkt_truncated;
+		} errop;
+	} rx;
+	struct tx_stats {
+		u64 good;
+		u64 desc_fault;
+		u64 hdr_cons_err;
+		u64 subdesc_err;
+		u64 imm_size_oflow;
+		u64 data_seq_err;
+		u64 mem_seq_err;
+		u64 lock_viol;
+		u64 data_fault;
+		u64 tstmp_conflict;
+		u64 tstmp_timeout;
+		u64 mem_fault;
+		u64 csum_overlap;
+		u64 csum_overflow;
+	} tx;
+};
+
+enum RQ_SQ_STATS {
+	RQ_SQ_STATS_OCTS,
+	RQ_SQ_STATS_PKTS,
+};
+
+struct rx_tx_queue_stats {
+	u64	bytes;
+	u64	pkts;
+};
+
+struct q_desc_mem {
+	dma_addr_t	dma;
+	uint64_t	size;
+	uint16_t	q_len;
+	dma_addr_t	phys_base;
+	void		*base;
+	void		*unalign_base;
+};
+
+struct rbdr {
+	bool		enable;
+	uint32_t	buf_size;
+	uint32_t	thresh;      /* Threshold level for interrupt */
+	void		*desc;
+	struct q_desc_mem   dmem;
+};
+
+struct rcv_queue {
+	bool		enable;
+	struct	rbdr	*rbdr_start;
+	struct	rbdr	*rbdr_cont;
+	bool		en_tcp_reassembly;
+	uint8_t		cq_qs;  /* CQ's QS to which this RQ is assigned */
+	uint8_t		cq_idx; /* CQ index (0 to 7) in the QS */
+	uint8_t		cont_rbdr_qs;      /* Continue buffer ptrs - QS num */
+	uint8_t		cont_qs_rbdr_idx;  /* RBDR idx in the cont QS */
+	uint8_t		start_rbdr_qs;     /* First buffer ptrs - QS num */
+	uint8_t		start_qs_rbdr_idx; /* RBDR idx in the above QS */
+	uint8_t         caching;
+	struct		rx_tx_queue_stats stats;
+};
+
+struct cmp_queue {
+	bool		enable;
+	uint8_t		intr_timer_thresh;
+	uint16_t	thresh;
+	spinlock_t	cq_lock;  /* lock to serialize processing CQEs */
+	void		*desc;
+	struct q_desc_mem   dmem;
+	struct cmp_queue_stats	stats;
+};
+
+struct snd_queue {
+	bool		enable;
+	uint8_t		cq_qs;  /* CQ's QS to which this SQ is pointing */
+	uint8_t		cq_idx; /* CQ index (0 to 7) in the above QS */
+	uint16_t	thresh;
+	uint16_t	free_cnt;
+	uint64_t	head;
+	uint64_t	tail;
+	uint64_t	*skbuff;
+	void		*desc;
+	struct q_desc_mem   dmem;
+	struct rx_tx_queue_stats stats;
+};
+
+struct queue_set {
+	bool		enable;
+	bool		be_en;
+	uint8_t		vnic_id;
+	uint8_t		rq_cnt;
+	uint8_t		cq_cnt;
+	uint64_t	cq_len;
+	uint8_t		sq_cnt;
+	uint64_t	sq_len;
+	uint8_t		rbdr_cnt;
+	uint64_t	rbdr_len;
+	struct	rcv_queue	rq[MAX_RCV_QUEUES_PER_QS];
+	struct	cmp_queue	cq[MAX_CMP_QUEUES_PER_QS];
+	struct	snd_queue	sq[MAX_SND_QUEUES_PER_QS];
+	struct	rbdr		rbdr[MAX_RCV_BUF_DESC_RINGS_PER_QS];
+};
+
+#define GET_RBDR_DESC(RING, idx)\
+		(&(((struct rbdr_entry_t *)((RING)->desc))[idx]))
+#define GET_SQ_DESC(RING, idx)\
+		(&(((struct sq_hdr_subdesc *)((RING)->desc))[idx]))
+#define GET_CQ_DESC(RING, idx)\
+		(&(((union cq_desc_t *)((RING)->desc))[idx]))
+
+/* CQ status bits */
+#define	CQ_WR_FULL	(1 << 26)
+#define	CQ_WR_DISABLE	(1 << 25)
+#define	CQ_WR_FAULT	(1 << 24)
+#define	CQ_CQE_COUNT	(0xFFFF << 0)
+
+#define	CQ_ERR_MASK	(CQ_WR_FULL | CQ_WR_DISABLE | CQ_WR_FAULT)
+
+int nicvf_set_qset_resources(struct nicvf *nic);
+int nicvf_config_data_transfer(struct nicvf *nic, bool enable);
+void nicvf_qset_config(struct nicvf *nic, bool enable);
+void nicvf_cmp_queue_config(struct nicvf *nic, struct queue_set *qs,
+			    int qidx, bool enable);
+
+void nicvf_sq_enable(struct nicvf *nic, struct snd_queue *sq, int qidx);
+void nicvf_sq_disable(struct nicvf *nic, int qidx);
+void nicvf_put_sq_desc(struct snd_queue *sq, int desc_cnt);
+void nicvf_sq_free_used_descs(struct net_device *netdev,
+			      struct snd_queue *sq, int qidx);
+int nicvf_sq_append_skb(struct nicvf *nic, struct sk_buff *skb);
+
+struct sk_buff *nicvf_get_rcv_skb(struct nicvf *nic, void *cq_desc);
+void nicvf_refill_rbdr(unsigned long data);
+
+void nicvf_enable_intr(struct nicvf *nic, int int_type, int q_idx);
+void nicvf_disable_intr(struct nicvf *nic, int int_type, int q_idx);
+void nicvf_clear_intr(struct nicvf *nic, int int_type, int q_idx);
+int nicvf_is_intr_enabled(struct nicvf *nic, int int_type, int q_idx);
+
+/* Register access APIs */
+void nicvf_reg_write(struct nicvf *nic, uint64_t offset, uint64_t val);
+uint64_t nicvf_reg_read(struct nicvf *nic, uint64_t offset);
+void nicvf_qset_reg_write(struct nicvf *nic, uint64_t offset, uint64_t val);
+uint64_t nicvf_qset_reg_read(struct nicvf *nic, uint64_t offset);
+void nicvf_queue_reg_write(struct nicvf *nic, uint64_t offset,
+			   uint64_t qidx, uint64_t val);
+uint64_t nicvf_queue_reg_read(struct nicvf *nic,
+			      uint64_t offset, uint64_t qidx);
+
+/* Stats */
+void nicvf_update_rq_stats(struct nicvf *nic, int rq_idx);
+void nicvf_update_sq_stats(struct nicvf *nic, int sq_idx);
+int nicvf_check_cqe_rx_errs(struct nicvf *nic,
+			    struct cmp_queue *cq, void *cq_desc);
+int nicvf_check_cqe_tx_errs(struct nicvf *nic,
+			    struct cmp_queue *cq, void *cq_desc);
+#endif /* NICVF_QUEUES_H */
diff --git a/drivers/net/ethernet/cavium/thunder/q_struct.h b/drivers/net/ethernet/cavium/thunder/q_struct.h
new file mode 100644
index 000000000000..729276bd800a
--- /dev/null
+++ b/drivers/net/ethernet/cavium/thunder/q_struct.h
@@ -0,0 +1,702 @@
+/*
+ * This file contains HW queue descriptor formats, config register
+ * structures e.t.c
+ *
+ * Copyright (C) 2014 Cavium, Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of
+ * the License, or (at your option) any later version.
+ */
+
+#ifndef Q_STRUCT_H
+#define Q_STRUCT_H
+
+/* Load transaction types for reading segment bytes specified by
+ * NIC_SEND_GATHER_S[LD_TYPE].
+ */
+enum nic_send_ld_type_e {
+	NIC_SEND_LD_TYPE_E_LDD = 0x0,
+	NIC_SEND_LD_TYPE_E_LDT = 0x1,
+	NIC_SEND_LD_TYPE_E_LDWB = 0x2,
+	NIC_SEND_LD_TYPE_E_ENUM_LAST = 0x3,
+};
+
+enum ether_type_algorithm {
+	ETYPE_ALG_NONE = 0x0,
+	ETYPE_ALG_SKIP = 0x1,
+	ETYPE_ALG_ENDPARSE = 0x2,
+	ETYPE_ALG_VLAN = 0x3,
+	ETYPE_ALG_VLAN_STRIP = 0x4,
+};
+
+enum layer3_type {
+	L3TYPE_NONE = 0x00,
+	L3TYPE_GRH = 0x01,
+	L3TYPE_IPV4 = 0x04,
+	L3TYPE_IPV4_OPTIONS = 0x05,
+	L3TYPE_IPV6 = 0x06,
+	L3TYPE_IPV6_OPTIONS = 0x07,
+	L3TYPE_ET_STOP = 0x0D,
+	L3TYPE_OTHER = 0x0E,
+};
+
+enum layer4_type {
+	L4TYPE_NONE = 0x00,
+	L4TYPE_IPSEC_ESP = 0x01,
+	L4TYPE_IPFRAG = 0x02,
+	L4TYPE_IPCOMP = 0x03,
+	L4TYPE_TCP = 0x04,
+	L4TYPE_UDP = 0x05,
+	L4TYPE_SCTP = 0x06,
+	L4TYPE_GRE = 0x07,
+	L4TYPE_ROCE_BTH = 0x08,
+	L4TYPE_OTHER = 0x0E,
+};
+
+/* CPI and RSSI configuration */
+enum cpi_algorithm_type {
+	CPI_ALG_NONE = 0x0,
+	CPI_ALG_VLAN = 0x1,
+	CPI_ALG_VLAN16 = 0x2,
+	CPI_ALG_DIFF = 0x3,
+};
+
+enum rss_algorithm_type {
+	RSS_ALG_NONE = 0x00,
+	RSS_ALG_PORT = 0x01,
+	RSS_ALG_IP = 0x02,
+	RSS_ALG_TCP_IP = 0x03,
+	RSS_ALG_UDP_IP = 0x04,
+	RSS_ALG_SCTP_IP = 0x05,
+	RSS_ALG_GRE_IP = 0x06,
+	RSS_ALG_ROCE = 0x07,
+};
+
+enum rss_hash_cfg {
+	RSS_HASH_L2ETC = 0x00,
+	RSS_HASH_IP = 0x01,
+	RSS_HASH_TCP = 0x02,
+	RSS_TCP_SYN_DIS = 0x03,
+	RSS_HASH_UDP = 0x04,
+	RSS_HASH_L4ETC = 0x05,
+	RSS_HASH_ROCE = 0x06,
+	RSS_L3_BIDI = 0x07,
+	RSS_L4_BIDI = 0x08,
+};
+
+/* Completion queue entry types */
+enum cqe_type {
+	CQE_TYPE_INVALID = 0x0,
+	CQE_TYPE_RX = 0x2,
+	CQE_TYPE_RX_SPLIT = 0x3,
+	CQE_TYPE_RX_TCP = 0x4,
+	CQE_TYPE_SEND = 0x8,
+	CQE_TYPE_SEND_PTP = 0x9,
+};
+
+enum cqe_rx_tcp_status {
+	CQE_RX_STATUS_VALID_TCP_CNXT = 0x00,
+	CQE_RX_STATUS_INVALID_TCP_CNXT = 0x0F,
+};
+
+enum cqe_send_status {
+	CQE_SEND_STATUS_GOOD = 0x00,
+	CQE_SEND_STATUS_DESC_FAULT = 0x01,
+	CQE_SEND_STATUS_HDR_CONS_ERR = 0x11,
+	CQE_SEND_STATUS_SUBDESC_ERR = 0x12,
+	CQE_SEND_STATUS_IMM_SIZE_OFLOW = 0x80,
+	CQE_SEND_STATUS_CRC_SEQ_ERR = 0x81,
+	CQE_SEND_STATUS_DATA_SEQ_ERR = 0x82,
+	CQE_SEND_STATUS_MEM_SEQ_ERR = 0x83,
+	CQE_SEND_STATUS_LOCK_VIOL = 0x84,
+	CQE_SEND_STATUS_LOCK_UFLOW = 0x85,
+	CQE_SEND_STATUS_DATA_FAULT = 0x86,
+	CQE_SEND_STATUS_TSTMP_CONFLICT = 0x87,
+	CQE_SEND_STATUS_TSTMP_TIMEOUT = 0x88,
+	CQE_SEND_STATUS_MEM_FAULT = 0x89,
+	CQE_SEND_STATUS_CSUM_OVERLAP = 0x8A,
+	CQE_SEND_STATUS_CSUM_OVERFLOW = 0x8B,
+};
+
+enum cqe_rx_tcp_end_reason {
+	CQE_RX_TCP_END_FIN_FLAG_DET = 0,
+	CQE_RX_TCP_END_INVALID_FLAG = 1,
+	CQE_RX_TCP_END_TIMEOUT = 2,
+	CQE_RX_TCP_END_OUT_OF_SEQ = 3,
+	CQE_RX_TCP_END_PKT_ERR = 4,
+	CQE_RX_TCP_END_QS_DISABLED = 0x0F,
+};
+
+/* Packet protocol level error enumeration */
+enum cqe_rx_err_level {
+	CQE_RX_ERRLVL_RE = 0x0,
+	CQE_RX_ERRLVL_L2 = 0x1,
+	CQE_RX_ERRLVL_L3 = 0x2,
+	CQE_RX_ERRLVL_L4 = 0x3,
+};
+
+/* Packet protocol level error type enumeration */
+enum cqe_rx_err_opcode {
+	CQE_RX_ERR_RE_NONE = 0x0,
+	CQE_RX_ERR_RE_PARTIAL = 0x1,
+	CQE_RX_ERR_RE_JABBER = 0x2,
+	CQE_RX_ERR_RE_FCS = 0x7,
+	CQE_RX_ERR_RE_TERMINATE = 0x9,
+	CQE_RX_ERR_RE_RX_CTL = 0xb,
+	CQE_RX_ERR_PREL2_ERR = 0x1f,
+	CQE_RX_ERR_L2_FRAGMENT = 0x20,
+	CQE_RX_ERR_L2_OVERRUN = 0x21,
+	CQE_RX_ERR_L2_PFCS = 0x22,
+	CQE_RX_ERR_L2_PUNY = 0x23,
+	CQE_RX_ERR_L2_MAL = 0x24,
+	CQE_RX_ERR_L2_OVERSIZE = 0x25,
+	CQE_RX_ERR_L2_UNDERSIZE = 0x26,
+	CQE_RX_ERR_L2_LENMISM = 0x27,
+	CQE_RX_ERR_L2_PCLP = 0x28,
+	CQE_RX_ERR_IP_NOT = 0x41,
+	CQE_RX_ERR_IP_CHK = 0x42,
+	CQE_RX_ERR_IP_MAL = 0x43,
+	CQE_RX_ERR_IP_MALD = 0x44,
+	CQE_RX_ERR_IP_HOP = 0x45,
+	CQE_RX_ERR_L3_ICRC = 0x46,
+	CQE_RX_ERR_L3_PCLP = 0x47,
+	CQE_RX_ERR_L4_MAL = 0x61,
+	CQE_RX_ERR_L4_CHK = 0x62,
+	CQE_RX_ERR_UDP_LEN = 0x63,
+	CQE_RX_ERR_L4_PORT = 0x64,
+	CQE_RX_ERR_TCP_FLAG = 0x65,
+	CQE_RX_ERR_TCP_OFFSET = 0x66,
+	CQE_RX_ERR_L4_PCLP = 0x67,
+	CQE_RX_ERR_RBDR_TRUNC = 0x70,
+};
+
+struct cqe_rx_t {
+#if defined(__BIG_ENDIAN_BITFIELD)
+	uint64_t   cqe_type:4; /* W0 */
+	uint64_t   stdn_fault:1;
+	uint64_t   rsvd0:1;
+	uint64_t   rq_qs:7;
+	uint64_t   rq_idx:3;
+	uint64_t   rsvd1:12;
+	uint64_t   rss_alg:4;
+	uint64_t   rsvd2:4;
+	uint64_t   rb_cnt:4;
+	uint64_t   vlan_found:1;
+	uint64_t   vlan_stripped:1;
+	uint64_t   vlan2_found:1;
+	uint64_t   vlan2_stripped:1;
+	uint64_t   l4_type:4;
+	uint64_t   l3_type:4;
+	uint64_t   l2_present:1;
+	uint64_t   err_level:3;
+	uint64_t   err_opcode:8;
+
+	uint64_t   pkt_len:16; /* W1 */
+	uint64_t   l2_ptr:8;
+	uint64_t   l3_ptr:8;
+	uint64_t   l4_ptr:8;
+	uint64_t   cq_pkt_len:8;
+	uint64_t   align_pad:3;
+	uint64_t   rsvd3:1;
+	uint64_t   chan:12;
+
+	uint64_t   rss_tag:32; /* W2 */
+	uint64_t   vlan_tci:16;
+	uint64_t   vlan_ptr:8;
+	uint64_t   vlan2_ptr:8;
+
+	uint64_t   rb3_sz:16; /* W3 */
+	uint64_t   rb2_sz:16;
+	uint64_t   rb1_sz:16;
+	uint64_t   rb0_sz:16;
+
+	uint64_t   rb7_sz:16; /* W4 */
+	uint64_t   rb6_sz:16;
+	uint64_t   rb5_sz:16;
+	uint64_t   rb4_sz:16;
+
+	uint64_t   rb11_sz:16; /* W5 */
+	uint64_t   rb10_sz:16;
+	uint64_t   rb9_sz:16;
+	uint64_t   rb8_sz:16;
+#elif defined(__LITTLE_ENDIAN_BITFIELD)
+	uint64_t   err_opcode:8;
+	uint64_t   err_level:3;
+	uint64_t   l2_present:1;
+	uint64_t   l3_type:4;
+	uint64_t   l4_type:4;
+	uint64_t   vlan2_stripped:1;
+	uint64_t   vlan2_found:1;
+	uint64_t   vlan_stripped:1;
+	uint64_t   vlan_found:1;
+	uint64_t   rb_cnt:4;
+	uint64_t   rsvd2:4;
+	uint64_t   rss_alg:4;
+	uint64_t   rsvd1:12;
+	uint64_t   rq_idx:3;
+	uint64_t   rq_qs:7;
+	uint64_t   rsvd0:1;
+	uint64_t   stdn_fault:1;
+	uint64_t   cqe_type:4; /* W0 */
+	uint64_t   chan:12;
+	uint64_t   rsvd3:1;
+	uint64_t   align_pad:3;
+	uint64_t   cq_pkt_len:8;
+	uint64_t   l4_ptr:8;
+	uint64_t   l3_ptr:8;
+	uint64_t   l2_ptr:8;
+	uint64_t   pkt_len:16; /* W1 */
+	uint64_t   vlan2_ptr:8;
+	uint64_t   vlan_ptr:8;
+	uint64_t   vlan_tci:16;
+	uint64_t   rss_tag:32; /* W2 */
+	uint64_t   rb0_sz:16;
+	uint64_t   rb1_sz:16;
+	uint64_t   rb2_sz:16;
+	uint64_t   rb3_sz:16; /* W3 */
+	uint64_t   rb4_sz:16;
+	uint64_t   rb5_sz:16;
+	uint64_t   rb6_sz:16;
+	uint64_t   rb7_sz:16; /* W4 */
+	uint64_t   rb8_sz:16;
+	uint64_t   rb9_sz:16;
+	uint64_t   rb10_sz:16;
+	uint64_t   rb11_sz:16; /* W5 */
+#endif
+	uint64_t   rb0_ptr:64;
+	uint64_t   rb1_ptr:64;
+	uint64_t   rb2_ptr:64;
+	uint64_t   rb3_ptr:64;
+	uint64_t   rb4_ptr:64;
+	uint64_t   rb5_ptr:64;
+	uint64_t   rb6_ptr:64;
+	uint64_t   rb7_ptr:64;
+	uint64_t   rb8_ptr:64;
+	uint64_t   rb9_ptr:64;
+	uint64_t   rb10_ptr:64;
+	uint64_t   rb11_ptr:64;
+};
+
+struct cqe_rx_tcp_err_t {
+#if defined(__BIG_ENDIAN_BITFIELD)
+	uint64_t   cqe_type:4; /* W0 */
+	uint64_t   rsvd0:60;
+
+	uint64_t   rsvd1:4; /* W1 */
+	uint64_t   partial_first:1;
+	uint64_t   rsvd2:27;
+	uint64_t   rbdr_bytes:8;
+	uint64_t   rsvd3:24;
+#elif defined(__LITTLE_ENDIAN_BITFIELD)
+	uint64_t   rsvd0:60;
+	uint64_t   cqe_type:4;
+
+	uint64_t   rsvd3:24;
+	uint64_t   rbdr_bytes:8;
+	uint64_t   rsvd2:27;
+	uint64_t   partial_first:1;
+	uint64_t   rsvd1:4;
+#endif
+};
+
+struct cqe_rx_tcp_t {
+#if defined(__BIG_ENDIAN_BITFIELD)
+	uint64_t   cqe_type:4; /* W0 */
+	uint64_t   rsvd0:52;
+	uint64_t   cq_tcp_status:8;
+
+	uint64_t   rsvd1:32; /* W1 */
+	uint64_t   tcp_cntx_bytes:8;
+	uint64_t   rsvd2:8;
+	uint64_t   tcp_err_bytes:16;
+#elif defined(__LITTLE_ENDIAN_BITFIELD)
+	uint64_t   cq_tcp_status:8;
+	uint64_t   rsvd0:52;
+	uint64_t   cqe_type:4; /* W0 */
+
+	uint64_t   tcp_err_bytes:16;
+	uint64_t   rsvd2:8;
+	uint64_t   tcp_cntx_bytes:8;
+	uint64_t   rsvd1:32; /* W1 */
+#endif
+};
+
+struct cqe_send_t {
+#if defined(__BIG_ENDIAN_BITFIELD)
+	uint64_t   cqe_type:4; /* W0 */
+	uint64_t   rsvd0:4;
+	uint64_t   sqe_ptr:16;
+	uint64_t   rsvd1:4;
+	uint64_t   rsvd2:10;
+	uint64_t   sq_qs:7;
+	uint64_t   sq_idx:3;
+	uint64_t   rsvd3:8;
+	uint64_t   send_status:8;
+
+	uint64_t   ptp_timestamp:64; /* W1 */
+#elif defined(__LITTLE_ENDIAN_BITFIELD)
+	uint64_t   send_status:8;
+	uint64_t   rsvd3:8;
+	uint64_t   sq_idx:3;
+	uint64_t   sq_qs:7;
+	uint64_t   rsvd2:10;
+	uint64_t   rsvd1:4;
+	uint64_t   sqe_ptr:16;
+	uint64_t   rsvd0:4;
+	uint64_t   cqe_type:4; /* W0 */
+
+	uint64_t   ptp_timestamp:64; /* W1 */
+#endif
+};
+
+union cq_desc_t {
+	uint64_t u[64];
+	struct cqe_send_t snd_hdr;
+	struct cqe_rx_t rx_hdr;
+	struct cqe_rx_tcp_t rx_tcp_hdr;
+	struct cqe_rx_tcp_err_t rx_tcp_err_hdr;
+};
+
+struct rbdr_entry_t {
+#if defined(__BIG_ENDIAN_BITFIELD)
+	uint64_t   rsvd0:15;
+	uint64_t   buf_addr:42;
+	uint64_t   cache_align:7;
+#elif defined(__LITTLE_ENDIAN_BITFIELD)
+	uint64_t   cache_align:7;
+	uint64_t   buf_addr:42;
+	uint64_t   rsvd0:15;
+#endif
+};
+
+/* TCP reassembly context */
+struct rbe_tcp_cnxt_t {
+#if defined(__BIG_ENDIAN_BITFIELD)
+	uint64_t   tcp_pkt_cnt:12;
+	uint64_t   rsvd1:4;
+	uint64_t   align_hdr_bytes:4;
+	uint64_t   align_ptr_bytes:4;
+	uint64_t   ptr_bytes:16;
+	uint64_t   rsvd2:24;
+	uint64_t   cqe_type:4;
+	uint64_t   rsvd0:54;
+	uint64_t   tcp_end_reason:2;
+	uint64_t   tcp_status:4;
+#elif defined(__LITTLE_ENDIAN_BITFIELD)
+	uint64_t   tcp_status:4;
+	uint64_t   tcp_end_reason:2;
+	uint64_t   rsvd0:54;
+	uint64_t   cqe_type:4;
+	uint64_t   rsvd2:24;
+	uint64_t   ptr_bytes:16;
+	uint64_t   align_ptr_bytes:4;
+	uint64_t   align_hdr_bytes:4;
+	uint64_t   rsvd1:4;
+	uint64_t   tcp_pkt_cnt:12;
+#endif
+};
+
+/* Always Big endian */
+struct rx_hdr_t {
+	uint64_t   opaque:32;
+	uint64_t   rss_flow:8;
+	uint64_t   skip_length:6;
+	uint64_t   disable_rss:1;
+	uint64_t   disable_tcp_reassembly:1;
+	uint64_t   nodrop:1;
+	uint64_t   dest_alg:2;
+	uint64_t   rsvd0:2;
+	uint64_t   dest_rq:11;
+};
+
+enum send_l4_csum_type {
+	SEND_L4_CSUM_DISABLE = 0x00,
+	SEND_L4_CSUM_UDP = 0x01,
+	SEND_L4_CSUM_TCP = 0x02,
+	SEND_L4_CSUM_SCTP = 0x03,
+};
+
+enum send_crc_alg {
+	SEND_CRCALG_CRC32 = 0x00,
+	SEND_CRCALG_CRC32C = 0x01,
+	SEND_CRCALG_ICRC = 0x02,
+};
+
+enum send_load_type {
+	SEND_LD_TYPE_LDD = 0x00,
+	SEND_LD_TYPE_LDT = 0x01,
+	SEND_LD_TYPE_LDWB = 0x02,
+};
+
+enum send_mem_alg_type {
+	SEND_MEMALG_SET = 0x00,
+	SEND_MEMALG_ADD = 0x08,
+	SEND_MEMALG_SUB = 0x09,
+	SEND_MEMALG_ADDLEN = 0x0A,
+	SEND_MEMALG_SUBLEN = 0x0B,
+};
+
+enum send_mem_dsz_type {
+	SEND_MEMDSZ_B64 = 0x00,
+	SEND_MEMDSZ_B32 = 0x01,
+	SEND_MEMDSZ_B8 = 0x03,
+};
+
+enum sq_subdesc_type {
+	SQ_DESC_TYPE_INVALID = 0x00,
+	SQ_DESC_TYPE_HEADER = 0x01,
+	SQ_DESC_TYPE_CRC = 0x02,
+	SQ_DESC_TYPE_IMMEDIATE = 0x03,
+	SQ_DESC_TYPE_GATHER = 0x04,
+	SQ_DESC_TYPE_MEMORY = 0x05,
+};
+
+struct sq_crc_subdesc {
+#if defined(__BIG_ENDIAN_BITFIELD)
+	uint64_t    rsvd1:32;
+	uint64_t    crc_ival:32;
+	uint64_t    subdesc_type:4;
+	uint64_t    crc_alg:2;
+	uint64_t    rsvd0:10;
+	uint64_t    crc_insert_pos:16;
+	uint64_t    hdr_start:16;
+	uint64_t    crc_len:16;
+#elif defined(__LITTLE_ENDIAN_BITFIELD)
+	uint64_t    crc_len:16;
+	uint64_t    hdr_start:16;
+	uint64_t    crc_insert_pos:16;
+	uint64_t    rsvd0:10;
+	uint64_t    crc_alg:2;
+	uint64_t    subdesc_type:4;
+	uint64_t    crc_ival:32;
+	uint64_t    rsvd1:32;
+#endif
+};
+
+struct sq_gather_subdesc {
+#if defined(__BIG_ENDIAN_BITFIELD)
+	uint64_t    subdesc_type:4; /* W0 */
+	uint64_t    ld_type:2;
+	uint64_t    rsvd0:42;
+	uint64_t    size:16;
+
+	uint64_t    rsvd1:15; /* W1 */
+	uint64_t    addr:49;
+#elif defined(__LITTLE_ENDIAN_BITFIELD)
+	uint64_t    size:16;
+	uint64_t    rsvd0:42;
+	uint64_t    ld_type:2;
+	uint64_t    subdesc_type:4; /* W0 */
+
+	uint64_t    addr:49;
+	uint64_t    rsvd1:15; /* W1 */
+#endif
+};
+
+/* SQ immediate subdescriptor */
+struct sq_imm_subdesc {
+#if defined(__BIG_ENDIAN_BITFIELD)
+	uint64_t    subdesc_type:4; /* W0 */
+	uint64_t    rsvd0:46;
+	uint64_t    len:14;
+
+	uint64_t    data:64; /* W1 */
+#elif defined(__LITTLE_ENDIAN_BITFIELD)
+	uint64_t    len:14;
+	uint64_t    rsvd0:46;
+	uint64_t    subdesc_type:4; /* W0 */
+
+	uint64_t    data:64; /* W1 */
+#endif
+};
+
+struct sq_mem_subdesc {
+#if defined(__BIG_ENDIAN_BITFIELD)
+	uint64_t    subdesc_type:4; /* W0 */
+	uint64_t    mem_alg:4;
+	uint64_t    mem_dsz:2;
+	uint64_t    wmem:1;
+	uint64_t    rsvd0:21;
+	uint64_t    offset:32;
+
+	uint64_t    rsvd1:15; /* W1 */
+	uint64_t    addr:49;
+#elif defined(__LITTLE_ENDIAN_BITFIELD)
+	uint64_t    offset:32;
+	uint64_t    rsvd0:21;
+	uint64_t    wmem:1;
+	uint64_t    mem_dsz:2;
+	uint64_t    mem_alg:4;
+	uint64_t    subdesc_type:4; /* W0 */
+
+	uint64_t    addr:49;
+	uint64_t    rsvd1:15; /* W1 */
+#endif
+};
+
+struct sq_hdr_subdesc {
+#if defined(__BIG_ENDIAN_BITFIELD)
+	uint64_t    subdesc_type:4;
+	uint64_t    tso:1;
+	uint64_t    post_cqe:1; /* Post CQE on no error also */
+	uint64_t    dont_send:1;
+	uint64_t    tstmp:1;
+	uint64_t    subdesc_cnt:8;
+	uint64_t    csum_l4:2;
+	uint64_t    csum_l3:1;
+	uint64_t    rsvd0:5;
+	uint64_t    l4_offset:8;
+	uint64_t    l3_offset:8;
+	uint64_t    rsvd1:4;
+	uint64_t    tot_len:20; /* W0 */
+
+	uint64_t    tso_sdc_cont:8;
+	uint64_t    tso_sdc_first:8;
+	uint64_t    tso_l4_offset:8;
+	uint64_t    tso_flags_last:12;
+	uint64_t    tso_flags_first:12;
+	uint64_t    rsvd2:2;
+	uint64_t    tso_max_paysize:14; /* W1 */
+#elif defined(__LITTLE_ENDIAN_BITFIELD)
+	uint64_t    tot_len:20;
+	uint64_t    rsvd1:4;
+	uint64_t    l3_offset:8;
+	uint64_t    l4_offset:8;
+	uint64_t    rsvd0:5;
+	uint64_t    csum_l3:1;
+	uint64_t    csum_l4:2;
+	uint64_t    subdesc_cnt:8;
+	uint64_t    tstmp:1;
+	uint64_t    dont_send:1;
+	uint64_t    post_cqe:1; /* Post CQE on no error also */
+	uint64_t    tso:1;
+	uint64_t    subdesc_type:4; /* W0 */
+
+	uint64_t    tso_max_paysize:14;
+	uint64_t    rsvd2:2;
+	uint64_t    tso_flags_first:12;
+	uint64_t    tso_flags_last:12;
+	uint64_t    tso_l4_offset:8;
+	uint64_t    tso_sdc_first:8;
+	uint64_t    tso_sdc_cont:8; /* W1 */
+#endif
+};
+
+/* Queue config register formats */
+struct rq_cfg {
+#if defined(__BIG_ENDIAN_BITFIELD)
+	uint64_t reserved_2_63:62;
+	uint64_t ena:1;
+	uint64_t tcp_ena:1;
+#elif defined(__LITTLE_ENDIAN_BITFIELD)
+	uint64_t tcp_ena:1;
+	uint64_t ena:1;
+	uint64_t reserved_2_63:62;
+#endif
+};
+
+struct cq_cfg {
+#if defined(__BIG_ENDIAN_BITFIELD)
+	uint64_t reserved_43_63:21;
+	uint64_t ena:1;
+	uint64_t reset:1;
+	uint64_t caching:1;
+	uint64_t reserved_35_39:5;
+	uint64_t qsize:3;
+	uint64_t reserved_25_31:7;
+	uint64_t avg_con:9;
+	uint64_t reserved_0_15:16;
+#elif defined(__LITTLE_ENDIAN_BITFIELD)
+	uint64_t reserved_0_15:16;
+	uint64_t avg_con:9;
+	uint64_t reserved_25_31:7;
+	uint64_t qsize:3;
+	uint64_t reserved_35_39:5;
+	uint64_t caching:1;
+	uint64_t reset:1;
+	uint64_t ena:1;
+	uint64_t reserved_43_63:21;
+#endif
+};
+
+struct sq_cfg {
+#if defined(__BIG_ENDIAN_BITFIELD)
+	uint64_t reserved_20_63:44;
+	uint64_t ena:1;
+	uint64_t reserved_18_18:1;
+	uint64_t reset:1;
+	uint64_t ldwb:1;
+	uint64_t reserved_11_15:5;
+	uint64_t qsize:3;
+	uint64_t reserved_3_7:5;
+	uint64_t tstmp_bgx_intf:3;
+#elif defined(__LITTLE_ENDIAN_BITFIELD)
+	uint64_t tstmp_bgx_intf:3;
+	uint64_t reserved_3_7:5;
+	uint64_t qsize:3;
+	uint64_t reserved_11_15:5;
+	uint64_t ldwb:1;
+	uint64_t reset:1;
+	uint64_t reserved_18_18:1;
+	uint64_t ena:1;
+	uint64_t reserved_20_63:44;
+#endif
+};
+
+struct rbdr_cfg {
+#if defined(__BIG_ENDIAN_BITFIELD)
+	uint64_t reserved_45_63:19;
+	uint64_t ena:1;
+	uint64_t reset:1;
+	uint64_t ldwb:1;
+	uint64_t reserved_36_41:6;
+	uint64_t qsize:4;
+	uint64_t reserved_25_31:7;
+	uint64_t avg_con:9;
+	uint64_t reserved_12_15:4;
+	uint64_t lines:12;
+#elif defined(__LITTLE_ENDIAN_BITFIELD)
+	uint64_t lines:12;
+	uint64_t reserved_12_15:4;
+	uint64_t avg_con:9;
+	uint64_t reserved_25_31:7;
+	uint64_t qsize:4;
+	uint64_t reserved_36_41:6;
+	uint64_t ldwb:1;
+	uint64_t reset:1;
+	uint64_t ena: 1;
+	uint64_t reserved_45_63:19;
+#endif
+};
+
+struct qs_cfg {
+#if defined(__BIG_ENDIAN_BITFIELD)
+	uint64_t reserved_32_63:32;
+	uint64_t ena:1;
+	uint64_t reserved_27_30:4;
+	uint64_t sq_ins_ena:1;
+	uint64_t sq_ins_pos:6;
+	uint64_t lock_ena:1;
+	uint64_t lock_viol_cqe_ena:1;
+	uint64_t send_tstmp_ena:1;
+	uint64_t be:1;
+	uint64_t reserved_7_15:9;
+	uint64_t vnic:7;
+#elif defined(__LITTLE_ENDIAN_BITFIELD)
+	uint64_t vnic:7;
+	uint64_t reserved_7_15:9;
+	uint64_t be:1;
+	uint64_t send_tstmp_ena:1;
+	uint64_t lock_viol_cqe_ena:1;
+	uint64_t lock_ena:1;
+	uint64_t sq_ins_pos:6;
+	uint64_t sq_ins_ena:1;
+	uint64_t reserved_27_30:4;
+	uint64_t ena:1;
+	uint64_t reserved_32_63:32;
+#endif
+};
+
+#endif /* Q_STRUCT_H */
diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
new file mode 100644
index 000000000000..b8886f9e0f46
--- /dev/null
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
@@ -0,0 +1,386 @@
+/*
+ * Copyright (C) 2014 Cavium, Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of
+ * the License, or (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/interrupt.h>
+#include <linux/pci.h>
+
+#include "nic_reg.h"
+#include "nic.h"
+#include "thunder_bgx.h"
+
+#define DRV_NAME	"thunder-BGX"
+#define DRV_VERSION	"1.0"
+
+struct lmac {
+	int	dmac;
+	bool	link_up;
+} lmac;
+
+struct bgx {
+	uint8_t			bgx_id;
+	struct	lmac		lmac[MAX_LMAC_PER_BGX];
+	int			lmac_count;
+	uint64_t		reg_base;
+	struct	pci_dev		*pdev;
+	 /* MSI-X */
+	bool			msix_enabled;
+	uint16_t		num_vec;
+	struct	msix_entry	msix_entries[BGX_MSIX_VECTORS];
+	char			irq_name[BGX_MSIX_VECTORS][20];
+	uint8_t			irq_allocated[BGX_MSIX_VECTORS];
+} bgx;
+
+struct bgx *bgx_vnic[MAX_BGX_THUNDER];
+
+/* Supported devices */
+static const struct pci_device_id bgx_id_table[] = {
+	{ PCI_DEVICE(PCI_VENDOR_ID_CAVIUM, PCI_DEVICE_ID_THUNDER_BGX) },
+	{ 0, }  /* end of table */
+};
+
+MODULE_AUTHOR("Cavium Inc");
+MODULE_DESCRIPTION("Cavium Thunder BGX/MAC Driver");
+MODULE_LICENSE("GPL v2");
+MODULE_VERSION(DRV_VERSION);
+MODULE_DEVICE_TABLE(pci, bgx_id_table);
+
+/* Register read/write APIs */
+static uint64_t bgx_reg_read(struct bgx *bgx, uint8_t lmac, uint64_t offset)
+{
+	uint64_t addr = bgx->reg_base + (lmac << 20) + offset;
+
+	return readq_relaxed((void *)addr);
+}
+
+static void bgx_reg_write(struct bgx *bgx, uint8_t lmac,
+			  uint64_t offset, uint64_t val)
+{
+	uint64_t addr = bgx->reg_base + (lmac << 20) + offset;
+
+	writeq_relaxed(val, (void *)addr);
+}
+
+/* Return number of BGX present in HW */
+void bgx_get_count(int node, int *bgx_count)
+{
+	int i;
+	struct bgx *bgx;
+
+	*bgx_count = 0;
+	for (i = 0; i < MAX_BGX_PER_CN88XX; i++) {
+		bgx = bgx_vnic[(node * MAX_BGX_PER_CN88XX) + i];
+		if (bgx)
+			*bgx_count |= (1 << i);
+	}
+}
+EXPORT_SYMBOL(bgx_get_count);
+
+/* Return number of LMAC configured for this BGX */
+int bgx_get_lmac_count(int node, int bgx_idx)
+{
+	struct bgx *bgx;
+
+	bgx = bgx_vnic[(node * MAX_BGX_PER_CN88XX) + bgx_idx];
+	if (bgx)
+		return bgx->lmac_count;
+
+	return 0;
+}
+EXPORT_SYMBOL(bgx_get_lmac_count);
+
+/* Link Interrupts APIs */
+static void bgx_enable_link_intr(struct bgx *bgx, uint8_t lmac)
+{
+	uint64_t val;
+
+	val = bgx_reg_read(bgx, lmac, BGX_SPUX_INT_ENA_W1S);
+	val |= (LMAC_INTR_LINK_UP | LMAC_INTR_LINK_DOWN);
+	bgx_reg_write(bgx, lmac, BGX_SPUX_INT_ENA_W1S, val);
+}
+
+static irqreturn_t bgx_lmac_intr_handler (int irq, void *bgx_irq)
+{
+	struct bgx *bgx = (struct bgx *)bgx_irq;
+	u64 result;
+	uint8_t lmac;
+
+	for (lmac = 0; lmac < bgx->lmac_count; lmac++) {
+		result = bgx_reg_read(bgx, lmac, BGX_SPUX_INT);
+		if (result & LMAC_INTR_LINK_UP) {
+			bgx_reg_write(bgx, lmac, BGX_SPUX_INT,
+				      LMAC_INTR_LINK_UP);
+			dev_info(&bgx->pdev->dev, "lmac %d link is Up\n", lmac);
+			bgx->lmac[lmac].link_up = true;
+		}
+
+		if (result & LMAC_INTR_LINK_DOWN) {
+			bgx_reg_write(bgx, lmac, BGX_SPUX_INT,
+				      LMAC_INTR_LINK_DOWN);
+			dev_info(&bgx->pdev->dev,
+				 "lmac %d link is Down\n", lmac);
+			bgx->lmac[lmac].link_up = false;
+		}
+	}
+	return IRQ_HANDLED;
+}
+
+static int bgx_enable_msix(struct bgx *bgx)
+{
+	int vec, ret;
+
+	bgx->num_vec = BGX_MSIX_VECTORS;
+	for (vec = 0; vec < bgx->num_vec; vec++)
+		bgx->msix_entries[vec].entry = vec;
+
+	ret = pci_enable_msix(bgx->pdev, bgx->msix_entries, bgx->num_vec);
+	if (ret) {
+		dev_err(&bgx->pdev->dev ,
+			"Request for #%d msix vectors failed\n", bgx->num_vec);
+		return 0;
+	}
+	bgx->msix_enabled = 1;
+	return 1;
+}
+
+static void bgx_disable_msix(struct bgx *bgx)
+{
+	if (bgx->msix_enabled) {
+		pci_disable_msix(bgx->pdev);
+		bgx->msix_enabled = 0;
+		bgx->num_vec = 0;
+	}
+}
+
+static int bgx_register_interrupts(struct bgx *bgx, uint8_t lmac)
+{
+	int irq, ret = 0;
+
+	/* Register only link interrupts now */
+	irq = SPUX_INT + (lmac * BGX_LMAC_VEC_OFFSET);
+	sprintf(bgx->irq_name[irq], "LMAC%d", lmac);
+	ret = request_irq(bgx->msix_entries[irq].vector,
+			  bgx_lmac_intr_handler, 0, bgx->irq_name[irq], bgx);
+	if (ret)
+		goto fail;
+	else
+		bgx->irq_allocated[irq] = 1;
+
+	/* Enable link interrupt */
+	bgx_enable_link_intr(bgx, lmac);
+	return 0;
+
+fail:
+	dev_err(&bgx->pdev->dev, "Request irq failed\n");
+	for (irq = 0; irq < bgx->num_vec; irq++) {
+		if (bgx->irq_allocated[irq])
+			free_irq(bgx->msix_entries[irq].vector, bgx);
+		bgx->irq_allocated[irq] = 0;
+	}
+	return 1;
+}
+
+static void bgx_unregister_interrupts(struct bgx *bgx)
+{
+	int irq;
+	/* Free registered interrupts */
+	for (irq = 0; irq < bgx->num_vec; irq++) {
+		if (bgx->irq_allocated[irq])
+			free_irq(bgx->msix_entries[irq].vector, bgx);
+		bgx->irq_allocated[irq] = 0;
+	}
+	/* Disable MSI-X */
+	bgx_disable_msix(bgx);
+}
+
+static void bgx_flush_dmac_addrs(struct bgx *bgx, uint64_t lmac)
+{
+	uint64_t dmac = 0x00;
+	uint64_t offset, addr;
+
+	while (bgx->lmac[lmac].dmac > 0) {
+		offset = ((bgx->lmac[lmac].dmac - 1) * sizeof(dmac)) +
+			(lmac * MAX_DMAC_PER_LMAC * sizeof(dmac));
+		addr = bgx->reg_base + BGX_CMR_RX_DMACX_CAM + offset;
+		writeq_relaxed(dmac, (void *)addr);
+		bgx->lmac[lmac].dmac--;
+	}
+}
+
+void bgx_add_dmac_addr(uint64_t dmac, int node, int bgx_idx, int lmac)
+{
+	uint64_t offset, addr;
+	struct bgx *bgx;
+
+	bgx_idx += node * MAX_BGX_PER_CN88XX;
+	bgx = bgx_vnic[bgx_idx];
+
+	if (!bgx) {
+		pr_err("BGX%d not yet initialized, ignoring DMAC addition\n",
+		       bgx_idx);
+		return;
+	}
+
+	dmac = dmac | (1ULL << 48) | ((uint64_t)lmac << 49); /* Enable DMAC */
+	if (bgx->lmac[lmac].dmac == MAX_DMAC_PER_LMAC) {
+		pr_err("Max DMAC filters for LMAC%d reached, ignoring DMAC addition\n",
+		       lmac);
+		return;
+	}
+
+	if (bgx->lmac[lmac].dmac == MAX_DMAC_PER_LMAC_TNS_BYPASS_MODE)
+		bgx->lmac[lmac].dmac = 1;
+
+	offset = (bgx->lmac[lmac].dmac * sizeof(dmac)) +
+		(lmac * MAX_DMAC_PER_LMAC * sizeof(dmac));
+	addr = bgx->reg_base + BGX_CMR_RX_DMACX_CAM + offset;
+	writeq_relaxed(dmac, (void *)addr);
+	bgx->lmac[lmac].dmac++;
+
+	bgx_reg_write(bgx, lmac, BGX_CMRX_RX_DMAC_CTL,
+		      (CAM_ACCEPT << 3) | (MCAST_MODE_CAM_FILTER << 1)
+		      | (BCAST_ACCEPT << 0));
+}
+EXPORT_SYMBOL(bgx_add_dmac_addr);
+
+void bgx_lmac_enable(struct bgx *bgx, int8_t lmac)
+{
+	uint64_t dmac_bcast = (1ULL << 48) - 1;
+
+	bgx_reg_write(bgx, lmac, BGX_CMRX_CFG,
+		      (1 << 15) | (1 << 14) | (1 << 13));
+
+	/* Register interrupts */
+	bgx_register_interrupts(bgx, lmac);
+
+	/* Add broadcast MAC into all LMAC's DMAC filters */
+	for (lmac = 0; lmac < bgx->lmac_count; lmac++)
+		bgx_add_dmac_addr(dmac_bcast, 0, bgx->bgx_id, lmac);
+}
+
+void bgx_lmac_disable(struct bgx *bgx, uint8_t lmac)
+{
+	bgx_reg_write(bgx, lmac, BGX_CMRX_CFG, 0x00);
+	bgx_flush_dmac_addrs(bgx, lmac);
+	bgx_unregister_interrupts(bgx);
+}
+
+static void bgx_init_hw(struct bgx *bgx)
+{
+	int lmac;
+	uint64_t enable = 0;
+
+	/* Enable all LMACs */
+	/* Enable LMAC, Pkt Rx enable, Pkt Tx enable */
+	enable = (1 << 15) | (1 << 14) | (1 << 13);
+	for (lmac = 0; lmac < MAX_LMAC_PER_BGX; lmac++) {
+		bgx_reg_write(bgx, lmac, BGX_CMRX_CFG, enable);
+		bgx->lmac_count++;
+	}
+}
+
+static int bgx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
+{
+	struct device *dev = &pdev->dev;
+	struct bgx *bgx;
+	int    err;
+	uint8_t lmac = 0;
+
+	bgx = kzalloc(sizeof(*bgx), GFP_KERNEL);
+	bgx->pdev = pdev;
+
+	pci_set_drvdata(pdev, bgx);
+
+	err = pci_enable_device(pdev);
+	if (err) {
+		dev_err(dev, "Failed to enable PCI device\n");
+		goto exit;
+	}
+
+	err = pci_request_regions(pdev, DRV_NAME);
+	if (err) {
+		dev_err(dev, "PCI request regions failed 0x%x\n", err);
+		goto err_disable_device;
+	}
+
+	/* MAP configuration registers */
+	bgx->reg_base = (uint64_t)pci_ioremap_bar(pdev, PCI_CFG_REG_BAR_NUM);
+	if (!bgx->reg_base) {
+		dev_err(dev, "BGX: Cannot map CSR memory space, aborting\n");
+		err = -ENOMEM;
+		goto err_release_regions;
+	}
+	bgx->bgx_id = (pci_resource_start(pdev, PCI_CFG_REG_BAR_NUM) >> 24) & 1;
+	bgx->bgx_id += NODE_ID(pci_resource_start(pdev, PCI_CFG_REG_BAR_NUM))
+							* MAX_BGX_PER_CN88XX;
+	bgx_vnic[bgx->bgx_id] = bgx;
+
+	/* Initialize BGX hardware */
+	bgx_init_hw(bgx);
+	/* Enable MSI-X */
+	if (!bgx_enable_msix(bgx))
+		return 1;
+	/* Enable all LMACs */
+	for (lmac = 0; lmac < bgx->lmac_count; lmac++)
+		bgx_lmac_enable(bgx, lmac);
+	goto exit;
+
+	if (bgx->reg_base)
+		iounmap((void *)bgx->reg_base);
+err_release_regions:
+	pci_release_regions(pdev);
+err_disable_device:
+	pci_disable_device(pdev);
+exit:
+	return err;
+}
+
+static void bgx_remove(struct pci_dev *pdev)
+{
+	struct bgx *bgx = pci_get_drvdata(pdev);
+	uint8_t lmac;
+
+	if (!bgx)
+		return;
+	/* Disable all LMACs */
+	for (lmac = 0; lmac < 4; lmac++)
+		bgx_lmac_disable(bgx, lmac);
+
+	pci_set_drvdata(pdev, NULL);
+
+	if (bgx->reg_base)
+		iounmap((void *)bgx->reg_base);
+
+	pci_release_regions(pdev);
+	pci_disable_device(pdev);
+	kfree(bgx);
+}
+
+static struct pci_driver bgx_driver = {
+	.name = DRV_NAME,
+	.id_table = bgx_id_table,
+	.probe = bgx_probe,
+	.remove = bgx_remove,
+};
+
+static int __init bgx_init_module(void)
+{
+	pr_info("%s, ver %s\n", DRV_NAME, DRV_VERSION);
+
+	return pci_register_driver(&bgx_driver);
+}
+
+static void __exit bgx_cleanup_module(void)
+{
+	pci_unregister_driver(&bgx_driver);
+}
+
+module_init(bgx_init_module);
+module_exit(bgx_cleanup_module);
+
diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.h b/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
new file mode 100644
index 000000000000..de6503148d25
--- /dev/null
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
@@ -0,0 +1,78 @@
+/*
+ * Copyright (C) 2014 Cavium, Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of
+ * the License, or (at your option) any later version.
+ */
+
+#ifndef THUNDER_BGX_H
+#define THUNDER_BGX_H
+
+#define    MAX_BGX_THUNDER			8 /* Max 4 nodes, 2 per node */
+#define    MAX_BGX_PER_CN88XX			2
+#define    MAX_LMAC_PER_BGX			4
+#define    MAX_BGX_CHANS_PER_LMAC		16
+#define    MAX_DMAC_PER_LMAC			8
+
+#define    MAX_DMAC_PER_LMAC_TNS_BYPASS_MODE	2
+
+#define    MAX_LMAC	(MAX_BGX_PER_CN88XX * MAX_LMAC_PER_BGX)
+
+#define    NODE_ID_MASK				0x300000000000
+#define    NODE_ID(x)				((x & NODE_ID_MASK) >> 44)
+
+/* Registers */
+#define BGX_CMRX_CFG				0x00
+#define BGX_CMRX_RX_ID_MAP			0x60
+#define BGX_CMRX_RX_DMAC_CTL			0x0E8
+#define BGX_CMR_RX_DMACX_CAM			0x200
+#define BGX_CMR_RX_LMACS			0x468
+#define BGX_CMR_TX_LMACS			0x1000
+
+#define BGX_SPUX_STATUS1			0x10008
+#define BGX_SPUX_STATUS2			0x10020
+#define BGX_SPUX_INT				0x10220	/* +(0..3) << 20 */
+#define BGX_SPUX_INT_W1S			0x10228
+#define BGX_SPUX_INT_ENA_W1C			0x10230
+#define BGX_SPUX_INT_ENA_W1S			0x10238
+
+#define BGX_MSIX_VEC_0_29_ADDR			0x400000 /* +(0..29) << 4 */
+#define BGX_MSIX_VEC_0_29_CTL			0x400008
+#define BGX_MSIX_PBA_0				0x4F0000
+
+/* MSI-X interrupts */
+#define BGX_MSIX_VECTORS	30
+#define BGX_LMAC_VEC_OFFSET	7
+#define BGX_MSIX_VEC_SHIFT	4
+
+#define CMRX_INT		0
+#define SPUX_INT		1
+#define SMUX_RX_INT		2
+#define SMUX_TX_INT		3
+#define GMPX_PCS_INT		4
+#define GMPX_GMI_RX_INT		5
+#define GMPX_GMI_TX_INT		6
+#define CMR_MEM_INT		28
+#define SPU_MEM_INT		29
+
+#define LMAC_INTR_LINK_UP	(1 << 0)
+#define LMAC_INTR_LINK_DOWN	(1 << 1)
+
+/*  RX_DMAC_CTL configuration*/
+enum MCAST_MODE {
+		MCAST_MODE_REJECT,
+		MCAST_MODE_ACCEPT,
+		MCAST_MODE_CAM_FILTER,
+		RSVD
+};
+
+#define BCAST_ACCEPT	1
+#define CAM_ACCEPT	1
+
+void bgx_add_dmac_addr(uint64_t dmac, int node, int bgx_idx, int lmac);
+void bgx_get_count(int node, int *bgx_count);
+int bgx_get_lmac_count(int node, int bgx);
+
+#endif /* THUNDER_BGX_H */
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index 1fa99a301817..80bd3336691e 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -2324,6 +2324,8 @@
 #define PCI_DEVICE_ID_ALTIMA_AC9100	0x03ea
 #define PCI_DEVICE_ID_ALTIMA_AC1003	0x03eb
 
+#define PCI_VENDOR_ID_CAVIUM		0x177d
+
 #define PCI_VENDOR_ID_BELKIN		0x1799
 #define PCI_DEVICE_ID_BELKIN_F5D7010V7	0x701f
 
-- 
2.1.3
