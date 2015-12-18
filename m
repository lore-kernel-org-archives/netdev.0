From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/23] netfilter: Set /proc/net entries owner to root in namespace
Date: Fri, 18 Dec 2015 21:26:37 +0100
Message-ID: <1450470409-31427-12-git-send-email-pablo@netfilter.org>
References: <1450470409-31427-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57977 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965194AbbLRUeI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2015 15:34:08 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id C6746132AB5
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:34:07 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 514ADDA24B
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:34:07 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 238E5DA8E4
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2015 21:33:49 +0100 (CET)
In-Reply-To: <1450470409-31427-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philip Whineray <phil@firehol.org>

Various files are owned by root with 0440 permission. Reading them is
impossible in an unprivileged user namespace, interfering with firewall
tools. For instance, iptables-save relies on /proc/net/ip_tables_names
contents to dump only loaded tables.

This patch assigned ownership of the following files to root in the
current namespace:

- /proc/net/*_tables_names
- /proc/net/*_tables_matches
- /proc/net/*_tables_targets
- /proc/net/nf_conntrack
- /proc/net/nf_conntrack_expect
- /proc/net/netfilter/nfnetlink_log

A mapping for root must be available, so this order should be followed:

unshare(CLONE_NEWUSER);
/* Setup the mapping */
unshare(CLONE_NEWNET);

Signed-off-by: Philip Whineray <phil@firehol.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_expect.c     |  7 +++++++
 net/netfilter/nf_conntrack_standalone.c |  7 +++++++
 net/netfilter/nfnetlink_log.c           | 15 +++++++++++++--
 net/netfilter/x_tables.c                | 12 ++++++++++++
 4 files changed, 39 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index acf5c7b..278927a 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -596,11 +596,18 @@ static int exp_proc_init(struct net *net)
 {
 #ifdef CONFIG_NF_CONNTRACK_PROCFS
 	struct proc_dir_entry *proc;
+	kuid_t root_uid;
+	kgid_t root_gid;
 
 	proc = proc_create("nf_conntrack_expect", 0440, net->proc_net,
 			   &exp_file_ops);
 	if (!proc)
 		return -ENOMEM;
+
+	root_uid = make_kuid(net->user_ns, 0);
+	root_gid = make_kgid(net->user_ns, 0);
+	if (uid_valid(root_uid) && gid_valid(root_gid))
+		proc_set_user(proc, root_uid, root_gid);
 #endif /* CONFIG_NF_CONNTRACK_PROCFS */
 	return 0;
 }
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 1fb3cac..0f1a45b 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -392,11 +392,18 @@ static const struct file_operations ct_cpu_seq_fops = {
 static int nf_conntrack_standalone_init_proc(struct net *net)
 {
 	struct proc_dir_entry *pde;
+	kuid_t root_uid;
+	kgid_t root_gid;
 
 	pde = proc_create("nf_conntrack", 0440, net->proc_net, &ct_file_ops);
 	if (!pde)
 		goto out_nf_conntrack;
 
+	root_uid = make_kuid(net->user_ns, 0);
+	root_gid = make_kgid(net->user_ns, 0);
+	if (uid_valid(root_uid) && gid_valid(root_gid))
+		proc_set_user(pde, root_uid, root_gid);
+
 	pde = proc_create("nf_conntrack", S_IRUGO, net->proc_net_stat,
 			  &ct_cpu_seq_fops);
 	if (!pde)
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 740cce4..dea4676 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -1064,15 +1064,26 @@ static int __net_init nfnl_log_net_init(struct net *net)
 {
 	unsigned int i;
 	struct nfnl_log_net *log = nfnl_log_pernet(net);
+#ifdef CONFIG_PROC_FS
+	struct proc_dir_entry *proc;
+	kuid_t root_uid;
+	kgid_t root_gid;
+#endif
 
 	for (i = 0; i < INSTANCE_BUCKETS; i++)
 		INIT_HLIST_HEAD(&log->instance_table[i]);
 	spin_lock_init(&log->instances_lock);
 
 #ifdef CONFIG_PROC_FS
-	if (!proc_create("nfnetlink_log", 0440,
-			 net->nf.proc_netfilter, &nful_file_ops))
+	proc = proc_create("nfnetlink_log", 0440,
+			   net->nf.proc_netfilter, &nful_file_ops);
+	if (!proc)
 		return -ENOMEM;
+
+	root_uid = make_kuid(net->user_ns, 0);
+	root_gid = make_kgid(net->user_ns, 0);
+	if (uid_valid(root_uid) && gid_valid(root_gid))
+		proc_set_user(proc, root_uid, root_gid);
 #endif
 	return 0;
 }
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index d4aaad7..c8a0b7d 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -26,6 +26,7 @@
 #include <linux/mm.h>
 #include <linux/slab.h>
 #include <linux/audit.h>
+#include <linux/user_namespace.h>
 #include <net/net_namespace.h>
 
 #include <linux/netfilter/x_tables.h>
@@ -1226,6 +1227,8 @@ int xt_proto_init(struct net *net, u_int8_t af)
 #ifdef CONFIG_PROC_FS
 	char buf[XT_FUNCTION_MAXNAMELEN];
 	struct proc_dir_entry *proc;
+	kuid_t root_uid;
+	kgid_t root_gid;
 #endif
 
 	if (af >= ARRAY_SIZE(xt_prefix))
@@ -1233,12 +1236,17 @@ int xt_proto_init(struct net *net, u_int8_t af)
 
 
 #ifdef CONFIG_PROC_FS
+	root_uid = make_kuid(net->user_ns, 0);
+	root_gid = make_kgid(net->user_ns, 0);
+
 	strlcpy(buf, xt_prefix[af], sizeof(buf));
 	strlcat(buf, FORMAT_TABLES, sizeof(buf));
 	proc = proc_create_data(buf, 0440, net->proc_net, &xt_table_ops,
 				(void *)(unsigned long)af);
 	if (!proc)
 		goto out;
+	if (uid_valid(root_uid) && gid_valid(root_gid))
+		proc_set_user(proc, root_uid, root_gid);
 
 	strlcpy(buf, xt_prefix[af], sizeof(buf));
 	strlcat(buf, FORMAT_MATCHES, sizeof(buf));
@@ -1246,6 +1254,8 @@ int xt_proto_init(struct net *net, u_int8_t af)
 				(void *)(unsigned long)af);
 	if (!proc)
 		goto out_remove_tables;
+	if (uid_valid(root_uid) && gid_valid(root_gid))
+		proc_set_user(proc, root_uid, root_gid);
 
 	strlcpy(buf, xt_prefix[af], sizeof(buf));
 	strlcat(buf, FORMAT_TARGETS, sizeof(buf));
@@ -1253,6 +1263,8 @@ int xt_proto_init(struct net *net, u_int8_t af)
 				(void *)(unsigned long)af);
 	if (!proc)
 		goto out_remove_matches;
+	if (uid_valid(root_uid) && gid_valid(root_gid))
+		proc_set_user(proc, root_uid, root_gid);
 #endif
 
 	return 0;
-- 
2.1.4
