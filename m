From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 2/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Mon, 18 Jun 2007 13:36:11 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329030D59A7@orsmsx414.amr.corp.intel.com>
References: <4676D77B.7020105@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <jeff@garzik.org>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, <hadi@cyberus.ca>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:52411 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760920AbXFRUg2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 16:36:28 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4676D77B.7020105@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> PJ Waskiewicz wrote:
> >
> > diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c index 
> > 6d7542c..44ecdc6 100644
> > --- a/net/sched/sch_prio.c
> > +++ b/net/sched/sch_prio.c
> >  	}
> > +#ifdef CONFIG_NET_SCH_PRIO_MQ
> > +	/* setup queue to band mapping */
> > +	if (q->bands < sch->dev->egress_subqueue_count) {
> > +		qmapoffset = 1;
> > +		mod = sch->dev->egress_subqueue_count;
> > +	} else {
> > +		mod = q->bands % sch->dev->egress_subqueue_count;
> > +		qmapoffset = q->bands / sch->dev->egress_subqueue_count
> > +				+ ((mod) ? 1 : 0);
> > +	}
> > +
> > +	queue = 0;
> > +	offset = 0;
> > +	for (i = 0; i < q->bands; i++) {
> > +		q->band2queue[i] = queue;
> > +		if ( ((i + 1) - offset) == qmapoffset) {
> > +			queue++;
> > +			offset += qmapoffset;
> > +			if (mod)
> > +				mod--;
> > +			qmapoffset = q->bands /
> > +				sch->dev->egress_subqueue_count +
> > +				((mod) ? 1 : 0);
> > +		}
> > +	}
> > +#endif
> 
> This should really go, its not only ugly, it also makes no 
> sense to use more bands than queues since that means multiple 
> bands of different priorities are controlled through a single 
> queue state, so lower priority bands can stop the queue for 
> higher priority ones.
> 
> The user should enable multiqueue behaviour and using it with 
> a non-matching parameters should simply return an error.

That sounds fine to me.  I'll clean this and sch_prio up.

> > diff --git a/net/sched/sch_rr.c b/net/sched/sch_rr.c new file mode 
> > 100644 index 0000000..ce9f237
> > --- /dev/null
> > +++ b/net/sched/sch_rr.c
> 
> For which multiqueue capable device is this? Jamal mentioned 
> that e1000 
> uses drr.

E1000 is capable of doing DRR and WRR, however the way our drivers are
written, they're straight round-robin.  But this qdisc would be useful
for devices such as wireless where they have their own scheduler in the
MAC, and do not want the stack to prioritize traffic beyond that.  This
way a user can classify multiple flows into multiple bands, but the
driver will control the prioritization of the traffic beyond that.  For
MAC's that have no strict scheduler (such as e1000 as it is today), they
can use sch_prio to achieve multiple queue support, but have scheduling
priority from the stack.

This qdisc can also be useful at the physical netdev layer for
virtualization I would think, but perhaps I haven't thought that hard
about that yet.

> Lots os unnecessary includes. I have a patch that cleans this up for 
> net/sched,
> this is the relevant sch_prio part where you copied this from:

I'll clean the includes up.  Thanks!

> > +	band = TC_H_MIN(band) - 1;
> > +	if (band > q->bands) {
> 
> You copied an off-by-one from an old sch_prio version here.

Hmm.  This is the sch_prio from the first 2.6.23-dev tree.  I'll resync
and make sure it's the correct one.

> > +static int rr_tune(struct Qdisc *sch, struct rtattr *opt)
> > +{
> > +	struct rr_sched_data *q = qdisc_priv(sch);
> > +	struct tc_rr_qopt *qopt = RTA_DATA(opt);
> 
> 
> Nested attributes please, don't repeat sch_prio's mistake.

I'm not sure I understand what you mean here about nested attributes.

> 
> > ...
> > +	/* setup queue to band mapping - best effort to map 
> into available
> > +	 * hardware queues
> > +	 */
> > +	if (q->bands < sch->dev->egress_subqueue_count) {
> > +		qmapoffset = 1;
> > +		mod = sch->dev->egress_subqueue_count;
> > +	} else {
> > +		mod = q->bands % sch->dev->egress_subqueue_count;
> > +		qmapoffset = q->bands / sch->dev->egress_subqueue_count
> > +				+ ((mod) ? 1 : 0);
> > +	}
> > +
> > +	queue = 0;
> > +	offset = 0;
> > +	for (i = 0; i < q->bands; i++) {
> > +		q->band2queue[i] = queue;
> > +		if ( ((i + 1) - offset) == qmapoffset) {
> > +			queue++;
> > +			offset += qmapoffset;
> > +			if (mod)
> > +				mod--;
> > +			qmapoffset = q->bands /
> > +				sch->dev->egress_subqueue_count +
> > +				((mod) ? 1 : 0);
> > +		}
> > +	}
> 
> Should go as well.
> 

Works for me.  I'll clean this up as well.
