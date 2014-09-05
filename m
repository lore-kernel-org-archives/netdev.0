From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC net-next PATCH V2 2/3] qdisc: bulk dequeue support for
 qdiscs with TCQ_F_ONETXQUEUE
Date: Fri, 5 Sep 2014 10:28:15 +0200
Message-ID: <20140905102815.157fda5a@redhat.com>
References: <20140904125247.4108.8132.stgit@dragon>
	<20140904125438.4108.38160.stgit@dragon>
	<1409837383.26422.113.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7595 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754289AbaIEI2m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2014 04:28:42 -0400
In-Reply-To: <1409837383.26422.113.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 04 Sep 2014 06:29:43 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Thu, 2014-09-04 at 14:55 +0200, Jesper Dangaard Brouer wrote:
> > Based on DaveM's recent API work on dev_hard_start_xmit(), that allows
> > sending/processing an entire skb list.
> > 
> > This patch implements qdisc bulk dequeue, by allowing multiple packets
> > to be dequeued in dequeue_skb().
> > 
> > The optimization principle for this is two fold, (1) to amortize
> > locking cost and (2) avoid expensive tailptr update for notifying HW.
> >  (1) Several packets are dequeued while holding the qdisc root_lock,
> > amortizing locking cost over several packet.  The dequeued SKB list is
> > processed under the TXQ lock in dev_hard_start_xmit(), thus also
> > amortizing the cost of the TXQ lock.
> >  (2) Further more, dev_hard_start_xmit() will utilize the skb->xmit_more
> > API to delay HW tailptr update, which also reduces the cost per
> > packet.
> > 
> > One restriction of the new API is that every SKB must belong to the
> > same TXQ.  This patch takes the easy way out, by restricting bulk
> > dequeue to qdisc's with the TCQ_F_ONETXQUEUE flag, that specifies the
> > qdisc only have attached a single TXQ.
> > 
> > Some detail about the flow; dev_hard_start_xmit() will process the skb
> > list, and transmit packets individually towards the driver (see
> > xmit_one()).  In case the driver stops midway in the list, the
> > remaining skb list is returned by dev_hard_start_xmit().  In
> > sch_direct_xmit() this returned list is requeued by dev_requeue_skb().
> > 
> > The patch also tries to limit the amount of bytes dequeued, based on
> > the drivers BQL limits.  It also tries to avoid and stop dequeuing
> > when seeing a GSO packet (both real GSO and segmented GSO skb lists).
> > 
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> > 
> > ---
> > V2:
> >  - Restruct functions, split out functionality
> >  - Use BQL bytelimit to avoid overshooting driver limits, causing
> >    too large skb lists to be sitting on the requeue gso_skb.
> > 
> >  net/sched/sch_generic.c |   67 +++++++++++++++++++++++++++++++++++++++++++++--
> >  1 files changed, 64 insertions(+), 3 deletions(-)
> > 
> > diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> > index 19696eb..a0c8070 100644
> > --- a/net/sched/sch_generic.c
> > +++ b/net/sched/sch_generic.c
> > @@ -56,6 +56,67 @@ static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
> >  	return 0;
> >  }
> >  
> > +static inline bool qdisc_may_bulk(const struct Qdisc *qdisc,
> > +				  const struct sk_buff *skb)
> 
> Why skb is passed here ?

Just a left over, when the func did more checking.

> > +{
> > +	return (qdisc->flags & TCQ_F_ONETXQUEUE);
> 	
> 	return qdisc->flags & TCQ_F_ONETXQUEUE;

Sure, nitpick ;-)


