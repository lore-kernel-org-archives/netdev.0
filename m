From: pablo@netfilter.org
Subject: [PATCH 12/18] netfilter: nf_ct_dccp: add dccp_kmemdup_sysctl_table function
Date: Fri,  6 Jul 2012 13:17:02 +0200
Message-ID: <1341573428-3204-13-git-send-email-pablo@netfilter.org>
References: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43529 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933551Ab2GFLTK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 07:19:10 -0400
In-Reply-To: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>

This patch is a cleanup. It adds dccp_kmemdup_sysctl_table to
split code into smaller chunks. Yet it prepares introduction
of nf_conntrack_proto_*_sysctl.c.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_proto_dccp.c |   54 +++++++++++++++++--------------
 1 file changed, 30 insertions(+), 24 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index 52da8f0..6535326 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -387,7 +387,7 @@ dccp_state_table[CT_DCCP_ROLE_MAX + 1][DCCP_PKT_SYNCACK + 1][CT_DCCP_MAX + 1] =
 /* this module per-net specifics */
 static int dccp_net_id __read_mostly;
 struct dccp_net {
-	struct nf_proto_net np;
+	struct nf_proto_net pn;
 	int dccp_loose;
 	unsigned int dccp_timeout[CT_DCCP_MAX + 1];
 };
@@ -815,16 +815,37 @@ static struct ctl_table dccp_sysctl_table[] = {
 };
 #endif /* CONFIG_SYSCTL */
 
+static int dccp_kmemdup_sysctl_table(struct nf_proto_net *pn,
+				     struct dccp_net *dn)
+{
+#ifdef CONFIG_SYSCTL
+	if (pn->ctl_table)
+		return 0;
+
+	pn->ctl_table = kmemdup(dccp_sysctl_table,
+				sizeof(dccp_sysctl_table),
+				GFP_KERNEL);
+	if (!pn->ctl_table)
+		return -ENOMEM;
+
+	pn->ctl_table[0].data = &dn->dccp_timeout[CT_DCCP_REQUEST];
+	pn->ctl_table[1].data = &dn->dccp_timeout[CT_DCCP_RESPOND];
+	pn->ctl_table[2].data = &dn->dccp_timeout[CT_DCCP_PARTOPEN];
+	pn->ctl_table[3].data = &dn->dccp_timeout[CT_DCCP_OPEN];
+	pn->ctl_table[4].data = &dn->dccp_timeout[CT_DCCP_CLOSEREQ];
+	pn->ctl_table[5].data = &dn->dccp_timeout[CT_DCCP_CLOSING];
+	pn->ctl_table[6].data = &dn->dccp_timeout[CT_DCCP_TIMEWAIT];
+	pn->ctl_table[7].data = &dn->dccp_loose;
+#endif
+	return 0;
+}
+
 static int dccp_init_net(struct net *net, u_int16_t proto)
 {
 	struct dccp_net *dn = dccp_pernet(net);
-	struct nf_proto_net *pn = (struct nf_proto_net *)dn;
+	struct nf_proto_net *pn = &dn->pn;
 
-#ifdef CONFIG_SYSCTL
-	if (!pn->ctl_table) {
-#else
-	if (!pn->users++) {
-#endif
+	if (!pn->users) {
 		/* default values */
 		dn->dccp_loose = 1;
 		dn->dccp_timeout[CT_DCCP_REQUEST]	= 2 * DCCP_MSL;
@@ -834,24 +855,9 @@ static int dccp_init_net(struct net *net, u_int16_t proto)
 		dn->dccp_timeout[CT_DCCP_CLOSEREQ]	= 64 * HZ;
 		dn->dccp_timeout[CT_DCCP_CLOSING]	= 64 * HZ;
 		dn->dccp_timeout[CT_DCCP_TIMEWAIT]	= 2 * DCCP_MSL;
-#ifdef CONFIG_SYSCTL
-		pn->ctl_table = kmemdup(dccp_sysctl_table,
-					sizeof(dccp_sysctl_table),
-					GFP_KERNEL);
-		if (!pn->ctl_table)
-			return -ENOMEM;
-
-		pn->ctl_table[0].data = &dn->dccp_timeout[CT_DCCP_REQUEST];
-		pn->ctl_table[1].data = &dn->dccp_timeout[CT_DCCP_RESPOND];
-		pn->ctl_table[2].data = &dn->dccp_timeout[CT_DCCP_PARTOPEN];
-		pn->ctl_table[3].data = &dn->dccp_timeout[CT_DCCP_OPEN];
-		pn->ctl_table[4].data = &dn->dccp_timeout[CT_DCCP_CLOSEREQ];
-		pn->ctl_table[5].data = &dn->dccp_timeout[CT_DCCP_CLOSING];
-		pn->ctl_table[6].data = &dn->dccp_timeout[CT_DCCP_TIMEWAIT];
-		pn->ctl_table[7].data = &dn->dccp_loose;
-#endif
 	}
-	return 0;
+
+	return dccp_kmemdup_sysctl_table(pn, dn);
 }
 
 static struct nf_conntrack_l4proto dccp_proto4 __read_mostly = {
-- 
1.7.10
