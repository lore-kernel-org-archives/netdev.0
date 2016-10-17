From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH v3 net-next 2/2] net: deprecate eth_change_mtu, remove
 usage
Date: Mon, 17 Oct 2016 17:20:06 +0100
Message-ID: <20161017172006.4d549daa@jkicinski-Precision-T1700>
References: <20161002.224322.740109807229746275.davem@davemloft.net>
        <20161008020434.9691-1-jarod@redhat.com>
        <20161008020434.9691-3-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jarod Wilson <jarod@redhat.com>, David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161008020434.9691-3-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri,  7 Oct 2016 22:04:34 -0400, Jarod Wilson wrote:
> @@ -357,6 +356,8 @@ void ether_setup(struct net_device *dev)
>  	dev->type		= ARPHRD_ETHER;
>  	dev->hard_header_len 	= ETH_HLEN;
>  	dev->mtu		= ETH_DATA_LEN;
> +	dev->min_mtu		= ETH_MIN_MTU;
> +	dev->max_mtu		= ETH_DATA_LEN;
>  	dev->addr_len		= ETH_ALEN;
>  	dev->tx_queue_len	= 1000;	/* Ethernet wants good queues */
>  	dev->flags		= IFF_BROADCAST|IFF_MULTICAST;

This chunk seems to be breaking MTUs > 1500 for me.

On Fri,  7 Oct 2016 22:04:33 -0400, Jarod Wilson wrote:
> diff --git a/net/core/dev.c b/net/core/dev.c
> index f1fe26f..f376639 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -6499,9 +6499,18 @@ int dev_set_mtu(struct net_device *dev, int new_mtu)
>  	if (new_mtu == dev->mtu)
>  		return 0;
>  
> -	/*	MTU must be positive.	 */
> -	if (new_mtu < 0)
> +	/* MTU must be positive, and in range */
> +	if (new_mtu < 0 || new_mtu < dev->min_mtu) {
> +		net_err_ratelimited("%s: Invalid MTU %d requested, hw min %d\n",
> +				    dev->name, new_mtu, dev->min_mtu);
>  		return -EINVAL;
> +	}
> +
> +	if (dev->max_mtu > 0 && new_mtu > dev->max_mtu) {
> +		net_err_ratelimited("%s: Invalid MTU %d requested, hw max %d\n",
> +				    dev->name, new_mtu, dev->min_mtu);
> +		return -EINVAL;
> +	}

Please correct me if I'm wrong but it seems like we are now limiting
_all_ ethernet drivers to ETH_DATA_LEN in net-next.
