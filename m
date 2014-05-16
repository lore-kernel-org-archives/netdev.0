From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH 3/4] vlan: Fix lockdep warning with stacked vlan devices.
Date: Fri, 16 May 2014 11:36:43 -0400
Message-ID: <1400254604-23910-4-git-send-email-vyasevic@redhat.com>
References: <1400254604-23910-1-git-send-email-vyasevic@redhat.com>
Cc: dingtianhong@huawei.com, kaber@trash.net, vfalico@gmail.com,
	jiri@resnulli.us, Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14234 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932831AbaEPPhO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2014 11:37:14 -0400
In-Reply-To: <1400254604-23910-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit dc8eaaa006350d24030502a4521542e74b5cb39f.
	vlan: Fix lockdep warning when vlan dev handle notification

Instead we use the new new API to find the lock subclass of
our vlan device.  This way we can support configurations where
vlans are interspersed with other devices:
  bond -> vlan -> macvlan -> vlan

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/linux/if_vlan.h |  1 +
 net/8021q/vlan.c        |  1 +
 net/8021q/vlan_dev.c    | 52 +++++++++----------------------------------------
 net/core/dev.c          |  1 -
 4 files changed, 11 insertions(+), 44 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 13bbbde..9b5f405 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -159,6 +159,7 @@ struct vlan_dev_priv {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	struct netpoll				*netpoll;
 #endif
+	unsigned int				nest_level;
 };
 
 static inline struct vlan_dev_priv *vlan_dev_priv(const struct net_device *dev)
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 0328d73..76812f01 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -185,6 +185,7 @@ int register_vlan_dev(struct net_device *dev)
 	if (err < 0)
 		goto out_uninit_mvrp;
 
+	vlan->nest_level = dev_get_nest_level(real_dev, is_vlan_dev) + 1;
 	err = register_netdevice(dev);
 	if (err < 0)
 		goto out_uninit_mvrp;
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 733ec28..da0951e 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -493,48 +493,10 @@ static void vlan_dev_change_rx_flags(struct net_device *dev, int change)
 	}
 }
 
-static int vlan_calculate_locking_subclass(struct net_device *real_dev)
-{
-	int subclass = 0;
-
-	while (is_vlan_dev(real_dev)) {
-		subclass++;
-		real_dev = vlan_dev_priv(real_dev)->real_dev;
-	}
-
-	return subclass;
-}
-
-static void vlan_dev_mc_sync(struct net_device *to, struct net_device *from)
-{
-	int err = 0, subclass;
-
-	subclass = vlan_calculate_locking_subclass(to);
-
-	spin_lock_nested(&to->addr_list_lock, subclass);
-	err = __hw_addr_sync(&to->mc, &from->mc, to->addr_len);
-	if (!err)
-		__dev_set_rx_mode(to);
-	spin_unlock(&to->addr_list_lock);
-}
-
-static void vlan_dev_uc_sync(struct net_device *to, struct net_device *from)
-{
-	int err = 0, subclass;
-
-	subclass = vlan_calculate_locking_subclass(to);
-
-	spin_lock_nested(&to->addr_list_lock, subclass);
-	err = __hw_addr_sync(&to->uc, &from->uc, to->addr_len);
-	if (!err)
-		__dev_set_rx_mode(to);
-	spin_unlock(&to->addr_list_lock);
-}
-
 static void vlan_dev_set_rx_mode(struct net_device *vlan_dev)
 {
-	vlan_dev_mc_sync(vlan_dev_priv(vlan_dev)->real_dev, vlan_dev);
-	vlan_dev_uc_sync(vlan_dev_priv(vlan_dev)->real_dev, vlan_dev);
+	dev_mc_sync(vlan_dev_priv(vlan_dev)->real_dev, vlan_dev);
+	dev_uc_sync(vlan_dev_priv(vlan_dev)->real_dev, vlan_dev);
 }
 
 /*
@@ -597,7 +559,6 @@ static const struct net_device_ops vlan_netdev_ops;
 static int vlan_dev_init(struct net_device *dev)
 {
 	struct net_device *real_dev = vlan_dev_priv(dev)->real_dev;
-	int subclass = 0;
 
 	netif_carrier_off(dev);
 
@@ -646,8 +607,7 @@ static int vlan_dev_init(struct net_device *dev)
 
 	SET_NETDEV_DEVTYPE(dev, &vlan_type);
 
-	subclass = vlan_calculate_locking_subclass(dev);
-	vlan_dev_set_lockdep_class(dev, subclass);
+	vlan_dev_set_lockdep_class(dev, vlan_dev_get_lock_subclas(dev));
 
 	vlan_dev_priv(dev)->vlan_pcpu_stats = netdev_alloc_pcpu_stats(struct vlan_pcpu_stats);
 	if (!vlan_dev_priv(dev)->vlan_pcpu_stats)
@@ -785,6 +745,11 @@ static void vlan_dev_netpoll_cleanup(struct net_device *dev)
 }
 #endif /* CONFIG_NET_POLL_CONTROLLER */
 
+static int vlan_dev_get_lock_subclass(struct net_device *dev)
+{
+	return vlan_dev_priv(dev)->nest_level;
+}
+
 static const struct ethtool_ops vlan_ethtool_ops = {
 	.get_settings	        = vlan_ethtool_get_settings,
 	.get_drvinfo	        = vlan_ethtool_get_drvinfo,
@@ -819,6 +784,7 @@ static const struct net_device_ops vlan_netdev_ops = {
 	.ndo_netpoll_cleanup	= vlan_dev_netpoll_cleanup,
 #endif
 	.ndo_fix_features	= vlan_dev_fix_features,
+	.ndo_get_lock_subclass  = vlan_dev_get_lock_subclass,
 };
 
 void vlan_setup(struct net_device *dev)
diff --git a/net/core/dev.c b/net/core/dev.c
index fd0d139..fdaf1f7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5284,7 +5284,6 @@ void __dev_set_rx_mode(struct net_device *dev)
 	if (ops->ndo_set_rx_mode)
 		ops->ndo_set_rx_mode(dev);
 }
-EXPORT_SYMBOL(__dev_set_rx_mode);
 
 void dev_set_rx_mode(struct net_device *dev)
 {
-- 
1.9.0
