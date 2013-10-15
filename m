From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH RFC 0/2] xfrm: Remove ancient sleeping code
Date: Tue, 15 Oct 2013 09:30:20 +0200
Message-ID: <20131015073020.GV7660@secunet.com>
References: <20131010063301.GO7660@secunet.com>
 <20131011.150124.527914076255487526.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:34641 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751200Ab3JOHaX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Oct 2013 03:30:23 -0400
Content-Disposition: inline
In-Reply-To: <20131011.150124.527914076255487526.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 11, 2013 at 03:01:24PM -0400, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Thu, 10 Oct 2013 08:33:01 +0200
> 
> > The two RFC patches to remove the sleeping code are in reply to this
> > mail. I'd add this to the ipsec-next tree if there are no objections.
> 
> The sleep path has the slight benefit that the TCP retransmit timers
> for the initial SYN packet will not be started until the IPSEC rule
> is resolved and the SYN actually goes out.

Yes, that's a slight advantage of the sleeping. But if the IPsec state
does not get resolved for whatever reason, the retransmit timer will
never start. The task will wake up but goes back to sleep immediately
because the needed state is not resolved.

> 
> With the packet queue, if the IPSEC resolution is slow then we'll have
> spurious SYN retransmits.
> 
> It makes no sense for TCP to keep queueing up SYNs if they will just
> all get stuck in the packet queue.  The first one is enough.

Right, that's why I've limited the queue to 100 packets. We can
queue the SYNs of up to 100 tcp connestions that want to use
this IPsec state. It surely can happen that we queue multiple
retransmitted SYNs if the IPsec resolution is slow. But the
queueing code tries at least to get the packets out before
the first tcp retransmit. I think there is still room for
optimizations, maybe reducing the queue lenght or the queue
timeout to avoid queueing retransmitted SYNs as much as possible.

> 
> On the other hand we do want TCP to timeout, we do want the user to
> be able to "Ctrl-C" (ie. send a SIGINT) during a connect, etc.

As mentioned above, tcp does not timeout if the state is not
getting resolved and the task that tried to open the tcp
conection hangs indefinitely.

We could fiddle something to get a terminating condition if the
state is not resolved after some time, but my plan was to disable
the larval_drop sysctl by default some day again. At best without
any notable change to userspace. That's why I would prefer to
remove the sleeping entirely.
