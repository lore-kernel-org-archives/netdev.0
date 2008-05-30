From: "Patrick Mullaney" <pmullaney@novell.com>
Subject: Re: [PATCH] net/core/sock.c remove extra wakeup
Date: Fri, 30 May 2008 11:00:49 -0600
Message-ID: <483FDE61020000C7000389F6@lucius.provo.novell.com>
References: <483F99090200005A00037FFE@lucius.provo.novell.com>
 <483F990C0200005A00038001@lucius.provo.novell.com>
 <483FDE61020000C7000389F6@lucius.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Gregory Haskins" <GHaskins@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lucius.provo.novell.com ([137.65.248.127]:8938 "EHLO
	lucius.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752084AbYE3RAy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2008 13:00:54 -0400
In-Reply-To: <483FDE61020000C7000389F6@lucius.provo.novell.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not sure if Greg's post made it to the list but I would like to
build on what he said(for those who didn't see it - see below).

Point taken on the potential for a race, it was considered - I wanted to
get feedback from the list to see if it was an issue. There is a
somewhat similar looking piece of code in stream.c that clears this
bit as well in a similar spot(sk_stream_write_space). Perhaps this is
because stream apps must have a single thread per socket and this
is not necessarily the case with datagram apps?

The wakeup is expensive because it is completely unnecessary - the
thread being woke has nothing to do. If this is a high priority thread,
which is part of the reason I mentioned that we are testing on a
PREEMPT_RT enabled kernel, this will cause undue jitter and degrading
of performance(as Greg mentioned we are seeing a 20% degradation in
loaded situations). Even in the case where it is sched_other, we see
significant degradation.

Would a better approach be?

1) clear the bit when the waiter returns(bottom of sock_wait_for_wmem)
2) add a new wait-queue to the socket to separate the writers
3) another idea?

I'm having a hard time understanding the use of the NOSPACE flag in
sock.c. It seems like it currently gets set but never gets cleared. I
must be missing something.

Thanks.
Pat

On Fri, 2008-05-30 at 10:05 +0000, Gregory Haskins wrote:
> Sorry for the top post (on a phone)
> 
> Point taken that the fix needs to be analysed for races, but the problem is very real.
>   We noticed that our udp netperf test would get two wake-ups per packet.
>   I don't remember the exact path where the udp waits occur off the top of my head,
>  but the fundamental problem is the overloaded use of the single wait-queue.
> 
> So basically it was waiting for a packet to arrive, and the net-rx softirq would first trigger
>  a NOSPACE wakeup (of which was a noop by the udp-rx code) followed by an rx-wakeup.
>   So the netperf thread woke twice for one packet.  Fixing this boosted performance by a large
>  margin (don't recall exact figures off the top of my head....somewhere around 20%)
> 
> Long stort short, its potentially worth fixing this, even if this patch isn't "it" :)
> 
> HTH
> 
> Regards
> -Greg  
>  
> -----Original Message-----
> From: David Miller <davem@davemloft.net>
> To: Patrick Mullaney <PMullaney@novell.com>
> Cc: Gregory Haskins <GHaskins@novell.com>
> Cc:  <netdev@vger.kernel.org>
> 
> Sent: 5/30/2008 3:52:54 AM
> Subject: Re: [PATCH] net/core/sock.c remove extra wakeup
> 
> From: "Patrick Mullaney" <pmullaney@novell.com>
> Date: Thu, 29 May 2008 10:08:43 -0600
> 
> > We have noticed an extra wakeup of a task waiting on a udp receive
> > while testing with CONFIG_PREEMPT_RT. The following patch
> > eliminates the source of the extra wakeup by only waking a task
> > if it is waiting on the writable condition(the SOCK_NOSPACE
> > bit has been set). The patch is against 2.6.25.
> > 
> > Signed-off-by: Patrick Mullaney <pmullaney@novell.com>
> 
> This looks Ok on the surface, but I'm really worried about
> races.
> 
> If you clear that bit, another thread which set that bit
> and already checked the socket space, might sleep and never
> wake up.
> 
> I think that is fundamentally why we don't try to optimize
> this in that way.
> 
> And why is this so expensive?  Once the first wakeup occurs,
> the subsequent attemps will merely see that the wait queue
> is empty and do nothing.
> 
> The only cost is the read lock on the callback lock, and that
> is about as expensive as this new atomic operation you are
> adding to clear the SOCK_NOSPACE bit.
> 
> So the benefit is not clear, and neither is the correctness of
> this change.
> 
> Sorry.

