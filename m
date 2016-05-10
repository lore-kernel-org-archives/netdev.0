From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Tue, 10 May 2016 18:03:50 +0200
Message-ID: <1462896230.6687.74.camel@redhat.com>
References: <cover.1462886866.git.pabeni@redhat.com>
	 <1462890590.23934.68.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
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
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462890590.23934.68.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Tue, 2016-05-10 at 07:29 -0700, Eric Dumazet wrote:
> On Tue, 2016-05-10 at 16:11 +0200, Paolo Abeni wrote:
> > Currently, the softirq loop can be scheduled both inside the ksofirqd kernel
> > thread and inside any running process. This makes nearly impossible for the
> > process scheduler to balance in a fair way the amount of time that
> > a given core spends performing the softirq loop.
> > 
> > Under high network load, the softirq loop can take nearly 100% of a given CPU,
> > leaving very little time for use space processing. On single core hosts, this
> > means that the user space can nearly starve; for example super_netperf
> > UDP_STREAM tests towards a remote single core vCPU guest[1] can measure an
> > aggregated throughput of a few thousands pps, and the same behavior can be
> > reproduced even on bare-metal, eventually simulating a single core with taskset
> > and/or sysfs configuration.
> 
> I hate these patches and ideas guys, sorry. That is before my breakfast,
> but still...

I'm sorry, I did not meant to spoil your breakfast ;-)

> I have enough hard time dealing with loads where ksoftirqd has to
> compete with user threads that thought that playing with priorities was
> a nice idea.

I fear there is a misunderstanding. I'm not suggesting to fiddle with
priorities; the above 'taskset' reference was just an hint to replicate
the starvation issue on bare-metal in the lack of a single core host.

> 
> Guess what, when they lose networking they complain.
> 
> We already have ksoftirqd to normally cope with the case you are
> describing.
> 
> If it is not working as intended, please identify the bugs and fix them,
> instead of adding yet another tests in fast path and extra complexity in
> the stack.

The idea it exactly that: the problem is how the softirq loop is
scheduled and executed, i.e. the current ksoftirqd/"inline loop" model. 

If a single core host is under network flood, i.e. ksoftirqd is
scheduled and it eventually (after processing ~640 packets) will let the
user space process run. The latter will execute a syscall to receive a
packet, which will have to disable/enable bh at least once and that will
cause the processing of another ~640 packets. To receive a single packet
in user space, the kernel has to process more than one thousand packets.

AFAICS it can't be solved without changing how the net_rx_action is
served.

The user space starvation issue don't affect large server, but AFAIK
many small devices have a lot of out-of-tree hacks to cope with this
sort of issues.

In the VM scenario, the starvation issue was not a real concern up to a
little time ago because the vhost/tun device was not able to push
packets fast enough into the guest to trigger the issue. Recent
improvements have changed the situation.

Also, the scheduler's ability to migrate the napi threads is quite
beneficial for hypervisor when the VMs are receiving a lot of network
traffic. 
Please have a look at the performance numbers.

The current patch adds a single, simple, test per napi_schedule
invocation, and with minimal changes, the kernel won't access any
additional cache-line when the napi thread is disabled. Even in the
current form, in my tests no regression is seen with the patched kernel
when the napi thread mode is disabled.

> In the one vcpu case, allowing the user thread to consume more UDP
> packets from the target UDP socket will also make your NIC drop more
> packets, that are not necessarily packets for the same socket.

That is true. But the threaded napi will not starve, i.e. the forwarding
process, to a nearly zero packet rate, while with the current code the
reverse scenario can happen. 

Cheers,

Paolo

> 
> So you are shifting the attack to a different target,
> at the expense of more kernel bloat.
> 
> 
> 
