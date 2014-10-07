From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Quota in __qdisc_run() (was: qdisc: validate skb without holding
 lock)
Date: Tue, 07 Oct 2014 16:43:33 +0200
Message-ID: <1412693013.4140057.176149461.0FBF6CBD@webmail.messagingengine.com>
References: <20141003.145647.1980640682969765484.davem@davemloft.net>
 <1412373477.17245.5.camel@edumazet-glaptop2.roam.corp.google.com>
 <1412375467.17245.16.camel@edumazet-glaptop2.roam.corp.google.com>
 <20141003.153645.72976986956341944.davem@davemloft.net>
 <1412379044.17245.26.camel@edumazet-glaptop2.roam.corp.google.com>
 <20141007093441.35ce3a02@redhat.com>
 <1412686038.11091.111.camel@edumazet-glaptop2.roam.corp.google.com>
 <20141007153050.792c9743@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	therbert@google.com, fw@strlen.de, dborkman@redhat.com,
	jhs@mojatatu.com, alexander.duyck@gmail.com,
	john.r.fastabend@intel.com, dave.taht@gmail.com, toke@toke.dk
To: Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:42028 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753712AbaJGOne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 10:43:34 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by gateway2.nyi.internal (Postfix) with ESMTP id 595F820B40
	for <netdev@vger.kernel.org>; Tue,  7 Oct 2014 10:43:33 -0400 (EDT)
In-Reply-To: <20141007153050.792c9743@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 7, 2014, at 15:30, Jesper Dangaard Brouer wrote:
> On Tue, 07 Oct 2014 05:47:18 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > On Tue, 2014-10-07 at 09:34 +0200, Jesper Dangaard Brouer wrote:
> > > On Fri, 03 Oct 2014 16:30:44 -0700 Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > 
> > > > Another problem we need to address is the quota in __qdisc_run()
> > > > is no longer meaningfull, if each qdisc_restart() can pump many packets.
> > > 
> > > I fully agree. My earlier "magic" packet limit was covering/pampering
> > > over this issue.
> > 
> > Although quota was multiplied by 7 or 8 in worst case ?
> 
> Yes, exactly not a very elegant solution ;-)
> 
> 
> > > > An idea would be to use the bstats (or cpu_qstats if applicable)
> > > 
> > > Please elaborate some more, as I don't completely follow (feel free to
> > > show with a patch ;-)).
> > > 
> > 
> > I was hoping John could finish the percpu stats before I do that.
> > 
> > Problem with q->bstats.packets is that TSO packets with 45 MSS add 45 to
> > this counter.
> > 
> > Using a time quota would be better, but : jiffies is too big, and
> > local_clock() might be too expensive.
> 
> Hannes hacked up this patch for me... (didn't finish testing)
> 
> The basic idea is we want keep/restore the quota fairness between
> qdisc's , that we sort of broke with commit 5772e9a346 ("qdisc: bulk
> dequeue support for qdiscs with TCQ_F_ONETXQUEUE").
> 
> We choose not to account for the number of packets inside the TSO/GSO
> packets ("skb_gso_segs").  As the previous fairness also had this
> "defect".
> 
> You might view this as a short term solution, until you can fix it with
> your q->bstats.packets or time quota?
> 
> 
> [RFC PATCH] net_sched: restore quota limits after bulk dequeue
> 
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -57,17 +57,19 @@ static inline int dev_requeue_skb(struct sk_buff
> *skb, struct Qdisc *q)
>  
>  static void try_bulk_dequeue_skb(struct Qdisc *q,
>                                  struct sk_buff *skb,
> -                                const struct netdev_queue *txq)
> +                                const struct netdev_queue *txq,
> +                                int *quota)
>  {
>         int bytelimit = qdisc_avail_bulklimit(txq) - skb->len;
>  
> -       while (bytelimit > 0) {
> +       while (bytelimit > 0 && *quota > 0) {
>                 struct sk_buff *nskb = q->dequeue(q);
>  
>                 if (!nskb)
>                         break;
>  
>                 bytelimit -= nskb->len; /* covers GSO len */
> +               --*quota;
>                 skb->next = nskb;
>                 skb = nskb;
>         }
> @@ -77,7 +79,7 @@ static void try_bulk_dequeue_skb(struct Qdisc *q,
>  /* Note that dequeue_skb can possibly return a SKB list (via skb->next).
>   * A requeued skb (via q->gso_skb) can also be a SKB list.
>   */
> -static struct sk_buff *dequeue_skb(struct Qdisc *q, bool *validate)
> +static struct sk_buff *dequeue_skb(struct Qdisc *q, bool *validate, int
> *quota)
>  {
>         struct sk_buff *skb = q->gso_skb;
>         const struct netdev_queue *txq = q->dev_queue;
> @@ -87,18 +89,25 @@ static struct sk_buff *dequeue_skb(struct Qdisc *q,
> bool *validate)
>                 /* check the reason of requeuing without tx lock first */
>                 txq = skb_get_tx_queue(txq->dev, skb);
>                 if (!netif_xmit_frozen_or_stopped(txq)) {
> +                       struct sk_buff *iskb = skb;
> +
>                         q->gso_skb = NULL;
>                         q->q.qlen--;
> -               } else
> +                       do
> +                               --*quota;
> +                       while ((iskb = skb->next));

This needs to be:

do
   ...
while ((iskb = iskb->next))

Bye,
Hannes
