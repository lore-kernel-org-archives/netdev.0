From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 12/15] net: sched: lockless support for
 netif_schedule
Date: Wed, 7 Sep 2016 07:50:53 -0700
Message-ID: <57D0294D.50005@gmail.com>
References: <20160823202135.14368.62466.stgit@john-Precision-Tower-5810>
 <20160823202746.14368.6466.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com, jhs@mojatatu.com, davem@davemloft.net,
        brouer@redhat.com, xiyou.wangcong@gmail.com,
        alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:36627 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757366AbcIGOvI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 10:51:08 -0400
Received: by mail-pa0-f68.google.com with SMTP id ez1so1013207pab.3
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 07:51:08 -0700 (PDT)
In-Reply-To: <20160823202746.14368.6466.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-23 01:27 PM, John Fastabend wrote:
> netif_schedule uses a bit QDISC_STATE_SCHED to tell the qdisc layer
> if a run of the qdisc has been scheduler. This is important when
> tearing down qdisc instances. We can not rcu_free an instance for
> example if its possible that we might have outstanding references to
> it.
> 
> Perhaps more importantly in the per cpu lockless case we need to
> schedule a run of the qdisc on all qdiscs that are enqueu'ing packets
> and hitting the gso_skb requeue logic or else the skb may get stuck
> on the gso_skb queue without anything to finish the xmit.
> 
> This patch uses a reference counter instead of a bit to account for
> the multiple CPUs.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  include/net/sch_generic.h |    1 +
>  net/core/dev.c            |   32 +++++++++++++++++++++++---------
>  net/sched/sch_api.c       |    5 +++++
>  net/sched/sch_generic.c   |   15 ++++++++++++++-
>  4 files changed, 43 insertions(+), 10 deletions(-)
> 
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index 12df73d..cf4b3ea 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -93,6 +93,7 @@ struct Qdisc {
>  	seqcount_t		running;
>  	struct gnet_stats_queue	qstats;
>  	unsigned long		state;
> +	unsigned long __percpu	*cpu_state;
>  	struct Qdisc            *next_sched;
>  	struct sk_buff		*skb_bad_txq;
>  	struct rcu_head		rcu_head;
> diff --git a/net/core/dev.c b/net/core/dev.c
> index a0effa6..f638571 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2272,8 +2272,14 @@ static void __netif_reschedule(struct Qdisc *q)
>  
>  void __netif_schedule(struct Qdisc *q)
>  {
> -	if (!test_and_set_bit(__QDISC_STATE_SCHED, &q->state))
> +	if (q->flags & TCQ_F_NOLOCK) {
> +		unsigned long *s = this_cpu_ptr(q->cpu_state);
> +
> +		if (!test_and_set_bit(__QDISC_STATE_SCHED, s))
> +			__netif_reschedule(q);
> +	} else if (!test_and_set_bit(__QDISC_STATE_SCHED, &q->state)) {
>  		__netif_reschedule(q);
> +	}
>  }
>  EXPORT_SYMBOL(__netif_schedule);


I've had this lingering issue with this patchset that I think I've
pinned down. The issue manifests itself as a hang every once and awhile
when adding a new qdisc where the qdisc add code is stuck waiting for
the QDISC_STATE_SCHED bit to be zeroed.

The base issue is __netif_schedule gets called from other contexts
other than the enqueue()/dequeue() paths. In the dequeue() path if a
packet can not be pushed at the driver with this series it will park
the skb on one of the gso or bad pkt per cpu slots and signal
__netif_schedule to retry. This works because the skb is on the per
cpu slot of the running cpu and the __netif_schedule is signaled on
the running cpu so everything aligns.

However if the txq is frozen_or_stopped by the driver the dequeue
path in the qdisc layer just aborts and waits for the driver to signal
it to wake up via a netif_schedule call. But there is no guarantee that
the driver submitted netif_schedule call is going to come back on the
"right" per cpu.  Nor does the soft_irq structure have any way to signal
an interrupt on a specific cpu. So if the driver signals a soft_irq on
some other core than we happily process it but there is nothing to kick
the qdisc stack to dequeue packets on other cores.

TXQs tend to get frozen or stopped (netif_xmit_frozen_or_stopped) via
BQL or if you have flow control on which is how I got this to hang more
reliably.

I'm looking at coming up with some sort of fix now but not entirely
sure the best mechanism at the moment. One possibility is to not backoff
from the qdisc layer in the case of frozen_or_stopped queues and
believe that the txq really shouldn't be frozen_or_stopped for very
long. Another is to signal a soft_irq on any cpu core with packets which
we can "learn" via per cpu qlen values.

Any other ideas would be welcome. Just thought I would point out why
this series was taking so long to get a v2 out. Also behind on reviewing
other patches....

Thanks,
John
