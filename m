From: Pankaj Gupta <pagupta@redhat.com>
Subject: Re: [PATCH v2 net-next 1/3] net: allow large number of rx queues
Date: Mon, 24 Nov 2014 13:43:39 -0500 (EST)
Message-ID: <640754143.3324569.1416854619120.JavaMail.zimbra@redhat.com>
References: <1416854032-10083-1-git-send-email-pagupta@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jasowang@redhat.com, dgibson@redhat.com,
	vfalico@gmail.com, edumazet@google.com, vyasevic@redhat.com,
	hkchu@google.com, xemul@parallels.com, therbert@google.com,
	bhutchings@solarflare.com, xii@google.com,
	stephen@networkplumber.org, jiri@resnulli.us,
	sergei shtylyov <sergei.shtylyov@cogentembedded.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416854032-10083-1-git-send-email-pagupta@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry! forgot to CC Michael, doing now.

> netif_alloc_rx_queues() uses kcalloc() to allocate memory
> for "struct netdev_queue *_rx" array.
> If we are doing large rx queue allocation kcalloc() might
> fail, so this patch does a fallback to vzalloc().
> Similar implementation is done for tx queue allocation in
> netif_alloc_netdev_queues().
> 
> We avoid failure of high order memory allocation
> with the help of vzalloc(), this allows us to do large
> rx and tx queue allocation which in turn helps us to
> increase the number of queues in tun.
> 
> As vmalloc() adds overhead on a critical network path,
> __GFP_REPEAT flag is used with kzalloc() to do this fallback
> only when really needed.
> 
> Signed-off-by: Pankaj Gupta <pagupta@redhat.com>
> Reviewed-by: Michael S. Tsirkin <mst@redhat.com>
> Reviewed-by: David Gibson <dgibson@redhat.com>
> ---
>  net/core/dev.c | 19 +++++++++++++------
>  1 file changed, 13 insertions(+), 6 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index e916ba8..abe9560 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -6059,17 +6059,25 @@ void netif_stacked_transfer_operstate(const struct
> net_device *rootdev,
>  EXPORT_SYMBOL(netif_stacked_transfer_operstate);
>  
>  #ifdef CONFIG_SYSFS
> +static void netif_free_rx_queues(struct net_device *dev)
> +{
> +	kvfree(dev->_rx);
> +}
> +
>  static int netif_alloc_rx_queues(struct net_device *dev)
>  {
>  	unsigned int i, count = dev->num_rx_queues;
>  	struct netdev_rx_queue *rx;
> +	size_t sz = count * sizeof(*rx);
>  
>  	BUG_ON(count < 1);
>  
> -	rx = kcalloc(count, sizeof(struct netdev_rx_queue), GFP_KERNEL);
> -	if (!rx)
> -		return -ENOMEM;
> -
> +	rx = kzalloc(sz, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
> +	if (!rx) {
> +		rx = vzalloc(sz);
> +		if (!rx)
> +			return -ENOMEM;
> +	}
>  	dev->_rx = rx;
>  
>  	for (i = 0; i < count; i++)
> @@ -6698,9 +6706,8 @@ void free_netdev(struct net_device *dev)
>  
>  	netif_free_tx_queues(dev);
>  #ifdef CONFIG_SYSFS
> -	kfree(dev->_rx);
> +	netif_free_rx_queues(dev);
>  #endif
> -
>  	kfree(rcu_dereference_protected(dev->ingress_queue, 1));
>  
>  	/* Flush device addresses */
> --
> 1.8.3.1
> 
> 
