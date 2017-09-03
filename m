From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next 6/6] net: qualcomm: rmnet: Rename real_dev_info to port
Date: Sat,  2 Sep 2017 23:30:46 -0600
Message-ID: <1504416646-9527-7-git-send-email-subashab@codeaurora.org>
References: <1504416646-9527-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        Dan Williams <dcbw@redhat.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:42882 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751159AbdICFcA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 01:32:00 -0400
In-Reply-To: <1504416646-9527-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make it similar to drivers like ipvlan / macvlan so it is easier to read.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Cc: Dan Williams <dcbw@redhat.com>
---
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c | 65 +++++++++++-----------
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h |  5 +-
 .../net/ethernet/qualcomm/rmnet/rmnet_handlers.c   | 56 +++++++++----------
 drivers/net/ethernet/qualcomm/rmnet/rmnet_map.h    |  6 +-
 .../ethernet/qualcomm/rmnet/rmnet_map_command.c    | 13 ++---
 .../net/ethernet/qualcomm/rmnet/rmnet_map_data.c   |  3 +-
 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c    | 17 +++---
 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h    |  4 +-
 8 files changed, 82 insertions(+), 87 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
index 6f21cd0..98f2255 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
@@ -46,7 +46,7 @@
 struct rmnet_walk_data {
 	struct net_device *real_dev;
 	struct list_head *head;
-	struct rmnet_real_dev_info *real_dev_info;
+	struct rmnet_port *port;
 };
 
 static int rmnet_is_real_dev_registered(const struct net_device *real_dev)
@@ -58,8 +58,8 @@ static int rmnet_is_real_dev_registered(const struct net_device *real_dev)
 }
 
 /* Needs rtnl lock */
-static struct rmnet_real_dev_info*
-rmnet_get_real_dev_info_rtnl(const struct net_device *real_dev)
+static struct rmnet_port*
+rmnet_get_port_rtnl(const struct net_device *real_dev)
 {
 	return rtnl_dereference(real_dev->rx_handler_data);
 }
