From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net 2/2] net: core: explicitly select a txq before doing
 l2 forwarding
Date: Tue, 07 Jan 2014 00:22:37 -0800
Message-ID: <52CBB94D.6010405@intel.com>
References: <1388978467-2075-1-git-send-email-jasowang@redhat.com> <1388978467-2075-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com,
	Neil Horman <nhorman@tuxdriver.com>,
	e1000-devel@lists.sourceforge.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388978467-2075-2-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/5/2014 7:21 PM, Jason Wang wrote:
> Currently, the tx queue were selected implicitly in ndo_dfwd_start_xmit(). The
> will cause several issues:
>
> - NETIF_F_LLTX was forced for macvlan device in this case which lead extra lock
>    contention.
> - dev_hard_start_xmit() was called with NULL txq which bypasses the net device
>    watchdog
> - dev_hard_start_xmit() does not check txq everywhere which will lead a crash
>    when tso is disabled for lower device.
>
> Fix this by explicitly introducing a select queue method just for l2 forwarding
> offload (ndo_dfwd_select_queue), and introducing dfwd_direct_xmit() to do the
> queue selecting and transmitting for l2 forwarding.
>
> With this fixes, NETIF_F_LLTX could be preserved for macvlan and there's no need
> to check txq against NULL in dev_hard_start_xmit().
>
> In the future, it was also required for macvtap l2 forwarding support since it
> provides a necessary synchronization method.
>
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Cc: e1000-devel@lists.sourceforge.net
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---

[...]

> index 4fc1722..bc2b03f 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2538,6 +2538,32 @@ static inline int skb_needs_linearize(struct sk_buff *skb,
>   				!(features & NETIF_F_SG)));
>   }
>
> +int dfwd_direct_xmit(struct sk_buff *skb, struct net_device *dev,
> +		     void *accel_priv)
> +{
> +	struct netdev_queue *txq;
> +	int ret = NETDEV_TX_BUSY;
> +	int index;
> +
> +	BUG_ON(!dev->netdev_ops->ndo_dfwd_select_queue);
> +	index =	dev->netdev_ops->ndo_dfwd_select_queue(dev, skb,
> +						       accel_priv);
> +
> +	local_bh_disable();
> +
> +	skb_set_queue_mapping(skb, index);

How about replacing the index calculation and skb_set_queue_mapping with
netdev_pick_tx(). Then we don't need to add a new op and the existing
XPS, tx hash and select_queue() op works.

> +	txq = netdev_get_tx_queue(dev, index);
> +
> +	HARD_TX_LOCK(dev, txq, smp_processor_id());
> +	if (!netif_xmit_frozen_or_stopped(txq))
> +		ret = dev_hard_start_xmit(skb, dev, txq, accel_priv);
> +	HARD_TX_UNLOCK(dev, txq);
> +
> +	local_bh_enable();
> +	return ret;
> +}
> +EXPORT_SYMBOL_GPL(dfwd_direct_xmit);
> +
>   int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
>   			struct netdev_queue *txq, void *accel_priv)
>   {
> @@ -2611,7 +2637,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
>   			rc = ops->ndo_start_xmit(skb, dev);
>
>   		trace_net_dev_xmit(skb, rc, dev, skb_len);
> -		if (rc == NETDEV_TX_OK && txq)
> +		if (rc == NETDEV_TX_OK)
>   			txq_trans_update(txq);

Removing the check here rather than adding more checks in the gso case
as I suggested in the other thread seems cleaner.

Thanks!
John


>   		return rc;
>   	}
>
