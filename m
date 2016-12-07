From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/50] netfilter: conntrack: built-in support for UDPlite
Date: Wed,  7 Dec 2016 22:52:18 +0100
Message-ID: <1481147576-5690-13-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60154 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933153AbcLGVxb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 16:53:31 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 61A33C2B24
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:29 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 48FE6DA86C
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:29 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id DD63ADA849
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:26 +0100 (CET)
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Davide Caratti <dcaratti@redhat.com>

CONFIG_NF_CT_PROTO_UDPLITE is no more a tristate. When set to y,
connection tracking support for UDPlite protocol is built-in into
nf_conntrack.ko.

footprint test:
$ ls -l net/netfilter/nf_conntrack{_proto_udplite,}.ko \
        net/ipv4/netfilter/nf_conntrack_ipv4.ko \
        net/ipv6/netfilter/nf_conntrack_ipv6.ko

(builtin)|| udplite|  ipv4  |  ipv6  |nf_conntrack
---------++--------+--------+--------+--------------
none     || 432538 | 828755 | 828676 | 6141434
UDPlite  ||   -    | 829649 | 829362 | 6498204

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/ipv4/nf_conntrack_ipv4.h |  3 +
 include/net/netfilter/ipv6/nf_conntrack_ipv6.h |  3 +
 include/net/netns/conntrack.h                  | 16 ++++++
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |  3 +
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |  3 +
 net/netfilter/Kconfig                          |  5 +-
 net/netfilter/Makefile                         |  2 +-
 net/netfilter/nf_conntrack_proto_udplite.c     | 79 +++-----------------------
 8 files changed, 41 insertions(+), 73 deletions(-)

diff --git a/include/net/netfilter/ipv4/nf_conntrack_ipv4.h b/include/net/netfilter/ipv4/nf_conntrack_ipv4.h
index 5f1fc15a51fb..919e4e8af327 100644
--- a/include/net/netfilter/ipv4/nf_conntrack_ipv4.h
+++ b/include/net/netfilter/ipv4/nf_conntrack_ipv4.h
@@ -21,6 +21,9 @@ extern struct nf_conntrack_l4proto nf_conntrack_l4proto_dccp4;
 #ifdef CONFIG_NF_CT_PROTO_SCTP
 extern struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp4;
 #endif
+#ifdef CONFIG_NF_CT_PROTO_UDPLITE
+extern struct nf_conntrack_l4proto nf_conntrack_l4proto_udplite4;
+#endif
 
 int nf_conntrack_ipv4_compat_init(void);
 void nf_conntrack_ipv4_compat_fini(void);
diff --git a/include/net/netfilter/ipv6/nf_conntrack_ipv6.h b/include/net/netfilter/ipv6/nf_conntrack_ipv6.h
index f70d191a8820..eaea968f8657 100644
--- a/include/net/netfilter/ipv6/nf_conntrack_ipv6.h
+++ b/include/net/netfilter/ipv6/nf_conntrack_ipv6.h
@@ -12,6 +12,9 @@ extern struct nf_conntrack_l4proto nf_conntrack_l4proto_dccp6;
 #ifdef CONFIG_NF_CT_PROTO_SCTP
 extern struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp6;
 #endif
+#ifdef CONFIG_NF_CT_PROTO_UDPLITE
+extern struct nf_conntrack_l4proto nf_conntrack_l4proto_udplite6;
+#endif
 
 #include <linux/sysctl.h>
 extern struct ctl_table nf_ct_ipv6_sysctl_table[];
diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index 17724c62de97..cf799fc3fdec 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -69,6 +69,19 @@ struct nf_sctp_net {
 };
 #endif
 
