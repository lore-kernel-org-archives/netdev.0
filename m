From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 15/62: xtables: add struct xt_mtdtor_param::net
Date: Tue, 16 Feb 2010 15:55:40 +0100 (MET)
Message-ID: <20100216145538.2796.77511.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit f54e9367f8499a9bf6b2afbc0dce63e1d53c525a
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Mon Jan 18 08:25:47 2010 +0100

    netfilter: xtables: add struct xt_mtdtor_param::net
    
    Add ->net to match destructor list like ->net in constructor list.
    
    Make sure it's set in ebtables/iptables/ip6tables, this requires to
    propagate netns up to *_unregister_table().
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 88261b9..3caf5e1 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -216,6 +216,7 @@ struct xt_mtchk_param {
 
 /* Match destructor parameters */
 struct xt_mtdtor_param {
+	struct net *net;
 	const struct xt_match *match;
 	void *matchinfo;
 	u_int8_t family;
diff --git a/include/linux/netfilter_bridge/ebtables.h b/include/linux/netfilter_bridge/ebtables.h
index 3cc40c1..1c6f0c5 100644
--- a/include/linux/netfilter_bridge/ebtables.h
+++ b/include/linux/netfilter_bridge/ebtables.h
@@ -289,7 +289,7 @@ struct ebt_table {
 		     ~(__alignof__(struct ebt_replace)-1))
 extern struct ebt_table *ebt_register_table(struct net *net,
 					    const struct ebt_table *table);
-extern void ebt_unregister_table(struct ebt_table *table);
+extern void ebt_unregister_table(struct net *net, struct ebt_table *table);
 extern unsigned int ebt_do_table(unsigned int hook, struct sk_buff *skb,
    const struct net_device *in, const struct net_device *out,
    struct ebt_table *table);
diff --git a/include/linux/netfilter_ipv4/ip_tables.h b/include/linux/netfilter_ipv4/ip_tables.h
index 27b3f58..8d1f273 100644
--- a/include/linux/netfilter_ipv4/ip_tables.h
+++ b/include/linux/netfilter_ipv4/ip_tables.h
@@ -242,7 +242,7 @@ extern void ipt_init(void) __init;
 extern struct xt_table *ipt_register_table(struct net *net,
 					   const struct xt_table *table,
 					   const struct ipt_replace *repl);
-extern void ipt_unregister_table(struct xt_table *table);
+extern void ipt_unregister_table(struct net *net, struct xt_table *table);
 
 /* Standard entry. */
 struct ipt_standard {
diff --git a/include/linux/netfilter_ipv6/ip6_tables.h b/include/linux/netfilter_ipv6/ip6_tables.h
index b31050d..d2952d2 100644
--- a/include/linux/netfilter_ipv6/ip6_tables.h
+++ b/include/linux/netfilter_ipv6/ip6_tables.h
@@ -300,7 +300,7 @@ extern void ip6t_init(void) __init;
 extern struct xt_table *ip6t_register_table(struct net *net,
 					    const struct xt_table *table,
 					    const struct ip6t_replace *repl);
-extern void ip6t_unregister_table(struct xt_table *table);
+extern void ip6t_unregister_table(struct net *net, struct xt_table *table);
 extern unsigned int ip6t_do_table(struct sk_buff *skb,
 				  unsigned int hook,
 				  const struct net_device *in,
diff --git a/net/bridge/netfilter/ebtable_broute.c b/net/bridge/netfilter/ebtable_broute.c
index d32ab13..ae3f106 100644
--- a/net/bridge/netfilter/ebtable_broute.c
+++ b/net/bridge/netfilter/ebtable_broute.c
@@ -71,7 +71,7 @@ static int __net_init broute_net_init(struct net *net)
 
 static void __net_exit broute_net_exit(struct net *net)
 {
-	ebt_unregister_table(net->xt.broute_table);
+	ebt_unregister_table(net, net->xt.broute_table);
 }
 
 static struct pernet_operations broute_net_ops = {
diff --git a/net/bridge/netfilter/ebtable_filter.c b/net/bridge/netfilter/ebtable_filter.c
index 60b1a6c..42e6bd0 100644
--- a/net/bridge/netfilter/ebtable_filter.c
+++ b/net/bridge/netfilter/ebtable_filter.c
@@ -107,7 +107,7 @@ static int __net_init frame_filter_net_init(struct net *net)
 
 static void __net_exit frame_filter_net_exit(struct net *net)
 {
-	ebt_unregister_table(net->xt.frame_filter);
+	ebt_unregister_table(net, net->xt.frame_filter);
 }
 
 static struct pernet_operations frame_filter_net_ops = {
diff --git a/net/bridge/netfilter/ebtable_nat.c b/net/bridge/netfilter/ebtable_nat.c
index 4a98804..6dc2f87 100644
--- a/net/bridge/netfilter/ebtable_nat.c
+++ b/net/bridge/netfilter/ebtable_nat.c
@@ -107,7 +107,7 @@ static int __net_init frame_nat_net_init(struct net *net)
 
 static void __net_exit frame_nat_net_exit(struct net *net)
 {
-	ebt_unregister_table(net->xt.frame_nat);
+	ebt_unregister_table(net, net->xt.frame_nat);
 }
 
 static struct pernet_operations frame_nat_net_ops = {
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index c77bab9..1aa0e4c 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -561,13 +561,14 @@ ebt_get_udc_positions(struct ebt_entry *e, struct ebt_table_info *newinfo,
 }
 
 static inline int
-ebt_cleanup_match(struct ebt_entry_match *m, unsigned int *i)
+ebt_cleanup_match(struct ebt_entry_match *m, struct net *net, unsigned int *i)
 {
 	struct xt_mtdtor_param par;
 
 	if (i && (*i)-- == 0)
 		return 1;
 
+	par.net       = net;
 	par.match     = m->u.match;
 	par.matchinfo = m->data;
 	par.family    = NFPROTO_BRIDGE;
@@ -595,7 +596,7 @@ ebt_cleanup_watcher(struct ebt_entry_watcher *w, unsigned int *i)
 }
 
 static inline int
-ebt_cleanup_entry(struct ebt_entry *e, unsigned int *cnt)
+ebt_cleanup_entry(struct ebt_entry *e, struct net *net, unsigned int *cnt)
 {
 	struct xt_tgdtor_param par;
 	struct ebt_entry_target *t;
@@ -606,7 +607,7 @@ ebt_cleanup_entry(struct ebt_entry *e, unsigned int *cnt)
 	if (cnt && (*cnt)-- == 0)
 		return 1;
 	EBT_WATCHER_ITERATE(e, ebt_cleanup_watcher, NULL);
-	EBT_MATCH_ITERATE(e, ebt_cleanup_match, NULL);
+	EBT_MATCH_ITERATE(e, ebt_cleanup_match, net, NULL);
 	t = (struct ebt_entry_target *)(((char *)e) + e->target_offset);
 
 	par.target   = t->u.target;
@@ -731,7 +732,7 @@ ebt_check_entry(struct ebt_entry *e,
 cleanup_watchers:
 	EBT_WATCHER_ITERATE(e, ebt_cleanup_watcher, &j);
 cleanup_matches:
-	EBT_MATCH_ITERATE(e, ebt_cleanup_match, &i);
+	EBT_MATCH_ITERATE(e, ebt_cleanup_match, net, &i);
 	return ret;
 }
 
@@ -924,7 +925,7 @@ static int translate_table(struct net *net, char *name,
 	   ebt_check_entry, net, newinfo, name, &i, cl_s, udc_cnt);
 	if (ret != 0) {
 		EBT_ENTRY_ITERATE(newinfo->entries, newinfo->entries_size,
-		   ebt_cleanup_entry, &i);
+				  ebt_cleanup_entry, net, &i);
 	}
 	vfree(cl_s);
 	return ret;
@@ -1074,7 +1075,7 @@ static int do_replace(struct net *net, void __user *user, unsigned int len)
 
 	/* decrease module count and free resources */
 	EBT_ENTRY_ITERATE(table->entries, table->entries_size,
-	   ebt_cleanup_entry, NULL);
+			  ebt_cleanup_entry, net, NULL);
 
 	vfree(table->entries);
 	if (table->chainstack) {
@@ -1091,7 +1092,7 @@ free_unlock:
 	mutex_unlock(&ebt_mutex);
 free_iterate:
 	EBT_ENTRY_ITERATE(newinfo->entries, newinfo->entries_size,
-	   ebt_cleanup_entry, NULL);
+			  ebt_cleanup_entry, net, NULL);
 free_counterstmp:
 	vfree(counterstmp);
 	/* can be initialized in translate_table() */
@@ -1208,7 +1209,7 @@ out:
 	return ERR_PTR(ret);
 }
 
-void ebt_unregister_table(struct ebt_table *table)
+void ebt_unregister_table(struct net *net, struct ebt_table *table)
 {
 	int i;
 
@@ -1220,7 +1221,7 @@ void ebt_unregister_table(struct ebt_table *table)
 	list_del(&table->list);
 	mutex_unlock(&ebt_mutex);
 	EBT_ENTRY_ITERATE(table->private->entries, table->private->entries_size,
-			  ebt_cleanup_entry, NULL);
+			  ebt_cleanup_entry, net, NULL);
 	if (table->private->nentries)
 		module_put(table->me);
 	vfree(table->private->entries);
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index a069d72..cfaba0e 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -553,13 +553,14 @@ mark_source_chains(struct xt_table_info *newinfo,
 }
 
 static int
-cleanup_match(struct ipt_entry_match *m, unsigned int *i)
+cleanup_match(struct ipt_entry_match *m, struct net *net, unsigned int *i)
 {
 	struct xt_mtdtor_param par;
 
 	if (i && (*i)-- == 0)
 		return 1;
 
+	par.net       = net;
 	par.match     = m->u.kernel.match;
 	par.matchinfo = m->data;
 	par.family    = NFPROTO_IPV4;
@@ -705,7 +706,7 @@ find_check_entry(struct ipt_entry *e, struct net *net, const char *name,
  err:
 	module_put(t->u.kernel.target->me);
  cleanup_matches:
-	IPT_MATCH_ITERATE(e, cleanup_match, &j);
+	IPT_MATCH_ITERATE(e, cleanup_match, net, &j);
 	return ret;
 }
 
@@ -775,7 +776,7 @@ check_entry_size_and_hooks(struct ipt_entry *e,
 }
 
 static int
-cleanup_entry(struct ipt_entry *e, unsigned int *i)
+cleanup_entry(struct ipt_entry *e, struct net *net, unsigned int *i)
 {
 	struct xt_tgdtor_param par;
 	struct ipt_entry_target *t;
@@ -784,7 +785,7 @@ cleanup_entry(struct ipt_entry *e, unsigned int *i)
 		return 1;
 
 	/* Cleanup all matches */
-	IPT_MATCH_ITERATE(e, cleanup_match, NULL);
+	IPT_MATCH_ITERATE(e, cleanup_match, net, NULL);
 	t = ipt_get_target(e);
 
 	par.target   = t->u.kernel.target;
@@ -866,7 +867,7 @@ translate_table(struct net *net,
 
 	if (ret != 0) {
 		IPT_ENTRY_ITERATE(entry0, newinfo->size,
-				cleanup_entry, &i);
+				cleanup_entry, net, &i);
 		return ret;
 	}
 
@@ -1260,7 +1261,7 @@ __do_replace(struct net *net, const char *name, unsigned int valid_hooks,
 	/* Decrease module usage counts and free resource */
 	loc_cpu_old_entry = oldinfo->entries[raw_smp_processor_id()];
 	IPT_ENTRY_ITERATE(loc_cpu_old_entry, oldinfo->size, cleanup_entry,
-			  NULL);
+			  net, NULL);
 	xt_free_table_info(oldinfo);
 	if (copy_to_user(counters_ptr, counters,
 			 sizeof(struct xt_counters) * num_counters) != 0)
@@ -1320,7 +1321,7 @@ do_replace(struct net *net, void __user *user, unsigned int len)
 	return 0;
 
  free_newinfo_untrans:
-	IPT_ENTRY_ITERATE(loc_cpu_entry, newinfo->size, cleanup_entry, NULL);
+	IPT_ENTRY_ITERATE(loc_cpu_entry, newinfo->size, cleanup_entry, net, NULL);
  free_newinfo:
 	xt_free_table_info(newinfo);
 	return ret;
@@ -1682,7 +1683,7 @@ compat_check_entry(struct ipt_entry *e, struct net *net, const char *name,
 	return 0;
 
  cleanup_matches:
-	IPT_MATCH_ITERATE(e, cleanup_match, &j);
+	IPT_MATCH_ITERATE(e, cleanup_match, net, &j);
 	return ret;
 }
 
@@ -1782,7 +1783,7 @@ translate_compat_table(struct net *net,
 		j -= i;
 		COMPAT_IPT_ENTRY_ITERATE_CONTINUE(entry0, newinfo->size, i,
 						  compat_release_entry, &j);
-		IPT_ENTRY_ITERATE(entry1, newinfo->size, cleanup_entry, &i);
+		IPT_ENTRY_ITERATE(entry1, newinfo->size, cleanup_entry, net, &i);
 		xt_free_table_info(newinfo);
 		return ret;
 	}
@@ -1853,7 +1854,7 @@ compat_do_replace(struct net *net, void __user *user, unsigned int len)
 	return 0;
 
  free_newinfo_untrans:
-	IPT_ENTRY_ITERATE(loc_cpu_entry, newinfo->size, cleanup_entry, NULL);
+	IPT_ENTRY_ITERATE(loc_cpu_entry, newinfo->size, cleanup_entry, net, NULL);
  free_newinfo:
 	xt_free_table_info(newinfo);
 	return ret;
@@ -2112,7 +2113,7 @@ out:
 	return ERR_PTR(ret);
 }
 
-void ipt_unregister_table(struct xt_table *table)
+void ipt_unregister_table(struct net *net, struct xt_table *table)
 {
 	struct xt_table_info *private;
 	void *loc_cpu_entry;
@@ -2122,7 +2123,7 @@ void ipt_unregister_table(struct xt_table *table)
 
 	/* Decrease module usage counts and free resources */
 	loc_cpu_entry = private->entries[raw_smp_processor_id()];
-	IPT_ENTRY_ITERATE(loc_cpu_entry, private->size, cleanup_entry, NULL);
+	IPT_ENTRY_ITERATE(loc_cpu_entry, private->size, cleanup_entry, net, NULL);
 	if (private->number > private->initial_entries)
 		module_put(table_owner);
 	xt_free_table_info(private);
diff --git a/net/ipv4/netfilter/iptable_filter.c b/net/ipv4/netfilter/iptable_filter.c
index df566cb..dee90eb 100644
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -138,7 +138,7 @@ static int __net_init iptable_filter_net_init(struct net *net)
 
 static void __net_exit iptable_filter_net_exit(struct net *net)
 {
-	ipt_unregister_table(net->ipv4.iptable_filter);
+	ipt_unregister_table(net, net->ipv4.iptable_filter);
 }
 
 static struct pernet_operations iptable_filter_net_ops = {
diff --git a/net/ipv4/netfilter/iptable_mangle.c b/net/ipv4/netfilter/iptable_mangle.c
index fae78c3..e07bf24 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -208,7 +208,7 @@ static int __net_init iptable_mangle_net_init(struct net *net)
 
 static void __net_exit iptable_mangle_net_exit(struct net *net)
 {
-	ipt_unregister_table(net->ipv4.iptable_mangle);
+	ipt_unregister_table(net, net->ipv4.iptable_mangle);
 }
 
 static struct pernet_operations iptable_mangle_net_ops = {
diff --git a/net/ipv4/netfilter/iptable_raw.c b/net/ipv4/netfilter/iptable_raw.c
index 993edc2..40f2b9f 100644
--- a/net/ipv4/netfilter/iptable_raw.c
+++ b/net/ipv4/netfilter/iptable_raw.c
@@ -100,7 +100,7 @@ static int __net_init iptable_raw_net_init(struct net *net)
 
 static void __net_exit iptable_raw_net_exit(struct net *net)
 {
-	ipt_unregister_table(net->ipv4.iptable_raw);
+	ipt_unregister_table(net, net->ipv4.iptable_raw);
 }
 
 static struct pernet_operations iptable_raw_net_ops = {
diff --git a/net/ipv4/netfilter/iptable_security.c b/net/ipv4/netfilter/iptable_security.c
index 3bd3d63..7ce2366 100644
--- a/net/ipv4/netfilter/iptable_security.c
+++ b/net/ipv4/netfilter/iptable_security.c
@@ -138,7 +138,7 @@ static int __net_init iptable_security_net_init(struct net *net)
 
 static void __net_exit iptable_security_net_exit(struct net *net)
 {
-	ipt_unregister_table(net->ipv4.iptable_security);
+	ipt_unregister_table(net, net->ipv4.iptable_security);
 }
 
 static struct pernet_operations iptable_security_net_ops = {
diff --git a/net/ipv4/netfilter/nf_nat_rule.c b/net/ipv4/netfilter/nf_nat_rule.c
index 9e81e0d..85da34f 100644
--- a/net/ipv4/netfilter/nf_nat_rule.c
+++ b/net/ipv4/netfilter/nf_nat_rule.c
@@ -195,7 +195,7 @@ static int __net_init nf_nat_rule_net_init(struct net *net)
 
 static void __net_exit nf_nat_rule_net_exit(struct net *net)
 {
-	ipt_unregister_table(net->ipv4.nat_table);
+	ipt_unregister_table(net, net->ipv4.nat_table);
 }
 
 static struct pernet_operations nf_nat_rule_net_ops = {
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index a825940..9f1d45f 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -585,13 +585,14 @@ mark_source_chains(struct xt_table_info *newinfo,
 }
 
 static int
-cleanup_match(struct ip6t_entry_match *m, unsigned int *i)
+cleanup_match(struct ip6t_entry_match *m, struct net *net, unsigned int *i)
 {
 	struct xt_mtdtor_param par;
 
 	if (i && (*i)-- == 0)
 		return 1;
 
+	par.net       = net;
 	par.match     = m->u.kernel.match;
 	par.matchinfo = m->data;
 	par.family    = NFPROTO_IPV6;
@@ -737,7 +738,7 @@ find_check_entry(struct ip6t_entry *e, struct net *net, const char *name,
  err:
 	module_put(t->u.kernel.target->me);
  cleanup_matches:
-	IP6T_MATCH_ITERATE(e, cleanup_match, &j);
+	IP6T_MATCH_ITERATE(e, cleanup_match, net, &j);
 	return ret;
 }
 
@@ -807,7 +808,7 @@ check_entry_size_and_hooks(struct ip6t_entry *e,
 }
 
 static int
-cleanup_entry(struct ip6t_entry *e, unsigned int *i)
+cleanup_entry(struct ip6t_entry *e, struct net *net, unsigned int *i)
 {
 	struct xt_tgdtor_param par;
 	struct ip6t_entry_target *t;
@@ -816,7 +817,7 @@ cleanup_entry(struct ip6t_entry *e, unsigned int *i)
 		return 1;
 
 	/* Cleanup all matches */
-	IP6T_MATCH_ITERATE(e, cleanup_match, NULL);
+	IP6T_MATCH_ITERATE(e, cleanup_match, net, NULL);
 	t = ip6t_get_target(e);
 
 	par.target   = t->u.kernel.target;
@@ -898,7 +899,7 @@ translate_table(struct net *net,
 
 	if (ret != 0) {
 		IP6T_ENTRY_ITERATE(entry0, newinfo->size,
-				   cleanup_entry, &i);
+				   cleanup_entry, net, &i);
 		return ret;
 	}
 
@@ -1293,7 +1294,7 @@ __do_replace(struct net *net, const char *name, unsigned int valid_hooks,
 	/* Decrease module usage counts and free resource */
 	loc_cpu_old_entry = oldinfo->entries[raw_smp_processor_id()];
 	IP6T_ENTRY_ITERATE(loc_cpu_old_entry, oldinfo->size, cleanup_entry,
-			   NULL);
+			   net, NULL);
 	xt_free_table_info(oldinfo);
 	if (copy_to_user(counters_ptr, counters,
 			 sizeof(struct xt_counters) * num_counters) != 0)
@@ -1353,7 +1354,7 @@ do_replace(struct net *net, void __user *user, unsigned int len)
 	return 0;
 
  free_newinfo_untrans:
-	IP6T_ENTRY_ITERATE(loc_cpu_entry, newinfo->size, cleanup_entry, NULL);
+	IP6T_ENTRY_ITERATE(loc_cpu_entry, newinfo->size, cleanup_entry, net, NULL);
  free_newinfo:
 	xt_free_table_info(newinfo);
 	return ret;
@@ -1692,14 +1693,15 @@ compat_copy_entry_from_user(struct compat_ip6t_entry *e, void **dstptr,
 	return ret;
 }
 
-static int compat_check_entry(struct ip6t_entry *e, const char *name,
-				     unsigned int *i)
+static int compat_check_entry(struct ip6t_entry *e, struct net *net,
+			      const char *name, unsigned int *i)
 {
 	unsigned int j;
 	int ret;
 	struct xt_mtchk_param mtpar;
 
 	j = 0;
+	mtpar.net	= net;
 	mtpar.table     = name;
 	mtpar.entryinfo = &e->ipv6;
 	mtpar.hook_mask = e->comefrom;
@@ -1716,12 +1718,13 @@ static int compat_check_entry(struct ip6t_entry *e, const char *name,
 	return 0;
 
  cleanup_matches:
-	IP6T_MATCH_ITERATE(e, cleanup_match, &j);
+	IP6T_MATCH_ITERATE(e, cleanup_match, net, &j);
 	return ret;
 }
 
 static int
-translate_compat_table(const char *name,
+translate_compat_table(struct net *net,
+		       const char *name,
 		       unsigned int valid_hooks,
 		       struct xt_table_info **pinfo,
 		       void **pentry0,
@@ -1810,12 +1813,12 @@ translate_compat_table(const char *name,
 
 	i = 0;
 	ret = IP6T_ENTRY_ITERATE(entry1, newinfo->size, compat_check_entry,
-				 name, &i);
+				 net, name, &i);
 	if (ret) {
 		j -= i;
 		COMPAT_IP6T_ENTRY_ITERATE_CONTINUE(entry0, newinfo->size, i,
 						   compat_release_entry, &j);
-		IP6T_ENTRY_ITERATE(entry1, newinfo->size, cleanup_entry, &i);
+		IP6T_ENTRY_ITERATE(entry1, newinfo->size, cleanup_entry, net, &i);
 		xt_free_table_info(newinfo);
 		return ret;
 	}
@@ -1870,7 +1873,7 @@ compat_do_replace(struct net *net, void __user *user, unsigned int len)
 		goto free_newinfo;
 	}
 
-	ret = translate_compat_table(tmp.name, tmp.valid_hooks,
+	ret = translate_compat_table(net, tmp.name, tmp.valid_hooks,
 				     &newinfo, &loc_cpu_entry, tmp.size,
 				     tmp.num_entries, tmp.hook_entry,
 				     tmp.underflow);
@@ -1886,7 +1889,7 @@ compat_do_replace(struct net *net, void __user *user, unsigned int len)
 	return 0;
 
  free_newinfo_untrans:
-	IP6T_ENTRY_ITERATE(loc_cpu_entry, newinfo->size, cleanup_entry, NULL);
+	IP6T_ENTRY_ITERATE(loc_cpu_entry, newinfo->size, cleanup_entry, net, NULL);
  free_newinfo:
 	xt_free_table_info(newinfo);
 	return ret;
@@ -2144,7 +2147,7 @@ out:
 	return ERR_PTR(ret);
 }
 
-void ip6t_unregister_table(struct xt_table *table)
+void ip6t_unregister_table(struct net *net, struct xt_table *table)
 {
 	struct xt_table_info *private;
 	void *loc_cpu_entry;
@@ -2154,7 +2157,7 @@ void ip6t_unregister_table(struct xt_table *table)
 
 	/* Decrease module usage counts and free resources */
 	loc_cpu_entry = private->entries[raw_smp_processor_id()];
-	IP6T_ENTRY_ITERATE(loc_cpu_entry, private->size, cleanup_entry, NULL);
+	IP6T_ENTRY_ITERATE(loc_cpu_entry, private->size, cleanup_entry, net, NULL);
 	if (private->number > private->initial_entries)
 		module_put(table_owner);
 	xt_free_table_info(private);
diff --git a/net/ipv6/netfilter/ip6table_filter.c b/net/ipv6/netfilter/ip6table_filter.c
index ad378ef..33ddfe5 100644
--- a/net/ipv6/netfilter/ip6table_filter.c
+++ b/net/ipv6/netfilter/ip6table_filter.c
@@ -131,7 +131,7 @@ static int __net_init ip6table_filter_net_init(struct net *net)
 
 static void __net_exit ip6table_filter_net_exit(struct net *net)
 {
-	ip6t_unregister_table(net->ipv6.ip6table_filter);
+	ip6t_unregister_table(net, net->ipv6.ip6table_filter);
 }
 
 static struct pernet_operations ip6table_filter_net_ops = {
diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6table_mangle.c
index a929c19..9bc483f 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -182,7 +182,7 @@ static int __net_init ip6table_mangle_net_init(struct net *net)
 
 static void __net_exit ip6table_mangle_net_exit(struct net *net)
 {
-	ip6t_unregister_table(net->ipv6.ip6table_mangle);
+	ip6t_unregister_table(net, net->ipv6.ip6table_mangle);
 }
 
 static struct pernet_operations ip6table_mangle_net_ops = {
diff --git a/net/ipv6/netfilter/ip6table_raw.c b/net/ipv6/netfilter/ip6table_raw.c
index ed1a118..4c90b55 100644
--- a/net/ipv6/netfilter/ip6table_raw.c
+++ b/net/ipv6/netfilter/ip6table_raw.c
@@ -94,7 +94,7 @@ static int __net_init ip6table_raw_net_init(struct net *net)
 
 static void __net_exit ip6table_raw_net_exit(struct net *net)
 {
-	ip6t_unregister_table(net->ipv6.ip6table_raw);
+	ip6t_unregister_table(net, net->ipv6.ip6table_raw);
 }
 
 static struct pernet_operations ip6table_raw_net_ops = {
diff --git a/net/ipv6/netfilter/ip6table_security.c b/net/ipv6/netfilter/ip6table_security.c
index 41b444c..baa8d4e 100644
--- a/net/ipv6/netfilter/ip6table_security.c
+++ b/net/ipv6/netfilter/ip6table_security.c
@@ -134,7 +134,7 @@ static int __net_init ip6table_security_net_init(struct net *net)
 
 static void __net_exit ip6table_security_net_exit(struct net *net)
 {
-	ip6t_unregister_table(net->ipv6.ip6table_security);
+	ip6t_unregister_table(net, net->ipv6.ip6table_security);
 }
 
 static struct pernet_operations ip6table_security_net_ops = {
