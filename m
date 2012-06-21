From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 10/13] netfilter: nf_conntrack_l4proto_generic cleanup
Date: Thu, 21 Jun 2012 22:36:47 +0800
Message-ID: <1340289410-17642-10-git-send-email-gaofeng@cn.fujitsu.com>
References: <1340289410-17642-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1340289410-17642-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

some cleanup of nf_conntrack_l4proto_generic,
split the code to make it more clearer.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/netfilter/nf_conntrack_proto_generic.c |   39 ++++++++++++++++++++++-----
 1 files changed, 31 insertions(+), 8 deletions(-)

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
1.7.7.6

