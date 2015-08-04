From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/18] netfilter: xtables: compute exact size needed for jumpstack
Date: Tue,  4 Aug 2015 12:02:36 +0200
Message-ID: <1438682568-8346-7-git-send-email-pablo@netfilter.org>
References: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55992 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933047AbbHDJ5W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 05:57:22 -0400
In-Reply-To: <1438682568-8346-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

The {arp,ip,ip6tables} jump stack is currently sized based
on the number of user chains.

However, its rather unlikely that every user defined chain jumps to the
next, so lets use the existing loop detection logic to also track the
chain depths.

The stacksize is then set to the largest chain depth seen.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/arp_tables.c |   19 ++++++++++++-------
 net/ipv4/netfilter/ip_tables.c  |   28 ++++++++++++++++++----------
 net/ipv6/netfilter/ip6_tables.c |   23 +++++++++++++++--------
 net/netfilter/x_tables.c        |    4 ++++
 4 files changed, 49 insertions(+), 25 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 92305a1..ae6d0a1 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -372,10 +372,13 @@ static inline bool unconditional(const struct arpt_arp *arp)
 
 /* Figures out from what hook each rule can be called: returns 0 if
  * there are loops.  Puts hook bitmask in comefrom.
+ *
+ * Keeps track of largest call depth seen and stores it in newinfo->stacksize.
  */
