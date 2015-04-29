From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH net-next 1/1] hv_netvsc: Use the xmit_more skb flag to optimize signaling the host
Date: Wed, 29 Apr 2015 15:33:42 -0700
Message-ID: <1430346822-13103-1-git-send-email-kys@microsoft.com>
Cc: "K. Y. Srinivasan" <kys@microsoft.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Based on the information given to this driver (via the xmit_more skb flag),
we can defer signaling the host if more packets are on the way. This will help
make the host more efficient since it can potentially process a larger batch of
packets. Implement this optimization.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/netvsc.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 2e8ad06..9ca416f 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -743,6 +743,7 @@ static inline int netvsc_send_pkt(
 	u64 req_id;
 	int ret;
 	struct hv_page_buffer *pgbuf;
+	u32 vmbus_flags = VMBUS_DATA_PACKET_FLAG_COMPLETION_REQUESTED;
 
 	nvmsg.hdr.msg_type = NVSP_MSG1_TYPE_SEND_RNDIS_PKT;
 	if (packet->is_data_pkt) {
@@ -772,19 +773,21 @@ static inline int netvsc_send_pkt(
 	if (packet->page_buf_cnt) {
 		pgbuf = packet->cp_partial ? packet->page_buf +
 			packet->rmsg_pgcnt : packet->page_buf;
-		ret = vmbus_sendpacket_pagebuffer(out_channel,
+		ret = vmbus_sendpacket_pagebuffer_ctl(out_channel,
 						  pgbuf,
 						  packet->page_buf_cnt,
 						  &nvmsg,
 						  sizeof(struct nvsp_message),
-						  req_id);
+						  req_id,
+						  vmbus_flags,
+						  !packet->xmit_more);
 	} else {
-		ret = vmbus_sendpacket(
+		ret = vmbus_sendpacket_ctl(
 				out_channel, &nvmsg,
 				sizeof(struct nvsp_message),
 				req_id,
 				VM_PKT_DATA_INBAND,
-				VMBUS_DATA_PACKET_FLAG_COMPLETION_REQUESTED);
+				vmbus_flags, !packet->xmit_more);
 	}
 
 	if (ret == 0) {
-- 
1.7.4.1
