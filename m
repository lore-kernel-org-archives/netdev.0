From: Ben Greear <greearb@candelatech.com>
Subject: [PATCH]  802.1q vlan updates
Date: Wed, 05 Nov 2003 20:24:43 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FA9CD0B.8000707@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080500030205060300080101"
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080500030205060300080101
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Here is a patch that is a cleaned up version of something I sent
a while back.  This adds the ability to query a device to see if
it is a vlan device by asking for the vlan's parent device.
One can deduce that a querried interface is not a VLAN by looking
at the IOCTL error code.

Patch is against 2.4.22-pre9, compile tested and extracted from a run-time
tested patch.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


--------------080500030205060300080101
Content-Type: text/plain;
 name="vlan_2.4.22.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vlan_2.4.22.patch"

--- linux-2.4.22/net/8021q/vlan_dev.c	2003-11-05 19:54:38.000000000 -0800
+++ linux-2.4.22.vlan/net/8021q/vlan_dev.c	2003-11-05 19:41:20.000000000 -0800
@@ -1,4 +1,4 @@
-/*
+/* -*- linux-c -*-
  * INET		802.1Q VLAN
  *		Ethernet-type device handling.
  *
@@ -636,6 +636,60 @@
 	return -EINVAL;
 }
 
+
+int vlan_dev_get_realdev_name(const char *dev_name, char* result)
+{
+	struct net_device *dev = dev_get_by_name(dev_name);
+	int rv = 0;
+	
+	if (dev) {
+		if (dev->priv_flags & IFF_802_1Q_VLAN) {
+			strncpy(result, VLAN_DEV_INFO(dev)->real_dev->name, 23);
+			dev_put(dev);
+			rv = 0;
+		} else {
+			/*printk(KERN_ERR 
+			       "%s: %s is not a vlan device, priv_flags: %hX.\n",
+			       __FUNCTION__, dev->name, dev->priv_flags);*/
+			dev_put(dev);
+			rv = -EINVAL;
+		}
+	} else {
+		/* printk(KERN_ERR	 "%s: Could not find device: %s\n", 
+		   __FUNCTION__, dev_name); */
+		rv = -ENODEV;
+	}
+
+	return rv;
+}
+
+int vlan_dev_get_vid(const char *dev_name, unsigned short* result)
+{
+	struct net_device *dev = dev_get_by_name(dev_name);
+	int rv = 0;
+	
+	if (dev) {
+		if (dev->priv_flags & IFF_802_1Q_VLAN) {
+			*result = VLAN_DEV_INFO(dev)->vlan_id;
+			dev_put(dev);
+			rv = 0;
+		} else {
+			/*printk(KERN_ERR 
+			       "%s: %s is not a vlan device, priv_flags: %hX.\n",
+			       __FUNCTION__, dev->name, dev->priv_flags);*/
+			dev_put(dev);
+			rv = -EINVAL;
+		}
+	} else {
+		/* printk(KERN_ERR	 "%s: Could not find device: %s\n", 
+		   __FUNCTION__, dev_name);*/
+		rv = -ENODEV;
+	}
+
+	return rv;
+}
+
+
 int vlan_dev_set_mac_address(struct net_device *dev, void *addr_struct_p)
 {
 	struct sockaddr *addr = (struct sockaddr *)(addr_struct_p);
--- linux-2.4.22/net/8021q/vlan.c	2003-11-05 19:54:38.000000000 -0800
+++ linux-2.4.22.vlan/net/8021q/vlan.c	2003-11-05 19:46:04.000000000 -0800
@@ -1,4 +1,4 @@
-/*
+/* -*- linux-c -*-
  * INET		802.1Q VLAN
  *		Ethernet-type device handling.
  *
@@ -657,15 +657,9 @@
 int vlan_ioctl_handler(unsigned long arg)
 {
 	int err = 0;
+        unsigned short vid = 0;
 	struct vlan_ioctl_args args;
 
-	/* everything here needs root permissions, except aguably the
-	 * hack ioctls for sending packets.  However, I know _I_ don't
-	 * want users running that on my network! --BLG
-	 */
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 	if (copy_from_user(&args, (void*)arg,
                            sizeof(struct vlan_ioctl_args)))
 		return -EFAULT;
@@ -680,24 +674,33 @@
 
 	switch (args.cmd) {
 	case SET_VLAN_INGRESS_PRIORITY_CMD:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+
 		err = vlan_dev_set_ingress_priority(args.device1,
 						    args.u.skb_priority,
 						    args.vlan_qos);
 		break;
 
 	case SET_VLAN_EGRESS_PRIORITY_CMD:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
 		err = vlan_dev_set_egress_priority(args.device1,
 						   args.u.skb_priority,
 						   args.vlan_qos);
 		break;
 
 	case SET_VLAN_FLAG_CMD:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
 		err = vlan_dev_set_vlan_flag(args.device1,
 					     args.u.flag,
 					     args.vlan_qos);
 		break;
 
 	case SET_VLAN_NAME_TYPE_CMD:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
 		if ((args.u.name_type >= 0) &&
 		    (args.u.name_type < VLAN_NAME_TYPE_HIGHEST)) {
 			vlan_name_type = args.u.name_type;
@@ -707,17 +710,9 @@
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
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
 		/* we have been given the name of the Ethernet Device we want to
 		 * talk to:  args.dev1	 We also have the
 		 * VLAN ID:  args.u.VID
@@ -730,12 +725,53 @@
 		break;
 
 	case DEL_VLAN_CMD:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
 		/* Here, the args.dev1 is the actual VLAN we want
 		 * to get rid of.
 		 */
 		err = unregister_vlan_device(args.device1);
 		break;
 
+	case GET_VLAN_INGRESS_PRIORITY_CMD:
+		/* TODO:  Implement
+		err = vlan_dev_get_ingress_priority(args);
+		if (copy_to_user((void*)arg, &args,
+				 sizeof(struct vlan_ioctl_args))) {
+			err = -EFAULT;
+		}
+		*/
+		err = -EINVAL;
+		break;
+
+	case GET_VLAN_EGRESS_PRIORITY_CMD:
+		/* TODO:  Implement
+		err = vlan_dev_get_egress_priority(args.device1, &(args.args);
+		if (copy_to_user((void*)arg, &args,
+				 sizeof(struct vlan_ioctl_args))) {
+			err = -EFAULT;
+		}
+		*/
+		err = -EINVAL;
+		break;
+
+	case GET_VLAN_REALDEV_NAME_CMD:
+		err = vlan_dev_get_realdev_name(args.device1, args.u.device2);
+		if (copy_to_user((void*)arg, &args,
+				 sizeof(struct vlan_ioctl_args))) {
+			err = -EFAULT;
+		}
+		break;
+
+	case GET_VLAN_VID_CMD:
+		err = vlan_dev_get_vid(args.device1, &vid);
+		args.u.VID = vid;
+		if (copy_to_user((void*)arg, &args,
+				 sizeof(struct vlan_ioctl_args))) {
+			err = -EFAULT;
+		}
+		break;
+		
 	default:
 		/* pass on to underlying device instead?? */
 		printk(VLAN_DBG "%s: Unknown VLAN CMD: %x \n",
--- linux-2.4.22/include/linux/if_vlan.h	2003-08-25 04:44:44.000000000 -0700
+++ linux-2.4.22.vlan/include/linux/if_vlan.h	2003-11-05 19:47:37.000000000 -0800
@@ -213,7 +213,9 @@
 	GET_VLAN_INGRESS_PRIORITY_CMD,
 	GET_VLAN_EGRESS_PRIORITY_CMD,
 	SET_VLAN_NAME_TYPE_CMD,
-	SET_VLAN_FLAG_CMD
+	SET_VLAN_FLAG_CMD,
+        GET_VLAN_REALDEV_NAME_CMD, /* If this works, you know it's a VLAN device, btw */
+        GET_VLAN_VID_CMD /* Get the VID of this VLAN (specified by name) */
 };
 
 enum vlan_name_types {

--------------080500030205060300080101--
