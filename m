From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [RFC v2 7/7] net: netfilter conntrack - add per-net functionality for ICMP protocol
Date: Wed, 11 Mar 2009 23:57:13 +0300
Message-ID: <20090311210817.976738435@gmail.com>
References: <20090311205706.141086138@gmail.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	xemul@openvz.org, adobriyan@gmail.com,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: kaber@trash.net, davem@davemloft.net, daniel.lezcano@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.185]:62190 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752592AbZCKVIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 17:08:34 -0400
Content-Disposition: inline; filename=net-namespace-nf-conntrack-proto-icmp
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Module specific data moved into per-net site and being allocated/freed
during net namespace creation/deletion. For this reason module_init/exit
calls added.

Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c |  128 +++++++++++++++++++++++++--
 1 file changed, 120 insertions(+), 8 deletions(-)

Index: linux-2.6.git/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
===================================================================
--- linux-2.6.git.orig/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ linux-2.6.git/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -9,6 +9,7 @@
 #include <linux/types.h>
 #include <linux/timer.h>
 #include <linux/netfilter.h>
+#include <linux/module.h>
 #include <linux/in.h>
 #include <linux/icmp.h>
 #include <linux/seq_file.h>
@@ -20,7 +21,27 @@
 #include <net/netfilter/nf_conntrack_core.h>
 #include <net/netfilter/nf_log.h>
 
-static unsigned int nf_ct_icmp_timeout __read_mostly = 30*HZ;
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
+
+/* per-net specifics */
+static int icmp_net_id;
+struct icmp_net {
+	unsigned int icmp_timeout;
+#ifdef CONFIG_SYSCTL
+	struct ctl_table_header *sysctl_header;
+	struct ctl_table *sysctl_table;
+#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
+	struct ctl_table_header *compat_sysctl_header;
+	struct ctl_table *compat_sysctl_table;
+#endif
+#endif
+};
+
+static inline struct icmp_net *icmp_pernet(struct net *net)
+{
+	return net_generic(net, icmp_net_id);
+}
 
 static bool icmp_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
 			      struct nf_conntrack_tuple *tuple)
@@ -90,9 +111,10 @@ static int icmp_packet(struct nf_conn *c
 		if (atomic_dec_and_test(&ct->proto.icmp.count))
 			nf_ct_kill_acct(ct, ctinfo, skb);
 	} else {
+		struct icmp_net *in = icmp_pernet(nf_ct_net(ct));
 		atomic_inc(&ct->proto.icmp.count);
 		nf_conntrack_event_cache(IPCT_PROTOINFO_VOLATILE, ct);
-		nf_ct_refresh_acct(ct, ctinfo, skb, nf_ct_icmp_timeout);
+		nf_ct_refresh_acct(ct, ctinfo, skb, in->icmp_timeout);
 	}
 
 	return NF_ACCEPT;
@@ -265,11 +287,10 @@ static int icmp_nlattr_to_tuple(struct n
 #endif
 
 #ifdef CONFIG_SYSCTL
-static struct ctl_table_header *icmp_sysctl_header;
+/* templates, data assigned later */
 static struct ctl_table icmp_sysctl_table[] = {
 	{
 		.procname	= "nf_conntrack_icmp_timeout",
-		.data		= &nf_ct_icmp_timeout,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
@@ -282,7 +303,6 @@ static struct ctl_table icmp_sysctl_tabl
 static struct ctl_table icmp_compat_sysctl_table[] = {
 	{
 		.procname	= "ip_conntrack_icmp_timeout",
-		.data		= &nf_ct_icmp_timeout,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
@@ -312,11 +332,103 @@ struct nf_conntrack_l4proto nf_conntrack
 	.nlattr_to_tuple	= icmp_nlattr_to_tuple,
 	.nla_policy		= icmp_nla_policy,
 #endif
+};
+
+static __net_init int icmp_net_init(struct net *net)
+{
+	struct icmp_net *in;
+	int err;
+
+	in = kmalloc(sizeof(*in), GFP_KERNEL);
+	if (!in)
+		return -ENOMEM;
+
+	/* default values */
+	in->icmp_timeout = 30 * HZ;
+
+	err = net_assign_generic(net, icmp_net_id, in);
+	if (err)
+		goto out;
+
+#ifdef CONFIG_SYSCTL
+	err = -ENOMEM;
+	in->sysctl_table = kmemdup(icmp_sysctl_table,
+			sizeof(icmp_sysctl_table), GFP_KERNEL);
+	if (!in->sysctl_table)
+		goto out;
+
+	in->sysctl_table[0].data = &in->icmp_timeout;
+
+	in->sysctl_header = register_net_sysctl_table(net,
+			nf_net_netfilter_sysctl_path, in->sysctl_table);
+	if (!in->sysctl_header)
+		goto out_free;
+
+#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
+	in->compat_sysctl_table = kmemdup(icmp_compat_sysctl_table,
+			sizeof(icmp_compat_sysctl_table), GFP_KERNEL);
+	if (!in->compat_sysctl_table)
+		goto out_sysctl;
+
+	in->compat_sysctl_table[0].data = &in->icmp_timeout;
+
+	in->compat_sysctl_header = register_net_sysctl_table(net,
+			nf_net_ipv4_netfilter_sysctl_path,
+			in->compat_sysctl_table);
+	if (!in->compat_sysctl_header)
+		goto out_free_compat;
+#endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
+#endif /* CONFIG_SYSCTL */
+
+	return 0;
+
+#ifdef CONFIG_SYSCTL
+#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
+out_free_compat:
+	kfree(in->compat_sysctl_table);
+#endif
+out_sysctl:
+	unregister_net_sysctl_table(in->sysctl_header);
+out_free:
+	kfree(in->sysctl_table);
+#endif
+
+out:
+	kfree(in);
+	return err;
+}
+
+static __net_exit void icmp_net_exit(struct net *net)
+{
+	struct icmp_net *in = icmp_pernet(net);
 #ifdef CONFIG_SYSCTL
-	.ctl_table_header	= &icmp_sysctl_header,
-	.ctl_table		= icmp_sysctl_table,
+	unregister_net_sysctl_table(in->sysctl_header);
+	kfree(in->sysctl_table);
 #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-	.ctl_compat_table	= icmp_compat_sysctl_table,
+	unregister_net_sysctl_table(in->compat_sysctl_header);
+	kfree(in->compat_sysctl_table);
 #endif
 #endif
+	kfree(in);
+
+	net_assign_generic(net, icmp_net_id, NULL);
+}
+
+static struct pernet_operations icmp_net_ops = {
+	.init = icmp_net_init,
+	.exit = icmp_net_exit,
 };
+
+int __init nf_ct_icmp_proto_init(void)
+{
+	return register_pernet_gen_subsys(&icmp_net_id, &icmp_net_ops);
+}
+
+void __exit nf_ct_icmp_proto_fini(void)
+{
+	unregister_pernet_gen_subsys(icmp_net_id, &icmp_net_ops);
+}
+
+module_init(nf_ct_icmp_proto_init);
+module_exit(nf_ct_icmp_proto_fini);
+MODULE_LICENSE("GPL");

