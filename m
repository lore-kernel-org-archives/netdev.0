From: Tom Herbert <therbert@google.com>
Subject: Re: [net-next PATCH 1/1 V4] qdisc: bulk dequeue support for qdiscs
 with TCQ_F_ONETXQUEUE
Date: Wed, 24 Sep 2014 11:34:37 -0700
Message-ID: <CA+mtBx8s63TDe1XS7TzfscwhiRCgyeLkKLz2p-4et1erX0-dUQ@mail.gmail.com>
References: <20140924160932.9721.56450.stgit@localhost>
	<20140924161047.9721.43080.stgit@localhost>
	<1411579395.15395.41.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140924195831.6fb91051@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	=?UTF-8?B?VG9rZSBIw7hpbGFuZC1Kw7hyZ2Vuc2Vu?= <toke@toke.dk>,
	Florian Westphal <fw@strlen.de>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Dave Taht <dave.taht@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:44194 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750994AbaIXSei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 14:34:38 -0400
Received: by mail-ie0-f169.google.com with SMTP id rp18so10257665iec.0
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 11:34:37 -0700 (PDT)
In-Reply-To: <20140924195831.6fb91051@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 24, 2014 at 10:58 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> On Wed, 24 Sep 2014 10:23:15 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>> On Wed, 2014-09-24 at 18:12 +0200, Jesper Dangaard Brouer wrote:
>> > Based on DaveM's recent API work on dev_hard_start_xmit(), that allows
>> > sending/processing an entire skb list.
>> >
>> > This patch implements qdisc bulk dequeue, by allowing multiple packets
>> > to be dequeued in dequeue_skb().
>> >
>> > The optimization principle for this is two fold, (1) to amortize
>> > locking cost and (2) avoid expensive tailptr update for notifying HW.
>> >  (1) Several packets are dequeued while holding the qdisc root_lock,
>> > amortizing locking cost over several packet.  The dequeued SKB list is
>> > processed under the TXQ lock in dev_hard_start_xmit(), thus also
>> > amortizing the cost of the TXQ lock.
>> >  (2) Further more, dev_hard_start_xmit() will utilize the skb->xmit_more
>> > API to delay HW tailptr update, which also reduces the cost per
>> > packet.
>> >
>> > One restriction of the new API is that every SKB must belong to the
>> > same TXQ.  This patch takes the easy way out, by restricting bulk
>> > dequeue to qdisc's with the TCQ_F_ONETXQUEUE flag, that specifies the
>> > qdisc only have attached a single TXQ.
>> >
>> > Some detail about the flow; dev_hard_start_xmit() will process the skb
>> > list, and transmit packets individually towards the driver (see
>> > xmit_one()).  In case the driver stops midway in the list, the
>> > remaining skb list is returned by dev_hard_start_xmit().  In
>> > sch_direct_xmit() this returned list is requeued by dev_requeue_skb().
>> >
>> > To avoid overshooting the HW limits, which results in requeuing, the
>> > patch limits the amount of bytes dequeued, based on the drivers BQL
>> > limits.  In-effect bulking will only happen for BQL enabled drivers.
>> > Besides the bytelimit from BQL, also limit bulking to maximum 8
>> > packets to avoid any issues with available descriptor in HW.
>> >
>> > For now, as a conservative approach, don't bulk dequeue GSO and
>> > segmented GSO packets, because testing showed requeuing occuring
>> > with segmented GSO packets.
>> >
>> > Jointed work with Hannes, Daniel and Florian.
>> >
>> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
>> > Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> > Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> > Signed-off-by: Florian Westphal <fw@strlen.de>
>> >
>> > ---
>> > V4:
>> > - Patch rewritten in the Red Hat Neuchatel office jointed work with
>> >   Hannes, Daniel and Florian.
>> > - Conservative approach of only using on BQL enabled drivers
>> > - No user tunable parameter, but limit bulking to 8 packets.
>> > - For now, avoid bulking GSO packets packets.
>> >
> [...]
>> > diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
>> > index 19696eb..6fba089 100644
>> > --- a/net/sched/sch_generic.c
>> > +++ b/net/sched/sch_generic.c
>> > @@ -56,6 +56,42 @@ static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
>> >     return 0;
>> >  }
>> >
>> > +static struct sk_buff *try_bulk_dequeue_skb(struct Qdisc *q,
>> > +                                       struct sk_buff *head_skb,
>> > +                                       int bytelimit)
>> > +{
>> > +   struct sk_buff *skb, *tail_skb = head_skb;
>> > +   int budget = 8; /* Arbitrary, but conservatively choosen limit */
>> > +
>> > +   while (bytelimit > 0 && --budget > 0) {
>> > +           /* For now, don't bulk dequeue GSO (or GSO segmented) pkts */
>>
>> Hmm... this is a serious limitation.
>
> We plan to remove this at a later point, this is just to be conservative.
>
>
>> > +           if (tail_skb->next || skb_is_gso(tail_skb))
>> > +                   break;
>> > +
>> > +           skb = q->dequeue(q);
>> > +           if (!skb)
>> > +                   break;
>> > +
>> > +           bytelimit -= skb->len; /* covers GSO len */
>>
>> Not really, use qdisc_pkt_len(skb) instead, to have a better byte count.
>
> Understood, will update patch tomorrow.
>
I believe drivers typically use skb->len for BQL tracking. Since
bytelimit is based on BQL here, it might be more correct to use
skb->len.

>
>> > +           skb = validate_xmit_skb(skb, qdisc_dev(q));
>> > +           if (!skb)
>> > +                   break;
>> > +
>> > +           /* "skb" can be a skb list after validate call above
>> > +            * (GSO segmented), but it is okay to append it to
>> > +            * current tail_skb->next, because next round will exit
>> > +            * in-case "tail_skb->next" is a skb list.
>> > +            */
>>
>> It would be trivial to change validate_xmit_skb() to return the head and
>> tail of the chain. Walking the chain would hit hot cache lines, but it
>> is better not having to walk it.
>
> Yes, we could do this when we later add support for GSO segmented packets.
>
>
>> > +           tail_skb->next = skb;
>> > +           tail_skb = skb;
>>
>> So that here we do : tail_skb = tail;
>>
>> > +   }
>> > +
>> > +   return head_skb;
>> > +}
>> > +
>> > +/* Note that dequeue_skb can possibly return a SKB list (via skb->next).
>> > + * A requeued skb (via q->gso_skb) can also be a SKB list.
>> > + */
>> >  static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
>> >  {
>> >     struct sk_buff *skb = q->gso_skb;
>> > @@ -70,10 +106,17 @@ static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
>> >             } else
>> >                     skb = NULL;
>> >     } else {
>> > -           if (!(q->flags & TCQ_F_ONETXQUEUE) || !netif_xmit_frozen_or_stopped(txq)) {
>> > +           if (!(q->flags & TCQ_F_ONETXQUEUE) ||
>> > +               !netif_xmit_frozen_or_stopped(txq)) {
>> > +                   int bytelimit = qdisc_avail_bulklimit(txq);
>> > +
>> >                     skb = q->dequeue(q);
>> > -                   if (skb)
>> > +                   if (skb) {
>> > +                           bytelimit -= skb->len;
>>
>>   qdisc_pkt_len(skb)
>
> Okay, will update patch tomorrow.
>
>> >                             skb = validate_xmit_skb(skb, qdisc_dev(q));
>> > +                   }
>> > +                   if (skb && qdisc_may_bulk(q))
>> > +                           skb = try_bulk_dequeue_skb(q, skb, bytelimit);
>> >             }
>> >     }
>> >
>>
>> It looks good, but we really need to take care of TSO packets.
>
> As notes above, TSO packets are planned as a future feature.  Lets
> first see if this works well, without introducing any HoL blocking
> issues or other regressions.
>
>
>> pktgen is nice, but do not represent the majority of the traffic we send
>> from high performance host where we want this bulk dequeue thing ;)
>
> This patch is actually targetted towards more normal use-cases.
> Pktgen cannot even use this work, as it bypass the qdisc layer...
>
> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Sr. Network Kernel Developer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer
