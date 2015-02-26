From: Andrew Schwartzmeyer <andrew@schwartzmeyer.com>
Subject: [PATCH] Implement Hyper-V netvsc_get_channels() ethool op
Date: Thu, 26 Feb 2015 12:00:40 -0800
Message-ID: <1424980840-33714-1-git-send-email-andrew@schwartzmeyer.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: keithd@vandals.uidaho.edu, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
 hall5714@vandals.uidaho.edu
To: <haiyangz@microsoft.com>
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

This adds support for reporting the combined channels count of the
hv_netvsc driver via 'ethtool --show-channels'.

This required adding 'max_chn' to 'struct netvsc_device', and assigning
it 'rsscap.num_recv_que' in 'rndis_filter_device_add'. Now we can access
the combined maximum channel count via 'struct netvsc_device' in the
ethtool callback.

Signed-off-by: Andrew Schwartzmeyer <andrew@schwartzmeyer.com>
---
 drivers/net/hyperv/hyperv_net.h   |  1 +
 drivers/net/hyperv/netvsc_drv.c   | 14 ++++++++++++++
 drivers/net/hyperv/rndis_filter.c |  5 ++++-
 3 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 384ca4f4de4a..371f2a6c0715 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -635,6 +635,7 @@ struct netvsc_device {
 	struct vmbus_channel *chn_table[NR_CPUS];
 	u32 send_table[VRSS_SEND_TAB_SIZE];
 	u32 num_chn;
+	u32 max_chn;
 	atomic_t queue_sends[NR_CPUS];
 
 	/* Holds rndis device info */
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 15d82eda0baf..a06bd6614007 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -687,6 +687,19 @@ static void netvsc_get_drvinfo(struct net_device *net,
 	strlcpy(info->fw_version, "N/A", sizeof(info->fw_version));
 }
 
+static void netvsc_get_channels(struct net_device *net,
+				struct ethtool_channels *channel)
+{
+	struct net_device_context *net_device_ctx = netdev_priv(net);
+	struct hv_device *dev = net_device_ctx->device_ctx;
+	struct netvsc_device *nvdev = hv_get_drvdata(dev);
+
+	if (nvdev) {
+		channel->max_combined	= nvdev->max_chn;
+		channel->combined_count = nvdev->num_chn;
+	}
+}
+
 static int netvsc_change_mtu(struct net_device *ndev, int mtu)
 {
 	struct net_device_context *ndevctx = netdev_priv(ndev);
@@ -760,6 +773,7 @@ static void netvsc_poll_controller(struct net_device *net)
 static const struct ethtool_ops ethtool_ops = {
 	.get_drvinfo	= netvsc_get_drvinfo,
 	.get_link	= ethtool_op_get_link,
+	.get_channels   = netvsc_get_channels,
 };
 
 static const struct net_device_ops device_ops = {
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 7816d98bdddc..015f9b9b5093 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -1094,6 +1094,7 @@ int rndis_filter_device_add(struct hv_device *dev,
 	if (ret || rsscap.num_recv_que < 2)
 		goto out;
 
+	net_device->max_chn = rsscap.num_recv_que;
 	net_device->num_chn = (num_online_cpus() < rsscap.num_recv_que) ?
 			       num_online_cpus() : rsscap.num_recv_que;
 	if (net_device->num_chn == 1)
@@ -1140,8 +1141,10 @@ int rndis_filter_device_add(struct hv_device *dev,
 	ret = rndis_filter_set_rss_param(rndis_device, net_device->num_chn);
 
 out:
-	if (ret)
+	if (ret) {
+		net_device->max_chn = 1;
 		net_device->num_chn = 1;
+	}
 	return 0; /* return 0 because primary channel can be used alone */
 
 err_dev_remv:
-- 
2.3.0
