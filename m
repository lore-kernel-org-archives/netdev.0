From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 7/13] bridge: Add multicast forwarding functions
Date: Fri, 26 Feb 2010 23:35:12 +0800
Message-ID: <E1Nl2Dg-0006vx-EK@gondolin.me.apana.org.au>
References: <20100226153410.GA26419@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52521 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965143Ab0BZPfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 10:35:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bridge: Add multicast forwarding functions

This patch adds code to perform selective multicast forwarding.

We forward multicast traffic to a set of ports plus all multicast
router ports.  In order to avoid duplications among these two
sets of ports, we order all ports by the numeric value of their
pointers.  The two lists are then walked in lock-step to eliminate
duplicates.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/bridge/br_forward.c |   67 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/bridge/br_private.h |   15 ++++++++++
 2 files changed, 82 insertions(+)

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 86cd071..d61e6f7 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -186,3 +186,70 @@ void br_flood_forward(struct net_bridge *br, struct sk_buff *skb,
 {
 	br_flood(br, skb, skb2, __br_forward);
 }
+
+#ifdef CONFIG_BRIDGE_IGMP_SNOOPING
+/* called with rcu_read_lock */
+static void br_multicast_flood(struct net_bridge_mdb_entry *mdst,
+			       struct sk_buff *skb, struct sk_buff *skb0,
+			       void (*__packet_hook)(
+					const struct net_bridge_port *p,
+					struct sk_buff *skb))
+{
+	struct net_device *dev = BR_INPUT_SKB_CB(skb)->brdev;
+	struct net_bridge *br = netdev_priv(dev);
+	struct net_bridge_port *port;
+	struct net_bridge_port *lport, *rport;
+	struct net_bridge_port *prev;
+	struct net_bridge_port_group *p;
+	struct hlist_node *rp;
+
+	prev = NULL;
+
+	rp = br->router_list.first;
+	p = mdst ? mdst->ports : NULL;
+	while (p || rp) {
+		lport = p ? p->port : NULL;
+		rport = rp ? hlist_entry(rp, struct net_bridge_port, rlist) :
+			     NULL;
+
+		port = (unsigned long)lport > (unsigned long)rport ?
+		       lport : rport;
+
+		prev = maybe_deliver(prev, port, skb, __packet_hook);
+		if (IS_ERR(prev))
+			goto out;
+
+		if ((unsigned long)lport >= (unsigned long)port)
+			p = p->next;
+		if ((unsigned long)rport >= (unsigned long)port)
+			rp = rp->next;
+	}
+
+	if (!prev)
+		goto out;
+
+	if (skb0)
+		deliver_clone(prev, skb, __packet_hook);
+	else
+		__packet_hook(prev, skb);
+	return;
+
+out:
+	if (!skb0)
+		kfree_skb(skb);
+}
+
+/* called with rcu_read_lock */
+void br_multicast_deliver(struct net_bridge_mdb_entry *mdst,
+			  struct sk_buff *skb)
+{
+	br_multicast_flood(mdst, skb, NULL, __br_deliver);
+}
+
+/* called with rcu_read_lock */
+void br_multicast_forward(struct net_bridge_mdb_entry *mdst,
+			  struct sk_buff *skb, struct sk_buff *skb2)
+{
+	br_multicast_flood(mdst, skb, skb2, __br_forward);
+}
+#endif
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 0871775..f2dd411 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -294,6 +294,10 @@ extern void br_multicast_disable_port(struct net_bridge_port *port);
 extern void br_multicast_init(struct net_bridge *br);
 extern void br_multicast_open(struct net_bridge *br);
 extern void br_multicast_stop(struct net_bridge *br);
+extern void br_multicast_deliver(struct net_bridge_mdb_entry *mdst,
+				 struct sk_buff *skb);
+extern void br_multicast_forward(struct net_bridge_mdb_entry *mdst,
+				 struct sk_buff *skb, struct sk_buff *skb2);
 #else
 static inline int br_multicast_rcv(struct net_bridge *br,
 				   struct net_bridge_port *port,
@@ -335,6 +339,17 @@ static inline void br_multicast_open(struct net_bridge *br)
 static inline void br_multicast_stop(struct net_bridge *br)
 {
 }
+
+static inline void br_multicast_deliver(struct net_bridge_mdb_entry *mdst,
+					struct sk_buff *skb)
+{
+}
+
+static inline void br_multicast_forward(struct net_bridge_mdb_entry *mdst,
+					struct sk_buff *skb,
+					struct sk_buff *skb2)
+{
+}
 #endif
 
 static inline bool br_multicast_is_router(struct net_bridge *br)
