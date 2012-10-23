From: Paolo Valente <paolo.valente@unimore.it>
Subject: Re: [RFC PATCH net-next] qfq: handle the case that front slot is empty
Date: Tue, 23 Oct 2012 09:09:22 +0200
Message-ID: <F36C0EC1-0A4C-48FB-ABF3-A89575A9287E@unimore.it>
References: <1350965711-4390-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spostino.sms.unimo.it ([155.185.44.3]:50088 "EHLO
	spostino.sms.unimo.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753450Ab2JWHJg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 03:09:36 -0400
In-Reply-To: <1350965711-4390-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The crash you reported is one of the problems I tried to solve with my last fixes.
After those fixes I could not reproduce this crash (and other crashes) any more, but of course I am still missing something.

Il giorno 23/ott/2012, alle ore 06:15, Cong Wang ha scritto:

> I am not sure if this patch fixes the real problem or just workarounds
> it. At least, after this patch I don't see the crash I reported any more.

It is actually a workaround: if the condition that triggers your workaround holds true, then the group data structure is already inconstent, and qfq is likely not to schedule classes correctly.
I will try to reproduce the crash with the steps you suggest, and try to understand what is still wrong as soon as I can.

Paolo

> 
> The problem is that in some cases the front slot can become empty,
> therefore qfq_slot_head() returns an invalid pointer (not NULL!).
> This patch just make it return NULL in such case.
> 
> What's more, in qfq_front_slot_remove(), it always clears
> bit 0 in full_slots, so we should ajust the bucket list with
> qfq_slot_scan() before that.
> 
> Cc: Paolo Valente <paolo.valente@unimore.it>
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> ---
> diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
> index f0dd83c..8dfdd89 100644
> --- a/net/sched/sch_qfq.c
> +++ b/net/sched/sch_qfq.c
> @@ -680,24 +680,13 @@ static void qfq_slot_insert(struct qfq_group *grp, struct qfq_class *cl,
> /* Maybe introduce hlist_first_entry?? */
> static struct qfq_class *qfq_slot_head(struct qfq_group *grp)
> {
> +	if (hlist_empty(&grp->slots[grp->front]))
> +		return NULL;
> 	return hlist_entry(grp->slots[grp->front].first,
> 			   struct qfq_class, next);
> }
> 
> /*
> - * remove the entry from the slot
> - */
> -static void qfq_front_slot_remove(struct qfq_group *grp)
> -{
> -	struct qfq_class *cl = qfq_slot_head(grp);
> -
> -	BUG_ON(!cl);
> -	hlist_del(&cl->next);
> -	if (hlist_empty(&grp->slots[grp->front]))
> -		__clear_bit(0, &grp->full_slots);
> -}
> -
> -/*
>  * Returns the first full queue in a group. As a side effect,
>  * adjust the bucket list so the first non-empty bucket is at
>  * position 0 in full_slots.
> @@ -722,6 +711,19 @@ static struct qfq_class *qfq_slot_scan(struct qfq_group *grp)
> }
> 
> /*
> + * remove the entry from the front slot
> + */
> +static void qfq_front_slot_remove(struct qfq_group *grp)
> +{
> +	struct qfq_class *cl = qfq_slot_scan(grp);
> +
> +	BUG_ON(!cl);
> +	hlist_del(&cl->next);
> +	if (hlist_empty(&grp->slots[grp->front]))
> +		__clear_bit(0, &grp->full_slots);
> +}
> +
> +/*
>  * adjust the bucket list. When the start time of a group decreases,
>  * we move the index down (modulo QFQ_MAX_SLOTS) so we don't need to
>  * move the objects. The mask of occupied slots must be shifted
> @@ -794,6 +796,8 @@ static struct sk_buff *qfq_dequeue(struct Qdisc *sch)
> 	grp = qfq_ffs(q, q->bitmaps[ER]);
> 
> 	cl = qfq_slot_head(grp);
> +	if (!cl)
> +		return NULL;
> 	skb = qdisc_dequeue_peeked(cl->qdisc);
> 	if (!skb) {
> 		WARN_ONCE(1, "qfq_dequeue: non-workconserving leaf\n");
> @@ -1018,16 +1022,23 @@ static void qfq_deactivate_class(struct qfq_sched *q, struct qfq_class *cl)
> 		__clear_bit(grp->index, &q->bitmaps[ER]);
> 	} else if (hlist_empty(&grp->slots[grp->front])) {
> 		cl = qfq_slot_scan(grp);
> -		roundedS = qfq_round_down(cl->S, grp->slot_shift);
> -		if (grp->S != roundedS) {
> +		if (!cl) {
> 			__clear_bit(grp->index, &q->bitmaps[ER]);
> 			__clear_bit(grp->index, &q->bitmaps[IR]);
> 			__clear_bit(grp->index, &q->bitmaps[EB]);
> 			__clear_bit(grp->index, &q->bitmaps[IB]);
> -			grp->S = roundedS;
> -			grp->F = roundedS + (2ULL << grp->slot_shift);
> -			s = qfq_calc_state(q, grp);
> -			__set_bit(grp->index, &q->bitmaps[s]);
> +		} else {
> +			roundedS = qfq_round_down(cl->S, grp->slot_shift);
> +			if (grp->S != roundedS) {
> +				__clear_bit(grp->index, &q->bitmaps[ER]);
> +				__clear_bit(grp->index, &q->bitmaps[IR]);
> +				__clear_bit(grp->index, &q->bitmaps[EB]);
> +				__clear_bit(grp->index, &q->bitmaps[IB]);
> +				grp->S = roundedS;
> +				grp->F = roundedS + (2ULL << grp->slot_shift);
> +				s = qfq_calc_state(q, grp);
> +				__set_bit(grp->index, &q->bitmaps[s]);
> +			}
> 		}
> 	}
> 


--
Paolo Valente                                                 
Algogroup
Dipartimento di Ingegneria dell'Informazione		
Via Vignolese 905/b
41125 Modena - Italy        				  
homepage:  http://algo.ing.unimo.it/people/paolo/
