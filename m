From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 2/7] soc/fman: Add the FMan FLIB
Date: Fri, 6 Mar 2015 18:57:33 -0600
Message-ID: <1425689853.4698.174.camel@freescale.com>
References: <1425534351-1065-1-git-send-email-Emilian.Medve@Freescale.com>
	 <1425534351-1065-3-git-send-email-Emilian.Medve@Freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linuxppc-dev@lists.ozlabs.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	Igal Liberman <Igal.Liberman@Freescale.com>
To: Emil Medve <Emilian.Medve@Freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425534351-1065-3-git-send-email-Emilian.Medve@Freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-03-04 at 23:45 -0600, Emil Medve wrote:
> From: Igal Liberman <Igal.Liberman@freescale.com>
> 
> Signed-off-by: Igal Liberman <Igal.Liberman@freescale.com>
> ---
>  drivers/soc/Kconfig           |    1 +
>  drivers/soc/Makefile          |    1 +
>  drivers/soc/fsl/Kconfig       |    1 +
>  drivers/soc/fsl/Makefile      |    1 +
>  drivers/soc/fsl/fman/Kconfig  |    7 +
>  drivers/soc/fsl/fman/Makefile |   13 +
>  drivers/soc/fsl/fman/fman.c   | 1396 +++++++++++++++++++++++++++++++++++++++++
>  7 files changed, 1420 insertions(+)
>  create mode 100644 drivers/soc/fsl/Kconfig
>  create mode 100644 drivers/soc/fsl/Makefile
>  create mode 100644 drivers/soc/fsl/fman/Kconfig
>  create mode 100644 drivers/soc/fsl/fman/Makefile
>  create mode 100644 drivers/soc/fsl/fman/fman.c
> 
> diff --git a/drivers/soc/Kconfig b/drivers/soc/Kconfig
> index 76d6bd4..674a6e6 100644
> --- a/drivers/soc/Kconfig
> +++ b/drivers/soc/Kconfig
> @@ -1,5 +1,6 @@
>  menu "SOC (System On Chip) specific Drivers"
>  
> +source "drivers/soc/fsl/Kconfig"
>  source "drivers/soc/qcom/Kconfig"
>  source "drivers/soc/ti/Kconfig"
>  source "drivers/soc/versatile/Kconfig"
> diff --git a/drivers/soc/Makefile b/drivers/soc/Makefile
> index 063113d..42836ee 100644
> --- a/drivers/soc/Makefile
> +++ b/drivers/soc/Makefile
> @@ -2,6 +2,7 @@
>  # Makefile for the Linux Kernel SOC specific device drivers.
>  #
>  
> +obj-$(CONFIG_FSL_SOC)		+= fsl/
>  obj-$(CONFIG_ARCH_QCOM)		+= qcom/
>  obj-$(CONFIG_ARCH_TEGRA)	+= tegra/
>  obj-$(CONFIG_SOC_TI)		+= ti/
> diff --git a/drivers/soc/fsl/Kconfig b/drivers/soc/fsl/Kconfig
> new file mode 100644
> index 0000000..38c08ae
> --- /dev/null
> +++ b/drivers/soc/fsl/Kconfig
> @@ -0,0 +1 @@
> +source "drivers/soc/fsl/fman/Kconfig"
> diff --git a/drivers/soc/fsl/Makefile b/drivers/soc/fsl/Makefile
> new file mode 100644
> index 0000000..97d715c
> --- /dev/null
> +++ b/drivers/soc/fsl/Makefile
> @@ -0,0 +1 @@
> +obj-$(CONFIG_FSL_FMAN)           += fman/
> diff --git a/drivers/soc/fsl/fman/Kconfig b/drivers/soc/fsl/fman/Kconfig
> new file mode 100644
> index 0000000..e5009a9
> --- /dev/null
> +++ b/drivers/soc/fsl/fman/Kconfig
> @@ -0,0 +1,7 @@
> +menuconfig FSL_FMAN
> +	tristate "Freescale DPAA Frame Manager"
> +	depends on FSL_SOC || COMPILE_TEST
> +	default n
> +	help
> +		Freescale Data-Path Acceleration Architecture Frame Manager
> +		(FMan) support

As this doesn't appear to be a complete driver, why is it
user-selectable?  Likewise for the other flib patches.

Why are you adding the flibs in a big batch, rather than bundling the
code with the driver patches that use it?

