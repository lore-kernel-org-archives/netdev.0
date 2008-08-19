From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 19 Aug 2008 18:48:31 +0200
Message-ID: <20080819164830.GA2533@ami.dom.local>
References: <20080819.040200.155911269.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:10519 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756502AbYHSQsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 12:48:07 -0400
Received: by ug-out-1314.google.com with SMTP id c2so528366ugf.37
        for <netdev@vger.kernel.org>; Tue, 19 Aug 2008 09:48:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080819.040200.155911269.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote, On 08/19/2008 01:02 PM:

> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Tue, 19 Aug 2008 20:58:15 +1000
> 
>> On Tue, Aug 19, 2008 at 08:55:51PM +1000, Herbert Xu wrote:
>>> On Tue, Aug 19, 2008 at 03:54:06AM -0700, David Miller wrote:
>>>> Every qdisc_run() will invoke __netif_schedule() so it is
>>>> a fast path I think :-)
>>> Argh, I meant __netif_reschedule which shouldn't be the fast path.
>> Nevermind, both paths call __netif_reschedule :)
>>

I can miss something, but probably it's needed in __netif_reschedule()
yet. Here is a scenario:

cpu1				cpu2
dev_deactivate()
dev_deactivate_queue()
qdisc_reset()
				qdisc_run()
				qdisc_watchdog_schedule()
				(or hrtimer_restart in cbq)
while (some_qdisc_is_busy())
return (qdisc not busy)
				hrtimer triggered
				__netif_schedule()
qdisc_destroy()			qdisc_run()
		
Jarek P.

>> OK, how about just moving it to the else clause in net_tx_action?
> 
> I just checked the following into net-2.6
> 
> pkt_sched: Prevent livelock in TX queue running.
> 
> If dev_deactivate() is trying to quiesce the queue, it
> is theoretically possible for another cpu to livelock
> trying to process that queue.  This happens because
> dev_deactivate() grabs the queue spinlock as it checks
> the queue state, whereas net_tx_action() does a trylock
> and reschedules the qdisc if it hits the lock.
> 
> This breaks the livelock by adding a check on
> __QDISC_STATE_DEACTIVATED to net_tx_action() when
> the trylock fails.
> 
> Based upon feedback from Herbert Xu and Jarek Poplawski.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/core/dev.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 8d13380..60c51f7 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1990,7 +1990,9 @@ static void net_tx_action(struct softirq_action *h)
>  				qdisc_run(q);
>  				spin_unlock(root_lock);
>  			} else {
> -				__netif_reschedule(q);
> +				if (!test_bit(__QDISC_STATE_DEACTIVATED,
> +					      &q->state))
> +					__netif_reschedule(q);
>  			}
>  		}
>  	}
