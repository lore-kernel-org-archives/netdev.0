From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next] hv_netvsc: Add structs and handlers for VF messages
Date: Fri, 24 Jul 2015 10:08:40 -0700
Message-ID: <1437757720-16105-1-git-send-email-haiyangz@microsoft.com>
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds data structures and handlers for messages related
to SRIOV Virtual Function.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h |   29 ++++++++++++++++++++++++++
 drivers/net/hyperv/netvsc.c     |   43 +++++++++++++++++++++++++++++---------
 2 files changed, 62 insertions(+), 10 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 26cd14c..f225d1f 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -541,6 +541,29 @@ union nvsp_2_message_uber {
 	struct nvsp_2_free_rxbuf free_rxbuf;
 } __packed;
 
+struct nvsp_4_send_vf_association {
+	/* 1: allocated, serial number is valid. 0: not allocated */
+	u32 allocated;
+
+	/* Serial number of the VF to team with */
+	u32 serial;
+} __packed;
+
+enum nvsp_vm_datapath {
+	NVSP_DATAPATH_SYNTHETIC = 0,
+	NVSP_DATAPATH_VF,
+	NVSP_DATAPATH_MAX
+};
+
+struct nvsp_4_sw_datapath {
+	u32 active_datapath; /* active data path in VM */
+} __packed;
+
+union nvsp_4_message_uber {
+	struct nvsp_4_send_vf_association vf_assoc;
+	struct nvsp_4_sw_datapath active_dp;
+} __packed;
+
 enum nvsp_subchannel_operation {
 	NVSP_SUBCHANNEL_NONE = 0,
 	NVSP_SUBCHANNEL_ALLOCATE,
@@ -578,6 +601,7 @@ union nvsp_all_messages {
 	union nvsp_message_init_uber init_msg;
 	union nvsp_1_message_uber v1_msg;
 	union nvsp_2_message_uber v2_msg;
+	union nvsp_4_message_uber v4_msg;
 	union nvsp_5_message_uber v5_msg;
 } __packed;
 
@@ -689,6 +713,11 @@ struct netvsc_device {
 
 	/* The net device context */
 	struct net_device_context *nd_ctx;
+
+	/* 1: allocated, serial number is valid. 0: not allocated */
+	u32 vf_alloc;
+	/* Serial number of the VF to team with */
+	u32 vf_serial;
 };
 
 /* NdisInitialize message */
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 23126a7..51e4c0f 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -453,13 +453,16 @@ static int negotiate_nvsp_ver(struct hv_device *device,
 	if (nvsp_ver == NVSP_PROTOCOL_VERSION_1)
 		return 0;
 
-	/* NVSPv2 only: Send NDIS config */
+	/* NVSPv2 or later: Send NDIS config */
 	memset(init_packet, 0, sizeof(struct nvsp_message));
 	init_packet->hdr.msg_type = NVSP_MSG2_TYPE_SEND_NDIS_CONFIG;
 	init_packet->msg.v2_msg.send_ndis_config.mtu = net_device->ndev->mtu +
 						       ETH_HLEN;
 	init_packet->msg.v2_msg.send_ndis_config.capability.ieee8021q = 1;
 
+	if (nvsp_ver >= NVSP_PROTOCOL_VERSION_5)
+		init_packet->msg.v2_msg.send_ndis_config.capability.sriov = 1;
+
 	ret = vmbus_sendpacket(device->channel, init_packet,
 				sizeof(struct nvsp_message),
 				(unsigned long)init_packet,
@@ -1064,11 +1067,10 @@ static void netvsc_receive(struct netvsc_device *net_device,
 
 
 static void netvsc_send_table(struct hv_device *hdev,
-			      struct vmpacket_descriptor *vmpkt)
+			      struct nvsp_message *nvmsg)
 {
 	struct netvsc_device *nvscdev;
 	struct net_device *ndev;
-	struct nvsp_message *nvmsg;
 	int i;
 	u32 count, *tab;
 
@@ -1077,12 +1079,6 @@ static void netvsc_send_table(struct hv_device *hdev,
 		return;
 	ndev = nvscdev->ndev;
 
-	nvmsg = (struct nvsp_message *)((unsigned long)vmpkt +
-					(vmpkt->offset8 << 3));
-
-	if (nvmsg->hdr.msg_type != NVSP_MSG5_TYPE_SEND_INDIRECTION_TABLE)
-		return;
-
 	count = nvmsg->msg.v5_msg.send_table.count;
 	if (count != VRSS_SEND_TAB_SIZE) {
 		netdev_err(ndev, "Received wrong send-table size:%u\n", count);
@@ -1096,6 +1092,28 @@ static void netvsc_send_table(struct hv_device *hdev,
 		nvscdev->send_table[i] = tab[i];
 }
 
+static void netvsc_send_vf(struct netvsc_device *nvdev,
+			   struct nvsp_message *nvmsg)
+{
+	nvdev->vf_alloc = nvmsg->msg.v4_msg.vf_assoc.allocated;
+	nvdev->vf_serial = nvmsg->msg.v4_msg.vf_assoc.serial;
+}
+
+static inline void netvsc_receive_inband(struct hv_device *hdev,
+					 struct netvsc_device *nvdev,
+					 struct nvsp_message *nvmsg)
+{
+	switch (nvmsg->hdr.msg_type) {
+	case NVSP_MSG5_TYPE_SEND_INDIRECTION_TABLE:
+		netvsc_send_table(hdev, nvmsg);
+		break;
+
+	case NVSP_MSG4_TYPE_SEND_VF_ASSOCIATION:
+		netvsc_send_vf(nvdev, nvmsg);
+		break;
+	}
+}
+
 void netvsc_channel_cb(void *context)
 {
 	int ret;
@@ -1108,6 +1126,7 @@ void netvsc_channel_cb(void *context)
 	unsigned char *buffer;
 	int bufferlen = NETVSC_PACKET_SIZE;
 	struct net_device *ndev;
+	struct nvsp_message *nvmsg;
 
 	if (channel->primary_channel != NULL)
 		device = channel->primary_channel->device_obj;
@@ -1126,6 +1145,8 @@ void netvsc_channel_cb(void *context)
 		if (ret == 0) {
 			if (bytes_recvd > 0) {
 				desc = (struct vmpacket_descriptor *)buffer;
+				nvmsg = (struct nvsp_message *)((unsigned long)
+					 desc + (desc->offset8 << 3));
 				switch (desc->type) {
 				case VM_PKT_COMP:
 					netvsc_send_completion(net_device,
@@ -1138,7 +1159,9 @@ void netvsc_channel_cb(void *context)
 					break;
 
 				case VM_PKT_DATA_INBAND:
-					netvsc_send_table(device, desc);
+					netvsc_receive_inband(device,
+							      net_device,
+							      nvmsg);
 					break;
 
 				default:
-- 
1.7.4.1
