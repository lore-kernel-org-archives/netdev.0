From: kaber@trash.net
Subject: [PATCH 3/3] netfilter: ipset: Fix the order of listing of sets
Date: Tue, 19 Apr 2011 16:51:45 +0200
Message-ID: <1303224705-17400-4-git-send-email-kaber@trash.net>
References: <1303224705-17400-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40015 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752911Ab1DSOvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 10:51:49 -0400
In-Reply-To: <1303224705-17400-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

A restoreable saving of sets requires that list:set type of sets
come last and the code part which should have taken into account
the ordering was broken. The patch fixes the listing order.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/ipset/ip_set_core.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index e88ac3c..d87e03b 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -1022,8 +1022,9 @@ ip_set_dump_start(struct sk_buff *skb, struct netlink_callback *cb)
 	if (cb->args[1] >= ip_set_max)
 		goto out;
 
-	pr_debug("args[0]: %ld args[1]: %ld\n", cb->args[0], cb->args[1]);
 	max = cb->args[0] == DUMP_ONE ? cb->args[1] + 1 : ip_set_max;
+dump_last:
+	pr_debug("args[0]: %ld args[1]: %ld\n", cb->args[0], cb->args[1]);
 	for (; cb->args[1] < max; cb->args[1]++) {
 		index = (ip_set_id_t) cb->args[1];
 		set = ip_set_list[index];
@@ -1038,8 +1039,8 @@ ip_set_dump_start(struct sk_buff *skb, struct netlink_callback *cb)
 		 * so that lists (unions of sets) are dumped last.
 		 */
 		if (cb->args[0] != DUMP_ONE &&
-		    !((cb->args[0] == DUMP_ALL) ^
-		      (set->type->features & IPSET_DUMP_LAST)))
+		    ((cb->args[0] == DUMP_ALL) ==
+		     !!(set->type->features & IPSET_DUMP_LAST)))
 			continue;
 		pr_debug("List set: %s\n", set->name);
 		if (!cb->args[2]) {
@@ -1083,6 +1084,12 @@ ip_set_dump_start(struct sk_buff *skb, struct netlink_callback *cb)
 			goto release_refcount;
 		}
 	}
+	/* If we dump all sets, continue with dumping last ones */
+	if (cb->args[0] == DUMP_ALL) {
+		cb->args[0] = DUMP_LAST;
+		cb->args[1] = 0;
+		goto dump_last;
+	}
 	goto out;
 
 nla_put_failure:
@@ -1093,11 +1100,6 @@ release_refcount:
 		pr_debug("release set %s\n", ip_set_list[index]->name);
 		ip_set_put_byindex(index);
 	}
-
-	/* If we dump all sets, continue with dumping last ones */
-	if (cb->args[0] == DUMP_ALL && cb->args[1] >= max && !cb->args[2])
-		cb->args[0] = DUMP_LAST;
-
 out:
 	if (nlh) {
 		nlmsg_end(skb, nlh);
-- 
1.7.2.3

