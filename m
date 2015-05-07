From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: [RFC,v3 04/12] fsl/fman: Add the FMan port FLIB
Date: Thu, 7 May 2015 16:05:35 +0300
Message-ID: <1431003943-14906-4-git-send-email-madalin.bucur@freescale.com>
References: <1431003943-14906-1-git-send-email-madalin.bucur@freescale.com>
 <1431003943-14906-2-git-send-email-madalin.bucur@freescale.com>
 <1431003943-14906-3-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Igal Liberman <Igal.Liberman@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0138.outbound.protection.outlook.com ([65.55.169.138]:47520
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751925AbbEGNF5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 May 2015 09:05:57 -0400
In-Reply-To: <1431003943-14906-3-git-send-email-madalin.bucur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igal Liberman <Igal.Liberman@freescale.com>

The FMan Port FLib provides basic API used by the drivers to
configure and control the FMan Port hardware.

Signed-off-by: Igal Liberman <Igal.Liberman@freescale.com>
---
 drivers/net/ethernet/freescale/fman/Kconfig        |   1 +
 drivers/net/ethernet/freescale/fman/Makefile       |   2 +
 drivers/net/ethernet/freescale/fman/port/Makefile  |   3 +
 .../net/ethernet/freescale/fman/port/fman_port.c   | 728 +++++++++++++++++++++
 4 files changed, 734 insertions(+)
 create mode 100644 drivers/net/ethernet/freescale/fman/port/Makefile
 create mode 100644 drivers/net/ethernet/freescale/fman/port/fman_port.c

diff --git a/drivers/net/ethernet/freescale/fman/Kconfig b/drivers/net/ethernet/freescale/fman/Kconfig
index 8aeae29..af42c3a 100644
--- a/drivers/net/ethernet/freescale/fman/Kconfig
+++ b/drivers/net/ethernet/freescale/fman/Kconfig
@@ -5,3 +5,4 @@ config FSL_FMAN
 	help
 		Freescale Data-Path Acceleration Architecture Frame Manager
 		(FMan) support
+
diff --git a/drivers/net/ethernet/freescale/fman/Makefile b/drivers/net/ethernet/freescale/fman/Makefile
index a718f7c..a9ae0aa 100644
--- a/drivers/net/ethernet/freescale/fman/Makefile
+++ b/drivers/net/ethernet/freescale/fman/Makefile
@@ -3,3 +3,5 @@ subdir-ccflags-y += -I$(srctree)/drivers/net/ethernet/freescale/fman/flib
 obj-y		+= fsl_fman.o
 
 fsl_fman-objs			:= fman.o
+
+obj-y	+= port/
diff --git a/drivers/net/ethernet/freescale/fman/port/Makefile b/drivers/net/ethernet/freescale/fman/port/Makefile
new file mode 100644
index 0000000..54b1fa4
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/port/Makefile
@@ -0,0 +1,3 @@
+obj-y	+= fsl_fman_port.o
+
+fsl_fman_port-objs		:= fman_port.o
diff --git a/drivers/net/ethernet/freescale/fman/port/fman_port.c b/drivers/net/ethernet/freescale/fman/port/fman_port.c
new file mode 100644
index 0000000..7d04084
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/port/fman_port.c
@@ -0,0 +1,728 @@
+/*
+ * Copyright 2008 - 2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *	 notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *	 notice, this list of conditions and the following disclaimer in the
+ *	 documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *	 names of its contributors may be used to endorse or promote products
+ *	 derived from this software without specific prior written permission.
+ *
+ * ALTERNATIVELY, this software may be distributed under the terms of the
+ * GNU General Public License ("GPL") as published by the Free Software
+ * Foundation, either version 2 of that License or (at your option) any
+ * later version.
+ *
+ * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AND ANY
+ * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
+ * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include "common/general.h"
+
+#include "fman_common.h"
+#include "fsl_fman_port.h"
+
+/* problem Eyal: the following should not be here*/
+#define NIA_FM_CTL_AC_NO_IPACC_PRE_BMI_ENQ_FRAME	0x00000028
+
+static uint32_t get_no_pcd_nia_bmi_ac_enc_frame(struct fman_port_cfg *cfg)
+{
+	if (cfg->errata_A006675)
+		return NIA_ENG_FM_CTL |
+		    NIA_FM_CTL_AC_NO_IPACC_PRE_BMI_ENQ_FRAME;
+	else
+		return NIA_ENG_BMI | NIA_BMI_AC_ENQ_FRAME;
+}
+
+static int init_bmi_rx(struct fman_port *port,
+		       struct fman_port_cfg *cfg,
+		       struct fman_port_params *params)
+{
+	struct fman_port_rx_bmi_regs __iomem *regs = &port->bmi_regs->rx;
+	uint32_t tmp;
+
+	/* Rx Configuration register */
+	tmp = 0;
+	if (cfg->discard_override)
+		tmp |= BMI_PORT_CFG_FDOVR;
+	iowrite32be(tmp, &regs->fmbm_rcfg);
+
+	/* DMA attributes */
+	tmp = (uint32_t)cfg->dma_swap_data << BMI_DMA_ATTR_SWP_SHIFT;
+	if (cfg->dma_ic_stash_on)
+		tmp |= BMI_DMA_ATTR_IC_STASH_ON;
+	if (cfg->dma_header_stash_on)
+		tmp |= BMI_DMA_ATTR_HDR_STASH_ON;
+	if (cfg->dma_sg_stash_on)
+		tmp |= BMI_DMA_ATTR_SG_STASH_ON;
+	if (cfg->dma_write_optimize)
+		tmp |= BMI_DMA_ATTR_WRITE_OPTIMIZE;
+	iowrite32be(tmp, &regs->fmbm_rda);
+
+	/* Rx FIFO parameters */
+	tmp = (cfg->rx_pri_elevation / FMAN_PORT_BMI_FIFO_UNITS - 1) <<
+	    BMI_RX_FIFO_PRI_ELEVATION_SHIFT;
+	tmp |= cfg->rx_fifo_thr / FMAN_PORT_BMI_FIFO_UNITS - 1;
+	iowrite32be(tmp, &regs->fmbm_rfp);
+
+	if (cfg->excessive_threshold_register)
+		/* always allow access to the extra resources */
+		iowrite32be(BMI_RX_FIFO_THRESHOLD_ETHE, &regs->fmbm_reth);
+
+	/* Frame end data */
+	tmp = (uint32_t)cfg->checksum_bytes_ignore <<
+	    BMI_RX_FRAME_END_CS_IGNORE_SHIFT;
+	tmp |= (uint32_t)cfg->rx_cut_end_bytes << BMI_RX_FRAME_END_CUT_SHIFT;
+	if (cfg->errata_A006320)
+		tmp &= 0xffe0ffff;
+	iowrite32be(tmp, &regs->fmbm_rfed);
+
+	/* Internal context parameters */
+	tmp = ((uint32_t)cfg->ic_ext_offset / FMAN_PORT_IC_OFFSET_UNITS) <<
+	    BMI_IC_TO_EXT_SHIFT;
+	tmp |= ((uint32_t)cfg->ic_int_offset / FMAN_PORT_IC_OFFSET_UNITS) <<
+	    BMI_IC_FROM_INT_SHIFT;
+	tmp |= cfg->ic_size / FMAN_PORT_IC_OFFSET_UNITS;
+	iowrite32be(tmp, &regs->fmbm_ricp);
+
+	/* Internal buffer offset */
+	tmp = ((uint32_t)cfg->int_buf_start_margin / FMAN_PORT_IC_OFFSET_UNITS)
+	    << BMI_INT_BUF_MARG_SHIFT;
+	iowrite32be(tmp, &regs->fmbm_rim);
+
+	/* External buffer margins */
+	tmp = (uint32_t)cfg->ext_buf_start_margin <<
+	    BMI_EXT_BUF_MARG_START_SHIFT;
+	tmp |= (uint32_t)cfg->ext_buf_end_margin;
+	if (cfg->fmbm_rebm_has_sgd && cfg->no_scatter_gather)
+		tmp |= BMI_SG_DISABLE;
+	iowrite32be(tmp, &regs->fmbm_rebm);
+
+	/* Frame attributes */
+	tmp = BMI_CMD_RX_MR_DEF;
+	tmp |= BMI_CMD_ATTR_ORDER;
+	tmp |= (uint32_t)cfg->color << BMI_CMD_ATTR_COLOR_SHIFT;
+	if (cfg->sync_req)
+		tmp |= BMI_CMD_ATTR_SYNC;
+
+	iowrite32be(tmp, &regs->fmbm_rfca);
+
+	/* NIA */
+	tmp = (uint32_t)cfg->rx_fd_bits << BMI_NEXT_ENG_FD_BITS_SHIFT;
+	tmp |= get_no_pcd_nia_bmi_ac_enc_frame(cfg);
+
+	iowrite32be(tmp, &regs->fmbm_rfne);
+
+	/* Enqueue NIA */
+	iowrite32be(NIA_ENG_QMI_ENQ | NIA_ORDER_RESTOR, &regs->fmbm_rfene);
+
+	/* Default/error queues */
+	iowrite32be((params->dflt_fqid & 0x00FFFFFF), &regs->fmbm_rfqid);
+	iowrite32be((params->err_fqid & 0x00FFFFFF), &regs->fmbm_refqid);
+
+	/* Discard/error masks */
+	iowrite32be(params->discard_mask, &regs->fmbm_rfsdm);
+	iowrite32be(params->err_mask, &regs->fmbm_rfsem);
+
+	/* Statistics counters */
+	tmp = 0;
+	if (cfg->stats_counters_enable)
+		tmp = BMI_COUNTERS_EN;
+	iowrite32be(tmp, &regs->fmbm_rstc);
+
+	/* Performance counters */
+	fman_port_set_perf_cnt_params(port, &cfg->perf_cnt_params);
+	tmp = 0;
+	if (cfg->perf_counters_enable)
+		tmp = BMI_COUNTERS_EN;
+	iowrite32be(tmp, &regs->fmbm_rpc);
+
+	return 0;
+}
+
+static int init_bmi_tx(struct fman_port *port,
+		       struct fman_port_cfg *cfg,
+		       struct fman_port_params *params)
+{
+	struct fman_port_tx_bmi_regs __iomem *regs = &port->bmi_regs->tx;
+	uint32_t tmp;
+
+	/* Tx Configuration register */
+	tmp = 0;
+	iowrite32be(tmp, &regs->fmbm_tcfg);
+
+	/* DMA attributes */
+	tmp = (uint32_t)cfg->dma_swap_data << BMI_DMA_ATTR_SWP_SHIFT;
+	if (cfg->dma_ic_stash_on)
+		tmp |= BMI_DMA_ATTR_IC_STASH_ON;
+	if (cfg->dma_header_stash_on)
+		tmp |= BMI_DMA_ATTR_HDR_STASH_ON;
+	if (cfg->dma_sg_stash_on)
+		tmp |= BMI_DMA_ATTR_SG_STASH_ON;
+	iowrite32be(tmp, &regs->fmbm_tda);
+
+	/* Tx FIFO parameters */
+	tmp = (cfg->tx_fifo_min_level / FMAN_PORT_BMI_FIFO_UNITS) <<
+	    BMI_TX_FIFO_MIN_FILL_SHIFT;
+	tmp |= ((uint32_t)cfg->tx_fifo_deq_pipeline_depth - 1) <<
+	    BMI_FIFO_PIPELINE_DEPTH_SHIFT;
+	tmp |= (uint32_t)(cfg->tx_fifo_low_comf_level /
+			   FMAN_PORT_BMI_FIFO_UNITS - 1);
+	iowrite32be(tmp, &regs->fmbm_tfp);
+
+	/* Frame end data */
+	tmp = (uint32_t)cfg->checksum_bytes_ignore <<
+	    BMI_FRAME_END_CS_IGNORE_SHIFT;
+	iowrite32be(tmp, &regs->fmbm_tfed);
+
+	/* Internal context parameters */
+	tmp = ((uint32_t)cfg->ic_ext_offset / FMAN_PORT_IC_OFFSET_UNITS) <<
+	    BMI_IC_TO_EXT_SHIFT;
+	tmp |= ((uint32_t)cfg->ic_int_offset / FMAN_PORT_IC_OFFSET_UNITS) <<
+	    BMI_IC_FROM_INT_SHIFT;
+	tmp |= cfg->ic_size / FMAN_PORT_IC_OFFSET_UNITS;
+	iowrite32be(tmp, &regs->fmbm_ticp);
+
+	/* Frame attributes */
+	tmp = BMI_CMD_TX_MR_DEF;
+	tmp |= BMI_CMD_ATTR_ORDER;
+	tmp |= (uint32_t)cfg->color << BMI_CMD_ATTR_COLOR_SHIFT;
+	iowrite32be(tmp, &regs->fmbm_tfca);
+
+	/* Dequeue NIA + enqueue NIA */
+	iowrite32be(NIA_ENG_QMI_DEQ, &regs->fmbm_tfdne);
+	iowrite32be(NIA_ENG_QMI_ENQ | NIA_ORDER_RESTOR, &regs->fmbm_tfene);
+	if (cfg->fmbm_tfne_has_features)
+		iowrite32be(!params->dflt_fqid ?
+			    BMI_EBD_EN | NIA_BMI_AC_FETCH_ALL_FRAME :
+			    NIA_BMI_AC_FETCH_ALL_FRAME, &regs->fmbm_tfne);
+	if (!params->dflt_fqid && params->dont_release_buf) {
+		iowrite32be(0x00FFFFFF, &regs->fmbm_tcfqid);
+		iowrite32be(NIA_ENG_BMI | NIA_BMI_AC_TX_RELEASE,
+			    &regs->fmbm_tfene);
+		if (cfg->fmbm_tfne_has_features)
+			iowrite32be(ioread32be(&regs->fmbm_tfne) & ~BMI_EBD_EN,
+				    &regs->fmbm_tfne);
+	}
+
+	/* Confirmation/error queues */
+	if (params->dflt_fqid || !params->dont_release_buf)
+		iowrite32be(params->dflt_fqid & 0x00FFFFFF, &regs->fmbm_tcfqid);
+	iowrite32be((params->err_fqid & 0x00FFFFFF), &regs->fmbm_tefqid);
+
+	/* Statistics counters */
+	tmp = 0;
+	if (cfg->stats_counters_enable)
+		tmp = BMI_COUNTERS_EN;
+	iowrite32be(tmp, &regs->fmbm_tstc);
+
+	/* Performance counters */
+	fman_port_set_perf_cnt_params(port, &cfg->perf_cnt_params);
+	tmp = 0;
+	if (cfg->perf_counters_enable)
+		tmp = BMI_COUNTERS_EN;
+	iowrite32be(tmp, &regs->fmbm_tpc);
+
+	return 0;
+}
+
+static int init_bmi_oh(struct fman_port *port,
+		       struct fman_port_cfg *cfg,
+		       struct fman_port_params *params)
+{
+	struct fman_port_oh_bmi_regs __iomem *regs = &port->bmi_regs->oh;
+	uint32_t tmp;
+
+	/* OP Configuration register */
+	tmp = 0;
+	if (cfg->discard_override)
+		tmp |= BMI_PORT_CFG_FDOVR;
+	iowrite32be(tmp, &regs->fmbm_ocfg);
+
+	/* DMA attributes */
+	tmp = (uint32_t)cfg->dma_swap_data << BMI_DMA_ATTR_SWP_SHIFT;
+	if (cfg->dma_ic_stash_on)
+		tmp |= BMI_DMA_ATTR_IC_STASH_ON;
+	if (cfg->dma_header_stash_on)
+		tmp |= BMI_DMA_ATTR_HDR_STASH_ON;
+	if (cfg->dma_sg_stash_on)
+		tmp |= BMI_DMA_ATTR_SG_STASH_ON;
+	if (cfg->dma_write_optimize)
+		tmp |= BMI_DMA_ATTR_WRITE_OPTIMIZE;
+	iowrite32be(tmp, &regs->fmbm_oda);
+
+	/* Tx FIFO parameters */
+	tmp = ((uint32_t)cfg->tx_fifo_deq_pipeline_depth - 1) <<
+	    BMI_FIFO_PIPELINE_DEPTH_SHIFT;
+	iowrite32be(tmp, &regs->fmbm_ofp);
+
+	/* Internal context parameters */
+	tmp = ((uint32_t)cfg->ic_ext_offset / FMAN_PORT_IC_OFFSET_UNITS) <<
+	    BMI_IC_TO_EXT_SHIFT;
+	tmp |= ((uint32_t)cfg->ic_int_offset / FMAN_PORT_IC_OFFSET_UNITS) <<
+	    BMI_IC_FROM_INT_SHIFT;
+	tmp |= cfg->ic_size / FMAN_PORT_IC_OFFSET_UNITS;
+	iowrite32be(tmp, &regs->fmbm_oicp);
+
+	/* Frame attributes */
+	tmp = BMI_CMD_OP_MR_DEF;
+	tmp |= (uint32_t)cfg->color << BMI_CMD_ATTR_COLOR_SHIFT;
+	if (cfg->sync_req)
+		tmp |= BMI_CMD_ATTR_SYNC;
+	if (port->type == E_FMAN_PORT_TYPE_OP)
+		tmp |= BMI_CMD_ATTR_ORDER;
+	iowrite32be(tmp, &regs->fmbm_ofca);
+
+	/* Internal buffer offset */
+	tmp = ((uint32_t)cfg->int_buf_start_margin / FMAN_PORT_IC_OFFSET_UNITS)
+	    << BMI_INT_BUF_MARG_SHIFT;
+	iowrite32be(tmp, &regs->fmbm_oim);
+
+	/* Dequeue NIA */
+	iowrite32be(NIA_ENG_QMI_DEQ, &regs->fmbm_ofdne);
+
+	/* NIA and Enqueue NIA */
+	iowrite32be(get_no_pcd_nia_bmi_ac_enc_frame(cfg),
+		    &regs->fmbm_ofne);
+	iowrite32be(NIA_ENG_QMI_ENQ | NIA_ORDER_RESTOR,
+		    &regs->fmbm_ofene);
+
+	/* Default/error queues */
+	iowrite32be((params->dflt_fqid & 0x00FFFFFF), &regs->fmbm_ofqid);
+	iowrite32be((params->err_fqid & 0x00FFFFFF), &regs->fmbm_oefqid);
+
+	/* Discard/error masks */
+	if (port->type == E_FMAN_PORT_TYPE_OP) {
+		iowrite32be(params->discard_mask, &regs->fmbm_ofsdm);
+		iowrite32be(params->err_mask, &regs->fmbm_ofsem);
+	}
+
+	/* Statistics counters */
+	tmp = 0;
+	if (cfg->stats_counters_enable)
+		tmp = BMI_COUNTERS_EN;
+	iowrite32be(tmp, &regs->fmbm_ostc);
+
+	/* Performance counters */
+	fman_port_set_perf_cnt_params(port, &cfg->perf_cnt_params);
+	tmp = 0;
+	if (cfg->perf_counters_enable)
+		tmp = BMI_COUNTERS_EN;
+	iowrite32be(tmp, &regs->fmbm_opc);
+
+	return 0;
+}
+
+static int init_qmi(struct fman_port *port,
+		    struct fman_port_cfg *cfg, struct fman_port_params *params)
+{
+	struct fman_port_qmi_regs __iomem *regs = port->qmi_regs;
+	uint32_t tmp;
+
+	tmp = 0;
+	if (cfg->queue_counters_enable)
+		tmp |= QMI_PORT_CFG_EN_COUNTERS;
+	iowrite32be(tmp, &regs->fmqm_pnc);
+
+	/* Rx port configuration */
+	if ((port->type == E_FMAN_PORT_TYPE_RX) ||
+	    (port->type == E_FMAN_PORT_TYPE_RX_10G)) {
+		/* Enqueue NIA */
+		iowrite32be(NIA_ENG_BMI | NIA_BMI_AC_RELEASE, &regs->fmqm_pnen);
+		return 0;
+	}
+
+	/* Continue with Tx and O/H port configuration */
+	if ((port->type == E_FMAN_PORT_TYPE_TX) ||
+	    (port->type == E_FMAN_PORT_TYPE_TX_10G)) {
+		/* Enqueue NIA */
+		iowrite32be(NIA_ENG_BMI | NIA_BMI_AC_TX_RELEASE,
+			    &regs->fmqm_pnen);
+		/* Dequeue NIA */
+		iowrite32be(NIA_ENG_BMI | NIA_BMI_AC_TX, &regs->fmqm_pndn);
+	} else {
+		/* Enqueue NIA */
+		iowrite32be(NIA_ENG_BMI | NIA_BMI_AC_RELEASE, &regs->fmqm_pnen);
+		/* Dequeue NIA */
+		iowrite32be(NIA_ENG_BMI | NIA_BMI_AC_FETCH, &regs->fmqm_pndn);
+	}
+
+	/* Dequeue Configuration register */
+	tmp = 0;
+	if (cfg->deq_high_pri)
+		tmp |= QMI_DEQ_CFG_PRI;
+
+	switch (cfg->deq_type) {
+	case E_FMAN_PORT_DEQ_BY_PRI:
+		tmp |= QMI_DEQ_CFG_TYPE1;
+		break;
+	case E_FMAN_PORT_DEQ_ACTIVE_FQ:
+		tmp |= QMI_DEQ_CFG_TYPE2;
+		break;
+	case E_FMAN_PORT_DEQ_ACTIVE_FQ_NO_ICS:
+		tmp |= QMI_DEQ_CFG_TYPE3;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	if (cfg->qmi_deq_options_support) {
+		switch (cfg->deq_prefetch_opt) {
+		case E_FMAN_PORT_DEQ_NO_PREFETCH:
+			break;
+		case E_FMAN_PORT_DEQ_PART_PREFETCH:
+			tmp |= QMI_DEQ_CFG_PREFETCH_PARTIAL;
+			break;
+		case E_FMAN_PORT_DEQ_FULL_PREFETCH:
+			tmp |= QMI_DEQ_CFG_PREFETCH_FULL;
+			break;
+		default:
+			return -EINVAL;
+		}
+	}
+	tmp |= (uint32_t)(params->deq_sp & QMI_DEQ_CFG_SP_MASK) <<
+		QMI_DEQ_CFG_SP_SHIFT;
+	tmp |= cfg->deq_byte_cnt;
+	iowrite32be(tmp, &regs->fmqm_pndc);
+
+	return 0;
+}
+
+void fman_port_defconfig(struct fman_port_cfg *cfg, enum fman_port_type type)
+{
+	cfg->dma_swap_data = E_FMAN_PORT_DMA_NO_SWAP;
+	cfg->dma_ic_stash_on = false;
+	cfg->dma_header_stash_on = false;
+	cfg->dma_sg_stash_on = false;
+	cfg->dma_write_optimize = true;
+	cfg->color = E_FMAN_PORT_COLOR_GREEN;
+	cfg->discard_override = false;
+	cfg->checksum_bytes_ignore = 0;
+	cfg->rx_cut_end_bytes = 4;
+	cfg->rx_pri_elevation = ((0x3FF + 1) * FMAN_PORT_BMI_FIFO_UNITS);
+	cfg->rx_fifo_thr = ((0x3FF + 1) * FMAN_PORT_BMI_FIFO_UNITS);
+	cfg->rx_fd_bits = 0;
+	cfg->ic_ext_offset = 0;
+	cfg->ic_int_offset = 0;
+	cfg->ic_size = 0;
+	cfg->int_buf_start_margin = 0;
+	cfg->ext_buf_start_margin = 0;
+	cfg->ext_buf_end_margin = 0;
+	cfg->tx_fifo_min_level = 0;
+	cfg->tx_fifo_low_comf_level = (5 * 1024);
+	cfg->stats_counters_enable = true;
+	cfg->perf_counters_enable = true;
+	cfg->deq_type = E_FMAN_PORT_DEQ_BY_PRI;
+
+	cfg->sync_req = true;
+	cfg->deq_prefetch_opt = E_FMAN_PORT_DEQ_FULL_PREFETCH;
+
+	if (type == E_FMAN_PORT_TYPE_TX_10G) {
+		cfg->tx_fifo_deq_pipeline_depth = 4;
+		cfg->deq_high_pri = true;
+		cfg->deq_byte_cnt = 0x1400;
+	} else {
+		if (type == E_FMAN_PORT_TYPE_OP)
+			cfg->tx_fifo_deq_pipeline_depth = 2;
+		else
+			cfg->tx_fifo_deq_pipeline_depth = 1;
+
+		cfg->deq_high_pri = false;
+		cfg->deq_byte_cnt = 0x400;
+	}
+	cfg->no_scatter_gather = DEFAULT_FMAN_SP_NO_SCATTER_GATHER;
+}
+
+int fman_port_init(struct fman_port *port,
+		   struct fman_port_cfg *cfg, struct fman_port_params *params)
+{
+	int err;
+
+	/* Init BMI registers */
+	switch (port->type) {
+	case E_FMAN_PORT_TYPE_RX:
+	case E_FMAN_PORT_TYPE_RX_10G:
+		err = init_bmi_rx(port, cfg, params);
+		break;
+	case E_FMAN_PORT_TYPE_TX:
+	case E_FMAN_PORT_TYPE_TX_10G:
+		err = init_bmi_tx(port, cfg, params);
+		break;
+	case E_FMAN_PORT_TYPE_OP:
+		err = init_bmi_oh(port, cfg, params);
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	if (err)
+		return err;
+
+	/* Init QMI registers */
+	err = init_qmi(port, cfg, params);
+	return err;
+
+	return 0;
+}
+
+int fman_port_enable(struct fman_port *port)
+{
+	uint32_t __iomem *bmi_cfg_reg;
+	uint32_t tmp;
+	bool rx_port;
+
+	switch (port->type) {
+	case E_FMAN_PORT_TYPE_RX:
+	case E_FMAN_PORT_TYPE_RX_10G:
+		bmi_cfg_reg = &port->bmi_regs->rx.fmbm_rcfg;
+		rx_port = true;
+		break;
+	case E_FMAN_PORT_TYPE_TX:
+	case E_FMAN_PORT_TYPE_TX_10G:
+		bmi_cfg_reg = &port->bmi_regs->tx.fmbm_tcfg;
+		rx_port = false;
+		break;
+	case E_FMAN_PORT_TYPE_OP:
+		bmi_cfg_reg = &port->bmi_regs->oh.fmbm_ocfg;
+		rx_port = false;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	/* Enable QMI */
+	if (!rx_port) {
+		tmp = ioread32be(&port->qmi_regs->fmqm_pnc) | QMI_PORT_CFG_EN;
+		iowrite32be(tmp, &port->qmi_regs->fmqm_pnc);
+	}
+
+	/* Enable BMI */
+	tmp = ioread32be(bmi_cfg_reg) | BMI_PORT_CFG_EN;
+	iowrite32be(tmp, bmi_cfg_reg);
+
+	return 0;
+}
+
+int fman_port_disable(const struct fman_port *port)
+{
+	uint32_t __iomem *bmi_cfg_reg, *bmi_status_reg;
+	uint32_t tmp;
+	bool rx_port, failure = false;
+	int count;
+
+	switch (port->type) {
+	case E_FMAN_PORT_TYPE_RX:
+	case E_FMAN_PORT_TYPE_RX_10G:
+		bmi_cfg_reg = &port->bmi_regs->rx.fmbm_rcfg;
+		bmi_status_reg = &port->bmi_regs->rx.fmbm_rst;
+		rx_port = true;
+		break;
+	case E_FMAN_PORT_TYPE_TX:
+	case E_FMAN_PORT_TYPE_TX_10G:
+		bmi_cfg_reg = &port->bmi_regs->tx.fmbm_tcfg;
+		bmi_status_reg = &port->bmi_regs->tx.fmbm_tst;
+		rx_port = false;
+		break;
+	case E_FMAN_PORT_TYPE_OP:
+		bmi_cfg_reg = &port->bmi_regs->oh.fmbm_ocfg;
+		bmi_status_reg = &port->bmi_regs->oh.fmbm_ost;
+		rx_port = false;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	/* Disable QMI */
+	if (!rx_port) {
+		tmp = ioread32be(&port->qmi_regs->fmqm_pnc) & ~QMI_PORT_CFG_EN;
+		iowrite32be(tmp, &port->qmi_regs->fmqm_pnc);
+
+		/* Wait for QMI to finish FD handling */
+		count = 100;
+		do {
+			usleep_range(10, 11);
+			tmp = ioread32be(&port->qmi_regs->fmqm_pns);
+		} while ((tmp & QMI_PORT_STATUS_DEQ_FD_BSY) && --count);
+
+		if (count == 0) {
+			/* Timeout */
+			failure = true;
+		}
+	}
+
+	/* Disable BMI */
+	tmp = ioread32be(bmi_cfg_reg) & ~BMI_PORT_CFG_EN;
+	iowrite32be(tmp, bmi_cfg_reg);
+
+	/* Wait for graceful stop end */
+	count = 500;
+	do {
+		usleep_range(10, 11);
+		tmp = ioread32be(bmi_status_reg);
+	} while ((tmp & BMI_PORT_STATUS_BSY) && --count);
+
+	if (count == 0) {
+		/* Timeout */
+		failure = true;
+	}
+
+	if (failure)
+		return -EBUSY;
+
+	return 0;
+}
+
+int fman_port_set_bpools(const struct fman_port *port,
+			 const struct fman_port_bpools *bp)
+{
+	uint32_t __iomem *bp_reg, *bp_depl_reg;
+	uint32_t tmp;
+	uint8_t i, max_bp_num;
+	bool grp_depl_used = false, rx_port;
+
+	switch (port->type) {
+	case E_FMAN_PORT_TYPE_RX:
+	case E_FMAN_PORT_TYPE_RX_10G:
+		max_bp_num = port->ext_pools_num;
+		rx_port = true;
+		bp_reg = port->bmi_regs->rx.fmbm_ebmpi;
+		bp_depl_reg = &port->bmi_regs->rx.fmbm_mpd;
+		break;
+	case E_FMAN_PORT_TYPE_OP:
+		if (port->fm_rev_maj != 4)
+			return -EINVAL;
+		max_bp_num = FMAN_PORT_OBS_EXT_POOLS_NUM;
+		rx_port = false;
+		bp_reg = port->bmi_regs->oh.fmbm_oebmpi;
+		bp_depl_reg = &port->bmi_regs->oh.fmbm_ompd;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	if (rx_port) {
+		/* Check buffers are provided in ascending order */
+		for (i = 0; (i < (bp->count - 1) &&
+			     (i < FMAN_PORT_MAX_EXT_POOLS_NUM - 1)); i++) {
+			if (bp->bpool[i].size > bp->bpool[i + 1].size)
+				return -EINVAL;
+		}
+	}
+
+	/* Set up external buffers pools */
+	for (i = 0; i < bp->count; i++) {
+		tmp = BMI_EXT_BUF_POOL_VALID;
+		tmp |= ((uint32_t)bp->bpool[i].bpid <<
+			BMI_EXT_BUF_POOL_ID_SHIFT) & BMI_EXT_BUF_POOL_ID_MASK;
+
+		if (rx_port) {
+			if (bp->counters_enable)
+				tmp |= BMI_EXT_BUF_POOL_EN_COUNTER;
+
+			if (bp->bpool[i].is_backup)
+				tmp |= BMI_EXT_BUF_POOL_BACKUP;
+
+			tmp |= (uint32_t)bp->bpool[i].size;
+		}
+
+		iowrite32be(tmp, &bp_reg[i]);
+	}
+
+	/* Clear unused pools */
+	for (i = bp->count; i < max_bp_num; i++)
+		iowrite32be(0, &bp_reg[i]);
+
+	/* Pools depletion */
+	tmp = 0;
+	for (i = 0; i < FMAN_PORT_MAX_EXT_POOLS_NUM; i++) {
+		if (bp->bpool[i].grp_bp_depleted) {
+			grp_depl_used = true;
+			tmp |= 0x80000000 >> i;
+		}
+
+		if (bp->bpool[i].single_bp_depleted)
+			tmp |= 0x80 >> i;
+	}
+
+	if (grp_depl_used)
+		tmp |= ((uint32_t)bp->grp_bp_depleted_num - 1) <<
+		    BMI_POOL_DEP_NUM_OF_POOLS_SHIFT;
+
+	iowrite32be(tmp, bp_depl_reg);
+	return 0;
+}
+
+int fman_port_set_perf_cnt_params(struct fman_port *port,
+				  struct fman_port_perf_cnt_params *params)
+{
+	uint32_t __iomem *pcp_reg;
+	uint32_t tmp;
+
+	/* Obtain register address and check parameters are in range */
+	switch (port->type) {
+	case E_FMAN_PORT_TYPE_RX:
+	case E_FMAN_PORT_TYPE_RX_10G:
+		pcp_reg = &port->bmi_regs->rx.fmbm_rpcp;
+		if ((params->queue_val == 0) ||
+		    (params->queue_val > MAX_PERFORMANCE_RX_QUEUE_COMP))
+			return -EINVAL;
+		break;
+	case E_FMAN_PORT_TYPE_TX:
+	case E_FMAN_PORT_TYPE_TX_10G:
+		pcp_reg = &port->bmi_regs->tx.fmbm_tpcp;
+		if ((params->queue_val == 0) ||
+		    (params->queue_val > MAX_PERFORMANCE_TX_QUEUE_COMP))
+			return -EINVAL;
+		break;
+	case E_FMAN_PORT_TYPE_OP:
+		pcp_reg = &port->bmi_regs->oh.fmbm_opcp;
+		if (params->queue_val != 0)
+			return -EINVAL;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	if ((params->task_val == 0) ||
+	    (params->task_val > MAX_PERFORMANCE_TASK_COMP))
+		return -EINVAL;
+	if ((params->dma_val == 0) ||
+	    (params->dma_val > MAX_PERFORMANCE_DMA_COMP))
+		return -EINVAL;
+	if ((params->fifo_val == 0) ||
+	    ((params->fifo_val / FMAN_PORT_BMI_FIFO_UNITS) >
+	     MAX_PERFORMANCE_FIFO_COMP))
+		return -EINVAL;
+	tmp = (uint32_t)(params->task_val - 1) <<
+	    BMI_PERFORMANCE_TASK_COMP_SHIFT;
+	tmp |= (uint32_t)(params->dma_val - 1) <<
+	    BMI_PERFORMANCE_DMA_COMP_SHIFT;
+	tmp |= (uint32_t)(params->fifo_val / FMAN_PORT_BMI_FIFO_UNITS - 1);
+
+	switch (port->type) {
+	case E_FMAN_PORT_TYPE_RX:
+	case E_FMAN_PORT_TYPE_RX_10G:
+	case E_FMAN_PORT_TYPE_TX:
+	case E_FMAN_PORT_TYPE_TX_10G:
+		tmp |= (uint32_t)(params->queue_val - 1) <<
+		    BMI_PERFORMANCE_QUEUE_COMP_SHIFT;
+		break;
+	default:
+		break;
+	}
+
+	iowrite32be(tmp, pcp_reg);
+	return 0;
+}
-- 
1.7.11.7
