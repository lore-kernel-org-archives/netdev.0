From: "Alexander Duyck" <alexander.duyck@gmail.com>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs. dev_deactivate() race
Date: Sun, 14 Sep 2008 03:31:35 -0700
Message-ID: <5f2db9d90809140331k434b9944mf5edf16e3094f12c@mail.gmail.com>
References: <20080913011018.GA10242@gondor.apana.org.au>
	 <20080912.182259.238925690.davem@davemloft.net>
	 <20080913012758.GA10459@gondor.apana.org.au>
	 <20080912.184008.74354363.davem@davemloft.net>
	 <20080913014800.GA10611@gondor.apana.org.au>
	 <20080913205408.GA2545@ami.dom.local>
	 <20080914061610.GA20571@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jarek Poplawski" <jarkao2@gmail.com>,
	"David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:11585 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752538AbYINKbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2008 06:31:36 -0400
Received: by yx-out-2324.google.com with SMTP id 8so492019yxm.1
        for <netdev@vger.kernel.org>; Sun, 14 Sep 2008 03:31:35 -0700 (PDT)
In-Reply-To: <20080914061610.GA20571@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 13, 2008 at 11:16 PM, Herbert Xu <herbert@gondor.apana.org.au>
wrote:
> On Sat, Sep 13, 2008 at 10:54:08PM +0200, Jarek Poplawski wrote:
>>
>> If I get it right peek + dequeue should do all current dequeue logic
>> plus additionally write down the child qdisc or skb (leaves) info,
>> plus, probably, some ifs btw., which looks like a bit of overhead,
>> if we consider requeuing as something exceptional. Unless we don't -
>> then of course something like this could be useful.
>
> I don't see the overhead in writing down something that we alrady
> have.  In any case, do you have an alternative solution to the
> current problem that qdisc_run looks at an arbitrary queue's
> status to decide whether it should process a qdisc that empties
> into n queues?

What if we were to push the check for netif_tx_queue_stopped further down into
the qdisc layer so that the basic qdiscs such as pfifo_fast did their own peek
and in the event that a queue is stopped it just returned NULL and set a flag
bit?  Basically this would mimic how we are currently handling throttled
queues (TCQ_F_THROTTLED).  Then in turn each parent could do a check on skb ==
NULL and set the same flag, or they could act like multiq and just skip over
that leaf and move onto the next because it is stopped.

I might try putting together a patch for this on Monday but in the meantime
here are a couple code snippets to demonstrate what I am thinking.  It seems
like this would  provide most of what you are looking for because the first
thing that happens in qdisc_restart() is a packet is dequeued and if that
fails the routine exits.

Thanks,

Alex

static inline struct sk_buff *__qdisc_dequeue_head(struct Qdisc *sch,
						   struct sk_buff_head *list)
{
	struct sk_buff *skb = skb_peek(list);
	struct netdev_queue *txq;

	if (skb == NULL)
		return NULL;
		
	txq = netdev_get_tx_queue(sch->dev, skb_get_queue_mapping(skb));
	if (netif_tx_queue_stopped(txq) || netif_tx_queue_frozen(txq)) {
		sch->flags |= TCQ_F_STOPPED;
		return NULL;
	}

	__skb_unlink(skb, list);
	sch->qstats.backlog -= qdisc_pkt_len(skb);
	sch->flags &= ~TCQ_F_STOPPED;

	return skb;
}

static struct sk_buff *prio_dequeue(struct Qdisc* sch)
{
	struct prio_sched_data *q = qdisc_priv(sch);
	int prio;

	for (prio = 0; prio < q->bands; prio++) {
		struct Qdisc *qdisc = q->queues[prio];
		struct sk_buff *skb = qdisc->dequeue(qdisc);
		if (skb) {
			sch->q.qlen--;
			sch->flags &= ~TCQ_F_STOPPED;
			return skb;
		}
		if (qdisc->flags & TCQ_F_STOPPED) {
			sch->flags |= TCQ_F_STOPPED;
			return NULL;
		}
	}
	sch->flags &= ~TCQ_F_STOPPED;
	return NULL;

}
