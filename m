From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 1/1] hv_netvsc: fix deadlock on hotplug
Date: Wed,  6 Sep 2017 08:19:25 -0700
Message-ID: <20170906151925.15221-2-sthemmin@microsoft.com>
References: <20170906151925.15221-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com,
	haiyangz@microsoft.com,
	sthemmin@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170906151925.15221-1-sthemmin@microsoft.com>
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

When a virtual device is added dynamically (via host console), then
the vmbus sends an offer message for the primary channel. The processing
of this message for networking causes the network device to then
initialize the sub channels.

The problem is that setting up the sub channels needs to wait until
the subsequent subchannel offers have been processed. These offers
come in on the same ring buffer and work queue as where the primary
offer is being processed; leading to a deadlock.

This did not happen in older kernels, because the sub channel waiting
logic was broken (it wasn't really waiting).

The solution is to do the sub channel setup in its own work queue
context that is scheduled by the primary channel setup; and then
happens later.

Fixes: 732e49850c5e ("netvsc: fix race on sub channel creation")
Reported-by: Dexuan Cui <decui@microsoft.com>
Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
Should also go to stable, but this version does not apply cleanly
to 4.13. Have another patch for that.

 drivers/net/hyperv/hyperv_net.h   |   1 +
 drivers/net/hyperv/netvsc_drv.c   |   8 +--
 drivers/net/hyperv/rndis_filter.c | 106 ++++++++++++++++++++++++++------------
 3 files changed, 74 insertions(+), 41 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index ec546da86683..d1df5050adfb 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -172,6 +172,7 @@ struct rndis_device {
 	struct list_head req_list;
 
 	struct work_struct mcast_work;
+	struct work_struct subchan_work;
 
 	bool link_state;        /* 0 - link up, 1 - link down */
 
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 165ba4b3b423..80f45e0f81c8 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -853,10 +853,7 @@ static int netvsc_set_channels(struct net_device *net,
 	rndis_filter_device_remove(dev, nvdev);
 
 	nvdev = rndis_filter_device_add(dev, &device_info);
-	if (!IS_ERR(nvdev)) {
-		netif_set_real_num_tx_queues(net, nvdev->num_chn);
-		netif_set_real_num_rx_queues(net, nvdev->num_chn);
-	} else {
+	if (IS_ERR(nvdev)) {
 		ret = PTR_ERR(nvdev);
 		device_info.num_chn = orig;
 		nvdev = rndis_filter_device_add(dev, &device_info);
@@ -1954,9 +1951,6 @@ static int netvsc_probe(struct hv_device *dev,
 		NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX;
 	net->vlan_features = net->features;
 
-	netif_set_real_num_tx_queues(net, nvdev->num_chn);
-	netif_set_real_num_rx_queues(net, nvdev->num_chn);
-
 	netdev_lockdep_set_classes(net);
 
 	/* MTU range: 68 - 1500 or 65521 */
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 69c40b8fccc3..c240125eed48 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -33,6 +33,7 @@
 #include "hyperv_net.h"
 
 static void rndis_set_multicast(struct work_struct *w);
+static void rndis_set_subchannel(struct work_struct *w);
 
 #define RNDIS_EXT_LEN PAGE_SIZE
 struct rndis_request {
@@ -79,6 +80,7 @@ static struct rndis_device *get_rndis_device(void)
 
 	INIT_LIST_HEAD(&device->req_list);
 	INIT_WORK(&device->mcast_work, rndis_set_multicast);
+	INIT_WORK(&device->subchan_work, rndis_set_subchannel);
 
 	device->state = RNDIS_DEV_UNINITIALIZED;
 
@@ -1002,6 +1004,7 @@ static int rndis_filter_close_device(struct rndis_device *dev)
 
 	/* Make sure rndis_set_multicast doesn't re-enable filter! */
 	cancel_work_sync(&dev->mcast_work);
+	cancel_work_sync(&dev->subchan_work);
 
 	ret = rndis_filter_set_packet_filter(dev, 0);
 	if (ret == -ENODEV)
@@ -1054,6 +1057,71 @@ static void netvsc_sc_open(struct vmbus_channel *new_sc)
 	wake_up(&nvscdev->subchan_open);
 }
 
+/*
+ * Open sub-channels after completing the handling of the device probe.
+ * This breaks overlap of processing the host message for the
+ * new primary channel with the initialization of sub-channels.
+ */
+static void rndis_set_subchannel(struct work_struct *w)
+{
+	struct rndis_device *rdev
+		= container_of(w, struct rndis_device, subchan_work);
+	struct net_device *net = rdev->ndev;
+	struct net_device_context *ndev_ctx = netdev_priv(net);
+	struct hv_device *dev = ndev_ctx->device_ctx;
+	struct nvsp_message *init_packet;
+	struct netvsc_device *nvdev;
+	int ret = -ENODEV;
+
+	if (!rtnl_trylock()) {
+		schedule_work(w);
+		return;
+	}
+
+	nvdev = rtnl_dereference(ndev_ctx->nvdev);
+	if (!nvdev)
+		goto out;
+
+	init_packet = &nvdev->channel_init_pkt;
+	memset(init_packet, 0, sizeof(struct nvsp_message));
+	init_packet->hdr.msg_type = NVSP_MSG5_TYPE_SUBCHANNEL;
+	init_packet->msg.v5_msg.subchn_req.op = NVSP_SUBCHANNEL_ALLOCATE;
+	init_packet->msg.v5_msg.subchn_req.num_subchannels =
+						nvdev->num_chn - 1;
+	ret = vmbus_sendpacket(dev->channel, init_packet,
+			       sizeof(struct nvsp_message),
+			       (unsigned long)init_packet,
+			       VM_PKT_DATA_INBAND,
+			       VMBUS_DATA_PACKET_FLAG_COMPLETION_REQUESTED);
+	if (ret)
+		goto out;
+
+	wait_for_completion(&nvdev->channel_init_wait);
+	if (init_packet->msg.v5_msg.subchn_comp.status != NVSP_STAT_SUCCESS) {
+		netdev_err(net, "sub channel request failed\n");
+		goto out;
+	}
+
+	nvdev->num_chn = 1 +
+		init_packet->msg.v5_msg.subchn_comp.num_subchannels;
+
+	/* wait for all sub channels to open */
+	wait_event(nvdev->subchan_open,
+		   atomic_read(&nvdev->open_chn) == nvdev->num_chn);
+
+	/* ignore failues from setting rss parameters, still have channels */
+	rndis_filter_set_rss_param(rdev, netvsc_hash_key);
+out:
+	if (ret) {
+		nvdev->max_chn = 1;
+		nvdev->num_chn = 1;
+	}
+
+	netif_set_real_num_tx_queues(net, nvdev->num_chn);
+	netif_set_real_num_rx_queues(net, nvdev->num_chn);
+	rtnl_unlock();
+}
+
 struct netvsc_device *rndis_filter_device_add(struct hv_device *dev,
 				      struct netvsc_device_info *device_info)
 {
@@ -1063,7 +1131,6 @@ struct netvsc_device *rndis_filter_device_add(struct hv_device *dev,
 	struct rndis_device *rndis_device;
 	struct ndis_offload hwcaps;
 	struct ndis_offload_params offloads;
-	struct nvsp_message *init_packet;
 	struct ndis_recv_scale_cap rsscap;
 	u32 rsscap_size = sizeof(struct ndis_recv_scale_cap);
 	unsigned int gso_max_size = GSO_MAX_SIZE;
@@ -1215,9 +1282,7 @@ struct netvsc_device *rndis_filter_device_add(struct hv_device *dev,
 							net_device->num_chn);
 
 	atomic_set(&net_device->open_chn, 1);
-
-	if (net_device->num_chn == 1)
-		return net_device;
+	vmbus_set_sc_create_callback(dev->channel, netvsc_sc_open);
 
 	for (i = 1; i < net_device->num_chn; i++) {
 		ret = netvsc_alloc_recv_comp_ring(net_device, i);
@@ -1228,38 +1293,11 @@ struct netvsc_device *rndis_filter_device_add(struct hv_device *dev,
 		}
 	}
 
-	vmbus_set_sc_create_callback(dev->channel, netvsc_sc_open);
-
-	init_packet = &net_device->channel_init_pkt;
-	memset(init_packet, 0, sizeof(struct nvsp_message));
-	init_packet->hdr.msg_type = NVSP_MSG5_TYPE_SUBCHANNEL;
-	init_packet->msg.v5_msg.subchn_req.op = NVSP_SUBCHANNEL_ALLOCATE;
-	init_packet->msg.v5_msg.subchn_req.num_subchannels =
-						net_device->num_chn - 1;
-	ret = vmbus_sendpacket(dev->channel, init_packet,
-			       sizeof(struct nvsp_message),
-			       (unsigned long)init_packet,
-			       VM_PKT_DATA_INBAND,
-			       VMBUS_DATA_PACKET_FLAG_COMPLETION_REQUESTED);
-	if (ret)
-		goto out;
-
-	wait_for_completion(&net_device->channel_init_wait);
-	if (init_packet->msg.v5_msg.subchn_comp.status != NVSP_STAT_SUCCESS) {
-		ret = -ENODEV;
-		goto out;
-	}
-
-	net_device->num_chn = 1 +
-		init_packet->msg.v5_msg.subchn_comp.num_subchannels;
-
-	/* wait for all sub channels to open */
-	wait_event(net_device->subchan_open,
-		   atomic_read(&net_device->open_chn) == net_device->num_chn);
+	if (net_device->num_chn > 1)
+		schedule_work(&rndis_device->subchan_work);
 
-	/* ignore failues from setting rss parameters, still have channels */
-	rndis_filter_set_rss_param(rndis_device, netvsc_hash_key);
 out:
+	/* if unavailable, just proceed with one queue */
 	if (ret) {
 		net_device->max_chn = 1;
 		net_device->num_chn = 1;
-- 
2.11.0
