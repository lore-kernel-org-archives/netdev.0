From: Jamie Iles <jamie@jamieiles.com>
Subject: Re: [PATCH v3 08/10] ARM: mxs: add ocotp read function
Date: Wed, 5 Jan 2011 16:16:46 +0000
Message-ID: <20110105161235.GA2112@gallagher>
References: <1294236457-17476-1-git-send-email-shawn.guo@freescale.com>
 <1294236457-17476-9-git-send-email-shawn.guo@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, gerg@snapgear.com, baruch@tkos.co.il,
	eric@eukrea.com, bryan.wu@canonical.com, r64343@freescale.com,
	B32542@freescale.com, u.kleine-koenig@pengutronix.de,
	lw@karo-electronics.de, w.sang@pengutronix.de,
	s.hauer@pengutronix.de, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43641 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192Ab1AEQXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 11:23:12 -0500
Received: by wyb28 with SMTP id 28so15505473wyb.19
        for <netdev@vger.kernel.org>; Wed, 05 Jan 2011 08:23:10 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1294236457-17476-9-git-send-email-shawn.guo@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Shawn,

On Wed, Jan 05, 2011 at 10:07:35PM +0800, Shawn Guo wrote:
> Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
> ---
> Changes for v2:
>  - Add mutex locking for mxs_read_ocotp()
>  - Use type size_t for count and i
>  - Add comment for clk_enable/disable skipping
>  - Add ERROR bit clearing and polling step
> 
>  arch/arm/mach-mxs/Makefile              |    2 +-
>  arch/arm/mach-mxs/include/mach/common.h |    1 +
>  arch/arm/mach-mxs/ocotp.c               |   79 +++++++++++++++++++++++++++++++
>  3 files changed, 81 insertions(+), 1 deletions(-)
>  create mode 100644 arch/arm/mach-mxs/ocotp.c
> 
[...]
> diff --git a/arch/arm/mach-mxs/ocotp.c b/arch/arm/mach-mxs/ocotp.c
> new file mode 100644
> index 0000000..902ef59
> --- /dev/null
> +++ b/arch/arm/mach-mxs/ocotp.c
> @@ -0,0 +1,79 @@
> +/*
> + * Copyright 2010 Freescale Semiconductor, Inc. All Rights Reserved.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + */
> +
> +#include <linux/delay.h>
> +#include <linux/err.h>
> +#include <linux/mutex.h>
> +
> +#include <mach/mxs.h>
> +
> +#define BM_OCOTP_CTRL_BUSY		(1 << 8)
> +#define BM_OCOTP_CTRL_ERROR		(1 << 9)
> +#define BM_OCOTP_CTRL_RD_BANK_OPEN	(1 << 12)
> +
> +static DEFINE_MUTEX(ocotp_mutex);
> +
> +int mxs_read_ocotp(unsigned offset, size_t count, u32 *values)
> +{
> +	void __iomem *ocotp_base = MXS_IO_ADDRESS(MXS_OCOTP_BASE_ADDR);
> +	int timeout = 0x400;
> +	size_t i;
> +
> +	mutex_lock(&ocotp_mutex);
> +
> +	/*
> +	 * clk_enable(hbus_clk) for ocotp can be skipped
> +	 * as it must be on when system is running.
> +	 */
> +
> +	/* try to clear ERROR bit */
> +	__mxs_clrl(BM_OCOTP_CTRL_ERROR, ocotp_base);
> +
> +	/* check both BUSY and ERROR cleared */
> +	while ((__raw_readl(ocotp_base) &
> +		(BM_OCOTP_CTRL_BUSY | BM_OCOTP_CTRL_ERROR)) && --timeout)
> +		/* nothing */;

Is it worth using cpu_relax() in these polling loops?

Jamie
