From: David Miller <davem@davemloft.net>
Subject: Re: pktgen
Date: Mon, 01 Jan 2007 20:53:26 -0800 (PST)
Message-ID: <20070101.205326.07639283.davem@davemloft.net>
References: <456F15F7.3000700@candelatech.com>
	<20061130.201423.118625277.davem@davemloft.net>
	<17775.58441.678623.396102@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, adobriyan@gmail.com, pavol.gono@gmail.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43256
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755261AbXABExc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jan 2007 23:53:32 -0500
To: Robert.Olsson@data.slu.se
In-Reply-To: <17775.58441.678623.396102@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Olsson <Robert.Olsson@data.slu.se>
Date: Fri, 1 Dec 2006 09:14:01 +0100

> 
> David Miller writes:
> 
>  > Agreed.
>  > 
>  > Robert, please fix this by using a completion so that we can
>  > wait for the threads to start up, something like this:
> 
> Included. It passes my test but Alexey and others test.

Ok, I'm going to put Robert's version of the fix into 2.6.19
and previous -stable branches.

But for 2.6.20 I'd like to do the following, based upon
Christoph's suggestion to convert to kthread.

Can folks please give this a spin?  I've tested that the
module loads and unloads properly, the threads startup
and shutdown, but that's it.

Thanks!

commit b3010a665cc33596fbf4be3fc6c3c5c80aeefb65
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Mon Jan 1 20:51:53 2007 -0800

    [PKTGEN]: Convert to kthread API.
    
    Based upon a suggestion from Christoph Hellwig.
    
    This fixes various races in module load/unload handling
    too.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 1897a3a..04d4b93 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -148,6 +148,7 @@
 #include <linux/seq_file.h>
 #include <linux/wait.h>
 #include <linux/etherdevice.h>
+#include <linux/kthread.h>
 #include <net/checksum.h>
 #include <net/ipv6.h>
 #include <net/addrconf.h>
@@ -360,8 +361,7 @@ struct pktgen_thread {
 	spinlock_t if_lock;
 	struct list_head if_list;	/* All device here */
 	struct list_head th_list;
-	int removed;
-	char name[32];
+	struct task_struct *tsk;
 	char result[512];
 	u32 max_before_softirq;	/* We'll call do_softirq to prevent starvation. */
 
@@ -1689,7 +1689,7 @@ static int pktgen_thread_show(struct seq_file *seq, void *v)
 	BUG_ON(!t);
 
 	seq_printf(seq, "Name: %s  max_before_softirq: %d\n",
-		   t->name, t->max_before_softirq);
+		   t->tsk->comm, t->max_before_softirq);
 
 	seq_printf(seq, "Running: ");
 
