From: Scott Wood <scottwood@freescale.com>
Subject: Re: [v2,5/9] fsl/fman: Add Frame Manager support
Date: Thu, 25 Jun 2015 22:54:45 -0500
Message-ID: <1435290885.6524.13.camel@freescale.com>
References: <1435174555-7008-1-git-send-email-igal.liberman@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>,
	<madalin.bucur@freescale.com>, <pebolle@tiscali.nl>
To: <igal.liberman@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0112.outbound.protection.outlook.com ([157.56.110.112]:43574
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751589AbbFZDzY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jun 2015 23:55:24 -0400
In-Reply-To: <1435174555-7008-1-git-send-email-igal.liberman@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-06-24 at 22:35 +0300, igal.liberman@freescale.com wrote:
> From: Igal Liberman <Igal.Liberman@freescale.com>
> 
> Add Frame Manger Driver support.
> This patch adds The FMan configuration, initialization and
> runtime control routines.
> 
> Signed-off-by: Igal Liberman <Igal.Liberman@freescale.com>
> ---
>  drivers/net/ethernet/freescale/fman/Kconfig        |   35 +
>  drivers/net/ethernet/freescale/fman/Makefile       |    2 +-
>  drivers/net/ethernet/freescale/fman/fm.c           | 1406 
> ++++++++++++++++++++
>  drivers/net/ethernet/freescale/fman/fm.h           |  394 ++++++
>  drivers/net/ethernet/freescale/fman/fm_common.h    |  142 ++
>  drivers/net/ethernet/freescale/fman/fm_drv.c       |  701 ++++++++++
>  drivers/net/ethernet/freescale/fman/fm_drv.h       |  116 ++
>  drivers/net/ethernet/freescale/fman/inc/enet_ext.h |  199 +++
>  drivers/net/ethernet/freescale/fman/inc/fm_ext.h   |  488 +++++++
>  .../net/ethernet/freescale/fman/inc/fsl_fman_drv.h |   99 ++
>  drivers/net/ethernet/freescale/fman/inc/service.h  |   55 +
>  11 files changed, 3636 insertions(+), 1 deletion(-)
>  create mode 100644 drivers/net/ethernet/freescale/fman/fm.c
>  create mode 100644 drivers/net/ethernet/freescale/fman/fm.h
>  create mode 100644 drivers/net/ethernet/freescale/fman/fm_common.h
>  create mode 100644 drivers/net/ethernet/freescale/fman/fm_drv.c
>  create mode 100644 drivers/net/ethernet/freescale/fman/fm_drv.h
>  create mode 100644 drivers/net/ethernet/freescale/fman/inc/enet_ext.h
>  create mode 100644 drivers/net/ethernet/freescale/fman/inc/fm_ext.h
>  create mode 100644 drivers/net/ethernet/freescale/fman/inc/fsl_fman_drv.h
>  create mode 100644 drivers/net/ethernet/freescale/fman/inc/service.h

Again, please start with something pared down, without extraneous features, 
but *with* enough functionality to actually pass packets around.  Getting 
this thing into decent shape is going to be hard enough without carrying 
around the excess baggage.

> diff --git a/drivers/net/ethernet/freescale/fman/Kconfig 
> b/drivers/net/ethernet/freescale/fman/Kconfig
> index 825a0d5..12c75bfd 100644
> --- a/drivers/net/ethernet/freescale/fman/Kconfig
> +++ b/drivers/net/ethernet/freescale/fman/Kconfig
> @@ -7,3 +7,38 @@ config FSL_FMAN
>               Freescale Data-Path Acceleration Architecture Frame Manager
>               (FMan) support
>  
> +if FSL_FMAN
> +
> +config FSL_FM_MAX_FRAME_SIZE
> +     int "Maximum L2 frame size"
> +     range 64 9600
> +     default "1522"
> +     help
> +             Configure this in relation to the maximum possible MTU of your
> +             network configuration. In particular, one would need to
> +             increase this value in order to use jumbo frames.
> +             FSL_FM_MAX_FRAME_SIZE must accommodate the Ethernet FCS
> +             (4 bytes) and one ETH+VLAN header (18 bytes), to a total of
> +             22 bytes in excess of the desired L3 MTU.
> +
> +             Note that having too large a FSL_FM_MAX_FRAME_SIZE (much larger
> +             than the actual MTU) may lead to buffer exhaustion, especially
> +             in the case of badly fragmented datagrams on the Rx path.
> +             Conversely, having a FSL_FM_MAX_FRAME_SIZE smaller than the
> +             actual MTU will lead to frames being dropped.

Scatter gather can't be used for jumbo frames?

Why is this a compile-time option?

> +
> +config FSL_FM_RX_EXTRA_HEADROOM
> +     int "Add extra headroom at beginning of data buffers"
> +     range 16 384
> +     default "64"
> +     help
> +             Configure this to tell the Frame Manager to reserve some extra
> +             space at the beginning of a data buffer on the receive path,
> +             before Internal Context fields are copied. This is in addition
> +             to the private data area already reserved for driver internal
> +             use. The provided value must be a multiple of 16.
> +
> +             This option does not affect in any way the layout of
> +             transmitted buffers.

There's nothing here to indicate when a user would want to do this.

Why is this a compile-time option?

> +             /* FManV3H */
> +             else if (minor == 0 || minor == 2 || minor == 3) {
> +                     intg->fm_muram_size             = 384 * 1024;
> +                     intg->fm_iram_size              = 64 * 1024;
> +                     intg->fm_num_of_ctrl            = 4;
> +
> +                     intg->bmi_max_num_of_tasks      = 128;
> +                     intg->bmi_max_num_of_dmas       = 84;
> +
> +                     intg->num_of_rx_ports           = 8;
> +             } else {
> +                     pr_err("Unsupported FManv3 version\n");
> +                     kfree(intg);
> +                     return NULL;
> +             }
> +
> +             break;
> +     default:
> +             pr_err("Unsupported FMan version\n");
> +             kfree(intg);
> +             return NULL;
> +     }

