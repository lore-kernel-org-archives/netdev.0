From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH net-next V2 13/17] hv_netvsc: Eliminate is_data_pkt from
 struct hv_netvsc_packet
Date: Sat, 28 Nov 2015 12:20:41 -0800
Message-ID: <1448742045-22732-13-git-send-email-kys@microsoft.com>
References: <1448742017-22693-1-git-send-email-kys@microsoft.com>
 <1448742045-22732-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1448742045-22732-1-git-send-email-kys@microsoft.com>
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

Eliminate is_data_pkt from struct hv_netvsc_packet.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h   |    1 -
 drivers/net/hyperv/netvsc.c       |   14 ++++++++------
 drivers/net/hyperv/netvsc_drv.c   |    1 -
 drivers/net/hyperv/rndis_filter.c |    1 -
 4 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index baa40b1..65e340e 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -131,7 +131,6 @@ struct ndis_tcp_ip_checksum_info;
 struct hv_netvsc_packet {
 	/* Bookkeeping stuff */
 	u8 status;
-	u8 is_data_pkt;
 	u8 xmit_more; /* from skb */
 	u8 cp_partial; /* partial copy into send buffer */
 
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index d18e10c..11b009e 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -704,12 +704,14 @@ static u32 netvsc_copy_to_send_buf(struct netvsc_device *net_device,
 				   u32 pend_size,
 				   struct hv_netvsc_packet *packet,
 				   struct rndis_message *rndis_msg,
-				   struct hv_page_buffer **pb)
+				   struct hv_page_buffer **pb,
+				   struct sk_buff *skb)
 {
 	char *start = net_device->send_buf;
 	char *dest = start + (section_index * net_device->send_section_size)
 		     + pend_size;
 	int i;
+	bool is_data_pkt = (skb != NULL) ? true : false;
 	u32 msg_size = 0;
 	u32 padding = 0;
 	u32 remain = packet->total_data_buflen % net_device->pkt_align;
@@ -717,7 +719,7 @@ static u32 netvsc_copy_to_send_buf(struct netvsc_device *net_device,
 		packet->page_buf_cnt;
 
 	/* Add padding */
-	if (packet->is_data_pkt && packet->xmit_more && remain &&
+	if (is_data_pkt && packet->xmit_more && remain &&
 	    !packet->cp_partial) {
 		padding = net_device->pkt_align - remain;
 		rndis_msg->msg_len += padding;
@@ -758,7 +760,7 @@ static inline int netvsc_send_pkt(
 	u32 ring_avail = hv_ringbuf_avail_percent(&out_channel->outbound);
 
 	nvmsg.hdr.msg_type = NVSP_MSG1_TYPE_SEND_RNDIS_PKT;
-	if (packet->is_data_pkt) {
+	if (skb != NULL) {
 		/* 0 is RMC_DATA; */
 		nvmsg.msg.v1_msg.send_rndis_pkt.channel_type = 0;
 	} else {
@@ -868,7 +870,7 @@ int netvsc_send(struct hv_device *device,
 	if (msdp->pkt)
 		msd_len = msdp->pkt->total_data_buflen;
 
-	try_batch = packet->is_data_pkt && msd_len > 0 && msdp->count <
+	try_batch = (skb != NULL) && msd_len > 0 && msdp->count <
 		    net_device->max_pkt;
 
 	if (try_batch && msd_len + pktlen + net_device->pkt_align <
@@ -880,7 +882,7 @@ int netvsc_send(struct hv_device *device,
 		section_index = msdp->pkt->send_buf_index;
 		packet->cp_partial = true;
 
-	} else if (packet->is_data_pkt && pktlen + net_device->pkt_align <
+	} else if ((skb != NULL) && pktlen + net_device->pkt_align <
 		   net_device->send_section_size) {
 		section_index = netvsc_get_next_send_section(net_device);
 		if (section_index != NETVSC_INVALID_INDEX) {
@@ -894,7 +896,7 @@ int netvsc_send(struct hv_device *device,
 	if (section_index != NETVSC_INVALID_INDEX) {
 		netvsc_copy_to_send_buf(net_device,
 					section_index, msd_len,
-					packet, rndis_msg, pb);
+					packet, rndis_msg, pb, skb);
 
 		packet->send_buf_index = section_index;
 
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 1532ae4..eb0c6fa 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -477,7 +477,6 @@ check_size:
 
 	packet->q_idx = skb_get_queue_mapping(skb);
 
-	packet->is_data_pkt = true;
 	packet->total_data_buflen = skb->len;
 
 	rndis_msg = (struct rndis_message *)skb->head;
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 53139f7..0b98674 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -215,7 +215,6 @@ static int rndis_filter_send_request(struct rndis_device *dev,
 	/* Setup the packet to send it */
 	packet = &req->pkt;
 
-	packet->is_data_pkt = false;
 	packet->total_data_buflen = req->request_msg.msg_len;
 	packet->page_buf_cnt = 1;
 
-- 
1.7.4.1
