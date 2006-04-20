From: "Andrew Grover" <andy.grover@gmail.com>
Subject: Re: [PATCH 0/10] [IOAT] I/OAT patches repost
Date: Thu, 20 Apr 2006 15:14:15 -0700
Message-ID: <c0a09e5c0604201514x16490b13v68644a24078b99de@mail.gmail.com>
References: <Pine.LNX.4.44.0604201329300.22544-100000@isotope.jf.intel.com>
	 <20060420213305.GK26746@pb15.lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Andrew Grover" <andrew.grover@intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xproxy.gmail.com ([66.249.82.200]:20127 "EHLO xproxy.gmail.com")
	by vger.kernel.org with ESMTP id S932076AbWDTWOQ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 18:14:16 -0400
Received: by xproxy.gmail.com with SMTP id t10so224934wxc
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 15:14:15 -0700 (PDT)
To: "Olof Johansson" <olof@lixom.net>
In-Reply-To: <20060420213305.GK26746@pb15.lixom.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hah, I was just writing an email covering those. I'll incorporate that
into this reponse.

On 4/20/06, Olof Johansson <olof@lixom.net> wrote:
> I guess the overall question is, how much of this needs to be addressed
> in the implementation before merge, and how much should be done when
> more drivers (with more features) are merged down the road. It might not
> make sense to implement all of it now if the only available public
> driver lacks the abilities.   But I'm bringing up the points anyway.

Yeah. But I would think maybe this is a reason to merge at least the
DMA subsystem code, so people with other HW (ARM? I'm still not
exactly sure) can start trying to write a DMA driver and see where the
architecture needs to be generalized further.

> Maybe it could make sense to add a software-based driver for reference,
> and for others to play around with.

We wrote one, but just for testing. I think we've been focused on the
performance story, so it didn't seem a priority.

> I would also prefer to see the series clearly split between the DMA
> framework and first clients (networking) and the I/OAT driver. Right now
> "I/OAT" and "DMA" is used interchangeably, especially when describing
> the later patches. It might help you in the perception that this is
> something unique to the Intel chipsets as well.  :-)

I think we have this reasonably well split-out in the patches, but yes
you're right about how we've been using the terms.

> (I have also proposed DMA offload discussions as a topic for the Kernel
> Summit. I have kept Chris Leech Cc:d on most of the emails in question. It
> should be a good place to get input from other subsystems regarding what
> functionality they would like to see provided, etc.)

I think that would be a good topic for the KS - like you say not
necessarily I/OAT but general DMA offload.

> >    1. Performance improvement may be on too narrow a set of workloads
> Maybe from I/OAT and the current client, but the introduction of the
> DMA infrastructure opens up for other uses that are not yet possible in
> the API. For example, DMA with functions is a very natural extension,
> and something that's very common on various platforms (XOR for RAID use,
> checksums, encryption).

Yes. Does this hardware exist in shipping platforms, so we could use
actual hw to start evaluating the DMA interfaces?

While you may not care (:-) I'd like to address the network
performance aspect above, for other netdev readers:

First obviously it's a technology for RX CPU improvement so there's no
benefit on TX workloads. Second it depends on there being buffers to
copy the data into *before* the data arrives. This happens to be the
case for benchmarks like netperf and Chariot, but real apps using
poll/select wouldn't see a benefit,  Just laying the cards out here.
BUT we are seeing very good CPU savings on some workloads, so for
those apps (and if select/poll apps could make use of a
yet-to-be-implemented async net interface) it would be a win.

I don't know what the breakdown is of apps doing blocking reads vs.
waiting, does anyone know?

> >    2. Limited availability of hardware supporting I/OAT
>
> DMA engines are fairly common, even though I/OAT might not be yet. They
> just haven't had a common infrastructure until now.

We've engaged early that's a good thing :) I think we'd like to see
some netdev people do some independent performance analysis of it. If
anyone is willing to do so and has time to do so, email us and let's
see what we can work out.

> For people who might want to play with it, a reference software-based
> implementation might be useful.

Yeah I'll ask if I can post the one we have. Or it would be trivial to write.

> >    3. Data copied by I/OAT is not cached
>
> This is a I/OAT device limitation and not a global statement of the
> DMA infrastructure. Other platforms might be able to prime caches
> with the DMA traffic. Hint flags should be added on either the channel
> allocation calls, or per-operation calls, depending on where it makes
> sense driver/client wise.

Furthermore in our implementation's defense I would say I think the
smart prefetching that modern CPUs do is helping here. In any case, we
are seeing performance gains (see benchmarks), which seems to indicate
this is not an immediate deal-breaker for the technology.. In
addition, there may be workloads (file serving? backup?) where we
could do a skb->page-in-page-cache copy and avoid cache pollution?

> >    4. Intrusiveness of net stack modifications
> >    5. Compatibility with upcoming VJ net channel architecture
> Both of these are outside my scope, so I won't comment on them at this
> time.

Yeah I don't have much to say about these except we made the patch as
unintrusive as we could, and we think there may be ways to use async
DMA to
help VJ channels, whenever they arrive.

> I would like to add, for longer term:
>    * Userspace interfaces:
> Are there any plans yet on how to export some of this to userspace? It
> might not make full sense for just memcpy due to overheads, but it makes
> sense for more advanced dma/offload engines.

I agree.

Regards -- Andy
