From: Arjan van de Ven <arjan@infradead.org>
Subject: [PATCH] net: make the tcp and udp file_operations for the /proc
 stuff const
Date: Sun, 30 Oct 2011 09:46:30 -0700
Message-ID: <20111030094630.47e247ae@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:41929 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755634Ab1J3Qlw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2011 12:41:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

as most of you probably already know, there's a strong desire to make struct file_operations
(and similar structures) const throughout the kernel. I'm sure something like this patch
has been posted here before, so I realize I'm threading in a tricky part ;-)

I'll try anyway with the patch below at least to get feedback on how to do this thing better
if nothing else...



>From 85d9ba34b3a6ad60a2b5ac3421eebdb5bbf81f7d Mon Sep 17 00:00:00 2001
From: Arjan van de Ven <arjan@linux.intel.com>
Date: Sun, 30 Oct 2011 09:25:32 -0700
Subject: [PATCH] net: make the tcp and udp file_operations for the /proc stuff const

the tcp and udp code creates a set of struct file_operations at runtime
while it can also be done at compile time, with the added benefit of then
having these file operations be const.

the trickiest part was to get the "THIS_MODULE" reference right; the naive
method of declaring a struct in the place of registration would not work
for this reason.

Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
---
 include/net/tcp.h   |   10 ++++++----
 include/net/udp.h   |   12 +++++++-----
 net/ipv4/tcp_ipv4.c |   22 ++++++++++++----------
 net/ipv4/udp.c      |   22 ++++++++++++----------
 net/ipv4/udplite.c  |   13 ++++++++++---
 net/ipv6/tcp_ipv6.c |   12 +++++++++---
 net/ipv6/udp.c      |   12 +++++++++---
 net/ipv6/udplite.c  |   13 ++++++++++---
 8 files changed, 75 insertions(+), 41 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index acc620a..b9cdfe3 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1398,11 +1398,13 @@ enum tcp_seq_states {
 	TCP_SEQ_STATE_TIME_WAIT,
 };
 
+int tcp_seq_open(struct inode *inode, struct file *file);
+
 struct tcp_seq_afinfo {
-	char			*name;
-	sa_family_t		family;
-	struct file_operations	seq_fops;
-	struct seq_operations	seq_ops;
+	char				*name;
+	sa_family_t			family;
+	const struct file_operations	*seq_fops;
+	struct seq_operations		seq_ops;
 };
 
 struct tcp_iter_state {
diff --git a/include/net/udp.h b/include/net/udp.h
index 67ea6fc..3b285f4 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -230,12 +230,14 @@ extern struct sock *udp6_lib_lookup(struct net *net, const struct in6_addr *sadd
 #endif
 
 /* /proc */
+int udp_seq_open(struct inode *inode, struct file *file);
+
 struct udp_seq_afinfo {
-	char			*name;
-	sa_family_t		family;
-	struct udp_table	*udp_table;
-	struct file_operations	seq_fops;
-	struct seq_operations	seq_ops;
+	char				*name;
+	sa_family_t			family;
+	struct udp_table		*udp_table;
+	const struct file_operations	*seq_fops;
+	struct seq_operations		seq_ops;
 };
 
 struct udp_iter_state {
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7963e03..d43dc07 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2336,7 +2336,7 @@ static void tcp_seq_stop(struct seq_file *seq, void *v)
 	}
 }
 
-static int tcp_seq_open(struct inode *inode, struct file *file)
+int tcp_seq_open(struct inode *inode, struct file *file)
 {
 	struct tcp_seq_afinfo *afinfo = PDE(inode)->data;
 	struct tcp_iter_state *s;
@@ -2352,23 +2352,19 @@ static int tcp_seq_open(struct inode *inode, struct file *file)
 	s->last_pos 		= 0;
 	return 0;
 }
+EXPORT_SYMBOL(tcp_seq_open);
 
 int tcp_proc_register(struct net *net, struct tcp_seq_afinfo *afinfo)
 {
 	int rc = 0;
 	struct proc_dir_entry *p;
 
-	afinfo->seq_fops.open		= tcp_seq_open;
-	afinfo->seq_fops.read		= seq_read;
-	afinfo->seq_fops.llseek		= seq_lseek;
-	afinfo->seq_fops.release	= seq_release_net;
-
 	afinfo->seq_ops.start		= tcp_seq_start;
 	afinfo->seq_ops.next		= tcp_seq_next;
 	afinfo->seq_ops.stop		= tcp_seq_stop;
 
 	p = proc_create_data(afinfo->name, S_IRUGO, net->proc_net,
-			     &afinfo->seq_fops, afinfo);
+			     afinfo->seq_fops, afinfo);
 	if (!p)
 		rc = -ENOMEM;
 	return rc;
@@ -2517,12 +2513,18 @@ out:
 	return 0;
 }
 
+static const struct file_operations tcp_afinfo_seq_fops = {
+	.owner   = THIS_MODULE,
+	.open    = tcp_seq_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release_net
+};
+
 static struct tcp_seq_afinfo tcp4_seq_afinfo = {
 	.name		= "tcp",
 	.family		= AF_INET,
-	.seq_fops	= {
-		.owner		= THIS_MODULE,
-	},
+	.seq_fops	= &tcp_afinfo_seq_fops,
 	.seq_ops	= {
 		.show		= tcp4_seq_show,
 	},
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 1b5a193..25b869a 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2038,7 +2038,7 @@ static void udp_seq_stop(struct seq_file *seq, void *v)
 		spin_unlock_bh(&state->udp_table->hash[state->bucket].lock);
 }
 
