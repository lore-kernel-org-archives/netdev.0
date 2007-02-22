From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [take37 7/10] kevent: Signal notifications.
Date: Thu, 22 Feb 2007 16:55:05 +0300
Message-ID: <11721525052042@2ka.mipt.ru>
References: <11721525014139@2ka.mipt.ru>
Reply-To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Ingo Molnar <mingo@elte.hu>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from corega.com.ru ([195.178.208.66]:48504 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933077AbXBVNzJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 08:55:09 -0500
In-Reply-To: <11721525014139@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signal notifications.

This type of notifications allows to deliver signals through kevent queue.
One can find example application signal.c on project homepage.

If KEVENT_SIGNAL_NOMASK bit is set in raw_u64 id then signal will be
delivered only through queue, otherwise both delivery types are used - old
through update of mask of pending signals and through queue.

If signal is delivered only through kevent queue, mask of pending signals
is not updated at all, which is equal to putting signal into blocked mask,
but with delivery of that signal through kevent queue.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>


diff --git a/include/linux/sched.h b/include/linux/sched.h
index 5053dc0..49a7b53 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -82,6 +82,7 @@ struct sched_param {
 #include <linux/resource.h>
 #include <linux/timer.h>
 #include <linux/hrtimer.h>
+#include <linux/kevent_storage.h>
 #include <linux/task_io_accounting.h>
 
 #include <asm/processor.h>
@@ -1050,6 +1051,10 @@ struct task_struct {
 #ifdef	CONFIG_TASK_DELAY_ACCT
 	struct task_delay_info *delays;
 #endif
+#ifdef CONFIG_KEVENT_SIGNAL
+	struct kevent_storage st;
+	u32 kevent_signals;
+#endif
 #ifdef CONFIG_FAULT_INJECTION
 	int make_it_fail;
 #endif
diff --git a/kernel/fork.c b/kernel/fork.c
index d154cc7..606f316 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -49,6 +49,7 @@
 #include <linux/delayacct.h>
 #include <linux/taskstats_kern.h>
 #include <linux/random.h>
+#include <linux/kevent.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -118,6 +119,9 @@ void __put_task_struct(struct task_struct *tsk)
 	WARN_ON(atomic_read(&tsk->usage));
 	WARN_ON(tsk == current);
 
+#ifdef CONFIG_KEVENT_SIGNAL
+	kevent_storage_fini(&tsk->st);
+#endif
 	security_task_free(tsk);
 	free_uid(tsk->user);
 	put_group_info(tsk->group_info);
@@ -1128,6 +1132,10 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 	if (retval)
 		goto bad_fork_cleanup_namespaces;
 
+#ifdef CONFIG_KEVENT_SIGNAL
+	kevent_storage_init(p, &p->st);
+#endif
+
 	p->set_child_tid = (clone_flags & CLONE_CHILD_SETTID) ? child_tidptr : NULL;
 	/*
 	 * Clear TID on mm_release()?
diff --git a/kernel/kevent/kevent_signal.c b/kernel/kevent/kevent_signal.c
new file mode 100644
index 0000000..abe3972
--- /dev/null
+++ b/kernel/kevent/kevent_signal.c
@@ -0,0 +1,94 @@
+/*
+ * 	kevent_signal.c
+ * 
+ * 2006 Copyright (c) Evgeniy Polyakov <johnpol@2ka.mipt.ru>
+ * All rights reserved.
+ * 
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/file.h>
+#include <linux/fs.h>
+#include <linux/kevent.h>
+
+static int kevent_signal_callback(struct kevent *k)
+{
+	struct task_struct *tsk = k->st->origin;
+	int sig = k->event.id.raw[0];
+	int ret = 0;
+
+	if (sig == tsk->kevent_signals)
+		ret = 1;
+
+	if (ret && (k->event.id.raw_u64 & KEVENT_SIGNAL_NOMASK))
+		tsk->kevent_signals |= 0x80000000;
+
+	return ret;
+}
+
+int kevent_signal_enqueue(struct kevent *k)
+{
+	int err;
+
+	err = kevent_storage_enqueue(&current->st, k);
+	if (err)
+		goto err_out_exit;
+
+	if (k->event.req_flags & KEVENT_REQ_ALWAYS_QUEUE) {
+		kevent_requeue(k);
+		err = 0;
+	} else {
+		err = k->callbacks.callback(k);
+		if (err)
+			goto err_out_dequeue;
+	}
+
+	return err;
+
+err_out_dequeue:
+	kevent_storage_dequeue(k->st, k);
+err_out_exit:
+	return err;
+}
+
+int kevent_signal_dequeue(struct kevent *k)
+{
+	kevent_storage_dequeue(k->st, k);
+	return 0;
+}
+
+int kevent_signal_notify(struct task_struct *tsk, int sig)
+{
+	tsk->kevent_signals = sig;
+	kevent_storage_ready(&tsk->st, NULL, KEVENT_SIGNAL_DELIVERY);
+	return (tsk->kevent_signals & 0x80000000);
+}
+
+static int __init kevent_init_signal(void)
+{
+	struct kevent_callbacks sc = {
+		.callback = &kevent_signal_callback,
+		.enqueue = &kevent_signal_enqueue,
+		.dequeue = &kevent_signal_dequeue,
+		.flags = 0,
+	};
+
+	return kevent_add_callbacks(&sc, KEVENT_SIGNAL);
+}
+module_init(kevent_init_signal);
diff --git a/kernel/signal.c b/kernel/signal.c
index e2a7d4b..89a71a0 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -23,6 +23,7 @@
 #include <linux/ptrace.h>
 #include <linux/signal.h>
 #include <linux/capability.h>
+#include <linux/kevent.h>
 #include <linux/freezer.h>
 #include <linux/pid_namespace.h>
 #include <linux/nsproxy.h>
@@ -738,6 +739,9 @@ static int send_signal(int sig, struct siginfo *info, struct task_struct *t,
 {
 	struct sigqueue * q = NULL;
 	int ret = 0;
+	
+	if (kevent_signal_notify(t, sig))
+		return 1;
 
 	/*
 	 * fast-pathed signals for kernel-internal things like SIGSTOP
@@ -817,6 +821,17 @@ specific_send_sig_info(int sig, struct siginfo *info, struct task_struct *t)
 	ret = send_signal(sig, info, t, &t->pending);
 	if (!ret && !sigismember(&t->blocked, sig))
 		signal_wake_up(t, sig == SIGKILL);
+#ifdef CONFIG_KEVENT_SIGNAL
+	/*
+	 * Kevent allows to deliver signals through kevent queue, 
+	 * it is possible to setup kevent to not deliver
+	 * signal through the usual way, in that case send_signal()
+	 * returns 1 and signal is delivered only through kevent queue.
+	 * We simulate successfull delivery notification through this hack:
+	 */
+	if (ret == 1)
+		ret = 0;
+#endif
 out:
 	return ret;
 }
@@ -1006,6 +1021,17 @@ __group_send_sig_info(int sig, struct siginfo *info, struct task_struct *p)
 	 * to avoid several races.
 	 */
 	ret = send_signal(sig, info, p, &p->signal->shared_pending);
+#ifdef CONFIG_KEVENT_SIGNAL
+	/*
+	 * Kevent allows to deliver signals through kevent queue, 
+	 * it is possible to setup kevent to not deliver
+	 * signal through the usual way, in that case send_signal()
+	 * returns 1 and signal is delivered only through kevent queue.
+	 * We simulate successfull delivery notification through this hack:
+	 */
+	if (ret == 1)
+		ret = 0;
+#endif
 	if (unlikely(ret))
 		return ret;
 

