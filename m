From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] fast_hash: avoid indirect function calls
Date: Thu, 06 Nov 2014 16:13:58 +0100
Message-ID: <1415286838.24404.35.camel@localhost>
References: <8214a3fdc8b7f97bb782c8722e9f1e65037553fe.1415142006.git.hannes@stressinduktion.org>
	 <20141105.220306.359839190322444593.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel@vger.kernel.org,
	dborkman@redhat.com, tgraf@suug.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:58460 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751295AbaKFPOB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 10:14:01 -0500
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 8061120D28
	for <netdev@vger.kernel.org>; Thu,  6 Nov 2014 10:14:00 -0500 (EST)
In-Reply-To: <20141105.220306.359839190322444593.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mi, 2014-11-05 at 22:03 -0500, David Miller wrote:
> > Would it make sense to start suppressing the generation of local
> > functions for static inline functions which address is taken?
> > 
> > E.g. we could use extern inline in a few cases (dst_output is often used
> > as a function pointer but marked static inline).  We could mark it as
> > extern inline and copy&paste the code to a .c file to prevent multiple
> > copies of machine code for this function. But because of the copy&paste I
> > did not in this case.
> 
> I'd say that perhaps dst_output() can be handled in the "traditional"
> way, by not inlining it ever.

Yes, that sounds sane. dst_output (8 copies), dst_discard (6 copies)
seem to be good candidates but also won't change much as they are
trivially short. Fast path mostly uses them as function pointers, so we
shouldn't see any slowdown here.

I figured out that extern inlining functions and copy&pasting the code
does only make sense for functions which don't depend on static inline
functions, so this option to reduce code bloat is absolutely useless.

Btw. our most duplicated function in an allyesconfig-build (not size
optimized) is netif(_tx)_stop_queue with 30 (or 180 if -Os) copies
(netif_wake_queue 135 copies with -Os, not visible in -O2).

> If we have indirect function invocations and non-direct inlines, maybe
> in the end it's better to have it in a single hot cache location, no?

I am not sure and this very much depends on the cpu, I think. But
reducing icache pressure is always a good thing and leads to better
performance after all, so in general I would agree. Also, unconditional
direct branches should be very fast nowadays.

But if we care about size I wouldn't touch the code and hope stuff like
gnu gold's ICF (identical code folding) or gnu ld --gc-sections in
combination with --ffunction-sections and --fdata-sections will be used
by the kernel some day to eliminate copies of duplicate functions.

Bye,
Hannes
