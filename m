From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 8/8] amd-xgbe: Add traffic class support
Date: Fri, 25 Jul 2014 16:11:39 -0500
Message-ID: <20140725211139.32358.85136.stgit@tlendack-t1.amdoffice.net>
References: <20140725211052.32358.54337.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0206.outbound.protection.outlook.com ([207.46.163.206]:20953
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S934542AbaGYVLt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2014 17:11:49 -0400
In-Reply-To: <20140725211052.32358.54337.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for traffic classes as well as support
for Data Center Bridging interfaces related to traffic classes
and priority flow control.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/Kconfig            |   10 +
 drivers/net/ethernet/amd/xgbe/Makefile      |    1 
 drivers/net/ethernet/amd/xgbe/xgbe-common.h |   22 ++
 drivers/net/ethernet/amd/xgbe/xgbe-dcb.c    |  292 +++++++++++++++++++++++++++
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c    |  192 ++++++++++++++++--
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c    |   33 +++
 drivers/net/ethernet/amd/xgbe/xgbe-main.c   |    5 
 drivers/net/ethernet/amd/xgbe/xgbe.h        |   18 ++
 8 files changed, 546 insertions(+), 27 deletions(-)
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe-dcb.c

diff --git a/drivers/net/ethernet/amd/Kconfig b/drivers/net/ethernet/amd/Kconfig
index 98ef8ff..8319c99 100644
--- a/drivers/net/ethernet/amd/Kconfig
+++ b/drivers/net/ethernet/amd/Kconfig
@@ -192,4 +192,14 @@ config AMD_XGBE
 	  To compile this driver as a module, choose M here: the module
 	  will be called amd-xgbe.
 
+config AMD_XGBE_DCB
+	bool "Data Center Bridging (DCB) support"
+	default n
+	depends on AMD_XGBE && DCB
+	---help---
+	  Say Y here to enable Data Center Bridging (DCB) support in the
+	  driver.
+
+	  If unsure, say N.
+
 endif # NET_VENDOR_AMD
diff --git a/drivers/net/ethernet/amd/xgbe/Makefile b/drivers/net/ethernet/amd/xgbe/Makefile
index 66c49b4..171a7e6 100644
--- a/drivers/net/ethernet/amd/xgbe/Makefile
+++ b/drivers/net/ethernet/amd/xgbe/Makefile
@@ -4,4 +4,5 @@ amd-xgbe-objs := xgbe-main.o xgbe-drv.o xgbe-dev.o \
 		 xgbe-desc.o xgbe-ethtool.o xgbe-mdio.o \
 		 xgbe-ptp.o
 
+amd-xgbe-$(CONFIG_AMD_XGBE_DCB) += xgbe-dcb.o
 amd-xgbe-$(CONFIG_DEBUG_FS) += xgbe-debugfs.o
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-common.h b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
index 646702c..cc25a3a 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-common.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
@@ -322,6 +322,9 @@
 #define MAC_MACA_INC			4
 #define MAC_HTR_INC			4
 
+#define MAC_RQC2_INC			4
+#define MAC_RQC2_Q_PER_REG		4
+
 /* MAC register entry bit positions and sizes */
 #define MAC_HWF0R_ADDMACADRSEL_INDEX	18
 #define MAC_HWF0R_ADDMACADRSEL_WIDTH	5
@@ -361,6 +364,8 @@
 #define MAC_HWF1R_HASHTBLSZ_WIDTH	3
 #define MAC_HWF1R_L3L4FNUM_INDEX	27
 #define MAC_HWF1R_L3L4FNUM_WIDTH	4
+#define MAC_HWF1R_NUMTC_INDEX		21
+#define MAC_HWF1R_NUMTC_WIDTH		3
 #define MAC_HWF1R_RSSEN_INDEX		20
 #define MAC_HWF1R_RSSEN_WIDTH		1
 #define MAC_HWF1R_RXFIFOSIZE_INDEX	0
@@ -433,8 +438,12 @@
 #define MAC_RCR_LM_WIDTH		1
 #define MAC_RCR_RE_INDEX		0
 #define MAC_RCR_RE_WIDTH		1
+#define MAC_RFCR_PFCE_INDEX		8
+#define MAC_RFCR_PFCE_WIDTH		1
 #define MAC_RFCR_RFE_INDEX		0
 #define MAC_RFCR_RFE_WIDTH		1
+#define MAC_RFCR_UP_INDEX		1
+#define MAC_RFCR_UP_WIDTH		1
 #define MAC_RQC0R_RXQ0EN_INDEX		0
 #define MAC_RQC0R_RXQ0EN_WIDTH		2
 #define MAC_SSIR_SNSINC_INDEX		8
@@ -704,6 +713,8 @@
 
 #define MTL_RQDCM_INC			4
 #define MTL_RQDCM_Q_PER_REG		4
+#define MTL_TCPM_INC			4
+#define MTL_TCPM_TC_PER_REG		4
 
 /* MTL register entry bit positions and sizes */
 #define MTL_OMR_ETSALG_INDEX		5
@@ -722,9 +733,6 @@
 #define MTL_Q_TQOMR			0x00
 #define MTL_Q_TQUR			0x04
 #define MTL_Q_TQDR			0x08
-#define MTL_Q_TCECR			0x10
-#define MTL_Q_TCESR			0x14
-#define MTL_Q_TCQWR			0x18
 #define MTL_Q_RQOMR			0x40
 #define MTL_Q_RQMPOCR			0x44
 #define MTL_Q_RQDR			0x4c
@@ -732,8 +740,6 @@
 #define MTL_Q_ISR			0x74
 
 /* MTL queue register entry bit positions and sizes */
-#define MTL_Q_TCQWR_QW_INDEX		0
-#define MTL_Q_TCQWR_QW_WIDTH		21
 #define MTL_Q_RQOMR_EHFC_INDEX		7
 #define MTL_Q_RQOMR_EHFC_WIDTH		1
 #define MTL_Q_RQOMR_RFA_INDEX		8
@@ -748,6 +754,8 @@
 #define MTL_Q_RQOMR_RTC_WIDTH		2
 #define MTL_Q_TQOMR_FTQ_INDEX		0
 #define MTL_Q_TQOMR_FTQ_WIDTH		1
+#define MTL_Q_TQOMR_Q2TCMAP_INDEX	8
+#define MTL_Q_TQOMR_Q2TCMAP_WIDTH	3
 #define MTL_Q_TQOMR_TQS_INDEX		16
 #define MTL_Q_TQOMR_TQS_WIDTH		10
 #define MTL_Q_TQOMR_TSF_INDEX		1
@@ -794,10 +802,14 @@
 #define MTL_TC_INC			MTL_Q_INC
 
 #define MTL_TC_ETSCR			0x10
+#define MTL_TC_ETSSR			0x14
+#define MTL_TC_QWR			0x18
 
 /* MTL traffic class register entry bit positions and sizes */
 #define MTL_TC_ETSCR_TSA_INDEX		0
 #define MTL_TC_ETSCR_TSA_WIDTH		2
+#define MTL_TC_QWR_QW_INDEX		0
+#define MTL_TC_QWR_QW_WIDTH		21
 
 /* MTL traffic class register value */
 #define MTL_TSA_SP			0x00
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dcb.c b/drivers/net/ethernet/amd/xgbe/xgbe-dcb.c
new file mode 100644
index 0000000..ff68dc3
--- /dev/null
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dcb.c
@@ -0,0 +1,292 @@
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
+#include <linux/netdevice.h>
+#include <net/dcbnl.h>
+
+#include "xgbe.h"
+#include "xgbe-common.h"
+
+
+static int xgbe_dcb_ieee_getets(struct net_device *netdev,
+				struct ieee_ets *ets)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+
+	DBGPR("-->%s\n", __func__);
+
+	/* Set number of supported traffic classes */
+	ets->ets_cap = pdata->hw_feat.tc_cnt;
+
+	if (pdata->ets) {
+		ets->cbs = pdata->ets->cbs;
+		memcpy(ets->tc_tx_bw, pdata->ets->tc_tx_bw,
+		       sizeof(ets->tc_tx_bw));
+		memcpy(ets->tc_tsa, pdata->ets->tc_tsa,
+		       sizeof(ets->tc_tsa));
+		memcpy(ets->prio_tc, pdata->ets->prio_tc,
+		       sizeof(ets->prio_tc));
+	}
+
+	DBGPR("<--%s\n", __func__);
+
+	return 0;
+}
+
+static int xgbe_dcb_ieee_setets(struct net_device *netdev,
+				struct ieee_ets *ets)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+	unsigned int i, tc_ets, tc_ets_weight;
+
+	DBGPR("-->%s\n", __func__);
+
+	tc_ets = 0;
+	tc_ets_weight = 0;
+	for (i = 0; i < IEEE_8021QAZ_MAX_TCS; i++) {
+		DBGPR("  TC%u: tx_bw=%hhu, rx_bw=%hhu, tsa=%hhu\n", i,
+		      ets->tc_tx_bw[i], ets->tc_rx_bw[i], ets->tc_tsa[i]);
+		DBGPR("  PRIO%u: TC=%hhu\n", i, ets->prio_tc[i]);
+
+		if ((ets->tc_tx_bw[i] || ets->tc_tsa[i]) &&
+		    (i >= pdata->hw_feat.tc_cnt))
+				return -EINVAL;
+
+		if (ets->prio_tc[i] >= pdata->hw_feat.tc_cnt)
+			return -EINVAL;
+
+		switch (ets->tc_tsa[i]) {
+		case IEEE_8021QAZ_TSA_STRICT:
+			break;
+		case IEEE_8021QAZ_TSA_ETS:
+			tc_ets = 1;
+			tc_ets_weight += ets->tc_tx_bw[i];
+			break;
+
+		default:
+			return -EINVAL;
+		}
+	}
+
+	/* Weights must add up to 100% */
+	if (tc_ets && (tc_ets_weight != 100))
+		return -EINVAL;
+
+	if (!pdata->ets) {
+		pdata->ets = devm_kzalloc(pdata->dev, sizeof(*pdata->ets),
+					  GFP_KERNEL);
+		if (!pdata->ets)
+			return -ENOMEM;
+	}
+
+	memcpy(pdata->ets, ets, sizeof(*pdata->ets));
+
+	pdata->hw_if.config_dcb_tc(pdata);
+
+	DBGPR("<--%s\n", __func__);
+
+	return 0;
+}
+
+static int xgbe_dcb_ieee_getpfc(struct net_device *netdev,
+				struct ieee_pfc *pfc)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+
+	DBGPR("-->%s\n", __func__);
+
+	/* Set number of supported PFC traffic classes */
+	pfc->pfc_cap = pdata->hw_feat.tc_cnt;
+
+	if (pdata->pfc) {
+		pfc->pfc_en = pdata->pfc->pfc_en;
+		pfc->mbc = pdata->pfc->mbc;
+		pfc->delay = pdata->pfc->delay;
+	}
+
+	DBGPR("<--%s\n", __func__);
+
+	return 0;
+}
+
+static int xgbe_dcb_ieee_setpfc(struct net_device *netdev,
+				struct ieee_pfc *pfc)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+
+	DBGPR("-->%s\n", __func__);
+
+	DBGPR("  cap=%hhu, en=%hhx, mbc=%hhu, delay=%hhu\n",
+	      pfc->pfc_cap, pfc->pfc_en, pfc->mbc, pfc->delay);
+
+	if (!pdata->pfc) {
+		pdata->pfc = devm_kzalloc(pdata->dev, sizeof(*pdata->pfc),
+					  GFP_KERNEL);
+		if (!pdata->pfc)
+			return -ENOMEM;
+	}
+
+	memcpy(pdata->pfc, pfc, sizeof(*pdata->pfc));
+
+	pdata->hw_if.config_dcb_pfc(pdata);
+
+	DBGPR("<--%s\n", __func__);
+
+	return 0;
+}
+
+static u8 xgbe_dcb_getdcbx(struct net_device *netdev)
+{
+	DBGPR("<->%s\n", __func__);
+
+	return DCB_CAP_DCBX_HOST | DCB_CAP_DCBX_VER_IEEE;
+}
+
+static u8 xgbe_dcb_setdcbx(struct net_device *netdev, u8 dcbx)
+{
+	u8 support = xgbe_dcb_getdcbx(netdev);
+
+	DBGPR("-->%s\n", __func__);
+
+	DBGPR("  DCBX=%#hhx\n", dcbx);
+
+	if (dcbx & ~support)
+		return 1;
+
+	if ((dcbx & support) != support)
+		return 1;
+
+	DBGPR("<--%s\n", __func__);
+
+	return 0;
+}
+
+static const struct dcbnl_rtnl_ops xgbe_dcbnl_ops = {
+	/* IEEE 802.1Qaz std */
+	.ieee_getets = xgbe_dcb_ieee_getets,
+	.ieee_setets = xgbe_dcb_ieee_setets,
+	.ieee_getpfc = xgbe_dcb_ieee_getpfc,
+	.ieee_setpfc = xgbe_dcb_ieee_setpfc,
+
+	/* DCBX configuration */
+	.getdcbx     = xgbe_dcb_getdcbx,
+	.setdcbx     = xgbe_dcb_setdcbx,
+};
+
+const struct dcbnl_rtnl_ops *xgbe_get_dcbnl_ops(void)
+{
+	return &xgbe_dcbnl_ops;
+}
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 40527afe8..b168190 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -407,7 +407,9 @@ static int xgbe_enable_rx_flow_control(struct xgbe_prv_data *pdata)
 
 static int xgbe_config_tx_flow_control(struct xgbe_prv_data *pdata)
 {
-	if (pdata->tx_pause)
+	struct ieee_pfc *pfc = pdata->pfc;
+
+	if (pdata->tx_pause || (pfc && pfc->pfc_en))
 		xgbe_enable_tx_flow_control(pdata);
 	else
 		xgbe_disable_tx_flow_control(pdata);
@@ -417,7 +419,9 @@ static int xgbe_config_tx_flow_control(struct xgbe_prv_data *pdata)
 
 static int xgbe_config_rx_flow_control(struct xgbe_prv_data *pdata)
 {
-	if (pdata->rx_pause)
+	struct ieee_pfc *pfc = pdata->pfc;
+
+	if (pdata->rx_pause || (pfc && pfc->pfc_en))
 		xgbe_enable_rx_flow_control(pdata);
 	else
 		xgbe_disable_rx_flow_control(pdata);
@@ -427,8 +431,13 @@ static int xgbe_config_rx_flow_control(struct xgbe_prv_data *pdata)
 
 static void xgbe_config_flow_control(struct xgbe_prv_data *pdata)
 {
+	struct ieee_pfc *pfc = pdata->pfc;
+
 	xgbe_config_tx_flow_control(pdata);
 	xgbe_config_rx_flow_control(pdata);
+
+	XGMAC_IOWRITE_BITS(pdata, MAC_RFCR, PFCE,
+			   (pfc && pfc->pfc_en) ? 1 : 0);
 }
 
 static void xgbe_enable_dma_interrupts(struct xgbe_prv_data *pdata)
@@ -1141,6 +1150,87 @@ static int xgbe_config_tstamp(struct xgbe_prv_data *pdata,
 	return 0;
 }
 
+static void xgbe_config_dcb_tc(struct xgbe_prv_data *pdata)
+{
+	struct ieee_ets *ets = pdata->ets;
+	unsigned int total_weight, min_weight, weight;
+	unsigned int i;
+
+	DBGPR("-->%s\n", __func__);
+
+	if (!ets)
+		return;
+
+	/* Set Tx to deficit weighted round robin scheduling algorithm (when
+	 * traffic class is using ETS algorithm)
+	 */
+	XGMAC_IOWRITE_BITS(pdata, MTL_OMR, ETSALG, MTL_ETSALG_DWRR);
+
+	/* Set Traffic Class algorithms */
+	total_weight = pdata->netdev->mtu * pdata->hw_feat.tc_cnt;
+	min_weight = total_weight / 100;
+	if (!min_weight)
+		min_weight = 1;
+
+	for (i = 0; i < pdata->hw_feat.tc_cnt; i++) {
+		switch (ets->tc_tsa[i]) {
+		case IEEE_8021QAZ_TSA_STRICT:
+			DBGPR("  TC%u using SP\n", i);
+			XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_TC_ETSCR, TSA,
+					       MTL_TSA_SP);
+			break;
+		case IEEE_8021QAZ_TSA_ETS:
+			weight = total_weight * ets->tc_tx_bw[i] / 100;
+			weight = clamp(weight, min_weight, total_weight);
+
+			DBGPR("  TC%u using DWRR (weight %u)\n", i, weight);
+			XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_TC_ETSCR, TSA,
+					       MTL_TSA_ETS);
+			XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_TC_QWR, QW,
+					       weight);
+			break;
+		}
+	}
+
+	DBGPR("<--%s\n", __func__);
+}
+
+static void xgbe_config_dcb_pfc(struct xgbe_prv_data *pdata)
+{
+	struct ieee_pfc *pfc = pdata->pfc;
+	struct ieee_ets *ets = pdata->ets;
+	unsigned int mask, reg, reg_val;
+	unsigned int tc, prio;
+
+	DBGPR("-->%s\n", __func__);
+
+	if (!pfc || !ets)
+		return;
+
+	for (tc = 0; tc < pdata->hw_feat.tc_cnt; tc++) {
+		mask = 0;
+		for (prio = 0; prio < IEEE_8021QAZ_MAX_TCS; prio++) {
+			if ((pfc->pfc_en & (1 << prio)) &&
+			    (ets->prio_tc[prio] == tc))
+				mask |= (1 << prio);
+		}
+		mask &= 0xff;
+
+		DBGPR("  TC%u PFC mask=%#x\n", tc, mask);
+		reg = MTL_TCPM0R + (MTL_TCPM_INC * (tc / MTL_TCPM_TC_PER_REG));
+		reg_val = XGMAC_IOREAD(pdata, reg);
+
+		reg_val &= ~(0xff << ((tc % MTL_TCPM_TC_PER_REG) << 3));
+		reg_val |= (mask << ((tc % MTL_TCPM_TC_PER_REG) << 3));
+
+		XGMAC_IOWRITE(pdata, reg, reg_val);
+	}
+
+	xgbe_config_flow_control(pdata);
+
+	DBGPR("<--%s\n", __func__);
+}
+
 static void xgbe_pre_xmit(struct xgbe_channel *channel)
 {
 	struct xgbe_prv_data *pdata = channel->pdata;
@@ -1631,14 +1721,15 @@ static void xgbe_config_mtl_mode(struct xgbe_prv_data *pdata)
 {
 	unsigned int i;
 
-	/* Set Tx to weighted round robin scheduling algorithm (when
-	 * traffic class is using ETS algorithm)
-	 */
+	/* Set Tx to weighted round robin scheduling algorithm */
 	XGMAC_IOWRITE_BITS(pdata, MTL_OMR, ETSALG, MTL_ETSALG_WRR);
 
-	/* Set Tx traffic classes to strict priority algorithm */
-	for (i = 0; i < XGBE_TC_CNT; i++)
-		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_TC_ETSCR, TSA, MTL_TSA_SP);
+	/* Set Tx traffic classes to use WRR algorithm with equal weights */
+	for (i = 0; i < pdata->hw_feat.tc_cnt; i++) {
+		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_TC_ETSCR, TSA,
+				       MTL_TSA_ETS);
+		XGMAC_MTL_IOWRITE_BITS(pdata, i, MTL_TC_QWR, QW, 1);
+	}
 
 	/* Set Rx to strict priority algorithm */
 	XGMAC_IOWRITE_BITS(pdata, MTL_OMR, RAA, MTL_RAA_SP);
