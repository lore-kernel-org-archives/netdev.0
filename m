From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/18] netfilter: ipset: set match: add support to match the counters
Date: Mon, 29 Apr 2013 20:22:19 +0200
Message-ID: <1367259744-8922-14-git-send-email-pablo@netfilter.org>
References: <1367259744-8922-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1367259744-8922-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

The new revision of the set match supports to match the counters
and to suppress updating the counters at matching too.

At the set:list types, the updating of the subcounters can be
suppressed as well.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/ipset/ip_set.h      |    9 +++-
 include/uapi/linux/netfilter/ipset/ip_set.h |   31 ++++++++++--
 include/uapi/linux/netfilter/xt_set.h       |    9 ++++
 net/netfilter/ipset/ip_set_core.c           |    2 +-
 net/netfilter/ipset/ip_set_list_set.c       |    8 ++-
 net/netfilter/xt_set.c                      |   70 +++++++++++++++++++++++++++
 6 files changed, 120 insertions(+), 9 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index 0f978eb..d80e275 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -76,7 +76,7 @@ struct ip_set;
 
 typedef int (*ipset_adtfn)(struct ip_set *set, void *value,
 			   const struct ip_set_ext *ext,
-			   struct ip_set_ext *mext, u32 flags);
+			   struct ip_set_ext *mext, u32 cmdflags);
 
 /* Kernel API function options */
 struct ip_set_adt_opt {
@@ -217,10 +217,15 @@ ip_set_update_counter(struct ip_set_counter *counter,
 		      const struct ip_set_ext *ext,
 		      struct ip_set_ext *mext, u32 flags)
 {
-	if (ext->packets != ULLONG_MAX) {
+	if (ext->packets != ULLONG_MAX &&
+	    !(flags & IPSET_FLAG_SKIP_COUNTER_UPDATE)) {
 		ip_set_add_bytes(ext->bytes, counter);
 		ip_set_add_packets(ext->packets, counter);
 	}
+	if (flags & IPSET_FLAG_MATCH_COUNTERS) {
+		mext->packets = ip_set_get_packets(counter);
+		mext->bytes = ip_set_get_bytes(counter);
+	}
 }
 
 static inline bool
diff --git a/include/uapi/linux/netfilter/ipset/ip_set.h b/include/uapi/linux/netfilter/ipset/ip_set.h
index ed45267..8024cdf 100644
--- a/include/uapi/linux/netfilter/ipset/ip_set.h
+++ b/include/uapi/linux/netfilter/ipset/ip_set.h
@@ -145,7 +145,7 @@ enum ipset_errno {
 	IPSET_ERR_TYPE_SPECIFIC = 4352,
 };
 
-/* Flags at command level */
+/* Flags at command level or match/target flags, lower half of cmdattrs*/
 enum ipset_cmd_flags {
 	IPSET_FLAG_BIT_EXIST	= 0,
 	IPSET_FLAG_EXIST	= (1 << IPSET_FLAG_BIT_EXIST),
@@ -153,10 +153,20 @@ enum ipset_cmd_flags {
 	IPSET_FLAG_LIST_SETNAME	= (1 << IPSET_FLAG_BIT_LIST_SETNAME),
 	IPSET_FLAG_BIT_LIST_HEADER = 2,
 	IPSET_FLAG_LIST_HEADER	= (1 << IPSET_FLAG_BIT_LIST_HEADER),
-	IPSET_FLAG_CMD_MAX = 15,	/* Lower half */
+	IPSET_FLAG_BIT_SKIP_COUNTER_UPDATE = 3,
+	IPSET_FLAG_SKIP_COUNTER_UPDATE =
+		(1 << IPSET_FLAG_BIT_SKIP_COUNTER_UPDATE),
+	IPSET_FLAG_BIT_SKIP_SUBCOUNTER_UPDATE = 4,
+	IPSET_FLAG_SKIP_SUBCOUNTER_UPDATE =
+		(1 << IPSET_FLAG_BIT_SKIP_SUBCOUNTER_UPDATE),
+	IPSET_FLAG_BIT_MATCH_COUNTERS = 5,
+	IPSET_FLAG_MATCH_COUNTERS = (1 << IPSET_FLAG_BIT_MATCH_COUNTERS),
+	IPSET_FLAG_BIT_RETURN_NOMATCH = 7,
+	IPSET_FLAG_RETURN_NOMATCH = (1 << IPSET_FLAG_BIT_RETURN_NOMATCH),
+	IPSET_FLAG_CMD_MAX = 15,
 };
 
-/* Flags at CADT attribute level */
+/* Flags at CADT attribute level, upper half of cmdattrs */
 enum ipset_cadt_flags {
 	IPSET_FLAG_BIT_BEFORE	= 0,
 	IPSET_FLAG_BEFORE	= (1 << IPSET_FLAG_BIT_BEFORE),
@@ -166,7 +176,7 @@ enum ipset_cadt_flags {
 	IPSET_FLAG_NOMATCH	= (1 << IPSET_FLAG_BIT_NOMATCH),
 	IPSET_FLAG_BIT_WITH_COUNTERS = 3,
 	IPSET_FLAG_WITH_COUNTERS = (1 << IPSET_FLAG_BIT_WITH_COUNTERS),
-	IPSET_FLAG_CADT_MAX	= 15,	/* Upper half */
+	IPSET_FLAG_CADT_MAX	= 15,
 };
 
 /* Commands with settype-specific attributes */
@@ -195,6 +205,7 @@ enum ip_set_dim {
 	 * If changed, new revision of iptables match/target is required.
 	 */
 	IPSET_DIM_MAX = 6,
+	/* Backward compatibility: set match revision 2 */
 	IPSET_BIT_RETURN_NOMATCH = 7,
 };
 
@@ -207,6 +218,18 @@ enum ip_set_kopt {
 	IPSET_RETURN_NOMATCH = (1 << IPSET_BIT_RETURN_NOMATCH),
 };
 
+enum {
+	IPSET_COUNTER_NONE = 0,
+	IPSET_COUNTER_EQ,
+	IPSET_COUNTER_NE,
+	IPSET_COUNTER_LT,
+	IPSET_COUNTER_GT,
+};
+
+struct ip_set_counter_match {
+	__u8 op;
+	__u64 value;
+};
 
 /* Interface to iptables/ip6tables */
 
diff --git a/include/uapi/linux/netfilter/xt_set.h b/include/uapi/linux/netfilter/xt_set.h
index e3a9978..964d3d4 100644
--- a/include/uapi/linux/netfilter/xt_set.h
+++ b/include/uapi/linux/netfilter/xt_set.h
@@ -62,4 +62,13 @@ struct xt_set_info_target_v2 {
 	__u32 timeout;
 };
 
+/* Revision 3 match */
+
+struct xt_set_info_match_v3 {
+	struct xt_set_info match_set;
+	struct ip_set_counter_match packets;
+	struct ip_set_counter_match bytes;
+	__u32 flags;
+};
+
 #endif /*_XT_SET_H*/
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index f6d878a..f771390 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -413,7 +413,7 @@ ip_set_test(ip_set_id_t index, const struct sk_buff *skb,
 		ret = 1;
 	} else {
 		/* --return-nomatch: invert matched element */
-		if ((opt->flags & IPSET_RETURN_NOMATCH) &&
+		if ((opt->cmdflags & IPSET_FLAG_RETURN_NOMATCH) &&
 		    (set->type->features & IPSET_TYPE_NOMATCH) &&
 		    (ret > 0 || ret == -ENOTEMPTY))
 			ret = -ret;
diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index c09022e..979b8c9 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -84,9 +84,13 @@ list_set_ktest(struct ip_set *set, const struct sk_buff *skb,
 {
 	struct list_set *map = set->data;
 	struct set_elem *e;
-	u32 i;
+	u32 i, cmdflags = opt->cmdflags;
 	int ret;
 
+	/* Don't lookup sub-counters at all */
+	opt->cmdflags &= ~IPSET_FLAG_MATCH_COUNTERS;
+	if (opt->cmdflags & IPSET_FLAG_SKIP_SUBCOUNTER_UPDATE)
+		opt->cmdflags &= ~IPSET_FLAG_SKIP_COUNTER_UPDATE;
 	for (i = 0; i < map->size; i++) {
 		e = list_set_elem(map, i);
 		if (e->id == IPSET_INVALID_ID)
@@ -99,7 +103,7 @@ list_set_ktest(struct ip_set *set, const struct sk_buff *skb,
 			if (SET_WITH_COUNTER(set))
 				ip_set_update_counter(ext_counter(e, map),
 						      ext, &opt->ext,
-						      opt->cmdflags);
+						      cmdflags);
 			return ret;
 		}
 	}
diff --git a/net/netfilter/xt_set.c b/net/netfilter/xt_set.c
index 636c519..31790e7 100644
--- a/net/netfilter/xt_set.c
+++ b/net/netfilter/xt_set.c
@@ -189,6 +189,9 @@ set_match_v1(const struct sk_buff *skb, struct xt_action_param *par)
 	ADT_OPT(opt, par->family, info->match_set.dim,
 		info->match_set.flags, 0, UINT_MAX);
 
+	if (opt.flags & IPSET_RETURN_NOMATCH)
+		opt.cmdflags |= IPSET_FLAG_RETURN_NOMATCH;
+
 	return match_set(info->match_set.index, skb, par, &opt,
 			 info->match_set.flags & IPSET_INV_MATCH);
 }
@@ -317,6 +320,52 @@ set_target_v2(struct sk_buff *skb, const struct xt_action_param *par)
 #define set_target_v2_checkentry	set_target_v1_checkentry
 #define set_target_v2_destroy		set_target_v1_destroy
 
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
 static struct xt_match set_matches[] __read_mostly = {
 	{
 		.name		= "set",
@@ -369,6 +418,27 @@ static struct xt_match set_matches[] __read_mostly = {
 		.destroy	= set_match_v1_destroy,
 		.me		= THIS_MODULE
 	},
+	/* counters support: update, match */
+	{
+		.name		= "set",
+		.family		= NFPROTO_IPV4,
+		.revision	= 3,
+		.match		= set_match_v3,
+		.matchsize	= sizeof(struct xt_set_info_match_v3),
+		.checkentry	= set_match_v3_checkentry,
+		.destroy	= set_match_v3_destroy,
+		.me		= THIS_MODULE
+	},
+	{
+		.name		= "set",
+		.family		= NFPROTO_IPV6,
+		.revision	= 3,
+		.match		= set_match_v3,
+		.matchsize	= sizeof(struct xt_set_info_match_v3),
+		.checkentry	= set_match_v3_checkentry,
+		.destroy	= set_match_v3_destroy,
+		.me		= THIS_MODULE
+	},
 };
 
 static struct xt_target set_targets[] __read_mostly = {
-- 
1.7.10.4

