From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [net-next-2.6 PATCH] net: device name allocation cleanups
Date: Tue, 17 Nov 2009 18:49:03 +0200
Message-ID: <200911171849.03870.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:9254 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752582AbZKQQwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 11:52:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 net/core/dev.c |   58 +++++++++++++------------------------------------------
 1 files changed, 14 insertions(+), 44 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 4b24d79..6226960 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -862,6 +862,9 @@ static int __dev_alloc_name(struct net *net, const char *name, char *buf)
 	unsigned long *inuse;
 	struct net_device *d;
 
+	if (!dev_valid_name(name))
+		return -EINVAL;
+
 	p = strnchr(name, IFNAMSIZ-1, '%');
 	if (p) {
 		/*
@@ -901,7 +904,9 @@ static int __dev_alloc_name(struct net *net, const char *name, char *buf)
 	 * when the name is long and there isn't enough space left
 	 * for the digits, or if all bits are used.
 	 */
-	return -ENFILE;
+	if (p)
+		return -ENFILE;
+	return -EEXIST;
 }
 
 /**
@@ -956,22 +961,14 @@ int dev_change_name(struct net_device *dev, const char *newname)
 	if (dev->flags & IFF_UP)
 		return -EBUSY;
 
-	if (!dev_valid_name(newname))
-		return -EINVAL;
-
 	if (strncmp(newname, dev->name, IFNAMSIZ) == 0)
 		return 0;
 
 	memcpy(oldname, dev->name, IFNAMSIZ);
 
-	if (strchr(newname, '%')) {
-		err = dev_alloc_name(dev, newname);
-		if (err < 0)
-			return err;
-	} else if (__dev_get_by_name(net, newname))
-		return -EEXIST;
-	else
-		strlcpy(dev->name, newname, IFNAMSIZ);
+	err = dev_alloc_name(dev, newname);
+	if (err < 0)
+		return err;
 
 rollback:
 	/* For now only devices in the initial network namespace
@@ -4864,8 +4861,6 @@ EXPORT_SYMBOL(netdev_fix_features);
 
 int register_netdevice(struct net_device *dev)
 {
-	struct hlist_head *head;
-	struct hlist_node *p;
 	int ret;
 	struct net *net = dev_net(dev);
 
@@ -4894,26 +4889,10 @@ int register_netdevice(struct net_device *dev)
 		}
 	}
 
-	if (!dev_valid_name(dev->name)) {
-		ret = -EINVAL;
-		goto err_uninit;
-	}
-
 	dev->ifindex = dev_new_index(net);
 	if (dev->iflink == -1)
 		dev->iflink = dev->ifindex;
 
-	/* Check for existence of name */
-	head = dev_name_hash(net, dev->name);
-	hlist_for_each(p, head) {
-		struct net_device *d
-			= hlist_entry(p, struct net_device, name_hlist);
-		if (!strncmp(d->name, dev->name, IFNAMSIZ)) {
-			ret = -EEXIST;
-			goto err_uninit;
-		}
-	}
-
 	/* Fix illegal checksum combinations */
 	if ((dev->features & NETIF_F_HW_CSUM) &&
 	    (dev->features & (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))) {
@@ -5038,11 +5017,9 @@ int register_netdev(struct net_device *dev)
 	 * If the name is a format string the caller wants us to do a
 	 * name allocation.
 	 */
-	if (strchr(dev->name, '%')) {
-		err = dev_alloc_name(dev, dev->name);
-		if (err < 0)
-			goto out;
-	}
+	err = dev_alloc_name(dev, dev->name);
+	if (err < 0)
+		goto out;
 
 	err = register_netdevice(dev);
 out:
@@ -5461,16 +5438,9 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 		/* We get here if we can't use the current device name */
 		if (!pat)
 			goto out;
-		if (!dev_valid_name(pat))
-			goto out;
-		if (strchr(pat, '%')) {
-			if (__dev_alloc_name(net, pat, buf) < 0)
-				goto out;
-			destname = buf;
-		} else
-			destname = pat;
-		if (__dev_get_by_name(net, destname))
+		if (__dev_alloc_name(net, pat, buf) < 0)
 			goto out;
+		destname = buf;
 	}
 
 	/*
-- 
1.5.6.5

