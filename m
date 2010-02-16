From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 14/62: xtables: add struct xt_mtchk_param::net
Date: Tue, 16 Feb 2010 15:55:39 +0100 (MET)
Message-ID: <20100216145536.2796.81635.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51983 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756127Ab0BPOzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:55:40 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit a83d8e8d099fc373a5ca7112ad08c553bb2c180f
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Mon Jan 18 08:21:13 2010 +0100

    netfilter: xtables: add struct xt_mtchk_param::net
    
    Some complex match modules (like xt_hashlimit/xt_recent) want netns
    information at constructor and destructor time. We propably can play
    games at match destruction time, because netns can be passed in object,
    but I think it's cleaner to explicitly pass netns.
    
    Add ->net, make sure it's set from ebtables/iptables/ip6tables code.
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 378f27a..88261b9 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -205,6 +205,7 @@ struct xt_match_param {
  * @hook_mask:	via which hooks the new rule is reachable
  */
 struct xt_mtchk_param {
+	struct net *net;
 	const char *table;
 	const void *entryinfo;
 	const struct xt_match *match;
diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index bd1c654..c77bab9 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -619,7 +619,9 @@ ebt_cleanup_entry(struct ebt_entry *e, unsigned int *cnt)
 }
 
 static inline int
-ebt_check_entry(struct ebt_entry *e, struct ebt_table_info *newinfo,
+ebt_check_entry(struct ebt_entry *e,
+   struct net *net,
+   struct ebt_table_info *newinfo,
    const char *name, unsigned int *cnt,
    struct ebt_cl_stack *cl_s, unsigned int udc_cnt)
 {
@@ -671,6 +673,7 @@ ebt_check_entry(struct ebt_entry *e, struct ebt_table_info *newinfo,
 	}
 	i = 0;
 
+	mtpar.net	= net;
 	mtpar.table     = tgpar.table     = name;
 	mtpar.entryinfo = tgpar.entryinfo = e;
 	mtpar.hook_mask = tgpar.hook_mask = hookmask;
@@ -808,7 +811,8 @@ letscontinue:
 }
 
 /* do the parsing of the table/chains/entries/matches/watchers/targets, heh */
-static int translate_table(char *name, struct ebt_table_info *newinfo)
+static int translate_table(struct net *net, char *name,
+			   struct ebt_table_info *newinfo)
 {
 	unsigned int i, j, k, udc_cnt;
 	int ret;
@@ -917,7 +921,7 @@ static int translate_table(char *name, struct ebt_table_info *newinfo)
 	/* used to know what we need to clean up if something goes wrong */
 	i = 0;
 	ret = EBT_ENTRY_ITERATE(newinfo->entries, newinfo->entries_size,
-	   ebt_check_entry, newinfo, name, &i, cl_s, udc_cnt);
+	   ebt_check_entry, net, newinfo, name, &i, cl_s, udc_cnt);
 	if (ret != 0) {
 		EBT_ENTRY_ITERATE(newinfo->entries, newinfo->entries_size,
 		   ebt_cleanup_entry, &i);
@@ -1017,7 +1021,7 @@ static int do_replace(struct net *net, void __user *user, unsigned int len)
 	if (ret != 0)
 		goto free_counterstmp;
 
-	ret = translate_table(tmp.name, newinfo);
+	ret = translate_table(net, tmp.name, newinfo);
 
 	if (ret != 0)
 		goto free_counterstmp;
@@ -1154,7 +1158,7 @@ ebt_register_table(struct net *net, const struct ebt_table *input_table)
 			newinfo->hook_entry[i] = p +
 				((char *)repl->hook_entry[i] - repl->entries);
 	}
-	ret = translate_table(repl->name, newinfo);
+	ret = translate_table(net, repl->name, newinfo);
 	if (ret != 0) {
 		BUGPRINT("Translate_table failed\n");
 		goto free_chainstack;
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 572330a..a069d72 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -661,8 +661,8 @@ static int check_target(struct ipt_entry *e, const char *name)
 }
 
 static int
-find_check_entry(struct ipt_entry *e, const char *name, unsigned int size,
-		 unsigned int *i)
+find_check_entry(struct ipt_entry *e, struct net *net, const char *name,
+		 unsigned int size, unsigned int *i)
 {
 	struct ipt_entry_target *t;
 	struct xt_target *target;
@@ -675,6 +675,7 @@ find_check_entry(struct ipt_entry *e, const char *name, unsigned int size,
 		return ret;
 
 	j = 0;
+	mtpar.net	= net;
 	mtpar.table     = name;
 	mtpar.entryinfo = &e->ip;
 	mtpar.hook_mask = e->comefrom;
@@ -798,7 +799,8 @@ cleanup_entry(struct ipt_entry *e, unsigned int *i)
 /* Checks and translates the user-supplied table segment (held in
    newinfo) */
 static int
-translate_table(const char *name,
+translate_table(struct net *net,
+		const char *name,
 		unsigned int valid_hooks,
 		struct xt_table_info *newinfo,
 		void *entry0,
@@ -860,7 +862,7 @@ translate_table(const char *name,
 	/* Finally, each sanity check must pass */
 	i = 0;
 	ret = IPT_ENTRY_ITERATE(entry0, newinfo->size,
-				find_check_entry, name, size, &i);
+				find_check_entry, net, name, size, &i);
 
 	if (ret != 0) {
 		IPT_ENTRY_ITERATE(entry0, newinfo->size,
@@ -1303,7 +1305,7 @@ do_replace(struct net *net, void __user *user, unsigned int len)
 		goto free_newinfo;
 	}
 
-	ret = translate_table(tmp.name, tmp.valid_hooks,
+	ret = translate_table(net, tmp.name, tmp.valid_hooks,
 			      newinfo, loc_cpu_entry, tmp.size, tmp.num_entries,
 			      tmp.hook_entry, tmp.underflow);
 	if (ret != 0)
@@ -1655,7 +1657,7 @@ compat_copy_entry_from_user(struct compat_ipt_entry *e, void **dstptr,
 }
 
 static int
-compat_check_entry(struct ipt_entry *e, const char *name,
+compat_check_entry(struct ipt_entry *e, struct net *net, const char *name,
 				     unsigned int *i)
 {
 	struct xt_mtchk_param mtpar;
@@ -1663,6 +1665,7 @@ compat_check_entry(struct ipt_entry *e, const char *name,
 	int ret;
 
 	j = 0;
+	mtpar.net	= net;
 	mtpar.table     = name;
 	mtpar.entryinfo = &e->ip;
 	mtpar.hook_mask = e->comefrom;
@@ -1684,7 +1687,8 @@ compat_check_entry(struct ipt_entry *e, const char *name,
 }
 
 static int
-translate_compat_table(const char *name,
+translate_compat_table(struct net *net,
+		       const char *name,
 		       unsigned int valid_hooks,
 		       struct xt_table_info **pinfo,
 		       void **pentry0,
@@ -1773,7 +1777,7 @@ translate_compat_table(const char *name,
 
 	i = 0;
 	ret = IPT_ENTRY_ITERATE(entry1, newinfo->size, compat_check_entry,
-				name, &i);
+				net, name, &i);
 	if (ret) {
 		j -= i;
 		COMPAT_IPT_ENTRY_ITERATE_CONTINUE(entry0, newinfo->size, i,
@@ -1833,7 +1837,7 @@ compat_do_replace(struct net *net, void __user *user, unsigned int len)
 		goto free_newinfo;
 	}
 
-	ret = translate_compat_table(tmp.name, tmp.valid_hooks,
+	ret = translate_compat_table(net, tmp.name, tmp.valid_hooks,
 				     &newinfo, &loc_cpu_entry, tmp.size,
 				     tmp.num_entries, tmp.hook_entry,
 				     tmp.underflow);
@@ -2086,7 +2090,7 @@ struct xt_table *ipt_register_table(struct net *net,
 	loc_cpu_entry = newinfo->entries[raw_smp_processor_id()];
 	memcpy(loc_cpu_entry, repl->entries, repl->size);
 
-	ret = translate_table(table->name, table->valid_hooks,
+	ret = translate_table(net, table->name, table->valid_hooks,
 			      newinfo, loc_cpu_entry, repl->size,
 			      repl->num_entries,
 			      repl->hook_entry,
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 480d7f8..a825940 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -693,8 +693,8 @@ static int check_target(struct ip6t_entry *e, const char *name)
 }
 
 static int
-find_check_entry(struct ip6t_entry *e, const char *name, unsigned int size,
-		 unsigned int *i)
+find_check_entry(struct ip6t_entry *e, struct net *net, const char *name,
+		 unsigned int size, unsigned int *i)
 {
 	struct ip6t_entry_target *t;
 	struct xt_target *target;
@@ -707,6 +707,7 @@ find_check_entry(struct ip6t_entry *e, const char *name, unsigned int size,
 		return ret;
 
 	j = 0;
+	mtpar.net	= net;
 	mtpar.table     = name;
 	mtpar.entryinfo = &e->ipv6;
 	mtpar.hook_mask = e->comefrom;
@@ -830,7 +831,8 @@ cleanup_entry(struct ip6t_entry *e, unsigned int *i)
 /* Checks and translates the user-supplied table segment (held in
    newinfo) */
 static int
-translate_table(const char *name,
+translate_table(struct net *net,
+		const char *name,
 		unsigned int valid_hooks,
 		struct xt_table_info *newinfo,
 		void *entry0,
@@ -892,7 +894,7 @@ translate_table(const char *name,
 	/* Finally, each sanity check must pass */
 	i = 0;
 	ret = IP6T_ENTRY_ITERATE(entry0, newinfo->size,
-				find_check_entry, name, size, &i);
+				find_check_entry, net, name, size, &i);
 
 	if (ret != 0) {
 		IP6T_ENTRY_ITERATE(entry0, newinfo->size,
@@ -1336,7 +1338,7 @@ do_replace(struct net *net, void __user *user, unsigned int len)
 		goto free_newinfo;
 	}
 
-	ret = translate_table(tmp.name, tmp.valid_hooks,
+	ret = translate_table(net, tmp.name, tmp.valid_hooks,
 			      newinfo, loc_cpu_entry, tmp.size, tmp.num_entries,
 			      tmp.hook_entry, tmp.underflow);
 	if (ret != 0)
@@ -2121,7 +2123,7 @@ struct xt_table *ip6t_register_table(struct net *net,
 	loc_cpu_entry = newinfo->entries[raw_smp_processor_id()];
 	memcpy(loc_cpu_entry, repl->entries, repl->size);
 
-	ret = translate_table(table->name, table->valid_hooks,
+	ret = translate_table(net, table->name, table->valid_hooks,
 			      newinfo, loc_cpu_entry, repl->size,
 			      repl->num_entries,
 			      repl->hook_entry,
