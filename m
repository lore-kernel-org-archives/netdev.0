From: Patrick McHardy <kaber@trash.net>
Subject: [NET 03/04]: Add __dev_getfirstbyhwtype
Date: Thu,  3 May 2007 02:04:17 +0200 (MEST)
Message-ID: <20070503000300.30775.78276.sendpatchset@localhost.localdomain>
References: <20070503000256.30775.81929.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	howells@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48181 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767272AbXECAES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 20:04:18 -0400
In-Reply-To: <20070503000256.30775.81929.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET]: Add __dev_getfirstbyhwtype

Add __dev_getfirstbyhwtype for callers that don't want a reference but
some data from the device and thus need to take the rtnl anyway.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 3c87ab894405bb9997ff07ceb7dde4902762596a
tree 2d2dfae5b5cacaeb4dc03600073d1e8716312742
parent cef7f64469d521dd1dcb991e247ad02e84c3051c
author Patrick McHardy <kaber@trash.net> Wed, 02 May 2007 20:19:09 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 02 May 2007 20:19:09 +0200

 include/linux/netdevice.h |    1 +
 net/core/dev.c            |   21 ++++++++++++++++-----
 2 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ac0c92b..4428f1c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -582,6 +582,7 @@ extern int 			netdev_boot_setup_check(struct net_device *dev);
 extern unsigned long		netdev_boot_base(const char *prefix, int unit);
 extern struct net_device    *dev_getbyhwaddr(unsigned short type, char *hwaddr);
 extern struct net_device *dev_getfirstbyhwtype(unsigned short type);
+extern struct net_device *__dev_getfirstbyhwtype(unsigned short type);
 extern void		dev_add_pack(struct packet_type *pt);
 extern void		dev_remove_pack(struct packet_type *pt);
 extern void		__dev_remove_pack(struct packet_type *pt);
diff --git a/net/core/dev.c b/net/core/dev.c
index eb99900..c305819 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -576,17 +576,28 @@ struct net_device *dev_getbyhwaddr(unsigned short type, char *ha)
 
 EXPORT_SYMBOL(dev_getbyhwaddr);
 
-struct net_device *dev_getfirstbyhwtype(unsigned short type)
+struct net_device *__dev_getfirstbyhwtype(unsigned short type)
 {
 	struct net_device *dev;
 
-	rtnl_lock();
+	ASSERT_RTNL();
 	for (dev = dev_base; dev; dev = dev->next) {
-		if (dev->type == type) {
-			dev_hold(dev);
+		if (dev->type == type)
 			break;
-		}
 	}
+	return dev;
+}
+
+EXPORT_SYMBOL(__dev_getfirstbyhwtype);
+
+struct net_device *dev_getfirstbyhwtype(unsigned short type)
+{
+	struct net_device *dev;
+
+	rtnl_lock();
+	dev = __dev_getfirstbyhwtype(type);
+	if (dev)
+		dev_hold(dev);
 	rtnl_unlock();
 	return dev;
 }
