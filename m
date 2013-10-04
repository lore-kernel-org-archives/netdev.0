From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/33] netfilter: ipset: order matches and targets separatedly in xt_set.c
Date: Fri,  4 Oct 2013 10:32:56 +0200
Message-ID: <1380875598-5250-12-git-send-email-pablo@netfilter.org>
References: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1380875598-5250-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/xt_set.c |  188 ++++++++++++++++++++++++------------------------
 1 file changed, 96 insertions(+), 92 deletions(-)

diff --git a/net/netfilter/xt_set.c b/net/netfilter/xt_set.c
index 31790e7..2095488 100644
--- a/net/netfilter/xt_set.c
+++ b/net/netfilter/xt_set.c
@@ -109,6 +109,101 @@ set_match_v0_destroy(const struct xt_mtdtor_param *par)
 	ip_set_nfnl_put(info->match_set.index);
 }
 
+/* Revision 1 match */
+
+static bool
+set_match_v1(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	const struct xt_set_info_match_v1 *info = par->matchinfo;
+	ADT_OPT(opt, par->family, info->match_set.dim,
+		info->match_set.flags, 0, UINT_MAX);
+
+	if (opt.flags & IPSET_RETURN_NOMATCH)
+		opt.cmdflags |= IPSET_FLAG_RETURN_NOMATCH;
+
+	return match_set(info->match_set.index, skb, par, &opt,
+			 info->match_set.flags & IPSET_INV_MATCH);
+}
+
+static int
+set_match_v1_checkentry(const struct xt_mtchk_param *par)
+{
+	struct xt_set_info_match_v1 *info = par->matchinfo;
+	ip_set_id_t index;
+
+	index = ip_set_nfnl_get_byindex(info->match_set.index);
+
+	if (index == IPSET_INVALID_ID) {
+		pr_warning("Cannot find set indentified by id %u to match\n",
+			   info->match_set.index);
+		return -ENOENT;
+	}
+	if (info->match_set.dim > IPSET_DIM_MAX) {
+		pr_warning("Protocol error: set match dimension "
+			   "is over the limit!\n");
+		ip_set_nfnl_put(info->match_set.index);
+		return -ERANGE;
+	}
+
+	return 0;
+}
+
+static void
+set_match_v1_destroy(const struct xt_mtdtor_param *par)
+{
+	struct xt_set_info_match_v1 *info = par->matchinfo;
+
+	ip_set_nfnl_put(info->match_set.index);
+}
+
+/* Revision 3 match */
+
+static bool
+match_counter(u64 counter, const struct ip_set_counter_match *info)
+{
+	switch (info->op) {
+	case IPSET_COUNTER_NONE:
+		return true;
+	case IPSET_COUNTER_EQ:
+		return counter == info->value;
+	case IPSET_COUNTER_NE:
+		return counter != info->value;
+	case IPSET_COUNTER_LT:
+		return counter < info->value;
+	case IPSET_COUNTER_GT:
+		return counter > info->value;
+	}
+	return false;
+}
+
+static bool
+set_match_v3(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	const struct xt_set_info_match_v3 *info = par->matchinfo;
+	ADT_OPT(opt, par->family, info->match_set.dim,
+		info->match_set.flags, info->flags, UINT_MAX);
+	int ret;
+
+	if (info->packets.op != IPSET_COUNTER_NONE ||
+	    info->bytes.op != IPSET_COUNTER_NONE)
+		opt.cmdflags |= IPSET_FLAG_MATCH_COUNTERS;
+
+	ret = match_set(info->match_set.index, skb, par, &opt,
+			info->match_set.flags & IPSET_INV_MATCH);
+
+	if (!(ret && opt.cmdflags & IPSET_FLAG_MATCH_COUNTERS))
+		return ret;
+
+	if (!match_counter(opt.ext.packets, &info->packets))
+		return 0;
+	return match_counter(opt.ext.bytes, &info->bytes);
+}
+
+#define set_match_v3_checkentry	set_match_v1_checkentry
+#define set_match_v3_destroy	set_match_v1_destroy
+
+/* Revision 0 interface: backward compatible with netfilter/iptables */
+
 static unsigned int
 set_target_v0(struct sk_buff *skb, const struct xt_action_param *par)
 {
@@ -180,52 +275,7 @@ set_target_v0_destroy(const struct xt_tgdtor_param *par)
 		ip_set_nfnl_put(info->del_set.index);
 }
 
