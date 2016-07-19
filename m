From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH stable-4.1 v2] netfilter: x_tables: fix stable backport
Date: Tue, 19 Jul 2016 13:07:16 +0200 (CEST)
Message-ID: <20160719110716.C5910A0EB7@unicorn.suse.cz>
References: <20160719063308.EDD42A0B22@unicorn.suse.cz>
Cc: stable@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>,
	Takashi Iwai <tiwai@suse.de>
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:45010 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753061AbcGSLHT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2016 07:07:19 -0400
In-Reply-To: <20160719063308.EDD42A0B22@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stable-4.1 backport of mainline commit 364723410175 ("netfilter:
x_tables: validate targets of jumps") doesn't handle correctly the fact
that 4.1 kernel is missing commit 482cfc318559 ("netfilter: xtables:
avoid percpu ruleset duplication") so that t->entries is still a per-cpu
array in find_jump_target().

Use the same fix as e.g. stable-3.14 backport.

Fixes: 8163327a3a92 ("netfilter: x_tables: validate targets of jumps")
Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 net/ipv4/netfilter/arp_tables.c | 5 +++--
 net/ipv4/netfilter/ip_tables.c  | 5 +++--
 net/ipv6/netfilter/ip6_tables.c | 5 +++--
 3 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 2953ee9e5fa0..49e145640ee7 100644
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
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 3bcf28bf1525..52a883645899 100644
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
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 5254d76dfce8..b77bf6dab70c 100644
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
-- 
2.9.2
