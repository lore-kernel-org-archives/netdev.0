From: kaber@trash.net
Subject: [PATCH 72/72] netfilter: ebtables: replace EBT_WATCHER_ITERATE macro
Date: Thu, 21 Oct 2010 17:19:59 +0200
Message-ID: <1287674399-31455-73-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59999 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753559Ab0JUPUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:20:18 -0400
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 include/linux/netfilter_bridge/ebtables.h |    9 ++++-
 net/bridge/netfilter/ebtables.c           |   46 ++++++++++++++++++++--------
 2 files changed, 40 insertions(+), 15 deletions(-)

diff --git a/include/linux/netfilter_bridge/ebtables.h b/include/linux/netfilter_bridge/ebtables.h
index 1c33b9e..39cc33f 100644
--- a/include/linux/netfilter_bridge/ebtables.h
+++ b/include/linux/netfilter_bridge/ebtables.h
@@ -269,6 +269,13 @@ extern unsigned int ebt_do_table(unsigned int hook, struct sk_buff *skb,
 	             (entry)->watchers_offset); \
 	     (pos) = (struct ebt_entry_match *)((char *)((pos)->data) + \
 	             (pos)->match_size))
+#define ebt_ewatcher_foreach(pos, entry) \
+	for ((pos) = (struct ebt_entry_watcher *)((entry)->elems + \
+	             (entry)->watchers_offset); \
+	     (pos) < (struct ebt_entry_watcher *)((char *)(entry) + \
+	             (entry)->target_offset); \
+	     (pos) = (struct ebt_entry_watcher *)((char *)((pos)->data) + \
+	             (pos)->watcher_size))
 
 #ifndef __KERNEL__
 #define EBT_MATCH_ITERATE(e, fn, args...)                   \
@@ -293,7 +300,6 @@ extern unsigned int ebt_do_table(unsigned int hook, struct sk_buff *skb,
 	}                                                   \
 	__ret;                                              \
 })
