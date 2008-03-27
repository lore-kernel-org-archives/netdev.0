From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 1/1] [NETFILTER]: Replate direct proc_fops assignment with proc_create call.
Date: Thu, 27 Mar 2008 10:20:53 +0300
Message-ID: <1206602453-11321-1-git-send-email-den@openvz.org>
Cc: netdev@vger.kernel.org, kaber@trash.net,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:53466 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752034AbYC0HUT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 03:20:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This elliminates infamous race during module loading when one could lookup
proc entry without proc_fops assigned.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/netfilter/ip_queue.c                      |    8 +++-----
 net/ipv4/netfilter/ipt_CLUSTERIP.c                 |    5 ++---
 net/ipv4/netfilter/ipt_recent.c                    |    3 +--
 .../netfilter/nf_conntrack_l3proto_ipv4_compat.c   |    7 ++-----
 net/ipv6/netfilter/ip6_queue.c                     |    8 +++-----
 net/netfilter/nf_conntrack_standalone.c            |    9 +++------
 net/netfilter/nf_log.c                             |    8 ++------
 net/netfilter/nf_queue.c                           |    7 ++-----
 net/netfilter/nfnetlink_log.c                      |    9 ++-------
 net/netfilter/nfnetlink_queue.c                    |    9 ++-------
 net/netfilter/xt_hashlimit.c                       |   16 ++++++++--------
 11 files changed, 30 insertions(+), 59 deletions(-)

diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index 500998a..719be29 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -588,11 +588,9 @@ static int __init ip_queue_init(void)
 	}
 
 #ifdef CONFIG_PROC_FS