-static int mark_source_chains(const struct xt_table_info *newinfo,
+static int mark_source_chains(struct xt_table_info *newinfo,
 			      unsigned int valid_hooks, void *entry0)
 {
+	unsigned int calldepth, max_calldepth = 0;
 	unsigned int hook;
 
 	/* No recursion; use packet counter to save back ptrs (reset
@@ -391,6 +394,7 @@ static int mark_source_chains(const struct xt_table_info *newinfo,
 
 		/* Set initial back pointer. */
 		e->counters.pcnt = pos;
+		calldepth = 0;
 
 		for (;;) {
 			const struct xt_standard_target *t
@@ -445,6 +449,8 @@ static int mark_source_chains(const struct xt_table_info *newinfo,
 					(entry0 + pos + size);
 				e->counters.pcnt = pos;
 				pos += size;
+				if (calldepth > 0)
+					--calldepth;
 			} else {
 				int newpos = t->verdict;
 
@@ -459,6 +465,10 @@ static int mark_source_chains(const struct xt_table_info *newinfo,
 						return 0;
 					}
 
+					if (entry0 + newpos != arpt_next_entry(e) &&
+					    ++calldepth > max_calldepth)
+						max_calldepth = calldepth;
+
 					/* This a jump; chase it. */
 					duprintf("Jump rule %u -> %u\n",
 						 pos, newpos);
@@ -475,6 +485,7 @@ static int mark_source_chains(const struct xt_table_info *newinfo,
 		next:
 		duprintf("Finished chain %u\n", hook);
 	}
+	newinfo->stacksize = max_calldepth;
 	return 1;
 }
 
@@ -664,9 +675,6 @@ static int translate_table(struct xt_table_info *newinfo, void *entry0,
 		if (ret != 0)
 			break;
 		++i;
-		if (strcmp(arpt_get_target(iter)->u.user.name,
-		    XT_ERROR_TARGET) == 0)
-			++newinfo->stacksize;
 	}
 	duprintf("translate_table: ARPT_ENTRY_ITERATE gives %d\n", ret);
 	if (ret != 0)
@@ -1439,9 +1447,6 @@ static int translate_compat_table(const char *name,
 			break;
 		}
 		++i;
-		if (strcmp(arpt_get_target(iter1)->u.user.name,
-		    XT_ERROR_TARGET) == 0)
-			++newinfo->stacksize;
 	}
 	if (ret) {
 		/*
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 6c72fbb..5e44b35 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -439,11 +439,15 @@ ipt_do_table(struct sk_buff *skb,
 }
 
 /* Figures out from what hook each rule can be called: returns 0 if
-   there are loops.  Puts hook bitmask in comefrom. */
+ * there are loops.  Puts hook bitmask in comefrom.
+ *
+ * Keeps track of largest call depth seen and stores it in newinfo->stacksize.
+ */
 static int
-mark_source_chains(const struct xt_table_info *newinfo,
+mark_source_chains(struct xt_table_info *newinfo,
 		   unsigned int valid_hooks, void *entry0)
 {
+	unsigned int calldepth, max_calldepth = 0;
 	unsigned int hook;
 
 	/* No recursion; use packet counter to save back ptrs (reset
@@ -457,6 +461,7 @@ mark_source_chains(const struct xt_table_info *newinfo,
 
 		/* Set initial back pointer. */
 		e->counters.pcnt = pos;
+		calldepth = 0;
 
 		for (;;) {
 			const struct xt_standard_target *t
@@ -518,6 +523,9 @@ mark_source_chains(const struct xt_table_info *newinfo,
 					(entry0 + pos + size);
 				e->counters.pcnt = pos;
 				pos += size;
+				WARN_ON_ONCE(calldepth == 0);
+				if (calldepth > 0)
+					--calldepth;
 			} else {
 				int newpos = t->verdict;
 
@@ -531,9 +539,14 @@ mark_source_chains(const struct xt_table_info *newinfo,
 								newpos);
 						return 0;
 					}
+					if (entry0 + newpos != ipt_next_entry(e) &&
+					    !(e->ip.flags & IPT_F_GOTO) &&
+					    ++calldepth > max_calldepth)
+						max_calldepth = calldepth;
+
 					/* This a jump; chase it. */
-					duprintf("Jump rule %u -> %u\n",
-						 pos, newpos);
+					duprintf("Jump rule %u -> %u, calldepth %d\n",
+						 pos, newpos, calldepth);
 				} else {
 					/* ... this is a fallthru */
 					newpos = pos + e->next_offset;
@@ -547,6 +560,7 @@ mark_source_chains(const struct xt_table_info *newinfo,
 		next:
 		duprintf("Finished chain %u\n", hook);
 	}
+	newinfo->stacksize = max_calldepth;
 	return 1;
 }
 
@@ -826,9 +840,6 @@ translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
 		if (ret != 0)
 			return ret;
 		++i;
-		if (strcmp(ipt_get_target(iter)->u.user.name,
-		    XT_ERROR_TARGET) == 0)
-			++newinfo->stacksize;
 	}
 
 	if (i != repl->num_entries) {
@@ -1744,9 +1755,6 @@ translate_compat_table(struct net *net,
 		if (ret != 0)
 			break;
 		++i;
-		if (strcmp(ipt_get_target(iter1)->u.user.name,
-		    XT_ERROR_TARGET) == 0)
-			++newinfo->stacksize;
 	}
 	if (ret) {
 		/*
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 3c35ced..baf0321 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -452,11 +452,15 @@ ip6t_do_table(struct sk_buff *skb,
 }
 
 /* Figures out from what hook each rule can be called: returns 0 if
-   there are loops.  Puts hook bitmask in comefrom. */
+ * there are loops.  Puts hook bitmask in comefrom.
+ *
+ * Keeps track of largest call depth seen and stores it in newinfo->stacksize.
+ */
 static int
-mark_source_chains(const struct xt_table_info *newinfo,
+mark_source_chains(struct xt_table_info *newinfo,
 		   unsigned int valid_hooks, void *entry0)
 {
+	unsigned int calldepth, max_calldepth = 0;
 	unsigned int hook;
 
 	/* No recursion; use packet counter to save back ptrs (reset
@@ -470,6 +474,7 @@ mark_source_chains(const struct xt_table_info *newinfo,
 
 		/* Set initial back pointer. */
 		e->counters.pcnt = pos;
+		calldepth = 0;
 
 		for (;;) {
 			const struct xt_standard_target *t
@@ -531,6 +536,8 @@ mark_source_chains(const struct xt_table_info *newinfo,
 					(entry0 + pos + size);
 				e->counters.pcnt = pos;
 				pos += size;
+				if (calldepth > 0)
+					--calldepth;
 			} else {
 				int newpos = t->verdict;
 
@@ -544,6 +551,11 @@ mark_source_chains(const struct xt_table_info *newinfo,
 								newpos);
 						return 0;
 					}
+					if (entry0 + newpos != ip6t_next_entry(e) &&
+					    !(e->ipv6.flags & IP6T_F_GOTO) &&
+					    ++calldepth > max_calldepth)
+						max_calldepth = calldepth;
+
 					/* This a jump; chase it. */
 					duprintf("Jump rule %u -> %u\n",
 						 pos, newpos);
@@ -560,6 +572,7 @@ mark_source_chains(const struct xt_table_info *newinfo,
 		next:
 		duprintf("Finished chain %u\n", hook);
 	}
+	newinfo->stacksize = max_calldepth;
 	return 1;
 }
 
@@ -839,9 +852,6 @@ translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
 		if (ret != 0)
 			return ret;
 		++i;
-		if (strcmp(ip6t_get_target(iter)->u.user.name,
-		    XT_ERROR_TARGET) == 0)
-			++newinfo->stacksize;
 	}
 
 	if (i != repl->num_entries) {
@@ -1754,9 +1764,6 @@ translate_compat_table(struct net *net,
 		if (ret != 0)
 			break;
 		++i;
-		if (strcmp(ip6t_get_target(iter1)->u.user.name,
-		    XT_ERROR_TARGET) == 0)
-			++newinfo->stacksize;
 	}
 	if (ret) {
 		/*
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index d324fe7..4db7d60 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -749,6 +749,10 @@ static int xt_jumpstack_alloc(struct xt_table_info *i)
 	if (i->jumpstack == NULL)
 		return -ENOMEM;
 
+	/* ruleset without jumps -- no stack needed */
+	if (i->stacksize == 0)
+		return 0;
+
 	i->stacksize *= xt_jumpstack_multiplier;
 	size = sizeof(void *) * i->stacksize;
 	for_each_possible_cpu(cpu) {
-- 
1.7.10.4
