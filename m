From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next v2 3/7] net: qualcomm: rmnet: Move rmnet_mode to rmnet_port
Date: Wed, 11 Oct 2017 18:43:54 -0600
Message-ID: <1507769038-30231-4-git-send-email-subashab@codeaurora.org>
References: <1507769038-30231-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:33184 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752156AbdJLAoV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 20:44:21 -0400
In-Reply-To: <1507769038-30231-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mode information on the real device makes it easier to route packets
to rmnet device or bridged device based on the configuration.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c   | 12 +++++-------
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h   |  2 +-
 drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c |  3 +--
 3 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
index 8403eea..85fce9c 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
@@ -124,20 +124,17 @@ static int rmnet_register_real_device(struct net_device *real_dev)
 }
 
 static void rmnet_set_endpoint_config(struct net_device *dev,
-				      u8 mux_id, u8 rmnet_mode,
-				      struct net_device *egress_dev)
+				      u8 mux_id, struct net_device *egress_dev)
 {
 	struct rmnet_endpoint *ep;
 
-	netdev_dbg(dev, "id %d mode %d dev %s\n",
-		   mux_id, rmnet_mode, egress_dev->name);
+	netdev_dbg(dev, "id %d dev %s\n", mux_id, egress_dev->name);
 
 	ep = rmnet_get_endpoint(dev, mux_id);
 	/* This config is cleared on every set, so its ok to not
 	 * clear it on a device delete.
 	 */
 	memset(ep, 0, sizeof(struct rmnet_endpoint));
-	ep->rmnet_mode = rmnet_mode;
 	ep->egress_dev = egress_dev;
 	ep->mux_id = mux_id;
 }
@@ -183,9 +180,10 @@ static int rmnet_newlink(struct net *src_net, struct net_device *dev,
 		   ingress_format, egress_format);
 	port->egress_data_format = egress_format;
 	port->ingress_data_format = ingress_format;
+	port->rmnet_mode = mode;
 
-	rmnet_set_endpoint_config(real_dev, mux_id, mode, dev);
-	rmnet_set_endpoint_config(dev, mux_id, mode, real_dev);
+	rmnet_set_endpoint_config(real_dev, mux_id, dev);
+	rmnet_set_endpoint_config(dev, mux_id, real_dev);
 	return 0;
 
 err2:
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
index 0b0c5a7..03d473f 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
@@ -24,7 +24,6 @@
  * Exact usage of this parameter depends on the rmnet_mode.
  */
 struct rmnet_endpoint {
-	u8 rmnet_mode;
 	u8 mux_id;
 	struct net_device *egress_dev;
 };
@@ -39,6 +38,7 @@ struct rmnet_port {
 	u32 egress_data_format;
 	struct net_device *rmnet_devices[RMNET_MAX_LOGICAL_EP];
 	u8 nr_rmnet_devs;
+	u8 rmnet_mode;
 };
 
 extern struct rtnl_link_ops rmnet_link_ops;
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
index b50f401..86e37cc 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_handlers.c
@@ -205,8 +205,7 @@ void rmnet_egress_handler(struct sk_buff *skb,
 		}
 	}
 
-	if (ep->rmnet_mode == RMNET_EPMODE_VND)
-		rmnet_vnd_tx_fixup(skb, orig_dev);
+	rmnet_vnd_tx_fixup(skb, orig_dev);
 
 	dev_queue_xmit(skb);
 }
-- 
1.9.1
