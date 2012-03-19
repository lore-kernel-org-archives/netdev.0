From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] net/hyperv: Fix the code handling tx busy
Date: Mon, 19 Mar 2012 10:11:58 -0700
Message-ID: <1332177118.9397.32.camel@edumazet-glaptop>
References: <1332176549-30960-1-git-send-email-haiyangz@microsoft.com>
	 <1332176549-30960-2-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1332176549-30960-2-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-03-19 at 10:02 -0700, Haiyang Zhang wrote:
> Instead of dropping the packet, we keep the skb buffer, and return
> NETDEV_TX_BUSY to let upper layer retry send. This will not cause
> endless loop, because the host is taking data away from ring buffer.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
> ---
>  drivers/net/hyperv/netvsc_drv.c |    5 +----
>  1 files changed, 1 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
> index 2517d20..dd29478 100644
> --- a/drivers/net/hyperv/netvsc_drv.c
> +++ b/drivers/net/hyperv/netvsc_drv.c
> @@ -223,13 +223,10 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
>  		net->stats.tx_bytes += skb->len;
>  		net->stats.tx_packets++;
>  	} else {
> -		/* we are shutting down or bus overloaded, just drop packet */
> -		net->stats.tx_dropped++;
>  		kfree(packet);
> -		dev_kfree_skb_any(skb);
>  	}
>  
> -	return NETDEV_TX_OK;
> +	return ret ? NETDEV_TX_BUSY : NETDEV_TX_OK;
>  }
>  
>  /*

Thats simply not true at all.

A start_xmit() cannot do that.

TX_BUSY should never be returned at all, its a deprecated code, for
pretty good reasons. (assuming queue is not stopped)

Try this on a machine with one CPU, I am pretty sure this can trigger
complete freezes.

Once softirq loops in your start_xmit(), how do you think one process
can help you now ?
