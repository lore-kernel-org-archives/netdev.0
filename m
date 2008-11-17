From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 11/33] vlan: convert to net_device_ops
Date: Mon, 17 Nov 2008 15:42:18 -0800
Message-ID: <20081117234355.711999848@vyatta.com>
References: <20081117234207.854110282@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:55063 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752150AbYKRAAH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 19:00:07 -0500
Content-Disposition: inline; filename=vlan-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert vlan devices and function pointers to net_device_ops.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/8021q/vlan.c	2008-11-17 11:45:49.000000000 -0800
+++ b/net/8021q/vlan.c	2008-11-17 11:46:37.000000000 -0800
@@ -144,6 +144,7 @@ void unregister_vlan_dev(struct net_devi
 {
 	struct vlan_dev_info *vlan = vlan_dev_info(dev);
 	struct net_device *real_dev = vlan->real_dev;
+	const struct net_device_ops *ops = real_dev->netdev_ops;
 	struct vlan_group *grp;
 	u16 vlan_id = vlan->vlan_id;
 
@@ -156,7 +157,7 @@ void unregister_vlan_dev(struct net_devi
 	 * HW accelerating devices or SW vlan input packet processing.
 	 */
 	if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
-		real_dev->vlan_rx_kill_vid(real_dev, vlan_id);
+		ops->vlan_rx_kill_vid(real_dev, vlan_id);
 
 	vlan_group_set_device(grp, vlan_id, NULL);
 	grp->nr_vlans--;
@@ -170,7 +171,7 @@ void unregister_vlan_dev(struct net_devi
 		vlan_gvrp_uninit_applicant(real_dev);
 
 		if (real_dev->features & NETIF_F_HW_VLAN_RX)
-			real_dev->vlan_rx_register(real_dev, NULL);
+			ops->vlan_rx_register(real_dev, NULL);
 
 		hlist_del_rcu(&grp->hlist);
 
@@ -205,21 +206,21 @@ static void vlan_transfer_operstate(cons
 
 int vlan_check_real_dev(struct net_device *real_dev, u16 vlan_id)
 {
-	char *name = real_dev->name;
+	const char *name = real_dev->name;
+	const struct net_device_ops *ops = real_dev->netdev_ops;
 
 	if (real_dev->features & NETIF_F_VLAN_CHALLENGED) {
 		pr_info("8021q: VLANs not supported on %s\n", name);
 		return -EOPNOTSUPP;
 	}
 
-	if ((real_dev->features & NETIF_F_HW_VLAN_RX) &&
-	    !real_dev->vlan_rx_register) {
+	if ((real_dev->features & NETIF_F_HW_VLAN_RX) && !ops->vlan_rx_register) {
 		pr_info("8021q: device %s has buggy VLAN hw accel\n", name);
 		return -EOPNOTSUPP;
 	}
 
 	if ((real_dev->features & NETIF_F_HW_VLAN_FILTER) &&
-	    (!real_dev->vlan_rx_add_vid || !real_dev->vlan_rx_kill_vid)) {
+	    (!ops->vlan_rx_add_vid || !ops->vlan_rx_kill_vid)) {
 		pr_info("8021q: Device %s has buggy VLAN hw accel\n", name);
 		return -EOPNOTSUPP;
 	}
@@ -240,6 +241,7 @@ int register_vlan_dev(struct net_device 
 {
 	struct vlan_dev_info *vlan = vlan_dev_info(dev);
 	struct net_device *real_dev = vlan->real_dev;
+	const struct net_device_ops *ops = real_dev->netdev_ops;
 	u16 vlan_id = vlan->vlan_id;
 	struct vlan_group *grp, *ngrp = NULL;
 	int err;
@@ -275,9 +277,9 @@ int register_vlan_dev(struct net_device 
 	grp->nr_vlans++;
 
 	if (ngrp && real_dev->features & NETIF_F_HW_VLAN_RX)
-		real_dev->vlan_rx_register(real_dev, ngrp);
+		ops->vlan_rx_register(real_dev, ngrp);
 	if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
-		real_dev->vlan_rx_add_vid(real_dev, vlan_id);
+		ops->vlan_rx_add_vid(real_dev, vlan_id);
 
 	return 0;
 
--- a/net/8021q/vlan_dev.c	2008-11-17 11:45:49.000000000 -0800
+++ b/net/8021q/vlan_dev.c	2008-11-17 11:46:37.000000000 -0800
@@ -524,6 +524,7 @@ out:
 static int vlan_dev_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct net_device *real_dev = vlan_dev_info(dev)->real_dev;
+	const struct net_device_ops *ops = real_dev->netdev_ops;
 	struct ifreq ifrr;
 	int err = -EOPNOTSUPP;
 
@@ -534,8 +535,8 @@ static int vlan_dev_ioctl(struct net_dev
 	case SIOCGMIIPHY:
 	case SIOCGMIIREG:
 	case SIOCSMIIREG:
-		if (real_dev->do_ioctl && netif_device_present(real_dev))
-			err = real_dev->do_ioctl(real_dev, &ifrr, cmd);
+		if (netif_device_present(real_dev) && ops->do_ioctl)
+			err = ops->do_ioctl(real_dev, &ifrr, cmd);
 		break;
 	}
 
@@ -697,6 +698,20 @@ static const struct ethtool_ops vlan_eth
 	.get_flags		= vlan_ethtool_get_flags,
 };
 
+static const struct net_device_ops vlan_netdev_ops = {
+	.change_mtu		= vlan_dev_change_mtu,
+	.init			= vlan_dev_init,
+	.uninit			= vlan_dev_uninit,
+	.open			= vlan_dev_open,
+	.stop			= vlan_dev_stop,
+	.validate_addr		= eth_validate_addr,
+	.set_mac_address	= vlan_dev_set_mac_address,
+	.set_rx_mode		= vlan_dev_set_rx_mode,
+	.set_multicast_list	= vlan_dev_set_rx_mode,
+	.change_rx_flags	= vlan_dev_change_rx_flags,
+	.do_ioctl		= vlan_dev_ioctl,
+};
+
 void vlan_setup(struct net_device *dev)
 {
 	ether_setup(dev);
@@ -704,16 +719,7 @@ void vlan_setup(struct net_device *dev)
 	dev->priv_flags		|= IFF_802_1Q_VLAN;
 	dev->tx_queue_len	= 0;
 
-	dev->change_mtu		= vlan_dev_change_mtu;
-	dev->init		= vlan_dev_init;
-	dev->uninit		= vlan_dev_uninit;
-	dev->open		= vlan_dev_open;
-	dev->stop		= vlan_dev_stop;
-	dev->set_mac_address	= vlan_dev_set_mac_address;
-	dev->set_rx_mode	= vlan_dev_set_rx_mode;
-	dev->set_multicast_list	= vlan_dev_set_rx_mode;
-	dev->change_rx_flags	= vlan_dev_change_rx_flags;
-	dev->do_ioctl		= vlan_dev_ioctl;
+	dev->netdev_ops		= &vlan_netdev_ops;
 	dev->destructor		= free_netdev;
 	dev->ethtool_ops	= &vlan_ethtool_ops;
 

-- 

