From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 14/25] netfilter: x_tables: speed up jump target validation
Date: Sat, 23 Jul 2016 13:08:28 +0200
Message-ID: <1469272119-29942-15-git-send-email-pablo@netfilter.org>
References: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35924 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751335AbcGWLJc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2016 07:09:32 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 6FADBE7DA2
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:30 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 53EB7FF2C7
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:30 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id F3581FAB5B
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:24 +0200 (CEST)
In-Reply-To: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

The dummy ruleset I used to test the original validation change was broken,
most rules were unreachable and were not tested by mark_source_chains().

In some cases rulesets that used to load in a few seconds now require
several minutes.

sample ruleset that shows the behaviour:

echo "*filter"
for i in $(seq 0 100000);do
        printf ":chain_%06x - [0:0]\n" $i
done
for i in $(seq 0 100000);do
   printf -- "-A INPUT -j chain_%06x\n" $i
   printf -- "-A INPUT -j chain_%06x\n" $i
   printf -- "-A INPUT -j chain_%06x\n" $i
done
echo COMMIT

[ pipe result into iptables-restore ]

This ruleset will be about 74mbyte in size, with ~500k searches
though all 500k[1] rule entries. iptables-restore will take forever
(gave up after 10 minutes)

Instead of always searching the entire blob for a match, fill an
array with the start offsets of every single ipt_entry struct,
then do a binary search to check if the jump target is present or not.

After this change ruleset restore times get again close to what one
gets when reverting 36472341017529e (~3 seconds on my workstation).

[1] every user-defined rule gets an implicit RETURN, so we get
300k jumps + 100k userchains + 100k returns -> 500k rule entries

Fixes: 36472341017529e ("netfilter: x_tables: validate targets of jumps")
Reported-by: Jeff Wu <wujiafu@gmail.com>
Tested-by: Jeff Wu <wujiafu@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/x_tables.h |  4 +++
 net/ipv4/netfilter/arp_tables.c    | 47 ++++++++++++++++++-----------------
 net/ipv4/netfilter/ip_tables.c     | 45 ++++++++++++++++++----------------
 net/ipv6/netfilter/ip6_tables.c    | 45 ++++++++++++++++++----------------
 net/netfilter/x_tables.c           | 50 ++++++++++++++++++++++++++++++++++++++
 5 files changed, 127 insertions(+), 64 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index e94e81a..2ad1a2b 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -250,6 +250,10 @@ int xt_check_entry_offsets(const void *base, const char *elems,
 			   unsigned int target_offset,
 			   unsigned int next_offset);
 
+unsigned int *xt_alloc_entry_offsets(unsigned int size);
+bool xt_find_jump_offset(const unsigned int *offsets,
+			 unsigned int target, unsigned int size);
+
 int xt_check_match(struct xt_mtchk_param *, unsigned int size, u_int8_t proto,
 		   bool inv_proto);
 int xt_check_target(struct xt_tgchk_param *, unsigned int size, u_int8_t proto,
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index c8dd9e2..b31df59 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -299,23 +299,12 @@ static inline bool unconditional(const struct arpt_entry *e)
 	       memcmp(&e->arp, &uncond, sizeof(uncond)) == 0;
 }
 