+#ifdef CONFIG_NF_CT_PROTO_UDPLITE
+enum udplite_conntrack {
+	UDPLITE_CT_UNREPLIED,
+	UDPLITE_CT_REPLIED,
+	UDPLITE_CT_MAX
+};
+
+struct nf_udplite_net {
+	struct nf_proto_net pn;
+	unsigned int timeouts[UDPLITE_CT_MAX];
+};
+#endif
+
 struct nf_ip_net {
 	struct nf_generic_net   generic;
 	struct nf_tcp_net	tcp;
@@ -81,6 +94,9 @@ struct nf_ip_net {
 #ifdef CONFIG_NF_CT_PROTO_SCTP
 	struct nf_sctp_net	sctp;
 #endif
+#ifdef CONFIG_NF_CT_PROTO_UDPLITE
+	struct nf_udplite_net	udplite;
+#endif
 };
 
 struct ct_pcpu {
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 0a9d354ef314..22fce4fcece4 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -346,6 +346,9 @@ static struct nf_conntrack_l4proto *builtin_l4proto4[] = {
 #ifdef CONFIG_NF_CT_PROTO_SCTP
 	&nf_conntrack_l4proto_sctp4,
 #endif
+#ifdef CONFIG_NF_CT_PROTO_UDPLITE
+	&nf_conntrack_l4proto_udplite4,
+#endif
 };
 
 static int ipv4_net_init(struct net *net)
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 1d8daafb1685..389f712854f2 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -346,6 +346,9 @@ static struct nf_conntrack_l4proto *builtin_l4proto6[] = {
 #ifdef CONFIG_NF_CT_PROTO_SCTP
 	&nf_conntrack_l4proto_sctp6,
 #endif
+#ifdef CONFIG_NF_CT_PROTO_UDPLITE
+	&nf_conntrack_l4proto_udplite6,
+#endif
 };
 
 static int ipv6_net_init(struct net *net)
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 29c0bf0a315d..def4be06cda6 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -169,14 +169,15 @@ config NF_CT_PROTO_SCTP
 	  If unsure, say Y.
 
 config NF_CT_PROTO_UDPLITE
-	tristate 'UDP-Lite protocol connection tracking support'
+	bool 'UDP-Lite protocol connection tracking support'
 	depends on NETFILTER_ADVANCED
+	default y
 	help
 	  With this option enabled, the layer 3 independent connection
 	  tracking code will be able to do state tracking on UDP-Lite
 	  connections.
 
-	  To compile it as a module, choose M here.  If unsure, say N.
+	  If unsure, say Y.
 
 config NF_CONNTRACK_AMANDA
 	tristate "Amanda backup protocol support"
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 6545c28ab746..e4c8c1d7aaed 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -7,6 +7,7 @@ nf_conntrack-$(CONFIG_NF_CONNTRACK_EVENTS) += nf_conntrack_ecache.o
 nf_conntrack-$(CONFIG_NF_CONNTRACK_LABELS) += nf_conntrack_labels.o
 nf_conntrack-$(CONFIG_NF_CT_PROTO_DCCP) += nf_conntrack_proto_dccp.o
 nf_conntrack-$(CONFIG_NF_CT_PROTO_SCTP) += nf_conntrack_proto_sctp.o
+nf_conntrack-$(CONFIG_NF_CT_PROTO_UDPLITE) += nf_conntrack_proto_udplite.o
 
 obj-$(CONFIG_NETFILTER) = netfilter.o
 
@@ -19,7 +20,6 @@ obj-$(CONFIG_NETFILTER_NETLINK_LOG) += nfnetlink_log.o
 obj-$(CONFIG_NF_CONNTRACK) += nf_conntrack.o
 
 obj-$(CONFIG_NF_CT_PROTO_GRE) += nf_conntrack_proto_gre.o
-obj-$(CONFIG_NF_CT_PROTO_UDPLITE) += nf_conntrack_proto_udplite.o
 
 # netlink interface for nf_conntrack
 obj-$(CONFIG_NF_CT_NETLINK) += nf_conntrack_netlink.o
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index 7808604c70a2..c35f7bf05d8c 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -9,7 +9,6 @@
 
 #include <linux/types.h>
 #include <linux/timer.h>
-#include <linux/module.h>
 #include <linux/udp.h>
 #include <linux/seq_file.h>
 #include <linux/skbuff.h>
@@ -24,26 +23,14 @@
 #include <net/netfilter/nf_conntrack_ecache.h>
 #include <net/netfilter/nf_log.h>
 
-enum udplite_conntrack {
-	UDPLITE_CT_UNREPLIED,
-	UDPLITE_CT_REPLIED,
-	UDPLITE_CT_MAX
-};
-
 static unsigned int udplite_timeouts[UDPLITE_CT_MAX] = {
 	[UDPLITE_CT_UNREPLIED]	= 30*HZ,
 	[UDPLITE_CT_REPLIED]	= 180*HZ,
 };
 
-static unsigned int udplite_net_id __read_mostly;
-struct udplite_net {
-	struct nf_proto_net pn;
-	unsigned int timeouts[UDPLITE_CT_MAX];
-};
-
-static inline struct udplite_net *udplite_pernet(struct net *net)
+static inline struct nf_udplite_net *udplite_pernet(struct net *net)
 {
-	return net_generic(net, udplite_net_id);
+	return &net->ct.nf_ct_proto.udplite;
 }
 
 static bool udplite_pkt_to_tuple(const struct sk_buff *skb,
@@ -178,7 +165,7 @@ static int udplite_timeout_nlattr_to_obj(struct nlattr *tb[],
 					 struct net *net, void *data)
 {
 	unsigned int *timeouts = data;
-	struct udplite_net *un = udplite_pernet(net);
+	struct nf_udplite_net *un = udplite_pernet(net);
 
 	/* set default timeouts for UDPlite. */
 	timeouts[UDPLITE_CT_UNREPLIED] = un->timeouts[UDPLITE_CT_UNREPLIED];
@@ -237,7 +224,7 @@ static struct ctl_table udplite_sysctl_table[] = {
 #endif /* CONFIG_SYSCTL */
 
 static int udplite_kmemdup_sysctl_table(struct nf_proto_net *pn,
-					struct udplite_net *un)
+					struct nf_udplite_net *un)
 {
 #ifdef CONFIG_SYSCTL
 	if (pn->ctl_table)
@@ -257,7 +244,7 @@ static int udplite_kmemdup_sysctl_table(struct nf_proto_net *pn,
 
 static int udplite_init_net(struct net *net, u_int16_t proto)
 {
-	struct udplite_net *un = udplite_pernet(net);
+	struct nf_udplite_net *un = udplite_pernet(net);
 	struct nf_proto_net *pn = &un->pn;
 
 	if (!pn->users) {
@@ -270,7 +257,7 @@ static int udplite_init_net(struct net *net, u_int16_t proto)
 	return udplite_kmemdup_sysctl_table(pn, un);
 }
 
-static struct nf_conntrack_l4proto nf_conntrack_l4proto_udplite4 __read_mostly =
+struct nf_conntrack_l4proto nf_conntrack_l4proto_udplite4 __read_mostly =
 {
 	.l3proto		= PF_INET,
 	.l4proto		= IPPROTO_UDPLITE,
@@ -299,11 +286,11 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_udplite4 __read_mostly =
 		.nla_policy	= udplite_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
-	.net_id			= &udplite_net_id,
 	.init_net		= udplite_init_net,
 };
+EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_udplite4);
 
-static struct nf_conntrack_l4proto nf_conntrack_l4proto_udplite6 __read_mostly =
+struct nf_conntrack_l4proto nf_conntrack_l4proto_udplite6 __read_mostly =
 {
 	.l3proto		= PF_INET6,
 	.l4proto		= IPPROTO_UDPLITE,
@@ -332,54 +319,6 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_udplite6 __read_mostly =
 		.nla_policy	= udplite_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
-	.net_id			= &udplite_net_id,
 	.init_net		= udplite_init_net,
 };
-
-static struct nf_conntrack_l4proto *udplite_proto[] = {
-	&nf_conntrack_l4proto_udplite4,
-	&nf_conntrack_l4proto_udplite6,
-};
-
-static int udplite_net_init(struct net *net)
-{
-	return nf_ct_l4proto_pernet_register(net, udplite_proto,
-					     ARRAY_SIZE(udplite_proto));
-}
-
-static void udplite_net_exit(struct net *net)
-{
-	nf_ct_l4proto_pernet_unregister(net, udplite_proto,
-					ARRAY_SIZE(udplite_proto));
-}
-
-static struct pernet_operations udplite_net_ops = {
-	.init = udplite_net_init,
-	.exit = udplite_net_exit,
-	.id   = &udplite_net_id,
-	.size = sizeof(struct udplite_net),
-};
-
-static int __init nf_conntrack_proto_udplite_init(void)
-{
-	int ret;
-
-	ret = register_pernet_subsys(&udplite_net_ops);
-	if (ret < 0)
-		return ret;
-	ret = nf_ct_l4proto_register(udplite_proto, ARRAY_SIZE(udplite_proto));
-	if (ret < 0)
-		unregister_pernet_subsys(&udplite_net_ops);
-	return ret;
-}
-
-static void __exit nf_conntrack_proto_udplite_exit(void)
-{
-	nf_ct_l4proto_unregister(udplite_proto, ARRAY_SIZE(udplite_proto));
-	unregister_pernet_subsys(&udplite_net_ops);
-}
-
-module_init(nf_conntrack_proto_udplite_init);
-module_exit(nf_conntrack_proto_udplite_exit);
-
-MODULE_LICENSE("GPL");
+EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_udplite6);
-- 
2.1.4
