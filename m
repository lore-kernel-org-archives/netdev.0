From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/2] netvsc: allow driver to be removed even if VF is present
Date: Thu, 31 Aug 2017 16:16:13 -0700
Message-ID: <20170831231613.15805-3-sthemmin@microsoft.com>
References: <20170831231613.15805-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:34679 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751787AbdHaXQS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 19:16:18 -0400
Received: by mail-pg0-f53.google.com with SMTP id t193so3128199pgc.1
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 16:16:18 -0700 (PDT)
In-Reply-To: <20170831231613.15805-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If VF is attached then can still allow netvsc driver module to
be removed. Just have to make sure and do the cleanup.

Also, avoid extra rtnl round trip when calling unregister.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 128165e49c9a..97ed4bdc439f 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1834,9 +1834,6 @@ static int netvsc_register_vf(struct net_device *vf_netdev)
 
 	netdev_info(ndev, "VF registering: %s\n", vf_netdev->name);
 
-	/* Prevent this module from being unloaded while VF is registered */
-	try_module_get(THIS_MODULE);
-
 	dev_hold(vf_netdev);
 	rcu_assign_pointer(net_device_ctx->vf_netdev, vf_netdev);
 	return NOTIFY_OK;
@@ -1880,10 +1877,11 @@ static int netvsc_unregister_vf(struct net_device *vf_netdev)
 
 	netdev_info(ndev, "VF unregistering: %s\n", vf_netdev->name);
 
+	netdev_rx_handler_unregister(vf_netdev);
 	netdev_upper_dev_unlink(vf_netdev, ndev);
 	RCU_INIT_POINTER(net_device_ctx->vf_netdev, NULL);
 	dev_put(vf_netdev);
-	module_put(THIS_MODULE);
+
 	return NOTIFY_OK;
 }
 
@@ -1987,11 +1985,11 @@ static int netvsc_probe(struct hv_device *dev,
 
 static int netvsc_remove(struct hv_device *dev)
 {
-	struct net_device *net;
 	struct net_device_context *ndev_ctx;
+	struct net_device *vf_netdev;
+	struct net_device *net;
 
 	net = hv_get_drvdata(dev);
-
 	if (net == NULL) {
 		dev_err(&dev->device, "No net device to remove\n");
 		return 0;
@@ -2008,12 +2006,15 @@ static int netvsc_remove(struct hv_device *dev)
 	 * removed. Also blocks mtu and channel changes.
 	 */
 	rtnl_lock();
+	vf_netdev = rtnl_dereference(ndev_ctx->vf_netdev);
+	if (vf_netdev)
+		netvsc_unregister_vf(vf_netdev);
+
 	rndis_filter_device_remove(dev,
 				   rtnl_dereference(ndev_ctx->nvdev));
+	unregister_netdevice(net);
 	rtnl_unlock();
 
-	unregister_netdev(net);
-
 	hv_set_drvdata(dev, NULL);
 
 	free_percpu(ndev_ctx->vf_stats);
-- 
2.11.0
