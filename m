From: Patrick Mullaney <pmullaney@novell.com>
Subject: [PATCH] netdevice: provide common routine for macvlan and vlan
	operstate management
Date: Thu, 03 Dec 2009 15:21:54 -0500
Message-ID: <20091203201824.15789.7578.stgit@mimic.site>
References: <4B105311.1020005@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, arnd@arndb.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <4B105311.1020005@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Applies to net-next-2.6.git/master:218d00bdd)

Provide common routine for the transition of operational state for a leaf
device during a root device transition.

Signed-off-by: Patrick Mullaney <pmullaney@novell.com>
---

 drivers/net/macvlan.c     |   24 +++---------------------
 include/linux/netdevice.h |    3 +++
 net/8021q/vlan.c          |   29 ++++-------------------------
 net/core/dev.c            |   27 +++++++++++++++++++++++++++
 4 files changed, 37 insertions(+), 46 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 93c3e6e..21a9c9a 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -582,25 +582,6 @@ static void macvlan_port_destroy(struct net_device *dev)
 	kfree(port);
 }
 
-static void macvlan_transfer_operstate(struct net_device *dev)
-{
-	struct macvlan_dev *vlan = netdev_priv(dev);
-	const struct net_device *lowerdev = vlan->lowerdev;
-
-	if (lowerdev->operstate == IF_OPER_DORMANT)
-		netif_dormant_on(dev);
-	else
-		netif_dormant_off(dev);
-
-	if (netif_carrier_ok(lowerdev)) {
-		if (!netif_carrier_ok(dev))
-			netif_carrier_on(dev);
-	} else {
-		if (netif_carrier_ok(dev))
-			netif_carrier_off(dev);
-	}
-}
-
 static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
 {
 	if (tb[IFLA_ADDRESS]) {
@@ -693,7 +674,7 @@ static int macvlan_newlink(struct net *src_net, struct net_device *dev,
 		return err;
 
 	list_add_tail(&vlan->list, &port->vlans);
-	macvlan_transfer_operstate(dev);
+	netif_stacked_transfer_operstate(lowerdev, dev);
 	return 0;
 }
 
@@ -768,7 +749,8 @@ static int macvlan_device_event(struct notifier_block *unused,
 	switch (event) {
 	case NETDEV_CHANGE:
 		list_for_each_entry(vlan, &port->vlans, list)
-			macvlan_transfer_operstate(vlan->dev);
+			netif_stacked_transfer_operstate(vlan->lowerdev,
+							 vlan->dev);
 		break;
 	case NETDEV_FEAT_CHANGE:
 		list_for_each_entry(vlan, &port->vlans, list) {
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index daf13d3..a3fccc8 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1981,6 +1981,9 @@ unsigned long netdev_increment_features(unsigned long all, unsigned long one,
 					unsigned long mask);
 unsigned long netdev_fix_features(unsigned long features, const char *name);
 
+void netif_stacked_transfer_operstate(const struct net_device *rootdev,
+					struct net_device *dev);
+
 static inline int net_gso_ok(int features, int gso_type)
 {
 	int feature = gso_type << NETIF_F_GSO_SHIFT;
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index ec37692..33f90e7 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -184,27 +184,6 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 	dev_put(real_dev);
 }
 
-static void vlan_transfer_operstate(const struct net_device *dev,
-				    struct net_device *vlandev)
-{
-	/* Have to respect userspace enforced dormant state
-	 * of real device, also must allow supplicant running
-	 * on VLAN device
-	 */
-	if (dev->operstate == IF_OPER_DORMANT)
-		netif_dormant_on(vlandev);
-	else
-		netif_dormant_off(vlandev);
-
-	if (netif_carrier_ok(dev)) {
-		if (!netif_carrier_ok(vlandev))
-			netif_carrier_on(vlandev);
-	} else {
-		if (netif_carrier_ok(vlandev))
-			netif_carrier_off(vlandev);
-	}
-}
-
 int vlan_check_real_dev(struct net_device *real_dev, u16 vlan_id)
 {
 	const char *name = real_dev->name;
@@ -262,7 +241,7 @@ int register_vlan_dev(struct net_device *dev)
 	/* Account for reference in struct vlan_dev_info */
 	dev_hold(real_dev);
 
-	vlan_transfer_operstate(real_dev, dev);
+	netif_stacked_transfer_operstate(real_dev, dev);
 	linkwatch_fire_event(dev); /* _MUST_ call rfc2863_policy() */
 
 	/* So, got the sucker initialized, now lets place
@@ -453,7 +432,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 			if (!vlandev)
 				continue;
 
-			vlan_transfer_operstate(dev, vlandev);
+			netif_stacked_transfer_operstate(dev, vlandev);
 		}
 		break;
 
@@ -511,7 +490,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 			vlan = vlan_dev_info(vlandev);
 			if (!(vlan->flags & VLAN_FLAG_LOOSE_BINDING))
 				dev_change_flags(vlandev, flgs & ~IFF_UP);
-			vlan_transfer_operstate(dev, vlandev);
+			netif_stacked_transfer_operstate(dev, vlandev);
 		}
 		break;
 
@@ -529,7 +508,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 			vlan = vlan_dev_info(vlandev);
 			if (!(vlan->flags & VLAN_FLAG_LOOSE_BINDING))
 				dev_change_flags(vlandev, flgs | IFF_UP);
-			vlan_transfer_operstate(dev, vlandev);
+			netif_stacked_transfer_operstate(dev, vlandev);
 		}
 		break;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index e3e18de..1842f63 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4901,6 +4901,33 @@ unsigned long netdev_fix_features(unsigned long features, const char *name)
 EXPORT_SYMBOL(netdev_fix_features);
 
 /**
+ *	netif_stacked_transfer_operstate -	transfer operstate
+ *	@rootdev: the root or lower level device to transfer state from
+ *	@dev: the device to transfer operstate to
+ *
+ *	Transfer operational state from root to device. This is normally
+ *	called when a stacking relationship exists between the root
+ *	device and the device(a leaf device).
+ */
+void netif_stacked_transfer_operstate(const struct net_device *rootdev,
+					struct net_device *dev)
+{
+	if (rootdev->operstate == IF_OPER_DORMANT)
+		netif_dormant_on(dev);
+	else
+		netif_dormant_off(dev);
+
+	if (netif_carrier_ok(rootdev)) {
+		if (!netif_carrier_ok(dev))
+			netif_carrier_on(dev);
+	} else {
+		if (netif_carrier_ok(dev))
+			netif_carrier_off(dev);
+	}
+}
+EXPORT_SYMBOL(netif_stacked_transfer_operstate);
+
+/**
  *	register_netdevice	- register a network device
  *	@dev: device to register
  *

