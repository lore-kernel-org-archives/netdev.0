From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next 4/6] net: qualcomm: rmnet: Refactor the new rmnet dev creation
Date: Sat,  2 Sep 2017 23:30:44 -0600
Message-ID: <1504416646-9527-5-git-send-email-subashab@codeaurora.org>
References: <1504416646-9527-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        Dan Williams <dcbw@redhat.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:42746 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751196AbdICFb4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 01:31:56 -0400
In-Reply-To: <1504416646-9527-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Data format can be directly set from rmnet_newlink() since the
rmnet real dev info is already available.

Since __rmnet_get_real_dev_info() is no longer used in rmnet_config.c
after removal of those functions, move content to
rmnet_get_real_dev_info().

__rmnet_set_endpoint_config() is collapsed into
rmnet_set_endpoint_config() since only mux_id was being set additionally
within it. Remove an unnecessary mux_id check.

Set the mux_id for the rmnet_dev within rmnet_vnd_newlink() itself.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Cc: Dan Williams <dcbw@redhat.com>
---
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c | 96 +++++-----------------
 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c    | 13 ++-
 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h    |  1 -
 3 files changed, 26 insertions(+), 84 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
index 3ca98ec..c0aed7c 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
@@ -57,16 +57,6 @@ static int rmnet_is_real_dev_registered(const struct net_device *real_dev)
 	return (rx_handler == rmnet_rx_handler);
 }
 
-/* Needs either rcu_read_lock() or rtnl lock */
-static struct rmnet_real_dev_info*
-__rmnet_get_real_dev_info(const struct net_device *real_dev)
-{
-	if (rmnet_is_real_dev_registered(real_dev))
-		return rcu_dereference_rtnl(real_dev->rx_handler_data);
-	else
-		return NULL;
-}
-
 /* Needs rtnl lock */
 static struct rmnet_real_dev_info*
 rmnet_get_real_dev_info_rtnl(const struct net_device *real_dev)
@@ -83,10 +73,7 @@ static int rmnet_is_real_dev_registered(const struct net_device *real_dev)
 	if (!rmnet_is_real_dev_registered(dev)) {
 		ep = rmnet_vnd_get_endpoint(dev);
 	} else {
-		r = __rmnet_get_real_dev_info(dev);
-
-		if (!r)
-			return NULL;
+		r = rmnet_get_real_dev_info_rtnl(dev);
 
 		ep = &r->muxed_ep[config_id];
 	}
@@ -139,70 +126,23 @@ static int rmnet_register_real_device(struct net_device *real_dev)
 	return 0;
 }
 
-static int rmnet_set_ingress_data_format(struct net_device *dev, u32 idf)
-{
-	struct rmnet_real_dev_info *r;
-
-	netdev_dbg(dev, "Ingress format 0x%08X\n", idf);
-
-	r = __rmnet_get_real_dev_info(dev);
-
-	r->ingress_data_format = idf;
-
-	return 0;
-}
-
-static int rmnet_set_egress_data_format(struct net_device *dev, u32 edf,
-					u16 agg_size, u16 agg_count)
+static void rmnet_set_endpoint_config(struct net_device *dev,
+				      u8 mux_id, u8 rmnet_mode,
+				      struct net_device *egress_dev)
 {
-	struct rmnet_real_dev_info *r;
-
-	netdev_dbg(dev, "Egress format 0x%08X agg size %d cnt %d\n",
-		   edf, agg_size, agg_count);
-
-	r = __rmnet_get_real_dev_info(dev);
-
-	r->egress_data_format = edf;
-
-	return 0;
-}
-
-static int __rmnet_set_endpoint_config(struct net_device *dev, int config_id,
-				       struct rmnet_endpoint *ep)
-{
-	struct rmnet_endpoint *dev_ep;
-
-	dev_ep = rmnet_get_endpoint(dev, config_id);
-
-	if (!dev_ep)
-		return -EINVAL;
-
-	memcpy(dev_ep, ep, sizeof(struct rmnet_endpoint));
-	dev_ep->mux_id = config_id;
-
-	return 0;
-}
-
-static int rmnet_set_endpoint_config(struct net_device *dev,
-				     int config_id, u8 rmnet_mode,
-				     struct net_device *egress_dev)
-{
-	struct rmnet_endpoint ep;
+	struct rmnet_endpoint *ep;
 
 	netdev_dbg(dev, "id %d mode %d dev %s\n",
-		   config_id, rmnet_mode, egress_dev->name);
-
-	if (config_id >= RMNET_MAX_LOGICAL_EP)
-		return -EINVAL;
+		   mux_id, rmnet_mode, egress_dev->name);
 
