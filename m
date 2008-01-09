From: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH net-2.6.25 11/19] [NETNS] Show routing information from
	correct namespace (fib_hash.c)
Date: Wed,  9 Jan 2008 21:04:32 +0300
Message-ID: <1199901880-6812-11-git-send-email-den@openvz.org>
References: <47850C57.60907@openvz.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org,
        benjamin.thery-6ktuUTfB/bM@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47850C57.60907-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is the second part (for the CONFIG_IP_FIB_HASH case) of the patch #4,
where we have created proc files in namespaces.

Now we can dump correct info in them.

Acked-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>
Acked-by: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Denis V. Lunev <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
---
 net/ipv4/fib_hash.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
index fb61ca9..c9f1f73 100644
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
@@ -933,10 +937,11 @@ static struct fib_alias *fib_get_idx(struct seq_file *seq, loff_t pos)
 static void *fib_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(fib_hash_lock)
 {
+	struct fib_iter_state *iter = seq->private;
 	void *v = NULL;
 
 	read_lock(&fib_hash_lock);
-	if (fib_get_table(&init_net, RT_TABLE_MAIN))
+	if (fib_get_table(iter->p.net, RT_TABLE_MAIN))
 		v = *pos ? fib_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
 	return v;
 }
@@ -1024,8 +1029,8 @@ static const struct seq_operations fib_seq_ops = {
 
 static int fib_seq_open(struct inode *inode, struct file *file)
 {
-	return seq_open_private(file, &fib_seq_ops,
-			sizeof(struct fib_iter_state));
+	return seq_open_net(inode, file, &fib_seq_ops,
+			    sizeof(struct fib_iter_state));
 }
 
 static const struct file_operations fib_seq_fops = {
@@ -1033,7 +1038,7 @@ static const struct file_operations fib_seq_fops = {
 	.open           = fib_seq_open,
 	.read           = seq_read,
 	.llseek         = seq_lseek,
-	.release	= seq_release_private,
+	.release	= seq_release_net,
 };
 
 int __net_init fib_proc_init(struct net *net)
