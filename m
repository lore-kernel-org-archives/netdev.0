From: Patrick McHardy <kaber@trash.net>
Subject: Re: vlan/macvlan: fix NULL pointer dereferences in ethtool handlers
Date: Mon, 20 Apr 2009 16:49:28 +0200
Message-ID: <49EC8B78.1020704@trash.net>
References: <49E8A8CC.8060305@trash.net> <20090417.155943.174603790.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090000040201070008050305"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33893 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755901AbZDTOtc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 10:49:32 -0400
In-Reply-To: <20090417.155943.174603790.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090000040201070008050305
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Fri, 17 Apr 2009 18:05:32 +0200
> 
>>     vlan/macvlan: fix NULL pointer dereferences in ethtool handlers
>>     
>>     Check whether the underlying device provides a set of ethtool ops before
>>     checking for individual handlers to avoid NULL pointer dereferences.
>>     
>>     Reported-by: Art van Breemen <ard@telegraafnet.nl>
>>     Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> Applied, thanks Patrick.
> 
> These things beg for helper functions in my opinion.

Something like this?



--------------090000040201070008050305
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit ff0b17b20d79b5aecc86fff587d957fe11c638fb
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Apr 20 16:46:48 2009 +0200

    net: factor out ethtool invocation of vlan/macvlan drivers
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 214a8cf..329cd50 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -374,36 +374,20 @@ static void macvlan_ethtool_get_drvinfo(struct net_device *dev,
 static u32 macvlan_ethtool_get_rx_csum(struct net_device *dev)
 {
 	const struct macvlan_dev *vlan = netdev_priv(dev);
-	struct net_device *lowerdev = vlan->lowerdev;
-
-	if (lowerdev->ethtool_ops == NULL ||
-	    lowerdev->ethtool_ops->get_rx_csum == NULL)
-		return 0;
-	return lowerdev->ethtool_ops->get_rx_csum(lowerdev);
+	return dev_ethtool_get_rx_csum(vlan->lowerdev);
 }
 
 static int macvlan_ethtool_get_settings(struct net_device *dev,
 					struct ethtool_cmd *cmd)
 {
 	const struct macvlan_dev *vlan = netdev_priv(dev);
-	struct net_device *lowerdev = vlan->lowerdev;
-
-	if (!lowerdev->ethtool_ops ||
-	    !lowerdev->ethtool_ops->get_settings)
-		return -EOPNOTSUPP;
-
-	return lowerdev->ethtool_ops->get_settings(lowerdev, cmd);
+	return dev_ethtool_get_settings(vlan->lowerdev, cmd);
 }
 
 static u32 macvlan_ethtool_get_flags(struct net_device *dev)
 {
 	const struct macvlan_dev *vlan = netdev_priv(dev);
-	struct net_device *lowerdev = vlan->lowerdev;
-
-	if (!lowerdev->ethtool_ops ||
-	    !lowerdev->ethtool_ops->get_flags)
-		return 0;
-	return lowerdev->ethtool_ops->get_flags(lowerdev);
+	return dev_ethtool_get_flags(vlan->lowerdev);
 }
 
 static const struct ethtool_ops macvlan_ethtool_ops = {
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2e7783f..04679ca 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -42,6 +42,7 @@
 #include <linux/dmaengine.h>
 #include <linux/workqueue.h>
 
+#include <linux/ethtool.h>
 #include <net/net_namespace.h>
 #include <net/dsa.h>
 #ifdef CONFIG_DCB
@@ -49,7 +50,6 @@
 #endif
 
 struct vlan_group;
-struct ethtool_ops;
 struct netpoll_info;
 /* 802.11 specific */
 struct wireless_dev;
@@ -1908,6 +1908,28 @@ static inline int skb_bond_should_drop(struct sk_buff *skb)
 }
 
 extern struct pernet_operations __net_initdata loopback_net_ops;
+
+static inline int dev_ethtool_get_settings(struct net_device *dev,
+					   struct ethtool_cmd *cmd)
+{
+	if (!dev->ethtool_ops || !dev->ethtool_ops->get_settings)
+		return -EOPNOTSUPP;
+	return dev->ethtool_ops->get_settings(dev, cmd);
+}
+
+static inline u32 dev_ethtool_get_rx_csum(struct net_device *dev)
+{
+	if (!dev->ethtool_ops || !dev->ethtool_ops->get_rx_csum)
+		return 0;
+	return dev->ethtool_ops->get_rx_csum(dev);
+}
+
+static inline u32 dev_ethtool_get_flags(struct net_device *dev)
+{
+	if (!dev->ethtool_ops || !dev->ethtool_ops->get_flags)
+		return 0;
+	return dev->ethtool_ops->get_flags(dev);
+}
 #endif /* __KERNEL__ */
 
 #endif	/* _LINUX_DEV_H */
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 6b09213..04dc8c8 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -666,13 +666,7 @@ static int vlan_ethtool_get_settings(struct net_device *dev,
 				     struct ethtool_cmd *cmd)
 {
 	const struct vlan_dev_info *vlan = vlan_dev_info(dev);
-	struct net_device *real_dev = vlan->real_dev;
-
-	if (!real_dev->ethtool_ops ||
-	    !real_dev->ethtool_ops->get_settings)
-		return -EOPNOTSUPP;
-
-	return real_dev->ethtool_ops->get_settings(real_dev, cmd);
+	return dev_ethtool_get_settings(vlan->real_dev, cmd);
 }
 
 static void vlan_ethtool_get_drvinfo(struct net_device *dev,
@@ -686,24 +680,13 @@ static void vlan_ethtool_get_drvinfo(struct net_device *dev,
 static u32 vlan_ethtool_get_rx_csum(struct net_device *dev)
 {
 	const struct vlan_dev_info *vlan = vlan_dev_info(dev);
-	struct net_device *real_dev = vlan->real_dev;
-
-	if (real_dev->ethtool_ops == NULL ||
-	    real_dev->ethtool_ops->get_rx_csum == NULL)
-		return 0;
-	return real_dev->ethtool_ops->get_rx_csum(real_dev);
+	return dev_ethtool_get_rx_csum(vlan->real_dev);
 }
 
 static u32 vlan_ethtool_get_flags(struct net_device *dev)
 {
 	const struct vlan_dev_info *vlan = vlan_dev_info(dev);
-	struct net_device *real_dev = vlan->real_dev;
-
-	if (!(real_dev->features & NETIF_F_HW_VLAN_RX) ||
-	    real_dev->ethtool_ops == NULL ||
-	    real_dev->ethtool_ops->get_flags == NULL)
-		return 0;
-	return real_dev->ethtool_ops->get_flags(real_dev);
+	return dev_ethtool_get_flags(vlan->real_dev);
 }
 
 static const struct ethtool_ops vlan_ethtool_ops = {

--------------090000040201070008050305--
