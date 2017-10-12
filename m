From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next v2 6/7] net: qualcomm: rmnet: Convert the muxed endpoint to hlist
Date: Wed, 11 Oct 2017 18:43:57 -0600
Message-ID: <1507769038-30231-7-git-send-email-subashab@codeaurora.org>
References: <1507769038-30231-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        Dan Williams <dcbw@redhat.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:33334 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752626AbdJLAoY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 20:44:24 -0400
In-Reply-To: <1507769038-30231-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than using a static array, use a hlist to store the muxed
endpoints and use the mux id to query the rmnet_device.
This is useful as usually very few mux ids are used.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Cc: Dan Williams <dcbw@redhat.com>
---
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c | 75 ++++++++++++----------
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h |  4 +-
 .../net/ethernet/qualcomm/rmnet/rmnet_handlers.c   | 17 +++--
 .../ethernet/qualcomm/rmnet/rmnet_map_command.c    |  4 +-
 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c    | 15 +++--
 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h    |  6 +-
 6 files changed, 68 insertions(+), 53 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
index 96058bb..b5fe3f4 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
@@ -61,18 +61,6 @@ static int rmnet_is_real_dev_registered(const struct net_device *real_dev)
 	return rtnl_dereference(real_dev->rx_handler_data);
 }
 
