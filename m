From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: route cache DoS testing and softirqs
Date: Tue, 30 Mar 2004 22:47:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040330204731.GG3808@dualathlon.random>
References: <20040329184550.GA4540@in.ibm.com> <20040329222926.GF3808@dualathlon.random> <20040330144324.GA3778@in.ibm.com> <20040330195315.GB3773@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        Robert Olsson <Robert.Olsson@data.slu.se>,
        "Paul E. McKenney" <paulmck@us.ibm.com>,
        Dave Miller <davem@redhat.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Dipankar Sarma <dipankar@in.ibm.com>
Content-Disposition: inline
In-Reply-To: <20040330195315.GB3773@in.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 31, 2004 at 01:23:15AM +0530, Dipankar Sarma wrote:
> It doesn't look as if we are processing much from ksoftirqd at
> all in this case. I did the following instrumentation -
> 
>         if (in_interrupt() && local_softirqd_running())
>                 return;
>         max_restart = MAX_SOFTIRQ_RESTART;
>         local_irq_save(flags);
> 
>         if (rcu_trace) {
>                 int cpu = smp_processor_id();
>                 per_cpu(softirq_count, cpu)++;
>                 if (local_softirqd_running() && current == __get_cpu_var(ksoftirqd))
>                         per_cpu(ksoftirqd_count, cpu)++;
>                 else if (!in_interrupt())
>                         per_cpu(other_softirq_count, cpu)++;
>         }
>         pending = local_softirq_pending();
> 
> A look at the softirq_count, ksoftirqd_count and other_softirq_count shows -
> 
> CPU 0 : 638240	554	637686
> CPU 1 : 102316 	1 	102315
> CPU 2 : 675696 	557 	675139
> CPU 3 : 102305 	0 	102305
> 
> So, it doesn't seem supprising that your ksoftirqd offloading didn't
> really help much. The softirq frequency and grace period graph
> looks pretty much same without that patch -
> 
> http://lse.sourceforge.net/locking/rcu/rtcache/pktgen/andrea/cpu-softirq.png
> 
> We are simply calling do_softirq() too much it seems and not letting
> other things run on the system. Perhaps we need to look at real
> throttling of softirqs ?
> 

I see what's going on now, yes my patch cannot help. the workload is
simply generating too much hardirq load, and it's like if we don't use
softirq at all but that we process the packet inside the hardirq for
this matter. As far as RCU is concerned it's like if there a no softirq
at all but that we process everything in the hardirq.

so what you're looking after is a new feature then:

1) rate limit the hardirqs
2) rate limit only part of the irq load (i.e. the softirq, that's handy
   since it's already splitted out) to scheduler-aware context (not
   inside irq context anymore)
3) stop processing packets in irqs in the first place (NAPI or similar)

however I start to think they can be all wrong, and that rcu is simply
not suitable for purerely irq usages like this. w/o rcu there would be
no need of the scheduler keeping up with the irq load, and in some usage
I can imagine that it is a feature to prioritize heavily on the
irq load vs scheduler-aware context.
