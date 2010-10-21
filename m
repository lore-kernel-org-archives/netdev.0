From: kaber@trash.net
Subject: [PATCH 71/72] netfilter: ebtables: replace EBT_MATCH_ITERATE macro
Date: Thu, 21 Oct 2010 17:19:58 +0200
Message-ID: <1287674399-31455-72-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 include/linux/netfilter_bridge/ebtables.h |    9 +++++
 net/bridge/netfilter/ebtables.c           |   47 ++++++++++++++++++++--------
 2 files changed, 42 insertions(+), 14 deletions(-)

diff --git a/include/linux/netfilter_bridge/ebtables.h b/include/linux/netfilter_bridge/ebtables.h
index af0b721..1c33b9e 100644
--- a/include/linux/netfilter_bridge/ebtables.h
+++ b/include/linux/netfilter_bridge/ebtables.h
@@ -263,6 +263,14 @@ extern unsigned int ebt_do_table(unsigned int hook, struct sk_buff *skb,
 	             ((pos)->bitmask == 0 ? sizeof(struct ebt_entries) : \
 	             (pos)->next_offset)))
 
+#define ebt_ematch_foreach(pos, entry) \
+	for ((pos) = (struct ebt_entry_match *)(entry)->elems; \
+	     (pos) < (struct ebt_entry_match *)((char *)(entry) + \
+	             (entry)->watchers_offset); \
+	     (pos) = (struct ebt_entry_match *)((char *)((pos)->data) + \
+	             (pos)->match_size))
+
+#ifndef __KERNEL__
 #define EBT_MATCH_ITERATE(e, fn, args...)                   \
 ({                                                          \
 	unsigned int __i;                                   \
@@ -285,6 +293,7 @@ extern unsigned int ebt_do_table(unsigned int hook, struct sk_buff *skb,
 	}                                                   \
 	__ret;                                              \
 })
