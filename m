From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] macvlan: use the right RCU api
Date: Sat, 30 Mar 2013 13:08:44 -0700
Message-ID: <1364674124.5113.132.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:62072 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757077Ab3C3UIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Mar 2013 16:08:48 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz11so791005pad.16
        for <netdev@vger.kernel.org>; Sat, 30 Mar 2013 13:08:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Make sure we use proper API to fetch dev->rx_handler_data,
instead of ugly casts.

Rename macvlan_port_get() to macvlan_port_get_rtnl() to document fact
that we hold RTNL when needed, with lockdep support.

This removes sparse warnings as well (CONFIG_SPARSE_RCU_POINTER=y)

CHECK   drivers/net/macvlan.c
drivers/net/macvlan.c:706:37: warning: cast removes address space of expression
drivers/net/macvlan.c:775:16: warning: cast removes address space of expression
drivers/net/macvlan.c:924:16: warning: cast removes address space of expression

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/macvlan.c |   19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 73abbc1..70af6dc 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -46,9 +46,16 @@ struct macvlan_port {
 
 static void macvlan_port_destroy(struct net_device *dev);
 
-#define macvlan_port_get_rcu(dev) \
-	((struct macvlan_port *) rcu_dereference(dev->rx_handler_data))
-#define macvlan_port_get(dev) ((struct macvlan_port *) dev->rx_handler_data)
+static struct macvlan_port *macvlan_port_get_rcu(const struct net_device *dev)
+{
+	return rcu_dereference(dev->rx_handler_data);
+}
+
+static struct macvlan_port *macvlan_port_get_rtnl(const struct net_device *dev)
+{
+	return rtnl_dereference(dev->rx_handler_data);
+}
+
 #define macvlan_port_exists(dev) (dev->priv_flags & IFF_MACVLAN_PORT)
 
 static struct macvlan_dev *macvlan_hash_lookup(const struct macvlan_port *port,
@@ -703,7 +710,7 @@ static int macvlan_port_create(struct net_device *dev)
 
 static void macvlan_port_destroy(struct net_device *dev)
 {
-	struct macvlan_port *port = macvlan_port_get(dev);
+	struct macvlan_port *port = macvlan_port_get_rtnl(dev);
 
 	dev->priv_flags &= ~IFF_MACVLAN_PORT;
 	netdev_rx_handler_unregister(dev);
@@ -772,7 +779,7 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 		if (err < 0)
 			return err;
 	}
-	port = macvlan_port_get(lowerdev);
+	port = macvlan_port_get_rtnl(lowerdev);
 
 	/* Only 1 macvlan device can be created in passthru mode */
 	if (port->passthru)
@@ -921,7 +928,7 @@ static int macvlan_device_event(struct notifier_block *unused,
 	if (!macvlan_port_exists(dev))
 		return NOTIFY_DONE;
 
-	port = macvlan_port_get(dev);
+	port = macvlan_port_get_rtnl(dev);
 
 	switch (event) {
 	case NETDEV_CHANGE:
