From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 12/15] netfilter: adjust l4proto_dccp to the nf_conntrack_l4proto_register
Date: Tue, 29 May 2012 15:04:20 +0800
Message-ID: <1338275063-11711-13-git-send-email-gaofeng@cn.fujitsu.com>
References: <1338275063-11711-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1338275063-11711-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

move the nf_conntrack_l4proto_register from module_init to
dccp_net_ops.init,and change the struct dccp_net to adjust
to the nf_conntrack_l4proto_register.

Acked-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/netfilter/nf_conntrack_proto_dccp.c |  133 ++++++++++++++++---------------
 1 files changed, 67 insertions(+), 66 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index 5a8e037..0623d48 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -387,12 +387,9 @@ dccp_state_table[CT_DCCP_ROLE_MAX + 1][DCCP_PKT_SYNCACK + 1][CT_DCCP_MAX + 1] =
 /* this module per-net specifics */
 static int dccp_net_id __read_mostly;
 struct dccp_net {
+	struct nf_proto_net np;
 	int dccp_loose;
 	unsigned int dccp_timeout[CT_DCCP_MAX + 1];
-#ifdef CONFIG_SYSCTL
-	struct ctl_table_header *sysctl_header;
-	struct ctl_table *sysctl_table;
-#endif
 };
 
 static inline struct dccp_net *dccp_pernet(struct net *net)
@@ -817,6 +814,46 @@ static struct ctl_table dccp_sysctl_table[] = {
 };
 #endif /* CONFIG_SYSCTL */
 
