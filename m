From: Tom Herbert <therbert@google.com>
Subject: Re: [RFC net-next PATCH V2 2/3] qdisc: bulk dequeue support for
 qdiscs with TCQ_F_ONETXQUEUE
Date: Thu, 4 Sep 2014 09:59:34 -0700
Message-ID: <CA+mtBx9LEt25oPNGpNVQngCvq-NSPohD=Dmrpogzbq_Kwcm5ww@mail.gmail.com>
References: <20140904125247.4108.8132.stgit@dragon>
	<20140904125438.4108.38160.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:39346 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754451AbaIDQ7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 12:59:35 -0400
Received: by mail-ig0-f179.google.com with SMTP id r2so1482307igi.12
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2014 09:59:34 -0700 (PDT)
In-Reply-To: <20140904125438.4108.38160.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 4, 2014 at 5:55 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> Based on DaveM's recent API work on dev_hard_start_xmit(), that allows
> sending/processing an entire skb list.
>
> This patch implements qdisc bulk dequeue, by allowing multiple packets
> to be dequeued in dequeue_skb().
>
> The optimization principle for this is two fold, (1) to amortize
> locking cost and (2) avoid expensive tailptr update for notifying HW.
>  (1) Several packets are dequeued while holding the qdisc root_lock,
> amortizing locking cost over several packet.  The dequeued SKB list is
> processed under the TXQ lock in dev_hard_start_xmit(), thus also
> amortizing the cost of the TXQ lock.
>  (2) Further more, dev_hard_start_xmit() will utilize the skb->xmit_more
> API to delay HW tailptr update, which also reduces the cost per
> packet.
>
> One restriction of the new API is that every SKB must belong to the
> same TXQ.  This patch takes the easy way out, by restricting bulk
> dequeue to qdisc's with the TCQ_F_ONETXQUEUE flag, that specifies the
> qdisc only have attached a single TXQ.
>
> Some detail about the flow; dev_hard_start_xmit() will process the skb
> list, and transmit packets individually towards the driver (see
> xmit_one()).  In case the driver stops midway in the list, the
> remaining skb list is returned by dev_hard_start_xmit().  In
> sch_direct_xmit() this returned list is requeued by dev_requeue_skb().
>
> The patch also tries to limit the amount of bytes dequeued, based on
> the drivers BQL limits.  It also tries to avoid and stop dequeuing
> when seeing a GSO packet (both real GSO and segmented GSO skb lists).
>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
>
> ---
> V2:
>  - Restruct functions, split out functionality
>  - Use BQL bytelimit to avoid overshooting driver limits, causing
>    too large skb lists to be sitting on the requeue gso_skb.
>
>  net/sched/sch_generic.c |   67 +++++++++++++++++++++++++++++++++++++++++++++--
>  1 files changed, 64 insertions(+), 3 deletions(-)
>
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index 19696eb..a0c8070 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -56,6 +56,67 @@ static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
>         return 0;
>  }
>
> +static inline bool qdisc_may_bulk(const struct Qdisc *qdisc,
> +                                 const struct sk_buff *skb)
> +{
> +       return (qdisc->flags & TCQ_F_ONETXQUEUE);
> +}
> +
> +static inline struct sk_buff *qdisc_dequeue_validate(struct Qdisc *qdisc)
> +{
> +       struct sk_buff *skb = qdisc->dequeue(qdisc);
> +
> +       if (skb != NULL)
> +               skb = validate_xmit_skb(skb, qdisc_dev(qdisc));
> +
> +       return skb;
> +}
> +
> +static inline struct sk_buff *qdisc_bulk_dequeue_skb(struct Qdisc *q,
> +                                                    struct sk_buff *head)
> +{
> +       struct sk_buff *new, *skb = head;
> +       struct netdev_queue *txq = q->dev_queue;
> +       int bytelimit = netdev_tx_avail_queue(txq);
> +       int limit = 5;
> +
> +       if (bytelimit <= 0)
> +               return head;
> +
This should be "if (bytelimit < 0)" since BQL doesn't stop a queue
until available space goes negative. Also, I don't think this check
might not be needed anyway. I believe this function would only be
called when the queue is not stopped, so we can, and probably should,
send at least one packet to avoid the possibility of locking transmit.

> +       do {
> +               if (skb->next || skb_is_gso(skb)) {
> +                       /* Stop processing if the skb is already a skb
> +                        * list (e.g a segmented GSO packet) or a real
> +                        * GSO packet */
> +                       break;
> +               }
> +               new = qdisc_dequeue_validate(q);
> +               if (new) {
> +                       skb->next = new;
> +                       skb = new;
> +                       bytelimit -= skb->len;
> +                       cnt++;
> +                       /* One problem here is it is difficult to
> +                        * requeue the "new" dequeued skb, e.g. in
> +                        * case of GSO, thus a "normal" packet can
> +                        * have a GSO packet on its ->next ptr.
> +                        *
> +                        * Requeue is difficult because if requeuing
> +                        * on q->gso_skb, then a second requeue can
> +                        * happen from sch_direct_xmit e.g. if driver
> +                        * returns NETDEV_TX_BUSY, which would
> +                        * overwrite this requeue.
> +                        */
Maybe we could just add another pointer e.g. hold_skb and use that to
requeue normal packets and continue to use gso_skb for GSO requeue? In
dequeue_skb, check gso_skb first, then hold_skb, and the
qdisc->dequeue.

> +               }
> +       } while (new && --limit && (bytelimit > 0));

Should be "bytelimit >= 0".

> +       skb = head;
> +
> +       return skb;
> +}
> +
> +/* Note that dequeue_skb can possibly return a SKB list (via skb->next).
> + * A requeued skb (via q->gso_skb) can also be a SKB list.
> + */
>  static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
>  {
>         struct sk_buff *skb = q->gso_skb;
> @@ -71,9 +132,9 @@ static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
>                         skb = NULL;
>         } else {
>                 if (!(q->flags & TCQ_F_ONETXQUEUE) || !netif_xmit_frozen_or_stopped(txq)) {
> -                       skb = q->dequeue(q);
> -                       if (skb)
> -                               skb = validate_xmit_skb(skb, qdisc_dev(q));
> +                       skb = qdisc_dequeue_validate(q);
> +                       if (skb && qdisc_may_bulk(q, skb))
> +                               skb = qdisc_bulk_dequeue_skb(q, skb);
>                 }
>         }
>
>