-static bool find_jump_target(const struct xt_table_info *t,
-			     const struct arpt_entry *target)
-{
-	struct arpt_entry *iter;
-
-	xt_entry_foreach(iter, t->entries, t->size) {
-		 if (iter == target)
-			return true;
-	}
-	return false;
-}
-
 /* Figures out from what hook each rule can be called: returns 0 if
  * there are loops.  Puts hook bitmask in comefrom.
  */
 static int mark_source_chains(const struct xt_table_info *newinfo,
-			      unsigned int valid_hooks, void *entry0)
+			      unsigned int valid_hooks, void *entry0,
+			      unsigned int *offsets)
 {
 	unsigned int hook;
 
@@ -388,10 +377,11 @@ static int mark_source_chains(const struct xt_table_info *newinfo,
 					   XT_STANDARD_TARGET) == 0 &&
 				    newpos >= 0) {
 					/* This a jump; chase it. */
+					if (!xt_find_jump_offset(offsets, newpos,
+								 newinfo->number))
+						return 0;
 					e = (struct arpt_entry *)
 						(entry0 + newpos);
-					if (!find_jump_target(newinfo, e))
-						return 0;
 				} else {
 					/* ... this is a fallthru */
 					newpos = pos + e->next_offset;
@@ -543,6 +533,7 @@ static int translate_table(struct xt_table_info *newinfo, void *entry0,
 			   const struct arpt_replace *repl)
 {
 	struct arpt_entry *iter;
+	unsigned int *offsets;
 	unsigned int i;
 	int ret = 0;
 
@@ -555,6 +546,9 @@ static int translate_table(struct xt_table_info *newinfo, void *entry0,
 		newinfo->underflow[i] = 0xFFFFFFFF;
 	}
 
+	offsets = xt_alloc_entry_offsets(newinfo->number);
+	if (!offsets)
+		return -ENOMEM;
 	i = 0;
 
 	/* Walk through entries, checking offsets. */
@@ -565,17 +559,20 @@ static int translate_table(struct xt_table_info *newinfo, void *entry0,
 						 repl->underflow,
 						 repl->valid_hooks);
 		if (ret != 0)
-			break;
+			goto out_free;
+		if (i < repl->num_entries)
+			offsets[i] = (void *)iter - entry0;
 		++i;
 		if (strcmp(arpt_get_target(iter)->u.user.name,
 		    XT_ERROR_TARGET) == 0)
 			++newinfo->stacksize;
 	}
 	if (ret != 0)
-		return ret;
+		goto out_free;
 
+	ret = -EINVAL;
 	if (i != repl->num_entries)
-		return -EINVAL;
+		goto out_free;
 
 	/* Check hooks all assigned */
 	for (i = 0; i < NF_ARP_NUMHOOKS; i++) {
@@ -583,13 +580,16 @@ static int translate_table(struct xt_table_info *newinfo, void *entry0,
 		if (!(repl->valid_hooks & (1 << i)))
 			continue;
 		if (newinfo->hook_entry[i] == 0xFFFFFFFF)
-			return -EINVAL;
+			goto out_free;
 		if (newinfo->underflow[i] == 0xFFFFFFFF)
-			return -EINVAL;
+			goto out_free;
 	}
 
-	if (!mark_source_chains(newinfo, repl->valid_hooks, entry0))
-		return -ELOOP;
+	if (!mark_source_chains(newinfo, repl->valid_hooks, entry0, offsets)) {
+		ret = -ELOOP;
+		goto out_free;
+	}
+	kvfree(offsets);
 
 	/* Finally, each sanity check must pass */
 	i = 0;
@@ -610,6 +610,9 @@ static int translate_table(struct xt_table_info *newinfo, void *entry0,
 	}
 
 	return ret;
+ out_free:
+	kvfree(offsets);
+	return ret;
 }
 
 static void get_counters(const struct xt_table_info *t,
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index f0df66f..f993545 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -373,23 +373,12 @@ ipt_do_table(struct sk_buff *skb,
 	else return verdict;
 }
 
-static bool find_jump_target(const struct xt_table_info *t,
-			     const struct ipt_entry *target)
-{
-	struct ipt_entry *iter;
-
-	xt_entry_foreach(iter, t->entries, t->size) {
-		 if (iter == target)
-			return true;
-	}
-	return false;
-}
-
 /* Figures out from what hook each rule can be called: returns 0 if
    there are loops.  Puts hook bitmask in comefrom. */
 static int
 mark_source_chains(const struct xt_table_info *newinfo,
-		   unsigned int valid_hooks, void *entry0)
+		   unsigned int valid_hooks, void *entry0,
+		   unsigned int *offsets)
 {
 	unsigned int hook;
 
@@ -458,10 +447,11 @@ mark_source_chains(const struct xt_table_info *newinfo,
 					   XT_STANDARD_TARGET) == 0 &&
 				    newpos >= 0) {
 					/* This a jump; chase it. */
+					if (!xt_find_jump_offset(offsets, newpos,
+								 newinfo->number))
+						return 0;
 					e = (struct ipt_entry *)
 						(entry0 + newpos);
-					if (!find_jump_target(newinfo, e))
-						return 0;
 				} else {
 					/* ... this is a fallthru */
 					newpos = pos + e->next_offset;
@@ -694,6 +684,7 @@ translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
 		const struct ipt_replace *repl)
 {
 	struct ipt_entry *iter;
+	unsigned int *offsets;
 	unsigned int i;
 	int ret = 0;
 
@@ -706,6 +697,9 @@ translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
 		newinfo->underflow[i] = 0xFFFFFFFF;
 	}
 
+	offsets = xt_alloc_entry_offsets(newinfo->number);
+	if (!offsets)
+		return -ENOMEM;
 	i = 0;
 	/* Walk through entries, checking offsets. */
 	xt_entry_foreach(iter, entry0, newinfo->size) {
@@ -715,15 +709,18 @@ translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
 						 repl->underflow,
 						 repl->valid_hooks);
 		if (ret != 0)
-			return ret;
+			goto out_free;
+		if (i < repl->num_entries)
+			offsets[i] = (void *)iter - entry0;
 		++i;
 		if (strcmp(ipt_get_target(iter)->u.user.name,
 		    XT_ERROR_TARGET) == 0)
 			++newinfo->stacksize;
 	}
 
