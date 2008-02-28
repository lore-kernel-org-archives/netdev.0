From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 04/15] [NETFILTER]: Use proc_create() to setup ->proc_fops
 first
Date: Thu, 28 Feb 2008 18:56:08 +0800
Message-ID: <47C69348.5090400@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63182 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752084AbYB1K6i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2008 05:58:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use proc_create() and proc_net_fops_create() to
make sure that ->proc_fops be setup before gluing
PDE to main tree.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 net/ipv4/netfilter/ip_queue.c                      |    4 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c                 |   21 ++++++++-----------
 net/ipv4/netfilter/ipt_recent.c                    |    3 +-
 .../netfilter/nf_conntrack_l3proto_ipv4_compat.c   |    4 +-
 net/ipv6/netfilter/ip6_queue.c                     |    4 +-
 net/netfilter/nf_conntrack_standalone.c            |    4 +-
 net/netfilter/nf_log.c                             |    5 +--
 net/netfilter/nf_queue.c                           |    4 +-
 net/netfilter/nfnetlink_log.c                      |    5 +--
 net/netfilter/nfnetlink_queue.c                    |    5 +--
 net/netfilter/xt_hashlimit.c                       |   16 +++++++-------
 11 files changed, 34 insertions(+), 41 deletions(-)

diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index fe05da4..c180346 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -588,10 +588,10 @@ static int __init ip_queue_init(void)
 	}
 
 #ifdef CONFIG_PROC_FS
