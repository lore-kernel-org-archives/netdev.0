From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/27] iptables: use match, target and data copy_to_user helpers
Date: Fri,  3 Feb 2017 13:25:20 +0100
Message-ID: <1486124738-3013-10-git-send-email-pablo@netfilter.org>
References: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58918 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753230AbdBCM2i (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 07:28:38 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id C7850C1073
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:36 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B1B94DA817
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:36 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A0678DA84F
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 13:28:34 +0100 (CET)
In-Reply-To: <1486124738-3013-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Convert iptables to copying entries, matches and targets one by one,
using the xt_match_to_user and xt_target_to_user helper functions.

Signed-off-by: Willem de Bruijn <willemb@google.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter/ip_tables.c | 21 ++++++---------------
 1 file changed, 6 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 91656a1d8fbd..384b85713e06 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -826,10 +826,6 @@ copy_entries_to_user(unsigned int total_size,
 		return PTR_ERR(counters);
 
 	loc_cpu_entry = private->entries;
-	if (copy_to_user(userptr, loc_cpu_entry, total_size) != 0) {
-		ret = -EFAULT;
-		goto free_counters;
-	}
 
 	/* FIXME: use iterator macros --RR */
 	/* ... then go back and fix counters and names */
@@ -839,6 +835,10 @@ copy_entries_to_user(unsigned int total_size,
 		const struct xt_entry_target *t;
 
 		e = (struct ipt_entry *)(loc_cpu_entry + off);
+		if (copy_to_user(userptr + off, e, sizeof(*e))) {
+			ret = -EFAULT;
+			goto free_counters;
+		}
 		if (copy_to_user(userptr + off
 				 + offsetof(struct ipt_entry, counters),
 				 &counters[num],
@@ -852,23 +852,14 @@ copy_entries_to_user(unsigned int total_size,
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
 
 		t = ipt_get_target_c(e);
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
