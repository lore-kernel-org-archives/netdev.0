From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Mon, 09 Jun 2003 14:30:46 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030609.143046.48683937.davem@redhat.com>
References: <20030609082718.GG20613@netnation.com>
	<004f01c32ebe$b4bd88d0$4a00000a@badass>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sim@netnation.com, hadi@shell.cyberus.ca, fw@deneb.enyo.de,
   netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: xerox@foonet.net
In-Reply-To: <004f01c32ebe$b4bd88d0$4a00000a@badass>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: "CIT/Paul" <xerox@foonet.net>
   Date: Mon, 9 Jun 2003 15:38:30 -0400

   I've tried other settings, secret-interval 1 which seems to 'flush' the
   cache every second or 60 seconds as I have it here..
   If I have secret interval set to 1 the GC never runs because the cache
   never gets > my gc thresh..

Set secret interval to infinity.  Even the default setting of 10
minutes is overly anal.  It's only picking a new random secret for the
hash so that algorithmic attacks are less likely even if the attacker
find a method by which to determine the secret key on your system.  It
is impossible for an attacker to do this as far as I am aware.

   Also tried with max_size 16000 but juno pegs the route cache

What do you mean, specifically, by "pegs"?

   This seems to be a good compromise for now.. 
   
Setting the secret interval smaller than it's default serves no
purpose.  I would recommend instead to incrase it.

   Ok you see this happening but during this the router is almost
   unusable..   
   PID USER     PRI  NI  SIZE  RSS SHARE STAT %CPU %MEM   TIME COMMAND
       3 root      20  -1     0    0     0 RW<  48.5  0.0  34:04
   ksoftirqd_CPU0
       4 root      20  -1     0    0     0 RW<  46.7  0.0  34:14
   ksoftirqd_CPU1
   
   Both cpus are slammed at 100% by the ksoftirqds.

ksoftirqd kicks in WAY too early, try my patch below.

   This is using e1000 with interrups limited to ~ 4000/second (ITR),
   no NAPI.. NAPI messes it up big time and drops more packets than
   without :>

Something is very wrong, NAPI can only give your system more CPU time
by which to do packet processing.  Some good kernel profiles would be
nice too.
   
Anyways, here is the patch to make ksoftirqd no kick in so quickly,
it's based upon a 2.4.x patch from Ingo Molnar:

--- kernel/softirq.c.~1~	Mon Jun  9 14:28:02 2003
+++ kernel/softirq.c	Mon Jun  9 14:29:28 2003
@@ -52,11 +52,22 @@
 		wake_up_process(tsk);
 }
 
+/*
+ * We restart softirq processing MAX_SOFTIRQ_RESTART times,
+ * and we fall back to softirqd after that.
+ *
+ * This number has been established via experimentation.
+ * The two things to balance is latency against fairness -
+ * we want to handle softirqs as soon as possible, but they
+ * should not be able to lock up the box.
+ */
+#define MAX_SOFTIRQ_RESTART 10
+
 asmlinkage void do_softirq(void)
 {
+	int max_restart = MAX_SOFTIRQ_RESTART;
 	__u32 pending;
 	unsigned long flags;
-	__u32 mask;
 
 	if (in_interrupt())
 		return;
@@ -68,7 +79,6 @@
 	if (pending) {
 		struct softirq_action *h;
 
-		mask = ~pending;
 		local_bh_disable();
 restart:
 		/* Reset the pending bitmask before enabling irqs */
@@ -88,10 +98,8 @@
 		local_irq_disable();
 
 		pending = local_softirq_pending();
-		if (pending & mask) {
-			mask &= ~pending;
+		if (pending && --max_restart)
 			goto restart;
-		}
 		if (pending)
 			wakeup_softirqd(smp_processor_id());
 		__local_bh_enable();
