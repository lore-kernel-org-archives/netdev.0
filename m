From: Joe Perches <joe@perches.com>
Subject: [PATCH V2] hyperv: netvsc: Neaten netvsc_send_pkt by using a temporary
Date: Mon, 31 Jul 2017 10:30:54 -0700
Message-ID: <280adfa19cb240fd843102215d423f9a2e724ff2.1501522035.git.joe@perches.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "K. Y. Srinivasan" <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>,
        Stephen Hemminger <sthemmin@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Repeated dereference of nvmsg.msg.v1_msg.send_rndis_pkt can be
shortened by using a temporary.  Do so.

No change in object code.

Miscellanea:

o Use * const for rpkt and nvchan

Signed-off-by: Joe Perches <joe@perches.com>
---

v2: Use * const for rpkt and nvchan
      This is a fairly unusual style, but is technically correct
      requested by: Stephen Hemminger <stephen@networkplumber.org>
    Removed style change that doesn't apply any longer

 drivers/net/hyperv/netvsc.c | 25 +++++++++++--------------
 1 file changed, 11 insertions(+), 14 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index c64934c64dca..9598220b3bcc 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -747,8 +747,10 @@ static inline int netvsc_send_pkt(
 	struct sk_buff *skb)
 {
 	struct nvsp_message nvmsg;
-	struct netvsc_channel *nvchan
-		= &net_device->chan_table[packet->q_idx];
+	struct nvsp_1_message_send_rndis_packet * const rpkt =
+		&nvmsg.msg.v1_msg.send_rndis_pkt;
+	struct netvsc_channel * const nvchan =
+		&net_device->chan_table[packet->q_idx];
 	struct vmbus_channel *out_channel = nvchan->channel;
 	struct net_device *ndev = hv_get_drvdata(device);
 	struct netdev_queue *txq = netdev_get_tx_queue(ndev, packet->q_idx);
@@ -757,21 +759,16 @@ static inline int netvsc_send_pkt(
 	u32 ring_avail = hv_ringbuf_avail_percent(&out_channel->outbound);
 
 	nvmsg.hdr.msg_type = NVSP_MSG1_TYPE_SEND_RNDIS_PKT;
-	if (skb != NULL) {
-		/* 0 is RMC_DATA; */
-		nvmsg.msg.v1_msg.send_rndis_pkt.channel_type = 0;
-	} else {
-		/* 1 is RMC_CONTROL; */
-		nvmsg.msg.v1_msg.send_rndis_pkt.channel_type = 1;
-	}
+	if (skb)
+		rpkt->channel_type = 0;		/* 0 is RMC_DATA */
+	else
+		rpkt->channel_type = 1;		/* 1 is RMC_CONTROL */
 
-	nvmsg.msg.v1_msg.send_rndis_pkt.send_buf_section_index =
-		packet->send_buf_index;
+	rpkt->send_buf_section_index = packet->send_buf_index;
 	if (packet->send_buf_index == NETVSC_INVALID_INDEX)
-		nvmsg.msg.v1_msg.send_rndis_pkt.send_buf_section_size = 0;
+		rpkt->send_buf_section_size = 0;
 	else
-		nvmsg.msg.v1_msg.send_rndis_pkt.send_buf_section_size =
-			packet->total_data_buflen;
+		rpkt->send_buf_section_size = packet->total_data_buflen;
 
 	req_id = (ulong)skb;
 
-- 
2.10.0.rc2.1.g053435c
