From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN 05/18]: Move device setup to vlan_dev.c
Date: Sun, 20 Jan 2008 18:11:24 +0100 (MET)
Message-ID: <20080120171124.7980.39177.sendpatchset@localhost.localdomain>
References: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62340 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754444AbYATRLZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 12:11:25 -0500
In-Reply-To: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[VLAN]: Move device setup to vlan_dev.c

Move device setup to vlan_dev.c and make all the VLAN device methods
static.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit aa7c9ed461cf1cf1977a7d5735d464a7539d2518
tree 06a7feef01dfd6494de6ed687895c6ca58a44f3d
parent fef4f968b4704bf2b37417ca6ba0dedda696e611
author Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 16:24:55 +0100
committer Patrick McHardy <kaber@trash.net> Sun, 20 Jan 2008 16:24:55 +0100

 net/8021q/vlan.c     |   81 -----------------------------------------
 net/8021q/vlan.h     |   13 -------
 net/8021q/vlan_dev.c |  100 +++++++++++++++++++++++++++++++++++++++++++-------
 3 files changed, 86 insertions(+), 108 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 54f2346..8bc6385 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -307,87 +307,6 @@ int unregister_vlan_device(struct net_device *dev)
 	return ret;
 }
 
-/*
- * vlan network devices have devices nesting below it, and are a special
- * "super class" of normal network devices; split their locks off into a
- * separate class since they always nest.
- */
-static struct lock_class_key vlan_netdev_xmit_lock_key;
-
-static const struct header_ops vlan_header_ops = {
-	.create	 = vlan_dev_hard_header,
-	.rebuild = vlan_dev_rebuild_header,
-	.parse	 = eth_header_parse,
-};
-
-static int vlan_dev_init(struct net_device *dev)
-{
-	struct net_device *real_dev = VLAN_DEV_INFO(dev)->real_dev;
-	int subclass = 0;
-
-	/* IFF_BROADCAST|IFF_MULTICAST; ??? */
-	dev->flags  = real_dev->flags & ~IFF_UP;
-	dev->iflink = real_dev->ifindex;
-	dev->state  = (real_dev->state & ((1<<__LINK_STATE_NOCARRIER) |
-					  (1<<__LINK_STATE_DORMANT))) |
-		      (1<<__LINK_STATE_PRESENT);
-
-	/* ipv6 shared card related stuff */
-	dev->dev_id = real_dev->dev_id;
-
-	if (is_zero_ether_addr(dev->dev_addr))
-		memcpy(dev->dev_addr, real_dev->dev_addr, dev->addr_len);
-	if (is_zero_ether_addr(dev->broadcast))
-		memcpy(dev->broadcast, real_dev->broadcast, dev->addr_len);
-
-	if (real_dev->features & NETIF_F_HW_VLAN_TX) {
-		dev->header_ops      = real_dev->header_ops;
-		dev->hard_header_len = real_dev->hard_header_len;
-		dev->hard_start_xmit = vlan_dev_hwaccel_hard_start_xmit;
-	} else {
-		dev->header_ops      = &vlan_header_ops;
-		dev->hard_header_len = real_dev->hard_header_len + VLAN_HLEN;
-		dev->hard_start_xmit = vlan_dev_hard_start_xmit;
-	}
-
-	if (real_dev->priv_flags & IFF_802_1Q_VLAN)
-		subclass = 1;
-
-	lockdep_set_class_and_subclass(&dev->_xmit_lock,
-				&vlan_netdev_xmit_lock_key, subclass);
-	return 0;
-}
-
-void vlan_setup(struct net_device *new_dev)
-{
-	ether_setup(new_dev);
-
-	/* new_dev->ifindex = 0;  it will be set when added to
-	 * the global list.
-	 * iflink is set as well.
-	 */
-	/* Make this thing known as a VLAN device */
-	new_dev->priv_flags |= IFF_802_1Q_VLAN;
-
-	/* Set us up to have no queue, as the underlying Hardware device
-	 * can do all the queueing we could want.
-	 */
-	new_dev->tx_queue_len = 0;
-
-	/* set up method calls */
-	new_dev->change_mtu = vlan_dev_change_mtu;
-	new_dev->init = vlan_dev_init;
-	new_dev->open = vlan_dev_open;
-	new_dev->stop = vlan_dev_stop;
-	new_dev->set_mac_address = vlan_set_mac_address;
-	new_dev->set_multicast_list = vlan_dev_set_multicast_list;
-	new_dev->change_rx_flags = vlan_change_rx_flags;
-	new_dev->destructor = free_netdev;
-	new_dev->do_ioctl = vlan_dev_ioctl;
-
-	memset(new_dev->broadcast, 0, ETH_ALEN);
-}
-
 static void vlan_transfer_operstate(const struct net_device *dev, struct net_device *vlandev)
 {
 	/* Have to respect userspace enforced dormant state
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 2cd1393..7b615d6 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -49,19 +49,8 @@ struct net_device *__find_vlan_dev(struct net_device* real_dev,
 				   unsigned short VID); /* vlan.c */
 
 /* found in vlan_dev.c */
-int vlan_dev_rebuild_header(struct sk_buff *skb);
 int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
 		  struct packet_type *ptype, struct net_device *orig_dev);
