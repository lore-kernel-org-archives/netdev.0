From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Subject: [PATCH net-next] hv_netvsc: Fix rndis_filter_close error during netvsc_remove
Date: Thu, 24 Aug 2017 11:50:02 -0700
Message-ID: <20170824185002.10213-1-haiyangz@exchange.microsoft.com>
Reply-To: haiyangz@microsoft.com
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
        vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>

We now remove rndis filter before unregister_netdev(), which calls
device close. It involves closing rndis filter already removed.

This patch fixes this error.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index c0c4c9195a3f..fac44c5c8d0d 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -119,12 +119,16 @@ static int netvsc_close(struct net_device *net)
 	struct net_device *vf_netdev
 		= rtnl_dereference(net_device_ctx->vf_netdev);
 	struct netvsc_device *nvdev = rtnl_dereference(net_device_ctx->nvdev);
-	int ret;
+	int ret = 0;
 	u32 aread, i, msec = 10, retry = 0, retry_max = 20;
 	struct vmbus_channel *chn;
 
 	netif_tx_disable(net);
 
+	/* No need to close rndis filter if it is removed already */
+	if (!nvdev)
+		goto out;
+
 	ret = rndis_filter_close(nvdev);
 	if (ret != 0) {
 		netdev_err(net, "unable to close device (ret %d).\n", ret);
@@ -163,6 +167,7 @@ static int netvsc_close(struct net_device *net)
 		ret = -ETIMEDOUT;
 	}
 
+out:
 	if (vf_netdev)
 		dev_close(vf_netdev);
 
-- 
2.14.0