-/* Revision 1 match and target */
-
-static bool
-set_match_v1(const struct sk_buff *skb, struct xt_action_param *par)
-{
-	const struct xt_set_info_match_v1 *info = par->matchinfo;
-	ADT_OPT(opt, par->family, info->match_set.dim,
-		info->match_set.flags, 0, UINT_MAX);
-
-	if (opt.flags & IPSET_RETURN_NOMATCH)
-		opt.cmdflags |= IPSET_FLAG_RETURN_NOMATCH;
-
-	return match_set(info->match_set.index, skb, par, &opt,
-			 info->match_set.flags & IPSET_INV_MATCH);
-}
-
-static int
-set_match_v1_checkentry(const struct xt_mtchk_param *par)
-{
-	struct xt_set_info_match_v1 *info = par->matchinfo;
-	ip_set_id_t index;
-
-	index = ip_set_nfnl_get_byindex(info->match_set.index);
-
-	if (index == IPSET_INVALID_ID) {
-		pr_warning("Cannot find set indentified by id %u to match\n",
-			   info->match_set.index);
-		return -ENOENT;
-	}
-	if (info->match_set.dim > IPSET_DIM_MAX) {
-		pr_warning("Protocol error: set match dimension "
-			   "is over the limit!\n");
-		ip_set_nfnl_put(info->match_set.index);
-		return -ERANGE;
-	}
-
-	return 0;
-}
-
-static void
-set_match_v1_destroy(const struct xt_mtdtor_param *par)
-{
-	struct xt_set_info_match_v1 *info = par->matchinfo;
-
-	ip_set_nfnl_put(info->match_set.index);
-}
+/* Revision 1 target */
 
 static unsigned int
 set_target_v1(struct sk_buff *skb, const struct xt_action_param *par)
@@ -320,52 +370,6 @@ set_target_v2(struct sk_buff *skb, const struct xt_action_param *par)
 #define set_target_v2_checkentry	set_target_v1_checkentry
 #define set_target_v2_destroy		set_target_v1_destroy
 
-/* Revision 3 match */
-
-static bool
-match_counter(u64 counter, const struct ip_set_counter_match *info)
-{
-	switch (info->op) {
-	case IPSET_COUNTER_NONE:
-		return true;
-	case IPSET_COUNTER_EQ:
-		return counter == info->value;
-	case IPSET_COUNTER_NE:
-		return counter != info->value;
-	case IPSET_COUNTER_LT:
-		return counter < info->value;
-	case IPSET_COUNTER_GT:
-		return counter > info->value;
-	}
-	return false;
-}
-
-static bool
-set_match_v3(const struct sk_buff *skb, struct xt_action_param *par)
-{
-	const struct xt_set_info_match_v3 *info = par->matchinfo;
-	ADT_OPT(opt, par->family, info->match_set.dim,
-		info->match_set.flags, info->flags, UINT_MAX);
-	int ret;
-
-	if (info->packets.op != IPSET_COUNTER_NONE ||
-	    info->bytes.op != IPSET_COUNTER_NONE)
-		opt.cmdflags |= IPSET_FLAG_MATCH_COUNTERS;
-
-	ret = match_set(info->match_set.index, skb, par, &opt,
-			info->match_set.flags & IPSET_INV_MATCH);
-
-	if (!(ret && opt.cmdflags & IPSET_FLAG_MATCH_COUNTERS))
-		return ret;
-
-	if (!match_counter(opt.ext.packets, &info->packets))
-		return 0;
-	return match_counter(opt.ext.bytes, &info->bytes);
-}
-
-#define set_match_v3_checkentry	set_match_v1_checkentry
-#define set_match_v3_destroy	set_match_v1_destroy
-
 static struct xt_match set_matches[] __read_mostly = {
 	{
 		.name		= "set",
-- 
1.7.10.4

