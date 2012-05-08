From: pablo@netfilter.org
Subject: [PATCH 02/25] netfilter: nf_ct_helper: allow to disable automatic helper assignment
Date: Tue,  8 May 2012 20:38:00 +0200
Message-ID: <1336502303-1722-3-git-send-email-pablo@netfilter.org>
References: <1336502303-1722-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, openbsc@lists.osmocom.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39257 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755597Ab2EHSkG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2012 14:40:06 -0400
In-Reply-To: <1336502303-1722-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Leblond <eric@regit.org>

This patch allows you to disable automatic conntrack helper
lookup based on TCP/UDP ports, eg.

echo 0 > /proc/sys/net/netfilter/nf_conntrack_helper

[ Note: flows that already got a helper will keep using it even
  if automatic helper assignment has been disabled ]

Once this behaviour has been disabled, you have to explicitly
use the iptables CT target to attach helper to flows.

There are good reasons to stop supporting automatic helper
assignment, for further information, please read:

http://www.netfilter.org/news.html#2012-04-03

This patch also adds one message to inform that automatic helper
assignment is deprecated and it will be removed soon (this is
spotted only once, with the first flow that gets a helper attached
to make it as less annoying as possible).

Signed-off-by: Eric Leblond <eric@regit.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_helper.h |    4 +-
 include/net/netns/conntrack.h               |    3 +
 net/netfilter/nf_conntrack_core.c           |   15 ++--
 net/netfilter/nf_conntrack_helper.c         |  109 ++++++++++++++++++++++++---
 4 files changed, 110 insertions(+), 21 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_helper.h b/include/net/netfilter/nf_conntrack_helper.h
index 5767dc2..1d18894 100644
--- a/include/net/netfilter/nf_conntrack_helper.h
+++ b/include/net/netfilter/nf_conntrack_helper.h
@@ -60,8 +60,8 @@ static inline struct nf_conn_help *nfct_help(const struct nf_conn *ct)
 	return nf_ct_ext_find(ct, NF_CT_EXT_HELPER);
 }
 
-extern int nf_conntrack_helper_init(void);
-extern void nf_conntrack_helper_fini(void);
+extern int nf_conntrack_helper_init(struct net *net);
+extern void nf_conntrack_helper_fini(struct net *net);
 
 extern int nf_conntrack_broadcast_help(struct sk_buff *skb,
 				       unsigned int protoff,
diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index 7a911ec..a053a19 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -26,11 +26,14 @@ struct netns_ct {
 	int			sysctl_tstamp;
 	int			sysctl_checksum;
 	unsigned int		sysctl_log_invalid; /* Log invalid packets */
+	int			sysctl_auto_assign_helper;
+	bool			auto_assign_helper_warned;
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_header	*sysctl_header;
 	struct ctl_table_header	*acct_sysctl_header;
 	struct ctl_table_header	*tstamp_sysctl_header;
 	struct ctl_table_header	*event_sysctl_header;
+	struct ctl_table_header	*helper_sysctl_header;
 #endif
 	char			*slabname;
 };
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index cf0747c..32c5909 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1336,7 +1336,6 @@ static void nf_conntrack_cleanup_init_net(void)
 	while (untrack_refs() > 0)
 		schedule();
 
-	nf_conntrack_helper_fini();
 	nf_conntrack_proto_fini();
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 	nf_ct_extend_unregister(&nf_ct_zone_extend);
@@ -1354,6 +1353,7 @@ static void nf_conntrack_cleanup_net(struct net *net)
 	}
 
 	nf_ct_free_hashtable(net->ct.hash, net->ct.htable_size);
+	nf_conntrack_helper_fini(net);
 	nf_conntrack_timeout_fini(net);
 	nf_conntrack_ecache_fini(net);
 	nf_conntrack_tstamp_fini(net);
@@ -1504,10 +1504,6 @@ static int nf_conntrack_init_init_net(void)
 	if (ret < 0)
 		goto err_proto;
 
-	ret = nf_conntrack_helper_init();
-	if (ret < 0)
-		goto err_helper;
-
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 	ret = nf_ct_extend_register(&nf_ct_zone_extend);
 	if (ret < 0)
@@ -1525,10 +1521,8 @@ static int nf_conntrack_init_init_net(void)
 
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 err_extend:
-	nf_conntrack_helper_fini();
-#endif
-err_helper:
 	nf_conntrack_proto_fini();
+#endif
 err_proto:
 	return ret;
 }
@@ -1589,9 +1583,14 @@ static int nf_conntrack_init_net(struct net *net)
 	ret = nf_conntrack_timeout_init(net);
 	if (ret < 0)
 		goto err_timeout;
+	ret = nf_conntrack_helper_init(net);
+	if (ret < 0)
+		goto err_helper;
 
 	return 0;
 
+err_helper:
+	nf_conntrack_timeout_fini(net);
 err_timeout:
 	nf_conntrack_ecache_fini(net);
 err_ecache:
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 436b7cb..317f6e4 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -34,6 +34,67 @@ static struct hlist_head *nf_ct_helper_hash __read_mostly;
 static unsigned int nf_ct_helper_hsize __read_mostly;
 static unsigned int nf_ct_helper_count __read_mostly;
 
