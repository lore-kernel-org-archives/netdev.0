From: Ben Greear <greearb@candelatech.com>
Subject: VLAN patch for 2.4.21
Date: Tue, 05 Aug 2003 17:27:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F304B62.3010505@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here is a patch that adds a few new IOCTL options (not new IOCTLs per se)
for the 802.1Q VLANs.  One ioctl allows one to get the VID for a device by
the interface name.  A second gets the name of the underlying device for
the VLAN device.  Tested on x86 and PPC.

Comments welcome!

Thanks,
Ben



--- linux-2.4.21/net/8021q/vlan_dev.c	2003-06-13 07:51:39.000000000 -0700
+++ linux-2.4.21.amds/net/8021q/vlan_dev.c	2003-07-30 16:20:41.000000000 -0700
@@ -1,4 +1,4 @@
-/*
+/* -*- linux-c -*-
   * INET		802.1Q VLAN
   *		Ethernet-type device handling.
   *
@@ -632,6 +632,59 @@
  	return -EINVAL;
  }

+
+int vlan_dev_get_realdev_name(const char *dev_name, char* result)
+{
+	struct net_device *dev = dev_get_by_name(dev_name);
+        int rv = 0;
+
+	if (dev) {
+		if (dev->priv_flags & IFF_802_1Q_VLAN) {
+                        strncpy(result, VLAN_DEV_INFO(dev)->real_dev->name, 23);
+                        dev_put(dev);
+                        rv = 0;
+		} else {
+			printk(KERN_ERR
+			       "%s: %s is not a vlan device, priv_flags: %hX.\n",
+			       __FUNCTION__, dev->name, dev->priv_flags);
+			dev_put(dev);
+                        rv = -EINVAL;
+		}
+	} else {
+		printk(KERN_ERR  "%s: Could not find device: %s\n",
+			__FUNCTION__, dev_name);
+                rv = -ENODEV;
+	}
+
+	return rv;
+}
+
+int vlan_dev_get_vid(const char *dev_name, unsigned short* result)
+{
+	struct net_device *dev = dev_get_by_name(dev_name);
+        int rv = 0;
+
+	if (dev) {
+		if (dev->priv_flags & IFF_802_1Q_VLAN) {
+                        *result = VLAN_DEV_INFO(dev)->vlan_id;
+                        dev_put(dev);
+                        rv = 0;
+		} else {
+			printk(KERN_ERR
+			       "%s: %s is not a vlan device, priv_flags: %hX.\n",
+			       __FUNCTION__, dev->name, dev->priv_flags);
+			dev_put(dev);
+                        rv = -EINVAL;
+		}
+	} else {
+		printk(KERN_ERR  "%s: Could not find device: %s\n",
+			__FUNCTION__, dev_name);
+                rv = -ENODEV;
+	}
+
+	return rv;
+}
+
  int vlan_dev_set_mac_address(struct net_device *dev, void *addr_struct_p)
  {
  	struct sockaddr *addr = (struct sockaddr *)(addr_struct_p);
--- linux-2.4.21/net/8021q/vlan.c	2003-06-13 07:51:39.000000000 -0700
+++ linux-2.4.21.amds/net/8021q/vlan.c	2003-07-30 16:20:41.000000000 -0700
@@ -1,4 +1,4 @@
-/*
+/* -*- linux-c -*-
   * INET		802.1Q VLAN
   *		Ethernet-type device handling.
   *
@@ -655,12 +655,9 @@
  int vlan_ioctl_handler(unsigned long arg)
  {
  	int err = 0;
+        unsigned short vid = 0;
  	struct vlan_ioctl_args args;

-	/* everything here needs root permissions, except aguably the
-	 * hack ioctls for sending packets.  However, I know _I_ don't
-	 * want users running that on my network! --BLG
-	 */
  	if (!capable(CAP_NET_ADMIN))
  		return -EPERM;

