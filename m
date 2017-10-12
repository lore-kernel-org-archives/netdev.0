From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next v2 7/7] net: qualcomm: rmnet: Implement bridge mode
Date: Wed, 11 Oct 2017 18:43:58 -0600
Message-ID: <1507769038-30231-8-git-send-email-subashab@codeaurora.org>
References: <1507769038-30231-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:33398 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752767AbdJLAoZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 20:44:25 -0400
In-Reply-To: <1507769038-30231-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to bridge two devices which can send multiplexing and
aggregation (MAP) data. This is done only when the data itself is
not going to be consumed in the stack but is being passed on to a
different endpoint. This is mainly used for testing.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c | 93 +++++++++++++++++++++-
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h |  7 +-
 .../net/ethernet/qualcomm/rmnet/rmnet_handlers.c   | 26 +++++-
 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c    |  2 +
 4 files changed, 122 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
index b5fe3f4..71bee1a 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
@@ -109,6 +109,36 @@ static int rmnet_register_real_device(struct net_device *real_dev)
 	return 0;
 }
 
+static void rmnet_unregister_bridge(struct net_device *dev,
+				    struct rmnet_port *port)
+{
+	struct net_device *rmnet_dev, *bridge_dev;
+	struct rmnet_port *bridge_port;
+
+	if (port->rmnet_mode != RMNET_EPMODE_BRIDGE)
+		return;
+
+	/* bridge slave handling */
+	if (!port->nr_rmnet_devs) {
+		rmnet_dev = netdev_master_upper_dev_get_rcu(dev);
+		netdev_upper_dev_unlink(dev, rmnet_dev);
+
+		bridge_dev = port->bridge_ep;
+
+		bridge_port = rmnet_get_port_rtnl(bridge_dev);
+		bridge_port->bridge_ep = NULL;
+		bridge_port->rmnet_mode = RMNET_EPMODE_VND;
+	} else {
+		bridge_dev = port->bridge_ep;
+
+		bridge_port = rmnet_get_port_rtnl(bridge_dev);
+		rmnet_dev = netdev_master_upper_dev_get_rcu(bridge_dev);
+		netdev_upper_dev_unlink(bridge_dev, rmnet_dev);
+
+		rmnet_unregister_real_device(bridge_dev, bridge_port);
+	}
+}
+
 static int rmnet_newlink(struct net *src_net, struct net_device *dev,
 			 struct nlattr *tb[], struct nlattr *data[],
 			 struct netlink_ext_ack *extack)
@@ -190,10 +220,10 @@ static void rmnet_dellink(struct net_device *dev, struct list_head *head)
 	ep = rmnet_get_endpoint(port, mux_id);
 	if (ep) {
 		hlist_del_init_rcu(&ep->hlnode);
+		rmnet_unregister_bridge(dev, port);
 		rmnet_vnd_dellink(mux_id, port, ep);
 		kfree(ep);
 	}
-
 	rmnet_unregister_real_device(real_dev, port);
 
 	unregister_netdevice_queue(dev, head);
@@ -237,6 +267,8 @@ static void rmnet_force_unassociate_device(struct net_device *dev)
 	d.port = port;
 
 	rcu_read_lock();
+	rmnet_unregister_bridge(dev, port);
+
 	netdev_walk_all_lower_dev_rcu(real_dev, rmnet_dev_walk_unreg, &d);
 	rcu_read_unlock();
 	unregister_netdevice_many(&list);
@@ -321,6 +353,65 @@ struct rmnet_endpoint *rmnet_get_endpoint(struct rmnet_port *port, u8 mux_id)
 	return NULL;
 }
 
