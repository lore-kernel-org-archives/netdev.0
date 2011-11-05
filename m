From: David Lamparter <equinox@diac24.net>
Subject: [PATCH 1/2] net: vlan: 802.1ad S-VLAN support
Date: Sat,  5 Nov 2011 17:54:14 +0100
Message-ID: <1320512055-1231037-2-git-send-email-equinox@diac24.net>
References: <1320512055-1231037-1-git-send-email-equinox@diac24.net>
Cc: David Lamparter <equinox@diac24.net>,
	Patrick McHardy <kaber@trash.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:38700 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753697Ab1KERDT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Nov 2011 13:03:19 -0400
In-Reply-To: <1320512055-1231037-1-git-send-email-equinox@diac24.net>
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

Signed-off-by: David Lamparter <equinox@diac24.net>
Cc: Patrick McHardy <kaber@trash.net>
---
[v1: rebased onto current net-next with vlan restructuring; cleaned up
     module symbols; removed incomplete/unused ioctl .1ad support;
     fixed nla_total_size mess-up; added some documentation]
---
 Documentation/networking/ieee802_1ad.txt |   56 +++++++++++++
 include/linux/if_link.h                  |    1 +
 include/linux/if_vlan.h                  |   24 ++++--
 net/8021q/Kconfig                        |    7 ++-
 net/8021q/vlan.c                         |  131 ++++++++++++++++-------------
 net/8021q/vlan.h                         |   34 ++++++---
 net/8021q/vlan_core.c                    |   26 +++++-
 net/8021q/vlan_dev.c                     |   15 +++-
 net/8021q/vlan_gvrp.c                    |    6 ++
 net/8021q/vlan_netlink.c                 |   21 +++++-
 net/8021q/vlanproc.c                     |    9 ++-
 net/core/dev.c                           |    2 +-
 12 files changed, 242 insertions(+), 90 deletions(-)
 create mode 100644 Documentation/networking/ieee802_1ad.txt

diff --git a/Documentation/networking/ieee802_1ad.txt b/Documentation/networking/ieee802_1ad.txt
new file mode 100644
index 0000000..b0945e3
--- /dev/null
+++ b/Documentation/networking/ieee802_1ad.txt
@@ -0,0 +1,56 @@
+
+		(Linux) IEEE 802.1ad caveats
+
+
+What is 802.1ad?
+================
+
+802.1ad, "S-VLAN" or "Carrier" VLANs, is basically just your old 802.1Q VLAN,
+but with a new protocol value. Due to the history of S-VLANs, there are
+several protocol values in use. The officially allocated value is 0x88a8;
+Nortel originally used 0x9100, 0x9200 and 0x9300. Linux currently supports
+those 4 values and can be extended if need arises.
+
+802.1ad S-VLANs usually carry an inner layer of 802.1Q VLANs. To do so with
+Linux, just create an 802.1Q device on top of the 802.1ad device.
+
+
+How to use
+==========
+
+vconfig/ioctl is not supported with 802.1ad.
+
+Acquire a recent version of iproute2 and use
+"ip link add link ... type vlan ... protocol ..."
+
+
+Frame size caveats
+==================
+
+802.1ad increases ethernet frame size by 4 bytes, just like 802.1Q VLANs do.
+
+To keep the upper-layer MTU at the 1500 bytes it is supposed to be, you will
+need to make sure that both your NICs and your ethernet switches support the
+resulting frames.
+
+The Linux kernel does currently _not_ track individual NIC's hardware
+capabilities, however since it can't test your switch capabilities you will
+need to verify by testing either way. Make sure to use your desired production
+VLAN stack-up and try "ping -s 1472". If it doesn't work, you will need to
+reduce the MTU on _all_ nodes on that particular broadcast domain.
+
+General expectations on support are:
+
+ - expect all 10/100 ethernet switches to cause problems. These usually
+   support either 1500 bytes or 1500 bytes plus 802.1Q tags and nothing else.
+   Even if 802.1Q is supported, they won't recognise 802.1ad tags as VLAN tags
+   and subject packets to normal length checks (which will fail).
+
+ - Jumbo Frame capable equipment (Gigabit Ethernet) should be able to handle
+   802.1ad frames, but you might need to shrink your (jumbo) MTU by 4 bytes.
+
+ - a good part of 10/100 NICs (and non-jumbo 1GE NICs) don't have the size
+   limit at 1514/1518 bytes but at 1536 or 2048 bytes. These will work fine.
+
+ - if your NIC already has problems with 802.1Q, don't expect it to work with
+   802.1ad.
diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index c52d4b5..b45d2d9 100644
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
index 44da482..522b464 100644
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
 
