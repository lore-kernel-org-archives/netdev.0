From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v3 2/2] dev: always advertise rx_flags changes via netlink
Date: Wed, 25 Sep 2013 12:02:45 +0200
Message-ID: <1380103365-5185-2-git-send-email-nicolas.dichtel@6wind.com>
References: <20130924094707.41641042@nehalam.linuxnetplumber.net>
 <1380103365-5185-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:36475 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754265Ab3IYKC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 06:02:57 -0400
In-Reply-To: <1380103365-5185-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When flags IFF_PROMISC and IFF_ALLMULTI are changed, netlink messages are not
consistent. For example, if a multicast daemon is running (flag IFF_ALLMULTI
set in dev->flags but not dev->gflags, ie not exported to userspace) and then a
user sets it via netlink (flag IFF_ALLMULTI set in dev->flags and dev->gflags, ie
exported to userspace), no netlink message is sent.
Same for IFF_PROMISC and because dev->promiscuity is exported via
IFLA_PROMISCUITY, we may send a netlink message after each change of this
counter.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

v3: add patch #1
    use __dev_notify_flags() to notify rxflags (note that notifier chains are
    not called when flags IFF_PROMISC and IFF_ALLMULTI are changed)

v2: rework the patch to avoid double notification

 net/core/dev.c | 60 ++++++++++++++++++++++++++++++++++++----------------------
 1 file changed, 37 insertions(+), 23 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 1222309feeaa..b23aefcb3c42 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4822,7 +4822,7 @@ static void dev_change_rx_flags(struct net_device *dev, int flags)
 		ops->ndo_change_rx_flags(dev, flags);
 }
 
-static int __dev_set_promiscuity(struct net_device *dev, int inc)
+static int __dev_set_promiscuity(struct net_device *dev, int inc, bool notify)
 {
 	unsigned int old_flags = dev->flags;
 	kuid_t uid;
@@ -4865,6 +4865,8 @@ static int __dev_set_promiscuity(struct net_device *dev, int inc)
 
 		dev_change_rx_flags(dev, IFF_PROMISC);
 	}
+	if (notify)
+		__dev_notify_flags(dev, old_flags, IFF_PROMISC);
 	return 0;
 }
 
@@ -4884,7 +4886,7 @@ int dev_set_promiscuity(struct net_device *dev, int inc)
 	unsigned int old_flags = dev->flags;
 	int err;
 
-	err = __dev_set_promiscuity(dev, inc);
+	err = __dev_set_promiscuity(dev, inc, true);
 	if (err < 0)
 		return err;
 	if (dev->flags != old_flags)
@@ -4893,22 +4895,9 @@ int dev_set_promiscuity(struct net_device *dev, int inc)
 }
 EXPORT_SYMBOL(dev_set_promiscuity);
 
-/**
- *	dev_set_allmulti	- update allmulti count on a device
- *	@dev: device
- *	@inc: modifier
- *
- *	Add or remove reception of all multicast frames to a device. While the
- *	count in the device remains above zero the interface remains listening
- *	to all interfaces. Once it hits zero the device reverts back to normal
- *	filtering operation. A negative @inc value is used to drop the counter
- *	when releasing a resource needing all multicasts.
- *	Return 0 if successful or a negative errno code on error.
- */
-
-int dev_set_allmulti(struct net_device *dev, int inc)
+static int __dev_set_allmulti(struct net_device *dev, int inc, bool notify)
 {
-	unsigned int old_flags = dev->flags;
+	unsigned int old_flags = dev->flags, old_gflags = dev->gflags;
 
 	ASSERT_RTNL();
 
@@ -4931,9 +4920,30 @@ int dev_set_allmulti(struct net_device *dev, int inc)
 	if (dev->flags ^ old_flags) {
 		dev_change_rx_flags(dev, IFF_ALLMULTI);
 		dev_set_rx_mode(dev);
+		if (notify)
+			__dev_notify_flags(dev, old_flags,
+					   dev->gflags ^ old_gflags);
 	}
 	return 0;
 }
+
+/**
+ *	dev_set_allmulti	- update allmulti count on a device
+ *	@dev: device
+ *	@inc: modifier
+ *
+ *	Add or remove reception of all multicast frames to a device. While the
+ *	count in the device remains above zero the interface remains listening
+ *	to all interfaces. Once it hits zero the device reverts back to normal
+ *	filtering operation. A negative @inc value is used to drop the counter
+ *	when releasing a resource needing all multicasts.
+ *	Return 0 if successful or a negative errno code on error.
+ */
+
+int dev_set_allmulti(struct net_device *dev, int inc)
+{
+	return __dev_set_allmulti(dev, inc, true);
+}
 EXPORT_SYMBOL(dev_set_allmulti);
 
 /*
@@ -4958,10 +4968,10 @@ void __dev_set_rx_mode(struct net_device *dev)
 		 * therefore calling __dev_set_promiscuity here is safe.
 		 */
 		if (!netdev_uc_empty(dev) && !dev->uc_promisc) {
-			__dev_set_promiscuity(dev, 1);
+			__dev_set_promiscuity(dev, 1, false);
 			dev->uc_promisc = true;
 		} else if (netdev_uc_empty(dev) && dev->uc_promisc) {
-			__dev_set_promiscuity(dev, -1);
+			__dev_set_promiscuity(dev, -1, false);
 			dev->uc_promisc = false;
 		}
 	}
@@ -5050,9 +5060,13 @@ int __dev_change_flags(struct net_device *dev, unsigned int flags)
 
 	if ((flags ^ dev->gflags) & IFF_PROMISC) {
 		int inc = (flags & IFF_PROMISC) ? 1 : -1;
+		unsigned int old_flags = dev->flags;
 
 		dev->gflags ^= IFF_PROMISC;
-		dev_set_promiscuity(dev, inc);
+
+		if (__dev_set_promiscuity(dev, inc, false) >= 0)
+			if (dev->flags != old_flags)
+				dev_set_rx_mode(dev);
 	}
 
 	/* NOTE: order of synchronization of IFF_PROMISC and IFF_ALLMULTI
@@ -5063,7 +5077,7 @@ int __dev_change_flags(struct net_device *dev, unsigned int flags)
 		int inc = (flags & IFF_ALLMULTI) ? 1 : -1;
 
 		dev->gflags ^= IFF_ALLMULTI;
-		dev_set_allmulti(dev, inc);
+		__dev_set_allmulti(dev, inc, false);
 	}
 
 	return ret;
@@ -5105,13 +5119,13 @@ void __dev_notify_flags(struct net_device *dev, unsigned int old_flags,
 int dev_change_flags(struct net_device *dev, unsigned int flags)
 {
 	int ret;
-	unsigned int changes, old_flags = dev->flags;
+	unsigned int changes, old_flags = dev->flags, old_gflags = dev->gflags;
 
 	ret = __dev_change_flags(dev, flags);
 	if (ret < 0)
 		return ret;
 
-	changes = old_flags ^ dev->flags;
+	changes = (old_flags ^ dev->flags) | (old_gflags ^ dev->gflags);
 	__dev_notify_flags(dev, old_flags, changes);
 	return ret;
 }
-- 
1.8.2.1