Don't duplicate error paths.  Use goto like the rest of the kernel.

> +
> +     intg->bmi_max_fifo_size = intg->fm_muram_size;
> +
> +     return intg;
> +}
> +
> +static int is_init_done(struct fman_cfg *p_fm_drv_parameters)

No Hungarian notation.  Check throughout the patchset.

> +{
> +     /* Checks if FMan driver parameters were initialized */
> +     if (!p_fm_drv_parameters)
> +             return 0;
> +     return -EINVAL;
> +}

The name makes it sound like it returns a boolean, but instead it returns 
either 0 or -EINVAL?  Why do you need this wrapper just to do a NULL-pointer 
check?

> +static void free_init_resources(struct fm_t *p_fm)
> +{
> +     if (p_fm->cam_offset)
> +             fm_muram_free_mem(p_fm->p_muram, p_fm->cam_offset,
> +                               p_fm->cam_size);
> +     if (p_fm->fifo_offset)
> +             fm_muram_free_mem(p_fm->p_muram, p_fm->fifo_offset,
> +                               p_fm->fifo_size);
> +}
> +
> +static bool is_fman_ctrl_code_loaded(struct fm_t *p_fm)
> +{
> +     struct fm_iram_regs_t __iomem *p_iram;
> +
> +     p_iram = (struct fm_iram_regs_t __iomem *)UINT_TO_PTR(p_fm->base_addr +
> +                                                    FM_MM_IMEM);
> +
> +     return (bool)!!(in_be32(&p_iram->iready) & IRAM_READY);
> +}
> +
> +static int check_fm_parameters(struct fm_t *p_fm)
> +{
> +     if (is_fman_ctrl_code_loaded(p_fm) && !p_fm->reset_on_init) {
> +             pr_err("Old FMan CTRL code is loaded; FM must be reset!\n");
> +             return -EDOM;
> +     }
> +     if (p_fm->p_fm_state_struct->rev_info.major_rev < 6) {
> +             if (!p_fm->p_fm_drv_param->dma_axi_dbg_num_of_beats ||
> +                 (p_fm->p_fm_drv_param->dma_axi_dbg_num_of_beats >
> +                     DMA_MODE_MAX_AXI_DBG_NUM_OF_BEATS)) {
> +                     pr_err("axiDbgNumOfBeats has to be in the range 1 - %d\n",
> +                            DMA_MODE_MAX_AXI_DBG_NUM_OF_BEATS);
> +                     return -EDOM;
> +             }
> +     }
> +     if (p_fm->p_fm_drv_param->dma_cam_num_of_entries %
> +         DMA_CAM_UNITS) {
> +             pr_err("dma_cam_num_of_entries has to be divisble by %d\n",
> +                    DMA_CAM_UNITS);
> +             return -EDOM;
> +     }
> +     if (p_fm->p_fm_drv_param->dma_comm_qtsh_asrt_emer >
> +         p_fm->intg->dma_thresh_max_commq) {
> +             pr_err("dma_comm_qtsh_asrt_emer can not be larger than %d\n",
> +                    p_fm->intg->dma_thresh_max_commq);
> +             return -EDOM;
> +     }
> +     if (p_fm->p_fm_drv_param->dma_comm_qtsh_clr_emer >
> +         p_fm->intg->dma_thresh_max_commq) {
> +             pr_err("dma_comm_qtsh_clr_emer can not be larger than %d\n",
> +                    p_fm->intg->dma_thresh_max_commq);
> +             return -EDOM;
> +     }
> +     if (p_fm->p_fm_drv_param->dma_comm_qtsh_clr_emer >=
> +         p_fm->p_fm_drv_param->dma_comm_qtsh_asrt_emer) {
> +             pr_err("dma_comm_qtsh_clr_emer must be smaller than 
> dma_comm_qtsh_asrt_emer\n");
> +             return -EDOM;
> +     }
> +     if (p_fm->p_fm_state_struct->rev_info.major_rev < 6) {
> +             if (p_fm->p_fm_drv_param->dma_read_buf_tsh_asrt_emer >
> +                 p_fm->intg->dma_thresh_max_buf) {
> +                     pr_err("dma_read_buf_tsh_asrt_emer can not be larger than %d\n",
> +                            p_fm->intg->dma_thresh_max_buf);
> +                     return -EDOM;
> +             }
> +             if (p_fm->p_fm_drv_param->dma_read_buf_tsh_clr_emer >
> +                   p_fm->intg->dma_thresh_max_buf) {
> +                     pr_err("dma_read_buf_tsh_clr_emer can not be larger than %d\n",
> +                            p_fm->intg->dma_thresh_max_buf);
> +                     return -EDOM;
> +             }
> +             if (p_fm->p_fm_drv_param->dma_read_buf_tsh_clr_emer >=
> +                   p_fm->p_fm_drv_param->dma_read_buf_tsh_asrt_emer) {
> +                     pr_err("dma_read_buf_tsh_clr_emer must be < 
> dma_read_buf_tsh_asrt_emer\n");
> +                     return -EDOM;
> +             }
> +             if (p_fm->p_fm_drv_param->dma_write_buf_tsh_asrt_emer >
> +                   p_fm->intg->dma_thresh_max_buf) {
> +                     pr_err("dma_write_buf_tsh_asrt_emer can not be larger than %d\n",
> +                            p_fm->intg->dma_thresh_max_buf);
> +                     return -EDOM;
> +             }
> +             if (p_fm->p_fm_drv_param->dma_write_buf_tsh_clr_emer >
> +                   p_fm->intg->dma_thresh_max_buf) {
> +                     pr_err("dma_write_buf_tsh_clr_emer can not be larger than %d\n",
> +                            p_fm->intg->dma_thresh_max_buf);
> +                     return -EDOM;
> +             }
> +             if (p_fm->p_fm_drv_param->dma_write_buf_tsh_clr_emer >=
> +                   p_fm->p_fm_drv_param->dma_write_buf_tsh_asrt_emer) {
> +                     pr_err("dma_write_buf_tsh_clr_emer has to be less than 
> dma_write_buf_tsh_asrt_emer\n");
> +                     return -EDOM;
> +             }
> +     } else {
> +             if ((p_fm->p_fm_drv_param->dma_dbg_cnt_mode ==
> +                             E_FMAN_DMA_DBG_CNT_INT_READ_EM) ||
> +                     (p_fm->p_fm_drv_param->dma_dbg_cnt_mode ==
> +                             E_FMAN_DMA_DBG_CNT_INT_WRITE_EM) ||
> +                     (p_fm->p_fm_drv_param->dma_dbg_cnt_mode ==
> +                             E_FMAN_DMA_DBG_CNT_RAW_WAR_PROT)) {
> +                     pr_err("dma_dbg_cnt_mode value not supported by this integration.\n");
> +                     return -EDOM;
> +             }
> +             if ((p_fm->p_fm_drv_param->dma_emergency_bus_select ==
> +                    FM_DMA_MURAM_READ_EMERGENCY) ||
> +                   (p_fm->p_fm_drv_param->dma_emergency_bus_select ==
> +                    FM_DMA_MURAM_WRITE_EMERGENCY)) {
> +                     pr_err("emergencyBusSelect value not supported by this integration.\n");
> +                     return -EDOM;
> +             }

What do you mean by "integration"?

Why are there still camelCaps in strings?

> +static void unimplemented_isr(void __maybe_unused *h_src_arg)
> +{
> +     pr_err("Unimplemented ISR!\n");
> +}
> +
> +

This message is severely lacking in context.

> +static int init_fm_dma(struct fm_t *p_fm)
> +{
> +     int err;
> +
> +     err = (int)fman_dma_init(p_fm->p_fm_dma_regs,
> +                                  p_fm->p_fm_drv_param);
> +     if (err != 0)
> +             return err;
> +
> +     /* Allocate MURAM for CAM */
> +     p_fm->cam_size = (uint32_t)(p_fm->p_fm_drv_param->
> +                                     dma_cam_num_of_entries *
> +                                     DMA_CAM_SIZEOF_ENTRY);
> +     p_fm->cam_offset = fm_muram_alloc(p_fm->p_muram, p_fm->cam_size);
> +     if (IS_ERR_VALUE(p_fm->cam_offset)) {
> +             pr_err("MURAM alloc for DMA CAM failed\n");
> +             return -ENOMEM;
> +     }
> +
> +     if (p_fm->p_fm_state_struct->rev_info.major_rev == 2) {
> +             uintptr_t cam_base_addr;

u32 __iomem *cam_base_addr;

> +
> +             fm_muram_free_mem(p_fm->p_muram, p_fm->cam_offset,
> +                               p_fm->cam_size);
> +
> +             p_fm->cam_size =
> +                     p_fm->p_fm_drv_param->dma_cam_num_of_entries * 72 + 128;
> +             p_fm->cam_offset = fm_muram_alloc(p_fm->p_muram, (uint32_t)
> +                                                  p_fm->cam_size);
> +                     pr_err("MURAM alloc for DMA CAM failed\n");
> +                     return -ENOMEM;
> +             }
> +
> +             cam_base_addr = fm_muram_offset_to_vbase(p_fm->p_muram,
> +                                                      p_fm->cam_offset);
> +             switch (p_fm->p_fm_drv_param->dma_cam_num_of_entries) {
> +             case (8):
> +                     out_be32((uint32_t __iomem *)cam_base_addr,
> +                              0xff000000);
> +                     break;
> +             case (16):
> +                     out_be32((uint32_t __iomem *)cam_base_addr,
> +                              0xffff0000);
> +                     break;
> +             case (24):
> +                     out_be32((uint32_t __iomem *)cam_base_addr,
> +                              0xffffff00);
> +                     break;
> +             case (32):
> +                     out_be32((uint32_t __iomem *)cam_base_addr,
> +                              0xffffffff);
> +                     break;
> +             default:
> +                     pr_err("wrong dma_cam_num_of_entries\n");
> +                     return -EDOM;
> +             }
> +     }
> +

Please don't use -EDOM for situations where the entire rest of the kernel 
uses -EINVAL.

Unnecessary parentheses.

Couldn't this just be replaced with:
        out_be32(cam_base_addr, ~(1 << (32 - dma_cam_num_of_entries)) - 1);
?

> void *fm_config(struct fm_params_t *p_fm_param)
> +{
> +     struct fm_t *p_fm;
> +     uintptr_t base_addr;
> +
> +     if (!((p_fm_param->firmware.p_code && p_fm_param->firmware.size) ||
> +           (!p_fm_param->firmware.p_code && !p_fm_param->firmware.size)))
> +             return NULL;
> +
> +     base_addr = p_fm_param->base_addr;
> +
> +     /* Allocate FM structure */
> +     p_fm = kzalloc(sizeof(*p_fm), GFP_KERNEL);
> +     if (!p_fm)
> +             return NULL;
> +
> +     p_fm->p_fm_state_struct = kzalloc(sizeof(*p_fm->p_fm_state_struct),
> +                                              GFP_KERNEL);
> +     if (!p_fm->p_fm_state_struct) {
> +             kfree(p_fm);
> +             pr_err("FM Status structure\n");
> +             return NULL;
> +     }

It's generally not recommended to print an error on memory allocation 
failure, but this message doesn't even make sense.

> +     if (p_fm->p_fm_state_struct->rev_info.major_rev < 6 &&
> +         p_fm->p_fm_state_struct->rev_info.major_rev != 4 &&
> +         p_fm->reset_on_init) {
> +             err = fw_not_reset_erratum_bugzilla6173wa(p_fm);
> +             if (err != 0)
> +                     return err;

bugzilla6173wa?

> +     } else {
> +             /* Reset the FM if required. */
> +             if (p_fm->reset_on_init) {
> +                     u32 svr = mfspr(SPRN_SVR);
> +
> +                     if (((SVR_SOC_VER(svr) == SVR_T4240 &&
> +                           SVR_REV(svr) > 0x10)) ||
> +                             ((SVR_SOC_VER(svr) == SVR_T4160 &&
> +                               SVR_REV(svr) > 0x10)) ||
> +                             ((SVR_SOC_VER(svr) == SVR_T4080 &&
> +                               SVR_REV(svr) > 0x10)) ||
> +                             (SVR_SOC_VER(svr) == SVR_T2080) ||
> +                             (SVR_SOC_VER(svr) == SVR_T2081)) {
> +                             pr_debug("Hack: No FM reset!\n");
                if (IS_ERR_VALUE(p_fm->cam_offset)) {
Why?

> +                     } else {
> +                             out_be32(&p_fm->p_fm_fpm_regs->fm_rstc,
> +                                      FPM_RSTC_FM_RESET);
> +                             /* Memory barrier */
> +                             mb();
> +                             usleep_range(100, 101);
> +                     }
> +
> +                     if (fman_is_qmi_halt_not_busy_state(
> +                             p_fm->p_fm_qmi_regs)) {

Don't align continuation lines with the if-body.

> +                             fman_resume(p_fm->p_fm_fpm_regs);
> +                             usleep_range(100, 101);
> +                     }
> +             }
> +

Why such a narrow range in usleep_range()?

> +/* Macro for calling MAC error interrupt handler */
> +#define FM_M_CALL_MAC_ERR_ISR(_p_fm, _id) \
> +     (_p_fm->intr_mng[(enum fm_inter_module_event)(FM_EV_ERR_MAC0 + _id)]. \
> +     f_isr(p_fm->intr_mng[(enum fm_inter_module_event)\
> +     (FM_EV_ERR_MAC0 + _id)].h_src_handle))

Why are you casting to an enum just to use it as an array index?

> +int fm_set_exception(struct fm_t *p_fm, enum fm_exceptions exception,
> +                  bool enable)
> +{
> +     uint32_t bit_mask = 0;
> +     enum fman_exceptions fsl_exception;
> +     struct fman_rg fman_rg;
> +     int ret;
> +
> +     ret = is_init_done(p_fm->p_fm_drv_param);
> +     if (ret)
> +             return ret;
> +
> +     fman_rg.bmi_rg = p_fm->p_fm_bmi_regs;
> +     fman_rg.qmi_rg = p_fm->p_fm_qmi_regs;
> +     fman_rg.fpm_rg = p_fm->p_fm_fpm_regs;
> +     fman_rg.dma_rg = p_fm->p_fm_dma_regs;
> +
> +     GET_EXCEPTION_FLAG(bit_mask, exception);
> +     if (bit_mask) {
> +             if (enable)
> +                     p_fm->p_fm_state_struct->exceptions |= bit_mask;
> +             else
> +                     p_fm->p_fm_state_struct->exceptions &= ~bit_mask;
> +
> +             FMAN_EXCEPTION_TRANS(fsl_exception, exception);
> +
> +             return (int)fman_set_exception(&fman_rg,
> +                                            fsl_exception, enable);

fman_set_exception() already returns int.

> +     } else {
> +             pr_err("Undefined exceptioni\n");

Typo.

> +             return -EDOM;

Math argument out of range of function?

What math function is involved?

> +/* Prevents the use of TX port 1 with OP port 0 for FM Major Rev 4 (P1023) 
> */
> 
> +#define FM_LOW_END_RESTRICTION

This is never used (and would be a multiplatform violation if it were).

> +
> +#define GET_EXCEPTION_FLAG(bit_mask, exception)                      \
> +do {                                                                 \
> +     switch ((int)exception) {                                       \
> +     case FM_EX_DMA_BUS_ERROR:                                       \
> +             bit_mask = FM_EX_DMA_BUS_ERROR;                 \
> +             break;                                                  \
> +     case FM_EX_DMA_SINGLE_PORT_ECC:                         \
> +             bit_mask = FM_EX_DMA_SINGLE_PORT_ECC;                   \
> +             break;                                                  \
> +     case FM_EX_DMA_READ_ECC:                                        \
> +             bit_mask = FM_EX_DMA_READ_ECC;                          \
> +             break;                                                  \
> +     case FM_EX_DMA_SYSTEM_WRITE_ECC:                                \
> +             bit_mask = FM_EX_DMA_SYSTEM_WRITE_ECC;                  \
> +             break;                                                  \
> +     case FM_EX_DMA_FM_WRITE_ECC:                                    \
> +             bit_mask = FM_EX_DMA_FM_WRITE_ECC;                      \
> +             break;                                                  \
> +     case FM_EX_FPM_STALL_ON_TASKS:                                  \
> +             bit_mask = FM_EX_FPM_STALL_ON_TASKS;                    \
> +             break;                                                  \
> +     case FM_EX_FPM_SINGLE_ECC:                                      \
> +             bit_mask = FM_EX_FPM_SINGLE_ECC;                        \
> +             break;                                                  \
> +     case FM_EX_FPM_DOUBLE_ECC:                                      \
> +             bit_mask = FM_EX_FPM_DOUBLE_ECC;                        \
> +             break;                                                  \
> +     case FM_EX_QMI_SINGLE_ECC:                                      \
> +             bit_mask = FM_EX_QMI_SINGLE_ECC;                        \
> +             break;                                                  \
> +     case FM_EX_QMI_DOUBLE_ECC:                                      \
> +             bit_mask = FM_EX_QMI_DOUBLE_ECC;                        \
> +             break;                                                  \
> +     case FM_EX_QMI_DEQ_FROM_UNKNOWN_PORTID:                 \
> +             bit_mask = FM_EX_QMI_DEQ_FROM_UNKNOWN_PORTID;           \
> +             break;                                                  \
> +     case FM_EX_BMI_LIST_RAM_ECC:                                    \
> +             bit_mask = FM_EX_BMI_LIST_RAM_ECC;                      \
> +             break;                                                  \
> +     case FM_EX_BMI_STORAGE_PROFILE_ECC:                             \
> +             bit_mask = FM_EX_BMI_STORAGE_PROFILE_ECC;               \
> +             break;                                                  \
> +     case FM_EX_BMI_STATISTICS_RAM_ECC:                              \
> +             bit_mask = FM_EX_BMI_STATISTICS_RAM_ECC;                \
> +             break;                                                  \
> +     case FM_EX_BMI_DISPATCH_RAM_ECC:                                \
> +             bit_mask = FM_EX_BMI_DISPATCH_RAM_ECC;                  \
> +             break;                                                  \
> +     case FM_EX_IRAM_ECC:                                            \
> +             bit_mask = FM_EX_IRAM_ECC;                              \
> +             break;                                                  \
> +     case FM_EX_MURAM_ECC:                                           \
> +             bit_mask = FM_EX_MURAM_ECC;                             \
> +             break;                                                  \
> +     default:                                                        \
> +             bit_mask = 0;                                           \
> +             break;                                                  \
> +     }                                                               \
> +} while (0)
> +
> +#define GET_FM_MODULE_EVENT(_p_fm, _mod, _id, _intr_type, _event)    \
> +do {                                                                 \
> +     switch (_mod) {                                                 \
> +     case (FM_MOD_PRS):                                              \
> +             if (_id)                                                \
> +                     _event = FM_EV_DUMMY_LAST;                      \
> +             else                                                    \
> +                     event = (_intr_type == FM_INTR_TYPE_ERR) ?      \
> +                     FM_EV_ERR_PRS : FM_EV_PRS;                      \
> +             break;                                                  \
> +     case (FM_MOD_TMR):                                              \
> +             if (_id)                                                \
> +                     _event = FM_EV_DUMMY_LAST;                      \
> +             else                                                    \
> +                     _event = (_intr_type == FM_INTR_TYPE_ERR) ?     \
> +                     FM_EV_DUMMY_LAST : FM_EV_TMR;                   \
> +             break;                                                  \
> +     case (FM_MOD_MAC):                                              \
> +                     _event = (_intr_type == FM_INTR_TYPE_ERR) ?     \
> +                     (FM_EV_ERR_MAC0 + _id) :                        \
> +                     (FM_EV_MAC0 + _id);                             \
> +             break;                                                  \
> +     case (FM_MOD_FMAN_CTRL):                                        \
> +             if (_intr_type == FM_INTR_TYPE_ERR)                     \
> +                     _event = FM_EV_DUMMY_LAST;                      \
> +             else                                                    \
> +                     _event = (FM_EV_FMAN_CTRL_0 + _id);             \
> +             break;                                                  \
> +     default:                                                        \
> +             _event = FM_EV_DUMMY_LAST;                              \
> +             break;                                                  \
> +     }                                                               \
> +} while (0)

Use functions instead of macros wherever possible.

> +/* do not change! if changed, must be disabled for rev1 ! */
> +#define DFLT_VERIFY_UCODE                 false

I know I complained about this last time...


> +
> +#define DFLT_DMA_READ_INT_BUF_LOW(dma_thresh_max_buf)        \
> +     ((dma_thresh_max_buf + 1) / 2)
> +#define DFLT_DMA_READ_INT_BUF_HIGH(dma_thresh_max_buf)       \
> +     ((dma_thresh_max_buf + 1) * 3 / 4)
> +#define DFLT_DMA_WRITE_INT_BUF_LOW(dma_thresh_max_buf)       \
> +     ((dma_thresh_max_buf + 1) / 2)
> +#define DFLT_DMA_WRITE_INT_BUF_HIGH(dma_thresh_max_buf)\
> +     ((dma_thresh_max_buf + 1) * 3 / 4)
> +#define DFLT_DMA_COMM_Q_LOW(major, dma_thresh_max_commq)     \
> +     ((major == 6) ? 0x2A : ((dma_thresh_max_commq + 1) / 2))
> +#define DFLT_DMA_COMM_Q_HIGH(major, dma_thresh_max_commq)    \
> +     ((major == 6) ? 0x3f : ((dma_thresh_max_commq + 1) * 3 / 4))
> +#define DFLT_TOTAL_NUM_OF_TASKS(major, minor, bmi_max_num_of_tasks)  \
> +     ((major == 6) ? ((minor == 1 || minor == 4) ? 59 : 124) :       \
> +     bmi_max_num_of_tasks)

Where do 0x2a, 0x3f, 59, 124, etc come from?  Please define symbolically.

> +#define DFLT_TOTAL_FIFO_SIZE(major, minor)                   \
> +     ((major == 6) ?                                         \
> +     ((minor == 1 || minor == 4) ? (156 * 1024) : (295 * 1024)) :    \
> +     (((major == 2) || (major == 5)) ?                       \
> +     (100 * 1024) : ((major == 4) ?                  \
> +     (46 * 1024) : (122 * 1024))))

This isn't the International Obfuscated C Code Contest.

> 
> +/* Memory Mapped Registers */
> +
> +struct fm_iram_regs_t {
> +     uint32_t iadd;  /* FM IRAM instruction address register */
> +     uint32_t idata;/* FM IRAM instruction data register */
> +     uint32_t itcfg;/* FM IRAM timing config register */
> +     uint32_t iready;/* FM IRAM ready register */
> +     uint8_t res[0x80000 - 0x10];
> +} __attribute__((__packed__));

Why do you need __packed__ on this?

Why do you need the padding on the end?

> +struct fm_t {
> +     uintptr_t base_addr;
> +     char fm_module_name[MODULE_NAME_SIZE];
> +     struct fm_intr_src_t intr_mng[FM_EV_DUMMY_LAST];
> +
> +     struct fman_fpm_regs __iomem *p_fm_fpm_regs;
> +     struct fman_bmi_regs __iomem *p_fm_bmi_regs;
> +     struct fman_qmi_regs __iomem *p_fm_qmi_regs;
> +     struct fman_dma_regs __iomem *p_fm_dma_regs;
> +     struct fman_regs __iomem *p_fm_regs;
> +     fm_exceptions_cb *f_exception;
> +     fm_bus_error_cb *f_bus_error;
> +     void *h_app;            /* Application handle */
> +     spinlock_t *spinlock;

Why is the spinlock dynamically allocated?

> +/* Bootarg used to override the Kconfig FSL_FM_MAX_FRAME_SIZE value */
> +#define FSL_FM_MAX_FRM_BOOTARG     "fsl_fm_max_frm"
> +
> +/* Bootarg used to override FSL_FM_RX_EXTRA_HEADROOM Kconfig value */
> +#define FSL_FM_RX_EXTRA_HEADROOM_BOOTARG  "fsl_fm_rx_extra_headroom"

Is this indirection really needed?

> +/* Extra headroom for Rx buffers.
> + * FMan is instructed to allocate, on the Rx path, this amount of
> + * space at the beginning of a data buffer, beside the DPA private
> + * data area and the IC fields.
> + * Does not impact Tx buffer layout.
> + * Configurable from Kconfig or bootargs. Zero by default, it's needed on
> + * particular forwarding scenarios that add extra headers to the
> + * forwarded frame.
> + */
> +int fsl_fm_rx_extra_headroom = CONFIG_FSL_FM_RX_EXTRA_HEADROOM;

If it's configurable via bootargs, why is the kconfig needed?

> +
> +u16 fm_get_max_frm(void)
> +{
> +     return fsl_fm_max_frm;
> +}
> +EXPORT_SYMBOL(fm_get_max_frm);

fsl_fm_max_frm isn't static, so why is this accessor needed?

> +int fm_get_rx_extra_headroom(void)
> +{
> +     return ALIGN(fsl_fm_rx_extra_headroom, 16);
> +}
> +EXPORT_SYMBOL(fm_get_rx_extra_headroom);

Why not just align it when you set the variable?

> +
> +static int __init fm_set_max_frm(char *str)
> +{
> +     int ret = 0;
> +
> +     ret = get_option(&str, &fsl_fm_max_frm);
> +     if (ret != 1) {
> +             /* This will only work if CONFIG_EARLY_PRINTK is compiled in,
> +              * and something like "earlyprintk=serial,uart0,115200" is
> +              * specified in the bootargs.
> +              */
> +             pr_err("No suitable %s=<int> prop in bootargs; will use the default 
> FSL_FM_MAX_FRAME_SIZE (%d) from Kconfig.\n",
> +                    FSL_FM_MAX_FRM_BOOTARG,
> +                    CONFIG_FSL_FM_MAX_FRAME_SIZE);
> +
> +             fsl_fm_max_frm = CONFIG_FSL_FM_MAX_FRAME_SIZE;
> +             return 1;
> +     }
> +
> +     /* Don't allow invalid bootargs; fallback to the Kconfig value */
> +     if (fsl_fm_max_frm < 64 || fsl_fm_max_frm > 9600) {
> +             pr_err("Invalid %s=%d in bootargs, valid range is 64-9600. Falling back 
> to the FSL_FM_MAX_FRAME_SIZE (%d) from Kconfig.\n",
> +                    FSL_FM_MAX_FRM_BOOTARG, fsl_fm_max_frm,
> +                    CONFIG_FSL_FM_MAX_FRAME_SIZE);
> +
> +             fsl_fm_max_frm = CONFIG_FSL_FM_MAX_FRAME_SIZE;
> +             return 1;
> +     }
> +
> +     pr_info("Using fsl_fm_max_frm=%d from bootargs\n", fsl_fm_max_frm);
> +     return 0;
> +}
> +early_param(FSL_FM_MAX_FRM_BOOTARG, fm_set_max_frm);
> +
> +static int __init fm_set_rx_extra_headroom(char *str)
> +{
> +     int ret;
> +
> +     ret = get_option(&str, &fsl_fm_rx_extra_headroom);
> +
> +     if (ret != 1) {
> +             pr_err("No suitable %s=<int> prop in bootargs; will use the default 
> FSL_FM_RX_EXTRA_HEADROOM (%d) from Kconfig.\n",
> +                    FSL_FM_RX_EXTRA_HEADROOM_BOOTARG,
> +                    CONFIG_FSL_FM_RX_EXTRA_HEADROOM);
> +             fsl_fm_rx_extra_headroom = CONFIG_FSL_FM_RX_EXTRA_HEADROOM;
> +
> +             return 1;
> +     }
> +
> +     if (fsl_fm_rx_extra_headroom < FSL_FM_RX_EXTRA_HEADROOM_MIN ||
> +         fsl_fm_rx_extra_headroom > FSL_FM_RX_EXTRA_HEADROOM_MAX) {
> +             pr_err("Invalid value for %s=%d prop in bootargs; will use the default 
> FSL_FM_RX_EXTRA_HEADROOM (%d) from Kconfig.\n",
> +                    FSL_FM_RX_EXTRA_HEADROOM_BOOTARG,
> +                    fsl_fm_rx_extra_headroom,
> +                    CONFIG_FSL_FM_RX_EXTRA_HEADROOM);
> +             fsl_fm_rx_extra_headroom = CONFIG_FSL_FM_RX_EXTRA_HEADROOM;
> +     }
> +
> +     pr_info("Using fsl_fm_rx_extra_headroom=%d from bootargs\n",
> +             fsl_fm_rx_extra_headroom);

This is unnecessarily verbose.

> +
> +     return 0;
> +}
> +early_param(FSL_FM_RX_EXTRA_HEADROOM_BOOTARG, fm_set_rx_extra_headroom);

Why early?

> +static irqreturn_t fm_err_irq(int irq, void *_dev)
> +{
> +     struct fm_drv_t *fm_drv = (struct fm_drv_t *)_dev;
> +
> +     if (!fm_drv || !fm_drv->h_dev)
> +             return IRQ_NONE;

Why would you request the IRQ if either of these are NULL?

> +static const struct qe_firmware *find_fman_microcode(void)
> +{
> +     static const struct qe_firmware *uc_patch;
> +     struct device_node *np;
> +
> +     if (uc_patch)
> +             return uc_patch;
> +
> +     /* The firmware should be inside the device tree. */
> +     np = of_find_compatible_node(NULL, NULL, "fsl,fman-firmware");
> +     if (np) {
> +             uc_patch = of_get_property(np, "fsl,firmware", NULL);

I don't see any binding for this.

> +static int fill_qman_channhels_info(struct fm_drv_t *fm_drv)

"channhels"?


> +static struct fm_drv_t *read_fm_dev_tree_node(struct platform_device 
> *of_dev)
> +{
> +     struct fm_drv_t *fm_drv;
> +     struct device_node *fm_node, *dev_node;
> +     struct of_device_id name;
> +     struct resource res;
> +     const uint32_t *uint32_prop;
> +     int lenp, err;
> +     struct clk *clk;
> +     u32 clk_rate;
> +
> +     fm_node = of_node_get(of_dev->dev.of_node);
> +
> +     uint32_prop = (uint32_t *)of_get_property(fm_node, "cell-index",
> +                                               &lenp);
> +     if (unlikely(!uint32_prop)) {
> +             pr_err("of_get_property(%s, cell-index) failed\n",
> +                    fm_node->full_name);
> +             goto _return_null;
> +     }
> +     if (WARN_ON(lenp != sizeof(uint32_t)))
> +             return NULL;
> +
> +     fm_drv = kzalloc(sizeof(*fm_drv), GFP_KERNEL);
> +     if (!fm_drv)
> +             goto _return_null;
> +
> +     fm_drv->dev = &of_dev->dev;
> +     fm_drv->id = (u8)*uint32_prop;
> +
> +     /* Get the FM interrupt */
> +     fm_drv->irq = of_irq_to_resource(fm_node, 0, NULL);
> +     if (unlikely(fm_drv->irq == 0)) {
> +             pr_err("of_irq_to_resource() = %d\n", NO_IRQ);
> +             goto _return_null;
> +     }
> +
> +     /* Get the FM error interrupt */
> +     fm_drv->err_irq = of_irq_to_resource(fm_node, 1, NULL);
> +
> +     /* Get the FM address */
> +     err = of_address_to_resource(fm_node, 0, &res);
> +     if (unlikely(err < 0)) {
> +             pr_err("of_address_to_resource() = %d\n", err);
> +             goto _return_null;
> +     }
> +
> +     fm_drv->fm_base_addr = 0;
> +     fm_drv->fm_phys_base_addr = res.start;
> +     fm_drv->fm_mem_size = res.end + 1 - res.start;
> +

Why are you using these OF functions rather than using platform_device 
mechanisms?

> +     clk = clk_get(fm_drv->dev, fm_drv->id == 0 ? "fm0clk" : "fm1clk");
> +     if (IS_ERR(clk)) {
> +             pr_err("Failed to get FM%d clock structure\n", fm_drv->id);
> +             goto _return_null;
> +     }

Get the clock from the clocks property of the device tree node, not by 
hardcoding what you think the clock's name will be.

> +     uint32_prop = (uint32_t *)of_get_property(fm_node,
> +                                               "fsl,qman-channel-range",
> +                                               &lenp);
> 

Don't cast away the const.

> +     if (unlikely(!uint32_prop)) {

Don't use unlikely() in paths that aren't performance-critical.

> +     /* Get the MURAM base address and size */
> +     memset(&name, 0, sizeof(name));
> +     if (WARN_ON(strlen("muram") >= sizeof(name.name)))
> +             goto _return_null;
> +     strcpy(name.name, "muram");
> +     if (WARN_ON(strlen("fsl,fman-muram") >= sizeof(name.compatible)))
> +             goto _return_null;
> +     strcpy(name.compatible, "fsl,fman-muram");
> +     for_each_child_of_node(fm_node, dev_node) {
> +             if (likely(of_match_node(&name, dev_node))) {

Why not just define the match struct statically?

> +#ifndef __SERVICE_h
> +#define __SERVICE_h
> +
> +#include <linux/version.h>

What do you need this for?

> +
> +#include <linux/kernel.h>
> +#include <linux/types.h>
> +#include <linux/io.h>

What do you use in this file from linux/io.h?

> +/* Define ASSERT condition */
> +#undef ASSERT
> +#define ASSERT(x)       WARN_ON(!(x))

Why not just use WARN_ON directly?

> +/* Pointers Manipulation */
> +#define UINT_TO_PTR(_val)           ((void __iomem *)(uintptr_t)(_val))

Why are you doing so much of this that you need macros for it?

UINT_TO_PTR seems like it could be hiding 64-bit-cleanliness bugs.  From 
looking at the places it's used, it certainly would be if the value fed into 
it were actually "unsigned int".

Just define base_addr and such as "void __iomem *".

> +#define PTR_MOVE(_ptr, _offset)     (void *)((uint8_t *)(_ptr) + (_offset))

I don't see this used anywhere.  Likewise IN_RANGE and ILLEGAL_BASE.

-Scott
