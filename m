From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v3 1/1] net: fec: ptp: avoid register access when ipg
 clock is disabled
Date: Fri, 15 Aug 2014 20:08:54 +0200
Message-ID: <20140815180854.GA6897@localhost.localdomain>
References: <1408081975-15087-1-git-send-email-b38611@freescale.com>
 <1408081975-15087-2-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, shawn.guo@linaro.org
To: Fugang Duan <b38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:52644 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027AbaHOSJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2014 14:09:23 -0400
Received: by mail-wi0-f171.google.com with SMTP id hi2so1176178wib.16
        for <netdev@vger.kernel.org>; Fri, 15 Aug 2014 11:09:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1408081975-15087-2-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks better, but ...

On Fri, Aug 15, 2014 at 01:52:55PM +0800, Fugang Duan wrote:

> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index 66fe1f6..ba35994 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -1613,14 +1613,18 @@ static int fec_enet_clk_enable(struct net_device *ndev, bool enable)
>  			ret = clk_prepare_enable(fep->clk_ptp);
>  			if (ret)
>  				goto failed_clk_ptp;
> +			else
> +				fep->ptp_clk_on = true;
>  		}
>  	} else {
>  		clk_disable_unprepare(fep->clk_ahb);
>  		clk_disable_unprepare(fep->clk_ipg);
>  		if (fep->clk_enet_out)
>  			clk_disable_unprepare(fep->clk_enet_out);
> -		if (fep->clk_ptp)
> +		if (fep->clk_ptp) {
>  			clk_disable_unprepare(fep->clk_ptp);
> +			fep->ptp_clk_on = false;

Set the flag to false first, because this races ...

> diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
> index 82386b2..8084aaf 100644
> --- a/drivers/net/ethernet/freescale/fec_ptp.c
> +++ b/drivers/net/ethernet/freescale/fec_ptp.c
> @@ -245,6 +245,10 @@ static int fec_ptp_settime(struct ptp_clock_info *ptp,
>  	u64 ns;
>  	unsigned long flags;
>  
> +	/* Check the ptp clock */
> +	if (!fep->ptp_clk_on)
> +		return -EINVAL;

with this and ...

> +
>  	ns = ts->tv_sec * 1000000000ULL;
>  	ns += ts->tv_nsec;
>  
> @@ -338,17 +342,20 @@ int fec_ptp_get(struct net_device *ndev, struct ifreq *ifr)
>   * fec_time_keep - call timecounter_read every second to avoid timer overrun
>   *                 because ENET just support 32bit counter, will timeout in 4s
>   */
> -static void fec_time_keep(unsigned long _data)
> +static void fec_time_keep(struct work_struct *work)
>  {
> -	struct fec_enet_private *fep = (struct fec_enet_private *)_data;
> +	struct delayed_work *dwork = to_delayed_work(work);
> +	struct fec_enet_private *fep = container_of(dwork, struct fec_enet_private, time_keep);
>  	u64 ns;
>  	unsigned long flags;
>  
> -	spin_lock_irqsave(&fep->tmreg_lock, flags);
> -	ns = timecounter_read(&fep->tc);
> -	spin_unlock_irqrestore(&fep->tmreg_lock, flags);
> +	if (fep->ptp_clk_on) {

with this.

> +		spin_lock_irqsave(&fep->tmreg_lock, flags);
> +		ns = timecounter_read(&fep->tc);
> +		spin_unlock_irqrestore(&fep->tmreg_lock, flags);
> +	}

Thanks,
Richard
