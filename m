From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] xps-mq: Transmit Packet Steering for multiqueue
Date: Thu, 16 Sep 2010 22:52:41 +0100
Message-ID: <1284673961.2283.57.camel@achroite.uk.solarflarecom.com>
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
Received: from exchange.solarflare.com ([216.237.3.220]:23180 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756323Ab0IPVwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 17:52:50 -0400
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

And ideally a cheap way (not O(N^2)) to find the distance between 2 CPU
threads (not just nodes).

> And that can be used to tweak all of this stuff.
> 
> The policy should probably be in userspace, we just need to provide
> the knobs in the kernel to tweak it however userspace wants.
> 
> Userspace should be able to, for example, move a TX queue into a
> NUMA domain and have this invoke several side effects:
> 
> 1) IRQs for that TX queue get rerouted to a cpu in the NUMA
>    domain.
> 
> 2) TX queue datastructures in the driver get reallocated using
>    memory in that NUMA domain.

I've actually done some work on an interface and implementation of this,
although I didn't include actually setting the IRQ affinity as there has
been pushback whenever people propose letting drivers set this.  If they
only do so as directed by the administrator this might be more
acceptable though.

Unfortunately in my limited testing on a 2-node system I didn't see a
whole lot of improvement in performance when the affinities were all
lined up.  I should try to get some time on a 4-node system.

> 3) TX hashing is configured to use the set of cpus in the NUMA
>    domain.
> 
> It's alot of tedious work and involves some delicate tasks figuring
> out where each of these things go, but really then we'd solve all
> of this crap one and for all.

Right.

The other thing I've been working on lately which sort of ties into this
is hardware acceleration of Receive Flow Steering.  Multiqueue NICs such
as ours tend to have RX flow filters as well as hashing.  So why not use
those to do a first level of steering?  We're going to do some more
internal testing and review but I hope to send out a first version of
this next week.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

