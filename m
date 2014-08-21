From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v4 1/1] net: fec: ptp: avoid register access when ipg
 clock is disabled
Date: Thu, 21 Aug 2014 09:02:41 +0200
Message-ID: <20140821070241.GB6231@netboy>
References: <1408418453-28012-1-git-send-email-b38611@freescale.com>
 <1408418453-28012-2-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, shawn.guo@linaro.org
To: Fugang Duan <b38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:43884 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750965AbaHUHCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2014 03:02:52 -0400
Received: by mail-wi0-f180.google.com with SMTP id n3so7947555wiv.1
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2014 00:02:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1408418453-28012-2-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 19, 2014 at 11:20:53AM +0800, Fugang Duan wrote:
> The current kernel hang on i.MX6SX with rootfs mount from MMC.
> The root cause is ptp rise up period timer to access enet register

s/ptp rise up period/that ptp uses a periodic/

> even if ipg clock is disabled.

...

> diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
> index 82386b2..6d65555 100644
> --- a/drivers/net/ethernet/freescale/fec_ptp.c
> +++ b/drivers/net/ethernet/freescale/fec_ptp.c
> @@ -245,12 +245,18 @@ static int fec_ptp_settime(struct ptp_clock_info *ptp,
>  	u64 ns;
>  	unsigned long flags;
>  
> +	mutex_lock(&fep->ptp_clk_mutex);
> +	/* Check the ptp clock */
> +	if (!fep->ptp_clk_on)
> +		return -EINVAL;

You are still holding the mutex here.

> +
>  	ns = ts->tv_sec * 1000000000ULL;
>  	ns += ts->tv_nsec;
>  
>  	spin_lock_irqsave(&fep->tmreg_lock, flags);
>  	timecounter_init(&fep->tc, &fep->cc, ns);
>  	spin_unlock_irqrestore(&fep->tmreg_lock, flags);
> +	mutex_unlock(&fep->ptp_clk_mutex);
>  	return 0;
>  }

Thanks,
Richard
