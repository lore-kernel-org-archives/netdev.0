From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 3/6 net-2.6.26] [UDP]: Move seq_ops from udp_iter_state to udp_seq_afinfo.
Date: Thu, 27 Mar 2008 17:11:35 +0300
Message-ID: <1206627098-2456-3-git-send-email-den@openvz.org>
References: <1206627041.2109.15.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:25122 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755855AbYC0OLJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 10:11:09 -0400
In-Reply-To: <1206627041.2109.15.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to create seq_operations for each instance of 'netstat'.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/udp.h  |    3 +--
 net/ipv4/udp.c     |   14 ++++++++------
 net/ipv4/udplite.c |    4 +++-
 net/ipv6/udp.c     |    4 +++-
 net/ipv6/udplite.c |    4 +++-
 5 files changed, 18 insertions(+), 11 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index 77af7d4..0079d17 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -189,8 +189,8 @@ struct udp_seq_afinfo {
 	char			*name;
 	sa_family_t		family;
 	struct hlist_head	*hashtable;
-	int 			(*seq_show) (struct seq_file *m, void *v);
 	struct file_operations	*seq_fops;
+	struct seq_operations	seq_ops;
 };
 
 struct udp_iter_state {
@@ -198,7 +198,6 @@ struct udp_iter_state {
 	sa_family_t		family;
 	struct hlist_head	*hashtable;
 	int			bucket;
-	struct seq_operations	seq_ops;
 };
 
 #ifdef CONFIG_PROC_FS
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index c05f45b..43920f1 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1594,13 +1594,9 @@ static int udp_seq_open(struct inode *inode, struct file *file)
 
 	s->family		= afinfo->family;
 	s->hashtable		= afinfo->hashtable;
-	s->seq_ops.start	= udp_seq_start;
-	s->seq_ops.next		= udp_seq_next;
-	s->seq_ops.show		= afinfo->seq_show;
-	s->seq_ops.stop		= udp_seq_stop;
 	s->p.net                = net;
 
-	rc = seq_open(file, &s->seq_ops);
+	rc = seq_open(file, &afinfo->seq_ops);
 	if (rc)
 		goto out_put_net;
 
@@ -1637,6 +1633,10 @@ int udp_proc_register(struct net *net, struct udp_seq_afinfo *afinfo)
 	afinfo->seq_fops->llseek	= seq_lseek;
 	afinfo->seq_fops->release	= udp_seq_release;
 
+	afinfo->seq_ops.start		= udp_seq_start;
+	afinfo->seq_ops.next		= udp_seq_next;
+	afinfo->seq_ops.stop		= udp_seq_stop;
+
 	p = proc_net_fops_create(net, afinfo->name, S_IRUGO, afinfo->seq_fops);
 	if (p)
 		p->data = afinfo;
@@ -1693,8 +1693,10 @@ static struct udp_seq_afinfo udp4_seq_afinfo = {
 	.name		= "udp",
 	.family		= AF_INET,
 	.hashtable	= udp_hash,
-	.seq_show	= udp4_seq_show,
 	.seq_fops	= &udp4_seq_fops,
+	.seq_ops	= {
+		.show		= udp4_seq_show,
+	},
 };
 
 static int udp4_proc_init_net(struct net *net)
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index 53f3ed4..3cb8b7f 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -80,8 +80,10 @@ static struct udp_seq_afinfo udplite4_seq_afinfo = {
 	.name		= "udplite",
 	.family		= AF_INET,
 	.hashtable	= udplite_hash,
-	.seq_show	= udp4_seq_show,
 	.seq_fops	= &udplite4_seq_fops,
+	.seq_ops	= {
+		.show		= udp4_seq_show,
+	},
 };
 
 static int udplite4_proc_init_net(struct net *net)
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index aacbc82..cb3a3c6 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -983,8 +983,10 @@ static struct udp_seq_afinfo udp6_seq_afinfo = {
 	.name		= "udp6",
 	.family		= AF_INET6,
 	.hashtable	= udp_hash,
-	.seq_show	= udp6_seq_show,
 	.seq_fops	= &udp6_seq_fops,
+	.seq_ops	= {
+		.show		= udp6_seq_show,
+	},
 };
 
 int udp6_proc_init(struct net *net)
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index 706c5c3..56223eb 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -105,8 +105,10 @@ static struct udp_seq_afinfo udplite6_seq_afinfo = {
 	.name		= "udplite6",
 	.family		= AF_INET6,
 	.hashtable	= udplite_hash,
-	.seq_show	= udp6_seq_show,
 	.seq_fops	= &udplite6_seq_fops,
+	.seq_ops	= {
+		.show		= udp6_seq_show,
+	},
 };
 
 static int udplite6_proc_init_net(struct net *net)
-- 
1.5.3.rc5

