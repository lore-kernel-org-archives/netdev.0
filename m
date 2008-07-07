From: Patrick McHardy <kaber@trash.net>
Subject: vlan 05/07: move struct vlan_dev_info to private header
Date: Mon,  7 Jul 2008 14:36:05 +0200 (MEST)
Message-ID: <20080707123604.23947.90001.sendpatchset@localhost.localdomain>
References: <20080707123557.23947.70114.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59282 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753300AbYGGMgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 08:36:07 -0400
In-Reply-To: <20080707123557.23947.70114.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vlan: move struct vlan_dev_info to private header

Hide struct vlan_dev_info from drivers to prevent them from growing
more creative ways to use it. Provide accessors for the two drivers
that currently use it.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit b060b0baf74457b1a9e05e7b264be91a753477ee
tree dd424a8b7481db49bb1160ea8b28c4115d2ad330
parent f8a70bfd12e6421b2c98e19a475633fddb5d5a2a
author Patrick McHardy <kaber@trash.net> Mon, 07 Jul 2008 14:26:44 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 07 Jul 2008 14:26:44 +0200

 drivers/net/cxgb3/l2t.c         |    2 +
 drivers/s390/net/qeth_l3_main.c |    4 +--
 include/linux/if_vlan.h         |   56 ++++++++++-----------------------------
 net/8021q/vlan.c                |    4 +--
 net/8021q/vlan.h                |   50 ++++++++++++++++++++++++++++++++++-
 net/8021q/vlan_core.c           |   12 ++++++++
 net/8021q/vlan_dev.c            |    5 ---
 7 files changed, 80 insertions(+), 53 deletions(-)

diff --git a/drivers/net/cxgb3/l2t.c b/drivers/net/cxgb3/l2t.c
index f510140..825e510 100644
--- a/drivers/net/cxgb3/l2t.c
+++ b/drivers/net/cxgb3/l2t.c
@@ -337,7 +337,7 @@ struct l2t_entry *t3_l2t_get(struct t3cdev *cdev, struct neighbour *neigh,
 		atomic_set(&e->refcnt, 1);
 		neigh_replace(e, neigh);
 		if (neigh->dev->priv_flags & IFF_802_1Q_VLAN)
-			e->vlan = vlan_dev_info(neigh->dev)->vlan_id;
+			e->vlan = vlan_dev_vlan_id(neigh->dev);
 		else
 			e->vlan = VLAN_NONE;
 		spin_unlock(&e->lock);
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 999552c..85be40a 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2020,7 +2020,7 @@ static int qeth_l3_verify_vlan_dev(struct net_device *dev,
 		}
 	}
 
-	if (rc && !(netdev_priv(vlan_dev_info(dev)->real_dev) == (void *)card))
+	if (rc && !(netdev_priv(vlan_dev_real_dev(dev)) == (void *)card))
 		return 0;
 
 	return rc;
@@ -2056,7 +2056,7 @@ static struct qeth_card *qeth_l3_get_card_from_dev(struct net_device *dev)
 	if (rc == QETH_REAL_CARD)
 		card = netdev_priv(dev);
 	else if (rc == QETH_VLAN_CARD)
-		card = netdev_priv(vlan_dev_info(dev)->real_dev);
+		card = netdev_priv(vlan_dev_real_dev(dev));
 	if (card && card->options.layer2)
 		card = NULL;
 	QETH_DBF_TEXT_(TRACE, 4, "%d", rc);
diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 594cd35..cb2e6b4 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -109,47 +109,6 @@ static inline void vlan_group_set_device(struct vlan_group *vg,
 	array[vlan_id % VLAN_GROUP_ARRAY_PART_LEN] = dev;
 }
 
