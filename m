From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH 4/6] hv_netvsc: get rid of struct net_device pointer in struct
 netvsc_device
Date: Thu, 12 May 2016 14:49:36 +0200
Message-ID: <1463057378-21118-5-git-send-email-vkuznets@redhat.com>
References: <1463057378-21118-1-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, Haiyang Zhang <haiyangz@microsoft.com>,
 linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1463057378-21118-1-git-send-email-vkuznets@redhat.com>
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

Simplify netvsvc pointer graph by getting rid of the redundant ndev
pointer. We can always get a pointer to struct net_device from somewhere
else.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 drivers/net/hyperv/hyperv_net.h   |  2 --
 drivers/net/hyperv/netvsc.c       | 30 ++++++++++++------------------
 drivers/net/hyperv/netvsc_drv.c   | 18 +++++++++---------
 drivers/net/hyperv/rndis_filter.c |  4 ++--
 4 files changed, 23 insertions(+), 31 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 6edc55f..16d22b3 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -701,8 +701,6 @@ struct netvsc_device {
 	struct nvsp_message revoke_packet;
 	/* unsigned char HwMacAddr[HW_MACADDR_LEN]; */
 
-	struct net_device *ndev;
-
 	struct vmbus_channel *chn_table[VRSS_CHANNEL_MAX];
 	u32 send_table[VRSS_SEND_TAB_SIZE];
 	u32 max_chn;
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index cc0af6a..f755b03 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -52,7 +52,6 @@ static struct netvsc_device *alloc_net_device(struct hv_device *device)
 
 	init_waitqueue_head(&net_device->wait_drain);
 	net_device->destroy = false;
-	net_device->ndev = ndev;
 	net_device->max_pkt = RNDIS_MAX_PKT_DEFAULT;
 	net_device->pkt_align = RNDIS_PKT_ALIGN_DEFAULT;
 
@@ -232,7 +231,7 @@ static int netvsc_init_buf(struct hv_device *device)
 	net_device = get_outbound_net_device(device);
 	if (!net_device)
 		return -ENODEV;
-	ndev = net_device->ndev;
+	ndev = hv_get_drvdata(device);
 
 	node = cpu_to_node(device->channel->target_cpu);
 	net_device->recv_buf = vzalloc_node(net_device->recv_buf_size, node);
@@ -422,6 +421,7 @@ static int negotiate_nvsp_ver(struct hv_device *device,
 			      struct nvsp_message *init_packet,
 			      u32 nvsp_ver)
 {
+	struct net_device *ndev = hv_get_drvdata(device);
 	int ret;
 	unsigned long t;
 
@@ -455,8 +455,7 @@ static int negotiate_nvsp_ver(struct hv_device *device,
 	/* NVSPv2 or later: Send NDIS config */
 	memset(init_packet, 0, sizeof(struct nvsp_message));
 	init_packet->hdr.msg_type = NVSP_MSG2_TYPE_SEND_NDIS_CONFIG;
-	init_packet->msg.v2_msg.send_ndis_config.mtu = net_device->ndev->mtu +
-						       ETH_HLEN;
+	init_packet->msg.v2_msg.send_ndis_config.mtu = ndev->mtu + ETH_HLEN;
 	init_packet->msg.v2_msg.send_ndis_config.capability.ieee8021q = 1;
 
 	if (nvsp_ver >= NVSP_PROTOCOL_VERSION_5)
@@ -476,7 +475,6 @@ static int netvsc_connect_vsp(struct hv_device *device)
 	struct netvsc_device *net_device;
 	struct nvsp_message *init_packet;
 	int ndis_version;
-	struct net_device *ndev;
 	u32 ver_list[] = { NVSP_PROTOCOL_VERSION_1, NVSP_PROTOCOL_VERSION_2,
 		NVSP_PROTOCOL_VERSION_4, NVSP_PROTOCOL_VERSION_5 };
 	int i, num_ver = 4; /* number of different NVSP versions */
@@ -484,7 +482,6 @@ static int netvsc_connect_vsp(struct hv_device *device)
 	net_device = get_outbound_net_device(device);
 	if (!net_device)
 		return -ENODEV;
-	ndev = net_device->ndev;
 
 	init_packet = &net_device->channel_init_pkt;
 
@@ -737,6 +734,7 @@ static u32 netvsc_copy_to_send_buf(struct netvsc_device *net_device,
 }
 
 static inline int netvsc_send_pkt(
+	struct hv_device *device,
 	struct hv_netvsc_packet *packet,
 	struct netvsc_device *net_device,
 	struct hv_page_buffer **pb,
@@ -745,7 +743,7 @@ static inline int netvsc_send_pkt(
 	struct nvsp_message nvmsg;
 	u16 q_idx = packet->q_idx;
 	struct vmbus_channel *out_channel = net_device->chn_table[q_idx];
-	struct net_device *ndev = net_device->ndev;
+	struct net_device *ndev = hv_get_drvdata(device);
 	u64 req_id;
 	int ret;
 	struct hv_page_buffer *pgbuf;
@@ -940,7 +938,8 @@ int netvsc_send(struct hv_device *device,
 	}
 
 	if (msd_send) {
-		m_ret = netvsc_send_pkt(msd_send, net_device, NULL, msd_skb);
+		m_ret = netvsc_send_pkt(device, msd_send, net_device,
+					NULL, msd_skb);
 
 		if (m_ret != 0) {
 			netvsc_free_send_slot(net_device,
@@ -951,7 +950,7 @@ int netvsc_send(struct hv_device *device,
 
 send_now:
 	if (cur_send)
-		ret = netvsc_send_pkt(cur_send, net_device, pb, skb);
+		ret = netvsc_send_pkt(device, cur_send, net_device, pb, skb);
 
 	if (ret != 0 && section_index != NETVSC_INVALID_INDEX)
 		netvsc_free_send_slot(net_device, section_index);
@@ -967,9 +966,7 @@ static void netvsc_send_recv_completion(struct hv_device *device,
 	struct nvsp_message recvcompMessage;
 	int retries = 0;
 	int ret;
-	struct net_device *ndev;
-
-	ndev = net_device->ndev;
+	struct net_device *ndev = hv_get_drvdata(device);
 
 	recvcompMessage.hdr.msg_type =
 				NVSP_MSG1_TYPE_SEND_RNDIS_PKT_COMPLETE;
@@ -1016,11 +1013,9 @@ static void netvsc_receive(struct netvsc_device *net_device,
 	u32 status = NVSP_STAT_SUCCESS;
 	int i;
 	int count = 0;
-	struct net_device *ndev;
+	struct net_device *ndev = hv_get_drvdata(device);
 	void *data;
 
-	ndev = net_device->ndev;
-
 	/*
 	 * All inbound packets other than send completion should be xfer page
 	 * packet
@@ -1076,14 +1071,13 @@ static void netvsc_send_table(struct hv_device *hdev,
 			      struct nvsp_message *nvmsg)
 {
 	struct netvsc_device *nvscdev;
-	struct net_device *ndev;
+	struct net_device *ndev = hv_get_drvdata(hdev);
 	int i;
 	u32 count, *tab;
 
 	nvscdev = get_outbound_net_device(hdev);
 	if (!nvscdev)
 		return;
-	ndev = nvscdev->ndev;
 
 	count = nvmsg->msg.v5_msg.send_table.count;
 	if (count != VRSS_SEND_TAB_SIZE) {
@@ -1142,7 +1136,7 @@ void netvsc_channel_cb(void *context)
 	net_device = get_inbound_net_device(device);
 	if (!net_device)
 		return;
-	ndev = net_device->ndev;
+	ndev = hv_get_drvdata(device);
 	buffer = get_per_channel_state(channel);
 
 	do {
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index feaa7af..393403a 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -67,18 +67,19 @@ static void do_set_multicast(struct work_struct *w)
 {
 	struct net_device_context *ndevctx =
 		container_of(w, struct net_device_context, work);
-	struct netvsc_device *nvdev;
+	struct hv_device *device_obj = ndevctx->device_ctx;
+	struct net_device *ndev = hv_get_drvdata(device_obj);
+	struct netvsc_device *nvdev = ndevctx->nvdev;
 	struct rndis_device *rdev;
 
-	nvdev = ndevctx->nvdev;
-	if (nvdev == NULL || nvdev->ndev == NULL)
+	if (!nvdev)
 		return;
 
 	rdev = nvdev->extension;
 	if (rdev == NULL)
 		return;
 
-	if (nvdev->ndev->flags & IFF_PROMISC)
+	if (ndev->flags & IFF_PROMISC)
 		rndis_filter_set_packet_filter(rdev,
 			NDIS_PACKET_TYPE_PROMISCUOUS);
 	else
@@ -998,23 +999,22 @@ static const struct net_device_ops device_ops = {
  */
 static void netvsc_link_change(struct work_struct *w)
 {
-	struct net_device_context *ndev_ctx;
-	struct net_device *net;
+	struct net_device_context *ndev_ctx =
+		container_of(w, struct net_device_context, dwork.work);
+	struct hv_device *device_obj = ndev_ctx->device_ctx;
+	struct net_device *net = hv_get_drvdata(device_obj);
 	struct netvsc_device *net_device;
 	struct rndis_device *rdev;
 	struct netvsc_reconfig *event = NULL;
 	bool notify = false, reschedule = false;
 	unsigned long flags, next_reconfig, delay;
 
-	ndev_ctx = container_of(w, struct net_device_context, dwork.work);
-
 	rtnl_lock();
 	if (ndev_ctx->start_remove)
 		goto out_unlock;
 
 	net_device = ndev_ctx->nvdev;
 	rdev = net_device->extension;
-	net = net_device->ndev;
 
 	next_reconfig = ndev_ctx->last_reconfig + LINKCHANGE_INT;
 	if (time_is_after_jiffies(next_reconfig)) {
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 03ebce8..681ef8b 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -1061,8 +1061,8 @@ int rndis_filter_device_add(struct hv_device *dev,
 	ret = rndis_filter_query_device(rndis_device,
 					RNDIS_OID_GEN_MAXIMUM_FRAME_SIZE,
 					&mtu, &size);
-	if (ret == 0 && size == sizeof(u32) && mtu < net_device->ndev->mtu)
-		net_device->ndev->mtu = mtu;
+	if (ret == 0 && size == sizeof(u32) && mtu < net->mtu)
+		net->mtu = mtu;
 
 	/* Get the mac address */
 	ret = rndis_filter_query_device_mac(rndis_device);
-- 
2.5.5
