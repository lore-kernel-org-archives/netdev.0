From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 02/11] soc/fsl: Introduce DPAA BMan device management
 driver
Date: Fri, 10 Jul 2015 13:36:00 +0200
Message-ID: <1436528160.20619.159.camel@tiscali.nl>
References: <1436473322-21247-1-git-send-email-Roy.Pledge@freescale.com>
	 <1436473322-21247-3-git-send-email-Roy.Pledge@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@lists.ozlabs.org, scottwood@freescale.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Roy Pledge <Roy.Pledge@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lb2-smtp-cloud2.xs4all.net ([194.109.24.25]:44455 "EHLO
	lb2-smtp-cloud2.xs4all.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751679AbbGJLgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 07:36:05 -0400
In-Reply-To: <1436473322-21247-3-git-send-email-Roy.Pledge@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On do, 2015-07-09 at 16:21 -0400, Roy Pledge wrote:
> --- /dev/null
> +++ b/drivers/soc/fsl/qbman/Kconfig

> +menuconfig FSL_DPA
> +	bool "Freescale DPAA support"
> +	depends on FSL_SOC || COMPILE_TEST

(I already commented on COMPILE_TEST in a separate mail.)

> +	default n
> +	help
> +		FSL Data-Path Acceleration Architecture drivers
> +
> +		These are not the actual Ethernet driver(s)
> +
> +if FSL_DPA
> +
> +config FSL_DPA_CHECKING
> +	bool "additional driver checking"
> +	default n
> +	help
> +		Compiles in additional checks to sanity-check the drivers and
> +		any use of it by other code. Not recommended for performance

Only recommended for people that are certain none of the 100+ asserts
will ever trigger. See below.

> +config FSL_DPA_CAN_WAIT
> +	bool
> +	default y
> +
> +config FSL_DPA_CAN_WAIT_SYNC
> +	bool
> +	default y

Both these aren't actually used in this patch. The first patch that uses
them is 3/11.

Besides, the way these two symbols are implemented makes them function
as aliases for FSL_DPA. So why are they needed?

> +config FSL_BMAN
> +	tristate "BMan device management"
> +	default n
> +	help
> +		FSL DPAA BMan driver

(Will readers know what BMan means?)

> +endif # FSL_DPA

> --- /dev/null
> +++ b/drivers/soc/fsl/qbman/Makefile

> +obj-$(CONFIG_FSL_BMAN)				+= bman.o

> --- /dev/null
> +++ b/drivers/soc/fsl/qbman/bman.c

> +int bm_pool_set(u32 bpid, const u32 *thresholds)
> +{
> +	if (!bm)
> +		return -ENODEV;
> +	bm_set_pool(bm, bpid, thresholds[0], thresholds[1],
> +		thresholds[2], thresholds[3]);
> +	return 0;
> +}
> +EXPORT_SYMBOL(bm_pool_set);

Nit: the first (caller of this function and) user of this export is
added in 3/11.

I couldn't find a MODULE_LICENSE() in bman.c. So building this as a
module and loading that module will generate a warning and taint the
kernel.

> --- /dev/null
> +++ b/drivers/soc/fsl/qbman/dpaa_sys.h

> +#ifdef CONFIG_FSL_DPA_CHECKING
> +#define DPA_ASSERT(x) \
> +	do { \
> +		if (!(x)) { \
> +			pr_crit("ASSERT: (%s:%d) %s\n", __FILE__, __LINE__, \
> +				__stringify_1(x)); \
> +			dump_stack(); \
> +			panic("assertion failure"); \

Not my call, but why panic() here?

> +		} \
> +	} while (0)
> +#else
> +#define DPA_ASSERT(x)
> +#endif

Thanks,


Paul Bolle
