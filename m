From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [PATCH 4/4] IP100A: Solve host error problem in low performance
 embedded system when continune down and up.
Date: Tue, 22 Aug 2006 09:05:42 -0700
Message-ID: <20060822090542.6469977a.rdunlap@xenotime.net>
References: <1156271492.4662.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@osdl.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:56467 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S1751407AbWHVQCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2006 12:02:36 -0400
Received: from midway.site ([71.117.233.155]) by xenotime.net for <netdev@vger.kernel.org>; Tue, 22 Aug 2006 09:02:34 -0700
To: Jesse Huang <jesse@icplus.com.tw>
In-Reply-To: <1156271492.4662.6.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 22 Aug 2006 14:31:32 -0400 Jesse Huang wrote:

> From: Jesse Huang <jesse@icplus.com.tw>
> 
> Change Logs:
>    - Solve host error problem in low performance embedded 
>      system when continune down and up.
> 
> Signed-off-by: Jesse Huang <jesse@icplus.com.tw>
> 
> ---
> 
>  sundance.c |   30 +++++++++++++++++++++++++-----
>  1 files changed, 25 insertions(+), 5 deletions(-)

Full path/file names above and below, please.

> a88c635933a981dd4fca87e5b8ca9426c5c98013
> diff --git a/sundance.c b/sundance.c
> index 424aebd..de55e0f 100755
> --- a/sundance.c
> +++ b/sundance.c
> @@ -1647,6 +1647,14 @@ static int netdev_close(struct net_devic
>  	struct sk_buff *skb;
>  	int i;
>  
> +	/* Wait and kill tasklet */
> +	tasklet_kill(&np->rx_tasklet);
> +	tasklet_kill(&np->tx_tasklet);
> +   np->cur_tx = 0;
> +   np->dirty_tx = 0;

Use same indentation/whitespace as surrounding code.
(tabs, not spaces)

> +	np->cur_task = 0;
> +	np->last_tx = 0;
> +
>  	netif_stop_queue(dev);
>  
>  	if (netif_msg_ifdown(np)) {
> @@ -1667,9 +1675,20 @@ static int netdev_close(struct net_devic
>  	/* Stop the chip's Tx and Rx processes. */
>  	iowrite16(TxDisable | RxDisable | StatsDisable, ioaddr + MACCtrl1);
>  
> -	/* Wait and kill tasklet */
> -	tasklet_kill(&np->rx_tasklet);
> -	tasklet_kill(&np->tx_tasklet);
> +    for (i = 2000; i > 0; i--) {
> +		 if ((ioread32(ioaddr + DMACtrl) &0xC000) == 0)
> +		    break;
> +		 mdelay(1);
> +    }	
> +
> +    iowrite16(GlobalReset | DMAReset | FIFOReset |NetworkReset, ioaddr +ASICCtrl + 2);
> +    
> +    for (i = 2000; i > 0; i--)
> +    {
> +		 if ((ioread16(ioaddr + ASICCtrl +2) &ResetBusy) == 0)
> +	    	break;
> +		 mdelay(1);
> +    }

Same comment about indentation/whitespace.

---
~Randy
