From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 8/8 net-2.6.26] [NETNS]: Add netns refcnt debug for network devices.
Date: Tue, 15 Apr 2008 16:37:55 +0400
Message-ID: <1208263075-28016-8-git-send-email-den@openvz.org>
References: <1208262959.21529.32.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	dlezcano@fr.ibm.com, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:42678 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758947AbYDOMjQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 08:39:16 -0400
In-Reply-To: <1208262959.21529.32.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_set_net is called for
- just allocated devices
- devices moving from one namespace to another
release_net has proper check inside to distinguish these cases.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/linux/netdevice.h |    3 ++-
 net/core/dev.c            |    2 ++
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8b17ed4..7c1d446 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -758,7 +758,8 @@ static inline
 void dev_net_set(struct net_device *dev, struct net *net)
 {
 #ifdef CONFIG_NET_NS
-	dev->nd_net = net;
+	release_net(dev->nd_net);
+	dev->nd_net = hold_net(net);
 #endif
 }
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 7aa0112..77530e9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4042,6 +4042,8 @@ EXPORT_SYMBOL(alloc_netdev_mq);
  */
 void free_netdev(struct net_device *dev)
 {
+	release_net(dev_net(dev));
+
 	/*  Compatibility with error handling in drivers */
 	if (dev->reg_state == NETREG_UNINITIALIZED) {
 		kfree((char *)dev - dev->padded);
-- 
1.5.3.rc5

