From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Wed, 11 May 2016 10:55:04 -0700
Message-ID: <1462989304.23934.152.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1462886866.git.pabeni@redhat.com>
	 <1462890590.23934.68.camel@edumazet-glaptop3.roam.corp.google.com>
	 <90f3db8c-c30c-b204-576a-454939ac93ce@stressinduktion.org>
	 <CANn89i+YKrVOgfFwW-2psfCzq5_YLdmbV06-H-1FCOwXdMBuzQ@mail.gmail.com>
	 <1462915900.23934.99.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1462916121.16365.14.camel@redhat.com>
	 <1462917217.23934.101.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Paolo Abeni <pabeni@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Tom Herbert <tom@herbertland.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Rik van Riel <riel@redhat.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462917217.23934.101.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-05-10 at 14:53 -0700, Eric Dumazet wrote:
> On Tue, 2016-05-10 at 17:35 -0400, Rik van Riel wrote:
> 
> > You might need another one of these in invoke_softirq()
> > 
> 
> Excellent.
> 
> I gave it a quick try (without your suggestion), and host seems to
> survive a stress test.

Well, we instantly trigger rcu issues.

How to reproduce :

netserver &
for i in `seq 1 100`
do
  netperf -H 127.0.0.1 -t TCP_RR -l 1000 &
done
# local hack to enable the new behavior
# without having to add a new sysctl, but hacking an existing one
echo 1001 >/proc/sys/net/core/netdev_max_backlog

<bang :>



