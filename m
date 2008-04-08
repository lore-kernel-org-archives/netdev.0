From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH] [TCP]: Place file operations directly into tcp_seq_afinfo.
Date: Tue,  8 Apr 2008 17:29:51 +0400
Message-ID: <1207661392-13570-5-git-send-email-den@openvz.org>
References: <1207661318.7171.22.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:18993 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751954AbYDHN3b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2008 09:29:31 -0400
In-Reply-To: <1207661318.7171.22.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to have separate never-used variable.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/tcp.h   |    2 +-
 net/ipv4/tcp_ipv4.c |   15 ++++++---------
 net/ipv6/tcp_ipv6.c |    2 --
 3 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index a386bdd..23915f3 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1324,7 +1324,7 @@ struct tcp_seq_afinfo {
 	struct module		*owner;
 	char			*name;
 	sa_family_t		family;
-	struct file_operations	*seq_fops;
+	struct file_operations	seq_fops;
 	struct seq_operations	seq_ops;
 };
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 287af10..ebef394 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2233,17 +2233,17 @@ int tcp_proc_register(struct net *net, struct tcp_seq_afinfo *afinfo)
 	int rc = 0;
 	struct proc_dir_entry *p;
 
-	afinfo->seq_fops->owner		= afinfo->owner;
-	afinfo->seq_fops->open		= tcp_seq_open;
-	afinfo->seq_fops->read		= seq_read;
-	afinfo->seq_fops->llseek	= seq_lseek;
-	afinfo->seq_fops->release	= seq_release_net;
+	afinfo->seq_fops.owner		= afinfo->owner;
+	afinfo->seq_fops.open		= tcp_seq_open;
+	afinfo->seq_fops.read		= seq_read;
+	afinfo->seq_fops.llseek		= seq_lseek;
+	afinfo->seq_fops.release	= seq_release_net;
 
 	afinfo->seq_ops.start		= tcp_seq_start;
 	afinfo->seq_ops.next		= tcp_seq_next;
 	afinfo->seq_ops.stop		= tcp_seq_stop;
 
-	p = proc_net_fops_create(net, afinfo->name, S_IRUGO, afinfo->seq_fops);
+	p = proc_net_fops_create(net, afinfo->name, S_IRUGO, &afinfo->seq_fops);
 	if (p)
 		p->data = afinfo;
 	else
@@ -2254,7 +2254,6 @@ int tcp_proc_register(struct net *net, struct tcp_seq_afinfo *afinfo)
 void tcp_proc_unregister(struct net *net, struct tcp_seq_afinfo *afinfo)
 {
 	proc_net_remove(net, afinfo->name);
-	memset(afinfo->seq_fops, 0, sizeof(*afinfo->seq_fops));
 }
 
 static void get_openreq4(struct sock *sk, struct request_sock *req,
@@ -2383,12 +2382,10 @@ out:
 	return 0;
 }
 
-static struct file_operations tcp4_seq_fops;
 static struct tcp_seq_afinfo tcp4_seq_afinfo = {
 	.owner		= THIS_MODULE,
 	.name		= "tcp",
 	.family		= AF_INET,
-	.seq_fops	= &tcp4_seq_fops,
 	.seq_ops	= {
 		.show		= tcp4_seq_show,
 	},
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 09d9184..15c7044 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -2121,12 +2121,10 @@ out:
 	return 0;
 }
 
-static struct file_operations tcp6_seq_fops;
 static struct tcp_seq_afinfo tcp6_seq_afinfo = {
 	.owner		= THIS_MODULE,
 	.name		= "tcp6",
 	.family		= AF_INET6,
-	.seq_fops	= &tcp6_seq_fops,
 	.seq_ops	= {
 		.show		= tcp6_seq_show,
 	},
-- 
1.5.3.rc5

