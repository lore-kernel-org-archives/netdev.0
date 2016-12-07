From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/50] netfilter: conntrack: built-in support for DCCP
Date: Wed,  7 Dec 2016 22:52:16 +0100
Message-ID: <1481147576-5690-11-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Davide Caratti <dcaratti@redhat.com>

CONFIG_NF_CT_PROTO_DCCP is no more a tristate. When set to y, connection
tracking support for DCCP protocol is built-in into nf_conntrack.ko.

footprint test:
$ ls -l net/netfilter/nf_conntrack{_proto_dccp,}.ko \
        net/ipv4/netfilter/nf_conntrack_ipv4.ko \
        net/ipv6/netfilter/nf_conntrack_ipv6.ko

(builtin)||  dccp  |  ipv4  |  ipv6  | nf_conntrack
---------++--------+--------+--------+--------------
none     || 469140 | 828755 | 828676 | 6141434
DCCP     ||   -    | 830566 | 829935 | 6533526

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/nf_conntrack_dccp.h    |  2 +-
 include/net/netfilter/ipv4/nf_conntrack_ipv4.h |  3 +
 include/net/netfilter/ipv6/nf_conntrack_ipv6.h |  3 +
 include/net/netns/conntrack.h                  | 14 +++++
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |  3 +
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |  3 +
 net/netfilter/Kconfig                          |  6 +-
 net/netfilter/Makefile                         |  3 +-
 net/netfilter/nf_conntrack_proto_dccp.c        | 79 ++++----------------------
 9 files changed, 41 insertions(+), 75 deletions(-)

