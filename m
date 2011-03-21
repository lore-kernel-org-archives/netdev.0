From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] macvlan: Fix use after free of struct macvlan_port.
Date: Mon, 21 Mar 2011 14:15:31 -0700
Message-ID: <m1aagojhu4.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>,
	Ben Greear <greearb@candelatech.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:50621 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753131Ab1CUVPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 17:15:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When the macvlan driver was extended to call unregisgter_netdevice_queue
in 23289a37e2b127dfc4de1313fba15bb4c9f0cd5b, a use after free of struct
macvlan_port was introduced.  The code in dellink relied on unregister_netdevice
actually unregistering the net device so it would be safe to free macvlan_port.

Since unregister_netdevice_queue can just queue up the unregister instead of
performing the unregiser immediately we free the macvlan_port too soon and
then the code in macvlan_stop removes the macaddress for the set of macaddress
to listen for and uses memory that has already been freed.

To fix this add a reference count to track when it is safe to free the macvlan_port
and move the call of macvlan_port_destroy into macvlan_uninit which is guaranteed
to be called after the final macvlan_port_close.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 drivers/net/macvlan.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 5b37d3c..78e34e9 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -39,8 +39,11 @@ struct macvlan_port {
 	struct list_head	vlans;
 	struct rcu_head		rcu;
 	bool 			passthru;
+	int			count;
 };
 
+static void macvlan_port_destroy(struct net_device *dev);
+
 #define macvlan_port_get_rcu(dev) \
 	((struct macvlan_port *) rcu_dereference(dev->rx_handler_data))
 #define macvlan_port_get(dev) ((struct macvlan_port *) dev->rx_handler_data)
@@ -457,8 +460,13 @@ static int macvlan_init(struct net_device *dev)
 static void macvlan_uninit(struct net_device *dev)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
+	struct macvlan_port *port = vlan->port;
 
 	free_percpu(vlan->pcpu_stats);
+
+	port->count -= 1;
+	if (!port->count)
+		macvlan_port_destroy(port->dev);
 }
 
 static struct rtnl_link_stats64 *macvlan_dev_get_stats64(struct net_device *dev,
@@ -691,12 +699,13 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 		vlan->mode = nla_get_u32(data[IFLA_MACVLAN_MODE]);
 
 	if (vlan->mode == MACVLAN_MODE_PASSTHRU) {
-		if (!list_empty(&port->vlans))
+		if (port->count)
 			return -EINVAL;
 		port->passthru = true;
 		memcpy(dev->dev_addr, lowerdev->dev_addr, ETH_ALEN);
 	}
 
+	port->count += 1;
 	err = register_netdevice(dev);
 	if (err < 0)
 		goto destroy_port;
@@ -707,7 +716,8 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 	return 0;
 
 destroy_port:
-	if (list_empty(&port->vlans))
+	port->count -= 1;
+	if (!port->count)
 		macvlan_port_destroy(lowerdev);
 
 	return err;
@@ -725,13 +735,9 @@ static int macvlan_newlink(struct net *src_net, struct net_device *dev,
 void macvlan_dellink(struct net_device *dev, struct list_head *head)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
-	struct macvlan_port *port = vlan->port;
 
 	list_del(&vlan->list);
 	unregister_netdevice_queue(dev, head);
-
-	if (list_empty(&port->vlans))
-		macvlan_port_destroy(port->dev);
 }
 EXPORT_SYMBOL_GPL(macvlan_dellink);
 
-- 
1.7.4