[  236.977511] INFO: rcu_sched self-detected stall on CPU
[  236.977512] INFO: rcu_sched self-detected stall on CPU
[  236.977515] INFO: rcu_sched self-detected stall on CPU
[  236.977518] INFO: rcu_sched self-detected stall on CPU
[  236.977519] INFO: rcu_sched self-detected stall on CPU
[  236.977521] INFO: rcu_sched self-detected stall on CPU
[  236.977522] INFO: rcu_sched self-detected stall on CPU
[  236.977523] INFO: rcu_sched self-detected stall on CPU
[  236.977525] INFO: rcu_sched self-detected stall on CPU
[  236.977526] INFO: rcu_sched self-detected stall on CPU
[  236.977527] INFO: rcu_sched self-detected stall on CPU
[  236.977529] INFO: rcu_sched self-detected stall on CPU
[  236.977530] INFO: rcu_sched self-detected stall on CPU
[  236.977532] INFO: rcu_sched self-detected stall on CPU
[  236.977532] 	47-...: (1 GPs behind) idle=8d1/1/0 softirq=2500/2506 fqs=1 
[  236.977535] INFO: rcu_sched self-detected stall on CPU
[  236.977536] INFO: rcu_sched self-detected stall on CPU
[  236.977540] 	36-...: (1 GPs behind) idle=d05/1/0 softirq=2637/2644 fqs=1 
[  236.977546] 	
[  236.977546] 	38-...: (1 GPs behind) idle=a5b/1/0 softirq=2612/2618 fqs=1 
[  236.977549] 	0-...: (1 GPs behind) idle=c39/1/0 softirq=15315/15321 fqs=1 
[  236.977551] 	24-...: (1 GPs behind) idle=ea3/1/0 softirq=2455/2461 fqs=1 
[  236.977554] 	18-...: (20995 ticks this GP) idle=ef5/1/0 softirq=8530/8530 fqs=1 
[  236.977556] 	39-...: (1 GPs behind) idle=f9d/1/0 softirq=2144/2150 fqs=1 
[  236.977558] 	
[  236.977558] 	22-...: (1 GPs behind) idle=5a7/1/0 softirq=10238/10244 fqs=1 
[  236.977561] 	7-...: (1 GPs behind) idle=323/1/0 softirq=5279/5285 fqs=1 
[  236.977563] 	31-...: (1 GPs behind) idle=47d/1/0 softirq=2526/2532 fqs=1 
[  236.977565] 	33-...: (1 GPs behind) idle=175/1/0 softirq=2060/2066 fqs=1 
[  236.977568] 	10-...: (1 GPs behind) idle=c3d/1/0 softirq=4864/4870 fqs=1 
[  236.977570] 	34-...: (20995 ticks this GP) idle=dd5/1/0 softirq=2243/2243 fqs=1 
[  236.977574] 	
[  236.977574] 	37-...: (1 GPs behind) idle=aef/1/0 softirq=2660/2666 fqs=1 
[  236.977576] 	13-...: (1 GPs behind) idle=a2b/1/0 softirq=9928/9934 fqs=1 
[  236.977578] 	
[  236.977578] 	
[  236.977579] 	
[  236.977580] 	
[  236.977582] 	
[  236.977583] 	
[  236.977583] 	
[  236.977584] 	
[  236.977584] 	
[  236.977586] 	
[  236.977587] rcu_sched kthread starved for 20997 jiffies! g33049 c33048 f0x0 RCU_GP_WAIT_FQS(3) ->state=0x1
[  236.977588] 	
[  236.977589] 	
[  236.977595] rcu_sched kthread starved for 20997 jiffies! g33049 c33048 f0x0 RCU_GP_WAIT_FQS(3) ->state=0x1
[  236.977603] rcu_sched kthread starved for 20997 jiffies! g33049 c33048 f0x0 RCU_GP_WAIT_FQS(3) ->state=0x1
[  236.977607] rcu_sched kthread starved for 20997 jiffies! g33049 c33048 f0x0 RCU_GP_WAIT_FQS(3) ->state=0x1
[  236.977609] rcu_sched kthread starved for 20997 jiffies! g33049 c33048 f0x0 RCU_GP_WAIT_FQS(3) ->state=0x1
[  236.977610] rcu_sched kthread starved for 20997 jiffies! g33049 c33048 f0x0 RCU_GP_WAIT_FQS(3) ->state=0x1
[  236.977612] rcu_sched kthread starved for 20997 jiffies! g33049 c33048 f0x0 RCU_GP_WAIT_FQS(3) ->state=0x1
[  236.977614] rcu_sched kthread starved for 20997 jiffies! g33049 c33048 f0x0 RCU_GP_WAIT_FQS(3) ->state=0x1
[  236.977616] rcu_sched kthread starved for 20997 jiffies! g33049 c33048 f0x0 RCU_GP_WAIT_FQS(3) ->state=0x1
[  236.977618] rcu_sched kthread starved for 20997 jiffies! g33049 c33048 f0x0 RCU_GP_WAIT_FQS(3) ->state=0x1
[  236.977619] rcu_sched kthread starved for 20997 jiffies! g33049 c33048 f0x0 RCU_GP_WAIT_FQS(3) ->state=0x1
[  236.977620] rcu_sched kthread starved for 20997 jiffies! g33049 c33048 f0x0 RCU_GP_WAIT_FQS(3) ->state=0x1
[  236.977622] rcu_sched kthread starved for 20997 jiffies! g33049 c33048 f0x0 RCU_GP_WAIT_FQS(3) ->state=0x1
[  236.977626] rcu_sched kthread starved for 20997 jiffies! g33049 c33048 f0x0 RCU_GP_WAIT_FQS(3) ->state=0x1
[  236.977627] rcu_sched kthread starved for 20997 jiffies! g33049 c33048 f0x0 RCU_GP_WAIT_FQS(3) ->state=0x1
[  236.978512] INFO: rcu_sched self-detected stall on CPU
[  236.978512] INFO: rcu_sched self-detected stall on CPU
[  236.978514] INFO: rcu_sched self-detected stall on CPU
[  236.978516] INFO: rcu_sched self-detected stall on CPU
[  236.978517] INFO: rcu_sched self-detected stall on CPU
[  236.978518] INFO: rcu_sched self-detected stall on CPU
[  236.978519] INFO: rcu_sched self-detected stall on CPU
[  236.978520] INFO: rcu_sched self-detected stall on CPU
[  236.978521] INFO: rcu_sched self-detected stall on CPU
[  236.978522] INFO: rcu_sched self-detected stall on CPU
[  236.978523] INFO: rcu_sched self-detected stall on CPU
[  236.978524] INFO: rcu_sched self-detected stall on CPU
[  236.978532] 	45-...: (1 GPs behind) idle=8ed/1/0 softirq=3047/3053 fqs=1 
[  236.978534] 	19-...: (20996 ticks this GP) idle=b5d/1/0 softirq=8157/8157 fqs=1 
[  236.978538] 	17-...: (1 GPs behind) idle=5ad/1/0 softirq=7839/7845 fqs=1 
[  236.978539] 	41-...: (1 GPs behind) idle=f4f/1/0 softirq=2345/2351 fqs=1 
[  236.978542] 	6-...: (1 GPs behind) idle=a39/1/0 softirq=5492/5498 fqs=1 
[  236.978544] 	30-...: (1 GPs behind) idle=c51/1/0 softirq=2499/2505 fqs=1 
[  236.978546] 	5-...: (1 GPs behind) idle=917/1/0 softirq=5196/5202 fqs=1 
[  236.978548] 	26-...: (20996 ticks this GP) idle=c61/1/0 softirq=2863/2863 fqs=1 
[  236.978550] 	32-...: (1 GPs behind) idle=8db/1/0 softirq=2588/2594 fqs=1 
[  236.978552] 	35-...: (1 GPs behind) idle=351/1/0 softirq=1869/1875 fqs=1 
[  236.978554] 	8-...: (1 GPs behind) idle=221/1/0 softirq=5192/5198 fqs=1 
[  236.978556] 	11-...: (1 GPs behind) idle=485/1/0 softirq=4480/4486 fqs=1 
[  236.978557] 	
[  236.978558] 	
[  236.978559] 	
[  236.978560] 	
[  236.978561] 	


