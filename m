From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH RFC 0/2] net: Iterate over cpu_present_mask during
 calculation of percpu statistics
Date: Tue, 30 Aug 2016 08:55:13 +0200
Message-ID: <20160830065513.GY10153@twins.programming.kicks-ass.net>
References: <147249730528.18175.4772805024092024580.stgit@pro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        yoshfuji@linux-ipv6.org, jmorris@namei.org, davem@davemloft.net,
        edumazet@google.com, mingo@redhat.com, kaber@trash.net
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <147249730528.18175.4772805024092024580.stgit@pro>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 29, 2016 at 10:03:48PM +0300, Kirill Tkhai wrote:
> Many variables of statistics type are made percpu in kernel. This allows
> to do not make them atomic or to do not use synchronization. The result
> value is calculated as sum of values on every possible cpu.
> 
> The problem is this scales bad. The calculations may took a lot of time.
> For example, some machine configurations have many possible cpus like below:
> 
> "smpboot: Allowing 192 CPUs, 160 hotplug CPUs"
> 
> There are only 32 real cpus, but 192 possible cpus.

This is fairly rare AFAIK. Its typically only found on machines with
empty sockets (rare, because empty sockets are expensive) or broken
BIOSes (I have one of the latter).

I've cured things by adding "possible_cpus=40" to the cmdline.

> I had a report about very slow getifaddrs() on older kernel, when there are
> possible only 590 getifaddrs calls/second on Xeon(R) CPU E5-2667 v3 @ 3.20GHz.
> 
> The patchset aims to begin solving of this problem. It makes possible to
> iterate over present cpus mask instead of possible. When cpu is going down,
> a statistics is being moved to an alive cpu. It's made in CPU_DYING callback,
> which happens when machine is stopped. So, iteration  over present cpus mask
> is safe under preemption disabled.
> 
> Patchset could exclude even offline cpus, but I didn't do that, because
> the main problem seems to be possible cpus. Also, this would require to
> do some changes in kernel/cpu.c, so I'd like to hear people opinion about
> expediency of this before.
> 
> One more question is whether the whole kernel needs the same possibility
> and the patchset should be more generic.

I'd vote for no. This isn't a fundamental optimization, the thing is
still O(n), we just reduced the n for one particular
machine.

[ and note that that machine is still wasting an enormous amount of
memory actually _having_ all that per-cpu storage, which too is gone
with the cmdline 'fix' ]

On machines which really have 192 (or more) CPUs, this will still be as
slow as ever.
