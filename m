From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 08/12] fsl/fman: Add Frame Manager support
Date: Thu, 11 Jun 2015 10:55:56 +0200
Message-ID: <1434012956.2271.58.camel@x220>
References: <1433949712-5648-1-git-send-email-madalin.bucur@freescale.com>
	 <1433949712-5648-2-git-send-email-madalin.bucur@freescale.com>
	 <1433949712-5648-3-git-send-email-madalin.bucur@freescale.com>
	 <1433949712-5648-4-git-send-email-madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, scottwood@freescale.com,
	Igal Liberman <Igal.Liberman@freescale.com>
To: madalin.bucur@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb2-smtp-cloud6.xs4all.net ([194.109.24.28]:33867 "EHLO
	lb2-smtp-cloud6.xs4all.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750883AbbFKI4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 04:56:03 -0400
In-Reply-To: <1433949712-5648-4-git-send-email-madalin.bucur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

You should note that I started with scanning this patch for basic, say,
build system issues. Which I did find. But then I kept spotting all kind
of oddities. After a while I stopped looking closely. So, to note
something, I haven't yet looked into the 24 symbols this series exports.
There might be a reason for all 24 of them, but I just thought it a bit
suspect.

But, anyhow, my guess is this series needs a close look or two before
the people understanding ethernet drivers (I'm not one of them) will
consider reviewing it for more substantial issues.

On Wed, 2015-06-10 at 18:21 +0300, Madalin Bucur wrote:
> --- a/drivers/net/ethernet/freescale/fman/Kconfig
> +++ b/drivers/net/ethernet/freescale/fman/Kconfig
 
> +if FSL_FMAN
> +
> +config FSL_FM_MAX_FRAME_SIZE
> +	int "Maximum L2 frame size"
> +	depends on FSL_FMAN

This dependency is already provided through "if FSL_MAN" above.

> +	range 64 9600
> +	default "1522"
> +	help
> +		Configure this in relation to the maximum possible MTU of your
> +		network configuration. In particular, one would need to
> +		increase this value in order to use jumbo frames.
> +		FSL_FM_MAX_FRAME_SIZE must accommodate the Ethernet FCS
> +		(4 bytes) and one ETH+VLAN header (18 bytes), to a total of
> +		22 bytes in excess of the desired L3 MTU.
> +
> +		Note that having too large a FSL_FM_MAX_FRAME_SIZE (much larger
> +		than the actual MTU) may lead to buffer exhaustion, especially
> +		in the case of badly fragmented datagrams on the Rx path.
> +		Conversely, having a FSL_FM_MAX_FRAME_SIZE smaller than the
> +		actual MTU will lead to frames being dropped.
> +
> +config FSL_FM_RX_EXTRA_HEADROOM
> +	int "Add extra headroom at beginning of data buffers"
> +	depends on FSL_FMAN

Ditto.

> +	range 16 384
> +	default "64"
> +	help
> +		Configure this to tell the Frame Manager to reserve some extra
> +		space at the beginning of a data buffer on the receive path,
> +		before Internal Context fields are copied. This is in addition
> +		to the private data area already reserved for driver internal
> +		use. The provided value must be a multiple of 16.
> +
> +		This option does not affect in any way the layout of
> +		transmitted buffers.
> +
> +endif	# FSL_FMAN

> --- a/drivers/net/ethernet/freescale/fman/Makefile
> +++ b/drivers/net/ethernet/freescale/fman/Makefile
>  
>  obj-y		+= fsl_fman.o
>  
> -fsl_fman-objs	:= fman.o fm_muram.o
> +fsl_fman-objs	:= fman.o fm_muram.o fm.o fm_drv.o

> --- /dev/null
> +++ b/drivers/net/ethernet/freescale/fman/fm.c

> +/* static functions */

There's no need to tell us that.

> +static int check_fm_parameters(struct fm_t *p_fm)
> +{

> +#ifdef FM_AID_MODE_NO_TNUM_SW005

I think this is always defined (I already deleted that part of the
patch, so perhaps I'm missing some subtle issue).

> +		if (p_fm->p_fm_state_struct->rev_info.major_rev >= 6 &&
> +		    p_fm->p_fm_drv_param->dma_aid_mode !=
> +		    E_FMAN_DMA_AID_OUT_PORT_ID) {
> +			pr_err("dma_aid_mode not supported by this integration.\n");
> +			return -EDOM;
> +		}
> +#endif /* FM_AID_MODE_NO_TNUM_SW005 */

> +#ifdef FM_HAS_TOTAL_DMAS

Ditto.

> +	if ((p_fm->p_fm_state_struct->rev_info.major_rev < 6) &&
> +	    (!p_fm->p_fm_state_struct->max_num_of_open_dmas ||
> +	     (p_fm->p_fm_state_struct->max_num_of_open_dmas >
> +		p_fm->intg->bmi_max_num_of_dmas))) {
> +		pr_err("max_num_of_open_dmas number has to be in the range 1 - %d\n",
> +		       p_fm->intg->bmi_max_num_of_dmas);
> +		return -EDOM;
> +	}
> +#endif /* FM_HAS_TOTAL_DMAS */

> +#ifdef FM_NO_WATCHDOG

Ditto. I'll stop checking for this stuff now. Please clean them up (or
show me that I'm wrong).

> +	if ((p_fm->p_fm_state_struct->rev_info.major_rev == 2) &&
> +	    (p_fm->p_fm_drv_param->dma_watchdog)) {
> +		pr_err("watchdog!\n");
> +		return -EINVAL;
> +	}
> +#endif /* FM_NO_WATCHDOG */

> +/*     fm_init
> + *
> + *  Initializes the FM module
> + *
> + * @Param[in]     p_fm - FM module descriptor
> + *
> + * @Return        0 on success; Error code otherwise.
> + */

I know little about kerneldoc, but this is not kerneldoc, right?

> +/* fm_free
> + * Frees all resources that were assigned to FM module.
> + * Calling this routine invalidates the descriptor.
> + * p_fm - FM module descriptor
> + *Return        0 on success; Error code otherwise.
> + */

Ditto.

> +void fm_event_isr(struct fm_t *p_fm)
> +{
> +#define FM_M_CALL_MAC_ISR(_id)    \
> +	(p_fm->intr_mng[(enum fm_inter_module_event)(FM_EV_MAC0 + _id)]. \
> +	f_isr(p_fm->intr_mng[(enum fm_inter_module_event)(FM_EV_MAC0 + _id)] \
> +	.h_src_handle))
> +	uint32_t pending;
> +	int ret;
> +	struct fman_fpm_regs __iomem *fpm_rg;

There must be a nicer way than to put a #define just before the local
variables.

> +int fm_error_isr(struct fm_t *p_fm)
> +{
> +#define FM_M_CALL_MAC_ERR_ISR(_id) \
> +	(p_fm->intr_mng[(enum fm_inter_module_event)(FM_EV_ERR_MAC0 + _id)]. \
> +	f_isr(p_fm->intr_mng[(enum fm_inter_module_event)\
> +	(FM_EV_ERR_MAC0 + _id)].h_src_handle))
> +	uint32_t pending;
> +	struct fman_fpm_regs __iomem *fpm_rg;
> +	int ret;

Ditto.

> --- /dev/null
> +++ b/drivers/net/ethernet/freescale/fman/fm.h

> +/* list_object
> + * Macro to get the struct (object) for this entry.
> + * type   - The type of the struct (object) this list
> + * is embedded in.
> + * member - The name of the struct list_head object
> + * within the struct.
> + * Return        The structure pointer for this entry.
> + */
> +#define member_offset(type, member) (PTR_TO_UINT(&((type *)0)->member))
> +#define list_object(p_list, type, member) \
> +((type *)((char *)(p_list) - member_offset(type, member)))

Aren't there any global #defines that already do (something like) this?

> +++ b/drivers/net/ethernet/freescale/fman/fm_drv.c

> +static void destroy_fm_dev(struct fm_drv_t *p_fm_drv)
> +{
> +	kfree(p_fm_drv);
> +}

Why do you wrap kfree() here? 

> +/**
> +*find_fman_microcode - find the Fman microcode
> + *
> +*This function returns a pointer to the QE Firmware blob that holds
> +*the Fman microcode.  We use the QE Firmware structure because Fman microcode
> +*is similar to QE microcode, so there's no point in defining a new layout.
> + *
> +*Current versions of U-Boot embed the Fman firmware into the device tree,
> +*so we check for that first.  Each Fman node in the device tree contains a
> +*node or a pointer to node that holds the firmware.  Technically, we should
> +*be fetching the firmware node for the current Fman, but we don't have that
> +*information any more, so we assume that there is only one firmware node in
> +*the device tree, and that all Fmen use the same firmware.
> + */

/**
*new_style - a new comment style
 *
*This is a new style of comment formatting.
*Do people like it?
 */

> +static int /*__devinit*/ fm_probe(struct platform_device *of_dev)

Please remove commented out code before submitting.

> +static const struct of_device_id fm_match[] = {
> +	{
> +	 .compatible = "fsl,fman"},
> +	{}
> +};
> +
> +#ifndef MODULE
> +MODULE_DEVICE_TABLE(of, fm_match);
> +#endif /* !MODULE */

include/linux/module.h reads (summarized):
    #ifdef MODULE
    #define MODULE_DEVICE_TABLE(type, name)                                 \
    extern const typeof(name) __mod_##type##__##name##_device_table         \
      __attribute__ ((unused, alias(__stringify(name))))
    #else  /* !MODULE */
    #define MODULE_DEVICE_TABLE(type, name)
    #endif

So please drop the #ifndef wrapper.

> +void *fm_drv_init(void)

static.

> +{
> +	memset(&fm_drvs, 0, sizeof(fm_drvs));
> +	mutex_init(&fm_drv_mutex);
> +
> +	/* Register to the DTB for basic FM API */
> +	platform_driver_register(&fm_driver);
> +
> +	return &fm_drvs;
> +}
> +
> +int fm_drv_free(void *p_fm_drv)

static.

> +{
> +	platform_driver_unregister(&fm_driver);
> +	mutex_destroy(&fm_drv_mutex);
> +
> +	return 0;
> +}

And p_fm_drv is unused in the function (and see below).

> +static void *p_fm_drv;

> +static int __init __cold fm_load(void)
> +{
> +	p_fm_drv = fm_drv_init();
> +	if (!p_fm_drv) {
> +		pr_err("Failed to init FM wrapper!\n");
> +		return -ENODEV;
> +	}
> +
> +	pr_info("Freescale FM module\n");
> +	return 0;
> +}
> +
> +static void __exit __cold fm_unload(void)
> +{
> +	if (p_fm_drv)
> +		fm_drv_free(p_fm_drv);
> +}

How can p_fm_drv be NULL if fm_load() succeeded? If think that variable
isn't needed at all.

And by the way: p_, because it's a pointer? Don't do that, that's
silly. 

> +module_init(fm_load);
> +module_exit(fm_unload);

FSL_FMAN is bool (see 7/12) and fm_drv.o can only be built-in, as far as
I could (quickly) see. But the code is using a few module specific
constructs. Was FSL_FMAN perhaps meant to be tristate?

Thanks,


Paul Bolle
