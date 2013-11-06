From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 1/2] net/vlan: Provide read access to the vlan egress map
Date: Wed,  6 Nov 2013 15:37:23 +0200
Message-ID: <1383745044-32575-2-git-send-email-ogerlitz@mellanox.com>
References: <1383745044-32575-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, sean.hefty@intel.com,
	eyalpe@mellanox.com, Hadar Hen Zion <hadarh@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:38915 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756546Ab3KFNhe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Nov 2013 08:37:34 -0500
In-Reply-To: <1383745044-32575-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Perry <eyalpe@mellanox.com>

Provide a method for read-only access to the vlan device egress mapping.

Do this by refactoring vlan_dev_get_egress_qos_mask() such that now it
receives as an argument the skb priority instead of pointer to the skb.

Such an access is needed for the IBoE stack where the control plane
goes through the network stack. This is an add-on step on top of commit
d4a968658c "net/route: export symbol ip_tos2prio" which allowed the RDMA-CM
to use ip_tos2prio.

Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
---
 include/linux/if_vlan.h |    9 ++++++++-
 net/8021q/vlan_dev.c    |   18 ++++++++++++------
 2 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 715c343..f3088a0 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -88,7 +88,8 @@ extern struct net_device *__vlan_find_dev_deep(struct net_device *real_dev,
 					       __be16 vlan_proto, u16 vlan_id);
 extern struct net_device *vlan_dev_real_dev(const struct net_device *dev);
 extern u16 vlan_dev_vlan_id(const struct net_device *dev);
-
+extern u16 vlan_dev_get_egress_qos_mask(struct net_device *dev,
+					u32 skprio);
 extern bool vlan_do_receive(struct sk_buff **skb);
 extern struct sk_buff *vlan_untag(struct sk_buff *skb);
 
@@ -121,6 +122,12 @@ static inline u16 vlan_dev_vlan_id(const struct net_device *dev)
 	return 0;
 }
 
+static inline u16 vlan_dev_get_egress_qos_mask(struct net_device *dev,
+					       u32 skprio)
+{
+	return 0;
+}
+
 static inline bool vlan_do_receive(struct sk_buff **skb)
 {
 	return false;
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 09bf1c3..13904a4 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -69,15 +69,15 @@ static int vlan_dev_rebuild_header(struct sk_buff *skb)
 }
 
 static inline u16
-vlan_dev_get_egress_qos_mask(struct net_device *dev, struct sk_buff *skb)
+__vlan_dev_get_egress_qos_mask(struct net_device *dev, u32 skprio)
 {
 	struct vlan_priority_tci_mapping *mp;
 
 	smp_rmb(); /* coupled with smp_wmb() in vlan_dev_set_egress_priority() */
 
-	mp = vlan_dev_priv(dev)->egress_priority_map[(skb->priority & 0xF)];
+	mp = vlan_dev_priv(dev)->egress_priority_map[(skprio & 0xF)];
 	while (mp) {
-		if (mp->priority == skb->priority) {
+		if (mp->priority == skprio) {
 			return mp->vlan_qos; /* This should already be shifted
 					      * to mask correctly with the
 					      * VLAN's TCI */
@@ -87,6 +87,12 @@ vlan_dev_get_egress_qos_mask(struct net_device *dev, struct sk_buff *skb)
 	return 0;
 }
 
+u16 vlan_dev_get_egress_qos_mask(struct net_device *dev, u32 skprio)
+{
+	return __vlan_dev_get_egress_qos_mask(dev, skprio);
+}
+EXPORT_SYMBOL(vlan_dev_get_egress_qos_mask);
+
 /*
  *	Create the VLAN header for an arbitrary protocol layer
  *
@@ -111,7 +117,7 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 		vhdr = (struct vlan_hdr *) skb_push(skb, VLAN_HLEN);
 
 		vlan_tci = vlan->vlan_id;
-		vlan_tci |= vlan_dev_get_egress_qos_mask(dev, skb);
+		vlan_tci |= __vlan_dev_get_egress_qos_mask(dev, skb->priority);
 		vhdr->h_vlan_TCI = htons(vlan_tci);
 
 		/*
@@ -168,7 +174,7 @@ static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
 	    vlan->flags & VLAN_FLAG_REORDER_HDR) {
 		u16 vlan_tci;
 		vlan_tci = vlan->vlan_id;
-		vlan_tci |= vlan_dev_get_egress_qos_mask(dev, skb);
+		vlan_tci |= __vlan_dev_get_egress_qos_mask(dev, skb->priority);
 		skb = __vlan_hwaccel_put_tag(skb, vlan->vlan_proto, vlan_tci);
 	}
 
@@ -253,7 +259,7 @@ int vlan_dev_set_egress_priority(const struct net_device *dev,
 	np->vlan_qos = vlan_qos;
 	/* Before inserting this element in hash table, make sure all its fields
 	 * are committed to memory.
-	 * coupled with smp_rmb() in vlan_dev_get_egress_qos_mask()
+	 * coupled with smp_rmb() in __vlan_dev_get_egress_qos_mask()
 	 */
 	smp_wmb();
 	vlan->egress_priority_map[skb_prio & 0xF] = np;
-- 
1.7.1
