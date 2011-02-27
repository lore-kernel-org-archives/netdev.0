From: Thomas Graf <tgraf@infradead.org>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Sun, 27 Feb 2011 06:02:05 -0500
Message-ID: <20110227110205.GE9763@canuck.infradead.org>
References: <20110225.112019.48513284.davem@davemloft.net>
 <20110226005718.GA19889@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:53039 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751925Ab1B0LCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Feb 2011 06:02:16 -0500
Content-Disposition: inline
In-Reply-To: <20110226005718.GA19889@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 26, 2011 at 08:57:18AM +0800, Herbert Xu wrote:
> I'm fairly certain the bottleneck is indeed in the kernel, and
> in the UDP stack in particular.
> 
> This is born out by a test where I used two named worker threads,
> both working on the same socket.  Stracing shows that they're
> working flat out only doing sendmsg/recvmsg.
> 
> The result was that they obtained (in aggregate) half the throughput
> of a single worker thread.

I agree. This is the bottleneck that I described were the kernel is
not able to deliver enough queries for BIND to show the lock
contention issues.

But there is also the situation where netperf RR performance numbers
indicate a mugh higher kernel capability but BIND is not able to
deliver more even though the CPU utilization is very low. This is
the situation where we see the large number of futex calls indicating
the lock contention due to too many queries on a single socket.

> Which is why I'm quite skeptical about this REUSEPORT patch as
> IMHO the only reason it produces a great result is solely because
> it is allowing parallel sends going out.
> 
> Rather than modifying all UDP applications out there to fix what
> is fundamentally a kernel problem, I think what we should do is
> fix the UDP stack so that it actually scales.

I am not suggesting that this is the ultimate and final fix for this
problem. It is fixing a symptom rather than fixing the cause but
sometimes being able to fix the symptom becomes really handy :-)

Adding SO_REUSEPORT does not prevent us from fixing the UDP stack
in the long run.

> It isn't all that hard since the easy way would be to only take
> the lock if we're already corked or about to cork.
> 
> For the receive side we also don't need REUSEPORT as we can simply
> make our UDP stack multiqueue.

OK, it is not required and there is definitely a better way to fix
the kernel bottleneck in the long term. Even better.

I still suggest to merge this patch as a immediate workaround fix
until we scale properly on a single socket and also as a workaround
for applications which can't get rid of their per socket mutex quickly.
