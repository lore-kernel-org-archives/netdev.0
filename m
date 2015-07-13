From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next] hv_netvsc: Add close of RNDIS filter into change mtu
 call
Date: Mon, 13 Jul 2015 13:09:16 -0700
Message-ID: <1436818156-13674-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, jasowang@redhat.com, driverdev-devel@linuxdriverproject.org,
 linux-kernel@vger.kernel.org, haiyangz@microsoft.com
To: davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

The current change mtu call only stops tx before removing RNDIS filter.
In case ringbufer is not empty, the rndis_filter_device_remove() may
hang on removing the buffers.

This patch adds close of RNDIS filter before removing it, also a
gradual waiting loop until the ring is empty. The change_mtu hang
issue under heavy traffic is solved by this patch.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c |   58 +++++++++++++++++++++++++++++++++++----
 1 files changed, 52 insertions(+), 6 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index b855ba9..7b36d5f 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -106,7 +106,7 @@ static int netvsc_open(struct net_device *net)
 		return ret;
 	}
 
-	netif_tx_start_all_queues(net);
+	netif_tx_wake_all_queues(net);
 
 	nvdev = hv_get_drvdata(device_obj);
 	rdev = nvdev->extension;
@@ -120,15 +120,56 @@ static int netvsc_close(struct net_device *net)
 {
 	struct net_device_context *net_device_ctx = netdev_priv(net);
 	struct hv_device *device_obj = net_device_ctx->device_ctx;
+	struct netvsc_device *nvdev = hv_get_drvdata(device_obj);
 	int ret;
+	u32 aread, awrite, i, msec = 10, retry = 0, retry_max = 20;
+	struct vmbus_channel *chn;
 
 	netif_tx_disable(net);
 
 	/* Make sure netvsc_set_multicast_list doesn't re-enable filter! */
 	cancel_work_sync(&net_device_ctx->work);
 	ret = rndis_filter_close(device_obj);
-	if (ret != 0)
+	if (ret != 0) {
 		netdev_err(net, "unable to close device (ret %d).\n", ret);
+		return ret;
+	}
+
+	/* Ensure pending bytes in ring are read */
+	while (true) {
+		aread = 0;
+		for (i = 0; i < nvdev->num_chn; i++) {
+			chn = nvdev->chn_table[i];
+			if (!chn)
+				continue;
+
+			hv_get_ringbuffer_availbytes(&chn->inbound, &aread,
+						     &awrite);
+
+			if (aread)
+				break;
+
+			hv_get_ringbuffer_availbytes(&chn->outbound, &aread,
+						     &awrite);
+
+			if (aread)
+				break;
+		}
+
+		retry++;
+		if (retry > retry_max || aread == 0)
+			break;
+
+		msleep(msec);
+
+		if (msec < 1000)
+			msec *= 2;
+	}
+
+	if (aread) {
+		netdev_err(net, "Ring buffer not empty after closing rndis\n");
+		ret = -ETIMEDOUT;
+	}
 
 	return ret;
 }
@@ -736,6 +777,7 @@ static int netvsc_change_mtu(struct net_device *ndev, int mtu)
 	struct netvsc_device *nvdev = hv_get_drvdata(hdev);
 	struct netvsc_device_info device_info;
 	int limit = ETH_DATA_LEN;
+	int ret = 0;
 
 	if (nvdev == NULL || nvdev->destroy)
 		return -ENODEV;
@@ -746,9 +788,11 @@ static int netvsc_change_mtu(struct net_device *ndev, int mtu)
 	if (mtu < NETVSC_MTU_MIN || mtu > limit)
 		return -EINVAL;
 
+	ret = netvsc_close(ndev);
+	if (ret)
+		goto out;
+
 	nvdev->start_remove = true;
-	cancel_work_sync(&ndevctx->work);
-	netif_tx_disable(ndev);
 	rndis_filter_device_remove(hdev);
 
 	ndev->mtu = mtu;
@@ -758,9 +802,11 @@ static int netvsc_change_mtu(struct net_device *ndev, int mtu)
 	device_info.ring_size = ring_size;
 	device_info.max_num_vrss_chns = max_num_vrss_chns;
 	rndis_filter_device_add(hdev, &device_info);
-	netif_tx_wake_all_queues(ndev);
 
-	return 0;
+out:
+	netvsc_open(ndev);
+
+	return ret;
 }
 
 static struct rtnl_link_stats64 *netvsc_get_stats64(struct net_device *net,
-- 
1.7.4.1
