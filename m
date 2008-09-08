From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 09/33] netns ct: per-netns /proc/net/nf_conntrack, /proc/net/stat/nf_conntrack
Date: Mon,  8 Sep 2008 07:02:46 +0400
Message-ID: <1220842990-30500-9-git-send-email-adobriyan@gmail.com>
References: <48C01046.2070704@trash.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.190]:60034 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752387AbYIHDB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2008 23:01:56 -0400
Received: by mu-out-0910.google.com with SMTP id g7so1162882muf.1
        for <netdev@vger.kernel.org>; Sun, 07 Sep 2008 20:01:55 -0700 (PDT)
In-Reply-To: <48C01046.2070704@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 5456e4b..02eaf87 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -40,18 +40,20 @@ print_tuple(struct seq_file *s, const struct nf_conntrack_tuple *tuple,
 EXPORT_SYMBOL_GPL(print_tuple);
 
 struct ct_iter_state {
+	struct seq_net_private p;
 	unsigned int bucket;
 };
 
 static struct hlist_node *ct_get_first(struct seq_file *seq)
 {
+	struct net *net = seq_file_net(seq);
 	struct ct_iter_state *st = seq->private;
 	struct hlist_node *n;
 
 	for (st->bucket = 0;
 	     st->bucket < nf_conntrack_htable_size;
 	     st->bucket++) {
-		n = rcu_dereference(init_net.ct.hash[st->bucket].first);
+		n = rcu_dereference(net->ct.hash[st->bucket].first);
 		if (n)
 			return n;
 	}
@@ -61,13 +63,14 @@ static struct hlist_node *ct_get_first(struct seq_file *seq)
 static struct hlist_node *ct_get_next(struct seq_file *seq,
 				      struct hlist_node *head)
 {
+	struct net *net = seq_file_net(seq);
 	struct ct_iter_state *st = seq->private;
 
 	head = rcu_dereference(head->next);
 	while (head == NULL) {
 		if (++st->bucket >= nf_conntrack_htable_size)
 			return NULL;
-		head = rcu_dereference(init_net.ct.hash[st->bucket].first);
+		head = rcu_dereference(net->ct.hash[st->bucket].first);
 	}
 	return head;
 }
@@ -177,7 +180,7 @@ static const struct seq_operations ct_seq_ops = {
 
 static int ct_open(struct inode *inode, struct file *file)
 {
-	return seq_open_private(file, &ct_seq_ops,
+	return seq_open_net(inode, file, &ct_seq_ops,
 			sizeof(struct ct_iter_state));
 }
 
@@ -186,7 +189,7 @@ static const struct file_operations ct_file_ops = {
 	.open    = ct_open,
 	.read    = seq_read,
 	.llseek  = seq_lseek,
-	.release = seq_release_private,
+	.release = seq_release_net,
 };
 
 static void *ct_cpu_seq_start(struct seq_file *seq, loff_t *pos)
@@ -277,38 +280,38 @@ static const struct file_operations ct_cpu_seq_fops = {
 	.release = seq_release,
 };
 
-static int nf_conntrack_standalone_init_proc(void)
+static int nf_conntrack_standalone_init_proc(struct net *net)
 {
 	struct proc_dir_entry *pde;
 
-	pde = proc_net_fops_create(&init_net, "nf_conntrack", 0440, &ct_file_ops);
+	pde = proc_net_fops_create(net, "nf_conntrack", 0440, &ct_file_ops);
 	if (!pde)
 		goto out_nf_conntrack;
 
-	pde = proc_create("nf_conntrack", S_IRUGO, init_net.proc_net_stat,
+	pde = proc_create("nf_conntrack", S_IRUGO, net->proc_net_stat,
 			  &ct_cpu_seq_fops);
 	if (!pde)
 		goto out_stat_nf_conntrack;
 	return 0;
 
 out_stat_nf_conntrack:
-	proc_net_remove(&init_net, "nf_conntrack");
+	proc_net_remove(net, "nf_conntrack");
 out_nf_conntrack:
 	return -ENOMEM;
 }
 
-static void nf_conntrack_standalone_fini_proc(void)
+static void nf_conntrack_standalone_fini_proc(struct net *net)
 {
-	remove_proc_entry("nf_conntrack", init_net.proc_net_stat);
-	proc_net_remove(&init_net, "nf_conntrack");
+	remove_proc_entry("nf_conntrack", net->proc_net_stat);
+	proc_net_remove(net, "nf_conntrack");
 }
 #else
-static int nf_conntrack_standalone_init_proc(void)
+static int nf_conntrack_standalone_init_proc(struct net *net)
 {
 	return 0;
 }
 
-static void nf_conntrack_standalone_fini_proc(void)
+static void nf_conntrack_standalone_fini_proc(struct net *net)
 {
 }
 #endif /* CONFIG_PROC_FS */
@@ -442,11 +445,25 @@ static void nf_conntrack_standalone_fini_sysctl(void)
 
 static int nf_conntrack_net_init(struct net *net)
 {
-	return nf_conntrack_init(net);
+	int ret;
+
+	ret = nf_conntrack_init(net);
+	if (ret < 0)
+		goto out_init;
+	ret = nf_conntrack_standalone_init_proc(net);
+	if (ret < 0)
+		goto out_proc;
+	return 0;
+
+out_proc:
+	nf_conntrack_cleanup(net);
+out_init:
+	return ret;
 }
 
 static void nf_conntrack_net_exit(struct net *net)
 {
+	nf_conntrack_standalone_fini_proc(net);
 	nf_conntrack_cleanup(net);
 }
 
@@ -462,17 +479,12 @@ static int __init nf_conntrack_standalone_init(void)
 	ret = register_pernet_subsys(&nf_conntrack_net_ops);
 	if (ret < 0)
 		goto out;
-	ret = nf_conntrack_standalone_init_proc();
-	if (ret < 0)
-		goto out_proc;
 	ret = nf_conntrack_standalone_init_sysctl();
 	if (ret < 0)
 		goto out_sysctl;
 	return 0;
 
 out_sysctl:
-	nf_conntrack_standalone_fini_proc();
-out_proc:
 	unregister_pernet_subsys(&nf_conntrack_net_ops);
 out:
 	return ret;
@@ -481,7 +493,6 @@ out:
 static void __exit nf_conntrack_standalone_fini(void)
 {
 	nf_conntrack_standalone_fini_sysctl();
-	nf_conntrack_standalone_fini_proc();
 	unregister_pernet_subsys(&nf_conntrack_net_ops);
 }
 
