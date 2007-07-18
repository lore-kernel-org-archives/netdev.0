From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] pktgen - define and use pktgen_dbg,err,warn,info
Date: Wed, 18 Jul 2007 16:21:00 -0700
Message-ID: <1184800861.5863.54.camel@localhost>
References: <1184796853.5863.40.camel@localhost>
	 <20070718.154950.91758269.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:4486 "EHLO Perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753334AbXGRXVK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2007 19:21:10 -0400
In-Reply-To: <20070718.154950.91758269.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-07-18 at 15:49 -0700, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Wed, 18 Jul 2007 15:14:13 -0700
> 
> > -#define VERSION  "pktgen v2.68: Packet Generator for packet performance testing.\n"
> > +#define PKTGEN_NAME    "pktgen"
> > +#define PKTGEN_VERSION "v2.68"
> > +#define PKTGEN_DESC    "Packet Generator for packet performance testing"
> > +#define PKTGEN_FULLINFO PKTGEN_NAME " " PKTGEN_VERSION ": " PKTGEN_DESC ".\n"
>  ...
> 
> > -static char version[] __initdata = VERSION;
> > -
> 
> Using PKTGEN_FULLINFO explicitly won't get that string into the
> __initdata section as the version[] will, that's why people do it that
> way with the explicit version[] array.
> 
> Please put it back, assign PKTGEN_FULLINFO to it, and use it.

Done. Here you are.

fyi:
pktgen_info(version) fails compile,
pktgen_info("%s", version) works.

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index b92a322..b8fee53 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -162,7 +162,10 @@
 #include <asm/div64.h>		/* do_div */
 #include <asm/timex.h>
 
-#define VERSION  "pktgen v2.68: Packet Generator for packet performance testing.\n"
+#define PKTGEN_NAME    "pktgen"
+#define PKTGEN_VERSION "v2.68"
+#define PKTGEN_DESC    "Packet Generator for packet performance testing"
+#define PKTGEN_FULLINFO PKTGEN_NAME " " PKTGEN_VERSION ": " PKTGEN_DESC ".\n"
 
 /* The buckets are exponential in 'width' */
 #define LAT_BUCKETS_MAX 32
@@ -370,6 +373,24 @@ struct pktgen_thread {
 	wait_queue_head_t queue;
 };
 
