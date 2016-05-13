From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Fri, 13 May 2016 19:19:00 +0200
Message-ID: <1463159940.11721.37.camel@redhat.com>
References: <cover.1462886866.git.pabeni@redhat.com>
	 <1462890590.23934.68.camel@edumazet-glaptop3.roam.corp.google.com>
	 <90f3db8c-c30c-b204-576a-454939ac93ce@stressinduktion.org>
	 <CANn89i+YKrVOgfFwW-2psfCzq5_YLdmbV06-H-1FCOwXdMBuzQ@mail.gmail.com>
	 <94f323a9-515e-4d75-cac8-ef0214f0499e@stressinduktion.org>
	 <1462920697.23934.113.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160511065527.GD3193@twins.programming.kicks-ass.net>
	 <1463003804.23934.154.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1463158203.11721.25.camel@redhat.com>
	 <CANn89iLxx-K6XDgU=c+6S1ExtSoCqQyG+7XjzJW+xoL3ACJYuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Tom Herbert <tom@herbertland.com>,
	Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANn89iLxx-K6XDgU=c+6S1ExtSoCqQyG+7XjzJW+xoL3ACJYuQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-05-13 at 10:03 -0700, Eric Dumazet wrote:
> On Fri, May 13, 2016 at 9:50 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> 
> >> Indeed, and the patch looks quite simple now ;)
> >>
> >> diff --git a/kernel/softirq.c b/kernel/softirq.c
> >> index 17caf4b63342d7839528f367b283a386413b0362..23c364485d03618773c385d943c0ef39f5931d09 100644
> >> --- a/kernel/softirq.c
> >> +++ b/kernel/softirq.c
> >> @@ -57,6 +57,11 @@ static struct softirq_action softirq_vec[NR_SOFTIRQS] __cacheline_aligned_in_smp
> >>
> >>  DEFINE_PER_CPU(struct task_struct *, ksoftirqd);
> >>
> >> +static inline bool ksoftirqd_running(void)
> >> +{
> >> +     return __this_cpu_read(ksoftirqd)->state == TASK_RUNNING;
> >> +}
> >> +
> >>  const char * const softirq_to_name[NR_SOFTIRQS] = {
> >>       "HI", "TIMER", "NET_TX", "NET_RX", "BLOCK", "BLOCK_IOPOLL",
> >>       "TASKLET", "SCHED", "HRTIMER", "RCU"
> >> @@ -313,7 +318,7 @@ asmlinkage __visible void do_softirq(void)
> >>
> >>       pending = local_softirq_pending();
> >>
> >> -     if (pending)
> >> +     if (pending && !ksoftirqd_running())
> >>               do_softirq_own_stack();
> >>
> >>       local_irq_restore(flags);
> >> @@ -340,6 +345,9 @@ void irq_enter(void)
> >>
> >>  static inline void invoke_softirq(void)
> >>  {
> >> +     if (ksoftirqd_running())
> >> +             return;
> >> +
> >>       if (!force_irqthreads) {
> >>  #ifdef CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK
> >>               /*
> >
> > In this version of the path, the chunk affecting __local_bh_enable_ip()
> > has been removed.
> >
> > I think it is beneficial, because it allows avoiding a
> > local_irq_save()/local_irq_restore() pairs per local_bh_enable under heavy load.
> >
> 
> Interesting, do you have any numbers ?

The difference is small, in the noise range:

[with this patch applied]
super_netperf 100 -H 192.168.122.1 -t UDP_STREAM -l 60 -- -m 1 
9.00

[adding the test into __local_bh_enable_ip(), too]
super_netperf 100 -H 192.168.122.1 -t UDP_STREAM -l 60 -- -m 1 
9.14

but reproducible, in my experiments.
I have similar data for different number of flows.

> I believe I did this so that we factorize the logic in do_softirq()
> and keep the code local to kernel/softirq.c
> 
> Otherwise, netif_rx_ni() could also process softirq while ksoftirqd
> was scheduled,
> so I would have to  'export' the ksoftirqd_running(void) helper in an
> include file.

The idea could be to add the test in __local_bh_enable_ip(), maintaining
the test also in do_softirq() (as currently done, i.e for
local_softirq_pending())

Cheers,

Paolo
