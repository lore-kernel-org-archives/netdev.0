From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH] bridge: call br_netpoll_disable in br_add_if
Date: Thu, 20 Dec 2012 17:41:43 +0800
Message-ID: <1355996503-19318-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: amwang@redhat.com, shemminger@vyatta.com, davem@davemloft.net,
	Gao feng <gaofeng@cn.fujitsu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:19418 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750956Ab2LTJuo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2012 04:50:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When netdev_set_master faild in br_add_if, we should
call br_netpoll_disable to do some cleanup jobs,such
as free the memory of struct netpoll which allocated
in br_netpoll_enable.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/bridge/br_if.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 1c8fdc3..37fe693 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -366,11 +366,11 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 
 	err = netdev_set_master(dev, br->dev);
 	if (err)
-		goto err3;
+		goto err4;
 
 	err = netdev_rx_handler_register(dev, br_handle_frame, p);
 	if (err)
-		goto err4;
+		goto err5;
 
 	dev->priv_flags |= IFF_BRIDGE_PORT;
 
@@ -402,8 +402,10 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 
 	return 0;
 
-err4:
+err5:
 	netdev_set_master(dev, NULL);
+err4:
+	br_netpoll_disable(p);
 err3:
 	sysfs_remove_link(br->ifobj, p->dev->name);
 err2:
-- 
1.7.7.6
