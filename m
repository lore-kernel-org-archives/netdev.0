From: Patrick McHardy <kaber@trash.net>
Subject: VLAN MTU propagation
Date: Wed, 08 Oct 2008 14:18:48 +0200
Message-ID: <48ECA528.7060301@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030204060005040908040406"
To: Stephen Hemminger <shemminger@vyatta.com>,
	Rick Jones <rick.jones2@hp.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48476 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754065AbYJHMSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 08:18:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030204060005040908040406
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

How about this patch (still compiling, so untested)?

Its based on Rick's suggestion of using an operational and a desired
MTU. The operational MTU is simply the net_device's MTU and is always
set to the minimum of the lower device's MTU and the desired MTU.
The desired MTU can be changed by configuring a MTU for the VLAN device
manually.

The remaining question is whether we should report the desired MTU to
userspace using the netlink interface, or maybe print a message when
the MTU is limited by the lower device.


--------------030204060005040908040406
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 488c56e..eac3641 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1226,6 +1226,7 @@ extern int		dev_change_flags(struct net_device *, unsigned);
 extern int		dev_change_name(struct net_device *, char *);
 extern int		dev_change_net_namespace(struct net_device *,
 						 struct net *, const char *);
+extern void		dev_notify_mtu(struct net_device *);
 extern int		dev_set_mtu(struct net_device *, int);
 extern int		dev_set_mac_address(struct net_device *,
 					    struct sockaddr *);
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index b661f47..c542807 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -347,6 +347,7 @@ static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
 	new_dev->mtu = real_dev->mtu;
 
 	vlan_dev_info(new_dev)->vlan_id = vlan_id;
+	vlan_dev_info(new_dev)->mtu = new_dev->mtu;
 	vlan_dev_info(new_dev)->real_dev = real_dev;
 	vlan_dev_info(new_dev)->dent = NULL;
 	vlan_dev_info(new_dev)->flags = VLAN_FLAG_REORDER_HDR;
@@ -477,6 +478,18 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 
 		break;
 
+	case NETDEV_CHANGEMTU:
+		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
+			vlandev = vlan_group_get_device(grp, i);
+			if (!vlandev)
+				continue;
+
+			vlandev->mtu = min(vlan_dev_info(vlandev)->mtu,
+					   dev->mtu);
+			dev_notify_mtu(vlandev);
+		}
+		break;
+
 	case NETDEV_DOWN:
 		/* Put all VLANs for this dev in the down state too.  */
 		for (i = 0; i < VLAN_GROUP_ARRAY_LEN; i++) {
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index a6603a4..84f2c11 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -24,6 +24,7 @@ struct vlan_priority_tci_mapping {
  *	@egress_priority_map: hash of egress priority mappings
  *	@vlan_id: VLAN identifier
  *	@flags: device flags
+ *	@mtu: desired MTU - effective MTU is limited by MTU of real device
  *	@real_dev: underlying netdevice
  *	@real_dev_addr: address of underlying netdevice
  *	@dent: proc dir entry
@@ -38,6 +39,7 @@ struct vlan_dev_info {
 
 	u16					vlan_id;
 	u16					flags;
+	unsigned int				mtu;
 
 	struct net_device			*real_dev;
 	unsigned char				real_dev_addr[ETH_ALEN];
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 4bf014e..18d85c4 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -347,14 +347,13 @@ static int vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb,
 
 static int vlan_dev_change_mtu(struct net_device *dev, int new_mtu)
 {
+	struct vlan_dev_info *vlan = vlan_dev_info(dev);
+
 	/* TODO: gotta make sure the underlying layer can handle it,
 	 * maybe an IFF_VLAN_CAPABLE flag for devices?
 	 */
-	if (vlan_dev_info(dev)->real_dev->mtu < new_mtu)
-		return -ERANGE;
-
-	dev->mtu = new_mtu;
-
+	vlan->mtu = new_mtu;
+	dev->mtu  = min_t(unsigned int, vlan->real_dev->mtu, new_mtu);
 	return 0;
 }
 
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index e9c91dc..d9f9b17 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -125,9 +125,9 @@ static int vlan_newlink(struct net_device *dev,
 		return err;
 
 	if (!tb[IFLA_MTU])
-		dev->mtu = real_dev->mtu;
-	else if (dev->mtu > real_dev->mtu)
-		return -EINVAL;
+		dev->mtu = vlan->mtu = real_dev->mtu;
+	else
+		vlan->mtu = nla_get_u32(tb[IFLA_MTU]);
 
 	err = vlan_changelink(dev, tb, data);
 	if (err < 0)
diff --git a/net/core/dev.c b/net/core/dev.c
index fd992c0..2a2094a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3399,6 +3399,13 @@ int dev_change_flags(struct net_device *dev, unsigned flags)
 	return ret;
 }
 
+void dev_notify_mtu(struct net_device *dev)
+{
+	if (dev->flags & IFF_UP)
+		call_netdevice_notifiers(NETDEV_CHANGEMTU, dev);
+}
+EXPORT_SYMBOL_GPL(dev_notify_mtu);
+
 int dev_set_mtu(struct net_device *dev, int new_mtu)
 {
 	int err;
@@ -3418,8 +3425,8 @@ int dev_set_mtu(struct net_device *dev, int new_mtu)
 		err = dev->change_mtu(dev, new_mtu);
 	else
 		dev->mtu = new_mtu;
-	if (!err && dev->flags & IFF_UP)
-		call_netdevice_notifiers(NETDEV_CHANGEMTU, dev);
+	if (!err)
+		dev_notify_mtu(dev);
 	return err;
 }
 

--------------030204060005040908040406--
