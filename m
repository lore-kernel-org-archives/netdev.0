From: Nishanth Aravamudan <nacc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [-mm PATCH 05/32] net: fix-up schedule_timeout() usage
Date: Mon, 15 Aug 2005 11:10:00 -0700
Message-ID: <20050815181000.GH2854@us.ibm.com>
References: <20050815180514.GC2854@us.ibm.com>
Reply-To: irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm-3NddpPZAyC0@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kuznet-v/Mj1YrvjDBInbfyfbPRSQ@public.gmane.org, pekkas-UjJjq++bwZ7HOG6cAo2yLw@public.gmane.org,
	jmorris-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, kaber-9zj18yfci/wOIzVOb1FTxg@public.gmane.org,
	jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org, okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <20050815180514.GC2854-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Sender: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <http://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Id: netdev.vger.kernel.org

Description: Use schedule_timeout_{,un}interruptible() instead of
set_current_state()/schedule_timeout() to reduce kernel size. Also use
human-time conversion functions instead of hard-coded division to avoid
rounding issues.

Signed-off-by: Nishanth Aravamudan <nacc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

---

 net/core/pktgen.c            |   13 +++++--------
 net/dccp/proto.c             |    2 +-
 net/ipv4/ipconfig.c          |    5 ++---
 net/irda/ircomm/ircomm_tty.c |    9 +++------
 net/sunrpc/svcsock.c         |    3 +--
 5 files changed, 12 insertions(+), 20 deletions(-)

