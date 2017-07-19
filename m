From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 8/8] netvsc: add rtnl annotations in rndis
Date: Wed, 19 Jul 2017 11:53:19 -0700
Message-ID: <20170719185319.25871-9-sthemmin@microsoft.com>
References: <20170719185319.25871-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:38722 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932107AbdGSSxc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 14:53:32 -0400
Received: by mail-pg0-f53.google.com with SMTP id s4so3878069pgr.5
        for <netdev@vger.kernel.org>; Wed, 19 Jul 2017 11:53:32 -0700 (PDT)
In-Reply-To: <20170719185319.25871-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The rndis functions are used when changing device state.
Therefore the references from network device to internal state
are protected by RTNL mutex.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h   |  6 ------
 drivers/net/hyperv/netvsc.c       |  6 ++++--
 drivers/net/hyperv/netvsc_drv.c   |  1 +
 drivers/net/hyperv/rndis_filter.c | 12 ++++++++++--
 4 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index d13572879e7e..afb65f753574 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -787,12 +787,6 @@ struct netvsc_device {
 	struct rcu_head rcu;
 };
 
-static inline struct netvsc_device *
-net_device_to_netvsc_device(struct net_device *ndev)
-{
-	return ((struct net_device_context *)netdev_priv(ndev))->nvdev;
-}
-
 /* NdisInitialize message */
 struct rndis_initialize_request {
 	u32 req_id;
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index c15640c6fd83..0a9d9feedc3f 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -105,7 +105,8 @@ static void netvsc_destroy_buf(struct hv_device *device)
 {
 	struct nvsp_message *revoke_packet;
 	struct net_device *ndev = hv_get_drvdata(device);
-	struct netvsc_device *net_device = net_device_to_netvsc_device(ndev);
+	struct net_device_context *ndc = netdev_priv(ndev);
+	struct netvsc_device *net_device = rtnl_dereference(ndc->nvdev);
 	int ret;
 
 	/*
@@ -829,7 +830,8 @@ int netvsc_send(struct net_device_context *ndev_ctx,
 		struct hv_page_buffer **pb,
 		struct sk_buff *skb)
 {
-	struct netvsc_device *net_device = rcu_dereference(ndev_ctx->nvdev);
+	struct netvsc_device *net_device
+		= rcu_dereference_rtnl(ndev_ctx->nvdev);
 	struct hv_device *device = ndev_ctx->device_ctx;
 	int ret = 0;
 	struct netvsc_channel *nvchan;
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 1238600d717e..a164981c15f7 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1548,6 +1548,7 @@ static int netvsc_probe(struct hv_device *dev,
 
 	netif_set_real_num_tx_queues(net, nvdev->num_chn);
 	netif_set_real_num_rx_queues(net, nvdev->num_chn);
+	rtnl_unlock();
 
 	netdev_lockdep_set_classes(net);
 
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 9ab67c8309ff..e439886f72c1 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -84,6 +84,14 @@ static struct rndis_device *get_rndis_device(void)
 	return device;
 }
 
+static struct netvsc_device *
+net_device_to_netvsc_device(struct net_device *ndev)
+{
+	struct net_device_context *net_device_ctx = netdev_priv(ndev);
+
+	return rtnl_dereference(net_device_ctx->nvdev);
+}
+
 static struct rndis_request *get_rndis_request(struct rndis_device *dev,
 					     u32 msg_type,
 					     u32 msg_len)
@@ -472,7 +480,7 @@ static int rndis_filter_query_device(struct rndis_device *dev, u32 oid,
 
 	if (oid == OID_TCP_OFFLOAD_HARDWARE_CAPABILITIES) {
 		struct net_device_context *ndevctx = netdev_priv(dev->ndev);
-		struct netvsc_device *nvdev = ndevctx->nvdev;
+		struct netvsc_device *nvdev = rtnl_dereference(ndevctx->nvdev);
 		struct ndis_offload *hwcaps;
 		u32 nvsp_version = nvdev->nvsp_version;
 		u8 ndis_rev;
@@ -944,7 +952,7 @@ static void rndis_filter_halt_device(struct rndis_device *dev)
 	struct rndis_request *request;
 	struct rndis_halt_request *halt;
 	struct net_device_context *net_device_ctx = netdev_priv(dev->ndev);
-	struct netvsc_device *nvdev = net_device_ctx->nvdev;
+	struct netvsc_device *nvdev = rtnl_dereference(net_device_ctx->nvdev);
 
 	/* Attempt to do a rndis device halt */
 	request = get_rndis_request(dev, RNDIS_MSG_HALT,
-- 
2.11.0
