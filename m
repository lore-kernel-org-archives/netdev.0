From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Route cache performance under stress
Date: Tue, 17 Jun 2003 19:03:37 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <16111.18921.939537.978325@robur.slu.se>
References: <004f01c32ebe$b4bd88d0$4a00000a@badass>
	<20030609221911.GF11509@netnation.com>
	<16101.4136.328760.955758@robur.slu.se>
	<20030612.232114.71088346.davem@redhat.com>
	<16105.43543.826589.672148@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, sim@netnation.com,
	xerox@foonet.net, hadi@shell.cyberus.ca, fw@deneb.enyo.de,
	netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <16105.43543.826589.672148@robur.slu.se>
List-Id: netdev.vger.kernel.org


 > David S. Miller writes:
 > Next, we should put similar metrics into fib_hash.c

 A starting point...

 Kernel hack enclosed and companion app from:
 ftp://robur.slu.se/pub/Linux/net-development/fibstat
 
 Just some hash metrics yet. Output below is from our DoS tests:

lookup_total   == hash lookup/sec
zone_search    == zones search/sec
chain_search   == chain search/sec

lookup_total  zone_search chain_search
           0            0            0
           0            0            0
           0            0            0
      475084      4513198      2454249
      861704      8186188      4450394
      867935      8245366      4480320
      863319      8201514      4458924
      864056      8208532      4463344
      863788      8205986      4461238
      861772      8186834      4449507


--- include/net/ip_fib.h.030617	2003-06-17 15:03:57.000000000 +0200
+++ include/net/ip_fib.h	2003-06-17 16:07:00.000000000 +0200
@@ -135,6 +135,21 @@
 	unsigned char	tb_data[0];
 };
 
+struct fib_stat 
+{
+        unsigned int lookup_total;
+        unsigned int zone_search;
+        unsigned int chain_search;
+};
+
+extern struct fib_stat *fib_stat;
+#define FIB_STAT_INC(field)                                          \
+                (per_cpu_ptr(fib_stat, smp_processor_id())->field++)
+
+
+extern int __init fib_stat_init(void);
+
+
 #ifndef CONFIG_IP_MULTIPLE_TABLES
 
 extern struct fib_table *ip_fib_local_table;
--- net/ipv4/fib_hash.c.030617	2003-06-15 23:02:21.000000000 +0200
+++ net/ipv4/fib_hash.c	2003-06-17 16:01:45.000000000 +0200
@@ -13,6 +13,11 @@
  *		modify it under the terms of the GNU General Public License
  *		as published by the Free Software Foundation; either version
  *		2 of the License, or (at your option) any later version.
+ *
+ *
+ * Fixes:
+ * Robert Olsson		:	Added statistics
+ *
  */
 
 #include <linux/config.h>
@@ -107,6 +112,10 @@
 	struct fn_zone	*fn_zone_list;
 };
 
