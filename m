From: kaber@trash.net
Subject: [PATCH 70/72] netfilter: ebtables: replace EBT_ENTRY_ITERATE macro
Date: Thu, 21 Oct 2010 17:19:57 +0200
Message-ID: <1287674399-31455-71-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

The macro is replaced by a list.h-like foreach loop. This makes the

This is similar to v2.6.33-rc8-1212-g72b2b1d.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 include/linux/netfilter_bridge/ebtables.h |   14 ++++-
 net/bridge/netfilter/ebtables.c           |   93 +++++++++++++++++++----------
 2 files changed, 74 insertions(+), 33 deletions(-)

diff --git a/include/linux/netfilter_bridge/ebtables.h b/include/linux/netfilter_bridge/ebtables.h
index cbbb883..af0b721 100644
--- a/include/linux/netfilter_bridge/ebtables.h
+++ b/include/linux/netfilter_bridge/ebtables.h
@@ -254,8 +254,15 @@ extern unsigned int ebt_do_table(unsigned int hook, struct sk_buff *skb,
 
 #endif /* __KERNEL__ */
 
-/* blatently stolen from ip_tables.h
+/* blatantly stolen from ip_tables.h
  * fn returns 0 to continue iteration */
+#define ebt_entry_foreach(pos, ehead, esize) \
+	for ((pos) = (struct ebt_entry *)(ehead); \
+	     (pos) < (struct ebt_entry *)((char *)(ehead) + (esize)); \
+	     (pos) = (struct ebt_entry *)((char *)(pos) + \
+	             ((pos)->bitmask == 0 ? sizeof(struct ebt_entries) : \
+	             (pos)->next_offset)))
+
 #define EBT_MATCH_ITERATE(e, fn, args...)                   \
 ({                                                          \
 	unsigned int __i;                                   \
@@ -302,6 +309,7 @@ extern unsigned int ebt_do_table(unsigned int hook, struct sk_buff *skb,
 	__ret;                                              \
 })
 
+#ifndef __KERNEL__
 #define EBT_ENTRY_ITERATE(entries, size, fn, args...)       \
 ({                                                          \
 	unsigned int __i;                                   \
@@ -324,5 +332,7 @@ extern unsigned int ebt_do_table(unsigned int hook, struct sk_buff *skb,
 	}                                                   \
 	__ret;                                              \
 })
+#endif /* __KERNEL__ */
+
+#endif /* __LINUX_BRIDGE_EFF_H */
 
-#endif
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index bcc102e..ef4ca1b 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -834,6 +834,7 @@ static int translate_table(struct net *net, const char *name,
 	unsigned int i, j, k, udc_cnt;
 	int ret;
 	struct ebt_cl_stack *cl_s = NULL; /* used in the checking for chain loops */
+	struct ebt_entry *entry;
 
 	i = 0;
 	while (i < NF_BR_NUMHOOKS && !newinfo->hook_entry[i])
@@ -864,12 +865,12 @@ static int translate_table(struct net *net, const char *name,
 	k = 0; /* holds the total nr. of entries, should equal
 		  newinfo->nentries afterwards */
 	udc_cnt = 0; /* will hold the nr. of user defined chains (udc) */
-	ret = EBT_ENTRY_ITERATE(newinfo->entries, newinfo->entries_size,
-	   ebt_check_entry_size_and_hooks, newinfo,
-	   &i, &j, &k, &udc_cnt);
-
-	if (ret != 0)
-		return ret;
+	ebt_entry_foreach(entry, newinfo->entries, newinfo->entries_size) {
+		ret = ebt_check_entry_size_and_hooks(entry, newinfo,
+						     &i, &j, &k, &udc_cnt);
+		if (ret != 0)
+			return ret;
+	}
 
 	if (i != j) {
 		BUGPRINT("nentries does not equal the nr of entries in the "
@@ -906,8 +907,10 @@ static int translate_table(struct net *net, const char *name,
 		if (!cl_s)
 			return -ENOMEM;
 		i = 0; /* the i'th udc */
-		EBT_ENTRY_ITERATE(newinfo->entries, newinfo->entries_size,
-		   ebt_get_udc_positions, newinfo, &i, cl_s);
+		ebt_entry_foreach(entry, newinfo->entries,
+		    newinfo->entries_size)
+			if (ebt_get_udc_positions(entry, newinfo, &i, cl_s) < 0)
+				break;
 		/* sanity check */
 		if (i != udc_cnt) {
 			BUGPRINT("i != udc_cnt\n");
@@ -937,12 +940,18 @@ static int translate_table(struct net *net, const char *name,
 
 	/* used to know what we need to clean up if something goes wrong */
 	i = 0;
-	ret = EBT_ENTRY_ITERATE(newinfo->entries, newinfo->entries_size,
-	   ebt_check_entry, net, newinfo, name, &i, cl_s, udc_cnt);
-	if (ret != 0) {
-		EBT_ENTRY_ITERATE(newinfo->entries, newinfo->entries_size,
-				  ebt_cleanup_entry, net, &i);
+	ret = 0;
+	ebt_entry_foreach(entry, newinfo->entries, newinfo->entries_size) {
+		ret = ebt_check_entry(entry, net, newinfo, name, &i,
+				      cl_s, udc_cnt);
+		if (ret != 0)
+			break;
 	}
+	if (ret != 0)
+		ebt_entry_foreach(entry, newinfo->entries,
+		    newinfo->entries_size)
+			if (ebt_cleanup_entry(entry, net, &i) != 0)
+				break;
 	vfree(cl_s);
 	return ret;
 }
@@ -978,6 +987,7 @@ static int do_replace_finish(struct net *net, struct ebt_replace *repl,
 	/* used to be able to unlock earlier */
 	struct ebt_table_info *table;
 	struct ebt_table *t;
+	struct ebt_entry *entry;
 
 	/* the user wants counters back
 	   the check on the size is done later, when we have the lock */
@@ -1044,8 +1054,9 @@ static int do_replace_finish(struct net *net, struct ebt_replace *repl,
 		ret = 0;
 
 	/* decrease module count and free resources */
-	EBT_ENTRY_ITERATE(table->entries, table->entries_size,
-			  ebt_cleanup_entry, net, NULL);
+	ebt_entry_foreach(entry, table->entries, table->entries_size)
+		if (ebt_cleanup_entry(entry, net, NULL) != 0)
+			break;
 
 	vfree(table->entries);
 	if (table->chainstack) {
@@ -1061,8 +1072,9 @@ static int do_replace_finish(struct net *net, struct ebt_replace *repl,
 free_unlock:
 	mutex_unlock(&ebt_mutex);
 free_iterate:
-	EBT_ENTRY_ITERATE(newinfo->entries, newinfo->entries_size,
-			  ebt_cleanup_entry, net, NULL);
+	ebt_entry_foreach(entry, newinfo->entries, newinfo->entries_size)
+		if (ebt_cleanup_entry(entry, net, NULL) != 0)
+			break;
 free_counterstmp:
 	vfree(counterstmp);
 	/* can be initialized in translate_table() */
@@ -1234,6 +1246,7 @@ out:
 
 void ebt_unregister_table(struct net *net, struct ebt_table *table)
 {
+	struct ebt_entry *entry;
 	int i;
 
 	if (!table) {
@@ -1243,8 +1256,10 @@ void ebt_unregister_table(struct net *net, struct ebt_table *table)
 	mutex_lock(&ebt_mutex);
 	list_del(&table->list);
 	mutex_unlock(&ebt_mutex);
-	EBT_ENTRY_ITERATE(table->private->entries, table->private->entries_size,
-			  ebt_cleanup_entry, net, NULL);
+	ebt_entry_foreach(entry, table->private->entries,
+	    table->private->entries_size)
+		if (ebt_cleanup_entry(entry, net, NULL) != 0)
+			break;
 	if (table->private->nentries)
 		module_put(table->me);
 	vfree(table->private->entries);
@@ -1403,6 +1418,7 @@ static int copy_everything_to_user(struct ebt_table *t, void __user *user,
 	struct ebt_replace tmp;
 	const struct ebt_counter *oldcounters;
 	unsigned int entries_size, nentries;
+	struct ebt_entry *entry;
 	int ret;
 	char *entries;
 
@@ -1445,8 +1461,12 @@ static int copy_everything_to_user(struct ebt_table *t, void __user *user,
 		return -EFAULT;
 	}
 	/* set the match/watcher/target names right */
-	return EBT_ENTRY_ITERATE(entries, entries_size,
-	   ebt_make_names, entries, tmp.entries);
+	ebt_entry_foreach(entry, entries, entries_size) {
+		ret = ebt_make_names(entry, entries, tmp.entries);
+		if (ret != 0)
+			return ret;
+	}
+	return 0;
 }
 
 static int do_ebt_set_ctl(struct sock *sk,
@@ -1755,11 +1775,16 @@ static int compat_table_info(const struct ebt_table_info *info,
 {
 	unsigned int size = info->entries_size;
 	const void *entries = info->entries;
+	struct ebt_entry *entry;
+	int ret;
 
 	newinfo->entries_size = size;
-
-	return EBT_ENTRY_ITERATE(entries, size, compat_calc_entry, info,
-							entries, newinfo);
+	ebt_entry_foreach(entry, entries, size) {
+		ret = compat_calc_entry(entry, info, entries, newinfo);
+		if (ret != 0)
+			return ret;
+	}
+	return 0;
 }
 
 static int compat_copy_everything_to_user(struct ebt_table *t,
@@ -1768,6 +1793,7 @@ static int compat_copy_everything_to_user(struct ebt_table *t,
 	struct compat_ebt_replace repl, tmp;
 	struct ebt_counter *oldcounters;
 	struct ebt_table_info tinfo;
+	struct ebt_entry *entry;
 	int ret;
 	void __user *pos;
 
@@ -1814,8 +1840,12 @@ static int compat_copy_everything_to_user(struct ebt_table *t,
 		return ret;
 
 	pos = compat_ptr(tmp.entries);
-	return EBT_ENTRY_ITERATE(tinfo.entries, tinfo.entries_size,
-			compat_copy_entry_to_user, &pos, &tmp.entries_size);
+	ebt_entry_foreach(entry, tinfo.entries, tinfo.entries_size) {
+		ret = compat_copy_entry_to_user(entry, &pos, &tmp.entries_size);
+		if (ret != 0)
+			return ret;
+	}
+	return 0;
 }
 
 struct ebt_entries_buf_state {
@@ -2141,13 +2171,14 @@ static int compat_copy_entries(unsigned char *data, unsigned int size_user,
 				struct ebt_entries_buf_state *state)
 {
 	unsigned int size_remaining = size_user;
+	struct ebt_entry *entry;
 	int ret;
 
-	ret = EBT_ENTRY_ITERATE(data, size_user, size_entry_mwt, data,
-					&size_remaining, state);
-	if (ret < 0)
-		return ret;
-
+	ebt_entry_foreach(entry, data, size_user) {
+		ret = size_entry_mwt(entry, data, &size_remaining, state);
+		if (ret != 0)
+			return ret;
+	}
 	WARN_ON(size_remaining);
 	return state->buf_kern_offset;
 }
-- 
1.7.1

