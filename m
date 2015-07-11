From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 04/11] soc/fsl: Introduce drivers for the DPAA QMan
Date: Sat, 11 Jul 2015 12:34:08 +0200
Message-ID: <1436610848.20619.258.camel@tiscali.nl>
References: <1436473322-21247-1-git-send-email-Roy.Pledge@freescale.com>
	 <1436473322-21247-5-git-send-email-Roy.Pledge@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@lists.ozlabs.org, scottwood@freescale.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Roy Pledge <Roy.Pledge@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1436473322-21247-5-git-send-email-Roy.Pledge@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On do, 2015-07-09 at 16:21 -0400, Roy Pledge wrote:
> --- a/drivers/soc/fsl/qbman/Kconfig
> +++ b/drivers/soc/fsl/qbman/Kconfig
 
> +config FSL_QMAN
> +	tristate "QMan device management"
> +	default n
> +	help
> +		FSL DPAA QMan driver

> +config FSL_QMAN_POLL_LIMIT
> +	int
> +	default 32

This Kconfig symbol will always be set to its default (32). So why
bother with a Kconfig symbol. Can't you use, say, a preprocessor define
directly?

> +config FSL_QMAN_CONFIG
> +	bool "QMan device management"
> +	default y
> +	help
> +	  If this linux image is running natively, you need this option. If this
> +	  linux image is running as a guest OS under the hypervisor, only one
> +	  guest OS ("the control plane") needs this option.

> +config FSL_QMAN_CI_SCHED_CFG_SRCCIV
> +	int
> +	depends on FSL_QMAN_CONFIG
> +	default 4
> +
> +config FSL_QMAN_CI_SCHED_CFG_SRQ_W
> +	int
> +	depends on FSL_QMAN_CONFIG
> +	default 3
> +
> +config FSL_QMAN_CI_SCHED_CFG_RW_W
> +	int
> +	depends on FSL_QMAN_CONFIG
> +	default 2
> +
> +config FSL_QMAN_CI_SCHED_CFG_BMAN_W
> +	int
> +	depends on FSL_QMAN_CONFIG
> +	default 2

Ditto.

> +config FSL_QMAN_PIRQ_DQRR_ITHRESH
> +	int
> +	default 12
> +
> +config FSL_QMAN_PIRQ_MR_ITHRESH
> +	int
> +	default 4
> +
> +config FSL_QMAN_PIRQ_IPERIOD
> +	int
> +	default 100

Ditto.

> --- a/drivers/soc/fsl/qbman/Makefile
> +++ b/drivers/soc/fsl/qbman/Makefile

> +obj-$(CONFIG_FSL_QMAN)				+= qman_api.o qman_utils.o qman_driver.o

If FSL_QMAN is set to 'm' this should generate three modules. Is three
modules what you want? (Just to be safe: cross compiling ran into
problems, even for PPC64, probably because of silliness on my side. So I
couldn't check this. And I trust make's results more than I trust my
ability to parse Makefiles.)
 
Besides, there's no MODULE_LICENSE() in any of their source files. So,
whether you create one or three modules, loading a module will trigger a
warning and taint the kernel.

> +obj-$(CONFIG_FSL_QMAN_CONFIG)			+= qman.o qman_portal.o

> --- /dev/null
> +++ b/drivers/soc/fsl/qbman/qman.c

> +MODULE_DEVICE_TABLE(of, of_fsl_qman_ids);

qman.o is built if FSL_QMAN_CONFIG is set. FSL_QMAN_CONFIG is a bool
symbol. The net effect is that MODULE_DEVICE_TABLE is preprocessed away.

> +static struct platform_driver of_fsl_qman_driver = {
> +	.driver = {
> +		.name = DRV_NAME,
> +		.of_match_table = of_fsl_qman_ids,
> +	},
> +	.probe = of_fsl_qman_probe,
> +	.remove	= of_fsl_qman_remove,
> +};
> +
> +module_platform_driver(of_fsl_qman_driver);

As of v4.2-rc1 you can use builtin_platform_driver() for built-in only
code.

Thanks,


Paul Bolle