Is there a minimal core of fman functionality (complete functionality,
not flibs) that you could start with, rather than trying to get the
entire thing reviewed at once?  In other words, break it up vertically,
not horizontally.

Note that the lack of caller context is especially harmful given that
the functions are not documented.

> diff --git a/drivers/soc/fsl/fman/Makefile b/drivers/soc/fsl/fman/Makefile
> new file mode 100644
> index 0000000..d7fbecb
> --- /dev/null
> +++ b/drivers/soc/fsl/fman/Makefile
> @@ -0,0 +1,13 @@
> +ccflags-y += -DVERSION=\"\"
> +
> +ifeq ($(CONFIG_FSL_FMAN),y)
> +
> +FMAN = $(srctree)/drivers/soc/fsl/fman
> +
> +ccflags-y += -I$(FMAN)/flib
> +
> +obj-$(CONFIG_FSL_FMAN)	+= fsl_fman.o
> +
> +fsl_fman-objs		:= fman.o
> +
> +endif

You won't even get into this makefile if CONFIG_FSL_FMAN=n...  Did you
really mean to exclude this stuff when CONFIG_FSL_FMAN=m?

> +int fman_reset_mac(struct fman_fpm_regs __iomem *fpm_rg, uint8_t mac_id)
> +{
> +	uint32_t msk, timeout = 100;
> +
> +	/* Get the relevant bit mask */
> +	switch (mac_id) {
> +	case (0):
> +		msk = FPM_RSTC_MAC0_RESET;
> +		break;
> +	case (1):
> +		msk = FPM_RSTC_MAC1_RESET;
> +		break;
> +	case (2):
> +		msk = FPM_RSTC_MAC2_RESET;
> +		break;
> +	case (3):
> +		msk = FPM_RSTC_MAC3_RESET;
> +		break;
> +	case (4):
> +		msk = FPM_RSTC_MAC4_RESET;
> +		break;
> +	case (5):
> +		msk = FPM_RSTC_MAC5_RESET;
> +		break;
> +	case (6):
> +		msk = FPM_RSTC_MAC6_RESET;
> +		break;
> +	case (7):
> +		msk = FPM_RSTC_MAC7_RESET;
> +		break;
> +	case (8):
> +		msk = FPM_RSTC_MAC8_RESET;
> +		break;
> +	case (9):
> +		msk = FPM_RSTC_MAC9_RESET;
> +		break;
> +	default:
> +		return -EINVAL;
> +	}

Without seeing the caller, I can't judge whether there's a good reason
for passing this in by number rather than passing in FPM_RSTC_MACn_RESET
directly and avoiding the switch.

> +	/* reset */
> +	iowrite32be(msk, &fpm_rg->fm_rstc);
> +	while ((ioread32be(&fpm_rg->fm_rstc) & msk) && --timeout)
> +		usleep_range(10, 11);
> +
> +	if (!timeout)
> +		return -EBUSY;
> +	return 0;
> +}

-EBUSY generally means that the caller is expected to try again.  I
think this should be -EIO.

> +uint32_t fman_get_total_fifo_size(struct fman_bmi_regs __iomem *bmi_rg)
> +{
> +	uint32_t reg, res;
> +
> +	reg = ioread32be(&bmi_rg->fmbm_cfg1);
> +	res = (reg >> BMI_CFG1_FIFO_SIZE_SHIFT) & 0x3ff;
> +	return res * FMAN_BMI_FIFO_UNITS;
> +}

Where did 0x3ff come from?

> +void fman_set_num_of_tasks(struct fman_bmi_regs __iomem *bmi_rg,
> +			   uint8_t port_id, uint8_t num_tasks,
> +			   uint8_t num_extra_tasks)
> +{
> +	uint32_t tmp;
> +
> +	if ((port_id > 63) || (port_id < 1))
> +		return;
> +
> +	/* calculate reg */
> +	tmp = ioread32be(&bmi_rg->fmbm_pp[port_id - 1]) &
> +	    ~(BMI_NUM_OF_TASKS_MASK | BMI_NUM_OF_EXTRA_TASKS_MASK);
> +	tmp |= (uint32_t)(((num_tasks - 1) << BMI_NUM_OF_TASKS_SHIFT) |
> +			   (num_extra_tasks << BMI_EXTRA_NUM_OF_TASKS_SHIFT));
> +	iowrite32be(tmp, &bmi_rg->fmbm_pp[port_id - 1]);
> +}

