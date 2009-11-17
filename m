From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [net-next-2.6 PATCH] net: device name allocation cleanups
Date: Tue, 17 Nov 2009 22:33:53 +0200
Message-ID: <200911172233.53119.opurdila@ixiacom.com>
References: <200911171849.03870.opurdila@ixiacom.com> <20091117090157.2a07bed5@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:10983 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751920AbZKQUgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 15:36:54 -0500
In-Reply-To: <20091117090157.2a07bed5@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 17 November 2009 19:01:57 you wrote:
 
> You have merged the dev_alloc_name into all the registration paths.
> Before it was possible for device to call register_netdevice with a name
> with a % in it. Only if it did dev_alloc_name or register_netdev would
> the %d be interpreted.
> 
> So this patch causes a change which may be visible in user space.

Oops, didn't saw that coming :) How about this one?

(tested all code paths except the dev_change_net_namespace)

[net-next-2.6 PATCH] net: device name allocation cleanups

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 net/core/dev.c |   73 +++++++++++++++++++++----------------------------------
 1 files changed, 28 insertions(+), 45 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 4b24d79..eec13de 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -893,7 +893,8 @@ static int __dev_alloc_name(struct net *net, const char *name, char *buf)
 		free_page((unsigned long) inuse);
 	}
 
-	snprintf(buf, IFNAMSIZ, name, i);
+	if (buf != name)
+		snprintf(buf, IFNAMSIZ, name, i);
 	if (!__dev_get_by_name(net, buf))
 		return i;
 
@@ -933,6 +934,25 @@ int dev_alloc_name(struct net_device *dev, const char *name)
 }
 EXPORT_SYMBOL(dev_alloc_name);
 
+static int dev_get_valid_name(struct net *net, const char *name, char *buf,
+			      int fmt)
+{
+	if (!dev_valid_name(name))
+		return -EINVAL;
+
+	if (fmt) {
+		if (strchr(name, '%'))
+			return __dev_alloc_name(net, name, buf);
+	}
+
+	if (__dev_get_by_name(net, name))
+		return -EEXIST;
+	else
+		if (buf != name)
+			strlcpy(buf, name, IFNAMSIZ);
+
+	return 0;
+}
 
 /**
  *	dev_change_name - change name of a device
@@ -956,22 +976,14 @@ int dev_change_name(struct net_device *dev, const char *newname)
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
+	err = dev_get_valid_name(net, newname, dev->name, 1);
+	if (err < 0)
+		return err;
 
 rollback:
 	/* For now only devices in the initial network namespace
@@ -4864,8 +4876,6 @@ EXPORT_SYMBOL(netdev_fix_features);
 
 int register_netdevice(struct net_device *dev)
 {
-	struct hlist_head *head;
-	struct hlist_node *p;
 	int ret;
 	struct net *net = dev_net(dev);
 
@@ -4894,26 +4904,14 @@ int register_netdevice(struct net_device *dev)
 		}
 	}
 
-	if (!dev_valid_name(dev->name)) {
-		ret = -EINVAL;
+	ret = dev_get_valid_name(net, dev->name, dev->name, 0);
+	if (ret)
 		goto err_uninit;
-	}
 
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
@@ -5422,8 +5420,6 @@ EXPORT_SYMBOL(unregister_netdev);
 
 int dev_change_net_namespace(struct net_device *dev, struct net *net, const char *pat)
 {
-	char buf[IFNAMSIZ];
-	const char *destname;
 	int err;
 
 	ASSERT_RTNL();
@@ -5456,20 +5452,11 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	 * we can use it in the destination network namespace.
 	 */
 	err = -EEXIST;
-	destname = dev->name;
-	if (__dev_get_by_name(net, destname)) {
+	if (__dev_get_by_name(net, dev->name)) {
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
+		if (dev_get_valid_name(net, pat, dev->name, 1))
 			goto out;
 	}
 
@@ -5505,10 +5492,6 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	/* Actually switch the network namespace */
 	dev_net_set(dev, net);
 
-	/* Assign the new device name */
-	if (destname != dev->name)
-		strcpy(dev->name, destname);
-
 	/* If there is an ifindex conflict assign a new one */
 	if (__dev_get_by_index(net, dev->ifindex)) {
 		int iflink = (dev->iflink == dev->ifindex);
-- 
1.5.6.5

