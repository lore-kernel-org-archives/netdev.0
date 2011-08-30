From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 4/9] stmmac: add MMC support exported via ethtool (v2)
Date: Tue, 30 Aug 2011 16:20:59 +0200
Message-ID: <1314714064-29101-5-git-send-email-peppe.cavallaro@st.com>
References: <1314714064-29101-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:37907 "EHLO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754374Ab1H3OVh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 10:21:37 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id AF8CCD0
	for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 14:21:34 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 5DE3F2261
	for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 14:21:34 +0000 (GMT)
In-Reply-To: <1314714064-29101-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the MMC management counters support.
MMC module is an extension of the register address
space and all the hardware counters can be accessed
via ethtoo -S ethX.

Note that, the MMC interrupts remain masked and the logic
to handle this kind of interrupt will be added later (if
actually useful).

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/Makefile         |    3 +-
 drivers/net/stmmac/common.h         |    1 +
 drivers/net/stmmac/dwmac1000_dma.c  |    8 -
 drivers/net/stmmac/mmc.h            |  131 +++++++++++++++++
 drivers/net/stmmac/mmc_core.c       |  265 +++++++++++++++++++++++++++++++++++
 drivers/net/stmmac/stmmac.h         |    1 +
 drivers/net/stmmac/stmmac_ethtool.c |  145 +++++++++++++++++--
 drivers/net/stmmac/stmmac_main.c    |   13 ++
 8 files changed, 544 insertions(+), 23 deletions(-)
 create mode 100644 drivers/net/stmmac/mmc.h
 create mode 100644 drivers/net/stmmac/mmc_core.c

diff --git a/drivers/net/stmmac/Makefile b/drivers/net/stmmac/Makefile
index 9691733..0f23d95 100644
--- a/drivers/net/stmmac/Makefile
+++ b/drivers/net/stmmac/Makefile
@@ -2,4 +2,5 @@ obj-$(CONFIG_STMMAC_ETH) += stmmac.o
 stmmac-$(CONFIG_STMMAC_TIMER) += stmmac_timer.o
 stmmac-objs:= stmmac_main.o stmmac_ethtool.o stmmac_mdio.o	\
 	      dwmac_lib.o dwmac1000_core.o  dwmac1000_dma.o	\
-	      dwmac100_core.o dwmac100_dma.o enh_desc.o  norm_desc.o $(stmmac-y)
+	      dwmac100_core.o dwmac100_dma.o enh_desc.o  norm_desc.o \
+	      mmc_core.o $(stmmac-y)
diff --git a/drivers/net/stmmac/common.h b/drivers/net/stmmac/common.h
index 290b97a..e08fee8 100644
--- a/drivers/net/stmmac/common.h
+++ b/drivers/net/stmmac/common.h
@@ -29,6 +29,7 @@
 #endif
 
 #include "descs.h"
+#include "mmc.h"
 
 #undef CHIP_DEBUG_PRINT
 /* Turn-on extra printk debug for MAC core, dma and descriptors */
diff --git a/drivers/net/stmmac/dwmac1000_dma.c b/drivers/net/stmmac/dwmac1000_dma.c
index 3dbeea6..a89384c 100644
--- a/drivers/net/stmmac/dwmac1000_dma.c
+++ b/drivers/net/stmmac/dwmac1000_dma.c
@@ -118,13 +118,6 @@ static void dwmac1000_dma_operation_mode(void __iomem *ioaddr, int txmode,
 	writel(csr6, ioaddr + DMA_CONTROL);
 }
 
