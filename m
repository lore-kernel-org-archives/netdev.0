From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH net-next v2 08/12] netfilter: merge sctpv[4,6]_net_init into sctp_net_init
Date: Sat, 16 Jun 2012 11:41:19 +0800
Message-ID: <1339818083-31356-8-git-send-email-gaofeng@cn.fujitsu.com>
References: <1339818083-31356-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:48314 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1758948Ab2FPDlG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jun 2012 23:41:06 -0400
In-Reply-To: <1339818083-31356-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

merge sctpv4_net_init and sctpv6_net_init into sctp_net_init to
reduce the redundancy codes.

and use nf_proto_net.users to identify if it's the first time
we use the nf_proto_net. when it's the first time,we will
initialized it.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/netfilter/nf_conntrack_proto_sctp.c |   58 +++++++++---------------------
 1 files changed, 18 insertions(+), 40 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 1e7836c..dfad67e 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -707,19 +707,6 @@ static struct ctl_table sctp_compat_sysctl_table[] = {
 #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 #endif
 
-static void sctp_init_net_data(struct sctp_net *sn)
-{
-	int i;
-#ifdef CONFIG_SYSCTL
-	if (!sn->pn.ctl_table) {
-#else
-	if (!sn->pn.users++) {
-#endif
-		for (i = 0; i < SCTP_CONNTRACK_MAX; i++)
-			sn->timeouts[i] = sctp_timeouts[i];
-	}
-}
-
 static int sctp_kmemdup_sysctl_table(struct nf_proto_net *pn)
 {
 #ifdef CONFIG_SYSCTL
@@ -767,41 +754,32 @@ static int sctp_kmemdup_compat_sysctl_table(struct nf_proto_net *pn)
 	return 0;
 }
 
-static int sctpv4_init_net(struct net *net, u_int16_t proto)
+static int sctp_init_net(struct net *net, u_int16_t proto)
 {
 	int ret;
 	struct sctp_net *sn = sctp_pernet(net);
-	struct nf_proto_net *pn = (struct nf_proto_net *)sn;
+	struct nf_proto_net *pn = &sn->pn;
 
-	sctp_init_net_data(sn);
-
-	ret = sctp_kmemdup_compat_sysctl_table(pn);
-	if (ret < 0)
-		return ret;
+	if (!pn->users) {
+		int i;
+		for (i = 0; i < SCTP_CONNTRACK_MAX; i++)
+			sn->timeouts[i] = sctp_timeouts[i];
+	}
 
-	ret = sctp_kmemdup_sysctl_table(pn);
+	if (proto == AF_INET) {
+		ret = sctp_kmemdup_compat_sysctl_table(pn);
+		if (ret < 0)
+			return ret;
 
-#ifdef CONFIG_SYSCTL
-#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-	if (ret < 0) {
+		ret = sctp_kmemdup_sysctl_table(pn);
+		if (ret < 0)
+			nf_ct_kfree_compat_sysctl_table(pn);
+	} else
+		ret = sctp_kmemdup_sysctl_table(pn);
 
-		kfree(pn->ctl_compat_table);
-		pn->ctl_compat_table = NULL;
-	}
-#endif
-#endif
 	return ret;
 }
 
-static int sctpv6_init_net(struct net *net, u_int16_t proto)
-{
-	struct sctp_net *sn = sctp_pernet(net);
-	struct nf_proto_net *pn = (struct nf_proto_net *)sn;
-
-	sctp_init_net_data(sn);
-	return sctp_kmemdup_sysctl_table(pn);
-}
-
 static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp4 __read_mostly = {
 	.l3proto		= PF_INET,
 	.l4proto 		= IPPROTO_SCTP,
@@ -833,7 +811,7 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp4 __read_mostly = {
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 	.net_id			= &sctp_net_id,
-	.init_net		= sctpv4_init_net,
+	.init_net		= sctp_init_net,
 };
 
 static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp6 __read_mostly = {
@@ -867,7 +845,7 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp6 __read_mostly = {
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 #endif
 	.net_id			= &sctp_net_id,
-	.init_net		= sctpv6_init_net,
+	.init_net		= sctp_init_net,
 };
 
 static int sctp_net_init(struct net *net)
-- 
1.7.7.6
