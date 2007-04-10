From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] NET: [UPDATED] Multiqueue network device support implementation.
Date: Tue, 10 Apr 2007 09:27:17 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329029E454C@orsmsx414.amr.corp.intel.com>
References: <461B5D79.9040307@trash.net>
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
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1031052AbXDJQ12@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <461B5D79.9040307@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Peter P Waskiewicz Jr wrote:
> > +	/* To retrieve statistics per subqueue - FOR FUTURE USE */
> > +	struct net_device_stats* (*get_subqueue_stats)(struct 
> net_device *dev,
> > +							int 
> queue_index);
> 
> 
> Please no future use stuff, just add it when you need it.

Gotcha.  I'll remove this.

> 
> > diff --git a/net/core/dev.c b/net/core/dev.c index 219a57f..c11c8fa 
> > 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -3326,12 +3328,23 @@ struct net_device *alloc_netdev(int 
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
> This leaks the device. You treat every single-queue device as 
> having a single subqueue. If it doesn't get too ugly it would 
> be nice to avoid this and only allocate the subqueue states 
> for real multiqueue devices.

We went back and forth on this.  The reason we allocate a queue in every
case, even on single-queue devices, was to make the stack not have
branching for multiqueue and non-multiqueue devices.  If we don't have
at least one queue on a device, then we can't have
netif_subqueue_stopped() in the hotpath unless we check if a device is
multiqueue before.  The original patches I released had this branching,
and I was asked to not do that.  I'd also like to see all queue-related
stuff be pulled from net_device and put into net_device_subqueue at some
point, even for single-queue devices.  Thoughts?

> 
> > --- a/net/sched/sch_generic.c
> > +++ b/net/sched/sch_generic.c
> > @@ -133,7 +133,8 @@ static inline int qdisc_restart(struct 
> net_device *dev)
> >  			/* And release queue */
> >  			spin_unlock(&dev->queue_lock);
> >  
> > -			if (!netif_queue_stopped(dev)) {
> > +			if (!netif_queue_stopped(dev) &&
> > +			    !netif_subqueue_stopped(dev, 
> skb->queue_mapping)) {
> >  				int ret;
> >  
> >  				ret = dev_hard_start_xmit(skb, 
> dev); @@ -149,7 +150,6 @@ static 
> > inline int qdisc_restart(struct net_device *dev)
> >  					goto collision;
> >  				}
> >  			}
> > -
> 
> 
> Unrelated whitespace change.

I'll fix that.

> 
> >  			/* NETDEV_TX_BUSY - we need to requeue */
> >  			/* Release the driver */
> >  			if (!nolock) {
> > diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c index 
> > 5cfe60b..7365621 100644
> > --- a/net/sched/sch_prio.c
> > +++ b/net/sched/sch_prio.c
> > @@ -43,6 +43,7 @@ struct prio_sched_data
> >  	struct tcf_proto *filter_list;
> >  	u8  prio2band[TC_PRIO_MAX+1];
> >  	struct Qdisc *queues[TCQ_PRIO_BANDS];
> > +	u16 band2queue[TC_PRIO_MAX + 1];
> >  };
> >  
> >  
> > @@ -63,20 +64,26 @@ prio_classify(struct sk_buff *skb, 
> struct Qdisc *sch, int *qerr)
> >  		case TC_ACT_SHOT:
> >  			return NULL;
> >  		};
> > -
> 
> Same here

I'll fix that too.

> 
> >  		if (!q->filter_list ) {
> >  #else
> >  		if (!q->filter_list || tc_classify(skb, 
> q->filter_list, &res)) {  
> > #endif
> >  			if (TC_H_MAJ(band))
> >  				band = 0;
> > +			skb->queue_mapping =
> > +				  
> q->prio2band[q->band2queue[band&TC_PRIO_MAX]];
> > +
> 
> 
> Does this needs to be cleared at some point again? TC actions 
> might redirect or mirror packets to other (multiqueue) devices.

If an skb is redirected to another device, the skb should be filtered
through that device's qdisc, yes?

> 
> > @@ -242,6 +259,30 @@ static int prio_tune(struct Qdisc 
> *sch, struct rtattr *opt)
> >  			}
> >  		}
> >  	}
> > +	/* setup queue to band mapping */
> > +	if (q->bands < sch->dev->egress_subqueue_count) {
> > +		qmapoffset = 1;
> > +		mod = 0;
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
> 
> 
> Besides being quite ugly, I don't think this does what you want.
> For bands < queues we get band2queue[0] = 0, all others map to 1.
> 

I see what's wrong with this.  If I removed "mod = 0;", the algorithm
works as intended.  We also did go through a number of iterations of the
best way to map queues to bands, using a simple hash, a complex
assigment, etc., and this algorithm gives the best distribution given
any combination of queues / bands (minus that small bug).  I'll fix this
and resubmit.

Thanks for the feedback,

-PJ Waskiewicz
