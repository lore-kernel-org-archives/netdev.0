From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH v2 05/14] vlan: Avoid hash table lookup to find group.
Date: Wed, 20 Oct 2010 16:56:05 -0700
Message-ID: <1287618974-4714-6-git-send-email-jesse@nicira.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:59370 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753620Ab0JTX42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 19:56:28 -0400
Received: by mail-qy0-f174.google.com with SMTP id 12so1775911qyk.19
        for <netdev@vger.kernel.org>; Wed, 20 Oct 2010 16:56:28 -0700 (PDT)
In-Reply-To: <1287618974-4714-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A struct net_device always maps to zero or one vlan groups and we
always know the device when we are looking up a group.  We currently
do a hash table lookup on the device to find the group but it is
much simpler to just store a pointer.

Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 include/linux/if_vlan.h   |   19 +++++++++++++
 include/linux/netdevice.h |    5 +++-
 net/8021q/vlan.c          |   64 +++++++--------------------------------------
 net/8021q/vlan.h          |   17 ------------
 net/8021q/vlan_dev.c      |    2 +-
 5 files changed, 34 insertions(+), 73 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 494cce8..4047781 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -16,6 +16,7 @@
 #ifdef __KERNEL__
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/rtnetlink.h>
 
 #define VLAN_HLEN	4		/* The additional bytes (on top of the Ethernet header)
 					 * that VLAN requires.
@@ -114,6 +115,18 @@ static inline void vlan_group_set_device(struct vlan_group *vg,
 #define vlan_tx_tag_get(__skb)		((__skb)->vlan_tci & ~VLAN_TAG_PRESENT)
 
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+/* Must be invoked with rcu_read_lock or with RTNL. */
+static inline struct net_device *vlan_find_dev(struct net_device *real_dev,
+					       u16 vlan_id)
+{
+	struct vlan_group *grp = rcu_dereference_rtnl(real_dev->vlgrp);
+
+	if (grp)
+		return vlan_group_get_device(grp, vlan_id);
+
+	return NULL;
+}
+
 extern struct net_device *vlan_dev_real_dev(const struct net_device *dev);
 extern u16 vlan_dev_vlan_id(const struct net_device *dev);
 
@@ -128,6 +141,12 @@ vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
 	       unsigned int vlan_tci);
 
 #else
