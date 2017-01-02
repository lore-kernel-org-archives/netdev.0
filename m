From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH nf-next 4/7] arptables: use match, target and data copy_to_user helpers
Date: Mon,  2 Jan 2017 17:19:43 -0500
Message-ID: <1483395586-105774-5-git-send-email-willemdebruijn.kernel@gmail.com>
References: <1483395586-105774-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net, fw@strlen.de,
        dborkman@iogearbox.net, pablo@netfilter.org,
        Willem de Bruijn <willemb@google.com>
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:36407 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934262AbdABWT6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 17:19:58 -0500
In-Reply-To: <1483395586-105774-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Convert arptables to copying entries, matches and targets one by one,
using the xt_match_to_user and xt_target_to_user helper functions.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/ipv4/netfilter/arp_tables.c | 15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index a467e12..6241a81 100644
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
2.8.0.rc3.226.g39d4020
