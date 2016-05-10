From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 0/2] net: threadable napi poll loop
Date: Tue, 10 May 2016 15:51:37 -0700
Message-ID: <1462920697.23934.113.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1462886866.git.pabeni@redhat.com>
	 <1462890590.23934.68.camel@edumazet-glaptop3.roam.corp.google.com>
	 <90f3db8c-c30c-b204-576a-454939ac93ce@stressinduktion.org>
	 <CANn89i+YKrVOgfFwW-2psfCzq5_YLdmbV06-H-1FCOwXdMBuzQ@mail.gmail.com>
	 <94f323a9-515e-4d75-cac8-ef0214f0499e@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
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
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35398 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751961AbcEJWvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 18:51:39 -0400
In-Reply-To: <94f323a9-515e-4d75-cac8-ef0214f0499e@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-05-11 at 00:32 +0200, Hannes Frederic Sowa wrote:

> Not only did we want to present this solely as a bugfix but also as as
> performance enhancements in case of virtio (as you can see in the cover
> letter). Given that a long time ago there was a tendency to remove
> softirqs completely, we thought it might be very interesting, that a
> threaded napi in general seems to be absolutely viable nowadays and
> might offer new features.

Well, you did not fix the bug, you worked around by adding yet another
layer, with another sysctl that admins or programs have to manage.

If you have a special need for virtio, do not hide it behind a 'bug fix'
but add it as a features request.

This ksoftirqd issue is real and a fix looks very reasonable.

Please try this patch, as I had very good success with it.

Thanks.


diff --git a/kernel/softirq.c b/kernel/softirq.c
index 17caf4b63342..22463217e3cf 100644
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
@@ -340,6 +345,9 @@ void irq_enter(void)
 
 static inline void invoke_softirq(void)
 {
+	if (__this_cpu_read(ksoftirqd_scheduled))
+		return;
+
 	if (!force_irqthreads) {
 #ifdef CONFIG_HAVE_IRQ_EXIT_ON_IRQ_STACK
 		/*
@@ -660,6 +668,8 @@ static void run_ksoftirqd(unsigned int cpu)
 		 * in the task stack here.
 		 */
 		__do_softirq();
+		if (!local_softirq_pending())
+			__this_cpu_write(ksoftirqd_scheduled, false);
 		local_irq_enable();
 		cond_resched_rcu_qs();
 		return;
