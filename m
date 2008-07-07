From: Patrick McHardy <kaber@trash.net>
Subject: vlan 07/07: TCI related type and naming cleanups
Date: Mon,  7 Jul 2008 14:36:08 +0200 (MEST)
Message-ID: <20080707123607.23947.50965.sendpatchset@localhost.localdomain>
References: <20080707123557.23947.70114.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59287 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753507AbYGGMgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 08:36:10 -0400
In-Reply-To: <20080707123557.23947.70114.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vlan: TCI related type and naming cleanups

The VLAN code contains multiple spots that use tag, id and tci as
identifiers for arguments and variables incorrectly and they actually
contain or are expected to contain something different. Additionally
types are used inconsistently (unsigned short vs u16) and identifiers
are sometimes capitalized.

- consistently use u16 for storing TCI, ID or QoS values
- consistently use vlan_id and vlan_tci for storing the respective values
- remove capitalization
- add kdoc comment to netif_hwaccel_{rx,receive_skb}

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 030f4ae9fb86661142f2dc12079077ae79ffc98e
tree 59dcb702888222d4ccea79e241ed168976cd7335
parent daeb32dc9028e7929568becc899169cd8ff3e6ad
author Patrick McHardy <kaber@trash.net> Mon, 07 Jul 2008 14:26:45 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 07 Jul 2008 14:26:45 +0200

 include/linux/if_vlan.h |   84 +++++++++++++++++++++++++++--------------------
 net/8021q/vlan.c        |   34 +++++++++----------
 net/8021q/vlan.h        |   19 +++++------
 net/8021q/vlan_core.c   |    6 ++-
 net/8021q/vlan_dev.c    |   47 +++++++++++++-------------
 net/8021q/vlan_gvrp.c   |    8 ++--
 6 files changed, 103 insertions(+), 95 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 8e68b05..d36515d 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -87,7 +87,7 @@ struct vlan_group {
 };
 
 static inline struct net_device *vlan_group_get_device(struct vlan_group *vg,
-						       unsigned int vlan_id)
+						       u16 vlan_id)
 {
 	struct net_device **array;
 	array = vg->vlan_devices_arrays[vlan_id / VLAN_GROUP_ARRAY_PART_LEN];
@@ -95,7 +95,7 @@ static inline struct net_device *vlan_group_get_device(struct vlan_group *vg,
 }
 
 static inline void vlan_group_set_device(struct vlan_group *vg,
-					 unsigned int vlan_id,
+					 u16 vlan_id,
 					 struct net_device *dev)
 {
 	struct net_device **array;
@@ -122,7 +122,7 @@ extern struct net_device *vlan_dev_real_dev(const struct net_device *dev);
 extern u16 vlan_dev_vlan_id(const struct net_device *dev);
 
 extern int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
-			     unsigned short vlan_tag, int polling);
+			     u16 vlan_tci, int polling);
 #else
 static inline struct net_device *vlan_dev_real_dev(const struct net_device *dev)
 {
@@ -137,39 +137,51 @@ static inline u16 vlan_dev_vlan_id(const struct net_device *dev)
 }
 
 static inline int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
-				    unsigned short vlan_tag, int polling)
+				    u16 vlan_tci, int polling)
 {
 	BUG();
 	return NET_XMIT_SUCCESS;
 }
 #endif
 
+/**
+ * vlan_hwaccel_rx - netif_rx wrapper for VLAN RX acceleration
+ * @skb: buffer
+ * @grp: vlan group
+ * @vlan_tci: VLAN TCI as received from the card
+ */
 static inline int vlan_hwaccel_rx(struct sk_buff *skb,
 				  struct vlan_group *grp,
-				  unsigned short vlan_tag)
+				  u16 vlan_tci)
 {
-	return __vlan_hwaccel_rx(skb, grp, vlan_tag, 0);
+	return __vlan_hwaccel_rx(skb, grp, vlan_tci, 0);
 }
 
