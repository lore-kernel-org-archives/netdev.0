From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v3 8/9] xen-netback: Timeout packets in RX path
Date: Wed, 8 Jan 2014 21:34:21 +0000
Message-ID: <52CDC45D.3050509@citrix.com>
References: <1389139818-24458-1-git-send-email-zoltan.kiss@citrix.com> <1389139818-24458-9-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	Paul Durrant <Paul.Durrant@citrix.com>
To: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:42400 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757378AbaAHVeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 16:34:25 -0500
In-Reply-To: <1389139818-24458-9-git-send-email-zoltan.kiss@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just realized when answering Ma's mail that this doesn't cause the 
desired effect after Paul's flow control improvement: starting the queue 
doesn't drop the packets which cannot fit the ring. Which in fact might 
be not good. We are adding the skb to vif->rx_queue even when 
xenvif_rx_ring_slots_available(vif, min_slots_needed) said there is no 
space for that. Or am I missing something? Paul?

Zoli

On 08/01/14 00:10, Zoltan Kiss wrote:
> A malicious or buggy guest can leave its queue filled indefinitely, in which
> case qdisc start to queue packets for that VIF. If those packets came from an
> another guest, it can block its slots and prevent shutdown. To avoid that, we
> make sure the queue is drained in every 10 seconds.
...
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index 95fcd63..ce032f9 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -114,6 +114,16 @@ static irqreturn_t xenvif_interrupt(int irq, void *dev_id)
>   	return IRQ_HANDLED;
>   }
>
> +static void xenvif_wake_queue(unsigned long data)
> +{
> +	struct xenvif *vif = (struct xenvif *)data;
> +
> +	if (netif_queue_stopped(vif->dev)) {
> +		netdev_err(vif->dev, "draining TX queue\n");
> +		netif_wake_queue(vif->dev);
> +	}
> +}
> +
>   static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
>   {
>   	struct xenvif *vif = netdev_priv(dev);
> @@ -143,8 +153,13 @@ static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
>   	 * then turn off the queue to give the ring a chance to
>   	 * drain.
>   	 */
> -	if (!xenvif_rx_ring_slots_available(vif, min_slots_needed))
> +	if (!xenvif_rx_ring_slots_available(vif, min_slots_needed)) {
> +		vif->wake_queue.function = xenvif_wake_queue;
> +		vif->wake_queue.data = (unsigned long)vif;
>   		xenvif_stop_queue(vif);
> +		mod_timer(&vif->wake_queue,
> +			jiffies + rx_drain_timeout_jiffies);
> +	}
>
>   	skb_queue_tail(&vif->rx_queue, skb);
>   	xenvif_kick_thread(vif);