Tentative proto / patch (not including Peter suggestions yet)

diff --git a/kernel/softirq.c b/kernel/softirq.c
index 17caf4b63342..be94e0241a70 100644
--- a/kernel/softirq.c
+++ b/kernel/softirq.c
@@ -56,6 +56,14 @@ EXPORT_SYMBOL(irq_stat);
 static struct softirq_action softirq_vec[NR_SOFTIRQS] __cacheline_aligned_in_smp;
 
 DEFINE_PER_CPU(struct task_struct *, ksoftirqd);
+DEFINE_PER_CPU(bool, ksoftirqd_scheduled);
+
+static inline bool ksoftirqd_running(void)
+{
+	extern int netdev_max_backlog; /* temp hack */
+
+	return (netdev_max_backlog & 1) && __this_cpu_read(ksoftirqd_scheduled);
+}
 
 const char * const softirq_to_name[NR_SOFTIRQS] = {
 	"HI", "TIMER", "NET_TX", "NET_RX", "BLOCK", "BLOCK_IOPOLL",
@@ -73,8 +81,10 @@ static void wakeup_softirqd(void)
 	/* Interrupts are disabled: no need to stop preemption */
 	struct task_struct *tsk = __this_cpu_read(ksoftirqd);
 
-	if (tsk && tsk->state != TASK_RUNNING)
+	if (tsk && tsk->state != TASK_RUNNING) {
+		__this_cpu_write(ksoftirqd_scheduled, true);
 		wake_up_process(tsk);
+	}
 }
 
 /*
@@ -313,7 +323,7 @@ asmlinkage __visible void do_softirq(void)
 
 	pending = local_softirq_pending();
 
-	if (pending)
+	if (pending && !ksoftirqd_running())
 		do_softirq_own_stack();
 
 	local_irq_restore(flags);
@@ -340,6 +350,9 @@ void irq_enter(void)
 
 static inline void invoke_softirq(void)
 {
+	if (ksoftirqd_running())
+		return;
+
 	if (!force_irqthreads) {
 #ifdef CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK
 		/*
@@ -660,6 +673,8 @@ static void run_ksoftirqd(unsigned int cpu)
 		 * in the task stack here.
 		 */
 		__do_softirq();
+		if (!local_softirq_pending())
+			__this_cpu_write(ksoftirqd_scheduled, false);
 		local_irq_enable();
 		cond_resched_rcu_qs();
 		return;
