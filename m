From: Serhey Popovych <serhe.popovych@gmail.com>
Subject: [PATCH 2/3] dev: Avoid infinite loop on network device index exhaustion
Date: Fri, 16 Jun 2017 17:23:52 +0300
Message-ID: <a6cc35519e46dc988a983f4b167ccd420b42a0fa.1497621810.git.serhe.popovych@gmail.com>
References: <cover.1497621810.git.serhe.popovych@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:33101 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754094AbdFPOYW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 10:24:22 -0400
Received: by mail-lf0-f66.google.com with SMTP id u62so4370720lfg.0
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 07:24:21 -0700 (PDT)
Received: from tuxracer.synapse.com ([195.238.92.77])
        by smtp.gmail.com with ESMTPSA id z10sm486566lja.6.2017.06.16.07.24.19
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 07:24:20 -0700 (PDT)
In-Reply-To: <cover.1497621810.git.serhe.popovych@gmail.com>
In-Reply-To: <cover.1497621810.git.serhe.popovych@gmail.com>
References: <cover.1497621810.git.serhe.popovych@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If network device indexes exhaust in namespace dev_new_index()
can loop indefinitely since there is no condition to exit
except case where free index is found.

Since all it's caller hold RTNL mutex this may completely
lock down network subsystem configuration operations.

Instead of retrying with ifindex == 1 (LOOPBACK_IFINDEX)
in dev_new_index() we should fail and return invalid
index value (0).

Adjust callers to correctly handle error case of dev_new_index().

Signed-off-by: Serhey Popovych <serhe.popovych@gmail.com>
---
 net/core/dev.c | 30 ++++++++++++++++++++++--------
 1 file changed, 22 insertions(+), 8 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index dae8010..6f573f7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7014,7 +7014,9 @@ int dev_change_xdp_fd(struct net_device *dev, struct netlink_ext_ack *extack,
  *	@net: the applicable net namespace
  *
  *	Returns a suitable unique value for a new device interface
- *	number.  The caller must hold the rtnl semaphore or the
+ *	number or zero in case of no free indexes in net namespace.
+ *
+ *	The caller must hold the rtnl mutex or the
  *	dev_base_lock to be sure it remains unique.
  */
 static int dev_new_index(struct net *net)
@@ -7023,7 +7025,7 @@ static int dev_new_index(struct net *net)
 
 	for (;;) {
 		if (++ifindex <= 0)
-			ifindex = 1;
+			return 0;
 		if (!__dev_get_by_index(net, ifindex))
 			return net->ifindex = ifindex;
 	}
@@ -7491,9 +7493,12 @@ int register_netdevice(struct net_device *dev)
 	}
 
 	ret = -EBUSY;
-	if (dev->ifindex <= 0)
-		dev->ifindex = dev_new_index(net);
-	else if (__dev_get_by_index(net, dev->ifindex))
+	if (dev->ifindex <= 0) {
+		int ifindex = dev_new_index(net);
+		if (!ifindex)
+			goto err_uninit;
+		dev->ifindex = ifindex;
+	} else if (__dev_get_by_index(net, dev->ifindex))
 		goto err_uninit;
 
 	/* Transfer changeable features to wanted_features and enable
@@ -8174,6 +8179,7 @@ void unregister_netdev(struct net_device *dev)
 
 int dev_change_net_namespace(struct net_device *dev, struct net *net, const char *pat)
 {
+	int ifindex = 0;
 	int err;
 
 	ASSERT_RTNL();
@@ -8192,6 +8198,14 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	if (net_eq(dev_net(dev), net))
 		goto out;
 
+	/* If there is an ifindex conflict assign a new one */
+	err = -EBUSY;
+	if (__dev_get_by_index(net, dev->ifindex)) {
+		ifindex = dev_new_index(net);
+		if (!ifindex)
+			goto out;
+	}
+
 	/* Pick the destination device name, and ensure
 	 * we can use it in the destination network namespace.
 	 */
@@ -8245,9 +8259,9 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	/* Actually switch the network namespace */
 	dev_net_set(dev, net);
 
-	/* If there is an ifindex conflict assign a new one */
-	if (__dev_get_by_index(net, dev->ifindex))
-		dev->ifindex = dev_new_index(net);
+	/* Actually change the ifindex */
+	if (ifindex)
+		dev->ifindex = ifindex;
 
 	/* Send a netdev-add uevent to the new namespace */
 	kobject_uevent(&dev->dev.kobj, KOBJ_ADD);
-- 
1.8.3.1
