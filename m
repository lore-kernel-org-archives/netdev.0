From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/6] netdev: allow rejecting MTU changes from notifiers
Date: Fri, 17 Oct 2008 21:32:56 -0700
Message-ID: <20081018043323.642235776@vyatta.com>
References: <20081018043252.968940967@vyatta.com>
Cc: bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jay Vousburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:52219 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751208AbYJREgB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Oct 2008 00:36:01 -0400
Content-Disposition: inline; filename=dev-mtu-rollback.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows notifiers to reject changes to MTU, and then does rollback
same way change name does).

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
--- a/net/core/dev.c	2008-10-17 18:59:11.000000000 -0700
+++ b/net/core/dev.c	2008-10-17 21:22:30.000000000 -0700
@@ -3453,9 +3453,10 @@ int dev_change_flags(struct net_device *
  */
 int dev_set_mtu(struct net_device *dev, int new_mtu)
 {
-	int err;
+	int ret, err = 0;
+	int old_mtu = dev->mtu;
 
-	if (new_mtu == dev->mtu)
+	if (new_mtu == old_mtu)
 		return 0;
 
 	/*	MTU must be positive.	 */
@@ -3465,13 +3466,31 @@ int dev_set_mtu(struct net_device *dev, 
 	if (!netif_device_present(dev))
 		return -ENODEV;
 
-	err = 0;
-	if (dev->change_mtu)
-		err = dev->change_mtu(dev, new_mtu);
-	else
+rollback:
+	if (dev->change_mtu) {
+		ret = dev->change_mtu(dev, new_mtu);
+		if (ret)
+			return ret;
+	} else
 		dev->mtu = new_mtu;
-	if (!err && dev->flags & IFF_UP)
-		call_netdevice_notifiers(NETDEV_CHANGEMTU, dev);
+
+	if (!err && (dev->flags & IFF_UP)) {
+		ret = call_netdevice_notifiers(NETDEV_CHANGEMTU, dev);
+		ret = notifier_to_errno(ret);
+		printk(KERN_DEBUG "dev_set_mtu notifier ret %d\n", ret);
+
+		if (ret) {
+			if (err) {
+				printk(KERN_ERR "%s: mtu rollback failed: %d\n",
+				       dev->name, ret);
+			} else {
+				err = ret;
+				new_mtu = old_mtu;
+				goto rollback;
+			}
+		}
+
+	}
 	return err;
 }
 

-- 

