From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 03/15] netfilter: add namespace support for l4proto_generic
Date: Tue, 29 May 2012 15:04:11 +0800
Message-ID: <1338275063-11711-4-git-send-email-gaofeng@cn.fujitsu.com>
References: <1338275063-11711-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1338275063-11711-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

modify nf_conntrack_proto_init(fini) to register l4proto_generic's
sysctl pernet, move nf_conntrack_proto_init from nf_conntrack_init_init_net
to nf_conntrack_init. and move nf_conntrack_proto_fini from
nf_conntrack_cleanup_init_net to nf_conntrack_cleanup.

implement generic_net_init,it's used to initial the pernet
data for generic proto.

and use nf_generic_net.timeout to replace nf_ct_generic_timeout in
get_timeouts function.

Acked-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/net/netfilter/nf_conntrack_core.h  |    4 +-
 include/net/netns/conntrack.h              |    6 ++++
 net/netfilter/nf_conntrack_core.c          |   17 ++++-------
 net/netfilter/nf_conntrack_proto.c         |   46 +++++++++++++++++----------
 net/netfilter/nf_conntrack_proto_generic.c |   38 +++++++++++++++++++++--
 5 files changed, 78 insertions(+), 33 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
index aced085..d8f5b9f 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -28,8 +28,8 @@ extern unsigned int nf_conntrack_in(struct net *net,
 extern int nf_conntrack_init(struct net *net);
 extern void nf_conntrack_cleanup(struct net *net);
 
-extern int nf_conntrack_proto_init(void);
-extern void nf_conntrack_proto_fini(void);
+extern int nf_conntrack_proto_init(struct net *net);
+extern void nf_conntrack_proto_fini(struct net *net);
 
 extern bool
 nf_ct_get_tuple(const struct sk_buff *skb,
diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index b2dbcc5..0ef8592 100644
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
index ac3af97..068f2e0 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1333,7 +1333,6 @@ static void nf_conntrack_cleanup_init_net(void)
 	while (untrack_refs() > 0)
 		schedule();
 
-	nf_conntrack_proto_fini();
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 	nf_ct_extend_unregister(&nf_ct_zone_extend);
 #endif
@@ -1372,7 +1371,7 @@ void nf_conntrack_cleanup(struct net *net)
 	   netfilter framework.  Roll on, two-stage module
 	   delete... */
 	synchronize_net();
-
+	nf_conntrack_proto_fini(net);
 	nf_conntrack_cleanup_net(net);
 
 	if (net_eq(net, &init_net)) {
@@ -1496,11 +1495,6 @@ static int nf_conntrack_init_init_net(void)
 	printk(KERN_INFO "nf_conntrack version %s (%u buckets, %d max)\n",
 	       NF_CONNTRACK_VERSION, nf_conntrack_htable_size,
 	       nf_conntrack_max);
-
-	ret = nf_conntrack_proto_init();
-	if (ret < 0)
-		goto err_proto;
-
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 	ret = nf_ct_extend_register(&nf_ct_zone_extend);
 	if (ret < 0)
@@ -1518,9 +1512,7 @@ static int nf_conntrack_init_init_net(void)
 
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 err_extend:
-	nf_conntrack_proto_fini();
 #endif
-err_proto:
 	return ret;
 }
 
@@ -1583,9 +1575,7 @@ static int nf_conntrack_init_net(struct net *net)
 	ret = nf_conntrack_helper_init(net);
 	if (ret < 0)
 		goto err_helper;
-
 	return 0;
-
 err_helper:
 	nf_conntrack_timeout_fini(net);
 err_timeout:
@@ -1622,6 +1612,9 @@ int nf_conntrack_init(struct net *net)
 		if (ret < 0)
 			goto out_init_net;
 	}
+	ret = nf_conntrack_proto_init(net);
+	if (ret < 0)
+		goto out_proto;
 	ret = nf_conntrack_init_net(net);
 	if (ret < 0)
 		goto out_net;
@@ -1637,6 +1630,8 @@ int nf_conntrack_init(struct net *net)
 	return 0;
 
 out_net:
+	nf_conntrack_proto_fini(net);
+out_proto:
 	if (net_eq(net, &init_net))
 		nf_conntrack_cleanup_init_net();
 out_init_net:
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index a1a8008..3f9c7f0 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -301,10 +301,16 @@ EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_unregister);
 static struct nf_proto_net *nf_ct_l4proto_net(struct net *net,
 					      struct nf_conntrack_l4proto *l4proto)
 {
-	if (l4proto->net_id)
-		return net_generic(net, *l4proto->net_id);
-	else
-		return NULL;
+	switch (l4proto->l4proto) {
+	case 255: /* l4proto_generic */
+		return (struct nf_proto_net *)&net->ct.nf_ct_proto.generic;
+	default:
+		if (l4proto->net_id)
+			return net_generic(net, *l4proto->net_id);
+		else
+			return NULL;
+	}
+	return NULL;
 }
 
 static
@@ -486,28 +492,34 @@ void nf_conntrack_l4proto_unregister(struct net *net,
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_unregister);
 
-int nf_conntrack_proto_init(void)
+int nf_conntrack_proto_init(struct net *net)
 {
 	unsigned int i;
 	int err;
-
-	err = nf_ct_l4proto_register_sysctl(&init_net, &nf_conntrack_l4proto_generic);
+	err = nf_conntrack_l4proto_generic.init_net(net);
 	if (err < 0)
 		return err;
+	err = nf_ct_l4proto_register_sysctl(net,
+					    &nf_conntrack_l4proto_generic);
+	if (err < 0)
+		return err;
 
-	for (i = 0; i < AF_MAX; i++)
-		rcu_assign_pointer(nf_ct_l3protos[i],
-				   &nf_conntrack_l3proto_generic);
+	if (net == &init_net) {
+		for (i = 0; i < AF_MAX; i++)
+			rcu_assign_pointer(nf_ct_l3protos[i],
+					   &nf_conntrack_l3proto_generic);
+	}
 	return 0;
 }
 
-void nf_conntrack_proto_fini(void)
+void nf_conntrack_proto_fini(struct net *net)
 {
 	unsigned int i;
-
-	nf_ct_l4proto_unregister_sysctl(&init_net, &nf_conntrack_l4proto_generic);
-
-	/* free l3proto protocol tables */
-	for (i = 0; i < PF_MAX; i++)
-		kfree(nf_ct_protos[i]);
+	nf_ct_l4proto_unregister_sysctl(net,
+					&nf_conntrack_l4proto_generic);
+	if (net == &init_net) {
+		/* free l3proto protocol tables */
+		for (i = 0; i < PF_MAX; i++)
+			kfree(nf_ct_protos[i]);
+	}
 }
diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netfilter/nf_conntrack_proto_generic.c
index d8923d5..19bc880 100644
--- a/net/netfilter/nf_conntrack_proto_generic.c
+++ b/net/netfilter/nf_conntrack_proto_generic.c
@@ -14,6 +14,11 @@
 
 static unsigned int nf_ct_generic_timeout __read_mostly = 600*HZ;
 
+static inline struct nf_generic_net *generic_pernet(struct net *net)
+{
+	return &net->ct.nf_ct_proto.generic;
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
@@ -131,6 +134,34 @@ static struct ctl_table generic_compat_sysctl_table[] = {
 #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 #endif /* CONFIG_SYSCTL */
 
+static int generic_init_net(struct net *net)
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
@@ -158,4 +189,5 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_generic __read_mostly =
 	.ctl_compat_table	= generic_compat_sysctl_table,
 #endif
 #endif
+	.init_net		= generic_init_net,
 };
-- 
1.7.7.6

