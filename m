From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V2 3/3] pktgen: RCU-ify "if_list" to remove lock in
	next_to_run()
Date: Thu, 26 Jun 2014 13:16:59 +0200
Message-ID: <20140626111654.23576.89066.stgit@dragon>
References: <20140626111549.23576.90201.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>,
	Eric Dumazet <eric.dumazet@gmail.com>, zoltan.kiss@citrix.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38930 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756716AbaFZLRc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2014 07:17:32 -0400
In-Reply-To: <20140626111549.23576.90201.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The if_lock()/if_unlock() in next_to_run() adds a significant
overhead, because its called for every packet in busy loop of
pktgen_thread_worker().  (Thomas Graf originally pointed me
at this lock problem).

Removing these two "LOCK" operations should in theory save us approx
16ns (8ns x 2), as illustrated below we do save 16ns when removing
the locks and introducing RCU protection.

Performance data with CLONE_SKB==100000, TX-size=512, rx-usecs=30:
 (single CPU performance, ixgbe 10Gbit/s, E5-2630)
 * Prev   : 5684009 pps --> 175.93ns (1/5684009*10^9)
 * RCU-fix: 6272204 pps --> 159.43ns (1/6272204*10^9)
 * Diff   : +588195 pps --> -16.50ns

To understand this RCU patch, I describe the pktgen thread model
below.

In pktgen there is several kernel threads, but there is only one CPU
running each kernel thread.  Communication with the kernel threads are
done through some thread control flags.  This allow the thread to
change data structures at a know synchronization point, see main
thread func pktgen_thread_worker().

Userspace changes are communicated through proc-file writes.  There
are three types of changes, general control changes "pgctrl"
(func:pgctrl_write), thread changes "kpktgend_X"
(func:pktgen_thread_write), and interface config changes "etcX@N"
(func:pktgen_if_write).

Userspace "pgctrl" and "thread" changes are synchronized via the mutex
pktgen_thread_lock, thus only a single userspace instance can run.
The mutex is taken while the packet generator is running, by pgctrl
"start".  Thus e.g. "add_device" cannot be invoked when pktgen is
running/started.

All "pgctrl" and all "thread" changes, except thread "add_device",
communicate via the thread control flags.  The main problem is the
exception "add_device", that modifies threads "if_list" directly.

Fortunately "add_device" cannot be invoked while pktgen is running.
But there exists a race between "rem_device_all" and "add_device"
(which normally don't occur, because "rem_device_all" waits 125ms
before returning). Background'ing "rem_device_all" and running
"add_device" immediately allow the race to occur.

The race affects the threads (list of devices) "if_list".  The if_lock
is used for protecting this "if_list".  Other readers are given
lock-free access to the list under RCU read sections.

Note, interface config changes (via proc) can occur while pktgen is
running, which worries me a bit.  I'm assuming proc_remove() takes
appropriate locks, to assure no writers exists after proc_remove()
finish.

I've been running a script exercising the race condition (leading me
to fix the proc_remove order), without any issues.  The script also
exercises concurrent proc writes, while the interface config is
getting removed.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Reviewed-by: Florian Westphal <fw@strlen.de>
---

 net/core/pktgen.c |  101 +++++++++++++++++++++++++++--------------------------
 1 files changed, 52 insertions(+), 49 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index b61f553..5b05e36 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -69,8 +69,9 @@
  * for running devices in the if_list and sends packets until count is 0 it
  * also the thread checks the thread->control which is used for inter-process
  * communication. controlling process "posts" operations to the threads this
- * way. The if_lock should be possible to remove when add/rem_device is merged
- * into this too.
+ * way.
+ * The if_list is RCU protected, and the if_lock remains to protect updating
+ * of if_list, from "add_device" as it invoked from userspace (via proc write).
  *
  * By design there should only be *one* "controlling" process. In practice
  * multiple write accesses gives unpredictable result. Understood by "write"
