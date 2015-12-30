From: Gilad Avidov <gavidov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: [PATCH V3] net: emac: emac gigabit ethernet controller driver
Date: Tue, 29 Dec 2015 18:48:55 -0700
Message-ID: <1451440135-25771-1-git-send-email-gavidov@codeaurora.org>
Cc: sdharia-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, shankerd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
	vikrams-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	Gilad Avidov <gavidov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add supports for ethernet controller HW on Qualcomm Technologies, Inc. SoC.
This driver supports the following features:
1) Checksum offload.
2) Runtime power management support.
3) Interrupt coalescing support.
4) SGMII phy.
5) SGMII direct connection without external phy.

Based on a driver by Niranjana Vishwanathapura
<nvishwan-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>.

Changes since v1 (https://lkml.org/lkml/2015/12/7/1088)
 - replace hw bit fields to macros with bitwise operations.
 - change all iterators to unsized types (int)
 - some minor code flow improvements.
 - change return type to void for functions which return value is never
   used.
 - replace instance of xxxxl_relaxed() io followed by mb() with a
   readl()/writel().

Changes since v2 (https://lwn.net/Articles/667876/)
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

Signed-off-by: Gilad Avidov <gavidov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
---
 .../devicetree/bindings/net/qcom-emac.txt          |   68 +
 drivers/net/ethernet/qualcomm/Kconfig              |   11 +
 drivers/net/ethernet/qualcomm/Makefile             |    2 +
 drivers/net/ethernet/qualcomm/emac/Makefile        |    7 +
 drivers/net/ethernet/qualcomm/emac/emac-mac.c      | 1808 ++++++++++++++++++++
 drivers/net/ethernet/qualcomm/emac/emac-mac.h      |  286 ++++
 drivers/net/ethernet/qualcomm/emac/emac-phy.c      |  486 ++++++
 drivers/net/ethernet/qualcomm/emac/emac-phy.h      |   69 +
 drivers/net/ethernet/qualcomm/emac/emac-sgmii.c    |  679 ++++++++
 drivers/net/ethernet/qualcomm/emac/emac-sgmii.h    |   30 +
 drivers/net/ethernet/qualcomm/emac/emac.c          | 1228 +++++++++++++
 drivers/net/ethernet/qualcomm/emac/emac.h          |  388 +++++
 12 files changed, 5062 insertions(+)
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
index 0000000..8d58a40
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/qcom-emac.txt
@@ -0,0 +1,68 @@
+Qualcomm EMAC Gigabit Ethernet Controller
+
+Required properties:
+- cell-index : EMAC controller instance number.
+- compatible : Should be "qcom,emac".
+- reg : Offset and length of the register regions for the device
+- reg-names : Register region names referenced in 'reg' above.
+	Required register resource entries are:
+	"base"   : EMAC controller base register block.
+	"csr"    : EMAC wrapper register block.
+	Optional register resource entries are:
+	"ptp"    : EMAC PTP (1588) register block.
+		   Required if 'qcom,emac-tstamp-en' is present.
+	"sgmii"  : EMAC SGMII PHY register block.
+- interrupts : Interrupt numbers used by this controller
+- interrupt-names : Interrupt resource names referenced in 'interrupts' above.
+	Required interrupt resource entries are:
+	"emac_core0"   : EMAC core0 interrupt.
+	"sgmii_irq"   : EMAC SGMII interrupt.
+- qcom,emac-gpio-mdc  : GPIO pin number of the MDC line of MDIO bus.
+- qcom,emac-gpio-mdio : GPIO pin number of the MDIO line of MDIO bus.
+- phy-addr            : Specifies phy address on MDIO bus.
+			Required if the optional property "qcom,no-external-phy"
+			is not specified.
+
+Optional properties:
+- qcom,emac-tstamp-en       : Enables the PTP (1588) timestamping feature.
+			      Include this only if PTP (1588) timestamping
+			      feature is needed. If included, "ptp" register
+			      base should be specified.
+- mac-address               : The 6-byte MAC address. If present, it is the
+			      default MAC address.
+- qcom,no-external-phy      : Indicates there is no external PHY connected to
+			      EMAC. Include this only if the EMAC is directly
+			      connected to the peer end without EPHY.
+- qcom,emac-ptp-grandmaster : Enable the PTP (1588) grandmaster mode.
+			      Include this only if PTP (1588) is configured as
+			      grandmaster.
+- qcom,emac-ptp-frac-ns-adj : The vector table to adjust the fractional ns per
+			      RTC clock cycle.
+			      Include this only if there is accuracy loss of
+			      fractional ns per RTC clock cycle. For individual
+			      table entry, the first field indicates the RTC
+			      reference clock rate. The second field indicates
+			      the number of adjustment in 2 ^ -26 ns.
+Example:
+	emac0: qcom,emac@feb20000 {
+		cell-index = <0>;
+		compatible = "qcom,emac";
+		reg-names = "base", "csr", "ptp", "sgmii";
+		reg =   <0xfeb20000 0x10000>,
+			<0xfeb36000 0x1000>,
+			<0xfeb3c000 0x4000>,
+			<0xfeb38000 0x400>;
+		#address-cells = <0>;
+		interrupt-parent = <&emac0>;
+		#interrupt-cells = <1>;
+		interrupts = <0 1>;
+		interrupt-map-mask = <0xffffffff>;
+		interrupt-map = <0 &intc 0 76 0
+				 1 &intc 0 80 0>;
+		interrupt-names = "emac_core0", "sgmii_irq";
+		qcom,emac-gpio-mdc = <&qcomgpio 123 0>;
+		qcom,emac-gpio-mdio = <&qcomgpio 124 0>;
+		qcom,emac-tstamp-en;
+		qcom,emac-ptp-frac-ns-adj = <125000000 1>;
+		phy-addr = <0>;
+	};
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
index 9da2d75..b14686e 100644
--- a/drivers/net/ethernet/qualcomm/Makefile
+++ b/drivers/net/ethernet/qualcomm/Makefile
@@ -4,3 +4,5 @@
 
 obj-$(CONFIG_QCA7000) += qcaspi.o
 qcaspi-objs := qca_spi.o qca_framing.o qca_7k.o qca_debug.o
+
+obj-$(CONFIG_QCOM_EMAC) += emac/
\ No newline at end of file
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
index 0000000..36a7746
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
@@ -0,0 +1,1808 @@
+/* Copyright (c) 2013-2015, The Linux Foundation. All rights reserved.
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
+#include <linux/gpio.h>
+#include <linux/pm_runtime.h>
+#include "emac.h"
+#include "emac-sgmii.h"
+
+/* EMAC base register offsets */
+#define EMAC_MAC_CTRL                                         0x001480
+#define EMAC_WOL_CTRL0                                        0x0014a0
+#define EMAC_RSS_KEY0                                         0x0014b0
+#define EMAC_H1TPD_BASE_ADDR_LO                               0x0014e0
+#define EMAC_H2TPD_BASE_ADDR_LO                               0x0014e4
+#define EMAC_H3TPD_BASE_ADDR_LO                               0x0014e8
+#define EMAC_INTER_SRAM_PART9                                 0x001534
+#define EMAC_DESC_CTRL_0                                      0x001540
+#define EMAC_DESC_CTRL_1                                      0x001544
+#define EMAC_DESC_CTRL_2                                      0x001550
+#define EMAC_DESC_CTRL_10                                     0x001554
+#define EMAC_DESC_CTRL_12                                     0x001558
+#define EMAC_DESC_CTRL_13                                     0x00155c
+#define EMAC_DESC_CTRL_3                                      0x001560
+#define EMAC_DESC_CTRL_4                                      0x001564
+#define EMAC_DESC_CTRL_5                                      0x001568
+#define EMAC_DESC_CTRL_14                                     0x00156c
+#define EMAC_DESC_CTRL_15                                     0x001570
+#define EMAC_DESC_CTRL_16                                     0x001574
+#define EMAC_DESC_CTRL_6                                      0x001578
+#define EMAC_DESC_CTRL_8                                      0x001580
+#define EMAC_DESC_CTRL_9                                      0x001584
+#define EMAC_DESC_CTRL_11                                     0x001588
+#define EMAC_TXQ_CTRL_0                                       0x001590
+#define EMAC_TXQ_CTRL_1                                       0x001594
+#define EMAC_TXQ_CTRL_2                                       0x001598
+#define EMAC_RXQ_CTRL_0                                       0x0015a0
+#define EMAC_RXQ_CTRL_1                                       0x0015a4
+#define EMAC_RXQ_CTRL_2                                       0x0015a8
+#define EMAC_RXQ_CTRL_3                                       0x0015ac
+#define EMAC_BASE_CPU_NUMBER                                  0x0015b8
+#define EMAC_DMA_CTRL                                         0x0015c0
+#define EMAC_MAILBOX_0                                        0x0015e0
+#define EMAC_MAILBOX_5                                        0x0015e4
+#define EMAC_MAILBOX_6                                        0x0015e8
+#define EMAC_MAILBOX_13                                       0x0015ec
+#define EMAC_MAILBOX_2                                        0x0015f4
+#define EMAC_MAILBOX_3                                        0x0015f8
+#define EMAC_MAILBOX_11                                       0x00160c
+#define EMAC_AXI_MAST_CTRL                                    0x001610
+#define EMAC_MAILBOX_12                                       0x001614
+#define EMAC_MAILBOX_9                                        0x001618
+#define EMAC_MAILBOX_10                                       0x00161c
+#define EMAC_ATHR_HEADER_CTRL                                 0x001620
+#define EMAC_CLK_GATE_CTRL                                    0x001814
+#define EMAC_MISC_CTRL                                        0x001990
+#define EMAC_MAILBOX_7                                        0x0019e0
+#define EMAC_MAILBOX_8                                        0x0019e4
+#define EMAC_MAILBOX_15                                       0x001bd4
+#define EMAC_MAILBOX_16                                       0x001bd8
+
+/* EMAC_MAC_CTRL */
+#define SINGLE_PAUSE_MODE                                   0x10000000
+#define DEBUG_MODE                                           0x8000000
+#define BROAD_EN                                             0x4000000
+#define MULTI_ALL                                            0x2000000
+#define RX_CHKSUM_EN                                         0x1000000
+#define HUGE                                                  0x800000
+#define SPEED_BMSK                                            0x300000
+#define SPEED_SHFT                                                  20
+#define SIMR                                                   0x80000
+#define TPAUSE                                                 0x10000
+#define PROM_MODE                                               0x8000
+#define VLAN_STRIP                                              0x4000
+#define PRLEN_BMSK                                              0x3c00
+#define PRLEN_SHFT                                                  10
+#define HUGEN                                                    0x200
+#define FLCHK                                                    0x100
+#define PCRCE                                                     0x80
+#define CRCE                                                      0x40
+#define FULLD                                                     0x20
+#define MAC_LP_EN                                                 0x10
+#define RXFC                                                       0x8
+#define TXFC                                                       0x4
+#define RXEN                                                       0x2
+#define TXEN                                                       0x1
+
+/* EMAC_WOL_CTRL0 */
+#define LK_CHG_PME                                                0x20
+#define LK_CHG_EN                                                 0x10
+#define MG_FRAME_PME                                               0x8
+#define MG_FRAME_EN                                                0x4
+#define WK_FRAME_EN                                                0x1
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
+/* DMA address */
+#define DMA_ADDR_HI_MASK                         0xffffffff00000000ULL
+#define DMA_ADDR_LO_MASK                         0x00000000ffffffffULL
+
+#define EMAC_DMA_ADDR_HI(_addr)                                      \
+		((u32)(((u64)(_addr) & DMA_ADDR_HI_MASK) >> 32))
+#define EMAC_DMA_ADDR_LO(_addr)                                      \
+		((u32)((u64)(_addr) & DMA_ADDR_LO_MASK))
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
+	mta |= (0x1 << bit);
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
+	u32 mac;
+
+	mac = readl(adpt->base + EMAC_MAC_CTRL);
+
+	if (test_bit(EMAC_STATUS_VLANSTRIP_EN, &adpt->status))
+		mac |= VLAN_STRIP;
+	else
+		mac &= ~VLAN_STRIP;
+
+	if (test_bit(EMAC_STATUS_PROMISC_EN, &adpt->status))
+		mac |= PROM_MODE;
+	else
+		mac &= ~PROM_MODE;
+
+	if (test_bit(EMAC_STATUS_MULTIALL_EN, &adpt->status))
+		mac |= MULTI_ALL;
+	else
+		mac &= ~MULTI_ALL;
+
+	if (test_bit(EMAC_STATUS_LOOPBACK_EN, &adpt->status))
+		mac |= MAC_LP_EN;
+	else
+		mac &= ~MAC_LP_EN;
+
+	writel(mac, adpt->base + EMAC_MAC_CTRL);
+}
+
+/* Power Management */
+void emac_mac_pm(struct emac_adapter *adpt)
+{
+	u32 dma_mas, mac;
+
+	dma_mas = readl(adpt->base + EMAC_DMA_MAS_CTRL);
+	dma_mas &= ~LPW_CLK_SEL;
+	dma_mas |= LPW_STATE | LPW_CLK_SEL;
+
+	mac = readl(adpt->base + EMAC_MAC_CTRL);
+	mac &= ~(FULLD | RXEN | TXEN);
+	mac = (mac & ~SPEED_BMSK) |
+	  (((u32)emac_mac_speed_10_100 << SPEED_SHFT) & SPEED_BMSK);
+
+	writel(dma_mas, adpt->base + EMAC_DMA_MAS_CTRL);
+	writel(mac, adpt->base + EMAC_MAC_CTRL);
+}
+
+/* Config descriptor rings */
+static void emac_mac_dma_rings_config(struct emac_adapter *adpt)
+{
+	static const unsigned int tpd_q_offset[] = {
+		EMAC_DESC_CTRL_8,        EMAC_H1TPD_BASE_ADDR_LO,
+		EMAC_H2TPD_BASE_ADDR_LO, EMAC_H3TPD_BASE_ADDR_LO};
+	static const unsigned int rfd_q_offset[] = {
+		EMAC_DESC_CTRL_2,        EMAC_DESC_CTRL_10,
+		EMAC_DESC_CTRL_12,       EMAC_DESC_CTRL_13};
+	static const unsigned int rrd_q_offset[] = {
+		EMAC_DESC_CTRL_5,        EMAC_DESC_CTRL_14,
+		EMAC_DESC_CTRL_15,       EMAC_DESC_CTRL_16};
+
+	if (adpt->timestamp_en)
+		emac_reg_update32(adpt->csr + EMAC_EMAC_WRAPPER_CSR1,
+				  0, ENABLE_RRD_TIMESTAMP);
+
+	/* TPD (Transmit Packet Descriptor) */
+	writel(EMAC_DMA_ADDR_HI(adpt->tx_q.tpd.dma_addr),
+	       adpt->base + EMAC_DESC_CTRL_1);
+
+	writel(EMAC_DMA_ADDR_LO(adpt->tx_q.tpd.dma_addr),
+	       adpt->base + tpd_q_offset[0]);
+
+	writel(adpt->tx_q.tpd.count & TPD_RING_SIZE_BMSK,
+	       adpt->base + EMAC_DESC_CTRL_9);
+
+	/* RFD (Receive Free Descriptor) & RRD (Receive Return Descriptor) */
+	writel(EMAC_DMA_ADDR_HI(adpt->rx_q.rfd.dma_addr),
+	       adpt->base + EMAC_DESC_CTRL_0);
+
+	writel(EMAC_DMA_ADDR_LO(adpt->rx_q.rfd.dma_addr),
+	       adpt->base + rfd_q_offset[0]);
+	writel(EMAC_DMA_ADDR_LO(adpt->rx_q.rrd.dma_addr),
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
+	val |= (TXQ_MODE | LS_8023_SP);
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
+	val = ((adpt->rfd_burst << NUM_RFD_BURST_PREF_SHFT) &
+	       NUM_RFD_BURST_PREF_BMSK);
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
+	u32 dma_ctrl;
+
+	dma_ctrl = DMAR_REQ_PRI;
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
+void emac_mac_config(struct emac_adapter *adpt)
+{
+	u32 val;
+
+	emac_mac_addr_clear(adpt, adpt->mac_addr);
+
+	emac_mac_dma_rings_config(adpt);
+
+	writel(adpt->mtu + ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN,
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
+	struct emac_phy *phy = &adpt->phy;
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
+	/* enable RX/TX Flow Control */
+	switch (phy->cur_fc_mode) {
+	case EMAC_FC_FULL:
+		mac |= (TXFC | RXFC);
+		break;
+	case EMAC_FC_RX_PAUSE:
+		mac |= RXFC;
+		break;
+	case EMAC_FC_TX_PAUSE:
+		mac |= TXFC;
+		break;
+	default:
+		break;
+	}
+
+	/* setup link speed */
+	mac &= ~SPEED_BMSK;
+	switch (phy->link_speed) {
+	case EMAC_LINK_SPEED_1GB_FULL:
+		mac |= ((emac_mac_speed_1000 << SPEED_SHFT) & SPEED_BMSK);
+		csr1 |= FREQ_MODE;
+		break;
+	default:
+		mac |= ((emac_mac_speed_10_100 << SPEED_SHFT) & SPEED_BMSK);
+		csr1 &= ~FREQ_MODE;
+		break;
+	}
+
+	switch (phy->link_speed) {
+	case EMAC_LINK_SPEED_1GB_FULL:
+	case EMAC_LINK_SPEED_100_FULL:
+	case EMAC_LINK_SPEED_10_FULL:
+		mac |= FULLD;
+		break;
+	default:
+		mac &= ~FULLD;
+	}
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
+	emac_reg_update32(adpt->base + EMAC_MAC_CTRL, (TXEN | RXEN), 0);
+	usleep_range(1000, 1050); /* stopping mac may take upto 1msec */
+}
+
+/* set MAC address */
+void emac_mac_addr_clear(struct emac_adapter *adpt, u8 *addr)
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
+	sta = (((u32)addr[0]) << 8) | (((u32)addr[1]));
+	writel(sta, adpt->base + EMAC_MAC_STA_ADDR1);
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
+	size_t size;
+	int i;
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
+	struct emac_rx_queue *rx_q = &adpt->rx_q;
+	struct device *dev = adpt->netdev->dev.parent;
+	size_t size;
+	int i;
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
+	struct emac_rx_queue *rx_q = &adpt->rx_q;
+	struct emac_ring_header *ring_header = &adpt->ring_header;
+	unsigned long size;
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
+	unsigned int num_tx_descs = adpt->tx_desc_cnt;
+	unsigned int num_rx_descs = adpt->rx_desc_cnt;
+	struct device *dev = adpt->netdev->dev.parent;
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
+	ring_header->v_addr = dma_alloc_coherent(dev, ring_header->size,
+						 &ring_header->dma_addr,
+						 GFP_KERNEL);
+	if (!ring_header->v_addr)
+		return -ENOMEM;
+
+	memset(ring_header->v_addr, 0, ring_header->size);
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
+	int i;
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
+				   union emac_rfd *rfd)
+{
+	u32 *hw_rfd = EMAC_RFD(rx_q, adpt->rfd_size,
+			       rx_q->rfd.produce_idx);
+
+	*(hw_rfd++) = rfd->word[0];
+	*hw_rfd = rfd->word[1];
+
+	if (++rx_q->rfd.produce_idx == rx_q->rfd.count)
+		rx_q->rfd.produce_idx = 0;
+}
+
+/* Fill up receive queue's RFD with preallocated receive buffers */
+static int emac_mac_rx_descs_refill(struct emac_adapter *adpt,
+				    struct emac_rx_queue *rx_q)
+{
+	struct emac_buffer *curr_rxbuf;
+	struct emac_buffer *next_rxbuf;
+	union emac_rfd rfd;
+	struct sk_buff *skb;
+	void *skb_data = NULL;
+	int count = 0;
+	u32 next_produce_idx;
+
+	next_produce_idx = rx_q->rfd.produce_idx;
+	if (++next_produce_idx == rx_q->rfd.count)
+		next_produce_idx = 0;
+	curr_rxbuf = GET_RFD_BUFFER(rx_q, rx_q->rfd.produce_idx);
+	next_rxbuf = GET_RFD_BUFFER(rx_q, next_produce_idx);
+
+	/* this always has a blank rx_buffer*/
+	while (!next_rxbuf->dma_addr) {
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
+		rfd.addr = curr_rxbuf->dma_addr;
+		emac_mac_rx_rfd_create(adpt, rx_q, &rfd);
+		next_produce_idx = rx_q->rfd.produce_idx;
+		if (++next_produce_idx == rx_q->rfd.count)
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
+
+	return count;
+}
+
+/* Bringup the interface/HW */
+int emac_mac_up(struct emac_adapter *adpt)
+{
+	struct emac_phy *phy = &adpt->phy;
+	struct emac_irq	*irq = &adpt->irq;
+
+	struct net_device *netdev = adpt->netdev;
+	int ret = 0;
+	int i;
+
+	emac_mac_rx_tx_ring_reset_all(adpt);
+	emac_rx_mode_set(netdev);
+
+	emac_mac_config(adpt);
+
+	ret = emac_sgmii_up(adpt);
+
+	if (ret)
+		return ret;
+
+	for (i = 0; phy->uses_gpios && i < EMAC_GPIO_CNT; i++) {
+		ret = gpio_request(adpt->gpio[i], emac_gpio_name[i]);
+		if (ret) {
+			netdev_err(adpt->netdev,
+				   "error:%d on gpio_request(%d:%s)\n",
+				   ret, adpt->gpio[i], emac_gpio_name[i]);
+			while (--i >= 0)
+				gpio_free(adpt->gpio[i]);
+			goto err_request_gpio;
+		}
+	}
+
+	ret = request_irq(irq->irq, emac_isr, 0, EMAC_MAC_IRQ_RES, irq);
+	if (ret) {
+		netdev_err(adpt->netdev,
+			   "error:%d on request_irq(%d:%s flags:0)\n", ret,
+			   irq->irq, EMAC_MAC_IRQ_RES);
+		goto err_request_irq;
+	}
+
+	emac_mac_rx_descs_refill(adpt, &adpt->rx_q);
+
+	napi_enable(&adpt->rx_q.napi);
+
+	/* enable mac irq */
+	writel(~DIS_INT, adpt->base + EMAC_INT_STATUS);
+	writel(adpt->irq.mask, adpt->base + EMAC_INT_MASK);
+
+	netif_start_queue(netdev);
+	clear_bit(EMAC_STATUS_DOWN, &adpt->status);
+
+	/* check link status */
+	set_bit(EMAC_STATUS_TASK_LSC_REQ, &adpt->status);
+	adpt->link_chk_timeout = jiffies + EMAC_TRY_LINK_TIMEOUT;
+	mod_timer(&adpt->timers, jiffies);
+
+	return ret;
+
+err_request_irq:
+	for (i = 0; adpt->phy.uses_gpios && i < EMAC_GPIO_CNT; i++)
+		gpio_free(adpt->gpio[i]);
+err_request_gpio:
+	emac_sgmii_down(adpt);
+	return ret;
+}
+
+/* Bring down the interface/HW */
+void emac_mac_down(struct emac_adapter *adpt, bool reset)
+{
+	struct net_device *netdev = adpt->netdev;
+	struct emac_phy *phy = &adpt->phy;
+
+	unsigned long flags;
+	int i;
+
+	set_bit(EMAC_STATUS_DOWN, &adpt->status);
+
+	netif_stop_queue(netdev);
+	netif_carrier_off(netdev);
+
+	/* disable mac irq */
+	writel(DIS_INT, adpt->base + EMAC_INT_STATUS);
+	writel(0, adpt->base + EMAC_INT_MASK);
+	synchronize_irq(adpt->irq.irq);
+
+	napi_disable(&adpt->rx_q.napi);
+
+	emac_sgmii_down(adpt);
+
+	free_irq(adpt->irq.irq, &adpt->irq);
+
+	for (i = 0; phy->uses_gpios && i < EMAC_GPIO_CNT; i++)
+		gpio_free(adpt->gpio[i]);
+
+	clear_bit(EMAC_STATUS_TASK_LSC_REQ, &adpt->status);
+	clear_bit(EMAC_STATUS_TASK_REINIT_REQ, &adpt->status);
+	clear_bit(EMAC_STATUS_TASK_CHK_SGMII_REQ, &adpt->status);
+	del_timer_sync(&adpt->timers);
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
+	pm_runtime_put_noidle(netdev->dev.parent);
+	phy->link_speed = EMAC_LINK_SPEED_UNKNOWN;
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
+	u32 *hw_rrd = EMAC_RRD(rx_q, adpt->rrd_size,
+			       rx_q->rrd.consume_idx);
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
+	u32 tmp_tpd;
+	u32 *hw_tpd = EMAC_TPD(tx_q, adpt->tpd_size,
+			     tx_q->tpd.last_produce_idx);
+
+	tmp_tpd = *(hw_tpd + 1);
+	tmp_tpd |= EMAC_TPD_LAST_FRAGMENT;
+	*(hw_tpd + 1) = tmp_tpd;
+}
+
+void emac_tx_tpd_ts_save(struct emac_adapter *adpt, struct emac_tx_queue *tx_q)
+{
+	u32 tmp_tpd;
+	u32 *hw_tpd = EMAC_TPD(tx_q, adpt->tpd_size,
+			       tx_q->tpd.last_produce_idx);
+
+	tmp_tpd = *(hw_tpd + 3);
+	tmp_tpd |= EMAC_TPD_TSTAMP_SAVE;
+	*(hw_tpd + 3) = tmp_tpd;
+}
+
+static void emac_rx_rfd_clean(struct emac_rx_queue *rx_q,
+			      struct emac_rrd *rrd)
+{
+	struct emac_buffer *rfbuf = rx_q->rfd.rfbuff;
+	u32 consume_idx = RRD_SI(rrd);
+	int i;
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
+	if (test_bit(EMAC_STATUS_DOWN, &adpt->status))
+		return;
+
+	if (schedule_work(&adpt->tx_ts_task))
+		adpt->tx_ts_stats.sched++;
+}
+
+void emac_mac_tx_ts_periodic_routine(struct work_struct *work)
+{
+	struct emac_adapter *adpt = container_of(work, struct emac_adapter,
+						 tx_ts_task);
+	struct sk_buff *skb;
+	struct sk_buff_head q;
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
+	struct net_device *netdev  = adpt->netdev;
+
+	struct emac_rrd rrd;
+	struct emac_buffer *rfbuf;
+	struct sk_buff *skb;
+
+	u32 hw_consume_idx, num_consume_pkts;
+	unsigned int count = 0;
+	u32 proc_idx;
+	u32 reg = readl_relaxed(adpt->base + rx_q->consume_reg);
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
+			skb->ip_summed = (RRD_L4F(&rrd) ?
+					  CHECKSUM_NONE : CHECKSUM_UNNECESSARY);
+		else
+			skb_checksum_none_assert(skb);
+
+		if (test_bit(EMAC_STATUS_TS_RX_EN, &adpt->status)) {
+			struct skb_shared_hwtstamps *hwts = skb_hwtstamps(skb);
+
+			hwts->hwtstamp = ktime_set(RRD_TS_HI(&rrd),
+						   RRD_TS_LOW(&rrd));
+		}
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
+	struct emac_buffer *tpbuf;
+	u32 hw_consume_idx;
+	u32 pkts_compl = 0, bytes_compl = 0;
+	u32 reg = readl_relaxed(adpt->base + tx_q->consume_reg);
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
+	if (pkts_compl || bytes_compl)
+		netdev_completed_queue(adpt->netdev, pkts_compl, bytes_compl);
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
+	u32 num_required = 1;
+	int i;
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
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
+		num_required++;
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
+	u8  hdr_len;
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
+		u8 css, cso;
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
+	struct emac_buffer *tpbuf = NULL;
+	u16 nr_frags = skb_shinfo(skb)->nr_frags;
+	u32 len = skb_headlen(skb);
+	u16 map_len = 0;
+	u16 mapped_len = 0;
+	u16 hdr_len = 0;
+	int i;
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
+		TPD_BUFFER_ADDR_L_SET(tpd, EMAC_DMA_ADDR_LO(tpbuf->dma_addr));
+		TPD_BUFFER_ADDR_H_SET(tpd, EMAC_DMA_ADDR_HI(tpbuf->dma_addr));
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
+		TPD_BUFFER_ADDR_L_SET(tpd, EMAC_DMA_ADDR_LO(tpbuf->dma_addr));
+		TPD_BUFFER_ADDR_H_SET(tpd, EMAC_DMA_ADDR_HI(tpbuf->dma_addr));
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
+		TPD_BUFFER_ADDR_L_SET(tpd, EMAC_DMA_ADDR_LO(tpbuf->dma_addr));
+		TPD_BUFFER_ADDR_H_SET(tpd, EMAC_DMA_ADDR_HI(tpbuf->dma_addr));
+		TPD_BUF_LEN_SET(tpd, tpbuf->length);
+		emac_tx_tpd_create(adpt, tx_q, tpd);
+	}
+
+	/* The last tpd */
+	emac_tx_tpd_mark_last(adpt, tx_q);
+
+	if (test_bit(EMAC_STATUS_TS_TX_EN, &adpt->status) &&
+	    (skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)) {
+		struct sk_buff *skb_ts = skb_clone(skb, GFP_ATOMIC);
+
+		if (likely(skb_ts)) {
+			unsigned long flags;
+
+			emac_tx_tpd_ts_save(adpt, tx_q);
+			skb_ts->sk = skb->sk;
+			EMAC_SKB_CB(skb_ts)->tpd_idx =
+				tx_q->tpd.last_produce_idx;
+			EMAC_SKB_CB(skb_ts)->jiffies = get_jiffies_64();
+			skb_shinfo(skb_ts)->tx_flags |= SKBTX_IN_PROGRESS;
+			spin_lock_irqsave(&adpt->tx_ts_lock, flags);
+			if (adpt->tx_ts_pending_queue.qlen >=
+			    EMAC_TX_POLL_HWTXTSTAMP_THRESHOLD) {
+				emac_tx_ts_poll(adpt);
+				adpt->tx_ts_stats.tx_poll++;
+			}
+			__skb_queue_tail(&adpt->tx_ts_pending_queue,
+					 skb_ts);
+			spin_unlock_irqrestore(&adpt->tx_ts_lock, flags);
+			adpt->tx_ts_stats.tx++;
+			emac_schedule_tx_ts_task(adpt);
+		}
+	}
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
+	if (test_bit(EMAC_STATUS_DOWN, &adpt->status)) {
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
+	}
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
index 0000000..23dcdb8
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/emac/emac-mac.h
@@ -0,0 +1,286 @@
+/* Copyright (c) 2013-2015, The Linux Foundation. All rights reserved.
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
+enum emac_mac_speed {
+	emac_mac_speed_0 = 0,
+	emac_mac_speed_10_100 = 1,
+	emac_mac_speed_1000 = 2
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
+#define BITS_MASK(idx, n_bits) (((((unsigned long)1) << (n_bits)) - 1) << (idx))
+#define BITS_GET(val, idx, n_bits) (((val) & BITS_MASK(idx, n_bits)) >> idx)
+#define BITS_SET(val, idx, n_bits, new_val)				\
+	((val) = (((val) & (~BITS_MASK(idx, n_bits))) |			\
+		(((new_val) << (idx)) & BITS_MASK(idx, n_bits))))
+
+/* RRD (Receive Return Descriptor) */
+struct emac_rrd {
+	u32	word[6];
+
+/* number of RFD */
+#define RRD_NOR(rrd)			BITS_GET((rrd)->word[0], 16, 4)
+/* start consumer index of rfd-ring */
+#define RRD_SI(rrd)			BITS_GET((rrd)->word[0], 20, 12)
+/* vlan-tag (CVID, CFI and PRI) */
+#define RRD_CVALN_TAG(rrd)		BITS_GET((rrd)->word[2], 0, 16)
+/* length of the packet */
+#define RRD_PKT_SIZE(rrd)		BITS_GET((rrd)->word[3], 0, 14)
+/* L4(TCP/UDP) checksum failed */
+#define RRD_L4F(rrd)			BITS_GET((rrd)->word[3], 14, 1)
+/* vlan tagged */
+#define RRD_CVTAG(rrd)			BITS_GET((rrd)->word[3], 16, 1)
+/* When set, indicates that the descriptor is updated by the IP core.
+ * When cleared, indicates that the descriptor is invalid.
+ */
+#define RRD_UPDT(rrd)			BITS_GET((rrd)->word[3], 31, 1)
+#define RRD_UPDT_SET(rrd, val)		BITS_SET((rrd)->word[3], 31, 1, val)
+/* timestamp low */
+#define RRD_TS_LOW(rrd)			BITS_GET((rrd)->word[4], 0, 30)
+/* timestamp high */
+#define RRD_TS_HI(rrd)			((rrd)->word[5])
+};
+
+/* RFD (Receive Free Descriptor) */
+union emac_rfd {
+	u64	addr;
+	u32	word[2];
+};
+
+/* TPD (Transmit Packet Descriptor) */
+struct emac_tpd {
+	u32				word[4];
+
+/* Number of bytes of the transmit packet. (include 4-byte CRC) */
+#define TPD_BUF_LEN_SET(tpd, val)	BITS_SET((tpd)->word[0], 0, 16, val)
+/* Custom Checksum Offload: When set, ask IP core to offload custom checksum */
+#define TPD_CSX_SET(tpd, val)		BITS_SET((tpd)->word[1], 8, 1, val)
+/* TCP Large Send Offload: When set, ask IP core to do offload TCP Large Send */
+#define TPD_LSO(tpd)			BITS_GET((tpd)->word[1], 12, 1)
+#define TPD_LSO_SET(tpd, val)		BITS_SET((tpd)->word[1], 12, 1, val)
+/*  Large Send Offload Version: When set, indicates this is an LSOv2
+ * (for both IPv4 and IPv6). When cleared, indicates this is an LSOv1
+ * (only for IPv4).
+ */
+#define TPD_LSOV_SET(tpd, val)		BITS_SET((tpd)->word[1], 13, 1, val)
+/* IPv4 packet: When set, indicates this is an  IPv4 packet, this bit is only
+ * for LSOV2 format.
+ */
+#define TPD_IPV4_SET(tpd, val)		BITS_SET((tpd)->word[1], 16, 1, val)
+/* 0: Ethernet   frame (DA+SA+TYPE+DATA+CRC)
+ * 1: IEEE 802.3 frame (DA+SA+LEN+DSAP+SSAP+CTL+ORG+TYPE+DATA+CRC)
+ */
+#define TPD_TYP_SET(tpd, val)		BITS_SET((tpd)->word[1], 17, 1, val)
+/* Low-32bit Buffer Address */
+#define TPD_BUFFER_ADDR_L_SET(tpd, val)	((tpd)->word[2] = (val))
+/* CVLAN Tag to be inserted if INS_VLAN_TAG is set, CVLAN TPID based on global
+ * register configuration.
+ */
+#define TPD_CVLAN_TAG_SET(tpd, val)	BITS_SET((tpd)->word[3], 0, 16, val)
+/*  Insert CVlan Tag: When set, ask MAC to insert CVLAN TAG to outgoing packet
+ */
+#define TPD_INSTC_SET(tpd, val)		BITS_SET((tpd)->word[3], 17, 1, val)
+/* High-14bit Buffer Address, So, the 64b-bit address is
+ * {DESC_CTRL_11_TX_DATA_HIADDR[17:0],(register) BUFFER_ADDR_H, BUFFER_ADDR_L}
+ */
+#define TPD_BUFFER_ADDR_H_SET(tpd, val)	BITS_SET((tpd)->word[3], 18, 13, val)
+/* Format D. Word offset from the 1st byte of this packet to start to calculate
+ * the custom checksum.
+ */
+#define TPD_PAYLOAD_OFFSET_SET(tpd, val) BITS_SET((tpd)->word[1], 0, 8, val)
+/*  Format D. Word offset from the 1st byte of this packet to fill the custom
+ * checksum to
+ */
+#define TPD_CXSUM_OFFSET_SET(tpd, val)	BITS_SET((tpd)->word[1], 18, 8, val)
+
+/* Format C. TCP Header offset from the 1st byte of this packet. (byte unit) */
+#define TPD_TCPHDR_OFFSET_SET(tpd, val)	BITS_SET((tpd)->word[1], 0, 8, val)
+/* Format C. MSS (Maximum Segment Size) got from the protocol layer. (byte unit)
+ */
+#define TPD_MSS_SET(tpd, val)		BITS_SET((tpd)->word[1], 18, 13, val)
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
+	dma_addr_t		dma_addr;		/* physical address */
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
+void emac_mac_addr_clear(struct emac_adapter *adpt, u8 *addr);
+void emac_mac_pm(struct emac_adapter *adpt);
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
index 0000000..ef51b537
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/emac/emac-phy.c
@@ -0,0 +1,486 @@
+/* Copyright (c) 2013-2015, The Linux Foundation. All rights reserved.
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
+#include <linux/pm_runtime.h>
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
+/* EMAC_MDIO_EX_CTRL */
+#define DEVAD_BMSK                                            0x1f0000
+#define DEVAD_SHFT                                                  16
+#define EX_REG_ADDR_BMSK                                        0xffff
+#define EX_REG_ADDR_SHFT                                             0
+
+#define MDIO_CLK_25_4                                                0
+#define MDIO_CLK_25_28                                               7
+
+#define MDIO_WAIT_TIMES                                           1000
+
+/* PHY */
+#define MII_PSSR                          0x11 /* PHY Specific Status Reg */
+
+/* MII_BMCR (0x00) */
+#define BMCR_SPEED10                    0x0000
+
+/* MII_PSSR (0x11) */
+#define PSSR_SPD_DPLX_RESOLVED          0x0800  /* 1=Speed & Duplex resolved */
+#define PSSR_DPLX                       0x2000  /* 1=Duplex 0=Half Duplex */
+#define PSSR_SPEED                      0xC000  /* Speed, bits 14:15 */
+#define PSSR_10MBS                      0x0000  /* 00=10Mbs */
+#define PSSR_100MBS                     0x4000  /* 01=100Mbs */
+#define PSSR_1000MBS                    0x8000  /* 10=1000Mbs */
+
+#define EMAC_LINK_SPEED_DEFAULT (\
+		EMAC_LINK_SPEED_10_HALF  |\
+		EMAC_LINK_SPEED_10_FULL  |\
+		EMAC_LINK_SPEED_100_HALF |\
+		EMAC_LINK_SPEED_100_FULL |\
+		EMAC_LINK_SPEED_1GB_FULL)
+
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
+static void emac_phy_mdio_autopoll_enable(struct emac_adapter *adpt)
+{
+	emac_reg_update32(adpt->base + EMAC_MDIO_CTRL, 0, MDIO_AP_EN);
+}
+
+int emac_phy_read_reg(struct emac_adapter *adpt, bool ext, u8 dev, bool fast,
+		      u16 reg_addr, u16 *phy_data)
+{
+	struct emac_phy *phy = &adpt->phy;
+	u32 clk_sel, val = 0;
+	int ret = 0;
+
+	*phy_data = 0;
+	clk_sel = fast ? MDIO_CLK_25_4 : MDIO_CLK_25_28;
+
+	if (phy->external) {
+		ret = emac_phy_mdio_autopoll_disable(adpt);
+		if (ret)
+			return ret;
+	}
+	/* set PHY address */
+	emac_reg_update32(adpt->base + EMAC_PHY_STS, PHY_ADDR_BMSK,
+			  (dev << PHY_ADDR_SHFT));
+
+	if (ext) {
+		val = ((dev << DEVAD_SHFT) & DEVAD_BMSK) |
+		      ((reg_addr << EX_REG_ADDR_SHFT) & EX_REG_ADDR_BMSK);
+		writel(val, adpt->base + EMAC_MDIO_EX_CTRL);
+
+		val = SUP_PREAMBLE |
+		      ((clk_sel << MDIO_CLK_SEL_SHFT) & MDIO_CLK_SEL_BMSK) |
+		      MDIO_START | MDIO_MODE | MDIO_RD_NWR;
+	} else {
+		val = val & ~(MDIO_REG_ADDR_BMSK | MDIO_CLK_SEL_BMSK |
+				MDIO_MODE | MDIO_PR);
+		val = SUP_PREAMBLE |
+		      ((clk_sel << MDIO_CLK_SEL_SHFT) & MDIO_CLK_SEL_BMSK) |
+		      ((reg_addr << MDIO_REG_ADDR_SHFT) & MDIO_REG_ADDR_BMSK) |
+		      MDIO_START | MDIO_RD_NWR;
+	}
+
+	writel(val, adpt->base + EMAC_MDIO_CTRL);
+
+	if (readl_poll_timeout(adpt->base + EMAC_MDIO_CTRL, val,
+			       !(val & (MDIO_START | MDIO_BUSY)),
+			       100, MDIO_WAIT_TIMES * 100))
+		ret = -EIO;
+	else
+		*phy_data = ((val >> MDIO_DATA_SHFT) & MDIO_DATA_BMSK);
+
+	if (phy->external)
+		emac_phy_mdio_autopoll_enable(adpt);
+
+	return ret;
+}
+
+int emac_phy_write_reg(struct emac_adapter *adpt, bool ext, u8 dev, bool fast,
+		       u16 reg_addr, u16 phy_data)
+{
+	struct emac_phy *phy = &adpt->phy;
+	u32 clk_sel, val = 0;
+	int ret = 0;
+
+	clk_sel = fast ? MDIO_CLK_25_4 : MDIO_CLK_25_28;
+
+	if (phy->external) {
+		ret = emac_phy_mdio_autopoll_disable(adpt);
+		if (ret)
+			return ret;
+	}
+
+	/* set PHY address */
+	emac_reg_update32(adpt->base + EMAC_PHY_STS, PHY_ADDR_BMSK,
+			  (dev << PHY_ADDR_SHFT));
+
+	if (ext) {
+		val = ((dev << DEVAD_SHFT) & DEVAD_BMSK) |
+		      ((reg_addr << EX_REG_ADDR_SHFT) & EX_REG_ADDR_BMSK);
+		writel(val, adpt->base + EMAC_MDIO_EX_CTRL);
+
+		val = SUP_PREAMBLE |
+			((clk_sel << MDIO_CLK_SEL_SHFT) & MDIO_CLK_SEL_BMSK) |
+			((phy_data << MDIO_DATA_SHFT) & MDIO_DATA_BMSK) |
+			MDIO_START | MDIO_MODE;
+	} else {
+		val = val & ~(MDIO_REG_ADDR_BMSK | MDIO_CLK_SEL_BMSK |
+			MDIO_DATA_BMSK | MDIO_MODE | MDIO_PR);
+		val = SUP_PREAMBLE |
+		((clk_sel << MDIO_CLK_SEL_SHFT) & MDIO_CLK_SEL_BMSK) |
+		((reg_addr << MDIO_REG_ADDR_SHFT) & MDIO_REG_ADDR_BMSK) |
+		((phy_data << MDIO_DATA_SHFT) & MDIO_DATA_BMSK) |
+		MDIO_START;
+	}
+
+	writel(val, adpt->base + EMAC_MDIO_CTRL);
+
+	if (readl_poll_timeout(adpt->base + EMAC_MDIO_CTRL, val,
+			       !(val & (MDIO_START | MDIO_BUSY)), 100,
+			       MDIO_WAIT_TIMES * 100))
+		ret = -EIO;
+
+	if (phy->external)
+		emac_phy_mdio_autopoll_enable(adpt);
+
+	return ret;
+}
+
+int emac_phy_read(struct emac_adapter *adpt, u16 phy_addr, u16 reg_addr,
+		  u16 *phy_data)
+{
+	struct emac_phy *phy = &adpt->phy;
+	int  ret;
+
+	mutex_lock(&phy->lock);
+	ret = emac_phy_read_reg(adpt, false, phy_addr, true, reg_addr,
+				phy_data);
+	mutex_unlock(&phy->lock);
+
+	if (ret)
+		netdev_err(adpt->netdev, "error: reading phy reg 0x%02x\n",
+			   reg_addr);
+	else
+		netif_dbg(adpt,  hw, adpt->netdev,
+			  "EMAC PHY RD: 0x%02x -> 0x%04x\n", reg_addr,
+			  *phy_data);
+
+	return ret;
+}
+
+int emac_phy_write(struct emac_adapter *adpt, u16 phy_addr, u16 reg_addr,
+		   u16 phy_data)
+{
+	struct emac_phy *phy = &adpt->phy;
+	int  ret;
+
+	mutex_lock(&phy->lock);
+	ret = emac_phy_write_reg(adpt, false, phy_addr, true, reg_addr,
+				 phy_data);
+	mutex_unlock(&phy->lock);
+
+	if (ret)
+		netdev_err(adpt->netdev, "error: writing phy reg 0x%02x\n",
+			   reg_addr);
+	else
+		netif_dbg(adpt, hw,
+			  adpt->netdev, "EMAC PHY WR: 0x%02x <- 0x%04x\n",
+			  reg_addr, phy_data);
+
+	return ret;
+}
+
+/* initialize external phy */
+int emac_phy_external_init(struct emac_adapter *adpt)
+{
+	struct emac_phy *phy = &adpt->phy;
+	u16 phy_id[2];
+	int ret = 0;
+
+	if (phy->external) {
+		ret = emac_phy_read(adpt, phy->addr, MII_PHYSID1, &phy_id[0]);
+		if (ret)
+			return ret;
+
+		ret = emac_phy_read(adpt, phy->addr, MII_PHYSID2, &phy_id[1]);
+		if (ret)
+			return ret;
+
+		phy->id[0] = phy_id[0];
+		phy->id[1] = phy_id[1];
+	} else {
+		emac_phy_mdio_autopoll_disable(adpt);
+	}
+
+	return 0;
+}
+
+static int emac_phy_link_setup_external(struct emac_adapter *adpt,
+					enum emac_flow_ctrl req_fc_mode,
+					u32 speed, bool autoneg, bool fc)
+{
+	struct emac_phy *phy = &adpt->phy;
+	u16 adv, bmcr, ctrl1000 = 0;
+	int ret = 0;
+
+	if (autoneg) {
+		switch (req_fc_mode) {
+		case EMAC_FC_FULL:
+		case EMAC_FC_RX_PAUSE:
+			adv = ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
+			break;
+		case EMAC_FC_TX_PAUSE:
+			adv = ADVERTISE_PAUSE_ASYM;
+			break;
+		default:
+			adv = 0;
+			break;
+		}
+		if (!fc)
+			adv &= ~(ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM);
+
+		if (speed & EMAC_LINK_SPEED_10_HALF)
+			adv |= ADVERTISE_10HALF;
+
+		if (speed & EMAC_LINK_SPEED_10_FULL)
+			adv |= ADVERTISE_10HALF | ADVERTISE_10FULL;
+
+		if (speed & EMAC_LINK_SPEED_100_HALF)
+			adv |= ADVERTISE_100HALF;
+
+		if (speed & EMAC_LINK_SPEED_100_FULL)
+			adv |= ADVERTISE_100HALF | ADVERTISE_100FULL;
+
+		if (speed & EMAC_LINK_SPEED_1GB_FULL)
+			ctrl1000 |= ADVERTISE_1000FULL;
+
+		ret |= emac_phy_write(adpt, phy->addr, MII_ADVERTISE, adv);
+		ret |= emac_phy_write(adpt, phy->addr, MII_CTRL1000, ctrl1000);
+
+		bmcr = BMCR_RESET | BMCR_ANENABLE | BMCR_ANRESTART;
+		ret |= emac_phy_write(adpt, phy->addr, MII_BMCR, bmcr);
+	} else {
+		bmcr = BMCR_RESET;
+		switch (speed) {
+		case EMAC_LINK_SPEED_10_HALF:
+			bmcr |= BMCR_SPEED10;
+			break;
+		case EMAC_LINK_SPEED_10_FULL:
+			bmcr |= BMCR_SPEED10 | BMCR_FULLDPLX;
+			break;
+		case EMAC_LINK_SPEED_100_HALF:
+			bmcr |= BMCR_SPEED100;
+			break;
+		case EMAC_LINK_SPEED_100_FULL:
+			bmcr |= BMCR_SPEED100 | BMCR_FULLDPLX;
+			break;
+		default:
+			return -EINVAL;
+		}
+
+		ret |= emac_phy_write(adpt, phy->addr, MII_BMCR, bmcr);
+	}
+
+	return ret;
+}
+
+int emac_phy_link_setup(struct emac_adapter *adpt, u32 speed, bool autoneg,
+			bool fc)
+{
+	struct emac_phy *phy = &adpt->phy;
+	int ret = 0;
+
+	if (!phy->external)
+		return emac_sgmii_no_ephy_link_setup(adpt, speed, autoneg);
+
+	if (emac_phy_link_setup_external(adpt, phy->req_fc_mode, speed, autoneg,
+					 fc)) {
+		netdev_err(adpt->netdev,
+			   "error: on ephy setup speed:%d autoneg:%d fc:%d\n",
+			   speed, autoneg, fc);
+		ret = -EINVAL;
+	} else {
+		phy->autoneg = autoneg;
+	}
+
+	return ret;
+}
+
+int emac_phy_link_check(struct emac_adapter *adpt, u32 *speed, bool *link_up)
+{
+	struct emac_phy *phy = &adpt->phy;
+	u16 bmsr, pssr;
+	int ret;
+
+	if (!phy->external) {
+		emac_sgmii_no_ephy_link_check(adpt, speed, link_up);
+		return 0;
+	}
+
+	ret = emac_phy_read(adpt, phy->addr, MII_BMSR, &bmsr);
+	if (ret)
+		return ret;
+
+	if (!(bmsr & BMSR_LSTATUS)) {
+		*link_up = false;
+		*speed = EMAC_LINK_SPEED_UNKNOWN;
+		return 0;
+	}
+	*link_up = true;
+	ret = emac_phy_read(adpt, phy->addr, MII_PSSR, &pssr);
+	if (ret)
+		return ret;
+
+	if (!(pssr & PSSR_SPD_DPLX_RESOLVED)) {
+		netdev_err(adpt->netdev, "error: speed duplex resolved\n");
+		return -EINVAL;
+	}
+
+	switch (pssr & PSSR_SPEED) {
+	case PSSR_1000MBS:
+		if (pssr & PSSR_DPLX)
+			*speed = EMAC_LINK_SPEED_1GB_FULL;
+		else
+			netdev_err(adpt->netdev,
+				   "error: 1000M half duplex is invalid");
+		break;
+	case PSSR_100MBS:
+		if (pssr & PSSR_DPLX)
+			*speed = EMAC_LINK_SPEED_100_FULL;
+		else
+			*speed = EMAC_LINK_SPEED_100_HALF;
+		break;
+	case PSSR_10MBS:
+		if (pssr & PSSR_DPLX)
+			*speed = EMAC_LINK_SPEED_10_FULL;
+		else
+			*speed = EMAC_LINK_SPEED_10_HALF;
+		break;
+	default:
+		*speed = EMAC_LINK_SPEED_UNKNOWN;
+		ret = -EINVAL;
+		break;
+	}
+
+	return ret;
+}
+
+/* Read speed off the LPA (Link Partner Ability) register */
+void emac_phy_link_speed_get(struct emac_adapter *adpt, u32 *speed)
+{
+	struct emac_phy *phy = &adpt->phy;
+	int ret;
+	u16 lpa, stat1000;
+	bool link;
+
+	if (!phy->external) {
+		emac_sgmii_no_ephy_link_check(adpt, speed, &link);
+		return;
+	}
+
+	ret = emac_phy_read(adpt, phy->addr, MII_LPA, &lpa);
+	ret |= emac_phy_read(adpt, phy->addr, MII_STAT1000, &stat1000);
+	if (ret)
+		return;
+
+	*speed = EMAC_LINK_SPEED_10_HALF;
+	if (lpa & LPA_10FULL)
+		*speed = EMAC_LINK_SPEED_10_FULL;
+	else if (lpa & LPA_10HALF)
+		*speed = EMAC_LINK_SPEED_10_HALF;
+	else if (lpa & LPA_100FULL)
+		*speed = EMAC_LINK_SPEED_100_FULL;
+	else if (lpa & LPA_100HALF)
+		*speed = EMAC_LINK_SPEED_100_HALF;
+	else if (stat1000 & LPA_1000FULL)
+		*speed = EMAC_LINK_SPEED_1GB_FULL;
+}
+
+/* Read phy configuration and initialize it */
+int emac_phy_config(struct platform_device *pdev, struct emac_adapter *adpt)
+{
+	struct emac_phy *phy = &adpt->phy;
+	struct device_node *dt = pdev->dev.of_node;
+	int ret;
+
+	phy->external = !of_property_read_bool(dt, "qcom,no-external-phy");
+
+	/* get phy address on MDIO bus */
+	if (phy->external) {
+		ret = of_property_read_u32(dt, "phy-addr", &phy->addr);
+		if (ret)
+			return ret;
+	} else {
+		phy->uses_gpios = false;
+	}
+
+	ret = emac_sgmii_config(pdev, adpt);
+	if (ret)
+		return ret;
+
+	mutex_init(&phy->lock);
+
+	phy->autoneg = true;
+	phy->autoneg_advertised = EMAC_LINK_SPEED_DEFAULT;
+
+	return emac_sgmii_init(adpt);
+}
diff --git a/drivers/net/ethernet/qualcomm/emac/emac-phy.h b/drivers/net/ethernet/qualcomm/emac/emac-phy.h
new file mode 100644
index 0000000..c40e1db
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/emac/emac-phy.h
@@ -0,0 +1,69 @@
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
+enum emac_flow_ctrl {
+	EMAC_FC_NONE,
+	EMAC_FC_RX_PAUSE,
+	EMAC_FC_TX_PAUSE,
+	EMAC_FC_FULL,
+	EMAC_FC_DEFAULT
+};
+
+/* emac_phy
+ * @base register file base address space.
+ * @irq phy interrupt number.
+ * @external true when external phy is used.
+ * @addr mii address.
+ * @id vendor id.
+ * @cur_fc_mode flow control mode in effect.
+ * @req_fc_mode flow control mode requested by caller.
+ * @disable_fc_autoneg Do not auto-negotiate flow control.
+ */
+struct emac_phy {
+	void __iomem			*base;
+	int				irq;
+
+	bool				external;
+	bool				uses_gpios;
+	u32				addr;
+	u16				id[2];
+	bool				autoneg;
+	u32				autoneg_advertised;
+	u32				link_speed;
+	bool				link_up;
+	/* lock - synchronize access to mdio bus */
+	struct mutex			lock;
+
+	/* flow control configuration */
+	enum emac_flow_ctrl		cur_fc_mode;
+	enum emac_flow_ctrl		req_fc_mode;
+	bool				disable_fc_autoneg;
+};
+
+struct emac_adapter;
+struct platform_device;
+
+int  emac_phy_read(struct emac_adapter *adpt, u16 phy_addr, u16 reg_addr,
+		   u16 *phy_data);
+int  emac_phy_write(struct emac_adapter *adpt, u16 phy_addr, u16 reg_addr,
+		    u16 phy_data);
+int  emac_phy_config(struct platform_device *pdev, struct emac_adapter *adpt);
+int  emac_phy_external_init(struct emac_adapter *adpt);
+int  emac_phy_link_setup(struct emac_adapter *adpt, u32 speed, bool autoneg,
+			 bool fc);
+int  emac_phy_link_check(struct emac_adapter *adpt, u32 *speed, bool *link_up);
+void emac_phy_link_speed_get(struct emac_adapter *adpt, u32 *speed);
+
+#endif /* _EMAC_PHY_H_ */
diff --git a/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
new file mode 100644
index 0000000..2f6a2ff
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
@@ -0,0 +1,679 @@
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
+#define EMAC_QSERDES_COM_SYS_CLK_CTRL			    0x000000
+#define EMAC_QSERDES_COM_PLL_CNTRL			    0x000014
+#define EMAC_QSERDES_COM_PLL_IP_SETI			    0x000018
+#define EMAC_QSERDES_COM_PLL_CP_SETI			    0x000024
+#define EMAC_QSERDES_COM_PLL_IP_SETP			    0x000028
+#define EMAC_QSERDES_COM_PLL_CP_SETP			    0x00002c
+#define EMAC_QSERDES_COM_SYSCLK_EN_SEL			    0x000038
+#define EMAC_QSERDES_COM_RESETSM_CNTRL			    0x000040
+#define EMAC_QSERDES_COM_PLLLOCK_CMP1			    0x000044
+#define EMAC_QSERDES_COM_PLLLOCK_CMP2			    0x000048
+#define EMAC_QSERDES_COM_PLLLOCK_CMP3			    0x00004c
+#define EMAC_QSERDES_COM_PLLLOCK_CMP_EN			    0x000050
+#define EMAC_QSERDES_COM_DEC_START1			    0x000064
+#define EMAC_QSERDES_COM_DIV_FRAC_START1		    0x000098
+#define EMAC_QSERDES_COM_DIV_FRAC_START2		    0x00009c
+#define EMAC_QSERDES_COM_DIV_FRAC_START3		    0x0000a0
+#define EMAC_QSERDES_COM_DEC_START2			    0x0000a4
+#define EMAC_QSERDES_COM_PLL_CRCTRL			    0x0000ac
+#define EMAC_QSERDES_COM_RESET_SM			    0x0000bc
+#define EMAC_QSERDES_TX_BIST_MODE_LANENO		    0x000100
+#define EMAC_QSERDES_TX_TX_EMP_POST1_LVL		    0x000108
+#define EMAC_QSERDES_TX_TX_DRV_LVL			    0x00010c
+#define EMAC_QSERDES_TX_LANE_MODE			    0x000150
+#define EMAC_QSERDES_TX_TRAN_DRVR_EMP_EN		    0x000170
+#define EMAC_QSERDES_RX_CDR_CONTROL			    0x000200
+#define EMAC_QSERDES_RX_CDR_CONTROL2			    0x000210
+#define EMAC_QSERDES_RX_RX_EQ_GAIN12			    0x000230
+
+/* EMAC_SGMII register offsets */
+#define EMAC_SGMII_PHY_SERDES_START			    0x000300
+#define EMAC_SGMII_PHY_CMN_PWR_CTRL			    0x000304
+#define EMAC_SGMII_PHY_RX_PWR_CTRL			    0x000308
+#define EMAC_SGMII_PHY_TX_PWR_CTRL			    0x00030C
+#define EMAC_SGMII_PHY_LANE_CTRL1			    0x000318
+#define EMAC_SGMII_PHY_AUTONEG_CFG2			    0x000348
+#define EMAC_SGMII_PHY_CDR_CTRL0			    0x000358
+#define EMAC_SGMII_PHY_SPEED_CFG1			    0x000374
+#define EMAC_SGMII_PHY_POW_DWN_CTRL0			    0x000380
+#define EMAC_SGMII_PHY_RESET_CTRL			    0x0003a8
+#define EMAC_SGMII_PHY_IRQ_CMD				    0x0003ac
+#define EMAC_SGMII_PHY_INTERRUPT_CLEAR			    0x0003b0
+#define EMAC_SGMII_PHY_INTERRUPT_MASK			    0x0003b4
+#define EMAC_SGMII_PHY_INTERRUPT_STATUS			    0x0003b8
+#define EMAC_SGMII_PHY_RX_CHK_STATUS			    0x0003d4
+#define EMAC_SGMII_PHY_AUTONEG0_STATUS			    0x0003e0
+#define EMAC_SGMII_PHY_AUTONEG1_STATUS			    0x0003e4
+
+#define SGMII_CDR_MAX_CNT					0x0f
+
+#define QSERDES_PLL_IPSETI					0x01
+#define QSERDES_PLL_CP_SETI					0x3b
+#define QSERDES_PLL_IP_SETP					0x0a
+#define QSERDES_PLL_CP_SETP					0x09
+#define QSERDES_PLL_CRCTRL					0xfb
+#define QSERDES_PLL_DEC						0x02
+#define QSERDES_PLL_DIV_FRAC_START1				0x55
+#define QSERDES_PLL_DIV_FRAC_START2				0x2a
+#define QSERDES_PLL_DIV_FRAC_START3				0x03
+#define QSERDES_PLL_LOCK_CMP1					0x2b
+#define QSERDES_PLL_LOCK_CMP2					0x68
+#define QSERDES_PLL_LOCK_CMP3					0x00
+
+#define QSERDES_RX_CDR_CTRL1_THRESH				0x03
+#define QSERDES_RX_CDR_CTRL1_GAIN				0x02
+#define QSERDES_RX_CDR_CTRL2_THRESH				0x03
+#define QSERDES_RX_CDR_CTRL2_GAIN				0x04
+#define QSERDES_RX_EQ_GAIN2					0x0f
+#define QSERDES_RX_EQ_GAIN1					0x0f
+
+#define QSERDES_TX_BIST_MODE_LANENO				0x00
+#define QSERDES_TX_DRV_LVL					0x0f
+#define QSERDES_TX_EMP_POST1_LVL				0x01
+#define QSERDES_TX_LANE_MODE					0x08
+
+/* EMAC_QSERDES_COM_SYS_CLK_CTRL */
+#define SYSCLK_CM						0x10
+#define SYSCLK_AC_COUPLE					0x08
+
+/* EMAC_QSERDES_COM_PLL_CNTRL */
+#define OCP_EN							0x20
+#define PLL_DIV_FFEN						0x04
+#define PLL_DIV_ORD						0x02
+
+/* EMAC_QSERDES_COM_SYSCLK_EN_SEL */
+#define SYSCLK_SEL_CMOS						0x8
+
+/* EMAC_QSERDES_COM_RESETSM_CNTRL */
+#define FRQ_TUNE_MODE						0x10
+
+/* EMAC_QSERDES_COM_PLLLOCK_CMP_EN */
+#define PLLLOCK_CMP_EN						0x01
+
+/* EMAC_QSERDES_COM_DEC_START1 */
+#define DEC_START1_MUX						0x80
+
+/* EMAC_QSERDES_COM_DIV_FRAC_START1 */
+#define DIV_FRAC_START1_MUX					0x80
+
+/* EMAC_QSERDES_COM_DIV_FRAC_START2 */
+#define DIV_FRAC_START2_MUX					0x80
+
+/* EMAC_QSERDES_COM_DIV_FRAC_START3 */
+#define DIV_FRAC_START3_MUX					0x10
+
+/* EMAC_QSERDES_COM_DEC_START2 */
+#define DEC_START2_MUX						0x2
+#define DEC_START2						0x1
+
+/* EMAC_QSERDES_COM_RESET_SM */
+#define QSERDES_READY						0x20
+
+/* EMAC_QSERDES_TX_TX_EMP_POST1_LVL */
+#define TX_EMP_POST1_LVL_MUX					0x20
+#define TX_EMP_POST1_LVL_BMSK					0x1f
+#define TX_EMP_POST1_LVL_SHFT					0
+
+/* EMAC_QSERDES_TX_TX_DRV_LVL */
+#define TX_DRV_LVL_MUX						0x10
+#define TX_DRV_LVL_BMSK						0x0f
+#define TX_DRV_LVL_SHFT						   0
+
+/* EMAC_QSERDES_TX_TRAN_DRVR_EMP_EN */
+#define EMP_EN_MUX						0x02
+#define EMP_EN							0x01
+
+/* EMAC_QSERDES_RX_CDR_CONTROL & EMAC_QSERDES_RX_CDR_CONTROL2 */
+#define SECONDORDERENABLE					0x40
+#define FIRSTORDER_THRESH_BMSK					0x38
+#define FIRSTORDER_THRESH_SHFT					   3
+#define SECONDORDERGAIN_BMSK					0x07
+#define SECONDORDERGAIN_SHFT					   0
+
+/* EMAC_QSERDES_RX_RX_EQ_GAIN12 */
+#define RX_EQ_GAIN2_BMSK					0xf0
+#define RX_EQ_GAIN2_SHFT					   4
+#define RX_EQ_GAIN1_BMSK					0x0f
+#define RX_EQ_GAIN1_SHFT					   0
+
+/* EMAC_SGMII_PHY_SERDES_START */
+#define SERDES_START						0x01
+
+/* EMAC_SGMII_PHY_CMN_PWR_CTRL */
+#define BIAS_EN							0x40
+#define PLL_EN							0x20
+#define SYSCLK_EN						0x10
+#define CLKBUF_L_EN						0x08
+#define PLL_TXCLK_EN						0x02
+#define PLL_RXCLK_EN						0x01
+
+/* EMAC_SGMII_PHY_RX_PWR_CTRL */
+#define L0_RX_SIGDET_EN						0x80
+#define L0_RX_TERM_MODE_BMSK					0x30
+#define L0_RX_TERM_MODE_SHFT					   4
+#define L0_RX_I_EN						0x02
+
+/* EMAC_SGMII_PHY_TX_PWR_CTRL */
+#define L0_TX_EN						0x20
+#define L0_CLKBUF_EN						0x10
+#define L0_TRAN_BIAS_EN						0x02
+
+/* EMAC_SGMII_PHY_LANE_CTRL1 */
+#define L0_RX_EQ_EN						0x40
+#define L0_RESET_TSYNC_EN					0x10
+#define L0_DRV_LVL_BMSK						0x0f
+#define L0_DRV_LVL_SHFT						   0
+
+/* EMAC_SGMII_PHY_AUTONEG_CFG2 */
+#define FORCE_AN_TX_CFG						0x20
+#define FORCE_AN_RX_CFG						0x10
+#define AN_ENABLE						0x01
+
+/* EMAC_SGMII_PHY_SPEED_CFG1 */
+#define DUPLEX_MODE						0x10
+#define SPDMODE_1000						0x02
+#define SPDMODE_100						0x01
+#define SPDMODE_10						0x00
+#define SPDMODE_BMSK						0x03
+#define SPDMODE_SHFT						   0
+
+/* EMAC_SGMII_PHY_POW_DWN_CTRL0 */
+#define PWRDN_B							 0x01
+
+/* EMAC_SGMII_PHY_RESET_CTRL */
+#define PHY_SW_RESET						 0x01
+
+/* EMAC_SGMII_PHY_IRQ_CMD */
+#define IRQ_GLOBAL_CLEAR					 0x01
+
+/* EMAC_SGMII_PHY_INTERRUPT_MASK */
+#define DECODE_CODE_ERR					       BIT(7)
+#define DECODE_DISP_ERR					       BIT(6)
+#define PLL_UNLOCK					       BIT(5)
+#define AN_ILLEGAL_TERM					       BIT(4)
+#define SYNC_FAIL					       BIT(3)
+#define AN_START					       BIT(2)
+#define AN_END						       BIT(1)
+#define AN_REQUEST					       BIT(0)
+
+#define SGMII_PHY_IRQ_CLR_WAIT_TIME				   10
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
+	ulong		offset;
+#define END_MARKER	0xffffffff
+	u32		val;
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
+static const struct emac_reg_write physical_coding_sublayer_programming[] = {
+{EMAC_SGMII_PHY_CDR_CTRL0,	SGMII_CDR_MAX_CNT},
+{EMAC_SGMII_PHY_POW_DWN_CTRL0,	PWRDN_B},
+{EMAC_SGMII_PHY_CMN_PWR_CTRL,	BIAS_EN | SYSCLK_EN | CLKBUF_L_EN |
+				PLL_TXCLK_EN | PLL_RXCLK_EN},
+{EMAC_SGMII_PHY_TX_PWR_CTRL,	L0_TX_EN | L0_CLKBUF_EN | L0_TRAN_BIAS_EN},
+{EMAC_SGMII_PHY_RX_PWR_CTRL,	L0_RX_SIGDET_EN | (1 << L0_RX_TERM_MODE_SHFT) |
+				L0_RX_I_EN},
+{EMAC_SGMII_PHY_CMN_PWR_CTRL,	BIAS_EN | PLL_EN | SYSCLK_EN | CLKBUF_L_EN |
+				PLL_TXCLK_EN | PLL_RXCLK_EN},
+{EMAC_SGMII_PHY_LANE_CTRL1,	L0_RX_EQ_EN | L0_RESET_TSYNC_EN |
+				L0_DRV_LVL_BMSK},
+};
+
+static const struct emac_reg_write sysclk_refclk_setting[] = {
+{EMAC_QSERDES_COM_SYSCLK_EN_SEL,	SYSCLK_SEL_CMOS},
+{EMAC_QSERDES_COM_SYS_CLK_CTRL,		SYSCLK_CM | SYSCLK_AC_COUPLE},
+};
+
+static const struct emac_reg_write pll_setting[] = {
+{EMAC_QSERDES_COM_PLL_IP_SETI,		QSERDES_PLL_IPSETI},
+{EMAC_QSERDES_COM_PLL_CP_SETI,		QSERDES_PLL_CP_SETI},
+{EMAC_QSERDES_COM_PLL_IP_SETP,		QSERDES_PLL_IP_SETP},
+{EMAC_QSERDES_COM_PLL_CP_SETP,		QSERDES_PLL_CP_SETP},
+{EMAC_QSERDES_COM_PLL_CRCTRL,		QSERDES_PLL_CRCTRL},
+{EMAC_QSERDES_COM_PLL_CNTRL,		OCP_EN | PLL_DIV_FFEN | PLL_DIV_ORD},
+{EMAC_QSERDES_COM_DEC_START1,		DEC_START1_MUX | QSERDES_PLL_DEC},
+{EMAC_QSERDES_COM_DEC_START2,		DEC_START2_MUX | DEC_START2},
+{EMAC_QSERDES_COM_DIV_FRAC_START1,	DIV_FRAC_START1_MUX |
+					QSERDES_PLL_DIV_FRAC_START1},
+{EMAC_QSERDES_COM_DIV_FRAC_START2,	DIV_FRAC_START2_MUX |
+					QSERDES_PLL_DIV_FRAC_START2},
+{EMAC_QSERDES_COM_DIV_FRAC_START3,	DIV_FRAC_START3_MUX |
+					QSERDES_PLL_DIV_FRAC_START3},
+{EMAC_QSERDES_COM_PLLLOCK_CMP1,		QSERDES_PLL_LOCK_CMP1},
+{EMAC_QSERDES_COM_PLLLOCK_CMP2,		QSERDES_PLL_LOCK_CMP2},
+{EMAC_QSERDES_COM_PLLLOCK_CMP3,		QSERDES_PLL_LOCK_CMP3},
+{EMAC_QSERDES_COM_PLLLOCK_CMP_EN,	PLLLOCK_CMP_EN},
+{EMAC_QSERDES_COM_RESETSM_CNTRL,	FRQ_TUNE_MODE},
+};
+
+static const struct emac_reg_write cdr_setting[] = {
+{EMAC_QSERDES_RX_CDR_CONTROL,	SECONDORDERENABLE |
+		(QSERDES_RX_CDR_CTRL1_THRESH << FIRSTORDER_THRESH_SHFT) |
+		(QSERDES_RX_CDR_CTRL1_GAIN << SECONDORDERGAIN_SHFT)},
+{EMAC_QSERDES_RX_CDR_CONTROL2,	SECONDORDERENABLE |
+		(QSERDES_RX_CDR_CTRL2_THRESH << FIRSTORDER_THRESH_SHFT) |
+		(QSERDES_RX_CDR_CTRL2_GAIN << SECONDORDERGAIN_SHFT)},
+};
+
+static const struct emac_reg_write tx_rx_setting[] = {
+{EMAC_QSERDES_TX_BIST_MODE_LANENO,	QSERDES_TX_BIST_MODE_LANENO},
+{EMAC_QSERDES_TX_TX_DRV_LVL,		TX_DRV_LVL_MUX |
+			(QSERDES_TX_DRV_LVL << TX_DRV_LVL_SHFT)},
+{EMAC_QSERDES_TX_TRAN_DRVR_EMP_EN,	EMP_EN_MUX | EMP_EN},
+{EMAC_QSERDES_TX_TX_EMP_POST1_LVL,	TX_EMP_POST1_LVL_MUX |
+			(QSERDES_TX_EMP_POST1_LVL << TX_EMP_POST1_LVL_SHFT)},
+{EMAC_QSERDES_RX_RX_EQ_GAIN12,
+				(QSERDES_RX_EQ_GAIN2 << RX_EQ_GAIN2_SHFT) |
+				(QSERDES_RX_EQ_GAIN1 << RX_EQ_GAIN1_SHFT)},
+{EMAC_QSERDES_TX_LANE_MODE,		QSERDES_TX_LANE_MODE},
+};
+
+int emac_sgmii_link_init(struct emac_adapter *adpt, u32 speed, bool autoneg,
+			 bool fc)
+{
+	struct emac_phy *phy = &adpt->phy;
+	u32 val;
+	u32 speed_cfg = 0;
+
+	val = readl(phy->base + EMAC_SGMII_PHY_AUTONEG_CFG2);
+
+	if (autoneg) {
+		val &= ~(FORCE_AN_RX_CFG | FORCE_AN_TX_CFG);
+		val |= AN_ENABLE;
+		writel(val, phy->base + EMAC_SGMII_PHY_AUTONEG_CFG2);
+	} else {
+		switch (speed) {
+		case EMAC_LINK_SPEED_10_HALF:
+			speed_cfg = SPDMODE_10;
+			break;
+		case EMAC_LINK_SPEED_10_FULL:
+			speed_cfg = SPDMODE_10 | DUPLEX_MODE;
+			break;
+		case EMAC_LINK_SPEED_100_HALF:
+			speed_cfg = SPDMODE_100;
+			break;
+		case EMAC_LINK_SPEED_100_FULL:
+			speed_cfg = SPDMODE_100 | DUPLEX_MODE;
+			break;
+		case EMAC_LINK_SPEED_1GB_FULL:
+			speed_cfg = SPDMODE_1000 | DUPLEX_MODE;
+			break;
+		default:
+			return -EINVAL;
+		}
+		val &= ~AN_ENABLE;
+		writel(speed_cfg, phy->base + EMAC_SGMII_PHY_SPEED_CFG1);
+		writel(val, phy->base + EMAC_SGMII_PHY_AUTONEG_CFG2);
+	}
+
+	return 0;
+}
+
+int emac_sgmii_irq_clear(struct emac_adapter *adpt, u32 irq_bits)
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
+	/* Ensure that clearing procedure finalization is written to HW */
+	wmb();
+
+	return 0;
+}
+
+int emac_sgmii_init(struct emac_adapter *adpt)
+{
+	struct emac_phy *phy = &adpt->phy;
+	int i;
+	int ret;
+
+	ret = emac_sgmii_link_init(adpt, phy->autoneg_advertised, phy->autoneg,
+				   !phy->disable_fc_autoneg);
+	if (ret)
+		return ret;
+
+	emac_reg_write_all(phy->base, physical_coding_sublayer_programming,
+			   ARRAY_SIZE(physical_coding_sublayer_programming));
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
+		if (readl(phy->base + EMAC_QSERDES_COM_RESET_SM) &
+			  QSERDES_READY)
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
+	clk_set_rate(adpt->clk[EMAC_CLK_HIGH_SPEED], EMC_CLK_RATE_19_2MHZ);
+	emac_sgmii_reset_prepare(adpt);
+	emac_sgmii_init(adpt);
+	clk_set_rate(adpt->clk[EMAC_CLK_HIGH_SPEED], EMC_CLK_RATE_125MHZ);
+}
+
+int emac_sgmii_no_ephy_link_setup(struct emac_adapter *adpt, u32 speed,
+				  bool autoneg)
+{
+	struct emac_phy *phy = &adpt->phy;
+
+	phy->autoneg		= autoneg;
+	phy->autoneg_advertised	= speed;
+	/* The AN_ENABLE and SPEED_CFG can't change on fly. The SGMII_PHY has
+	 * to be re-initialized.
+	 */
+	emac_sgmii_reset_prepare(adpt);
+
+	return emac_sgmii_init(adpt);
+}
+
+int emac_sgmii_config(struct platform_device *pdev, struct emac_adapter *adpt)
+{
+	struct emac_phy *phy = &adpt->phy;
+	struct resource *res;
+	int ret;
+
+	ret = platform_get_irq_byname(pdev, SGMII_IRQ_RES);
+	if (ret < 0) {
+		netdev_err(adpt->netdev, "error: missing '%s' resource\n",
+			   SGMII_IRQ_RES);
+		return ret;
+	}
+
+	phy->irq = ret;
+
+	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, SGMII_MEM_RES);
+	if (!res) {
+		netdev_err(adpt->netdev, "error: missing '%s' resource\n",
+			   SGMII_MEM_RES);
+		return -ENXIO;
+	}
+
+	phy->base = devm_ioremap_resource(&pdev->dev, res);
+	if (IS_ERR(phy->base))
+		return -ENOMEM;
+
+	return 0;
+}
+
+void emac_sgmii_autoneg_check(struct emac_adapter *adpt, u32 *speed,
+			      bool *link_up)
+{
+	struct emac_phy *phy = &adpt->phy;
+	u32 autoneg0, autoneg1, status;
+
+	autoneg0 = readl_relaxed(phy->base + EMAC_SGMII_PHY_AUTONEG0_STATUS);
+	autoneg1 = readl_relaxed(phy->base + EMAC_SGMII_PHY_AUTONEG1_STATUS);
+	status   = ((autoneg1 & 0xff) << 8) | (autoneg0 & 0xff);
+
+	if (!(status & TXCFG_LINK)) {
+		*link_up = false;
+		*speed = EMAC_LINK_SPEED_UNKNOWN;
+		return;
+	}
+
+	*link_up = true;
+
+	switch (status & TXCFG_MODE_BMSK) {
+	case TXCFG_1000_FULL:
+		*speed = EMAC_LINK_SPEED_1GB_FULL;
+		break;
+	case TXCFG_100_FULL:
+		*speed = EMAC_LINK_SPEED_100_FULL;
+		break;
+	case TXCFG_100_HALF:
+		*speed = EMAC_LINK_SPEED_100_HALF;
+		break;
+	case TXCFG_10_FULL:
+		*speed = EMAC_LINK_SPEED_10_FULL;
+		break;
+	case TXCFG_10_HALF:
+		*speed = EMAC_LINK_SPEED_10_HALF;
+		break;
+	default:
+		*speed = EMAC_LINK_SPEED_UNKNOWN;
+		break;
+	}
+}
+
+void emac_sgmii_no_ephy_link_check(struct emac_adapter *adpt, u32 *speed,
+				   bool *link_up)
+{
+	struct emac_phy *phy = &adpt->phy;
+	u32 val;
+
+	val = readl_relaxed(phy->base + EMAC_SGMII_PHY_AUTONEG_CFG2);
+	if (val & AN_ENABLE) {
+		emac_sgmii_autoneg_check(adpt, speed, link_up);
+		return;
+	}
+
+	val = readl_relaxed(phy->base + EMAC_SGMII_PHY_SPEED_CFG1);
+	switch (val & (DUPLEX_MODE | SPDMODE_BMSK)) {
+	case DUPLEX_MODE | SPDMODE_1000:
+		*speed = EMAC_LINK_SPEED_1GB_FULL;
+		break;
+	case DUPLEX_MODE | SPDMODE_100:
+		*speed = EMAC_LINK_SPEED_100_FULL;
+		break;
+	case SPDMODE_100:
+		*speed = EMAC_LINK_SPEED_100_HALF;
+		break;
+	case DUPLEX_MODE | SPDMODE_10:
+		*speed = EMAC_LINK_SPEED_10_FULL;
+		break;
+	case SPDMODE_10:
+		*speed = EMAC_LINK_SPEED_10_HALF;
+		break;
+	default:
+		*speed = EMAC_LINK_SPEED_UNKNOWN;
+		break;
+	}
+	*link_up = true;
+}
+
+irqreturn_t emac_sgmii_isr(int _irq, void *data)
+{
+	struct emac_adapter *adpt = data;
+	struct emac_phy *phy = &adpt->phy;
+	u32 status;
+
+	netif_dbg(adpt,  intr, adpt->netdev, "receive sgmii interrupt\n");
+
+	do {
+		status = readl_relaxed(phy->base +
+				       EMAC_SGMII_PHY_INTERRUPT_STATUS) &
+				       SGMII_ISR_MASK;
+		if (!status)
+			break;
+
+		if (status & SGMII_PHY_INTERRUPT_ERR) {
+			set_bit(EMAC_STATUS_TASK_CHK_SGMII_REQ, &adpt->status);
+			if (!test_bit(EMAC_STATUS_DOWN, &adpt->status))
+				emac_work_thread_reschedule(adpt);
+		}
+
+		if (status & SGMII_ISR_AN_MASK)
+			emac_lsc_schedule_check(adpt);
+
+		if (emac_sgmii_irq_clear(adpt, status) != 0) {
+			/* reset */
+			set_bit(EMAC_STATUS_TASK_REINIT_REQ, &adpt->status);
+			emac_work_thread_reschedule(adpt);
+			break;
+		}
+	} while (1);
+
+	return IRQ_HANDLED;
+}
+
+int emac_sgmii_up(struct emac_adapter *adpt)
+{
+	struct emac_phy *phy = &adpt->phy;
+	int ret;
+
+	ret = request_irq(phy->irq, emac_sgmii_isr, IRQF_TRIGGER_RISING,
+			  "sgmii_irq", adpt);
+	if (ret)
+		netdev_err(adpt->netdev,
+			   "error:%d on request_irq(%d:sgmii_irq)\n", ret,
+			   phy->irq);
+
+	/* enable sgmii irq */
+	writel_relaxed(SGMII_ISR_MASK,
+		       phy->base + EMAC_SGMII_PHY_INTERRUPT_MASK);
+
+	return ret;
+}
+
+void emac_sgmii_down(struct emac_adapter *adpt)
+{
+	struct emac_phy *phy = &adpt->phy;
+
+	writel_relaxed(0, phy->base + EMAC_SGMII_PHY_INTERRUPT_MASK);
+	synchronize_irq(phy->irq);
+	free_irq(phy->irq, adpt);
+}
+
+/* Check SGMII for error */
+void emac_sgmii_periodic_check(struct emac_adapter *adpt)
+{
+	struct emac_phy *phy = &adpt->phy;
+
+	if (!test_bit(EMAC_STATUS_TASK_CHK_SGMII_REQ, &adpt->status))
+		return;
+	clear_bit(EMAC_STATUS_TASK_CHK_SGMII_REQ, &adpt->status);
+
+	/* ensure that no reset is in progress while link task is running */
+	while (test_and_set_bit(EMAC_STATUS_RESETTING, &adpt->status))
+		msleep(20); /* Reset might take few 10s of ms */
+
+	if (test_bit(EMAC_STATUS_DOWN, &adpt->status))
+		goto sgmii_task_done;
+
+	if (readl_relaxed(phy->base + EMAC_SGMII_PHY_RX_CHK_STATUS) & 0x40)
+		goto sgmii_task_done;
+
+	netdev_err(adpt->netdev, "error: SGMII CDR not locked\n");
+
+sgmii_task_done:
+	clear_bit(EMAC_STATUS_RESETTING, &adpt->status);
+}
diff --git a/drivers/net/ethernet/qualcomm/emac/emac-sgmii.h b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.h
new file mode 100644
index 0000000..4d55915b
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.h
@@ -0,0 +1,30 @@
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
+int  emac_sgmii_init(struct emac_adapter *adpt);
+int  emac_sgmii_config(struct platform_device *pdev, struct emac_adapter *adpt);
+void emac_sgmii_reset(struct emac_adapter *adpt);
+int  emac_sgmii_up(struct emac_adapter *adpt);
+void emac_sgmii_down(struct emac_adapter *adpt);
+void emac_sgmii_periodic_check(struct emac_adapter *adpt);
+int  emac_sgmii_no_ephy_link_setup(struct emac_adapter *adpt, u32 speed,
+				   bool autoneg);
+void emac_sgmii_no_ephy_link_check(struct emac_adapter *adpt, u32 *speed,
+				   bool *link_up);
+
+#endif /*_EMAC_SGMII_H_*/
diff --git a/drivers/net/ethernet/qualcomm/emac/emac.c b/drivers/net/ethernet/qualcomm/emac/emac.c
new file mode 100644
index 0000000..17383f8
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/emac/emac.c
@@ -0,0 +1,1228 @@
+/* Copyright (c) 2013-2015, The Linux Foundation. All rights reserved.
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
+/* Qualcomm Technologies, Inc. EMAC Gigabit Ethernet Driver
+ * The EMAC driver supports following features:
+ * 1) Receive Side Scaling (RSS).
+ * 2) Checksum offload.
+ * 3) Multiple PHY support on MDIO bus.
+ * 4) Runtime power management support.
+ * 5) Interrupt coalescing support.
+ * 6) SGMII phy.
+ * 7) SGMII direct connection (without external phy).
+ */
+
+#include <linux/if_ether.h>
+#include <linux/if_vlan.h>
+#include <linux/interrupt.h>
+#include <linux/io.h>
+#include <linux/module.h>
+#include <linux/of.h>
+#include <linux/of_net.h>
+#include <linux/of_gpio.h>
+#include <linux/phy.h>
+#include <linux/platform_device.h>
+#include <linux/pm_runtime.h>
+#include "emac.h"
+#include "emac-mac.h"
+#include "emac-phy.h"
+#include "emac-sgmii.h"
+
+#define DRV_VERSION "1.3.0.0"
+
+static int debug = -1;
+module_param(debug, int, S_IRUGO | S_IWUSR | S_IWGRP);
+
+static int emac_irq_use_extended;
+module_param(emac_irq_use_extended, int, S_IRUGO | S_IWUSR | S_IWGRP);
+
+const char emac_drv_name[] = "qcom-emac";
+const char emac_drv_description[] =
+			"Qualcomm Technologies, Inc. EMAC Ethernet Driver";
+const char emac_drv_version[] = DRV_VERSION;
+
+#define EMAC_MSG_DEFAULT (NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK |  \
+		NETIF_MSG_TIMER | NETIF_MSG_IFDOWN | NETIF_MSG_IFUP |         \
+		NETIF_MSG_RX_ERR | NETIF_MSG_TX_ERR | NETIF_MSG_TX_QUEUED |   \
+		NETIF_MSG_INTR | NETIF_MSG_TX_DONE | NETIF_MSG_RX_STATUS |    \
+		NETIF_MSG_PKTDATA | NETIF_MSG_HW | NETIF_MSG_WOL)
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
+const char * const emac_gpio_name[] = {
+	"qcom,emac-gpio-mdc", "qcom,emac-gpio-mdio"
+};
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
+	WARN_ON(in_interrupt());
+
+	while (test_and_set_bit(EMAC_STATUS_RESETTING, &adpt->status))
+		msleep(20); /* Reset might take few 10s of ms */
+
+	if (test_bit(EMAC_STATUS_DOWN, &adpt->status)) {
+		clear_bit(EMAC_STATUS_RESETTING, &adpt->status);
+		return;
+	}
+
+	emac_mac_down(adpt, true);
+
+	emac_sgmii_reset(adpt);
+	emac_mac_up(adpt);
+
+	clear_bit(EMAC_STATUS_RESETTING, &adpt->status);
+}
+
+void emac_work_thread_reschedule(struct emac_adapter *adpt)
+{
+	if (!test_bit(EMAC_STATUS_DOWN, &adpt->status) &&
+	    !test_bit(EMAC_STATUS_WATCH_DOG, &adpt->status)) {
+		set_bit(EMAC_STATUS_WATCH_DOG, &adpt->status);
+		schedule_work(&adpt->work_thread);
+	}
+}
+
+void emac_lsc_schedule_check(struct emac_adapter *adpt)
+{
+	set_bit(EMAC_STATUS_TASK_LSC_REQ, &adpt->status);
+	adpt->link_chk_timeout = jiffies + EMAC_TRY_LINK_TIMEOUT;
+
+	if (!test_bit(EMAC_STATUS_DOWN, &adpt->status))
+		emac_work_thread_reschedule(adpt);
+}
+
+/* Change MAC address */
+static int emac_set_mac_address(struct net_device *netdev, void *p)
+{
+	struct emac_adapter *adpt = netdev_priv(netdev);
+
+	struct sockaddr *addr = p;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	if (netif_running(netdev))
+		return -EBUSY;
+
+	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
+	memcpy(adpt->mac_addr, addr->sa_data, netdev->addr_len);
+
+	emac_mac_addr_clear(adpt, adpt->mac_addr);
+
+	return 0;
+}
+
+/* NAPI */
+static int emac_napi_rtx(struct napi_struct *napi, int budget)
+{
+	struct emac_rx_queue *rx_q = container_of(napi, struct emac_rx_queue,
+						   napi);
+	struct emac_adapter *adpt = netdev_priv(rx_q->netdev);
+	struct emac_irq *irq = rx_q->irq;
+
+	int work_done = 0;
+
+	/* Keep link state information with original netdev */
+	if (!netif_carrier_ok(adpt->netdev))
+		goto quit_polling;
+
+	emac_mac_rx_process(adpt, rx_q, &work_done, budget);
+
+	if (work_done < budget) {
+quit_polling:
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
+	struct emac_adapter *adpt = container_of(irq, struct emac_adapter, irq);
+	struct emac_rx_queue *rx_q = &adpt->rx_q;
+
+	int max_ints = 1;
+	u32 isr, status;
+
+	/* disable the interrupt */
+	writel(0, adpt->base + EMAC_INT_MASK);
+
+	do {
+		isr = readl_relaxed(adpt->base + EMAC_INT_STATUS);
+		status = isr & irq->mask;
+
+		if (status == 0)
+			break;
+
+		if (status & ISR_ERROR) {
+			netif_warn(adpt,  intr, adpt->netdev,
+				   "warning: error irq status 0x%lx\n",
+				   status & ISR_ERROR);
+			/* reset MAC */
+			set_bit(EMAC_STATUS_TASK_REINIT_REQ, &adpt->status);
+			emac_work_thread_reschedule(adpt);
+		}
+
+		/* Schedule the napi for receive queue with interrupt
+		 * status bit set
+		 */
+		if ((status & rx_q->intr)) {
+			if (napi_schedule_prep(&rx_q->napi)) {
+				irq->mask &= ~rx_q->intr;
+				__napi_schedule(&rx_q->napi);
+			}
+		}
+
+		if (status & TX_PKT_INT)
+			emac_mac_tx_process(adpt, &adpt->tx_q);
+
+		if (status & ISR_OVER)
+			netif_warn(adpt, intr, adpt->netdev,
+				   "warning: TX/RX overflow status 0x%lx\n",
+				   status & ISR_OVER);
+
+		/* link event */
+		if (status & (ISR_GPHY_LINK | SW_MAN_INT)) {
+			emac_lsc_schedule_check(adpt);
+			break;
+		}
+	} while (--max_ints > 0);
+
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
+	struct emac_adapter *adpt = netdev_priv(netdev);
+
+	netdev_features_t changed = features ^ netdev->features;
+
+	if (!(changed & (NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX)))
+		return 0;
+
+	netdev->features = features;
+	if (netdev->features & NETIF_F_HW_VLAN_CTAG_RX)
+		set_bit(EMAC_STATUS_VLANSTRIP_EN, &adpt->status);
+	else
+		clear_bit(EMAC_STATUS_VLANSTRIP_EN, &adpt->status);
+
+	if (netif_running(netdev))
+		emac_reinit_locked(adpt);
+
+	return 0;
+}
+
+/* Configure Multicast and Promiscuous modes */
+void emac_rx_mode_set(struct net_device *netdev)
+{
+	struct emac_adapter *adpt = netdev_priv(netdev);
+
+	struct netdev_hw_addr *ha;
+
+	/* Check for Promiscuous and All Multicast modes */
+	if (netdev->flags & IFF_PROMISC) {
+		set_bit(EMAC_STATUS_PROMISC_EN, &adpt->status);
+	} else if (netdev->flags & IFF_ALLMULTI) {
+		set_bit(EMAC_STATUS_MULTIALL_EN, &adpt->status);
+		clear_bit(EMAC_STATUS_PROMISC_EN, &adpt->status);
+	} else {
+		clear_bit(EMAC_STATUS_MULTIALL_EN, &adpt->status);
+		clear_bit(EMAC_STATUS_PROMISC_EN, &adpt->status);
+	}
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
+	struct emac_adapter *adpt = netdev_priv(netdev);
+	int old_mtu   = netdev->mtu;
+	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
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
+		adpt->mtu = new_mtu;
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
+	netif_carrier_off(netdev);
+
+	/* allocate rx/tx dma buffer & descriptors */
+	ret = emac_mac_rx_tx_rings_alloc_all(adpt);
+	if (ret) {
+		netdev_err(adpt->netdev, "error allocating rx/tx rings\n");
+		return ret;
+	}
+
+	pm_runtime_set_active(netdev->dev.parent);
+	pm_runtime_enable(netdev->dev.parent);
+
+	ret = emac_mac_up(adpt);
+	if (ret)
+		emac_mac_rx_tx_rings_free_all(adpt);
+
+	return ret;
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
+	pm_runtime_disable(netdev->dev.parent);
+	if (!test_bit(EMAC_STATUS_DOWN, &adpt->status))
+		emac_mac_down(adpt, true);
+	else
+		emac_mac_reset(adpt);
+
+	emac_mac_rx_tx_rings_free_all(adpt);
+
+	clear_bit(EMAC_STATUS_RESETTING, &adpt->status);
+
+	return 0;
+}
+
+/* PHY related IOCTLs */
+static int emac_mii_ioctl(struct net_device *netdev,
+			  struct ifreq *ifr, int cmd)
+{
+	struct emac_adapter *adpt = netdev_priv(netdev);
+	struct emac_phy *phy = &adpt->phy;
+	struct mii_ioctl_data *data = if_mii(ifr);
+
+	switch (cmd) {
+	case SIOCGMIIPHY:
+		data->phy_id = phy->addr;
+		return 0;
+
+	case SIOCGMIIREG:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+
+		if (data->reg_num & ~(0x1F))
+			return -EFAULT;
+
+		if (data->phy_id >= PHY_MAX_ADDR)
+			return -EFAULT;
+
+		if (phy->external && data->phy_id != phy->addr)
+			return -EFAULT;
+
+		return emac_phy_read(adpt, data->phy_id, data->reg_num,
+				     &data->val_out);
+
+	case SIOCSMIIREG:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+
+		if (data->reg_num & ~(0x1F))
+			return -EFAULT;
+
+		if (data->phy_id >= PHY_MAX_ADDR)
+			return -EFAULT;
+
+		if (phy->external && data->phy_id != phy->addr)
+			return -EFAULT;
+
+		return emac_phy_write(adpt, data->phy_id, data->reg_num,
+				      data->val_in);
+	default:
+		return -EFAULT;
+	}
+}
+
+/* Respond to a TX hang */
+static void emac_tx_timeout(struct net_device *netdev)
+{
+	struct emac_adapter *adpt = netdev_priv(netdev);
+
+	if (!test_bit(EMAC_STATUS_DOWN, &adpt->status)) {
+		set_bit(EMAC_STATUS_TASK_REINIT_REQ, &adpt->status);
+		emac_work_thread_reschedule(adpt);
+	}
+}
+
+/* IOCTL support for the interface */
+static int emac_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
+{
+	switch (cmd) {
+	case SIOCGMIIPHY:
+	case SIOCGMIIREG:
+	case SIOCSMIIREG:
+		return emac_mii_ioctl(netdev, ifr, cmd);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+/* Provide network statistics info for the interface */
+struct rtnl_link_stats64 *emac_get_stats64(struct net_device *netdev,
+					   struct rtnl_link_stats64 *net_stats)
+{
+	struct emac_adapter *adpt = netdev_priv(netdev);
+	struct emac_stats *stats = &adpt->stats;
+	u16 addr = REG_MAC_RX_STATUS_BIN;
+	u64 *stats_itr = &adpt->stats.rx_ok;
+	u32 val;
+
+	while (addr <= REG_MAC_RX_STATUS_END) {
+		val = readl_relaxed(adpt->base + addr);
+		*stats_itr += val;
+		++stats_itr;
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
+	return net_stats;
+}
+
+static const struct net_device_ops emac_netdev_ops = {
+	.ndo_open		= &emac_open,
+	.ndo_stop		= &emac_close,
+	.ndo_validate_addr	= &eth_validate_addr,
+	.ndo_start_xmit		= &emac_start_xmit,
+	.ndo_set_mac_address	= &emac_set_mac_address,
+	.ndo_change_mtu		= &emac_change_mtu,
+	.ndo_do_ioctl		= &emac_ioctl,
+	.ndo_tx_timeout		= &emac_tx_timeout,
+	.ndo_get_stats64	= &emac_get_stats64,
+	.ndo_set_features       = emac_set_features,
+	.ndo_set_rx_mode        = emac_rx_mode_set,
+};
+
+static char *emac_link_speed_to_str(u32 speed)
+{
+	switch (speed) {
+	case EMAC_LINK_SPEED_1GB_FULL:
+		return  "1 Gbps Duplex Full";
+	case EMAC_LINK_SPEED_100_FULL:
+		return "100 Mbps Duplex Full";
+	case EMAC_LINK_SPEED_100_HALF:
+		return "100 Mbps Duplex Half";
+	case EMAC_LINK_SPEED_10_FULL:
+		return "10 Mbps Duplex Full";
+	case EMAC_LINK_SPEED_10_HALF:
+		return "10 Mbps Duplex HALF";
+	default:
+		return "unknown speed";
+	}
+}
+
+/* Check link status and handle link state changes */
+static void emac_work_thread_link_check(struct emac_adapter *adpt)
+{
+	struct net_device *netdev = adpt->netdev;
+	struct emac_phy *phy = &adpt->phy;
+	const char *speed;
+
+	if (!test_bit(EMAC_STATUS_TASK_LSC_REQ, &adpt->status))
+		return;
+	clear_bit(EMAC_STATUS_TASK_LSC_REQ, &adpt->status);
+
+	/* ensure that no reset is in progress while link task is running */
+	while (test_and_set_bit(EMAC_STATUS_RESETTING, &adpt->status))
+		msleep(20); /* Reset might take few 10s of ms */
+
+	if (test_bit(EMAC_STATUS_DOWN, &adpt->status))
+		goto link_task_done;
+
+	emac_phy_link_check(adpt, &phy->link_speed, &phy->link_up);
+	speed = emac_link_speed_to_str(phy->link_speed);
+
+	if (phy->link_up) {
+		if (netif_carrier_ok(netdev))
+			goto link_task_done;
+
+		pm_runtime_get_sync(netdev->dev.parent);
+		netif_info(adpt, timer, adpt->netdev, "NIC Link is Up %s\n",
+			   speed);
+
+		emac_mac_start(adpt);
+		netif_carrier_on(netdev);
+		netif_wake_queue(netdev);
+	} else {
+		if (time_after(adpt->link_chk_timeout, jiffies))
+			set_bit(EMAC_STATUS_TASK_LSC_REQ, &adpt->status);
+
+		/* only continue if link was up previously */
+		if (!netif_carrier_ok(netdev))
+			goto link_task_done;
+
+		phy->link_speed = 0;
+		netif_info(adpt,  timer, adpt->netdev, "NIC Link is Down\n");
+		netif_stop_queue(netdev);
+		netif_carrier_off(netdev);
+
+		emac_mac_stop(adpt);
+		pm_runtime_put_sync(netdev->dev.parent);
+	}
+
+	/* link state transition, kick timer */
+	mod_timer(&adpt->timers, jiffies);
+
+link_task_done:
+	clear_bit(EMAC_STATUS_RESETTING, &adpt->status);
+}
+
+/* Watchdog task routine */
+static void emac_work_thread(struct work_struct *work)
+{
+	struct emac_adapter *adpt = container_of(work, struct emac_adapter,
+						 work_thread);
+
+	if (!test_bit(EMAC_STATUS_WATCH_DOG, &adpt->status))
+		netif_warn(adpt,  timer, adpt->netdev,
+			   "warning: WATCH_DOG flag isn't set\n");
+
+	if (test_bit(EMAC_STATUS_TASK_REINIT_REQ, &adpt->status)) {
+		clear_bit(EMAC_STATUS_TASK_REINIT_REQ, &adpt->status);
+
+		if ((!test_bit(EMAC_STATUS_DOWN, &adpt->status)) &&
+		    (!test_bit(EMAC_STATUS_RESETTING, &adpt->status)))
+			emac_reinit_locked(adpt);
+	}
+
+	emac_work_thread_link_check(adpt);
+	emac_sgmii_periodic_check(adpt);
+	clear_bit(EMAC_STATUS_WATCH_DOG, &adpt->status);
+}
+
+/* Timer routine */
+static void emac_timer_thread(unsigned long data)
+{
+	struct emac_adapter *adpt = (struct emac_adapter *)data;
+	unsigned long delay;
+
+	if (pm_runtime_status_suspended(adpt->netdev->dev.parent))
+		return;
+
+	/* poll faster when waiting for link */
+	if (test_bit(EMAC_STATUS_TASK_LSC_REQ, &adpt->status))
+		delay = HZ / 10;
+	else
+		delay = 2 * HZ;
+
+	/* Reset the timer */
+	mod_timer(&adpt->timers, delay + jiffies);
+
+	emac_work_thread_reschedule(adpt);
+}
+
+/* Initialize various data structures  */
+static void emac_init_adapter(struct emac_adapter *adpt)
+{
+	struct emac_phy *phy = &adpt->phy;
+	int max_frame;
+	u32 reg;
+
+	/* ids */
+	reg =  readl_relaxed(adpt->base + EMAC_DMA_MAS_CTRL);
+	adpt->devid = (reg & DEV_ID_NUM_BMSK)  >> DEV_ID_NUM_SHFT;
+	adpt->revid = (reg & DEV_REV_NUM_BMSK) >> DEV_REV_NUM_SHFT;
+
+	/* descriptors */
+	adpt->tx_desc_cnt = EMAC_DEF_TX_DESCS;
+	adpt->rx_desc_cnt = EMAC_DEF_RX_DESCS;
+
+	/* mtu */
+	adpt->netdev->mtu = ETH_DATA_LEN;
+	adpt->mtu = adpt->netdev->mtu;
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
+	/* link */
+	phy->link_up = false;
+	phy->link_speed = EMAC_LINK_SPEED_UNKNOWN;
+
+	/* flow control */
+	phy->req_fc_mode = EMAC_FC_FULL;
+	phy->cur_fc_mode = EMAC_FC_FULL;
+	phy->disable_fc_autoneg = false;
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
+#ifdef CONFIG_PM
+static int emac_runtime_suspend(struct device *device)
+{
+	struct platform_device *pdev = to_platform_device(device);
+	struct net_device *netdev = dev_get_drvdata(&pdev->dev);
+	struct emac_adapter *adpt = netdev_priv(netdev);
+
+	emac_mac_pm(adpt);
+
+	return 0;
+}
+
+static int emac_runtime_idle(struct device *device)
+{
+	struct platform_device *pdev = to_platform_device(device);
+	struct net_device *netdev = dev_get_drvdata(&pdev->dev);
+
+	/* schedule to enter runtime suspend state if the link does
+	 * not come back up within the specified time
+	 */
+	pm_schedule_suspend(netdev->dev.parent,
+			    jiffies_to_msecs(EMAC_TRY_LINK_TIMEOUT));
+
+	return -EBUSY;
+}
+#endif /* CONFIG_PM */
+
+#ifdef CONFIG_PM_SLEEP
+static int emac_suspend(struct device *device)
+{
+	struct platform_device *pdev = to_platform_device(device);
+	struct net_device *netdev = dev_get_drvdata(&pdev->dev);
+	struct emac_adapter *adpt = netdev_priv(netdev);
+	struct emac_phy *phy = &adpt->phy;
+	int i;
+	u32 speed, adv_speed;
+	bool link_up = false;
+	int ret = 0;
+
+	netif_device_detach(netdev);
+	if (netif_running(netdev)) {
+		/* ensure no task is running and no reset is in progress */
+		while (test_and_set_bit(EMAC_STATUS_RESETTING, &adpt->status))
+			msleep(20); /* Reset might take few 10s of ms */
+
+		emac_mac_down(adpt, false);
+
+		clear_bit(EMAC_STATUS_RESETTING, &adpt->status);
+	}
+
+	emac_phy_link_check(adpt, &speed, &link_up);
+
+	if (link_up) {
+		adv_speed = EMAC_LINK_SPEED_10_HALF;
+		emac_phy_link_speed_get(adpt, &adv_speed);
+
+		ret = emac_phy_link_setup(adpt, adv_speed, true,
+					  !adpt->phy.disable_fc_autoneg);
+		if (ret)
+			return ret;
+
+		link_up = false;
+		for (i = 0; i < EMAC_MAX_SETUP_LNK_CYCLE; i++) {
+			ret = emac_phy_link_check(adpt, &speed, &link_up);
+			if ((!ret) && link_up)
+				break;
+
+			/* link can take upto few seconds to come up */
+			msleep(100);
+		}
+	}
+
+	if (!link_up)
+		speed = EMAC_LINK_SPEED_10_HALF;
+
+	phy->link_speed = speed;
+	phy->link_up = link_up;
+
+	emac_mac_pm(adpt);
+
+	return 0;
+}
+
+static int emac_resume(struct device *device)
+{
+	struct platform_device *pdev = to_platform_device(device);
+	struct net_device *netdev = dev_get_drvdata(&pdev->dev);
+	struct emac_adapter *adpt = netdev_priv(netdev);
+	struct emac_phy *phy = &adpt->phy;
+	u32 ret;
+
+	emac_mac_reset(adpt);
+	ret = emac_phy_link_setup(adpt, phy->autoneg_advertised, true,
+				  !phy->disable_fc_autoneg);
+	if (ret)
+		return ret;
+
+	if (netif_running(netdev)) {
+		ret = emac_mac_up(adpt);
+		if (ret)
+			return ret;
+	}
+
+	netif_device_attach(netdev);
+
+	return 0;
+}
+#endif /* CONFIG_PM_SLEEP */
+
+/* Get the clock */
+static int emac_clks_get(struct platform_device *pdev,
+			 struct emac_adapter *adpt)
+{
+	struct clk *clk;
+	int i;
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
+static int emac_clks_phase1_init(struct emac_adapter *adpt)
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
+	ret = clk_set_rate(adpt->clk[EMAC_CLK_HIGH_SPEED],
+			   EMC_CLK_RATE_19_2MHZ);
+	if (ret)
+		return ret;
+
+	return clk_prepare_enable(adpt->clk[EMAC_CLK_HIGH_SPEED]);
+}
+
+/* Enable clocks; needs emac_clks_phase1_init to be called before */
+static int emac_clks_phase2_init(struct emac_adapter *adpt)
+{
+	int ret;
+
+	ret = clk_set_rate(adpt->clk[EMAC_CLK_TX], EMC_CLK_RATE_125MHZ);
+	if (ret)
+		return ret;
+
+	ret = clk_prepare_enable(adpt->clk[EMAC_CLK_TX]);
+	if (ret)
+		return ret;
+
+	ret = clk_set_rate(adpt->clk[EMAC_CLK_HIGH_SPEED], EMC_CLK_RATE_125MHZ);
+	if (ret)
+		return ret;
+
+	ret = clk_set_rate(adpt->clk[EMAC_CLK_MDIO], EMC_CLK_RATE_25MHZ);
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
+	struct net_device *netdev = adpt->netdev;
+	struct device_node *node = pdev->dev.of_node;
+	struct resource *res;
+	const void *maddr;
+	int ret = 0;
+	int i;
+
+	if (!node)
+		return -ENODEV;
+
+	/* get id */
+	ret = of_property_read_u32(node, "cell-index", &pdev->id);
+	if (ret)
+		return ret;
+
+	/* get time stamp enable flag */
+	adpt->timestamp_en = of_property_read_bool(node, "qcom,emac-tstamp-en");
+
+	/* get gpios */
+	for (i = 0; adpt->phy.uses_gpios && i < EMAC_GPIO_CNT; i++) {
+		ret = of_get_named_gpio(node, emac_gpio_name[i], 0);
+		if (ret < 0)
+			return ret;
+
+		adpt->gpio[i] = ret;
+	}
+
+	/* get mac address */
+	maddr = of_get_mac_address(node);
+	if (!maddr)
+		return -ENODEV;
+
+	memcpy(adpt->mac_perm_addr, maddr, netdev->addr_len);
+
+	ret = platform_get_irq_byname(pdev, EMAC_MAC_IRQ_RES);
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
+	if (!res) {
+		netdev_err(adpt->netdev, "error: missing 'base' resource\n");
+		ret = -ENXIO;
+		goto err_reg_res;
+	}
+
+	adpt->base = devm_ioremap_resource(&pdev->dev, res);
+	if (!adpt->base) {
+		ret = -ENOMEM;
+		goto err_reg_res;
+	}
+
+	res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "csr");
+	if (!res) {
+		netdev_err(adpt->netdev, "error: missing 'csr' resource\n");
+		ret = -ENXIO;
+		goto err_reg_res;
+	}
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
+	int i;
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
+	int ret = 0;
+	u32 hw_ver;
+	u32 extended_irq_mask = emac_irq_use_extended ? IMR_EXTENDED_MASK :
+							IMR_NORMAL_MASK;
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
+	adpt->msg_enable = netif_msg_init(debug, EMAC_MSG_DEFAULT);
+
+	dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32));
+
+	dma_set_max_seg_size(&pdev->dev, 65536);
+	dma_set_seg_boundary(&pdev->dev, 0xffffffff);
+
+	adpt->irq.mask = RX_PKT_INT0 | extended_irq_mask;
+
+	ret = emac_probe_resources(pdev, adpt);
+	if (ret)
+		goto err_undo_netdev;
+
+	/* initialize clocks */
+	ret = emac_clks_phase1_init(adpt);
+	if (ret)
+		goto err_undo_resources;
+
+	hw_ver = readl_relaxed(adpt->base + EMAC_CORE_HW_VERSION);
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
+	ret = emac_clks_phase2_init(adpt);
+	if (ret)
+		goto err_undo_clk_phase1;
+
+	/* init external phy */
+	ret = emac_phy_external_init(adpt);
+	if (ret)
+		goto err_undo_clk_phase2;
+
+	/* reset mac */
+	emac_mac_reset(adpt);
+
+	/* setup link to put it in a known good starting state */
+	ret = emac_phy_link_setup(adpt, phy->autoneg_advertised, true,
+				  !phy->disable_fc_autoneg);
+	if (ret)
+		goto err_undo_clk_phase2;
+
+	/* set mac address */
+	memcpy(adpt->mac_addr, adpt->mac_perm_addr, netdev->addr_len);
+	memcpy(netdev->dev_addr, adpt->mac_addr, netdev->addr_len);
+	emac_mac_addr_clear(adpt, adpt->mac_addr);
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
+	setup_timer(&adpt->timers, &emac_timer_thread,
+		    (unsigned long)adpt);
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
+	set_bit(EMAC_STATUS_VLANSTRIP_EN, &adpt->status);
+	set_bit(EMAC_STATUS_DOWN, &adpt->status);
+	strlcpy(netdev->name, "eth%d", sizeof(netdev->name));
+
+	ret = register_netdev(netdev);
+	if (ret)
+		goto err_undo_clk_phase2;
+
+	dev_info(&pdev->dev, "%s - version %s\n", emac_drv_description,
+		 emac_drv_version);
+	netif_dbg(adpt, probe, adpt->netdev, "EMAC HW ID %d.%d\n", adpt->devid,
+		  adpt->revid);
+	netif_dbg(adpt, probe, adpt->netdev, "EMAC HW version %d.%d.%d\n",
+		  (hw_ver & MAJOR_BMSK) >> MAJOR_SHFT,
+		  (hw_ver & MINOR_BMSK) >> MINOR_SHFT,
+		  (hw_ver & STEP_BMSK)  >> STEP_SHFT);
+
+	return 0;
+
+err_undo_clk_phase2:
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
+	dev_dbg(&pdev->dev, "removing %s\n", emac_drv_name);
+
+	unregister_netdev(netdev);
+	emac_clks_phase2_teardown(adpt);
+	emac_clks_phase1_teardown(adpt);
+	emac_release_resources(adpt);
+	free_netdev(netdev);
+	dev_set_drvdata(&pdev->dev, NULL);
+
+	return 0;
+}
+
+static const struct dev_pm_ops emac_pm_ops = {
+	SET_SYSTEM_SLEEP_PM_OPS(
+		emac_suspend,
+		emac_resume
+	)
+	SET_RUNTIME_PM_OPS(
+		emac_runtime_suspend,
+		NULL,
+		emac_runtime_idle
+	)
+};
+
+static const struct of_device_id emac_dt_match[] = {
+	{
+		.compatible = "qcom,emac",
+	},
+	{}
+};
+
+static struct platform_driver emac_platform_driver = {
+	.probe	= emac_probe,
+	.remove	= emac_remove,
+	.driver = {
+		.owner		= THIS_MODULE,
+		.name		= emac_drv_name,
+		.pm		= &emac_pm_ops,
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
index 0000000..9982617
--- /dev/null
+++ b/drivers/net/ethernet/qualcomm/emac/emac.h
@@ -0,0 +1,388 @@
+/* Copyright (c) 2013-2015, The Linux Foundation. All rights reserved.
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
+/* mdio/mdc gpios */
+#define EMAC_GPIO_CNT                                                2
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
+#define KHz(RATE)	((RATE)    * 1000)
+#define MHz(RATE)	(KHz(RATE) * 1000)
+
+enum emac_clk_rate {
+	EMC_CLK_RATE_2_5MHZ	= KHz(2500),
+	EMC_CLK_RATE_19_2MHZ	= KHz(19200),
+	EMC_CLK_RATE_25MHZ	= MHz(25),
+	EMC_CLK_RATE_125MHZ	= MHz(125),
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
+};
+
+enum emac_status_bits {
+	EMAC_STATUS_PROMISC_EN,
+	EMAC_STATUS_VLANSTRIP_EN,
+	EMAC_STATUS_MULTIALL_EN,
+	EMAC_STATUS_LOOPBACK_EN,
+	EMAC_STATUS_TS_RX_EN,
+	EMAC_STATUS_TS_TX_EN,
+	EMAC_STATUS_RESETTING,
+	EMAC_STATUS_DOWN,
+	EMAC_STATUS_WATCH_DOG,
+	EMAC_STATUS_TASK_REINIT_REQ,
+	EMAC_STATUS_TASK_LSC_REQ,
+	EMAC_STATUS_TASK_CHK_SGMII_REQ,
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
+
+	void __iomem			*base;
+	void __iomem			*csr;
+
+	struct emac_phy			phy;
+	struct emac_stats		stats;
+
+	struct emac_irq			irq;
+	unsigned int			gpio[EMAC_GPIO_CNT];
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
+	u16				devid;
+	u16				revid;
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
+	/* MAC parameter */
+	u8				mac_addr[ETH_ALEN];
+	u8				mac_perm_addr[ETH_ALEN];
+	u32				mtu;
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
+	struct timer_list		timers;
+	unsigned long			link_chk_timeout;
+
+	bool				timestamp_en;
+	u16				msg_enable;
+	unsigned long			status;
+};
+
+void emac_reinit_locked(struct emac_adapter *adpt);
+void emac_work_thread_reschedule(struct emac_adapter *adpt);
+void emac_lsc_schedule_check(struct emac_adapter *adpt);
+void emac_rx_mode_set(struct net_device *netdev);
+void emac_reg_update32(void __iomem *addr, u32 mask, u32 val);
+irqreturn_t emac_isr(int irq, void *data);
+
+extern const char * const emac_gpio_name[];
+
+#endif /* _EMAC_H_ */
-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
