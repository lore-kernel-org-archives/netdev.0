From: Patrick McHardy <kaber@trash.net>
Subject: [RFC VLAN 02/10]: Convert name-based configuration functions to struct netdevice *
Date: Tue,  5 Jun 2007 16:36:54 +0200 (MEST)
Message-ID: <20070605143653.23717.58937.sendpatchset@localhost.localdomain>
References: <20070605143650.23717.91261.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64419 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764172AbXFEOgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 10:36:55 -0400
In-Reply-To: <20070605143650.23717.91261.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[VLAN]: Convert name-based configuration functions to struct netdevice *

Move the device lookup and checks to the ioctl handler under the RTNL and
change all name-based interfaces to take a struct net_device * instead.

This allows to use them from a netlink interface, which identifies devices
based on ifindex not name. It also avoids races between the ioctl interface
and the (upcoming) netlink interface since now all changes happen under the
RTNL.

As a nice side effect this greatly simplifies error handling in the helper
functions and fixes a number of incorrect error codes like -EINVAL for
device not found.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 9f146bc68a86cb588f3150894b3af5646cfb4fdc
tree f28cb67843e6c566b6b3923aaefc5097c1c82d58
parent 576d73325b7ce3d454c544dcdfea0a2e3ae6486e
author Patrick McHardy <kaber@trash.net> Tue, 05 Jun 2007 16:33:44 +0200
committer Patrick McHardy <kaber@trash.net> Tue, 05 Jun 2007 16:33:44 +0200

 net/8021q/vlan.c     |  152 +++++++++++++++++++++-----------------------------
 net/8021q/vlan.h     |   13 +++-
 net/8021q/vlan_dev.c |  143 +++++++++++++----------------------------------
 3 files changed, 109 insertions(+), 199 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index f3b1328..788324a 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -278,43 +278,16 @@ static int unregister_vlan_dev(struct net_device *real_dev,
 	return ret;
 }
 
-static int unregister_vlan_device(const char *vlan_IF_name)
+static int unregister_vlan_device(struct net_device *dev)
 {
-	struct net_device *dev = NULL;
 	int ret;
 
+	ret = unregister_vlan_dev(VLAN_DEV_INFO(dev)->real_dev,
+				  VLAN_DEV_INFO(dev)->vlan_id);
+	unregister_netdevice(dev);
 
-	dev = dev_get_by_name(vlan_IF_name);
-	ret = -EINVAL;
-	if (dev) {
-		if (dev->priv_flags & IFF_802_1Q_VLAN) {
-			rtnl_lock();
-
-			ret = unregister_vlan_dev(VLAN_DEV_INFO(dev)->real_dev,
-						  VLAN_DEV_INFO(dev)->vlan_id);
-
-			dev_put(dev);
-			unregister_netdevice(dev);
-
-			rtnl_unlock();
-
-			if (ret == 1)
-				ret = 0;
-		} else {
-			printk(VLAN_ERR
-			       "%s: ERROR:	Tried to remove a non-vlan device "
-			       "with VLAN code, name: %s  priv_flags: %hX\n",
-			       __FUNCTION__, dev->name, dev->priv_flags);
-			dev_put(dev);
-			ret = -EPERM;
-		}
-	} else {
-#ifdef VLAN_DEBUG
-		printk(VLAN_DBG "%s: WARNING: Could not find dev.\n", __FUNCTION__);
-#endif
-		ret = -EINVAL;
-	}
-
+	if (ret == 1)
+		ret = 0;
 	return ret;
 }
 
@@ -378,12 +351,11 @@ static struct lock_class_key vlan_netdev_xmit_lock_key;
  *  Returns the device that was created, or NULL if there was
  *  an error of some kind.
  */
