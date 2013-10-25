From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: Big performance loss from 3.4.63 to 3.10.13 when routing ipv4
Date: Fri, 25 Oct 2013 10:01:58 +0200
Message-ID: <20131025080158.GC31491@secunet.com>
References: <3244031.uQGDddGTLF@h2o.as.studentenwerk.mhn.de>
 <3169911.kTmZ0BZVVr@h2o.as.studentenwerk.mhn.de>
 <1382547992.7572.31.camel@edumazet-glaptop.roam.corp.google.com>
 <5743349.5WGxWa1M1u@ei.h3.stusta.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, hannes@stressinduktion.org,
	netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: Wolfgang Walter <linux@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:32922 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751214Ab3JYICB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Oct 2013 04:02:01 -0400
Content-Disposition: inline
In-Reply-To: <5743349.5WGxWa1M1u@ei.h3.stusta.mhn.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 24, 2013 at 12:52:58AM +0200, Wolfgang Walter wrote:
> On Wednesday 23 October 2013 10:06:32 Eric Dumazet wrote:
> > On Wed, 2013-10-23 at 18:59 +0200, Wolfgang Walter wrote:
> > > Ah, ok. I use SLUB, but SLABINFO=y.
> > > 
> > > Without much traffic it is:
> > > 
> > > # grep dst /proc/slabinfo
> > > xfrm_dst_cache      4435   4608    448   36    4 : tunables    0    0    0
> > > : slabdata    128    128      0
> > > 
> > > on the big one.
> > > 
> > > I can recompile the kernels with SLAB instead of SLUB if SLAB gives more
> > > usefull infos.
> > Not needed, because it seems we do not merge this SLUB cache with
> > another one.
> 
> Ok. I can't see xfrm_dst_cache on 32bit-systems, though.
> 
> > 
> > So please post this information, because I believe the default should be
> > 65536, not 1024 or 4096
> > 
> 
> Indeed I already saw higher values, at the moment I see:
> 
> # while true; do grep dst /proc/slabinfo ; sleep 1; done
> xfrm_dst_cache     12636  12636    448   36    4 : tunables    0    0    0 : slabdata    351    351      0

We currently start the garbage collector if we have more than gc_thresh
(1024) dst entries allocated and refuse new allocations at 2 * gc_thresh.

So maybe we should set gc_thresh to 32768. Than we can have 65536 dst
entries in the system (cache + packets in flight) before we refuse
new allocations. In paticular we can still cache another 32768 dst
entries after the garbage collector was started. It looks like you
had never more than 15000 dst entries cached, so a default of 32768
looks reasonable and should also keep smaller embedded routers happy.
