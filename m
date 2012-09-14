From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH net-next] net: dev: fix incorrect getting net device's name
Date: Fri, 14 Sep 2012 14:58:27 +0800
Message-ID: <1347605907-3884-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: ebiederm@xmission.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, Gao feng <gaofeng@cn.fujitsu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53419 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750955Ab2ING6X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2012 02:58:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When moving a nic from net namespace A to net namespace B,
in dev_change_net_namesapce,we call __dev_get_by_name to
decide if the netns B has the device has the same name.

if the netns B already has the same named device,we call
dev_get_valid_name to try to get a valid name for this nic in
the netns B,but net_device->nd_net still point to netns A now.

this patch fix it.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/core/dev.c |   28 ++++++++++++++++++++--------
 1 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index b1e6d63..381ea68 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -959,18 +959,30 @@ int dev_alloc_name(struct net_device *dev, const char *name)
 }
 EXPORT_SYMBOL(dev_alloc_name);
 
-static int dev_get_valid_name(struct net_device *dev, const char *name)
+static int dev_alloc_name_ns(struct net *net,
+			     struct net_device *dev,
+			     const char *name)
 {
-	struct net *net;
+	char buf[IFNAMSIZ];
+	int ret;
 
-	BUG_ON(!dev_net(dev));
-	net = dev_net(dev);
+	ret = __dev_alloc_name(net, name, buf);
+	if (ret >= 0)
+		strlcpy(dev->name, buf, IFNAMSIZ);
+	return ret;
+}
+
+static int dev_get_valid_name(struct net *net,
+			      struct net_device *dev,
+			      const char *name)
+{
+	BUG_ON(!net);
 
 	if (!dev_valid_name(name))
 		return -EINVAL;
 
 	if (strchr(name, '%'))
-		return dev_alloc_name(dev, name);
+		return dev_alloc_name_ns(net, dev, name);
 	else if (__dev_get_by_name(net, name))
 		return -EEXIST;
 	else if (dev->name != name)
@@ -1006,7 +1018,7 @@ int dev_change_name(struct net_device *dev, const char *newname)
 
 	memcpy(oldname, dev->name, IFNAMSIZ);
 
-	err = dev_get_valid_name(dev, newname);
+	err = dev_get_valid_name(net, dev, newname);
 	if (err < 0)
 		return err;
 
@@ -5585,7 +5597,7 @@ int register_netdevice(struct net_device *dev)
 
 	dev->iflink = -1;
 
-	ret = dev_get_valid_name(dev, dev->name);
+	ret = dev_get_valid_name(net, dev, dev->name);
 	if (ret < 0)
 		goto out;
 
@@ -6229,7 +6241,7 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 		/* We get here if we can't use the current device name */
 		if (!pat)
 			goto out;
-		if (dev_get_valid_name(dev, pat) < 0)
+		if (dev_get_valid_name(net, dev, pat) < 0)
 			goto out;
 	}
 
-- 
1.7.7.6
