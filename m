From: Dexuan Cui <decui@microsoft.com>
Subject: [PATCH 2/7] Drivers: hv: vmbus: define a new VMBus message type for hvsock
Date: Mon,  6 Jul 2015 07:45:31 -0700
Message-ID: <1436193931-26924-1-git-send-email-decui@microsoft.com>
To: gregkh@linuxfoundation.org, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org, olaf@aepfle.de,
	apw@canonical.com, jasowang@redhat.com, kys@microsoft.com,
	haiyangz@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A function to send the type of message is also added.

The coming net/hvsock driver will use this function to proactively request
the host to offer a VMBus channel for a new hvsock connection.

Signed-off-by: Dexuan Cui <decui@microsoft.com>
---
 drivers/hv/channel.c      | 15 +++++++++++++++
 drivers/hv/channel_mgmt.c |  4 ++++
 include/linux/hyperv.h    | 13 +++++++++++++
 3 files changed, 32 insertions(+)

diff --git a/drivers/hv/channel.c b/drivers/hv/channel.c
index 603ce97..b09d1b7 100644
--- a/drivers/hv/channel.c
+++ b/drivers/hv/channel.c
@@ -218,6 +218,21 @@ error0:
 }
 EXPORT_SYMBOL_GPL(vmbus_open);
 
+/* Used for Hyper-V Socket: a guest client's connect() to the host */
+int vmbus_send_tl_connect_request(const uuid_le *shv_guest_servie_id,
+				  const uuid_le *shv_host_servie_id)
+{
+	struct vmbus_channel_tl_connect_request conn_msg;
+
+	memset(&conn_msg, 0, sizeof(conn_msg));
+	conn_msg.header.msgtype = CHANNELMSG_TL_CONNECT_REQUEST;
+	conn_msg.guest_endpoint_id = *shv_guest_servie_id;
+	conn_msg.host_service_id = *shv_host_servie_id;
+
+	return vmbus_post_msg(&conn_msg, sizeof(conn_msg));
+}
+EXPORT_SYMBOL_GPL(vmbus_send_tl_connect_request);
+
 /*
  * create_gpadl_header - Creates a gpadl for the specified buffer
  */
diff --git a/drivers/hv/channel_mgmt.c b/drivers/hv/channel_mgmt.c
index 4506a66..7018c53 100644
--- a/drivers/hv/channel_mgmt.c
+++ b/drivers/hv/channel_mgmt.c
@@ -772,6 +772,10 @@ struct vmbus_channel_message_table_entry
 	{CHANNELMSG_VERSION_RESPONSE,		1, vmbus_onversion_response},
 	{CHANNELMSG_UNLOAD,			0, NULL},
 	{CHANNELMSG_UNLOAD_RESPONSE,		1, vmbus_unload_response},
+	{CHANNELMSG_18,				0, NULL},
+	{CHANNELMSG_19,				0, NULL},
+	{CHANNELMSG_20,				0, NULL},
+	{CHANNELMSG_TL_CONNECT_REQUEST,		0, NULL},
 };
 
 /*
diff --git a/include/linux/hyperv.h b/include/linux/hyperv.h
index aa21814..8799948 100644
--- a/include/linux/hyperv.h
+++ b/include/linux/hyperv.h
@@ -393,6 +393,10 @@ enum vmbus_channel_message_type {
 	CHANNELMSG_VERSION_RESPONSE		= 15,
 	CHANNELMSG_UNLOAD			= 16,
 	CHANNELMSG_UNLOAD_RESPONSE		= 17,
+	CHANNELMSG_18				= 18,
+	CHANNELMSG_19				= 19,
+	CHANNELMSG_20				= 20,
+	CHANNELMSG_TL_CONNECT_REQUEST		= 21,
 	CHANNELMSG_COUNT
 };
 
@@ -563,6 +567,13 @@ struct vmbus_channel_initiate_contact {
 	u64 monitor_page2;
 } __packed;
 
+/* Hyper-V socket: guest's connect()-ing to host */
+struct vmbus_channel_tl_connect_request {
+	struct vmbus_channel_message_header header;
+	uuid_le guest_endpoint_id;
+	uuid_le host_service_id;
+} __packed;
+
 struct vmbus_channel_version_response {
 	struct vmbus_channel_message_header header;
 	u8 version_supported;
@@ -1248,4 +1259,6 @@ extern struct resource hyperv_mmio;
 
 extern __u32 vmbus_proto_version;
 
+int vmbus_send_tl_connect_request(const uuid_le *shv_guest_servie_id,
+				const uuid_le *shv_host_servie_id);
 #endif /* _HYPERV_H */
-- 
2.1.0
