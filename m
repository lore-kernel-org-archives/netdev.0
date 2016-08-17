From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH net-next V2 3/5] net_sched: flower: Avoid dissection of unmasked keys
Date: Wed, 17 Aug 2016 13:36:12 +0300
Message-ID: <1471430174-27740-4-git-send-email-hadarh@mellanox.com>
References: <1471430174-27740-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tom Herbert <tom@herbertland.com>,
	Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34308 "EHLO
	mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752371AbcHQKh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 06:37:59 -0400
In-Reply-To: <1471430174-27740-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current flower implementation checks the mask range and set all the
keys included in that range as "used_keys", even if a specific key in
the range has a zero mask.

This behavior can cause a false positive return value of
dissector_uses_key function and unnecessary dissection in
__skb_flow_dissect.

This patch checks explicitly the mask of each key and "used_keys" will
be set accordingly.

Fixes: 77b9900ef53a ('tc: introduce Flower classifier')
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_flower.c | 28 +++++++++++++---------------
 1 file changed, 13 insertions(+), 15 deletions(-)

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 5060801..0080fc0 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -404,12 +404,10 @@ static int fl_init_hashtable(struct cls_fl_head *head,
 
 #define FL_KEY_MEMBER_OFFSET(member) offsetof(struct fl_flow_key, member)
 #define FL_KEY_MEMBER_SIZE(member) (sizeof(((struct fl_flow_key *) 0)->member))
-#define FL_KEY_MEMBER_END_OFFSET(member)					\
-	(FL_KEY_MEMBER_OFFSET(member) + FL_KEY_MEMBER_SIZE(member))
 
-#define FL_KEY_IN_RANGE(mask, member)						\
-        (FL_KEY_MEMBER_OFFSET(member) <= (mask)->range.end &&			\
-         FL_KEY_MEMBER_END_OFFSET(member) >= (mask)->range.start)
+#define FL_KEY_IS_MASKED(mask, member)						\
+	memchr_inv(((char *)mask) + FL_KEY_MEMBER_OFFSET(member),		\
+		   0, FL_KEY_MEMBER_SIZE(member))				\
 
 #define FL_KEY_SET(keys, cnt, id, member)					\
 	do {									\
@@ -418,9 +416,9 @@ static int fl_init_hashtable(struct cls_fl_head *head,
 		cnt++;								\
 	} while(0);
 
-#define FL_KEY_SET_IF_IN_RANGE(mask, keys, cnt, id, member)			\
+#define FL_KEY_SET_IF_MASKED(mask, keys, cnt, id, member)			\
 	do {									\
-		if (FL_KEY_IN_RANGE(mask, member))				\
+		if (FL_KEY_IS_MASKED(mask, member))				\
 			FL_KEY_SET(keys, cnt, id, member);			\
 	} while(0);
 
@@ -432,14 +430,14 @@ static void fl_init_dissector(struct cls_fl_head *head,
 
 	FL_KEY_SET(keys, cnt, FLOW_DISSECTOR_KEY_CONTROL, control);
 	FL_KEY_SET(keys, cnt, FLOW_DISSECTOR_KEY_BASIC, basic);
-	FL_KEY_SET_IF_IN_RANGE(mask, keys, cnt,
-			       FLOW_DISSECTOR_KEY_ETH_ADDRS, eth);
-	FL_KEY_SET_IF_IN_RANGE(mask, keys, cnt,
-			       FLOW_DISSECTOR_KEY_IPV4_ADDRS, ipv4);
-	FL_KEY_SET_IF_IN_RANGE(mask, keys, cnt,
-			       FLOW_DISSECTOR_KEY_IPV6_ADDRS, ipv6);
-	FL_KEY_SET_IF_IN_RANGE(mask, keys, cnt,
-			       FLOW_DISSECTOR_KEY_PORTS, tp);
+	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
+			     FLOW_DISSECTOR_KEY_ETH_ADDRS, eth);
+	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
+			     FLOW_DISSECTOR_KEY_IPV4_ADDRS, ipv4);
+	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
+			     FLOW_DISSECTOR_KEY_IPV6_ADDRS, ipv6);
+	FL_KEY_SET_IF_MASKED(&mask->key, keys, cnt,
+			     FLOW_DISSECTOR_KEY_PORTS, tp);
 
 	skb_flow_dissector_init(&head->dissector, keys, cnt);
 }
-- 
1.8.3.1
