From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH 1/7] net: xgmac: add basic framework for Samsung 10Gb ethernet
 driver
Date: Wed, 05 Mar 2014 20:28:16 +0900
Message-ID: <007b01cf3866$009f1900$01dd4b00$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, siva.kallam@samsung.com,
	vipul.pandya@samsung.com, ks.giri@samsung.com,
	ilho215.lee@samsung.com
To: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-samsung-soc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:58294 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755162AbaCEL2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 06:28:20 -0500
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Siva Reddy <siva.kallam@samsung.com>

This patch adds support for Samsung 10Gb ethernet driver(xgmac).

- xgmac core initialization
- Tx and Rx support
- MDIO support
- ISRs for Tx and Rx
- ifconfig support to driver

Signed-off-by: Siva Reddy Kallam <siva.kallam@samsung.com>
Signed-off-by: Vipul Pandya <vipul.pandya@samsung.com>
Signed-off-by: Girish K S <ks.giri@samsung.com>
Signed-off-by: Byungho An <bh74.an@samsung.com>
---
 .../devicetree/bindings/net/samsung-xgmac.txt      |   39 +
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/samsung/Kconfig               |    7 +
 drivers/net/ethernet/samsung/Makefile              |    4 +
 drivers/net/ethernet/samsung/xgmac_common.h        |  476 +++++
 drivers/net/ethernet/samsung/xgmac_core.c          |  157 ++
 drivers/net/ethernet/samsung/xgmac_desc.c          |  469 +++++
 drivers/net/ethernet/samsung/xgmac_desc.h          |  291 +++
 drivers/net/ethernet/samsung/xgmac_dma.c           |  371 ++++
 drivers/net/ethernet/samsung/xgmac_dma.h           |   49 +
 drivers/net/ethernet/samsung/xgmac_ethtool.c       |   38 +
 drivers/net/ethernet/samsung/xgmac_main.c          | 2146 ++++++++++++++++++++
 drivers/net/ethernet/samsung/xgmac_mdio.c          |  274 +++
 drivers/net/ethernet/samsung/xgmac_mtl.c           |  238 +++
 drivers/net/ethernet/samsung/xgmac_mtl.h           |  104 +
 drivers/net/ethernet/samsung/xgmac_platform.c      |  264 +++
 drivers/net/ethernet/samsung/xgmac_reg.h           |  477 +++++
 drivers/net/ethernet/samsung/xgmac_xpcs.c          |   92 +
 drivers/net/ethernet/samsung/xgmac_xpcs.h          |   38 +
 include/linux/xgmac_platform.h                     |   54 +
 21 files changed, 5590 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/samsung-xgmac.txt
 create mode 100644 drivers/net/ethernet/samsung/Kconfig
 create mode 100644 drivers/net/ethernet/samsung/Makefile
 create mode 100644 drivers/net/ethernet/samsung/xgmac_common.h
 create mode 100644 drivers/net/ethernet/samsung/xgmac_core.c
 create mode 100644 drivers/net/ethernet/samsung/xgmac_desc.c
 create mode 100644 drivers/net/ethernet/samsung/xgmac_desc.h
 create mode 100644 drivers/net/ethernet/samsung/xgmac_dma.c
 create mode 100644 drivers/net/ethernet/samsung/xgmac_dma.h
 create mode 100644 drivers/net/ethernet/samsung/xgmac_ethtool.c
 create mode 100644 drivers/net/ethernet/samsung/xgmac_main.c
 create mode 100644 drivers/net/ethernet/samsung/xgmac_mdio.c
 create mode 100644 drivers/net/ethernet/samsung/xgmac_mtl.c
 create mode 100644 drivers/net/ethernet/samsung/xgmac_mtl.h
 create mode 100644 drivers/net/ethernet/samsung/xgmac_platform.c
 create mode 100644 drivers/net/ethernet/samsung/xgmac_reg.h
 create mode 100644 drivers/net/ethernet/samsung/xgmac_xpcs.c
 create mode 100644 drivers/net/ethernet/samsung/xgmac_xpcs.h
 create mode 100644 include/linux/xgmac_platform.h

diff --git a/Documentation/devicetree/bindings/net/samsung-xgmac.txt b/Documentation/devicetree/bindings/net/samsung-xgmac.txt
new file mode 100644
index 0000000..f2abf65
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/samsung-xgmac.txt
@@ -0,0 +1,39 @@
+* Samsung 10G Ethernet driver (XGMAC)
+
+Required properties:
+- compatible: Should be "samsung,xgmac-v2.0a"
+- reg: Address and length of the register set for the device
+- interrupt-parent: Should be the phandle for the interrupt controller
+  that services interrupts for this device
+- interrupts: Should contain the XGMAC interrupts
+- phy-mode: String, operation mode of the PHY interface.
+  Supported values are: "xaui", "gmii".
+- samsung,pbl		Programmable Burst Length
+- samsung,burst-map        Program the possible bursts supported by xgmac
+- samsung,fixed-burst	Program the DMA to use the fixed burst mode
+- samsung,adv-addr-mode	program the DMA to use Enhanced address mode
+- samsung,force_thresh_dma_mode	Force DMA to use the threshold mode for
+				both tx and rx
+- samsung,force_sf_dma_mode	Force DMA to use the Store and Forward
+				mode for both tx and rx. This flag is
+				ignored if force_thresh_dma_mode is set.
+
+Optional properties:
+- mac-address: 6 bytes, mac address
+
+Examples:
+
+	xgmac0: ethernet@1a040000 {
+		compatible = "samsung,dwxgmac-v2.0a";
+		reg = <1a040000 0x10000>;
+		interrupt-parent = <&gic>;
+		interrupts = <0 209 4>, <0 185 4>, <0 186 4>, <0 187 4>,
+			     <0 188 4>, <0 189 4>, <0 190 4>, <0 191 4>,
+			     <0 192 4>, <0 193 4>, <0 194 4>, <0 195 4>,
+			     <0 196 4>, <0 197 4>, <0 198 4>, <0 199 4>,
+			     <0 200 4>, <0 201 4>, <0 202 4>, <0 203 4>,
+			     <0 204 4>, <0 205 4>, <0 206 4>, <0 207 4>,
+			     <0 208 4>, <0 211 4>;
+		mac-address = [000000000000]; /* Filled in by U-Boot */
+		phy-mode = "xaui";
+	};
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 506b024..d4545fa 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -149,6 +149,7 @@ config S6GMAC
 	  To compile this driver as a module, choose M here. The module
 	  will be called s6gmac.
 
+source "drivers/net/ethernet/samsung/Kconfig"
 source "drivers/net/ethernet/seeq/Kconfig"
 source "drivers/net/ethernet/silan/Kconfig"
 source "drivers/net/ethernet/sis/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index c0b8789..153d38d 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -60,6 +60,7 @@ obj-$(CONFIG_NET_VENDOR_REALTEK) += realtek/
 obj-$(CONFIG_SH_ETH) += renesas/
 obj-$(CONFIG_NET_VENDOR_RDC) += rdc/
 obj-$(CONFIG_S6GMAC) += s6gmac.o
+obj-$(CONFIG_NET_SAMSUNG_XGMAC) += samsung/
 obj-$(CONFIG_NET_VENDOR_SEEQ) += seeq/
 obj-$(CONFIG_NET_VENDOR_SILAN) += silan/
 obj-$(CONFIG_NET_VENDOR_SIS) += sis/