+static int dccp_init_net(struct net *net)
+{
+
+	struct dccp_net *dn = dccp_pernet(net);
+	struct nf_proto_net *pn = (struct nf_proto_net *)dn;
+
+#ifdef CONFIG_SYSCTL
+	if (!pn->ctl_table) {
+#else
+	if (!pn->users++) {
+#endif
+		/* default values */
+		dn->dccp_loose = 1;
+		dn->dccp_timeout[CT_DCCP_REQUEST]	= 2 * DCCP_MSL;
+		dn->dccp_timeout[CT_DCCP_RESPOND]	= 4 * DCCP_MSL;
+		dn->dccp_timeout[CT_DCCP_PARTOPEN]	= 4 * DCCP_MSL;
+		dn->dccp_timeout[CT_DCCP_OPEN]		= 12 * 3600 * HZ;
+		dn->dccp_timeout[CT_DCCP_CLOSEREQ]	= 64 * HZ;
+		dn->dccp_timeout[CT_DCCP_CLOSING]	= 64 * HZ;
+		dn->dccp_timeout[CT_DCCP_TIMEWAIT]	= 2 * DCCP_MSL;
+#ifdef CONFIG_SYSCTL
+		pn->ctl_table = kmemdup(dccp_sysctl_table,
+					sizeof(dccp_sysctl_table),
+					GFP_KERNEL);
+		if (!pn->ctl_table)
+			return -ENOMEM;
+
+		pn->ctl_table[0].data = &dn->dccp_timeout[CT_DCCP_REQUEST];
+		pn->ctl_table[1].data = &dn->dccp_timeout[CT_DCCP_RESPOND];
+		pn->ctl_table[2].data = &dn->dccp_timeout[CT_DCCP_PARTOPEN];
+		pn->ctl_table[3].data = &dn->dccp_timeout[CT_DCCP_OPEN];
+		pn->ctl_table[4].data = &dn->dccp_timeout[CT_DCCP_CLOSEREQ];
+		pn->ctl_table[5].data = &dn->dccp_timeout[CT_DCCP_CLOSING];
+		pn->ctl_table[6].data = &dn->dccp_timeout[CT_DCCP_TIMEWAIT];
+		pn->ctl_table[7].data = &dn->dccp_loose;
+#endif
+	}
+	return 0;
+}
+
 static struct nf_conntrack_l4proto dccp_proto4 __read_mostly = {
 	.l3proto		= AF_INET,
 	.l4proto		= IPPROTO_DCCP,
@@ -847,6 +884,8 @@ static struct nf_conntrack_l4proto dccp_proto4 __read_mostly = {
 		.nla_policy	= dccp_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
+	.net_id			= &dccp_net_id,
+	.init_net		= dccp_init_net,
 };
 
 static struct nf_conntrack_l4proto dccp_proto6 __read_mostly = {
@@ -879,55 +918,39 @@ static struct nf_conntrack_l4proto dccp_proto6 __read_mostly = {
 		.nla_policy	= dccp_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
+	.net_id			= &dccp_net_id,
+	.init_net		= dccp_init_net,
 };
 
 static __net_init int dccp_net_init(struct net *net)
 {
-	struct dccp_net *dn = dccp_pernet(net);
-
-	/* default values */
-	dn->dccp_loose = 1;
-	dn->dccp_timeout[CT_DCCP_REQUEST]	= 2 * DCCP_MSL;
-	dn->dccp_timeout[CT_DCCP_RESPOND]	= 4 * DCCP_MSL;
-	dn->dccp_timeout[CT_DCCP_PARTOPEN]	= 4 * DCCP_MSL;
-	dn->dccp_timeout[CT_DCCP_OPEN]		= 12 * 3600 * HZ;
-	dn->dccp_timeout[CT_DCCP_CLOSEREQ]	= 64 * HZ;
-	dn->dccp_timeout[CT_DCCP_CLOSING]	= 64 * HZ;
-	dn->dccp_timeout[CT_DCCP_TIMEWAIT]	= 2 * DCCP_MSL;
-
-#ifdef CONFIG_SYSCTL
-	dn->sysctl_table = kmemdup(dccp_sysctl_table,
-			sizeof(dccp_sysctl_table), GFP_KERNEL);
-	if (!dn->sysctl_table)
-		return -ENOMEM;
-
-	dn->sysctl_table[0].data = &dn->dccp_timeout[CT_DCCP_REQUEST];
-	dn->sysctl_table[1].data = &dn->dccp_timeout[CT_DCCP_RESPOND];
-	dn->sysctl_table[2].data = &dn->dccp_timeout[CT_DCCP_PARTOPEN];
-	dn->sysctl_table[3].data = &dn->dccp_timeout[CT_DCCP_OPEN];
-	dn->sysctl_table[4].data = &dn->dccp_timeout[CT_DCCP_CLOSEREQ];
-	dn->sysctl_table[5].data = &dn->dccp_timeout[CT_DCCP_CLOSING];
-	dn->sysctl_table[6].data = &dn->dccp_timeout[CT_DCCP_TIMEWAIT];
-	dn->sysctl_table[7].data = &dn->dccp_loose;
-
-	dn->sysctl_header = register_net_sysctl(net, "net/netfilter",
-						dn->sysctl_table);
-	if (!dn->sysctl_header) {
-		kfree(dn->sysctl_table);
-		return -ENOMEM;
+	int ret = 0;
+	ret = nf_conntrack_l4proto_register(net,
+					    &dccp_proto4);
+	if (ret < 0) {
+		pr_err("nf_conntrack_l4proto_dccp4 :protocol register failed.\n");
+		goto out;
+	}
+	ret = nf_conntrack_l4proto_register(net,
+					    &dccp_proto6);
+	if (ret < 0) {
+		pr_err("nf_conntrack_l4proto_dccp6 :protocol register failed.\n");
+		goto cleanup_dccp4;
 	}
-#endif
-
 	return 0;
+cleanup_dccp4:
+	nf_conntrack_l4proto_unregister(net,
+					&dccp_proto4);
+out:
+	return ret;
 }
 
 static __net_exit void dccp_net_exit(struct net *net)
 {
-	struct dccp_net *dn = dccp_pernet(net);
-#ifdef CONFIG_SYSCTL
-	unregister_net_sysctl_table(dn->sysctl_header);
-	kfree(dn->sysctl_table);
-#endif
+	nf_conntrack_l4proto_unregister(net,
+					&dccp_proto6);
+	nf_conntrack_l4proto_unregister(net,
+					&dccp_proto4);
 }
 
 static struct pernet_operations dccp_net_ops = {
@@ -939,34 +962,12 @@ static struct pernet_operations dccp_net_ops = {
 
 static int __init nf_conntrack_proto_dccp_init(void)
 {
-	int err;
-
-	err = register_pernet_subsys(&dccp_net_ops);
-	if (err < 0)
-		goto err1;
-
-	err = nf_conntrack_l4proto_register(&init_net, &dccp_proto4);
-	if (err < 0)
-		goto err2;
-
-	err = nf_conntrack_l4proto_register(&init_net, &dccp_proto6);
-	if (err < 0)
-		goto err3;
-	return 0;
-
-err3:
-	nf_conntrack_l4proto_unregister(&init_net, &dccp_proto4);
-err2:
-	unregister_pernet_subsys(&dccp_net_ops);
-err1:
-	return err;
+	return register_pernet_subsys(&dccp_net_ops);
 }
 
 static void __exit nf_conntrack_proto_dccp_fini(void)
 {
 	unregister_pernet_subsys(&dccp_net_ops);
-	nf_conntrack_l4proto_unregister(&init_net, &dccp_proto6);
-	nf_conntrack_l4proto_unregister(&init_net, &dccp_proto4);
 }
 
 module_init(nf_conntrack_proto_dccp_init);
-- 
1.7.7.6

