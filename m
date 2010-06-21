From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] net/core/pktgen.c: Use pr_<level>
Date: Mon, 21 Jun 2010 15:29:14 -0700
Message-ID: <1277159354.1775.212.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <robert.olsson@its.uu.se>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: "David S.Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add pr_fmt(fmt) KBUILD_MODNAME ": " fmt
Remove "pktgen: " from formats
Convert printks to pr_<level>
Added func_enter() for debugging
Moved version to end of string at module_init
Coalesced long formats

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/core/pktgen.c |  142 ++++++++++++++++++++++++-----------------------------
 1 files changed, 64 insertions(+), 78 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 6428653..1ee2ebd 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -115,6 +115,9 @@
  * command by Adit Ranadive <adit.262@gmail.com>
  *
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/sys.h>
 #include <linux/types.h>
 #include <linux/module.h>
@@ -174,6 +177,8 @@
 #define MAX_MPLS_LABELS 16 /* This is the max label stack depth */
 #define MPLS_STACK_BOTTOM htonl(0x00000100)
 
+#define func_enter() pr_debug("entering %s\n", __func__);
+
 /* Device flag bits */
 #define F_IPSRC_RND   (1<<0)	/* IP-Src Random  */
 #define F_IPDST_RND   (1<<1)	/* IP-Dst Random  */
@@ -424,7 +429,8 @@ static inline int ktime_lt(const ktime_t cmp1, const ktime_t cmp2)
 }
 
 static const char version[] =
-	"pktgen " VERSION ": Packet Generator for packet performance testing.\n";
+	"Packet Generator for packet performance testing. "
+	"Version: " VERSION "\n";
 
 static int pktgen_remove_device(struct pktgen_thread *t, struct pktgen_dev *i);
 static int pktgen_add_device(struct pktgen_thread *t, const char *ifname);
