From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v2 8/9] xen-netback: Timeout packets in RX path
Date: Fri, 13 Dec 2013 15:44:06 +0000
Message-ID: <20131213154406.GO21900@zion.uk.xensource.com>
References: <1386892097-15502-1-git-send-email-zoltan.kiss@citrix.com>
 <1386892097-15502-9-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1386892097-15502-9-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 12, 2013 at 11:48:16PM +0000, Zoltan Kiss wrote:
> A malicious or buggy guest can leave its queue filled indefinitely, in which
> case qdisc start to queue packets for that VIF. If those packets came from an
> another guest, it can block its slots and prevent shutdown. To avoid that, we
> make sure the queue is drained in every 10 seconds
> 

Oh I see where the 10 second constraint in previous patch comes from.

Could you define a macro for this constant then use it everywhere.

> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> ---
[...]
> +static void xenvif_wake_queue(unsigned long data)
> +{
> +	struct xenvif *vif = (struct xenvif *)data;
> +
> +	netdev_err(vif->dev, "timer fires\n");

What timer? This error message needs to be more specific.

> +	if (netif_queue_stopped(vif->dev)) {
> +		netdev_err(vif->dev, "draining TX queue\n");
> +		netif_wake_queue(vif->dev);
> +	}
> +}
> +
>  static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  {
>  	struct xenvif *vif = netdev_priv(dev);
> @@ -141,8 +152,13 @@ static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	 * then turn off the queue to give the ring a chance to
>  	 * drain.
>  	 */
> -	if (!xenvif_rx_ring_slots_available(vif, min_slots_needed))
> +	if (!xenvif_rx_ring_slots_available(vif, min_slots_needed)) {
> +		vif->wake_queue.function = xenvif_wake_queue;
> +		vif->wake_queue.data = (unsigned long)vif;
>  		xenvif_stop_queue(vif);
> +		mod_timer(&vif->wake_queue,
> +			jiffies + rx_drain_timeout_jiffies);
> +	}
>  

Do you need to use jiffies_64 instead of jiffies?

This timer is only armed when ring is full. So what happens when the
ring is not full and some other parts of the system holds on to the
packets forever? Can this happen?

Wei.
