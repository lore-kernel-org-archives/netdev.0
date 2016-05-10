From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Tue, 10 May 2016 07:29:50 -0700
Message-ID: <1462890590.23934.68.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1462886866.git.pabeni@redhat.com>
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
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1462886866.git.pabeni@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-05-10 at 16:11 +0200, Paolo Abeni wrote:
> Currently, the softirq loop can be scheduled both inside the ksofirqd kernel
> thread and inside any running process. This makes nearly impossible for the
> process scheduler to balance in a fair way the amount of time that
> a given core spends performing the softirq loop.
> 
> Under high network load, the softirq loop can take nearly 100% of a given CPU,
> leaving very little time for use space processing. On single core hosts, this
> means that the user space can nearly starve; for example super_netperf
> UDP_STREAM tests towards a remote single core vCPU guest[1] can measure an
> aggregated throughput of a few thousands pps, and the same behavior can be
> reproduced even on bare-metal, eventually simulating a single core with taskset
> and/or sysfs configuration.

I hate these patches and ideas guys, sorry. That is before my breakfast,
but still...

I have enough hard time dealing with loads where ksoftirqd has to
compete with user threads that thought that playing with priorities was
a nice idea.

Guess what, when they lose networking they complain.

We already have ksoftirqd to normally cope with the case you are
describing.

If it is not working as intended, please identify the bugs and fix them,
instead of adding yet another tests in fast path and extra complexity in
the stack.

In the one vcpu case, allowing the user thread to consume more UDP
packets from the target UDP socket will also make your NIC drop more
packets, that are not necessarily packets for the same socket.

So you are shifting the attack to a different target,
at the expense of more kernel bloat.
