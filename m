From: Florian Westphal <fw@strlen.de>
Subject: Re: [net-next PATCH V5] qdisc: bulk dequeue support for qdiscs with
 TCQ_F_ONETXQUEUE
Date: Tue, 30 Sep 2014 14:25:09 +0200
Message-ID: <20140930122509.GF11709@breakpoint.cc>
References: <20140930085114.24043.81310.stgit@dragon>
 <1412077736.30721.54.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Dave Taht <dave.taht@gmail.com>, toke@toke.dk
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:34351 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750935AbaI3MZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 08:25:17 -0400
Content-Disposition: inline
In-Reply-To: <1412077736.30721.54.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >  	struct sk_buff *skb = q->gso_skb;
> > @@ -70,10 +106,17 @@ static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
> >  		} else
> >  			skb = NULL;
> >  	} else {
> > -		if (!(q->flags & TCQ_F_ONETXQUEUE) || !netif_xmit_frozen_or_stopped(txq)) {
> > +		if (!(q->flags & TCQ_F_ONETXQUEUE) ||
> > +		    !netif_xmit_frozen_or_stopped(txq)) {
> > +			int bytelimit = qdisc_avail_bulklimit(txq);
> > +
> >  			skb = q->dequeue(q);
> > -			if (skb)
> > +			if (skb) {
> > +				bytelimit -= skb->len;
> >  				skb = validate_xmit_skb(skb, qdisc_dev(q));
> > +			}
> > +			if (skb && qdisc_may_bulk(q))
> > +				skb = try_bulk_dequeue_skb(q, skb, bytelimit);
> >  		}
> >  	}
> 
> Okay...
> 
> In my opinion, you guys missed some opportunities :
> 
> 1) Ideally the algo should try to call validate_xmit_skb() outside of
> the locks (qdisc lock or device lock), because eventually doing checksum
> computation or full segmentation should allow other cpus doing enqueues.

You're right, but this is not related to this patch specifically.
But sure, we can look into moving validate_xmit_skb calls outside of the
qdisc root locked sections.

> 2) TSO support. Have you ideas how to perform this ?

Yes, the idea was to just remove the skb_is_gso() test and limit
dql_avail() result to e.g. 128k to avoid a '8-fat-gso-skbs-in-a-row' scenario.

Did you have any other ideas in mind?

Thanks,
Florian