+#endif
 
 #define EBT_WATCHER_ITERATE(e, fn, args...)                 \
 ({                                                          \
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index ef4ca1b..1960c68 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -190,6 +190,7 @@ unsigned int ebt_do_table (unsigned int hook, struct sk_buff *skb,
 	const char *base;
 	const struct ebt_table_info *private;
 	struct xt_action_param acpar;
+	struct ebt_entry_match *ematch;
 
 	acpar.family  = NFPROTO_BRIDGE;
 	acpar.in      = in;
@@ -216,8 +217,9 @@ unsigned int ebt_do_table (unsigned int hook, struct sk_buff *skb,
 		if (ebt_basic_match(point, eth_hdr(skb), in, out))
 			goto letscontinue;
 
-		if (EBT_MATCH_ITERATE(point, ebt_do_match, skb, &acpar) != 0)
-			goto letscontinue;
+		ebt_ematch_foreach(ematch, point)
+			if (ebt_do_match(ematch, skb, &acpar) != 0)
+				goto letscontinue;
 		if (acpar.hotdrop) {
 			read_unlock_bh(&table->lock);
 			return NF_DROP;
@@ -621,6 +623,7 @@ ebt_cleanup_entry(struct ebt_entry *e, struct net *net, unsigned int *cnt)
 {
 	struct xt_tgdtor_param par;
 	struct ebt_entry_target *t;
+	struct ebt_entry_match *ematch;
 
 	if (e->bitmask == 0)
 		return 0;
@@ -628,7 +631,9 @@ ebt_cleanup_entry(struct ebt_entry *e, struct net *net, unsigned int *cnt)
 	if (cnt && (*cnt)-- == 0)
 		return 1;
 	EBT_WATCHER_ITERATE(e, ebt_cleanup_watcher, net, NULL);
-	EBT_MATCH_ITERATE(e, ebt_cleanup_match, net, NULL);
+	ebt_ematch_foreach(ematch, e)
+		if (ebt_cleanup_match(ematch, net, NULL) != 0)
+			break;
 	t = (struct ebt_entry_target *)(((char *)e) + e->target_offset);
 
 	par.net      = net;
@@ -654,6 +659,7 @@ ebt_check_entry(struct ebt_entry *e, struct net *net,
 	int ret;
 	struct xt_mtchk_param mtpar;
 	struct xt_tgchk_param tgpar;
+	struct ebt_entry_match *ematch;
 
 	/* don't mess with the struct ebt_entries */
 	if (e->bitmask == 0)
@@ -700,9 +706,11 @@ ebt_check_entry(struct ebt_entry *e, struct net *net,
 	mtpar.entryinfo = tgpar.entryinfo = e;
 	mtpar.hook_mask = tgpar.hook_mask = hookmask;
 	mtpar.family    = tgpar.family    = NFPROTO_BRIDGE;
-	ret = EBT_MATCH_ITERATE(e, ebt_check_match, &mtpar, &i);
-	if (ret != 0)
-		goto cleanup_matches;
+	ebt_ematch_foreach(ematch, e) {
+		ret = ebt_check_match(ematch, &mtpar, &i);
+		if (ret != 0)
+			goto cleanup_matches;
+	}
 	j = 0;
 	ret = EBT_WATCHER_ITERATE(e, ebt_check_watcher, &tgpar, &j);
 	if (ret != 0)
@@ -748,7 +756,9 @@ ebt_check_entry(struct ebt_entry *e, struct net *net,
 cleanup_watchers:
 	EBT_WATCHER_ITERATE(e, ebt_cleanup_watcher, net, &j);
 cleanup_matches:
-	EBT_MATCH_ITERATE(e, ebt_cleanup_match, net, &i);
+	ebt_ematch_foreach(ematch, e)
+		if (ebt_cleanup_match(ematch, net, &i) != 0)
+			break;
 	return ret;
 }
 
@@ -1361,6 +1371,7 @@ ebt_make_names(struct ebt_entry *e, const char *base, char __user *ubase)
 	int ret;
 	char __user *hlp;
 	const struct ebt_entry_target *t;
+	struct ebt_entry_match *ematch;
 
 	if (e->bitmask == 0)
 		return 0;
@@ -1368,9 +1379,11 @@ ebt_make_names(struct ebt_entry *e, const char *base, char __user *ubase)
 	hlp = ubase + (((char *)e + e->target_offset) - base);
 	t = (struct ebt_entry_target *)(((char *)e) + e->target_offset);
 
-	ret = EBT_MATCH_ITERATE(e, ebt_make_matchname, base, ubase);
-	if (ret != 0)
-		return ret;
+	ebt_ematch_foreach(ematch, e) {
+		ret = ebt_make_matchname(ematch, base, ubase);
+		if (ret != 0)
+			return ret;
+	}
 	ret = EBT_WATCHER_ITERATE(e, ebt_make_watchername, base, ubase);
 	if (ret != 0)
 		return ret;
@@ -1663,6 +1676,7 @@ static int compat_copy_entry_to_user(struct ebt_entry *e, void __user **dstptr,
 	struct ebt_entry __user *ce;
 	u32 watchers_offset, target_offset, next_offset;
 	compat_uint_t origsize;
+	struct ebt_entry_match *ematch;
 	int ret;
 
 	if (e->bitmask == 0) {
@@ -1686,9 +1700,11 @@ static int compat_copy_entry_to_user(struct ebt_entry *e, void __user **dstptr,
 	origsize = *size;
 	*dstptr += sizeof(*ce);
 
-	ret = EBT_MATCH_ITERATE(e, compat_match_to_user, dstptr, size);
-	if (ret)
-		return ret;
+	ebt_ematch_foreach(ematch, e) {
+		ret = compat_match_to_user(ematch, dstptr, size);
+		if (ret != 0)
+			return ret;
+	}
 	watchers_offset = e->watchers_offset - (origsize - *size);
 
 	ret = EBT_WATCHER_ITERATE(e, compat_watcher_to_user, dstptr, size);
@@ -1733,6 +1749,7 @@ static int compat_calc_entry(const struct ebt_entry *e,
 {
 	const struct ebt_entry_target *t;
 	unsigned int entry_offset;
+	struct ebt_entry_match *ematch;
 	int off, ret, i;
 
 	if (e->bitmask == 0)
@@ -1741,7 +1758,9 @@ static int compat_calc_entry(const struct ebt_entry *e,
 	off = 0;
 	entry_offset = (void *)e - base;
 
-	EBT_MATCH_ITERATE(e, compat_calc_match, &off);
+	ebt_ematch_foreach(ematch, e)
+		if (compat_calc_match(ematch, &off) != 0)
+			break;
 	EBT_WATCHER_ITERATE(e, compat_calc_watcher, &off);
 
 	t = (const struct ebt_entry_target *) ((char *) e + e->target_offset);
-- 
1.7.1

