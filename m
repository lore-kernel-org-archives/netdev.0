From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH resend] netfilter: make rcu read section smaller
Date: Sat, 15 Jan 2011 19:28:50 +0800
Message-ID: <1295090930-16671-2-git-send-email-xiaosuo@gmail.com>
References: <1295090930-16671-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1295090930-16671-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/ipv4/netfilter/nf_nat_core.c |   38 +++++++++++++++++++-------------------
 1 file changed, 19 insertions(+), 19 deletions(-)
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index c04787c..7300611 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -85,7 +85,7 @@ in_range(const struct nf_conntrack_tuple *tuple,
 	 const struct nf_nat_range *range)
 {
 	const struct nf_nat_protocol *proto;
-	int ret = 0;
+	int ret = 1;
 
 	/* If we are supposed to map IPs, then we must be in the
 	   range specified, otherwise let this drag us onto a new src IP. */
@@ -95,13 +95,14 @@ in_range(const struct nf_conntrack_tuple *tuple,
 			return 0;
 	}
 
-	rcu_read_lock();
-	proto = __nf_nat_proto_find(tuple->dst.protonum);
-	if (!(range->flags & IP_NAT_RANGE_PROTO_SPECIFIED) ||
-	    proto->in_range(tuple, IP_NAT_MANIP_SRC,
-			    &range->min, &range->max))
-		ret = 1;
-	rcu_read_unlock();
+	if (range->flags & IP_NAT_RANGE_PROTO_SPECIFIED) {
+		rcu_read_lock();
+		proto = __nf_nat_proto_find(tuple->dst.protonum);
+		if (!proto->in_range(tuple, IP_NAT_MANIP_SRC, &range->min,
+				     &range->max))
+			ret = 0;
+		rcu_read_unlock();
+	}
 
 	return ret;
 }
@@ -235,22 +236,21 @@ get_unique_tuple(struct nf_conntrack_tuple *tuple,
 
 	/* 3) The per-protocol part of the manip is made to map into
 	   the range to make a unique tuple. */
+	if (!(range->flags & (IP_NAT_RANGE_PROTO_RANDOM |
+			      IP_NAT_RANGE_PROTO_SPECIFIED)) &&
+	    !nf_nat_used_tuple(tuple, ct))
+		return;
 
 	rcu_read_lock();
 	proto = __nf_nat_proto_find(orig_tuple->dst.protonum);
 
 	/* Only bother mapping if it's not already in range and unique */
-	if (!(range->flags & IP_NAT_RANGE_PROTO_RANDOM)) {
-		if (range->flags & IP_NAT_RANGE_PROTO_SPECIFIED) {
-			if (proto->in_range(tuple, maniptype, &range->min,
-					    &range->max) &&
-			    (range->min.all == range->max.all ||
-			     !nf_nat_used_tuple(tuple, ct)))
-				goto out;
-		} else if (!nf_nat_used_tuple(tuple, ct)) {
-			goto out;
-		}
-	}
+	if ((range->flags & (IP_NAT_RANGE_PROTO_RANDOM |
+			     IP_NAT_RANGE_PROTO_SPECIFIED)) ==
+	    IP_NAT_RANGE_PROTO_SPECIFIED &&
+	    proto->in_range(tuple, maniptype, &range->min, &range->max) &&
+	    (range->min.all == range->max.all || !nf_nat_used_tuple(tuple, ct)))
+		goto out;
 
 	/* Last change: get protocol to try to obtain unique tuple. */
 	proto->unique_tuple(tuple, range, maniptype, ct);
