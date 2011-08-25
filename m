From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 3/9] stmmac: add MMC supports exported via debugfs.
Date: Thu, 25 Aug 2011 10:00:23 +0200
Message-ID: <1314259229-13767-4-git-send-email-peppe.cavallaro@st.com>
References: <1314259229-13767-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:47655 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751749Ab1HYIBC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 04:01:02 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 7768FE6
	for <netdev@vger.kernel.org>; Thu, 25 Aug 2011 08:00:59 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 254BA16A7
	for <netdev@vger.kernel.org>; Thu, 25 Aug 2011 08:00:59 +0000 (GMT)
In-Reply-To: <1314259229-13767-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the MMC management counters support.
MMC module is an extension of the register address
space and all the hardware counters can be accessed
via debugfs.
Below an example of the output:

  bash-3.00# cat /sys/kernel/debug/stmmaceth/mmc
==============================
MMC Management HW MAC counters
==============================
 -- MMC TX counter counters ---
        Number of bytes in good and bad frames: 1439120
        Number of good and bad frames transmitted: 9844
        Number of good Broadcast frame transmitted: 9
        Good and bad frames of 64bytes: 15
 [snip]
        Good and bad frames of 256-511: 11
        Good and bad frames of 512-1024: 15
        Good and bad frames bigger than 1024: 1930709609
        Good and bad unicast frames: 9835
        Good and bad broadcast frames: 9
        Frame aborted after carrier sense error: 1
        Number of bytes (no preamble) in good frames: 1439120
        Number of good frames transmitted: 9844
 -- MMC RX counter counters ---
        Number of good and bad frames: 14981
        Number of bytes in  good and bad frames recv: 12242993
 [snip]
 -- MMC IPC counters  ---
 -- MMC RX IPv4 counters  ---
 -- MMC RX IPV6 counters  ---
 -- MMC Protocols RX counters  ---

Note that, the MMC interrupts remain masked and the logic
to handle this kind of interrupt will be added later (if
actually useful).

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/Kconfig       |    9 ++
 drivers/net/stmmac/Makefile      |    3 +-
 drivers/net/stmmac/mmc.h         |  131 ++++++++++++++++++
 drivers/net/stmmac/mmc_core.c    |  265 ++++++++++++++++++++++++++++++++++++
 drivers/net/stmmac/stmmac.h      |    2 +
 drivers/net/stmmac/stmmac_main.c |  277 +++++++++++++++++++++++++++++++++++++-
 6 files changed, 685 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/stmmac/mmc.h
 create mode 100644 drivers/net/stmmac/mmc_core.c

diff --git a/drivers/net/stmmac/Kconfig b/drivers/net/stmmac/Kconfig
index 7df7df4..0a1bd82 100644
--- a/drivers/net/stmmac/Kconfig
+++ b/drivers/net/stmmac/Kconfig
@@ -11,6 +11,15 @@ config STMMAC_ETH
 
 if STMMAC_ETH
 
+config STMMAC_MONITOR
+	bool "Enable monitoring via sysFS "
+	default n
+	depends on STMMAC_ETH && DEBUG_FS
+	-- help
+	  To Enable monitoring via debufs.
+	  The stmmac entry in /sys reports the state of the HW monitoring
+	  counters (if supported).
+
 config STMMAC_DA
 	bool "STMMAC DMA arbitration scheme"
 	default n
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
index de1929b..bccf1f1 100644
--- a/drivers/net/stmmac/stmmac.h
+++ b/drivers/net/stmmac/stmmac.h
@@ -27,6 +27,7 @@
 #ifdef CONFIG_STMMAC_TIMER
 #include "stmmac_timer.h"
 #endif
