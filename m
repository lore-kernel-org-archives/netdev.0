From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: v2: [PATCH 2/3] netdevice: Fix promiscuity and allmulti overflow
Date: Mon, 16 Jun 2008 23:05:09 +0800
Message-ID: <48568125.4090500@cn.fujitsu.com>
References: <48562F45.3040302@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: NETDEV <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58989 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752556AbYFPPJd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 11:09:33 -0400
In-Reply-To: <48562F45.3040302@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Max of promiscuity and allmulti plus positive @inc can cause overflow.
Fox example: when allmulti=0xFFFFFFFF, any caller give dev_set_allmulti() a
positive @inc will cause allmulti be off.
This is not what we want, though it's rare case.
The fix is that only negative @inc will cause allmulti or promiscuity be off
and when any caller makes the counters touch the roof, we return error.

Change of v2:
Change void function dev_set_promiscuity/allmulti to return int.
So callers can get the overflow error.
Caller's fix will be done later.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 include/linux/netdevice.h |    4 +-
 net/core/dev.c            |   54 ++++++++++++++++++++++++++++++++++++--------
 2 files changed, 46 insertions(+), 12 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f27fd20..f2ab98e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1476,8 +1476,8 @@ extern int 		__dev_addr_delete(struct dev_addr_list **list, int *count, void *ad
 extern int		__dev_addr_add(struct dev_addr_list **list, int *count, void *addr, int alen, int newonly);
 extern int		__dev_addr_sync(struct dev_addr_list **to, int *to_count, struct dev_addr_list **from, int *from_count);
 extern void		__dev_addr_unsync(struct dev_addr_list **to, int *to_count, struct dev_addr_list **from, int *from_count);
-extern void		dev_set_promiscuity(struct net_device *dev, int inc);
-extern void		dev_set_allmulti(struct net_device *dev, int inc);
+extern int		dev_set_promiscuity(struct net_device *dev, int inc);
+extern int		dev_set_allmulti(struct net_device *dev, int inc);
 extern void		netdev_state_change(struct net_device *dev);
 extern void		netdev_features_change(struct net_device *dev);
 /* Load a device via the kmod */
diff --git a/net/core/dev.c b/net/core/dev.c
index 5829630..001646c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2747,16 +2747,29 @@ int netdev_set_master(struct net_device *slave, struct net_device *master)
 	return 0;
 }
 
-static void __dev_set_promiscuity(struct net_device *dev, int inc)
+static int __dev_set_promiscuity(struct net_device *dev, int inc)
 {
 	unsigned short old_flags = dev->flags;
 
 	ASSERT_RTNL();
 
-	if ((dev->promiscuity += inc) == 0)
-		dev->flags &= ~IFF_PROMISC;
-	else
-		dev->flags |= IFF_PROMISC;
+	dev->flags |= IFF_PROMISC;
+	dev->promiscuity += inc;
+	if (dev->promiscuity == 0) {
+		/*
+		 * Avoid overflow.
+		 * If inc causes overflow, untouch promisc and return error.
+		 */
+		if (inc < 0)
+			dev->flags &= ~IFF_PROMISC;
+		else {
+			dev->promiscuity -= inc;
+			printk(KERN_ERR "%s: promiscuity touches roof, "
+				"set promiscuity failed, promiscuity feature "
+				"of device will be broken.\n", dev->name);
+			return -EOVERFLOW;
+		}
+	}
 	if (dev->flags != old_flags) {
 		printk(KERN_INFO "device %s %s promiscuous mode\n",
 		       dev->name, (dev->flags & IFF_PROMISC) ? "entered" :
@@ -2774,6 +2787,7 @@ static void __dev_set_promiscuity(struct net_device *dev, int inc)
 		if (dev->change_rx_flags)
 			dev->change_rx_flags(dev, IFF_PROMISC);
 	}
+	return 0;
 }
 
 /**
@@ -2785,14 +2799,17 @@ static void __dev_set_promiscuity(struct net_device *dev, int inc)
  *	remains above zero the interface remains promiscuous. Once it hits zero
  *	the device reverts back to normal filtering operation. A negative inc
  *	value is used to drop promiscuity on the device.
+ *	Return 0 if successful or a negative errno code on error.
  */
-void dev_set_promiscuity(struct net_device *dev, int inc)
+int dev_set_promiscuity(struct net_device *dev, int inc)
 {
 	unsigned short old_flags = dev->flags;
+	int err;
 
-	__dev_set_promiscuity(dev, inc);
+	err = __dev_set_promiscuity(dev, inc);
 	if (dev->flags != old_flags)
 		dev_set_rx_mode(dev);
+	return err;
 }
 
 /**
@@ -2805,22 +2822,39 @@ void dev_set_promiscuity(struct net_device *dev, int inc)
  *	to all interfaces. Once it hits zero the device reverts back to normal
  *	filtering operation. A negative @inc value is used to drop the counter
  *	when releasing a resource needing all multicasts.
+ *	Return 0 if successful or a negative errno code on error.
  */
 
-void dev_set_allmulti(struct net_device *dev, int inc)
+int dev_set_allmulti(struct net_device *dev, int inc)
 {
 	unsigned short old_flags = dev->flags;
 
 	ASSERT_RTNL();
 
 	dev->flags |= IFF_ALLMULTI;
-	if ((dev->allmulti += inc) == 0)
-		dev->flags &= ~IFF_ALLMULTI;
+	dev->allmulti += inc;
+	if (dev->allmulti == 0) {
+		/*
+		 * Avoid overflow.
+		 * If inc causes overflow, untouch allmulti and return error.
+		 */
+		if (inc < 0)
+			dev->flags &= ~IFF_ALLMULTI;
+		else {
+			dev->allmulti -= inc;
+			printk(KERN_ERR "%s: allmulti touches roof, "
+				"set allmulti failed, allmulti feature of "
+				"device will be broken.\n", dev->name);
+			return -EOVERFLOW;
+		}
+	}
 	if (dev->flags ^ old_flags) {
 		if (dev->change_rx_flags)
 			dev->change_rx_flags(dev, IFF_ALLMULTI);
 		dev_set_rx_mode(dev);
 	}
+
+	return 0;
 }
 
 /*
-- 
1.5.3.4