-static struct rmnet_endpoint*
-rmnet_get_endpoint(struct net_device *dev, int config_id)
-{
-	struct rmnet_endpoint *ep;
-	struct rmnet_port *port;
-
-	port = rmnet_get_port_rtnl(dev);
-	ep = &port->muxed_ep[config_id];
-
-	return ep;
-}
-
 static int rmnet_unregister_real_device(struct net_device *real_dev,
 					struct rmnet_port *port)
 {
@@ -93,7 +81,7 @@ static int rmnet_unregister_real_device(struct net_device *real_dev,
 static int rmnet_register_real_device(struct net_device *real_dev)
 {
 	struct rmnet_port *port;
-	int rc;
+	int rc, entry;
 
 	ASSERT_RTNL();
 
@@ -114,26 +102,13 @@ static int rmnet_register_real_device(struct net_device *real_dev)
 	/* hold on to real dev for MAP data */
 	dev_hold(real_dev);
 
+	for (entry = 0; entry < RMNET_MAX_LOGICAL_EP; entry++)
+		INIT_HLIST_HEAD(&port->muxed_ep[entry]);
+
 	netdev_dbg(real_dev, "registered with rmnet\n");
 	return 0;
 }
 
-static void rmnet_set_endpoint_config(struct net_device *dev,
-				      u8 mux_id, struct net_device *egress_dev)
-{
-	struct rmnet_endpoint *ep;
-
-	netdev_dbg(dev, "id %d dev %s\n", mux_id, egress_dev->name);
-
-	ep = rmnet_get_endpoint(dev, mux_id);
-	/* This config is cleared on every set, so its ok to not
-	 * clear it on a device delete.
-	 */
-	memset(ep, 0, sizeof(struct rmnet_endpoint));
-	ep->egress_dev = egress_dev;
-	ep->mux_id = mux_id;
-}
-
 static int rmnet_newlink(struct net *src_net, struct net_device *dev,
 			 struct nlattr *tb[], struct nlattr *data[],
 			 struct netlink_ext_ack *extack)
@@ -145,6 +120,7 @@ static int rmnet_newlink(struct net *src_net, struct net_device *dev,
 			    RMNET_EGRESS_FORMAT_MAP;
 	struct net_device *real_dev;
 	int mode = RMNET_EPMODE_VND;
+	struct rmnet_endpoint *ep;
 	struct rmnet_port *port;
 	int err = 0;
 	u16 mux_id;
@@ -156,6 +132,10 @@ static int rmnet_newlink(struct net *src_net, struct net_device *dev,
 	if (!data[IFLA_VLAN_ID])
 		return -EINVAL;
 
+	ep = kzalloc(sizeof(*ep), GFP_ATOMIC);
+	if (!ep)
+		return -ENOMEM;
+
 	mux_id = nla_get_u16(data[IFLA_VLAN_ID]);
 
 	err = rmnet_register_real_device(real_dev);
@@ -163,7 +143,7 @@ static int rmnet_newlink(struct net *src_net, struct net_device *dev,
 		goto err0;
 
 	port = rmnet_get_port_rtnl(real_dev);
-	err = rmnet_vnd_newlink(mux_id, dev, port, real_dev);
+	err = rmnet_vnd_newlink(mux_id, dev, port, real_dev, ep);
 	if (err)
 		goto err1;
 
@@ -177,11 +157,11 @@ static int rmnet_newlink(struct net *src_net, struct net_device *dev,
 	port->ingress_data_format = ingress_format;
 	port->rmnet_mode = mode;
 
-	rmnet_set_endpoint_config(real_dev, mux_id, dev);
+	hlist_add_head_rcu(&ep->hlnode, &port->muxed_ep[mux_id]);
 	return 0;
 
 err2:
-	rmnet_vnd_dellink(mux_id, port);
+	rmnet_vnd_dellink(mux_id, port, ep);
 err1:
 	rmnet_unregister_real_device(real_dev, port);
 err0:
@@ -191,6 +171,7 @@ static int rmnet_newlink(struct net *src_net, struct net_device *dev,
 static void rmnet_dellink(struct net_device *dev, struct list_head *head)
 {
 	struct net_device *real_dev;
+	struct rmnet_endpoint *ep;
 	struct rmnet_port *port;
 	u8 mux_id;
 
@@ -204,8 +185,15 @@ static void rmnet_dellink(struct net_device *dev, struct list_head *head)
 	port = rmnet_get_port_rtnl(real_dev);
 
 	mux_id = rmnet_vnd_get_mux(dev);
-	rmnet_vnd_dellink(mux_id, port);
 	netdev_upper_dev_unlink(dev, real_dev);
+
+	ep = rmnet_get_endpoint(port, mux_id);
+	if (ep) {
+		hlist_del_init_rcu(&ep->hlnode);
+		rmnet_vnd_dellink(mux_id, port, ep);
+		kfree(ep);
+	}
+
 	rmnet_unregister_real_device(real_dev, port);
 
 	unregister_netdevice_queue(dev, head);
@@ -214,11 +202,16 @@ static void rmnet_dellink(struct net_device *dev, struct list_head *head)
 static int rmnet_dev_walk_unreg(struct net_device *rmnet_dev, void *data)
 {
 	struct rmnet_walk_data *d = data;
+	struct rmnet_endpoint *ep;
 	u8 mux_id;
 
 	mux_id = rmnet_vnd_get_mux(rmnet_dev);
-
-	rmnet_vnd_dellink(mux_id, d->port);
+	ep = rmnet_get_endpoint(d->port, mux_id);
+	if (ep) {
+		hlist_del_init_rcu(&ep->hlnode);
+		rmnet_vnd_dellink(mux_id, d->port, ep);
+		kfree(ep);
+	}
 	netdev_upper_dev_unlink(rmnet_dev, d->real_dev);
 	unregister_netdevice_queue(rmnet_dev, d->head);
 
@@ -316,6 +309,18 @@ struct rmnet_port *rmnet_get_port(struct net_device *real_dev)
 		return NULL;
 }
 
+struct rmnet_endpoint *rmnet_get_endpoint(struct rmnet_port *port, u8 mux_id)
+{
+	struct rmnet_endpoint *ep;
+
+	hlist_for_each_entry_rcu(ep, &port->muxed_ep[mux_id], hlnode) {
+		if (ep->mux_id == mux_id)
+			return ep;
+	}
+
+	return NULL;
+}
+
 /* Startup/Shutdown */
 
 static int __init rmnet_init(void)
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
index 123ccf4..8849986 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
@@ -23,6 +23,7 @@
 struct rmnet_endpoint {
 	u8 mux_id;
 	struct net_device *egress_dev;
+	struct hlist_node hlnode;
 };
 
 /* One instance of this structure is instantiated for each real_dev associated
@@ -30,11 +31,11 @@ struct rmnet_endpoint {
  */
 struct rmnet_port {
 	struct net_device *dev;
-	struct rmnet_endpoint muxed_ep[RMNET_MAX_LOGICAL_EP];
 	u32 ingress_data_format;
 	u32 egress_data_format;
 	u8 nr_rmnet_devs;
 	u8 rmnet_mode;
+	struct hlist_head muxed_ep[RMNET_MAX_LOGICAL_EP];
 };
 
 extern struct rtnl_link_ops rmnet_link_ops;
@@ -45,5 +46,6 @@ struct rmnet_priv {
 };
 
 struct rmnet_port *rmnet_get_port(struct net_device *real_dev);
+struct rmnet_endpoint *rmnet_get_endpoint(struct rmnet_port *port, u8 mux_id);
 
 #endif /* _RMNET_CONFIG_H_ */
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
index e0802d3..fa24ffb 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
@@ -71,19 +71,18 @@ static void rmnet_set_skb_proto(struct sk_buff *skb)
 		    & RMNET_INGRESS_FORMAT_MAP_COMMANDS)
 			return rmnet_map_command(skb, port);
 
-		kfree_skb(skb);
-		return RX_HANDLER_CONSUMED;
+		goto free_skb;
 	}
 
 	mux_id = RMNET_MAP_GET_MUX_ID(skb);
 	len = RMNET_MAP_GET_LENGTH(skb) - RMNET_MAP_GET_PAD(skb);
 
-	if (mux_id >= RMNET_MAX_LOGICAL_EP) {
-		kfree_skb(skb);
-		return RX_HANDLER_CONSUMED;
-	}
+	if (mux_id >= RMNET_MAX_LOGICAL_EP)
+		goto free_skb;
 
-	ep = &port->muxed_ep[mux_id];
+	ep = rmnet_get_endpoint(port, mux_id);
+	if (!ep)
+		goto free_skb;
 
 	if (port->ingress_data_format & RMNET_INGRESS_FORMAT_DEMUXING)
 		skb->dev = ep->egress_dev;
@@ -93,6 +92,10 @@ static void rmnet_set_skb_proto(struct sk_buff *skb)
 	skb_trim(skb, len);
 	rmnet_set_skb_proto(skb);
 	return rmnet_deliver_skb(skb);
+
+free_skb:
+	kfree_skb(skb);
+	return RX_HANDLER_CONSUMED;
 }
 
 static rx_handler_result_t
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_command.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_command.c
index d1ea5e2..74d362f 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_command.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_command.c
@@ -17,7 +17,7 @@
 #include "rmnet_vnd.h"
 
 static u8 rmnet_map_do_flow_control(struct sk_buff *skb,
-				    struct rmnet_port *rdinfo,
+				    struct rmnet_port *port,
 				    int enable)
 {
 	struct rmnet_map_control_command *cmd;
@@ -37,7 +37,7 @@ static u8 rmnet_map_do_flow_control(struct sk_buff *skb,
 		return RX_HANDLER_CONSUMED;
 	}
 
-	ep = &rdinfo->muxed_ep[mux_id];
+	ep = rmnet_get_endpoint(port, mux_id);
 	vnd = ep->egress_dev;
 
 	ip_family = cmd->flow_control.ip_family;
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
index 8b8497b..1b6747d 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
@@ -100,17 +100,19 @@ void rmnet_vnd_setup(struct net_device *rmnet_dev)
 
 int rmnet_vnd_newlink(u8 id, struct net_device *rmnet_dev,
 		      struct rmnet_port *port,
-		      struct net_device *real_dev)
+		      struct net_device *real_dev,
+		      struct rmnet_endpoint *ep)
 {
 	struct rmnet_priv *priv;
 	int rc;
 
-	if (port->muxed_ep[id].egress_dev)
+	if (ep->egress_dev)
 		return -EINVAL;
 
 	rc = register_netdevice(rmnet_dev);
 	if (!rc) {
-		port->muxed_ep[id].egress_dev = rmnet_dev;
+		ep->egress_dev = rmnet_dev;
+		ep->mux_id = id;
 		port->nr_rmnet_devs++;
 
 		rmnet_dev->rtnl_link_ops = &rmnet_link_ops;
@@ -125,12 +127,13 @@ int rmnet_vnd_newlink(u8 id, struct net_device *rmnet_dev,
 	return rc;
 }
 
-int rmnet_vnd_dellink(u8 id, struct rmnet_port *port)
+int rmnet_vnd_dellink(u8 id, struct rmnet_port *port,
+		      struct rmnet_endpoint *ep)
 {
-	if (id >= RMNET_MAX_LOGICAL_EP || !port->muxed_ep[id].egress_dev)
+	if (id >= RMNET_MAX_LOGICAL_EP || !ep->egress_dev)
 		return -EINVAL;
 
-	port->muxed_ep[id].egress_dev = NULL;
+	ep->egress_dev = NULL;
 	port->nr_rmnet_devs--;
 	return 0;
 }
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h
index cae134d..71e4c32 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h
@@ -19,8 +19,10 @@
 int rmnet_vnd_do_flow_control(struct net_device *dev, int enable);
 int rmnet_vnd_newlink(u8 id, struct net_device *rmnet_dev,
 		      struct rmnet_port *port,
-		      struct net_device *real_dev);
-int rmnet_vnd_dellink(u8 id, struct rmnet_port *port);
+		      struct net_device *real_dev,
+		      struct rmnet_endpoint *ep);
+int rmnet_vnd_dellink(u8 id, struct rmnet_port *port,
+		      struct rmnet_endpoint *ep);
 void rmnet_vnd_rx_fixup(struct sk_buff *skb, struct net_device *dev);
 void rmnet_vnd_tx_fixup(struct sk_buff *skb, struct net_device *dev);
 u8 rmnet_vnd_get_mux(struct net_device *rmnet_dev);
-- 
1.9.1
