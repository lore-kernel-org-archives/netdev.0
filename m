From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 09/10] netfilter: nf_conntrack_l4proto_generic cleanup
Date: Thu, 14 Jun 2012 18:07:24 +0800
Message-ID: <1339668445-23848-9-git-send-email-gaofeng@cn.fujitsu.com>
References: <1339668445-23848-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1339668445-23848-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

some cleanup of nf_conntrack_l4proto_generic,
split the code to make it more clearer.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/netfilter/nf_conntrack_proto_generic.c |   41 ++++++++++++++++++++++-----
 1 files changed, 33 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netfilter/nf_conntrack_proto_generic.c
index d1ed7b4..5e3c0ea 100644
--- a/net/netfilter/nf_conntrack_proto_generic.c
+++ b/net/netfilter/nf_conntrack_proto_generic.c
@@ -135,34 +135,59 @@ static struct ctl_table generic_compat_sysctl_table[] = {
 #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 #endif /* CONFIG_SYSCTL */
 
-static int generic_init_net(struct net *net, u_int16_t proto)
+static int generic_kmemdup_sysctl_table(struct nf_proto_net *pn)
 {
-	struct nf_generic_net *gn = generic_pernet(net);
-	struct nf_proto_net *pn = (struct nf_proto_net *)gn;
-	gn->timeout = nf_ct_generic_timeout;
 #ifdef CONFIG_SYSCTL
+	struct nf_generic_net *gn = (struct nf_generic_net *)pn;
+
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
 
+static int generic_kmemdup_compat_sysctl_table(struct nf_proto_net *pn)
+{
+#ifdef CONFIG_SYSCTL
 #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
+	struct nf_generic_net *gn = (struct nf_generic_net *)pn;
+
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
+	int ret = 0;
+	struct nf_generic_net *gn = generic_pernet(net);
+	struct nf_proto_net *pn = (struct nf_proto_net *)gn;
+
+	gn->timeout = nf_ct_generic_timeout;
+
+	ret = generic_kmemdup_compat_sysctl_table(pn);
+	if (ret < 0)
+		return ret;
+
+	ret = generic_kmemdup_sysctl_table(pn);
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

