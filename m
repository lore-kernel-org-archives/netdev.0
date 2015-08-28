From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 8/9] Revert "netfilter: xtables: compute exact size needed for jumpstack"
Date: Sat, 29 Aug 2015 00:50:16 +0200
Message-ID: <1440802217-13080-9-git-send-email-pablo@netfilter.org>
References: <1440802217-13080-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1440802217-13080-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

This reverts commit 98d1bd802cdbc8f56868fae51edec13e86b59515.

mark_source_chains will not re-visit chains, so

*filter
:INPUT ACCEPT [365:25776]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [217:45832]
:t1 - [0:0]
:t2 - [0:0]
:t3 - [0:0]
:t4 - [0:0]
-A t1 -i lo -j t2
-A t2 -i lo -j t3
-A t3 -i lo -j t4
# -A INPUT -j t4
# -A INPUT -j t3
# -A INPUT -j t2
-A INPUT -j t1
COMMIT

Will compute a chain depth of 2 if the comments are removed.
Revert back to counting the number of chains for the time being.

Reported-by: Cong Wang <cwang@twopensource.com>
Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/arp_tables.c |   19 +++++++------------
 net/ipv4/netfilter/ip_tables.c  |   28 ++++++++++------------------
 net/ipv6/netfilter/ip6_tables.c |   23 ++++++++---------------
 3 files changed, 25 insertions(+), 45 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index c416cb3..8f87fc3 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -367,13 +367,10 @@ static inline bool unconditional(const struct arpt_arp *arp)
 
 /* Figures out from what hook each rule can be called: returns 0 if
  * there are loops.  Puts hook bitmask in comefrom.
- *
- * Keeps track of largest call depth seen and stores it in newinfo->stacksize.
  */
