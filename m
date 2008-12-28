From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] netns: foreach_netdev_safe is insufficient in default_device_exit
Date: Sun, 28 Dec 2008 00:10:35 -0800
Message-ID: <m1y6y04t50.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:43908 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751789AbYL1IRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Dec 2008 03:17:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


During network namespace teardown we either move or delete
all of the network devices associated with a network namespace.
In the case of veth devices deleting one will also delete it's
pair device.  If both devices are in the same network namespace
then for_each_netdev_safe is insufficient as next may point
to the second veth device we have deleted.

To avoid problems I do what we do in __rtnl_kill_links and
restart the scan of the device list, after we have deleted
a device.

Currently dev_change_netnamespace does not appear to suffer from
this problem, but wireless devices are also paired and likely
should be moved between network namespaces together.  So I have
errored on the side of caution and restart the scan of the network
devices in that case as well.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 net/core/dev.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index daca72e..1f154d2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5059,13 +5059,14 @@ static struct pernet_operations __net_initdata netdev_net_ops = {
 
 static void __net_exit default_device_exit(struct net *net)
 {
-	struct net_device *dev, *next;
+	struct net_device *dev;
 	/*
 	 * Push all migratable of the network devices back to the
 	 * initial network namespace
 	 */
 	rtnl_lock();
-	for_each_netdev_safe(net, dev, next) {
+restart:
+	for_each_netdev(net, dev) {
 		int err;
 		char fb_name[IFNAMSIZ];
 
@@ -5076,7 +5077,7 @@ static void __net_exit default_device_exit(struct net *net)
 		/* Delete virtual devices */
 		if (dev->rtnl_link_ops && dev->rtnl_link_ops->dellink) {
 			dev->rtnl_link_ops->dellink(dev);
-			continue;
+			goto restart;
 		}
 
 		/* Push remaing network devices to init_net */
@@ -5087,6 +5088,7 @@ static void __net_exit default_device_exit(struct net *net)
 				__func__, dev->name, err);
 			BUG();
 		}
+		goto restart;
 	}
 	rtnl_unlock();
 }
-- 
1.5.3.rc6.17.g1911

