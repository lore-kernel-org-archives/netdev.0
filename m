From: Mike Sinkovsky <msink@permonline.ru>
Subject: [PATCH RFC] net: hardware limited MTU for 802.1Q frames
Date: Fri, 23 Mar 2012 15:51:26 +0500
Message-ID: <1332499886-1126-1-git-send-email-msink@permonline.ru>
Cc: msink@permonline.ru
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.ccl.ru ([195.222.140.73]:62992 "EHLO mail4.ccl.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753014Ab2CWKv6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2012 06:51:58 -0400
Received: from iserv ([188.19.146.24])
	(authenticated bits=0)
	by mail4.ccl.ru (8.14.4/8.14.4) with ESMTP id q2NApta4034663
	for <netdev@vger.kernel.org>; Fri, 23 Mar 2012 16:51:55 +0600 (YEKT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some chips (WIZnet as example) have hardware limited MTU -
plain ethernet frame works with MTU 1500, but for 802.1Q
frames MTU must be limited to 1496.

This patch add callback in net_device_ops, called from 8021q
code to check for this hardware limitation.

If callback is not set in driver - vlan works as before,
in hope that underlaying device always can handle
additional 4 byte in frame length.
---
 include/linux/netdevice.h |   20 ++++++++++++++++++++
 net/8021q/vlan.c          |   13 ++++++-------
 net/8021q/vlan_dev.c      |    8 ++++----
 net/8021q/vlan_netlink.c  |    4 ++--
 4 files changed, 32 insertions(+), 13 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8debe29..3cbf2a4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -790,6 +790,13 @@ struct netdev_fcoe_hbainfo {
  *	of a device. If not defined, any request to change MTU will
  *	will return an error.
  *
+ * int (*ndo_get_hard_mtu)(struct net_device *dev)
+ *	If defined, returns hardware limit for MTU.
+ *	Called when a slave device needs to set MTU, to make sure that
+ *	this limit is not exceed.
+ *	If not defined, dev->mtu is used in hope the underlying device can
+ *	handle it.
+ *
  * void (*ndo_tx_timeout)(struct net_device *dev);
  *	Callback uses when the transmitter has not made any progress
  *	for dev->watchdog ticks.
@@ -926,6 +933,7 @@ struct net_device_ops {
 					          struct ifmap *map);
 	int			(*ndo_change_mtu)(struct net_device *dev,
 						  int new_mtu);
+	int			(*ndo_get_hard_mtu)(struct net_device *dev);
 	int			(*ndo_neigh_setup)(struct net_device *dev,
 						   struct neigh_parms *);
 	void			(*ndo_tx_timeout) (struct net_device *dev);
@@ -2677,6 +2685,18 @@ static inline bool netif_supports_nofcs(struct net_device *dev)
 	return dev->priv_flags & IFF_SUPP_NOFCS;
 }
 
+static inline int netdev_get_mtu(struct net_device *dev, int hlen)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+	int mtu = dev->mtu;
+	if (ops->ndo_get_hard_mtu) {
+		int hard_mtu = ops->ndo_get_hard_mtu(dev);
+		if (mtu + hlen > hard_mtu)
+			mtu = hard_mtu - hlen;
+	}
+	return mtu;
+}
+
 extern struct pernet_operations __net_initdata loopback_net_ops;
 
 /* Logging, debugging and troubleshooting/diagnostic helpers. */
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index efea35b..ecf3089 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -238,10 +238,8 @@ static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
 		return -ENOBUFS;
 
 	dev_net_set(new_dev, net);
-	/* need 4 bytes for extra VLAN header info,
-	 * hope the underlying device can handle it.
-	 */
-	new_dev->mtu = real_dev->mtu;
+
+	new_dev->mtu = netdev_get_mtu(real_dev, VLAN_HLEN);
 
 	vlan_dev_priv(new_dev)->vlan_id = vlan_id;
 	vlan_dev_priv(new_dev)->real_dev = real_dev;
@@ -326,7 +324,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 	struct net_device *dev = ptr;
 	struct vlan_group *grp;
 	struct vlan_info *vlan_info;
-	int i, flgs;
+	int i, flgs, mtu;
 	struct net_device *vlandev;
 	struct vlan_dev_priv *vlan;
 	LIST_HEAD(list);
@@ -378,15 +376,16 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 		break;
 
 	case NETDEV_CHANGEMTU:
+		mtu = netdev_get_mtu(dev, VLAN_HLEN);
 		for (i = 0; i < VLAN_N_VID; i++) {
 			vlandev = vlan_group_get_device(grp, i);
 			if (!vlandev)
 				continue;
 
-			if (vlandev->mtu <= dev->mtu)
+			if (vlandev->mtu <= mtu)
 				continue;
 
-			dev_set_mtu(vlandev, dev->mtu);
+			dev_set_mtu(vlandev, mtu);
 		}
 		break;
 
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 9988d4a..bd52428 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -180,10 +180,10 @@ static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
 
 static int vlan_dev_change_mtu(struct net_device *dev, int new_mtu)
 {
-	/* TODO: gotta make sure the underlying layer can handle it,
-	 * maybe an IFF_VLAN_CAPABLE flag for devices?
-	 */
-	if (vlan_dev_priv(dev)->real_dev->mtu < new_mtu)
+	struct net_device *real_dev = vlan_dev_priv(dev)->real_dev;
+
+	/* make sure the underlying layer can handle it */
+	if (new_mtu > netdev_get_mtu(real_dev, VLAN_HLEN))
 		return -ERANGE;
 
 	dev->mtu = new_mtu;
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index 5071136..c83420c 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -127,8 +127,8 @@ static int vlan_newlink(struct net *src_net, struct net_device *dev,
 		return err;
 
 	if (!tb[IFLA_MTU])
-		dev->mtu = real_dev->mtu;
-	else if (dev->mtu > real_dev->mtu)
+		dev->mtu = netdev_get_mtu(real_dev, VLAN_HLEN);
+	else if (dev->mtu > netdev_get_mtu(real_dev, VLAN_HLEN))
 		return -EINVAL;
 
 	err = vlan_changelink(dev, tb, data);
