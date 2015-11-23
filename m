From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH net-next 04/10] hv_netvsc: Eliminate rndis_msg pointer from
 hv_netvsc_packet structure
Date: Mon, 23 Nov 2015 15:29:00 -0800
Message-ID: <1448321346-21357-4-git-send-email-kys@microsoft.com>
References: <1448321324-21318-1-git-send-email-kys@microsoft.com>
 <1448321346-21357-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1448321346-21357-1-git-send-email-kys@microsoft.com>
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

Eliminate rndis_msg pointer from hv_netvsc_packet structure.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h   |    8 +++-----
 drivers/net/hyperv/netvsc.c       |   10 ++++++----
 drivers/net/hyperv/netvsc_drv.c   |    7 +++----
 drivers/net/hyperv/rndis_filter.c |    2 +-
 4 files changed, 13 insertions(+), 14 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index ac24091..7fa4f43 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -149,10 +149,6 @@ struct hv_netvsc_packet {
 	void *send_completion_ctx;
 	void (*send_completion)(void *context);
 
-
-	/* This points to the memory after page_buf */
-	struct rndis_message *rndis_msg;
-
 	/* Points to the send/receive buffer where the ethernet frame is */
 	void *data;
 	struct hv_page_buffer *page_buf;
@@ -189,10 +185,12 @@ struct rndis_device {
 
 
 /* Interface */
+struct rndis_message;
 int netvsc_device_add(struct hv_device *device, void *additional_info);
 int netvsc_device_remove(struct hv_device *device);
 int netvsc_send(struct hv_device *device,
-		struct hv_netvsc_packet *packet);
+		struct hv_netvsc_packet *packet,
+		struct rndis_message *rndis_msg);
 void netvsc_linkstatus_callback(struct hv_device *device_obj,
 				struct rndis_message *resp);
 void netvsc_xmit_completion(void *context);
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 52533ed..2de9e7f 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -706,7 +706,8 @@ static u32 netvsc_get_next_send_section(struct netvsc_device *net_device)
 static u32 netvsc_copy_to_send_buf(struct netvsc_device *net_device,
 				   unsigned int section_index,
 				   u32 pend_size,
-				   struct hv_netvsc_packet *packet)
+				   struct hv_netvsc_packet *packet,
+				   struct rndis_message *rndis_msg)
 {
 	char *start = net_device->send_buf;
 	char *dest = start + (section_index * net_device->send_section_size)
@@ -722,7 +723,7 @@ static u32 netvsc_copy_to_send_buf(struct netvsc_device *net_device,
 	if (packet->is_data_pkt && packet->xmit_more && remain &&
 	    !packet->cp_partial) {
 		padding = net_device->pkt_align - remain;
-		packet->rndis_msg->msg_len += padding;
+		rndis_msg->msg_len += padding;
 		packet->total_data_buflen += padding;
 	}
 
@@ -841,7 +842,8 @@ static inline int netvsc_send_pkt(
 }
 
 int netvsc_send(struct hv_device *device,
-		struct hv_netvsc_packet *packet)
+		struct hv_netvsc_packet *packet,
+		struct rndis_message *rndis_msg)
 {
 	struct netvsc_device *net_device;
 	int ret = 0, m_ret = 0;
@@ -897,7 +899,7 @@ int netvsc_send(struct hv_device *device,
 	if (section_index != NETVSC_INVALID_INDEX) {
 		netvsc_copy_to_send_buf(net_device,
 					section_index, msd_len,
-					packet);
+					packet, rndis_msg);
 
 		packet->send_buf_index = section_index;
 
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index e5f4eec..77c0849 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -482,10 +482,10 @@ check_size:
 	packet->is_data_pkt = true;
 	packet->total_data_buflen = skb->len;
 
-	packet->rndis_msg = (struct rndis_message *)((unsigned long)packet +
+	rndis_msg = (struct rndis_message *)((unsigned long)packet +
 				sizeof(struct hv_netvsc_packet));
 
-	memset(packet->rndis_msg, 0, RNDIS_AND_PPI_SIZE);
+	memset(rndis_msg, 0, RNDIS_AND_PPI_SIZE);
 
 	/* Set the completion routine */
 	packet->send_completion = netvsc_xmit_completion;
@@ -495,7 +495,6 @@ check_size:
 	isvlan = packet->vlan_tci & VLAN_TAG_PRESENT;
 
 	/* Add the rndis header */
-	rndis_msg = packet->rndis_msg;
 	rndis_msg->ndis_msg_type = RNDIS_MSG_PACKET;
 	rndis_msg->msg_len = packet->total_data_buflen;
 	rndis_pkt = &rndis_msg->msg.pkt;
@@ -619,7 +618,7 @@ do_send:
 	packet->page_buf_cnt = init_page_array(rndis_msg, rndis_msg_size,
 					       skb, packet);
 
-	ret = netvsc_send(net_device_ctx->device_ctx, packet);
+	ret = netvsc_send(net_device_ctx->device_ctx, packet, rndis_msg);
 
 drop:
 	if (ret == 0) {
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 1b04d78..63584e7 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -240,7 +240,7 @@ static int rndis_filter_send_request(struct rndis_device *dev,
 	packet->send_completion = NULL;
 	packet->xmit_more = false;
 
-	ret = netvsc_send(dev->net_dev->dev, packet);
+	ret = netvsc_send(dev->net_dev->dev, packet, NULL);
 	return ret;
 }
 
-- 
1.7.4.1