+	ep = rmnet_get_endpoint(dev, mux_id);
 	/* This config is cleared on every set, so its ok to not
 	 * clear it on a device delete.
 	 */
-	memset(&ep, 0, sizeof(struct rmnet_endpoint));
-	ep.rmnet_mode = rmnet_mode;
-	ep.egress_dev = egress_dev;
-
-	return __rmnet_set_endpoint_config(dev, config_id, &ep);
+	memset(ep, 0, sizeof(struct rmnet_endpoint));
+	ep->rmnet_mode = rmnet_mode;
+	ep->egress_dev = egress_dev;
+	ep->mux_id = mux_id;
 }
 
 static int rmnet_newlink(struct net *src_net, struct net_device *dev,
@@ -242,9 +182,11 @@ static int rmnet_newlink(struct net *src_net, struct net_device *dev,
 	if (err)
 		goto err2;
 
-	rmnet_vnd_set_mux(dev, mux_id);
-	rmnet_set_egress_data_format(real_dev, egress_format, 0, 0);
-	rmnet_set_ingress_data_format(real_dev, ingress_format);
+	netdev_dbg(dev, "data format [ingress 0x%08X] [egress 0x%08X]\n",
+		   ingress_format, egress_format);
+	r->egress_data_format = egress_format;
+	r->ingress_data_format = ingress_format;
+
 	rmnet_set_endpoint_config(real_dev, mux_id, mode, dev);
 	rmnet_set_endpoint_config(dev, mux_id, mode, real_dev);
 	return 0;
@@ -376,10 +318,14 @@ struct rtnl_link_ops rmnet_link_ops __read_mostly = {
 	.get_size	= rmnet_get_size,
 };
 
+/* Needs either rcu_read_lock() or rtnl lock */
 struct rmnet_real_dev_info*
 rmnet_get_real_dev_info(struct net_device *real_dev)
 {
-	return __rmnet_get_real_dev_info(real_dev);
+	if (rmnet_is_real_dev_registered(real_dev))
+		return rcu_dereference_rtnl(real_dev->rx_handler_data);
+	else
+		return NULL;
 }
 
 /* Startup/Shutdown */
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
index 7c73052..a6de041 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
@@ -93,6 +93,7 @@ void rmnet_vnd_setup(struct net_device *rmnet_dev)
 int rmnet_vnd_newlink(u8 id, struct net_device *rmnet_dev,
 		      struct rmnet_real_dev_info *r)
 {
+	struct rmnet_priv *priv;
 	int rc;
 
 	if (r->rmnet_devices[id])
@@ -103,6 +104,10 @@ int rmnet_vnd_newlink(u8 id, struct net_device *rmnet_dev,
 		r->rmnet_devices[id] = rmnet_dev;
 		r->nr_rmnet_devs++;
 		rmnet_dev->rtnl_link_ops = &rmnet_link_ops;
+
+		priv = netdev_priv(rmnet_dev);
+		priv->mux_id = id;
+
 		netdev_dbg(rmnet_dev, "rmnet dev created\n");
 	}
 
@@ -127,14 +132,6 @@ u8 rmnet_vnd_get_mux(struct net_device *rmnet_dev)
 	return priv->mux_id;
 }
 
-void rmnet_vnd_set_mux(struct net_device *rmnet_dev, u8 mux_id)
-{
-	struct rmnet_priv *priv;
-
-	priv = netdev_priv(rmnet_dev);
-	priv->mux_id = mux_id;
-}
-
 /* Gets the logical endpoint configuration for a RmNet virtual network device
  * node. Caller should confirm that devices is a RmNet VND before calling.
  */
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h
index b102b42..4823f38 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h
@@ -24,6 +24,5 @@ int rmnet_vnd_newlink(u8 id, struct net_device *rmnet_dev,
 void rmnet_vnd_rx_fixup(struct sk_buff *skb, struct net_device *dev);
 void rmnet_vnd_tx_fixup(struct sk_buff *skb, struct net_device *dev);
 u8 rmnet_vnd_get_mux(struct net_device *rmnet_dev);
-void rmnet_vnd_set_mux(struct net_device *rmnet_dev, u8 mux_id);
 void rmnet_vnd_setup(struct net_device *dev);
 #endif /* _RMNET_VND_H_ */
-- 
1.9.1