-static int udp_seq_open(struct inode *inode, struct file *file)
+int udp_seq_open(struct inode *inode, struct file *file)
 {
 	struct udp_seq_afinfo *afinfo = PDE(inode)->data;
 	struct udp_iter_state *s;
@@ -2054,6 +2054,7 @@ static int udp_seq_open(struct inode *inode, struct file *file)
 	s->udp_table		= afinfo->udp_table;
 	return err;
 }
+EXPORT_SYMBOL(udp_seq_open);
 
 /* ------------------------------------------------------------------------ */
 int udp_proc_register(struct net *net, struct udp_seq_afinfo *afinfo)
@@ -2061,17 +2062,12 @@ int udp_proc_register(struct net *net, struct udp_seq_afinfo *afinfo)
 	struct proc_dir_entry *p;
 	int rc = 0;
 
-	afinfo->seq_fops.open		= udp_seq_open;
-	afinfo->seq_fops.read		= seq_read;
-	afinfo->seq_fops.llseek		= seq_lseek;
-	afinfo->seq_fops.release	= seq_release_net;
-
 	afinfo->seq_ops.start		= udp_seq_start;
 	afinfo->seq_ops.next		= udp_seq_next;
 	afinfo->seq_ops.stop		= udp_seq_stop;
 
 	p = proc_create_data(afinfo->name, S_IRUGO, net->proc_net,
-			     &afinfo->seq_fops, afinfo);
+			     afinfo->seq_fops, afinfo);
 	if (!p)
 		rc = -ENOMEM;
 	return rc;
@@ -2121,14 +2117,20 @@ int udp4_seq_show(struct seq_file *seq, void *v)
 	return 0;
 }
 
+static const struct file_operations udp_afinfo_seq_fops = {
+	.owner    = THIS_MODULE,
+	.open     = udp_seq_open,
+	.read     = seq_read,
+	.llseek   = seq_lseek,
+	.release  = seq_release_net
+};
+
 /* ------------------------------------------------------------------------ */
 static struct udp_seq_afinfo udp4_seq_afinfo = {
 	.name		= "udp",
 	.family		= AF_INET,
 	.udp_table	= &udp_table,
-	.seq_fops	= {
-		.owner	=	THIS_MODULE,
-	},
+	.seq_fops	= &udp_afinfo_seq_fops,
 	.seq_ops	= {
 		.show		= udp4_seq_show,
 	},
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index aee9963..08383eb 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -71,13 +71,20 @@ static struct inet_protosw udplite4_protosw = {
 };
 
 #ifdef CONFIG_PROC_FS
+
+static const struct file_operations udplite_afinfo_seq_fops = {
+	.owner    = THIS_MODULE,
+	.open     = udp_seq_open,
+	.read     = seq_read,
+	.llseek   = seq_lseek,
+	.release  = seq_release_net
+};
+
 static struct udp_seq_afinfo udplite4_seq_afinfo = {
 	.name		= "udplite",
 	.family		= AF_INET,
 	.udp_table 	= &udplite_table,
-	.seq_fops	= {
-		.owner	=	THIS_MODULE,
-	},
+	.seq_fops	= &udplite_afinfo_seq_fops,
 	.seq_ops	= {
 		.show		= udp4_seq_show,
 	},
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 7b8fc57..d0fde8c 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -2158,12 +2158,18 @@ out:
 	return 0;
 }
 
+static const struct file_operations tcp6_afinfo_seq_fops = {
+	.owner   = THIS_MODULE,
+	.open    = tcp_seq_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release_net
+};
+
 static struct tcp_seq_afinfo tcp6_seq_afinfo = {
 	.name		= "tcp6",
 	.family		= AF_INET6,
-	.seq_fops	= {
-		.owner		= THIS_MODULE,
-	},
+	.seq_fops	= &tcp6_afinfo_seq_fops,
 	.seq_ops	= {
 		.show		= tcp6_seq_show,
 	},
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index bb95e8e..37f654d 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1424,13 +1424,19 @@ int udp6_seq_show(struct seq_file *seq, void *v)
 	return 0;
 }
 
+static const struct file_operations udp6_afinfo_seq_fops = {
+	.owner    = THIS_MODULE,
+	.open     = udp_seq_open,
+	.read     = seq_read,
+	.llseek   = seq_lseek,
+	.release  = seq_release_net
+};
+
 static struct udp_seq_afinfo udp6_seq_afinfo = {
 	.name		= "udp6",
 	.family		= AF_INET6,
 	.udp_table	= &udp_table,
-	.seq_fops	= {
-		.owner	=	THIS_MODULE,
-	},
+	.seq_fops	= &udp6_afinfo_seq_fops,
 	.seq_ops	= {
 		.show		= udp6_seq_show,
 	},
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index 986c4de..8889aa2 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -93,13 +93,20 @@ void udplitev6_exit(void)
 }
 
 #ifdef CONFIG_PROC_FS
+
+static const struct file_operations udplite6_afinfo_seq_fops = {
+	.owner    = THIS_MODULE,
+	.open     = udp_seq_open,
+	.read     = seq_read,
+	.llseek   = seq_lseek,
+	.release  = seq_release_net
+};
+
 static struct udp_seq_afinfo udplite6_seq_afinfo = {
 	.name		= "udplite6",
 	.family		= AF_INET6,
 	.udp_table	= &udplite_table,
-	.seq_fops	= {
-		.owner	=	THIS_MODULE,
-	},
+	.seq_fops	= &udplite6_afinfo_seq_fops,
 	.seq_ops	= {
 		.show		= udp6_seq_show,
 	},
-- 
1.7.6


-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
