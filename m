From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6] vlan: introduce ndo_vlan_[enable/disable]
Date: Sat, 16 Jul 2011 12:15:59 +0200
Message-ID: <1310811359-4440-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56004 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752950Ab1GPKQH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Jul 2011 06:16:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some devices are not able to enable/disable rx/tw vlan accel separately.
they depend on ndo_vlan_rx_register to know if to enable of disable
hw accel. And since ndo_vlan_rx_register is going to die soon,
this must be resolved.

One solution might be to enable accel on device start every time, even
if there are no vlan up on. But this would change behaviour and might
lead to possible regression (on older devices).

Better is to preserve current behaviour and introduce a couple of ndos
to let device driver know when to enable/disable vlan accel. They are
alled at the same time as ndo_vlan_rx_register.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 include/linux/netdevice.h |   14 ++++++++++++++
 net/8021q/vlan.c          |    4 ++++
 2 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f84dfd2..8a69f33 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -775,6 +775,18 @@ struct netdev_tc_txq {
  *	when vlan groups for the device changes.  Note: grp is NULL
  *	if no vlan's groups are being used.
  *
+ * void (*ndo_vlan_enable)(struct net_device *dev);
+ *	This function is called when first vlan is registered on this device.
+ *	This is primary to be implemented for devices what can enable rx/tx
+ *	vlan accel only at one. Otherwise enabling of vlan accel should be
+ *	implemented using ndo_set_features.
+ *
+ * void (*ndo_vlan_disable)(struct net_device *dev);
+ *	This function is called when last vlan is unregistered on this device.
+ *	This is primary to be implemented for devices what can disable rx/tx
+ *	vlan accel only at one. Otherwise disabling of vlan accel should be
+ *	implemented using ndo_set_features.
+ *
  * void (*ndo_vlan_rx_add_vid)(struct net_device *dev, unsigned short vid);
  *	If device support VLAN filtering (dev->features & NETIF_F_HW_VLAN_FILTER)
  *	this function is called when a VLAN id is registered.
@@ -895,6 +907,8 @@ struct net_device_ops {
 
 	void			(*ndo_vlan_rx_register)(struct net_device *dev,
 						        struct vlan_group *grp);
+	void			(*ndo_vlan_enable)(struct net_device *dev);
+	void			(*ndo_vlan_disable)(struct net_device *dev);
 	void			(*ndo_vlan_rx_add_vid)(struct net_device *dev,
 						       unsigned short vid);
 	void			(*ndo_vlan_rx_kill_vid)(struct net_device *dev,
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index d24c464..051c3cd 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -136,6 +136,8 @@ void unregister_vlan_dev(struct net_device *dev, struct list_head *head)
 		rcu_assign_pointer(real_dev->vlgrp, NULL);
 		if (ops->ndo_vlan_rx_register)
 			ops->ndo_vlan_rx_register(real_dev, NULL);
+		if (ops->ndo_vlan_disable)
+			ops->ndo_vlan_disable(real_dev);
 
 		/* Free the group, after all cpu's are done. */
 		call_rcu(&grp->rcu, vlan_rcu_free);
@@ -209,6 +211,8 @@ int register_vlan_dev(struct net_device *dev)
 	if (ngrp) {
 		if (ops->ndo_vlan_rx_register && (real_dev->features & NETIF_F_HW_VLAN_RX))
 			ops->ndo_vlan_rx_register(real_dev, ngrp);
+		if (ops->ndo_vlan_enable)
+			ops->ndo_vlan_enable(real_dev);
 		rcu_assign_pointer(real_dev->vlgrp, ngrp);
 	}
 	if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
-- 
1.7.6

