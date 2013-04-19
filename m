From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 3/6] net: vlan: prepare for 802.1ad support
Date: Fri, 19 Apr 2013 14:04:29 +0200
Message-ID: <1366373072-19621-4-git-send-email-kaber@trash.net>
References: <1366373072-19621-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46098 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030191Ab3DSMEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 08:04:38 -0400
In-Reply-To: <1366373072-19621-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the encapsulation protocol value a property of VLAN devices and change
the device lookup functions to take the protocol value into account.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 drivers/net/bonding/bond_main.c                    |  8 +-
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c |  2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  2 +-
 include/linux/if_vlan.h                            |  2 +-
 net/8021q/vlan.c                                   | 87 ++++++++--------------
 net/8021q/vlan.h                                   | 54 +++++++++++---
 net/8021q/vlan_core.c                              | 10 ++-
 net/8021q/vlan_dev.c                               |  7 +-
 net/8021q/vlan_gvrp.c                              |  4 +
 net/8021q/vlan_mvrp.c                              |  4 +
 net/8021q/vlan_netlink.c                           |  9 ++-
 net/bridge/br_netfilter.c                          |  3 +-
 12 files changed, 108 insertions(+), 84 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 35e89e1..1e79a76 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -782,7 +782,7 @@ static void bond_resend_igmp_join_requests(struct bonding *bond)
 
 	/* rejoin all groups on vlan devices */
 	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
