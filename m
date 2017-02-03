From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/27] ebtables: use match, target and data copy_to_user helpers
Date: Fri,  3 Feb 2017 13:25:23 +0100
Message-ID: <1486124738-3013-13-git-send-email-pablo@netfilter.org>
References: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Willem de Bruijn <willemb@google.com>

Convert ebtables to copying entries, matches and targets one by one.

The solution is analogous to that of generic xt_(match|target)_to_user
helpers, but is applied to different structs.

Convert existing helpers ebt_make_XXXname helpers that overwrite
fields of an already copy_to_user'd struct with ebt_XXX_to_user
helpers that copy all relevant fields of the struct from scratch.

Signed-off-by: Willem de Bruijn <willemb@google.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/netfilter/ebtables.c | 78 +++++++++++++++++++++++++----------------
 1 file changed, 47 insertions(+), 31 deletions(-)

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 537e3d506fc2..79b69917f521 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -1346,56 +1346,72 @@ static int update_counters(struct net *net, const void __user *user,
 				hlp.num_counters, user, len);
 }
 
-static inline int ebt_make_matchname(const struct ebt_entry_match *m,
-				     const char *base, char __user *ubase)
+static inline int ebt_obj_to_user(char __user *um, const char *_name,
+				  const char *data, int entrysize,
+				  int usersize, int datasize)
 {
-	char __user *hlp = ubase + ((char *)m - base);
-	char name[EBT_FUNCTION_MAXNAMELEN] = {};
+	char name[EBT_FUNCTION_MAXNAMELEN] = {0};
 
 	/* ebtables expects 32 bytes long names but xt_match names are 29 bytes
 	 * long. Copy 29 bytes and fill remaining bytes with zeroes.
 	 */
-	strlcpy(name, m->u.match->name, sizeof(name));
-	if (copy_to_user(hlp, name, EBT_FUNCTION_MAXNAMELEN))
+	strlcpy(name, _name, sizeof(name));
+	if (copy_to_user(um, name, EBT_FUNCTION_MAXNAMELEN) ||
+	    put_user(datasize, (int __user *)(um + EBT_FUNCTION_MAXNAMELEN)) ||
+	    xt_data_to_user(um + entrysize, data, usersize, datasize))
 		return -EFAULT;
+
 	return 0;
 }
 
-static inline int ebt_make_watchername(const struct ebt_entry_watcher *w,
-				       const char *base, char __user *ubase)
+static inline int ebt_match_to_user(const struct ebt_entry_match *m,
+				    const char *base, char __user *ubase)
 {
-	char __user *hlp = ubase + ((char *)w - base);
-	char name[EBT_FUNCTION_MAXNAMELEN] = {};
+	return ebt_obj_to_user(ubase + ((char *)m - base),
+			       m->u.match->name, m->data, sizeof(*m),
+			       m->u.match->usersize, m->match_size);
+}
 
-	strlcpy(name, w->u.watcher->name, sizeof(name));
-	if (copy_to_user(hlp, name, EBT_FUNCTION_MAXNAMELEN))
-		return -EFAULT;
-	return 0;
+static inline int ebt_watcher_to_user(const struct ebt_entry_watcher *w,
+				      const char *base, char __user *ubase)
+{
+	return ebt_obj_to_user(ubase + ((char *)w - base),
+			       w->u.watcher->name, w->data, sizeof(*w),
+			       w->u.watcher->usersize, w->watcher_size);
 }
 
-static inline int ebt_make_names(struct ebt_entry *e, const char *base,
-				 char __user *ubase)
+static inline int ebt_entry_to_user(struct ebt_entry *e, const char *base,
+				    char __user *ubase)
 {
 	int ret;
 	char __user *hlp;
 	const struct ebt_entry_target *t;
-	char name[EBT_FUNCTION_MAXNAMELEN] = {};
 
-	if (e->bitmask == 0)
+	if (e->bitmask == 0) {
+		/* special case !EBT_ENTRY_OR_ENTRIES */
+		if (copy_to_user(ubase + ((char *)e - base), e,
+				 sizeof(struct ebt_entries)))
+			return -EFAULT;
 		return 0;
+	}
+
+	if (copy_to_user(ubase + ((char *)e - base), e, sizeof(*e)))
+		return -EFAULT;
 
 	hlp = ubase + (((char *)e + e->target_offset) - base);
 	t = (struct ebt_entry_target *)(((char *)e) + e->target_offset);
 
-	ret = EBT_MATCH_ITERATE(e, ebt_make_matchname, base, ubase);
+	ret = EBT_MATCH_ITERATE(e, ebt_match_to_user, base, ubase);
 	if (ret != 0)
 		return ret;
-	ret = EBT_WATCHER_ITERATE(e, ebt_make_watchername, base, ubase);
+	ret = EBT_WATCHER_ITERATE(e, ebt_watcher_to_user, base, ubase);
 	if (ret != 0)
 		return ret;
-	strlcpy(name, t->u.target->name, sizeof(name));
-	if (copy_to_user(hlp, name, EBT_FUNCTION_MAXNAMELEN))
-		return -EFAULT;
+	ret = ebt_obj_to_user(hlp, t->u.target->name, t->data, sizeof(*t),
+			      t->u.target->usersize, t->target_size);
+	if (ret != 0)
+		return ret;
+
 	return 0;
 }
 
@@ -1475,13 +1491,9 @@ static int copy_everything_to_user(struct ebt_table *t, void __user *user,
 	if (ret)
 		return ret;
 
-	if (copy_to_user(tmp.entries, entries, entries_size)) {
-		BUGPRINT("Couldn't copy entries to userspace\n");
-		return -EFAULT;
-	}
 	/* set the match/watcher/target names right */
 	return EBT_ENTRY_ITERATE(entries, entries_size,
-	   ebt_make_names, entries, tmp.entries);
+	   ebt_entry_to_user, entries, tmp.entries);
 }
 
 static int do_ebt_set_ctl(struct sock *sk,
@@ -1630,8 +1642,10 @@ static int compat_match_to_user(struct ebt_entry_match *m, void __user **dstptr,
 	if (match->compat_to_user) {
 		if (match->compat_to_user(cm->data, m->data))
 			return -EFAULT;
-	} else if (copy_to_user(cm->data, m->data, msize))
+	} else {
+		if (xt_data_to_user(cm->data, m->data, match->usersize, msize))
 			return -EFAULT;
+	}
 
 	*size -= ebt_compat_entry_padsize() + off;
 	*dstptr = cm->data;
@@ -1657,8 +1671,10 @@ static int compat_target_to_user(struct ebt_entry_target *t,
 	if (target->compat_to_user) {
 		if (target->compat_to_user(cm->data, t->data))
 			return -EFAULT;
-	} else if (copy_to_user(cm->data, t->data, tsize))
-		return -EFAULT;
+	} else {
+		if (xt_data_to_user(cm->data, t->data, target->usersize, tsize))
+			return -EFAULT;
+	}
 
 	*size -= ebt_compat_entry_padsize() + off;
 	*dstptr = cm->data;
-- 
2.1.4

