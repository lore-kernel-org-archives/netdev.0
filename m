From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/5] netfilter: nat: fix src map lookup
Date: Tue, 18 Jul 2017 12:13:57 +0200
Message-ID: <1500372839-6735-4-git-send-email-pablo@netfilter.org>
References: <1500372839-6735-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44326 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751445AbdGRKON (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Jul 2017 06:14:13 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id C9BBEA4175
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 12:14:00 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B72DCDA57F
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 12:14:00 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 742F4D1CAD
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 12:13:58 +0200 (CEST)
In-Reply-To: <1500372839-6735-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

When doing initial conversion to rhashtable I replaced the bucket
walk with a single rhashtable_lookup_fast().

When moving to rhlist I failed to properly walk the list of identical
tuples, but that is what is needed for this to work correctly.
The table contains the original tuples, so the reply tuples are all
distinct.

We currently decide that mapping is (not) in range only based on the
first entry, but in case its not we need to try the reply tuple of the
next entry until we either find an in-range mapping or we checked
all the entries.

This bug makes nat core attempt collision resolution while it might be
able to use the mapping as-is.

Fixes: 870190a9ec90 ("netfilter: nat: convert nat bysrc hash to rhashtable")
Reported-by: Jaco Kroon <jaco@uls.co.za>
Tested-by: Jaco Kroon <jaco@uls.co.za>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_nat_core.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 832c5a08d9a5..eb541786ccb7 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -222,20 +222,21 @@ find_appropriate_src(struct net *net,
 		.tuple = tuple,
 		.zone = zone
 	};
-	struct rhlist_head *hl;
+	struct rhlist_head *hl, *h;
 
 	hl = rhltable_lookup(&nf_nat_bysource_table, &key,
 			     nf_nat_bysource_params);
-	if (!hl)
-		return 0;
 
-	ct = container_of(hl, typeof(*ct), nat_bysource);
+	rhl_for_each_entry_rcu(ct, h, hl, nat_bysource) {
+		nf_ct_invert_tuplepr(result,
+				     &ct->tuplehash[IP_CT_DIR_REPLY].tuple);
+		result->dst = tuple->dst;
 
-	nf_ct_invert_tuplepr(result,
-			     &ct->tuplehash[IP_CT_DIR_REPLY].tuple);
-	result->dst = tuple->dst;
+		if (in_range(l3proto, l4proto, result, range))
+			return 1;
+	}
 
-	return in_range(l3proto, l4proto, result, range);
+	return 0;
 }
 
 /* For [FUTURE] fragmentation handling, we want the least-used
-- 
2.1.4