-static struct net_device *register_vlan_device(const char *eth_IF_name,
+static struct net_device *register_vlan_device(struct net_device *real_dev,
 					       unsigned short VLAN_ID)
 {
 	struct vlan_group *grp;
 	struct net_device *new_dev;
-	struct net_device *real_dev; /* the ethernet device */
 	char name[IFNAMSIZ];
 	int i;
 
@@ -395,46 +367,36 @@ static struct net_device *register_vlan_device(const char *eth_IF_name,
 	if (VLAN_ID > VLAN_VID_MASK)
 		goto out_ret_null;
 
-	/* find the device relating to eth_IF_name. */
-	real_dev = dev_get_by_name(eth_IF_name);
-	if (!real_dev)
-		goto out_ret_null;
-
 	if (real_dev->features & NETIF_F_VLAN_CHALLENGED) {
 		printk(VLAN_DBG "%s: VLANs not supported on %s.\n",
 			__FUNCTION__, real_dev->name);
-		goto out_put_dev;
+		goto out_ret_null;
 	}
 
 	if ((real_dev->features & NETIF_F_HW_VLAN_RX) &&
 	    !real_dev->vlan_rx_register) {
 		printk(VLAN_DBG "%s: Device %s has buggy VLAN hw accel.\n",
 			__FUNCTION__, real_dev->name);
-		goto out_put_dev;
+		goto out_ret_null;
 	}
 
 	if ((real_dev->features & NETIF_F_HW_VLAN_FILTER) &&
 	    (!real_dev->vlan_rx_add_vid || !real_dev->vlan_rx_kill_vid)) {
 		printk(VLAN_DBG "%s: Device %s has buggy VLAN hw accel.\n",
 			__FUNCTION__, real_dev->name);
-		goto out_put_dev;
+		goto out_ret_null;
 	}
 
-	/* From this point on, all the data structures must remain
-	 * consistent.
-	 */
-	rtnl_lock();
-
 	/* The real device must be up and operating in order to
 	 * assosciate a VLAN device with it.
 	 */
 	if (!(real_dev->flags & IFF_UP))
-		goto out_unlock;
+		goto out_ret_null;
 
 	if (__find_vlan_dev(real_dev, VLAN_ID) != NULL) {
 		/* was already registered. */
 		printk(VLAN_DBG "%s: ALREADY had VLAN registered\n", __FUNCTION__);
-		goto out_unlock;
+		goto out_ret_null;
 	}
 
 	/* Gotta set up the fields for the device. */
@@ -471,7 +433,7 @@ static struct net_device *register_vlan_device(const char *eth_IF_name,
 			       vlan_setup);
 
 	if (new_dev == NULL)
-		goto out_unlock;
+		goto out_ret_null;
 
 #ifdef VLAN_DEBUG
 	printk(VLAN_DBG "Allocated new name -:%s:-\n", new_dev->name);
@@ -577,9 +539,8 @@ static struct net_device *register_vlan_device(const char *eth_IF_name,
 	if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
 		real_dev->vlan_rx_add_vid(real_dev, VLAN_ID);
 
-	rtnl_unlock();
-
-
+	/* Account for reference in struct vlan_dev_info */
+	dev_hold(real_dev);
 #ifdef VLAN_DEBUG
 	printk(VLAN_DBG "Allocated new device successfully, returning.\n");
 #endif
@@ -590,17 +551,11 @@ out_free_arrays:
 
 out_free_unregister:
 	unregister_netdev(new_dev);
-	goto out_unlock;
+	goto out_ret_null;
 
 out_free_newdev:
 	free_netdev(new_dev);
 
-out_unlock:
-	rtnl_unlock();
-
-out_put_dev:
-	dev_put(real_dev);
-
 out_ret_null:
 	return NULL;
 }
@@ -693,9 +648,10 @@ out:
  */
 static int vlan_ioctl_handler(void __user *arg)
 {
-	int err = 0;
+	int err;
 	unsigned short vid = 0;
 	struct vlan_ioctl_args args;
+	struct net_device *dev = NULL;
 
 	if (copy_from_user(&args, arg, sizeof(struct vlan_ioctl_args)))
 		return -EFAULT;
@@ -708,34 +664,59 @@ static int vlan_ioctl_handler(void __user *arg)
 	printk(VLAN_DBG "%s: args.cmd: %x\n", __FUNCTION__, args.cmd);
 #endif
 
+	rtnl_lock();
+
 	switch (args.cmd) {
 	case SET_VLAN_INGRESS_PRIORITY_CMD:
+	case SET_VLAN_EGRESS_PRIORITY_CMD:
+	case SET_VLAN_FLAG_CMD:
+	case ADD_VLAN_CMD:
+	case DEL_VLAN_CMD:
+	case GET_VLAN_REALDEV_NAME_CMD:
+	case GET_VLAN_VID_CMD:
+		err = -ENODEV;
+		dev = __dev_get_by_name(args.device1);
+		if (!dev)
+			goto out;
+
+		err = -EINVAL;
+		if (args.cmd != ADD_VLAN_CMD &&
+		    !(dev->priv_flags & IFF_802_1Q_VLAN))
+			goto out;
+	}
+
+	switch (args.cmd) {
+	case SET_VLAN_INGRESS_PRIORITY_CMD:
+		err = -EPERM;
 		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
-		err = vlan_dev_set_ingress_priority(args.device1,
-						    args.u.skb_priority,
-						    args.vlan_qos);
+			break;
+		vlan_dev_set_ingress_priority(dev,
+					      args.u.skb_priority,
+					      args.vlan_qos);
 		break;
 
 	case SET_VLAN_EGRESS_PRIORITY_CMD:
+		err = -EPERM;
 		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
-		err = vlan_dev_set_egress_priority(args.device1,
+			break;
+		err = vlan_dev_set_egress_priority(dev,
 						   args.u.skb_priority,
 						   args.vlan_qos);
 		break;
 
 	case SET_VLAN_FLAG_CMD:
+		err = -EPERM;
 		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
-		err = vlan_dev_set_vlan_flag(args.device1,
+			break;
+		err = vlan_dev_set_vlan_flag(dev,
 					     args.u.flag,
 					     args.vlan_qos);
 		break;
 
 	case SET_VLAN_NAME_TYPE_CMD:
+		err = -EPERM;
 		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
+			break;
 		if ((args.u.name_type >= 0) &&
 		    (args.u.name_type < VLAN_NAME_TYPE_HIGHEST)) {
 			vlan_name_type = args.u.name_type;
@@ -746,13 +727,10 @@ static int vlan_ioctl_handler(void __user *arg)
 		break;
 
 	case ADD_VLAN_CMD:
+		err = -EPERM;
 		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
-		/* we have been given the name of the Ethernet Device we want to
-		 * talk to:  args.dev1	 We also have the
-		 * VLAN ID:  args.u.VID
-		 */
-		if (register_vlan_device(args.device1, args.u.VID)) {
+			break;
+		if (register_vlan_device(dev, args.u.VID)) {
 			err = 0;
 		} else {
 			err = -EINVAL;
@@ -760,12 +738,10 @@ static int vlan_ioctl_handler(void __user *arg)
 		break;
 
 	case DEL_VLAN_CMD:
+		err = -EPERM;
 		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
-		/* Here, the args.dev1 is the actual VLAN we want
-		 * to get rid of.
-		 */
-		err = unregister_vlan_device(args.device1);
+			break;
+		err = unregister_vlan_device(dev);
 		break;
 
 	case GET_VLAN_INGRESS_PRIORITY_CMD:
@@ -789,9 +765,7 @@ static int vlan_ioctl_handler(void __user *arg)
 		err = -EINVAL;
 		break;
 	case GET_VLAN_REALDEV_NAME_CMD:
-		err = vlan_dev_get_realdev_name(args.device1, args.u.device2);
-		if (err)
-			goto out;
+		vlan_dev_get_realdev_name(dev, args.u.device2);
 		if (copy_to_user(arg, &args,
 				 sizeof(struct vlan_ioctl_args))) {
 			err = -EFAULT;
@@ -799,9 +773,7 @@ static int vlan_ioctl_handler(void __user *arg)
 		break;
 
 	case GET_VLAN_VID_CMD:
-		err = vlan_dev_get_vid(args.device1, &vid);
-		if (err)
-			goto out;
+		vlan_dev_get_vid(dev, &vid);
 		args.u.VID = vid;
 		if (copy_to_user(arg, &args,
 				 sizeof(struct vlan_ioctl_args))) {
@@ -813,9 +785,11 @@ static int vlan_ioctl_handler(void __user *arg)
 		/* pass on to underlying device instead?? */
 		printk(VLAN_DBG "%s: Unknown VLAN CMD: %x \n",
 			__FUNCTION__, args.cmd);
-		return -EINVAL;
+		err = -EINVAL;
+		break;
 	}
 out:
+	rtnl_unlock();
 	return err;
 }
 
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 1976cdb..b837390 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -62,11 +62,14 @@ int vlan_dev_set_mac_address(struct net_device *dev, void* addr);
 int vlan_dev_open(struct net_device* dev);
 int vlan_dev_stop(struct net_device* dev);
 int vlan_dev_ioctl(struct net_device* dev, struct ifreq *ifr, int cmd);
-int vlan_dev_set_ingress_priority(char* dev_name, __u32 skb_prio, short vlan_prio);
-int vlan_dev_set_egress_priority(char* dev_name, __u32 skb_prio, short vlan_prio);
-int vlan_dev_set_vlan_flag(char* dev_name, __u32 flag, short flag_val);
-int vlan_dev_get_realdev_name(const char* dev_name, char* result);
-int vlan_dev_get_vid(const char* dev_name, unsigned short* result);
+void vlan_dev_set_ingress_priority(const struct net_device *dev,
+				   u32 skb_prio, short vlan_prio);
+int vlan_dev_set_egress_priority(const struct net_device *dev,
+				 u32 skb_prio, short vlan_prio);
+int vlan_dev_set_vlan_flag(const struct net_device *dev,
+			   u32 flag, short flag_val);
+void vlan_dev_get_realdev_name(const struct net_device *dev, char *result);
+void vlan_dev_get_vid(const struct net_device *dev, unsigned short *result);
 void vlan_dev_set_multicast_list(struct net_device *vlan_dev);
 
 #endif /* !(__BEN_VLAN_802_1Q_INC__) */
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index ec46084..0b7e03e 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -534,136 +534,69 @@ int vlan_dev_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
-int vlan_dev_set_ingress_priority(char *dev_name, __u32 skb_prio, short vlan_prio)
+void vlan_dev_set_ingress_priority(const struct net_device *dev,
+				   u32 skb_prio, short vlan_prio)
 {
-	struct net_device *dev = dev_get_by_name(dev_name);
-
-	if (dev) {
-		if (dev->priv_flags & IFF_802_1Q_VLAN) {
-			/* see if a priority mapping exists.. */
-			VLAN_DEV_INFO(dev)->ingress_priority_map[vlan_prio & 0x7] = skb_prio;
-			dev_put(dev);
-			return 0;
-		}
-
-		dev_put(dev);
-	}
-	return -EINVAL;
+	VLAN_DEV_INFO(dev)->ingress_priority_map[vlan_prio & 0x7] = skb_prio;
 }
 
-int vlan_dev_set_egress_priority(char *dev_name, __u32 skb_prio, short vlan_prio)
+int vlan_dev_set_egress_priority(const struct net_device *dev,
+				 u32 skb_prio, short vlan_prio)
 {
-	struct net_device *dev = dev_get_by_name(dev_name);
 	struct vlan_priority_tci_mapping *mp = NULL;
 	struct vlan_priority_tci_mapping *np;
 
-	if (dev) {
-		if (dev->priv_flags & IFF_802_1Q_VLAN) {
-			/* See if a priority mapping exists.. */
-			mp = VLAN_DEV_INFO(dev)->egress_priority_map[skb_prio & 0xF];
-			while (mp) {
-				if (mp->priority == skb_prio) {
-					mp->vlan_qos = ((vlan_prio << 13) & 0xE000);
-					dev_put(dev);
-					return 0;
-				}
-				mp = mp->next;
-			}
-
-			/* Create a new mapping then. */
-			mp = VLAN_DEV_INFO(dev)->egress_priority_map[skb_prio & 0xF];
-			np = kmalloc(sizeof(struct vlan_priority_tci_mapping), GFP_KERNEL);
-			if (np) {
-				np->next = mp;
-				np->priority = skb_prio;
-				np->vlan_qos = ((vlan_prio << 13) & 0xE000);
-				VLAN_DEV_INFO(dev)->egress_priority_map[skb_prio & 0xF] = np;
-				dev_put(dev);
-				return 0;
-			} else {
-				dev_put(dev);
-				return -ENOBUFS;
-			}
+	/* See if a priority mapping exists.. */
+	mp = VLAN_DEV_INFO(dev)->egress_priority_map[skb_prio & 0xF];
+	while (mp) {
+		if (mp->priority == skb_prio) {
+			mp->vlan_qos = ((vlan_prio << 13) & 0xE000);
+			return 0;
 		}
-		dev_put(dev);
+		mp = mp->next;
 	}
-	return -EINVAL;
+
+	/* Create a new mapping then. */
+	mp = VLAN_DEV_INFO(dev)->egress_priority_map[skb_prio & 0xF];
+	np = kmalloc(sizeof(struct vlan_priority_tci_mapping), GFP_KERNEL);
+	if (!np)
+		return -ENOBUFS;
+
+	np->next = mp;
+	np->priority = skb_prio;
+	np->vlan_qos = ((vlan_prio << 13) & 0xE000);
+	VLAN_DEV_INFO(dev)->egress_priority_map[skb_prio & 0xF] = np;
+	return 0;
 }
 
 /* Flags are defined in the vlan_dev_info class in include/linux/if_vlan.h file. */
-int vlan_dev_set_vlan_flag(char *dev_name, __u32 flag, short flag_val)
+int vlan_dev_set_vlan_flag(const struct net_device *dev,
+			   u32 flag, short flag_val)
 {
-	struct net_device *dev = dev_get_by_name(dev_name);
-
-	if (dev) {
-		if (dev->priv_flags & IFF_802_1Q_VLAN) {
-			/* verify flag is supported */
-			if (flag == 1) {
-				if (flag_val) {
-					VLAN_DEV_INFO(dev)->flags |= 1;
-				} else {
-					VLAN_DEV_INFO(dev)->flags &= ~1;
-				}
-				dev_put(dev);
-				return 0;
-			} else {
-				printk(KERN_ERR  "%s: flag %i is not valid.\n",
-					__FUNCTION__, (int)(flag));
-				dev_put(dev);
-				return -EINVAL;
-			}
+	/* verify flag is supported */
+	if (flag == 1) {
+		if (flag_val) {
+			VLAN_DEV_INFO(dev)->flags |= 1;
 		} else {
-			printk(KERN_ERR
-			       "%s: %s is not a vlan device, priv_flags: %hX.\n",
-			       __FUNCTION__, dev->name, dev->priv_flags);
-			dev_put(dev);
+			VLAN_DEV_INFO(dev)->flags &= ~1;
 		}
-	} else {
-		printk(KERN_ERR  "%s: Could not find device: %s\n",
-			__FUNCTION__, dev_name);
+		return 0;
 	}
-
+	printk(KERN_ERR  "%s: flag %i is not valid.\n",
+			__FUNCTION__, (int)(flag));
 	return -EINVAL;
 }
 
-
-int vlan_dev_get_realdev_name(const char *dev_name, char* result)
+void vlan_dev_get_realdev_name(const struct net_device *dev, char *result)
 {
-	struct net_device *dev = dev_get_by_name(dev_name);
-	int rv = 0;
-	if (dev) {
-		if (dev->priv_flags & IFF_802_1Q_VLAN) {
-			strncpy(result, VLAN_DEV_INFO(dev)->real_dev->name, 23);
-			rv = 0;
-		} else {
-			rv = -EINVAL;
-		}
-		dev_put(dev);
-	} else {
-		rv = -ENODEV;
-	}
-	return rv;
+	strncpy(result, VLAN_DEV_INFO(dev)->real_dev->name, 23);
 }
 
-int vlan_dev_get_vid(const char *dev_name, unsigned short* result)
+void vlan_dev_get_vid(const struct net_device *dev, unsigned short *result)
 {
-	struct net_device *dev = dev_get_by_name(dev_name);
-	int rv = 0;
-	if (dev) {
-		if (dev->priv_flags & IFF_802_1Q_VLAN) {
-			*result = VLAN_DEV_INFO(dev)->vlan_id;
-			rv = 0;
-		} else {
-			rv = -EINVAL;
-		}
-		dev_put(dev);
-	} else {
-		rv = -ENODEV;
-	}
-	return rv;
+	*result = VLAN_DEV_INFO(dev)->vlan_id;
 }
 
-
 int vlan_dev_set_mac_address(struct net_device *dev, void *addr_struct_p)
 {
 	struct sockaddr *addr = (struct sockaddr *)(addr_struct_p);
