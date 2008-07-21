From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 17/31] netns ct: per-netns ip_conntrack et al
Date: Mon, 21 Jul 2008 20:45:30 +0400
Message-ID: <20080721164530.GC13390@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	dev@openvz.org, xemul@openvz.org, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, benjamin.thery@bull.net
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c |   59 ++++++++++++------
 1 file changed, 40 insertions(+), 19 deletions(-)

--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4_compat.c
@@ -33,18 +33,20 @@ seq_print_counters(struct seq_file *s,
 #endif
 
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
@@ -54,13 +56,14 @@ static struct hlist_node *ct_get_first(struct seq_file *seq)
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
@@ -170,8 +173,8 @@ static const struct seq_operations ct_seq_ops = {
 
 static int ct_open(struct inode *inode, struct file *file)
 {
-	return seq_open_private(file, &ct_seq_ops,
-			sizeof(struct ct_iter_state));
+	return seq_open_net(inode, file, &ct_seq_ops,
+			    sizeof(struct ct_iter_state));
 }
 
 static const struct file_operations ct_file_ops = {
@@ -179,21 +182,23 @@ static const struct file_operations ct_file_ops = {
 	.open    = ct_open,
 	.read    = seq_read,
 	.llseek  = seq_lseek,
-	.release = seq_release_private,
+	.release = seq_release_net,
 };
 
 /* expects */
 struct ct_expect_iter_state {
+	struct seq_net_private p;
 	unsigned int bucket;
 };
 
 static struct hlist_node *ct_expect_get_first(struct seq_file *seq)
 {
+	struct net *net = seq_file_net(seq);
 	struct ct_expect_iter_state *st = seq->private;
 	struct hlist_node *n;
 
 	for (st->bucket = 0; st->bucket < nf_ct_expect_hsize; st->bucket++) {
-		n = rcu_dereference(init_net.ct.expect_hash[st->bucket].first);
+		n = rcu_dereference(net->ct.expect_hash[st->bucket].first);
 		if (n)
 			return n;
 	}
@@ -203,13 +208,14 @@ static struct hlist_node *ct_expect_get_first(struct seq_file *seq)
 static struct hlist_node *ct_expect_get_next(struct seq_file *seq,
 					     struct hlist_node *head)
 {
+	struct net *net = seq_file_net(seq);
 	struct ct_expect_iter_state *st = seq->private;
 
 	head = rcu_dereference(head->next);
 	while (head == NULL) {
 		if (++st->bucket >= nf_ct_expect_hsize)
 			return NULL;
-		head = rcu_dereference(init_net.ct.expect_hash[st->bucket].first);
+		head = rcu_dereference(net->ct.expect_hash[st->bucket].first);
 	}
 	return head;
 }
@@ -277,8 +283,8 @@ static const struct seq_operations exp_seq_ops = {
 
 static int exp_open(struct inode *inode, struct file *file)
 {
-	return seq_open_private(file, &exp_seq_ops,
-			sizeof(struct ct_expect_iter_state));
+	return seq_open_net(inode, file, &exp_seq_ops,
+			    sizeof(struct ct_expect_iter_state));
 }
 
 static const struct file_operations ip_exp_file_ops = {
@@ -286,7 +292,7 @@ static const struct file_operations ip_exp_file_ops = {
 	.open    = exp_open,
 	.read    = seq_read,
 	.llseek  = seq_lseek,
-	.release = seq_release_private,
+	.release = seq_release_net,
 };
 
 static void *ct_cpu_seq_start(struct seq_file *seq, loff_t *pos)
@@ -377,36 +383,51 @@ static const struct file_operations ct_cpu_seq_fops = {
 	.release = seq_release,
 };
 
-int __init nf_conntrack_ipv4_compat_init(void)
+static int __net_init ip_conntrack_net_init(struct net *net)
 {
 	struct proc_dir_entry *proc, *proc_exp, *proc_stat;
 
-	proc = proc_net_fops_create(&init_net, "ip_conntrack", 0440, &ct_file_ops);
+	proc = proc_net_fops_create(net, "ip_conntrack", 0440, &ct_file_ops);
 	if (!proc)
 		goto err1;
 
-	proc_exp = proc_net_fops_create(&init_net, "ip_conntrack_expect", 0440,
+	proc_exp = proc_net_fops_create(net, "ip_conntrack_expect", 0440,
 					&ip_exp_file_ops);
 	if (!proc_exp)
 		goto err2;
 
 	proc_stat = proc_create("ip_conntrack", S_IRUGO,
-				init_net.proc_net_stat, &ct_cpu_seq_fops);
+				net->proc_net_stat, &ct_cpu_seq_fops);
 	if (!proc_stat)
 		goto err3;
 	return 0;
 
 err3:
-	proc_net_remove(&init_net, "ip_conntrack_expect");
+	proc_net_remove(net, "ip_conntrack_expect");
 err2:
-	proc_net_remove(&init_net, "ip_conntrack");
+	proc_net_remove(net, "ip_conntrack");
 err1:
 	return -ENOMEM;
 }
 
+static void __net_exit ip_conntrack_net_exit(struct net *net)
+{
+	remove_proc_entry("ip_conntrack", net->proc_net_stat);
+	proc_net_remove(net, "ip_conntrack_expect");
+	proc_net_remove(net, "ip_conntrack");
+}
+
+static struct pernet_operations ip_conntrack_net_ops = {
+	.init = ip_conntrack_net_init,
+	.exit = ip_conntrack_net_exit,
+};
+
+int __init nf_conntrack_ipv4_compat_init(void)
+{
+	return register_pernet_subsys(&ip_conntrack_net_ops);
+}
+
 void __exit nf_conntrack_ipv4_compat_fini(void)
 {
-	remove_proc_entry("ip_conntrack", init_net.proc_net_stat);
-	proc_net_remove(&init_net, "ip_conntrack_expect");
-	proc_net_remove(&init_net, "ip_conntrack");
+	unregister_pernet_subsys(&ip_conntrack_net_ops);
 }
-- 
1.5.4.5