@@ -1748,18 +1839,77 @@ static void xgbe_config_rx_fifo_size(struct xgbe_prv_data *pdata)
 		      pdata->rx_q_count, ((fifo_size + 1) * 256));
 }
 
-static void xgbe_config_rx_queue_mapping(struct xgbe_prv_data *pdata)
+static void xgbe_config_queue_mapping(struct xgbe_prv_data *pdata)
 {
-	unsigned int i, reg, reg_val;
-	unsigned int q_count = pdata->rx_q_count;
+	unsigned int qptc, qptc_extra, queue;
+	unsigned int prio_queues;
+	unsigned int ppq, ppq_extra, prio;
+	unsigned int mask;
+	unsigned int i, j, reg, reg_val;
+
+	DBGPR("-->%s\n", __func__);
+
+	/* Map the MTL Tx Queues to Traffic Classes
+	 *   Note: Tx Queues >= Traffic Classes
+	 */
+	qptc = pdata->tx_q_count / pdata->hw_feat.tc_cnt;
+	qptc_extra = pdata->tx_q_count % pdata->hw_feat.tc_cnt;
+
+	for (i = 0, queue = 0; i < pdata->hw_feat.tc_cnt; i++) {
+		for (j = 0; j < qptc; j++) {
+			DBGPR("  TXq%u mapped to TC%u\n", queue, i);
+			XGMAC_MTL_IOWRITE_BITS(pdata, queue, MTL_Q_TQOMR,
+					       Q2TCMAP, i);
+			pdata->q2tc_map[queue++] = i;
+		}
+
+		if (i < qptc_extra) {
+			DBGPR("  TXq%u mapped to TC%u\n", queue, i);
+			XGMAC_MTL_IOWRITE_BITS(pdata, queue, MTL_Q_TQOMR,
+					       Q2TCMAP, i);
+			pdata->q2tc_map[queue++] = i;
+		}
+	}
+
+	/* Map the 8 VLAN priority values to available MTL Rx queues */
+	prio_queues = min_t(unsigned int, IEEE_8021QAZ_MAX_TCS,
+			    pdata->rx_q_count);
+	ppq = IEEE_8021QAZ_MAX_TCS / prio_queues;
+	ppq_extra = IEEE_8021QAZ_MAX_TCS % prio_queues;
+
+	reg = MAC_RQC2R;
+	reg_val = 0;
+	for (i = 0, prio = 0; i < prio_queues;) {
+		mask = 0;
+		for (j = 0; j < ppq; j++) {
+			DBGPR("  PRIO%u mapped to RXq%u\n", prio, i);
+			mask |= (1 << prio);
+			pdata->prio2q_map[prio++] = i;
+		}
+
+		if (i < ppq_extra) {
+			DBGPR("  PRIO%u mapped to RXq%u\n", prio, i);
+			mask |= (1 << prio);
+			pdata->prio2q_map[prio++] = i;
+		}
+
+		reg_val |= (mask << ((i++ % MAC_RQC2_Q_PER_REG) << 3));
+
+		if ((i % MAC_RQC2_Q_PER_REG) && (i != prio_queues))
+			continue;
+
+		XGMAC_IOWRITE(pdata, reg, reg_val);
+		reg += MAC_RQC2_INC;
+		reg_val = 0;
+	}
 
 	/* Select dynamic mapping of MTL Rx queue to DMA Rx channel */
 	reg = MTL_RQDCM0R;
 	reg_val = 0;
-	for (i = 0; i < q_count;) {
+	for (i = 0; i < pdata->rx_q_count;) {
 		reg_val |= (0x80 << ((i++ % MTL_RQDCM_Q_PER_REG) << 3));
 
-		if ((i % MTL_RQDCM_Q_PER_REG) && (i != q_count))
+		if ((i % MTL_RQDCM_Q_PER_REG) && (i != pdata->rx_q_count))
 			continue;
 
 		XGMAC_IOWRITE(pdata, reg, reg_val);
@@ -1767,6 +1917,8 @@ static void xgbe_config_rx_queue_mapping(struct xgbe_prv_data *pdata)
 		reg += MTL_RQDCM_INC;
 		reg_val = 0;
 	}
+
+	DBGPR("<--%s\n", __func__);
 }
 
 static void xgbe_config_flow_control_threshold(struct xgbe_prv_data *pdata)
@@ -2345,9 +2497,7 @@ static int xgbe_init(struct xgbe_prv_data *pdata)
 	 * Initialize MTL related features
 	 */
 	xgbe_config_mtl_mode(pdata);
-	xgbe_config_rx_queue_mapping(pdata);
-	/*TODO: Program the priorities mapped to the Selected Traffic Classes
-		in MTL_TC_Prty_Map0-3 registers */
+	xgbe_config_queue_mapping(pdata);
 	xgbe_config_tsf_mode(pdata, pdata->tx_sf_mode);
 	xgbe_config_rsf_mode(pdata, pdata->rx_sf_mode);
 	xgbe_config_tx_threshold(pdata, pdata->tx_threshold);
@@ -2355,15 +2505,13 @@ static int xgbe_init(struct xgbe_prv_data *pdata)
 	xgbe_config_tx_fifo_size(pdata);
 	xgbe_config_rx_fifo_size(pdata);
 	xgbe_config_flow_control_threshold(pdata);
-	/*TODO: Queue to Traffic Class Mapping (Q2TCMAP) */
 	/*TODO: Error Packet and undersized good Packet forwarding enable
 		(FEP and FUP)
 	 */
+	xgbe_config_dcb_tc(pdata);
+	xgbe_config_dcb_pfc(pdata);
 	xgbe_enable_mtl_interrupts(pdata);
 
-	/* Transmit Class Weight */
-	XGMAC_IOWRITE_BITS(pdata, MTL_Q_TCQWR, QW, 0x10);
-
 	/*
 	 * Initialize MAC related features
 	 */
@@ -2472,5 +2620,9 @@ void xgbe_init_function_ptrs_dev(struct xgbe_hw_if *hw_if)
 	hw_if->get_tstamp_time = xgbe_get_tstamp_time;
 	hw_if->get_tx_tstamp = xgbe_get_tx_tstamp;
 
+	/* For Data Center Bridging config */
+	hw_if->config_dcb_tc = xgbe_config_dcb_tc;
+	hw_if->config_dcb_pfc = xgbe_config_dcb_pfc;
+
 	DBGPR("<--xgbe_init_function_ptrs\n");
 }
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 346a6fd..126aa9d 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -387,6 +387,7 @@ void xgbe_get_all_hw_features(struct xgbe_prv_data *pdata)
 	hw_feat->sph           = XGMAC_GET_BITS(mac_hfr1, MAC_HWF1R, SPHEN);
 	hw_feat->tso           = XGMAC_GET_BITS(mac_hfr1, MAC_HWF1R, TSOEN);
 	hw_feat->dma_debug     = XGMAC_GET_BITS(mac_hfr1, MAC_HWF1R, DBGMEMA);
