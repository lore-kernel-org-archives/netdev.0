From: pablo@netfilter.org
Subject: [PATCH 14/25] netfilter: nf_ct_udplite: add namespace support
Date: Mon, 11 Jun 2012 16:43:50 +0200
Message-ID: <1339425841-24171-15-git-send-email-pablo@netfilter.org>
References: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao feng <gaofeng@cn.fujitsu.com>

This patch adds namespace support for UDPlite protocol tracker.

Acked-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_proto_udplite.c |   98 +++++++++++++++++++++++-----
 1 file changed, 80 insertions(+), 18 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index fa142a8..7f85b08 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -35,6 +35,17 @@ static unsigned int udplite_timeouts[UDPLITE_CT_MAX] = {
 	[UDPLITE_CT_REPLIED]	= 180*HZ,
 };
 
+static int udplite_net_id __read_mostly;
+struct udplite_net {
+	struct nf_proto_net pn;
+	unsigned int timeouts[UDPLITE_CT_MAX];
+};
+
+static inline struct udplite_net *udplite_pernet(struct net *net)
+{
+	return net_generic(net, udplite_net_id);
+}
+
 static bool udplite_pkt_to_tuple(const struct sk_buff *skb,
 				 unsigned int dataoff,
 				 struct nf_conntrack_tuple *tuple)
@@ -70,7 +81,7 @@ static int udplite_print_tuple(struct seq_file *s,
 
 static unsigned int *udplite_get_timeouts(struct net *net)
 {
-	return udplite_timeouts;
+	return udplite_pernet(net)->timeouts;
 }
 
 /* Returns verdict for packet, and may modify conntracktype */
@@ -209,14 +220,12 @@ static struct ctl_table_header *udplite_sysctl_header;
 static struct ctl_table udplite_sysctl_table[] = {
 	{
 		.procname	= "nf_conntrack_udplite_timeout",
-		.data		= &udplite_timeouts[UDPLITE_CT_UNREPLIED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
 	{
 		.procname	= "nf_conntrack_udplite_timeout_stream",
-		.data		= &udplite_timeouts[UDPLITE_CT_REPLIED],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
@@ -225,6 +234,31 @@ static struct ctl_table udplite_sysctl_table[] = {
 };
 #endif /* CONFIG_SYSCTL */
 
+static int udplite_init_net(struct net *net)
+{
+	int i;
+	struct udplite_net *un = udplite_pernet(net);
+	struct nf_proto_net *pn = (struct nf_proto_net *)un;
+#ifdef CONFIG_SYSCTL
+	if (!pn->ctl_table) {
+#else
+	if (!pn->users++) {
+#endif
+		for (i = 0 ; i < UDPLITE_CT_MAX; i++)
+			un->timeouts[i] = udplite_timeouts[i];
+#ifdef CONFIG_SYSCTL
+		pn->ctl_table = kmemdup(udplite_sysctl_table,
+					sizeof(udplite_sysctl_table),
+					GFP_KERNEL);
+		if (!pn->ctl_table)
+			return -ENOMEM;
+		pn->ctl_table[0].data = &un->timeouts[UDPLITE_CT_UNREPLIED];
+		pn->ctl_table[1].data = &un->timeouts[UDPLITE_CT_REPLIED];
+#endif
+	}
+	return 0;
+}
+
 static struct nf_conntrack_l4proto nf_conntrack_l4proto_udplite4 __read_mostly =
 {
 	.l3proto		= PF_INET,
@@ -258,6 +292,8 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_udplite4 __read_mostly =
 	.ctl_table_header	= &udplite_sysctl_header,
 	.ctl_table		= udplite_sysctl_table,
 #endif
+	.net_id			= &udplite_net_id,
+	.init_net		= udplite_init_net,
 };
 
 static struct nf_conntrack_l4proto nf_conntrack_l4proto_udplite6 __read_mostly =
@@ -293,29 +329,55 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_udplite6 __read_mostly =
 	.ctl_table_header	= &udplite_sysctl_header,
 	.ctl_table		= udplite_sysctl_table,
 #endif
+	.net_id			= &udplite_net_id,
+	.init_net		= udplite_init_net,
 };
 
-static int __init nf_conntrack_proto_udplite_init(void)
+static int udplite_net_init(struct net *net)
 {
-	int err;
-
-	err = nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4proto_udplite4);
-	if (err < 0)
-		goto err1;
-	err = nf_conntrack_l4proto_register(&init_net, &nf_conntrack_l4proto_udplite6);
-	if (err < 0)
-		goto err2;
+	int ret = 0;
+
+	ret = nf_conntrack_l4proto_register(net,
+					    &nf_conntrack_l4proto_udplite4);
+	if (ret < 0) {
+		pr_err("nf_conntrack_l4proto_udplite4 :protocol register failed.\n");
+		goto out;
+	}
+	ret = nf_conntrack_l4proto_register(net,
+					    &nf_conntrack_l4proto_udplite6);
+	if (ret < 0) {
+		pr_err("nf_conntrack_l4proto_udplite4 :protocol register failed.\n");
+		goto cleanup_udplite4;
+	}
 	return 0;
-err2:
-	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_udplite4);
-err1:
-	return err;
+
+cleanup_udplite4:
+	nf_conntrack_l4proto_unregister(net, &nf_conntrack_l4proto_udplite4);
+out:
+	return ret;
+}
+
+static void udplite_net_exit(struct net *net)
+{
+	nf_conntrack_l4proto_unregister(net, &nf_conntrack_l4proto_udplite6);
+	nf_conntrack_l4proto_unregister(net, &nf_conntrack_l4proto_udplite4);
+}
+
+static struct pernet_operations udplite_net_ops = {
+	.init = udplite_net_init,
+	.exit = udplite_net_exit,
+	.id   = &udplite_net_id,
+	.size = sizeof(struct udplite_net),
+};
+
+static int __init nf_conntrack_proto_udplite_init(void)
+{
+	return register_pernet_subsys(&udplite_net_ops);
 }
 
 static void __exit nf_conntrack_proto_udplite_exit(void)
 {
-	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_udplite6);
-	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_udplite4);
+	unregister_pernet_subsys(&udplite_net_ops);
 }
 
 module_init(nf_conntrack_proto_udplite_init);
-- 
1.7.10