+#include "mmc.h"
 
 struct stmmac_priv {
 	/* Frequently used values are kept adjacent for cache effect */
@@ -76,6 +77,7 @@ struct stmmac_priv {
 	struct stmmac_timer *tm;
 #endif
 	struct plat_stmmacenet_data *plat;
+	struct stmmac_counters mmc;
 };
 
 extern int stmmac_mdio_unregister(struct net_device *ndev);
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index da11405..4655fab 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -47,6 +47,10 @@
 #include <linux/slab.h>
 #include <linux/prefetch.h>
 #include "stmmac.h"
+#ifdef CONFIG_STMMAC_MONITOR
+#include <linux/debugfs.h>
+#include <linux/seq_file.h>
+#endif
 
 #define STMMAC_RESOURCE_NAME	"stmmaceth"
 
@@ -747,6 +751,17 @@ static void stmmac_dma_interrupt(struct stmmac_priv *priv)
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
@@ -845,6 +860,8 @@ static int stmmac_open(struct net_device *dev)
 	memset(&priv->xstats, 0, sizeof(struct stmmac_extra_stats));
 	priv->xstats.threshold = tc;
 
+	stmmac_mmc_setup(priv);
+
 	/* Start the ball rolling... */
 	DBG(probe, DEBUG, "%s: DMA RX/TX processes started...\n", dev->name);
 	priv->hw->dma->start_tx(priv->ioaddr);
@@ -1411,6 +1428,254 @@ static int stmmac_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	return ret;
 }
 
