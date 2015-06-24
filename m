From: igal.liberman@freescale.com
Subject: [v2,2/9] fsl/fman: Add the FMan port FLIB
Date: Wed, 24 Jun 2015 22:33:38 +0300
Message-ID: <1435174418-5044-1-git-send-email-igal.liberman@freescale.com>
Reply-To: igal.liberman@freescale.com
Mime-Version: 1.0
Content-Type: text/plain
Cc: linuxppc-dev@lists.ozlabs.org, scottwood@freescale.com,
	madalin.bucur@freescale.com, pebolle@tiscali.nl,
	Igal Liberman <Igal.Liberman@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0146.outbound.protection.outlook.com ([207.46.100.146]:55053
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753131AbbFXTdw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jun 2015 15:33:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igal Liberman <Igal.Liberman@freescale.com>

The FMan Port FLib provides basic API used by the drivers to
configure and control the FMan Port hardware.

Signed-off-by: Igal Liberman <Igal.Liberman@freescale.com>
---
 drivers/net/ethernet/freescale/fman/Kconfig        |    1 +
 drivers/net/ethernet/freescale/fman/Makefile       |    2 +
 .../ethernet/freescale/fman/flib/fsl_fman_port.h   |  443 ++++++++++++++
 .../net/ethernet/freescale/fman/flib/fsl_fman_sp.h |   53 ++
 drivers/net/ethernet/freescale/fman/port/Makefile  |    3 +
 .../net/ethernet/freescale/fman/port/fman_port.c   |  613 ++++++++++++++++++++
 6 files changed, 1115 insertions(+)
 create mode 100644 drivers/net/ethernet/freescale/fman/flib/fsl_fman_port.h
 create mode 100644 drivers/net/ethernet/freescale/fman/flib/fsl_fman_sp.h
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
index 2799c6f..50a4de2 100644
--- a/drivers/net/ethernet/freescale/fman/Makefile
+++ b/drivers/net/ethernet/freescale/fman/Makefile
@@ -3,3 +3,5 @@ subdir-ccflags-y += -I$(srctree)/drivers/net/ethernet/freescale/fman/flib
 obj-y		+= fsl_fman.o
 
 fsl_fman-objs	:= fman.o
+
+obj-y	+= port/
diff --git a/drivers/net/ethernet/freescale/fman/flib/fsl_fman_port.h b/drivers/net/ethernet/freescale/fman/flib/fsl_fman_port.h
new file mode 100644
index 0000000..ee1a853
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/flib/fsl_fman_port.h
@@ -0,0 +1,443 @@
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
+#ifndef __FSL_FMAN_PORT_H
+#define __FSL_FMAN_PORT_H
+
+#include <linux/io.h>
+
+#include "fsl_fman_sp.h"
+
+/* Registers bit fields */
+
+/* BMI defines */
+#define BMI_EBD_EN				0x80000000
+
+#define BMI_PORT_CFG_EN				0x80000000
+#define BMI_PORT_CFG_FDOVR			0x02000000
+
+#define BMI_PORT_STATUS_BSY			0x80000000
+
+#define BMI_DMA_ATTR_SWP_SHIFT			FMAN_SP_DMA_ATTR_SWP_SHIFT
+#define BMI_DMA_ATTR_IC_STASH_ON		0x10000000
+#define BMI_DMA_ATTR_HDR_STASH_ON		0x04000000
+#define BMI_DMA_ATTR_SG_STASH_ON		0x01000000
+#define BMI_DMA_ATTR_WRITE_OPTIMIZE		FMAN_SP_DMA_ATTR_WRITE_OPTIMIZE
+
+#define BMI_RX_FIFO_PRI_ELEVATION_SHIFT	16
+#define BMI_RX_FIFO_THRESHOLD_ETHE		0x80000000
+
+#define BMI_RX_FRAME_END_CS_IGNORE_SHIFT	24
+#define BMI_RX_FRAME_END_CUT_SHIFT		16
+
+#define BMI_IC_TO_EXT_SHIFT			FMAN_SP_IC_TO_EXT_SHIFT
+#define BMI_IC_FROM_INT_SHIFT			FMAN_SP_IC_FROM_INT_SHIFT
+
+#define BMI_INT_BUF_MARG_SHIFT			28
+#define BMI_EXT_BUF_MARG_START_SHIFT		FMAN_SP_EXT_BUF_MARG_START_SHIFT
+
+#define BMI_CMD_MR_LEAC				0x00200000
+#define BMI_CMD_MR_SLEAC			0x00100000
+#define BMI_CMD_MR_MA				0x00080000
+#define BMI_CMD_MR_DEAS				0x00040000
+#define BMI_CMD_RX_MR_DEF			(BMI_CMD_MR_LEAC | \
+						BMI_CMD_MR_SLEAC | \
+						BMI_CMD_MR_MA | \
+						BMI_CMD_MR_DEAS)
+#define BMI_CMD_TX_MR_DEF			0
+#define BMI_CMD_OP_MR_DEF			(BMI_CMD_MR_DEAS | \
+						BMI_CMD_MR_MA)
+
+#define BMI_CMD_ATTR_ORDER			0x80000000
+#define BMI_CMD_ATTR_SYNC			0x02000000
+#define BMI_CMD_ATTR_COLOR_SHIFT		26
+
+#define BMI_FIFO_PIPELINE_DEPTH_SHIFT		12
+#define BMI_NEXT_ENG_FD_BITS_SHIFT		24
+#define BMI_FRAME_END_CS_IGNORE_SHIFT		24
+
+#define BMI_COUNTERS_EN				0x80000000
+
+#define BMI_EXT_BUF_POOL_VALID			FMAN_SP_EXT_BUF_POOL_VALID
+#define BMI_EXT_BUF_POOL_EN_COUNTER		FMAN_SP_EXT_BUF_POOL_EN_COUNTER
+#define BMI_EXT_BUF_POOL_BACKUP		FMAN_SP_EXT_BUF_POOL_BACKUP
+#define BMI_EXT_BUF_POOL_ID_SHIFT		16
+#define BMI_EXT_BUF_POOL_ID_MASK		0x003F0000
+#define BMI_POOL_DEP_NUM_OF_POOLS_SHIFT	16
+
+#define BMI_TX_FIFO_MIN_FILL_SHIFT		16
+
+#define BMI_SG_DISABLE				FMAN_SP_SG_DISABLE
+
+/* QMI defines */
+#define QMI_PORT_CFG_EN				0x80000000
+#define QMI_PORT_CFG_EN_COUNTERS		0x10000000
+#define QMI_PORT_STATUS_DEQ_FD_BSY		0x20000000
+
+#define QMI_DEQ_CFG_PRI				0x80000000
+#define QMI_DEQ_CFG_TYPE1			0x10000000
+#define QMI_DEQ_CFG_TYPE2			0x20000000
+#define QMI_DEQ_CFG_TYPE3			0x30000000
+#define QMI_DEQ_CFG_PREFETCH_PARTIAL		0x01000000
+#define QMI_DEQ_CFG_PREFETCH_FULL		0x03000000
+#define QMI_DEQ_CFG_SP_MASK			0xf
+#define QMI_DEQ_CFG_SP_SHIFT			20
+
+/* General port defines */
+#define FMAN_PORT_MAX_EXT_POOLS_NUM	8
+#define FMAN_PORT_OBS_EXT_POOLS_NUM	2
+#define FMAN_PORT_CG_MAP_NUM		8
+#define FMAN_PORT_PRS_RESULT_WORDS_NUM	8
+#define FMAN_PORT_BMI_FIFO_UNITS	0x100
+#define FMAN_PORT_IC_OFFSET_UNITS	0x10
+
+/* NIA Description */
+#define NIA_ORDER_RESTOR			0x00800000
+#define NIA_ENG_FM_CTL				0x00000000
+#define NIA_ENG_BMI				0x00500000
+#define NIA_ENG_QMI_ENQ				0x00540000
+#define NIA_ENG_QMI_DEQ				0x00580000
+
+#define NIA_FM_CTL_AC_NO_IPACC_PRE_BMI_ENQ_FRAME	0x00000028
+#define NIA_BMI_AC_ENQ_FRAME				0x00000002
+#define NIA_BMI_AC_TX_RELEASE				0x000002C0
+#define NIA_BMI_AC_RELEASE				0x000000C0
+#define NIA_BMI_AC_TX					0x00000274
+#define NIA_BMI_AC_FETCH				0x00000208
+#define NIA_BMI_AC_FETCH_ALL_FRAME			0x0000020c
+
+/* FM Port Register Map */
+
+/* BMI Rx port register map */
+struct fman_port_rx_bmi_regs {
+	uint32_t fmbm_rcfg;		/* Rx Configuration */
+	uint32_t fmbm_rst;		/* Rx Status */
+	uint32_t fmbm_rda;		/* Rx DMA attributes */
+	uint32_t fmbm_rfp;		/* Rx FIFO Parameters */
+	uint32_t fmbm_rfed;		/* Rx Frame End Data */
+	uint32_t fmbm_ricp;		/* Rx Internal Context Parameters */
+	uint32_t fmbm_rim;		/* Rx Internal Buffer Margins */
+	uint32_t fmbm_rebm;		/* Rx External Buffer Margins */
+	uint32_t fmbm_rfne;		/* Rx Frame Next Engine */
+	uint32_t fmbm_rfca;		/* Rx Frame Command Attributes. */
+	uint32_t fmbm_rfpne;		/* Rx Frame Parser Next Engine */
+	uint32_t fmbm_rpso;		/* Rx Parse Start Offset */
+	uint32_t fmbm_rpp;		/* Rx Policer Profile  */
+	uint32_t fmbm_rccb;		/* Rx Coarse Classification Base */
+	uint32_t fmbm_reth;		/* Rx Excessive Threshold */
+	uint32_t reserved003c[1];	/* (0x03C 0x03F) */
+	uint32_t fmbm_rprai[FMAN_PORT_PRS_RESULT_WORDS_NUM];
+					/* Rx Parse Results Array Init */
+	uint32_t fmbm_rfqid;		/* Rx Frame Queue ID */
+	uint32_t fmbm_refqid;		/* Rx Error Frame Queue ID */
+	uint32_t fmbm_rfsdm;		/* Rx Frame Status Discard Mask */
+	uint32_t fmbm_rfsem;		/* Rx Frame Status Error Mask */
+	uint32_t fmbm_rfene;		/* Rx Frame Enqueue Next Engine */
+	uint32_t reserved0074[0x2];	/* (0x074-0x07C)  */
+	uint32_t fmbm_rcmne; /* Rx Frame Continuous Mode Next Engine */
+	uint32_t reserved0080[0x20];/* (0x080 0x0FF)  */
+	uint32_t fmbm_ebmpi[FMAN_PORT_MAX_EXT_POOLS_NUM];
+					/* Buffer Manager pool Information- */
+	uint32_t fmbm_acnt[FMAN_PORT_MAX_EXT_POOLS_NUM];
+					/* Allocate Counter- */
+	uint32_t reserved0130[8];
+					/* 0x130/0x140 - 0x15F reserved - */
+	uint32_t fmbm_rcgm[FMAN_PORT_CG_MAP_NUM];
+					/* Congestion Group Map */
+	uint32_t fmbm_mpd;		/* BM Pool Depletion  */
+	uint32_t reserved0184[0x1F];	/* (0x184 0x1FF) */
+	uint32_t fmbm_rstc;		/* Rx Statistics Counters */
+	uint32_t fmbm_rfrc;		/* Rx Frame Counter */
+	uint32_t fmbm_rfbc;		/* Rx Bad Frames Counter */
+	uint32_t fmbm_rlfc;		/* Rx Large Frames Counter */
+	uint32_t fmbm_rffc;		/* Rx Filter Frames Counter */
+	uint32_t fmbm_rfdc;		/* Rx Frame Discard Counter */
+	uint32_t fmbm_rfldec;		/* Rx Frames List DMA Error Counter */
+	uint32_t fmbm_rodc;		/* Rx Out of Buffers Discard nntr */
+	uint32_t fmbm_rbdc;		/* Rx Buffers Deallocate Counter */
+	uint32_t reserved0224[0x17];	/* (0x224 0x27F) */
+	uint32_t fmbm_rpc;		/* Rx Performance Counters */
+	uint32_t fmbm_rpcp;		/* Rx Performance Count Parameters */
+	uint32_t fmbm_rccn;		/* Rx Cycle Counter */
+	uint32_t fmbm_rtuc;		/* Rx Tasks Utilization Counter */
+	uint32_t fmbm_rrquc;		/* Rx Receive Queue Utilization cntr */
+	uint32_t fmbm_rduc;		/* Rx DMA Utilization Counter */
+	uint32_t fmbm_rfuc;		/* Rx FIFO Utilization Counter */
+	uint32_t fmbm_rpac;		/* Rx Pause Activation Counter */
+	uint32_t reserved02a0[0x18];	/* (0x2A0 0x2FF) */
+	uint32_t fmbm_rdbg;		/* Rx Debug- */
+};
+
+/* BMI Tx port register map */
+struct fman_port_tx_bmi_regs {
+	uint32_t fmbm_tcfg;		/* Tx Configuration */
+	uint32_t fmbm_tst;		/* Tx Status */
+	uint32_t fmbm_tda;		/* Tx DMA attributes */
+	uint32_t fmbm_tfp;		/* Tx FIFO Parameters */
+	uint32_t fmbm_tfed;		/* Tx Frame End Data */
+	uint32_t fmbm_ticp;		/* Tx Internal Context Parameters */
+	uint32_t fmbm_tfdne;		/* Tx Frame Dequeue Next Engine. */
+	uint32_t fmbm_tfca;		/* Tx Frame Command attribute. */
+	uint32_t fmbm_tcfqid;		/* Tx Confirmation Frame Queue ID. */
+	uint32_t fmbm_tefqid;		/* Tx Frame Error Queue ID */
+	uint32_t fmbm_tfene;		/* Tx Frame Enqueue Next Engine */
+	uint32_t fmbm_trlmts;		/* Tx Rate Limiter Scale */
+	uint32_t fmbm_trlmt;		/* Tx Rate Limiter */
+	uint32_t reserved0034[0x0e];	/* (0x034-0x6c) */
+	uint32_t fmbm_tccb;		/* Tx Coarse Classification base */
+	uint32_t fmbm_tfne;		/* Tx Frame Next Engine */
+	/* Tx Priority based Flow Control (PFC) Mapping */
+	uint32_t fmbm_tpfcm[0x02];
+	/* Tx Frame Continuous Mode Next Engine */
+	uint32_t fmbm_tcmne;
+	uint32_t reserved0080[0x60];	/* (0x080-0x200) */
+	uint32_t fmbm_tstc;		/* Tx Statistics Counters */
+	uint32_t fmbm_tfrc;		/* Tx Frame Counter */
+	uint32_t fmbm_tfdc;		/* Tx Frames Discard Counter */
+	uint32_t fmbm_tfledc;		/* Tx Frame len error discard cntr */
+	uint32_t fmbm_tfufdc;		/* Tx Frame unsprt frmt discard cntr */
+	uint32_t fmbm_tbdc;		/* Tx Buffers Deallocate Counter */
+	uint32_t reserved0218[0x1A];	/* (0x218-0x280) */
+	uint32_t fmbm_tpc;		/* Tx Performance Counters */
+	uint32_t fmbm_tpcp;		/* Tx Performance Count Parameters */
+	uint32_t fmbm_tccn;		/* Tx Cycle Counter */
+	uint32_t fmbm_ttuc;		/* Tx Tasks Utilization Counter */
+	uint32_t fmbm_ttcquc;		/* Tx Transmit conf Q util Counter */
+	uint32_t fmbm_tduc;		/* Tx DMA Utilization Counter */
+	uint32_t fmbm_tfuc;		/* Tx FIFO Utilization Counter */
+};
+
+/* BMI O/H port register map */
+struct fman_port_oh_bmi_regs {
+	uint32_t fmbm_ocfg;		/* O/H Configuration  */
+	uint32_t fmbm_ost;		/* O/H Status */
+	uint32_t fmbm_oda;		/* O/H DMA attributes  */
+	uint32_t fmbm_oicp;		/* O/H Internal Context Parameters */
+	uint32_t fmbm_ofdne;		/* O/H Frame Dequeue Next Engine  */
+	uint32_t fmbm_ofne;		/* O/H Frame Next Engine  */
+	uint32_t fmbm_ofca;		/* O/H Frame Command Attributes. */
+	uint32_t fmbm_ofpne;		/* O/H Frame Parser Next Engine	 */
+	uint32_t fmbm_opso;		/* O/H Parse Start Offset  */
+	uint32_t fmbm_opp;		/* O/H Policer Profile */
+	uint32_t fmbm_occb;		/* O/H Coarse Classification base */
+	uint32_t fmbm_oim;		/* O/H Internal margins */
+	uint32_t fmbm_ofp;		/* O/H Fifo Parameters */
+	uint32_t fmbm_ofed;		/* O/H Frame End Data */
+	uint32_t reserved0030[2];	/* (0x038 - 0x03F) */
+	uint32_t fmbm_oprai[FMAN_PORT_PRS_RESULT_WORDS_NUM];
+				/* O/H Parse Results Array Initialization  */
+	uint32_t fmbm_ofqid;		/* O/H Frame Queue ID  */
+	uint32_t fmbm_oefqid;		/* O/H Error Frame Queue ID  */
+	uint32_t fmbm_ofsdm;		/* O/H Frame Status Discard Mask  */
+	uint32_t fmbm_ofsem;		/* O/H Frame Status Error Mask	 */
+	uint32_t fmbm_ofene;		/* O/H Frame Enqueue Next Engine  */
+	uint32_t fmbm_orlmts;		/* O/H Rate Limiter Scale  */
+	uint32_t fmbm_orlmt;		/* O/H Rate Limiter  */
+	uint32_t fmbm_ocmne;		/* O/H Continuous Mode Next Engine  */
+	uint32_t reserved0080[0x20];	/* 0x080 - 0x0FF Reserved */
+	uint32_t fmbm_oebmpi[2];	/* Buf Mngr Observed Pool Info */
+	uint32_t reserved0108[0x16];	/* 0x108 - 0x15F Reserved */
+	uint32_t fmbm_ocgm;		/* Observed Congestion Group Map */
+	uint32_t reserved0164[0x7];	/* 0x164 - 0x17F Reserved */
+	uint32_t fmbm_ompd;		/* Observed BMan Pool Depletion */
+	uint32_t reserved0184[0x1F];	/* 0x184 - 0x1FF Reserved */
+	uint32_t fmbm_ostc;		/* O/H Statistics Counters  */
+	uint32_t fmbm_ofrc;		/* O/H Frame Counter  */
+	uint32_t fmbm_ofdc;		/* O/H Frames Discard Counter  */
+	uint32_t fmbm_ofledc;		/* O/H Frames Len Err Discard Cntr */
+	uint32_t fmbm_ofufdc;		/* O/H Frames Unsprtd Discard Cutr  */
+	uint32_t fmbm_offc;		/* O/H Filter Frames Counter  */
+	uint32_t fmbm_ofwdc;		/* Rx Frames WRED Discard Counter  */
+	uint32_t fmbm_ofldec;		/* O/H Frames List DMA Error Cntr */
+	uint32_t fmbm_obdc;		/* O/H Buffers Deallocate Counter */
+	uint32_t reserved0218[0x17];	/* (0x218 - 0x27F) */
+	uint32_t fmbm_opc;		/* O/H Performance Counters  */
+	uint32_t fmbm_opcp;		/* O/H Performance Count Parameters */
+	uint32_t fmbm_occn;		/* O/H Cycle Counter  */
+	uint32_t fmbm_otuc;		/* O/H Tasks Utilization Counter  */
+	uint32_t fmbm_oduc;		/* O/H DMA Utilization Counter */
+	uint32_t fmbm_ofuc;		/* O/H FIFO Utilization Counter */
+};
+
+/* BMI port register map */
+union fman_port_bmi_regs {
+	struct fman_port_rx_bmi_regs rx;
+	struct fman_port_tx_bmi_regs tx;
+	struct fman_port_oh_bmi_regs oh;
+};
+
+/* QMI port register map */
+struct fman_port_qmi_regs {
+	uint32_t fmqm_pnc;		/* PortID n Configuration Register */
+	uint32_t fmqm_pns;		/* PortID n Status Register */
+	uint32_t fmqm_pnts;		/* PortID n Task Status Register */
+	uint32_t reserved00c[4];	/* 0xn00C - 0xn01B */
+	uint32_t fmqm_pnen;		/* PortID n Enqueue NIA Register */
+	uint32_t fmqm_pnetfc;		/* PortID n Enq Total Frame Counter */
+	uint32_t reserved024[2];	/* 0xn024 - 0x02B */
+	uint32_t fmqm_pndn;		/* PortID n Dequeue NIA Register */
+	uint32_t fmqm_pndc;		/* PortID n Dequeue Config Register */
+	uint32_t fmqm_pndtfc;		/* PortID n Dequeue tot Frame cntr */
+	uint32_t fmqm_pndfdc;		/* PortID n Dequeue FQID Dflt Cntr */
+	uint32_t fmqm_pndcc;		/* PortID n Dequeue Confirm Counter */
+};
+
+enum fman_port_dma_swap {
+	E_FMAN_PORT_DMA_NO_SWAP,	/* No swap, transfer data as is */
+	E_FMAN_PORT_DMA_SWAP_LE,
+	/* The transferred data should be swapped in PPC Little Endian mode */
+	E_FMAN_PORT_DMA_SWAP_BE
+	/* The transferred data should be swapped in Big Endian mode */
+};
+
+/* Default port color */
+enum fman_port_color {
+	E_FMAN_PORT_COLOR_GREEN,	/* Default port color is green */
+	E_FMAN_PORT_COLOR_YELLOW,	/* Default port color is yellow */
+	E_FMAN_PORT_COLOR_RED,		/* Default port color is red */
+	E_FMAN_PORT_COLOR_OVERRIDE	/* Ignore color */
+};
+
+/* QMI dequeue from the SP channel - types */
+enum fman_port_deq_type {
+	E_FMAN_PORT_DEQ_BY_PRI,
+	/* Priority precedence and Intra-Class scheduling */
+	E_FMAN_PORT_DEQ_ACTIVE_FQ,
+	/* Active FQ precedence and Intra-Class scheduling */
+	E_FMAN_PORT_DEQ_ACTIVE_FQ_NO_ICS
+	/* Active FQ precedence and override Intra-Class scheduling */
+};
+
+/* QMI dequeue prefetch modes */
+enum fman_port_deq_prefetch {
+	E_FMAN_PORT_DEQ_NO_PREFETCH, /* No prefetch mode */
+	E_FMAN_PORT_DEQ_PART_PREFETCH, /* Partial prefetch mode */
+	E_FMAN_PORT_DEQ_FULL_PREFETCH /* Full prefetch mode */
+};
+
+/* FM Port configuration structure, used at init */
+struct fman_port_cfg {
+	/* BMI parameters */
+	enum fman_port_dma_swap dma_swap_data;
+	bool dma_ic_stash_on;
+	bool dma_header_stash_on;
+	bool dma_sg_stash_on;
+	bool dma_write_optimize;
+	uint16_t ic_ext_offset;
+	uint8_t ic_int_offset;
+	uint16_t ic_size;
+	enum fman_port_color color;
+	bool sync_req;
+	bool discard_override;
+	uint8_t checksum_bytes_ignore;
+	uint8_t rx_cut_end_bytes;
+	uint32_t rx_pri_elevation;
+	uint32_t rx_fifo_thr;
+	uint8_t rx_fd_bits;
+	uint8_t int_buf_start_margin;
+	uint16_t ext_buf_start_margin;
+	uint16_t ext_buf_end_margin;
+	uint32_t tx_fifo_min_level;
+	uint32_t tx_fifo_low_comf_level;
+	uint8_t tx_fifo_deq_pipeline_depth;
+	/* QMI parameters */
+	bool deq_high_pri;
+	enum fman_port_deq_type deq_type;
+	enum fman_port_deq_prefetch deq_prefetch_opt;
+	uint16_t deq_byte_cnt;
+	bool no_scatter_gather;
+	int errata_A006675;
+	int errata_A006320;
+	int excessive_threshold_register;
+	int fmbm_rebm_has_sgd;
+	int fmbm_tfne_has_features;
+	int qmi_deq_options_support;
+};
+
+enum fman_port_type {
+	E_FMAN_PORT_TYPE_OP = 0,	/* Offline parsing port */
+	E_FMAN_PORT_TYPE_RX,		/* 1G Rx port */
+	E_FMAN_PORT_TYPE_RX_10G,	/* 10G Rx port */
+	E_FMAN_PORT_TYPE_TX,		/* 1G Tx port */
+	E_FMAN_PORT_TYPE_TX_10G,	/* 10G Tx port */
+	E_FMAN_PORT_TYPE_DUMMY
+};
+
+struct fman_port_params {
+	uint32_t discard_mask;
+	uint32_t err_mask;
+	uint32_t dflt_fqid;
+	uint32_t err_fqid;
+	uint8_t deq_sp;
+	bool dont_release_buf;
+};
+
+/* Port context - used by most API functions */
+struct fman_port {
+	enum fman_port_type type;
+	uint8_t fm_rev_maj;
+	uint8_t fm_rev_min;
+	union fman_port_bmi_regs __iomem *bmi_regs;
+	struct fman_port_qmi_regs __iomem *qmi_regs;
+	uint8_t ext_pools_num;
+};
+
+/* External buffer pools configuration */
+struct fman_port_bpools {
+	uint8_t count;			/* Num of pools to set up */
+	bool counters_enable;		/* Enable allocate counters */
+	uint8_t grp_bp_depleted_num;
+	/* Number of depleted pools - if reached the BMI indicates
+	 * the MAC to send a pause frame
+	 */
+	struct {
+		uint8_t bpid;		/* BM pool ID */
+		uint16_t size;
+		/* Pool's size - must be in ascending order */
+		bool is_backup;
+		/* If this is a backup pool */
+		bool grp_bp_depleted;
+		/* Consider this buffer in multiple pools depletion criteria */
+		bool single_bp_depleted;
+		/* Consider this buffer in single pool depletion criteria */
+	} bpool[FMAN_PORT_MAX_EXT_POOLS_NUM];
+};
+
+/*   FM Port API */
+void fman_port_defconfig(struct fman_port_cfg *cfg, enum fman_port_type type);
+int fman_port_init(struct fman_port *port,
+		   struct fman_port_cfg *cfg, struct fman_port_params *params);
+int fman_port_enable(struct fman_port *port);
+int fman_port_disable(const struct fman_port *port);
+int fman_port_set_bpools(const struct fman_port *port,
+			 const struct fman_port_bpools *bp);
+
+#endif	/* __FSL_FMAN_PORT_H */
diff --git a/drivers/net/ethernet/freescale/fman/flib/fsl_fman_sp.h b/drivers/net/ethernet/freescale/fman/flib/fsl_fman_sp.h
new file mode 100644
index 0000000..651d98e
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/flib/fsl_fman_sp.h
@@ -0,0 +1,53 @@
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
+#ifndef __FSL_FMAN_SP_H
+#define __FSL_FMAN_SP_H
+
+#include "fsl_fman.h"
+
+/* Registers bit fields */
+#define FMAN_SP_EXT_BUF_POOL_EN_COUNTER	    0x40000000
+#define FMAN_SP_EXT_BUF_POOL_VALID		    0x80000000
+#define FMAN_SP_EXT_BUF_POOL_BACKUP		    0x20000000
+#define FMAN_SP_DMA_ATTR_WRITE_OPTIMIZE	    0x00100000
+#define FMAN_SP_SG_DISABLE			    0x80000000
+
+/* shifts */
+#define FMAN_SP_EXT_BUF_MARG_START_SHIFT	    16
+#define FMAN_SP_DMA_ATTR_SWP_SHIFT		    30
+#define FMAN_SP_IC_TO_EXT_SHIFT		    16
+#define FMAN_SP_IC_FROM_INT_SHIFT		    8
+
+/* defaults */
+#define DEFAULT_FMAN_SP_NO_SCATTER_GATHER		      false
+
+#endif	/* __FSL_FMAN_SP_H */
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
index 0000000..e9a14bf
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/port/fman_port.c
@@ -0,0 +1,613 @@
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
+#include "fsl_fman_port.h"
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
+	return 0;
+}
+
+static int init_qmi(struct fman_port *port,
+		    struct fman_port_cfg *cfg, struct fman_port_params *params)
+{
+	struct fman_port_qmi_regs __iomem *regs = port->qmi_regs;
+	uint32_t tmp;
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
-- 
1.7.9.5