@@ -495,7 +501,7 @@ static ssize_t pgctrl_write(struct file *file, const char __user *buf,
 		pktgen_reset_all_threads();
 
 	else
-		printk(KERN_WARNING "pktgen: Unknown command: %s\n", data);
+		pr_warning("Unknown command: %s\n", data);
 
 	err = count;
 
@@ -852,14 +858,14 @@ static ssize_t pktgen_if_write(struct file *file,
 	pg_result = &(pkt_dev->result[0]);
 
 	if (count < 1) {
-		printk(KERN_WARNING "pktgen: wrong command format\n");
+		pr_warning("wrong command format\n");
 		return -EINVAL;
 	}
 
 	max = count - i;
 	tmp = count_trail_chars(&user_buffer[i], max);
 	if (tmp < 0) {
-		printk(KERN_WARNING "pktgen: illegal format\n");
+		pr_warning("illegal format\n");
 		return tmp;
 	}
 	i += tmp;
@@ -990,9 +996,7 @@ static ssize_t pktgen_if_write(struct file *file,
 			return len;
 		pkt_dev->delay = pkt_dev->min_pkt_size*8*NSEC_PER_USEC/value;
 		if (debug)
-			printk(KERN_INFO
-				 "pktgen: Delay set at: %llu ns\n",
-					pkt_dev->delay);
+			pr_info("Delay set at: %llu ns\n", pkt_dev->delay);
 
 		sprintf(pg_result, "OK: rate=%lu", value);
 		return count;
@@ -1007,9 +1011,7 @@ static ssize_t pktgen_if_write(struct file *file,
 			return len;
 		pkt_dev->delay = NSEC_PER_SEC/value;
 		if (debug)
-			printk(KERN_INFO
-				 "pktgen: Delay set at: %llu ns\n",
-					pkt_dev->delay);
+			pr_info("Delay set at: %llu ns\n", pkt_dev->delay);
 
 		sprintf(pg_result, "OK: rate=%lu", value);
 		return count;
@@ -1815,7 +1817,7 @@ static ssize_t pktgen_thread_write(struct file *file,
 		       name, (unsigned long)count);
 
 	if (!t) {
-		printk(KERN_ERR "pktgen: ERROR: No thread\n");
+		pr_err("ERROR: No thread\n");
 		ret = -EINVAL;
 		goto out;
 	}
@@ -1908,7 +1910,7 @@ static void pktgen_mark_device(const char *ifname)
 	int i = 0;
 
 	mutex_lock(&pktgen_thread_lock);
-	pr_debug("pktgen: pktgen_mark_device marking %s for removal\n", ifname);
+	pr_debug("%s: marking %s for removal\n", __func__, ifname);
 
 	while (1) {
 
@@ -1917,15 +1919,14 @@ static void pktgen_mark_device(const char *ifname)
 			break;	/* success */
 
 		mutex_unlock(&pktgen_thread_lock);
-		pr_debug("pktgen: pktgen_mark_device waiting for %s "
-				"to disappear....\n", ifname);
+		pr_debug("%s: waiting for %s to disappear....\n",
+			 __func__, ifname);
 		schedule_timeout_interruptible(msecs_to_jiffies(msec_per_try));
 		mutex_lock(&pktgen_thread_lock);
 
 		if (++i >= max_tries) {
-			printk(KERN_ERR "pktgen_mark_device: timed out after "
-			       "waiting %d msec for device %s to be removed\n",
-			       msec_per_try * i, ifname);
+			pr_err("%s: timed out after waiting %d msec for device %s to be removed\n",
+			       __func__, msec_per_try * i, ifname);
 			break;
 		}
 
@@ -1952,8 +1953,8 @@ static void pktgen_change_name(struct net_device *dev)
 							  &pktgen_if_fops,
 							  pkt_dev);
 			if (!pkt_dev->entry)
-				printk(KERN_ERR "pktgen: can't move proc "
-				       " entry for '%s'\n", dev->name);
+				pr_err("can't move proc entry for '%s'\n",
+				       dev->name);
 			break;
 		}
 	}
@@ -2017,15 +2018,15 @@ static int pktgen_setup_dev(struct pktgen_dev *pkt_dev, const char *ifname)
 
 	odev = pktgen_dev_get_by_name(pkt_dev, ifname);
 	if (!odev) {
-		printk(KERN_ERR "pktgen: no such netdevice: \"%s\"\n", ifname);
+		pr_err("no such netdevice: \"%s\"\n", ifname);
 		return -ENODEV;
 	}
 
 	if (odev->type != ARPHRD_ETHER) {
-		printk(KERN_ERR "pktgen: not an ethernet device: \"%s\"\n", ifname);
+		pr_err("not an ethernet device: \"%s\"\n", ifname);
 		err = -EINVAL;
 	} else if (!netif_running(odev)) {
-		printk(KERN_ERR "pktgen: device is down: \"%s\"\n", ifname);
+		pr_err("device is down: \"%s\"\n", ifname);
 		err = -ENETDOWN;
 	} else {
 		pkt_dev->odev = odev;
@@ -2044,8 +2045,7 @@ static void pktgen_setup_inject(struct pktgen_dev *pkt_dev)
 	int ntxq;
 
 	if (!pkt_dev->odev) {
-		printk(KERN_ERR "pktgen: ERROR: pkt_dev->odev == NULL in "
-		       "setup_inject.\n");
+		pr_err("ERROR: pkt_dev->odev == NULL in setup_inject\n");
 		sprintf(pkt_dev->result,
 			"ERROR: pkt_dev->odev == NULL in setup_inject.\n");
 		return;
@@ -2055,19 +2055,15 @@ static void pktgen_setup_inject(struct pktgen_dev *pkt_dev)
 	ntxq = pkt_dev->odev->real_num_tx_queues;
 
 	if (ntxq <= pkt_dev->queue_map_min) {
-		printk(KERN_WARNING "pktgen: WARNING: Requested "
-		       "queue_map_min (zero-based) (%d) exceeds valid range "
-		       "[0 - %d] for (%d) queues on %s, resetting\n",
-		       pkt_dev->queue_map_min, (ntxq ?: 1) - 1, ntxq,
-		       pkt_dev->odevname);
+		pr_warning("WARNING: Requested queue_map_min (zero-based) (%d) exceeds valid range [0 - %d] for (%d) queues on %s, resetting\n",
+			   pkt_dev->queue_map_min, (ntxq ?: 1) - 1, ntxq,
+			   pkt_dev->odevname);
 		pkt_dev->queue_map_min = ntxq - 1;
 	}
 	if (pkt_dev->queue_map_max >= ntxq) {
-		printk(KERN_WARNING "pktgen: WARNING: Requested "
-		       "queue_map_max (zero-based) (%d) exceeds valid range "
-		       "[0 - %d] for (%d) queues on %s, resetting\n",
-		       pkt_dev->queue_map_max, (ntxq ?: 1) - 1, ntxq,
-		       pkt_dev->odevname);
+		pr_warning("WARNING: Requested queue_map_max (zero-based) (%d) exceeds valid range [0 - %d] for (%d) queues on %s, resetting\n",
+			   pkt_dev->queue_map_max, (ntxq ?: 1) - 1, ntxq,
+			   pkt_dev->odevname);
 		pkt_dev->queue_map_max = ntxq - 1;
 	}
 
@@ -2127,8 +2123,7 @@ static void pktgen_setup_inject(struct pktgen_dev *pkt_dev)
 			}
 			rcu_read_unlock();
 			if (err)
-				printk(KERN_ERR "pktgen: ERROR: IPv6 link "
-				       "address not availble.\n");
+				pr_err("ERROR: IPv6 link address not available\n");
 		}
 #endif
 	} else {
@@ -2562,8 +2557,8 @@ static int process_ipsec(struct pktgen_dev *pkt_dev,
 			if (nhead > 0) {
 				ret = pskb_expand_head(skb, nhead, 0, GFP_ATOMIC);
 				if (ret < 0) {
-					printk(KERN_ERR "Error expanding "
-					       "ipsec packet %d\n", ret);
+					pr_err("Error expanding ipsec packet %d\n",
+					       ret);
 					goto err;
 				}
 			}
@@ -2572,8 +2567,7 @@ static int process_ipsec(struct pktgen_dev *pkt_dev,
 			skb_pull(skb, ETH_HLEN);
 			ret = pktgen_output_ipsec(skb, pkt_dev);
 			if (ret) {
-				printk(KERN_ERR "Error creating ipsec "
-				       "packet %d\n", ret);
+				pr_err("Error creating ipsec packet %d\n", ret);
 				goto err;
 			}
 			/* restore ll */
@@ -3049,8 +3043,7 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 	if (datalen < sizeof(struct pktgen_hdr)) {
 		datalen = sizeof(struct pktgen_hdr);
 		if (net_ratelimit())
-			printk(KERN_INFO "pktgen: increased datalen to %d\n",
-			       datalen);
+			pr_info("increased datalen to %d\n", datalen);
 	}
 
 	udph->source = htons(pkt_dev->cur_udp_src);
@@ -3177,7 +3170,7 @@ static void pktgen_run(struct pktgen_thread *t)
 	struct pktgen_dev *pkt_dev;
 	int started = 0;
 
-	pr_debug("pktgen: entering pktgen_run. %p\n", t);
+	func_enter();
 
 	if_lock(t);
 	list_for_each_entry(pkt_dev, &t->if_list, list) {
@@ -3210,7 +3203,7 @@ static void pktgen_stop_all_threads_ifs(void)
 {
 	struct pktgen_thread *t;
 
-	pr_debug("pktgen: entering pktgen_stop_all_threads_ifs.\n");
+	func_enter();
 
 	mutex_lock(&pktgen_thread_lock);
 
@@ -3275,7 +3268,7 @@ static void pktgen_run_all_threads(void)
 {
 	struct pktgen_thread *t;
 
-	pr_debug("pktgen: entering pktgen_run_all_threads.\n");
+	func_enter();
 
 	mutex_lock(&pktgen_thread_lock);
 
@@ -3294,7 +3287,7 @@ static void pktgen_reset_all_threads(void)
 {
 	struct pktgen_thread *t;
 
-	pr_debug("pktgen: entering pktgen_reset_all_threads.\n");
+	func_enter();
 
 	mutex_lock(&pktgen_thread_lock);
 
@@ -3344,8 +3337,8 @@ static int pktgen_stop_device(struct pktgen_dev *pkt_dev)
 	int nr_frags = pkt_dev->skb ? skb_shinfo(pkt_dev->skb)->nr_frags : -1;
 
 	if (!pkt_dev->running) {
-		printk(KERN_WARNING "pktgen: interface: %s is already "
-		       "stopped\n", pkt_dev->odevname);
+		pr_warning("interface: %s is already stopped\n",
+			   pkt_dev->odevname);
 		return -EINVAL;
 	}
 
@@ -3381,7 +3374,7 @@ static void pktgen_stop(struct pktgen_thread *t)
 {
 	struct pktgen_dev *pkt_dev;
 
-	pr_debug("pktgen: entering pktgen_stop\n");
+	func_enter();
 
 	if_lock(t);
 
@@ -3401,7 +3394,7 @@ static void pktgen_rem_one_if(struct pktgen_thread *t)
 	struct list_head *q, *n;
 	struct pktgen_dev *cur;
 
-	pr_debug("pktgen: entering pktgen_rem_one_if\n");
+	func_enter();
 
 	if_lock(t);
 
@@ -3427,9 +3420,10 @@ static void pktgen_rem_all_ifs(struct pktgen_thread *t)
 	struct list_head *q, *n;
 	struct pktgen_dev *cur;
 
+	func_enter();
+
 	/* Remove all devices, free mem */
 
-	pr_debug("pktgen: entering pktgen_rem_all_ifs\n");
 	if_lock(t);
 
 	list_for_each_safe(q, n, &t->if_list) {
@@ -3511,8 +3505,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 
 		pkt_dev->skb = fill_packet(odev, pkt_dev);
 		if (pkt_dev->skb == NULL) {
-			printk(KERN_ERR "pktgen: ERROR: couldn't "
-			       "allocate skb in fill_packet.\n");
+			pr_err("ERROR: couldn't allocate skb in fill_packet\n");
 			schedule();
 			pkt_dev->clone_count--;	/* back out increment, OOM */
 			return;
@@ -3592,8 +3585,7 @@ static int pktgen_thread_worker(void *arg)
 	init_waitqueue_head(&t->queue);
 	complete(&t->start_done);
 
-	pr_debug("pktgen: starting pktgen/%d:  pid=%d\n",
-		 cpu, task_pid_nr(current));
+	pr_debug("starting pktgen/%d:  pid=%d\n", cpu, task_pid_nr(current));
 
 	set_current_state(TASK_INTERRUPTIBLE);
 
@@ -3646,13 +3638,13 @@ static int pktgen_thread_worker(void *arg)
 		set_current_state(TASK_INTERRUPTIBLE);
 	}
 
-	pr_debug("pktgen: %s stopping all device\n", t->tsk->comm);
+	pr_debug("%s stopping all device\n", t->tsk->comm);
 	pktgen_stop(t);
 
-	pr_debug("pktgen: %s removing all device\n", t->tsk->comm);
+	pr_debug("%s removing all device\n", t->tsk->comm);
 	pktgen_rem_all_ifs(t);
 
-	pr_debug("pktgen: %s removing thread.\n", t->tsk->comm);
+	pr_debug("%s removing thread\n", t->tsk->comm);
 	pktgen_rem_thread(t);
 
 	return 0;
@@ -3676,7 +3668,7 @@ static struct pktgen_dev *pktgen_find_dev(struct pktgen_thread *t,
 		}
 
 	if_unlock(t);
-	pr_debug("pktgen: find_dev(%s) returning %p\n", ifname, pkt_dev);
+	pr_debug("find_dev(%s) returning %p\n", ifname, pkt_dev);
 	return pkt_dev;
 }
 
@@ -3692,8 +3684,7 @@ static int add_dev_to_thread(struct pktgen_thread *t,
 	if_lock(t);
 
 	if (pkt_dev->pg_thread) {
-		printk(KERN_ERR "pktgen: ERROR: already assigned "
-		       "to a thread.\n");
+		pr_err("ERROR: already assigned to a thread\n");
 		rv = -EBUSY;
 		goto out;
 	}
@@ -3719,7 +3710,7 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 
 	pkt_dev = __pktgen_NN_threads(ifname, FIND);
 	if (pkt_dev) {
-		printk(KERN_ERR "pktgen: ERROR: interface already used.\n");
+		pr_err("ERROR: interface already used\n");
 		return -EBUSY;
 	}
 
@@ -3764,7 +3755,7 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 	pkt_dev->entry = proc_create_data(ifname, 0600, pg_proc_dir,
 					  &pktgen_if_fops, pkt_dev);
 	if (!pkt_dev->entry) {
-		printk(KERN_ERR "pktgen: cannot create %s/%s procfs entry.\n",
+		pr_err("cannot create %s/%s procfs entry\n",
 		       PG_PROC_DIR, ifname);
 		err = -EINVAL;
 		goto out2;
@@ -3795,8 +3786,7 @@ static int __init pktgen_create_thread(int cpu)
 	t = kzalloc_node(sizeof(struct pktgen_thread), GFP_KERNEL,
 			 cpu_to_node(cpu));
 	if (!t) {
-		printk(KERN_ERR "pktgen: ERROR: out of memory, can't "
-		       "create new thread.\n");
+		pr_err("ERROR: out of memory, can't create new thread\n");
 		return -ENOMEM;
 	}
 
@@ -3810,8 +3800,7 @@ static int __init pktgen_create_thread(int cpu)
 
 	p = kthread_create(pktgen_thread_worker, t, "kpktgend_%d", cpu);
 	if (IS_ERR(p)) {
-		printk(KERN_ERR "pktgen: kernel_thread() failed "
-		       "for cpu %d\n", t->cpu);
+		pr_err("kernel_thread() failed for cpu %d\n", t->cpu);
 		list_del(&t->th_list);
 		kfree(t);
 		return PTR_ERR(p);
@@ -3822,7 +3811,7 @@ static int __init pktgen_create_thread(int cpu)
 	pe = proc_create_data(t->tsk->comm, 0600, pg_proc_dir,
 			      &pktgen_thread_fops, t);
 	if (!pe) {
-		printk(KERN_ERR "pktgen: cannot create %s/%s procfs entry.\n",
+		pr_err("cannot create %s/%s procfs entry\n",
 		       PG_PROC_DIR, t->tsk->comm);
 		kthread_stop(p);
 		list_del(&t->th_list);
@@ -3856,11 +3845,10 @@ static int pktgen_remove_device(struct pktgen_thread *t,
 				struct pktgen_dev *pkt_dev)
 {
 
-	pr_debug("pktgen: remove_device pkt_dev=%p\n", pkt_dev);
+	pr_debug("remove_device pkt_dev=%p\n", pkt_dev);
 
 	if (pkt_dev->running) {
-		printk(KERN_WARNING "pktgen: WARNING: trying to remove a "
-		       "running interface, stopping it now.\n");
+		pr_warning("WARNING: trying to remove a running interface, stopping it now\n");
 		pktgen_stop_device(pkt_dev);
 	}
 
@@ -3891,7 +3879,7 @@ static int __init pg_init(void)
 	int cpu;
 	struct proc_dir_entry *pe;
 
-	printk(KERN_INFO "%s", version);
+	pr_info("%s", version);
 
 	pg_proc_dir = proc_mkdir(PG_PROC_DIR, init_net.proc_net);
 	if (!pg_proc_dir)
@@ -3899,8 +3887,7 @@ static int __init pg_init(void)
 
 	pe = proc_create(PGCTRL, 0600, pg_proc_dir, &pktgen_fops);
 	if (pe == NULL) {
-		printk(KERN_ERR "pktgen: ERROR: cannot create %s "
-		       "procfs entry.\n", PGCTRL);
+		pr_err("ERROR: cannot create %s procfs entry\n", PGCTRL);
 		proc_net_remove(&init_net, PG_PROC_DIR);
 		return -EINVAL;
 	}
@@ -3913,13 +3900,12 @@ static int __init pg_init(void)
 
 		err = pktgen_create_thread(cpu);
 		if (err)
-			printk(KERN_WARNING "pktgen: WARNING: Cannot create "
-			       "thread for cpu %d (%d)\n", cpu, err);
+			pr_warning("WARNING: Cannot create thread for cpu %d (%d)\n",
+				   cpu, err);
 	}
 
 	if (list_empty(&pktgen_threads)) {
-		printk(KERN_ERR "pktgen: ERROR: Initialization failed for "
-		       "all threads\n");
+		pr_err("ERROR: Initialization failed for all threads\n");
 		unregister_netdevice_notifier(&pktgen_notifier_block);
 		remove_proc_entry(PGCTRL, pg_proc_dir);
 		proc_net_remove(&init_net, PG_PROC_DIR);
