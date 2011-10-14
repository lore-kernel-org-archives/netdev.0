From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] tcp: reduce memory needs of out of order queue
Date: Fri, 14 Oct 2011 08:50:23 -0700
Message-ID: <4E985A3F.5080103@hp.com>
References: <1318576791.2533.99.camel@edumazet-laptop> <20111014.034224.1197576516015404466.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:31586 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751703Ab1JNPu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 11:50:26 -0400
In-Reply-To: <20111014.034224.1197576516015404466.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/14/2011 12:42 AM, David Miller wrote:

> No objection from me, although I wish wireless drivers were able to
> size their SKBs more appropriately.  I wonder how many problems that
> look like "OMG we gotz da Buffer Bloat, arrr!" are actually due to
> this truesize issue.

I think the buffer bloat folks are looking at latency through transmit 
queues - now perhaps some of their latency is really coming from 
retransmissions thanks to packets being dropped thanks to overfilling 
socket buffers, but I'm pretty sure they are clever enough to look for that.

> I think such large truesize SKBs will cause problems even in non loss
> situations, in that the receive buffer will hit it's limits more
> quickly.  I not sure that the receive buffer autotuning is built to
> handle this sort of scenerio as a common occurance.

I believe that may be the case - at least during something like:

netperf -t TCP_RR -H <host> -l 30 -- -b 256 -D

which on an otherwise quiet test setup will report a non-trivial number 
of retransmissions - either via looking at netstat -s output, or by 
adding local_transport_retrans,remote_transport_retrans to an output 
selector for netperf (eg -o 
throughput,burst_size,local_transport_retrans,remote_transport_retrans,lss_size_end,rsr_size_end)

(I plan on providing more data after a laptop has gone through some 
upgrades)

> You might want to check if this is the actual root cause of your
> problems.  If the receive buffer autotuning doesn't expand the receive
> buffer enough to hold two windows worth of these large truesize SKBs,
> that's the real reason why we end up pruning.
>
> We have to decide if these kinds of SKBs are acceptable as a normal
> situation for MSS sized frames.  And if they are then it's probably
> a good idea to adjust the receive buffer autotuning code too.
>
> Although I realize it might be difficult, getting rid of these weird
> SKBs in the first place would be ideal.

That means a semi-arbitrary alloc/copy in drivers, even when/if the 
wasted space isn't going to be a problem no?  That TCP_RR test above 
would run "just fine" if the burst size was much smaller, but if there 
was an arbitrary allocate/copy it would take a service demand and thus 
transaction rate hit.

> It would also be a good idea to put the truesize inaccuracies into
> perspective when selecting how to fix this.  It's trying to prevent
> 1 byte packets not accounting for the 256 byte SKB and metadata.
> That kind of case with such a high ratio of wastage is important.
>
> On the other hand, using 2048 bytes for a 1500 byte packet and claiming
> the truesize is 1500 + sizeof(metadata)... that might be an acceptable
> lie to tell :-)  This is especially true if it allows an easy solution
> to this wireless problem.

Is the wireless problem strictly a wireless problem?  Many of the 
drivers where Eric has been fixing the truesize accounting have been 
wired devices no?

rick jones