+#ifdef CONFIG_STMMAC_MONITOR
+static struct dentry *stmmac_fs_dir;
+static struct dentry *stmmac_mmc;
+
+/* To only dump counters > 0 */
+static inline void seq_printf_mmc(struct seq_file *seq,
+				  const char *description,
+				  unsigned int counter)
+{
+	if (counter > 0)
+		seq_printf(seq, "\t%s%d\n", description, counter);
+}
+
+static int stmmac_sysfs_mmc_read(struct seq_file *seq, void *v)
+{
+	struct net_device *dev = seq->private;
+	struct stmmac_priv *priv = netdev_priv(dev);
+
+	seq_printf(seq, "==============================\n");
+	seq_printf(seq, "MMC Management HW MAC counters\n");
+	seq_printf(seq, "==============================\n");
+
+	dwmac_mmc_read(priv->ioaddr, &priv->mmc);
+
+	seq_printf(seq, " -- MMC TX counter counters ---\n");
+
+	seq_printf_mmc(seq, "Number of bytes in good and bad frames: ",
+		       priv->mmc.mmc_tx_octetcount_gb);
+	seq_printf_mmc(seq, "Number of good and bad frames transmitted: ",
+		       priv->mmc.mmc_tx_framecount_gb);
+	seq_printf_mmc(seq, "Number of good Broadcast frame transmitted: ",
+		       priv->mmc.mmc_tx_broadcastframe_g);
+	seq_printf_mmc(seq, "Number of good Multicast frame transmitted: ",
+		       priv->mmc.mmc_tx_multicastframe_g);
+	seq_printf_mmc(seq, "Good and bad frames of 64bytes: ",
+		       priv->mmc.mmc_tx_64_octets_gb);
+	seq_printf_mmc(seq, "Good and bad frames of 65-127: ",
+		       priv->mmc.mmc_tx_65_to_127_octets_gb);
+	seq_printf_mmc(seq, "Good and bad frames of 128-255: ",
+		       priv->mmc.mmc_tx_128_to_255_octets_gb);
+	seq_printf_mmc(seq, "Good and bad frames of 256-511: ",
+		       priv->mmc.mmc_tx_256_to_511_octets_gb);
+	seq_printf_mmc(seq, "Good and bad frames of 512-1024: ",
+		       priv->mmc.mmc_tx_512_to_1023_octets_gb);
+	seq_printf_mmc(seq, "Good and bad frames bigger than 1024: ",
+		       priv->mmc.mmc_tx_1024_to_max_octets_gb);
+	seq_printf_mmc(seq, "Good and bad unicast frames: ",
+		       priv->mmc.mmc_tx_unicast_gb);
+	seq_printf_mmc(seq, "Good and bad multicast frames: ",
+		       priv->mmc.mmc_tx_multicast_gb);
+	seq_printf_mmc(seq, "Good and bad broadcast frames: ",
+		       priv->mmc.mmc_tx_broadcast_gb);
+	seq_printf_mmc(seq, "Number of tx Underflow errors: ",
+		       priv->mmc.mmc_tx_underflow_error);
+	seq_printf_mmc(seq, "Good frms after single collision (Half Duplex): ",
+		       priv->mmc.mmc_tx_singlecol_g);
+	seq_printf_mmc(seq, "Good frames after multi collision (Half Duplex): ",
+		       priv->mmc.mmc_tx_multicol_g);
+	seq_printf_mmc(seq, "Good frames after deferral error (Half Duplex): ",
+		       priv->mmc.mmc_tx_deferred);
+	seq_printf_mmc(seq, "Frame aborted after late collisions: ",
+		       priv->mmc.mmc_tx_latecol);
+	seq_printf_mmc(seq, "Frame aborted after excessive collisions: ",
+		       priv->mmc.mmc_tx_exesscol);
+	seq_printf_mmc(seq, "Frame aborted after carrier sense error: ",
+		       priv->mmc.mmc_tx_carrier_error);
+	seq_printf_mmc(seq, "Number of bytes (no preamble) in good frames: ",
+		       priv->mmc.mmc_tx_octetcount_g);
+	seq_printf_mmc(seq, "Number of good frames transmitted: ",
+		       priv->mmc.mmc_tx_framecount_g);
+	seq_printf_mmc(seq, "Frame aborted due to excessive deferral errors: ",
+		       priv->mmc.mmc_tx_excessdef);
+	seq_printf_mmc(seq, "Number of good pause frames: ",
+		       priv->mmc.mmc_tx_pause_frame);
+	seq_printf_mmc(seq, "Number of good VLAN frames: ",
+		       priv->mmc.mmc_tx_vlan_frame_g);
+
+	seq_printf(seq, " -- MMC RX counter counters ---\n");
+
+	seq_printf_mmc(seq, "Number of good and bad frames: ",
+		       priv->mmc.mmc_rx_framecount_gb);
+	seq_printf_mmc(seq, "Number of bytes in  good and bad frames recv: ",
+		       priv->mmc.mmc_rx_octetcount_gb);
+	seq_printf_mmc(seq, "Number of bytes in good frms (no preample): ",
+		       priv->mmc.mmc_rx_octetcount_g);
+	seq_printf_mmc(seq, "Good broadcast frames: ",
+		       priv->mmc.mmc_rx_broadcastframe_g);
+	seq_printf_mmc(seq, "Good multicast frames: ",
+		       priv->mmc.mmc_rx_multicastframe_g);
+	seq_printf_mmc(seq, "Number of CRC err: ",
+		       priv->mmc.mmc_rx_crc_errror);
+	seq_printf_mmc(seq, "Frames with dribble error: ",
+		       priv->mmc.mmc_rx_align_error);
+	seq_printf_mmc(seq, "Number of frames with runt error: ",
+		       priv->mmc.mmc_rx_run_error);
+	seq_printf_mmc(seq, "Number of giant frame: ",
+		       priv->mmc.mmc_rx_jabber_error);
+	seq_printf_mmc(seq, "Number of frames with size < 64bytes w/o error: ",
+		       priv->mmc.mmc_rx_undersize_g);
+	seq_printf_mmc(seq, "Number of oversized frames w/o errors: ",
+		       priv->mmc.mmc_rx_oversize_g);
+	seq_printf_mmc(seq, "Good and bad frames of 64bytes: ",
+		       priv->mmc.mmc_rx_64_octets_gb);
+	seq_printf_mmc(seq, "Good and bad frames of 65-127: ",
+		       priv->mmc.mmc_rx_65_to_127_octets_gb);
+	seq_printf_mmc(seq, "Good and bad frames of 128-255: ",
+		       priv->mmc.mmc_rx_128_to_255_octets_gb);
+	seq_printf_mmc(seq, "Good and bad frames of 256-511: ",
+		       priv->mmc.mmc_rx_256_to_511_octets_gb);
+	seq_printf_mmc(seq, "Good and bad frames of 512-1024: ",
+		       priv->mmc.mmc_rx_512_to_1023_octets_gb);
+	seq_printf_mmc(seq, "Good and bad frames bigger than 1024: ",
+		       priv->mmc.mmc_rx_1024_to_max_octets_gb);
+	seq_printf_mmc(seq, "Good unicast frames: ",
+		       priv->mmc.mmc_rx_unicast_g);
+	seq_printf_mmc(seq, "Number of frames with length errors: ",
+		       priv->mmc.mmc_rx_length_error);
+	seq_printf_mmc(seq, "Number of frames with length not equal to the"
+		       " valid frame size: ",  priv->mmc.mmc_rx_autofrangetype);
+	seq_printf_mmc(seq, "Number of goog and valid PAUSE frames: ",
+		       priv->mmc.mmc_rx_pause_frames);
+	seq_printf_mmc(seq, "Number of FIFO overflow errors: ",
+		       priv->mmc.mmc_rx_fifo_overflow);
+	seq_printf_mmc(seq, "Number of good VLAN frames: ",
+		       priv->mmc.mmc_rx_vlan_frames_gb);
+	seq_printf_mmc(seq, "Number of frames with watchdog error: ",
+		       priv->mmc.mmc_rx_watchdog_error);
+
+	seq_printf(seq, " -- MMC IPC counters  ---\n");
+	seq_printf_mmc(seq, "MMC IPC interrupt mask: ",
+			priv->mmc.mmc_rx_ipc_intr_mask);
+	seq_printf_mmc(seq, "MMC RX IPC interrupt mask:",
+		       priv->mmc.mmc_rx_ipc_intr);
+
+	seq_printf(seq, " -- MMC RX IPv4 counters  ---\n");
+	seq_printf_mmc(seq, "Good TCP/UDP/ICMP datagram: s",
+		       priv->mmc.mmc_rx_ipv4_gd);
+	seq_printf_mmc(seq, "IPv4 with header errors (CRC/len/vers mismatch): ",
+		       priv->mmc.mmc_rx_ipv4_hderr);
+	seq_printf_mmc(seq, "Number of datagram received that did not have"
+		       " TCP/UDP/ICMP payload processed by the Csum engine: ",
+		       priv->mmc.mmc_rx_ipv4_nopay);
+	seq_printf_mmc(seq, "Good datagram with fragmentation: ",
+		       priv->mmc.mmc_rx_ipv4_frag);
+	seq_printf_mmc(seq, "Good datagram that had a UDP payload with"
+		       "checksum disabled: ", priv->mmc.mmc_rx_ipv4_udsbl);
+
+	seq_printf_mmc(seq, "N. of bytes in good datagrams: ",
+		       priv->mmc.mmc_rx_ipv4_gd_octets);
+	seq_printf_mmc(seq, "N. of bytes with header errors: ",
+		       priv->mmc.mmc_rx_ipv4_hderr_octets);
+	seq_printf_mmc(seq, "N. of bytes that not have TCP/UDP/ICMP payload: ",
+		       priv->mmc.mmc_rx_ipv4_nopay_octets);
+	seq_printf_mmc(seq, "N. of bytes in fragmented datagrams: ",
+		       priv->mmc.mmc_rx_ipv4_frag_octets);
+	seq_printf_mmc(seq, "N. of bytes in UDP segment w/o csum: ",
+		       priv->mmc.mmc_rx_ipv4_udsbl_octets);
+
+	seq_printf(seq, " -- MMC RX IPV6 counters  ---\n");
+	seq_printf_mmc(seq, "N. of good datagrams with TCP/UDP/ICMP payload: ",
+		       priv->mmc.mmc_rx_ipv6_gd);
+	seq_printf_mmc(seq, "N. of good datagrams with header errors: ",
+		       priv->mmc.mmc_rx_ipv6_hderr);
+	seq_printf_mmc(seq, "N. of datagram received that did not have"
+		       " TCP/UDP/ICMP payload: ", priv->mmc.mmc_rx_ipv6_nopay);
+
+	seq_printf_mmc(seq, "N. of bytes in good IPv6 datagrams: ",
+		       priv->mmc.mmc_rx_ipv6_gd_octets);
+	seq_printf_mmc(seq, "N. of bytes in IPv6 datagrams with header err: ",
+		       priv->mmc.mmc_rx_ipv6_hderr_octets);
+	seq_printf_mmc(seq, "N. of bytes in datagrams that did not have a"
+		       " TCP/UDP/ICMP payload: ",
+		       priv->mmc.mmc_rx_ipv6_nopay_octets);
+
+	seq_printf(seq, " -- MMC Protocols RX counters  ---\n");
+	seq_printf_mmc(seq, "N. of good IP datagrams with a good UDP payload: ",
+		       priv->mmc.mmc_rx_udp_gd);
+	seq_printf_mmc(seq, " and the number of bytes:",
+		       priv->mmc.mmc_rx_udp_gd_octets);
+	seq_printf_mmc(seq, "N. of good IP datagrams whose UDP payload has a "
+		       "checksum error: ",  priv->mmc.mmc_rx_udp_err);
+	seq_printf_mmc(seq, " and the number of bytes: ",
+		       priv->mmc.mmc_rx_udp_err_octets);
+	seq_printf_mmc(seq, "N. of good IP datagrams with a good TCP payload: ",
+		       priv->mmc.mmc_rx_tcp_gd);
+	seq_printf_mmc(seq, " and the number of bytes:",
+		       priv->mmc.mmc_rx_tcp_gd_octets);
+	seq_printf_mmc(seq, "N. of good IP datagrams whose TCP payload has a "
+		       "checksum error: ",  priv->mmc.mmc_rx_tcp_err);
+	seq_printf_mmc(seq, " and the number of bytes: ",
+		       priv->mmc.mmc_rx_tcp_err_octets);
+	seq_printf_mmc(seq, "N. of good IP datagrams with good ICMP payload: ",
+		       priv->mmc.mmc_rx_icmp_gd);
+	seq_printf_mmc(seq, " and the number of bytes: ",
+		       priv->mmc.mmc_rx_icmp_gd_octets);
+	seq_printf_mmc(seq, "N. of good IP datagrams whose ICMP payload has a "
+		       "checksum error: ",  priv->mmc.mmc_rx_icmp_err);
+	seq_printf_mmc(seq, " and the number of bytes: ",
+		       priv->mmc.mmc_rx_icmp_err_octets);
+
+	return 0;
+}
+
+static int stmmac_sysfs_mmc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, stmmac_sysfs_mmc_read, inode->i_private);
+}
+
+static const struct file_operations stmmac_mmc_fops = {
+	.owner = THIS_MODULE,
+	.open = stmmac_sysfs_mmc_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = seq_release,
+};
+
+static int stmmac_init_fs(struct net_device *dev)
+{
+	/* Create debugfs entries */
+	stmmac_fs_dir = debugfs_create_dir(STMMAC_RESOURCE_NAME, NULL);
+
+	if (!stmmac_fs_dir || IS_ERR(stmmac_fs_dir)) {
+		pr_err("ERROR %s, debugfs create directory failed\n",
+		       STMMAC_RESOURCE_NAME);
+
+		return -ENOMEM;
+	}
+
+	stmmac_mmc = debugfs_create_file("mmc", S_IRUGO, stmmac_fs_dir, dev,
+					   &stmmac_mmc_fops);
+
+	if (!stmmac_mmc || IS_ERR(stmmac_mmc)) {
+		pr_info("ERROR creating stmmac MMC debugfs file\n");
+		debugfs_remove(stmmac_fs_dir);
+
+		return -ENOMEM;
+	}
+
+	return 0;
+}
+
+static void stmmac_exit_fs(void)
+{
+	debugfs_remove(stmmac_mmc);
+	debugfs_remove(stmmac_fs_dir);
+}
+#endif /* CONFIG_STMMAC_MONITOR */
+
 static const struct net_device_ops stmmac_netdev_ops = {
 	.ndo_open = stmmac_open,
 	.ndo_start_xmit = stmmac_xmit,
@@ -1623,6 +1888,13 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 	if (ret < 0)
 		goto out_unregister;
 	pr_debug("registered!\n");
+
+#ifdef CONFIG_STMMAC_MONITOR
+	ret = stmmac_init_fs(ndev);
+	if (ret < 0)
+		pr_warning("\tFailed debugFS registration");
+#endif
+
 	return 0;
 
 out_unregister:
@@ -1675,6 +1947,10 @@ static int stmmac_dvr_remove(struct platform_device *pdev)
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	release_mem_region(res->start, resource_size(res));
 
+#ifdef CONFIG_STMMAC_MONITOR
+	stmmac_exit_fs();
+#endif
+
 	free_netdev(ndev);
 
 	return 0;
@@ -1810,7 +2086,6 @@ static struct platform_driver stmmac_driver = {
 static int __init stmmac_init_module(void)
 {
 	int ret;
-
 	ret = platform_driver_register(&stmmac_driver);
 	return ret;
 }
-- 
1.7.4.4
