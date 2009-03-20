From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC] net: release dst entry in dev_queue_xmit()
Date: Fri, 20 Mar 2009 10:10:49 -0400
Message-ID: <20090320141049.GA10367@hmsreliant.think-freely.org>
References: <49C380A6.4000904@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48995 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752866AbZCTOLF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 10:11:05 -0400
Content-Disposition: inline
In-Reply-To: <49C380A6.4000904@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2009 at 12:40:22PM +0100, Eric Dumazet wrote:
> One point of contention in high network loads is the dst_release() performed
> when a transmited skb is freed. This is because NIC tx completion calls skb free
> long after original call to dev_queue_xmit(skb).
> 
> CPU cache is cold and the atomic op in dst_release() stalls. On SMP, this is
> quite visible if one CPU is 100% handling softirqs for a network device,
> since dst_clone() is done by other cpus, involving cache line ping pongs.
> 
> I believe we can release dst in dev_queue_xmit(), while cpu cache is hot, since
> caller of dev_queue_xmit() had to hold a reference on dst right before. This reduce
> work to be done by softirq handler, and decrease cache misses.
> 
> I also believe only pktgen can call dev_queue_xmit() with skb which have
> a skb->users != 1. But pkthen skbs have a NULL dst entry.
> 
> I added a WARN_ON_ONCE() to catch other cases, and not release skb->dst
> if skb->users != 1
> 
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> 
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index f112970..9e0fd01 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1852,6 +1852,20 @@ gso:
>  	if (q->enqueue) {
>  		spinlock_t *root_lock = qdisc_lock(q);
>  
> +		/*
> +		 * Release dst while its refcnt is hot in CPU cache, instead
> +		 * of waiting NIC tx completion
> +		 */
> +		if (likely(skb->dst)) {
> +			if (!WARN_ON_ONCE(atomic_read(&skb->users) != 1)) {
> +				int newrefcnt;
> +
> +				smp_mb__before_atomic_dec();
> +				newrefcnt = atomic_dec_return(&skb->dst->__refcnt);
> +				WARN_ON(newrefcnt < 0);
> +				skb->dst = NULL;
> +			}
> +		}
>  		spin_lock(root_lock);
>  
>  		if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

I think this seems like a pretty good idea.  I thought for a moment that some
stacked interfaces (bonds, vlan devices), might have a problem with this, since
they tend to pass through dev_queue_xmit twice, but I can't see a problem with
either one of those cases either, since neither of thier xmit routines makes any
use of the dst pointer.  I'd say include it

Acked-by: Neil Horman <nhorman@tuxdriver.com>

