From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH v2 14/14] vlan: Remove accleration legacy functions.
Date: Wed, 20 Oct 2010 16:56:14 -0700
Message-ID: <1287618974-4714-15-git-send-email-jesse@nicira.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:34344 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755704Ab0JTX4o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 19:56:44 -0400
Received: by mail-vw0-f46.google.com with SMTP id 2so2600261vws.19
        for <netdev@vger.kernel.org>; Wed, 20 Oct 2010 16:56:43 -0700 (PDT)
In-Reply-To: <1287618974-4714-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This removes the explicit vlan accleration functions that acted
as shims in favor of the main receive functions that can now
handle vlans.

Signed-off-by: Jesse Gross <jesse@nicira.com>
--
This patch can only be applied once all drivers that use vlan acceleration
have been converted over to the new model.
---
 include/linux/if_vlan.h   |   63 +++------------------------------------------
 include/linux/netdevice.h |    8 -----
 net/8021q/vlan.c          |    7 +----
 net/8021q/vlan_core.c     |   25 ------------------
 4 files changed, 5 insertions(+), 98 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index a0d9786..e607256 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -74,6 +74,10 @@ static inline struct vlan_ethhdr *vlan_eth_hdr(const struct sk_buff *skb)
 /* found in socket.c */
 extern void vlan_ioctl_set(int (*hook)(struct net *, void __user *));
 
+#define vlan_tx_tag_present(__skb)	((__skb)->vlan_tci & VLAN_TAG_PRESENT)
+#define vlan_tx_tag_get(__skb)		((__skb)->vlan_tci & ~VLAN_TAG_PRESENT)
+
+#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 /* if this changes, algorithm will have to be reworked because this
  * depends on completely exhausting the VLAN identifier space.  Thus
  * it gives constant time look-up, but in many cases it wastes memory.
@@ -111,10 +115,6 @@ static inline void vlan_group_set_device(struct vlan_group *vg,
 	array[vlan_id % VLAN_GROUP_ARRAY_PART_LEN] = dev;
 }
 
-#define vlan_tx_tag_present(__skb)	((__skb)->vlan_tci & VLAN_TAG_PRESENT)
-#define vlan_tx_tag_get(__skb)		((__skb)->vlan_tci & ~VLAN_TAG_PRESENT)
-
-#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 /* Must be invoked with rcu_read_lock or with RTNL. */
 static inline struct net_device *vlan_find_dev(struct net_device *real_dev,
 					       u16 vlan_id)
@@ -130,15 +130,7 @@ static inline struct net_device *vlan_find_dev(struct net_device *real_dev,
 extern struct net_device *vlan_dev_real_dev(const struct net_device *dev);
 extern u16 vlan_dev_vlan_id(const struct net_device *dev);
 
-extern int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
-			     u16 vlan_tci, int polling);
 extern bool vlan_hwaccel_do_receive(struct sk_buff **skb);
-extern gro_result_t
-vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
-		 unsigned int vlan_tci, struct sk_buff *skb);
-extern gro_result_t
-vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
-	       unsigned int vlan_tci);
 
 #else
 static inline struct net_device *vlan_find_dev(struct net_device *real_dev,
@@ -159,61 +151,14 @@ static inline u16 vlan_dev_vlan_id(const struct net_device *dev)
 	return 0;
 }
 
-static inline int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
-				    u16 vlan_tci, int polling)
-{
-	BUG();
-	return NET_XMIT_SUCCESS;
-}
-
 static inline bool vlan_hwaccel_do_receive(struct sk_buff **skb)
 {
 	BUG();
 	return false;
 }
