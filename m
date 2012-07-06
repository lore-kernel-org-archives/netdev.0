From: pablo@netfilter.org
Subject: [PATCH 11/18] netfilter: nf_ct_generic: add generic_kmemdup_sysctl_table function
Date: Fri,  6 Jul 2012 13:17:01 +0200
Message-ID: <1341573428-3204-12-git-send-email-pablo@netfilter.org>
References: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43472 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933543Ab2GFLTE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 07:19:04 -0400
In-Reply-To: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>

This patch is a cleanup. It adds generic_kmemdup_sysctl_table to
split code into smaller chunks. Yet it prepares introduction
of nf_conntrack_proto_*_sysctl.c.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_proto_generic.c |   39 ++++++++++++++++++++++------
 1 file changed, 31 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netfilter/nf_conntrack_proto_generic.c
index d1ed7b4..7c11c54 100644
--- a/net/netfilter/nf_conntrack_proto_generic.c
+++ b/net/netfilter/nf_conntrack_proto_generic.c
@@ -135,34 +135,57 @@ static struct ctl_table generic_compat_sysctl_table[] = {
 #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 #endif /* CONFIG_SYSCTL */
 
-static int generic_init_net(struct net *net, u_int16_t proto)
+static int generic_kmemdup_sysctl_table(struct nf_proto_net *pn,
+					struct nf_generic_net *gn)
 {
-	struct nf_generic_net *gn = generic_pernet(net);
-	struct nf_proto_net *pn = (struct nf_proto_net *)gn;
-	gn->timeout = nf_ct_generic_timeout;
 #ifdef CONFIG_SYSCTL
 	pn->ctl_table = kmemdup(generic_sysctl_table,
 				sizeof(generic_sysctl_table),
 				GFP_KERNEL);
 	if (!pn->ctl_table)
 		return -ENOMEM;
+
 	pn->ctl_table[0].data = &gn->timeout;
+#endif
+	return 0;
+}
 
+static int generic_kmemdup_compat_sysctl_table(struct nf_proto_net *pn,
+					       struct nf_generic_net *gn)
+{
+#ifdef CONFIG_SYSCTL
 #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
 	pn->ctl_compat_table = kmemdup(generic_compat_sysctl_table,
 				       sizeof(generic_compat_sysctl_table),
 				       GFP_KERNEL);
-	if (!pn->ctl_compat_table) {
-		kfree(pn->ctl_table);
-		pn->ctl_table = NULL;
+	if (!pn->ctl_compat_table)
 		return -ENOMEM;
-	}
+
 	pn->ctl_compat_table[0].data = &gn->timeout;
 #endif
 #endif
 	return 0;
 }
 
+static int generic_init_net(struct net *net, u_int16_t proto)
+{
+	int ret;
+	struct nf_generic_net *gn = generic_pernet(net);
+	struct nf_proto_net *pn = &gn->pn;
+
+	gn->timeout = nf_ct_generic_timeout;
+
+	ret = generic_kmemdup_compat_sysctl_table(pn, gn);
+	if (ret < 0)
+		return ret;
+
+	ret = generic_kmemdup_sysctl_table(pn, gn);
+	if (ret < 0)
+		nf_ct_kfree_compat_sysctl_table(pn);
+
+	return ret;
+}
+
 struct nf_conntrack_l4proto nf_conntrack_l4proto_generic __read_mostly =
 {
 	.l3proto		= PF_UNSPEC,
-- 
1.7.10
