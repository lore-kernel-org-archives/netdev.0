From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 15/16] proc: consolidate per-net single_open callers
Date: Thu, 17 Jul 2008 17:41:55 +0400
Message-ID: <487F4C23.3080508@openvz.org>
References: <487F46CD.7090103@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:38311 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754130AbYGQNmA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 09:42:00 -0400
In-Reply-To: <487F46CD.7090103@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are already 7 of them - time to kill some duplicate code.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 fs/proc/proc_net.c           |   24 +++++++++++++++++
 include/linux/seq_file_net.h |    2 +
 net/ipv4/fib_trie.c          |   13 +---------
 net/ipv4/proc.c              |   57 ++---------------------------------------
 net/ipv6/proc.c              |   19 +-------------
 net/ipv6/route.c             |   26 +-----------------
 6 files changed, 33 insertions(+), 108 deletions(-)

diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index 83f357b..ab232ad 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -51,6 +51,30 @@ int seq_open_net(struct inode *ino, struct file *f,
 }
 EXPORT_SYMBOL_GPL(seq_open_net);
 
+int single_open_net(struct inode *inode, struct file *file,
+		int (*show)(struct seq_file *, void *))
+{
+	int err;
+	struct net *net;
+
+	err = -ENXIO;
+	net = get_proc_net(inode);
+	if (net == NULL)
+		goto err_net;
+
+	err = single_open(file, show, net);
+	if (err < 0)
+		goto err_open;
+
+	return 0;
+
+err_open:
+	put_net(net);
+err_net:
+	return err;
+}
+EXPORT_SYMBOL_GPL(single_open_net);
+
 int seq_release_net(struct inode *ino, struct file *f)
 {
 	struct seq_file *seq;
diff --git a/include/linux/seq_file_net.h b/include/linux/seq_file_net.h
index 4ac5254..87dcc0e 100644
--- a/include/linux/seq_file_net.h
+++ b/include/linux/seq_file_net.h
@@ -14,6 +14,8 @@ struct seq_net_private {
 
 int seq_open_net(struct inode *, struct file *,
 		 const struct seq_operations *, int);
+int single_open_net(struct inode *, struct file *file,
+		int (*show)(struct seq_file *, void *));
 int seq_release_net(struct inode *, struct file *);
 static inline struct net *seq_file_net(struct seq_file *seq)
 {
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index f155a66..6009df2 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -2251,18 +2251,7 @@ static int fib_triestat_seq_show(struct seq_file *seq, void *v)
 
 static int fib_triestat_seq_open(struct inode *inode, struct file *file)
 {
-	int err;
-	struct net *net;
-
-	net = get_proc_net(inode);
-	if (net == NULL)
-		return -ENXIO;
-	err = single_open(file, fib_triestat_seq_show, net);
-	if (err < 0) {
-		put_net(net);
-		return err;
-	}
-	return 0;
+	return single_open_net(inode, file, fib_triestat_seq_show);
 }
 
 static int fib_triestat_seq_release(struct inode *ino, struct file *f)
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 5543904..daf5d3c 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -71,24 +71,7 @@ static int sockstat_seq_show(struct seq_file *seq, void *v)
 
 static int sockstat_seq_open(struct inode *inode, struct file *file)
 {
-	int err;
-	struct net *net;
-
-	err = -ENXIO;
-	net = get_proc_net(inode);
-	if (net == NULL)
-		goto err_net;
-
-	err = single_open(file, sockstat_seq_show, net);
-	if (err < 0)
-		goto err_open;
-
-	return 0;
-
-err_open:
-	put_net(net);
-err_net:
-	return err;
+	return single_open_net(inode, file, sockstat_seq_show);
 }
 
 static int sockstat_seq_release(struct inode *inode, struct file *file)
@@ -397,24 +380,7 @@ static int snmp_seq_show(struct seq_file *seq, void *v)
 
 static int snmp_seq_open(struct inode *inode, struct file *file)
 {
-	int err;
-	struct net *net;
-
-	err = -ENXIO;
-	net = get_proc_net(inode);
-	if (net == NULL)
-		goto err_net;
-
-	err = single_open(file, snmp_seq_show, net);
-	if (err < 0)
-		goto err_open;
-
-	return 0;
-
-err_open:
-	put_net(net);
-err_net:
-	return err;
+	return single_open_net(inode, file, snmp_seq_show);
 }
 
 static int snmp_seq_release(struct inode *inode, struct file *file)
@@ -469,24 +435,7 @@ static int netstat_seq_show(struct seq_file *seq, void *v)
 
 static int netstat_seq_open(struct inode *inode, struct file *file)
 {
-	int err;
-	struct net *net;
-
-	err = -ENXIO;
-	net = get_proc_net(inode);
-	if (net == NULL)
-		goto err_net;
-
-	err = single_open(file, netstat_seq_show, net);
-	if (err < 0)
-		goto err_open;
-
-	return 0;
-
-err_open:
-	put_net(net);
-err_net:
-	return err;
+	return single_open_net(inode, file, netstat_seq_show);
 }
 
 static int netstat_seq_release(struct inode *inode, struct file *file)
diff --git a/net/ipv6/proc.c b/net/ipv6/proc.c
index cbc7e51..29c5a79 100644
--- a/net/ipv6/proc.c
+++ b/net/ipv6/proc.c
@@ -183,24 +183,7 @@ static int snmp6_seq_show(struct seq_file *seq, void *v)
 
 static int sockstat6_seq_open(struct inode *inode, struct file *file)
 {
-	int err;
-	struct net *net;
-
-	err = -ENXIO;
-	net = get_proc_net(inode);
-	if (net == NULL)
-		goto err_net;
-
-	err = single_open(file, sockstat6_seq_show, net);
-	if (err < 0)
-		goto err_open;
-
-	return 0;
-
-err_open:
-	put_net(net);
-err_net:
-	return err;
+	return single_open_net(inode, file, sockstat6_seq_show);
 }
 
 static int sockstat6_seq_release(struct inode *inode, struct file *file)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 5d6c166..fb7ff8f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2416,18 +2416,7 @@ static int ipv6_route_show(struct seq_file *m, void *v)
 
 static int ipv6_route_open(struct inode *inode, struct file *file)
 {
-	int err;
-	struct net *net = get_proc_net(inode);
-	if (!net)
-		return -ENXIO;
-
-	err = single_open(file, ipv6_route_show, net);
-	if (err < 0) {
-		put_net(net);
-		return err;
-	}
-
-	return 0;
+	return single_open_net(inode, file, ipv6_route_show);
 }
 
 static int ipv6_route_release(struct inode *inode, struct file *file)
@@ -2463,18 +2452,7 @@ static int rt6_stats_seq_show(struct seq_file *seq, void *v)
 
 static int rt6_stats_seq_open(struct inode *inode, struct file *file)
 {
-	int err;
-	struct net *net = get_proc_net(inode);
-	if (!net)
-		return -ENXIO;
-
-	err = single_open(file, rt6_stats_seq_show, net);
-	if (err < 0) {
-		put_net(net);
-		return err;
-	}
-
-	return 0;
+	return single_open_net(inode, file, rt6_stats_seq_show);
 }
 
 static int rt6_stats_seq_release(struct inode *inode, struct file *file)
-- 
1.5.5.1

