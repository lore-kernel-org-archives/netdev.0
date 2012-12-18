From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH V2 03/12] bridge: Verify that a vlan is allowed to egress on give port
Date: Tue, 18 Dec 2012 14:00:54 -0500
Message-ID: <1355857263-31197-4-git-send-email-vyasevic@redhat.com>
References: <1355857263-31197-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com, davem@davemloft.net, or.gerlitz@gmail.com,
	jhs@mojatatu.com, mst@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24197 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753400Ab2LRTB3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2012 14:01:29 -0500
In-Reply-To: <1355857263-31197-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When bridge forwards a frame, make sure that a frame is allowed
to egress on that port.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_forward.c |   18 ++++++++++++++++++
 net/bridge/br_private.h |    1 +
 2 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 02015a5..0c7ffc2 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -26,11 +26,29 @@ static int deliver_clone(const struct net_bridge_port *prev,
 			 void (*__packet_hook)(const struct net_bridge_port *p,
 					       struct sk_buff *skb));
 
+static inline bool br_allowed_egress(const struct net_bridge_port *p,
+				     const struct sk_buff *skb)
+{
+	struct net_port_vlan *pve;
+	u16 vid;
+
+	if (list_empty(&p->vlan_list))
+		return true;
+
+	vid = br_get_vlan(skb);
+	pve = nbp_vlan_find(p, vid);
+	if (pve)
+		return true;
+
+	return false;
+}
+
 /* Don't forward packets to originating port or forwarding diasabled */
 static inline int should_deliver(const struct net_bridge_port *p,
 				 const struct sk_buff *skb)
 {
 	return (((p->flags & BR_HAIRPIN_MODE) || skb->dev != p->dev) &&
+		br_allowed_egress(p, skb) &&
 		p->state == BR_STATE_FORWARDING);
 }
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 1ba76b4..5090134 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -202,6 +202,7 @@ static inline u16 br_get_vlan(const struct sk_buff *skb)
 	if (vlan_tx_tag_present(skb))
 		return vlan_tx_tag_get(skb) & VLAN_VID_MASK;
 
+	/* Untagged and VLAN 0 traffic is handled the same way */
 	if (vlan_get_tag(skb, &tag))
 		return 0;
 
-- 
1.7.7.6
