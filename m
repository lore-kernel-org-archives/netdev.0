From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/27] arptables: use match, target and data copy_to_user helpers
Date: Fri,  3 Feb 2017 13:25:22 +0100
Message-ID: <1486124738-3013-12-git-send-email-pablo@netfilter.org>
References: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Willem de Bruijn <willemb@google.com>

Convert arptables to copying entries, matches and targets one by one,
using the xt_match_to_user and xt_target_to_user helper functions.

Signed-off-by: Willem de Bruijn <willemb@google.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/arp_tables.c | 15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index a467e1236c43..6241a81fd7f5 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -677,11 +677,6 @@ static int copy_entries_to_user(unsigned int total_size,
 		return PTR_ERR(counters);
 
 	loc_cpu_entry = private->entries;
-	/* ... then copy entire thing ... */
-	if (copy_to_user(userptr, loc_cpu_entry, total_size) != 0) {
-		ret = -EFAULT;
-		goto free_counters;
-	}
 
 	/* FIXME: use iterator macros --RR */
 	/* ... then go back and fix counters and names */
@@ -689,6 +684,10 @@ static int copy_entries_to_user(unsigned int total_size,
 		const struct xt_entry_target *t;
 
 		e = (struct arpt_entry *)(loc_cpu_entry + off);
+		if (copy_to_user(userptr + off, e, sizeof(*e))) {
+			ret = -EFAULT;
+			goto free_counters;
+		}
 		if (copy_to_user(userptr + off
 				 + offsetof(struct arpt_entry, counters),
 				 &counters[num],
@@ -698,11 +697,7 @@ static int copy_entries_to_user(unsigned int total_size,
 		}
 
 		t = arpt_get_target_c(e);
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
2.1.4

