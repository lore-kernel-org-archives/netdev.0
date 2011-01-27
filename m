From: Simon Horman <horms@verge.net.au>
Subject: Re: TSO/GRO/LRO/somethingO breaks LVS on 2.6.36
Date: Thu, 27 Jan 2011 11:36:43 +1000
Message-ID: <20110127013640.GA2284@verge.net.au>
References: <20101203103447.GA29714@hostway.ca>
 <1291375743.2897.141.camel@edumazet-laptop>
 <20101203123617.GA6993@verge.net.au>
 <20101209023509.GA21216@hostway.ca>
 <1291863119.2795.29.camel@edumazet-laptop>
 <20101222233948.GC17581@hostway.ca>
 <20110113063422.GB14643@verge.net.au>
 <20110127004805.GB11578@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Simon Kirby <sim@hostway.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:32804 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754331Ab1A0Bgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jan 2011 20:36:48 -0500
Content-Disposition: inline
In-Reply-To: <20110127004805.GB11578@hostway.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 26, 2011 at 04:48:05PM -0800, Simon Kirby wrote:
> On Thu, Jan 13, 2011 at 03:34:22PM +0900, Simon Horman wrote:
> 
> > Hi Simon,
> > 
> > thanks for prodding me to respond to this post offline and sorry for not
> > responding earlier.
> > 
> > Firstly, I think that this is a receive-side problem so I don't believe
> > that GSO (generic segmentation offload) or other transmit-side options are
> > likely to have any affect.
> > 
> > My understanding is that on the receive-side there are two options which
> > when enabled can result in the behaviour that you describe.
> > 
> > * LRO (large receive offload)
> > 
> >   You have this disabled, and assuming it really is disabled it
> >   shouldn't be causing a problem.
> > 
> > * GRO (generic receive offload)
> > 
> >   This does not seem to be in the output of your ethtool commands at all.
> >   So I wonder if your ethtool is too old to support this option?
> 
> So, this was the case.  Our ethtool (lenny) was too old to see the GRO
> option, only GSO.  Disabling GRO on eth1.39 has no effect, but disabling
> it on eth1 caused it to stop receiving the merged frames, fixing the LVS
> packet loss (due to no sending GSO support from LVS/IPVS).
> 
> Speaking of this, did your patch for LVS/IPVS GSO support go anywhere? 

The patch for IPVS GRO support has been merged and should appear in 2.6.39.
This is somewhat later than I previously anticipated due to a merge mix-up
on my part.

> >   In any case, I was able to reproduce the problem that you describe (or at
> >   least something very similar) using 2.6.36 with GRO enabled on eth1.1 and
> >   the problem did not manifest when I disabled GRO on eth1.1.
> 
> It worked for you to do ethtool -K eth1.1 gro off, then?  For me on
> 2.6.37, it seemed to be that "ethtool -K eth1 gro off" was needed, even
> though packets arrive on eth1.39.

I will recheck my results, but in general I think it is a bit
of an open question as to how ethtool settings should be propagated
between related devices.

> Also, strangely, 2.6.35.4's default state (with no received merged frames)
> has GRO on for eth1 but off for eth1.39:
> 
> # ethtool -k eth1
> Offload parameters for eth1:
> rx-checksumming: on
> tx-checksumming: on
> scatter-gather: on
> tcp-segmentation-offload: on
> udp-fragmentation-offload: off
> generic-segmentation-offload: on
> generic-receive-offload: on
> large-receive-offload: off
> ntuple-filters: off
> receive-hashing: off
> 
> # ethtool -k eth1.39
> Offload parameters for eth1.39:
> rx-checksumming: on
> tx-checksumming: off
> scatter-gather: off
> tcp-segmentation-offload: off
> udp-fragmentation-offload: off
> generic-segmentation-offload: off
> generic-receive-offload: off
> large-receive-offload: off
> ntuple-filters: off
> receive-hashing: off
> 
> If I set 2.6.37 to have all of the same options, I still see GRO frames
> on 2.6.37 (tg3), which is weird.

Yes that is a weird.

There has been quite a lot of work on VLANs recently and
I suspect that the behaviour that you are observing with 2.6.37
is a regression that occurred during that work. It would
be good to fix things to restore the 2.6.35 behaviour.
