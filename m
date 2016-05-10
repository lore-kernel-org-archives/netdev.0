From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Tue, 10 May 2016 14:31:40 -0700
Message-ID: <1462915900.23934.99.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1462886866.git.pabeni@redhat.com>
	 <1462890590.23934.68.camel@edumazet-glaptop3.roam.corp.google.com>
	 <90f3db8c-c30c-b204-576a-454939ac93ce@stressinduktion.org>
	 <CANn89i+YKrVOgfFwW-2psfCzq5_YLdmbV06-H-1FCOwXdMBuzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Paolo Abeni <pabeni@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Tom Herbert <tom@herbertland.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>, Rik van Riel <riel@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANn89i+YKrVOgfFwW-2psfCzq5_YLdmbV06-H-1FCOwXdMBuzQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-05-10 at 14:09 -0700, Eric Dumazet wrote:
> On Tue, May 10, 2016 at 1:46 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> 
> > I agree here, but I don't think this patch particularly is a lot of
> > bloat and something very interesting people can play with and extend upon.
> >
> 
> Sure, very rarely patch authors think their stuff is bloat.
> 
> I prefer to fix kernel softirq.c, or at least show me that you tried
> hard enough.
> 
> I am pretty sure that the following would work :
> 
> When ksoftirqd is scheduled, remember this in a per cpu variable
> (ksoftiqd_scheduled)
> 
> When enabling BH , do not call do_softirq() if this variable is set.
> 
> ksoftirqd would clear the variable at the right place (probably in
> run_ksoftirqd())
> 
> Sure, this might add a lot of latency regressions, but lets fix them.

Only to give the idea (it is completely untested and probably buggy)

diff --git a/kernel/softirq.c b/kernel/softirq.c
index 17caf4b63342..cb30cfd76687 100644
--- a/kernel/softirq.c
+++ b/kernel/softirq.c
@@ -56,6 +56,7 @@ EXPORT_SYMBOL(irq_stat);
 static struct softirq_action softirq_vec[NR_SOFTIRQS] __cacheline_aligned_in_smp;
 
 DEFINE_PER_CPU(struct task_struct *, ksoftirqd);
+DEFINE_PER_CPU(bool, ksoftirqd_scheduled);
 
 const char * const softirq_to_name[NR_SOFTIRQS] = {
 	"HI", "TIMER", "NET_TX", "NET_RX", "BLOCK", "BLOCK_IOPOLL",
@@ -73,8 +74,10 @@ static void wakeup_softirqd(void)
 	/* Interrupts are disabled: no need to stop preemption */
 	struct task_struct *tsk = __this_cpu_read(ksoftirqd);
 
-	if (tsk && tsk->state != TASK_RUNNING)
+	if (tsk && tsk->state != TASK_RUNNING) {
+		__this_cpu_write(ksoftirqd_scheduled, true);
 		wake_up_process(tsk);
+	}
 }
 
 /*
@@ -162,7 +165,9 @@ void __local_bh_enable_ip(unsigned long ip, unsigned int cnt)
 	 */
 	preempt_count_sub(cnt - 1);
 
-	if (unlikely(!in_interrupt() && local_softirq_pending())) {
+	if (unlikely(!in_interrupt() &&
+		     local_softirq_pending() &&
+		     !__this_cpu_read(ksoftirqd_scheduled))) {
 		/*
 		 * Run softirq if any pending. And do it in its own stack
 		 * as we may be calling this deep in a task call stack already.
@@ -660,6 +665,8 @@ static void run_ksoftirqd(unsigned int cpu)
 		 * in the task stack here.
 		 */
 		__do_softirq();
+		if (!local_softirq_pending())
+			__this_cpu_write(ksoftirqd_scheduled, false);
 		local_irq_enable();
 		cond_resched_rcu_qs();
 		return;
