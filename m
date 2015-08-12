From: Andrew Schwartzmeyer <andschwa@microsoft.com>
Subject: [PATCH net-next 2/2] hv_netvsc: Implement set_channels ethtool op
Date: Tue, 11 Aug 2015 17:14:32 -0700
Message-ID: <1439338472-21361-2-git-send-email-andschwa@microsoft.com>
References: <1439338472-21361-1-git-send-email-andschwa@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kys@microsoft.com>, <andschwa@microsoft.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <haiyangz@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439338472-21361-1-git-send-email-andschwa@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This enables the use of ethtool --set-channels devname combined N to
change the number of vRSS queues. Separate rx, tx, and other parameters
are not supported. The maximum is rsscap.num_recv_que. It passes the
given value to rndis_filter_device_add through the device_info->num_chn
field.

If the procedure fails, it attempts to recover to the prior state. If
the recovery fails, it logs an error and aborts.

Current num_chn is saved and restored when changing the MTU.

Signed-off-by: Andrew Schwartzmeyer <andschwa@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 97 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 97 insertions(+)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 21845202a52d..f3b9d3eb753b 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -770,6 +770,101 @@ static void netvsc_get_channels(struct net_device *net,
 	}
 }
 
+static int netvsc_set_channels(struct net_device *net,
+			       struct ethtool_channels *channels)
+{
+	struct net_device_context *net_device_ctx = netdev_priv(net);
+	struct hv_device *dev = net_device_ctx->device_ctx;
+	struct netvsc_device *nvdev = hv_get_drvdata(dev);
+	struct netvsc_device_info device_info;
+	const u32 num_chn = nvdev->num_chn;
+	const u32 max_chn = min_t(u32, nvdev->max_chn, num_online_cpus());
+	int ret = 0;
+	bool recovering = false;
+
+	if (!nvdev || nvdev->destroy)
+		return -ENODEV;
+
+	if (nvdev->nvsp_version < NVSP_PROTOCOL_VERSION_5) {
+		pr_info("vRSS unsupported before NVSP Version 5\n");
+		return -EINVAL;
+	}
+
+	/* We do not support rx, tx, or other */
+	if (!channels ||
+	    channels->rx_count ||
+	    channels->tx_count ||
+	    channels->other_count ||
+	    (channels->combined_count < 1))
+		return -EINVAL;
+
+	if (channels->combined_count > max_chn) {
+		pr_info("combined channels too high, using %d\n", max_chn);
+		channels->combined_count = max_chn;
+	}
+
+	ret = netvsc_close(net);
+	if (ret)
+		goto out;
+
+ do_set:
+	nvdev->start_remove = true;
+	rndis_filter_device_remove(dev);
+
+	nvdev->num_chn = channels->combined_count;
+
+	net_device_ctx->device_ctx = dev;
+	hv_set_drvdata(dev, net);
+
+	memset(&device_info, 0, sizeof(device_info));
+	device_info.num_chn = nvdev->num_chn; /* passed to RNDIS */
+	device_info.ring_size = ring_size;
+	device_info.max_num_vrss_chns = max_num_vrss_chns;
+
+	ret = rndis_filter_device_add(dev, &device_info);
+	if (ret) {
+		if (recovering) {
+			netdev_err(net, "unable to add netvsc device (ret %d)\n", ret);
+			return ret;
+		}
+		goto recover;
+	}
+
+	nvdev = hv_get_drvdata(dev);
+
+	ret = netif_set_real_num_tx_queues(net, nvdev->num_chn);
+	if (ret) {
+		if (recovering) {
+			netdev_err(net, "could not set tx queue count (ret %d)\n", ret);
+			return ret;
+		}
+		goto recover;
+	}
+
+	ret = netif_set_real_num_rx_queues(net, nvdev->num_chn);
+	if (ret) {
+		if (recovering) {
+			netdev_err(net, "could not set rx queue count (ret %d)\n", ret);
+			return ret;
+		}
+		goto recover;
+	}
+
+ out:
+	netvsc_open(net);
+
+	return ret;
+
+ recover:
+	/* If the above failed, we attempt to recover through the same
+	 * process but with the original number of channels.
+	 */
+	netdev_err(net, "could not set channels, recovering\n");
+	recovering = true;
+	channels->combined_count = num_chn;
+	goto do_set;
+}
+
 static int netvsc_change_mtu(struct net_device *ndev, int mtu)
 {
 	struct net_device_context *ndevctx = netdev_priv(ndev);
@@ -802,6 +897,7 @@ static int netvsc_change_mtu(struct net_device *ndev, int mtu)
 
 	memset(&device_info, 0, sizeof(device_info));
 	device_info.ring_size = ring_size;
+	device_info.num_chn = nvdev->num_chn;
 	device_info.max_num_vrss_chns = max_num_vrss_chns;
 	rndis_filter_device_add(hdev, &device_info);
 
@@ -891,6 +987,7 @@ static const struct ethtool_ops ethtool_ops = {
 	.get_drvinfo	= netvsc_get_drvinfo,
 	.get_link	= ethtool_op_get_link,
 	.get_channels   = netvsc_get_channels,
+	.set_channels   = netvsc_set_channels,
 };
 
 static const struct net_device_ops device_ops = {
-- 
2.4.2