+#define pktgen_printk(level, format, arg...)	\
+	printk(level PKTGEN_NAME ": " format, ##arg)
+
+#ifdef DEBUG
+#define pktgen_dbg(format, arg...) pktgen_printk(KERN_DEBUG, format, ##arg)
+#else
+static inline int __attribute__ ((format (printf, 1, 2)))
+pktgen_dbg(const char *fmt, ...)
+{
+	return 0;
+}
+#endif
+
+#define pktgen_err(format, arg...) pktgen_printk(KERN_ERR, format, ##arg)
+#define pktgen_info(format, arg...) pktgen_printk(KERN_INFO, format, ##arg)
+#define pktgen_warn(format, arg...) pktgen_printk(KERN_WARNING, format, ##arg)
+#define pktgen_notice(format, arg...) pktgen_printk(KERN_NOTICE, format, ##arg)
+
 #define REMOVE 1
 #define FIND   0
 
@@ -441,7 +462,7 @@ static inline __u64 pg_div(__u64 n, __u32 base)
 {
 	__u64 tmp = n;
 	do_div(tmp, base);
-	/* printk("pktgen: pg_div, n: %llu  base: %d  rv: %llu\n",
+	/* pktgen_info("pg_div, n: %llu  base: %d  rv: %llu\n",
 	   n, base, tmp); */
 	return tmp;
 }
@@ -484,7 +505,7 @@ static inline __u64 tv_diff(const struct timeval *a, const struct timeval *b)
 
 /* old include end */
 
-static char version[] __initdata = VERSION;
+static char version[] __initdata = PKTGEN_FULLINFO;
 
 static int pktgen_remove_device(struct pktgen_thread *t, struct pktgen_dev *i);
 static int pktgen_add_device(struct pktgen_thread *t, const char *ifname);
@@ -520,7 +541,7 @@ static struct notifier_block pktgen_notifier_block = {
 
 static int pgctrl_show(struct seq_file *seq, void *v)
 {
-	seq_puts(seq, VERSION);
+	seq_puts(seq, PKTGEN_FULLINFO);
 	return 0;
 }
 
@@ -551,7 +572,7 @@ static ssize_t pgctrl_write(struct file *file, const char __user * buf,
 		pktgen_run_all_threads();
 
 	else
-		printk("pktgen: Unknown command: %s\n", data);
+		pktgen_info("Unknown command: %s\n", data);
 
 	err = count;
 
@@ -880,14 +901,14 @@ static ssize_t pktgen_if_write(struct file *file,
 	pg_result = &(pkt_dev->result[0]);
 
 	if (count < 1) {
-		printk("pktgen: wrong command format\n");
+		pktgen_err("wrong command format\n");
 		return -EINVAL;
 	}
 
 	max = count - i;
 	tmp = count_trail_chars(&user_buffer[i], max);
 	if (tmp < 0) {
-		printk("pktgen: illegal format\n");
+		pktgen_err("illegal format\n");
 		return tmp;
 	}
 	i += tmp;
@@ -915,8 +936,8 @@ static ssize_t pktgen_if_write(struct file *file,
 		if (copy_from_user(tb, user_buffer, count))
 			return -EFAULT;
 		tb[count] = 0;
-		printk("pktgen: %s,%lu  buffer -:%s:-\n", name,
-		       (unsigned long)count, tb);
+		pktgen_info("%s,%lu  buffer -:%s:-\n", name,
+			    (unsigned long)count, tb);
 	}
 
 	if (!strcmp(name, "min_pkt_size")) {
@@ -1212,8 +1233,8 @@ static ssize_t pktgen_if_write(struct file *file,
 			pkt_dev->cur_daddr = pkt_dev->daddr_min;
 		}
 		if (debug)
-			printk("pktgen: dst_min set to: %s\n",
-			       pkt_dev->dst_min);
+			pktgen_info("dst_min set to: %s\n",
+				    pkt_dev->dst_min);
 		i += len;
 		sprintf(pg_result, "OK: dst_min=%s", pkt_dev->dst_min);
 		return count;
@@ -1235,8 +1256,8 @@ static ssize_t pktgen_if_write(struct file *file,
 			pkt_dev->cur_daddr = pkt_dev->daddr_max;
 		}
 		if (debug)
-			printk("pktgen: dst_max set to: %s\n",
-			       pkt_dev->dst_max);
+			pktgen_info("dst_max set to: %s\n",
+				    pkt_dev->dst_max);
 		i += len;
 		sprintf(pg_result, "OK: dst_max=%s", pkt_dev->dst_max);
 		return count;
@@ -1258,7 +1279,7 @@ static ssize_t pktgen_if_write(struct file *file,
 		ipv6_addr_copy(&pkt_dev->cur_in6_daddr, &pkt_dev->in6_daddr);
 
 		if (debug)
-			printk("pktgen: dst6 set to: %s\n", buf);
+			pktgen_info("dst6 set to: %s\n", buf);
 
 		i += len;
 		sprintf(pg_result, "OK: dst6=%s", buf);
@@ -1281,7 +1302,7 @@ static ssize_t pktgen_if_write(struct file *file,
 		ipv6_addr_copy(&pkt_dev->cur_in6_daddr,
 			       &pkt_dev->min_in6_daddr);
 		if (debug)
-			printk("pktgen: dst6_min set to: %s\n", buf);
+			pktgen_info("dst6_min set to: %s\n", buf);
 
 		i += len;
 		sprintf(pg_result, "OK: dst6_min=%s", buf);
@@ -1302,7 +1323,7 @@ static ssize_t pktgen_if_write(struct file *file,
 		fmt_ip6(buf, pkt_dev->max_in6_daddr.s6_addr);
 
 		if (debug)
-			printk("pktgen: dst6_max set to: %s\n", buf);
+			pktgen_info("dst6_max set to: %s\n", buf);
 
 		i += len;
 		sprintf(pg_result, "OK: dst6_max=%s", buf);
@@ -1325,7 +1346,7 @@ static ssize_t pktgen_if_write(struct file *file,
 		ipv6_addr_copy(&pkt_dev->cur_in6_saddr, &pkt_dev->in6_saddr);
 
 		if (debug)
-			printk("pktgen: src6 set to: %s\n", buf);
+			pktgen_info("src6 set to: %s\n", buf);
 
 		i += len;
 		sprintf(pg_result, "OK: src6=%s", buf);
@@ -1346,8 +1367,8 @@ static ssize_t pktgen_if_write(struct file *file,
 			pkt_dev->cur_saddr = pkt_dev->saddr_min;
 		}
 		if (debug)
-			printk("pktgen: src_min set to: %s\n",
-			       pkt_dev->src_min);
+			pktgen_info("src_min set to: %s\n",
+				    pkt_dev->src_min);
 		i += len;
 		sprintf(pg_result, "OK: src_min=%s", pkt_dev->src_min);
 		return count;
@@ -1367,8 +1388,8 @@ static ssize_t pktgen_if_write(struct file *file,
 			pkt_dev->cur_saddr = pkt_dev->saddr_max;
 		}
 		if (debug)
-			printk("pktgen: src_max set to: %s\n",
-			       pkt_dev->src_max);
+			pktgen_info("src_max set to: %s\n",
+				    pkt_dev->src_max);
 		i += len;
 		sprintf(pg_result, "OK: src_max=%s", pkt_dev->src_max);
 		return count;
@@ -1497,7 +1518,7 @@ static ssize_t pktgen_if_write(struct file *file,
 			pkt_dev->svlan_id = 0xffff;
 
 			if (debug)
-				printk("pktgen: VLAN/SVLAN auto turned off\n");
+				pktgen_info("VLAN/SVLAN auto turned off\n");
 		}
 		return count;
 	}
@@ -1512,10 +1533,10 @@ static ssize_t pktgen_if_write(struct file *file,
 			pkt_dev->vlan_id = value;  /* turn on VLAN */
 
 			if (debug)
-				printk("pktgen: VLAN turned on\n");
+				pktgen_info("VLAN turned on\n");
 
 			if (debug && pkt_dev->nr_labels)
-				printk("pktgen: MPLS auto turned off\n");
+				pktgen_info("MPLS auto turned off\n");
 
 			pkt_dev->nr_labels = 0;    /* turn off MPLS */
 			sprintf(pg_result, "OK: vlan_id=%u", pkt_dev->vlan_id);
@@ -1524,7 +1545,7 @@ static ssize_t pktgen_if_write(struct file *file,
 			pkt_dev->svlan_id = 0xffff;
 
 			if (debug)
-				printk("pktgen: VLAN/SVLAN turned off\n");
+				pktgen_info("VLAN/SVLAN turned off\n");
 		}
 		return count;
 	}
@@ -1569,10 +1590,10 @@ static ssize_t pktgen_if_write(struct file *file,
 			pkt_dev->svlan_id = value;  /* turn on SVLAN */
 
 			if (debug)
-				printk("pktgen: SVLAN turned on\n");
+				pktgen_info("SVLAN turned on\n");
 
 			if (debug && pkt_dev->nr_labels)
-				printk("pktgen: MPLS auto turned off\n");
+				pktgen_info("MPLS auto turned off\n");
 
 			pkt_dev->nr_labels = 0;    /* turn off MPLS */
 			sprintf(pg_result, "OK: svlan_id=%u", pkt_dev->svlan_id);
@@ -1581,7 +1602,7 @@ static ssize_t pktgen_if_write(struct file *file,
 			pkt_dev->svlan_id = 0xffff;
 
 			if (debug)
-				printk("pktgen: VLAN/SVLAN turned off\n");
+				pktgen_info("VLAN/SVLAN turned off\n");
 		}
 		return count;
 	}
@@ -1741,10 +1762,10 @@ static ssize_t pktgen_thread_write(struct file *file,
 	i += len;
 
 	if (debug)
-		printk("pktgen: t=%s, count=%lu\n", name, (unsigned long)count);
+		pktgen_info("t=%s, count=%lu\n", name, (unsigned long)count);
 
 	if (!t) {
-		printk("pktgen: ERROR: No thread\n");
+		pktgen_err("No thread\n");
 		ret = -EINVAL;
 		goto out;
 	}
@@ -1849,15 +1870,15 @@ static void pktgen_mark_device(const char *ifname)
 			break;	/* success */
 
 		mutex_unlock(&pktgen_thread_lock);
-		pr_debug("pktgen: pktgen_mark_device waiting for %s "
-				"to disappear....\n", ifname);
+		pktgen_dbg("%s waiting for %s to disappear....\n",
+			   __FUNCTION__, ifname);
 		schedule_timeout_interruptible(msecs_to_jiffies(msec_per_try));
 		mutex_lock(&pktgen_thread_lock);
 
 		if (++i >= max_tries) {
-			printk("pktgen_mark_device: timed out after waiting "
-			       "%d msec for device %s to be removed\n",
-			       msec_per_try * i, ifname);
+			pktgen_warn("%s: timed out after waiting "
+				    "%d msec for device %s to be removed\n",
+				    __FUNCTION__, msec_per_try * i, ifname);
 			break;
 		}
 
@@ -1882,8 +1903,8 @@ static void pktgen_change_name(struct net_device *dev)
 			pkt_dev->entry = create_proc_entry(dev->name, 0600,
 							   pg_proc_dir);
 			if (!pkt_dev->entry)
-				printk(KERN_ERR "pktgen: can't move proc "
-				       " entry for '%s'\n", dev->name);
+				pktgen_err("can't move proc entry for '%s'\n",
+					   dev->name);
 			break;
 		}
 	}
@@ -1926,15 +1947,15 @@ static int pktgen_setup_dev(struct pktgen_dev *pkt_dev, const char *ifname)
 
 	odev = dev_get_by_name(ifname);
 	if (!odev) {
-		printk("pktgen: no such netdevice: \"%s\"\n", ifname);
+		pktgen_err("no such netdevice: \"%s\"\n", ifname);
 		return -ENODEV;
 	}
 
 	if (odev->type != ARPHRD_ETHER) {
-		printk("pktgen: not an ethernet device: \"%s\"\n", ifname);
+		pktgen_err("not an ethernet device: \"%s\"\n", ifname);
 		err = -EINVAL;
 	} else if (!netif_running(odev)) {
-		printk("pktgen: device is down: \"%s\"\n", ifname);
+		pktgen_err("device is down: \"%s\"\n", ifname);
 		err = -ENETDOWN;
 	} else {
 		pkt_dev->odev = odev;
@@ -1951,7 +1972,7 @@ static int pktgen_setup_dev(struct pktgen_dev *pkt_dev, const char *ifname)
 static void pktgen_setup_inject(struct pktgen_dev *pkt_dev)
 {
 	if (!pkt_dev->odev) {
-		printk("pktgen: ERROR: pkt_dev->odev == NULL in setup_inject.\n");
+		pktgen_err("pkt_dev->odev == NULL in setup_inject.\n");
 		sprintf(pkt_dev->result,
 			"ERROR: pkt_dev->odev == NULL in setup_inject.\n");
 		return;
@@ -2013,7 +2034,7 @@ static void pktgen_setup_inject(struct pktgen_dev *pkt_dev)
 			}
 			rcu_read_unlock();
 			if (err)
-				printk("pktgen: ERROR: IPv6 link address not availble.\n");
+				pktgen_err("IPv6 link address not available.\n");
 		}
 #endif
 	} else {
@@ -2057,7 +2078,8 @@ static void spin(struct pktgen_dev *pkt_dev, __u64 spin_until_us)
 	__u64 now;
 
 	start = now = getCurUs();
-	printk(KERN_INFO "sleeping for %d\n", (int)(spin_until_us - now));
+	pktgen_info("sleeping for %llu\n",
+		    (unsigned long long)(spin_until_us - now));
 	while (now < spin_until_us) {
 		/* TODO: optimize sleeping behavior */
 		if (spin_until_us - now > jiffies_to_usecs(1) + 1)
@@ -2714,8 +2736,7 @@ static struct sk_buff *fill_packet_ipv6(struct net_device *odev,
 	if (datalen < sizeof(struct pktgen_hdr)) {
 		datalen = sizeof(struct pktgen_hdr);
 		if (net_ratelimit())
-			printk(KERN_INFO "pktgen: increased datalen to %d\n",
-			       datalen);
+			pktgen_info("increased datalen to %d\n", datalen);
 	}
 
 	udph->source = htons(pkt_dev->cur_udp_src);
@@ -2998,8 +3019,8 @@ static int pktgen_stop_device(struct pktgen_dev *pkt_dev)
 	int nr_frags = pkt_dev->skb ? skb_shinfo(pkt_dev->skb)->nr_frags : -1;
 
 	if (!pkt_dev->running) {
-		printk("pktgen: interface: %s is already stopped\n",
-		       pkt_dev->odev->name);
+		pktgen_err("interface: %s is already stopped\n",
+			   pkt_dev->odev->name);
 		return -EINVAL;
 	}
 
@@ -3171,7 +3192,7 @@ static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
 
 			pkt_dev->skb = fill_packet(odev, pkt_dev);
 			if (pkt_dev->skb == NULL) {
-				printk("pktgen: ERROR: couldn't allocate skb in fill_packet.\n");
+				pktgen_err("couldn't allocate skb in fill_packet.\n");
 				schedule();
 				pkt_dev->clone_count--;	/* back out increment, OOM */
 				goto out;
@@ -3202,7 +3223,7 @@ static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
 			atomic_dec(&(pkt_dev->skb->users));
 
 			if (debug && net_ratelimit())
-				printk(KERN_INFO "pktgen: Hard xmit error\n");
+				pktgen_err("Hard xmit error\n");
 
 			pkt_dev->errors++;
 			pkt_dev->last_ok = 0;
@@ -3373,7 +3394,7 @@ static int add_dev_to_thread(struct pktgen_thread *t,
 	if_lock(t);
 
 	if (pkt_dev->pg_thread) {
-		printk("pktgen: ERROR:  already assigned to a thread.\n");
+		pktgen_err("already assigned to a thread.\n");
 		rv = -EBUSY;
 		goto out;
 	}
@@ -3398,7 +3419,7 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 
 	pkt_dev = __pktgen_NN_threads(ifname, FIND);
 	if (pkt_dev) {
-		printk("pktgen: ERROR: interface already used.\n");
+		pktgen_err("interface already used.\n");
 		return -EBUSY;
 	}
 
@@ -3440,8 +3461,8 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 
 	pkt_dev->entry = create_proc_entry(ifname, 0600, pg_proc_dir);
 	if (!pkt_dev->entry) {
-		printk("pktgen: cannot create %s/%s procfs entry.\n",
-		       PG_PROC_DIR, ifname);
+		pktgen_err("cannot create %s/%s procfs entry.\n",
+			   PG_PROC_DIR, ifname);
 		err = -EINVAL;
 		goto out2;
 	}
@@ -3466,7 +3487,7 @@ static int __init pktgen_create_thread(int cpu)
 
 	t = kzalloc(sizeof(struct pktgen_thread), GFP_KERNEL);
 	if (!t) {
-		printk("pktgen: ERROR: out of memory, can't create new thread.\n");
+		pktgen_err("out of memory, can't create new thread.\n");
 		return -ENOMEM;
 	}
 
@@ -3479,7 +3500,7 @@ static int __init pktgen_create_thread(int cpu)
 
 	p = kthread_create(pktgen_thread_worker, t, "kpktgend_%d", cpu);
 	if (IS_ERR(p)) {
-		printk("pktgen: kernel_thread() failed for cpu %d\n", t->cpu);
+		pktgen_err("kthread_create() failed for cpu %d\n", t->cpu);
 		list_del(&t->th_list);
 		kfree(t);
 		return PTR_ERR(p);
@@ -3489,8 +3510,8 @@ static int __init pktgen_create_thread(int cpu)
 
 	pe = create_proc_entry(t->tsk->comm, 0600, pg_proc_dir);
 	if (!pe) {
-		printk("pktgen: cannot create %s/%s procfs entry.\n",
-		       PG_PROC_DIR, t->tsk->comm);
+		pktgen_err("cannot create %s/%s procfs entry.\n",
+			   PG_PROC_DIR, t->tsk->comm);
 		kthread_stop(p);
 		list_del(&t->th_list);
 		kfree(t);
@@ -3525,10 +3546,11 @@ static int pktgen_remove_device(struct pktgen_thread *t,
 				struct pktgen_dev *pkt_dev)
 {
 
-	pr_debug("pktgen: remove_device pkt_dev=%p\n", pkt_dev);
+	pktgen_dbg("remove_device pkt_dev=%p\n", pkt_dev);
 
 	if (pkt_dev->running) {
-		printk("pktgen:WARNING: trying to remove a running interface, stopping it now.\n");
+		pktgen_warn("trying to remove a running interface, "
+			    "stopping it now.\n");
 		pktgen_stop_device(pkt_dev);
 	}
 
@@ -3557,7 +3579,7 @@ static int __init pg_init(void)
 	int cpu;
 	struct proc_dir_entry *pe;
 
-	printk(version);
+	pktgen_info("%s", version);
 
 	pg_proc_dir = proc_mkdir(PG_PROC_DIR, proc_net);
 	if (!pg_proc_dir)
@@ -3566,8 +3588,7 @@ static int __init pg_init(void)
 
 	pe = create_proc_entry(PGCTRL, 0600, pg_proc_dir);
 	if (pe == NULL) {
-		printk("pktgen: ERROR: cannot create %s procfs entry.\n",
-		       PGCTRL);
+		pktgen_err("cannot create %s procfs entry.\n", PGCTRL);
 		proc_net_remove(PG_PROC_DIR);
 		return -EINVAL;
 	}
@@ -3583,12 +3604,12 @@ static int __init pg_init(void)
 
 		err = pktgen_create_thread(cpu);
 		if (err)
-			printk("pktgen: WARNING: Cannot create thread for cpu %d (%d)\n",
-					cpu, err);
+			pktgen_err("Cannot create thread for cpu %d (%d)\n",
+				   cpu, err);
 	}
 
 	if (list_empty(&pktgen_threads)) {
-		printk("pktgen: ERROR: Initialization failed for all threads\n");
+		pktgen_err("Initialization failed for all threads\n");
 		unregister_netdevice_notifier(&pktgen_notifier_block);
 		remove_proc_entry(PGCTRL, pg_proc_dir);
 		proc_net_remove(PG_PROC_DIR);


