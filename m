From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH 0/10] [IOAT] I/OAT patches repost
Date: Thu, 20 Apr 2006 18:33:43 -0500
Message-ID: <20060420233343.GL26746@pb15.lixom.net>
References: <Pine.LNX.4.44.0604201329300.22544-100000@isotope.jf.intel.com> <20060420213305.GK26746@pb15.lixom.net> <c0a09e5c0604201514x16490b13v68644a24078b99de@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:13784 "EHLO mail.lixom.net")
	by vger.kernel.org with ESMTP id S1751280AbWDTXep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2006 19:34:45 -0400
To: Andrew Grover <andy.grover@gmail.com>
Content-Disposition: inline
In-Reply-To: <c0a09e5c0604201514x16490b13v68644a24078b99de@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 20, 2006 at 03:14:15PM -0700, Andrew Grover wrote:
> Hah, I was just writing an email covering those. I'll incorporate that
> into this reponse.
> 
> On 4/20/06, Olof Johansson <olof@lixom.net> wrote:
> > I guess the overall question is, how much of this needs to be addressed
> > in the implementation before merge, and how much should be done when
> > more drivers (with more features) are merged down the road. It might not
> > make sense to implement all of it now if the only available public
> > driver lacks the abilities.   But I'm bringing up the points anyway.
> 
> Yeah. But I would think maybe this is a reason to merge at least the
> DMA subsystem code, so people with other HW (ARM? I'm still not
> exactly sure) can start trying to write a DMA driver and see where the
> architecture needs to be generalized further.

The interfaces need to evolve as people implement drivers, yes. If it
should be before or after merging can be discussed, but as long as
everyone is on the same page w.r.t. the interfaces being volatile for a
while, merge should be OK.

Having a roadmap of known-todo improvements could be beneficial for
everyone involved, especially if several people start looking at drivers
in parallel. However, so far, (public) activity seems to have been
fairly low.

> > I would also prefer to see the series clearly split between the DMA
> > framework and first clients (networking) and the I/OAT driver. Right now
> > "I/OAT" and "DMA" is used interchangeably, especially when describing
> > the later patches. It might help you in the perception that this is
> > something unique to the Intel chipsets as well.  :-)
> 
> I think we have this reasonably well split-out in the patches, but yes
> you're right about how we've been using the terms.

The patches are well split up already, it was mostly that the network
stack changes were marked as I/OAT changes instead of DMA dito.

> > >    1. Performance improvement may be on too narrow a set of workloads
> > Maybe from I/OAT and the current client, but the introduction of the
> > DMA infrastructure opens up for other uses that are not yet possible in
> > the API. For example, DMA with functions is a very natural extension,
> > and something that's very common on various platforms (XOR for RAID use,
> > checksums, encryption).
> 
> Yes. Does this hardware exist in shipping platforms, so we could use
> actual hw to start evaluating the DMA interfaces?

Freescale has it on several processors that are shipping, as far as I
know. Other embedded families likely has them as well (MIPS, ARM), but
I don't know details. The platform I am working on is not yet shipping;
I've just started looking at drivers.

> > For people who might want to play with it, a reference software-based
> > implementation might be useful.
> 
> Yeah I'll ask if I can post the one we have. Or it would be trivial to write.

I was going to look at it myself, but if you have one to post that's
even more trivial. :-)

> > >    3. Data copied by I/OAT is not cached
> >
> > This is a I/OAT device limitation and not a global statement of the
> > DMA infrastructure. Other platforms might be able to prime caches
> > with the DMA traffic. Hint flags should be added on either the channel
> > allocation calls, or per-operation calls, depending on where it makes
> > sense driver/client wise.
> 
> Furthermore in our implementation's defense I would say I think the
> smart prefetching that modern CPUs do is helping here.

Yes. It's also not obvious that warming the cache at copy time is always
a gain, it will depends on the receiver and what it does with the data.

> In any case, we
> are seeing performance gains (see benchmarks), which seems to indicate
> this is not an immediate deal-breaker for the technology..

There's always the good old benefit-vs-added-complexity tradeoff, which
I guess is the sore spot right now.

> In
> addition, there may be workloads (file serving? backup?) where we
> could do a skb->page-in-page-cache copy and avoid cache pollution?

Yes, NFS is probably a prime example of where most of the data isn't
looked at; just written to disk. I'm not sure how well-optimized the
receive path is there already w.r.t. avoiding copying though. I don't
remember seeing memcpy and friends being high on the profile when I
looked at SPECsfs last.

> > >    4. Intrusiveness of net stack modifications
> > >    5. Compatibility with upcoming VJ net channel architecture
> > Both of these are outside my scope, so I won't comment on them at this
> > time.
> 
> Yeah I don't have much to say about these except we made the patch as
> unintrusive as we could, and we think there may be ways to use async
> DMA to
> help VJ channels, whenever they arrive.

Not that I know all the tricks they are using, but it seems to me that it
would be hard to both be efficient w.r.t memory use (i.e. more than one
IP packet per page) AND avoid copying once. At least without device-level
flow classification and per-flow (process) buffer rings.



-Olof
