From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 10/10] netfilter: nf_conntrack_l4proto_dccp[4,6] cleanup
Date: Thu, 14 Jun 2012 18:07:25 +0800
Message-ID: <1339668445-23848-10-git-send-email-gaofeng@cn.fujitsu.com>
References: <1339668445-23848-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1339668445-23848-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

some cleanup of nf_conntrack_l4proto_dccp[4,6],
make codes more clearer and ready for moving the
sysctl code to nf_conntrack_proto_*_sysctl.c to
reduce the ifdef pollution.

and use nf_proto_net.users to identify if it's the first time
we use the nf_proto_net. when it's the first time,we will
initialized it.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/netfilter/nf_conntrack_proto_dccp.c |   51 +++++++++++++++++-------------
 1 files changed, 29 insertions(+), 22 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index 52da8f0..ef044ef 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -815,16 +815,38 @@ static struct ctl_table dccp_sysctl_table[] = {
 };
 #endif /* CONFIG_SYSCTL */
 
+static int dccp_kmemdup_sysctl_table(struct nf_proto_net *pn)
+{
+#ifdef CONFIG_SYSCTL
+	struct dccp_net *dn = (struct dccp_net *)pn;
+
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
 	struct nf_proto_net *pn = (struct nf_proto_net *)dn;
 
-#ifdef CONFIG_SYSCTL
-	if (!pn->ctl_table) {
-#else
-	if (!pn->users++) {
-#endif
+	if (!pn->users) {
 		/* default values */
 		dn->dccp_loose = 1;
 		dn->dccp_timeout[CT_DCCP_REQUEST]	= 2 * DCCP_MSL;
@@ -834,24 +856,9 @@ static int dccp_init_net(struct net *net, u_int16_t proto)
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
+	return dccp_kmemdup_sysctl_table(pn);
 }
 
 static struct nf_conntrack_l4proto dccp_proto4 __read_mostly = {
-- 
1.7.7.6

