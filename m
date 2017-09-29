From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH RFC] flow_dissector: Add FLOW_DISSECTOR_F_FLOWER
Date: Fri, 29 Sep 2017 12:13:42 -0700
Message-ID: <20170929191343.11318-1-tom@quantonium.net>
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
        rohit@quantonium.net, Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:55922 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752432AbdI2TOD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 15:14:03 -0400
Received: by mail-pg0-f51.google.com with SMTP id b11so275506pgn.12
        for <netdev@vger.kernel.org>; Fri, 29 Sep 2017 12:14:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is RFC and would be applied after "flow_dissector:
Protocol specific flow dissector offload"

In order to maitain uAPI in flower, the FLOW_DISSECTOR_F_FLOWER flag
is added to indicate to flow_dissector that the caller is flower.
As new funtionality is addes to flow_dissector that would break
the flower uAPI, the code can be wrapped in "if (!(flags &
FLOW_DISSECTOR_F_FLOWER)).

In this patch the conditional is use around protocol specific
dissection (e.g. DPI into VXLAN) as well as the code that
enforces a depth of parsing to prevent DPI. The latter was a
recent patch that would introduce a parsing limit to flower that
did not exist before (i.e. would break uAPI).

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 include/net/flow_dissector.h |  1 +
 net/core/flow_dissector.c    | 17 +++++++++++------
 net/sched/cls_flow.c         |  3 ++-
 3 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index ad75bbfd1c9c..ca315107d147 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -214,6 +214,7 @@ enum flow_dissector_key_id {
 #define FLOW_DISSECTOR_F_STOP_AT_FLOW_LABEL	BIT(2)
 #define FLOW_DISSECTOR_F_STOP_AT_ENCAP		BIT(3)
 #define FLOW_DISSECTOR_F_STOP_AT_L4		BIT(4)
+#define FLOW_DISSECTOR_F_FLOWER			BIT(5)
 
 struct flow_dissector_key {
 	enum flow_dissector_key_id key_id;
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 84b8eb1f6664..a4d5843ec34e 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -383,8 +383,11 @@ __skb_flow_dissect_ipv6(const struct sk_buff *skb,
  */
 #define MAX_FLOW_DISSECT_HDRS	15
 
-static bool skb_flow_dissect_allowed(int *num_hdrs)
+static bool skb_flow_dissect_allowed(int *num_hdrs, unsigned int flags)
 {
+	if (flags & FLOW_DISSECTOR_F_FLOWER)
+		return true;
+
 	++*num_hdrs;
 
 	return (*num_hdrs <= MAX_FLOW_DISSECT_HDRS);
@@ -722,7 +725,8 @@ bool __skb_flow_dissect(struct sk_buff *skb,
 		break;
 
 	default:
-		fdret = flow_dissect_by_type(skb, proto, key_control,
+		if (!(flags & FLOW_DISSECTOR_F_FLOWER))
+			fdret = flow_dissect_by_type(skb, proto, key_control,
 					     flow_dissector,
 					     target_container,
 					     data, &proto, &ip_proto, &nhoff,
@@ -735,7 +739,7 @@ bool __skb_flow_dissect(struct sk_buff *skb,
 	case FLOW_DISSECT_RET_OUT_GOOD:
 		goto out_good;
 	case FLOW_DISSECT_RET_PROTO_AGAIN:
-		if (skb_flow_dissect_allowed(&num_hdrs))
+		if (skb_flow_dissect_allowed(&num_hdrs, flags))
 			goto proto_again;
 		goto out_good;
 	case FLOW_DISSECT_RET_CONTINUE:
@@ -843,7 +847,8 @@ bool __skb_flow_dissect(struct sk_buff *skb,
 		break;
 
 	default:
-		fdret = flow_dissect_by_type_proto(skb, proto,
+		if (!(flags & FLOW_DISSECTOR_F_FLOWER))
+			fdret = flow_dissect_by_type_proto(skb, proto,
 						ip_proto, key_control,
 						flow_dissector,
 						target_container,
@@ -872,11 +877,11 @@ bool __skb_flow_dissect(struct sk_buff *skb,
 	/* Process result of IP proto processing */
 	switch (fdret) {
 	case FLOW_DISSECT_RET_PROTO_AGAIN:
-		if (skb_flow_dissect_allowed(&num_hdrs))
+		if (skb_flow_dissect_allowed(&num_hdrs, flags))
 			goto proto_again;
 		break;
 	case FLOW_DISSECT_RET_IPPROTO_AGAIN:
-		if (skb_flow_dissect_allowed(&num_hdrs))
+		if (skb_flow_dissect_allowed(&num_hdrs, flags))
 			goto ip_proto_again;
 		break;
 	case FLOW_DISSECT_RET_OUT_GOOD:
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 2a3a60ec5b86..ad4ac503697e 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -315,7 +315,8 @@ static int flow_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 
 		keymask = f->keymask;
 		if (keymask & FLOW_KEYS_NEEDED)
-			skb_flow_dissect_flow_keys(skb, &flow_keys, 0);
+			skb_flow_dissect_flow_keys(skb, &flow_keys,
+						   FLOW_DISSECTOR_F_FLOWER);
 
 		for (n = 0; n < f->nkeys; n++) {
 			key = ffs(keymask) - 1;
-- 
2.11.0