+	hw_feat->tc_cnt	       = XGMAC_GET_BITS(mac_hfr1, MAC_HWF1R, NUMTC);
 	hw_feat->hash_table_size = XGMAC_GET_BITS(mac_hfr1, MAC_HWF1R,
 						  HASHTBLSZ);
 	hw_feat->l3l4_filter_num = XGMAC_GET_BITS(mac_hfr1, MAC_HWF1R,
@@ -1328,6 +1329,37 @@ static void xgbe_poll_controller(struct net_device *netdev)
 }
 #endif /* End CONFIG_NET_POLL_CONTROLLER */
 
+static int xgbe_setup_tc(struct net_device *netdev, u8 tc)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+	unsigned int offset, queue;
+	u8 i;
+
+	DBGPR("-->%s - tc=%hhu\n", __func__, tc);
+
+	if (tc && (tc != pdata->hw_feat.tc_cnt))
+		return -EINVAL;
+
+	if (tc) {
+		netdev_set_num_tc(netdev, tc);
+		for (i = 0, queue = 0, offset = 0; i < tc; i++) {
+			while ((queue < pdata->tx_q_count) &&
+			       (pdata->q2tc_map[queue] == i))
+				queue++;
+
+			DBGPR("  TC%u using TXq%u-%u\n", i, offset, queue - 1);
+			netdev_set_tc_queue(netdev, i, queue - offset, offset);
+			offset = queue;
+		}
+	} else {
+		netdev_reset_tc(netdev);
+	}
+
+	DBGPR("<--%s\n", __func__);
+
+	return 0;
+}
+
 static int xgbe_set_features(struct net_device *netdev,
 			     netdev_features_t features)
 {
@@ -1376,6 +1408,7 @@ static const struct net_device_ops xgbe_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= xgbe_poll_controller,
 #endif
+	.ndo_setup_tc		= xgbe_setup_tc,
 	.ndo_set_features	= xgbe_set_features,
 };
 
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index 04e6c72..ec977d3 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -400,9 +400,12 @@ static int xgbe_probe(struct platform_device *pdev)
 	if (ret)
 		goto err_bus_id;
 
