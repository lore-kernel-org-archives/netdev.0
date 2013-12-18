From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next] hyperv: Add support for Virtual Receive Side Scaling
 (vRSS)
Date: Wed, 18 Dec 2013 14:21:02 -0800
Message-ID: <1387405262-18334-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, jasowang@redhat.com, driverdev-devel@linuxdriverproject.org,
 linux-kernel@vger.kernel.org, haiyangz@microsoft.com
To: davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

This feature allows multiple channels to be used by each virtual NIC.
It is available on Hyper-V host 2012 R2.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h   |  159 ++++++++++++++++++++++++++++++++++
 drivers/net/hyperv/netvsc.c       |  120 ++++++++++++++++++++------
 drivers/net/hyperv/netvsc_drv.c   |   94 +++++++++++++++++++-
 drivers/net/hyperv/rndis_filter.c |  171 ++++++++++++++++++++++++++++++++++++-
 4 files changed, 511 insertions(+), 33 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index a26eecb..055ab94 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -28,6 +28,98 @@
 #include <linux/hyperv.h>
 #include <linux/rndis.h>
 
+/* RSS related */
+#define OID_GEN_RECEIVE_SCALE_CAPABILITIES 0x00010203  /* query only */
+#define OID_GEN_RECEIVE_SCALE_PARAMETERS 0x00010204  /* query and set */
+
+#define NDIS_OBJECT_TYPE_RSS_CAPABILITIES 0x88
+#define NDIS_OBJECT_TYPE_RSS_PARAMETERS 0x89
+
+#define NDIS_RECEIVE_SCALE_CAPABILITIES_REVISION_2 2
+#define NDIS_RECEIVE_SCALE_PARAMETERS_REVISION_2 2
+
+struct ndis_obj_header {
+	u8 type;
+	u8 rev;
+	u16 size;
+} __packed;
+
+
+/* ndis_recv_scale_cap/cap_flag */
+#define NDIS_RSS_CAPS_MESSAGE_SIGNALED_INTERRUPTS 0x01000000
+#define NDIS_RSS_CAPS_CLASSIFICATION_AT_ISR       0x02000000
+#define NDIS_RSS_CAPS_CLASSIFICATION_AT_DPC       0x04000000
+#define NDIS_RSS_CAPS_USING_MSI_X                 0x08000000
+#define NDIS_RSS_CAPS_RSS_AVAILABLE_ON_PORTS      0x10000000
+#define NDIS_RSS_CAPS_SUPPORTS_MSI_X              0x20000000
+#define NDIS_RSS_CAPS_HASH_TYPE_TCP_IPV4          0x00000100
+#define NDIS_RSS_CAPS_HASH_TYPE_TCP_IPV6          0x00000200
+#define NDIS_RSS_CAPS_HASH_TYPE_TCP_IPV6_EX       0x00000400
+
+struct ndis_recv_scale_cap { /* NDIS_RECEIVE_SCALE_CAPABILITIES */
+	struct ndis_obj_header hdr;
+	u32 cap_flag;
+	u32 num_int_msg;
+	u32 num_recv_que;
+	u16 num_indirect_tabent;
+} __packed;
+
+
+/* ndis_recv_scale_param flags */
+#define NDIS_RSS_PARAM_FLAG_BASE_CPU_UNCHANGED     0x0001
+#define NDIS_RSS_PARAM_FLAG_HASH_INFO_UNCHANGED    0x0002
+#define NDIS_RSS_PARAM_FLAG_ITABLE_UNCHANGED       0x0004
+#define NDIS_RSS_PARAM_FLAG_HASH_KEY_UNCHANGED     0x0008
+#define NDIS_RSS_PARAM_FLAG_DISABLE_RSS            0x0010
+
+/* Hash info bits */
+#define NDIS_HASH_FUNC_TOEPLITZ 0x00000001
+#define NDIS_HASH_IPV4          0x00000100
+#define NDIS_HASH_TCP_IPV4      0x00000200
+#define NDIS_HASH_IPV6          0x00000400
+#define NDIS_HASH_IPV6_EX       0x00000800
+#define NDIS_HASH_TCP_IPV6      0x00001000
+#define NDIS_HASH_TCP_IPV6_EX   0x00002000
+
+#define NDIS_RSS_INDIRECTION_TABLE_MAX_SIZE_REVISION_2 (128 * 4)
+#define NDIS_RSS_HASH_SECRET_KEY_MAX_SIZE_REVISION_2   40
+
+#define ITAB_NUM 128
+#define HASH_KEYLEN NDIS_RSS_HASH_SECRET_KEY_MAX_SIZE_REVISION_2
+extern u8 hash_key[];
+
+struct ndis_recv_scale_param { /* NDIS_RECEIVE_SCALE_PARAMETERS */
+	struct ndis_obj_header hdr;
+
+	/* Qualifies the rest of the information */
+	u16 flag;
+
+	/* The base CPU number to do receive processing. not used */
+	u16 base_cpu_number;
+
+	/* This describes the hash function and type being enabled */
+	u32 hashinfo;
+
+	/* The size of indirection table array */
+	u16 indirect_tabsize;
+
+	/* The offset of the indirection table from the beginning of this
+	 * structure
+	 */
+	u32 indirect_taboffset;
+
+	/* The size of the hash secret key */
+	u16 hashkey_size;
+
+	/* The offset of the secret key from the beginning of this structure */
+	u32 kashkey_offset;
+
+	u32 processor_masks_offset;
+	u32 num_processor_masks;
+	u32 processor_masks_entry_size;
+};
+
+
 /* Fwd declaration */
 struct hv_netvsc_packet;
 
