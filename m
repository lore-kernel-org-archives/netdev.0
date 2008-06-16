From: "Gregory Haskins" <ghaskins@novell.com>
Subject: Re: [PATCH] net/core/sock.c remove extra wakeup
Date: Sun, 15 Jun 2008 21:48:12 -0600
Message-ID: <4855AA3C.BA47.005A.0@novell.com>
References: <483F990C0200005A00038001@sinclair.provo.novell.com>
 <E1K6K60-00061s-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, "Patrick Mullaney" <PMullaney@novell.com>,
	<netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sinclair.provo.novell.com ([137.65.248.137]:10230 "EHLO
	sinclair.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752170AbYFPDsD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2008 23:48:03 -0400
In-Reply-To: <E1K6K60-00061s-00@gondolin.me.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On Wed, Jun 11, 2008 at  2:46 AM, in message
<E1K6K60-00061s-00@gondolin.me.apana.org.au>, Herbert Xu
<herbert@gondor.apana.org.au> wrote: 
> Gregory Haskins <GHaskins@novell.com> wrote:
>> 
>> So basically it was waiting for a packet to arrive, and the net-rx softirq 
> would first trigger a NOSPACE wakeup (of which was a noop by the udp-rx code) 
> followed by an rx-wakeup.  So the netperf thread woke twice for one packet.  
> Fixing this boosted performance by a large margin (don't recall exact figures 
> off the top of my head....somewhere around 20%)
> 
> Please wrap your lines.

Apologies.  I don't think I have control over it in my corporate mailer environment :( but if I can figure out a way to do it I will make this change.  You are not the first to complain ;)

> 
> Anyway, you've lost me with this scenario.  The patch is stopping
> wake-ups on the write path yet you're talking about the read path.
> So my question is why are you getting the extra wake-up on that
> write path when you receive a packet?

Heh..you tell me :)

I don't recall the specifics off the top of my head, but IIRC it had to do with the fact that we were running a tx/rx netperf test and the way tx-completions are handled in the stack w.r.t. the softirqs.

The tx-completions code is executing inside the softirq-net-rx context and is freeing up the transmitted skbs.  The problem is that it is blindly signaling the wait-queue that there was now SPACE (even though no-one cared about that event at the moment...the only waiter was waiting on an rx event).

So one way to look at it is the problem is that the single wait-queue serves both rx-wakeup, and tx-nospace events.  Rather than open the can of worms of splitting the wait-queues into finer granularity,  Pat chose to at least make the overloaded use of the single wait-queue more intelligent to know if anyone cared about the NOSPACE event or not.

>From my perspective, I don't care how the issue is specifically solved...I would ultimately just like to see this wasted wake-up "go away" one way or the other.  ;)  It significantly degrades performance (at least in this synthetic test) and as far as I can tell there is no reason to structure the code this way.  If we are mistaken in that assessment, please let me know.

If we can offer any more details (such as the specific codepath that triggers the NOSPACE wakeup, for instance) we would be happy to oblige.  Long story short this is easily repeatable.

Regards,
-Greg

