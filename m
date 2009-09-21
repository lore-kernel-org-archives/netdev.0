From: Mel Gorman <mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>
Subject: Re: ipw2200: firmware DMA loading rework
Date: Mon, 21 Sep 2009 12:02:53 +0100
Message-ID: <20090921110253.GM12726@csn.ul.ie>
References: <riPp5fx5ECC.A.2IG.qsGlKB@chimera> <200909211159.27344.bzolnier@gmail.com> <20090921100813.GL12726@csn.ul.ie> <200909211246.34774.bzolnier@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Tso Ted <tytso-3s7WtUTddSA@public.gmane.org>,
	"Aneesh Kumar K.V" <aneesh.kumar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>,
	Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Mel Gorman <mel-wJa12IhQEiizQB+pC5nmwQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>,
	James Ketrenos <jketreno-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"Chatre, Reinette" <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"ipw2100-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org"
	<ipw2100-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Bartlomiej Zolnierkiewicz <bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <200909211246.34774.bzolnier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 21, 2009 at 12:46:34PM +0200, Bartlomiej Zolnierkiewicz wrote:
> > > > > <SNIP>
> > > > >
> > > > > This time it is an order-6 page allocation failure for rt2870sta
> > > > > (w/ upcoming driver changes) and Linus' tree from few days ago..
> > > > > 
> > > > 
> > > > It's another high-order atomic allocation which is difficult to grant.
> > > > I didn't look closely, but is this the same type of thing - large allocation
> > > > failure during firmware loading? If so, is this during resume or is the
> > > > device being reloaded for some other reason?
> > > 
> > > Just modprobing the driver on a system running for some time.
> > > 
> > 
> > Was this a common situation before?
> 
> Yes, just like firmware restarts with ipw2200.
> 
> > > > I suspect that there are going to be a few of these bugs cropping up
> > > > every so often where network devices are assuming large atomic
> > > > allocations will succeed because the "only time they happen" is during
> > > > boot but these days are happening at runtime for other reasons.
> > > 
> > > I wouldn't go so far as calling a normal order-6 (256kB) allocation on
> > > 512MB machine with 1024MB swap a bug.  Moreover such failures just never
> > > happened before 2.6.31-rc1.
> > 
> > It's not that normal, it's an allocation that cannot sleep and cannot
> > reclaim. Why is something like firmware loading allocating memory like
> 
> OK.
> 
> > that? Is this use of GFP_ATOMIC relatively recent or has it always been
> > that way?
> 
> It has always been like that.
> 

Nuts, why is firmware loading depending on GFP_ATOMIC?

> > > I don't know why people don't see it but for me it has a memory management
> > > regression and reliability issue written all over it.
> > > 
> > 
> > Possibly but drivers that reload their firmware as a response to an
> > error condition is relatively new and loading network drivers while the
> > system is already up and running a long time does not strike me as
> > typical system behaviour.
> 
> Loading drivers after boot is a typical desktop/laptop behavior, please
> think about hotplug (the hardware in question is an USB dongle).
> 

In that case, how reproducible is this problem so it can be
bisected? Basically, there are no guarantees that GFP_ATOMIC allocations
of this order will succeed although you can improve the odds by increasing
min_free_kbytes. Network drivers should never have been depending on GFP_ATOMIC
succeeding like this but the hole has been dug now.

If it's happening more frequently now than it used to then either

1. The allocations are occuring more frequently where as previously a
   pool might have been reused or the memory not freed for the lifetime of
   the system.

2. Something has changed in the allocator. I'm not aware of recent
   changes that could cause this though in such a recent time-frame.

3. Something has changed recently with respect to reclaim. There have
   been changes made recently to lumpy reclaim and that might be impacting
   kswapd's efforts at keeping large contiguous regions free.

4. Hotplug events that involve driver loads are more common now than they
   were previously for some reason. You mention that this is a USB dongle for
   example. Was it a case before that the driver loaded early and remained
   resident but only active after a hotplug event? If that was the case,
   the memory would be allocated once at boot. However, if an optimisation
   made recently unloads those unused drivers and re-loads them later, there
   would be more order-6 allocations than they were previously and manifest
   as these bug reports. Is this a possibility?

The ideal would be that network drivers not make allocations like this
in the first place by, for example, DMAing the firmware across in
page-size chunks instead of one contiguous lump :/

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab
