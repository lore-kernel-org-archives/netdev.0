From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH 1/2] bridge: Check if vlan filtering is enabled only once.
Date: Fri, 12 Sep 2014 16:26:16 -0400
Message-ID: <1410553577-17519-2-git-send-email-vyasevic@redhat.com>
References: <1410553577-17519-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f169.google.com ([209.85.216.169]:60345 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295AbaILUco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 16:32:44 -0400
Received: by mail-qc0-f169.google.com with SMTP id r5so1441000qcx.28
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 13:32:43 -0700 (PDT)
In-Reply-To: <1410553577-17519-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bridge code checks if vlan filtering is enabled on both
ingress and egress.   When the state flip happens, it
is possible for the bridge to currently be forwarding packets
and forwarding behavior becomes non-deterministic.  Bridge
may drop packets on some interfaces, but not others.

This patch solves this by caching the filtered state of the
packet into skb_cb on ingress.  The skb_cb is guaranteed to
not be over-written between the time packet entres bridge
forwarding path and the time it leaves it.  On egress, we
can then check the cached state to see if we need to
apply filtering information.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
Please consider for stable.

 net/bridge/br_private.h |  3 +++
 net/bridge/br_vlan.c    | 14 ++++++++++----
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 62a7fa2..b6c04cb 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -309,6 +309,9 @@ struct br_input_skb_cb {
 	int igmp;
 	int mrouters_only;
 #endif
+#ifdef CONFIG_BRIDGE_VLAN_FILTERING
+	bool vlan_filtered;
+#endif
 };
 
 #define BR_INPUT_SKB_CB(__skb)	((struct br_input_skb_cb *)(__skb)->cb)
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index e1bcd65..f645197 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -125,7 +125,8 @@ struct sk_buff *br_handle_vlan(struct net_bridge *br,
 {
 	u16 vid;
 
-	if (!br->vlan_enabled)
+	/* If this packet was not filtered at input, let it pass */
+	if (!BR_INPUT_SKB_CB(skb)->vlan_filtered)
 		goto out;
 
 	/* Vlan filter table must be configured at this point.  The
@@ -164,8 +165,10 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
 	/* If VLAN filtering is disabled on the bridge, all packets are
 	 * permitted.
 	 */
-	if (!br->vlan_enabled)
+	if (!br->vlan_enabled) {
+		BR_INPUT_SKB_CB(skb)->vlan_filtered = false;
 		return true;
+	}
 
 	/* If there are no vlan in the permitted list, all packets are
 	 * rejected.
@@ -173,6 +176,7 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
 	if (!v)
 		goto drop;
 
+	BR_INPUT_SKB_CB(skb)->vlan_filtered = true;
 	proto = br->vlan_proto;
 
 	/* If vlan tx offload is disabled on bridge device and frame was
@@ -251,7 +255,8 @@ bool br_allowed_egress(struct net_bridge *br,
 {
 	u16 vid;
 
-	if (!br->vlan_enabled)
+	/* If this packet was not filtered at input, let it pass */
+	if (!BR_INPUT_SKB_CB(skb)->vlan_filtered)
 		return true;
 
 	if (!v)
@@ -270,7 +275,8 @@ bool br_should_learn(struct net_bridge_port *p, struct sk_buff *skb, u16 *vid)
 	struct net_bridge *br = p->br;
 	struct net_port_vlans *v;
 
-	if (!br->vlan_enabled)
+	/* If filtering was disabled at input, let it pass. */
+	if (!BR_INPUT_SKB_CB(skb)->vlan_filtered)
 		return true;
 
 	v = rcu_dereference(p->vlan_info);
-- 
1.9.3