diff --git a/include/linux/netfilter/nf_conntrack_dccp.h b/include/linux/netfilter/nf_conntrack_dccp.h
index 40dcc82058d1..ff721d7325cf 100644
--- a/include/linux/netfilter/nf_conntrack_dccp.h
+++ b/include/linux/netfilter/nf_conntrack_dccp.h
@@ -25,7 +25,7 @@ enum ct_dccp_roles {
 #define CT_DCCP_ROLE_MAX	(__CT_DCCP_ROLE_MAX - 1)
 
 #ifdef __KERNEL__
-#include <net/netfilter/nf_conntrack_tuple.h>
+#include <linux/netfilter/nf_conntrack_tuple_common.h>
 
 struct nf_ct_dccp {
 	u_int8_t	role[IP_CT_DIR_MAX];
diff --git a/include/net/netfilter/ipv4/nf_conntrack_ipv4.h b/include/net/netfilter/ipv4/nf_conntrack_ipv4.h
index 981c327374da..c2f155fd9299 100644
--- a/include/net/netfilter/ipv4/nf_conntrack_ipv4.h
+++ b/include/net/netfilter/ipv4/nf_conntrack_ipv4.h
@@ -15,6 +15,9 @@ extern struct nf_conntrack_l3proto nf_conntrack_l3proto_ipv4;
 extern struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp4;
 extern struct nf_conntrack_l4proto nf_conntrack_l4proto_udp4;
 extern struct nf_conntrack_l4proto nf_conntrack_l4proto_icmp;
+#ifdef CONFIG_NF_CT_PROTO_DCCP
+extern struct nf_conntrack_l4proto nf_conntrack_l4proto_dccp4;
+#endif
 
 int nf_conntrack_ipv4_compat_init(void);
 void nf_conntrack_ipv4_compat_fini(void);
diff --git a/include/net/netfilter/ipv6/nf_conntrack_ipv6.h b/include/net/netfilter/ipv6/nf_conntrack_ipv6.h
index a4c993685795..5ec66c0d21c4 100644
--- a/include/net/netfilter/ipv6/nf_conntrack_ipv6.h
+++ b/include/net/netfilter/ipv6/nf_conntrack_ipv6.h
@@ -6,6 +6,9 @@ extern struct nf_conntrack_l3proto nf_conntrack_l3proto_ipv6;
 extern struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp6;
 extern struct nf_conntrack_l4proto nf_conntrack_l4proto_udp6;
 extern struct nf_conntrack_l4proto nf_conntrack_l4proto_icmpv6;
+#ifdef CONFIG_NF_CT_PROTO_DCCP
+extern struct nf_conntrack_l4proto nf_conntrack_l4proto_dccp6;
+#endif
 
 #include <linux/sysctl.h>
 extern struct ctl_table nf_ct_ipv6_sysctl_table[];
diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index 3d06d94d2e52..440b781baf0b 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -6,6 +6,9 @@
 #include <linux/atomic.h>
 #include <linux/workqueue.h>
 #include <linux/netfilter/nf_conntrack_tcp.h>
+#ifdef CONFIG_NF_CT_PROTO_DCCP
+#include <linux/netfilter/nf_conntrack_dccp.h>
+#endif
 #include <linux/seqlock.h>
 
 struct ctl_table_header;
@@ -48,12 +51,23 @@ struct nf_icmp_net {
 	unsigned int timeout;
 };
 
+#ifdef CONFIG_NF_CT_PROTO_DCCP
+struct nf_dccp_net {
+	struct nf_proto_net pn;
+	int dccp_loose;
+	unsigned int dccp_timeout[CT_DCCP_MAX + 1];
+};
+#endif
+
 struct nf_ip_net {
 	struct nf_generic_net   generic;
 	struct nf_tcp_net	tcp;
 	struct nf_udp_net	udp;
 	struct nf_icmp_net	icmp;
 	struct nf_icmp_net	icmpv6;
+#ifdef CONFIG_NF_CT_PROTO_DCCP
+	struct nf_dccp_net	dccp;
+#endif
 };
 
 struct ct_pcpu {
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 7130ed5dc1fa..cb3cf770b00c 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -340,6 +340,9 @@ static struct nf_conntrack_l4proto *builtin_l4proto4[] = {
 	&nf_conntrack_l4proto_tcp4,
 	&nf_conntrack_l4proto_udp4,
 	&nf_conntrack_l4proto_icmp,
+#ifdef CONFIG_NF_CT_PROTO_DCCP
+	&nf_conntrack_l4proto_dccp4,
+#endif
 };
 
 static int ipv4_net_init(struct net *net)
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 500be28ff563..f52338d02951 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -340,6 +340,9 @@ static struct nf_conntrack_l4proto *builtin_l4proto6[] = {
 	&nf_conntrack_l4proto_tcp6,
 	&nf_conntrack_l4proto_udp6,
 	&nf_conntrack_l4proto_icmpv6,
+#ifdef CONFIG_NF_CT_PROTO_DCCP
+	&nf_conntrack_l4proto_dccp6,
+#endif
 };
 
 static int ipv6_net_init(struct net *net)
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 496e1dcbd003..27a3d8c8f8ce 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -146,14 +146,14 @@ config NF_CONNTRACK_LABELS
 	  to connection tracking entries.  It selected by the connlabel match.
 
 config NF_CT_PROTO_DCCP
-	tristate 'DCCP protocol connection tracking support'
+	bool 'DCCP protocol connection tracking support'
 	depends on NETFILTER_ADVANCED
-	default IP_DCCP
+	default y
 	help
 	  With this option enabled, the layer 3 independent connection
 	  tracking code will be able to do state tracking on DCCP connections.
 
-	  If unsure, say 'N'.
+	  If unsure, say Y.
 
 config NF_CT_PROTO_GRE
 	tristate
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 3b97d89df2cd..bbd0cc08eff0 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -5,6 +5,7 @@ nf_conntrack-$(CONFIG_NF_CONNTRACK_TIMEOUT) += nf_conntrack_timeout.o
 nf_conntrack-$(CONFIG_NF_CONNTRACK_TIMESTAMP) += nf_conntrack_timestamp.o
 nf_conntrack-$(CONFIG_NF_CONNTRACK_EVENTS) += nf_conntrack_ecache.o
 nf_conntrack-$(CONFIG_NF_CONNTRACK_LABELS) += nf_conntrack_labels.o
+nf_conntrack-$(CONFIG_NF_CT_PROTO_DCCP) += nf_conntrack_proto_dccp.o
 
 obj-$(CONFIG_NETFILTER) = netfilter.o
 
@@ -16,8 +17,6 @@ obj-$(CONFIG_NETFILTER_NETLINK_LOG) += nfnetlink_log.o
 # connection tracking
 obj-$(CONFIG_NF_CONNTRACK) += nf_conntrack.o
 
-# SCTP protocol connection tracking
-obj-$(CONFIG_NF_CT_PROTO_DCCP) += nf_conntrack_proto_dccp.o
 obj-$(CONFIG_NF_CT_PROTO_GRE) += nf_conntrack_proto_gre.o
 obj-$(CONFIG_NF_CT_PROTO_SCTP) += nf_conntrack_proto_sctp.o
 obj-$(CONFIG_NF_CT_PROTO_UDPLITE) += nf_conntrack_proto_udplite.o
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index 073b047314dc..b68ce6ac13b3 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -9,7 +9,6 @@
  *
  */
 #include <linux/kernel.h>
-#include <linux/module.h>
 #include <linux/init.h>
 #include <linux/sysctl.h>
 #include <linux/spinlock.h>
@@ -384,17 +383,9 @@ dccp_state_table[CT_DCCP_ROLE_MAX + 1][DCCP_PKT_SYNCACK + 1][CT_DCCP_MAX + 1] =
 	},
 };
 
-/* this module per-net specifics */
-static unsigned int dccp_net_id __read_mostly;
-struct dccp_net {
-	struct nf_proto_net pn;
-	int dccp_loose;
-	unsigned int dccp_timeout[CT_DCCP_MAX + 1];
-};
-
-static inline struct dccp_net *dccp_pernet(struct net *net)
+static inline struct nf_dccp_net *dccp_pernet(struct net *net)
 {
-	return net_generic(net, dccp_net_id);
+	return &net->ct.nf_ct_proto.dccp;
 }
 
 static bool dccp_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
@@ -424,7 +415,7 @@ static bool dccp_new(struct nf_conn *ct, const struct sk_buff *skb,
 		     unsigned int dataoff, unsigned int *timeouts)
 {
 	struct net *net = nf_ct_net(ct);
-	struct dccp_net *dn;
+	struct nf_dccp_net *dn;
 	struct dccp_hdr _dh, *dh;
 	const char *msg;
 	u_int8_t state;
@@ -719,7 +710,7 @@ static int dccp_nlattr_size(void)
 static int dccp_timeout_nlattr_to_obj(struct nlattr *tb[],
 				      struct net *net, void *data)
 {
-	struct dccp_net *dn = dccp_pernet(net);
+	struct nf_dccp_net *dn = dccp_pernet(net);
 	unsigned int *timeouts = data;
 	int i;
 
@@ -820,7 +811,7 @@ static struct ctl_table dccp_sysctl_table[] = {
 #endif /* CONFIG_SYSCTL */
 
 static int dccp_kmemdup_sysctl_table(struct net *net, struct nf_proto_net *pn,
-				     struct dccp_net *dn)
+				     struct nf_dccp_net *dn)
 {
 #ifdef CONFIG_SYSCTL
 	if (pn->ctl_table)
@@ -850,7 +841,7 @@ static int dccp_kmemdup_sysctl_table(struct net *net, struct nf_proto_net *pn,
 
 static int dccp_init_net(struct net *net, u_int16_t proto)
 {
-	struct dccp_net *dn = dccp_pernet(net);
+	struct nf_dccp_net *dn = dccp_pernet(net);
 	struct nf_proto_net *pn = &dn->pn;
 
 	if (!pn->users) {
@@ -868,7 +859,7 @@ static int dccp_init_net(struct net *net, u_int16_t proto)
 	return dccp_kmemdup_sysctl_table(net, pn, dn);
 }
 
-static struct nf_conntrack_l4proto dccp_proto4 __read_mostly = {
+struct nf_conntrack_l4proto nf_conntrack_l4proto_dccp4 __read_mostly = {
 	.l3proto		= AF_INET,
 	.l4proto		= IPPROTO_DCCP,
 	.name			= "dccp",
@@ -898,11 +889,11 @@ static struct nf_conntrack_l4proto dccp_proto4 __read_mostly = {
 		.nla_policy	= dccp_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
-	.net_id			= &dccp_net_id,
 	.init_net		= dccp_init_net,
 };
+EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_dccp4);
 
-static struct nf_conntrack_l4proto dccp_proto6 __read_mostly = {
+struct nf_conntrack_l4proto nf_conntrack_l4proto_dccp6 __read_mostly = {
 	.l3proto		= AF_INET6,
 	.l4proto		= IPPROTO_DCCP,
 	.name			= "dccp",
@@ -932,56 +923,6 @@ static struct nf_conntrack_l4proto dccp_proto6 __read_mostly = {
 		.nla_policy	= dccp_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
-	.net_id			= &dccp_net_id,
 	.init_net		= dccp_init_net,
 };
-
-static struct nf_conntrack_l4proto *dccp_proto[] = {
-	&dccp_proto4,
-	&dccp_proto6,
-};
-
-static __net_init int dccp_net_init(struct net *net)
-{
-	return nf_ct_l4proto_pernet_register(net, dccp_proto,
-					     ARRAY_SIZE(dccp_proto));
-}
-
-static __net_exit void dccp_net_exit(struct net *net)
-{
-	nf_ct_l4proto_pernet_unregister(net, dccp_proto,
-					ARRAY_SIZE(dccp_proto));
-}
-
-static struct pernet_operations dccp_net_ops = {
-	.init = dccp_net_init,
-	.exit = dccp_net_exit,
-	.id   = &dccp_net_id,
-	.size = sizeof(struct dccp_net),
-};
-
-static int __init nf_conntrack_proto_dccp_init(void)
-{
-	int ret;
-
-	ret = register_pernet_subsys(&dccp_net_ops);
-	if (ret < 0)
-		return ret;
-	ret = nf_ct_l4proto_register(dccp_proto, ARRAY_SIZE(dccp_proto));
-	if (ret < 0)
-		unregister_pernet_subsys(&dccp_net_ops);
-	return ret;
-}
-
-static void __exit nf_conntrack_proto_dccp_fini(void)
-{
-	nf_ct_l4proto_unregister(dccp_proto, ARRAY_SIZE(dccp_proto));
-	unregister_pernet_subsys(&dccp_net_ops);
-}
-
-module_init(nf_conntrack_proto_dccp_init);
-module_exit(nf_conntrack_proto_dccp_fini);
-
-MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
-MODULE_DESCRIPTION("DCCP connection tracking protocol helper");
-MODULE_LICENSE("GPL");
+EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_dccp6);
-- 
2.1.4

