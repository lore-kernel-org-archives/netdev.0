From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Tue, 10 May 2016 22:46:19 +0200
Message-ID: <90f3db8c-c30c-b204-576a-454939ac93ce@stressinduktion.org>
References: <cover.1462886866.git.pabeni@redhat.com>
 <1462890590.23934.68.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Tom Herbert <tom@herbertland.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Paolo Abeni <pabeni@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462890590.23934.68.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On 10.05.2016 16:29, Eric Dumazet wrote:
> On Tue, 2016-05-10 at 16:11 +0200, Paolo Abeni wrote:
>> Currently, the softirq loop can be scheduled both inside the ksofirqd kernel
>> thread and inside any running process. This makes nearly impossible for the
>> process scheduler to balance in a fair way the amount of time that
>> a given core spends performing the softirq loop.
>>
>> Under high network load, the softirq loop can take nearly 100% of a given CPU,
>> leaving very little time for use space processing. On single core hosts, this
>> means that the user space can nearly starve; for example super_netperf
>> UDP_STREAM tests towards a remote single core vCPU guest[1] can measure an
>> aggregated throughput of a few thousands pps, and the same behavior can be
>> reproduced even on bare-metal, eventually simulating a single core with taskset
>> and/or sysfs configuration.
> 
> I hate these patches and ideas guys, sorry. That is before my breakfast,
> but still...

:)

> I have enough hard time dealing with loads where ksoftirqd has to
> compete with user threads that thought that playing with priorities was
> a nice idea.

We tried a lot of approaches so far and this seemed to be the best
architectural RFC we could post. I was quite surprised to see such good
performance numbers with threaded NAPI, thus I think it could be a way
forward.

Your mentioned problem above seems to be a configuration mistake, no?
Otherwise isn't that something user space/cgroups might solve?

> Guess what, when they lose networking they complain.
> 
> We already have ksoftirqd to normally cope with the case you are
> describing.

Indeed, but the time until we wake up ksoftirqd can be already quite
long and for every packet we get in udp_recvmsg the local_bh_enable call
let's us pick up quite a lot of new packets, which we drop before user
space can make any progress. By being more fair between user space and
"napid" we hoped to solve this. We also want more feedback from the
scheduler people, so we Cc'ed them also.

> If it is not working as intended, please identify the bugs and fix them,
> instead of adding yet another tests in fast path and extra complexity in
> the stack.

We could use _local_bh_enable instead of local_bh_enable in udp_recvmsg,
which certainly wouldn't branch down to softirqs as often, but this
feels wrong to me and certainly is.

After the discussion on netdev@ with Peter Hurley here [1] about
"Softirq priority inversion from "softirq: reduce latencies"", we didn't
want to propose some patch looking like this again, but this could help.
The idea would be to limit the number we recheck for softirqs but give
back control to user space.

[1] https://lkml.org/lkml/2016/2/27/152

If I remember local_bh_enable in kernel-rt processes one softirq
directly and defers its work to ksoftirqd much more quickly.

> In the one vcpu case, allowing the user thread to consume more UDP
> packets from the target UDP socket will also make your NIC drop more
> packets, that are not necessarily packets for the same socket.
> 
> So you are shifting the attack to a different target,
> at the expense of more kernel bloat.

I agree here, but I don't think this patch particularly is a lot of
bloat and something very interesting people can play with and extend upon.

Thanks,
Hannes
