From: David Lamparter <equinox@diac24.net>
Subject: [RFC PATCH] net: vlan: 802.1ad S-VLAN support
Date: Sun, 17 Jul 2011 22:55:05 +0200
Message-ID: <1310936105-3494206-1-git-send-email-equinox@diac24.net>
Cc: Patrick McHardy <kaber@trash.net>,
	David Lamparter <equinox@diac24.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:52497 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755124Ab1GQUz0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jul 2011 16:55:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this adds support for 802.1ad S-VLANs, which basically are regular VLANs
with a different protocol field. also supported are the legacy QinQ
9100/9200/9300 ethertypes. as with the CFI bit for 802.1Q, the DEI bit
is blissfully ignored.

this patch modifies the 802.1Q code, but keeps the regular VLAN
acceleration architecture unchanged. the S-VLAN code does not use that;
I am not aware of any NIC implementing it for ethertypes other than
8100.

all in-kernel interfaces and definitions are kept compatible; 802.1Q
performance should not experience significant changes.

tested in a simple setup with kvm, including some random stackings of
S-VLANs and C-VLANs.
---

well, this isn't quite finished yet, but it's in a state where I need
some feedback... especially on:
 - int vlan_pidx(u16 protocol)
   do i do this with a table? that wastes a cacheline... as code it's
   around 32 bytes on x86_64. it's not called for regular 802.1Q frames
   from any hot paths btw, so maybe i shouldn't care?
 - is_vlan_dev / IFF_802_1Q_VLAN
   need to decide whether this should be set for S-VLAN devices, and
   after it's decided need to look at the users from drivers/net and
   drivers/scsi
 - vlan_dev_vlan_id - same as above
 - GRO & co. - basically i have no clue.

Any feedback very welcome,
David

 include/linux/if_link.h  |    1 +
 include/linux/if_vlan.h  |   43 +++++++----
 net/8021q/vlan.c         |  190 ++++++++++++++++++++++++++++++----------------
 net/8021q/vlan.h         |    9 ++-
 net/8021q/vlan_core.c    |    6 +-
 net/8021q/vlan_dev.c     |   15 +++-
 net/8021q/vlan_gvrp.c    |    6 ++
 net/8021q/vlan_netlink.c |   21 +++++-
 net/8021q/vlanproc.c     |    9 ++-
 net/core/dev.c           |    2 +-
 10 files changed, 207 insertions(+), 95 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 0ee969a..23653a7 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -225,6 +225,7 @@ enum {
 	IFLA_VLAN_FLAGS,
 	IFLA_VLAN_EGRESS_QOS,
 	IFLA_VLAN_INGRESS_QOS,
+	IFLA_VLAN_PROTOCOL,
 	__IFLA_VLAN_MAX,
 };
 
diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index bc03e40..cd0269e 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -45,7 +45,7 @@ struct vlan_hdr {
  *	struct vlan_ethhdr - vlan ethernet header (ethhdr + vlan_hdr)
  *	@h_dest: destination ethernet address
  *	@h_source: source ethernet address
- *	@h_vlan_proto: ethernet protocol (always 0x8100)
+ *	@h_vlan_proto: ethernet protocol (0x8100, 0x88a8, 0x9x00)
  *	@h_vlan_TCI: priority and VLAN ID
  *	@h_vlan_encapsulated_proto: packet type ID or len
  */
@@ -71,6 +71,16 @@ static inline struct vlan_ethhdr *vlan_eth_hdr(const struct sk_buff *skb)
 #define VLAN_VID_MASK		0x0fff /* VLAN Identifier */
 #define VLAN_N_VID		4096
 
+enum {
+	VLAN_PROTOIDX_8021Q = 0,
+	VLAN_PROTOIDX_8021AD,
+	VLAN_PROTOIDX_QINQ1,
+	VLAN_PROTOIDX_QINQ2,
+	VLAN_PROTOIDX_QINQ3,
+
+	VLAN_N_PROTOCOL
+};
+
 /* found in socket.c */
 extern void vlan_ioctl_set(int (*hook)(struct net *, void __user *));
 
@@ -86,27 +96,31 @@ struct vlan_group {
 					    * the vlan is attached to.
 					    */
 	unsigned int		nr_vlans;
-	struct hlist_node	hlist;	/* linked list */
-	struct net_device **vlan_devices_arrays[VLAN_GROUP_ARRAY_SPLIT_PARTS];
+	struct net_device **vlan_devices_arrays[VLAN_N_PROTOCOL]
+						[VLAN_GROUP_ARRAY_SPLIT_PARTS];
 	struct rcu_head		rcu;
 };
 
-static inline struct net_device *vlan_group_get_device(struct vlan_group *vg,
-						       u16 vlan_id)
+#define vlan_group_get_device(vg, vlan_id) \
+	vlan_group_get_device_pidx(vg, VLAN_PROTOIDX_8021Q, vlan_id)
+static inline struct net_device *vlan_group_get_device_pidx(struct vlan_group *vg,
+							    int proto_idx, u16 vlan_id)
 {
 	struct net_device **array;
-	array = vg->vlan_devices_arrays[vlan_id / VLAN_GROUP_ARRAY_PART_LEN];
+	array = vg->vlan_devices_arrays[proto_idx][vlan_id / VLAN_GROUP_ARRAY_PART_LEN];
 	return array ? array[vlan_id % VLAN_GROUP_ARRAY_PART_LEN] : NULL;
 }
 
-static inline void vlan_group_set_device(struct vlan_group *vg,
-					 u16 vlan_id,
-					 struct net_device *dev)
+#define vlan_group_set_device(vg, vlan_id, dev) \
+	vlan_group_set_device_pidx(vg, VLAN_PROTOIDX_8021Q, vlan_id, dev)
+static inline void vlan_group_set_device_pidx(struct vlan_group *vg,
+					      int proto_idx, u16 vlan_id,
+					      struct net_device *dev)
 {
 	struct net_device **array;
 	if (!vg)
 		return;
-	array = vg->vlan_devices_arrays[vlan_id / VLAN_GROUP_ARRAY_PART_LEN];
+	array = vg->vlan_devices_arrays[proto_idx][vlan_id / VLAN_GROUP_ARRAY_PART_LEN];
 	array[vlan_id % VLAN_GROUP_ARRAY_PART_LEN] = dev;
 }
 
@@ -125,7 +139,7 @@ extern u16 vlan_dev_vlan_id(const struct net_device *dev);
 
 extern int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 			     u16 vlan_tci, int polling);