+
+struct fib_stat *fib_stat;
+
+
 static __inline__ fn_hash_idx_t fn_hash(fn_key_t key, struct fn_zone *fz)
 {
 	u32 h = ntohl(key.datum)>>(32 - fz->fz_order);
@@ -307,12 +316,19 @@
 	struct fn_zone *fz;
 	struct fn_hash *t = (struct fn_hash*)tb->tb_data;
 
+	FIB_STAT_INC(lookup_total);
+
 	read_lock(&fib_hash_lock);
 	for (fz = t->fn_zone_list; fz; fz = fz->fz_next) {
 		struct fib_node *f;
 		fn_key_t k = fz_key(flp->fl4_dst, fz);
 
+		FIB_STAT_INC(zone_search);
+
 		for (f = fz_chain(k, fz); f; f = f->fn_next) {
+
+			FIB_STAT_INC(chain_search);
+
 			if (!fn_key_eq(k, f->fn_key)) {
 				if (fn_key_leq(k, f->fn_key))
 					break;
@@ -1108,6 +1124,54 @@
 	.release	= ip_seq_release,
 };
 
+static int fib_stat_get_info(char *buffer, char **start, off_t offset, int length)
+{
+	int i;
+	int len = 0;
+
+	for (i = 0; i < NR_CPUS; i++) {
+		if (!cpu_possible(i))
+			continue;
+		len += sprintf(buffer+len, "%08x %08x %08x \n",
+			       per_cpu_ptr(fib_stat, i)->lookup_total,
+			       per_cpu_ptr(fib_stat, i)->zone_search,
+			       per_cpu_ptr(fib_stat, i)->chain_search
+
+			);
+	}
+	len -= offset;
+
+	if (len > length)
+		len = length;
+	if (len < 0)
+		len = 0;
+
+	*start = buffer + offset;
+  	return len;
+}
+
+int __init fib_stat_init(void)
+{
+	int i, rc = 0;
+
+	fib_stat = kmalloc_percpu(sizeof (struct fib_stat),
+				  GFP_KERNEL);
+	if (!fib_stat) {
+		rc = -ENOMEM;
+		goto out;
+	}
+
+	for (i = 0; i < NR_CPUS; i++) {
+		if (cpu_possible(i)) {
+			memset(per_cpu_ptr(fib_stat, i), 0,
+			       sizeof (struct fib_stat));
+		}
+	}
+	
+ out:
+	return rc;
+}
+
 int __init fib_proc_init(void)
 {
 	struct proc_dir_entry *p;
@@ -1116,13 +1180,27 @@
 	p = create_proc_entry("route", S_IRUGO, proc_net);
 	if (p)
 		p->proc_fops = &fib_seq_fops;
-	else
+	else {
+		rc = -ENOMEM;
+		goto out;
+	}
+
+
+
+        p = proc_net_create ("fib_stat", 0, fib_stat_get_info);
+
+	if (!p) {
 		rc = -ENOMEM;
+		remove_proc_entry("route", proc_net);
+	}
+
+ out:
 	return rc;
 }
 
 void __init fib_proc_exit(void)
 {
 	remove_proc_entry("route", proc_net);
+	remove_proc_entry("fib_stat", proc_net);
 }
 #endif /* CONFIG_PROC_FS */
--- net/ipv4/route.c.030617	2003-06-16 16:56:34.000000000 +0200
+++ net/ipv4/route.c	2003-06-17 16:02:41.000000000 +0200
@@ -2754,7 +2754,8 @@
 	rt_cache_stat = kmalloc_percpu(sizeof (struct rt_cache_stat),
 					GFP_KERNEL);
 	if (!rt_cache_stat) 
-		goto out_enomem1;
+		goto out_enomem0;
+
 	for (i = 0; i < NR_CPUS; i++) {
 		if (cpu_possible(i)) {
 			memset(per_cpu_ptr(rt_cache_stat, i), 0,
@@ -2765,6 +2766,9 @@
 	devinet_init();
 	ip_fib_init();
 
+	if(fib_stat_init()) 
+		goto out_enomem1;
+
 	init_timer(&rt_flush_timer);
 	rt_flush_timer.function = rt_run_flush;
 	init_timer(&rt_periodic_timer);
@@ -2785,7 +2789,7 @@
 
 #ifdef CONFIG_PROC_FS
 	if (rt_cache_proc_init())
-		goto out_enomem;
+		goto out_enomem2;
 	proc_net_create ("rt_cache_stat", 0, rt_cache_stat_get_info);
 #ifdef CONFIG_NET_CLS_ROUTE
 	create_proc_read_entry("net/rt_acct", 0, 0, ip_rt_acct_read, NULL);
@@ -2795,9 +2799,12 @@
 	xfrm4_init();
 out:
 	return rc;
-out_enomem:
-	kfree_percpu(rt_cache_stat);
+
+out_enomem2:
+	kfree_percpu(fib_stat);
 out_enomem1:
+	kfree_percpu(rt_cache_stat);
+out_enomem0:
 	rc = -ENOMEM;
 	goto out;
 }


Cheers.
					--ro
