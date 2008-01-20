From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN 13/18]: Turn VLAN_DEV_INFO into inline function
Date: Sun, 20 Jan 2008 18:11:35 +0100 (MET)
Message-ID: <20080120171135.7980.76399.sendpatchset@localhost.localdomain>
References: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62369 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754505AbYATRLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 12:11:36 -0500
In-Reply-To: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[VLAN]: Turn VLAN_DEV_INFO into inline function

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 84ea6a8ff0745f63e25d2d17664fd8c56448f985
tree de3ead8eda857231834d77e151be7ebc60ed3b5f
parent cd41c792d7df5107c05f2529426ae68f817e38f6
author Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 17:37:31 +0100
committer Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 17:37:31 +0100

 drivers/net/cxgb3/l2t.c      |    2 +-
 drivers/s390/net/qeth_main.c |    4 ++-
 include/linux/if_vlan.h      |    7 ++++-
 net/8021q/vlan.c             |   14 +++++------
 net/8021q/vlan_dev.c         |   56 +++++++++++++++++++++---------------------
 net/8021q/vlan_netlink.c     |   10 ++++----
 net/8021q/vlanproc.c         |   12 +++++----
 7 files changed, 54 insertions(+), 51 deletions(-)

diff --git a/drivers/net/cxgb3/l2t.c b/drivers/net/cxgb3/l2t.c
index d660af7..17ed4c3 100644
--- a/drivers/net/cxgb3/l2t.c
+++ b/drivers/net/cxgb3/l2t.c
@@ -337,7 +337,7 @@ struct l2t_entry *t3_l2t_get(struct t3cdev *cdev, struct neighbour *neigh,
 		atomic_set(&e->refcnt, 1);
 		neigh_replace(e, neigh);
 		if (neigh->dev->priv_flags & IFF_802_1Q_VLAN)
-			e->vlan = VLAN_DEV_INFO(neigh->dev)->vlan_id;
+			e->vlan = vlan_dev_info(neigh->dev)->vlan_id;
 		else
 			e->vlan = VLAN_NONE;
 		spin_unlock(&e->lock);
diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
index f1866a2..62606ce 100644
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -3890,7 +3890,7 @@ qeth_verify_vlan_dev(struct net_device *dev, struct qeth_card *card)
 			break;
 		}
 	}
-	if (rc && !(VLAN_DEV_INFO(dev)->real_dev->priv == (void *)card))
+	if (rc && !(vlan_dev_info(dev)->real_dev->priv == (void *)card))
 		return 0;
 
 #endif
@@ -3930,7 +3930,7 @@ qeth_get_card_from_dev(struct net_device *dev)
 		card = (struct qeth_card *)dev->priv;
 	else if (rc == QETH_VLAN_CARD)
 		card = (struct qeth_card *)
-			VLAN_DEV_INFO(dev)->real_dev->priv;
+			vlan_dev_info(dev)->real_dev->priv;
 
 	QETH_DBF_TEXT_(trace, 4, "%d", rc);
 	return card ;
diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 129fa87..82c2352 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -143,13 +143,16 @@ struct vlan_dev_info {
 	unsigned long cnt_encap_on_xmit;      /* How many times did we have to encapsulate the skb on TX. */
 };
 