That cast needs to be inside each shift -- doing it at the end is
useless.  Or rather, you don't need any cast at all for 32-bit results
(which is why it works despite being misplaced) because of C type
promotion rules, as long as you don't rely on whether the result is
signed or not.  Still, it would be nice to not rely on that due to
always using the smallest type you can get away with.

> +void fman_set_vsp_window(struct fman_bmi_regs __iomem *bmi_rg,
> +			 uint8_t port_id,
> +			 uint8_t base_storage_profile,
> +			 uint8_t log2_num_of_profiles)
> +{
> +	uint32_t tmp = 0;
> +
> +	if ((port_id > 63) || (port_id < 1))
> +		return;

Where does 63 come from?  And shouldn't there be some sort of WARN,
especially if you're not going to pass back an error code?  Don't
silently eat errors.

Oh, and unnecessary parentheses.

> +/* API Init unit functions */
> +
> +void fman_defconfig(struct fman_cfg *cfg)
> +{
> +	memset(cfg, 0, sizeof(struct fman_cfg));
> +
> +	cfg->catastrophic_err = DEFAULT_CATASTROPHIC_ERR;
> +	cfg->dma_err = DEFAULT_DMA_ERR;
> +	cfg->halt_on_external_activ = DEFAULT_HALT_ON_EXTERNAL_ACTIVATION;
> +	cfg->halt_on_unrecov_ecc_err = DEFAULT_HALT_ON_UNRECOVERABLE_ECC_ERROR;
> +	cfg->en_iram_test_mode = false;
> +	cfg->en_muram_test_mode = false;
> +	cfg->external_ecc_rams_enable = DEFAULT_EXTERNAL_ECC_RAMS_ENABLE;
> +
> +	cfg->dma_aid_override = DEFAULT_AID_OVERRIDE;
> +	cfg->dma_aid_mode = DEFAULT_AID_MODE;
> +	cfg->dma_comm_qtsh_clr_emer = DEFAULT_DMA_COMM_Q_LOW;
> +	cfg->dma_comm_qtsh_asrt_emer = DEFAULT_DMA_COMM_Q_HIGH;
> +	cfg->dma_cache_override = DEFAULT_CACHE_OVERRIDE;
> +	cfg->dma_cam_num_of_entries = DEFAULT_DMA_CAM_NUM_OF_ENTRIES;
> +	cfg->dma_dbg_cnt_mode = DEFAULT_DMA_DBG_CNT_MODE;
> +	cfg->dma_en_emergency = DEFAULT_DMA_EN_EMERGENCY;
> +	cfg->dma_sos_emergency = DEFAULT_DMA_SOS_EMERGENCY;
> +	cfg->dma_watchdog = DEFAULT_DMA_WATCHDOG;
> +	cfg->dma_en_emergency_smoother = DEFAULT_DMA_EN_EMERGENCY_SMOOTHER;
> +	cfg->dma_emergency_switch_counter =
> +	    DEFAULT_DMA_EMERGENCY_SWITCH_COUNTER;
> +	cfg->disp_limit_tsh = DEFAULT_DISP_LIMIT;
> +	cfg->prs_disp_tsh = DEFAULT_PRS_DISP_TH;
> +	cfg->plcr_disp_tsh = DEFAULT_PLCR_DISP_TH;
> +	cfg->kg_disp_tsh = DEFAULT_KG_DISP_TH;
> +	cfg->bmi_disp_tsh = DEFAULT_BMI_DISP_TH;
> +	cfg->qmi_enq_disp_tsh = DEFAULT_QMI_ENQ_DISP_TH;
> +	cfg->qmi_deq_disp_tsh = DEFAULT_QMI_DEQ_DISP_TH;
> +	cfg->fm_ctl1_disp_tsh = DEFAULT_FM_CTL1_DISP_TH;
> +	cfg->fm_ctl2_disp_tsh = DEFAULT_FM_CTL2_DISP_TH;
> +
> +	cfg->pedantic_dma = false;
> +	cfg->tnum_aging_period = DEFAULT_TNUM_AGING_PERIOD;
> +	cfg->dma_stop_on_bus_error = false;
> +	cfg->qmi_deq_option_support = false;
> +}

Couldn't you do this as a struct initializer?

> +/*  fm_init
> + *  Initializes the FM module
> + *  h_fm - FM module descriptor
> + *  Return        0 on success; Error code otherwise.
> + */
> +int fman_dma_init(struct fman_dma_regs __iomem *dma_rg, struct fman_cfg *cfg)
> +{
> +	uint32_t tmp_reg;
> +
> +	/* Init DMA Registers */
> +
> +	/* clear status reg events */
> +	/* oren - check!!!  */
> +	tmp_reg = (DMA_STATUS_BUS_ERR | DMA_STATUS_READ_ECC |
> +		   DMA_STATUS_SYSTEM_WRITE_ECC | DMA_STATUS_FM_WRITE_ECC);
> +	iowrite32be(ioread32be(&dma_rg->fmdmsr) | tmp_reg, &dma_rg->fmdmsr);

Either get Oren to check this, or remove the comment. :-)

> +	tmp_reg =
> +	    (((uint32_t)cfg->
> +	      qmi_enq_disp_tsh << FPM_THR2_QMI_ENQ_SHIFT) |
> +	      ((uint32_t)cfg->qmi_deq_disp_tsh << FPM_THR2_QMI_DEQ_SHIFT)
> +	     | ((uint32_t)cfg->
> +		fm_ctl1_disp_tsh << FPM_THR2_FM_CTL1_SHIFT) |
> +		((uint32_t)cfg->fm_ctl2_disp_tsh << FPM_THR2_FM_CTL2_SHIFT));

Yikes.


> +	iowrite32be(tmp_reg, &fpm_rg->fmfp_dist2);
> +
> +	/* define exceptions and error behavior */
> +	tmp_reg = 0;
> +	/* Clear events */
> +	tmp_reg |= (FPM_EV_MASK_STALL | FPM_EV_MASK_DOUBLE_ECC |
> +		    FPM_EV_MASK_SINGLE_ECC);
> +	/* enable interrupts */
> +	if (cfg->exceptions & FMAN_EX_FPM_STALL_ON_TASKS)
> +		tmp_reg |= FPM_EV_MASK_STALL_EN;
> +	if (cfg->exceptions & FMAN_EX_FPM_SINGLE_ECC)
> +		tmp_reg |= FPM_EV_MASK_SINGLE_ECC_EN;
> +	if (cfg->exceptions & FMAN_EX_FPM_DOUBLE_ECC)
> +		tmp_reg |= FPM_EV_MASK_DOUBLE_ECC_EN;
> +	tmp_reg |= (cfg->catastrophic_err << FPM_EV_MASK_CAT_ERR_SHIFT);
> +	tmp_reg |= (cfg->dma_err << FPM_EV_MASK_DMA_ERR_SHIFT);
> +	if (!cfg->halt_on_external_activ)
> +		tmp_reg |= FPM_EV_MASK_EXTERNAL_HALT;
> +	if (!cfg->halt_on_unrecov_ecc_err)
> +		tmp_reg |= FPM_EV_MASK_ECC_ERR_HALT;
> +	iowrite32be(tmp_reg, &fpm_rg->fmfp_ee);
> +
> +	/* clear all fmCtls event registers */
> +	for (i = 0; i < cfg->num_of_fman_ctrl_evnt_regs; i++)
> +		iowrite32be(0xFFFFFFFF, &fpm_rg->fmfp_cev[i]);
> +
> +	/* RAM ECC -  enable and clear events */
> +	/* first we need to clear all parser memory,
> +	 * as it is uninitialized and may cause ECC errors
> +	 */
> +	/* event bits */
> +	tmp_reg = (FPM_RAM_MURAM_ECC | FPM_RAM_IRAM_ECC);
> +	/* Rams enable not effected by RCR bit,
> +	 * but by a COP configuration
> +	 */
> +	if (cfg->external_ecc_rams_enable)
> +		tmp_reg |= FPM_RAM_RAMS_ECC_EN_SRC_SEL;
> +
> +	/* enable test mode */
> +	if (cfg->en_muram_test_mode)
> +		tmp_reg |= FPM_RAM_MURAM_TEST_ECC;
> +	if (cfg->en_iram_test_mode)
> +		tmp_reg |= FPM_RAM_IRAM_TEST_ECC;
> +	iowrite32be(tmp_reg, &fpm_rg->fm_rcr);
> +
> +	tmp_reg = 0;
> +	if (cfg->exceptions & FMAN_EX_IRAM_ECC) {
> +		tmp_reg |= FPM_IRAM_ECC_ERR_EX_EN;
> +		fman_enable_rams_ecc(fpm_rg);
> +	}
> +	if (cfg->exceptions & FMAN_EX_NURAM_ECC) {
> +		tmp_reg |= FPM_MURAM_ECC_ERR_EX_EN;
> +		fman_enable_rams_ecc(fpm_rg);
> +	}
> +	iowrite32be(tmp_reg, &fpm_rg->fm_rie);
> +
> +	return 0;
> +}
> +
> +int fman_bmi_init(struct fman_bmi_regs __iomem *bmi_rg, struct fman_cfg *cfg)
> +{
> +	uint32_t tmp_reg;
> +
> +	/* Init BMI Registers */
> +
> +	/* define common resources */
> +	tmp_reg = cfg->fifo_base_addr;
> +	tmp_reg = tmp_reg / BMI_FIFO_ALIGN;
> +
> +	tmp_reg |= ((cfg->total_fifo_size / FMAN_BMI_FIFO_UNITS - 1) <<
> +		    BMI_CFG1_FIFO_SIZE_SHIFT);
> +	iowrite32be(tmp_reg, &bmi_rg->fmbm_cfg1);
> +
> +	tmp_reg = ((uint32_t)(cfg->total_num_of_tasks - 1) <<
> +		   BMI_CFG2_TASKS_SHIFT);
> +	/* num of DMA's will be dynamically updated when each port is set */
> +	iowrite32be(tmp_reg, &bmi_rg->fmbm_cfg2);
> +
> +	/* define unmaskable exceptions, enable and clear events */
> +	tmp_reg = 0;
> +	iowrite32be(BMI_ERR_INTR_EN_LIST_RAM_ECC |
> +		    BMI_ERR_INTR_EN_STORAGE_PROFILE_ECC |
> +		    BMI_ERR_INTR_EN_STATISTICS_RAM_ECC |
> +		    BMI_ERR_INTR_EN_DISPATCH_RAM_ECC, &bmi_rg->fmbm_ievr);
> +
> +	if (cfg->exceptions & FMAN_EX_BMI_LIST_RAM_ECC)
> +		tmp_reg |= BMI_ERR_INTR_EN_LIST_RAM_ECC;
> +	if (cfg->exceptions & FMAN_EX_BMI_PIPELINE_ECC)
> +		tmp_reg |= BMI_ERR_INTR_EN_STORAGE_PROFILE_ECC;
> +	if (cfg->exceptions & FMAN_EX_BMI_STATISTICS_RAM_ECC)
> +		tmp_reg |= BMI_ERR_INTR_EN_STATISTICS_RAM_ECC;
> +	if (cfg->exceptions & FMAN_EX_BMI_DISPATCH_RAM_ECC)
> +		tmp_reg |= BMI_ERR_INTR_EN_DISPATCH_RAM_ECC;
> +	iowrite32be(tmp_reg, &bmi_rg->fmbm_ier);
> +
> +	return 0;
> +}
> +
> +int fman_qmi_init(struct fman_qmi_regs __iomem *qmi_rg, struct fman_cfg *cfg)
> +{
> +	uint32_t tmp_reg;
> +	uint16_t period_in_fm_clocks;
> +	uint8_t remainder;
> +
> +	/* Init QMI Registers */
> +
> +	/* Clear error interrupt events */
> +
> +	iowrite32be(QMI_ERR_INTR_EN_DOUBLE_ECC | QMI_ERR_INTR_EN_DEQ_FROM_DEF,
> +		    &qmi_rg->fmqm_eie);
> +	tmp_reg = 0;
> +	if (cfg->exceptions & FMAN_EX_QMI_DEQ_FROM_UNKNOWN_PORTID)
> +		tmp_reg |= QMI_ERR_INTR_EN_DEQ_FROM_DEF;
> +	if (cfg->exceptions & FMAN_EX_QMI_DOUBLE_ECC)
> +		tmp_reg |= QMI_ERR_INTR_EN_DOUBLE_ECC;
> +	/* enable events */
> +	iowrite32be(tmp_reg, &qmi_rg->fmqm_eien);
> +
> +	if (cfg->tnum_aging_period) {
> +		/* tnum_aging_period is in units of usec,
> +		 * p_fmClockFreq in Mhz
> +		 */
> +		period_in_fm_clocks = (uint16_t)
> +			(cfg->tnum_aging_period * cfg->clk_freq);
> +		/* periodInFmClocks must be a 64 multiply */
> +		remainder = (uint8_t)(period_in_fm_clocks % 64);

Name in comment doesn't match code (and unnecessary cast).

s/multiply/multiple/

> +		if (remainder) {
> +			tmp_reg = (uint32_t)((period_in_fm_clocks / 64) + 1);
> +		} else {
> +			tmp_reg = (uint32_t)(period_in_fm_clocks / 64);
> +			if (!tmp_reg)
> +				tmp_reg = 1;
> +		}
> +		tmp_reg <<= QMI_TAPC_TAP;
> +		iowrite32be(tmp_reg, &qmi_rg->fmqm_tapc);
> +	}
> +	tmp_reg = 0;
> +	/* Clear interrupt events */
> +	iowrite32be(QMI_INTR_EN_SINGLE_ECC, &qmi_rg->fmqm_ie);
> +	if (cfg->exceptions & FMAN_EX_QMI_SINGLE_ECC)
> +		tmp_reg |= QMI_INTR_EN_SINGLE_ECC;
> +	/* enable events */
> +	iowrite32be(tmp_reg, &qmi_rg->fmqm_ien);
> +
> +	return 0;
> +}
> +
> +int fman_enable(struct fman_rg *fman_rg, struct fman_cfg *cfg)
> +{
> +	uint32_t cfg_reg = 0;
> +
> +	/* Enable all modules */
> +
> +	/* clear&enable global counters  - calculate reg and save for later,
> +	 * because it's the same reg for QMI enable
> +	 */
> +	cfg_reg = QMI_CFG_EN_COUNTERS;
> +	if (cfg->qmi_deq_option_support)
> +		cfg_reg |= (uint32_t)(((cfg->qmi_def_tnums_thresh) << 8) |
> +				       (uint32_t)cfg->qmi_def_tnums_thresh);

Unnecessary casts.

> +
> +	iowrite32be(BMI_INIT_START, &fman_rg->bmi_rg->fmbm_init);
> +	iowrite32be(cfg_reg | QMI_CFG_ENQ_EN | QMI_CFG_DEQ_EN,
> +		    &fman_rg->qmi_rg->fmqm_gc);
> +
> +	return 0;
> +}


