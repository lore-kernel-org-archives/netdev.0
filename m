From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH] Fix netdev_printk null dereference
Date: Fri,  5 Mar 2010 12:47:05 +0000
Message-ID: <1267793225-426-1-git-send-email-steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 77-44-110-64.xdsl.murphx.net ([77.44.110.64]:59450 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750885Ab0CEMxN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 07:53:13 -0500
Received: from localhost.localdomain (unknown [10.0.20.109])
	by drevil2.shawell.net (Postfix) with ESMTP id 1D5D967BC8
	for <netdev@vger.kernel.org>; Fri,  5 Mar 2010 12:47:05 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a reproducible null dereference in smsc95xx (and I
suspect others) when the device is removed during a control register
access.  This can be reproduced by rapidly plugging and unplugging
the device during its initialisation.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 include/linux/netdevice.h |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c79a88b..250dbc0 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2132,9 +2132,10 @@ static inline const char *netdev_name(const struct net_device *dev)
 }
 
 #define netdev_printk(level, netdev, format, args...)		\
-	dev_printk(level, (netdev)->dev.parent,			\
+	({ if ((netdev)->dev.parent)				\
+		dev_printk(level, (netdev)->dev.parent,		\
 		   "%s: " format,				\
-		   netdev_name(netdev), ##args)
+		   netdev_name(netdev), ##args); })
 
 #define netdev_emerg(dev, format, args...)			\
 	netdev_printk(KERN_EMERG, dev, format, ##args)
-- 
1.6.6.1

