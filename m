From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCHv2 1/3] NET_SCHED: PSPacer qdisc module
Date: Tue, 27 Nov 2007 13:16:34 +0100
Message-ID: <474C0AA2.5040900@trash.net>
References: <20071127.005042.92637908.takano@axe-inc.co.jp>	<474B0D5D.2090506@trash.net> <20071127.200803.24564635.takano@axe-inc.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: takano-ryousei@aist.go.jp, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, dada1@cosmosbay.com,
	t.kudoh@aist.go.jp
To: TAKANO Ryousei <takano@axe-inc.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56340 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753946AbXK0MQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 07:16:43 -0500
In-Reply-To: <20071127.200803.24564635.takano@axe-inc.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

TAKANO Ryousei wrote:
> Hi Patrick,
> 
>>> +struct tc_psp_qopt
>>> +{
>>> +	__u32	defcls;
>>> +	__u32	rate;
>>> +};
>>
>> What unit is rate measured in?
>>
> 'rate' is the transmission rate in bytes per sec.


So wouldn't it make sense to use u64 then for 10GBit networks?

>>> +	skb_put(skb, size);
>> This is usually done before putting data in the packet.
>>
> Therefore, skb_put() is needed.


I meant this is usually done before writing to the packet data,
so you should move it up a few lines.

>>> +static int recalc_gapsize(struct sk_buff *skb, struct Qdisc *sch)
>>> +{
>>> +	struct psp_sched_data *q = qdisc_priv(sch);
>>> +	struct psp_class *cl;
>>> +	unsigned int len = skb->len;
>>> +	int gapsize = 0;
>>> +	int err;
>>> +
>>> +	cl = psp_classify(skb, sch, &err);
>>> +	switch (cl->mode) {
>>> +	case MODE_STATIC:
>>> +		gapsize = cl->gapsize;
>>> +		if (len < q->mtu) /* workaround for overflow */
>>> +			gapsize = (int)((long long)gapsize * len / q->mtu);
>> No need to cast to the LHS type. Shouldn't this also be rounded up
>> like the other gapsize calculation?
>>
> How about this?
> 
> 	u64 gapsize = 0;
> 	:
> 	case MODE_STATIC:
> 		gapsize = (u64)cl->gapsize * len / q->mtu;
> 		gapsize = min_t(u64, gapsize, UINT_MAX);


Really a minimum of UINT_MAX? This will probably also break on 32 bit
unless you use do_div().

> 		break;
> 	}
> 
>>> +static struct psp_class *lookup_next_class(struct Qdisc *sch, int *gapsize)
>>> +{
>>> +	struct psp_sched_data *q = qdisc_priv(sch);
>>> +	struct psp_class *cl, *next = NULL;
>>> +	gapclock_t diff;
>>> +	int shortest;
>>> +
>>> +	/* pacing class */
>>> +	shortest = q->mtu;
>>> +	list_for_each_entry(cl, &q->pacing_list, plist) {
>>> +		diff = cl->clock - q->clock;
>>> +		if (diff > 0) {
>>> +			if ((gapclock_t)shortest > diff)
>>> +				shortest = (int)diff;
>> Is diff guaranteed not to exceed an int?
>>
> No. But actually, 'diff' is much smaller than INT_MAX.
> How about this?
> 
> 	u64 diff, shortest;
> 	:
> 		if (q->clock < cl->clock) {
> 			diff = cl->clock - q->clock;
> 			if (shortest > diff)
> 				shortest = diff;
> 			continue;
> 		}


I don't know, its your qdisc :) I was merely wondering whether
you need larger types since there seems to be some inconsisteny.
Your old code had a check for diff > 0, so it appears that
cl->clock could be smaller than q->clock.

>>> +	while (!list_empty(&q->root))
>>> +		psp_destroy_class(sch, list_entry(q->root.next,
>>> +						  struct psp_class, sibling));
>> list_for_each_entry_safe.
>>
> I think it works well. Should I need to use list_for_each_entry_safe?


I don't doubt that it works, but list_for_each_entry_safe is
the proper interface for this.

One more thing: your qdisc can only be used as root qdisc since it
produces packets itself and thereby violates the rule that a qdisc
can only hand out packets that were previously enqueued to it.
Using it as a leaf qdisc can make the upper qdiscs qlen counter
go negative, causing infinite dequeue-loops, so you should make
sure that its only possibly to use as root qdisc by checking the
parent. It would also be better to do something like netem
(enqueue produced packets at the root) to make sure the qlen
counter is always accurate.

