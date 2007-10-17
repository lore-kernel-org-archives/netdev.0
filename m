From: Tina Yang <tina.yang@oracle.com>
Subject: [patch] net: avoid race between netpoll and network fast path
Date: Tue, 16 Oct 2007 20:45:04 -0700
Message-ID: <47158540.7000709@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:19213 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752543AbXJQDwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 23:52:01 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current netpoll design and implementation has serveral race issues with the
network fast path that panics/hangs the system or causes interface timeout/reset
but the fix is likely to have impact on the overall system performance and could
involve a large number of drivers.  The proposal is to disable the problem code
for normal operations but only to enable it at the time of crash in case polling
is necessary.  Tests that have been done included the bug fix verification
as well as regression check on the netlog results in various crash modes.

Signed-off-by: Tina Yang <tina.yang@oracle.com>

---

--- linux-2.6.23.1/include/linux/kernel.h.orig	2007-10-12 09:43:44.000000000 -0700
+++ linux-2.6.23.1/include/linux/kernel.h	2007-10-15 22:05:27.000000000 -0700
@@ -184,6 +184,8 @@ static inline void console_verbose(void)
 		console_loglevel = 15;
 }

+extern int netpoll_enable;
+
 extern void bust_spinlocks(int yes);
 extern void wake_up_klogd(void);
 extern int oops_in_progress;		/* If set, an oops, panic(), BUG() or die() is in progress */
--- linux-2.6.23.1/net/core/netpoll.c.orig	2007-10-12 09:43:44.000000000 -0700
+++ linux-2.6.23.1/net/core/netpoll.c	2007-10-15 22:20:15.000000000 -0700
@@ -150,15 +150,19 @@ static void service_arp_queue(struct net
 	}
 }

+int netpoll_enable;
+EXPORT_SYMBOL(netpoll_enable);
 void netpoll_poll(struct netpoll *np)
 {
 	if (!np->dev || !netif_running(np->dev) || !np->dev->poll_controller)
 		return;

 	/* Process pending work on NIC */
-	np->dev->poll_controller(np->dev);
-	if (np->dev->poll)
-		poll_napi(np);
+	if (unlikely(netpoll_enable)) {
+		np->dev->poll_controller(np->dev);
+		if (np->dev->poll)
+			poll_napi(np);
+	}

 	service_arp_queue(np->dev->npinfo);

--- linux-2.6.23.1/kernel/panic.c.orig	2007-10-12 09:43:44.000000000 -0700
+++ linux-2.6.23.1/kernel/panic.c	2007-10-15 22:07:25.000000000 -0700
@@ -66,6 +66,7 @@ NORET_TYPE void panic(const char * fmt,
         unsigned long caller = (unsigned long) __builtin_return_address(0);
 #endif

+	netpoll_enable = 1;
 	/*
 	 * It's possible to come here directly from a panic-assertion and not
 	 * have preempt disabled. Some functions called from here want
--- linux-2.6.23.1/arch/x86_64/kernel/traps.c.orig	2007-10-12 09:43:44.000000000 -0700
+++ linux-2.6.23.1/arch/x86_64/kernel/traps.c	2007-10-15 22:06:29.000000000 -0700
@@ -522,6 +522,8 @@ void __kprobes __die(const char * str, s
 #endif
 	printk("\n");
 	notify_die(DIE_OOPS, str, regs, err, current->thread.trap_no, SIGSEGV);
+	if (kexec_should_crash(current))
+		netpoll_enable = 1;
 	show_registers(regs);
 	add_taint(TAINT_DIE);
 	/* Executive summary in case the oops scrolled away */
--- linux-2.6.23.1/arch/i386/kernel/traps.c.orig	2007-10-12 09:43:44.000000000 -0700
+++ linux-2.6.23.1/arch/i386/kernel/traps.c	2007-10-15 22:06:14.000000000 -0700
@@ -428,6 +428,8 @@ void die(const char * str, struct pt_reg
 		if (notify_die(DIE_OOPS, str, regs, err,
 					current->thread.trap_no, SIGSEGV) !=
 				NOTIFY_STOP) {
+			if (kexec_should_crash(current))
+				netpoll_enable = 1;
 			show_registers(regs);
 			/* Executive summary in case the oops scrolled away */
 			esp = (unsigned long) (&regs->esp);
