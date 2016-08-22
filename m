From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V3 05/18] liquidio: CN23XX queue definitions
Date: Sun, 21 Aug 2016 17:12:32 -0700
Message-ID: <1471824765-26473-6-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1471824765-26473-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0041.outbound.protection.outlook.com ([104.47.42.41]:52561
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753647AbcHVAOD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 21 Aug 2016 20:14:03 -0400
In-Reply-To: <1471824765-26473-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for cn23xx specific queue definitions and
features.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/Kconfig                |   4 +-
 .../ethernet/cavium/liquidio/cn23xx_pf_device.h    |  48 +++++++
 drivers/net/ethernet/cavium/liquidio/lio_main.c    |  47 ++++---
 .../net/ethernet/cavium/liquidio/octeon_config.h   |  56 ++++++--
 .../net/ethernet/cavium/liquidio/octeon_device.c   | 142 ++++++++++++++++++++-
 .../net/ethernet/cavium/liquidio/octeon_device.h   |  39 ++++--
 6 files changed, 295 insertions(+), 41 deletions(-)
 create mode 100644 drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h

diff --git a/drivers/net/ethernet/cavium/Kconfig b/drivers/net/ethernet/cavium/Kconfig
index e1b78b5..e775495 100644
--- a/drivers/net/ethernet/cavium/Kconfig
+++ b/drivers/net/ethernet/cavium/Kconfig
@@ -58,7 +58,7 @@ config LIQUIDIO
 	select LIBCRC32C
 	---help---
 	  This driver supports Cavium LiquidIO Intelligent Server Adapters
-	  based on CN66XX and CN68XX chips.
+	  based on CN66XX, CN68XX and CN23XX chips.
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called liquidio.  This is recommended.
@@ -69,7 +69,7 @@ config OCTEON_MGMT_ETHERNET
 	select PHYLIB
 	select MDIO_OCTEON
 	default y
-	help
+	---help---
 	  Enable the ethernet driver for the management
 	  port on Cavium Networks' Octeon CN57XX, CN56XX, CN55XX,
 	  CN54XX, CN52XX, and CN6XXX chips.
diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h
new file mode 100644
index 0000000..e07d530
--- /dev/null
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h
@@ -0,0 +1,48 @@
+/**********************************************************************
+* Author: Cavium, Inc.
+*
+* Contact: support@cavium.com
+*          Please include "LiquidIO" in the subject.
+*
+* Copyright (c) 2003-2015 Cavium, Inc.
+*
+* This file is free software; you can redistribute it and/or modify
+* it under the terms of the GNU General Public License, Version 2, as
+* published by the Free Software Foundation.
+*
+* This file is distributed in the hope that it will be useful, but
+* AS-IS and WITHOUT ANY WARRANTY; without even the implied warranty
+* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE, TITLE, or
+* NONINFRINGEMENT.  See the GNU General Public License for more
+* details.
+*
+* This file may also be available under a different license from Cavium.
+* Contact Cavium, Inc. for more information
+**********************************************************************/
+
+/*! \file  cn23xx_device.h
+ * \brief Host Driver: Routines that perform CN23XX specific operations.
+*/
+
+#ifndef __CN23XX_PF_DEVICE_H__
+#define __CN23XX_PF_DEVICE_H__
+
+#include "cn23xx_pf_regs.h"
+
+/* Register address and configuration for a CN23XX devices.
+ * If device specific changes need to be made then add a struct to include
+ * device specific fields as shown in the commented section
+ */
+struct octeon_cn23xx_pf {
+	/** PCI interrupt summary register */
+	u8 __iomem *intr_sum_reg64;
+
+	/** PCI interrupt enable register */
+	u8 __iomem *intr_enb_reg64;
+
+	/** The PCI interrupt mask used by interrupt handler */
+	u64 intr_mask64;
+
+	struct octeon_config *conf;
+};
+#endif
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 19d1e86..3fe7b70 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -474,6 +474,9 @@ static const struct pci_device_id liquidio_pci_tbl[] = {
 	{       /* 66xx */
 		PCI_VENDOR_ID_CAVIUM, 0x92, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0
 	},
+	{       /* 23xx pf */
+		PCI_VENDOR_ID_CAVIUM, 0x9702, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0
+	},
 	{
 		0, 0, 0, 0, 0, 0, 0
 	}
@@ -491,7 +494,6 @@ static struct pci_driver liquidio_pci_driver = {
 	.suspend	= liquidio_suspend,
 	.resume		= liquidio_resume,
 #endif
-
 };
 
 /**
@@ -3269,15 +3271,24 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 		vdata->minor = cpu_to_be16(LIQUIDIO_BASE_MINOR_VERSION);
 		vdata->micro = cpu_to_be16(LIQUIDIO_BASE_MICRO_VERSION);
 
-		num_iqueues =
-			CFG_GET_NUM_TXQS_NIC_IF(octeon_get_conf(octeon_dev), i);
-		num_oqueues =
-			CFG_GET_NUM_RXQS_NIC_IF(octeon_get_conf(octeon_dev), i);
-		base_queue =
-			CFG_GET_BASE_QUE_NIC_IF(octeon_get_conf(octeon_dev), i);
-		gmx_port_id =
-			CFG_GET_GMXID_NIC_IF(octeon_get_conf(octeon_dev), i);
-		ifidx_or_pfnum = i;
+		if (OCTEON_CN23XX_PF(octeon_dev)) {
+			num_iqueues = octeon_dev->sriov_info.num_pf_rings;
+			num_oqueues = octeon_dev->sriov_info.num_pf_rings;
+			base_queue = octeon_dev->sriov_info.pf_srn;
+
+			gmx_port_id = octeon_dev->pf_num;
+			ifidx_or_pfnum = octeon_dev->pf_num;
+		} else {
+			num_iqueues = CFG_GET_NUM_TXQS_NIC_IF(
+						octeon_get_conf(octeon_dev), i);
+			num_oqueues = CFG_GET_NUM_RXQS_NIC_IF(
+						octeon_get_conf(octeon_dev), i);
+			base_queue = CFG_GET_BASE_QUE_NIC_IF(
+						octeon_get_conf(octeon_dev), i);
+			gmx_port_id = CFG_GET_GMXID_NIC_IF(
+						octeon_get_conf(octeon_dev), i);
+			ifidx_or_pfnum = i;
+		}
 
 		dev_dbg(&octeon_dev->pci_dev->dev,
 			"requesting config for interface %d, iqs %d, oqs %d\n",
@@ -3381,12 +3392,16 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 
 		lio->msg_enable = netif_msg_init(debug, DEFAULT_MSG_ENABLE);
 
-		lio->dev_capability = NETIF_F_HIGHDMA
-				| NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM
-				| NETIF_F_SG | NETIF_F_RXCSUM
-				| NETIF_F_GRO
-				| NETIF_F_TSO | NETIF_F_TSO6
-				| NETIF_F_LRO;
+		if (OCTEON_CN23XX_PF(octeon_dev) ||
+		    OCTEON_CN6XXX(octeon_dev)) {
+			lio->dev_capability = NETIF_F_HIGHDMA
+					      | NETIF_F_IP_CSUM
+					      | NETIF_F_IPV6_CSUM
+					      | NETIF_F_SG | NETIF_F_RXCSUM
+					      | NETIF_F_GRO
+					      | NETIF_F_TSO | NETIF_F_TSO6
+					      | NETIF_F_LRO;
+		}
 		netif_set_gso_max_size(netdev, OCTNIC_GSO_MAX_SIZE);
 
 		/*  Copy of transmit encapsulation capabilities:
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_config.h b/drivers/net/ethernet/cavium/liquidio/octeon_config.h
index b3396e3..79e1522 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_config.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_config.h
@@ -64,6 +64,34 @@
 #define   DEFAULT_NUM_NIC_PORTS_68XX   4
 #define   DEFAULT_NUM_NIC_PORTS_68XX_210NV  2
 
+/* CN23xx  IQ configuration macros */
+#define   CN23XX_MAX_RINGS_PER_PF_PASS_1_0 12
+#define   CN23XX_MAX_RINGS_PER_PF_PASS_1_1 32
+#define   CN23XX_MAX_RINGS_PER_PF	64
+
+#define   CN23XX_MAX_INPUT_QUEUES	CN23XX_MAX_RINGS_PER_PF
+#define   CN23XX_MAX_IQ_DESCRIPTORS	2048
+#define   CN23XX_DB_MIN                 1
+#define   CN23XX_DB_MAX                 8
+#define   CN23XX_DB_TIMEOUT		1
+
+#define   CN23XX_MAX_OUTPUT_QUEUES	CN23XX_MAX_RINGS_PER_PF
+#define   CN23XX_MAX_OQ_DESCRIPTORS	2048
+#define   CN23XX_OQ_BUF_SIZE		1536
+#define   CN23XX_OQ_PKTSPER_INTR	128
+/*#define CAVIUM_ONLY_CN23XX_RX_PERF*/
+#define   CN23XX_OQ_REFIL_THRESHOLD	128
+
+#define   CN23XX_OQ_INTR_PKT		64
+#define   CN23XX_OQ_INTR_TIME		100
+#define   DEFAULT_NUM_NIC_PORTS_23XX	1
+
+#define   CN23XX_CFG_IO_QUEUES		CN23XX_MAX_RINGS_PER_PF
+/* PEMs count */
+#define   CN23XX_MAX_MACS		4
+
+#define   CN23XX_DEF_IQ_INTR_THRESHOLD	32
+#define   CN23XX_DEF_IQ_INTR_BYTE_THRESHOLD   (64 * 1024)
 /* common OCTEON configuration macros */
 #define   CN6XXX_CFG_IO_QUEUES         32
 #define   OCTEON_32BYTE_INSTR          32
@@ -140,19 +168,24 @@
 enum lio_card_type {
 	LIO_210SV = 0, /* Two port, 66xx */
 	LIO_210NV,     /* Two port, 68xx */
-	LIO_410NV      /* Four port, 68xx */
+	LIO_410NV,     /* Four port, 68xx */
+	LIO_23XX       /* 23xx */
 };
 
 #define LIO_210SV_NAME "210sv"
 #define LIO_210NV_NAME "210nv"
 #define LIO_410NV_NAME "410nv"
+#define LIO_23XX_NAME  "23xx"
 
 /** Structure to define the configuration attributes for each Input queue.
  *  Applicable to all Octeon processors
  **/
 struct octeon_iq_config {
 #ifdef __BIG_ENDIAN_BITFIELD
-	u64 reserved:32;
+	u64 reserved:16;
+
+	/** Tx interrupt packets. Applicable to 23xx only */
+	u64 iq_intr_pkt:16;
 
 	/** Minimum ticks to wait before checking for pending instructions. */
 	u64 db_timeout:16;
@@ -192,7 +225,10 @@ struct octeon_iq_config {
 	/** Minimum ticks to wait before checking for pending instructions. */
 	u64 db_timeout:16;
 
-	u64 reserved:32;
+	/** Tx interrupt packets. Applicable to 23xx only */
+	u64 iq_intr_pkt:16;
+
+	u64 reserved:16;
 #endif
 };
 
@@ -416,11 +452,15 @@ struct octeon_config {
 #define DISPATCH_LIST_SIZE                      BIT(OPCODE_MASK_BITS)
 
 /* Maximum number of Octeon Instruction (command) queues */
-#define MAX_OCTEON_INSTR_QUEUES(oct)         CN6XXX_MAX_INPUT_QUEUES
-/* Maximum number of Octeon Output queues */
-#define MAX_OCTEON_OUTPUT_QUEUES(oct)         CN6XXX_MAX_OUTPUT_QUEUES
+#define MAX_OCTEON_INSTR_QUEUES(oct)		\
+		(OCTEON_CN23XX_PF(oct) ? CN23XX_MAX_INPUT_QUEUES : \
+					CN6XXX_MAX_INPUT_QUEUES)
 
-#define MAX_POSSIBLE_OCTEON_INSTR_QUEUES       CN6XXX_MAX_INPUT_QUEUES
-#define MAX_POSSIBLE_OCTEON_OUTPUT_QUEUES      CN6XXX_MAX_OUTPUT_QUEUES
+/* Maximum number of Octeon Instruction (command) queues */
+#define MAX_OCTEON_OUTPUT_QUEUES(oct)		\
+		(OCTEON_CN23XX_PF(oct) ? CN23XX_MAX_OUTPUT_QUEUES : \
+					CN6XXX_MAX_OUTPUT_QUEUES)
 
+#define MAX_POSSIBLE_OCTEON_INSTR_QUEUES	CN23XX_MAX_INPUT_QUEUES
+#define MAX_POSSIBLE_OCTEON_OUTPUT_QUEUES	CN23XX_MAX_OUTPUT_QUEUES
 #endif /* __OCTEON_CONFIG_H__  */
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index 541137a..120b78e 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -31,6 +31,7 @@
 #include "octeon_network.h"
 #include "cn66xx_regs.h"
 #include "cn66xx_device.h"
+#include "cn23xx_pf_device.h"
 
 /** Default configuration
  *  for CN66XX OCTEON Models.
@@ -417,6 +418,108 @@ static struct octeon_config default_cn68xx_210nv_conf = {
 	,
 };
 
+static struct octeon_config default_cn23xx_conf = {
+	.card_type                              = LIO_23XX,
+	.card_name                              = LIO_23XX_NAME,
+	/** IQ attributes */
+	.iq = {
+		.max_iqs		= CN23XX_CFG_IO_QUEUES,
+		.pending_list_size	= (CN23XX_MAX_IQ_DESCRIPTORS *
+					   CN23XX_CFG_IO_QUEUES),
+		.instr_type		= OCTEON_64BYTE_INSTR,
+		.db_min			= CN23XX_DB_MIN,
+		.db_timeout		= CN23XX_DB_TIMEOUT,
+		.iq_intr_pkt		= CN23XX_DEF_IQ_INTR_THRESHOLD,
+	},
+
+	/** OQ attributes */
+	.oq = {
+		.max_oqs		= CN23XX_CFG_IO_QUEUES,
+		.info_ptr		= OCTEON_OQ_INFOPTR_MODE,
+		.pkts_per_intr	= CN23XX_OQ_PKTSPER_INTR,
+		.refill_threshold	= CN23XX_OQ_REFIL_THRESHOLD,
+		.oq_intr_pkt	= CN23XX_OQ_INTR_PKT,
+		.oq_intr_time	= CN23XX_OQ_INTR_TIME,
+	},
+
+	.num_nic_ports				= DEFAULT_NUM_NIC_PORTS_23XX,
+	.num_def_rx_descs			= CN23XX_MAX_OQ_DESCRIPTORS,
+	.num_def_tx_descs			= CN23XX_MAX_IQ_DESCRIPTORS,
+	.def_rx_buf_size			= CN23XX_OQ_BUF_SIZE,
+
+	/* For ethernet interface 0:  Port cfg Attributes */
+	.nic_if_cfg[0] = {
+		/* Max Txqs: Half for each of the two ports :max_iq/2 */
+		.max_txqs			= MAX_TXQS_PER_INTF,
+
+		/* Actual configured value. Range could be: 1...max_txqs */
+		.num_txqs			= DEF_TXQS_PER_INTF,
+
+		/* Max Rxqs: Half for each of the two ports :max_oq/2  */
+		.max_rxqs			= MAX_RXQS_PER_INTF,
+
+		/* Actual configured value. Range could be: 1...max_rxqs */
+		.num_rxqs			= DEF_RXQS_PER_INTF,
+
+		/* Num of desc for rx rings */
+		.num_rx_descs			= CN23XX_MAX_OQ_DESCRIPTORS,
+
+		/* Num of desc for tx rings */
+		.num_tx_descs			= CN23XX_MAX_IQ_DESCRIPTORS,
+
+		/* SKB size, We need not change buf size even for Jumbo frames.
+		 * Octeon can send jumbo frames in 4 consecutive descriptors,
+		 */
+		.rx_buf_size			= CN23XX_OQ_BUF_SIZE,
+
+		.base_queue			= BASE_QUEUE_NOT_REQUESTED,
+
+		.gmx_port_id			= 0,
+	},
+
+	.nic_if_cfg[1] = {
+		/* Max Txqs: Half for each of the two ports :max_iq/2 */
+		.max_txqs			= MAX_TXQS_PER_INTF,
+
+		/* Actual configured value. Range could be: 1...max_txqs */
+		.num_txqs			= DEF_TXQS_PER_INTF,
+
+		/* Max Rxqs: Half for each of the two ports :max_oq/2  */
+		.max_rxqs			= MAX_RXQS_PER_INTF,
+
+		/* Actual configured value. Range could be: 1...max_rxqs */
+		.num_rxqs			= DEF_RXQS_PER_INTF,
+
+		/* Num of desc for rx rings */
+		.num_rx_descs			= CN23XX_MAX_OQ_DESCRIPTORS,
+
+		/* Num of desc for tx rings */
+		.num_tx_descs			= CN23XX_MAX_IQ_DESCRIPTORS,
+
+		/* SKB size, We need not change buf size even for Jumbo frames.
+		 * Octeon can send jumbo frames in 4 consecutive descriptors,
+		 */
+		.rx_buf_size			= CN23XX_OQ_BUF_SIZE,
+
+		.base_queue			= BASE_QUEUE_NOT_REQUESTED,
+
+		.gmx_port_id			= 1,
+	},
+
+	.misc					= {
+		/* Host driver link query interval */
+		.oct_link_query_interval	= 100,
+
+		/* Octeon link query interval */
+		.host_link_query_interval	= 500,
+
+		.enable_sli_oq_bp		= 0,
+
+		/* Control queue group */
+		.ctrlq_grp			= 1,
+	}
+};
+
 enum {
 	OCTEON_CONFIG_TYPE_DEFAULT = 0,
 	NUM_OCTEON_CONFS,
@@ -484,6 +587,8 @@ static void *__retrieve_octeon_config_info(struct octeon_device *oct,
 		} else if ((oct->chip_id == OCTEON_CN68XX) &&
 			   (card_type == LIO_410NV)) {
 			ret =  (void *)&default_cn68xx_conf;
+		} else if (oct->chip_id == OCTEON_CN23XX_PF_VID) {
+			ret =  (void *)&default_cn23xx_conf;
 		}
 		break;
 	default:
@@ -498,7 +603,8 @@ static int __verify_octeon_config_info(struct octeon_device *oct, void *conf)
 	case OCTEON_CN66XX:
 	case OCTEON_CN68XX:
 		return lio_validate_cn6xxx_config_info(oct, conf);
-
+	case OCTEON_CN23XX_PF_VID:
+		return 0;
 	default:
 		break;
 	}
@@ -572,6 +678,9 @@ static struct octeon_device *octeon_allocate_device_mem(u32 pci_id,
 		configsize = sizeof(struct octeon_cn6xxx);
 		break;
 
+	case OCTEON_CN23XX_PF_VID:
+		configsize = sizeof(struct octeon_cn23xx_pf);
+		break;
 	default:
 		pr_err("%s: Unknown PCI Device: 0x%x\n",
 		       __func__,
@@ -649,6 +758,9 @@ int octeon_setup_instr_queues(struct octeon_device *oct)
 	if (OCTEON_CN6XXX(oct))
 		num_descs =
 			CFG_GET_NUM_DEF_TX_DESCS(CHIP_FIELD(oct, cn6xxx, conf));
+	else if (OCTEON_CN23XX_PF(oct))
+		num_descs = CFG_GET_NUM_DEF_TX_DESCS(CHIP_FIELD(oct, cn23xx_pf,
+								conf));
 
 	oct->num_iqs = 0;
 
@@ -690,8 +802,12 @@ int octeon_setup_output_queues(struct octeon_device *oct)
 			CFG_GET_NUM_DEF_RX_DESCS(CHIP_FIELD(oct, cn6xxx, conf));
 		desc_size =
 			CFG_GET_DEF_RX_BUF_SIZE(CHIP_FIELD(oct, cn6xxx, conf));
+	} else if (OCTEON_CN23XX_PF(oct)) {
+		num_descs = CFG_GET_NUM_DEF_RX_DESCS(CHIP_FIELD(oct, cn23xx_pf,
+								conf));
+		desc_size = CFG_GET_DEF_RX_BUF_SIZE(CHIP_FIELD(oct, cn23xx_pf,
+							       conf));
 	}
-
 	oct->num_oqs = 0;
 	oct->droq[0] = vmalloc_node(sizeof(*oct->droq[0]), numa_node);
 	if (!oct->droq[0])
@@ -915,6 +1031,9 @@ int octeon_core_drv_init(struct octeon_recv_info *recv_info, void *buf)
 	if (OCTEON_CN6XXX(oct))
 		num_nic_ports =
 			CFG_GET_NUM_NIC_PORTS(CHIP_FIELD(oct, cn6xxx, conf));
+	else if (OCTEON_CN23XX_PF(oct))
+		num_nic_ports =
+			CFG_GET_NUM_NIC_PORTS(CHIP_FIELD(oct, cn23xx_pf, conf));
 
 	if (atomic_read(&oct->status) >= OCT_DEV_RUNNING) {
 		dev_err(&oct->pci_dev->dev, "Received CORE OK when device state is 0x%x\n",
@@ -1004,8 +1123,10 @@ struct octeon_config *octeon_get_conf(struct octeon_device *oct)
 	if (OCTEON_CN6XXX(oct)) {
 		default_oct_conf =
 			(struct octeon_config *)(CHIP_FIELD(oct, cn6xxx, conf));
+	} else if (OCTEON_CN23XX_PF(oct)) {
+		default_oct_conf = (struct octeon_config *)
+			(CHIP_FIELD(oct, cn23xx_pf, conf));
 	}
-
 	return default_oct_conf;
 }
 
@@ -1037,7 +1158,9 @@ u64 lio_pci_readq(struct octeon_device *oct, u64 addr)
 	 * So write MSB first
 	 */
 	addrhi = (addr >> 32);
-	if ((oct->chip_id == OCTEON_CN66XX) || (oct->chip_id == OCTEON_CN68XX))
+	if ((oct->chip_id == OCTEON_CN66XX) ||
+	    (oct->chip_id == OCTEON_CN68XX) ||
+	    (oct->chip_id == OCTEON_CN23XX_PF_VID))
 		addrhi |= 0x00060000;
 	writel(addrhi, oct->reg_list.pci_win_rd_addr_hi);
 
@@ -1081,8 +1204,15 @@ int octeon_mem_access_ok(struct octeon_device *oct)
 	u64 lmc0_reset_ctl;
 
 	/* Check to make sure a DDR interface is enabled */
-	lmc0_reset_ctl = lio_pci_readq(oct, CN6XXX_LMC0_RESET_CTL);
-	access_okay = (lmc0_reset_ctl & CN6XXX_LMC0_RESET_CTL_DDR3RST_MASK);
+	if (OCTEON_CN23XX_PF(oct)) {
+		lmc0_reset_ctl = lio_pci_readq(oct, CN23XX_LMC0_RESET_CTL);
+		access_okay =
+			(lmc0_reset_ctl & CN23XX_LMC0_RESET_CTL_DDR3RST_MASK);
+	} else {
+		lmc0_reset_ctl = lio_pci_readq(oct, CN6XXX_LMC0_RESET_CTL);
+		access_okay =
+			(lmc0_reset_ctl & CN6XXX_LMC0_RESET_CTL_DDR3RST_MASK);
+	}
 
 	return access_okay ? 0 : 1;
 }
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index fcda21e..c1757ce 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -30,13 +30,19 @@
 /** PCI VendorId Device Id */
 #define  OCTEON_CN68XX_PCIID          0x91177d
 #define  OCTEON_CN66XX_PCIID          0x92177d
-
+#define  OCTEON_CN23XX_PCIID_PF       0x9702177d
 /** Driver identifies chips by these Ids, created by clubbing together
  *  DeviceId+RevisionId; Where Revision Id is not used to distinguish
  *  between chips, a value of 0 is used for revision id.
  */
 #define  OCTEON_CN68XX                0x0091
 #define  OCTEON_CN66XX                0x0092
+#define  OCTEON_CN23XX_PF_VID         0x9702
+
+/**RevisionId for the chips */
+#define	 OCTEON_CN23XX_REV_1_0		0x00
+#define	 OCTEON_CN23XX_REV_1_1		0x01
+#define	 OCTEON_CN23XX_REV_2_0		0x80
 
 /** Endian-swap modes supported by Octeon. */
 enum octeon_pci_swap_mode {
@@ -67,13 +73,14 @@ enum octeon_pci_swap_mode {
 #define    OCT_DEV_SC_BUFF_POOL_INIT_DONE 0x4
 #define    OCT_DEV_RESP_LIST_INIT_DONE    0x5
 #define    OCT_DEV_DROQ_INIT_DONE         0x6
-#define    OCT_DEV_IO_QUEUES_DONE         0x7
-#define    OCT_DEV_CONSOLE_INIT_DONE      0x8
-#define    OCT_DEV_HOST_OK                0x9
-#define    OCT_DEV_CORE_OK                0xa
-#define    OCT_DEV_RUNNING                0xb
-#define    OCT_DEV_IN_RESET               0xc
-#define    OCT_DEV_STATE_INVALID          0xd
+#define    OCT_DEV_INTR_SET_DONE          0x7
+#define    OCT_DEV_IO_QUEUES_DONE         0x8
+#define    OCT_DEV_CONSOLE_INIT_DONE      0x9
+#define    OCT_DEV_HOST_OK                0xa
+#define    OCT_DEV_CORE_OK                0xb
+#define    OCT_DEV_RUNNING                0xc
+#define    OCT_DEV_IN_RESET               0xd
+#define    OCT_DEV_STATE_INVALID          0xe
 
 #define    OCT_DEV_STATES                 OCT_DEV_STATE_INVALID
 
@@ -271,6 +278,17 @@ struct octdev_props {
 	struct net_device *netdev;
 };
 
+struct octeon_sriov_info {
+	/* Actual rings left for PF device */
+	u32	num_pf_rings;
+
+	/* SRN of PF usable IO queues   */
+	u32	pf_srn;
+	/* total pf rings */
+	u32	trs;
+
+};
+
 /** The Octeon device.
  *  Each Octeon device has this structure to represent all its
  *  components.
@@ -296,7 +314,7 @@ struct octeon_device {
 	/** Octeon Chip type. */
 	u16 chip_id;
 	u16 rev_id;
-
+	u16 pf_num;
 	/** This device's id - set by the driver. */
 	u32 octeon_id;
 
@@ -395,6 +413,8 @@ struct octeon_device {
 
 	void *priv;
 
+	struct octeon_sriov_info sriov_info;
+
 	int rx_pause;
 	int tx_pause;
 
@@ -408,6 +428,7 @@ struct octeon_device {
 #define  OCT_DRV_OFFLINE 2
 #define  OCTEON_CN6XXX(oct)           ((oct->chip_id == OCTEON_CN66XX) || \
 				       (oct->chip_id == OCTEON_CN68XX))
+#define  OCTEON_CN23XX_PF(oct)        (oct->chip_id == OCTEON_CN23XX_PF_VID)
 #define CHIP_FIELD(oct, TYPE, field)             \
 	(((struct octeon_ ## TYPE  *)(oct->chip))->field)
 
-- 
1.8.3.1
