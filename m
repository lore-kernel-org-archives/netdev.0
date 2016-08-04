From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Subject: [PATCH net-next,
 1/2] hv_netvsc: Add query for initial physical link speed
Date: Thu,  4 Aug 2016 10:42:14 -0700
Message-ID: <1470332535-15554-1-git-send-email-haiyangz@exchange.microsoft.com>
Reply-To: haiyangz@microsoft.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: haiyangz@microsoft.com, driverdev-devel@linuxdriverproject.org,
 olaf@aepfle.de
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

From: Haiyang Zhang <haiyangz@microsoft.com>

The physical link speed value will be reported by ethtool command.
The real speed is available from Windows 2016 host or later.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c   |    4 ++--
 drivers/net/hyperv/rndis_filter.c |   24 ++++++++++++++++++++++++
 2 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 41bd952..3e5356b 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1352,6 +1352,8 @@ static int netvsc_probe(struct hv_device *dev,
 
 	netif_carrier_off(net);
 
+	netvsc_init_settings(net);
+
 	net_device_ctx = netdev_priv(net);
 	net_device_ctx->device_ctx = dev;
 	net_device_ctx->msg_enable = netif_msg_init(debug, default_msg);
@@ -1410,8 +1412,6 @@ static int netvsc_probe(struct hv_device *dev,
 	netif_set_real_num_tx_queues(net, nvdev->num_chn);
 	netif_set_real_num_rx_queues(net, nvdev->num_chn);
 
-	netvsc_init_settings(net);
-
 	ret = register_netdev(net);
 	if (ret != 0) {
 		pr_err("Unable to register netdev.\n");
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 8e830f7..dd3b335 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -752,6 +752,28 @@ static int rndis_filter_query_device_link_status(struct rndis_device *dev)
 	return ret;
 }
 
+static int rndis_filter_query_link_speed(struct rndis_device *dev)
+{
+	u32 size = sizeof(u32);
+	u32 link_speed;
+	struct net_device_context *ndc;
+	int ret;
+
+	ret = rndis_filter_query_device(dev, RNDIS_OID_GEN_LINK_SPEED,
+					&link_speed, &size);
+
+	if (!ret) {
+		ndc = netdev_priv(dev->ndev);
+
+		/* The link speed reported from host is in 100bps unit, so
+		 * we convert it to Mbps here.
+		 */
+		ndc->speed = link_speed / 10000;
+	}
+
+	return ret;
+}
+
 int rndis_filter_set_packet_filter(struct rndis_device *dev, u32 new_filter)
 {
 	struct rndis_request *request;
@@ -1044,6 +1066,8 @@ int rndis_filter_device_add(struct hv_device *dev,
 	if (net_device->nvsp_version < NVSP_PROTOCOL_VERSION_5)
 		return 0;
 
+	rndis_filter_query_link_speed(rndis_device);
+
 	/* vRSS setup */
 	memset(&rsscap, 0, rsscap_size);
 	ret = rndis_filter_query_device(rndis_device,
-- 
1.7.4.1
