From: sthemmin@exchange.microsoft.com
Subject: [PATCH 5/7] hv_netvsc: use RCU to protect vf_netdev
Date: Thu, 22 Sep 2016 16:56:33 -0700
Message-ID: <1474588595-16054-6-git-send-email-sthemmin@exchange.microsoft.com>
References: <1474588595-16054-1-git-send-email-sthemmin@exchange.microsoft.com>
Reply-To: sthemmin@microsoft.com
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: "K. Y. Srinivasan" <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded03.prod.phx3.secureserver.net ([208.109.80.60]:59854
        "EHLO p3plsmtps2ded03.prod.phx3.secureserver.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757856AbcIVWGI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Sep 2016 18:06:08 -0400
In-Reply-To: <1474588595-16054-1-git-send-email-sthemmin@exchange.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <sthemmin@microsoft.com>

The vf_netdev pointer in the netvsc device context can simply be protected
by RCU because network device destruction is already RCU synchronized.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h |    2 +-
 drivers/net/hyperv/netvsc_drv.c |   29 +++++++++++++++--------------
 2 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 284b97b..6b79487 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -695,7 +695,7 @@ struct net_device_context {
 	bool start_remove;
 
 	/* State to manage the associated VF interface. */
-	struct net_device *vf_netdev;
+	struct net_device __rcu *vf_netdev;
 	bool vf_inject;
 	atomic_t vf_use_cnt;
 	/* 1: allocated, serial number is valid. 0: not allocated */
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 8768219..dde17c0 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -667,8 +667,8 @@ int netvsc_recv_callback(struct hv_device *device_obj,
 {
 	struct net_device *net = hv_get_drvdata(device_obj);
 	struct net_device_context *net_device_ctx = netdev_priv(net);
+	struct net_device *vf_netdev;
 	struct sk_buff *skb;
-	struct sk_buff *vf_skb;
 	struct netvsc_stats *rx_stats;
 	u32 bytes_recvd = packet->total_data_buflen;
 	int ret = 0;
@@ -676,9 +676,12 @@ int netvsc_recv_callback(struct hv_device *device_obj,
 	if (!net || net->reg_state != NETREG_REGISTERED)
 		return NVSP_STAT_FAIL;
 
-	if (READ_ONCE(net_device_ctx->vf_inject)) {
+	vf_netdev = rcu_dereference(net_device_ctx->vf_netdev);
+	if (vf_netdev) {
+		struct sk_buff *vf_skb;
+
 		atomic_inc(&net_device_ctx->vf_use_cnt);
-		if (!READ_ONCE(net_device_ctx->vf_inject)) {
+		if (!net_device_ctx->vf_inject) {
 			/*
 			 * We raced; just move on.
 			 */
@@ -694,13 +697,12 @@ int netvsc_recv_callback(struct hv_device *device_obj,
 		 * the host). Deliver these via the VF interface
 		 * in the guest.
 		 */
-		vf_skb = netvsc_alloc_recv_skb(net_device_ctx->vf_netdev,
+		vf_skb = netvsc_alloc_recv_skb(vf_netdev,
 					       packet, csum_info, *data,
 					       vlan_tci);
 		if (vf_skb != NULL) {
-			++net_device_ctx->vf_netdev->stats.rx_packets;
-			net_device_ctx->vf_netdev->stats.rx_bytes +=
-				bytes_recvd;
+			++vf_netdev->stats.rx_packets;
+			vf_netdev->stats.rx_bytes += bytes_recvd;
 			netif_receive_skb(vf_skb);
 		} else {
 			++net->stats.rx_dropped;
@@ -1232,7 +1234,7 @@ static struct net_device *get_netvsc_bymac(const u8 *mac)
 	return NULL;
 }
 
-static struct net_device *get_netvsc_byref(const struct net_device *vf_netdev)
+static struct net_device *get_netvsc_byref(struct net_device *vf_netdev)
 {
 	struct net_device *dev;
 
@@ -1248,7 +1250,7 @@ static struct net_device *get_netvsc_byref(const struct net_device *vf_netdev)
 		if (net_device_ctx->nvdev == NULL)
 			continue;	/* device is removed */
 
-		if (net_device_ctx->vf_netdev == vf_netdev)
+		if (rtnl_dereference(net_device_ctx->vf_netdev) == vf_netdev)
 			return dev;	/* a match */
 	}
 
@@ -1275,7 +1277,7 @@ static int netvsc_register_vf(struct net_device *vf_netdev)
 
 	net_device_ctx = netdev_priv(ndev);
 	netvsc_dev = net_device_ctx->nvdev;
-	if (!netvsc_dev || net_device_ctx->vf_netdev)
+	if (!netvsc_dev || rtnl_dereference(net_device_ctx->vf_netdev))
 		return NOTIFY_DONE;
 
 	netdev_info(ndev, "VF registering: %s\n", vf_netdev->name);
@@ -1285,7 +1287,7 @@ static int netvsc_register_vf(struct net_device *vf_netdev)
 	try_module_get(THIS_MODULE);
 
 	dev_hold(vf_netdev);
-	net_device_ctx->vf_netdev = vf_netdev;
+	rcu_assign_pointer(net_device_ctx->vf_netdev, vf_netdev);
 	return NOTIFY_OK;
 }
 
@@ -1379,7 +1381,8 @@ static int netvsc_unregister_vf(struct net_device *vf_netdev)
 
 	netdev_info(ndev, "VF unregistering: %s\n", vf_netdev->name);
 	netvsc_inject_disable(net_device_ctx);
-	net_device_ctx->vf_netdev = NULL;
+
+	RCU_INIT_POINTER(net_device_ctx->vf_netdev, NULL);
 	dev_put(vf_netdev);
 	module_put(THIS_MODULE);
 	return NOTIFY_OK;
@@ -1433,8 +1436,6 @@ static int netvsc_probe(struct hv_device *dev,
 	INIT_LIST_HEAD(&net_device_ctx->reconfig_events);
 
 	atomic_set(&net_device_ctx->vf_use_cnt, 0);
-	net_device_ctx->vf_netdev = NULL;
-	net_device_ctx->vf_inject = false;
 
 	net->netdev_ops = &device_ops;
 
-- 
1.7.4.1
