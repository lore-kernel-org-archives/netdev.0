From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH]  802.1Q VLAN
Date: Mon, 25 Oct 2004 13:51:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <417D675F.3000909@candelatech.com>
References: <41797696.9070905@candelatech.com>	<20041022214611.GA4948@electric-eye.fr.zoreil.com> <41798506.1030909@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000309000109080400000304"
Cc: "Linux 802.1Q VLAN" <vlan@candelatech.com>,
        Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
In-Reply-To: <41798506.1030909@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000309000109080400000304
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


Ok, I believe I have fixed all the suggestions offered by Francois (thanks!).

Please see what you think of this updated patch.  The changes have
been compile tested...and will pass some data in just a few minutes to
make sure nothing funny happens...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


--------------000309000109080400000304
Content-Type: text/plain;
 name="vlan.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vlan.patch"

--- linux-2.6.9/net/8021q/vlan_dev.c	2004-10-18 14:55:07.000000000 -0700
+++ linux-2.6.9.p4s/net/8021q/vlan_dev.c	2004-10-25 13:38:32.779294920 -0700
@@ -1,4 +1,4 @@
-/*
+/* -*- linux-c -*-
  * INET		802.1Q VLAN
  *		Ethernet-type device handling.
  *
@@ -484,13 +484,26 @@
 	       veth->h_vlan_proto, veth->h_vlan_TCI, veth->h_vlan_encapsulated_proto);
 #endif
 
-	stats->tx_packets++; /* for statics only */
-	stats->tx_bytes += skb->len;
-
 	skb->dev = VLAN_DEV_INFO(dev)->real_dev;
-	dev_queue_xmit(skb);
 
-	return 0;
+	{
+		/* Please note, dev_queue_xmit consumes the pkt regardless of the
+		 * error value.  So, will copy the skb first and free if successful.
+		 */
+		struct sk_buff* skb2 = skb_get(skb);
+		int rv = dev_queue_xmit(skb2);
+		if (rv == 0) {
+			/* Was success, need to free the skb reference since we bumped up the
+			 * user count above.
+			 */
+
+			stats->tx_packets++; /* for statics only */
+			stats->tx_bytes += skb->len;
+
+			kfree_skb(skb);
+		}
+		return rv;
+	}
 }
 
 int vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
@@ -622,7 +635,45 @@
 	return -EINVAL;
 }
 
+
+int vlan_dev_get_realdev_name(const char *dev_name, char* result)
+{
+	struct net_device *dev = dev_get_by_name(dev_name);
+	int rv = 0;
+	if (dev) {
+		if (dev->priv_flags & IFF_802_1Q_VLAN) {
+			strncpy(result, VLAN_DEV_INFO(dev)->real_dev->name, 23);
+			rv = 0;
+		} else {
+			rv = -EINVAL;
+		}
+		dev_put(dev);
+	} else {
+		rv = -ENODEV;
+	}
+	return rv;
+}
+
+int vlan_dev_get_vid(const char *dev_name, unsigned short* result)
+{
+	struct net_device *dev = dev_get_by_name(dev_name);
+	int rv = 0;
+	if (dev) {
+		if (dev->priv_flags & IFF_802_1Q_VLAN) {
+			*result = VLAN_DEV_INFO(dev)->vlan_id;
+			rv = 0;
+		} else {
+			rv = -EINVAL;
+		}
+		dev_put(dev);
+	} else {
+		rv = -ENODEV;
+	}
+	return rv;
+}
+
+
 int vlan_dev_set_mac_address(struct net_device *dev, void *addr_struct_p)
 {
 	struct sockaddr *addr = (struct sockaddr *)(addr_struct_p);
--- linux-2.6.9/net/8021q/vlan.c	2004-10-18 14:54:55.000000000 -0700
+++ linux-2.6.9.p4s/net/8021q/vlan.c	2004-10-22 12:14:24.000000000 -0700
@@ -1,4 +1,4 @@
-/*
+/* -*- linux-c -*-
  * INET		802.1Q VLAN
  *		Ethernet-type device handling.
  *
@@ -646,15 +646,9 @@
 static int vlan_ioctl_handler(void __user *arg)
 {
 	int err = 0;
+	unsigned short vid = 0;
 	struct vlan_ioctl_args args;
 
-	/* everything here needs root permissions, except aguably the
-	 * hack ioctls for sending packets.  However, I know _I_ don't
-	 * want users running that on my network! --BLG
-	 */
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 	if (copy_from_user(&args, arg, sizeof(struct vlan_ioctl_args)))
 		return -EFAULT;
 
@@ -668,24 +662,32 @@
 
 	switch (args.cmd) {
 	case SET_VLAN_INGRESS_PRIORITY_CMD:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
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
@@ -695,17 +697,9 @@
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
@@ -718,13 +712,52 @@
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
+		   err = vlan_dev_get_ingress_priority(args);
+		   if (copy_to_user((void*)arg, &args,
+		        sizeof(struct vlan_ioctl_args))) {
+		        err = -EFAULT;
+		   }
+		*/
+		err = -EINVAL;
+		break;
+	case GET_VLAN_EGRESS_PRIORITY_CMD:
+		/* TODO:  Implement
+		   err = vlan_dev_get_egress_priority(args.device1, &(args.args);
+		   if (copy_to_user((void*)arg, &args,
+		        sizeof(struct vlan_ioctl_args))) {
+		        err = -EFAULT;
+		   }
+		*/
+		err = -EINVAL;
+		break;
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
+                      err = -EFAULT;
+		}
+		break;
+
 	default:
 		/* pass on to underlying device instead?? */
 		printk(VLAN_DBG "%s: Unknown VLAN CMD: %x \n",
--- linux-2.6.9/net/8021q/vlan.h	2004-10-18 14:54:37.000000000 -0700
+++ linux-2.6.9.p4s/net/8021q/vlan.h	2004-10-22 12:14:24.000000000 -0700
@@ -66,7 +66,9 @@
 int vlan_dev_set_ingress_priority(char* dev_name, __u32 skb_prio, short vlan_prio);
 int vlan_dev_set_egress_priority(char* dev_name, __u32 skb_prio, short vlan_prio);
 int vlan_dev_set_vlan_flag(char* dev_name, __u32 flag, short flag_val);
+int vlan_dev_get_realdev_name(const char* dev_name, char* result);
+int vlan_dev_get_vid(const char* dev_name, unsigned short* result);
 void vlan_dev_set_multicast_list(struct net_device *vlan_dev);
 
 #endif /* !(__BEN_VLAN_802_1Q_INC__) */
--- linux-2.6.9/include/linux/if_vlan.h	2004-10-18 14:53:43.000000000 -0700
+++ linux-2.6.9.p4s/include/linux/if_vlan.h	2004-10-22 15:05:52.000000000 -0700
@@ -1,4 +1,4 @@
-/*
+/* -*- linux-c -*-
  * VLAN		An implementation of 802.1Q VLAN tagging.
  *
  * Authors:	Ben Greear <greearb@candelatech.com>
@@ -366,7 +366,9 @@
 	GET_VLAN_INGRESS_PRIORITY_CMD,
 	GET_VLAN_EGRESS_PRIORITY_CMD,
 	SET_VLAN_NAME_TYPE_CMD,
-	SET_VLAN_FLAG_CMD
+	SET_VLAN_FLAG_CMD,
+	GET_VLAN_REALDEV_NAME_CMD, /* If this works, you know it's a VLAN device, btw */
+	GET_VLAN_VID_CMD /* Get the VID of this VLAN (specified by name) */
 };
 
 enum vlan_name_types {

--------------000309000109080400000304--