-struct vlan_priority_tci_mapping {
-	u32 priority;
-	unsigned short vlan_qos; /* This should be shifted when first set, so we only do it
-				  * at provisioning time.
-				  * ((skb->priority << 13) & 0xE000)
-				  */
-	struct vlan_priority_tci_mapping *next;
-};
-
-/* Holds information that makes sense if this device is a VLAN device. */
-struct vlan_dev_info {
-	/** This will be the mapping that correlates skb->priority to
-	 * 3 bits of VLAN QOS tags...
-	 */
-	unsigned int nr_ingress_mappings;
-	u32 ingress_priority_map[8];
-
-	unsigned int nr_egress_mappings;
-	struct vlan_priority_tci_mapping *egress_priority_map[16]; /* hash table */
-
-	unsigned short vlan_id;        /*  The VLAN Identifier for this interface. */
-	unsigned short flags;          /* (1 << 0) re_order_header   This option will cause the
-                                        *   VLAN code to move around the ethernet header on
-                                        *   ingress to make the skb look **exactly** like it
-                                        *   came in from an ethernet port.  This destroys some of
-                                        *   the VLAN information in the skb, but it fixes programs
-                                        *   like DHCP that use packet-filtering and don't understand
-                                        *   802.1Q
-                                        */
-	struct net_device *real_dev;    /* the underlying device/interface */
-	unsigned char real_dev_addr[ETH_ALEN];
-	struct proc_dir_entry *dent;    /* Holds the proc data */
-	unsigned long cnt_inc_headroom_on_tx; /* How many times did we have to grow the skb on TX. */
-	unsigned long cnt_encap_on_xmit;      /* How many times did we have to encapsulate the skb on TX. */
-};
-
-static inline struct vlan_dev_info *vlan_dev_info(const struct net_device *dev)
-{
-	return netdev_priv(dev);
-}
-
 /* VLAN tx hw acceleration helpers. */
 struct vlan_skb_tx_cookie {
 	u32	magic;
@@ -163,9 +122,24 @@ struct vlan_skb_tx_cookie {
 #define vlan_tx_tag_get(__skb)	(VLAN_TX_SKB_CB(__skb)->vlan_tag)
 
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+extern struct net_device *vlan_dev_real_dev(const struct net_device *dev);
+extern u16 vlan_dev_vlan_id(const struct net_device *dev);
+
 extern int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 			     unsigned short vlan_tag, int polling);
 #else
+static inline struct net_device *vlan_dev_real_dev(const struct net_device *dev)
+{
+	BUG();
+	return NULL;
+}
+
+static inline u16 vlan_dev_vlan_id(const struct net_device *dev)
+{
+	BUG();
+	return 0;
+}
+
 static inline int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 				    unsigned short vlan_tag, int polling)
 {
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 8141e2d..7a2625d 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -543,7 +543,6 @@ static struct notifier_block vlan_notifier_block __read_mostly = {
 static int vlan_ioctl_handler(struct net *net, void __user *arg)
 {
 	int err;
-	unsigned short vid = 0;
 	struct vlan_ioctl_args args;
 	struct net_device *dev = NULL;
 
@@ -644,8 +643,7 @@ static int vlan_ioctl_handler(struct net *net, void __user *arg)
 
 	case GET_VLAN_VID_CMD:
 		err = 0;
-		vlan_dev_get_vid(dev, &vid);
-		args.u.VID = vid;
+		args.u.VID = vlan_dev_vlan_id(dev);
 		if (copy_to_user(arg, &args,
 				 sizeof(struct vlan_ioctl_args)))
 		      err = -EFAULT;
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 7cc1a97..14c421e 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -3,6 +3,55 @@
 
 #include <linux/if_vlan.h>
 
+
+/**
+ *	struct vlan_priority_tci_mapping - vlan egress priority mappings
+ *	@priority: skb priority
+ *	@vlan_qos: vlan priority: (skb->priority << 13) & 0xE000
+ *	@next: pointer to next struct
+ */
+struct vlan_priority_tci_mapping {
+	u32					priority;
+	unsigned short				vlan_qos;
+	struct vlan_priority_tci_mapping	*next;
+};
+
+/**
+ *	struct vlan_dev_info - VLAN private device data
+ *	@nr_ingress_mappings: number of ingress priority mappings
+ *	@ingress_priority_map: ingress priority mappings
+ *	@nr_egress_mappings: number of egress priority mappings
+ *	@egress_priority_map: hash of egress priority mappings
+ *	@vlan_id: VLAN identifier
+ *	@flags: device flags
+ *	@real_dev: underlying netdevice
+ *	@real_dev_addr: address of underlying netdevice
+ *	@dent: proc dir entry
+ *	@cnt_inc_headroom_on_tx: statistic - number of skb expansions on TX
+ *	@cnt_encap_on_xmit: statistic - number of skb encapsulations on TX
+ */
+struct vlan_dev_info {
+	unsigned int				nr_ingress_mappings;
+	u32					ingress_priority_map[8];
+	unsigned int				nr_egress_mappings;
+	struct vlan_priority_tci_mapping	*egress_priority_map[16];
+
+	unsigned short				vlan_id;
+	unsigned short				flags;
+
+	struct net_device			*real_dev;
+	unsigned char				real_dev_addr[ETH_ALEN];
+
+	struct proc_dir_entry			*dent;
+	unsigned long				cnt_inc_headroom_on_tx;
+	unsigned long				cnt_encap_on_xmit;
+};
+
+static inline struct vlan_dev_info *vlan_dev_info(const struct net_device *dev)
+{
+	return netdev_priv(dev);
+}
+
 #define VLAN_GRP_HASH_SHIFT	5
 #define VLAN_GRP_HASH_SIZE	(1 << VLAN_GRP_HASH_SHIFT)
 #define VLAN_GRP_HASH_MASK	(VLAN_GRP_HASH_SIZE - 1)
@@ -30,7 +79,6 @@ int vlan_dev_set_egress_priority(const struct net_device *dev,
 				 u32 skb_prio, short vlan_prio);
 int vlan_dev_change_flags(const struct net_device *dev, u32 flag, u32 mask);
 void vlan_dev_get_realdev_name(const struct net_device *dev, char *result);
-void vlan_dev_get_vid(const struct net_device *dev, unsigned short *result);
 
 int vlan_check_real_dev(struct net_device *real_dev, unsigned short vlan_id);
 void vlan_setup(struct net_device *dev);
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index a6c249c..4daabc2 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -46,3 +46,15 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 	return (polling ? netif_receive_skb(skb) : netif_rx(skb));
 }
 EXPORT_SYMBOL(__vlan_hwaccel_rx);
+
+struct net_device *vlan_dev_real_dev(const struct net_device *dev)
+{
+	return vlan_dev_info(dev)->real_dev;
+}
+EXPORT_SYMBOL_GPL(vlan_dev_real_dev);
+
+u16 vlan_dev_vlan_id(const struct net_device *dev)
+{
+	return vlan_dev_info(dev)->vlan_id;
+}
+EXPORT_SYMBOL_GPL(vlan_dev_vlan_id);
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 722697d..2aab294 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -531,11 +531,6 @@ void vlan_dev_get_realdev_name(const struct net_device *dev, char *result)
 	strncpy(result, vlan_dev_info(dev)->real_dev->name, 23);
 }
 
-void vlan_dev_get_vid(const struct net_device *dev, unsigned short *result)
-{
-	*result = vlan_dev_info(dev)->vlan_id;
-}
-
 static int vlan_dev_open(struct net_device *dev)
 {
 	struct vlan_dev_info *vlan = vlan_dev_info(dev);