-	proc = create_proc_entry(IPQ_PROC_FS_NAME, 0, init_net.proc_net);
-	if (proc) {
-		proc->owner = THIS_MODULE;
-		proc->proc_fops = &ip_queue_proc_fops;
-	} else {
+	proc = proc_create(IPQ_PROC_FS_NAME, 0, init_net.proc_net,
+			   &ip_queue_proc_fops);
+	if (!proc) {
 		printk(KERN_ERR "ip_queue: failed to create proc entry\n");
 		goto cleanup_ipqnl;
 	}
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 1b10f36..965b08a 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -167,14 +167,13 @@ clusterip_config_init(struct ipt_clusterip_tgt_info *i, __be32 ip,
 
 		/* create proc dir entry */
 		sprintf(buffer, "%u.%u.%u.%u", NIPQUAD(ip));
-		c->pde = create_proc_entry(buffer, S_IWUSR|S_IRUSR,
-					   clusterip_procdir);
+		c->pde = proc_create(buffer, S_IWUSR|S_IRUSR,
+				     clusterip_procdir, &clusterip_proc_fops);
 		if (!c->pde) {
 			kfree(c);
 			return NULL;
 		}
 	}
-	c->pde->proc_fops = &clusterip_proc_fops;
 	c->pde->data = c;
 #endif
 
diff --git a/net/ipv4/netfilter/ipt_recent.c b/net/ipv4/netfilter/ipt_recent.c
index 8e8f042..50e0669 100644
--- a/net/ipv4/netfilter/ipt_recent.c
+++ b/net/ipv4/netfilter/ipt_recent.c
@@ -276,12 +276,11 @@ recent_mt_check(const char *tablename, const void *ip,
 	for (i = 0; i < ip_list_hash_size; i++)
 		INIT_LIST_HEAD(&t->iphash[i]);
 #ifdef CONFIG_PROC_FS
-	t->proc = create_proc_entry(t->name, ip_list_perms, proc_dir);
+	t->proc = proc_create(t->name, ip_list_perms, proc_dir, &recent_fops);
 	if (t->proc == NULL) {
 		kfree(t);
 		goto out;
 	}
-	t->proc->proc_fops = &recent_fops;
 	t->proc->uid       = ip_list_uid;
 	t->proc->gid       = ip_list_gid;
 	t->proc->data      = t;
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
index 9668c3a..e60b885 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
@@ -395,13 +395,10 @@ int __init nf_conntrack_ipv4_compat_init(void)
 	if (!proc_exp)
 		goto err2;
 
-	proc_stat = create_proc_entry("ip_conntrack", S_IRUGO, init_net.proc_net_stat);
+	proc_stat = proc_create("ip_conntrack", S_IRUGO,
+				init_net.proc_net_stat, &ct_cpu_seq_fops);
 	if (!proc_stat)
 		goto err3;
-
-	proc_stat->proc_fops = &ct_cpu_seq_fops;
-	proc_stat->owner = THIS_MODULE;
-
 	return 0;
 
 err3:
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index a6d3062..92a36c9 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -591,11 +591,9 @@ static int __init ip6_queue_init(void)
 	}
 
 #ifdef CONFIG_PROC_FS
-	proc = create_proc_entry(IPQ_PROC_FS_NAME, 0, init_net.proc_net);
-	if (proc) {
-		proc->owner = THIS_MODULE;
-		proc->proc_fops = &ip6_queue_proc_fops;
-	} else {
+	proc = proc_create(IPQ_PROC_FS_NAME, 0, init_net.proc_net,
+			   &ip6_queue_proc_fops);
+	if (!proc) {
 		printk(KERN_ERR "ip6_queue: failed to create proc entry\n");
 		goto cleanup_ipqnl;
 	}
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index a9bf6e4..9d0b8bb 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -395,7 +395,7 @@ EXPORT_SYMBOL_GPL(nf_ct_log_invalid);
 static int __init nf_conntrack_standalone_init(void)
 {
 #ifdef CONFIG_PROC_FS
-	struct proc_dir_entry *proc, *proc_stat;
+	struct proc_dir_entry *proc;
 #endif
 	int ret = 0;
 
@@ -407,12 +407,9 @@ static int __init nf_conntrack_standalone_init(void)
 	proc = proc_net_fops_create(&init_net, "nf_conntrack", 0440, &ct_file_ops);
 	if (!proc) goto cleanup_init;
 
-	proc_stat = create_proc_entry("nf_conntrack", S_IRUGO, init_net.proc_net_stat);
-	if (!proc_stat)
+	if (!proc_create("nf_conntrack", S_IRUGO,
+			 init_net.proc_net_stat, &ct_cpu_seq_fops))
 		goto cleanup_proc;
-
-	proc_stat->proc_fops = &ct_cpu_seq_fops;
-	proc_stat->owner = THIS_MODULE;
 #endif
 #ifdef CONFIG_SYSCTL
 	nf_ct_sysctl_header = register_sysctl_paths(nf_ct_path,
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index cec9976..bc11d70 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -168,13 +168,9 @@ static const struct file_operations nflog_file_ops = {
 int __init netfilter_log_init(void)
 {
 #ifdef CONFIG_PROC_FS
-	struct proc_dir_entry *pde;
-
-	pde = create_proc_entry("nf_log", S_IRUGO, proc_net_netfilter);
-	if (!pde)
+	if (!proc_create("nf_log", S_IRUGO,
+			 proc_net_netfilter, &nflog_file_ops))
 		return -1;
-
-	pde->proc_fops = &nflog_file_ops;
 #endif
 	return 0;
 }
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index ddc80ea..bbd2689 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -348,12 +348,9 @@ static const struct file_operations nfqueue_file_ops = {
 int __init netfilter_queue_init(void)
 {
 #ifdef CONFIG_PROC_FS
-	struct proc_dir_entry *pde;
-
-	pde = create_proc_entry("nf_queue", S_IRUGO, proc_net_netfilter);
-	if (!pde)
+	if (!proc_create("nf_queue", S_IRUGO,
+			 proc_net_netfilter, &nfqueue_file_ops))
 		return -1;
-	pde->proc_fops = &nfqueue_file_ops;
 #endif
 	return 0;
 }
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index bf3f19b..b8173af 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -923,9 +923,6 @@ static const struct file_operations nful_file_ops = {
 static int __init nfnetlink_log_init(void)
 {
 	int i, status = -ENOMEM;
-#ifdef CONFIG_PROC_FS
-	struct proc_dir_entry *proc_nful;
-#endif
 
 	for (i = 0; i < INSTANCE_BUCKETS; i++)
 		INIT_HLIST_HEAD(&instance_table[i]);
@@ -943,11 +940,9 @@ static int __init nfnetlink_log_init(void)
 	}
 
 #ifdef CONFIG_PROC_FS
-	proc_nful = create_proc_entry("nfnetlink_log", 0440,
-				      proc_net_netfilter);
-	if (!proc_nful)
+	if (!proc_create("nfnetlink_log", 0440,
+			 proc_net_netfilter, &nful_file_ops))
 		goto cleanup_subsys;
-	proc_nful->proc_fops = &nful_file_ops;
 #endif
 	return status;
 
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 81fb048..2c9fe5c 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -896,9 +896,6 @@ static const struct file_operations nfqnl_file_ops = {
 static int __init nfnetlink_queue_init(void)
 {
 	int i, status = -ENOMEM;
-#ifdef CONFIG_PROC_FS
-	struct proc_dir_entry *proc_nfqueue;
-#endif
 
 	for (i = 0; i < INSTANCE_BUCKETS; i++)
 		INIT_HLIST_HEAD(&instance_table[i]);
@@ -911,11 +908,9 @@ static int __init nfnetlink_queue_init(void)
 	}
 
 #ifdef CONFIG_PROC_FS
-	proc_nfqueue = create_proc_entry("nfnetlink_queue", 0440,
-					 proc_net_netfilter);
-	if (!proc_nfqueue)
+	if (!proc_create("nfnetlink_queue", 0440,
+			 proc_net_netfilter, &nfqnl_file_ops))
 		goto cleanup_subsys;
-	proc_nfqueue->proc_fops = &nfqnl_file_ops;
 #endif
 
 	register_netdevice_notifier(&nfqnl_dev_notifier);
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 5418ce5..dc29007 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -237,14 +237,14 @@ static int htable_create_v0(struct xt_hashlimit_info *minfo, int family)
 	hinfo->family = family;
 	hinfo->rnd_initialized = 0;
 	spin_lock_init(&hinfo->lock);
-	hinfo->pde = create_proc_entry(minfo->name, 0,
-				       family == AF_INET ? hashlimit_procdir4 :
-							   hashlimit_procdir6);
+	hinfo->pde = proc_create(minfo->name, 0,
+				 family == AF_INET ? hashlimit_procdir4 :
+						     hashlimit_procdir6,
+				 &dl_file_ops);
 	if (!hinfo->pde) {
 		vfree(hinfo);
 		return -1;
 	}
-	hinfo->pde->proc_fops = &dl_file_ops;
 	hinfo->pde->data = hinfo;
 
 	setup_timer(&hinfo->timer, htable_gc, (unsigned long )hinfo);
@@ -301,14 +301,14 @@ static int htable_create(struct xt_hashlimit_mtinfo1 *minfo,
 	hinfo->rnd_initialized = 0;
 	spin_lock_init(&hinfo->lock);
 
-	hinfo->pde = create_proc_entry(minfo->name, 0,
-				       family == AF_INET ? hashlimit_procdir4 :
-							   hashlimit_procdir6);
+	hinfo->pde = proc_create(minfo->name, 0,
+				 family == AF_INET ? hashlimit_procdir4 :
+						     hashlimit_procdir6,
+				 &dl_file_ops);
 	if (hinfo->pde == NULL) {
 		vfree(hinfo);
 		return -1;
 	}
-	hinfo->pde->proc_fops = &dl_file_ops;
 	hinfo->pde->data = hinfo;
 
 	setup_timer(&hinfo->timer, htable_gc, (unsigned long)hinfo);
-- 
1.5.3.rc5

