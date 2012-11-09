From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] kaweth:BQL support
Date: Fri, 09 Nov 2012 05:15:44 -0800
Message-ID: <1352466944.19779.556.camel@edumazet-glaptop>
References: <1352463587-23899-1-git-send-email-oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Oliver Neukum <oneukum@suse.de>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:39908 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751948Ab2KINPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 08:15:47 -0500
Received: by mail-ia0-f174.google.com with SMTP id y32so2702548iag.19
        for <netdev@vger.kernel.org>; Fri, 09 Nov 2012 05:15:47 -0800 (PST)
In-Reply-To: <1352463587-23899-1-git-send-email-oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-09 at 13:19 +0100, Oliver Neukum wrote:
> This adds the callbacks for the statistics necessary for BQL
> 
> Signed-off-by: Oliver Neukum <oneukum@suse.de>
> ---
>  drivers/net/usb/kaweth.c |    6 +++++-
>  1 files changed, 5 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
> index afb117c..f30e07f 100644
> --- a/drivers/net/usb/kaweth.c
> +++ b/drivers/net/usb/kaweth.c
> @@ -715,6 +715,7 @@ static int kaweth_open(struct net_device *net)
>  		usb_kill_urb(kaweth->rx_urb);
>  		goto err_out;
>  	}
> +	netdev_reset_queue(net);
>  	kaweth->opened = 1;
>  
>  	netif_start_queue(net);
> @@ -783,6 +784,7 @@ static void kaweth_usb_transmit_complete(struct urb *urb)
>  {
>  	struct kaweth_device *kaweth = urb->context;
>  	struct sk_buff *skb = kaweth->tx_skb;
> +	struct net_device *net = kaweth->net;
>  	int status = urb->status;
>  
>  	if (unlikely(status != 0))
> @@ -790,7 +792,8 @@ static void kaweth_usb_transmit_complete(struct urb *urb)
>  			dev_dbg(&urb->dev->dev, "%s: TX status %d.\n",
>  				kaweth->net->name, status);
>  
> -	netif_wake_queue(kaweth->net);
> +	netif_wake_queue(net);
> +	netdev_completed_queue(net, 1, skb->len - 2);
>  	dev_kfree_skb_irq(skb);
>  }
>  
> @@ -854,6 +857,7 @@ skip:
>  	{
>  		kaweth->stats.tx_packets++;
>  		kaweth->stats.tx_bytes += skb->len;
> +		netdev_sent_queue(net, skb->len - 2);
>  	}
>  
>  	spin_unlock_irq(&kaweth->device_lock);


I am curious to know if it changes anything on the behavior of this
network adapter ?

Because it seems queue is stopped anyway when a packet is in transmit.

(netif_stop_queue() in kaweth_start_xmit(), and netif_wake_queue() in
kaweth_usb_transmit_complete())

What I am missing ?

Thanks
