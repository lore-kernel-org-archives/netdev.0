From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 1/2] net: Allow to create links with given ifindex
Date: Mon, 30 Jul 2012 08:34:55 +0400
Message-ID: <50160EEF.6050406@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:29439 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751735Ab2G3EfH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jul 2012 00:35:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the RTM_NEWLINK results in -EOPNOTSUPP if the ifinfomsg->ifi_index
is not zero. I propose to allow requesting ifindices on link creation. This
is required by the checkpoint-restore to correctly restore a net namespace
(i.e. -- a container). The question what to do with pre-created devices such
as lo or sit fbdev is open, but for manually created devices this can be 
solved by this patch.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---

diff --git a/net/core/dev.c b/net/core/dev.c
index 0ebaea1..5966e2f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5533,7 +5533,12 @@ int register_netdevice(struct net_device *dev)
 		}
 	}
 
-	dev->ifindex = dev_new_index(net);
+	ret = -EBUSY;
+	if (!dev->ifindex)
+		dev->ifindex = dev_new_index(net);
+	else if (__dev_get_by_index(net, dev->ifindex))
+		goto err_uninit;
+
 	if (dev->iflink == -1)
 		dev->iflink = dev->ifindex;
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 334b930..76e19aa 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1801,8 +1801,6 @@ replay:
 			return -ENODEV;
 		}
 
-		if (ifm->ifi_index)
-			return -EOPNOTSUPP;
 		if (tb[IFLA_MAP] || tb[IFLA_MASTER] || tb[IFLA_PROTINFO])
 			return -EOPNOTSUPP;
 
@@ -1828,10 +1826,14 @@ replay:
 			return PTR_ERR(dest_net);
 
 		dev = rtnl_create_link(net, dest_net, ifname, ops, tb);
-
-		if (IS_ERR(dev))
+		if (IS_ERR(dev)) {
 			err = PTR_ERR(dev);
-		else if (ops->newlink)
+			goto out;
+		}
+
+		dev->ifindex = ifm->ifi_index;
+
+		if (ops->newlink)
 			err = ops->newlink(net, dev, tb, data);
 		else
 			err = register_netdevice(dev);
