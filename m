From: Simon Kirby <sim@hostway.ca>
Subject: Re: TSO/GRO/LRO/somethingO breaks LVS on 2.6.36
Date: Wed, 26 Jan 2011 16:48:05 -0800
Message-ID: <20110127004805.GB11578@hostway.ca>
References: <20101203103447.GA29714@hostway.ca> <1291375743.2897.141.camel@edumazet-laptop> <20101203123617.GA6993@verge.net.au> <20101209023509.GA21216@hostway.ca> <1291863119.2795.29.camel@edumazet-laptop> <20101222233948.GC17581@hostway.ca> <20110113063422.GB14643@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netnation.com ([204.174.223.2]:60161 "EHLO peace.netnation.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753679Ab1A0AsH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jan 2011 19:48:07 -0500
Content-Disposition: inline
In-Reply-To: <20110113063422.GB14643@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 13, 2011 at 03:34:22PM +0900, Simon Horman wrote:

> Hi Simon,
> 
> thanks for prodding me to respond to this post offline and sorry for not
> responding earlier.
> 
> Firstly, I think that this is a receive-side problem so I don't believe
> that GSO (generic segmentation offload) or other transmit-side options are
> likely to have any affect.
> 
> My understanding is that on the receive-side there are two options which
> when enabled can result in the behaviour that you describe.
> 
> * LRO (large receive offload)
> 
>   You have this disabled, and assuming it really is disabled it
>   shouldn't be causing a problem.
> 
> * GRO (generic receive offload)
> 
>   This does not seem to be in the output of your ethtool commands at all.
>   So I wonder if your ethtool is too old to support this option?

So, this was the case.  Our ethtool (lenny) was too old to see the GRO
option, only GSO.  Disabling GRO on eth1.39 has no effect, but disabling
it on eth1 caused it to stop receiving the merged frames, fixing the LVS
packet loss (due to no sending GSO support from LVS/IPVS).

Speaking of this, did your patch for LVS/IPVS GSO support go anywhere? 

>   In any case, I was able to reproduce the problem that you describe (or at
>   least something very similar) using 2.6.36 with GRO enabled on eth1.1 and
>   the problem did not manifest when I disabled GRO on eth1.1.

It worked for you to do ethtool -K eth1.1 gro off, then?  For me on
2.6.37, it seemed to be that "ethtool -K eth1 gro off" was needed, even
though packets arrive on eth1.39.

Also, strangely, 2.6.35.4's default state (with no received merged frames)
has GRO on for eth1 but off for eth1.39:

# ethtool -k eth1
Offload parameters for eth1:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp-segmentation-offload: on
udp-fragmentation-offload: off
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off
ntuple-filters: off
receive-hashing: off

# ethtool -k eth1.39
Offload parameters for eth1.39:
rx-checksumming: on
tx-checksumming: off
scatter-gather: off
tcp-segmentation-offload: off
udp-fragmentation-offload: off
generic-segmentation-offload: off
generic-receive-offload: off
large-receive-offload: off
ntuple-filters: off
receive-hashing: off

If I set 2.6.37 to have all of the same options, I still see GRO frames
on 2.6.37 (tg3), which is weird.

Cheers,

Simon-
