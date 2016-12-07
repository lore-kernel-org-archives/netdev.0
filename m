From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/50] netfilter: conntrack: built-in support for SCTP
Date: Wed,  7 Dec 2016 22:52:17 +0100
Message-ID: <1481147576-5690-12-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Davide Caratti <dcaratti@redhat.com>

CONFIG_NF_CT_PROTO_SCTP is no more a tristate. When set to y, connection
tracking support for SCTP protocol is built-in into nf_conntrack.ko.

footprint test:
$ ls -l net/netfilter/nf_conntrack{_proto_sctp,}.ko \
        net/ipv4/netfilter/nf_conntrack_ipv4.ko \
        net/ipv6/netfilter/nf_conntrack_ipv6.ko

(builtin)||  sctp  |  ipv4  |  ipv6  | nf_conntrack
---------++--------+--------+--------+--------------
none     || 498243 | 828755 | 828676 | 6141434
SCTP     ||   -    | 829254 | 829175 | 6547872

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/ipv4/nf_conntrack_ipv4.h |  3 +
 include/net/netfilter/ipv6/nf_conntrack_ipv6.h |  3 +
 include/net/netns/conntrack.h                  | 13 +++++
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |  3 +
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |  3 +
 net/netfilter/Kconfig                          |  7 +--
 net/netfilter/Makefile                         |  2 +-
 net/netfilter/nf_conntrack_proto_sctp.c        | 76 +++-----------------------
 8 files changed, 38 insertions(+), 72 deletions(-)

diff --git a/include/net/netfilter/ipv4/nf_conntrack_ipv4.h b/include/net/netfilter/ipv4/nf_conntrack_ipv4.h
index c2f155fd9299..5f1fc15a51fb 100644
--- a/include/net/netfilter/ipv4/nf_conntrack_ipv4.h
+++ b/include/net/netfilter/ipv4/nf_conntrack_ipv4.h
@@ -18,6 +18,9 @@ extern struct nf_conntrack_l4proto nf_conntrack_l4proto_icmp;
 #ifdef CONFIG_NF_CT_PROTO_DCCP
 extern struct nf_conntrack_l4proto nf_conntrack_l4proto_dccp4;
 #endif
+#ifdef CONFIG_NF_CT_PROTO_SCTP
+extern struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp4;
+#endif
 
 int nf_conntrack_ipv4_compat_init(void);
 void nf_conntrack_ipv4_compat_fini(void);
diff --git a/include/net/netfilter/ipv6/nf_conntrack_ipv6.h b/include/net/netfilter/ipv6/nf_conntrack_ipv6.h
index 5ec66c0d21c4..f70d191a8820 100644
--- a/include/net/netfilter/ipv6/nf_conntrack_ipv6.h
+++ b/include/net/netfilter/ipv6/nf_conntrack_ipv6.h
@@ -9,6 +9,9 @@ extern struct nf_conntrack_l4proto nf_conntrack_l4proto_icmpv6;
 #ifdef CONFIG_NF_CT_PROTO_DCCP
 extern struct nf_conntrack_l4proto nf_conntrack_l4proto_dccp6;
 #endif
+#ifdef CONFIG_NF_CT_PROTO_SCTP
+extern struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp6;
+#endif
 
 #include <linux/sysctl.h>
 extern struct ctl_table nf_ct_ipv6_sysctl_table[];
diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index 440b781baf0b..17724c62de97 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -9,6 +9,9 @@
 #ifdef CONFIG_NF_CT_PROTO_DCCP
 #include <linux/netfilter/nf_conntrack_dccp.h>
 #endif
+#ifdef CONFIG_NF_CT_PROTO_SCTP
+#include <linux/netfilter/nf_conntrack_sctp.h>
+#endif
 #include <linux/seqlock.h>
 
 struct ctl_table_header;
@@ -59,6 +62,13 @@ struct nf_dccp_net {
 };
 #endif
 
