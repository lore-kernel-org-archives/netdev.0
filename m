From: TAKANO Ryousei <takano@axe-inc.co.jp>
Subject: Re: [PATCHv2 1/3] NET_SCHED: PSPacer qdisc module
Date: Tue, 27 Nov 2007 20:08:03 +0900 (JST)
Message-ID: <20071127.200803.24564635.takano@axe-inc.co.jp>
References: <20071127.005042.92637908.takano@axe-inc.co.jp>
	<474B0D5D.2090506@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: takano-ryousei@aist.go.jp, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, dada1@cosmosbay.com,
	t.kudoh@aist.go.jp
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from axekw.axe-inc.co.jp ([61.199.217.67]:52455 "EHLO
	axekw.axe-inc.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751453AbXK0LIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 06:08:11 -0500
In-Reply-To: <474B0D5D.2090506@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Patrick,

I appreciate your comments.
I will update and resend patches.

> > +typedef long long gapclock_t;
> 
> It seems you only add to this, does it need to be signed?
> How about using a fixed size type (u64) and getting rid
> of the typedef?
> 
OK. I will use u64 instead of gapclock_t, and remove the typedef.

> > +struct tc_psp_qopt
> > +{
> > +	__u32	defcls;
> > +	__u32	rate;
> > +};
> 
> 
> What unit is rate measured in?
> 
'rate' is the transmission rate in bytes per sec.

> > +struct tc_psp_xstats
> > +{
> > +	__u32	bytes;		/* gap packet statistics */
> > +	__u32	packets;
> > +};
> 
> How about using gnet_stats_basic for this?
> 
OK. I will use gnet_stats_basic.

> > +	if (!skb)
> > +		return NULL;
> > +
> > +	memset(skb->data, 0xff, size);
> 
> memsetting the header portion seems unnecessary since you overwrite
> it again directly below.
> 
The size of a gap packet is variable, so it fills a whole gap packet
with 0xff, where 'size' indicates the interface MTU size.

> > +	skb_put(skb, size);
> 
> This is usually done before putting data in the packet.
> 
Therefore, skb_put() is needed.

> > +static int recalc_gapsize(struct sk_buff *skb, struct Qdisc *sch)
> > +{
> > +	struct psp_sched_data *q = qdisc_priv(sch);
> > +	struct psp_class *cl;
> > +	unsigned int len = skb->len;
> > +	int gapsize = 0;
> > +	int err;
> > +
> > +	cl = psp_classify(skb, sch, &err);
> > +	switch (cl->mode) {
> > +	case MODE_STATIC:
> > +		gapsize = cl->gapsize;
> > +		if (len < q->mtu) /* workaround for overflow */
> > +			gapsize = (int)((long long)gapsize * len / q->mtu);
> 
> No need to cast to the LHS type. Shouldn't this also be rounded up
> like the other gapsize calculation?
> 
How about this?

	u64 gapsize = 0;
	:
	case MODE_STATIC:
		gapsize = (u64)cl->gapsize * len / q->mtu;
		gapsize = min_t(u64, gapsize, UINT_MAX);
		break;
	}

> > +static struct psp_class *lookup_next_class(struct Qdisc *sch, int *gapsize)
> > +{
> > +	struct psp_sched_data *q = qdisc_priv(sch);
> > +	struct psp_class *cl, *next = NULL;
> > +	gapclock_t diff;
> > +	int shortest;
> > +
> > +	/* pacing class */
> > +	shortest = q->mtu;
> > +	list_for_each_entry(cl, &q->pacing_list, plist) {
> > +		diff = cl->clock - q->clock;
> > +		if (diff > 0) {
> > +			if ((gapclock_t)shortest > diff)
> > +				shortest = (int)diff;
> 
> Is diff guaranteed not to exceed an int?
> 
No. But actually, 'diff' is much smaller than INT_MAX.
How about this?

	u64 diff, shortest;
	:
		if (q->clock < cl->clock) {
			diff = cl->clock - q->clock;
			if (shortest > diff)
				shortest = diff;
			continue;
		}


> > +static void psp_destroy(struct Qdisc *sch)
> > +{
> > +	struct psp_sched_data *q = qdisc_priv(sch);
> > +
> > +	tcf_destroy_chain(q->filter_list);
> > +
> > +	while (!list_empty(&q->root))
> > +		psp_destroy_class(sch, list_entry(q->root.next,
> > +						  struct psp_class, sibling));
> 
> list_for_each_entry_safe.
> 
I think it works well. Should I need to use list_for_each_entry_safe?

Best regards,
Ryousei Takano
