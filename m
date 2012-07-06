From: pablo@netfilter.org
Subject: [PATCH 08/18] netfilter: nf_ct_udp: merge udpv[4,6]_net_init into udp_net_init
Date: Fri,  6 Jul 2012 13:16:58 +0200
Message-ID: <1341573428-3204-9-git-send-email-pablo@netfilter.org>
References: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43545 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933543Ab2GFLTM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 07:19:12 -0400
In-Reply-To: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>

Merge udpv4_net_init and udpv6_net_init into udp_net_init to
remove redundant code now that we have the u_int16_t proto
parameter.

And use nf_proto_net.users to identify if it's the first time
we use the nf_proto_net, in that case, we initialize it.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_proto_udp.c |   65 +++++++++++---------------------
 1 file changed, 23 insertions(+), 42 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index 2b978e6..e7e0434 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -235,10 +235,10 @@ static struct ctl_table udp_compat_sysctl_table[] = {
 #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 #endif /* CONFIG_SYSCTL */
 
-static int udp_kmemdup_sysctl_table(struct nf_proto_net *pn)
+static int udp_kmemdup_sysctl_table(struct nf_proto_net *pn,
+				    struct nf_udp_net *un)
 {
 #ifdef CONFIG_SYSCTL
-	struct nf_udp_net *un = (struct nf_udp_net *)pn;
 	if (pn->ctl_table)
 		return 0;
 	pn->ctl_table = kmemdup(udp_sysctl_table,
@@ -252,11 +252,11 @@ static int udp_kmemdup_sysctl_table(struct nf_proto_net *pn)
 	return 0;
 }
 
-static int udp_kmemdup_compat_sysctl_table(struct nf_proto_net *pn)
+static int udp_kmemdup_compat_sysctl_table(struct nf_proto_net *pn,
+					   struct nf_udp_net *un)
 {
 #ifdef CONFIG_SYSCTL
 #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-	struct nf_udp_net *un = (struct nf_udp_net *)pn;
 	pn->ctl_compat_table = kmemdup(udp_compat_sysctl_table,
 				       sizeof(udp_compat_sysctl_table),
 				       GFP_KERNEL);
@@ -270,50 +270,31 @@ static int udp_kmemdup_compat_sysctl_table(struct nf_proto_net *pn)
 	return 0;
 }
 
-static void udp_init_net_data(struct nf_udp_net *un)
-{
-	int i;
-#ifdef CONFIG_SYSCTL
-	if (!un->pn.ctl_table) {
-#else
-	if (!un->pn.users++) {
-#endif
-		for (i = 0; i < UDP_CT_MAX; i++)
-			un->timeouts[i] = udp_timeouts[i];
-	}
-}
-
-static int udpv4_init_net(struct net *net, u_int16_t proto)
+static int udp_init_net(struct net *net, u_int16_t proto)
 {
 	int ret;
 	struct nf_udp_net *un = udp_pernet(net);
-	struct nf_proto_net *pn = (struct nf_proto_net *)un;
-
-	udp_init_net_data(un);
+	struct nf_proto_net *pn = &un->pn;
 
-	ret = udp_kmemdup_compat_sysctl_table(pn);
-	if (ret < 0)
-		return ret;
+	if (!pn->users) {
+		int i;
 
-	ret = udp_kmemdup_sysctl_table(pn);
-#ifdef CONFIG_SYSCTL
-#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-	if (ret < 0) {
-		kfree(pn->ctl_compat_table);
-		pn->ctl_compat_table = NULL;
+		for (i = 0; i < UDP_CT_MAX; i++)
+			un->timeouts[i] = udp_timeouts[i];
 	}
-#endif
-#endif
-	return ret;
-}
 
-static int udpv6_init_net(struct net *net, u_int16_t proto)
-{
-	struct nf_udp_net *un = udp_pernet(net);
-	struct nf_proto_net *pn = (struct nf_proto_net *)un;
+	if (proto == AF_INET) {
+		ret = udp_kmemdup_compat_sysctl_table(pn, un);
+		if (ret < 0)
+			return ret;
 
-	udp_init_net_data(un);
-	return udp_kmemdup_sysctl_table(pn);
+		ret = udp_kmemdup_sysctl_table(pn, un);
+		if (ret < 0)
+			nf_ct_kfree_compat_sysctl_table(pn);
+	} else
+		ret = udp_kmemdup_sysctl_table(pn, un);
+
+	return ret;
 }
 
 struct nf_conntrack_l4proto nf_conntrack_l4proto_udp4 __read_mostly =
@@ -343,7 +324,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udp4 __read_mostly =
 		.nla_policy	= udp_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
-	.init_net		= udpv4_init_net,
+	.init_net		= udp_init_net,
 };
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_udp4);
 
@@ -374,6 +355,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udp6 __read_mostly =
 		.nla_policy	= udp_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
-	.init_net		= udpv6_init_net,
+	.init_net		= udp_init_net,
 };
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_udp6);
-- 
1.7.10
