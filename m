From: Ahmed Amamou <ahmed@gandi.net>
Subject: [RFC PATCH 17/24] net: rbridge: Add test on trill flag before flood
Date: Wed, 24 Sep 2014 17:52:13 +0200
Message-ID: <1411573940-14079-18-git-send-email-ahmed@gandi.net>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Cc: william@gandi.net, f.cachereul@alphalink.fr,
	Ahmed Amamou <ahmed@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:44435 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751593AbaIXQDK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2014 12:03:10 -0400
In-Reply-To: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

frame from ACCESS PORT can not be flooded on TRUNK port
the opposite is also true, so we add a check on trill_flag on
br_flood function an add a special call
br_flood_forward_flags and br_flood_deliver_flags for them

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
---
 net/bridge/br_forward.c | 38 ++++++++++++++++++++++++++++++++++++++
 net/bridge/br_private.h |  4 ++++
 2 files changed, 42 insertions(+)

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 056b67b..a8b3c5d 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -170,7 +170,11 @@ static void br_flood(struct net_bridge *br, struct sk_buff *skb,
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
@@ -181,6 +185,10 @@ static void br_flood(struct net_bridge *br, struct sk_buff *skb,
 		/* Do not flood unicast traffic to ports that turn it off */
 		if (unicast && !(p->flags & BR_FLOOD))
 			continue;
+#ifdef CONFIG_TRILL
+		if (flag  && ! (p->trill_flag & flag))
+			continue;
+#endif
 		prev = maybe_deliver(prev, p, skb, __packet_hook);
 		if (IS_ERR(prev))
 			goto out;
@@ -202,17 +210,47 @@ out:
 
 
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
+
+
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 /* called with rcu_read_lock */
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 37456cf..152545e 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -449,6 +449,10 @@ int br_forward_finish(struct sk_buff *skb);
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
1.9.1
