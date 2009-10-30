From: Stephen Hemminger <shemminger@vyatta.com>
Subject: RFC: netdev: allow ethtool physical id to drop rtnl_lock
Date: Fri, 30 Oct 2009 10:42:01 -0700
Message-ID: <20091030104201.6bb03b23@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48583 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932257AbZJ3RmC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Oct 2009 13:42:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool operation to blink LED can take an indeterminately long time,
blocking out other operations (via rtnl_lock). This patch is an attempt
to work around the problem.

It does need more discussion, because it will mean that drivers that formerly
were protected from changes during blink aren't.  For example, user could
start device blinking, and then plug in cable causing change netlink event
to change state or pull cable and have device come down.

The other possibility is to do this on a driver by driver basis
which is more effort.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/core/ethtool.c	2009-10-30 10:27:23.621917624 -0700
+++ b/net/core/ethtool.c	2009-10-30 10:35:53.787670774 -0700
@@ -17,6 +17,7 @@
 #include <linux/errno.h>
 #include <linux/ethtool.h>
 #include <linux/netdevice.h>
+#include <linux/rtnetlink.h>
 #include <asm/uaccess.h>
 
 /*
@@ -781,6 +782,8 @@ static int ethtool_get_strings(struct ne
 static int ethtool_phys_id(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_value id;
+	int err;
+	static int busy;
 
 	if (!dev->ethtool_ops->phys_id)
 		return -EOPNOTSUPP;
@@ -788,7 +791,21 @@ static int ethtool_phys_id(struct net_de
 	if (copy_from_user(&id, useraddr, sizeof(id)))
 		return -EFAULT;
 
-	return dev->ethtool_ops->phys_id(dev, id.data);
+	if (busy)
+		return -EBUSY;
+
+	/* This operation may take a long time, drop lock */
+	busy = 1;
+	dev_hold(dev);
+	rtnl_unlock();
+
+	err = dev->ethtool_ops->phys_id(dev, id.data);
+
+	rtnl_lock();
+	dev_put(dev);
+	busy = 0;
+
+	return err;
 }
 
 static int ethtool_get_stats(struct net_device *dev, void __user *useraddr)