+/**
+ * vlan_hwaccel_receive_skb - netif_receive_skb wrapper for VLAN RX acceleration
+ * @skb: buffer
+ * @grp: vlan group
+ * @vlan_tci: VLAN TCI as received from the card
+ */
 static inline int vlan_hwaccel_receive_skb(struct sk_buff *skb,
 					   struct vlan_group *grp,
-					   unsigned short vlan_tag)
+					   u16 vlan_tci)
 {
-	return __vlan_hwaccel_rx(skb, grp, vlan_tag, 1);
+	return __vlan_hwaccel_rx(skb, grp, vlan_tci, 1);
 }
 
 /**
  * __vlan_put_tag - regular VLAN tag inserting
  * @skb: skbuff to tag
- * @tag: VLAN tag to insert
+ * @vlan_tci: VLAN TCI to insert
  *
  * Inserts the VLAN tag into @skb as part of the payload
  * Returns a VLAN tagged skb. If a new skb is created, @skb is freed.
- * 
+ *
  * Following the skb_unshare() example, in case of error, the calling function
  * doesn't have to worry about freeing the original skb.
  */
-static inline struct sk_buff *__vlan_put_tag(struct sk_buff *skb, unsigned short tag)
+static inline struct sk_buff *__vlan_put_tag(struct sk_buff *skb, u16 vlan_tci)
 {
 	struct vlan_ethhdr *veth;
 
@@ -197,8 +209,8 @@ static inline struct sk_buff *__vlan_put_tag(struct sk_buff *skb, unsigned short
 	/* first, the ethernet type */
 	veth->h_vlan_proto = htons(ETH_P_8021Q);
 
-	/* now, the tag */
-	veth->h_vlan_TCI = htons(tag);
+	/* now, the TCI */
+	veth->h_vlan_TCI = htons(vlan_tci);
 
 	skb->protocol = htons(ETH_P_8021Q);
 
@@ -208,17 +220,18 @@ static inline struct sk_buff *__vlan_put_tag(struct sk_buff *skb, unsigned short
 /**
  * __vlan_hwaccel_put_tag - hardware accelerated VLAN inserting
  * @skb: skbuff to tag
- * @tag: VLAN tag to insert
+ * @vlan_tci: VLAN TCI to insert
  *
- * Puts the VLAN tag in @skb->cb[] and lets the device do the rest
+ * Puts the VLAN TCI in @skb->cb[] and lets the device do the rest
  */
-static inline struct sk_buff *__vlan_hwaccel_put_tag(struct sk_buff *skb, unsigned short tag)
+static inline struct sk_buff *__vlan_hwaccel_put_tag(struct sk_buff *skb,
+						     u16 vlan_tci)
 {
 	struct vlan_skb_tx_cookie *cookie;
 
 	cookie = VLAN_TX_SKB_CB(skb);
 	cookie->magic = VLAN_TX_COOKIE_MAGIC;
-	cookie->vlan_tag = tag;
+	cookie->vlan_tag = vlan_tci;
 
 	return skb;
 }
@@ -228,28 +241,28 @@ static inline struct sk_buff *__vlan_hwaccel_put_tag(struct sk_buff *skb, unsign
 /**
  * vlan_put_tag - inserts VLAN tag according to device features
  * @skb: skbuff to tag
- * @tag: VLAN tag to insert
+ * @vlan_tci: VLAN TCI to insert
  *
  * Assumes skb->dev is the target that will xmit this frame.
  * Returns a VLAN tagged skb.
  */
-static inline struct sk_buff *vlan_put_tag(struct sk_buff *skb, unsigned short tag)
+static inline struct sk_buff *vlan_put_tag(struct sk_buff *skb, u16 vlan_tci)
 {
 	if (skb->dev->features & NETIF_F_HW_VLAN_TX) {
-		return __vlan_hwaccel_put_tag(skb, tag);
+		return __vlan_hwaccel_put_tag(skb, vlan_tci);
 	} else {
-		return __vlan_put_tag(skb, tag);
+		return __vlan_put_tag(skb, vlan_tci);
 	}
 }
 
 /**
  * __vlan_get_tag - get the VLAN ID that is part of the payload
  * @skb: skbuff to query
- * @tag: buffer to store vlaue
- * 
+ * @vlan_tci: buffer to store vlaue
+ *
  * Returns error if the skb is not of VLAN type
  */
-static inline int __vlan_get_tag(const struct sk_buff *skb, unsigned short *tag)
+static inline int __vlan_get_tag(const struct sk_buff *skb, u16 *vlan_tci)
 {
 	struct vlan_ethhdr *veth = (struct vlan_ethhdr *)skb->data;
 
@@ -257,29 +270,28 @@ static inline int __vlan_get_tag(const struct sk_buff *skb, unsigned short *tag)
 		return -EINVAL;
 	}
 
-	*tag = ntohs(veth->h_vlan_TCI);
-
+	*vlan_tci = ntohs(veth->h_vlan_TCI);
 	return 0;
 }
 
 /**
  * __vlan_hwaccel_get_tag - get the VLAN ID that is in @skb->cb[]
  * @skb: skbuff to query
- * @tag: buffer to store vlaue
- * 
+ * @vlan_tci: buffer to store vlaue
+ *
  * Returns error if @skb->cb[] is not set correctly
  */
 static inline int __vlan_hwaccel_get_tag(const struct sk_buff *skb,
-					 unsigned short *tag)
+					 u16 *vlan_tci)
 {
 	struct vlan_skb_tx_cookie *cookie;
 
 	cookie = VLAN_TX_SKB_CB(skb);
 	if (cookie->magic == VLAN_TX_COOKIE_MAGIC) {
-		*tag = cookie->vlan_tag;
+		*vlan_tci = cookie->vlan_tag;
 		return 0;
 	} else {
-		*tag = 0;
+		*vlan_tci = 0;
 		return -EINVAL;
 	}
 }
@@ -289,16 +301,16 @@ static inline int __vlan_hwaccel_get_tag(const struct sk_buff *skb,
 /**
  * vlan_get_tag - get the VLAN ID from the skb
  * @skb: skbuff to query
- * @tag: buffer to store vlaue
- * 
+ * @vlan_tci: buffer to store vlaue
+ *
  * Returns error if the skb is not VLAN tagged
  */
-static inline int vlan_get_tag(const struct sk_buff *skb, unsigned short *tag)
+static inline int vlan_get_tag(const struct sk_buff *skb, u16 *vlan_tci)
 {
 	if (skb->dev->features & NETIF_F_HW_VLAN_TX) {
-		return __vlan_hwaccel_get_tag(skb, tag);
+		return __vlan_hwaccel_get_tag(skb, vlan_tci);
 	} else {
-		return __vlan_get_tag(skb, tag);
+		return __vlan_get_tag(skb, vlan_tci);
 	}
 }
 
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 7a2625d..68bdcf4 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -83,13 +83,12 @@ static struct vlan_group *__vlan_find_group(struct net_device *real_dev)
  *
  * Must be invoked with RCU read lock (no preempt)
  */
-struct net_device *__find_vlan_dev(struct net_device *real_dev,
-				   unsigned short VID)
+struct net_device *__find_vlan_dev(struct net_device *real_dev, u16 vlan_id)
 {
 	struct vlan_group *grp = __vlan_find_group(real_dev);
 
 	if (grp)
-		return vlan_group_get_device(grp, VID);
+		return vlan_group_get_device(grp, vlan_id);
 
 	return NULL;
 }
@@ -117,14 +116,14 @@ static struct vlan_group *vlan_group_alloc(struct net_device *real_dev)
 	return grp;
 }
 
-static int vlan_group_prealloc_vid(struct vlan_group *vg, int vid)
+static int vlan_group_prealloc_vid(struct vlan_group *vg, u16 vlan_id)
 {
 	struct net_device **array;
 	unsigned int size;
 
 	ASSERT_RTNL();
 
-	array = vg->vlan_devices_arrays[vid / VLAN_GROUP_ARRAY_PART_LEN];
+	array = vg->vlan_devices_arrays[vlan_id / VLAN_GROUP_ARRAY_PART_LEN];
 	if (array != NULL)
 		return 0;
 
@@ -133,7 +132,7 @@ static int vlan_group_prealloc_vid(struct vlan_group *vg, int vid)
 	if (array == NULL)
 		return -ENOBUFS;
 
-	vg->vlan_devices_arrays[vid / VLAN_GROUP_ARRAY_PART_LEN] = array;
+	vg->vlan_devices_arrays[vlan_id / VLAN_GROUP_ARRAY_PART_LEN] = array;
 	return 0;
 }
 
@@ -147,7 +146,7 @@ void unregister_vlan_dev(struct net_device *dev)
 	struct vlan_dev_info *vlan = vlan_dev_info(dev);
 	struct net_device *real_dev = vlan->real_dev;
 	struct vlan_group *grp;
-	unsigned short vlan_id = vlan->vlan_id;
+	u16 vlan_id = vlan->vlan_id;
 
 	ASSERT_RTNL();
 
@@ -205,7 +204,7 @@ static void vlan_transfer_operstate(const struct net_device *dev,
 	}
 }
 
-int vlan_check_real_dev(struct net_device *real_dev, unsigned short vlan_id)
+int vlan_check_real_dev(struct net_device *real_dev, u16 vlan_id)
 {
 	char *name = real_dev->name;
 
@@ -242,7 +241,7 @@ int register_vlan_dev(struct net_device *dev)
 {
 	struct vlan_dev_info *vlan = vlan_dev_info(dev);
 	struct net_device *real_dev = vlan->real_dev;
-	unsigned short vlan_id = vlan->vlan_id;
+	u16 vlan_id = vlan->vlan_id;
 	struct vlan_group *grp, *ngrp = NULL;
 	int err;
 
@@ -295,8 +294,7 @@ out_free_group:
 /*  Attach a VLAN device to a mac address (ie Ethernet Card).
  *  Returns 0 if the device was created or a negative error code otherwise.
  */
-static int register_vlan_device(struct net_device *real_dev,
-				unsigned short VLAN_ID)
+static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
 {
 	struct net_device *new_dev;
 	struct net *net = dev_net(real_dev);
@@ -304,10 +302,10 @@ static int register_vlan_device(struct net_device *real_dev,
 	char name[IFNAMSIZ];
 	int err;
 
-	if (VLAN_ID >= VLAN_VID_MASK)
+	if (vlan_id >= VLAN_VID_MASK)
 		return -ERANGE;
 
-	err = vlan_check_real_dev(real_dev, VLAN_ID);
+	err = vlan_check_real_dev(real_dev, vlan_id);
 	if (err < 0)
 		return err;
 
@@ -315,26 +313,26 @@ static int register_vlan_device(struct net_device *real_dev,
 	switch (vn->name_type) {
 	case VLAN_NAME_TYPE_RAW_PLUS_VID:
 		/* name will look like:	 eth1.0005 */
-		snprintf(name, IFNAMSIZ, "%s.%.4i", real_dev->name, VLAN_ID);
+		snprintf(name, IFNAMSIZ, "%s.%.4i", real_dev->name, vlan_id);
 		break;
 	case VLAN_NAME_TYPE_PLUS_VID_NO_PAD:
 		/* Put our vlan.VID in the name.
 		 * Name will look like:	 vlan5
 		 */
-		snprintf(name, IFNAMSIZ, "vlan%i", VLAN_ID);
+		snprintf(name, IFNAMSIZ, "vlan%i", vlan_id);
 		break;
 	case VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD:
 		/* Put our vlan.VID in the name.
 		 * Name will look like:	 eth0.5
 		 */
-		snprintf(name, IFNAMSIZ, "%s.%i", real_dev->name, VLAN_ID);
+		snprintf(name, IFNAMSIZ, "%s.%i", real_dev->name, vlan_id);
 		break;
 	case VLAN_NAME_TYPE_PLUS_VID:
 		/* Put our vlan.VID in the name.
 		 * Name will look like:	 vlan0005
 		 */
 	default:
-		snprintf(name, IFNAMSIZ, "vlan%.4i", VLAN_ID);
+		snprintf(name, IFNAMSIZ, "vlan%.4i", vlan_id);
 	}
 
 	new_dev = alloc_netdev(sizeof(struct vlan_dev_info), name,
@@ -349,7 +347,7 @@ static int register_vlan_device(struct net_device *real_dev,
 	 */
 	new_dev->mtu = real_dev->mtu;
 
-	vlan_dev_info(new_dev)->vlan_id = VLAN_ID; /* 1 through VLAN_VID_MASK */
+	vlan_dev_info(new_dev)->vlan_id = vlan_id;
 	vlan_dev_info(new_dev)->real_dev = real_dev;
 	vlan_dev_info(new_dev)->dent = NULL;
 	vlan_dev_info(new_dev)->flags = VLAN_FLAG_REORDER_HDR;
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 14c421e..a6603a4 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -12,7 +12,7 @@
  */
 struct vlan_priority_tci_mapping {
 	u32					priority;
-	unsigned short				vlan_qos;
+	u16					vlan_qos;
 	struct vlan_priority_tci_mapping	*next;
 };
 
@@ -36,8 +36,8 @@ struct vlan_dev_info {
 	unsigned int				nr_egress_mappings;
 	struct vlan_priority_tci_mapping	*egress_priority_map[16];
 
-	unsigned short				vlan_id;
-	unsigned short				flags;
+	u16					vlan_id;
+	u16					flags;
 
 	struct net_device			*real_dev;
 	unsigned char				real_dev_addr[ETH_ALEN];
@@ -67,30 +67,29 @@ static inline struct vlan_dev_info *vlan_dev_info(const struct net_device *dev)
  *  Must be invoked with rcu_read_lock (ie preempt disabled)
  *  or with RTNL.
  */
-struct net_device *__find_vlan_dev(struct net_device *real_dev,
-				   unsigned short VID); /* vlan.c */
+struct net_device *__find_vlan_dev(struct net_device *real_dev, u16 vlan_id);
 
 /* found in vlan_dev.c */
 int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 		  struct packet_type *ptype, struct net_device *orig_dev);
 void vlan_dev_set_ingress_priority(const struct net_device *dev,
-				   u32 skb_prio, short vlan_prio);
+				   u32 skb_prio, u16 vlan_prio);
 int vlan_dev_set_egress_priority(const struct net_device *dev,
-				 u32 skb_prio, short vlan_prio);
+				 u32 skb_prio, u16 vlan_prio);
 int vlan_dev_change_flags(const struct net_device *dev, u32 flag, u32 mask);
 void vlan_dev_get_realdev_name(const struct net_device *dev, char *result);
 
-int vlan_check_real_dev(struct net_device *real_dev, unsigned short vlan_id);
+int vlan_check_real_dev(struct net_device *real_dev, u16 vlan_id);
 void vlan_setup(struct net_device *dev);
 int register_vlan_dev(struct net_device *dev);
 void unregister_vlan_dev(struct net_device *dev);
 
 static inline u32 vlan_get_ingress_priority(struct net_device *dev,
-					    unsigned short vlan_tag)
+					    u16 vlan_tci)
 {
 	struct vlan_dev_info *vip = vlan_dev_info(dev);
 
-	return vip->ingress_priority_map[(vlan_tag >> 13) & 0x7];
+	return vip->ingress_priority_map[(vlan_tci >> 13) & 0x7];
 }
 
 #ifdef CONFIG_VLAN_8021Q_GVRP
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 4daabc2..2bec74c 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -5,7 +5,7 @@
 
 /* VLAN rx hw acceleration helper.  This acts like netif_{rx,receive_skb}(). */
 int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
-		      unsigned short vlan_tag, int polling)
+		      u16 vlan_tci, int polling)
 {
 	struct net_device_stats *stats;
 
@@ -14,7 +14,7 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 		return NET_RX_DROP;
 	}
 
-	skb->dev = vlan_group_get_device(grp, vlan_tag & VLAN_VID_MASK);
+	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
 	if (skb->dev == NULL) {
 		dev_kfree_skb_any(skb);
 		/* Not NET_RX_DROP, this is not being dropped
@@ -27,7 +27,7 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 	stats->rx_packets++;
 	stats->rx_bytes += skb->len;
 
-	skb->priority = vlan_get_ingress_priority(skb->dev, vlan_tag);
+	skb->priority = vlan_get_ingress_priority(skb->dev, vlan_tci);
 	switch (skb->pkt_type) {
 	case PACKET_BROADCAST:
 		break;
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 2aab294..2ccac6b 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -150,9 +150,9 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 		  struct packet_type *ptype, struct net_device *orig_dev)
 {
 	struct vlan_hdr *vhdr;
-	unsigned short vid;
 	struct net_device_stats *stats;
-	unsigned short vlan_TCI;
+	u16 vlan_id;
+	u16 vlan_tci;
 
 	skb = skb_share_check(skb, GFP_ATOMIC);
 	if (skb == NULL)
@@ -162,14 +162,14 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 		goto err_free;
 
 	vhdr = (struct vlan_hdr *)skb->data;
-	vlan_TCI = ntohs(vhdr->h_vlan_TCI);
-	vid = (vlan_TCI & VLAN_VID_MASK);
+	vlan_tci = ntohs(vhdr->h_vlan_TCI);
+	vlan_id = vlan_tci & VLAN_VID_MASK;
 
 	rcu_read_lock();
-	skb->dev = __find_vlan_dev(dev, vid);
+	skb->dev = __find_vlan_dev(dev, vlan_id);
 	if (!skb->dev) {
 		pr_debug("%s: ERROR: No net_device for VID: %u on dev: %s\n",
-			 __func__, (unsigned int)vid, dev->name);
+			 __func__, vlan_id, dev->name);
 		goto err_unlock;
 	}
 
@@ -181,11 +181,10 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 
 	skb_pull_rcsum(skb, VLAN_HLEN);
 
-	skb->priority = vlan_get_ingress_priority(skb->dev,
-						  ntohs(vhdr->h_vlan_TCI));
+	skb->priority = vlan_get_ingress_priority(skb->dev, vlan_tci);
 
 	pr_debug("%s: priority: %u for TCI: %hu\n",
-		 __func__, skb->priority, ntohs(vhdr->h_vlan_TCI));
+		 __func__, skb->priority, vlan_tci);
 
 	switch (skb->pkt_type) {
 	case PACKET_BROADCAST: /* Yeah, stats collect these together.. */
@@ -228,7 +227,7 @@ err_free:
 	return NET_RX_DROP;
 }
 
-static inline unsigned short
+static inline u16
 vlan_dev_get_egress_qos_mask(struct net_device *dev, struct sk_buff *skb)
 {
 	struct vlan_priority_tci_mapping *mp;
@@ -260,7 +259,7 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 				unsigned int len)
 {
 	struct vlan_hdr *vhdr;
-	unsigned short veth_TCI = 0;
+	u16 vlan_tci = 0;
 	int rc = 0;
 	int build_vlan_header = 0;
 	struct net_device *vdev = dev;
@@ -292,10 +291,10 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 		 * VLAN ID	 12 bits (low bits)
 		 *
 		 */
-		veth_TCI = vlan_dev_info(dev)->vlan_id;
-		veth_TCI |= vlan_dev_get_egress_qos_mask(dev, skb);
+		vlan_tci = vlan_dev_info(dev)->vlan_id;
+		vlan_tci |= vlan_dev_get_egress_qos_mask(dev, skb);
 
-		vhdr->h_vlan_TCI = htons(veth_TCI);
+		vhdr->h_vlan_TCI = htons(vlan_tci);
 
 		/*
 		 *  Set the protocol type. For a packet of type ETH_P_802_3 we
@@ -373,7 +372,7 @@ static int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (veth->h_vlan_proto != htons(ETH_P_8021Q) ||
 		vlan_dev_info(dev)->flags & VLAN_FLAG_REORDER_HDR) {
 		int orig_headroom = skb_headroom(skb);
-		unsigned short veth_TCI;
+		u16 vlan_tci;
 
 		/* This is not a VLAN frame...but we can fix that! */
 		vlan_dev_info(dev)->cnt_encap_on_xmit++;
@@ -386,10 +385,10 @@ static int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		 * CFI		 1 bit
 		 * VLAN ID	 12 bits (low bits)
 		 */
-		veth_TCI = vlan_dev_info(dev)->vlan_id;
-		veth_TCI |= vlan_dev_get_egress_qos_mask(dev, skb);
+		vlan_tci = vlan_dev_info(dev)->vlan_id;
+		vlan_tci |= vlan_dev_get_egress_qos_mask(dev, skb);
 
-		skb = __vlan_put_tag(skb, veth_TCI);
+		skb = __vlan_put_tag(skb, vlan_tci);
 		if (!skb) {
 			stats->tx_dropped++;
 			return 0;
@@ -422,7 +421,7 @@ static int vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb,
 					    struct net_device *dev)
 {
 	struct net_device_stats *stats = &dev->stats;
-	unsigned short veth_TCI;
+	u16 vlan_tci;
 
 	/* Construct the second two bytes. This field looks something
 	 * like:
@@ -430,9 +429,9 @@ static int vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb,
 	 * CFI		 1 bit
 	 * VLAN ID	 12 bits (low bits)
 	 */
-	veth_TCI = vlan_dev_info(dev)->vlan_id;
-	veth_TCI |= vlan_dev_get_egress_qos_mask(dev, skb);
-	skb = __vlan_hwaccel_put_tag(skb, veth_TCI);
+	vlan_tci = vlan_dev_info(dev)->vlan_id;
+	vlan_tci |= vlan_dev_get_egress_qos_mask(dev, skb);
+	skb = __vlan_hwaccel_put_tag(skb, vlan_tci);
 
 	stats->tx_packets++;
 	stats->tx_bytes += skb->len;
@@ -457,7 +456,7 @@ static int vlan_dev_change_mtu(struct net_device *dev, int new_mtu)
 }
 
 void vlan_dev_set_ingress_priority(const struct net_device *dev,
-				   u32 skb_prio, short vlan_prio)
+				   u32 skb_prio, u16 vlan_prio)
 {
 	struct vlan_dev_info *vlan = vlan_dev_info(dev);
 
@@ -470,7 +469,7 @@ void vlan_dev_set_ingress_priority(const struct net_device *dev,
 }
 
 int vlan_dev_set_egress_priority(const struct net_device *dev,
-				 u32 skb_prio, short vlan_prio)
+				 u32 skb_prio, u16 vlan_prio)
 {
 	struct vlan_dev_info *vlan = vlan_dev_info(dev);
 	struct vlan_priority_tci_mapping *mp = NULL;
diff --git a/net/8021q/vlan_gvrp.c b/net/8021q/vlan_gvrp.c
index db97816..061cece 100644
--- a/net/8021q/vlan_gvrp.c
+++ b/net/8021q/vlan_gvrp.c
@@ -30,19 +30,19 @@ static struct garp_application vlan_gvrp_app __read_mostly = {
 int vlan_gvrp_request_join(const struct net_device *dev)
 {
 	const struct vlan_dev_info *vlan = vlan_dev_info(dev);
-	__be16 vid = htons(vlan->vlan_id);
+	__be16 vlan_id = htons(vlan->vlan_id);
 
 	return garp_request_join(vlan->real_dev, &vlan_gvrp_app,
-				 &vid, sizeof(vid), GVRP_ATTR_VID);
+				 &vlan_id, sizeof(vlan_id), GVRP_ATTR_VID);
 }
 
 void vlan_gvrp_request_leave(const struct net_device *dev)
 {
 	const struct vlan_dev_info *vlan = vlan_dev_info(dev);
-	__be16 vid = htons(vlan->vlan_id);
+	__be16 vlan_id = htons(vlan->vlan_id);
 
 	garp_request_leave(vlan->real_dev, &vlan_gvrp_app,
-			   &vid, sizeof(vid), GVRP_ATTR_VID);
+			   &vlan_id, sizeof(vlan_id), GVRP_ATTR_VID);
 }
 
 int vlan_gvrp_init_applicant(struct net_device *dev)