+int rmnet_add_bridge(struct net_device *rmnet_dev,
+		     struct net_device *slave_dev,
+		     struct netlink_ext_ack *extack)
+{
+	struct rmnet_priv *priv = netdev_priv(rmnet_dev);
+	struct net_device *real_dev = priv->real_dev;
+	struct rmnet_port *port, *slave_port;
+	int err;
+
+	port = rmnet_get_port(real_dev);
+
+	/* If there is more than one rmnet dev attached, its probably being
+	 * used for muxing. Skip the briding in that case
+	 */
+	if (port->nr_rmnet_devs > 1)
+		return -EINVAL;
+
+	if (rmnet_is_real_dev_registered(slave_dev))
+		return -EBUSY;
+
+	err = rmnet_register_real_device(slave_dev);
+	if (err)
+		return -EBUSY;
+
+	err = netdev_master_upper_dev_link(slave_dev, rmnet_dev, NULL, NULL,
+					   extack);
+	if (err)
+		return -EINVAL;
+
+	slave_port = rmnet_get_port(slave_dev);
+	slave_port->rmnet_mode = RMNET_EPMODE_BRIDGE;
+	slave_port->bridge_ep = real_dev;
+
+	port->rmnet_mode = RMNET_EPMODE_BRIDGE;
+	port->bridge_ep = slave_dev;
+
+	netdev_dbg(slave_dev, "registered with rmnet as slave\n");
+	return 0;
+}
+
+int rmnet_del_bridge(struct net_device *rmnet_dev,
+		     struct net_device *slave_dev)
+{
+	struct rmnet_priv *priv = netdev_priv(rmnet_dev);
+	struct net_device *real_dev = priv->real_dev;
+	struct rmnet_port *port, *slave_port;
+
+	port = rmnet_get_port(real_dev);
+	port->rmnet_mode = RMNET_EPMODE_VND;
+	port->bridge_ep = NULL;
+
+	netdev_upper_dev_unlink(slave_dev, rmnet_dev);
+	slave_port = rmnet_get_port(slave_dev);
+	rmnet_unregister_real_device(slave_dev, slave_port);
+
+	netdev_dbg(slave_dev, "removed from rmnet as slave\n");
+	return 0;
+}
+
 /* Startup/Shutdown */
 
 static int __init rmnet_init(void)
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
index 8849986..60115e6 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
@@ -36,6 +36,7 @@ struct rmnet_port {
 	u8 nr_rmnet_devs;
 	u8 rmnet_mode;
 	struct hlist_head muxed_ep[RMNET_MAX_LOGICAL_EP];
+	struct net_device *bridge_ep;
 };
 
 extern struct rtnl_link_ops rmnet_link_ops;
@@ -47,5 +48,9 @@ struct rmnet_priv {
 
 struct rmnet_port *rmnet_get_port(struct net_device *real_dev);
 struct rmnet_endpoint *rmnet_get_endpoint(struct rmnet_port *port, u8 mux_id);
-
+int rmnet_add_bridge(struct net_device *rmnet_dev,
+		     struct net_device *slave_dev,
+		     struct netlink_ext_ack *extack);
+int rmnet_del_bridge(struct net_device *rmnet_dev,
+		     struct net_device *slave_dev);
 #endif /* _RMNET_CONFIG_H_ */
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
index fa24ffb..df3d2d1 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
@@ -149,6 +149,17 @@ static int rmnet_map_egress_handler(struct sk_buff *skb,
 	return RMNET_MAP_SUCCESS;
 }
 
+static rx_handler_result_t
+rmnet_bridge_handler(struct sk_buff *skb, struct net_device *bridge_dev)
+{
+	if (bridge_dev) {
+		skb->dev = bridge_dev;
+		dev_queue_xmit(skb);
+	}
+
+	return RX_HANDLER_CONSUMED;
+}
+
 /* Ingress / Egress Entry Points */
 
 /* Processes packet as per ingress data format for receiving device. Logical
@@ -157,10 +168,10 @@ static int rmnet_map_egress_handler(struct sk_buff *skb,
  */
 rx_handler_result_t rmnet_rx_handler(struct sk_buff **pskb)
 {
-	struct rmnet_port *port;
+	int rc = RX_HANDLER_CONSUMED;
 	struct sk_buff *skb = *pskb;
+	struct rmnet_port *port;
 	struct net_device *dev;
-	int rc;
 
 	if (!skb)
 		return RX_HANDLER_CONSUMED;
@@ -168,8 +179,15 @@ rx_handler_result_t rmnet_rx_handler(struct sk_buff **pskb)
 	dev = skb->dev;
 	port = rmnet_get_port(dev);
 
-	if (port->ingress_data_format & RMNET_INGRESS_FORMAT_MAP)
-		rc = rmnet_map_ingress_handler(skb, port);
+	switch (port->rmnet_mode) {
+	case RMNET_EPMODE_VND:
+		if (port->ingress_data_format & RMNET_INGRESS_FORMAT_MAP)
+			rc = rmnet_map_ingress_handler(skb, port);
+		break;
+	case RMNET_EPMODE_BRIDGE:
+		rc = rmnet_bridge_handler(skb, port->bridge_ep);
+		break;
+	}
 
 	return rc;
 }
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
index 1b6747d..12bd0bb 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
@@ -74,6 +74,8 @@ static int rmnet_vnd_get_iflink(const struct net_device *dev)
 	.ndo_start_xmit = rmnet_vnd_start_xmit,
 	.ndo_change_mtu = rmnet_vnd_change_mtu,
 	.ndo_get_iflink = rmnet_vnd_get_iflink,
+	.ndo_add_slave  = rmnet_add_bridge,
+	.ndo_del_slave  = rmnet_del_bridge,
 };
 
 /* Called by kernel whenever a new rmnet<n> device is created. Sets MTU,
-- 
1.9.1