diff --git a/drivers/net/ethernet/samsung/Kconfig b/drivers/net/ethernet/samsung/Kconfig
new file mode 100644
index 0000000..266f063
--- /dev/null
+++ b/drivers/net/ethernet/samsung/Kconfig
@@ -0,0 +1,7 @@
+config NET_SAMSUNG_XGMAC
+	tristate "Samsung 10G/2.5G/1G XGMAC Ethernet driver"
+	depends on HAS_IOMEM && HAS_DMA
+	select CRC32
+	help
+	  This is the driver for the XGMAC 10G Ethernet IP block found on Samsung
+	  platforms.
diff --git a/drivers/net/ethernet/samsung/Makefile b/drivers/net/ethernet/samsung/Makefile
new file mode 100644
index 0000000..99ff90a
--- /dev/null
+++ b/drivers/net/ethernet/samsung/Makefile
@@ -0,0 +1,4 @@
+obj-$(CONFIG_NET_SAMSUNG_XGMAC) += samsung-xgmac.o
+samsung-xgmac-objs:= xgmac_platform.o xgmac_main.o xgmac_desc.o \
+		xgmac_dma.o xgmac_core.o xgmac_mtl.o  xgmac_mdio.o \
+		xgmac_ethtool.o xgmac_xpcs.o $(samsung-xgmac-y)
diff --git a/drivers/net/ethernet/samsung/xgmac_common.h b/drivers/net/ethernet/samsung/xgmac_common.h
new file mode 100644
index 0000000..eb78c84
--- /dev/null
+++ b/drivers/net/ethernet/samsung/xgmac_common.h
@@ -0,0 +1,476 @@
+/* 10G controller driver for Samsung SoCs
+ *
+ * Copyright (C) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ *
+ * Author: Siva Reddy Kallam <siva.kallam@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+*/
+
+#ifndef __XGMAC_COMMON_H__
+#define __XGMAC_COMMON_H__
+
+/* forward references */
+struct xgmac_desc_ops;
+struct xgmac_dma_ops;
+struct xgmac_mtl_ops;
+
+#define XGMAC_RESOURCE_NAME	"sam_xgmaceth"
+#define DRV_MODULE_VERSION	"November_2013"
+
+/* MAX HW feature words */
+#define XGMAC_HW_WORDS 3
+
+#define XGMAC_RX_COE_NONE	0
+
+/* CSR Frequency Access Defines*/
+#define XGMAC_CSR_F_150M	150000000
+#define XGMAC_CSR_F_250M	250000000
+#define XGMAC_CSR_F_300M	300000000
+#define XGMAC_CSR_F_350M	350000000
+#define XGMAC_CSR_F_400M	400000000
+#define XGMAC_CSR_F_500M	500000000
+
+/* pause time */
+#define XGMAC_PAUSE_TIME 0x200
+
+/* tx queues */
+#define XGMAC_TX_QUEUES   8
+#define XGMAC_RX_QUEUES   16
+
+/* Max/Min RI Watchdog Timer count value */
+#define XGMAC_MAX_DMA_RIWT	0xff
+#define XGMAC_MIN_DMA_RIWT	0x20
+
+/* Tx coalesce parameters */
+#define XGMAC_COAL_TX_TIMER	40000
+#define XGMAC_MAX_COAL_TX_TICK	100000
+#define XGMAC_TX_MAX_FRAMES	512
+#define XGMAC_TX_FRAMES	128
+
+
+
+/* XGMAC TX FIFO is 8K, Rx FIFO is 16K */
+#define BUF_SIZE_16KiB 16384
+#define BUF_SIZE_8KiB 8192
+#define BUF_SIZE_4KiB 4096
+#define BUF_SIZE_2KiB 2048
+
+
+#define XGMAC_DEFAULT_LIT_LS	0x3E8
+#define XGMAC_DEFAULT_TWT_LS	0x0
+
+/* Flow Control defines */
+#define XGMAC_FLOW_OFF		0
+#define XGMAC_FLOW_RX		1
+#define XGMAC_FLOW_TX		2
+#define XGMAC_FLOW_AUTO		(XGMAC_FLOW_TX | XGMAC_FLOW_RX)
+
+#define SF_DMA_MODE 1		/* DMA STORE-AND-FORWARD Operation Mode */
+
+/* errors */
+#define RX_GMII_ERR		0x01
+#define RX_WATCHDOG_ERR		0x02
+#define RX_CRC_ERR		0x03
+#define RX_GAINT_ERR		0x04
+#define RX_IP_HDR_ERR		0x05
+#define RX_PAYLOAD_ERR		0x06
+#define RX_OVERFLOW_ERR		0x07
+
+/* pkt type */
+#define RX_LEN_PKT		0x00
+#define RX_MACCTL_PKT		0x01
+#define RX_DCBCTL_PKT		0x02
+#define RX_ARP_PKT		0x03
+#define RX_OAM_PKT		0x04
+#define RX_UNTAG_PKT		0x05
+#define RX_OTHER_PKT		0x07
+#define RX_SVLAN_PKT		0x08
+#define RX_CVLAN_PKT		0x09
+#define RX_DVLAN_OCVLAN_ICVLAN_PKT		0x0A
+#define RX_DVLAN_OSVLAN_ISVLAN_PKT		0x0B
+#define RX_DVLAN_OSVLAN_ICVLAN_PKT		0x0C
+#define RX_DVLAN_OCVLAN_ISVLAN_PKT		0x0D
+
+#define RX_NOT_IP_PKT		0x00
+#define RX_IPV4_TCP_PKT		0x01
+#define RX_IPV4_UDP_PKT		0x02
+#define RX_IPV4_ICMP_PKT	0x03
+#define RX_IPV4_UNKNOWN_PKT	0x07
+#define RX_IPV6_TCP_PKT		0x09
+#define RX_IPV6_UDP_PKT		0x0A
+#define RX_IPV6_ICMP_PKT	0x0B
+#define RX_IPV6_UNKNOWN_PKT	0x0F
+
+#define RX_NO_PTP		0x00
+#define RX_PTP_SYNC		0x01
+#define RX_PTP_FOLLOW_UP	0x02
+#define RX_PTP_DELAY_REQ	0x03
+#define RX_PTP_DELAY_RESP	0x04
+#define RX_PTP_PDELAY_REQ	0x05
+#define RX_PTP_PDELAY_RESP	0x06
+#define RX_PTP_PDELAY_FOLLOW_UP	0x07
+#define RX_PTP_ANNOUNCE		0x08
+#define RX_PTP_MGMT		0x09
+#define RX_PTP_SIGNAL		0x0A
+#define RX_PTP_RESV_MSG		0x0F
+
+enum dma_irq_status {
+	tx_hard_error = BIT(0),
+	tx_bump_tc = BIT(1),
+	handle_tx = BIT(2),
+	rx_hard_error = BIT(3),
+	rx_bump_tc = BIT(4),
+	handle_rx = BIT(5),
+};
+
+#define NETIF_F_HW_VLAN_ALL     (NETIF_F_HW_VLAN_CTAG_RX |\
+				NETIF_F_HW_VLAN_STAG_RX |\
+				NETIF_F_HW_VLAN_CTAG_TX |\
+				NETIF_F_HW_VLAN_STAG_TX |\
+				NETIF_F_HW_VLAN_CTAG_FILTER |\
+				NETIF_F_HW_VLAN_STAG_FILTER)
+
+/* MMC control defines */
+#define XGMAC_MMC_CTRL_CNT_FRZ  0x00000008
+
+/* XGMAC HW ADDR regs */
+#define XGMAC_ADDR_HIGH(reg)    (((reg > 15) ? 0x00000800 : 0x00000040) + \
+				(reg * 8))
+#define XGMAC_ADDR_LOW(reg)     (((reg > 15) ? 0x00000804 : 0x00000044) + \
+				(reg * 8))
+#define XGMAC_MAX_PERFECT_ADDRESSES 32 /* Maximum unicast perfect filtering */
+#define XGMAC_FRAME_FILTER       0x00000004      /* Frame Filter */
+
+/* XGMAC Frame Filter defines */
+#define XGMAC_FRAME_FILTER_PR    0x00000001      /* Promiscuous Mode */
+#define XGMAC_FRAME_FILTER_HUC   0x00000002      /* Hash Unicast */
+#define XGMAC_FRAME_FILTER_HMC   0x00000004      /* Hash Multicast */
+#define XGMAC_FRAME_FILTER_DAIF  0x00000008      /* DA Inverse Filtering */
+#define XGMAC_FRAME_FILTER_PM    0x00000010      /* Pass all multicast */
+#define XGMAC_FRAME_FILTER_DBF   0x00000020      /* Disable Broadcast frames */
+#define XGMAC_FRAME_FILTER_SAIF  0x00000100      /* Inverse Filtering */
+#define XGMAC_FRAME_FILTER_SAF   0x00000200      /* Source Address Filter */
+#define XGMAC_FRAME_FILTER_HPF   0x00000400      /* Hash or perfect Filter */
+#define XGMAC_FRAME_FILTER_RA    0x80000000      /* Receive all mode */
+
+#define XGMAC_HASH_TABLE_SIZE    64
+#define XGMAC_HASH_HIGH          0x00000008      /* Multicast Hash Table High */
+#define XGMAC_HASH_LOW           0x0000000c      /* Multicast Hash Table Low */
+
+#define XGMAC_HI_REG_AE          0x80000000
+
+/* Minimum and maximum MTU */
+#define MIN_MTU         68
+#define MAX_MTU         9000
+
+#define XGMAC_FOR_EACH_QUEUE(max_queues, queue_num) \
+	for (queue_num = 0; queue_num < max_queues; queue_num++)
+
+/* xgmac statistics counters */
+struct xgmac_extra_stats {
+	/* TX/RX IRQ events */
+	unsigned long tx_underflow_irq;
+	unsigned long tx_process_stopped_irq;
+	unsigned long tx_ctxt_desc_err;
+	unsigned long tx_threshold;
+	unsigned long rx_threshold;
+	unsigned long tx_pkt_n;
+	unsigned long rx_pkt_n;
+	unsigned long normal_irq_n;
+	unsigned long tx_normal_irq_n;
+	unsigned long rx_normal_irq_n;
+	unsigned long napi_poll;
+	unsigned long tx_clean;
+	unsigned long tx_reset_ic_bit;
+	unsigned long rx_process_stopped_irq;
+	unsigned long rx_underflow_irq;
+
+	/* Bus access errors */
+	unsigned long fatal_bus_error_irq;
+	unsigned long tx_read_transfer_err;
+	unsigned long tx_write_transfer_err;
+	unsigned long tx_desc_access_err;
+	unsigned long tx_buffer_access_err;
+	unsigned long tx_data_transfer_err;
+	unsigned long rx_read_transfer_err;
+	unsigned long rx_write_transfer_err;
+	unsigned long rx_desc_access_err;
+	unsigned long rx_buffer_access_err;
+	unsigned long rx_data_transfer_err;
+
+	/* RX specific */
+	/* L2 error */
+	unsigned long rx_code_gmii_err;
+	unsigned long rx_watchdog_err;
+	unsigned long rx_crc_err;
+	unsigned long rx_gaint_pkt_err;
+	unsigned long ip_hdr_err;
+	unsigned long ip_payload_err;
+	unsigned long overflow_error;
+
+	/* L2 Pkt type */
+	unsigned long len_pkt;
+	unsigned long mac_ctl_pkt;
+	unsigned long dcb_ctl_pkt;
+	unsigned long arp_pkt;
+	unsigned long oam_pkt;
+	unsigned long untag_okt;
+	unsigned long other_pkt;
+	unsigned long svlan_tag_pkt;
+	unsigned long cvlan_tag_pkt;
+	unsigned long dvlan_ocvlan_icvlan_pkt;
+	unsigned long dvlan_osvlan_isvlan_pkt;
+	unsigned long dvlan_osvlan_icvlan_pkt;
+	unsigned long dvan_ocvlan_icvlan_pkt;
+
+	/* L3/L4 Pkt type */
+	unsigned long not_ip_pkt;
+	unsigned long ip4_tcp_pkt;
+	unsigned long ip4_udp_pkt;
+	unsigned long ip4_icmp_pkt;
+	unsigned long ip4_unknown_pkt;
+	unsigned long ip6_tcp_pkt;
+	unsigned long ip6_udp_pkt;
+	unsigned long ip6_icmp_pkt;
+	unsigned long ip6_unknown_pkt;
+
+	/* Filter specific */
+	unsigned long vlan_filter_match;
+	unsigned long sa_filter_fail;
+	unsigned long da_filter_fail;
+	unsigned long hash_filter_pass;
+	unsigned long l3_filter_match;
+	unsigned long l4_filter_match;
+
+	/* RX context specific */
+	unsigned long timestamp_dropped;
+	unsigned long rx_msg_type_no_ptp;
+	unsigned long rx_ptp_type_sync;
+	unsigned long rx_ptp_type_follow_up;
+	unsigned long rx_ptp_type_delay_req;
+	unsigned long rx_ptp_type_delay_resp;
+	unsigned long rx_ptp_type_pdelay_req;
+	unsigned long rx_ptp_type_pdelay_resp;
+	unsigned long rx_ptp_type_pdelay_follow_up;
+	unsigned long rx_ptp_announce;
+	unsigned long rx_ptp_mgmt;
+	unsigned long rx_ptp_signal;
+	unsigned long rx_ptp_resv_msg_type;
+};
+
+
+struct xgmac_hwtimestamp {
+	void (*config_hw_tstamping)(void __iomem *ioaddr, u32 data);
+	void (*config_sub_second_increment)(void __iomem *ioaddr);
+	int (*init_systime)(void __iomem *ioaddr, u32 sec, u32 nsec);
+	int (*config_addend)(void __iomem *ioaddr, u32 addend);
+	int (*adjust_systime)(void __iomem *ioaddr, u32 sec, u32 nsec,
+			       int add_sub);
+	u64 (*get_systime)(void __iomem *ioaddr);
+};
+
+struct mac_link {
+	int port;
+	int duplex;
+	int speed;
+};
+
+struct mii_regs {
+	unsigned int addr;	/* MII Address */
+	unsigned int data;	/* MII Data */
+};
+
+struct xgmac_core_ops {
+	/* MAC core initialization */
+	void (*core_init)(void __iomem *ioaddr);
+	/* Dump MAC registers */
+	void (*dump_regs)(void __iomem *ioaddr);
+	/* Handle extra events on specific interrupts hw dependent */
+	int (*host_irq_status)(void __iomem *ioaddr,
+				struct xgmac_extra_stats *x);
+	/* Set power management mode (e.g. magic frame) */
+	void (*pmt)(void __iomem *ioaddr, unsigned long mode);
+	/* Set/Get Unicast MAC addresses */
+	void (*set_umac_addr)(void __iomem *ioaddr, unsigned char *addr,
+			       unsigned int reg_n);
+	void (*get_umac_addr)(void __iomem *ioaddr, unsigned char *addr,
+			       unsigned int reg_n);
+	void (*enable_rx)(void __iomem *ioaddr, bool enable);
+	void (*enable_tx)(void __iomem *ioaddr, bool enable);
+
+	/* controller version specific operations */
+	int (*get_controller_version)(void __iomem *ioaddr);
+
+	/* If supported then get the optional core features */
+	unsigned int (*get_hw_feature)(void __iomem *ioaddr,
+						unsigned char feature_index);
+	/* adjust XGMAC speed */
+	void (*set_speed)(void __iomem *ioaddr, unsigned char speed);
+};
+
+const struct xgmac_core_ops *xgmac_get_core_ops(void);
+
+struct xgmac_ops {
+	const struct xgmac_core_ops *mac;
+	const struct xgmac_desc_ops *desc;
+	const struct xgmac_dma_ops *dma;
+	const struct xgmac_mtl_ops *mtl;
+	const struct xgmac_hwtimestamp *ptp;
+	struct mii_regs mii;	/* MII register Addresses */
+	struct mac_link link;
+	unsigned int ctrl_uid;
+	unsigned int ctrl_id;
+};
+
+/* XGMAC private data structures */
+struct xgmac_tx_queue {
+	u8 queue_no;
+	unsigned int irq_no;
+	struct xgmac_priv_data *priv_ptr;
+	struct xgmac_tx_norm_desc *dma_tx;
+	dma_addr_t dma_tx_phy;
+	dma_addr_t *tx_skbuff_dma;
+	struct sk_buff **tx_skbuff;
+	spinlock_t tx_lock;
+	unsigned int cur_tx;
+	unsigned int dirty_tx;
+	u32 tx_count_frames;
+	u32 tx_coal_frames;
+	u32 tx_coal_timer;
+	int hwts_tx_en;
+	struct timer_list txtimer;
+};
+
+struct xgmac_rx_queue {
+	u8 queue_no;
+	unsigned int irq_no;
+	struct xgmac_priv_data *priv_ptr;
+	struct xgmac_rx_norm_desc *dma_rx;
+	struct sk_buff **rx_skbuff;
+	unsigned int cur_rx;
+	unsigned int dirty_rx;
+	u32 rx_riwt;
+	dma_addr_t *rx_skbuff_dma;
+	dma_addr_t dma_rx_phy;
+};
+
+/* XGMAC HW capabilities */
+struct xgmac_hw_features {
+	/****** CAP [0] *******/
+	unsigned int gmii_1000mbps;
+	unsigned int vlan_hfilter;
+	unsigned int sma_mdio;
+	unsigned int pmt_remote_wake_up;
+	unsigned int pmt_magic_frame;
+	unsigned int rmon;
+	unsigned int arp_offload;
+	/* IEEE 1588-2008 */
+	unsigned int atime_stamp;
+
+	unsigned int tx_csum_offload;
+	unsigned int rx_csum_offload;
+	unsigned int multi_macaddr;
+	unsigned int tstamp_srcselect;
+	unsigned int sa_vlan_insert;
+
+	/****** CAP [1] *******/
+	unsigned int rxfifo_size;
+	unsigned int txfifo_size;
+	unsigned int atstmap_hword;
+	unsigned int dcb_enable;
+	unsigned int splithead_enable;
+	unsigned int tcpseg_offload;
+	unsigned int debug_mem;
+	unsigned int rss_enable;
+	unsigned int hash_tsize;
+	unsigned int l3l4_filer_size;
+
+	/* This value is in bytes and
+	 * as mentioned in HW features
+	 * of XGMAC data book
+	 */
+	unsigned int rx_mtl_qsize;
+	unsigned int tx_mtl_qsize;
+
+	/****** CAP [2] *******/
+	/* TX and RX number of channels */
+	unsigned int rx_mtl_queues;
+	unsigned int tx_mtl_queues;
+	unsigned int rx_dma_channels;
+	unsigned int tx_dma_channels;
+	unsigned int pps_output_count;
+	unsigned int aux_input_count;
+};
+
+struct xgmac_priv_data {
+	/* DMA descriptos */
+	struct xgmac_tx_queue *txq[XGMAC_TX_QUEUES];
+	struct xgmac_rx_queue *rxq[XGMAC_RX_QUEUES];
+	u8 cur_rx_qnum;
+
+	unsigned int dma_tx_size;
+	unsigned int dma_rx_size;
+	unsigned int dma_buf_sz;
+	u32 rx_riwt;
+
+	struct napi_struct napi;
+
+	void __iomem *ioaddr;
+	struct net_device *dev;
+	struct device *device;
+	struct xgmac_ops *hw;/* xgmac specific ops */
+	int no_csum_insertion;
+	spinlock_t lock;
+	spinlock_t stats_lock;
+
+	struct phy_device *phydev;
+	int oldlink;
+	int speed;
+	int oldduplex;
+	unsigned int flow_ctrl;
+	unsigned int pause;
+	struct mii_bus *mii;
+	int mii_irq[PHY_MAX_ADDR];
+
+	struct xgmac_extra_stats xstats;
+	struct xgmac_plat_data *plat;
+	struct xgmac_hw_features hw_cap;
+
+	u32 msg_enable;
+
+	struct clk *xgmac_clk;
+	int clk_csr;
+	unsigned int mode;
+	unsigned int default_addend;
+
+	/* advanced time stamp support */
+	u32 adv_ts;
+	int use_riwt;
+	spinlock_t ptp_lock;
+};
+
+/* Function prototypes */
+extern struct xgmac_priv_data *xgmac_dvr_probe(struct device *device,
+					struct xgmac_plat_data *plat_dat,
+					void __iomem *addr);
+extern int xgmac_dvr_remove(struct net_device *ndev);
+extern void xgmac_set_ethtool_ops(struct net_device *netdev);
+extern int xgmac_mdio_unregister(struct net_device *ndev);
+extern int xgmac_mdio_register(struct net_device *ndev);
+extern int xgmac_register_platform(void);
+extern void xgmac_unregister_platform(void);
+
+#ifdef CONFIG_PM
+extern int xgmac_suspend(struct net_device *ndev);
+extern int xgmac_resume(struct net_device *ndev);
+extern int xgmac_freeze(struct net_device *ndev);
+extern int xgmac_restore(struct net_device *ndev);
+#endif /* CONFIG_PM */
+
+extern const struct xgmac_mtl_ops *xgmac_get_mtl_ops(void);
+
+#endif /* __XGMAC_COMMON_H__ */
diff --git a/drivers/net/ethernet/samsung/xgmac_core.c b/drivers/net/ethernet/samsung/xgmac_core.c
new file mode 100644
index 0000000..931d05b
--- /dev/null
+++ b/drivers/net/ethernet/samsung/xgmac_core.c
@@ -0,0 +1,157 @@
+
+/* 10G controller driver for Samsung SoCs
+ *
+ * Copyright (C) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ *
+ * Author: Siva Reddy Kallam <siva.kallam@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/export.h>
+#include <linux/io.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+
+#include "xgmac_common.h"
+#include "xgmac_reg.h"
+
+/* MAC core initialization */
+static void xgmac_core_init(void __iomem *ioaddr)
+{
+	u32 regval;
+	/* TX configuration */
+	regval = readl(ioaddr + XGMAC_CORE_TX_CONFIG_REG);
+	/* Other configurable parameters IFP, IPG, ISR, ISM
+	 * needs to be set if needed
+	 */
+	regval |= XGMAC_TX_JABBER_DISABLE;
+	writel(regval, ioaddr + XGMAC_CORE_TX_CONFIG_REG);
+
+	/* RX configuration */
+	regval = readl(ioaddr + XGMAC_CORE_RX_CONFIG_REG);
+	/* Other configurable parameters CST, SPEN, USP, GPSLCE
+	 * WD, LM, S2KP, HDSMS, GPSL, ELEN, ARPEN needs to be
+	 * set if needed
+	 */
+	regval |= XGMAC_RX_JUMBPKT_ENABLE | XGMAC_RX_ACS_ENABLE;
+	writel(regval, ioaddr + XGMAC_CORE_RX_CONFIG_REG);
+}
+
+/* Dump MAC registers */
+static void xgmac_core_dump_regs(void __iomem *ioaddr)
+{
+}
+
+/* Handle extra events on specific interrupts hw dependent */
+static int xgmac_core_host_irq_status(void __iomem *ioaddr,
+				struct xgmac_extra_stats *x)
+{
+	return 0;
+}
+
+/* Set power management mode (e.g. magic frame) */
+static void xgmac_core_pmt(void __iomem *ioaddr, unsigned long mode)
+{
+}
+
+/* Set/Get Unicast MAC addresses */
+static void xgmac_core_set_umac_addr(void __iomem *ioaddr, unsigned char *addr,
+			       unsigned int reg_n)
+{
+	u32 high_word, low_word;
+
+	high_word = (addr[5] << 8) || (addr[4]);
+	low_word = (addr[3] << 24) || (addr[2] << 16) ||
+		   (addr[1] << 8) || (addr[0]);
+	writel(high_word, ioaddr + XGMAC_CORE_ADD_HIGHOFFSET(reg_n));
+	writel(low_word, ioaddr + XGMAC_CORE_ADD_LOWOFFSET(reg_n));
+}
+
+static void xgmac_core_get_umac_addr(void __iomem *ioaddr, unsigned char *addr,
+			       unsigned int reg_n)
+{
+	u32 high_word, low_word;
+
+	high_word = readl(ioaddr + XGMAC_CORE_ADD_HIGHOFFSET(reg_n));
+	low_word = readl(ioaddr + XGMAC_CORE_ADD_LOWOFFSET(reg_n));
+
+	/* extract and assign address */
+	addr[5] = (high_word & 0x0000FF00) >> 8;
+	addr[4] = (high_word & 0x000000FF);
+	addr[3] = (low_word & 0xFF000000) >> 24;
+	addr[2] = (low_word & 0x00FF0000) >> 16;
+	addr[1] = (low_word & 0x0000FF00) >> 8;
+	addr[0] = (low_word & 0x000000FF);
+}
+
+static void xgmac_enable_tx(void __iomem *ioaddr, bool enable)
+{
+	u32 tx_config;
+
+	tx_config = readl(ioaddr + XGMAC_CORE_TX_CONFIG_REG);
+	tx_config &= ~XGMAC_TX_ENABLE;
+
+	if (enable)
+		tx_config |= XGMAC_TX_ENABLE;
+	writel(tx_config, ioaddr + XGMAC_CORE_TX_CONFIG_REG);
+}
+
+static void xgmac_enable_rx(void __iomem *ioaddr, bool enable)
+{
+	u32 rx_config;
+
+	rx_config = readl(ioaddr + XGMAC_CORE_RX_CONFIG_REG);
+	rx_config &= ~XGMAC_RX_ENABLE;
+
+	if (enable)
+		rx_config |= XGMAC_RX_ENABLE;
+	writel(rx_config, ioaddr + XGMAC_CORE_RX_CONFIG_REG);
+}
+
+static int xgmac_get_controller_version(void __iomem *ioaddr)
+{
+	return readl(ioaddr + XGMAC_CORE_VERSION_REG);
+}
+
+/* If supported then get the optional core features */
+static unsigned int xgmac_get_hw_feature(void __iomem *ioaddr,
+						unsigned char feature_index)
+{
+	return readl(ioaddr + (XGMAC_CORE_HW_FEA_REG(feature_index)));
+}
+
+static void xgmac_core_set_speed(void __iomem *ioaddr,
+					unsigned char speed)
+{
+	u32 tx_cfg = readl(ioaddr + XGMAC_CORE_TX_CONFIG_REG);
+
+	/* clear the speed bits */
+	tx_cfg &= ~0x60000000;
+	tx_cfg |= (speed << XGMAC_SPEED_LSHIFT);
+
+	/* set the speed */
+	writel(tx_cfg, ioaddr + XGMAC_CORE_TX_CONFIG_REG);
+}
+
+const struct xgmac_core_ops core_ops = {
+	.core_init = xgmac_core_init,
+	.dump_regs = xgmac_core_dump_regs,
+	.host_irq_status = xgmac_core_host_irq_status,
+	.pmt = xgmac_core_pmt,
+	.set_umac_addr = xgmac_core_set_umac_addr,
+	.get_umac_addr = xgmac_core_get_umac_addr,
+	.enable_rx = xgmac_enable_rx,
+	.enable_tx = xgmac_enable_tx,
+	.get_controller_version = xgmac_get_controller_version,
+	.get_hw_feature = xgmac_get_hw_feature,
+	.set_speed = xgmac_core_set_speed,
+};
+
+const struct xgmac_core_ops *xgmac_get_core_ops(void)
+{
+	return &core_ops;
+}
diff --git a/drivers/net/ethernet/samsung/xgmac_desc.c b/drivers/net/ethernet/samsung/xgmac_desc.c
new file mode 100644
index 0000000..791b5ec
--- /dev/null
+++ b/drivers/net/ethernet/samsung/xgmac_desc.c
@@ -0,0 +1,469 @@
+/* 10G controller driver for Samsung SoCs
+ *
+ * Copyright (C) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ *
+ * Author: Siva Reddy Kallam <siva.kallam@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#include <linux/bitops.h>
+#include <linux/export.h>
+#include <linux/io.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+
+#include "xgmac_common.h"
+#include "xgmac_dma.h"
+#include "xgmac_desc.h"
+
+/* DMA TX descriptor ring initialization */
+static void xgmac_init_tx_desc(struct xgmac_tx_norm_desc *p)
+{
+	p->tdes23.tx_rd_des23.own_bit = 0;
+}
+
+/* Assign buffer lengths for descriptor */
+static void xgmac_prepare_tx_desc(struct xgmac_tx_norm_desc *p, u8 is_fd,
+				int buf1_len, int pkt_len)
+{
+	p->tdes23.tx_rd_des23.first_desc = is_fd;
+	p->tdes23.tx_rd_des23.buf1_size = buf1_len;
+
+	p->tdes23.tx_rd_des23.tx_pkt_len.cksum_pktlen.total_pkt_len = pkt_len;
+
+}
+
+/* Set VLAN control information */
+static void xgmac_tx_vlanctl_desc(struct xgmac_tx_norm_desc *p, int vlan_ctl)
+{
+	p->tdes23.tx_rd_des23.vlan_tag_ctl = vlan_ctl;
+}
+
+/* Set the owner of Normal descriptor */
+static void xgmac_set_tx_owner(struct xgmac_tx_norm_desc *p)
+{
+	p->tdes23.tx_rd_des23.own_bit = 1;
+}
+/* Get the owner of Normal descriptor */
+static int xgmac_get_tx_owner(struct xgmac_tx_norm_desc *p)
+{
+	return p->tdes23.tx_rd_des23.own_bit;
+}
+
+/* Invoked by the xmit function to close the tx descriptor */
+static void xgmac_close_tx_desc(struct xgmac_tx_norm_desc *p)
+{
+	p->tdes23.tx_rd_des23.last_desc = 1;
+	p->tdes23.tx_rd_des23.int_on_com = 1;
+}
+
+/* Clean the tx descriptor as soon as the tx irq is received */
+static void xgmac_release_tx_desc(struct xgmac_tx_norm_desc *p)
+{
+	memset(p, 0, sizeof(struct xgmac_tx_norm_desc));
+}
+
+/* Clear interrupt on tx frame completion. When this bit is
+ * set an interrupt happens as soon as the frame is transmitted
+*/
+static void xgmac_clear_tx_ic(struct xgmac_tx_norm_desc *p)
+{
+	p->tdes23.tx_rd_des23.int_on_com = 0;
+}
+
+/* Last tx segment reports the transmit status */
+static int xgmac_get_tx_ls(struct xgmac_tx_norm_desc *p)
+{
+	return p->tdes23.tx_rd_des23.last_desc;
+}
+
+/* Get the buffer size from the descriptor */
+static int xgmac_get_tx_len(struct xgmac_tx_norm_desc *p)
+{
+	return p->tdes23.tx_rd_des23.buf1_size;
+}
+
+/* Set tx timestamp enable bit */
+static void xgmac_tx_enable_tstamp(struct xgmac_tx_norm_desc *p)
+{
+	p->tdes23.tx_rd_des23.timestmp_enable = 1;
+}
+
+/* get tx timestamp status */
+static int xgmac_get_tx_timestamp_status(struct xgmac_tx_norm_desc *p)
+{
+	return p->tdes23.tx_rd_des23.timestmp_enable;
+}
+
+/* TX Context Descripto Specific */
+static void xgmac_init_tx_ctxtdesc(struct xgmac_tx_ctxt_desc *p)
+{
+	p->ctxt_bit = 1;
+	p->own_bit = 0;
+}
+
+/* Set the owner of TX context descriptor */
+static void xgmac_set_tx_ctxt_owner(struct xgmac_tx_ctxt_desc *p)
+{
+	p->own_bit = 1;
+}
+
+/* Get the owner of TX context descriptor */
+static int xgmac_get_tx_ctxt_owner(struct xgmac_tx_ctxt_desc *p)
+{
+	return p->own_bit;
+}
+
+/* Set TX mss in TX context Descriptor */
+static void xgmac_tx_ctxt_desc_setmss(struct xgmac_tx_ctxt_desc *p, int mss)
+{
+	p->maxseg_size = mss;
+}
+
+/* Get TX mss from TX context Descriptor */
+static int xgmac_tx_ctxt_desc_getmss(struct xgmac_tx_ctxt_desc *p)
+{
+	return p->maxseg_size;
+}
+
+/* Set IVLAN information */
+static void xgmac_tx_ctxt_desc_set_ivlantag(struct xgmac_tx_ctxt_desc *p,
+				     int is_ivlanvalid, int ivlan_tag,
+				     int ivlan_ctl)
+{
+	if (is_ivlanvalid) {
+		p->ivlan_tag_valid = is_ivlanvalid;
+		p->ivlan_tag = ivlan_tag;
+		p->ivlan_tag_ctl = ivlan_ctl;
+	}
+}
+
+/* Return IVLAN Tag */
+static int xgmac_tx_ctxt_desc_get_ivlantag(struct xgmac_tx_ctxt_desc *p)
+{
+	return p->ivlan_tag;
+}
+
+/* Set VLAN Tag */
+static void xgmac_tx_ctxt_desc_set_vlantag(struct xgmac_tx_ctxt_desc *p,
+					int is_vlanvalid, int vlan_tag)
+{
+	if (is_vlanvalid) {
+		p->vltag_valid = is_vlanvalid;
+		p->vlan_tag = vlan_tag;
+	}
+}
+
+/* Return VLAN Tag */
+static int xgmac_tx_ctxt_desc_get_vlantag(struct xgmac_tx_ctxt_desc *p)
+{
+	return p->vlan_tag;
+}
+
+/* Set Time stamp */
+static void xgmac_tx_ctxt_desc_set_tstamp(struct xgmac_tx_ctxt_desc *p,
+					 u8 ostc_enable, u64 tstamp)
+{
+	if (ostc_enable) {
+		p->ostc = ostc_enable;
+		p->tstamp_lo = (u32) tstamp;
+		p->tstamp_hi = (u32) (tstamp>>32);
+	}
+
+}
+/* Close TX context descriptor */
+static void xgmac_close_tx_ctxt_desc(struct xgmac_tx_ctxt_desc *p)
+{
+	p->own_bit = 1;
+}
+
+/* WB status of context descriptor */
+static int xgmac_get_tx_ctxt_cde(struct xgmac_tx_ctxt_desc *p)
+{
+	return p->ctxt_desc_err;
+}
+
+/* DMA RX descriptor ring initialization */
+static void xgmac_init_rx_desc(struct xgmac_rx_norm_desc *p, int disable_rx_ic,
+			int mode, int end)
+{
+	p->rdes23.rx_rd_des23.own_bit = 1;
+	if (disable_rx_ic)
+		p->rdes23.rx_rd_des23.int_on_com = disable_rx_ic;
+
+}
+
+/* Get RX own bit */
+static int xgmac_get_rx_owner(struct xgmac_rx_norm_desc *p)
+{
+	return p->rdes23.rx_rd_des23.own_bit;
+}
+
+/* Set RX own bit */
+static void xgmac_set_rx_owner(struct xgmac_rx_norm_desc *p)
+{
+	p->rdes23.rx_rd_des23.own_bit = 1;
+}
+
+/* Get the receive frame size */
+static int xgmac_get_rx_frame_len(struct xgmac_rx_norm_desc *p)
+{
+	return p->rdes23.rx_wb_des23.pkt_len;
+}
+
+/* Return first Descriptor status */
+static int xgmac_get_rx_fd_status(struct xgmac_rx_norm_desc *p)
+{
+	return p->rdes23.rx_wb_des23.first_desc;
+}
+
+/* Return Last Descriptor status */
+static int xgmac_get_rx_ld_status(struct xgmac_rx_norm_desc *p)
+{
+	return p->rdes23.rx_wb_des23.last_desc;
+}
+
+
+/* Return the RX status looking at the WB fields */
+static void xgmac_rx_wbstatus(struct xgmac_rx_norm_desc *p,
+			struct xgmac_extra_stats *x)
+{
+
+	if (p->rdes23.rx_wb_des23.err_summary) {
+		switch (p->rdes23.rx_wb_des23.err_l2_type) {
+		case RX_GMII_ERR:
+			x->rx_code_gmii_err++;
+			break;
+		case RX_WATCHDOG_ERR:
+			x->rx_watchdog_err++;
+			break;
+		case RX_CRC_ERR:
+			x->rx_crc_err++;
+			break;
+		case RX_GAINT_ERR:
+			x->rx_gaint_pkt_err++;
+			break;
+		case RX_IP_HDR_ERR:
+			x->ip_hdr_err++;
+			break;
+		case RX_PAYLOAD_ERR:
+			x->ip_payload_err++;
+			break;
+		case RX_OVERFLOW_ERR:
+			x->overflow_error++;
+			break;
+		default:
+			pr_err("\tInvalid Error type\n");
+			break;
+		}
+	} else {
+		switch (p->rdes23.rx_wb_des23.err_l2_type) {
+		case RX_LEN_PKT:
+			x->len_pkt++;
+			break;
+		case RX_MACCTL_PKT:
+			x->mac_ctl_pkt++;
+			break;
+		case RX_DCBCTL_PKT:
+			x->dcb_ctl_pkt++;
+			break;
+		case RX_ARP_PKT:
+			x->arp_pkt++;
+			break;
+		case RX_OAM_PKT:
+			x->oam_pkt++;
+			break;
+		case RX_UNTAG_PKT:
+			x->untag_okt++;
+			break;
+		case RX_OTHER_PKT:
+			x->other_pkt++;
+			break;
+		case RX_SVLAN_PKT:
+			x->svlan_tag_pkt++;
+			break;
+		case RX_CVLAN_PKT:
+			x->cvlan_tag_pkt++;
+			break;
+		case RX_DVLAN_OCVLAN_ICVLAN_PKT:
+			x->dvlan_ocvlan_icvlan_pkt++;
+			break;
+		case RX_DVLAN_OSVLAN_ISVLAN_PKT:
+			x->dvlan_osvlan_isvlan_pkt++;
+			break;
+		case RX_DVLAN_OSVLAN_ICVLAN_PKT:
+			x->dvlan_osvlan_icvlan_pkt++;
+			break;
+		case RX_DVLAN_OCVLAN_ISVLAN_PKT:
+			x->dvlan_ocvlan_icvlan_pkt++;
+			break;
+		default:
+			pr_err("\tInvalid L2 Packet type\n");
+			break;
+		}
+
+	}
+
+	/* L3/L4 Pkt type */
+	switch (p->rdes23.rx_wb_des23.layer34_pkt_type) {
+	case RX_NOT_IP_PKT:
+		x->not_ip_pkt++;
+		break;
+	case RX_IPV4_TCP_PKT:
+		x->ip4_tcp_pkt++;
+		break;
+	case RX_IPV4_UDP_PKT:
+		x->ip4_udp_pkt++;
+		break;
+	case RX_IPV4_ICMP_PKT:
+		x->ip4_icmp_pkt++;
+		break;
+	case RX_IPV4_UNKNOWN_PKT:
+		x->ip4_unknown_pkt++;
+		break;
+	case RX_IPV6_TCP_PKT:
+		x->ip6_tcp_pkt++;
+		break;
+	case RX_IPV6_UDP_PKT:
+		x->ip6_udp_pkt++;
+		break;
+	case RX_IPV6_ICMP_PKT:
+		x->ip6_icmp_pkt++;
+		break;
+	case RX_IPV6_UNKNOWN_PKT:
+		x->ip6_unknown_pkt++;
+		break;
+	default:
+		pr_err("\tInvalid L3/L4 Packet type\n");
+		break;
+	}
+
+	/* Filter */
+	if (p->rdes23.rx_wb_des23.vlan_filter_match)
+		x->vlan_filter_match++;
+
+	if (p->rdes23.rx_wb_des23.sa_filter_fail)
+		x->sa_filter_fail++;
+
+	if (p->rdes23.rx_wb_des23.da_filter_fail)
+		x->da_filter_fail++;
+
+	if (p->rdes23.rx_wb_des23.hash_filter_pass)
+		x->hash_filter_pass++;
+
+	if (p->rdes23.rx_wb_des23.l3_filter_match)
+		x->l3_filter_match++;
+
+	if (p->rdes23.rx_wb_des23.l4_filter_match)
+		x->l4_filter_match++;
+
+}
+
+/* Get own bit of context descriptor */
+static int xgmac_get_rx_ctxt_owner(struct xgmac_rx_ctxt_desc *p)
+{
+	return p->own_bit;
+}
+
+/* Set own bit for context descriptor */
+static void xgmac_set_ctxt_rx_owner(struct xgmac_rx_ctxt_desc *p)
+{
+	p->own_bit = 1;
+}
+
+
+/* Return the reception status looking at Context control information */
+static void xgmac_rx_ctxt_wbstatus(struct xgmac_rx_ctxt_desc *p,
+				struct xgmac_extra_stats *x)
+{
+	if (p->tstamp_dropped)
+		x->timestamp_dropped++;
+
+	/* ptp */
+	if (p->ptp_msgtype == RX_NO_PTP)
+		x->rx_msg_type_no_ptp++;
+	else if (p->ptp_msgtype == RX_PTP_SYNC)
+		x->rx_ptp_type_sync++;
+	else if (p->ptp_msgtype == RX_PTP_FOLLOW_UP)
+		x->rx_ptp_type_follow_up++;
+	else if (p->ptp_msgtype == RX_PTP_DELAY_REQ)
+		x->rx_ptp_type_delay_req++;
+	else if (p->ptp_msgtype == RX_PTP_DELAY_RESP)
+		x->rx_ptp_type_delay_resp++;
+	else if (p->ptp_msgtype == RX_PTP_PDELAY_REQ)
+		x->rx_ptp_type_pdelay_req++;
+	else if (p->ptp_msgtype == RX_PTP_PDELAY_RESP)
+		x->rx_ptp_type_pdelay_resp++;
+	else if (p->ptp_msgtype == RX_PTP_PDELAY_FOLLOW_UP)
+		x->rx_ptp_type_pdelay_follow_up++;
+	else if (p->ptp_msgtype == RX_PTP_ANNOUNCE)
+		x->rx_ptp_announce++;
+	else if (p->ptp_msgtype == RX_PTP_MGMT)
+		x->rx_ptp_mgmt++;
+	else if (p->ptp_msgtype == RX_PTP_SIGNAL)
+		x->rx_ptp_signal++;
+	else if (p->ptp_msgtype == RX_PTP_RESV_MSG)
+		x->rx_ptp_resv_msg_type++;
+
+}
+
+/* get rx timestamp status */
+static int xgmac_get_rx_ctxt_tstamp_status(struct xgmac_rx_ctxt_desc *p)
+{
+	if ((p->tstamp_hi == 0xffffffff) && (p->tstamp_lo == 0xffffffff)) {
+		pr_err("\tTime stamp corrupted\n");
+		return 0;
+	}
+
+	return p->tstamp_available;
+}
+
+
+static u64 xgmac_get_rx_timestamp(struct xgmac_rx_ctxt_desc *p)
+{
+	u64 ns;
+	ns = p->tstamp_lo;
+	ns += p->tstamp_hi * 1000000000ULL;
+
+	return ns;
+}
+
+static const struct xgmac_desc_ops desc_ops = {
+	.init_tx_desc = xgmac_init_tx_desc,
+	.prepare_tx_desc = xgmac_prepare_tx_desc,
+	.tx_vlanctl_desc = xgmac_tx_vlanctl_desc,
+	.set_tx_owner = xgmac_set_tx_owner,
+	.get_tx_owner = xgmac_get_tx_owner,
+	.close_tx_desc = xgmac_close_tx_desc,
+	.release_tx_desc = xgmac_release_tx_desc,
+	.clear_tx_ic = xgmac_clear_tx_ic,
+	.get_tx_ls = xgmac_get_tx_ls,
+	.get_tx_len = xgmac_get_tx_len,
+	.tx_enable_tstamp = xgmac_tx_enable_tstamp,
+	.get_tx_timestamp_status = xgmac_get_tx_timestamp_status,
+	.tx_ctxt_desc_set_ivlantag = xgmac_tx_ctxt_desc_set_ivlantag,
+	.tx_ctxt_desc_get_ivlantag = xgmac_tx_ctxt_desc_get_ivlantag,
+	.tx_ctxt_desc_set_vlantag = xgmac_tx_ctxt_desc_set_vlantag,
+	.tx_ctxt_desc_get_vlantag = xgmac_tx_ctxt_desc_get_vlantag,
+	.tx_ctxt_set_tstamp = xgmac_tx_ctxt_desc_set_tstamp,
+	.init_rx_desc = xgmac_init_rx_desc,
+	.get_rx_owner = xgmac_get_rx_owner,
+	.set_rx_owner = xgmac_set_rx_owner,
+	.get_rx_frame_len = xgmac_get_rx_frame_len,
+	.get_rx_fd_status = xgmac_get_rx_fd_status,
+	.get_rx_ld_status = xgmac_get_rx_ld_status,
+	.rx_wbstatus = xgmac_rx_wbstatus,
+	.get_rx_ctxt_owner = xgmac_get_rx_ctxt_owner,
+	.set_rx_ctxt_owner = xgmac_set_ctxt_rx_owner,
+	.rx_ctxt_wbstatus = xgmac_rx_ctxt_wbstatus,
+	.get_rx_ctxt_tstamp_status = xgmac_get_rx_ctxt_tstamp_status,
+	.get_timestamp = xgmac_get_rx_timestamp,
+};
+
+const struct xgmac_desc_ops *xgmac_get_desc_ops(void)
+{
+	return &desc_ops;
+}
diff --git a/drivers/net/ethernet/samsung/xgmac_desc.h b/drivers/net/ethernet/samsung/xgmac_desc.h
new file mode 100644
index 0000000..4f20283
--- /dev/null
+++ b/drivers/net/ethernet/samsung/xgmac_desc.h
@@ -0,0 +1,291 @@
+/* 10G controller driver for Samsung SoCs
+ *
+ * Copyright (C) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ *
+ * Author: Siva Reddy Kallam <siva.kallam@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#ifndef __XGMAC_DESC_H__
+#define __XGMAC_DESC_H__
+
+#define XGMAC_DESC_SIZE_BYTES	16
+
+/* forward declatarion */
+struct xgmac_extra_stats;
+
+/* Transmit checksum insertion control */
+enum tdes_csum_insertion {
+	cic_disabled = 0,	/* Checksum Insertion Control */
+	cic_only_ip = 1,	/* Only IP header */
+	/* IP header but pseudoheader is not calculated */
+	cic_no_pseudoheader = 2,
+	cic_full = 3,		/* IP header and pseudoheader */
+};
+
+struct xgmac_tx_norm_desc {
+	u64 tdes01; /* buf1 address */
+	union {
+		/* TX Read-Format Desc 2,3 */
+		struct {
+			/* TDES2 */
+			u32 buf1_size:14;
+			u32 vlan_tag_ctl:2;
+			u32 buf2_size:14;
+			u32 timestmp_enable:1;
+			u32 int_on_com:1;
+			/* TDES3 */
+			union {
+				u32 tcp_payload_len:18;
+				struct {
+					u32 total_pkt_len:15;
+					u32 reserved1:1;
+					u32 cksum_ctl:2;
+				} cksum_pktlen;
+			} tx_pkt_len;
+
+			u32 tse_bit:1;
+			u32 tcp_hdr_len:4;
+			u32 sa_insert_ctl:3;
+			u32 crc_pad_ctl:2;
+			u32 last_desc:1;
+			u32 first_desc:1;
+			u32 ctxt_bit:1;
+			u32 own_bit:1;
+		} tx_rd_des23;
+
+		/* tx write back Desc 2,3 */
+		struct {
+			/* WB TES2 */
+			u32 reserved1:32;
+			/* WB TES3 */
+			u32 reserved2:31;
+			u32 own_bit:1;
+		} tx_wb_des23;
+	} tdes23;
+};
+
+struct xgmac_rx_norm_desc {
+	union {
+		u32 rdes0; /* buf1 address */
+		struct {
+			u32 out_vlan_tag:16;
+			u32 in_vlan_tag:16;
+		} wb_rx_des0;
+	} rd_wb_des0;
+
+	union {
+		u32 rdes1;	/* buf2 address or buf1[63:32] */
+		u32 rss_hash;	/* Write-back RX */
+	} rd_wb_des1;
+
+	union {
+		/* RX Read format Desc 2,3 */
+		struct{
+			/* RDES2 */
+			u32 buf2_addr:32;
+			/* RDES3 */
+			u32 buf2_hi_addr:30;
+			u32 int_on_com:1;
+			u32 own_bit:1;
+		} rx_rd_des23;
+
+		/* RX write back */
+		struct{
+			/* WB RDES2 */
+			u32 hdr_len:10;
+			u32 rdes2_reserved:2;
+			u32 elrd_val:1;
+			u32 iovt_sel:1;
+			u32 res_pkt:1;
+			u32 vlan_filter_match:1;
+			u32 sa_filter_fail:1;
+			u32 da_filter_fail:1;
+			u32 hash_filter_pass:1;
+			u32 macaddr_filter_match:8;
+			u32 l3_filter_match:1;
+			u32 l4_filter_match:1;
+			u32 l34_filter_num:3;
+
+			/* WB RDES3 */
+			u32 pkt_len:14;
+			u32 rdes3_reserved:1;
+			u32 err_summary:15;
+			u32 err_l2_type:4;
+			u32 layer34_pkt_type:4;
+			u32 no_coagulation_pkt:1;
+			u32 in_seq_pkt:1;
+			u32 rss_valid:1;
+			u32 context_des_avail:1;
+			u32 last_desc:1;
+			u32 first_desc:1;
+			u32 recv_context_desc:1;
+			u32 own_bit:1;
+		} rx_wb_des23;
+	 } rdes23;
+};
+
+/* Context descriptor structure */
+struct xgmac_tx_ctxt_desc {
+	u32 tstamp_lo:32;
+	u32 tstamp_hi:32;
+	u32 maxseg_size:15;
+	u32 reserved1:1;
+	u32 ivlan_tag:16;
+	u32 vlan_tag:16;
+	u32 vltag_valid:1;
+	u32 ivlan_tag_valid:1;
+	u32 ivlan_tag_ctl:2;
+	u32 reserved2:3;
+	u32 ctxt_desc_err:1;
+	u32 reserved3:2;
+	u32 ostc:1;
+	u32 tcmssv:1;
+	u32 reserved4:2;
+	u32 ctxt_bit:1;
+	u32 own_bit:1;
+};
+
+struct xgmac_rx_ctxt_desc {
+	u32 tstamp_lo:32;
+	u32 tstamp_hi:32;
+	u32 reserved1:32;
+	u32 ptp_msgtype:4;
+	u32 tstamp_available:1;
+	u32 ptp_rsp_err:1;
+	u32 tstamp_dropped:1;
+	u32 reserved2:23;
+	u32 rx_ctxt_desc:1;
+	u32 own_bit:1;
+};
+
+struct xgmac_desc_ops {
+	/* DMA TX descriptor ring initialization */
+	void (*init_tx_desc)(struct xgmac_tx_norm_desc *p);
+
+	/* Invoked by the xmit function to prepare the tx descriptor */
+	void (*tx_enable_tse)(struct xgmac_tx_norm_desc *p, u8 is_tse,
+				u32 hdr_len, u32 payload_len);
+
+	/* Assign buffer lengths for descriptor */
+	void (*prepare_tx_desc)(struct xgmac_tx_norm_desc *p, u8 is_fd,
+				 int buf1_len, int pkt_len);
+
+	/* Set VLAN control information */
+	void (*tx_vlanctl_desc)(struct xgmac_tx_norm_desc *p, int vlan_ctl);
+
+	/* Set the owner of the descriptor */
+	void (*set_tx_owner)(struct xgmac_tx_norm_desc *p);
+
+	/* Get the owner of the descriptor */
+	int (*get_tx_owner)(struct xgmac_tx_norm_desc *p);
+
+	/* Invoked by the xmit function to close the tx descriptor */
+	void (*close_tx_desc)(struct xgmac_tx_norm_desc *p);
+
+	/* Clean the tx descriptor as soon as the tx irq is received */
+	void (*release_tx_desc)(struct xgmac_tx_norm_desc *p);
+
+	/* Clear interrupt on tx frame completion. When this bit is
+	 * set an interrupt happens as soon as the frame is transmitted
+	 */
+	void (*clear_tx_ic)(struct xgmac_tx_norm_desc *p);
+
+	/* Last tx segment reports the transmit status */
+	int (*get_tx_ls)(struct xgmac_tx_norm_desc *p);
+
+	/* Get the buffer size from the descriptor */
+	int (*get_tx_len)(struct xgmac_tx_norm_desc *p);
+
+	/* Set tx timestamp enable bit */
+	void (*tx_enable_tstamp)(struct xgmac_tx_norm_desc *p);
+
+	/* get tx timestamp status */
+	int (*get_tx_timestamp_status)(struct xgmac_tx_norm_desc *p);
+
+	/* TX Context Descripto Specific */
+	void (*init_tx_ctxt_desc)(struct xgmac_tx_ctxt_desc *p);
+
+	/* Set the owner of the TX context descriptor */
+	void (*set_tx_ctxt_owner)(struct xgmac_tx_ctxt_desc *p);
+
+	/* Get the owner of the TX context descriptor */
+	int (*get_tx_ctxt_owner)(struct xgmac_tx_ctxt_desc *p);
+
+	/* Set TX mss */
+	void (*tx_ctxt_desc_setmss)(struct xgmac_tx_ctxt_desc *p, int mss);
+
+	/* Set TX mss */
+	int (*tx_ctxt_desc_get_mss)(struct xgmac_tx_ctxt_desc *p);
+
+	/* Set IVLAN information */
+	void (*tx_ctxt_desc_set_ivlantag)(struct xgmac_tx_ctxt_desc *p,
+					int is_ivlanvalid, int ivlan_tag,
+					int ivlan_ctl);
+
+	/* Return IVLAN Tag */
+	int (*tx_ctxt_desc_get_ivlantag)(struct xgmac_tx_ctxt_desc *p);
+
+	/* Set VLAN Tag */
+	void (*tx_ctxt_desc_set_vlantag)(struct xgmac_tx_ctxt_desc *p,
+					int is_vlanvalid, int vlan_tag);
+
+	/* Return VLAN Tag */
+	int (*tx_ctxt_desc_get_vlantag)(struct xgmac_tx_ctxt_desc *p);
+
+	/* Set Time stamp */
+	void (*tx_ctxt_set_tstamp)(struct xgmac_tx_ctxt_desc *p,
+					u8 ostc_enable, u64 tstamp);
+
+	/* Close TX context descriptor */
+	void (*close_tx_ctxt_desc)(struct xgmac_tx_ctxt_desc *p);
+
+	/* WB status of context descriptor */
+	int (*get_tx_ctxt_cde)(struct xgmac_tx_ctxt_desc *p);
+
+	/* DMA RX descriptor ring initialization */
+	void (*init_rx_desc)(struct xgmac_rx_norm_desc *p, int disable_rx_ic,
+				int mode, int end);
+
+	/* Get own bit */
+	int (*get_rx_owner)(struct xgmac_rx_norm_desc *p);
+
+	/* Set own bit */
+	void (*set_rx_owner)(struct xgmac_rx_norm_desc *p);
+
+	/* Get the receive frame size */
+	int (*get_rx_frame_len)(struct xgmac_rx_norm_desc *p);
+
+	/* Return first Descriptor status */
+	int (*get_rx_fd_status)(struct xgmac_rx_norm_desc *p);
+
+	/* Return first Descriptor status */
+	int (*get_rx_ld_status)(struct xgmac_rx_norm_desc *p);
+
+	/* Return the reception status looking at the RDES1 */
+	void (*rx_wbstatus)(struct xgmac_rx_norm_desc *p,
+				struct xgmac_extra_stats *x);
+
+	/* Get own bit */
+	int (*get_rx_ctxt_owner)(struct xgmac_rx_ctxt_desc *p);
+
+	/* Set own bit */
+	void (*set_rx_ctxt_owner)(struct xgmac_rx_ctxt_desc *p);
+
+	/* Return the reception status looking at Context control information */
+	void (*rx_ctxt_wbstatus)(struct xgmac_rx_ctxt_desc *p,
+				 struct xgmac_extra_stats *x);
+
+	/* Get rx timestamp status */
+	int (*get_rx_ctxt_tstamp_status)(struct xgmac_rx_ctxt_desc *p);
+
+	/* Get timestamp value for rx, need to check this */
+	u64 (*get_timestamp)(struct xgmac_rx_ctxt_desc *p);
+};
+
+const struct xgmac_desc_ops *xgmac_get_desc_ops(void);
+
+#endif /* __XGMAC_DESC_H__ */
diff --git a/drivers/net/ethernet/samsung/xgmac_dma.c b/drivers/net/ethernet/samsung/xgmac_dma.c
new file mode 100644
index 0000000..c28d90c
--- /dev/null
+++ b/drivers/net/ethernet/samsung/xgmac_dma.c
@@ -0,0 +1,371 @@
+/* 10G controller driver for Samsung SoCs
+ *
+ * Copyright (C) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ *
+ * Author: Siva Reddy Kallam <siva.kallam@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#include <linux/io.h>
+#include <linux/delay.h>
+#include <linux/export.h>
+#include <linux/io.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+
+#include "xgmac_common.h"
+#include "xgmac_dma.h"
+#include "xgmac_reg.h"
+#include "xgmac_desc.h"
+/* DMA core initialization */
+static int xgmac_dma_init(void __iomem *ioaddr, int fix_burst,
+			     int burst_map, int adv_addr_mode)
+{
+	int retry_count = 10;
+	u32 reg_val;
+
+	/* reset the DMA */
+	writel(XGMAC_DMA_SOFT_RESET, ioaddr + XGMAC_DMA_MODE_REG);
+	while (retry_count--) {
+		if (!(readl(ioaddr + XGMAC_DMA_MODE_REG) &
+			XGMAC_DMA_SOFT_RESET))
+			break;
+		mdelay(10);
+	}
+
+	if (retry_count < 0)
+		return -EBUSY;
+
+	reg_val = readl(ioaddr + XGMAC_DMA_SYSBUS_MODE_REG);
+
+	/* if fix_burst = 0, Set UNDEF = 1 of DMA_Sys_Mode Register.
+	 * if fix_burst = 1, Set UNDEF = 0 of DMA_Sys_Mode Register.
+	 * burst_map is bitmap for  BLEN[4, 8, 16, 32, 64, 128 and 256].
+	 * Set burst_map irrespective of fix_burst value.
+	 */
+	if (!fix_burst)
+		reg_val |= XGMAC_DMA_AXI_UNDEF_BURST;
+
+	/* enable adavnced address mode */
+	if (adv_addr_mode)
+		reg_val |= XGMAC_DMA_ENHACE_ADDR_MODE;
+
+	/* write burst len map */
+	reg_val |= (burst_map << XGMAC_DMA_BLENMAP_LSHIFT);
+
+	writel(reg_val,	ioaddr + XGMAC_DMA_SYSBUS_MODE_REG);
+
+	return 0;
+}
+
+static void xgmac_dma_channel_init(void __iomem *ioaddr, int cha_num,
+				int fix_burst, int pbl, dma_addr_t dma_tx,
+				dma_addr_t dma_rx, int t_rsize, int r_rsize)
+{
+	u32 reg_val;
+	dma_addr_t dma_addr;
+
+	reg_val = readl(ioaddr + XGMAC_DMA_CHA_CTL_REG(cha_num));
+	/* set the pbl */
+	if (fix_burst) {
+		reg_val |= XGMAC_DMA_PBL_X8MODE;
+		writel(reg_val, ioaddr + XGMAC_DMA_CHA_CTL_REG(cha_num));
+		/* program the TX pbl */
+		reg_val = readl(ioaddr + XGMAC_DMA_CHA_TXCTL_REG(cha_num));
+		reg_val |= (pbl << XGMAC_DMA_TXPBL_LSHIFT);
+		writel(reg_val, ioaddr + XGMAC_DMA_CHA_TXCTL_REG(cha_num));
+		/* program the RX pbl */
+		reg_val = readl(ioaddr + XGMAC_DMA_CHA_RXCTL_REG(cha_num));
+		reg_val |= (pbl << XGMAC_DMA_RXPBL_LSHIFT);
+		writel(reg_val, ioaddr + XGMAC_DMA_CHA_RXCTL_REG(cha_num));
+	}
+
+	/* program desc registers */
+	writel((dma_tx >> 32),
+			ioaddr + XGMAC_DMA_CHA_TXDESC_HADD_REG(cha_num));
+	writel((dma_tx & 0xFFFFFFFF),
+			ioaddr + XGMAC_DMA_CHA_TXDESC_LADD_REG(cha_num));
+
+	writel((dma_rx >> 32),
+			ioaddr + XGMAC_DMA_CHA_RXDESC_HADD_REG(cha_num));
+	writel((dma_rx & 0xFFFFFFFF),
+			ioaddr + XGMAC_DMA_CHA_RXDESC_LADD_REG(cha_num));
+
+	/* program tail pointers */
+	/* assumption: upper 32 bits are constant and
+	 * same as TX/RX desc list
+	 */
+	dma_addr = dma_tx + ((t_rsize-1) * XGMAC_DESC_SIZE_BYTES);
+	writel((dma_addr & 0xFFFFFFFF),
+			ioaddr + XGMAC_DMA_CHA_TXDESC_TAILPTR_REG(cha_num));
+
+	dma_addr = dma_rx + ((r_rsize-1) * XGMAC_DESC_SIZE_BYTES);
+	writel((dma_addr & 0xFFFFFFFF),
+			ioaddr + XGMAC_DMA_CHA_RXDESC_LADD_REG(cha_num));
+	/* program the ring sizes */
+	writel(t_rsize-1, ioaddr + XGMAC_DMA_CHA_TXDESC_RINGLEN_REG(cha_num));
+	writel(r_rsize-1, ioaddr + XGMAC_DMA_CHA_RXDESC_RINGLEN_REG(cha_num));
+
+	/* Enable TX/RX interrupts */
+	writel(XGMAC_DMA_ENA_INT,
+			ioaddr + XGMAC_DMA_CHA_INT_ENABLE_REG(cha_num));
+}
+
+static void xgmac_enable_dma_transmission(void __iomem *ioaddr, int cha_num)
+{
+	u32 tx_config;
+	tx_config = readl(ioaddr + XGMAC_DMA_CHA_TXCTL_REG(cha_num));
+	tx_config |= XGMAC_TX_START_DMA;
+	writel(tx_config, ioaddr + XGMAC_DMA_CHA_TXCTL_REG(cha_num));
+}
+
+static void xgmac_enable_dma_irq(void __iomem *ioaddr, int dma_cnum)
+{
+	/* Enable TX/RX interrupts */
+	writel(XGMAC_DMA_ENA_INT,
+			ioaddr + XGMAC_DMA_CHA_INT_ENABLE_REG(dma_cnum));
+}
+
+static void xgmac_disable_dma_irq(void __iomem *ioaddr, int dma_cnum)
+{
+	/* Disable TX/RX interrupts */
+	writel(0, ioaddr + XGMAC_DMA_CHA_INT_ENABLE_REG(dma_cnum));
+}
+
+static void xgmac_dma_start_tx(void __iomem *ioaddr, int tchannels)
+{
+	int cnum;
+	u32 tx_ctl_reg;
+
+	for (cnum = 0; cnum < tchannels; cnum++) {
+		tx_ctl_reg = readl(ioaddr + XGMAC_DMA_CHA_TXCTL_REG(cnum));
+		tx_ctl_reg |= XGMAC_TX_ENABLE;
+		writel(tx_ctl_reg,
+			ioaddr + XGMAC_DMA_CHA_TXCTL_REG(cnum));
+	}
+}
+
+static void xgmac_dma_start_tx_queue(void __iomem *ioaddr, int dma_cnum)
+{
+	u32 tx_ctl_reg;
+
+	tx_ctl_reg = readl(ioaddr + XGMAC_DMA_CHA_TXCTL_REG(dma_cnum));
+	tx_ctl_reg |= XGMAC_TX_ENABLE;
+	writel(tx_ctl_reg, ioaddr + XGMAC_DMA_CHA_TXCTL_REG(dma_cnum));
+}
+
+static void xgmac_dma_stop_tx_queue(void __iomem *ioaddr, int dma_cnum)
+{
+	u32 tx_ctl_reg;
+
+	tx_ctl_reg = readl(ioaddr + XGMAC_DMA_CHA_TXCTL_REG(dma_cnum));
+	tx_ctl_reg &= ~(XGMAC_TX_ENABLE);
+	writel(tx_ctl_reg, ioaddr + XGMAC_DMA_CHA_TXCTL_REG(dma_cnum));
+}
+
+static void xgmac_dma_stop_tx(void __iomem *ioaddr, int tchannels)
+{
+	int cnum;
+	u32 tx_ctl_reg;
+
+	for (cnum = 0; cnum < tchannels; cnum++) {
+		tx_ctl_reg = readl(ioaddr + XGMAC_DMA_CHA_TXCTL_REG(cnum));
+		tx_ctl_reg &= ~(XGMAC_TX_ENABLE);
+		writel(tx_ctl_reg, ioaddr + XGMAC_DMA_CHA_TXCTL_REG(cnum));
+	}
+}
+
+static void xgmac_dma_start_rx(void __iomem *ioaddr, int rchannels)
+{
+	int cnum;
+	u32 rx_ctl_reg;
+
+	for (cnum = 0; cnum < rchannels; cnum++) {
+		rx_ctl_reg = readl(ioaddr + XGMAC_DMA_CHA_RXCTL_REG(cnum));
+		rx_ctl_reg |= XGMAC_RX_ENABLE;
+		writel(rx_ctl_reg,
+			ioaddr + XGMAC_DMA_CHA_RXCTL_REG(cnum));
+	}
+}
+
+static void xgmac_dma_stop_rx(void __iomem *ioaddr, int rchannels)
+{
+	int cnum;
+	u32 rx_ctl_reg;
+
+	for (cnum = 0; cnum < rchannels; cnum++) {
+		rx_ctl_reg = readl(ioaddr + XGMAC_DMA_CHA_RXCTL_REG(cnum));
+		rx_ctl_reg &= ~(XGMAC_RX_ENABLE);
+		writel(rx_ctl_reg, ioaddr + XGMAC_DMA_CHA_RXCTL_REG(cnum));
+	}
+}
+
+static int xgmac_tx_dma_int_status(void __iomem *ioaddr, int channel_no,
+			      struct xgmac_extra_stats *x)
+{
+	u32 int_status = readl(ioaddr + XGMAC_DMA_CHA_STATUS_REG(channel_no));
+	u32 clear_val = 0;
+	u32 ret_val = 0;
+
+	/* TX Normal Interrupt Summary */
+	if (likely(int_status & XGMAC_DMA_INT_STATUS_NIS)) {
+		x->normal_irq_n++;
+		if (int_status & XGMAC_DMA_INT_STATUS_TI) {
+			ret_val |= handle_tx;
+			x->tx_normal_irq_n++;
+			clear_val |= XGMAC_DMA_INT_STATUS_TI;
+		}
+
+		if (int_status & XGMAC_DMA_INT_STATUS_TBU) {
+			x->tx_underflow_irq++;
+			ret_val |= tx_bump_tc;
+			clear_val |= XGMAC_DMA_INT_STATUS_TBU;
+		}
+	} else if (unlikely(int_status & XGMAC_DMA_INT_STATUS_AIS)) {
+		/* TX Abnormal Interrupt Summary */
+		if (int_status & XGMAC_DMA_INT_STATUS_TPS) {
+			ret_val |= tx_hard_error;
+			clear_val |= XGMAC_DMA_INT_STATUS_TPS;
+			x->tx_process_stopped_irq++;
+		}
+
+		if (int_status & XGMAC_DMA_INT_STATUS_FBE) {
+			ret_val |= tx_hard_error;
+			x->fatal_bus_error_irq++;
+
+			/* Assumption: FBE bit is the combination of
+			 * all the bus access erros and cleared when
+			 * the respective error bits cleared
+			 */
+
+			/* check for actual cause */
+			if (int_status & XGMAC_DMA_INT_STATUS_TEB0) {
+				x->tx_read_transfer_err++;
+				clear_val |= XGMAC_DMA_INT_STATUS_TEB0;
+			} else
+				x->tx_write_transfer_err++;
+
+			if (int_status & XGMAC_DMA_INT_STATUS_TEB1) {
+				x->tx_desc_access_err++;
+				clear_val |= XGMAC_DMA_INT_STATUS_TEB1;
+			} else
+				 x->tx_buffer_access_err++;
+
+			if (int_status & XGMAC_DMA_INT_STATUS_TEB2) {
+				x->tx_data_transfer_err++;
+				clear_val |= XGMAC_DMA_INT_STATUS_TEB2;
+			}
+		}
+
+		/* context descriptor error */
+		if (int_status & XGMAC_DMA_INT_STATUS_CTXTERR) {
+			x->tx_ctxt_desc_err++;
+			clear_val |= XGMAC_DMA_INT_STATUS_CTXTERR;
+		}
+	}
+
+	/* clear the served bits */
+	writel(clear_val, ioaddr + XGMAC_DMA_CHA_STATUS_REG(channel_no));
+
+	return ret_val;
+}
+
+static int xgmac_rx_dma_int_status(void __iomem *ioaddr, int channel_no,
+			      struct xgmac_extra_stats *x)
+{
+	u32 int_status = readl(ioaddr + XGMAC_DMA_CHA_STATUS_REG(channel_no));
+	u32 clear_val = 0;
+	u32 ret_val = 0;
+
+	/* RX Normal Interrupt Summary */
+	if (likely(int_status & XGMAC_DMA_INT_STATUS_NIS)) {
+		x->normal_irq_n++;
+		if (int_status & XGMAC_DMA_INT_STATUS_RI) {
+			ret_val |= handle_rx;
+			x->rx_normal_irq_n++;
+			clear_val |= XGMAC_DMA_INT_STATUS_RI;
+		}
+	} else if (unlikely(int_status & XGMAC_DMA_INT_STATUS_AIS)) {
+		/* RX Abnormal Interrupt Summary */
+		if (int_status & XGMAC_DMA_INT_STATUS_RBU) {
+			ret_val |= rx_bump_tc;
+			clear_val |= XGMAC_DMA_INT_STATUS_RBU;
+			x->rx_underflow_irq++;
+		}
+
+		if (int_status & XGMAC_DMA_INT_STATUS_RPS) {
+			ret_val |= rx_hard_error;
+			clear_val |= XGMAC_DMA_INT_STATUS_RPS;
+			x->rx_process_stopped_irq++;
+		}
+
+		if (int_status & XGMAC_DMA_INT_STATUS_FBE) {
+			ret_val |= rx_hard_error;
+			x->fatal_bus_error_irq++;
+
+			/* Assumption: FBE bit is the combination of
+			 * all the bus access erros and cleared when
+			 * the respective error bits cleared
+			 */
+
+			/* check for actual cause */
+			if (int_status & XGMAC_DMA_INT_STATUS_REB0) {
+				x->rx_read_transfer_err++;
+				clear_val |= XGMAC_DMA_INT_STATUS_REB0;
+			} else
+				x->rx_write_transfer_err++;
+
+			if (int_status & XGMAC_DMA_INT_STATUS_REB1) {
+				x->rx_desc_access_err++;
+				clear_val |= XGMAC_DMA_INT_STATUS_REB1;
+			} else
+				 x->rx_buffer_access_err++;
+
+			if (int_status & XGMAC_DMA_INT_STATUS_REB2) {
+				x->rx_data_transfer_err++;
+				clear_val |= XGMAC_DMA_INT_STATUS_REB2;
+			}
+		}
+	}
+
+	/* clear the served bits */
+	writel(clear_val, ioaddr + XGMAC_DMA_CHA_STATUS_REG(channel_no));
+
+	return ret_val;
+}
+
+/* Program the HW RX Watchdog */
+static void xgmac_dma_rx_watchdog(void __iomem *ioaddr, u32 riwt)
+{
+	u32 que_num;
+
+	XGMAC_FOR_EACH_QUEUE(XGMAC_RX_QUEUES, que_num) {
+		writel(riwt,
+		       ioaddr + XGMAC_DMA_CHA_INT_RXWATCHTMR_REG(que_num));
+	}
+}
+
+static const struct xgmac_dma_ops xgmac_dma_ops = {
+	.init = xgmac_dma_init,
+	.cha_init = xgmac_dma_channel_init,
+	.enable_dma_transmission = xgmac_enable_dma_transmission,
+	.enable_dma_irq = xgmac_enable_dma_irq,
+	.disable_dma_irq = xgmac_disable_dma_irq,
+	.start_tx = xgmac_dma_start_tx,
+	.start_tx_queue = xgmac_dma_start_tx_queue,
+	.stop_tx = xgmac_dma_stop_tx,
+	.stop_tx_queue = xgmac_dma_stop_tx_queue,
+	.start_rx = xgmac_dma_start_rx,
+	.stop_rx = xgmac_dma_stop_rx,
+	.tx_dma_int_status = xgmac_tx_dma_int_status,
+	.rx_dma_int_status = xgmac_rx_dma_int_status,
+	.rx_watchdog = xgmac_dma_rx_watchdog,
+};
+
+const struct xgmac_dma_ops *xgmac_get_dma_ops(void)
+{
+	return &xgmac_dma_ops;
+}
diff --git a/drivers/net/ethernet/samsung/xgmac_dma.h b/drivers/net/ethernet/samsung/xgmac_dma.h
new file mode 100644
index 0000000..002fd18
--- /dev/null
+++ b/drivers/net/ethernet/samsung/xgmac_dma.h
@@ -0,0 +1,49 @@
+/* 10G controller driver for Samsung SoCs
+ *
+ * Copyright (C) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ *
+ * Author: Siva Reddy Kallam <siva.kallam@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#ifndef __XGMAC_DMA_H__
+#define __XGMAC_DMA_H__
+
+/* forward declatarion */
+struct xgmac_extra_stats;
+
+#define XGMAC_DMA_BLENMAP_LSHIFT	1
+#define XGMAC_DMA_TXPBL_LSHIFT		16
+#define XGMAC_DMA_RXPBL_LSHIFT		16
+#define DEFAULT_DMA_PBL			8
+
+struct xgmac_dma_ops {
+	/* DMA core initialization */
+	int (*init)(void __iomem *ioaddr, int fix_burst,
+		     int burst_map, int enhance_amode);
+	void (*cha_init)(void __iomem *ioaddr, int cha_num, int fix_burst,
+			int pbl, dma_addr_t dma_tx, dma_addr_t dma_rx,
+			int t_rzie, int r_rsize);
+	void (*enable_dma_transmission)(void __iomem *ioaddr, int dma_cnum);
+	void (*enable_dma_irq)(void __iomem *ioaddr, int dma_cnum);
+	void (*disable_dma_irq)(void __iomem *ioaddr, int dma_cnum);
+	void (*start_tx)(void __iomem *ioaddr, int tchannels);
+	void (*start_tx_queue)(void __iomem *ioaddr, int dma_cnum);
+	void (*stop_tx)(void __iomem *ioaddr, int tchannels);
+	void (*stop_tx_queue)(void __iomem *ioaddr, int dma_cnum);
+	void (*start_rx)(void __iomem *ioaddr, int rchannels);
+	void (*stop_rx)(void __iomem *ioaddr, int rchannels);
+	int (*tx_dma_int_status)(void __iomem *ioaddr, int channel_no,
+			      struct xgmac_extra_stats *x);
+	int (*rx_dma_int_status)(void __iomem *ioaddr, int channel_no,
+			      struct xgmac_extra_stats *x);
+	/* Program the HW RX Watchdog */
+	void (*rx_watchdog)(void __iomem *ioaddr, u32 riwt);
+};
+
+const struct xgmac_dma_ops *xgmac_get_dma_ops(void);
+
+#endif /* __XGMAC_CORE_H__ */
diff --git a/drivers/net/ethernet/samsung/xgmac_ethtool.c b/drivers/net/ethernet/samsung/xgmac_ethtool.c
new file mode 100644
index 0000000..684b260
--- /dev/null
+++ b/drivers/net/ethernet/samsung/xgmac_ethtool.c
@@ -0,0 +1,38 @@
+/* 10G controller driver for Samsung SoCs
+ *
+ * Copyright (C) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ *
+ * Author: Siva Reddy Kallam <siva.kallam@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+
+#include "xgmac_common.h"
+
+struct xgmac_stats {
+	char stat_string[ETH_GSTRING_LEN];
+	int sizeof_stat;
+	int stat_offset;
+};
+
+#define XGMAC_STAT(m)	\
+	{ #m, FIELD_SIZEOF(struct xgmac_extra_stats, m),	\
+	offsetof(struct xgmac_priv_data, xstats.m)}
+
+static const struct xgmac_stats xgmac_gstrings_stats[] = {
+};
+#define XGMAC_STATS_LEN ARRAY_SIZE(xgmac_gstrings_stats)
+
+static const struct ethtool_ops xgmac_ethtool_ops = {
+};
+
+void xgmac_set_ethtool_ops(struct net_device *netdev)
+{
+	SET_ETHTOOL_OPS(netdev, &xgmac_ethtool_ops);
+}
diff --git a/drivers/net/ethernet/samsung/xgmac_main.c b/drivers/net/ethernet/samsung/xgmac_main.c
new file mode 100644
index 0000000..f72a4c1
--- /dev/null
+++ b/drivers/net/ethernet/samsung/xgmac_main.c
@@ -0,0 +1,2146 @@
+/* 10G controller driver for Samsung SoCs
+ *
+ * Copyright (C) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ *
+ * Author: Siva Reddy Kallam <siva.kallam@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#include <linux/clk.h>
+#include <linux/crc32.h>
+#include <linux/dma-mapping.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/if.h>
+#include <linux/if_ether.h>
+#include <linux/if_vlan.h>
+#include <linux/init.h>
+#include <linux/interrupt.h>
+#include <linux/ip.h>
+#include <linux/kernel.h>
+#include <linux/mii.h>
+#include <linux/module.h>
+#include <linux/net_tstamp.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+#include <linux/platform_device.h>
+#include <linux/prefetch.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+#include <linux/tcp.h>
+#include <linux/xgmac_platform.h>
+
+#include "xgmac_common.h"
+#include "xgmac_desc.h"
+#include "xgmac_dma.h"
+#include "xgmac_mtl.h"
+#include "xgmac_reg.h"
+
+#define XGMAC_ALIGN(x)	L1_CACHE_ALIGN(x)
+#define JUMBO_LEN	9000
+
+/* Module parameters */
+#define TX_TIMEO	5000
+#define DMA_TX_SIZE	512
+#define DMA_RX_SIZE	1024
+#define TC_DEFAULT	64
+#define DMA_BUFFER_SIZE	BUF_SIZE_2KiB
+/* The default timer value as per the xgmac specification 1 sec(1000 ms) */
+#define XGMAC_DEFAULT_LPI_TIMER	1000
+
+static int watchdog = TX_TIMEO;
+static int debug = -1;
+static int xgmac_phyaddr = -1;
+static int dma_txsize = DMA_TX_SIZE;
+static int dma_rxsize = DMA_RX_SIZE;
+static int flow_ctrl = XGMAC_FLOW_OFF;
+static int pause = XGMAC_PAUSE_TIME;
+static int tx_tc = TC_DEFAULT;
+static int rx_tc = TC_DEFAULT;
+static int buf_sz = DMA_BUFFER_SIZE;
+
+module_param(watchdog, int, S_IRUGO | S_IWUSR);
+module_param(debug, int, S_IRUGO | S_IWUSR);
+module_param(xgmac_phyaddr, int, S_IRUGO);
+module_param(dma_txsize, int, S_IRUGO | S_IWUSR);
+module_param(dma_rxsize, int, S_IRUGO | S_IWUSR);
+module_param(flow_ctrl, int, S_IRUGO | S_IWUSR);
+module_param(pause, int, S_IRUGO | S_IWUSR);
+module_param(tx_tc, int, S_IRUGO | S_IWUSR);
+module_param(rx_tc, int, S_IRUGO | S_IWUSR);
+module_param(buf_sz, int, S_IRUGO | S_IWUSR);
+
+static const u32 default_msg_level = (NETIF_MSG_DRV | NETIF_MSG_PROBE |
+				      NETIF_MSG_LINK | NETIF_MSG_IFUP |
+				      NETIF_MSG_IFDOWN | NETIF_MSG_TIMER);
+
+static irqreturn_t xgmac_common_interrupt(int irq, void *dev_id);
+static irqreturn_t xgmac_tx_interrupt(int irq, void *dev_id);
+static irqreturn_t xgmac_rx_interrupt(int irq, void *dev_id);
+
+#define XGMAC_COAL_TIMER(x) (jiffies + usecs_to_jiffies(x))
+
+/**
+ * xgmac_verify_args - verify the driver parameters.
+ * Description: it verifies if some wrong parameter is passed to the driver.
+ * Note that wrong parameters are replaced with the default values.
+ */
+static void xgmac_verify_args(void)
+{
+	if (unlikely(watchdog < 0))
+		watchdog = TX_TIMEO;
+	if (unlikely(dma_rxsize < 0))
+		dma_rxsize = DMA_RX_SIZE;
+	if (unlikely(dma_txsize < 0))
+		dma_txsize = DMA_TX_SIZE;
+	if (unlikely((buf_sz < DMA_BUFFER_SIZE) || (buf_sz > BUF_SIZE_16KiB)))
+		buf_sz = DMA_BUFFER_SIZE;
+	if (unlikely(flow_ctrl > 1))
+		flow_ctrl = XGMAC_FLOW_AUTO;
+	else if (likely(flow_ctrl < 0))
+		flow_ctrl = XGMAC_FLOW_OFF;
+	if (unlikely((pause < 0) || (pause > 0xffff)))
+		pause = XGMAC_PAUSE_TIME;
+}
+
+/**
+ * xgmac_clk_csr_set - dynamically set the MDC clock
+ * @priv: driver private structure
+ * Description: this is to dynamically set the MDC clock according to the csr
+ * clock input.
+ */
+static void xgmac_clk_csr_set(struct xgmac_priv_data *priv)
+{
+	u32 clk_rate = clk_get_rate(priv->xgmac_clk);
+
+	/* assign the proper divider, this will be used during
+	 * mdio communication
+	 */
+	if (clk_rate < XGMAC_CSR_F_150M)
+		priv->clk_csr = XGMAC_CSR_100_150M;
+	else if ((clk_rate >= XGMAC_CSR_F_150M) &&
+		 (clk_rate <= XGMAC_CSR_F_250M))
+		priv->clk_csr = XGMAC_CSR_150_250M;
+	else if ((clk_rate >= XGMAC_CSR_F_250M) &&
+		 (clk_rate <= XGMAC_CSR_F_300M))
+		priv->clk_csr = XGMAC_CSR_250_300M;
+	else if ((clk_rate >= XGMAC_CSR_F_300M) &&
+		 (clk_rate <= XGMAC_CSR_F_350M))
+		priv->clk_csr = XGMAC_CSR_300_350M;
+	else if ((clk_rate >= XGMAC_CSR_F_350M) &&
+		 (clk_rate <= XGMAC_CSR_F_400M))
+		priv->clk_csr = XGMAC_CSR_350_400M;
+	else if ((clk_rate >= XGMAC_CSR_F_400M) &&
+		(clk_rate <= XGMAC_CSR_F_500M))
+		priv->clk_csr = XGMAC_CSR_400_500M;
+
+}
+
+static void print_pkt(unsigned char *buf, int len)
+{
+	int j;
+	pr_debug("len = %d byte, buf addr: 0x%p", len, buf);
+	for (j = 0; j < len; j++) {
+		if ((j % 16) == 0)
+			pr_debug("\n %03x:", j);
+		pr_debug(" %02x", buf[j]);
+	}
+	pr_debug("\n");
+}
+
+/* minimum number of free TX descriptors required to wake up TX process */
+#define XGMAC_TX_THRESH(x)	(x->dma_tx_size/4)
+
+static inline u32 xgmac_tx_avail(struct xgmac_tx_queue *queue, int tx_qsize)
+{
+	return queue->dirty_tx + tx_qsize - queue->cur_tx - 1;
+}
+
+/**
+ * xgmac_adjust_link
+ * @dev: net device structure
+ * Description: it adjusts the link parameters.
+ */
+static void xgmac_adjust_link(struct net_device *dev)
+{
+	struct xgmac_priv_data *priv = netdev_priv(dev);
+	struct phy_device *phydev = priv->phydev;
+	u8 new_state = 0;
+	u8 speed = 0xff;
+
+	if (!phydev)
+		return;
+
+	/* XGMAC is not supporting auto-negotiation and
+	 * half duplex mode. so, not handling duplex change
+	 * in this function. only handling speed and link status
+	 */
+	if (phydev->link) {
+		if (phydev->speed != priv->speed) {
+			new_state = 1;
+			switch (phydev->speed) {
+			case SPEED_10000:
+				speed = XGMAC_SPEED_10G;
+				break;
+			case SPEED_2500:
+				speed = XGMAC_SPEED_2_5G;
+				break;
+			case SPEED_1000:
+				speed = XGMAC_SPEED_1G;
+				break;
+			default:
+				if (netif_msg_link(priv))
+					pr_err("%s: Speed (%d) not suppoted\n",
+						dev->name, phydev->speed);
+			}
+
+			priv->speed = phydev->speed;
+			priv->hw->mac->set_speed(priv->ioaddr, speed);
+		}
+
+		if (!priv->oldlink) {
+			new_state = 1;
+			priv->oldlink = 1;
+		}
+	} else if (priv->oldlink) {
+		new_state = 1;
+		priv->oldlink = 0;
+		priv->speed = SPEED_UNKNOWN;
+	}
+
+	if (new_state & netif_msg_link(priv))
+		phy_print_status(phydev);
+}
+
+/**
+ * xgmac_init_phy - PHY initialization
+ * @dev: net device structure
+ * Description: it initializes the driver's PHY state, and attaches the PHY
+ * to the mac driver.
+ *  Return value:
+ *  0 on success
+ */
+static int xgmac_init_phy(struct net_device *ndev)
+{
+	char phy_id_fmt[MII_BUS_ID_SIZE + 3];
+	char bus_id[MII_BUS_ID_SIZE];
+	struct phy_device *phydev;
+	struct xgmac_priv_data *priv = netdev_priv(ndev);
+	int phy_iface = priv->plat->interface;
+
+	/* assign default link status */
+	priv->oldlink = 0;
+	priv->speed = SPEED_UNKNOWN;
+	priv->oldduplex = DUPLEX_UNKNOWN;
+
+	if (priv->plat->phy_bus_name)
+		snprintf(bus_id, MII_BUS_ID_SIZE, "%s-%x",
+			 priv->plat->phy_bus_name, priv->plat->bus_id);
+	else
+		snprintf(bus_id, MII_BUS_ID_SIZE, "xgmac-%x",
+			 priv->plat->bus_id);
+
+	snprintf(phy_id_fmt, MII_BUS_ID_SIZE + 3, PHY_ID_FMT, bus_id,
+		 priv->plat->phy_addr);
+	pr_debug("xgmac_init_phy:  trying to attach to %s\n", phy_id_fmt);
+
+	phydev = phy_connect(ndev, phy_id_fmt, &xgmac_adjust_link, phy_iface);
+
+	if (IS_ERR(phydev)) {
+		pr_err("%s: Could not attach to PHY\n", ndev->name);
+		return PTR_ERR(phydev);
+	}
+
+	/* Stop Advertising 1000BASE Capability if interface is not GMII */
+	if ((phy_iface == PHY_INTERFACE_MODE_MII) ||
+	    (phy_iface == PHY_INTERFACE_MODE_RMII))
+		phydev->advertising &= ~(SUPPORTED_1000baseT_Half |
+					 SUPPORTED_1000baseT_Full);
+	if (phydev->phy_id == 0) {
+		phy_disconnect(phydev);
+		return -ENODEV;
+	}
+
+	pr_debug("xgmac_init_phy: %s: attached to PHY (UID 0x%x) Link = %d\n",
+			ndev->name, phydev->phy_id, phydev->link);
+
+	/* save phy device in private structure */
+	priv->phydev = phydev;
+
+	return 0;
+}
+
+/**
+ * xgmac_clear_descriptors: clear descriptors
+ * @priv: driver private structure
+ * Description: this function is called to clear the tx and rx descriptors
+ * in case of both basic and extended descriptors are used.
+ */
+static void xgmac_clear_descriptors(struct xgmac_priv_data *priv)
+{
+	int i, j;
+	unsigned int txsize = priv->dma_tx_size;
+	unsigned int rxsize = priv->dma_rx_size;
+
+	/* Clear the Rx/Tx descriptors */
+	for (j = 0; j < XGMAC_RX_QUEUES; j++) {
+		for (i = 0; i < rxsize; i++)
+			priv->hw->desc->init_rx_desc(&priv->rxq[j]->dma_rx[i],
+						     priv->use_riwt, priv->mode,
+						     (i == rxsize - 1));
+	}
+
+	for (j = 0; j < XGMAC_TX_QUEUES; j++) {
+		for (i = 0; i < txsize; i++)
+			priv->hw->desc->init_tx_desc(&priv->txq[j]->dma_tx[i]);
+	}
+}
+
+static int xgmac_init_rx_buffers(struct net_device *dev,
+				 struct xgmac_rx_norm_desc *p, int i,
+				 unsigned int dma_buf_sz,
+				 struct xgmac_rx_queue *rx_ring)
+{
+	struct xgmac_priv_data *priv = netdev_priv(dev);
+	struct sk_buff *skb;
+
+	skb = __netdev_alloc_skb(dev, dma_buf_sz, GFP_KERNEL);
+	if (!skb) {
+		pr_err("%s: Rx init fails; skb is NULL\n", __func__);
+		return -ENOMEM;
+	}
+	skb_reserve(skb, NET_IP_ALIGN);
+
+	rx_ring->rx_skbuff[i] = skb;
+	rx_ring->rx_skbuff_dma[i] = dma_map_single(priv->device, skb->data,
+						dma_buf_sz, DMA_FROM_DEVICE);
+
+	if (dma_mapping_error(priv->device, rx_ring->rx_skbuff_dma[i])) {
+			pr_err("%s: DMA mapping error\n", __func__);
+			dev_kfree_skb_any(skb);
+			return -EINVAL;
+	}
+
+	p->rdes23.rx_rd_des23.buf2_addr = rx_ring->rx_skbuff_dma[i];
+
+	return 0;
+}
+/**
+ * init_tx_ring - init the TX descriptor ring
+ * @dev: net device structure
+ * @tx_ring: ring to be intialised
+ * @tx_rsize: ring size
+ * Description:  this function initializes the DMA TX descriptor
+ */
+static int init_tx_ring(struct device *dev, u8 queue_no,
+			struct xgmac_tx_queue *tx_ring,	int tx_rsize)
+{
+	/* TX ring is not allcoated */
+	if (!tx_ring) {
+		dev_err(dev, "No memory for TX queue of XGMAC\n");
+		return -ENOMEM;
+	}
+
+	/* allocate memory for TX descriptors */
+	tx_ring->dma_tx = dma_zalloc_coherent(dev,
+			tx_rsize * sizeof(struct xgmac_tx_norm_desc),
+			&tx_ring->dma_tx_phy, GFP_KERNEL);
+	if (!tx_ring->dma_tx) {
+		dev_err(dev, "No memory for TX desc of XGMAC\n");
+		return -ENOMEM;
+	}
+
+	/* allocate memory for TX skbuff array */
+	tx_ring->tx_skbuff_dma = devm_kcalloc(dev, tx_rsize,
+					sizeof(dma_addr_t), GFP_KERNEL);
+	if (!tx_ring->tx_skbuff_dma) {
+		dev_err(dev, "No memory for TX skbuffs DMA of XGMAC\n");
+		goto dmamem_err;
+	}
+
+	tx_ring->tx_skbuff = devm_kcalloc(dev, tx_rsize,
+				sizeof(struct sk_buff *), GFP_KERNEL);
+
+	if (!tx_ring->tx_skbuff) {
+		dev_err(dev, "No memory for TX skbuffs of XGMAC\n");
+		goto dmamem_err;
+	}
+
+	/* assign queue number */
+	tx_ring->queue_no = queue_no;
+
+	/* initalise counters */
+	tx_ring->dirty_tx = 0;
+	tx_ring->cur_tx = 0;
+
+	/* initalise TX queue lock */
+	spin_lock_init(&tx_ring->tx_lock);
+
+	return 0;
+
+dmamem_err:
+	dma_free_coherent(dev, tx_rsize * sizeof(struct xgmac_tx_norm_desc),
+			  tx_ring->dma_tx, tx_ring->dma_tx_phy);
+	return -ENOMEM;
+}
+
+/**
+ * free_rx_ring - free the RX descriptor ring
+ * @dev: net device structure
+ * @rx_ring: ring to be intialised
+ * @rx_rsize: ring size
+ * Description:  this function initializes the DMA RX descriptor
+ */
+void free_rx_ring(struct device *dev, struct xgmac_rx_queue *rx_ring,
+			int rx_rsize)
+{
+	dma_free_coherent(dev, rx_rsize * sizeof(struct xgmac_rx_norm_desc),
+			  rx_ring->dma_rx, rx_ring->dma_rx_phy);
+	kfree(rx_ring->rx_skbuff_dma);
+	kfree(rx_ring->rx_skbuff);
+}
+
+/**
+ * init_rx_ring - init the RX descriptor ring
+ * @dev: net device structure
+ * @rx_ring: ring to be intialised
+ * @rx_rsize: ring size
+ * Description:  this function initializes the DMA RX descriptor
+ */
+static int init_rx_ring(struct net_device *dev, u8 queue_no,
+			struct xgmac_rx_queue *rx_ring,	int rx_rsize)
+{
+	struct xgmac_priv_data *priv = netdev_priv(dev);
+	int desc_index;
+	unsigned int bfsize = 0;
+	unsigned int ret = 0;
+
+	/* Set the max buffer size according to the MTU. */
+	bfsize = ALIGN(dev->mtu + ETH_HLEN + ETH_FCS_LEN + NET_IP_ALIGN, 8);
+
+	if (netif_msg_probe(priv))
+		pr_debug("%s: bfsize %d\n", __func__, bfsize);
+
+	/* RX ring is not allcoated */
+	if (rx_ring == NULL) {
+		pr_err("No memory for RX queue of XGMAC\n");
+		goto error;
+	} else {
+		/* assign queue number */
+		rx_ring->queue_no = queue_no;
+
+		/* allocate memory for RX descriptors */
+		rx_ring->dma_rx = dma_zalloc_coherent(priv->device,
+				rx_rsize * sizeof(struct xgmac_rx_norm_desc),
+				&rx_ring->dma_rx_phy, GFP_KERNEL);
+
+		if (rx_ring->dma_rx == NULL) {
+			pr_err("No memory for RX desc of XGMAC\n");
+			goto error;
+		}
+
+		/* allocate memory for RX skbuff array */
+		rx_ring->rx_skbuff_dma = kmalloc_array(rx_rsize,
+					sizeof(dma_addr_t), GFP_KERNEL);
+
+		if (rx_ring->rx_skbuff_dma == NULL) {
+			pr_err("No memory for RX skbuffs DMA of XGMAC\n");
+			goto dmamem_err;
+		}
+
+		rx_ring->rx_skbuff = kmalloc_array(rx_rsize,
+					sizeof(struct sk_buff *), GFP_KERNEL);
+
+		if (rx_ring->rx_skbuff == NULL) {
+			pr_err("No memory for RX skbuffs of XGMAC\n");
+			goto rxbuff_err;
+		}
+
+		/* initalise the buffers */
+		for (desc_index = 0; desc_index < rx_rsize; desc_index++) {
+			struct xgmac_rx_norm_desc *p;
+			p = rx_ring->dma_rx + desc_index;
+			ret = xgmac_init_rx_buffers(dev, p, desc_index,
+							bfsize, rx_ring);
+			if (ret)
+				goto err_init_rx_buffers;
+		}
+
+		/* initalise counters */
+		rx_ring->cur_rx = 0;
+		rx_ring->dirty_rx = (unsigned int)(desc_index - rx_rsize);
+		priv->dma_buf_sz = bfsize;
+
+	}
+
+	return 0;
+
+err_init_rx_buffers:
+	while (--desc_index >= 0)
+		free_rx_ring(priv->device, rx_ring, desc_index);
+	kfree(rx_ring->rx_skbuff);
+rxbuff_err:
+	kfree(rx_ring->rx_skbuff_dma);
+dmamem_err:
+	dma_free_coherent(priv->device,
+			  rx_rsize * sizeof(struct xgmac_rx_norm_desc),
+			  rx_ring->dma_rx, rx_ring->dma_rx_phy);
+error:
+	return -ENOMEM;
+}
+/**
+ * free_tx_ring - free the TX descriptor ring
+ * @dev: net device structure
+ * @tx_ring: ring to be intialised
+ * @tx_rsize: ring size
+ * Description:  this function initializes the DMA TX descriptor
+ */
+void free_tx_ring(struct device *dev, struct xgmac_tx_queue *tx_ring,
+			int tx_rsize)
+{
+	dma_free_coherent(dev, tx_rsize * sizeof(struct xgmac_tx_norm_desc),
+			  tx_ring->dma_tx, tx_ring->dma_tx_phy);
+}
+
+/**
+ * init_dma_desc_rings - init the RX/TX descriptor rings
+ * @dev: net device structure
+ * Description:  this function initializes the DMA RX/TX descriptors
+ * and allocates the socket buffers. It suppors the chained and ring
+ * modes.
+ */
+static int init_dma_desc_rings(struct net_device *netd)
+{
+	int queue_num, ret;
+	struct xgmac_priv_data *priv = netdev_priv(netd);
+	int tx_rsize = priv->dma_tx_size;
+	int rx_rsize = priv->dma_rx_size;
+
+	/* Allocate memory for queue structures and TX descs */
+	XGMAC_FOR_EACH_QUEUE(XGMAC_TX_QUEUES, queue_num) {
+		ret = init_tx_ring(priv->device, queue_num,
+				   priv->txq[queue_num], tx_rsize);
+		if (ret) {
+			dev_err(&netd->dev, "TX DMA ring allocation failed!\n");
+			goto txalloc_err;
+		}
+
+		/* save private pointer in each ring this
+		 * pointer is needed during cleaing TX queue
+		 */
+		priv->txq[queue_num]->priv_ptr = priv;
+	}
+
+	/* Allocate memory for queue structures and RX descs */
+	XGMAC_FOR_EACH_QUEUE(XGMAC_RX_QUEUES, queue_num) {
+		ret = init_rx_ring(netd, queue_num,
+				   priv->rxq[queue_num], rx_rsize);
+		if (ret) {
+			pr_err("RX DMA ring allocation failed!!\n");
+			goto rxalloc_err;
+		}
+
+		/* save private pointer in each ring this
+		 * pointer is needed during cleaing TX queue
+		 */
+		priv->rxq[queue_num]->priv_ptr = priv;
+	}
+
+	xgmac_clear_descriptors(priv);
+
+	return 0;
+
+txalloc_err:
+	while (queue_num--)
+		free_tx_ring(priv->device, priv->txq[queue_num], tx_rsize);
+	return ret;
+
+rxalloc_err:
+	while (queue_num--)
+		free_rx_ring(priv->device, priv->rxq[queue_num], rx_rsize);
+	return ret;
+}
+
+static void tx_free_ring_skbufs(struct xgmac_tx_queue *txqueue)
+{
+	int dma_desc;
+	struct xgmac_priv_data *priv = txqueue->priv_ptr;
+	int tx_rsize = priv->dma_tx_size;
+
+	for (dma_desc = 0; dma_desc < tx_rsize; dma_desc++) {
+		struct xgmac_tx_norm_desc *tdesc = txqueue->dma_tx + dma_desc;
+
+		if (txqueue->tx_skbuff_dma[dma_desc])
+			dma_unmap_single(priv->device,
+					txqueue->tx_skbuff_dma[dma_desc],
+					priv->hw->desc->get_tx_len(tdesc),
+					DMA_TO_DEVICE);
+
+		dev_kfree_skb_any(txqueue->tx_skbuff[dma_desc]);
+		txqueue->tx_skbuff[dma_desc] = NULL;
+		txqueue->tx_skbuff_dma[dma_desc] = 0;
+	}
+}
+
+
+static void dma_free_tx_skbufs(struct xgmac_priv_data *priv)
+{
+	int queue_num;
+
+	XGMAC_FOR_EACH_QUEUE(XGMAC_TX_QUEUES, queue_num) {
+		struct xgmac_tx_queue *tqueue = priv->txq[queue_num];
+		tx_free_ring_skbufs(tqueue);
+	}
+}
+
+static void free_dma_desc_resources(struct xgmac_priv_data *priv)
+{
+	int queue_num;
+	int tx_rsize = priv->dma_tx_size;
+	int rx_rsize = priv->dma_rx_size;
+
+	/* Release the DMA TX buffers */
+	dma_free_tx_skbufs(priv);
+
+	/* Release the TX ring memory also */
+	XGMAC_FOR_EACH_QUEUE(XGMAC_TX_QUEUES, queue_num) {
+		free_tx_ring(priv->device, priv->txq[queue_num], tx_rsize);
+	}
+
+	/* Release the RX ring memory also */
+	XGMAC_FOR_EACH_QUEUE(XGMAC_RX_QUEUES, queue_num) {
+		free_rx_ring(priv->device, priv->rxq[queue_num], rx_rsize);
+	}
+}
+
+static int txring_mem_alloc(struct xgmac_priv_data *priv)
+{
+	int queue_num;
+
+	XGMAC_FOR_EACH_QUEUE(XGMAC_TX_QUEUES, queue_num) {
+		priv->txq[queue_num] = devm_kmalloc(priv->device,
+				sizeof(struct xgmac_tx_queue), GFP_KERNEL);
+		if (!priv->txq[queue_num]) {
+			dev_err(priv->device,
+				"No memory for TX queue of XGMAC\n");
+			return -ENOMEM;
+		}
+	}
+
+	return 0;
+}
+
+static int rxring_mem_alloc(struct xgmac_priv_data *priv)
+{
+	int queue_num;
+
+	XGMAC_FOR_EACH_QUEUE(XGMAC_RX_QUEUES, queue_num) {
+		priv->rxq[queue_num] = devm_kmalloc(priv->device,
+				sizeof(struct xgmac_rx_queue), GFP_KERNEL);
+		if (!priv->rxq[queue_num]) {
+			pr_err("No memory for RX queue of XGMAC\n");
+			return -ENOMEM;
+		}
+	}
+
+	return 0;
+}
+
+/**
+ *  xgmac_mtl_operation_mode - HW MTL operation mode
+ *  @priv: driver private structure
+ *  Description: it sets the MTL operation mode: tx/rx MTL thresholds
+ *  or Store-And-Forward capability.
+ */
+static void xgmac_mtl_operation_mode(struct xgmac_priv_data *priv)
+{
+	int queue_num;
+
+	/* TX/RX threshold control */
+	if (likely(priv->plat->force_sf_dma_mode)) {
+		/* set TC mode for TX QUEUES */
+		XGMAC_FOR_EACH_QUEUE(priv->hw_cap.tx_mtl_queues, queue_num)
+			priv->hw->mtl->set_tx_mtl_mode(priv->ioaddr, queue_num,
+					XGMAC_MTL_SFMODE);
+		tx_tc = XGMAC_MTL_SFMODE;
+
+		/* set TC mode for RX QUEUES */
+		XGMAC_FOR_EACH_QUEUE(priv->hw_cap.rx_mtl_queues, queue_num)
+			priv->hw->mtl->set_rx_mtl_mode(priv->ioaddr, queue_num,
+					XGMAC_MTL_SFMODE);
+		rx_tc = XGMAC_MTL_SFMODE;
+	} else if (unlikely(priv->plat->force_thresh_dma_mode)) {
+		/* set TC mode for TX QUEUES */
+		XGMAC_FOR_EACH_QUEUE(priv->hw_cap.tx_mtl_queues, queue_num)
+			priv->hw->mtl->set_tx_mtl_mode(priv->ioaddr, queue_num,
+						   tx_tc);
+		/* set TC mode for RX QUEUES */
+		XGMAC_FOR_EACH_QUEUE(priv->hw_cap.rx_mtl_queues, queue_num)
+			priv->hw->mtl->set_rx_mtl_mode(priv->ioaddr, queue_num,
+						   rx_tc);
+	} else
+		pr_err("ERROR: %s: Invalid TX threshold mode\n", __func__);
+}
+
+/**
+ * xgmac_tx_queue_clean:
+ * @priv: driver private structure
+ * Description: it reclaims resources after transmission completes.
+ */
+static void xgmac_tx_queue_clean(struct xgmac_tx_queue *tqueue)
+{
+	struct xgmac_priv_data *priv = tqueue->priv_ptr;
+	unsigned int tx_rsize = priv->dma_tx_size;
+	struct netdev_queue *dev_txq;
+	u8 queue_no = tqueue->queue_no;
+
+	dev_txq = netdev_get_tx_queue(priv->dev, queue_no);
+
+	spin_lock(&tqueue->tx_lock);
+
+	priv->xstats.tx_clean++;
+	while (tqueue->dirty_tx != tqueue->cur_tx) {
+		unsigned int entry = tqueue->dirty_tx % tx_rsize;
+		struct sk_buff *skb = tqueue->tx_skbuff[entry];
+		struct xgmac_tx_norm_desc *p;
+
+		p = tqueue->dma_tx + entry;
+
+		/* Check if the descriptor is owned by the DMA. */
+		if (priv->hw->desc->get_tx_owner(p))
+			break;
+
+		if (netif_msg_tx_done(priv))
+			pr_debug("%s: curr %d, dirty %d\n", __func__,
+					tqueue->cur_tx, tqueue->dirty_tx);
+
+		if (likely(tqueue->tx_skbuff_dma[entry])) {
+			dma_unmap_single(priv->device,
+					tqueue->tx_skbuff_dma[entry],
+					priv->hw->desc->get_tx_len(p),
+					DMA_TO_DEVICE);
+			tqueue->tx_skbuff_dma[entry] = 0;
+		}
+
+		if (likely(skb)) {
+			dev_kfree_skb(skb);
+			tqueue->tx_skbuff[entry] = NULL;
+		}
+
+		priv->hw->desc->release_tx_desc(p);
+
+		tqueue->dirty_tx++;
+	}
+
+	/* wake up queue */
+	if (unlikely(netif_tx_queue_stopped(dev_txq) &&
+		xgmac_tx_avail(tqueue, tx_rsize) > XGMAC_TX_THRESH(priv))) {
+		netif_tx_lock(priv->dev);
+		if (netif_tx_queue_stopped(dev_txq) &&
+		xgmac_tx_avail(tqueue, tx_rsize) > XGMAC_TX_THRESH(priv)) {
+			if (netif_msg_tx_done(priv))
+				pr_debug("%s: restart transmit\n", __func__);
+			netif_tx_wake_queue(dev_txq);
+		}
+		netif_tx_unlock(priv->dev);
+	}
+
+	spin_unlock(&tqueue->tx_lock);
+}
+
+/**
+ * xgmac_tx_clean:
+ * @priv: driver private structure
+ * Description: it reclaims resources after transmission completes.
+ */
+static void xgmac_tx_all_clean(struct xgmac_priv_data *priv)
+{
+	u8 queue_num;
+
+	XGMAC_FOR_EACH_QUEUE(XGMAC_TX_QUEUES, queue_num) {
+		struct xgmac_tx_queue *tqueue = priv->txq[queue_num];
+		xgmac_tx_queue_clean(tqueue);
+	}
+}
+
+/**
+ * xgmac_restart_tx_queue: irq tx error mng function
+ * @priv: driver private structure
+ * Description: it cleans the descriptors and restarts the transmission
+ * in case of errors.
+ */
+static void xgmac_restart_tx_queue(struct xgmac_priv_data *priv, int queue_num)
+{
+	struct xgmac_tx_queue *tx_ring = priv->txq[queue_num];
+	struct netdev_queue *dev_txq = netdev_get_tx_queue(priv->dev,
+							queue_num);
+
+	/* stop the queue */
+	netif_tx_stop_queue(dev_txq);
+
+	/* stop the tx dma */
+	priv->hw->dma->stop_tx_queue(priv->ioaddr, queue_num);
+
+	/* free the skbuffs of the ring */
+	tx_free_ring_skbufs(tx_ring);
+
+	/* initalise counters */
+	tx_ring->cur_tx = 0;
+	tx_ring->dirty_tx = 0;
+
+	/* start the tx dma */
+	priv->hw->dma->start_tx_queue(priv->ioaddr, queue_num);
+
+	priv->dev->stats.tx_errors++;
+
+	/* wakeup the queue */
+	netif_tx_wake_queue(dev_txq);
+}
+
+/**
+ * xgmac_reset_all_tx_queues: irq tx error mng function
+ * @priv: driver private structure
+ * Description: it cleans all the descriptors and
+ * restarts the transmission on all queues in case of errors.
+ */
+static void xgmac_reset_all_tx_queues(struct xgmac_priv_data *priv)
+{
+	int queue_num;
+
+	/* On TX timeout of net device, resetting of all queues
+	 * may not be proper way, revisit this later if needed
+	 */
+	XGMAC_FOR_EACH_QUEUE(XGMAC_TX_QUEUES, queue_num)
+		xgmac_restart_tx_queue(priv, queue_num);
+}
+
+/**
+ * xgmac_get_hw_features: get XMAC capabilities from the HW cap. register.
+ * @priv: driver private structure
+ * Description:
+ *  new GMAC chip generations have a new register to indicate the
+ *  presence of the optional feature/functions.
+ *  This can be also used to override the value passed through the
+ *  platform and necessary for old MAC10/100 and GMAC chips.
+ */
+static int xgmac_get_hw_features(struct xgmac_priv_data * const priv)
+{
+	int rval = 0;
+	struct xgmac_hw_features *features = &priv->hw_cap;
+
+	/* Read First Capability Register CAP[0] */
+	rval = priv->hw->mac->get_hw_feature(priv->ioaddr, 0);
+	if (rval) {
+		features->gmii_1000mbps = XGMAC_HW_FEAT_GMII(rval);
+		features->vlan_hfilter = XGMAC_HW_FEAT_VLAN_HASH_FILTER(rval);
+		features->sma_mdio = XGMAC_HW_FEAT_SMA(rval);
+		features->pmt_remote_wake_up =
+				XGMAC_HW_FEAT_PMT_TEMOTE_WOP(rval);
+		features->pmt_magic_frame = XGMAC_HW_FEAT_PMT_MAGIC_PKT(rval);
+		features->rmon = XGMAC_HW_FEAT_RMON(rval);
+		features->arp_offload = XGMAC_HW_FEAT_ARP_OFFLOAD(rval);
+		features->atime_stamp = XGMAC_HW_FEAT_IEEE1500_2008(rval);
+		features->tx_csum_offload =
+					XGMAC_HW_FEAT_TX_CSUM_OFFLOAD(rval);
+		features->rx_csum_offload =
+					XGMAC_HW_FEAT_RX_CSUM_OFFLOAD(rval);
+		features->multi_macaddr = XGMAC_HW_FEAT_MACADDR_COUNT(rval);
+		features->tstamp_srcselect = XGMAC_HW_FEAT_TSTMAP_SRC(rval);
+		features->sa_vlan_insert = XGMAC_HW_FEAT_SRCADDR_VLAN(rval);
+	}
+	/* Read First Capability Register CAP[1] */
+	rval = priv->hw->mac->get_hw_feature(priv->ioaddr, 1);
+	if (rval) {
+		features->rxfifo_size = XGMAC_HW_FEAT_RX_FIFO_SIZE(rval);
+		features->txfifo_size = XGMAC_HW_FEAT_TX_FIFO_SIZE(rval);
+		features->atstmap_hword = XGMAC_HW_FEAT_TX_FIFO_SIZE(rval);
+		features->dcb_enable = XGMAC_HW_FEAT_DCB(rval);
+		features->splithead_enable = XGMAC_HW_FEAT_SPLIT_HDR(rval);
+		features->tcpseg_offload = XGMAC_HW_FEAT_TSO(rval);
+		features->debug_mem = XGMAC_HW_FEAT_DEBUG_MEM_IFACE(rval);
+		features->rss_enable = XGMAC_HW_FEAT_RSS(rval);
+		features->hash_tsize = XGMAC_HW_FEAT_HASH_TABLE_SIZE(rval);
+		features->l3l4_filer_size = XGMAC_HW_FEAT_L3L4_FILTER_NUM(rval);
+	}
+
+	/* Read First Capability Register CAP[2] */
+	rval = priv->hw->mac->get_hw_feature(priv->ioaddr, 2);
+	if (rval) {
+		features->rx_mtl_queues = XGMAC_HW_FEAT_RX_MTL_QUEUES(rval);
+		features->tx_mtl_queues = XGMAC_HW_FEAT_TX_MTL_QUEUES(rval);
+		features->rx_dma_channels = XGMAC_HW_FEAT_RX_DMA_CHANNELS(rval);
+		features->tx_dma_channels = XGMAC_HW_FEAT_TX_DMA_CHANNELS(rval);
+		features->pps_output_count = XGMAC_HW_FEAT_PPS_OUTPUTS(rval);
+		features->aux_input_count = XGMAC_HW_FEAT_AUX_SNAPSHOTS(rval);
+	}
+
+	return rval;
+}
+
+/**
+ * xgmac_check_ether_addr: check if the MAC addr is valid
+ * @priv: driver private structure
+ * Description:
+ * it is to verify if the MAC address is valid, in case of failures it
+ * generates a random MAC address
+ */
+static void xgmac_check_ether_addr(struct xgmac_priv_data *priv)
+{
+	if (!is_valid_ether_addr(priv->dev->dev_addr)) {
+		priv->hw->mac->get_umac_addr((void __iomem *)
+					     priv->dev->base_addr,
+					     priv->dev->dev_addr, 0);
+		if (!is_valid_ether_addr(priv->dev->dev_addr))
+			eth_hw_addr_random(priv->dev);
+	}
+	dev_info(priv->device, "device MAC address %pM\n",
+			priv->dev->dev_addr);
+
+}
+
+/**
+ * xgmac_init_dma_engine: DMA init.
+ * @priv: driver private structure
+ * Description:
+ * It inits the DMA invoking the specific XGMAC callback.
+ * Some DMA parameters can be passed from the platform;
+ * in case of these are not passed a default is kept for the MAC or GMAC.
+ */
+static int xgmac_init_dma_engine(struct xgmac_priv_data *priv)
+{
+	int pbl = DEFAULT_DMA_PBL, fixed_burst = 0, burst_map = 0;
+	int adv_addr_mode = 1;
+	int queue_num;
+
+	if (priv->plat->dma_cfg) {
+		pbl = priv->plat->dma_cfg->pbl;
+		fixed_burst = priv->plat->dma_cfg->fixed_burst;
+		burst_map = priv->plat->dma_cfg->burst_map;
+		adv_addr_mode = priv->plat->dma_cfg->adv_addr_mode;
+	}
+
+	XGMAC_FOR_EACH_QUEUE(XGMAC_TX_QUEUES, queue_num)
+		priv->hw->dma->cha_init(priv->ioaddr, queue_num,
+					fixed_burst, pbl,
+					(priv->txq[queue_num])->dma_tx_phy,
+					(priv->rxq[queue_num])->dma_rx_phy,
+					priv->dma_tx_size, priv->dma_rx_size);
+
+	return priv->hw->dma->init(priv->ioaddr, fixed_burst,
+				burst_map, adv_addr_mode);
+}
+
+/**
+ * xgmac_init_mtl_engine: MTL init.
+ * @priv: driver private structure
+ * Description:
+ * It inits the MTL invoking the specific XGMAC callback.
+ */
+static void xgmac_init_mtl_engine(struct xgmac_priv_data *priv)
+{
+	int queue_num;
+
+	XGMAC_FOR_EACH_QUEUE(XGMAC_TX_QUEUES, queue_num) {
+		priv->hw->mtl->mtl_set_txfifosize(priv->ioaddr, queue_num,
+				priv->hw_cap.tx_mtl_qsize);
+		priv->hw->mtl->mtl_enable_txqueue(priv->ioaddr, queue_num);
+	}
+
+}
+
+/**
+ * xgmac_disable_mtl_engine: MTL disable.
+ * @priv: driver private structure
+ * Description:
+ * It disables the MTL queues by invoking the specific XGMAC callback.
+ */
+static void xgmac_disable_mtl_engine(struct xgmac_priv_data *priv)
+{
+	int queue_num;
+
+	XGMAC_FOR_EACH_QUEUE(XGMAC_TX_QUEUES, queue_num)
+		priv->hw->mtl->mtl_disable_txqueue(priv->ioaddr, queue_num);
+}
+
+
+/**
+ * xgmac_tx_timer: mitigation sw timer for tx.
+ * @data: data pointer
+ * Description:
+ * This is the timer handler to directly invoke the xgmac_tx_clean.
+ */
+static void xgmac_tx_timer(unsigned long data)
+{
+	struct xgmac_tx_queue *p = (struct xgmac_tx_queue *)data;
+	xgmac_tx_queue_clean(p);
+}
+
+/**
+ * xgmac_init_tx_coalesce: init tx mitigation options.
+ * @priv: driver private structure
+ * Description:
+ * This inits the transmit coalesce parameters: i.e. timer rate,
+ * timer handler and default threshold used for enabling the
+ * interrupt on completion bit.
+ */
+static void xgmac_tx_init_coalesce(struct xgmac_priv_data *priv)
+{
+	u8 queue_num;
+
+	XGMAC_FOR_EACH_QUEUE(XGMAC_TX_QUEUES, queue_num) {
+		struct xgmac_tx_queue *p = priv->txq[queue_num];
+		p->tx_coal_frames =  XGMAC_TX_FRAMES;
+		p->tx_coal_timer = XGMAC_COAL_TX_TIMER;
+		init_timer(&p->txtimer);
+		p->txtimer.expires = XGMAC_COAL_TIMER(p->tx_coal_timer);
+		p->txtimer.data = (unsigned long)&priv->txq[queue_num];
+		p->txtimer.function = xgmac_tx_timer;
+		add_timer(&p->txtimer);
+	}
+}
+
+static void xgmac_tx_del_timer(struct xgmac_priv_data *priv)
+{
+	u8 queue_num;
+
+	XGMAC_FOR_EACH_QUEUE(XGMAC_TX_QUEUES, queue_num) {
+		struct xgmac_tx_queue *p = priv->txq[queue_num];
+		del_timer_sync(&p->txtimer);
+	}
+}
+
+/**
+ *  xgmac_open - open entry point of the driver
+ *  @dev : pointer to the device structure.
+ *  Description:
+ *  This function is the open entry point of the driver.
+ *  Return value:
+ *  0 on success and an appropriate (-)ve integer as defined in errno.h
+ *  file on failure.
+ */
+static int xgmac_open(struct net_device *dev)
+{
+	struct xgmac_priv_data *priv = netdev_priv(dev);
+	int ret, queue_num;
+
+	clk_prepare_enable(priv->xgmac_clk);
+
+	xgmac_check_ether_addr(priv);
+
+	/* Init the phy */
+	ret = xgmac_init_phy(dev);
+	if (ret) {
+		pr_err("%s: Cannot attach to PHY (error: %d)\n",
+				__func__, ret);
+		goto phy_error;
+	}
+
+	/* Create and initialize the TX/RX descriptors chains. */
+	priv->dma_tx_size = XGMAC_ALIGN(dma_txsize);
+	priv->dma_rx_size = XGMAC_ALIGN(dma_rxsize);
+	priv->dma_buf_sz = XGMAC_ALIGN(buf_sz);
+	init_dma_desc_rings(dev);
+
+	/* DMA initialization and SW reset */
+	ret = xgmac_init_dma_engine(priv);
+	if (ret < 0) {
+		pr_err("%s: DMA initialization failed\n", __func__);
+		goto init_error;
+	}
+
+	/*  MTL initialization */
+	xgmac_init_mtl_engine(priv);
+
+	/* Copy the MAC addr into the HW  */
+	priv->hw->mac->set_umac_addr(priv->ioaddr, dev->dev_addr, 0);
+
+	/* Initialize the MAC Core */
+	priv->hw->mac->core_init(priv->ioaddr);
+
+	/* Request the IRQ lines */
+	ret = devm_request_irq(priv->device, dev->irq, xgmac_common_interrupt,
+			  IRQF_SHARED, dev->name, dev);
+	if (unlikely(ret < 0)) {
+		pr_err("%s: ERROR: allocating the IRQ %d (error: %d)\n",
+		       __func__, dev->irq, ret);
+		goto init_error;
+	}
+
+	/* Request TX DMA irq lines */
+	XGMAC_FOR_EACH_QUEUE(XGMAC_TX_QUEUES, queue_num) {
+		ret = devm_request_irq(priv->device,
+					(priv->txq[queue_num])->irq_no,
+					xgmac_tx_interrupt, 0,
+					dev->name, priv->txq[queue_num]);
+		if (unlikely(ret < 0)) {
+			pr_err("%s: ERROR: allocating TX IRQ %d (error: %d)\n",
+				__func__, dev->irq, ret);
+			goto init_error;
+		}
+	}
+
+	/* Request RX DMA irq lines */
+	XGMAC_FOR_EACH_QUEUE(XGMAC_RX_QUEUES, queue_num) {
+		ret = devm_request_irq(priv->device,
+					(priv->rxq[queue_num])->irq_no,
+					xgmac_rx_interrupt, 0,
+					dev->name, priv->rxq[queue_num]);
+		if (unlikely(ret < 0)) {
+			pr_err("%s: ERROR: allocating TX IRQ %d (error: %d)\n",
+				__func__, dev->irq, ret);
+			goto init_error;
+		}
+	}
+
+	/* Enable the MAC Rx/Tx */
+	priv->hw->mac->enable_tx(priv->ioaddr, true);
+	priv->hw->mac->enable_rx(priv->ioaddr, true);
+
+	/* Set the HW DMA mode and the COE */
+	xgmac_mtl_operation_mode(priv);
+
+	/* Extra statistics */
+	memset(&priv->xstats, 0, sizeof(struct xgmac_extra_stats));
+
+	priv->xstats.tx_threshold = tx_tc;
+	priv->xstats.rx_threshold = rx_tc;
+
+	/* Start the ball rolling... */
+	pr_debug("%s: DMA RX/TX processes started...\n", dev->name);
+	priv->hw->dma->start_tx(priv->ioaddr, XGMAC_TX_QUEUES);
+	priv->hw->dma->start_rx(priv->ioaddr, XGMAC_RX_QUEUES);
+
+	if (priv->phydev)
+		phy_start(priv->phydev);
+
+	/* initalise TX coalesce parameters */
+	xgmac_tx_init_coalesce(priv);
+
+	if ((priv->use_riwt) && (priv->hw->dma->rx_watchdog)) {
+		priv->rx_riwt = XGMAC_MAX_DMA_RIWT;
+		priv->hw->dma->rx_watchdog(priv->ioaddr, XGMAC_MAX_DMA_RIWT);
+	}
+
+	napi_enable(&priv->napi);
+	netif_start_queue(dev);
+
+	return 0;
+
+init_error:
+	free_dma_desc_resources(priv);
+	if (priv->phydev)
+		phy_disconnect(priv->phydev);
+phy_error:
+	clk_disable_unprepare(priv->xgmac_clk);
+
+	return ret;
+}
+
+/**
+ *  xgmac_release - close entry point of the driver
+ *  @dev : device pointer.
+ *  Description:
+ *  This is the stop entry point of the driver.
+ */
+static int xgmac_release(struct net_device *dev)
+{
+	struct xgmac_priv_data *priv = netdev_priv(dev);
+
+	/* Stop and disconnect the PHY */
+	if (priv->phydev) {
+		phy_stop(priv->phydev);
+		phy_disconnect(priv->phydev);
+		priv->phydev = NULL;
+	}
+
+	netif_tx_stop_all_queues(dev);
+
+	napi_disable(&priv->napi);
+
+	/* delete TX timers */
+	xgmac_tx_del_timer(priv);
+
+	/* Stop TX/RX DMA and clear the descriptors */
+	priv->hw->dma->stop_tx(priv->ioaddr, XGMAC_TX_QUEUES);
+	priv->hw->dma->stop_rx(priv->ioaddr, XGMAC_RX_QUEUES);
+
+	/* disable MTL queue */
+	xgmac_disable_mtl_engine(priv);
+
+	/* Release and free the Rx/Tx resources */
+	free_dma_desc_resources(priv);
+
+	/* Disable the MAC Rx/Tx */
+	priv->hw->mac->enable_tx(priv->ioaddr, false);
+	priv->hw->mac->enable_rx(priv->ioaddr, false);
+
+	netif_carrier_off(dev);
+
+	clk_disable_unprepare(priv->xgmac_clk);
+
+	return 0;
+
+}
+
+/**
+ *  xgmac_xmit: Tx entry point of the driver
+ *  @skb : the socket buffer
+ *  @dev : device pointer
+ *  Description : this is the tx entry point of the driver.
+ *  It programs the chain or the ring and supports oversized frames
+ *  and SG feature.
+ */
+static netdev_tx_t xgmac_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	unsigned int entry, frag_num;
+	struct netdev_queue *dev_txq;
+	unsigned txq_index = skb_get_queue_mapping(skb);
+	struct xgmac_priv_data *priv = netdev_priv(dev);
+	unsigned int tx_rsize = priv->dma_tx_size;
+	struct xgmac_tx_queue *tqueue = priv->txq[txq_index];
+	struct xgmac_tx_norm_desc *tx_desc, *first_desc;
+	int nr_frags = skb_shinfo(skb)->nr_frags;
+	int no_pagedlen = skb_headlen(skb);
+	int is_jumbo = 0;
+
+	/* get the TX queue handle */
+	dev_txq = netdev_get_tx_queue(dev, txq_index);
+
+	/* get the spinlock */
+	spin_lock(&tqueue->tx_lock);
+
+	if (unlikely(xgmac_tx_avail(tqueue, tx_rsize) < nr_frags + 1)) {
+		if (!netif_tx_queue_stopped(dev_txq)) {
+			netif_tx_stop_queue(dev_txq);
+			pr_err("%s: Tx Ring is full when %d queue is awake\n",
+				__func__, txq_index);
+		}
+		/* release the spin lock in case of BUSY */
+		spin_unlock(&tqueue->tx_lock);
+		return NETDEV_TX_BUSY;
+	}
+
+	entry = tqueue->cur_tx % tx_rsize;
+	tx_desc = tqueue->dma_tx + entry;
+
+	first_desc = tx_desc;
+
+	/* save the skb address */
+	tqueue->tx_skbuff[entry] = skb;
+
+	if (!is_jumbo) {
+		tx_desc->tdes01 = dma_map_single(priv->device, skb->data,
+						   no_pagedlen, DMA_TO_DEVICE);
+		if (dma_mapping_error(priv->device, tx_desc->tdes01))
+			pr_err("%s: TX dma mapping failed!!\n", __func__);
+
+		priv->hw->desc->prepare_tx_desc(tx_desc, 1, no_pagedlen,
+						no_pagedlen);
+	}
+
+	for (frag_num = 0; frag_num < nr_frags; frag_num++) {
+		const skb_frag_t *frag = &skb_shinfo(skb)->frags[frag_num];
+		int len = skb_frag_size(frag);
+		entry = (++tqueue->cur_tx) % tx_rsize;
+		tx_desc = tqueue->dma_tx + entry;
+		tx_desc->tdes01 = skb_frag_dma_map(priv->device, frag, 0, len,
+						   DMA_TO_DEVICE);
+
+		tqueue->tx_skbuff_dma[entry] = tx_desc->tdes01;
+		tqueue->tx_skbuff[entry] = NULL;
+
+		/* prepare the descriptor */
+		priv->hw->desc->prepare_tx_desc(tx_desc, 0, len,
+						len);
+		/* memory barrier to flush descriptor */
+		wmb();
+
+		/* set the owner */
+		priv->hw->desc->set_tx_owner(tx_desc);
+	}
+
+	/* close the descriptors */
+	priv->hw->desc->close_tx_desc(tx_desc);
+
+	/* memory barrier to flush descriptor */
+	wmb();
+
+	tqueue->tx_count_frames += nr_frags + 1;
+	if (tqueue->tx_count_frames > tqueue->tx_coal_frames) {
+		priv->hw->desc->clear_tx_ic(tx_desc);
+		priv->xstats.tx_reset_ic_bit++;
+		mod_timer(&tqueue->txtimer,
+			 XGMAC_COAL_TIMER(tqueue->tx_coal_timer));
+	} else
+		tqueue->tx_count_frames = 0;
+
+	/* set owner for first desc */
+	priv->hw->desc->set_tx_owner(first_desc);
+
+	/* memory barrier to flush descriptor */
+	wmb();
+
+	tqueue->cur_tx++;
+
+	/* display current ring */
+	if (netif_msg_pktdata(priv)) {
+		pr_debug("%s: curr %d dirty=%d entry=%d, first=%p, nfrags=%d",
+			__func__, (tqueue->cur_tx % tx_rsize),
+			(tqueue->dirty_tx % tx_rsize), entry,
+			first_desc, nr_frags);
+
+		pr_debug(">>> xgmac: tx frame to be transmitted: ");
+		print_pkt(skb->data, skb->len);
+	}
+
+	if (unlikely(xgmac_tx_avail(tqueue, tx_rsize) <= (MAX_SKB_FRAGS + 1))) {
+		if (netif_msg_hw(priv))
+			pr_debug("%s: stop transmitted packets\n", __func__);
+		netif_tx_stop_queue(dev_txq);
+	}
+
+	dev->stats.tx_bytes += skb->len;
+
+	if (unlikely((skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
+		     tqueue->hwts_tx_en)) {
+		/* declare that device is doing timestamping */
+		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
+		priv->hw->desc->tx_enable_tstamp(first_desc);
+	}
+
+	if (!tqueue->hwts_tx_en)
+		skb_tx_timestamp(skb);
+
+	priv->hw->dma->enable_dma_transmission(priv->ioaddr, txq_index);
+
+	spin_unlock(&tqueue->tx_lock);
+
+	return NETDEV_TX_OK;
+}
+
+/**
+ * xgmac_rx_refill: refill used skb preallocated buffers
+ * @priv: driver private structure
+ * Description : this is to reallocate the skb for the reception process
+ * that is based on zero-copy.
+ */
+static void xgmac_rx_refill(struct xgmac_priv_data *priv)
+{
+	unsigned int rxsize = priv->dma_rx_size;
+	int bfsize = priv->dma_buf_sz;
+	u8 qnum = priv->cur_rx_qnum;
+
+	for (; priv->rxq[qnum]->cur_rx - priv->rxq[qnum]->dirty_rx > 0;
+	     priv->rxq[qnum]->dirty_rx++) {
+		unsigned int entry = priv->rxq[qnum]->dirty_rx % rxsize;
+		struct xgmac_rx_norm_desc *p;
+
+		p = priv->rxq[qnum]->dma_rx + entry;
+
+		if (likely(priv->rxq[qnum]->rx_skbuff[entry] == NULL)) {
+			struct sk_buff *skb;
+
+			skb = netdev_alloc_skb_ip_align(priv->dev, bfsize);
+
+			if (unlikely(skb == NULL))
+				break;
+
+			priv->rxq[qnum]->rx_skbuff[entry] = skb;
+			priv->rxq[qnum]->rx_skbuff_dma[entry] =
+			    dma_map_single(priv->device, skb->data, bfsize,
+					   DMA_FROM_DEVICE);
+
+			p->rdes23.rx_rd_des23.buf2_addr =
+					priv->rxq[qnum]->rx_skbuff_dma[entry];
+		}
+
+		/* Added memory barrier for RX descriptor modification */
+		wmb();
+		priv->hw->desc->set_rx_owner(p);
+		/* Added memory barrier for RX descriptor modification */
+		wmb();
+	}
+}
+
+/**
+ * xgmac_rx: receive the frames from the remote host
+ * @priv: driver private structure
+ * @limit: napi bugget.
+ * Description :  this the function called by the napi poll method.
+ * It gets all the frames inside the ring.
+ */
+static int xgmac_rx(struct xgmac_priv_data *priv, int limit)
+{
+	u8 qnum = priv->cur_rx_qnum;
+	unsigned int rxsize = priv->dma_rx_size;
+	unsigned int entry = priv->rxq[qnum]->cur_rx;
+	unsigned int next_entry = 0;
+	unsigned int count = 0;
+
+	while (count < limit) {
+		struct xgmac_rx_norm_desc *p;
+		struct sk_buff *skb;
+		int frame_len;
+
+		p = priv->rxq[qnum]->dma_rx + entry;
+
+		if (priv->hw->desc->get_rx_owner(p))
+			break;
+
+		count++;
+
+		next_entry = (++priv->rxq[qnum]->cur_rx) % rxsize;
+		prefetch(priv->rxq[qnum]->dma_rx + next_entry);
+
+		/*TO DO read the status of the incoming frame */
+
+		skb = priv->rxq[qnum]->rx_skbuff[entry];
+
+		if (unlikely(!skb)) {
+			pr_err("%s: rx descriptor is not in consistent\n",
+				priv->dev->name);
+		}
+
+		prefetch(skb->data - NET_IP_ALIGN);
+		priv->rxq[qnum]->rx_skbuff[entry] = NULL;
+
+		frame_len = priv->hw->desc->get_rx_frame_len(p);
+
+		skb_put(skb, frame_len);
+
+		netif_receive_skb(skb);
+
+		entry = next_entry;
+	}
+
+	xgmac_rx_refill(priv);
+
+	return count;
+}
+
+/**
+ *  xgmac_poll - xgmac poll method (NAPI)
+ *  @napi : pointer to the napi structure.
+ *  @budget : maximum number of packets that the current CPU can receive from
+ *	      all interfaces.
+ *  Description :
+ *  To look at the incoming frames and clear the tx resources.
+ */
+static int xgmac_poll(struct napi_struct *napi, int budget)
+{
+	struct xgmac_priv_data *priv = container_of(napi,
+					struct xgmac_priv_data, napi);
+	int work_done = 0;
+	u8 qnum = priv->cur_rx_qnum;
+
+	priv->xstats.napi_poll++;
+	/* first, clean the tx queues */
+	xgmac_tx_all_clean(priv);
+
+	work_done = xgmac_rx(priv, budget);
+	if (work_done < budget) {
+		napi_complete(napi);
+		priv->hw->dma->enable_dma_irq(priv->ioaddr, qnum);
+	}
+
+	return work_done;
+}
+
+/**
+ *  xgmac_tx_timeout
+ *  @dev : Pointer to net device structure
+ *  Description: this function is called when a packet transmission fails to
+ *   complete within a reasonable time. The driver will mark the error in the
+ *   netdev structure and arrange for the device to be reset to a sane state
+ *   in order to transmit a new packet.
+ */
+static void xgmac_tx_timeout(struct net_device *dev)
+{
+	struct xgmac_priv_data *priv = netdev_priv(dev);
+	xgmac_reset_all_tx_queues(priv);
+}
+
+/**
+ *  xgmac_common_interrupt - main ISR
+ *  @irq: interrupt number.
+ *  @dev_id: to pass the net device pointer.
+ *  Description: this is the main driver interrupt service routine.
+ *  It calls the DMA ISR and also the core ISR to manage PMT, MMC, LPI
+ *  interrupts.
+ */
+static irqreturn_t xgmac_common_interrupt(int irq, void *dev_id)
+{
+	return IRQ_HANDLED;
+}
+
+/**
+ *  xgmac_tx_interrupt - TX DMA ISR
+ *  @irq: interrupt number.
+ *  @dev_id: to pass the net device pointer.
+ *  Description: this is the tx dma interrupt service routine.
+ */
+static irqreturn_t xgmac_tx_interrupt(int irq, void *dev_id)
+{
+	int status;
+	struct xgmac_tx_queue *txq = (struct xgmac_tx_queue *)dev_id;
+	struct xgmac_priv_data *priv = txq->priv_ptr;
+
+	/* get the channel status */
+	status = priv->hw->dma->tx_dma_int_status(priv->ioaddr, txq->queue_no,
+						&priv->xstats);
+	/* check for normal path */
+	if (likely((status & handle_tx)))
+		napi_schedule(&priv->napi);
+
+	/* check for unrecoverable error */
+	if (unlikely((status & tx_hard_error)))
+		xgmac_restart_tx_queue(priv, txq->queue_no);
+
+	/* check for TC configuration change */
+	if (unlikely((status & tx_bump_tc) &&
+		     (tx_tc != XGMAC_MTL_SFMODE) && (tx_tc < 512))) {
+		/* step of TX TC is 32 till 128, otherwise 64 */
+		tx_tc += (tx_tc < 128) ? 32 : 64;
+		priv->hw->mtl->set_tx_mtl_mode(priv->ioaddr,
+					       txq->queue_no, tx_tc);
+		priv->xstats.tx_threshold = tx_tc;
+	}
+
+	return IRQ_HANDLED;
+}
+
+/**
+ *  xgmac_rx_interrupt - RX DMA ISR
+ *  @irq: interrupt number.
+ *  @dev_id: to pass the net device pointer.
+ *  Description: this is the rx dma interrupt service routine.
+ */
+static irqreturn_t xgmac_rx_interrupt(int irq, void *dev_id)
+{
+	int status;
+	struct xgmac_rx_queue *rxq = (struct xgmac_rx_queue *)dev_id;
+	struct xgmac_priv_data *priv = rxq->priv_ptr;
+
+	/* get the channel status */
+	status = priv->hw->dma->rx_dma_int_status(priv->ioaddr, rxq->queue_no,
+						&priv->xstats);
+
+	if (likely((status & handle_rx) && (napi_schedule_prep(&priv->napi)))) {
+		priv->hw->dma->disable_dma_irq(priv->ioaddr, rxq->queue_no);
+		__napi_schedule(&priv->napi);
+	}
+
+	/* check for TC configuration change */
+	if (unlikely((status & rx_bump_tc) &&
+		     (rx_tc != XGMAC_MTL_SFMODE) && (rx_tc < 128))) {
+		/* step of TC is 32 */
+		rx_tc += 32;
+		priv->hw->mtl->set_rx_mtl_mode(priv->ioaddr,
+					       rxq->queue_no, rx_tc);
+		priv->xstats.rx_threshold = rx_tc;
+	}
+
+	return IRQ_HANDLED;
+}
+
+/*  xgmac_get_stats64 - entry point to see statistical information of device
+ *  @dev : device pointer.
+ *  @stats : pointer to hold all the statistical information of device.
+ *  Description:
+ *  This function is a driver entry point whenever ifconfig command gets
+ *  executed to see device statistics. Statistics are number of
+ *  bytes sent or received, errors occured etc.
+ *  Return value:
+ *  This function returns various statistical information of device.
+ */
+static struct rtnl_link_stats64 *xgmac_get_stats64(struct net_device *dev,
+						struct rtnl_link_stats64 *stats)
+{
+	struct xgmac_priv_data *priv = netdev_priv(dev);
+	void __iomem *ioaddr = priv->ioaddr;
+	u64 count;
+
+	spin_lock(&priv->stats_lock);
+	/* Freeze the counter registers before reading value otherwise it may
+	 * get updated by hardware while we are reading them
+	 */
+	writel(XGMAC_MMC_CTRL_CNT_FRZ, ioaddr + XGMAC_MMC_CTL_REG);
+
+	stats->rx_bytes = readl(ioaddr + XGMAC_MMC_RXOCTETLO_GCNT_REG);
+	stats->rx_bytes |= (u64)(readl(ioaddr + XGMAC_MMC_RXOCTETHI_GCNT_REG))
+				<< 32;
+	stats->rx_packets = readl(ioaddr + XGMAC_MMC_RXFRAMELO_GBCNT_REG);
+	stats->rx_packets |=
+		(u64)(readl(ioaddr + XGMAC_MMC_RXFRAMEHI_GBCNT_REG)) << 32;
+	stats->multicast = readl(ioaddr + XGMAC_MMC_RXMULTILO_GCNT_REG);
+	stats->multicast |= (u64)(readl(ioaddr + XGMAC_MMC_RXMULTIHI_GCNT_REG))
+				<< 32;
+	stats->rx_crc_errors = readl(ioaddr + XGMAC_MMC_RXCRCERRLO_REG);
+	stats->rx_crc_errors |= (u64)(readl(ioaddr + XGMAC_MMC_RXCRCERRHI_REG))
+				<< 32;
+	stats->rx_length_errors = readl(ioaddr + XGMAC_MMC_RXLENERRLO_REG);
+	stats->rx_length_errors |=
+			(u64)(readl(ioaddr + XGMAC_MMC_RXLENERRHI_REG))	<< 32;
+	stats->rx_missed_errors = readl(ioaddr +
+				 XGMAC_MMC_RXFIFOOVERFLOWLO_GBCNT_REG);
+	stats->rx_missed_errors |= (u64)(readl(ioaddr +
+				 XGMAC_MMC_RXFIFOOVERFLOWHI_GBCNT_REG));
+
+	stats->tx_bytes = readl(ioaddr + XGMAC_MMC_TXOCTETLO_GCNT_REG);
+	stats->tx_bytes |=
+		(u64)(readl(ioaddr + XGMAC_MMC_TXOCTETHI_GCNT_REG)) << 32;
+
+	count = readl(ioaddr + XGMAC_MMC_TXFRAMELO_GBCNT_REG);
+	count |= (u64)(readl(ioaddr + XGMAC_MMC_TXFRAMEHI_GBCNT_REG)) << 32;
+	stats->tx_errors = readl(ioaddr + XGMAC_MMC_TXFRAMELO_GCNT_REG);
+	stats->tx_errors |= (u64)(readl(ioaddr + XGMAC_MMC_TXFRAMEHI_GCNT_REG))
+				<< 32;
+	stats->tx_errors = count - stats->tx_errors;
+	stats->tx_packets = count;
+	stats->tx_fifo_errors = readl(ioaddr + XGMAC_MMC_TXUFLWLO_GBCNT_REG);
+	stats->tx_fifo_errors |= (u64)(readl(ioaddr +
+				 XGMAC_MMC_TXUFLWHI_GBCNT_REG));
+
+	writel(0, ioaddr + XGMAC_MMC_CTL_REG);
+	spin_unlock(&priv->stats_lock);
+	return stats;
+}
+
+/*  xgmac_set_features - entry point to set offload features of the device.
+ *  @dev : device pointer.
+ *  @features : features which are required to be set.
+ *  Description:
+ *  This function is a driver entry point and called by Linux kernel whenever
+ *  any device features are set or reset by user.
+ *  Return value:
+ *  This function returns 0 after setting or resetting device features.
+ */
+static int xgmac_set_features(struct net_device *dev,
+			      netdev_features_t features)
+{
+	struct xgmac_priv_data *priv = netdev_priv(dev);
+	netdev_features_t changed = dev->features ^ features;
+	u32 ctrl;
+
+	if (changed & NETIF_F_RXCSUM) {
+		ctrl = readl(priv->ioaddr + XGMAC_CORE_RX_CONFIG_REG);
+		if (features & NETIF_F_RXCSUM)
+			ctrl |= XGMAC_RX_CSUMOFFLOAD_ENABLE;
+		else
+			ctrl &= ~XGMAC_RX_CSUMOFFLOAD_ENABLE;
+		writel(ctrl, priv->ioaddr + XGMAC_CORE_RX_CONFIG_REG);
+	}
+
+	return 0;
+}
+
+/*  xgmac_change_mtu - entry point to change MTU size for the device.
+ *  @dev : device pointer.
+ *  @new_mtu : the new MTU size for the device.
+ *  Description: the Maximum Transfer Unit (MTU) is used by the network layer
+ *  to drive packet transmission. Ethernet has an MTU of 1500 octets
+ *  (ETH_DATA_LEN). This value can be changed with ifconfig.
+ *  Return value:
+ *  0 on success and an appropriate (-)ve integer as defined in errno.h
+ *  file on failure.
+ */
+static int xgmac_change_mtu(struct net_device *dev, int new_mtu)
+{
+	/* RFC 791, page 25, "Every internet module must be able to forward
+	 * a datagram of 68 octets without further fragmentation."
+	 */
+	if (new_mtu < MIN_MTU || (new_mtu > MAX_MTU)) {
+		pr_err("%s: invalid MTU, MTU should be in between %d and %d\n"
+		       , dev->name, MIN_MTU, MAX_MTU);
+		return -EINVAL;
+	}
+
+	/* Return if the buffer sizes will not change */
+	if (dev->mtu == new_mtu)
+		return 0;
+
+	dev->mtu = new_mtu;
+
+	if (!netif_running(dev))
+		return 0;
+
+	/* Recevice ring buffer size is needed to be set based on MTU. If MTU is
+	 * changed then reinitilisation of the receive ring buffers need to be
+	 * done. Hence bring interface down and bring interface back up
+	 */
+	xgmac_release(dev);
+	return xgmac_open(dev);
+}
+
+static void xgmac_set_umac_addr(void __iomem *ioaddr, unsigned char *addr,
+				unsigned int reg_n)
+{
+	unsigned long data;
+
+	data = (addr[5] << 8) | addr[4];
+	/* For MAC Addr registers se have to set the Address Enable (AE)
+	 * bit that has no effect on the High Reg 0 where the bit 31 (MO)
+	 * is RO.
+	 */
+	writel(data | XGMAC_HI_REG_AE, ioaddr + XGMAC_ADDR_HIGH(reg_n));
+	data = (addr[3] << 24) | (addr[2] << 16) | (addr[1] << 8) | addr[0];
+	writel(data, ioaddr + XGMAC_ADDR_LOW(reg_n));
+}
+
+/* xgmac_set_rx_mode - entry point for setting different receive mode of
+ * a device. unicast, multicast addressing
+ * @dev : pointer to the device structure
+ * Description:
+ * This function is a driver entry point which gets called by the kernel
+ * whenever different receive mode like unicast, multicast and promiscuous
+ * must be enabled/disabled.
+ * Return value:
+ * void.
+ */
+static void xgmac_set_rx_mode(struct net_device *dev)
+{
+	struct xgmac_priv_data *priv = netdev_priv(dev);
+	void __iomem *ioaddr = (void __iomem *)priv->ioaddr;
+	unsigned int value = 0;
+	u32 mc_filter[2];
+	struct netdev_hw_addr *ha;
+	int reg = 1;
+
+	pr_debug("%s: # mcasts %d, # unicast %d\n", __func__,
+		 netdev_mc_count(dev), netdev_uc_count(dev));
+
+	if (dev->flags & IFF_PROMISC)
+		value = XGMAC_FRAME_FILTER_PR;
+	else if ((netdev_mc_count(dev) > XGMAC_HASH_TABLE_SIZE)
+		 || (dev->flags & IFF_ALLMULTI)) {
+		value = XGMAC_FRAME_FILTER_PM;	/* pass all multi */
+		writel(0xffffffff, ioaddr + XGMAC_HASH_HIGH);
+		writel(0xffffffff, ioaddr + XGMAC_HASH_LOW);
+	} else if (!netdev_mc_empty(dev)) {
+		/* Hash filter for multicast */
+		value = XGMAC_FRAME_FILTER_HMC;
+
+		memset(mc_filter, 0, sizeof(mc_filter));
+		netdev_for_each_mc_addr(ha, dev) {
+			/* The upper 6 bits of the calculated CRC are used to
+			 * index the contens of the hash table
+			 */
+			int bit_nr = bitrev32(~crc32_le(~0, ha->addr, 6)) >> 26;
+			/* The most significant bit determines the register to
+			 * use (H/L) while the other 5 bits determine the bit
+			 * within the register.
+			 */
+			mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
+		}
+		writel(mc_filter[0], ioaddr + XGMAC_HASH_LOW);
+		writel(mc_filter[1], ioaddr + XGMAC_HASH_HIGH);
+	}
+
+	/* Handle multiple unicast addresses (perfect filtering) */
+	if (netdev_uc_count(dev) > XGMAC_MAX_PERFECT_ADDRESSES)
+		/* Switch to promiscuous mode if more than 16 addrs
+		 * are required
+		 */
+		value |= XGMAC_FRAME_FILTER_PR;
+	else {
+		netdev_for_each_uc_addr(ha, dev) {
+			xgmac_set_umac_addr(ioaddr, ha->addr, reg);
+			reg++;
+		}
+	}
+#ifdef FRAME_FILTER_DEBUG
+	/* Enable Receive all mode (to debug filtering_fail errors) */
+	value |= XGMAC_FRAME_FILTER_RA;
+#endif
+	writel(value, ioaddr + XGMAC_FRAME_FILTER);
+
+	pr_debug("\tFilter: 0x%08x\n\tHash: HI 0x%08x, LO 0x%08x\n",
+	readl(ioaddr + XGMAC_FRAME_FILTER),
+	readl(ioaddr + XGMAC_HASH_HIGH), readl(ioaddr + XGMAC_HASH_LOW));
+}
+
+/* xgmac_config - entry point for changing configuration mode passed on by
+ * ifconfig
+ * @dev : pointer to the device structure
+ * @map : pointer to the device mapping structure
+ * Description:
+ * This function is a driver entry point which gets called by the kernel
+ * whenever some device configuration is changed.
+ * Return value:
+ * This function returns 0 if success and appropriate error otherwise.
+ */
+static int xgmac_config(struct net_device *dev, struct ifmap *map)
+{
+	/* Can't act on a running interface */
+	if (dev->flags & IFF_UP)
+		return -EBUSY;
+
+	/* Don't allow changing the I/O address */
+	if (map->base_addr != dev->base_addr) {
+		pr_warn("%s: can't change I/O address\n", dev->name);
+		return -EOPNOTSUPP;
+	}
+
+	/* Don't allow changing the IRQ */
+	if (map->irq != dev->irq) {
+		pr_warn("%s: not change IRQ number %d\n", dev->name, dev->irq);
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/* xgmac_poll_controller - entry point for polling receive by device
+ * @dev : pointer to the device structure
+ * Description:
+ * This function is used by NETCONSOLE and other diagnostic tools
+ * to allow network I/O with interrupts disabled.
+ * Return value:
+ * Void.
+ */
+static void xgmac_poll_controller(struct net_device *dev)
+{
+	disable_irq(dev->irq);
+	xgmac_rx_interrupt(dev->irq, dev);
+	enable_irq(dev->irq);
+}
+#endif
+
+/*  xgmac_ioctl - Entry point for the Ioctl
+ *  @dev: Device pointer.
+ *  @rq: An IOCTL specefic structure, that can contain a pointer to
+ *  a proprietary structure used to pass information to the driver.
+ *  @cmd: IOCTL command
+ *  Description:
+ *  Currently it supports the phy_mii_ioctl(...) and HW time stamping.
+ */
+static int xgmac_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
+{
+	struct xgmac_priv_data *priv = netdev_priv(dev);
+	int ret = -EOPNOTSUPP;
+
+	if (!netif_running(dev))
+		return -EINVAL;
+
+	switch (cmd) {
+	case SIOCGMIIPHY:
+	case SIOCGMIIREG:
+	case SIOCSMIIREG:
+		if (!priv->phydev)
+			return -EINVAL;
+		ret = phy_mii_ioctl(priv->phydev, rq, cmd);
+		break;
+	default:
+		break;
+	}
+
+	return ret;
+}
+
+static const struct net_device_ops xgmac_netdev_ops = {
+	.ndo_open = xgmac_open,
+	.ndo_start_xmit = xgmac_xmit,
+	.ndo_stop = xgmac_release,
+	.ndo_get_stats64 = xgmac_get_stats64,
+	.ndo_change_mtu = xgmac_change_mtu,
+	.ndo_set_features = xgmac_set_features,
+	.ndo_set_rx_mode = xgmac_set_rx_mode,
+	.ndo_tx_timeout = xgmac_tx_timeout,
+	.ndo_do_ioctl = xgmac_ioctl,
+	.ndo_set_config = xgmac_config,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller = xgmac_poll_controller,
+#endif
+	.ndo_set_mac_address = eth_mac_addr,
+};
+
+/* get the hardware ops */
+void xgmac_get_ops(struct xgmac_ops * const ops_ptr)
+{
+	ops_ptr->mac = xgmac_get_core_ops();
+	ops_ptr->desc = xgmac_get_desc_ops();
+	ops_ptr->dma = xgmac_get_dma_ops();
+	ops_ptr->mtl = xgmac_get_mtl_ops();
+
+	/* set the MDIO communication Address/Data regisers */
+	ops_ptr->mii.addr = XGMAC_MDIO_SCMD_ADD_REG;
+	ops_ptr->mii.data = XGMAC_MDIO_SCMD_DATA_REG;
+
+	/* Assigning the default link settings
+	 * no XGMAC defined default values to be set in registers,
+	 * so assigning as 0 for port and duplex
+	 */
+	ops_ptr->link.port = 0;
+	ops_ptr->link.duplex = 0;
+	ops_ptr->link.speed = XGMAC_SPEED_10G;
+}
+
+/**
+ *  xgmac_hw_init - Init the GMAC device
+ *  @priv: driver private structure
+ *  Description: this function checks the HW capability
+ *  (if supported) and sets the driver's features.
+ */
+static int xgmac_hw_init(struct xgmac_priv_data * const priv)
+{
+	u32 ctrl_ids;
+
+	/* get the hardware ops */
+	xgmac_get_ops(priv->hw);
+
+	/* get the controller id */
+	ctrl_ids = priv->hw->mac->get_controller_version(priv->ioaddr);
+	priv->hw->ctrl_uid = (ctrl_ids & 0x00ff0000) >> 16;
+	priv->hw->ctrl_id = (ctrl_ids & 0x000000ff);
+	pr_info("xgmac - user ID: 0x%x, Controller ID: 0x%x\n",
+			priv->hw->ctrl_uid, priv->hw->ctrl_id);
+
+	/* get the H/W features */
+	if (!xgmac_get_hw_features(priv))
+		pr_info("XGMAC Hardware features not found\n");
+
+	if (priv->hw_cap.tx_csum_offload)
+		pr_info("XGMAC: TX Checksum offload supported\n");
+
+	if (priv->hw_cap.rx_csum_offload)
+		pr_info("XGMAC: RX Checksum offload supported\n");
+
+	return 0;
+}
+
+/**
+ * xgmac_dvr_probe
+ * @device: device pointer
+ * @plat_dat: platform data pointer
+ * @addr: iobase memory address
+ * Description: this is the main probe function used to
+ * call the alloc_etherdev, allocate the priv structure.
+ */
+struct xgmac_priv_data *xgmac_dvr_probe(struct device *device,
+				     struct xgmac_plat_data *plat_dat,
+				     void __iomem *addr)
+{
+	int ret = 0;
+	struct net_device *ndev = NULL;
+	struct xgmac_priv_data *priv;
+
+	ndev = alloc_etherdev_mqs(sizeof(struct xgmac_priv_data),
+				 XGMAC_TX_QUEUES, XGMAC_RX_QUEUES);
+	if (!ndev)
+		return NULL;
+
+	SET_NETDEV_DEV(ndev, device);
+
+	priv = netdev_priv(ndev);
+	priv->device = device;
+	priv->dev = ndev;
+
+	ether_setup(ndev);
+
+	xgmac_set_ethtool_ops(ndev);
+	priv->pause = pause;
+	priv->plat = plat_dat;
+	priv->ioaddr = addr;
+	priv->dev->base_addr = (unsigned long)addr;
+
+	/* Verify driver arguments */
+	xgmac_verify_args();
+
+	/* Override with kernel parameters if supplied
+	 */
+	if ((xgmac_phyaddr >= 0) && (xgmac_phyaddr <= 31))
+		priv->plat->phy_addr = xgmac_phyaddr;
+
+	/* Init MAC and get the capabilities */
+	ret = xgmac_hw_init(priv);
+	if (ret)
+		goto error_free_netdev;
+
+	/* allocate memory resources for Descriptor rings */
+	ret = txring_mem_alloc(priv);
+	if (ret)
+		goto error_free_netdev;
+
+	ret = rxring_mem_alloc(priv);
+	if (ret)
+		goto error_free_netdev;
+
+	ndev->netdev_ops = &xgmac_netdev_ops;
+
+	ndev->hw_features = NETIF_F_SG | NETIF_F_RXCSUM;
+	ndev->features |= ndev->hw_features | NETIF_F_HIGHDMA;
+	ndev->watchdog_timeo = msecs_to_jiffies(watchdog);
+
+	/* assign filtering support */
+	ndev->priv_flags |= IFF_UNICAST_FLT;
+
+	priv->msg_enable = netif_msg_init(debug, default_msg_level);
+
+	if (flow_ctrl)
+		priv->flow_ctrl = XGMAC_FLOW_AUTO;	/* RX/TX pause on */
+
+	/* Rx Watchdog is available, enable depend on platform data */
+	if (!priv->plat->riwt_off) {
+		priv->use_riwt = 1;
+		pr_info(" Enable RX Mitigation via HW Watchdog Timer\n");
+	}
+
+	netif_napi_add(ndev, &priv->napi, xgmac_poll, 64);
+
+	spin_lock_init(&priv->stats_lock);
+
+	ret = register_netdev(ndev);
+	if (ret) {
+		pr_err("%s: ERROR %i registering the device\n", __func__, ret);
+		goto error_netdev_register;
+	}
+
+	priv->xgmac_clk = clk_get(priv->device, XGMAC_RESOURCE_NAME);
+	if (IS_ERR(priv->xgmac_clk)) {
+		pr_warn("%s: warning: cannot get CSR clock\n", __func__);
+		goto error_clk_get;
+	}
+
+	/* If a specific clk_csr value is passed from the platform
+	 * this means that the CSR Clock Range selection cannot be
+	 * changed at run-time and it is fixed. Viceversa the driver'll try to
+	 * set the MDC clock dynamically according to the csr actual
+	 * clock input.
+	 */
+	if (!priv->plat->clk_csr)
+		xgmac_clk_csr_set(priv);
+	else
+		priv->clk_csr = priv->plat->clk_csr;
+
+	/* MDIO bus Registration */
+	ret = xgmac_mdio_register(ndev);
+	if (ret < 0) {
+		pr_debug("%s: MDIO bus (id: %d) registration failed",
+				__func__, priv->plat->bus_id);
+		goto error_mdio_register;
+	}
+
+	xgmac_check_ether_addr(priv);
+
+	return priv;
+
+error_mdio_register:
+	clk_put(priv->xgmac_clk);
+error_clk_get:
+	unregister_netdev(ndev);
+error_netdev_register:
+	netif_napi_del(&priv->napi);
+error_free_netdev:
+	free_netdev(ndev);
+
+	return NULL;
+}
+
+/**
+ * xgmac_dvr_remove
+ * @ndev: net device pointer
+ * Description: this function resets the TX/RX processes, disables the MAC RX/TX
+ * changes the link status, releases the DMA descriptor rings.
+ */
+int xgmac_dvr_remove(struct net_device *ndev)
+{
+	struct xgmac_priv_data *priv = netdev_priv(ndev);
+
+	pr_info("%s:\n\tremoving driver", __func__);
+
+	priv->hw->dma->stop_rx(priv->ioaddr, XGMAC_RX_QUEUES);
+	priv->hw->dma->stop_tx(priv->ioaddr, XGMAC_TX_QUEUES);
+
+	priv->hw->mac->enable_tx(priv->ioaddr, false);
+	priv->hw->mac->enable_rx(priv->ioaddr, false);
+
+	xgmac_mdio_unregister(ndev);
+
+	netif_carrier_off(ndev);
+
+	unregister_netdev(ndev);
+
+	free_netdev(ndev);
+
+	return 0;
+}
+
+#ifdef CONFIG_PM
+int xgmac_suspend(struct net_device *ndev)
+{
+	return 0;
+}
+
+int xgmac_resume(struct net_device *ndev)
+{
+	return 0;
+}
+
+int xgmac_freeze(struct net_device *ndev)
+{
+	return -ENOSYS;
+}
+
+int xgmac_restore(struct net_device *ndev)
+{
+	return -ENOSYS;
+}
+#endif /* CONFIG_PM */
+
+/* Driver is configured as Platf drivers
+ */
+static int __init xgmac_init(void)
+{
+	int ret;
+
+	ret = xgmac_register_platform();
+	if (ret)
+		goto err;
+	return 0;
+err:
+	pr_err("xgmac: driver registration failed\n");
+	return ret;
+}
+
+static void __exit xgmac_exit(void)
+{
+	xgmac_unregister_platform();
+}
+
+module_init(xgmac_init);
+module_exit(xgmac_exit);
+
+#ifndef MODULE
+static int __init xgmac_cmdline_opt(char *str)
+{
+	return 0;
+}
+
+__setup("xgmaceth=", xgmac_cmdline_opt);
+#endif /* MODULE */
+
+
+
+MODULE_DESCRIPTION("SAMSUNG 10G/2.5G/1G Ethernet PLATFORM driver");
+
+MODULE_PARM_DESC(watchdog, "Transmit timeout in milliseconds (default 5s)");
+MODULE_PARM_DESC(debug, "Message Level (-1: default, 0: no output, 16: all)");
+MODULE_PARM_DESC(xgmac_phyaddr, "Physical device address");
+MODULE_PARM_DESC(dma_txsize, "Number of descriptors in the per channel TX list");
+MODULE_PARM_DESC(dma_rxsize, "Number of descriptors in the per channel RX list");
+MODULE_PARM_DESC(flow_ctrl, "Flow control ability [on/off]");
+MODULE_PARM_DESC(pause, "Flow Control Pause Time");
+MODULE_PARM_DESC(tx_tc, "TX MTL threshold control value");
+MODULE_PARM_DESC(rx_tc, "RX MTL threshold control value");
+MODULE_PARM_DESC(buf_sz, "DMA buffer size");
+
+MODULE_AUTHOR("Siva Reddy Kallam <siva.kallam@samsung.com>");
+MODULE_AUTHOR("ByungHo An <bh74.an@samsung.com>");
+MODULE_AUTHOR("Girish K S <ks.giri@samsung.com>");
+MODULE_AUTHOR("Vipul Pandya <vipul.pandya@samsung.com>");
+
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/samsung/xgmac_mdio.c b/drivers/net/ethernet/samsung/xgmac_mdio.c
new file mode 100644
index 0000000..647a7bd
--- /dev/null
+++ b/drivers/net/ethernet/samsung/xgmac_mdio.c
@@ -0,0 +1,274 @@
+/* 10G controller driver for Samsung SoCs
+ *
+ * Copyright (C) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ *
+ * Author: Siva Reddy Kallam <siva.kallam@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#include <linux/io.h>
+#include <linux/mii.h>
+#include <linux/netdevice.h>
+#include <linux/platform_device.h>
+#include <linux/phy.h>
+#include <linux/slab.h>
+#include <linux/xgmac_platform.h>
+
+#include "xgmac_common.h"
+#include "xgmac_reg.h"
+
+#define XGMAC_SMA_WRITE_CMD	0x01 /* write command */
+#define XGMAC_SMA_PREAD_CMD	0x02 /* post read  increament address */
+#define XGMAC_SMA_READ_CMD	0x03 /* read command */
+#define XGMAC_SMA_SKIP_ADDRFRM	0x00040000 /* skip the address frame */
+#define XGMAC_MII_BUSY		0x00800000 /* mii busy */
+
+static int xgmac_mdio_busy_wait(void __iomem *ioaddr, unsigned int mii_data)
+{
+	unsigned long cur_time;
+	unsigned long fin_time = jiffies + 3 * HZ; /* 30 ms */
+
+	do {
+		cur_time = jiffies;
+		if (readl(ioaddr + mii_data) & XGMAC_MII_BUSY)
+			cpu_relax();
+		else
+			return 0;
+	} while (!time_after_eq(cur_time, fin_time));
+
+	return -EBUSY;
+}
+
+/**
+ * xgmac_mdio_read
+ * @bus: points to the mii_bus structure
+ * @phyaddr: address of phy port
+ * @phyreg: address of register with in phy register
+ * Description: this function used for C45 and C22 MDIO Read
+ */
+static int xgmac_mdio_read(struct mii_bus *bus, int phyaddr, int phyreg)
+{
+	struct net_device *ndev = bus->priv;
+	struct xgmac_priv_data *priv = netdev_priv(ndev);
+	u32 devaddr, reg_val;
+	u32 mii_addr = priv->hw->mii.addr;
+	u32 mii_data = priv->hw->mii.data;
+
+	/* check for busy wait */
+	if (xgmac_mdio_busy_wait(priv->ioaddr, mii_data))
+		return -EBUSY;
+
+	if (phyreg & MII_ADDR_C45) {
+		devaddr = (phyreg >> 16) & 0x1F;
+		/* set mdio address register */
+		reg_val = (phyaddr << 16) | (devaddr << 21) |
+			  (phyreg & 0xFFFF);
+		writel(reg_val, priv->ioaddr + mii_addr);
+
+		/* set mdio control/data register */
+		reg_val = (XGMAC_SMA_READ_CMD << 16) | XGMAC_SMA_SKIP_ADDRFRM |
+			  ((priv->clk_csr & 0x7) << 19) | XGMAC_MII_BUSY;
+		writel(reg_val, priv->ioaddr + mii_data);
+	} else {
+		/* configure the port for C22
+		 * ports 0-3 only supports C22
+		 */
+		if (phyaddr < 4)
+			writel((1 << phyaddr),
+				priv->ioaddr + XGMAC_MDIO_CLAUSE22_PORT_REG);
+		else
+			return -ENODEV;
+		/* set mdio address register */
+		reg_val = (phyaddr << 16) | (phyreg & 0x1F);
+		writel(reg_val, priv->ioaddr + mii_addr);
+
+		/* set mdio control/data register */
+		reg_val = (XGMAC_SMA_READ_CMD << 16) | XGMAC_SMA_SKIP_ADDRFRM |
+			  ((priv->clk_csr & 0x7) << 19) | XGMAC_MII_BUSY;
+		writel(reg_val, priv->ioaddr + mii_data);
+	}
+
+	/* wait till operation succeds */
+	if (xgmac_mdio_busy_wait(priv->ioaddr, mii_data))
+		return -EBUSY;
+
+	/* read and return the data from mmi Data register */
+	reg_val = readl(priv->ioaddr + mii_data) & 0xFFFF;
+	return reg_val;
+}
+/**
+ * xgmac_mdio_write
+ * @bus: points to the mii_bus structure
+ * @phyaddr: address of phy port
+ * @phyreg: address of phy registers
+ * @phydata: data to be written into phy register
+ * Description: this function is used for C45 and C22 MDIO write
+ */
+static int xgmac_mdio_write(struct mii_bus *bus, int phyaddr, int phyreg,
+			     u16 phydata)
+{
+	struct net_device *ndev = bus->priv;
+	struct xgmac_priv_data *priv = netdev_priv(ndev);
+	u32 devaddr, reg_val;
+	u32 mii_addr = priv->hw->mii.addr;
+	u32 mii_data = priv->hw->mii.data;
+
+	/* check for busy wait */
+	if (xgmac_mdio_busy_wait(priv->ioaddr, mii_data))
+		return -EBUSY;
+
+	if (phyreg & MII_ADDR_C45) {
+		devaddr = (phyreg >> 16) & 0x1F;
+		/* set mdio address register */
+		reg_val = (phyaddr << 16) | (devaddr << 21) |
+			  (phyreg & 0xFFFF);
+		writel(reg_val, priv->ioaddr + mii_addr);
+
+		/* set mdio control/data register */
+		reg_val = (XGMAC_SMA_WRITE_CMD << 16) | XGMAC_SMA_SKIP_ADDRFRM |
+			  ((priv->clk_csr & 0x7) << 19) | XGMAC_MII_BUSY;
+		reg_val |= phydata;
+
+		writel(reg_val, priv->ioaddr + mii_data);
+	} else {
+		/* configure the port for C22
+		 * ports 0-3 only supports C22
+		 */
+		if (phyaddr < 4)
+			writel((1 << phyaddr),
+				priv->ioaddr + XGMAC_MDIO_CLAUSE22_PORT_REG);
+		else
+			return -ENODEV;
+
+		/* set mdio address register */
+		reg_val = (phyaddr << 16) | (phyreg & 0x1F);
+		writel(reg_val, priv->ioaddr + mii_addr);
+
+		/* set mdio control/data register */
+		reg_val = (XGMAC_SMA_WRITE_CMD << 16) | XGMAC_SMA_SKIP_ADDRFRM |
+			  ((priv->clk_csr & 0x7) << 19) | XGMAC_MII_BUSY;
+		reg_val |= phydata;
+		writel(reg_val, priv->ioaddr + mii_data);
+	}
+
+	/* wait till operation succeds */
+	if (xgmac_mdio_busy_wait(priv->ioaddr, mii_data))
+		return -EBUSY;
+
+	return 0;
+}
+
+int xgmac_mdio_register(struct net_device *ndev)
+{
+	int err, phy_addr, act;
+	int *irqlist;
+	u8 phy_found = 0;
+	struct mii_bus *mdio_bus;
+	struct xgmac_priv_data *priv = netdev_priv(ndev);
+	struct xgmac_mdio_bus_data *mdio_data = priv->plat->mdio_bus_data;
+
+	/* allocate the new mdio bus */
+	mdio_bus = mdiobus_alloc();
+	if (!mdio_bus) {
+		pr_err("%s : mii bus allocation failed\n",
+			__func__);
+		return -ENOMEM;
+	}
+
+	if (mdio_data->irqs)
+		irqlist = mdio_data->irqs;
+	else
+		irqlist = priv->mii_irq;
+
+	/* assign mii bus fields */
+	mdio_bus->name = "samxgmac";
+	mdio_bus->read = &xgmac_mdio_read;
+	mdio_bus->write = &xgmac_mdio_write;
+	snprintf(mdio_bus->id, MII_BUS_ID_SIZE, "%s-%x",
+		 mdio_bus->name, priv->plat->bus_id);
+	mdio_bus->priv = ndev;
+	mdio_bus->phy_mask = mdio_data->phy_mask;
+	mdio_bus->parent = priv->device;
+
+	/* register with kernel subsystem */
+	err = mdiobus_register(mdio_bus);
+	if (err != 0) {
+		pr_err("mdiobus register failed\n");
+		goto mdiobus_err;
+	}
+
+	for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
+		struct phy_device *phy = mdio_bus->phy_map[phy_addr];
+		if (phy) {
+			char irq_num[4];
+			char *irq_str;
+			/* If an IRQ was provided to be assigned after
+			 * the bus probe, do it here.
+			 */
+			if ((mdio_data->irqs == NULL) &&
+			    (mdio_data->probed_phy_irq > 0)) {
+				irqlist[phy_addr] = mdio_data->probed_phy_irq;
+				phy->irq = mdio_data->probed_phy_irq;
+			}
+
+			/* If we're  going to bind the MAC to this PHY bus,
+			 * and no PHY number was provided to the MAC,
+			 * use the one probed here.
+			 */
+			if (priv->plat->phy_addr == -1)
+				priv->plat->phy_addr = phy_addr;
+
+			act = (priv->plat->phy_addr == phy_addr);
+			switch (phy->irq) {
+			case PHY_POLL:
+				irq_str = "POLL";
+				break;
+			case PHY_IGNORE_INTERRUPT:
+				irq_str = "IGNORE";
+				break;
+			default:
+				sprintf(irq_num, "%d", phy->irq);
+				irq_str = irq_num;
+				break;
+			}
+			pr_info("%s: PHY ID %08x at %d IRQ %s (%s)%s\n",
+				ndev->name, phy->phy_id, phy_addr,
+				irq_str, dev_name(&phy->dev),
+				act ? " active" : "");
+			phy_found = 1;
+		}
+	}
+
+	if (!phy_found) {
+		pr_err("%s: PHY not found\n", ndev->name);
+		mdiobus_unregister(mdio_bus);
+		mdiobus_free(mdio_bus);
+		return -ENODEV;
+	}
+
+	priv->mii = mdio_bus;
+
+	return 0;
+
+mdiobus_err:
+	mdiobus_free(mdio_bus);
+	return err;
+}
+
+int xgmac_mdio_unregister(struct net_device *ndev)
+{
+	struct xgmac_priv_data *priv = netdev_priv(ndev);
+
+	if (!priv->mii)
+		return 0;
+
+	mdiobus_unregister(priv->mii);
+	priv->mii->priv = NULL;
+	mdiobus_free(priv->mii);
+	priv->mii = NULL;
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/samsung/xgmac_mtl.c b/drivers/net/ethernet/samsung/xgmac_mtl.c
new file mode 100644
index 0000000..c842aa0
--- /dev/null
+++ b/drivers/net/ethernet/samsung/xgmac_mtl.c
@@ -0,0 +1,238 @@
+/* 10G controller driver for Samsung SoCs
+ *
+ * Copyright (C) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ *
+ * Author: Siva Reddy Kallam <siva.kallam@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#include <linux/io.h>
+#include <linux/errno.h>
+#include <linux/export.h>
+#include <linux/jiffies.h>
+
+#include "xgmac_mtl.h"
+#include "xgmac_reg.h"
+
+static void xgmac_mtl_init(void __iomem *ioaddr, unsigned int etsalg,
+			   unsigned int raa)
+{
+	u32 reg_val;
+	reg_val = readl(ioaddr + XGMAC_MTL_OP_MODE_REG);
+	reg_val &= ETS_RST;
+
+	/* ETS Algorith */
+	switch (etsalg & XGMAC_MTL_OPMODE_ESTMASK) {
+	case ETS_WRR:
+		reg_val &= ETS_WRR;
+		break;
+	case ETS_WFQ:
+		reg_val |= ETS_WFQ;
+		break;
+	case ETS_DWRR:
+		reg_val |= ETS_DWRR;
+		break;
+	}
+	writel(reg_val, ioaddr + XGMAC_MTL_OP_MODE_REG);
+
+	switch (raa & XGMAC_MTL_OPMODE_RAAMASK) {
+	case RAA_SP:
+		reg_val &= RAA_SP;
+		break;
+	case RAA_WSP:
+		reg_val |= RAA_WSP;
+		break;
+	}
+	writel(reg_val, ioaddr + XGMAC_MTL_OP_MODE_REG);
+}
+
+/* For Dynamic DMA channel mapping for Rx queue */
+static void xgmac_mtl_dma_dm_rxqueue(void __iomem *ioaddr)
+{
+	writel(RX_QUEUE_DYNAMIC, ioaddr + XGMAC_MTL_RXQ_DMAMAP0_REG);
+	writel(RX_QUEUE_DYNAMIC, ioaddr + XGMAC_MTL_RXQ_DMAMAP1_REG);
+	writel(RX_QUEUE_DYNAMIC, ioaddr + XGMAC_MTL_RXQ_DMAMAP2_REG);
+}
+
+static void xgmac_mtl_set_txfifosize(void __iomem *ioaddr, int queue_num,
+				int queue_fifo)
+{
+	u32 fifo_bits, reg_val;
+	/* 0 means 256 bytes */
+	fifo_bits = (queue_fifo / XGMAC_MTL_TX_FIFO_DIV)-1;
+	reg_val = readl(ioaddr + XGMAC_MTL_TXQ_OPMODE_REG(queue_num));
+	reg_val |= (fifo_bits << XGMAC_MTL_FIFO_LSHIFT);
+	writel(reg_val, ioaddr + XGMAC_MTL_TXQ_OPMODE_REG(queue_num));
+}
+
+static void xgmac_mtl_set_rxfifosize(void __iomem *ioaddr, int queue_num,
+				int queue_fifo)
+{
+	u32 fifo_bits, reg_val;
+	/* 0 means 256 bytes */
+	fifo_bits = (queue_fifo / XGMAC_MTL_RX_FIFO_DIV)-1;
+	reg_val = readl(ioaddr + XGMAC_MTL_RXQ_OPMODE_REG(queue_num));
+	reg_val |= (fifo_bits << XGMAC_MTL_FIFO_LSHIFT);
+	writel(reg_val, ioaddr + XGMAC_MTL_RXQ_OPMODE_REG(queue_num));
+}
+
+static void xgmac_mtl_enable_txqueue(void __iomem *ioaddr, int queue_num)
+{
+	u32 reg_val;
+	reg_val = readl(ioaddr + XGMAC_MTL_TXQ_OPMODE_REG(queue_num));
+	reg_val |= XGMAC_MTL_ENABLE_QUEUE;
+	writel(reg_val, ioaddr + XGMAC_MTL_TXQ_OPMODE_REG(queue_num));
+}
+
+static void xgmac_mtl_disable_txqueue(void __iomem *ioaddr, int queue_num)
+{
+	u32 reg_val;
+	reg_val = readl(ioaddr + XGMAC_MTL_TXQ_OPMODE_REG(queue_num));
+	reg_val &= ~XGMAC_MTL_ENABLE_QUEUE;
+	writel(reg_val, ioaddr + XGMAC_MTL_TXQ_OPMODE_REG(queue_num));
+}
+
+static void xgmac_mtl_fc_active(void __iomem *ioaddr, int queue_num,
+				int threshold)
+{
+	u32 reg_val;
+	reg_val = readl(ioaddr + XGMAC_MTL_RXQ_OPMODE_REG(queue_num));
+	reg_val &= ~(XGMAC_MTL_FCMASK << RX_FC_ACTIVE);
+	reg_val |= (threshold << RX_FC_ACTIVE);
+
+	writel(reg_val, ioaddr + XGMAC_MTL_RXQ_OPMODE_REG(queue_num));
+}
+
+static void xgmac_mtl_fc_enable(void __iomem *ioaddr, int queue_num)
+{
+	u32 reg_val;
+	reg_val = readl(ioaddr + XGMAC_MTL_RXQ_OPMODE_REG(queue_num));
+	reg_val |= XGMAC_MTL_ENABLE_FC;
+	writel(reg_val, ioaddr + XGMAC_MTL_RXQ_OPMODE_REG(queue_num));
+}
+
+static void xgmac_mtl_fc_deactive(void __iomem *ioaddr, int queue_num,
+				  int threshold)
+{
+	u32 reg_val;
+	reg_val = readl(ioaddr + XGMAC_MTL_RXQ_OPMODE_REG(queue_num));
+	reg_val &= ~(XGMAC_MTL_FCMASK << RX_FC_DEACTIVE);
+	reg_val |= (threshold << RX_FC_DEACTIVE);
+
+	writel(reg_val, ioaddr + XGMAC_MTL_RXQ_OPMODE_REG(queue_num));
+}
+
+static void xgmac_mtl_fep_enable(void __iomem *ioaddr, int queue_num)
+{
+	u32 reg_val;
+	reg_val = readl(ioaddr + XGMAC_MTL_RXQ_OPMODE_REG(queue_num));
+	reg_val |= XGMAC_MTL_RXQ_OP_FEP;
+
+	writel(reg_val, ioaddr + XGMAC_MTL_RXQ_OPMODE_REG(queue_num));
+}
+
+static void xgmac_mtl_fep_disable(void __iomem *ioaddr, int queue_num)
+{
+	u32 reg_val;
+	reg_val = readl(ioaddr + XGMAC_MTL_RXQ_OPMODE_REG(queue_num));
+	reg_val &= ~(XGMAC_MTL_RXQ_OP_FEP);
+
+	writel(reg_val, ioaddr + XGMAC_MTL_RXQ_OPMODE_REG(queue_num));
+}
+
+static void xgmac_mtl_fup_enable(void __iomem *ioaddr, int queue_num)
+{
+	u32 reg_val;
+	reg_val = readl(ioaddr + XGMAC_MTL_RXQ_OPMODE_REG(queue_num));
+	reg_val |= XGMAC_MTL_RXQ_OP_FUP;
+
+	writel(reg_val, ioaddr + XGMAC_MTL_RXQ_OPMODE_REG(queue_num));
+}
+
+static void xgmac_mtl_fup_disable(void __iomem *ioaddr, int queue_num)
+{
+	u32 reg_val;
+	reg_val = readl(ioaddr + XGMAC_MTL_RXQ_OPMODE_REG(queue_num));
+	reg_val &= ~(XGMAC_MTL_RXQ_OP_FUP);
+
+	writel(reg_val, ioaddr + XGMAC_MTL_RXQ_OPMODE_REG(queue_num));
+}
+
+
+static void xgmac_set_tx_mtl_mode(void __iomem *ioaddr, int queue_num,
+				  int tx_mode)
+{
+	u32 reg_val;
+
+	reg_val = readl(ioaddr + XGMAC_MTL_TXQ_OPMODE_REG(queue_num));
+	/* TX specific MTL mode settings */
+	if (tx_mode == XGMAC_MTL_SFMODE)
+		reg_val |= XGMAC_MTL_SFMODE;
+	else {
+		/* set the TTC values */
+		if (tx_mode <= 64)
+			reg_val |= MTL_CONTROL_TTC_64;
+		else if (tx_mode <= 96)
+			reg_val |= MTL_CONTROL_TTC_96;
+		else if (tx_mode <= 128)
+			reg_val |= MTL_CONTROL_TTC_128;
+		else if (tx_mode <= 192)
+			reg_val |= MTL_CONTROL_TTC_192;
+		else if (tx_mode <= 256)
+			reg_val |= MTL_CONTROL_TTC_256;
+		else if (tx_mode <= 384)
+			reg_val |= MTL_CONTROL_TTC_384;
+		else
+			reg_val |= MTL_CONTROL_TTC_512;
+	}
+
+	/* write into TXQ operation register */
+	writel(reg_val, ioaddr + XGMAC_MTL_TXQ_OPMODE_REG(queue_num));
+}
+
+static void xgmac_set_rx_mtl_mode(void __iomem *ioaddr, int queue_num,
+				  int rx_mode)
+{
+	u32 reg_val;
+	reg_val = readl(ioaddr + XGMAC_MTL_RXQ_OPMODE_REG(queue_num));
+	/* RX specific MTL mode settings */
+	if (rx_mode == XGMAC_RX_MTL_SFMODE) {
+		reg_val |= XGMAC_RX_MTL_SFMODE;
+	} else {
+		if (rx_mode <= 64)
+			reg_val |= MTL_CONTROL_RTC_64;
+		else if (rx_mode <= 96)
+			reg_val |= MTL_CONTROL_RTC_96;
+		else if (rx_mode <= 128)
+			reg_val |= MTL_CONTROL_RTC_128;
+	}
+
+	/* write into RXQ operation register */
+	writel(reg_val, ioaddr + XGMAC_MTL_RXQ_OPMODE_REG(queue_num));
+}
+
+static const struct xgmac_mtl_ops mtl_ops = {
+	.mtl_set_txfifosize = xgmac_mtl_set_txfifosize,
+	.mtl_set_rxfifosize = xgmac_mtl_set_rxfifosize,
+	.mtl_enable_txqueue = xgmac_mtl_enable_txqueue,
+	.mtl_disable_txqueue = xgmac_mtl_disable_txqueue,
+	.mtl_dynamic_dma_rxqueue = xgmac_mtl_dma_dm_rxqueue,
+	.set_tx_mtl_mode = xgmac_set_tx_mtl_mode,
+	.set_rx_mtl_mode = xgmac_set_rx_mtl_mode,
+	.mtl_init = xgmac_mtl_init,
+	.mtl_fc_active = xgmac_mtl_fc_active,
+	.mtl_fc_deactive = xgmac_mtl_fc_deactive,
+	.mtl_fc_enable = xgmac_mtl_fc_enable,
+	.mtl_fep_enable = xgmac_mtl_fep_enable,
+	.mtl_fep_disable = xgmac_mtl_fep_disable,
+	.mtl_fup_enable = xgmac_mtl_fup_enable,
+	.mtl_fup_disable = xgmac_mtl_fup_disable
+};
+
+const struct xgmac_mtl_ops *xgmac_get_mtl_ops(void)
+{
+	return &mtl_ops;
+}
diff --git a/drivers/net/ethernet/samsung/xgmac_mtl.h b/drivers/net/ethernet/samsung/xgmac_mtl.h
new file mode 100644
index 0000000..888fa8f
--- /dev/null
+++ b/drivers/net/ethernet/samsung/xgmac_mtl.h
@@ -0,0 +1,104 @@
+/* 10G controller driver for Samsung SoCs
+ *
+ * Copyright (C) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ *
+ * Author: Siva Reddy Kallam <siva.kallam@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#ifndef __XGMAC_MTL_H__
+#define __XGMAC_MTL_H__
+
+#define XGMAC_MTL_OPMODE_ESTMASK	0x3
+#define XGMAC_MTL_OPMODE_RAAMASK	0x1
+#define XGMAC_MTL_FCMASK		0x7
+#define XGMAC_MTL_TX_FIFO_DIV		256
+#define XGMAC_MTL_RX_FIFO_DIV		256
+
+#define XGMAC_MTL_RXQ_OP_FEP		BIT(4)
+#define XGMAC_MTL_RXQ_OP_FUP		BIT(3)
+#define XGMAC_MTL_ENABLE_FC		0x80
+
+#define ETS_WRR				0xFFFFFF9F
+#define ETS_RST				0xFFFFFF9F
+#define ETS_WFQ				0x00000020
+#define ETS_DWRR			0x00000040
+#define RAA_SP				0xFFFFFFFB
+#define RAA_WSP				0x00000004
+
+#define RX_QUEUE_DYNAMIC		0x80808080
+#define RX_FC_ACTIVE			8
+#define RX_FC_DEACTIVE			13
+
+enum ttc_control {
+	MTL_CONTROL_TTC_64 = 0x00000000,
+	MTL_CONTROL_TTC_96 = 0x00000020,
+	MTL_CONTROL_TTC_128 = 0x00000030,
+	MTL_CONTROL_TTC_192 = 0x00000040,
+	MTL_CONTROL_TTC_256 = 0x00000050,
+	MTL_CONTROL_TTC_384 = 0x00000060,
+	MTL_CONTROL_TTC_512 = 0x00000070,
+};
+
+enum rtc_control {
+	MTL_CONTROL_RTC_64 = 0x00000000,
+	MTL_CONTROL_RTC_96 = 0x00000002,
+	MTL_CONTROL_RTC_128 = 0x00000003,
+};
+
+enum flow_control_th {
+	MTL_FC_FULL_1K = 0x00000000,
+	MTL_FC_FULL_2K = 0x00000001,
+	MTL_FC_FULL_4K = 0x00000002,
+	MTL_FC_FULL_5K = 0x00000003,
+	MTL_FC_FULL_6K = 0x00000004,
+	MTL_FC_FULL_8K = 0x00000005,
+	MTL_FC_FULL_16K = 0x00000006,
+	MTL_FC_FULL_24K = 0x00000007,
+};
+
+struct xgmac_mtl_ops {
+	void (*mtl_init)(void __iomem *ioaddr, unsigned int etsalg,
+			unsigned int raa);
+
+	void (*mtl_set_txfifosize)(void __iomem *ioaddr, int queue_num,
+				    int mtl_fifo);
+
+	void (*mtl_set_rxfifosize)(void __iomem *ioaddr, int queue_num,
+					  int queue_fifo);
+
+	void (*mtl_enable_txqueue)(void __iomem *ioaddr, int queue_num);
+
+	void (*mtl_disable_txqueue)(void __iomem *ioaddr, int queue_num);
+
+	void (*set_tx_mtl_mode)(void __iomem *ioaddr, int queue_num,
+				 int tx_mode);
+
+	void (*set_rx_mtl_mode)(void __iomem *ioaddr, int queue_num,
+				 int rx_mode);
+
+	void (*mtl_dynamic_dma_rxqueue)(void __iomem *ioaddr);
+
+	void (*mtl_fc_active)(void __iomem *ioaddr, int queue_num,
+			       int threshold);
+
+	void (*mtl_fc_deactive)(void __iomem *ioaddr, int queue_num,
+				 int threshold);
+
+	void (*mtl_fc_enable)(void __iomem *ioaddr, int queue_num);
+
+	void (*mtl_fep_enable)(void __iomem *ioaddr, int queue_num);
+
+	void (*mtl_fep_disable)(void __iomem *ioaddr, int queue_num);
+
+	void (*mtl_fup_enable)(void __iomem *ioaddr, int queue_num);
+
+	void (*mtl_fup_disable)(void __iomem *ioaddr, int queue_num);
+};
+
+const struct xgmac_mtl_ops *xgmac_get_mtl_ops(void);
+
+#endif /* __XGMAC_MTL_H__ */
diff --git a/drivers/net/ethernet/samsung/xgmac_platform.c b/drivers/net/ethernet/samsung/xgmac_platform.c
new file mode 100644
index 0000000..1bb327a2
--- /dev/null
+++ b/drivers/net/ethernet/samsung/xgmac_platform.c
@@ -0,0 +1,264 @@
+/* 10G controller driver for Samsung SoCs
+ *
+ * Copyright (C) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ *
+ * Author: Siva Reddy Kallam <siva.kallam@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#include <linux/etherdevice.h>
+#include <linux/io.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/of.h>
+#include <linux/of_irq.h>
+#include <linux/of_net.h>
+#include <linux/phy.h>
+#include <linux/platform_device.h>
+#include <linux/xgmac_platform.h>
+
+#include "xgmac_common.h"
+#include "xgmac_reg.h"
+
+#ifdef CONFIG_OF
+static int xgmac_probe_config_dt(struct platform_device *pdev,
+				  struct xgmac_plat_data *plat,
+				  const char **mac)
+{
+	struct device_node *np = pdev->dev.of_node;
+	struct xgmac_dma_cfg *dma_cfg;
+	u32 phy_addr;
+
+	if (!np)
+		return -ENODEV;
+
+	*mac = of_get_mac_address(np);
+	plat->interface = of_get_phy_mode(np);
+
+	plat->bus_id = of_alias_get_id(np, "ethernet");
+	if (plat->bus_id < 0)
+		plat->bus_id = 0;
+
+	of_property_read_u32(np, "samsung,phy-addr", &plat->phy_addr);
+
+	plat->mdio_bus_data = devm_kzalloc(&pdev->dev,
+					   sizeof(struct xgmac_mdio_bus_data),
+					   GFP_KERNEL);
+
+	if (of_device_is_compatible(np, "samsung,xgmac-v2.0a"))
+		plat->pmt = 1;
+
+	plat->force_sf_dma_mode = of_property_read_bool(np,
+					"samsung,force_sf_dma_mode");
+
+	dma_cfg = devm_kzalloc(&pdev->dev, sizeof(*dma_cfg), GFP_KERNEL);
+	if (!dma_cfg)
+		return -ENOMEM;
+
+	plat->dma_cfg = dma_cfg;
+	of_property_read_u32(np, "samsung,pbl", &dma_cfg->pbl);
+	of_property_read_u32(np, "samsung,burst-map", &dma_cfg->burst_map);
+	dma_cfg->fixed_burst = of_property_read_bool(np, "samsung,fixed-burst");
+	dma_cfg->adv_addr_mode = of_property_read_bool(np,
+							"samsung,adv-addr-mode");
+
+	plat->force_thresh_dma_mode = of_property_read_bool(np,
+					"samsung,force_thresh_dma_mode");
+	if (plat->force_thresh_dma_mode) {
+		plat->force_sf_dma_mode = 0;
+		pr_warn("force_sf_dma_mode is ignored as force_thresh_dma_mode is set.");
+	}
+
+	return 0;
+}
+#else
+static int xgmac_probe_config_dt(struct platform_device *pdev,
+				  struct xgmac_plat_data *plat,
+				  const char **mac)
+{
+	return -ENOSYS;
+}
+#endif /* CONFIG_OF */
+
+/**
+ * xgmac_platform_probe
+ * @pdev: platform device pointer
+ * Description: platform_device probe function. It allocates
+ * the necessary resources and invokes the main to init
+ * the net device, register the mdio bus etc.
+ */
+static int xgmac_platform_probe(struct platform_device *pdev)
+{
+	int ret = 0;
+	int loop = 0;
+	int index1, index2;
+	struct resource *res;
+	struct device *dev = &pdev->dev;
+	void __iomem *addr = NULL;
+	struct xgmac_priv_data *priv = NULL;
+	struct xgmac_plat_data *plat_dat = NULL;
+	const char *mac = NULL;
+	int total_dma_channels = XGMAC_TX_QUEUES + XGMAC_RX_QUEUES;
+
+	/* Get memory resource */
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!res)
+		return -ENODEV;
+
+	addr = devm_ioremap_resource(dev, res);
+	if (IS_ERR(addr))
+		return PTR_ERR(addr);
+
+	plat_dat = pdev->dev.platform_data;
+	if (pdev->dev.of_node) {
+		if (!plat_dat)
+			plat_dat = devm_kzalloc(&pdev->dev,
+					sizeof(struct xgmac_plat_data),
+					GFP_KERNEL);
+		if (!plat_dat) {
+			pr_err("%s: ERROR: no memory", __func__);
+			return  -ENOMEM;
+		}
+
+		ret = xgmac_probe_config_dt(pdev, plat_dat, &mac);
+		if (ret) {
+			pr_err("%s: main dt probe failed", __func__);
+			return ret;
+		}
+	}
+
+	priv = xgmac_dvr_probe(&(pdev->dev), plat_dat, addr);
+	if (!priv) {
+		pr_err("%s: main driver probe failed", __func__);
+		return -ENODEV;
+	}
+
+	/* Get MAC address if available (DT) */
+	if (mac)
+		ether_addr_copy(priv->dev->dev_addr, mac);
+
+	/* Get the XGMAC common INT information */
+	priv->dev->irq  = irq_of_parse_and_map(dev->of_node, loop++);
+	if (priv->dev->irq <= 0) {
+		dev_err(dev, "xgmac common irq parsing failed\n");
+		return -EINVAL;
+	}
+
+	/* Get the TX/RX IRQ numbers */
+	for (index1 = 0, index2 = 0 ; loop < total_dma_channels; loop++) {
+		if (loop < XGMAC_TX_QUEUES) {
+			(priv->txq[index1])->irq_no  =
+				irq_of_parse_and_map(dev->of_node, loop);
+			if ((priv->txq[index1++])->irq_no <= 0) {
+				dev_err(dev, "xgmac tx irq parsing failed\n");
+				return -EINVAL;
+			}
+		} else {
+			(priv->rxq[index2])->irq_no  =
+				irq_of_parse_and_map(dev->of_node, loop);
+			if ((priv->rxq[index2++])->irq_no <= 0) {
+				dev_err(dev, "xgmac rx irq parsing failed\n");
+				return -EINVAL;
+			}
+		}
+	}
+
+	platform_set_drvdata(pdev, priv->dev);
+
+	pr_debug("XGMAC platform driver registration completed");
+
+	return 0;
+}
+
+/**
+ * xgmac_platform_remove
+ * @pdev: platform device pointer
+ * Description: this function calls the main to free the net resources
+ * and calls the platforms hook and release the resources (e.g. mem).
+ */
+static int xgmac_platform_remove(struct platform_device *pdev)
+{
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	int ret = xgmac_dvr_remove(ndev);
+
+	return ret;
+}
+
+#ifdef CONFIG_PM
+static int xgmac_platform_suspend(struct device *dev)
+{
+	struct net_device *ndev = dev_get_drvdata(dev);
+
+	return xgmac_suspend(ndev);
+}
+
+static int xgmac_platform_resume(struct device *dev)
+{
+	struct net_device *ndev = dev_get_drvdata(dev);
+
+	return xgmac_resume(ndev);
+}
+
+int xgmac_platform_freeze(struct device *dev)
+{
+	int ret;
+	struct net_device *ndev = dev_get_drvdata(dev);
+
+	ret = xgmac_freeze(ndev);
+
+	return ret;
+}
+
+int xgmac_platform_restore(struct device *dev)
+{
+	struct net_device *ndev = dev_get_drvdata(dev);
+
+	return xgmac_restore(ndev);
+}
+
+static const struct dev_pm_ops xgmac_platform_pm_ops = {
+	.suspend = xgmac_platform_suspend,
+	.resume = xgmac_platform_resume,
+	.freeze = xgmac_platform_freeze,
+	.thaw = xgmac_platform_restore,
+	.restore = xgmac_platform_restore,
+};
+#else
+static const struct dev_pm_ops xgmac_platform_pm_ops;
+#endif /* CONFIG_PM */
+
+static const struct of_device_id xgmac_dt_ids[] = {
+	{ .compatible = "samsung,xgmac-v2.0a"},
+	{ /* sentinel */ }
+};
+MODULE_DEVICE_TABLE(of, xgmac_dt_ids);
+
+struct platform_driver xgmac_platform_driver = {
+	.probe = xgmac_platform_probe,
+	.remove = xgmac_platform_remove,
+	.driver = {
+		   .name = XGMAC_RESOURCE_NAME,
+		   .owner = THIS_MODULE,
+		   .pm = &xgmac_platform_pm_ops,
+		   .of_match_table = of_match_ptr(xgmac_dt_ids),
+		   },
+};
+
+int xgmac_register_platform(void)
+{
+	int err;
+
+	err = platform_driver_register(&xgmac_platform_driver);
+	if (err)
+		pr_err("xgmac: failed to register the platform driver\n");
+
+	return err;
+}
+
+void xgmac_unregister_platform(void)
+{
+	platform_driver_unregister(&xgmac_platform_driver);
+}
diff --git a/drivers/net/ethernet/samsung/xgmac_reg.h b/drivers/net/ethernet/samsung/xgmac_reg.h
new file mode 100644
index 0000000..11ae281
--- /dev/null
+++ b/drivers/net/ethernet/samsung/xgmac_reg.h
@@ -0,0 +1,477 @@
+/* 10G controller driver for Samsung SoCs
+ *
+ * Copyright (C) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ *
+ * Author: Siva Reddy Kallam <siva.kallam@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#ifndef __XGMAC_REGMAP_H__
+#define __XGMAC_REGMAP_H__
+
+/* XGMAC MAC Registers */
+#define XGMAC_CORE_TX_CONFIG_REG	0x0000
+#define XGMAC_CORE_RX_CONFIG_REG	0x0004
+#define XGMAC_CORE_PKT_FILTER_REG	0x0008
+#define XGMAC_CORE_WATCHDOG_TIMEOUT_REG 0x000C
+#define XGMAC_CORE_HASH_TABLE_REG0	0x0010
+#define XGMAC_CORE_HASH_TABLE_REG1	0x0014
+#define XGMAC_CORE_HASH_TABLE_REG2	0x0018
+#define XGMAC_CORE_HASH_TABLE_REG3	0x001C
+#define XGMAC_CORE_HASH_TABLE_REG4	0x0020
+#define XGMAC_CORE_HASH_TABLE_REG5	0x0024
+#define XGMAC_CORE_HASH_TABLE_REG6	0x0028
+#define XGMAC_CORE_HASH_TABLE_REG7	0x002C
+/* VLAN Specific Registers */
+#define XGMAC_CORE_VLAN_TAG_REG		0x0050
+#define XGMAC_CORE_VLAN_HASHTAB_REG	0x0058
+#define XGMAC_CORE_VLAN_INSCTL_REG	0x0060
+#define XGMAC_CORE_VLAN_INNERCTL_REG	0x0064
+#define XGMAC_CORE_RX_ETHTYPE_MATCH_REG 0x006C
+
+/* Flow Contol Registers */
+#define XGMAC_CORE_TX_Q0_FLOWCTL_REG	0x0070
+#define XGMAC_CORE_TX_Q1_FLOWCTL_REG	0x0074
+#define XGMAC_CORE_TX_Q2_FLOWCTL_REG	0x0078
+#define XGMAC_CORE_TX_Q3_FLOWCTL_REG	0x007C
+#define XGMAC_CORE_TX_Q4_FLOWCTL_REG	0x0080
+#define XGMAC_CORE_TX_Q5_FLOWCTL_REG	0x0084
+#define XGMAC_CORE_TX_Q6_FLOWCTL_REG	0x0088
+#define XGMAC_CORE_TX_Q7_FLOWCTL_REG	0x008C
+#define XGMAC_CORE_RX_FLOWCTL_REG	0x0090
+#define XGMAC_CORE_RX_CTL0_REG		0x00A0
+#define XGMAC_CORE_RX_CTL1_REG		0x00A4
+#define XGMAC_CORE_RX_CTL2_REG		0x00A8
+#define XGMAC_CORE_RX_CTL3_REG		0x00AC
+
+/* Interrupt Registers */
+#define XGMAC_CORE_INT_STATUS_REG	0x00B0
+#define XGMAC_CORE_INT_ENABLE_REG	0x00B4
+#define XGMAC_CORE_RXTX_ERR_STATUS_REG	0x00B8
+#define XGMAC_CORE_PMT_CTL_STATUS_REG	0x00C0
+#define XGMAC_CORE_RWK_PKT_FILTER_REG	0x00C4
+#define XGMAC_CORE_VERSION_REG		0x0110
+#define XGMAC_CORE_DEBUG_REG		0x0114
+#define XGMAC_CORE_HW_FEA_REG(index)	(0x011C + index * 4)
+
+/* SMA(MDIO) module registers */
+#define XGMAC_MDIO_SCMD_ADD_REG		0x0200
+#define XGMAC_MDIO_SCMD_DATA_REG	0x0204
+#define XGMAC_MDIO_CCMD_WADD_REG	0x0208
+#define XGMAC_MDIO_CCMD_WDATA_REG	0x020C
+#define XGMAC_MDIO_CSCAN_PORT_REG	0x0210
+#define XGMAC_MDIO_INT_STATUS_REG	0x0214
+#define XGMAC_MDIO_INT_ENABLE_REG	0x0218
+#define XGMAC_MDIO_PORT_CONDCON_REG	0x021C
+#define XGMAC_MDIO_CLAUSE22_PORT_REG	0x0220
+
+/* port specific, addr = 0-3 */
+#define XGMAC_MDIO_DEV_BASE_REG		0x0230
+#define	XGMAC_MDIO_PORT_DEV_REG(addr) \
+		(XGMAC_MDIO_DEV_BASE_REG + (0x10 * addr) + 0x0)
+#define	XGMAC_MDIO_PORT_LSTATUS_REG(addr) \
+		(XGMAC_MDIO_DEV_BASE_REG + (0x10 * addr) + 0x4)
+#define	XGMAC_MDIO_PORT_ALIVE_REG(addr)	\
+		(XGMAC_MDIO_DEV_BASE_REG + (0x10 * addr) + 0x8)
+
+#define XGMAC_CORE_GPIO_CTL_REG		0x0278
+#define XGMAC_CORE_GPIO_STATUS_REG	0x027C
+
+/* Address registers for filtering */
+#define XGMAC_CORE_ADD_BASE_REG		0x0300
+
+/* addr = 0-31 */
+#define XGMAC_CORE_ADD_HIGHOFFSET(addr) \
+			(XGMAC_CORE_ADD_BASE_REG + (0x8 * addr) + 0x0)
+#define XGMAC_CORE_ADD_LOWOFFSET(addr)	\
+			(XGMAC_CORE_ADD_BASE_REG + (0x8 * addr) + 0x4)
+
+/* XGMAC MMC registers */
+#define XGMAC_MMC_CTL_REG		0x0800
+#define XGMAC_MMC_RXINT_STATUS_REG	0x0804
+#define XGMAC_MMC_TXINT_STATUS_REG	0x0808
+#define XGMAC_MMC_RXINT_ENABLE_REG	0x080C
+#define XGMAC_MMC_TXINT_ENABLE_REG	0x0810
+
+/* TX specific counters */
+#define XGMAC_MMC_TXOCTETHI_GBCNT_REG	0x0814
+#define XGMAC_MMC_TXOCTETLO_GBCNT_REG	0x0818
+#define XGMAC_MMC_TXFRAMELO_GBCNT_REG	0x081C
+#define XGMAC_MMC_TXFRAMEHI_GBCNT_REG	0x0820
+#define XGMAC_MMC_TXBROADLO_GCNT_REG	0x0824
+#define XGMAC_MMC_TXBROADHI_GCNT_REG	0x0828
+#define XGMAC_MMC_TXMULTILO_GCNT_REG	0x082C
+#define XGMAC_MMC_TXMULTIHI_GCNT_REG	0x0830
+#define XGMAC_MMC_TX64LO_GBCNT_REG	0x0834
+#define XGMAC_MMC_TX64HI_GBCNT_REG	0x0838
+#define XGMAC_MMC_TX65TO127LO_GBCNT_REG		0x083C
+#define XGMAC_MMC_TX65TO127HI_GBCNT_REG		0x0840
+#define XGMAC_MMC_TX128TO255LO_GBCNT_REG	0x0844
+#define XGMAC_MMC_TX128TO255HI_GBCNT_REG	0x0848
+#define XGMAC_MMC_TX256TO511LO_GBCNT_REG	0x084C
+#define XGMAC_MMC_TX256TO511HI_GBCNT_REG	0x0850
+#define XGMAC_MMC_TX512TO1023LO_GBCNT_REG	0x0854
+#define XGMAC_MMC_TX512TO1023HI_GBCNT_REG	0x0858
+#define XGMAC_MMC_TX1023TOMAXLO_GBCNT_REG	0x085C
+#define XGMAC_MMC_TX1023TOMAXHI_GBCNT_REG	0x0860
+#define XGMAC_MMC_TXUNICASTLO_GBCNT_REG		0x0864
+#define XGMAC_MMC_TXUNICASTHI_GBCNT_REG		0x0868
+#define XGMAC_MMC_TXMULTILO_GBCNT_REG		0x086C
+#define XGMAC_MMC_TXMULTIHI_GBCNT_REG		0x0870
+#define XGMAC_MMC_TXBROADLO_GBCNT_REG		0x0874
+#define XGMAC_MMC_TXBROADHI_GBCNT_REG		0x0878
+#define XGMAC_MMC_TXUFLWLO_GBCNT_REG		0x087C
+#define XGMAC_MMC_TXUFLWHI_GBCNT_REG		0x0880
+#define XGMAC_MMC_TXOCTETLO_GCNT_REG	0x0884
+#define XGMAC_MMC_TXOCTETHI_GCNT_REG	0x0888
+#define XGMAC_MMC_TXFRAMELO_GCNT_REG	0x088C
+#define XGMAC_MMC_TXFRAMEHI_GCNT_REG	0x0890
+#define XGMAC_MMC_TXPAUSELO_CNT_REG	0x0894
+#define XGMAC_MMC_TXPAUSEHI_CNT_REG	0x0898
+#define XGMAC_MMC_TXVLANLO_GCNT_REG	0x089C
+#define XGMAC_MMC_TXVLANHI_GCNT_REG	0x08A0
+
+/* RX specific counters */
+#define XGMAC_MMC_RXFRAMELO_GBCNT_REG	0x0900
+#define XGMAC_MMC_RXFRAMEHI_GBCNT_REG	0x0904
+#define XGMAC_MMC_RXOCTETLO_GBCNT_REG	0x0908
+#define XGMAC_MMC_RXOCTETHI_GBCNT_REG	0x090C
+#define XGMAC_MMC_RXOCTETLO_GCNT_REG	0x0910
+#define XGMAC_MMC_RXOCTETHI_GCNT_REG	0x0914
+#define XGMAC_MMC_RXBROADLO_GCNT_REG	0x0918
+#define XGMAC_MMC_RXBROADHI_GCNT_REG	0x091C
+#define XGMAC_MMC_RXMULTILO_GCNT_REG	0x0920
+#define XGMAC_MMC_RXMULTIHI_GCNT_REG	0x0924
+#define XGMAC_MMC_RXCRCERRLO_REG	0x0928
+#define XGMAC_MMC_RXCRCERRHI_REG	0x092C
+#define XGMAC_MMC_RXSHORT64BFRAME_ERR_REG	0x0930
+#define XGMAC_MMC_RXJABBERERR_REG		0x0934
+#define XGMAC_MMC_RXSHORT64BFRAME_COR_REG	0x0938
+#define XGMAC_MMC_RXOVERMAXFRAME_COR_REG	0x093C
+#define XGMAC_MMC_RX64LO_GBCNT_REG		0x0940
+#define XGMAC_MMC_RX64HI_GBCNT_REG		0x0944
+#define XGMAC_MMC_RX65TO127LO_GBCNT_REG		0x0948
+#define XGMAC_MMC_RX65TO127HI_GBCNT_REG		0x094C
+#define XGMAC_MMC_RX128TO255LO_GBCNT_REG	0x0950
+#define XGMAC_MMC_RX128TO255HI_GBCNT_REG	0x0954
+#define XGMAC_MMC_RX256TO511LO_GBCNT_REG	0x0958
+#define XGMAC_MMC_RX256TO511HI_GBCNT_REG	0x095C
+#define XGMAC_MMC_RX512TO1023LO_GBCNT_REG	0x0960
+#define XGMAC_MMC_RX512TO1023HI_GBCNT_REG	0x0964
+#define XGMAC_MMC_RX1023TOMAXLO_GBCNT_REG	0x0968
+#define XGMAC_MMC_RX1023TOMAXHI_GBCNT_REG	0x096C
+#define XGMAC_MMC_RXUNICASTLO_GCNT_REG		0x0970
+#define XGMAC_MMC_RXUNICASTHI_GCNT_REG		0x0974
+#define XGMAC_MMC_RXLENERRLO_REG		0x0978
+#define XGMAC_MMC_RXLENERRHI_REG		0x097C
+#define XGMAC_MMC_RXOUTOFRANGETYPELO_REG	0x0980
+#define XGMAC_MMC_RXOUTOFRANGETYPEHI_REG	0x0984
+#define XGMAC_MMC_RXPAUSELO_CNT_REG		0x0988
+#define XGMAC_MMC_RXPAUSEHI_CNT_REG		0x098C
+#define XGMAC_MMC_RXFIFOOVERFLOWLO_GBCNT_REG	0x0990
+#define XGMAC_MMC_RXFIFOOVERFLOWHI_GBCNT_REG	0x0994
+#define XGMAC_MMC_RXVLANLO_GBCNT_REG		0x0998
+#define XGMAC_MMC_RXVLANHI_GBCNT_REG		0x099C
+#define XGMAC_MMC_RXWATCHDOG_ERR_REG		0x09A0
+
+/* L3/L4 function registers */
+#define XGMAC_CORE_L34_ADDCTL_REG	0x0C00
+#define XGMAC_CORE_L34_ADDCTL_REG	0x0C00
+#define XGMAC_CORE_L34_DATA_REG		0x0C04
+
+/* ARP registers */
+#define XGMAC_CORE_ARP_ADD_REG		0x0C10
+
+/* RSS registers */
+#define XGMAC_CORE_RSS_CTL_REG		0x0C80
+#define XGMAC_CORE_RSS_ADD_REG		0x0C88
+#define XGMAC_CORE_RSS_DATA_REG		0x0C8C
+
+/* IEEE 1588 registers */
+#define XGMAC_CORE_TSTAMP_CTL_REG	0x0D00
+#define XGMAC_CORE_SUBSEC_INC_REG	0x0D04
+#define XGMAC_CORE_SYSTIME_SEC_REG	0x0D0C
+#define XGMAC_CORE_SYSTIME_NSEC_REG	0x0D10
+#define XGMAC_CORE_SYSTIME_SECUP_REG	0x0D14
+#define XGMAC_CORE_TSTAMP_ADD_REG	0x0D18
+#define XGMAC_CORE_SYSTIME_HWORD_REG	0x0D1C
+#define XGMAC_CORE_TSTAMP_STATUS_REG	0x0D20
+#define XGMAC_CORE_TXTIME_STATUSNSEC_REG 0x0D30
+#define XGMAC_CORE_TXTIME_STATUSSEC_REG	0x0D34
+
+/* Auxiliary registers */
+#define XGMAC_CORE_AUX_CTL_REG			 0x0D40
+#define XGMAC_CORE_AUX_TSTAMP_NSEC_REG		 0x0D48
+#define XGMAC_CORE_AUX_TSTAMP_SEC_REG		 0x0D4C
+#define XGMAC_CORE_AUX_TSTAMP_INGCOR_REG	 0x0D50
+#define XGMAC_CORE_AUX_TSTAMP_ENGCOR_REG	 0x0D54
+#define XGMAC_CORE_AUX_TSTAMP_INGCOR_NSEC_REG	 0x0D58
+#define XGMAC_CORE_AUX_TSTAMP_INGCOR_SUBNSEC_REG 0x0D5C
+#define XGMAC_CORE_AUX_TSTAMP_ENGCOR_NSEC_REG	 0x0D60
+#define XGMAC_CORE_AUX_TSTAMP_ENGCOR_SUBNSEC_REG 0x0D64
+
+/* PPS registers */
+#define XGMAC_CORE_PPS_CTL_REG		0x0D70
+#define XGMAC_CORE_PPS_BASE			0x0D80
+
+/* addr = 0 - 3 */
+#define XGMAC_CORE_PPS_TTIME_SEC_REG(addr) \
+		(XGMAC_CORE_PPS_BASE + (0x10 * addr) + 0x0)
+#define	XGMAC_CORE_PPS_TTIME_NSEC_REG(addr) \
+		(XGMAC_CORE_PPS_BASE + (0x10 * addr) + 0x4)
+#define	XGMAC_CORE_PPS_INTERVAL_REG(addr) \
+		(XGMAC_CORE_PPS_BASE + (0x10 * addr) + 0x8)
+#define	XGMAC_CORE_PPS_WIDTH_REG(addr) \
+		(XGMAC_CORE_PPS_BASE + (0x10 * addr) + 0xC)
+#define XGMAC_CORE_PTO_CTL_REG		0x0DC0
+#define XGMAC_CORE_SRCPORT_ITY0_REG	0x0DC4
+#define XGMAC_CORE_SRCPORT_ITY1_REG	0x0DC8
+#define XGMAC_CORE_SRCPORT_ITY2_REG	0x0DCC
+#define XGMAC_CORE_LOGMSG_LEVEL_REG	0x0DD0
+
+/* XGMAC MTL Registers */
+#define XGMAC_MTL_BASE_REG		0x1000
+#define XGMAC_MTL_OP_MODE_REG		(XGMAC_MTL_BASE_REG + 0x0000)
+#define XGMAC_MTL_DEBUG_CTL_REG		(XGMAC_MTL_BASE_REG + 0x0008)
+#define XGMAC_MTL_DEBUG_STATUS_REG	(XGMAC_MTL_BASE_REG + 0x000C)
+#define XGMAC_MTL_FIFO_DEBUGDATA_REG	(XGMAC_MTL_BASE_REG + 0x0010)
+#define XGMAC_MTL_INT_STATUS_REG	(XGMAC_MTL_BASE_REG + 0x0020)
+#define XGMAC_MTL_RXQ_DMAMAP0_REG	(XGMAC_MTL_BASE_REG + 0x0030)
+#define XGMAC_MTL_RXQ_DMAMAP1_REG	(XGMAC_MTL_BASE_REG + 0x0034)
+#define XGMAC_MTL_RXQ_DMAMAP2_REG	(XGMAC_MTL_BASE_REG + 0x0038)
+#define XGMAC_MTL_TX_PRTYMAP0_REG	(XGMAC_MTL_BASE_REG + 0x0040)
+#define XGMAC_MTL_TX_PRTYMAP1_REG	(XGMAC_MTL_BASE_REG + 0x0044)
+
+/* TC/Queue registers , qnum=0-15 */
+#define XGMAC_MTL_TC_TXBASE_REG		(XGMAC_MTL_BASE_REG + 0x0100)
+#define XGMAC_MTL_TXQ_OPMODE_REG(qnum) \
+		(XGMAC_MTL_TC_TXBASE_REG + (qnum * 0x80) + 0x00)
+#define XGMAC_MTL_SFMODE		BIT(1)
+#define XGMAC_MTL_FIFO_LSHIFT		16
+#define XGMAC_MTL_ENABLE_QUEUE		0x00000008
+#define XGMAC_MTL_TXQ_UNDERFLOW_REG(qnum) \
+		(XGMAC_MTL_TC_TXBASE_REG + (qnum * 0x80) + 0x04)
+#define XGMAC_MTL_TXQ_DEBUG_REG(qnum) \
+		(XGMAC_MTL_TC_TXBASE_REG + (qnum * 0x80) + 0x08)
+#define XGMAC_MTL_TXQ_ETSCTL_REG(qnum) \
+		(XGMAC_MTL_TC_TXBASE_REG + (qnum * 0x80) + 0x10)
+#define XGMAC_MTL_TXQ_ETSSTATUS_REG(qnum) \
+		(XGMAC_MTL_TC_TXBASE_REG + (qnum * 0x80) + 0x14)
+#define XGMAC_MTL_TXQ_QUANTWEIGHT_REG(qnum) \
+		(XGMAC_MTL_TC_TXBASE_REG + (qnum * 0x80) + 0x18)
+
+#define XGMAC_MTL_TC_RXBASE_REG		0x1140
+#define XGMAC_RX_MTL_SFMODE		BIT(5)
+#define XGMAC_MTL_RXQ_OPMODE_REG(qnum) \
+		(XGMAC_MTL_TC_RXBASE_REG + (qnum * 0x80) + 0x00)
+#define XGMAC_MTL_RXQ_MISPKTOVERFLOW_REG(qnum) \
+		(XGMAC_MTL_TC_RXBASE_REG + (qnum * 0x80) + 0x04)
+#define XGMAC_MTL_RXQ_DEBUG_REG(qnum) \
+		(XGMAC_MTL_TC_RXBASE_REG + (qnum * 0x80) + 0x08)
+#define XGMAC_MTL_RXQ_CTL_REG(qnum) \
+		(XGMAC_MTL_TC_RXBASE_REG + (qnum * 0x80) + 0x0C)
+#define XGMAC_MTL_RXQ_INTENABLE_REG(qnum) \
+		(XGMAC_MTL_TC_RXBASE_REG + (qnum * 0x80) + 0x30)
+#define XGMAC_MTL_RXQ_INTSTATUS_REG(qnum) \
+		(XGMAC_MTL_TC_RXBASE_REG + (qnum * 0x80) + 0x34)
+
+/* XGMAC DMA Registers */
+#define XGMAC_DMA_BASE_REG		0x3000
+#define XGMAC_DMA_MODE_REG		(XGMAC_DMA_BASE_REG + 0x0000)
+#define XGMAC_DMA_SOFT_RESET		BIT(0)
+#define XGMAC_DMA_SYSBUS_MODE_REG	(XGMAC_DMA_BASE_REG + 0x0004)
+#define XGMAC_DMA_AXI_UNDEF_BURST	BIT(0)
+#define XGMAC_DMA_ENHACE_ADDR_MODE	BIT(11)
+#define XGMAC_DMA_INT_STATUS_REG	(XGMAC_DMA_BASE_REG + 0x0008)
+#define XGMAC_DMA_AXI_ARCACHECTL_REG	(XGMAC_DMA_BASE_REG + 0x0010)
+#define XGMAC_DMA_AXI_AWCACHECTL_REG	(XGMAC_DMA_BASE_REG + 0x0018)
+#define XGMAC_DMA_DEBUG_STATUS0_REG	(XGMAC_DMA_BASE_REG + 0x0020)
+#define XGMAC_DMA_DEBUG_STATUS1_REG	(XGMAC_DMA_BASE_REG + 0x0024)
+#define XGMAC_DMA_DEBUG_STATUS2_REG	(XGMAC_DMA_BASE_REG + 0x0028)
+#define XGMAC_DMA_DEBUG_STATUS3_REG	(XGMAC_DMA_BASE_REG + 0x002C)
+#define XGMAC_DMA_DEBUG_STATUS4_REG	(XGMAC_DMA_BASE_REG + 0x0030)
+#define XGMAC_DMA_DEBUG_STATUS5_REG	(XGMAC_DMA_BASE_REG + 0x0034)
+
+/* Channel Registers, cha_num = 0-15 */
+#define XGMAC_DMA_CHA_BASE_REG \
+		(XGMAC_DMA_BASE_REG + 0x0100)
+#define XGMAC_DMA_CHA_CTL_REG(cha_num) \
+		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x00)
+#define XGMAC_DMA_PBL_X8MODE			BIT(16)
+#define XGMAC_DMA_CHA_TXCTL_TSE_ENABLE		BIT(12)
+#define XGMAC_DMA_CHA_TXCTL_REG(cha_num) \
+		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x04)
+#define XGMAC_DMA_CHA_RXCTL_REG(cha_num) \
+		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x08)
+#define XGMAC_DMA_CHA_TXDESC_HADD_REG(cha_num) \
+		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x10)
+#define XGMAC_DMA_CHA_TXDESC_LADD_REG(cha_num) \
+		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x14)
+#define XGMAC_DMA_CHA_RXDESC_HADD_REG(cha_num) \
+		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x18)
+#define XGMAC_DMA_CHA_RXDESC_LADD_REG(cha_num) \
+		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x1C)
+#define XGMAC_DMA_CHA_TXDESC_TAILPTR_REG(cha_num) \
+		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x24)
+#define XGMAC_DMA_CHA_RXDESC_TAILPTR_REG(cha_num) \
+		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x2C)
+#define XGMAC_DMA_CHA_TXDESC_RINGLEN_REG(cha_num) \
+		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x30)
+#define XGMAC_DMA_CHA_RXDESC_RINGLEN_REG(cha_num) \
+		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x34)
+#define XGMAC_DMA_CHA_INT_ENABLE_REG(cha_num) \
+		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x38)
+#define XGMAC_DMA_CHA_INT_RXWATCHTMR_REG(cha_num) \
+		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x3C)
+#define XGMAC_DMA_CHA_TXDESC_CURADDLO_REG(cha_num) \
+		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x44)
+#define XGMAC_DMA_CHA_RXDESC_CURADDLO_REG(cha_num) \
+		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x4C)
+#define XGMAC_DMA_CHA_CURTXBUF_ADDHI_REG(cha_num) \
+		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x50)
+#define XGMAC_DMA_CHA_CURTXBUF_ADDLO_REG(cha_num) \
+		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x54)
+#define XGMAC_DMA_CHA_CURRXBUF_ADDHI_REG(cha_num) \
+		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x58)
+#define XGMAC_DMA_CHA_CURRXBUF_ADDLO_REG(cha_num) \
+		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x5C)
+#define XGMAC_DMA_CHA_STATUS_REG(cha_num) \
+		(XGMAC_DMA_CHA_BASE_REG + (cha_num * 0x80) + 0x60)
+
+/* TX DMA control register specific */
+#define XGMAC_TX_START_DMA	BIT(0)
+
+/* xgmac tx configuration register bitfields */
+#define XGMAC_SPEED_10G		0x0
+#define XGMAC_SPEED_2_5G	0x1
+#define XGMAC_SPEED_1G		0x2
+#define XGMAC_SPEED_LSHIFT	29
+
+#define XGMAC_TX_ENABLE		BIT(0)
+#define XGMAC_TX_DISDIC_ALGO	BIT(1)
+#define XGMAC_TX_JABBER_DISABLE	BIT(16)
+
+/* xgmac rx configuration register bitfields */
+#define XGMAC_RX_ENABLE		BIT(0)
+#define XGMAC_RX_ACS_ENABLE		BIT(1)
+#define XGMAC_RX_WATCHDOG_DISABLE	BIT(7)
+#define XGMAC_RX_JUMBPKT_ENABLE		BIT(8)
+#define XGMAC_RX_CSUMOFFLOAD_ENABLE	BIT(9)
+#define XGMAC_RX_LOOPBACK_ENABLE	BIT(10)
+#define XGMAC_RX_ARPOFFLOAD_ENABLE	BIT(31)
+
+/* xgmac vlan Tag Register bitfields */
+#define XGMAC_VLAN_SVLAN_ENABLE		BIT(18)
+#define XGMAC_VLAN_DOUBLEVLAN_ENABLE	BIT(26)
+#define XGMAC_VLAN_INNERVLAN_ENABLE	BIT(27)
+
+/* XMAC VLAN Tag Inclusion Register(0x0060) bitfields
+ * Below fields same for  Inner VLAN Tag Inclusion
+ * Register(0x0064) register
+ */
+enum vlan_tag_ctl_tx {
+	VLAN_TAG_TX_NOP,
+	VLAN_TAG_TX_DEL,
+	VLAN_TAG_TX_INSERT,
+	VLAN_TAG_TX_REPLACE
+};
+#define XGMAC_VLAN_PRTY_CTL	BIT(18)
+#define XGMAC_VLAN_CSVL_CTL	BIT(19)
+
+/* XGMAC TX Q Flow Control Register bitfields */
+#define XGMAC_TX_FLOW_CTL_FCB	BIT(0)
+#define XGMAC_TX_FLOW_CTL_TFB	BIT(1)
+
+/* XGMAC RX Q Flow Control Register bitfields */
+#define XGMAC_RX_FLOW_CTL_ENABLE	BIT(0)
+#define XGMAC_RX_UNICAST_DETECT		BIT(1)
+#define XGMAC_RX_PRTYFLOW_CTL_ENABLE	BIT(8)
+
+/* xgmac rx Q control0 register bifields */
+#define XGMAC_RX_Q_ENABLE	0x2
+
+/* XGMAC hardware features bit field specific */
+/* Capability Register 0 */
+#define XGMAC_HW_FEAT_GMII(cap)			((cap & 0x00000002) >> 1)
+#define XGMAC_HW_FEAT_VLAN_HASH_FILTER(cap)	((cap & 0x00000010) >> 4)
+#define XGMAC_HW_FEAT_SMA(cap)			((cap & 0x00000020) >> 5)
+#define XGMAC_HW_FEAT_PMT_TEMOTE_WOP(cap)	((cap & 0x00000040) >> 6)
+#define XGMAC_HW_FEAT_PMT_MAGIC_PKT(cap)	((cap & 0x00000080) >> 7)
+#define XGMAC_HW_FEAT_RMON(cap)			((cap & 0x00000100) >> 8)
+#define XGMAC_HW_FEAT_ARP_OFFLOAD(cap)		((cap & 0x00000200) >> 9)
+#define XGMAC_HW_FEAT_IEEE1500_2008(cap)	((cap & 0x00001000) >> 12)
+#define XGMAC_HW_FEAT_EEE(cap)			((cap & 0x00002000) >> 13)
+#define XGMAC_HW_FEAT_TX_CSUM_OFFLOAD(cap)	((cap & 0x00004000) >> 14)
+#define XGMAC_HW_FEAT_RX_CSUM_OFFLOAD(cap)	((cap & 0x00010000) >> 16)
+#define XGMAC_HW_FEAT_MACADDR_COUNT(cap)	((cap & 0x007C0000) >> 18)
+#define XGMAC_HW_FEAT_TSTMAP_SRC(cap)		((cap & 0x06000000) >> 25)
+#define XGMAC_HW_FEAT_SRCADDR_VLAN(cap)		((cap & 0x08000000) >> 27)
+
+/* Capability Register 1 */
+#define XGMAC_HW_FEAT_RX_FIFO_SIZE(cap)		((cap & 0x0000001F))
+#define XGMAC_HW_FEAT_TX_FIFO_SIZE(cap)		((cap & 0x000007C0) >> 6)
+#define XGMAC_HW_FEAT_IEEE1588_HWORD(cap)	((cap & 0x00002000) >> 13)
+#define XGMAC_HW_FEAT_DCB(cap)			((cap & 0x00010000) >> 16)
+#define XGMAC_HW_FEAT_SPLIT_HDR(cap)		((cap & 0x00020000) >> 17)
+#define XGMAC_HW_FEAT_TSO(cap)			((cap & 0x00040000) >> 18)
+#define XGMAC_HW_FEAT_DEBUG_MEM_IFACE(cap)	((cap & 0x00080000) >> 19)
+#define XGMAC_HW_FEAT_RSS(cap)			((cap & 0x00100000) >> 20)
+#define XGMAC_HW_FEAT_HASH_TABLE_SIZE(cap)	((cap & 0x03000000) >> 24)
+#define XGMAC_HW_FEAT_L3L4_FILTER_NUM(cap)	((cap & 0x78000000) >> 27)
+
+/* Capability Register 2 */
+#define XGMAC_HW_FEAT_RX_MTL_QUEUES(cap)	((cap & 0x0000000F))
+#define XGMAC_HW_FEAT_TX_MTL_QUEUES(cap)	((cap & 0x000003C0) >> 6)
+#define XGMAC_HW_FEAT_RX_DMA_CHANNELS(cap)	((cap & 0x0000F000) >> 12)
+#define XGMAC_HW_FEAT_TX_DMA_CHANNELS(cap)	((cap & 0x003C0000) >> 18)
+#define XGMAC_HW_FEAT_PPS_OUTPUTS(cap)		((cap & 0x07000000) >> 24)
+#define XGMAC_HW_FEAT_AUX_SNAPSHOTS(cap)	((cap & 0x70000000) >> 28)
+
+/* DMAchannel interrupt enable specific */
+/* DMA Normal interrupt */
+#define XGMAC_DMA_INT_ENA_NIE	BIT(16)	/* Normal Summary */
+#define XGMAC_DMA_INT_ENA_TIE	BIT(0)	/* Transmit Interrupt */
+#define XGMAC_DMA_INT_ENA_TUE	BIT(2)	/* Transmit Buffer Unavailable */
+#define XGMAC_DMA_INT_ENA_RIE	BIT(6)	/* Receive Interrupt */
+
+#define XGMAC_DMA_INT_NORMAL \
+		(XGMAC_DMA_INT_ENA_NIE | XGMAC_DMA_INT_ENA_RIE | \
+		XGMAC_DMA_INT_ENA_TIE | XGMAC_DMA_INT_ENA_TUE)
+
+/* DMA Abnormal interrupt */
+#define XGMAC_DMA_INT_ENA_AIE	BIT(15)	/* Abnormal Summary */
+#define XGMAC_DMA_INT_ENA_TSE	BIT(1)	/* Transmit Stopped */
+#define XGMAC_DMA_INT_ENA_RUE	BIT(7)	/* Receive Buffer Unavailable */
+#define XGMAC_DMA_INT_ENA_RSE	BIT(8)	/* Receive Stopped */
+#define XGMAC_DMA_INT_ENA_FBE	BIT(12)	/* Fatal Bus Error */
+#define XGMAC_DMA_INT_ENA_CDEE	BIT(13)	/* Context Descriptor Error */
+
+#define XGMAC_DMA_INT_ABNORMAL \
+		(XGMAC_DMA_INT_ENA_AIE | XGMAC_DMA_INT_ENA_TSE | \
+		XGMAC_DMA_INT_ENA_RUE | XGMAC_DMA_INT_ENA_RSE | \
+		XGMAC_DMA_INT_ENA_FBE | XGMAC_DMA_INT_ENA_CDEE)
+
+#define XGMAC_DMA_ENA_INT	(XGMAC_DMA_INT_NORMAL | XGMAC_DMA_INT_ABNORMAL)
+
+/* DMA channel interrupt status specific */
+#define	XGMAC_DMA_INT_STATUS_REB2	BIT(21)
+#define	XGMAC_DMA_INT_STATUS_REB1	BIT(20)
+#define	XGMAC_DMA_INT_STATUS_REB0	BIT(19)
+#define	XGMAC_DMA_INT_STATUS_TEB2	BIT(18)
+#define	XGMAC_DMA_INT_STATUS_TEB1	BIT(17)
+#define	XGMAC_DMA_INT_STATUS_TEB0	BIT(16)
+#define	XGMAC_DMA_INT_STATUS_NIS	BIT(15)
+#define XGMAC_DMA_INT_STATUS_AIS	BIT(14)
+#define XGMAC_DMA_INT_STATUS_CTXTERR	BIT(13)
+#define XGMAC_DMA_INT_STATUS_FBE	BIT(12)
+#define XGMAC_DMA_INT_STATUS_RPS	BIT(8)
+#define XGMAC_DMA_INT_STATUS_RBU	BIT(7)
+#define XGMAC_DMA_INT_STATUS_RI		BIT(6)
+#define XGMAC_DMA_INT_STATUS_TBU	BIT(2)
+#define XGMAC_DMA_INT_STATUS_TPS	BIT(1)
+#define XGMAC_DMA_INT_STATUS_TI		BIT(0)
+
+#endif /* __XGMAC_REGMAP_H__ */
diff --git a/drivers/net/ethernet/samsung/xgmac_xpcs.c b/drivers/net/ethernet/samsung/xgmac_xpcs.c
new file mode 100644
index 0000000..f0f811d
--- /dev/null
+++ b/drivers/net/ethernet/samsung/xgmac_xpcs.c
@@ -0,0 +1,92 @@
+/* 10G controller driver for Samsung SoCs
+ *
+ * Copyright (C) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ *
+ * Author: Siva Reddy Kallam <siva.kallam@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#include <linux/bitops.h>
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+#include "xgmac_common.h"
+#include "xgmac_xpcs.h"
+
+static int xgmac_xpcs_read(struct net_device *ndev, unsigned int reg)
+{
+	u32 value;
+	struct xgmac_priv_data *priv = netdev_priv(ndev);
+
+	value = readl(priv->ioaddr + XPCS_OFFSET + reg);
+
+	return value;
+}
+
+static int xgmac_xpcs_write(struct net_device *ndev, int reg, int data)
+{
+	struct xgmac_priv_data *priv = netdev_priv(ndev);
+
+	writel(data, priv->ioaddr + XPCS_OFFSET + reg);
+
+	return 0;
+}
+
+int xgmac_xpcs_init(struct net_device *ndev)
+{
+	u32 value;
+
+	value = xgmac_xpcs_read(ndev, SR_PCS_MMD_CONTROL1);
+	/* 10G XAUI mode */
+	xgmac_xpcs_write(ndev, SR_PCS_CONTROL2, XPCS_TYPE_SEL_X);
+	xgmac_xpcs_write(ndev, VR_PCS_MMD_XAUI_MODE_CONTROL, XPCS_XAUI_MODE);
+	xgmac_xpcs_write(ndev, VR_PCS_MMD_XAUI_MODE_CONTROL, value | BIT(13));
+	xgmac_xpcs_write(ndev, SR_PCS_MMD_CONTROL1, value | BIT(11));
+
+	do {
+		value = xgmac_xpcs_read(ndev, VR_PCS_MMD_DIGITAL_STATUS);
+
+	} while ((value & XPCS_QSEQ_STATE_MPLLOFF) == XPCS_QSEQ_STATE_STABLE);
+
+	value = xgmac_xpcs_read(ndev, SR_PCS_MMD_CONTROL1);
+	xgmac_xpcs_write(ndev, SR_PCS_MMD_CONTROL1, value & ~BIT(11));
+
+	do {
+		value = xgmac_xpcs_read(ndev, VR_PCS_MMD_DIGITAL_STATUS);
+	} while ((value & XPCS_QSEQ_STATE_MPLLOFF) != XPCS_QSEQ_STATE_STABLE);
+
+	return 0;
+}
+
+int xgmac_xpcs_init_1G(struct net_device *ndev)
+{
+	int value;
+
+	/* 10GBASE-X PCS (1G) mode */
+	xgmac_xpcs_write(ndev, SR_PCS_CONTROL2, XPCS_TYPE_SEL_X);
+	xgmac_xpcs_write(ndev, VR_PCS_MMD_XAUI_MODE_CONTROL, XPCS_XAUI_MODE);
+	value = xgmac_xpcs_read(ndev, SR_PCS_MMD_CONTROL1);
+	xgmac_xpcs_write(ndev, SR_PCS_MMD_CONTROL1, value & ~BIT(13));
+
+	value = xgmac_xpcs_read(ndev, SR_MII_MMD_CONTROL);
+	xgmac_xpcs_write(ndev, SR_MII_MMD_CONTROL, value | BIT(6));
+	xgmac_xpcs_write(ndev, SR_MII_MMD_CONTROL, value & ~BIT(13));
+	value = xgmac_xpcs_read(ndev, SR_PCS_MMD_CONTROL1);
+	xgmac_xpcs_write(ndev, SR_PCS_MMD_CONTROL1, value | BIT(11));
+
+	do {
+		value = xgmac_xpcs_read(ndev, VR_PCS_MMD_DIGITAL_STATUS);
+	} while ((value & XPCS_QSEQ_STATE_MPLLOFF) != XPCS_QSEQ_STATE_STABLE);
+
+	value = xgmac_xpcs_read(ndev, SR_PCS_MMD_CONTROL1);
+	xgmac_xpcs_write(ndev, SR_PCS_MMD_CONTROL1, value & ~BIT(11));
+
+	/* Auto Negotiation cluase 37 enable */
+	value = xgmac_xpcs_read(ndev, SR_MII_MMD_CONTROL);
+	xgmac_xpcs_write(ndev, SR_MII_MMD_CONTROL, value | BIT(12));
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/samsung/xgmac_xpcs.h b/drivers/net/ethernet/samsung/xgmac_xpcs.h
new file mode 100644
index 0000000..c801fc8
--- /dev/null
+++ b/drivers/net/ethernet/samsung/xgmac_xpcs.h
@@ -0,0 +1,38 @@
+/* 10G controller driver for Samsung SoCs
+ *
+ * Copyright (C) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ *
+ * Author: Byungho An <bh74.an@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#ifndef __XGMAC_XPCS_H__
+#define __XGMAC_XPCS_H__
+
+/* XPCS Registers */
+#define XPCS_OFFSET			0x1A060000
+#define SR_PCS_MMD_CONTROL1		0x030000
+#define SR_PCS_CONTROL2			0x030007
+#define VR_PCS_MMD_XAUI_MODE_CONTROL	0x038004
+#define VR_PCS_MMD_DIGITAL_STATUS	0x038010
+#define SR_MII_MMD_CONTROL		0x1F0000
+#define SR_MII_MMD_AN_ADV		0x1F0004
+#define SR_MII_MMD_AN_LINK_PARTNER_BA	0x1F0005
+#define VR_MII_MMD_AN_CONTROL		0x1F8001
+#define VR_MII_MMD_AN_INT_STATUS	0x1F8002
+
+#define XPCS_QSEQ_STATE_STABLE		0x10
+#define XPCS_QSEQ_STATE_MPLLOFF		0x1c
+#define XPCS_TYPE_SEL_R			0x00
+#define XPCS_TYPE_SEL_X			0x01
+#define XPCS_TYPE_SEL_W			0x02
+#define XPCS_XAUI_MODE			0x00
+#define XPCS_RXAUI_MODE			0x01
+
+int xgmac_xpcs_init(struct net_device *ndev);
+int xgmac_xpcs_init_1G(struct net_device *ndev);
+
+#endif /* __XGMAC_XPCS_H__ */
diff --git a/include/linux/xgmac_platform.h b/include/linux/xgmac_platform.h
new file mode 100644
index 0000000..a8c5d81
--- /dev/null
+++ b/include/linux/xgmac_platform.h
@@ -0,0 +1,54 @@
+/*
+ * 10G controller driver for Samsung EXYNOS SoCs
+ *
+ * Copyright (C) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ *
+ * Author: Siva Reddy Kallam <siva.kallam@samsung.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#ifndef __XGMAC_PLATFORM_H__
+#define __XGMAC_PLATFORM_H__
+
+/* MDC Clock Selection define*/
+#define	XGMAC_CSR_100_150M	0x0	/* MDC = clk_scr_i/62 */
+#define	XGMAC_CSR_150_250M	0x1	/* MDC = clk_scr_i/102 */
+#define	XGMAC_CSR_250_300M	0x2	/* MDC = clk_scr_i/122 */
+#define	XGMAC_CSR_300_350M	0x3	/* MDC = clk_scr_i/142 */
+#define	XGMAC_CSR_350_400M	0x4	/* MDC = clk_scr_i/162 */
+#define	XGMAC_CSR_400_500M	0x5	/* MDC = clk_scr_i/202 */
+
+/* Platfrom data for platform device structure's
+ * platform_data field
+ */
+struct xgmac_mdio_bus_data {
+	unsigned int phy_mask;
+	int *irqs;
+	int probed_phy_irq;
+};
+
+struct xgmac_dma_cfg {
+	int pbl;
+	int fixed_burst;
+	int burst_map;
+	int adv_addr_mode;
+};
+
+struct xgmac_plat_data {
+	char *phy_bus_name;
+	int bus_id;
+	int phy_addr;
+	int interface;
+	struct xgmac_mdio_bus_data *mdio_bus_data;
+	struct xgmac_dma_cfg *dma_cfg;
+	int clk_csr;
+	int pmt;
+	int force_sf_dma_mode;
+	int force_thresh_dma_mode;
+	int riwt_off;
+};
+
+#endif /* __XGMAC_PLATFORM_H__ */
-- 
1.7.10.4