+	ret = -EINVAL;
 	if (i != repl->num_entries)
-		return -EINVAL;
+		goto out_free;
 
 	/* Check hooks all assigned */
 	for (i = 0; i < NF_INET_NUMHOOKS; i++) {
@@ -731,13 +728,16 @@ translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
 		if (!(repl->valid_hooks & (1 << i)))
 			continue;
 		if (newinfo->hook_entry[i] == 0xFFFFFFFF)
-			return -EINVAL;
+			goto out_free;
 		if (newinfo->underflow[i] == 0xFFFFFFFF)
-			return -EINVAL;
+			goto out_free;
 	}
 
-	if (!mark_source_chains(newinfo, repl->valid_hooks, entry0))
-		return -ELOOP;
+	if (!mark_source_chains(newinfo, repl->valid_hooks, entry0, offsets)) {
+		ret = -ELOOP;
+		goto out_free;
+	}
+	kvfree(offsets);
 
 	/* Finally, each sanity check must pass */
 	i = 0;
@@ -758,6 +758,9 @@ translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
 	}
 
 	return ret;
+ out_free:
+	kvfree(offsets);
+	return ret;
 }
 
 static void
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 61ed950..552fac2 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -402,23 +402,12 @@ ip6t_do_table(struct sk_buff *skb,
 	else return verdict;
 }
 
-static bool find_jump_target(const struct xt_table_info *t,
-			     const struct ip6t_entry *target)
-{
-	struct ip6t_entry *iter;
-
-	xt_entry_foreach(iter, t->entries, t->size) {
-		 if (iter == target)
-			return true;
-	}
-	return false;
-}
-
 /* Figures out from what hook each rule can be called: returns 0 if
    there are loops.  Puts hook bitmask in comefrom. */
 static int
 mark_source_chains(const struct xt_table_info *newinfo,
-		   unsigned int valid_hooks, void *entry0)
+		   unsigned int valid_hooks, void *entry0,
+		   unsigned int *offsets)
 {
 	unsigned int hook;
 
@@ -487,10 +476,11 @@ mark_source_chains(const struct xt_table_info *newinfo,
 					   XT_STANDARD_TARGET) == 0 &&
 				    newpos >= 0) {
 					/* This a jump; chase it. */
+					if (!xt_find_jump_offset(offsets, newpos,
+								 newinfo->number))
+						return 0;
 					e = (struct ip6t_entry *)
 						(entry0 + newpos);
-					if (!find_jump_target(newinfo, e))
-						return 0;
 				} else {
 					/* ... this is a fallthru */
 					newpos = pos + e->next_offset;
@@ -724,6 +714,7 @@ translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
 		const struct ip6t_replace *repl)
 {
 	struct ip6t_entry *iter;
+	unsigned int *offsets;
 	unsigned int i;
 	int ret = 0;
 
@@ -736,6 +727,9 @@ translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
 		newinfo->underflow[i] = 0xFFFFFFFF;
 	}
 