> +void fman_set_ports_bandwidth(struct fman_bmi_regs __iomem *bmi_rg,
> +			      uint8_t *weights)
> +{
> +	int i;
> +	uint8_t shift;
> +	uint32_t tmp = 0;
> +
> +	for (i = 0; i < 64; i++) {
> +		if (weights[i] > 1) {	/* no need to write 1 since it is 0 */

If you have an API requirement that weights is of size 64, then use
"uint8_t weights[64]".  What does 64 represent?  Can it be symbolic?
Can it be supplied by the caller instead of hardcoded?

> +			/* Add this port to tmp_reg */
> +			/* (each 8 ports result in one register) */
> +			shift = (uint8_t)(32 - 4 * ((i % 8) + 1));
> +			tmp |= ((weights[i] - 1) << shift);
> +		}
> +		if (i % 8 == 7) {	/* last in this set */
> +			iowrite32be(tmp, &bmi_rg->fmbm_arb[i / 8]);
> +			tmp = 0;
> +		}
> +	}
> +}


	for (i = 0; i < nreg; i++) {
		u32 tmp = 0;

		for (j = 0; j < 8; j++) {
			uint8_t weight = weights[i * 8 + j];

			WARN_ON(weight > 0xf);
			tmp |= weight;
			tmp <<= 4;
		}

		iowrite32be(tmp, &bmi_rg->fmbm_arb[i]);
	}

