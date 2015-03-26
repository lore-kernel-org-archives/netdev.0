From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next] hv_netvsc: Implement batching in send buffer
Date: Thu, 26 Mar 2015 09:03:37 -0700
Message-ID: <1427385817-17811-1-git-send-email-haiyangz@microsoft.com>
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With this patch, we can send out multiple RNDIS data packets in one send buffer
slot and one VMBus message. It reduces the overhead associated with VMBus messages.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h   |   16 +++-
 drivers/net/hyperv/netvsc.c       |  187 ++++++++++++++++++++++++++++---------
 drivers/net/hyperv/netvsc_drv.c   |    2 +
 drivers/net/hyperv/rndis_filter.c |    4 +
 4 files changed, 162 insertions(+), 47 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 4815843..384f057 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -131,6 +131,7 @@ struct hv_netvsc_packet {
 
 	struct hv_device *device;
 	bool is_data_pkt;
+	bool xmit_more; /* from skb */
 	u16 vlan_tci;
 
 	u16 q_idx;
@@ -596,7 +597,16 @@ struct nvsp_message {
 
 #define VRSS_SEND_TAB_SIZE 16
 
-/* Per netvsc channel-specific */
+#define RNDIS_MAX_PKT_DEFAULT 8
+#define RNDIS_PKT_ALIGN_DEFAULT 8
+
+struct multi_send_data {
+	spinlock_t lock; /* protect struct multi_send_data */
+	struct hv_netvsc_packet *pkt; /* netvsc pkt pending */
+	u32 count; /* counter of batched packets */
+};
+
+/* Per netvsc device */
 struct netvsc_device {
 	struct hv_device *dev;
 
@@ -647,6 +657,10 @@ struct netvsc_device {
 	unsigned char *cb_buffer;
 	/* The sub channel callback buffer */
 	unsigned char *sub_cb_buf;
+
+	struct multi_send_data msd[NR_CPUS];
+	u32 max_pkt; /* max number of pkt in one send, e.g. 8 */
+	u32 pkt_align; /* alignment bytes, e.g. 8 */
 };
 
 /* NdisInitialize message */
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 208eb05..b81bd37 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -37,6 +37,7 @@ static struct netvsc_device *alloc_net_device(struct hv_device *device)
 {
 	struct netvsc_device *net_device;
 	struct net_device *ndev = hv_get_drvdata(device);
+	int i;
 
 	net_device = kzalloc(sizeof(struct netvsc_device), GFP_KERNEL);
 	if (!net_device)
@@ -53,6 +54,11 @@ static struct netvsc_device *alloc_net_device(struct hv_device *device)
 	net_device->destroy = false;
 	net_device->dev = device;
 	net_device->ndev = ndev;
+	net_device->max_pkt = RNDIS_MAX_PKT_DEFAULT;
+	net_device->pkt_align = RNDIS_PKT_ALIGN_DEFAULT;
+
+	for (i = 0; i < num_online_cpus(); i++)
+		spin_lock_init(&net_device->msd[i].lock);
 
 	hv_set_drvdata(device, net_device);
 	return net_device;
@@ -687,12 +693,23 @@ static u32 netvsc_get_next_send_section(struct netvsc_device *net_device)
 
 static u32 netvsc_copy_to_send_buf(struct netvsc_device *net_device,
 				   unsigned int section_index,
+				   u32 pend_size,
 				   struct hv_netvsc_packet *packet)
 {
 	char *start = net_device->send_buf;
-	char *dest = (start + (section_index * net_device->send_section_size));
+	char *dest = start + (section_index * net_device->send_section_size)
+		     + pend_size;
 	int i;
 	u32 msg_size = 0;
+	u32 padding = 0;
+	u32 remain = packet->total_data_buflen % net_device->pkt_align;
+
+	/* Add padding */
+	if (packet->is_data_pkt && packet->xmit_more && remain) {
+		padding = net_device->pkt_align - remain;
+		packet->rndis_msg->msg_len += padding;
+		packet->total_data_buflen += padding;
+	}
 
 	for (i = 0; i < packet->page_buf_cnt; i++) {
 		char *src = phys_to_virt(packet->page_buf[i].pfn << PAGE_SHIFT);
@@ -703,67 +720,48 @@ static u32 netvsc_copy_to_send_buf(struct netvsc_device *net_device,
 		msg_size += len;
 		dest += len;
 	}
+
+	if (padding) {
+		memset(dest, 0, padding);
+		msg_size += padding;
+	}
+
 	return msg_size;
 }
 
-int netvsc_send(struct hv_device *device,
-			struct hv_netvsc_packet *packet)
+static inline int netvsc_send_pkt(
+	struct hv_netvsc_packet *packet,
+	struct netvsc_device *net_device)
 {
-	struct netvsc_device *net_device;
-	int ret = 0;
-	struct nvsp_message sendMessage;
-	struct net_device *ndev;
-	struct vmbus_channel *out_channel = NULL;
-	u64 req_id;
-	unsigned int section_index = NETVSC_INVALID_INDEX;
-	u32 msg_size = 0;
-	struct sk_buff *skb = NULL;
+	struct nvsp_message nvmsg;
+	struct vmbus_channel *out_channel = packet->channel;
 	u16 q_idx = packet->q_idx;
+	struct net_device *ndev = net_device->ndev;
+	u64 req_id;
+	int ret;
 
-
-	net_device = get_outbound_net_device(device);
-	if (!net_device)
-		return -ENODEV;
-	ndev = net_device->ndev;
-
-	sendMessage.hdr.msg_type = NVSP_MSG1_TYPE_SEND_RNDIS_PKT;
+	nvmsg.hdr.msg_type = NVSP_MSG1_TYPE_SEND_RNDIS_PKT;
 	if (packet->is_data_pkt) {
 		/* 0 is RMC_DATA; */
-		sendMessage.msg.v1_msg.send_rndis_pkt.channel_type = 0;
+		nvmsg.msg.v1_msg.send_rndis_pkt.channel_type = 0;
 	} else {
 		/* 1 is RMC_CONTROL; */
-		sendMessage.msg.v1_msg.send_rndis_pkt.channel_type = 1;
+		nvmsg.msg.v1_msg.send_rndis_pkt.channel_type = 1;
 	}
 
-	/* Attempt to send via sendbuf */
-	if (packet->total_data_buflen < net_device->send_section_size) {
-		section_index = netvsc_get_next_send_section(net_device);
-		if (section_index != NETVSC_INVALID_INDEX) {
-			msg_size = netvsc_copy_to_send_buf(net_device,
-							   section_index,
-							   packet);
-			skb = (struct sk_buff *)
-			      (unsigned long)packet->send_completion_tid;
-			packet->page_buf_cnt = 0;
-		}
-	}
-	packet->send_buf_index = section_index;
-
-
-	sendMessage.msg.v1_msg.send_rndis_pkt.send_buf_section_index =
-		section_index;
-	sendMessage.msg.v1_msg.send_rndis_pkt.send_buf_section_size = msg_size;
+	nvmsg.msg.v1_msg.send_rndis_pkt.send_buf_section_index =
+		packet->send_buf_index;
+	if (packet->send_buf_index == NETVSC_INVALID_INDEX)
+		nvmsg.msg.v1_msg.send_rndis_pkt.send_buf_section_size = 0;
+	else
+		nvmsg.msg.v1_msg.send_rndis_pkt.send_buf_section_size =
+			packet->total_data_buflen;
 
 	if (packet->send_completion)
 		req_id = (ulong)packet;
 	else
 		req_id = 0;
 
-	out_channel = net_device->chn_table[packet->q_idx];
-	if (out_channel == NULL)
-		out_channel = device->channel;
-	packet->channel = out_channel;
-
 	if (out_channel->rescind)
 		return -ENODEV;
 
@@ -771,11 +769,12 @@ int netvsc_send(struct hv_device *device,
 		ret = vmbus_sendpacket_pagebuffer(out_channel,
 						  packet->page_buf,
 						  packet->page_buf_cnt,
-						  &sendMessage,
+						  &nvmsg,
 						  sizeof(struct nvsp_message),
 						  req_id);
 	} else {
-		ret = vmbus_sendpacket(out_channel, &sendMessage,
+		ret = vmbus_sendpacket(
+				out_channel, &nvmsg,
 				sizeof(struct nvsp_message),
 				req_id,
 				VM_PKT_DATA_INBAND,
@@ -809,6 +808,102 @@ int netvsc_send(struct hv_device *device,
 			   packet, ret);
 	}
 
+	return ret;
+}
+
+int netvsc_send(struct hv_device *device,
+		struct hv_netvsc_packet *packet)
+{
+	struct netvsc_device *net_device;
+	int ret = 0, m_ret = 0;
+	struct vmbus_channel *out_channel;
+	u16 q_idx = packet->q_idx;
+	u32 pktlen = packet->total_data_buflen, msd_len = 0;
+	unsigned int section_index = NETVSC_INVALID_INDEX;
+	struct sk_buff *skb = NULL;
+	unsigned long flag;
+	struct multi_send_data *msdp;
+	struct hv_netvsc_packet *msd_send = NULL, *cur_send = NULL;
+
+	net_device = get_outbound_net_device(device);
+	if (!net_device)
+		return -ENODEV;
+
+	out_channel = net_device->chn_table[q_idx];
+	if (!out_channel) {
+		out_channel = device->channel;
+		q_idx = 0;
+		packet->q_idx = 0;
+	}
+	packet->channel = out_channel;
+	packet->send_buf_index = NETVSC_INVALID_INDEX;
+
+	msdp = &net_device->msd[q_idx];
+
+	/* batch packets in send buffer if possible */
+	spin_lock_irqsave(&msdp->lock, flag);
+	if (msdp->pkt)
+		msd_len = msdp->pkt->total_data_buflen;
+
+	if (packet->is_data_pkt && msd_len > 0 &&
+	    msdp->count < net_device->max_pkt &&
+	    msd_len + pktlen + net_device->pkt_align <
+	    net_device->send_section_size) {
+		section_index = msdp->pkt->send_buf_index;
+
+	} else if (packet->is_data_pkt && pktlen + net_device->pkt_align <
+		   net_device->send_section_size) {
+		section_index = netvsc_get_next_send_section(net_device);
+		if (section_index != NETVSC_INVALID_INDEX) {
+				msd_send = msdp->pkt;
+				msdp->pkt = NULL;
+				msdp->count = 0;
+				msd_len = 0;
+		}
+	}
+
+	if (section_index != NETVSC_INVALID_INDEX) {
+		netvsc_copy_to_send_buf(net_device,
+					section_index, msd_len,
+					packet);
+		skb = (struct sk_buff *)
+		       (unsigned long)packet->send_completion_tid;
+
+		packet->page_buf_cnt = 0;
+		packet->send_buf_index = section_index;
+		packet->total_data_buflen += msd_len;
+
+		kfree(msdp->pkt);
+		if (packet->xmit_more) {
+			msdp->pkt = packet;
+			msdp->count++;
+		} else {
+			cur_send = packet;
+			msdp->pkt = NULL;
+			msdp->count = 0;
+		}
+	} else {
+		msd_send = msdp->pkt;
+		msdp->pkt = NULL;
+		msdp->count = 0;
+		cur_send = packet;
+	}
+
+	spin_unlock_irqrestore(&msdp->lock, flag);
+
+	if (msd_send) {
+		m_ret = netvsc_send_pkt(msd_send, net_device);
+
+		if (m_ret != 0) {
+			netvsc_free_send_slot(net_device,
+					      msd_send->send_buf_index);
+			kfree(msd_send);
+		}
+	}
+
+	if (cur_send)
+		ret = netvsc_send_pkt(cur_send, net_device);
+
 	if (ret != 0) {
 		if (section_index != NETVSC_INVALID_INDEX)
 			netvsc_free_send_slot(net_device, section_index);
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index a06bd66..0c99818 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -413,6 +413,8 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 		return NETDEV_TX_OK;
 	}
 
+	packet->xmit_more = skb->xmit_more;
+
 	packet->vlan_tci = skb->vlan_tci;
 
 	packet->q_idx = skb_get_queue_mapping(skb);
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index ca81de0..a2b185a 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -237,6 +237,7 @@ static int rndis_filter_send_request(struct rndis_device *dev,
 	}
 
 	packet->send_completion = NULL;
+	packet->xmit_more = false;
 
 	ret = netvsc_send(dev->net_dev->dev, packet);
 	return ret;
@@ -855,6 +856,7 @@ static int rndis_filter_init_device(struct rndis_device *dev)
 	u32 status;
 	int ret;
 	unsigned long t;
+	struct netvsc_device *nvdev = dev->net_dev;
 
 	request = get_rndis_request(dev, RNDIS_MSG_INIT,
 			RNDIS_MESSAGE_SIZE(struct rndis_initialize_request));
@@ -889,6 +891,8 @@ static int rndis_filter_init_device(struct rndis_device *dev)
 	status = init_complete->status;
 	if (status == RNDIS_STATUS_SUCCESS) {
 		dev->state = RNDIS_DEV_INITIALIZED;
+		nvdev->max_pkt = init_complete->max_pkt_per_msg;
+		nvdev->pkt_align = 1 << init_complete->pkt_alignment_factor;
 		ret = 0;
 	} else {
 		dev->state = RNDIS_DEV_UNINITIALIZED;
-- 
1.7.4.1
