From: Frederik Deweerdt <deweerdt@free.fr>
Subject: Re: [PATCH 5/5] Solve host error problem in low performance embedded system when continune down and up.
Date: Mon, 2 Oct 2006 12:59:29 +0000
Message-ID: <20061002125929.GB3003@slug>
References: <1159813596.2576.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@osdl.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:56654 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1750790AbWJBLAz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Oct 2006 07:00:55 -0400
Received: by ug-out-1314.google.com with SMTP id o38so488316ugd
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2006 04:00:54 -0700 (PDT)
To: Jesse Huang <jesse@icplus.com.tw>
Content-Disposition: inline
In-Reply-To: <1159813596.2576.8.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 02, 2006 at 02:26:36PM -0400, Jesse Huang wrote:
> From: Jesse Huang <jesse@icplus.com.tw>
> 
> Change Logs:
> Solve host error problem in low performance embedded system when continune down and up.
> 
> Signed-off-by: Jesse Huang <jesse@icplus.com.tw>
> ---
> 
>  drivers/net/sundance.c |   26 +++++++++++++++++++++++---
>  1 files changed, 23 insertions(+), 3 deletions(-)
> 
> c06c70e20a85facd640528ca66e0b579fc3ee745
> diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
> index 14b4933..b4a6010 100755
> --- a/drivers/net/sundance.c
> +++ b/drivers/net/sundance.c
> @@ -1643,6 +1643,14 @@ static int netdev_close(struct net_devic
>  	struct sk_buff *skb;
>  	int i;
>  
> +	/* Wait and kill tasklet */
> +	tasklet_kill(&np->rx_tasklet);
> +	tasklet_kill(&np->tx_tasklet);
> +	np->cur_tx = 0;
> +	np->dirty_tx = 0;
> +	np->cur_task = 0;
> +	np->last_tx = 0;
> +
>  	netif_stop_queue(dev);
>  
>  	if (netif_msg_ifdown(np)) {
> @@ -1663,9 +1671,20 @@ static int netdev_close(struct net_devic
>  	/* Stop the chip's Tx and Rx processes. */
>  	iowrite16(TxDisable | RxDisable | StatsDisable, ioaddr + MACCtrl1);
>  
> -	/* Wait and kill tasklet */
> -	tasklet_kill(&np->rx_tasklet);
> -	tasklet_kill(&np->tx_tasklet);
> +    	for (i = 2000; i > 0; i--) {
> + 		if ((ioread32(ioaddr + DMACtrl) &0xC000) == 0)
                                                ^^^^^^^
Missing white space?
> +			break;
> +		mdelay(1);
> +    	}
> +
> +    	iowrite16(GlobalReset | DMAReset | FIFOReset | NetworkReset, ioaddr +ASICCtrl + 2);
                                                                            ^^^^^^^^^
Same here..
> +
> +    	for (i = 2000; i > 0; i--)
> +    	{
> + 		if ((ioread16(ioaddr + ASICCtrl +2) &ResetBusy) == 0)
                                                    ^^^^^^^^^^
.. and here
> +			break;
> +		mdelay(1);
> +    	}
>  
Regards,
Frederik
