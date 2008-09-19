From: "Alexander Duyck" <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH] sched: only dequeue if packet can be queued to hardware queue.
Date: Thu, 18 Sep 2008 18:11:45 -0700
Message-ID: <5f2db9d90809181811q74c3211fp9a099acb8e895fd4@mail.gmail.com>
References: <20080918063036.27934.91273.stgit@localhost.localdomain>
	 <20080918194419.GA2982@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Alexander Duyck" <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	davem@davemloft.net, kaber@trash.net
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.178]:59486 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755527AbYISBLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 21:11:48 -0400
Received: by el-out-1112.google.com with SMTP id z25so51967ele.1
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2008 18:11:45 -0700 (PDT)
In-Reply-To: <20080918194419.GA2982@ami.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 18, 2008 at 12:44 PM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> I think, these changes make sense only if they don't add more then give,
> and two dequeues (and still no way to kill requeue) is IMHO too much.
> (I mean the maintenance.) As far as I can see it's mainly for HFSC's
> qdisc_peek_len(), anyway this looks like main issue to me.

The thing is this was just meant to be a proof of concept for the most
part so I was doing a lot of cut and paste coding, and as a result the
size increased by a good amount.  I admit this could be cleaned up a
lot I just wanted to verify some things.

Also my ultimate goal wasn't to kill requeue completely as you can't
do that since in the case of TSO/GSO you will end up with SKBs which
require multiple transmit descriptors and therefore you will always
need an option to requeue.  The advantage with this approach is that
you don't incur the CPU cost, which is a significant savings when you
compare the requeue approach which was generating 13% cpu to the smart
dequeue which was only using 3%.

> Below a few small doubts. (I need to find some time for details yet.)
> BTW, this patch needs a checkpatch run.

I did run checkpatch on this.  Most of the errors are inherited from
the cut and paste and I didn't want to take the time to completely
rewrite the core qdisc functionality.  Other than those errors I
believe some were whitespace complaints as I was using tabs to the
start of my functions and then spaces to indent my function parameters
in the case of having to wrap for long lines.

> ---
> diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
> index b786a5b..4082f39 100644
> --- a/include/net/pkt_sched.h
> +++ b/include/net/pkt_sched.h
> @@ -90,10 +90,7 @@ extern void __qdisc_run(struct Qdisc *q);
>
>  static inline void qdisc_run(struct Qdisc *q)
>  {
> -       struct netdev_queue *txq = q->dev_queue;
> -
> -       if (!netif_tx_queue_stopped(txq) &&
>
> I think, there is no reason to do a full dequeue try each time instead
> of this check, even if we save on requeuing now. We could try to save
> the result of the last dequeue, e.g. a number or some mask of a few
> tx_queues which prevented dequeuing, and check for the change of state
> only. (Or alternatively, what I mentioned before: a flag set with the
> full stop or freeze.)

Once again if you have a suggestion on approach feel free to modify
the patch and see how it works for you.  My only concern is that there
are several qdiscs which won't give you the same packet twice and so
you don't know what is going to pop out until you go in and check.

>
> -           !test_and_set_bit(__QDISC_STATE_RUNNING, &q->state))
> +       if (!test_and_set_bit(__QDISC_STATE_RUNNING, &q->state))
>                __qdisc_run(q);
>  }
>
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index e556962..4400a18 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> ...
> +static inline struct sk_buff *__qdisc_smart_dequeue(struct Qdisc *sch,
> +                                                   struct sk_buff_head *list)
> +{
> +       struct sk_buff *skb = skb_peek(list);
>
> Since success is much more likely here, __skb_dequeue() with
> __skb_queue_head() on fail looks better to me.
>
> Of course, it's a matter of taste, but (if we really need these two
> dequeues) maybe qdisc_dequeue_smart() would be more in line with
> qdisc_dequeue_head()? (And similarly smart names below.)

Right, but then we are getting back to the queue/requeue stuff.  If
you want feel free to make use of my patch to generate your own that
uses that approach.  I just don't like changing things unless I
absolutely have to and all I did is essentially tear apart
__skb_dequeue and place the bits inline with my testing for
netif_tx_subqueue_stopped.

> +       struct netdev_queue *txq;
> +
> +       if (!skb)
> +               return NULL;
> +
> +       txq = netdev_get_tx_queue(qdisc_dev(sch), skb_get_queue_mapping(skb));
> +       if (netif_tx_queue_stopped(txq) || netif_tx_queue_frozen(txq)) {
> +               sch->flags |= TCQ_F_STOPPED;
> +               return NULL;
> +       }
> +       __skb_unlink(skb, list);
> +       sch->qstats.backlog -= qdisc_pkt_len(skb);
> +       sch->flags &= ~TCQ_F_STOPPED;
>
> This clearing is probably needed in ->reset() and in ->drop() too.
> (Or above, after if (!skb))

For the most part I would agree with you, but for now I was only using
the flag as a part of the smart_dequeue process to flag the upper
queues so I didn't give it much thought.  It is yet another thing I
probably should have cleaned up but didn't get around to since this
was mostly proof of concept.

> ...
> diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
> index d14f020..4da1a85 100644
> --- a/net/sched/sch_htb.c
> +++ b/net/sched/sch_htb.c
> ...
> +static struct sk_buff *htb_smart_dequeue(struct Qdisc *sch)
> +{
> +       struct sk_buff *skb = NULL;
> +       struct htb_sched *q = qdisc_priv(sch);
> +       int level, stopped = false;
> +       psched_time_t next_event;
> +
> +       /* try to dequeue direct packets as high prio (!) to minimize cpu work */
> +       skb = skb_peek(&q->direct_queue);
>
> As above: __skb_dequeue()?

Actually I could probably replace most of the skb_peek stuff with
calls to __qdisc_smart_dequeue instead and then just check for the
flag on fail.

> Thanks,
> Jarek P.

I probably won't be able to contribute to this for at least the next
two weeks since I am going to be out for vacation from Saturday until
the start of October.

In the meantime I also just threw a couple of patches out which may
help anyone who is trying to test this stuff.  Turns out if you try to
do a netperf UDP_STREAM test on a multiqueue aware system with 2.6.27
you get horrible performance on the receive side.  The root cause
appears to be that simple_tx_hash was doing a hash on fragmented
packets and as a result placing packets in psuedo random queues which
caused issues with packet ordering.

Thanks,

Alex
