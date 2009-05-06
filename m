From: Vladimir Ivashchenko <hazard@francoudi.com>
Subject: Re: bond + tc regression ?
Date: Wed, 06 May 2009 21:45:18 +0300
Message-ID: <1241635518.13702.37.camel@hazard2.francoudi.com>
References: <1241538358.27647.9.camel@hazard2.francoudi.com>
	 <4A0069F3.5030607@cosmosbay.com> <20090505174135.GA29716@francoudi.com>
	 <4A008A72.6030607@cosmosbay.com> <20090505235008.GA17690@francoudi.com>
	 <4A0105A8.3060707@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cerber.thunderworx.net ([217.27.32.18]:2414 "EHLO
	cerber.thunderworx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759646AbZEFSpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 14:45:20 -0400
In-Reply-To: <4A0105A8.3060707@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2009-05-06 at 05:36 +0200, Eric Dumazet wrote:

> Ah, I forgot about one patch that could help your setup too (if using more than one
> cpu on NIC irqs of course), queued for 2.6.31

I have tried the patch. Didn't make a noticeable difference. Under 850
mbps HTB+sfq load, 2.6.29.1, four NICs / two bond ifaces, IRQ balancing,
the dual-core server has only 25% idle on each CPU.

What's interesting, the same 850mbps load, identical machine, but with
only two NICs and no bond, HTB+esfq, kernel 2.6.21.2 => 60% CPU idle.
2.5x overhead.

> (commit 6a321cb370ad3db4ba6e405e638b3a42c41089b0)
> 
> You could post oprofile results to help us finding other hot spots.
> 
> 
> [PATCH] net: netif_tx_queue_stopped too expensive
> 
> netif_tx_queue_stopped(txq) is most of the time false.
> 
> Yet its cost is very expensive on SMP.
> 
> static inline int netif_tx_queue_stopped(const struct netdev_queue *dev_queue)
> {
> 	return test_bit(__QUEUE_STATE_XOFF, &dev_queue->state);
> }
> 
> I saw this on oprofile hunting and bnx2 driver bnx2_tx_int().
> 
> We probably should split "struct netdev_queue" in two parts, one
> being read mostly.
> 
> __netif_tx_lock() touches _xmit_lock & xmit_lock_owner, these
> deserve a separate cache line.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> 
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 2e7783f..1caaebb 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -447,12 +447,18 @@ enum netdev_queue_state_t
>  };
>  
>  struct netdev_queue {
> +/*
> + * read mostly part
> + */
>  	struct net_device	*dev;
>  	struct Qdisc		*qdisc;
>  	unsigned long		state;
> -	spinlock_t		_xmit_lock;
> -	int			xmit_lock_owner;
>  	struct Qdisc		*qdisc_sleeping;
> +/*
> + * write mostly part
> + */
> +	spinlock_t		_xmit_lock ____cacheline_aligned_in_smp;
> +	int			xmit_lock_owner;
>  } ____cacheline_aligned_in_smp;
>  
> 
-- 
Best Regards,
Vladimir Ivashchenko
Chief Technology Officer
PrimeTel PLC, Cyprus - www.prime-tel.com
Tel: +357 25 100100 Fax: +357 2210 2211