-int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
-			 unsigned short type, const void *daddr,
-			 const void *saddr, unsigned len);
-int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev);
-int vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb, struct net_device *dev);
-int vlan_dev_change_mtu(struct net_device *dev, int new_mtu);
-int vlan_dev_open(struct net_device* dev);
-int vlan_dev_stop(struct net_device* dev);
-int vlan_set_mac_address(struct net_device *dev, void *p);
-int vlan_dev_ioctl(struct net_device* dev, struct ifreq *ifr, int cmd);
 void vlan_dev_set_ingress_priority(const struct net_device *dev,
 				   u32 skb_prio, short vlan_prio);
 int vlan_dev_set_egress_priority(const struct net_device *dev,
@@ -70,8 +59,6 @@ int vlan_dev_set_vlan_flag(const struct net_device *dev,
 			   u32 flag, short flag_val);
 void vlan_dev_get_realdev_name(const struct net_device *dev, char *result);
 void vlan_dev_get_vid(const struct net_device *dev, unsigned short *result);
-void vlan_change_rx_flags(struct net_device *dev, int change);
-void vlan_dev_set_multicast_list(struct net_device *vlan_dev);
 
 int vlan_check_real_dev(struct net_device *real_dev, unsigned short vlan_id);
 void vlan_setup(struct net_device *dev);
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 9543e91..51ce421 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -47,7 +47,7 @@
  *
  * TODO:  This needs a checkup, I'm ignorant here. --BLG
  */
-int vlan_dev_rebuild_header(struct sk_buff *skb)
+static int vlan_dev_rebuild_header(struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
 	struct vlan_ethhdr *veth = (struct vlan_ethhdr *)(skb->data);
@@ -342,9 +342,10 @@ static inline unsigned short vlan_dev_get_egress_qos_mask(struct net_device* dev
  *  This is called when the SKB is moving down the stack towards the
  *  physical devices.
  */
-int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
-			 unsigned short type,
-			 const void *daddr, const void *saddr, unsigned len)
+static int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
+				unsigned short type,
+				const void *daddr, const void *saddr,
+				unsigned int len)
 {
 	struct vlan_hdr *vhdr;
 	unsigned short veth_TCI = 0;
@@ -451,7 +452,7 @@ int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 	return rc;
 }
 
-int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct net_device_stats *stats = &dev->stats;
 	struct vlan_ethhdr *veth = (struct vlan_ethhdr *)(skb->data);
@@ -512,7 +513,8 @@ int vlan_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
-int vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
+static int vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb,
+					    struct net_device *dev)
 {
 	struct net_device_stats *stats = &dev->stats;
 	unsigned short veth_TCI;
@@ -536,7 +538,7 @@ int vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb, struct net_device *dev
 	return 0;
 }
 
