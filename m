From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-2.6.25 11/19] [NETNS] Show routing information from correct namespace (fib_hash.c)
Date: Wed, 19 Dec 2007 18:24:41 +0300
Message-ID: <1198077889-10693-12-git-send-email-den@openvz.org>
References: <4769370F.5020303@openvz.org>
Cc: benjamin.thery@bull.net, dlezcano@fr.ibm.com, devel@openvz.org,
	containers@lists.osdl.org, netdev@vger.kernel.org, xemul@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:65234 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755176AbXLSPXJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2007 10:23:09 -0500
In-Reply-To: <4769370F.5020303@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the second part (for the CONFIG_IP_FIB_HASH case) of the patch #4,
where we have created proc files in namespaces.

Now we can dump correct info in them.

Acked-by: Benjamin Thery <benjamin.thery@bull.net>
Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/fib_hash.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
index 75c1bde..3bb3a0a 100644
--- a/net/ipv4/fib_hash.c
+++ b/net/ipv4/fib_hash.c
@@ -782,6 +782,7 @@ struct fib_table *fib_hash_init(u32 id)
 #ifdef CONFIG_PROC_FS
 
 struct fib_iter_state {
+	struct seq_net_private p;
 	struct fn_zone	*zone;
 	int		bucket;
 	struct hlist_head *hash_head;
@@ -795,8 +796,11 @@ struct fib_iter_state {
 static struct fib_alias *fib_get_first(struct seq_file *seq)
 {
 	struct fib_iter_state *iter = seq->private;
-	struct fib_table *main_table = fib_get_table(&init_net, RT_TABLE_MAIN);
-	struct fn_hash *table = (struct fn_hash *)main_table->tb_data;
+	struct fib_table *main_table;
+	struct fn_hash *table;
+
+	main_table = fib_get_table(iter->p.net, RT_TABLE_MAIN);
+	table = (struct fn_hash *)main_table->tb_data;
 
 	iter->bucket    = 0;
 	iter->hash_head = NULL;
@@ -932,10 +936,11 @@ static struct fib_alias *fib_get_idx(struct seq_file *seq, loff_t pos)
 
 static void *fib_seq_start(struct seq_file *seq, loff_t *pos)
 {
+	struct fib_iter_state *iter = seq->private;
 	void *v = NULL;
 
 	read_lock(&fib_hash_lock);
-	if (fib_get_table(&init_net, RT_TABLE_MAIN))
+	if (fib_get_table(iter->p.net, RT_TABLE_MAIN))
 		v = *pos ? fib_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
 	return v;
 }
@@ -1022,8 +1027,8 @@ static const struct seq_operations fib_seq_ops = {
 
 static int fib_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open_private(file, &fib_seq_ops,
-			sizeof(struct fib_iter_state));
+	return seq_open_net(inode, file, &fib_seq_ops,
+			    sizeof(struct fib_iter_state));
 }
 
 static const struct file_operations fib_seq_fops = {
@@ -1031,7 +1036,7 @@ static const struct file_operations fib_seq_fops = {
 	.open           = fib_seq_open,
 	.read           = seq_read,
 	.llseek         = seq_lseek,
-	.release	= seq_release_private,
+	.release	= seq_release_net,
 };
 
 int __net_init fib_proc_init(struct net *net)
-- 
1.5.3.rc5