-static int mark_source_chains(struct xt_table_info *newinfo,
+static int mark_source_chains(const struct xt_table_info *newinfo,
 			      unsigned int valid_hooks, void *entry0)
 {
-	unsigned int calldepth, max_calldepth = 0;
 	unsigned int hook;
 
 	/* No recursion; use packet counter to save back ptrs (reset
@@ -389,7 +386,6 @@ static int mark_source_chains(struct xt_table_info *newinfo,
 
 		/* Set initial back pointer. */
 		e->counters.pcnt = pos;
-		calldepth = 0;
 
 		for (;;) {
 			const struct xt_standard_target *t
@@ -444,8 +440,6 @@ static int mark_source_chains(struct xt_table_info *newinfo,
 					(entry0 + pos + size);
 				e->counters.pcnt = pos;
 				pos += size;
-				if (calldepth > 0)
-					--calldepth;
 			} else {
 				int newpos = t->verdict;
 
@@ -460,10 +454,6 @@ static int mark_source_chains(struct xt_table_info *newinfo,
 						return 0;
 					}
 
-					if (entry0 + newpos != arpt_next_entry(e) &&
-					    ++calldepth > max_calldepth)
-						max_calldepth = calldepth;
-
 					/* This a jump; chase it. */
 					duprintf("Jump rule %u -> %u\n",
 						 pos, newpos);
@@ -480,7 +470,6 @@ static int mark_source_chains(struct xt_table_info *newinfo,
 		next:
 		duprintf("Finished chain %u\n", hook);
 	}
-	newinfo->stacksize = max_calldepth;
 	return 1;
 }
 
@@ -670,6 +659,9 @@ static int translate_table(struct xt_table_info *newinfo, void *entry0,
 		if (ret != 0)
 			break;
 		++i;
+		if (strcmp(arpt_get_target(iter)->u.user.name,
+		    XT_ERROR_TARGET) == 0)
+			++newinfo->stacksize;
 	}
 	duprintf("translate_table: ARPT_ENTRY_ITERATE gives %d\n", ret);
 	if (ret != 0)
@@ -1442,6 +1434,9 @@ static int translate_compat_table(const char *name,
 			break;
 		}
 		++i;
+		if (strcmp(arpt_get_target(iter1)->u.user.name,
+		    XT_ERROR_TARGET) == 0)
+			++newinfo->stacksize;
 	}
 	if (ret) {
 		/*
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 787f99e..b0a86e7 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -443,15 +443,11 @@ ipt_do_table(struct sk_buff *skb,
 }
 
 /* Figures out from what hook each rule can be called: returns 0 if
- * there are loops.  Puts hook bitmask in comefrom.
- *
- * Keeps track of largest call depth seen and stores it in newinfo->stacksize.
- */
+   there are loops.  Puts hook bitmask in comefrom. */
 static int
-mark_source_chains(struct xt_table_info *newinfo,
+mark_source_chains(const struct xt_table_info *newinfo,
 		   unsigned int valid_hooks, void *entry0)
 {
-	unsigned int calldepth, max_calldepth = 0;
 	unsigned int hook;
 
 	/* No recursion; use packet counter to save back ptrs (reset
@@ -465,7 +461,6 @@ mark_source_chains(struct xt_table_info *newinfo,
 
 		/* Set initial back pointer. */
 		e->counters.pcnt = pos;
-		calldepth = 0;
 
 		for (;;) {
 			const struct xt_standard_target *t
@@ -527,9 +522,6 @@ mark_source_chains(struct xt_table_info *newinfo,
 					(entry0 + pos + size);
 				e->counters.pcnt = pos;
 				pos += size;
-				WARN_ON_ONCE(calldepth == 0);
-				if (calldepth > 0)
-					--calldepth;
 			} else {
 				int newpos = t->verdict;
 
@@ -543,14 +535,9 @@ mark_source_chains(struct xt_table_info *newinfo,
 								newpos);
 						return 0;
 					}
-					if (entry0 + newpos != ipt_next_entry(e) &&
-					    !(e->ip.flags & IPT_F_GOTO) &&
-					    ++calldepth > max_calldepth)
-						max_calldepth = calldepth;
-
 					/* This a jump; chase it. */
-					duprintf("Jump rule %u -> %u, calldepth %d\n",
-						 pos, newpos, calldepth);
+					duprintf("Jump rule %u -> %u\n",
+						 pos, newpos);
 				} else {
 					/* ... this is a fallthru */
 					newpos = pos + e->next_offset;
@@ -564,7 +551,6 @@ mark_source_chains(struct xt_table_info *newinfo,
 		next:
 		duprintf("Finished chain %u\n", hook);
 	}
-	newinfo->stacksize = max_calldepth;
 	return 1;
 }
 
@@ -844,6 +830,9 @@ translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
 		if (ret != 0)
 			return ret;
 		++i;
+		if (strcmp(ipt_get_target(iter)->u.user.name,
+		    XT_ERROR_TARGET) == 0)
+			++newinfo->stacksize;
 	}
 
 	if (i != repl->num_entries) {
@@ -1759,6 +1748,9 @@ translate_compat_table(struct net *net,
 		if (ret != 0)
 			break;
 		++i;
+		if (strcmp(ipt_get_target(iter1)->u.user.name,
+		    XT_ERROR_TARGET) == 0)
+			++newinfo->stacksize;
 	}
 	if (ret) {
 		/*
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 4e21f80..0771991 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -455,15 +455,11 @@ ip6t_do_table(struct sk_buff *skb,
 }
 
 /* Figures out from what hook each rule can be called: returns 0 if
- * there are loops.  Puts hook bitmask in comefrom.
- *
- * Keeps track of largest call depth seen and stores it in newinfo->stacksize.
- */
+   there are loops.  Puts hook bitmask in comefrom. */
 static int
-mark_source_chains(struct xt_table_info *newinfo,
+mark_source_chains(const struct xt_table_info *newinfo,
 		   unsigned int valid_hooks, void *entry0)
 {
-	unsigned int calldepth, max_calldepth = 0;
 	unsigned int hook;
 
 	/* No recursion; use packet counter to save back ptrs (reset
@@ -477,7 +473,6 @@ mark_source_chains(struct xt_table_info *newinfo,
 
 		/* Set initial back pointer. */
 		e->counters.pcnt = pos;
-		calldepth = 0;
 
 		for (;;) {
 			const struct xt_standard_target *t
@@ -539,8 +534,6 @@ mark_source_chains(struct xt_table_info *newinfo,
 					(entry0 + pos + size);
 				e->counters.pcnt = pos;
 				pos += size;
-				if (calldepth > 0)
-					--calldepth;
 			} else {
 				int newpos = t->verdict;
 
@@ -554,11 +547,6 @@ mark_source_chains(struct xt_table_info *newinfo,
 								newpos);
 						return 0;
 					}
-					if (entry0 + newpos != ip6t_next_entry(e) &&
-					    !(e->ipv6.flags & IP6T_F_GOTO) &&
-					    ++calldepth > max_calldepth)
-						max_calldepth = calldepth;
-
 					/* This a jump; chase it. */
 					duprintf("Jump rule %u -> %u\n",
 						 pos, newpos);
@@ -575,7 +563,6 @@ mark_source_chains(struct xt_table_info *newinfo,
 		next:
 		duprintf("Finished chain %u\n", hook);
 	}
-	newinfo->stacksize = max_calldepth;
 	return 1;
 }
 
@@ -855,6 +842,9 @@ translate_table(struct net *net, struct xt_table_info *newinfo, void *entry0,
 		if (ret != 0)
 			return ret;
 		++i;
+		if (strcmp(ip6t_get_target(iter)->u.user.name,
+		    XT_ERROR_TARGET) == 0)
+			++newinfo->stacksize;
 	}
 
 	if (i != repl->num_entries) {
@@ -1767,6 +1757,9 @@ translate_compat_table(struct net *net,
 		if (ret != 0)
 			break;
 		++i;
+		if (strcmp(ip6t_get_target(iter1)->u.user.name,
+		    XT_ERROR_TARGET) == 0)
+			++newinfo->stacksize;
 	}
 	if (ret) {
 		/*
-- 
1.7.10.4

