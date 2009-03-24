From: Patrick McHardy <kaber@trash.net>
Subject: net 34/41: netfilter conntrack - add per-net functionality for DCCP protocol
Date: Tue, 24 Mar 2009 15:03:52 +0100 (MET)
Message-ID: <20090324140348.31401.74422.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 1546000fe8db0d3f47b0ef1dd487ec23fbd95313
Author: Cyrill Gorcunov <gorcunov@openvz.org>
Date:   Mon Mar 16 16:30:49 2009 +0100

    net: netfilter conntrack - add per-net functionality for DCCP protocol
    
    Module specific data moved into per-net site and being allocated/freed
    during net namespace creation/deletion.
    
    Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
    Acked-by: Daniel Lezcano <daniel.lezcano@free.fr>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index 8fcf176..d3d5a7f 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -16,6 +16,9 @@
 #include <linux/skbuff.h>
 #include <linux/dccp.h>
 
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
+
 #include <linux/netfilter/nfnetlink_conntrack.h>
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_l4proto.h>
@@ -23,8 +26,6 @@
 
 static DEFINE_RWLOCK(dccp_lock);
 
-static int nf_ct_dccp_loose __read_mostly = 1;
-
 /* Timeouts are based on values from RFC4340:
  *
  * - REQUEST:
@@ -72,16 +73,6 @@ static int nf_ct_dccp_loose __read_mostly = 1;
 
 #define DCCP_MSL (2 * 60 * HZ)
 
-static unsigned int dccp_timeout[CT_DCCP_MAX + 1] __read_mostly = {
-	[CT_DCCP_REQUEST]	= 2 * DCCP_MSL,
-	[CT_DCCP_RESPOND]	= 4 * DCCP_MSL,
-	[CT_DCCP_PARTOPEN]	= 4 * DCCP_MSL,
-	[CT_DCCP_OPEN]		= 12 * 3600 * HZ,
-	[CT_DCCP_CLOSEREQ]	= 64 * HZ,
-	[CT_DCCP_CLOSING]	= 64 * HZ,
-	[CT_DCCP_TIMEWAIT]	= 2 * DCCP_MSL,
-};
-
 static const char * const dccp_state_names[] = {
 	[CT_DCCP_NONE]		= "NONE",
 	[CT_DCCP_REQUEST]	= "REQUEST",
@@ -393,6 +384,22 @@ dccp_state_table[CT_DCCP_ROLE_MAX + 1][DCCP_PKT_SYNCACK + 1][CT_DCCP_MAX + 1] =
 	},
 };
 
+/* this module per-net specifics */
+static int dccp_net_id;
+struct dccp_net {
+	int dccp_loose;
+	unsigned int dccp_timeout[CT_DCCP_MAX + 1];
+#ifdef CONFIG_SYSCTL
+	struct ctl_table_header *sysctl_header;
+	struct ctl_table *sysctl_table;
+#endif
+};
+
+static inline struct dccp_net *dccp_pernet(struct net *net)
+{
+	return net_generic(net, dccp_net_id);
+}
+
 static bool dccp_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
 			      struct nf_conntrack_tuple *tuple)
 {
@@ -419,6 +426,7 @@ static bool dccp_new(struct nf_conn *ct, const struct sk_buff *skb,
 		     unsigned int dataoff)
 {
 	struct net *net = nf_ct_net(ct);
+	struct dccp_net *dn;
 	struct dccp_hdr _dh, *dh;
 	const char *msg;
 	u_int8_t state;
@@ -429,7 +437,8 @@ static bool dccp_new(struct nf_conn *ct, const struct sk_buff *skb,
 	state = dccp_state_table[CT_DCCP_ROLE_CLIENT][dh->dccph_type][CT_DCCP_NONE];
 	switch (state) {
 	default:
-		if (nf_ct_dccp_loose == 0) {
+		dn = dccp_pernet(net);
+		if (dn->dccp_loose == 0) {
 			msg = "nf_ct_dccp: not picking up existing connection ";
 			goto out_invalid;
 		}
@@ -465,6 +474,7 @@ static int dccp_packet(struct nf_conn *ct, const struct sk_buff *skb,
 		       u_int8_t pf, unsigned int hooknum)
 {
 	struct net *net = nf_ct_net(ct);
+	struct dccp_net *dn;
 	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
 	struct dccp_hdr _dh, *dh;
 	u_int8_t type, old_state, new_state;
@@ -542,7 +552,9 @@ static int dccp_packet(struct nf_conn *ct, const struct sk_buff *skb,
 	ct->proto.dccp.last_pkt = type;
 	ct->proto.dccp.state = new_state;
 	write_unlock_bh(&dccp_lock);
-	nf_ct_refresh_acct(ct, ctinfo, skb, dccp_timeout[new_state]);
+
+	dn = dccp_pernet(net);
+	nf_ct_refresh_acct(ct, ctinfo, skb, dn->dccp_timeout[new_state]);
 
 	return NF_ACCEPT;
 }
@@ -660,13 +672,11 @@ static int nlattr_to_dccp(struct nlattr *cda[], struct nf_conn *ct)
 #endif
 
 #ifdef CONFIG_SYSCTL
-static unsigned int dccp_sysctl_table_users;
-static struct ctl_table_header *dccp_sysctl_header;
-static ctl_table dccp_sysctl_table[] = {
+/* template, data assigned later */
+static struct ctl_table dccp_sysctl_table[] = {
 	{
 		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "nf_conntrack_dccp_timeout_request",
-		.data		= &dccp_timeout[CT_DCCP_REQUEST],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
@@ -674,7 +684,6 @@ static ctl_table dccp_sysctl_table[] = {
 	{
 		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "nf_conntrack_dccp_timeout_respond",
-		.data		= &dccp_timeout[CT_DCCP_RESPOND],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
@@ -682,7 +691,6 @@ static ctl_table dccp_sysctl_table[] = {
 	{
 		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "nf_conntrack_dccp_timeout_partopen",
-		.data		= &dccp_timeout[CT_DCCP_PARTOPEN],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
@@ -690,7 +698,6 @@ static ctl_table dccp_sysctl_table[] = {
 	{
 		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "nf_conntrack_dccp_timeout_open",
-		.data		= &dccp_timeout[CT_DCCP_OPEN],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
@@ -698,7 +705,6 @@ static ctl_table dccp_sysctl_table[] = {
 	{
 		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "nf_conntrack_dccp_timeout_closereq",
-		.data		= &dccp_timeout[CT_DCCP_CLOSEREQ],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
@@ -706,7 +712,6 @@ static ctl_table dccp_sysctl_table[] = {
 	{
 		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "nf_conntrack_dccp_timeout_closing",
-		.data		= &dccp_timeout[CT_DCCP_CLOSING],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
@@ -714,7 +719,6 @@ static ctl_table dccp_sysctl_table[] = {
 	{
 		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "nf_conntrack_dccp_timeout_timewait",
-		.data		= &dccp_timeout[CT_DCCP_TIMEWAIT],
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
@@ -722,8 +726,7 @@ static ctl_table dccp_sysctl_table[] = {
 	{
 		.ctl_name	= CTL_UNNUMBERED,
 		.procname	= "nf_conntrack_dccp_loose",
-		.data		= &nf_ct_dccp_loose,
-		.maxlen		= sizeof(nf_ct_dccp_loose),
+		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
@@ -751,11 +754,6 @@ static struct nf_conntrack_l4proto dccp_proto4 __read_mostly = {
 	.nlattr_to_tuple	= nf_ct_port_nlattr_to_tuple,
 	.nla_policy		= nf_ct_port_nla_policy,
 #endif
-#ifdef CONFIG_SYSCTL
-	.ctl_table_users	= &dccp_sysctl_table_users,
-	.ctl_table_header	= &dccp_sysctl_header,
-	.ctl_table		= dccp_sysctl_table,
-#endif
 };
 
 static struct nf_conntrack_l4proto dccp_proto6 __read_mostly = {
@@ -776,34 +774,107 @@ static struct nf_conntrack_l4proto dccp_proto6 __read_mostly = {
 	.nlattr_to_tuple	= nf_ct_port_nlattr_to_tuple,
 	.nla_policy		= nf_ct_port_nla_policy,
 #endif
+};
+
+static __net_init int dccp_net_init(struct net *net)
+{
+	struct dccp_net *dn;
+	int err;
+
+	dn = kmalloc(sizeof(*dn), GFP_KERNEL);
+	if (!dn)
+		return -ENOMEM;
+
+	/* default values */
+	dn->dccp_loose = 1;
+	dn->dccp_timeout[CT_DCCP_REQUEST]	= 2 * DCCP_MSL;
+	dn->dccp_timeout[CT_DCCP_RESPOND]	= 4 * DCCP_MSL;
+	dn->dccp_timeout[CT_DCCP_PARTOPEN]	= 4 * DCCP_MSL;
+	dn->dccp_timeout[CT_DCCP_OPEN]		= 12 * 3600 * HZ;
+	dn->dccp_timeout[CT_DCCP_CLOSEREQ]	= 64 * HZ;
+	dn->dccp_timeout[CT_DCCP_CLOSING]	= 64 * HZ;
+	dn->dccp_timeout[CT_DCCP_TIMEWAIT]	= 2 * DCCP_MSL;
+
+	err = net_assign_generic(net, dccp_net_id, dn);
+	if (err)
+		goto out;
+
 #ifdef CONFIG_SYSCTL
-	.ctl_table_users	= &dccp_sysctl_table_users,
-	.ctl_table_header	= &dccp_sysctl_header,
-	.ctl_table		= dccp_sysctl_table,
+	err = -ENOMEM;
+	dn->sysctl_table = kmemdup(dccp_sysctl_table,
+			sizeof(dccp_sysctl_table), GFP_KERNEL);
+	if (!dn->sysctl_table)
+		goto out;
+
+	dn->sysctl_table[0].data = &dn->dccp_timeout[CT_DCCP_REQUEST];
+	dn->sysctl_table[1].data = &dn->dccp_timeout[CT_DCCP_RESPOND];
+	dn->sysctl_table[2].data = &dn->dccp_timeout[CT_DCCP_PARTOPEN];
+	dn->sysctl_table[3].data = &dn->dccp_timeout[CT_DCCP_OPEN];
+	dn->sysctl_table[4].data = &dn->dccp_timeout[CT_DCCP_CLOSEREQ];
+	dn->sysctl_table[5].data = &dn->dccp_timeout[CT_DCCP_CLOSING];
+	dn->sysctl_table[6].data = &dn->dccp_timeout[CT_DCCP_TIMEWAIT];
+	dn->sysctl_table[7].data = &dn->dccp_loose;
+
+	dn->sysctl_header = register_net_sysctl_table(net,
+			nf_net_netfilter_sysctl_path, dn->sysctl_table);
+	if (!dn->sysctl_header) {
+		kfree(dn->sysctl_table);
+		goto out;
+	}
 #endif
+
+	return 0;
+
+out:
+	kfree(dn);
+	return err;
+}
+
+static __net_exit void dccp_net_exit(struct net *net)
+{
+	struct dccp_net *dn = dccp_pernet(net);
+#ifdef CONFIG_SYSCTL
+	unregister_net_sysctl_table(dn->sysctl_header);
+	kfree(dn->sysctl_table);
+#endif
+	kfree(dn);
+
+	net_assign_generic(net, dccp_net_id, NULL);
+}
+
+static struct pernet_operations dccp_net_ops = {
+	.init = dccp_net_init,
+	.exit = dccp_net_exit,
 };
 
 static int __init nf_conntrack_proto_dccp_init(void)
 {
 	int err;
 
-	err = nf_conntrack_l4proto_register(&dccp_proto4);
+	err = register_pernet_gen_subsys(&dccp_net_id, &dccp_net_ops);
 	if (err < 0)
 		goto err1;
 
-	err = nf_conntrack_l4proto_register(&dccp_proto6);
+	err = nf_conntrack_l4proto_register(&dccp_proto4);
 	if (err < 0)
 		goto err2;
+
+	err = nf_conntrack_l4proto_register(&dccp_proto6);
+	if (err < 0)
+		goto err3;
 	return 0;
 
-err2:
+err3:
 	nf_conntrack_l4proto_unregister(&dccp_proto4);
+err2:
+	unregister_pernet_gen_subsys(dccp_net_id, &dccp_net_ops);
 err1:
 	return err;
 }
 
 static void __exit nf_conntrack_proto_dccp_fini(void)
 {
+	unregister_pernet_gen_subsys(dccp_net_id, &dccp_net_ops);
 	nf_conntrack_l4proto_unregister(&dccp_proto6);
 	nf_conntrack_l4proto_unregister(&dccp_proto4);
 }
