From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 05/08: xtables: optimize call flow around xt_entry_foreach
Date: Wed, 24 Feb 2010 18:49:34 +0100 (MET)
Message-ID: <20100224174934.16391.99152.sendpatchset@x2.localnet>
References: <20100224174927.16391.59798.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100224174927.16391.59798.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 0559518b5b99c591226460c0bbf8e6a570c518a8
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Wed Feb 24 18:33:43 2010 +0100

    netfilter: xtables: optimize call flow around xt_entry_foreach
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index f733886..5fdedeb 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -512,8 +512,7 @@ static inline int check_target(struct arpt_entry *e, const char *name)
 }
 
 static inline int
-find_check_entry(struct arpt_entry *e, const char *name, unsigned int size,
-		 unsigned int *i)
+find_check_entry(struct arpt_entry *e, const char *name, unsigned int size)
 {
 	struct arpt_entry_target *t;
 	struct xt_target *target;
@@ -538,8 +537,6 @@ find_check_entry(struct arpt_entry *e, const char *name, unsigned int size,
 	ret = check_target(e, name);
 	if (ret)
 		goto err;
-
-	(*i)++;
 	return 0;
 err:
 	module_put(t->u.kernel.target->me);
@@ -568,8 +565,7 @@ static inline int check_entry_size_and_hooks(struct arpt_entry *e,
 					     const unsigned char *limit,
 					     const unsigned int *hook_entries,
 					     const unsigned int *underflows,
-					     unsigned int valid_hooks,
-					     unsigned int *i)
+					     unsigned int valid_hooks)
 {
 	unsigned int h;
 
@@ -606,19 +602,14 @@ static inline int check_entry_size_and_hooks(struct arpt_entry *e,
 	/* Clear counters and comefrom */
 	e->counters = ((struct xt_counters) { 0, 0 });
 	e->comefrom = 0;
-
-	(*i)++;
 	return 0;
 }
 
-static inline int cleanup_entry(struct arpt_entry *e, unsigned int *i)
+static inline void cleanup_entry(struct arpt_entry *e)
 {
 	struct xt_tgdtor_param par;
 	struct arpt_entry_target *t;
 
-	if (i && (*i)-- == 0)
-		return 1;
-
 	t = arpt_get_target(e);
 	par.target   = t->u.kernel.target;
 	par.targinfo = t->data;
@@ -626,7 +617,6 @@ static inline int cleanup_entry(struct arpt_entry *e, unsigned int *i)
 	if (par.target->destroy != NULL)
 		par.target->destroy(&par);
 	module_put(par.target->me);
-	return 0;
 }
 
 /* Checks and translates the user-supplied table segment (held in
@@ -660,10 +650,10 @@ static int translate_table(const char *name,
 	/* Walk through entries, checking offsets. */
 	xt_entry_foreach(iter, entry0, newinfo->size) {
 		ret = check_entry_size_and_hooks(iter, newinfo, entry0,
-		      entry0 + size, hook_entries, underflows,
-		      valid_hooks, &i);
+		      entry0 + size, hook_entries, underflows, valid_hooks);
 		if (ret != 0)
 			break;
+		++i;
 	}
 	duprintf("translate_table: ARPT_ENTRY_ITERATE gives %d\n", ret);
 	if (ret != 0)
@@ -700,15 +690,18 @@ static int translate_table(const char *name,
 	/* Finally, each sanity check must pass */
 	i = 0;
 	xt_entry_foreach(iter, entry0, newinfo->size) {
-		ret = find_check_entry(iter, name, size, &i);
+		ret = find_check_entry(iter, name, size);
 		if (ret != 0)
 			break;
+		++i;
 	}
 
 	if (ret != 0) {
-		xt_entry_foreach(iter, entry0, newinfo->size)
-			if (cleanup_entry(iter, &i) != 0)
+		xt_entry_foreach(iter, entry0, newinfo->size) {
+			if (i-- == 0)
 				break;
+			cleanup_entry(iter);
+		}
 		return ret;
 	}
 
@@ -721,27 +714,6 @@ static int translate_table(const char *name,
 	return ret;
 }
 
-/* Gets counters. */
-static inline int add_entry_to_counter(const struct arpt_entry *e,
-				       struct xt_counters total[],
-				       unsigned int *i)
-{
-	ADD_COUNTER(total[*i], e->counters.bcnt, e->counters.pcnt);
-
-	(*i)++;
-	return 0;
-}
-
-static inline int set_entry_to_counter(const struct arpt_entry *e,
-				       struct xt_counters total[],
-				       unsigned int *i)
-{
-	SET_COUNTER(total[*i], e->counters.bcnt, e->counters.pcnt);
-
-	(*i)++;
-	return 0;
-}
-
 static void get_counters(const struct xt_table_info *t,
 			 struct xt_counters counters[])
 {
@@ -761,18 +733,22 @@ static void get_counters(const struct xt_table_info *t,
 	curcpu = smp_processor_id();
 
 	i = 0;
-	xt_entry_foreach(iter, t->entries[curcpu], t->size)
-		if (set_entry_to_counter(iter, counters, &i) != 0)
-			break;
+	xt_entry_foreach(iter, t->entries[curcpu], t->size) {
+		SET_COUNTER(counters[i], iter->counters.bcnt,
+			iter->counters.pcnt);
+		++i;
+	}
 
 	for_each_possible_cpu(cpu) {
 		if (cpu == curcpu)
 			continue;
 		i = 0;
 		xt_info_wrlock(cpu);
-		xt_entry_foreach(iter, t->entries[cpu], t->size)
-			if (add_entry_to_counter(iter, counters, &i) != 0)
-				break;
+		xt_entry_foreach(iter, t->entries[cpu], t->size) {
+			ADD_COUNTER(counters[i], iter->counters.bcnt,
+				iter->counters.pcnt);
+			++i;
+		}
 		xt_info_wrunlock(cpu);
 	}
 	local_bh_enable();
@@ -904,7 +880,7 @@ static int compat_table_info(const struct xt_table_info *info,
 {
 	struct arpt_entry *iter;
 	void *loc_cpu_entry;
-	int ret = 0;
+	int ret;
 
 	if (!newinfo || !info)
 		return -EINVAL;
@@ -916,9 +892,9 @@ static int compat_table_info(const struct xt_table_info *info,
 	xt_entry_foreach(iter, loc_cpu_entry, info->size) {
 		ret = compat_calc_entry(iter, info, loc_cpu_entry, newinfo);
 		if (ret != 0)
-			break;
+			return ret;
 	}
-	return ret;
+	return 0;
 }
 #endif
 
@@ -1078,8 +1054,7 @@ static int __do_replace(struct net *net, const char *name,
 	/* Decrease module usage counts and free resource */
 	loc_cpu_old_entry = oldinfo->entries[raw_smp_processor_id()];
 	xt_entry_foreach(iter, loc_cpu_old_entry, oldinfo->size)
-		if (cleanup_entry(iter, NULL) != 0)
-			break;
+		cleanup_entry(iter);
 
 	xt_free_table_info(oldinfo);
 	if (copy_to_user(counters_ptr, counters,
@@ -1142,26 +1117,12 @@ static int do_replace(struct net *net, const void __user *user,
 
  free_newinfo_untrans:
 	xt_entry_foreach(iter, loc_cpu_entry, newinfo->size)
-		if (cleanup_entry(iter, NULL) != 0)
-			break;
+		cleanup_entry(iter);
  free_newinfo:
 	xt_free_table_info(newinfo);
 	return ret;
 }
 
-/* We're lazy, and add to the first CPU; overflow works its fey magic
- * and everything is OK. */
-static int
-add_counter_to_entry(struct arpt_entry *e,
-		     const struct xt_counters addme[],
-		     unsigned int *i)
-{
-	ADD_COUNTER(e->counters, addme[*i].bcnt, addme[*i].pcnt);
-
-	(*i)++;
-	return 0;
-}
-
 static int do_add_counters(struct net *net, const void __user *user,
 			   unsigned int len, int compat)
 {
@@ -1234,9 +1195,10 @@ static int do_add_counters(struct net *net, const void __user *user,
 	curcpu = smp_processor_id();
 	loc_cpu_entry = private->entries[curcpu];
 	xt_info_wrlock(curcpu);
-	xt_entry_foreach(iter, loc_cpu_entry, private->size)
-		if (add_counter_to_entry(iter, paddc, &i) != 0)
-			break;
+	xt_entry_foreach(iter, loc_cpu_entry, private->size) {
+		ADD_COUNTER(iter->counters, paddc[i].bcnt, paddc[i].pcnt);
+		++i;
+	}
 	xt_info_wrunlock(curcpu);
  unlock_up_free:
 	local_bh_enable();
@@ -1249,17 +1211,12 @@ static int do_add_counters(struct net *net, const void __user *user,
 }
 
 #ifdef CONFIG_COMPAT
-static inline int
-compat_release_entry(struct compat_arpt_entry *e, unsigned int *i)
+static inline void compat_release_entry(struct compat_arpt_entry *e)
 {
 	struct arpt_entry_target *t;
 
-	if (i && (*i)-- == 0)
-		return 1;
-
 	t = compat_arpt_get_target(e);
 	module_put(t->u.kernel.target->me);
-	return 0;
 }
 
 static inline int
@@ -1270,7 +1227,6 @@ check_compat_entry_size_and_hooks(struct compat_arpt_entry *e,
 				  const unsigned char *limit,
 				  const unsigned int *hook_entries,
 				  const unsigned int *underflows,
-				  unsigned int *i,
 				  const char *name)
 {
 	struct arpt_entry_target *t;
@@ -1330,8 +1286,6 @@ check_compat_entry_size_and_hooks(struct compat_arpt_entry *e,
 	/* Clear counters and comefrom */
 	memset(&e->counters, 0, sizeof(e->counters));
 	e->comefrom = 0;
-
-	(*i)++;
 	return 0;
 
 release_target:
@@ -1375,19 +1329,6 @@ compat_copy_entry_from_user(struct compat_arpt_entry *e, void **dstptr,
 	return ret;
 }
 
-static inline int compat_check_entry(struct arpt_entry *e, const char *name,
-				     unsigned int *i)
-{
-	int ret;
-
-	ret = check_target(e, name);
-	if (ret)
-		return ret;
-
-	(*i)++;
-	return 0;
-}
-
 static int translate_compat_table(const char *name,
 				  unsigned int valid_hooks,
 				  struct xt_table_info **pinfo,
@@ -1423,12 +1364,11 @@ static int translate_compat_table(const char *name,
 	xt_entry_foreach(iter0, entry0, total_size) {
 		ret = check_compat_entry_size_and_hooks(iter0, info, &size,
 		      entry0, entry0 + total_size, hook_entries, underflows,
-		      &j, name);
+		      name);
 		if (ret != 0)
-			break;
+			goto out_unlock;
+		++j;
 	}
-	if (ret != 0)
-		goto out_unlock;
 
 	ret = -EINVAL;
 	if (j != number) {
@@ -1484,9 +1424,10 @@ static int translate_compat_table(const char *name,
 
 	i = 0;
 	xt_entry_foreach(iter1, entry1, newinfo->size) {
-		ret = compat_check_entry(iter1, name, &i);
+		ret = check_target(iter1, name);
 		if (ret != 0)
 			break;
+		++i;
 	}
 	if (ret) {
 		/*
@@ -1499,12 +1440,15 @@ static int translate_compat_table(const char *name,
 		xt_entry_foreach(iter0, entry0, newinfo->size) {
 			if (skip-- > 0)
 				continue;
-			if (compat_release_entry(iter0, &j) != 0)
+			if (j-- == 0)
 				break;
+			compat_release_entry(iter0);
 		}
-		xt_entry_foreach(iter1, entry1, newinfo->size)
-			if (cleanup_entry(iter1, &i) != 0)
+		xt_entry_foreach(iter1, entry1, newinfo->size) {
+			if (i-- == 0)
 				break;
+			cleanup_entry(iter1);
+		}
 		xt_free_table_info(newinfo);
 		return ret;
 	}
@@ -1522,9 +1466,11 @@ static int translate_compat_table(const char *name,
 free_newinfo:
 	xt_free_table_info(newinfo);
 out:
-	xt_entry_foreach(iter0, entry0, total_size)
-		if (compat_release_entry(iter0, &j) != 0)
+	xt_entry_foreach(iter0, entry0, total_size) {
+		if (j-- == 0)
 			break;
+		compat_release_entry(iter0);
+	}
 	return ret;
 out_unlock:
 	xt_compat_flush_offsets(NFPROTO_ARP);
@@ -1590,8 +1536,7 @@ static int compat_do_replace(struct net *net, void __user *user,
 
  free_newinfo_untrans:
 	xt_entry_foreach(iter, loc_cpu_entry, newinfo->size)
-		if (cleanup_entry(iter, NULL) != 0)
-			break;
+		cleanup_entry(iter);
  free_newinfo:
 	xt_free_table_info(newinfo);
 	return ret;
@@ -1625,7 +1570,7 @@ static int compat_do_arpt_set_ctl(struct sock *sk, int cmd, void __user *user,
 static int compat_copy_entry_to_user(struct arpt_entry *e, void __user **dstptr,
 				     compat_uint_t *size,
 				     struct xt_counters *counters,
-				     unsigned int *i)
+				     unsigned int i)
 {
 	struct arpt_entry_target *t;
 	struct compat_arpt_entry __user *ce;
@@ -1633,14 +1578,12 @@ static int compat_copy_entry_to_user(struct arpt_entry *e, void __user **dstptr,
 	compat_uint_t origsize;
 	int ret;
 
-	ret = -EFAULT;
 	origsize = *size;
 	ce = (struct compat_arpt_entry __user *)*dstptr;
-	if (copy_to_user(ce, e, sizeof(struct arpt_entry)))
-		goto out;
-
-	if (copy_to_user(&ce->counters, &counters[*i], sizeof(counters[*i])))
-		goto out;
+	if (copy_to_user(ce, e, sizeof(struct arpt_entry)) != 0 ||
+	    copy_to_user(&ce->counters, &counters[i],
+	    sizeof(counters[i])) != 0)
+		return -EFAULT;
 
 	*dstptr += sizeof(struct compat_arpt_entry);
 	*size -= sizeof(struct arpt_entry) - sizeof(struct compat_arpt_entry);
@@ -1650,18 +1593,12 @@ static int compat_copy_entry_to_user(struct arpt_entry *e, void __user **dstptr,
 	t = arpt_get_target(e);
 	ret = xt_compat_target_to_user(t, dstptr, size);
 	if (ret)
-		goto out;
-	ret = -EFAULT;
+		return ret;
 	next_offset = e->next_offset - (origsize - *size);
-	if (put_user(target_offset, &ce->target_offset))
-		goto out;
-	if (put_user(next_offset, &ce->next_offset))
-		goto out;
-
-	(*i)++;
+	if (put_user(target_offset, &ce->target_offset) != 0 ||
+	    put_user(next_offset, &ce->next_offset) != 0)
+		return -EFAULT;
 	return 0;
-out:
-	return ret;
 }
 
 static int compat_copy_entries_to_user(unsigned int total_size,
@@ -1687,7 +1624,7 @@ static int compat_copy_entries_to_user(unsigned int total_size,
 	size = total_size;
 	xt_entry_foreach(iter, loc_cpu_entry, total_size) {
 		ret = compat_copy_entry_to_user(iter, &pos,
-		      &size, counters, &i);
+		      &size, counters, i++);
 		if (ret != 0)
 			break;
 	}
@@ -1893,8 +1830,7 @@ void arpt_unregister_table(struct xt_table *table)
 	/* Decrease module usage counts and free resources */
 	loc_cpu_entry = private->entries[raw_smp_processor_id()];
 	xt_entry_foreach(iter, loc_cpu_entry, private->size)
-		if (cleanup_entry(iter, NULL) != 0)
-			break;
+		cleanup_entry(iter);
 	if (private->number > private->initial_entries)
 		module_put(table_owner);
 	xt_free_table_info(private);
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index b43280a..9c8aa39 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -679,7 +679,7 @@ static int check_target(struct ipt_entry *e, struct net *net, const char *name)
 
 static int
 find_check_entry(struct ipt_entry *e, struct net *net, const char *name,
-		 unsigned int size, unsigned int *i)
+		 unsigned int size)
 {
 	struct ipt_entry_target *t;
 	struct xt_target *target;
@@ -716,8 +716,6 @@ find_check_entry(struct ipt_entry *e, struct net *net, const char *name,
 	ret = check_target(e, net, name);
 	if (ret)
 		goto err;
-
-	(*i)++;
 	return 0;
  err:
 	module_put(t->u.kernel.target->me);
@@ -748,8 +746,7 @@ check_entry_size_and_hooks(struct ipt_entry *e,
 			   const unsigned char *limit,
 			   const unsigned int *hook_entries,
 			   const unsigned int *underflows,
-			   unsigned int valid_hooks,
-			   unsigned int *i)
+			   unsigned int valid_hooks)
 {
 	unsigned int h;
 
@@ -786,20 +783,15 @@ check_entry_size_and_hooks(struct ipt_entry *e,
 	/* Clear counters and comefrom */
 	e->counters = ((struct xt_counters) { 0, 0 });
 	e->comefrom = 0;
-
-	(*i)++;
 	return 0;
 }
 
-static int
-cleanup_entry(struct ipt_entry *e, struct net *net, unsigned int *i)
+static void
+cleanup_entry(struct ipt_entry *e, struct net *net)
 {
 	struct xt_tgdtor_param par;
 	struct ipt_entry_target *t;
 
-	if (i && (*i)-- == 0)
-		return 1;
-
 	/* Cleanup all matches */
 	IPT_MATCH_ITERATE(e, cleanup_match, net, NULL);
 	t = ipt_get_target(e);
@@ -811,7 +803,6 @@ cleanup_entry(struct ipt_entry *e, struct net *net, unsigned int *i)
 	if (par.target->destroy != NULL)
 		par.target->destroy(&par);
 	module_put(par.target->me);
-	return 0;
 }
 
 /* Checks and translates the user-supplied table segment (held in
@@ -845,13 +836,11 @@ translate_table(struct net *net,
 	/* Walk through entries, checking offsets. */
 	xt_entry_foreach(iter, entry0, newinfo->size) {
 		ret = check_entry_size_and_hooks(iter, newinfo, entry0,
-		      entry0 + size, hook_entries, underflows,
-		      valid_hooks, &i);
+		      entry0 + size, hook_entries, underflows, valid_hooks);
 		if (ret != 0)
-			break;
+			return ret;
+		++i;
 	}
-	if (ret != 0)
-		return ret;
 
 	if (i != number) {
 		duprintf("translate_table: %u not %u entries\n",
@@ -882,15 +871,18 @@ translate_table(struct net *net,
 	/* Finally, each sanity check must pass */
 	i = 0;
 	xt_entry_foreach(iter, entry0, newinfo->size) {
-		ret = find_check_entry(iter, net, name, size, &i);
+		ret = find_check_entry(iter, net, name, size);
 		if (ret != 0)
 			break;
+		++i;
 	}
 
 	if (ret != 0) {
-		xt_entry_foreach(iter, entry0, newinfo->size)
-			if (cleanup_entry(iter, net, &i) != 0)
+		xt_entry_foreach(iter, entry0, newinfo->size) {
+			if (i-- == 0)
 				break;
+			cleanup_entry(iter, net);
+		}
 		return ret;
 	}
 
@@ -903,29 +895,6 @@ translate_table(struct net *net,
 	return ret;
 }
 
-/* Gets counters. */
-static inline int
-add_entry_to_counter(const struct ipt_entry *e,
-		     struct xt_counters total[],
-		     unsigned int *i)
-{
-	ADD_COUNTER(total[*i], e->counters.bcnt, e->counters.pcnt);
-
-	(*i)++;
-	return 0;
-}
-
-static inline int
-set_entry_to_counter(const struct ipt_entry *e,
-		     struct ipt_counters total[],
-		     unsigned int *i)
-{
-	SET_COUNTER(total[*i], e->counters.bcnt, e->counters.pcnt);
-
-	(*i)++;
-	return 0;
-}
-
 static void
 get_counters(const struct xt_table_info *t,
 	     struct xt_counters counters[])
@@ -946,18 +915,22 @@ get_counters(const struct xt_table_info *t,
 	curcpu = smp_processor_id();
 
 	i = 0;
-	xt_entry_foreach(iter, t->entries[curcpu], t->size)
-		if (set_entry_to_counter(iter, counters, &i) != 0)
-			break;
+	xt_entry_foreach(iter, t->entries[curcpu], t->size) {
+		SET_COUNTER(counters[i], iter->counters.bcnt,
+			iter->counters.pcnt);
+		++i;
+	}
 
 	for_each_possible_cpu(cpu) {
 		if (cpu == curcpu)
 			continue;
 		i = 0;
 		xt_info_wrlock(cpu);
-		xt_entry_foreach(iter, t->entries[cpu], t->size)
-			if (add_entry_to_counter(iter, counters, &i) != 0)
-				break;
+		xt_entry_foreach(iter, t->entries[cpu], t->size) {
+			ADD_COUNTER(counters[i], iter->counters.bcnt,
+				iter->counters.pcnt);
+			++i; /* macro does multi eval of i */
+		}
 		xt_info_wrunlock(cpu);
 	}
 	local_bh_enable();
@@ -1117,7 +1090,7 @@ static int compat_table_info(const struct xt_table_info *info,
 {
 	struct ipt_entry *iter;
 	void *loc_cpu_entry;
-	int ret = 0;
+	int ret;
 
 	if (!newinfo || !info)
 		return -EINVAL;
@@ -1129,9 +1102,9 @@ static int compat_table_info(const struct xt_table_info *info,
 	xt_entry_foreach(iter, loc_cpu_entry, info->size) {
 		ret = compat_calc_entry(iter, info, loc_cpu_entry, newinfo);
 		if (ret != 0)
-			break;
+			return ret;
 	}
-	return ret;
+	return 0;
 }
 #endif
 
@@ -1289,8 +1262,7 @@ __do_replace(struct net *net, const char *name, unsigned int valid_hooks,
 	/* Decrease module usage counts and free resource */
 	loc_cpu_old_entry = oldinfo->entries[raw_smp_processor_id()];
 	xt_entry_foreach(iter, loc_cpu_old_entry, oldinfo->size)
-		if (cleanup_entry(iter, net, NULL) != 0)
-			break;
+		cleanup_entry(iter, net);
 
 	xt_free_table_info(oldinfo);
 	if (copy_to_user(counters_ptr, counters,
@@ -1353,26 +1325,12 @@ do_replace(struct net *net, const void __user *user, unsigned int len)
 
  free_newinfo_untrans:
 	xt_entry_foreach(iter, loc_cpu_entry, newinfo->size)
-		if (cleanup_entry(iter, net, NULL) != 0)
-			break;
+		cleanup_entry(iter, net);
  free_newinfo:
 	xt_free_table_info(newinfo);
 	return ret;
 }
 
-/* We're lazy, and add to the first CPU; overflow works its fey magic
- * and everything is OK. */
-static int
-add_counter_to_entry(struct ipt_entry *e,
-		     const struct xt_counters addme[],
-		     unsigned int *i)
-{
-	ADD_COUNTER(e->counters, addme[*i].bcnt, addme[*i].pcnt);
-
-	(*i)++;
-	return 0;
-}
-
 static int
 do_add_counters(struct net *net, const void __user *user,
                 unsigned int len, int compat)
@@ -1446,9 +1404,10 @@ do_add_counters(struct net *net, const void __user *user,
 	curcpu = smp_processor_id();
 	loc_cpu_entry = private->entries[curcpu];
 	xt_info_wrlock(curcpu);
-	xt_entry_foreach(iter, loc_cpu_entry, private->size)
-		if (add_counter_to_entry(iter, paddc, &i) != 0)
-			break;
+	xt_entry_foreach(iter, loc_cpu_entry, private->size) {
+		ADD_COUNTER(iter->counters, paddc[i].bcnt, paddc[i].pcnt);
+		++i;
+	}
 	xt_info_wrunlock(curcpu);
  unlock_up_free:
 	local_bh_enable();
@@ -1476,7 +1435,7 @@ struct compat_ipt_replace {
 static int
 compat_copy_entry_to_user(struct ipt_entry *e, void __user **dstptr,
 			  unsigned int *size, struct xt_counters *counters,
-			  unsigned int *i)
+			  unsigned int i)
 {
 	struct ipt_entry_target *t;
 	struct compat_ipt_entry __user *ce;
@@ -1484,14 +1443,12 @@ compat_copy_entry_to_user(struct ipt_entry *e, void __user **dstptr,
 	compat_uint_t origsize;
 	int ret;
 
-	ret = -EFAULT;
 	origsize = *size;
 	ce = (struct compat_ipt_entry __user *)*dstptr;
-	if (copy_to_user(ce, e, sizeof(struct ipt_entry)))
-		goto out;
-
-	if (copy_to_user(&ce->counters, &counters[*i], sizeof(counters[*i])))
-		goto out;
+	if (copy_to_user(ce, e, sizeof(struct ipt_entry)) != 0 ||
+	    copy_to_user(&ce->counters, &counters[i],
+	    sizeof(counters[i])) != 0)
+		return -EFAULT;
 
 	*dstptr += sizeof(struct compat_ipt_entry);
 	*size -= sizeof(struct ipt_entry) - sizeof(struct compat_ipt_entry);
@@ -1499,22 +1456,16 @@ compat_copy_entry_to_user(struct ipt_entry *e, void __user **dstptr,
 	ret = IPT_MATCH_ITERATE(e, xt_compat_match_to_user, dstptr, size);
 	target_offset = e->target_offset - (origsize - *size);
 	if (ret)
-		goto out;
+		return ret;
 	t = ipt_get_target(e);
 	ret = xt_compat_target_to_user(t, dstptr, size);
 	if (ret)
-		goto out;
-	ret = -EFAULT;
+		return ret;
 	next_offset = e->next_offset - (origsize - *size);
-	if (put_user(target_offset, &ce->target_offset))
-		goto out;
-	if (put_user(next_offset, &ce->next_offset))
-		goto out;
-
-	(*i)++;
+	if (put_user(target_offset, &ce->target_offset) != 0 ||
+	    put_user(next_offset, &ce->next_offset) != 0)
+		return -EFAULT;
 	return 0;
-out:
-	return ret;
 }
 
 static int
@@ -1551,19 +1502,14 @@ compat_release_match(struct ipt_entry_match *m, unsigned int *i)
 	return 0;
 }
 
-static int
-compat_release_entry(struct compat_ipt_entry *e, unsigned int *i)
+static void compat_release_entry(struct compat_ipt_entry *e)
 {
 	struct ipt_entry_target *t;
 
-	if (i && (*i)-- == 0)
-		return 1;
-
 	/* Cleanup all matches */
 	COMPAT_IPT_MATCH_ITERATE(e, compat_release_match, NULL);
 	t = compat_ipt_get_target(e);
 	module_put(t->u.kernel.target->me);
-	return 0;
 }
 
 static int
@@ -1574,7 +1520,6 @@ check_compat_entry_size_and_hooks(struct compat_ipt_entry *e,
 				  const unsigned char *limit,
 				  const unsigned int *hook_entries,
 				  const unsigned int *underflows,
-				  unsigned int *i,
 				  const char *name)
 {
 	struct ipt_entry_target *t;
@@ -1640,8 +1585,6 @@ check_compat_entry_size_and_hooks(struct compat_ipt_entry *e,
 	/* Clear counters and comefrom */
 	memset(&e->counters, 0, sizeof(e->counters));
 	e->comefrom = 0;
-
-	(*i)++;
 	return 0;
 
 out:
@@ -1691,8 +1634,7 @@ compat_copy_entry_from_user(struct compat_ipt_entry *e, void **dstptr,
 }
 
 static int
-compat_check_entry(struct ipt_entry *e, struct net *net, const char *name,
-				     unsigned int *i)
+compat_check_entry(struct ipt_entry *e, struct net *net, const char *name)
 {
 	struct xt_mtchk_param mtpar;
 	unsigned int j;
@@ -1711,8 +1653,6 @@ compat_check_entry(struct ipt_entry *e, struct net *net, const char *name,
 	ret = check_target(e, net, name);
 	if (ret)
 		goto cleanup_matches;
-
-	(*i)++;
 	return 0;
 
  cleanup_matches:
@@ -1737,7 +1677,7 @@ translate_compat_table(struct net *net,
 	struct compat_ipt_entry *iter0;
 	struct ipt_entry *iter1;
 	unsigned int size;
-	int ret = 0;
+	int ret;
 
 	info = *pinfo;
 	entry0 = *pentry0;
@@ -1757,12 +1697,11 @@ translate_compat_table(struct net *net,
 	xt_entry_foreach(iter0, entry0, total_size) {
 		ret = check_compat_entry_size_and_hooks(iter0, info, &size,
 		      entry0, entry0 + total_size, hook_entries, underflows,
-		      &j, name);
+		      name);
 		if (ret != 0)
-			break;
+			goto out_unlock;
+		++j;
 	}
-	if (ret != 0)
-		goto out_unlock;
 
 	ret = -EINVAL;
 	if (j != number) {
@@ -1818,9 +1757,10 @@ translate_compat_table(struct net *net,
 
 	i = 0;
 	xt_entry_foreach(iter1, entry1, newinfo->size) {
-		ret = compat_check_entry(iter1, net, name, &i);
+		ret = compat_check_entry(iter1, net, name);
 		if (ret != 0)
 			break;
+		++i;
 	}
 	if (ret) {
 		/*
@@ -1833,12 +1773,15 @@ translate_compat_table(struct net *net,
 		xt_entry_foreach(iter0, entry0, newinfo->size) {
 			if (skip-- > 0)
 				continue;
-			if (compat_release_entry(iter0, &i) != 0)
+			if (j-- == 0)
 				break;
+			compat_release_entry(iter0);
 		}
-		xt_entry_foreach(iter1, entry1, newinfo->size)
-			if (cleanup_entry(iter1, net, &i) != 0)
+		xt_entry_foreach(iter1, entry1, newinfo->size) {
+			if (i-- == 0)
 				break;
+			cleanup_entry(iter1, net);
+		}
 		xt_free_table_info(newinfo);
 		return ret;
 	}
@@ -1856,9 +1799,11 @@ translate_compat_table(struct net *net,
 free_newinfo:
 	xt_free_table_info(newinfo);
 out:
-	xt_entry_foreach(iter0, entry0, total_size)
-		if (compat_release_entry(iter0, &j) != 0)
+	xt_entry_foreach(iter0, entry0, total_size) {
+		if (j-- == 0)
 			break;
+		compat_release_entry(iter0);
+	}
 	return ret;
 out_unlock:
 	xt_compat_flush_offsets(AF_INET);
@@ -1913,8 +1858,7 @@ compat_do_replace(struct net *net, void __user *user, unsigned int len)
 
  free_newinfo_untrans:
 	xt_entry_foreach(iter, loc_cpu_entry, newinfo->size)
-		if (cleanup_entry(iter, net, NULL) != 0)
-			break;
+		cleanup_entry(iter, net);
  free_newinfo:
 	xt_free_table_info(newinfo);
 	return ret;
@@ -1978,7 +1922,7 @@ compat_copy_entries_to_user(unsigned int total_size, struct xt_table *table,
 	size = total_size;
 	xt_entry_foreach(iter, loc_cpu_entry, total_size) {
 		ret = compat_copy_entry_to_user(iter, &pos,
-		      &size, counters, &i);
+		      &size, counters, i++);
 		if (ret != 0)
 			break;
 	}
@@ -2189,8 +2133,7 @@ void ipt_unregister_table(struct net *net, struct xt_table *table)
 	/* Decrease module usage counts and free resources */
 	loc_cpu_entry = private->entries[raw_smp_processor_id()];
 	xt_entry_foreach(iter, loc_cpu_entry, private->size)
-		if (cleanup_entry(iter, net, NULL) != 0)
-			break;
+		cleanup_entry(iter, net);
 	if (private->number > private->initial_entries)
 		module_put(table_owner);
 	xt_free_table_info(private);
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 23926e3..b7e27c1 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -710,7 +710,7 @@ static int check_target(struct ip6t_entry *e, struct net *net, const char *name)
 
 static int
 find_check_entry(struct ip6t_entry *e, struct net *net, const char *name,
-		 unsigned int size, unsigned int *i)
+		 unsigned int size)
 {
 	struct ip6t_entry_target *t;
 	struct xt_target *target;
@@ -747,8 +747,6 @@ find_check_entry(struct ip6t_entry *e, struct net *net, const char *name,
 	ret = check_target(e, net, name);
 	if (ret)
 		goto err;
-
-	(*i)++;
 	return 0;
  err:
 	module_put(t->u.kernel.target->me);
@@ -779,8 +777,7 @@ check_entry_size_and_hooks(struct ip6t_entry *e,
 			   const unsigned char *limit,
 			   const unsigned int *hook_entries,
 			   const unsigned int *underflows,
-			   unsigned int valid_hooks,
-			   unsigned int *i)
+			   unsigned int valid_hooks)
 {
 	unsigned int h;
 
@@ -817,20 +814,14 @@ check_entry_size_and_hooks(struct ip6t_entry *e,
 	/* Clear counters and comefrom */
 	e->counters = ((struct xt_counters) { 0, 0 });
 	e->comefrom = 0;
-
-	(*i)++;
 	return 0;
 }
 
-static int
-cleanup_entry(struct ip6t_entry *e, struct net *net, unsigned int *i)
+static void cleanup_entry(struct ip6t_entry *e, struct net *net)
 {
 	struct xt_tgdtor_param par;
 	struct ip6t_entry_target *t;
 
-	if (i && (*i)-- == 0)
-		return 1;
-
 	/* Cleanup all matches */
 	IP6T_MATCH_ITERATE(e, cleanup_match, net, NULL);
 	t = ip6t_get_target(e);
@@ -842,7 +833,6 @@ cleanup_entry(struct ip6t_entry *e, struct net *net, unsigned int *i)
 	if (par.target->destroy != NULL)
 		par.target->destroy(&par);
 	module_put(par.target->me);
-	return 0;
 }
 
 /* Checks and translates the user-supplied table segment (held in
@@ -876,13 +866,11 @@ translate_table(struct net *net,
 	/* Walk through entries, checking offsets. */
 	xt_entry_foreach(iter, entry0, newinfo->size) {
 		ret = check_entry_size_and_hooks(iter, newinfo, entry0,
-		      entry0 + size, hook_entries, underflows,
-		      valid_hooks, &i);
+		      entry0 + size, hook_entries, underflows, valid_hooks);
 		if (ret != 0)
-			break;
+			return ret;
+		++i;
 	}
-	if (ret != 0)
-		return ret;
 
 	if (i != number) {
 		duprintf("translate_table: %u not %u entries\n",
@@ -913,15 +901,18 @@ translate_table(struct net *net,
 	/* Finally, each sanity check must pass */
 	i = 0;
 	xt_entry_foreach(iter, entry0, newinfo->size) {
-		ret = find_check_entry(iter, net, name, size, &i);
+		ret = find_check_entry(iter, net, name, size);
 		if (ret != 0)
 			break;
+		++i;
 	}
 
 	if (ret != 0) {
-		xt_entry_foreach(iter, entry0, newinfo->size)
-			if (cleanup_entry(iter, net, &i) != 0)
+		xt_entry_foreach(iter, entry0, newinfo->size) {
+			if (i-- == 0)
 				break;
+			cleanup_entry(iter, net);
+		}
 		return ret;
 	}
 
@@ -934,29 +925,6 @@ translate_table(struct net *net,
 	return ret;
 }
 
-/* Gets counters. */
-static inline int
-add_entry_to_counter(const struct ip6t_entry *e,
-		     struct xt_counters total[],
-		     unsigned int *i)
-{
-	ADD_COUNTER(total[*i], e->counters.bcnt, e->counters.pcnt);
-
-	(*i)++;
-	return 0;
-}
-
-static inline int
-set_entry_to_counter(const struct ip6t_entry *e,
-		     struct ip6t_counters total[],
-		     unsigned int *i)
-{
-	SET_COUNTER(total[*i], e->counters.bcnt, e->counters.pcnt);
-
-	(*i)++;
-	return 0;
-}
-
 static void
 get_counters(const struct xt_table_info *t,
 	     struct xt_counters counters[])
@@ -977,18 +945,22 @@ get_counters(const struct xt_table_info *t,
 	curcpu = smp_processor_id();
 
 	i = 0;
-	xt_entry_foreach(iter, t->entries[curcpu], t->size)
-		if (set_entry_to_counter(iter, counters, &i) != 0)
-			break;
+	xt_entry_foreach(iter, t->entries[curcpu], t->size) {
+		SET_COUNTER(counters[i], iter->counters.bcnt,
+			iter->counters.pcnt);
+		++i;
+	}
 
 	for_each_possible_cpu(cpu) {
 		if (cpu == curcpu)
 			continue;
 		i = 0;
 		xt_info_wrlock(cpu);
-		xt_entry_foreach(iter, t->entries[cpu], t->size)
-			if (add_entry_to_counter(iter, counters, &i) != 0)
-				break;
+		xt_entry_foreach(iter, t->entries[cpu], t->size) {
+			ADD_COUNTER(counters[i], iter->counters.bcnt,
+				iter->counters.pcnt);
+			++i;
+		}
 		xt_info_wrunlock(cpu);
 	}
 	local_bh_enable();
@@ -1148,7 +1120,7 @@ static int compat_table_info(const struct xt_table_info *info,
 {
 	struct ip6t_entry *iter;
 	void *loc_cpu_entry;
-	int ret = 0;
+	int ret;
 
 	if (!newinfo || !info)
 		return -EINVAL;
@@ -1160,9 +1132,9 @@ static int compat_table_info(const struct xt_table_info *info,
 	xt_entry_foreach(iter, loc_cpu_entry, info->size) {
 		ret = compat_calc_entry(iter, info, loc_cpu_entry, newinfo);
 		if (ret != 0)
-			break;
+			return ret;
 	}
-	return ret;
+	return 0;
 }
 #endif
 
@@ -1321,8 +1293,7 @@ __do_replace(struct net *net, const char *name, unsigned int valid_hooks,
 	/* Decrease module usage counts and free resource */
 	loc_cpu_old_entry = oldinfo->entries[raw_smp_processor_id()];
 	xt_entry_foreach(iter, loc_cpu_old_entry, oldinfo->size)
-		if (cleanup_entry(iter, net, NULL) != 0)
-			break;
+		cleanup_entry(iter, net);
 
 	xt_free_table_info(oldinfo);
 	if (copy_to_user(counters_ptr, counters,
@@ -1385,26 +1356,12 @@ do_replace(struct net *net, const void __user *user, unsigned int len)
 
  free_newinfo_untrans:
 	xt_entry_foreach(iter, loc_cpu_entry, newinfo->size)
-		if (cleanup_entry(iter, net, NULL) != 0)
-			break;
+		cleanup_entry(iter, net);
  free_newinfo:
 	xt_free_table_info(newinfo);
 	return ret;
 }
 
-/* We're lazy, and add to the first CPU; overflow works its fey magic
- * and everything is OK. */
-static int
-add_counter_to_entry(struct ip6t_entry *e,
-		     const struct xt_counters addme[],
-		     unsigned int *i)
-{
-	ADD_COUNTER(e->counters, addme[*i].bcnt, addme[*i].pcnt);
-
-	(*i)++;
-	return 0;
-}
-
 static int
 do_add_counters(struct net *net, const void __user *user, unsigned int len,
 		int compat)
@@ -1479,9 +1436,10 @@ do_add_counters(struct net *net, const void __user *user, unsigned int len,
 	curcpu = smp_processor_id();
 	xt_info_wrlock(curcpu);
 	loc_cpu_entry = private->entries[curcpu];
-	xt_entry_foreach(iter, loc_cpu_entry, private->size)
-		if (add_counter_to_entry(iter, paddc, &i) != 0)
-			break;
+	xt_entry_foreach(iter, loc_cpu_entry, private->size) {
+		ADD_COUNTER(iter->counters, paddc[i].bcnt, paddc[i].pcnt);
+		++i;
+	}
 	xt_info_wrunlock(curcpu);
 
  unlock_up_free:
@@ -1510,7 +1468,7 @@ struct compat_ip6t_replace {
 static int
 compat_copy_entry_to_user(struct ip6t_entry *e, void __user **dstptr,
 			  unsigned int *size, struct xt_counters *counters,
-			  unsigned int *i)
+			  unsigned int i)
 {
 	struct ip6t_entry_target *t;
 	struct compat_ip6t_entry __user *ce;
@@ -1518,14 +1476,12 @@ compat_copy_entry_to_user(struct ip6t_entry *e, void __user **dstptr,
 	compat_uint_t origsize;
 	int ret;
 
-	ret = -EFAULT;
 	origsize = *size;
 	ce = (struct compat_ip6t_entry __user *)*dstptr;
-	if (copy_to_user(ce, e, sizeof(struct ip6t_entry)))
-		goto out;
-
-	if (copy_to_user(&ce->counters, &counters[*i], sizeof(counters[*i])))
-		goto out;
+	if (copy_to_user(ce, e, sizeof(struct ip6t_entry)) != 0 ||
+	    copy_to_user(&ce->counters, &counters[i],
+	    sizeof(counters[i])) != 0)
+		return -EFAULT;
 
 	*dstptr += sizeof(struct compat_ip6t_entry);
 	*size -= sizeof(struct ip6t_entry) - sizeof(struct compat_ip6t_entry);
@@ -1533,22 +1489,16 @@ compat_copy_entry_to_user(struct ip6t_entry *e, void __user **dstptr,
 	ret = IP6T_MATCH_ITERATE(e, xt_compat_match_to_user, dstptr, size);
 	target_offset = e->target_offset - (origsize - *size);
 	if (ret)
-		goto out;
+		return ret;
 	t = ip6t_get_target(e);
 	ret = xt_compat_target_to_user(t, dstptr, size);
 	if (ret)
-		goto out;
-	ret = -EFAULT;
+		return ret;
 	next_offset = e->next_offset - (origsize - *size);
-	if (put_user(target_offset, &ce->target_offset))
-		goto out;
-	if (put_user(next_offset, &ce->next_offset))
-		goto out;
-
-	(*i)++;
+	if (put_user(target_offset, &ce->target_offset) != 0 ||
+	    put_user(next_offset, &ce->next_offset) != 0)
+		return -EFAULT;
 	return 0;
-out:
-	return ret;
 }
 
 static int
@@ -1585,19 +1535,14 @@ compat_release_match(struct ip6t_entry_match *m, unsigned int *i)
 	return 0;
 }
 
-static int
-compat_release_entry(struct compat_ip6t_entry *e, unsigned int *i)
+static void compat_release_entry(struct compat_ip6t_entry *e)
 {
 	struct ip6t_entry_target *t;
 
-	if (i && (*i)-- == 0)
-		return 1;
-
 	/* Cleanup all matches */
 	COMPAT_IP6T_MATCH_ITERATE(e, compat_release_match, NULL);
 	t = compat_ip6t_get_target(e);
 	module_put(t->u.kernel.target->me);
-	return 0;
 }
 
 static int
@@ -1608,7 +1553,6 @@ check_compat_entry_size_and_hooks(struct compat_ip6t_entry *e,
 				  const unsigned char *limit,
 				  const unsigned int *hook_entries,
 				  const unsigned int *underflows,
-				  unsigned int *i,
 				  const char *name)
 {
 	struct ip6t_entry_target *t;
@@ -1674,8 +1618,6 @@ check_compat_entry_size_and_hooks(struct compat_ip6t_entry *e,
 	/* Clear counters and comefrom */
 	memset(&e->counters, 0, sizeof(e->counters));
 	e->comefrom = 0;
-
-	(*i)++;
 	return 0;
 
 out:
@@ -1725,7 +1667,7 @@ compat_copy_entry_from_user(struct compat_ip6t_entry *e, void **dstptr,
 }
 
 static int compat_check_entry(struct ip6t_entry *e, struct net *net,
-			      const char *name, unsigned int *i)
+			      const char *name)
 {
 	unsigned int j;
 	int ret;
@@ -1744,8 +1686,6 @@ static int compat_check_entry(struct ip6t_entry *e, struct net *net,
 	ret = check_target(e, net, name);
 	if (ret)
 		goto cleanup_matches;
-
-	(*i)++;
 	return 0;
 
  cleanup_matches:
@@ -1790,12 +1730,11 @@ translate_compat_table(struct net *net,
 	xt_entry_foreach(iter0, entry0, total_size) {
 		ret = check_compat_entry_size_and_hooks(iter0, info, &size,
 		      entry0, entry0 + total_size, hook_entries, underflows,
-		      &j, name);
+		      name);
 		if (ret != 0)
-			break;
+			goto out_unlock;
+		++j;
 	}
-	if (ret != 0)
-		goto out_unlock;
 
 	ret = -EINVAL;
 	if (j != number) {
@@ -1851,9 +1790,10 @@ translate_compat_table(struct net *net,
 
 	i = 0;
 	xt_entry_foreach(iter1, entry1, newinfo->size) {
-		ret = compat_check_entry(iter1, net, name, &i);
+		ret = compat_check_entry(iter1, net, name);
 		if (ret != 0)
 			break;
+		++i;
 	}
 	if (ret) {
 		/*
@@ -1866,12 +1806,15 @@ translate_compat_table(struct net *net,
 		xt_entry_foreach(iter0, entry0, newinfo->size) {
 			if (skip-- > 0)
 				continue;
-			if (compat_release_entry(iter0, &j) != 0)
+			if (j-- == 0)
 				break;
+			compat_release_entry(iter0);
 		}
-		xt_entry_foreach(iter1, entry1, newinfo->size)
-			if (cleanup_entry(iter1, net, &i) != 0)
+		xt_entry_foreach(iter1, entry1, newinfo->size) {
+			if (i-- == 0)
 				break;
+			cleanup_entry(iter1, net);
+		}
 		xt_free_table_info(newinfo);
 		return ret;
 	}
@@ -1889,9 +1832,11 @@ translate_compat_table(struct net *net,
 free_newinfo:
 	xt_free_table_info(newinfo);
 out:
-	xt_entry_foreach(iter0, entry0, total_size)
-		if (compat_release_entry(iter0, &j) != 0)
+	xt_entry_foreach(iter0, entry0, total_size) {
+		if (j-- == 0)
 			break;
+		compat_release_entry(iter0);
+	}
 	return ret;
 out_unlock:
 	xt_compat_flush_offsets(AF_INET6);
@@ -1946,8 +1891,7 @@ compat_do_replace(struct net *net, void __user *user, unsigned int len)
 
  free_newinfo_untrans:
 	xt_entry_foreach(iter, loc_cpu_entry, newinfo->size)
-		if (cleanup_entry(iter, net, NULL) != 0)
-			break;
+		cleanup_entry(iter, net);
  free_newinfo:
 	xt_free_table_info(newinfo);
 	return ret;
@@ -2011,7 +1955,7 @@ compat_copy_entries_to_user(unsigned int total_size, struct xt_table *table,
 	size = total_size;
 	xt_entry_foreach(iter, loc_cpu_entry, total_size) {
 		ret = compat_copy_entry_to_user(iter, &pos,
-		      &size, counters, &i);
+		      &size, counters, i++);
 		if (ret != 0)
 			break;
 	}
@@ -2221,8 +2165,7 @@ void ip6t_unregister_table(struct net *net, struct xt_table *table)
 	/* Decrease module usage counts and free resources */
 	loc_cpu_entry = private->entries[raw_smp_processor_id()];
 	xt_entry_foreach(iter, loc_cpu_entry, private->size)
-		if (cleanup_entry(iter, net, NULL) != 0)
-			break;
+		cleanup_entry(iter, net);
 	if (private->number > private->initial_entries)
 		module_put(table_owner);
 	xt_free_table_info(private);
