From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] xps-mq: Transmit Packet Steering for multiqueue
Date: Mon, 21 Feb 2011 18:19:55 +0000
Message-ID: <1298312395.2608.65.camel@bwh-desktop>
References: <AANLkTin2rmcsxHi6+bFEUykhrkoWs--hrisAx_v__k1D@mail.gmail.com>
	 <1283356463.2556.351.camel@edumazet-laptop>
	 <AANLkTinOfkr=+_61kb+bZf_0brcahQz8b_P6TWhUgFka@mail.gmail.com>
	 <20100901.183251.106803238.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, eric.dumazet@gmail.com, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:4986 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151Ab1BUST6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 13:19:58 -0500
In-Reply-To: <20100901.183251.106803238.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-09-01 at 18:32 -0700, David Miller wrote:
> From: Tom Herbert <therbert@google.com>
> Date: Wed, 1 Sep 2010 09:24:18 -0700
> 
> > On Wed, Sep 1, 2010 at 8:54 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >> 3) Eventually have a user selectable selection (socket option, or system
> >> wide, but one sysctl, not many bitmasks ;) ).
> >>
> > Right, but it would also be nice if a single sysctl could optimally
> > set up multiqueue, RSS, RPS, and all my interrupt affinities for me
> > ;-)
> 
> It's becomming increasingly obvious to me that we need (somewhere,
> not necessarily the kernel) a complete datastructure representing
> the NUMA, cache, cpu, device hierarchy.
> 
> And that can be used to tweak all of this stuff.
> 
> The policy should probably be in userspace, we just need to provide
> the knobs in the kernel to tweak it however userspace wants.
> 
> Userspace should be able to, for example, move a TX queue into a
> NUMA domain and have this invoke several side effects:

I think most of the pieces are now ready:

> 1) IRQs for that TX queue get rerouted to a cpu in the NUMA
>    domain.

There is a longstanding procfs interface for IRQ affinity, and userland
infrastructure built on it.  Adding a new interface would be contentious
and I have tried to build on it instead.

> 2) TX queue datastructures in the driver get reallocated using
>    memory in that NUMA domain.

I've previously sent patches to add an ethtool API for NUMA control,
which include the option to allocate on the same node where IRQs are
handled.  However, there is currently no function to allocate
DMA-coherent memory on a specified NUMA node (rather than the device's
node).  This is likely to be beneficial for event rings and might be
good for descriptor rings for some devices.  (The implementation I sent
for sfc mistakenly switched it to allocating non-coherent memory, for
which it *is* possible to specify the node.)

> 3) TX hashing is configured to use the set of cpus in the NUMA
>    domain.

I posted patches for automatic XPS configuration at the end of last
week.  And RFS acceleration covers the other direction.

Ben.

> It's alot of tedious work and involves some delicate tasks figuring
> out where each of these things go, but really then we'd solve all
> of this crap one and for all.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

