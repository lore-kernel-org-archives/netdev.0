From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] rps: overflow prevention for saturated cpus
Date: Thu, 06 Dec 2012 15:45:38 -0800
Message-ID: <50C12E22.3030206@hp.com>
References: <1354826194-9289-1-git-send-email-willemb@google.com> <50C11B4D.4040109@hp.com> <CA+FuTSc=-TE4X=VWmdXMLhE_jn6CtjUpauznt4evrRLi-DOd2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <therbert@google.com>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:14554 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751401Ab2LFXpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 18:45:42 -0500
In-Reply-To: <CA+FuTSc=-TE4X=VWmdXMLhE_jn6CtjUpauznt4evrRLi-DOd2g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/2012 03:04 PM, Willem de Bruijn wrote:
> On Thu, Dec 6, 2012 at 5:25 PM, Rick Jones <rick.jones2@hp.com> wrote:
>> I thought (one of) the ideas behind RFS at least was to give the CPU
>> scheduler control over where network processing took place instead of it
>> being dictated solely by the addressing. I would have expected the CPU
>> scheduler to migrate some work off the saturated CPU.  Or will this only
>> affect RPS and not RFS?
>
> I wrote it with RPS in mind, indeed. With RFS, for sufficiently
> multithreaded applications that are unpinned, the scheduler will
> likely spread the threads across as many cpus as possible. In that
> case, the mechanism will not kick in, or as quickly. Even with RFS,
> pinned threads and single-threaded applications will likely also
> benefit during high load from redirecting kernel receive
> processing away from the cpu that runs the application thread. I
> haven't tested that case independently.

Unless that single-threaded application (or single receiving thread) is 
pinned to a CPU, isn't there a non-trivial chance that incoming traffic 
flowing up different CPUs will cause it to be bounced from one CPU to 
another, taking its cache lines with it and not just the "intra-stack" 
cache lines?

Long (?) ago and far away it was possible to say that a given IRQ should 
be potentially serviced by more than one CPU (if I recall though not 
phrase correctly).  Didn't that get taken away because it did such nasty 
things like reordering and such?  (Admittedly, I'm really stretching the 
limits of my dimm memory there)

>> What kind of workload is this targeting that calls for
>> such intra-flow parallelism?
>
> Packet processing middeboxes that rather operate in degraded mode
> (reordering) than drop packets. Intrusion detection systems and proxies,
> for instance. These boxes are actually likely to have RPS enabled and
> RFS disabled.
>
>> With respect to the examples given, what happens when it is TCP traffic
>> rather than UDP?
>
> That should be identical. RFS is supported for both protocols. In the
> test, it is turned off to demonstrate the effect solely with RPS.

Will it be identical with TCP?  If anything, I would think causing 
reordering of the TCP segments within flows would only further increase 
the workload of the middlebox because it will increase the ACK rates. 
Perhaps quite significantly if GRO was effective at the receivers before 
the reordering started.

At least unless/until the reordering is bad enough to cause the sending 
TCPs to fast retransmit and so throttle back.  And unless we are talking 
about being overloaded by massive herds of "mice" I'd think that the TCP 
flows would be throttling back to what the single CPU in the middlebox 
could handle.

rick