-#endif
 
 #define EBT_WATCHER_ITERATE(e, fn, args...)                 \
 ({                                                          \
@@ -318,7 +324,6 @@ extern unsigned int ebt_do_table(unsigned int hook, struct sk_buff *skb,
 	__ret;                                              \
 })
 
-#ifndef __KERNEL__
 #define EBT_ENTRY_ITERATE(entries, size, fn, args...)       \
 ({                                                          \
 	unsigned int __i;                                   \
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 1960c68..a824e9e 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -191,6 +191,7 @@ unsigned int ebt_do_table (unsigned int hook, struct sk_buff *skb,
 	const struct ebt_table_info *private;
 	struct xt_action_param acpar;
 	struct ebt_entry_match *ematch;
+	struct ebt_entry_watcher *ewatcher;
 
 	acpar.family  = NFPROTO_BRIDGE;
 	acpar.in      = in;
@@ -231,7 +232,9 @@ unsigned int ebt_do_table (unsigned int hook, struct sk_buff *skb,
 
 		/* these should only watch: not modify, nor tell us
 		   what to do with the packet */
-		EBT_WATCHER_ITERATE(point, ebt_do_watcher, skb, &acpar);
+		ebt_ewatcher_foreach(ewatcher, point)
+			if (ebt_do_watcher(ewatcher, skb, &acpar) != 0)
+				break;
 
 		t = (struct ebt_entry_target *)
 		   (((char *)point) + point->target_offset);
@@ -624,13 +627,16 @@ ebt_cleanup_entry(struct ebt_entry *e, struct net *net, unsigned int *cnt)
 	struct xt_tgdtor_param par;
 	struct ebt_entry_target *t;
 	struct ebt_entry_match *ematch;
+	struct ebt_entry_watcher *ewatcher;
 
 	if (e->bitmask == 0)
 		return 0;
 	/* we're done */
 	if (cnt && (*cnt)-- == 0)
 		return 1;
-	EBT_WATCHER_ITERATE(e, ebt_cleanup_watcher, net, NULL);
+	ebt_ewatcher_foreach(ewatcher, e)
+		if (ebt_cleanup_watcher(ewatcher, net, NULL) != 0)
+			break;
 	ebt_ematch_foreach(ematch, e)
 		if (ebt_cleanup_match(ematch, net, NULL) != 0)
 			break;
@@ -660,6 +666,7 @@ ebt_check_entry(struct ebt_entry *e, struct net *net,
 	struct xt_mtchk_param mtpar;
 	struct xt_tgchk_param tgpar;
 	struct ebt_entry_match *ematch;
+	struct ebt_entry_watcher *ewatcher;
 
 	/* don't mess with the struct ebt_entries */
 	if (e->bitmask == 0)
@@ -712,9 +719,11 @@ ebt_check_entry(struct ebt_entry *e, struct net *net,
 			goto cleanup_matches;
 	}
 	j = 0;
-	ret = EBT_WATCHER_ITERATE(e, ebt_check_watcher, &tgpar, &j);
-	if (ret != 0)
-		goto cleanup_watchers;
+	ebt_ewatcher_foreach(ewatcher, e) {
+		ret = ebt_check_watcher(ewatcher, &tgpar, &j);
+		if (ret != 0)
+			goto cleanup_watchers;
+	}
 	t = (struct ebt_entry_target *)(((char *)e) + e->target_offset);
 	gap = e->next_offset - e->target_offset;
 
@@ -754,7 +763,9 @@ ebt_check_entry(struct ebt_entry *e, struct net *net,
 	(*cnt)++;
 	return 0;
 cleanup_watchers:
-	EBT_WATCHER_ITERATE(e, ebt_cleanup_watcher, net, &j);
+	ebt_ewatcher_foreach(ewatcher, e)
+		if (ebt_cleanup_watcher(ewatcher, net, &j) != 0)
+			break;
 cleanup_matches:
 	ebt_ematch_foreach(ematch, e)
 		if (ebt_cleanup_match(ematch, net, &i) != 0)
@@ -1372,6 +1383,7 @@ ebt_make_names(struct ebt_entry *e, const char *base, char __user *ubase)
 	char __user *hlp;
 	const struct ebt_entry_target *t;
 	struct ebt_entry_match *ematch;
+	struct ebt_entry_watcher *ewatcher;
 
 	if (e->bitmask == 0)
 		return 0;
@@ -1384,9 +1396,11 @@ ebt_make_names(struct ebt_entry *e, const char *base, char __user *ubase)
 		if (ret != 0)
 			return ret;
 	}
-	ret = EBT_WATCHER_ITERATE(e, ebt_make_watchername, base, ubase);
-	if (ret != 0)
-		return ret;
+	ebt_ewatcher_foreach(ewatcher, e) {
+		ret = ebt_make_watchername(ewatcher, base, ubase);
+		if (ret != 0)
+			return ret;
+	}
 	if (copy_to_user(hlp, t->u.target->name, EBT_FUNCTION_MAXNAMELEN))
 		return -EFAULT;
 	return 0;
@@ -1677,6 +1691,7 @@ static int compat_copy_entry_to_user(struct ebt_entry *e, void __user **dstptr,
 	u32 watchers_offset, target_offset, next_offset;
 	compat_uint_t origsize;
 	struct ebt_entry_match *ematch;
+	struct ebt_entry_watcher *ewatcher;
 	int ret;
 
 	if (e->bitmask == 0) {
@@ -1707,9 +1722,11 @@ static int compat_copy_entry_to_user(struct ebt_entry *e, void __user **dstptr,
 	}
 	watchers_offset = e->watchers_offset - (origsize - *size);
 
-	ret = EBT_WATCHER_ITERATE(e, compat_watcher_to_user, dstptr, size);
-	if (ret)
-		return ret;
+	ebt_ewatcher_foreach(ewatcher, e) {
+		ret = compat_watcher_to_user(ewatcher, dstptr, size);
+		if (ret != 0)
+			break;
+	}
 	target_offset = e->target_offset - (origsize - *size);
 
 	t = (struct ebt_entry_target *) ((char *) e + e->target_offset);
@@ -1750,6 +1767,7 @@ static int compat_calc_entry(const struct ebt_entry *e,
 	const struct ebt_entry_target *t;
 	unsigned int entry_offset;
 	struct ebt_entry_match *ematch;
+	struct ebt_entry_watcher *ewatcher;
 	int off, ret, i;
 
 	if (e->bitmask == 0)
@@ -1761,7 +1779,9 @@ static int compat_calc_entry(const struct ebt_entry *e,
 	ebt_ematch_foreach(ematch, e)
 		if (compat_calc_match(ematch, &off) != 0)
 			break;
-	EBT_WATCHER_ITERATE(e, compat_calc_watcher, &off);
+	ebt_ewatcher_foreach(ewatcher, e)
+		if (compat_calc_watcher(ewatcher, &off) != 0)
+			break;
 
 	t = (const struct ebt_entry_target *) ((char *) e + e->target_offset);
 
-- 
1.7.1

