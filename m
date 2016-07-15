From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [v10, 3/7] soc: fsl: add GUTS driver for QorIQ platforms
Date: Fri, 15 Jul 2016 12:43:41 -0400
Message-ID: <CAP=VYLqsV_M=8CM47k4kzdULCp_y0yP9t8Sq9=jFp6W593QJgw@mail.gmail.com>
References: <1462417950-46796-1-git-send-email-yangbo.lu@nxp.com> <1462417950-46796-4-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-mmc@vger.kernel.org,
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
	devicetree@vger.kernel.org,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-clk@vger.kernel.org,
	linux-i2c@vger.kernel.org, iommu@lists.linux-foundation.org,
	netdev <netdev@vger.kernel.org>, ulf.hansson@linaro.org,
	Scott Wood <oss@buserror.net>,
	Mark Rutland <mark.rutland@arm.com>,
	Rob Herring <robh+dt@kernel.org>,
	Russell King <linux@arm.linux.org.uk>,
	Jochen Friedrich <jochen@scram.de>,
	Joerg Roedel <joro@8bytes.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	Bhupesh Sharma <bhupesh.sharma@freescale.com>,
	Qiang Zhao <qiang.zhao@nxp.com>,
	Kumar Gala <galak@codeaurora.org>,
	Santosh Shilimkar <ssantosh@kernel.org>, leoyang.li@nxp.com,
	xiaobo.xie@nxp.com
To: Yangbo Lu <yangbo.lu@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35234 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751054AbcGOQoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 12:44:13 -0400
In-Reply-To: <1462417950-46796-4-git-send-email-yangbo.lu@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 4, 2016 at 11:12 PM, Yangbo Lu <yangbo.lu@nxp.com> wrote:
> The global utilities block controls power management, I/O device
> enabling, power-onreset(POR) configuration monitoring, alternate
> function selection for multiplexed signals,and clock control.
>
> This patch adds GUTS driver to manage and access global utilities
> block.
>
> Signed-off-by: Yangbo Lu <yangbo.lu@nxp.com>
> Acked-by: Scott Wood <oss@buserror.net>
> ---
> Changes for v4:
>         - Added this patch
> Changes for v5:
>         - Modified copyright info
>         - Changed MODULE_LICENSE to GPL
>         - Changed EXPORT_SYMBOL_GPL to EXPORT_SYMBOL
>         - Made FSL_GUTS user-invisible
>         - Added a complete compatible list for GUTS
>         - Stored guts info in file-scope variable
>         - Added mfspr() getting SVR
>         - Redefined GUTS APIs
>         - Called fsl_guts_init rather than using platform driver
>         - Removed useless parentheses
>         - Removed useless 'extern' key words
> Changes for v6:
>         - Made guts thread safe in fsl_guts_init
> Changes for v7:
>         - Removed 'ifdef' for function declaration in guts.h
> Changes for v8:
>         - Fixes lines longer than 80 characters checkpatch issue
>         - Added 'Acked-by: Scott Wood'
> Changes for v9:
>         - None
> Changes for v10:
>         - None
> ---
>  drivers/soc/Kconfig      |   2 +-
>  drivers/soc/fsl/Kconfig  |   8 +++
>  drivers/soc/fsl/Makefile |   1 +
>  drivers/soc/fsl/guts.c   | 119 ++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/fsl/guts.h | 126 +++++++++++++++++++++++++++++------------------
>  5 files changed, 207 insertions(+), 49 deletions(-)
>  create mode 100644 drivers/soc/fsl/Kconfig
>  create mode 100644 drivers/soc/fsl/guts.c
>
> diff --git a/drivers/soc/Kconfig b/drivers/soc/Kconfig
> index cb58ef0..7106463 100644
> --- a/drivers/soc/Kconfig
> +++ b/drivers/soc/Kconfig
> @@ -2,7 +2,7 @@ menu "SOC (System On Chip) specific Drivers"
>
>  source "drivers/soc/bcm/Kconfig"
>  source "drivers/soc/brcmstb/Kconfig"
> -source "drivers/soc/fsl/qe/Kconfig"
> +source "drivers/soc/fsl/Kconfig"
>  source "drivers/soc/mediatek/Kconfig"
>  source "drivers/soc/qcom/Kconfig"
>  source "drivers/soc/rockchip/Kconfig"
> diff --git a/drivers/soc/fsl/Kconfig b/drivers/soc/fsl/Kconfig
> new file mode 100644
> index 0000000..b313759
> --- /dev/null
> +++ b/drivers/soc/fsl/Kconfig
> @@ -0,0 +1,8 @@
> +#
> +# Freescale SOC drivers
> +#
> +
> +source "drivers/soc/fsl/qe/Kconfig"
> +
> +config FSL_GUTS
> +       bool
> diff --git a/drivers/soc/fsl/Makefile b/drivers/soc/fsl/Makefile
> index 203307f..02afb7f 100644
> --- a/drivers/soc/fsl/Makefile
> +++ b/drivers/soc/fsl/Makefile
> @@ -4,3 +4,4 @@
>
>  obj-$(CONFIG_QUICC_ENGINE)             += qe/
>  obj-$(CONFIG_CPM)                      += qe/
> +obj-$(CONFIG_FSL_GUTS)                 += guts.o
> diff --git a/drivers/soc/fsl/guts.c b/drivers/soc/fsl/guts.c
> new file mode 100644
> index 0000000..fa155e6
> --- /dev/null
> +++ b/drivers/soc/fsl/guts.c
> @@ -0,0 +1,119 @@
> +/*
> + * Freescale QorIQ Platforms GUTS Driver
> + *
> + * Copyright (C) 2016 Freescale Semiconductor, Inc.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + */
> +
> +#include <linux/io.h>
> +#include <linux/module.h>

Seems there was lots of discussion on this.  If it does end up being
resent, it would be nice to get the module.h and other modular stuff
gone since it is a bool Kconfig.

Thanks,
Paul.
