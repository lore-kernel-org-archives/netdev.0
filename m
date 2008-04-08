From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 3/6 net-2.6.26] [TCP]: Move seq_ops from tcp_iter_state to tcp_seq_afinfo.
Date: Tue,  8 Apr 2008 17:34:26 +0400
Message-ID: <1207661669-13667-3-git-send-email-den@openvz.org>
References: <1207661633.7171.25.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:14032 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751868AbYDHNeI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2008 09:34:08 -0400
In-Reply-To: <1207661633.7171.25.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to create seq_operations for each instance of 'netstat'.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/tcp.h   |    3 +--
 net/ipv4/tcp_ipv4.c |   14 ++++++++------
 net/ipv6/tcp_ipv6.c |    4 +++-
 3 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index f9d6b89..a386bdd 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1324,8 +1324,8 @@ struct tcp_seq_afinfo {
 	struct module		*owner;
 	char			*name;
 	sa_family_t		family;
-	int			(*seq_show) (struct seq_file *m, void *v);
 	struct file_operations	*seq_fops;
+	struct seq_operations	seq_ops;
 };
 
 struct tcp_iter_state {
@@ -1334,7 +1334,6 @@ struct tcp_iter_state {
 	enum tcp_seq_states	state;
 	struct sock		*syn_wait_sk;
 	int			bucket, sbucket, num, uid;
-	struct seq_operations	seq_ops;
 };
 
 extern int tcp_proc_register(struct net *net, struct tcp_seq_afinfo *afinfo);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index e5dd52b..0d0e220 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2230,13 +2230,9 @@ static int tcp_seq_open(struct inode *inode, struct file *file)
 		goto out_kfree;
 
 	s->family		= afinfo->family;
-	s->seq_ops.start	= tcp_seq_start;
-	s->seq_ops.next		= tcp_seq_next;
-	s->seq_ops.show		= afinfo->seq_show;
-	s->seq_ops.stop		= tcp_seq_stop;
 	s->p.net                = net;
 
-	rc = seq_open(file, &s->seq_ops);
+	rc = seq_open(file, &afinfo->seq_ops);
 	if (rc)
 		goto out_put_net;
 	seq = file->private_data;
@@ -2270,6 +2266,10 @@ int tcp_proc_register(struct net *net, struct tcp_seq_afinfo *afinfo)
 	afinfo->seq_fops->llseek	= seq_lseek;
 	afinfo->seq_fops->release	= tcp_seq_release;
 
+	afinfo->seq_ops.start		= tcp_seq_start;
+	afinfo->seq_ops.next		= tcp_seq_next;
+	afinfo->seq_ops.stop		= tcp_seq_stop;
+
 	p = proc_net_fops_create(net, afinfo->name, S_IRUGO, afinfo->seq_fops);
 	if (p)
 		p->data = afinfo;
@@ -2415,8 +2415,10 @@ static struct tcp_seq_afinfo tcp4_seq_afinfo = {
 	.owner		= THIS_MODULE,
 	.name		= "tcp",
 	.family		= AF_INET,
-	.seq_show	= tcp4_seq_show,
 	.seq_fops	= &tcp4_seq_fops,
+	.seq_ops	= {
+		.show		= tcp4_seq_show,
+	},
 };
 
 static int tcp4_proc_init_net(struct net *net)
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 378cc40..09d9184 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -2126,8 +2126,10 @@ static struct tcp_seq_afinfo tcp6_seq_afinfo = {
 	.owner		= THIS_MODULE,
 	.name		= "tcp6",
 	.family		= AF_INET6,
-	.seq_show	= tcp6_seq_show,
 	.seq_fops	= &tcp6_seq_fops,
+	.seq_ops	= {
+		.show		= tcp6_seq_show,
+	},
 };
 
 int tcp6_proc_init(struct net *net)
-- 
1.5.3.rc5