-	proc = create_proc_entry(IPQ_PROC_FS_NAME, 0, init_net.proc_net);
+	proc = proc_net_fops_create(&init_net, IPQ_PROC_FS_NAME,
+				    0, &ip_queue_proc_fops);
 	if (proc) {
 		proc->owner = THIS_MODULE;
-		proc->proc_fops = &ip_queue_proc_fops;
 	} else {
 		printk(KERN_ERR "ip_queue: failed to create proc entry\n");
 		goto cleanup_ipqnl;
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index c6cf84c..af44818 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -162,19 +162,16 @@ clusterip_config_init(struct ipt_clusterip_tgt_info *i, __be32 ip,
 	atomic_set(&c->entries, 1);
 
 #ifdef CONFIG_PROC_FS
-	{
-		char buffer[16];
-
-		/* create proc dir entry */
-		sprintf(buffer, "%u.%u.%u.%u", NIPQUAD(ip));
-		c->pde = create_proc_entry(buffer, S_IWUSR|S_IRUSR,
-					   clusterip_procdir);
-		if (!c->pde) {
-			kfree(c);
-			return NULL;
-		}
+	char buffer[16];
+
+	/* create proc dir entry */
+	sprintf(buffer, "%u.%u.%u.%u", NIPQUAD(ip));
+	c->pde = proc_create(buffer, S_IWUSR|S_IRUSR,
+			     clusterip_procdir, &clusterip_proc_fops);
+	if (!c->pde) {
+		kfree(c);
+		return NULL;
 	}
-	c->pde->proc_fops = &clusterip_proc_fops;
 	c->pde->data = c;
 #endif
 
diff --git a/net/ipv4/netfilter/ipt_recent.c b/net/ipv4/netfilter/ipt_recent.c
index 68cbe3c..71ea597 100644
--- a/net/ipv4/netfilter/ipt_recent.c
+++ b/net/ipv4/netfilter/ipt_recent.c
@@ -274,12 +274,11 @@ recent_mt_check(const char *tablename, const void *ip,
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
index 089252e..4ca2d85 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
@@ -395,11 +395,11 @@ int __init nf_conntrack_ipv4_compat_init(void)
 	if (!proc_exp)
 		goto err2;
 
-	proc_stat = create_proc_entry("ip_conntrack", S_IRUGO, init_net.proc_net_stat);
+	proc_stat = proc_create("ip_conntrack", S_IRUGO,
+				init_net.proc_net_stat, &ct_cpu_seq_fops);
 	if (!proc_stat)
 		goto err3;
 
-	proc_stat->proc_fops = &ct_cpu_seq_fops;
 	proc_stat->owner = THIS_MODULE;
 
 	return 0;
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index cc2f9af..f351a66 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -591,10 +591,10 @@ static int __init ip6_queue_init(void)
 	}
 
 #ifdef CONFIG_PROC_FS
-	proc = create_proc_entry(IPQ_PROC_FS_NAME, 0, init_net.proc_net);
+	proc = proc_net_fops_create(&init_net, IPQ_PROC_FS_NAME,
+				    0, &ip6_queue_proc_fops);
 	if (proc) {
 		proc->owner = THIS_MODULE;
-		proc->proc_fops = &ip6_queue_proc_fops;
 	} else {
 		printk(KERN_ERR "ip6_queue: failed to create proc entry\n");
 		goto cleanup_ipqnl;
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index e88e96a..8b0916c 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -407,11 +407,11 @@ static int __init nf_conntrack_standalone_init(void)
 	proc = proc_net_fops_create(&init_net, "nf_conntrack", 0440, &ct_file_ops);
 	if (!proc) goto cleanup_init;
 
-	proc_stat = create_proc_entry("nf_conntrack", S_IRUGO, init_net.proc_net_stat);
+	proc_stat = proc_create("nf_conntrack", S_IRUGO,
+				init_net.proc_net_stat, &ct_cpu_seq_fops);
 	if (!proc_stat)
 		goto cleanup_proc;
 
-	proc_stat->proc_fops = &ct_cpu_seq_fops;
 	proc_stat->owner = THIS_MODULE;
 #endif
 #ifdef CONFIG_SYSCTL
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index cec9976..8e8b115 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -170,11 +170,10 @@ int __init netfilter_log_init(void)
 #ifdef CONFIG_PROC_FS
 	struct proc_dir_entry *pde;
 
-	pde = create_proc_entry("nf_log", S_IRUGO, proc_net_netfilter);
+	pde = proc_create("nf_log", S_IRUGO,
+			  proc_net_netfilter, &nflog_file_ops);
 	if (!pde)
 		return -1;
-
-	pde->proc_fops = &nflog_file_ops;
 #endif
 	return 0;
 }
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index bfc2928..6bfdb78 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -350,10 +350,10 @@ int __init netfilter_queue_init(void)
 #ifdef CONFIG_PROC_FS
 	struct proc_dir_entry *pde;
 
-	pde = create_proc_entry("nf_queue", S_IRUGO, proc_net_netfilter);
+	pde = proc_create("nf_queue", S_IRUGO,
+			  proc_net_netfilter, &nfqueue_file_ops);
 	if (!pde)
 		return -1;
-	pde->proc_fops = &nfqueue_file_ops;
 #endif
 	return 0;
 }
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 7efa40d..83832eb 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -941,11 +941,10 @@ static int __init nfnetlink_log_init(void)
 	}
 
 #ifdef CONFIG_PROC_FS
-	proc_nful = create_proc_entry("nfnetlink_log", 0440,
-				      proc_net_netfilter);
+	proc_nful = proc_create("nfnetlink_log", 0440,
+				proc_net_netfilter, &nful_file_ops);
 	if (!proc_nful)
 		goto cleanup_subsys;
-	proc_nful->proc_fops = &nful_file_ops;
 #endif
 	return status;
 
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 0043d3a..385dacd 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -918,11 +918,10 @@ static int __init nfnetlink_queue_init(void)
 	}
 
 #ifdef CONFIG_PROC_FS
-	proc_nfqueue = create_proc_entry("nfnetlink_queue", 0440,
-					 proc_net_netfilter);
+	proc_nfqueue = proc_create("nfnetlink_queue", 0440,
+				   proc_net_netfilter, &nfqnl_file_ops);
 	if (!proc_nfqueue)
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
WCN