> > +}
> > +
> > +static inline struct sk_buff *qdisc_dequeue_validate(struct Qdisc *qdisc)
> > +{
> > +	struct sk_buff *skb = qdisc->dequeue(qdisc);
> > +
> > +	if (skb != NULL)
> > +		skb = validate_xmit_skb(skb, qdisc_dev(qdisc));
> 
> > +
> > +	return skb;
> > +}
> > +
> > +static inline struct sk_buff *qdisc_bulk_dequeue_skb(struct Qdisc *q,
> > +						     struct sk_buff *head)
> > +{
> > +	struct sk_buff *new, *skb = head;
> > +	struct netdev_queue *txq = q->dev_queue;
> > +	int bytelimit = netdev_tx_avail_queue(txq);
> > +	int limit = 5;
> > +
> > +	if (bytelimit <= 0)
> > +		return head;
> > +
> > +	do {
> > +		if (skb->next || skb_is_gso(skb)) {
> 
> A GSO packet should not 'stop the processing' if the device is TSO
> capable : It should look as a normal packet.

So, I cannot see if it is a TSO packet via the skb_is_gso(skb) check?
Will skb->len be the length of the full TSO packet size?

This check (skb->next) also guards against new=qdisc_dequeue_validate()
returned a list (GSO segmenting), in last "round" (now here skb=new),
as I then can assign the next "new" packet directly to skb->next=new
(without checking if new is a skb list).


> > +			/* Stop processing if the skb is already a skb
> > +			 * list (e.g a segmented GSO packet) or a real
> > +			 * GSO packet */
> > +			break;
> > +		}
> > +		new = qdisc_dequeue_validate(q);
> 
> Thats broken.
> 
> After validate_xmit_skb()  @new might be the head of a list. (GSO split)

As described above, I think, I'm handling this case, as I don't allow
further processing if I detect that this was an skb list.
 
> 
> 
> > +		if (new) {
> > +			skb->next = new;
> 
> 
> > +			skb = new;
> 
> and new is only the first element on the list.
> 
> > +			bytelimit -= skb->len;
> 
> skb->len is the length of first segment.

Damn, yes, then I will have to walk the "new" skb in-case it is a list,
I was hoping to avoid that.


> > +			cnt++;
(ups, debug left over)

> > +			/* One problem here is it is difficult to
> > +			 * requeue the "new" dequeued skb, e.g. in
> > +			 * case of GSO, thus a "normal" packet can
> > +			 * have a GSO packet on its ->next ptr.
> > +			 *
> > +			 * Requeue is difficult because if requeuing
> > +			 * on q->gso_skb, then a second requeue can
> > +			 * happen from sch_direct_xmit e.g. if driver
> > +			 * returns NETDEV_TX_BUSY, which would
> > +			 * overwrite this requeue.
> > +			 */
> 
> It should not overwrite, but insert back. Thats what need to be done.

Okay, guess that should/could be handled in dev_requeue_skb().

In this case with (TCQ_F_ONETXQUEUE) the end result of not requeuing
here is almost the same.  In case dev_hard_start_xmit() didn't xmit the
entire list, it will be placed back on the requeue (q->gso_skb) anyway.
Thus we might be better off just sending this to the device, instead of
requeuing explicitly here.


> > +		}
> > +	} while (new && --limit && (bytelimit > 0));
> > +	skb = head;
> > +
> > +	return skb;
> > +}
> > +
> 
> 
> Idea is really the following :
> 
> Once qdisc dequeue bulk is done, and skb validated, we have a list of
> skb to send to the device.
> 
> We iterate the list and try to send the individual skb.
> 
> As soon as device returns NETDEV_TX_BUSY (or even better, when the queue
> is stopped), we requeue the remaining list.

Yes, that is also my understanding.

The "dangerous" part is the size (in bytes) of the requeued remaining
list.  In the-meantime while the driver/queue have been stopped, a high
priority packet might have been queued in the qdisc.  When we start to
dequeue again, then the requeued list is transmitted *before* dequeuing
the high prio packet sitting in the real qdisc queue. (That is what you
call head-of-line blocking right)


> BQL never tried to find the exact split point :
> 
> If available budget is 25000 bytes, and next TSO packet is 45000 bytes,
> we send it.

Okay, so it is okay to overshoot, which I also think this patch does.


> So the bql validation should be done before the eventual
> validate_xmit_skb() : This way you dont care of GSO or TSO.

If do a skb=q->dequeue(q), and the packet is a GSO packet, then
skb->len should be valid/cover-hole-packet right? (I could use that,
and avoid walking the gso list).


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
