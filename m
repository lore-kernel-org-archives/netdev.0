From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] dev: advertise rx_flags changes
Date: Mon, 23 Sep 2013 16:25:34 +0200
Message-ID: <1379946334-4183-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:32904 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752272Ab3IWOZo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 10:25:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no netlink message/call to notifier chains when rx_flags are updated,
let's advertise everybody.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/core/dev.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 5c713f2239cc..6c91d3919279 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4818,8 +4818,13 @@ static void dev_change_rx_flags(struct net_device *dev, int flags)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
 
-	if ((dev->flags & IFF_UP) && ops->ndo_change_rx_flags)
-		ops->ndo_change_rx_flags(dev, flags);
+	if (dev->flags & IFF_UP) {
+		if (ops->ndo_change_rx_flags)
+			ops->ndo_change_rx_flags(dev, flags);
+
+		call_netdevice_notifiers(NETDEV_CHANGE, dev);
+		rtmsg_ifinfo(RTM_NEWLINK, dev, flags);
+	}
 }
 
 static int __dev_set_promiscuity(struct net_device *dev, int inc)
-- 
1.8.2.1