@@ -208,7 +209,7 @@
 #define T_REMDEVALL   (1<<2)	/* Remove all devs */
 #define T_REMDEV      (1<<3)	/* Remove one dev */
 
-/* If lock -- can be removed after some work */
+/* If lock -- protects updating of if_list */
 #define   if_lock(t)           spin_lock(&(t->if_lock));
 #define   if_unlock(t)           spin_unlock(&(t->if_lock));
 
@@ -241,6 +242,7 @@ struct pktgen_dev {
 	struct proc_dir_entry *entry;	/* proc file */
 	struct pktgen_thread *pg_thread;/* the owner */
 	struct list_head list;		/* chaining in the thread's run-queue */
+	struct rcu_head	 rcu;		/* freed by RCU */
 
 	int running;		/* if false, the test will stop */
 
@@ -1737,14 +1739,14 @@ static int pktgen_thread_show(struct seq_file *seq, void *v)
 
 	seq_puts(seq, "Running: ");
 
-	if_lock(t);
-	list_for_each_entry(pkt_dev, &t->if_list, list)
+	rcu_read_lock();
+	list_for_each_entry_rcu(pkt_dev, &t->if_list, list)
 		if (pkt_dev->running)
 			seq_printf(seq, "%s ", pkt_dev->odevname);
 
 	seq_puts(seq, "\nStopped: ");
 
-	list_for_each_entry(pkt_dev, &t->if_list, list)
+	list_for_each_entry_rcu(pkt_dev, &t->if_list, list)
 		if (!pkt_dev->running)
 			seq_printf(seq, "%s ", pkt_dev->odevname);
 
@@ -1753,7 +1755,7 @@ static int pktgen_thread_show(struct seq_file *seq, void *v)
 	else
 		seq_puts(seq, "\nResult: NA\n");
 
-	if_unlock(t);
+	rcu_read_unlock();
 
 	return 0;
 }