@@ -3112,7 +3112,7 @@ static void pktgen_rem_thread(struct pktgen_thread *t)
 {
 	/* Remove from the thread list */
 
-	remove_proc_entry(t->name, pg_proc_dir);
+	remove_proc_entry(t->tsk->comm, pg_proc_dir);
 
 	mutex_lock(&pktgen_thread_lock);
 
@@ -3260,58 +3260,40 @@ out:;
  * Main loop of the thread goes here
  */
 
-static void pktgen_thread_worker(struct pktgen_thread *t)
+static int pktgen_thread_worker(void *arg)
 {
 	DEFINE_WAIT(wait);
+	struct pktgen_thread *t = arg;
 	struct pktgen_dev *pkt_dev = NULL;
 	int cpu = t->cpu;
-	sigset_t tmpsig;
 	u32 max_before_softirq;
 	u32 tx_since_softirq = 0;
 
-	daemonize("pktgen/%d", cpu);
-
-	/* Block all signals except SIGKILL, SIGSTOP and SIGTERM */
-
-	spin_lock_irq(&current->sighand->siglock);
-	tmpsig = current->blocked;
-	siginitsetinv(&current->blocked,
-		      sigmask(SIGKILL) | sigmask(SIGSTOP) | sigmask(SIGTERM));
-
-	recalc_sigpending();
-	spin_unlock_irq(&current->sighand->siglock);
-
-	/* Migrate to the right CPU */
-	set_cpus_allowed(current, cpumask_of_cpu(cpu));
-	if (smp_processor_id() != cpu)
-		BUG();
+	BUG_ON(smp_processor_id() != cpu);
 
 	init_waitqueue_head(&t->queue);
 
-	t->control &= ~(T_TERMINATE);
-	t->control &= ~(T_RUN);
-	t->control &= ~(T_STOP);
-	t->control &= ~(T_REMDEVALL);
-	t->control &= ~(T_REMDEV);
-
 	t->pid = current->pid;
 
 	PG_DEBUG(printk("pktgen: starting pktgen/%d:  pid=%d\n", cpu, current->pid));
 
 	max_before_softirq = t->max_before_softirq;
 
-	__set_current_state(TASK_INTERRUPTIBLE);
-	mb();
+	set_current_state(TASK_INTERRUPTIBLE);
 
-	while (1) {
-
-		__set_current_state(TASK_RUNNING);
+	while (!kthread_should_stop()) {
+		pkt_dev = next_to_run(t);
 
-		/*
-		 * Get next dev to xmit -- if any.
-		 */
+		if (!pkt_dev &&
+		    (t->control & (T_STOP | T_RUN | T_REMDEVALL | T_REMDEV))
+		    == 0) {
+			prepare_to_wait(&(t->queue), &wait,
+					TASK_INTERRUPTIBLE);
+			schedule_timeout(HZ / 10);
+			finish_wait(&(t->queue), &wait);
+		}
 
-		pkt_dev = next_to_run(t);
+		__set_current_state(TASK_RUNNING);
 
 		if (pkt_dev) {
 
@@ -3329,21 +3311,8 @@ static void pktgen_thread_worker(struct pktgen_thread *t)
 					do_softirq();
 				tx_since_softirq = 0;
 			}
-		} else {
-			prepare_to_wait(&(t->queue), &wait, TASK_INTERRUPTIBLE);
-			schedule_timeout(HZ / 10);
-			finish_wait(&(t->queue), &wait);
 		}
 
-		/*
-		 * Back from sleep, either due to the timeout or signal.
-		 * We check if we have any "posted" work for us.
-		 */
-
-		if (t->control & T_TERMINATE || signal_pending(current))
-			/* we received a request to terminate ourself */
-			break;
-
 		if (t->control & T_STOP) {
 			pktgen_stop(t);
 			t->control &= ~(T_STOP);
@@ -3364,20 +3333,19 @@ static void pktgen_thread_worker(struct pktgen_thread *t)
 			t->control &= ~(T_REMDEV);
 		}
 
-		if (need_resched())
-			schedule();
+		set_current_state(TASK_INTERRUPTIBLE);
 	}
 
-	PG_DEBUG(printk("pktgen: %s stopping all device\n", t->name));
+	PG_DEBUG(printk("pktgen: %s stopping all device\n", t->tsk->comm));
 	pktgen_stop(t);
 
-	PG_DEBUG(printk("pktgen: %s removing all device\n", t->name));
+	PG_DEBUG(printk("pktgen: %s removing all device\n", t->tsk->comm));
 	pktgen_rem_all_ifs(t);
 
-	PG_DEBUG(printk("pktgen: %s removing thread.\n", t->name));
+	PG_DEBUG(printk("pktgen: %s removing thread.\n", t->tsk->comm));
 	pktgen_rem_thread(t);
 
-	t->removed = 1;
+	return 0;
 }
 
 static struct pktgen_dev *pktgen_find_dev(struct pktgen_thread *t,
@@ -3495,37 +3463,11 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 	return add_dev_to_thread(t, pkt_dev);
 }
 
-static struct pktgen_thread *__init pktgen_find_thread(const char *name)
+static int __init pktgen_create_thread(int cpu)
 {
 	struct pktgen_thread *t;
-
-	mutex_lock(&pktgen_thread_lock);
-
-	list_for_each_entry(t, &pktgen_threads, th_list)
-		if (strcmp(t->name, name) == 0) {
-			mutex_unlock(&pktgen_thread_lock);
-			return t;
-		}
-
-	mutex_unlock(&pktgen_thread_lock);
-	return NULL;
-}
-
-static int __init pktgen_create_thread(const char *name, int cpu)
-{
-	int err;
-	struct pktgen_thread *t = NULL;
 	struct proc_dir_entry *pe;
-
-	if (strlen(name) > 31) {
-		printk("pktgen: ERROR:  Thread name cannot be more than 31 characters.\n");
-		return -EINVAL;
-	}
-
-	if (pktgen_find_thread(name)) {
-		printk("pktgen: ERROR: thread: %s already exists\n", name);
-		return -EINVAL;
-	}
+	struct task_struct *p;
 
 	t = kzalloc(sizeof(struct pktgen_thread), GFP_KERNEL);
 	if (!t) {
@@ -3533,14 +3475,29 @@ static int __init pktgen_create_thread(const char *name, int cpu)
 		return -ENOMEM;
 	}
 
-	strcpy(t->name, name);
 	spin_lock_init(&t->if_lock);
 	t->cpu = cpu;
 
-	pe = create_proc_entry(t->name, 0600, pg_proc_dir);
+	INIT_LIST_HEAD(&t->if_list);
+
+	list_add_tail(&t->th_list, &pktgen_threads);
+
+	p = kthread_create(pktgen_thread_worker, t, "kpktgend_%d", cpu);
+	if (IS_ERR(p)) {
+		printk("pktgen: kernel_thread() failed for cpu %d\n", t->cpu);
+		list_del(&t->th_list);
+		kfree(t);
+		return PTR_ERR(p);
+	}
+	kthread_bind(p, cpu);
+	t->tsk = p;
+
+	pe = create_proc_entry(t->tsk->comm, 0600, pg_proc_dir);
 	if (!pe) {
 		printk("pktgen: cannot create %s/%s procfs entry.\n",
-		       PG_PROC_DIR, t->name);
+		       PG_PROC_DIR, t->tsk->comm);
+		kthread_stop(p);
+		list_del(&t->th_list);
 		kfree(t);
 		return -EINVAL;
 	}
@@ -3548,21 +3505,7 @@ static int __init pktgen_create_thread(const char *name, int cpu)
 	pe->proc_fops = &pktgen_thread_fops;
 	pe->data = t;
 
-	INIT_LIST_HEAD(&t->if_list);
-
-	list_add_tail(&t->th_list, &pktgen_threads);
-
-	t->removed = 0;
-
-	err = kernel_thread((void *)pktgen_thread_worker, (void *)t,
-			  CLONE_FS | CLONE_FILES | CLONE_SIGHAND);
-	if (err < 0) {
-		printk("pktgen: kernel_thread() failed for cpu %d\n", t->cpu);
-		remove_proc_entry(t->name, pg_proc_dir);
-		list_del(&t->th_list);
-		kfree(t);
-		return err;
-	}
+	wake_up_process(p);
 
 	return 0;
 }
@@ -3643,10 +3586,8 @@ static int __init pg_init(void)
 
 	for_each_online_cpu(cpu) {
 		int err;
-		char buf[30];
 
-		sprintf(buf, "kpktgend_%i", cpu);
-		err = pktgen_create_thread(buf, cpu);
+		err = pktgen_create_thread(cpu);
 		if (err)
 			printk("pktgen: WARNING: Cannot create thread for cpu %d (%d)\n",
 					cpu, err);
@@ -3674,9 +3615,8 @@ static void __exit pg_cleanup(void)
 
 	list_for_each_safe(q, n, &pktgen_threads) {
 		t = list_entry(q, struct pktgen_thread, th_list);
-		t->control |= (T_TERMINATE);
-
-		wait_event_interruptible_timeout(queue, (t->removed == 1), HZ);
+		kthread_stop(t->tsk);
+		kfree(t);
 	}
 
 	/* Un-register us from receiving netdevice events */