+static bool nf_ct_auto_assign_helper __read_mostly = true;
+module_param_named(nf_conntrack_helper, nf_ct_auto_assign_helper, bool, 0644);
+MODULE_PARM_DESC(nf_conntrack_helper,
+		 "Enable automatic conntrack helper assignment (default 1)");
+
+#ifdef CONFIG_SYSCTL
+static struct ctl_table helper_sysctl_table[] = {
+	{
+		.procname	= "nf_conntrack_helper",
+		.data		= &init_net.ct.sysctl_auto_assign_helper,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{}
+};
+
+static int nf_conntrack_helper_init_sysctl(struct net *net)
+{
+	struct ctl_table *table;
+
+	table = kmemdup(helper_sysctl_table, sizeof(helper_sysctl_table),
+			GFP_KERNEL);
+	if (!table)
+		goto out;
+
+	table[0].data = &net->ct.sysctl_auto_assign_helper;
+
+	net->ct.helper_sysctl_header =
+		register_net_sysctl(net, "net/netfilter", table);
+
+	if (!net->ct.helper_sysctl_header) {
+		pr_err("nf_conntrack_helper: can't register to sysctl.\n");
+		goto out_register;
+	}
+	return 0;
+
+out_register:
+	kfree(table);
+out:
+	return -ENOMEM;
+}
+
+static void nf_conntrack_helper_fini_sysctl(struct net *net)
+{
+	struct ctl_table *table;
+
+	table = net->ct.helper_sysctl_header->ctl_table_arg;
+	unregister_net_sysctl_table(net->ct.helper_sysctl_header);
+	kfree(table);
+}
+#else
+static int nf_conntrack_helper_init_sysctl(struct net *net)
+{
+	return 0;
+}
+
+static void nf_conntrack_helper_fini_sysctl(struct net *net)
+{
+}
+#endif /* CONFIG_SYSCTL */
 
 /* Stupid hash, but collision free for the default registrations of the
  * helpers currently in the kernel. */
@@ -118,6 +179,7 @@ int __nf_ct_try_assign_helper(struct nf_conn *ct, struct nf_conn *tmpl,
 {
 	struct nf_conntrack_helper *helper = NULL;
 	struct nf_conn_help *help;
+	struct net *net = nf_ct_net(ct);
 	int ret = 0;
 
 	if (tmpl != NULL) {
@@ -127,8 +189,17 @@ int __nf_ct_try_assign_helper(struct nf_conn *ct, struct nf_conn *tmpl,
 	}
 
 	help = nfct_help(ct);
-	if (helper == NULL)
+	if (net->ct.sysctl_auto_assign_helper && helper == NULL) {
 		helper = __nf_ct_helper_find(&ct->tuplehash[IP_CT_DIR_REPLY].tuple);
+		if (unlikely(!net->ct.auto_assign_helper_warned && helper)) {
+			pr_info("nf_conntrack: automatic helper "
+				"assignment is deprecated and it will "
+				"be removed soon. Use the iptables CT target "
+				"to attach helpers instead.\n");
+			net->ct.auto_assign_helper_warned = true;
+		}
+	}
+
 	if (helper == NULL) {
 		if (help)
 			RCU_INIT_POINTER(help->helper, NULL);
@@ -315,28 +386,44 @@ static struct nf_ct_ext_type helper_extend __read_mostly = {
 	.id	= NF_CT_EXT_HELPER,
 };
 
-int nf_conntrack_helper_init(void)
+int nf_conntrack_helper_init(struct net *net)
 {
 	int err;
 
-	nf_ct_helper_hsize = 1; /* gets rounded up to use one page */
-	nf_ct_helper_hash = nf_ct_alloc_hashtable(&nf_ct_helper_hsize, 0);
-	if (!nf_ct_helper_hash)
-		return -ENOMEM;
+	net->ct.auto_assign_helper_warned = false;
+	net->ct.sysctl_auto_assign_helper = nf_ct_auto_assign_helper;
 
-	err = nf_ct_extend_register(&helper_extend);
+	if (net_eq(net, &init_net)) {
+		nf_ct_helper_hsize = 1; /* gets rounded up to use one page */
+		nf_ct_helper_hash =
+			nf_ct_alloc_hashtable(&nf_ct_helper_hsize, 0);
+		if (!nf_ct_helper_hash)
+			return -ENOMEM;
+
+		err = nf_ct_extend_register(&helper_extend);
+		if (err < 0)
+			goto err1;
+	}
+
+	err = nf_conntrack_helper_init_sysctl(net);
 	if (err < 0)
-		goto err1;
+		goto out_sysctl;
 
 	return 0;
 
+out_sysctl:
+	if (net_eq(net, &init_net))
+		nf_ct_extend_unregister(&helper_extend);
 err1:
 	nf_ct_free_hashtable(nf_ct_helper_hash, nf_ct_helper_hsize);
 	return err;
 }
 
-void nf_conntrack_helper_fini(void)
+void nf_conntrack_helper_fini(struct net *net)
 {
-	nf_ct_extend_unregister(&helper_extend);
-	nf_ct_free_hashtable(nf_ct_helper_hash, nf_ct_helper_hsize);
+	nf_conntrack_helper_fini_sysctl(net);
+	if (net_eq(net, &init_net)) {
+		nf_ct_extend_unregister(&helper_extend);
+		nf_ct_free_hashtable(nf_ct_helper_hash, nf_ct_helper_hsize);
+	}
 }
-- 
1.7.9.5
