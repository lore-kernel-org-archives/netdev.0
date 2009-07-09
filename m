From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH] netpoll: Fix carrier detection for drivers that are
 using phylib
Date: Thu, 09 Jul 2009 16:31:02 +0200
Message-ID: <1247149862.12784.6.camel@twins>
References: <20090707235812.GA12824@oksana.dev.rtsoft.ru>
	 <20090708005000.GA12380@redhat.com> <1247034263.9777.24.camel@twins>
	 <alpine.LFD.2.01.0907080907210.3210@localhost.localdomain>
	 <20090708141024.f8b581c5.akpm@linux-foundation.org>
	 <20090708213331.GA9346@oksana.dev.rtsoft.ru>
	 <20090708144744.5555b88d.akpm@linux-foundation.org>
	 <20090708222003.GA12318@oksana.dev.rtsoft.ru>
	 <alpine.LFD.2.01.0907081701050.3352@localhost.localdomain>
	 <1247145977.21295.899.camel@calx>  <1247147206.7439.2.camel@twins>
	 <1247149093.21295.915.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Anton Vorontsov <avorontsov@ru.mvista.com>,
	Andrew Morton <akpm@linux-foundation.org>, oleg@redhat.com,
	mingo@elte.hu, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep14-int.chello.at ([62.179.121.34]:46402 "EHLO
	viefep14-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760737AbZGIObL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2009 10:31:11 -0400
In-Reply-To: <1247149093.21295.915.camel@calx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-07-09 at 09:18 -0500, Matt Mackall wrote:
> 
> Sorry if I was unclear. I'm suggesting setting the count so the existing
> PREEMPT_ACTIVE test here fires:
> 
> int __sched _cond_resched(void)
> {
>         if (need_resched() && !(preempt_count() & PREEMPT_ACTIVE) &&
>                                         system_state == SYSTEM_RUNNING) {
>                 __cond_resched();
>                 return 1;
>         }
>         return 0;
> }

Right, /me read preempt and thought a simple preempt inc but didn't read
the code. Shame on me.

So something like (utterly untested and such)

---

 arch/x86/include/asm/thread_info.h |    2 +-
 kernel/sched.c                     |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/x86/include/asm/thread_info.h b/arch/x86/include/asm/thread_info.h
index b078352..7b5dbce 100644
--- a/arch/x86/include/asm/thread_info.h
+++ b/arch/x86/include/asm/thread_info.h
@@ -49,7 +49,7 @@ struct thread_info {
 	.exec_domain	= &default_exec_domain,	\
 	.flags		= 0,			\
 	.cpu		= 0,			\
-	.preempt_count	= 1,			\
+	.preempt_count	= 1 + PREEMPT_ACTIVE,	\
 	.addr_limit	= KERNEL_DS,		\
 	.restart_block = {			\
 		.fn = do_no_restart_syscall,	\
diff --git a/kernel/sched.c b/kernel/sched.c
index fd3ac58..8e81162 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -6599,8 +6599,7 @@ static void __cond_resched(void)
 
 int __sched _cond_resched(void)
 {
-	if (need_resched() && !(preempt_count() & PREEMPT_ACTIVE) &&
-					system_state == SYSTEM_RUNNING) {
+	if (need_resched() && !(preempt_count() & PREEMPT_ACTIVE)) {
 		__cond_resched();
 		return 1;
 	}
@@ -9422,6 +9421,7 @@ void __init sched_init(void)
 	perf_counter_init();
 
 	scheduler_running = 1;
+	sub_preempt_count(PREEMPT_ACTIVE);
 }
 
 #ifdef CONFIG_DEBUG_SPINLOCK_SLEEP


