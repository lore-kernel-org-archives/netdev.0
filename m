From: Benjamin Poirier <bpoirier@suse.de>
Subject: Re: [PATCH v2 3/3] tg3: Fix tx_pending checks for tg3_tso_bug
Date: Tue, 26 Aug 2014 12:25:21 -0700
Message-ID: <20140826192521.GA4745@f1.synalogic.ca>
References: <1408658240-6811-1-git-send-email-bpoirier@suse.de>
 <1408658240-6811-3-git-send-email-bpoirier@suse.de>
 <1408749447.8268.53.camel@prashant>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Prashant Sreedharan <prashant@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1408749447.8268.53.camel@prashant>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2014/08/22 16:17, Prashant Sreedharan wrote:
> Benjamin, thanks for the patch. Broadcom QA will be testing the changes.
> Couple of comments below.
> >  	segs = skb_gso_segment(skb, tp->dev->features &
> >  				    ~(NETIF_F_TSO | NETIF_F_TSO6));
> > -	if (IS_ERR(segs) || !segs)
> > +	if (IS_ERR_OR_NULL(segs))
> >  		goto tg3_tso_bug_end;
> >  
> >  	do {
> > +		unsigned int desc_cnt = skb_shinfo(segs)->nr_frags + 1;
> > +
> >  		nskb = segs;
> >  		segs = segs->next;
> >  		nskb->next = NULL;
> > -		tg3_start_xmit(nskb, tp->dev);
> > +
> > +		if (tg3_tx_avail(tnapi) <= segs_remaining - 1 + desc_cnt &&
> > +		    skb_linearize(nskb)) {
> > +			nskb->next = segs;
> > +			segs = nskb;
> > +			do {
> > +				nskb = segs->next;
> > +
> > +				dev_kfree_skb_any(segs);
> > +				segs = nskb;
> > +			} while (segs);
> 
> If skb_linearize() fails need to increment the tp->tx_dropped count

Sorry for the delay, while testing this error path I noticed a potential
problem. There should be an additional check here to stop the queue with
the default threshold. Otherwise, the netdev_err message at the start of
__tg3_start_xmit() could be triggered when the next frame is
transmitted. That is because the previous calls to __tg3_start_xmit() in
tg3_tso_bug() may have been using a stop_thresh=segs_remaining that is <
MAX_SKB_FRAGS + 1.

> 
> > +			goto tg3_tso_bug_end;
> > +		}
> > +		segs_remaining--;
> > +		if (segs_remaining)
> > +			__tg3_start_xmit(nskb, tp->dev, segs_remaining);
> 
> To clarify passing segs_remaining will make sure the queue is never
> stopped correct ?

It makes sure the queue is not stopped before we are finished submitting
all gso segments.

This is what's alluded to in this part of the commit message:
	This puts us in the exceptional situation that a single skb that
	triggers tg3_tso_bug() may require the entire tx ring. [...]
	Likewise, usually the tx queue is stopped as soon as an skb with
	max frags may overrun it. Since the skbs submitted from
	tg3_tso_bug() use a controlled number of descriptors, the tx
	queue stop threshold may be lowered.

> 
> > +		else
> > +			tg3_start_xmit(nskb, tp->dev);
> >  	} while (segs);
> >  
> 
> 
