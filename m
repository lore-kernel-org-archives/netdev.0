From: Florian Westphal <fw@strlen.de>
Subject: [PATCH v2 nf-next 2/2] netfilter: x_tables: don't use seqlock when fetching old counters
Date: Tue, 10 Oct 2017 23:39:45 +0200
Message-ID: <20171010213945.19074-3-fw@strlen.de>
References: <20171010213945.19074-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>, Dan Williams <dcbw@redhat.com>
To: <netdev@vger.kernel.org>, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:37050 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932254AbdJJVjy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 17:39:54 -0400
In-Reply-To: <20171010213945.19074-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

after previous commit xt_replace_table will wait until all cpus
had even seqcount (i.e., no cpu is accessing old ruleset).

Add a 'old' counter retrival version that doesn't synchronize counters.
Its not needed, the old counters are not in use anymore at this point.

This speeds up table replacement on busy systems with large tables
(and many cores).

Cc: Dan Williams <dcbw@redhat.com>
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 v2: fix Erics email address

 net/ipv4/netfilter/arp_tables.c | 22 ++++++++++++++++++++--
 net/ipv4/netfilter/ip_tables.c  | 23 +++++++++++++++++++++--
 net/ipv6/netfilter/ip6_tables.c | 22 ++++++++++++++++++++--
 3 files changed, 61 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 9e2770fd00be..f88221aebc9d 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -634,6 +634,25 @@ static void get_counters(const struct xt_table_info *t,
 	}
 }
 
+static void get_old_counters(const struct xt_table_info *t,
+			     struct xt_counters counters[])
+{
+	struct arpt_entry *iter;
+	unsigned int cpu, i;
+
+	for_each_possible_cpu(cpu) {
+		i = 0;
+		xt_entry_foreach(iter, t->entries, t->size) {
+			struct xt_counters *tmp;
+
+			tmp = xt_get_per_cpu_counter(&iter->counters, cpu);
+			ADD_COUNTER(counters[i], tmp->bcnt, tmp->pcnt);
+			++i;
+		}
+		cond_resched();
+	}
+}
+
 static struct xt_counters *alloc_counters(const struct xt_table *table)
 {
 	unsigned int countersize;
@@ -910,8 +929,7 @@ static int __do_replace(struct net *net, const char *name,
 	    (newinfo->number <= oldinfo->initial_entries))
 		module_put(t->me);
 
-	/* Get the old counters, and synchronize with replace */
-	get_counters(oldinfo, counters);
+	get_old_counters(oldinfo, counters);
 
 	/* Decrease module usage counts and free resource */
 	loc_cpu_old_entry = oldinfo->entries;
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 39286e543ee6..4cbe5e80f3bf 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -781,6 +781,26 @@ get_counters(const struct xt_table_info *t,
 	}
 }
 
+static void get_old_counters(const struct xt_table_info *t,
+			     struct xt_counters counters[])
+{
+	struct ipt_entry *iter;
+	unsigned int cpu, i;
+
+	for_each_possible_cpu(cpu) {
+		i = 0;
+		xt_entry_foreach(iter, t->entries, t->size) {
+			const struct xt_counters *tmp;
+
+			tmp = xt_get_per_cpu_counter(&iter->counters, cpu);
+			ADD_COUNTER(counters[i], tmp->bcnt, tmp->pcnt);
+			++i; /* macro does multi eval of i */
+		}
+
+		cond_resched();
+	}
+}
+
 static struct xt_counters *alloc_counters(const struct xt_table *table)
 {
 	unsigned int countersize;
@@ -1070,8 +1090,7 @@ __do_replace(struct net *net, const char *name, unsigned int valid_hooks,
 	    (newinfo->number <= oldinfo->initial_entries))
 		module_put(t->me);
 
-	/* Get the old counters, and synchronize with replace */
-	get_counters(oldinfo, counters);
+	get_old_counters(oldinfo, counters);
 
 	/* Decrease module usage counts and free resource */
 	xt_entry_foreach(iter, oldinfo->entries, oldinfo->size)
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 01bd3ee5ebc6..f06e25065a34 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -800,6 +800,25 @@ get_counters(const struct xt_table_info *t,
 	}
 }
 
+static void get_old_counters(const struct xt_table_info *t,
+			     struct xt_counters counters[])
+{
+	struct ip6t_entry *iter;
+	unsigned int cpu, i;
+
+	for_each_possible_cpu(cpu) {
+		i = 0;
+		xt_entry_foreach(iter, t->entries, t->size) {
+			const struct xt_counters *tmp;
+
+			tmp = xt_get_per_cpu_counter(&iter->counters, cpu);
+			ADD_COUNTER(counters[i], tmp->bcnt, tmp->pcnt);
+			++i;
+		}
+		cond_resched();
+	}
+}
+
 static struct xt_counters *alloc_counters(const struct xt_table *table)
 {
 	unsigned int countersize;
@@ -1090,8 +1109,7 @@ __do_replace(struct net *net, const char *name, unsigned int valid_hooks,
 	    (newinfo->number <= oldinfo->initial_entries))
 		module_put(t->me);
 
-	/* Get the old counters, and synchronize with replace */
-	get_counters(oldinfo, counters);
+	get_old_counters(oldinfo, counters);
 
 	/* Decrease module usage counts and free resource */
 	xt_entry_foreach(iter, oldinfo->entries, oldinfo->size)
-- 
2.13.6
