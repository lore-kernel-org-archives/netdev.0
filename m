From: Patrick McHardy <kaber@trash.net>
Subject: [RFC VLAN 05/08]: Split up device creation
Date: Tue,  5 Jun 2007 16:23:37 +0200 (MEST)
Message-ID: <20070605142336.20372.3681.sendpatchset@localhost.localdomain>
References: <20070605142327.20372.18108.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64170 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764401AbXFEOXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 10:23:38 -0400
In-Reply-To: <20070605142327.20372.18108.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[VLAN]: Split up device creation

Split up device creation in allocation/registration functions taking
struct net_device * and a small wrapper for the ioctl handling. This is
needed by the netlink interface to properly set up the device before
registration.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit c59e99d32d8085f8ed1aa794106c28e546220581
tree dca7eeb9815666e863e5739a8c0a4698333026bc
parent 1057887432918a89e5b374c29ac36224716cb0e4
author Patrick McHardy <kaber@trash.net> Tue, 29 May 2007 17:52:41 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 29 May 2007 17:52:41 +0200

 net/8021q/vlan.c |  196 ++++++++++++++++++++++++++----------------------------
 net/8021q/vlan.h |    4 +
 2 files changed, 100 insertions(+), 100 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index d470913..e5405cf 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -380,64 +380,110 @@ static void vlan_transfer_operstate(const struct net_device *dev, struct net_dev
 	}
 }
 