@@ -38,6 +130,8 @@ struct xferpage_packet {
 
 	/* # of netvsc packets this xfer packet contains */
 	u32 count;
+
+	struct vmbus_channel *channel;
 };
 
 /*
@@ -53,6 +147,9 @@ struct hv_netvsc_packet {
 	bool is_data_pkt;
 	u16 vlan_tci;
 
+	bool is_hash;
+	u32 hash;
+
 	/*
 	 * Valid only for receives when we break a xfer page packet
 	 * into multiple netvsc packets
@@ -118,6 +215,7 @@ void netvsc_linkstatus_callback(struct hv_device *device_obj,
 				unsigned int status);
 int netvsc_recv_callback(struct hv_device *device_obj,
 			struct hv_netvsc_packet *packet);
+extern void netvsc_channel_cb(void *context);
 int rndis_filter_open(struct hv_device *dev);
 int rndis_filter_close(struct hv_device *dev);
 int rndis_filter_device_add(struct hv_device *dev,
@@ -134,11 +232,15 @@ int rndis_filter_send(struct hv_device *dev,
 int rndis_filter_set_packet_filter(struct rndis_device *dev, u32 new_filter);
 int rndis_filter_set_device_mac(struct hv_device *hdev, char *mac);
 
+extern int ring_size;
+
 
 #define NVSP_INVALID_PROTOCOL_VERSION	((u32)0xFFFFFFFF)
 
 #define NVSP_PROTOCOL_VERSION_1		2
 #define NVSP_PROTOCOL_VERSION_2		0x30002
+#define NVSP_PROTOCOL_VERSION_4		0x40000
+#define NVSP_PROTOCOL_VERSION_5		0x50000
 
 enum {
 	NVSP_MSG_TYPE_NONE = 0,
@@ -193,6 +295,23 @@ enum {
 
 	NVSP_MSG2_TYPE_ALLOC_CHIMNEY_HANDLE,
 	NVSP_MSG2_TYPE_ALLOC_CHIMNEY_HANDLE_COMP,
+
+	NVSP_MSG2_MAX = NVSP_MSG2_TYPE_ALLOC_CHIMNEY_HANDLE_COMP,
+
+	/* Version 4 messages */
+	NVSP_MSG4_TYPE_SEND_VF_ASSOCIATION,
+	NVSP_MSG4_TYPE_SWITCH_DATA_PATH,
+	NVSP_MSG4_TYPE_UPLINK_CONNECT_STATE_DEPRECATED,
+
+	NVSP_MSG4_MAX = NVSP_MSG4_TYPE_UPLINK_CONNECT_STATE_DEPRECATED,
+
+	/* Version 5 messages */
+	NVSP_MSG5_TYPE_OID_QUERY_EX,
+	NVSP_MSG5_TYPE_OID_QUERY_EX_COMP,
+	NVSP_MSG5_TYPE_SUBCHANNEL,
+	NVSP_MSG5_TYPE_SEND_INDIRECTION_TABLE,
+
+	NVSP_MSG5_MAX = NVSP_MSG5_TYPE_SEND_INDIRECTION_TABLE,
 };
 
 enum {
@@ -447,10 +566,44 @@ union nvsp_2_message_uber {
 	struct nvsp_2_free_rxbuf free_rxbuf;
 } __packed;
 
+enum nvsp_subchannel_operation {
+	NVSP_SUBCHANNEL_NONE = 0,
+	NVSP_SUBCHANNEL_ALLOCATE,
+	NVSP_SUBCHANNEL_MAX
+};
+
+struct nvsp_5_subchannel_request {
+	u32 op;
+	u32 num_subchannels;
+} __packed;
+
+struct nvsp_5_subchannel_complete {
+	u32 status;
+	u32 num_subchannels; /* Actual number of subchannels allocated */
+} __packed;
+
+struct nvsp_5_send_indirect_table {
+	/* The number of entries in the send indirection table */
+	u32 count;
+
+	/* The offset of the send indireciton table from top of this struct.
+	 * The send indirection table tells which channel to put the send
+	 * traffic on. Each entry is a channel number.
+	 */
+	u32 offset;
+} __packed;
+
+union nvsp_5_message_uber {
+	struct nvsp_5_subchannel_request subchn_req;
+	struct nvsp_5_subchannel_complete subchn_comp;
+	struct nvsp_5_send_indirect_table send_table;
+} __packed;
+
 union nvsp_all_messages {
 	union nvsp_message_init_uber init_msg;
 	union nvsp_1_message_uber v1_msg;
 	union nvsp_2_message_uber v2_msg;
+	union nvsp_5_message_uber v5_msg;
 } __packed;
 
 /* ALL Messages */
@@ -471,6 +624,8 @@ struct nvsp_message {
 
 #define NETVSC_PACKET_SIZE                      2048
 
+#define VRSS_SEND_TAB_SIZE 16
+
 /* Per netvsc channel-specific */
 struct netvsc_device {
 	struct hv_device *dev;
@@ -504,6 +659,10 @@ struct netvsc_device {
 
 	struct net_device *ndev;
 
+	struct vmbus_channel *chn_table[NR_CPUS];
+	u32 send_table[VRSS_SEND_TAB_SIZE];
+	u32 num_chn;
+
 	/* Holds rndis device info */
 	void *extension;
 };
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 93b485b..023d649 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -293,7 +293,7 @@ static int negotiate_nvsp_ver(struct hv_device *device,
 	    NVSP_STAT_SUCCESS)
 		return -EINVAL;
 
-	if (nvsp_ver != NVSP_PROTOCOL_VERSION_2)
+	if (nvsp_ver == NVSP_PROTOCOL_VERSION_1)
 		return 0;
 
 	/* NVSPv2 only: Send NDIS config */
@@ -317,6 +317,9 @@ static int netvsc_connect_vsp(struct hv_device *device)
 	struct nvsp_message *init_packet;
 	int ndis_version;
 	struct net_device *ndev;
+	u32 ver_list[] = {NVSP_PROTOCOL_VERSION_1, NVSP_PROTOCOL_VERSION_2,
+		NVSP_PROTOCOL_VERSION_4, NVSP_PROTOCOL_VERSION_5};
+	int i, num_ver = 4; /* number of different NVSP versions */
 
 	net_device = get_outbound_net_device(device);
 	if (!net_device)
@@ -326,13 +329,14 @@ static int netvsc_connect_vsp(struct hv_device *device)
 	init_packet = &net_device->channel_init_pkt;
 
 	/* Negotiate the latest NVSP protocol supported */
-	if (negotiate_nvsp_ver(device, net_device, init_packet,
-			       NVSP_PROTOCOL_VERSION_2) == 0) {
-		net_device->nvsp_version = NVSP_PROTOCOL_VERSION_2;
-	} else if (negotiate_nvsp_ver(device, net_device, init_packet,
-				    NVSP_PROTOCOL_VERSION_1) == 0) {
-		net_device->nvsp_version = NVSP_PROTOCOL_VERSION_1;
-	} else {
+	for (i = num_ver - 1; i >= 0; i--)
+		if (negotiate_nvsp_ver(device, net_device, init_packet,
+			ver_list[i])  == 0) {
+			net_device->nvsp_version = ver_list[i];
+			break;
+		}
+
+	if (i < 0) {
 		ret = -EPROTO;
 		goto cleanup;
 	}
@@ -342,7 +346,10 @@ static int netvsc_connect_vsp(struct hv_device *device)
 	/* Send the ndis version */
 	memset(init_packet, 0, sizeof(struct nvsp_message));
 
-	ndis_version = 0x00050001;
+	if (net_device->nvsp_version <= NVSP_PROTOCOL_VERSION_4)
+		ndis_version = 0x00050001;
+	else
+		ndis_version = 0x0006001e;
 
 	init_packet->hdr.msg_type = NVSP_MSG1_TYPE_SEND_NDIS_VER;
 	init_packet->msg.v1_msg.
@@ -455,7 +462,9 @@ static void netvsc_send_completion(struct hv_device *device,
 	    (nvsp_packet->hdr.msg_type ==
 	     NVSP_MSG1_TYPE_SEND_RECV_BUF_COMPLETE) ||
 	    (nvsp_packet->hdr.msg_type ==
-	     NVSP_MSG1_TYPE_SEND_SEND_BUF_COMPLETE)) {
+	     NVSP_MSG1_TYPE_SEND_SEND_BUF_COMPLETE) ||
+	    (nvsp_packet->hdr.msg_type ==
+	     NVSP_MSG5_TYPE_SUBCHANNEL)) {
 		/* Copy the response back */
 		memcpy(&net_device->channel_init_pkt, nvsp_packet,
 		       sizeof(struct nvsp_message));
@@ -484,7 +493,7 @@ static void netvsc_send_completion(struct hv_device *device,
 			(hv_ringbuf_avail_percent(&device->channel->outbound)
 			> RING_AVAIL_PERCENT_HIWATER ||
 			num_outstanding_sends < 1))
-				netif_wake_queue(ndev);
+				netif_tx_wake_all_queues(ndev);
 	} else {
 		netdev_err(ndev, "Unknown send completion packet type- "
 			   "%d received!!\n", nvsp_packet->hdr.msg_type);
@@ -499,6 +508,7 @@ int netvsc_send(struct hv_device *device,
 	int ret = 0;
 	struct nvsp_message sendMessage;
 	struct net_device *ndev;
+	struct vmbus_channel *out_channel = NULL;
 	u64 req_id;
 
 	net_device = get_outbound_net_device(device);
@@ -525,15 +535,21 @@ int netvsc_send(struct hv_device *device,
 	else
 		req_id = 0;
 
+	if (packet->is_hash)
+		out_channel = net_device->chn_table[net_device->send_table[
+					packet->hash % VRSS_SEND_TAB_SIZE]];
+	if (out_channel == NULL)
+		out_channel = device->channel;
+
 	if (packet->page_buf_cnt) {
-		ret = vmbus_sendpacket_pagebuffer(device->channel,
+		ret = vmbus_sendpacket_pagebuffer(out_channel,
 						  packet->page_buf,
 						  packet->page_buf_cnt,
 						  &sendMessage,
 						  sizeof(struct nvsp_message),
 						  req_id);
 	} else {
-		ret = vmbus_sendpacket(device->channel, &sendMessage,
+		ret = vmbus_sendpacket(out_channel, &sendMessage,
 				sizeof(struct nvsp_message),
 				req_id,
 				VM_PKT_DATA_INBAND,
@@ -544,15 +560,15 @@ int netvsc_send(struct hv_device *device,
 		atomic_inc(&net_device->num_outstanding_sends);
 		if (hv_ringbuf_avail_percent(&device->channel->outbound) <
 			RING_AVAIL_PERCENT_LOWATER) {
-			netif_stop_queue(ndev);
+			netif_tx_stop_all_queues(ndev);
 			if (atomic_read(&net_device->
 				num_outstanding_sends) < 1)
-				netif_wake_queue(ndev);
+				netif_tx_wake_all_queues(ndev);
 		}
 	} else if (ret == -EAGAIN) {
-		netif_stop_queue(ndev);
+		netif_tx_stop_all_queues(ndev);
 		if (atomic_read(&net_device->num_outstanding_sends) < 1) {
-			netif_wake_queue(ndev);
+			netif_tx_wake_all_queues(ndev);
 			ret = -ENOSPC;
 		}
 	} else {
@@ -564,6 +580,7 @@ int netvsc_send(struct hv_device *device,
 }
 
 static void netvsc_send_recv_completion(struct hv_device *device,
+					struct vmbus_channel *channel,
 					u64 transaction_id, u32 status)
 {
 	struct nvsp_message recvcompMessage;
@@ -581,7 +598,7 @@ static void netvsc_send_recv_completion(struct hv_device *device,
 
 retry_send_cmplt:
 	/* Send the completion */
-	ret = vmbus_sendpacket(device->channel, &recvcompMessage,
+	ret = vmbus_sendpacket(channel, &recvcompMessage,
 			       sizeof(struct nvsp_message), transaction_id,
 			       VM_PKT_COMP, 0);
 	if (ret == 0) {
@@ -612,6 +629,7 @@ static void netvsc_receive_completion(void *context)
 {
 	struct hv_netvsc_packet *packet = context;
 	struct hv_device *device = packet->device;
+	struct vmbus_channel *channel;
 	struct netvsc_device *net_device;
 	u64 transaction_id = 0;
 	bool fsend_receive_comp = false;
@@ -643,6 +661,7 @@ static void netvsc_receive_completion(void *context)
 	 */
 	if (packet->xfer_page_pkt->count == 0) {
 		fsend_receive_comp = true;
+		channel = packet->xfer_page_pkt->channel;
 		transaction_id = packet->completion.recv.recv_completion_tid;
 		status = packet->xfer_page_pkt->status;
 		list_add_tail(&packet->xfer_page_pkt->list_ent,
@@ -656,12 +675,14 @@ static void netvsc_receive_completion(void *context)
 
 	/* Send a receive completion for the xfer page packet */
 	if (fsend_receive_comp)
-		netvsc_send_recv_completion(device, transaction_id, status);
+		netvsc_send_recv_completion(device, channel,
+					    transaction_id, status);
 
 }
 
 static void netvsc_receive(struct hv_device *device,
-			    struct vmpacket_descriptor *packet)
+			   struct vmbus_channel *channel,
+			   struct vmpacket_descriptor *packet)
 {
 	struct netvsc_device *net_device;
 	struct vmtransfer_page_packet_header *vmxferpage_packet;
@@ -744,7 +765,7 @@ static void netvsc_receive(struct hv_device *device,
 		spin_unlock_irqrestore(&net_device->recv_pkt_list_lock,
 				       flags);
 
-		netvsc_send_recv_completion(device,
+		netvsc_send_recv_completion(device, channel,
 					    vmxferpage_packet->d.trans_id,
 					    NVSP_STAT_FAIL);
 
@@ -755,6 +776,7 @@ static void netvsc_receive(struct hv_device *device,
 	xferpage_packet = (struct xferpage_packet *)listHead.next;
 	list_del(&xferpage_packet->list_ent);
 	xferpage_packet->status = NVSP_STAT_SUCCESS;
+	xferpage_packet->channel = channel;
 
 	/* This is how much we can satisfy */
 	xferpage_packet->count = count - 1;
@@ -796,10 +818,45 @@ static void netvsc_receive(struct hv_device *device,
 
 }
 
-static void netvsc_channel_cb(void *context)
+
+static void netvsc_send_table(struct hv_device *hdev,
+			      struct vmpacket_descriptor *vmpkt)
+{
+	struct netvsc_device *nvscdev;
+	struct net_device *ndev;
+	struct nvsp_message *nvmsg;
+	int i;
+	u32 count, *tab;
+
+	nvscdev = get_outbound_net_device(hdev);
+	if (!nvscdev)
+		return;
+	ndev = nvscdev->ndev;
+
+	nvmsg = (struct nvsp_message *)((unsigned long)vmpkt +
+					(vmpkt->offset8 << 3));
+
+	if (nvmsg->hdr.msg_type != NVSP_MSG5_TYPE_SEND_INDIRECTION_TABLE)
+		return;
+
+	count = nvmsg->msg.v5_msg.send_table.count;
+	if (count != VRSS_SEND_TAB_SIZE) {
+		netdev_err(ndev, "Received wrong send-table size:%u\n", count);
+		return;
+	}
+
+	tab = (u32 *)((unsigned long)&nvmsg->msg.v5_msg.send_table +
+		      nvmsg->msg.v5_msg.send_table.offset);
+
+	for (i = 0; i < count; i++)
+		nvscdev->send_table[i] = tab[i];
+}
+
+void netvsc_channel_cb(void *context)
 {
 	int ret;
-	struct hv_device *device = context;
+	struct vmbus_channel *channel = (struct vmbus_channel *)context;
+	struct hv_device *device;
 	struct netvsc_device *net_device;
 	u32 bytes_recvd;
 	u64 request_id;
@@ -809,6 +866,11 @@ static void netvsc_channel_cb(void *context)
 	int bufferlen = NETVSC_PACKET_SIZE;
 	struct net_device *ndev;
 
+	if (channel->primary_channel != NULL)
+		device = channel->primary_channel->device_obj;
+	else
+		device = channel->device_obj;
+
 	packet = kzalloc(NETVSC_PACKET_SIZE * sizeof(unsigned char),
 			 GFP_ATOMIC);
 	if (!packet)
@@ -821,7 +883,7 @@ static void netvsc_channel_cb(void *context)
 	ndev = net_device->ndev;
 
 	do {
-		ret = vmbus_recvpacket_raw(device->channel, buffer, bufferlen,
+		ret = vmbus_recvpacket_raw(channel, buffer, bufferlen,
 					   &bytes_recvd, &request_id);
 		if (ret == 0) {
 			if (bytes_recvd > 0) {
@@ -832,7 +894,11 @@ static void netvsc_channel_cb(void *context)
 					break;
 
 				case VM_PKT_DATA_USING_XFER_PAGES:
-					netvsc_receive(device, desc);
+					netvsc_receive(device, channel, desc);
+					break;
+
+				case VM_PKT_DATA_INBAND:
+					netvsc_send_table(device, desc);
 					break;
 
 				default:
@@ -928,7 +994,7 @@ int netvsc_device_add(struct hv_device *device, void *additional_info)
 	/* Open the channel */
 	ret = vmbus_open(device->channel, ring_size * PAGE_SIZE,
 			 ring_size * PAGE_SIZE, NULL, 0,
-			 netvsc_channel_cb, device);
+			 netvsc_channel_cb, device->channel);
 
 	if (ret != 0) {
 		netdev_err(ndev, "unable to open channel: %d\n", ret);
@@ -938,6 +1004,8 @@ int netvsc_device_add(struct hv_device *device, void *additional_info)
 	/* Channel is opened */
 	pr_info("hv_netvsc channel opened successfully\n");
 
+	net_device->chn_table[0] = device->channel;
+
 	/* Connect with the NetVsp */
 	ret = netvsc_connect_vsp(device);
 	if (ret != 0) {
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 9184c82..88ce01e 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -48,7 +48,7 @@ struct net_device_context {
 };
 
 #define RING_SIZE_MIN 64
-static int ring_size = 128;
+int ring_size = 128;
 module_param(ring_size, int, S_IRUGO);
 MODULE_PARM_DESC(ring_size, "Ring buffer size (# of pages)");
 
@@ -97,7 +97,7 @@ static int netvsc_open(struct net_device *net)
 		return ret;
 	}
 
-	netif_start_queue(net);
+	netif_tx_start_all_queues(net);
 
 	return ret;
 }
@@ -119,6 +119,68 @@ static int netvsc_close(struct net_device *net)
 	return ret;
 }
 
+union sub_key {
+	u64 k;
+	struct {
+		u8 pad[3];
+		u8 kb;
+		u32 ka;
+	};
+};
+
+/* Toeplitz hash function
+ * data: network byte order
+ * return: host byte order
+ */
+static u32 comp_hash(u8 *key, int klen, u8 *data, int dlen)
+{
+	union sub_key subk;
+	int k_next = 4;
+	u8 dt;
+	int i, j;
+	u32 ret = 0;
+
+	subk.k = 0;
+	subk.ka = ntohl(*(u32 *)key);
+
+	for (i = 0; i < dlen; i++) {
+		subk.kb = key[k_next];
+		k_next = (k_next + 1) % klen;
+		dt = data[i];
+		for (j = 0; j < 8; j++) {
+			if (dt & 0x80)
+				ret ^= subk.ka;
+			dt <<= 1;
+			subk.k <<= 1;
+		}
+	}
+
+	return ret;
+}
+
+static void netvsc_set_hash(struct hv_netvsc_packet *pkt, struct sk_buff *skb)
+{
+	struct iphdr *iphdr;
+	int data_len;
+
+	pkt->is_hash = false;
+
+	if (eth_hdr(skb)->h_proto != htons(ETH_P_IP))
+		return;
+
+	iphdr = ip_hdr(skb);
+
+	if (iphdr->version == 4) {
+		if (iphdr->protocol == IPPROTO_TCP)
+			data_len = 12;
+		else
+			data_len = 8;
+		pkt->hash = comp_hash(hash_key, HASH_KEYLEN,
+				      (u8 *)&iphdr->saddr, data_len);
+		pkt->is_hash = true;
+	}
+}
+
 static void netvsc_xmit_completion(void *context)
 {
 	struct hv_netvsc_packet *packet = (struct hv_netvsc_packet *)context;
@@ -134,6 +196,8 @@ static void netvsc_xmit_completion(void *context)
 static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 {
 	struct net_device_context *net_device_ctx = netdev_priv(net);
+	struct hv_device *hdev =  net_device_ctx->device_ctx;
+	struct netvsc_device *nvdev = hv_get_drvdata(hdev);
 	struct hv_netvsc_packet *packet;
 	int ret;
 	unsigned int i, num_pages, npg_data;
@@ -163,6 +227,11 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 				sizeof(struct hv_netvsc_packet) +
 				    (num_pages * sizeof(struct hv_page_buffer));
 
+	if (nvdev && nvdev->num_chn > 1)
+		netvsc_set_hash(packet, skb);
+	else
+		packet->is_hash = false;
+
 	/* If the rndis msg goes beyond 1 page, we will add 1 later */
 	packet->page_buf_cnt = num_pages - 1;
 
@@ -288,6 +357,9 @@ int netvsc_recv_callback(struct hv_device *device_obj,
 		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
 				       packet->vlan_tci);
 
+	skb_record_rx_queue(skb, packet->xfer_page_pkt->channel->
+		offermsg.offer.sub_channel_index % net->real_num_rx_queues);
+
 	net->stats.rx_packets++;
 	net->stats.rx_bytes += packet->total_data_buflen;
 
@@ -319,7 +391,7 @@ static int netvsc_change_mtu(struct net_device *ndev, int mtu)
 	if (nvdev == NULL || nvdev->destroy)
 		return -ENODEV;
 
-	if (nvdev->nvsp_version == NVSP_PROTOCOL_VERSION_2)
+	if (nvdev->nvsp_version >= NVSP_PROTOCOL_VERSION_2)
 		limit = NETVSC_MTU;
 
 	if (mtu < 68 || mtu > limit)
@@ -337,7 +409,7 @@ static int netvsc_change_mtu(struct net_device *ndev, int mtu)
 	hv_set_drvdata(hdev, ndev);
 	device_info.ring_size = ring_size;
 	rndis_filter_device_add(hdev, &device_info);
-	netif_wake_queue(ndev);
+	netif_tx_wake_all_queues(ndev);
 
 	return 0;
 }
@@ -411,9 +483,11 @@ static int netvsc_probe(struct hv_device *dev,
 	struct net_device *net = NULL;
 	struct net_device_context *net_device_ctx;
 	struct netvsc_device_info device_info;
+	struct netvsc_device *nvdev;
 	int ret;
 
-	net = alloc_etherdev(sizeof(struct net_device_context));
+	net = alloc_etherdev_mq(sizeof(struct net_device_context),
+				num_online_cpus());
 	if (!net)
 		return -ENOMEM;
 
@@ -435,6 +509,9 @@ static int netvsc_probe(struct hv_device *dev,
 	SET_ETHTOOL_OPS(net, &ethtool_ops);
 	SET_NETDEV_DEV(net, &dev->device);
 
+	netif_set_real_num_tx_queues(net, 1);
+	netif_set_real_num_rx_queues(net, 1);
+
 	ret = register_netdev(net);
 	if (ret != 0) {
 		pr_err("Unable to register netdev.\n");
@@ -453,6 +530,13 @@ static int netvsc_probe(struct hv_device *dev,
 		return ret;
 	}
 	memcpy(net->dev_addr, device_info.mac_adr, ETH_ALEN);
+	nvdev = hv_get_drvdata(dev);
+	rtnl_lock();
+	netif_set_real_num_tx_queues(net, nvdev->num_chn);
+	netif_set_real_num_rx_queues(net, nvdev->num_chn);
+	rtnl_unlock();
+	netdev_info(net, "real num tx,rx queues:%u, %u\n",
+		    net->real_num_tx_queues, net->real_num_rx_queues);
 
 	netif_carrier_on(net);
 
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 1084e5d..fd32df7 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -31,7 +31,7 @@
 #include "hyperv_net.h"
 
 
-#define RNDIS_EXT_LEN 100
+#define RNDIS_EXT_LEN PAGE_SIZE
 struct rndis_request {
 	struct list_head list_ent;
 	struct completion  wait_event;
@@ -490,6 +490,19 @@ static int rndis_filter_query_device(struct rndis_device *dev, u32 oid,
 	query->info_buflen = 0;
 	query->dev_vc_handle = 0;
 
+	if (oid == OID_GEN_RECEIVE_SCALE_CAPABILITIES) {
+		struct ndis_recv_scale_cap *cap;
+
+		request->request_msg.msg_len +=
+			sizeof(struct ndis_recv_scale_cap);
+		query->info_buflen = sizeof(struct ndis_recv_scale_cap);
+		cap = (struct ndis_recv_scale_cap *)((unsigned long)query +
+			query->info_buf_offset);
+		cap->hdr.type = NDIS_OBJECT_TYPE_RSS_CAPABILITIES;
+		cap->hdr.rev = NDIS_RECEIVE_SCALE_CAPABILITIES_REVISION_2;
+		cap->hdr.size = sizeof(struct ndis_recv_scale_cap);
+	}
+
 	ret = rndis_filter_send_request(dev, request);
 	if (ret != 0)
 		goto cleanup;
@@ -611,6 +624,88 @@ cleanup:
 }
 
 
+u8 hash_key[HASH_KEYLEN] = {
+	0x6d, 0x5a, 0x56, 0xda, 0x25, 0x5b, 0x0e, 0xc2,
+	0x41, 0x67, 0x25, 0x3d, 0x43, 0xa3, 0x8f, 0xb0,
+	0xd0, 0xca, 0x2b, 0xcb, 0xae, 0x7b, 0x30, 0xb4,
+	0x77, 0xcb, 0x2d, 0xa3, 0x80, 0x30, 0xf2, 0x0c,
+	0x6a, 0x42, 0xb7, 0x3b, 0xbe, 0xac, 0x01, 0xfa
+};
+
+int rndis_filter_set_rss_param(struct rndis_device *rdev, int num_queue)
+{
+	struct net_device *ndev = rdev->net_dev->ndev;
+	struct rndis_request *request;
+	struct rndis_set_request *set;
+	struct rndis_set_complete *set_complete;
+	u32 extlen = sizeof(struct ndis_recv_scale_param) + 4*ITAB_NUM
+		+ HASH_KEYLEN;
+	struct ndis_recv_scale_param *rssp;
+	u32 *itab;
+	u8 *keyp;
+	int i, t, ret;
+
+	request = get_rndis_request(rdev, RNDIS_MSG_SET,
+		RNDIS_MESSAGE_SIZE(struct rndis_set_request) + extlen);
+	if (!request)
+		return -ENOMEM;
+
+	set = &request->request_msg.msg.set_req;
+	set->oid = OID_GEN_RECEIVE_SCALE_PARAMETERS;
+	set->info_buflen = extlen;
+	set->info_buf_offset = sizeof(struct rndis_set_request);
+	set->dev_vc_handle = 0;
+
+	rssp = (struct ndis_recv_scale_param *)(set + 1);
+	rssp->hdr.type = NDIS_OBJECT_TYPE_RSS_PARAMETERS;
+	rssp->hdr.rev = NDIS_RECEIVE_SCALE_PARAMETERS_REVISION_2;
+	rssp->hdr.size = sizeof(struct ndis_recv_scale_param);
+	rssp->flag = 0;
+	rssp->hashinfo = NDIS_HASH_FUNC_TOEPLITZ | NDIS_HASH_IPV4 |
+				NDIS_HASH_TCP_IPV4;
+	rssp->indirect_tabsize = 4*ITAB_NUM;
+	rssp->indirect_taboffset = sizeof(struct ndis_recv_scale_param);
+	rssp->hashkey_size = HASH_KEYLEN;
+	rssp->kashkey_offset = rssp->indirect_taboffset
+		+ rssp->indirect_tabsize;
+
+	/* Set indirection table entries */
+	itab = (u32 *)(rssp + 1);
+	for (i = 0; i < ITAB_NUM; i++)
+		itab[i] = i % num_queue;
+
+	/* Set hask key values */
+	keyp = (u8 *)((unsigned long)rssp + rssp->kashkey_offset);
+	for (i = 0; i < HASH_KEYLEN; i++)
+		keyp[i] = hash_key[i];
+
+
+	ret = rndis_filter_send_request(rdev, request);
+	if (ret != 0)
+		goto cleanup;
+
+	t = wait_for_completion_timeout(&request->wait_event, 5*HZ);
+	if (t == 0) {
+		netdev_err(ndev, "timeout before we got a set response...\n");
+		/* can't put_rndis_request, since we may still receive a
+		 * send-completion.
+		 */
+		return -ETIMEDOUT;
+	} else {
+		set_complete = &request->response_msg.msg.set_complete;
+		if (set_complete->status != RNDIS_STATUS_SUCCESS) {
+			netdev_err(ndev, "Fail to set RSS parameters:0x%x\n",
+				   set_complete->status);
+			ret = -EINVAL;
+		}
+	}
+
+cleanup:
+	put_rndis_request(rdev, request);
+	return ret;
+}
+
+
 static int rndis_filter_query_device_link_status(struct rndis_device *dev)
 {
 	u32 size = sizeof(u32);
@@ -803,6 +898,23 @@ static int rndis_filter_close_device(struct rndis_device *dev)
 	return ret;
 }
 
+
+static void netvsc_sc_open(struct vmbus_channel *new_sc)
+{
+	struct netvsc_device *nvscdev;
+	u16 chn_index;
+	int ret;
+
+	ret = vmbus_open(new_sc, ring_size * PAGE_SIZE, ring_size * PAGE_SIZE,
+		NULL, 0, netvsc_channel_cb, new_sc);
+
+	if (ret == 0) {
+		nvscdev = hv_get_drvdata(new_sc->primary_channel->device_obj);
+		chn_index = new_sc->offermsg.offer.sub_channel_index;
+		nvscdev->chn_table[chn_index] = new_sc;
+	}
+}
+
 int rndis_filter_device_add(struct hv_device *dev,
 				  void *additional_info)
 {
@@ -810,6 +922,11 @@ int rndis_filter_device_add(struct hv_device *dev,
 	struct netvsc_device *net_device;
 	struct rndis_device *rndis_device;
 	struct netvsc_device_info *device_info = additional_info;
+	struct nvsp_message *init_packet;
+	int t;
+	struct ndis_recv_scale_cap rsscap;
+	u32 rsscap_size = sizeof(struct ndis_recv_scale_cap);
+
 
 	rndis_device = get_rndis_device();
 	if (!rndis_device)
@@ -829,6 +946,7 @@ int rndis_filter_device_add(struct hv_device *dev,
 
 	/* Initialize the rndis device */
 	net_device = hv_get_drvdata(dev);
+	net_device->num_chn = 1;
 
 	net_device->extension = rndis_device;
 	rndis_device->net_dev = net_device;
@@ -857,7 +975,56 @@ int rndis_filter_device_add(struct hv_device *dev,
 		 rndis_device->hw_mac_adr,
 		 device_info->link_state ? "down" : "up");
 
-	return ret;
+	if (net_device->nvsp_version <= NVSP_PROTOCOL_VERSION_4)
+		return 0;
+
+	/* vRSS setup */
+	memset(&rsscap, 0, rsscap_size);
+	ret = rndis_filter_query_device(rndis_device,
+		OID_GEN_RECEIVE_SCALE_CAPABILITIES, &rsscap, &rsscap_size);
+	if (ret || rsscap.num_recv_que < 2)
+		goto out;
+
+	net_device->num_chn = (num_online_cpus() < rsscap.num_recv_que) ?
+		num_online_cpus() : rsscap.num_recv_que;
+	if (net_device->num_chn == 1)
+		goto out;
+
+	vmbus_set_sc_create_callback(dev->channel, netvsc_sc_open);
+
+	init_packet = &net_device->channel_init_pkt;
+	memset(init_packet, 0, sizeof(struct nvsp_message));
+	init_packet->hdr.msg_type = NVSP_MSG5_TYPE_SUBCHANNEL;
+	init_packet->msg.v5_msg.subchn_req.op = NVSP_SUBCHANNEL_ALLOCATE;
+	init_packet->msg.v5_msg.subchn_req.num_subchannels =
+						net_device->num_chn - 1;
+	ret = vmbus_sendpacket(dev->channel, init_packet,
+			       sizeof(struct nvsp_message),
+			       (unsigned long)init_packet,
+			       VM_PKT_DATA_INBAND,
+			       VMBUS_DATA_PACKET_FLAG_COMPLETION_REQUESTED);
+	if (ret)
+		goto out;
+	t = wait_for_completion_timeout(&net_device->channel_init_wait, 5*HZ);
+	if (t == 0) {
+		ret = -ETIMEDOUT;
+		goto out;
+	}
+	if (init_packet->msg.v5_msg.subchn_comp.status !=
+		NVSP_STAT_SUCCESS) {
+		ret = -ENODEV;
+		goto out;
+	}
+	net_device->num_chn = 1 +
+		init_packet->msg.v5_msg.subchn_comp.num_subchannels;
+
+	vmbus_are_subchannels_present(dev->channel);
+
+	ret = rndis_filter_set_rss_param(rndis_device, net_device->num_chn);
+out:
+	if (ret)
+		net_device->num_chn = 1;
+	return 0; /* return 0 because primary channel can be used alone */
 }
 
 void rndis_filter_device_remove(struct hv_device *dev)
-- 
1.7.4.1
