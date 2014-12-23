From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v3] 3c59x: Fix memory leaks in vortex_open
Date: Tue, 23 Dec 2014 09:24:39 -0500
Message-ID: <20141223142439.GD31876@hmsreliant.think-freely.org>
References: <1419303290-27565-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, ebiederm@xmission.com,
	dingtianhong@huawei.com, paul.gortmaker@windriver.com,
	justinvanwijngaarden@gmail.com, netdev@vger.kernel.org
To: Jia-Ju Bai <baijiaju1990@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43796 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754155AbaLWOZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2014 09:25:14 -0500
Content-Disposition: inline
In-Reply-To: <1419303290-27565-1-git-send-email-baijiaju1990@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 23, 2014 at 10:54:50AM +0800, Jia-Ju Bai wrote:
> For linux-3.18.0
> The driver calls __netdev_alloc_skb in vortex_open but lacks dev_kfree_skb
> when vortex_up is failed, so memory leaks may occur in this situation.
> This patch fixes this problem.
> 
> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
> ---
>  drivers/net/ethernet/3com/3c59x.c |   10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
> index 41095eb..d0c5bee 100644
> --- a/drivers/net/ethernet/3com/3c59x.c
> +++ b/drivers/net/ethernet/3com/3c59x.c
> @@ -1782,6 +1782,16 @@ vortex_open(struct net_device *dev)
>  	if (!retval)
>  		goto out;
>  
> +	if (vp->full_bus_master_rx) {
> +		for (i = 0; i < RX_RING_SIZE; i++) {
> +			if (vp->rx_skbuff[i]) {
> +				dev_kfree_skb(vp->rx_skbuff[i]);
> +				vp->rx_skbuff[i] = NULL;
> +			}
> +		}
> +		retval = -ENOMEM;
> +	}
> +
>  err_free_irq:
>  	free_irq(dev->irq, dev);
>  err:
> -- 
> 1.7.9.5
> 
> 
> 
This doesn't make sense.  We free all the skbs in vortex_open if we don't
allocate all of them (the if (i != RX_RING_SIZE) check), the only place we miss
is if vortex_up fails, and you didn't remove the if (!retval) goto out check, so
this code won't get run appropriately.

That said, it does seem we need to clean up if vortex_up fails, but it would
seem to me to be easier to just call vortex_close if it does, since that will do
all of the approriate cleanup.

Neil
