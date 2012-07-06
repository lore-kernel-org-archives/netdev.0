From: pablo@netfilter.org
Subject: [PATCH 13/18] netfilter: nf_ct_icmp: add icmp_kmemdup[_compat]_sysctl_table function
Date: Fri,  6 Jul 2012 13:17:03 +0200
Message-ID: <1341573428-3204-14-git-send-email-pablo@netfilter.org>
References: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao feng <gaofeng@cn.fujitsu.com>

Split sysctl function into smaller chucks to cleanup code and prepare
patches to reduce ifdef pollution.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c |   41 ++++++++++++++++++++------
 1 file changed, 32 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index 76f7a2f..9c2095c 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -337,34 +337,57 @@ static struct ctl_table icmp_compat_sysctl_table[] = {
 #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 #endif /* CONFIG_SYSCTL */
 
-static int icmp_init_net(struct net *net, u_int16_t proto)
+static int icmp_kmemdup_sysctl_table(struct nf_proto_net *pn,
+				     struct nf_icmp_net *in)
 {
-	struct nf_icmp_net *in = icmp_pernet(net);
-	struct nf_proto_net *pn = (struct nf_proto_net *)in;
-	in->timeout = nf_ct_icmp_timeout;
-
 #ifdef CONFIG_SYSCTL
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
+static int icmp_kmemdup_compat_sysctl_table(struct nf_proto_net *pn,
+					    struct nf_icmp_net *in)
+{
+#ifdef CONFIG_SYSCTL
 #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
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
 
+static int icmp_init_net(struct net *net, u_int16_t proto)
+{
+	int ret;
+	struct nf_icmp_net *in = icmp_pernet(net);
+	struct nf_proto_net *pn = &in->pn;
+
+	in->timeout = nf_ct_icmp_timeout;
+
+	ret = icmp_kmemdup_compat_sysctl_table(pn, in);
+	if (ret < 0)
+		return ret;
+
+	ret = icmp_kmemdup_sysctl_table(pn, in);
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
1.7.10

