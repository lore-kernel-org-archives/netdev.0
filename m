From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next V6 05/14] bridge: Cache vlan in the cb for faster egress lookup.
Date: Wed, 16 Jan 2013 13:18:00 -0500
Message-ID: <1358360289-23249-6-git-send-email-vyasevic@redhat.com>
References: <1358360289-23249-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, davem@davemloft.net,
	shemminger@vyatta.com, mst@redhat.com, shmulik.ladkani@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35687 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756549Ab3APSST (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 13:18:19 -0500
In-Reply-To: <1358360289-23249-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On input, cache the pointer to the bridge vlan info, so that
on egress, we have can simply look at the port bitmap instead
of traversing a vlan list.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_private.h |    1 +
 net/bridge/br_vlan.c    |   20 +++++++++++++++++++-
 2 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 39e70af..7960681 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -316,6 +316,7 @@ static inline struct net_bridge *vlans_to_bridge(struct net_port_vlans *vlans)
 
 struct br_input_skb_cb {
 	struct net_device *brdev;
+	struct net_bridge_vlan *vlan;
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	int igmp;
 	int mrouters_only;
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index a4f7c15..01ebfbc 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -11,6 +11,8 @@ bool br_allowed_ingress(struct net_port_vlans *v, struct sk_buff *skb)
 	struct net_port_vlan *pve;
 	u16 vid;
 
+	BR_INPUT_SKB_CB(skb)->vlan = NULL;
+
 	/* If there are no vlan in the permitted list, all packets are
 	 * permitted.
 	 */
@@ -19,8 +21,10 @@ bool br_allowed_ingress(struct net_port_vlans *v, struct sk_buff *skb)
 
 	vid = br_get_vlan(skb);
 	pve = nbp_vlan_find(v, vid);
-	if (pve)
+	if (pve) {
+		BR_INPUT_SKB_CB(skb)->vlan = rcu_dereference(pve->vlan);
 		return true;
+	}
 
 	return false;
 }
@@ -30,11 +34,25 @@ bool br_allowed_egress(const struct net_port_vlans *v,
 		       const struct sk_buff *skb)
 {
 	struct net_port_vlan *pve;
+	struct net_bridge_vlan *vlan = NULL;
 	u16 vid;
 
 	if (list_empty(&v->vlan_list))
 		return true;
 
+	vlan = BR_INPUT_SKB_CB(skb)->vlan;
+	if (vlan) {
+		/* If we have cached VLAN information, use port_bitmap
+		 * of the vlan to make the decision
+		 */
+		if (test_bit(v->port_idx, vlan->port_bitmap))
+			return true;
+		return false;
+	}
+
+	/* We don't have cached vlan information, so we need to do
+	 * it the hard way.
+	 */
 	vid = br_get_vlan(skb);
 	pve = nbp_vlan_find(v, vid);
 	if (pve)
-- 
1.7.7.6