-/*  Attach a VLAN device to a mac address (ie Ethernet Card).
- *  Returns the device that was created, or NULL if there was
- *  an error of some kind.
- */
-static struct net_device *register_vlan_device(struct net_device *real_dev,
-					       unsigned short VLAN_ID)
+int vlan_check_device(struct net_device *dev, unsigned short vlan_id)
 {
-	struct vlan_group *grp, *reg = NULL;
-	struct net_device *new_dev;
-	char name[IFNAMSIZ];
-
-#ifdef VLAN_DEBUG
-	printk(VLAN_DBG "%s: if_name -:%s:-	vid: %i\n",
-		__FUNCTION__, eth_IF_name, VLAN_ID);
-#endif
-
-	if (VLAN_ID >= VLAN_VID_MASK)
-		goto out_ret_null;
-
-	if (real_dev->features & NETIF_F_VLAN_CHALLENGED) {
+	if (dev->features & NETIF_F_VLAN_CHALLENGED) {
 		printk(VLAN_DBG "%s: VLANs not supported on %s.\n",
-			__FUNCTION__, real_dev->name);
-		goto out_ret_null;
+			__FUNCTION__, dev->name);
+		return -EOPNOTSUPP;
 	}
 
-	if ((real_dev->features & NETIF_F_HW_VLAN_RX) &&
-	    (real_dev->vlan_rx_register == NULL ||
-	     real_dev->vlan_rx_kill_vid == NULL)) {
+	if ((dev->features & NETIF_F_HW_VLAN_RX) &&
+	    (dev->vlan_rx_register == NULL || dev->vlan_rx_kill_vid == NULL)) {
 		printk(VLAN_DBG "%s: Device %s has buggy VLAN hw accel.\n",
-			__FUNCTION__, real_dev->name);
-		goto out_ret_null;
+			__FUNCTION__, dev->name);
+		return -EOPNOTSUPP;
 	}
 
-	if ((real_dev->features & NETIF_F_HW_VLAN_FILTER) &&
-	    (real_dev->vlan_rx_add_vid == NULL ||
-	     real_dev->vlan_rx_kill_vid == NULL)) {
+	if ((dev->features & NETIF_F_HW_VLAN_FILTER) &&
+	    (dev->vlan_rx_add_vid == NULL || dev->vlan_rx_kill_vid == NULL)) {
 		printk(VLAN_DBG "%s: Device %s has buggy VLAN hw accel.\n",
-			__FUNCTION__, real_dev->name);
-		goto out_ret_null;
+			__FUNCTION__, dev->name);
+		return -EOPNOTSUPP;
 	}
 
 	/* The real device must be up and operating in order to
-	 * assosciate a VLAN device with it.
+	 * associate a VLAN device with it.
 	 */
-	if (!(real_dev->flags & IFF_UP))
-		goto out_ret_null;
+	if (!(dev->flags & IFF_UP))
+		return -ENETDOWN;
 
-	if (__find_vlan_dev(real_dev, VLAN_ID) != NULL) {
-		/* was already registered. */
-		printk(VLAN_DBG "%s: ALREADY had VLAN registered\n", __FUNCTION__);
-		goto out_ret_null;
+	if (__find_vlan_dev(dev, vlan_id) != NULL)
+		return -EEXIST;
+
+	return 0;
+}
+
+int vlan_register_dev(struct net_device *dev)
+{
+	struct vlan_dev_info *vlan = VLAN_DEV_INFO(dev);
+	struct net_device *real_dev = vlan->real_dev;
+	struct vlan_group *group, *reg = NULL;
+	int err;
+
+	group = __vlan_find_group(real_dev->ifindex);
+	if (!group) {
+		err = -ENOMEM;
+		group = reg = vlan_group_alloc(real_dev->ifindex);
+		if (!group)
+			goto err1;
 	}
 
-	/* Gotta set up the fields for the device. */
+	err = register_netdevice(dev);
+	if (err < 0)
+		goto err2;
+
+	/* Account for reference in struct vlan_dev_info */
+	dev_hold(real_dev);
+
+	vlan_transfer_operstate(real_dev, dev);
+	linkwatch_fire_event(dev); /* _MUST_ call rfc2863_policy() */
+
+	/* So, got the sucker initialized, now lets place
+	 * it into our local structure.
+	 */
+	vlan_group_set_device(group, vlan->vlan_id, dev);
+
+	if (reg && real_dev->features & NETIF_F_HW_VLAN_RX)
+		real_dev->vlan_rx_register(real_dev, reg);
+	if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
+		real_dev->vlan_rx_add_vid(real_dev, vlan->vlan_id);
+
+	if (vlan_proc_add_dev(dev) < 0)
+		printk(KERN_WARNING "VLAN: failed to add proc entry for %s\n",
+		       dev->name);
+	return 0;
+
+err2:
+	if (reg)
+		vlan_group_free(reg);
+err1:
+	return err;
+}
+
+/*  Attach a VLAN device to a mac address (ie Ethernet Card).
+ *  Returns 0 if the device was created or a negative error code otherwise.
+ */
+static int register_vlan_device(struct net_device *real_dev,
+				unsigned short VLAN_ID)
+{
+	struct net_device *new_dev;
+	char name[IFNAMSIZ];
+	int err;
+
 #ifdef VLAN_DEBUG
-	printk(VLAN_DBG "About to allocate name, vlan_name_type: %i\n",
-	       vlan_name_type);
+	printk(VLAN_DBG "%s: if_name -:%s:-	vid: %i\n",
+		__FUNCTION__, eth_IF_name, VLAN_ID);
 #endif
+
+	if (VLAN_ID >= VLAN_VID_MASK)
+		return -ERANGE;
+
+	err = vlan_check_device(real_dev, VLAN_ID);
+	if (err < 0)
+		return err;
+
+	/* Gotta set up the fields for the device. */
 	switch (vlan_name_type) {
 	case VLAN_NAME_TYPE_RAW_PLUS_VID:
 		/* name will look like:	 eth1.0005 */
@@ -465,71 +511,25 @@ static struct net_device *register_vlan_device(struct net_device *real_dev,
 
 	new_dev = alloc_netdev(sizeof(struct vlan_dev_info), name,
 			       vlan_setup);
-
 	if (new_dev == NULL)
-		goto out_ret_null;
+		return -ENOMEM;
 
 #ifdef VLAN_DEBUG
 	printk(VLAN_DBG "Allocated new name -:%s:-\n", new_dev->name);
-#endif
-
-	VLAN_DEV_INFO(new_dev)->vlan_id = VLAN_ID; /* 1 through VLAN_VID_MASK */
-	VLAN_DEV_INFO(new_dev)->real_dev = real_dev;
-	VLAN_DEV_INFO(new_dev)->dent = NULL;
-	VLAN_DEV_INFO(new_dev)->flags = 1;
-
 	VLAN_MEM_DBG("new_dev->priv malloc, addr: %p  size: %i\n",
 		     new_dev->priv,
 		     sizeof(struct vlan_dev_info));
-
-#ifdef VLAN_DEBUG
-	printk(VLAN_DBG "About to go find the group for idx: %i\n",
-	       real_dev->ifindex);
-#endif
-	grp = __vlan_find_group(real_dev->ifindex);
-	if (!grp) {
-		reg = grp = vlan_group_alloc(real_dev->ifindex);
-		if (!grp)
-			goto out_free_newdev;
-	}
-
-	if (register_netdevice(new_dev))
-		goto out_free_group;
-
-	vlan_transfer_operstate(real_dev, new_dev);
-	linkwatch_fire_event(new_dev); /* _MUST_ call rfc2863_policy() */
-
-	/* So, got the sucker initialized, now lets place
-	 * it into our local structure.
-	 */
-	if (reg && real_dev->features & NETIF_F_HW_VLAN_RX)
-		real_dev->vlan_rx_register(real_dev, reg);
-
-	vlan_group_set_device(grp, VLAN_ID, new_dev);
-
-	if (vlan_proc_add_dev(new_dev)<0)/* create it's proc entry */
-		printk(KERN_WARNING "VLAN: failed to add proc entry for %s\n",
-							 new_dev->name);
-
-	if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
-		real_dev->vlan_rx_add_vid(real_dev, VLAN_ID);
-
-	/* Account for reference in struct vlan_dev_info */
-	dev_hold(real_dev);
-#ifdef VLAN_DEBUG
-	printk(VLAN_DBG "Allocated new device successfully, returning.\n");
 #endif
-	return new_dev;
 
-out_free_group:
-	if (reg)
-		vlan_group_free(reg);
+	VLAN_DEV_INFO(new_dev)->vlan_id = VLAN_ID; /* 1 through VLAN_VID_MASK */
+	VLAN_DEV_INFO(new_dev)->real_dev = real_dev;
+	VLAN_DEV_INFO(new_dev)->flags = 1;
 
-out_free_newdev:
-	free_netdev(new_dev);
+	err = vlan_register_dev(new_dev);
+	if (err < 0)
+		free_netdev(new_dev);
 
-out_ret_null:
-	return NULL;
+	return 0;
 }
 
 static int vlan_device_event(struct notifier_block *unused, unsigned long event, void *ptr)
@@ -699,11 +699,7 @@ static int vlan_ioctl_handler(void __user *arg)
 		 * talk to:  args.dev1	 We also have the
 		 * VLAN ID:  args.u.VID
 		 */
-		if (register_vlan_device(dev, args.u.VID)) {
-			err = 0;
-		} else {
-			err = -EINVAL;
-		}
+		err = register_vlan_device(dev, args.u.VID);
 		break;
 
 	case DEL_VLAN_CMD:
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index b837390..47f0c53 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -72,4 +72,8 @@ void vlan_dev_get_realdev_name(const struct net_device *dev, char *result);
 void vlan_dev_get_vid(const struct net_device *dev, unsigned short *result);
 void vlan_dev_set_multicast_list(struct net_device *vlan_dev);
 
+int vlan_check_device(struct net_device *dev, unsigned short vlan_id);
+int vlan_register_dev(struct net_device *dev);
+int vlan_unregister_dev(struct net_device *dev);
+
 #endif /* !(__BEN_VLAN_802_1Q_INC__) */
