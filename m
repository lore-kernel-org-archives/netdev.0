From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: [PATCH net-next 5/6] net: qualcomm: rmnet: Implement ndo_get_iflink
Date: Sat,  2 Sep 2017 23:30:45 -0600
Message-ID: <1504416646-9527-6-git-send-email-subashab@codeaurora.org>
References: <1504416646-9527-1-git-send-email-subashab@codeaurora.org>
Cc: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        Dan Williams <dcbw@redhat.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:42818 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751159AbdICFb6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 01:31:58 -0400
In-Reply-To: <1504416646-9527-1-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This makes it easier to find out the parent dev.

Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Cc: Dan Williams <dcbw@redhat.com>
---
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c |  2 +-
 drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h |  1 +
 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c    | 12 +++++++++++-
 drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h    |  3 ++-
 4 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
index c0aed7c..6f21cd0 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.c
@@ -174,7 +174,7 @@ static int rmnet_newlink(struct net *src_net, struct net_device *dev,
 		goto err0;
 
 	r = rmnet_get_real_dev_info_rtnl(real_dev);
-	err = rmnet_vnd_newlink(mux_id, dev, r);
+	err = rmnet_vnd_newlink(mux_id, dev, r, real_dev);
 	if (err)
 		goto err1;
 
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
index 40b6b32..3212b25 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_config.h
@@ -47,6 +47,7 @@ struct rmnet_real_dev_info {
 struct rmnet_priv {
 	struct rmnet_endpoint local_ep;
 	u8 mux_id;
+	struct net_device *real_dev;
 };
 
 struct rmnet_real_dev_info*
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
index a6de041..f5c63b7 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.c
@@ -63,9 +63,17 @@ static int rmnet_vnd_change_mtu(struct net_device *rmnet_dev, int new_mtu)
 	return 0;
 }
 
+static int rmnet_vnd_get_iflink(const struct net_device *dev)
+{
+	struct rmnet_priv *priv = netdev_priv(dev);
+
+	return priv->real_dev->ifindex;
+}
+
 static const struct net_device_ops rmnet_vnd_ops = {
 	.ndo_start_xmit = rmnet_vnd_start_xmit,
 	.ndo_change_mtu = rmnet_vnd_change_mtu,
+	.ndo_get_iflink = rmnet_vnd_get_iflink,
 };
 
 /* Called by kernel whenever a new rmnet<n> device is created. Sets MTU,
@@ -91,7 +99,8 @@ void rmnet_vnd_setup(struct net_device *rmnet_dev)
 /* Exposed API */
 
 int rmnet_vnd_newlink(u8 id, struct net_device *rmnet_dev,
-		      struct rmnet_real_dev_info *r)
+		      struct rmnet_real_dev_info *r,
+		      struct net_device *real_dev)
 {
 	struct rmnet_priv *priv;
 	int rc;
@@ -107,6 +116,7 @@ int rmnet_vnd_newlink(u8 id, struct net_device *rmnet_dev,
 
 		priv = netdev_priv(rmnet_dev);
 		priv->mux_id = id;
+		priv->real_dev = real_dev;
 
 		netdev_dbg(rmnet_dev, "rmnet dev created\n");
 	}
diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h
index 4823f38..9084e44 100644
--- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h
+++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_vnd.h
@@ -19,7 +19,8 @@
 int rmnet_vnd_do_flow_control(struct net_device *dev, int enable);
 struct rmnet_endpoint *rmnet_vnd_get_endpoint(struct net_device *dev);
 int rmnet_vnd_newlink(u8 id, struct net_device *rmnet_dev,
-		      struct rmnet_real_dev_info *r);
+		      struct rmnet_real_dev_info *r,
+		      struct net_device *real_dev);
 int rmnet_vnd_dellink(u8 id, struct rmnet_real_dev_info *r);
 void rmnet_vnd_rx_fixup(struct sk_buff *skb, struct net_device *dev);
 void rmnet_vnd_tx_fixup(struct sk_buff *skb, struct net_device *dev);
-- 
1.9.1