-int vlan_dev_change_mtu(struct net_device *dev, int new_mtu)
+static int vlan_dev_change_mtu(struct net_device *dev, int new_mtu)
 {
 	/* TODO: gotta make sure the underlying layer can handle it,
 	 * maybe an IFF_VLAN_CAPABLE flag for devices?
@@ -626,7 +628,7 @@ void vlan_dev_get_vid(const struct net_device *dev, unsigned short *result)
 	*result = VLAN_DEV_INFO(dev)->vlan_id;
 }
 
-int vlan_dev_open(struct net_device *dev)
+static int vlan_dev_open(struct net_device *dev)
 {
 	struct vlan_dev_info *vlan = VLAN_DEV_INFO(dev);
 	struct net_device *real_dev = vlan->real_dev;
@@ -650,7 +652,7 @@ int vlan_dev_open(struct net_device *dev)
 	return 0;
 }
 
-int vlan_dev_stop(struct net_device *dev)
+static int vlan_dev_stop(struct net_device *dev)
 {
 	struct net_device *real_dev = VLAN_DEV_INFO(dev)->real_dev;
 
@@ -666,7 +668,7 @@ int vlan_dev_stop(struct net_device *dev)
 	return 0;
 }
 
-int vlan_set_mac_address(struct net_device *dev, void *p)
+static int vlan_dev_set_mac_address(struct net_device *dev, void *p)
 {
 	struct net_device *real_dev = VLAN_DEV_INFO(dev)->real_dev;
 	struct sockaddr *addr = p;
@@ -692,7 +694,7 @@ out:
 	return 0;
 }
 
-int vlan_dev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
+static int vlan_dev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct net_device *real_dev = VLAN_DEV_INFO(dev)->real_dev;
 	struct ifreq ifrr;
@@ -716,7 +718,7 @@ int vlan_dev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return err;
 }
 
-void vlan_change_rx_flags(struct net_device *dev, int change)
+static void vlan_dev_change_rx_flags(struct net_device *dev, int change)
 {
 	struct net_device *real_dev = VLAN_DEV_INFO(dev)->real_dev;
 
@@ -726,8 +728,78 @@ void vlan_change_rx_flags(struct net_device *dev, int change)
 		dev_set_promiscuity(real_dev, dev->flags & IFF_PROMISC ? 1 : -1);
 }
 
-/** Taken from Gleb + Lennert's VLAN code, and modified... */
-void vlan_dev_set_multicast_list(struct net_device *vlan_dev)
+static void vlan_dev_set_multicast_list(struct net_device *vlan_dev)
 {
 	dev_mc_sync(VLAN_DEV_INFO(vlan_dev)->real_dev, vlan_dev);
 }
+
+/*
+ * vlan network devices have devices nesting below it, and are a special
+ * "super class" of normal network devices; split their locks off into a
+ * separate class since they always nest.
+ */
+static struct lock_class_key vlan_netdev_xmit_lock_key;
+
+static const struct header_ops vlan_header_ops = {
+	.create	 = vlan_dev_hard_header,
+	.rebuild = vlan_dev_rebuild_header,
+	.parse	 = eth_header_parse,
+};
+
+static int vlan_dev_init(struct net_device *dev)
+{
+	struct net_device *real_dev = VLAN_DEV_INFO(dev)->real_dev;
+	int subclass = 0;
+
+	/* IFF_BROADCAST|IFF_MULTICAST; ??? */
+	dev->flags  = real_dev->flags & ~IFF_UP;
+	dev->iflink = real_dev->ifindex;
+	dev->state  = (real_dev->state & ((1<<__LINK_STATE_NOCARRIER) |
+					  (1<<__LINK_STATE_DORMANT))) |
+		      (1<<__LINK_STATE_PRESENT);
+
+	/* ipv6 shared card related stuff */
+	dev->dev_id = real_dev->dev_id;
+
+	if (is_zero_ether_addr(dev->dev_addr))
+		memcpy(dev->dev_addr, real_dev->dev_addr, dev->addr_len);
+	if (is_zero_ether_addr(dev->broadcast))
+		memcpy(dev->broadcast, real_dev->broadcast, dev->addr_len);
+
+	if (real_dev->features & NETIF_F_HW_VLAN_TX) {
+		dev->header_ops      = real_dev->header_ops;
+		dev->hard_header_len = real_dev->hard_header_len;
+		dev->hard_start_xmit = vlan_dev_hwaccel_hard_start_xmit;
+	} else {
+		dev->header_ops      = &vlan_header_ops;
+		dev->hard_header_len = real_dev->hard_header_len + VLAN_HLEN;
+		dev->hard_start_xmit = vlan_dev_hard_start_xmit;
+	}
+
+	if (real_dev->priv_flags & IFF_802_1Q_VLAN)
+		subclass = 1;
+
+	lockdep_set_class_and_subclass(&dev->_xmit_lock,
+				&vlan_netdev_xmit_lock_key, subclass);
+	return 0;
+}
+
+void vlan_setup(struct net_device *dev)
+{
+	ether_setup(dev);
+
+	dev->priv_flags		|= IFF_802_1Q_VLAN;
+	dev->tx_queue_len	= 0;
+
+	dev->change_mtu		= vlan_dev_change_mtu;
+	dev->init		= vlan_dev_init;
+	dev->open		= vlan_dev_open;
+	dev->stop		= vlan_dev_stop;
+	dev->set_mac_address	= vlan_dev_set_mac_address;
+	dev->set_multicast_list	= vlan_dev_set_multicast_list;
+	dev->change_rx_flags	= vlan_dev_change_rx_flags;
+	dev->do_ioctl		= vlan_dev_ioctl;
+	dev->destructor		= free_netdev;
+
+	memset(dev->broadcast, 0, ETH_ALEN);
+}
