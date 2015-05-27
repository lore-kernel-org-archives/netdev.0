From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH V2 net-next 1/1] hv_netvsc: Properly size the vrss queues
Date: Wed, 27 May 2015 13:16:57 -0700
Message-ID: <1432757817-6804-1-git-send-email-kys@microsoft.com>
Cc: "K. Y. Srinivasan" <kys@microsoft.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current algorithm for deciding on the number of VRSS channels is
not optimal since we open up the min of number of CPUs online and the
number of VRSS channels the host is offering. So on a 32 VCPU guest
we could potentially open 32 VRSS subchannels. Experimentation has
shown that it is best to limit the number of VRSS channels to the number
of CPUs within a NUMA node.

Here is the new algorithm for deciding on the number of sub-channels we
would open up:
        1) Pick the minimum of what the host is offering and what the driver
           in the guest is specifying as the default value.
        2) Pick the minimum of (1) and the numbers of CPUs in the NUMA
           node the primary channel is bound to.


Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
	V2: Got rid of the module parameter (Dave Miller)

 drivers/net/hyperv/hyperv_net.h   |    1 +
 drivers/net/hyperv/netvsc_drv.c   |    4 ++++
 drivers/net/hyperv/rndis_filter.c |   16 ++++++++++++++--
 3 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index ddcc7f8..dd45440 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -161,6 +161,7 @@ struct netvsc_device_info {
 	unsigned char mac_adr[ETH_ALEN];
 	bool link_state;	/* 0 - link up, 1 - link down */
 	int  ring_size;
+	u32  max_num_vrss_chns;
 };
 
 enum rndis_device_state {
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index d9c88bc..358475e 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -46,6 +46,8 @@ static int ring_size = 128;
 module_param(ring_size, int, S_IRUGO);
 MODULE_PARM_DESC(ring_size, "Ring buffer size (# of pages)");
 
+static int max_num_vrss_chns = 8;
+
 static const u32 default_msg = NETIF_MSG_DRV | NETIF_MSG_PROBE |
 				NETIF_MSG_LINK | NETIF_MSG_IFUP |
 				NETIF_MSG_IFDOWN | NETIF_MSG_RX_ERR |
@@ -755,6 +757,7 @@ static int netvsc_change_mtu(struct net_device *ndev, int mtu)
 	ndevctx->device_ctx = hdev;
 	hv_set_drvdata(hdev, ndev);
 	device_info.ring_size = ring_size;
+	device_info.max_num_vrss_chns = max_num_vrss_chns;
 	rndis_filter_device_add(hdev, &device_info);
 	netif_tx_wake_all_queues(ndev);
 
@@ -975,6 +978,7 @@ static int netvsc_probe(struct hv_device *dev,
 
 	/* Notify the netvsc driver of the new device */
 	device_info.ring_size = ring_size;
+	device_info.max_num_vrss_chns = max_num_vrss_chns;
 	ret = rndis_filter_device_add(dev, &device_info);
 	if (ret != 0) {
 		netdev_err(net, "unable to add netvsc device (ret %d)\n", ret);
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 9118cea..006c1b8 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -1013,6 +1013,9 @@ int rndis_filter_device_add(struct hv_device *dev,
 	struct ndis_recv_scale_cap rsscap;
 	u32 rsscap_size = sizeof(struct ndis_recv_scale_cap);
 	u32 mtu, size;
+	u32 num_rss_qs;
+	const struct cpumask *node_cpu_mask;
+	u32 num_possible_rss_qs;
 
 	rndis_device = get_rndis_device();
 	if (!rndis_device)
@@ -1100,9 +1103,18 @@ int rndis_filter_device_add(struct hv_device *dev,
 	if (ret || rsscap.num_recv_que < 2)
 		goto out;
 
+	num_rss_qs = min(device_info->max_num_vrss_chns, rsscap.num_recv_que);
+
 	net_device->max_chn = rsscap.num_recv_que;
-	net_device->num_chn = (num_online_cpus() < rsscap.num_recv_que) ?
-			       num_online_cpus() : rsscap.num_recv_que;
+
+	/*
+	 * We will limit the VRSS channels to the number CPUs in the NUMA node
+	 * the primary channel is currently bound to.
+	 */
+	node_cpu_mask = cpumask_of_node(cpu_to_node(dev->channel->target_cpu));
+	num_possible_rss_qs = cpumask_weight(node_cpu_mask);
+	net_device->num_chn = min(num_possible_rss_qs, num_rss_qs);
+
 	if (net_device->num_chn == 1)
 		goto out;
 
-- 
1.7.4.1
