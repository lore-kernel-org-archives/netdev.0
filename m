From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Thu, 27 Jul 2006 20:51:22 +0400
Message-ID: <20060727165121.GA6637@2ka.mipt.ru>
References: <20060718081625.GA13830@2ka.mipt.ru> <20060718230121.GA31474@ms2.inr.ac.ru> <1153966671.6904.71.camel@localhost.localdomain> <20060726.221708.123400049.davem@davemloft.net> <1153979173.6904.100.camel@localhost.localdomain> <20060727163335.GA12944@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:43678 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751753AbWG0Qvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2006 12:51:46 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20060727163335.GA12944@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Alexey.

On Thu, Jul 27, 2006 at 08:33:35PM +0400, Alexey Kuznetsov (kuznet@ms2.inr.ac.ru) wrote:
> First, it was stated that suggested implementation performs better and even
> much better. I am asking why do we see such improvement?
> I am absolutely not satisifed with statement "It is better. Period."
> From all that I see, this particular implementation does not implement
> optimizations suggested by VJ, it implements only the things,
> which are not supposed to affect performance or to affect it negatively.

Just for clarifications: I showed that even using _existing_ stack
(using sk_backlog_rcv) performance in process context can exceed two
level processing. And after creating own TCP implemetation 
(which does not include two-level related overhead among other things)
performance different was even higher. I can agree that it is possible
that in second case part of the gain is obtained from the new TCP
implementation, but not 100% from process' context, but in first place 
existing socket code was used.

> > userspace), no dequeue lock is required.
> 
> And that was a part of the second question.
> 
> I do not see, how single threaded TCP is possible. In receiver path
> it has to ack with quite strict time bounds, to delack etc., in sender path
> it has to slow start, I am even not saying about "slow path" things:
> retransmit, probing window, lingering without process context etc.
> It looks like, VJ implies the protocol must be changed. We can't, we mustn't.
> 
> After we deidealize this idealization and recognize that some "slow path"
> should exist and some part of this "slow path" has to be executed
> with higher priority than the "fast" one, where do we arrive?
> Is not it exactly what we have right now? Clean fast path, separate slow path.
> Not good enough? Where? Let's find and fix this.

Slow path does exist, retransmits and friends are there too in new stack.
And my initial netchannel implementation used  _existing_ socket code
from process context. Again, there is no need to crate two levels
between fast and slow or softirq and process, and it was proven and
shown that it can perform faster.

Why don't you want to see, that existing model is just path enlargement:
there might also exist delayes between hard and soft irqs, so acks will
be delayed and so on... But stack works without problems even if some
kernel thread takes 100% cpu (with preemption), and there are very big
delays for ack generations, but userspace is not possible to get that
data. With netchannels it is essentially the same (heh, I said that
already a lot of times).

> Alexey

-- 
	Evgeniy Polyakov
