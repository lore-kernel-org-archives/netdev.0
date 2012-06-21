From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 08/13] netfilter: nf_conntrack_l4proto_udplite[4,6] cleanup
Date: Thu, 21 Jun 2012 22:36:45 +0800
Message-ID: <1340289410-17642-8-git-send-email-gaofeng@cn.fujitsu.com>
References: <1340289410-17642-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1340289410-17642-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

some cleanup for nf_conntrack_l4proto_udplite[4,6],
make codes more clearer and ready for moving the
sysctl code to nf_conntrack_proto_*_sysctl.c to
reduce the ifdef pollution.

and use nf_proto_net.users to identify if it's the first time
we use the nf_proto_net. when it's the first time,we will
initialized it.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/netfilter/nf_conntrack_proto_udplite.c |   43 +++++++++++++++++-----------
 1 files changed, 26 insertions(+), 17 deletions(-)

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
1.7.7.6

