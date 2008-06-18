From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: v2: [PATCH 2/3] netdevice: Fix promiscuity and allmulti overflow
Date: Wed, 18 Jun 2008 09:51:00 +0800
Message-ID: <48586A04.6040800@cn.fujitsu.com>
References: <48562F45.3040302@cn.fujitsu.com> <48568125.4090500@cn.fujitsu.com> <4857B542.6030703@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59103 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1758850AbYFRByr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 21:54:47 -0400
In-Reply-To: <4857B542.6030703@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy said the following on 2008-6-17 20:59:
>> +            printk(KERN_ERR "%s: promiscuity touches roof, "
>> +                "set promiscuity failed, promiscuity feature "
>> +                "of device will be broken.\n", dev->name);
>> +            return -EOVERFLOW;
>> +        }
>> +    }
> 
> Assuming the caller does proper error handling, that printk is
> not true.
> 

Yes.
But currently, no caller handling this, and I think even if I make
some callers to handle this, but there maybe some callers and their
callers do not want to handle error condition.
So I need a KERN_WARNING here.
If some day, all of the caller handle the error properly, we can
remove this printk.

Here is v3:

---
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

Change of v3:
1. Since we return error to caller, we don't need to print KERN_ERROR,
KERN_WARNING is enough.
2. In dev_set_promiscuity(), if __dev_set_promiscuity() failed, we
return at once.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 include/linux/netdevice.h |    4 +-
 net/core/dev.c            |   55 ++++++++++++++++++++++++++++++++++++--------
 2 files changed, 47 insertions(+), 12 deletions(-)

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
index 5829630..61beb4d 100644
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
+			printk(KERN_WARNING "%s: promiscuity touches roof, "
+				"set promiscuity failed, promiscuity feature "
+				"of device might be broken.\n", dev->name);
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
@@ -2785,14 +2799,19 @@ static void __dev_set_promiscuity(struct net_device *dev, int inc)
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
+	if (!err)
+		return err;
 	if (dev->flags != old_flags)
 		dev_set_rx_mode(dev);
+	return err;
 }
 
 /**
@@ -2805,22 +2824,38 @@ void dev_set_promiscuity(struct net_device *dev, int inc)
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
+			printk(KERN_WARNING "%s: allmulti touches roof, "
+				"set allmulti failed, allmulti feature of "
+				"device might be broken.\n", dev->name);
+			return -EOVERFLOW;
+		}
+	}
 	if (dev->flags ^ old_flags) {
 		if (dev->change_rx_flags)
 			dev->change_rx_flags(dev, IFF_ALLMULTI);
 		dev_set_rx_mode(dev);
 	}
+	return 0;
 }
 
 /*
-- 
1.5.3.4


