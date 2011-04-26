From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 12/13] mm: Throttle direct reclaimers if PF_MEMALLOC
 reserves are low and swap is backed by network storage
Date: Tue, 26 Apr 2011 15:26:24 +0100
Message-ID: <20110426142624.GH4658@suse.de>
References: <1303803414-5937-1-git-send-email-mgorman@suse.de>
 <1303803414-5937-13-git-send-email-mgorman@suse.de>
 <20110426223059.10f3edda@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Linux-MM <linux-mm@kvack.org>,
	Linux-Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: NeilBrown <neilb@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:43662 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756527Ab1DZO02 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2011 10:26:28 -0400
Content-Disposition: inline
In-Reply-To: <20110426223059.10f3edda@notabene.brown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 26, 2011 at 10:30:59PM +1000, NeilBrown wrote:
> On Tue, 26 Apr 2011 08:36:53 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> 
> > +/*
> > + * Throttle direct reclaimers if backing storage is backed by the network
> > + * and the PFMEMALLOC reserve for the preferred node is getting dangerously
> > + * depleted. kswapd will continue to make progress and wake the processes
> > + * when the low watermark is reached
> > + */
> > +static void throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
> > +					nodemask_t *nodemask)
> > +{
> > +	struct zone *zone;
> > +	int high_zoneidx = gfp_zone(gfp_mask);
> > +	DEFINE_WAIT(wait);
> > +
> > +	/* Check if the pfmemalloc reserves are ok */
> > +	first_zones_zonelist(zonelist, high_zoneidx, NULL, &zone);
> > +	prepare_to_wait(&zone->zone_pgdat->pfmemalloc_wait, &wait,
> > +							TASK_INTERRUPTIBLE);
> > +	if (pfmemalloc_watermark_ok(zone->zone_pgdat, high_zoneidx))
> > +		goto out;
> > +
> > +	/* Throttle */
> > +	do {
> > +		schedule();
> > +		finish_wait(&zone->zone_pgdat->pfmemalloc_wait, &wait);
> > +		prepare_to_wait(&zone->zone_pgdat->pfmemalloc_wait, &wait,
> > +							TASK_INTERRUPTIBLE);
> > +	} while (!pfmemalloc_watermark_ok(zone->zone_pgdat, high_zoneidx) &&
> > +			!fatal_signal_pending(current));
> > +
> > +out:
> > +	finish_wait(&zone->zone_pgdat->pfmemalloc_wait, &wait);
> > +}
> 
> You are doing an interruptible wait, but only checking for fatal signals.
> So if a non-fatal signal arrives, you will busy-wait.
> 
> So I suspect you want TASK_KILLABLE, so just use:
> 
>     wait_event_killable(zone->zone_pgdat->pfmemalloc_wait,
>                         pgmemalloc_watermark_ok(zone->zone_pgdata,
>                                                 high_zoneidx));
> 

Well, if a normal signal arrives, we do not necessarily want the
process to enter reclaim. For fatal signals, I allow it to continue
because it's not likely to be putting the system under more pressure
if it's exiting.

> (You also have an extraneous call to finish_wait)
> 

Which one? I'm not seeing a flow where finish_wait gets called twice
without a prepare_to_wait in between. 

-- 
Mel Gorman
SUSE Labs