-extern bool vlan_do_receive(struct sk_buff **skb);
+extern bool vlan_do_receive(struct sk_buff **skb, int pidx, u16 protocol);
 extern struct sk_buff *vlan_untag(struct sk_buff *skb);
 extern gro_result_t
 vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
@@ -226,7 +240,8 @@ static inline int vlan_hwaccel_receive_skb(struct sk_buff *skb,
  *
  * Does not change skb->protocol so this function can be used during receive.
  */
-static inline struct sk_buff *vlan_insert_tag(struct sk_buff *skb, u16 vlan_tci)
+static inline struct sk_buff *vlan_insert_tag(struct sk_buff *skb,
+					      u16 protocol, u16 vlan_tci)
 {
 	struct vlan_ethhdr *veth;
 
@@ -241,7 +256,7 @@ static inline struct sk_buff *vlan_insert_tag(struct sk_buff *skb, u16 vlan_tci)
 	skb->mac_header -= VLAN_HLEN;
 
 	/* first, the ethernet type */
-	veth->h_vlan_proto = htons(ETH_P_8021Q);
+	veth->h_vlan_proto = htons(protocol);
 
 	/* now, the TCI */
 	veth->h_vlan_TCI = htons(vlan_tci);
@@ -262,7 +277,7 @@ static inline struct sk_buff *vlan_insert_tag(struct sk_buff *skb, u16 vlan_tci)
  */
 static inline struct sk_buff *__vlan_put_tag(struct sk_buff *skb, u16 vlan_tci)
 {
-	skb = vlan_insert_tag(skb, vlan_tci);
+	skb = vlan_insert_tag(skb, ETH_P_8021Q, vlan_tci);
 	if (skb)
 		skb->protocol = htons(ETH_P_8021Q);
 	return skb;
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index d24c464..2cdd886 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -46,17 +46,39 @@
 
 int vlan_net_id __read_mostly;
 
-const char vlan_fullname[] = "802.1Q VLAN Support";
+const char vlan_fullname[] = "802.1Q/.1ad VLAN Support";
 const char vlan_version[] = DRV_VERSION;
 
 /* End of global variables definitions. */
 
+#if 0
+/* lookup table, use first byte */
+static const uint8_t vlan_protocol_idx[256] = {
+	[ETH_P_8021Q >> 8]	= VLAN_PROTOIDX_8021Q,
+	[ETH_P_8021AD >> 8]	= VLAN_PROTOIDX_8021AD,
+	[ETH_P_QINQ1 >> 8]	= VLAN_PROTOIDX_QINQ1,
+	[ETH_P_QINQ2 >> 8]	= VLAN_PROTOIDX_QINQ2,
+	[ETH_P_QINQ3 >> 8]	= VLAN_PROTOIDX_QINQ3,
+};
+#define vlan_pidx(protocol) (vlan_protocol_idx[(protocol) >> 8])
+#else
+static inline int vlan_pidx(u16 protocol)
+{
+	if (likely(protocol == ETH_P_8021Q))
+		return VLAN_PROTOIDX_8021Q;
+	if (protocol == ETH_P_8021AD)
+		return VLAN_PROTOIDX_8021AD;
+	return ((protocol - ETH_P_QINQ1) >> 8) + VLAN_PROTOIDX_QINQ1;
+}
+#endif
+
 static void vlan_group_free(struct vlan_group *grp)
 {
-	int i;
+	int i, j;
 
-	for (i = 0; i < VLAN_GROUP_ARRAY_SPLIT_PARTS; i++)
-		kfree(grp->vlan_devices_arrays[i]);
+	for (j = 0; j < VLAN_N_PROTOCOL; j++)
+		for (i = 0; i < VLAN_GROUP_ARRAY_SPLIT_PARTS; i++)
+			kfree(grp->vlan_devices_arrays[j][i]);
 	kfree(grp);
 }
 
@@ -72,14 +94,16 @@ static struct vlan_group *vlan_group_alloc(struct net_device *real_dev)
 	return grp;
 }
 
-static int vlan_group_prealloc_vid(struct vlan_group *vg, u16 vlan_id)
+static int vlan_group_prealloc_vid(struct vlan_group *vg,
+				   u16 protocol, u16 vlan_id)
 {
 	struct net_device **array;
 	unsigned int size;
 
 	ASSERT_RTNL();
 
-	array = vg->vlan_devices_arrays[vlan_id / VLAN_GROUP_ARRAY_PART_LEN];
+	array = vg->vlan_devices_arrays[vlan_pidx(protocol)]
+					[vlan_id / VLAN_GROUP_ARRAY_PART_LEN];
 	if (array != NULL)
 		return 0;
 
@@ -88,7 +112,8 @@ static int vlan_group_prealloc_vid(struct vlan_group *vg, u16 vlan_id)
 	if (array == NULL)
 		return -ENOBUFS;
 
-	vg->vlan_devices_arrays[vlan_id / VLAN_GROUP_ARRAY_PART_LEN] = array;
+	vg->vlan_devices_arrays[vlan_pidx(protocol)]
+				[vlan_id / VLAN_GROUP_ARRAY_PART_LEN] = array;
 	return 0;
 }
 
@@ -103,6 +128,7 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 	struct net_device *real_dev = vlan->real_dev;
 	const struct net_device_ops *ops = real_dev->netdev_ops;
 	struct vlan_group *grp;
+	u16 protocol = vlan->protocol;
 	u16 vlan_id = vlan->vlan_id;
 
 	ASSERT_RTNL();
@@ -114,7 +140,8 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 	 * HW accelerating devices or SW vlan input packet processing if
 	 * VLAN is not 0 (leave it there for 802.1p).
 	 */
-	if (vlan_id && (real_dev->features & NETIF_F_HW_VLAN_FILTER))
+	if (vlan_id && protocol == ETH_P_8021Q &&
+			(real_dev->features & NETIF_F_HW_VLAN_FILTER))
 		ops->ndo_vlan_rx_kill_vid(real_dev, vlan_id);
 
 	grp->nr_vlans--;
@@ -122,7 +149,7 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 	if (vlan->flags & VLAN_FLAG_GVRP)
 		vlan_gvrp_request_leave(dev);
 
-	vlan_group_set_device(grp, vlan_id, NULL);
+	vlan_group_set_device_pidx(grp, vlan_pidx(protocol), vlan_id, NULL);
 	/* Because unregister_netdevice_queue() makes sure at least one rcu
 	 * grace period is respected before device freeing,
 	 * we dont need to call synchronize_net() here.
@@ -145,7 +172,8 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 	dev_put(real_dev);
 }
 
-int vlan_check_real_dev(struct net_device *real_dev, u16 vlan_id)
+int vlan_check_real_dev(struct net_device *real_dev,
+			u16 protocol, u16 vlan_id)
 {
 	const char *name = real_dev->name;
 	const struct net_device_ops *ops = real_dev->netdev_ops;
@@ -161,7 +189,7 @@ int vlan_check_real_dev(struct net_device *real_dev, u16 vlan_id)
 		return -EOPNOTSUPP;
 	}
 
-	if (vlan_find_dev(real_dev, vlan_id) != NULL)
+	if (vlan_find_dev(real_dev, vlan_pidx(protocol), vlan_id) != NULL)
 		return -EEXIST;
 
 	return 0;
@@ -173,6 +201,7 @@ int register_vlan_dev(struct net_device *dev)
 	struct net_device *real_dev = vlan->real_dev;
 	const struct net_device_ops *ops = real_dev->netdev_ops;
 	u16 vlan_id = vlan->vlan_id;
+	u16 protocol = vlan->protocol;
 	struct vlan_group *grp, *ngrp = NULL;
 	int err;
 
@@ -186,7 +215,7 @@ int register_vlan_dev(struct net_device *dev)
 			goto out_free_group;
 	}
 
-	err = vlan_group_prealloc_vid(grp, vlan_id);
+	err = vlan_group_prealloc_vid(grp, protocol, vlan_id);
 	if (err < 0)
 		goto out_uninit_applicant;
 
@@ -203,7 +232,7 @@ int register_vlan_dev(struct net_device *dev)
 	/* So, got the sucker initialized, now lets place
 	 * it into our local structure.
 	 */
-	vlan_group_set_device(grp, vlan_id, dev);
+	vlan_group_set_device_pidx(grp, vlan_pidx(protocol), vlan_id, dev);
 	grp->nr_vlans++;
 
 	if (ngrp) {
@@ -211,7 +240,7 @@ int register_vlan_dev(struct net_device *dev)
 			ops->ndo_vlan_rx_register(real_dev, ngrp);
 		rcu_assign_pointer(real_dev->vlgrp, ngrp);
 	}
-	if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
+	if (protocol == ETH_P_8021Q && real_dev->features & NETIF_F_HW_VLAN_FILTER)
 		ops->ndo_vlan_rx_add_vid(real_dev, vlan_id);
 
 	return 0;
@@ -230,18 +259,26 @@ out_free_group:
 /*  Attach a VLAN device to a mac address (ie Ethernet Card).
  *  Returns 0 if the device was created or a negative error code otherwise.
  */
-static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
+static int register_vlan_device(struct net_device *real_dev,
+				u16 protocol, u16 vlan_id)
 {
 	struct net_device *new_dev;
 	struct net *net = dev_net(real_dev);
 	struct vlan_net *vn = net_generic(net, vlan_net_id);
 	char name[IFNAMSIZ];
+	static const char *protonames[VLAN_N_PROTOCOL] = {
+		[VLAN_PROTOIDX_8021Q]	= "",
+		[VLAN_PROTOIDX_8021AD]	= "1ad",
+		[VLAN_PROTOIDX_QINQ1]	= "91-",
+		[VLAN_PROTOIDX_QINQ2]	= "92-",
+		[VLAN_PROTOIDX_QINQ3]	= "93-"
+	};
 	int err;
 
 	if (vlan_id >= VLAN_VID_MASK)
 		return -ERANGE;
 
-	err = vlan_check_real_dev(real_dev, vlan_id);
+	err = vlan_check_real_dev(real_dev, protocol, vlan_id);
 	if (err < 0)
 		return err;
 
@@ -249,26 +286,30 @@ static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
 	switch (vn->name_type) {
 	case VLAN_NAME_TYPE_RAW_PLUS_VID:
 		/* name will look like:	 eth1.0005 */
-		snprintf(name, IFNAMSIZ, "%s.%.4i", real_dev->name, vlan_id);
+		snprintf(name, IFNAMSIZ, "%s.%s%.4i", real_dev->name,
+				protonames[vlan_pidx(protocol)], vlan_id);
 		break;
 	case VLAN_NAME_TYPE_PLUS_VID_NO_PAD:
 		/* Put our vlan.VID in the name.
 		 * Name will look like:	 vlan5
 		 */
-		snprintf(name, IFNAMSIZ, "vlan%i", vlan_id);
+		snprintf(name, IFNAMSIZ, "vlan%s%i",
+				protonames[vlan_pidx(protocol)], vlan_id);
 		break;
 	case VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD:
 		/* Put our vlan.VID in the name.
 		 * Name will look like:	 eth0.5
 		 */
-		snprintf(name, IFNAMSIZ, "%s.%i", real_dev->name, vlan_id);
+		snprintf(name, IFNAMSIZ, "%s.%s%i", real_dev->name,
+				protonames[vlan_pidx(protocol)], vlan_id);
 		break;
 	case VLAN_NAME_TYPE_PLUS_VID:
 		/* Put our vlan.VID in the name.
 		 * Name will look like:	 vlan0005
 		 */
 	default:
-		snprintf(name, IFNAMSIZ, "vlan%.4i", vlan_id);
+		snprintf(name, IFNAMSIZ, "vlan%s%.4i",
+				protonames[vlan_pidx(protocol)], vlan_id);
 	}
 
 	new_dev = alloc_netdev(sizeof(struct vlan_dev_info), name, vlan_setup);
@@ -282,6 +323,7 @@ static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
 	 */
 	new_dev->mtu = real_dev->mtu;
 
+	vlan_dev_info(new_dev)->protocol = protocol;
 	vlan_dev_info(new_dev)->vlan_id = vlan_id;
 	vlan_dev_info(new_dev)->real_dev = real_dev;
 	vlan_dev_info(new_dev)->dent = NULL;
@@ -359,6 +401,12 @@ static void __vlan_device_event(struct net_device *dev, unsigned long event)
 	}
 }
 
+#define vlangrp_for_each_dev(i, grp, vlandev) \
+	for (i = 0; i < VLAN_N_VID * VLAN_N_PROTOCOL; i++) \
+		if ((vlandev = vlan_group_get_device_pidx(grp, \
+					i / VLAN_N_VID, i % VLAN_N_VID)))
+			/* { code here } */
+
 static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 			     void *ptr)
 {
@@ -391,22 +439,14 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 	switch (event) {
 	case NETDEV_CHANGE:
 		/* Propagate real device state to vlan devices */
-		for (i = 0; i < VLAN_N_VID; i++) {
-			vlandev = vlan_group_get_device(grp, i);
-			if (!vlandev)
-				continue;
-
+		vlangrp_for_each_dev(i, grp, vlandev) {
 			netif_stacked_transfer_operstate(dev, vlandev);
 		}
 		break;
 
 	case NETDEV_CHANGEADDR:
 		/* Adjust unicast filters on underlying device */
-		for (i = 0; i < VLAN_N_VID; i++) {
-			vlandev = vlan_group_get_device(grp, i);
-			if (!vlandev)
-				continue;
-
+		vlangrp_for_each_dev(i, grp, vlandev) {
 			flgs = vlandev->flags;
 			if (!(flgs & IFF_UP))
 				continue;
@@ -416,11 +456,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 		break;
 
 	case NETDEV_CHANGEMTU:
-		for (i = 0; i < VLAN_N_VID; i++) {
-			vlandev = vlan_group_get_device(grp, i);
-			if (!vlandev)
-				continue;
-
+		vlangrp_for_each_dev(i, grp, vlandev) {
 			if (vlandev->mtu <= dev->mtu)
 				continue;
 
@@ -430,11 +466,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 
 	case NETDEV_FEAT_CHANGE:
 		/* Propagate device features to underlying device */
-		for (i = 0; i < VLAN_N_VID; i++) {
-			vlandev = vlan_group_get_device(grp, i);
-			if (!vlandev)
-				continue;
-
+		vlangrp_for_each_dev(i, grp, vlandev) {
 			vlan_transfer_features(dev, vlandev);
 		}
 
@@ -442,11 +474,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 
 	case NETDEV_DOWN:
 		/* Put all VLANs for this dev in the down state too.  */
-		for (i = 0; i < VLAN_N_VID; i++) {
-			vlandev = vlan_group_get_device(grp, i);
-			if (!vlandev)
-				continue;
-
+		vlangrp_for_each_dev(i, grp, vlandev) {
 			flgs = vlandev->flags;
 			if (!(flgs & IFF_UP))
 				continue;
@@ -460,11 +488,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 
 	case NETDEV_UP:
 		/* Put all VLANs for this dev in the up state too.  */
-		for (i = 0; i < VLAN_N_VID; i++) {
-			vlandev = vlan_group_get_device(grp, i);
-			if (!vlandev)
-				continue;
-
+		vlangrp_for_each_dev(i, grp, vlandev) {
 			flgs = vlandev->flags;
 			if (flgs & IFF_UP)
 				continue;
@@ -481,17 +505,14 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 		if (dev->reg_state != NETREG_UNREGISTERING)
 			break;
 
-		for (i = 0; i < VLAN_N_VID; i++) {
-			vlandev = vlan_group_get_device(grp, i);
-			if (!vlandev)
-				continue;
-
-			/* unregistration of last vlan destroys group, abort
-			 * afterwards */
-			if (grp->nr_vlans == 1)
-				i = VLAN_N_VID;
+		vlangrp_for_each_dev(i, grp, vlandev) {
+			unsigned int nr = grp->nr_vlans;
 
 			unregister_vlan_dev(vlandev, &list);
+
+			/* if it was the last VLAN, grp is now gone */
+			if (nr == 1)
+				break;
 		}
 		unregister_netdevice_many(&list);
 		break;
@@ -503,11 +524,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 	case NETDEV_NOTIFY_PEERS:
 	case NETDEV_BONDING_FAILOVER:
 		/* Propagate to vlan devices */
-		for (i = 0; i < VLAN_N_VID; i++) {
-			vlandev = vlan_group_get_device(grp, i);
-			if (!vlandev)
-				continue;
-
+		vlangrp_for_each_dev(i, grp, vlandev) {
 			call_netdevice_notifiers(event, vlandev);
 		}
 		break;
@@ -608,7 +625,7 @@ static int vlan_ioctl_handler(struct net *net, void __user *arg)
 		err = -EPERM;
 		if (!capable(CAP_NET_ADMIN))
 			break;
-		err = register_vlan_device(dev, args.u.VID);
+		err = register_vlan_device(dev, ETH_P_8021Q, args.u.VID);
 		break;
 
 	case DEL_VLAN_CMD:
@@ -668,6 +685,39 @@ static struct pernet_operations vlan_net_ops = {
 	.size = sizeof(struct vlan_net),
 };
 
+static int vlan_rcv(struct sk_buff *skb, struct net_device *dev,
+                   struct packet_type *pt, struct net_device *orig_dev)
+{
+	u16 protocol = be16_to_cpu(pt->type);
+
+	skb = vlan_untag(skb);
+	if (unlikely(!skb))
+		return 0;
+	if (vlan_do_receive(&skb, vlan_pidx(protocol), protocol))
+		return netif_receive_skb(skb);
+
+	if (likely(skb))
+		kfree_skb(skb);
+	return 0;
+}
+
+static struct packet_type vlan_1ad_type __read_mostly = {
+	.type = cpu_to_be16(ETH_P_8021AD),
+	.func = vlan_rcv,
+};
+static struct packet_type vlan_qq1_type __read_mostly = {
+	.type = cpu_to_be16(ETH_P_QINQ1),
+	.func = vlan_rcv,
+};
+static struct packet_type vlan_qq2_type __read_mostly = {
+	.type = cpu_to_be16(ETH_P_QINQ2),
+	.func = vlan_rcv,
+};
+static struct packet_type vlan_qq3_type __read_mostly = {
+	.type = cpu_to_be16(ETH_P_QINQ3),
+	.func = vlan_rcv,
+};
+
 static int __init vlan_proto_init(void)
 {
 	int err;
@@ -691,6 +741,11 @@ static int __init vlan_proto_init(void)
 		goto err4;
 
 	vlan_ioctl_set(vlan_ioctl_handler);
+
+	dev_add_pack(&vlan_1ad_type);
+	dev_add_pack(&vlan_qq1_type);
+	dev_add_pack(&vlan_qq2_type);
+	dev_add_pack(&vlan_qq3_type);
 	return 0;
 
 err4:
@@ -705,6 +760,11 @@ err0:
 
 static void __exit vlan_cleanup_module(void)
 {
+	dev_remove_pack(&vlan_1ad_type);
+	dev_remove_pack(&vlan_qq1_type);
+	dev_remove_pack(&vlan_qq2_type);
+	dev_remove_pack(&vlan_qq3_type);
+
 	vlan_ioctl_set(NULL);
 	vlan_netlink_fini();
 
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index b132f54..2043b06 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -46,6 +46,7 @@ struct vlan_pcpu_stats {
  *	@ingress_priority_map: ingress priority mappings
  *	@nr_egress_mappings: number of egress priority mappings
  *	@egress_priority_map: hash of egress priority mappings
+ *	@protocol: encapsulation protocol value (8100, 88a8, 9x00)
  *	@vlan_id: VLAN identifier
  *	@flags: device flags
  *	@real_dev: underlying netdevice
@@ -59,6 +60,7 @@ struct vlan_dev_info {
 	unsigned int				nr_egress_mappings;
 	struct vlan_priority_tci_mapping	*egress_priority_map[16];
 
+	u16					protocol;
 	u16					vlan_id;
 	u16					flags;
 
@@ -76,12 +78,12 @@ static inline struct vlan_dev_info *vlan_dev_info(const struct net_device *dev)
 
 /* Must be invoked with rcu_read_lock or with RTNL. */
 static inline struct net_device *vlan_find_dev(struct net_device *real_dev,
-					       u16 vlan_id)
+					       int pidx, u16 vlan_id)
 {
 	struct vlan_group *grp = rcu_dereference_rtnl(real_dev->vlgrp);
 
 	if (grp)
-		return vlan_group_get_device(grp, vlan_id);
+		return vlan_group_get_device_pidx(grp, pidx, vlan_id);
 
 	return NULL;
 }
@@ -94,7 +96,8 @@ int vlan_dev_set_egress_priority(const struct net_device *dev,
 int vlan_dev_change_flags(const struct net_device *dev, u32 flag, u32 mask);
 void vlan_dev_get_realdev_name(const struct net_device *dev, char *result);
 
-int vlan_check_real_dev(struct net_device *real_dev, u16 vlan_id);
+int vlan_check_real_dev(struct net_device *real_dev,
+			u16 protocol, u16 vlan_id);
 void vlan_setup(struct net_device *dev);
 int register_vlan_dev(struct net_device *dev);
 void unregister_vlan_dev(struct net_device *dev, struct list_head *head);
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index fcc6846..921e240 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -4,14 +4,14 @@
 #include <linux/netpoll.h>
 #include "vlan.h"
 
-bool vlan_do_receive(struct sk_buff **skbp)
+bool vlan_do_receive(struct sk_buff **skbp, int pidx, u16 protocol)
 {
 	struct sk_buff *skb = *skbp;
 	u16 vlan_id = skb->vlan_tci & VLAN_VID_MASK;
 	struct net_device *vlan_dev;
 	struct vlan_pcpu_stats *rx_stats;
 
-	vlan_dev = vlan_find_dev(skb->dev, vlan_id);
+	vlan_dev = vlan_find_dev(skb->dev, pidx, vlan_id);
 	if (!vlan_dev) {
 		if (vlan_id)
 			skb->pkt_type = PACKET_OTHERHOST;
@@ -41,7 +41,7 @@ bool vlan_do_receive(struct sk_buff **skbp)
 		 * original position later
 		 */
 		skb_push(skb, offset);
-		skb = *skbp = vlan_insert_tag(skb, skb->vlan_tci);
+		skb = *skbp = vlan_insert_tag(skb, protocol, skb->vlan_tci);
 		if (!skb)
 			return false;
 		skb_pull(skb, offset + VLAN_HLEN);
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 49bb752..67c6a66 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -119,8 +119,8 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 		else
 			vhdr->h_vlan_encapsulated_proto = htons(len);
 
-		skb->protocol = htons(ETH_P_8021Q);
-		type = ETH_P_8021Q;
+		type = vlan_dev_info(dev)->protocol;
+		skb->protocol = htons(type);
 		vhdrlen = VLAN_HLEN;
 	}
 
@@ -140,6 +140,7 @@ static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
 					    struct net_device *dev)
 {
 	struct vlan_ethhdr *veth = (struct vlan_ethhdr *)(skb->data);
+	u16 protocol = vlan_dev_info(dev)->protocol;
 	unsigned int len;
 	int ret;
 
@@ -148,12 +149,15 @@ static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
 	 * NOTE: THIS ASSUMES DIX ETHERNET, SPECIFICALLY NOT SUPPORTING
 	 * OTHER THINGS LIKE FDDI/TokenRing/802.3 SNAPs...
 	 */
-	if (veth->h_vlan_proto != htons(ETH_P_8021Q) ||
+	if (veth->h_vlan_proto != htons(protocol) ||
 	    vlan_dev_info(dev)->flags & VLAN_FLAG_REORDER_HDR) {
 		u16 vlan_tci;
 		vlan_tci = vlan_dev_info(dev)->vlan_id;
 		vlan_tci |= vlan_dev_get_egress_qos_mask(dev, skb);
-		skb = __vlan_hwaccel_put_tag(skb, vlan_tci);
+		if (protocol == ETH_P_8021Q)
+			skb = __vlan_hwaccel_put_tag(skb, vlan_tci);
+		else
+			skb = vlan_insert_tag(skb, protocol, vlan_tci);
 	}
 
 	skb_set_dev(skb, vlan_dev_info(dev)->real_dev);
@@ -547,7 +551,8 @@ static int vlan_dev_init(struct net_device *dev)
 #endif
 
 	dev->needed_headroom = real_dev->needed_headroom;
-	if (real_dev->features & NETIF_F_HW_VLAN_TX) {
+	if (vlan_dev_info(dev)->protocol == ETH_P_8021Q
+			&& real_dev->features & NETIF_F_HW_VLAN_TX) {
 		dev->header_ops      = real_dev->header_ops;
 		dev->hard_header_len = real_dev->hard_header_len;
 	} else {
diff --git a/net/8021q/vlan_gvrp.c b/net/8021q/vlan_gvrp.c
index 061cece..83c6728 100644
--- a/net/8021q/vlan_gvrp.c
+++ b/net/8021q/vlan_gvrp.c
@@ -32,6 +32,9 @@ int vlan_gvrp_request_join(const struct net_device *dev)
 	const struct vlan_dev_info *vlan = vlan_dev_info(dev);
 	__be16 vlan_id = htons(vlan->vlan_id);
 
+	if (vlan->protocol != ETH_P_8021Q)
+		return 0;
+
 	return garp_request_join(vlan->real_dev, &vlan_gvrp_app,
 				 &vlan_id, sizeof(vlan_id), GVRP_ATTR_VID);
 }
@@ -41,6 +44,9 @@ void vlan_gvrp_request_leave(const struct net_device *dev)
 	const struct vlan_dev_info *vlan = vlan_dev_info(dev);
 	__be16 vlan_id = htons(vlan->vlan_id);
 
+	if (vlan->protocol != ETH_P_8021Q)
+		return;
+
 	garp_request_leave(vlan->real_dev, &vlan_gvrp_app,
 			   &vlan_id, sizeof(vlan_id), GVRP_ATTR_VID);
 }
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index be9a5c1..418dc55 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -19,6 +19,7 @@
 
 static const struct nla_policy vlan_policy[IFLA_VLAN_MAX + 1] = {
 	[IFLA_VLAN_ID]		= { .type = NLA_U16 },
+	[IFLA_VLAN_PROTOCOL]	= { .type = NLA_U16 },
 	[IFLA_VLAN_FLAGS]	= { .len = sizeof(struct ifla_vlan_flags) },
 	[IFLA_VLAN_EGRESS_QOS]	= { .type = NLA_NESTED },
 	[IFLA_VLAN_INGRESS_QOS] = { .type = NLA_NESTED },
@@ -57,6 +58,19 @@ static int vlan_validate(struct nlattr *tb[], struct nlattr *data[])
 		if (id >= VLAN_VID_MASK)
 			return -ERANGE;
 	}
+	if (data[IFLA_VLAN_PROTOCOL]) {
+		id = nla_get_u16(data[IFLA_VLAN_PROTOCOL]);
+		switch (id) {
+		case ETH_P_8021Q:
+		case ETH_P_8021AD:
+		case ETH_P_QINQ1:
+		case ETH_P_QINQ2:
+		case ETH_P_QINQ3:
+			break;
+		default:
+			return -EINVAL;
+		}
+	}
 	if (data[IFLA_VLAN_FLAGS]) {
 		flags = nla_data(data[IFLA_VLAN_FLAGS]);
 		if ((flags->flags & flags->mask) &
@@ -118,10 +132,12 @@ static int vlan_newlink(struct net *src_net, struct net_device *dev,
 		return -ENODEV;
 
 	vlan->vlan_id  = nla_get_u16(data[IFLA_VLAN_ID]);
+	vlan->protocol = data[IFLA_VLAN_PROTOCOL]
+			? nla_get_u16(data[IFLA_VLAN_PROTOCOL]) : ETH_P_8021Q;
 	vlan->real_dev = real_dev;
 	vlan->flags    = VLAN_FLAG_REORDER_HDR;
 
-	err = vlan_check_real_dev(real_dev, vlan->vlan_id);
+	err = vlan_check_real_dev(real_dev, vlan->protocol, vlan->vlan_id);
 	if (err < 0)
 		return err;
 
@@ -150,7 +166,7 @@ static size_t vlan_get_size(const struct net_device *dev)
 {
 	struct vlan_dev_info *vlan = vlan_dev_info(dev);
 
-	return nla_total_size(2) +	/* IFLA_VLAN_ID */
+	return nla_total_size(4) +	/* IFLA_VLAN_ID + _PROTOCOL */
 	       sizeof(struct ifla_vlan_flags) + /* IFLA_VLAN_FLAGS */
 	       vlan_qos_map_size(vlan->nr_ingress_mappings) +
 	       vlan_qos_map_size(vlan->nr_egress_mappings);
@@ -166,6 +182,7 @@ static int vlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	unsigned int i;
 
 	NLA_PUT_U16(skb, IFLA_VLAN_ID, vlan_dev_info(dev)->vlan_id);
+	NLA_PUT_U16(skb, IFLA_VLAN_PROTOCOL, vlan_dev_info(dev)->protocol);
 	if (vlan->flags) {
 		f.flags = vlan->flags;
 		f.mask  = ~0;
diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index d34b6da..7e6464c 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -270,8 +270,11 @@ static int vlan_seq_show(struct seq_file *seq, void *v)
 		const struct net_device *vlandev = v;
 		const struct vlan_dev_info *dev_info = vlan_dev_info(vlandev);
 
-		seq_printf(seq, "%-15s| %d  | %s\n",  vlandev->name,
-			   dev_info->vlan_id,    dev_info->real_dev->name);
+		seq_printf(seq, "%-15s| ", vlandev->name);
+		if (dev_info->protocol != ETH_P_8021Q)
+			seq_printf(seq, "%04x:", dev_info->protocol);
+		seq_printf(seq, "%d  | %s\n", dev_info->vlan_id,
+				dev_info->real_dev->name);
 	}
 	return 0;
 }
@@ -301,6 +304,8 @@ static int vlandev_seq_show(struct seq_file *seq, void *offset)
 	seq_printf(seq, fmt64, "total frames transmitted", stats->tx_packets);
 	seq_printf(seq, fmt64, "total bytes transmitted", stats->tx_bytes);
 	seq_printf(seq, "Device: %s", dev_info->real_dev->name);
+	if (dev_info->protocol != ETH_P_8021Q)
+		seq_printf(seq, ", protocol 0x%04x", dev_info->protocol);
 	/* now show all PRIORITY mappings relating to this VLAN */
 	seq_printf(seq, "\nINGRESS priority mappings: "
 			"0:%u  1:%u  2:%u  3:%u  4:%u  5:%u  6:%u 7:%u\n",
diff --git a/net/core/dev.c b/net/core/dev.c
index 9444c5c..ece5fd3 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3187,7 +3187,7 @@ ncls:
 			ret = deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev = NULL;
 		}
-		if (vlan_do_receive(&skb)) {
+		if (vlan_do_receive(&skb, VLAN_PROTOIDX_8021Q, ETH_P_8021Q)) {
 			ret = __netif_receive_skb(skb);
 			goto out;
 		} else if (unlikely(!skb))
-- 
1.7.5.3