> +
> +void fman_enable_rams_ecc(struct fman_fpm_regs __iomem *fpm_rg)
> +{
> +	uint32_t tmp;
> +
> +	tmp = ioread32be(&fpm_rg->fm_rcr);
> +	if (tmp & FPM_RAM_RAMS_ECC_EN_SRC_SEL)
> +		iowrite32be(tmp | FPM_RAM_IRAM_ECC_EN, &fpm_rg->fm_rcr);
> +	else
> +		iowrite32be(tmp | FPM_RAM_RAMS_ECC_EN |
> +			    FPM_RAM_IRAM_ECC_EN, &fpm_rg->fm_rcr);
> +}

	tmp = ioread32be(&fpm_rg->fm_rcr);
	if (tmp & FPM_RAM_RAMS_ECC_EN_SRC_SEL)
		tmp |= FPM_RAM_RAMS_ECC_EN;
	iowrite32be(tmp | FPM_RAM_IRAM_ECC_EN, &fpm_rg->fm_rcr);

> +int fman_modify_counter(struct fman_rg *fman_rg,
> +			enum fman_counters reg_name, uint32_t val)
> +{
> +	/* When applicable (when there is an 'enable counters' bit,
> +	 * check that counters are enabled
> +	 */
> +	switch (reg_name) {
> +	case (E_FMAN_COUNTERS_ENQ_TOTAL_FRAME):
> +	case (E_FMAN_COUNTERS_DEQ_TOTAL_FRAME):
> +	case (E_FMAN_COUNTERS_DEQ_0):
> +	case (E_FMAN_COUNTERS_DEQ_1):
> +	case (E_FMAN_COUNTERS_DEQ_2):
> +	case (E_FMAN_COUNTERS_DEQ_3):
> +	case (E_FMAN_COUNTERS_DEQ_FROM_DEFAULT):
> +	case (E_FMAN_COUNTERS_DEQ_FROM_CONTEXT):
> +	case (E_FMAN_COUNTERS_DEQ_FROM_FD):
> +	case (E_FMAN_COUNTERS_DEQ_CONFIRM):

Why the parentheses?

> +void fman_set_dma_emergency(struct fman_dma_regs __iomem *dma_rg,
> +			    bool is_write, bool enable)
> +{
> +	uint32_t msk;
> +
> +	msk = (uint32_t)(is_write ? DMA_MODE_EMER_WRITE : DMA_MODE_EMER_READ);

Unnecessary cast.

Why doesn't the caller just pass in
DMA_MODE_EMER_WRITE/DMA_MODE_EMER_READ?

> +void fman_force_intr(struct fman_rg *fman_rg, enum fman_exceptions exception)
> +{
> +	switch (exception) {
> +	case E_FMAN_EX_QMI_DEQ_FROM_UNKNOWN_PORTID:
> +		iowrite32be(QMI_ERR_INTR_EN_DEQ_FROM_DEF,
> +			    &fman_rg->qmi_rg->fmqm_eif);
> +		break;
> +	case E_FMAN_EX_QMI_SINGLE_ECC:
> +		iowrite32be(QMI_INTR_EN_SINGLE_ECC, &fman_rg->qmi_rg->fmqm_if);
> +		break;
> +	case E_FMAN_EX_QMI_DOUBLE_ECC:
> +		iowrite32be(QMI_ERR_INTR_EN_DOUBLE_ECC,
> +			    &fman_rg->qmi_rg->fmqm_eif);
> +		break;
> +	case E_FMAN_EX_BMI_LIST_RAM_ECC:
> +		iowrite32be(BMI_ERR_INTR_EN_LIST_RAM_ECC,
> +			    &fman_rg->bmi_rg->fmbm_ifr);
> +		break;
> +	case E_FMAN_EX_BMI_STORAGE_PROFILE_ECC:
> +		iowrite32be(BMI_ERR_INTR_EN_STORAGE_PROFILE_ECC,
> +			    &fman_rg->bmi_rg->fmbm_ifr);
> +		break;
> +	case E_FMAN_EX_BMI_STATISTICS_RAM_ECC:
> +		iowrite32be(BMI_ERR_INTR_EN_STATISTICS_RAM_ECC,
> +			    &fman_rg->bmi_rg->fmbm_ifr);
> +		break;
> +	case E_FMAN_EX_BMI_DISPATCH_RAM_ECC:
> +		iowrite32be(BMI_ERR_INTR_EN_DISPATCH_RAM_ECC,
> +			    &fman_rg->bmi_rg->fmbm_ifr);
> +		break;

How does this abstraction improve on simply writing the bit directly?
Likewise elsewhere.

> +	default:
> +		break;

Unnecessary.

> +	}
> +}
> +
> +bool fman_is_qmi_halt_not_busy_state(struct fman_qmi_regs __iomem *qmi_rg)
> +{
> +	return (bool)!!(ioread32be(&qmi_rg->fmqm_gs) & QMI_GS_HALT_NOT_BUSY);

Unnecessary cast.

-Scott