@@ -87,7 +97,8 @@ struct vlan_group {
 					    */
 	unsigned int		nr_vlans;
 	struct hlist_node	hlist;	/* linked list */
-	struct net_device **vlan_devices_arrays[VLAN_GROUP_ARRAY_SPLIT_PARTS];
+	struct net_device **vlan_devices_arrays[VLAN_N_PROTOCOL]
+						[VLAN_GROUP_ARRAY_SPLIT_PARTS];
 	struct rcu_head		rcu;
 };
 
@@ -106,7 +117,7 @@ extern struct net_device *__vlan_find_dev_deep(struct net_device *real_dev,
 extern struct net_device *vlan_dev_real_dev(const struct net_device *dev);
 extern u16 vlan_dev_vlan_id(const struct net_device *dev);
 
-extern bool vlan_do_receive(struct sk_buff **skb);
+extern bool vlan_do_receive(struct sk_buff **skb, int pidx, u16 protocol);
 extern struct sk_buff *vlan_untag(struct sk_buff *skb);
 
 #else
@@ -154,7 +165,8 @@ static inline struct sk_buff *vlan_untag(struct sk_buff *skb)
  *
  * Does not change skb->protocol so this function can be used during receive.
  */
-static inline struct sk_buff *vlan_insert_tag(struct sk_buff *skb, u16 vlan_tci)
+static inline struct sk_buff *vlan_insert_tag(struct sk_buff *skb,
+					      u16 protocol, u16 vlan_tci)
 {
 	struct vlan_ethhdr *veth;
 
@@ -169,7 +181,7 @@ static inline struct sk_buff *vlan_insert_tag(struct sk_buff *skb, u16 vlan_tci)
 	skb->mac_header -= VLAN_HLEN;
 
 	/* first, the ethernet type */
-	veth->h_vlan_proto = htons(ETH_P_8021Q);
+	veth->h_vlan_proto = htons(protocol);
 
 	/* now, the TCI */
 	veth->h_vlan_TCI = htons(vlan_tci);
@@ -190,7 +202,7 @@ static inline struct sk_buff *vlan_insert_tag(struct sk_buff *skb, u16 vlan_tci)
  */
 static inline struct sk_buff *__vlan_put_tag(struct sk_buff *skb, u16 vlan_tci)
 {
-	skb = vlan_insert_tag(skb, vlan_tci);
+	skb = vlan_insert_tag(skb, ETH_P_8021Q, vlan_tci);
 	if (skb)
 		skb->protocol = htons(ETH_P_8021Q);
 	return skb;
diff --git a/net/8021q/Kconfig b/net/8021q/Kconfig
index fa073a5..fcfa1c3 100644
--- a/net/8021q/Kconfig
+++ b/net/8021q/Kconfig
@@ -3,7 +3,7 @@
 #
 
 config VLAN_8021Q
-	tristate "802.1Q VLAN Support"
+	tristate "802.1Q/.1ad VLAN Support"
 	---help---
 	  Select this and you will be able to create 802.1Q VLAN interfaces
 	  on your ethernet interfaces.  802.1Q VLAN supports almost
@@ -13,6 +13,11 @@ config VLAN_8021Q
 	  use VLANs.  See the VLAN web page for more information:
 	  <http://www.candelatech.com/~greear/vlan.html>
 
+	  This code also supports 802.1ad S-VLANs if used in conjunction
+	  with a recent version of iproute2. Make sure to read
+	  Documentation/networking/ieee802_1ad.txt and understand the
+	  caveats associated with frame size restrictions.
+
 	  To compile this code as a module, choose M here: the module
 	  will be called 8021q.
 
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 5471628..23a250e 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -46,17 +46,18 @@
 
 int vlan_net_id __read_mostly;
 
-const char vlan_fullname[] = "802.1Q VLAN Support";
+const char vlan_fullname[] = "802.1Q/.1ad VLAN Support";
 const char vlan_version[] = DRV_VERSION;
 
 /* End of global variables definitions. */
 
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
 
@@ -72,14 +73,16 @@ static struct vlan_group *vlan_group_alloc(struct net_device *real_dev)
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
 
@@ -88,7 +91,8 @@ static int vlan_group_prealloc_vid(struct vlan_group *vg, u16 vlan_id)
 	if (array == NULL)
 		return -ENOBUFS;
 
-	vg->vlan_devices_arrays[vlan_id / VLAN_GROUP_ARRAY_PART_LEN] = array;
+	vg->vlan_devices_arrays[vlan_pidx(protocol)]
+				[vlan_id / VLAN_GROUP_ARRAY_PART_LEN] = array;
 	return 0;
 }
 
@@ -103,6 +107,7 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 	struct net_device *real_dev = vlan->real_dev;
 	const struct net_device_ops *ops = real_dev->netdev_ops;
 	struct vlan_group *grp;
+	u16 protocol = vlan->protocol;
 	u16 vlan_id = vlan->vlan_id;
 
 	ASSERT_RTNL();
@@ -114,7 +119,8 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 	 * HW accelerating devices or SW vlan input packet processing if
 	 * VLAN is not 0 (leave it there for 802.1p).
 	 */
-	if (vlan_id && (real_dev->features & NETIF_F_HW_VLAN_FILTER))
+	if (vlan_id && protocol == ETH_P_8021Q &&
+			(real_dev->features & NETIF_F_HW_VLAN_FILTER))
 		ops->ndo_vlan_rx_kill_vid(real_dev, vlan_id);
 
 	grp->nr_vlans--;
@@ -122,7 +128,7 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 	if (vlan->flags & VLAN_FLAG_GVRP)
 		vlan_gvrp_request_leave(dev);
 
-	vlan_group_set_device(grp, vlan_id, NULL);
+	vlan_group_set_device_pidx(grp, vlan_pidx(protocol), vlan_id, NULL);
 	/* Because unregister_netdevice_queue() makes sure at least one rcu
 	 * grace period is respected before device freeing,
 	 * we dont need to call synchronize_net() here.
@@ -143,7 +149,8 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 	dev_put(real_dev);
 }
 
-int vlan_check_real_dev(struct net_device *real_dev, u16 vlan_id)
+int vlan_check_real_dev(struct net_device *real_dev,
+			u16 protocol, u16 vlan_id)
 {
 	const char *name = real_dev->name;
 	const struct net_device_ops *ops = real_dev->netdev_ops;
@@ -159,7 +166,7 @@ int vlan_check_real_dev(struct net_device *real_dev, u16 vlan_id)
 		return -EOPNOTSUPP;
 	}
 
-	if (vlan_find_dev(real_dev, vlan_id) != NULL)
+	if (vlan_find_dev(real_dev, vlan_pidx(protocol), vlan_id) != NULL)
 		return -EEXIST;
 
 	return 0;
@@ -171,6 +178,7 @@ int register_vlan_dev(struct net_device *dev)
 	struct net_device *real_dev = vlan->real_dev;
 	const struct net_device_ops *ops = real_dev->netdev_ops;
 	u16 vlan_id = vlan->vlan_id;
+	u16 protocol = vlan->protocol;
 	struct vlan_group *grp, *ngrp = NULL;
 	int err;
 
@@ -184,7 +192,7 @@ int register_vlan_dev(struct net_device *dev)
 			goto out_free_group;
 	}
 
-	err = vlan_group_prealloc_vid(grp, vlan_id);
+	err = vlan_group_prealloc_vid(grp, protocol, vlan_id);
 	if (err < 0)
 		goto out_uninit_applicant;
 
@@ -201,13 +209,13 @@ int register_vlan_dev(struct net_device *dev)
 	/* So, got the sucker initialized, now lets place
 	 * it into our local structure.
 	 */
-	vlan_group_set_device(grp, vlan_id, dev);
+	vlan_group_set_device_pidx(grp, vlan_pidx(protocol), vlan_id, dev);
 	grp->nr_vlans++;
 
 	if (ngrp) {
 		rcu_assign_pointer(real_dev->vlgrp, ngrp);
 	}
-	if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
+	if (protocol == ETH_P_8021Q && real_dev->features & NETIF_F_HW_VLAN_FILTER)
 		ops->ndo_vlan_rx_add_vid(real_dev, vlan_id);
 
 	return 0;
@@ -225,6 +233,8 @@ out_free_group:
 
 /*  Attach a VLAN device to a mac address (ie Ethernet Card).
  *  Returns 0 if the device was created or a negative error code otherwise.
+ *  Only used for ioctl; netlink gets the name from userspace and saves
+ *  some complexity.
  */
 static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
 {
@@ -237,7 +247,7 @@ static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
 	if (vlan_id >= VLAN_VID_MASK)
 		return -ERANGE;
 
-	err = vlan_check_real_dev(real_dev, vlan_id);
+	err = vlan_check_real_dev(real_dev, ETH_P_8021Q, vlan_id);
 	if (err < 0)
 		return err;
 
@@ -278,6 +288,7 @@ static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
 	 */
 	new_dev->mtu = real_dev->mtu;
 
+	vlan_dev_info(new_dev)->protocol = ETH_P_8021Q;
 	vlan_dev_info(new_dev)->vlan_id = vlan_id;
 	vlan_dev_info(new_dev)->real_dev = real_dev;
 	vlan_dev_info(new_dev)->dent = NULL;
@@ -355,6 +366,12 @@ static void __vlan_device_event(struct net_device *dev, unsigned long event)
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
@@ -387,22 +404,14 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
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
@@ -412,11 +421,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
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
 
@@ -426,11 +431,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 
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
 
@@ -438,11 +439,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 
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
@@ -456,11 +453,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 
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
@@ -477,17 +470,14 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
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
@@ -499,11 +489,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
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
@@ -664,6 +650,23 @@ static struct pernet_operations vlan_net_ops = {
 	.size = sizeof(struct vlan_net),
 };
 
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
@@ -687,6 +690,11 @@ static int __init vlan_proto_init(void)
 		goto err4;
 
 	vlan_ioctl_set(vlan_ioctl_handler);
+
+	dev_add_pack(&vlan_1ad_type);
+	dev_add_pack(&vlan_qq1_type);
+	dev_add_pack(&vlan_qq2_type);
+	dev_add_pack(&vlan_qq3_type);
 	return 0;
 
 err4:
@@ -701,6 +709,11 @@ err0:
 
 static void __exit vlan_cleanup_module(void)
 {
+	dev_remove_pack(&vlan_qq3_type);
+	dev_remove_pack(&vlan_qq2_type);
+	dev_remove_pack(&vlan_qq1_type);
+	dev_remove_pack(&vlan_1ad_type);
+
 	vlan_ioctl_set(NULL);
 	vlan_netlink_fini();
 
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 9fd45f3..13b46f3 100644
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
 
@@ -74,33 +76,42 @@ static inline struct vlan_dev_info *vlan_dev_info(const struct net_device *dev)
 	return netdev_priv(dev);
 }
 
-static inline struct net_device *vlan_group_get_device(struct vlan_group *vg,
-						       u16 vlan_id)
+static inline int vlan_pidx(u16 protocol)
+{
+	if (likely(protocol == ETH_P_8021Q))
+		return VLAN_PROTOIDX_8021Q;
+	if (protocol == ETH_P_8021AD)
+		return VLAN_PROTOIDX_8021AD;
+	return ((protocol - ETH_P_QINQ1) >> 8) + VLAN_PROTOIDX_QINQ1;
+}
+
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
@@ -113,10 +124,13 @@ int vlan_dev_set_egress_priority(const struct net_device *dev,
 int vlan_dev_change_flags(const struct net_device *dev, u32 flag, u32 mask);
 void vlan_dev_get_realdev_name(const struct net_device *dev, char *result);
 
-int vlan_check_real_dev(struct net_device *real_dev, u16 vlan_id);
+int vlan_check_real_dev(struct net_device *real_dev,
+			u16 protocol, u16 vlan_id);
 void vlan_setup(struct net_device *dev);
 int register_vlan_dev(struct net_device *dev);
 void unregister_vlan_dev(struct net_device *dev, struct list_head *head);
+int vlan_rcv(struct sk_buff *skb, struct net_device *dev,
+	     struct packet_type *pt, struct net_device *orig_dev);
 
 static inline u32 vlan_get_ingress_priority(struct net_device *dev,
 					    u16 vlan_tci)
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index f1f2f7b..f83b9fa 100644
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
@@ -70,7 +70,8 @@ struct net_device *__vlan_find_dev_deep(struct net_device *real_dev,
 	struct vlan_group *grp = rcu_dereference_rtnl(real_dev->vlgrp);
 
 	if (grp) {
-		return vlan_group_get_device(grp, vlan_id);
+		return vlan_group_get_device_pidx(grp,
+				VLAN_PROTOIDX_8021Q, vlan_id);
 	} else {
 		/*
 		 * Bonding slaves do not have grp assigned to themselves.
@@ -175,3 +176,20 @@ err_free:
 	kfree_skb(skb);
 	return NULL;
 }
+
+int vlan_rcv(struct sk_buff *skb, struct net_device *dev,
+	     struct packet_type *pt, struct net_device *orig_dev)
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
+EXPORT_SYMBOL_GPL(vlan_rcv);
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index c8cf939..a30a4a4 100644
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
@@ -551,7 +555,8 @@ static int vlan_dev_init(struct net_device *dev)
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
index be9a5c1..44be0f6 100644
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
+	return nla_total_size(2) * 2 +	/* IFLA_VLAN_ID + _PROTOCOL */
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
index b7ba81a..10ac4f3 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3288,7 +3288,7 @@ ncls:
 			ret = deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev = NULL;
 		}
-		if (vlan_do_receive(&skb))
+		if (vlan_do_receive(&skb, VLAN_PROTOIDX_8021Q, ETH_P_8021Q))
 			goto another_round;
 		else if (unlikely(!skb))
 			goto out;
-- 
1.7.7
