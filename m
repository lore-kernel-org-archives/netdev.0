From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][NETNS]: Fix arbitrary net_device-s corruptions on net_ns
 stop.
Date: Wed, 07 May 2008 12:08:56 +0400
Message-ID: <48216398.9050509@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:36731 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754100AbYEGILh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 May 2008 04:11:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a net namespace is destroyed, some devices (those, not killed
on ns stop explicitly) are moved back to init_net.

The problem, is that this net_ns change has one point of failure -
the __dev_alloc_name() may be called if a name collision occurs (and
this is easy to trigger). This allocator performs a likely-to-fail
GFP_ATOMIC allocation to find a suitable number. Other possible 
conditions that may cause error (for device being ns local or not
registered) are always false in this case.

So, when this call fails, the device is unregistered. But this is
*not* the right thing to do, since after this the device may be
released (and kfree-ed) improperly. E. g. bridges require more
actions (sysfs update, timer disarming, etc.), some other devices 
want to remove their private areas from lists, etc.

I. e. arbitrary use-after-free cases may occur.

The proposed fix is the following: since the only reason for the
dev_change_net_namespace to fail is the name generation, we may
give it a unique fall-back name w/o %d-s in it - the dev<ifindex>
one, since ifindexes are still unique.

So make this change, raise the failure-case printk loglevel to 
EMERG and replace the unregister_netdevice call with BUG().

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/core/dev.c b/net/core/dev.c
index d334446..86da6aa 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4480,17 +4480,19 @@ static void __net_exit default_device_exit(struct net *net)
 	rtnl_lock();
 	for_each_netdev_safe(net, dev, next) {
 		int err;
+		char fb_name[IFNAMSIZ];
 
 		/* Ignore unmoveable devices (i.e. loopback) */
 		if (dev->features & NETIF_F_NETNS_LOCAL)
 			continue;
 
 		/* Push remaing network devices to init_net */
-		err = dev_change_net_namespace(dev, &init_net, "dev%d");
+		sprintf(fb_name, "dev%d", dev->ifindex);
+		err = dev_change_net_namespace(dev, &init_net, fb_name);
 		if (err) {
-			printk(KERN_WARNING "%s: failed to move %s to init_net: %d\n",
+			printk(KERN_EMERG "%s: failed to move %s to init_net: %d\n",
 				__func__, dev->name, err);
-			unregister_netdevice(dev);
+			BUG();
 		}
 	}
 	rtnl_unlock();
