From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 04/17] netfilter: add namespace support for l4proto_generic
Date: Mon, 14 May 2012 16:52:14 +0800
Message-ID: <1336985547-31960-5-git-send-email-gaofeng@cn.fujitsu.com>
References: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

implement and export nf_conntrack_proto_generic_[init,fini],
nf_conntrack_[init,cleanup]_net call them to register or unregister
the sysctl of generic proto.

implement generic_net_init,it's used to initial the pernet
data for generic proto.

and use nf_generic_net.timeout to replace nf_ct_generic_timeout in
get_timeouts function.

Acked-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/net/netfilter/nf_conntrack_l4proto.h |    2 +
 include/net/netns/conntrack.h                |    6 +++
 net/netfilter/nf_conntrack_core.c            |    8 +++-
 net/netfilter/nf_conntrack_proto.c           |   21 +++++-----
 net/netfilter/nf_conntrack_proto_generic.c   |   55 ++++++++++++++++++++++++-
 5 files changed, 76 insertions(+), 16 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index a93dcd5..0d329b9 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -118,6 +118,8 @@ struct nf_conntrack_l4proto {
 
 /* Existing built-in generic protocol */
 extern struct nf_conntrack_l4proto nf_conntrack_l4proto_generic;
+extern int nf_conntrack_proto_generic_init(struct net *net);
+extern void nf_conntrack_proto_generic_fini(struct net *net);
 
 #define MAX_NF_CT_PROTO 256
 
diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index 94992e9..3381b80 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -20,7 +20,13 @@ struct nf_proto_net {
 	unsigned int		users;
 };
 
+struct nf_generic_net {
+	struct nf_proto_net pn;
+	unsigned int timeout;
+};
+
 struct nf_ip_net {
+	struct nf_generic_net   generic;
 #if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
 	struct ctl_table_header *ctl_table_header;
 	struct ctl_table	*ctl_table;
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 32c5909..fd33e91 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1353,6 +1353,7 @@ static void nf_conntrack_cleanup_net(struct net *net)
 	}
 
 	nf_ct_free_hashtable(net->ct.hash, net->ct.htable_size);
+	nf_conntrack_proto_generic_fini(net);
 	nf_conntrack_helper_fini(net);
 	nf_conntrack_timeout_fini(net);
 	nf_conntrack_ecache_fini(net);
@@ -1586,9 +1587,12 @@ static int nf_conntrack_init_net(struct net *net)
 	ret = nf_conntrack_helper_init(net);
 	if (ret < 0)
 		goto err_helper;
-
+	ret = nf_conntrack_proto_generic_init(net);
+	if (ret < 0)
+		goto err_generic;
 	return 0;
-
+err_generic:
+	nf_conntrack_helper_fini(net);
 err_helper:
 	nf_conntrack_timeout_fini(net);
 err_timeout:
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 7ee6653..9b4bf6d 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -287,10 +287,16 @@ EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_unregister);
 static struct nf_proto_net *nf_ct_l4proto_net(struct net *net,
 					      struct nf_conntrack_l4proto *l4proto)
 {
-	if (l4proto->net_id)
-		return net_generic(net, *l4proto->net_id);
-	else
-		return NULL;
+	switch (l4proto->l4proto) {
+	case 255: /* l4proto_generic */
+		return (struct nf_proto_net *)&net->ct.proto.generic;
+	default:
+		if (l4proto->net_id)
+			return net_generic(net, *l4proto->net_id);
+		else
+			return NULL;
+	}
+	return NULL;
 }
 
 int nf_ct_l4proto_register_sysctl(struct net *net,
@@ -457,11 +463,6 @@ EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_unregister);
 int nf_conntrack_proto_init(void)
 {
 	unsigned int i;
-	int err;
-
-	err = nf_ct_l4proto_register_sysctl(&init_net, &nf_conntrack_l4proto_generic);
-	if (err < 0)
-		return err;
 
 	for (i = 0; i < AF_MAX; i++)
 		rcu_assign_pointer(nf_ct_l3protos[i],
@@ -473,8 +474,6 @@ void nf_conntrack_proto_fini(void)
 {
 	unsigned int i;
 
-	nf_ct_l4proto_unregister_sysctl(&init_net, &nf_conntrack_l4proto_generic);
-
 	/* free l3proto protocol tables */
 	for (i = 0; i < PF_MAX; i++)
 		kfree(nf_ct_protos[i]);
diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netfilter/nf_conntrack_proto_generic.c
index d8923d5..7976a64 100644
--- a/net/netfilter/nf_conntrack_proto_generic.c
+++ b/net/netfilter/nf_conntrack_proto_generic.c
@@ -14,6 +14,11 @@
 
 static unsigned int nf_ct_generic_timeout __read_mostly = 600*HZ;
 
+static inline struct nf_generic_net *generic_pernet(struct net *net)
+{
+	return &net->ct.proto.generic;
+}
+
 static bool generic_pkt_to_tuple(const struct sk_buff *skb,
 				 unsigned int dataoff,
 				 struct nf_conntrack_tuple *tuple)
@@ -42,7 +47,7 @@ static int generic_print_tuple(struct seq_file *s,
 
 static unsigned int *generic_get_timeouts(struct net *net)
 {
-	return &nf_ct_generic_timeout;
+	return &(generic_pernet(net)->timeout);
 }
 
 /* Returns verdict for packet, or -1 for invalid. */
@@ -110,7 +115,6 @@ static struct ctl_table_header *generic_sysctl_header;
 static struct ctl_table generic_sysctl_table[] = {
 	{
 		.procname	= "nf_conntrack_generic_timeout",
-		.data		= &nf_ct_generic_timeout,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
@@ -121,7 +125,6 @@ static struct ctl_table generic_sysctl_table[] = {
 static struct ctl_table generic_compat_sysctl_table[] = {
 	{
 		.procname	= "ip_conntrack_generic_timeout",
-		.data		= &nf_ct_generic_timeout,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
@@ -131,10 +134,39 @@ static struct ctl_table generic_compat_sysctl_table[] = {
 #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 #endif /* CONFIG_SYSCTL */
 
+static int generic_init_net(struct net *net, u_int8_t compat)
+{
+	struct nf_generic_net *gn = generic_pernet(net);
+	struct nf_proto_net *pn = (struct nf_proto_net *)gn;
+	gn->timeout = nf_ct_generic_timeout;
+#ifdef CONFIG_SYSCTL
+	pn->ctl_table = kmemdup(generic_sysctl_table,
+				sizeof(generic_sysctl_table),
+				GFP_KERNEL);
+	if (!pn->ctl_table)
+		return -ENOMEM;
+	pn->ctl_table[0].data = &gn->timeout;
+
+#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
+	pn->ctl_compat_table = kmemdup(generic_compat_sysctl_table,
+				       sizeof(generic_compat_sysctl_table),
+				       GFP_KERNEL);
+	if (!pn->ctl_compat_table) {
+		kfree(pn->ctl_table);
+		pn->ctl_table = NULL;
+		return -ENOMEM;
+	}
+	pn->ctl_compat_table[0].data = &gn->timeout;
+#endif
+#endif
+	return 0;
+}
+
 struct nf_conntrack_l4proto nf_conntrack_l4proto_generic __read_mostly =
 {
 	.l3proto		= PF_UNSPEC,
 	.l4proto		= 255,
+	.compat			= 1,
 	.name			= "unknown",
 	.pkt_to_tuple		= generic_pkt_to_tuple,
 	.invert_tuple		= generic_invert_tuple,
@@ -158,4 +190,21 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_generic __read_mostly =
 	.ctl_compat_table	= generic_compat_sysctl_table,
 #endif
 #endif
+	.init_net		= generic_init_net,
 };
+
+int nf_conntrack_proto_generic_init(struct net *net)
+{
+	int ret = 0;
+	ret = generic_init_net(net, nf_conntrack_l4proto_generic.compat);
+	if (ret < 0)
+		return ret;
+	return nf_ct_l4proto_register_sysctl(net,
+					     &nf_conntrack_l4proto_generic);
+}
+
+void nf_conntrack_proto_generic_fini(struct net *net)
+{
+	nf_ct_l4proto_unregister_sysctl(net,
+					&nf_conntrack_l4proto_generic);
+}
-- 
1.7.7.6

