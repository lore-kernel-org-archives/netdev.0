From: pablo@netfilter.org
Subject: [PATCH 09/18] netfilter: nf_ct_udplite: add udplite_kmemdup_sysctl_table function
Date: Fri,  6 Jul 2012 13:16:59 +0200
Message-ID: <1341573428-3204-10-git-send-email-pablo@netfilter.org>
References: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao feng <gaofeng@cn.fujitsu.com>

This cleans up nf_conntrack_l4proto_udplite[4,6] and it prepares
the moving of the sysctl code to nf_conntrack_proto_*_sysctl.c
to reduce the ifdef pollution.

And use nf_proto_net.users to identify if it's the first time
we use the nf_proto_net, in that case, we initialize it.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_proto_udplite.c |   43 +++++++++++++++++-----------
 1 file changed, 26 insertions(+), 17 deletions(-)

diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index d33e511..4b66df2 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -234,29 +234,38 @@ static struct ctl_table udplite_sysctl_table[] = {
 };
 #endif /* CONFIG_SYSCTL */
 
-static int udplite_init_net(struct net *net, u_int16_t proto)
+static int udplite_kmemdup_sysctl_table(struct nf_proto_net *pn,
+					struct udplite_net *un)
 {
-	int i;
-	struct udplite_net *un = udplite_pernet(net);
-	struct nf_proto_net *pn = (struct nf_proto_net *)un;
 #ifdef CONFIG_SYSCTL
-	if (!pn->ctl_table) {
-#else
-	if (!pn->users++) {
+	if (pn->ctl_table)
+		return 0;
+
+	pn->ctl_table = kmemdup(udplite_sysctl_table,
+				sizeof(udplite_sysctl_table),
+				GFP_KERNEL);
+	if (!pn->ctl_table)
+		return -ENOMEM;
+
+	pn->ctl_table[0].data = &un->timeouts[UDPLITE_CT_UNREPLIED];
+	pn->ctl_table[1].data = &un->timeouts[UDPLITE_CT_REPLIED];
 #endif
+	return 0;
+}
+
+static int udplite_init_net(struct net *net, u_int16_t proto)
+{
+	struct udplite_net *un = udplite_pernet(net);
+	struct nf_proto_net *pn = &un->pn;
+
+	if (!pn->users) {
+		int i;
+
 		for (i = 0 ; i < UDPLITE_CT_MAX; i++)
 			un->timeouts[i] = udplite_timeouts[i];
-#ifdef CONFIG_SYSCTL
-		pn->ctl_table = kmemdup(udplite_sysctl_table,
-					sizeof(udplite_sysctl_table),
-					GFP_KERNEL);
-		if (!pn->ctl_table)
-			return -ENOMEM;
-		pn->ctl_table[0].data = &un->timeouts[UDPLITE_CT_UNREPLIED];
-		pn->ctl_table[1].data = &un->timeouts[UDPLITE_CT_REPLIED];
-#endif
 	}
-	return 0;
+
+	return udplite_kmemdup_sysctl_table(pn, un);
 }
 
 static struct nf_conntrack_l4proto nf_conntrack_l4proto_udplite4 __read_mostly =
-- 
1.7.10

