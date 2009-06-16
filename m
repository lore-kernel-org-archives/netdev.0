From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC net 02/03]: allow to propagate errors through
	->ndo_hard_start_xmit()
Date: Tue, 16 Jun 2009 09:25:31 +0000
Message-ID: <20090616092531.GA6106@ff.dom.local>
References: <20090609161700.6730.4204.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:58516 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752843AbZFPJZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 05:25:35 -0400
Received: by bwz9 with SMTP id 9so3892770bwz.37
        for <netdev@vger.kernel.org>; Tue, 16 Jun 2009 02:25:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090609161700.6730.4204.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09-06-2009 18:17, Patrick McHardy wrote:
> commit c2104095c3a1023b4f4809c90092145dff093c88
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Tue Jun 9 17:55:34 2009 +0200
> 
>     net: allow to propagate errors through ->ndo_hard_start_xmit()
>     
...
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 11560e3..b2e9953 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1731,6 +1731,8 @@ gso:
>  		nskb->next = NULL;
>  		rc = ops->ndo_start_xmit(nskb, dev);
>  		if (unlikely(rc)) {
> +			if (rc & ~NETDEV_TX_MASK)
> +				return rc;

This is probably not enough: what about the rest of the skb
(qdisc_restart() would skip requeuing)?

Jarek P.

>  			nskb->next = skb->next;
>  			skb->next = nskb;
>  			return rc;
> @@ -1895,8 +1897,9 @@ gso:
>  			HARD_TX_LOCK(dev, txq, cpu);
>  
>  			if (!netif_tx_queue_stopped(txq)) {
> -				rc = 0;
> -				if (!dev_hard_start_xmit(skb, dev, txq)) {
> +				rc = dev_hard_start_xmit(skb, dev, txq);
> +				if (rc == NETDEV_TX_OK || rc < 0 ||
> +				    rc & NET_XMIT_MASK) {
>  					HARD_TX_UNLOCK(dev, txq);
>  					goto out;
>  				}
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index 27d0381..7e3e514 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -143,8 +143,16 @@ static inline int qdisc_restart(struct Qdisc *q)
>  
>  	HARD_TX_LOCK(dev, txq, smp_processor_id());
>  	if (!netif_tx_queue_stopped(txq) &&
> -	    !netif_tx_queue_frozen(txq))
> +	    !netif_tx_queue_frozen(txq)) {
>  		ret = dev_hard_start_xmit(skb, dev, txq);
> +
> +		/* an error implies that the skb was consumed */
> +		if (ret < 0)
> +			ret = NETDEV_TX_OK;
> +
> +		/* all NET_XMIT codes map to NETDEV_TX_OK */
> +		ret &= ~NET_XMIT_MASK;
> +	}
>  	HARD_TX_UNLOCK(dev, txq);
>  
>  	spin_lock(root_lock);
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 



