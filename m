From: Dexuan Cui <decui@microsoft.com>
Subject: [PATCH V5 3/9] Drivers: hv: vmbus: define a new VMBus message type
 for hvsock
Date: Thu, 24 Dec 2015 06:14:29 -0800
Message-ID: <1450966469-13142-1-git-send-email-decui@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pebolle@tiscali.nl, dan.carpenter@oracle.com, stefanha@redhat.com
To: gregkh@linuxfoundation.org, davem@davemloft.net,
 stephen@networkplumber.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, driverdev-devel@linuxdriverproject.org,
 olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com, kys@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
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
index 1161d68..eaaa066 100644
--- a/drivers/hv/channel.c
+++ b/drivers/hv/channel.c
@@ -219,6 +219,21 @@ error0:
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
index 1c1ad47..4611b50 100644
--- a/drivers/hv/channel_mgmt.c
+++ b/drivers/hv/channel_mgmt.c
@@ -825,6 +825,10 @@ struct vmbus_channel_message_table_entry
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
index c0eddd7..b835d80 100644
--- a/include/linux/hyperv.h
+++ b/include/linux/hyperv.h
@@ -392,6 +392,10 @@ enum vmbus_channel_message_type {
 	CHANNELMSG_VERSION_RESPONSE		= 15,
 	CHANNELMSG_UNLOAD			= 16,
 	CHANNELMSG_UNLOAD_RESPONSE		= 17,
+	CHANNELMSG_18				= 18,
+	CHANNELMSG_19				= 19,
+	CHANNELMSG_20				= 20,
+	CHANNELMSG_TL_CONNECT_REQUEST		= 21,
 	CHANNELMSG_COUNT
 };
 
@@ -562,6 +566,13 @@ struct vmbus_channel_initiate_contact {
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
@@ -1255,4 +1266,6 @@ void hv_process_channel_removal(struct vmbus_channel *channel, u32 relid);
 
 extern __u32 vmbus_proto_version;
 
+int vmbus_send_tl_connect_request(const uuid_le *shv_guest_servie_id,
+				  const uuid_le *shv_host_servie_id);
 #endif /* _HYPERV_H */
-- 
2.1.4
