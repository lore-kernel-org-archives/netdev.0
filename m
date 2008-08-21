From: adobriyan@gmail.com
Subject: [PATCH 15/38] netns ct: per-netns /proc/net/nf_conntrack_expect
Date: Fri, 22 Aug 2008 02:02:46 +0400
Message-ID: <20080821220246.GO31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/netfilter/nf_conntrack_expect.c |   24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -423,16 +423,18 @@ EXPORT_SYMBOL_GPL(nf_ct_expect_related);
 
 #ifdef CONFIG_PROC_FS
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
@@ -442,13 +444,14 @@ static struct hlist_node *ct_expect_get_first(struct seq_file *seq)
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
@@ -522,7 +525,7 @@ static const struct seq_operations exp_seq_ops = {
 
 static int exp_open(struct inode *inode, struct file *file)
 {
-	return seq_open_private(file, &exp_seq_ops,
+	return seq_open_net(inode, file, &exp_seq_ops,
 			sizeof(struct ct_expect_iter_state));
 }
 
@@ -531,26 +534,26 @@ static const struct file_operations exp_file_ops = {
 	.open    = exp_open,
 	.read    = seq_read,
 	.llseek  = seq_lseek,
-	.release = seq_release_private,
+	.release = seq_release_net,
 };
 #endif /* CONFIG_PROC_FS */
 
-static int exp_proc_init(void)
+static int exp_proc_init(struct net *net)
 {
 #ifdef CONFIG_PROC_FS
 	struct proc_dir_entry *proc;
 
-	proc = proc_net_fops_create(&init_net, "nf_conntrack_expect", 0440, &exp_file_ops);
+	proc = proc_net_fops_create(net, "nf_conntrack_expect", 0440, &exp_file_ops);
 	if (!proc)
 		return -ENOMEM;
 #endif /* CONFIG_PROC_FS */
 	return 0;
 }
 
-static void exp_proc_remove(void)
+static void exp_proc_remove(struct net *net)
 {
 #ifdef CONFIG_PROC_FS
-	proc_net_remove(&init_net, "nf_conntrack_expect");
+	proc_net_remove(net, "nf_conntrack_expect");
 #endif /* CONFIG_PROC_FS */
 }
 
@@ -579,7 +582,7 @@ int nf_conntrack_expect_init(struct net *net)
 	if (!nf_ct_expect_cachep)
 		goto err2;
 
-	err = exp_proc_init();
+	err = exp_proc_init(net);
 	if (err < 0)
 		goto err3;
 
@@ -596,7 +599,7 @@ err1:
 
 void nf_conntrack_expect_fini(struct net *net)
 {
-	exp_proc_remove();
+	exp_proc_remove(net);
 	kmem_cache_destroy(nf_ct_expect_cachep);
 	nf_ct_free_hashtable(net->ct.expect_hash, net->ct.expect_vmalloc,
 			     nf_ct_expect_hsize);
-- 
1.5.6.3