+	offsets = xt_alloc_entry_offsets(newinfo->number);
+	if (!offsets)
+		return -ENOMEM;
 	i = 0;
 	/* Walk through entries, checking offsets. */
 	xt_entry_foreach(iter, entry0, newinfo->size) {
@@ -745,15 +739,18 @@ translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
 						 repl->underflow,
 						 repl->valid_hooks);
 		if (ret != 0)
-			return ret;
+			goto out_free;
+		if (i < repl->num_entries)
+			offsets[i] = (void *)iter - entry0;
 		++i;
 		if (strcmp(ip6t_get_target(iter)->u.user.name,
 		    XT_ERROR_TARGET) == 0)
 			++newinfo->stacksize;
 	}
 
+	ret = -EINVAL;
 	if (i != repl->num_entries)
-		return -EINVAL;
+		goto out_free;
 
 	/* Check hooks all assigned */
 	for (i = 0; i < NF_INET_NUMHOOKS; i++) {
@@ -761,13 +758,16 @@ translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
 		if (!(repl->valid_hooks & (1 << i)))
 			continue;
 		if (newinfo->hook_entry[i] == 0xFFFFFFFF)
-			return -EINVAL;
+			goto out_free;
 		if (newinfo->underflow[i] == 0xFFFFFFFF)
-			return -EINVAL;
+			goto out_free;
 	}
 
-	if (!mark_source_chains(newinfo, repl->valid_hooks, entry0))
-		return -ELOOP;
+	if (!mark_source_chains(newinfo, repl->valid_hooks, entry0, offsets)) {
+		ret = -ELOOP;
+		goto out_free;
+	}
+	kvfree(offsets);
 
 	/* Finally, each sanity check must pass */
 	i = 0;
@@ -788,6 +788,9 @@ translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
 	}
 
 	return ret;
+ out_free:
+	kvfree(offsets);
+	return ret;
 }
 
 static void
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index fe0e2db..e0aa7c1 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -702,6 +702,56 @@ int xt_check_entry_offsets(const void *base,
 }
 EXPORT_SYMBOL(xt_check_entry_offsets);
 
+/**
+ * xt_alloc_entry_offsets - allocate array to store rule head offsets
+ *
+ * @size: number of entries
+ *
+ * Return: NULL or kmalloc'd or vmalloc'd array
+ */
+unsigned int *xt_alloc_entry_offsets(unsigned int size)
+{
+	unsigned int *off;
+
+	off = kcalloc(size, sizeof(unsigned int), GFP_KERNEL | __GFP_NOWARN);
+
+	if (off)
+		return off;
+
+	if (size < (SIZE_MAX / sizeof(unsigned int)))
+		off = vmalloc(size * sizeof(unsigned int));
+
+	return off;
+}
+EXPORT_SYMBOL(xt_alloc_entry_offsets);
+
+/**
+ * xt_find_jump_offset - check if target is a valid jump offset
+ *
+ * @offsets: array containing all valid rule start offsets of a rule blob
+ * @target: the jump target to search for
+ * @size: entries in @offset
+ */
+bool xt_find_jump_offset(const unsigned int *offsets,
+			 unsigned int target, unsigned int size)
+{
+	int m, low = 0, hi = size;
+
+	while (hi > low) {
+		m = (low + hi) / 2u;
+
+		if (offsets[m] > target)
+			hi = m;
+		else if (offsets[m] < target)
+			low = m + 1;
+		else
+			return true;
+	}
+
+	return false;
+}
+EXPORT_SYMBOL(xt_find_jump_offset);
+
 int xt_check_target(struct xt_tgchk_param *par,
 		    unsigned int size, u_int8_t proto, bool inv_proto)
 {
-- 
2.1.4
