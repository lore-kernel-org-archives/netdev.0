From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH 0/10] [IOAT] I/OAT patches repost
Date: Thu, 20 Apr 2006 22:04:26 -0500
Message-ID: <20060421030426.GM26746@pb15.lixom.net>
References: <Pine.LNX.4.44.0604201329300.22544-100000@isotope.jf.intel.com> <20060420213305.GK26746@pb15.lixom.net> <20060420.172742.132879746.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: olof@lixom.net, andrew.grover@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:59097 "EHLO mail.lixom.net")
	by vger.kernel.org with ESMTP id S1751018AbWDUDFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2006 23:05:45 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060420.172742.132879746.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 20, 2006 at 05:27:42PM -0700, David S. Miller wrote:
> From: Olof Johansson <olof@lixom.net>
> Date: Thu, 20 Apr 2006 16:33:05 -0500
> 
> > From the wiki:
> > 
> > >    3. Data copied by I/OAT is not cached
> > 
> > This is a I/OAT device limitation and not a global statement of the
> > DMA infrastructure. Other platforms might be able to prime caches
> > with the DMA traffic. Hint flags should be added on either the channel
> > allocation calls, or per-operation calls, depending on where it makes
> > sense driver/client wise.
> 
> This sidesteps the whole question of _which_ cache to warm.  And if
> you choose wrongly, then what?
>
> Besides the control overhead of the DMA engines, the biggest thing
> lost in my opinion is the perfect cache warming that a cpu based copy
> does from the kernel socket buffer into userspace.

It's definitely the easiest way to always make sure the right caches
are warm for the app, that I agree with.

But, when warming those caches by copying, the data is pulled in through
a potentially cold cache in the first place. So the cache misses are
just moved from the copy loop to userspace with dma offload. Or am I
missing something?

> The first thing an application is going to do is touch that data.  So
> I think it's very important to prewarm the caches and the only
> straightforward way I know of to always warm up the correct cpu's
> caches is copy_to_user().

The other way (assuming the hardware supports cache warming) would be
to pass down affinities (or look them up during receive processing,
I'm not sure that's practical the way things work now), and dispatch
on a DMA channel with the right cache affinity. I've got a feeling that
"straightforward" is not a term to use for describing that solution
though.

> Unfortunately, many benchmarks just do raw bandwidth tests sending to
> a receiver that just doesn't even look at the data.  They just return
> from recvmsg() and loop back into it.  This is not what applications
> using networking actually do, so it's important to make sure we look
> intelligently at any benchmarks done and do not fall into the trap of
> saying "even without cache warming it made things faster" when in fact
> the tested receiver did not touch the data at all so was a false test.

Yes, some real-life-like benchmarking is definitiely needed. Unfortunately
I'm not at a position where I can do much (and share numbers) at the
moment myself.


-Olof
