From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v2] Renesas Ethernet AVB driver
Date: Mon, 13 Apr 2015 01:36:56 +0300
Message-ID: <1453213.DoV6WFn45r@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-sh@vger.kernel.org
To: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, devicetree@vger.kernel.org,
	galak@codeaurora.org, netdev@vger.kernel.org,
	richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:35817 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751832AbbDLWhD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 18:37:03 -0400
Received: by lbbuc2 with SMTP id uc2so46301134lbb.2
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 15:37:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ethernet AVB includes an Gigabit Ethernet controller (E-MAC) that is basically
compatible with SuperH Gigabit Ethernet E-MAC). Ethernet AVB  has a dedicated
direct memory access controller (AVB-DMAC) that is a new design compared to the
SuperH E-DMAC. The AVB-DMAC is compliant with 3 standards formulated for IEEE
802.1BA: IEEE 802.1AS timing and synchronization protocol, IEEE 802.1Qav real-
time transfer, and the IEEE 802.1Qat stream reservation protocol.

Not only the Ethernet driver is enclosed, there is also the PTP driver in
the same file.  These drivers only support device tree probing, so the binding
document is included in this patch.

Based on the original patches by Mitsuhiro Kimura (Ethernet driver) and Masaru
Nagai (PTP driver).

Signed-off-by: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>
Signed-off-by: Masaru Nagai <masaru.nagai.vx@renesas.com>
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
This patch is against David Miller's 'net-next.git' repo.

Changes in version 2:
- fixed the bug where interrupts weren't re-enabled in ravb_set_ringparam();
- added netif_device_{detach|attach}() calls to ravb_set_ringparam(), fixing
  TX watchdog being fired during ring resize;
- made ravb_ring_{init|free}(), ravb_free_dma_buffer(), and ravb_[ed]mac_init()
  calls conditional fixing crash/memory  leak when resizing rings of  a closed
  device;
- fixed the order of setting SKBTX_IN_PROGRESS and skb_tx_timestamp() calls;
- implemented ndo_set_rx_mode() method;
- implemented SIOCGHWTSTAMP ioctl(), turning *if* statement in ravb_do_ioctl()
  into *switch*;
- merged ravb_wait_clear() and ravb_wait_setting() into ravb_wait(), switching
  to 100 times more frequent polling and simplfying the code;
- replaced unbounded register polling loops with ravb_wait() calls;
- switched to using 'struct timespec64' instead of 'struct timespec' whenever
  possible, adding code to read/write extra PTP registers;
- added dma_[rw]mb() barrier calls where needed (with comments);
- renamed ravb_reset() to ravb_config(), fixed the comment grammar there;
- renamed ravb_mac_init() to ravb_emac_init(), removing now unneeded parameter,
  renamed local variable there,  simplified the expression assigned to that
  variable;
- removed now unneeded parameter from ravb_dmac_init() along with the code
  disabling interrupts, moved netif_start_queue() from this function to its
  callers;
- renamed ravb_hwtstamp_ioctl() to ravb_hwtstamp_set(), renaming the 2nd
  parameter, removing unused 3rd parameter, and turning the initializer for
  one of the local variables into assignment;
- removed unused parameter from ravb_rx();
- renamed variables in ravb_get_tx_tstamp() and ravb_close();
- changed the "compatible" property values;
- removed unneeded parens and netif_queue_stopped() call in ravb_poll(), fixed
  the comment there;
- simplified ravb_ptp_is_config();
- realigned some lines/names/operators throughout;
- sorted the variable declarations by length descending thoughout;
- capitalize the first letter in the comments thoughout;
- added Masaru Nagai to MODULE_AUTHOR();
- mentioned the PTP driver in the changelog.

 Documentation/devicetree/bindings/net/renesas,ravb.txt |   48 
 drivers/net/ethernet/renesas/Kconfig                   |   14 
 drivers/net/ethernet/renesas/Makefile                  |    1 
 drivers/net/ethernet/renesas/ravb.c                    | 3089 +++++++++++++++++
 4 files changed, 3152 insertions(+)

Index: net-next/Documentation/devicetree/bindings/net/renesas,ravb.txt
===================================================================
--- /dev/null
+++ net-next/Documentation/devicetree/bindings/net/renesas,ravb.txt
@@ -0,0 +1,48 @@
+* Renesas Electronics Ethernet AVB
+
+This file provides information on what the device node for the Ethernet AVB
+interface contains.
+
+Required properties:
+- compatible: "renesas,etheravb-r8a7790" if the device is a part of R8A7790 SoC.
+	      "renesas,etheravb-r8a7794" if the device is a part of R8A7794 SoC.
+- reg: offset and length of (1) the register block and (2) the stream buffer.
+- interrupts: interrupt specifier for the sole interrupt.
+- phy-mode: see ethernet.txt file in the same directory.
+- phy-handle: see ethernet.txt file in the same directory.
+- #address-cells: number of address cells for the MDIO bus, must be equal to 1.
+- #size-cells: number of size cells on the MDIO bus, must be equal to 0.
+- clocks: clock phandle and specifier pair.
+- pinctrl-0: phandle, referring to a default pin configuration node.
+
+Optional properties:
+- interrupt-parent: the phandle for the interrupt controller that services
+		    interrupts for this device.
+- pinctrl-names: pin configuration state name ("default").
+- renesas,no-ether-link: boolean, specify when a board does not provide a proper
+			 AVB_LINK signal.
+- renesas,ether-link-active-low: boolean, specify when the AVB_LINK signal is
+				 active-low instead of normal active-high.
+
+Example:
+
+	ethernet@e6800000 {
+		compatible = "renesas,etheravb-r8a7790";
+		reg = <0 0xe6800000 0 0x800>, <0 0xee0e8000 0 0x4000>;
+		interrupt-parent = <&gic>;
+		interrupts = <0 163 IRQ_TYPE_LEVEL_HIGH>;
+		clocks = <&mstp8_clks R8A7790_CLK_ETHERAVB>;
+		phy-mode = "rmii";
+		phy-handle = <&phy0>;
+		pinctrl-0 = <&ether_pins>;
+		pinctrl-names = "default";
+		renesas,no-ether-link;
+		#address-cells = <1>;
+		#size-cells = <0>;
+
+		phy0: ethernet-phy@0 {
+			reg = <0>;
+			interrupt-parent = <&gpio2>;
+			interrupts = <15 IRQ_TYPE_LEVEL_LOW>;
+		};
+	};
Index: net-next/drivers/net/ethernet/renesas/Kconfig
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/Kconfig
+++ net-next/drivers/net/ethernet/renesas/Kconfig
@@ -15,3 +15,17 @@ config SH_ETH
 	  This driver supporting CPUs are:
 		- SH7619, SH7710, SH7712, SH7724, SH7734, SH7763, SH7757,
 		  R8A7740, R8A777x and R8A779x.
+
+config RAVB
+	tristate "Renesas Ethernet AVB support"
+	depends on HAS_DMA
+	depends on ARCH_SHMOBILE || COMPILE_TEST
+	select CRC32
+	select MII
+	select MDIO_BITBANG
+	select PHYLIB
+	select PTP_1588_CLOCK
+	help
+	  Renesas Ethernet AVB device driver.
+	  This driver supports the following SoCs:
+		- R8A779x.
Index: net-next/drivers/net/ethernet/renesas/Makefile
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/Makefile
+++ net-next/drivers/net/ethernet/renesas/Makefile
@@ -3,3 +3,4 @@
 #
 
 obj-$(CONFIG_SH_ETH) += sh_eth.o