-		vlan_dev = __vlan_find_dev_deep(bond_dev,
+		vlan_dev = __vlan_find_dev_deep(bond_dev, htons(ETH_P_8021Q),
 						vlan->vlan_id);
 		if (vlan_dev)
 			__bond_resend_igmp_join_requests(vlan_dev);
@@ -2512,7 +2512,8 @@ static int bond_has_this_ip(struct bonding *bond, __be32 ip)
 
 	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
 		rcu_read_lock();
-		vlan_dev = __vlan_find_dev_deep(bond->dev, vlan->vlan_id);
+		vlan_dev = __vlan_find_dev_deep(bond->dev, htons(ETH_P_8021Q),
+						vlan->vlan_id);
 		rcu_read_unlock();
 		if (vlan_dev && ip == bond_confirm_addr(vlan_dev, 0, ip))
 			return 1;
@@ -2541,7 +2542,7 @@ static void bond_arp_send(struct net_device *slave_dev, int arp_op, __be32 dest_
 		return;
 	}
 	if (vlan_id) {
-		skb = vlan_put_tag(skb, vlan_id);
+		skb = vlan_put_tag(skb, htons(ETH_P_8021Q), vlan_id);
 		if (!skb) {
 			pr_err("failed to insert VLAN tag\n");
 			return;
@@ -2603,6 +2604,7 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 		list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
 			rcu_read_lock();
 			vlan_dev = __vlan_find_dev_deep(bond->dev,
+							htons(ETH_P_8021Q),
 							vlan->vlan_id);
 			rcu_read_unlock();
 			if (vlan_dev == rt->dst.dev) {
diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
index 4232767..0c96e5f 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
@@ -185,7 +185,7 @@ static struct net_device *get_iff_from_mac(struct adapter *adapter,
 		if (!memcmp(dev->dev_addr, mac, ETH_ALEN)) {
 			rcu_read_lock();
 			if (vlan && vlan != VLAN_VID_MASK) {
-				dev = __vlan_find_dev_deep(dev, vlan);
+				dev = __vlan_find_dev_deep(dev, htons(ETH_P_8021Q), vlan);
 			} else if (netif_is_bond_slave(dev)) {
 				struct net_device *upper_dev;
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index e88e013..d132765 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -3346,7 +3346,7 @@ void qlcnic_restore_indev_addr(struct net_device *netdev, unsigned long event)
 
 	rcu_read_lock();
 	for_each_set_bit(vid, adapter->vlans, VLAN_N_VID) {
-		dev = __vlan_find_dev_deep(netdev, vid);
+		dev = __vlan_find_dev_deep(netdev, htons(ETH_P_8021Q), vid);
 		if (!dev)
 			continue;
 		qlcnic_config_indev_addr(adapter, dev, event);
diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index fcb9ef8..2c9fb65 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -86,7 +86,7 @@ static inline int is_vlan_dev(struct net_device *dev)
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 
 extern struct net_device *__vlan_find_dev_deep(struct net_device *real_dev,
-					       u16 vlan_id);
+					       __be16 vlan_proto, u16 vlan_id);
 extern struct net_device *vlan_dev_real_dev(const struct net_device *dev);
 extern u16 vlan_dev_vlan_id(const struct net_device *dev);
 
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 447c5c9..9424f37 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -51,14 +51,18 @@ const char vlan_version[] = DRV_VERSION;
 
 /* End of global variables definitions. */
 
-static int vlan_group_prealloc_vid(struct vlan_group *vg, u16 vlan_id)
+static int vlan_group_prealloc_vid(struct vlan_group *vg,
+				   __be16 vlan_proto, u16 vlan_id)
 {
 	struct net_device **array;
+	unsigned int pidx, vidx;
 	unsigned int size;
 
 	ASSERT_RTNL();
 
-	array = vg->vlan_devices_arrays[vlan_id / VLAN_GROUP_ARRAY_PART_LEN];
+	pidx  = vlan_proto_idx(vlan_proto);
+	vidx  = vlan_id / VLAN_GROUP_ARRAY_PART_LEN;
+	array = vg->vlan_devices_arrays[pidx][vidx];
 	if (array != NULL)
 		return 0;
 
@@ -67,7 +71,7 @@ static int vlan_group_prealloc_vid(struct vlan_group *vg, u16 vlan_id)
 	if (array == NULL)
 		return -ENOBUFS;
 
-	vg->vlan_devices_arrays[vlan_id / VLAN_GROUP_ARRAY_PART_LEN] = array;
+	vg->vlan_devices_arrays[pidx][vidx] = array;
 	return 0;
 }
 
@@ -93,7 +97,7 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 	if (vlan->flags & VLAN_FLAG_GVRP)
 		vlan_gvrp_request_leave(dev);
 
-	vlan_group_set_device(grp, vlan_id, NULL);
+	vlan_group_set_device(grp, vlan->vlan_proto, vlan_id, NULL);
 	/* Because unregister_netdevice_queue() makes sure at least one rcu
 	 * grace period is respected before device freeing,
 	 * we dont need to call synchronize_net() here.
@@ -112,13 +116,14 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 	 * VLAN is not 0 (leave it there for 802.1p).
 	 */
 	if (vlan_id)
-		vlan_vid_del(real_dev, htons(ETH_P_8021Q), vlan_id);
+		vlan_vid_del(real_dev, vlan->vlan_proto, vlan_id);
 
 	/* Get rid of the vlan's reference to real_dev */
 	dev_put(real_dev);
 }
 
-int vlan_check_real_dev(struct net_device *real_dev, u16 vlan_id)
+int vlan_check_real_dev(struct net_device *real_dev,
+			__be16 protocol, u16 vlan_id)
 {
 	const char *name = real_dev->name;
 
@@ -127,7 +132,7 @@ int vlan_check_real_dev(struct net_device *real_dev, u16 vlan_id)
 		return -EOPNOTSUPP;
 	}
 
-	if (vlan_find_dev(real_dev, vlan_id) != NULL)
+	if (vlan_find_dev(real_dev, protocol, vlan_id) != NULL)
 		return -EEXIST;
 
 	return 0;
@@ -142,7 +147,7 @@ int register_vlan_dev(struct net_device *dev)
 	struct vlan_group *grp;
 	int err;
 
-	err = vlan_vid_add(real_dev, htons(ETH_P_8021Q), vlan_id);
+	err = vlan_vid_add(real_dev, vlan->vlan_proto, vlan_id);
 	if (err)
 		return err;
 
@@ -160,7 +165,7 @@ int register_vlan_dev(struct net_device *dev)
 			goto out_uninit_gvrp;
 	}
 
-	err = vlan_group_prealloc_vid(grp, vlan_id);
+	err = vlan_group_prealloc_vid(grp, vlan->vlan_proto, vlan_id);
 	if (err < 0)
 		goto out_uninit_mvrp;
 
@@ -181,7 +186,7 @@ int register_vlan_dev(struct net_device *dev)
 	/* So, got the sucker initialized, now lets place
 	 * it into our local structure.
 	 */
-	vlan_group_set_device(grp, vlan_id, dev);
+	vlan_group_set_device(grp, vlan->vlan_proto, vlan_id, dev);
 	grp->nr_vlan_devs++;
 
 	return 0;
@@ -195,7 +200,7 @@ out_uninit_gvrp:
 	if (grp->nr_vlan_devs == 0)
 		vlan_gvrp_uninit_applicant(real_dev);
 out_vid_del:
-	vlan_vid_del(real_dev, htons(ETH_P_8021Q), vlan_id);
+	vlan_vid_del(real_dev, vlan->vlan_proto, vlan_id);
 	return err;
 }
 
@@ -213,7 +218,7 @@ static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
 	if (vlan_id >= VLAN_VID_MASK)
 		return -ERANGE;
 
-	err = vlan_check_real_dev(real_dev, vlan_id);
+	err = vlan_check_real_dev(real_dev, htons(ETH_P_8021Q), vlan_id);
 	if (err < 0)
 		return err;
 
@@ -255,6 +260,7 @@ static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
 	new_dev->mtu = real_dev->mtu;
 	new_dev->priv_flags |= (real_dev->priv_flags & IFF_UNICAST_FLT);
 
+	vlan_dev_priv(new_dev)->vlan_proto = htons(ETH_P_8021Q);
 	vlan_dev_priv(new_dev)->vlan_id = vlan_id;
 	vlan_dev_priv(new_dev)->real_dev = real_dev;
 	vlan_dev_priv(new_dev)->dent = NULL;
@@ -341,6 +347,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 	int i, flgs;
 	struct net_device *vlandev;
 	struct vlan_dev_priv *vlan;
+	bool last = false;
 	LIST_HEAD(list);
 
 	if (is_vlan_dev(dev))
@@ -365,22 +372,13 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 	switch (event) {
 	case NETDEV_CHANGE:
 		/* Propagate real device state to vlan devices */
-		for (i = 0; i < VLAN_N_VID; i++) {
-			vlandev = vlan_group_get_device(grp, i);
-			if (!vlandev)
-				continue;
-
+		vlan_group_for_each_dev(grp, i, vlandev)
 			netif_stacked_transfer_operstate(dev, vlandev);
-		}
 		break;
 
 	case NETDEV_CHANGEADDR:
 		/* Adjust unicast filters on underlying device */
-		for (i = 0; i < VLAN_N_VID; i++) {
-			vlandev = vlan_group_get_device(grp, i);
-			if (!vlandev)
-				continue;
-
+		vlan_group_for_each_dev(grp, i, vlandev) {
 			flgs = vlandev->flags;
 			if (!(flgs & IFF_UP))
 				continue;
@@ -390,11 +388,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 		break;
 
 	case NETDEV_CHANGEMTU:
-		for (i = 0; i < VLAN_N_VID; i++) {
-			vlandev = vlan_group_get_device(grp, i);
-			if (!vlandev)
-				continue;
-
+		vlan_group_for_each_dev(grp, i, vlandev) {
 			if (vlandev->mtu <= dev->mtu)
 				continue;
 
@@ -404,14 +398,8 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 
 	case NETDEV_FEAT_CHANGE:
 		/* Propagate device features to underlying device */
-		for (i = 0; i < VLAN_N_VID; i++) {
-			vlandev = vlan_group_get_device(grp, i);
-			if (!vlandev)
-				continue;
-
+		vlan_group_for_each_dev(grp, i, vlandev)
 			vlan_transfer_features(dev, vlandev);
-		}
-
 		break;
 
 	case NETDEV_DOWN:
@@ -419,11 +407,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 			vlan_vid_del(dev, htons(ETH_P_8021Q), 0);
 
 		/* Put all VLANs for this dev in the down state too.  */
-		for (i = 0; i < VLAN_N_VID; i++) {
-			vlandev = vlan_group_get_device(grp, i);
-			if (!vlandev)
-				continue;
-
+		vlan_group_for_each_dev(grp, i, vlandev) {
 			flgs = vlandev->flags;
 			if (!(flgs & IFF_UP))
 				continue;
@@ -437,11 +421,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 
 	case NETDEV_UP:
 		/* Put all VLANs for this dev in the up state too.  */
-		for (i = 0; i < VLAN_N_VID; i++) {
-			vlandev = vlan_group_get_device(grp, i);
-			if (!vlandev)
-				continue;
-
+		vlan_group_for_each_dev(grp, i, vlandev) {
 			flgs = vlandev->flags;
 			if (flgs & IFF_UP)
 				continue;
@@ -458,17 +438,15 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 		if (dev->reg_state != NETREG_UNREGISTERING)
 			break;
 
-		for (i = 0; i < VLAN_N_VID; i++) {
-			vlandev = vlan_group_get_device(grp, i);
-			if (!vlandev)
-				continue;
-
+		vlan_group_for_each_dev(grp, i, vlandev) {
 			/* removal of last vid destroys vlan_info, abort
 			 * afterwards */
 			if (vlan_info->nr_vids == 1)
-				i = VLAN_N_VID;
+				last = true;
 
 			unregister_vlan_dev(vlandev, &list);
+			if (last)
+				break;
 		}
 		unregister_netdevice_many(&list);
 		break;
@@ -482,13 +460,8 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 	case NETDEV_NOTIFY_PEERS:
 	case NETDEV_BONDING_FAILOVER:
 		/* Propagate to vlan devices */
-		for (i = 0; i < VLAN_N_VID; i++) {
-			vlandev = vlan_group_get_device(grp, i);
-			if (!vlandev)
-				continue;
-
+		vlan_group_for_each_dev(grp, i, vlandev)
 			call_netdevice_notifiers(event, vlandev);
-		}
 		break;
 	}
 
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 670f1e8..245de96 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -49,6 +49,7 @@ struct netpoll;
  *	@ingress_priority_map: ingress priority mappings
  *	@nr_egress_mappings: number of egress priority mappings
  *	@egress_priority_map: hash of egress priority mappings
+ *	@vlan_proto: VLAN encapsulation protocol
  *	@vlan_id: VLAN identifier
  *	@flags: device flags
  *	@real_dev: underlying netdevice
@@ -62,6 +63,7 @@ struct vlan_dev_priv {
 	unsigned int				nr_egress_mappings;
 	struct vlan_priority_tci_mapping	*egress_priority_map[16];
 
+	__be16					vlan_proto;
 	u16					vlan_id;
 	u16					flags;
 
@@ -87,10 +89,16 @@ static inline struct vlan_dev_priv *vlan_dev_priv(const struct net_device *dev)
 #define VLAN_GROUP_ARRAY_SPLIT_PARTS  8
 #define VLAN_GROUP_ARRAY_PART_LEN     (VLAN_N_VID/VLAN_GROUP_ARRAY_SPLIT_PARTS)
 
+enum vlan_protos {
+	VLAN_PROTO_8021Q	= 0,
+	VLAN_PROTO_NUM,
+};
+
 struct vlan_group {
 	unsigned int		nr_vlan_devs;
 	struct hlist_node	hlist;	/* linked list */
-	struct net_device **vlan_devices_arrays[VLAN_GROUP_ARRAY_SPLIT_PARTS];
+	struct net_device **vlan_devices_arrays[VLAN_PROTO_NUM]
+					       [VLAN_GROUP_ARRAY_SPLIT_PARTS];
 };
 
 struct vlan_info {
@@ -103,37 +111,64 @@ struct vlan_info {
 	struct rcu_head		rcu;
 };
 
-static inline struct net_device *vlan_group_get_device(struct vlan_group *vg,
-						       u16 vlan_id)
+static inline unsigned int vlan_proto_idx(__be16 proto)
+{
+	switch (proto) {
+	case __constant_htons(ETH_P_8021Q):
+		return VLAN_PROTO_8021Q;
+	default:
+		BUG();
+	}
+}
+
+static inline struct net_device *__vlan_group_get_device(struct vlan_group *vg,
+							 unsigned int pidx,
+							 u16 vlan_id)
 {
 	struct net_device **array;
-	array = vg->vlan_devices_arrays[vlan_id / VLAN_GROUP_ARRAY_PART_LEN];
+
+	array = vg->vlan_devices_arrays[pidx]
+				       [vlan_id / VLAN_GROUP_ARRAY_PART_LEN];
 	return array ? array[vlan_id % VLAN_GROUP_ARRAY_PART_LEN] : NULL;
 }
 
+static inline struct net_device *vlan_group_get_device(struct vlan_group *vg,
+						       __be16 vlan_proto,
+						       u16 vlan_id)
+{
+	return __vlan_group_get_device(vg, vlan_proto_idx(vlan_proto), vlan_id);
+}
+
 static inline void vlan_group_set_device(struct vlan_group *vg,
-					 u16 vlan_id,
+					 __be16 vlan_proto, u16 vlan_id,
 					 struct net_device *dev)
 {
 	struct net_device **array;
 	if (!vg)
 		return;
-	array = vg->vlan_devices_arrays[vlan_id / VLAN_GROUP_ARRAY_PART_LEN];
+	array = vg->vlan_devices_arrays[vlan_proto_idx(vlan_proto)]
+				       [vlan_id / VLAN_GROUP_ARRAY_PART_LEN];
 	array[vlan_id % VLAN_GROUP_ARRAY_PART_LEN] = dev;
 }
 
 /* Must be invoked with rcu_read_lock or with RTNL. */
 static inline struct net_device *vlan_find_dev(struct net_device *real_dev,
-					       u16 vlan_id)
+					       __be16 vlan_proto, u16 vlan_id)
 {
 	struct vlan_info *vlan_info = rcu_dereference_rtnl(real_dev->vlan_info);
 
 	if (vlan_info)
-		return vlan_group_get_device(&vlan_info->grp, vlan_id);
+		return vlan_group_get_device(&vlan_info->grp,
+					     vlan_proto, vlan_id);
 
 	return NULL;
 }
 
+#define vlan_group_for_each_dev(grp, i, dev) \
+	for ((i) = 0; i < VLAN_PROTO_NUM * VLAN_N_VID; i++) \
+		if (((dev) = __vlan_group_get_device((grp), (i) / VLAN_N_VID, \
+							    (i) % VLAN_N_VID)))
+
 /* found in vlan_dev.c */
 void vlan_dev_set_ingress_priority(const struct net_device *dev,
 				   u32 skb_prio, u16 vlan_prio);
@@ -142,7 +177,8 @@ int vlan_dev_set_egress_priority(const struct net_device *dev,
 int vlan_dev_change_flags(const struct net_device *dev, u32 flag, u32 mask);
 void vlan_dev_get_realdev_name(const struct net_device *dev, char *result);
 
-int vlan_check_real_dev(struct net_device *real_dev, u16 vlan_id);
+int vlan_check_real_dev(struct net_device *real_dev,
+			__be16 protocol, u16 vlan_id);
 void vlan_setup(struct net_device *dev);
 int register_vlan_dev(struct net_device *dev);
 void unregister_vlan_dev(struct net_device *dev, struct list_head *head);
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 04e3b95..4e4c360 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -12,7 +12,7 @@ bool vlan_do_receive(struct sk_buff **skbp)
 	struct net_device *vlan_dev;
 	struct vlan_pcpu_stats *rx_stats;
 
-	vlan_dev = vlan_find_dev(skb->dev, vlan_id);
+	vlan_dev = vlan_find_dev(skb->dev, htons(ETH_P_8021Q), vlan_id);
 	if (!vlan_dev)
 		return false;
 
@@ -62,12 +62,13 @@ bool vlan_do_receive(struct sk_buff **skbp)
 
 /* Must be invoked with rcu_read_lock. */
 struct net_device *__vlan_find_dev_deep(struct net_device *dev,
-					u16 vlan_id)
+					__be16 vlan_proto, u16 vlan_id)
 {
 	struct vlan_info *vlan_info = rcu_dereference(dev->vlan_info);
 
 	if (vlan_info) {
-		return vlan_group_get_device(&vlan_info->grp, vlan_id);
+		return vlan_group_get_device(&vlan_info->grp,
+					     vlan_proto, vlan_id);
 	} else {
 		/*
 		 * Lower devices of master uppers (bonding, team) do not have
@@ -78,7 +79,8 @@ struct net_device *__vlan_find_dev_deep(struct net_device *dev,
 
 		upper_dev = netdev_master_upper_dev_get_rcu(dev);
 		if (upper_dev)
-			return __vlan_find_dev_deep(upper_dev, vlan_id);
+			return __vlan_find_dev_deep(upper_dev,
+						    vlan_proto, vlan_id);
 	}
 
 	return NULL;
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 5c4892a..d7457b7 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -99,6 +99,7 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 				const void *daddr, const void *saddr,
 				unsigned int len)
 {
+	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 	struct vlan_hdr *vhdr;
 	unsigned int vhdrlen = 0;
 	u16 vlan_tci = 0;
@@ -120,8 +121,8 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 		else
 			vhdr->h_vlan_encapsulated_proto = htons(len);
 
-		skb->protocol = htons(ETH_P_8021Q);
-		type = ETH_P_8021Q;
+		skb->protocol = vlan->vlan_proto;
+		type = ntohs(vlan->vlan_proto);
 		vhdrlen = VLAN_HLEN;
 	}
 
@@ -161,7 +162,7 @@ static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
 	 * NOTE: THIS ASSUMES DIX ETHERNET, SPECIFICALLY NOT SUPPORTING
 	 * OTHER THINGS LIKE FDDI/TokenRing/802.3 SNAPs...
 	 */
-	if (veth->h_vlan_proto != htons(ETH_P_8021Q) ||
+	if (veth->h_vlan_proto != vlan->vlan_proto ||
 	    vlan->flags & VLAN_FLAG_REORDER_HDR) {
 		u16 vlan_tci;
 		vlan_tci = vlan->vlan_id;
diff --git a/net/8021q/vlan_gvrp.c b/net/8021q/vlan_gvrp.c
index 6f97553..66a8032 100644
--- a/net/8021q/vlan_gvrp.c
+++ b/net/8021q/vlan_gvrp.c
@@ -32,6 +32,8 @@ int vlan_gvrp_request_join(const struct net_device *dev)
 	const struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 	__be16 vlan_id = htons(vlan->vlan_id);
 
+	if (vlan->vlan_proto != htons(ETH_P_8021Q))
+		return 0;
 	return garp_request_join(vlan->real_dev, &vlan_gvrp_app,
 				 &vlan_id, sizeof(vlan_id), GVRP_ATTR_VID);
 }
@@ -41,6 +43,8 @@ void vlan_gvrp_request_leave(const struct net_device *dev)
 	const struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 	__be16 vlan_id = htons(vlan->vlan_id);
 
+	if (vlan->vlan_proto != htons(ETH_P_8021Q))
+		return;
 	garp_request_leave(vlan->real_dev, &vlan_gvrp_app,
 			   &vlan_id, sizeof(vlan_id), GVRP_ATTR_VID);
 }
diff --git a/net/8021q/vlan_mvrp.c b/net/8021q/vlan_mvrp.c
index d9ec1d5..e0fe091 100644
--- a/net/8021q/vlan_mvrp.c
+++ b/net/8021q/vlan_mvrp.c
@@ -38,6 +38,8 @@ int vlan_mvrp_request_join(const struct net_device *dev)
 	const struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 	__be16 vlan_id = htons(vlan->vlan_id);
 
+	if (vlan->vlan_proto != htons(ETH_P_8021Q))
+		return 0;
 	return mrp_request_join(vlan->real_dev, &vlan_mrp_app,
 				&vlan_id, sizeof(vlan_id), MVRP_ATTR_VID);
 }
@@ -47,6 +49,8 @@ void vlan_mvrp_request_leave(const struct net_device *dev)
 	const struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 	__be16 vlan_id = htons(vlan->vlan_id);
 
+	if (vlan->vlan_proto != htons(ETH_P_8021Q))
+		return;
 	mrp_request_leave(vlan->real_dev, &vlan_mrp_app,
 			  &vlan_id, sizeof(vlan_id), MVRP_ATTR_VID);
 }
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index 1789658..a1a956a 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -118,11 +118,12 @@ static int vlan_newlink(struct net *src_net, struct net_device *dev,
 	if (!real_dev)
 		return -ENODEV;
 
-	vlan->vlan_id  = nla_get_u16(data[IFLA_VLAN_ID]);
-	vlan->real_dev = real_dev;
-	vlan->flags    = VLAN_FLAG_REORDER_HDR;
+	vlan->vlan_proto = htons(ETH_P_8021Q);
+	vlan->vlan_id	 = nla_get_u16(data[IFLA_VLAN_ID]);
+	vlan->real_dev	 = real_dev;
+	vlan->flags	 = VLAN_FLAG_REORDER_HDR;
 
-	err = vlan_check_real_dev(real_dev, vlan->vlan_id);
+	err = vlan_check_real_dev(real_dev, vlan->vlan_proto, vlan->vlan_id);
 	if (err < 0)
 		return err;
 
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index fe43bc7..bd61bf5 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -535,7 +535,8 @@ static struct net_device *brnf_get_logical_dev(struct sk_buff *skb, const struct
 	if (brnf_pass_vlan_indev == 0 || !vlan_tx_tag_present(skb))
 		return br;
 
-	vlan = __vlan_find_dev_deep(br, vlan_tx_tag_get(skb) & VLAN_VID_MASK);
+	vlan = __vlan_find_dev_deep(br, htons(ETH_P_8021Q),
+				    vlan_tx_tag_get(skb) & VLAN_VID_MASK);
 
 	return vlan ? vlan : br;
 }
-- 
1.8.1.4
