From: Mitch Williams <mitch.a.williams@intel.com>
Subject: [RFC] Enable/Disable VLAN HW filters
Date: Thu, 31 Aug 2006 15:51:07 -0700
Message-ID: <1157064667.4416.14.camel@strongmad>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:37781 "EHLO
	fmsmga101-1.fm.intel.com") by vger.kernel.org with ESMTP
	id S932474AbWHaWvI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 18:51:08 -0400
Received: from strongmad.jf.intel.com (strongmad.jf.intel.com [10.23.35.36])
	by nwlxmail01.jf.intel.com (8.12.11.20060308/8.12.9/MailSET/Hub) with ESMTP id k7VMp7n7026481
	for <netdev@vger.kernel.org>; Thu, 31 Aug 2006 15:51:07 -0700
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We've had a few internal requests for a way to enable and disable the
hardware VLAN filter at runtime.  I'm posting it here for discussion and
to see if anybody else is interested in this feature.

Originally I had planned to do this as an Ethtool ioctl, but decided
instead to handle it through the VLAN module.  Ethtool doesn't know
anything about VLANs at all.

There are no userspace changes required to support this functionality.

To disable HW VLAN filtering:
# vconfig set_flag <VLAN interface> 2 1

To enable HW VLAN filtering:
# vconfig set_flag <VLAN interface> 2 0

At this point (somewhat obviously), it's only implemented on e1000, but
this ioctl could be easily implemented by other drivers.

Originally based on 2.6.17 but applies OK to 2.6.18-rc4 with a little
fuzz.

diff -urpN -X linux-2.6.17/Documentation/dontdiff linux-2.6.17-clean/include/linux/if_vlan.h linux-2.6.17/include/linux/if_vlan.h
--- linux-2.6.17-clean/include/linux/if_vlan.h	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.17/include/linux/if_vlan.h	2006-07-13 15:37:41.000000000 -0700
@@ -87,7 +87,20 @@ struct vlan_priority_tci_mapping {
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
@@ -97,14 +110,7 @@ struct vlan_dev_info {
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
diff -urpN -X linux-2.6.17/Documentation/dontdiff linux-2.6.17-clean/include/linux/netdevice.h linux-2.6.17/include/linux/netdevice.h
--- linux-2.6.17-clean/include/linux/netdevice.h	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.17/include/linux/netdevice.h	2006-07-17 16:53:26.000000000 -0700
@@ -484,7 +484,9 @@ struct net_device
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
diff -urpN -X linux-2.6.17/Documentation/dontdiff linux-2.6.17-clean/net/8021q/vlan_dev.c linux-2.6.17/net/8021q/vlan_dev.c
--- linux-2.6.17-clean/net/8021q/vlan_dev.c	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.17/net/8021q/vlan_dev.c	2006-07-19 10:53:36.000000000 -0700
@@ -590,37 +590,58 @@ int vlan_dev_set_egress_priority(char *d
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
diff -urpN -X linux-2.6.17/Documentation/dontdiff linux-2.6.17-clean/drivers/net/e1000/e1000_main.c linux-2.6.17/drivers/net/e1000/e1000_main.c
--- linux-2.6.17-clean/drivers/net/e1000/e1000_main.c	2006-06-17 18:49:35.000000000 -0700
+++ linux-2.6.17/drivers/net/e1000/e1000_main.c	2006-07-25 16:27:08.000000000 -0700
@@ -215,6 +215,9 @@ static void e1000_vlan_rx_register(struc
 static void e1000_vlan_rx_add_vid(struct net_device *netdev, uint16_t vid);
 static void e1000_vlan_rx_kill_vid(struct net_device *netdev, uint16_t vid);
 static void e1000_restore_vlan(struct e1000_adapter *adapter);
+#ifdef HAVE_VLAN_FLAGS
+static int e1000_vlan_set_flag(struct net_device *netdev, unsigned int flag, int value);
+#endif
 
 #ifdef CONFIG_PM
 static int e1000_suspend(struct pci_dev *pdev, pm_message_t state);
@@ -691,6 +694,10 @@ e1000_probe(struct pci_dev *pdev,
 	netdev->vlan_rx_register = e1000_vlan_rx_register;
 	netdev->vlan_rx_add_vid = e1000_vlan_rx_add_vid;
 	netdev->vlan_rx_kill_vid = e1000_vlan_rx_kill_vid;
+#ifdef HAVE_VLAN_FLAGS
+	netdev->vlan_set_flag = e1000_vlan_set_flag;
+#endif
+
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	netdev->poll_controller = e1000_netpoll;
 #endif
@@ -4303,7 +4310,43 @@ e1000_vlan_rx_register(struct net_device
 
 	e1000_irq_enable(adapter);
 }
+#ifdef HAVE_VLAN_FLAGS
+static int
+e1000_vlan_set_flag(struct net_device *netdev, unsigned int flag, int value)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	uint32_t rctl;
 
+	/* The only flag we currently care about is bit 1,
+	   which controls HW filtering. */
+	e1000_irq_disable(adapter);
+#ifdef NAHUM
+	if (adapter->hw.mac_type == e1000_ich8lan)
+		return -EPERM;
+#endif
+	if (flag == VLAN_FLAG_DISABLE_FILTER) {
+		if (value) {
+			/* disable VLAN filtering */
+			rctl = E1000_READ_REG(&adapter->hw, RCTL);
+			rctl &= ~E1000_RCTL_VFE;
+			E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
+			netdev->features &= ~NETIF_F_HW_VLAN_FILTER;
+		} else {
+			/* enable VLAN receive filtering */
+			rctl = E1000_READ_REG(&adapter->hw, RCTL);
+			rctl |= E1000_RCTL_VFE;
+			rctl &= ~E1000_RCTL_CFIEN;
+			E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
+			netdev->features |= NETIF_F_HW_VLAN_FILTER;
+			e1000_restore_vlan(adapter);
+			e1000_update_mng_vlan(adapter);
+		}
+	}
+
+	e1000_irq_enable(adapter);
+	return 0;
+}
+#endif
 static void
 e1000_vlan_rx_add_vid(struct net_device *netdev, uint16_t vid)
 {
