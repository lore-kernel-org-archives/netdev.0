From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] net: fec: ptp: fix convergence issue to support LinuxPTP
 stack
Date: Tue, 14 Oct 2014 12:36:10 +0200
Message-ID: <20141014103610.GA4019@localhost.localdomain>
References: <1413265187-5228-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	bhutchings@solarflare.com, b20596@freescale.com
To: Fugang Duan <b38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:56365 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752778AbaJNKgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 06:36:15 -0400
Received: by mail-wi0-f173.google.com with SMTP id fb4so9716611wid.0
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2014 03:36:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1413265187-5228-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 14, 2014 at 01:39:47PM +0800, Fugang Duan wrote:
> IEEE 1588 module has one hw issue in capturing the ATVR register. According
> to the user manual it is:
> 		ENET0->ATCR |= ENET_ATCR_CAPTURE_MASK;
> 		while(ENET0->ATCR & ENET_ATCR_CAPTURE_MASK);
> 		ts_counter_ns = ENET0->ATVR;

...

> diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
> index cca3617..380bb10 100644
> --- a/drivers/net/ethernet/freescale/fec_ptp.c
> +++ b/drivers/net/ethernet/freescale/fec_ptp.c
> @@ -82,12 +82,17 @@ static cycle_t fec_ptp_read(const struct cyclecounter *cc)
>  {
>  	struct fec_enet_private *fep =
>  		container_of(cc, struct fec_enet_private, cc);
> +	const struct platform_device_id *id_entry =
> +		platform_get_device_id(fep->pdev);
>  	u32 tempval;
>  
>  	tempval = readl(fep->hwp + FEC_ATIME_CTRL);
>  	tempval |= FEC_T_CTRL_CAPTURE;
>  	writel(tempval, fep->hwp + FEC_ATIME_CTRL);
>  
> +	if (id_entry->driver_data & FEC_QUIRK_BUG_CAPTURE)
> +		udelay(1);
> +

What? You never had

	while(ENET0->ATCR & ENET_ATCR_CAPTURE_MASK);

in the first place. Maybe you should try that.

Did this code ever work? I guess not.

>  	return readl(fep->hwp + FEC_ATIME);
>  }

Thanks,
Richard
