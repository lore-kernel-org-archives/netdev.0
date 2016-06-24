From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH] [v6] net: emac: emac gigabit ethernet controller driver
Date: Fri, 24 Jun 2016 18:46:48 -0500
Message-ID: <1466812008-26686-1-git-send-email-timur@codeaurora.org>
To: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	shankerd@codeaurora.org, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org, robh+dt@kernel.org,
	andrew@lunn.ch, bjorn.andersson@linaro.org, mlangsdo@redhat.com,
	jcm@redhat.com, agross@codeaurora.org, davem@davemloft.net,
	f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:50585 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080AbcFXXrH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 19:47:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add supports for ethernet controller HW on Qualcomm Technologies, Inc. SoC.
This driver supports the following features:
1) Checksum offload.
2) Interrupt coalescing support.
3) SGMII phy.
4) phylib interface for external phy

Based on original work by
	Niranjana Vishwanathapura <nvishwan@codeaurora.org>
	Gilad Avidov <gavidov@codeaurora.org>

Signed-off-by: Timur Tabi <timur@codeaurora.org>
---

v6:
 - Properly ordered local variables
 - use built-in GEN_MASK instead of BITS_MASK
 - remove redundant call to emac_rx_mode_set from emac_mac_up
 - removed emac_rfd structure, use dma_addr_t directly instead
 - removed emac_mac_speed enun, replaced with macros
 - removed superfluous phy_stop from emac_mac_down(), which prevented reloading module
 - add missing netif_napi_del
 - set the DMA mask

v5:
 - changed author to Timur, added MAINTAINERS entry
 - use phylib, replacing internal phy code
 - added support for EMAC internal SGMII v2
 - fix ~DIS_INT warning
 - update DT bindings, including removing unused properties
 - removed interrupt handler for internal sgmii
 - removed link status check handler/state (replaced with phylib)
 - removed periodic timer handler (replaced with phylib)
 - removed power management code (will be rewritten later)
 - external phy is now required, not optional
 - removed redundant EMAC_STATUS_DOWN status flag
 - removed redundant link status and speed variables
 - removed redundant status bits (vlan strip, promiscuous, loopback, etc)
 - removed useless watchdog status
 - removed command-line parameters
 - cleaned up probe messages
 - removed redundant params from emac_sgmii_link_init()
 - always call netdev_completed_queue() (per review comment)
 - fix emac_napi_rtx() (per review comment)
 - removed max_ints loop in interrupt handler
 - removed redundant mutex around phy read/write calls
 - added lock for reading emac status (per review comment)
 - generate random MAC address if it can't be read from firmware
 - replace EMAC_DMA_ADDR_HI/LO with upper/lower_32_bits
 - don't test return value from platform_get_resource (per review comment)
 - use net_warn_ratelimited (per review comment)
 - don't set the dma masks (will be set by DT or IORT code)
 - remove unused emac_tx_tpd_ts_save()
 - removed redundant local MTU variable

v4:
 - add missing ipv6 header file
 - correct compatible string
 - fix spacing in emac_reg_write arrays
 - drop unnecessary cell-index property
 - remove unsupported DT properties from docs
 - remove GPIO initialization and update docs

v3:
 - remove most of the memory barriers by using the non xxx_relaxed() api.
 - remove RSS and WOL support.
 - correct comments from physical address to dma address.
 - rearrange structs to make them packed.
 - replace polling loops with readl_poll_timeout().
 - remove unnecessary wrapper functions from phy layer.
 - add blank line before return statements.
 - set to null clocks after clk_put().
 - use module_platform_driver() and dma_set_mask_and_coherent()
 - replace long hex bitmasks with BIT() macro.

v2:
 - replace hw bit fields to macros with bitwise operations.
 - change all iterators to unsized types (int)
 - some minor code flow improvements.
 - change return type to void for functions which return value is never
   used.
 - replace instance of xxxxl_relaxed() io followed by mb() with a
   readl()/writel().


 .../devicetree/bindings/net/qcom-emac.txt          |   63 +
 MAINTAINERS                                        |    6 +
 drivers/net/ethernet/qualcomm/Kconfig              |   11 +
 drivers/net/ethernet/qualcomm/Makefile             |    2 +
 drivers/net/ethernet/qualcomm/emac/Makefile        |    7 +
 drivers/net/ethernet/qualcomm/emac/emac-mac.c      | 1661 ++++++++++++++++++++
 drivers/net/ethernet/qualcomm/emac/emac-mac.h      |  271 ++++
 drivers/net/ethernet/qualcomm/emac/emac-phy.c      |  211 +++
 drivers/net/ethernet/qualcomm/emac/emac-phy.h      |   32 +
 drivers/net/ethernet/qualcomm/emac/emac-sgmii.c    |  700 +++++++++
 drivers/net/ethernet/qualcomm/emac/emac-sgmii.h    |   24 +
 drivers/net/ethernet/qualcomm/emac/emac.c          |  809 ++++++++++
 drivers/net/ethernet/qualcomm/emac/emac.h          |  369 +++++
 13 files changed, 4166 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/qcom-emac.txt
 create mode 100644 drivers/net/ethernet/qualcomm/emac/Makefile
 create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-mac.c
 create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-mac.h
 create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-phy.c
 create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-phy.h
 create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
 create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-sgmii.h
 create mode 100644 drivers/net/ethernet/qualcomm/emac/emac.c
 create mode 100644 drivers/net/ethernet/qualcomm/emac/emac.h

