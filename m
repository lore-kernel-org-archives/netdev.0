From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] IPV4 route cache /proc interface cleanup
Date: Thu, 21 Aug 2003 16:30:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030821163019.66cfe65c.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch to 2.6.0-test3 uses seq_file for /proc/net/rt_cache_stat
Someone else already did the hard one /proc/net/rt_cache

Couple of other little nits:
* use proc_net_fops_create to setup
* collapse two_line setup functions into the init routine
* proc_exit routine was never called and can go. 
* cleaner to refer to proc_net as base rather than net/rt_acct

Tested and output format is same as before on my SMP machine

diff -Nru a/net/ipv4/route.c b/net/ipv4/route.c
--- a/net/ipv4/route.c	Thu Aug 21 16:21:04 2003
+++ b/net/ipv4/route.c	Thu Aug 21 16:21:04 2003
@@ -312,49 +312,6 @@
   	return 0;
 }
 
-static int rt_cache_stat_get_info(char *buffer, char **start, off_t offset, int length)
-{
-	unsigned int dst_entries = atomic_read(&ipv4_dst_ops.entries);
-	int i;
-	int len = 0;
-
-	for (i = 0; i < NR_CPUS; i++) {
-		if (!cpu_possible(i))
-			continue;
-		len += sprintf(buffer+len, "%08x  %08x %08x %08x %08x %08x %08x %08x  %08x %08x %08x %08x %08x %08x %08x %08x %08x \n",
-			       dst_entries,		       
-			       per_cpu_ptr(rt_cache_stat, i)->in_hit,
-			       per_cpu_ptr(rt_cache_stat, i)->in_slow_tot,
-			       per_cpu_ptr(rt_cache_stat, i)->in_slow_mc,
-			       per_cpu_ptr(rt_cache_stat, i)->in_no_route,
-			       per_cpu_ptr(rt_cache_stat, i)->in_brd,
-			       per_cpu_ptr(rt_cache_stat, i)->in_martian_dst,
-			       per_cpu_ptr(rt_cache_stat, i)->in_martian_src,
-
-			       per_cpu_ptr(rt_cache_stat, i)->out_hit,
-			       per_cpu_ptr(rt_cache_stat, i)->out_slow_tot,
-			       per_cpu_ptr(rt_cache_stat, i)->out_slow_mc, 
-
-			       per_cpu_ptr(rt_cache_stat, i)->gc_total,
-			       per_cpu_ptr(rt_cache_stat, i)->gc_ignored,
-			       per_cpu_ptr(rt_cache_stat, i)->gc_goal_miss,
-			       per_cpu_ptr(rt_cache_stat, i)->gc_dst_overflow,
-			       per_cpu_ptr(rt_cache_stat, i)->in_hlist_search,
-			       per_cpu_ptr(rt_cache_stat, i)->out_hlist_search
-
-			);
-	}
-	len -= offset;
-
-	if (len > length)
-		len = length;
-	if (len < 0)
-		len = 0;
-
-	*start = buffer + offset;
-  	return len;
-}
-
 static struct seq_operations rt_cache_seq_ops = {
 	.start  = rt_cache_seq_start,
 	.next   = rt_cache_seq_next,
@@ -391,22 +348,89 @@
 	.release = seq_release_private,
 };
 
-int __init rt_cache_proc_init(void)
+
+static void *rt_cpu_seq_start(struct seq_file *seq, loff_t *pos)
 {
-	int rc = 0;
-	struct proc_dir_entry *p = create_proc_entry("rt_cache", S_IRUGO,
-						     proc_net);
-	if (p)
-		p->proc_fops = &rt_cache_seq_fops;
-	else
-		rc = -ENOMEM;
-	return rc;
+	int cpu;
+
+	for (cpu = *pos; cpu < NR_CPUS; ++cpu) {
+		if (!cpu_possible(cpu))
+			continue;
+		*pos = cpu;
+		return per_cpu_ptr(rt_cache_stat, cpu);
+	}
+	return NULL;
+}
+
+static void *rt_cpu_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	int cpu;
+
+	for (cpu = *pos + 1; cpu < NR_CPUS; ++cpu) {
+		if (!cpu_possible(cpu))
+			continue;
+		*pos = cpu;
+		return per_cpu_ptr(rt_cache_stat, cpu);
+	}
+	return NULL;
+	
 }
 
-void __init rt_cache_proc_exit(void)
+static void rt_cpu_seq_stop(struct seq_file *seq, void *v)
 {
-	remove_proc_entry("rt_cache", proc_net);
+
 }
+
+static int rt_cpu_seq_show(struct seq_file *seq, void *v)
+{
+	struct rt_cache_stat *st = v;
+	
+	seq_printf(seq,"%08x  %08x %08x %08x %08x %08x %08x %08x "
+		   " %08x %08x %08x %08x %08x %08x %08x %08x %08x \n",
+		   atomic_read(&ipv4_dst_ops.entries),
+		   st->in_hit,
+		   st->in_slow_tot,
+		   st->in_slow_mc,
+		   st->in_no_route,
+		   st->in_brd,
+		   st->in_martian_dst,
+		   st->in_martian_src,
+
+		   st->out_hit,
+		   st->out_slow_tot,
+		   st->out_slow_mc, 
+
+		   st->gc_total,
+		   st->gc_ignored,
+		   st->gc_goal_miss,
+		   st->gc_dst_overflow,
+		   st->in_hlist_search,
+		   st->out_hlist_search
+		);
+	return 0;
+}
+
+static struct seq_operations rt_cpu_seq_ops = {
+	.start  = rt_cpu_seq_start,
+	.next   = rt_cpu_seq_next,
+	.stop   = rt_cpu_seq_stop,
+	.show   = rt_cpu_seq_show,
+};
+
+
+static int rt_cpu_seq_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &rt_cpu_seq_ops);
+}
+
+static struct file_operations rt_cpu_seq_fops = {
+	.owner	 = THIS_MODULE,
+	.open	 = rt_cpu_seq_open,
+	.read	 = seq_read,
+	.llseek	 = seq_lseek,
+	.release = seq_release_private,
+};
+
 #endif /* CONFIG_PROC_FS */
   
 static __inline__ void rt_free(struct rtable *rt)
@@ -2779,11 +2803,12 @@
 	add_timer(&rt_secret_timer);
 
 #ifdef CONFIG_PROC_FS
-	if (rt_cache_proc_init())
+	if (!proc_net_fops_create("rt_cache", S_IRUGO, &rt_cache_seq_fops) ||
+	    !proc_net_fops_create("rt_cache_stat", S_IRUGO, &rt_cpu_seq_fops))
 		goto out_enomem;
-	proc_net_create ("rt_cache_stat", 0, rt_cache_stat_get_info);
+
 #ifdef CONFIG_NET_CLS_ROUTE
-	create_proc_read_entry("net/rt_acct", 0, 0, ip_rt_acct_read, NULL);
+	create_proc_read_entry("rt_acct", proc_net, 0, ip_rt_acct_read, NULL);
 #endif
 #endif
 #ifdef CONFIG_XFRM
