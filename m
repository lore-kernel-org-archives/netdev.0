From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 1/2] net: davinci_cpdma: reduce time holding ctlr->lock in
 cpdma_control_set
Date: Thu, 4 Aug 2016 18:22:03 +0300
Message-ID: <4ca5db2b-9d81-8157-aec5-f7d8cf183981@ti.com>
References: <1469534545-14478-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <1469534545-14478-2-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Cc: <linux-omap@vger.kernel.org>, <netdev@vger.kernel.org>,
	<kernel@pengutronix.de>
To: =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:36473 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755193AbcHDPWP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2016 11:22:15 -0400
In-Reply-To: <1469534545-14478-2-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/26/2016 03:02 PM, Uwe Kleine-König wrote:
> The only user of cpdma_control_set (i.e. cpsw_ndo_open) doesn't check
> the return code, so it doesn't matter, which error triggers. So the
> checks that are independant of the fields protected by ctlr->lock can be
> moved out of the critical section.
>
> Signed-off-by: Uwe Kleine-König <u.kleine-koenig@pengutronix.de>


Reviewed-by: Grygorii Strashko <grygorii.strashko@ti.com>

> ---
>  drivers/net/ethernet/ti/davinci_cpdma.c | 20 +++++++++-----------
>  1 file changed, 9 insertions(+), 11 deletions(-)
>
> diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
> index 73638f7a55d4..5ffa04a306c6 100644
> --- a/drivers/net/ethernet/ti/davinci_cpdma.c
> +++ b/drivers/net/ethernet/ti/davinci_cpdma.c
> @@ -877,23 +877,21 @@ int cpdma_control_set(struct cpdma_ctlr *ctlr, int control, int value)
>  	int ret;
>  	u32 val;
>
> -	spin_lock_irqsave(&ctlr->lock, flags);
> -
> -	ret = -ENOTSUPP;
>  	if (!ctlr->params.has_ext_regs)
> -		goto unlock_ret;
> +		return -ENOTSUPP;
>
> -	ret = -EINVAL;
> -	if (ctlr->state != CPDMA_STATE_ACTIVE)
> -		goto unlock_ret;
> -
> -	ret = -ENOENT;
>  	if (control < 0 || control >= ARRAY_SIZE(controls))
> -		goto unlock_ret;
> +		return -ENOENT;
>
> -	ret = -EPERM;
>  	if ((info->access & ACCESS_WO) != ACCESS_WO)
> +		return -EPERM;
> +
> +	spin_lock_irqsave(&ctlr->lock, flags);
> +
> +	if (ctlr->state != CPDMA_STATE_ACTIVE) {
> +		ret = -EINVAL;
>  		goto unlock_ret;
> +	}
>
>  	val  = dma_reg_read(ctlr, info->reg);
>  	val &= ~(info->mask << info->shift);
>


-- 
regards,
-grygorii