--- 2.6.13-rc5-mm1/net/core/pktgen.c	2005-08-07 10:05:22.000000000 -0700
+++ 2.6.13-rc5-mm1-dev/net/core/pktgen.c	2005-08-14 13:32:59.000000000 -0700
@@ -1452,8 +1452,7 @@ static int proc_thread_write(struct file
 		thread_lock();
 		t->control |= T_REMDEV;
 		thread_unlock();
-		current->state = TASK_INTERRUPTIBLE;
-		schedule_timeout(HZ/8);  /* Propagate thread->control  */
+		schedule_timeout_interruptible(msecs_to_jiffies(125));  /* Propagate thread->control  */
 		ret = count;
                 sprintf(pg_result, "OK: rem_device_all");
 		goto out;
@@ -1716,10 +1715,9 @@ static void spin(struct pktgen_dev *pkt_
 	printk(KERN_INFO "sleeping for %d\n", (int)(spin_until_us - now));
 	while (now < spin_until_us) {
 		/* TODO: optimise sleeping behavior */
-		if (spin_until_us - now > (1000000/HZ)+1) {
-			current->state = TASK_INTERRUPTIBLE;
-			schedule_timeout(1);
-		} else if (spin_until_us - now > 100) {
+		if (spin_until_us - now > jiffies_to_usecs(1)+1)
+			schedule_timeout_interruptible(1);
+		else if (spin_until_us - now > 100) {
 			do_softirq();
 			if (!pkt_dev->running)
 				return;
@@ -2449,8 +2447,7 @@ static void pktgen_run_all_threads(void)
 	}
 	thread_unlock();
 
-	current->state = TASK_INTERRUPTIBLE;
-	schedule_timeout(HZ/8);  /* Propagate thread->control  */
+	schedule_timeout_interruptible(msecs_to_jiffies(125));  /* Propagate thread->control  */
 			
 	pktgen_wait_all_threads_run();
 }
diff -urpN 2.6.13-rc5-mm1/net/dccp/proto.c 2.6.13-rc5-mm1-dev/net/dccp/proto.c
--- 2.6.13-rc5-mm1/net/dccp/proto.c	2005-08-07 10:05:22.000000000 -0700
+++ 2.6.13-rc5-mm1-dev/net/dccp/proto.c	2005-08-10 16:10:55.000000000 -0700
@@ -225,7 +225,7 @@ int dccp_sendmsg(struct kiocb *iocb, str
 			if (delay > timeo)
 				goto out_discard;
 			release_sock(sk);
-			delay = schedule_timeout(delay);
+			delay = schedule_timeout_interruptible(delay);
 			lock_sock(sk);
 			timeo -= delay;
 			if (signal_pending(current))
diff -urpN 2.6.13-rc5-mm1/net/ipv4/ipconfig.c 2.6.13-rc5-mm1-dev/net/ipv4/ipconfig.c
--- 2.6.13-rc5-mm1/net/ipv4/ipconfig.c	2005-08-07 10:05:22.000000000 -0700
+++ 2.6.13-rc5-mm1-dev/net/ipv4/ipconfig.c	2005-08-10 15:26:57.000000000 -0700
@@ -1102,10 +1102,9 @@ static int __init ic_dynamic(void)
 #endif
 
 		jiff = jiffies + (d->next ? CONF_INTER_TIMEOUT : timeout);
-		while (time_before(jiffies, jiff) && !ic_got_reply) {
+		while (time_before(jiffies, jiff) && !ic_got_reply)
 			set_current_state(TASK_UNINTERRUPTIBLE);
-			schedule_timeout(1);
-		}
+			schedule_timeout_uninterruptible(1);
 #ifdef IPCONFIG_DHCP
 		/* DHCP isn't done until we get a DHCPACK. */
 		if ((ic_got_reply & IC_BOOTP)
diff -urpN 2.6.13-rc5-mm1/net/irda/ircomm/ircomm_tty.c 2.6.13-rc5-mm1-dev/net/irda/ircomm/ircomm_tty.c
--- 2.6.13-rc5-mm1/net/irda/ircomm/ircomm_tty.c	2005-08-07 09:57:38.000000000 -0700
+++ 2.6.13-rc5-mm1-dev/net/irda/ircomm/ircomm_tty.c	2005-08-10 15:27:13.000000000 -0700
@@ -567,10 +567,8 @@ static void ircomm_tty_close(struct tty_
 	self->tty = NULL;
 
 	if (self->blocked_open) {
-		if (self->close_delay) {
-			current->state = TASK_INTERRUPTIBLE;
-			schedule_timeout(self->close_delay);
-		}
+		if (self->close_delay)
+			schedule_timeout_interruptible(self->close_delay);
 		wake_up_interruptible(&self->open_wait);
 	}
 
@@ -863,8 +861,7 @@ static void ircomm_tty_wait_until_sent(s
 	spin_lock_irqsave(&self->spinlock, flags);
 	while (self->tx_skb && self->tx_skb->len) {
 		spin_unlock_irqrestore(&self->spinlock, flags);
-		current->state = TASK_INTERRUPTIBLE;
-		schedule_timeout(poll_time);
+		schedule_timeout_interruptible(poll_time);
 		spin_lock_irqsave(&self->spinlock, flags);
 		if (signal_pending(current))
 			break;
diff -urpN 2.6.13-rc5-mm1/net/sunrpc/svcsock.c 2.6.13-rc5-mm1-dev/net/sunrpc/svcsock.c
--- 2.6.13-rc5-mm1/net/sunrpc/svcsock.c	2005-08-07 10:05:22.000000000 -0700
+++ 2.6.13-rc5-mm1-dev/net/sunrpc/svcsock.c	2005-08-12 13:51:40.000000000 -0700
@@ -1167,8 +1167,7 @@ svc_recv(struct svc_serv *serv, struct s
 	while (rqstp->rq_arghi < pages) {
 		struct page *p = alloc_page(GFP_KERNEL);
 		if (!p) {
-			set_current_state(TASK_UNINTERRUPTIBLE);
-			schedule_timeout(HZ/2);
+			schedule_timeout_uninterruptible(msecs_to_jiffies(500);
 			continue;
 		}
 		rqstp->rq_argpages[rqstp->rq_arghi++] = p;


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
