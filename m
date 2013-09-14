From: Hong Zhiguo <honkiko@gmail.com>
Subject: [PATCH net-next 2/2] bridge: fix NULL pointer deref of br_port_get_rcu
Date: Sat, 14 Sep 2013 22:42:28 +0800
Message-ID: <1379169748-767-3-git-send-email-zhiguohong@tencent.com>
References: <1379169748-767-1-git-send-email-zhiguohong@tencent.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, vyasevic@redhat.com,
	Hong Zhiguo <zhiguohong@tencent.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:55593 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932084Ab3INOoo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Sep 2013 10:44:44 -0400
Received: by mail-pd0-f181.google.com with SMTP id g10so2384912pdj.40
        for <netdev@vger.kernel.org>; Sat, 14 Sep 2013 07:44:44 -0700 (PDT)
In-Reply-To: <1379169748-767-1-git-send-email-zhiguohong@tencent.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hong Zhiguo <zhiguohong@tencent.com>

The NULL deref happens when br_handle_frame is called between these
2 lines of del_nbp:
	dev->priv_flags &= ~IFF_BRIDGE_PORT;
	/* --> br_handle_frame is called at this time */
	netdev_rx_handler_unregister(dev);

In br_handle_frame the return of br_port_get_rcu(dev) is dereferenced
without check but br_port_get_rcu(dev) returns NULL if:
	!(dev->priv_flags & IFF_BRIDGE_PORT)

Eric Dumazet pointed out the testing of IFF_BRIDGE_PORT is not necessary
here since we're in rcu_read_lock and we have synchronize_net() in
netdev_rx_handler_unregister. So remove the testing of IFF_BRIDGE_PORT
and by the previous patch, make sure br_port_get_rcu is called in
bridging code.

Signed-off-by: Hong Zhiguo <zhiguohong@tencent.com>
---
 net/bridge/br_private.h | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 49fb43e..1aaca0e 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -202,10 +202,7 @@ struct net_bridge_port
 
 static inline struct net_bridge_port *br_port_get_rcu(const struct net_device *dev)
 {
-	struct net_bridge_port *port =
-			rcu_dereference_rtnl(dev->rx_handler_data);
-
-	return br_port_exists(dev) ? port : NULL;
+	return rcu_dereference(dev->rx_handler_data);
 }
 
 static inline struct net_bridge_port *br_port_get_rtnl(const struct net_device *dev)
-- 
1.8.1.2
