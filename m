From: kaber@trash.net
Subject: [PATCH 03/72] netfilter: nf_nat_core: don't check if the tuple is used if there is no other choice
Date: Thu, 21 Oct 2010 17:18:50 +0200
Message-ID: <1287674399-31455-4-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59985 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752123Ab0JUPUC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:20:02 -0400
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>

Eliminate nf_nat_used_tuple() to save some CPU cycles when there is no
other choice.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/nf_nat_core.c |   16 +++++++++++-----
 1 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index 8c8632d..2c084b3 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -262,11 +262,17 @@ get_unique_tuple(struct nf_conntrack_tuple *tuple,
 	proto = __nf_nat_proto_find(orig_tuple->dst.protonum);
 
 	/* Only bother mapping if it's not already in range and unique */
-	if (!(range->flags & IP_NAT_RANGE_PROTO_RANDOM) &&
-	    (!(range->flags & IP_NAT_RANGE_PROTO_SPECIFIED) ||
-	     proto->in_range(tuple, maniptype, &range->min, &range->max)) &&
-	    !nf_nat_used_tuple(tuple, ct))
-		goto out;
+	if (!(range->flags & IP_NAT_RANGE_PROTO_RANDOM)) {
+		if (range->flags & IP_NAT_RANGE_PROTO_SPECIFIED) {
+			if (proto->in_range(tuple, maniptype, &range->min,
+					    &range->max) &&
+			    (range->min.all == range->max.all ||
+			     !nf_nat_used_tuple(tuple, ct)))
+				goto out;
+		} else if (!nf_nat_used_tuple(tuple, ct)) {
+			goto out;
+		}
+	}
 
 	/* Last change: get protocol to try to obtain unique tuple. */
 	proto->unique_tuple(tuple, range, maniptype, ct);
-- 
1.7.1

