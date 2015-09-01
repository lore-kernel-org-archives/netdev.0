From: Ahmed Amamou <ahmed@gandi.net>
Subject: [PATCH RFC v2 15/21] net: rbridge: add test on trill flag before flood
Date: Tue,  1 Sep 2015 17:43:10 +0200
Message-ID: <1441122196-11662-16-git-send-email-ahmed@gandi.net>
References: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Cc: William Dauchy <william@gandi.net>, Ahmed Amamou <ahmed@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:58576 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751308AbbIAPxk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 11:53:40 -0400
In-Reply-To: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

frame from ACCESS PORT can not be flooded on TRUNK port
the opposite is also true, so we add a check on trill_flag on
br_flood function an add a special call
br_flood_forward_flags and br_flood_deliver_flags for them

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
---
 net/bridge/br_forward.c | 37 ++++++++++++++++++++++++++++++++++++-
 net/bridge/br_private.h |  4 ++++
 2 files changed, 40 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index fa7bfce..c27b213 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -190,7 +190,11 @@ static void br_flood(struct net_bridge *br, struct sk_buff *skb,
 		     struct sk_buff *skb0,
 		     void (*__packet_hook)(const struct net_bridge_port *p,
 					   struct sk_buff *skb),
+#ifdef CONFIG_TRILL
+		     bool unicast, uint8_t flag)
+#else
 		     bool unicast)
+#endif
 {
 	struct net_bridge_port *p;
 	struct net_bridge_port *prev;
@@ -209,6 +213,10 @@ static void br_flood(struct net_bridge *br, struct sk_buff *skb,
 		    BR_INPUT_SKB_CB(skb)->proxyarp_replied)
 			continue;
 
+#ifdef CONFIG_TRILL
+		if (flag && !(p->trill_flag & flag))
+			continue;
+#endif
 		prev = maybe_deliver(prev, p, skb, __packet_hook);
 		if (IS_ERR(prev))
 			goto out;
@@ -228,19 +236,46 @@ out:
 		kfree_skb(skb);
 }
 
-
 /* called with rcu_read_lock */
+#ifdef CONFIG_TRILL
+void br_flood_deliver_flags(struct net_bridge *br, struct sk_buff *skb,
+			    bool unicast, uint8_t flags)
+{
+	br_flood(br, skb, NULL, __br_deliver, unicast, flags);
+}
+
+void br_flood_deliver(struct net_bridge *br, struct sk_buff *skb, bool unicast)
+{
+	br_flood_deliver_flags(br, skb, unicast, false);
+}
+
+#else
 void br_flood_deliver(struct net_bridge *br, struct sk_buff *skb, bool unicast)
 {
 	br_flood(br, skb, NULL, __br_deliver, unicast);
 }
+#endif
 
 /* called under bridge lock */
+#ifdef CONFIG_TRILL
+void br_flood_forward_flags(struct net_bridge *br, struct sk_buff *skb,
+			    struct sk_buff *skb2, bool unicast, uint8_t flags)
+{
+	br_flood(br, skb, skb2, __br_forward, unicast, flags);
+}
+
+void br_flood_forward(struct net_bridge *br, struct sk_buff *skb,
+		      struct sk_buff *skb2, bool unicast)
+{
+	br_flood_forward_flags(br, skb, skb2, unicast, false);
+}
+#else
 void br_flood_forward(struct net_bridge *br, struct sk_buff *skb,
 		      struct sk_buff *skb2, bool unicast)
 {
 	br_flood(br, skb, skb2, __br_forward, unicast);
 }
+#endif
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 /* called with rcu_read_lock */
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index a62e41e..5e622e1 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -457,6 +457,10 @@ int br_forward_finish(struct sock *sk, struct sk_buff *skb);
 void br_flood_deliver(struct net_bridge *br, struct sk_buff *skb, bool unicast);
 void br_flood_forward(struct net_bridge *br, struct sk_buff *skb,
 		      struct sk_buff *skb2, bool unicast);
+void br_flood_deliver_flags(struct net_bridge *br, struct sk_buff *skb,
+			    bool unicast, uint8_t flags);
+void br_flood_forward_flags(struct net_bridge *br, struct sk_buff *skb,
+			    struct sk_buff *skb2, bool unicast, uint8_t flags);
 
 /* br_if.c */
 void br_port_carrier_check(struct net_bridge_port *p);
-- 
2.1.4
