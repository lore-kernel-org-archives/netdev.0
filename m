From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next v5 05/14] bridge: Cache vlan in the cb for faster egress lookup.
Date: Wed,  9 Jan 2013 12:17:52 -0500
Message-ID: <1357751882-8619-6-git-send-email-vyasevic@redhat.com>
References: <1357751882-8619-1-git-send-email-vyasevic@redhat.com>
Cc: davem@davemloft.net, stephen@redhat.com,
	bridge@lists.linux-foundation.org, shmulik.ladkani@gmail.com,
	mst@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39746 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932129Ab3AIRSN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2013 12:18:13 -0500
In-Reply-To: <1357751882-8619-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On input, cache the pointer to the bridge vlan info, so that
on egress, we have can simply look at the port bitmap instead
of traversing a vlan list.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_forward.c |   14 ++++++++++++++
 net/bridge/br_input.c   |    6 +++++-
 net/bridge/br_private.h |    1 +
 3 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 3e9a705..d95a30f 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -30,11 +30,25 @@ bool br_allowed_egress(const struct net_port_vlans *v,
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
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 72a333c..50b97b8 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -57,6 +57,8 @@ bool br_allowed_ingress(struct net_port_vlans *v, struct sk_buff *skb)
 	struct net_port_vlan *pve;
 	u16 vid;
 
+	BR_INPUT_SKB_CB(skb)->vlan = NULL;
+
 	/* If there are no vlan in the permitted list, all packets are
 	 * permitted.
 	 */
@@ -65,8 +67,10 @@ bool br_allowed_ingress(struct net_port_vlans *v, struct sk_buff *skb)
 
 	vid = br_get_vlan(skb);
 	pve = nbp_vlan_find(v, vid);
-	if (pve)
+	if (pve) {
+		BR_INPUT_SKB_CB(skb)->vlan = rcu_dereference(pve->vlan);
 		return true;
+	}
 
 	return false;
 }
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index cf5982e..6b92118 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -330,6 +330,7 @@ static inline struct net_bridge *vlans_to_bridge(struct net_port_vlans *vlans)
 
 struct br_input_skb_cb {
 	struct net_device *brdev;
+	struct net_bridge_vlan *vlan;
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	int igmp;
 	int mrouters_only;
-- 
1.7.7.6