+#ifdef CONFIG_NF_CT_PROTO_SCTP
+struct nf_sctp_net {
+	struct nf_proto_net pn;
+	unsigned int timeouts[SCTP_CONNTRACK_MAX];
+};
+#endif
+
 struct nf_ip_net {
 	struct nf_generic_net   generic;
 	struct nf_tcp_net	tcp;
@@ -68,6 +78,9 @@ struct nf_ip_net {
 #ifdef CONFIG_NF_CT_PROTO_DCCP
 	struct nf_dccp_net	dccp;
 #endif
+#ifdef CONFIG_NF_CT_PROTO_SCTP
+	struct nf_sctp_net	sctp;
+#endif
 };
 
 struct ct_pcpu {
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index cb3cf770b00c..0a9d354ef314 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -343,6 +343,9 @@ static struct nf_conntrack_l4proto *builtin_l4proto4[] = {
 #ifdef CONFIG_NF_CT_PROTO_DCCP
 	&nf_conntrack_l4proto_dccp4,
 #endif
+#ifdef CONFIG_NF_CT_PROTO_SCTP
+	&nf_conntrack_l4proto_sctp4,
+#endif
 };
 
 static int ipv4_net_init(struct net *net)
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index f52338d02951..1d8daafb1685 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -343,6 +343,9 @@ static struct nf_conntrack_l4proto *builtin_l4proto6[] = {
 #ifdef CONFIG_NF_CT_PROTO_DCCP
 	&nf_conntrack_l4proto_dccp6,
 #endif
+#ifdef CONFIG_NF_CT_PROTO_SCTP
+	&nf_conntrack_l4proto_sctp6,
+#endif
 };
 
 static int ipv6_net_init(struct net *net)
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 27a3d8c8f8ce..29c0bf0a315d 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -159,15 +159,14 @@ config NF_CT_PROTO_GRE
 	tristate
 
 config NF_CT_PROTO_SCTP
-	tristate 'SCTP protocol connection tracking support'
+	bool 'SCTP protocol connection tracking support'
 	depends on NETFILTER_ADVANCED
-	default IP_SCTP
+	default y
 	help
 	  With this option enabled, the layer 3 independent connection
 	  tracking code will be able to do state tracking on SCTP connections.
 
-	  If you want to compile it as a module, say M here and read
-	  <file:Documentation/kbuild/modules.txt>.  If unsure, say `N'.
+	  If unsure, say Y.
 
 config NF_CT_PROTO_UDPLITE
 	tristate 'UDP-Lite protocol connection tracking support'
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index bbd0cc08eff0..6545c28ab746 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -6,6 +6,7 @@ nf_conntrack-$(CONFIG_NF_CONNTRACK_TIMESTAMP) += nf_conntrack_timestamp.o
 nf_conntrack-$(CONFIG_NF_CONNTRACK_EVENTS) += nf_conntrack_ecache.o
 nf_conntrack-$(CONFIG_NF_CONNTRACK_LABELS) += nf_conntrack_labels.o
 nf_conntrack-$(CONFIG_NF_CT_PROTO_DCCP) += nf_conntrack_proto_dccp.o
+nf_conntrack-$(CONFIG_NF_CT_PROTO_SCTP) += nf_conntrack_proto_sctp.o
 
 obj-$(CONFIG_NETFILTER) = netfilter.o
 
@@ -18,7 +19,6 @@ obj-$(CONFIG_NETFILTER_NETLINK_LOG) += nfnetlink_log.o
 obj-$(CONFIG_NF_CONNTRACK) += nf_conntrack.o
 
 obj-$(CONFIG_NF_CT_PROTO_GRE) += nf_conntrack_proto_gre.o
-obj-$(CONFIG_NF_CT_PROTO_SCTP) += nf_conntrack_proto_sctp.o
 obj-$(CONFIG_NF_CT_PROTO_UDPLITE) += nf_conntrack_proto_udplite.o
 
 # netlink interface for nf_conntrack
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index d096c2d6b87b..a0efde38da44 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -15,7 +15,6 @@
 #include <linux/types.h>
 #include <linux/timer.h>
 #include <linux/netfilter.h>
-#include <linux/module.h>
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/sctp.h>
@@ -144,15 +143,9 @@ static const u8 sctp_conntracks[2][11][SCTP_CONNTRACK_MAX] = {
 	}
 };
 
-static unsigned int sctp_net_id	__read_mostly;
-struct sctp_net {
-	struct nf_proto_net pn;
-	unsigned int timeouts[SCTP_CONNTRACK_MAX];
-};
-
-static inline struct sctp_net *sctp_pernet(struct net *net)
+static inline struct nf_sctp_net *sctp_pernet(struct net *net)
 {
-	return net_generic(net, sctp_net_id);
+	return &net->ct.nf_ct_proto.sctp;
 }
 
 static bool sctp_pkt_to_tuple(const struct sk_buff *skb, unsigned int dataoff,
@@ -600,7 +593,7 @@ static int sctp_timeout_nlattr_to_obj(struct nlattr *tb[],
 				      struct net *net, void *data)
 {
 	unsigned int *timeouts = data;
-	struct sctp_net *sn = sctp_pernet(net);
+	struct nf_sctp_net *sn = sctp_pernet(net);
 	int i;
 
 	/* set default SCTP timeouts. */
@@ -708,7 +701,7 @@ static struct ctl_table sctp_sysctl_table[] = {
 #endif
 
 static int sctp_kmemdup_sysctl_table(struct nf_proto_net *pn,
-				     struct sctp_net *sn)
+				     struct nf_sctp_net *sn)
 {
 #ifdef CONFIG_SYSCTL
 	if (pn->ctl_table)
@@ -735,7 +728,7 @@ static int sctp_kmemdup_sysctl_table(struct nf_proto_net *pn,
 
 static int sctp_init_net(struct net *net, u_int16_t proto)
 {
-	struct sctp_net *sn = sctp_pernet(net);
+	struct nf_sctp_net *sn = sctp_pernet(net);
 	struct nf_proto_net *pn = &sn->pn;
 
 	if (!pn->users) {
@@ -748,7 +741,7 @@ static int sctp_init_net(struct net *net, u_int16_t proto)
 	return sctp_kmemdup_sysctl_table(pn, sn);
 }
 
-static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp4 __read_mostly = {
+struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp4 __read_mostly = {
 	.l3proto		= PF_INET,
 	.l4proto 		= IPPROTO_SCTP,
 	.name 			= "sctp",
@@ -778,11 +771,11 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp4 __read_mostly = {
 		.nla_policy	= sctp_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
-	.net_id			= &sctp_net_id,
 	.init_net		= sctp_init_net,
 };
+EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_sctp4);
 
-static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp6 __read_mostly = {
+struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp6 __read_mostly = {
 	.l3proto		= PF_INET6,
 	.l4proto 		= IPPROTO_SCTP,
 	.name 			= "sctp",
@@ -812,57 +805,6 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp6 __read_mostly = {
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 #endif
-	.net_id			= &sctp_net_id,
 	.init_net		= sctp_init_net,
 };
-
-static struct nf_conntrack_l4proto *sctp_proto[] = {
-	&nf_conntrack_l4proto_sctp4,
-	&nf_conntrack_l4proto_sctp6,
-};
-
-static int sctp_net_init(struct net *net)
-{
-	return nf_ct_l4proto_pernet_register(net, sctp_proto,
-					     ARRAY_SIZE(sctp_proto));
-}
-
-static void sctp_net_exit(struct net *net)
-{
-	nf_ct_l4proto_pernet_unregister(net, sctp_proto,
-					ARRAY_SIZE(sctp_proto));
-}
-
-static struct pernet_operations sctp_net_ops = {
-	.init = sctp_net_init,
-	.exit = sctp_net_exit,
-	.id   = &sctp_net_id,
-	.size = sizeof(struct sctp_net),
-};
-
-static int __init nf_conntrack_proto_sctp_init(void)
-{
-	int ret;
-
-	ret = register_pernet_subsys(&sctp_net_ops);
-	if (ret < 0)
-		return ret;
-	ret = nf_ct_l4proto_register(sctp_proto, ARRAY_SIZE(sctp_proto));
-	if (ret < 0)
-		unregister_pernet_subsys(&sctp_net_ops);
-	return ret;
-}
-
-static void __exit nf_conntrack_proto_sctp_fini(void)
-{
-	nf_ct_l4proto_unregister(sctp_proto, ARRAY_SIZE(sctp_proto));
-	unregister_pernet_subsys(&sctp_net_ops);
-}
-
-module_init(nf_conntrack_proto_sctp_init);
-module_exit(nf_conntrack_proto_sctp_fini);
-
-MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Kiran Kumar Immidi");
-MODULE_DESCRIPTION("Netfilter connection tracking protocol helper for SCTP");
-MODULE_ALIAS("ip_conntrack_proto_sctp");
+EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_sctp6);
-- 
2.1.4

