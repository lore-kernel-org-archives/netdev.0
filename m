From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next V4 05/13] bridge: Cache vlan in the cb for faster egress lookup.
Date: Wed, 19 Dec 2012 12:48:16 -0500
Message-ID: <1355939304-21804-6-git-send-email-vyasevic@redhat.com>
References: <1355939304-21804-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com, davem@davemloft.net, or.gerlitz@gmail.com,
	jhs@mojatatu.com, mst@redhat.com, erdnetdev@gmail.com,
	jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20477 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752652Ab2LSSRZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2012 13:17:25 -0500
In-Reply-To: <1355939304-21804-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On input, cache the pointer to the bridge vlan info, so that
on egress, we have can simply look at the port bitmap instead
of traversing a vlan list.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_device.c  |    8 ++++++++
 net/bridge/br_forward.c |   14 ++++++++++++++
 net/bridge/br_input.c   |    6 +++++-
 net/bridge/br_private.h |    1 +
 4 files changed, 28 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 9546742..57c5bac 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -30,6 +30,7 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct net_bridge_fdb_entry *dst;
 	struct net_bridge_mdb_entry *mdst;
 	struct br_cpu_netstats *brstats = this_cpu_ptr(br->stats);
+	struct net_bridge_vlan *vlan;
 
 	rcu_read_lock();
 #ifdef CONFIG_BRIDGE_NETFILTER
@@ -47,6 +48,13 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	BR_INPUT_SKB_CB(skb)->brdev = dev;
 
+	/* Any vlan transmitted by the bridge itself is permitted.
+	 * Try to cache the vlan in the CB to speed up forwarding.
+	 */
+	vlan = br_vlan_find(br, br_get_vlan(skb));
+	if (vlan)
+		BR_INPUT_SKB_CB(skb)->vlan = vlan;
+
 	skb_reset_mac_header(skb);
 	skb_pull(skb, ETH_HLEN);
 
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 0c7ffc2..4ae5f55 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -30,11 +30,25 @@ static inline bool br_allowed_egress(const struct net_bridge_port *p,
 				     const struct sk_buff *skb)
 {
 	struct net_port_vlan *pve;
+	struct net_bridge_vlan *vlan = NULL;
 	u16 vid;
 
 	if (list_empty(&p->vlan_list))
 		return true;
 
+	vlan = BR_INPUT_SKB_CB(skb)->vlan;
+	if (vlan) {
+		/* If we have cached VLAN information, use port_bitmap
+		 * of the vlan to make the decision
+		 */
+		if (test_bit(p->port_no, vlan->port_bitmap))
+			return true;
+		return false;
+	}
+
+	/* We don't have cached vlan information, so we need to do
+	 * it the hard way.
+	 */
 	vid = br_get_vlan(skb);
 	pve = nbp_vlan_find(p, vid);
 	if (pve)
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 54c0894..e475f49 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -47,6 +47,8 @@ static bool br_allowed_ingress(struct net_bridge_port *p, struct sk_buff *skb)
 	struct net_port_vlan *pve;
 	u16 vid;
 
+	BR_INPUT_SKB_CB(skb)->vlan = NULL;
+
 	/* If there are no vlan in the permitted list, all packets are
 	 * permitted.
 	 */
@@ -55,8 +57,10 @@ static bool br_allowed_ingress(struct net_bridge_port *p, struct sk_buff *skb)
 
 	vid = br_get_vlan(skb);
 	pve = nbp_vlan_find(p, vid);
-	if (pve)
+	if (pve) {
+		BR_INPUT_SKB_CB(skb)->vlan = pve->vlan;
 		return true;
+	}
 
 	return false;
 }
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 5090134..6793088 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -300,6 +300,7 @@ struct net_bridge
 
 struct br_input_skb_cb {
 	struct net_device *brdev;
+	struct net_bridge_vlan *vlan;
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	int igmp;
 	int mrouters_only;
-- 
1.7.7.6
