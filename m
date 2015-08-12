From: Andrew Schwartzmeyer <andschwa@microsoft.com>
Subject: [PATCH net-next 1/2] hv_netvsc: Set vRSS with num_chn in RNDIS filter
Date: Tue, 11 Aug 2015 17:14:31 -0700
Message-ID: <1439338472-21361-1-git-send-email-andschwa@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kys@microsoft.com>, <andschwa@microsoft.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <haiyangz@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Uses device_info->num_chn to pass user provided number of vRSS
queues (from ethtool --set-channels) to rndis_filter_device_add. If
nonzero and less than the maximum, set net_device->num_chn to the given
value; else default to prior algorithm.

Always initialize struct device_info to 0, otherwise not all its fields
are guaranteed to be 0, which is necessary when checking if num_chn has
been purposefully set.

Signed-off-by: Andrew Schwartzmeyer <andschwa@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h   | 1 +
 drivers/net/hyperv/netvsc_drv.c   | 3 +++
 drivers/net/hyperv/rndis_filter.c | 7 ++++++-
 3 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 5ce7020ca530..5fa98f599b3d 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -162,6 +162,7 @@ struct netvsc_device_info {
 	bool link_state;	/* 0 - link up, 1 - link down */
 	int  ring_size;
 	u32  max_num_vrss_chns;
+	u32  num_chn;
 };
 
 enum rndis_device_state {
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 7b36d5fecc1f..21845202a52d 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -799,6 +799,8 @@ static int netvsc_change_mtu(struct net_device *ndev, int mtu)
 
 	ndevctx->device_ctx = hdev;
 	hv_set_drvdata(hdev, ndev);
+
+	memset(&device_info, 0, sizeof(device_info));
 	device_info.ring_size = ring_size;
 	device_info.max_num_vrss_chns = max_num_vrss_chns;
 	rndis_filter_device_add(hdev, &device_info);
@@ -1022,6 +1024,7 @@ static int netvsc_probe(struct hv_device *dev,
 	net->needed_headroom = max_needed_headroom;
 
 	/* Notify the netvsc driver of the new device */
+	memset(&device_info, 0, sizeof(device_info));
 	device_info.ring_size = ring_size;
 	device_info.max_num_vrss_chns = max_num_vrss_chns;
 	ret = rndis_filter_device_add(dev, &device_info);
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 9b8263db49cc..5931a799aa17 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -1125,7 +1125,12 @@ int rndis_filter_device_add(struct hv_device *dev,
 	 */
 	node_cpu_mask = cpumask_of_node(cpu_to_node(dev->channel->target_cpu));
 	num_possible_rss_qs = cpumask_weight(node_cpu_mask);
-	net_device->num_chn = min(num_possible_rss_qs, num_rss_qs);
+
+	/* We will use the given number of channels if available. */
+	if (device_info->num_chn && device_info->num_chn < net_device->max_chn)
+		net_device->num_chn = device_info->num_chn;
+	else
+		net_device->num_chn = min(num_possible_rss_qs, num_rss_qs);
 
 	num_rss_qs = net_device->num_chn - 1;
 	net_device->num_sc_offered = num_rss_qs;
-- 
2.4.2
