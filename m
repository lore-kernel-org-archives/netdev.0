From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Thu, 27 Apr 2006 15:51:26 +0400
Message-ID: <20060427115126.GA11570@2ka.mipt.ru>
References: <200604261147.34221.kelly@au.ibm.com> <20060426.003335.26972263.davem@davemloft.net> <200604271331.37073.kelly@au.ibm.com> <20060426.232501.119306252.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: kelly@au1.ibm.com, rusty@rustcorp.com.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:39385 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S965026AbWD0LwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 07:52:16 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060426.232501.119306252.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 26, 2006 at 11:25:01PM -0700, David S. Miller (davem@davemloft.net) wrote:
> > We approached this from the understanding that an intelligent NIC
> > will be able to transition directly to userspace, which is a major
> > win.  0 copies to userspace would be sweet.  I think we can still
> > achieve this using your scheme without *too* much pain.
> 
> Understood.  What's your basic idea?  Just make the buffers in the
> pool large enough to fit the SKB encapsulation at the end?

There are some caveats here found while developing zero-copy sniffer
[1]. Project's goal was to remap skbs into userspace in real-time.
While absolute numbers (posted to netdev@) were really high, it is only
applicable to read-only application. As was shown in IOAT thread,
data must be warmed in caches, so reading from mapped area will be as
fast as memcpy() (read+write), and copy_to_user() actually almost equal
to memcpy() (benchmarks were posted to netdev@). And we must add
remapping overhead.

If we want to dma data from nic into premapped userspace area, this will
strike with message sizes/misalignment/slow read and so on, so
preallocation has even more problems.

This change also requires significant changes in application, at least
until recv/send are changed, which is not the best thing to do.

So I think that mapping itself can be done as some additional socket
option or something not turnedon by default.


I do think that significant win in VJ's tests belongs not to remapping
and cache-oriented changes, but to move all protocol processing into
process' context.

I fully agree with Dave that it must be implemented step-by-step, and
the most significant, IMHO, is moving protocol processing into socket's
"place". This will force to netfilter changes, but I do think that for
the proof-of-concept code we can turn it off.

I will start to work in this direction next week after aio_sendfile() is
completed.

So, we will have three attempts to write incompatible stacks - and that is good :)
No one need an excuse to rewrite something, as I read in Rusty's blog...

Thanks.

[1]. http://tservice.net.ru/~s0mbre/old/?section=projects&item=af_tlb

-- 
	Evgeniy Polyakov
