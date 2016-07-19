From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH stable-4.1] netfilter: x_tables: fix stable backport
Date: Tue, 19 Jul 2016 08:33:08 +0200 (CEST)
Message-ID: <20160719063308.EDD42A0B22@unicorn.suse.cz>
Cc: stable@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>,
	Takashi Iwai <tiwai@suse.de>
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stable-4.1 backport of Florian Westphal's CVE-2016-4997 fixes doesn't
handle correctly the fact that 4.1 kernel is missing commit
482cfc318559 ("netfilter: xtables: avoid percpu ruleset duplication").

Add code fragments needed for pre-4.2 kernels.

Fixes: 8163327a3a92 ("netfilter: x_tables: validate targets of jumps")
Fixes: af815d264b7e ("netfilter: x_tables: do compat validation via translate_table")
Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 net/ipv4/netfilter/arp_tables.c | 10 ++++++++--
 net/ipv4/netfilter/ip_tables.c  | 13 +++++++++----
 net/ipv6/netfilter/ip6_tables.c | 14 ++++++++++----
 3 files changed, 27 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 2953ee9e5fa0..015611cc937c 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -363,11 +363,12 @@ static inline bool unconditional(const struct arpt_entry *e)
 }
 
 static bool find_jump_target(const struct xt_table_info *t,
+			     const void *entry0,
 			     const struct arpt_entry *target)
 {
 	struct arpt_entry *iter;
 
-	xt_entry_foreach(iter, t->entries, t->size) {
+	xt_entry_foreach(iter, entry0, t->size) {
 		 if (iter == target)
 			return true;
 	}
@@ -469,7 +470,7 @@ static int mark_source_chains(const struct xt_table_info *newinfo,
 						 pos, newpos);
 					e = (struct arpt_entry *)
 						(entry0 + newpos);
-					if (!find_jump_target(newinfo, e))
+					if (!find_jump_target(newinfo, entry0, e))
 						return 0;
 				} else {
 					/* ... this is a fallthru */
@@ -1358,6 +1359,11 @@ static int translate_compat_table(struct xt_table_info **pinfo,
 	if (ret)
 		goto free_newinfo;
 
+	/* And one copy for every other CPU */
+	for_each_possible_cpu(i)
+		if (newinfo->entries[i] && newinfo->entries[i] != entry1)
+			memcpy(newinfo->entries[i], entry1, newinfo->size);
+
 	*pinfo = newinfo;
 	*pentry0 = entry1;
 	xt_free_table_info(info);
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 3bcf28bf1525..3a748d796ec1 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -439,11 +439,12 @@ ipt_do_table(struct sk_buff *skb,
 }
 
 static bool find_jump_target(const struct xt_table_info *t,
+			     const void *entry0,
 			     const struct ipt_entry *target)
 {
 	struct ipt_entry *iter;
 
-	xt_entry_foreach(iter, t->entries, t->size) {
+	xt_entry_foreach(iter, entry0, t->size) {
 		 if (iter == target)
 			return true;
 	}
@@ -549,7 +550,7 @@ mark_source_chains(const struct xt_table_info *newinfo,
 						 pos, newpos);
 					e = (struct ipt_entry *)
 						(entry0 + newpos);
-					if (!find_jump_target(newinfo, e))
+					if (!find_jump_target(newinfo, entry0, e))
 						return 0;
 				} else {
 					/* ... this is a fallthru */
@@ -1479,8 +1480,7 @@ check_compat_entry_size_and_hooks(struct compat_ipt_entry *e,
 	entry_offset = (void *)e - (void *)base;
 	j = 0;
 	xt_ematch_foreach(ematch, e) {
-		ret = compat_find_calc_match(ematch, &e->ip, e->comefrom,
-					     &off);
+		ret = compat_find_calc_match(ematch, &e->ip, e->comefrom, &off);
 		if (ret != 0)
 			goto release_matches;
 		++j;
@@ -1635,6 +1635,11 @@ translate_compat_table(struct net *net,
 	if (ret)
 		goto free_newinfo;
 
+	/* And one copy for every other CPU */
+	for_each_possible_cpu(i)
+		if (newinfo->entries[i] && newinfo->entries[i] != entry1)
+			memcpy(newinfo->entries[i], entry1, newinfo->size);
+
 	*pinfo = newinfo;
 	*pentry0 = entry1;
 	xt_free_table_info(info);
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 5254d76dfce8..1ac4bcdefc53 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -452,11 +452,12 @@ ip6t_do_table(struct sk_buff *skb,
 }
 
 static bool find_jump_target(const struct xt_table_info *t,
+			     const void *entry0,
 			     const struct ip6t_entry *target)
 {
 	struct ip6t_entry *iter;
 
-	xt_entry_foreach(iter, t->entries, t->size) {
+	xt_entry_foreach(iter, entry0, t->size) {
 		 if (iter == target)
 			return true;
 	}
@@ -562,7 +563,7 @@ mark_source_chains(const struct xt_table_info *newinfo,
 						 pos, newpos);
 					e = (struct ip6t_entry *)
 						(entry0 + newpos);
-					if (!find_jump_target(newinfo, e))
+					if (!find_jump_target(newinfo, entry0, e))
 						return 0;
 				} else {
 					/* ... this is a fallthru */
@@ -1493,8 +1494,8 @@ check_compat_entry_size_and_hooks(struct compat_ip6t_entry *e,
 	entry_offset = (void *)e - (void *)base;
 	j = 0;
 	xt_ematch_foreach(ematch, e) {
-		ret = compat_find_calc_match(ematch, &e->ipv6, e->comefrom,
-					     &off);
+		ret = compat_find_calc_match(ematch,
+					     &e->ipv6, e->comefrom, &off);
 		if (ret != 0)
 			goto release_matches;
 		++j;
@@ -1640,6 +1641,11 @@ translate_compat_table(struct net *net,
 	if (ret)
 		goto free_newinfo;
 
+	/* And one copy for every other CPU */
+	for_each_possible_cpu(i)
+		if (newinfo->entries[i] && newinfo->entries[i] != entry1)
+			memcpy(newinfo->entries[i], entry1, newinfo->size);
+
 	*pinfo = newinfo;
 	*pentry0 = entry1;
 	xt_free_table_info(info);
-- 
2.9.2