@@ -678,24 +675,32 @@

  	switch (args.cmd) {
  	case SET_VLAN_INGRESS_PRIORITY_CMD:
+                if (!capable(CAP_NET_ADMIN))
+                        return -EPERM;
  		err = vlan_dev_set_ingress_priority(args.device1,
  						    args.u.skb_priority,
  						    args.vlan_qos);
  		break;

  	case SET_VLAN_EGRESS_PRIORITY_CMD:
+                if (!capable(CAP_NET_ADMIN))
+                        return -EPERM;
  		err = vlan_dev_set_egress_priority(args.device1,
  						   args.u.skb_priority,
  						   args.vlan_qos);
  		break;

  	case SET_VLAN_FLAG_CMD:
+                if (!capable(CAP_NET_ADMIN))
+                        return -EPERM;
  		err = vlan_dev_set_vlan_flag(args.device1,
  					     args.u.flag,
  					     args.vlan_qos);
  		break;

  	case SET_VLAN_NAME_TYPE_CMD:
+                if (!capable(CAP_NET_ADMIN))
+                        return -EPERM;
  		if ((args.u.name_type >= 0) &&
  		    (args.u.name_type < VLAN_NAME_TYPE_HIGHEST)) {
  			vlan_name_type = args.u.name_type;
@@ -705,17 +710,9 @@
  		}
  		break;

-		/* TODO:  Figure out how to pass info back...
-		   case GET_VLAN_INGRESS_PRIORITY_IOCTL:
-		   err = vlan_dev_get_ingress_priority(args);
-		   break;
-
-		   case GET_VLAN_EGRESS_PRIORITY_IOCTL:
-		   err = vlan_dev_get_egress_priority(args);
-		   break;
-		*/
-
  	case ADD_VLAN_CMD:
+                if (!capable(CAP_NET_ADMIN))
+                        return -EPERM;
  		/* we have been given the name of the Ethernet Device we want to
  		 * talk to:  args.dev1	 We also have the
  		 * VLAN ID:  args.u.VID
@@ -728,12 +725,53 @@
  		break;

  	case DEL_VLAN_CMD:
+                if (!capable(CAP_NET_ADMIN))
+                        return -EPERM;
  		/* Here, the args.dev1 is the actual VLAN we want
  		 * to get rid of.
  		 */
  		err = unregister_vlan_device(args.device1);
  		break;

+        case GET_VLAN_INGRESS_PRIORITY_CMD:
+                /* TODO:  Implement
+                err = vlan_dev_get_ingress_priority(args);
+                if (copy_to_user((void*)arg, &args,
+                                 sizeof(struct vlan_ioctl_args))) {
+                        err = -EFAULT;
+                }
+                */
+                err = -EINVAL;
+                break;
+
+        case GET_VLAN_EGRESS_PRIORITY_CMD:
+                /* TODO:  Implement
+		err = vlan_dev_get_egress_priority(args.device1, &(args.args);
+                if (copy_to_user((void*)arg, &args,
+                                 sizeof(struct vlan_ioctl_args))) {
+                        err = -EFAULT;
+                }
+                */
+                err = -EINVAL;
+                break;
+
+        case GET_VLAN_REALDEV_NAME_CMD:
+		err = vlan_dev_get_realdev_name(args.device1, args.u.device2);
+                if (copy_to_user((void*)arg, &args,
+                                 sizeof(struct vlan_ioctl_args))) {
+                        err = -EFAULT;
+                }
+                break;
+
+        case GET_VLAN_VID_CMD:
+		err = vlan_dev_get_vid(args.device1, &vid);
+                args.u.VID = vid;
+                if (copy_to_user((void*)arg, &args,
+                                 sizeof(struct vlan_ioctl_args))) {
+                        err = -EFAULT;
+                }
+                break;
+
  	default:
  		/* pass on to underlying device instead?? */
  		printk(VLAN_DBG "%s: Unknown VLAN CMD: %x \n",
--- linux-2.4.21/net/8021q/vlan.h	2002-08-02 17:39:46.000000000 -0700
+++ linux-2.4.21.amds/net/8021q/vlan.h	2003-07-30 16:30:53.000000000 -0700
@@ -72,6 +72,8 @@
  int vlan_dev_set_ingress_priority(char* dev_name, __u32 skb_prio, short vlan_prio);
  int vlan_dev_set_egress_priority(char* dev_name, __u32 skb_prio, short vlan_prio);
  int vlan_dev_set_vlan_flag(char* dev_name, __u32 flag, short flag_val);
+int vlan_dev_get_realdev_name(const char* dev_name, char* result);
+int vlan_dev_get_vid(const char* dev_name, unsigned short* result);
  void vlan_dev_set_multicast_list(struct net_device *vlan_dev);

  #endif /* !(__BEN_VLAN_802_1Q_INC__) */
--- linux-2.4.21/include/linux/if_vlan.h	2002-11-28 15:53:15.000000000 -0800
+++ linux-2.4.21.amds/include/linux/if_vlan.h	2003-07-30 16:29:30.000000000 -0700
@@ -212,7 +212,9 @@
  	GET_VLAN_INGRESS_PRIORITY_CMD,
  	GET_VLAN_EGRESS_PRIORITY_CMD,
  	SET_VLAN_NAME_TYPE_CMD,
-	SET_VLAN_FLAG_CMD
+	SET_VLAN_FLAG_CMD,
+        GET_VLAN_REALDEV_NAME_CMD, /* If this works, you know it's a VLAN device, btw */
+        GET_VLAN_VID_CMD /* Get the VID of this VLAN (specified by name) */
  };

  enum vlan_name_types {




-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
