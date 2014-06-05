From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH V3 net-next 2/5] amd-xgbe: Initial AMD 10GbE platform driver
Date: Thu, 5 Jun 2014 09:15:06 -0500
Message-ID: <20140605141506.19317.68850.stgit@tlendack-t1.amdoffice.net>
References: <20140605141454.19317.87165.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <jcm@redhat.com>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dns-bn1lp0143.outbound.protection.outlook.com ([207.46.163.143]:47642
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751653AbaFEOPO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2014 10:15:14 -0400
In-Reply-To: <20140605141454.19317.87165.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch provides the initial platform driver for the AMD
10GbE device.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/Makefile       |    6 
 drivers/net/ethernet/amd/xgbe/xgbe-common.h  | 1007 ++++++++++++
 drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c |  375 ++++
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c    |  556 +++++++
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c     | 2183 ++++++++++++++++++++++++++
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c     | 1351 ++++++++++++++++
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c |  510 ++++++
 drivers/net/ethernet/amd/xgbe/xgbe-main.c    |  512 ++++++
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c    |  433 +++++
 drivers/net/ethernet/amd/xgbe/xgbe.h         |  676 ++++++++
 10 files changed, 7609 insertions(+)
 create mode 100644 drivers/net/ethernet/amd/xgbe/Makefile
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe-common.h
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe-desc.c
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe-dev.c
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe-drv.c
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe-main.c
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe.h

diff --git a/drivers/net/ethernet/amd/xgbe/Makefile b/drivers/net/ethernet/amd/xgbe/Makefile
new file mode 100644
index 0000000..26cf9af
--- /dev/null
+++ b/drivers/net/ethernet/amd/xgbe/Makefile
@@ -0,0 +1,6 @@
+obj-$(CONFIG_AMD_XGBE) += amd-xgbe.o
+
+amd-xgbe-objs := xgbe-main.o xgbe-drv.o xgbe-dev.o \
+		 xgbe-desc.o xgbe-ethtool.o xgbe-mdio.o
+
+amd-xgbe-$(CONFIG_DEBUG_FS) += xgbe-debugfs.o
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-common.h b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
new file mode 100644
index 0000000..bf462ee8
--- /dev/null
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
@@ -0,0 +1,1007 @@
+/*
+ * AMD 10Gb Ethernet driver
+ *
+ * This file is available to you under your choice of the following two
+ * licenses:
+ *
+ * License 1: GPLv2
+ *
+ * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ *
+ * This file is free software; you may copy, redistribute and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation, either version 2 of the License, or (at
+ * your option) any later version.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ *
+ * This file incorporates work covered by the following copyright and
+ * permission notice:
+ *     The Synopsys DWC ETHER XGMAC Software Driver and documentation
+ *     (hereinafter "Software") is an unsupported proprietary work of Synopsys,
+ *     Inc. unless otherwise expressly agreed to in writing between Synopsys
+ *     and you.
+ *
+ *     The Software IS NOT an item of Licensed Software or Licensed Product
+ *     under any End User Software License Agreement or Agreement for Licensed
+ *     Product with Synopsys or any supplement thereto.  Permission is hereby
+ *     granted, free of charge, to any person obtaining a copy of this software
+ *     annotated with this license and the Software, to deal in the Software
+ *     without restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or sell copies
+ *     of the Software, and to permit persons to whom the Software is furnished
+ *     to do so, subject to the following conditions:
+ *
+ *     The above copyright notice and this permission notice shall be included
+ *     in all copies or substantial portions of the Software.
+ *
+ *     THIS SOFTWARE IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN "AS IS"
+ *     BASIS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
+ *     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+ *     PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS
+ *     BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ *     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
+ *     THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ *
+ * License 2: Modified BSD
+ *
+ * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ * All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Advanced Micro Devices, Inc. nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
+ * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ * This file incorporates work covered by the following copyright and
+ * permission notice:
+ *     The Synopsys DWC ETHER XGMAC Software Driver and documentation
+ *     (hereinafter "Software") is an unsupported proprietary work of Synopsys,
+ *     Inc. unless otherwise expressly agreed to in writing between Synopsys
+ *     and you.
+ *
+ *     The Software IS NOT an item of Licensed Software or Licensed Product
+ *     under any End User Software License Agreement or Agreement for Licensed
+ *     Product with Synopsys or any supplement thereto.  Permission is hereby
+ *     granted, free of charge, to any person obtaining a copy of this software
+ *     annotated with this license and the Software, to deal in the Software
+ *     without restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or sell copies
+ *     of the Software, and to permit persons to whom the Software is furnished
+ *     to do so, subject to the following conditions:
+ *
+ *     The above copyright notice and this permission notice shall be included
+ *     in all copies or substantial portions of the Software.
+ *
+ *     THIS SOFTWARE IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN "AS IS"
+ *     BASIS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
+ *     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+ *     PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS
+ *     BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ *     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
+ *     THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef __XGBE_COMMON_H__
+#define __XGBE_COMMON_H__
+
+/* DMA register offsets */
+#define DMA_MR				0x3000
+#define DMA_SBMR			0x3004
+#define DMA_ISR				0x3008
+#define DMA_AXIARCR			0x3010
+#define DMA_AXIAWCR			0x3018
+#define DMA_DSR0			0x3020
+#define DMA_DSR1			0x3024
+#define DMA_DSR2			0x3028
+#define DMA_DSR3			0x302c
+#define DMA_DSR4			0x3030
+
+/* DMA register entry bit positions and sizes */
+#define DMA_AXIARCR_DRC_INDEX		0
+#define DMA_AXIARCR_DRC_WIDTH		4
+#define DMA_AXIARCR_DRD_INDEX		4
+#define DMA_AXIARCR_DRD_WIDTH		2
+#define DMA_AXIARCR_TEC_INDEX		8
+#define DMA_AXIARCR_TEC_WIDTH		4
+#define DMA_AXIARCR_TED_INDEX		12
+#define DMA_AXIARCR_TED_WIDTH		2
+#define DMA_AXIARCR_THC_INDEX		16
+#define DMA_AXIARCR_THC_WIDTH		4
+#define DMA_AXIARCR_THD_INDEX		20
+#define DMA_AXIARCR_THD_WIDTH		2
+#define DMA_AXIAWCR_DWC_INDEX		0
+#define DMA_AXIAWCR_DWC_WIDTH		4
+#define DMA_AXIAWCR_DWD_INDEX		4
+#define DMA_AXIAWCR_DWD_WIDTH		2
+#define DMA_AXIAWCR_RPC_INDEX		8
+#define DMA_AXIAWCR_RPC_WIDTH		4
+#define DMA_AXIAWCR_RPD_INDEX		12
+#define DMA_AXIAWCR_RPD_WIDTH		2
+#define DMA_AXIAWCR_RHC_INDEX		16
+#define DMA_AXIAWCR_RHC_WIDTH		4
+#define DMA_AXIAWCR_RHD_INDEX		20
+#define DMA_AXIAWCR_RHD_WIDTH		2
+#define DMA_AXIAWCR_TDC_INDEX		24
+#define DMA_AXIAWCR_TDC_WIDTH		4
+#define DMA_AXIAWCR_TDD_INDEX		28
+#define DMA_AXIAWCR_TDD_WIDTH		2
+#define DMA_DSR0_RPS_INDEX		8
+#define DMA_DSR0_RPS_WIDTH		4
+#define DMA_DSR0_TPS_INDEX		12
+#define DMA_DSR0_TPS_WIDTH		4
+#define DMA_ISR_MACIS_INDEX		17
+#define DMA_ISR_MACIS_WIDTH		1
+#define DMA_ISR_MTLIS_INDEX		16
+#define DMA_ISR_MTLIS_WIDTH		1
+#define DMA_MR_SWR_INDEX		0
+#define DMA_MR_SWR_WIDTH		1
+#define DMA_SBMR_EAME_INDEX		11
+#define DMA_SBMR_EAME_WIDTH		1
+#define DMA_SBMR_UNDEF_INDEX		0
+#define DMA_SBMR_UNDEF_WIDTH		1
+
+/* DMA channel register offsets
+ *   Multiple channels can be active.  The first channel has registers
+ *   that begin at 0x3100.  Each subsequent channel has registers that
+ *   are accessed using an offset of 0x80 from the previous channel.
+ */
+#define DMA_CH_BASE			0x3100
+#define DMA_CH_INC			0x80
+
+#define DMA_CH_CR			0x00
+#define DMA_CH_TCR			0x04
+#define DMA_CH_RCR			0x08
+#define DMA_CH_TDLR_HI			0x10
+#define DMA_CH_TDLR_LO			0x14
+#define DMA_CH_RDLR_HI			0x18
+#define DMA_CH_RDLR_LO			0x1c
+#define DMA_CH_TDTR_LO			0x24
+#define DMA_CH_RDTR_LO			0x2c
+#define DMA_CH_TDRLR			0x30
+#define DMA_CH_RDRLR			0x34
+#define DMA_CH_IER			0x38
+#define DMA_CH_RIWT			0x3c
+#define DMA_CH_CATDR_LO			0x44
+#define DMA_CH_CARDR_LO			0x4c
+#define DMA_CH_CATBR_HI			0x50
+#define DMA_CH_CATBR_LO			0x54
+#define DMA_CH_CARBR_HI			0x58
+#define DMA_CH_CARBR_LO			0x5c
+#define DMA_CH_SR			0x60
+
+/* DMA channel register entry bit positions and sizes */
+#define DMA_CH_CR_PBLX8_INDEX		16
+#define DMA_CH_CR_PBLX8_WIDTH		1
+#define DMA_CH_IER_AIE_INDEX		15
+#define DMA_CH_IER_AIE_WIDTH		1
+#define DMA_CH_IER_FBEE_INDEX		12
+#define DMA_CH_IER_FBEE_WIDTH		1
+#define DMA_CH_IER_NIE_INDEX		16
+#define DMA_CH_IER_NIE_WIDTH		1
+#define DMA_CH_IER_RBUE_INDEX		7
+#define DMA_CH_IER_RBUE_WIDTH		1
+#define DMA_CH_IER_RIE_INDEX		6
+#define DMA_CH_IER_RIE_WIDTH		1
+#define DMA_CH_IER_RSE_INDEX		8
+#define DMA_CH_IER_RSE_WIDTH		1
+#define DMA_CH_IER_TBUE_INDEX		2
+#define DMA_CH_IER_TBUE_WIDTH		1
+#define DMA_CH_IER_TIE_INDEX		0
+#define DMA_CH_IER_TIE_WIDTH		1
+#define DMA_CH_IER_TXSE_INDEX		1
+#define DMA_CH_IER_TXSE_WIDTH		1
+#define DMA_CH_RCR_PBL_INDEX		16
+#define DMA_CH_RCR_PBL_WIDTH		6
+#define DMA_CH_RCR_RBSZ_INDEX		1
+#define DMA_CH_RCR_RBSZ_WIDTH		14
+#define DMA_CH_RCR_SR_INDEX		0
+#define DMA_CH_RCR_SR_WIDTH		1
+#define DMA_CH_RIWT_RWT_INDEX		0
+#define DMA_CH_RIWT_RWT_WIDTH		8
+#define DMA_CH_SR_FBE_INDEX		12
+#define DMA_CH_SR_FBE_WIDTH		1
+#define DMA_CH_SR_RBU_INDEX		7
+#define DMA_CH_SR_RBU_WIDTH		1
+#define DMA_CH_SR_RI_INDEX		6
+#define DMA_CH_SR_RI_WIDTH		1
+#define DMA_CH_SR_RPS_INDEX		8
+#define DMA_CH_SR_RPS_WIDTH		1
+#define DMA_CH_SR_TBU_INDEX		2
+#define DMA_CH_SR_TBU_WIDTH		1
+#define DMA_CH_SR_TI_INDEX		0
+#define DMA_CH_SR_TI_WIDTH		1
+#define DMA_CH_SR_TPS_INDEX		1
+#define DMA_CH_SR_TPS_WIDTH		1
+#define DMA_CH_TCR_OSP_INDEX		4
+#define DMA_CH_TCR_OSP_WIDTH		1
+#define DMA_CH_TCR_PBL_INDEX		16
+#define DMA_CH_TCR_PBL_WIDTH		6
+#define DMA_CH_TCR_ST_INDEX		0
+#define DMA_CH_TCR_ST_WIDTH		1
+#define DMA_CH_TCR_TSE_INDEX		12
+#define DMA_CH_TCR_TSE_WIDTH		1
+
+/* DMA channel register values */
+#define DMA_OSP_DISABLE			0x00
+#define DMA_OSP_ENABLE			0x01
+#define DMA_PBL_1			1
+#define DMA_PBL_2			2
+#define DMA_PBL_4			4
+#define DMA_PBL_8			8
+#define DMA_PBL_16			16
+#define DMA_PBL_32			32
+#define DMA_PBL_64			64      /* 8 x 8 */
+#define DMA_PBL_128			128     /* 8 x 16 */
+#define DMA_PBL_256			256     /* 8 x 32 */
+#define DMA_PBL_X8_DISABLE		0x00
+#define DMA_PBL_X8_ENABLE		0x01
+
+
+/* MAC register offsets */
+#define MAC_TCR				0x0000
+#define MAC_RCR				0x0004
+#define MAC_PFR				0x0008
+#define MAC_WTR				0x000c
+#define MAC_HTR0			0x0010
+#define MAC_HTR1			0x0014
+#define MAC_HTR2			0x0018
+#define MAC_HTR3			0x001c
+#define MAC_HTR4			0x0020
+#define MAC_HTR5			0x0024
+#define MAC_HTR6			0x0028
+#define MAC_HTR7			0x002c
+#define MAC_VLANTR			0x0050
+#define MAC_VLANHTR			0x0058
+#define MAC_VLANIR			0x0060
+#define MAC_IVLANIR			0x0064
+#define MAC_RETMR			0x006c
+#define MAC_Q0TFCR			0x0070
+#define MAC_RFCR			0x0090
+#define MAC_RQC0R			0x00a0
+#define MAC_RQC1R			0x00a4
+#define MAC_RQC2R			0x00a8
+#define MAC_RQC3R			0x00ac
+#define MAC_ISR				0x00b0
+#define MAC_IER				0x00b4
+#define MAC_RTSR			0x00b8
+#define MAC_PMTCSR			0x00c0
+#define MAC_RWKPFR			0x00c4
+#define MAC_LPICSR			0x00d0
+#define MAC_LPITCR			0x00d4
+#define MAC_VR				0x0110
+#define MAC_DR				0x0114
+#define MAC_HWF0R			0x011c
+#define MAC_HWF1R			0x0120
+#define MAC_HWF2R			0x0124
+#define MAC_GPIOCR			0x0278
+#define MAC_GPIOSR			0x027c
+#define MAC_MACA0HR			0x0300
+#define MAC_MACA0LR			0x0304
+#define MAC_MACA1HR			0x0308
+#define MAC_MACA1LR			0x030c
+
+#define MAC_QTFCR_INC			4
+#define MAC_MACA_INC			4
+
+/* MAC register entry bit positions and sizes */
+#define MAC_HWF0R_ADDMACADRSEL_INDEX	18
+#define MAC_HWF0R_ADDMACADRSEL_WIDTH	5
+#define MAC_HWF0R_ARPOFFSEL_INDEX	9
+#define MAC_HWF0R_ARPOFFSEL_WIDTH	1
+#define MAC_HWF0R_EEESEL_INDEX		13
+#define MAC_HWF0R_EEESEL_WIDTH		1
+#define MAC_HWF0R_GMIISEL_INDEX		1
+#define MAC_HWF0R_GMIISEL_WIDTH		1
+#define MAC_HWF0R_MGKSEL_INDEX		7
+#define MAC_HWF0R_MGKSEL_WIDTH		1
+#define MAC_HWF0R_MMCSEL_INDEX		8
+#define MAC_HWF0R_MMCSEL_WIDTH		1
+#define MAC_HWF0R_RWKSEL_INDEX		6
+#define MAC_HWF0R_RWKSEL_WIDTH		1
+#define MAC_HWF0R_RXCOESEL_INDEX	16
+#define MAC_HWF0R_RXCOESEL_WIDTH	1
+#define MAC_HWF0R_SAVLANINS_INDEX	27
+#define MAC_HWF0R_SAVLANINS_WIDTH	1
+#define MAC_HWF0R_SMASEL_INDEX		5
+#define MAC_HWF0R_SMASEL_WIDTH		1
+#define MAC_HWF0R_TSSEL_INDEX		12
+#define MAC_HWF0R_TSSEL_WIDTH		1
+#define MAC_HWF0R_TSSTSSEL_INDEX	25
+#define MAC_HWF0R_TSSTSSEL_WIDTH	2
+#define MAC_HWF0R_TXCOESEL_INDEX	14
+#define MAC_HWF0R_TXCOESEL_WIDTH	1
+#define MAC_HWF0R_VLHASH_INDEX		4
+#define MAC_HWF0R_VLHASH_WIDTH		1
+#define MAC_HWF1R_ADVTHWORD_INDEX	13
+#define MAC_HWF1R_ADVTHWORD_WIDTH	1
+#define MAC_HWF1R_DBGMEMA_INDEX		19
+#define MAC_HWF1R_DBGMEMA_WIDTH		1
+#define MAC_HWF1R_DCBEN_INDEX		16
+#define MAC_HWF1R_DCBEN_WIDTH		1
+#define MAC_HWF1R_HASHTBLSZ_INDEX	24
+#define MAC_HWF1R_HASHTBLSZ_WIDTH	3
+#define MAC_HWF1R_L3L4FNUM_INDEX	27
+#define MAC_HWF1R_L3L4FNUM_WIDTH	4
+#define MAC_HWF1R_RSSEN_INDEX		20
+#define MAC_HWF1R_RSSEN_WIDTH		1
+#define MAC_HWF1R_RXFIFOSIZE_INDEX	0
+#define MAC_HWF1R_RXFIFOSIZE_WIDTH	5
+#define MAC_HWF1R_SPHEN_INDEX		17
+#define MAC_HWF1R_SPHEN_WIDTH		1
+#define MAC_HWF1R_TSOEN_INDEX		18
+#define MAC_HWF1R_TSOEN_WIDTH		1
+#define MAC_HWF1R_TXFIFOSIZE_INDEX	6
+#define MAC_HWF1R_TXFIFOSIZE_WIDTH	5
+#define MAC_HWF2R_AUXSNAPNUM_INDEX	28
+#define MAC_HWF2R_AUXSNAPNUM_WIDTH	3
+#define MAC_HWF2R_PPSOUTNUM_INDEX	24
+#define MAC_HWF2R_PPSOUTNUM_WIDTH	3
+#define MAC_HWF2R_RXCHCNT_INDEX		12
+#define MAC_HWF2R_RXCHCNT_WIDTH		4
+#define MAC_HWF2R_RXQCNT_INDEX		0
+#define MAC_HWF2R_RXQCNT_WIDTH		4
+#define MAC_HWF2R_TXCHCNT_INDEX		18
+#define MAC_HWF2R_TXCHCNT_WIDTH		4
+#define MAC_HWF2R_TXQCNT_INDEX		6
+#define MAC_HWF2R_TXQCNT_WIDTH		4
+#define MAC_ISR_MMCRXIS_INDEX		9
+#define MAC_ISR_MMCRXIS_WIDTH		1
+#define MAC_ISR_MMCTXIS_INDEX		10
+#define MAC_ISR_MMCTXIS_WIDTH		1
+#define MAC_ISR_PMTIS_INDEX		4
+#define MAC_ISR_PMTIS_WIDTH		1
+#define MAC_MACA1HR_AE_INDEX		31
+#define MAC_MACA1HR_AE_WIDTH		1
+#define MAC_PFR_HMC_INDEX		2
+#define MAC_PFR_HMC_WIDTH		1
+#define MAC_PFR_HUC_INDEX		1
+#define MAC_PFR_HUC_WIDTH		1
+#define MAC_PFR_PM_INDEX		4
+#define MAC_PFR_PM_WIDTH		1
+#define MAC_PFR_PR_INDEX		0
+#define MAC_PFR_PR_WIDTH		1
+#define MAC_PMTCSR_MGKPKTEN_INDEX	1
+#define MAC_PMTCSR_MGKPKTEN_WIDTH	1
+#define MAC_PMTCSR_PWRDWN_INDEX		0
+#define MAC_PMTCSR_PWRDWN_WIDTH		1
+#define MAC_PMTCSR_RWKFILTRST_INDEX	31
+#define MAC_PMTCSR_RWKFILTRST_WIDTH	1
+#define MAC_PMTCSR_RWKPKTEN_INDEX	2
+#define MAC_PMTCSR_RWKPKTEN_WIDTH	1
+#define MAC_Q0TFCR_PT_INDEX		16
+#define MAC_Q0TFCR_PT_WIDTH		16
+#define MAC_Q0TFCR_TFE_INDEX		1
+#define MAC_Q0TFCR_TFE_WIDTH		1
+#define MAC_RCR_ACS_INDEX		1
+#define MAC_RCR_ACS_WIDTH		1
+#define MAC_RCR_CST_INDEX		2
+#define MAC_RCR_CST_WIDTH		1
+#define MAC_RCR_DCRCC_INDEX		3
+#define MAC_RCR_DCRCC_WIDTH		1
+#define MAC_RCR_IPC_INDEX		9
+#define MAC_RCR_IPC_WIDTH		1
+#define MAC_RCR_JE_INDEX		8
+#define MAC_RCR_JE_WIDTH		1
+#define MAC_RCR_LM_INDEX		10
+#define MAC_RCR_LM_WIDTH		1
+#define MAC_RCR_RE_INDEX		0
+#define MAC_RCR_RE_WIDTH		1
+#define MAC_RFCR_RFE_INDEX		0
+#define MAC_RFCR_RFE_WIDTH		1
+#define MAC_RQC0R_RXQ0EN_INDEX		0
+#define MAC_RQC0R_RXQ0EN_WIDTH		2
+#define MAC_TCR_SS_INDEX		29
+#define MAC_TCR_SS_WIDTH		2
+#define MAC_TCR_TE_INDEX		0
+#define MAC_TCR_TE_WIDTH		1
+#define MAC_VLANTR_DOVLTC_INDEX		20
+#define MAC_VLANTR_DOVLTC_WIDTH		1
+#define MAC_VLANTR_ERSVLM_INDEX		19
+#define MAC_VLANTR_ERSVLM_WIDTH		1
+#define MAC_VLANTR_ESVL_INDEX		18
+#define MAC_VLANTR_ESVL_WIDTH		1
+#define MAC_VLANTR_EVLS_INDEX		21
+#define MAC_VLANTR_EVLS_WIDTH		2
+#define MAC_VLANTR_EVLRXS_INDEX		24
+#define MAC_VLANTR_EVLRXS_WIDTH		1
+#define MAC_VR_DEVID_INDEX		8
+#define MAC_VR_DEVID_WIDTH		8
+#define MAC_VR_SNPSVER_INDEX		0
+#define MAC_VR_SNPSVER_WIDTH		8
+#define MAC_VR_USERVER_INDEX		16
+#define MAC_VR_USERVER_WIDTH		8
+
+/* MMC register offsets */
+#define MMC_CR				0x0800
+#define MMC_RISR			0x0804
+#define MMC_TISR			0x0808
+#define MMC_RIER			0x080c
+#define MMC_TIER			0x0810
+#define MMC_TXOCTETCOUNT_GB_LO		0x0814
+#define MMC_TXOCTETCOUNT_GB_HI		0x0818
+#define MMC_TXFRAMECOUNT_GB_LO		0x081c
+#define MMC_TXFRAMECOUNT_GB_HI		0x0820
+#define MMC_TXBROADCASTFRAMES_G_LO	0x0824
+#define MMC_TXBROADCASTFRAMES_G_HI	0x0828
+#define MMC_TXMULTICASTFRAMES_G_LO	0x082c
+#define MMC_TXMULTICASTFRAMES_G_HI	0x0830
+#define MMC_TX64OCTETS_GB_LO		0x0834
+#define MMC_TX64OCTETS_GB_HI		0x0838
+#define MMC_TX65TO127OCTETS_GB_LO	0x083c
+#define MMC_TX65TO127OCTETS_GB_HI	0x0840
+#define MMC_TX128TO255OCTETS_GB_LO	0x0844
+#define MMC_TX128TO255OCTETS_GB_HI	0x0848
+#define MMC_TX256TO511OCTETS_GB_LO	0x084c
+#define MMC_TX256TO511OCTETS_GB_HI	0x0850
+#define MMC_TX512TO1023OCTETS_GB_LO	0x0854
+#define MMC_TX512TO1023OCTETS_GB_HI	0x0858
+#define MMC_TX1024TOMAXOCTETS_GB_LO	0x085c
+#define MMC_TX1024TOMAXOCTETS_GB_HI	0x0860
+#define MMC_TXUNICASTFRAMES_GB_LO	0x0864
+#define MMC_TXUNICASTFRAMES_GB_HI	0x0868
+#define MMC_TXMULTICASTFRAMES_GB_LO	0x086c
+#define MMC_TXMULTICASTFRAMES_GB_HI	0x0870
+#define MMC_TXBROADCASTFRAMES_GB_LO	0x0874
+#define MMC_TXBROADCASTFRAMES_GB_HI	0x0878
+#define MMC_TXUNDERFLOWERROR_LO		0x087c
+#define MMC_TXUNDERFLOWERROR_HI		0x0880
+#define MMC_TXOCTETCOUNT_G_LO		0x0884
+#define MMC_TXOCTETCOUNT_G_HI		0x0888
+#define MMC_TXFRAMECOUNT_G_LO		0x088c
+#define MMC_TXFRAMECOUNT_G_HI		0x0890
+#define MMC_TXPAUSEFRAMES_LO		0x0894
+#define MMC_TXPAUSEFRAMES_HI		0x0898
+#define MMC_TXVLANFRAMES_G_LO		0x089c
+#define MMC_TXVLANFRAMES_G_HI		0x08a0
+#define MMC_RXFRAMECOUNT_GB_LO		0x0900
+#define MMC_RXFRAMECOUNT_GB_HI		0x0904
+#define MMC_RXOCTETCOUNT_GB_LO		0x0908
+#define MMC_RXOCTETCOUNT_GB_HI		0x090c
+#define MMC_RXOCTETCOUNT_G_LO		0x0910
+#define MMC_RXOCTETCOUNT_G_HI		0x0914
+#define MMC_RXBROADCASTFRAMES_G_LO	0x0918
+#define MMC_RXBROADCASTFRAMES_G_HI	0x091c
+#define MMC_RXMULTICASTFRAMES_G_LO	0x0920
+#define MMC_RXMULTICASTFRAMES_G_HI	0x0924
+#define MMC_RXCRCERROR_LO		0x0928
+#define MMC_RXCRCERROR_HI		0x092c
+#define MMC_RXRUNTERROR			0x0930
+#define MMC_RXJABBERERROR		0x0934
+#define MMC_RXUNDERSIZE_G		0x0938
+#define MMC_RXOVERSIZE_G		0x093c
+#define MMC_RX64OCTETS_GB_LO		0x0940
+#define MMC_RX64OCTETS_GB_HI		0x0944
+#define MMC_RX65TO127OCTETS_GB_LO	0x0948
+#define MMC_RX65TO127OCTETS_GB_HI	0x094c
+#define MMC_RX128TO255OCTETS_GB_LO	0x0950
+#define MMC_RX128TO255OCTETS_GB_HI	0x0954
+#define MMC_RX256TO511OCTETS_GB_LO	0x0958
+#define MMC_RX256TO511OCTETS_GB_HI	0x095c
+#define MMC_RX512TO1023OCTETS_GB_LO	0x0960
+#define MMC_RX512TO1023OCTETS_GB_HI	0x0964
+#define MMC_RX1024TOMAXOCTETS_GB_LO	0x0968
+#define MMC_RX1024TOMAXOCTETS_GB_HI	0x096c
+#define MMC_RXUNICASTFRAMES_G_LO	0x0970
+#define MMC_RXUNICASTFRAMES_G_HI	0x0974
+#define MMC_RXLENGTHERROR_LO		0x0978
+#define MMC_RXLENGTHERROR_HI		0x097c
+#define MMC_RXOUTOFRANGETYPE_LO		0x0980
+#define MMC_RXOUTOFRANGETYPE_HI		0x0984
+#define MMC_RXPAUSEFRAMES_LO		0x0988
+#define MMC_RXPAUSEFRAMES_HI		0x098c
+#define MMC_RXFIFOOVERFLOW_LO		0x0990
+#define MMC_RXFIFOOVERFLOW_HI		0x0994
+#define MMC_RXVLANFRAMES_GB_LO		0x0998
+#define MMC_RXVLANFRAMES_GB_HI		0x099c
+#define MMC_RXWATCHDOGERROR		0x09a0
+
+/* MMC register entry bit positions and sizes */
+#define MMC_CR_CR_INDEX				0
+#define MMC_CR_CR_WIDTH				1
+#define MMC_CR_CSR_INDEX			1
+#define MMC_CR_CSR_WIDTH			1
+#define MMC_CR_ROR_INDEX			2
+#define MMC_CR_ROR_WIDTH			1
+#define MMC_CR_MCF_INDEX			3
+#define MMC_CR_MCF_WIDTH			1
+#define MMC_CR_MCT_INDEX			4
+#define MMC_CR_MCT_WIDTH			2
+#define MMC_RIER_ALL_INTERRUPTS_INDEX		0
+#define MMC_RIER_ALL_INTERRUPTS_WIDTH		23
+#define MMC_RISR_RXFRAMECOUNT_GB_INDEX		0
+#define MMC_RISR_RXFRAMECOUNT_GB_WIDTH		1
+#define MMC_RISR_RXOCTETCOUNT_GB_INDEX		1
+#define MMC_RISR_RXOCTETCOUNT_GB_WIDTH		1
+#define MMC_RISR_RXOCTETCOUNT_G_INDEX		2
+#define MMC_RISR_RXOCTETCOUNT_G_WIDTH		1
+#define MMC_RISR_RXBROADCASTFRAMES_G_INDEX	3
+#define MMC_RISR_RXBROADCASTFRAMES_G_WIDTH	1
+#define MMC_RISR_RXMULTICASTFRAMES_G_INDEX	4
+#define MMC_RISR_RXMULTICASTFRAMES_G_WIDTH	1
+#define MMC_RISR_RXCRCERROR_INDEX		5
+#define MMC_RISR_RXCRCERROR_WIDTH		1
+#define MMC_RISR_RXRUNTERROR_INDEX		6
+#define MMC_RISR_RXRUNTERROR_WIDTH		1
+#define MMC_RISR_RXJABBERERROR_INDEX		7
+#define MMC_RISR_RXJABBERERROR_WIDTH		1
+#define MMC_RISR_RXUNDERSIZE_G_INDEX		8
+#define MMC_RISR_RXUNDERSIZE_G_WIDTH		1
+#define MMC_RISR_RXOVERSIZE_G_INDEX		9
+#define MMC_RISR_RXOVERSIZE_G_WIDTH		1
+#define MMC_RISR_RX64OCTETS_GB_INDEX		10
+#define MMC_RISR_RX64OCTETS_GB_WIDTH		1
+#define MMC_RISR_RX65TO127OCTETS_GB_INDEX	11
+#define MMC_RISR_RX65TO127OCTETS_GB_WIDTH	1
+#define MMC_RISR_RX128TO255OCTETS_GB_INDEX	12
+#define MMC_RISR_RX128TO255OCTETS_GB_WIDTH	1
+#define MMC_RISR_RX256TO511OCTETS_GB_INDEX	13
+#define MMC_RISR_RX256TO511OCTETS_GB_WIDTH	1
+#define MMC_RISR_RX512TO1023OCTETS_GB_INDEX	14
+#define MMC_RISR_RX512TO1023OCTETS_GB_WIDTH	1
+#define MMC_RISR_RX1024TOMAXOCTETS_GB_INDEX	15
+#define MMC_RISR_RX1024TOMAXOCTETS_GB_WIDTH	1
+#define MMC_RISR_RXUNICASTFRAMES_G_INDEX	16
+#define MMC_RISR_RXUNICASTFRAMES_G_WIDTH	1
+#define MMC_RISR_RXLENGTHERROR_INDEX		17
+#define MMC_RISR_RXLENGTHERROR_WIDTH		1
+#define MMC_RISR_RXOUTOFRANGETYPE_INDEX		18
+#define MMC_RISR_RXOUTOFRANGETYPE_WIDTH		1
+#define MMC_RISR_RXPAUSEFRAMES_INDEX		19
+#define MMC_RISR_RXPAUSEFRAMES_WIDTH		1
+#define MMC_RISR_RXFIFOOVERFLOW_INDEX		20
+#define MMC_RISR_RXFIFOOVERFLOW_WIDTH		1
+#define MMC_RISR_RXVLANFRAMES_GB_INDEX		21
+#define MMC_RISR_RXVLANFRAMES_GB_WIDTH		1
+#define MMC_RISR_RXWATCHDOGERROR_INDEX		22
+#define MMC_RISR_RXWATCHDOGERROR_WIDTH		1
+#define MMC_TIER_ALL_INTERRUPTS_INDEX		0
+#define MMC_TIER_ALL_INTERRUPTS_WIDTH		18
+#define MMC_TISR_TXOCTETCOUNT_GB_INDEX		0
+#define MMC_TISR_TXOCTETCOUNT_GB_WIDTH		1
+#define MMC_TISR_TXFRAMECOUNT_GB_INDEX		1
+#define MMC_TISR_TXFRAMECOUNT_GB_WIDTH		1
+#define MMC_TISR_TXBROADCASTFRAMES_G_INDEX	2
+#define MMC_TISR_TXBROADCASTFRAMES_G_WIDTH	1
+#define MMC_TISR_TXMULTICASTFRAMES_G_INDEX	3
+#define MMC_TISR_TXMULTICASTFRAMES_G_WIDTH	1
+#define MMC_TISR_TX64OCTETS_GB_INDEX		4
+#define MMC_TISR_TX64OCTETS_GB_WIDTH		1
+#define MMC_TISR_TX65TO127OCTETS_GB_INDEX	5
+#define MMC_TISR_TX65TO127OCTETS_GB_WIDTH	1
+#define MMC_TISR_TX128TO255OCTETS_GB_INDEX	6
+#define MMC_TISR_TX128TO255OCTETS_GB_WIDTH	1
+#define MMC_TISR_TX256TO511OCTETS_GB_INDEX	7
+#define MMC_TISR_TX256TO511OCTETS_GB_WIDTH	1
+#define MMC_TISR_TX512TO1023OCTETS_GB_INDEX	8
+#define MMC_TISR_TX512TO1023OCTETS_GB_WIDTH	1
+#define MMC_TISR_TX1024TOMAXOCTETS_GB_INDEX	9
+#define MMC_TISR_TX1024TOMAXOCTETS_GB_WIDTH	1
+#define MMC_TISR_TXUNICASTFRAMES_GB_INDEX	10
+#define MMC_TISR_TXUNICASTFRAMES_GB_WIDTH	1
+#define MMC_TISR_TXMULTICASTFRAMES_GB_INDEX	11
+#define MMC_TISR_TXMULTICASTFRAMES_GB_WIDTH	1
+#define MMC_TISR_TXBROADCASTFRAMES_GB_INDEX	12
+#define MMC_TISR_TXBROADCASTFRAMES_GB_WIDTH	1
+#define MMC_TISR_TXUNDERFLOWERROR_INDEX		13
+#define MMC_TISR_TXUNDERFLOWERROR_WIDTH		1
+#define MMC_TISR_TXOCTETCOUNT_G_INDEX		14
+#define MMC_TISR_TXOCTETCOUNT_G_WIDTH		1
+#define MMC_TISR_TXFRAMECOUNT_G_INDEX		15
+#define MMC_TISR_TXFRAMECOUNT_G_WIDTH		1
+#define MMC_TISR_TXPAUSEFRAMES_INDEX		16
+#define MMC_TISR_TXPAUSEFRAMES_WIDTH		1
+#define MMC_TISR_TXVLANFRAMES_G_INDEX		17
+#define MMC_TISR_TXVLANFRAMES_G_WIDTH		1
+
+/* MTL register offsets */
+#define MTL_OMR				0x1000
+#define MTL_FDCR			0x1008
+#define MTL_FDSR			0x100c
+#define MTL_FDDR			0x1010
+#define MTL_ISR				0x1020
+#define MTL_RQDCM0R			0x1030
+#define MTL_TCPM0R			0x1040
+#define MTL_TCPM1R			0x1044
+
+#define MTL_RQDCM_INC			4
+#define MTL_RQDCM_Q_PER_REG		4
+
+/* MTL register entry bit positions and sizes */
+#define MTL_OMR_ETSALG_INDEX		5
+#define MTL_OMR_ETSALG_WIDTH		2
+#define MTL_OMR_RAA_INDEX		2
+#define MTL_OMR_RAA_WIDTH		1
+
+/* MTL queue register offsets
+ *   Multiple queues can be active.  The first queue has registers
+ *   that begin at 0x1100.  Each subsequent queue has registers that
+ *   are accessed using an offset of 0x80 from the previous queue.
+ */
+#define MTL_Q_BASE			0x1100
+#define MTL_Q_INC			0x80
+
+#define MTL_Q_TQOMR			0x00
+#define MTL_Q_TQUR			0x04
+#define MTL_Q_TQDR			0x08
+#define MTL_Q_TCECR			0x10
+#define MTL_Q_TCESR			0x14
+#define MTL_Q_TCQWR			0x18
+#define MTL_Q_RQOMR			0x40
+#define MTL_Q_RQMPOCR			0x44
+#define MTL_Q_RQDR			0x4c
+#define MTL_Q_IER			0x70
+#define MTL_Q_ISR			0x74
+
+/* MTL queue register entry bit positions and sizes */
+#define MTL_Q_TCQWR_QW_INDEX		0
+#define MTL_Q_TCQWR_QW_WIDTH		21
+#define MTL_Q_RQOMR_EHFC_INDEX		7
+#define MTL_Q_RQOMR_EHFC_WIDTH		1
+#define MTL_Q_RQOMR_RFA_INDEX		8
+#define MTL_Q_RQOMR_RFA_WIDTH		3
+#define MTL_Q_RQOMR_RFD_INDEX		13
+#define MTL_Q_RQOMR_RFD_WIDTH		3
+#define MTL_Q_RQOMR_RQS_INDEX		16
+#define MTL_Q_RQOMR_RQS_WIDTH		9
+#define MTL_Q_RQOMR_RSF_INDEX		5
+#define MTL_Q_RQOMR_RSF_WIDTH		1
+#define MTL_Q_RQOMR_RTC_INDEX		0
+#define MTL_Q_RQOMR_RTC_WIDTH		2
+#define MTL_Q_TQOMR_FTQ_INDEX		0
+#define MTL_Q_TQOMR_FTQ_WIDTH		1
+#define MTL_Q_TQOMR_TQS_INDEX		16
+#define MTL_Q_TQOMR_TQS_WIDTH		10
+#define MTL_Q_TQOMR_TSF_INDEX		1
+#define MTL_Q_TQOMR_TSF_WIDTH		1
+#define MTL_Q_TQOMR_TTC_INDEX		4
+#define MTL_Q_TQOMR_TTC_WIDTH		3
+#define MTL_Q_TQOMR_TXQEN_INDEX		2
+#define MTL_Q_TQOMR_TXQEN_WIDTH		2
+
+/* MTL queue register value */
+#define MTL_RSF_DISABLE			0x00
+#define MTL_RSF_ENABLE			0x01
+#define MTL_TSF_DISABLE			0x00
+#define MTL_TSF_ENABLE			0x01
+
+#define MTL_RX_THRESHOLD_64		0x00
+#define MTL_RX_THRESHOLD_96		0x02
+#define MTL_RX_THRESHOLD_128		0x03
+#define MTL_TX_THRESHOLD_32		0x01
+#define MTL_TX_THRESHOLD_64		0x00
+#define MTL_TX_THRESHOLD_96		0x02
+#define MTL_TX_THRESHOLD_128		0x03
+#define MTL_TX_THRESHOLD_192		0x04
+#define MTL_TX_THRESHOLD_256		0x05
+#define MTL_TX_THRESHOLD_384		0x06
+#define MTL_TX_THRESHOLD_512		0x07
+
+#define MTL_ETSALG_WRR			0x00
+#define MTL_ETSALG_WFQ			0x01
+#define MTL_ETSALG_DWRR			0x02
+#define MTL_RAA_SP			0x00
+#define MTL_RAA_WSP			0x01
+
+#define MTL_Q_DISABLED			0x00
+#define MTL_Q_ENABLED			0x02
+
+
+/* MTL traffic class register offsets
+ *   Multiple traffic classes can be active.  The first class has registers
+ *   that begin at 0x1100.  Each subsequent queue has registers that
+ *   are accessed using an offset of 0x80 from the previous queue.
+ */
+#define MTL_TC_BASE			MTL_Q_BASE
+#define MTL_TC_INC			MTL_Q_INC
+
+#define MTL_TC_ETSCR			0x10
+
+/* MTL traffic class register entry bit positions and sizes */
+#define MTL_TC_ETSCR_TSA_INDEX		0
+#define MTL_TC_ETSCR_TSA_WIDTH		2
+
+/* MTL traffic class register value */
+#define MTL_TSA_SP			0x00
+#define MTL_TSA_ETS			0x02
+
+
+/* PCS MMD select register offset
+ *  The MMD select register is used for accessing PCS registers
+ *  when the underlying APB3 interface is using indirect addressing.
+ *  Indirect addressing requires accessing registers in two phases,
+ *  an address phase and a data phase.  The address phases requires
+ *  writing an address selection value to the MMD select regiesters.
+ */
+#define PCS_MMD_SELECT			0xff
+
+
+/* Descriptor/Packet entry bit positions and sizes */
+#define RX_PACKET_ERRORS_CRC_INDEX		2
+#define RX_PACKET_ERRORS_CRC_WIDTH		1
+#define RX_PACKET_ERRORS_FRAME_INDEX		3
+#define RX_PACKET_ERRORS_FRAME_WIDTH		1
+#define RX_PACKET_ERRORS_LENGTH_INDEX		0
+#define RX_PACKET_ERRORS_LENGTH_WIDTH		1
+#define RX_PACKET_ERRORS_OVERRUN_INDEX		1
+#define RX_PACKET_ERRORS_OVERRUN_WIDTH		1
+
+#define RX_PACKET_ATTRIBUTES_CSUM_DONE_INDEX	0
+#define RX_PACKET_ATTRIBUTES_CSUM_DONE_WIDTH	1
+#define RX_PACKET_ATTRIBUTES_VLAN_CTAG_INDEX	1
+#define RX_PACKET_ATTRIBUTES_VLAN_CTAG_WIDTH	1
+#define RX_PACKET_ATTRIBUTES_INCOMPLETE_INDEX	2
+#define RX_PACKET_ATTRIBUTES_INCOMPLETE_WIDTH	1
+
+#define RX_NORMAL_DESC0_OVT_INDEX		0
+#define RX_NORMAL_DESC0_OVT_WIDTH		16
+#define RX_NORMAL_DESC3_ES_INDEX		15
+#define RX_NORMAL_DESC3_ES_WIDTH		1
+#define RX_NORMAL_DESC3_ETLT_INDEX		16
+#define RX_NORMAL_DESC3_ETLT_WIDTH		4
+#define RX_NORMAL_DESC3_INTE_INDEX		30
+#define RX_NORMAL_DESC3_INTE_WIDTH		1
+#define RX_NORMAL_DESC3_LD_INDEX		28
+#define RX_NORMAL_DESC3_LD_WIDTH		1
+#define RX_NORMAL_DESC3_OWN_INDEX		31
+#define RX_NORMAL_DESC3_OWN_WIDTH		1
+#define RX_NORMAL_DESC3_PL_INDEX		0
+#define RX_NORMAL_DESC3_PL_WIDTH		14
+
+#define TX_PACKET_ATTRIBUTES_CSUM_ENABLE_INDEX	0
+#define TX_PACKET_ATTRIBUTES_CSUM_ENABLE_WIDTH	1
+#define TX_PACKET_ATTRIBUTES_TSO_ENABLE_INDEX	1
+#define TX_PACKET_ATTRIBUTES_TSO_ENABLE_WIDTH	1
+#define TX_PACKET_ATTRIBUTES_VLAN_CTAG_INDEX	2
+#define TX_PACKET_ATTRIBUTES_VLAN_CTAG_WIDTH	1
+
+#define TX_CONTEXT_DESC2_MSS_INDEX		0
+#define TX_CONTEXT_DESC2_MSS_WIDTH		15
+#define TX_CONTEXT_DESC3_CTXT_INDEX		30
+#define TX_CONTEXT_DESC3_CTXT_WIDTH		1
+#define TX_CONTEXT_DESC3_TCMSSV_INDEX		26
+#define TX_CONTEXT_DESC3_TCMSSV_WIDTH		1
+#define TX_CONTEXT_DESC3_VLTV_INDEX		16
+#define TX_CONTEXT_DESC3_VLTV_WIDTH		1
+#define TX_CONTEXT_DESC3_VT_INDEX		0
+#define TX_CONTEXT_DESC3_VT_WIDTH		16
+
+#define TX_NORMAL_DESC2_HL_B1L_INDEX		0
+#define TX_NORMAL_DESC2_HL_B1L_WIDTH		14
+#define TX_NORMAL_DESC2_IC_INDEX		31
+#define TX_NORMAL_DESC2_IC_WIDTH		1
+#define TX_NORMAL_DESC2_VTIR_INDEX		14
+#define TX_NORMAL_DESC2_VTIR_WIDTH		2
+#define TX_NORMAL_DESC3_CIC_INDEX		16
+#define TX_NORMAL_DESC3_CIC_WIDTH		2
+#define TX_NORMAL_DESC3_CPC_INDEX		26
+#define TX_NORMAL_DESC3_CPC_WIDTH		2
+#define TX_NORMAL_DESC3_CTXT_INDEX		30
+#define TX_NORMAL_DESC3_CTXT_WIDTH		1
+#define TX_NORMAL_DESC3_FD_INDEX		29
+#define TX_NORMAL_DESC3_FD_WIDTH		1
+#define TX_NORMAL_DESC3_FL_INDEX		0
+#define TX_NORMAL_DESC3_FL_WIDTH		15
+#define TX_NORMAL_DESC3_LD_INDEX		28
+#define TX_NORMAL_DESC3_LD_WIDTH		1
+#define TX_NORMAL_DESC3_OWN_INDEX		31
+#define TX_NORMAL_DESC3_OWN_WIDTH		1
+#define TX_NORMAL_DESC3_TCPHDRLEN_INDEX		19
+#define TX_NORMAL_DESC3_TCPHDRLEN_WIDTH		4
+#define TX_NORMAL_DESC3_TCPPL_INDEX		0
+#define TX_NORMAL_DESC3_TCPPL_WIDTH		18
+#define TX_NORMAL_DESC3_TSE_INDEX		18
+#define TX_NORMAL_DESC3_TSE_WIDTH		1
+
+#define TX_NORMAL_DESC2_VLAN_INSERT		0x2
+
+/* MDIO undefined or vendor specific registers */
+#ifndef MDIO_AN_COMP_STAT
+#define MDIO_AN_COMP_STAT		0x0030
+#endif
+
+
+/* Bit setting and getting macros
+ *  The get macro will extract the current bit field value from within
+ *  the variable
+ *
+ *  The set macro will clear the current bit field value within the
+ *  variable and then set the bit field of the variable to the
+ *  specified value
+ */
+#define GET_BITS(_var, _index, _width)					\
+	(((_var) >> (_index)) & ((0x1 << (_width)) - 1))
+
+#define SET_BITS(_var, _index, _width, _val)				\
+do {									\
+	(_var) &= ~(((0x1 << (_width)) - 1) << (_index));		\
+	(_var) |= (((_val) & ((0x1 << (_width)) - 1)) << (_index));	\
+} while (0)
+
+#define GET_BITS_LE(_var, _index, _width)				\
+	((le32_to_cpu((_var)) >> (_index)) & ((0x1 << (_width)) - 1))
+
+#define SET_BITS_LE(_var, _index, _width, _val)				\
+do {									\
+	(_var) &= cpu_to_le32(~(((0x1 << (_width)) - 1) << (_index)));	\
+	(_var) |= cpu_to_le32((((_val) &				\
+			      ((0x1 << (_width)) - 1)) << (_index)));	\
+} while (0)
+
+
+/* Bit setting and getting macros based on register fields
+ *  The get macro uses the bit field definitions formed using the input
+ *  names to extract the current bit field value from within the
+ *  variable
+ *
+ *  The set macro uses the bit field definitions formed using the input
+ *  names to set the bit field of the variable to the specified value
+ */
+#define XGMAC_GET_BITS(_var, _prefix, _field)				\
+	GET_BITS((_var),						\
+		 _prefix##_##_field##_INDEX,				\
+		 _prefix##_##_field##_WIDTH)
+
+#define XGMAC_SET_BITS(_var, _prefix, _field, _val)			\
+	SET_BITS((_var),						\
+		 _prefix##_##_field##_INDEX,				\
+		 _prefix##_##_field##_WIDTH, (_val))
+
+#define XGMAC_GET_BITS_LE(_var, _prefix, _field)			\
+	GET_BITS_LE((_var),						\
+		 _prefix##_##_field##_INDEX,				\
+		 _prefix##_##_field##_WIDTH)
+
+#define XGMAC_SET_BITS_LE(_var, _prefix, _field, _val)			\
+	SET_BITS_LE((_var),						\
+		 _prefix##_##_field##_INDEX,				\
+		 _prefix##_##_field##_WIDTH, (_val))
+
+
+/* Macros for reading or writing registers
+ *  The ioread macros will get bit fields or full values using the
+ *  register definitions formed using the input names
+ *
+ *  The iowrite macros will set bit fields or full values using the
+ *  register definitions formed using the input names
+ */
+#define XGMAC_IOREAD(_pdata, _reg)					\
+	ioread32((_pdata)->xgmac_regs + _reg)
+
+#define XGMAC_IOREAD_BITS(_pdata, _reg, _field)				\
+	GET_BITS(XGMAC_IOREAD((_pdata), _reg),				\
+		 _reg##_##_field##_INDEX,				\
+		 _reg##_##_field##_WIDTH)
+
+#define XGMAC_IOWRITE(_pdata, _reg, _val)				\
+	iowrite32((_val), (_pdata)->xgmac_regs + _reg)
+
+#define XGMAC_IOWRITE_BITS(_pdata, _reg, _field, _val)			\
+do {									\
+	u32 reg_val = XGMAC_IOREAD((_pdata), _reg);			\
+	SET_BITS(reg_val,						\
+		 _reg##_##_field##_INDEX,				\
+		 _reg##_##_field##_WIDTH, (_val));			\
+	XGMAC_IOWRITE((_pdata), _reg, reg_val);				\
+} while (0)
+
+
+/* Macros for reading or writing MTL queue or traffic class registers
+ *  Similar to the standard read and write macros except that the
+ *  base register value is calculated by the queue or traffic class number
+ */
+#define XGMAC_MTL_IOREAD(_pdata, _n, _reg)				\
+	ioread32((_pdata)->xgmac_regs +					\
+		 MTL_Q_BASE + ((_n) * MTL_Q_INC) + _reg)
+
+#define XGMAC_MTL_IOREAD_BITS(_pdata, _n, _reg, _field)			\
+	GET_BITS(XGMAC_MTL_IOREAD((_pdata), (_n), _reg),		\
+		 _reg##_##_field##_INDEX,				\
+		 _reg##_##_field##_WIDTH)
+
+#define XGMAC_MTL_IOWRITE(_pdata, _n, _reg, _val)			\
+	iowrite32((_val), (_pdata)->xgmac_regs +			\
+		  MTL_Q_BASE + ((_n) * MTL_Q_INC) + _reg)
+
+#define XGMAC_MTL_IOWRITE_BITS(_pdata, _n, _reg, _field, _val)		\
+do {									\
+	u32 reg_val = XGMAC_MTL_IOREAD((_pdata), (_n), _reg);		\
+	SET_BITS(reg_val,						\
+		 _reg##_##_field##_INDEX,				\
+		 _reg##_##_field##_WIDTH, (_val));			\
+	XGMAC_MTL_IOWRITE((_pdata), (_n), _reg, reg_val);		\
+} while (0)
+
+
+/* Macros for reading or writing DMA channel registers
+ *  Similar to the standard read and write macros except that the
+ *  base register value is obtained from the ring
+ */
+#define XGMAC_DMA_IOREAD(_channel, _reg)				\
+	ioread32((_channel)->dma_regs + _reg)
+
+#define XGMAC_DMA_IOREAD_BITS(_channel, _reg, _field)			\
+	GET_BITS(XGMAC_DMA_IOREAD((_channel), _reg),			\
+		 _reg##_##_field##_INDEX,				\
+		 _reg##_##_field##_WIDTH)
+
+#define XGMAC_DMA_IOWRITE(_channel, _reg, _val)				\
+	iowrite32((_val), (_channel)->dma_regs + _reg)
+
+#define XGMAC_DMA_IOWRITE_BITS(_channel, _reg, _field, _val)		\
+do {									\
+	u32 reg_val = XGMAC_DMA_IOREAD((_channel), _reg);		\
+	SET_BITS(reg_val,						\
+		 _reg##_##_field##_INDEX,				\
+		 _reg##_##_field##_WIDTH, (_val));			\
+	XGMAC_DMA_IOWRITE((_channel), _reg, reg_val);			\
+} while (0)
+
+
+/* Macros for building, reading or writing register values or bits
+ * within the register values of XPCS registers.
+ */
+#define XPCS_IOWRITE(_pdata, _off, _val)				\
+	iowrite32(_val, (_pdata)->xpcs_regs + (_off))
+
+#define XPCS_IOREAD(_pdata, _off)					\
+	ioread32((_pdata)->xpcs_regs + (_off))
+
+
+/* Macros for building, reading or writing register values or bits
+ * using MDIO.  Different from above because of the use of standardized
+ * Linux include values.  No shifting is performed with the bit
+ * operations, everything works on mask values.
+ */
+#define XMDIO_READ(_pdata, _mmd, _reg)					\
+	((_pdata)->hw_if.read_mmd_regs((_pdata), 0,			\
+		MII_ADDR_C45 | (_mmd << 16) | ((_reg) & 0xffff)))
+
+#define XMDIO_READ_BITS(_pdata, _mmd, _reg, _mask)			\
+	(XMDIO_READ((_pdata), _mmd, _reg) & _mask)
+
+#define XMDIO_WRITE(_pdata, _mmd, _reg, _val)				\
+	((_pdata)->hw_if.write_mmd_regs((_pdata), 0,			\
+		MII_ADDR_C45 | (_mmd << 16) | ((_reg) & 0xffff), (_val)))
+
+#define XMDIO_WRITE_BITS(_pdata, _mmd, _reg, _mask, _val)		\
+do {									\
+	u32 mmd_val = XMDIO_READ((_pdata), _mmd, _reg);			\
+	mmd_val &= ~_mask;						\
+	mmd_val |= (_val);						\
+	XMDIO_WRITE((_pdata), _mmd, _reg, mmd_val);			\
+} while (0)
+
+#endif
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c b/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
new file mode 100644
index 0000000..6bb76d5
--- /dev/null
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
@@ -0,0 +1,375 @@
+/*
+ * AMD 10Gb Ethernet driver
+ *
+ * This file is available to you under your choice of the following two
+ * licenses:
+ *
+ * License 1: GPLv2
+ *
+ * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ *
+ * This file is free software; you may copy, redistribute and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation, either version 2 of the License, or (at
+ * your option) any later version.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ *
+ * This file incorporates work covered by the following copyright and
+ * permission notice:
+ *     The Synopsys DWC ETHER XGMAC Software Driver and documentation
+ *     (hereinafter "Software") is an unsupported proprietary work of Synopsys,
+ *     Inc. unless otherwise expressly agreed to in writing between Synopsys
+ *     and you.
+ *
+ *     The Software IS NOT an item of Licensed Software or Licensed Product
+ *     under any End User Software License Agreement or Agreement for Licensed
+ *     Product with Synopsys or any supplement thereto.  Permission is hereby
+ *     granted, free of charge, to any person obtaining a copy of this software
+ *     annotated with this license and the Software, to deal in the Software
+ *     without restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or sell copies
+ *     of the Software, and to permit persons to whom the Software is furnished
+ *     to do so, subject to the following conditions:
+ *
+ *     The above copyright notice and this permission notice shall be included
+ *     in all copies or substantial portions of the Software.
+ *
+ *     THIS SOFTWARE IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN "AS IS"
+ *     BASIS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
+ *     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+ *     PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS
+ *     BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ *     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
+ *     THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ *
+ * License 2: Modified BSD
+ *
+ * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ * All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Advanced Micro Devices, Inc. nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
+ * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ * This file incorporates work covered by the following copyright and
+ * permission notice:
+ *     The Synopsys DWC ETHER XGMAC Software Driver and documentation
+ *     (hereinafter "Software") is an unsupported proprietary work of Synopsys,
+ *     Inc. unless otherwise expressly agreed to in writing between Synopsys
+ *     and you.
+ *
+ *     The Software IS NOT an item of Licensed Software or Licensed Product
+ *     under any End User Software License Agreement or Agreement for Licensed
+ *     Product with Synopsys or any supplement thereto.  Permission is hereby
+ *     granted, free of charge, to any person obtaining a copy of this software
+ *     annotated with this license and the Software, to deal in the Software
+ *     without restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or sell copies
+ *     of the Software, and to permit persons to whom the Software is furnished
+ *     to do so, subject to the following conditions:
+ *
+ *     The above copyright notice and this permission notice shall be included
+ *     in all copies or substantial portions of the Software.
+ *
+ *     THIS SOFTWARE IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN "AS IS"
+ *     BASIS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
+ *     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+ *     PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS
+ *     BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ *     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
+ *     THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <linux/debugfs.h>
+#include <linux/module.h>
+#include <linux/slab.h>
+
+#include "xgbe.h"
+#include "xgbe-common.h"
+
+
+static ssize_t xgbe_common_read(char __user *buffer, size_t count,
+				loff_t *ppos, unsigned int value)
+{
+	char *buf;
+	ssize_t len;
+
+	if (*ppos != 0)
+		return 0;
+
+	buf = kasprintf(GFP_KERNEL, "0x%08x\n", value);
+	if (!buf)
+		return -ENOMEM;
+
+	if (count < strlen(buf)) {
+		kfree(buf);
+		return -ENOSPC;
+	}
+
+	len = simple_read_from_buffer(buffer, count, ppos, buf, strlen(buf));
+	kfree(buf);
+
+	return len;
+}
+
+static ssize_t xgbe_common_write(const char __user *buffer, size_t count,
+				 loff_t *ppos, unsigned int *value)
+{
+	char workarea[32];
+	ssize_t len;
+	unsigned int scan_value;
+
+	if (*ppos != 0)
+		return 0;
+
+	if (count >= sizeof(workarea))
+		return -ENOSPC;
+
+	len = simple_write_to_buffer(workarea, sizeof(workarea) - 1, ppos,
+				     buffer, count);
+	if (len < 0)
+		return len;
+
+	workarea[len] = '\0';
+	if (sscanf(workarea, "%x", &scan_value) == 1)
+		*value = scan_value;
+	else
+		return -EIO;
+
+	return len;
+}
+
+static ssize_t xgmac_reg_addr_read(struct file *filp, char __user *buffer,
+				   size_t count, loff_t *ppos)
+{
+	struct xgbe_prv_data *pdata = filp->private_data;
+
+	return xgbe_common_read(buffer, count, ppos, pdata->debugfs_xgmac_reg);
+}
+
+static ssize_t xgmac_reg_addr_write(struct file *filp,
+				    const char __user *buffer,
+				    size_t count, loff_t *ppos)
+{
+	struct xgbe_prv_data *pdata = filp->private_data;
+
+	return xgbe_common_write(buffer, count, ppos,
+				 &pdata->debugfs_xgmac_reg);
+}
+
+static ssize_t xgmac_reg_value_read(struct file *filp, char __user *buffer,
+				    size_t count, loff_t *ppos)
+{
+	struct xgbe_prv_data *pdata = filp->private_data;
+	unsigned int value;
+
+	value = XGMAC_IOREAD(pdata, pdata->debugfs_xgmac_reg);
+
+	return xgbe_common_read(buffer, count, ppos, value);
+}
+
+static ssize_t xgmac_reg_value_write(struct file *filp,
+				     const char __user *buffer,
+				     size_t count, loff_t *ppos)
+{
+	struct xgbe_prv_data *pdata = filp->private_data;
+	unsigned int value;
+	ssize_t len;
+
+	len = xgbe_common_write(buffer, count, ppos, &value);
+	if (len < 0)
+		return len;
+
+	XGMAC_IOWRITE(pdata, pdata->debugfs_xgmac_reg, value);
+
+	return len;
+}
+
+static const struct file_operations xgmac_reg_addr_fops = {
+	.owner = THIS_MODULE,
+	.open = simple_open,
+	.read =  xgmac_reg_addr_read,
+	.write = xgmac_reg_addr_write,
+};
+
+static const struct file_operations xgmac_reg_value_fops = {
+	.owner = THIS_MODULE,
+	.open = simple_open,
+	.read =  xgmac_reg_value_read,
+	.write = xgmac_reg_value_write,
+};
+
+static ssize_t xpcs_mmd_read(struct file *filp, char __user *buffer,
+			     size_t count, loff_t *ppos)
+{
+	struct xgbe_prv_data *pdata = filp->private_data;
+
+	return xgbe_common_read(buffer, count, ppos, pdata->debugfs_xpcs_mmd);
+}
+
+static ssize_t xpcs_mmd_write(struct file *filp, const char __user *buffer,
+			      size_t count, loff_t *ppos)
+{
+	struct xgbe_prv_data *pdata = filp->private_data;
+
+	return xgbe_common_write(buffer, count, ppos,
+				 &pdata->debugfs_xpcs_mmd);
+}
+
+static ssize_t xpcs_reg_addr_read(struct file *filp, char __user *buffer,
+				  size_t count, loff_t *ppos)
+{
+	struct xgbe_prv_data *pdata = filp->private_data;
+
+	return xgbe_common_read(buffer, count, ppos, pdata->debugfs_xpcs_reg);
+}
+
+static ssize_t xpcs_reg_addr_write(struct file *filp, const char __user *buffer,
+				   size_t count, loff_t *ppos)
+{
+	struct xgbe_prv_data *pdata = filp->private_data;
+
+	return xgbe_common_write(buffer, count, ppos,
+				 &pdata->debugfs_xpcs_reg);
+}
+
+static ssize_t xpcs_reg_value_read(struct file *filp, char __user *buffer,
+				   size_t count, loff_t *ppos)
+{
+	struct xgbe_prv_data *pdata = filp->private_data;
+	unsigned int value;
+
+	value = pdata->hw_if.read_mmd_regs(pdata, pdata->debugfs_xpcs_mmd,
+					   pdata->debugfs_xpcs_reg);
+
+	return xgbe_common_read(buffer, count, ppos, value);
+}
+
+static ssize_t xpcs_reg_value_write(struct file *filp,
+				    const char __user *buffer,
+				    size_t count, loff_t *ppos)
+{
+	struct xgbe_prv_data *pdata = filp->private_data;
+	unsigned int value;
+	ssize_t len;
+
+	len = xgbe_common_write(buffer, count, ppos, &value);
+	if (len < 0)
+		return len;
+
+	pdata->hw_if.write_mmd_regs(pdata, pdata->debugfs_xpcs_mmd,
+				    pdata->debugfs_xpcs_reg, value);
+
+	return len;
+}
+
+static const struct file_operations xpcs_mmd_fops = {
+	.owner = THIS_MODULE,
+	.open = simple_open,
+	.read =  xpcs_mmd_read,
+	.write = xpcs_mmd_write,
+};
+
+static const struct file_operations xpcs_reg_addr_fops = {
+	.owner = THIS_MODULE,
+	.open = simple_open,
+	.read =  xpcs_reg_addr_read,
+	.write = xpcs_reg_addr_write,
+};
+
+static const struct file_operations xpcs_reg_value_fops = {
+	.owner = THIS_MODULE,
+	.open = simple_open,
+	.read =  xpcs_reg_value_read,
+	.write = xpcs_reg_value_write,
+};
+
+void xgbe_debugfs_init(struct xgbe_prv_data *pdata)
+{
+	struct dentry *pfile;
+	char *buf;
+
+	/* Set defaults */
+	pdata->debugfs_xgmac_reg = 0;
+	pdata->debugfs_xpcs_mmd = 1;
+	pdata->debugfs_xpcs_reg = 0;
+
+	buf = kasprintf(GFP_KERNEL, "amd-xgbe-%s", pdata->netdev->name);
+	pdata->xgbe_debugfs = debugfs_create_dir(buf, NULL);
+	if (pdata->xgbe_debugfs == NULL) {
+		netdev_err(pdata->netdev, "debugfs_create_dir failed\n");
+		return;
+	}
+
+	pfile = debugfs_create_file("xgmac_register", 0600,
+				    pdata->xgbe_debugfs, pdata,
+				    &xgmac_reg_addr_fops);
+	if (!pfile)
+		netdev_err(pdata->netdev, "debugfs_create_file failed\n");
+
+	pfile = debugfs_create_file("xgmac_register_value", 0600,
+				    pdata->xgbe_debugfs, pdata,
+				    &xgmac_reg_value_fops);
+	if (!pfile)
+		netdev_err(pdata->netdev, "debugfs_create_file failed\n");
+
+	pfile = debugfs_create_file("xpcs_mmd", 0600,
+				    pdata->xgbe_debugfs, pdata,
+				    &xpcs_mmd_fops);
+	if (!pfile)
+		netdev_err(pdata->netdev, "debugfs_create_file failed\n");
+
+	pfile = debugfs_create_file("xpcs_register", 0600,
+				    pdata->xgbe_debugfs, pdata,
+				    &xpcs_reg_addr_fops);
+	if (!pfile)
+		netdev_err(pdata->netdev, "debugfs_create_file failed\n");
+
+	pfile = debugfs_create_file("xpcs_register_value", 0600,
+				    pdata->xgbe_debugfs, pdata,
+				    &xpcs_reg_value_fops);
+	if (!pfile)
+		netdev_err(pdata->netdev, "debugfs_create_file failed\n");
+
+	kfree(buf);
+}
+
+void xgbe_debugfs_exit(struct xgbe_prv_data *pdata)
+{
+	debugfs_remove_recursive(pdata->xgbe_debugfs);
+	pdata->xgbe_debugfs = NULL;
+}
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
new file mode 100644
index 0000000..6f1c859
--- /dev/null
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
@@ -0,0 +1,556 @@
+/*
+ * AMD 10Gb Ethernet driver
+ *
+ * This file is available to you under your choice of the following two
+ * licenses:
+ *
+ * License 1: GPLv2
+ *
+ * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ *
+ * This file is free software; you may copy, redistribute and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation, either version 2 of the License, or (at
+ * your option) any later version.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ *
+ * This file incorporates work covered by the following copyright and
+ * permission notice:
+ *     The Synopsys DWC ETHER XGMAC Software Driver and documentation
+ *     (hereinafter "Software") is an unsupported proprietary work of Synopsys,
+ *     Inc. unless otherwise expressly agreed to in writing between Synopsys
+ *     and you.
+ *
+ *     The Software IS NOT an item of Licensed Software or Licensed Product
+ *     under any End User Software License Agreement or Agreement for Licensed
+ *     Product with Synopsys or any supplement thereto.  Permission is hereby
+ *     granted, free of charge, to any person obtaining a copy of this software
+ *     annotated with this license and the Software, to deal in the Software
+ *     without restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or sell copies
+ *     of the Software, and to permit persons to whom the Software is furnished
+ *     to do so, subject to the following conditions:
+ *
+ *     The above copyright notice and this permission notice shall be included
+ *     in all copies or substantial portions of the Software.
+ *
+ *     THIS SOFTWARE IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN "AS IS"
+ *     BASIS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
+ *     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+ *     PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS
+ *     BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ *     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
+ *     THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ *
+ * License 2: Modified BSD
+ *
+ * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ * All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Advanced Micro Devices, Inc. nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
+ * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ * This file incorporates work covered by the following copyright and
+ * permission notice:
+ *     The Synopsys DWC ETHER XGMAC Software Driver and documentation
+ *     (hereinafter "Software") is an unsupported proprietary work of Synopsys,
+ *     Inc. unless otherwise expressly agreed to in writing between Synopsys
+ *     and you.
+ *
+ *     The Software IS NOT an item of Licensed Software or Licensed Product
+ *     under any End User Software License Agreement or Agreement for Licensed
+ *     Product with Synopsys or any supplement thereto.  Permission is hereby
+ *     granted, free of charge, to any person obtaining a copy of this software
+ *     annotated with this license and the Software, to deal in the Software
+ *     without restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or sell copies
+ *     of the Software, and to permit persons to whom the Software is furnished
+ *     to do so, subject to the following conditions:
+ *
+ *     The above copyright notice and this permission notice shall be included
+ *     in all copies or substantial portions of the Software.
+ *
+ *     THIS SOFTWARE IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN "AS IS"
+ *     BASIS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
+ *     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+ *     PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS
+ *     BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ *     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
+ *     THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include "xgbe.h"
+#include "xgbe-common.h"
+
+
+static void xgbe_unmap_skb(struct xgbe_prv_data *, struct xgbe_ring_data *);
+
+static void xgbe_free_ring(struct xgbe_prv_data *pdata,
+			   struct xgbe_ring *ring)
+{
+	struct xgbe_ring_data *rdata;
+	unsigned int i;
+
+	if (!ring)
+		return;
+
+	if (ring->rdata) {
+		for (i = 0; i < ring->rdesc_count; i++) {
+			rdata = GET_DESC_DATA(ring, i);
+			xgbe_unmap_skb(pdata, rdata);
+		}
+
+		kfree(ring->rdata);
+		ring->rdata = NULL;
+	}
+
+	if (ring->rdesc) {
+		dma_free_coherent(pdata->dev,
+				  (sizeof(struct xgbe_ring_desc) *
+				   ring->rdesc_count),
+				  ring->rdesc, ring->rdesc_dma);
+		ring->rdesc = NULL;
+	}
+}
+
+static void xgbe_free_ring_resources(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_channel *channel;
+	unsigned int i;
+
+	DBGPR("-->xgbe_free_ring_resources\n");
+
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		xgbe_free_ring(pdata, channel->tx_ring);
+		xgbe_free_ring(pdata, channel->rx_ring);
+	}
+
+	DBGPR("<--xgbe_free_ring_resources\n");
+}
+
+static int xgbe_init_ring(struct xgbe_prv_data *pdata,
+			  struct xgbe_ring *ring, unsigned int rdesc_count)
+{
+	DBGPR("-->xgbe_init_ring\n");
+
+	if (!ring)
+		return 0;
+
+	/* Descriptors */
+	ring->rdesc_count = rdesc_count;
+	ring->rdesc = dma_alloc_coherent(pdata->dev,
+					 (sizeof(struct xgbe_ring_desc) *
+					  rdesc_count), &ring->rdesc_dma,
+					 GFP_KERNEL);
+	if (!ring->rdesc)
+		return -ENOMEM;
+
+	/* Descriptor information */
+	ring->rdata = kcalloc(rdesc_count, sizeof(struct xgbe_ring_data),
+			      GFP_KERNEL);
+	if (!ring->rdata)
+		return -ENOMEM;
+
+	DBGPR("    rdesc=0x%p, rdesc_dma=0x%llx, rdata=0x%p\n",
+	      ring->rdesc, ring->rdesc_dma, ring->rdata);
+
+	DBGPR("<--xgbe_init_ring\n");
+
+	return 0;
+}
+
+static int xgbe_alloc_ring_resources(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_channel *channel;
+	unsigned int i;
+	int ret;
+
+	DBGPR("-->xgbe_alloc_ring_resources\n");
+
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		DBGPR("  %s - tx_ring:\n", channel->name);
+		ret = xgbe_init_ring(pdata, channel->tx_ring,
+				     pdata->tx_desc_count);
+		if (ret) {
+			netdev_alert(pdata->netdev,
+				     "error initializing Tx ring\n");
+			goto err_ring;
+		}
+
+		DBGPR("  %s - rx_ring:\n", channel->name);
+		ret = xgbe_init_ring(pdata, channel->rx_ring,
+				     pdata->rx_desc_count);
+		if (ret) {
+			netdev_alert(pdata->netdev,
+				     "error initializing Tx ring\n");
+			goto err_ring;
+		}
+	}
+
+	DBGPR("<--xgbe_alloc_ring_resources\n");
+
+	return 0;
+
+err_ring:
+	xgbe_free_ring_resources(pdata);
+
+	return ret;
+}
+
+static void xgbe_wrapper_tx_descriptor_init(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_hw_if *hw_if = &pdata->hw_if;
+	struct xgbe_channel *channel;
+	struct xgbe_ring *ring;
+	struct xgbe_ring_data *rdata;
+	struct xgbe_ring_desc *rdesc;
+	dma_addr_t rdesc_dma;
+	unsigned int i, j;
+
+	DBGPR("-->xgbe_wrapper_tx_descriptor_init\n");
+
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		ring = channel->tx_ring;
+		if (!ring)
+			break;
+
+		rdesc = ring->rdesc;
+		rdesc_dma = ring->rdesc_dma;
+
+		for (j = 0; j < ring->rdesc_count; j++) {
+			rdata = GET_DESC_DATA(ring, j);
+
+			rdata->rdesc = rdesc;
+			rdata->rdesc_dma = rdesc_dma;
+
+			rdesc++;
+			rdesc_dma += sizeof(struct xgbe_ring_desc);
+		}
+
+		ring->cur = 0;
+		ring->dirty = 0;
+		ring->tx.queue_stopped = 0;
+
+		hw_if->tx_desc_init(channel);
+	}
+
+	DBGPR("<--xgbe_wrapper_tx_descriptor_init\n");
+}
+
+static void xgbe_wrapper_rx_descriptor_init(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_hw_if *hw_if = &pdata->hw_if;
+	struct xgbe_channel *channel;
+	struct xgbe_ring *ring;
+	struct xgbe_ring_desc *rdesc;
+	struct xgbe_ring_data *rdata;
+	dma_addr_t rdesc_dma, skb_dma;
+	struct sk_buff *skb = NULL;
+	unsigned int i, j;
+
+	DBGPR("-->xgbe_wrapper_rx_descriptor_init\n");
+
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		ring = channel->rx_ring;
+		if (!ring)
+			break;
+
+		rdesc = ring->rdesc;
+		rdesc_dma = ring->rdesc_dma;
+
+		for (j = 0; j < ring->rdesc_count; j++) {
+			rdata = GET_DESC_DATA(ring, j);
+
+			rdata->rdesc = rdesc;
+			rdata->rdesc_dma = rdesc_dma;
+
+			/* Allocate skb & assign to each rdesc */
+			skb = dev_alloc_skb(pdata->rx_buf_size);
+			if (skb == NULL)
+				break;
+			skb_dma = dma_map_single(pdata->dev, skb->data,
+						 pdata->rx_buf_size,
+						 DMA_FROM_DEVICE);
+			if (dma_mapping_error(pdata->dev, skb_dma)) {
+				netdev_alert(pdata->netdev,
+					     "failed to do the dma map\n");
+				dev_kfree_skb_any(skb);
+				break;
+			}
+			rdata->skb = skb;
+			rdata->skb_dma = skb_dma;
+			rdata->skb_dma_len = pdata->rx_buf_size;
+
+			rdesc++;
+			rdesc_dma += sizeof(struct xgbe_ring_desc);
+		}
+
+		ring->cur = 0;
+		ring->dirty = 0;
+		ring->rx.realloc_index = 0;
+		ring->rx.realloc_threshold = 0;
+
+		hw_if->rx_desc_init(channel);
+	}
+
+	DBGPR("<--xgbe_wrapper_rx_descriptor_init\n");
+}
+
+static void xgbe_unmap_skb(struct xgbe_prv_data *pdata,
+			   struct xgbe_ring_data *rdata)
+{
+	if (rdata->skb_dma) {
+		if (rdata->mapped_as_page) {
+			dma_unmap_page(pdata->dev, rdata->skb_dma,
+				       rdata->skb_dma_len, DMA_TO_DEVICE);
+		} else {
+			dma_unmap_single(pdata->dev, rdata->skb_dma,
+					 rdata->skb_dma_len, DMA_TO_DEVICE);
+		}
+		rdata->skb_dma = 0;
+		rdata->skb_dma_len = 0;
+	}
+
+	if (rdata->skb) {
+		dev_kfree_skb_any(rdata->skb);
+		rdata->skb = NULL;
+	}
+
+	rdata->tso_header = 0;
+	rdata->len = 0;
+	rdata->interrupt = 0;
+	rdata->mapped_as_page = 0;
+}
+
+static int xgbe_map_tx_skb(struct xgbe_channel *channel, struct sk_buff *skb)
+{
+	struct xgbe_prv_data *pdata = channel->pdata;
+	struct xgbe_ring *ring = channel->tx_ring;
+	struct xgbe_ring_data *rdata;
+	struct xgbe_packet_data *packet;
+	struct skb_frag_struct *frag;
+	dma_addr_t skb_dma;
+	unsigned int start_index, cur_index;
+	unsigned int offset, tso, vlan, datalen, len;
+	unsigned int i;
+
+	DBGPR("-->xgbe_map_tx_skb: cur = %d\n", ring->cur);
+
+	offset = 0;
+	start_index = ring->cur;
+	cur_index = ring->cur;
+
+	packet = &ring->packet_data;
+	packet->rdesc_count = 0;
+	packet->length = 0;
+
+	tso = XGMAC_GET_BITS(packet->attributes, TX_PACKET_ATTRIBUTES,
+			     TSO_ENABLE);
+	vlan = XGMAC_GET_BITS(packet->attributes, TX_PACKET_ATTRIBUTES,
+			      VLAN_CTAG);
+
+	/* Save space for a context descriptor if needed */
+	if ((tso && (packet->mss != ring->tx.cur_mss)) ||
+	    (vlan && (packet->vlan_ctag != ring->tx.cur_vlan_ctag)))
+		cur_index++;
+	rdata = GET_DESC_DATA(ring, cur_index);
+
+	if (tso) {
+		DBGPR("  TSO packet\n");
+
+		/* Map the TSO header */
+		skb_dma = dma_map_single(pdata->dev, skb->data,
+					 packet->header_len, DMA_TO_DEVICE);
+		if (dma_mapping_error(pdata->dev, skb_dma)) {
+			netdev_alert(pdata->netdev, "dma_map_single failed\n");
+			goto err_out;
+		}
+		rdata->skb_dma = skb_dma;
+		rdata->skb_dma_len = packet->header_len;
+		rdata->tso_header = 1;
+
+		offset = packet->header_len;
+
+		packet->length += packet->header_len;
+
+		cur_index++;
+		rdata = GET_DESC_DATA(ring, cur_index);
+	}
+
+	/* Map the (remainder of the) packet */
+	for (datalen = skb_headlen(skb) - offset; datalen; ) {
+		len = min_t(unsigned int, datalen, TX_MAX_BUF_SIZE);
+
+		skb_dma = dma_map_single(pdata->dev, skb->data + offset, len,
+					 DMA_TO_DEVICE);
+		if (dma_mapping_error(pdata->dev, skb_dma)) {
+			netdev_alert(pdata->netdev, "dma_map_single failed\n");
+			goto err_out;
+		}
+		rdata->skb_dma = skb_dma;
+		rdata->skb_dma_len = len;
+		DBGPR("  skb data: index=%u, dma=0x%llx, len=%u\n",
+		      cur_index, skb_dma, len);
+
+		datalen -= len;
+		offset += len;
+
+		packet->length += len;
+
+		cur_index++;
+		rdata = GET_DESC_DATA(ring, cur_index);
+	}
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		DBGPR("  mapping frag %u\n", i);
+
+		frag = &skb_shinfo(skb)->frags[i];
+		offset = 0;
+
+		for (datalen = skb_frag_size(frag); datalen; ) {
+			len = min_t(unsigned int, datalen, TX_MAX_BUF_SIZE);
+
+			skb_dma = skb_frag_dma_map(pdata->dev, frag, offset,
+						   len, DMA_TO_DEVICE);
+			if (dma_mapping_error(pdata->dev, skb_dma)) {
+				netdev_alert(pdata->netdev,
+					     "skb_frag_dma_map failed\n");
+				goto err_out;
+			}
+			rdata->skb_dma = skb_dma;
+			rdata->skb_dma_len = len;
+			rdata->mapped_as_page = 1;
+			DBGPR("  skb data: index=%u, dma=0x%llx, len=%u\n",
+			      cur_index, skb_dma, len);
+
+			datalen -= len;
+			offset += len;
+
+			packet->length += len;
+
+			cur_index++;
+			rdata = GET_DESC_DATA(ring, cur_index);
+		}
+	}
+
+	/* Save the skb address in the last entry */
+	rdata->skb = skb;
+
+	/* Save the number of descriptor entries used */
+	packet->rdesc_count = cur_index - start_index;
+
+	DBGPR("<--xgbe_map_tx_skb: count=%u\n", packet->rdesc_count);
+
+	return packet->rdesc_count;
+
+err_out:
+	while (start_index < cur_index) {
+		rdata = GET_DESC_DATA(ring, start_index++);
+		xgbe_unmap_skb(pdata, rdata);
+	}
+
+	DBGPR("<--xgbe_map_tx_skb: count=0\n");
+
+	return 0;
+}
+
+static void xgbe_realloc_skb(struct xgbe_channel *channel)
+{
+	struct xgbe_prv_data *pdata = channel->pdata;
+	struct xgbe_hw_if *hw_if = &pdata->hw_if;
+	struct xgbe_ring *ring = channel->rx_ring;
+	struct xgbe_ring_data *rdata;
+	struct sk_buff *skb = NULL;
+	dma_addr_t skb_dma;
+	int i;
+
+	DBGPR("-->xgbe_realloc_skb: rx_ring->rx.realloc_index = %u\n",
+	      ring->rx.realloc_index);
+
+	for (i = 0; i < ring->dirty; i++) {
+		rdata = GET_DESC_DATA(ring, ring->rx.realloc_index);
+
+		/* Reset rdata values */
+		xgbe_unmap_skb(pdata, rdata);
+
+		/* Allocate skb & assign to each rdesc */
+		skb = dev_alloc_skb(pdata->rx_buf_size);
+		if (skb == NULL) {
+			netdev_alert(pdata->netdev,
+				     "failed to allocate skb\n");
+			break;
+		}
+		skb_dma = dma_map_single(pdata->dev, skb->data,
+					 pdata->rx_buf_size, DMA_FROM_DEVICE);
+		if (dma_mapping_error(pdata->dev, skb_dma)) {
+			netdev_alert(pdata->netdev,
+				     "failed to do the dma map\n");
+			dev_kfree_skb_any(skb);
+			break;
+		}
+		rdata->skb = skb;
+		rdata->skb_dma = skb_dma;
+		rdata->skb_dma_len = pdata->rx_buf_size;
+
+		hw_if->rx_desc_reset(rdata);
+
+		ring->rx.realloc_index++;
+	}
+	ring->dirty = 0;
+
+	DBGPR("<--xgbe_realloc_skb\n");
+}
+
+void xgbe_init_function_ptrs_desc(struct xgbe_desc_if *desc_if)
+{
+	DBGPR("-->xgbe_init_function_ptrs_desc\n");
+
+	desc_if->alloc_ring_resources = xgbe_alloc_ring_resources;
+	desc_if->free_ring_resources = xgbe_free_ring_resources;
+	desc_if->map_tx_skb = xgbe_map_tx_skb;
+	desc_if->realloc_skb = xgbe_realloc_skb;
+	desc_if->unmap_skb = xgbe_unmap_skb;
+	desc_if->wrapper_tx_desc_init = xgbe_wrapper_tx_descriptor_init;
+	desc_if->wrapper_rx_desc_init = xgbe_wrapper_rx_descriptor_init;
+
+	DBGPR("<--xgbe_init_function_ptrs_desc\n");
+}
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
new file mode 100644
index 0000000..36bc86e
--- /dev/null
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -0,0 +1,2183 @@
+/*
+ * AMD 10Gb Ethernet driver
+ *
+ * This file is available to you under your choice of the following two
+ * licenses:
+ *
+ * License 1: GPLv2
+ *
+ * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ *
+ * This file is free software; you may copy, redistribute and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation, either version 2 of the License, or (at
+ * your option) any later version.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ *
+ * This file incorporates work covered by the following copyright and
+ * permission notice:
+ *     The Synopsys DWC ETHER XGMAC Software Driver and documentation
+ *     (hereinafter "Software") is an unsupported proprietary work of Synopsys,
+ *     Inc. unless otherwise expressly agreed to in writing between Synopsys
+ *     and you.
+ *
+ *     The Software IS NOT an item of Licensed Software or Licensed Product
+ *     under any End User Software License Agreement or Agreement for Licensed
+ *     Product with Synopsys or any supplement thereto.  Permission is hereby
+ *     granted, free of charge, to any person obtaining a copy of this software
+ *     annotated with this license and the Software, to deal in the Software
+ *     without restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or sell copies
+ *     of the Software, and to permit persons to whom the Software is furnished
+ *     to do so, subject to the following conditions:
+ *
+ *     The above copyright notice and this permission notice shall be included
+ *     in all copies or substantial portions of the Software.
+ *
+ *     THIS SOFTWARE IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN "AS IS"
+ *     BASIS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
+ *     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+ *     PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS
+ *     BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ *     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
+ *     THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ *
+ * License 2: Modified BSD
+ *
+ * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ * All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Advanced Micro Devices, Inc. nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
+ * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ * This file incorporates work covered by the following copyright and
+ * permission notice:
+ *     The Synopsys DWC ETHER XGMAC Software Driver and documentation
+ *     (hereinafter "Software") is an unsupported proprietary work of Synopsys,
+ *     Inc. unless otherwise expressly agreed to in writing between Synopsys
+ *     and you.
+ *
+ *     The Software IS NOT an item of Licensed Software or Licensed Product
+ *     under any End User Software License Agreement or Agreement for Licensed
+ *     Product with Synopsys or any supplement thereto.  Permission is hereby
+ *     granted, free of charge, to any person obtaining a copy of this software
+ *     annotated with this license and the Software, to deal in the Software
+ *     without restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or sell copies
+ *     of the Software, and to permit persons to whom the Software is furnished
+ *     to do so, subject to the following conditions:
+ *
+ *     The above copyright notice and this permission notice shall be included
+ *     in all copies or substantial portions of the Software.
+ *
+ *     THIS SOFTWARE IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN "AS IS"
+ *     BASIS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
+ *     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+ *     PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS
+ *     BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ *     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
+ *     THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <linux/phy.h>
+#include <linux/clk.h>
+#include <asm/cputype.h>
+
+#include "xgbe.h"
+#include "xgbe-common.h"
+
+
+static unsigned int xgbe_usec_to_riwt(struct xgbe_prv_data *pdata,
+				      unsigned int usec)
+{
+	unsigned long rate;
+	unsigned int ret;
+
+	DBGPR("-->xgbe_usec_to_riwt\n");
+
+	rate = clk_get_rate(pdata->sysclock);
+
+	/*
+	 * Convert the input usec value to the watchdog timer value. Each
+	 * watchdog timer value is equivalent to 256 clock cycles.
+	 * Calculate the required value as:
+	 *   ( usec * ( system_clock_mhz / 10^6 ) / 256
+	 */
+	ret = (usec * (rate / 1000000)) / 256;
+
+	DBGPR("<--xgbe_usec_to_riwt\n");
+
+	return ret;
+}
+
+static unsigned int xgbe_riwt_to_usec(struct xgbe_prv_data *pdata,
+				      unsigned int riwt)
+{
+	unsigned long rate;
+	unsigned int ret;
+
+	DBGPR("-->xgbe_riwt_to_usec\n");
+
+	rate = clk_get_rate(pdata->sysclock);
+
+	/*
+	 * Convert the input watchdog timer value to the usec value. Each
+	 * watchdog timer value is equivalent to 256 clock cycles.
+	 * Calculate the required value as:
+	 *   ( riwt * 256 ) / ( system_clock_mhz / 10^6 )
+	 */
+	ret = (riwt * 256) / (rate / 1000000);
+
+	DBGPR("<--xgbe_riwt_to_usec\n");
+
+	return ret;
+}
+
+static int xgbe_config_pblx8(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_channel *channel;
+	unsigned int i;
+
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++)
+		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_CR, PBLX8,
+				       pdata->pblx8);
+
+	return 0;
+}
+
+static int xgbe_get_tx_pbl_val(struct xgbe_prv_data *pdata)
+{
+	return XGMAC_DMA_IOREAD_BITS(pdata->channel, DMA_CH_TCR, PBL);
+}
+
+static int xgbe_config_tx_pbl_val(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_channel *channel;
+	unsigned int i;
+
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			break;
+
+		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_TCR, PBL,
+				       pdata->tx_pbl);
+	}
+
+	return 0;
+}
+
+static int xgbe_get_rx_pbl_val(struct xgbe_prv_data *pdata)
+{
+	return XGMAC_DMA_IOREAD_BITS(pdata->channel, DMA_CH_RCR, PBL);
+}
+
+static int xgbe_config_rx_pbl_val(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_channel *channel;
+	unsigned int i;
+
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->rx_ring)
+			break;
+
+		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_RCR, PBL,
+				       pdata->rx_pbl);
+	}
+
+	return 0;
+}
+
+static int xgbe_config_osp_mode(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_channel *channel;
+	unsigned int i;
+
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			break;
+
+		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_TCR, OSP,
+				       pdata->tx_osp_mode);
+	}
+
+	return 0;
+}
+
+static int xgbe_config_rsf_mode(struct xgbe_prv_data *pdata, unsigned int val)
+{
+	unsigned int i;
+
+	for (i = 0; i < pdata->hw_feat.rx_q_cnt; i++)
+		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_RQOMR, RSF, val);
+
+	return 0;
+}
+
+static int xgbe_config_tsf_mode(struct xgbe_prv_data *pdata, unsigned int val)
+{
+	unsigned int i;
+
+	for (i = 0; i < pdata->hw_feat.tx_q_cnt; i++)
+		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_TQOMR, TSF, val);
+
+	return 0;
+}
+
+static int xgbe_config_rx_threshold(struct xgbe_prv_data *pdata,
+				    unsigned int val)
+{
+	unsigned int i;
+
+	for (i = 0; i < pdata->hw_feat.rx_q_cnt; i++)
+		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_RQOMR, RTC, val);
+
+	return 0;
+}
+
+static int xgbe_config_tx_threshold(struct xgbe_prv_data *pdata,
+				    unsigned int val)
+{
+	unsigned int i;
+
+	for (i = 0; i < pdata->hw_feat.tx_q_cnt; i++)
+		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_TQOMR, TTC, val);
+
+	return 0;
+}
+
+static int xgbe_config_rx_coalesce(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_channel *channel;
+	unsigned int i;
+
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->rx_ring)
+			break;
+
+		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_RIWT, RWT,
+				       pdata->rx_riwt);
+	}
+
+	return 0;
+}
+
+static int xgbe_config_tx_coalesce(struct xgbe_prv_data *pdata)
+{
+	return 0;
+}
+
+static void xgbe_config_rx_buffer_size(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_channel *channel;
+	unsigned int i;
+
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->rx_ring)
+			break;
+
+		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_RCR, RBSZ,
+				       pdata->rx_buf_size);
+	}
+}
+
+static void xgbe_config_tso_mode(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_channel *channel;
+	unsigned int i;
+
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			break;
+
+		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_TCR, TSE, 1);
+	}
+}
+
+static int xgbe_disable_tx_flow_control(struct xgbe_prv_data *pdata)
+{
+	unsigned int max_q_count, q_count;
+	unsigned int reg, reg_val;
+	unsigned int i;
+
+	/* Clear MTL flow control */
+	for (i = 0; i < pdata->hw_feat.rx_q_cnt; i++)
+		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_RQOMR, EHFC, 0);
+
+	/* Clear MAC flow control */
+	max_q_count = XGMAC_MAX_FLOW_CONTROL_QUEUES;
+	q_count = min_t(unsigned int, pdata->hw_feat.rx_q_cnt, max_q_count);
+	reg = MAC_Q0TFCR;
+	for (i = 0; i < q_count; i++) {
+		reg_val = XGMAC_IOREAD(pdata, reg);
+		XGMAC_SET_BITS(reg_val, MAC_Q0TFCR, TFE, 0);
+		XGMAC_IOWRITE(pdata, reg, reg_val);
+
+		reg += MAC_QTFCR_INC;
+	}
+
+	return 0;
+}
+
+static int xgbe_enable_tx_flow_control(struct xgbe_prv_data *pdata)
+{
+	unsigned int max_q_count, q_count;
+	unsigned int reg, reg_val;
+	unsigned int i;
+
+	/* Set MTL flow control */
+	for (i = 0; i < pdata->hw_feat.rx_q_cnt; i++)
+		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_RQOMR, EHFC, 1);
+
+	/* Set MAC flow control */
+	max_q_count = XGMAC_MAX_FLOW_CONTROL_QUEUES;
+	q_count = min_t(unsigned int, pdata->hw_feat.rx_q_cnt, max_q_count);
+	reg = MAC_Q0TFCR;
+	for (i = 0; i < q_count; i++) {
+		reg_val = XGMAC_IOREAD(pdata, reg);
+
+		/* Enable transmit flow control */
+		XGMAC_SET_BITS(reg_val, MAC_Q0TFCR, TFE, 1);
+		/* Set pause time */
+		XGMAC_SET_BITS(reg_val, MAC_Q0TFCR, PT, 0xffff);
+
+		XGMAC_IOWRITE(pdata, reg, reg_val);
+
+		reg += MAC_QTFCR_INC;
+	}
+
+	return 0;
+}
+
+static int xgbe_disable_rx_flow_control(struct xgbe_prv_data *pdata)
+{
+	XGMAC_IOWRITE_BITS(pdata, MAC_RFCR, RFE, 0);
+
+	return 0;
+}
+
+static int xgbe_enable_rx_flow_control(struct xgbe_prv_data *pdata)
+{
+	XGMAC_IOWRITE_BITS(pdata, MAC_RFCR, RFE, 1);
+
+	return 0;
+}
+
+static int xgbe_config_tx_flow_control(struct xgbe_prv_data *pdata)
+{
+	if (pdata->tx_pause)
+		xgbe_enable_tx_flow_control(pdata);
+	else
+		xgbe_disable_tx_flow_control(pdata);
+
+	return 0;
+}
+
+static int xgbe_config_rx_flow_control(struct xgbe_prv_data *pdata)
+{
+	if (pdata->rx_pause)
+		xgbe_enable_rx_flow_control(pdata);
+	else
+		xgbe_disable_rx_flow_control(pdata);
+
+	return 0;
+}
+
+static void xgbe_config_flow_control(struct xgbe_prv_data *pdata)
+{
+	xgbe_config_tx_flow_control(pdata);
+	xgbe_config_rx_flow_control(pdata);
+}
+
+static void xgbe_enable_dma_interrupts(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_channel *channel;
+	unsigned int dma_ch_isr, dma_ch_ier;
+	unsigned int i;
+
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		/* Clear all the interrupts which are set */
+		dma_ch_isr = XGMAC_DMA_IOREAD(channel, DMA_CH_SR);
+		XGMAC_DMA_IOWRITE(channel, DMA_CH_SR, dma_ch_isr);
+
+		/* Clear all interrupt enable bits */
+		dma_ch_ier = 0;
+
+		/* Enable following interrupts
+		 *   NIE  - Normal Interrupt Summary Enable
+		 *   AIE  - Abnormal Interrupt Summary Enable
+		 *   FBEE - Fatal Bus Error Enable
+		 */
+		XGMAC_SET_BITS(dma_ch_ier, DMA_CH_IER, NIE, 1);
+		XGMAC_SET_BITS(dma_ch_ier, DMA_CH_IER, AIE, 1);
+		XGMAC_SET_BITS(dma_ch_ier, DMA_CH_IER, FBEE, 1);
+
+		if (channel->tx_ring) {
+			/* Enable the following Tx interrupts
+			 *   TIE  - Transmit Interrupt Enable (unless polling)
+			 */
+			XGMAC_SET_BITS(dma_ch_ier, DMA_CH_IER, TIE, 1);
+		}
+		if (channel->rx_ring) {
+			/* Enable following Rx interrupts
+			 *   RBUE - Receive Buffer Unavailable Enable
+			 *   RIE  - Receive Interrupt Enable
+			 */
+			XGMAC_SET_BITS(dma_ch_ier, DMA_CH_IER, RBUE, 1);
+			XGMAC_SET_BITS(dma_ch_ier, DMA_CH_IER, RIE, 1);
+		}
+
+		XGMAC_DMA_IOWRITE(channel, DMA_CH_IER, dma_ch_ier);
+	}
+}
+
+static void xgbe_enable_mtl_interrupts(struct xgbe_prv_data *pdata)
+{
+	unsigned int mtl_q_isr;
+	unsigned int q_count, i;
+
+	q_count = max(pdata->hw_feat.tx_q_cnt, pdata->hw_feat.rx_q_cnt);
+	for (i = 0; i < q_count; i++) {
+		/* Clear all the interrupts which are set */
+		mtl_q_isr = XGMAC_MTL_IOREAD(pdata, i, MTL_Q_ISR);
+		XGMAC_MTL_IOWRITE(pdata, i, MTL_Q_ISR, mtl_q_isr);
+
+		/* No MTL interrupts to be enabled */
+		XGMAC_MTL_IOWRITE(pdata, i, MTL_Q_ISR, 0);
+	}
+}
+
+static void xgbe_enable_mac_interrupts(struct xgbe_prv_data *pdata)
+{
+	/* No MAC interrupts to be enabled */
+	XGMAC_IOWRITE(pdata, MAC_IER, 0);
+
+	/* Enable all counter interrupts */
+	XGMAC_IOWRITE_BITS(pdata, MMC_RIER, ALL_INTERRUPTS, 0xff);
+	XGMAC_IOWRITE_BITS(pdata, MMC_TIER, ALL_INTERRUPTS, 0xff);
+}
+
+static int xgbe_set_gmii_speed(struct xgbe_prv_data *pdata)
+{
+	XGMAC_IOWRITE_BITS(pdata, MAC_TCR, SS, 0x3);
+
+	return 0;
+}
+
+static int xgbe_set_gmii_2500_speed(struct xgbe_prv_data *pdata)
+{
+	XGMAC_IOWRITE_BITS(pdata, MAC_TCR, SS, 0x2);
+
+	return 0;
+}
+
+static int xgbe_set_xgmii_speed(struct xgbe_prv_data *pdata)
+{
+	XGMAC_IOWRITE_BITS(pdata, MAC_TCR, SS, 0);
+
+	return 0;
+}
+
+static int xgbe_set_promiscuous_mode(struct xgbe_prv_data *pdata,
+				     unsigned int enable)
+{
+	unsigned int val = enable ? 1 : 0;
+
+	if (XGMAC_IOREAD_BITS(pdata, MAC_PFR, PR) == val)
+		return 0;
+
+	DBGPR("  %s promiscuous mode\n", enable ? "entering" : "leaving");
+	XGMAC_IOWRITE_BITS(pdata, MAC_PFR, PR, val);
+
+	return 0;
+}
+
+static int xgbe_set_all_multicast_mode(struct xgbe_prv_data *pdata,
+				       unsigned int enable)
+{
+	unsigned int val = enable ? 1 : 0;
+
+	if (XGMAC_IOREAD_BITS(pdata, MAC_PFR, PM) == val)
+		return 0;
+
+	DBGPR("  %s allmulti mode\n", enable ? "entering" : "leaving");
+	XGMAC_IOWRITE_BITS(pdata, MAC_PFR, PM, val);
+
+	return 0;
+}
+
+static int xgbe_set_addn_mac_addrs(struct xgbe_prv_data *pdata,
+				   unsigned int am_mode)
+{
+	struct netdev_hw_addr *ha;
+	unsigned int mac_reg;
+	unsigned int mac_addr_hi, mac_addr_lo;
+	u8 *mac_addr;
+	unsigned int i;
+
+	XGMAC_IOWRITE_BITS(pdata, MAC_PFR, HUC, 0);
+	XGMAC_IOWRITE_BITS(pdata, MAC_PFR, HMC, 0);
+
+	i = 0;
+	mac_reg = MAC_MACA1HR;
+
+	netdev_for_each_uc_addr(ha, pdata->netdev) {
+		mac_addr_lo = 0;
+		mac_addr_hi = 0;
+		mac_addr = (u8 *)&mac_addr_lo;
+		mac_addr[0] = ha->addr[0];
+		mac_addr[1] = ha->addr[1];
+		mac_addr[2] = ha->addr[2];
+		mac_addr[3] = ha->addr[3];
+		mac_addr = (u8 *)&mac_addr_hi;
+		mac_addr[0] = ha->addr[4];
+		mac_addr[1] = ha->addr[5];
+
+		DBGPR("  adding unicast address %pM at 0x%04x\n",
+		      ha->addr, mac_reg);
+
+		XGMAC_SET_BITS(mac_addr_hi, MAC_MACA1HR, AE, 1);
+
+		XGMAC_IOWRITE(pdata, mac_reg, mac_addr_hi);
+		mac_reg += MAC_MACA_INC;
+		XGMAC_IOWRITE(pdata, mac_reg, mac_addr_lo);
+		mac_reg += MAC_MACA_INC;
+
+		i++;
+	}
+
+	if (!am_mode) {
+		netdev_for_each_mc_addr(ha, pdata->netdev) {
+			mac_addr_lo = 0;
+			mac_addr_hi = 0;
+			mac_addr = (u8 *)&mac_addr_lo;
+			mac_addr[0] = ha->addr[0];
+			mac_addr[1] = ha->addr[1];
+			mac_addr[2] = ha->addr[2];
+			mac_addr[3] = ha->addr[3];
+			mac_addr = (u8 *)&mac_addr_hi;
+			mac_addr[0] = ha->addr[4];
+			mac_addr[1] = ha->addr[5];
+
+			DBGPR("  adding multicast address %pM at 0x%04x\n",
+			      ha->addr, mac_reg);
+
+			XGMAC_SET_BITS(mac_addr_hi, MAC_MACA1HR, AE, 1);
+
+			XGMAC_IOWRITE(pdata, mac_reg, mac_addr_hi);
+			mac_reg += MAC_MACA_INC;
+			XGMAC_IOWRITE(pdata, mac_reg, mac_addr_lo);
+			mac_reg += MAC_MACA_INC;
+
+			i++;
+		}
+	}
+
+	/* Clear remaining additional MAC address entries */
+	for (; i < pdata->hw_feat.addn_mac; i++) {
+		XGMAC_IOWRITE(pdata, mac_reg, 0);
+		mac_reg += MAC_MACA_INC;
+		XGMAC_IOWRITE(pdata, mac_reg, 0);
+		mac_reg += MAC_MACA_INC;
+	}
+
+	return 0;
+}
+
+static int xgbe_set_mac_address(struct xgbe_prv_data *pdata, u8 *addr)
+{
+	unsigned int mac_addr_hi, mac_addr_lo;
+
+	mac_addr_hi = (addr[5] <<  8) | (addr[4] <<  0);
+	mac_addr_lo = (addr[3] << 24) | (addr[2] << 16) |
+		      (addr[1] <<  8) | (addr[0] <<  0);
+
+	XGMAC_IOWRITE(pdata, MAC_MACA0HR, mac_addr_hi);
+	XGMAC_IOWRITE(pdata, MAC_MACA0LR, mac_addr_lo);
+
+	return 0;
+}
+
+static int xgbe_read_mmd_regs(struct xgbe_prv_data *pdata, int prtad,
+			      int mmd_reg)
+{
+	unsigned int mmd_address;
+	int mmd_data;
+
+	if (mmd_reg & MII_ADDR_C45)
+		mmd_address = mmd_reg & ~MII_ADDR_C45;
+	else
+		mmd_address = (pdata->mdio_mmd << 16) | (mmd_reg & 0xffff);
+
+	/* The PCS registers are accessed using mmio. The underlying APB3
+	 * management interface uses indirect addressing to access the MMD
+	 * register sets. This requires accessing of the PCS register in two
+	 * phases, an address phase and a data phase.
+	 *
+	 * The mmio interface is based on 32-bit offsets and values. All
+	 * register offsets must therefore be adjusted by left shifting the
+	 * offset 2 bits and reading 32 bits of data.
+	 */
+	mutex_lock(&pdata->xpcs_mutex);
+	XPCS_IOWRITE(pdata, PCS_MMD_SELECT << 2, mmd_address >> 8);
+	mmd_data = XPCS_IOREAD(pdata, (mmd_address & 0xff) << 2);
+	mutex_unlock(&pdata->xpcs_mutex);
+
+	return mmd_data;
+}
+
+static void xgbe_write_mmd_regs(struct xgbe_prv_data *pdata, int prtad,
+				int mmd_reg, int mmd_data)
+{
+	unsigned int mmd_address;
+
+	if (mmd_reg & MII_ADDR_C45)
+		mmd_address = mmd_reg & ~MII_ADDR_C45;
+	else
+		mmd_address = (pdata->mdio_mmd << 16) | (mmd_reg & 0xffff);
+
+	/* The PCS registers are accessed using mmio. The underlying APB3
+	 * management interface uses indirect addressing to access the MMD
+	 * register sets. This requires accessing of the PCS register in two
+	 * phases, an address phase and a data phase.
+	 *
+	 * The mmio interface is based on 32-bit offsets and values. All
+	 * register offsets must therefore be adjusted by left shifting the
+	 * offset 2 bits and reading 32 bits of data.
+	 */
+	mutex_lock(&pdata->xpcs_mutex);
+	XPCS_IOWRITE(pdata, PCS_MMD_SELECT << 2, mmd_address >> 8);
+	XPCS_IOWRITE(pdata, (mmd_address & 0xff) << 2, mmd_data);
+	mutex_unlock(&pdata->xpcs_mutex);
+}
+
+static int xgbe_tx_complete(struct xgbe_ring_desc *rdesc)
+{
+	return !XGMAC_GET_BITS_LE(rdesc->desc3, TX_NORMAL_DESC3, OWN);
+}
+
+static int xgbe_disable_rx_csum(struct xgbe_prv_data *pdata)
+{
+	XGMAC_IOWRITE_BITS(pdata, MAC_RCR, IPC, 0);
+
+	return 0;
+}
+
+static int xgbe_enable_rx_csum(struct xgbe_prv_data *pdata)
+{
+	XGMAC_IOWRITE_BITS(pdata, MAC_RCR, IPC, 1);
+
+	return 0;
+}
+
+static int xgbe_enable_rx_vlan_stripping(struct xgbe_prv_data *pdata)
+{
+	/* Put the VLAN tag in the Rx descriptor */
+	XGMAC_IOWRITE_BITS(pdata, MAC_VLANTR, EVLRXS, 1);
+
+	/* Don't check the VLAN type */
+	XGMAC_IOWRITE_BITS(pdata, MAC_VLANTR, DOVLTC, 1);
+
+	/* Check only C-TAG (0x8100) packets */
+	XGMAC_IOWRITE_BITS(pdata, MAC_VLANTR, ERSVLM, 0);
+
+	/* Don't consider an S-TAG (0x88A8) packet as a VLAN packet */
+	XGMAC_IOWRITE_BITS(pdata, MAC_VLANTR, ESVL, 0);
+
+	/* Enable VLAN tag stripping */
+	XGMAC_IOWRITE_BITS(pdata, MAC_VLANTR, EVLS, 0x3);
+
+	return 0;
+}
+
+static int xgbe_disable_rx_vlan_stripping(struct xgbe_prv_data *pdata)
+{
+	XGMAC_IOWRITE_BITS(pdata, MAC_VLANTR, EVLS, 0);
+
+	return 0;
+}
+
+static void xgbe_tx_desc_reset(struct xgbe_ring_data *rdata)
+{
+	struct xgbe_ring_desc *rdesc = rdata->rdesc;
+
+	/* Reset the Tx descriptor
+	 *   Set buffer 1 (lo) address to zero
+	 *   Set buffer 1 (hi) address to zero
+	 *   Reset all other control bits (IC, TTSE, B2L & B1L)
+	 *   Reset all other control bits (OWN, CTXT, FD, LD, CPC, CIC, etc)
+	 */
+	rdesc->desc0 = 0;
+	rdesc->desc1 = 0;
+	rdesc->desc2 = 0;
+	rdesc->desc3 = 0;
+}
+
+static void xgbe_tx_desc_init(struct xgbe_channel *channel)
+{
+	struct xgbe_ring *ring = channel->tx_ring;
+	struct xgbe_ring_data *rdata;
+	struct xgbe_ring_desc *rdesc;
+	int i;
+	int start_index = ring->cur;
+
+	DBGPR("-->tx_desc_init\n");
+
+	/* Initialze all descriptors */
+	for (i = 0; i < ring->rdesc_count; i++) {
+		rdata = GET_DESC_DATA(ring, i);
+		rdesc = rdata->rdesc;
+
+		/* Initialize Tx descriptor
+		 *   Set buffer 1 (lo) address to zero
+		 *   Set buffer 1 (hi) address to zero
+		 *   Reset all other control bits (IC, TTSE, B2L & B1L)
+		 *   Reset all other control bits (OWN, CTXT, FD, LD, CPC, CIC,
+		 *     etc)
+		 */
+		rdesc->desc0 = 0;
+		rdesc->desc1 = 0;
+		rdesc->desc2 = 0;
+		rdesc->desc3 = 0;
+	}
+
+	/* Make sure everything is written to the descriptor(s) before
+	 * telling the device about them
+	 */
+	wmb();
+
+	/* Update the total number of Tx descriptors */
+	XGMAC_DMA_IOWRITE(channel, DMA_CH_TDRLR, ring->rdesc_count - 1);
+
+	/* Update the starting address of descriptor ring */
+	rdata = GET_DESC_DATA(ring, start_index);
+	XGMAC_DMA_IOWRITE(channel, DMA_CH_TDLR_HI,
+			  upper_32_bits(rdata->rdesc_dma));
+	XGMAC_DMA_IOWRITE(channel, DMA_CH_TDLR_LO,
+			  lower_32_bits(rdata->rdesc_dma));
+
+	DBGPR("<--tx_desc_init\n");
+}
+
+static void xgbe_rx_desc_reset(struct xgbe_ring_data *rdata)
+{
+	struct xgbe_ring_desc *rdesc = rdata->rdesc;
+
+	/* Reset the Rx descriptor
+	 *   Set buffer 1 (lo) address to dma address (lo)
+	 *   Set buffer 1 (hi) address to dma address (hi)
+	 *   Set buffer 2 (lo) address to zero
+	 *   Set buffer 2 (hi) address to zero and set control bits
+	 *     OWN and INTE
+	 */
+	rdesc->desc0 = cpu_to_le32(lower_32_bits(rdata->skb_dma));
+	rdesc->desc1 = cpu_to_le32(upper_32_bits(rdata->skb_dma));
+	rdesc->desc2 = 0;
+
+	rdesc->desc3 = 0;
+	if (rdata->interrupt)
+		XGMAC_SET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, INTE, 1);
+
+	/* Since the Rx DMA engine is likely running, make sure everything
+	 * is written to the descriptor(s) before setting the OWN bit
+	 * for the descriptor
+	 */
+	wmb();
+
+	XGMAC_SET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, OWN, 1);
+
+	/* Make sure ownership is written to the descriptor */
+	wmb();
+}
+
+static void xgbe_rx_desc_init(struct xgbe_channel *channel)
+{
+	struct xgbe_prv_data *pdata = channel->pdata;
+	struct xgbe_ring *ring = channel->rx_ring;
+	struct xgbe_ring_data *rdata;
+	struct xgbe_ring_desc *rdesc;
+	unsigned int start_index = ring->cur;
+	unsigned int rx_coalesce, rx_frames;
+	unsigned int i;
+
+	DBGPR("-->rx_desc_init\n");
+
+	rx_coalesce = (pdata->rx_riwt || pdata->rx_frames) ? 1 : 0;
+	rx_frames = pdata->rx_frames;
+
+	/* Initialize all descriptors */
+	for (i = 0; i < ring->rdesc_count; i++) {
+		rdata = GET_DESC_DATA(ring, i);
+		rdesc = rdata->rdesc;
+
+		/* Initialize Rx descriptor
+		 *   Set buffer 1 (lo) address to dma address (lo)
+		 *   Set buffer 1 (hi) address to dma address (hi)
+		 *   Set buffer 2 (lo) address to zero
+		 *   Set buffer 2 (hi) address to zero and set control
+		 *     bits OWN and INTE appropriateley
+		 */
+		rdesc->desc0 = cpu_to_le32(lower_32_bits(rdata->skb_dma));
+		rdesc->desc1 = cpu_to_le32(upper_32_bits(rdata->skb_dma));
+		rdesc->desc2 = 0;
+		rdesc->desc3 = 0;
+		XGMAC_SET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, OWN, 1);
+		XGMAC_SET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, INTE, 1);
+		rdata->interrupt = 1;
+		if (rx_coalesce && (!rx_frames || ((i + 1) % rx_frames))) {
+			/* Clear interrupt on completion bit */
+			XGMAC_SET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, INTE,
+					  0);
+			rdata->interrupt = 0;
+		}
+	}
+
+	/* Make sure everything is written to the descriptors before
+	 * telling the device about them
+	 */
+	wmb();
+
+	/* Update the total number of Rx descriptors */
+	XGMAC_DMA_IOWRITE(channel, DMA_CH_RDRLR, ring->rdesc_count - 1);
+
+	/* Update the starting address of descriptor ring */
+	rdata = GET_DESC_DATA(ring, start_index);
+	XGMAC_DMA_IOWRITE(channel, DMA_CH_RDLR_HI,
+			  upper_32_bits(rdata->rdesc_dma));
+	XGMAC_DMA_IOWRITE(channel, DMA_CH_RDLR_LO,
+			  lower_32_bits(rdata->rdesc_dma));
+
+	/* Update the Rx Descriptor Tail Pointer */
+	rdata = GET_DESC_DATA(ring, start_index + ring->rdesc_count - 1);
+	XGMAC_DMA_IOWRITE(channel, DMA_CH_RDTR_LO,
+			  lower_32_bits(rdata->rdesc_dma));
+
+	DBGPR("<--rx_desc_init\n");
+}
+
+static void xgbe_pre_xmit(struct xgbe_channel *channel)
+{
+	struct xgbe_prv_data *pdata = channel->pdata;
+	struct xgbe_ring *ring = channel->tx_ring;
+	struct xgbe_ring_data *rdata;
+	struct xgbe_ring_desc *rdesc;
+	struct xgbe_packet_data *packet = &ring->packet_data;
+	unsigned int csum, tso, vlan;
+	unsigned int tso_context, vlan_context;
+	unsigned int tx_coalesce, tx_frames;
+	int start_index = ring->cur;
+	int i;
+
+	DBGPR("-->xgbe_pre_xmit\n");
+
+	csum = XGMAC_GET_BITS(packet->attributes, TX_PACKET_ATTRIBUTES,
+			      CSUM_ENABLE);
+	tso = XGMAC_GET_BITS(packet->attributes, TX_PACKET_ATTRIBUTES,
+			     TSO_ENABLE);
+	vlan = XGMAC_GET_BITS(packet->attributes, TX_PACKET_ATTRIBUTES,
+			      VLAN_CTAG);
+
+	if (tso && (packet->mss != ring->tx.cur_mss))
+		tso_context = 1;
+	else
+		tso_context = 0;
+
+	if (vlan && (packet->vlan_ctag != ring->tx.cur_vlan_ctag))
+		vlan_context = 1;
+	else
+		vlan_context = 0;
+
+	tx_coalesce = (pdata->tx_usecs || pdata->tx_frames) ? 1 : 0;
+	tx_frames = pdata->tx_frames;
+	if (tx_coalesce && !channel->tx_timer_active)
+		ring->coalesce_count = 0;
+
+	rdata = GET_DESC_DATA(ring, ring->cur);
+	rdesc = rdata->rdesc;
+
+	/* Create a context descriptor if this is a TSO packet */
+	if (tso_context || vlan_context) {
+		if (tso_context) {
+			DBGPR("  TSO context descriptor, mss=%u\n",
+			      packet->mss);
+
+			/* Set the MSS size */
+			XGMAC_SET_BITS_LE(rdesc->desc2, TX_CONTEXT_DESC2,
+					  MSS, packet->mss);
+
+			/* Mark it as a CONTEXT descriptor */
+			XGMAC_SET_BITS_LE(rdesc->desc3, TX_CONTEXT_DESC3,
+					  CTXT, 1);
+
+			/* Indicate this descriptor contains the MSS */
+			XGMAC_SET_BITS_LE(rdesc->desc3, TX_CONTEXT_DESC3,
+					  TCMSSV, 1);
+
+			ring->tx.cur_mss = packet->mss;
+		}
+
+		if (vlan_context) {
+			DBGPR("  VLAN context descriptor, ctag=%u\n",
+			      packet->vlan_ctag);
+
+			/* Mark it as a CONTEXT descriptor */
+			XGMAC_SET_BITS_LE(rdesc->desc3, TX_CONTEXT_DESC3,
+					  CTXT, 1);
+
+			/* Set the VLAN tag */
+			XGMAC_SET_BITS_LE(rdesc->desc3, TX_CONTEXT_DESC3,
+					  VT, packet->vlan_ctag);
+
+			/* Indicate this descriptor contains the VLAN tag */
+			XGMAC_SET_BITS_LE(rdesc->desc3, TX_CONTEXT_DESC3,
+					  VLTV, 1);
+
+			ring->tx.cur_vlan_ctag = packet->vlan_ctag;
+		}
+
+		ring->cur++;
+		rdata = GET_DESC_DATA(ring, ring->cur);
+		rdesc = rdata->rdesc;
+	}
+
+	/* Update buffer address (for TSO this is the header) */
+	rdesc->desc0 =  cpu_to_le32(lower_32_bits(rdata->skb_dma));
+	rdesc->desc1 =  cpu_to_le32(upper_32_bits(rdata->skb_dma));
+
+	/* Update the buffer length */
+	XGMAC_SET_BITS_LE(rdesc->desc2, TX_NORMAL_DESC2, HL_B1L,
+			  rdata->skb_dma_len);
+
+	/* VLAN tag insertion check */
+	if (vlan)
+		XGMAC_SET_BITS_LE(rdesc->desc2, TX_NORMAL_DESC2, VTIR,
+				  TX_NORMAL_DESC2_VLAN_INSERT);
+
+	/* Set IC bit based on Tx coalescing settings */
+	XGMAC_SET_BITS_LE(rdesc->desc2, TX_NORMAL_DESC2, IC, 1);
+	if (tx_coalesce && (!tx_frames ||
+			    (++ring->coalesce_count % tx_frames)))
+		/* Clear IC bit */
+		XGMAC_SET_BITS_LE(rdesc->desc2, TX_NORMAL_DESC2, IC, 0);
+
+	/* Mark it as First Descriptor */
+	XGMAC_SET_BITS_LE(rdesc->desc3, TX_NORMAL_DESC3, FD, 1);
+
+	/* Mark it as a NORMAL descriptor */
+	XGMAC_SET_BITS_LE(rdesc->desc3, TX_NORMAL_DESC3, CTXT, 0);
+
+	/* Set OWN bit if not the first descriptor */
+	if (ring->cur != start_index)
+		XGMAC_SET_BITS_LE(rdesc->desc3, TX_NORMAL_DESC3, OWN, 1);
+
+	if (tso) {
+		/* Enable TSO */
+		XGMAC_SET_BITS_LE(rdesc->desc3, TX_NORMAL_DESC3, TSE, 1);
+		XGMAC_SET_BITS_LE(rdesc->desc3, TX_NORMAL_DESC3, TCPPL,
+				  packet->tcp_payload_len);
+		XGMAC_SET_BITS_LE(rdesc->desc3, TX_NORMAL_DESC3, TCPHDRLEN,
+				  packet->tcp_header_len / 4);
+	} else {
+		/* Enable CRC and Pad Insertion */
+		XGMAC_SET_BITS_LE(rdesc->desc3, TX_NORMAL_DESC3, CPC, 0);
+
+		/* Enable HW CSUM */
+		if (csum)
+			XGMAC_SET_BITS_LE(rdesc->desc3, TX_NORMAL_DESC3,
+					  CIC, 0x3);
+
+		/* Set the total length to be transmitted */
+		XGMAC_SET_BITS_LE(rdesc->desc3, TX_NORMAL_DESC3, FL,
+				  packet->length);
+	}
+
+	for (i = ring->cur - start_index + 1; i < packet->rdesc_count; i++) {
+		ring->cur++;
+		rdata = GET_DESC_DATA(ring, ring->cur);
+		rdesc = rdata->rdesc;
+
+		/* Update buffer address */
+		rdesc->desc0 = cpu_to_le32(lower_32_bits(rdata->skb_dma));
+		rdesc->desc1 = cpu_to_le32(upper_32_bits(rdata->skb_dma));
+
+		/* Update the buffer length */
+		XGMAC_SET_BITS_LE(rdesc->desc2, TX_NORMAL_DESC2, HL_B1L,
+				  rdata->skb_dma_len);
+
+		/* Set IC bit based on Tx coalescing settings */
+		XGMAC_SET_BITS_LE(rdesc->desc2, TX_NORMAL_DESC2, IC, 1);
+		if (tx_coalesce && (!tx_frames ||
+				    (++ring->coalesce_count % tx_frames)))
+			/* Clear IC bit */
+			XGMAC_SET_BITS_LE(rdesc->desc2, TX_NORMAL_DESC2, IC, 0);
+
+		/* Set OWN bit */
+		XGMAC_SET_BITS_LE(rdesc->desc3, TX_NORMAL_DESC3, OWN, 1);
+
+		/* Mark it as NORMAL descriptor */
+		XGMAC_SET_BITS_LE(rdesc->desc3, TX_NORMAL_DESC3, CTXT, 0);
+
+		/* Enable HW CSUM */
+		if (csum)
+			XGMAC_SET_BITS_LE(rdesc->desc3, TX_NORMAL_DESC3,
+					  CIC, 0x3);
+	}
+
+	/* Set LAST bit for the last descriptor */
+	XGMAC_SET_BITS_LE(rdesc->desc3, TX_NORMAL_DESC3, LD, 1);
+
+	/* In case the Tx DMA engine is running, make sure everything
+	 * is written to the descriptor(s) before setting the OWN bit
+	 * for the first descriptor
+	 */
+	wmb();
+
+	/* Set OWN bit for the first descriptor */
+	rdata = GET_DESC_DATA(ring, start_index);
+	rdesc = rdata->rdesc;
+	XGMAC_SET_BITS_LE(rdesc->desc3, TX_NORMAL_DESC3, OWN, 1);
+
+#ifdef XGMAC_ENABLE_TX_DESC_DUMP
+	xgbe_dump_tx_desc(ring, start_index, packet->rdesc_count, 1);
+#endif
+
+	/* Make sure ownership is written to the descriptor */
+	wmb();
+
+	/* Issue a poll command to Tx DMA by writing address
+	 * of next immediate free descriptor */
+	ring->cur++;
+	rdata = GET_DESC_DATA(ring, ring->cur);
+	XGMAC_DMA_IOWRITE(channel, DMA_CH_TDTR_LO,
+			  lower_32_bits(rdata->rdesc_dma));
+
+	/* Start the Tx coalescing timer */
+	if (tx_coalesce && !channel->tx_timer_active) {
+		channel->tx_timer_active = 1;
+		hrtimer_start(&channel->tx_timer,
+			      ktime_set(0, pdata->tx_usecs * NSEC_PER_USEC),
+			      HRTIMER_MODE_REL);
+	}
+
+	DBGPR("  %s: descriptors %u to %u written\n",
+	      channel->name, start_index & (ring->rdesc_count - 1),
+	      (ring->cur - 1) & (ring->rdesc_count - 1));
+
+	DBGPR("<--xgbe_pre_xmit\n");
+}
+
+static int xgbe_dev_read(struct xgbe_channel *channel)
+{
+	struct xgbe_ring *ring = channel->rx_ring;
+	struct xgbe_ring_data *rdata;
+	struct xgbe_ring_desc *rdesc;
+	struct xgbe_packet_data *packet = &ring->packet_data;
+	unsigned int err, etlt;
+
+	DBGPR("-->xgbe_dev_read: cur = %d\n", ring->cur);
+
+	rdata = GET_DESC_DATA(ring, ring->cur);
+	rdesc = rdata->rdesc;
+
+	/* Check for data availability */
+	if (XGMAC_GET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, OWN))
+		return 1;
+
+#ifdef XGMAC_ENABLE_RX_DESC_DUMP
+	xgbe_dump_rx_desc(ring, rdesc, ring->cur);
+#endif
+
+	/* Get the packet length */
+	rdata->len = XGMAC_GET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, PL);
+
+	if (!XGMAC_GET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, LD)) {
+		/* Not all the data has been transferred for this packet */
+		XGMAC_SET_BITS(packet->attributes, RX_PACKET_ATTRIBUTES,
+			       INCOMPLETE, 1);
+		return 0;
+	}
+
+	/* This is the last of the data for this packet */
+	XGMAC_SET_BITS(packet->attributes, RX_PACKET_ATTRIBUTES,
+		       INCOMPLETE, 0);
+
+	/* Set checksum done indicator as appropriate */
+	if (channel->pdata->netdev->features & NETIF_F_RXCSUM)
+		XGMAC_SET_BITS(packet->attributes, RX_PACKET_ATTRIBUTES,
+			       CSUM_DONE, 1);
+
+	/* Check for errors (only valid in last descriptor) */
+	err = XGMAC_GET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, ES);
+	etlt = XGMAC_GET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, ETLT);
+	DBGPR("  err=%u, etlt=%#x\n", err, etlt);
+
+	if (!err || (err && !etlt)) {
+		if (etlt == 0x09) {
+			XGMAC_SET_BITS(packet->attributes, RX_PACKET_ATTRIBUTES,
+				       VLAN_CTAG, 1);
+			packet->vlan_ctag = XGMAC_GET_BITS_LE(rdesc->desc0,
+							      RX_NORMAL_DESC0,
+							      OVT);
+			DBGPR("  vlan-ctag=0x%04x\n", packet->vlan_ctag);
+		}
+	} else {
+		if ((etlt == 0x05) || (etlt == 0x06))
+			XGMAC_SET_BITS(packet->attributes, RX_PACKET_ATTRIBUTES,
+				       CSUM_DONE, 0);
+		else
+			XGMAC_SET_BITS(packet->errors, RX_PACKET_ERRORS,
+				       FRAME, 1);
+	}
+
+	DBGPR("<--xgbe_dev_read: %s - descriptor=%u (cur=%d)\n", channel->name,
+	      ring->cur & (ring->rdesc_count - 1), ring->cur);
+
+	return 0;
+}
+
+static int xgbe_is_context_desc(struct xgbe_ring_desc *rdesc)
+{
+	/* Rx and Tx share CTXT bit, so check TDES3.CTXT bit */
+	return XGMAC_GET_BITS_LE(rdesc->desc3, TX_NORMAL_DESC3, CTXT);
+}
+
+static int xgbe_is_last_desc(struct xgbe_ring_desc *rdesc)
+{
+	/* Rx and Tx share LD bit, so check TDES3.LD bit */
+	return XGMAC_GET_BITS_LE(rdesc->desc3, TX_NORMAL_DESC3, LD);
+}
+
+static void xgbe_save_interrupt_status(struct xgbe_channel *channel,
+				       enum xgbe_int_state int_state)
+{
+	unsigned int dma_ch_ier;
+
+	if (int_state == XGMAC_INT_STATE_SAVE) {
+		channel->saved_ier = XGMAC_DMA_IOREAD(channel, DMA_CH_IER);
+		channel->saved_ier &= DMA_INTERRUPT_MASK;
+	} else {
+		dma_ch_ier = XGMAC_DMA_IOREAD(channel, DMA_CH_IER);
+		dma_ch_ier |= channel->saved_ier;
+		XGMAC_DMA_IOWRITE(channel, DMA_CH_IER, dma_ch_ier);
+	}
+}
+
+static int xgbe_enable_int(struct xgbe_channel *channel,
+			   enum xgbe_int int_id)
+{
+	switch (int_id) {
+	case XGMAC_INT_DMA_ISR_DC0IS:
+		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_IER, TIE, 1);
+		break;
+	case XGMAC_INT_DMA_CH_SR_TI:
+		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_IER, TIE, 1);
+		break;
+	case XGMAC_INT_DMA_CH_SR_TPS:
+		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_IER, TXSE, 1);
+		break;
+	case XGMAC_INT_DMA_CH_SR_TBU:
+		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_IER, TBUE, 1);
+		break;
+	case XGMAC_INT_DMA_CH_SR_RI:
+		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_IER, RIE, 1);
+		break;
+	case XGMAC_INT_DMA_CH_SR_RBU:
+		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_IER, RBUE, 1);
+		break;
+	case XGMAC_INT_DMA_CH_SR_RPS:
+		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_IER, RSE, 1);
+		break;
+	case XGMAC_INT_DMA_CH_SR_FBE:
+		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_IER, FBEE, 1);
+		break;
+	case XGMAC_INT_DMA_ALL:
+		xgbe_save_interrupt_status(channel, XGMAC_INT_STATE_RESTORE);
+		break;
+	default:
+		return -1;
+	}
+
+	return 0;
+}
+
+static int xgbe_disable_int(struct xgbe_channel *channel,
+			    enum xgbe_int int_id)
+{
+	unsigned int dma_ch_ier;
+
+	switch (int_id) {
+	case XGMAC_INT_DMA_ISR_DC0IS:
+		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_IER, TIE, 0);
+		break;
+	case XGMAC_INT_DMA_CH_SR_TI:
+		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_IER, TIE, 0);
+		break;
+	case XGMAC_INT_DMA_CH_SR_TPS:
+		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_IER, TXSE, 0);
+		break;
+	case XGMAC_INT_DMA_CH_SR_TBU:
+		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_IER, TBUE, 0);
+		break;
+	case XGMAC_INT_DMA_CH_SR_RI:
+		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_IER, RIE, 0);
+		break;
+	case XGMAC_INT_DMA_CH_SR_RBU:
+		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_IER, RBUE, 0);
+		break;
+	case XGMAC_INT_DMA_CH_SR_RPS:
+		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_IER, RSE, 0);
+		break;
+	case XGMAC_INT_DMA_CH_SR_FBE:
+		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_IER, FBEE, 0);
+		break;
+	case XGMAC_INT_DMA_ALL:
+		xgbe_save_interrupt_status(channel, XGMAC_INT_STATE_SAVE);
+
+		dma_ch_ier = XGMAC_DMA_IOREAD(channel, DMA_CH_IER);
+		dma_ch_ier &= ~DMA_INTERRUPT_MASK;
+		XGMAC_DMA_IOWRITE(channel, DMA_CH_IER, dma_ch_ier);
+		break;
+	default:
+		return -1;
+	}
+
+	return 0;
+}
+
+static int xgbe_exit(struct xgbe_prv_data *pdata)
+{
+	unsigned int count = 2000;
+
+	DBGPR("-->xgbe_exit\n");
+
+	/* Issue a software reset */
+	XGMAC_IOWRITE_BITS(pdata, DMA_MR, SWR, 1);
+	usleep_range(10, 15);
+
+	/* Poll Until Poll Condition */
+	while (count-- && XGMAC_IOREAD_BITS(pdata, DMA_MR, SWR))
+		usleep_range(500, 600);
+
+	if (!count)
+		return -EBUSY;
+
+	DBGPR("<--xgbe_exit\n");
+
+	return 0;
+}
+
+static int xgbe_flush_tx_queues(struct xgbe_prv_data *pdata)
+{
+	unsigned int i, count;
+
+	for (i = 0; i < pdata->hw_feat.tx_q_cnt; i++)
+		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_TQOMR, FTQ, 1);
+
+	/* Poll Until Poll Condition */
+	for (i = 0; i < pdata->hw_feat.tx_q_cnt; i++) {
+		count = 2000;
+		while (count-- && XGMAC_MTL_IOREAD_BITS(pdata, i,
+							MTL_Q_TQOMR, FTQ))
+			usleep_range(500, 600);
+
+		if (!count)
+			return -EBUSY;
+	}
+
+	return 0;
+}
+
+static void xgbe_config_dma_bus(struct xgbe_prv_data *pdata)
+{
+	/* Set enhanced addressing mode */
+	XGMAC_IOWRITE_BITS(pdata, DMA_SBMR, EAME, 1);
+
+	/* Set the System Bus mode */
+	XGMAC_IOWRITE_BITS(pdata, DMA_SBMR, UNDEF, 1);
+}
+
+static void xgbe_config_dma_cache(struct xgbe_prv_data *pdata)
+{
+	unsigned int arcache, awcache;
+
+	arcache = 0;
+	XGMAC_SET_BITS(arcache, DMA_AXIARCR, DRC, DMA_ARCACHE_SETTING);
+	XGMAC_SET_BITS(arcache, DMA_AXIARCR, DRD, DMA_ARDOMAIN_SETTING);
+	XGMAC_SET_BITS(arcache, DMA_AXIARCR, TEC, DMA_ARCACHE_SETTING);
+	XGMAC_SET_BITS(arcache, DMA_AXIARCR, TED, DMA_ARDOMAIN_SETTING);
+	XGMAC_SET_BITS(arcache, DMA_AXIARCR, THC, DMA_ARCACHE_SETTING);
+	XGMAC_SET_BITS(arcache, DMA_AXIARCR, THD, DMA_ARDOMAIN_SETTING);
+	XGMAC_IOWRITE(pdata, DMA_AXIARCR, arcache);
+
+	awcache = 0;
+	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, DWC, DMA_AWCACHE_SETTING);
+	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, DWD, DMA_AWDOMAIN_SETTING);
+	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, RPC, DMA_AWCACHE_SETTING);
+	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, RPD, DMA_AWDOMAIN_SETTING);
+	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, RHC, DMA_AWCACHE_SETTING);
+	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, RHD, DMA_AWDOMAIN_SETTING);
+	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, TDC, DMA_AWCACHE_SETTING);
+	XGMAC_SET_BITS(awcache, DMA_AXIAWCR, TDD, DMA_AWDOMAIN_SETTING);
+	XGMAC_IOWRITE(pdata, DMA_AXIAWCR, awcache);
+}
+
+static void xgbe_config_mtl_mode(struct xgbe_prv_data *pdata)
+{
+	unsigned int i;
+
+	/* Set Tx to weighted round robin scheduling algorithm (when
+	 * traffic class is using ETS algorithm)
+	 */
+	XGMAC_IOWRITE_BITS(pdata, MTL_OMR, ETSALG, MTL_ETSALG_WRR);
+
+	/* Set Tx traffic classes to strict priority algorithm */
+	for (i = 0; i < XGBE_TC_CNT; i++)
+		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_TC_ETSCR, TSA, MTL_TSA_SP);
+
+	/* Set Rx to strict priority algorithm */
+	XGMAC_IOWRITE_BITS(pdata, MTL_OMR, RAA, MTL_RAA_SP);
+}
+
+static unsigned int xgbe_calculate_per_queue_fifo(unsigned long fifo_size,
+						  unsigned char queue_count)
+{
+	unsigned int q_fifo_size = 0;
+	enum xgbe_mtl_fifo_size p_fifo = XGMAC_MTL_FIFO_SIZE_256;
+
+	/* Calculate Tx/Rx fifo share per queue */
+	switch (fifo_size) {
+	case 0:
+		q_fifo_size = FIFO_SIZE_B(128);
+		break;
+	case 1:
+		q_fifo_size = FIFO_SIZE_B(256);
+		break;
+	case 2:
+		q_fifo_size = FIFO_SIZE_B(512);
+		break;
+	case 3:
+		q_fifo_size = FIFO_SIZE_KB(1);
+		break;
+	case 4:
+		q_fifo_size = FIFO_SIZE_KB(2);
+		break;
+	case 5:
+		q_fifo_size = FIFO_SIZE_KB(4);
+		break;
+	case 6:
+		q_fifo_size = FIFO_SIZE_KB(8);
+		break;
+	case 7:
+		q_fifo_size = FIFO_SIZE_KB(16);
+		break;
+	case 8:
+		q_fifo_size = FIFO_SIZE_KB(32);
+		break;
+	case 9:
+		q_fifo_size = FIFO_SIZE_KB(64);
+		break;
+	case 10:
+		q_fifo_size = FIFO_SIZE_KB(128);
+		break;
+	case 11:
+		q_fifo_size = FIFO_SIZE_KB(256);
+		break;
+	}
+	q_fifo_size = q_fifo_size / queue_count;
+
+	/* Set the queue fifo size programmable value */
+	if (q_fifo_size >= FIFO_SIZE_KB(256))
+		p_fifo = XGMAC_MTL_FIFO_SIZE_256K;
+	else if (q_fifo_size >= FIFO_SIZE_KB(128))
+		p_fifo = XGMAC_MTL_FIFO_SIZE_128K;
+	else if (q_fifo_size >= FIFO_SIZE_KB(64))
+		p_fifo = XGMAC_MTL_FIFO_SIZE_64K;
+	else if (q_fifo_size >= FIFO_SIZE_KB(32))
+		p_fifo = XGMAC_MTL_FIFO_SIZE_32K;
+	else if (q_fifo_size >= FIFO_SIZE_KB(16))
+		p_fifo = XGMAC_MTL_FIFO_SIZE_16K;
+	else if (q_fifo_size >= FIFO_SIZE_KB(8))
+		p_fifo = XGMAC_MTL_FIFO_SIZE_8K;
+	else if (q_fifo_size >= FIFO_SIZE_KB(4))
+		p_fifo = XGMAC_MTL_FIFO_SIZE_4K;
+	else if (q_fifo_size >= FIFO_SIZE_KB(2))
+		p_fifo = XGMAC_MTL_FIFO_SIZE_2K;
+	else if (q_fifo_size >= FIFO_SIZE_KB(1))
+		p_fifo = XGMAC_MTL_FIFO_SIZE_1K;
+	else if (q_fifo_size >= FIFO_SIZE_B(512))
+		p_fifo = XGMAC_MTL_FIFO_SIZE_512;
+	else if (q_fifo_size >= FIFO_SIZE_B(256))
+		p_fifo = XGMAC_MTL_FIFO_SIZE_256;
+
+	return p_fifo;
+}
+
+static void xgbe_config_tx_fifo_size(struct xgbe_prv_data *pdata)
+{
+	enum xgbe_mtl_fifo_size fifo_size;
+	unsigned int i;
+
+	fifo_size = xgbe_calculate_per_queue_fifo(pdata->hw_feat.tx_fifo_size,
+						  pdata->hw_feat.tx_q_cnt);
+
+	for (i = 0; i < pdata->hw_feat.tx_q_cnt; i++)
+		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_TQOMR, TQS, fifo_size);
+
+	netdev_notice(pdata->netdev, "%d Tx queues, %d byte fifo per queue\n",
+		      pdata->hw_feat.tx_q_cnt, ((fifo_size + 1) * 256));
+}
+
+static void xgbe_config_rx_fifo_size(struct xgbe_prv_data *pdata)
+{
+	enum xgbe_mtl_fifo_size fifo_size;
+	unsigned int i;
+
+	fifo_size = xgbe_calculate_per_queue_fifo(pdata->hw_feat.rx_fifo_size,
+						  pdata->hw_feat.rx_q_cnt);
+
+	for (i = 0; i < pdata->hw_feat.rx_q_cnt; i++)
+		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_RQOMR, RQS, fifo_size);
+
+	netdev_notice(pdata->netdev, "%d Rx queues, %d byte fifo per queue\n",
+		      pdata->hw_feat.rx_q_cnt, ((fifo_size + 1) * 256));
+}
+
+static void xgbe_config_rx_queue_mapping(struct xgbe_prv_data *pdata)
+{
+	unsigned int i, reg, reg_val;
+	unsigned int q_count = pdata->hw_feat.rx_q_cnt;
+
+	/* Select dynamic mapping of MTL Rx queue to DMA Rx channel */
+	reg = MTL_RQDCM0R;
+	reg_val = 0;
+	for (i = 0; i < q_count;) {
+		reg_val |= (0x80 << ((i++ % MTL_RQDCM_Q_PER_REG) << 3));
+
+		if ((i % MTL_RQDCM_Q_PER_REG) && (i != q_count))
+			continue;
+
+		XGMAC_IOWRITE(pdata, reg, reg_val);
+
+		reg += MTL_RQDCM_INC;
+		reg_val = 0;
+	}
+}
+
+static void xgbe_config_flow_control_threshold(struct xgbe_prv_data *pdata)
+{
+	unsigned int i;
+
+	for (i = 0; i < pdata->hw_feat.rx_q_cnt; i++) {
+		/* Activate flow control when less than 4k left in fifo */
+		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_RQOMR, RFA, 2);
+
+		/* De-activate flow control when more than 6k left in fifo */
+		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_RQOMR, RFD, 4);
+	}
+}
+
+static void xgbe_config_mac_address(struct xgbe_prv_data *pdata)
+{
+	xgbe_set_mac_address(pdata, pdata->netdev->dev_addr);
+}
+
+static void xgbe_config_jumbo_enable(struct xgbe_prv_data *pdata)
+{
+	unsigned int val;
+
+	val = (pdata->netdev->mtu > XGMAC_STD_PACKET_MTU) ? 1 : 0;
+
+	XGMAC_IOWRITE_BITS(pdata, MAC_RCR, JE, val);
+}
+
+static void xgbe_config_checksum_offload(struct xgbe_prv_data *pdata)
+{
+	if (pdata->netdev->features & NETIF_F_RXCSUM)
+		xgbe_enable_rx_csum(pdata);
+	else
+		xgbe_disable_rx_csum(pdata);
+}
+
+static void xgbe_config_vlan_support(struct xgbe_prv_data *pdata)
+{
+	if (pdata->netdev->features & NETIF_F_HW_VLAN_CTAG_RX)
+		xgbe_enable_rx_vlan_stripping(pdata);
+	else
+		xgbe_disable_rx_vlan_stripping(pdata);
+}
+
+static void xgbe_tx_mmc_int(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_mmc_stats *stats = &pdata->mmc_stats;
+	unsigned int mmc_isr = XGMAC_IOREAD(pdata, MMC_TISR);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TXOCTETCOUNT_GB))
+		stats->txoctetcount_gb +=
+			XGMAC_IOREAD(pdata, MMC_TXOCTETCOUNT_GB_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TXFRAMECOUNT_GB))
+		stats->txframecount_gb +=
+			XGMAC_IOREAD(pdata, MMC_TXFRAMECOUNT_GB_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TXBROADCASTFRAMES_G))
+		stats->txbroadcastframes_g +=
+			XGMAC_IOREAD(pdata, MMC_TXBROADCASTFRAMES_G_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TXMULTICASTFRAMES_G))
+		stats->txmulticastframes_g +=
+			XGMAC_IOREAD(pdata, MMC_TXMULTICASTFRAMES_G_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TX64OCTETS_GB))
+		stats->tx64octets_gb +=
+			XGMAC_IOREAD(pdata, MMC_TX64OCTETS_GB_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TX65TO127OCTETS_GB))
+		stats->tx65to127octets_gb +=
+			XGMAC_IOREAD(pdata, MMC_TX65TO127OCTETS_GB_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TX128TO255OCTETS_GB))
+		stats->tx128to255octets_gb +=
+			XGMAC_IOREAD(pdata, MMC_TX128TO255OCTETS_GB_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TX256TO511OCTETS_GB))
+		stats->tx256to511octets_gb +=
+			XGMAC_IOREAD(pdata, MMC_TX256TO511OCTETS_GB_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TX512TO1023OCTETS_GB))
+		stats->tx512to1023octets_gb +=
+			XGMAC_IOREAD(pdata, MMC_TX512TO1023OCTETS_GB_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TX1024TOMAXOCTETS_GB))
+		stats->tx1024tomaxoctets_gb +=
+			XGMAC_IOREAD(pdata, MMC_TX1024TOMAXOCTETS_GB_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TXUNICASTFRAMES_GB))
+		stats->txunicastframes_gb +=
+			XGMAC_IOREAD(pdata, MMC_TXUNICASTFRAMES_GB_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TXMULTICASTFRAMES_GB))
+		stats->txmulticastframes_gb +=
+			XGMAC_IOREAD(pdata, MMC_TXMULTICASTFRAMES_GB_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TXBROADCASTFRAMES_GB))
+		stats->txbroadcastframes_g +=
+			XGMAC_IOREAD(pdata, MMC_TXBROADCASTFRAMES_GB_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TXUNDERFLOWERROR))
+		stats->txunderflowerror +=
+			XGMAC_IOREAD(pdata, MMC_TXUNDERFLOWERROR_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TXOCTETCOUNT_G))
+		stats->txoctetcount_g +=
+			XGMAC_IOREAD(pdata, MMC_TXOCTETCOUNT_G_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TXFRAMECOUNT_G))
+		stats->txframecount_g +=
+			XGMAC_IOREAD(pdata, MMC_TXFRAMECOUNT_G_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TXPAUSEFRAMES))
+		stats->txpauseframes +=
+			XGMAC_IOREAD(pdata, MMC_TXPAUSEFRAMES_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_TISR, TXVLANFRAMES_G))
+		stats->txvlanframes_g +=
+			XGMAC_IOREAD(pdata, MMC_TXVLANFRAMES_G_LO);
+}
+
+static void xgbe_rx_mmc_int(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_mmc_stats *stats = &pdata->mmc_stats;
+	unsigned int mmc_isr = XGMAC_IOREAD(pdata, MMC_RISR);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXFRAMECOUNT_GB))
+		stats->rxframecount_gb +=
+			XGMAC_IOREAD(pdata, MMC_RXFRAMECOUNT_GB_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXOCTETCOUNT_GB))
+		stats->rxoctetcount_gb +=
+			XGMAC_IOREAD(pdata, MMC_RXOCTETCOUNT_GB_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXOCTETCOUNT_G))
+		stats->rxoctetcount_g +=
+			XGMAC_IOREAD(pdata, MMC_RXOCTETCOUNT_G_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXBROADCASTFRAMES_G))
+		stats->rxbroadcastframes_g +=
+			XGMAC_IOREAD(pdata, MMC_RXBROADCASTFRAMES_G_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXMULTICASTFRAMES_G))
+		stats->rxmulticastframes_g +=
+			XGMAC_IOREAD(pdata, MMC_RXMULTICASTFRAMES_G_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXCRCERROR))
+		stats->rxcrcerror +=
+			XGMAC_IOREAD(pdata, MMC_RXCRCERROR_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXRUNTERROR))
+		stats->rxrunterror +=
+			XGMAC_IOREAD(pdata, MMC_RXRUNTERROR);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXJABBERERROR))
+		stats->rxjabbererror +=
+			XGMAC_IOREAD(pdata, MMC_RXJABBERERROR);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXUNDERSIZE_G))
+		stats->rxundersize_g +=
+			XGMAC_IOREAD(pdata, MMC_RXUNDERSIZE_G);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXOVERSIZE_G))
+		stats->rxoversize_g +=
+			XGMAC_IOREAD(pdata, MMC_RXOVERSIZE_G);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RX64OCTETS_GB))
+		stats->rx64octets_gb +=
+			XGMAC_IOREAD(pdata, MMC_RX64OCTETS_GB_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RX65TO127OCTETS_GB))
+		stats->rx65to127octets_gb +=
+			XGMAC_IOREAD(pdata, MMC_RX65TO127OCTETS_GB_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RX128TO255OCTETS_GB))
+		stats->rx128to255octets_gb +=
+			XGMAC_IOREAD(pdata, MMC_RX128TO255OCTETS_GB_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RX256TO511OCTETS_GB))
+		stats->rx256to511octets_gb +=
+			XGMAC_IOREAD(pdata, MMC_RX256TO511OCTETS_GB_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RX512TO1023OCTETS_GB))
+		stats->rx512to1023octets_gb +=
+			XGMAC_IOREAD(pdata, MMC_RX512TO1023OCTETS_GB_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RX1024TOMAXOCTETS_GB))
+		stats->rx1024tomaxoctets_gb +=
+			XGMAC_IOREAD(pdata, MMC_RX1024TOMAXOCTETS_GB_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXUNICASTFRAMES_G))
+		stats->rxunicastframes_g +=
+			XGMAC_IOREAD(pdata, MMC_RXUNICASTFRAMES_G_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXLENGTHERROR))
+		stats->rxlengtherror +=
+			XGMAC_IOREAD(pdata, MMC_RXLENGTHERROR_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXOUTOFRANGETYPE))
+		stats->rxoutofrangetype +=
+			XGMAC_IOREAD(pdata, MMC_RXOUTOFRANGETYPE_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXPAUSEFRAMES))
+		stats->rxpauseframes +=
+			XGMAC_IOREAD(pdata, MMC_RXPAUSEFRAMES_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXFIFOOVERFLOW))
+		stats->rxfifooverflow +=
+			XGMAC_IOREAD(pdata, MMC_RXFIFOOVERFLOW_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXVLANFRAMES_GB))
+		stats->rxvlanframes_gb +=
+			XGMAC_IOREAD(pdata, MMC_RXVLANFRAMES_GB_LO);
+
+	if (XGMAC_GET_BITS(mmc_isr, MMC_RISR, RXWATCHDOGERROR))
+		stats->rxwatchdogerror +=
+			XGMAC_IOREAD(pdata, MMC_RXWATCHDOGERROR);
+}
+
+static void xgbe_read_mmc_stats(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_mmc_stats *stats = &pdata->mmc_stats;
+
+	/* Freeze counters */
+	XGMAC_IOWRITE_BITS(pdata, MMC_CR, MCF, 1);
+
+	stats->txoctetcount_gb +=
+		XGMAC_IOREAD(pdata, MMC_TXOCTETCOUNT_GB_LO);
+
+	stats->txframecount_gb +=
+		XGMAC_IOREAD(pdata, MMC_TXFRAMECOUNT_GB_LO);
+
+	stats->txbroadcastframes_g +=
+		XGMAC_IOREAD(pdata, MMC_TXBROADCASTFRAMES_G_LO);
+
+	stats->txmulticastframes_g +=
+		XGMAC_IOREAD(pdata, MMC_TXMULTICASTFRAMES_G_LO);
+
+	stats->tx64octets_gb +=
+		XGMAC_IOREAD(pdata, MMC_TX64OCTETS_GB_LO);
+
+	stats->tx65to127octets_gb +=
+		XGMAC_IOREAD(pdata, MMC_TX65TO127OCTETS_GB_LO);
+
+	stats->tx128to255octets_gb +=
+		XGMAC_IOREAD(pdata, MMC_TX128TO255OCTETS_GB_LO);
+
+	stats->tx256to511octets_gb +=
+		XGMAC_IOREAD(pdata, MMC_TX256TO511OCTETS_GB_LO);
+
+	stats->tx512to1023octets_gb +=
+		XGMAC_IOREAD(pdata, MMC_TX512TO1023OCTETS_GB_LO);
+
+	stats->tx1024tomaxoctets_gb +=
+		XGMAC_IOREAD(pdata, MMC_TX1024TOMAXOCTETS_GB_LO);
+
+	stats->txunicastframes_gb +=
+		XGMAC_IOREAD(pdata, MMC_TXUNICASTFRAMES_GB_LO);
+
+	stats->txmulticastframes_gb +=
+		XGMAC_IOREAD(pdata, MMC_TXMULTICASTFRAMES_GB_LO);
+
+	stats->txbroadcastframes_g +=
+		XGMAC_IOREAD(pdata, MMC_TXBROADCASTFRAMES_GB_LO);
+
+	stats->txunderflowerror +=
+		XGMAC_IOREAD(pdata, MMC_TXUNDERFLOWERROR_LO);
+
+	stats->txoctetcount_g +=
+		XGMAC_IOREAD(pdata, MMC_TXOCTETCOUNT_G_LO);
+
+	stats->txframecount_g +=
+		XGMAC_IOREAD(pdata, MMC_TXFRAMECOUNT_G_LO);
+
+	stats->txpauseframes +=
+		XGMAC_IOREAD(pdata, MMC_TXPAUSEFRAMES_LO);
+
+	stats->txvlanframes_g +=
+		XGMAC_IOREAD(pdata, MMC_TXVLANFRAMES_G_LO);
+
+	stats->rxframecount_gb +=
+		XGMAC_IOREAD(pdata, MMC_RXFRAMECOUNT_GB_LO);
+
+	stats->rxoctetcount_gb +=
+		XGMAC_IOREAD(pdata, MMC_RXOCTETCOUNT_GB_LO);
+
+	stats->rxoctetcount_g +=
+		XGMAC_IOREAD(pdata, MMC_RXOCTETCOUNT_G_LO);
+
+	stats->rxbroadcastframes_g +=
+		XGMAC_IOREAD(pdata, MMC_RXBROADCASTFRAMES_G_LO);
+
+	stats->rxmulticastframes_g +=
+		XGMAC_IOREAD(pdata, MMC_RXMULTICASTFRAMES_G_LO);
+
+	stats->rxcrcerror +=
+		XGMAC_IOREAD(pdata, MMC_RXCRCERROR_LO);
+
+	stats->rxrunterror +=
+		XGMAC_IOREAD(pdata, MMC_RXRUNTERROR);
+
+	stats->rxjabbererror +=
+		XGMAC_IOREAD(pdata, MMC_RXJABBERERROR);
+
+	stats->rxundersize_g +=
+		XGMAC_IOREAD(pdata, MMC_RXUNDERSIZE_G);
+
+	stats->rxoversize_g +=
+		XGMAC_IOREAD(pdata, MMC_RXOVERSIZE_G);
+
+	stats->rx64octets_gb +=
+		XGMAC_IOREAD(pdata, MMC_RX64OCTETS_GB_LO);
+
+	stats->rx65to127octets_gb +=
+		XGMAC_IOREAD(pdata, MMC_RX65TO127OCTETS_GB_LO);
+
+	stats->rx128to255octets_gb +=
+		XGMAC_IOREAD(pdata, MMC_RX128TO255OCTETS_GB_LO);
+
+	stats->rx256to511octets_gb +=
+		XGMAC_IOREAD(pdata, MMC_RX256TO511OCTETS_GB_LO);
+
+	stats->rx512to1023octets_gb +=
+		XGMAC_IOREAD(pdata, MMC_RX512TO1023OCTETS_GB_LO);
+
+	stats->rx1024tomaxoctets_gb +=
+		XGMAC_IOREAD(pdata, MMC_RX1024TOMAXOCTETS_GB_LO);
+
+	stats->rxunicastframes_g +=
+		XGMAC_IOREAD(pdata, MMC_RXUNICASTFRAMES_G_LO);
+
+	stats->rxlengtherror +=
+		XGMAC_IOREAD(pdata, MMC_RXLENGTHERROR_LO);
+
+	stats->rxoutofrangetype +=
+		XGMAC_IOREAD(pdata, MMC_RXOUTOFRANGETYPE_LO);
+
+	stats->rxpauseframes +=
+		XGMAC_IOREAD(pdata, MMC_RXPAUSEFRAMES_LO);
+
+	stats->rxfifooverflow +=
+		XGMAC_IOREAD(pdata, MMC_RXFIFOOVERFLOW_LO);
+
+	stats->rxvlanframes_gb +=
+		XGMAC_IOREAD(pdata, MMC_RXVLANFRAMES_GB_LO);
+
+	stats->rxwatchdogerror +=
+		XGMAC_IOREAD(pdata, MMC_RXWATCHDOGERROR);
+
+	/* Un-freeze counters */
+	XGMAC_IOWRITE_BITS(pdata, MMC_CR, MCF, 0);
+}
+
+static void xgbe_config_mmc(struct xgbe_prv_data *pdata)
+{
+	/* Set counters to reset on read */
+	XGMAC_IOWRITE_BITS(pdata, MMC_CR, ROR, 1);
+
+	/* Reset the counters */
+	XGMAC_IOWRITE_BITS(pdata, MMC_CR, CR, 1);
+}
+
+static void xgbe_enable_tx(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_channel *channel;
+	unsigned int i;
+
+	/* Enable each Tx DMA channel */
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			break;
+
+		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_TCR, ST, 1);
+	}
+
+	/* Enable each Tx queue */
+	for (i = 0; i < pdata->hw_feat.tx_q_cnt; i++)
+		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_TQOMR, TXQEN,
+				       MTL_Q_ENABLED);
+
+	/* Enable MAC Tx */
+	XGMAC_IOWRITE_BITS(pdata, MAC_TCR, TE, 1);
+}
+
+static void xgbe_disable_tx(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_channel *channel;
+	unsigned int i;
+
+	/* Disable MAC Tx */
+	XGMAC_IOWRITE_BITS(pdata, MAC_TCR, TE, 0);
+
+	/* Disable each Tx queue */
+	for (i = 0; i < pdata->hw_feat.tx_q_cnt; i++)
+		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_Q_TQOMR, TXQEN, 0);
+
+	/* Disable each Tx DMA channel */
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			break;
+
+		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_TCR, ST, 0);
+	}
+}
+
+static void xgbe_enable_rx(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_channel *channel;
+	unsigned int reg_val, i;
+
+	/* Enable each Rx DMA channel */
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->rx_ring)
+			break;
+
+		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_RCR, SR, 1);
+	}
+
+	/* Enable each Rx queue */
+	reg_val = 0;
+	for (i = 0; i < pdata->hw_feat.rx_q_cnt; i++)
+		reg_val |= (0x02 << (i << 1));
+	XGMAC_IOWRITE(pdata, MAC_RQC0R, reg_val);
+
+	/* Enable MAC Rx */
+	XGMAC_IOWRITE_BITS(pdata, MAC_RCR, DCRCC, 1);
+	XGMAC_IOWRITE_BITS(pdata, MAC_RCR, CST, 1);
+	XGMAC_IOWRITE_BITS(pdata, MAC_RCR, ACS, 1);
+	XGMAC_IOWRITE_BITS(pdata, MAC_RCR, RE, 1);
+}
+
+static void xgbe_disable_rx(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_channel *channel;
+	unsigned int i;
+
+	/* Disable MAC Rx */
+	XGMAC_IOWRITE_BITS(pdata, MAC_RCR, DCRCC, 0);
+	XGMAC_IOWRITE_BITS(pdata, MAC_RCR, CST, 0);
+	XGMAC_IOWRITE_BITS(pdata, MAC_RCR, ACS, 0);
+	XGMAC_IOWRITE_BITS(pdata, MAC_RCR, RE, 0);
+
+	/* Disable each Rx queue */
+	XGMAC_IOWRITE(pdata, MAC_RQC0R, 0);
+
+	/* Disable each Rx DMA channel */
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->rx_ring)
+			break;
+
+		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_RCR, SR, 0);
+	}
+}
+
+static void xgbe_powerup_tx(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_channel *channel;
+	unsigned int i;
+
+	/* Enable each Tx DMA channel */
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			break;
+
+		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_TCR, ST, 1);
+	}
+
+	/* Enable MAC Tx */
+	XGMAC_IOWRITE_BITS(pdata, MAC_TCR, TE, 1);
+}
+
+static void xgbe_powerdown_tx(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_channel *channel;
+	unsigned int i;
+
+	/* Disable MAC Tx */
+	XGMAC_IOWRITE_BITS(pdata, MAC_TCR, TE, 0);
+
+	/* Disable each Tx DMA channel */
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			break;
+
+		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_TCR, ST, 0);
+	}
+}
+
+static void xgbe_powerup_rx(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_channel *channel;
+	unsigned int i;
+
+	/* Enable each Rx DMA channel */
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->rx_ring)
+			break;
+
+		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_RCR, SR, 1);
+	}
+}
+
+static void xgbe_powerdown_rx(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_channel *channel;
+	unsigned int i;
+
+	/* Disable each Rx DMA channel */
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->rx_ring)
+			break;
+
+		XGMAC_DMA_IOWRITE_BITS(channel, DMA_CH_RCR, SR, 0);
+	}
+}
+
+static int xgbe_init(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_desc_if *desc_if = &pdata->desc_if;
+	int ret;
+
+	DBGPR("-->xgbe_init\n");
+
+	/* Flush Tx queues */
+	ret = xgbe_flush_tx_queues(pdata);
+	if (ret)
+		return ret;
+
+	/*
+	 * Initialize DMA related features
+	 */
+	xgbe_config_dma_bus(pdata);
+	xgbe_config_dma_cache(pdata);
+	xgbe_config_osp_mode(pdata);
+	xgbe_config_pblx8(pdata);
+	xgbe_config_tx_pbl_val(pdata);
+	xgbe_config_rx_pbl_val(pdata);
+	xgbe_config_rx_coalesce(pdata);
+	xgbe_config_tx_coalesce(pdata);
+	xgbe_config_rx_buffer_size(pdata);
+	xgbe_config_tso_mode(pdata);
+	desc_if->wrapper_tx_desc_init(pdata);
+	desc_if->wrapper_rx_desc_init(pdata);
+	xgbe_enable_dma_interrupts(pdata);
+
+	/*
+	 * Initialize MTL related features
+	 */
+	xgbe_config_mtl_mode(pdata);
+	xgbe_config_rx_queue_mapping(pdata);
+	/*TODO: Program the priorities mapped to the Selected Traffic Classes
+		in MTL_TC_Prty_Map0-3 registers */
+	xgbe_config_tsf_mode(pdata, pdata->tx_sf_mode);
+	xgbe_config_rsf_mode(pdata, pdata->rx_sf_mode);
+	xgbe_config_tx_threshold(pdata, pdata->tx_threshold);
+	xgbe_config_rx_threshold(pdata, pdata->rx_threshold);
+	xgbe_config_tx_fifo_size(pdata);
+	xgbe_config_rx_fifo_size(pdata);
+	xgbe_config_flow_control_threshold(pdata);
+	/*TODO: Queue to Traffic Class Mapping (Q2TCMAP) */
+	/*TODO: Error Packet and undersized good Packet forwarding enable
+		(FEP and FUP)
+	 */
+	xgbe_enable_mtl_interrupts(pdata);
+
+	/* Transmit Class Weight */
+	XGMAC_IOWRITE_BITS(pdata, MTL_Q_TCQWR, QW, 0x10);
+
+	/*
+	 * Initialize MAC related features
+	 */
+	xgbe_config_mac_address(pdata);
+	xgbe_config_jumbo_enable(pdata);
+	xgbe_config_flow_control(pdata);
+	xgbe_config_checksum_offload(pdata);
+	xgbe_config_vlan_support(pdata);
+	xgbe_config_mmc(pdata);
+	xgbe_enable_mac_interrupts(pdata);
+
+	DBGPR("<--xgbe_init\n");
+
+	return 0;
+}
+
+void xgbe_init_function_ptrs_dev(struct xgbe_hw_if *hw_if)
+{
+	DBGPR("-->xgbe_init_function_ptrs\n");
+
+	hw_if->tx_complete = xgbe_tx_complete;
+
+	hw_if->set_promiscuous_mode = xgbe_set_promiscuous_mode;
+	hw_if->set_all_multicast_mode = xgbe_set_all_multicast_mode;
+	hw_if->set_addn_mac_addrs = xgbe_set_addn_mac_addrs;
+	hw_if->set_mac_address = xgbe_set_mac_address;
+
+	hw_if->enable_rx_csum = xgbe_enable_rx_csum;
+	hw_if->disable_rx_csum = xgbe_disable_rx_csum;
+
+	hw_if->enable_rx_vlan_stripping = xgbe_enable_rx_vlan_stripping;
+	hw_if->disable_rx_vlan_stripping = xgbe_disable_rx_vlan_stripping;
+
+	hw_if->read_mmd_regs = xgbe_read_mmd_regs;
+	hw_if->write_mmd_regs = xgbe_write_mmd_regs;
+
+	hw_if->set_gmii_speed = xgbe_set_gmii_speed;
+	hw_if->set_gmii_2500_speed = xgbe_set_gmii_2500_speed;
+	hw_if->set_xgmii_speed = xgbe_set_xgmii_speed;
+
+	hw_if->enable_tx = xgbe_enable_tx;
+	hw_if->disable_tx = xgbe_disable_tx;
+	hw_if->enable_rx = xgbe_enable_rx;
+	hw_if->disable_rx = xgbe_disable_rx;
+
+	hw_if->powerup_tx = xgbe_powerup_tx;
+	hw_if->powerdown_tx = xgbe_powerdown_tx;
+	hw_if->powerup_rx = xgbe_powerup_rx;
+	hw_if->powerdown_rx = xgbe_powerdown_rx;
+
+	hw_if->pre_xmit = xgbe_pre_xmit;
+	hw_if->dev_read = xgbe_dev_read;
+	hw_if->enable_int = xgbe_enable_int;
+	hw_if->disable_int = xgbe_disable_int;
+	hw_if->init = xgbe_init;
+	hw_if->exit = xgbe_exit;
+
+	/* Descriptor related Sequences have to be initialized here */
+	hw_if->tx_desc_init = xgbe_tx_desc_init;
+	hw_if->rx_desc_init = xgbe_rx_desc_init;
+	hw_if->tx_desc_reset = xgbe_tx_desc_reset;
+	hw_if->rx_desc_reset = xgbe_rx_desc_reset;
+	hw_if->is_last_desc = xgbe_is_last_desc;
+	hw_if->is_context_desc = xgbe_is_context_desc;
+
+	/* For FLOW ctrl */
+	hw_if->config_tx_flow_control = xgbe_config_tx_flow_control;
+	hw_if->config_rx_flow_control = xgbe_config_rx_flow_control;
+
+	/* For RX coalescing */
+	hw_if->config_rx_coalesce = xgbe_config_rx_coalesce;
+	hw_if->config_tx_coalesce = xgbe_config_tx_coalesce;
+	hw_if->usec_to_riwt = xgbe_usec_to_riwt;
+	hw_if->riwt_to_usec = xgbe_riwt_to_usec;
+
+	/* For RX and TX threshold config */
+	hw_if->config_rx_threshold = xgbe_config_rx_threshold;
+	hw_if->config_tx_threshold = xgbe_config_tx_threshold;
+
+	/* For RX and TX Store and Forward Mode config */
+	hw_if->config_rsf_mode = xgbe_config_rsf_mode;
+	hw_if->config_tsf_mode = xgbe_config_tsf_mode;
+
+	/* For TX DMA Operating on Second Frame config */
+	hw_if->config_osp_mode = xgbe_config_osp_mode;
+
+	/* For RX and TX PBL config */
+	hw_if->config_rx_pbl_val = xgbe_config_rx_pbl_val;
+	hw_if->get_rx_pbl_val = xgbe_get_rx_pbl_val;
+	hw_if->config_tx_pbl_val = xgbe_config_tx_pbl_val;
+	hw_if->get_tx_pbl_val = xgbe_get_tx_pbl_val;
+	hw_if->config_pblx8 = xgbe_config_pblx8;
+
+	/* For MMC statistics support */
+	hw_if->tx_mmc_int = xgbe_tx_mmc_int;
+	hw_if->rx_mmc_int = xgbe_rx_mmc_int;
+	hw_if->read_mmc_stats = xgbe_read_mmc_stats;
+
+	DBGPR("<--xgbe_init_function_ptrs\n");
+}
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
new file mode 100644
index 0000000..cfe3d93
--- /dev/null
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -0,0 +1,1351 @@
+/*
+ * AMD 10Gb Ethernet driver
+ *
+ * This file is available to you under your choice of the following two
+ * licenses:
+ *
+ * License 1: GPLv2
+ *
+ * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ *
+ * This file is free software; you may copy, redistribute and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation, either version 2 of the License, or (at
+ * your option) any later version.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ *
+ * This file incorporates work covered by the following copyright and
+ * permission notice:
+ *     The Synopsys DWC ETHER XGMAC Software Driver and documentation
+ *     (hereinafter "Software") is an unsupported proprietary work of Synopsys,
+ *     Inc. unless otherwise expressly agreed to in writing between Synopsys
+ *     and you.
+ *
+ *     The Software IS NOT an item of Licensed Software or Licensed Product
+ *     under any End User Software License Agreement or Agreement for Licensed
+ *     Product with Synopsys or any supplement thereto.  Permission is hereby
+ *     granted, free of charge, to any person obtaining a copy of this software
+ *     annotated with this license and the Software, to deal in the Software
+ *     without restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or sell copies
+ *     of the Software, and to permit persons to whom the Software is furnished
+ *     to do so, subject to the following conditions:
+ *
+ *     The above copyright notice and this permission notice shall be included
+ *     in all copies or substantial portions of the Software.
+ *
+ *     THIS SOFTWARE IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN "AS IS"
+ *     BASIS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
+ *     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+ *     PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS
+ *     BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ *     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
+ *     THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ *
+ * License 2: Modified BSD
+ *
+ * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ * All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Advanced Micro Devices, Inc. nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
+ * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ * This file incorporates work covered by the following copyright and
+ * permission notice:
+ *     The Synopsys DWC ETHER XGMAC Software Driver and documentation
+ *     (hereinafter "Software") is an unsupported proprietary work of Synopsys,
+ *     Inc. unless otherwise expressly agreed to in writing between Synopsys
+ *     and you.
+ *
+ *     The Software IS NOT an item of Licensed Software or Licensed Product
+ *     under any End User Software License Agreement or Agreement for Licensed
+ *     Product with Synopsys or any supplement thereto.  Permission is hereby
+ *     granted, free of charge, to any person obtaining a copy of this software
+ *     annotated with this license and the Software, to deal in the Software
+ *     without restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or sell copies
+ *     of the Software, and to permit persons to whom the Software is furnished
+ *     to do so, subject to the following conditions:
+ *
+ *     The above copyright notice and this permission notice shall be included
+ *     in all copies or substantial portions of the Software.
+ *
+ *     THIS SOFTWARE IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN "AS IS"
+ *     BASIS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
+ *     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+ *     PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS
+ *     BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ *     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
+ *     THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <linux/spinlock.h>
+#include <linux/tcp.h>
+#include <linux/if_vlan.h>
+#include <linux/phy.h>
+#include <net/busy_poll.h>
+#include <linux/clk.h>
+#include <linux/if_ether.h>
+
+#include "xgbe.h"
+#include "xgbe-common.h"
+
+
+static int xgbe_poll(struct napi_struct *, int);
+static void xgbe_set_rx_mode(struct net_device *);
+
+static inline unsigned int xgbe_tx_avail_desc(struct xgbe_ring *ring)
+{
+	return (ring->rdesc_count - (ring->cur - ring->dirty));
+}
+
+static int xgbe_calc_rx_buf_size(struct net_device *netdev, unsigned int mtu)
+{
+	unsigned int rx_buf_size;
+
+	if (mtu > XGMAC_JUMBO_PACKET_MTU) {
+		netdev_alert(netdev, "MTU exceeds maximum supported value\n");
+		return -EINVAL;
+	}
+
+	rx_buf_size = mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
+	if (rx_buf_size < RX_MIN_BUF_SIZE)
+		rx_buf_size = RX_MIN_BUF_SIZE;
+	rx_buf_size = (rx_buf_size + RX_BUF_ALIGN - 1) & ~(RX_BUF_ALIGN - 1);
+
+	return rx_buf_size;
+}
+
+static void xgbe_enable_rx_tx_ints(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_hw_if *hw_if = &pdata->hw_if;
+	struct xgbe_channel *channel;
+	unsigned int i;
+
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (channel->tx_ring)
+			hw_if->enable_int(channel,
+					  XGMAC_INT_DMA_CH_SR_TI);
+		if (channel->rx_ring)
+			hw_if->enable_int(channel,
+					  XGMAC_INT_DMA_CH_SR_RI);
+	}
+}
+
+static void xgbe_disable_rx_tx_ints(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_hw_if *hw_if = &pdata->hw_if;
+	struct xgbe_channel *channel;
+	unsigned int i;
+
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (channel->tx_ring)
+			hw_if->disable_int(channel,
+					   XGMAC_INT_DMA_CH_SR_TI);
+		if (channel->rx_ring)
+			hw_if->disable_int(channel,
+					   XGMAC_INT_DMA_CH_SR_RI);
+	}
+}
+
+static irqreturn_t xgbe_isr(int irq, void *data)
+{
+	struct xgbe_prv_data *pdata = data;
+	struct xgbe_hw_if *hw_if = &pdata->hw_if;
+	struct xgbe_channel *channel;
+	unsigned int dma_isr, dma_ch_isr;
+	unsigned int mac_isr;
+	unsigned int i;
+
+	/* The DMA interrupt status register also reports MAC and MTL
+	 * interrupts. So for polling mode, we just need to check for
+	 * this register to be non-zero
+	 */
+	dma_isr = XGMAC_IOREAD(pdata, DMA_ISR);
+	if (!dma_isr)
+		goto isr_done;
+
+	DBGPR("-->xgbe_isr\n");
+
+	DBGPR("  DMA_ISR = %08x\n", dma_isr);
+	DBGPR("  DMA_DS0 = %08x\n", XGMAC_IOREAD(pdata, DMA_DSR0));
+	DBGPR("  DMA_DS1 = %08x\n", XGMAC_IOREAD(pdata, DMA_DSR1));
+
+	for (i = 0; i < pdata->channel_count; i++) {
+		if (!(dma_isr & (1 << i)))
+			continue;
+
+		channel = pdata->channel + i;
+
+		dma_ch_isr = XGMAC_DMA_IOREAD(channel, DMA_CH_SR);
+		DBGPR("  DMA_CH%u_ISR = %08x\n", i, dma_ch_isr);
+
+		if (XGMAC_GET_BITS(dma_ch_isr, DMA_CH_SR, TI) ||
+		    XGMAC_GET_BITS(dma_ch_isr, DMA_CH_SR, RI)) {
+			if (napi_schedule_prep(&pdata->napi)) {
+				/* Disable Tx and Rx interrupts */
+				xgbe_disable_rx_tx_ints(pdata);
+
+				/* Turn on polling */
+				__napi_schedule(&pdata->napi);
+			}
+		}
+
+		/* Restart the device on a Fatal Bus Error */
+		if (XGMAC_GET_BITS(dma_ch_isr, DMA_CH_SR, FBE))
+			schedule_work(&pdata->restart_work);
+
+		/* Clear all interrupt signals */
+		XGMAC_DMA_IOWRITE(channel, DMA_CH_SR, dma_ch_isr);
+	}
+
+	if (XGMAC_GET_BITS(dma_isr, DMA_ISR, MACIS)) {
+		mac_isr = XGMAC_IOREAD(pdata, MAC_ISR);
+
+		if (XGMAC_GET_BITS(mac_isr, MAC_ISR, MMCTXIS))
+			hw_if->tx_mmc_int(pdata);
+
+		if (XGMAC_GET_BITS(mac_isr, MAC_ISR, MMCRXIS))
+			hw_if->rx_mmc_int(pdata);
+	}
+
+	DBGPR("  DMA_ISR = %08x\n", XGMAC_IOREAD(pdata, DMA_ISR));
+
+	DBGPR("<--xgbe_isr\n");
+
+isr_done:
+	return IRQ_HANDLED;
+}
+
+static enum hrtimer_restart xgbe_tx_timer(struct hrtimer *timer)
+{
+	struct xgbe_channel *channel = container_of(timer,
+						    struct xgbe_channel,
+						    tx_timer);
+	struct xgbe_ring *ring = channel->tx_ring;
+	struct xgbe_prv_data *pdata = channel->pdata;
+	unsigned long flags;
+
+	DBGPR("-->xgbe_tx_timer\n");
+
+	spin_lock_irqsave(&ring->lock, flags);
+
+	if (napi_schedule_prep(&pdata->napi)) {
+		/* Disable Tx and Rx interrupts */
+		xgbe_disable_rx_tx_ints(pdata);
+
+		/* Turn on polling */
+		__napi_schedule(&pdata->napi);
+	}
+
+	channel->tx_timer_active = 0;
+
+	spin_unlock_irqrestore(&ring->lock, flags);
+
+	DBGPR("<--xgbe_tx_timer\n");
+
+	return HRTIMER_NORESTART;
+}
+
+static void xgbe_init_tx_timers(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_channel *channel;
+	unsigned int i;
+
+	DBGPR("-->xgbe_init_tx_timers\n");
+
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			break;
+
+		DBGPR("  %s adding tx timer\n", channel->name);
+		hrtimer_init(&channel->tx_timer, CLOCK_MONOTONIC,
+			     HRTIMER_MODE_REL);
+		channel->tx_timer.function = xgbe_tx_timer;
+	}
+
+	DBGPR("<--xgbe_init_tx_timers\n");
+}
+
+static void xgbe_stop_tx_timers(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_channel *channel;
+	unsigned int i;
+
+	DBGPR("-->xgbe_stop_tx_timers\n");
+
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		if (!channel->tx_ring)
+			break;
+
+		DBGPR("  %s deleting tx timer\n", channel->name);
+		channel->tx_timer_active = 0;
+		hrtimer_cancel(&channel->tx_timer);
+	}
+
+	DBGPR("<--xgbe_stop_tx_timers\n");
+}
+
+void xgbe_get_all_hw_features(struct xgbe_prv_data *pdata)
+{
+	unsigned int mac_hfr0, mac_hfr1, mac_hfr2;
+	struct xgbe_hw_features *hw_feat = &pdata->hw_feat;
+
+	DBGPR("-->xgbe_get_all_hw_features\n");
+
+	mac_hfr0 = XGMAC_IOREAD(pdata, MAC_HWF0R);
+	mac_hfr1 = XGMAC_IOREAD(pdata, MAC_HWF1R);
+	mac_hfr2 = XGMAC_IOREAD(pdata, MAC_HWF2R);
+
+	memset(hw_feat, 0, sizeof(*hw_feat));
+
+	/* Hardware feature register 0 */
+	hw_feat->gmii        = XGMAC_GET_BITS(mac_hfr0, MAC_HWF0R, GMIISEL);
+	hw_feat->vlhash      = XGMAC_GET_BITS(mac_hfr0, MAC_HWF0R, VLHASH);
+	hw_feat->sma         = XGMAC_GET_BITS(mac_hfr0, MAC_HWF0R, SMASEL);
+	hw_feat->rwk         = XGMAC_GET_BITS(mac_hfr0, MAC_HWF0R, RWKSEL);
+	hw_feat->mgk         = XGMAC_GET_BITS(mac_hfr0, MAC_HWF0R, MGKSEL);
+	hw_feat->mmc         = XGMAC_GET_BITS(mac_hfr0, MAC_HWF0R, MMCSEL);
+	hw_feat->aoe         = XGMAC_GET_BITS(mac_hfr0, MAC_HWF0R, ARPOFFSEL);
+	hw_feat->ts          = XGMAC_GET_BITS(mac_hfr0, MAC_HWF0R, TSSEL);
+	hw_feat->eee         = XGMAC_GET_BITS(mac_hfr0, MAC_HWF0R, EEESEL);
+	hw_feat->tx_coe      = XGMAC_GET_BITS(mac_hfr0, MAC_HWF0R, TXCOESEL);
+	hw_feat->rx_coe      = XGMAC_GET_BITS(mac_hfr0, MAC_HWF0R, RXCOESEL);
+	hw_feat->addn_mac    = XGMAC_GET_BITS(mac_hfr0, MAC_HWF0R,
+					      ADDMACADRSEL);
+	hw_feat->ts_src      = XGMAC_GET_BITS(mac_hfr0, MAC_HWF0R, TSSTSSEL);
+	hw_feat->sa_vlan_ins = XGMAC_GET_BITS(mac_hfr0, MAC_HWF0R, SAVLANINS);
+
+	/* Hardware feature register 1 */
+	hw_feat->rx_fifo_size  = XGMAC_GET_BITS(mac_hfr1, MAC_HWF1R,
+						RXFIFOSIZE);
+	hw_feat->tx_fifo_size  = XGMAC_GET_BITS(mac_hfr1, MAC_HWF1R,
+						TXFIFOSIZE);
+	hw_feat->dcb           = XGMAC_GET_BITS(mac_hfr1, MAC_HWF1R, DCBEN);
+	hw_feat->sph           = XGMAC_GET_BITS(mac_hfr1, MAC_HWF1R, SPHEN);
+	hw_feat->tso           = XGMAC_GET_BITS(mac_hfr1, MAC_HWF1R, TSOEN);
+	hw_feat->dma_debug     = XGMAC_GET_BITS(mac_hfr1, MAC_HWF1R, DBGMEMA);
+	hw_feat->hash_table_size = XGMAC_GET_BITS(mac_hfr1, MAC_HWF1R,
+						  HASHTBLSZ);
+	hw_feat->l3l4_filter_num = XGMAC_GET_BITS(mac_hfr1, MAC_HWF1R,
+						  L3L4FNUM);
+
+	/* Hardware feature register 2 */
+	hw_feat->rx_q_cnt     = XGMAC_GET_BITS(mac_hfr2, MAC_HWF2R, RXQCNT);
+	hw_feat->tx_q_cnt     = XGMAC_GET_BITS(mac_hfr2, MAC_HWF2R, TXQCNT);
+	hw_feat->rx_ch_cnt    = XGMAC_GET_BITS(mac_hfr2, MAC_HWF2R, RXCHCNT);
+	hw_feat->tx_ch_cnt    = XGMAC_GET_BITS(mac_hfr2, MAC_HWF2R, TXCHCNT);
+	hw_feat->pps_out_num  = XGMAC_GET_BITS(mac_hfr2, MAC_HWF2R, PPSOUTNUM);
+	hw_feat->aux_snap_num = XGMAC_GET_BITS(mac_hfr2, MAC_HWF2R, AUXSNAPNUM);
+
+	/* The Queue and Channel counts are zero based so increment them
+	 * to get the actual number
+	 */
+	hw_feat->rx_q_cnt++;
+	hw_feat->tx_q_cnt++;
+	hw_feat->rx_ch_cnt++;
+	hw_feat->tx_ch_cnt++;
+
+	DBGPR("<--xgbe_get_all_hw_features\n");
+}
+
+static void xgbe_napi_enable(struct xgbe_prv_data *pdata, unsigned int add)
+{
+	if (add)
+		netif_napi_add(pdata->netdev, &pdata->napi, xgbe_poll,
+			       NAPI_POLL_WEIGHT);
+	napi_enable(&pdata->napi);
+}
+
+static void xgbe_napi_disable(struct xgbe_prv_data *pdata)
+{
+	napi_disable(&pdata->napi);
+}
+
+void xgbe_init_tx_coalesce(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_hw_if *hw_if = &pdata->hw_if;
+
+	DBGPR("-->xgbe_init_tx_coalesce\n");
+
+	pdata->tx_usecs = XGMAC_INIT_DMA_TX_USECS;
+	pdata->tx_frames = XGMAC_INIT_DMA_TX_FRAMES;
+
+	hw_if->config_tx_coalesce(pdata);
+
+	DBGPR("<--xgbe_init_tx_coalesce\n");
+}
+
+void xgbe_init_rx_coalesce(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_hw_if *hw_if = &pdata->hw_if;
+
+	DBGPR("-->xgbe_init_rx_coalesce\n");
+
+	pdata->rx_riwt = hw_if->usec_to_riwt(pdata, XGMAC_INIT_DMA_RX_USECS);
+	pdata->rx_frames = XGMAC_INIT_DMA_RX_FRAMES;
+
+	hw_if->config_rx_coalesce(pdata);
+
+	DBGPR("<--xgbe_init_rx_coalesce\n");
+}
+
+static void xgbe_free_tx_skbuff(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_desc_if *desc_if = &pdata->desc_if;
+	struct xgbe_channel *channel;
+	struct xgbe_ring *ring;
+	struct xgbe_ring_data *rdata;
+	unsigned int i, j;
+
+	DBGPR("-->xgbe_free_tx_skbuff\n");
+
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		ring = channel->tx_ring;
+		if (!ring)
+			break;
+
+		for (j = 0; j < ring->rdesc_count; j++) {
+			rdata = GET_DESC_DATA(ring, j);
+			desc_if->unmap_skb(pdata, rdata);
+		}
+	}
+
+	DBGPR("<--xgbe_free_tx_skbuff\n");
+}
+
+static void xgbe_free_rx_skbuff(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_desc_if *desc_if = &pdata->desc_if;
+	struct xgbe_channel *channel;
+	struct xgbe_ring *ring;
+	struct xgbe_ring_data *rdata;
+	unsigned int i, j;
+
+	DBGPR("-->xgbe_free_rx_skbuff\n");
+
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++) {
+		ring = channel->rx_ring;
+		if (!ring)
+			break;
+
+		for (j = 0; j < ring->rdesc_count; j++) {
+			rdata = GET_DESC_DATA(ring, j);
+			desc_if->unmap_skb(pdata, rdata);
+		}
+	}
+
+	DBGPR("<--xgbe_free_rx_skbuff\n");
+}
+
+int xgbe_powerdown(struct net_device *netdev, unsigned int caller)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+	struct xgbe_hw_if *hw_if = &pdata->hw_if;
+	unsigned long flags;
+
+	DBGPR("-->xgbe_powerdown\n");
+
+	if (!netif_running(netdev) ||
+	    (caller == XGMAC_IOCTL_CONTEXT && pdata->power_down)) {
+		netdev_alert(netdev, "Device is already powered down\n");
+		DBGPR("<--xgbe_powerdown\n");
+		return -EINVAL;
+	}
+
+	phy_stop(pdata->phydev);
+
+	spin_lock_irqsave(&pdata->lock, flags);
+
+	if (caller == XGMAC_DRIVER_CONTEXT)
+		netif_device_detach(netdev);
+
+	netif_tx_stop_all_queues(netdev);
+	xgbe_napi_disable(pdata);
+
+	/* Powerdown Tx/Rx */
+	hw_if->powerdown_tx(pdata);
+	hw_if->powerdown_rx(pdata);
+
+	pdata->power_down = 1;
+
+	spin_unlock_irqrestore(&pdata->lock, flags);
+
+	DBGPR("<--xgbe_powerdown\n");
+
+	return 0;
+}
+
+int xgbe_powerup(struct net_device *netdev, unsigned int caller)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+	struct xgbe_hw_if *hw_if = &pdata->hw_if;
+	unsigned long flags;
+
+	DBGPR("-->xgbe_powerup\n");
+
+	if (!netif_running(netdev) ||
+	    (caller == XGMAC_IOCTL_CONTEXT && !pdata->power_down)) {
+		netdev_alert(netdev, "Device is already powered up\n");
+		DBGPR("<--xgbe_powerup\n");
+		return -EINVAL;
+	}
+
+	spin_lock_irqsave(&pdata->lock, flags);
+
+	pdata->power_down = 0;
+
+	phy_start(pdata->phydev);
+
+	/* Enable Tx/Rx */
+	hw_if->powerup_tx(pdata);
+	hw_if->powerup_rx(pdata);
+
+	if (caller == XGMAC_DRIVER_CONTEXT)
+		netif_device_attach(netdev);
+
+	xgbe_napi_enable(pdata, 0);
+	netif_tx_start_all_queues(netdev);
+
+	spin_unlock_irqrestore(&pdata->lock, flags);
+
+	DBGPR("<--xgbe_powerup\n");
+
+	return 0;
+}
+
+static int xgbe_start(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_hw_if *hw_if = &pdata->hw_if;
+	struct net_device *netdev = pdata->netdev;
+
+	DBGPR("-->xgbe_start\n");
+
+	xgbe_set_rx_mode(netdev);
+
+	hw_if->init(pdata);
+
+	phy_start(pdata->phydev);
+
+	hw_if->enable_tx(pdata);
+	hw_if->enable_rx(pdata);
+
+	xgbe_init_tx_timers(pdata);
+
+	xgbe_napi_enable(pdata, 1);
+	netif_tx_start_all_queues(netdev);
+
+	DBGPR("<--xgbe_start\n");
+
+	return 0;
+}
+
+static void xgbe_stop(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_hw_if *hw_if = &pdata->hw_if;
+	struct net_device *netdev = pdata->netdev;
+
+	DBGPR("-->xgbe_stop\n");
+
+	phy_stop(pdata->phydev);
+
+	netif_tx_stop_all_queues(netdev);
+	xgbe_napi_disable(pdata);
+
+	xgbe_stop_tx_timers(pdata);
+
+	hw_if->disable_tx(pdata);
+	hw_if->disable_rx(pdata);
+
+	DBGPR("<--xgbe_stop\n");
+}
+
+static void xgbe_restart_dev(struct xgbe_prv_data *pdata, unsigned int reset)
+{
+	struct xgbe_hw_if *hw_if = &pdata->hw_if;
+
+	DBGPR("-->xgbe_restart_dev\n");
+
+	/* If not running, "restart" will happen on open */
+	if (!netif_running(pdata->netdev))
+		return;
+
+	xgbe_stop(pdata);
+	synchronize_irq(pdata->irq_number);
+
+	xgbe_free_tx_skbuff(pdata);
+	xgbe_free_rx_skbuff(pdata);
+
+	/* Issue software reset to device if requested */
+	if (reset)
+		hw_if->exit(pdata);
+
+	xgbe_start(pdata);
+
+	DBGPR("<--xgbe_restart_dev\n");
+}
+
+static void xgbe_restart(struct work_struct *work)
+{
+	struct xgbe_prv_data *pdata = container_of(work,
+						   struct xgbe_prv_data,
+						   restart_work);
+
+	rtnl_lock();
+
+	xgbe_restart_dev(pdata, 1);
+
+	rtnl_unlock();
+}
+
+static void xgbe_prep_vlan(struct sk_buff *skb, struct xgbe_packet_data *packet)
+{
+	if (vlan_tx_tag_present(skb))
+		packet->vlan_ctag = vlan_tx_tag_get(skb);
+}
+
+static int xgbe_prep_tso(struct sk_buff *skb, struct xgbe_packet_data *packet)
+{
+	int ret;
+
+	if (!XGMAC_GET_BITS(packet->attributes, TX_PACKET_ATTRIBUTES,
+			    TSO_ENABLE))
+		return 0;
+
+	ret = skb_cow_head(skb, 0);
+	if (ret)
+		return ret;
+
+	packet->header_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
+	packet->tcp_header_len = tcp_hdrlen(skb);
+	packet->tcp_payload_len = skb->len - packet->header_len;
+	packet->mss = skb_shinfo(skb)->gso_size;
+	DBGPR("  packet->header_len=%u\n", packet->header_len);
+	DBGPR("  packet->tcp_header_len=%u, packet->tcp_payload_len=%u\n",
+	      packet->tcp_header_len, packet->tcp_payload_len);
+	DBGPR("  packet->mss=%u\n", packet->mss);
+
+	return 0;
+}
+
+static int xgbe_is_tso(struct sk_buff *skb)
+{
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		return 0;
+
+	if (!skb_is_gso(skb))
+		return 0;
+
+	DBGPR("  TSO packet to be processed\n");
+
+	return 1;
+}
+
+static void xgbe_packet_info(struct xgbe_ring *ring, struct sk_buff *skb,
+			     struct xgbe_packet_data *packet)
+{
+	struct skb_frag_struct *frag;
+	unsigned int context_desc;
+	unsigned int len;
+	unsigned int i;
+
+	context_desc = 0;
+	packet->rdesc_count = 0;
+
+	if (xgbe_is_tso(skb)) {
+		/* TSO requires an extra desriptor if mss is different */
+		if (skb_shinfo(skb)->gso_size != ring->tx.cur_mss) {
+			context_desc = 1;
+			packet->rdesc_count++;
+		}
+
+		/* TSO requires an extra desriptor for TSO header */
+		packet->rdesc_count++;
+
+		XGMAC_SET_BITS(packet->attributes, TX_PACKET_ATTRIBUTES,
+			       TSO_ENABLE, 1);
+		XGMAC_SET_BITS(packet->attributes, TX_PACKET_ATTRIBUTES,
+			       CSUM_ENABLE, 1);
+	} else if (skb->ip_summed == CHECKSUM_PARTIAL)
+		XGMAC_SET_BITS(packet->attributes, TX_PACKET_ATTRIBUTES,
+			       CSUM_ENABLE, 1);
+
+	if (vlan_tx_tag_present(skb)) {
+		/* VLAN requires an extra descriptor if tag is different */
+		if (vlan_tx_tag_get(skb) != ring->tx.cur_vlan_ctag)
+			/* We can share with the TSO context descriptor */
+			if (!context_desc) {
+				context_desc = 1;
+				packet->rdesc_count++;
+			}
+
+		XGMAC_SET_BITS(packet->attributes, TX_PACKET_ATTRIBUTES,
+			       VLAN_CTAG, 1);
+	}
+
+	for (len = skb_headlen(skb); len;) {
+		packet->rdesc_count++;
+		len -= min_t(unsigned int, len, TX_MAX_BUF_SIZE);
+	}
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		frag = &skb_shinfo(skb)->frags[i];
+		for (len = skb_frag_size(frag); len; ) {
+			packet->rdesc_count++;
+			len -= min_t(unsigned int, len, TX_MAX_BUF_SIZE);
+		}
+	}
+}
+
+static int xgbe_open(struct net_device *netdev)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+	struct xgbe_hw_if *hw_if = &pdata->hw_if;
+	struct xgbe_desc_if *desc_if = &pdata->desc_if;
+	int ret;
+
+	DBGPR("-->xgbe_open\n");
+
+	/* Enable the clock */
+	ret = clk_prepare_enable(pdata->sysclock);
+	if (ret) {
+		netdev_alert(netdev, "clk_prepare_enable failed\n");
+		return ret;
+	}
+
+	/* Calculate the Rx buffer size before allocating rings */
+	ret = xgbe_calc_rx_buf_size(netdev, netdev->mtu);
+	if (ret < 0)
+		goto err_clk;
+	pdata->rx_buf_size = ret;
+
+	/* Allocate the ring descriptors and buffers */
+	ret = desc_if->alloc_ring_resources(pdata);
+	if (ret)
+		goto err_clk;
+
+	/* Initialize the device restart work struct */
+	INIT_WORK(&pdata->restart_work, xgbe_restart);
+
+	/* Request interrupts */
+	ret = devm_request_irq(pdata->dev, netdev->irq, xgbe_isr, 0,
+			       netdev->name, pdata);
+	if (ret) {
+		netdev_alert(netdev, "error requesting irq %d\n",
+			     pdata->irq_number);
+		goto err_irq;
+	}
+	pdata->irq_number = netdev->irq;
+
+	ret = xgbe_start(pdata);
+	if (ret)
+		goto err_start;
+
+	DBGPR("<--xgbe_open\n");
+
+	return 0;
+
+err_start:
+	hw_if->exit(pdata);
+
+	devm_free_irq(pdata->dev, pdata->irq_number, pdata);
+	pdata->irq_number = 0;
+
+err_irq:
+	desc_if->free_ring_resources(pdata);
+
+err_clk:
+	clk_disable_unprepare(pdata->sysclock);
+
+	return ret;
+}
+
+static int xgbe_close(struct net_device *netdev)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+	struct xgbe_hw_if *hw_if = &pdata->hw_if;
+	struct xgbe_desc_if *desc_if = &pdata->desc_if;
+
+	DBGPR("-->xgbe_close\n");
+
+	/* Stop the device */
+	xgbe_stop(pdata);
+
+	/* Issue software reset to device */
+	hw_if->exit(pdata);
+
+	/* Free all the ring data */
+	desc_if->free_ring_resources(pdata);
+
+	/* Release the interrupt */
+	if (pdata->irq_number != 0) {
+		devm_free_irq(pdata->dev, pdata->irq_number, pdata);
+		pdata->irq_number = 0;
+	}
+
+	/* Disable the clock */
+	clk_disable_unprepare(pdata->sysclock);
+
+	DBGPR("<--xgbe_close\n");
+
+	return 0;
+}
+
+static int xgbe_xmit(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+	struct xgbe_hw_if *hw_if = &pdata->hw_if;
+	struct xgbe_desc_if *desc_if = &pdata->desc_if;
+	struct xgbe_channel *channel;
+	struct xgbe_ring *ring;
+	struct xgbe_packet_data *packet;
+	unsigned long flags;
+	int ret;
+
+	DBGPR("-->xgbe_xmit: skb->len = %d\n", skb->len);
+
+	channel = pdata->channel + skb->queue_mapping;
+	ring = channel->tx_ring;
+	packet = &ring->packet_data;
+
+	ret = NETDEV_TX_OK;
+
+	spin_lock_irqsave(&ring->lock, flags);
+
+	if (skb->len == 0) {
+		netdev_err(netdev, "empty skb received from stack\n");
+		dev_kfree_skb_any(skb);
+		goto tx_netdev_return;
+	}
+
+	/* Calculate preliminary packet info */
+	memset(packet, 0, sizeof(*packet));
+	xgbe_packet_info(ring, skb, packet);
+
+	/* Check that there are enough descriptors available */
+	if (packet->rdesc_count > xgbe_tx_avail_desc(ring)) {
+		DBGPR("  Tx queue stopped, not enough descriptors available\n");
+		netif_stop_subqueue(netdev, channel->queue_index);
+		ring->tx.queue_stopped = 1;
+		ret = NETDEV_TX_BUSY;
+		goto tx_netdev_return;
+	}
+
+	ret = xgbe_prep_tso(skb, packet);
+	if (ret) {
+		netdev_err(netdev, "error processing TSO packet\n");
+		dev_kfree_skb_any(skb);
+		goto tx_netdev_return;
+	}
+	xgbe_prep_vlan(skb, packet);
+
+	if (!desc_if->map_tx_skb(channel, skb)) {
+		dev_kfree_skb_any(skb);
+		goto tx_netdev_return;
+	}
+
+	/* Configure required descriptor fields for transmission */
+	hw_if->pre_xmit(channel);
+
+#ifdef XGMAC_ENABLE_TX_PKT_DUMP
+	xgbe_print_pkt(netdev, skb, true);
+#endif
+
+tx_netdev_return:
+	spin_unlock_irqrestore(&ring->lock, flags);
+
+	DBGPR("<--xgbe_xmit\n");
+
+	return ret;
+}
+
+static void xgbe_set_rx_mode(struct net_device *netdev)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+	struct xgbe_hw_if *hw_if = &pdata->hw_if;
+	unsigned int pr_mode, am_mode;
+
+	DBGPR("-->xgbe_set_rx_mode\n");
+
+	pr_mode = ((netdev->flags & IFF_PROMISC) != 0);
+	am_mode = ((netdev->flags & IFF_ALLMULTI) != 0);
+
+	if (netdev_uc_count(netdev) > pdata->hw_feat.addn_mac)
+		pr_mode = 1;
+	if (netdev_mc_count(netdev) > pdata->hw_feat.addn_mac)
+		am_mode = 1;
+	if ((netdev_uc_count(netdev) + netdev_mc_count(netdev)) >
+	     pdata->hw_feat.addn_mac)
+		pr_mode = 1;
+
+	hw_if->set_promiscuous_mode(pdata, pr_mode);
+	hw_if->set_all_multicast_mode(pdata, am_mode);
+	if (!pr_mode)
+		hw_if->set_addn_mac_addrs(pdata, am_mode);
+
+	DBGPR("<--xgbe_set_rx_mode\n");
+}
+
+static int xgbe_set_mac_address(struct net_device *netdev, void *addr)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+	struct xgbe_hw_if *hw_if = &pdata->hw_if;
+	struct sockaddr *saddr = addr;
+
+	DBGPR("-->xgbe_set_mac_address\n");
+
+	if (!is_valid_ether_addr(saddr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	memcpy(netdev->dev_addr, saddr->sa_data, netdev->addr_len);
+
+	hw_if->set_mac_address(pdata, netdev->dev_addr);
+
+	DBGPR("<--xgbe_set_mac_address\n");
+
+	return 0;
+}
+
+static int xgbe_change_mtu(struct net_device *netdev, int mtu)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+	int ret;
+
+	DBGPR("-->xgbe_change_mtu\n");
+
+	ret = xgbe_calc_rx_buf_size(netdev, mtu);
+	if (ret < 0)
+		return ret;
+
+	pdata->rx_buf_size = ret;
+	netdev->mtu = mtu;
+
+	xgbe_restart_dev(pdata, 0);
+
+	DBGPR("<--xgbe_change_mtu\n");
+
+	return 0;
+}
+
+static struct rtnl_link_stats64 *xgbe_get_stats64(struct net_device *netdev,
+						  struct rtnl_link_stats64 *s)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+	struct xgbe_mmc_stats *pstats = &pdata->mmc_stats;
+
+	DBGPR("-->%s\n", __func__);
+
+	pdata->hw_if.read_mmc_stats(pdata);
+
+	s->rx_packets = pstats->rxframecount_gb;
+	s->rx_bytes = pstats->rxoctetcount_gb;
+	s->rx_errors = pstats->rxframecount_gb -
+		       pstats->rxbroadcastframes_g -
+		       pstats->rxmulticastframes_g -
+		       pstats->rxunicastframes_g;
+	s->multicast = pstats->rxmulticastframes_g;
+	s->rx_length_errors = pstats->rxlengtherror;
+	s->rx_crc_errors = pstats->rxcrcerror;
+	s->rx_fifo_errors = pstats->rxfifooverflow;
+
+	s->tx_packets = pstats->txframecount_gb;
+	s->tx_bytes = pstats->txoctetcount_gb;
+	s->tx_errors = pstats->txframecount_gb - pstats->txframecount_g;
+	s->tx_dropped = netdev->stats.tx_dropped;
+
+	DBGPR("<--%s\n", __func__);
+
+	return s;
+}
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void xgbe_poll_controller(struct net_device *netdev)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+
+	DBGPR("-->xgbe_poll_controller\n");
+
+	disable_irq(pdata->irq_number);
+
+	xgbe_isr(pdata->irq_number, pdata);
+
+	enable_irq(pdata->irq_number);
+
+	DBGPR("<--xgbe_poll_controller\n");
+}
+#endif /* End CONFIG_NET_POLL_CONTROLLER */
+
+static int xgbe_set_features(struct net_device *netdev,
+			     netdev_features_t features)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+	struct xgbe_hw_if *hw_if = &pdata->hw_if;
+	unsigned int rxcsum_enabled, rxvlan_enabled;
+
+	rxcsum_enabled = !!(pdata->netdev_features & NETIF_F_RXCSUM);
+	rxvlan_enabled = !!(pdata->netdev_features & NETIF_F_HW_VLAN_CTAG_RX);
+
+	if ((features & NETIF_F_RXCSUM) && !rxcsum_enabled) {
+		hw_if->enable_rx_csum(pdata);
+		netdev_alert(netdev, "state change - rxcsum enabled\n");
+	} else if (!(features & NETIF_F_RXCSUM) && rxcsum_enabled) {
+		hw_if->disable_rx_csum(pdata);
+		netdev_alert(netdev, "state change - rxcsum disabled\n");
+	}
+
+	if ((features & NETIF_F_HW_VLAN_CTAG_RX) && !rxvlan_enabled) {
+		hw_if->enable_rx_vlan_stripping(pdata);
+		netdev_alert(netdev, "state change - rxvlan enabled\n");
+	} else if (!(features & NETIF_F_HW_VLAN_CTAG_RX) && rxvlan_enabled) {
+		hw_if->disable_rx_vlan_stripping(pdata);
+		netdev_alert(netdev, "state change - rxvlan disabled\n");
+	}
+
+	pdata->netdev_features = features;
+
+	DBGPR("<--xgbe_set_features\n");
+
+	return 0;
+}
+
+static const struct net_device_ops xgbe_netdev_ops = {
+	.ndo_open		= xgbe_open,
+	.ndo_stop		= xgbe_close,
+	.ndo_start_xmit		= xgbe_xmit,
+	.ndo_set_rx_mode	= xgbe_set_rx_mode,
+	.ndo_set_mac_address	= xgbe_set_mac_address,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= xgbe_change_mtu,
+	.ndo_get_stats64	= xgbe_get_stats64,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= xgbe_poll_controller,
+#endif
+	.ndo_set_features	= xgbe_set_features,
+};
+
+struct net_device_ops *xgbe_get_netdev_ops(void)
+{
+	return (struct net_device_ops *)&xgbe_netdev_ops;
+}
+
+static int xgbe_tx_poll(struct xgbe_channel *channel)
+{
+	struct xgbe_prv_data *pdata = channel->pdata;
+	struct xgbe_hw_if *hw_if = &pdata->hw_if;
+	struct xgbe_desc_if *desc_if = &pdata->desc_if;
+	struct xgbe_ring *ring = channel->tx_ring;
+	struct xgbe_ring_data *rdata;
+	struct xgbe_ring_desc *rdesc;
+	struct net_device *netdev = pdata->netdev;
+	unsigned long flags;
+	int processed = 0;
+
+	DBGPR("-->xgbe_tx_poll\n");
+
+	/* Nothing to do if there isn't a Tx ring for this channel */
+	if (!ring)
+		return 0;
+
+	spin_lock_irqsave(&ring->lock, flags);
+
+	while ((processed < TX_DESC_MAX_PROC) && (ring->dirty < ring->cur)) {
+		rdata = GET_DESC_DATA(ring, ring->dirty);
+		rdesc = rdata->rdesc;
+
+		if (!hw_if->tx_complete(rdesc))
+			break;
+
+#ifdef XGMAC_ENABLE_TX_DESC_DUMP
+		xgbe_dump_tx_desc(ring, ring->dirty, 1, 0);
+#endif
+
+		/* Free the SKB and reset the descriptor for re-use */
+		desc_if->unmap_skb(pdata, rdata);
+		hw_if->tx_desc_reset(rdata);
+
+		processed++;
+		ring->dirty++;
+	}
+
+	if ((ring->tx.queue_stopped == 1) &&
+	    (xgbe_tx_avail_desc(ring) > TX_DESC_MIN_FREE)) {
+		ring->tx.queue_stopped = 0;
+		netif_wake_subqueue(netdev, channel->queue_index);
+	}
+
+	DBGPR("<--xgbe_tx_poll: processed=%d\n", processed);
+
+	spin_unlock_irqrestore(&ring->lock, flags);
+
+	return processed;
+}
+
+static int xgbe_rx_poll(struct xgbe_channel *channel, int budget)
+{
+	struct xgbe_prv_data *pdata = channel->pdata;
+	struct xgbe_hw_if *hw_if = &pdata->hw_if;
+	struct xgbe_desc_if *desc_if = &pdata->desc_if;
+	struct xgbe_ring *ring = channel->rx_ring;
+	struct xgbe_ring_data *rdata;
+	struct xgbe_packet_data *packet;
+	struct net_device *netdev = pdata->netdev;
+	struct sk_buff *skb;
+	unsigned int incomplete, error;
+	unsigned int cur_len, put_len, max_len;
+	int received = 0;
+
+	DBGPR("-->xgbe_rx_poll: budget=%d\n", budget);
+
+	/* Nothing to do if there isn't a Rx ring for this channel */
+	if (!ring)
+		return 0;
+
+	packet = &ring->packet_data;
+	while (received < budget) {
+		DBGPR("  cur = %d\n", ring->cur);
+
+		/* Clear the packet data information */
+		memset(packet, 0, sizeof(*packet));
+		skb = NULL;
+		error = 0;
+		cur_len = 0;
+
+read_again:
+		rdata = GET_DESC_DATA(ring, ring->cur);
+
+		if (hw_if->dev_read(channel))
+			break;
+
+		received++;
+		ring->cur++;
+		ring->dirty++;
+
+		dma_unmap_single(pdata->dev, rdata->skb_dma,
+				 rdata->skb_dma_len, DMA_FROM_DEVICE);
+		rdata->skb_dma = 0;
+
+		incomplete = XGMAC_GET_BITS(packet->attributes,
+					    RX_PACKET_ATTRIBUTES,
+					    INCOMPLETE);
+
+		/* Earlier error, just drain the remaining data */
+		if (incomplete && error)
+			goto read_again;
+
+		if (error || packet->errors) {
+			if (packet->errors)
+				DBGPR("Error in received packet\n");
+			dev_kfree_skb(skb);
+			continue;
+		}
+
+		put_len = rdata->len - cur_len;
+		if (skb) {
+			if (pskb_expand_head(skb, 0, put_len, GFP_ATOMIC)) {
+				DBGPR("pskb_expand_head error\n");
+				if (incomplete) {
+					error = 1;
+					goto read_again;
+				}
+
+				dev_kfree_skb(skb);
+				continue;
+			}
+			memcpy(skb_tail_pointer(skb), rdata->skb->data,
+			       put_len);
+		} else {
+			skb = rdata->skb;
+			rdata->skb = NULL;
+		}
+		skb_put(skb, put_len);
+		cur_len += put_len;
+
+		if (incomplete)
+			goto read_again;
+
+		/* Be sure we don't exceed the configured MTU */
+		max_len = netdev->mtu + ETH_HLEN;
+		if (!(netdev->features & NETIF_F_HW_VLAN_CTAG_RX) &&
+		    (skb->protocol == htons(ETH_P_8021Q)))
+			max_len += VLAN_HLEN;
+
+		if (skb->len > max_len) {
+			DBGPR("packet length exceeds configured MTU\n");
+			dev_kfree_skb(skb);
+			continue;
+		}
+
+#ifdef XGMAC_ENABLE_RX_PKT_DUMP
+		xgbe_print_pkt(netdev, skb, false);
+#endif
+
+		skb_checksum_none_assert(skb);
+		if (XGMAC_GET_BITS(packet->attributes,
+				   RX_PACKET_ATTRIBUTES, CSUM_DONE))
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+		if (XGMAC_GET_BITS(packet->attributes,
+				   RX_PACKET_ATTRIBUTES, VLAN_CTAG))
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
+					       packet->vlan_ctag);
+
+		skb->dev = netdev;
+		skb->protocol = eth_type_trans(skb, netdev);
+		skb_record_rx_queue(skb, channel->queue_index);
+		skb_mark_napi_id(skb, &pdata->napi);
+
+		netdev->last_rx = jiffies;
+		napi_gro_receive(&pdata->napi, skb);
+	}
+
+	if (received) {
+		desc_if->realloc_skb(channel);
+
+		/* Update the Rx Tail Pointer Register with address of
+		 * the last cleaned entry */
+		rdata = GET_DESC_DATA(ring, ring->rx.realloc_index - 1);
+		XGMAC_DMA_IOWRITE(channel, DMA_CH_RDTR_LO,
+				  lower_32_bits(rdata->rdesc_dma));
+	}
+
+	DBGPR("<--xgbe_rx_poll: received = %d\n", received);
+
+	return received;
+}
+
+static int xgbe_poll(struct napi_struct *napi, int budget)
+{
+	struct xgbe_prv_data *pdata = container_of(napi, struct xgbe_prv_data,
+						   napi);
+	struct xgbe_channel *channel;
+	int processed;
+	unsigned int i;
+
+	DBGPR("-->xgbe_poll: budget=%d\n", budget);
+
+	/* Cleanup Tx ring first */
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++)
+		xgbe_tx_poll(channel);
+
+	/* Process Rx ring next */
+	processed = 0;
+	channel = pdata->channel;
+	for (i = 0; i < pdata->channel_count; i++, channel++)
+		processed += xgbe_rx_poll(channel, budget - processed);
+
+	/* If we processed everything, we are done */
+	if (processed < budget) {
+		/* Turn off polling */
+		napi_complete(napi);
+
+		/* Enable Tx and Rx interrupts */
+		xgbe_enable_rx_tx_ints(pdata);
+	}
+
+	DBGPR("<--xgbe_poll: received = %d\n", processed);
+
+	return processed;
+}
+
+void xgbe_dump_tx_desc(struct xgbe_ring *ring, unsigned int idx,
+		       unsigned int count, unsigned int flag)
+{
+	struct xgbe_ring_data *rdata;
+	struct xgbe_ring_desc *rdesc;
+
+	while (count--) {
+		rdata = GET_DESC_DATA(ring, idx);
+		rdesc = rdata->rdesc;
+		DBGPR("TX_NORMAL_DESC[%d %s] = %08x:%08x:%08x:%08x\n", idx,
+		      (flag == 1) ? "QUEUED FOR TX" : "TX BY DEVICE",
+		      le32_to_cpu(rdesc->desc0), le32_to_cpu(rdesc->desc1),
+		      le32_to_cpu(rdesc->desc2), le32_to_cpu(rdesc->desc3));
+		idx++;
+	}
+}
+
+void xgbe_dump_rx_desc(struct xgbe_ring *ring, struct xgbe_ring_desc *desc,
+		       unsigned int idx)
+{
+	DBGPR("RX_NORMAL_DESC[%d RX BY DEVICE] = %08x:%08x:%08x:%08x\n", idx,
+	      le32_to_cpu(desc->desc0), le32_to_cpu(desc->desc1),
+	      le32_to_cpu(desc->desc2), le32_to_cpu(desc->desc3));
+}
+
+void xgbe_print_pkt(struct net_device *netdev, struct sk_buff *skb, bool tx_rx)
+{
+	struct ethhdr *eth = (struct ethhdr *)skb->data;
+	unsigned char *buf = skb->data;
+	unsigned char buffer[128];
+	unsigned int i, j;
+
+	netdev_alert(netdev, "\n************** SKB dump ****************\n");
+
+	netdev_alert(netdev, "%s packet of %d bytes\n",
+		     (tx_rx ? "TX" : "RX"), skb->len);
+
+	netdev_alert(netdev, "Dst MAC addr: %pM\n", eth->h_dest);
+	netdev_alert(netdev, "Src MAC addr: %pM\n", eth->h_source);
+	netdev_alert(netdev, "Protocol: 0x%04hx\n", ntohs(eth->h_proto));
+
+	for (i = 0, j = 0; i < skb->len;) {
+		j += snprintf(buffer + j, sizeof(buffer) - j, "%02hhx",
+			      buf[i++]);
+
+		if ((i % 32) == 0) {
+			netdev_alert(netdev, "  0x%04x: %s\n", i - 32, buffer);
+			j = 0;
+		} else if ((i % 16) == 0) {
+			buffer[j++] = ' ';
+			buffer[j++] = ' ';
+		} else if ((i % 4) == 0) {
+			buffer[j++] = ' ';
+		}
+	}
+	if (i % 32)
+		netdev_alert(netdev, "  0x%04x: %s\n", i - (i % 32), buffer);
+
+	netdev_alert(netdev, "\n************** SKB dump ****************\n");
+}
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
new file mode 100644
index 0000000..8909f2b
--- /dev/null
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
@@ -0,0 +1,510 @@
+/*
+ * AMD 10Gb Ethernet driver
+ *
+ * This file is available to you under your choice of the following two
+ * licenses:
+ *
+ * License 1: GPLv2
+ *
+ * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ *
+ * This file is free software; you may copy, redistribute and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation, either version 2 of the License, or (at
+ * your option) any later version.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ *
+ * This file incorporates work covered by the following copyright and
+ * permission notice:
+ *     The Synopsys DWC ETHER XGMAC Software Driver and documentation
+ *     (hereinafter "Software") is an unsupported proprietary work of Synopsys,
+ *     Inc. unless otherwise expressly agreed to in writing between Synopsys
+ *     and you.
+ *
+ *     The Software IS NOT an item of Licensed Software or Licensed Product
+ *     under any End User Software License Agreement or Agreement for Licensed
+ *     Product with Synopsys or any supplement thereto.  Permission is hereby
+ *     granted, free of charge, to any person obtaining a copy of this software
+ *     annotated with this license and the Software, to deal in the Software
+ *     without restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or sell copies
+ *     of the Software, and to permit persons to whom the Software is furnished
+ *     to do so, subject to the following conditions:
+ *
+ *     The above copyright notice and this permission notice shall be included
+ *     in all copies or substantial portions of the Software.
+ *
+ *     THIS SOFTWARE IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN "AS IS"
+ *     BASIS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
+ *     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+ *     PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS
+ *     BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ *     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
+ *     THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ *
+ * License 2: Modified BSD
+ *
+ * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ * All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Advanced Micro Devices, Inc. nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
+ * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ * This file incorporates work covered by the following copyright and
+ * permission notice:
+ *     The Synopsys DWC ETHER XGMAC Software Driver and documentation
+ *     (hereinafter "Software") is an unsupported proprietary work of Synopsys,
+ *     Inc. unless otherwise expressly agreed to in writing between Synopsys
+ *     and you.
+ *
+ *     The Software IS NOT an item of Licensed Software or Licensed Product
+ *     under any End User Software License Agreement or Agreement for Licensed
+ *     Product with Synopsys or any supplement thereto.  Permission is hereby
+ *     granted, free of charge, to any person obtaining a copy of this software
+ *     annotated with this license and the Software, to deal in the Software
+ *     without restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or sell copies
+ *     of the Software, and to permit persons to whom the Software is furnished
+ *     to do so, subject to the following conditions:
+ *
+ *     The above copyright notice and this permission notice shall be included
+ *     in all copies or substantial portions of the Software.
+ *
+ *     THIS SOFTWARE IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN "AS IS"
+ *     BASIS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
+ *     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+ *     PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS
+ *     BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ *     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
+ *     THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <linux/spinlock.h>
+#include <linux/phy.h>
+
+#include "xgbe.h"
+#include "xgbe-common.h"
+
+
+struct xgbe_stats {
+	char stat_string[ETH_GSTRING_LEN];
+	int stat_size;
+	int stat_offset;
+};
+
+#define XGMAC_MMC_STAT(_string, _var)				\
+	{ _string,						\
+	  FIELD_SIZEOF(struct xgbe_mmc_stats, _var),		\
+	  offsetof(struct xgbe_prv_data, mmc_stats._var),	\
+	}
+
+static const struct xgbe_stats xgbe_gstring_stats[] = {
+	XGMAC_MMC_STAT("tx_bytes", txoctetcount_gb),
+	XGMAC_MMC_STAT("tx_packets", txframecount_gb),
+	XGMAC_MMC_STAT("tx_unicast_packets", txunicastframes_gb),
+	XGMAC_MMC_STAT("tx_broadcast_packets", txbroadcastframes_gb),
+	XGMAC_MMC_STAT("tx_multicast_packets", txmulticastframes_gb),
+	XGMAC_MMC_STAT("tx_vlan_packets", txvlanframes_g),
+	XGMAC_MMC_STAT("tx_64_byte_packets", tx64octets_gb),
+	XGMAC_MMC_STAT("tx_65_to_127_byte_packets", tx65to127octets_gb),
+	XGMAC_MMC_STAT("tx_128_to_255_byte_packets", tx128to255octets_gb),
+	XGMAC_MMC_STAT("tx_256_to_511_byte_packets", tx256to511octets_gb),
+	XGMAC_MMC_STAT("tx_512_to_1023_byte_packets", tx512to1023octets_gb),
+	XGMAC_MMC_STAT("tx_1024_to_max_byte_packets", tx1024tomaxoctets_gb),
+	XGMAC_MMC_STAT("tx_underflow_errors", txunderflowerror),
+	XGMAC_MMC_STAT("tx_pause_frames", txpauseframes),
+
+	XGMAC_MMC_STAT("rx_bytes", rxoctetcount_gb),
+	XGMAC_MMC_STAT("rx_packets", rxframecount_gb),
+	XGMAC_MMC_STAT("rx_unicast_packets", rxunicastframes_g),
+	XGMAC_MMC_STAT("rx_broadcast_packets", rxbroadcastframes_g),
+	XGMAC_MMC_STAT("rx_multicast_packets", rxmulticastframes_g),
+	XGMAC_MMC_STAT("rx_vlan_packets", rxvlanframes_gb),
+	XGMAC_MMC_STAT("rx_64_byte_packets", rx64octets_gb),
+	XGMAC_MMC_STAT("rx_65_to_127_byte_packets", rx65to127octets_gb),
+	XGMAC_MMC_STAT("rx_128_to_255_byte_packets", rx128to255octets_gb),
+	XGMAC_MMC_STAT("rx_256_to_511_byte_packets", rx256to511octets_gb),
+	XGMAC_MMC_STAT("rx_512_to_1023_byte_packets", rx512to1023octets_gb),
+	XGMAC_MMC_STAT("rx_1024_to_max_byte_packets", rx1024tomaxoctets_gb),
+	XGMAC_MMC_STAT("rx_undersize_packets", rxundersize_g),
+	XGMAC_MMC_STAT("rx_oversize_packets", rxoversize_g),
+	XGMAC_MMC_STAT("rx_crc_errors", rxcrcerror),
+	XGMAC_MMC_STAT("rx_crc_errors_small_packets", rxrunterror),
+	XGMAC_MMC_STAT("rx_crc_errors_giant_packets", rxjabbererror),
+	XGMAC_MMC_STAT("rx_length_errors", rxlengtherror),
+	XGMAC_MMC_STAT("rx_out_of_range_errors", rxoutofrangetype),
+	XGMAC_MMC_STAT("rx_fifo_overflow_errors", rxfifooverflow),
+	XGMAC_MMC_STAT("rx_watchdog_errors", rxwatchdogerror),
+	XGMAC_MMC_STAT("rx_pause_frames", rxpauseframes),
+};
+#define XGBE_STATS_COUNT	ARRAY_SIZE(xgbe_gstring_stats)
+
+static void xgbe_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
+{
+	int i;
+
+	DBGPR("-->%s\n", __func__);
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		for (i = 0; i < XGBE_STATS_COUNT; i++) {
+			memcpy(data, xgbe_gstring_stats[i].stat_string,
+			       ETH_GSTRING_LEN);
+			data += ETH_GSTRING_LEN;
+		}
+		break;
+	}
+
+	DBGPR("<--%s\n", __func__);
+}
+
+static void xgbe_get_ethtool_stats(struct net_device *netdev,
+				   struct ethtool_stats *stats, u64 *data)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+	u8 *stat;
+	int i;
+
+	DBGPR("-->%s\n", __func__);
+
+	pdata->hw_if.read_mmc_stats(pdata);
+	for (i = 0; i < XGBE_STATS_COUNT; i++) {
+		stat = (u8 *)pdata + xgbe_gstring_stats[i].stat_offset;
+		*data++ = *(u64 *)stat;
+	}
+
+	DBGPR("<--%s\n", __func__);
+}
+
+static int xgbe_get_sset_count(struct net_device *netdev, int stringset)
+{
+	int ret;
+
+	DBGPR("-->%s\n", __func__);
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		ret = XGBE_STATS_COUNT;
+		break;
+
+	default:
+		ret = -EOPNOTSUPP;
+	}
+
+	DBGPR("<--%s\n", __func__);
+
+	return ret;
+}
+
+static void xgbe_get_pauseparam(struct net_device *netdev,
+				struct ethtool_pauseparam *pause)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+
+	DBGPR("-->xgbe_get_pauseparam\n");
+
+	pause->autoneg = pdata->pause_autoneg;
+	pause->tx_pause = pdata->tx_pause;
+	pause->rx_pause = pdata->rx_pause;
+
+	DBGPR("<--xgbe_get_pauseparam\n");
+}
+
+static int xgbe_set_pauseparam(struct net_device *netdev,
+			       struct ethtool_pauseparam *pause)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+	struct phy_device *phydev = pdata->phydev;
+	int ret = 0;
+
+	DBGPR("-->xgbe_set_pauseparam\n");
+
+	DBGPR("  autoneg = %d, tx_pause = %d, rx_pause = %d\n",
+	      pause->autoneg, pause->tx_pause, pause->rx_pause);
+
+	pdata->pause_autoneg = pause->autoneg;
+	if (pause->autoneg) {
+		phydev->advertising |= ADVERTISED_Pause;
+		phydev->advertising |= ADVERTISED_Asym_Pause;
+
+	} else {
+		phydev->advertising &= ~ADVERTISED_Pause;
+		phydev->advertising &= ~ADVERTISED_Asym_Pause;
+
+		pdata->tx_pause = pause->tx_pause;
+		pdata->rx_pause = pause->rx_pause;
+	}
+
+	if (netif_running(netdev))
+		ret = phy_start_aneg(phydev);
+
+	DBGPR("<--xgbe_set_pauseparam\n");
+
+	return ret;
+}
+
+static int xgbe_get_settings(struct net_device *netdev,
+			     struct ethtool_cmd *cmd)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+	int ret;
+
+	DBGPR("-->xgbe_get_settings\n");
+
+	if (!pdata->phydev)
+		return -ENODEV;
+
+	spin_lock_irq(&pdata->lock);
+
+	ret = phy_ethtool_gset(pdata->phydev, cmd);
+	cmd->transceiver = XCVR_EXTERNAL;
+
+	spin_unlock_irq(&pdata->lock);
+
+	DBGPR("<--xgbe_get_settings\n");
+
+	return ret;
+}
+
+static int xgbe_set_settings(struct net_device *netdev,
+			     struct ethtool_cmd *cmd)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+	struct phy_device *phydev = pdata->phydev;
+	u32 speed;
+	int ret;
+
+	DBGPR("-->xgbe_set_settings\n");
+
+	if (!pdata->phydev)
+		return -ENODEV;
+
+	spin_lock_irq(&pdata->lock);
+
+	speed = ethtool_cmd_speed(cmd);
+
+	ret = -EINVAL;
+	if (cmd->phy_address != phydev->addr)
+		goto unlock;
+
+	if ((cmd->autoneg != AUTONEG_ENABLE) &&
+	    (cmd->autoneg != AUTONEG_DISABLE))
+		goto unlock;
+
+	if ((cmd->autoneg == AUTONEG_DISABLE) &&
+	    (((speed != SPEED_10000) && (speed != SPEED_1000)) ||
+	     (cmd->duplex != DUPLEX_FULL)))
+		goto unlock;
+
+	if (cmd->autoneg == AUTONEG_ENABLE) {
+		/* Clear settings needed to force speeds */
+		phydev->supported &= ~SUPPORTED_1000baseT_Full;
+		phydev->supported &= ~SUPPORTED_10000baseT_Full;
+	} else {
+		/* Add settings needed to force speed */
+		phydev->supported |= SUPPORTED_1000baseT_Full;
+		phydev->supported |= SUPPORTED_10000baseT_Full;
+	}
+
+	cmd->advertising &= phydev->supported;
+	if ((cmd->autoneg == AUTONEG_ENABLE) && !cmd->advertising)
+		goto unlock;
+
+	ret = 0;
+	phydev->autoneg = cmd->autoneg;
+	phydev->speed = speed;
+	phydev->duplex = cmd->duplex;
+	phydev->advertising = cmd->advertising;
+
+	if (cmd->autoneg == AUTONEG_ENABLE)
+		phydev->advertising |= ADVERTISED_Autoneg;
+	else
+		phydev->advertising &= ~ADVERTISED_Autoneg;
+
+	if (netif_running(netdev))
+		ret = phy_start_aneg(phydev);
+
+unlock:
+	spin_unlock_irq(&pdata->lock);
+
+	DBGPR("<--xgbe_set_settings\n");
+
+	return ret;
+}
+
+static void xgbe_get_drvinfo(struct net_device *netdev,
+			     struct ethtool_drvinfo *drvinfo)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+
+	strlcpy(drvinfo->driver, XGBE_DRV_NAME, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, XGBE_DRV_VERSION, sizeof(drvinfo->version));
+	strlcpy(drvinfo->bus_info, dev_name(pdata->dev),
+		sizeof(drvinfo->bus_info));
+	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version), "%d.%d.%d",
+		 XGMAC_IOREAD_BITS(pdata, MAC_VR, USERVER),
+		 XGMAC_IOREAD_BITS(pdata, MAC_VR, DEVID),
+		 XGMAC_IOREAD_BITS(pdata, MAC_VR, SNPSVER));
+	drvinfo->n_stats = XGBE_STATS_COUNT;
+}
+
+static int xgbe_get_coalesce(struct net_device *netdev,
+			     struct ethtool_coalesce *ec)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+	struct xgbe_hw_if *hw_if = &pdata->hw_if;
+	unsigned int riwt;
+
+	DBGPR("-->xgbe_get_coalesce\n");
+
+	memset(ec, 0, sizeof(struct ethtool_coalesce));
+
+	riwt = pdata->rx_riwt;
+	ec->rx_coalesce_usecs = hw_if->riwt_to_usec(pdata, riwt);
+	ec->rx_max_coalesced_frames = pdata->rx_frames;
+
+	ec->tx_coalesce_usecs = pdata->tx_usecs;
+	ec->tx_max_coalesced_frames = pdata->tx_frames;
+
+	DBGPR("<--xgbe_get_coalesce\n");
+
+	return 0;
+}
+
+static int xgbe_set_coalesce(struct net_device *netdev,
+			     struct ethtool_coalesce *ec)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+	struct xgbe_hw_if *hw_if = &pdata->hw_if;
+	unsigned int rx_frames, rx_riwt, rx_usecs;
+	unsigned int tx_frames, tx_usecs;
+
+	DBGPR("-->xgbe_set_coalesce\n");
+
+	/* Check for not supported parameters  */
+	if ((ec->rx_coalesce_usecs_irq) ||
+	    (ec->rx_max_coalesced_frames_irq) ||
+	    (ec->tx_coalesce_usecs_irq) ||
+	    (ec->tx_max_coalesced_frames_irq) ||
+	    (ec->stats_block_coalesce_usecs) ||
+	    (ec->use_adaptive_rx_coalesce) ||
+	    (ec->use_adaptive_tx_coalesce) ||
+	    (ec->pkt_rate_low) ||
+	    (ec->rx_coalesce_usecs_low) ||
+	    (ec->rx_max_coalesced_frames_low) ||
+	    (ec->tx_coalesce_usecs_low) ||
+	    (ec->tx_max_coalesced_frames_low) ||
+	    (ec->pkt_rate_high) ||
+	    (ec->rx_coalesce_usecs_high) ||
+	    (ec->rx_max_coalesced_frames_high) ||
+	    (ec->tx_coalesce_usecs_high) ||
+	    (ec->tx_max_coalesced_frames_high) ||
+	    (ec->rate_sample_interval))
+		return -EOPNOTSUPP;
+
+	/* Can only change rx-frames when interface is down (see
+	 * rx_descriptor_init in xgbe-dev.c)
+	 */
+	rx_frames = pdata->rx_frames;
+	if (rx_frames != ec->rx_max_coalesced_frames && netif_running(netdev)) {
+		netdev_alert(netdev,
+			     "interface must be down to change rx-frames\n");
+		return -EINVAL;
+	}
+
+	rx_riwt = hw_if->usec_to_riwt(pdata, ec->rx_coalesce_usecs);
+	rx_frames = ec->rx_max_coalesced_frames;
+
+	/* Use smallest possible value if conversion resulted in zero */
+	if (ec->rx_coalesce_usecs && !rx_riwt)
+		rx_riwt = 1;
+
+	/* Check the bounds of values for Rx */
+	if (rx_riwt > XGMAC_MAX_DMA_RIWT) {
+		rx_usecs = hw_if->riwt_to_usec(pdata, XGMAC_MAX_DMA_RIWT);
+		netdev_alert(netdev, "rx-usec is limited to %d usecs\n",
+			     rx_usecs);
+		return -EINVAL;
+	}
+	if (rx_frames > pdata->channel->rx_ring->rdesc_count) {
+		netdev_alert(netdev, "rx-frames is limited to %d frames\n",
+			     pdata->channel->rx_ring->rdesc_count);
+		return -EINVAL;
+	}
+
+	tx_usecs = ec->tx_coalesce_usecs;
+	tx_frames = ec->tx_max_coalesced_frames;
+
+	/* Check the bounds of values for Tx */
+	if (tx_frames > pdata->channel->tx_ring->rdesc_count) {
+		netdev_alert(netdev, "tx-frames is limited to %d frames\n",
+			     pdata->channel->tx_ring->rdesc_count);
+		return -EINVAL;
+	}
+
+	pdata->rx_riwt = rx_riwt;
+	pdata->rx_frames = rx_frames;
+	hw_if->config_rx_coalesce(pdata);
+
+	pdata->tx_usecs = tx_usecs;
+	pdata->tx_frames = tx_frames;
+	hw_if->config_tx_coalesce(pdata);
+
+	DBGPR("<--xgbe_set_coalesce\n");
+
+	return 0;
+}
+
+static const struct ethtool_ops xgbe_ethtool_ops = {
+	.get_settings = xgbe_get_settings,
+	.set_settings = xgbe_set_settings,
+	.get_drvinfo = xgbe_get_drvinfo,
+	.get_link = ethtool_op_get_link,
+	.get_coalesce = xgbe_get_coalesce,
+	.set_coalesce = xgbe_set_coalesce,
+	.get_pauseparam = xgbe_get_pauseparam,
+	.set_pauseparam = xgbe_set_pauseparam,
+	.get_strings = xgbe_get_strings,
+	.get_ethtool_stats = xgbe_get_ethtool_stats,
+	.get_sset_count = xgbe_get_sset_count,
+};
+
+struct ethtool_ops *xgbe_get_ethtool_ops(void)
+{
+	return (struct ethtool_ops *)&xgbe_ethtool_ops;
+}
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
new file mode 100644
index 0000000..b21f9b9
--- /dev/null
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -0,0 +1,512 @@
+/*
+ * AMD 10Gb Ethernet driver
+ *
+ * This file is available to you under your choice of the following two
+ * licenses:
+ *
+ * License 1: GPLv2
+ *
+ * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ *
+ * This file is free software; you may copy, redistribute and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation, either version 2 of the License, or (at
+ * your option) any later version.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ *
+ * This file incorporates work covered by the following copyright and
+ * permission notice:
+ *     The Synopsys DWC ETHER XGMAC Software Driver and documentation
+ *     (hereinafter "Software") is an unsupported proprietary work of Synopsys,
+ *     Inc. unless otherwise expressly agreed to in writing between Synopsys
+ *     and you.
+ *
+ *     The Software IS NOT an item of Licensed Software or Licensed Product
+ *     under any End User Software License Agreement or Agreement for Licensed
+ *     Product with Synopsys or any supplement thereto.  Permission is hereby
+ *     granted, free of charge, to any person obtaining a copy of this software
+ *     annotated with this license and the Software, to deal in the Software
+ *     without restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or sell copies
+ *     of the Software, and to permit persons to whom the Software is furnished
+ *     to do so, subject to the following conditions:
+ *
+ *     The above copyright notice and this permission notice shall be included
+ *     in all copies or substantial portions of the Software.
+ *
+ *     THIS SOFTWARE IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN "AS IS"
+ *     BASIS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
+ *     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+ *     PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS
+ *     BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ *     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
+ *     THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ *
+ * License 2: Modified BSD
+ *
+ * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ * All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Advanced Micro Devices, Inc. nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
+ * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ * This file incorporates work covered by the following copyright and
+ * permission notice:
+ *     The Synopsys DWC ETHER XGMAC Software Driver and documentation
+ *     (hereinafter "Software") is an unsupported proprietary work of Synopsys,
+ *     Inc. unless otherwise expressly agreed to in writing between Synopsys
+ *     and you.
+ *
+ *     The Software IS NOT an item of Licensed Software or Licensed Product
+ *     under any End User Software License Agreement or Agreement for Licensed
+ *     Product with Synopsys or any supplement thereto.  Permission is hereby
+ *     granted, free of charge, to any person obtaining a copy of this software
+ *     annotated with this license and the Software, to deal in the Software
+ *     without restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or sell copies
+ *     of the Software, and to permit persons to whom the Software is furnished
+ *     to do so, subject to the following conditions:
+ *
+ *     The above copyright notice and this permission notice shall be included
+ *     in all copies or substantial portions of the Software.
+ *
+ *     THIS SOFTWARE IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN "AS IS"
+ *     BASIS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
+ *     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+ *     PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS
+ *     BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ *     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
+ *     THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <linux/module.h>
+#include <linux/device.h>
+#include <linux/platform_device.h>
+#include <linux/spinlock.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/io.h>
+#include <linux/of.h>
+#include <linux/of_net.h>
+#include <linux/clk.h>
+
+#include "xgbe.h"
+#include "xgbe-common.h"
+
+
+MODULE_AUTHOR("Tom Lendacky <thomas.lendacky@amd.com>");
+MODULE_LICENSE("Dual BSD/GPL");
+MODULE_VERSION(XGBE_DRV_VERSION);
+MODULE_DESCRIPTION(XGBE_DRV_DESC);
+
+static struct xgbe_channel *xgbe_alloc_rings(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_channel *channel_mem, *channel;
+	struct xgbe_ring *tx_ring, *rx_ring;
+	unsigned int count, i;
+
+	DBGPR("-->xgbe_alloc_rings\n");
+
+	count = max_t(unsigned int, pdata->tx_ring_count, pdata->rx_ring_count);
+
+	channel_mem = devm_kcalloc(pdata->dev, count,
+				   sizeof(struct xgbe_channel), GFP_KERNEL);
+	if (!channel_mem)
+		return NULL;
+
+	tx_ring = devm_kcalloc(pdata->dev, pdata->tx_ring_count,
+			       sizeof(struct xgbe_ring), GFP_KERNEL);
+	if (!tx_ring)
+		return NULL;
+
+	rx_ring = devm_kcalloc(pdata->dev, pdata->rx_ring_count,
+			       sizeof(struct xgbe_ring), GFP_KERNEL);
+	if (!rx_ring)
+		return NULL;
+
+	for (i = 0, channel = channel_mem; i < count; i++, channel++) {
+		snprintf(channel->name, sizeof(channel->name), "channel-%d", i);
+		channel->pdata = pdata;
+		channel->queue_index = i;
+		channel->dma_regs = pdata->xgmac_regs + DMA_CH_BASE +
+				    (DMA_CH_INC * i);
+
+		if (i < pdata->tx_ring_count) {
+			spin_lock_init(&tx_ring->lock);
+			channel->tx_ring = tx_ring++;
+		}
+
+		if (i < pdata->rx_ring_count) {
+			spin_lock_init(&tx_ring->lock);
+			channel->rx_ring = rx_ring++;
+		}
+
+		DBGPR("  %s - queue_index=%u, dma_regs=%p, tx=%p, rx=%p\n",
+		      channel->name, channel->queue_index, channel->dma_regs,
+		      channel->tx_ring, channel->rx_ring);
+	}
+
+	pdata->channel_count = count;
+
+	DBGPR("<--xgbe_alloc_rings\n");
+
+	return channel_mem;
+}
+
+static void xgbe_default_config(struct xgbe_prv_data *pdata)
+{
+	DBGPR("-->xgbe_default_config\n");
+
+	pdata->pblx8 = DMA_PBL_X8_ENABLE;
+	pdata->tx_sf_mode = MTL_TSF_ENABLE;
+	pdata->tx_threshold = MTL_TX_THRESHOLD_64;
+	pdata->tx_pbl = DMA_PBL_16;
+	pdata->tx_osp_mode = DMA_OSP_ENABLE;
+	pdata->rx_sf_mode = MTL_RSF_DISABLE;
+	pdata->rx_threshold = MTL_RX_THRESHOLD_64;
+	pdata->rx_pbl = DMA_PBL_16;
+	pdata->pause_autoneg = 1;
+	pdata->tx_pause = 1;
+	pdata->rx_pause = 1;
+	pdata->power_down = 0;
+	pdata->default_autoneg = AUTONEG_ENABLE;
+	pdata->default_speed = SPEED_10000;
+
+	DBGPR("<--xgbe_default_config\n");
+}
+
+static void xgbe_init_all_fptrs(struct xgbe_prv_data *pdata)
+{
+	xgbe_init_function_ptrs_dev(&pdata->hw_if);
+	xgbe_init_function_ptrs_desc(&pdata->desc_if);
+}
+
+static int xgbe_probe(struct platform_device *pdev)
+{
+	struct xgbe_prv_data *pdata;
+	struct xgbe_hw_if *hw_if;
+	struct xgbe_desc_if *desc_if;
+	struct net_device *netdev;
+	struct device *dev = &pdev->dev;
+	struct resource *res;
+	const u8 *mac_addr;
+	int ret;
+
+	DBGPR("--> xgbe_probe\n");
+
+	netdev = alloc_etherdev_mq(sizeof(struct xgbe_prv_data),
+				   MAX_DMA_CHANNELS);
+	if (!netdev) {
+		dev_err(dev, "alloc_etherdev failed\n");
+		ret = -ENOMEM;
+		goto err_alloc;
+	}
+	SET_NETDEV_DEV(netdev, dev);
+	pdata = netdev_priv(netdev);
+	pdata->netdev = netdev;
+	pdata->pdev = pdev;
+	pdata->dev = dev;
+	platform_set_drvdata(pdev, netdev);
+
+	spin_lock_init(&pdata->lock);
+	mutex_init(&pdata->xpcs_mutex);
+
+	/* Set and validate the number of descriptors for a ring */
+	BUILD_BUG_ON_NOT_POWER_OF_2(TX_DESC_CNT);
+	pdata->tx_desc_count = TX_DESC_CNT;
+	if (pdata->tx_desc_count & (pdata->tx_desc_count - 1)) {
+		dev_err(dev, "tx descriptor count (%d) is not valid\n",
+			pdata->tx_desc_count);
+		ret = -EINVAL;
+		goto err_io;
+	}
+	BUILD_BUG_ON_NOT_POWER_OF_2(RX_DESC_CNT);
+	pdata->rx_desc_count = RX_DESC_CNT;
+	if (pdata->rx_desc_count & (pdata->rx_desc_count - 1)) {
+		dev_err(dev, "rx descriptor count (%d) is not valid\n",
+			pdata->rx_desc_count);
+		ret = -EINVAL;
+		goto err_io;
+	}
+
+	/* Obtain the system clock setting */
+	pdata->sysclock = devm_clk_get(dev, NULL);
+	if (IS_ERR(pdata->sysclock)) {
+		dev_err(dev, "devm_clk_get failed\n");
+		ret = PTR_ERR(pdata->sysclock);
+		goto err_io;
+	}
+
+	/* Obtain the mmio areas for the device */
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	pdata->xgmac_regs = devm_ioremap_resource(dev, res);
+	if (IS_ERR(pdata->xgmac_regs)) {
+		dev_err(dev, "xgmac ioremap failed\n");
+		ret = PTR_ERR(pdata->xgmac_regs);
+		goto err_io;
+	}
+	DBGPR("  xgmac_regs = %p\n", pdata->xgmac_regs);
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
+	pdata->xpcs_regs = devm_ioremap_resource(dev, res);
+	if (IS_ERR(pdata->xpcs_regs)) {
+		dev_err(dev, "xpcs ioremap failed\n");
+		ret = PTR_ERR(pdata->xpcs_regs);
+		goto err_io;
+	}
+	DBGPR("  xpcs_regs  = %p\n", pdata->xpcs_regs);
+
+	/* Set the DMA mask */
+	if (!dev->dma_mask)
+		dev->dma_mask = &dev->coherent_dma_mask;
+	*(dev->dma_mask) = DMA_BIT_MASK(40);
+	dev->coherent_dma_mask = DMA_BIT_MASK(40);
+
+	ret = platform_get_irq(pdev, 0);
+	if (ret < 0) {
+		dev_err(dev, "platform_get_irq failed\n");
+		goto err_io;
+	}
+	netdev->irq = ret;
+	netdev->base_addr = (unsigned long)pdata->xgmac_regs;
+
+	/* Set all the function pointers */
+	xgbe_init_all_fptrs(pdata);
+	hw_if = &pdata->hw_if;
+	desc_if = &pdata->desc_if;
+
+	/* Issue software reset to device */
+	hw_if->exit(pdata);
+
+	/* Populate the hardware features */
+	xgbe_get_all_hw_features(pdata);
+
+	/* Retrieve the MAC address */
+	mac_addr = of_get_mac_address(dev->of_node);
+	if (!mac_addr) {
+		dev_err(dev, "invalid mac address for this device\n");
+		ret = -EINVAL;
+		goto err_io;
+	}
+	memcpy(netdev->dev_addr, mac_addr, netdev->addr_len);
+
+	/* Retrieve the PHY mode - it must be "xgmii" */
+	pdata->phy_mode = of_get_phy_mode(dev->of_node);
+	if (pdata->phy_mode != PHY_INTERFACE_MODE_XGMII) {
+		dev_err(dev, "invalid phy-mode specified for this device\n");
+		ret = -EINVAL;
+		goto err_io;
+	}
+
+	/* Set default configuration data */
+	xgbe_default_config(pdata);
+
+	/* Calculate the number of Tx and Rx rings to be created */
+	pdata->tx_ring_count = min_t(unsigned int, num_online_cpus(),
+				     pdata->hw_feat.tx_ch_cnt);
+	if (netif_set_real_num_tx_queues(netdev, pdata->tx_ring_count)) {
+		dev_err(dev, "error setting real tx queue count\n");
+		goto err_io;
+	}
+
+	pdata->rx_ring_count = min_t(unsigned int,
+				     netif_get_num_default_rss_queues(),
+				     pdata->hw_feat.rx_ch_cnt);
+	ret = netif_set_real_num_rx_queues(netdev, pdata->rx_ring_count);
+	if (ret) {
+		dev_err(dev, "error setting real rx queue count\n");
+		goto err_io;
+	}
+
+	/* Allocate the rings for the DMA channels */
+	pdata->channel = xgbe_alloc_rings(pdata);
+	if (!pdata->channel) {
+		dev_err(dev, "ring allocation failed\n");
+		ret = -ENOMEM;
+		goto err_io;
+	}
+
+	/* Prepare to regsiter with MDIO */
+	pdata->mii_bus_id = kasprintf(GFP_KERNEL, "%s", pdev->name);
+	if (!pdata->mii_bus_id) {
+		dev_err(dev, "failed to allocate mii bus id\n");
+		ret = -ENOMEM;
+		goto err_io;
+	}
+	ret = xgbe_mdio_register(pdata);
+	if (ret)
+		goto err_bus_id;
+
+	/* Set network and ethtool operations */
+	netdev->netdev_ops = xgbe_get_netdev_ops();
+	netdev->ethtool_ops = xgbe_get_ethtool_ops();
+
+	/* Set device features */
+	netdev->hw_features = NETIF_F_SG |
+			      NETIF_F_IP_CSUM |
+			      NETIF_F_IPV6_CSUM |
+			      NETIF_F_RXCSUM |
+			      NETIF_F_TSO |
+			      NETIF_F_TSO6 |
+			      NETIF_F_GRO |
+			      NETIF_F_HW_VLAN_CTAG_RX |
+			      NETIF_F_HW_VLAN_CTAG_TX;
+
+	netdev->vlan_features |= NETIF_F_SG |
+				 NETIF_F_IP_CSUM |
+				 NETIF_F_IPV6_CSUM |
+				 NETIF_F_TSO |
+				 NETIF_F_TSO6;
+
+	netdev->features |= netdev->hw_features;
+	pdata->netdev_features = netdev->features;
+
+	xgbe_init_rx_coalesce(pdata);
+	xgbe_init_tx_coalesce(pdata);
+
+	netif_carrier_off(netdev);
+	ret = register_netdev(netdev);
+	if (ret) {
+		dev_err(dev, "net device registration failed\n");
+		goto err_reg_netdev;
+	}
+
+	xgbe_debugfs_init(pdata);
+
+	netdev_notice(netdev, "net device enabled\n");
+
+	DBGPR("<-- xgbe_probe\n");
+
+	return 0;
+
+err_reg_netdev:
+	xgbe_mdio_unregister(pdata);
+
+err_bus_id:
+	kfree(pdata->mii_bus_id);
+
+err_io:
+	free_netdev(netdev);
+
+err_alloc:
+	dev_notice(dev, "net device not enabled\n");
+
+	return ret;
+}
+
+static int xgbe_remove(struct platform_device *pdev)
+{
+	struct net_device *netdev = platform_get_drvdata(pdev);
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+
+	DBGPR("-->xgbe_remove\n");
+
+	xgbe_debugfs_exit(pdata);
+
+	unregister_netdev(netdev);
+
+	xgbe_mdio_unregister(pdata);
+
+	kfree(pdata->mii_bus_id);
+
+	free_netdev(netdev);
+
+	DBGPR("<--xgbe_remove\n");
+
+	return 0;
+}
+
+#ifdef CONFIG_PM
+static int xgbe_suspend(struct device *dev)
+{
+	struct net_device *netdev = dev_get_drvdata(dev);
+	int ret;
+
+	DBGPR("-->xgbe_suspend\n");
+
+	if (!netif_running(netdev)) {
+		DBGPR("<--xgbe_dev_suspend\n");
+		return -EINVAL;
+	}
+
+	ret = xgbe_powerdown(netdev, XGMAC_DRIVER_CONTEXT);
+
+	DBGPR("<--xgbe_suspend\n");
+
+	return ret;
+}
+
+static int xgbe_resume(struct device *dev)
+{
+	struct net_device *netdev = dev_get_drvdata(dev);
+	int ret;
+
+	DBGPR("-->xgbe_resume\n");
+
+	if (!netif_running(netdev)) {
+		DBGPR("<--xgbe_dev_resume\n");
+		return -EINVAL;
+	}
+
+	ret = xgbe_powerup(netdev, XGMAC_DRIVER_CONTEXT);
+
+	DBGPR("<--xgbe_resume\n");
+
+	return ret;
+}
+#endif /* CONFIG_PM */
+
+static const struct of_device_id xgbe_of_match[] = {
+	{ .compatible = "amd,xgbe-seattle-v1a", },
+	{},
+};
+
+MODULE_DEVICE_TABLE(of, xgbe_of_match);
+static SIMPLE_DEV_PM_OPS(xgbe_pm_ops, xgbe_suspend, xgbe_resume);
+
+static struct platform_driver xgbe_driver = {
+	.driver = {
+		.name = "amd-xgbe",
+		.of_match_table = xgbe_of_match,
+		.pm = &xgbe_pm_ops,
+	},
+	.probe = xgbe_probe,
+	.remove = xgbe_remove,
+};
+
+module_platform_driver(xgbe_driver);
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
new file mode 100644
index 0000000..52bbdbf
--- /dev/null
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
@@ -0,0 +1,433 @@
+/*
+ * AMD 10Gb Ethernet driver
+ *
+ * This file is available to you under your choice of the following two
+ * licenses:
+ *
+ * License 1: GPLv2
+ *
+ * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ *
+ * This file is free software; you may copy, redistribute and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation, either version 2 of the License, or (at
+ * your option) any later version.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ *
+ * This file incorporates work covered by the following copyright and
+ * permission notice:
+ *     The Synopsys DWC ETHER XGMAC Software Driver and documentation
+ *     (hereinafter "Software") is an unsupported proprietary work of Synopsys,
+ *     Inc. unless otherwise expressly agreed to in writing between Synopsys
+ *     and you.
+ *
+ *     The Software IS NOT an item of Licensed Software or Licensed Product
+ *     under any End User Software License Agreement or Agreement for Licensed
+ *     Product with Synopsys or any supplement thereto.  Permission is hereby
+ *     granted, free of charge, to any person obtaining a copy of this software
+ *     annotated with this license and the Software, to deal in the Software
+ *     without restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or sell copies
+ *     of the Software, and to permit persons to whom the Software is furnished
+ *     to do so, subject to the following conditions:
+ *
+ *     The above copyright notice and this permission notice shall be included
+ *     in all copies or substantial portions of the Software.
+ *
+ *     THIS SOFTWARE IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN "AS IS"
+ *     BASIS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
+ *     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+ *     PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS
+ *     BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ *     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
+ *     THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ *
+ * License 2: Modified BSD
+ *
+ * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ * All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Advanced Micro Devices, Inc. nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
+ * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ * This file incorporates work covered by the following copyright and
+ * permission notice:
+ *     The Synopsys DWC ETHER XGMAC Software Driver and documentation
+ *     (hereinafter "Software") is an unsupported proprietary work of Synopsys,
+ *     Inc. unless otherwise expressly agreed to in writing between Synopsys
+ *     and you.
+ *
+ *     The Software IS NOT an item of Licensed Software or Licensed Product
+ *     under any End User Software License Agreement or Agreement for Licensed
+ *     Product with Synopsys or any supplement thereto.  Permission is hereby
+ *     granted, free of charge, to any person obtaining a copy of this software
+ *     annotated with this license and the Software, to deal in the Software
+ *     without restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or sell copies
+ *     of the Software, and to permit persons to whom the Software is furnished
+ *     to do so, subject to the following conditions:
+ *
+ *     The above copyright notice and this permission notice shall be included
+ *     in all copies or substantial portions of the Software.
+ *
+ *     THIS SOFTWARE IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN "AS IS"
+ *     BASIS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
+ *     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+ *     PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS
+ *     BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ *     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
+ *     THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <linux/module.h>
+#include <linux/kmod.h>
+#include <linux/spinlock.h>
+#include <linux/mdio.h>
+#include <linux/phy.h>
+#include <linux/of.h>
+
+#include "xgbe.h"
+#include "xgbe-common.h"
+
+
+static int xgbe_mdio_read(struct mii_bus *mii, int prtad, int mmd_reg)
+{
+	struct xgbe_prv_data *pdata = mii->priv;
+	struct xgbe_hw_if *hw_if = &pdata->hw_if;
+	int mmd_data;
+
+	DBGPR_MDIO("-->xgbe_mdio_read: prtad=%#x mmd_reg=%#x\n",
+		   prtad, mmd_reg);
+
+	mmd_data = hw_if->read_mmd_regs(pdata, prtad, mmd_reg);
+
+	DBGPR_MDIO("<--xgbe_mdio_read: mmd_data=%#x\n", mmd_data);
+
+	return mmd_data;
+}
+
+static int xgbe_mdio_write(struct mii_bus *mii, int prtad, int mmd_reg,
+			   u16 mmd_val)
+{
+	struct xgbe_prv_data *pdata = mii->priv;
+	struct xgbe_hw_if *hw_if = &pdata->hw_if;
+	int mmd_data = mmd_val;
+
+	DBGPR_MDIO("-->xgbe_mdio_write: prtad=%#x mmd_reg=%#x mmd_data=%#x\n",
+		   prtad, mmd_reg, mmd_data);
+
+	hw_if->write_mmd_regs(pdata, prtad, mmd_reg, mmd_data);
+
+	DBGPR_MDIO("<--xgbe_mdio_write\n");
+
+	return 0;
+}
+
+static void xgbe_adjust_link(struct net_device *netdev)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+	struct xgbe_hw_if *hw_if = &pdata->hw_if;
+	struct phy_device *phydev = pdata->phydev;
+	unsigned long flags;
+	int new_state = 0;
+
+	if (phydev == NULL)
+		return;
+
+	DBGPR_MDIO("-->xgbe_adjust_link: address=%d, newlink=%d, curlink=%d\n",
+		   phydev->addr, phydev->link, pdata->phy_link);
+
+	spin_lock_irqsave(&pdata->lock, flags);
+
+	if (phydev->link) {
+		/* Flow control support */
+		if (pdata->pause_autoneg) {
+			if (phydev->pause || phydev->asym_pause) {
+				pdata->tx_pause = 1;
+				pdata->rx_pause = 1;
+			} else {
+				pdata->tx_pause = 0;
+				pdata->rx_pause = 0;
+			}
+		}
+
+		if (pdata->tx_pause != pdata->phy_tx_pause) {
+			hw_if->config_tx_flow_control(pdata);
+			pdata->phy_tx_pause = pdata->tx_pause;
+		}
+
+		if (pdata->rx_pause != pdata->phy_rx_pause) {
+			hw_if->config_rx_flow_control(pdata);
+			pdata->phy_rx_pause = pdata->rx_pause;
+		}
+
+		/* Speed support */
+		if (phydev->speed != pdata->phy_speed) {
+			new_state = 1;
+
+			switch (phydev->speed) {
+			case SPEED_10000:
+				hw_if->set_xgmii_speed(pdata);
+				break;
+
+			case SPEED_2500:
+				hw_if->set_gmii_2500_speed(pdata);
+				break;
+
+			case SPEED_1000:
+				hw_if->set_gmii_speed(pdata);
+				break;
+			}
+			pdata->phy_speed = phydev->speed;
+		}
+
+		if (phydev->link != pdata->phy_link) {
+			new_state = 1;
+			pdata->phy_link = 1;
+		}
+	} else if (pdata->phy_link) {
+		new_state = 1;
+		pdata->phy_link = 0;
+		pdata->phy_speed = SPEED_UNKNOWN;
+	}
+
+	if (new_state)
+		phy_print_status(phydev);
+
+	spin_unlock_irqrestore(&pdata->lock, flags);
+
+	DBGPR_MDIO("<--xgbe_adjust_link\n");
+}
+
+void xgbe_dump_phy_registers(struct xgbe_prv_data *pdata)
+{
+	struct device *dev = pdata->dev;
+	struct phy_device *phydev = pdata->mii->phy_map[XGBE_PRTAD];
+	int i;
+
+	dev_alert(dev, "\n************* PHY Reg dump **********************\n");
+
+	dev_alert(dev, "PCS Control Reg (%#04x) = %#04x\n", MDIO_CTRL1,
+		  XMDIO_READ(pdata, MDIO_MMD_PCS, MDIO_CTRL1));
+	dev_alert(dev, "PCS Status Reg (%#04x) = %#04x\n", MDIO_STAT1,
+		  XMDIO_READ(pdata, MDIO_MMD_PCS, MDIO_STAT1));
+	dev_alert(dev, "Phy Id (PHYS ID 1 %#04x)= %#04x\n", MDIO_DEVID1,
+		  XMDIO_READ(pdata, MDIO_MMD_PCS, MDIO_DEVID1));
+	dev_alert(dev, "Phy Id (PHYS ID 2 %#04x)= %#04x\n", MDIO_DEVID2,
+		  XMDIO_READ(pdata, MDIO_MMD_PCS, MDIO_DEVID2));
+	dev_alert(dev, "Devices in Package (%#04x)= %#04x\n", MDIO_DEVS1,
+		  XMDIO_READ(pdata, MDIO_MMD_PCS, MDIO_DEVS1));
+	dev_alert(dev, "Devices in Package (%#04x)= %#04x\n", MDIO_DEVS2,
+		  XMDIO_READ(pdata, MDIO_MMD_PCS, MDIO_DEVS2));
+
+	dev_alert(dev, "Auto-Neg Control Reg (%#04x) = %#04x\n", MDIO_CTRL1,
+		  XMDIO_READ(pdata, MDIO_MMD_AN, MDIO_CTRL1));
+	dev_alert(dev, "Auto-Neg Status Reg (%#04x) = %#04x\n", MDIO_STAT1,
+		  XMDIO_READ(pdata, MDIO_MMD_AN, MDIO_STAT1));
+	dev_alert(dev, "Auto-Neg Ad Reg 1 (%#04x) = %#04x\n",
+		  MDIO_AN_ADVERTISE,
+		  XMDIO_READ(pdata, MDIO_MMD_AN, MDIO_AN_ADVERTISE));
+	dev_alert(dev, "Auto-Neg Ad Reg 2 (%#04x) = %#04x\n",
+		  MDIO_AN_ADVERTISE + 1,
+		  XMDIO_READ(pdata, MDIO_MMD_AN, MDIO_AN_ADVERTISE + 1));
+	dev_alert(dev, "Auto-Neg Ad Reg 3 (%#04x) = %#04x\n",
+		  MDIO_AN_ADVERTISE + 2,
+		  XMDIO_READ(pdata, MDIO_MMD_AN, MDIO_AN_ADVERTISE + 2));
+	dev_alert(dev, "Auto-Neg Completion Reg (%#04x) = %#04x\n",
+		  MDIO_AN_COMP_STAT,
+		  XMDIO_READ(pdata, MDIO_MMD_AN, MDIO_AN_COMP_STAT));
+
+	dev_alert(dev, "MMD Device Mask = %#x\n",
+		  phydev->c45_ids.devices_in_package);
+	for (i = 0; i < ARRAY_SIZE(phydev->c45_ids.device_ids); i++)
+		dev_alert(dev, "  MMD %d: ID = %#08x\n", i,
+			  phydev->c45_ids.device_ids[i]);
+
+	dev_alert(dev, "\n*************************************************\n");
+}
+
+int xgbe_mdio_register(struct xgbe_prv_data *pdata)
+{
+	struct net_device *netdev = pdata->netdev;
+	struct device_node *phy_node;
+	struct mii_bus *mii;
+	struct phy_device *phydev;
+	int ret = 0;
+
+	DBGPR("-->xgbe_mdio_register\n");
+
+	/* Retrieve the phy-handle */
+	phy_node = of_parse_phandle(pdata->dev->of_node, "phy-handle", 0);
+	if (!phy_node) {
+		dev_err(pdata->dev, "unable to parse phy-handle\n");
+		return -EINVAL;
+	}
+
+	/* Register with the MDIO bus */
+	mii = mdiobus_alloc();
+	if (mii == NULL) {
+		dev_err(pdata->dev, "mdiobus_alloc failed\n");
+		ret = -ENOMEM;
+		goto err_node_get;
+	}
+
+	/* Register on the MDIO bus (don't probe any PHYs) */
+	mii->name = XGBE_PHY_NAME;
+	mii->read = xgbe_mdio_read;
+	mii->write = xgbe_mdio_write;
+	snprintf(mii->id, sizeof(mii->id), "%s", pdata->mii_bus_id);
+	mii->priv = pdata;
+	mii->phy_mask = ~0;
+	mii->parent = pdata->dev;
+	ret = mdiobus_register(mii);
+	if (ret) {
+		dev_err(pdata->dev, "mdiobus_register failed\n");
+		goto err_mdiobus_alloc;
+	}
+	DBGPR("  mdiobus_register succeeded for %s\n", pdata->mii_bus_id);
+
+	/* Probe the PCS using Clause 45 */
+	phydev = get_phy_device(mii, XGBE_PRTAD, true);
+	if (IS_ERR(phydev) || !phydev ||
+	    !phydev->c45_ids.device_ids[MDIO_MMD_PCS]) {
+		dev_err(pdata->dev, "get_phy_device failed\n");
+		ret = phydev ? PTR_ERR(phydev) : -ENOLINK;
+		goto err_mdiobus_register;
+	}
+	request_module(MDIO_MODULE_PREFIX MDIO_ID_FMT,
+		       MDIO_ID_ARGS(phydev->c45_ids.device_ids[MDIO_MMD_PCS]));
+
+	of_node_get(phy_node);
+	phydev->dev.of_node = phy_node;
+	ret = phy_device_register(phydev);
+	if (ret) {
+		dev_err(pdata->dev, "phy_device_register failed\n");
+		of_node_put(phy_node);
+		goto err_phy_device;
+	}
+
+	/* Add a reference to the PHY driver so it can't be unloaded */
+	pdata->phy_module = phydev->dev.driver ?
+			    phydev->dev.driver->owner : NULL;
+	if (!try_module_get(pdata->phy_module)) {
+		dev_err(pdata->dev, "try_module_get failed\n");
+		ret = -EIO;
+		goto err_phy_device;
+	}
+
+	pdata->mii = mii;
+	pdata->mdio_mmd = MDIO_MMD_PCS;
+
+	pdata->phy_link = -1;
+	pdata->phy_speed = SPEED_UNKNOWN;
+	pdata->phy_tx_pause = pdata->tx_pause;
+	pdata->phy_rx_pause = pdata->rx_pause;
+
+	ret = phy_connect_direct(netdev, phydev, &xgbe_adjust_link,
+				 pdata->phy_mode);
+	if (ret) {
+		netdev_err(netdev, "phy_connect_direct failed\n");
+		goto err_phy_device;
+	}
+
+	if (!phydev->drv || (phydev->drv->phy_id == 0)) {
+		netdev_err(netdev, "phy_id not valid\n");
+		return -ENODEV;
+		goto err_phy_connect;
+	}
+	DBGPR("  phy_connect_direct succeeded for PHY %s, link=%d\n",
+	      dev_name(&phydev->dev), phydev->link);
+
+	phydev->autoneg = pdata->default_autoneg;
+	if (phydev->autoneg == AUTONEG_DISABLE) {
+		/* Add settings needed to force speed */
+		phydev->supported |= SUPPORTED_1000baseT_Full;
+		phydev->supported |= SUPPORTED_10000baseT_Full;
+
+		phydev->speed = pdata->default_speed;
+		phydev->duplex = DUPLEX_FULL;
+
+		phydev->advertising &= ~ADVERTISED_Autoneg;
+	}
+
+	pdata->phydev = phydev;
+
+	of_node_put(phy_node);
+
+	DBGPHY_REGS(pdata);
+
+	DBGPR("<--xgbe_mdio_register\n");
+
+	return 0;
+
+err_phy_connect:
+	phy_disconnect(phydev);
+
+err_phy_device:
+	phy_device_free(phydev);
+
+err_mdiobus_register:
+	mdiobus_unregister(mii);
+
+err_mdiobus_alloc:
+	mdiobus_free(mii);
+
+err_node_get:
+	of_node_put(phy_node);
+
+	return ret;
+}
+
+void xgbe_mdio_unregister(struct xgbe_prv_data *pdata)
+{
+	DBGPR("-->xgbe_mdio_unregister\n");
+
+	phy_disconnect(pdata->phydev);
+	pdata->phydev = NULL;
+
+	module_put(pdata->phy_module);
+	pdata->phy_module = NULL;
+
+	mdiobus_unregister(pdata->mii);
+	pdata->mii->priv = NULL;
+
+	mdiobus_free(pdata->mii);
+	pdata->mii = NULL;
+
+	DBGPR("<--xgbe_mdio_unregister\n");
+}
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
new file mode 100644
index 0000000..9a5bfe6
--- /dev/null
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -0,0 +1,676 @@
+/*
+ * AMD 10Gb Ethernet driver
+ *
+ * This file is available to you under your choice of the following two
+ * licenses:
+ *
+ * License 1: GPLv2
+ *
+ * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ *
+ * This file is free software; you may copy, redistribute and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation, either version 2 of the License, or (at
+ * your option) any later version.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ *
+ * This file incorporates work covered by the following copyright and
+ * permission notice:
+ *     The Synopsys DWC ETHER XGMAC Software Driver and documentation
+ *     (hereinafter "Software") is an unsupported proprietary work of Synopsys,
+ *     Inc. unless otherwise expressly agreed to in writing between Synopsys
+ *     and you.
+ *
+ *     The Software IS NOT an item of Licensed Software or Licensed Product
+ *     under any End User Software License Agreement or Agreement for Licensed
+ *     Product with Synopsys or any supplement thereto.  Permission is hereby
+ *     granted, free of charge, to any person obtaining a copy of this software
+ *     annotated with this license and the Software, to deal in the Software
+ *     without restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or sell copies
+ *     of the Software, and to permit persons to whom the Software is furnished
+ *     to do so, subject to the following conditions:
+ *
+ *     The above copyright notice and this permission notice shall be included
+ *     in all copies or substantial portions of the Software.
+ *
+ *     THIS SOFTWARE IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN "AS IS"
+ *     BASIS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
+ *     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+ *     PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS
+ *     BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ *     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
+ *     THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ *
+ * License 2: Modified BSD
+ *
+ * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ * All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Advanced Micro Devices, Inc. nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
+ * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ * This file incorporates work covered by the following copyright and
+ * permission notice:
+ *     The Synopsys DWC ETHER XGMAC Software Driver and documentation
+ *     (hereinafter "Software") is an unsupported proprietary work of Synopsys,
+ *     Inc. unless otherwise expressly agreed to in writing between Synopsys
+ *     and you.
+ *
+ *     The Software IS NOT an item of Licensed Software or Licensed Product
+ *     under any End User Software License Agreement or Agreement for Licensed
+ *     Product with Synopsys or any supplement thereto.  Permission is hereby
+ *     granted, free of charge, to any person obtaining a copy of this software
+ *     annotated with this license and the Software, to deal in the Software
+ *     without restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or sell copies
+ *     of the Software, and to permit persons to whom the Software is furnished
+ *     to do so, subject to the following conditions:
+ *
+ *     The above copyright notice and this permission notice shall be included
+ *     in all copies or substantial portions of the Software.
+ *
+ *     THIS SOFTWARE IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN "AS IS"
+ *     BASIS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
+ *     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+ *     PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS
+ *     BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ *     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
+ *     THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#ifndef __XGBE_H__
+#define __XGBE_H__
+
+#include <linux/dma-mapping.h>
+#include <linux/netdevice.h>
+#include <linux/workqueue.h>
+#include <linux/phy.h>
+
+
+#define XGBE_DRV_NAME		"amd-xgbe"
+#define XGBE_DRV_VERSION	"1.0.0-a"
+#define XGBE_DRV_DESC		"AMD 10 Gigabit Ethernet Driver"
+
+/* Descriptor related defines */
+#define TX_DESC_CNT		512
+#define TX_DESC_MIN_FREE	(TX_DESC_CNT >> 3)
+#define TX_DESC_MAX_PROC	(TX_DESC_CNT >> 1)
+#define RX_DESC_CNT		512
+
+#define TX_MAX_BUF_SIZE		(0x3fff & ~(64 - 1))
+
+#define RX_MIN_BUF_SIZE		(ETH_FRAME_LEN + ETH_FCS_LEN + VLAN_HLEN)
+#define RX_BUF_ALIGN		64
+
+#define MAX_DMA_CHANNELS	16
+#define DMA_ARDOMAIN_SETTING	0x2
+#define DMA_ARCACHE_SETTING	0xb
+#define DMA_AWDOMAIN_SETTING	0x2
+#define DMA_AWCACHE_SETTING	0x7
+#define DMA_INTERRUPT_MASK	0x31c7
+
+#define XGMAC_MIN_PACKET	60
+#define XGMAC_STD_PACKET_MTU	1500
+#define XGMAC_MAX_STD_PACKET	1518
+#define XGMAC_JUMBO_PACKET_MTU	9000
+#define XGMAC_MAX_JUMBO_PACKET	9018
+
+#define MAX_MULTICAST_LIST	14
+#define TX_FLAGS_IP_PKT		0x00000001
+#define TX_FLAGS_TCP_PKT	0x00000002
+
+/* MDIO bus phy name */
+#define XGBE_PHY_NAME		"amd_xgbe_phy"
+#define XGBE_PRTAD		0
+
+/* Driver PMT macros */
+#define XGMAC_DRIVER_CONTEXT	1
+#define XGMAC_IOCTL_CONTEXT	2
+
+#define FIFO_SIZE_B(x)		(x)
+#define FIFO_SIZE_KB(x)		(x * 1024)
+
+#define XGBE_TC_CNT		2
+
+/* Helper macro for descriptor handling
+ *  Always use GET_DESC_DATA to access the descriptor data
+ *  since the index is free-running and needs to be and-ed
+ *  with the descriptor count value of the ring to index to
+ *  the proper descriptor data.
+ */
+#define GET_DESC_DATA(_ring, _idx)				\
+	((_ring)->rdata +					\
+	 ((_idx) & ((_ring)->rdesc_count - 1)))
+
+
+/* Default coalescing parameters */
+#define XGMAC_INIT_DMA_TX_USECS		100
+#define XGMAC_INIT_DMA_TX_FRAMES	16
+
+#define XGMAC_MAX_DMA_RIWT		0xff
+#define XGMAC_INIT_DMA_RX_USECS		100
+#define XGMAC_INIT_DMA_RX_FRAMES	16
+
+/* Flow control queue count */
+#define XGMAC_MAX_FLOW_CONTROL_QUEUES	8
+
+
+struct xgbe_prv_data;
+
+struct xgbe_packet_data {
+	unsigned int attributes;
+
+	unsigned int errors;
+
+	unsigned int rdesc_count;
+	unsigned int length;
+
+	unsigned int header_len;
+	unsigned int tcp_header_len;
+	unsigned int tcp_payload_len;
+	unsigned short mss;
+
+	unsigned short vlan_ctag;
+};
+
+/* Common Rx and Tx descriptor mapping */
+struct xgbe_ring_desc {
+	unsigned int desc0;
+	unsigned int desc1;
+	unsigned int desc2;
+	unsigned int desc3;
+};
+
+/* Structure used to hold information related to the descriptor
+ * and the packet associated with the descriptor (always use
+ * use the GET_DESC_DATA macro to access this data from the ring)
+ */
+struct xgbe_ring_data {
+	struct xgbe_ring_desc *rdesc;	/* Virtual address of descriptor */
+	dma_addr_t rdesc_dma;		/* DMA address of descriptor */
+
+	struct sk_buff *skb;		/* Virtual address of SKB */
+	dma_addr_t skb_dma;		/* DMA address of SKB data */
+	unsigned int skb_dma_len;	/* Length of SKB DMA area */
+	unsigned int tso_header;        /* TSO header indicator */
+
+	unsigned short len;		/* Length of received Rx packet */
+
+	unsigned int interrupt;		/* Interrupt indicator */
+
+	unsigned int mapped_as_page;
+};
+
+struct xgbe_ring {
+	/* Ring lock - used just for TX rings at the moment */
+	spinlock_t lock;
+
+	/* Per packet related information */
+	struct xgbe_packet_data packet_data;
+
+	/* Virtual/DMA addresses and count of allocated descriptor memory */
+	struct xgbe_ring_desc *rdesc;
+	dma_addr_t rdesc_dma;
+	unsigned int rdesc_count;
+
+	/* Array of descriptor data corresponding the descriptor memory
+	 * (always use the GET_DESC_DATA macro to access this data)
+	 */
+	struct xgbe_ring_data *rdata;
+
+	/* Ring index values
+	 *  cur   - Tx: index of descriptor to be used for current transfer
+	 *          Rx: index of descriptor to check for packet availability
+	 *  dirty - Tx: index of descriptor to check for transfer complete
+	 *          Rx: count of descriptors in which a packet has been received
+	 *              (used with skb_realloc_index to refresh the ring)
+	 */
+	unsigned int cur;
+	unsigned int dirty;
+
+	/* Coalesce frame count used for interrupt bit setting */
+	unsigned int coalesce_count;
+
+	union {
+		struct {
+			unsigned int queue_stopped;
+			unsigned short cur_mss;
+			unsigned short cur_vlan_ctag;
+		} tx;
+
+		struct {
+			unsigned int realloc_index;
+			unsigned int realloc_threshold;
+		} rx;
+	};
+} ____cacheline_aligned;
+
+/* Structure used to describe the descriptor rings associated with
+ * a DMA channel.
+ */
+struct xgbe_channel {
+	char name[16];
+
+	/* Address of private data area for device */
+	struct xgbe_prv_data *pdata;
+
+	/* Queue index and base address of queue's DMA registers */
+	unsigned int queue_index;
+	void __iomem *dma_regs;
+
+	unsigned int saved_ier;
+
+	unsigned int tx_timer_active;
+	struct hrtimer tx_timer;
+
+	struct xgbe_ring *tx_ring;
+	struct xgbe_ring *rx_ring;
+} ____cacheline_aligned;
+
+enum xgbe_int {
+	XGMAC_INT_DMA_ISR_DC0IS,
+	XGMAC_INT_DMA_CH_SR_TI,
+	XGMAC_INT_DMA_CH_SR_TPS,
+	XGMAC_INT_DMA_CH_SR_TBU,
+	XGMAC_INT_DMA_CH_SR_RI,
+	XGMAC_INT_DMA_CH_SR_RBU,
+	XGMAC_INT_DMA_CH_SR_RPS,
+	XGMAC_INT_DMA_CH_SR_FBE,
+	XGMAC_INT_DMA_ALL,
+};
+
+enum xgbe_int_state {
+	XGMAC_INT_STATE_SAVE,
+	XGMAC_INT_STATE_RESTORE,
+};
+
+enum xgbe_mtl_fifo_size {
+	XGMAC_MTL_FIFO_SIZE_256  = 0x00,
+	XGMAC_MTL_FIFO_SIZE_512  = 0x01,
+	XGMAC_MTL_FIFO_SIZE_1K   = 0x03,
+	XGMAC_MTL_FIFO_SIZE_2K   = 0x07,
+	XGMAC_MTL_FIFO_SIZE_4K   = 0x0f,
+	XGMAC_MTL_FIFO_SIZE_8K   = 0x1f,
+	XGMAC_MTL_FIFO_SIZE_16K  = 0x3f,
+	XGMAC_MTL_FIFO_SIZE_32K  = 0x7f,
+	XGMAC_MTL_FIFO_SIZE_64K  = 0xff,
+	XGMAC_MTL_FIFO_SIZE_128K = 0x1ff,
+	XGMAC_MTL_FIFO_SIZE_256K = 0x3ff,
+};
+
+struct xgbe_mmc_stats {
+	/* Tx Stats */
+	u64 txoctetcount_gb;
+	u64 txframecount_gb;
+	u64 txbroadcastframes_g;
+	u64 txmulticastframes_g;
+	u64 tx64octets_gb;
+	u64 tx65to127octets_gb;
+	u64 tx128to255octets_gb;
+	u64 tx256to511octets_gb;
+	u64 tx512to1023octets_gb;
+	u64 tx1024tomaxoctets_gb;
+	u64 txunicastframes_gb;
+	u64 txmulticastframes_gb;
+	u64 txbroadcastframes_gb;
+	u64 txunderflowerror;
+	u64 txoctetcount_g;
+	u64 txframecount_g;
+	u64 txpauseframes;
+	u64 txvlanframes_g;
+
+	/* Rx Stats */
+	u64 rxframecount_gb;
+	u64 rxoctetcount_gb;
+	u64 rxoctetcount_g;
+	u64 rxbroadcastframes_g;
+	u64 rxmulticastframes_g;
+	u64 rxcrcerror;
+	u64 rxrunterror;
+	u64 rxjabbererror;
+	u64 rxundersize_g;
+	u64 rxoversize_g;
+	u64 rx64octets_gb;
+	u64 rx65to127octets_gb;
+	u64 rx128to255octets_gb;
+	u64 rx256to511octets_gb;
+	u64 rx512to1023octets_gb;
+	u64 rx1024tomaxoctets_gb;
+	u64 rxunicastframes_g;
+	u64 rxlengtherror;
+	u64 rxoutofrangetype;
+	u64 rxpauseframes;
+	u64 rxfifooverflow;
+	u64 rxvlanframes_gb;
+	u64 rxwatchdogerror;
+};
+
+struct xgbe_hw_if {
+	int (*tx_complete)(struct xgbe_ring_desc *);
+
+	int (*set_promiscuous_mode)(struct xgbe_prv_data *, unsigned int);
+	int (*set_all_multicast_mode)(struct xgbe_prv_data *, unsigned int);
+	int (*set_addn_mac_addrs)(struct xgbe_prv_data *, unsigned int);
+	int (*set_mac_address)(struct xgbe_prv_data *, u8 *addr);
+
+	int (*enable_rx_csum)(struct xgbe_prv_data *);
+	int (*disable_rx_csum)(struct xgbe_prv_data *);
+
+	int (*enable_rx_vlan_stripping)(struct xgbe_prv_data *);
+	int (*disable_rx_vlan_stripping)(struct xgbe_prv_data *);
+
+	int (*read_mmd_regs)(struct xgbe_prv_data *, int, int);
+	void (*write_mmd_regs)(struct xgbe_prv_data *, int, int, int);
+	int (*set_gmii_speed)(struct xgbe_prv_data *);
+	int (*set_gmii_2500_speed)(struct xgbe_prv_data *);
+	int (*set_xgmii_speed)(struct xgbe_prv_data *);
+
+	void (*enable_tx)(struct xgbe_prv_data *);
+	void (*disable_tx)(struct xgbe_prv_data *);
+	void (*enable_rx)(struct xgbe_prv_data *);
+	void (*disable_rx)(struct xgbe_prv_data *);
+
+	void (*powerup_tx)(struct xgbe_prv_data *);
+	void (*powerdown_tx)(struct xgbe_prv_data *);
+	void (*powerup_rx)(struct xgbe_prv_data *);
+	void (*powerdown_rx)(struct xgbe_prv_data *);
+
+	int (*init)(struct xgbe_prv_data *);
+	int (*exit)(struct xgbe_prv_data *);
+
+	int (*enable_int)(struct xgbe_channel *, enum xgbe_int);
+	int (*disable_int)(struct xgbe_channel *, enum xgbe_int);
+	void (*pre_xmit)(struct xgbe_channel *);
+	int (*dev_read)(struct xgbe_channel *);
+	void (*tx_desc_init)(struct xgbe_channel *);
+	void (*rx_desc_init)(struct xgbe_channel *);
+	void (*rx_desc_reset)(struct xgbe_ring_data *);
+	void (*tx_desc_reset)(struct xgbe_ring_data *);
+	int (*is_last_desc)(struct xgbe_ring_desc *);
+	int (*is_context_desc)(struct xgbe_ring_desc *);
+
+	/* For FLOW ctrl */
+	int (*config_tx_flow_control)(struct xgbe_prv_data *);
+	int (*config_rx_flow_control)(struct xgbe_prv_data *);
+
+	/* For RX coalescing */
+	int (*config_rx_coalesce)(struct xgbe_prv_data *);
+	int (*config_tx_coalesce)(struct xgbe_prv_data *);
+	unsigned int (*usec_to_riwt)(struct xgbe_prv_data *, unsigned int);
+	unsigned int (*riwt_to_usec)(struct xgbe_prv_data *, unsigned int);
+
+	/* For RX and TX threshold config */
+	int (*config_rx_threshold)(struct xgbe_prv_data *, unsigned int);
+	int (*config_tx_threshold)(struct xgbe_prv_data *, unsigned int);
+
+	/* For RX and TX Store and Forward Mode config */
+	int (*config_rsf_mode)(struct xgbe_prv_data *, unsigned int);
+	int (*config_tsf_mode)(struct xgbe_prv_data *, unsigned int);
+
+	/* For TX DMA Operate on Second Frame config */
+	int (*config_osp_mode)(struct xgbe_prv_data *);
+
+	/* For RX and TX PBL config */
+	int (*config_rx_pbl_val)(struct xgbe_prv_data *);
+	int (*get_rx_pbl_val)(struct xgbe_prv_data *);
+	int (*config_tx_pbl_val)(struct xgbe_prv_data *);
+	int (*get_tx_pbl_val)(struct xgbe_prv_data *);
+	int (*config_pblx8)(struct xgbe_prv_data *);
+
+	/* For MMC statistics */
+	void (*rx_mmc_int)(struct xgbe_prv_data *);
+	void (*tx_mmc_int)(struct xgbe_prv_data *);
+	void (*read_mmc_stats)(struct xgbe_prv_data *);
+};
+
+struct xgbe_desc_if {
+	int (*alloc_ring_resources)(struct xgbe_prv_data *);
+	void (*free_ring_resources)(struct xgbe_prv_data *);
+	int (*map_tx_skb)(struct xgbe_channel *, struct sk_buff *);
+	void (*realloc_skb)(struct xgbe_channel *);
+	void (*unmap_skb)(struct xgbe_prv_data *, struct xgbe_ring_data *);
+	void (*wrapper_tx_desc_init)(struct xgbe_prv_data *);
+	void (*wrapper_rx_desc_init)(struct xgbe_prv_data *);
+};
+
+/* This structure contains flags that indicate what hardware features
+ * or configurations are present in the device.
+ */
+struct xgbe_hw_features {
+	/* HW Feature Register0 */
+	unsigned int gmii;		/* 1000 Mbps support */
+	unsigned int vlhash;		/* VLAN Hash Filter */
+	unsigned int sma;		/* SMA(MDIO) Interface */
+	unsigned int rwk;		/* PMT remote wake-up packet */
+	unsigned int mgk;		/* PMT magic packet */
+	unsigned int mmc;		/* RMON module */
+	unsigned int aoe;		/* ARP Offload */
+	unsigned int ts;		/* IEEE 1588-2008 Adavanced Timestamp */
+	unsigned int eee;		/* Energy Efficient Ethernet */
+	unsigned int tx_coe;		/* Tx Checksum Offload */
+	unsigned int rx_coe;		/* Rx Checksum Offload */
+	unsigned int addn_mac;		/* Additional MAC Addresses */
+	unsigned int ts_src;		/* Timestamp Source */
+	unsigned int sa_vlan_ins;	/* Source Address or VLAN Insertion */
+
+	/* HW Feature Register1 */
+	unsigned int rx_fifo_size;	/* MTL Receive FIFO Size */
+	unsigned int tx_fifo_size;	/* MTL Transmit FIFO Size */
+	unsigned int adv_ts_hi;		/* Advance Timestamping High Word */
+	unsigned int dcb;		/* DCB Feature */
+	unsigned int sph;		/* Split Header Feature */
+	unsigned int tso;		/* TCP Segmentation Offload */
+	unsigned int dma_debug;		/* DMA Debug Registers */
+	unsigned int rss;		/* Receive Side Scaling */
+	unsigned int hash_table_size;	/* Hash Table Size */
+	unsigned int l3l4_filter_num;	/* Number of L3-L4 Filters */
+
+	/* HW Feature Register2 */
+	unsigned int rx_q_cnt;		/* Number of MTL Receive Queues */
+	unsigned int tx_q_cnt;		/* Number of MTL Transmit Queues */
+	unsigned int rx_ch_cnt;		/* Number of DMA Receive Channels */
+	unsigned int tx_ch_cnt;		/* Number of DMA Transmit Channels */
+	unsigned int pps_out_num;	/* Number of PPS outputs */
+	unsigned int aux_snap_num;	/* Number of Aux snapshot inputs */
+};
+
+struct xgbe_prv_data {
+	struct net_device *netdev;
+	struct platform_device *pdev;
+	struct device *dev;
+
+	/* XGMAC/XPCS related mmio registers */
+	void __iomem *xgmac_regs;	/* XGMAC CSRs */
+	void __iomem *xpcs_regs;	/* XPCS MMD registers */
+
+	/* Overall device lock */
+	spinlock_t lock;
+
+	/* XPCS indirect addressing mutex */
+	struct mutex xpcs_mutex;
+
+	int irq_number;
+
+	struct xgbe_hw_if hw_if;
+	struct xgbe_desc_if desc_if;
+
+	/* Rings for Tx/Rx on a DMA channel */
+	struct xgbe_channel *channel;
+	unsigned int channel_count;
+	unsigned int tx_ring_count;
+	unsigned int tx_desc_count;
+	unsigned int rx_ring_count;
+	unsigned int rx_desc_count;
+
+	/* Tx/Rx common settings */
+	unsigned int pblx8;
+
+	/* Tx settings */
+	unsigned int tx_sf_mode;
+	unsigned int tx_threshold;
+	unsigned int tx_pbl;
+	unsigned int tx_osp_mode;
+
+	/* Rx settings */
+	unsigned int rx_sf_mode;
+	unsigned int rx_threshold;
+	unsigned int rx_pbl;
+
+	/* Tx coalescing settings */
+	unsigned int tx_usecs;
+	unsigned int tx_frames;
+
+	/* Rx coalescing settings */
+	unsigned int rx_riwt;
+	unsigned int rx_frames;
+
+	/* Current MTU */
+	unsigned int rx_buf_size;
+
+	/* Flow control settings */
+	unsigned int pause_autoneg;
+	unsigned int tx_pause;
+	unsigned int rx_pause;
+
+	/* MDIO settings */
+	struct module *phy_module;
+	char *mii_bus_id;
+	struct mii_bus *mii;
+	int mdio_mmd;
+	struct phy_device *phydev;
+	int default_autoneg;
+	int default_speed;
+
+	/* Current PHY settings */
+	phy_interface_t phy_mode;
+	int phy_link;
+	int phy_speed;
+	unsigned int phy_tx_pause;
+	unsigned int phy_rx_pause;
+
+	/* Netdev related settings */
+	netdev_features_t netdev_features;
+	struct napi_struct napi;
+	struct xgbe_mmc_stats mmc_stats;
+
+	/* System clock value used for Rx watchdog */
+	struct clk *sysclock;
+
+	/* Hardware features of the device */
+	struct xgbe_hw_features hw_feat;
+
+	/* Device restart work structure */
+	struct work_struct restart_work;
+
+	/* Keeps track of power mode */
+	unsigned int power_down;
+
+#ifdef CONFIG_DEBUG_FS
+	struct dentry *xgbe_debugfs;
+
+	unsigned int debugfs_xgmac_reg;
+
+	unsigned int debugfs_xpcs_mmd;
+	unsigned int debugfs_xpcs_reg;
+#endif
+};
+
+/* Function prototypes*/
+
+void xgbe_init_function_ptrs_dev(struct xgbe_hw_if *);
+void xgbe_init_function_ptrs_desc(struct xgbe_desc_if *);
+struct net_device_ops *xgbe_get_netdev_ops(void);
+struct ethtool_ops *xgbe_get_ethtool_ops(void);
+
+int xgbe_mdio_register(struct xgbe_prv_data *);
+void xgbe_mdio_unregister(struct xgbe_prv_data *);
+void xgbe_dump_phy_registers(struct xgbe_prv_data *);
+void xgbe_dump_tx_desc(struct xgbe_ring *, unsigned int, unsigned int,
+		       unsigned int);
+void xgbe_dump_rx_desc(struct xgbe_ring *, struct xgbe_ring_desc *,
+		       unsigned int);
+void xgbe_print_pkt(struct net_device *, struct sk_buff *, bool);
+void xgbe_get_all_hw_features(struct xgbe_prv_data *);
+int xgbe_powerup(struct net_device *, unsigned int);
+int xgbe_powerdown(struct net_device *, unsigned int);
+void xgbe_init_rx_coalesce(struct xgbe_prv_data *);
+void xgbe_init_tx_coalesce(struct xgbe_prv_data *);
+
+#ifdef CONFIG_DEBUG_FS
+void xgbe_debugfs_init(struct xgbe_prv_data *);
+void xgbe_debugfs_exit(struct xgbe_prv_data *);
+#else
+static inline void xgbe_debugfs_init(struct xgbe_prv_data *pdata) {}
+static inline void xgbe_debugfs_exit(struct xgbe_prv_data *pdata) {}
+#endif /* CONFIG_DEBUG_FS */
+
+/* NOTE: Uncomment for TX and RX DESCRIPTOR DUMP in KERNEL LOG */
+#if 0
+#define XGMAC_ENABLE_TX_DESC_DUMP
+#define XGMAC_ENABLE_RX_DESC_DUMP
+#endif
+
+/* NOTE: Uncomment for TX and RX PACKET DUMP in KERNEL LOG */
+#if 0
+#define XGMAC_ENABLE_TX_PKT_DUMP
+#define XGMAC_ENABLE_RX_PKT_DUMP
+#endif
+
+/* NOTE: Uncomment for function trace log messages in KERNEL LOG */
+#if 0
+#define YDEBUG
+#define YDEBUG_MDIO
+#endif
+
+/* For debug prints */
+#ifdef YDEBUG
+#define DBGPR(x...) pr_alert(x)
+#define DBGPHY_REGS(x...) xgbe_dump_phy_registers(x)
+#else
+#define DBGPR(x...) do { } while (0)
+#define DBGPHY_REGS(x...) do { } while (0)
+#endif
+
+#ifdef YDEBUG_MDIO
+#define DBGPR_MDIO(x...) pr_alert(x)
+#else
+#define DBGPR_MDIO(x...) do { } while (0)
+#endif
+
+#endif