-#define VLAN_DEV_INFO(x) ((struct vlan_dev_info *)(x->priv))
+static inline struct vlan_dev_info *vlan_dev_info(const struct net_device *dev)
+{
+	return netdev_priv(dev);
+}
 
 /* inline functions */
 static inline __u32 vlan_get_ingress_priority(struct net_device *dev,
 					      unsigned short vlan_tag)
 {
-	struct vlan_dev_info *vip = VLAN_DEV_INFO(dev);
+	struct vlan_dev_info *vip = vlan_dev_info(dev);
 
 	return vip->ingress_priority_map[(vlan_tag >> 13) & 0x7];
 }
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index ac79638..d058c0e 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -134,7 +134,7 @@ static void vlan_rcu_free(struct rcu_head *rcu)
 
 void unregister_vlan_dev(struct net_device *dev)
 {
-	struct vlan_dev_info *vlan = VLAN_DEV_INFO(dev);
+	struct vlan_dev_info *vlan = vlan_dev_info(dev);
 	struct net_device *real_dev = vlan->real_dev;
 	struct vlan_group *grp;
 	unsigned short vlan_id = vlan->vlan_id;
@@ -229,7 +229,7 @@ int vlan_check_real_dev(struct net_device *real_dev, unsigned short vlan_id)
 
 int register_vlan_dev(struct net_device *dev)
 {
-	struct vlan_dev_info *vlan = VLAN_DEV_INFO(dev);
+	struct vlan_dev_info *vlan = vlan_dev_info(dev);
 	struct net_device *real_dev = vlan->real_dev;
 	unsigned short vlan_id = vlan->vlan_id;
 	struct vlan_group *grp, *ngrp = NULL;
@@ -328,10 +328,10 @@ static int register_vlan_device(struct net_device *real_dev,
 	 */
 	new_dev->mtu = real_dev->mtu;
 
-	VLAN_DEV_INFO(new_dev)->vlan_id = VLAN_ID; /* 1 through VLAN_VID_MASK */
-	VLAN_DEV_INFO(new_dev)->real_dev = real_dev;
-	VLAN_DEV_INFO(new_dev)->dent = NULL;
-	VLAN_DEV_INFO(new_dev)->flags = VLAN_FLAG_REORDER_HDR;
+	vlan_dev_info(new_dev)->vlan_id = VLAN_ID; /* 1 through VLAN_VID_MASK */
+	vlan_dev_info(new_dev)->real_dev = real_dev;
+	vlan_dev_info(new_dev)->dent = NULL;
+	vlan_dev_info(new_dev)->flags = VLAN_FLAG_REORDER_HDR;
 
 	new_dev->rtnl_link_ops = &vlan_link_ops;
 	err = register_vlan_dev(new_dev);
@@ -348,7 +348,7 @@ out_free_newdev:
 static void vlan_sync_address(struct net_device *dev,
 			      struct net_device *vlandev)
 {
-	struct vlan_dev_info *vlan = VLAN_DEV_INFO(vlandev);
+	struct vlan_dev_info *vlan = vlan_dev_info(vlandev);
 
 	/* May be called without an actual change */
 	if (!compare_ether_addr(vlan->real_dev_addr, dev->dev_addr))
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 756a71c..a846559 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -72,7 +72,7 @@ static int vlan_dev_rebuild_header(struct sk_buff *skb)
 
 static inline struct sk_buff *vlan_check_reorder_header(struct sk_buff *skb)
 {
-	if (VLAN_DEV_INFO(skb->dev)->flags & VLAN_FLAG_REORDER_HDR) {
+	if (vlan_dev_info(skb->dev)->flags & VLAN_FLAG_REORDER_HDR) {
 		if (skb_shared(skb) || skb_cloned(skb)) {
 			struct sk_buff *nskb = skb_copy(skb, GFP_ATOMIC);
 			kfree_skb(skb);
@@ -290,7 +290,7 @@ static inline unsigned short vlan_dev_get_egress_qos_mask(struct net_device* dev
 							  struct sk_buff* skb)
 {
 	struct vlan_priority_tci_mapping *mp =
-		VLAN_DEV_INFO(dev)->egress_priority_map[(skb->priority & 0xF)];
+		vlan_dev_info(dev)->egress_priority_map[(skb->priority & 0xF)];
 
 	while (mp) {
 		if (mp->priority == skb->priority) {
@@ -324,7 +324,7 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 	struct net_device *vdev = dev; /* save this for the bottom of the method */
 
 	pr_debug("%s: skb: %p type: %hx len: %u vlan_id: %hx, daddr: %p\n",
-		 __FUNCTION__, skb, type, len, VLAN_DEV_INFO(dev)->vlan_id, daddr);
+		 __FUNCTION__, skb, type, len, vlan_dev_info(dev)->vlan_id, daddr);
 
 	/* build vlan header only if re_order_header flag is NOT set.  This
 	 * fixes some programs that get confused when they see a VLAN device
@@ -334,7 +334,7 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 	 * header shuffling in the hard_start_xmit.  Users can turn off this
 	 * REORDER behaviour with the vconfig tool.
 	 */
-	if (!(VLAN_DEV_INFO(dev)->flags & VLAN_FLAG_REORDER_HDR))
+	if (!(vlan_dev_info(dev)->flags & VLAN_FLAG_REORDER_HDR))
 		build_vlan_header = 1;
 
 	if (build_vlan_header) {
@@ -349,7 +349,7 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 		 * VLAN ID	 12 bits (low bits)
 		 *
 		 */
-		veth_TCI = VLAN_DEV_INFO(dev)->vlan_id;
+		veth_TCI = vlan_dev_info(dev)->vlan_id;
 		veth_TCI |= vlan_dev_get_egress_qos_mask(dev, skb);
 
 		vhdr->h_vlan_TCI = htons(veth_TCI);
@@ -374,7 +374,7 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 	if (saddr == NULL)
 		saddr = dev->dev_addr;
 
-	dev = VLAN_DEV_INFO(dev)->real_dev;
+	dev = vlan_dev_info(dev)->real_dev;
 
 	/* MPLS can send us skbuffs w/out enough space.	 This check will grow the
 	 * skb if it doesn't have enough headroom.  Not a beautiful solution, so
@@ -395,7 +395,7 @@ static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 			stats->tx_dropped++;
 			return -ENOMEM;
 		}
-		VLAN_DEV_INFO(vdev)->cnt_inc_headroom_on_tx++;
+		vlan_dev_info(vdev)->cnt_inc_headroom_on_tx++;
 		pr_debug("%s: %s: had to grow skb.\n", __FUNCTION__, vdev->name);
 	}
 
@@ -430,12 +430,12 @@ static int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	 */
 
 	if (veth->h_vlan_proto != htons(ETH_P_8021Q) ||
-		VLAN_DEV_INFO(dev)->flags & VLAN_FLAG_REORDER_HDR) {
+		vlan_dev_info(dev)->flags & VLAN_FLAG_REORDER_HDR) {
 		int orig_headroom = skb_headroom(skb);
 		unsigned short veth_TCI;
 
 		/* This is not a VLAN frame...but we can fix that! */
-		VLAN_DEV_INFO(dev)->cnt_encap_on_xmit++;
+		vlan_dev_info(dev)->cnt_encap_on_xmit++;
 
 		pr_debug("%s: proto to encap: 0x%hx\n",
 			 __FUNCTION__, htons(veth->h_vlan_proto));
@@ -445,7 +445,7 @@ static int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		 * CFI		 1 bit
 		 * VLAN ID	 12 bits (low bits)
 		 */
-		veth_TCI = VLAN_DEV_INFO(dev)->vlan_id;
+		veth_TCI = vlan_dev_info(dev)->vlan_id;
 		veth_TCI |= vlan_dev_get_egress_qos_mask(dev, skb);
 
 		skb = __vlan_put_tag(skb, veth_TCI);
@@ -455,7 +455,7 @@ static int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 
 		if (orig_headroom < VLAN_HLEN) {
-			VLAN_DEV_INFO(dev)->cnt_inc_headroom_on_tx++;
+			vlan_dev_info(dev)->cnt_inc_headroom_on_tx++;
 		}
 	}
 
@@ -472,7 +472,7 @@ static int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	stats->tx_packets++; /* for statics only */
 	stats->tx_bytes += skb->len;
 
-	skb->dev = VLAN_DEV_INFO(dev)->real_dev;
+	skb->dev = vlan_dev_info(dev)->real_dev;
 	dev_queue_xmit(skb);
 
 	return 0;
@@ -490,14 +490,14 @@ static int vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb,
 	 * CFI		 1 bit
 	 * VLAN ID	 12 bits (low bits)
 	 */
-	veth_TCI = VLAN_DEV_INFO(dev)->vlan_id;
+	veth_TCI = vlan_dev_info(dev)->vlan_id;
 	veth_TCI |= vlan_dev_get_egress_qos_mask(dev, skb);
 	skb = __vlan_hwaccel_put_tag(skb, veth_TCI);
 
 	stats->tx_packets++;
 	stats->tx_bytes += skb->len;
 
-	skb->dev = VLAN_DEV_INFO(dev)->real_dev;
+	skb->dev = vlan_dev_info(dev)->real_dev;
 	dev_queue_xmit(skb);
 
 	return 0;
@@ -508,7 +508,7 @@ static int vlan_dev_change_mtu(struct net_device *dev, int new_mtu)
 	/* TODO: gotta make sure the underlying layer can handle it,
 	 * maybe an IFF_VLAN_CAPABLE flag for devices?
 	 */
-	if (VLAN_DEV_INFO(dev)->real_dev->mtu < new_mtu)
+	if (vlan_dev_info(dev)->real_dev->mtu < new_mtu)
 		return -ERANGE;
 
 	dev->mtu = new_mtu;
@@ -519,7 +519,7 @@ static int vlan_dev_change_mtu(struct net_device *dev, int new_mtu)
 void vlan_dev_set_ingress_priority(const struct net_device *dev,
 				   u32 skb_prio, short vlan_prio)
 {
-	struct vlan_dev_info *vlan = VLAN_DEV_INFO(dev);
+	struct vlan_dev_info *vlan = vlan_dev_info(dev);
 
 	if (vlan->ingress_priority_map[vlan_prio & 0x7] && !skb_prio)
 		vlan->nr_ingress_mappings--;
@@ -532,7 +532,7 @@ void vlan_dev_set_ingress_priority(const struct net_device *dev,
 int vlan_dev_set_egress_priority(const struct net_device *dev,
 				 u32 skb_prio, short vlan_prio)
 {
-	struct vlan_dev_info *vlan = VLAN_DEV_INFO(dev);
+	struct vlan_dev_info *vlan = vlan_dev_info(dev);
 	struct vlan_priority_tci_mapping *mp = NULL;
 	struct vlan_priority_tci_mapping *np;
 	u32 vlan_qos = (vlan_prio << 13) & 0xE000;
@@ -573,9 +573,9 @@ int vlan_dev_set_vlan_flag(const struct net_device *dev,
 	/* verify flag is supported */
 	if (flag == VLAN_FLAG_REORDER_HDR) {
 		if (flag_val) {
-			VLAN_DEV_INFO(dev)->flags |= VLAN_FLAG_REORDER_HDR;
+			vlan_dev_info(dev)->flags |= VLAN_FLAG_REORDER_HDR;
 		} else {
-			VLAN_DEV_INFO(dev)->flags &= ~VLAN_FLAG_REORDER_HDR;
+			vlan_dev_info(dev)->flags &= ~VLAN_FLAG_REORDER_HDR;
 		}
 		return 0;
 	}
@@ -584,17 +584,17 @@ int vlan_dev_set_vlan_flag(const struct net_device *dev,
 
 void vlan_dev_get_realdev_name(const struct net_device *dev, char *result)
 {
-	strncpy(result, VLAN_DEV_INFO(dev)->real_dev->name, 23);
+	strncpy(result, vlan_dev_info(dev)->real_dev->name, 23);
 }
 
 void vlan_dev_get_vid(const struct net_device *dev, unsigned short *result)
 {
-	*result = VLAN_DEV_INFO(dev)->vlan_id;
+	*result = vlan_dev_info(dev)->vlan_id;
 }
 
 static int vlan_dev_open(struct net_device *dev)
 {
-	struct vlan_dev_info *vlan = VLAN_DEV_INFO(dev);
+	struct vlan_dev_info *vlan = vlan_dev_info(dev);
 	struct net_device *real_dev = vlan->real_dev;
 	int err;
 
@@ -618,7 +618,7 @@ static int vlan_dev_open(struct net_device *dev)
 
 static int vlan_dev_stop(struct net_device *dev)
 {
-	struct net_device *real_dev = VLAN_DEV_INFO(dev)->real_dev;
+	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
 
 	dev_mc_unsync(real_dev, dev);
 	if (dev->flags & IFF_ALLMULTI)
@@ -634,7 +634,7 @@ static int vlan_dev_stop(struct net_device *dev)
 
 static int vlan_dev_set_mac_address(struct net_device *dev, void *p)
 {
-	struct net_device *real_dev = VLAN_DEV_INFO(dev)->real_dev;
+	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
 	struct sockaddr *addr = p;
 	int err;
 
@@ -660,7 +660,7 @@ out:
 
 static int vlan_dev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	struct net_device *real_dev = VLAN_DEV_INFO(dev)->real_dev;
+	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
 	struct ifreq ifrr;
 	int err = -EOPNOTSUPP;
 
@@ -684,7 +684,7 @@ static int vlan_dev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 static void vlan_dev_change_rx_flags(struct net_device *dev, int change)
 {
-	struct net_device *real_dev = VLAN_DEV_INFO(dev)->real_dev;
+	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
 
 	if (change & IFF_ALLMULTI)
 		dev_set_allmulti(real_dev, dev->flags & IFF_ALLMULTI ? 1 : -1);
@@ -694,7 +694,7 @@ static void vlan_dev_change_rx_flags(struct net_device *dev, int change)
 
 static void vlan_dev_set_multicast_list(struct net_device *vlan_dev)
 {
-	dev_mc_sync(VLAN_DEV_INFO(vlan_dev)->real_dev, vlan_dev);
+	dev_mc_sync(vlan_dev_info(vlan_dev)->real_dev, vlan_dev);
 }
 
 /*
@@ -712,7 +712,7 @@ static const struct header_ops vlan_header_ops = {
 
 static int vlan_dev_init(struct net_device *dev)
 {
-	struct net_device *real_dev = VLAN_DEV_INFO(dev)->real_dev;
+	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
 	int subclass = 0;
 
 	/* IFF_BROADCAST|IFF_MULTICAST; ??? */
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index 9ee6358..e32eeb3 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -75,7 +75,7 @@ static int vlan_validate(struct nlattr *tb[], struct nlattr *data[])
 static int vlan_changelink(struct net_device *dev,
 			   struct nlattr *tb[], struct nlattr *data[])
 {
-	struct vlan_dev_info *vlan = VLAN_DEV_INFO(dev);
+	struct vlan_dev_info *vlan = vlan_dev_info(dev);
 	struct ifla_vlan_flags *flags;
 	struct ifla_vlan_qos_mapping *m;
 	struct nlattr *attr;
@@ -104,7 +104,7 @@ static int vlan_changelink(struct net_device *dev,
 static int vlan_newlink(struct net_device *dev,
 			struct nlattr *tb[], struct nlattr *data[])
 {
-	struct vlan_dev_info *vlan = VLAN_DEV_INFO(dev);
+	struct vlan_dev_info *vlan = vlan_dev_info(dev);
 	struct net_device *real_dev;
 	int err;
 
@@ -148,7 +148,7 @@ static inline size_t vlan_qos_map_size(unsigned int n)
 
 static size_t vlan_get_size(const struct net_device *dev)
 {
-	struct vlan_dev_info *vlan = VLAN_DEV_INFO(dev);
+	struct vlan_dev_info *vlan = vlan_dev_info(dev);
 
 	return nla_total_size(2) +	/* IFLA_VLAN_ID */
 	       vlan_qos_map_size(vlan->nr_ingress_mappings) +
@@ -157,14 +157,14 @@ static size_t vlan_get_size(const struct net_device *dev)
 
 static int vlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 {
-	struct vlan_dev_info *vlan = VLAN_DEV_INFO(dev);
+	struct vlan_dev_info *vlan = vlan_dev_info(dev);
 	struct vlan_priority_tci_mapping *pm;
 	struct ifla_vlan_flags f;
 	struct ifla_vlan_qos_mapping m;
 	struct nlattr *nest;
 	unsigned int i;
 
-	NLA_PUT_U16(skb, IFLA_VLAN_ID, VLAN_DEV_INFO(dev)->vlan_id);
+	NLA_PUT_U16(skb, IFLA_VLAN_ID, vlan_dev_info(dev)->vlan_id);
 	if (vlan->flags) {
 		f.flags = vlan->flags;
 		f.mask  = ~0;
diff --git a/net/8021q/vlanproc.c b/net/8021q/vlanproc.c
index 971e623..b520244 100644
--- a/net/8021q/vlanproc.c
+++ b/net/8021q/vlanproc.c
@@ -180,7 +180,7 @@ err:
 
 int vlan_proc_add_dev (struct net_device *vlandev)
 {
-	struct vlan_dev_info *dev_info = VLAN_DEV_INFO(vlandev);
+	struct vlan_dev_info *dev_info = vlan_dev_info(vlandev);
 
 	dev_info->dent = create_proc_entry(vlandev->name,
 					   S_IFREG|S_IRUSR|S_IWUSR,
@@ -199,9 +199,9 @@ int vlan_proc_add_dev (struct net_device *vlandev)
 int vlan_proc_rem_dev(struct net_device *vlandev)
 {
 	/** NOTE:  This will consume the memory pointed to by dent, it seems. */
-	if (VLAN_DEV_INFO(vlandev)->dent) {
-		remove_proc_entry(VLAN_DEV_INFO(vlandev)->dent->name, proc_vlan_dir);
-		VLAN_DEV_INFO(vlandev)->dent = NULL;
+	if (vlan_dev_info(vlandev)->dent) {
+		remove_proc_entry(vlan_dev_info(vlandev)->dent->name, proc_vlan_dir);
+		vlan_dev_info(vlandev)->dent = NULL;
 	}
 	return 0;
 }
@@ -278,7 +278,7 @@ static int vlan_seq_show(struct seq_file *seq, void *v)
 			   nmtype ? nmtype :  "UNKNOWN" );
 	} else {
 		const struct net_device *vlandev = v;
-		const struct vlan_dev_info *dev_info = VLAN_DEV_INFO(vlandev);
+		const struct vlan_dev_info *dev_info = vlan_dev_info(vlandev);
 
 		seq_printf(seq, "%-15s| %d  | %s\n",  vlandev->name,
 			   dev_info->vlan_id,    dev_info->real_dev->name);
@@ -289,7 +289,7 @@ static int vlan_seq_show(struct seq_file *seq, void *v)
 static int vlandev_seq_show(struct seq_file *seq, void *offset)
 {
 	struct net_device *vlandev = (struct net_device *) seq->private;
-	const struct vlan_dev_info *dev_info = VLAN_DEV_INFO(vlandev);
+	const struct vlan_dev_info *dev_info = vlan_dev_info(vlandev);
 	struct net_device_stats *stats = &vlandev->stats;
 	static const char fmt[] = "%30s %12lu\n";
 	int i;
