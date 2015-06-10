From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: [PATCH 08/12] fsl/fman: Add Frame Manager support
Date: Wed, 10 Jun 2015 18:21:43 +0300
Message-ID: <1433949712-5648-4-git-send-email-madalin.bucur@freescale.com>
References: <1433949712-5648-1-git-send-email-madalin.bucur@freescale.com>
 <1433949712-5648-2-git-send-email-madalin.bucur@freescale.com>
 <1433949712-5648-3-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <scottwood@freescale.com>,
	Igal Liberman <Igal.Liberman@freescale.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linuxppc-dev@lists.ozlabs.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433949712-5648-3-git-send-email-madalin.bucur@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Igal Liberman <Igal.Liberman@freescale.com>

Add Frame Manger Driver support.
This patch adds The FMan configuration, initialization and
runtime control routines.

Signed-off-by: Igal Liberman <Igal.Liberman@freescale.com>
---
 drivers/net/ethernet/freescale/fman/Kconfig        |   37 +
 drivers/net/ethernet/freescale/fman/Makefile       |    2 +-
 drivers/net/ethernet/freescale/fman/fm.c           | 1478 ++++++++++++++++++++
 drivers/net/ethernet/freescale/fman/fm.h           |  404 ++++++
 drivers/net/ethernet/freescale/fman/fm_common.h    |  367 +++++
 drivers/net/ethernet/freescale/fman/fm_drv.c       |  827 +++++++++++
 drivers/net/ethernet/freescale/fman/fm_drv.h       |  123 ++
 drivers/net/ethernet/freescale/fman/inc/enet_ext.h |  199 +++
 drivers/net/ethernet/freescale/fman/inc/fm_ext.h   |  453 ++++++
 .../net/ethernet/freescale/fman/inc/fsl_fman_drv.h |   94 ++
 drivers/net/ethernet/freescale/fman/inc/net_ext.h  |  534 +++++++
 drivers/net/ethernet/freescale/fman/inc/service.h  |   90 ++
 12 files changed, 4607 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/freescale/fman/fm.c
 create mode 100644 drivers/net/ethernet/freescale/fman/fm.h
 create mode 100644 drivers/net/ethernet/freescale/fman/fm_common.h
 create mode 100644 drivers/net/ethernet/freescale/fman/fm_drv.c
 create mode 100644 drivers/net/ethernet/freescale/fman/fm_drv.h
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/enet_ext.h
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/fm_ext.h
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/fsl_fman_drv.h
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/net_ext.h
 create mode 100644 drivers/net/ethernet/freescale/fman/inc/service.h

diff --git a/drivers/net/ethernet/freescale/fman/Kconfig b/drivers/net/ethernet/freescale/fman/Kconfig
index 825a0d5..d7de35f 100644
--- a/drivers/net/ethernet/freescale/fman/Kconfig
+++ b/drivers/net/ethernet/freescale/fman/Kconfig
@@ -7,3 +7,40 @@ config FSL_FMAN
 		Freescale Data-Path Acceleration Architecture Frame Manager
 		(FMan) support
 
+if FSL_FMAN
+
+config FSL_FM_MAX_FRAME_SIZE
+	int "Maximum L2 frame size"
+	depends on FSL_FMAN
+	range 64 9600
+	default "1522"
+	help
+		Configure this in relation to the maximum possible MTU of your
+		network configuration. In particular, one would need to
+		increase this value in order to use jumbo frames.
+		FSL_FM_MAX_FRAME_SIZE must accommodate the Ethernet FCS
+		(4 bytes) and one ETH+VLAN header (18 bytes), to a total of
+		22 bytes in excess of the desired L3 MTU.
+
+		Note that having too large a FSL_FM_MAX_FRAME_SIZE (much larger
+		than the actual MTU) may lead to buffer exhaustion, especially
+		in the case of badly fragmented datagrams on the Rx path.
+		Conversely, having a FSL_FM_MAX_FRAME_SIZE smaller than the
+		actual MTU will lead to frames being dropped.
+
+config FSL_FM_RX_EXTRA_HEADROOM
+	int "Add extra headroom at beginning of data buffers"
+	depends on FSL_FMAN
+	range 16 384
+	default "64"
+	help
+		Configure this to tell the Frame Manager to reserve some extra
+		space at the beginning of a data buffer on the receive path,
+		before Internal Context fields are copied. This is in addition
+		to the private data area already reserved for driver internal
+		use. The provided value must be a multiple of 16.
+
+		This option does not affect in any way the layout of
+		transmitted buffers.
+
+endif	# FSL_FMAN
diff --git a/drivers/net/ethernet/freescale/fman/Makefile b/drivers/net/ethernet/freescale/fman/Makefile
index 55c91bd..f61d3a6 100644
--- a/drivers/net/ethernet/freescale/fman/Makefile
+++ b/drivers/net/ethernet/freescale/fman/Makefile
@@ -4,7 +4,7 @@ subdir-ccflags-y += -I$(srctree)/drivers/net/ethernet/freescale/fman/flib \
 
 obj-y		+= fsl_fman.o
 
-fsl_fman-objs	:= fman.o fm_muram.o
+fsl_fman-objs	:= fman.o fm_muram.o fm.o fm_drv.o
 
 obj-y	+= port/
 obj-y	+= mac/
