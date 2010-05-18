From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: [PATCH] net-2.6 : fix dev_get_valid_name
Date: Tue, 18 May 2010 19:35:12 +0200
Message-ID: <1274204112-8920-1-git-send-email-daniel.lezcano@free.fr>
Cc: opurdila@ixiacom.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([194.196.100.164]:53187 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758494Ab0ERRfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 13:35:21 -0400
Received: from d06nrmr1707.portsmouth.uk.ibm.com (d06nrmr1707.portsmouth.uk.ibm.com [9.149.39.225])
	by mtagate4.uk.ibm.com (8.13.1/8.13.1) with ESMTP id o4IHZJhF020931
	for <netdev@vger.kernel.org>; Tue, 18 May 2010 17:35:19 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1707.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o4IHZJO3635012
	for <netdev@vger.kernel.org>; Tue, 18 May 2010 18:35:19 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o4IHZJP6002201
	for <netdev@vger.kernel.org>; Tue, 18 May 2010 18:35:19 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the commit:

commit d90310243fd750240755e217c5faa13e24f41536
Author: Octavian Purdila <opurdila@ixiacom.com>
Date:   Wed Nov 18 02:36:59 2009 +0000

    net: device name allocation cleanups

introduced a bug when there is a hash collision making impossible
to rename a device with eth%d. This bug is very hard to reproduce
and appears rarely.

The problem is coming from we don't pass a temporary buffer to
__dev_alloc_name but 'dev->name' which is modified by the function.

A detailed explanation is here:

http://marc.info/?l=linux-netdev&m=127417784011987&w=2

Signed-off-by: Daniel Lezcano <daniel.lezcano@free.fr>
---
 net/core/dev.c |   20 ++++++++++++--------
 1 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 264137f..4704a1a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -936,18 +936,22 @@ int dev_alloc_name(struct net_device *dev, const char *name)
 }
 EXPORT_SYMBOL(dev_alloc_name);
 
-static int dev_get_valid_name(struct net *net, const char *name, char *buf,
-			      bool fmt)
+static int dev_get_valid_name(struct net_device *dev, const char *name, bool fmt)
 {
+	struct net *net;
+
+	BUG_ON(!dev_net(dev));
+	net = dev_net(dev);
+
 	if (!dev_valid_name(name))
 		return -EINVAL;
 
 	if (fmt && strchr(name, '%'))
-		return __dev_alloc_name(net, name, buf);
+		return dev_alloc_name(dev, name);
 	else if (__dev_get_by_name(net, name))
 		return -EEXIST;
-	else if (buf != name)
-		strlcpy(buf, name, IFNAMSIZ);
+	else if (strncmp(dev->name, name, IFNAMSIZ))
+		 strlcpy(dev->name, name, IFNAMSIZ);
 
 	return 0;
 }
@@ -979,7 +983,7 @@ int dev_change_name(struct net_device *dev, const char *newname)
 
 	memcpy(oldname, dev->name, IFNAMSIZ);
 
-	err = dev_get_valid_name(net, newname, dev->name, 1);
+	err = dev_get_valid_name(dev, newname, 1);
 	if (err < 0)
 		return err;
 
@@ -5083,7 +5087,7 @@ int register_netdevice(struct net_device *dev)
 		}
 	}
 
-	ret = dev_get_valid_name(net, dev->name, dev->name, 0);
+	ret = dev_get_valid_name(dev, dev->name, 0);
 	if (ret)
 		goto err_uninit;
 
@@ -5661,7 +5665,7 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 		/* We get here if we can't use the current device name */
 		if (!pat)
 			goto out;
-		if (dev_get_valid_name(net, pat, dev->name, 1))
+		if (dev_get_valid_name(dev, pat, 1))
 			goto out;
 	}
 
-- 
1.7.0.4

