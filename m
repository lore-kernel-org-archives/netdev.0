From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 03/11] soc/fsl: Introduce the DPAA BMan portal driver
Date: Fri, 10 Jul 2015 15:32:43 +0200
Message-ID: <1436535163.20619.216.camel@tiscali.nl>
References: <1436473322-21247-1-git-send-email-Roy.Pledge@freescale.com>
	 <1436473322-21247-4-git-send-email-Roy.Pledge@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@lists.ozlabs.org, scottwood@freescale.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Roy Pledge <Roy.Pledge@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb2-smtp-cloud3.xs4all.net ([194.109.24.26]:58728 "EHLO
	lb2-smtp-cloud3.xs4all.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932247AbbGJNcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 09:32:47 -0400
In-Reply-To: <1436473322-21247-4-git-send-email-Roy.Pledge@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On do, 2015-07-09 at 16:21 -0400, Roy Pledge wrote:
> --- a/drivers/soc/fsl/qbman/Kconfig
> +++ b/drivers/soc/fsl/qbman/Kconfig

> +config FSL_DPA_PIRQ_FAST
> +	bool
> +	default y

First used in 04/11.

> +config FSL_DPA_PIRQ_SLOW
> +	bool
> +	default y
> +
> +config FSL_DPA_PORTAL_SHARE
> +	bool
> +	default y

As in 02/11: these three symbols function as aliases for FSL_DPA. Why
are they needed? 

>  config FSL_BMAN
>  	tristate "BMan device management"
>  	default n
>  	help
>  		FSL DPAA BMan driver
>  
> +config FSL_BMAN_PORTAL
> +	tristate "BMan portal(s)"
> +	default n
> +	help
> +		FSL BMan portal driver

> --- /dev/null
> +++ b/drivers/soc/fsl/qbman/bman_api.c

> +struct bman_portal {
> +	[...]
> +#ifdef CONFIG_FSL_DPA_CAN_WAIT_SYNC

This check will always evaluate to true, right? (I'll only report this
once.)

> +	struct bman_pool *rcri_owned; /* only 1 release WAIT_SYNC at 
> a time */
> +#endif
> +#ifdef CONFIG_FSL_DPA_PORTAL_SHARE

Ditto.

> +	raw_spinlock_t sharing_lock; /* only used if is_shared */
> +	int is_shared;
> +	struct bman_portal *sharing_redirect;
> +#endif
> +	[...]
> +};

> +const struct bman_portal_config *bman_get_portal_config(void)
> +{
> +	[...]
> +}

I couldn't find callers of this function.

> +EXPORT_SYMBOL(bman_get_portal_config);

Nor users of this export, obviously.

> +
> +u32 bman_irqsource_get(void)
> +{
> +	[...]
> +}

Ditto.

> +EXPORT_SYMBOL(bman_irqsource_get);

Ditto.

> +int bman_p_irqsource_add(struct bman_portal *p, __maybe_unused u32 bits)
> +{
> +	[...]
> +}
> +EXPORT_SYMBOL(bman_p_irqsource_add);

There seem to be no users of this export.

> +int bman_irqsource_add(__maybe_unused u32 bits)
> +{
> +	[...]
> +}

Unused.

> +EXPORT_SYMBOL(bman_irqsource_add);

Ditto.

> +int bman_irqsource_remove(u32 bits)
> +{
> +	[...]
> +}

Ditto. 

> +EXPORT_SYMBOL(bman_irqsource_remove);

Ditto.

> +u32 bman_poll_slow(void)
> +{
> +	[...]
> +}

Ditto.

> +EXPORT_SYMBOL(bman_poll_slow);

Ditto.

> +void bman_poll(void)
> +{
> +	[...]
> +}

Ditto.

> +EXPORT_SYMBOL(bman_poll);

Ditto.

> +static inline struct bm_rcr_entry *try_rel_start(struct bman_portal **p,
> +#ifdef CONFIG_FSL_DPA_CAN_WAIT

Always true, right?

> +					__maybe_unused struct bman_pool *pool,
> +#endif
> +					__maybe_unused unsigned long *irqflags,
> +					__maybe_unused u32 flags)

And this is a, well, novel way to declare a function.

> +{
> +	[...]
> +}

> +int bman_flush_stockpile(struct bman_pool *pool, u32 flags)
> +{
> +	[...]
> +}

Unused function.

> +EXPORT_SYMBOL(bman_flush_stockpile);

So unused export too.

> +#ifdef CONFIG_FSL_BMAN
> +u32 bman_query_free_buffers(struct bman_pool *pool)
> +{
> +	return bm_pool_free_buffers(pool->params.bpid);
> +}
> +EXPORT_SYMBOL(bman_query_free_buffers);
> +
> +int bman_update_pool_thresholds(struct bman_pool *pool, const u32 *thresholds)
> +{
> +	u32 bpid;
> +
> +	bpid = bman_get_params(pool)->bpid;
> +
> +	return bm_pool_set(bpid, thresholds);
> +}
> +EXPORT_SYMBOL(bman_update_pool_thresholds);

More of the same.

> +#endif

> --- /dev/null
> +++ b/drivers/soc/fsl/qbman/bman_portal.c
> 
> +module_driver(bman_portal_driver,
> +	       bman_portal_driver_register, platform_driver_unregister);

No MODULE_LICENSE() here, nor in the other files that make up this
module. So loading this module will trigger a warning and taint the
kernel.

> --- /dev/null
> +++ b/drivers/soc/fsl/qbman/bman_utils.c

> +EXPORT_SYMBOL(bman_alloc_bpid_range);

Unused export.

> +EXPORT_SYMBOL(bman_release_bpid_range);

Ditto.

> +EXPORT_SYMBOL(bman_seed_bpid_range);

Ditto.

> +int bman_reserve_bpid_range(u32 bpid, u32 count)
> +{
> +	return dpaa_resource_reserve(&bpalloc, bpid, count);
> +}
> +EXPORT_SYMBOL(bman_reserve_bpid_range);

Because bman_reserve_bpid() is unused, see below, this function and this
export are unused too.

> --- /dev/null
> +++ b/drivers/soc/fsl/qbman/dpaa_resource.c
> 
> +#if defined(CONFIG_FSL_BMAN_PORTAL) || defined(CONFIG_FSL_BMAN_PORTAL_MODULE)

#if IS_ENABLED(CONFIG_FSL_BMAN_PORTAL)

> +#ifdef DPAA_RESOURCE_DEBUG

Never defined. So DUMP() is dead code.

> --- a/drivers/soc/fsl/qbman/dpaa_sys.h
> +++ b/drivers/soc/fsl/qbman/dpaa_sys.h
> 
> +#define CONFIG_TRY_BETTER_MEMCPY

Please replace the CONFIG_ prefix with something else.

> +#ifdef CONFIG_TRY_BETTER_MEMCPY

This will always be true, right?

> [...]
> +#else
> +#define copy_words memcpy
> +#define copy_shorts memcpy
> +#define copy_bytes memcpy
> +#endif

> --- /dev/null
> +++ b/include/soc/fsl/bman.h

> +static inline int bman_reserve_bpid(u32 bpid)
> +{
> +	return bman_reserve_bpid_range(bpid, 1);
> +}

Unused.

Thanks,


Paul Bolle
