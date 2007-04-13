From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 2/3] NET: [UPDATED] Multiqueue network device support implementation.
Date: Thu, 12 Apr 2007 19:01:16 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32902A46CB8@orsmsx414.amr.corp.intel.com>
References: <461ECBBC.3040400@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jgarzik@pobox.com>,
	"cramerj" <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:26681 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751240AbXDMCBX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2007 22:01:23 -0400
Content-class: urn:content-classes:message
In-Reply-To: <461ECBBC.3040400@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Patrick McHardy [mailto:kaber@trash.net] 
> Sent: Thursday, April 12, 2007 5:16 PM
> To: Waskiewicz Jr, Peter P
> Cc: davem@davemloft.net; netdev@vger.kernel.org; 
> linux-kernel@vger.kernel.org; jgarzik@pobox.com; cramerj; 
> Kok, Auke-jan H; Leech, Christopher
> Subject: Re: [PATCH 2/3] NET: [UPDATED] Multiqueue network 
> device support implementation.
> 
> Peter P Waskiewicz Jr wrote:
> > diff --git a/net/core/dev.c b/net/core/dev.c index 219a57f..3ce449e 
> > 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -1471,6 +1471,8 @@ gso:
> >  		q = dev->qdisc;
> >  		if (q->enqueue) {
> >  			rc = q->enqueue(skb, q);
> > +			/* reset queue_mapping to zero */
> > +			skb->queue_mapping = 0;
> 
> 
> This must be done before enqueueing. At this point you don't 
> even have a valid reference to the skb anymore.

Agreed, this is a transcription error on my part between my dev box and
this tree.

> 
> > @@ -3326,12 +3330,23 @@ struct net_device *alloc_netdev(int 
> sizeof_priv, const char *name,
> >  	if (sizeof_priv)
> >  		dev->priv = netdev_priv(dev);
> >  
> > + 	alloc_size = (sizeof(struct net_device_subqueue) * queue_count);
> > + 
> > + 	p = kzalloc(alloc_size, GFP_KERNEL);
> > + 	if (!p) {
> > + 		printk(KERN_ERR "alloc_netdev: Unable to 
> allocate queues.\n");
> > + 		return NULL;
> 
> 
> Still leaks the device

I explained this in a previous response, and you seemed to be ok with
the explanation.  Can you elaborate if this is still an issue?

> 
> > diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c index 
> > 5cfe60b..6a38905 100644
> > --- a/net/sched/sch_prio.c
> > +++ b/net/sched/sch_prio.c
> > @@ -144,11 +152,17 @@ prio_dequeue(struct Qdisc* sch)
> >  	struct Qdisc *qdisc;
> >  
> >  	for (prio = 0; prio < q->bands; prio++) {
> > -		qdisc = q->queues[prio];
> > -		skb = qdisc->dequeue(qdisc);
> > -		if (skb) {
> > -			sch->q.qlen--;
> > -			return skb;
> > +		/* Check if the target subqueue is available before
> > +		 * pulling an skb.  This way we avoid excessive requeues
> > +		 * for slower queues.
> > +		 */
> > +		if (!netif_subqueue_stopped(sch->dev, 
> q->band2queue[prio])) {
> > +			qdisc = q->queues[prio];
> > +			skb = qdisc->dequeue(qdisc);
> > +			if (skb) {
> > +				sch->q.qlen--;
> > +				return skb;
> > +			}
> >  		}
> >  	}
> >  	return NULL;
> > @@ -200,6 +214,10 @@ static int prio_tune(struct Qdisc 
> *sch, struct rtattr *opt)
> >  	struct prio_sched_data *q = qdisc_priv(sch);
> >  	struct tc_prio_qopt *qopt = RTA_DATA(opt);
> >  	int i;
> > +	int queue;
> > +	int qmapoffset;
> > +	int offset;
> > +	int mod;
> >  
> >  	if (opt->rta_len < RTA_LENGTH(sizeof(*qopt)))
> >  		return -EINVAL;
> > @@ -242,6 +260,30 @@ static int prio_tune(struct Qdisc 
> *sch, struct rtattr *opt)
> >  			}
> >  		}
> >  	}
> > +	/* setup queue to band mapping */
> > +	if (q->bands < sch->dev->egress_subqueue_count) {
> > +		qmapoffset = 1;
> > +		mod = sch->dev->egress_subqueue_count;
> > +	} else {
> > +		mod = q->bands % sch->dev->egress_subqueue_count;
> > +		qmapoffset = q->bands / 
> sch->dev->egress_subqueue_count +
> > +				((mod) ? 1 : 0);
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
> >  	return 0;
> >  }
> 
> 
> I stand by my point, this needs to be explicitly enabled by 
> the user since it changes the behaviour of prio on multiqueue 
> capable device.
> 

The user can enable this by using TC filters.  I do understand what you
mean that PRIO's behavior somewhat changes because of how the queues
turn off and on, but how is this different than today?  Today, if the
queue on the NIC shuts down, all the PRIO queues are down.  This way
it's actually helping get traffic out.  I don't see how the user can
control which queue is shut down; that is a function of how congested
the network is.  So if I can clarify what you're saying, are you asking
that the user actually setup the band to queue mapping?  Because if so,
I don't see how that would help since queues today don't have any
priority, and you would have no control which one stops over another
one.