diff --git a/drivers/net/ethernet/freescale/fman/fm.c b/drivers/net/ethernet/freescale/fman/fm.c
new file mode 100644
index 0000000..5beb118
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/fm.c
@@ -0,0 +1,1478 @@
+/*
+ * Copyright 2008-2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
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
+/* FM driver routines implementation. */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include "service.h"
+
+#include "fm_common.h"
+#include "fm.h"
+#include "fm_muram_ext.h"
+#include <asm/mpc85xx.h>
+#include "fsl_fman.h"
+
+#include <linux/string.h>
+#include <linux/slab.h>
+
+/* static functions */
+
+static struct fm_intg_t *fill_intg_params(uint8_t major, uint8_t minor,
+					  struct fm_params_t *p_fm_param)
+{
+	struct fm_intg_t *intg;
+
+	intg = kzalloc(sizeof(*intg), GFP_KERNEL);
+	if (!intg)
+		return NULL;
+
+	/* P1023 - Major 4
+	 * P4080 - Major 2
+	 * P2041/P3041/P5020/P5040 - Major 3
+	 * Tx/Bx - Major 6
+	 */
+
+	switch (major) {
+	case FM_IP_BLOCK_P2_P3_P5:
+		intg->fm_muram_size		= 160 * 1024;
+		intg->fm_iram_size		= 64 * 1024;
+		intg->fm_num_of_ctrl		= 2;
+
+		intg->dma_thresh_max_commq	= 31;
+		intg->dma_thresh_max_buf	= 127;
+
+		intg->qmi_max_num_of_tnums	= 64;
+		intg->qmi_def_tnums_thresh	= 48;
+
+		intg->bmi_max_num_of_tasks	= 128;
+		intg->bmi_max_num_of_dmas	= 32;
+		intg->port_max_weight		= 16;
+
+		intg->fm_port_num_of_cg		= 256;
+
+		intg->num_of_rx_ports		= 6;
+		break;
+
+	case FM_IP_BLOCK_P4:
+
+		intg->fm_muram_size		= 160 * 1024;
+		intg->fm_iram_size		= 64 * 1024;
+		intg->fm_num_of_ctrl		= 2;
+
+		intg->dma_thresh_max_commq	= 31;
+		intg->dma_thresh_max_buf	= 127;
+
+		intg->qmi_max_num_of_tnums	= 64;
+		intg->qmi_def_tnums_thresh	= 48;
+
+		intg->bmi_max_num_of_tasks	= 128;
+		intg->bmi_max_num_of_dmas	= 32;
+		intg->port_max_weight		= 16;
+
+		intg->fm_port_num_of_cg		= 256;
+
+		intg->num_of_rx_ports		= 5;
+		break;
+
+	case FM_IP_BLOCK_P1:
+
+		intg->fm_muram_size		= 64 * 1024;
+		intg->fm_iram_size		= 32 * 1024;
+		intg->fm_num_of_ctrl		= 2;
+
+		intg->dma_thresh_max_commq	= 15;
+		intg->dma_thresh_max_buf	= 7;
+
+		intg->qmi_max_num_of_tnums	= 15;
+
+		intg->bmi_max_num_of_tasks	= 64;
+		intg->bmi_max_num_of_dmas	= 16;
+		intg->port_max_weight		= 4;
+
+		intg->fm_port_num_of_cg		= 32;
+
+		intg->num_of_rx_ports		= 2;
+		break;
+
+	case FM_IP_BLOCK_B_T:
+		intg->dma_thresh_max_commq	= 83;
+		intg->dma_thresh_max_buf	= 127;
+
+		intg->qmi_max_num_of_tnums	= 64;
+		intg->qmi_def_tnums_thresh	= 32;
+
+		intg->port_max_weight		= 16;
+		intg->fm_port_num_of_cg		= 256;
+
+		/* FManV3L */
+		if (minor == 1 || minor == 4) {
+			intg->fm_muram_size		= 192 * 1024;
+			intg->fm_num_of_ctrl		= 2;
+
+			intg->bmi_max_num_of_tasks	= 64;
+			intg->bmi_max_num_of_dmas	= 32;
+
+			intg->num_of_rx_ports		= 5;
+			
+			if (minor == 1)
+				intg->fm_iram_size	= 32 * 1024;
+			else
+				intg->fm_iram_size	= 64 * 1024;
+		}
+		/* FManV3H */
+		else if (minor == 0 || minor == 2 || minor == 3) {
+			intg->fm_muram_size		= 384 * 1024;
+			intg->fm_iram_size		= 64 * 1024;
+			intg->fm_num_of_ctrl		= 4;
+
+			intg->bmi_max_num_of_tasks	= 128;
+			intg->bmi_max_num_of_dmas	= 84;
+
+			intg->num_of_rx_ports		= 8;
+		} else {
+			pr_err("Unsupported FManv3 version\n");
+			kfree(intg);
+			return NULL;
+		}
+
+		break;
+	default:
+		pr_err("Unsupported FMan version\n");
+		kfree(intg);
+		return NULL;
+	}
+
+	intg->bmi_max_fifo_size = intg->fm_muram_size;
+
+	return intg;
+}
+
+/* Checks if p_fm driver parameters were initialized
+ * returns 0 if success else returns error code
+ */
+static int is_init_done(struct fman_cfg *p_fm_drv_parameters)
+{
+	if (!p_fm_drv_parameters)
+		return 0;
+	return -EINVAL;
+}
+
+static void free_init_resources(struct fm_t *p_fm)
+{
+	if (p_fm->cam_offset)
+		fm_muram_free_mem(p_fm->p_muram, p_fm->cam_offset,
+				  p_fm->cam_size);
+	if (p_fm->fifo_offset)
+		fm_muram_free_mem(p_fm->p_muram, p_fm->fifo_offset,
+				  p_fm->fifo_size);
+}
+
+static bool is_fman_ctrl_code_loaded(struct fm_t *p_fm)
+{
+	struct fm_iram_regs_t __iomem *p_iram;
+
+	p_iram = (struct fm_iram_regs_t __iomem *)UINT_TO_PTR(p_fm->base_addr +
+						       FM_MM_IMEM);
+
+	return (bool)!!(GET_UINT32(p_iram->iready) & IRAM_READY);
+}
+
+static int check_fm_parameters(struct fm_t *p_fm)
+{
+	if (is_fman_ctrl_code_loaded(p_fm) && !p_fm->reset_on_init) {
+		pr_err("Old FMan CTRL code is loaded; FM must be reset!\n");
+		return -EDOM;
+	}
+	if (p_fm->p_fm_state_struct->rev_info.major_rev < 6) {
+		if (!p_fm->p_fm_drv_param->dma_axi_dbg_num_of_beats ||
+		    (p_fm->p_fm_drv_param->dma_axi_dbg_num_of_beats >
+			DMA_MODE_MAX_AXI_DBG_NUM_OF_BEATS)) {
+			pr_err("axiDbgNumOfBeats has to be in the range 1 - %d\n",
+			       DMA_MODE_MAX_AXI_DBG_NUM_OF_BEATS);
+			return -EDOM;
+		}
+	}
+	if (p_fm->p_fm_drv_param->dma_cam_num_of_entries %
+	    DMA_CAM_UNITS) {
+		pr_err("dma_cam_num_of_entries has to be divisble by %d\n",
+		       DMA_CAM_UNITS);
+		return -EDOM;
+	}
+	if (p_fm->p_fm_drv_param->dma_comm_qtsh_asrt_emer >
+	    p_fm->intg->dma_thresh_max_commq) {
+		pr_err("dma_comm_qtsh_asrt_emer can not be larger than %d\n",
+		       p_fm->intg->dma_thresh_max_commq);
+		return -EDOM;
+	}
+	if (p_fm->p_fm_drv_param->dma_comm_qtsh_clr_emer >
+	    p_fm->intg->dma_thresh_max_commq) {
+		pr_err("dma_comm_qtsh_clr_emer can not be larger than %d\n",
+		       p_fm->intg->dma_thresh_max_commq);
+		return -EDOM;
+	}
+	if (p_fm->p_fm_drv_param->dma_comm_qtsh_clr_emer >=
+	    p_fm->p_fm_drv_param->dma_comm_qtsh_asrt_emer) {
+		pr_err("dma_comm_qtsh_clr_emer must be smaller than dma_comm_qtsh_asrt_emer\n");
+		return -EDOM;
+	}
+	if (p_fm->p_fm_state_struct->rev_info.major_rev < 6) {
+		if (p_fm->p_fm_drv_param->dma_read_buf_tsh_asrt_emer >
+		    p_fm->intg->dma_thresh_max_buf) {
+			pr_err("dma_read_buf_tsh_asrt_emer can not be larger than %d\n",
+			       p_fm->intg->dma_thresh_max_buf);
+			return -EDOM;
+		}
+		if (p_fm->p_fm_drv_param->dma_read_buf_tsh_clr_emer >
+		      p_fm->intg->dma_thresh_max_buf) {
+			pr_err("dma_read_buf_tsh_clr_emer can not be larger than %d\n",
+			       p_fm->intg->dma_thresh_max_buf);
+			return -EDOM;
+		}
+		if (p_fm->p_fm_drv_param->dma_read_buf_tsh_clr_emer >=
+		      p_fm->p_fm_drv_param->dma_read_buf_tsh_asrt_emer) {
+			pr_err("dma_read_buf_tsh_clr_emer must be < dma_read_buf_tsh_asrt_emer\n");
+			return -EDOM;
+		}
+		if (p_fm->p_fm_drv_param->dma_write_buf_tsh_asrt_emer >
+		      p_fm->intg->dma_thresh_max_buf) {
+			pr_err("dma_write_buf_tsh_asrt_emer can not be larger than %d\n",
+			       p_fm->intg->dma_thresh_max_buf);
+			return -EDOM;
+		}
+		if (p_fm->p_fm_drv_param->dma_write_buf_tsh_clr_emer >
+		      p_fm->intg->dma_thresh_max_buf) {
+			pr_err("dma_write_buf_tsh_clr_emer can not be larger than %d\n",
+			       p_fm->intg->dma_thresh_max_buf);
+			return -EDOM;
+		}
+		if (p_fm->p_fm_drv_param->dma_write_buf_tsh_clr_emer >=
+		      p_fm->p_fm_drv_param->dma_write_buf_tsh_asrt_emer) {
+			pr_err("dma_write_buf_tsh_clr_emer has to be less than dma_write_buf_tsh_asrt_emer\n");
+			return -EDOM;
+		}
+	} else {
+		if ((p_fm->p_fm_drv_param->dma_dbg_cnt_mode ==
+				E_FMAN_DMA_DBG_CNT_INT_READ_EM) ||
+			(p_fm->p_fm_drv_param->dma_dbg_cnt_mode ==
+				E_FMAN_DMA_DBG_CNT_INT_WRITE_EM) ||
+			(p_fm->p_fm_drv_param->dma_dbg_cnt_mode ==
+				E_FMAN_DMA_DBG_CNT_RAW_WAR_PROT)) {
+			pr_err("dma_dbg_cnt_mode value not supported by this integration.\n");
+			return -EDOM;
+		}
+		if ((p_fm->p_fm_drv_param->dma_emergency_bus_select ==
+		       FM_DMA_MURAM_READ_EMERGENCY) ||
+		      (p_fm->p_fm_drv_param->dma_emergency_bus_select ==
+		       FM_DMA_MURAM_WRITE_EMERGENCY)) {
+			pr_err("emergencyBusSelect value not supported by this integration.\n");
+			return -EDOM;
+		}
+		if (p_fm->p_fm_drv_param->dma_stop_on_bus_error) {
+			pr_err("dma_stop_on_bus_error not supported by this integration.\n");
+			return -EDOM;
+		}
+#ifdef FM_AID_MODE_NO_TNUM_SW005
+		if (p_fm->p_fm_state_struct->rev_info.major_rev >= 6 &&
+		    p_fm->p_fm_drv_param->dma_aid_mode !=
+		    E_FMAN_DMA_AID_OUT_PORT_ID) {
+			pr_err("dma_aid_mode not supported by this integration.\n");
+			return -EDOM;
+		}
+#endif /* FM_AID_MODE_NO_TNUM_SW005 */
+		if (p_fm->p_fm_drv_param->dma_axi_dbg_num_of_beats) {
+			pr_err("dma_axi_dbg_num_of_beats not supported by this integration.\n");
+			return -EDOM;
+		}
+	}
+
+	if (!p_fm->p_fm_state_struct->fm_clk_freq) {
+		pr_err("fm_clk_freq must be set.\n");
+		return -EDOM;
+	}
+	if (USEC_TO_CLK
+	    (p_fm->p_fm_drv_param->dma_watchdog,
+	     p_fm->p_fm_state_struct->fm_clk_freq) > DMA_MAX_WATCHDOG) {
+		pr_err("dma_watchdog depends on FM clock. dma_watchdog(in microseconds)*clk (in Mhz), may not exceed 0x08%x\n",
+		       DMA_MAX_WATCHDOG);
+		return -EDOM;
+	}
+	if (p_fm->p_fm_state_struct->total_fifo_size % BMI_FIFO_UNITS) {
+		pr_err("total_fifo_size number has to be divisible by %d\n",
+		       BMI_FIFO_UNITS);
+	}
+	if (!p_fm->p_fm_state_struct->total_fifo_size ||
+	    (p_fm->p_fm_state_struct->total_fifo_size >
+	       p_fm->intg->bmi_max_fifo_size)) {
+		pr_err("total_fifo_size (curr - %d) has to be in the range 256 - %d\n",
+		       p_fm->p_fm_state_struct->total_fifo_size,
+		       p_fm->intg->bmi_max_fifo_size);
+		return -EDOM;
+	}
+	if (!p_fm->p_fm_state_struct->total_num_of_tasks ||
+	    (p_fm->p_fm_state_struct->total_num_of_tasks >
+	       p_fm->intg->bmi_max_num_of_tasks)) {
+		pr_err("total_num_of_tasks number has to be in the range 1 - %d\n",
+		       p_fm->intg->bmi_max_num_of_tasks);
+		return -EDOM;
+	}
+
+#ifdef FM_HAS_TOTAL_DMAS
+	if ((p_fm->p_fm_state_struct->rev_info.major_rev < 6) &&
+	    (!p_fm->p_fm_state_struct->max_num_of_open_dmas ||
+	     (p_fm->p_fm_state_struct->max_num_of_open_dmas >
+		p_fm->intg->bmi_max_num_of_dmas))) {
+		pr_err("max_num_of_open_dmas number has to be in the range 1 - %d\n",
+		       p_fm->intg->bmi_max_num_of_dmas);
+		return -EDOM;
+	}
+#endif /* FM_HAS_TOTAL_DMAS */
+
+	if (p_fm->p_fm_drv_param->disp_limit_tsh > FPM_MAX_DISP_LIMIT) {
+		pr_err("disp_limit_tsh can't be greater than %d\n",
+		       FPM_MAX_DISP_LIMIT);
+		return -EDOM;
+	}
+	if (!p_fm->f_exception) {
+		pr_err("Exceptions callback not provided\n");
+		return -EDOM;
+	}
+	if (!p_fm->f_bus_error) {
+		pr_err("Exceptions callback not provided\n");
+		return -EDOM;
+	}
+#ifdef FM_NO_WATCHDOG
+	if ((p_fm->p_fm_state_struct->rev_info.major_rev == 2) &&
+	    (p_fm->p_fm_drv_param->dma_watchdog)) {
+		pr_err("watchdog!\n");
+		return -EINVAL;
+	}
+#endif /* FM_NO_WATCHDOG */
+
+#ifdef FM_ECC_HALT_NO_SYNC_ERRATA_10GMAC_A008
+	if ((p_fm->p_fm_state_struct->rev_info.major_rev < 6) &&
+	    (p_fm->p_fm_state_struct->rev_info.major_rev != 4) &&
+	    (p_fm->p_fm_drv_param->halt_on_unrecov_ecc_err)) {
+		pr_err("HaltOnEccError!\n");
+		return -EINVAL;
+	}
+#endif /* FM_ECC_HALT_NO_SYNC_ERRATA_10GMAC_A008 */
+
+#ifdef FM_NO_TNUM_AGING
+	if ((p_fm->p_fm_state_struct->rev_info.major_rev != 4) &&
+	    (p_fm->p_fm_state_struct->rev_info.major_rev < 6))
+		if (p_fm->p_fm_drv_param->tnum_aging_period) {
+			pr_err("Tnum aging!\n");
+			return -EINVAL;
+		}
+#endif /* FM_NO_TNUM_AGING */
+
+	/* check that user did not set revision-dependent exceptions */
+#ifdef FM_NO_DISPATCH_RAM_ECC
+	if ((p_fm->p_fm_state_struct->rev_info.major_rev != 4) &&
+	    (p_fm->p_fm_state_struct->rev_info.major_rev < 6))
+		if (p_fm->user_set_exceptions & FM_EX_BMI_DISPATCH_RAM_ECC) {
+			pr_err("exception FM_EX_BMI_DISPATCH_RAM_ECC!\n");
+			return -EINVAL;
+		}
+#endif /* FM_NO_DISPATCH_RAM_ECC */
+
+#ifdef FM_QMI_NO_ECC_EXCEPTIONS
+	if (p_fm->p_fm_state_struct->rev_info.major_rev == 4)
+		if (p_fm->user_set_exceptions &
+		    (FM_EX_QMI_SINGLE_ECC | FM_EX_QMI_DOUBLE_ECC)) {
+			pr_err("exception FM_EX_QMI_SINGLE_ECC/FM_EX_QMI_DOUBLE_ECC!\n");
+			return -EINVAL;
+		}
+#endif /* FM_QMI_NO_ECC_EXCEPTIONS */
+
+#ifdef FM_QMI_NO_SINGLE_ECC_EXCEPTION
+	if (p_fm->p_fm_state_struct->rev_info.major_rev >= 6)
+		if (p_fm->user_set_exceptions & FM_EX_QMI_SINGLE_ECC) {
+			pr_err("exception FM_EX_QMI_SINGLE_ECC!\n");
+			return -EINVAL;
+		}
+#endif /* FM_QMI_NO_SINGLE_ECC_EXCEPTION */
+
+	return 0;
+}
+
+static void bmi_err_event(struct fm_t *p_fm)
+{
+	uint32_t event;
+	struct fman_bmi_regs __iomem *bmi_rg = p_fm->p_fm_bmi_regs;
+
+	event = fman_get_bmi_err_event(bmi_rg);
+
+	if (event & BMI_ERR_INTR_EN_STORAGE_PROFILE_ECC)
+		p_fm->f_exception(p_fm->h_app, FM_EX_BMI_STORAGE_PROFILE_ECC);
+	if (event & BMI_ERR_INTR_EN_LIST_RAM_ECC)
+		p_fm->f_exception(p_fm->h_app, FM_EX_BMI_LIST_RAM_ECC);
+	if (event & BMI_ERR_INTR_EN_STATISTICS_RAM_ECC)
+		p_fm->f_exception(p_fm->h_app, FM_EX_BMI_STATISTICS_RAM_ECC);
+	if (event & BMI_ERR_INTR_EN_DISPATCH_RAM_ECC)
+		p_fm->f_exception(p_fm->h_app, FM_EX_BMI_DISPATCH_RAM_ECC);
+}
+
+static void qmi_err_event(struct fm_t *p_fm)
+{
+	uint32_t event;
+	struct fman_qmi_regs __iomem *qmi_rg = p_fm->p_fm_qmi_regs;
+
+	event = fman_get_qmi_err_event(qmi_rg);
+
+	if (event & QMI_ERR_INTR_EN_DOUBLE_ECC)
+		p_fm->f_exception(p_fm->h_app, FM_EX_QMI_DOUBLE_ECC);
+	if (event & QMI_ERR_INTR_EN_DEQ_FROM_DEF)
+		p_fm->f_exception(p_fm->h_app,
+				  FM_EX_QMI_DEQ_FROM_UNKNOWN_PORTID);
+}
+
+static void dma_err_event(struct fm_t *p_fm)
+{
+	uint32_t status;
+	struct fman_dma_regs __iomem *dma_rg = p_fm->p_fm_dma_regs;
+
+	status = fman_get_dma_err_event(dma_rg);
+
+	if (status & DMA_STATUS_FM_SPDAT_ECC)
+		p_fm->f_exception(p_fm->h_app, FM_EX_DMA_SINGLE_PORT_ECC);
+	if (status & DMA_STATUS_READ_ECC)
+		p_fm->f_exception(p_fm->h_app, FM_EX_DMA_READ_ECC);
+	if (status & DMA_STATUS_SYSTEM_WRITE_ECC)
+		p_fm->f_exception(p_fm->h_app, FM_EX_DMA_SYSTEM_WRITE_ECC);
+	if (status & DMA_STATUS_FM_WRITE_ECC)
+		p_fm->f_exception(p_fm->h_app, FM_EX_DMA_FM_WRITE_ECC);
+}
+
+static void fpm_err_event(struct fm_t *p_fm)
+{
+	uint32_t event;
+	struct fman_fpm_regs __iomem *fpm_rg = p_fm->p_fm_fpm_regs;
+
+	event = fman_get_fpm_err_event(fpm_rg);
+
+	if ((event & FPM_EV_MASK_DOUBLE_ECC) &&
+	    (event & FPM_EV_MASK_DOUBLE_ECC_EN))
+		p_fm->f_exception(p_fm->h_app, FM_EX_FPM_DOUBLE_ECC);
+	if ((event & FPM_EV_MASK_STALL) && (event & FPM_EV_MASK_STALL_EN))
+		p_fm->f_exception(p_fm->h_app, FM_EX_FPM_STALL_ON_TASKS);
+	if ((event & FPM_EV_MASK_SINGLE_ECC) &&
+	    (event & FPM_EV_MASK_SINGLE_ECC_EN))
+		p_fm->f_exception(p_fm->h_app, FM_EX_FPM_SINGLE_ECC);
+}
+
+static void muram_err_intr(struct fm_t *p_fm)
+{
+	uint32_t event;
+	struct fman_fpm_regs __iomem *fpm_rg = p_fm->p_fm_fpm_regs;
+
+	event = fman_get_muram_err_event(fpm_rg);
+
+	if (event & FPM_RAM_MURAM_ECC)
+		p_fm->f_exception(p_fm->h_app, FM_EX_MURAM_ECC);
+}
+
+static void iram_err_intr(struct fm_t *p_fm)
+{
+	uint32_t event;
+	struct fman_fpm_regs __iomem *fpm_rg = p_fm->p_fm_fpm_regs;
+
+	event = fman_get_iram_err_event(fpm_rg);
+
+	if (event & FPM_RAM_IRAM_ECC)
+		p_fm->f_exception(p_fm->h_app, FM_EX_IRAM_ECC);
+}
+
+static void qmi_event(struct fm_t *p_fm)
+{
+	uint32_t event;
+	struct fman_qmi_regs __iomem *qmi_rg = p_fm->p_fm_qmi_regs;
+
+	event = fman_get_qmi_event(qmi_rg);
+
+	if (event & QMI_INTR_EN_SINGLE_ECC)
+		p_fm->f_exception(p_fm->h_app, FM_EX_QMI_SINGLE_ECC);
+}
+
+static void unimplemented_isr(void __maybe_unused *h_src_arg)
+{
+	pr_err("Unimplemented ISR!\n");
+}
+
+static void enable_time_stamp(struct fm_t *p_fm)
+{
+	struct fman_fpm_regs __iomem *fpm_rg = p_fm->p_fm_fpm_regs;
+
+	ASSERT(p_fm->p_fm_state_struct);
+	ASSERT(p_fm->p_fm_state_struct->count1_micro_bit);
+
+	fman_enable_time_stamp(fpm_rg,
+			       p_fm->p_fm_state_struct->count1_micro_bit,
+			       p_fm->p_fm_state_struct->fm_clk_freq);
+
+	p_fm->p_fm_state_struct->enabled_time_stamp = true;
+}
+
+static int clear_iram(struct fm_t *p_fm)
+{
+	struct fm_iram_regs_t __iomem *p_iram;
+	int i;
+
+	p_iram = (struct fm_iram_regs_t __iomem *)UINT_TO_PTR(p_fm->base_addr +
+						       FM_MM_IMEM);
+
+	/* Enable the auto-increment */
+	WRITE_UINT32(p_iram->iadd, IRAM_IADD_AIE);
+	while (GET_UINT32(p_iram->iadd) != IRAM_IADD_AIE)
+		;
+
+	for (i = 0; i < (p_fm->intg->fm_iram_size / 4); i++)
+		WRITE_UINT32(p_iram->idata, 0xffffffff);
+
+	WRITE_UINT32(p_iram->iadd, p_fm->intg->fm_iram_size - 4);
+	/* Memory barrier */
+	mb();
+	while (GET_UINT32(p_iram->idata) != 0xffffffff)
+		;
+
+	return 0;
+}
+
+static int load_fman_ctrl_code(struct fm_t *p_fm)
+{
+	struct fm_iram_regs_t __iomem *p_iram;
+	int i;
+	uint32_t tmp;
+	uint8_t comp_to_16;
+
+	p_iram = (struct fm_iram_regs_t __iomem *)UINT_TO_PTR(p_fm->base_addr +
+						       FM_MM_IMEM);
+
+	/* Enable the auto-increment */
+	WRITE_UINT32(p_iram->iadd, IRAM_IADD_AIE);
+	while (GET_UINT32(p_iram->iadd) != IRAM_IADD_AIE)
+		;
+
+	for (i = 0; i < (p_fm->firmware.size / 4); i++)
+		WRITE_UINT32(p_iram->idata, p_fm->firmware.p_code[i]);
+
+	comp_to_16 = (uint8_t)(p_fm->firmware.size % 16);
+	if (comp_to_16)
+		for (i = 0; i < ((16 - comp_to_16) / 4); i++)
+			WRITE_UINT32(p_iram->idata, 0xffffffff);
+
+	WRITE_UINT32(p_iram->iadd, p_fm->firmware.size - 4);
+	while (GET_UINT32(p_iram->iadd) != (p_fm->firmware.size - 4))
+		;
+
+	/* verify that writing has completed */
+	while (GET_UINT32(p_iram->idata) !=
+	       p_fm->firmware.p_code[(p_fm->firmware.size / 4) - 1])
+		;
+
+	if (p_fm->fw_verify) {
+		WRITE_UINT32(p_iram->iadd, IRAM_IADD_AIE);
+		while (GET_UINT32(p_iram->iadd) != IRAM_IADD_AIE)
+			;
+		for (i = 0; i < (p_fm->firmware.size / 4); i++) {
+			tmp = GET_UINT32(p_iram->idata);
+			if (tmp != p_fm->firmware.p_code[i]) {
+				pr_err("UCode write error : write 0x%x, read 0x%x\n",
+				       p_fm->firmware.p_code[i], tmp);
+				return -EIO;
+			}
+		}
+		WRITE_UINT32(p_iram->iadd, 0x0);
+	}
+
+	/* Enable patch from IRAM */
+	WRITE_UINT32(p_iram->iready, IRAM_READY);
+	usleep_range(1000, 1001);
+
+	pr_debug("FMan-Controller code (ver %d.%d.%d) loaded to IRAM.\n",
+		 ((uint16_t *)p_fm->firmware.p_code)[2],
+		 ((uint8_t *)p_fm->firmware.p_code)[6],
+		 ((uint8_t *)p_fm->firmware.p_code)[7]);
+
+	return 0;
+}
+
+#ifdef FM_UCODE_NOT_RESET_ERRATA_BUGZILLA6173
+static int fw_not_reset_erratum_bugzilla6173wa(struct fm_t *p_fm)
+{
+	struct fm_iram_regs_t __iomem *p_iram =
+	    (struct fm_iram_regs_t __iomem *)UINT_TO_PTR(p_fm->base_addr +
+							 FM_MM_IMEM);
+	uint32_t tmp_reg;
+	uint32_t saved_spliodn[63];
+
+	/* write to IRAM first location the debug instruction */
+	WRITE_UINT32(p_iram->iadd, 0);
+	while (GET_UINT32(p_iram->iadd) != 0)
+		;
+
+	WRITE_UINT32(p_iram->idata, FM_FW_DEBUG_INSTRUCTION);
+
+	WRITE_UINT32(p_iram->iadd, 0);
+	while (GET_UINT32(p_iram->iadd) != 0)
+		;
+	while (GET_UINT32(p_iram->idata) != FM_FW_DEBUG_INSTRUCTION)
+		;
+
+	/* Enable patch from IRAM */
+	WRITE_UINT32(p_iram->iready, IRAM_READY);
+	/* Memory barrier */
+	mb();
+	usleep_range(100, 101);
+
+	memcpy_fromio((void *)saved_spliodn,
+		      (void __iomem *)p_fm->p_fm_bmi_regs->fmbm_spliodn,
+		      63 * sizeof(uint32_t));
+
+	/* reset FMAN */
+	WRITE_UINT32(p_fm->p_fm_fpm_regs->fm_rstc, FPM_RSTC_FM_RESET);
+	/* Memory barrier */
+	mb();
+	usleep_range(100, 101);
+
+	/* verify breakpoint debug status register */
+	tmp_reg =
+	    GET_UINT32(*(uint32_t __iomem *)
+		       UINT_TO_PTR(p_fm->base_addr +
+				   FM_DEBUG_STATUS_REGISTER_OFFSET));
+	if (!tmp_reg) {
+		pr_err("Invalid debug status register value is '0'\n");
+		return -EINVAL;
+	}
+
+	/* Load FMan-Controller code to IRAM */
+
+	if (clear_iram(p_fm) != 0)
+		return -EINVAL;
+	if (p_fm->firmware.p_code && (load_fman_ctrl_code(p_fm) != 0))
+		return -EINVAL;
+	usleep_range(100, 101);
+
+	/* reset FMAN again to start the microcode */
+	WRITE_UINT32(p_fm->p_fm_fpm_regs->fm_rstc, FPM_RSTC_FM_RESET);
+	/* Memory barrier */
+	mb();
+	usleep_range(100, 101);
+	memcpy_toio((void __iomem *)p_fm->p_fm_bmi_regs->fmbm_spliodn,
+		    (void *)saved_spliodn, 63 * sizeof(uint32_t));
+
+	if (fman_is_qmi_halt_not_busy_state(p_fm->p_fm_qmi_regs)) {
+		fman_resume(p_fm->p_fm_fpm_regs);
+		/* Memory barrier */
+		mb();
+		usleep_range(100, 101);
+	}
+
+	return 0;
+}
+#endif /* FM_UCODE_NOT_RESET_ERRATA_BUGZILLA6173 */
+
+/*       Inter-Module functions         */
+
+void fm_register_intr(struct fm_t *p_fm, enum fm_event_modules module,
+		      uint8_t mod_id, enum fm_intr_type intr_type,
+		      void (*f_isr)(void *h_src_arg), void *h_src_arg)
+{
+	int event = 0;
+
+	GET_FM_MODULE_EVENT(p_fm, module, mod_id, intr_type, event);
+	ASSERT(event < FM_EV_DUMMY_LAST);
+
+	/* register in local FM structure */
+	p_fm->intr_mng[event].f_isr = f_isr;
+	p_fm->intr_mng[event].h_src_handle = h_src_arg;
+}
+
+void fm_unregister_intr(struct fm_t *p_fm, enum fm_event_modules module,
+			uint8_t mod_id, enum fm_intr_type intr_type)
+{
+	int event = 0;
+
+	GET_FM_MODULE_EVENT(p_fm, module, mod_id, intr_type, event);
+	ASSERT(event < FM_EV_DUMMY_LAST);
+
+	p_fm->intr_mng[event].f_isr = unimplemented_isr;
+	p_fm->intr_mng[event].h_src_handle = NULL;
+}
+
+uint8_t fm_get_id(struct fm_t *p_fm)
+{
+	return p_fm->p_fm_state_struct->fm_id;
+}
+
+uint16_t fm_get_clock_freq(struct fm_t *p_fm)
+{
+	/* for multicore environment: this depends on the
+	 * fact that fm_clk_freq was properly initialized at "init".
+	 */
+	return p_fm->p_fm_state_struct->fm_clk_freq;
+}
+
+uint32_t fm_get_bmi_max_fifo_size(struct fm_t *p_fm)
+{
+	return p_fm->intg->bmi_max_fifo_size;
+}
+
+static int init_fm_dma(struct fm_t *p_fm)
+{
+	int err;
+
+	err = (int)fman_dma_init(p_fm->p_fm_dma_regs,
+				     p_fm->p_fm_drv_param);
+	if (err != 0)
+		return err;
+
+	/* Allocate MURAM for CAM */
+	p_fm->cam_size = (uint32_t)(p_fm->p_fm_drv_param->
+					dma_cam_num_of_entries *
+					DMA_CAM_SIZEOF_ENTRY);
+	p_fm->cam_offset = fm_muram_alloc(p_fm->p_muram, p_fm->cam_size);
+	if (IS_ERR_VALUE(p_fm->cam_offset)) {
+		pr_err("MURAM alloc for DMA CAM failed\n");
+		return -ENOMEM;
+	}
+
+	if (p_fm->p_fm_state_struct->rev_info.major_rev == 2) {
+		uintptr_t cam_base_addr;
+
+		fm_muram_free_mem(p_fm->p_muram, p_fm->cam_offset,
+				  p_fm->cam_size);
+
+		p_fm->cam_size =
+			p_fm->p_fm_drv_param->dma_cam_num_of_entries * 72 + 128;
+		p_fm->cam_offset = fm_muram_alloc(p_fm->p_muram, (uint32_t)
+						     p_fm->cam_size);
+		if (IS_ERR_VALUE(p_fm->cam_offset)) {
+			pr_err("MURAM alloc for DMA CAM failed\n");
+			return -ENOMEM;
+		}
+
+		cam_base_addr = fm_muram_offset_to_vbase(p_fm->p_muram,
+							 p_fm->cam_offset);
+		switch (p_fm->p_fm_drv_param->dma_cam_num_of_entries) {
+		case (8):
+			WRITE_UINT32(*(uint32_t __iomem *)cam_base_addr,
+				     0xff000000);
+			break;
+		case (16):
+			WRITE_UINT32(*(uint32_t __iomem *)cam_base_addr,
+				     0xffff0000);
+			break;
+		case (24):
+			WRITE_UINT32(*(uint32_t __iomem *)cam_base_addr,
+				     0xffffff00);
+			break;
+		case (32):
+			WRITE_UINT32(*(uint32_t __iomem *)cam_base_addr,
+				     0xffffffff);
+			break;
+		default:
+			pr_err("wrong dma_cam_num_of_entries\n");
+			return -EDOM;
+		}
+	}
+
+	p_fm->p_fm_drv_param->cam_base_addr = p_fm->cam_offset;
+
+	return 0;
+}
+
+static int init_fm_fpm(struct fm_t *p_fm)
+{
+	return (int)fman_fpm_init(p_fm->p_fm_fpm_regs,
+				  p_fm->p_fm_drv_param);
+}
+
+static int init_fm_bmi(struct fm_t *p_fm)
+{
+	return (int)fman_bmi_init(p_fm->p_fm_bmi_regs,
+				  p_fm->p_fm_drv_param);
+}
+
+static int init_fm_qmi(struct fm_t *p_fm)
+{
+	return (int)fman_qmi_init(p_fm->p_fm_qmi_regs,
+				  p_fm->p_fm_drv_param);
+}
+
+/*                      API Init unit functions                              */
+
+void *fm_config(struct fm_params_t *p_fm_param)
+{
+	struct fm_t *p_fm;
+	uintptr_t base_addr;
+
+	if (!((p_fm_param->firmware.p_code && p_fm_param->firmware.size) ||
+	      (!p_fm_param->firmware.p_code && !p_fm_param->firmware.size)))
+		return NULL;
+
+	base_addr = p_fm_param->base_addr;
+
+	/* Allocate FM structure */
+	p_fm = kzalloc(sizeof(*p_fm), GFP_KERNEL);
+	if (!p_fm)
+		return NULL;
+
+	p_fm->p_fm_state_struct = kzalloc(sizeof(*p_fm->p_fm_state_struct),
+						 GFP_KERNEL);
+	if (!p_fm->p_fm_state_struct) {
+		kfree(p_fm);
+		pr_err("FM Status structure\n");
+		return NULL;
+	}
+
+	/* Initialize FM parameters which will be kept by the driver */
+	p_fm->p_fm_state_struct->fm_id = p_fm_param->fm_id;
+
+	/* Allocate the FM driver's parameters structure */
+	p_fm->p_fm_drv_param = kzalloc(sizeof(*p_fm->p_fm_drv_param),
+						 GFP_KERNEL);
+	if (!p_fm->p_fm_drv_param) {
+		kfree(p_fm->p_fm_state_struct);
+		kfree(p_fm);
+		pr_err("FM driver parameters\n");
+		return NULL;
+	}
+
+	/* Initialize FM parameters which will be kept by the driver */
+	p_fm->p_fm_state_struct->fm_id = p_fm_param->fm_id;
+	p_fm->p_muram = p_fm_param->p_muram;
+	p_fm->h_app = p_fm_param->h_app;
+	p_fm->p_fm_state_struct->fm_clk_freq = p_fm_param->fm_clk_freq;
+	p_fm->f_exception = p_fm_param->f_exception;
+	p_fm->f_bus_error = p_fm_param->f_bus_error;
+	p_fm->p_fm_fpm_regs =
+	    (struct fman_fpm_regs __iomem *)UINT_TO_PTR(base_addr + FM_MM_FPM);
+	p_fm->p_fm_bmi_regs =
+	    (struct fman_bmi_regs __iomem *)UINT_TO_PTR(base_addr + FM_MM_BMI);
+	p_fm->p_fm_qmi_regs =
+	    (struct fman_qmi_regs __iomem *)UINT_TO_PTR(base_addr + FM_MM_QMI);
+	p_fm->p_fm_dma_regs =
+	    (struct fman_dma_regs __iomem *)UINT_TO_PTR(base_addr + FM_MM_DMA);
+	p_fm->p_fm_regs = (struct fman_regs __iomem *)
+			   UINT_TO_PTR(base_addr + FM_MM_BMI);
+	p_fm->base_addr = base_addr;
+
+	p_fm->spinlock = kmalloc(sizeof(spinlock_t), GFP_KERNEL);
+	if (!p_fm->spinlock) {
+		kfree(p_fm->p_fm_drv_param);
+		kfree(p_fm->p_fm_state_struct);
+		kfree(p_fm);
+		pr_err("can't allocate spinlock!\n");
+		return NULL;
+	}
+
+	spin_lock_init(p_fm->spinlock);
+	fman_defconfig(p_fm->p_fm_drv_param);
+
+/* overide macros dependent parameters */
+#ifdef FM_PEDANTIC_DMA
+	if (p_fm->p_fm_state_struct->rev_info.major_rev == 4) {
+		p_fm->p_fm_drv_param->pedantic_dma = true;
+		p_fm->p_fm_drv_param->dma_aid_override = true;
+	}
+#endif /* FM_PEDANTIC_DMA */
+#ifdef FM_QMI_NO_DEQ_OPTIONS_SUPPORT
+	if (p_fm->p_fm_state_struct->rev_info.major_rev != 4)
+		p_fm->p_fm_drv_param->qmi_deq_option_support = true;
+#endif /* !FM_QMI_NO_DEQ_OPTIONS_SUPPORT */
+
+	p_fm->p_fm_state_struct->rams_ecc_enable = false;
+	p_fm->p_fm_state_struct->extra_fifo_pool_size = 0;
+	p_fm->p_fm_state_struct->exceptions = DFLT_EXCEPTIONS;
+	p_fm->reset_on_init = DFLT_RESET_ON_INIT;
+	p_fm->fw_verify = DFLT_VERIFY_UCODE;
+	p_fm->firmware.size = p_fm_param->firmware.size;
+	if (p_fm->firmware.size) {
+		p_fm->firmware.p_code = kmalloc(p_fm->firmware.size,
+						GFP_KERNEL);
+		if (!p_fm->firmware.p_code) {
+			kfree(p_fm->spinlock);
+			kfree(p_fm->p_fm_state_struct);
+			kfree(p_fm->p_fm_drv_param);
+			kfree(p_fm);
+			pr_err("FM firmware code\n");
+			return NULL;
+		}
+		memcpy(p_fm->firmware.p_code,
+		       p_fm_param->firmware.p_code, p_fm->firmware.size);
+	}
+	/* read revision */
+	/* Chip dependent, will be configured in Init */
+	fman_get_revision(p_fm->p_fm_fpm_regs,
+			  &p_fm->p_fm_state_struct->rev_info.major_rev,
+			  &p_fm->p_fm_state_struct->rev_info.minor_rev);
+
+	p_fm->intg =
+		fill_intg_params(p_fm->p_fm_state_struct->rev_info.major_rev,
+				 p_fm->p_fm_state_struct->rev_info.minor_rev,
+				 p_fm_param);
+	if (!p_fm->intg) {
+			kfree(p_fm->firmware.p_code);
+			kfree(p_fm->spinlock);
+			kfree(p_fm->p_fm_state_struct);
+			kfree(p_fm->p_fm_drv_param);
+			kfree(p_fm);
+			return NULL;
+	}
+
+#ifdef FM_AID_MODE_NO_TNUM_SW005
+	if (p_fm->p_fm_state_struct->rev_info.major_rev >= 6)
+		p_fm->p_fm_drv_param->dma_aid_mode = FM_DMA_AID_OUT_PORT_ID;
+#endif /* FM_AID_MODE_NO_TNUM_SW005 */
+#ifdef FM_QMI_NO_DEQ_OPTIONS_SUPPORT
+	if (p_fm->p_fm_state_struct->rev_info.major_rev != 4)
+		p_fm->p_fm_drv_param->qmi_def_tnums_thresh =
+		    p_fm->intg->qmi_def_tnums_thresh;
+#endif /* FM_QMI_NO_DEQ_OPTIONS_SUPPORT */
+
+	p_fm->p_fm_state_struct->total_fifo_size = 0;
+	p_fm->p_fm_state_struct->total_num_of_tasks =
+	(u8)DFLT_TOTAL_NUM_OF_TASKS(
+		p_fm->p_fm_state_struct->rev_info.major_rev,
+		p_fm->p_fm_state_struct->rev_info.minor_rev,
+		p_fm->intg->bmi_max_num_of_tasks);
+#ifdef FM_HAS_TOTAL_DMAS
+	if (p_fm->p_fm_state_struct->rev_info.major_rev < 6)
+		p_fm->p_fm_state_struct->max_num_of_open_dmas =
+		p_fm->intg->bmi_max_num_of_dmas;
+#endif /* FM_HAS_TOTAL_DMAS */
+	if (p_fm->p_fm_state_struct->rev_info.major_rev < 6) {
+		p_fm->p_fm_drv_param->dma_comm_qtsh_clr_emer =
+		(u8)DFLT_DMA_COMM_Q_LOW(p_fm->p_fm_state_struct->rev_info.
+				    major_rev,
+				    p_fm->intg->dma_thresh_max_commq);
+
+		p_fm->p_fm_drv_param->dma_comm_qtsh_asrt_emer =
+		(u8)DFLT_DMA_COMM_Q_HIGH(p_fm->p_fm_state_struct->rev_info.
+				     major_rev,
+				     p_fm->intg->dma_thresh_max_commq);
+
+		p_fm->p_fm_drv_param->dma_cam_num_of_entries =
+		DFLT_DMA_CAM_NUM_OF_ENTRIES(p_fm->p_fm_state_struct->
+					    rev_info.major_rev);
+		p_fm->p_fm_drv_param->dma_read_buf_tsh_clr_emer =
+		(u8)DFLT_DMA_READ_INT_BUF_LOW(p_fm->intg->dma_thresh_max_buf);
+
+		p_fm->p_fm_drv_param->dma_read_buf_tsh_asrt_emer =
+		(u8)DFLT_DMA_READ_INT_BUF_HIGH(p_fm->intg->dma_thresh_max_buf);
+
+		p_fm->p_fm_drv_param->dma_write_buf_tsh_clr_emer =
+		(u8)DFLT_DMA_WRITE_INT_BUF_LOW(p_fm->intg->dma_thresh_max_buf);
+
+		p_fm->p_fm_drv_param->dma_write_buf_tsh_asrt_emer =
+		(u8)DFLT_DMA_WRITE_INT_BUF_HIGH(p_fm->intg->dma_thresh_max_buf);
+
+		p_fm->p_fm_drv_param->dma_axi_dbg_num_of_beats =
+		DFLT_AXI_DBG_NUM_OF_BEATS;
+		}
+
+#ifdef FM_NO_TNUM_AGING
+	p_fm->p_fm_drv_param->tnum_aging_period = 0;
+#endif /* FM_NO_TNUM_AGING */
+	p_fm->tnum_aging_period = p_fm->p_fm_drv_param->tnum_aging_period;
+
+	return p_fm;
+}
+
+/*     fm_init
+ *
+ *  Initializes the FM module
+ *
+ * @Param[in]     p_fm - FM module descriptor
+ *
+ * @Return        0 on success; Error code otherwise.
+ */
+int fm_init(struct fm_t *p_fm)
+{
+	struct fman_cfg *p_fm_drv_param = NULL;
+	int err = 0;
+	int i;
+	struct fm_revision_info_t rev_info;
+	struct fman_rg fman_rg;
+	int ret, ret_err;
+
+	ret = is_init_done(p_fm->p_fm_drv_param);
+	if (!ret)
+		return -EINVAL;
+
+	fman_rg.bmi_rg = p_fm->p_fm_bmi_regs;
+	fman_rg.qmi_rg = p_fm->p_fm_qmi_regs;
+	fman_rg.fpm_rg = p_fm->p_fm_fpm_regs;
+	fman_rg.dma_rg = p_fm->p_fm_dma_regs;
+
+	p_fm->p_fm_state_struct->count1_micro_bit = FM_TIMESTAMP_1_USEC_BIT;
+	p_fm->p_fm_drv_param->num_of_fman_ctrl_evnt_regs =
+	    FM_NUM_OF_FMAN_CTRL_EVENT_REGS;
+
+	/* if user didn't configured total_fifo_size -
+	 * (total_fifo_size=0) we configure default
+	 * according to chip. otherwise, we use user's configuration.
+	 */
+	if (p_fm->p_fm_state_struct->total_fifo_size == 0)
+		p_fm->p_fm_state_struct->total_fifo_size =
+		DFLT_TOTAL_FIFO_SIZE(
+				p_fm->p_fm_state_struct->rev_info.major_rev,
+				p_fm->p_fm_state_struct->rev_info.minor_rev);
+
+	ret_err = check_fm_parameters(p_fm);
+	if (ret_err)
+		return ret_err;
+
+	p_fm_drv_param = p_fm->p_fm_drv_param;
+
+	fm_get_revision(p_fm, &rev_info);
+
+	/* clear revision-dependent non existing exception */
+#ifdef FM_NO_DISPATCH_RAM_ECC
+	if ((rev_info.major_rev != 4) && (rev_info.major_rev < 6))
+		p_fm->p_fm_state_struct->exceptions &=
+		    ~FM_EX_BMI_DISPATCH_RAM_ECC;
+#endif /* FM_NO_DISPATCH_RAM_ECC */
+
+#ifdef FM_QMI_NO_ECC_EXCEPTIONS
+	if (rev_info.major_rev == 4)
+		p_fm->p_fm_state_struct->exceptions &=
+		    ~(FM_EX_QMI_SINGLE_ECC | FM_EX_QMI_DOUBLE_ECC);
+#endif /* FM_QMI_NO_ECC_EXCEPTIONS */
+
+#ifdef FM_QMI_NO_SINGLE_ECC_EXCEPTION
+	if (rev_info.major_rev >= 6)
+		p_fm->p_fm_state_struct->exceptions &= ~FM_EX_QMI_SINGLE_ECC;
+#endif /* FM_QMI_NO_SINGLE_ECC_EXCEPTION */
+
+	/* clear CPG */
+	memset_io(UINT_TO_PTR(p_fm->base_addr + FM_MM_CGP), 0,
+		  p_fm->intg->fm_port_num_of_cg);
+
+	/* add to the default exceptions the user's definitions */
+	p_fm->p_fm_state_struct->exceptions |= p_fm->user_set_exceptions;
+
+#ifdef FM_UCODE_NOT_RESET_ERRATA_BUGZILLA6173
+	if (p_fm->p_fm_state_struct->rev_info.major_rev < 6 &&
+	    p_fm->p_fm_state_struct->rev_info.major_rev != 4 &&
+	    p_fm->reset_on_init) {
+		err = fw_not_reset_erratum_bugzilla6173wa(p_fm);
+		if (err != 0)
+			return err;
+	} else {
+#endif /* FM_UCODE_NOT_RESET_ERRATA_BUGZILLA6173 */
+
+		/* Reset the FM if required. */
+		if (p_fm->reset_on_init) {
+			u32 svr = mfspr(SPRN_SVR);
+
+			if (((SVR_SOC_VER(svr) == SVR_T4240 &&
+			      SVR_REV(svr) > 0x10)) ||
+				((SVR_SOC_VER(svr) == SVR_T4160 &&
+				  SVR_REV(svr) > 0x10)) ||
+				((SVR_SOC_VER(svr) == SVR_T4080 &&
+				  SVR_REV(svr) > 0x10)) ||
+				(SVR_SOC_VER(svr) == SVR_T2080) ||
+				(SVR_SOC_VER(svr) == SVR_T2081)) {
+				pr_debug("Hack: No FM reset!\n");
+			} else {
+				WRITE_UINT32(p_fm->p_fm_fpm_regs->fm_rstc,
+					     FPM_RSTC_FM_RESET);
+				/* Memory barrier */
+				mb();
+				usleep_range(100, 101);
+			}
+
+			if (fman_is_qmi_halt_not_busy_state(
+				p_fm->p_fm_qmi_regs)) {
+				fman_resume(p_fm->p_fm_fpm_regs);
+				usleep_range(100, 101);
+			}
+		}
+
+		/* Load FMan-Controller code to IRAM */
+
+		if (clear_iram(p_fm) != 0)
+			return -EINVAL;
+		if (p_fm->firmware.p_code && (load_fman_ctrl_code(p_fm) != 0))
+			return -EINVAL;
+#ifdef FM_UCODE_NOT_RESET_ERRATA_BUGZILLA6173
+	}
+#endif /* FM_UCODE_NOT_RESET_ERRATA_BUGZILLA6173 */
+
+	/* General FM driver initialization */
+	for (i = 0; i < FM_EV_DUMMY_LAST; i++)
+		p_fm->intr_mng[i].f_isr = unimplemented_isr;
+
+	p_fm_drv_param->exceptions = p_fm->p_fm_state_struct->exceptions;
+
+	/* Init DMA Registers */
+
+	err = init_fm_dma(p_fm);
+	if (err != 0) {
+		free_init_resources(p_fm);
+		return err;
+	}
+
+	/* Init FPM Registers */
+
+	err = init_fm_fpm(p_fm);
+	if (err != 0) {
+		free_init_resources(p_fm);
+		return err;
+	}
+
+	/* define common resources */
+	/* allocate MURAM for FIFO according to total size */
+	p_fm->fifo_offset = fm_muram_alloc(p_fm->p_muram,
+					   p_fm->p_fm_state_struct->
+					   total_fifo_size);
+	if (IS_ERR_VALUE(p_fm->cam_offset)) {
+		free_init_resources(p_fm);
+		pr_err("MURAM alloc for BMI FIFO failed\n");
+		return -ENOMEM;
+	}
+
+	p_fm_drv_param->fifo_base_addr = p_fm->fifo_offset;
+	p_fm_drv_param->total_fifo_size =
+		p_fm->p_fm_state_struct->total_fifo_size;
+	p_fm_drv_param->total_num_of_tasks =
+		p_fm->p_fm_state_struct->total_num_of_tasks;
+	p_fm_drv_param->clk_freq = p_fm->p_fm_state_struct->fm_clk_freq;
+
+	/* Init BMI Registers */
+
+	err = init_fm_bmi(p_fm);
+	if (err != 0) {
+		free_init_resources(p_fm);
+		return err;
+	}
+
+	/* Init QMI Registers */
+
+	err = init_fm_qmi(p_fm);
+	if (err != 0) {
+		free_init_resources(p_fm);
+		return err;
+	}
+
+	err = (int)fman_enable(&fman_rg, p_fm_drv_param);
+	if (err != 0)
+		return err;	/* FIXME */
+
+	enable_time_stamp(p_fm);
+
+	kfree(p_fm->firmware.p_code);
+	p_fm->firmware.p_code = NULL;
+
+	kfree(p_fm->p_fm_drv_param);
+	p_fm->p_fm_drv_param = NULL;
+
+	return 0;
+}
+
+/* fm_free
+ * Frees all resources that were assigned to FM module.
+ * Calling this routine invalidates the descriptor.
+ * p_fm - FM module descriptor
+ *Return        0 on success; Error code otherwise.
+ */
+int fm_free(struct fm_t *p_fm)
+{
+	struct fman_rg fman_rg;
+
+	fman_rg.bmi_rg = p_fm->p_fm_bmi_regs;
+	fman_rg.qmi_rg = p_fm->p_fm_qmi_regs;
+	fman_rg.fpm_rg = p_fm->p_fm_fpm_regs;
+	fman_rg.dma_rg = p_fm->p_fm_dma_regs;
+
+	fman_free_resources(&fman_rg);
+
+	kfree(p_fm->spinlock);
+
+	if (p_fm->p_fm_drv_param) {
+		kfree(p_fm->firmware.p_code);
+		kfree(p_fm->p_fm_drv_param);
+		p_fm->p_fm_drv_param = NULL;
+	}
+
+	free_init_resources(p_fm);
+
+	kfree(p_fm->p_fm_state_struct);
+
+	kfree(p_fm);
+
+	return 0;
+}
+
+/*       API Advanced Init unit functions        */
+
+int fm_cfg_reset_on_init(struct fm_t *p_fm, bool enable)
+{
+	int ret;
+
+	ret = is_init_done(p_fm->p_fm_drv_param);
+	if (!ret)
+		return -EINVAL;
+
+	p_fm->reset_on_init = enable;
+
+	return 0;
+}
+
+int fm_cfg_total_fifo_size(struct fm_t *p_fm, uint32_t total_fifo_size)
+{
+	int ret;
+
+	ret = is_init_done(p_fm->p_fm_drv_param);
+	if (!ret)
+		return -EINVAL;
+
+	p_fm->p_fm_state_struct->total_fifo_size = total_fifo_size;
+
+	return 0;
+}
+
+int fm_cfg_dma_aid_override(struct fm_t *p_fm, bool aid_override)
+{
+	int ret;
+
+	ret = is_init_done(p_fm->p_fm_drv_param);
+	if (!ret)
+		return -EINVAL;
+
+	p_fm->p_fm_drv_param->dma_aid_override = aid_override;
+
+	return 0;
+}
+
+/*       API Run-time Control uint functions        */
+
+void fm_event_isr(struct fm_t *p_fm)
+{
+#define FM_M_CALL_MAC_ISR(_id)    \
+	(p_fm->intr_mng[(enum fm_inter_module_event)(FM_EV_MAC0 + _id)]. \
+	f_isr(p_fm->intr_mng[(enum fm_inter_module_event)(FM_EV_MAC0 + _id)] \
+	.h_src_handle))
+	uint32_t pending;
+	int ret;
+	struct fman_fpm_regs __iomem *fpm_rg;
+
+	ret = is_init_done(p_fm->p_fm_drv_param);
+	if (ret)
+		return;
+
+	fpm_rg = p_fm->p_fm_fpm_regs;
+
+	/* normal interrupts */
+	pending = fman_get_normal_pending(fpm_rg);
+	if (!pending)
+		return;
+
+	if (pending & INTR_EN_QMI)
+		qmi_event(p_fm);
+	if (pending & INTR_EN_PRS)
+		p_fm->intr_mng[FM_EV_PRS].f_isr(p_fm->intr_mng[FM_EV_PRS].
+						 h_src_handle);
+	if (pending & INTR_EN_TMR)
+		p_fm->intr_mng[FM_EV_TMR].f_isr(p_fm->intr_mng[FM_EV_TMR].
+						 h_src_handle);
+
+	/* MAC events may belong to different partitions */
+	if (pending & INTR_EN_MAC0)
+		FM_M_CALL_MAC_ISR(0);
+	if (pending & INTR_EN_MAC1)
+		FM_M_CALL_MAC_ISR(1);
+	if (pending & INTR_EN_MAC2)
+		FM_M_CALL_MAC_ISR(2);
+	if (pending & INTR_EN_MAC3)
+		FM_M_CALL_MAC_ISR(3);
+	if (pending & INTR_EN_MAC4)
+		FM_M_CALL_MAC_ISR(4);
+	if (pending & INTR_EN_MAC5)
+		FM_M_CALL_MAC_ISR(5);
+	if (pending & INTR_EN_MAC6)
+		FM_M_CALL_MAC_ISR(6);
+	if (pending & INTR_EN_MAC7)
+		FM_M_CALL_MAC_ISR(7);
+	if (pending & INTR_EN_MAC8)
+		FM_M_CALL_MAC_ISR(8);
+	if (pending & INTR_EN_MAC9)
+		FM_M_CALL_MAC_ISR(9);
+}
+
+int fm_error_isr(struct fm_t *p_fm)
+{
+#define FM_M_CALL_MAC_ERR_ISR(_id) \
+	(p_fm->intr_mng[(enum fm_inter_module_event)(FM_EV_ERR_MAC0 + _id)]. \
+	f_isr(p_fm->intr_mng[(enum fm_inter_module_event)\
+	(FM_EV_ERR_MAC0 + _id)].h_src_handle))
+	uint32_t pending;
+	struct fman_fpm_regs __iomem *fpm_rg;
+	int ret;
+
+	ret = is_init_done(p_fm->p_fm_drv_param);
+	if (ret)
+		return ret;
+
+	fpm_rg = p_fm->p_fm_fpm_regs;
+
+	/* error interrupts */
+	pending = fman_get_fpm_error_interrupts(fpm_rg);
+	if (!pending)
+		return -EINVAL;
+
+	if (pending & ERR_INTR_EN_BMI)
+		bmi_err_event(p_fm);
+	if (pending & ERR_INTR_EN_QMI)
+		qmi_err_event(p_fm);
+	if (pending & ERR_INTR_EN_FPM)
+		fpm_err_event(p_fm);
+	if (pending & ERR_INTR_EN_DMA)
+		dma_err_event(p_fm);
+	if (pending & ERR_INTR_EN_IRAM)
+		iram_err_intr(p_fm);
+	if (pending & ERR_INTR_EN_MURAM)
+		muram_err_intr(p_fm);
+	if (pending & ERR_INTR_EN_PRS)
+		p_fm->intr_mng[FM_EV_ERR_PRS].f_isr(p_fm->
+						     intr_mng[FM_EV_ERR_PRS].
+						     h_src_handle);
+
+	/* MAC events may belong to different partitions */
+	if (pending & ERR_INTR_EN_MAC0)
+		FM_M_CALL_MAC_ERR_ISR(0);
+	if (pending & ERR_INTR_EN_MAC1)
+		FM_M_CALL_MAC_ERR_ISR(1);
+	if (pending & ERR_INTR_EN_MAC2)
+		FM_M_CALL_MAC_ERR_ISR(2);
+	if (pending & ERR_INTR_EN_MAC3)
+		FM_M_CALL_MAC_ERR_ISR(3);
+	if (pending & ERR_INTR_EN_MAC4)
+		FM_M_CALL_MAC_ERR_ISR(4);
+	if (pending & ERR_INTR_EN_MAC5)
+		FM_M_CALL_MAC_ERR_ISR(5);
+	if (pending & ERR_INTR_EN_MAC6)
+		FM_M_CALL_MAC_ERR_ISR(6);
+	if (pending & ERR_INTR_EN_MAC7)
+		FM_M_CALL_MAC_ERR_ISR(7);
+	if (pending & ERR_INTR_EN_MAC8)
+		FM_M_CALL_MAC_ERR_ISR(8);
+	if (pending & ERR_INTR_EN_MAC9)
+		FM_M_CALL_MAC_ERR_ISR(9);
+
+	return 0;
+}
+
+int fm_disable_rams_ecc(struct fm_t *p_fm)
+{
+	bool explicit_disable = false;
+	struct fman_fpm_regs __iomem *fpm_rg;
+	int ret;
+
+	ret = is_init_done(p_fm->p_fm_drv_param);
+	if (ret)
+		return ret;
+
+	fpm_rg = p_fm->p_fm_fpm_regs;
+
+	if (!p_fm->p_fm_state_struct->internal_call)
+		explicit_disable = true;
+	p_fm->p_fm_state_struct->internal_call = false;
+
+	/* if rams are already disabled, or if rams were explicitly enabled and
+	 *  are currently called indirectly (not explicitly), ignore this call.
+	 */
+	if (!p_fm->p_fm_state_struct->rams_ecc_enable ||
+	    (p_fm->p_fm_state_struct->explicit_enable && !explicit_disable))
+		return 0;
+	if (p_fm->p_fm_state_struct->explicit_enable)
+		/* This is the case were both explicit are true.
+		 * Turn off this flag for cases were following
+		 * ramsEnable routines are called
+		 */
+		p_fm->p_fm_state_struct->explicit_enable = false;
+
+	fman_enable_rams_ecc(fpm_rg);
+	p_fm->p_fm_state_struct->rams_ecc_enable = false;
+
+	return 0;
+}
+
+int fm_set_exception(struct fm_t *p_fm, enum fm_exceptions exception,
+		     bool enable)
+{
+	uint32_t bit_mask = 0;
+	enum fman_exceptions fsl_exception;
+	struct fman_rg fman_rg;
+	int ret;
+
+	ret = is_init_done(p_fm->p_fm_drv_param);
+	if (ret)
+		return ret;
+
+	fman_rg.bmi_rg = p_fm->p_fm_bmi_regs;
+	fman_rg.qmi_rg = p_fm->p_fm_qmi_regs;
+	fman_rg.fpm_rg = p_fm->p_fm_fpm_regs;
+	fman_rg.dma_rg = p_fm->p_fm_dma_regs;
+
+	GET_EXCEPTION_FLAG(bit_mask, exception);
+	if (bit_mask) {
+		if (enable)
+			p_fm->p_fm_state_struct->exceptions |= bit_mask;
+		else
+			p_fm->p_fm_state_struct->exceptions &= ~bit_mask;
+
+		FMAN_EXCEPTION_TRANS(fsl_exception, exception);
+
+		return (int)fman_set_exception(&fman_rg,
+					       fsl_exception, enable);
+	} else {
+		pr_err("Undefined exceptioni\n");
+		return -EDOM;
+	}
+
+	return 0;
+}
+
+int fm_get_revision(struct fm_t *p_fm, struct fm_revision_info_t
+			*p_fm_revision_info)
+{
+	p_fm_revision_info->major_rev = p_fm->p_fm_state_struct->
+					rev_info.major_rev;
+	p_fm_revision_info->minor_rev = p_fm->p_fm_state_struct->
+					rev_info.minor_rev;
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/freescale/fman/fm.h b/drivers/net/ethernet/freescale/fman/fm.h
new file mode 100644
index 0000000..f7f56e3
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/fm.h
@@ -0,0 +1,404 @@
+/*
+ * Copyright 2008-2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
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
+/* FM internal structures and definitions. */
+#ifndef __FM_H
+#define __FM_H
+
+#include "service.h"
+#include "fm_ext.h"
+
+#include "fsl_fman.h"
+
+/* Prevents the use of TX port 1 with OP port 0 for FM Major Rev 4 (P1023) */
+#define FM_LOW_END_RESTRICTION
+
+/* Hardware defines */
+#define FM_MAX_NUM_OF_HW_PORT_IDS           64
+#define FM_MAX_NUM_OF_MACS	10
+
+#define FM_NUM_OF_FMAN_CTRL_EVENT_REGS		4
+
+#define GET_EXCEPTION_FLAG(bit_mask, exception)			\
+do {									\
+	switch ((int)exception) {					\
+	case FM_EX_DMA_BUS_ERROR:					\
+		bit_mask = FM_EX_DMA_BUS_ERROR;			\
+		break;							\
+	case FM_EX_DMA_SINGLE_PORT_ECC:				\
+		bit_mask = FM_EX_DMA_SINGLE_PORT_ECC;			\
+		break;							\
+	case FM_EX_DMA_READ_ECC:					\
+		bit_mask = FM_EX_DMA_READ_ECC;				\
+		break;							\
+	case FM_EX_DMA_SYSTEM_WRITE_ECC:				\
+		bit_mask = FM_EX_DMA_SYSTEM_WRITE_ECC;			\
+		break;							\
+	case FM_EX_DMA_FM_WRITE_ECC:					\
+		bit_mask = FM_EX_DMA_FM_WRITE_ECC;			\
+		break;							\
+	case FM_EX_FPM_STALL_ON_TASKS:					\
+		bit_mask = FM_EX_FPM_STALL_ON_TASKS;			\
+		break;							\
+	case FM_EX_FPM_SINGLE_ECC:					\
+		bit_mask = FM_EX_FPM_SINGLE_ECC;			\
+		break;							\
+	case FM_EX_FPM_DOUBLE_ECC:					\
+		bit_mask = FM_EX_FPM_DOUBLE_ECC;			\
+		break;							\
+	case FM_EX_QMI_SINGLE_ECC:					\
+		bit_mask = FM_EX_QMI_SINGLE_ECC;			\
+		break;							\
+	case FM_EX_QMI_DOUBLE_ECC:					\
+		bit_mask = FM_EX_QMI_DOUBLE_ECC;			\
+		break;							\
+	case FM_EX_QMI_DEQ_FROM_UNKNOWN_PORTID:			\
+		bit_mask = FM_EX_QMI_DEQ_FROM_UNKNOWN_PORTID;		\
+		break;							\
+	case FM_EX_BMI_LIST_RAM_ECC:					\
+		bit_mask = FM_EX_BMI_LIST_RAM_ECC;			\
+		break;							\
+	case FM_EX_BMI_STORAGE_PROFILE_ECC:				\
+		bit_mask = FM_EX_BMI_STORAGE_PROFILE_ECC;		\
+		break;							\
+	case FM_EX_BMI_STATISTICS_RAM_ECC:				\
+		bit_mask = FM_EX_BMI_STATISTICS_RAM_ECC;		\
+		break;							\
+	case FM_EX_BMI_DISPATCH_RAM_ECC:				\
+		bit_mask = FM_EX_BMI_DISPATCH_RAM_ECC;			\
+		break;							\
+	case FM_EX_IRAM_ECC:						\
+		bit_mask = FM_EX_IRAM_ECC;				\
+		break;							\
+	case FM_EX_MURAM_ECC:						\
+		bit_mask = FM_EX_MURAM_ECC;				\
+		break;							\
+	default:							\
+		bit_mask = 0;						\
+		break;							\
+	}								\
+} while (0)
+
+#define GET_FM_MODULE_EVENT(_p_fm, _mod, _id, _intr_type, _event)	\
+do {									\
+	switch (_mod) {							\
+	case (FM_MOD_PRS):						\
+		if (_id)						\
+			_event = FM_EV_DUMMY_LAST;			\
+		else							\
+			event = (_intr_type == FM_INTR_TYPE_ERR) ?	\
+			FM_EV_ERR_PRS : FM_EV_PRS;			\
+		break;							\
+	case (FM_MOD_TMR):						\
+		if (_id)						\
+			_event = FM_EV_DUMMY_LAST;			\
+		else							\
+			_event = (_intr_type == FM_INTR_TYPE_ERR) ?	\
+			FM_EV_DUMMY_LAST : FM_EV_TMR;			\
+		break;							\
+	case (FM_MOD_MAC):						\
+			_event = (_intr_type == FM_INTR_TYPE_ERR) ?	\
+			(FM_EV_ERR_MAC0 + _id) :			\
+			(FM_EV_MAC0 + _id);				\
+		break;							\
+	case (FM_MOD_FMAN_CTRL):					\
+		if (_intr_type == FM_INTR_TYPE_ERR)			\
+			_event = FM_EV_DUMMY_LAST;			\
+		else							\
+			_event = (FM_EV_FMAN_CTRL_0 + _id);		\
+		break;							\
+	default:							\
+		_event = FM_EV_DUMMY_LAST;				\
+		break;							\
+	}								\
+} while (0)
+
+#define FMAN_EXCEPTION_TRANS(fsl_exception, _exception) do {\
+switch ((int)_exception) {\
+case  FM_EX_DMA_BUS_ERROR:                    \
+	fsl_exception =  E_FMAN_EX_DMA_BUS_ERROR;\
+	break;    \
+case  FM_EX_DMA_READ_ECC:                    \
+	fsl_exception =  E_FMAN_EX_DMA_READ_ECC;\
+	break;        \
+case  FM_EX_DMA_SYSTEM_WRITE_ECC:                \
+	fsl_exception =  E_FMAN_EX_DMA_SYSTEM_WRITE_ECC;\
+	break;    \
+case  FM_EX_DMA_FM_WRITE_ECC:                    \
+	fsl_exception =  E_FMAN_EX_DMA_FM_WRITE_ECC;\
+	break;    \
+case  FM_EX_FPM_STALL_ON_TASKS:                \
+	fsl_exception =  E_FMAN_EX_FPM_STALL_ON_TASKS;\
+	break;    \
+case  FM_EX_FPM_SINGLE_ECC:                    \
+	fsl_exception =  E_FMAN_EX_FPM_SINGLE_ECC;\
+	break;    \
+case  FM_EX_FPM_DOUBLE_ECC:                    \
+	fsl_exception =  E_FMAN_EX_FPM_DOUBLE_ECC;\
+	break;    \
+case  FM_EX_QMI_SINGLE_ECC:                    \
+	fsl_exception =  E_FMAN_EX_QMI_SINGLE_ECC;\
+	break;    \
+case  FM_EX_QMI_DOUBLE_ECC:                    \
+	fsl_exception =  E_FMAN_EX_QMI_DOUBLE_ECC;\
+	break;    \
+case  FM_EX_QMI_DEQ_FROM_UNKNOWN_PORTID:            \
+	fsl_exception =  E_FMAN_EX_QMI_DEQ_FROM_UNKNOWN_PORTID;\
+	break; \
+case  FM_EX_BMI_LIST_RAM_ECC:                    \
+	fsl_exception =  E_FMAN_EX_BMI_LIST_RAM_ECC;\
+	break;    \
+case  FM_EX_BMI_STORAGE_PROFILE_ECC:                    \
+	fsl_exception =  E_FMAN_EX_BMI_STORAGE_PROFILE_ECC;\
+	break;    \
+case  FM_EX_BMI_STATISTICS_RAM_ECC:                \
+	fsl_exception =  E_FMAN_EX_BMI_STATISTICS_RAM_ECC;\
+	break; \
+case  FM_EX_BMI_DISPATCH_RAM_ECC:                \
+	fsl_exception =  E_FMAN_EX_BMI_DISPATCH_RAM_ECC;\
+	break;    \
+case  FM_EX_IRAM_ECC:                        \
+	fsl_exception =  E_FMAN_EX_IRAM_ECC;\
+	break;        \
+case  FM_EX_MURAM_ECC:                    \
+	fsl_exception =  E_FMAN_EX_MURAM_ECC;\
+	break;        \
+default: \
+	fsl_exception =  E_FMAN_EX_DMA_BUS_ERROR; break;    \
+} \
+} while (0)
+
+/* defaults */
+#define DFLT_EXCEPTIONS	\
+	((FM_EX_DMA_BUS_ERROR)            | \
+	(FM_EX_DMA_READ_ECC)              | \
+	(FM_EX_DMA_SYSTEM_WRITE_ECC)      | \
+	(FM_EX_DMA_FM_WRITE_ECC)          | \
+	(FM_EX_FPM_STALL_ON_TASKS)        | \
+	(FM_EX_FPM_SINGLE_ECC)            | \
+	(FM_EX_FPM_DOUBLE_ECC)            | \
+	(FM_EX_QMI_DEQ_FROM_UNKNOWN_PORTID) | \
+	(FM_EX_BMI_LIST_RAM_ECC)          | \
+	(FM_EX_BMI_STORAGE_PROFILE_ECC)   | \
+	(FM_EX_BMI_STATISTICS_RAM_ECC)    | \
+	(FM_EX_IRAM_ECC)                  | \
+	(FM_EX_MURAM_ECC)                 | \
+	(FM_EX_BMI_DISPATCH_RAM_ECC)      | \
+	(FM_EX_QMI_DOUBLE_ECC)            | \
+	(FM_EX_QMI_SINGLE_ECC))
+
+#define DFLT_AXI_DBG_NUM_OF_BEATS            1
+#define DFLT_RESET_ON_INIT                 false
+/* do not change! if changed, must be disabled for rev1 ! */
+#define DFLT_VERIFY_UCODE                 false
+
+#define DFLT_DMA_READ_INT_BUF_LOW(dma_thresh_max_buf)	\
+	((dma_thresh_max_buf + 1) / 2)
+#define DFLT_DMA_READ_INT_BUF_HIGH(dma_thresh_max_buf)	\
+	((dma_thresh_max_buf + 1) * 3 / 4)
+#define DFLT_DMA_WRITE_INT_BUF_LOW(dma_thresh_max_buf)	\
+	((dma_thresh_max_buf + 1) / 2)
+#define DFLT_DMA_WRITE_INT_BUF_HIGH(dma_thresh_max_buf)\
+	((dma_thresh_max_buf + 1) * 3 / 4)
+#define DFLT_DMA_COMM_Q_LOW(major, dma_thresh_max_commq)	\
+	((major == 6) ? 0x2A : ((dma_thresh_max_commq + 1) / 2))
+#define DFLT_DMA_COMM_Q_HIGH(major, dma_thresh_max_commq)	\
+	((major == 6) ? 0x3f : ((dma_thresh_max_commq + 1) * 3 / 4))
+#define DFLT_TOTAL_NUM_OF_TASKS(major, minor, bmi_max_num_of_tasks)	\
+	((major == 6) ? ((minor == 1 || minor == 4) ? 59 : 124) :	\
+	bmi_max_num_of_tasks)
+
+#define DFLT_DMA_CAM_NUM_OF_ENTRIES(major)	(major == 6 ? 64 : 32)
+
+#define DFLT_TOTAL_FIFO_SIZE(major, minor)			\
+	((major == 6) ?						\
+	((minor == 1 || minor == 4) ? (156 * 1024) : (295 * 1024)) :	\
+	(((major == 2) || (major == 5)) ?			\
+	(100 * 1024) : ((major == 4) ?			\
+	(46 * 1024) : (122 * 1024))))
+
+#define FM_TIMESTAMP_1_USEC_BIT             8
+
+/* Defines used for enabling/disabling FM interrupts */
+#define ERR_INTR_EN_DMA         0x00010000
+#define ERR_INTR_EN_FPM         0x80000000
+#define ERR_INTR_EN_BMI         0x00800000
+#define ERR_INTR_EN_QMI         0x00400000
+#define ERR_INTR_EN_PRS         0x00200000
+#define ERR_INTR_EN_MURAM       0x00040000
+#define ERR_INTR_EN_IRAM        0x00020000
+#define ERR_INTR_EN_MAC8        0x00008000
+#define ERR_INTR_EN_MAC9        0x00000040
+#define ERR_INTR_EN_MAC0        0x00004000
+#define ERR_INTR_EN_MAC1        0x00002000
+#define ERR_INTR_EN_MAC2        0x00001000
+#define ERR_INTR_EN_MAC3        0x00000800
+#define ERR_INTR_EN_MAC4        0x00000400
+#define ERR_INTR_EN_MAC5        0x00000200
+#define ERR_INTR_EN_MAC6        0x00000100
+#define ERR_INTR_EN_MAC7        0x00000080
+
+#define INTR_EN_QMI             0x40000000
+#define INTR_EN_PRS             0x20000000
+#define INTR_EN_MAC0            0x00080000
+#define INTR_EN_MAC1            0x00040000
+#define INTR_EN_MAC2            0x00020000
+#define INTR_EN_MAC3            0x00010000
+#define INTR_EN_MAC4            0x00000040
+#define INTR_EN_MAC5            0x00000020
+#define INTR_EN_MAC6            0x00000008
+#define INTR_EN_MAC7            0x00000002
+#define INTR_EN_MAC8            0x00200000
+#define INTR_EN_MAC9            0x00100000
+#define INTR_EN_REV0            0x00008000
+#define INTR_EN_REV1            0x00004000
+#define INTR_EN_REV2            0x00002000
+#define INTR_EN_REV3            0x00001000
+#define INTR_EN_BRK             0x00000080
+#define INTR_EN_TMR             0x01000000
+
+/* Modules registers offsets */
+#define FM_MM_MURAM             0x00000000
+#define FM_MM_BMI               0x00080000
+#define FM_MM_QMI               0x00080400
+#define FM_MM_PRS               0x000c7000
+#define FM_MM_DMA               0x000C2000
+#define FM_MM_FPM               0x000C3000
+#define FM_MM_IMEM              0x000C4000
+#define FM_MM_CGP               0x000DB000
+#define FM_MM_TRB(i)            (0x000D0200 + 0x400 * (i))
+#define FM_MM_SP                0x000dc000
+
+/* Memory Mapped Registers */
+
+struct fm_iram_regs_t {
+	uint32_t iadd;	/* FM IRAM instruction address register */
+	uint32_t idata;/* FM IRAM instruction data register */
+	uint32_t itcfg;/* FM IRAM timing config register */
+	uint32_t iready;/* FM IRAM ready register */
+	uint8_t res[0x80000 - 0x10];
+} __attribute__((__packed__));
+
+/* General defines */
+#define FM_FW_DEBUG_INSTRUCTION             0x6ffff805UL
+
+struct fm_state_struct_t {
+	uint8_t fm_id;
+	uint16_t fm_clk_freq;
+	struct fm_revision_info_t rev_info;
+	bool enabled_time_stamp;
+	uint8_t count1_micro_bit;
+	uint8_t total_num_of_tasks;
+	uint32_t total_fifo_size;
+	uint8_t max_num_of_open_dmas;
+	uint8_t accumulated_num_of_tasks;
+	uint32_t accumulated_fifo_size;
+	uint8_t accumulated_num_of_open_dmas;
+	uint8_t accumulated_num_of_deq_tnums;
+#ifdef FM_LOW_END_RESTRICTION
+	bool low_end_restriction;
+#endif /* FM_LOW_END_RESTRICTION */
+	uint32_t exceptions;
+	bool rams_ecc_enable;
+	bool explicit_enable;
+	bool internal_call;
+	uint32_t extra_fifo_pool_size;
+	uint8_t extra_tasks_pool_size;
+	uint8_t extra_open_dmas_pool_size;
+};
+
+struct fm_intg_t {
+	/* Ram defines */
+	uint32_t fm_muram_size;
+	uint32_t fm_iram_size;
+	uint32_t fm_num_of_ctrl;
+
+	/* DMA defines */
+	uint32_t dma_thresh_max_commq;
+	uint32_t dma_thresh_max_buf;
+
+	/* QMI defines */
+	uint32_t qmi_max_num_of_tnums;
+	uint32_t qmi_def_tnums_thresh;
+
+	/* BMI defines */
+	uint32_t bmi_max_num_of_tasks;
+	uint32_t bmi_max_num_of_dmas;
+	uint32_t bmi_max_fifo_size;
+	uint32_t port_max_weight;
+
+	uint32_t fm_port_num_of_cg;
+	uint32_t num_of_rx_ports;
+};
+
+struct fm_t {
+/* locals for recovery */
+	uintptr_t base_addr;
+
+/* un-needed for recovery */
+	char fm_module_name[MODULE_NAME_SIZE];
+	/* FM exceptions user callback */
+	struct fm_intr_src_t intr_mng[FM_EV_DUMMY_LAST];
+
+/* Master Only parameters */
+
+/* locals for recovery */
+	struct fman_fpm_regs __iomem *p_fm_fpm_regs;
+	struct fman_bmi_regs __iomem *p_fm_bmi_regs;
+	struct fman_qmi_regs __iomem *p_fm_qmi_regs;
+	struct fman_dma_regs __iomem *p_fm_dma_regs;
+	struct fman_regs __iomem *p_fm_regs;
+	fm_exceptions_cb *f_exception;
+	fm_bus_error_cb *f_bus_error;
+	void *h_app;		/* Application handle */
+	spinlock_t *spinlock;
+	struct fm_state_struct_t *p_fm_state_struct;
+	uint16_t tnum_aging_period;
+
+	struct fman_cfg *p_fm_drv_param;
+	struct muram_info *p_muram;
+	/* cam section in muram */
+	int cam_offset;
+	uint32_t cam_size;
+	uintptr_t res_addr;
+	/* Fifo in MURAM */
+	int fifo_offset;
+	uint32_t fifo_size;
+	struct fm_firmware_params_t firmware;
+	bool fw_verify;
+	bool reset_on_init;
+	uint32_t user_set_exceptions;
+
+	struct fm_intg_t *intg;
+};
+
+#endif /* __FM_H */
diff --git a/drivers/net/ethernet/freescale/fman/fm_common.h b/drivers/net/ethernet/freescale/fman/fm_common.h
new file mode 100644
index 0000000..125c057
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/fm_common.h
@@ -0,0 +1,367 @@
+/*
+ * Copyright 2008-2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
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
+/* File          fm_common.h
+ * Description   FM internal structures and definitions.
+ */
+#ifndef __FM_COMMON_H
+#define __FM_COMMON_H
+
+#include "service.h"
+#include "fm_ext.h"
+
+/* Uniqe defines */
+#define FM_QMI_NO_ECC_EXCEPTIONS		/* P1 */
+#define FM_CSI_CFED_LIMIT			/* P1 */
+#define FM_PEDANTIC_DMA				/* P1 */
+#define FM_QMI_NO_DEQ_OPTIONS_SUPPORT		/* P1 */
+#define FM_HAS_TOTAL_DMAS			/* P1-P5 */
+#define FM_DEQ_PIPELINE_PARAMS_FOR_OP		/* P1, T/B */
+#define FM_NO_DISPATCH_RAM_ECC			/* P2-P5 */
+#define FM_NO_WATCHDOG				/* P4 */
+#define FM_NO_TNUM_AGING			/* P2-P5 */
+#define FM_NO_BACKUP_POOLS			/* P2-P5 */
+#define FM_NO_OP_OBSERVED_POOLS		/* P2-P5, T/B */
+#define FM_NO_ADVANCED_RATE_LIMITER		/* P2-P5 */
+#define FM_OP_OPEN_DMA_MIN_LIMIT		/* T/B */
+#define FM_NO_RESTRICT_ON_ACCESS_RSRC		/* T/B */
+#define FM_FRAME_END_PARAMS_FOR_OP		/* T/B */
+#define FM_QMI_NO_SINGLE_ECC_EXCEPTION		/* T/B */
+
+/* FMan Errata */
+#define FM_RX_PREAM_4_ERRATA_DTSEC_A001			/* Dtsec */
+#define FM_GTS_AFTER_DROPPED_FRAME_ERRATA_DTSEC_A004839	/* Dtsec */
+#define FM_TX_FIFO_CORRUPTION_ERRATA_10GMAC_A007		/* Tgec */
+#define FM_ECC_HALT_NO_SYNC_ERRATA_10GMAC_A008			/* P2-P5 */
+#define FM_GRS_ERRATA_DTSEC_A002				/* P4080 */
+#define FM_BAD_TX_TS_IN_B_2_B_ERRATA_DTSEC_A003		/* P4080 */
+#define FM_GTS_ERRATA_DTSEC_A004				/* P4080 */
+#define FM_GTS_AFTER_MAC_ABORTED_FRAME_ERRATA_DTSEC_A0012	/* P4080 */
+#define FM_GTS_UNDERRUN_ERRATA_DTSEC_A0014			/* P2-P5 */
+#define FM_TX_LOCKUP_ERRATA_DTSEC6				/* P4080 */
+#define FM_UCODE_NOT_RESET_ERRATA_BUGZILLA6173			/* P2-P5 */
+#define FM_10G_REM_N_LCL_FLT_EX_10GMAC_ERRATA_SW005		/* P4080 */
+#define FM_TX_ECC_FRMS_ERRATA_10GMAC_A004			/* P2-P5 */
+#define FM_LEN_CHECK_ERRATA_FMAN_SW002				/* P2-P5, T/B */
+#define FM_WRONG_RESET_VALUES_ERRATA_FMAN_A005127		/* T/B */
+#define FM_RX_FIFO_CORRUPT_ERRATA_10GMAC_A006320		/* mEMAC */
+#define FM_HEAVY_TRAFFIC_SEQUENCER_HANG_ERRATA_FMAN_A006981   /* T4/B4 rev1 */
+#define FM_AID_MODE_NO_TNUM_SW005
+/* refer to pdm TKT068794 - only support of port_id on aid - T/B */
+#define FM_ERROR_VSP_NO_MATCH_SW006
+/* refer to pdm TKT174304 - no match between errorQ and VSP - T/B */
+
+#define CLS_PLAN_NUM_PER_GRP                        8
+
+/* list_object
+ * Macro to get the struct (object) for this entry.
+ * type   - The type of the struct (object) this list
+ * is embedded in.
+ * member - The name of the struct list_head object
+ * within the struct.
+ * Return        The structure pointer for this entry.
+ */
+#define member_offset(type, member) (PTR_TO_UINT(&((type *)0)->member))
+#define list_object(p_list, type, member) \
+((type *)((char *)(p_list) - member_offset(type, member)))
+
+/* Enum for inter-module interrupts registration */
+enum fm_event_modules {
+	FM_MOD_PRS = 0,		/* Parser event */
+	FM_MOD_MAC,		/* MAC event */
+	FM_MOD_TMR,		/* Timer event */
+	FM_MOD_FMAN_CTRL,	/* FMAN Controller  Timer event */
+	FM_MOD_DUMMY_LAST
+};
+
+/* Enum for interrupts types */
+enum fm_intr_type {
+	FM_INTR_TYPE_ERR,
+	FM_INTR_TYPE_NORMAL
+};
+
+/* Enum for inter-module interrupts registration */
+enum fm_inter_module_event {
+	FM_EV_PRS = 0,		/* Parser event */
+	FM_EV_ERR_PRS,		/* Parser error event */
+	FM_EV_ERR_MAC8,		/* MAC 8 error event */
+	FM_EV_ERR_MAC9,		/* MAC 9 error event */
+	FM_EV_ERR_MAC0,		/* MAC 0 error event */
+	FM_EV_ERR_MAC1,		/* MAC 1 error event */
+	FM_EV_ERR_MAC2,		/* MAC 2 error event */
+	FM_EV_ERR_MAC3,		/* MAC 3 error event */
+	FM_EV_ERR_MAC4,		/* MAC 4 error event */
+	FM_EV_ERR_MAC5,		/* MAC 5 error event */
+	FM_EV_ERR_MAC6,		/* MAC 6 error event */
+	FM_EV_ERR_MAC7,		/* MAC 7 error event */
+	FM_EV_TMR,		/* Timer event */
+	FM_EV_MAC8,		/* MAC 8 event (Magic packet detection)*/
+	FM_EV_MAC9,		/* MAC 9 event (Magic packet detection)*/
+	FM_EV_MAC0,		/* MAC 0 event (Magic packet detection)*/
+	FM_EV_MAC1,		/* MAC 1 event (Magic packet detection)*/
+	FM_EV_MAC2,		/* MAC 2 (Magic packet detection)*/
+	FM_EV_MAC3,		/* MAC 3 (Magic packet detection)*/
+	FM_EV_MAC4,		/* MAC 4 (Magic packet detection)*/
+	FM_EV_MAC5,		/* MAC 5 (Magic packet detection)*/
+	FM_EV_MAC6,		/* MAC 6 (Magic packet detection)*/
+	FM_EV_MAC7,		/* MAC 7 (Magic packet detection)*/
+	FM_EV_FMAN_CTRL_0,	/* Fman controller event 0 */
+	FM_EV_FMAN_CTRL_1,	/* Fman controller event 1 */
+	FM_EV_FMAN_CTRL_2,	/* Fman controller event 2 */
+	FM_EV_FMAN_CTRL_3,	/* Fman controller event 3 */
+	FM_EV_DUMMY_LAST
+};
+
+/* FM IP BLOCK versions */
+#define FM_IP_BLOCK_P1			4
+#define FM_IP_BLOCK_P2_P3_P5		3
+#define FM_IP_BLOCK_P4			2
+#define FM_IP_BLOCK_B_T			6
+
+/*for UNDER_CONSTRUCTION_FM_RMU_USE_SEC its defined in fm_ext.h*/
+typedef uint32_t fm_fman_ctrl_t;
+
+#define FPM_PORT_FM_CTL1                0x00000001
+#define FPM_PORT_FM_CTL2                0x00000002
+
+static inline bool TRY_LOCK(spinlock_t *spinlock, volatile bool *p_flag)
+{
+	unsigned long int_flags;
+
+	if (spinlock)
+		spin_lock_irqsave(spinlock, int_flags);
+	else
+		local_irq_save(int_flags);
+
+	if (*p_flag) {
+		if (spinlock)
+			spin_unlock_irqrestore(spinlock, int_flags);
+		else
+			local_irq_restore(int_flags);
+		return false;
+	}
+	*p_flag = true;
+
+	if (spinlock)
+		spin_unlock_irqrestore(spinlock, int_flags);
+	else
+		local_irq_restore(int_flags);
+
+	return true;
+}
+
+#define RELEASE_LOCK(_flag) (_flag = false)
+
+/* Defines used for manipulation CC and BMI */
+#define INTERNAL_CONTEXT_OFFSET                 0x80000000
+#define OFFSET_OF_PR                            0x40000000
+#define NUM_OF_TASKS                            0x10000000
+#define OFFSET_OF_DATA                          0x08000000
+#define HW_PORT_ID                              0x04000000
+#define FM_REV                                  0x02000000
+#define GET_NIA_FPNE                            0x01000000
+#define GET_NIA_PNDN                            0x00800000
+#define NUM_OF_EXTRA_TASKS                      0x00400000
+#define DISCARD_MASK                            0x00200000
+
+#define UPDATE_NIA_PNEN                         0x80000000
+#define UPDATE_PSO                              0x40000000
+#define UPDATE_NIA_PNDN                         0x20000000
+#define UPDATE_FMFP_PRC_WITH_ONE_RISC_ONLY      0x10000000
+#define UPDATE_NIA_FENE                         0x04000000
+#define UPDATE_NIA_CMNE                         0x02000000
+#define UPDATE_NIA_FPNE                         0x01000000
+
+/* Defines used for manipulation CC and CC */
+#define UPDATE_NIA_ENQ_WITHOUT_DMA              0x80000000
+
+#define MODULE_NAME_SIZE        30
+#define DUMMY_PORT_ID           0
+
+#define FM_LIODN_OFFSET_MASK    0x3FF
+
+/* Description        CTRL Parameters Page defines */
+#define FM_CTL_PARAMS_PAGE_OP_FIX_EN            0x80000000
+#define FM_CTL_PARAMS_PAGE_ALWAYS_ON            0x00000100
+
+#define FM_CTL_PARAMS_PAGE_ERROR_VSP_MASK       0x0000003f
+
+#define BMI_MAX_FIFO_SIZE                   (FM_MURAM_SIZE)
+#define BMI_FIFO_UNITS                      0x100
+
+struct fm_intr_src_t {
+	void (*f_isr)(void *h_src_arg);
+	void *h_src_handle;
+};
+
+#define ILLEGAL_HDR_NUM                     0xFF
+#define NO_HDR_NUM                          FM_PCD_PRS_NUM_OF_HDRS
+
+#define IS_PRIVATE_HEADER(hdr)	(((hdr) == HEADER_TYPE_USER_DEFINED_SHIM1) || \
+				 ((hdr) == HEADER_TYPE_USER_DEFINED_SHIM2))
+
+#define GET_PRS_HDR_NUM(num, hdr) do {\
+switch (hdr) { \
+case (HEADER_TYPE_ETH):\
+	num = 0;  break;   \
+case (HEADER_TYPE_LLC_SNAP):\
+	num = 1;  break;   \
+case (HEADER_TYPE_VLAN):\
+	num = 2;  break;   \
+case (HEADER_TYPE_PPPOE):\
+	num = 3;  break;   \
+case (HEADER_TYPE_PPP):\
+	num = 3;  break;   \
+case (HEADER_TYPE_MPLS):\
+	num = 4;  break;   \
+case (HEADER_TYPE_IPV4):\
+	num = 5;  break;   \
+case (HEADER_TYPE_IPV6):\
+	num = 6;  break;   \
+case (HEADER_TYPE_GRE):\
+	num = 7;  break;   \
+case (HEADER_TYPE_MINENCAP):\
+	num = 8;  break;   \
+case (HEADER_TYPE_USER_DEFINED_L3):\
+	num = 9;  break;   \
+case (HEADER_TYPE_TCP):\
+	num = 10; break;   \
+case (HEADER_TYPE_UDP):\
+	num = 11; break;   \
+case (HEADER_TYPE_IPSEC_AH): \
+case (HEADER_TYPE_IPSEC_ESP):\
+	num = 12; break;   \
+case (HEADER_TYPE_SCTP):\
+	num = 13; break;   \
+case (HEADER_TYPE_DCCP):\
+	num = 14; break;   \
+case (HEADER_TYPE_USER_DEFINED_L4):\
+	num = 15; break;   \
+case (HEADER_TYPE_USER_DEFINED_SHIM1):                  \
+case (HEADER_TYPE_USER_DEFINED_SHIM2):                  \
+	num = NO_HDR_NUM; break;                            \
+default:                                                \
+	pr_err("Unsupported header for parser\n");\
+	num = ILLEGAL_HDR_NUM; break;                       \
+} \
+} while (0)
+
+/* Function      fm_register_intr
+ * Description   Used to register
+ * an inter-module event handler to be processed by FM
+ * Param[in]     h_fm            A handle to an FM Module.
+ * Param[in]     mod             The module that causes the event
+ * Param[in]     mod_id           Module id - if more than 1 instance of this
+ *				mode exists,0 otherwise.
+ * Param[in]     intr_type        Interrupt type (error/normal) selection.
+ * Param[in]     f_isr           The interrupt service routine.
+ * Param[in]     h_src_arg           Argument to be passed to f_isr.
+ * Return        None.
+ */
+void fm_register_intr(struct fm_t *p_fm,
+		      enum fm_event_modules mod,
+		      uint8_t mod_id,
+		      enum fm_intr_type intr_type,
+		      void (*f_isr)(void *h_src_arg), void *h_src_arg);
+
+/* Function      fm_unregister_intr
+ * Description   Used to un-register an
+ * inter-module event handler that was processed by FM
+ * Param[in]     h_fm            A handle to an FM Module.
+ * Param[in]     mod             The module that causes the event
+ * Param[in]     mod_id           Module id - if more than 1 instance of this
+ *				mode exists,0 otherwise.
+ * Param[in]     intr_type        Interrupt type (error/normal) selection.
+ * Return        None.
+ */
+void fm_unregister_intr(struct fm_t *p_fm,
+			enum fm_event_modules mod,
+			uint8_t mod_id, enum fm_intr_type intr_type);
+
+/* Description   enum for defining MAC types */
+enum fm_mac_type {
+	FM_MAC_10G = 0,	    /* 10G MAC */
+	FM_MAC_1G	    /* 1G MAC */
+};
+
+/* Function      fm_get_muram_pointer
+ * Description   Get the pointer of the MURAM from the FM module
+ * Param[in]     h_fm            A handle to an FM Module.
+ * Return        MURAM module pointer.
+ */
+struct muram_info *fm_get_muram_pointer(struct fm_t *p_fm);
+
+/* Function      fm_get_physical_muram_base
+ * Description   Get the physical base address of the MURAM from the FM module
+ * Param[in]     h_fm            A handle to an FM Module.
+ * Param[in]     fm_phys_addr      Physical MURAM base
+ * Return        Physical base address.
+ */
+void fm_get_physical_muram_base(struct fm_t *p_fm,
+				struct fm_phys_addr_t *fm_phys_addr);
+
+/* Function      fm_get_clock_freq
+ * Description   Used by MAC driver to get the FM clock frequency
+ * Param[in]     h_fm            A handle to an FM Module.
+ * Return        clock-freq on success; 0 otherwise.
+ * Cautions      Allowed only following fm_init().
+ */
+uint16_t fm_get_clock_freq(struct fm_t *p_fm);
+
+/*Function      fm_get_id
+ * Description   Used by PCD driver to read rhe FM id
+ * Param[in]     h_fm            A handle to an FM Module.
+ * Return        0 on success; Error code otherwise.
+ * Cautions      Allowed only following fm_init().
+ */
+uint8_t fm_get_id(struct fm_t *p_fm);
+
+int fm_set_num_of_open_dmas(struct fm_t *p_fm,
+			    uint8_t port_id,
+			    uint8_t *p_num_of_open_dmas,
+			    uint8_t *p_num_of_extra_open_dmas,
+			    bool initial_config);
+int fm_set_num_of_tasks(struct fm_t *p_fm,
+			uint8_t port_id,
+			uint8_t *p_num_of_tasks,
+			uint8_t *p_num_of_extra_tasks,
+			bool initial_config);
+int fm_set_size_of_fifo(struct fm_t *p_fm,
+			uint8_t port_id,
+			uint32_t *p_size_of_fifo,
+			uint32_t *p_extra_size_of_fifo,
+			bool initial_config);
+
+uint32_t fm_get_bmi_max_fifo_size(struct fm_t *p_fm);
+struct num_of_ports_info_t *fm_get_num_of_ports(struct fm_t *p_fm);
+
+#endif /* __FM_COMMON_H */
diff --git a/drivers/net/ethernet/freescale/fman/fm_drv.c b/drivers/net/ethernet/freescale/fman/fm_drv.c
new file mode 100644
index 0000000..2c78829
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/fm_drv.c
@@ -0,0 +1,827 @@
+/*
+ * Copyright 2008-2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
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
+#include <linux/version.h>
+#include <linux/slab.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/fs.h>
+#include <linux/cdev.h>
+#include <linux/device.h>
+#include <linux/irq.h>
+#include <linux/interrupt.h>
+#include <linux/io.h>
+#include <linux/ioport.h>
+#include <linux/of_platform.h>
+#include <linux/of_address.h>
+#include <linux/of_irq.h>
+#include <linux/slab.h>
+#include <linux/clk-provider.h>
+#include <linux/uaccess.h>
+#include <linux/errno.h>
+#include <asm/qe.h>		/* For struct qe_firmware */
+#include <sysdev/fsl_soc.h>
+#include <linux/stat.h>		/* For file access mask */
+#include <linux/skbuff.h>
+
+/* Internal services */
+#include "service.h"
+#include "fm_ext.h"
+#include "fm_drv.h"
+#include "fm_muram_ext.h"
+
+/* Bootarg used to override the Kconfig FSL_FM_MAX_FRAME_SIZE value */
+#define FSL_FM_MAX_FRM_BOOTARG     "fsl_fm_max_frm"
+
+/* Bootarg used to override FSL_FM_RX_EXTRA_HEADROOM Kconfig value */
+#define FSL_FM_RX_EXTRA_HEADROOM_BOOTARG  "fsl_fm_rx_extra_headroom"
+
+/* Minimum and maximum value for the fsl_fm_rx_extra_headroom bootarg */
+#define FSL_FM_RX_EXTRA_HEADROOM_MIN 16
+#define FSL_FM_RX_EXTRA_HEADROOM_MAX 384
+
+/* Max frame size, across all interfaces.
+ * Configurable from Kconfig or bootargs, to avoid allocating oversized
+ * (socket) buffers when not using jumbo frames.
+ * Must be large enough to accommodate the network MTU, but small enough
+ * to avoid wasting skb memory.
+ *
+ * Could be overridden once, at boot-time, via the
+ * fm_set_max_frm() callback.
+ */
+int fsl_fm_max_frm = CONFIG_FSL_FM_MAX_FRAME_SIZE;
+
+/* Extra headroom for Rx buffers.
+ * FMan is instructed to allocate, on the Rx path, this amount of
+ * space at the beginning of a data buffer, beside the DPA private
+ * data area and the IC fields.
+ * Does not impact Tx buffer layout.
+ * Configurable from Kconfig or bootargs. Zero by default, it's needed on
+ * particular forwarding scenarios that add extra headers to the
+ * forwarded frame.
+ */
+int fsl_fm_rx_extra_headroom = CONFIG_FSL_FM_RX_EXTRA_HEADROOM;
+
+static struct fm_drvs_t fm_drvs;
+
+u16 fm_get_max_frm(void)
+{
+	return fsl_fm_max_frm;
+}
+EXPORT_SYMBOL(fm_get_max_frm);
+
+int fm_get_rx_extra_headroom(void)
+{
+	return ALIGN(fsl_fm_rx_extra_headroom, 16);
+}
+EXPORT_SYMBOL(fm_get_rx_extra_headroom);
+
+static int __init fm_set_max_frm(char *str)
+{
+	int ret = 0;
+
+	ret = get_option(&str, &fsl_fm_max_frm);
+	if (ret != 1) {
+		/* This will only work if CONFIG_EARLY_PRINTK is compiled in,
+		 * and something like "earlyprintk=serial,uart0,115200" is
+		 * specified in the bootargs.
+		 */
+		pr_err("No suitable %s=<int> prop in bootargs; will use the default FSL_FM_MAX_FRAME_SIZE (%d) from Kconfig.\n",
+		       FSL_FM_MAX_FRM_BOOTARG,
+		       CONFIG_FSL_FM_MAX_FRAME_SIZE);
+
+		fsl_fm_max_frm = CONFIG_FSL_FM_MAX_FRAME_SIZE;
+		return 1;
+	}
+
+	/* Don't allow invalid bootargs; fallback to the Kconfig value */
+	if (fsl_fm_max_frm < 64 || fsl_fm_max_frm > 9600) {
+		pr_err("Invalid %s=%d in bootargs, valid range is 64-9600. Falling back to the FSL_FM_MAX_FRAME_SIZE (%d) from Kconfig.\n",
+		       FSL_FM_MAX_FRM_BOOTARG, fsl_fm_max_frm,
+		       CONFIG_FSL_FM_MAX_FRAME_SIZE);
+
+		fsl_fm_max_frm = CONFIG_FSL_FM_MAX_FRAME_SIZE;
+		return 1;
+	}
+
+	pr_info("Using fsl_fm_max_frm=%d from bootargs\n", fsl_fm_max_frm);
+	return 0;
+}
+
+early_param(FSL_FM_MAX_FRM_BOOTARG, fm_set_max_frm);
+
+static int __init fm_set_rx_extra_headroom(char *str)
+{
+	int ret;
+
+	ret = get_option(&str, &fsl_fm_rx_extra_headroom);
+
+	if (ret != 1) {
+		pr_err("No suitable %s=<int> prop in bootargs; will use the default FSL_FM_RX_EXTRA_HEADROOM (%d) from Kconfig.\n",
+		       FSL_FM_RX_EXTRA_HEADROOM_BOOTARG,
+		       CONFIG_FSL_FM_RX_EXTRA_HEADROOM);
+		fsl_fm_rx_extra_headroom = CONFIG_FSL_FM_RX_EXTRA_HEADROOM;
+
+		return 1;
+	}
+
+	if (fsl_fm_rx_extra_headroom < FSL_FM_RX_EXTRA_HEADROOM_MIN ||
+	    fsl_fm_rx_extra_headroom > FSL_FM_RX_EXTRA_HEADROOM_MAX) {
+		pr_err("Invalid value for %s=%d prop in bootargs; will use the default FSL_FM_RX_EXTRA_HEADROOM (%d) from Kconfig.\n",
+		       FSL_FM_RX_EXTRA_HEADROOM_BOOTARG,
+		       fsl_fm_rx_extra_headroom,
+		       CONFIG_FSL_FM_RX_EXTRA_HEADROOM);
+		fsl_fm_rx_extra_headroom = CONFIG_FSL_FM_RX_EXTRA_HEADROOM;
+	}
+
+	pr_info("Using fsl_fm_rx_extra_headroom=%d from bootargs\n",
+		fsl_fm_rx_extra_headroom);
+
+	return 0;
+}
+
+early_param(FSL_FM_RX_EXTRA_HEADROOM_BOOTARG, fm_set_rx_extra_headroom);
+
+static irqreturn_t fm_irq(int irq, void *_dev)
+{
+	struct fm_drv_t *p_fm_drv = (struct fm_drv_t *)_dev;
+
+	if (!p_fm_drv || !p_fm_drv->h_dev)
+		return IRQ_NONE;
+
+	fm_event_isr(p_fm_drv->h_dev);
+
+	return IRQ_HANDLED;
+}
+
+static irqreturn_t fm_err_irq(int irq, void *_dev)
+{
+	struct fm_drv_t *p_fm_drv = (struct fm_drv_t *)_dev;
+
+	if (!p_fm_drv || !p_fm_drv->h_dev)
+		return IRQ_NONE;
+
+	if (fm_error_isr(p_fm_drv->h_dev) == 0)
+		return IRQ_HANDLED;
+
+	return IRQ_NONE;
+}
+
+/* used to protect FMD from concurrent calls in functions
+ * fm_mutex_lock / fm_mutex_unlock
+ */
+static struct mutex fm_drv_mutex;
+
+static struct fm_drv_t *create_fm_dev(uint8_t id)
+{
+	struct fm_drv_t *p_fm_drv;
+
+	p_fm_drv = kzalloc(sizeof(*p_fm_drv), GFP_KERNEL);
+	if (!p_fm_drv)
+		return NULL;
+
+	return p_fm_drv;
+}
+
+static void destroy_fm_dev(struct fm_drv_t *p_fm_drv)
+{
+	kfree(p_fm_drv);
+}
+
+/**
+*find_fman_microcode - find the Fman microcode
+ *
+*This function returns a pointer to the QE Firmware blob that holds
+*the Fman microcode.  We use the QE Firmware structure because Fman microcode
+*is similar to QE microcode, so there's no point in defining a new layout.
+ *
+*Current versions of U-Boot embed the Fman firmware into the device tree,
+*so we check for that first.  Each Fman node in the device tree contains a
+*node or a pointer to node that holds the firmware.  Technically, we should
+*be fetching the firmware node for the current Fman, but we don't have that
+*information any more, so we assume that there is only one firmware node in
+*the device tree, and that all Fmen use the same firmware.
+ */
+static const struct qe_firmware *find_fman_microcode(void)
+{
+	static const struct qe_firmware *p4080_uc_patch;
+	struct device_node *np;
+
+	if (p4080_uc_patch)
+		return p4080_uc_patch;
+
+	/* The firmware should be inside the device tree. */
+	np = of_find_compatible_node(NULL, NULL, "fsl,fman-firmware");
+	if (np) {
+		p4080_uc_patch = of_get_property(np, "fsl,firmware", NULL);
+		of_node_put(np);
+		if (p4080_uc_patch)
+			return p4080_uc_patch;
+
+		pr_info("firmware node is incomplete\n");
+	}
+
+	/* Returning NULL here forces the reuse of the IRAM content */
+	return NULL;
+}
+
+static int fill_qman_channhels_info(struct fm_drv_t *p_fm_drv)
+{
+	p_fm_drv->qman_channels = kcalloc(p_fm_drv->num_of_qman_channels,
+					  sizeof(uint32_t),
+					  GFP_KERNEL);
+	if (!p_fm_drv->qman_channels)
+		return -ENOMEM;
+
+	if (p_fm_drv->fm_rev_info.major_rev >= 6) {
+		p_fm_drv->qman_channels[0] = 0x30;
+		p_fm_drv->qman_channels[1] = 0x31;
+		p_fm_drv->qman_channels[2] = 0x28;
+		p_fm_drv->qman_channels[3] = 0x29;
+		p_fm_drv->qman_channels[4] = 0x2a;
+		p_fm_drv->qman_channels[5] = 0x2b;
+		p_fm_drv->qman_channels[6] = 0x2c;
+		p_fm_drv->qman_channels[7] = 0x2d;
+		p_fm_drv->qman_channels[8] = 0x2;
+		p_fm_drv->qman_channels[9] = 0x3;
+		p_fm_drv->qman_channels[10] = 0x4;
+		p_fm_drv->qman_channels[11] = 0x5;
+		p_fm_drv->qman_channels[12] = 0x6;
+		p_fm_drv->qman_channels[13] = 0x7;
+	} else {
+		p_fm_drv->qman_channels[0] = 0x30;
+		p_fm_drv->qman_channels[1] = 0x28;
+		p_fm_drv->qman_channels[2] = 0x29;
+		p_fm_drv->qman_channels[3] = 0x2a;
+		p_fm_drv->qman_channels[4] = 0x2b;
+		p_fm_drv->qman_channels[5] = 0x2c;
+		p_fm_drv->qman_channels[6] = 0x1;
+		p_fm_drv->qman_channels[7] = 0x2;
+		p_fm_drv->qman_channels[8] = 0x3;
+		p_fm_drv->qman_channels[9] = 0x4;
+		p_fm_drv->qman_channels[10] = 0x5;
+		p_fm_drv->qman_channels[11] = 0x6;
+	}
+
+	return 0;
+}
+
+#define SVR_SECURITY_MASK    0x00080000
+#define SVR_PERSONALITY_MASK 0x0000FF00
+#define SVR_VER_IGNORE_MASK (SVR_SECURITY_MASK | SVR_PERSONALITY_MASK)
+#define SVR_B4860_REV1_VALUE 0x86800010
+#define SVR_B4860_REV2_VALUE 0x86800020
+
+static struct fm_drv_t *read_fm_dev_tree_node(struct platform_device
+							*of_dev)
+{
+	struct fm_drv_t *p_fm_drv;
+	struct device_node *fm_node, *dev_node;
+	struct of_device_id name; /* used temporarily */
+	struct resource res;
+	const uint32_t *uint32_prop;
+	int lenp, err;
+	struct clk *clk;
+	u32 clk_rate;
+	u8 cell_index;
+
+	fm_node = of_node_get(of_dev->dev.of_node);
+
+	uint32_prop =
+	    (uint32_t *)of_get_property(fm_node, "cell-index", &lenp);
+	if (unlikely(!uint32_prop)) {
+		pr_err("of_get_property(%s, cell-index) failed\n",
+		       fm_node->full_name);
+		goto _return_null;
+	}
+	if (WARN_ON(lenp != sizeof(uint32_t)))
+		return NULL;
+
+	cell_index = (u8)*uint32_prop;
+	p_fm_drv = create_fm_dev(cell_index);
+	if (!p_fm_drv)
+		goto _return_null;
+	p_fm_drv->dev = &of_dev->dev;
+	p_fm_drv->id = cell_index;
+
+	/* Get the FM interrupt */
+	p_fm_drv->irq = of_irq_to_resource(fm_node, 0, NULL);
+	if (unlikely(p_fm_drv->irq == /*NO_IRQ */ 0)) {
+		pr_err("of_irq_to_resource() = %d\n", NO_IRQ);
+		goto _return_null;
+	}
+
+	/* Get the FM error interrupt */
+	p_fm_drv->err_irq = of_irq_to_resource(fm_node, 1, NULL);
+
+	/* Get the FM address */
+	err = of_address_to_resource(fm_node, 0, &res);
+	if (unlikely(err < 0)) {
+		pr_err("of_address_to_resource() = %d\n", err);
+		goto _return_null;
+	}
+
+	p_fm_drv->fm_base_addr = 0;
+	p_fm_drv->fm_phys_base_addr = res.start;
+	p_fm_drv->fm_mem_size = res.end + 1 - res.start;
+
+	clk = clk_get(p_fm_drv->dev, p_fm_drv->id == 0 ? "fm0clk" : "fm1clk");
+	if (IS_ERR(clk)) {
+		pr_err("Failed to get FM%d clock structure\n", p_fm_drv->id);
+		goto _return_null;
+	}
+
+	clk_rate = clk_get_rate(clk);
+	if (!clk_rate) {
+		pr_err("Failed to determine FM%d clock rate\n", p_fm_drv->id);
+		goto _return_null;
+	}
+	/* Rounding to MHz */
+	clk_rate = (clk_rate + 500000) / 1000000;
+	p_fm_drv->params.fm_clk_freq = (u16)clk_rate;
+
+	uint32_prop =
+	    (uint32_t *)of_get_property(fm_node,
+					"fsl,qman-channel-range",
+					&lenp);
+	if (unlikely(!uint32_prop)) {
+		pr_err("of_get_property(%s, fsl,qman-channel-range) failed\n",
+		       fm_node->full_name);
+		goto _return_null;
+	}
+	if (WARN_ON(lenp != sizeof(uint32_t) * 2))
+		goto _return_null;
+	p_fm_drv->qman_channel_base = uint32_prop[0];
+	p_fm_drv->num_of_qman_channels = uint32_prop[1];
+
+	/* Get the MURAM base address and size */
+	memset(&name, 0, sizeof(name));
+	if (WARN_ON(strlen("muram") >= sizeof(name.name)))
+		goto _return_null;
+	strcpy(name.name, "muram");
+	if (WARN_ON(strlen("fsl,fman-muram") >= sizeof(name.compatible)))
+		goto _return_null;
+	strcpy(name.compatible, "fsl,fman-muram");
+	for_each_child_of_node(fm_node, dev_node) {
+		if (likely(of_match_node(&name, dev_node))) {
+			err = of_address_to_resource(dev_node, 0, &res);
+			if (unlikely(err < 0)) {
+				pr_err("of_address_to_resource() = %d\n",
+				       err);
+				goto _return_null;
+			}
+
+			p_fm_drv->fm_muram_base_addr = 0;
+			p_fm_drv->fm_muram_phys_base_addr = res.start;
+			p_fm_drv->fm_muram_mem_size = res.end + 1 - res.start;
+			{
+				/* In B4 rev 2.0 (and above) the MURAM size is
+				 * 512KB.
+				 * Check the SVR and update MURAM size if
+				 * required.
+				 */
+				uint32_t svr;
+
+				svr = mfspr(SPRN_SVR);
+
+				if ((svr & ~SVR_VER_IGNORE_MASK) >=
+				    SVR_B4860_REV2_VALUE)
+					p_fm_drv->fm_muram_mem_size = 0x80000;
+			}
+		}
+	}
+
+	of_node_put(fm_node);
+
+	p_fm_drv->active = true;
+
+	goto _return;
+
+_return_null:
+	of_node_put(fm_node);
+	return NULL;
+_return:
+	return p_fm_drv;
+}
+
+static void fm_drv_exceptions_cb(void *h_app,
+				 enum fm_exceptions __maybe_unused exception)
+{
+	struct fm_drv_t *p_fm_drv = (struct fm_drv_t *)h_app;
+
+	ASSERT(p_fm_drv);
+
+	pr_debug("got fm exception %d\n", exception);
+}
+
+static void fm_drv_bus_error_cb(void *h_app,
+				enum fm_port_type __maybe_unused port_type,
+				uint8_t __maybe_unused port_id,
+				uint64_t __maybe_unused addr,
+				uint8_t __maybe_unused tnum,
+				uint16_t __maybe_unused liodn)
+{
+	struct fm_drv_t *p_fm_drv = (struct fm_drv_t *)h_app;
+
+	ASSERT(p_fm_drv);
+}
+
+uint32_t get_qman_channel_id(struct fm_drv_t *p_fm_drv,
+			     uint32_t port_id,
+			     enum fm_port_type port_type,
+			     enum fm_port_speed port_speed)
+{
+	uint32_t qman_channel = 0;
+	int i;
+
+	for (i = 0; i < p_fm_drv->num_of_qman_channels; i++) {
+		if (p_fm_drv->qman_channels[i] == port_id)
+			break;
+	}
+
+	if (i == p_fm_drv->num_of_qman_channels)
+		return 0;
+
+	qman_channel = p_fm_drv->qman_channel_base + i;
+
+	return qman_channel;
+}
+
+static int configure_fm_dev(struct fm_drv_t *p_fm_drv)
+{
+	int err;
+
+	if (!p_fm_drv->active) {
+		pr_err("FM not configured!\n");
+		return -EINVAL;
+	}
+
+#ifndef MODULE
+	err = can_request_irq(p_fm_drv->irq, 0);
+	if (unlikely(err < 0)) {
+		pr_err("can_request_irq() = %d\n", err);
+		return -EINVAL;
+	}
+#endif
+	err = devm_request_irq(p_fm_drv->dev, p_fm_drv->irq, fm_irq,
+			       IRQF_NO_SUSPEND, "fman", p_fm_drv);
+	if (unlikely(err < 0)) {
+		pr_err("request_irq(%d) = %d\n", p_fm_drv->irq,
+		       err);
+		return -EINVAL;
+	}
+
+	if (p_fm_drv->err_irq != 0) {
+#ifndef MODULE
+		err = can_request_irq(p_fm_drv->err_irq, 0);
+		if (unlikely(err < 0)) {
+			pr_err("can_request_irq() = %d\n", err);
+			return -EINVAL;
+		}
+#endif
+		err = devm_request_irq(p_fm_drv->dev, p_fm_drv->err_irq,
+				       fm_err_irq,
+				       IRQF_SHARED | IRQF_NO_SUSPEND,
+				       "fman-err", p_fm_drv);
+		if (unlikely(err < 0)) {
+			pr_err("request_irq(%d) = %d\n",
+			       p_fm_drv->err_irq, err);
+			return -EINVAL;
+		}
+	}
+
+	p_fm_drv->res = devm_request_mem_region(p_fm_drv->dev,
+						p_fm_drv->fm_phys_base_addr,
+						p_fm_drv->fm_mem_size, "fman");
+	if (unlikely(!p_fm_drv->res)) {
+		pr_err("request_mem_region() failed\n");
+		return -EINVAL;
+	}
+
+	p_fm_drv->fm_base_addr =
+		PTR_TO_UINT(devm_ioremap(p_fm_drv->dev,
+					 p_fm_drv->fm_phys_base_addr,
+					 p_fm_drv->fm_mem_size));
+	if (unlikely(p_fm_drv->fm_base_addr == 0)) {
+		pr_err("devm_ioremap() failed\n");
+		return -EINVAL;
+	}
+
+	p_fm_drv->params.base_addr = p_fm_drv->fm_base_addr;
+	p_fm_drv->params.fm_id = p_fm_drv->id;
+	p_fm_drv->params.f_exception = fm_drv_exceptions_cb;
+	p_fm_drv->params.f_bus_error = fm_drv_bus_error_cb;
+	p_fm_drv->params.h_app = p_fm_drv;
+
+	return 0;
+}
+
+static int init_fm_dev(struct fm_drv_t *p_fm_drv)
+{
+	const struct qe_firmware *fw;
+
+	if (!p_fm_drv->active) {
+		pr_err("FM not configured!!!\n");
+		return -EINVAL;
+	}
+
+	p_fm_drv->p_muram =
+		fm_muram_init(p_fm_drv->fm_muram_phys_base_addr,
+			      p_fm_drv->fm_muram_mem_size);
+	if (!p_fm_drv->p_muram) {
+		pr_err("FM-MURAM!\n");
+		return -EINVAL;
+	}
+
+	fw = find_fman_microcode();
+
+	if (!fw) {
+		/* this forces the reuse of the current IRAM content */
+		p_fm_drv->params.firmware.size = 0;
+		p_fm_drv->params.firmware.p_code = NULL;
+	} else {
+		p_fm_drv->params.firmware.p_code =
+			(void *)fw + fw->microcode[0].code_offset;
+		p_fm_drv->params.firmware.size =
+			sizeof(u32) * fw->microcode[0].count;
+		pr_debug("Loading fman-controller code version %d.%d.%d\n",
+			 fw->microcode[0].major, fw->microcode[0].minor,
+			 fw->microcode[0].revision);
+	}
+
+	p_fm_drv->params.p_muram = p_fm_drv->p_muram;
+
+	p_fm_drv->h_dev = fm_config(&p_fm_drv->params);
+	if (!p_fm_drv->h_dev) {
+		pr_err("FM\n");
+		return -EINVAL;
+	}
+
+	if (fm_get_revision(p_fm_drv->h_dev, &p_fm_drv->fm_rev_info) != 0) {
+		pr_err("FM\n");
+		return -EINVAL;
+	}
+
+	if (fm_cfg_reset_on_init(p_fm_drv->h_dev, true) != 0) {
+		pr_err("FM\n");
+		return -EINVAL;
+	}
+	/* Config fm_cfg_dma_aid_override for P1023 */
+	if (p_fm_drv->fm_rev_info.major_rev == 4)
+		if (fm_cfg_dma_aid_override(p_fm_drv->h_dev, true) != 0) {
+			pr_err("FM\n");
+			return -EINVAL;
+		}
+	/* Config total fifo size for FManV3H */
+	if ((p_fm_drv->fm_rev_info.major_rev >= 6) &&
+	    (p_fm_drv->fm_rev_info.minor_rev != 1 &&
+	     p_fm_drv->fm_rev_info.minor_rev != 4))
+			fm_cfg_total_fifo_size(p_fm_drv->h_dev, 295 * 1024);
+
+	if (fm_init(p_fm_drv->h_dev) != 0) {
+		pr_err("FM\n");
+		return -EINVAL;
+	}
+
+	/* TODO: Why we mask these interrupts? */
+	if (p_fm_drv->err_irq == 0) {
+		fm_set_exception(p_fm_drv->h_dev,
+				 FM_EX_DMA_BUS_ERROR, false);
+		fm_set_exception(p_fm_drv->h_dev,
+				 FM_EX_DMA_READ_ECC, false);
+		fm_set_exception(p_fm_drv->h_dev,
+				 FM_EX_DMA_SYSTEM_WRITE_ECC, false);
+		fm_set_exception(p_fm_drv->h_dev,
+				 FM_EX_DMA_FM_WRITE_ECC, false);
+		fm_set_exception(p_fm_drv->h_dev,
+				 FM_EX_DMA_SINGLE_PORT_ECC, false);
+		fm_set_exception(p_fm_drv->h_dev,
+				 FM_EX_FPM_STALL_ON_TASKS, false);
+		fm_set_exception(p_fm_drv->h_dev,
+				 FM_EX_FPM_SINGLE_ECC, false);
+		fm_set_exception(p_fm_drv->h_dev,
+				 FM_EX_FPM_DOUBLE_ECC, false);
+		fm_set_exception(p_fm_drv->h_dev,
+				 FM_EX_QMI_SINGLE_ECC, false);
+		fm_set_exception(p_fm_drv->h_dev,
+				 FM_EX_QMI_DOUBLE_ECC, false);
+		fm_set_exception(p_fm_drv->h_dev,
+				 FM_EX_QMI_DEQ_FROM_UNKNOWN_PORTID, false);
+		fm_set_exception(p_fm_drv->h_dev,
+				 FM_EX_BMI_LIST_RAM_ECC, false);
+		fm_set_exception(p_fm_drv->h_dev,
+				 FM_EX_BMI_STORAGE_PROFILE_ECC, false);
+		fm_set_exception(p_fm_drv->h_dev,
+				 FM_EX_BMI_STATISTICS_RAM_ECC, false);
+		fm_set_exception(p_fm_drv->h_dev,
+				 FM_EX_BMI_DISPATCH_RAM_ECC, false);
+		fm_set_exception(p_fm_drv->h_dev, FM_EX_IRAM_ECC,
+				 false);
+		/* TODO: _fm_disable_rams_ecc assert for rams_ecc_owners.
+		 * fm_set_exception(p_fm_drv->h_dev,FM_EX_MURAM_ECC,
+		 *		    false);
+		 */
+	}
+
+	if (unlikely(fill_qman_channhels_info(p_fm_drv) < 0)) {
+		pr_err("can't fill qman channel info\n");
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static void free_fm_dev(struct fm_drv_t *p_fm_drv)
+{
+	if (!p_fm_drv->active)
+		return;
+
+	if (p_fm_drv->h_dev)
+		fm_free(p_fm_drv->h_dev);
+
+	if (p_fm_drv->p_muram)
+		fm_muram_free(p_fm_drv->p_muram);
+
+	devm_iounmap(p_fm_drv->dev,
+		     UINT_TO_PTR(p_fm_drv->fm_base_addr));
+	devm_release_mem_region(p_fm_drv->dev,
+				p_fm_drv->fm_phys_base_addr,
+				p_fm_drv->fm_mem_size);
+
+	if (p_fm_drv->err_irq != 0)
+		devm_free_irq(p_fm_drv->dev, p_fm_drv->err_irq, p_fm_drv);
+
+	devm_free_irq(p_fm_drv->dev, p_fm_drv->irq, p_fm_drv);
+}
+
+/* FMan character device file operations */
+static const struct file_operations fm_fops;
+
+static int /*__devinit*/ fm_probe(struct platform_device *of_dev)
+{
+	struct fm_drv_t *p_fm_drv;
+
+	p_fm_drv = read_fm_dev_tree_node(of_dev);
+	if (!p_fm_drv)
+		return -EIO;
+	if (configure_fm_dev(p_fm_drv) != 0)
+		return -EIO;
+	if (init_fm_dev(p_fm_drv) != 0)
+		return -EIO;
+
+	dev_set_drvdata(p_fm_drv->dev, p_fm_drv);
+
+	pr_debug("FM%d probed\n", p_fm_drv->id);
+
+	return 0;
+}
+
+static int fm_remove(struct platform_device *of_dev)
+{
+	struct fm_drv_t *p_fm_drv;
+	struct device *dev;
+
+	dev = &of_dev->dev;
+	p_fm_drv = dev_get_drvdata(dev);
+
+	free_fm_dev(p_fm_drv);
+
+	destroy_fm_dev(p_fm_drv);
+
+	dev_set_drvdata(dev, NULL);
+
+	return 0;
+}
+
+static const struct of_device_id fm_match[] = {
+	{
+	 .compatible = "fsl,fman"},
+	{}
+};
+
+#ifndef MODULE
+MODULE_DEVICE_TABLE(of, fm_match);
+#endif /* !MODULE */
+
+static struct platform_driver fm_driver = {
+	.driver = {
+		   .name = "fsl-fman",
+		   .of_match_table = fm_match,
+		   },
+	.probe = fm_probe,
+	.remove = fm_remove
+};
+
+void *fm_drv_init(void)
+{
+	memset(&fm_drvs, 0, sizeof(fm_drvs));
+	mutex_init(&fm_drv_mutex);
+
+	/* Register to the DTB for basic FM API */
+	platform_driver_register(&fm_driver);
+
+	return &fm_drvs;
+}
+
+int fm_drv_free(void *p_fm_drv)
+{
+	platform_driver_unregister(&fm_driver);
+	mutex_destroy(&fm_drv_mutex);
+
+	return 0;
+}
+
+struct fm *fm_bind(struct device *fm_dev)
+{
+	return (struct fm *)(dev_get_drvdata(get_device(fm_dev)));
+}
+EXPORT_SYMBOL(fm_bind);
+
+void fm_unbind(struct fm *fm)
+{
+	struct fm_drv_t *p_fm_drv = (struct fm_drv_t *)fm;
+
+	put_device(p_fm_drv->dev);
+}
+EXPORT_SYMBOL(fm_unbind);
+
+struct resource *fm_get_mem_region(struct fm *fm)
+{
+	struct fm_drv_t *p_fm_drv = (struct fm_drv_t *)fm;
+
+	return p_fm_drv->res;
+}
+EXPORT_SYMBOL(fm_get_mem_region);
+
+void *fm_get_handle(struct fm *fm)
+{
+	struct fm_drv_t *p_fm_drv = (struct fm_drv_t *)fm;
+
+	return (void *)p_fm_drv->h_dev;
+}
+EXPORT_SYMBOL(fm_get_handle);
+
+
+void fm_mutex_lock(void)
+{
+	mutex_lock(&fm_drv_mutex);
+}
+EXPORT_SYMBOL(fm_mutex_lock);
+
+void fm_mutex_unlock(void)
+{
+	mutex_unlock(&fm_drv_mutex);
+}
+EXPORT_SYMBOL(fm_mutex_unlock);
+
+static void *p_fm_drv;
+
+static int __init __cold fm_load(void)
+{
+	p_fm_drv = fm_drv_init();
+	if (!p_fm_drv) {
+		pr_err("Failed to init FM wrapper!\n");
+		return -ENODEV;
+	}
+
+	pr_info("Freescale FM module\n");
+	return 0;
+}
+
+static void __exit __cold fm_unload(void)
+{
+	if (p_fm_drv)
+		fm_drv_free(p_fm_drv);
+}
+
+module_init(fm_load);
+module_exit(fm_unload);
diff --git a/drivers/net/ethernet/freescale/fman/fm_drv.h b/drivers/net/ethernet/freescale/fman/fm_drv.h
new file mode 100644
index 0000000..2acd77b
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/fm_drv.h
@@ -0,0 +1,123 @@
+/*
+ * Copyright 2008-2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
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
+#ifndef __FM_DRV_H__
+#define __FM_DRV_H__
+
+#include "service.h"
+#include "fsl_fman_drv.h"
+
+/* FMan Driver Errata */
+#define FM_BCB_ERRATA_BMI_SW001				/* T/B */
+#define FM_TX_INVALID_ECC_ERRATA_10GMAC_A009			/* P2-P5 */
+
+#ifndef CONFIG_FSL_FM_MAX_FRAME_SIZE
+#define CONFIG_FSL_FM_MAX_FRAME_SIZE 0
+#endif
+
+#ifndef CONFIG_FSL_FM_RX_EXTRA_HEADROOM
+#define CONFIG_FSL_FM_RX_EXTRA_HEADROOM       16
+#endif
+
+/* SoC info */
+#define SOC_VERSION(svr)        (((svr) & 0xFFF7FF00) >> 8)
+#define SOC_MAJOR_REV(svr)      (((svr) & 0x000000F0) >> 4)
+#define SOC_MINOR_REV(svr)      ((svr) & 0x0000000F)
+
+/* Port defines */
+#define NUM_OF_FM_PORTS			63
+#define FIRST_OP_PORT(major)		(major >= 6 ? 0x02 : 0x01)
+#define FIRST_RX_PORT			0x08
+#define FIRST_TX_PORT			0x28
+#define LAST_OP_PORT			0x07
+#define LAST_RX_PORT			0x11
+#define LAST_TX_PORT			0x31
+
+#define TX_10G_PORT_BASE		0x30
+#define RX_10G_PORT_BASE		0x10
+
+#define NUM_OF_FMS			2
+struct fm_port_t;
+
+struct fm_port_drv_t {
+	uint8_t id;
+	char name[20];
+	bool active;
+	uint64_t phys_base_addr;
+	uint64_t base_addr;	/* Port's *virtual* address */
+	resource_size_t mem_size;
+	struct fm_buffer_prefix_content_t buff_prefix_content;
+	struct fm_port_t *h_dev;
+	struct fm_drv_t *p_fm;
+	uint16_t tx_ch;
+	struct device *dev;
+	struct fm_revision_info_t fm_rev_info;
+};
+
+struct fm_drv_t {
+	uint8_t id;
+	char name[10];
+	bool active;
+	uint64_t fm_phys_base_addr;
+	uint64_t fm_base_addr;
+	resource_size_t fm_mem_size;
+	phys_addr_t fm_muram_phys_base_addr;
+	uint64_t fm_muram_base_addr;
+	resource_size_t fm_muram_mem_size;
+	int irq;
+	int err_irq;
+	struct fm_params_t params;
+	void *h_dev;
+	struct muram_info *p_muram;
+
+	struct fm_port_drv_t ports[NUM_OF_FM_PORTS];
+
+	struct device *dev;
+	struct resource *res;
+
+	struct fm_revision_info_t fm_rev_info;
+	uint32_t qman_channel_base;
+	uint32_t num_of_qman_channels;
+	uint32_t *qman_channels;
+
+};
+
+struct fm_drvs_t {
+	struct fm_drv_t *p_fm_devs[NUM_OF_FMS];
+};
+
+uint32_t get_qman_channel_id(struct fm_drv_t *p_fm_dr,
+			     uint32_t port_id,
+			     enum fm_port_type port_type,
+			     enum fm_port_speed port_speed);
+
+#endif /* __FM_DRV_H__ */
diff --git a/drivers/net/ethernet/freescale/fman/inc/enet_ext.h b/drivers/net/ethernet/freescale/fman/inc/enet_ext.h
new file mode 100644
index 0000000..cfade84
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/inc/enet_ext.h
@@ -0,0 +1,199 @@
+/*
+ * Copyright 2008-2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
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
+/* Ethernet generic definitions and enums. */
+
+#ifndef __ENET_EXT_H
+#define __ENET_EXT_H
+
+#include "fsl_enet.h"
+
+/* Number of octets (8-bit bytes) in an ethernet address */
+#define ENET_NUM_OCTETS_PER_ADDRESS 6
+/* Group address mask for ethernet addresses */
+#define ENET_GROUP_ADDR	    0x01
+
+/* Ethernet Address */
+typedef uint8_t enet_addr_t[ENET_NUM_OCTETS_PER_ADDRESS];
+
+/* Ethernet MAC-PHY Interface */
+enum ethernet_interface {
+	ENET_IF_MII = E_ENET_IF_MII,	 /* MII interface */
+	ENET_IF_RMII = E_ENET_IF_RMII, /* RMII interface */
+	ENET_IF_SMII = E_ENET_IF_SMII, /* SMII interface */
+	ENET_IF_GMII = E_ENET_IF_GMII, /* GMII interface */
+	ENET_IF_RGMII = E_ENET_IF_RGMII,
+					 /* RGMII interface */
+	ENET_IF_TBI = E_ENET_IF_TBI,	 /* TBI interface */
+	ENET_IF_RTBI = E_ENET_IF_RTBI, /* RTBI interface */
+	ENET_IF_SGMII = E_ENET_IF_SGMII,
+					 /* SGMII interface */
+	ENET_IF_XGMII = E_ENET_IF_XGMII,
+					 /* XGMII interface */
+	ENET_IF_QSGMII = E_ENET_IF_QSGMII,
+					 /* QSGMII interface */
+	ENET_IF_XFI = E_ENET_IF_XFI	 /* XFI interface */
+};
+
+/* SGMII/QSGII interface with 1000BaseX auto-negotiation between MAC and phy
+ * or backplane; Note: 1000BaseX auto-negotiation relates only to interface
+ * between MAC and phy/backplane, SGMII phy can still synchronize with far-end
+ * phy at 10Mbps, 100Mbps or 1000Mbps
+ */
+#define ENET_IF_SGMII_BASEX       0x80000000
+
+/* Ethernet Speed (nominal data rate) */
+enum ethernet_speed {
+	ENET_SPEED_10 = E_ENET_SPEED_10,	 /* 10 Mbps */
+	ENET_SPEED_100 = E_ENET_SPEED_100,	 /* 100 Mbps */
+	ENET_SPEED_1000 = E_ENET_SPEED_1000,	 /* 1000 Mbps = 1 Gbps */
+	ENET_SPEED_10000 = E_ENET_SPEED_10000	 /* 10000 Mbps = 10 Gbps */
+};
+
+/* Ethernet mode (combination of MAC-PHY interface and speed) */
+enum e_enet_mode {
+	ENET_MODE_INVALID = 0,	/* Invalid Ethernet mode */
+	/*    10 Mbps MII   */
+	ENET_MODE_MII_10 = (ENET_IF_MII | ENET_SPEED_10),
+	/*   100 Mbps MII   */
+	ENET_MODE_MII_100 = (ENET_IF_MII | ENET_SPEED_100),
+	/*    10 Mbps RMII  */
+	ENET_MODE_RMII_10 = (ENET_IF_RMII | ENET_SPEED_10),
+	/*   100 Mbps RMII  */
+	ENET_MODE_RMII_100 = (ENET_IF_RMII | ENET_SPEED_100),
+	/*    10 Mbps SMII  */
+	ENET_MODE_SMII_10 = (ENET_IF_SMII | ENET_SPEED_10),
+	/*   100 Mbps SMII  */
+	ENET_MODE_SMII_100 = (ENET_IF_SMII | ENET_SPEED_100),
+	/*  1000 Mbps GMII  */
+	ENET_MODE_GMII_1000 = (ENET_IF_GMII | ENET_SPEED_1000),
+	/*    10 Mbps RGMII */
+	ENET_MODE_RGMII_10 = (ENET_IF_RGMII | ENET_SPEED_10),
+	/*   100 Mbps RGMII */
+	ENET_MODE_RGMII_100 = (ENET_IF_RGMII | ENET_SPEED_100),
+	/*  1000 Mbps RGMII */
+	ENET_MODE_RGMII_1000 = (ENET_IF_RGMII | ENET_SPEED_1000),
+	/*  1000 Mbps TBI   */
+	ENET_MODE_TBI_1000 = (ENET_IF_TBI | ENET_SPEED_1000),
+	/*  1000 Mbps RTBI  */
+	ENET_MODE_RTBI_1000 = (ENET_IF_RTBI | ENET_SPEED_1000),
+	/* 10 Mbps SGMII with auto-negotiation between MAC and
+	 * SGMII phy according to Cisco SGMII specification
+	 */
+	ENET_MODE_SGMII_10 = (ENET_IF_SGMII | ENET_SPEED_10),
+	/* 100 Mbps SGMII with auto-negotiation between MAC and
+	 * SGMII phy according to Cisco SGMII specification
+	 */
+	ENET_MODE_SGMII_100 = (ENET_IF_SGMII | ENET_SPEED_100),
+	/* 1000 Mbps SGMII with auto-negotiation between MAC and
+	 * SGMII phy according to Cisco SGMII specification
+	 */
+	ENET_MODE_SGMII_1000 = (ENET_IF_SGMII | ENET_SPEED_1000),
+	/* 10 Mbps SGMII with 1000BaseX auto-negotiation between
+	 * MAC and SGMII phy or backplane
+	 */
+	ENET_MODE_SGMII_BASEX_10 =
+	    (ENET_IF_SGMII_BASEX | ENET_IF_SGMII | ENET_SPEED_10),
+	/* 100 Mbps SGMII with 1000BaseX auto-negotiation between
+	 * MAC and SGMII phy or backplane
+	 */
+	ENET_MODE_SGMII_BASEX_100 =
+	    (ENET_IF_SGMII_BASEX | ENET_IF_SGMII | ENET_SPEED_100),
+	/* 1000 Mbps SGMII with 1000BaseX auto-negotiation between
+	 * MAC and SGMII phy or backplane
+	 */
+	ENET_MODE_SGMII_BASEX_1000 =
+	    (ENET_IF_SGMII_BASEX | ENET_IF_SGMII | ENET_SPEED_1000),
+	/* 1000 Mbps QSGMII with auto-negotiation between MAC and
+	 * QSGMII phy according to Cisco QSGMII specification
+	 */
+	ENET_MODE_QSGMII_1000 = (ENET_IF_QSGMII | ENET_SPEED_1000),
+	/* 1000 Mbps QSGMII with 1000BaseX auto-negotiation between
+	 * MAC and QSGMII phy or backplane
+	 */
+	ENET_MODE_QSGMII_BASEX_1000 =
+	    (ENET_IF_SGMII_BASEX | ENET_IF_QSGMII | ENET_SPEED_1000),
+	/* 10000 Mbps XGMII */
+	ENET_MODE_XGMII_10000 = (ENET_IF_XGMII | ENET_SPEED_10000),
+	/* 10000 Mbps XFI */
+	ENET_MODE_XFI_10000 = (ENET_IF_XFI | ENET_SPEED_10000)
+};
+
+#define IS_ENET_MODE_VALID(mode)			\
+	(((mode) == ENET_MODE_MII_10) ||		\
+	((mode) == ENET_MODE_MII_100) ||		\
+	((mode) == ENET_MODE_RMII_10) ||		\
+	((mode) == ENET_MODE_RMII_100) ||		\
+	((mode) == ENET_MODE_SMII_10) ||		\
+	((mode) == ENET_MODE_SMII_100) ||		\
+	((mode) == ENET_MODE_GMII_1000) ||		\
+	((mode) == ENET_MODE_RGMII_10) ||		\
+	((mode) == ENET_MODE_RGMII_100) ||		\
+	((mode) == ENET_MODE_RGMII_1000) ||		\
+	((mode) == ENET_MODE_TBI_1000) ||		\
+	((mode) == ENET_MODE_RTBI_1000) ||		\
+	((mode) == ENET_MODE_SGMII_10) ||		\
+	((mode) == ENET_MODE_SGMII_100) ||		\
+	((mode) == ENET_MODE_SGMII_1000) ||		\
+	((mode) == ENET_MODE_SGMII_BASEX_10) ||	\
+	((mode) == ENET_MODE_SGMII_BASEX_100) ||	\
+	((mode) == ENET_MODE_SGMII_BASEX_1000) ||	\
+	((mode) == ENET_MODE_XGMII_10000) ||		\
+	((mode) == ENET_MODE_QSGMII_1000) ||		\
+	((mode) == ENET_MODE_QSGMII_BASEX_1000) ||	\
+	((mode) == ENET_MODE_XFI_10000))
+
+#define MAKE_ENET_MODE(_interface, _speed) \
+		      (enum e_enet_mode)((_interface) | (_speed))
+
+#define ENET_INTERFACE_FROM_MODE(mode) \
+				(enum ethernet_interface)((mode) & 0x0FFF0000)
+#define ENET_SPEED_FROM_MODE(mode) \
+			    (enum ethernet_speed)((mode) & 0x0000FFFF)
+
+#define ENET_ADDR_TO_UINT64(_enet_addr)		  \
+	(uint64_t)(((uint64_t)(_enet_addr)[0] << 40) |   \
+		   ((uint64_t)(_enet_addr)[1] << 32) |   \
+		   ((uint64_t)(_enet_addr)[2] << 24) |   \
+		   ((uint64_t)(_enet_addr)[3] << 16) |   \
+		   ((uint64_t)(_enet_addr)[4] << 8) |    \
+		   ((uint64_t)(_enet_addr)[5]))
+
+#define MAKE_ENET_ADDR_FROM_UINT64(_addr64, _enet_addr) \
+	do { \
+		int i; \
+		for (i = 0; i < ENET_NUM_OCTETS_PER_ADDRESS; i++) \
+			(_enet_addr)[i] = \
+			(uint8_t)((_addr64) >> ((5 - i) * 8)); \
+	} while (0)
+
+#endif /* __ENET_EXT_H */
diff --git a/drivers/net/ethernet/freescale/fman/inc/fm_ext.h b/drivers/net/ethernet/freescale/fman/inc/fm_ext.h
new file mode 100644
index 0000000..bc5d964
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/inc/fm_ext.h
@@ -0,0 +1,453 @@
+/*
+ * Copyright 2008-2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
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
+/* FM Application Programming Interface. */
+#ifndef __FM_EXT
+#define __FM_EXT
+
+#include "service.h"
+#include "fsl_fman_sp.h"
+
+/* Enum for defining port types */
+enum fm_port_type {
+	FM_PORT_TYPE_OP = 0,	/* OP Port */
+	FM_PORT_TYPE_TX,	/* TX Port */
+	FM_PORT_TYPE_RX,	/* RX Port */
+	FM_PORT_TYPE_DUMMY
+};
+
+/* Enum for defining port speed */
+enum fm_port_speed {
+	FM_PORT_SPEED_1G = 0,		/* 1G port */
+	FM_PORT_SPEED_10G,		/* 10G port */
+	FM_PORT_SPEED_OP
+};
+
+/* BMan defines */
+#define BM_MAX_NUM_OF_POOLS		64 /* Buffers pools */
+#define FM_PORT_MAX_NUM_OF_EXT_POOLS	8  /* External BM pools per Rx port */
+
+/* General FM defines */
+#define FM_MAX_NUM_OF_PARTITIONS    64	 /* Maximum number of partitions */
+
+/* FM Frame descriptor macros  */
+/* Frame queue Context Override */
+#define FM_FD_CMD_FCO                   0x80000000
+#define FM_FD_CMD_RPD                   0x40000000  /* Read Prepended Data */
+#define FM_FD_CMD_DTC                   0x10000000  /* Do L4 Checksum */
+
+/* Not for Rx-Port! Unsupported Format */
+#define FM_FD_ERR_UNSUPPORTED_FORMAT    0x04000000
+/* Not for Rx-Port! Length Error */
+#define FM_FD_ERR_LENGTH                0x02000000
+#define FM_FD_ERR_DMA                   0x01000000  /* DMA Data error */
+
+/* IPR frame (not error) */
+#define FM_FD_IPR                       0x00000001
+/* IPR non-consistent-sp */
+#define FM_FD_ERR_IPR_NCSP              (0x00100000 | FM_FD_IPR)
+/* IPR error */
+#define FM_FD_ERR_IPR                   (0x00200000 | FM_FD_IPR)
+/* IPR timeout */
+#define FM_FD_ERR_IPR_TO                (0x00300000 | FM_FD_IPR)
+
+/* Rx FIFO overflow, FCS error, code error, running disparity error
+ * (SGMII and TBI modes), FIFO parity error. PHY Sequence error,
+ * PHY error control character detected.
+ */
+#define FM_FD_ERR_PHYSICAL              0x00080000
+/* Frame too long OR Frame size exceeds max_length_frame  */
+#define FM_FD_ERR_SIZE                  0x00040000
+/* classification discard */
+#define FM_FD_ERR_CLS_DISCARD           0x00020000
+/* Extract Out of Frame */
+#define FM_FD_ERR_EXTRACTION            0x00008000
+/* No Scheme Selected */
+#define FM_FD_ERR_NO_SCHEME             0x00004000
+/* Keysize Overflow */
+#define FM_FD_ERR_KEYSIZE_OVERFLOW      0x00002000
+/* Frame color is red */
+#define FM_FD_ERR_COLOR_RED             0x00000800
+/* Frame color is yellow */
+#define FM_FD_ERR_COLOR_YELLOW          0x00000400
+/* Parser Time out Exceed */
+#define FM_FD_ERR_PRS_TIMEOUT           0x00000080
+/* Invalid Soft Parser instruction */
+#define FM_FD_ERR_PRS_ILL_INSTRUCT      0x00000040
+/* Header error was identified during parsing */
+#define FM_FD_ERR_PRS_HDR_ERR           0x00000020
+/* Frame parsed beyind 256 first bytes */
+#define FM_FD_ERR_BLOCK_LIMIT_EXCEEDED  0x00000008
+
+/* non Frame-Manager error */
+#define FM_FD_RX_STATUS_ERR_NON_FM      0x00400000
+
+/* FM physical Address */
+struct fm_phys_addr_t {
+	uint8_t high;	      /* High part of the physical address */
+	uint32_t low;	      /* Low part of the physical address */
+} __attribute__((__packed__));
+
+/* Parse results memory layout */
+struct fm_prs_result_t {
+	 uint8_t lpid;		     /* Logical port id */
+	 uint8_t shimr;		     /* Shim header result  */
+	 uint16_t l2r;		     /* Layer 2 result */
+	 uint16_t l3r;		     /* Layer 3 result */
+	 uint8_t l4r;		     /* Layer 4 result */
+	 uint8_t cplan;		     /* Classification plan id */
+	 uint16_t nxthdr;	     /* Next Header  */
+	 uint16_t cksum;	     /* Running-sum */
+	/* Flags&fragment-offset field of the last IP-header */
+	 uint16_t flags_frag_off;
+	/* Routing type field of a IPV6 routing extension header */
+	 uint8_t route_type;
+	/* Routing Extension Header Present; last bit is IP valid */
+	 uint8_t rhp_ip_valid;
+	 uint8_t shim_off[2];	     /* Shim offset */
+	/* IP PID (last IP-proto) offset */
+	 uint8_t ip_pid_off;
+	 uint8_t eth_off;	     /* ETH offset */
+	 uint8_t llc_snap_off;	     /* LLC_SNAP offset */
+	 uint8_t vlan_off[2];	     /* VLAN offset */
+	 uint8_t etype_off;	     /* ETYPE offset */
+	 uint8_t pppoe_off;	     /* PPP offset */
+	 uint8_t mpls_off[2];	     /* MPLS offset */
+	 uint8_t ip_off[2];	     /* IP offset */
+	 uint8_t gre_off;	     /* GRE offset */
+	 uint8_t l4_off;	     /* Layer 4 offset */
+	 uint8_t nxthdr_off;	     /* Parser end point */
+} __attribute__((__packed__));
+
+/* @} */
+
+/* FM Exceptions */
+enum fm_exceptions {
+	FM_EX_DMA_BUS_ERROR = 0,	/* DMA bus error. */
+	/* Read Buffer ECC error (Valid for FM rev < 6)*/
+	FM_EX_DMA_READ_ECC,
+	/* Write Buffer ECC error on system side (Valid for FM rev < 6)*/
+	FM_EX_DMA_SYSTEM_WRITE_ECC,
+	/* Write Buffer ECC error on FM side (Valid for FM rev < 6)*/
+	FM_EX_DMA_FM_WRITE_ECC,
+	/* Single Port ECC error on FM side (Valid for FM rev > 6)*/
+	FM_EX_DMA_SINGLE_PORT_ECC,
+	FM_EX_FPM_STALL_ON_TASKS,	/* Stall of tasks on FPM */
+	FM_EX_FPM_SINGLE_ECC,		/* Single ECC on FPM. */
+	/* Double ECC error on FPM ram access */
+	FM_EX_FPM_DOUBLE_ECC,
+	FM_EX_QMI_SINGLE_ECC,		/* Single ECC on QMI. */
+	FM_EX_QMI_DOUBLE_ECC,		/* Double bit ECC occurred on QMI */
+	FM_EX_QMI_DEQ_FROM_UNKNOWN_PORTID,
+					/* Dequeue from unknown port id */
+	FM_EX_BMI_LIST_RAM_ECC,	/* Linked List RAM ECC error */
+	FM_EX_BMI_STORAGE_PROFILE_ECC,/* Storage Profile ECC Error */
+	/* Statistics Count RAM ECC Error Enable */
+	FM_EX_BMI_STATISTICS_RAM_ECC,
+	FM_EX_BMI_DISPATCH_RAM_ECC,	/* Dispatch RAM ECC Error Enable */
+	FM_EX_IRAM_ECC,		/* Double bit ECC occurred on IRAM*/
+	FM_EX_MURAM_ECC		/* Double bit ECC occurred on MURAM*/
+};
+
+/*  fm_exceptions_cb
+ *   Exceptions user callback routine, will be called upon an
+ *		exception passing the exception identification.
+ *   h_app      - User's application descriptor.
+ *   exception  - The exception.
+ */
+typedef void (fm_exceptions_cb) (void *h_app,
+				 enum fm_exceptions exception);
+
+/*  fm_bus_error_cb
+ *   Bus error user callback routine, will be called upon a
+ *		bus error, passing parameters describing the errors and
+ *		the owner.
+ *   h_app       - User's application descriptor.
+ *   port_type    - Port type (enum fm_port_type)
+ *   port_id      - Port id - relative to type.
+ *   addr        - Address that caused the error
+ *   tnum        - Owner of error
+ *   liodn       - Logical IO device number
+ */
+typedef void (fm_bus_error_cb) (void *h_app,
+				enum fm_port_type port_type,
+				uint8_t port_id,
+				uint64_t addr,
+				uint8_t tnum, uint16_t liodn);
+
+/* A structure for defining buffer prefix area content. */
+struct fm_buffer_prefix_content_t {
+	/* Number of bytes to be left at the beginning of the external
+	 * buffer; Note that the private-area will start from the base
+	 * of the buffer address.
+	 */
+	uint16_t priv_data_size;
+	/* true to pass the parse result to/from the FM;
+	 * User may use FM_PORT_GetBufferPrsResult() in
+	 * order to get the parser-result from a buffer.
+	 */
+	bool pass_prs_result;
+	/* true to pass the timeStamp to/from the FM User may use
+	 * fm_port_get_buffer_time_stamp() in order to get the
+	 * parser-result from a buffer.
+	 */
+	bool pass_time_stamp;
+	/* true to pass the KG hash result to/from the FM User may
+	 * use FM_PORT_GetBufferHashResult() in order to get the
+	 * parser-result from a buffer.
+	 */
+	bool pass_hash_result;
+	/* Add all other Internal-Context information: AD,
+	 * hash-result, key, etc.
+	 */
+	uint16_t data_align;
+};
+
+/* A structure of information about each of the external
+ * buffer pools used by a port or storage-profile.
+ */
+struct fm_ext_pool_params_t {
+	uint8_t id;		    /* External buffer pool id */
+	uint16_t size;		    /* External buffer pool buffer size */
+};
+
+/* A structure for informing the driver about the external
+ * buffer pools allocated in the BM and used by a port or a
+ * storage-profile.
+ */
+struct fm_ext_pools_t {
+	uint8_t num_of_pools_used; /* Number of pools use by this port */
+	struct fm_ext_pool_params_t ext_buf_pool[FM_PORT_MAX_NUM_OF_EXT_POOLS];
+					/* Parameters for each port */
+};
+
+/* A structure for defining backup BM Pools. */
+struct fm_backup_bm_pools_t {
+	/* Number of BM backup pools -  must be smaller
+	 * than the total number of pools defined for the specified port.
+	 */
+	uint8_t num_of_backup_pools;
+	/* num_of_backup_pools pool id's, specifying which pools should
+	 * be used only as backup. Pool id's specified here must be a
+	 * subset of the pools used by the specified port.
+	 */
+	uint8_t pool_ids[FM_PORT_MAX_NUM_OF_EXT_POOLS];
+};
+
+/* A structure for defining BM pool depletion criteria */
+struct fm_buf_pool_depletion_t {
+	/* select mode in which pause frames will be sent after a
+	 * number of pools (all together!) are depleted
+	 */
+	bool pools_grp_mode_enable;
+	/* the number of depleted pools that will invoke pause
+	 * frames transmission.
+	 */
+	uint8_t num_of_pools;
+	/* For each pool, true if it should be considered for
+	 * depletion (Note - this pool must be used by this port!).
+	 */
+	bool pools_to_consider[BM_MAX_NUM_OF_POOLS];
+	/* select mode in which pause frames will be sent
+	 * after a single-pool is depleted;
+	 */
+	bool single_pool_mode_enable;
+	/* For each pool, true if it should be considered
+	 * for depletion (Note - this pool must be used by this port!)
+	 */
+	bool pools_to_consider_for_single_mode[BM_MAX_NUM_OF_POOLS];
+};
+
+/* A Structure for defining Ucode patch for loading. */
+struct fm_firmware_params_t {
+	uint32_t size;			/* Size of uCode */
+	uint32_t *p_code;		/* A pointer to the uCode */
+};
+
+/* A Structure for defining FM initialization parameters */
+struct fm_params_t {
+	uint8_t fm_id;
+	/* Index of the FM */
+	uintptr_t base_addr;
+	/* A pointer to base of memory mapped FM registers (virtual);
+	 * NOTE that this should include ALL common registers of the FM
+	 * including the PCD registers area.
+	 */
+	struct muram_info *p_muram;
+	/* A pointer to an initialized MURAM object, to be used by the FM. */
+	uint16_t fm_clk_freq;
+	/* In Mhz; */
+	fm_exceptions_cb *f_exception;
+	/* An application callback routine to handle exceptions; */
+	fm_bus_error_cb *f_bus_error;
+	/* An application callback routine to handle exceptions; */
+	void *h_app;
+	/* A handle to an application layer object; This handle will be
+	 * passed by the driver upon calling the above callbacks;
+	 */
+	struct fm_firmware_params_t firmware;
+	/* The firmware parameters structure; */
+};
+
+struct fm_t; /* FMan data */
+
+/* fm_config
+ * Creates the FM module and returns its handle (descriptor).
+ * This descriptor must be passed as first parameter to all other
+ * FM function calls.
+ * No actual initialization or configuration of FM hardware is
+ * done by this routine. All FM parameters get default values that
+ * may be changed by calling one or more of the advance config
+ * routines.
+ * p_fm_params		A pointer to a data structure of mandatory FM
+ *			parameters
+ * Return		A handle to the FM object, or NULL for Failure.
+ */
+void *fm_config(struct fm_params_t *p_fm_params);
+
+/* fm_init
+ * Initializes the FM module by defining the software structure
+ * and configuring the hardware registers.
+ * p_fm		Pointer to the FMan module
+ * Return	0 on success; Error code otherwise.
+ */
+int fm_init(struct fm_t *p_fm);
+
+/* fm_free
+ * Frees all resources that were assigned to FM module.
+ * Calling this routine invalidates the descriptor.
+ * p_fm		Pointer to the FMan module
+ * Return	0 on success; Error code otherwise.
+ */
+int fm_free(struct fm_t *p_fm);
+
+/* Enum for choosing the field that will be output on AID */
+enum fm_dma_aid_mode {
+	FM_DMA_AID_OUT_PORT_ID = 0,	    /* 4 LSB of PORT_ID */
+	FM_DMA_AID_OUT_TNUM		    /* 4 LSB of TNUM */
+};
+
+/* Enum for selecting DMA Emergency options */
+/* Enable emergency for MURAM1 */
+#define  FM_DMA_MURAM_READ_EMERGENCY        0x00800000
+/* Enable emergency for MURAM2 */
+#define  FM_DMA_MURAM_WRITE_EMERGENCY       0x00400000
+/* Enable emergency for external bus */
+#define  FM_DMA_EXT_BUS_EMERGENCY           0x00100000
+
+/* fm_cfg_reset_on_init
+ * Define whether to reset the FM before initialization.
+ * Change the default configuration [DEFAULT_RESET_ON_INIT].
+ * p_fm		Pointer to the FMan module
+ * enable	When true, FM will be reset before any
+ * Return	0 on success; Error code otherwise.
+ * Allowed only following fm_config() and before fm_init().
+ */
+int fm_cfg_reset_on_init(struct fm_t *p_fm, bool enable);
+
+/* fm_cfg_total_fifo_size
+ * Define Total FIFO size for the whole FM.
+ * Calling this routine changes the total Fifo size in the internal driver
+ * data base from its default configuration [DEFAULT_total_fifo_size]
+ * p_fm			Pointer to the FMan module
+ * total_fifo_size	The selected new value.
+ * Return	 0 on success; Error code otherwise.
+ * Allowed only following fm_config() and before fm_init().
+ */
+int fm_cfg_total_fifo_size(struct fm_t *p_fm, uint32_t total_fifo_size);
+
+/* fm_cfg_dma_aid_override
+ * Define DMA AID OVERRIDE_MODE.
+ * Calling this routine changes the AID override mode in the internal driver
+ * data base from its default configuration  [DEFAULT_aid_override]
+ * p_fm			Pointer to the FMan module
+ * aid_override		The selected new value.
+ * Return	0 on success; Error code otherwise.
+ * Allowed only following fm_config() and before fm_init().
+ */
+int fm_cfg_dma_aid_override(struct fm_t *p_fm, bool aid_override);
+
+/* A Structure for returning FM revision information */
+struct fm_revision_info_t {
+	uint8_t major_rev;		    /* Major revision */
+	uint8_t minor_rev;		    /* Minor revision */
+};
+
+/* fm_set_exception
+ * Calling this routine enables/disables the specified exception.
+ * p_fm		Pointer to the FMan module
+ * exception	The exception to be selected.
+ * enable	True to enable interrupt, false to mask it.
+ * Return	0 on success; Error code otherwise.
+ * Allowed only following fm_init().
+ */
+int fm_set_exception(struct fm_t *p_fm, enum fm_exceptions exception,
+		     bool enable);
+
+/* fm_disable_rams_ecc
+ * Disables ECC mechanism for all the different FM RAM's; E.g. IRAM,
+ * MURAM, etc. Note:
+ *	In opposed to fm_enable_rams_ecc, this routine must be called
+ *	explicitly to disable all Rams ECC.
+ * p_fm		Pointer to the FMan module
+ * Return	0 on success; Error code otherwise.
+ * Allowed only following fm_config() and before fm_init().
+ */
+int fm_disable_rams_ecc(struct fm_t *p_fm);
+
+/* fm_get_revision
+ * Returns the FM revision
+ * p_fm			- Pointer to the FMan module
+ * p_fm_revision_info	- A structure of revision information parameters.
+ * Return	0 on success; Error code otherwise.
+ * Allowed only following fm_init().
+ */
+int fm_get_revision(struct fm_t *p_fm,
+		    struct fm_revision_info_t *p_fm_revision_info);
+
+/* fm_error_isr
+ * FM interrupt-service-routine for errors.
+ * p_fm		Pointer to the FMan module
+ * Return	0 on success; EMPTY if no errors found in register, other
+ *		error code otherwise.
+ * Allowed only following fm_init().
+ */
+int fm_error_isr(struct fm_t *p_fm);
+
+/* fm_event_isr
+ * FM interrupt-service-routine for normal events.
+ * p_fm		Pointer to the FMan module
+ * Allowed only following fm_init().
+ */
+void fm_event_isr(struct fm_t *p_fm);
+
+#endif /* __FM_EXT */
diff --git a/drivers/net/ethernet/freescale/fman/inc/fsl_fman_drv.h b/drivers/net/ethernet/freescale/fman/inc/fsl_fman_drv.h
new file mode 100644
index 0000000..cfbf462
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/inc/fsl_fman_drv.h
@@ -0,0 +1,94 @@
+/*
+ * Copyright 2008-2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
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
+/* Linux internal kernel API */
+
+#ifndef __FSL_FMAN_DRV_H
+#define __FSL_FMAN_DRV_H
+
+#include <linux/types.h>
+#include <linux/device.h>	/* struct device */
+
+/* FM device opaque structure used for type checking */
+struct fm;
+
+/* fm_bind
+ *	Bind to a specific FM device.
+ *
+ * fm_dev	- the OF handle of the FM device.
+ *  Return	A handle of the FM device.
+ *  Allowed only after the port was created.
+ */
+struct fm *fm_bind(struct device *fm_dev);
+
+/* fm_unbind
+ * Un-bind from a specific FM device.
+ *  fm	- A handle of the FM device.
+ *  Allowed only after the port was created.
+ */
+void fm_unbind(struct fm *fm);
+
+void *fm_get_handle(struct fm *fm);
+struct resource *fm_get_mem_region(struct fm *fm);
+
+/*	fm_mutex_lock
+ *
+ *   Lock function required before any FMD/LLD call.
+ */
+void fm_mutex_lock(void);
+
+/*	fm_mutex_unlock
+ *
+ *   Unlock function required after any FMD/LLD call.
+ */
+void fm_mutex_unlock(void);
+
+/*	fm_get_max_frm
+ *
+ *   Get the maximum frame size
+ */
+u16 fm_get_max_frm(void);
+
+/*	fm_get_rx_extra_headroom
+ *
+ *   Get the extra headroom size
+ */
+int fm_get_rx_extra_headroom(void);
+
+/* default values for initializing PTP 1588 timer clock */
+/* power of 2 for better performance */
+#define DPA_PTP_NOMINAL_FREQ_PERIOD_SHIFT 2
+/* 4ns,250MHz */
+#define DPA_PTP_NOMINAL_FREQ_PERIOD_NS \
+(1 << DPA_PTP_NOMINAL_FREQ_PERIOD_SHIFT)
+
+#endif /* __FSL_FMAN_DRV_H */
diff --git a/drivers/net/ethernet/freescale/fman/inc/net_ext.h b/drivers/net/ethernet/freescale/fman/inc/net_ext.h
new file mode 100644
index 0000000..a05ace0
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/inc/net_ext.h
@@ -0,0 +1,534 @@
+/*
+ * Copyright 2008-2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
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
+/* net_ext.h
+ * This file contains common and general headers definitions.
+ */
+#ifndef __NET_EXT_H
+#define __NET_EXT_H
+
+#define NET_HEADER_FIELD_PPP_PID                        (1)
+#define NET_HEADER_FIELD_PPP_COMPRESSED \
+(NET_HEADER_FIELD_PPP_PID << 1)
+#define NET_HEADER_FIELD_PPP_ALL_FIELDS \
+((NET_HEADER_FIELD_PPP_PID << 2) - 1)
+
+#define NET_HEADER_FIELD_PPPOE_VER                      (1)
+#define NET_HEADER_FIELD_PPPOE_TYPE \
+(NET_HEADER_FIELD_PPPOE_VER << 1)
+#define NET_HEADER_FIELD_PPPOE_CODE \
+(NET_HEADER_FIELD_PPPOE_VER << 2)
+#define NET_HEADER_FIELD_PPPOE_SID \
+(NET_HEADER_FIELD_PPPOE_VER << 3)
+#define NET_HEADER_FIELD_PPPOE_LEN \
+(NET_HEADER_FIELD_PPPOE_VER << 4)
+#define NET_HEADER_FIELD_PPPOE_SESSION \
+(NET_HEADER_FIELD_PPPOE_VER << 5)
+#define NET_HEADER_FIELD_PPPOE_PID \
+(NET_HEADER_FIELD_PPPOE_VER << 6)
+#define NET_HEADER_FIELD_PPPOE_ALL_FIELDS \
+((NET_HEADER_FIELD_PPPOE_VER << 7) - 1)
+
+#define NET_HEADER_FIELD_PPPMUX_PID                     (1)
+#define NET_HEADER_FIELD_PPPMUX_CKSUM \
+(NET_HEADER_FIELD_PPPMUX_PID << 1)
+#define NET_HEADER_FIELD_PPPMUX_COMPRESSED \
+(NET_HEADER_FIELD_PPPMUX_PID << 2)
+#define NET_HEADER_FIELD_PPPMUX_ALL_FIELDS \
+((NET_HEADER_FIELD_PPPMUX_PID << 3) - 1)
+
+#define NET_HEADER_FIELD_PPPMUX_SUBFRAME_PFF            (1)
+#define NET_HEADER_FIELD_PPPMUX_SUBFRAME_LXT \
+(NET_HEADER_FIELD_PPPMUX_SUBFRAME_PFF << 1)
+#define NET_HEADER_FIELD_PPPMUX_SUBFRAME_LEN \
+(NET_HEADER_FIELD_PPPMUX_SUBFRAME_PFF << 2)
+#define NET_HEADER_FIELD_PPPMUX_SUBFRAME_PID \
+(NET_HEADER_FIELD_PPPMUX_SUBFRAME_PFF << 3)
+#define NET_HEADER_FIELD_PPPMUX_SUBFRAME_USE_PID \
+(NET_HEADER_FIELD_PPPMUX_SUBFRAME_PFF << 4)
+#define NET_HEADER_FIELD_PPPMUX_SUBFRAME_ALL_FIELDS \
+((NET_HEADER_FIELD_PPPMUX_SUBFRAME_PFF << 5) - 1)
+
+#define NET_HEADER_FIELD_ETH_DA                         (1)
+#define NET_HEADER_FIELD_ETH_SA \
+(NET_HEADER_FIELD_ETH_DA << 1)
+#define NET_HEADER_FIELD_ETH_LENGTH \
+(NET_HEADER_FIELD_ETH_DA << 2)
+#define NET_HEADER_FIELD_ETH_TYPE \
+(NET_HEADER_FIELD_ETH_DA << 3)
+#define NET_HEADER_FIELD_ETH_FINAL_CKSUM \
+(NET_HEADER_FIELD_ETH_DA << 4)
+#define NET_HEADER_FIELD_ETH_PADDING \
+(NET_HEADER_FIELD_ETH_DA << 5)
+#define NET_HEADER_FIELD_ETH_ALL_FIELDS \
+((NET_HEADER_FIELD_ETH_DA << 6) - 1)
+
+#define NET_HEADER_FIELD_ETH_ADDR_SIZE                 6
+
+#define NET_HEADER_FIELD_IP_VER                         (1)
+#define NET_HEADER_FIELD_IP_DSCP \
+(NET_HEADER_FIELD_IP_VER << 2)
+#define NET_HEADER_FIELD_IP_ECN \
+(NET_HEADER_FIELD_IP_VER << 3)
+#define NET_HEADER_FIELD_IP_PROTO \
+(NET_HEADER_FIELD_IP_VER << 4)
+
+#define NET_HEADER_FIELD_IP_PROTO_SIZE                  1
+
+#define NET_HEADER_FIELD_IPV4_VER                       (1)
+#define NET_HEADER_FIELD_IPV4_HDR_LEN \
+(NET_HEADER_FIELD_IPV4_VER << 1)
+#define NET_HEADER_FIELD_IPV4_TOS \
+(NET_HEADER_FIELD_IPV4_VER << 2)
+#define NET_HEADER_FIELD_IPV4_TOTAL_LEN \
+(NET_HEADER_FIELD_IPV4_VER << 3)
+#define NET_HEADER_FIELD_IPV4_ID \
+(NET_HEADER_FIELD_IPV4_VER << 4)
+#define NET_HEADER_FIELD_IPV4_FLAG_D \
+(NET_HEADER_FIELD_IPV4_VER << 5)
+#define NET_HEADER_FIELD_IPV4_FLAG_M \
+(NET_HEADER_FIELD_IPV4_VER << 6)
+#define NET_HEADER_FIELD_IPV4_OFFSET \
+(NET_HEADER_FIELD_IPV4_VER << 7)
+#define NET_HEADER_FIELD_IPV4_TTL \
+(NET_HEADER_FIELD_IPV4_VER << 8)
+#define NET_HEADER_FIELD_IPV4_PROTO \
+(NET_HEADER_FIELD_IPV4_VER << 9)
+#define NET_HEADER_FIELD_IPV4_CKSUM \
+(NET_HEADER_FIELD_IPV4_VER << 10)
+#define NET_HEADER_FIELD_IPV4_SRC_IP \
+(NET_HEADER_FIELD_IPV4_VER << 11)
+#define NET_HEADER_FIELD_IPV4_DST_IP \
+(NET_HEADER_FIELD_IPV4_VER << 12)
+#define NET_HEADER_FIELD_IPV4_OPTS \
+(NET_HEADER_FIELD_IPV4_VER << 13)
+#define NET_HEADER_FIELD_IPV4_OPTS_COUNT \
+(NET_HEADER_FIELD_IPV4_VER << 14)
+#define NET_HEADER_FIELD_IPV4_ALL_FIELDS \
+((NET_HEADER_FIELD_IPV4_VER << 15) - 1)
+
+#define NET_HEADER_FIELD_IPV4_ADDR_SIZE                 4
+#define NET_HEADER_FIELD_IPV4_PROTO_SIZE                1
+
+#define NET_HEADER_FIELD_IPV6_VER                       (1)
+#define NET_HEADER_FIELD_IPV6_TC \
+(NET_HEADER_FIELD_IPV6_VER << 1)
+#define NET_HEADER_FIELD_IPV6_SRC_IP  \
+(NET_HEADER_FIELD_IPV6_VER << 2)
+#define NET_HEADER_FIELD_IPV6_DST_IP \
+(NET_HEADER_FIELD_IPV6_VER << 3)
+#define NET_HEADER_FIELD_IPV6_NEXT_HDR \
+(NET_HEADER_FIELD_IPV6_VER << 4)
+#define NET_HEADER_FIELD_IPV6_FL \
+(NET_HEADER_FIELD_IPV6_VER << 5)
+#define NET_HEADER_FIELD_IPV6_HOP_LIMIT \
+(NET_HEADER_FIELD_IPV6_VER << 6)
+#define NET_HEADER_FIELD_IPV6_ALL_FIELDS \
+((NET_HEADER_FIELD_IPV6_VER << 7) - 1)
+
+#define NET_HEADER_FIELD_IPV6_ADDR_SIZE                 16
+#define NET_HEADER_FIELD_IPV6_NEXT_HDR_SIZE             1
+
+#define NET_HEADER_FIELD_ICMP_TYPE                      (1)
+#define NET_HEADER_FIELD_ICMP_CODE  \
+(NET_HEADER_FIELD_ICMP_TYPE << 1)
+#define NET_HEADER_FIELD_ICMP_CKSUM  \
+(NET_HEADER_FIELD_ICMP_TYPE << 2)
+#define NET_HEADER_FIELD_ICMP_ID  \
+(NET_HEADER_FIELD_ICMP_TYPE << 3)
+#define NET_HEADER_FIELD_ICMP_SQ_NUM  \
+(NET_HEADER_FIELD_ICMP_TYPE << 4)
+#define NET_HEADER_FIELD_ICMP_ALL_FIELDS \
+((NET_HEADER_FIELD_ICMP_TYPE << 5) - 1)
+
+#define NET_HEADER_FIELD_ICMP_CODE_SIZE                 1
+#define NET_HEADER_FIELD_ICMP_TYPE_SIZE                 1
+
+#define NET_HEADER_FIELD_IGMP_VERSION                   (1)
+#define NET_HEADER_FIELD_IGMP_TYPE \
+(NET_HEADER_FIELD_IGMP_VERSION << 1)
+#define NET_HEADER_FIELD_IGMP_CKSUM \
+(NET_HEADER_FIELD_IGMP_VERSION << 2)
+#define NET_HEADER_FIELD_IGMP_DATA \
+(NET_HEADER_FIELD_IGMP_VERSION << 3)
+#define NET_HEADER_FIELD_IGMP_ALL_FIELDS \
+((NET_HEADER_FIELD_IGMP_VERSION << 4) - 1)
+
+#define NET_HEADER_FIELD_TCP_PORT_SRC                   (1)
+#define NET_HEADER_FIELD_TCP_PORT_DST \
+(NET_HEADER_FIELD_TCP_PORT_SRC << 1)
+#define NET_HEADER_FIELD_TCP_SEQ \
+(NET_HEADER_FIELD_TCP_PORT_SRC << 2)
+#define NET_HEADER_FIELD_TCP_ACK \
+(NET_HEADER_FIELD_TCP_PORT_SRC << 3)
+#define NET_HEADER_FIELD_TCP_OFFSET \
+(NET_HEADER_FIELD_TCP_PORT_SRC << 4)
+#define NET_HEADER_FIELD_TCP_FLAGS \
+(NET_HEADER_FIELD_TCP_PORT_SRC << 5)
+#define NET_HEADER_FIELD_TCP_WINDOW \
+(NET_HEADER_FIELD_TCP_PORT_SRC << 6)
+#define NET_HEADER_FIELD_TCP_CKSUM \
+(NET_HEADER_FIELD_TCP_PORT_SRC << 7)
+#define NET_HEADER_FIELD_TCP_URGPTR \
+(NET_HEADER_FIELD_TCP_PORT_SRC << 8)
+#define NET_HEADER_FIELD_TCP_OPTS  \
+(NET_HEADER_FIELD_TCP_PORT_SRC << 9)
+#define NET_HEADER_FIELD_TCP_OPTS_COUNT \
+(NET_HEADER_FIELD_TCP_PORT_SRC << 10)
+#define NET_HEADER_FIELD_TCP_ALL_FIELDS \
+((NET_HEADER_FIELD_TCP_PORT_SRC << 11) - 1)
+
+#define NET_HEADER_FIELD_TCP_PORT_SIZE                  2
+
+#define NET_HEADER_FIELD_SCTP_PORT_SRC                  (1)
+#define NET_HEADER_FIELD_SCTP_PORT_DST \
+(NET_HEADER_FIELD_SCTP_PORT_SRC << 1)
+#define NET_HEADER_FIELD_SCTP_VER_TAG \
+(NET_HEADER_FIELD_SCTP_PORT_SRC << 2)
+#define NET_HEADER_FIELD_SCTP_CKSUM \
+(NET_HEADER_FIELD_SCTP_PORT_SRC << 3)
+#define NET_HEADER_FIELD_SCTP_ALL_FIELDS \
+((NET_HEADER_FIELD_SCTP_PORT_SRC << 4) - 1)
+
+#define NET_HEADER_FIELD_SCTP_PORT_SIZE                 2
+
+#define NET_HEADER_FIELD_DCCP_PORT_SRC                  (1)
+#define NET_HEADER_FIELD_DCCP_PORT_DST \
+(NET_HEADER_FIELD_DCCP_PORT_SRC << 1)
+#define NET_HEADER_FIELD_DCCP_ALL_FIELDS \
+((NET_HEADER_FIELD_DCCP_PORT_SRC << 2) - 1)
+
+#define NET_HEADER_FIELD_DCCP_PORT_SIZE                 2
+
+#define NET_HEADER_FIELD_UDP_PORT_SRC                   (1)
+#define NET_HEADER_FIELD_UDP_PORT_DST \
+(NET_HEADER_FIELD_UDP_PORT_SRC << 1)
+#define NET_HEADER_FIELD_UDP_LEN  \
+(NET_HEADER_FIELD_UDP_PORT_SRC << 2)
+#define NET_HEADER_FIELD_UDP_CKSUM \
+(NET_HEADER_FIELD_UDP_PORT_SRC << 3)
+#define NET_HEADER_FIELD_UDP_ALL_FIELDS \
+((NET_HEADER_FIELD_UDP_PORT_SRC << 4) - 1)
+
+#define NET_HEADER_FIELD_UDP_PORT_SIZE                  2
+
+#define NET_HEADER_FIELD_UDP_LITE_PORT_SRC              (1)
+#define NET_HEADER_FIELD_UDP_LITE_PORT_DST  \
+(NET_HEADER_FIELD_UDP_LITE_PORT_SRC << 1)
+#define NET_HEADER_FIELD_UDP_LITE_ALL_FIELDS \
+((NET_HEADER_FIELD_UDP_LITE_PORT_SRC << 2) - 1)
+
+#define NET_HEADER_FIELD_UDP_LITE_PORT_SIZE             2
+
+#define NET_HEADER_FIELD_UDP_ENCAP_ESP_PORT_SRC         (1)
+#define NET_HEADER_FIELD_UDP_ENCAP_ESP_PORT_DST \
+(NET_HEADER_FIELD_UDP_ENCAP_ESP_PORT_SRC << 1)
+#define NET_HEADER_FIELD_UDP_ENCAP_ESP_LEN \
+(NET_HEADER_FIELD_UDP_ENCAP_ESP_PORT_SRC << 2)
+#define NET_HEADER_FIELD_UDP_ENCAP_ESP_CKSUM \
+(NET_HEADER_FIELD_UDP_ENCAP_ESP_PORT_SRC << 3)
+#define NET_HEADER_FIELD_UDP_ENCAP_ESP_SPI \
+(NET_HEADER_FIELD_UDP_ENCAP_ESP_PORT_SRC << 4)
+#define NET_HEADER_FIELD_UDP_ENCAP_ESP_SEQUENCE_NUM \
+(NET_HEADER_FIELD_UDP_ENCAP_ESP_PORT_SRC << 5)
+#define NET_HEADER_FIELD_UDP_ENCAP_ESP_ALL_FIELDS \
+((NET_HEADER_FIELD_UDP_ENCAP_ESP_PORT_SRC << 6) - 1)
+
+#define NET_HEADER_FIELD_UDP_ENCAP_ESP_PORT_SIZE        2
+#define NET_HEADER_FIELD_UDP_ENCAP_ESP_SPI_SIZE         4
+
+#define NET_HEADER_FIELD_IPHC_CID                       (1)
+#define NET_HEADER_FIELD_IPHC_CID_TYPE \
+(NET_HEADER_FIELD_IPHC_CID << 1)
+#define NET_HEADER_FIELD_IPHC_HCINDEX \
+(NET_HEADER_FIELD_IPHC_CID << 2)
+#define NET_HEADER_FIELD_IPHC_GEN \
+(NET_HEADER_FIELD_IPHC_CID << 3)
+#define NET_HEADER_FIELD_IPHC_D_BIT \
+(NET_HEADER_FIELD_IPHC_CID << 4)
+#define NET_HEADER_FIELD_IPHC_ALL_FIELDS \
+((NET_HEADER_FIELD_IPHC_CID << 5) - 1)
+
+#define NET_HEADER_FIELD_SCTP_CHUNK_DATA_TYPE           (1)
+#define NET_HEADER_FIELD_SCTP_CHUNK_DATA_FLAGS \
+(NET_HEADER_FIELD_SCTP_CHUNK_DATA_TYPE << 1)
+#define NET_HEADER_FIELD_SCTP_CHUNK_DATA_LENGTH \
+(NET_HEADER_FIELD_SCTP_CHUNK_DATA_TYPE << 2)
+#define NET_HEADER_FIELD_SCTP_CHUNK_DATA_TSN \
+(NET_HEADER_FIELD_SCTP_CHUNK_DATA_TYPE << 3)
+#define NET_HEADER_FIELD_SCTP_CHUNK_DATA_STREAM_ID \
+(NET_HEADER_FIELD_SCTP_CHUNK_DATA_TYPE << 4)
+#define NET_HEADER_FIELD_SCTP_CHUNK_DATA_STREAM_SQN \
+(NET_HEADER_FIELD_SCTP_CHUNK_DATA_TYPE << 5)
+#define NET_HEADER_FIELD_SCTP_CHUNK_DATA_PAYLOAD_PID \
+(NET_HEADER_FIELD_SCTP_CHUNK_DATA_TYPE << 6)
+#define NET_HEADER_FIELD_SCTP_CHUNK_DATA_UNORDERED \
+(NET_HEADER_FIELD_SCTP_CHUNK_DATA_TYPE << 7)
+#define NET_HEADER_FIELD_SCTP_CHUNK_DATA_BEGGINING \
+(NET_HEADER_FIELD_SCTP_CHUNK_DATA_TYPE << 8)
+#define NET_HEADER_FIELD_SCTP_CHUNK_DATA_END  \
+(NET_HEADER_FIELD_SCTP_CHUNK_DATA_TYPE << 9)
+#define NET_HEADER_FIELD_SCTP_CHUNK_DATA_ALL_FIELDS \
+((NET_HEADER_FIELD_SCTP_CHUNK_DATA_TYPE << 10) - 1)
+
+#define NET_HEADER_FIELD_L2TPV2_TYPE_BIT                (1)
+#define NET_HEADER_FIELD_L2TPV2_LENGTH_BIT \
+(NET_HEADER_FIELD_L2TPV2_TYPE_BIT << 1)
+#define NET_HEADER_FIELD_L2TPV2_SEQUENCE_BIT \
+(NET_HEADER_FIELD_L2TPV2_TYPE_BIT << 2)
+#define NET_HEADER_FIELD_L2TPV2_OFFSET_BIT  \
+(NET_HEADER_FIELD_L2TPV2_TYPE_BIT << 3)
+#define NET_HEADER_FIELD_L2TPV2_PRIORITY_BIT \
+(NET_HEADER_FIELD_L2TPV2_TYPE_BIT << 4)
+#define NET_HEADER_FIELD_L2TPV2_VERSION \
+(NET_HEADER_FIELD_L2TPV2_TYPE_BIT << 5)
+#define NET_HEADER_FIELD_L2TPV2_LEN \
+(NET_HEADER_FIELD_L2TPV2_TYPE_BIT << 6)
+#define NET_HEADER_FIELD_L2TPV2_TUNNEL_ID \
+(NET_HEADER_FIELD_L2TPV2_TYPE_BIT << 7)
+#define NET_HEADER_FIELD_L2TPV2_SESSION_ID \
+(NET_HEADER_FIELD_L2TPV2_TYPE_BIT << 8)
+#define NET_HEADER_FIELD_L2TPV2_NS \
+(NET_HEADER_FIELD_L2TPV2_TYPE_BIT << 9)
+#define NET_HEADER_FIELD_L2TPV2_NR \
+(NET_HEADER_FIELD_L2TPV2_TYPE_BIT << 10)
+#define NET_HEADER_FIELD_L2TPV2_OFFSET_SIZE \
+(NET_HEADER_FIELD_L2TPV2_TYPE_BIT << 11)
+#define NET_HEADER_FIELD_L2TPV2_FIRST_BYTE \
+(NET_HEADER_FIELD_L2TPV2_TYPE_BIT << 12)
+#define NET_HEADER_FIELD_L2TPV2_ALL_FIELDS \
+((NET_HEADER_FIELD_L2TPV2_TYPE_BIT << 13) - 1)
+
+#define NET_HEADER_FIELD_L2TPV3_CTRL_TYPE_BIT           (1)
+#define NET_HEADER_FIELD_L2TPV3_CTRL_LENGTH_BIT \
+(NET_HEADER_FIELD_L2TPV3_CTRL_TYPE_BIT << 1)
+#define NET_HEADER_FIELD_L2TPV3_CTRL_SEQUENCE_BIT \
+(NET_HEADER_FIELD_L2TPV3_CTRL_TYPE_BIT << 2)
+#define NET_HEADER_FIELD_L2TPV3_CTRL_VERSION \
+(NET_HEADER_FIELD_L2TPV3_CTRL_TYPE_BIT << 3)
+#define NET_HEADER_FIELD_L2TPV3_CTRL_LENGTH \
+(NET_HEADER_FIELD_L2TPV3_CTRL_TYPE_BIT << 4)
+#define NET_HEADER_FIELD_L2TPV3_CTRL_CONTROL \
+(NET_HEADER_FIELD_L2TPV3_CTRL_TYPE_BIT << 5)
+#define NET_HEADER_FIELD_L2TPV3_CTRL_SENT \
+(NET_HEADER_FIELD_L2TPV3_CTRL_TYPE_BIT << 6)
+#define NET_HEADER_FIELD_L2TPV3_CTRL_RECV \
+(NET_HEADER_FIELD_L2TPV3_CTRL_TYPE_BIT << 7)
+#define NET_HEADER_FIELD_L2TPV3_CTRL_FIRST_BYTE \
+(NET_HEADER_FIELD_L2TPV3_CTRL_TYPE_BIT << 8)
+#define NET_HEADER_FIELD_L2TPV3_CTRL_ALL_FIELDS \
+((NET_HEADER_FIELD_L2TPV3_CTRL_TYPE_BIT << 9) - 1)
+
+#define NET_HEADER_FIELD_L2TPV3_SESS_TYPE_BIT           (1)
+#define NET_HEADER_FIELD_L2TPV3_SESS_VERSION  \
+(NET_HEADER_FIELD_L2TPV3_SESS_TYPE_BIT << 1)
+#define NET_HEADER_FIELD_L2TPV3_SESS_ID  \
+(NET_HEADER_FIELD_L2TPV3_SESS_TYPE_BIT << 2)
+#define NET_HEADER_FIELD_L2TPV3_SESS_COOKIE  \
+(NET_HEADER_FIELD_L2TPV3_SESS_TYPE_BIT << 3)
+#define NET_HEADER_FIELD_L2TPV3_SESS_ALL_FIELDS  \
+((NET_HEADER_FIELD_L2TPV3_SESS_TYPE_BIT << 4) - 1)
+
+#define NET_HEADER_FIELD_VLAN_VPRI                      (1)
+#define NET_HEADER_FIELD_VLAN_CFI  \
+(NET_HEADER_FIELD_VLAN_VPRI << 1)
+#define NET_HEADER_FIELD_VLAN_VID  \
+(NET_HEADER_FIELD_VLAN_VPRI << 2)
+#define NET_HEADER_FIELD_VLAN_LENGTH  \
+(NET_HEADER_FIELD_VLAN_VPRI << 3)
+#define NET_HEADER_FIELD_VLAN_TYPE  \
+(NET_HEADER_FIELD_VLAN_VPRI << 4)
+#define NET_HEADER_FIELD_VLAN_ALL_FIELDS \
+((NET_HEADER_FIELD_VLAN_VPRI << 5) - 1)
+
+#define NET_HEADER_FIELD_VLAN_TCI \
+(NET_HEADER_FIELD_VLAN_VPRI | \
+NET_HEADER_FIELD_VLAN_CFI | \
+NET_HEADER_FIELD_VLAN_VID)
+
+#define NET_HEADER_FIELD_LLC_DSAP                       (1)
+#define NET_HEADER_FIELD_LLC_SSAP \
+(NET_HEADER_FIELD_LLC_DSAP << 1)
+#define NET_HEADER_FIELD_LLC_CTRL \
+(NET_HEADER_FIELD_LLC_DSAP << 2)
+#define NET_HEADER_FIELD_LLC_ALL_FIELDS  \
+((NET_HEADER_FIELD_LLC_DSAP << 3) - 1)
+
+#define NET_HEADER_FIELD_NLPID_NLPID                    (1)
+#define NET_HEADER_FIELD_NLPID_ALL_FIELDS  \
+((NET_HEADER_FIELD_NLPID_NLPID << 1) - 1)
+
+#define NET_HEADER_FIELD_SNAP_OUI                       (1)
+#define NET_HEADER_FIELD_SNAP_PID  \
+(NET_HEADER_FIELD_SNAP_OUI << 1)
+#define NET_HEADER_FIELD_SNAP_ALL_FIELDS  \
+((NET_HEADER_FIELD_SNAP_OUI << 2) - 1)
+
+#define NET_HEADER_FIELD_LLC_SNAP_TYPE                  (1)
+#define NET_HEADER_FIELD_LLC_SNAP_ALL_FIELDS  \
+((NET_HEADER_FIELD_LLC_SNAP_TYPE << 1) - 1)
+
+#define NET_HEADER_FIELD_ARP_HTYPE                      (1)
+#define NET_HEADER_FIELD_ARP_PTYPE  \
+(NET_HEADER_FIELD_ARP_HTYPE << 1)
+#define NET_HEADER_FIELD_ARP_HLEN  \
+(NET_HEADER_FIELD_ARP_HTYPE << 2)
+#define NET_HEADER_FIELD_ARP_PLEN  \
+(NET_HEADER_FIELD_ARP_HTYPE << 3)
+#define NET_HEADER_FIELD_ARP_OPER  \
+(NET_HEADER_FIELD_ARP_HTYPE << 4)
+#define NET_HEADER_FIELD_ARP_SHA  \
+(NET_HEADER_FIELD_ARP_HTYPE << 5)
+#define NET_HEADER_FIELD_ARP_SPA  \
+(NET_HEADER_FIELD_ARP_HTYPE << 6)
+#define NET_HEADER_FIELD_ARP_THA  \
+(NET_HEADER_FIELD_ARP_HTYPE << 7)
+#define NET_HEADER_FIELD_ARP_TPA  \
+(NET_HEADER_FIELD_ARP_HTYPE << 8)
+#define NET_HEADER_FIELD_ARP_ALL_FIELDS  \
+((NET_HEADER_FIELD_ARP_HTYPE << 9) - 1)
+
+#define NET_HEADER_FIELD_RFC2684_LLC                    (1)
+#define NET_HEADER_FIELD_RFC2684_NLPID  \
+(NET_HEADER_FIELD_RFC2684_LLC << 1)
+#define NET_HEADER_FIELD_RFC2684_OUI  \
+(NET_HEADER_FIELD_RFC2684_LLC << 2)
+#define NET_HEADER_FIELD_RFC2684_PID  \
+(NET_HEADER_FIELD_RFC2684_LLC << 3)
+#define NET_HEADER_FIELD_RFC2684_VPN_OUI  \
+(NET_HEADER_FIELD_RFC2684_LLC << 4)
+#define NET_HEADER_FIELD_RFC2684_VPN_IDX  \
+(NET_HEADER_FIELD_RFC2684_LLC << 5)
+#define NET_HEADER_FIELD_RFC2684_ALL_FIELDS  \
+((NET_HEADER_FIELD_RFC2684_LLC << 6) - 1)
+
+#define NET_HEADER_FIELD_USER_DEFINED_SRCPORT           (1)
+#define NET_HEADER_FIELD_USER_DEFINED_PCDID  \
+(NET_HEADER_FIELD_USER_DEFINED_SRCPORT << 1)
+#define NET_HEADER_FIELD_USER_DEFINED_ALL_FIELDS  \
+((NET_HEADER_FIELD_USER_DEFINED_SRCPORT << 2) - 1)
+
+#define NET_HEADER_FIELD_PAYLOAD_BUFFER                 (1)
+#define NET_HEADER_FIELD_PAYLOAD_SIZE  \
+(NET_HEADER_FIELD_PAYLOAD_BUFFER << 1)
+#define NET_HEADER_FIELD_MAX_FRM_SIZE \
+(NET_HEADER_FIELD_PAYLOAD_BUFFER << 2)
+#define NET_HEADER_FIELD_MIN_FRM_SIZE  \
+(NET_HEADER_FIELD_PAYLOAD_BUFFER << 3)
+#define NET_HEADER_FIELD_PAYLOAD_TYPE  \
+(NET_HEADER_FIELD_PAYLOAD_BUFFER << 4)
+#define NET_HEADER_FIELD_FRAME_SIZE  \
+(NET_HEADER_FIELD_PAYLOAD_BUFFER << 5)
+#define NET_HEADER_FIELD_PAYLOAD_ALL_FIELDS  \
+((NET_HEADER_FIELD_PAYLOAD_BUFFER << 6) - 1)
+
+#define NET_HEADER_FIELD_GRE_TYPE                       (1)
+#define NET_HEADER_FIELD_GRE_ALL_FIELDS  \
+((NET_HEADER_FIELD_GRE_TYPE << 1) - 1)
+
+#define NET_HEADER_FIELD_MINENCAP_SRC_IP                (1)
+#define NET_HEADER_FIELD_MINENCAP_DST_IP  \
+(NET_HEADER_FIELD_MINENCAP_SRC_IP << 1)
+#define NET_HEADER_FIELD_MINENCAP_TYPE  \
+(NET_HEADER_FIELD_MINENCAP_SRC_IP << 2)
+#define NET_HEADER_FIELD_MINENCAP_ALL_FIELDS \
+((NET_HEADER_FIELD_MINENCAP_SRC_IP << 3) - 1)
+
+#define NET_HEADER_FIELD_IPSEC_AH_NH  \
+(NET_HEADER_FIELD_IPSEC_AH_SPI << 1)
+#define NET_HEADER_FIELD_IPSEC_AH_ALL_FIELDS   \
+((NET_HEADER_FIELD_IPSEC_AH_SPI << 2) - 1)
+
+#define NET_HEADER_FIELD_IPSEC_ESP_SPI                  (1)
+#define NET_HEADER_FIELD_IPSEC_ESP_SEQUENCE_NUM  \
+(NET_HEADER_FIELD_IPSEC_ESP_SPI << 1)
+#define NET_HEADER_FIELD_IPSEC_ESP_ALL_FIELDS  \
+((NET_HEADER_FIELD_IPSEC_ESP_SPI << 2) - 1)
+
+#define NET_HEADER_FIELD_IPSEC_ESP_SPI_SIZE             4
+
+#define NET_HEADER_FIELD_MPLS_LABEL_STACK               (1)
+#define NET_HEADER_FIELD_MPLS_LABEL_STACK_ALL_FIELDS \
+((NET_HEADER_FIELD_MPLS_LABEL_STACK << 1) - 1)
+
+#define NET_HEADER_FIELD_MACSEC_SECTAG                  (1)
+#define NET_HEADER_FIELD_MACSEC_ALL_FIELDS  \
+((NET_HEADER_FIELD_MACSEC_SECTAG << 1) - 1)
+
+enum net_header_type {
+	HEADER_TYPE_NONE = 0,
+	HEADER_TYPE_PAYLOAD,
+	HEADER_TYPE_ETH,
+	HEADER_TYPE_VLAN,
+	HEADER_TYPE_IPV4,
+	HEADER_TYPE_IPV6,
+	HEADER_TYPE_IP,
+	HEADER_TYPE_TCP,
+	HEADER_TYPE_UDP,
+	HEADER_TYPE_UDP_LITE,
+	HEADER_TYPE_IPHC,
+	HEADER_TYPE_SCTP,
+	HEADER_TYPE_SCTP_CHUNK_DATA,
+	HEADER_TYPE_PPPOE,
+	HEADER_TYPE_PPP,
+	HEADER_TYPE_PPPMUX,
+	HEADER_TYPE_PPPMUX_SUBFRAME,
+	HEADER_TYPE_L2TPV2,
+	HEADER_TYPE_L2TPV3_CTRL,
+	HEADER_TYPE_L2TPV3_SESS,
+	HEADER_TYPE_LLC,
+	HEADER_TYPE_LLC_SNAP,
+	HEADER_TYPE_NLPID,
+	HEADER_TYPE_SNAP,
+	HEADER_TYPE_MPLS,
+	HEADER_TYPE_IPSEC_AH,
+	HEADER_TYPE_IPSEC_ESP,
+	HEADER_TYPE_UDP_ENCAP_ESP,	/* RFC 3948 */
+	HEADER_TYPE_MACSEC,
+	HEADER_TYPE_GRE,
+	HEADER_TYPE_MINENCAP,
+	HEADER_TYPE_DCCP,
+	HEADER_TYPE_ICMP,
+	HEADER_TYPE_IGMP,
+	HEADER_TYPE_ARP,
+	HEADER_TYPE_CAPWAP,
+	HEADER_TYPE_CAPWAP_DTLS,
+	HEADER_TYPE_RFC2684,
+	HEADER_TYPE_USER_DEFINED_L2,
+	HEADER_TYPE_USER_DEFINED_L3,
+	HEADER_TYPE_USER_DEFINED_L4,
+	HEADER_TYPE_USER_DEFINED_SHIM1,
+	HEADER_TYPE_USER_DEFINED_SHIM2,
+	MAX_HEADER_TYPE_COUNT
+};
+
+#endif /* __NET_EXT_H */
diff --git a/drivers/net/ethernet/freescale/fman/inc/service.h b/drivers/net/ethernet/freescale/fman/inc/service.h
new file mode 100644
index 0000000..7311d10
--- /dev/null
+++ b/drivers/net/ethernet/freescale/fman/inc/service.h
@@ -0,0 +1,90 @@
+/*
+ * Copyright 2008-2015 Freescale Semiconductor Inc.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Freescale Semiconductor nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
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
+#ifndef __SERVICE_h
+#define __SERVICE_h
+
+#include <linux/version.h>
+
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/io.h>
+
+/* Define ASSERT condition */
+#undef ASSERT
+#define ASSERT(x)       WARN_ON(!(x))
+
+/* In range macro */
+#define IN_RANGE(min, val, max) ((min) <= (val) && (val) <= (max))
+
+/* Ceiling division - not the fastest way, but safer in terms of overflow */
+#define DIV_CEIL(x, y) \
+	((div64_u64(x, y)) + (((((div64_u64(x, y))) * (y)) == (x)) ? 0 : 1))
+
+/* Round up a number to be a multiple of a second number */
+#define ROUND_UP(x, y)   ((((x) + (y) - 1) / (y)) * (y))
+
+#define PTR_TO_UINT(_ptr)           ((uintptr_t)(_ptr))
+#define UINT_TO_PTR(_val)           ((void __iomem *)(uintptr_t)(_val))
+#define PTR_MOVE(_ptr, _offset)     (void *)((uint8_t *)(_ptr) + (_offset))
+
+/* memory access macros */
+#define GET_UINT8(arg)		in_be8(&(arg))
+#define GET_UINT16(arg)		in_be16(&(arg))
+#define GET_UINT32(arg)		in_be32(&(arg))
+#define GET_UINT64(arg)		(*(__iomem uint64_t *)(&(arg)))
+
+#define WRITE_UINT8(arg, data)		out_be8(&(arg), data)
+#define WRITE_UINT16(arg, data)	out_be16(&(arg), data)
+#define WRITE_UINT32(arg, data)	out_be32(&(arg), data)
+#define WRITE_UINT64(arg, data)	(*(__iomem uint64_t *)(&(arg)) = (data))
+
+/* Timing macro for converting usec units to number of ticks
+ * (number of usec* clock_Hz) / 1,000,000) - since clk is in MHz units,
+ * no division needed.
+ */
+#define USEC_TO_CLK(usec, clk)       ((usec) * (clk))
+#define CYCLES_TO_USEC(cycles, clk)  ((cycles) / (clk))
+
+#define ILLEGAL_BASE    (~0)
+
+/* Enumeration (bit flags) of communication modes (Transmit,
+ * receive or both).
+ */
+enum comm_mode {
+	COMM_MODE_NONE = 0,	    /* No transmit/receive communication */
+	COMM_MODE_RX = 1,	    /* Only receive communication */
+	COMM_MODE_TX = 2,	    /* Only transmit communication */
+	COMM_MODE_RX_AND_TX = 3   /*Both transmit and receive communication*/
+};
+
+#endif /* SERVICE */
-- 
1.7.11.7
