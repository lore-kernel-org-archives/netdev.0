From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 4/6] netvsc: fix netvsc_set_channels
Date: Mon, 24 Jul 2017 10:57:28 -0700
Message-ID: <20170724175730.31806-5-sthemmin@microsoft.com>
References: <20170724175730.31806-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com,
	haiyangz@microsoft.com,
	sthemmin@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170724175730.31806-1-sthemmin@microsoft.com>
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

The number of channels returned by rndis_filter_device_add maybe
less than the number requested. Therefore set correct real
number of queues.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 51 +++++++++++++++--------------------------
 1 file changed, 19 insertions(+), 32 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index bc2af352d6dd..99ae7fb6ec11 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -713,29 +713,6 @@ static void netvsc_get_channels(struct net_device *net,
 	}
 }
 
-static int netvsc_set_queues(struct net_device *net, struct hv_device *dev,
-			     u32 num_chn)
-{
-	struct netvsc_device_info device_info;
-	struct netvsc_device *net_device;
-	int ret;
-
-	memset(&device_info, 0, sizeof(device_info));
-	device_info.num_chn = num_chn;
-	device_info.ring_size = ring_size;
-	device_info.max_num_vrss_chns = num_chn;
-
-	ret = netif_set_real_num_tx_queues(net, num_chn);
-	if (ret)
-		return ret;
-
-	ret = netif_set_real_num_rx_queues(net, num_chn);
-	if (ret)
-		return ret;
-
-	net_device = rndis_filter_device_add(dev, &device_info);
-	return IS_ERR(net_device) ? PTR_ERR(net_device) : 0;
-}
 
 static int netvsc_set_channels(struct net_device *net,
 			       struct ethtool_channels *channels)
@@ -743,9 +720,10 @@ static int netvsc_set_channels(struct net_device *net,
 	struct net_device_context *net_device_ctx = netdev_priv(net);
 	struct hv_device *dev = net_device_ctx->device_ctx;
 	struct netvsc_device *nvdev = rtnl_dereference(net_device_ctx->nvdev);
-	unsigned int count = channels->combined_count;
+	unsigned int orig, count = channels->combined_count;
+	struct netvsc_device_info device_info;
 	bool was_opened;
-	int ret;
+	int ret = 0;
 
 	/* We do not support separate count for rx, tx, or other */
 	if (count == 0 ||
@@ -764,19 +742,29 @@ static int netvsc_set_channels(struct net_device *net,
 	if (count > nvdev->max_chn)
 		return -EINVAL;
 
+	orig = nvdev->num_chn;
 	was_opened = rndis_filter_opened(nvdev);
 	if (was_opened)
 		rndis_filter_close(nvdev);
 
 	rndis_filter_device_remove(dev, nvdev);
 
-	ret = netvsc_set_queues(net, dev, count);
-	if (ret == 0)
-		nvdev->num_chn = count;
-	else
-		netvsc_set_queues(net, dev, nvdev->num_chn);
+	memset(&device_info, 0, sizeof(device_info));
+	device_info.num_chn = count;
+	device_info.ring_size = ring_size;
+	device_info.max_num_vrss_chns = count;
+
+	nvdev = rndis_filter_device_add(dev, &device_info);
+	if (!IS_ERR(nvdev)) {
+		netif_set_real_num_tx_queues(net, nvdev->num_chn);
+		netif_set_real_num_rx_queues(net, nvdev->num_chn);
+		ret = PTR_ERR(nvdev);
+	} else {
+		device_info.num_chn = orig;
+		device_info.max_num_vrss_chns = count;
+		rndis_filter_device_add(dev, &device_info);
+	}
 
-	nvdev = rtnl_dereference(net_device_ctx->nvdev);
 	if (was_opened)
 		rndis_filter_open(nvdev);
 
@@ -863,7 +851,6 @@ static int netvsc_change_mtu(struct net_device *ndev, int mtu)
 	memset(&device_info, 0, sizeof(device_info));
 	device_info.ring_size = ring_size;
 	device_info.num_chn = nvdev->num_chn;
-	device_info.max_num_vrss_chns = nvdev->num_chn;
 
 	rndis_filter_device_remove(hdev, nvdev);
 
-- 
2.11.0
