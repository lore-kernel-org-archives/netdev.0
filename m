From: pablo@netfilter.org
Subject: [PATCH 10/18] netfilter: nf_ct_sctp: merge sctpv[4,6]_net_init into sctp_net_init
Date: Fri,  6 Jul 2012 13:17:00 +0200
Message-ID: <1341573428-3204-11-git-send-email-pablo@netfilter.org>
References: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43520 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933543Ab2GFLTJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 07:19:09 -0400
In-Reply-To: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>

Merge sctpv4_net_init and sctpv6_net_init into sctp_net_init to
remove redundant code now that we have the u_int16_t proto
parameter.

And use nf_proto_net.users to identify if it's the first time
we use the nf_proto_net, in that case, we initialize i

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_proto_sctp.c |   65 +++++++++++--------------------
 1 file changed, 22 insertions(+), 43 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 1e7836c..c746d61 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -707,23 +707,10 @@ static struct ctl_table sctp_compat_sysctl_table[] = {
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
-static int sctp_kmemdup_sysctl_table(struct nf_proto_net *pn)
+static int sctp_kmemdup_sysctl_table(struct nf_proto_net *pn,
+				     struct sctp_net *sn)
 {
 #ifdef CONFIG_SYSCTL
-	struct sctp_net *sn = (struct sctp_net *)pn;
 	if (pn->ctl_table)
 		return 0;
 
@@ -744,11 +731,11 @@ static int sctp_kmemdup_sysctl_table(struct nf_proto_net *pn)
 	return 0;
 }
 
-static int sctp_kmemdup_compat_sysctl_table(struct nf_proto_net *pn)
+static int sctp_kmemdup_compat_sysctl_table(struct nf_proto_net *pn,
+					    struct sctp_net *sn)
 {
 #ifdef CONFIG_SYSCTL
 #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-	struct sctp_net *sn = (struct sctp_net *)pn;
 	pn->ctl_compat_table = kmemdup(sctp_compat_sysctl_table,
 				       sizeof(sctp_compat_sysctl_table),
 				       GFP_KERNEL);
@@ -767,41 +754,33 @@ static int sctp_kmemdup_compat_sysctl_table(struct nf_proto_net *pn)
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
+	if (!pn->users) {
+		int i;
 
-	ret = sctp_kmemdup_compat_sysctl_table(pn);
-	if (ret < 0)
-		return ret;
+		for (i = 0; i < SCTP_CONNTRACK_MAX; i++)
+			sn->timeouts[i] = sctp_timeouts[i];
+	}
 
-	ret = sctp_kmemdup_sysctl_table(pn);
+	if (proto == AF_INET) {
+		ret = sctp_kmemdup_compat_sysctl_table(pn, sn);
+		if (ret < 0)
+			return ret;
 
-#ifdef CONFIG_SYSCTL
-#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
-	if (ret < 0) {
+		ret = sctp_kmemdup_sysctl_table(pn, sn);
+		if (ret < 0)
+			nf_ct_kfree_compat_sysctl_table(pn);
+	} else
+		ret = sctp_kmemdup_sysctl_table(pn, sn);
 
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
@@ -833,7 +812,7 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp4 __read_mostly = {
 	},
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 	.net_id			= &sctp_net_id,
-	.init_net		= sctpv4_init_net,
+	.init_net		= sctp_init_net,
 };
 
 static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp6 __read_mostly = {
@@ -867,7 +846,7 @@ static struct nf_conntrack_l4proto nf_conntrack_l4proto_sctp6 __read_mostly = {
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 #endif
 	.net_id			= &sctp_net_id,
-	.init_net		= sctpv6_init_net,
+	.init_net		= sctp_init_net,
 };
 
 static int sctp_net_init(struct net *net)
-- 
1.7.10
