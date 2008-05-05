From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH]: cpmac bugfixes and enhancements
Date: Mon, 5 May 2008 16:16:34 -0700
Message-ID: <20080505161634.6964d46b.akpm@linux-foundation.org>
References: <200805041904.22726.matteo@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, ralf@linux-mips.org, nbd@openwrt.org,
	ejka@imfi.kspu.ru, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
To: Matteo Croce <matteo@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49414 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763254AbYEEXRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 19:17:51 -0400
In-Reply-To: <200805041904.22726.matteo@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 4 May 2008 19:04:22 +0200
Matteo Croce <matteo@openwrt.org> wrote:

> This patch fixes an IRQ storm, a locking issues, moves platform code in the right sections
> and other small fixes.
> 

Please feed this patch (and all future ones) through scripts/checkpatch.pl.
It picks up rather a lot of simple problems which there is no reason for
us to retain.

>
> ...
>
> +	spin_unlock(&priv->rx_lock);
> +	netif_rx_complete(priv->dev, napi);
> +	netif_stop_queue(priv->dev);
> +	napi_disable(&priv->napi);
> +	
> +	atomic_inc(&priv->reset_pending);
> +	cpmac_hw_stop(priv->dev);
> +	if (!schedule_work(&priv->reset_work))
> +		atomic_dec(&priv->reset_pending);
> +	return 0;
> + 
>  }
>  
>  static int cpmac_start_xmit(struct sk_buff *skb, struct net_device *dev)
> @@ -456,6 +549,9 @@ static int cpmac_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	struct cpmac_desc *desc;
>  	struct cpmac_priv *priv = netdev_priv(dev);
>  
> +	if (unlikely(atomic_read(&priv->reset_pending)))
> +		return NETDEV_TX_BUSY;
> +

This looks a bit strange.  schedule_work() will return zero if the work was
already scheduled, in which case we arrange for cpmac_start_xmit() to abort
early.

But if schedule_work() *doesn't* return zero, there is a time window in
which the reset is still pending.  Because it takes time for keventd to be
awoken and to run the work function.

I would have thought that we would want to prevent cpmac_start_xmit() from
running within that time window also?


But that's just a guess - the text which you used to describe your work is
missing much information, so I don't have a lot to work with here.