@@ -67,27 +67,27 @@ static int rmnet_is_real_dev_registered(const struct net_device *real_dev)
 static struct rmnet_endpoint*
 rmnet_get_endpoint(struct net_device *dev, int config_id)
 {
-	struct rmnet_real_dev_info *r;
 	struct rmnet_endpoint *ep;
+	struct rmnet_port *port;
 
 	if (!rmnet_is_real_dev_registered(dev)) {
 		ep = rmnet_vnd_get_endpoint(dev);
 	} else {
-		r = rmnet_get_real_dev_info_rtnl(dev);
+		port = rmnet_get_port_rtnl(dev);
 
-		ep = &r->muxed_ep[config_id];
+		ep = &port->muxed_ep[config_id];
 	}
 
 	return ep;
 }
 
 static int rmnet_unregister_real_device(struct net_device *real_dev,
-					struct rmnet_real_dev_info *r)
+					struct rmnet_port *port)
 {
-	if (r->nr_rmnet_devs)
+	if (port->nr_rmnet_devs)
 		return -EINVAL;
 
-	kfree(r);
+	kfree(port);
 
 	netdev_rx_handler_unregister(real_dev);
 
@@ -100,7 +100,7 @@ static int rmnet_unregister_real_device(struct net_device *real_dev,
 
 static int rmnet_register_real_device(struct net_device *real_dev)
 {
-	struct rmnet_real_dev_info *r;
+	struct rmnet_port *port;
 	int rc;
 
 	ASSERT_RTNL();
@@ -108,14 +108,14 @@ static int rmnet_register_real_device(struct net_device *real_dev)
 	if (rmnet_is_real_dev_registered(real_dev))
 		return 0;
 
-	r = kzalloc(sizeof(*r), GFP_ATOMIC);
-	if (!r)
+	port = kzalloc(sizeof(*port), GFP_ATOMIC);
+	if (!port)
 		return -ENOMEM;
 
-	r->dev = real_dev;
-	rc = netdev_rx_handler_register(real_dev, rmnet_rx_handler, r);
+	port->dev = real_dev;
+	rc = netdev_rx_handler_register(real_dev, rmnet_rx_handler, port);
 	if (rc) {
-		kfree(r);
+		kfree(port);
 		return -EBUSY;
 	}
 
@@ -154,9 +154,9 @@ static int rmnet_newlink(struct net *src_net, struct net_device *dev,
 			     RMNET_INGRESS_FORMAT_MAP;
 	int egress_format = RMNET_EGRESS_FORMAT_MUXING |
 			    RMNET_EGRESS_FORMAT_MAP;
-	struct rmnet_real_dev_info *r;
 	struct net_device *real_dev;
 	int mode = RMNET_EPMODE_VND;
+	struct rmnet_port *port;
 	int err = 0;
 	u16 mux_id;
 
@@ -173,8 +173,8 @@ static int rmnet_newlink(struct net *src_net, struct net_device *dev,
 	if (err)
 		goto err0;
 
-	r = rmnet_get_real_dev_info_rtnl(real_dev);
-	err = rmnet_vnd_newlink(mux_id, dev, r, real_dev);
+	port = rmnet_get_port_rtnl(real_dev);
+	err = rmnet_vnd_newlink(mux_id, dev, port, real_dev);
 	if (err)
 		goto err1;
 
@@ -184,25 +184,25 @@ static int rmnet_newlink(struct net *src_net, struct net_device *dev,
 
 	netdev_dbg(dev, "data format [ingress 0x%08X] [egress 0x%08X]\n",
 		   ingress_format, egress_format);
-	r->egress_data_format = egress_format;
-	r->ingress_data_format = ingress_format;
+	port->egress_data_format = egress_format;
+	port->ingress_data_format = ingress_format;
 
 	rmnet_set_endpoint_config(real_dev, mux_id, mode, dev);
 	rmnet_set_endpoint_config(dev, mux_id, mode, real_dev);
 	return 0;
 
 err2:
-	rmnet_vnd_dellink(mux_id, r);
+	rmnet_vnd_dellink(mux_id, port);
 err1:
-	rmnet_unregister_real_device(real_dev, r);
+	rmnet_unregister_real_device(real_dev, port);
 err0:
 	return err;
 }
 
 static void rmnet_dellink(struct net_device *dev, struct list_head *head)
 {
-	struct rmnet_real_dev_info *r;
 	struct net_device *real_dev;
+	struct rmnet_port *port;
 	u8 mux_id;
 
 	rcu_read_lock();
@@ -212,12 +212,12 @@ static void rmnet_dellink(struct net_device *dev, struct list_head *head)
 	if (!real_dev || !rmnet_is_real_dev_registered(real_dev))
 		return;
 
-	r = rmnet_get_real_dev_info_rtnl(real_dev);
+	port = rmnet_get_port_rtnl(real_dev);
 
 	mux_id = rmnet_vnd_get_mux(dev);
-	rmnet_vnd_dellink(mux_id, r);
+	rmnet_vnd_dellink(mux_id, port);
 	netdev_upper_dev_unlink(dev, real_dev);
-	rmnet_unregister_real_device(real_dev, r);
+	rmnet_unregister_real_device(real_dev, port);
 
 	unregister_netdevice_queue(dev, head);
 }
@@ -229,7 +229,7 @@ static int rmnet_dev_walk_unreg(struct net_device *rmnet_dev, void *data)
 
 	mux_id = rmnet_vnd_get_mux(rmnet_dev);
 
-	rmnet_vnd_dellink(mux_id, d->real_dev_info);
+	rmnet_vnd_dellink(mux_id, d->port);
 	netdev_upper_dev_unlink(rmnet_dev, d->real_dev);
 	unregister_netdevice_queue(rmnet_dev, d->head);
 
@@ -239,8 +239,8 @@ static int rmnet_dev_walk_unreg(struct net_device *rmnet_dev, void *data)
 static void rmnet_force_unassociate_device(struct net_device *dev)
 {
 	struct net_device *real_dev = dev;
-	struct rmnet_real_dev_info *r;
 	struct rmnet_walk_data d;
+	struct rmnet_port *port;
 	LIST_HEAD(list);
 
 	if (!rmnet_is_real_dev_registered(real_dev))
@@ -251,15 +251,15 @@ static void rmnet_force_unassociate_device(struct net_device *dev)
 	d.real_dev = real_dev;
 	d.head = &list;
 
-	r = rmnet_get_real_dev_info_rtnl(dev);
-	d.real_dev_info = r;
+	port = rmnet_get_port_rtnl(dev);
+	d.port = port;
 
 	rcu_read_lock();
 	netdev_walk_all_lower_dev_rcu(real_dev, rmnet_dev_walk_unreg, &d);
 	rcu_read_unlock();
 	unregister_netdevice_many(&list);
 
-	rmnet_unregister_real_device(real_dev, r);
+	rmnet_unregister_real_device(real_dev, port);
 }
 
 static int rmnet_config_notify_cb(struct notifier_block *nb,
@@ -319,8 +319,7 @@ struct rtnl_link_ops rmnet_link_ops __read_mostly = {
 };
 
 /* Needs either rcu_read_lock() or rtnl lock */
-struct rmnet_real_dev_info*
-rmnet_get_real_dev_info(struct net_device *real_dev)
+struct rmnet_port *rmnet_get_port(struct net_device *real_dev)
 {
 	if (rmnet_is_real_dev_registered(real_dev))
 		return rcu_dereference_rtnl(real_dev->rx_handler_data);
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
index 3212b25..dde4e9f 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
@@ -32,7 +32,7 @@ struct rmnet_endpoint {
 /* One instance of this structure is instantiated for each real_dev associated
  * with rmnet.
  */
-struct rmnet_real_dev_info {
+struct rmnet_port {
 	struct net_device *dev;
 	struct rmnet_endpoint local_ep;
 	struct rmnet_endpoint muxed_ep[RMNET_MAX_LOGICAL_EP];
@@ -50,7 +50,6 @@ struct rmnet_priv {
 	struct net_device *real_dev;
 };
 
-struct rmnet_real_dev_info*
-rmnet_get_real_dev_info(struct net_device *real_dev);
+struct rmnet_port *rmnet_get_port(struct net_device *real_dev);
 
 #endif /* _RMNET_CONFIG_H_ */
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
index 7dab3bb..540c762 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
@@ -82,32 +82,32 @@ static void rmnet_set_skb_proto(struct sk_buff *skb)
 
 static rx_handler_result_t
 rmnet_ingress_deliver_packet(struct sk_buff *skb,
-			     struct rmnet_real_dev_info *r)
+			     struct rmnet_port *port)
 {
-	if (!r) {
+	if (!port) {
 		kfree_skb(skb);
 		return RX_HANDLER_CONSUMED;
 	}
 
-	skb->dev = r->local_ep.egress_dev;
+	skb->dev = port->local_ep.egress_dev;
 
-	return rmnet_deliver_skb(skb, &r->local_ep);
+	return rmnet_deliver_skb(skb, &port->local_ep);
 }
 
 /* MAP handler */
 
 static rx_handler_result_t
 __rmnet_map_ingress_handler(struct sk_buff *skb,
-			    struct rmnet_real_dev_info *r)
+			    struct rmnet_port *port)
 {
 	struct rmnet_endpoint *ep;
 	u8 mux_id;
 	u16 len;
 
 	if (RMNET_MAP_GET_CD_BIT(skb)) {
-		if (r->ingress_data_format
+		if (port->ingress_data_format
 		    & RMNET_INGRESS_FORMAT_MAP_COMMANDS)
-			return rmnet_map_command(skb, r);
+			return rmnet_map_command(skb, port);
 
 		kfree_skb(skb);
 		return RX_HANDLER_CONSUMED;
@@ -121,9 +121,9 @@ static void rmnet_set_skb_proto(struct sk_buff *skb)
 		return RX_HANDLER_CONSUMED;
 	}
 
-	ep = &r->muxed_ep[mux_id];
+	ep = &port->muxed_ep[mux_id];
 
-	if (r->ingress_data_format & RMNET_INGRESS_FORMAT_DEMUXING)
+	if (port->ingress_data_format & RMNET_INGRESS_FORMAT_DEMUXING)
 		skb->dev = ep->egress_dev;
 
 	/* Subtract MAP header */
@@ -135,26 +135,26 @@ static void rmnet_set_skb_proto(struct sk_buff *skb)
 
 static rx_handler_result_t
 rmnet_map_ingress_handler(struct sk_buff *skb,
-			  struct rmnet_real_dev_info *r)
+			  struct rmnet_port *port)
 {
 	struct sk_buff *skbn;
 	int rc;
 
-	if (r->ingress_data_format & RMNET_INGRESS_FORMAT_DEAGGREGATION) {
-		while ((skbn = rmnet_map_deaggregate(skb, r)) != NULL)
-			__rmnet_map_ingress_handler(skbn, r);
+	if (port->ingress_data_format & RMNET_INGRESS_FORMAT_DEAGGREGATION) {
+		while ((skbn = rmnet_map_deaggregate(skb)) != NULL)
+			__rmnet_map_ingress_handler(skbn, port);
 
 		consume_skb(skb);
 		rc = RX_HANDLER_CONSUMED;
 	} else {
-		rc = __rmnet_map_ingress_handler(skb, r);
+		rc = __rmnet_map_ingress_handler(skb, port);
 	}
 
 	return rc;
 }
 
 static int rmnet_map_egress_handler(struct sk_buff *skb,
-				    struct rmnet_real_dev_info *r,
+				    struct rmnet_port *port,
 				    struct rmnet_endpoint *ep,
 				    struct net_device *orig_dev)
 {
@@ -173,7 +173,7 @@ static int rmnet_map_egress_handler(struct sk_buff *skb,
 	if (!map_header)
 		return RMNET_MAP_CONSUMED;
 
-	if (r->egress_data_format & RMNET_EGRESS_FORMAT_MUXING) {
+	if (port->egress_data_format & RMNET_EGRESS_FORMAT_MUXING) {
 		if (ep->mux_id == 0xff)
 			map_header->mux_id = 0;
 		else
@@ -193,7 +193,7 @@ static int rmnet_map_egress_handler(struct sk_buff *skb,
  */
 rx_handler_result_t rmnet_rx_handler(struct sk_buff **pskb)
 {
-	struct rmnet_real_dev_info *r;
+	struct rmnet_port *port;
 	struct sk_buff *skb = *pskb;
 	struct net_device *dev;
 	int rc;
@@ -202,16 +202,16 @@ rx_handler_result_t rmnet_rx_handler(struct sk_buff **pskb)
 		return RX_HANDLER_CONSUMED;
 
 	dev = skb->dev;
-	r = rmnet_get_real_dev_info(dev);
+	port = rmnet_get_port(dev);
 
-	if (r->ingress_data_format & RMNET_INGRESS_FORMAT_MAP) {
-		rc = rmnet_map_ingress_handler(skb, r);
+	if (port->ingress_data_format & RMNET_INGRESS_FORMAT_MAP) {
+		rc = rmnet_map_ingress_handler(skb, port);
 	} else {
 		switch (ntohs(skb->protocol)) {
 		case ETH_P_MAP:
-			if (r->local_ep.rmnet_mode ==
+			if (port->local_ep.rmnet_mode ==
 				RMNET_EPMODE_BRIDGE) {
-				rc = rmnet_ingress_deliver_packet(skb, r);
+				rc = rmnet_ingress_deliver_packet(skb, port);
 			} else {
 				kfree_skb(skb);
 				rc = RX_HANDLER_CONSUMED;
@@ -220,7 +220,7 @@ rx_handler_result_t rmnet_rx_handler(struct sk_buff **pskb)
 
 		case ETH_P_IP:
 		case ETH_P_IPV6:
-			rc = rmnet_ingress_deliver_packet(skb, r);
+			rc = rmnet_ingress_deliver_packet(skb, port);
 			break;
 
 		default:
@@ -238,20 +238,20 @@ rx_handler_result_t rmnet_rx_handler(struct sk_buff **pskb)
 void rmnet_egress_handler(struct sk_buff *skb,
 			  struct rmnet_endpoint *ep)
 {
-	struct rmnet_real_dev_info *r;
 	struct net_device *orig_dev;
+	struct rmnet_port *port;
 
 	orig_dev = skb->dev;
 	skb->dev = ep->egress_dev;
 
-	r = rmnet_get_real_dev_info(skb->dev);
-	if (!r) {
+	port = rmnet_get_port(skb->dev);
+	if (!port) {
 		kfree_skb(skb);
 		return;
 	}
 
-	if (r->egress_data_format & RMNET_EGRESS_FORMAT_MAP) {
-		switch (rmnet_map_egress_handler(skb, r, ep, orig_dev)) {
+	if (port->egress_data_format & RMNET_EGRESS_FORMAT_MAP) {
+		switch (rmnet_map_egress_handler(skb, port, ep, orig_dev)) {
 		case RMNET_MAP_CONSUMED:
 			return;
 
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_map.h b/drivers/net/ethernet/qualcomm/rmnet/rmnet_map.h
index 2aabad2..ce2302c 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_map.h
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_map.h
@@ -77,12 +77,10 @@ struct rmnet_map_header {
 #define RMNET_MAP_ADD_PAD_BYTES       1
 
 u8 rmnet_map_demultiplex(struct sk_buff *skb);
-struct sk_buff *rmnet_map_deaggregate(struct sk_buff *skb,
-				      struct rmnet_real_dev_info *rdinfo);
-
+struct sk_buff *rmnet_map_deaggregate(struct sk_buff *skb);
 struct rmnet_map_header *rmnet_map_add_map_header(struct sk_buff *skb,
 						  int hdrlen, int pad);
 rx_handler_result_t rmnet_map_command(struct sk_buff *skb,
-				      struct rmnet_real_dev_info *rdinfo);
+				      struct rmnet_port *port);
 
 #endif /* _RMNET_MAP_H_ */
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_command.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_command.c
index ccded40..d1ea5e2 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_command.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_command.c
@@ -17,7 +17,7 @@
 #include "rmnet_vnd.h"
 
 static u8 rmnet_map_do_flow_control(struct sk_buff *skb,
-				    struct rmnet_real_dev_info *rdinfo,
+				    struct rmnet_port *rdinfo,
 				    int enable)
 {
 	struct rmnet_map_control_command *cmd;
@@ -58,8 +58,7 @@ static u8 rmnet_map_do_flow_control(struct sk_buff *skb,
 }
 
 static void rmnet_map_send_ack(struct sk_buff *skb,
-			       unsigned char type,
-			       struct rmnet_real_dev_info *rdinfo)
+			       unsigned char type)
 {
 	struct rmnet_map_control_command *cmd;
 	int xmit_status;
@@ -78,7 +77,7 @@ static void rmnet_map_send_ack(struct sk_buff *skb,
  * name is decoded here and appropriate handler is called.
  */
 rx_handler_result_t rmnet_map_command(struct sk_buff *skb,
-				      struct rmnet_real_dev_info *rdinfo)
+				      struct rmnet_port *port)
 {
 	struct rmnet_map_control_command *cmd;
 	unsigned char command_name;
@@ -89,11 +88,11 @@ rx_handler_result_t rmnet_map_command(struct sk_buff *skb,
 
 	switch (command_name) {
 	case RMNET_MAP_COMMAND_FLOW_ENABLE:
-		rc = rmnet_map_do_flow_control(skb, rdinfo, 1);
+		rc = rmnet_map_do_flow_control(skb, port, 1);
 		break;
 
 	case RMNET_MAP_COMMAND_FLOW_DISABLE:
-		rc = rmnet_map_do_flow_control(skb, rdinfo, 0);
+		rc = rmnet_map_do_flow_control(skb, port, 0);
 		break;
 
 	default:
@@ -102,6 +101,6 @@ rx_handler_result_t rmnet_map_command(struct sk_buff *skb,
 		break;
 	}
 	if (rc == RMNET_MAP_COMMAND_ACK)
-		rmnet_map_send_ack(skb, rc, rdinfo);
+		rmnet_map_send_ack(skb, rc);
 	return RX_HANDLER_CONSUMED;
 }
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_data.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_data.c
index a29c476..557c9bf 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_data.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_data.c
@@ -69,8 +69,7 @@ struct rmnet_map_header *rmnet_map_add_map_header(struct sk_buff *skb,
  * returned, indicating that there are no more packets to deaggregate. Caller
  * is responsible for freeing the original skb.
  */
-struct sk_buff *rmnet_map_deaggregate(struct sk_buff *skb,
-				      struct rmnet_real_dev_info *rdinfo)
+struct sk_buff *rmnet_map_deaggregate(struct sk_buff *skb)
 {
 	struct rmnet_map_header *maph;
 	struct sk_buff *skbn;
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
index f5c63b7..7f90d55 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
@@ -99,19 +99,20 @@ void rmnet_vnd_setup(struct net_device *rmnet_dev)
 /* Exposed API */
 
 int rmnet_vnd_newlink(u8 id, struct net_device *rmnet_dev,
-		      struct rmnet_real_dev_info *r,
+		      struct rmnet_port *port,
 		      struct net_device *real_dev)
 {
 	struct rmnet_priv *priv;
 	int rc;
 
-	if (r->rmnet_devices[id])
+	if (port->rmnet_devices[id])
 		return -EINVAL;
 
 	rc = register_netdevice(rmnet_dev);
 	if (!rc) {
-		r->rmnet_devices[id] = rmnet_dev;
-		r->nr_rmnet_devs++;
+		port->rmnet_devices[id] = rmnet_dev;
+		port->nr_rmnet_devs++;
+
 		rmnet_dev->rtnl_link_ops = &rmnet_link_ops;
 
 		priv = netdev_priv(rmnet_dev);
@@ -124,13 +125,13 @@ int rmnet_vnd_newlink(u8 id, struct net_device *rmnet_dev,
 	return rc;
 }
 
-int rmnet_vnd_dellink(u8 id, struct rmnet_real_dev_info *r)
+int rmnet_vnd_dellink(u8 id, struct rmnet_port *port)
 {
-	if (id >= RMNET_MAX_LOGICAL_EP || !r->rmnet_devices[id])
+	if (id >= RMNET_MAX_LOGICAL_EP || !port->rmnet_devices[id])
 		return -EINVAL;
 
-	r->rmnet_devices[id] = NULL;
-	r->nr_rmnet_devs--;
+	port->rmnet_devices[id] = NULL;
+	port->nr_rmnet_devs--;
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h
index 9084e44..8a4042f 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h
@@ -19,9 +19,9 @@
 int rmnet_vnd_do_flow_control(struct net_device *dev, int enable);
 struct rmnet_endpoint *rmnet_vnd_get_endpoint(struct net_device *dev);
 int rmnet_vnd_newlink(u8 id, struct net_device *rmnet_dev,
-		      struct rmnet_real_dev_info *r,
+		      struct rmnet_port *port,
 		      struct net_device *real_dev);
-int rmnet_vnd_dellink(u8 id, struct rmnet_real_dev_info *r);
+int rmnet_vnd_dellink(u8 id, struct rmnet_port *port);
 void rmnet_vnd_rx_fixup(struct sk_buff *skb, struct net_device *dev);
 void rmnet_vnd_tx_fixup(struct sk_buff *skb, struct net_device *dev);
 u8 rmnet_vnd_get_mux(struct net_device *rmnet_dev);
-- 
1.9.1