+obj-$(CONFIG_RAVB) += ravb.o
Index: net-next/drivers/net/ethernet/renesas/ravb.c
===================================================================
--- /dev/null
+++ net-next/drivers/net/ethernet/renesas/ravb.c
@@ -0,0 +1,3089 @@
+/* Renesas Ethernet AVB device driver
+ *
+ * Copyright (C) 2014-2015 Renesas Electronics Corporation
+ * Copyright (C) 2015 Renesas Solutions Corp.
+ * Copyright (C) 2015 Cogent Embedded, Inc. <source@cogentembedded.com>
+ *
+ * Based on the SuperH Ethernet driver
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License version 2,
+ * as published by the Free Software Foundation.
+ */
+
+#include <linux/cache.h>
+#include <linux/clk.h>
+#include <linux/delay.h>
+#include <linux/dma-mapping.h>
+#include <linux/err.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/if_vlan.h>
+#include <linux/interrupt.h>
+#include <linux/io.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/mdio-bitbang.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/net_tstamp.h>
+#include <linux/of.h>
+#include <linux/of_device.h>
+#include <linux/of_irq.h>
+#include <linux/of_mdio.h>
+#include <linux/of_net.h>
+#include <linux/phy.h>
+#include <linux/platform_device.h>
+#include <linux/pm_runtime.h>
+#include <linux/ptp_clock_kernel.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+
+#define TX_TIMEOUT	(5 * HZ)
+
+#define BE_TX_RING_SIZE	64	/* TX ring size for Best Effort */
+#define BE_RX_RING_SIZE	1024	/* RX ring size for Best Effort */
+#define NC_TX_RING_SIZE	64	/* TX ring size for Network Control */
+#define NC_RX_RING_SIZE	64	/* RX ring size for Network Control */
+#define BE_TX_RING_MIN	64
+#define BE_RX_RING_MIN	64
+#define NC_TX_RING_MIN	64
+#define NC_RX_RING_MIN	64
+#define BE_TX_RING_MAX	1024
+#define BE_RX_RING_MAX	2048
+#define NC_TX_RING_MAX	128
+#define NC_RX_RING_MAX	128
+
+#define PKT_BUF_SZ	1538
+
+enum ravb_reg {
+	/* AVB-DMAC registers */
+	CCC	= 0x0000,
+	DBAT	= 0x0004,
+	DLR	= 0x0008,
+	CSR	= 0x000C,
+	CDAR0	= 0x0010,
+	CDAR1	= 0x0014,
+	CDAR2	= 0x0018,
+	CDAR3	= 0x001C,
+	CDAR4	= 0x0020,
+	CDAR5	= 0x0024,
+	CDAR6	= 0x0028,
+	CDAR7	= 0x002C,
+	CDAR8	= 0x0030,
+	CDAR9	= 0x0034,
+	CDAR10	= 0x0038,
+	CDAR11	= 0x003C,
+	CDAR12	= 0x0040,
+	CDAR13	= 0x0044,
+	CDAR14	= 0x0048,
+	CDAR15	= 0x004C,
+	CDAR16	= 0x0050,
+	CDAR17	= 0x0054,
+	CDAR18	= 0x0058,
+	CDAR19	= 0x005C,
+	CDAR20	= 0x0060,
+	CDAR21	= 0x0064,
+	ESR	= 0x0088,
+	RCR	= 0x0090,
+	RQC0	= 0x0094,
+	RQC1	= 0x0098,
+	RQC2	= 0x009C,
+	RQC3	= 0x00A0,
+	RQC4	= 0x00A4,
+	RPC	= 0x00B0,
+	UFCW	= 0x00BC,
+	UFCS	= 0x00C0,
+	UFCV0	= 0x00C4,
+	UFCV1	= 0x00C8,
+	UFCV2	= 0x00CC,
+	UFCV3	= 0x00D0,
+	UFCV4	= 0x00D4,
+	UFCD0	= 0x00E0,
+	UFCD1	= 0x00E4,
+	UFCD2	= 0x00E8,
+	UFCD3	= 0x00EC,
+	UFCD4	= 0x00F0,
+	SFO	= 0x00FC,
+	SFP0	= 0x0100,
+	SFP1	= 0x0104,
+	SFP2	= 0x0108,
+	SFP3	= 0x010C,
+	SFP4	= 0x0110,
+	SFP5	= 0x0114,
+	SFP6	= 0x0118,
+	SFP7	= 0x011C,
+	SFP8	= 0x0120,
+	SFP9	= 0x0124,
+	SFP10	= 0x0128,
+	SFP11	= 0x012C,
+	SFP12	= 0x0130,
+	SFP13	= 0x0134,
+	SFP14	= 0x0138,
+	SFP15	= 0x013C,
+	SFP16	= 0x0140,
+	SFP17	= 0x0144,
+	SFP18	= 0x0148,
+	SFP19	= 0x014C,
+	SFP20	= 0x0150,
+	SFP21	= 0x0154,
+	SFP22	= 0x0158,
+	SFP23	= 0x015C,
+	SFP24	= 0x0160,
+	SFP25	= 0x0164,
+	SFP26	= 0x0168,
+	SFP27	= 0x016C,
+	SFP28	= 0x0170,
+	SFP29	= 0x0174,
+	SFP30	= 0x0178,
+	SFP31	= 0x017C,
+	SFM0	= 0x01C0,
+	SFM1	= 0x01C4,
+	TGC	= 0x0300,
+	TCCR	= 0x0304,
+	TSR	= 0x0308,
+	TFA0	= 0x0310,
+	TFA1	= 0x0314,
+	TFA2	= 0x0318,
+	CIVR0	= 0x0320,
+	CIVR1	= 0x0324,
+	CDVR0	= 0x0328,
+	CDVR1	= 0x032C,
+	CUL0	= 0x0330,
+	CUL1	= 0x0334,
+	CLL0	= 0x0338,
+	CLL1	= 0x033C,
+	DIC	= 0x0350,
+	DIS	= 0x0354,
+	EIC	= 0x0358,
+	EIS	= 0x035C,
+	RIC0	= 0x0360,
+	RIS0	= 0x0364,
+	RIC1	= 0x0368,
+	RIS1	= 0x036C,
+	RIC2	= 0x0370,
+	RIS2	= 0x0374,
+	TIC	= 0x0378,
+	TIS	= 0x037C,
+	ISS	= 0x0380,
+	GCCR	= 0x0390,
+	GMTT	= 0x0394,
+	GPTC	= 0x0398,
+	GTI	= 0x039C,
+	GTO0	= 0x03A0,
+	GTO1	= 0x03A4,
+	GTO2	= 0x03A8,
+	GIC	= 0x03AC,
+	GIS	= 0x03B0,
+	GCPT	= 0x03B4,	/* Undocumented? */
+	GCT0	= 0x03B8,
+	GCT1	= 0x03BC,
+	GCT2	= 0x03C0,
+
+	/* E-MAC registers */
+	ECMR	= 0x0500,
+	RFLR	= 0x0508,
+	ECSR	= 0x0510,
+	ECSIPR	= 0x0518,
+	PIR	= 0x0520,
+	PSR	= 0x0528,
+	PIPR	= 0x052c,
+	MPR	= 0x0558,
+	PFTCR	= 0x055c,
+	PFRCR	= 0x0560,
+	GECMR	= 0x05b0,
+	MAHR	= 0x05c0,
+	MALR	= 0x05c8,
+	TROCR	= 0x0700,	/* Undocumented? */
+	CDCR	= 0x0708,	/* Undocumented? */
+	LCCR	= 0x0710,	/* Undocumented? */
+	CEFCR	= 0x0740,
+	FRECR	= 0x0748,
+	TSFRCR	= 0x0750,
+	TLFRCR	= 0x0758,
+	RFCR	= 0x0760,
+	CERCR	= 0x0768,	/* Undocumented? */
+	CEECR	= 0x0770,	/* Undocumented? */
+	MAFCR	= 0x0778,
+};
+
+/* Driver's parameters */
+#define RAVB_ALIGN	128
+
+/* Hardware time stamp */
+#define RAVB_TXTSTAMP_VALID	0x00000001	/* TX timestamp valid */
+#define RAVB_TXTSTAMP_ENABLED	0x00000010	/* enable TX timestampping */
+
+#define RAVB_RXTSTAMP_VALID	0x00000001	/* RX timestamp valid */
+#define RAVB_RXTSTAMP_TYPE	0x00000006	/* RX type mask */
+#define RAVB_RXTSTAMP_TYPE_V2_L2_EVENT	0x00000002
+#define RAVB_RXTSTAMP_TYPE_ALL		0x00000006
+#define RAVB_RXTSTAMP_ENABLED	0x00000010	/* enable rx timestampping */
+
+/* Register bits of the Ethernet AVB */
+/* CCC */
+enum CCC_BIT {
+	CCC_OPC		= 0x00000003,
+	CCC_OPC_RESET	= 0x00000000,
+	CCC_OPC_CONFIG	= 0x00000001,
+	CCC_OPC_OPERATION = 0x00000002,
+	CCC_DTSR	= 0x00000100,
+	CCC_CSEL	= 0x00030000,
+	CCC_CSEL_HPB	= 0x00010000,
+	CCC_CSEL_ETH_TX	= 0x00020000,
+	CCC_CSEL_GMII_REF = 0x00030000,
+	CCC_BOC		= 0x00100000,	/* Undocumented? */
+	CCC_LBME	= 0x01000000,
+};
+
+/* CSR */
+enum CSR_BIT {
+	CSR_OPS		= 0x0000000F,
+	CSR_OPS_RESET	= 0x00000001,
+	CSR_OPS_CONFIG	= 0x00000002,
+	CSR_OPS_OPERATION = 0x00000004,
+	CSR_OPS_STANDBY	= 0x00000008,	/* Undocumented? */
+	CSR_DTS		= 0x00000100,
+	CSR_TPO0	= 0x00010000,
+	CSR_TPO1	= 0x00020000,
+	CSR_TPO2	= 0x00040000,
+	CSR_TPO3	= 0x00080000,
+	CSR_RPO		= 0x00100000,
+};
+
+/* ESR */
+enum ESR_BIT {
+	ESR_EQN		= 0x0000001F,
+	ESR_ET		= 0x00000F00,
+	ESR_EIL		= 0x00001000,
+};
+
+/* RCR */
+enum RCR_BIT {
+	RCR_EFFS	= 0x00000001,
+	RCR_ENCF	= 0x00000002,
+	RCR_ESF		= 0x0000000C,
+	RCR_ETS0	= 0x00000010,
+	RCR_ETS2	= 0x00000020,
+	RCR_RFCL	= 0x1FFF0000,
+};
+
+/* RQC0/1/2/3/4 */
+enum RQC_BIT {
+	RQC_RSM0	= 0x00000003,
+	RQC_UFCC0	= 0x00000030,
+	RQC_RSM1	= 0x00000300,
+	RQC_UFCC1	= 0x00003000,
+	RQC_RSM2	= 0x00030000,
+	RQC_UFCC2	= 0x00300000,
+	RQC_RSM3	= 0x03000000,
+	RQC_UFCC3	= 0x30000000,
+};
+
+/* RPC */
+enum RPC_BIT {
+	RPC_PCNT	= 0x00000700,
+	RPC_DCNT	= 0x00FF0000,
+};
+
+/* UFCW */
+enum UFCW_BIT {
+	UFCW_WL0	= 0x0000003F,
+	UFCW_WL1	= 0x00003F00,
+	UFCW_WL2	= 0x003F0000,
+	UFCW_WL3	= 0x3F000000,
+};
+
+/* UFCS */
+enum UFCS_BIT {
+	UFCS_SL0	= 0x0000003F,
+	UFCS_SL1	= 0x00003F00,
+	UFCS_SL2	= 0x003F0000,
+	UFCS_SL3	= 0x3F000000,
+};
+
+/* UFCV0/1/2/3/4 */
+enum UFCV_BIT {
+	UFCV_CV0	= 0x0000003F,
+	UFCV_CV1	= 0x00003F00,
+	UFCV_CV2	= 0x003F0000,
+	UFCV_CV3	= 0x3F000000,
+};
+
+/* UFCD0/1/2/3/4 */
+enum UFCD_BIT {
+	UFCD_DV0	= 0x0000003F,
+	UFCD_DV1	= 0x00003F00,
+	UFCD_DV2	= 0x003F0000,
+	UFCD_DV3	= 0x3F000000,
+};
+
+/* SFO */
+enum SFO_BIT {
+	SFO_FPB		= 0x0000003F,
+};
+
+/* RTC */
+enum RTC_BIT {
+	RTC_MFL0	= 0x00000FFF,
+	RTC_MFL1	= 0x0FFF0000,
+};
+
+/* TGC */
+enum TGC_BIT {
+	TGC_TSM0	= 0x00000001,
+	TGC_TSM1	= 0x00000002,
+	TGC_TSM2	= 0x00000004,
+	TGC_TSM3	= 0x00000008,
+	TGC_TQP		= 0x00000030,
+	TGC_TQP_NONAVB	= 0x00000000,
+	TGC_TQP_AVBMODE1 = 0x00000010,
+	TGC_TQP_AVBMODE2 = 0x00000030,
+	TGC_TBD0	= 0x00000300,
+	TGC_TBD1	= 0x00003000,
+	TGC_TBD2	= 0x00030000,
+	TGC_TBD3	= 0x00300000,
+};
+
+/* TCCR */
+enum TCCR_BIT {
+	TCCR_TSRQ0	= 0x00000001,
+	TCCR_TSRQ1	= 0x00000002,
+	TCCR_TSRQ2	= 0x00000004,
+	TCCR_TSRQ3	= 0x00000008,
+	TCCR_TFEN	= 0x00000100,
+	TCCR_TFR	= 0x00000200,
+};
+
+/* TSR */
+enum TSR_BIT {
+	TSR_CCS0	= 0x00000003,
+	TSR_CCS1	= 0x0000000C,
+	TSR_TFFL	= 0x00000700,
+};
+
+/* TFA2 */
+enum TFA2_BIT {
+	TFA2_TSV	= 0x0000FFFF,
+	TFA2_TST	= 0x03FF0000,
+};
+
+/* DIC */
+enum DIC_BIT {
+	DIC_DPE1	= 0x00000002,
+	DIC_DPE2	= 0x00000004,
+	DIC_DPE3	= 0x00000008,
+	DIC_DPE4	= 0x00000010,
+	DIC_DPE5	= 0x00000020,
+	DIC_DPE6	= 0x00000040,
+	DIC_DPE7	= 0x00000080,
+	DIC_DPE8	= 0x00000100,
+	DIC_DPE9	= 0x00000200,
+	DIC_DPE10	= 0x00000400,
+	DIC_DPE11	= 0x00000800,
+	DIC_DPE12	= 0x00001000,
+	DIC_DPE13	= 0x00002000,
+	DIC_DPE14	= 0x00004000,
+	DIC_DPE15	= 0x00008000,
+};
+
+/* DIS */
+enum DIS_BIT {
+	DIS_DPF1	= 0x00000002,
+	DIS_DPF2	= 0x00000004,
+	DIS_DPF3	= 0x00000008,
+	DIS_DPF4	= 0x00000010,
+	DIS_DPF5	= 0x00000020,
+	DIS_DPF6	= 0x00000040,
+	DIS_DPF7	= 0x00000080,
+	DIS_DPF8	= 0x00000100,
+	DIS_DPF9	= 0x00000200,
+	DIS_DPF10	= 0x00000400,
+	DIS_DPF11	= 0x00000800,
+	DIS_DPF12	= 0x00001000,
+	DIS_DPF13	= 0x00002000,
+	DIS_DPF14	= 0x00004000,
+	DIS_DPF15	= 0x00008000,
+};
+
+/* EIC */
+enum EIC_BIT {
+	EIC_MREE	= 0x00000001,
+	EIC_MTEE	= 0x00000002,
+	EIC_QEE		= 0x00000004,
+	EIC_SEE		= 0x00000008,
+	EIC_CLLE0	= 0x00000010,
+	EIC_CLLE1	= 0x00000020,
+	EIC_CULE0	= 0x00000040,
+	EIC_CULE1	= 0x00000080,
+	EIC_TFFE	= 0x00000100,
+};
+
+/* EIS */
+enum EIS_BIT {
+	EIS_MREF	= 0x00000001,
+	EIS_MTEF	= 0x00000002,
+	EIS_QEF		= 0x00000004,
+	EIS_SEF		= 0x00000008,
+	EIS_CLLF0	= 0x00000010,
+	EIS_CLLF1	= 0x00000020,
+	EIS_CULF0	= 0x00000040,
+	EIS_CULF1	= 0x00000080,
+	EIS_TFFF	= 0x00000100,
+	EIS_QFS		= 0x00010000,
+};
+
+/* RIC0 */
+enum RIC0_BIT {
+	RIC0_FRE0	= 0x00000001,
+	RIC0_FRE1	= 0x00000002,
+	RIC0_FRE2	= 0x00000004,
+	RIC0_FRE3	= 0x00000008,
+	RIC0_FRE4	= 0x00000010,
+	RIC0_FRE5	= 0x00000020,
+	RIC0_FRE6	= 0x00000040,
+	RIC0_FRE7	= 0x00000080,
+	RIC0_FRE8	= 0x00000100,
+	RIC0_FRE9	= 0x00000200,
+	RIC0_FRE10	= 0x00000400,
+	RIC0_FRE11	= 0x00000800,
+	RIC0_FRE12	= 0x00001000,
+	RIC0_FRE13	= 0x00002000,
+	RIC0_FRE14	= 0x00004000,
+	RIC0_FRE15	= 0x00008000,
+	RIC0_FRE16	= 0x00010000,
+	RIC0_FRE17	= 0x00020000,
+};
+
+/* RIC0 */
+enum RIS0_BIT {
+	RIS0_FRF0	= 0x00000001,
+	RIS0_FRF1	= 0x00000002,
+	RIS0_FRF2	= 0x00000004,
+	RIS0_FRF3	= 0x00000008,
+	RIS0_FRF4	= 0x00000010,
+	RIS0_FRF5	= 0x00000020,
+	RIS0_FRF6	= 0x00000040,
+	RIS0_FRF7	= 0x00000080,
+	RIS0_FRF8	= 0x00000100,
+	RIS0_FRF9	= 0x00000200,
+	RIS0_FRF10	= 0x00000400,
+	RIS0_FRF11	= 0x00000800,
+	RIS0_FRF12	= 0x00001000,
+	RIS0_FRF13	= 0x00002000,
+	RIS0_FRF14	= 0x00004000,
+	RIS0_FRF15	= 0x00008000,
+	RIS0_FRF16	= 0x00010000,
+	RIS0_FRF17	= 0x00020000,
+};
+
+/* RIC1 */
+enum RIC1_BIT {
+	RIC1_RFWE	= 0x80000000,
+};
+
+/* RIS1 */
+enum RIS1_BIT {
+	RIS1_RFWF	= 0x80000000,
+};
+
+/* RIC2 */
+enum RIC2_BIT {
+	RIC2_QFE0	= 0x00000001,
+	RIC2_QFE1	= 0x00000002,
+	RIC2_QFE2	= 0x00000004,
+	RIC2_QFE3	= 0x00000008,
+	RIC2_QFE4	= 0x00000010,
+	RIC2_QFE5	= 0x00000020,
+	RIC2_QFE6	= 0x00000040,
+	RIC2_QFE7	= 0x00000080,
+	RIC2_QFE8	= 0x00000100,
+	RIC2_QFE9	= 0x00000200,
+	RIC2_QFE10	= 0x00000400,
+	RIC2_QFE11	= 0x00000800,
+	RIC2_QFE12	= 0x00001000,
+	RIC2_QFE13	= 0x00002000,
+	RIC2_QFE14	= 0x00004000,
+	RIC2_QFE15	= 0x00008000,
+	RIC2_QFE16	= 0x00010000,
+	RIC2_QFE17	= 0x00020000,
+	RIC2_RFFE	= 0x80000000,
+};
+
+/* RIS2 */
+enum RIS2_BIT {
+	RIS2_QFF0	= 0x00000001,
+	RIS2_QFF1	= 0x00000002,
+	RIS2_QFF2	= 0x00000004,
+	RIS2_QFF3	= 0x00000008,
+	RIS2_QFF4	= 0x00000010,
+	RIS2_QFF5	= 0x00000020,
+	RIS2_QFF6	= 0x00000040,
+	RIS2_QFF7	= 0x00000080,
+	RIS2_QFF8	= 0x00000100,
+	RIS2_QFF9	= 0x00000200,
+	RIS2_QFF10	= 0x00000400,
+	RIS2_QFF11	= 0x00000800,
+	RIS2_QFF12	= 0x00001000,
+	RIS2_QFF13	= 0x00002000,
+	RIS2_QFF14	= 0x00004000,
+	RIS2_QFF15	= 0x00008000,
+	RIS2_QFF16	= 0x00010000,
+	RIS2_QFF17	= 0x00020000,
+	RIS2_RFFF	= 0x80000000,
+};
+
+/* TIC */
+enum TIC_BIT {
+	TIC_FTE0	= 0x00000001,	/* Undocumented? */
+	TIC_FTE1	= 0x00000002,	/* Undocumented? */
+	TIC_TFUE	= 0x00000100,
+	TIC_TFWE	= 0x00000200,
+};
+
+/* TIS */
+enum TIS_BIT {
+	TIS_FTF0	= 0x00000001,	/* Undocumented? */
+	TIS_FTF1	= 0x00000002,	/* Undocumented? */
+	TIS_TFUF	= 0x00000100,
+	TIS_TFWF	= 0x00000200,
+};
+
+/* ISS */
+enum ISS_BIT {
+	ISS_FRS		= 0x00000001,	/* Undocumented? */
+	ISS_FTS		= 0x00000004,	/* Undocumented? */
+	ISS_ES		= 0x00000040,
+	ISS_MS		= 0x00000080,
+	ISS_TFUS	= 0x00000100,
+	ISS_TFWS	= 0x00000200,
+	ISS_RFWS	= 0x00001000,
+	ISS_CGIS	= 0x00002000,
+	ISS_DPS1	= 0x00020000,
+	ISS_DPS2	= 0x00040000,
+	ISS_DPS3	= 0x00080000,
+	ISS_DPS4	= 0x00100000,
+	ISS_DPS5	= 0x00200000,
+	ISS_DPS6	= 0x00400000,
+	ISS_DPS7	= 0x00800000,
+	ISS_DPS8	= 0x01000000,
+	ISS_DPS9	= 0x02000000,
+	ISS_DPS10	= 0x04000000,
+	ISS_DPS11	= 0x08000000,
+	ISS_DPS12	= 0x10000000,
+	ISS_DPS13	= 0x20000000,
+	ISS_DPS14	= 0x40000000,
+	ISS_DPS15	= 0x80000000,
+};
+
+/* GCCR */
+enum GCCR_BIT {
+	GCCR_TCR	= 0x00000003,
+	GCCR_TCR_NOREQ	= 0x00000000, /* No request */
+	GCCR_TCR_RESET	= 0x00000001, /* gPTP/AVTP presentation timer reset */
+	GCCR_TCR_CAPTURE = 0x00000003, /* Capture value set in GCCR.TCSS */
+	GCCR_LTO	= 0x00000004,
+	GCCR_LTI	= 0x00000008,
+	GCCR_LPTC	= 0x00000010,
+	GCCR_LMTT	= 0x00000020,
+	GCCR_TCSS	= 0x00000300,
+	GCCR_TCSS_GPTP	= 0x00000000,	/* gPTP timer value */
+	GCCR_TCSS_ADJGPTP = 0x00000100, /* Adjusted gPTP timer value */
+	GCCR_TCSS_AVTP	= 0x00000200,	/* AVTP presentation time value */
+};
+
+/* GTI */
+enum GTI_BIT {
+	GTI_TIV		= 0x0FFFFFFF,
+};
+
+/* GIC */
+enum GIC_BIT {
+	GIC_PTCE	= 0x00000001,	/* Undocumented? */
+	GIC_PTME	= 0x00000004,
+};
+
+/* GIS */
+enum GIS_BIT {
+	GIS_PTCF	= 0x00000001,	/* Undocumented? */
+	GIS_PTMF	= 0x00000004,
+};
+
+/* ECMR */
+enum ECMR_BIT {
+	ECMR_PRM	= 0x00000001,
+	ECMR_DM		= 0x00000002,
+	ECMR_TE		= 0x00000020,
+	ECMR_RE		= 0x00000040,
+	ECMR_MPDE	= 0x00000200,
+	ECMR_TXF	= 0x00010000,	/* Undocumented? */
+	ECMR_RXF	= 0x00020000,
+	ECMR_PFR	= 0x00040000,
+	ECMR_ZPF	= 0x00080000,	/* Undocumented? */
+	ECMR_RZPF	= 0x00100000,
+	ECMR_DPAD	= 0x00200000,
+	ECMR_RCSC	= 0x00800000,
+	ECMR_TRCCM	= 0x04000000,
+};
+
+/* ECSR */
+enum ECSR_BIT {
+	ECSR_ICD	= 0x00000001,
+	ECSR_MPD	= 0x00000002,
+	ECSR_LCHNG	= 0x00000004,
+	ECSR_PHYI	= 0x00000008,
+};
+
+/* ECSIPR */
+enum ECSIPR_BIT {
+	ECSIPR_ICDIP	= 0x00000001,
+	ECSIPR_MPDIP	= 0x00000002,
+	ECSIPR_LCHNGIP	= 0x00000004,	/* Undocumented? */
+};
+
+/* PIR */
+enum PIR_BIT {
+	PIR_MDC		= 0x00000001,
+	PIR_MMD		= 0x00000002,
+	PIR_MDO		= 0x00000004,
+	PIR_MDI		= 0x00000008,
+};
+
+/* PSR */
+enum PSR_BIT {
+	PSR_LMON	= 0x00000001,
+};
+
+/* PIPR */
+enum PIPR_BIT {
+	PIPR_PHYIP	= 0x00000001,
+};
+
+/* MPR */
+enum MPR_BIT {
+	MPR_MP		= 0x0000ffff,
+};
+
+/* GECMR */
+enum GECMR_BIT {
+	GECMR_SPEED	= 0x00000001,
+	GECMR_SPEED_100	= 0x00000000,
+	GECMR_SPEED_1000 = 0x00000001,
+};
+
+/* The Ethernet AVB descriptor definitions. */
+enum DT {
+	/* Frame data */
+	DT_FMID		= 4,
+	DT_FSTART	= 5,
+	DT_FEND		= 6,
+	DT_FSINGLE	= 7,
+	/* Chain control */
+	DT_LINK		= 8,
+	DT_LINKFIX	= 9,
+	DT_EOS		= 10,
+	/* HW/SW arbitration */
+	DT_FEMPTY	= 12,
+	DT_FEMPTY_IS	= 13,
+	DT_FEMPTY_IC	= 14,
+	DT_FEMPTY_ND	= 15,
+	DT_LEMPTY	= 2,
+	DT_EEMPTY	= 3,
+	/* 0, 1, 11 are reserved */
+};
+
+struct ravb_desc {
+#ifdef __LITTLE_ENDIAN
+	u32 ds: 12;	/* Descriptor size */
+	u32 cc: 12;	/* Content control */
+	u32 die: 4;	/* Descriptor interrupt enable */
+			/* 0: disable, other: enable */
+	u32 dt: 4;	/* Descriptor type */
+#else
+	u32 dt: 4;	/* Descriptor type */
+	u32 die: 4;	/* Descriptor interrupt enable */
+			/* 0: disable, other: enable */
+	u32 cc: 12;	/* Content control */
+	u32 ds: 12;	/* Descriptor size */
+#endif
+	u32 dptr;	/* Descriptor pointer */
+};
+
+struct ravb_rx_desc {
+#ifdef __LITTLE_ENDIAN
+	u32 ds: 12;	/* Descriptor size */
+	u32 ei: 1;	/* Error indication */
+	u32 ps: 2;	/* Padding selection */
+	u32 tr: 1;	/* Truncation indication */
+	u32 msc: 8;	/* MAC status code */
+	u32 die: 4;	/* Descriptor interrupt enable */
+			/* 0: disable, other: enable */
+	u32 dt: 4;	/* Descriptor type */
+#else
+	u32 dt: 4;	/* Descriptor type */
+	u32 die: 4;	/* Descriptor interrupt enable */
+			/* 0: disable, other: enable */
+	u32 msc: 8;	/* MAC status code */
+	u32 ps: 2;	/* Padding selection */
+	u32 ei: 1;	/* Error indication */
+	u32 tr: 1;	/* Truncation indication */
+	u32 ds: 12;	/* Descriptor size */
+#endif
+	u32 dptr;	/* Descpriptor pointer */
+};
+
+struct ravb_ex_rx_desc {
+#ifdef __LITTLE_ENDIAN
+	u32 ds: 12;	/* Descriptor size */
+	u32 ei: 1;	/* Error indication */
+	u32 ps: 2;	/* Padding selection */
+	u32 tr: 1;	/* Truncation indication */
+	u32 msc: 8;	/* MAC status code */
+	u32 die: 4;	/* Descriptor interrupt enable */
+			/* 0: disable, other: enable */
+	u32 dt: 4;	/* Descriptor type */
+#else
+	u32 dt: 4;	/* Descriptor type */
+	u32 die: 4;	/* Descriptor interrupt enable */
+			/* 0: disable, other: enable */
+	u32 msc: 8;	/* MAC status code */
+	u32 ps: 2;	/* Padding selection */
+	u32 ei: 1;	/* Error indication */
+	u32 tr: 1;	/* Truncation indication */
+	u32 ds: 12;	/* Descriptor size */
+#endif
+	u32 dptr;	/* Descpriptor pointer */
+	u32 ts_n;	/* Timestampe nsec */
+	u32 ts_sl;	/* Timestamp low */
+#ifdef __LITTLE_ENDIAN
+	u32 res: 16;	/* Reserved bits */
+	u32 ts_sh: 16;	/* Timestamp high */
+#else
+	u32 ts_sh: 16;	/* Timestamp high */
+	u32 res: 16;	/* Reserved bits */
+#endif
+};
+
+/* E-MAC status code */
+enum MSC_BIT {
+	MSC_CRC		= 0x01, /* Frame CRC error */
+	MSC_RFE		= 0x02, /* Frame reception error (flagged by PHY) */
+	MSC_RTSF	= 0x04, /* Frame length error (frame too short) */
+	MSC_RTLF	= 0x08, /* Frame length error (frame too long) */
+	MSC_FRE		= 0x10, /* Fraction error (not a multiple of 8 bits) */
+	MSC_CRL		= 0x20, /* Carrier lost */
+	MSC_CEEF	= 0x40, /* Carrier extension error */
+	MSC_MC		= 0x80, /* Multicast frame reception */
+};
+
+struct ravb_tx_desc {
+#ifdef __LITTLE_ENDIAN
+	u32 ds: 12;	/* Descriptor size */
+	u32 tag: 10;	/* Frame tag */
+	u32 tsr: 1;	/* Timestamp storage request */
+	u32 msc: 1;	/* MAC status storage request */
+	u32 die: 4;	/* Descriptor interrupt enable */
+			/* 0: disable, other: enable */
+	u32 dt: 4;	/* Descriptor type */
+#else
+	u32 dt: 4;	/* Descriptor type */
+	u32 die: 4;	/* Descriptor interrupt enable */
+			/* 0: disable, other: enable */
+	u32 msc: 1;	/* MAC status storage request */
+	u32 tsr: 1;	/* Timestamp storage request */
+	u32 tag: 10;	/* Frame tag */
+	u32 ds: 12;	/* Descriptor size */
+#endif
+	u32 dptr;	/* Descpriptor pointer */
+};
+
+#define DBAT_ENTRY_NUM	22
+#define RX_QUEUE_OFFSET	4
+#define NUM_RX_QUEUE	2
+#define NUM_TX_QUEUE	2
+
+enum RAVB_QUEUE {
+	RAVB_BE = 0,	/* Best Effort Queue */
+	RAVB_NC,	/* Network Control Queue */
+};
+
+struct ravb_tstamp_skb {
+	struct list_head list;
+	struct sk_buff *skb;
+	u16 tag;
+};
+
+struct ravb_ptp_perout {
+	u32 target;
+	u32 period;
+};
+
+#define N_EXT_TS	1
+#define N_PER_OUT	1
+
+struct ravb_ptp {
+	struct ptp_clock *clock;
+	struct ptp_clock_info info;
+	u32 default_addend;
+	u32 current_addend;
+	int extts[N_EXT_TS];
+	struct ravb_ptp_perout perout[N_PER_OUT];
+};
+
+struct ravb_private {
+	struct net_device *ndev;
+	struct platform_device *pdev;
+	void __iomem *addr;
+	struct mdiobb_ctrl mdiobb;
+	u32 num_rx_ring[NUM_RX_QUEUE];
+	u32 num_tx_ring[NUM_TX_QUEUE];
+	u32 desc_bat_size;
+	dma_addr_t desc_bat_dma;
+	struct ravb_desc *desc_bat;
+	dma_addr_t rx_desc_dma[NUM_RX_QUEUE];
+	dma_addr_t tx_desc_dma[NUM_TX_QUEUE];
+	struct ravb_ex_rx_desc *rx_ring[NUM_RX_QUEUE];
+	struct ravb_tx_desc *tx_ring[NUM_TX_QUEUE];
+	struct sk_buff **rx_skb[NUM_RX_QUEUE];
+	struct sk_buff **tx_skb[NUM_TX_QUEUE];
+	void **tx_buffers[NUM_TX_QUEUE];
+	u32 rx_over_errors;
+	u32 rx_fifo_errors;
+	struct net_device_stats stats[NUM_RX_QUEUE];
+	u32 tstamp_tx_ctrl;
+	u32 tstamp_rx_ctrl;
+	struct list_head ts_skb_list;
+	u32 ts_skb_tag;
+	struct ravb_ptp ptp;
+	spinlock_t lock;		/* Register access lock */
+	u32 cur_rx[NUM_RX_QUEUE];	/* Consumer ring indices */
+	u32 dirty_rx[NUM_RX_QUEUE];	/* Producer ring indices */
+	u32 cur_tx[NUM_TX_QUEUE];
+	u32 dirty_tx[NUM_TX_QUEUE];
+	u32 rx_buffer_size;		/* Based on MTU+slack. */
+	int edmac_endian;
+	struct napi_struct napi;
+	/* MII transceiver section. */
+	struct mii_bus *mii_bus;	/* MDIO bus control */
+	struct phy_device *phydev;	/* PHY device control */
+	int link;
+	phy_interface_t phy_interface;
+	int msg_enable;
+	int speed;
+	int duplex;
+
+	unsigned no_avb_link:1;
+	unsigned avb_link_active_low:1;
+};
+
+#define RAVB_DEF_MSG_ENABLE \
+		(NETIF_MSG_LINK	  | \
+		 NETIF_MSG_TIMER  | \
+		 NETIF_MSG_RX_ERR | \
+		 NETIF_MSG_TX_ERR)
+
+static inline u32 ravb_read(struct net_device *ndev, enum ravb_reg reg)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+
+	return ioread32(priv->addr + reg);
+}
+
+static inline void ravb_write(struct net_device *ndev, u32 data,
+			      enum ravb_reg reg)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+
+	iowrite32(data, priv->addr + reg);
+}
+
+static int ravb_wait(struct net_device *ndev, u16 reg, u32 mask, u32 value)
+{
+	int i;
+
+	for (i = 0; i < 10000; i++) {
+		if ((ravb_read(ndev, reg) & mask) == value)
+			return 0;
+		udelay(10);
+	}
+	return -ETIMEDOUT;
+}
+
+static int ravb_config(struct net_device *ndev)
+{
+	int result;
+
+	/* Set config mode */
+	ravb_write(ndev, (ravb_read(ndev, CCC) & ~CCC_OPC) | CCC_OPC_CONFIG,
+		   CCC);
+	/* Check if the operating mode is changed to the config mode */
+	result = ravb_wait(ndev, CSR, CSR_OPS, CSR_OPS_CONFIG);
+	if (result)
+		netdev_err(ndev, "Device reset failed\n");
+
+	return result;
+}
+
+static void ravb_set_duplex(struct net_device *ndev)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+
+	if (priv->duplex)	/* Full */
+		ravb_write(ndev, ravb_read(ndev, ECMR) | ECMR_DM, ECMR);
+	else			/* Half */
+		ravb_write(ndev, ravb_read(ndev, ECMR) & ~ECMR_DM, ECMR);
+}
+
+static void ravb_set_rate(struct net_device *ndev)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+
+	switch (priv->speed) {
+	case 100:		/* 100BASE */
+		ravb_write(ndev, GECMR_SPEED_100, GECMR);
+		break;
+	case 1000:		/* 1000BASE */
+		ravb_write(ndev, GECMR_SPEED_1000, GECMR);
+		break;
+	default:
+		break;
+	}
+}
+
+static void ravb_set_buffer_align(struct sk_buff *skb)
+{
+	u32 reserve = (u32)skb->data & (RAVB_ALIGN - 1);
+
+	if (reserve)
+		skb_reserve(skb, RAVB_ALIGN - reserve);
+}
+
+/* Program the hardware MAC address from dev->dev_addr. */
+static void update_mac_address(struct net_device *ndev)
+{
+	ravb_write(ndev,
+		   (ndev->dev_addr[0] << 24) | (ndev->dev_addr[1] << 16) |
+		   (ndev->dev_addr[2] << 8)  | (ndev->dev_addr[3]), MAHR);
+	ravb_write(ndev,
+		   (ndev->dev_addr[4] << 8)  | (ndev->dev_addr[5]), MALR);
+}
+
+/* Get MAC address from the MAC address registers
+ *
+ * Ethernet AVB device doesn't have ROM for MAC address.
+ * This function gets the MAC address that was used by a bootloader.
+ */
+static void read_mac_address(struct net_device *ndev, const u8 *mac)
+{
+	if (mac) {
+		ether_addr_copy(ndev->dev_addr, mac);
+	} else {
+		ndev->dev_addr[0] = (ravb_read(ndev, MAHR) >> 24);
+		ndev->dev_addr[1] = (ravb_read(ndev, MAHR) >> 16) & 0xFF;
+		ndev->dev_addr[2] = (ravb_read(ndev, MAHR) >> 8) & 0xFF;
+		ndev->dev_addr[3] = (ravb_read(ndev, MAHR) >> 0) & 0xFF;
+		ndev->dev_addr[4] = (ravb_read(ndev, MALR) >> 8) & 0xFF;
+		ndev->dev_addr[5] = (ravb_read(ndev, MALR) >> 0) & 0xFF;
+	}
+}
+
+static void ravb_mdio_ctrl(struct mdiobb_ctrl *ctrl, u32 mask, int set)
+{
+	struct ravb_private *priv = container_of(ctrl, struct ravb_private,
+						 mdiobb);
+	u32 pir = ravb_read(priv->ndev, PIR);
+
+	if (set)
+		pir |=  mask;
+	else
+		pir &= ~mask;
+	ravb_write(priv->ndev, pir, PIR);
+}
+
+/* MDC pin control */
+static void ravb_set_mdc(struct mdiobb_ctrl *ctrl, int level)
+{
+	ravb_mdio_ctrl(ctrl, PIR_MDC, level);
+}
+
+/* Data I/O pin control */
+static void ravb_set_mdio_dir(struct mdiobb_ctrl *ctrl, int output)
+{
+	ravb_mdio_ctrl(ctrl, PIR_MMD, output);
+}
+
+/* Set data bit */
+static void ravb_set_mdio_data(struct mdiobb_ctrl *ctrl, int value)
+{
+	ravb_mdio_ctrl(ctrl, PIR_MDO, value);
+}
+
+/* Get data bit */
+static int ravb_get_mdio_data(struct mdiobb_ctrl *ctrl)
+{
+	struct ravb_private *priv = container_of(ctrl, struct ravb_private,
+						 mdiobb);
+
+	return (ravb_read(priv->ndev, PIR) & PIR_MDI) != 0;
+}
+
+/* MDIO bus control struct */
+static struct mdiobb_ops bb_ops = {
+	.owner = THIS_MODULE,
+	.set_mdc = ravb_set_mdc,
+	.set_mdio_dir = ravb_set_mdio_dir,
+	.set_mdio_data = ravb_set_mdio_data,
+	.get_mdio_data = ravb_get_mdio_data,
+};
+
+/* Free skb and buffers for Ethernet AVB */
+static void ravb_ring_free(struct net_device *ndev, int q)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+	int i;
+
+	/* Free RX skb ringbuffer */
+	if (priv->rx_skb[q]) {
+		for (i = 0; i < priv->num_rx_ring[q]; i++)
+			dev_kfree_skb(priv->rx_skb[q][i]);
+	}
+	kfree(priv->rx_skb[q]);
+	priv->rx_skb[q] = NULL;
+
+	/* Free TX skb ringbuffer */
+	if (priv->tx_skb[q]) {
+		for (i = 0; i < priv->num_tx_ring[q]; i++)
+			dev_kfree_skb(priv->tx_skb[q][i]);
+	}
+	kfree(priv->tx_skb[q]);
+	priv->tx_skb[q] = NULL;
+
+	/* Free aligned TX buffers */
+	if (priv->tx_buffers[q]) {
+		for (i = 0; i < priv->num_tx_ring[q]; i++)
+			kfree(priv->tx_buffers[q][i]);
+	}
+	kfree(priv->tx_buffers[q]);
+	priv->tx_buffers[q] = NULL;
+}
+
+/* Format skb and descriptor buffer for Ethernet AVB */
+static void ravb_ring_format(struct net_device *ndev, int q)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+	struct ravb_ex_rx_desc *rx_desc = NULL;
+	struct ravb_tx_desc *tx_desc = NULL;
+	struct ravb_desc *desc = NULL;
+	int rx_ring_size = sizeof(*rx_desc) * priv->num_rx_ring[q];
+	int tx_ring_size = sizeof(*tx_desc) * priv->num_tx_ring[q];
+	int buffer_size = priv->rx_buffer_size + RAVB_ALIGN - 1;
+	struct sk_buff *skb;
+	dma_addr_t dma_addr;
+	void *buffer;
+	int i;
+
+	priv->cur_rx[q] = 0;
+	priv->cur_tx[q] = 0;
+	priv->dirty_rx[q] = 0;
+	priv->dirty_tx[q] = 0;
+	memset(priv->rx_ring[q], 0, rx_ring_size);
+	/* Build RX ring buffer */
+	for (i = 0; i < priv->num_rx_ring[q]; i++) {
+		priv->rx_skb[q][i] = NULL;
+		skb = netdev_alloc_skb(ndev, buffer_size);
+		if (!skb)
+			break;
+		ravb_set_buffer_align(skb);
+		/* RX descriptor */
+		rx_desc = &priv->rx_ring[q][i];
+		/* The size of the buffer should be on 16-byte boundary. */
+		rx_desc->ds = ALIGN(priv->rx_buffer_size, 16);
+		dma_addr = dma_map_single(&ndev->dev, skb->data, rx_desc->ds,
+					  DMA_FROM_DEVICE);
+		if (dma_mapping_error(&ndev->dev, dma_addr)) {
+			dev_kfree_skb(skb);
+			break;
+		}
+		priv->rx_skb[q][i] = skb;
+		rx_desc->dptr = dma_addr;
+		rx_desc->dt = DT_FEMPTY;
+	}
+	rx_desc = &priv->rx_ring[q][i];
+	rx_desc->dptr = (u32)priv->rx_desc_dma[q];
+	rx_desc->dt = DT_LINKFIX; /* type */
+	priv->dirty_rx[q] = (u32)(i - priv->num_rx_ring[q]);
+
+	memset(priv->tx_ring[q], 0, tx_ring_size);
+	/* Build TX ring buffer */
+	for (i = 0; i < priv->num_tx_ring[q]; i++) {
+		priv->tx_skb[q][i] = NULL;
+		priv->tx_buffers[q][i] = NULL;
+		buffer = kmalloc(buffer_size, GFP_ATOMIC);
+		if (!buffer)
+			break;
+		/* Aligned TX buffer */
+		priv->tx_buffers[q][i] = buffer;
+		tx_desc = &priv->tx_ring[q][i];
+		tx_desc->dt = DT_EEMPTY;
+	}
+	tx_desc = &priv->tx_ring[q][i];
+	tx_desc->dptr = (u32)priv->tx_desc_dma[q];
+	tx_desc->dt = DT_LINKFIX; /* type */
+
+	/* RX descriptor base address for best effort */
+	desc = &priv->desc_bat[RX_QUEUE_OFFSET + q];
+	desc->dt = DT_LINKFIX; /* type */
+	desc->dptr = (u32)priv->rx_desc_dma[q];
+
+	/* TX descriptor base address for best effort */
+	desc = &priv->desc_bat[q];
+	desc->dt = DT_LINKFIX; /* type */
+	desc->dptr = (u32)priv->tx_desc_dma[q];
+}
+
+/* Init skb and descriptor buffer for Ethernet AVB */
+static int ravb_ring_init(struct net_device *ndev, int q)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+	int rx_ring_size = 0, tx_ring_size;
+
+	/* Allocate RX and TX skb rings */
+	priv->rx_skb[q] = kcalloc(priv->num_rx_ring[q],
+				  sizeof(*priv->rx_skb[q]), GFP_KERNEL);
+	priv->tx_skb[q] = kcalloc(priv->num_tx_ring[q],
+				  sizeof(*priv->tx_skb[q]), GFP_KERNEL);
+	if (!priv->rx_skb[q] || !priv->tx_skb[q])
+		goto skb_ring_free;
+
+	/* Allocate rings for the aligned buffers */
+	priv->tx_buffers[q] = kcalloc(priv->num_tx_ring[q],
+				      sizeof(*priv->tx_buffers[q]), GFP_KERNEL);
+	if (!priv->tx_buffers[q])
+		goto skb_ring_free;
+
+	/* Allocate all RX descriptors. */
+	rx_ring_size = sizeof(struct ravb_ex_rx_desc) *
+		      (priv->num_rx_ring[q] + 1);
+	priv->rx_ring[q] = dma_alloc_coherent(NULL, rx_ring_size,
+					      &priv->rx_desc_dma[q],
+					      GFP_KERNEL);
+	if (!priv->rx_ring[q])
+		goto skb_ring_free;
+
+	priv->dirty_rx[q] = 0;
+
+	/* Allocate all TX descriptors. */
+	tx_ring_size = sizeof(struct ravb_tx_desc) * (priv->num_tx_ring[q] + 1);
+	priv->tx_ring[q] = dma_alloc_coherent(NULL, tx_ring_size,
+					      &priv->tx_desc_dma[q],
+					      GFP_KERNEL);
+	if (!priv->tx_ring[q])
+		goto desc_ring_free;
+
+	return 0;
+
+desc_ring_free:
+	/* Free DMA buffer */
+	dma_free_coherent(NULL, rx_ring_size,
+			  priv->rx_ring[q], priv->rx_desc_dma[q]);
+
+skb_ring_free:
+	/* Free RX and TX skb ring buffer */
+	ravb_ring_free(ndev, q);
+	priv->tx_ring[q] = NULL;
+	priv->rx_ring[q] = NULL;
+
+	return -ENOMEM;
+}
+
+static void ravb_free_dma_buffer(struct ravb_private *priv)
+{
+	int ring_size;
+	int q;
+
+	for (q = RAVB_BE; q < NUM_RX_QUEUE; q++) {
+		if (priv->rx_ring[q]) {
+			ring_size = sizeof(struct ravb_ex_rx_desc) *
+				    (priv->num_rx_ring[q] + 1);
+			dma_free_coherent(NULL, ring_size, priv->rx_ring[q],
+					  priv->rx_desc_dma[q]);
+			priv->rx_ring[q] = NULL;
+		}
+	}
+
+	for (q = RAVB_BE; q < NUM_TX_QUEUE; q++) {
+		if (priv->tx_ring[q]) {
+			ring_size = sizeof(struct ravb_tx_desc) *
+				    (priv->num_tx_ring[q] + 1);
+			dma_free_coherent(NULL, ring_size, priv->tx_ring[q],
+					  priv->tx_desc_dma[q]);
+			priv->tx_ring[q] = NULL;
+		}
+	}
+}
+
+/* E-MAC init function */
+static void ravb_emac_init(struct net_device *ndev)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+	u32 ecmr;
+
+	/* Receive frame limit set register */
+	ravb_write(ndev, ndev->mtu + ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN, RFLR);
+
+	/* PAUSE prohibition */
+	ecmr =  ravb_read(ndev, ECMR);
+	ecmr &= ECMR_DM;
+	ecmr |= ECMR_ZPF | (priv->duplex ? ECMR_DM : 0) | ECMR_TE | ECMR_RE;
+	ravb_write(ndev, ecmr, ECMR);
+
+	ravb_set_rate(ndev);
+
+	/* Set MAC address */
+	update_mac_address(ndev);
+
+	ravb_write(ndev, 1, MPR);
+
+	/* E-MAC status register clear */
+	ravb_write(ndev, ECSR_ICD | ECSR_MPD, ECSR);
+
+	/* E-MAC interrupt enable register */
+	ravb_write(ndev, ECSIPR_ICDIP | ECSIPR_MPDIP | ECSIPR_LCHNGIP, ECSIPR);
+}
+
+/* Device init function for Ethernet AVB */
+static int ravb_dmac_init(struct net_device *ndev)
+{
+	int result;
+
+	/* Set CONFIG mode */
+	result = ravb_config(ndev);
+	if (result)
+		return result;
+
+	/* Descriptor format */
+	ravb_ring_format(ndev, RAVB_BE);
+	ravb_ring_format(ndev, RAVB_NC);
+
+#if defined(__LITTLE_ENDIAN)
+	ravb_write(ndev, ravb_read(ndev, CCC) & ~CCC_BOC, CCC);
+#else
+	ravb_write(ndev, ravb_read(ndev, CCC) | CCC_BOC, CCC);
+#endif
+
+	/* Set AVB RX */
+	ravb_write(ndev, RCR_EFFS | RCR_ENCF | RCR_ETS0 | 0x18000000, RCR);
+
+	/* Set FIFO size */
+	ravb_write(ndev, TGC_TQP_AVBMODE1 | 0x00222200, TGC);
+
+	/* Timestamp enable */
+	ravb_write(ndev, TCCR_TFEN, TCCR);
+
+	/* Interrupt enable: */
+	/* Frame receive */
+	ravb_write(ndev, RIC0_FRE0 | RIC0_FRE1, RIC0);
+	/* Receive FIFO full warning */
+	ravb_write(ndev, RIC1_RFWE, RIC1);
+	/* Receive FIFO full error, descriptor empty */
+	ravb_write(ndev, RIC2_QFE0 | RIC2_QFE1 | RIC2_RFFE, RIC2);
+	/* Frame transmited, timestamp FIFO updated */
+	ravb_write(ndev, TIC_FTE0 | TIC_FTE1 | TIC_TFUE, TIC);
+
+	/* Setting the control will start the AVB-DMAC process. */
+	ravb_write(ndev, (ravb_read(ndev, CCC) & ~CCC_OPC) | CCC_OPC_OPERATION,
+		   CCC);
+
+	return 0;
+}
+
+/* Free TX skb function for AVB-IP */
+static int ravb_tx_free(struct net_device *ndev, int q)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+	struct net_device_stats *stats = &priv->stats[q];
+	struct ravb_tx_desc *desc;
+	int free_num = 0;
+	int entry = 0;
+
+	for (; priv->cur_tx[q] - priv->dirty_tx[q] > 0; priv->dirty_tx[q]++) {
+		entry = priv->dirty_tx[q] % priv->num_tx_ring[q];
+		desc = &priv->tx_ring[q][entry];
+		if (desc->dt != DT_FEMPTY)
+			break;
+		/* Descriptor type must be checked before all other reads */
+		dma_rmb();
+		/* Free the original skb. */
+		if (priv->tx_skb[q][entry]) {
+			dma_unmap_single(&ndev->dev, desc->dptr, desc->ds,
+					 DMA_TO_DEVICE);
+			dev_kfree_skb_any(priv->tx_skb[q][entry]);
+			priv->tx_skb[q][entry] = NULL;
+			free_num++;
+		}
+		stats->tx_packets++;
+		stats->tx_bytes += desc->ds;
+		desc->dt = DT_EEMPTY;
+	}
+	return free_num;
+}
+
+static void ravb_get_tx_tstamp(struct net_device *ndev)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+	struct ravb_tstamp_skb *ts_skb, *ts_skb2;
+	struct skb_shared_hwtstamps shhwtstamps;
+	struct sk_buff *skb;
+	struct timespec64 ts;
+	u16 tag, tfa_tag;
+	int count;
+	u32 tfa2;
+
+	count = (ravb_read(ndev, TSR) & TSR_TFFL) >> 8;
+	while (count--) {
+		tfa2 = ravb_read(ndev, TFA2);
+		tfa_tag = (tfa2 & TFA2_TST) >> 16;
+		ts.tv_nsec = (u64)ravb_read(ndev, TFA0);
+		ts.tv_sec = ((u64)(tfa2 & TFA2_TSV) << 32) |
+			    ravb_read(ndev, TFA1);
+		memset(&shhwtstamps, 0, sizeof(shhwtstamps));
+		shhwtstamps.hwtstamp = timespec64_to_ktime(ts);
+		list_for_each_entry_safe(ts_skb, ts_skb2, &priv->ts_skb_list,
+					 list) {
+			skb = ts_skb->skb;
+			tag = ts_skb->tag;
+			list_del(&ts_skb->list);
+			kfree(ts_skb);
+			if (tag == tfa_tag) {
+				skb_tstamp_tx(skb, &shhwtstamps);
+				break;
+			}
+		}
+		ravb_write(ndev, ravb_read(ndev, TCCR) | TCCR_TFR, TCCR);
+	}
+}
+
+/* Packet receive function for Ethernet AVB */
+static bool ravb_rx(struct net_device *ndev, int *quota, int q)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+	int entry = priv->cur_rx[q] % priv->num_rx_ring[q];
+	int boguscnt = (priv->dirty_rx[q] + priv->num_rx_ring[q]) -
+			priv->cur_rx[q];
+	struct net_device_stats *stats = &priv->stats[q];
+	int skb_size = priv->rx_buffer_size + RAVB_ALIGN - 1;
+	struct ravb_ex_rx_desc *desc;
+	struct sk_buff *skb;
+	dma_addr_t dma_addr;
+	struct timespec64 ts;
+	u16 pkt_len = 0;
+	u8  desc_status;
+	int limit;
+
+	if (quota)
+		boguscnt = min(boguscnt, *quota);
+	limit = boguscnt;
+	desc = &priv->rx_ring[q][entry];
+	while (desc->dt != DT_FEMPTY) {
+		/* Descriptor type must be checked before all other reads */
+		dma_rmb();
+		desc_status = desc->msc;
+		pkt_len = desc->ds;
+
+		if (--boguscnt < 0)
+			break;
+
+		if (desc_status & MSC_MC)
+			stats->multicast++;
+
+		if (desc_status & (MSC_CRC | MSC_RFE | MSC_RTSF | MSC_RTLF |
+				   MSC_CEEF)) {
+			stats->rx_errors++;
+			if (desc_status & MSC_CRC)
+				stats->rx_crc_errors++;
+			if (desc_status & MSC_RFE)
+				stats->rx_frame_errors++;
+			if (desc_status & (MSC_RTLF | MSC_RTSF))
+				stats->rx_length_errors++;
+			if (desc_status & MSC_CEEF)
+				stats->rx_missed_errors++;
+		} else {
+			u32 get_ts = priv->tstamp_rx_ctrl & RAVB_RXTSTAMP_TYPE;
+
+			skb = priv->rx_skb[q][entry];
+			priv->rx_skb[q][entry] = NULL;
+			dma_sync_single_for_cpu(&ndev->dev, desc->dptr,
+						ALIGN(priv->rx_buffer_size, 16),
+						DMA_FROM_DEVICE);
+			get_ts &= (q == RAVB_NC) ?
+					RAVB_RXTSTAMP_TYPE_V2_L2_EVENT :
+					~RAVB_RXTSTAMP_TYPE_V2_L2_EVENT;
+			if (get_ts) {
+				struct skb_shared_hwtstamps *shhwtstamps;
+
+				shhwtstamps = skb_hwtstamps(skb);
+				memset(shhwtstamps, 0, sizeof(*shhwtstamps));
+				ts.tv_sec = ((u64)desc->ts_sh << 32) |
+					    desc->ts_sl;
+				ts.tv_nsec = (u64)desc->ts_n;
+				shhwtstamps->hwtstamp = timespec64_to_ktime(ts);
+			}
+			skb_put(skb, pkt_len);
+			skb->protocol = eth_type_trans(skb, ndev);
+			if (q == RAVB_NC)
+				netif_rx(skb);
+			else
+				netif_receive_skb(skb);
+			stats->rx_packets++;
+			stats->rx_bytes += pkt_len;
+		}
+
+		entry = (++priv->cur_rx[q]) % priv->num_rx_ring[q];
+		desc = &priv->rx_ring[q][entry];
+	}
+
+	/* Refill the RX ring buffers. */
+	for (; priv->cur_rx[q] - priv->dirty_rx[q] > 0; priv->dirty_rx[q]++) {
+		entry = priv->dirty_rx[q] % priv->num_rx_ring[q];
+		desc = &priv->rx_ring[q][entry];
+		/* The size of the buffer should be on 16-byte boundary. */
+		desc->ds = ALIGN(priv->rx_buffer_size, 16);
+
+		if (!priv->rx_skb[q][entry]) {
+			skb = netdev_alloc_skb(ndev, skb_size);
+			if (!skb)
+				break;	/* Better luck next round. */
+			ravb_set_buffer_align(skb);
+			dma_unmap_single(&ndev->dev, desc->dptr, desc->ds,
+					 DMA_FROM_DEVICE);
+			dma_addr = dma_map_single(&ndev->dev, skb->data,
+						  desc->ds, DMA_FROM_DEVICE);
+			skb_checksum_none_assert(skb);
+			if (dma_mapping_error(&ndev->dev, dma_addr)) {
+				dev_kfree_skb_any(skb);
+				break;
+			}
+			desc->dptr = dma_addr;
+			priv->rx_skb[q][entry] = skb;
+		}
+		/* Descriptor type must be set after all the above writes */
+		dma_wmb();
+		desc->dt = DT_FEMPTY;
+	}
+
+	if (quota)
+		*quota -= limit - (++boguscnt);
+
+	return boguscnt <= 0;
+}
+
+static void ravb_rcv_snd_disable(struct net_device *ndev)
+{
+	/* Disable TX and RX */
+	ravb_write(ndev, ravb_read(ndev, ECMR) & ~(ECMR_RE | ECMR_TE), ECMR);
+}
+
+static void ravb_rcv_snd_enable(struct net_device *ndev)
+{
+	/* Enable TX and RX */
+	ravb_write(ndev, ravb_read(ndev, ECMR) | ECMR_RE | ECMR_TE, ECMR);
+}
+
+/* function for waiting dma process finished */
+static void ravb_wait_stop_dma(struct net_device *ndev)
+{
+	/* Wait for stopping the hardware TX process */
+	ravb_wait(ndev, TCCR, TCCR_TSRQ0 | TCCR_TSRQ1 | TCCR_TSRQ2 | TCCR_TSRQ3,
+		  0);
+
+	ravb_wait(ndev, CSR, CSR_TPO0 | CSR_TPO1 | CSR_TPO2 | CSR_TPO3, 0);
+
+	/* Stop the E-MAC's RX processes. */
+	ravb_write(ndev, ravb_read(ndev, ECMR) & ~ECMR_RE, ECMR);
+
+	/* Wait for stopping the RX DMA process */
+	ravb_wait(ndev, CSR, CSR_RPO, 0);
+}
+
+/* Caller must hold the lock */
+static void ravb_ptp_update_compare(struct ravb_private *priv, u32 ns)
+{
+	struct net_device *ndev = priv->ndev;
+	/* When the comparison value (GPTC.PTCV) is in range of
+	 * [x-1 to x+1] (x is the configured increment value in
+	 * GTI.TIV), it may happen that a comparison match is
+	 * not detected when the timer wraps around.
+	 */
+	u32 gti_ns_plus_1 = (priv->ptp.current_addend >> 20) + 1;
+
+	if (ns < gti_ns_plus_1)
+		ns = gti_ns_plus_1;
+	else if (ns > 0 - gti_ns_plus_1)
+		ns = 0 - gti_ns_plus_1;
+
+	ravb_write(ndev, ns, GPTC);
+	ravb_write(ndev, ravb_read(ndev, GCCR) | GCCR_LPTC, GCCR);
+	if (ravb_read(ndev, CSR) & CSR_OPS_OPERATION)
+		ravb_wait(ndev, GCCR, GCCR_LPTC, 0);
+}
+
+/* E-MAC interrupt handler */
+static void ravb_emac_interrupt(struct net_device *ndev)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+	u32 ecsr, psr;
+
+	ecsr = ravb_read(ndev, ECSR);
+	ravb_write(ndev, ecsr, ECSR);	/* clear interrupt */
+	if (ecsr & ECSR_ICD)
+		ndev->stats.tx_carrier_errors++;
+	if (ecsr & ECSR_LCHNG) {
+		/* Link changed */
+		if (priv->no_avb_link)
+			return;
+		psr = ravb_read(ndev, PSR);
+		if (priv->avb_link_active_low)
+			psr ^= PSR_LMON;
+		if (!(psr & PSR_LMON)) {
+			/* DIsable RX and TX */
+			ravb_rcv_snd_disable(ndev);
+		} else {
+			/* Enable RX and TX */
+			ravb_rcv_snd_enable(ndev);
+		}
+	}
+}
+
+/* Error interrupt handler */
+static void ravb_error_interrupt(struct net_device *ndev)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+	u32 eis, ris2;
+
+	eis = ravb_read(ndev, EIS);
+	ravb_write(ndev, ~EIS_QFS, EIS);
+	if (eis & EIS_QFS) {
+		ris2 = ravb_read(ndev, RIS2);
+		ravb_write(ndev, ~(RIS2_QFF0 | RIS2_RFFF), RIS2);
+
+		/* Receive Descriptor Empty int */
+		if (ris2 & RIS2_QFF0)
+			priv->stats[RAVB_BE].rx_over_errors++;
+
+		    /* Receive Descriptor Empty int */
+		if (ris2 & RIS2_QFF1)
+			priv->stats[RAVB_NC].rx_over_errors++;
+
+		/* Receive FIFO Overflow int */
+		if (ris2 & RIS2_RFFF)
+			priv->rx_fifo_errors++;
+	}
+}
+
+static irqreturn_t ravb_interrupt(int irq, void *dev_id)
+{
+	struct net_device *ndev = dev_id;
+	struct ravb_private *priv = netdev_priv(ndev);
+	irqreturn_t result = IRQ_NONE;
+	u32 iss;
+
+	spin_lock(&priv->lock);
+	/* Get interrupt status */
+	iss = ravb_read(ndev, ISS);
+
+	/* Received and transmited interrupts */
+	if (iss & (ISS_FRS | ISS_FTS | ISS_TFUS)) {
+		u32 ris0, ric0, tic, tis;
+
+		ris0 = ravb_read(ndev, RIS0);
+		ric0 = ravb_read(ndev, RIC0);
+		tis  = ravb_read(ndev, TIS);
+		tic  = ravb_read(ndev, TIC);
+		ravb_write(ndev, ~(TIS_FTF1 | TIS_TFUF), TIS);
+
+		/* Received network control queue */
+		if (ris0 & RIS0_FRF1) {
+			ravb_write(ndev, ~RIS0_FRF1, RIS0);
+			/* Timestamp of network control packets that is based
+			 * on IEEE802.1AS, is used time synchronization of PTP.
+			 * It should not be handled by NAPI scheduling, because
+			 * it needs to be received as soon as possible.
+			 */
+			ravb_rx(ndev, NULL, RAVB_NC);
+			result = IRQ_HANDLED;
+		}
+
+		/* Timestamp updated */
+		if (tis & TIS_TFUF) {
+			ravb_get_tx_tstamp(ndev);
+			result = IRQ_HANDLED;
+		}
+
+		/* Transmited network control queue */
+		if (tis & TIS_FTF1) {
+			ravb_tx_free(ndev, RAVB_NC);
+			netif_wake_queue(ndev);
+			result = IRQ_HANDLED;
+		}
+
+		/* Received and transmited best effort queue */
+		if (((ris0 & ric0) & RIS0_FRF0) || ((tis & tic) & TIS_FTF0)) {
+			if (napi_schedule_prep(&priv->napi)) {
+				/* Mask RX and TX interrupts */
+				ravb_write(ndev, ric0 & ~RIC0_FRE0, RIC0);
+				ravb_write(ndev, tic  & ~TIC_FTE0,  TIC);
+				__napi_schedule(&priv->napi);
+			} else {
+				netdev_warn(ndev,
+					    "ignoring interrupt, rx status 0x%08x, rx mask 0x%08x,\n",
+					    ris0, ric0);
+				netdev_warn(ndev,
+					    "                    tx status 0x%08x, tx mask 0x%08x.\n",
+					    tis, tic);
+			}
+			result = IRQ_HANDLED;
+		}
+	}
+
+	/* E-MAC status summary */
+	if (iss & ISS_MS) {
+		ravb_emac_interrupt(ndev);
+		result = IRQ_HANDLED;
+	}
+
+	/* Error status summary */
+	if (iss & ISS_ES) {
+		ravb_error_interrupt(ndev);
+		result = IRQ_HANDLED;
+	}
+
+	if (iss & ISS_CGIS) {
+		u32 gis = ravb_read(ndev, GIS);
+
+		gis &= ravb_read(ndev, GIC);
+		if (gis & GIS_PTCF) {
+			struct ptp_clock_event event;
+
+			event.type = PTP_CLOCK_EXTTS;
+			event.index = 0;
+			event.timestamp = ravb_read(ndev, GCPT);
+			ptp_clock_event(priv->ptp.clock, &event);
+		}
+		if (gis & GIS_PTMF) {
+			struct ravb_ptp_perout *perout = priv->ptp.perout;
+
+			if (perout->period) {
+				perout->target += perout->period;
+				ravb_ptp_update_compare(priv, perout->target);
+			}
+		}
+
+		if (gis) {
+			ravb_write(ndev, ~gis, GIS);
+			result = IRQ_HANDLED;
+		}
+	}
+
+	spin_unlock(&priv->lock);
+	return result;
+}
+
+static int ravb_poll(struct napi_struct *napi, int budget)
+{
+	struct ravb_private *priv = container_of(napi, struct ravb_private,
+						 napi);
+	struct net_device *ndev = napi->dev;
+	unsigned long flags;
+	int quota = budget;
+	u32 ris0, tis;
+
+	for (;;) {
+		tis = ravb_read(ndev, TIS);
+		ris0 = ravb_read(ndev, RIS0);
+		if (!((ris0 & RIS0_FRF0) || (tis & TIS_FTF0)))
+			break;
+
+		/* Processing RX Descriptor Ring */
+		if (ris0 & RIS0_FRF0) {
+			/* Clear RX interrupt */
+			ravb_write(ndev, ~RIS0_FRF0, RIS0);
+			if (ravb_rx(ndev, &quota, RAVB_BE))
+				goto out;
+		}
+		/* Processing TX Descriptor Ring */
+		if (tis & TIS_FTF0) {
+			/* Clear TX interrupt */
+			ravb_write(ndev, ~TIS_FTF0, TIS);
+			spin_lock_irqsave(&priv->lock, flags);
+			ravb_tx_free(ndev, RAVB_BE);
+			netif_wake_queue(ndev);
+			spin_unlock_irqrestore(&priv->lock, flags);
+		}
+	}
+
+	napi_complete(napi);
+
+	/* Re-enable RX/TX interrupts */
+	spin_lock_irqsave(&priv->lock, flags);
+	ravb_write(ndev, ravb_read(ndev, RIC0) | RIC0_FRE0, RIC0);
+	ravb_write(ndev, ravb_read(ndev, TIC)  | TIC_FTE0,  TIC);
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	/* Receive error message handling */
+	priv->rx_over_errors =  priv->stats[RAVB_BE].rx_over_errors;
+	priv->rx_over_errors += priv->stats[RAVB_NC].rx_over_errors;
+	if (priv->rx_over_errors != ndev->stats.rx_over_errors) {
+		ndev->stats.rx_over_errors = priv->rx_over_errors;
+		netif_err(priv, rx_err, ndev, "Receive Descriptor Empty\n");
+	}
+	if (priv->rx_fifo_errors != ndev->stats.rx_fifo_errors) {
+		ndev->stats.rx_fifo_errors = priv->rx_fifo_errors;
+		netif_err(priv, rx_err, ndev, "Receive FIFO Overflow\n");
+	}
+out:
+	return budget - quota;
+}
+
+/* PHY state control function */
+static void ravb_adjust_link(struct net_device *ndev)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+	struct phy_device *phydev = priv->phydev;
+	int new_state = 0;
+
+	if (phydev->link) {
+		if (phydev->duplex != priv->duplex) {
+			new_state = 1;
+			priv->duplex = phydev->duplex;
+			ravb_set_duplex(ndev);
+		}
+
+		if (phydev->speed != priv->speed) {
+			new_state = 1;
+			priv->speed = phydev->speed;
+			ravb_set_rate(ndev);
+		}
+		if (!priv->link) {
+			ravb_write(ndev, ravb_read(ndev, ECMR) & ~ECMR_TXF,
+				   ECMR);
+			new_state = 1;
+			priv->link = phydev->link;
+			if (priv->no_avb_link)
+				ravb_rcv_snd_enable(ndev);
+		}
+	} else if (priv->link) {
+		new_state = 1;
+		priv->link = 0;
+		priv->speed = 0;
+		priv->duplex = -1;
+		if (priv->no_avb_link)
+			ravb_rcv_snd_disable(ndev);
+	}
+
+	if (new_state && netif_msg_link(priv))
+		phy_print_status(phydev);
+}
+
+/* PHY init function */
+static int ravb_phy_init(struct net_device *ndev)
+{
+	struct device_node *np = ndev->dev.parent->of_node;
+	struct ravb_private *priv = netdev_priv(ndev);
+	struct phy_device *phydev;
+	struct device_node *pn;
+
+	priv->link = 0;
+	priv->speed = 0;
+	priv->duplex = -1;
+
+	/* Try connecting to PHY */
+	pn = of_parse_phandle(np, "phy-handle", 0);
+	phydev = of_phy_connect(ndev, pn, ravb_adjust_link, 0,
+				priv->phy_interface);
+	if (!phydev) {
+		netdev_err(ndev, "failed to connect PHY\n");
+		return -ENOENT;
+	}
+
+	netdev_info(ndev, "attached PHY %d (IRQ %d) to driver %s\n",
+		    phydev->addr, phydev->irq, phydev->drv->name);
+
+	priv->phydev = phydev;
+
+	return 0;
+}
+
+/* PHY control start function */
+static int ravb_phy_start(struct net_device *ndev)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+	int result;
+
+	result = ravb_phy_init(ndev);
+	if (result)
+		return result;
+
+	phy_start(priv->phydev);
+
+	return 0;
+}
+
+static int ravb_get_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+	int result = -ENODEV;
+	unsigned long flags;
+
+	if (priv->phydev) {
+		spin_lock_irqsave(&priv->lock, flags);
+		result = phy_ethtool_gset(priv->phydev, ecmd);
+		spin_unlock_irqrestore(&priv->lock, flags);
+	}
+
+	return result;
+}
+
+static int ravb_set_settings(struct net_device *ndev, struct ethtool_cmd *ecmd)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+	unsigned long flags;
+	int result;
+
+	if (!priv->phydev)
+		return -ENODEV;
+
+	spin_lock_irqsave(&priv->lock, flags);
+
+	/* Disable TX and RX */
+	ravb_rcv_snd_disable(ndev);
+
+	result = phy_ethtool_sset(priv->phydev, ecmd);
+	if (result)
+		goto error_exit;
+
+	if (ecmd->duplex == DUPLEX_FULL)
+		priv->duplex = 1;
+	else
+		priv->duplex = 0;
+
+	ravb_set_duplex(ndev);
+
+error_exit:
+	mdelay(1);
+
+	/* Enable TX and RX */
+	ravb_rcv_snd_enable(ndev);
+
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	return result;
+}
+
+static int ravb_nway_reset(struct net_device *ndev)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+	int result = -ENODEV;
+	unsigned long flags;
+
+	if (priv->phydev) {
+		spin_lock_irqsave(&priv->lock, flags);
+		result = phy_start_aneg(priv->phydev);
+		spin_unlock_irqrestore(&priv->lock, flags);
+	}
+
+	return result;
+}
+
+static u32 ravb_get_msglevel(struct net_device *ndev)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+
+	return priv->msg_enable;
+}
+
+static void ravb_set_msglevel(struct net_device *ndev, u32 value)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+
+	priv->msg_enable = value;
+}
+
+static const char ravb_gstrings_stats[][ETH_GSTRING_LEN] = {
+	"rx_queue_0_current",
+	"tx_queue_0_current",
+	"rx_queue_0_dirty",
+	"tx_queue_0_dirty",
+	"rx_queue_0_packets",
+	"tx_queue_0_packets",
+	"rx_queue_0_bytes",
+	"tx_queue_0_bytes",
+	"rx_queue_0_mcast_packets",
+	"rx_queue_0_errors",
+	"rx_queue_0_crc_errors",
+	"rx_queue_0_frame_errors",
+	"rx_queue_0_length_errors",
+	"rx_queue_0_missed_errors",
+	"rx_queue_0_over_errors",
+
+	"rx_queue_1_current",
+	"tx_queue_1_current",
+	"rx_queue_1_dirty",
+	"tx_queue_1_dirty",
+	"rx_queue_1_packets",
+	"tx_queue_1_packets",
+	"rx_queue_1_bytes",
+	"tx_queue_1_bytes",
+	"rx_queue_1_mcast_packets",
+	"rx_queue_1_errors",
+	"rx_queue_1_crc_errors",
+	"rx_queue_1_frame_errors_",
+	"rx_queue_1_length_errors",
+	"rx_queue_1_missed_errors",
+	"rx_queue_1_over_errors",
+};
+
+#define RAVB_STATS_LEN	ARRAY_SIZE(ravb_gstrings_stats)
+
+static int ravb_get_sset_count(struct net_device *netdev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return RAVB_STATS_LEN;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static void ravb_get_ethtool_stats(struct net_device *ndev,
+				   struct ethtool_stats *stats, u64 *data)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+	int i = 0;
+	int q;
+
+	/* Device-specific stats */
+	for (q = RAVB_BE; q < NUM_RX_QUEUE; q++) {
+		struct net_device_stats *stats = &priv->stats[q];
+
+		data[i++] = priv->cur_rx[q];
+		data[i++] = priv->cur_tx[q];
+		data[i++] = priv->dirty_rx[q];
+		data[i++] = priv->dirty_tx[q];
+		data[i++] = stats->rx_packets;
+		data[i++] = stats->tx_packets;
+		data[i++] = stats->rx_bytes;
+		data[i++] = stats->tx_bytes;
+		data[i++] = stats->multicast;
+		data[i++] = stats->rx_errors;
+		data[i++] = stats->rx_crc_errors;
+		data[i++] = stats->rx_frame_errors;
+		data[i++] = stats->rx_length_errors;
+		data[i++] = stats->rx_missed_errors;
+		data[i++] = stats->rx_over_errors;
+	}
+}
+
+static void ravb_get_strings(struct net_device *ndev, u32 stringset, u8 *data)
+{
+	switch (stringset) {
+	case ETH_SS_STATS:
+		memcpy(data, *ravb_gstrings_stats, sizeof(ravb_gstrings_stats));
+		break;
+	}
+}
+
+static void ravb_get_ringparam(struct net_device *ndev,
+			       struct ethtool_ringparam *ring)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+
+	ring->rx_max_pending = BE_RX_RING_MAX;
+	ring->tx_max_pending = BE_TX_RING_MAX;
+	ring->rx_pending = priv->num_rx_ring[RAVB_BE];
+	ring->tx_pending = priv->num_tx_ring[RAVB_BE];
+}
+
+static int ravb_set_ringparam(struct net_device *ndev,
+			      struct ethtool_ringparam *ring)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+	int result;
+
+	if (ring->tx_pending > BE_TX_RING_MAX ||
+	    ring->rx_pending > BE_RX_RING_MAX ||
+	    ring->tx_pending < BE_TX_RING_MIN ||
+	    ring->rx_pending < BE_RX_RING_MIN)
+		return -EINVAL;
+	if (ring->rx_mini_pending || ring->rx_jumbo_pending)
+		return -EINVAL;
+
+	if (netif_running(ndev)) {
+		netif_device_detach(ndev);
+		netif_tx_disable(ndev);
+		/* Wait for DMA stopping */
+		ravb_wait_stop_dma(ndev);
+
+		/* Stop AVB-DMAC process */
+		result = ravb_config(ndev);
+		if (result < 0) {
+			netdev_err(ndev,
+				   "Cannot set ringparam! Any AVB processes are still running?\n");
+			return result;
+		}
+		synchronize_irq(ndev->irq);
+
+		/* Free all the skbuffs in the RX queue. */
+		ravb_ring_free(ndev, RAVB_BE);
+		ravb_ring_free(ndev, RAVB_NC);
+		/* Free DMA buffer */
+		ravb_free_dma_buffer(priv);
+	}
+
+	/* Set new parameters */
+	priv->num_rx_ring[RAVB_BE] = ring->rx_pending;
+	priv->num_tx_ring[RAVB_BE] = ring->tx_pending;
+	priv->num_rx_ring[RAVB_NC] = NC_RX_RING_SIZE;
+	priv->num_tx_ring[RAVB_NC] = NC_TX_RING_SIZE;
+
+	if (netif_running(ndev)) {
+		result = ravb_ring_init(ndev, RAVB_BE);
+		if (result < 0) {
+			netdev_err(ndev, "%s: ravb_ring_init(RAVB_BE) failed\n",
+				   __func__);
+			return result;
+		}
+
+		result = ravb_ring_init(ndev, RAVB_NC);
+		if (result < 0) {
+			netdev_err(ndev, "%s: ravb_ring_init(RAVB_NC) failed\n",
+				   __func__);
+			return result;
+		}
+
+		result = ravb_dmac_init(ndev);
+		if (result < 0) {
+			netdev_err(ndev, "%s: ravb_dmac_init() failed\n",
+				   __func__);
+			return result;
+		}
+
+		ravb_emac_init(ndev);
+
+		netif_device_attach(ndev);
+	}
+
+	return 0;
+}
+
+static int ravb_get_ts_info(struct net_device *ndev,
+			    struct ethtool_ts_info *info)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+
+	info->so_timestamping =
+		SOF_TIMESTAMPING_TX_SOFTWARE |
+		SOF_TIMESTAMPING_RX_SOFTWARE |
+		SOF_TIMESTAMPING_SOFTWARE |
+		SOF_TIMESTAMPING_TX_HARDWARE |
+		SOF_TIMESTAMPING_RX_HARDWARE |
+		SOF_TIMESTAMPING_RAW_HARDWARE;
+	info->tx_types = (1 << HWTSTAMP_TX_OFF) | (1 << HWTSTAMP_TX_ON);
+	info->rx_filters =
+		(1 << HWTSTAMP_FILTER_NONE) |
+		(1 << HWTSTAMP_FILTER_PTP_V2_L2_EVENT) |
+		(1 << HWTSTAMP_FILTER_ALL);
+	info->phc_index = ptp_clock_index(priv->ptp.clock);
+
+	return 0;
+}
+
+static const struct ethtool_ops ravb_ethtool_ops = {
+	.get_settings		= ravb_get_settings,
+	.set_settings		= ravb_set_settings,
+	.nway_reset		= ravb_nway_reset,
+	.get_msglevel		= ravb_get_msglevel,
+	.set_msglevel		= ravb_set_msglevel,
+	.get_link		= ethtool_op_get_link,
+	.get_strings		= ravb_get_strings,
+	.get_ethtool_stats	= ravb_get_ethtool_stats,
+	.get_sset_count		= ravb_get_sset_count,
+	.get_ringparam		= ravb_get_ringparam,
+	.set_ringparam		= ravb_set_ringparam,
+	.get_ts_info		= ravb_get_ts_info,
+};
+
+/* Network device open function for Ethernet AVB */
+static int ravb_open(struct net_device *ndev)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+	int result;
+
+	napi_enable(&priv->napi);
+
+	result = request_irq(ndev->irq, ravb_interrupt, IRQF_SHARED, ndev->name,
+			     ndev);
+	if (result) {
+		netdev_err(ndev, "cannot request IRQ\n");
+		goto out_napi_off;
+	}
+
+	/* Descriptor set */
+	/* +26 gets the maximum ethernet encapsulation, +7 & ~7 because the
+	 * card needs room to do 8 byte alignment, +2 so we can reserve
+	 * the first 2 bytes, and +16 gets room for the status word from the
+	 * card.
+	 */
+	priv->rx_buffer_size = (ndev->mtu <= 1492 ? PKT_BUF_SZ :
+				(((ndev->mtu + 26 + 7) & ~7) + 2 + 16));
+
+	result = ravb_ring_init(ndev, RAVB_BE);
+	if (result)
+		goto out_free_irq;
+	result = ravb_ring_init(ndev, RAVB_NC);
+	if (result)
+		goto out_free_irq;
+
+	/* Device init */
+	result = ravb_dmac_init(ndev);
+	if (result)
+		goto out_free_irq;
+	ravb_emac_init(ndev);
+
+	netif_start_queue(ndev);
+
+	/* PHY control start */
+	result = ravb_phy_start(ndev);
+	if (result)
+		goto out_free_irq;
+
+	return 0;
+
+out_free_irq:
+	free_irq(ndev->irq, ndev);
+out_napi_off:
+	napi_disable(&priv->napi);
+	return result;
+}
+
+/* Timeout function for Ethernet AVB */
+static void ravb_tx_timeout(struct net_device *ndev)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+	int i, q;
+
+	netif_stop_queue(ndev);
+
+	netif_err(priv, tx_err, ndev,
+		  "transmit timed out, status %8.8x, resetting...\n",
+		  ravb_read(ndev, ISS));
+
+	/* tx_errors count up */
+	ndev->stats.tx_errors++;
+
+	/* Free all the skbuffs */
+	for (q = RAVB_BE; q < NUM_RX_QUEUE; q++) {
+		for (i = 0; i < priv->num_rx_ring[q]; i++) {
+			dev_kfree_skb(priv->rx_skb[q][i]);
+			priv->rx_skb[q][i] = NULL;
+		}
+	}
+	for (q = RAVB_BE; q < NUM_TX_QUEUE; q++) {
+		for (i = 0; i < priv->num_tx_ring[q]; i++) {
+			dev_kfree_skb(priv->tx_skb[q][i]);
+			priv->tx_skb[q][i] = NULL;
+			kfree(priv->tx_buffers[q][i]);
+			priv->tx_buffers[q][i] = NULL;
+		}
+	}
+
+	/* Device init */
+	ravb_dmac_init(ndev);
+	ravb_emac_init(ndev);
+	netif_start_queue(ndev);
+}
+
+/* Packet transmit function for Ethernet AVB */
+static int ravb_start_xmit(struct sk_buff *skb, struct net_device *ndev)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+	struct ravb_tstamp_skb *ts_skb = NULL;
+	struct ravb_tx_desc *desc;
+	unsigned long flags;
+	void *buffer;
+	u32 entry;
+	u32 tccr;
+	int q;
+
+	/* If skb needs TX timestamp, it is handled in network control queue */
+	q = (skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) ? RAVB_NC : RAVB_BE;
+
+	spin_lock_irqsave(&priv->lock, flags);
+	if (priv->cur_tx[q] - priv->dirty_tx[q] >= priv->num_tx_ring[q] - 4) {
+		if (!ravb_tx_free(ndev, q)) {
+			netif_warn(priv, tx_queued, ndev, "TX FD exhausted.\n");
+			netif_stop_queue(ndev);
+			spin_unlock_irqrestore(&priv->lock, flags);
+			return NETDEV_TX_BUSY;
+		}
+	}
+	entry = priv->cur_tx[q] % priv->num_tx_ring[q];
+	priv->cur_tx[q]++;
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	if (skb_put_padto(skb, ETH_ZLEN))
+		return NETDEV_TX_OK;
+
+	priv->tx_skb[q][entry] = skb;
+	buffer = PTR_ALIGN(priv->tx_buffers[q][entry], RAVB_ALIGN);
+	memcpy(buffer, skb->data, skb->len);
+	desc = &priv->tx_ring[q][entry];
+	desc->ds = skb->len;
+	desc->dptr = dma_map_single(&ndev->dev, buffer, skb->len,
+				    DMA_TO_DEVICE);
+	if (dma_mapping_error(&ndev->dev, desc->dptr)) {
+		dev_kfree_skb_any(skb);
+		priv->tx_skb[q][entry] = NULL;
+		return NETDEV_TX_OK;
+	}
+
+	/* TX timestamp required */
+	if (q == RAVB_NC) {
+		ts_skb = kmalloc(sizeof(*ts_skb), GFP_ATOMIC);
+		if (!ts_skb) {
+			netdev_err(ndev,
+				   "Cannot allocate skb list element for HW timestamp\n");
+			return -ENOMEM;
+		}
+		ts_skb->skb = skb;
+		ts_skb->tag = priv->ts_skb_tag++;
+		priv->ts_skb_tag %= 0x400;
+		list_add_tail(&ts_skb->list, &priv->ts_skb_list);
+
+		/* TAG and timestamp required flag */
+		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
+		skb_tx_timestamp(skb);
+		desc->tsr = 1;
+		desc->tag = ts_skb->tag;
+	}
+
+	/* Descriptor type must be set after all the above writes */
+	dma_wmb();
+	desc->dt = DT_FSINGLE;
+
+	spin_lock_irqsave(&priv->lock, flags);
+	tccr = ravb_read(ndev, TCCR);
+	if (!(tccr & (TCCR_TSRQ0 << q)))
+		ravb_write(ndev, tccr | (TCCR_TSRQ0 << q), TCCR);
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	return NETDEV_TX_OK;
+}
+
+static struct net_device_stats *ravb_get_stats(struct net_device *ndev)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+	struct net_device_stats *nstats, *stats0, *stats1;
+
+	nstats = &ndev->stats;
+	stats0 = &priv->stats[RAVB_BE];
+	stats1 = &priv->stats[RAVB_NC];
+
+	nstats->tx_dropped += ravb_read(ndev, TROCR);
+	ravb_write(ndev, 0, TROCR);	/* (write clear) */
+	nstats->collisions += ravb_read(ndev, CDCR);
+	ravb_write(ndev, 0, CDCR);	/* (write clear) */
+	nstats->tx_carrier_errors += ravb_read(ndev, LCCR);
+	ravb_write(ndev, 0, LCCR);	/* (write clear) */
+
+	nstats->tx_carrier_errors += ravb_read(ndev, CERCR);
+	ravb_write(ndev, 0, CERCR);	/* (write clear) */
+	nstats->tx_carrier_errors += ravb_read(ndev, CEECR);
+	ravb_write(ndev, 0, CEECR);	/* (write clear) */
+
+	nstats->rx_packets = stats0->rx_packets + stats1->rx_packets;
+	nstats->tx_packets = stats0->tx_packets + stats1->tx_packets;
+	nstats->rx_bytes = stats0->rx_bytes + stats1->rx_bytes;
+	nstats->tx_bytes = stats0->tx_bytes + stats1->tx_bytes;
+	nstats->multicast = stats0->multicast + stats1->multicast;
+	nstats->rx_errors = stats0->rx_errors + stats1->rx_errors;
+	nstats->rx_crc_errors = stats0->rx_crc_errors + stats1->rx_crc_errors;
+	nstats->rx_frame_errors =
+		stats0->rx_frame_errors + stats1->rx_frame_errors;
+	nstats->rx_length_errors =
+		stats0->rx_length_errors + stats1->rx_length_errors;
+	nstats->rx_missed_errors =
+		stats0->rx_missed_errors + stats1->rx_missed_errors;
+	nstats->rx_over_errors =
+		stats0->rx_over_errors + stats1->rx_over_errors;
+
+	return nstats;
+}
+
+/* Update promiscuous bit */
+static void ravb_set_rx_mode(struct net_device *ndev)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+	unsigned long flags;
+	u32 ecmr;
+
+	spin_lock_irqsave(&priv->lock, flags);
+	ecmr = ravb_read(ndev, ECMR);
+	if (ndev->flags & IFF_PROMISC)
+		ecmr |=  ECMR_PRM;
+	else
+		ecmr &= ~ECMR_PRM;
+	ravb_write(ndev, ecmr, ECMR);
+	spin_unlock_irqrestore(&priv->lock, flags);
+}
+
+/* Device close function for Ethernet AVB */
+static int ravb_close(struct net_device *ndev)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+	struct ravb_tstamp_skb *ts_skb, *ts_skb2;
+
+	netif_stop_queue(ndev);
+
+	/* Disable interrupts by clearing the interrupt masks. */
+	ravb_write(ndev, 0, RIC0);
+	ravb_write(ndev, 0, RIC1);
+	ravb_write(ndev, 0, RIC2);
+	ravb_write(ndev, 0, TIC);
+
+	/* Wait for DMA stop */
+	ravb_wait_stop_dma(ndev);
+
+	/* Set the config mode to stop the AVB-DMAC's processes */
+	if (ravb_config(ndev) < 0)
+		netdev_err(ndev,
+			   "Device will be stopped after HW processes are done.\n");
+
+	/* Clear the timestamp list */
+	list_for_each_entry_safe(ts_skb, ts_skb2, &priv->ts_skb_list, list) {
+		list_del(&ts_skb->list);
+		kfree(ts_skb);
+	}
+
+	/* PHY disconnect */
+	if (priv->phydev) {
+		phy_stop(priv->phydev);
+		phy_disconnect(priv->phydev);
+		priv->phydev = NULL;
+	}
+
+	free_irq(ndev->irq, ndev);
+
+	napi_disable(&priv->napi);
+
+	/* Free all the skbs in the RX queue. */
+	ravb_ring_free(ndev, RAVB_BE);
+	ravb_ring_free(ndev, RAVB_NC);
+
+	/* Free DMA buffer */
+	ravb_free_dma_buffer(priv);
+
+	return 0;
+}
+
+static int ravb_hwtstamp_get(struct net_device *ndev, struct ifreq *req)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+	struct hwtstamp_config config;
+
+	config.flags = 0;
+	config.tx_type = priv->tstamp_tx_ctrl ? HWTSTAMP_TX_ON :
+						HWTSTAMP_TX_OFF;
+	if (priv->tstamp_rx_ctrl & RAVB_RXTSTAMP_TYPE_V2_L2_EVENT)
+		config.rx_filter = HWTSTAMP_FILTER_PTP_V2_L2_EVENT;
+	else if (priv->tstamp_rx_ctrl & RAVB_RXTSTAMP_TYPE_ALL)
+		config.rx_filter = HWTSTAMP_FILTER_ALL;
+	else
+		config.rx_filter = HWTSTAMP_FILTER_NONE;
+
+	return copy_to_user(req->ifr_data, &config, sizeof(config)) ?
+		-EFAULT : 0;
+}
+
+/* Control hardware time stamping */
+static int ravb_hwtstamp_set(struct net_device *ndev, struct ifreq *req)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+	struct hwtstamp_config config;
+	u32 tstamp_rx_ctrl = RAVB_RXTSTAMP_ENABLED;
+	u32 tstamp_tx_ctrl;
+
+	if (copy_from_user(&config, req->ifr_data, sizeof(config)))
+		return -EFAULT;
+
+	/* Reserved for future extensions */
+	if (config.flags)
+		return -EINVAL;
+
+	switch (config.tx_type) {
+	case HWTSTAMP_TX_OFF:
+		tstamp_tx_ctrl = 0;
+		break;
+	case HWTSTAMP_TX_ON:
+		tstamp_tx_ctrl = RAVB_TXTSTAMP_ENABLED;
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	switch (config.rx_filter) {
+	case HWTSTAMP_FILTER_NONE:
+		tstamp_rx_ctrl = 0;
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
+		tstamp_rx_ctrl |= RAVB_RXTSTAMP_TYPE_V2_L2_EVENT;
+		break;
+	default:
+		config.rx_filter = HWTSTAMP_FILTER_ALL;
+		tstamp_rx_ctrl |= RAVB_RXTSTAMP_TYPE_ALL;
+	}
+
+	priv->tstamp_tx_ctrl = tstamp_tx_ctrl;
+	priv->tstamp_rx_ctrl = tstamp_rx_ctrl;
+
+	return copy_to_user(req->ifr_data, &config, sizeof(config)) ?
+		-EFAULT : 0;
+}
+
+/* ioctl to device function */
+static int ravb_do_ioctl(struct net_device *ndev, struct ifreq *req, int cmd)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+	struct phy_device *phydev = priv->phydev;
+
+	if (!netif_running(ndev))
+		return -EINVAL;
+
+	if (!phydev)
+		return -ENODEV;
+
+	switch (cmd) {
+	case SIOCGHWTSTAMP:
+		return ravb_hwtstamp_get(ndev, req);
+	case SIOCSHWTSTAMP:
+		return ravb_hwtstamp_set(ndev, req);
+	}
+
+	return phy_mii_ioctl(phydev, req, cmd);
+}
+
+static const struct net_device_ops ravb_netdev_ops = {
+	.ndo_open		= ravb_open,
+	.ndo_stop		= ravb_close,
+	.ndo_start_xmit		= ravb_start_xmit,
+	.ndo_get_stats		= ravb_get_stats,
+	.ndo_set_rx_mode	= ravb_set_rx_mode,
+	.ndo_tx_timeout		= ravb_tx_timeout,
+	.ndo_do_ioctl		= ravb_do_ioctl,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+};
+
+static void ravb_ptp_tcr_request(struct ravb_private *priv, int request)
+{
+	struct net_device *ndev = priv->ndev;
+
+	if (ravb_read(ndev, CSR) & CSR_OPS_OPERATION) {
+		ravb_wait(ndev, GCCR, GCCR_TCR, GCCR_TCR_NOREQ);
+		ravb_write(ndev, ravb_read(ndev, GCCR) | request, GCCR);
+		ravb_wait(ndev, GCCR, GCCR_TCR, GCCR_TCR_NOREQ);
+	}
+}
+
+static bool ravb_ptp_is_config(struct ravb_private *priv)
+{
+	return !!(ravb_read(priv->ndev, CSR) & CSR_OPS_CONFIG);
+}
+
+/* Caller must hold lock */
+static void ravb_ptp_time_read(struct ravb_private *priv, struct timespec64 *ts)
+{
+	struct net_device *ndev = priv->ndev;
+
+	ravb_ptp_tcr_request(priv, GCCR_TCR_CAPTURE);
+
+	ts->tv_nsec = ravb_read(ndev, GCT0);
+	ts->tv_sec  = ravb_read(ndev, GCT1) |
+		((s64)ravb_read(ndev, GCT2) << 32);
+}
+
+/* Caller must hold lock */
+static void ravb_ptp_time_write(struct ravb_private *priv,
+				const struct timespec64 *ts)
+{
+	struct net_device *ndev = priv->ndev;
+
+	ravb_ptp_tcr_request(priv, GCCR_TCR_RESET);
+
+	ravb_write(ndev, ts->tv_nsec, GTO0);
+	ravb_write(ndev, ts->tv_sec,  GTO1);
+	ravb_write(ndev, (ts->tv_sec >> 32) & 0xffff, GTO2);
+	ravb_write(ndev, ravb_read(ndev, GCCR) | GCCR_LTO, GCCR);
+	if (ravb_read(ndev, CSR) & CSR_OPS_OPERATION)
+		ravb_wait(ndev, GCCR, GCCR_LTO, 0);
+}
+
+/* Caller must hold lock */
+static u64 ravb_ptp_cnt_read(struct ravb_private *priv)
+{
+	struct timespec64 ts;
+	ktime_t kt;
+
+	ravb_ptp_time_read(priv, &ts);
+	kt = timespec64_to_ktime(ts);
+
+	return ktime_to_ns(kt);
+}
+
+/* Caller must hold lock */
+static void ravb_ptp_cnt_write(struct ravb_private *priv, u64 ns)
+{
+	struct timespec64 ts = ns_to_timespec64(ns);
+
+	ravb_ptp_time_write(priv, &ts);
+}
+
+/* Caller must hold lock */
+static void ravb_ptp_select_counter(struct ravb_private *priv, u16 sel)
+{
+	struct net_device *ndev = priv->ndev;
+	u32 val;
+
+	ravb_wait(ndev, GCCR, GCCR_TCR, GCCR_TCR_NOREQ);
+	val = ravb_read(ndev, GCCR) & ~GCCR_TCSS;
+	ravb_write(ndev, val | (sel << 8), GCCR);
+}
+
+/* Caller must hold lock */
+static void ravb_ptp_update_addend(struct ravb_private *priv, u32 addend)
+{
+	struct net_device *ndev = priv->ndev;
+
+	priv->ptp.current_addend = addend;
+
+	ravb_write(ndev, addend & GTI_TIV, GTI);
+	ravb_write(ndev, ravb_read(ndev, GCCR) | GCCR_LTI, GCCR);
+	if (ravb_read(ndev, CSR) & CSR_OPS_OPERATION)
+		ravb_wait(ndev, GCCR, GCCR_LTI, 0);
+}
+
+/* PTP clock operations */
+static int ravb_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
+{
+	struct ravb_private *priv = container_of(ptp, struct ravb_private,
+						 ptp.info);
+	unsigned long flags;
+	u32 diff, addend;
+	int neg_adj = 0;
+	u64 adj;
+
+	if (ppb < 0) {
+		neg_adj = 1;
+		ppb = -ppb;
+	}
+	addend = priv->ptp.default_addend;
+	adj = addend;
+	adj *= ppb;
+	diff = div_u64(adj, NSEC_PER_SEC);
+
+	addend = neg_adj ? addend - diff : addend + diff;
+
+	spin_lock_irqsave(&priv->lock, flags);
+	ravb_ptp_update_addend(priv, addend);
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	return 0;
+}
+
+static int ravb_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
+{
+	struct ravb_private *priv = container_of(ptp, struct ravb_private,
+						 ptp.info);
+	unsigned long flags;
+	u64 now;
+
+	if (ravb_ptp_is_config(priv))
+		return -EBUSY;
+
+	spin_lock_irqsave(&priv->lock, flags);
+	now =  ravb_ptp_cnt_read(priv);
+	now += delta;
+	ravb_ptp_cnt_write(priv, now);
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	return 0;
+}
+
+static int ravb_ptp_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+{
+	struct ravb_private *priv = container_of(ptp, struct ravb_private,
+						 ptp.info);
+	struct timespec64 ts64;
+	unsigned long flags;
+
+	if (ravb_ptp_is_config(priv))
+		return -EBUSY;
+
+	spin_lock_irqsave(&priv->lock, flags);
+	ravb_ptp_time_read(priv, &ts64);
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	ts->tv_sec  = ts64.tv_sec;
+	ts->tv_nsec = ts64.tv_nsec;
+
+	return 0;
+}
+
+static int ravb_ptp_settime(struct ptp_clock_info *ptp,
+			    const struct timespec *ts)
+{
+	struct ravb_private *priv = container_of(ptp, struct ravb_private,
+						 ptp.info);
+	struct timespec64 ts64;
+	unsigned long flags;
+
+	ts64.tv_sec  = ts->tv_sec;
+	ts64.tv_nsec = ts->tv_nsec;
+
+	spin_lock_irqsave(&priv->lock, flags);
+	ravb_ptp_time_write(priv, &ts64);
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	return 0;
+}
+
+static int ravb_ptp_extts(struct ptp_clock_info *ptp,
+			  struct ptp_extts_request *req, int on)
+{
+	struct ravb_private *priv = container_of(ptp, struct ravb_private,
+						 ptp.info);
+	struct net_device *ndev = priv->ndev;
+	unsigned long flags;
+	u32 gic;
+
+	if (req->index)
+		return -EINVAL;
+
+	if (priv->ptp.extts[req->index] == on)
+		return 0;
+	priv->ptp.extts[req->index] = on;
+
+	spin_lock_irqsave(&priv->lock, flags);
+	gic = ravb_read(ndev, GIC);
+	if (on)
+		gic |= GIC_PTCE;
+	else
+		gic &= ~GIC_PTCE;
+	ravb_write(ndev, gic, GIC);
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	return 0;
+}
+
+static int ravb_ptp_perout(struct ptp_clock_info *ptp,
+			   struct ptp_perout_request *req, int on)
+{
+	struct ravb_private *priv = container_of(ptp, struct ravb_private,
+						 ptp.info);
+	struct net_device *ndev = priv->ndev;
+	struct ravb_ptp_perout *perout;
+	unsigned long flags;
+	u32 gic;
+
+	if (req->index)
+		return -EINVAL;
+
+	if (on) {
+		u64 start_ns;
+		u64 period_ns;
+
+		start_ns = req->start.sec * NSEC_PER_SEC + req->start.nsec;
+		period_ns = req->period.sec * NSEC_PER_SEC + req->period.nsec;
+
+		if (start_ns > U32_MAX) {
+			netdev_warn(ndev,
+				    "ptp: Start value (nsec) is over limit. Maximum size of start is only 32 bits\n");
+			return -ERANGE;
+		}
+
+		if (period_ns > U32_MAX) {
+			netdev_warn(ndev,
+				    "ptp: Period value (nsec) is over limit. Maximum size of period is only 32 bits\n");
+			return -ERANGE;
+		}
+
+		spin_lock_irqsave(&priv->lock, flags);
+
+		perout = &priv->ptp.perout[req->index];
+		perout->target = (u32)start_ns;
+		perout->period = (u32)period_ns;
+		ravb_ptp_update_compare(priv, (u32)start_ns);
+
+		/* Unmask interrupt */
+		gic = ravb_read(ndev, GIC);
+		gic |= GIC_PTME;
+		ravb_write(ndev, gic, GIC);
+
+		spin_unlock_irqrestore(&priv->lock, flags);
+	} else {
+		spin_lock_irqsave(&priv->lock, flags);
+
+		perout = &priv->ptp.perout[req->index];
+		perout->period = 0;
+
+		/* Mask interrupt */
+		gic = ravb_read(ndev, GIC);
+		gic &= ~GIC_PTME;
+		ravb_write(ndev, gic, GIC);
+
+		spin_unlock_irqrestore(&priv->lock, flags);
+	}
+
+	return 0;
+}
+
+static int ravb_ptp_enable(struct ptp_clock_info *ptp,
+			   struct ptp_clock_request *req, int on)
+{
+	switch (req->type) {
+	case PTP_CLK_REQ_EXTTS:
+		return ravb_ptp_extts(ptp, &req->extts, on);
+	case PTP_CLK_REQ_PEROUT:
+		return ravb_ptp_perout(ptp, &req->perout, on);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static const struct ptp_clock_info ravb_ptp_info = {
+	.owner		= THIS_MODULE,
+	.name		= "ravb clock",
+	.max_adj	= 50000000,
+	.n_ext_ts	= N_EXT_TS,
+	.n_per_out	= N_PER_OUT,
+	.adjfreq	= ravb_ptp_adjfreq,
+	.adjtime	= ravb_ptp_adjtime,
+	.gettime	= ravb_ptp_gettime,
+	.settime	= ravb_ptp_settime,
+	.enable		= ravb_ptp_enable,
+};
+
+static int ravb_ptp_init(struct net_device *ndev, struct platform_device *pdev)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+	unsigned long flags;
+
+	priv->ptp.info = ravb_ptp_info;
+
+	priv->ptp.default_addend = ravb_read(ndev, GTI);
+	priv->ptp.current_addend = priv->ptp.default_addend;
+
+	spin_lock_irqsave(&priv->lock, flags);
+	ravb_ptp_select_counter(priv, GCCR_TCSS_ADJGPTP);
+	spin_unlock_irqrestore(&priv->lock, flags);
+
+	priv->ptp.clock = ptp_clock_register(&priv->ptp.info, &pdev->dev);
+	if (IS_ERR(priv->ptp.clock))
+		return PTR_ERR(priv->ptp.clock);
+
+	return 0;
+}
+
+static void ravb_ptp_stop(struct net_device *ndev)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+
+	ravb_write(ndev, 0, GIC);
+	ravb_write(ndev, 0, GIS);
+
+	ptp_clock_unregister(priv->ptp.clock);
+}
+
+/* MDIO bus init function */
+static int ravb_mdio_init(struct ravb_private *priv)
+{
+	struct platform_device *pdev = priv->pdev;
+	struct device *dev = &pdev->dev;
+	int result;
+
+	/* Bitbang init */
+	priv->mdiobb.ops = &bb_ops;
+
+	/* MII controller setting */
+	priv->mii_bus = alloc_mdio_bitbang(&priv->mdiobb);
+	if (!priv->mii_bus)
+		return -ENOMEM;
+
+	/* Hook up MII support for ethtool */
+	priv->mii_bus->name = "ravb_mii";
+	priv->mii_bus->parent = dev;
+	snprintf(priv->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
+		 pdev->name, pdev->id);
+
+	/* Register MDIO bus */
+	result = of_mdiobus_register(priv->mii_bus, dev->of_node);
+	if (result)
+		goto out_free_bus;
+
+	return 0;
+
+out_free_bus:
+	free_mdio_bitbang(priv->mii_bus);
+	return result;
+}
+
+/* MDIO bus release function */
+static int ravb_mdio_release(struct ravb_private *priv)
+{
+	/* Unregister mdio bus */
+	mdiobus_unregister(priv->mii_bus);
+
+	/* Free bitbang info */
+	free_mdio_bitbang(priv->mii_bus);
+
+	return 0;
+}
+
+static int ravb_probe(struct platform_device *pdev)
+{
+	struct device_node *np = pdev->dev.of_node;
+	struct ravb_private *priv;
+	struct net_device *ndev;
+	int result, q;
+	struct resource *res;
+
+	if (!np) {
+		dev_err(&pdev->dev,
+			"this driver is required to be instantiated from device tree\n");
+		return -EINVAL;
+	}
+
+	/* Get base address */
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!res) {
+		dev_err(&pdev->dev, "invalid resource\n");
+		return -EINVAL;
+	}
+
+	ndev = alloc_etherdev(sizeof(struct ravb_private));
+	if (!ndev)
+		return -ENOMEM;
+
+	pm_runtime_enable(&pdev->dev);
+	pm_runtime_get_sync(&pdev->dev);
+
+	/* The Ether-specific entries in the device structure. */
+	ndev->base_addr = res->start;
+	ndev->dma = -1;
+	result = platform_get_irq(pdev, 0);
+	if (result < 0) {
+		result = -ENODEV;
+		goto out_release;
+	}
+	ndev->irq = result;
+
+	SET_NETDEV_DEV(ndev, &pdev->dev);
+
+	priv = netdev_priv(ndev);
+	priv->ndev = ndev;
+	priv->pdev = pdev;
+	priv->num_tx_ring[RAVB_BE] = BE_TX_RING_SIZE;
+	priv->num_rx_ring[RAVB_BE] = BE_RX_RING_SIZE;
+	priv->num_tx_ring[RAVB_NC] = NC_TX_RING_SIZE;
+	priv->num_rx_ring[RAVB_NC] = NC_RX_RING_SIZE;
+	priv->addr = devm_ioremap_resource(&pdev->dev, res);
+	if (IS_ERR(priv->addr)) {
+		result = PTR_ERR(priv->addr);
+		goto out_release;
+	}
+
+	spin_lock_init(&priv->lock);
+
+	priv->phy_interface = of_get_phy_mode(np);
+
+	priv->no_avb_link = of_property_read_bool(np, "renesas,no-ether-link");
+	priv->avb_link_active_low =
+		of_property_read_bool(np, "renesas,ether-link-active-low");
+
+	ndev->netdev_ops = &ravb_netdev_ops;
+
+	priv->rx_over_errors = 0;
+	priv->rx_fifo_errors = 0;
+	for (q = RAVB_BE; q < NUM_RX_QUEUE; q++) {
+		struct net_device_stats *stats = &priv->stats[q];
+
+		stats->rx_packets = 0;
+		stats->tx_packets = 0;
+		stats->rx_bytes = 0;
+		stats->tx_bytes = 0;
+		stats->multicast = 0;
+		stats->rx_errors = 0;
+		stats->rx_crc_errors = 0;
+		stats->rx_frame_errors = 0;
+		stats->rx_length_errors = 0;
+		stats->rx_missed_errors = 0;
+		stats->rx_over_errors = 0;
+	}
+
+	/* Set function */
+	ndev->netdev_ops = &ravb_netdev_ops;
+	ndev->ethtool_ops = &ravb_ethtool_ops;
+
+	/* Set AVB config mode */
+	ravb_write(ndev, (ravb_read(ndev, CCC) & ~CCC_OPC) | CCC_OPC_CONFIG,
+		   CCC);
+
+	/* Set CSEL value */
+	ravb_write(ndev, (ravb_read(ndev, CCC) & ~CCC_CSEL) | CCC_CSEL_HPB,
+		   CCC);
+
+	/* Set GTI value */
+	ravb_write(ndev, ((1000 << 20) / 130) & GTI_TIV, GTI);
+
+	/* Request GTI loading */
+	ravb_write(ndev, ravb_read(ndev, GCCR) | GCCR_LTI, GCCR);
+
+	/* Allocate descriptor base address table */
+	priv->desc_bat_size = sizeof(struct ravb_desc) * DBAT_ENTRY_NUM;
+	priv->desc_bat = dma_alloc_coherent(NULL, priv->desc_bat_size,
+					    &priv->desc_bat_dma, GFP_KERNEL);
+	if (!priv->desc_bat) {
+		dev_err(&ndev->dev,
+			"Cannot allocate desc base address table (size %d bytes)\n",
+			priv->desc_bat_size);
+		result = -ENOMEM;
+		goto out_release;
+	}
+	for (q = RAVB_BE; q < DBAT_ENTRY_NUM; q++)
+		priv->desc_bat[q].dt = DT_EOS;
+	ravb_write(ndev, priv->desc_bat_dma, DBAT);
+
+	/* Initialise HW timestamp list */
+	INIT_LIST_HEAD(&priv->ts_skb_list);
+
+	/* Initialise PTP Clock driver */
+	ravb_ptp_init(ndev, pdev);
+
+	/* Debug message level */
+	priv->msg_enable = RAVB_DEF_MSG_ENABLE;
+
+	/* Read and set MAC address */
+	read_mac_address(ndev, of_get_mac_address(np));
+	if (!is_valid_ether_addr(ndev->dev_addr)) {
+		dev_warn(&pdev->dev,
+			 "no valid MAC address supplied, using a random one\n");
+		eth_hw_addr_random(ndev);
+	}
+
+	/* MDIO bus init */
+	result = ravb_mdio_init(priv);
+	if (result) {
+		dev_err(&ndev->dev, "failed to initialize MDIO\n");
+		goto out_dma_free;
+	}
+
+	netif_napi_add(ndev, &priv->napi, ravb_poll, 64);
+
+	/* Network device register */
+	result = register_netdev(ndev);
+	if (result)
+		goto out_napi_del;
+
+	/* Print device information */
+	netdev_info(ndev, "Base address at %#x, %pM, IRQ %d.\n",
+		    (u32)ndev->base_addr, ndev->dev_addr, ndev->irq);
+
+	platform_set_drvdata(pdev, ndev);
+
+	return 0;
+
+out_napi_del:
+	netif_napi_del(&priv->napi);
+	ravb_mdio_release(priv);
+out_dma_free:
+	dma_free_coherent(NULL, priv->desc_bat_size, priv->desc_bat,
+			  priv->desc_bat_dma);
+	/* Stop PTP Clock driver */
+	ravb_ptp_stop(ndev);
+out_release:
+	if (ndev)
+		free_netdev(ndev);
+
+	pm_runtime_put(&pdev->dev);
+	pm_runtime_disable(&pdev->dev);
+	return result;
+}
+
+static int ravb_remove(struct platform_device *pdev)
+{
+	struct net_device *ndev = platform_get_drvdata(pdev);
+	struct ravb_private *priv = netdev_priv(ndev);
+
+	/* Stop PTP clock driver */
+	ravb_ptp_stop(ndev);
+
+	dma_free_coherent(NULL, priv->desc_bat_size, priv->desc_bat,
+			  priv->desc_bat_dma);
+	/* Set reset mode */
+	ravb_write(ndev, CCC_OPC_RESET, CCC);
+	pm_runtime_put_sync(&pdev->dev);
+	unregister_netdev(ndev);
+	netif_napi_del(&priv->napi);
+	ravb_mdio_release(priv);
+	pm_runtime_disable(&pdev->dev);
+	free_netdev(ndev);
+	platform_set_drvdata(pdev, NULL);
+
+	return 0;
+}
+
+#ifdef CONFIG_PM
+static int ravb_runtime_nop(struct device *dev)
+{
+	/* Runtime PM callback shared between ->runtime_suspend()
+	 * and ->runtime_resume(). Simply returns success.
+	 *
+	 * This driver re-initializes all registers after
+	 * pm_runtime_get_sync() anyway so there is no need
+	 * to save and restore registers here.
+	 */
+	return 0;
+}
+
+static const struct dev_pm_ops ravb_dev_pm_ops = {
+	.runtime_suspend = ravb_runtime_nop,
+	.runtime_resume = ravb_runtime_nop,
+};
+
+#define RAVB_PM_OPS (&ravb_dev_pm_ops)
+#else
+#define RAVB_PM_OPS NULL
+#endif
+
+static const struct of_device_id ravb_match_table[] = {
+	{ .compatible = "renesas,etheravb-r8a7790" },
+	{ .compatible = "renesas,etheravb-r8a7794" },
+	{ }
+};
+MODULE_DEVICE_TABLE(of, ravb_match_table);
+
+static struct platform_driver ravb_driver = {
+	.probe		= ravb_probe,
+	.remove		= ravb_remove,
+	.driver = {
+		.name	= "ravb",
+		.pm	= RAVB_PM_OPS,
+		.of_match_table = ravb_match_table,
+	},
+};
+
+module_platform_driver(ravb_driver);
+
+MODULE_AUTHOR("Mitsuhiro Kimura, Masaru Nagai");
+MODULE_DESCRIPTION("Renesas Ethernet AVB driver");
+MODULE_LICENSE("GPL v2");
