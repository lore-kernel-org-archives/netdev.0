From: fgao@ikuai8.com
Subject: [PATCH net-next v3 1/1] driver: ipvlan: Free ipvl_port directly with kfree instead of kfree_rcu
Date: Wed,  7 Dec 2016 08:44:47 +0800
Message-ID: <1481071487-11227-1-git-send-email-fgao@ikuai8.com>
Cc: Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, maheshb@google.com, edumazet@google.com,
        netdev@vger.kernel.org, gfree.wind@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg340.qq.com ([14.17.44.35]:37633 "EHLO smtpbg340.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753170AbcLGApL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Dec 2016 19:45:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

There are two functions which would free the ipvl_port now. The first
is ipvlan_port_create. It frees the ipvl_port in the error handler,
so it could kfree it directly. The second is ipvlan_port_destroy. It
invokes netdev_rx_handler_unregister which enforces one grace period
by synchronize_net firstly, so it also could kfree the ipvl_port
directly and safely.

So it is unnecessary to use kfree_rcu to free ipvl_port.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 v3: Add more detail comments
 v2: Remove the rcu of ipvl_port directly
 v1: Initial patch

 drivers/net/ipvlan/ipvlan.h      | 1 -
 drivers/net/ipvlan/ipvlan_main.c | 4 ++--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
index 05a62d2..031093e 100644
--- a/drivers/net/ipvlan/ipvlan.h
+++ b/drivers/net/ipvlan/ipvlan.h
@@ -97,7 +97,6 @@ struct ipvl_port {
 	struct work_struct	wq;
 	struct sk_buff_head	backlog;
 	int			count;
-	struct rcu_head		rcu;
 };
 
 static inline struct ipvl_port *ipvlan_port_get_rcu(const struct net_device *d)
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index c6aa667..44ceebc 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -128,7 +128,7 @@ static int ipvlan_port_create(struct net_device *dev)
 	return 0;
 
 err:
-	kfree_rcu(port, rcu);
+	kfree(port);
 	return err;
 }
 
@@ -145,7 +145,7 @@ static void ipvlan_port_destroy(struct net_device *dev)
 	netdev_rx_handler_unregister(dev);
 	cancel_work_sync(&port->wq);
 	__skb_queue_purge(&port->backlog);
-	kfree_rcu(port, rcu);
+	kfree(port);
 }
 
 #define IPVLAN_FEATURES \
-- 
1.9.1