-	/* Set network and ethtool operations */
+	/* Set device operations */
 	netdev->netdev_ops = xgbe_get_netdev_ops();
 	netdev->ethtool_ops = xgbe_get_ethtool_ops();
+#ifdef CONFIG_AMD_XGBE_DCB
+	netdev->dcbnl_ops = xgbe_get_dcbnl_ops();
+#endif
 
 	/* Set device features */
 	netdev->hw_features = NETIF_F_SG |
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index f011d88..07bf70a 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -126,6 +126,7 @@
 #include <linux/ptp_clock_kernel.h>
 #include <linux/clocksource.h>
 #include <linux/net_tstamp.h>
+#include <net/dcbnl.h>
 
 
 #define XGBE_DRV_NAME		"amd-xgbe"
@@ -144,6 +145,7 @@
 #define XGBE_RX_BUF_ALIGN	64
 
 #define XGBE_MAX_DMA_CHANNELS	16
+#define XGBE_MAX_QUEUES		16
 
 /* DMA cache settings - Outer sharable, write-back, write-allocate */
 #define XGBE_DMA_OS_AXDOMAIN	0x2
@@ -184,7 +186,7 @@
 #define XGBE_FIFO_SIZE_B(x)	(x)
 #define XGBE_FIFO_SIZE_KB(x)	(x * 1024)
 
