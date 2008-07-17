From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 16/16] proc: consolidate per-net single-release callers
Date: Thu, 17 Jul 2008 17:43:03 +0400
Message-ID: <487F4C67.2060408@openvz.org>
References: <487F46CD.7090103@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:39408 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753689AbYGQNnI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 09:43:08 -0400
In-Reply-To: <487F46CD.7090103@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

They are symmetrical to single_open ones :)

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 fs/proc/proc_net.c           |    8 ++++++++
 include/linux/seq_file_net.h |    1 +
 net/ipv4/fib_trie.c          |    9 +--------
 net/ipv4/proc.c              |   30 +++---------------------------
 net/ipv6/proc.c              |   10 +---------
 net/ipv6/route.c             |   20 ++------------------
 6 files changed, 16 insertions(+), 62 deletions(-)

diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index ab232ad..b224a28 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -87,6 +87,14 @@ int seq_release_net(struct inode *ino, struct file *f)
 }
 EXPORT_SYMBOL_GPL(seq_release_net);
 
+int single_release_net(struct inode *ino, struct file *f)
+{
+	struct seq_file *seq = f->private_data;
+	put_net(seq->private);
+	return single_release(ino, f);
+}
+EXPORT_SYMBOL_GPL(single_release_net);
+
 static struct net *get_proc_task_net(struct inode *dir)
 {
 	struct task_struct *task;
diff --git a/include/linux/seq_file_net.h b/include/linux/seq_file_net.h
index 87dcc0e..32c89bb 100644
--- a/include/linux/seq_file_net.h
+++ b/include/linux/seq_file_net.h
@@ -17,6 +17,7 @@ int seq_open_net(struct inode *, struct file *,
 int single_open_net(struct inode *, struct file *file,
 		int (*show)(struct seq_file *, void *));
 int seq_release_net(struct inode *, struct file *);
+int single_release_net(struct inode *, struct file *);
 static inline struct net *seq_file_net(struct seq_file *seq)
 {
 #ifdef CONFIG_NET_NS
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 6009df2..5cb7278 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -2254,19 +2254,12 @@ static int fib_triestat_seq_open(struct inode *inode, struct file *file)
 	return single_open_net(inode, file, fib_triestat_seq_show);
 }
 
-static int fib_triestat_seq_release(struct inode *ino, struct file *f)
-{
-	struct seq_file *seq = f->private_data;
-	put_net(seq->private);
-	return single_release(ino, f);
-}
-
 static const struct file_operations fib_triestat_fops = {
 	.owner	= THIS_MODULE,
 	.open	= fib_triestat_seq_open,
 	.read	= seq_read,
 	.llseek	= seq_lseek,
-	.release = fib_triestat_seq_release,
+	.release = single_release_net,
 };
 
 static struct node *fib_trie_get_idx(struct seq_file *seq, loff_t pos)
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index daf5d3c..834356e 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -74,20 +74,12 @@ static int sockstat_seq_open(struct inode *inode, struct file *file)
 	return single_open_net(inode, file, sockstat_seq_show);
 }
 
-static int sockstat_seq_release(struct inode *inode, struct file *file)
-{
-	struct net *net = ((struct seq_file *)file->private_data)->private;
-
-	put_net(net);
-	return single_release(inode, file);
-}
-
 static const struct file_operations sockstat_seq_fops = {
 	.owner	 = THIS_MODULE,
 	.open	 = sockstat_seq_open,
 	.read	 = seq_read,
 	.llseek	 = seq_lseek,
-	.release = sockstat_seq_release,
+	.release = single_release_net,
 };
 
 /* snmp items */
@@ -383,20 +375,12 @@ static int snmp_seq_open(struct inode *inode, struct file *file)
 	return single_open_net(inode, file, snmp_seq_show);
 }
 
-static int snmp_seq_release(struct inode *inode, struct file *file)
-{
-	struct net *net = ((struct seq_file *)file->private_data)->private;
-
-	put_net(net);
-	return single_release(inode, file);
-}
-
 static const struct file_operations snmp_seq_fops = {
 	.owner	 = THIS_MODULE,
 	.open	 = snmp_seq_open,
 	.read	 = seq_read,
 	.llseek	 = seq_lseek,
-	.release = snmp_seq_release,
+	.release = single_release_net,
 };
 
 
@@ -438,20 +422,12 @@ static int netstat_seq_open(struct inode *inode, struct file *file)
 	return single_open_net(inode, file, netstat_seq_show);
 }
 
-static int netstat_seq_release(struct inode *inode, struct file *file)
-{
-	struct net *net = ((struct seq_file *)file->private_data)->private;
-
-	put_net(net);
-	return single_release(inode, file);
-}
-
 static const struct file_operations netstat_seq_fops = {
 	.owner	 = THIS_MODULE,
 	.open	 = netstat_seq_open,
 	.read	 = seq_read,
 	.llseek	 = seq_lseek,
-	.release = netstat_seq_release,
+	.release = single_release_net,
 };
 
 static __net_init int ip_proc_init_net(struct net *net)
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index 29c5a79..70940b3 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -186,20 +186,12 @@ static int sockstat6_seq_open(struct inode *inode, struct file *file)
 	return single_open_net(inode, file, sockstat6_seq_show);
 }
 
-static int sockstat6_seq_release(struct inode *inode, struct file *file)
-{
-	struct net *net = ((struct seq_file *)file->private_data)->private;
-
-	put_net(net);
-	return single_release(inode, file);
-}
-
 static const struct file_operations sockstat6_seq_fops = {
 	.owner	 = THIS_MODULE,
 	.open	 = sockstat6_seq_open,
 	.read	 = seq_read,
 	.llseek	 = seq_lseek,
-	.release = sockstat6_seq_release,
+	.release = single_release_net,
 };
 
 static int snmp6_seq_open(struct inode *inode, struct file *file)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index fb7ff8f..cb8a512 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2419,20 +2419,12 @@ static int ipv6_route_open(struct inode *inode, struct file *file)
 	return single_open_net(inode, file, ipv6_route_show);
 }
 
-static int ipv6_route_release(struct inode *inode, struct file *file)
-{
-	struct seq_file *seq = file->private_data;
-	struct net *net = seq->private;
-	put_net(net);
-	return single_release(inode, file);
-}
-
 static const struct file_operations ipv6_route_proc_fops = {
 	.owner		= THIS_MODULE,
 	.open		= ipv6_route_open,
 	.read		= seq_read,
 	.llseek		= seq_lseek,
-	.release	= ipv6_route_release,
+	.release	= single_release_net,
 };
 
 static int rt6_stats_seq_show(struct seq_file *seq, void *v)
@@ -2455,20 +2447,12 @@ static int rt6_stats_seq_open(struct inode *inode, struct file *file)
 	return single_open_net(inode, file, rt6_stats_seq_show);
 }
 
-static int rt6_stats_seq_release(struct inode *inode, struct file *file)
-{
-	struct seq_file *seq = file->private_data;
-	struct net *net = (struct net *)seq->private;
-	put_net(net);
-	return single_release(inode, file);
-}
-
 static const struct file_operations rt6_stats_seq_fops = {
 	.owner	 = THIS_MODULE,
 	.open	 = rt6_stats_seq_open,
 	.read	 = seq_read,
 	.llseek	 = seq_lseek,
-	.release = rt6_stats_seq_release,
+	.release = single_release_net,
 };
 #endif	/* CONFIG_PROC_FS */
 
-- 
1.5.5.1

