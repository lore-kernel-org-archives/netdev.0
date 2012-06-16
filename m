From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH net-next v2 06/12] netfilter: merge udpv[4,6]_net_init into udp_net_init
Date: Sat, 16 Jun 2012 11:41:17 +0800
Message-ID: <1339818083-31356-6-git-send-email-gaofeng@cn.fujitsu.com>
References: <1339818083-31356-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:25622 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1759067Ab2FPDlD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jun 2012 23:41:03 -0400
In-Reply-To: <1339818083-31356-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

merge udpv4_net_init and udpv6_net_init into udp_net_init to
reduce the redundancy codes.

and use nf_proto_net.users to identify if it's the first time
we use the nf_proto_net. when it's the first time,we will
initialized it.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/netfilter/nf_conntrack_proto_udp.c |   56 ++++++++++---------------------
 1 files changed, 18 insertions(+), 38 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index 2b978e6..61bca4f 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -270,52 +270,32 @@ static int udp_kmemdup_compat_sysctl_table(struct nf_proto_net *pn)
 	return 0;
 }
 
-static void udp_init_net_data(struct nf_udp_net *un)
+static int udp_init_net(struct net *net, u_int16_t proto)
 {
-	int i;
-#ifdef CONFIG_SYSCTL
-	if (!un->pn.ctl_table) {
-#else
-	if (!un->pn.users++) {
-#endif
+	int ret;
+	struct nf_udp_net *un = udp_pernet(net);
+	struct nf_proto_net *pn = &un->pn;
+
+	if (!pn->users) {
+		int i;
 		for (i = 0; i < UDP_CT_MAX; i++)
 			un->timeouts[i] = udp_timeouts[i];
 	}
-}
-
-static int udpv4_init_net(struct net *net, u_int16_t proto)
-{
-	int ret;
-	struct nf_udp_net *un = udp_pernet(net);
-	struct nf_proto_net *pn = (struct nf_proto_net *)un;
 
-	udp_init_net_data(un);
+	if (proto == AF_INET) {
+		ret = udp_kmemdup_compat_sysctl_table(pn);
+		if (ret < 0)
+			return ret;
 
-	ret = udp_kmemdup_compat_sysctl_table(pn);
-	if (ret < 0)
-		return ret;
+		ret = udp_kmemdup_sysctl_table(pn);
+		if (ret < 0)
+			nf_ct_kfree_compat_sysctl_table(pn);
+	} else
+		ret = udp_kmemdup_sysctl_table(pn);
 
-	ret = udp_kmemdup_sysctl_table(pn);
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
 
-static int udpv6_init_net(struct net *net, u_int16_t proto)
-{
-	struct nf_udp_net *un = udp_pernet(net);
-	struct nf_proto_net *pn = (struct nf_proto_net *)un;
-
-	udp_init_net_data(un);
-	return udp_kmemdup_sysctl_table(pn);
-}
-
 struct nf_conntrack_l4proto nf_conntrack_l4proto_udp4 __read_mostly =
 {
 	.l3proto		= PF_INET,
@@ -343,7 +323,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udp4 __read_mostly =
 		.nla_policy	= udp_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
-	.init_net		= udpv4_init_net,
+	.init_net		= udp_init_net,
 };
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_udp4);
 
@@ -374,6 +354,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udp6 __read_mostly =
 		.nla_policy	= udp_timeout_nla_policy,
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
-	.init_net		= udpv6_init_net,
+	.init_net		= udp_init_net,
 };
 EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_udp6);
-- 
1.7.7.6
