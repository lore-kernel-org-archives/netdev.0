From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 05/10] netfilter: merge tcpv[4,6]_net_init into tcp_net_init
Date: Thu, 14 Jun 2012 18:07:20 +0800
Message-ID: <1339668445-23848-5-git-send-email-gaofeng@cn.fujitsu.com>
References: <1339668445-23848-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:40238 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755429Ab2FNKjL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2012 06:39:11 -0400
In-Reply-To: <1339668445-23848-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

merge tcpv4_net_init and tcpv6_net_init into tcp_net_init to
reduce the redundancy codes.

and use nf_proto_net.users to identify if it's the first time
we use the nf_proto_net. when it's the first time,we will
initialized it.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/netfilter/nf_conntrack_proto_tcp.c |   57 ++++++++------------------------
 1 files changed, 14 insertions(+), 43 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 6db9d3c..e3d5427 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -1593,18 +1593,14 @@ static int tcp_kmemdup_compat_sysctl_table(struct nf_proto_net *pn)
 	return 0;
 }
 
-static int tcpv4_init_net(struct net *net, u_int16_t proto)
+static int tcp_init_net(struct net *net, u_int16_t proto)
 {
-	int i;
 	int ret = 0;
 	struct nf_tcp_net *tn = tcp_pernet(net);
 	struct nf_proto_net *pn = (struct nf_proto_net *)tn;
 
-#ifdef CONFIG_SYSCTL
-	if (!pn->ctl_table) {
-#else
-	if (!pn->users++) {
-#endif
+	if (!pn->users) {
+		int i = 0;
 		for (i = 0; i < TCP_CONNTRACK_TIMEOUT_MAX; i++)
 			tn->timeouts[i] = tcp_timeouts[i];
 
@@ -1613,45 +1609,20 @@ static int tcpv4_init_net(struct net *net, u_int16_t proto)
 		tn->tcp_max_retrans = nf_ct_tcp_max_retrans;
 	}
 
-	ret = tcp_kmemdup_compat_sysctl_table(pn);
+	if (proto == AF_INET) {
+		ret = tcp_kmemdup_compat_sysctl_table(pn);
+		if (ret < 0)
+			return ret;
 
-	if (ret < 0)
-		return ret;
+		ret = tcp_kmemdup_sysctl_table(pn);
+		if (ret < 0)
+			nf_ct_kfree_compat_sysctl_table(pn);
+	} else
+		ret = tcp_kmemdup_sysctl_table(pn);
 
-	ret = tcp_kmemdup_sysctl_table(pn);
-
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
