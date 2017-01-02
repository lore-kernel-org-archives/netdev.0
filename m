From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH nf-next 3/7] ip6tables: use match, target and data copy_to_user helpers
Date: Mon,  2 Jan 2017 17:19:42 -0500
Message-ID: <1483395586-105774-4-git-send-email-willemdebruijn.kernel@gmail.com>
References: <1483395586-105774-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net, fw@strlen.de,
        dborkman@iogearbox.net, pablo@netfilter.org,
        Willem de Bruijn <willemb@google.com>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:34545 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934261AbdABWT5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 17:19:57 -0500
In-Reply-To: <1483395586-105774-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Convert ip6tables to copying entries, matches and targets one by one,
using the xt_match_to_user and xt_target_to_user helper functions.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/ipv6/netfilter/ip6_tables.c | 21 ++++++---------------
 1 file changed, 6 insertions(+), 15 deletions(-)

diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 25a022d..1e15c54 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -855,10 +855,6 @@ copy_entries_to_user(unsigned int total_size,
 		return PTR_ERR(counters);
 
 	loc_cpu_entry = private->entries;
-	if (copy_to_user(userptr, loc_cpu_entry, total_size) != 0) {
-		ret = -EFAULT;
-		goto free_counters;
-	}
 
 	/* FIXME: use iterator macros --RR */
 	/* ... then go back and fix counters and names */
@@ -868,6 +864,10 @@ copy_entries_to_user(unsigned int total_size,
 		const struct xt_entry_target *t;
 
 		e = (struct ip6t_entry *)(loc_cpu_entry + off);
+		if (copy_to_user(userptr + off, e, sizeof(*e))) {
+			ret = -EFAULT;
+			goto free_counters;
+		}
 		if (copy_to_user(userptr + off
 				 + offsetof(struct ip6t_entry, counters),
 				 &counters[num],
@@ -881,23 +881,14 @@ copy_entries_to_user(unsigned int total_size,
 		     i += m->u.match_size) {
 			m = (void *)e + i;
 
-			if (copy_to_user(userptr + off + i
-					 + offsetof(struct xt_entry_match,
-						    u.user.name),
-					 m->u.kernel.match->name,
-					 strlen(m->u.kernel.match->name)+1)
-			    != 0) {
+			if (xt_match_to_user(m, userptr + off + i)) {
 				ret = -EFAULT;
 				goto free_counters;
 			}
 		}
 
 		t = ip6t_get_target_c(e);
-		if (copy_to_user(userptr + off + e->target_offset
-				 + offsetof(struct xt_entry_target,
-					    u.user.name),
-				 t->u.kernel.target->name,
-				 strlen(t->u.kernel.target->name)+1) != 0) {
+		if (xt_target_to_user(t, userptr + off + e->target_offset)) {
 			ret = -EFAULT;
 			goto free_counters;
 		}
-- 
2.8.0.rc3.226.g39d4020