diff --git a/Documentation/devicetree/bindings/net/qcom-emac.txt b/Documentation/devicetree/bindings/net/qcom-emac.txt
new file mode 100644
index 0000000..4e1a533
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/qcom-emac.txt
@@ -0,0 +1,63 @@
+Qualcomm EMAC Gigabit Ethernet Controller
+
+Required properties:
+- compatible : Should be "qcom,fsm9900-emac".
+- reg : Offset and length of the register regions for the device
+- reg-names : Register region names referenced in 'reg' above.
+	Required register resource entries are:
+	"base"   : EMAC controller base register block.
+	"csr"    : EMAC wrapper register block.
+	"sgmii"  : EMAC SGMII PHY register block.
+	Optional register resource entries are:
+	"ptp"    : EMAC PTP (1588) register block.
+- interrupts : Interrupt numbers used by this controller
+- interrupt-names : Interrupt resource names referenced in 'interrupts' above.
+	Required interrupt resource entries are:
+	"emac_core0"   : EMAC core0 interrupt.
+	"sgmii_irq"   : EMAC SGMII interrupt.
+- mac-address               : The 6-byte MAC address. If present, it is the
+			      default MAC address.
+
+The external phy child node:
+- compatible : Should be "qcom,fsm9900-emac-phy".
+- reg : The phy address
+
+Example:
+soc {
+	#address-cells = <1>;
+	#size-cells = <1>;
+	dma-ranges = <0 0 0xffffffff>;
+
+	emac0: ethernet@feb20000 {
+		compatible = "qcom,fsm9900-emac";
+		#address-cells = <1>;
+		#size-cells = <1>;
+		reg-names = "base", "csr", "ptp", "sgmii";
+		reg =   <0xfeb20000 0x10000>,
+			<0xfeb36000 0x1000>,
+			<0xfeb3c000 0x4000>,
+			<0xfeb38000 0x400>;
+		interrupt-parent = <&emac0>;
+		#interrupt-cells = <1>;
+		interrupts = <76 80>;
+		interrupt-names = "emac_core0", "sgmii_irq";
+		phy0: ethernet-phy@0 {
+			compatible = "qcom,fsm9900-emac-phy";
+			reg = <0>;
+		}
+
+		pinctrl-names = "default";
+		pinctrl-0 = <&mdio_pins_a>;
+	};
+
+	tlmm: pinctrl@fd510000 {
+		compatible = "qcom,fsm9900-pinctrl";
+
+		mdio_pins_a: mdio {
+			state {
+				pins = "gpio123", "gpio124";
+				function = "mdio";
+			};
+		};
+	};
diff --git a/MAINTAINERS b/MAINTAINERS
index 6ee06ea..e53f3a6 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -8974,6 +8974,12 @@ T:	git git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/ath.git
 S:	Supported
 F:	drivers/net/wireless/ath/ath10k/
 
+QUALCOMM EMAC GIGABIT ETHERNET DRIVER
+M:	Timur Tabi <timur@codeaurora.org>
+L:	netdev@vger.kernel.org
+S:	Supported
+F:	drivers/net/ethernet/qualcomm/emac/
+
 QUALCOMM HEXAGON ARCHITECTURE
 M:	Richard Kuo <rkuo@codeaurora.org>
 L:	linux-hexagon@vger.kernel.org
diff --git a/drivers/net/ethernet/qualcomm/Kconfig b/drivers/net/ethernet/qualcomm/Kconfig
index a76e380..85b599f 100644
--- a/drivers/net/ethernet/qualcomm/Kconfig
+++ b/drivers/net/ethernet/qualcomm/Kconfig
@@ -24,4 +24,15 @@ config QCA7000
 	  To compile this driver as a module, choose M here. The module
 	  will be called qcaspi.
 
+config QCOM_EMAC
+	tristate "Qualcomm Technologies, Inc. EMAC Gigabit Ethernet support"
+	select CRC32
+	---help---
+	  This driver supports the Qualcomm Technologies, Inc. Gigabit
+	  Ethernet Media Access Controller (EMAC). The controller
+	  supports IEEE 802.3-2002, half-duplex mode at 10/100 Mb/s,
+	  full-duplex mode at 10/100/1000Mb/s, Wake On LAN (WOL) for
+	  low power, Receive-Side Scaling (RSS), and IEEE 1588-2008
+	  Precision Clock Synchronization Protocol.
+
 endif # NET_VENDOR_QUALCOMM
diff --git a/drivers/net/ethernet/qualcomm/Makefile b/drivers/net/ethernet/qualcomm/Makefile
index 9da2d75..1b3a0ce 100644
--- a/drivers/net/ethernet/qualcomm/Makefile
+++ b/drivers/net/ethernet/qualcomm/Makefile
@@ -4,3 +4,5 @@
 
 obj-$(CONFIG_QCA7000) += qcaspi.o
 qcaspi-objs := qca_spi.o qca_framing.o qca_7k.o qca_debug.o
+
+obj-$(CONFIG_QCOM_EMAC) += emac/
diff --git a/drivers/net/ethernet/qualcomm/emac/Makefile b/drivers/net/ethernet/qualcomm/emac/Makefile
new file mode 100644
index 0000000..01ee144
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/emac/Makefile
@@ -0,0 +1,7 @@
+#
+# Makefile for the Qualcomm Technologies, Inc. EMAC Gigabit Ethernet driver
+#
+
+obj-$(CONFIG_QCOM_EMAC) += qcom-emac.o
+
+qcom-emac-objs := emac.o emac-mac.o emac-phy.o emac-sgmii.o
diff --git a/drivers/net/ethernet/qualcomm/emac/emac-mac.c b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
new file mode 100644
index 0000000..70bc686
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
@@ -0,0 +1,1661 @@
+/* Copyright (c) 2013-2016, The Linux Foundation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 and
+ * only version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+/* Qualcomm Technologies, Inc. EMAC Ethernet Controller MAC layer support
+ */
+
+#include <linux/tcp.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/crc32.h>
+#include <linux/if_vlan.h>
+#include <linux/jiffies.h>
+#include <linux/phy.h>
+#include <linux/of.h>
+#include <net/ip6_checksum.h>
+#include "emac.h"
+#include "emac-sgmii.h"
+
+/* EMAC base register offsets */
+#define EMAC_MAC_CTRL			0x001480
+#define EMAC_WOL_CTRL0			0x0014a0
+#define EMAC_RSS_KEY0			0x0014b0
+#define EMAC_H1TPD_BASE_ADDR_LO		0x0014e0
+#define EMAC_H2TPD_BASE_ADDR_LO		0x0014e4
+#define EMAC_H3TPD_BASE_ADDR_LO		0x0014e8
+#define EMAC_INTER_SRAM_PART9		0x001534
+#define EMAC_DESC_CTRL_0		0x001540
+#define EMAC_DESC_CTRL_1		0x001544
+#define EMAC_DESC_CTRL_2		0x001550
+#define EMAC_DESC_CTRL_10		0x001554
+#define EMAC_DESC_CTRL_12		0x001558
+#define EMAC_DESC_CTRL_13		0x00155c
+#define EMAC_DESC_CTRL_3		0x001560
+#define EMAC_DESC_CTRL_4		0x001564
+#define EMAC_DESC_CTRL_5		0x001568
+#define EMAC_DESC_CTRL_14		0x00156c
+#define EMAC_DESC_CTRL_15		0x001570
+#define EMAC_DESC_CTRL_16		0x001574
+#define EMAC_DESC_CTRL_6		0x001578
+#define EMAC_DESC_CTRL_8		0x001580
+#define EMAC_DESC_CTRL_9		0x001584
+#define EMAC_DESC_CTRL_11		0x001588
+#define EMAC_TXQ_CTRL_0			0x001590
+#define EMAC_TXQ_CTRL_1			0x001594
+#define EMAC_TXQ_CTRL_2			0x001598
+#define EMAC_RXQ_CTRL_0			0x0015a0
+#define EMAC_RXQ_CTRL_1			0x0015a4
+#define EMAC_RXQ_CTRL_2			0x0015a8
+#define EMAC_RXQ_CTRL_3			0x0015ac
+#define EMAC_BASE_CPU_NUMBER		0x0015b8
+#define EMAC_DMA_CTRL			0x0015c0
+#define EMAC_MAILBOX_0			0x0015e0
+#define EMAC_MAILBOX_5			0x0015e4
+#define EMAC_MAILBOX_6			0x0015e8
+#define EMAC_MAILBOX_13			0x0015ec
+#define EMAC_MAILBOX_2			0x0015f4
+#define EMAC_MAILBOX_3			0x0015f8
+#define EMAC_MAILBOX_11			0x00160c
+#define EMAC_AXI_MAST_CTRL		0x001610
+#define EMAC_MAILBOX_12			0x001614
+#define EMAC_MAILBOX_9			0x001618
+#define EMAC_MAILBOX_10			0x00161c
+#define EMAC_ATHR_HEADER_CTRL		0x001620
+#define EMAC_CLK_GATE_CTRL		0x001814
+#define EMAC_MISC_CTRL			0x001990
+#define EMAC_MAILBOX_7			0x0019e0
+#define EMAC_MAILBOX_8			0x0019e4
+#define EMAC_MAILBOX_15			0x001bd4
+#define EMAC_MAILBOX_16			0x001bd8
+
+/* EMAC_MAC_CTRL */
+#define SINGLE_PAUSE_MODE       	0x10000000
+#define DEBUG_MODE                      0x08000000
+#define BROAD_EN                        0x04000000
+#define MULTI_ALL                       0x02000000
+#define RX_CHKSUM_EN                    0x01000000
+#define HUGE                            0x00800000
+#define SPEED(x)			(((x) & 0x3) << 20)
+#define SPEED_MASK			SPEED(0x3)
+#define SIMR                            0x00080000
+#define TPAUSE                          0x00010000
+#define PROM_MODE                       0x00008000
+#define VLAN_STRIP                      0x00004000
+#define PRLEN_BMSK                      0x00003c00
+#define PRLEN_SHFT                      10
+#define HUGEN                           0x00000200
+#define FLCHK                           0x00000100
+#define PCRCE                           0x00000080
+#define CRCE                            0x00000040
+#define FULLD                           0x00000020
+#define MAC_LP_EN                       0x00000010
+#define RXFC                            0x00000008
+#define TXFC                            0x00000004
+#define RXEN                            0x00000002
+#define TXEN                            0x00000001
+
+
+/* EMAC_WOL_CTRL0 */
+#define LK_CHG_PME			0x20
+#define LK_CHG_EN			0x10
+#define MG_FRAME_PME			0x8
+#define MG_FRAME_EN			0x4
+#define WK_FRAME_EN			0x1
+
+/* EMAC_DESC_CTRL_3 */
+#define RFD_RING_SIZE_BMSK                                       0xfff
+
+/* EMAC_DESC_CTRL_4 */
+#define RX_BUFFER_SIZE_BMSK                                     0xffff
+
+/* EMAC_DESC_CTRL_6 */
+#define RRD_RING_SIZE_BMSK                                       0xfff
+
+/* EMAC_DESC_CTRL_9 */
+#define TPD_RING_SIZE_BMSK                                      0xffff
+
+/* EMAC_TXQ_CTRL_0 */
+#define NUM_TXF_BURST_PREF_BMSK                             0xffff0000
+#define NUM_TXF_BURST_PREF_SHFT                                     16
+#define LS_8023_SP                                                0x80
+#define TXQ_MODE                                                  0x40
+#define TXQ_EN                                                    0x20
+#define IP_OP_SP                                                  0x10
+#define NUM_TPD_BURST_PREF_BMSK                                    0xf
+#define NUM_TPD_BURST_PREF_SHFT                                      0
+
+/* EMAC_TXQ_CTRL_1 */
+#define JUMBO_TASK_OFFLOAD_THRESHOLD_BMSK                        0x7ff
+
+/* EMAC_TXQ_CTRL_2 */
+#define TXF_HWM_BMSK                                         0xfff0000
+#define TXF_LWM_BMSK                                             0xfff
+
+/* EMAC_RXQ_CTRL_0 */
+#define RXQ_EN                                                 BIT(31)
+#define CUT_THRU_EN                                            BIT(30)
+#define RSS_HASH_EN                                            BIT(29)
+#define NUM_RFD_BURST_PREF_BMSK                              0x3f00000
+#define NUM_RFD_BURST_PREF_SHFT                                     20
+#define IDT_TABLE_SIZE_BMSK                                    0x1ff00
+#define IDT_TABLE_SIZE_SHFT                                          8
+#define SP_IPV6                                                   0x80
+
+/* EMAC_RXQ_CTRL_1 */
+#define JUMBO_1KAH_BMSK                                         0xf000
+#define JUMBO_1KAH_SHFT                                             12
+#define RFD_PREF_LOW_TH                                           0x10
+#define RFD_PREF_LOW_THRESHOLD_BMSK                              0xfc0
+#define RFD_PREF_LOW_THRESHOLD_SHFT                                  6
+#define RFD_PREF_UP_TH                                            0x10
+#define RFD_PREF_UP_THRESHOLD_BMSK                                0x3f
+#define RFD_PREF_UP_THRESHOLD_SHFT                                   0
+
+/* EMAC_RXQ_CTRL_2 */
+#define RXF_DOF_THRESFHOLD                                       0x1a0
+#define RXF_DOF_THRESHOLD_BMSK                               0xfff0000
+#define RXF_DOF_THRESHOLD_SHFT                                      16
+#define RXF_UOF_THRESFHOLD                                        0xbe
+#define RXF_UOF_THRESHOLD_BMSK                                   0xfff
+#define RXF_UOF_THRESHOLD_SHFT                                       0
+
+/* EMAC_RXQ_CTRL_3 */
+#define RXD_TIMER_BMSK                                      0xffff0000
+#define RXD_THRESHOLD_BMSK                                       0xfff
+#define RXD_THRESHOLD_SHFT                                           0
+
+/* EMAC_DMA_CTRL */
+#define DMAW_DLY_CNT_BMSK                                      0xf0000
+#define DMAW_DLY_CNT_SHFT                                           16
+#define DMAR_DLY_CNT_BMSK                                       0xf800
+#define DMAR_DLY_CNT_SHFT                                           11
+#define DMAR_REQ_PRI                                             0x400
+#define REGWRBLEN_BMSK                                           0x380
+#define REGWRBLEN_SHFT                                               7
+#define REGRDBLEN_BMSK                                            0x70
+#define REGRDBLEN_SHFT                                               4
+#define OUT_ORDER_MODE                                             0x4
+#define ENH_ORDER_MODE                                             0x2
+#define IN_ORDER_MODE                                              0x1
+
+/* EMAC_MAILBOX_13 */
+#define RFD3_PROC_IDX_BMSK                                   0xfff0000
+#define RFD3_PROC_IDX_SHFT                                          16
+#define RFD3_PROD_IDX_BMSK                                       0xfff
+#define RFD3_PROD_IDX_SHFT                                           0
+
+/* EMAC_MAILBOX_2 */
+#define NTPD_CONS_IDX_BMSK                                  0xffff0000
+#define NTPD_CONS_IDX_SHFT                                          16
+
+/* EMAC_MAILBOX_3 */
+#define RFD0_CONS_IDX_BMSK                                       0xfff
+#define RFD0_CONS_IDX_SHFT                                           0
+
+/* EMAC_MAILBOX_11 */
+#define H3TPD_PROD_IDX_BMSK                                 0xffff0000
+#define H3TPD_PROD_IDX_SHFT                                         16
+
+/* EMAC_AXI_MAST_CTRL */
+#define DATA_BYTE_SWAP                                             0x8
+#define MAX_BOUND                                                  0x2
+#define MAX_BTYPE                                                  0x1
+
+/* EMAC_MAILBOX_12 */
+#define H3TPD_CONS_IDX_BMSK                                 0xffff0000
+#define H3TPD_CONS_IDX_SHFT                                         16
+
+/* EMAC_MAILBOX_9 */
+#define H2TPD_PROD_IDX_BMSK                                     0xffff
+#define H2TPD_PROD_IDX_SHFT                                          0
+
+/* EMAC_MAILBOX_10 */
+#define H1TPD_CONS_IDX_BMSK                                 0xffff0000
+#define H1TPD_CONS_IDX_SHFT                                         16
+#define H2TPD_CONS_IDX_BMSK                                     0xffff
+#define H2TPD_CONS_IDX_SHFT                                          0
+
+/* EMAC_ATHR_HEADER_CTRL */
+#define HEADER_CNT_EN                                              0x2
+#define HEADER_ENABLE                                              0x1
+
+/* EMAC_MAILBOX_0 */
+#define RFD0_PROC_IDX_BMSK                                   0xfff0000
+#define RFD0_PROC_IDX_SHFT                                          16
+#define RFD0_PROD_IDX_BMSK                                       0xfff
+#define RFD0_PROD_IDX_SHFT                                           0
+
+/* EMAC_MAILBOX_5 */
+#define RFD1_PROC_IDX_BMSK                                   0xfff0000
+#define RFD1_PROC_IDX_SHFT                                          16
+#define RFD1_PROD_IDX_BMSK                                       0xfff
+#define RFD1_PROD_IDX_SHFT                                           0
+
+/* EMAC_MISC_CTRL */
+#define RX_UNCPL_INT_EN                                            0x1
+
+/* EMAC_MAILBOX_7 */
+#define RFD2_CONS_IDX_BMSK                                   0xfff0000
+#define RFD2_CONS_IDX_SHFT                                          16
+#define RFD1_CONS_IDX_BMSK                                       0xfff
+#define RFD1_CONS_IDX_SHFT                                           0
+
+/* EMAC_MAILBOX_8 */
+#define RFD3_CONS_IDX_BMSK                                       0xfff
+#define RFD3_CONS_IDX_SHFT                                           0
+
+/* EMAC_MAILBOX_15 */
+#define NTPD_PROD_IDX_BMSK                                      0xffff
+#define NTPD_PROD_IDX_SHFT                                           0
+
+/* EMAC_MAILBOX_16 */
+#define H1TPD_PROD_IDX_BMSK                                     0xffff
+#define H1TPD_PROD_IDX_SHFT                                          0
+
+#define RXQ0_RSS_HSTYP_IPV6_TCP_EN                                0x20
+#define RXQ0_RSS_HSTYP_IPV6_EN                                    0x10
+#define RXQ0_RSS_HSTYP_IPV4_TCP_EN                                 0x8
+#define RXQ0_RSS_HSTYP_IPV4_EN                                     0x4
+
+/* EMAC_EMAC_WRAPPER_TX_TS_INX */
+#define EMAC_WRAPPER_TX_TS_EMPTY                               BIT(31)
+#define EMAC_WRAPPER_TX_TS_INX_BMSK                             0xffff
+
+struct emac_skb_cb {
+	u32           tpd_idx;
+	unsigned long jiffies;
+};
+
+struct emac_tx_ts_cb {
+	u32 sec;
+	u32 ns;
+};
+
+#define EMAC_SKB_CB(skb)	((struct emac_skb_cb *)(skb)->cb)
+#define EMAC_TX_TS_CB(skb)	((struct emac_tx_ts_cb *)(skb)->cb)
+#define EMAC_RSS_IDT_SIZE	256
+#define JUMBO_1KAH		0x4
+#define RXD_TH			0x100
+#define EMAC_TPD_LAST_FRAGMENT	0x80000000
+#define EMAC_TPD_TSTAMP_SAVE	0x80000000
+
+/* EMAC Errors in emac_rrd.word[3] */
+#define EMAC_RRD_L4F		BIT(14)
+#define EMAC_RRD_IPF		BIT(15)
+#define EMAC_RRD_CRC		BIT(21)
+#define EMAC_RRD_FAE		BIT(22)
+#define EMAC_RRD_TRN		BIT(23)
+#define EMAC_RRD_RNT		BIT(24)
+#define EMAC_RRD_INC		BIT(25)
+#define EMAC_RRD_FOV		BIT(29)
+#define EMAC_RRD_LEN		BIT(30)
+
+/* Error bits that will result in a received frame being discarded */
+#define EMAC_RRD_ERROR (EMAC_RRD_IPF | EMAC_RRD_CRC | EMAC_RRD_FAE | \
+			EMAC_RRD_TRN | EMAC_RRD_RNT | EMAC_RRD_INC | \
+			EMAC_RRD_FOV | EMAC_RRD_LEN)
+#define EMAC_RRD_STATS_DW_IDX 3
+
+#define EMAC_RRD(RXQ, SIZE, IDX)	((RXQ)->rrd.v_addr + (SIZE * (IDX)))
+#define EMAC_RFD(RXQ, SIZE, IDX)	((RXQ)->rfd.v_addr + (SIZE * (IDX)))
+#define EMAC_TPD(TXQ, SIZE, IDX)	((TXQ)->tpd.v_addr + (SIZE * (IDX)))
+
+#define GET_RFD_BUFFER(RXQ, IDX)	(&((RXQ)->rfd.rfbuff[(IDX)]))
+#define GET_TPD_BUFFER(RTQ, IDX)	(&((RTQ)->tpd.tpbuff[(IDX)]))
+
+#define EMAC_TX_POLL_HWTXTSTAMP_THRESHOLD	8
+
+#define ISR_RX_PKT      (\
+	RX_PKT_INT0     |\
+	RX_PKT_INT1     |\
+	RX_PKT_INT2     |\
+	RX_PKT_INT3)
+
+void emac_mac_multicast_addr_set(struct emac_adapter *adpt, u8 *addr)
+{
+	u32 crc32, bit, reg, mta;
+
+	/* Calculate the CRC of the MAC address */
+	crc32 = ether_crc(ETH_ALEN, addr);
+
+	/* The HASH Table is an array of 2 32-bit registers. It is
+	 * treated like an array of 64 bits (BitArray[hash_value]).
+	 * Use the upper 6 bits of the above CRC as the hash value.
+	 */
+	reg = (crc32 >> 31) & 0x1;
+	bit = (crc32 >> 26) & 0x1F;
+
+	mta = readl(adpt->base + EMAC_HASH_TAB_REG0 + (reg << 2));
+	mta |= BIT(bit);
+	writel(mta, adpt->base + EMAC_HASH_TAB_REG0 + (reg << 2));
+}
+
+void emac_mac_multicast_addr_clear(struct emac_adapter *adpt)
+{
+	writel(0, adpt->base + EMAC_HASH_TAB_REG0);
+	writel(0, adpt->base + EMAC_HASH_TAB_REG1);
+}
+
+/* definitions for RSS */
+#define EMAC_RSS_KEY(_i, _type) \
+		(EMAC_RSS_KEY0 + ((_i) * sizeof(_type)))
+#define EMAC_RSS_TBL(_i, _type) \
+		(EMAC_IDT_TABLE0 + ((_i) * sizeof(_type)))
+
+/* Config MAC modes */
+void emac_mac_mode_config(struct emac_adapter *adpt)
+{
+	struct net_device *netdev = adpt->netdev;
+	u32 mac;
+
+	mac = readl(adpt->base + EMAC_MAC_CTRL);
+	mac &= ~(VLAN_STRIP | PROM_MODE | MULTI_ALL | MAC_LP_EN);
+
+	if (netdev->features & NETIF_F_HW_VLAN_CTAG_RX)
+		mac |= VLAN_STRIP;
+
+	if (netdev->flags & IFF_PROMISC)
+		mac |= PROM_MODE;
+
+	if (netdev->flags & IFF_ALLMULTI)
+		mac |= MULTI_ALL;
+
+	writel(mac, adpt->base + EMAC_MAC_CTRL);
+}
+
+/* Config descriptor rings */
+static void emac_mac_dma_rings_config(struct emac_adapter *adpt)
+{
+	static const unsigned short tpd_q_offset[] = {
+		EMAC_DESC_CTRL_8,        EMAC_H1TPD_BASE_ADDR_LO,
+		EMAC_H2TPD_BASE_ADDR_LO, EMAC_H3TPD_BASE_ADDR_LO};
+	static const unsigned short rfd_q_offset[] = {
+		EMAC_DESC_CTRL_2,        EMAC_DESC_CTRL_10,
+		EMAC_DESC_CTRL_12,       EMAC_DESC_CTRL_13};
+	static const unsigned short rrd_q_offset[] = {
+		EMAC_DESC_CTRL_5,        EMAC_DESC_CTRL_14,
+		EMAC_DESC_CTRL_15,       EMAC_DESC_CTRL_16};
+
+	if (adpt->timestamp_en)
+		emac_reg_update32(adpt->csr + EMAC_EMAC_WRAPPER_CSR1,
+				  0, ENABLE_RRD_TIMESTAMP);
+
+	/* TPD (Transmit Packet Descriptor) */
+	writel(upper_32_bits(adpt->tx_q.tpd.dma_addr),
+	       adpt->base + EMAC_DESC_CTRL_1);
+
+	writel(lower_32_bits(adpt->tx_q.tpd.dma_addr),
+	       adpt->base + tpd_q_offset[0]);
+
+	writel(adpt->tx_q.tpd.count & TPD_RING_SIZE_BMSK,
+	       adpt->base + EMAC_DESC_CTRL_9);
+
+	/* RFD (Receive Free Descriptor) & RRD (Receive Return Descriptor) */
+	writel(upper_32_bits(adpt->rx_q.rfd.dma_addr),
+	       adpt->base + EMAC_DESC_CTRL_0);
+
+	writel(lower_32_bits(adpt->rx_q.rfd.dma_addr),
+	       adpt->base + rfd_q_offset[0]);
+	writel(lower_32_bits(adpt->rx_q.rrd.dma_addr),
+	       adpt->base + rrd_q_offset[0]);
+
+	writel(adpt->rx_q.rfd.count & RFD_RING_SIZE_BMSK,
+	       adpt->base + EMAC_DESC_CTRL_3);
+	writel(adpt->rx_q.rrd.count & RRD_RING_SIZE_BMSK,
+	       adpt->base + EMAC_DESC_CTRL_6);
+
+	writel(adpt->rxbuf_size & RX_BUFFER_SIZE_BMSK,
+	       adpt->base + EMAC_DESC_CTRL_4);
+
+	writel(0, adpt->base + EMAC_DESC_CTRL_11);
+
+	/* Load all of the base addresses above and ensure that triggering HW to
+	 * read ring pointers is flushed
+	 */
+	writel(1, adpt->base + EMAC_INTER_SRAM_PART9);
+}
+
+/* Config transmit parameters */
+static void emac_mac_tx_config(struct emac_adapter *adpt)
+{
+	u32 val;
+
+	writel((EMAC_MAX_TX_OFFLOAD_THRESH >> 3) &
+	       JUMBO_TASK_OFFLOAD_THRESHOLD_BMSK, adpt->base + EMAC_TXQ_CTRL_1);
+
+	val = (adpt->tpd_burst << NUM_TPD_BURST_PREF_SHFT) &
+	       NUM_TPD_BURST_PREF_BMSK;
+
+	val |= TXQ_MODE | LS_8023_SP;
+	val |= (0x0100 << NUM_TXF_BURST_PREF_SHFT) &
+		NUM_TXF_BURST_PREF_BMSK;
+
+	writel(val, adpt->base + EMAC_TXQ_CTRL_0);
+	emac_reg_update32(adpt->base + EMAC_TXQ_CTRL_2,
+			  (TXF_HWM_BMSK | TXF_LWM_BMSK), 0);
+}
+
+/* Config receive parameters */
+static void emac_mac_rx_config(struct emac_adapter *adpt)
+{
+	u32 val;
+
+	val = (adpt->rfd_burst << NUM_RFD_BURST_PREF_SHFT) &
+	       NUM_RFD_BURST_PREF_BMSK;
+	val |= (SP_IPV6 | CUT_THRU_EN);
+
+	writel(val, adpt->base + EMAC_RXQ_CTRL_0);
+
+	val = readl(adpt->base + EMAC_RXQ_CTRL_1);
+	val &= ~(JUMBO_1KAH_BMSK | RFD_PREF_LOW_THRESHOLD_BMSK |
+		 RFD_PREF_UP_THRESHOLD_BMSK);
+	val |= (JUMBO_1KAH << JUMBO_1KAH_SHFT) |
+		(RFD_PREF_LOW_TH << RFD_PREF_LOW_THRESHOLD_SHFT) |
+		(RFD_PREF_UP_TH  << RFD_PREF_UP_THRESHOLD_SHFT);
+	writel(val, adpt->base + EMAC_RXQ_CTRL_1);
+
+	val = readl(adpt->base + EMAC_RXQ_CTRL_2);
+	val &= ~(RXF_DOF_THRESHOLD_BMSK | RXF_UOF_THRESHOLD_BMSK);
+	val |= (RXF_DOF_THRESFHOLD  << RXF_DOF_THRESHOLD_SHFT) |
+		(RXF_UOF_THRESFHOLD << RXF_UOF_THRESHOLD_SHFT);
+	writel(val, adpt->base + EMAC_RXQ_CTRL_2);
+
+	val = readl(adpt->base + EMAC_RXQ_CTRL_3);
+	val &= ~(RXD_TIMER_BMSK | RXD_THRESHOLD_BMSK);
+	val |= RXD_TH << RXD_THRESHOLD_SHFT;
+	writel(val, adpt->base + EMAC_RXQ_CTRL_3);
+}
+
+/* Config dma */
+static void emac_mac_dma_config(struct emac_adapter *adpt)
+{
+	u32 dma_ctrl = DMAR_REQ_PRI;
+
+	switch (adpt->dma_order) {
+	case emac_dma_ord_in:
+		dma_ctrl |= IN_ORDER_MODE;
+		break;
+	case emac_dma_ord_enh:
+		dma_ctrl |= ENH_ORDER_MODE;
+		break;
+	case emac_dma_ord_out:
+		dma_ctrl |= OUT_ORDER_MODE;
+		break;
+	default:
+		break;
+	}
+
+	dma_ctrl |= (((u32)adpt->dmar_block) << REGRDBLEN_SHFT) &
+						REGRDBLEN_BMSK;
+	dma_ctrl |= (((u32)adpt->dmaw_block) << REGWRBLEN_SHFT) &
+						REGWRBLEN_BMSK;
+	dma_ctrl |= (((u32)adpt->dmar_dly_cnt) << DMAR_DLY_CNT_SHFT) &
+						DMAR_DLY_CNT_BMSK;
+	dma_ctrl |= (((u32)adpt->dmaw_dly_cnt) << DMAW_DLY_CNT_SHFT) &
+						DMAW_DLY_CNT_BMSK;
+
+	/* config DMA and ensure that configuration is flushed to HW */
+	writel(dma_ctrl, adpt->base + EMAC_DMA_CTRL);
+}
+
+/* set MAC address */
+static void emac_set_mac_address(struct emac_adapter *adpt, u8 *addr)
+{
+	u32 sta;
+
+	/* for example: 00-A0-C6-11-22-33
+	 * 0<-->C6112233, 1<-->00A0.
+	 */
+
+	/* low 32bit word */
+	sta = (((u32)addr[2]) << 24) | (((u32)addr[3]) << 16) |
+	      (((u32)addr[4]) << 8)  | (((u32)addr[5]));
+	writel(sta, adpt->base + EMAC_MAC_STA_ADDR0);
+
+	/* hight 32bit word */
+	sta = (((u32)addr[0]) << 8) | (u32)addr[1];
+	writel(sta, adpt->base + EMAC_MAC_STA_ADDR1);
+}
+
+void emac_mac_config(struct emac_adapter *adpt)
+{
+	struct net_device *netdev = adpt->netdev;
+	u32 val;
+
+	emac_set_mac_address(adpt, netdev->dev_addr);
+
+	emac_mac_dma_rings_config(adpt);
+
+	writel(netdev->mtu + ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN,
+	       adpt->base + EMAC_MAX_FRAM_LEN_CTRL);
+
+	emac_mac_tx_config(adpt);
+	emac_mac_rx_config(adpt);
+	emac_mac_dma_config(adpt);
+
+	val = readl(adpt->base + EMAC_AXI_MAST_CTRL);
+	val &= ~(DATA_BYTE_SWAP | MAX_BOUND);
+	val |= MAX_BTYPE;
+	writel(val, adpt->base + EMAC_AXI_MAST_CTRL);
+	writel(0, adpt->base + EMAC_CLK_GATE_CTRL);
+	writel(RX_UNCPL_INT_EN, adpt->base + EMAC_MISC_CTRL);
+}
+
+void emac_mac_reset(struct emac_adapter *adpt)
+{
+	writel(0, adpt->base + EMAC_INT_MASK);
+	writel(DIS_INT, adpt->base + EMAC_INT_STATUS);
+
+	emac_mac_stop(adpt);
+
+	emac_reg_update32(adpt->base + EMAC_DMA_MAS_CTRL, 0, SOFT_RST);
+	usleep_range(100, 150); /* reset may take upto 100usec */
+
+	/*  interrupt clear-on-read */
+	emac_reg_update32(adpt->base + EMAC_DMA_MAS_CTRL, 0, INT_RD_CLR_EN);
+}
+
+void emac_mac_start(struct emac_adapter *adpt)
+{
+	struct phy_device *phydev = adpt->phydev;
+	u32 mac, csr1;
+
+	/* enable tx queue */
+	emac_reg_update32(adpt->base + EMAC_TXQ_CTRL_0, 0, TXQ_EN);
+
+	/* enable rx queue */
+	emac_reg_update32(adpt->base + EMAC_RXQ_CTRL_0, 0, RXQ_EN);
+
+	/* enable mac control */
+	mac = readl(adpt->base + EMAC_MAC_CTRL);
+	csr1 = readl(adpt->csr + EMAC_EMAC_WRAPPER_CSR1);
+
+	mac |= TXEN | RXEN;     /* enable RX/TX */
+
+	/* We don't have ethtool support yet, so force flow-control mode
+	 * to 'full' always.
+	 */
+	mac |= TXFC | RXFC;
+
+	/* setup link speed */
+	mac &= ~SPEED_MASK;
+	if (phydev->speed == SPEED_1000) {
+		mac |= SPEED(2);
+		csr1 |= FREQ_MODE;
+	} else {
+		mac |= SPEED(1);
+		csr1 &= ~FREQ_MODE;
+	}
+
+	if (phydev->duplex == DUPLEX_FULL)
+		mac |= FULLD;
+	else
+		mac &= ~FULLD;
+
+	/* other parameters */
+	mac |= (CRCE | PCRCE);
+	mac |= ((adpt->preamble << PRLEN_SHFT) & PRLEN_BMSK);
+	mac |= BROAD_EN;
+	mac |= FLCHK;
+	mac &= ~RX_CHKSUM_EN;
+	mac &= ~(HUGEN | VLAN_STRIP | TPAUSE | SIMR | HUGE | MULTI_ALL |
+		 DEBUG_MODE | SINGLE_PAUSE_MODE);
+
+	writel_relaxed(csr1, adpt->csr + EMAC_EMAC_WRAPPER_CSR1);
+
+	writel_relaxed(mac, adpt->base + EMAC_MAC_CTRL);
+
+	/* enable interrupt read clear, low power sleep mode and
+	 * the irq moderators
+	 */
+
+	writel_relaxed(adpt->irq_mod, adpt->base + EMAC_IRQ_MOD_TIM_INIT);
+	writel_relaxed(INT_RD_CLR_EN | LPW_MODE | IRQ_MODERATOR_EN |
+			IRQ_MODERATOR2_EN, adpt->base + EMAC_DMA_MAS_CTRL);
+
+	emac_mac_mode_config(adpt);
+
+	emac_reg_update32(adpt->base + EMAC_ATHR_HEADER_CTRL,
+			  (HEADER_ENABLE | HEADER_CNT_EN), 0);
+
+	emac_reg_update32(adpt->csr + EMAC_EMAC_WRAPPER_CSR2, 0, WOL_EN);
+}
+
+void emac_mac_stop(struct emac_adapter *adpt)
+{
+	emac_reg_update32(adpt->base + EMAC_RXQ_CTRL_0, RXQ_EN, 0);
+	emac_reg_update32(adpt->base + EMAC_TXQ_CTRL_0, TXQ_EN, 0);
+	emac_reg_update32(adpt->base + EMAC_MAC_CTRL, TXEN | RXEN, 0);
+	usleep_range(1000, 1050); /* stopping mac may take upto 1msec */
+}
+
+/* Read one entry from the HW tx timestamp FIFO */
+static bool emac_mac_tx_ts_read(struct emac_adapter *adpt,
+				struct emac_tx_ts *ts)
+{
+	u32 ts_idx;
+
+	ts_idx = readl_relaxed(adpt->csr + EMAC_EMAC_WRAPPER_TX_TS_INX);
+
+	if (ts_idx & EMAC_WRAPPER_TX_TS_EMPTY)
+		return false;
+
+	ts->ns = readl_relaxed(adpt->csr + EMAC_EMAC_WRAPPER_TX_TS_LO);
+	ts->sec = readl_relaxed(adpt->csr + EMAC_EMAC_WRAPPER_TX_TS_HI);
+	ts->ts_idx = ts_idx & EMAC_WRAPPER_TX_TS_INX_BMSK;
+
+	return true;
+}
+
+/* Free all descriptors of given transmit queue */
+static void emac_tx_q_descs_free(struct emac_adapter *adpt)
+{
+	struct emac_tx_queue *tx_q = &adpt->tx_q;
+	unsigned int i;
+	size_t size;
+
+	/* ring already cleared, nothing to do */
+	if (!tx_q->tpd.tpbuff)
+		return;
+
+	for (i = 0; i < tx_q->tpd.count; i++) {
+		struct emac_buffer *tpbuf = GET_TPD_BUFFER(tx_q, i);
+
+		if (tpbuf->dma_addr) {
+			dma_unmap_single(adpt->netdev->dev.parent,
+					 tpbuf->dma_addr, tpbuf->length,
+					 DMA_TO_DEVICE);
+			tpbuf->dma_addr = 0;
+		}
+		if (tpbuf->skb) {
+			dev_kfree_skb_any(tpbuf->skb);
+			tpbuf->skb = NULL;
+		}
+	}
+
+	size = sizeof(struct emac_buffer) * tx_q->tpd.count;
+	memset(tx_q->tpd.tpbuff, 0, size);
+
+	/* clear the descriptor ring */
+	memset(tx_q->tpd.v_addr, 0, tx_q->tpd.size);
+
+	tx_q->tpd.consume_idx = 0;
+	tx_q->tpd.produce_idx = 0;
+}
+
+/* Free all descriptors of given receive queue */
+static void emac_rx_q_free_descs(struct emac_adapter *adpt)
+{
+	struct device *dev = adpt->netdev->dev.parent;
+	struct emac_rx_queue *rx_q = &adpt->rx_q;
+	unsigned int i;
+	size_t size;
+
+	/* ring already cleared, nothing to do */
+	if (!rx_q->rfd.rfbuff)
+		return;
+
+	for (i = 0; i < rx_q->rfd.count; i++) {
+		struct emac_buffer *rfbuf = GET_RFD_BUFFER(rx_q, i);
+
+		if (rfbuf->dma_addr) {
+			dma_unmap_single(dev, rfbuf->dma_addr, rfbuf->length,
+					 DMA_FROM_DEVICE);
+			rfbuf->dma_addr = 0;
+		}
+		if (rfbuf->skb) {
+			dev_kfree_skb(rfbuf->skb);
+			rfbuf->skb = NULL;
+		}
+	}
+
+	size =  sizeof(struct emac_buffer) * rx_q->rfd.count;
+	memset(rx_q->rfd.rfbuff, 0, size);
+
+	/* clear the descriptor rings */
+	memset(rx_q->rrd.v_addr, 0, rx_q->rrd.size);
+	rx_q->rrd.produce_idx = 0;
+	rx_q->rrd.consume_idx = 0;
+
+	memset(rx_q->rfd.v_addr, 0, rx_q->rfd.size);
+	rx_q->rfd.produce_idx = 0;
+	rx_q->rfd.consume_idx = 0;
+}
+
+/* Free all buffers associated with given transmit queue */
+static void emac_tx_q_bufs_free(struct emac_adapter *adpt)
+{
+	struct emac_tx_queue *tx_q = &adpt->tx_q;
+
+	emac_tx_q_descs_free(adpt);
+
+	kfree(tx_q->tpd.tpbuff);
+	tx_q->tpd.tpbuff = NULL;
+	tx_q->tpd.v_addr = NULL;
+	tx_q->tpd.dma_addr = 0;
+	tx_q->tpd.size = 0;
+}
+
+/* Allocate TX descriptor ring for the given transmit queue */
+static int emac_tx_q_desc_alloc(struct emac_adapter *adpt,
+				struct emac_tx_queue *tx_q)
+{
+	struct emac_ring_header *ring_header = &adpt->ring_header;
+	size_t size;
+
+	size = sizeof(struct emac_buffer) * tx_q->tpd.count;
+	tx_q->tpd.tpbuff = kzalloc(size, GFP_KERNEL);
+	if (!tx_q->tpd.tpbuff)
+		return -ENOMEM;
+
+	tx_q->tpd.size = tx_q->tpd.count * (adpt->tpd_size * 4);
+	tx_q->tpd.dma_addr = ring_header->dma_addr + ring_header->used;
+	tx_q->tpd.v_addr = ring_header->v_addr + ring_header->used;
+	ring_header->used += ALIGN(tx_q->tpd.size, 8);
+	tx_q->tpd.produce_idx = 0;
+	tx_q->tpd.consume_idx = 0;
+
+	return 0;
+}
+
+/* Free all buffers associated with given transmit queue */
+static void emac_rx_q_bufs_free(struct emac_adapter *adpt)
+{
+	struct emac_rx_queue *rx_q = &adpt->rx_q;
+
+	emac_rx_q_free_descs(adpt);
+
+	kfree(rx_q->rfd.rfbuff);
+	rx_q->rfd.rfbuff   = NULL;
+
+	rx_q->rfd.v_addr   = NULL;
+	rx_q->rfd.dma_addr = 0;
+	rx_q->rfd.size     = 0;
+
+	rx_q->rrd.v_addr   = NULL;
+	rx_q->rrd.dma_addr = 0;
+	rx_q->rrd.size     = 0;
+}
+
+/* Allocate RX descriptor rings for the given receive queue */
+static int emac_rx_descs_alloc(struct emac_adapter *adpt)
+{
+	struct emac_ring_header *ring_header = &adpt->ring_header;
+	struct emac_rx_queue *rx_q = &adpt->rx_q;
+	size_t size;
+
+	size = sizeof(struct emac_buffer) * rx_q->rfd.count;
+	rx_q->rfd.rfbuff = kzalloc(size, GFP_KERNEL);
+	if (!rx_q->rfd.rfbuff)
+		return -ENOMEM;
+
+	rx_q->rrd.size = rx_q->rrd.count * (adpt->rrd_size * 4);
+	rx_q->rfd.size = rx_q->rfd.count * (adpt->rfd_size * 4);
+
+	rx_q->rrd.dma_addr = ring_header->dma_addr + ring_header->used;
+	rx_q->rrd.v_addr   = ring_header->v_addr + ring_header->used;
+	ring_header->used += ALIGN(rx_q->rrd.size, 8);
+
+	rx_q->rfd.dma_addr = ring_header->dma_addr + ring_header->used;
+	rx_q->rfd.v_addr   = ring_header->v_addr + ring_header->used;
+	ring_header->used += ALIGN(rx_q->rfd.size, 8);
+
+	rx_q->rrd.produce_idx = 0;
+	rx_q->rrd.consume_idx = 0;
+
+	rx_q->rfd.produce_idx = 0;
+	rx_q->rfd.consume_idx = 0;
+
+	return 0;
+}
+
+/* Allocate all TX and RX descriptor rings */
+int emac_mac_rx_tx_rings_alloc_all(struct emac_adapter *adpt)
+{
+	struct emac_ring_header *ring_header = &adpt->ring_header;
+	struct device *dev = adpt->netdev->dev.parent;
+	unsigned int num_tx_descs = adpt->tx_desc_cnt;
+	unsigned int num_rx_descs = adpt->rx_desc_cnt;
+	int ret;
+
+	adpt->tx_q.tpd.count = adpt->tx_desc_cnt;
+
+	adpt->rx_q.rrd.count = adpt->rx_desc_cnt;
+	adpt->rx_q.rfd.count = adpt->rx_desc_cnt;
+
+	/* Ring DMA buffer. Each ring may need up to 8 bytes for alignment,
+	 * hence the additional padding bytes are allocated.
+	 */
+	ring_header->size = num_tx_descs * (adpt->tpd_size * 4) +
+			    num_rx_descs * (adpt->rfd_size * 4) +
+			    num_rx_descs * (adpt->rrd_size * 4) +
+			    8 + 2 * 8; /* 8 byte per one Tx and two Rx rings */
+
+	ring_header->used = 0;
+	ring_header->v_addr = dma_zalloc_coherent(dev, ring_header->size,
+						 &ring_header->dma_addr,
+						 GFP_KERNEL);
+	if (!ring_header->v_addr)
+		return -ENOMEM;
+
+	ring_header->used = ALIGN(ring_header->dma_addr, 8) -
+							ring_header->dma_addr;
+
+	ret = emac_tx_q_desc_alloc(adpt, &adpt->tx_q);
+	if (ret) {
+		netdev_err(adpt->netdev, "error: Tx Queue alloc failed\n");
+		goto err_alloc_tx;
+	}
+
+	ret = emac_rx_descs_alloc(adpt);
+	if (ret) {
+		netdev_err(adpt->netdev, "error: Rx Queue alloc failed\n");
+		goto err_alloc_rx;
+	}
+
+	return 0;
+
+err_alloc_rx:
+	emac_tx_q_bufs_free(adpt);
+err_alloc_tx:
+	dma_free_coherent(dev, ring_header->size,
+			  ring_header->v_addr, ring_header->dma_addr);
+
+	ring_header->v_addr   = NULL;
+	ring_header->dma_addr = 0;
+	ring_header->size     = 0;
+	ring_header->used     = 0;
+
+	return ret;
+}
+
+/* Free all TX and RX descriptor rings */
+void emac_mac_rx_tx_rings_free_all(struct emac_adapter *adpt)
+{
+	struct emac_ring_header *ring_header = &adpt->ring_header;
+	struct device *dev = adpt->netdev->dev.parent;
+
+	emac_tx_q_bufs_free(adpt);
+	emac_rx_q_bufs_free(adpt);
+
+	dma_free_coherent(dev, ring_header->size,
+			  ring_header->v_addr, ring_header->dma_addr);
+
+	ring_header->v_addr   = NULL;
+	ring_header->dma_addr = 0;
+	ring_header->size     = 0;
+	ring_header->used     = 0;
+}
+
+/* Initialize descriptor rings */
+static void emac_mac_rx_tx_ring_reset_all(struct emac_adapter *adpt)
+{
+	unsigned int i;
+
+	adpt->tx_q.tpd.produce_idx = 0;
+	adpt->tx_q.tpd.consume_idx = 0;
+	for (i = 0; i < adpt->tx_q.tpd.count; i++)
+		adpt->tx_q.tpd.tpbuff[i].dma_addr = 0;
+
+	adpt->rx_q.rrd.produce_idx = 0;
+	adpt->rx_q.rrd.consume_idx = 0;
+	adpt->rx_q.rfd.produce_idx = 0;
+	adpt->rx_q.rfd.consume_idx = 0;
+	for (i = 0; i < adpt->rx_q.rfd.count; i++)
+		adpt->rx_q.rfd.rfbuff[i].dma_addr = 0;
+}
+
+/* Produce new receive free descriptor */
+static void emac_mac_rx_rfd_create(struct emac_adapter *adpt,
+				   struct emac_rx_queue *rx_q,
+				   dma_addr_t addr)
+{
+	u32 *hw_rfd = EMAC_RFD(rx_q, adpt->rfd_size, rx_q->rfd.produce_idx);
+
+	*(hw_rfd++) = lower_32_bits(addr);
+	*hw_rfd = upper_32_bits(addr);
+
+	if (++rx_q->rfd.produce_idx == rx_q->rfd.count)
+		rx_q->rfd.produce_idx = 0;
+}
+
+/* Fill up receive queue's RFD with preallocated receive buffers */
+static void emac_mac_rx_descs_refill(struct emac_adapter *adpt,
+				    struct emac_rx_queue *rx_q)
+{
+	struct emac_buffer *curr_rxbuf;
+	struct emac_buffer *next_rxbuf;
+	unsigned int count = 0;
+	u32 next_produce_idx;
+
+	next_produce_idx = rx_q->rfd.produce_idx + 1;
+	if (next_produce_idx == rx_q->rfd.count)
+		next_produce_idx = 0;
+
+	curr_rxbuf = GET_RFD_BUFFER(rx_q, rx_q->rfd.produce_idx);
+	next_rxbuf = GET_RFD_BUFFER(rx_q, next_produce_idx);
+
+	/* this always has a blank rx_buffer*/
+	while (!next_rxbuf->dma_addr) {
+		struct sk_buff *skb;
+		void *skb_data;
+
+		skb = dev_alloc_skb(adpt->rxbuf_size + NET_IP_ALIGN);
+		if (!skb)
+			break;
+
+		/* Make buffer alignment 2 beyond a 16 byte boundary
+		 * this will result in a 16 byte aligned IP header after
+		 * the 14 byte MAC header is removed
+		 */
+		skb_reserve(skb, NET_IP_ALIGN);
+		skb_data = skb->data;
+		curr_rxbuf->skb = skb;
+		curr_rxbuf->length = adpt->rxbuf_size;
+		curr_rxbuf->dma_addr = dma_map_single(adpt->netdev->dev.parent,
+						      skb_data,
+						      curr_rxbuf->length,
+						      DMA_FROM_DEVICE);
+		emac_mac_rx_rfd_create(adpt, rx_q, curr_rxbuf->dma_addr);
+		next_produce_idx = rx_q->rfd.produce_idx + 1;
+		if (next_produce_idx == rx_q->rfd.count)
+			next_produce_idx = 0;
+
+		curr_rxbuf = GET_RFD_BUFFER(rx_q, rx_q->rfd.produce_idx);
+		next_rxbuf = GET_RFD_BUFFER(rx_q, next_produce_idx);
+		count++;
+	}
+
+	if (count) {
+		u32 prod_idx = (rx_q->rfd.produce_idx << rx_q->produce_shift) &
+				rx_q->produce_mask;
+		emac_reg_update32(adpt->base + rx_q->produce_reg,
+				  rx_q->produce_mask, prod_idx);
+	}
+}
+
+static void emac_adjust_link(struct net_device *netdev)
+{
+	struct emac_adapter *adpt = netdev_priv(netdev);
+	struct phy_device *phydev = netdev->phydev;
+
+	if (phydev->link)
+		emac_mac_start(adpt);
+	else
+		emac_mac_stop(adpt);
+
+	phy_print_status(phydev);
+}
+
+/* Bringup the interface/HW */
+int emac_mac_up(struct emac_adapter *adpt)
+{
+	struct net_device *netdev = adpt->netdev;
+	struct emac_irq	*irq = &adpt->irq;
+	int ret;
+
+	emac_mac_rx_tx_ring_reset_all(adpt);
+	emac_mac_config(adpt);
+
+	ret = request_irq(irq->irq, emac_isr, 0, EMAC_MAC_IRQ_RES, irq);
+	if (ret) {
+		netdev_err(adpt->netdev,
+			   "error:%d on request_irq(%d:%s flags:0)\n", ret,
+			   irq->irq, EMAC_MAC_IRQ_RES);
+		return ret;
+	}
+
+	emac_mac_rx_descs_refill(adpt, &adpt->rx_q);
+
+	ret = phy_connect_direct(netdev, adpt->phydev, emac_adjust_link,
+				 PHY_INTERFACE_MODE_SGMII);
+	if (ret) {
+		netdev_err(adpt->netdev,
+			   "error:%d on request_irq(%d:%s flags:0)\n", ret,
+			   irq->irq, EMAC_MAC_IRQ_RES);
+		return ret;
+	}
+
+	/* enable mac irq */
+	writel((u32)~DIS_INT, adpt->base + EMAC_INT_STATUS);
+	writel(adpt->irq.mask, adpt->base + EMAC_INT_MASK);
+
+	adpt->phydev->irq = PHY_IGNORE_INTERRUPT;
+	phy_start(adpt->phydev);
+
+	napi_enable(&adpt->rx_q.napi);
+	netif_start_queue(netdev);
+
+	return 0;
+}
+
+/* Bring down the interface/HW */
+void emac_mac_down(struct emac_adapter *adpt, bool reset)
+{
+	struct net_device *netdev = adpt->netdev;
+	unsigned long flags;
+
+	netif_stop_queue(netdev);
+	napi_disable(&adpt->rx_q.napi);
+
+	phy_disconnect(adpt->phydev);
+
+	/* disable mac irq */
+	writel(DIS_INT, adpt->base + EMAC_INT_STATUS);
+	writel(0, adpt->base + EMAC_INT_MASK);
+	synchronize_irq(adpt->irq.irq);
+	free_irq(adpt->irq.irq, &adpt->irq);
+	clear_bit(EMAC_STATUS_TASK_REINIT_REQ, &adpt->status);
+
+	cancel_work_sync(&adpt->tx_ts_task);
+	spin_lock_irqsave(&adpt->tx_ts_lock, flags);
+	__skb_queue_purge(&adpt->tx_ts_pending_queue);
+	__skb_queue_purge(&adpt->tx_ts_ready_queue);
+	spin_unlock_irqrestore(&adpt->tx_ts_lock, flags);
+
+	if (reset)
+		emac_mac_reset(adpt);
+
+	emac_tx_q_descs_free(adpt);
+	netdev_reset_queue(adpt->netdev);
+	emac_rx_q_free_descs(adpt);
+}
+
+/* Consume next received packet descriptor */
+static bool emac_rx_process_rrd(struct emac_adapter *adpt,
+				struct emac_rx_queue *rx_q,
+				struct emac_rrd *rrd)
+{
+	u32 *hw_rrd = EMAC_RRD(rx_q, adpt->rrd_size, rx_q->rrd.consume_idx);
+
+	/* If time stamping is enabled, it will be added in the beginning of
+	 * the hw rrd (hw_rrd). In sw rrd (rrd), 32bit words 4 & 5 are reserved
+	 * for the time stamp; hence the conversion.
+	 * Also, read the rrd word with update flag first; read rest of rrd
+	 * only if update flag is set.
+	 */
+	if (adpt->timestamp_en)
+		rrd->word[3] = *(hw_rrd + 5);
+	else
+		rrd->word[3] = *(hw_rrd + 3);
+
+	if (!RRD_UPDT(rrd))
+		return false;
+
+	if (adpt->timestamp_en) {
+		rrd->word[4] = *(hw_rrd++);
+		rrd->word[5] = *(hw_rrd++);
+	} else {
+		rrd->word[4] = 0;
+		rrd->word[5] = 0;
+	}
+
+	rrd->word[0] = *(hw_rrd++);
+	rrd->word[1] = *(hw_rrd++);
+	rrd->word[2] = *(hw_rrd++);
+
+	if (unlikely(RRD_NOR(rrd) != 1)) {
+		netdev_err(adpt->netdev,
+			   "error: multi-RFD not support yet! nor:%lu\n",
+			   RRD_NOR(rrd));
+	}
+
+	/* mark rrd as processed */
+	RRD_UPDT_SET(rrd, 0);
+	*hw_rrd = rrd->word[3];
+
+	if (++rx_q->rrd.consume_idx == rx_q->rrd.count)
+		rx_q->rrd.consume_idx = 0;
+
+	return true;
+}
+
+/* Produce new transmit descriptor */
+static bool emac_tx_tpd_create(struct emac_adapter *adpt,
+			       struct emac_tx_queue *tx_q, struct emac_tpd *tpd)
+{
+	u32 *hw_tpd;
+
+	tx_q->tpd.last_produce_idx = tx_q->tpd.produce_idx;
+	hw_tpd = EMAC_TPD(tx_q, adpt->tpd_size, tx_q->tpd.produce_idx);
+
+	if (++tx_q->tpd.produce_idx == tx_q->tpd.count)
+		tx_q->tpd.produce_idx = 0;
+
+	*(hw_tpd++) = tpd->word[0];
+	*(hw_tpd++) = tpd->word[1];
+	*(hw_tpd++) = tpd->word[2];
+	*hw_tpd = tpd->word[3];
+
+	return true;
+}
+
+/* Mark the last transmit descriptor as such (for the transmit packet) */
+static void emac_tx_tpd_mark_last(struct emac_adapter *adpt,
+				  struct emac_tx_queue *tx_q)
+{
+	u32 *hw_tpd =
+		EMAC_TPD(tx_q, adpt->tpd_size, tx_q->tpd.last_produce_idx);
+	u32 tmp_tpd;
+
+	tmp_tpd = *(hw_tpd + 1);
+	tmp_tpd |= EMAC_TPD_LAST_FRAGMENT;
+	*(hw_tpd + 1) = tmp_tpd;
+}
+
+static void emac_rx_rfd_clean(struct emac_rx_queue *rx_q, struct emac_rrd *rrd)
+{
+	struct emac_buffer *rfbuf = rx_q->rfd.rfbuff;
+	u32 consume_idx = RRD_SI(rrd);
+	unsigned int i;
+
+	for (i = 0; i < RRD_NOR(rrd); i++) {
+		rfbuf[consume_idx].skb = NULL;
+		if (++consume_idx == rx_q->rfd.count)
+			consume_idx = 0;
+	}
+
+	rx_q->rfd.consume_idx = consume_idx;
+	rx_q->rfd.process_idx = consume_idx;
+}
+
+/* proper lock must be acquired before polling */
+static void emac_tx_ts_poll(struct emac_adapter *adpt)
+{
+	struct sk_buff_head *pending_q = &adpt->tx_ts_pending_queue;
+	struct sk_buff_head *q = &adpt->tx_ts_ready_queue;
+	struct sk_buff *skb, *skb_tmp;
+	struct emac_tx_ts tx_ts;
+
+	while (emac_mac_tx_ts_read(adpt, &tx_ts)) {
+		bool found = false;
+
+		adpt->tx_ts_stats.rx++;
+
+		skb_queue_walk_safe(pending_q, skb, skb_tmp) {
+			if (EMAC_SKB_CB(skb)->tpd_idx == tx_ts.ts_idx) {
+				struct sk_buff *pskb;
+
+				EMAC_TX_TS_CB(skb)->sec = tx_ts.sec;
+				EMAC_TX_TS_CB(skb)->ns = tx_ts.ns;
+				/* the tx timestamps for all the pending
+				 * packets before this one are lost
+				 */
+				while ((pskb = __skb_dequeue(pending_q))
+				       != skb) {
+					EMAC_TX_TS_CB(pskb)->sec = 0;
+					EMAC_TX_TS_CB(pskb)->ns = 0;
+					__skb_queue_tail(q, pskb);
+					adpt->tx_ts_stats.lost++;
+				}
+				__skb_queue_tail(q, skb);
+				found = true;
+				break;
+			}
+		}
+
+		if (!found) {
+			netif_dbg(adpt, tx_done, adpt->netdev,
+				  "no entry(tpd=%d) found, drop tx timestamp\n",
+				  tx_ts.ts_idx);
+			adpt->tx_ts_stats.drop++;
+		}
+	}
+
+	skb_queue_walk_safe(pending_q, skb, skb_tmp) {
+		/* No packet after this one expires */
+		if (time_is_after_jiffies(EMAC_SKB_CB(skb)->jiffies +
+					  msecs_to_jiffies(100)))
+			break;
+		adpt->tx_ts_stats.timeout++;
+		netif_dbg(adpt, tx_done, adpt->netdev,
+			  "tx timestamp timeout: tpd_idx=%d\n",
+			  EMAC_SKB_CB(skb)->tpd_idx);
+
+		__skb_unlink(skb, pending_q);
+		EMAC_TX_TS_CB(skb)->sec = 0;
+		EMAC_TX_TS_CB(skb)->ns = 0;
+		__skb_queue_tail(q, skb);
+	}
+}
+
+static void emac_schedule_tx_ts_task(struct emac_adapter *adpt)
+{
+	if (schedule_work(&adpt->tx_ts_task))
+		adpt->tx_ts_stats.sched++;
+}
+
+void emac_mac_tx_ts_periodic_routine(struct work_struct *work)
+{
+	struct emac_adapter *adpt =
+		container_of(work, struct emac_adapter, tx_ts_task);
+	struct sk_buff_head q;
+	struct sk_buff *skb;
+	unsigned long flags;
+
+	adpt->tx_ts_stats.poll++;
+
+	__skb_queue_head_init(&q);
+
+	while (1) {
+		spin_lock_irqsave(&adpt->tx_ts_lock, flags);
+		if (adpt->tx_ts_pending_queue.qlen)
+			emac_tx_ts_poll(adpt);
+		skb_queue_splice_tail_init(&adpt->tx_ts_ready_queue, &q);
+		spin_unlock_irqrestore(&adpt->tx_ts_lock, flags);
+
+		if (!q.qlen)
+			break;
+
+		while ((skb = __skb_dequeue(&q))) {
+			struct emac_tx_ts_cb *cb = EMAC_TX_TS_CB(skb);
+
+			if (cb->sec || cb->ns) {
+				struct skb_shared_hwtstamps ts;
+
+				ts.hwtstamp = ktime_set(cb->sec, cb->ns);
+				skb_tstamp_tx(skb, &ts);
+				adpt->tx_ts_stats.deliver++;
+			}
+			dev_kfree_skb_any(skb);
+		}
+	}
+
+	if (adpt->tx_ts_pending_queue.qlen)
+		emac_schedule_tx_ts_task(adpt);
+}
+
+/* Push the received skb to upper layers */
+static void emac_receive_skb(struct emac_rx_queue *rx_q,
+			     struct sk_buff *skb,
+			     u16 vlan_tag, bool vlan_flag)
+{
+	if (vlan_flag) {
+		u16 vlan;
+
+		EMAC_TAG_TO_VLAN(vlan_tag, vlan);
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan);
+	}
+
+	napi_gro_receive(&rx_q->napi, skb);
+}
+
+/* Process receive event */
+void emac_mac_rx_process(struct emac_adapter *adpt, struct emac_rx_queue *rx_q,
+			 int *num_pkts, int max_pkts)
+{
+	u32 proc_idx, hw_consume_idx, num_consume_pkts;
+	struct net_device *netdev  = adpt->netdev;
+	struct emac_buffer *rfbuf;
+	unsigned int count = 0;
+	struct emac_rrd rrd;
+	struct sk_buff *skb;
+	u32 reg;
+
+	reg = readl_relaxed(adpt->base + rx_q->consume_reg);
+
+	hw_consume_idx = (reg & rx_q->consume_mask) >> rx_q->consume_shift;
+	num_consume_pkts = (hw_consume_idx >= rx_q->rrd.consume_idx) ?
+		(hw_consume_idx -  rx_q->rrd.consume_idx) :
+		(hw_consume_idx + rx_q->rrd.count - rx_q->rrd.consume_idx);
+
+	do {
+		if (!num_consume_pkts)
+			break;
+
+		if (!emac_rx_process_rrd(adpt, rx_q, &rrd))
+			break;
+
+		if (likely(RRD_NOR(&rrd) == 1)) {
+			/* good receive */
+			rfbuf = GET_RFD_BUFFER(rx_q, RRD_SI(&rrd));
+			dma_unmap_single(adpt->netdev->dev.parent,
+					 rfbuf->dma_addr, rfbuf->length,
+					 DMA_FROM_DEVICE);
+			rfbuf->dma_addr = 0;
+			skb = rfbuf->skb;
+		} else {
+			netdev_err(adpt->netdev,
+				   "error: multi-RFD not support yet!\n");
+			break;
+		}
+		emac_rx_rfd_clean(rx_q, &rrd);
+		num_consume_pkts--;
+		count++;
+
+		/* Due to a HW issue in L4 check sum detection (UDP/TCP frags
+		 * with DF set are marked as error), drop packets based on the
+		 * error mask rather than the summary bit (ignoring L4F errors)
+		 */
+		if (rrd.word[EMAC_RRD_STATS_DW_IDX] & EMAC_RRD_ERROR) {
+			netif_dbg(adpt, rx_status, adpt->netdev,
+				  "Drop error packet[RRD: 0x%x:0x%x:0x%x:0x%x]\n",
+				  rrd.word[0], rrd.word[1],
+				  rrd.word[2], rrd.word[3]);
+
+			dev_kfree_skb(skb);
+			continue;
+		}
+
+		skb_put(skb, RRD_PKT_SIZE(&rrd) - ETH_FCS_LEN);
+		skb->dev = netdev;
+		skb->protocol = eth_type_trans(skb, skb->dev);
+		if (netdev->features & NETIF_F_RXCSUM)
+			skb->ip_summed = RRD_L4F(&rrd) ?
+					  CHECKSUM_NONE : CHECKSUM_UNNECESSARY;
+		else
+			skb_checksum_none_assert(skb);
+
+		emac_receive_skb(rx_q, skb, (u16)RRD_CVALN_TAG(&rrd),
+				 (bool)RRD_CVTAG(&rrd));
+
+		netdev->last_rx = jiffies;
+		(*num_pkts)++;
+	} while (*num_pkts < max_pkts);
+
+	if (count) {
+		proc_idx = (rx_q->rfd.process_idx << rx_q->process_shft) &
+				rx_q->process_mask;
+		emac_reg_update32(adpt->base + rx_q->process_reg,
+				  rx_q->process_mask, proc_idx);
+		emac_mac_rx_descs_refill(adpt, rx_q);
+	}
+}
+
+/* Process transmit event */
+void emac_mac_tx_process(struct emac_adapter *adpt, struct emac_tx_queue *tx_q)
+{
+	u32 reg = readl_relaxed(adpt->base + tx_q->consume_reg);
+	u32 hw_consume_idx, pkts_compl = 0, bytes_compl = 0;
+	struct emac_buffer *tpbuf;
+
+	hw_consume_idx = (reg & tx_q->consume_mask) >> tx_q->consume_shift;
+
+	while (tx_q->tpd.consume_idx != hw_consume_idx) {
+		tpbuf = GET_TPD_BUFFER(tx_q, tx_q->tpd.consume_idx);
+		if (tpbuf->dma_addr) {
+			dma_unmap_single(adpt->netdev->dev.parent,
+					 tpbuf->dma_addr, tpbuf->length,
+					 DMA_TO_DEVICE);
+			tpbuf->dma_addr = 0;
+		}
+
+		if (tpbuf->skb) {
+			pkts_compl++;
+			bytes_compl += tpbuf->skb->len;
+			dev_kfree_skb_irq(tpbuf->skb);
+			tpbuf->skb = NULL;
+		}
+
+		if (++tx_q->tpd.consume_idx == tx_q->tpd.count)
+			tx_q->tpd.consume_idx = 0;
+	}
+
+	netdev_completed_queue(adpt->netdev, pkts_compl, bytes_compl);
+}
+
+/* Initialize all queue data structures */
+void emac_mac_rx_tx_ring_init_all(struct platform_device *pdev,
+				  struct emac_adapter *adpt)
+{
+	adpt->rx_q.netdev = adpt->netdev;
+
+	adpt->rx_q.produce_reg  = EMAC_MAILBOX_0;
+	adpt->rx_q.produce_mask = RFD0_PROD_IDX_BMSK;
+	adpt->rx_q.produce_shift = RFD0_PROD_IDX_SHFT;
+
+	adpt->rx_q.process_reg  = EMAC_MAILBOX_0;
+	adpt->rx_q.process_mask = RFD0_PROC_IDX_BMSK;
+	adpt->rx_q.process_shft = RFD0_PROC_IDX_SHFT;
+
+	adpt->rx_q.consume_reg  = EMAC_MAILBOX_3;
+	adpt->rx_q.consume_mask = RFD0_CONS_IDX_BMSK;
+	adpt->rx_q.consume_shift = RFD0_CONS_IDX_SHFT;
+
+	adpt->rx_q.irq          = &adpt->irq;
+	adpt->rx_q.intr         = adpt->irq.mask & ISR_RX_PKT;
+
+	adpt->tx_q.produce_reg  = EMAC_MAILBOX_15;
+	adpt->tx_q.produce_mask = NTPD_PROD_IDX_BMSK;
+	adpt->tx_q.produce_shift = NTPD_PROD_IDX_SHFT;
+
+	adpt->tx_q.consume_reg  = EMAC_MAILBOX_2;
+	adpt->tx_q.consume_mask = NTPD_CONS_IDX_BMSK;
+	adpt->tx_q.consume_shift = NTPD_CONS_IDX_SHFT;
+}
+
+/* get the number of free transmit descriptors */
+static u32 emac_tpd_num_free_descs(struct emac_tx_queue *tx_q)
+{
+	u32 produce_idx = tx_q->tpd.produce_idx;
+	u32 consume_idx = tx_q->tpd.consume_idx;
+
+	return (consume_idx > produce_idx) ?
+		(consume_idx - produce_idx - 1) :
+		(tx_q->tpd.count + consume_idx - produce_idx - 1);
+}
+
+/* Check if enough transmit descriptors are available */
+static bool emac_tx_has_enough_descs(struct emac_tx_queue *tx_q,
+				     const struct sk_buff *skb)
+{
+	unsigned int num_required = 1;
+	u16 proto_hdr_len = 0;
+
+	if (skb_is_gso(skb)) {
+		proto_hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
+		if (proto_hdr_len < skb_headlen(skb))
+			num_required++;
+		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
+			num_required++;
+	}
+
+	num_required += skb_shinfo(skb)->nr_frags;
+
+	return num_required < emac_tpd_num_free_descs(tx_q);
+}
+
+/* Fill up transmit descriptors with TSO and Checksum offload information */
+static int emac_tso_csum(struct emac_adapter *adpt,
+			 struct emac_tx_queue *tx_q,
+			 struct sk_buff *skb,
+			 struct emac_tpd *tpd)
+{
+	unsigned int hdr_len;
+	int ret;
+
+	if (skb_is_gso(skb)) {
+		if (skb_header_cloned(skb)) {
+			ret = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
+			if (unlikely(ret))
+				return ret;
+		}
+
+		if (skb->protocol == htons(ETH_P_IP)) {
+			u32 pkt_len = ((unsigned char *)ip_hdr(skb) - skb->data)
+				       + ntohs(ip_hdr(skb)->tot_len);
+			if (skb->len > pkt_len)
+				pskb_trim(skb, pkt_len);
+		}
+
+		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
+		if (unlikely(skb->len == hdr_len)) {
+			/* we only need to do csum */
+			netif_warn(adpt, tx_err, adpt->netdev,
+				   "tso not needed for packet with 0 data\n");
+			goto do_csum;
+		}
+
+		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4) {
+			ip_hdr(skb)->check = 0;
+			tcp_hdr(skb)->check = ~csum_tcpudp_magic(
+						ip_hdr(skb)->saddr,
+						ip_hdr(skb)->daddr,
+						0, IPPROTO_TCP, 0);
+			TPD_IPV4_SET(tpd, 1);
+		}
+
+		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6) {
+			/* ipv6 tso need an extra tpd */
+			struct emac_tpd extra_tpd;
+
+			memset(tpd, 0, sizeof(*tpd));
+			memset(&extra_tpd, 0, sizeof(extra_tpd));
+
+			ipv6_hdr(skb)->payload_len = 0;
+			tcp_hdr(skb)->check = ~csum_ipv6_magic(
+						&ipv6_hdr(skb)->saddr,
+						&ipv6_hdr(skb)->daddr,
+						0, IPPROTO_TCP, 0);
+			TPD_PKT_LEN_SET(&extra_tpd, skb->len);
+			TPD_LSO_SET(&extra_tpd, 1);
+			TPD_LSOV_SET(&extra_tpd, 1);
+			emac_tx_tpd_create(adpt, tx_q, &extra_tpd);
+			TPD_LSOV_SET(tpd, 1);
+		}
+
+		TPD_LSO_SET(tpd, 1);
+		TPD_TCPHDR_OFFSET_SET(tpd, skb_transport_offset(skb));
+		TPD_MSS_SET(tpd, skb_shinfo(skb)->gso_size);
+		return 0;
+	}
+
+do_csum:
+	if (likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
+		unsigned int css, cso;
+
+		cso = skb_transport_offset(skb);
+		if (unlikely(cso & 0x1)) {
+			netdev_err(adpt->netdev,
+				   "error: payload offset should be even\n");
+			return -EINVAL;
+		}
+		css = cso + skb->csum_offset;
+
+		TPD_PAYLOAD_OFFSET_SET(tpd, cso >> 1);
+		TPD_CXSUM_OFFSET_SET(tpd, css >> 1);
+		TPD_CSX_SET(tpd, 1);
+	}
+
+	return 0;
+}
+
+/* Fill up transmit descriptors */
+static void emac_tx_fill_tpd(struct emac_adapter *adpt,
+			     struct emac_tx_queue *tx_q, struct sk_buff *skb,
+			     struct emac_tpd *tpd)
+{
+	u16 nr_frags = skb_shinfo(skb)->nr_frags;
+	unsigned int len = skb_headlen(skb);
+	struct emac_buffer *tpbuf = NULL;
+	unsigned int mapped_len = 0;
+	unsigned int map_len = 0;
+	unsigned int hdr_len = 0;
+	unsigned int i;
+
+	/* if Large Segment Offload is (in TCP Segmentation Offload struct) */
+	if (TPD_LSO(tpd)) {
+		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
+		map_len = hdr_len;
+
+		tpbuf = GET_TPD_BUFFER(tx_q, tx_q->tpd.produce_idx);
+		tpbuf->length = map_len;
+		tpbuf->dma_addr = dma_map_single(adpt->netdev->dev.parent,
+						 skb->data, hdr_len,
+						 DMA_TO_DEVICE);
+		mapped_len += map_len;
+		TPD_BUFFER_ADDR_L_SET(tpd, lower_32_bits(tpbuf->dma_addr));
+		TPD_BUFFER_ADDR_H_SET(tpd, upper_32_bits(tpbuf->dma_addr));
+		TPD_BUF_LEN_SET(tpd, tpbuf->length);
+		emac_tx_tpd_create(adpt, tx_q, tpd);
+	}
+
+	if (mapped_len < len) {
+		tpbuf = GET_TPD_BUFFER(tx_q, tx_q->tpd.produce_idx);
+		tpbuf->length = len - mapped_len;
+		tpbuf->dma_addr = dma_map_single(adpt->netdev->dev.parent,
+						 skb->data + mapped_len,
+						 tpbuf->length, DMA_TO_DEVICE);
+		TPD_BUFFER_ADDR_L_SET(tpd, lower_32_bits(tpbuf->dma_addr));
+		TPD_BUFFER_ADDR_H_SET(tpd, upper_32_bits(tpbuf->dma_addr));
+		TPD_BUF_LEN_SET(tpd, tpbuf->length);
+		emac_tx_tpd_create(adpt, tx_q, tpd);
+	}
+
+	for (i = 0; i < nr_frags; i++) {
+		struct skb_frag_struct *frag;
+
+		frag = &skb_shinfo(skb)->frags[i];
+
+		tpbuf = GET_TPD_BUFFER(tx_q, tx_q->tpd.produce_idx);
+		tpbuf->length = frag->size;
+		tpbuf->dma_addr = dma_map_page(adpt->netdev->dev.parent,
+					       frag->page.p, frag->page_offset,
+					       tpbuf->length, DMA_TO_DEVICE);
+		TPD_BUFFER_ADDR_L_SET(tpd, lower_32_bits(tpbuf->dma_addr));
+		TPD_BUFFER_ADDR_H_SET(tpd, upper_32_bits(tpbuf->dma_addr));
+		TPD_BUF_LEN_SET(tpd, tpbuf->length);
+		emac_tx_tpd_create(adpt, tx_q, tpd);
+	}
+
+	/* The last tpd */
+	emac_tx_tpd_mark_last(adpt, tx_q);
+
+	/* The last buffer info contain the skb address,
+	 * so it will be freed after unmap
+	 */
+	tpbuf->skb = skb;
+}
+
+/* Transmit the packet using specified transmit queue */
+int emac_mac_tx_buf_send(struct emac_adapter *adpt, struct emac_tx_queue *tx_q,
+			 struct sk_buff *skb)
+{
+	struct emac_tpd tpd;
+	u32 prod_idx;
+
+	if (!emac_tx_has_enough_descs(tx_q, skb)) {
+		/* not enough descriptors, just stop queue */
+		netif_stop_queue(adpt->netdev);
+		return NETDEV_TX_BUSY;
+	}
+
+	memset(&tpd, 0, sizeof(tpd));
+
+	if (emac_tso_csum(adpt, tx_q, skb, &tpd) != 0) {
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
+	}
+
+	if (skb_vlan_tag_present(skb)) {
+		u16 tag;
+
+		EMAC_VLAN_TO_TAG(skb_vlan_tag_get(skb), tag);
+		TPD_CVLAN_TAG_SET(&tpd, tag);
+		TPD_INSTC_SET(&tpd, 1);
+	}
+
+	if (skb_network_offset(skb) != ETH_HLEN)
+		TPD_TYP_SET(&tpd, 1);
+
+	emac_tx_fill_tpd(adpt, tx_q, skb, &tpd);
+
+	netdev_sent_queue(adpt->netdev, skb->len);
+
+	/* update produce idx */
+	prod_idx = (tx_q->tpd.produce_idx << tx_q->produce_shift) &
+		    tx_q->produce_mask;
+	emac_reg_update32(adpt->base + tx_q->produce_reg,
+			  tx_q->produce_mask, prod_idx);
+
+	return NETDEV_TX_OK;
+}
diff --git a/drivers/net/ethernet/qualcomm/emac/emac-mac.h b/drivers/net/ethernet/qualcomm/emac/emac-mac.h
new file mode 100644
index 0000000..8ab1d0f
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/emac/emac-mac.h
@@ -0,0 +1,271 @@
+/* Copyright (c) 2013-2016, The Linux Foundation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 and
+ * only version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+/* EMAC DMA HW engine uses three rings:
+ * Tx:
+ *   TPD: Transmit Packet Descriptor ring.
+ * Rx:
+ *   RFD: Receive Free Descriptor ring.
+ *     Ring of descriptors with empty buffers to be filled by Rx HW.
+ *   RRD: Receive Return Descriptor ring.
+ *     Ring of descriptors with buffers filled with received data.
+ */
+
+#ifndef _EMAC_HW_H_
+#define _EMAC_HW_H_
+
+/* EMAC_CSR register offsets */
+#define EMAC_EMAC_WRAPPER_CSR1                                0x000000
+#define EMAC_EMAC_WRAPPER_CSR2                                0x000004
+#define EMAC_EMAC_WRAPPER_TX_TS_LO                            0x000104
+#define EMAC_EMAC_WRAPPER_TX_TS_HI                            0x000108
+#define EMAC_EMAC_WRAPPER_TX_TS_INX                           0x00010c
+
+#define EMAC_MAC_IRQ_RES                                    "core0_irq"
+
+/* DMA Order Settings */
+enum emac_dma_order {
+	emac_dma_ord_in = 1,
+	emac_dma_ord_enh = 2,
+	emac_dma_ord_out = 4
+};
+
+enum emac_dma_req_block {
+	emac_dma_req_128 = 0,
+	emac_dma_req_256 = 1,
+	emac_dma_req_512 = 2,
+	emac_dma_req_1024 = 3,
+	emac_dma_req_2048 = 4,
+	emac_dma_req_4096 = 5
+};
+
+/* Returns the value of bits idx...idx+n_bits */
+#define BITS_GET(val, lo, hi) (((val) & GENMASK((hi), (lo))) >> lo)
+#define BITS_SET(val, lo, hi, new_val)				\
+	((val) = (((val) & (~GENMASK((hi), (lo)))) |		\
+		(((new_val) << (lo)) & GENMASK((hi), (lo)))))
+
+/* RRD (Receive Return Descriptor) */
+struct emac_rrd {
+	u32	word[6];
+
+/* number of RFD */
+#define RRD_NOR(rrd)			BITS_GET((rrd)->word[0], 16, 19)
+/* start consumer index of rfd-ring */
+#define RRD_SI(rrd)			BITS_GET((rrd)->word[0], 20, 31)
+/* vlan-tag (CVID, CFI and PRI) */
+#define RRD_CVALN_TAG(rrd)		BITS_GET((rrd)->word[2], 0, 15)
+/* length of the packet */
+#define RRD_PKT_SIZE(rrd)		BITS_GET((rrd)->word[3], 0, 13)
+/* L4(TCP/UDP) checksum failed */
+#define RRD_L4F(rrd)			BITS_GET((rrd)->word[3], 14, 14)
+/* vlan tagged */
+#define RRD_CVTAG(rrd)			BITS_GET((rrd)->word[3], 16, 16)
+/* When set, indicates that the descriptor is updated by the IP core.
+ * When cleared, indicates that the descriptor is invalid.
+ */
+#define RRD_UPDT(rrd)			BITS_GET((rrd)->word[3], 31, 31)
+#define RRD_UPDT_SET(rrd, val)		BITS_SET((rrd)->word[3], 31, 31, val)
+/* timestamp low */
+#define RRD_TS_LOW(rrd)			BITS_GET((rrd)->word[4], 0, 29)
+/* timestamp high */
+#define RRD_TS_HI(rrd)			((rrd)->word[5])
+};
+
+/* TPD (Transmit Packet Descriptor) */
+struct emac_tpd {
+	u32				word[4];
+
+/* Number of bytes of the transmit packet. (include 4-byte CRC) */
+#define TPD_BUF_LEN_SET(tpd, val)	BITS_SET((tpd)->word[0], 0, 15, val)
+/* Custom Checksum Offload: When set, ask IP core to offload custom checksum */
+#define TPD_CSX_SET(tpd, val)		BITS_SET((tpd)->word[1], 8, 8, val)
+/* TCP Large Send Offload: When set, ask IP core to do offload TCP Large Send */
+#define TPD_LSO(tpd)			BITS_GET((tpd)->word[1], 12, 12)
+#define TPD_LSO_SET(tpd, val)		BITS_SET((tpd)->word[1], 12, 12, val)
+/*  Large Send Offload Version: When set, indicates this is an LSOv2
+ * (for both IPv4 and IPv6). When cleared, indicates this is an LSOv1
+ * (only for IPv4).
+ */
+#define TPD_LSOV_SET(tpd, val)		BITS_SET((tpd)->word[1], 13, 13, val)
+/* IPv4 packet: When set, indicates this is an  IPv4 packet, this bit is only
+ * for LSOV2 format.
+ */
+#define TPD_IPV4_SET(tpd, val)		BITS_SET((tpd)->word[1], 16, 16, val)
+/* 0: Ethernet   frame (DA+SA+TYPE+DATA+CRC)
+ * 1: IEEE 802.3 frame (DA+SA+LEN+DSAP+SSAP+CTL+ORG+TYPE+DATA+CRC)
+ */
+#define TPD_TYP_SET(tpd, val)		BITS_SET((tpd)->word[1], 17, 17, val)
+/* Low-32bit Buffer Address */
+#define TPD_BUFFER_ADDR_L_SET(tpd, val)	((tpd)->word[2] = (val))
+/* CVLAN Tag to be inserted if INS_VLAN_TAG is set, CVLAN TPID based on global
+ * register configuration.
+ */
+#define TPD_CVLAN_TAG_SET(tpd, val)	BITS_SET((tpd)->word[3], 0, 15, val)
+/*  Insert CVlan Tag: When set, ask MAC to insert CVLAN TAG to outgoing packet
+ */
+#define TPD_INSTC_SET(tpd, val)		BITS_SET((tpd)->word[3], 17, 17, val)
+/* High-14bit Buffer Address, So, the 64b-bit address is
+ * {DESC_CTRL_11_TX_DATA_HIADDR[17:0],(register) BUFFER_ADDR_H, BUFFER_ADDR_L}
+ */
+#define TPD_BUFFER_ADDR_H_SET(tpd, val)	BITS_SET((tpd)->word[3], 18, 30, val)
+/* Format D. Word offset from the 1st byte of this packet to start to calculate
+ * the custom checksum.
+ */
+#define TPD_PAYLOAD_OFFSET_SET(tpd, val) BITS_SET((tpd)->word[1], 0, 7, val)
+/*  Format D. Word offset from the 1st byte of this packet to fill the custom
+ * checksum to
+ */
+#define TPD_CXSUM_OFFSET_SET(tpd, val)	BITS_SET((tpd)->word[1], 18, 25, val)
+
+/* Format C. TCP Header offset from the 1st byte of this packet. (byte unit) */
+#define TPD_TCPHDR_OFFSET_SET(tpd, val)	BITS_SET((tpd)->word[1], 0, 7, val)
+/* Format C. MSS (Maximum Segment Size) got from the protocol layer. (byte unit)
+ */
+#define TPD_MSS_SET(tpd, val)		BITS_SET((tpd)->word[1], 18, 30, val)
+/* packet length in ext tpd */
+#define TPD_PKT_LEN_SET(tpd, val)	((tpd)->word[2] = (val))
+};
+
+/* emac_ring_header represents a single, contiguous block of DMA space
+ * mapped for the three descriptor rings (tpd, rfd, rrd)
+ */
+struct emac_ring_header {
+	void			*v_addr;	/* virtual address */
+	dma_addr_t		dma_addr;	/* dma address */
+	size_t			size;		/* length in bytes */
+	size_t			used;
+};
+
+/* emac_buffer is wrapper around a pointer to a socket buffer
+ * so a DMA handle can be stored along with the skb
+ */
+struct emac_buffer {
+	struct sk_buff		*skb;		/* socket buffer */
+	u16			length;		/* rx buffer length */
+	dma_addr_t		dma_addr;	/* dma address */
+};
+
+/* receive free descriptor (rfd) ring */
+struct emac_rfd_ring {
+	struct emac_buffer	*rfbuff;
+	u32 __iomem		*v_addr;	/* virtual address */
+	dma_addr_t		dma_addr;	/* dma address */
+	u64			size;		/* length in bytes */
+	u32			count;		/* number of desc in the ring */
+	u32			produce_idx;
+	u32			process_idx;
+	u32			consume_idx;	/* unused */
+};
+
+/* Receive Return Desciptor (RRD) ring */
+struct emac_rrd_ring {
+	u32 __iomem		*v_addr;	/* virtual address */
+	dma_addr_t		dma_addr;	/* physical address */
+	u64			size;		/* length in bytes */
+	u32			count;		/* number of desc in the ring */
+	u32			produce_idx;	/* unused */
+	u32			consume_idx;
+};
+
+/* Rx queue */
+struct emac_rx_queue {
+	struct net_device	*netdev;	/* netdev ring belongs to */
+	struct emac_rrd_ring	rrd;
+	struct emac_rfd_ring	rfd;
+	struct napi_struct	napi;
+	struct emac_irq		*irq;
+
+	u32			intr;
+	u32			produce_mask;
+	u32			process_mask;
+	u32			consume_mask;
+
+	u16			produce_reg;
+	u16			process_reg;
+	u16			consume_reg;
+
+	u8			produce_shift;
+	u8			process_shft;
+	u8			consume_shift;
+};
+
+/* Transimit Packet Descriptor (tpd) ring */
+struct emac_tpd_ring {
+	struct emac_buffer	*tpbuff;
+	u32 __iomem		*v_addr;	/* virtual address */
+	dma_addr_t		dma_addr;	/* dma address */
+
+	u64			size;		/* length in bytes */
+	u32			count;		/* number of desc in the ring */
+	u32			produce_idx;
+	u32			consume_idx;
+	u32			last_produce_idx;
+};
+
+/* Tx queue */
+struct emac_tx_queue {
+	struct emac_tpd_ring	tpd;
+
+	u32			produce_mask;
+	u32			consume_mask;
+
+	u16			max_packets;	/* max packets per interrupt */
+	u16			produce_reg;
+	u16			consume_reg;
+
+	u8			produce_shift;
+	u8			consume_shift;
+};
+
+/* HW tx timestamp */
+struct emac_tx_ts {
+	u32			ts_idx;
+	u32			sec;
+	u32			ns;
+};
+
+/* Tx timestamp statistics */
+struct emac_tx_ts_stats {
+	u32			tx;
+	u32			rx;
+	u32			deliver;
+	u32			drop;
+	u32			lost;
+	u32			timeout;
+	u32			sched;
+	u32			poll;
+	u32			tx_poll;
+};
+
+struct emac_adapter;
+
+int  emac_mac_up(struct emac_adapter *adpt);
+void emac_mac_down(struct emac_adapter *adpt, bool reset);
+void emac_mac_reset(struct emac_adapter *adpt);
+void emac_mac_start(struct emac_adapter *adpt);
+void emac_mac_stop(struct emac_adapter *adpt);
+void emac_mac_mode_config(struct emac_adapter *adpt);
+void emac_mac_rx_process(struct emac_adapter *adpt, struct emac_rx_queue *rx_q,
+			 int *num_pkts, int max_pkts);
+int emac_mac_tx_buf_send(struct emac_adapter *adpt, struct emac_tx_queue *tx_q,
+			 struct sk_buff *skb);
+void emac_mac_tx_process(struct emac_adapter *adpt, struct emac_tx_queue *tx_q);
+void emac_mac_rx_tx_ring_init_all(struct platform_device *pdev,
+				  struct emac_adapter *adpt);
+int  emac_mac_rx_tx_rings_alloc_all(struct emac_adapter *adpt);
+void emac_mac_rx_tx_rings_free_all(struct emac_adapter *adpt);
+void emac_mac_tx_ts_periodic_routine(struct work_struct *work);
+void emac_mac_multicast_addr_clear(struct emac_adapter *adpt);
+void emac_mac_multicast_addr_set(struct emac_adapter *adpt, u8 *addr);
+
+#endif /*_EMAC_HW_H_*/
diff --git a/drivers/net/ethernet/qualcomm/emac/emac-phy.c b/drivers/net/ethernet/qualcomm/emac/emac-phy.c
new file mode 100644
index 0000000..377909f
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/emac/emac-phy.c
@@ -0,0 +1,211 @@
+/* Copyright (c) 2013-2016, The Linux Foundation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 and
+ * only version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+/* Qualcomm Technologies, Inc. EMAC PHY Controller driver.
+ */
+
+#include <linux/module.h>
+#include <linux/of.h>
+#include <linux/of_net.h>
+#include <linux/of_mdio.h>
+#include <linux/phy.h>
+#include <linux/iopoll.h>
+#include "emac.h"
+#include "emac-mac.h"
+#include "emac-phy.h"
+#include "emac-sgmii.h"
+
+/* EMAC base register offsets */
+#define EMAC_MDIO_CTRL                                        0x001414
+#define EMAC_PHY_STS                                          0x001418
+#define EMAC_MDIO_EX_CTRL                                     0x001440
+
+/* EMAC_MDIO_CTRL */
+#define MDIO_MODE                                              BIT(30)
+#define MDIO_PR                                                BIT(29)
+#define MDIO_AP_EN                                             BIT(28)
+#define MDIO_BUSY                                              BIT(27)
+#define MDIO_CLK_SEL_BMSK                                    0x7000000
+#define MDIO_CLK_SEL_SHFT                                           24
+#define MDIO_START                                             BIT(23)
+#define SUP_PREAMBLE                                           BIT(22)
+#define MDIO_RD_NWR                                            BIT(21)
+#define MDIO_REG_ADDR_BMSK                                    0x1f0000
+#define MDIO_REG_ADDR_SHFT                                          16
+#define MDIO_DATA_BMSK                                          0xffff
+#define MDIO_DATA_SHFT                                               0
+
+/* EMAC_PHY_STS */
+#define PHY_ADDR_BMSK                                         0x1f0000
+#define PHY_ADDR_SHFT                                               16
+
+#define MDIO_CLK_25_4                                                0
+#define MDIO_CLK_25_28                                               7
+
+#define MDIO_WAIT_TIMES                                           1000
+
+#define EMAC_LINK_SPEED_DEFAULT (\
+		EMAC_LINK_SPEED_10_HALF  |\
+		EMAC_LINK_SPEED_10_FULL  |\
+		EMAC_LINK_SPEED_100_HALF |\
+		EMAC_LINK_SPEED_100_FULL |\
+		EMAC_LINK_SPEED_1GB_FULL)
+
+/**
+ * emac_phy_mdio_autopoll_disable() - disable mdio autopoll
+ * @adpt: the emac adapter
+ *
+ * The autopoll feature takes over the MDIO bus.  In order for
+ * the PHY driver to be able to talk to the PHY over the MDIO
+ * bus, we need to temporarily disable the autopoll feature.
+ */
+static int emac_phy_mdio_autopoll_disable(struct emac_adapter *adpt)
+{
+	u32 val;
+
+	/* disable autopoll */
+	emac_reg_update32(adpt->base + EMAC_MDIO_CTRL, MDIO_AP_EN, 0);
+
+	/* wait for any mdio polling to complete */
+	if (!readl_poll_timeout(adpt->base + EMAC_MDIO_CTRL, val,
+				!(val & MDIO_BUSY), 100, MDIO_WAIT_TIMES * 100))
+		return 0;
+
+	/* failed to disable; ensure it is enabled before returning */
+	emac_reg_update32(adpt->base + EMAC_MDIO_CTRL, 0, MDIO_AP_EN);
+
+	return -EBUSY;
+}
+
+/**
+ * emac_phy_mdio_autopoll_disable() - disable mdio autopoll
+ * @adpt: the emac adapter
+ *
+ * The EMAC has the ability to poll the external PHY on the MDIO
+ * bus for link state changes.  This eliminates the need for the
+ * driver to poll the phy.  If if the link state does change,
+ * the EMAC issues an interrupt on behalf of the PHY.
+ */
+static void emac_phy_mdio_autopoll_enable(struct emac_adapter *adpt)
+{
+	emac_reg_update32(adpt->base + EMAC_MDIO_CTRL, 0, MDIO_AP_EN);
+}
+
+static int emac_mdio_read(struct mii_bus *bus, int addr, int regnum)
+{
+	struct emac_adapter *adpt = bus->priv;
+	u32 reg;
+	int ret;
+
+	ret = emac_phy_mdio_autopoll_disable(adpt);
+	if (ret)
+		return ret;
+
+	emac_reg_update32(adpt->base + EMAC_PHY_STS, PHY_ADDR_BMSK,
+			  (addr << PHY_ADDR_SHFT));
+
+	reg = SUP_PREAMBLE |
+	      ((MDIO_CLK_25_4 << MDIO_CLK_SEL_SHFT) & MDIO_CLK_SEL_BMSK) |
+	      ((regnum << MDIO_REG_ADDR_SHFT) & MDIO_REG_ADDR_BMSK) |
+	      MDIO_START | MDIO_RD_NWR;
+
+	writel(reg, adpt->base + EMAC_MDIO_CTRL);
+
+	if (readl_poll_timeout(adpt->base + EMAC_MDIO_CTRL, reg,
+			       !(reg & (MDIO_START | MDIO_BUSY)),
+			       100, MDIO_WAIT_TIMES * 100))
+		ret = -EIO;
+	else
+		ret = (reg >> MDIO_DATA_SHFT) & MDIO_DATA_BMSK;
+
+	emac_phy_mdio_autopoll_enable(adpt);
+
+	return ret;
+}
+
+static int emac_mdio_write(struct mii_bus *bus, int addr, int regnum, u16 val)
+{
+	struct emac_adapter *adpt = bus->priv;
+	u32 reg;
+	int ret;
+
+	ret = emac_phy_mdio_autopoll_disable(adpt);
+	if (ret)
+		return ret;
+
+	emac_reg_update32(adpt->base + EMAC_PHY_STS, PHY_ADDR_BMSK,
+			  (addr << PHY_ADDR_SHFT));
+
+	reg = SUP_PREAMBLE |
+		((MDIO_CLK_25_4 << MDIO_CLK_SEL_SHFT) & MDIO_CLK_SEL_BMSK) |
+		((regnum << MDIO_REG_ADDR_SHFT) & MDIO_REG_ADDR_BMSK) |
+		((val << MDIO_DATA_SHFT) & MDIO_DATA_BMSK) |
+		MDIO_START;
+
+	writel(reg, adpt->base + EMAC_MDIO_CTRL);
+
+	if (readl_poll_timeout(adpt->base + EMAC_MDIO_CTRL, reg,
+			       !(reg & (MDIO_START | MDIO_BUSY)), 100,
+			       MDIO_WAIT_TIMES * 100))
+		ret = -EIO;
+
+	emac_phy_mdio_autopoll_enable(adpt);
+
+	return ret;
+}
+
+/* Read phy configuration and initialize it */
+int emac_phy_config(struct platform_device *pdev, struct emac_adapter *adpt)
+{
+	struct device_node *np = pdev->dev.of_node;
+	struct emac_phy *phy = &adpt->phy;
+	struct mii_bus *mii_bus;
+	int ret;
+
+	/* Create the mii_bus object for talking to the MDIO bus */
+	adpt->mii_bus = mii_bus = devm_mdiobus_alloc(&pdev->dev);
+	if (!mii_bus)
+		return -ENOMEM;
+
+	mii_bus->name = "emac-mdio";
+	snprintf(mii_bus->id, MII_BUS_ID_SIZE, "%s", pdev->name);
+	mii_bus->read = emac_mdio_read;
+	mii_bus->write = emac_mdio_write;
+	mii_bus->parent = &pdev->dev;
+	mii_bus->priv = adpt;
+
+	ret = of_mdiobus_register(mii_bus, np);
+	if (ret) {
+		dev_err(&pdev->dev, "could not register mdio bus\n");
+		return ret;
+	}
+	adpt->phydev = of_phy_find_device(np);
+
+	if (!adpt->phydev) {
+		dev_err(&pdev->dev, "could not find phy device\n");
+		mdiobus_unregister(mii_bus);
+		return ret;
+	}
+
+	phy_attached_print(adpt->phydev, NULL);
+
+	ret = emac_sgmii_config(pdev, adpt);
+	if (ret)
+		return ret;
+
+	if (phy->version == 2)
+		return emac_sgmii_init_v2(adpt);
+	else
+		return emac_sgmii_init_v1(adpt);
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/qualcomm/emac/emac-phy.h b/drivers/net/ethernet/qualcomm/emac/emac-phy.h
new file mode 100644
index 0000000..03e2b74
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/emac/emac-phy.h
@@ -0,0 +1,32 @@
+/* Copyright (c) 2015, The Linux Foundation. All rights reserved.
+*
+* This program is free software; you can redistribute it and/or modify
+* it under the terms of the GNU General Public License version 2 and
+* only version 2 as published by the Free Software Foundation.
+*
+* This program is distributed in the hope that it will be useful,
+* but WITHOUT ANY WARRANTY; without even the implied warranty of
+* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+* GNU General Public License for more details.
+*/
+
+#ifndef _EMAC_PHY_H_
+#define _EMAC_PHY_H_
+
+/* emac_phy
+ * @base register file base address space.
+ * @digital per-lane digital block
+ * @version the internal phy version
+ */
+struct emac_phy {
+	void __iomem			*base;
+	void __iomem			*digital;
+
+	unsigned int			version;
+};
+
+struct emac_adapter;
+
+int emac_phy_config(struct platform_device *pdev, struct emac_adapter *adpt);
+
+#endif /* _EMAC_PHY_H_ */
diff --git a/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
new file mode 100644
index 0000000..f38d8d5
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
@@ -0,0 +1,700 @@
+/* Copyright (c) 2015, The Linux Foundation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 and
+ * only version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+/* Qualcomm Technologies, Inc. EMAC SGMII Controller driver.
+ */
+
+#include <linux/iopoll.h>
+#include "emac.h"
+#include "emac-mac.h"
+#include "emac-sgmii.h"
+
+/* EMAC_QSERDES register offsets */
+#define EMAC_QSERDES_COM_SYS_CLK_CTRL		0x000000
+#define EMAC_QSERDES_COM_PLL_CNTRL		0x000014
+#define EMAC_QSERDES_COM_PLL_IP_SETI		0x000018
+#define EMAC_QSERDES_COM_PLL_CP_SETI		0x000024
+#define EMAC_QSERDES_COM_PLL_IP_SETP		0x000028
+#define EMAC_QSERDES_COM_PLL_CP_SETP		0x00002c
+#define EMAC_QSERDES_COM_SYSCLK_EN_SEL		0x000038
+#define EMAC_QSERDES_COM_RESETSM_CNTRL		0x000040
+#define EMAC_QSERDES_COM_PLLLOCK_CMP1		0x000044
+#define EMAC_QSERDES_COM_PLLLOCK_CMP2		0x000048
+#define EMAC_QSERDES_COM_PLLLOCK_CMP3		0x00004c
+#define EMAC_QSERDES_COM_PLLLOCK_CMP_EN		0x000050
+#define EMAC_QSERDES_COM_DEC_START1		0x000064
+#define EMAC_QSERDES_COM_DIV_FRAC_START1	0x000098
+#define EMAC_QSERDES_COM_DIV_FRAC_START2	0x00009c
+#define EMAC_QSERDES_COM_DIV_FRAC_START3	0x0000a0
+#define EMAC_QSERDES_COM_DEC_START2		0x0000a4
+#define EMAC_QSERDES_COM_PLL_CRCTRL		0x0000ac
+#define EMAC_QSERDES_COM_RESET_SM		0x0000bc
+#define EMAC_QSERDES_TX_BIST_MODE_LANENO	0x000100
+#define EMAC_QSERDES_TX_TX_EMP_POST1_LVL	0x000108
+#define EMAC_QSERDES_TX_TX_DRV_LVL		0x00010c
+#define EMAC_QSERDES_TX_LANE_MODE		0x000150
+#define EMAC_QSERDES_TX_TRAN_DRVR_EMP_EN	0x000170
+#define EMAC_QSERDES_RX_CDR_CONTROL		0x000200
+#define EMAC_QSERDES_RX_CDR_CONTROL2		0x000210
+#define EMAC_QSERDES_RX_RX_EQ_GAIN12		0x000230
+
+/* EMAC_SGMII register offsets */
+#define EMAC_SGMII_PHY_SERDES_START		0x000000
+#define EMAC_SGMII_PHY_CMN_PWR_CTRL		0x000004
+#define EMAC_SGMII_PHY_RX_PWR_CTRL		0x000008
+#define EMAC_SGMII_PHY_TX_PWR_CTRL		0x00000C
+#define EMAC_SGMII_PHY_LANE_CTRL1		0x000018
+#define EMAC_SGMII_PHY_AUTONEG_CFG2		0x000048
+#define EMAC_SGMII_PHY_CDR_CTRL0		0x000058
+#define EMAC_SGMII_PHY_SPEED_CFG1		0x000074
+#define EMAC_SGMII_PHY_POW_DWN_CTRL0		0x000080
+#define EMAC_SGMII_PHY_RESET_CTRL		0x0000a8
+#define EMAC_SGMII_PHY_IRQ_CMD			0x0000ac
+#define EMAC_SGMII_PHY_INTERRUPT_CLEAR		0x0000b0
+#define EMAC_SGMII_PHY_INTERRUPT_MASK		0x0000b4
+#define EMAC_SGMII_PHY_INTERRUPT_STATUS		0x0000b8
+#define EMAC_SGMII_PHY_RX_CHK_STATUS		0x0000d4
+#define EMAC_SGMII_PHY_AUTONEG0_STATUS		0x0000e0
+#define EMAC_SGMII_PHY_AUTONEG1_STATUS		0x0000e4
+
+/* EMAC_QSERDES_COM_PLL_IP_SETI */
+#define PLL_IPSETI(x)				((x) & 0x3f)
+
+/* EMAC_QSERDES_COM_PLL_CP_SETI */
+#define PLL_CPSETI(x)				((x) & 0xff)
+
+/* EMAC_QSERDES_COM_PLL_IP_SETP */
+#define PLL_IPSETP(x)				((x) & 0x3f)
+
+/* EMAC_QSERDES_COM_PLL_CP_SETP */
+#define PLL_CPSETP(x)				((x) & 0x1f)
+
+/* EMAC_QSERDES_COM_PLL_CRCTRL */
+#define PLL_RCTRL(x)				(((x) & 0xf) << 4)
+#define PLL_CCTRL(x)				((x) & 0xf)
+
+/* SGMII v2 PHY registers per lane */
+#define EMAC_SGMII_PHY_LN_OFFSET		0x0400
+
+/* SGMII v2 digital lane registers */
+#define EMAC_SGMII_LN_DRVR_CTRL0		0x00C
+#define EMAC_SGMII_LN_DRVR_TAP_EN		0x018
+#define EMAC_SGMII_LN_TX_MARGINING		0x01C
+#define EMAC_SGMII_LN_TX_PRE			0x020
+#define EMAC_SGMII_LN_TX_POST			0x024
+#define EMAC_SGMII_LN_TX_BAND_MODE		0x060
+#define EMAC_SGMII_LN_LANE_MODE			0x064
+#define EMAC_SGMII_LN_PARALLEL_RATE		0x078
+#define EMAC_SGMII_LN_CML_CTRL_MODE0		0x0B8
+#define EMAC_SGMII_LN_MIXER_CTRL_MODE0		0x0D0
+#define EMAC_SGMII_LN_VGA_INITVAL		0x134
+#define EMAC_SGMII_LN_UCDR_FO_GAIN_MODE0	0x17C
+#define EMAC_SGMII_LN_UCDR_SO_GAIN_MODE0	0x188
+#define EMAC_SGMII_LN_UCDR_SO_CONFIG		0x194
+#define EMAC_SGMII_LN_RX_BAND			0x19C
+#define EMAC_SGMII_LN_RX_RCVR_PATH1_MODE0	0x1B8
+#define EMAC_SGMII_LN_RSM_CONFIG		0x1F0
+#define EMAC_SGMII_LN_SIGDET_ENABLES		0x224
+#define EMAC_SGMII_LN_SIGDET_CNTRL		0x228
+#define EMAC_SGMII_LN_SIGDET_DEGLITCH_CNTRL	0x22C
+#define EMAC_SGMII_LN_RX_EN_SIGNAL		0x2A0
+#define EMAC_SGMII_LN_RX_MISC_CNTRL0		0x2AC
+#define EMAC_SGMII_LN_DRVR_LOGIC_CLKDIV		0x2BC
+
+/* SGMII v2 digital lane register values */
+#define UCDR_STEP_BY_TWO_MODE0			BIT(7)
+#define UCDR_xO_GAIN_MODE(x)			((x) & 0x7f)
+#define UCDR_ENABLE				BIT(6)
+#define UCDR_SO_SATURATION(x)			((x) & 0x3f)
+#define SIGDET_LP_BYP_PS4			BIT(7)
+#define SIGDET_EN_PS0_TO_PS2			BIT(6)
+#define EN_ACCOUPLEVCM_SW_MUX			BIT(5)
+#define EN_ACCOUPLEVCM_SW			BIT(4)
+#define RX_SYNC_EN				BIT(3)
+#define RXTERM_HIGHZ_PS5			BIT(2)
+#define SIGDET_EN_PS3				BIT(1)
+#define EN_ACCOUPLE_VCM_PS3			BIT(0)
+#define UFS_MODE				BIT(5)
+#define TXVAL_VALID_INIT			BIT(4)
+#define TXVAL_VALID_MUX				BIT(3)
+#define TXVAL_VALID				BIT(2)
+#define USB3P1_MODE				BIT(1)
+#define KR_PCIGEN3_MODE				BIT(0)
+#define PRE_EN					BIT(3)
+#define POST_EN					BIT(2)
+#define MAIN_EN_MUX				BIT(1)
+#define MAIN_EN					BIT(0)
+#define TX_MARGINING_MUX			BIT(6)
+#define TX_MARGINING(x)				((x) & 0x3f)
+#define TX_PRE_MUX				BIT(6)
+#define TX_PRE(x)				((x) & 0x3f)
+#define TX_POST_MUX				BIT(6)
+#define TX_POST(x)				((x) & 0x3f)
+#define CML_GEAR_MODE(x)			(((x) & 7) << 3)
+#define CML2CMOS_IBOOST_MODE(x)			((x) & 7)
+#define MIXER_LOADB_MODE(x)			(((x) & 0xf) << 2)
+#define MIXER_DATARATE_MODE(x)			((x) & 3)
+#define VGA_THRESH_DFE(x)			((x) & 0x3f)
+#define SIGDET_LP_BYP_PS0_TO_PS2		BIT(5)
+#define SIGDET_LP_BYP_MUX			BIT(4)
+#define SIGDET_LP_BYP				BIT(3)
+#define SIGDET_EN_MUX				BIT(2)
+#define SIGDET_EN				BIT(1)
+#define SIGDET_FLT_BYP				BIT(0)
+#define SIGDET_LVL(x)				(((x) & 0xf) << 4)
+#define SIGDET_BW_CTRL(x)			((x) & 0xf)
+#define SIGDET_DEGLITCH_CTRL(x)			(((x) & 0xf) << 1)
+#define SIGDET_DEGLITCH_BYP			BIT(0)
+#define INVERT_PCS_RX_CLK			BIT(7)
+#define PWM_EN					BIT(6)
+#define RXBIAS_SEL(x)				(((x) & 0x3) << 4)
+#define EBDAC_SIGN				BIT(3)
+#define EDAC_SIGN				BIT(2)
+#define EN_AUXTAP1SIGN_INVERT			BIT(1)
+#define EN_DAC_CHOPPING				BIT(0)
+#define DRVR_LOGIC_CLK_EN			BIT(4)
+#define DRVR_LOGIC_CLK_DIV(x)			((x) & 0xf)
+#define PARALLEL_RATE_MODE2(x)			(((x) & 0x3) << 4)
+#define PARALLEL_RATE_MODE1(x)			(((x) & 0x3) << 2)
+#define PARALLEL_RATE_MODE0(x)			((x) & 0x3)
+#define BAND_MODE2(x)				(((x) & 0x3) << 4)
+#define BAND_MODE1(x)				(((x) & 0x3) << 2)
+#define BAND_MODE0(x)				((x) & 0x3)
+#define LANE_SYNC_MODE				BIT(5)
+#define LANE_MODE(x)				((x) & 0x1f)
+#define CDR_PD_SEL_MODE0(x)			(((x) & 0x3) << 5)
+#define EN_DLL_MODE0				BIT(4)
+#define EN_IQ_DCC_MODE0				BIT(3)
+#define EN_IQCAL_MODE0				BIT(2)
+#define EN_QPATH_MODE0				BIT(1)
+#define EN_EPATH_MODE0				BIT(0)
+#define FORCE_TSYNC_ACK				BIT(7)
+#define FORCE_CMN_ACK				BIT(6)
+#define FORCE_CMN_READY				BIT(5)
+#define EN_RCLK_DEGLITCH			BIT(4)
+#define BYPASS_RSM_CDR_RESET			BIT(3)
+#define BYPASS_RSM_TSYNC			BIT(2)
+#define BYPASS_RSM_SAMP_CAL			BIT(1)
+#define BYPASS_RSM_DLL_CAL			BIT(0)
+
+/* EMAC_QSERDES_COM_SYS_CLK_CTRL */
+#define SYSCLK_CM				BIT(4)
+#define SYSCLK_AC_COUPLE			BIT(3)
+
+/* EMAC_QSERDES_COM_PLL_CNTRL */
+#define OCP_EN					BIT(5)
+#define PLL_DIV_FFEN				BIT(2)
+#define PLL_DIV_ORD				BIT(1)
+
+/* EMAC_QSERDES_COM_SYSCLK_EN_SEL */
+#define SYSCLK_SEL_CMOS				BIT(3)
+
+/* EMAC_QSERDES_COM_RESETSM_CNTRL */
+#define FRQ_TUNE_MODE				BIT(4)
+
+/* EMAC_QSERDES_COM_PLLLOCK_CMP_EN */
+#define PLLLOCK_CMP_EN				BIT(0)
+
+/* EMAC_QSERDES_COM_DEC_START1 */
+#define DEC_START1_MUX				BIT(7)
+#define DEC_START1(x)				((x) & 0x7f)
+
+/* EMAC_QSERDES_COM_DIV_FRAC_START1 * EMAC_QSERDES_COM_DIV_FRAC_START2 */
+#define DIV_FRAC_START_MUX			BIT(7)
+#define DIV_FRAC_START(x)			((x) & 0x7f)
+
+/* EMAC_QSERDES_COM_DIV_FRAC_START3 */
+#define DIV_FRAC_START3_MUX			BIT(4)
+#define DIV_FRAC_START3(x)			((x) & 0xf)
+
+/* EMAC_QSERDES_COM_DEC_START2 */
+#define DEC_START2_MUX				BIT(1)
+#define DEC_START2				BIT(0)
+
+/* EMAC_QSERDES_COM_RESET_SM */
+#define READY					BIT(5)
+
+/* EMAC_QSERDES_TX_TX_EMP_POST1_LVL */
+#define TX_EMP_POST1_LVL_MUX			BIT(5)
+#define TX_EMP_POST1_LVL(x)			((x) & 0x1f)
+#define TX_EMP_POST1_LVL_BMSK			0x1f
+#define TX_EMP_POST1_LVL_SHFT			0
+
+/* EMAC_QSERDES_TX_TX_DRV_LVL */
+#define TX_DRV_LVL_MUX				BIT(4)
+#define TX_DRV_LVL(x)				((x) & 0xf)
+
+/* EMAC_QSERDES_TX_TRAN_DRVR_EMP_EN */
+#define EMP_EN_MUX				BIT(1)
+#define EMP_EN					BIT(0)
+
+/* EMAC_QSERDES_RX_CDR_CONTROL & EMAC_QSERDES_RX_CDR_CONTROL2 */
+#define HBW_PD_EN				BIT(7)
+#define SECONDORDERENABLE			BIT(6)
+#define FIRSTORDER_THRESH(x)			(((x) & 0x7) << 3)
+#define SECONDORDERGAIN(x)			((x) & 0x7)
+
+/* EMAC_QSERDES_RX_RX_EQ_GAIN12 */
+#define RX_EQ_GAIN2(x)				(((x) & 0xf) << 4)
+#define RX_EQ_GAIN1(x)				((x) & 0xf)
+
+/* EMAC_SGMII_PHY_SERDES_START */
+#define SERDES_START				BIT(0)
+
+/* EMAC_SGMII_PHY_CMN_PWR_CTRL */
+#define BIAS_EN					BIT(6)
+#define PLL_EN					BIT(5)
+#define SYSCLK_EN				BIT(4)
+#define CLKBUF_L_EN				BIT(3)
+#define PLL_TXCLK_EN				BIT(1)
+#define PLL_RXCLK_EN				BIT(0)
+
+/* EMAC_SGMII_PHY_RX_PWR_CTRL */
+#define L0_RX_SIGDET_EN				BIT(7)
+#define L0_RX_TERM_MODE(x)			(((x) & 3) << 4)
+#define L0_RX_I_EN				BIT(1)
+
+/* EMAC_SGMII_PHY_TX_PWR_CTRL */
+#define L0_TX_EN				BIT(5)
+#define L0_CLKBUF_EN				BIT(4)
+#define L0_TRAN_BIAS_EN				BIT(1)
+
+/* EMAC_SGMII_PHY_LANE_CTRL1 */
+#define L0_RX_EQUALIZE_ENABLE			BIT(6)
+#define L0_RESET_TSYNC_EN			BIT(4)
+#define L0_DRV_LVL(x)				((x) & 0xf)
+
+/* EMAC_SGMII_PHY_AUTONEG_CFG2 */
+#define FORCE_AN_TX_CFG				BIT(5)
+#define FORCE_AN_RX_CFG				BIT(4)
+#define AN_ENABLE				BIT(0)
+
+/* EMAC_SGMII_PHY_SPEED_CFG1 */
+#define DUPLEX_MODE				BIT(4)
+#define SPDMODE_1000				BIT(1)
+#define SPDMODE_100				BIT(0)
+#define SPDMODE_10				0
+#define SPDMODE_BMSK				3
+#define SPDMODE_SHFT				0
+
+/* EMAC_SGMII_PHY_POW_DWN_CTRL0 */
+#define PWRDN_B					BIT(0)
+#define CDR_MAX_CNT(x)				((x) & 0xff)
+
+/* EMAC_QSERDES_TX_BIST_MODE_LANENO */
+#define BIST_LANE_NUMBER(x)			(((x) & 3) << 5)
+#define BISTMODE(x)				((x) & 0x1f)
+
+/* EMAC_QSERDES_COM_PLLLOCK_CMPx */
+#define PLLLOCK_CMP(x)				((x) & 0xff)
+
+/* EMAC_SGMII_PHY_RESET_CTRL */
+#define PHY_SW_RESET				BIT(0)
+
+/* EMAC_SGMII_PHY_IRQ_CMD */
+#define IRQ_GLOBAL_CLEAR			BIT(0)
+
+/* EMAC_SGMII_PHY_INTERRUPT_MASK */
+#define DECODE_CODE_ERR				BIT(7)
+#define DECODE_DISP_ERR				BIT(6)
+#define PLL_UNLOCK				BIT(5)
+#define AN_ILLEGAL_TERM				BIT(4)
+#define SYNC_FAIL				BIT(3)
+#define AN_START				BIT(2)
+#define AN_END					BIT(1)
+#define AN_REQUEST				BIT(0)
+
+#define SGMII_PHY_IRQ_CLR_WAIT_TIME		10
+
+#define SGMII_PHY_INTERRUPT_ERR (\
+	DECODE_CODE_ERR         |\
+	DECODE_DISP_ERR)
+
+#define SGMII_ISR_AN_MASK       (\
+	AN_REQUEST              |\
+	AN_START                |\
+	AN_END                  |\
+	AN_ILLEGAL_TERM         |\
+	PLL_UNLOCK              |\
+	SYNC_FAIL)
+
+#define SGMII_ISR_MASK          (\
+	SGMII_PHY_INTERRUPT_ERR |\
+	SGMII_ISR_AN_MASK)
+
+/* SGMII TX_CONFIG */
+#define TXCFG_LINK					      0x8000
+#define TXCFG_MODE_BMSK					      0x1c00
+#define TXCFG_1000_FULL					      0x1800
+#define TXCFG_100_FULL					      0x1400
+#define TXCFG_100_HALF					      0x0400
+#define TXCFG_10_FULL					      0x1000
+#define TXCFG_10_HALF					      0x0000
+
+#define SERDES_START_WAIT_TIMES					 100
+
+#define SGMII_MEM_RES                                         "sgmii"
+#define SGMII_IRQ_RES                                     "sgmii_irq"
+
+struct emac_reg_write {
+	unsigned int offset;
+	u32 val;
+};
+
+static void emac_reg_write_all(void __iomem *base,
+			       const struct emac_reg_write *itr, size_t size)
+{
+	size_t i;
+
+	for (i = 0; i < size; ++itr, ++i)
+		writel(itr->val, base + itr->offset);
+}
+
+static const struct emac_reg_write physical_coding_sublayer_programming_v1[] = {
+	{EMAC_SGMII_PHY_CDR_CTRL0, CDR_MAX_CNT(15)},
+	{EMAC_SGMII_PHY_POW_DWN_CTRL0, PWRDN_B},
+	{EMAC_SGMII_PHY_CMN_PWR_CTRL,
+		BIAS_EN | SYSCLK_EN | CLKBUF_L_EN | PLL_TXCLK_EN | PLL_RXCLK_EN},
+	{EMAC_SGMII_PHY_TX_PWR_CTRL, L0_TX_EN | L0_CLKBUF_EN | L0_TRAN_BIAS_EN},
+	{EMAC_SGMII_PHY_RX_PWR_CTRL,
+		L0_RX_SIGDET_EN | L0_RX_TERM_MODE(1) | L0_RX_I_EN},
+	{EMAC_SGMII_PHY_CMN_PWR_CTRL,
+		BIAS_EN | PLL_EN | SYSCLK_EN | CLKBUF_L_EN | PLL_TXCLK_EN |
+		PLL_RXCLK_EN},
+	{EMAC_SGMII_PHY_LANE_CTRL1,
+		L0_RX_EQUALIZE_ENABLE | L0_RESET_TSYNC_EN | L0_DRV_LVL(15)},
+};
+
+static const struct emac_reg_write sysclk_refclk_setting[] = {
+	{EMAC_QSERDES_COM_SYSCLK_EN_SEL, SYSCLK_SEL_CMOS},
+	{EMAC_QSERDES_COM_SYS_CLK_CTRL,	SYSCLK_CM | SYSCLK_AC_COUPLE},
+};
+
+static const struct emac_reg_write pll_setting[] = {
+	{EMAC_QSERDES_COM_PLL_IP_SETI, PLL_IPSETI(1)},
+	{EMAC_QSERDES_COM_PLL_CP_SETI, PLL_CPSETI(59)},
+	{EMAC_QSERDES_COM_PLL_IP_SETP, PLL_IPSETP(10)},
+	{EMAC_QSERDES_COM_PLL_CP_SETP, PLL_CPSETP(9)},
+	{EMAC_QSERDES_COM_PLL_CRCTRL, PLL_RCTRL(15) | PLL_CCTRL(11)},
+	{EMAC_QSERDES_COM_PLL_CNTRL, OCP_EN | PLL_DIV_FFEN | PLL_DIV_ORD},
+	{EMAC_QSERDES_COM_DEC_START1, DEC_START1_MUX | DEC_START1(2)},
+	{EMAC_QSERDES_COM_DEC_START2, DEC_START2_MUX | DEC_START2},
+	{EMAC_QSERDES_COM_DIV_FRAC_START1,
+		DIV_FRAC_START_MUX | DIV_FRAC_START(85)},
+	{EMAC_QSERDES_COM_DIV_FRAC_START2,
+		DIV_FRAC_START_MUX | DIV_FRAC_START(42)},
+	{EMAC_QSERDES_COM_DIV_FRAC_START3,
+		DIV_FRAC_START3_MUX | DIV_FRAC_START3(3)},
+	{EMAC_QSERDES_COM_PLLLOCK_CMP1, PLLLOCK_CMP(43)},
+	{EMAC_QSERDES_COM_PLLLOCK_CMP2, PLLLOCK_CMP(104)},
+	{EMAC_QSERDES_COM_PLLLOCK_CMP3, PLLLOCK_CMP(0)},
+	{EMAC_QSERDES_COM_PLLLOCK_CMP_EN, PLLLOCK_CMP_EN},
+	{EMAC_QSERDES_COM_RESETSM_CNTRL, FRQ_TUNE_MODE},
+};
+
+static const struct emac_reg_write cdr_setting[] = {
+	{EMAC_QSERDES_RX_CDR_CONTROL,
+		SECONDORDERENABLE | FIRSTORDER_THRESH(3) | SECONDORDERGAIN(2)},
+	{EMAC_QSERDES_RX_CDR_CONTROL2,
+		SECONDORDERENABLE | FIRSTORDER_THRESH(3) | SECONDORDERGAIN(4)},
+};
+
+static const struct emac_reg_write tx_rx_setting[] = {
+	{EMAC_QSERDES_TX_BIST_MODE_LANENO, 0},
+	{EMAC_QSERDES_TX_TX_DRV_LVL, TX_DRV_LVL_MUX | TX_DRV_LVL(15)},
+	{EMAC_QSERDES_TX_TRAN_DRVR_EMP_EN, EMP_EN_MUX | EMP_EN},
+	{EMAC_QSERDES_TX_TX_EMP_POST1_LVL,
+		TX_EMP_POST1_LVL_MUX | TX_EMP_POST1_LVL(1)},
+	{EMAC_QSERDES_RX_RX_EQ_GAIN12, RX_EQ_GAIN2(15) | RX_EQ_GAIN1(15)},
+	{EMAC_QSERDES_TX_LANE_MODE, LANE_MODE(8)},
+};
+
+static const struct emac_reg_write sgmii_v2_laned[] = {
+	/* CDR Settings */
+	{EMAC_SGMII_LN_UCDR_FO_GAIN_MODE0,
+		UCDR_STEP_BY_TWO_MODE0 | UCDR_xO_GAIN_MODE(10)},
+	{EMAC_SGMII_LN_UCDR_SO_GAIN_MODE0, UCDR_xO_GAIN_MODE(6)},
+	{EMAC_SGMII_LN_UCDR_SO_CONFIG, UCDR_ENABLE | UCDR_SO_SATURATION(12)},
+
+	/* TX/RX Settings */
+	{EMAC_SGMII_LN_RX_EN_SIGNAL, SIGDET_LP_BYP_PS4 | SIGDET_EN_PS0_TO_PS2},
+
+	{EMAC_SGMII_LN_DRVR_CTRL0, TXVAL_VALID_INIT | KR_PCIGEN3_MODE},
+	{EMAC_SGMII_LN_DRVR_TAP_EN, MAIN_EN},
+	{EMAC_SGMII_LN_TX_MARGINING, TX_MARGINING_MUX | TX_MARGINING(25)},
+	{EMAC_SGMII_LN_TX_PRE, TX_PRE_MUX},
+	{EMAC_SGMII_LN_TX_POST, TX_POST_MUX},
+
+	{EMAC_SGMII_LN_CML_CTRL_MODE0,
+		CML_GEAR_MODE(1) | CML2CMOS_IBOOST_MODE(1)},
+	{EMAC_SGMII_LN_MIXER_CTRL_MODE0,
+		MIXER_LOADB_MODE(12) | MIXER_DATARATE_MODE(1)},
+	{EMAC_SGMII_LN_VGA_INITVAL, VGA_THRESH_DFE(31)},
+	{EMAC_SGMII_LN_SIGDET_ENABLES,
+		SIGDET_LP_BYP_PS0_TO_PS2 | SIGDET_FLT_BYP},
+	{EMAC_SGMII_LN_SIGDET_CNTRL, SIGDET_LVL(8)},
+
+	{EMAC_SGMII_LN_SIGDET_DEGLITCH_CNTRL, SIGDET_DEGLITCH_CTRL(4)},
+	{EMAC_SGMII_LN_RX_MISC_CNTRL0, 0},
+	{EMAC_SGMII_LN_DRVR_LOGIC_CLKDIV,
+		DRVR_LOGIC_CLK_EN | DRVR_LOGIC_CLK_DIV(4)},
+
+	{EMAC_SGMII_LN_PARALLEL_RATE, PARALLEL_RATE_MODE0(1)},
+	{EMAC_SGMII_LN_TX_BAND_MODE, BAND_MODE0(2)},
+	{EMAC_SGMII_LN_RX_BAND, BAND_MODE0(3)},
+	{EMAC_SGMII_LN_LANE_MODE, LANE_MODE(26)},
+	{EMAC_SGMII_LN_RX_RCVR_PATH1_MODE0, CDR_PD_SEL_MODE0(3)},
+	{EMAC_SGMII_LN_RSM_CONFIG, BYPASS_RSM_SAMP_CAL | BYPASS_RSM_DLL_CAL},
+};
+
+static const struct emac_reg_write physical_coding_sublayer_programming_v2[] = {
+	{EMAC_SGMII_PHY_POW_DWN_CTRL0, PWRDN_B},
+	{EMAC_SGMII_PHY_CDR_CTRL0, CDR_MAX_CNT(15)},
+	{EMAC_SGMII_PHY_TX_PWR_CTRL, 0},
+	{EMAC_SGMII_PHY_LANE_CTRL1, L0_RX_EQUALIZE_ENABLE},
+};
+
+static int emac_sgmii_link_init(struct emac_adapter *adpt)
+{
+	struct phy_device *phydev = adpt->phydev;
+	struct emac_phy *phy = &adpt->phy;
+	u32 val;
+
+	val = readl(phy->base + EMAC_SGMII_PHY_AUTONEG_CFG2);
+
+	if (phydev->autoneg == AUTONEG_ENABLE) {
+		val &= ~(FORCE_AN_RX_CFG | FORCE_AN_TX_CFG);
+		val |= AN_ENABLE;
+		writel(val, phy->base + EMAC_SGMII_PHY_AUTONEG_CFG2);
+	} else {
+		u32 speed_cfg;
+
+		switch (phydev->speed) {
+		case SPEED_10:
+			speed_cfg = SPDMODE_10;
+			break;
+		case SPEED_100:
+			speed_cfg = SPDMODE_100;
+			break;
+		case SPEED_1000:
+			speed_cfg = SPDMODE_1000;
+			break;
+		default:
+			return -EINVAL;
+		}
+
+		if (phydev->duplex == DUPLEX_FULL)
+			speed_cfg |= DUPLEX_MODE;
+
+		val &= ~AN_ENABLE;
+		writel(speed_cfg, phy->base + EMAC_SGMII_PHY_SPEED_CFG1);
+		writel(val, phy->base + EMAC_SGMII_PHY_AUTONEG_CFG2);
+	}
+
+	return 0;
+}
+
+static int emac_sgmii_irq_clear(struct emac_adapter *adpt, u32 irq_bits)
+{
+	struct emac_phy *phy = &adpt->phy;
+	u32 status;
+
+	writel_relaxed(irq_bits, phy->base + EMAC_SGMII_PHY_INTERRUPT_CLEAR);
+	writel_relaxed(IRQ_GLOBAL_CLEAR, phy->base + EMAC_SGMII_PHY_IRQ_CMD);
+	/* Ensure interrupt clear command is written to HW */
+	wmb();
+
+	/* After set the IRQ_GLOBAL_CLEAR bit, the status clearing must
+	 * be confirmed before clearing the bits in other registers.
+	 * It takes a few cycles for hw to clear the interrupt status.
+	 */
+	if (readl_poll_timeout_atomic(phy->base +
+				      EMAC_SGMII_PHY_INTERRUPT_STATUS,
+				      status, !(status & irq_bits), 1,
+				      SGMII_PHY_IRQ_CLR_WAIT_TIME)) {
+		netdev_err(adpt->netdev,
+			   "error: failed clear SGMII irq: status:0x%x bits:0x%x\n",
+			   status, irq_bits);
+		return -EIO;
+	}
+
+	/* Finalize clearing procedure */
+	writel_relaxed(0, phy->base + EMAC_SGMII_PHY_IRQ_CMD);
+	writel_relaxed(0, phy->base + EMAC_SGMII_PHY_INTERRUPT_CLEAR);
+
+	/* Ensure that clearing procedure finalization is written to HW */
+	wmb();
+
+	return 0;
+}
+
+int emac_sgmii_init_v1(struct emac_adapter *adpt)
+{
+	struct emac_phy *phy = &adpt->phy;
+	unsigned int i;
+	int ret;
+
+	ret = emac_sgmii_link_init(adpt);
+	if (ret)
+		return ret;
+
+	emac_reg_write_all(phy->base, physical_coding_sublayer_programming_v1,
+			   ARRAY_SIZE(physical_coding_sublayer_programming_v1));
+	emac_reg_write_all(phy->base, sysclk_refclk_setting,
+			   ARRAY_SIZE(sysclk_refclk_setting));
+	emac_reg_write_all(phy->base, pll_setting, ARRAY_SIZE(pll_setting));
+	emac_reg_write_all(phy->base, cdr_setting, ARRAY_SIZE(cdr_setting));
+	emac_reg_write_all(phy->base, tx_rx_setting,
+			   ARRAY_SIZE(tx_rx_setting));
+
+	/* Power up the Ser/Des engine */
+	writel(SERDES_START, phy->base + EMAC_SGMII_PHY_SERDES_START);
+
+	for (i = 0; i < SERDES_START_WAIT_TIMES; i++) {
+		if (readl(phy->base + EMAC_QSERDES_COM_RESET_SM) & READY)
+			break;
+		usleep_range(100, 200);
+	}
+
+	if (i == SERDES_START_WAIT_TIMES) {
+		netdev_err(adpt->netdev, "error: ser/des failed to start\n");
+		return -EIO;
+	}
+	/* Mask out all the SGMII Interrupt */
+	writel(0, phy->base + EMAC_SGMII_PHY_INTERRUPT_MASK);
+
+	emac_sgmii_irq_clear(adpt, SGMII_PHY_INTERRUPT_ERR);
+
+	return 0;
+}
+
+int emac_sgmii_init_v2(struct emac_adapter *adpt)
+{
+	struct emac_phy *phy = &adpt->phy;
+	void __iomem *phy_regs = phy->base;
+	void __iomem *laned = phy->digital;
+	unsigned int i;
+	u32 lnstatus;
+	int ret;
+
+	ret = emac_sgmii_link_init(adpt);
+	if (ret)
+		return ret;
+
+	/* PCS lane-x init */
+	emac_reg_write_all(phy->base, physical_coding_sublayer_programming_v2,
+			   ARRAY_SIZE(physical_coding_sublayer_programming_v2));
+
+	/* SGMII lane-x init */
+	emac_reg_write_all(phy->digital,
+			   sgmii_v2_laned, ARRAY_SIZE(sgmii_v2_laned));
+
+	/* Power up PCS and start reset lane state machine */
+
+	writel(0x00, phy_regs + EMAC_SGMII_PHY_RESET_CTRL);
+	writel(0x01, laned + SGMII_LN_RSM_START);
+
+	/* Wait for c_ready assertion */
+	for (i = 0; i < SERDES_START_WAIT_TIMES; i++) {
+		lnstatus = readl(phy_regs + SGMII_PHY_LN_LANE_STATUS);
+		if (lnstatus & 0x02)
+			break;
+		usleep_range(100, 200);
+	}
+
+	if (i == SERDES_START_WAIT_TIMES) {
+		netdev_err(adpt->netdev, "SGMII failed to start\n");
+		return -EIO;
+	}
+
+	/* Disable digital and SERDES loopback */
+	writel(0x0, phy_regs + SGMII_PHY_LN_BIST_GEN0);
+	writel(0x0, phy_regs + SGMII_PHY_LN_BIST_GEN2);
+	writel(0x0, phy_regs + SGMII_PHY_LN_CDR_CTRL1);
+
+	/* Mask out all the SGMII Interrupt */
+	writel(0x0, phy_regs + EMAC_SGMII_PHY_INTERRUPT_MASK);
+
+	emac_sgmii_irq_clear(adpt, SGMII_PHY_INTERRUPT_ERR);
+
+	return 0;
+}
+
+void emac_sgmii_reset_prepare(struct emac_adapter *adpt)
+{
+	struct emac_phy *phy = &adpt->phy;
+	u32 val;
+
+	/* Reset PHY */
+	val = readl(phy->base + EMAC_EMAC_WRAPPER_CSR2);
+	writel(((val & ~PHY_RESET) | PHY_RESET), phy->base +
+	       EMAC_EMAC_WRAPPER_CSR2);
+	/* Ensure phy-reset command is written to HW before the release cmd */
+	msleep(50);
+	val = readl(phy->base + EMAC_EMAC_WRAPPER_CSR2);
+	writel((val & ~PHY_RESET), phy->base + EMAC_EMAC_WRAPPER_CSR2);
+	/* Ensure phy-reset release command is written to HW before initializing
+	 * SGMII
+	 */
+	msleep(50);
+}
+
+void emac_sgmii_reset(struct emac_adapter *adpt)
+{
+	clk_set_rate(adpt->clk[EMAC_CLK_HIGH_SPEED], 19200000);
+	emac_sgmii_reset_prepare(adpt);
+
+	if (adpt->phy.version == 2)
+		emac_sgmii_init_v2(adpt);
+	else
+		emac_sgmii_init_v1(adpt);
+
+	clk_set_rate(adpt->clk[EMAC_CLK_HIGH_SPEED], 125000000);
+}
+
+int emac_sgmii_config(struct platform_device *pdev, struct emac_adapter *adpt)
+{
+	struct emac_phy *phy = &adpt->phy;
+	struct resource *res;
+	u32 val;
+	int ret;
+
+	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, SGMII_MEM_RES);
+
+	phy->base = devm_ioremap_resource(&pdev->dev, res);
+	if (IS_ERR(phy->base))
+		return -ENOMEM;
+
+	/* The phy version is typically defined only if it's v2 or later */
+	ret = device_property_read_u32(&pdev->dev, "phy-version", &val);
+	if (ret < 0)
+		phy->version = 1;
+	else
+		phy->version = val;
+
+	if (phy->version == 2) {
+		/* SGMII-v2 controller has two CSRs, one per-lane digital part
+		 * and one per-lane analog part. The PHY regmap is
+		 * compatible to SGMII-v1 controller and will be used in PHY
+		 * common code and digital regmap referenced in SGMII-v2
+		 * specific initialization code.
+		 */
+		/* FIXME: we should be calling ioremap twice, instead of
+		 * doing pointer math.
+		 */
+		phy->digital = phy->base;
+		phy->base += EMAC_SGMII_PHY_LN_OFFSET;
+	}
+
+	return 0;
+}
+
diff --git a/drivers/net/ethernet/qualcomm/emac/emac-sgmii.h b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.h
new file mode 100644
index 0000000..cd7db9f
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.h
@@ -0,0 +1,24 @@
+/* Copyright (c) 2015, The Linux Foundation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 and
+ * only version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#ifndef _EMAC_SGMII_H_
+#define _EMAC_SGMII_H_
+
+struct emac_adapter;
+struct platform_device;
+
+int emac_sgmii_init_v1(struct emac_adapter *adpt);
+int emac_sgmii_init_v2(struct emac_adapter *adpt);
+int emac_sgmii_config(struct platform_device *pdev, struct emac_adapter *adpt);
+void emac_sgmii_reset(struct emac_adapter *adpt);
+
+#endif
diff --git a/drivers/net/ethernet/qualcomm/emac/emac.c b/drivers/net/ethernet/qualcomm/emac/emac.c
new file mode 100644
index 0000000..a857ef5
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/emac/emac.c
@@ -0,0 +1,809 @@
+/* Copyright (c) 2013-2016, The Linux Foundation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 and
+ * only version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+/* Qualcomm Technologies, Inc. EMAC Gigabit Ethernet Driver */
+
+#include <linux/if_ether.h>
+#include <linux/if_vlan.h>
+#include <linux/interrupt.h>
+#include <linux/io.h>
+#include <linux/module.h>
+#include <linux/of.h>
+#include <linux/of_net.h>
+#include <linux/phy.h>
+#include <linux/platform_device.h>
+#include "emac.h"
+#include "emac-mac.h"
+#include "emac-phy.h"
+#include "emac-sgmii.h"
+
+#define EMAC_MSG_DEFAULT (NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK |  \
+		NETIF_MSG_TIMER | NETIF_MSG_IFDOWN | NETIF_MSG_IFUP)
+
+#define EMAC_RRD_SIZE					     4
+#define EMAC_TS_RRD_SIZE				     6
+#define EMAC_TPD_SIZE					     4
+#define EMAC_RFD_SIZE					     2
+
+#define REG_MAC_RX_STATUS_BIN		 EMAC_RXMAC_STATC_REG0
+#define REG_MAC_RX_STATUS_END		EMAC_RXMAC_STATC_REG22
+#define REG_MAC_TX_STATUS_BIN		 EMAC_TXMAC_STATC_REG0
+#define REG_MAC_TX_STATUS_END		EMAC_TXMAC_STATC_REG24
+
+#define RXQ0_NUM_RFD_PREF_DEF				     8
+#define TXQ0_NUM_TPD_PREF_DEF				     5
+
+#define EMAC_PREAMBLE_DEF				     7
+
+#define DMAR_DLY_CNT_DEF				    15
+#define DMAW_DLY_CNT_DEF				     4
+
+#define IMR_NORMAL_MASK         (\
+		ISR_ERROR       |\
+		ISR_GPHY_LINK   |\
+		ISR_TX_PKT      |\
+		GPHY_WAKEUP_INT)
+
+#define IMR_EXTENDED_MASK       (\
+		SW_MAN_INT      |\
+		ISR_OVER        |\
+		ISR_ERROR       |\
+		ISR_GPHY_LINK   |\
+		ISR_TX_PKT      |\
+		GPHY_WAKEUP_INT)
+
+#define ISR_TX_PKT      (\
+	TX_PKT_INT      |\
+	TX_PKT_INT1     |\
+	TX_PKT_INT2     |\
+	TX_PKT_INT3)
+
+#define ISR_GPHY_LINK        (\
+	GPHY_LINK_UP_INT     |\
+	GPHY_LINK_DOWN_INT)
+
+#define ISR_OVER        (\
+	RFD0_UR_INT     |\
+	RFD1_UR_INT     |\
+	RFD2_UR_INT     |\
+	RFD3_UR_INT     |\
+	RFD4_UR_INT     |\
+	RXF_OF_INT      |\
+	TXF_UR_INT)
+
+#define ISR_ERROR       (\
+	DMAR_TO_INT     |\
+	DMAW_TO_INT     |\
+	TXQ_TO_INT)
+
+/* in sync with enum emac_clk_id */
+static const char * const emac_clk_name[] = {
+	"axi_clk", "cfg_ahb_clk", "high_speed_clk", "mdio_clk", "tx_clk",
+	"rx_clk", "sys_clk"
+};
+
+void emac_reg_update32(void __iomem *addr, u32 mask, u32 val)
+{
+	u32 data = readl(addr);
+
+	writel(((data & ~mask) | val), addr);
+}
+
+/* reinitialize */
+void emac_reinit_locked(struct emac_adapter *adpt)
+{
+	while (test_and_set_bit(EMAC_STATUS_RESETTING, &adpt->status))
+		msleep(20); /* Reset might take few 10s of ms */
+
+	emac_mac_down(adpt, true);
+
+	emac_sgmii_reset(adpt);
+	emac_mac_up(adpt);
+
+	clear_bit(EMAC_STATUS_RESETTING, &adpt->status);
+}
+
+/* NAPI */
+static int emac_napi_rtx(struct napi_struct *napi, int budget)
+{
+	struct emac_rx_queue *rx_q =
+		container_of(napi, struct emac_rx_queue, napi);
+	struct emac_adapter *adpt = netdev_priv(rx_q->netdev);
+	struct emac_irq *irq = rx_q->irq;
+	int work_done = 0;
+
+	emac_mac_rx_process(adpt, rx_q, &work_done, budget);
+
+	if (work_done < budget) {
+		napi_complete(napi);
+
+		irq->mask |= rx_q->intr;
+		writel(irq->mask, adpt->base + EMAC_INT_MASK);
+	}
+
+	return work_done;
+}
+
+/* Transmit the packet */
+static int emac_start_xmit(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct emac_adapter *adpt = netdev_priv(netdev);
+
+	return emac_mac_tx_buf_send(adpt, &adpt->tx_q, skb);
+}
+
+irqreturn_t emac_isr(int _irq, void *data)
+{
+	struct emac_irq *irq = data;
+	struct emac_adapter *adpt =
+		container_of(irq, struct emac_adapter, irq);
+	struct emac_rx_queue *rx_q = &adpt->rx_q;
+	u32 isr, status;
+
+	/* disable the interrupt */
+	writel(0, adpt->base + EMAC_INT_MASK);
+
+	isr = readl_relaxed(adpt->base + EMAC_INT_STATUS);
+
+	status = isr & irq->mask;
+	if (status == 0)
+		goto exit;
+
+	if (status & ISR_ERROR) {
+		netif_warn(adpt,  intr, adpt->netdev,
+			   "warning: error irq status 0x%lx\n",
+			   status & ISR_ERROR);
+		/* reset MAC */
+		set_bit(EMAC_STATUS_TASK_REINIT_REQ, &adpt->status);
+		/* Call into emac_work_thread */
+		schedule_work(&adpt->work_thread);
+	}
+
+	/* Schedule the napi for receive queue with interrupt
+	 * status bit set
+	 */
+	if (status & rx_q->intr) {
+		if (napi_schedule_prep(&rx_q->napi)) {
+			irq->mask &= ~rx_q->intr;
+			__napi_schedule(&rx_q->napi);
+		}
+	}
+
+	if (status & TX_PKT_INT)
+		emac_mac_tx_process(adpt, &adpt->tx_q);
+
+	if (status & ISR_OVER)
+		net_warn_ratelimited("warning: TX/RX overflow\n");
+
+	/* link event */
+	if (status & ISR_GPHY_LINK)
+		phy_mac_interrupt(adpt->phydev, !!(status & GPHY_LINK_UP_INT));
+
+exit:
+	/* enable the interrupt */
+	writel(irq->mask, adpt->base + EMAC_INT_MASK);
+
+	return IRQ_HANDLED;
+}
+
+/* Configure VLAN tag strip/insert feature */
+static int emac_set_features(struct net_device *netdev,
+			     netdev_features_t features)
+{
+	netdev_features_t changed = features ^ netdev->features;
+	struct emac_adapter *adpt = netdev_priv(netdev);
+
+	/* We only need to reprogram the hardware if the VLAN tag features
+	 * have changed, and if it's already running.
+	 */
+	if (!(changed & (NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX)))
+		return 0;
+
+	if (!netif_running(netdev))
+		return 0;
+
+	/* emac_mac_mode_config() uses netdev->features to configure the EMAC,
+	 * so make sure it's set first.
+	 */
+	netdev->features = features;
+	emac_reinit_locked(adpt);
+
+	return 0;
+}
+
+/* Configure Multicast and Promiscuous modes */
+static void emac_rx_mode_set(struct net_device *netdev)
+{
+	struct emac_adapter *adpt = netdev_priv(netdev);
+	struct netdev_hw_addr *ha;
+
+	emac_mac_mode_config(adpt);
+
+	/* update multicast address filtering */
+	emac_mac_multicast_addr_clear(adpt);
+	netdev_for_each_mc_addr(ha, netdev)
+		emac_mac_multicast_addr_set(adpt, ha->addr);
+}
+
+/* Change the Maximum Transfer Unit (MTU) */
+static int emac_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	unsigned int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
+	struct emac_adapter *adpt = netdev_priv(netdev);
+	unsigned int old_mtu = netdev->mtu;
+
+	if ((max_frame < EMAC_MIN_ETH_FRAME_SIZE) ||
+	    (max_frame > EMAC_MAX_ETH_FRAME_SIZE)) {
+		netdev_err(adpt->netdev, "error: invalid MTU setting\n");
+		return -EINVAL;
+	}
+
+	if ((old_mtu != new_mtu) && netif_running(netdev)) {
+		netif_info(adpt, hw, adpt->netdev,
+			   "changing MTU from %d to %d\n", netdev->mtu,
+			   new_mtu);
+		netdev->mtu = new_mtu;
+		adpt->rxbuf_size = new_mtu > EMAC_DEF_RX_BUF_SIZE ?
+			ALIGN(max_frame, 8) : EMAC_DEF_RX_BUF_SIZE;
+		emac_reinit_locked(adpt);
+	}
+
+	return 0;
+}
+
+/* Called when the network interface is made active */
+static int emac_open(struct net_device *netdev)
+{
+	struct emac_adapter *adpt = netdev_priv(netdev);
+	int ret;
+
+	/* allocate rx/tx dma buffer & descriptors */
+	ret = emac_mac_rx_tx_rings_alloc_all(adpt);
+	if (ret) {
+		netdev_err(adpt->netdev, "error allocating rx/tx rings\n");
+		return ret;
+	}
+
+	ret = emac_mac_up(adpt);
+	if (ret) {
+		emac_mac_rx_tx_rings_free_all(adpt);
+		return ret;
+	}
+
+	emac_mac_start(adpt);
+
+	return 0;
+}
+
+/* Called when the network interface is disabled */
+static int emac_close(struct net_device *netdev)
+{
+	struct emac_adapter *adpt = netdev_priv(netdev);
+
+	/* ensure no task is running and no reset is in progress */
+	while (test_and_set_bit(EMAC_STATUS_RESETTING, &adpt->status))
+		msleep(20); /* Reset might take few 10s of ms */
+
+	emac_mac_down(adpt, true);
+	emac_mac_rx_tx_rings_free_all(adpt);
+
+	clear_bit(EMAC_STATUS_RESETTING, &adpt->status);
+
+	return 0;
+}
+
+/* Respond to a TX hang */
+static void emac_tx_timeout(struct net_device *netdev)
+{
+	struct emac_adapter *adpt = netdev_priv(netdev);
+
+	set_bit(EMAC_STATUS_TASK_REINIT_REQ, &adpt->status);
+	schedule_work(&adpt->work_thread);
+}
+
+/* IOCTL support for the interface */
+static int emac_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
+{
+	if (!netif_running(netdev))
+		return -EINVAL;
+
+	if (!netdev->phydev)
+		return -ENODEV;
+
+	return phy_mii_ioctl(netdev->phydev, ifr, cmd);
+}
+
+/* Provide network statistics info for the interface */
+static struct rtnl_link_stats64 *emac_get_stats64(struct net_device *netdev,
+						  struct rtnl_link_stats64 *net_stats)
+{
+	struct emac_adapter *adpt = netdev_priv(netdev);
+	unsigned int addr = REG_MAC_RX_STATUS_BIN;
+	struct emac_stats *stats = &adpt->stats;
+	u64 *stats_itr = &adpt->stats.rx_ok;
+	u32 val;
+
+	mutex_lock(&stats->lock);
+
+	while (addr <= REG_MAC_RX_STATUS_END) {
+		val = readl_relaxed(adpt->base + addr);
+		*stats_itr += val;
+		stats_itr++;
+		addr += sizeof(u32);
+	}
+
+	/* additional rx status */
+	val = readl_relaxed(adpt->base + EMAC_RXMAC_STATC_REG23);
+	adpt->stats.rx_crc_align += val;
+	val = readl_relaxed(adpt->base + EMAC_RXMAC_STATC_REG24);
+	adpt->stats.rx_jubbers += val;
+
+	/* update tx status */
+	addr = REG_MAC_TX_STATUS_BIN;
+	stats_itr = &adpt->stats.tx_ok;
+
+	while (addr <= REG_MAC_TX_STATUS_END) {
+		val = readl_relaxed(adpt->base + addr);
+		*stats_itr += val;
+		++stats_itr;
+		addr += sizeof(u32);
+	}
+
+	/* additional tx status */
+	val = readl_relaxed(adpt->base + EMAC_TXMAC_STATC_REG25);
+	adpt->stats.tx_col += val;
+
+	/* return parsed statistics */
+	net_stats->rx_packets = stats->rx_ok;
+	net_stats->tx_packets = stats->tx_ok;
+	net_stats->rx_bytes = stats->rx_byte_cnt;
+	net_stats->tx_bytes = stats->tx_byte_cnt;
+	net_stats->multicast = stats->rx_mcast;
+	net_stats->collisions = stats->tx_1_col + stats->tx_2_col * 2 +
+				stats->tx_late_col + stats->tx_abort_col;
+
+	net_stats->rx_errors = stats->rx_frag + stats->rx_fcs_err +
+			       stats->rx_len_err + stats->rx_sz_ov +
+			       stats->rx_align_err;
+	net_stats->rx_fifo_errors = stats->rx_rxf_ov;
+	net_stats->rx_length_errors = stats->rx_len_err;
+	net_stats->rx_crc_errors = stats->rx_fcs_err;
+	net_stats->rx_frame_errors = stats->rx_align_err;
+	net_stats->rx_over_errors = stats->rx_rxf_ov;
+	net_stats->rx_missed_errors = stats->rx_rxf_ov;
+
+	net_stats->tx_errors = stats->tx_late_col + stats->tx_abort_col +
+			       stats->tx_underrun + stats->tx_trunc;
+	net_stats->tx_fifo_errors = stats->tx_underrun;
+	net_stats->tx_aborted_errors = stats->tx_abort_col;
+	net_stats->tx_window_errors = stats->tx_late_col;
+
+	mutex_unlock(&stats->lock);
+
+	return net_stats;
+}
+
+static const struct net_device_ops emac_netdev_ops = {
+	.ndo_open		= emac_open,
+	.ndo_stop		= emac_close,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_start_xmit		= emac_start_xmit,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_change_mtu		= emac_change_mtu,
+	.ndo_do_ioctl		= emac_ioctl,
+	.ndo_tx_timeout		= emac_tx_timeout,
+	.ndo_get_stats64	= emac_get_stats64,
+	.ndo_set_features       = emac_set_features,
+	.ndo_set_rx_mode        = emac_rx_mode_set,
+};
+
+/* Watchdog task routine */
+static void emac_work_thread(struct work_struct *work)
+{
+	struct emac_adapter *adpt =
+		container_of(work, struct emac_adapter, work_thread);
+
+	if (test_bit(EMAC_STATUS_TASK_REINIT_REQ, &adpt->status)) {
+		clear_bit(EMAC_STATUS_TASK_REINIT_REQ, &adpt->status);
+
+		if (!test_bit(EMAC_STATUS_RESETTING, &adpt->status))
+			emac_reinit_locked(adpt);
+	}
+}
+
+/* Initialize various data structures  */
+static void emac_init_adapter(struct emac_adapter *adpt)
+{
+	unsigned int max_frame;
+	u32 reg;
+
+	/* descriptors */
+	adpt->tx_desc_cnt = EMAC_DEF_TX_DESCS;
+	adpt->rx_desc_cnt = EMAC_DEF_RX_DESCS;
+
+	/* mtu */
+	adpt->netdev->mtu = ETH_DATA_LEN;
+	max_frame = adpt->netdev->mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
+	adpt->rxbuf_size = adpt->netdev->mtu > EMAC_DEF_RX_BUF_SIZE ?
+			   ALIGN(max_frame, 8) : EMAC_DEF_RX_BUF_SIZE;
+
+	/* dma */
+	adpt->dma_order = emac_dma_ord_out;
+	adpt->dmar_block = emac_dma_req_4096;
+	adpt->dmaw_block = emac_dma_req_128;
+	adpt->dmar_dly_cnt = DMAR_DLY_CNT_DEF;
+	adpt->dmaw_dly_cnt = DMAW_DLY_CNT_DEF;
+	adpt->tpd_burst = TXQ0_NUM_TPD_PREF_DEF;
+	adpt->rfd_burst = RXQ0_NUM_RFD_PREF_DEF;
+
+	/* irq moderator */
+	reg = ((EMAC_DEF_RX_IRQ_MOD >> 1) << IRQ_MODERATOR2_INIT_SHFT) |
+	      ((EMAC_DEF_TX_IRQ_MOD >> 1) << IRQ_MODERATOR_INIT_SHFT);
+	adpt->irq_mod = reg;
+
+	/* others */
+	adpt->preamble = EMAC_PREAMBLE_DEF;
+}
+
+static const u8 duuid[] = {
+	0x77, 0x79, 0x60, 0xbf,
+	0x2d, 0xab,
+	0x9d, 0x4b,
+	0x94, 0xf0,
+	0xe1, 0x11, 0x98, 0x01, 0xa2, 0xba
+};
+
+/* Get the clock */
+static int emac_clks_get(struct platform_device *pdev,
+			 struct emac_adapter *adpt)
+{
+	struct clk *clk;
+	unsigned int i;
+
+	for (i = 0; i < EMAC_CLK_CNT; i++) {
+		clk = clk_get(&pdev->dev, emac_clk_name[i]);
+
+		if (IS_ERR(clk)) {
+			netdev_err(adpt->netdev, "error:%ld on clk_get(%s)\n",
+				   PTR_ERR(clk), emac_clk_name[i]);
+
+			while (--i >= 0)
+				if (adpt->clk[i]) {
+					clk_put(adpt->clk[i]);
+					adpt->clk[i] = NULL;
+				}
+			return PTR_ERR(clk);
+		}
+
+		adpt->clk[i] = clk;
+	}
+
+	return 0;
+}
+
+/* Initialize clocks */
+static int emac_clks_phase1_init(struct platform_device *pdev,
+				 struct emac_adapter *adpt)
+{
+	int ret;
+
+	ret = clk_prepare_enable(adpt->clk[EMAC_CLK_AXI]);
+	if (ret)
+		return ret;
+
+	ret = clk_prepare_enable(adpt->clk[EMAC_CLK_CFG_AHB]);
+	if (ret)
+		return ret;
+
+	ret = clk_set_rate(adpt->clk[EMAC_CLK_HIGH_SPEED], 19200000);
+	if (ret)
+		return ret;
+
+	return clk_prepare_enable(adpt->clk[EMAC_CLK_HIGH_SPEED]);
+}
+
+/* Enable clocks; needs emac_clks_phase1_init to be called before */
+static int emac_clks_phase2_init(struct platform_device *pdev,
+				 struct emac_adapter *adpt)
+{
+	int ret;
+
+	ret = clk_set_rate(adpt->clk[EMAC_CLK_TX], 125000000);
+	if (ret)
+		return ret;
+
+	ret = clk_prepare_enable(adpt->clk[EMAC_CLK_TX]);
+	if (ret)
+		return ret;
+
+	ret = clk_set_rate(adpt->clk[EMAC_CLK_HIGH_SPEED], 125000000);
+	if (ret)
+		return ret;
+
+	ret = clk_set_rate(adpt->clk[EMAC_CLK_MDIO], 25000000);
+	if (ret)
+		return ret;
+
+	ret = clk_prepare_enable(adpt->clk[EMAC_CLK_MDIO]);
+	if (ret)
+		return ret;
+
+	ret = clk_prepare_enable(adpt->clk[EMAC_CLK_RX]);
+	if (ret)
+		return ret;
+
+	return clk_prepare_enable(adpt->clk[EMAC_CLK_SYS]);
+}
+
+static void emac_clks_phase1_teardown(struct emac_adapter *adpt)
+{
+	clk_disable_unprepare(adpt->clk[EMAC_CLK_AXI]);
+	clk_disable_unprepare(adpt->clk[EMAC_CLK_CFG_AHB]);
+	clk_disable_unprepare(adpt->clk[EMAC_CLK_HIGH_SPEED]);
+}
+
+static void emac_clks_phase2_teardown(struct emac_adapter *adpt)
+{
+	clk_disable_unprepare(adpt->clk[EMAC_CLK_TX]);
+	clk_disable_unprepare(adpt->clk[EMAC_CLK_MDIO]);
+	clk_disable_unprepare(adpt->clk[EMAC_CLK_RX]);
+	clk_disable_unprepare(adpt->clk[EMAC_CLK_SYS]);
+}
+
+/* Get the resources */
+static int emac_probe_resources(struct platform_device *pdev,
+				struct emac_adapter *adpt)
+{
+	struct device_node *node = pdev->dev.of_node;
+	struct net_device *netdev = adpt->netdev;
+	struct resource *res;
+	const void *maddr;
+	unsigned int i;
+	int ret = 0;
+
+	/* get time stamp enable flag */
+	adpt->timestamp_en =
+		device_property_read_bool(&pdev->dev, "qcom,emac-tstamp-en");
+
+	/* get mac address */
+	maddr = of_get_mac_address(node);
+	if (!maddr)
+		eth_hw_addr_random(netdev);
+	else
+		ether_addr_copy(netdev->dev_addr, maddr);
+
+	ret = platform_get_irq_byname(pdev, EMAC_MAC_IRQ_RES);
+	if (ret)
+		ret = platform_get_irq(pdev, 0);
+
+	if (ret < 0) {
+		netdev_err(adpt->netdev,
+			   "error: missing %s resource\n", EMAC_MAC_IRQ_RES);
+		return ret;
+	}
+	adpt->irq.irq = ret;
+
+	ret = emac_clks_get(pdev, adpt);
+	if (ret)
+		return ret;
+
+	/* get register addresses */
+	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "base");
+
+	adpt->base = devm_ioremap_resource(&pdev->dev, res);
+	if (!adpt->base) {
+		ret = -ENOMEM;
+		goto err_reg_res;
+	}
+
+	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "csr");
+
+	adpt->csr = devm_ioremap_resource(&pdev->dev, res);
+	if (!adpt->csr) {
+		ret = -ENOMEM;
+		goto err_reg_res;
+	}
+
+	netdev->base_addr = (unsigned long)adpt->base;
+	return 0;
+
+err_reg_res:
+	for (i = 0; i < EMAC_CLK_CNT; i++) {
+		if (adpt->clk[i]) {
+			clk_put(adpt->clk[i]);
+			adpt->clk[i] = NULL;
+		}
+	}
+
+	return ret;
+}
+
+/* Release resources */
+static void emac_release_resources(struct emac_adapter *adpt)
+{
+	unsigned int i;
+
+	for (i = 0; i < EMAC_CLK_CNT; i++)
+		if (adpt->clk[i]) {
+			clk_put(adpt->clk[i]);
+			adpt->clk[i] = NULL;
+		}
+}
+
+/* Probe function */
+static int emac_probe(struct platform_device *pdev)
+{
+	struct net_device *netdev;
+	struct emac_adapter *adpt;
+	struct emac_phy *phy;
+	u16 devid, revid;
+	u32 reg;
+	int ret;
+
+	/* The EMAC itself is capable of 64-bit DMA. If the SOC limits that
+	 * range, then we expect platform code to adjust the mask accordingly.
+	 */
+	ret = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(64));
+	if (ret) {
+		dev_err(&pdev->dev, "could not set DMA mask\n");
+		return ret;
+	}
+
+	netdev = alloc_etherdev(sizeof(struct emac_adapter));
+	if (!netdev)
+		return -ENOMEM;
+
+	dev_set_drvdata(&pdev->dev, netdev);
+	SET_NETDEV_DEV(netdev, &pdev->dev);
+
+	adpt = netdev_priv(netdev);
+	adpt->netdev = netdev;
+	phy = &adpt->phy;
+	adpt->msg_enable = EMAC_MSG_DEFAULT;
+
+	mutex_init(&adpt->stats.lock);
+
+	adpt->irq.mask = RX_PKT_INT0 | IMR_NORMAL_MASK;
+
+	ret = emac_probe_resources(pdev, adpt);
+	if (ret)
+		goto err_undo_netdev;
+
+	/* initialize clocks */
+	ret = emac_clks_phase1_init(pdev, adpt);
+	if (ret)
+		goto err_undo_resources;
+
+	netdev->watchdog_timeo = EMAC_WATCHDOG_TIME;
+	netdev->irq = adpt->irq.irq;
+
+	if (adpt->timestamp_en)
+		adpt->rrd_size = EMAC_TS_RRD_SIZE;
+	else
+		adpt->rrd_size = EMAC_RRD_SIZE;
+
+	adpt->tpd_size = EMAC_TPD_SIZE;
+	adpt->rfd_size = EMAC_RFD_SIZE;
+
+	/* init netdev */
+	netdev->netdev_ops = &emac_netdev_ops;
+
+	/* init adapter */
+	emac_init_adapter(adpt);
+
+	/* init phy */
+	ret = emac_phy_config(pdev, adpt);
+	if (ret)
+		goto err_undo_clk_phase1;
+
+	/* enable clocks */
+	ret = emac_clks_phase2_init(pdev, adpt);
+	if (ret)
+		goto err_undo_clk_phase2;
+
+	/* reset mac */
+	emac_mac_reset(adpt);
+
+	/* set hw features */
+	netdev->features = NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_RXCSUM |
+			NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_HW_VLAN_CTAG_RX |
+			NETIF_F_HW_VLAN_CTAG_TX;
+	netdev->hw_features = netdev->features;
+
+	netdev->vlan_features |= NETIF_F_SG | NETIF_F_HW_CSUM |
+				 NETIF_F_TSO | NETIF_F_TSO6;
+
+	INIT_WORK(&adpt->work_thread, emac_work_thread);
+
+	/* Initialize queues */
+	emac_mac_rx_tx_ring_init_all(pdev, adpt);
+
+	netif_napi_add(netdev, &adpt->rx_q.napi, emac_napi_rtx, 64);
+
+	spin_lock_init(&adpt->tx_ts_lock);
+	skb_queue_head_init(&adpt->tx_ts_pending_queue);
+	skb_queue_head_init(&adpt->tx_ts_ready_queue);
+	INIT_WORK(&adpt->tx_ts_task, emac_mac_tx_ts_periodic_routine);
+
+	strlcpy(netdev->name, "eth%d", sizeof(netdev->name));
+
+	ret = register_netdev(netdev);
+	if (ret)
+		goto err_undo_clk_phase2;
+
+	reg =  readl_relaxed(adpt->base + EMAC_DMA_MAS_CTRL);
+	devid = (reg & DEV_ID_NUM_BMSK)  >> DEV_ID_NUM_SHFT;
+	revid = (reg & DEV_REV_NUM_BMSK) >> DEV_REV_NUM_SHFT;
+	reg = readl_relaxed(adpt->base + EMAC_CORE_HW_VERSION);
+
+	netif_info(adpt, probe, netdev,
+		   "hardware id %d.%d, hardware version %d.%d.%d\n",
+		   devid, revid,
+		   (reg & MAJOR_BMSK) >> MAJOR_SHFT,
+		   (reg & MINOR_BMSK) >> MINOR_SHFT,
+		   (reg & STEP_BMSK)  >> STEP_SHFT);
+
+	return 0;
+
+err_undo_clk_phase2:
+	mdiobus_unregister(adpt->mii_bus);
+	emac_clks_phase2_teardown(adpt);
+err_undo_clk_phase1:
+	emac_clks_phase1_teardown(adpt);
+err_undo_resources:
+	emac_release_resources(adpt);
+err_undo_netdev:
+	free_netdev(netdev);
+
+	return ret;
+}
+
+static int emac_remove(struct platform_device *pdev)
+{
+	struct net_device *netdev = dev_get_drvdata(&pdev->dev);
+	struct emac_adapter *adpt = netdev_priv(netdev);
+
+	unregister_netdev(netdev);
+	netif_napi_del(&adpt->rx_q.napi);
+
+	emac_clks_phase2_teardown(adpt);
+	emac_clks_phase1_teardown(adpt);
+	emac_release_resources(adpt);
+
+	mdiobus_unregister(adpt->mii_bus);
+	free_netdev(netdev);
+	dev_set_drvdata(&pdev->dev, NULL);
+
+	return 0;
+}
+
+static const struct of_device_id emac_dt_match[] = {
+	{
+		.compatible = "qcom,fsm9900-emac",
+	},
+	{}
+};
+
+static struct platform_driver emac_platform_driver = {
+	.probe	= emac_probe,
+	.remove	= emac_remove,
+	.driver = {
+		.owner		= THIS_MODULE,
+		.name		= "qcom-emac",
+		.of_match_table = emac_dt_match,
+	},
+};
+
+module_platform_driver(emac_platform_driver);
+
+MODULE_LICENSE("GPL v2");
+MODULE_ALIAS("platform:qcom-emac");
diff --git a/drivers/net/ethernet/qualcomm/emac/emac.h b/drivers/net/ethernet/qualcomm/emac/emac.h
new file mode 100644
index 0000000..4148eb5
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/emac/emac.h
@@ -0,0 +1,369 @@
+/* Copyright (c) 2013-2016, The Linux Foundation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 and
+ * only version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#ifndef _EMAC_H_
+#define _EMAC_H_
+
+#include <asm/byteorder.h>
+#include <linux/interrupt.h>
+#include <linux/netdevice.h>
+#include <linux/clk.h>
+#include <linux/platform_device.h>
+#include "emac-mac.h"
+#include "emac-phy.h"
+
+/* EMAC base register offsets */
+#define EMAC_DMA_MAS_CTRL                                     0x001400
+#define EMAC_IRQ_MOD_TIM_INIT                                 0x001408
+#define EMAC_BLK_IDLE_STS                                     0x00140c
+#define EMAC_PHY_LINK_DELAY                                   0x00141c
+#define EMAC_SYS_ALIV_CTRL                                    0x001434
+#define EMAC_MAC_IPGIFG_CTRL                                  0x001484
+#define EMAC_MAC_STA_ADDR0                                    0x001488
+#define EMAC_MAC_STA_ADDR1                                    0x00148c
+#define EMAC_HASH_TAB_REG0                                    0x001490
+#define EMAC_HASH_TAB_REG1                                    0x001494
+#define EMAC_MAC_HALF_DPLX_CTRL                               0x001498
+#define EMAC_MAX_FRAM_LEN_CTRL                                0x00149c
+#define EMAC_INT_STATUS                                       0x001600
+#define EMAC_INT_MASK                                         0x001604
+#define EMAC_RXMAC_STATC_REG0                                 0x001700
+#define EMAC_RXMAC_STATC_REG22                                0x001758
+#define EMAC_TXMAC_STATC_REG0                                 0x001760
+#define EMAC_TXMAC_STATC_REG24                                0x0017c0
+#define EMAC_CORE_HW_VERSION                                  0x001974
+#define EMAC_IDT_TABLE0                                       0x001b00
+#define EMAC_RXMAC_STATC_REG23                                0x001bc8
+#define EMAC_RXMAC_STATC_REG24                                0x001bcc
+#define EMAC_TXMAC_STATC_REG25                                0x001bd0
+#define EMAC_INT1_MASK                                        0x001bf0
+#define EMAC_INT1_STATUS                                      0x001bf4
+#define EMAC_INT2_MASK                                        0x001bf8
+#define EMAC_INT2_STATUS                                      0x001bfc
+#define EMAC_INT3_MASK                                        0x001c00
+#define EMAC_INT3_STATUS                                      0x001c04
+
+/* EMAC_DMA_MAS_CTRL */
+#define DEV_ID_NUM_BMSK                                     0x7f000000
+#define DEV_ID_NUM_SHFT                                             24
+#define DEV_REV_NUM_BMSK                                      0xff0000
+#define DEV_REV_NUM_SHFT                                            16
+#define INT_RD_CLR_EN                                           0x4000
+#define IRQ_MODERATOR2_EN                                        0x800
+#define IRQ_MODERATOR_EN                                         0x400
+#define LPW_CLK_SEL                                               0x80
+#define LPW_STATE                                                 0x20
+#define LPW_MODE                                                  0x10
+#define SOFT_RST                                                   0x1
+
+/* EMAC_IRQ_MOD_TIM_INIT */
+#define IRQ_MODERATOR2_INIT_BMSK                            0xffff0000
+#define IRQ_MODERATOR2_INIT_SHFT                                    16
+#define IRQ_MODERATOR_INIT_BMSK                                 0xffff
+#define IRQ_MODERATOR_INIT_SHFT                                      0
+
+/* EMAC_INT_STATUS */
+#define DIS_INT                                                BIT(31)
+#define PTP_INT                                                BIT(30)
+#define RFD4_UR_INT                                            BIT(29)
+#define TX_PKT_INT3                                            BIT(26)
+#define TX_PKT_INT2                                            BIT(25)
+#define TX_PKT_INT1                                            BIT(24)
+#define RX_PKT_INT3                                            BIT(19)
+#define RX_PKT_INT2                                            BIT(18)
+#define RX_PKT_INT1                                            BIT(17)
+#define RX_PKT_INT0                                            BIT(16)
+#define TX_PKT_INT                                             BIT(15)
+#define TXQ_TO_INT                                             BIT(14)
+#define GPHY_WAKEUP_INT                                        BIT(13)
+#define GPHY_LINK_DOWN_INT                                     BIT(12)
+#define GPHY_LINK_UP_INT                                       BIT(11)
+#define DMAW_TO_INT                                            BIT(10)
+#define DMAR_TO_INT                                             BIT(9)
+#define TXF_UR_INT                                              BIT(8)
+#define RFD3_UR_INT                                             BIT(7)
+#define RFD2_UR_INT                                             BIT(6)
+#define RFD1_UR_INT                                             BIT(5)
+#define RFD0_UR_INT                                             BIT(4)
+#define RXF_OF_INT                                              BIT(3)
+#define SW_MAN_INT                                              BIT(2)
+
+/* EMAC_MAILBOX_6 */
+#define RFD2_PROC_IDX_BMSK                                   0xfff0000
+#define RFD2_PROC_IDX_SHFT                                          16
+#define RFD2_PROD_IDX_BMSK                                       0xfff
+#define RFD2_PROD_IDX_SHFT                                           0
+
+/* EMAC_CORE_HW_VERSION */
+#define MAJOR_BMSK                                          0xf0000000
+#define MAJOR_SHFT                                                  28
+#define MINOR_BMSK                                           0xfff0000
+#define MINOR_SHFT                                                  16
+#define STEP_BMSK                                               0xffff
+#define STEP_SHFT                                                    0
+
+/* EMAC_EMAC_WRAPPER_CSR1 */
+#define TX_INDX_FIFO_SYNC_RST                                  BIT(23)
+#define TX_TS_FIFO_SYNC_RST                                    BIT(22)
+#define RX_TS_FIFO2_SYNC_RST                                   BIT(21)
+#define RX_TS_FIFO1_SYNC_RST                                   BIT(20)
+#define TX_TS_ENABLE                                           BIT(16)
+#define DIS_1588_CLKS                                          BIT(11)
+#define FREQ_MODE                                               BIT(9)
+#define ENABLE_RRD_TIMESTAMP                                    BIT(3)
+
+/* EMAC_EMAC_WRAPPER_CSR2 */
+#define HDRIVE_BMSK                                             0x3000
+#define HDRIVE_SHFT                                                 12
+#define SLB_EN                                                  BIT(9)
+#define PLB_EN                                                  BIT(8)
+#define WOL_EN                                                  BIT(3)
+#define PHY_RESET                                               BIT(0)
+
+#define EMAC_DEV_ID                                             0x0040
+
+/* SGMII v2 per lane registers */
+#define SGMII_LN_RSM_START             0x029C
+
+/* SGMII v2 PHY common registers */
+#define SGMII_PHY_CMN_CTRL            0x0408
+#define SGMII_PHY_CMN_RESET_CTRL      0x0410
+
+/* SGMII v2 PHY registers per lane */
+#define SGMII_PHY_LN_OFFSET          0x0400
+#define SGMII_PHY_LN_LANE_STATUS     0x00DC
+#define SGMII_PHY_LN_BIST_GEN0       0x008C
+#define SGMII_PHY_LN_BIST_GEN1       0x0090
+#define SGMII_PHY_LN_BIST_GEN2       0x0094
+#define SGMII_PHY_LN_BIST_GEN3       0x0098
+#define SGMII_PHY_LN_CDR_CTRL1       0x005C
+
+enum emac_clk_id {
+	EMAC_CLK_AXI,
+	EMAC_CLK_CFG_AHB,
+	EMAC_CLK_HIGH_SPEED,
+	EMAC_CLK_MDIO,
+	EMAC_CLK_TX,
+	EMAC_CLK_RX,
+	EMAC_CLK_SYS,
+	EMAC_CLK_CNT
+};
+
+#define EMAC_LINK_SPEED_UNKNOWN                                    0x0
+#define EMAC_LINK_SPEED_10_HALF                                 BIT(0)
+#define EMAC_LINK_SPEED_10_FULL                                 BIT(1)
+#define EMAC_LINK_SPEED_100_HALF                                BIT(2)
+#define EMAC_LINK_SPEED_100_FULL                                BIT(3)
+#define EMAC_LINK_SPEED_1GB_FULL                                BIT(5)
+
+#define EMAC_MAX_SETUP_LNK_CYCLE                                   100
+
+/* Wake On Lan */
+#define EMAC_WOL_PHY                     0x00000001 /* PHY Status Change */
+#define EMAC_WOL_MAGIC                   0x00000002 /* Magic Packet */
+
+struct emac_stats {
+	/* rx */
+	u64 rx_ok;              /* good packets */
+	u64 rx_bcast;           /* good broadcast packets */
+	u64 rx_mcast;           /* good multicast packets */
+	u64 rx_pause;           /* pause packet */
+	u64 rx_ctrl;            /* control packets other than pause frame. */
+	u64 rx_fcs_err;         /* packets with bad FCS. */
+	u64 rx_len_err;         /* packets with length mismatch */
+	u64 rx_byte_cnt;        /* good bytes count (without FCS) */
+	u64 rx_runt;            /* runt packets */
+	u64 rx_frag;            /* fragment count */
+	u64 rx_sz_64;	        /* packets that are 64 bytes */
+	u64 rx_sz_65_127;       /* packets that are 65-127 bytes */
+	u64 rx_sz_128_255;      /* packets that are 128-255 bytes */
+	u64 rx_sz_256_511;      /* packets that are 256-511 bytes */
+	u64 rx_sz_512_1023;     /* packets that are 512-1023 bytes */
+	u64 rx_sz_1024_1518;    /* packets that are 1024-1518 bytes */
+	u64 rx_sz_1519_max;     /* packets that are 1519-MTU bytes*/
+	u64 rx_sz_ov;           /* packets that are >MTU bytes (truncated) */
+	u64 rx_rxf_ov;          /* packets dropped due to RX FIFO overflow */
+	u64 rx_align_err;       /* alignment errors */
+	u64 rx_bcast_byte_cnt;  /* broadcast packets byte count (without FCS) */
+	u64 rx_mcast_byte_cnt;  /* multicast packets byte count (without FCS) */
+	u64 rx_err_addr;        /* packets dropped due to address filtering */
+	u64 rx_crc_align;       /* CRC align errors */
+	u64 rx_jubbers;         /* jubbers */
+
+	/* tx */
+	u64 tx_ok;              /* good packets */
+	u64 tx_bcast;           /* good broadcast packets */
+	u64 tx_mcast;           /* good multicast packets */
+	u64 tx_pause;           /* pause packets */
+	u64 tx_exc_defer;       /* packets with excessive deferral */
+	u64 tx_ctrl;            /* control packets other than pause frame */
+	u64 tx_defer;           /* packets that are deferred. */
+	u64 tx_byte_cnt;        /* good bytes count (without FCS) */
+	u64 tx_sz_64;           /* packets that are 64 bytes */
+	u64 tx_sz_65_127;       /* packets that are 65-127 bytes */
+	u64 tx_sz_128_255;      /* packets that are 128-255 bytes */
+	u64 tx_sz_256_511;      /* packets that are 256-511 bytes */
+	u64 tx_sz_512_1023;     /* packets that are 512-1023 bytes */
+	u64 tx_sz_1024_1518;    /* packets that are 1024-1518 bytes */
+	u64 tx_sz_1519_max;     /* packets that are 1519-MTU bytes */
+	u64 tx_1_col;           /* packets single prior collision */
+	u64 tx_2_col;           /* packets with multiple prior collisions */
+	u64 tx_late_col;        /* packets with late collisions */
+	u64 tx_abort_col;       /* packets aborted due to excess collisions */
+	u64 tx_underrun;        /* packets aborted due to FIFO underrun */
+	u64 tx_rd_eop;          /* count of reads beyond EOP */
+	u64 tx_len_err;         /* packets with length mismatch */
+	u64 tx_trunc;           /* packets truncated due to size >MTU */
+	u64 tx_bcast_byte;      /* broadcast packets byte count (without FCS) */
+	u64 tx_mcast_byte;      /* multicast packets byte count (without FCS) */
+	u64 tx_col;             /* collisions */
+
+	struct mutex lock;	/* prevent multiple simultaneous readers */
+};
+
+enum emac_status_bits {
+	EMAC_STATUS_RESETTING,
+	EMAC_STATUS_TASK_REINIT_REQ,
+};
+
+/* RSS hstype Definitions */
+#define EMAC_RSS_HSTYP_IPV4_EN				    0x00000001
+#define EMAC_RSS_HSTYP_TCP4_EN				    0x00000002
+#define EMAC_RSS_HSTYP_IPV6_EN				    0x00000004
+#define EMAC_RSS_HSTYP_TCP6_EN				    0x00000008
+#define EMAC_RSS_HSTYP_ALL_EN (\
+		EMAC_RSS_HSTYP_IPV4_EN   |\
+		EMAC_RSS_HSTYP_TCP4_EN   |\
+		EMAC_RSS_HSTYP_IPV6_EN   |\
+		EMAC_RSS_HSTYP_TCP6_EN)
+
+#define EMAC_VLAN_TO_TAG(_vlan, _tag) \
+		(_tag =  ((((_vlan) >> 8) & 0xFF) | (((_vlan) & 0xFF) << 8)))
+
+#define EMAC_TAG_TO_VLAN(_tag, _vlan) \
+		(_vlan = ((((_tag) >> 8) & 0xFF) | (((_tag) & 0xFF) << 8)))
+
+#define EMAC_DEF_RX_BUF_SIZE					  1536
+#define EMAC_MAX_JUMBO_PKT_SIZE				    (9 * 1024)
+#define EMAC_MAX_TX_OFFLOAD_THRESH			    (9 * 1024)
+
+#define EMAC_MAX_ETH_FRAME_SIZE		       EMAC_MAX_JUMBO_PKT_SIZE
+#define EMAC_MIN_ETH_FRAME_SIZE					    68
+
+#define EMAC_DEF_TX_QUEUES					     1
+#define EMAC_DEF_RX_QUEUES					     1
+
+#define EMAC_MIN_TX_DESCS					   128
+#define EMAC_MIN_RX_DESCS					   128
+
+#define EMAC_MAX_TX_DESCS					 16383
+#define EMAC_MAX_RX_DESCS					  2047
+
+#define EMAC_DEF_TX_DESCS					   512
+#define EMAC_DEF_RX_DESCS					   256
+
+#define EMAC_DEF_RX_IRQ_MOD					   250
+#define EMAC_DEF_TX_IRQ_MOD					   250
+
+#define EMAC_WATCHDOG_TIME				      (5 * HZ)
+
+/* by default check link every 4 seconds */
+#define EMAC_TRY_LINK_TIMEOUT				      (4 * HZ)
+
+/* emac_irq per-device (per-adapter) irq properties.
+ * @idx:	index of this irq entry in the adapter irq array.
+ * @irq:	irq number.
+ * @mask	mask to use over status register.
+ */
+struct emac_irq {
+	int		idx;
+	unsigned int	irq;
+	u32		mask;
+};
+
+/* emac_irq_config irq properties which are common to all devices of this driver
+ * @name	name in configuration (devicetree).
+ * @handler	ISR.
+ * @status_reg	status register offset.
+ * @mask_reg	mask   register offset.
+ * @init_mask	initial value for mask to use over status register.
+ * @irqflags	request_irq() flags.
+ */
+struct emac_irq_config {
+	char		*name;
+	irq_handler_t	handler;
+
+	u32		status_reg;
+	u32		mask_reg;
+	u32		init_mask;
+
+	unsigned long	irqflags;
+};
+
+/* The device's main data structure */
+struct emac_adapter {
+	struct net_device		*netdev;
+	struct mii_bus			*mii_bus;
+	struct phy_device		*phydev;
+
+	void __iomem			*base;
+	void __iomem			*csr;
+
+	struct emac_phy			phy;
+	struct emac_stats		stats;
+
+	struct emac_irq			irq;
+	struct clk			*clk[EMAC_CLK_CNT];
+
+	/* All Descriptor memory */
+	struct emac_ring_header		ring_header;
+	struct emac_tx_queue		tx_q;
+	struct emac_rx_queue		rx_q;
+	unsigned int			tx_desc_cnt;
+	unsigned int			rx_desc_cnt;
+	unsigned int			rrd_size; /* in quad words */
+	unsigned int			rfd_size; /* in quad words */
+	unsigned int			tpd_size; /* in quad words */
+
+	unsigned int			rxbuf_size;
+
+	/* Ring parameter */
+	u8				tpd_burst;
+	u8				rfd_burst;
+	unsigned int			dmaw_dly_cnt;
+	unsigned int			dmar_dly_cnt;
+	enum emac_dma_req_block		dmar_block;
+	enum emac_dma_req_block		dmaw_block;
+	enum emac_dma_order		dma_order;
+
+	u32				irq_mod;
+	u32				preamble;
+
+	/* Tx time-stamping queue */
+	struct sk_buff_head		tx_ts_pending_queue;
+	struct sk_buff_head		tx_ts_ready_queue;
+	struct work_struct		tx_ts_task;
+	spinlock_t			tx_ts_lock; /* Tx timestamp que lock */
+	struct emac_tx_ts_stats		tx_ts_stats;
+
+	struct work_struct		work_thread;
+
+	bool				timestamp_en;
+	u16				msg_enable;
+	unsigned long			status;
+};
+
+void emac_reinit_locked(struct emac_adapter *adpt);
+void emac_reg_update32(void __iomem *addr, u32 mask, u32 val);
+irqreturn_t emac_isr(int irq, void *data);
+
+#endif /* _EMAC_H_ */
-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
a Linux Foundation Collaborative Project.
