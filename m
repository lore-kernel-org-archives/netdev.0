From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] rfs: Receive Flow Steering
Date: Fri, 02 Apr 2010 11:25:01 -0700
Message-ID: <4BB6367D.9090600@hp.com>
References: <alpine.DEB.1.00.1004012045560.4252@pokey.mtv.corp.google.com>	<j2u412e6f7f1004012204r76dd8ccbg2e6e78d46541b85@mail.gmail.com>	<1270193393.1936.52.camel@edumazet-laptop> <4BB622F6.10606@hp.com> <g2i65634d661004021045uff7c0e25ge7dfd17929bc9ee9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Changli Gao <xiaosuo@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0185.atlanta.hp.com ([15.193.32.62]:14374 "EHLO
	g6t0185.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752643Ab0DBSfG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 14:35:06 -0400
In-Reply-To: <g2i65634d661004021045uff7c0e25ge7dfd17929bc9ee9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert wrote:
> 
> 
> On Fri, Apr 2, 2010 at 10:01 AM, Rick Jones <rick.jones2@hp.com 
> <mailto:rick.jones2@hp.com>> wrote:
> 
>     Eric Dumazet wrote:
> 
> 
>         Your claim of RPS being not good for applications is wrong, our test
>         results show an improvement as is. Maybe your applications dont
>         scale,
>         because of bad habits, or collidings heuristics, I dont know.
> 
> 
>     The progression in HP-UX was IPS (10.20) (aka RPS) then TOPS (11.0)
>     (aka RFS). We found that IPS was great for
>     single-flow-per-thread-of-execution stuff and that TOPS was better
>     for multiple-flow-per-thread-of-execution stuff.  It was long enough
>     ago now that I can safely say for one system-level benchmark not
>     known to be a "networking" benchmark, and without a massive kernel
>     component, TOPS was a 10% win.  Not too shabby.
> 
>     It wasn't that IPS wasn't good in its context - just that TOPS was
>     even better.
> 
> I would assume that with IPS threads would migrate to where packets were 
> being delivered thus giving the same sort of locality TOPS was 
> providing?  That would work great without any other constraints 
> (multiple flows per thread, thread CPU bindings, etc.).

Well... that depended - at the time, and still, we were and are also encouraging 
users and app designers to make copious use of processor/locality affinity (SMP 
and NUMA going back far longer in the RISC et al space than the x86 space).  So, 
it was and is entirely possible that the application thread of execution is 
hard-bound to a specific core/locality.  Also, I do not recall if HP-UX was as 
aggressive about waking a process/thread on the processor from which the wake-up 
came vs on the processor on which it last ran.

>     We also preferred the concept of the scheduler giving networking
>     clues as to where to process an application's packets rather than
>     networking trying to tell the scheduler.  There was some discussion
>     of out of order worries, but we were willing to trust to the basic
>     soundness of the scheduler - if it was moving threads around willy
>     nilly at a rate able to cause big packet reordering it had
>     fundamental problems that would have to be addressed anyway.
> 
> 
> I also think scheduler leading networking, like in RPS,  is generally 
> more scalable.  As for OOO packets, I've spent way to much time trying 
> to convince the bean-counters that a small number of them aren't 
> problematic :-), in the end it's just easier to not introduce new 
> mechanisms that will cause them!

So long as it doesn't drive you to produce new mechanisms heavier than they 
would have otherwise been.

The irony in the case of HP-UX IPS was that it was put in place in response to 
the severe out of order packet problems in HP-UX in 10.X before 10.20 - there 
were multiple netisr processes and only one netisr queue.  The other little 
tweak that came along in 10.20 with IPS, was inaddition to having a per 
processor (well, per core in today's parlance) netisr queue, the netisr would 
grab the entire queue under the one spinlock and work off of that.  That was 
nice because the code path became more efficient under load - more packets 
processed per spinlock/unlock pair.

happy benchmarking,

rick jones
