From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH net-next v2 11/12] netfilter: nf_conntrack_l4proto_icmp cleanup
Date: Sat, 16 Jun 2012 11:41:22 +0800
Message-ID: <1339818083-31356-11-git-send-email-gaofeng@cn.fujitsu.com>
References: <1339818083-31356-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50375 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1758959Ab2FPDlH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jun 2012 23:41:07 -0400
In-Reply-To: <1339818083-31356-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add two functions icmp_kmemdup_sysctl_table and
icmp_kmemdup_compat_sysctl_table to make codes more
clearer.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c |   44 ++++++++++++++++++++-----
 1 files changed, 35 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index 76f7a2f..be7ae4c 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -337,34 +337,60 @@ static struct ctl_table icmp_compat_sysctl_table[] = {
 #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 #endif /* CONFIG_SYSCTL */
 
-static int icmp_init_net(struct net *net, u_int16_t proto)
+static int icmp_kmemdup_sysctl_table(struct nf_proto_net *pn)
 {
-	struct nf_icmp_net *in = icmp_pernet(net);
-	struct nf_proto_net *pn = (struct nf_proto_net *)in;
-	in->timeout = nf_ct_icmp_timeout;
-
 #ifdef CONFIG_SYSCTL
+	struct nf_icmp_net *in = (struct nf_icmp_net *)pn;
+
 	pn->ctl_table = kmemdup(icmp_sysctl_table,
 				sizeof(icmp_sysctl_table),
 				GFP_KERNEL);
 	if (!pn->ctl_table)
 		return -ENOMEM;
+
 	pn->ctl_table[0].data = &in->timeout;
+#endif
+	return 0;
+}
+
+static int icmp_kmemdup_compat_sysctl_table(struct nf_proto_net *pn)
+{
+#ifdef CONFIG_SYSCTL
 #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
+	struct nf_icmp_net *in = (struct nf_icmp_net *)pn;
+
 	pn->ctl_compat_table = kmemdup(icmp_compat_sysctl_table,
 				       sizeof(icmp_compat_sysctl_table),
 				       GFP_KERNEL);
-	if (!pn->ctl_compat_table) {
-		kfree(pn->ctl_table);
-		pn->ctl_table = NULL;
+	if (!pn->ctl_compat_table)
 		return -ENOMEM;
-	}
+
 	pn->ctl_compat_table[0].data = &in->timeout;
 #endif
 #endif
 	return 0;
 }
 
+
+static int icmp_init_net(struct net *net, u_int16_t proto)
+{
+	int ret;
+	struct nf_icmp_net *in = icmp_pernet(net);
+	struct nf_proto_net *pn = &in->pn;
+
+	in->timeout = nf_ct_icmp_timeout;
+
+	ret = icmp_kmemdup_compat_sysctl_table(pn);
+	if (ret < 0)
+		return ret;
+
+	ret = icmp_kmemdup_sysctl_table(pn);
+	if (ret < 0)
+		nf_ct_kfree_compat_sysctl_table(pn);
+
+	return ret;
+}
+
 struct nf_conntrack_l4proto nf_conntrack_l4proto_icmp __read_mostly =
 {
 	.l3proto		= PF_INET,
-- 
1.7.7.6
