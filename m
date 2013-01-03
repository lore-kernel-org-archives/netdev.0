From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH net-next] softirq: reduce latencies
Date: Thu, 3 Jan 2013 12:46:08 -0800
Message-ID: <20130103124608.136fd65b.akpm@linux-foundation.org>
References: <1357216132.21409.24107.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1357216132.21409.24107.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 03 Jan 2013 04:28:52 -0800
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> In various network workloads, __do_softirq() latencies can be up
> to 20 ms if HZ=1000, and 200 ms if HZ=100.
> 
> This is because we iterate 10 times in the softirq dispatcher,
> and some actions can consume a lot of cycles.

hm, where did that "20 ms" come from?  What caused it?  Is it simply
the case that you happened to have actions which consume 2ms if HZ=1000
and 20ms if HZ=100?

> This patch changes the fallback to ksoftirqd condition to :
> 
> - A time limit of 2 ms.
> - need_resched() being set on current task
>
> When one of this condition is met, we wakeup ksoftirqd for further
> softirq processing if we still have pending softirqs.

Do we need both tests?  The need_resched() test alone might be
sufficient?


With this change, there is a possibility that a rapidly-rescheduling
task will cause softirq starvation?


Can this change cause worsened latencies in some situations?  Say there
are a large number of short-running actions queued.  Presently we'll
dispatch ten of them and return.  With this change we'll dispatch many
more of them - however many consume 2ms.  So worst-case latency
increases from "10 * not-much" to "2 ms".