+static inline struct net_device *vlan_find_dev(struct net_device *real_dev,
+					       u16 vlan_id)
+{
+	return NULL;
+}
+
 static inline struct net_device *vlan_dev_real_dev(const struct net_device *dev)
 {
 	BUG();
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2861565..9c78312 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -942,7 +942,10 @@ struct net_device {
 
 
 	/* Protocol specific pointers */
-	
+
+#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+	struct vlan_group	*vlgrp;		/* VLAN group */
+#endif
 #ifdef CONFIG_NET_DSA
 	void			*dsa_ptr;	/* dsa specific data */
 #endif
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 54f22d8..f862dcc 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -44,9 +44,6 @@
 
 int vlan_net_id __read_mostly;
 
-/* Our listing of VLAN group(s) */
-static struct hlist_head vlan_group_hash[VLAN_GRP_HASH_SIZE];
-
 const char vlan_fullname[] = "802.1Q VLAN Support";
 const char vlan_version[] = DRV_VERSION;
 static const char vlan_copyright[] = "Ben Greear <greearb@candelatech.com>";
@@ -59,40 +56,6 @@ static struct packet_type vlan_packet_type __read_mostly = {
 
 /* End of global variables definitions. */
 
-static inline unsigned int vlan_grp_hashfn(unsigned int idx)
-{
-	return ((idx >> VLAN_GRP_HASH_SHIFT) ^ idx) & VLAN_GRP_HASH_MASK;
-}
-
-/* Must be invoked with RCU read lock (no preempt) */
-static struct vlan_group *__vlan_find_group(struct net_device *real_dev)
-{
-	struct vlan_group *grp;
-	struct hlist_node *n;
-	int hash = vlan_grp_hashfn(real_dev->ifindex);
-
-	hlist_for_each_entry_rcu(grp, n, &vlan_group_hash[hash], hlist) {
-		if (grp->real_dev == real_dev)
-			return grp;
-	}
-
-	return NULL;
-}
-
-/*  Find the protocol handler.  Assumes VID < VLAN_VID_MASK.
- *
- * Must be invoked with RCU read lock (no preempt)
- */
-struct net_device *__find_vlan_dev(struct net_device *real_dev, u16 vlan_id)
-{
-	struct vlan_group *grp = __vlan_find_group(real_dev);
-
-	if (grp)
-		return vlan_group_get_device(grp, vlan_id);
-
-	return NULL;
-}
-
 static void vlan_group_free(struct vlan_group *grp)
 {
 	int i;
@@ -111,8 +74,6 @@ static struct vlan_group *vlan_group_alloc(struct net_device *real_dev)
 		return NULL;
 
 	grp->real_dev = real_dev;
-	hlist_add_head_rcu(&grp->hlist,
-			&vlan_group_hash[vlan_grp_hashfn(real_dev->ifindex)]);
 	return grp;
 }
 
@@ -151,7 +112,7 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 
 	ASSERT_RTNL();
 
-	grp = __vlan_find_group(real_dev);
+	grp = real_dev->vlgrp;
 	BUG_ON(!grp);
 
 	/* Take it out of our own structures, but be sure to interlock with
@@ -173,11 +134,10 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 	if (grp->nr_vlans == 0) {
 		vlan_gvrp_uninit_applicant(real_dev);
 
+		rcu_assign_pointer(real_dev->vlgrp, NULL);
 		if (real_dev->features & NETIF_F_HW_VLAN_RX)
 			ops->ndo_vlan_rx_register(real_dev, NULL);
 
-		hlist_del_rcu(&grp->hlist);
-
 		/* Free the group, after all cpu's are done. */
 		call_rcu(&grp->rcu, vlan_rcu_free);
 	}
@@ -207,7 +167,7 @@ int vlan_check_real_dev(struct net_device *real_dev, u16 vlan_id)
 		return -EOPNOTSUPP;
 	}
 
-	if (__find_vlan_dev(real_dev, vlan_id) != NULL)
+	if (vlan_find_dev(real_dev, vlan_id) != NULL)
 		return -EEXIST;
 
 	return 0;
@@ -222,7 +182,7 @@ int register_vlan_dev(struct net_device *dev)
 	struct vlan_group *grp, *ngrp = NULL;
 	int err;
 
-	grp = __vlan_find_group(real_dev);
+	grp = real_dev->vlgrp;
 	if (!grp) {
 		ngrp = grp = vlan_group_alloc(real_dev);
 		if (!grp)
@@ -252,8 +212,11 @@ int register_vlan_dev(struct net_device *dev)
 	vlan_group_set_device(grp, vlan_id, dev);
 	grp->nr_vlans++;
 
-	if (ngrp && real_dev->features & NETIF_F_HW_VLAN_RX)
-		ops->ndo_vlan_rx_register(real_dev, ngrp);
+	if (ngrp) {
+		if (real_dev->features & NETIF_F_HW_VLAN_RX)
+			ops->ndo_vlan_rx_register(real_dev, ngrp);
+		rcu_assign_pointer(real_dev->vlgrp, ngrp);
+	}
 	if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
 		ops->ndo_vlan_rx_add_vid(real_dev, vlan_id);
 
@@ -264,7 +227,6 @@ out_uninit_applicant:
 		vlan_gvrp_uninit_applicant(real_dev);
 out_free_group:
 	if (ngrp) {
-		hlist_del_rcu(&ngrp->hlist);
 		/* Free the group, after all cpu's are done. */
 		call_rcu(&ngrp->rcu, vlan_rcu_free);
 	}
@@ -428,7 +390,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 		dev->netdev_ops->ndo_vlan_rx_add_vid(dev, 0);
 	}
 
-	grp = __vlan_find_group(dev);
+	grp = dev->vlgrp;
 	if (!grp)
 		goto out;
 
@@ -746,8 +708,6 @@ err0:
 
 static void __exit vlan_cleanup_module(void)
 {
-	unsigned int i;
-
 	vlan_ioctl_set(NULL);
 	vlan_netlink_fini();
 
@@ -755,10 +715,6 @@ static void __exit vlan_cleanup_module(void)
 
 	dev_remove_pack(&vlan_packet_type);
 
-	/* This table must be empty if there are no module references left. */
-	for (i = 0; i < VLAN_GRP_HASH_SIZE; i++)
-		BUG_ON(!hlist_empty(&vlan_group_hash[i]));
-
 	unregister_pernet_subsys(&vlan_net_ops);
 	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 8d9503a..db01b31 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -72,23 +72,6 @@ static inline struct vlan_dev_info *vlan_dev_info(const struct net_device *dev)
 	return netdev_priv(dev);
 }
 
-#define VLAN_GRP_HASH_SHIFT	5
-#define VLAN_GRP_HASH_SIZE	(1 << VLAN_GRP_HASH_SHIFT)
-#define VLAN_GRP_HASH_MASK	(VLAN_GRP_HASH_SIZE - 1)
-
-/*  Find a VLAN device by the MAC address of its Ethernet device, and
- *  it's VLAN ID.  The default configuration is to have VLAN's scope
- *  to be box-wide, so the MAC will be ignored.  The mac will only be
- *  looked at if we are configured to have a separate set of VLANs per
- *  each MAC addressable interface.  Note that this latter option does
- *  NOT follow the spec for VLANs, but may be useful for doing very
- *  large quantities of VLAN MUX/DEMUX onto FrameRelay or ATM PVCs.
- *
- *  Must be invoked with rcu_read_lock (ie preempt disabled)
- *  or with RTNL.
- */
-struct net_device *__find_vlan_dev(struct net_device *real_dev, u16 vlan_id);
-
 /* found in vlan_dev.c */
 int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 		  struct packet_type *ptype, struct net_device *orig_dev);
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index f54251e..14e3d1f 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -158,7 +158,7 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 	vlan_id = vlan_tci & VLAN_VID_MASK;
 
 	rcu_read_lock();
-	vlan_dev = __find_vlan_dev(dev, vlan_id);
+	vlan_dev = vlan_find_dev(dev, vlan_id);
 
 	/* If the VLAN device is defined, we use it.
 	 * If not, and the VID is 0, it is a 802.1p packet (not
-- 
1.7.1