-
-static inline gro_result_t
-vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
-		 unsigned int vlan_tci, struct sk_buff *skb)
-{
-	return GRO_DROP;
-}
-
-static inline gro_result_t
-vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
-	       unsigned int vlan_tci)
-{
-	return GRO_DROP;
-}
 #endif
 
 /**
- * vlan_hwaccel_rx - netif_rx wrapper for VLAN RX acceleration
- * @skb: buffer
- * @grp: vlan group
- * @vlan_tci: VLAN TCI as received from the card
- */
-static inline int vlan_hwaccel_rx(struct sk_buff *skb,
-				  struct vlan_group *grp,
-				  u16 vlan_tci)
-{
-	return __vlan_hwaccel_rx(skb, grp, vlan_tci, 0);
-}
-
-/**
- * vlan_hwaccel_receive_skb - netif_receive_skb wrapper for VLAN RX acceleration
- * @skb: buffer
- * @grp: vlan group
- * @vlan_tci: VLAN TCI as received from the card
- */
-static inline int vlan_hwaccel_receive_skb(struct sk_buff *skb,
-					   struct vlan_group *grp,
-					   u16 vlan_tci)
-{
-	return __vlan_hwaccel_rx(skb, grp, vlan_tci, 1);
-}
-
-/**
  * __vlan_put_tag - regular VLAN tag inserting
  * @skb: skbuff to tag
  * @vlan_tci: VLAN TCI to insert
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ed7db7e..22c3c46 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -682,12 +682,6 @@ struct netdev_rx_queue {
  *	3. Update dev->stats asynchronously and atomically, and define
  *	   neither operation.
  *
- * void (*ndo_vlan_rx_register)(struct net_device *dev, struct vlan_group *grp);
- *	If device support VLAN receive accleration
- *	(ie. dev->features & NETIF_F_HW_VLAN_RX), then this function is called
- *	when vlan groups for the device changes.  Note: grp is NULL
- *	if no vlan's groups are being used.
- *
  * void (*ndo_vlan_rx_add_vid)(struct net_device *dev, unsigned short vid);
  *	If device support VLAN filtering (dev->features & NETIF_F_HW_VLAN_FILTER)
  *	this function is called when a VLAN id is registered.
@@ -739,8 +733,6 @@ struct net_device_ops {
 						     struct rtnl_link_stats64 *storage);
 	struct net_device_stats* (*ndo_get_stats)(struct net_device *dev);
 
-	void			(*ndo_vlan_rx_register)(struct net_device *dev,
-						        struct vlan_group *grp);
 	void			(*ndo_vlan_rx_add_vid)(struct net_device *dev,
 						       unsigned short vid);
 	void			(*ndo_vlan_rx_kill_vid)(struct net_device *dev,
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 05b867e..4e91db3 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -135,8 +135,6 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 		vlan_gvrp_uninit_applicant(real_dev);
 
 		rcu_assign_pointer(real_dev->vlgrp, NULL);
-		if (ops->ndo_vlan_rx_register)
-			ops->ndo_vlan_rx_register(real_dev, NULL);
 
 		/* Free the group, after all cpu's are done. */
 		call_rcu(&grp->rcu, vlan_rcu_free);
@@ -207,11 +205,8 @@ int register_vlan_dev(struct net_device *dev)
 	vlan_group_set_device(grp, vlan_id, dev);
 	grp->nr_vlans++;
 
-	if (ngrp) {
-		if (ops->ndo_vlan_rx_register)
-			ops->ndo_vlan_rx_register(real_dev, ngrp);
+	if (ngrp)
 		rcu_assign_pointer(real_dev->vlgrp, ngrp);
-	}
 	if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
 		ops->ndo_vlan_rx_add_vid(real_dev, vlan_id);
 
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 69b2f79..4d6a2b8 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -63,28 +63,3 @@ u16 vlan_dev_vlan_id(const struct net_device *dev)
 	return vlan_dev_info(dev)->vlan_id;
 }
 EXPORT_SYMBOL(vlan_dev_vlan_id);
-
-/* VLAN rx hw acceleration helper.  This acts like netif_{rx,receive_skb}(). */
-int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
-		      u16 vlan_tci, int polling)
-{
-	__vlan_hwaccel_put_tag(skb, vlan_tci);
-	return polling ? netif_receive_skb(skb) : netif_rx(skb);
-}
-EXPORT_SYMBOL(__vlan_hwaccel_rx);
-
-gro_result_t vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
-			      unsigned int vlan_tci, struct sk_buff *skb)
-{
-	__vlan_hwaccel_put_tag(skb, vlan_tci);
-	return napi_gro_receive(napi, skb);
-}
-EXPORT_SYMBOL(vlan_gro_receive);
-
-gro_result_t vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
-			    unsigned int vlan_tci)
-{
-	__vlan_hwaccel_put_tag(napi->skb, vlan_tci);
-	return napi_gro_frags(napi);
-}
-EXPORT_SYMBOL(vlan_gro_frags);
-- 
1.7.1