@@ -1878,10 +1880,8 @@ static struct pktgen_dev *__pktgen_NN_threads(const struct pktgen_net *pn,
 		pkt_dev = pktgen_find_dev(t, ifname, exact);
 		if (pkt_dev) {
 			if (remove) {
-				if_lock(t);
 				pkt_dev->removal_mark = 1;
 				t->control |= T_REMDEV;
-				if_unlock(t);
 			}
 			break;
 		}
@@ -1931,7 +1931,8 @@ static void pktgen_change_name(const struct pktgen_net *pn, struct net_device *d
 	list_for_each_entry(t, &pn->pktgen_threads, th_list) {
 		struct pktgen_dev *pkt_dev;
 
-		list_for_each_entry(pkt_dev, &t->if_list, list) {
+		rcu_read_lock();
+		list_for_each_entry_rcu(pkt_dev, &t->if_list, list) {
 			if (pkt_dev->odev != dev)
 				continue;
 
@@ -1946,6 +1947,7 @@ static void pktgen_change_name(const struct pktgen_net *pn, struct net_device *d
 				       dev->name);
 			break;
 		}
+		rcu_read_unlock();
 	}
 }
 
@@ -2997,8 +2999,8 @@ static void pktgen_run(struct pktgen_thread *t)
 
 	func_enter();
 
-	if_lock(t);
-	list_for_each_entry(pkt_dev, &t->if_list, list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(pkt_dev, &t->if_list, list) {
 
 		/*
 		 * setup odev and create initial packet.
@@ -3007,18 +3009,18 @@ static void pktgen_run(struct pktgen_thread *t)
 
 		if (pkt_dev->odev) {
 			pktgen_clear_counters(pkt_dev);
-			pkt_dev->running = 1;	/* Cranke yeself! */
 			pkt_dev->skb = NULL;
 			pkt_dev->started_at = pkt_dev->next_tx = ktime_get();
 
 			set_pkt_overhead(pkt_dev);
 
 			strcpy(pkt_dev->result, "Starting");
+			pkt_dev->running = 1;	/* Cranke yeself! */
 			started++;
 		} else
 			strcpy(pkt_dev->result, "Error starting");
 	}
-	if_unlock(t);
+	rcu_read_unlock();
 	if (started)
 		t->control &= ~(T_STOP);
 }
@@ -3041,27 +3043,25 @@ static int thread_is_running(const struct pktgen_thread *t)
 {
 	const struct pktgen_dev *pkt_dev;
 
-	list_for_each_entry(pkt_dev, &t->if_list, list)
-		if (pkt_dev->running)
+	rcu_read_lock();
+	list_for_each_entry_rcu(pkt_dev, &t->if_list, list)
+		if (pkt_dev->running) {
+			rcu_read_unlock();
 			return 1;
+		}
+	rcu_read_unlock();
 	return 0;
 }
 
 static int pktgen_wait_thread_run(struct pktgen_thread *t)
 {
-	if_lock(t);
-
 	while (thread_is_running(t)) {
 
-		if_unlock(t);
-
 		msleep_interruptible(100);
 
 		if (signal_pending(current))
 			goto signal;
-		if_lock(t);
 	}
-	if_unlock(t);
 	return 1;
 signal:
 	return 0;
@@ -3166,10 +3166,10 @@ static int pktgen_stop_device(struct pktgen_dev *pkt_dev)
 		return -EINVAL;
 	}
 
+	pkt_dev->running = 0;
 	kfree_skb(pkt_dev->skb);
 	pkt_dev->skb = NULL;
 	pkt_dev->stopped_at = ktime_get();
-	pkt_dev->running = 0;
 
 	show_results(pkt_dev, nr_frags);
 
@@ -3180,9 +3180,8 @@ static struct pktgen_dev *next_to_run(struct pktgen_thread *t)
 {
 	struct pktgen_dev *pkt_dev, *best = NULL;
 
-	if_lock(t);
-
-	list_for_each_entry(pkt_dev, &t->if_list, list) {
+	rcu_read_lock();
+	list_for_each_entry_rcu(pkt_dev, &t->if_list, list) {
 		if (!pkt_dev->running)
 			continue;
 		if (best == NULL)
@@ -3190,7 +3189,8 @@ static struct pktgen_dev *next_to_run(struct pktgen_thread *t)
 		else if (ktime_compare(pkt_dev->next_tx, best->next_tx) < 0)
 			best = pkt_dev;
 	}
-	if_unlock(t);
+	rcu_read_unlock();
+
 	return best;
 }
 
@@ -3200,13 +3200,13 @@ static void pktgen_stop(struct pktgen_thread *t)
 
 	func_enter();
 
-	if_lock(t);
+	rcu_read_lock();
 
-	list_for_each_entry(pkt_dev, &t->if_list, list) {
+	list_for_each_entry_rcu(pkt_dev, &t->if_list, list) {
 		pktgen_stop_device(pkt_dev);
 	}
 
-	if_unlock(t);
+	rcu_read_unlock();
 }
 
 /*
@@ -3220,8 +3220,6 @@ static void pktgen_rem_one_if(struct pktgen_thread *t)
 
 	func_enter();
 
-	if_lock(t);
-
 	list_for_each_safe(q, n, &t->if_list) {
 		cur = list_entry(q, struct pktgen_dev, list);
 
@@ -3235,8 +3233,6 @@ static void pktgen_rem_one_if(struct pktgen_thread *t)
 
 		break;
 	}
-
-	if_unlock(t);
 }
 
 static void pktgen_rem_all_ifs(struct pktgen_thread *t)
@@ -3248,8 +3244,6 @@ static void pktgen_rem_all_ifs(struct pktgen_thread *t)
 
 	/* Remove all devices, free mem */
 
-	if_lock(t);
-
 	list_for_each_safe(q, n, &t->if_list) {
 		cur = list_entry(q, struct pktgen_dev, list);
 
@@ -3258,8 +3252,6 @@ static void pktgen_rem_all_ifs(struct pktgen_thread *t)
 
 		pktgen_remove_device(t, cur);
 	}
-
-	if_unlock(t);
 }
 
 static void pktgen_rem_thread(struct pktgen_thread *t)
@@ -3482,8 +3474,8 @@ static struct pktgen_dev *pktgen_find_dev(struct pktgen_thread *t,
 	struct pktgen_dev *p, *pkt_dev = NULL;
 	size_t len = strlen(ifname);
 
-	if_lock(t);
-	list_for_each_entry(p, &t->if_list, list)
+	rcu_read_lock();
+	list_for_each_entry_rcu(p, &t->if_list, list)
 		if (strncmp(p->odevname, ifname, len) == 0) {
 			if (p->odevname[len]) {
 				if (exact || p->odevname[len] != '@')
@@ -3493,7 +3485,7 @@ static struct pktgen_dev *pktgen_find_dev(struct pktgen_thread *t,
 			break;
 		}
 
-	if_unlock(t);
+	rcu_read_unlock();
 	pr_debug("find_dev(%s) returning %p\n", ifname, pkt_dev);
 	return pkt_dev;
 }
@@ -3507,6 +3499,12 @@ static int add_dev_to_thread(struct pktgen_thread *t,
 {
 	int rv = 0;
 
+	/* This function cannot be called concurrently, as its called
+	 * under pktgen_thread_lock mutex, but it can run from
+	 * userspace on another CPU than the kthread.  The if_lock()
+	 * is used here to sync with concurrent instances of
+	 * _rem_dev_from_if_list() invoked via kthread, which is also
+	 * updating the if_list */
 	if_lock(t);
 
 	if (pkt_dev->pg_thread) {
@@ -3515,9 +3513,9 @@ static int add_dev_to_thread(struct pktgen_thread *t,
 		goto out;
 	}
 
-	list_add(&pkt_dev->list, &t->if_list);
-	pkt_dev->pg_thread = t;
 	pkt_dev->running = 0;
+	pkt_dev->pg_thread = t;
+	list_add_rcu(&pkt_dev->list, &t->if_list);
 
 out:
 	if_unlock(t);
@@ -3672,11 +3670,13 @@ static void _rem_dev_from_if_list(struct pktgen_thread *t,
 	struct list_head *q, *n;
 	struct pktgen_dev *p;
 
+	if_lock(t);
 	list_for_each_safe(q, n, &t->if_list) {
 		p = list_entry(q, struct pktgen_dev, list);
 		if (p == pkt_dev)
-			list_del(&p->list);
+			list_del_rcu(&p->list);
 	}
+	if_unlock(t);
 }
 
 static int pktgen_remove_device(struct pktgen_thread *t,
@@ -3696,20 +3696,22 @@ static int pktgen_remove_device(struct pktgen_thread *t,
 		pkt_dev->odev = NULL;
 	}
 
-	/* And update the thread if_list */
-
-	_rem_dev_from_if_list(t, pkt_dev);
-
+	/* Remove proc before if_list entry, because add_device uses
+	 * list to determine if interface already exist, avoid race
+	 * with proc_create_data() */
 	if (pkt_dev->entry)
 		proc_remove(pkt_dev->entry);
 
+	/* And update the thread if_list */
+	_rem_dev_from_if_list(t, pkt_dev);
+
 #ifdef CONFIG_XFRM
 	free_SAs(pkt_dev);
 #endif
 	vfree(pkt_dev->flows);
 	if (pkt_dev->page)
 		put_page(pkt_dev->page);
-	kfree(pkt_dev);
+	kfree_rcu(pkt_dev, rcu);
 	return 0;
 }
 
@@ -3809,6 +3811,7 @@ static void __exit pg_cleanup(void)
 {
 	unregister_netdevice_notifier(&pktgen_notifier_block);
 	unregister_pernet_subsys(&pg_net_ops);
+	/* Don't need rcu_barrier() due to use of kfree_rcu() */
 }
 
 module_init(pg_init);
