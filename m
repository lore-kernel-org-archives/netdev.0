From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH ney-next V3 12/17] hv_netvsc: Eliminate send_completion_tid
 from struct hv_netvsc_packet
Date: Tue,  1 Dec 2015 16:43:14 -0800
Message-ID: <1449016999-9796-12-git-send-email-kys@microsoft.com>
References: <1449016978-9755-1-git-send-email-kys@microsoft.com>
 <1449016999-9796-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1449016999-9796-1-git-send-email-kys@microsoft.com>
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

Eliminate send_completion_tid from struct hv_netvsc_packet.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h   |    8 ++------
 drivers/net/hyperv/netvsc.c       |   28 ++++++++++++++--------------
 drivers/net/hyperv/netvsc_drv.c   |   14 ++------------
 drivers/net/hyperv/rndis_filter.c |    2 +-
 4 files changed, 19 insertions(+), 33 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index b541455..baa40b1 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -145,10 +145,6 @@ struct hv_netvsc_packet {
 	u32 send_buf_index;
 
 	u32 total_data_buflen;
-	u32 pad1;
-
-
-	u64 send_completion_tid;
 };
 
 struct netvsc_device_info {
@@ -188,10 +184,10 @@ int netvsc_device_remove(struct hv_device *device);
 int netvsc_send(struct hv_device *device,
 		struct hv_netvsc_packet *packet,
 		struct rndis_message *rndis_msg,
-		struct hv_page_buffer **page_buffer);
+		struct hv_page_buffer **page_buffer,
+		struct sk_buff *skb);
 void netvsc_linkstatus_callback(struct hv_device *device_obj,
 				struct rndis_message *resp);
-void netvsc_xmit_completion(void *context);
 int netvsc_recv_callback(struct hv_device *device_obj,
 			struct hv_netvsc_packet *packet,
 			void **data,
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 18058a59..d18e10c 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -614,6 +614,7 @@ static void netvsc_send_completion(struct netvsc_device *net_device,
 	struct hv_netvsc_packet *nvsc_packet;
 	struct net_device *ndev;
 	u32 send_index;
+	struct sk_buff *skb;
 
 	ndev = net_device->ndev;
 
@@ -639,17 +640,17 @@ static void netvsc_send_completion(struct netvsc_device *net_device,
 		int queue_sends;
 
 		/* Get the send context */
-		nvsc_packet = (struct hv_netvsc_packet *)(unsigned long)
-			packet->trans_id;
+		skb = (struct sk_buff *)(unsigned long)packet->trans_id;
 
 		/* Notify the layer above us */
-		if (nvsc_packet) {
+		if (skb) {
+			nvsc_packet = (struct hv_netvsc_packet *) skb->cb;
 			send_index = nvsc_packet->send_buf_index;
 			if (send_index != NETVSC_INVALID_INDEX)
 				netvsc_free_send_slot(net_device, send_index);
 			q_idx = nvsc_packet->q_idx;
 			channel = incoming_channel;
-			netvsc_xmit_completion(nvsc_packet);
+			dev_kfree_skb_any(skb);
 		}
 
 		num_outstanding_sends =
@@ -744,7 +745,8 @@ static u32 netvsc_copy_to_send_buf(struct netvsc_device *net_device,
 static inline int netvsc_send_pkt(
 	struct hv_netvsc_packet *packet,
 	struct netvsc_device *net_device,
-	struct hv_page_buffer **pb)
+	struct hv_page_buffer **pb,
+	struct sk_buff *skb)
 {
 	struct nvsp_message nvmsg;
 	u16 q_idx = packet->q_idx;
@@ -772,10 +774,7 @@ static inline int netvsc_send_pkt(
 		nvmsg.msg.v1_msg.send_rndis_pkt.send_buf_section_size =
 			packet->total_data_buflen;
 
-	if (packet->completion_func)
-		req_id = (ulong)packet;
-	else
-		req_id = 0;
+	req_id = (ulong)skb;
 
 	if (out_channel->rescind)
 		return -ENODEV;
@@ -841,7 +840,8 @@ static inline int netvsc_send_pkt(
 int netvsc_send(struct hv_device *device,
 		struct hv_netvsc_packet *packet,
 		struct rndis_message *rndis_msg,
-		struct hv_page_buffer **pb)
+		struct hv_page_buffer **pb,
+		struct sk_buff *skb)
 {
 	struct netvsc_device *net_device;
 	int ret = 0, m_ret = 0;
@@ -907,7 +907,7 @@ int netvsc_send(struct hv_device *device,
 		}
 
 		if (msdp->pkt)
-			netvsc_xmit_completion(msdp->pkt);
+			dev_kfree_skb_any(skb);
 
 		if (packet->xmit_more && !packet->cp_partial) {
 			msdp->pkt = packet;
@@ -925,17 +925,17 @@ int netvsc_send(struct hv_device *device,
 	}
 
 	if (msd_send) {
-		m_ret = netvsc_send_pkt(msd_send, net_device, pb);
+		m_ret = netvsc_send_pkt(msd_send, net_device, pb, skb);
 
 		if (m_ret != 0) {
 			netvsc_free_send_slot(net_device,
 					      msd_send->send_buf_index);
-			netvsc_xmit_completion(msd_send);
+			dev_kfree_skb_any(skb);
 		}
 	}
 
 	if (cur_send)
-		ret = netvsc_send_pkt(cur_send, net_device, pb);
+		ret = netvsc_send_pkt(cur_send, net_device, pb, skb);
 
 	if (ret != 0 && section_index != NETVSC_INVALID_INDEX)
 		netvsc_free_send_slot(net_device, section_index);
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 1906f2f..1532ae4 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -278,16 +278,6 @@ static u16 netvsc_select_queue(struct net_device *ndev, struct sk_buff *skb,
 	return q_idx;
 }
 
-void netvsc_xmit_completion(void *context)
-{
-	struct hv_netvsc_packet *packet = (struct hv_netvsc_packet *)context;
-	struct sk_buff *skb = (struct sk_buff *)
-		(unsigned long)packet->send_completion_tid;
-
-	if (skb)
-		dev_kfree_skb_any(skb);
-}
-
 static u32 fill_pg_buf(struct page *page, u32 offset, u32 len,
 			struct hv_page_buffer *pb)
 {
@@ -496,7 +486,6 @@ check_size:
 
 	/* Set the completion routine */
 	packet->completion_func = 1;
-	packet->send_completion_tid = (unsigned long)skb;
 
 	isvlan = packet->vlan_tci & VLAN_TAG_PRESENT;
 
@@ -624,7 +613,8 @@ do_send:
 	packet->page_buf_cnt = init_page_array(rndis_msg, rndis_msg_size,
 					       skb, packet, &pb);
 
-	ret = netvsc_send(net_device_ctx->device_ctx, packet, rndis_msg, &pb);
+	ret = netvsc_send(net_device_ctx->device_ctx, packet,
+			  rndis_msg, &pb, skb);
 
 drop:
 	if (ret == 0) {
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 6ff2253..53139f7 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -240,7 +240,7 @@ static int rndis_filter_send_request(struct rndis_device *dev,
 	packet->completion_func = 0;
 	packet->xmit_more = false;
 
-	ret = netvsc_send(dev->net_dev->dev, packet, NULL, &pb);
+	ret = netvsc_send(dev->net_dev->dev, packet, NULL, &pb, NULL);
 	return ret;
 }
 
-- 
1.7.4.1
