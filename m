From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [RFC PATCH bridge 1/5] bridge: Add vlan check to forwarding path
Date: Thu, 23 Aug 2012 15:29:51 -0400
Message-ID: <1345750195-31598-2-git-send-email-vyasevic@redhat.com>
References: <1345750195-31598-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56559 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756161Ab2HWT36 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 15:29:58 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q7NJTw9G026193
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 15:29:58 -0400
In-Reply-To: <1345750195-31598-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When forwarding packets make sure vlan matches any configured vlan for
the port.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_forward.c |   17 ++++++++++++++++-
 net/bridge/br_input.c   |    8 ++++++++
 net/bridge/br_private.h |    2 ++
 3 files changed, 26 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index e9466d4..ab81954 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -26,11 +26,26 @@ static int deliver_clone(const struct net_bridge_port *prev,
 			 void (*__packet_hook)(const struct net_bridge_port *p,
 					       struct sk_buff *skb));
 
-/* Don't forward packets to originating port or forwarding diasabled */
+/* check to see that the vlan is allowed to be forwarded on this interface */
+static inline int vlan_match(const struct net_bridge_port *p,
+			     const struct sk_buff *skb)
+{
+	unsigned long *vlan_map = rcu_dereference(p->vlan_map);
+	unsigned short vid = vlan_tx_tag_get(skb) & VLAN_VID_MASK;
+
+	/* The map keeps the vlans off by 1 so adjust for that */
+	return (vlan_map && vlan_tx_tag_present(skb) &&
+		test_bit(vid+1, vlan_map));
+}
+
+/* Don't forward packets to originating port or forwarding diasabled.
+ */
 static inline int should_deliver(const struct net_bridge_port *p,
 				 const struct sk_buff *skb)
 {
+
 	return (((p->flags & BR_HAIRPIN_MODE) || skb->dev != p->dev) &&
+		vlan_match(p, skb) &&
 		p->state == BR_STATE_FORWARDING);
 }
 
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 76f15fd..b7ca3b3 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -53,10 +53,18 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	struct net_bridge_fdb_entry *dst;
 	struct net_bridge_mdb_entry *mdst;
 	struct sk_buff *skb2;
+	unsigned long *vlan_map;
 
 	if (!p || p->state == BR_STATE_DISABLED)
 		goto drop;
 
+	/* If VLAN filter is configured on the port, make sure we accept
+	 * only traffic matching the VLAN filter.
+	 */
+	vlan_map = rcu_dereference(p->vlan_map);
+	if (vlan_map && !test_bit((skb->vlan_tci & VLAN_VID_MASK), vlan_map))
+		goto drop;
+
 	/* insert into forwarding database after filtering to avoid spoofing */
 	br = p->br;
 	br_fdb_update(br, p, eth_hdr(skb)->h_source);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index a768b24..8da90e8 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -152,6 +152,8 @@ struct net_bridge_port
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	struct netpoll			*np;
 #endif
+	unsigned long __rcu		*vlan_map;
+
 };
 
 #define br_port_exists(dev) (dev->priv_flags & IFF_BRIDGE_PORT)
-- 
1.7.7.6
