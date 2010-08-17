From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH resend] netfilter: nf_nat_core: don't check if the tuple is used if there is no other choice
Date: Tue, 17 Aug 2010 15:21:36 +0800
Message-ID: <1282029696-3028-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eliminate nf_nat_used_tuple() to save some CPU cycles when there is no other
choice.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/ipv4/netfilter/nf_nat_core.c |   16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index 037a3a6..c370b21 100644
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
