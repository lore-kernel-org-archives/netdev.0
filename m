From: Mitch Williams <mitch.a.williams@intel.com>
Subject: [PATCH 1/2] HW VLAN filtering control (resend)
Date: Fri, 27 Jul 2007 14:30:25 -0700
Message-ID: <1185571825.28574.25.camel@strongmad>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:12376 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764875AbXG0VaZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jul 2007 17:30:25 -0400
Received: from strongmad.jf.intel.com (strongmad.jf.intel.com [10.23.35.99])
	by nwlxmail01.jf.intel.com (8.12.11.20060308/8.12.9/MailSET/Hub) with ESMTP id l6RLUPdL011342
	for <netdev@vger.kernel.org>; Fri, 27 Jul 2007 14:30:25 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support to the VLAN subsystem for enabling/disabling hardware VLAN
filtering at runtime.  This is useful for debugging purposes.

The existing vconfig utility can be used without modification.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>


diff -urpN -X dontdiff linux-2.6.22.1-clean/include/linux/if_vlan.h linux-2.6.22.1/include/linux/if_vlan.h
--- linux-2.6.22.1-clean/include/linux/if_vlan.h	2007-07-10 11:56:30.000000000 -0700
+++ linux-2.6.22.1/include/linux/if_vlan.h	2007-07-26 16:29:00.000000000 -0700
@@ -106,7 +106,20 @@ struct vlan_priority_tci_mapping {
 				  */
 	struct vlan_priority_tci_mapping *next;
 };
-
+#define VLAN_FLAG_REORDER 1		/* (1 << 0) re_order_header   This option will cause the
+					 *   VLAN code to move around the ethernet header on
+					 *   ingress to make the skb look **exactly** like it
+					 *   came in from an ethernet port.  This destroys some of
+					 *   the VLAN information in the skb, but it fixes programs
+					 *   like DHCP that use packet-filtering and don't understand
+					 *   802.1Q
+					 */
+
+#define VLAN_FLAG_DISABLE_FILTER 2	/* (1 << 1) disable HW filtering.  This flag allows
+					 * devices that perform hardware filtering to
+					 * turn off filtering.  This may be useful for
+					 * debugging or for sniffer applications.
+					 */
 /* Holds information that makes sense if this device is a VLAN device. */
 struct vlan_dev_info {
 	/** This will be the mapping that correlates skb->priority to
@@ -116,14 +129,7 @@ struct vlan_dev_info {
 	struct vlan_priority_tci_mapping *egress_priority_map[16]; /* hash table */
 
 	unsigned short vlan_id;        /*  The VLAN Identifier for this interface. */
-	unsigned short flags;          /* (1 << 0) re_order_header   This option will cause the
-                                        *   VLAN code to move around the ethernet header on
-                                        *   ingress to make the skb look **exactly** like it
-                                        *   came in from an ethernet port.  This destroys some of
-                                        *   the VLAN information in the skb, but it fixes programs
-                                        *   like DHCP that use packet-filtering and don't understand
-                                        *   802.1Q
-                                        */
+	unsigned short flags;
 	struct dev_mc_list *old_mc_list;  /* old multi-cast list for the VLAN interface..
                                            * we save this so we can tell what changes were
                                            * made, in order to feed the right changes down
diff -urpN -X dontdiff linux-2.6.22.1-clean/include/linux/netdevice.h linux-2.6.22.1/include/linux/netdevice.h
--- linux-2.6.22.1-clean/include/linux/netdevice.h	2007-07-10 11:56:30.000000000 -0700
+++ linux-2.6.22.1/include/linux/netdevice.h	2007-07-26 16:29:00.000000000 -0700
@@ -522,7 +522,9 @@ struct net_device
 						   unsigned short vid);
 	void			(*vlan_rx_kill_vid)(struct net_device *dev,
 						    unsigned short vid);
-
+#define HAVE_VLAN_FLAGS
+	int			(*vlan_set_flag)(struct net_device *dev,
+						  unsigned int flag, int value);
 	int			(*hard_header_parse)(struct sk_buff *skb,
 						     unsigned char *haddr);
 	int			(*neigh_setup)(struct net_device *dev, struct neigh_parms *);
diff -urpN -X dontdiff linux-2.6.22.1-clean/net/8021q/vlan_dev.c linux-2.6.22.1/net/8021q/vlan_dev.c
--- linux-2.6.22.1-clean/net/8021q/vlan_dev.c	2007-07-10 11:56:30.000000000 -0700
+++ linux-2.6.22.1/net/8021q/vlan_dev.c	2007-07-27 11:40:22.000000000 -0700
@@ -593,37 +593,58 @@ int vlan_dev_set_egress_priority(char *d
 /* Flags are defined in the vlan_dev_info class in include/linux/if_vlan.h file. */
 int vlan_dev_set_vlan_flag(char *dev_name, __u32 flag, short flag_val)
 {
+	struct net_device *real_dev;
 	struct net_device *dev = dev_get_by_name(dev_name);
+	int ret = 0;
 
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
-		} else {
-			printk(KERN_ERR
-			       "%s: %s is not a vlan device, priv_flags: %hX.\n",
-			       __FUNCTION__, dev->name, dev->priv_flags);
-			dev_put(dev);
-		}
-	} else {
+	if (!dev) {
 		printk(KERN_ERR  "%s: Could not find device: %s\n",
 			__FUNCTION__, dev_name);
+		ret = -EINVAL;
+		goto out_no_dev;
+	}
+	
+	if (!(dev->priv_flags & IFF_802_1Q_VLAN)) {
+		printk(KERN_ERR 
+			"%s: %s is not a vlan device, priv_flags: %hX.\n",
+			__FUNCTION__, dev->name, dev->priv_flags);
+		dev_put(dev);
+		ret = -EINVAL;
+		goto out;
+	}
+
+	real_dev = VLAN_DEV_INFO(dev)->real_dev;
+	switch (flag) {
+	case VLAN_FLAG_REORDER:
+		if (flag_val)
+			VLAN_DEV_INFO(dev)->flags |= 1;
+		else
+			VLAN_DEV_INFO(dev)->flags &= ~1;
+		break;
+
+	case VLAN_FLAG_DISABLE_FILTER:
+		if (real_dev->vlan_set_flag)
+			ret = real_dev->vlan_set_flag(real_dev, 
+							flag, flag_val);
+		else {
+			printk(KERN_ERR
+				"%s: VLAN flags not supported on base device %s.\n",
+				__FUNCTION__, real_dev->name);
+			ret = -EINVAL;
+		}
+		break;
+
+	default:
+		printk(KERN_ERR "%s: VLAN flag %d is invalid.\n",
+			__FUNCTION__, flag);
+		ret = -EINVAL;
+		break;
 	}
 
-	return -EINVAL;
+out:
+	dev_put(dev);
+out_no_dev:
+	return ret;
 }
 
 