-/* Not yet implemented --- no RMON module */
-static void dwmac1000_dma_diagnostic_fr(void *data,
-		  struct stmmac_extra_stats *x, void __iomem *ioaddr)
-{
-	return;
-}
-
 static void dwmac1000_dump_dma_regs(void __iomem *ioaddr)
 {
 	int i;
@@ -143,7 +136,6 @@ const struct stmmac_dma_ops dwmac1000_dma_ops = {
 	.init = dwmac1000_dma_init,
 	.dump_regs = dwmac1000_dump_dma_regs,
 	.dma_mode = dwmac1000_dma_operation_mode,
-	.dma_diagnostic_fr = dwmac1000_dma_diagnostic_fr,
 	.enable_dma_transmission = dwmac_enable_dma_transmission,
 	.enable_dma_irq = dwmac_enable_dma_irq,
 	.disable_dma_irq = dwmac_disable_dma_irq,
diff --git a/drivers/net/stmmac/mmc.h b/drivers/net/stmmac/mmc.h
new file mode 100644
index 0000000..a383520
--- /dev/null
+++ b/drivers/net/stmmac/mmc.h
@@ -0,0 +1,131 @@
+/*******************************************************************************
+  MMC Header file
+
+  Copyright (C) 2011  STMicroelectronics Ltd
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
+*******************************************************************************/
+
+/* MMC control register */
+/* When set, all counter are reset */
+#define MMC_CNTRL_COUNTER_RESET		0x1
+/* When set, do not roll over zero
+ * after reaching the max value*/
+#define MMC_CNTRL_COUNTER_STOP_ROLLOVER	0x2
+#define MMC_CNTRL_RESET_ON_READ		0x4	/* Reset after reading */
+#define MMC_CNTRL_COUNTER_FREEZER	0x8	/* Freeze counter values to the
+						 * current value.*/
+#define MMC_CNTRL_PRESET		0x10
+#define MMC_CNTRL_FULL_HALF_PRESET	0x20
+struct stmmac_counters {
+	unsigned int mmc_tx_octetcount_gb;
+	unsigned int mmc_tx_framecount_gb;
+	unsigned int mmc_tx_broadcastframe_g;
+	unsigned int mmc_tx_multicastframe_g;
+	unsigned int mmc_tx_64_octets_gb;
+	unsigned int mmc_tx_65_to_127_octets_gb;
+	unsigned int mmc_tx_128_to_255_octets_gb;
+	unsigned int mmc_tx_256_to_511_octets_gb;
+	unsigned int mmc_tx_512_to_1023_octets_gb;
+	unsigned int mmc_tx_1024_to_max_octets_gb;
+	unsigned int mmc_tx_unicast_gb;
+	unsigned int mmc_tx_multicast_gb;
+	unsigned int mmc_tx_broadcast_gb;
+	unsigned int mmc_tx_underflow_error;
+	unsigned int mmc_tx_singlecol_g;
+	unsigned int mmc_tx_multicol_g;
+	unsigned int mmc_tx_deferred;
+	unsigned int mmc_tx_latecol;
+	unsigned int mmc_tx_exesscol;
+	unsigned int mmc_tx_carrier_error;
+	unsigned int mmc_tx_octetcount_g;
+	unsigned int mmc_tx_framecount_g;
+	unsigned int mmc_tx_excessdef;
+	unsigned int mmc_tx_pause_frame;
+	unsigned int mmc_tx_vlan_frame_g;
+
+	/* MMC RX counter registers */
+	unsigned int mmc_rx_framecount_gb;
+	unsigned int mmc_rx_octetcount_gb;
+	unsigned int mmc_rx_octetcount_g;
+	unsigned int mmc_rx_broadcastframe_g;
+	unsigned int mmc_rx_multicastframe_g;
+	unsigned int mmc_rx_crc_errror;
+	unsigned int mmc_rx_align_error;
+	unsigned int mmc_rx_run_error;
+	unsigned int mmc_rx_jabber_error;
+	unsigned int mmc_rx_undersize_g;
+	unsigned int mmc_rx_oversize_g;
+	unsigned int mmc_rx_64_octets_gb;
+	unsigned int mmc_rx_65_to_127_octets_gb;
+	unsigned int mmc_rx_128_to_255_octets_gb;
+	unsigned int mmc_rx_256_to_511_octets_gb;
+	unsigned int mmc_rx_512_to_1023_octets_gb;
+	unsigned int mmc_rx_1024_to_max_octets_gb;
+	unsigned int mmc_rx_unicast_g;
+	unsigned int mmc_rx_length_error;
+	unsigned int mmc_rx_autofrangetype;
+	unsigned int mmc_rx_pause_frames;
+	unsigned int mmc_rx_fifo_overflow;
+	unsigned int mmc_rx_vlan_frames_gb;
+	unsigned int mmc_rx_watchdog_error;
+	/* IPC */
+	unsigned int mmc_rx_ipc_intr_mask;
+	unsigned int mmc_rx_ipc_intr;
+	/* IPv4 */
+	unsigned int mmc_rx_ipv4_gd;
+	unsigned int mmc_rx_ipv4_hderr;
+	unsigned int mmc_rx_ipv4_nopay;
+	unsigned int mmc_rx_ipv4_frag;
+	unsigned int mmc_rx_ipv4_udsbl;
+
+	unsigned int mmc_rx_ipv4_gd_octets;
+	unsigned int mmc_rx_ipv4_hderr_octets;
+	unsigned int mmc_rx_ipv4_nopay_octets;
+	unsigned int mmc_rx_ipv4_frag_octets;
+	unsigned int mmc_rx_ipv4_udsbl_octets;
+
+	/* IPV6 */
+	unsigned int mmc_rx_ipv6_gd_octets;
+	unsigned int mmc_rx_ipv6_hderr_octets;
+	unsigned int mmc_rx_ipv6_nopay_octets;
+
+	unsigned int mmc_rx_ipv6_gd;
+	unsigned int mmc_rx_ipv6_hderr;
+	unsigned int mmc_rx_ipv6_nopay;
+
+	/* Protocols */
+	unsigned int mmc_rx_udp_gd;
+	unsigned int mmc_rx_udp_err;
+	unsigned int mmc_rx_tcp_gd;
+	unsigned int mmc_rx_tcp_err;
+	unsigned int mmc_rx_icmp_gd;
+	unsigned int mmc_rx_icmp_err;
+
+	unsigned int mmc_rx_udp_gd_octets;
+	unsigned int mmc_rx_udp_err_octets;
+	unsigned int mmc_rx_tcp_gd_octets;
+	unsigned int mmc_rx_tcp_err_octets;
+	unsigned int mmc_rx_icmp_gd_octets;
+	unsigned int mmc_rx_icmp_err_octets;
+};
+
+extern void dwmac_mmc_ctrl(void __iomem *ioaddr, unsigned int mode);
+extern void dwmac_mmc_intr_all_mask(void __iomem *ioaddr);
+extern void dwmac_mmc_read(void __iomem *ioaddr, struct stmmac_counters *mmc);
diff --git a/drivers/net/stmmac/mmc_core.c b/drivers/net/stmmac/mmc_core.c
new file mode 100644
index 0000000..41e6b33
--- /dev/null
+++ b/drivers/net/stmmac/mmc_core.c
@@ -0,0 +1,265 @@
+/*******************************************************************************
+  DWMAC Management Counters
+
+  Copyright (C) 2011  STMicroelectronics Ltd
+
+  This program is free software; you can redistribute it and/or modify it
+  under the terms and conditions of the GNU General Public License,
+  version 2, as published by the Free Software Foundation.
+
+  This program is distributed in the hope it will be useful, but WITHOUT
+  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+  more details.
+
+  You should have received a copy of the GNU General Public License along with
+  this program; if not, write to the Free Software Foundation, Inc.,
+  51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+
+  The full GNU General Public License is included in this distribution in
+  the file called "COPYING".
+
+  Author: Giuseppe Cavallaro <peppe.cavallaro@st.com>
+*******************************************************************************/
+
+#include <linux/io.h>
+#include "mmc.h"
+
+/* MAC Management Counters register offset */
+
+#define MMC_CNTRL		0x00000100	/* MMC Control */
+#define MMC_RX_INTR		0x00000104	/* MMC RX Interrupt */
+#define MMC_TX_INTR		0x00000108	/* MMC TX Interrupt */
+#define MMC_RX_INTR_MASK	0x0000010c	/* MMC Interrupt Mask */
+#define MMC_TX_INTR_MASK	0x00000110	/* MMC Interrupt Mask */
+#define MMC_DEFAUL_MASK		0xffffffff
+
+/* MMC TX counter registers */
+
+/* Note:
+ * _GB register stands for good and bad frames
+ * _G is for good only.
+ */
+#define MMC_TX_OCTETCOUNT_GB		0x00000114
+#define MMC_TX_FRAMECOUNT_GB		0x00000118
+#define MMC_TX_BROADCASTFRAME_G		0x0000011c
+#define MMC_TX_MULTICASTFRAME_G		0x00000120
+#define MMC_TX_64_OCTETS_GB		0x00000124
+#define MMC_TX_65_TO_127_OCTETS_GB	0x00000128
+#define MMC_TX_128_TO_255_OCTETS_GB	0x0000012c
+#define MMC_TX_256_TO_511_OCTETS_GB	0x00000130
+#define MMC_TX_512_TO_1023_OCTETS_GB	0x00000134
+#define MMC_TX_1024_TO_MAX_OCTETS_GB	0x00000138
+#define MMC_TX_UNICAST_GB		0x0000013c
+#define MMC_TX_MULTICAST_GB		0x00000140
+#define MMC_TX_BROADCAST_GB		0x00000144
+#define MMC_TX_UNDERFLOW_ERROR		0x00000148
+#define MMC_TX_SINGLECOL_G		0x0000014c
+#define MMC_TX_MULTICOL_G		0x00000150
+#define MMC_TX_DEFERRED			0x00000154
+#define MMC_TX_LATECOL			0x00000158
+#define MMC_TX_EXESSCOL			0x0000015c
+#define MMC_TX_CARRIER_ERROR		0x00000160
+#define MMC_TX_OCTETCOUNT_G		0x00000164
+#define MMC_TX_FRAMECOUNT_G		0x00000168
+#define MMC_TX_EXCESSDEF		0x0000016c
+#define MMC_TX_PAUSE_FRAME		0x00000170
+#define MMC_TX_VLAN_FRAME_G		0x00000174
+
+/* MMC RX counter registers */
+#define MMC_RX_FRAMECOUNT_GB		0x00000180
+#define MMC_RX_OCTETCOUNT_GB		0x00000184
+#define MMC_RX_OCTETCOUNT_G		0x00000188
+#define MMC_RX_BROADCASTFRAME_G		0x0000018c
+#define MMC_RX_MULTICASTFRAME_G		0x00000190
+#define MMC_RX_CRC_ERRROR		0x00000194
+#define MMC_RX_ALIGN_ERROR		0x00000198
+#define MMC_RX_RUN_ERROR		0x0000019C
+#define MMC_RX_JABBER_ERROR		0x000001A0
+#define MMC_RX_UNDERSIZE_G		0x000001A4
+#define MMC_RX_OVERSIZE_G		0x000001A8
+#define MMC_RX_64_OCTETS_GB		0x000001AC
+#define MMC_RX_65_TO_127_OCTETS_GB	0x000001b0
+#define MMC_RX_128_TO_255_OCTETS_GB	0x000001b4
+#define MMC_RX_256_TO_511_OCTETS_GB	0x000001b8
+#define MMC_RX_512_TO_1023_OCTETS_GB	0x000001bc
+#define MMC_RX_1024_TO_MAX_OCTETS_GB	0x000001c0
+#define MMC_RX_UNICAST_G		0x000001c4
+#define MMC_RX_LENGTH_ERROR		0x000001c8
+#define MMC_RX_AUTOFRANGETYPE		0x000001cc
+#define MMC_RX_PAUSE_FRAMES		0x000001d0
+#define MMC_RX_FIFO_OVERFLOW		0x000001d4
+#define MMC_RX_VLAN_FRAMES_GB		0x000001d8
+#define MMC_RX_WATCHDOG_ERROR		0x000001dc
+/* IPC*/
+#define MMC_RX_IPC_INTR_MASK		0x00000200
+#define MMC_RX_IPC_INTR			0x00000208
+/* IPv4*/
+#define MMC_RX_IPV4_GD			0x00000210
+#define MMC_RX_IPV4_HDERR		0x00000214
+#define MMC_RX_IPV4_NOPAY		0x00000218
+#define MMC_RX_IPV4_FRAG		0x0000021C
+#define MMC_RX_IPV4_UDSBL		0x00000220
+
+#define MMC_RX_IPV4_GD_OCTETS		0x00000250
+#define MMC_RX_IPV4_HDERR_OCTETS	0x00000254
+#define MMC_RX_IPV4_NOPAY_OCTETS	0x00000258
+#define MMC_RX_IPV4_FRAG_OCTETS		0x0000025c
+#define MMC_RX_IPV4_UDSBL_OCTETS	0x00000260
+
+/* IPV6*/
+#define MMC_RX_IPV6_GD_OCTETS		0x00000264
+#define MMC_RX_IPV6_HDERR_OCTETS	0x00000268
+#define MMC_RX_IPV6_NOPAY_OCTETS	0x0000026c
+
+#define MMC_RX_IPV6_GD			0x00000224
+#define MMC_RX_IPV6_HDERR		0x00000228
+#define MMC_RX_IPV6_NOPAY		0x0000022c
+
+/* Protocols*/
+#define MMC_RX_UDP_GD			0x00000230
+#define MMC_RX_UDP_ERR			0x00000234
+#define MMC_RX_TCP_GD			0x00000238
+#define MMC_RX_TCP_ERR			0x0000023c
+#define MMC_RX_ICMP_GD			0x00000240
+#define MMC_RX_ICMP_ERR			0x00000244
+
+#define MMC_RX_UDP_GD_OCTETS		0x00000270
+#define MMC_RX_UDP_ERR_OCTETS		0x00000274
+#define MMC_RX_TCP_GD_OCTETS		0x00000278
+#define MMC_RX_TCP_ERR_OCTETS		0x0000027c
+#define MMC_RX_ICMP_GD_OCTETS		0x00000280
+#define MMC_RX_ICMP_ERR_OCTETS		0x00000284
+
+void dwmac_mmc_ctrl(void __iomem *ioaddr, unsigned int mode)
+{
+	u32 value = readl(ioaddr + MMC_CNTRL);
+
+	value |= (mode & 0x3F);
+
+	writel(value, ioaddr + MMC_CNTRL);
+
+	pr_debug("stmmac: MMC ctrl register (offset 0x%x): 0x%08x\n",
+		 MMC_CNTRL, value);
+}
+
+/* To mask all all interrupts.*/
+void dwmac_mmc_intr_all_mask(void __iomem *ioaddr)
+{
+	writel(MMC_DEFAUL_MASK, ioaddr + MMC_RX_INTR_MASK);
+	writel(MMC_DEFAUL_MASK, ioaddr + MMC_TX_INTR_MASK);
+}
+
+/* This reads the MAC core counters (if actaully supported).
+ * by default the MMC core is programmed to reset each
+ * counter after a read. So all the field of the mmc struct
+ * have to be incremented.
+ */
+void dwmac_mmc_read(void __iomem *ioaddr, struct stmmac_counters *mmc)
+{
+	mmc->mmc_tx_octetcount_gb += readl(ioaddr + MMC_TX_OCTETCOUNT_GB);
+	mmc->mmc_tx_framecount_gb += readl(ioaddr + MMC_TX_FRAMECOUNT_GB);
+	mmc->mmc_tx_broadcastframe_g += readl(ioaddr + MMC_TX_BROADCASTFRAME_G);
+	mmc->mmc_tx_multicastframe_g += readl(ioaddr + MMC_TX_MULTICASTFRAME_G);
+	mmc->mmc_tx_64_octets_gb += readl(ioaddr + MMC_TX_64_OCTETS_GB);
+	mmc->mmc_tx_65_to_127_octets_gb +=
+	    readl(ioaddr + MMC_TX_65_TO_127_OCTETS_GB);
+	mmc->mmc_tx_128_to_255_octets_gb +=
+	    readl(ioaddr + MMC_TX_128_TO_255_OCTETS_GB);
+	mmc->mmc_tx_256_to_511_octets_gb +=
+	    readl(ioaddr + MMC_TX_256_TO_511_OCTETS_GB);
+	mmc->mmc_tx_512_to_1023_octets_gb +=
+	    readl(ioaddr + MMC_TX_512_TO_1023_OCTETS_GB);
+	mmc->mmc_tx_1024_to_max_octets_gb +=
+	    readl(ioaddr + MMC_TX_1024_TO_MAX_OCTETS_GB);
+	mmc->mmc_tx_unicast_gb += readl(ioaddr + MMC_TX_UNICAST_GB);
+	mmc->mmc_tx_multicast_gb += readl(ioaddr + MMC_TX_MULTICAST_GB);
+	mmc->mmc_tx_broadcast_gb += readl(ioaddr + MMC_TX_BROADCAST_GB);
+	mmc->mmc_tx_underflow_error += readl(ioaddr + MMC_TX_UNDERFLOW_ERROR);
+	mmc->mmc_tx_singlecol_g += readl(ioaddr + MMC_TX_SINGLECOL_G);
+	mmc->mmc_tx_multicol_g += readl(ioaddr + MMC_TX_MULTICOL_G);
+	mmc->mmc_tx_deferred += readl(ioaddr + MMC_TX_DEFERRED);
+	mmc->mmc_tx_latecol += readl(ioaddr + MMC_TX_LATECOL);
+	mmc->mmc_tx_exesscol += readl(ioaddr + MMC_TX_EXESSCOL);
+	mmc->mmc_tx_carrier_error += readl(ioaddr + MMC_TX_CARRIER_ERROR);
+	mmc->mmc_tx_octetcount_g += readl(ioaddr + MMC_TX_OCTETCOUNT_G);
+	mmc->mmc_tx_framecount_g += readl(ioaddr + MMC_TX_FRAMECOUNT_G);
+	mmc->mmc_tx_excessdef += readl(ioaddr + MMC_TX_EXCESSDEF);
+	mmc->mmc_tx_pause_frame += readl(ioaddr + MMC_TX_PAUSE_FRAME);
+	mmc->mmc_tx_vlan_frame_g += readl(ioaddr + MMC_TX_VLAN_FRAME_G);
+
+	/* MMC RX counter registers */
+	mmc->mmc_rx_framecount_gb += readl(ioaddr + MMC_RX_FRAMECOUNT_GB);
+	mmc->mmc_rx_octetcount_gb += readl(ioaddr + MMC_RX_OCTETCOUNT_GB);
+	mmc->mmc_rx_octetcount_g += readl(ioaddr + MMC_RX_OCTETCOUNT_G);
+	mmc->mmc_rx_broadcastframe_g += readl(ioaddr + MMC_RX_BROADCASTFRAME_G);
+	mmc->mmc_rx_multicastframe_g += readl(ioaddr + MMC_RX_MULTICASTFRAME_G);
+	mmc->mmc_rx_crc_errror += readl(ioaddr + MMC_RX_CRC_ERRROR);
+	mmc->mmc_rx_align_error += readl(ioaddr + MMC_RX_ALIGN_ERROR);
+	mmc->mmc_rx_run_error += readl(ioaddr + MMC_RX_RUN_ERROR);
+	mmc->mmc_rx_jabber_error += readl(ioaddr + MMC_RX_JABBER_ERROR);
+	mmc->mmc_rx_undersize_g += readl(ioaddr + MMC_RX_UNDERSIZE_G);
+	mmc->mmc_rx_oversize_g += readl(ioaddr + MMC_RX_OVERSIZE_G);
+	mmc->mmc_rx_64_octets_gb += readl(ioaddr + MMC_RX_64_OCTETS_GB);
+	mmc->mmc_rx_65_to_127_octets_gb +=
+	    readl(ioaddr + MMC_RX_65_TO_127_OCTETS_GB);
+	mmc->mmc_rx_128_to_255_octets_gb +=
+	    readl(ioaddr + MMC_RX_128_TO_255_OCTETS_GB);
+	mmc->mmc_rx_256_to_511_octets_gb +=
+	    readl(ioaddr + MMC_RX_256_TO_511_OCTETS_GB);
+	mmc->mmc_rx_512_to_1023_octets_gb +=
+	    readl(ioaddr + MMC_RX_512_TO_1023_OCTETS_GB);
+	mmc->mmc_rx_1024_to_max_octets_gb +=
+	    readl(ioaddr + MMC_RX_1024_TO_MAX_OCTETS_GB);
+	mmc->mmc_rx_unicast_g += readl(ioaddr + MMC_RX_UNICAST_G);
+	mmc->mmc_rx_length_error += readl(ioaddr + MMC_RX_LENGTH_ERROR);
+	mmc->mmc_rx_autofrangetype += readl(ioaddr + MMC_RX_AUTOFRANGETYPE);
+	mmc->mmc_rx_pause_frames += readl(ioaddr + MMC_RX_PAUSE_FRAMES);
+	mmc->mmc_rx_fifo_overflow += readl(ioaddr + MMC_RX_FIFO_OVERFLOW);
+	mmc->mmc_rx_vlan_frames_gb += readl(ioaddr + MMC_RX_VLAN_FRAMES_GB);
+	mmc->mmc_rx_watchdog_error += readl(ioaddr + MMC_RX_WATCHDOG_ERROR);
+	/* IPC */
+	mmc->mmc_rx_ipc_intr_mask += readl(ioaddr + MMC_RX_IPC_INTR_MASK);
+	mmc->mmc_rx_ipc_intr += readl(ioaddr + MMC_RX_IPC_INTR);
+	/* IPv4 */
+	mmc->mmc_rx_ipv4_gd += readl(ioaddr + MMC_RX_IPV4_GD);
+	mmc->mmc_rx_ipv4_hderr += readl(ioaddr + MMC_RX_IPV4_HDERR);
+	mmc->mmc_rx_ipv4_nopay += readl(ioaddr + MMC_RX_IPV4_NOPAY);
+	mmc->mmc_rx_ipv4_frag += readl(ioaddr + MMC_RX_IPV4_FRAG);
+	mmc->mmc_rx_ipv4_udsbl += readl(ioaddr + MMC_RX_IPV4_UDSBL);
+
+	mmc->mmc_rx_ipv4_gd_octets += readl(ioaddr + MMC_RX_IPV4_GD_OCTETS);
+	mmc->mmc_rx_ipv4_hderr_octets +=
+	    readl(ioaddr + MMC_RX_IPV4_HDERR_OCTETS);
+	mmc->mmc_rx_ipv4_nopay_octets +=
+	    readl(ioaddr + MMC_RX_IPV4_NOPAY_OCTETS);
+	mmc->mmc_rx_ipv4_frag_octets += readl(ioaddr + MMC_RX_IPV4_FRAG_OCTETS);
+	mmc->mmc_rx_ipv4_udsbl_octets +=
+	    readl(ioaddr + MMC_RX_IPV4_UDSBL_OCTETS);
+
+	/* IPV6 */
+	mmc->mmc_rx_ipv6_gd_octets += readl(ioaddr + MMC_RX_IPV6_GD_OCTETS);
+	mmc->mmc_rx_ipv6_hderr_octets +=
+	    readl(ioaddr + MMC_RX_IPV6_HDERR_OCTETS);
+	mmc->mmc_rx_ipv6_nopay_octets +=
+	    readl(ioaddr + MMC_RX_IPV6_NOPAY_OCTETS);
+
+	mmc->mmc_rx_ipv6_gd += readl(ioaddr + MMC_RX_IPV6_GD);
+	mmc->mmc_rx_ipv6_hderr += readl(ioaddr + MMC_RX_IPV6_HDERR);
+	mmc->mmc_rx_ipv6_nopay += readl(ioaddr + MMC_RX_IPV6_NOPAY);
+
+	/* Protocols */
+	mmc->mmc_rx_udp_gd += readl(ioaddr + MMC_RX_UDP_GD);
+	mmc->mmc_rx_udp_err += readl(ioaddr + MMC_RX_UDP_ERR);
+	mmc->mmc_rx_tcp_gd += readl(ioaddr + MMC_RX_TCP_GD);
+	mmc->mmc_rx_tcp_err += readl(ioaddr + MMC_RX_TCP_ERR);
+	mmc->mmc_rx_icmp_gd += readl(ioaddr + MMC_RX_ICMP_GD);
+	mmc->mmc_rx_icmp_err += readl(ioaddr + MMC_RX_ICMP_ERR);
+
+	mmc->mmc_rx_udp_gd_octets += readl(ioaddr + MMC_RX_UDP_GD_OCTETS);
+	mmc->mmc_rx_udp_err_octets += readl(ioaddr + MMC_RX_UDP_ERR_OCTETS);
+	mmc->mmc_rx_tcp_gd_octets += readl(ioaddr + MMC_RX_TCP_GD_OCTETS);
+	mmc->mmc_rx_tcp_err_octets += readl(ioaddr + MMC_RX_TCP_ERR_OCTETS);
+	mmc->mmc_rx_icmp_gd_octets += readl(ioaddr + MMC_RX_ICMP_GD_OCTETS);
+	mmc->mmc_rx_icmp_err_octets += readl(ioaddr + MMC_RX_ICMP_ERR_OCTETS);
+}
diff --git a/drivers/net/stmmac/stmmac.h b/drivers/net/stmmac/stmmac.h
index 619e3af..ef03796 100644
--- a/drivers/net/stmmac/stmmac.h
+++ b/drivers/net/stmmac/stmmac.h
@@ -77,6 +77,7 @@ struct stmmac_priv {
 	struct stmmac_timer *tm;
 #endif
 	struct plat_stmmacenet_data *plat;
+	struct stmmac_counters mmc;
 };
 
 extern int stmmac_mdio_unregister(struct net_device *ndev);
diff --git a/drivers/net/stmmac/stmmac_ethtool.c b/drivers/net/stmmac/stmmac_ethtool.c
index 79df79d..7d23f99 100644
--- a/drivers/net/stmmac/stmmac_ethtool.c
+++ b/drivers/net/stmmac/stmmac_ethtool.c
@@ -46,7 +46,7 @@ struct stmmac_stats {
 	{ #m, FIELD_SIZEOF(struct stmmac_extra_stats, m),	\
 	offsetof(struct stmmac_priv, xstats.m)}
 
-static const struct  stmmac_stats stmmac_gstrings_stats[] = {
+static const struct stmmac_stats stmmac_gstrings_stats[] = {
 	STMMAC_STAT(tx_underflow),
 	STMMAC_STAT(tx_carrier),
 	STMMAC_STAT(tx_losscarrier),
@@ -91,19 +91,109 @@ static const struct  stmmac_stats stmmac_gstrings_stats[] = {
 };
 #define STMMAC_STATS_LEN ARRAY_SIZE(stmmac_gstrings_stats)
 
+/* HW MAC Management counters (if supported) */
+#define STMMAC_MMC_STAT(m)	\
+	{ #m, FIELD_SIZEOF(struct stmmac_counters, m),	\
+	offsetof(struct stmmac_priv, mmc.m)}
+
+static const struct stmmac_stats stmmac_gstr_mmc[] = {
+	STMMAC_MMC_STAT(mmc_tx_octetcount_gb),
+	STMMAC_MMC_STAT(mmc_tx_framecount_gb),
+	STMMAC_MMC_STAT(mmc_tx_broadcastframe_g),
+	STMMAC_MMC_STAT(mmc_tx_multicastframe_g),
+	STMMAC_MMC_STAT(mmc_tx_64_octets_gb),
+	STMMAC_MMC_STAT(mmc_tx_65_to_127_octets_gb),
+	STMMAC_MMC_STAT(mmc_tx_128_to_255_octets_gb),
+	STMMAC_MMC_STAT(mmc_tx_256_to_511_octets_gb),
+	STMMAC_MMC_STAT(mmc_tx_512_to_1023_octets_gb),
+	STMMAC_MMC_STAT(mmc_tx_1024_to_max_octets_gb),
+	STMMAC_MMC_STAT(mmc_tx_unicast_gb),
+	STMMAC_MMC_STAT(mmc_tx_multicast_gb),
+	STMMAC_MMC_STAT(mmc_tx_broadcast_gb),
+	STMMAC_MMC_STAT(mmc_tx_underflow_error),
+	STMMAC_MMC_STAT(mmc_tx_singlecol_g),
+	STMMAC_MMC_STAT(mmc_tx_multicol_g),
+	STMMAC_MMC_STAT(mmc_tx_deferred),
+	STMMAC_MMC_STAT(mmc_tx_latecol),
+	STMMAC_MMC_STAT(mmc_tx_exesscol),
+	STMMAC_MMC_STAT(mmc_tx_carrier_error),
+	STMMAC_MMC_STAT(mmc_tx_octetcount_g),
+	STMMAC_MMC_STAT(mmc_tx_framecount_g),
+	STMMAC_MMC_STAT(mmc_tx_excessdef),
+	STMMAC_MMC_STAT(mmc_tx_pause_frame),
+	STMMAC_MMC_STAT(mmc_tx_vlan_frame_g),
+	STMMAC_MMC_STAT(mmc_rx_framecount_gb),
+	STMMAC_MMC_STAT(mmc_rx_octetcount_gb),
+	STMMAC_MMC_STAT(mmc_rx_octetcount_g),
+	STMMAC_MMC_STAT(mmc_rx_broadcastframe_g),
+	STMMAC_MMC_STAT(mmc_rx_multicastframe_g),
+	STMMAC_MMC_STAT(mmc_rx_crc_errror),
+	STMMAC_MMC_STAT(mmc_rx_align_error),
+	STMMAC_MMC_STAT(mmc_rx_run_error),
+	STMMAC_MMC_STAT(mmc_rx_jabber_error),
+	STMMAC_MMC_STAT(mmc_rx_undersize_g),
+	STMMAC_MMC_STAT(mmc_rx_oversize_g),
+	STMMAC_MMC_STAT(mmc_rx_64_octets_gb),
+	STMMAC_MMC_STAT(mmc_rx_65_to_127_octets_gb),
+	STMMAC_MMC_STAT(mmc_rx_128_to_255_octets_gb),
+	STMMAC_MMC_STAT(mmc_rx_256_to_511_octets_gb),
+	STMMAC_MMC_STAT(mmc_rx_512_to_1023_octets_gb),
+	STMMAC_MMC_STAT(mmc_rx_1024_to_max_octets_gb),
+	STMMAC_MMC_STAT(mmc_rx_unicast_g),
+	STMMAC_MMC_STAT(mmc_rx_length_error),
+	STMMAC_MMC_STAT(mmc_rx_autofrangetype),
+	STMMAC_MMC_STAT(mmc_rx_pause_frames),
+	STMMAC_MMC_STAT(mmc_rx_fifo_overflow),
+	STMMAC_MMC_STAT(mmc_rx_vlan_frames_gb),
+	STMMAC_MMC_STAT(mmc_rx_watchdog_error),
+	STMMAC_MMC_STAT(mmc_rx_ipc_intr_mask),
+	STMMAC_MMC_STAT(mmc_rx_ipc_intr),
+	STMMAC_MMC_STAT(mmc_rx_ipv4_gd),
+	STMMAC_MMC_STAT(mmc_rx_ipv4_hderr),
+	STMMAC_MMC_STAT(mmc_rx_ipv4_nopay),
+	STMMAC_MMC_STAT(mmc_rx_ipv4_frag),
+	STMMAC_MMC_STAT(mmc_rx_ipv4_udsbl),
+	STMMAC_MMC_STAT(mmc_rx_ipv4_gd_octets),
+	STMMAC_MMC_STAT(mmc_rx_ipv4_hderr_octets),
+	STMMAC_MMC_STAT(mmc_rx_ipv4_nopay_octets),
+	STMMAC_MMC_STAT(mmc_rx_ipv4_frag_octets),
+	STMMAC_MMC_STAT(mmc_rx_ipv4_udsbl_octets),
+	STMMAC_MMC_STAT(mmc_rx_ipv6_gd_octets),
+	STMMAC_MMC_STAT(mmc_rx_ipv6_hderr_octets),
+	STMMAC_MMC_STAT(mmc_rx_ipv6_nopay_octets),
+	STMMAC_MMC_STAT(mmc_rx_ipv6_gd),
+	STMMAC_MMC_STAT(mmc_rx_ipv6_hderr),
+	STMMAC_MMC_STAT(mmc_rx_ipv6_nopay),
+	STMMAC_MMC_STAT(mmc_rx_udp_gd),
+	STMMAC_MMC_STAT(mmc_rx_udp_err),
+	STMMAC_MMC_STAT(mmc_rx_tcp_gd),
+	STMMAC_MMC_STAT(mmc_rx_tcp_err),
+	STMMAC_MMC_STAT(mmc_rx_icmp_gd),
+	STMMAC_MMC_STAT(mmc_rx_icmp_err),
+	STMMAC_MMC_STAT(mmc_rx_udp_gd_octets),
+	STMMAC_MMC_STAT(mmc_rx_udp_err_octets),
+	STMMAC_MMC_STAT(mmc_rx_tcp_gd_octets),
+	STMMAC_MMC_STAT(mmc_rx_tcp_err_octets),
+	STMMAC_MMC_STAT(mmc_rx_icmp_gd_octets),
+	STMMAC_MMC_STAT(mmc_rx_icmp_err_octets),
+};
+#define STMMAC_MMC_STATS_LEN ARRAY_SIZE(stmmac_gstr_mmc)
+
 static void stmmac_ethtool_getdrvinfo(struct net_device *dev,
 				      struct ethtool_drvinfo *info)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
 
-	if (!priv->plat->has_gmac)
-		strcpy(info->driver, MAC100_ETHTOOL_NAME);
-	else
+	info->n_stats = STMMAC_STATS_LEN;
+
+	if (likely(priv->plat->has_gmac)) {
 		strcpy(info->driver, GMAC_ETHTOOL_NAME);
+		info->n_stats += STMMAC_MMC_STATS_LEN;
+	} else
+		strcpy(info->driver, MAC100_ETHTOOL_NAME);
 
 	strcpy(info->version, DRV_MODULE_VERSION);
 	info->fw_version[0] = '\0';
-	info->n_stats = STMMAC_STATS_LEN;
 }
 
 static int stmmac_ethtool_getsettings(struct net_device *dev,
@@ -252,24 +342,44 @@ static void stmmac_get_ethtool_stats(struct net_device *dev,
 				 struct ethtool_stats *dummy, u64 *data)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
-	int i;
-
-	/* Update HW stats if supported */
-	priv->hw->dma->dma_diagnostic_fr(&dev->stats, (void *) &priv->xstats,
-					 priv->ioaddr);
-
+	int i, j = 0;
+
+	/* Update the DMA HW counters for dwmac10/100 */
+	if (unlikely(!priv->plat->has_gmac))
+		priv->hw->dma->dma_diagnostic_fr(&dev->stats,
+						 (void *) &priv->xstats,
+						 priv->ioaddr);
+	else {
+		/* If supported, for new GMAC chips expose the MMC counters */
+		dwmac_mmc_read(priv->ioaddr, &priv->mmc);
+
+		for (i = 0; i < STMMAC_MMC_STATS_LEN; i++) {
+			char *p = (char *)priv + stmmac_gstr_mmc[i].stat_offset;
+
+			data[j++] = (stmmac_gstr_mmc[i].sizeof_stat ==
+				     sizeof(u64)) ? (*(u64 *)p) : (*(u32 *)p);
+		}
+	}
 	for (i = 0; i < STMMAC_STATS_LEN; i++) {
 		char *p = (char *)priv + stmmac_gstrings_stats[i].stat_offset;
-		data[i] = (stmmac_gstrings_stats[i].sizeof_stat ==
-		sizeof(u64)) ? (*(u64 *)p) : (*(u32 *)p);
+		data[j++] = (stmmac_gstrings_stats[i].sizeof_stat ==
+			     sizeof(u64)) ? (*(u64 *)p) : (*(u32 *)p);
 	}
 }
 
 static int stmmac_get_sset_count(struct net_device *netdev, int sset)
 {
+	struct stmmac_priv *priv = netdev_priv(netdev);
+	int len;
+
 	switch (sset) {
 	case ETH_SS_STATS:
-		return STMMAC_STATS_LEN;
+		len = STMMAC_STATS_LEN;
+
+		if (likely(priv->plat->has_gmac))
+			len += STMMAC_MMC_STATS_LEN;
+
+		return len;
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -279,9 +389,16 @@ static void stmmac_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 {
 	int i;
 	u8 *p = data;
+	struct stmmac_priv *priv = netdev_priv(dev);
 
 	switch (stringset) {
 	case ETH_SS_STATS:
+		if (likely(priv->plat->has_gmac))
+			for (i = 0; i < STMMAC_MMC_STATS_LEN; i++) {
+				memcpy(p, stmmac_gstr_mmc[i].stat_string,
+				       ETH_GSTRING_LEN);
+				p += ETH_GSTRING_LEN;
+			}
 		for (i = 0; i < STMMAC_STATS_LEN; i++) {
 			memcpy(p, stmmac_gstrings_stats[i].stat_string,
 				ETH_GSTRING_LEN);
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index 931cbf6..88b2973 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -747,6 +747,17 @@ static void stmmac_dma_interrupt(struct stmmac_priv *priv)
 		stmmac_tx_err(priv);
 }
 
+static void stmmac_mmc_setup(struct stmmac_priv *priv)
+{
+	unsigned int mode = MMC_CNTRL_RESET_ON_READ | MMC_CNTRL_COUNTER_RESET |
+			    MMC_CNTRL_PRESET | MMC_CNTRL_FULL_HALF_PRESET;
+
+	/* Do not manage MMC IRQ (FIXME) */
+	dwmac_mmc_intr_all_mask(priv->ioaddr);
+	dwmac_mmc_ctrl(priv->ioaddr, mode);
+	memset(&priv->mmc, 0, sizeof(struct stmmac_counters));
+}
+
 /**
  *  stmmac_open - open entry point of the driver
  *  @dev : pointer to the device structure.
@@ -845,6 +856,8 @@ static int stmmac_open(struct net_device *dev)
 	memset(&priv->xstats, 0, sizeof(struct stmmac_extra_stats));
 	priv->xstats.threshold = tc;
 
+	stmmac_mmc_setup(priv);
+
 	/* Start the ball rolling... */
 	DBG(probe, DEBUG, "%s: DMA RX/TX processes started...\n", dev->name);
 	priv->hw->dma->start_tx(priv->ioaddr);
-- 
1.7.4.4
