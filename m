From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 3/9] netvsc: change max channel calculation
Date: Wed, 22 Mar 2017 14:50:59 -0700
Message-ID: <20170322215105.1059-4-sthemmin@microsoft.com>
References: <20170322215105.1059-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, haiyangz@microsoft.com,
        Stephen Hemminger <sthemmin@microsoft.com>
To: kys@microsoft.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:32794 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751153AbdCVVvS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 17:51:18 -0400
Received: by mail-pg0-f54.google.com with SMTP id w20so10692108pgc.0
        for <netdev@vger.kernel.org>; Wed, 22 Mar 2017 14:51:17 -0700 (PDT)
In-Reply-To: <20170322215105.1059-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The default number of maximum channels should be limited to the
number of cpus available on the numa node of the primary channel.
This also makes sure maximum channels <= num_online_cpus

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c   |  3 +--
 drivers/net/hyperv/rndis_filter.c | 25 ++++++++++---------------
 2 files changed, 11 insertions(+), 17 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index b3a7f508434b..2f9de2e9f38e 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1503,8 +1503,7 @@ static int netvsc_probe(struct hv_device *dev,
 	/* Notify the netvsc driver of the new device */
 	memset(&device_info, 0, sizeof(device_info));
 	device_info.ring_size = ring_size;
-	device_info.max_num_vrss_chns = min_t(u32, VRSS_CHANNEL_DEFAULT,
-					      num_online_cpus());
+	device_info.num_chn = VRSS_CHANNEL_DEFAULT;
 	ret = rndis_filter_device_add(dev, &device_info);
 	if (ret != 0) {
 		netdev_err(net, "unable to add netvsc device (ret %d)\n", ret);
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 382b9a62e3c4..d193d549cec6 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -1181,33 +1181,28 @@ int rndis_filter_device_add(struct hv_device *dev,
 	if (ret || rsscap.num_recv_que < 2)
 		goto out;
 
-	net_device->max_chn = min_t(u32, VRSS_CHANNEL_MAX, rsscap.num_recv_que);
-
-	num_rss_qs = min(device_info->max_num_vrss_chns, net_device->max_chn);
-
 	/*
 	 * We will limit the VRSS channels to the number CPUs in the NUMA node
 	 * the primary channel is currently bound to.
+	 *
+	 * This also guarantees that num_possible_rss_qs <= num_online_cpus
 	 */
 	node_cpu_mask = cpumask_of_node(cpu_to_node(dev->channel->target_cpu));
-	num_possible_rss_qs = cpumask_weight(node_cpu_mask);
+	num_possible_rss_qs = min_t(u32, cpumask_weight(node_cpu_mask),
+				    rsscap.num_recv_que);
 
-	/* We will use the given number of channels if available. */
-	if (device_info->num_chn && device_info->num_chn < net_device->max_chn)
-		net_device->num_chn = device_info->num_chn;
-	else
-		net_device->num_chn = min(num_possible_rss_qs, num_rss_qs);
+	net_device->max_chn = min_t(u32, VRSS_CHANNEL_MAX, num_possible_rss_qs);
 
-	num_rss_qs = net_device->num_chn - 1;
+	/* We will use the given number of channels if available. */
+	net_device->num_chn = min(net_device->max_chn, device_info->num_chn);
 
 	for (i = 0; i < ITAB_NUM; i++)
 		rndis_device->ind_table[i] = ethtool_rxfh_indir_default(i,
 							net_device->num_chn);
 
-	net_device->num_sc_offered = num_rss_qs;
-
-	if (net_device->num_chn == 1)
-		goto out;
+	num_rss_qs = net_device->num_chn - 1;
+	if (num_rss_qs == 0)
+		return 0;
 
 	vmbus_set_sc_create_callback(dev->channel, netvsc_sc_open);
 
-- 
2.11.0
