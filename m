From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 07/13] netfilter: merge udpv[4,6]_net_init into udp_net_init
Date: Thu, 21 Jun 2012 22:36:44 +0800
Message-ID: <1340289410-17642-7-git-send-email-gaofeng@cn.fujitsu.com>
References: <1340289410-17642-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1340289410-17642-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

merge udpv4_net_init and udpv6_net_init into udp_net_init to
reduce the redundancy codes.

and use nf_proto_net.users to identify if it's the first time
we use the nf_proto_net. when it's the first time,we will
initialized it.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/netfilter/nf_conntrack_proto_udp.c |   65 +++++++++++--------------------
 1 files changed, 23 insertions(+), 42 deletions(-)

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
1.7.7.6

