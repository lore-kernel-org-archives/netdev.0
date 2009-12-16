From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] bnx2: fixing a timout error due not refreshing TX
 timers correctly
Date: Wed, 16 Dec 2009 10:33:30 -0800
Message-ID: <1260988410.31045.72.camel@nseg_linux_HP1.broadcom.com>
References: <1260965365-14255-1-git-send-email-leitao@linux.vnet.ibm.com>
 <1260965365-14255-2-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "leitao@linux.vnet.ibm.com" <leitao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2248 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757948AbZLPSns (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2009 13:43:48 -0500
In-Reply-To: <1260965365-14255-2-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2009-12-16 at 04:09 -0800, leitao@linux.vnet.ibm.com wrote:
> When running the following script on an active bnx2 interface:
> 
> while(true); do ifconfig ethX mtu 9000; ifconfig ethX mtu 1500; done
> 
> A timeout error appears and dumps the following stack:
> 
> NETDEV WATCHDOG: eth4 (bnx2): transmit queue 0 timed out
> ------------[ cut here ]------------
> Badness at net/sched/sch_generic.c:261
> <snip>
> 
> This patch just fixes the way that ->trans_start is refreshed.
> 
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>

Thanks.  Acked-by: Michael Chan <mchan@broadcom.com>

> ---
>  drivers/net/bnx2.c |   10 +++++++++-
>  1 files changed, 9 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
> index 4bfc808..f81f082 100644
> --- a/drivers/net/bnx2.c
> +++ b/drivers/net/bnx2.c
> @@ -655,9 +655,17 @@ bnx2_netif_stop(struct bnx2 *bp)
>  	bnx2_cnic_stop(bp);
>  	bnx2_disable_int_sync(bp);
>  	if (netif_running(bp->dev)) {
> +		int i;
> +
>  		bnx2_napi_disable(bp);
>  		netif_tx_disable(bp->dev);
> -		bp->dev->trans_start = jiffies;	/* prevent tx timeout */
> +		/* prevent tx timeout */
> +		for (i = 0; i <  bp->dev->num_tx_queues; i++) {
> +			struct netdev_queue *txq;
> +
> +			txq = netdev_get_tx_queue(bp->dev, i);
> +			txq->trans_start = jiffies;
> +		}
>  	}
>  }
>  


