From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 5/6 net-2.6.26] [UDP]: Place file operations directly into udp_seq_afinfo.
Date: Thu, 27 Mar 2008 17:11:37 +0300
Message-ID: <1206627098-2456-5-git-send-email-den@openvz.org>
References: <1206627041.2109.15.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:25414 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755732AbYC0OLJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 10:11:09 -0400
In-Reply-To: <1206627041.2109.15.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to have separate never-used variable.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/udp.h  |    2 +-
 net/ipv4/udp.c     |   15 ++++++---------
 net/ipv4/udplite.c |    2 --
 net/ipv6/udp.c     |    2 --
 net/ipv6/udplite.c |    2 --
 5 files changed, 7 insertions(+), 16 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index 0079d17..5cf0e59 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -189,7 +189,7 @@ struct udp_seq_afinfo {
 	char			*name;
 	sa_family_t		family;
 	struct hlist_head	*hashtable;
-	struct file_operations	*seq_fops;
+	struct file_operations	seq_fops;
 	struct seq_operations	seq_ops;
 };
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 1b1f299..3f5ad77 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1599,17 +1599,17 @@ int udp_proc_register(struct net *net, struct udp_seq_afinfo *afinfo)
 	struct proc_dir_entry *p;
 	int rc = 0;
 
-	afinfo->seq_fops->owner		= afinfo->owner;
-	afinfo->seq_fops->open		= udp_seq_open;
-	afinfo->seq_fops->read		= seq_read;
-	afinfo->seq_fops->llseek	= seq_lseek;
-	afinfo->seq_fops->release	= seq_release_net;
+	afinfo->seq_fops.owner		= afinfo->owner;
+	afinfo->seq_fops.open		= udp_seq_open;
+	afinfo->seq_fops.read		= seq_read;
+	afinfo->seq_fops.llseek		= seq_lseek;
+	afinfo->seq_fops.release	= seq_release_net;
 
 	afinfo->seq_ops.start		= udp_seq_start;
 	afinfo->seq_ops.next		= udp_seq_next;
 	afinfo->seq_ops.stop		= udp_seq_stop;
 
-	p = proc_net_fops_create(net, afinfo->name, S_IRUGO, afinfo->seq_fops);
+	p = proc_net_fops_create(net, afinfo->name, S_IRUGO, &afinfo->seq_fops);
 	if (p)
 		p->data = afinfo;
 	else
@@ -1620,7 +1620,6 @@ int udp_proc_register(struct net *net, struct udp_seq_afinfo *afinfo)
 void udp_proc_unregister(struct net *net, struct udp_seq_afinfo *afinfo)
 {
 	proc_net_remove(net, afinfo->name);
-	memset(afinfo->seq_fops, 0, sizeof(*afinfo->seq_fops));
 }
 
 /* ------------------------------------------------------------------------ */
@@ -1659,13 +1658,11 @@ int udp4_seq_show(struct seq_file *seq, void *v)
 }
 
 /* ------------------------------------------------------------------------ */
-static struct file_operations udp4_seq_fops;
 static struct udp_seq_afinfo udp4_seq_afinfo = {
 	.owner		= THIS_MODULE,
 	.name		= "udp",
 	.family		= AF_INET,
 	.hashtable	= udp_hash,
-	.seq_fops	= &udp4_seq_fops,
 	.seq_ops	= {
 		.show		= udp4_seq_show,
 	},
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index 3cb8b7f..f73bb17 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -74,13 +74,11 @@ static struct inet_protosw udplite4_protosw = {
 };
 
 #ifdef CONFIG_PROC_FS
-static struct file_operations udplite4_seq_fops;
 static struct udp_seq_afinfo udplite4_seq_afinfo = {
 	.owner		= THIS_MODULE,
 	.name		= "udplite",
 	.family		= AF_INET,
 	.hashtable	= udplite_hash,
-	.seq_fops	= &udplite4_seq_fops,
 	.seq_ops	= {
 		.show		= udp4_seq_show,
 	},
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index cb3a3c6..475f2aa 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -977,13 +977,11 @@ int udp6_seq_show(struct seq_file *seq, void *v)
 	return 0;
 }
 
-static struct file_operations udp6_seq_fops;
 static struct udp_seq_afinfo udp6_seq_afinfo = {
 	.owner		= THIS_MODULE,
 	.name		= "udp6",
 	.family		= AF_INET6,
 	.hashtable	= udp_hash,
-	.seq_fops	= &udp6_seq_fops,
 	.seq_ops	= {
 		.show		= udp6_seq_show,
 	},
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index 56223eb..5a9e646 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -99,13 +99,11 @@ void udplitev6_exit(void)
 }
 
 #ifdef CONFIG_PROC_FS
-static struct file_operations udplite6_seq_fops;
 static struct udp_seq_afinfo udplite6_seq_afinfo = {
 	.owner		= THIS_MODULE,
 	.name		= "udplite6",
 	.family		= AF_INET6,
 	.hashtable	= udplite_hash,
-	.seq_fops	= &udplite6_seq_fops,
 	.seq_ops	= {
 		.show		= udp6_seq_show,
 	},
-- 
1.5.3.rc5

