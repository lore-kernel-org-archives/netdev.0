From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [patch v2] net: hip04: Make tx coalesce timer actually work
Date: Wed, 15 Apr 2015 10:24:16 +0800
Message-ID: <552DCBD0.5030607@huawei.com>
References: <alpine.DEB.2.11.1504132338080.3845@nanos> <3040901.Bp3bfgc1te@wuerfel> <alpine.DEB.2.11.1504140007570.3845@nanos> <20150414.141529.797692010779414843.davem@davemloft.net> <alpine.DEB.2.11.1504142140290.3845@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <arnd@arndb.de>, <linux-kernel@vger.kernel.org>,
	<peterz@infradead.org>, <mingo@kernel.org>,
	<zhangfei.gao@linaro.org>, <dan.carpenter@oracle.com>,
	<netdev@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.11.1504142140290.3845@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015/4/15 3:42, Thomas Gleixner wrote:
> The code sets the expiry value of the timer to a relative value and
> starts it with hrtimer_start_expires. That's fine, but that only works
> once. The timer is started in relative mode, so the expiry value gets
> overwritten with the absolut expiry time (now + expiry).
> 
> So once the timer expired, a new call to hrtimer_start_expires results
> in an immidiately expired timer, because the expiry value is
> already in the past.
> 
> Use the proper mechanisms to (re)start the timer in the intended way.
> 

Acked-by: Ding Tianhong <dingtianhong@huawei.com>

> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: dingtianhong <dingtianhong@huawei.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: Zhangfei Gao <zhangfei.gao@linaro.org>
> Cc: Dan Carpenter <dan.carpenter@oracle.com>
> Cc: netdev@vger.kernel.org
> ---
>  drivers/net/ethernet/hisilicon/hip04_eth.c |   18 +++++++++++-------
>  1 file changed, 11 insertions(+), 7 deletions(-)
> 
> Index: linux/drivers/net/ethernet/hisilicon/hip04_eth.c
> ===================================================================
> --- linux.orig/drivers/net/ethernet/hisilicon/hip04_eth.c
> +++ linux/drivers/net/ethernet/hisilicon/hip04_eth.c
> @@ -413,6 +413,15 @@ out:
>  	return count;
>  }
>  
> +static void hip04_start_tx_timer(struct hip04_priv *priv)
> +{
> +	unsigned long ns = priv->tx_coalesce_usecs * NSEC_PER_USEC / 2;
> +
> +	/* allow timer to fire after half the time at the earliest */
> +	hrtimer_start_range_ns(&priv->tx_coalesce_timer, ns_to_ktime(ns),
> +			       ns, HRTIMER_MODE_REL);
> +}
> +
>  static int hip04_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>  {
>  	struct hip04_priv *priv = netdev_priv(ndev);
> @@ -466,8 +475,7 @@ static int hip04_mac_start_xmit(struct s
>  		}
>  	} else if (!hrtimer_is_queued(&priv->tx_coalesce_timer)) {
>  		/* cleanup not pending yet, start a new timer */
> -		hrtimer_start_expires(&priv->tx_coalesce_timer,
> -				      HRTIMER_MODE_REL);
> +		hip04_start_tx_timer(priv);
>  	}
>  
>  	return NETDEV_TX_OK;
> @@ -549,7 +557,7 @@ done:
>  	/* clean up tx descriptors and start a new timer if necessary */
>  	tx_remaining = hip04_tx_reclaim(ndev, false);
>  	if (rx < budget && tx_remaining)
> -		hrtimer_start_expires(&priv->tx_coalesce_timer, HRTIMER_MODE_REL);
> +		hip04_start_tx_timer(priv);
>  
>  	return rx;
>  }
> @@ -809,7 +817,6 @@ static int hip04_mac_probe(struct platfo
>  	struct hip04_priv *priv;
>  	struct resource *res;
>  	unsigned int irq;
> -	ktime_t txtime;
>  	int ret;
>  
>  	ndev = alloc_etherdev(sizeof(struct hip04_priv));
> @@ -846,9 +853,6 @@ static int hip04_mac_probe(struct platfo
>  	 */
>  	priv->tx_coalesce_frames = TX_DESC_NUM * 3 / 4;
>  	priv->tx_coalesce_usecs = 200;
> -	/* allow timer to fire after half the time at the earliest */
> -	txtime = ktime_set(0, priv->tx_coalesce_usecs * NSEC_PER_USEC / 2);
> -	hrtimer_set_expires_range(&priv->tx_coalesce_timer, txtime, txtime);
>  	priv->tx_coalesce_timer.function = tx_done;
>  
>  	priv->map = syscon_node_to_regmap(arg.np);
> 
> .
> 
