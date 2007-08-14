From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: Re: [PATCH] xen-netfront: Avoid deref'ing skbafter it is potentially freed.
Date: Tue, 14 Aug 2007 02:03:30 +0200
Message-ID: <200708140203.30711.jesper.juhl@gmail.com>
References: <46C0B6FD.7020701@goop.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, NetDev <netdev@vger.kernel.org>,
	Keir Fraser <keir@xensource.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jesper Juhl <jesper.juhl@gmail.com>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:9049 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756429AbXHNAF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2007 20:05:58 -0400
Received: by ug-out-1314.google.com with SMTP id j3so33126ugf
        for <netdev@vger.kernel.org>; Mon, 13 Aug 2007 17:05:57 -0700 (PDT)
In-Reply-To: <46C0B6FD.7020701@goop.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 13 August 2007 21:54:37 Jeremy Fitzhardinge wrote:
> xennet_tx_bug_gc can free the skb before we use it, so make sure we don't.
> 
> Jeff, this is -rc material.
> 
> Signed-off-by: Keir Fraser <keir@xensource.com>
> Signed-off-by: Jeremy Fitzhardinge <jeremy@xensource.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> 
> diff -r 8bfc43f6d1b0 drivers/net/xen-netfront.c
> --- a/drivers/net/xen-netfront.c	Tue Aug 07 14:26:30 2007 -0700
> +++ b/drivers/net/xen-netfront.c	Mon Aug 13 09:39:15 2007 -0700
> @@ -566,15 +566,16 @@ static int xennet_start_xmit(struct sk_b
>  	if (notify)
>  		notify_remote_via_irq(np->netdev->irq);
>  
> +	np->stats.tx_bytes += skb->len;
> +	np->stats.tx_packets++;
> +
> +	/* Note: It is not safe to access skb after xennet_tx_buf_gc()! */
>  	xennet_tx_buf_gc(dev);
>  
>  	if (!netfront_tx_slot_available(np))
>  		netif_stop_queue(dev);
>  
>  	spin_unlock_irq(&np->tx_lock);
> -
> -	np->stats.tx_bytes += skb->len;
> -	np->stats.tx_packets++;
>  
>  	return 0;
>  
This moves the updating of both tx_bytes and tx_packets inside the 
spinlock, but as far as I can see we only _really_ need to move the 
tx_bytes update. Considering that we generally want to do as little 
work as possible while holding a lock, wouldn't the following be 
slightly better?


Signed-off-by: Keir Fraser <keir@xensource.com>
Signed-off-by: Jeremy Fitzhardinge <jeremy@xensource.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
---

 drivers/net/xen-netfront.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 489f69c..640e270 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -566,6 +566,9 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (notify)
 		notify_remote_via_irq(np->netdev->irq);
 
+	np->stats.tx_bytes += skb->len;
+
+	/* Note: It is not safe to access skb after xennet_tx_buf_gc()! */
 	xennet_tx_buf_gc(dev);
 
 	if (!netfront_tx_slot_available(np))
@@ -573,7 +576,6 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	spin_unlock_irq(&np->tx_lock);
 
-	np->stats.tx_bytes += skb->len;
 	np->stats.tx_packets++;
 
 	return 0;
