From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 06/13] netfilter: merge tcpv[4,6]_net_init into tcp_net_init
Date: Thu, 21 Jun 2012 22:36:43 +0800
Message-ID: <1340289410-17642-6-git-send-email-gaofeng@cn.fujitsu.com>
References: <1340289410-17642-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1340289410-17642-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

merge tcpv4_net_init and tcpv6_net_init into tcp_net_init to
reduce the redundancy codes.

and use nf_proto_net.users to identify if it's the first time
we use the nf_proto_net. when it's the first time,we will
initialized it.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/netfilter/nf_conntrack_proto_tcp.c |   71 +++++++++----------------------
 1 files changed, 21 insertions(+), 50 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 6db9d3c..44f0da8 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -1533,11 +1533,10 @@ static struct ctl_table tcp_compat_sysctl_table[] = {
 #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 #endif /* CONFIG_SYSCTL */
 
-static int tcp_kmemdup_sysctl_table(struct nf_proto_net *pn)
+static int tcp_kmemdup_sysctl_table(struct nf_proto_net *pn,
+				    struct nf_tcp_net *tn)
 {
 #ifdef CONFIG_SYSCTL
-	struct nf_tcp_net *tn = (struct nf_tcp_net *)pn;
-
 	if (pn->ctl_table)
 		return 0;
 
@@ -1564,11 +1563,11 @@ static int tcp_kmemdup_sysctl_table(struct nf_proto_net *pn)
 	return 0;
 }
 
-static int tcp_kmemdup_compat_sysctl_table(struct nf_proto_net *pn)
+static int tcp_kmemdup_compat_sysctl_table(struct nf_proto_net *pn,
+					   struct nf_tcp_net *tn)
 {
 #ifdef CONFIG_SYSCTL
 #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-	struct nf_tcp_net *tn = (struct nf_tcp_net *)pn;
 	pn->ctl_compat_table = kmemdup(tcp_compat_sysctl_table,
 				       sizeof(tcp_compat_sysctl_table),
 				       GFP_KERNEL);
@@ -1593,18 +1592,15 @@ static int tcp_kmemdup_compat_sysctl_table(struct nf_proto_net *pn)
 	return 0;
 }
 
-static int tcpv4_init_net(struct net *net, u_int16_t proto)
+static int tcp_init_net(struct net *net, u_int16_t proto)
 {
-	int i;
-	int ret = 0;
+	int ret;
 	struct nf_tcp_net *tn = tcp_pernet(net);
-	struct nf_proto_net *pn = (struct nf_proto_net *)tn;
+	struct nf_proto_net *pn = &tn->pn;
+
+	if (!pn->users) {
+		int i;
 
-#ifdef CONFIG_SYSCTL
-	if (!pn->ctl_table) {
-#else
-	if (!pn->users++) {
-#endif
 		for (i = 0; i < TCP_CONNTRACK_TIMEOUT_MAX; i++)
 			tn->timeouts[i] = tcp_timeouts[i];
 
@@ -1613,45 +1609,20 @@ static int tcpv4_init_net(struct net *net, u_int16_t proto)
 		tn->tcp_max_retrans = nf_ct_tcp_max_retrans;
 	}
 
-	ret = tcp_kmemdup_compat_sysctl_table(pn);
-
-	if (ret < 0)
-		return ret;
+	if (proto == AF_INET) {
+		ret = tcp_kmemdup_compat_sysctl_table(pn, tn);
+		if (ret < 0)
+			return ret;
 
-	ret = tcp_kmemdup_sysctl_table(pn);
+		ret = tcp_kmemdup_sysctl_table(pn, tn);
+		if (ret < 0)
+			nf_ct_kfree_compat_sysctl_table(pn);
+	} else
+		ret = tcp_kmemdup_sysctl_table(pn, tn);
 
-#ifdef CONFIG_SYSCTL
-#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-	if (ret < 0) {
-		kfree(pn->ctl_compat_table);
-		pn->ctl_compat_table = NULL;
-	}
-#endif
-#endif
 	return ret;
 }
 
-static int tcpv6_init_net(struct net *net, u_int16_t proto)
-{
-	int i;
-	struct nf_tcp_net *tn = tcp_pernet(net);
-	struct nf_proto_net *pn = (struct nf_proto_net *)tn;
-
-#ifdef CONFIG_SYSCTL
-	if (!pn->ctl_table) {
-#else
-	if (!pn->users++) {
-#endif
-		for (i = 0; i < TCP_CONNTRACK_TIMEOUT_MAX; i++)
-			tn->timeouts[i] = tcp_timeouts[i];
-		tn->tcp_loose = nf_ct_tcp_loose;
-		tn->tcp_be_liberal = nf_ct_tcp_be_liberal;
-		tn->tcp_max_retrans = nf_ct_tcp_max_retrans;
-	}
-
-	return tcp_kmemdup_sysctl_table(pn);
-}
-
 struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp4 __read_mostly =
 {
 	.l3proto		= PF_INET,
@@ -1684,7 +1655,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp4 __read_mostly =
 		.nla_policy	= tcp_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
-	.init_net		= tcpv4_init_net,
+	.init_net		= tcp_init_net,
 };
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_tcp4);
 
@@ -1720,6 +1691,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_tcp6 __read_mostly =
 		.nla_policy	= tcp_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
-	.init_net		= tcpv6_init_net,
+	.init_net		= tcp_init_net,
 };
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_tcp6);
-- 
1.7.7.6

