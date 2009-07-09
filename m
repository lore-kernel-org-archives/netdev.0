From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] netpoll: Fix carrier detection for drivers that are
 using phylib
Date: Wed, 8 Jul 2009 17:01:14 -0700 (PDT)
Message-ID: <alpine.LFD.2.01.0907081701050.3352@localhost.localdomain>
References: <20090707235812.GA12824@oksana.dev.rtsoft.ru> <20090708005000.GA12380@redhat.com> <1247034263.9777.24.camel@twins> <alpine.LFD.2.01.0907080907210.3210@localhost.localdomain> <20090708141024.f8b581c5.akpm@linux-foundation.org>
 <20090708213331.GA9346@oksana.dev.rtsoft.ru> <20090708144744.5555b88d.akpm@linux-foundation.org> <20090708222003.GA12318@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>, a.p.zijlstra@chello.nl,
	oleg@redhat.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52399 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756513AbZGIADA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 20:03:00 -0400
In-Reply-To: <20090708222003.GA12318@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 9 Jul 2009, Anton Vorontsov wrote:
> 
> The netpoll code is using msleep() just a few lines below cond_resched(),
> so we won't make things worse. ;-)

Yeah. That function is definitely sleeping. It does things like 
kmalloc(GFP_KERNEL), rtnl_lock() and synchronize_rcu() etc too, so an 
added msleep() is the least of our problems.

Afaik, it's called from a bog-standard "module_init()", which happens late 
enough that everything works.

In fact, I wonder if we should set SYSTEM_RUNNING much earlier - _before_ 
doing the whole "do_initcalls()". By then we've set up all the core stuff 
and enabled interrupts, so we really _are_ running. We just don't 
necessarily have drivers, filesystems etc loaded yet. But anything that 
happens late enough to be an initcall should be largely considered to 
be during "normal code".

(The "early_initcall" cases are special - those really do happen pretty 
early).

So ACK on Anton's patch, but I wonder if we _also_ should do the 
following?

Looking at the people looking at SYSTEM_RUNNING, I do note some odd cases. 
Why the heck does kernel/perf_counter.c do it, for example?

		Linus

---
 init/main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/init/main.c b/init/main.c
index 2c5ade7..f10d9cd 100644
--- a/init/main.c
+++ b/init/main.c
@@ -788,6 +788,7 @@ static void __init do_initcalls(void)
 {
 	initcall_t *call;
 
+	system_state = SYSTEM_RUNNING;
 	for (call = __early_initcall_end; call < __initcall_end; call++)
 		do_one_initcall(*call);
 
@@ -839,7 +840,6 @@ static noinline int init_post(void)
 	free_initmem();
 	unlock_kernel();
 	mark_rodata_ro();
-	system_state = SYSTEM_RUNNING;
 	numa_default_policy();
 
 	if (sys_open((const char __user *) "/dev/console", O_RDWR, 0) < 0)