-#define XGBE_TC_CNT		2
+#define XGBE_TC_MIN_QUANTUM	10
 
 /* Helper macro for descriptor handling
  *  Always use XGBE_GET_DESC_DATA to access the descriptor data
@@ -504,6 +506,10 @@ struct xgbe_hw_if {
 				unsigned int nsec);
 	u64 (*get_tstamp_time)(struct xgbe_prv_data *);
 	u64 (*get_tx_tstamp)(struct xgbe_prv_data *);
+
+	/* For Data Center Bridging config */
+	void (*config_dcb_tc)(struct xgbe_prv_data *);
+	void (*config_dcb_pfc)(struct xgbe_prv_data *);
 };
 
 struct xgbe_desc_if {
@@ -545,6 +551,7 @@ struct xgbe_hw_features {
 	unsigned int tso;		/* TCP Segmentation Offload */
 	unsigned int dma_debug;		/* DMA Debug Registers */
 	unsigned int rss;		/* Receive Side Scaling */
+	unsigned int tc_cnt;		/* Number of Traffic Classes */
 	unsigned int hash_table_size;	/* Hash Table Size */
 	unsigned int l3l4_filter_num;	/* Number of L3-L4 Filters */
 
@@ -663,6 +670,12 @@ struct xgbe_prv_data {
 	struct sk_buff *tx_tstamp_skb;
 	u64 tx_tstamp;
 
+	/* DCB support */
+	struct ieee_ets *ets;
+	struct ieee_pfc *pfc;
+	unsigned int q2tc_map[XGBE_MAX_QUEUES];
+	unsigned int prio2q_map[IEEE_8021QAZ_MAX_TCS];
+
 	/* Hardware features of the device */
 	struct xgbe_hw_features hw_feat;
 
@@ -688,6 +701,9 @@ void xgbe_init_function_ptrs_dev(struct xgbe_hw_if *);
 void xgbe_init_function_ptrs_desc(struct xgbe_desc_if *);
 struct net_device_ops *xgbe_get_netdev_ops(void);
 struct ethtool_ops *xgbe_get_ethtool_ops(void);
+#ifdef CONFIG_AMD_XGBE_DCB
+const struct dcbnl_rtnl_ops *xgbe_get_dcbnl_ops(void);
+#endif
 
 int xgbe_mdio_register(struct xgbe_prv_data *);
 void xgbe_mdio_unregister(struct xgbe_prv_data *);
