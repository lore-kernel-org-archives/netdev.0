From: kys@exchange.microsoft.com
Subject: [PATCH RESEND net-next] netvsc: Use the new in-place consumption APIs
 in the rx path
Date: Tue,  5 Jul 2016 16:52:46 -0700
Message-ID: <1467762766-1442-1-git-send-email-kys@exchange.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com, leann.ogasawara@canonical.com
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

From: K. Y. Srinivasan <kys@microsoft.com>

Use the new APIs for eliminating a copy on the receive path. These new APIs also
help in minimizing the number of memory barriers we end up issuing (in the
ringbuffer code) since we can better control when we want to expose the ring
state to the host.

The patch is being resent to address earlier email issues.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/netvsc.c |   88 +++++++++++++++++++++++++++++--------------
 1 files changed, 59 insertions(+), 29 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 719cb35..8cd4c19 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -1141,6 +1141,39 @@ static inline void netvsc_receive_inband(struct hv_device *hdev,
 	}
 }
 
+static void netvsc_process_raw_pkt(struct hv_device *device,
+				   struct vmbus_channel *channel,
+				   struct netvsc_device *net_device,
+				   struct net_device *ndev,
+				   u64 request_id,
+				   struct vmpacket_descriptor *desc)
+{
+	struct nvsp_message *nvmsg;
+
+	nvmsg = (struct nvsp_message *)((unsigned long)
+		desc + (desc->offset8 << 3));
+
+	switch (desc->type) {
+	case VM_PKT_COMP:
+		netvsc_send_completion(net_device, channel, device, desc);
+		break;
+
+	case VM_PKT_DATA_USING_XFER_PAGES:
+		netvsc_receive(net_device, channel, device, desc);
+		break;
+
+	case VM_PKT_DATA_INBAND:
+		netvsc_receive_inband(device, net_device, nvmsg);
+		break;
+
+	default:
+		netdev_err(ndev, "unhandled packet type %d, tid %llx\n",
+			   desc->type, request_id);
+		break;
+	}
+}
+
+
 void netvsc_channel_cb(void *context)
 {
 	int ret;
@@ -1153,7 +1186,7 @@ void netvsc_channel_cb(void *context)
 	unsigned char *buffer;
 	int bufferlen = NETVSC_PACKET_SIZE;
 	struct net_device *ndev;
-	struct nvsp_message *nvmsg;
+	bool need_to_commit = false;
 
 	if (channel->primary_channel != NULL)
 		device = channel->primary_channel->device_obj;
@@ -1167,39 +1200,36 @@ void netvsc_channel_cb(void *context)
 	buffer = get_per_channel_state(channel);
 
 	do {
+		desc = get_next_pkt_raw(channel);
+		if (desc != NULL) {
+			netvsc_process_raw_pkt(device,
+					       channel,
+					       net_device,
+					       ndev,
+					       desc->trans_id,
+					       desc);
+
+			put_pkt_raw(channel, desc);
+			need_to_commit = true;
+			continue;
+		}
+		if (need_to_commit) {
+			need_to_commit = false;
+			commit_rd_index(channel);
+		}
+
 		ret = vmbus_recvpacket_raw(channel, buffer, bufferlen,
 					   &bytes_recvd, &request_id);
 		if (ret == 0) {
 			if (bytes_recvd > 0) {
 				desc = (struct vmpacket_descriptor *)buffer;
-				nvmsg = (struct nvsp_message *)((unsigned long)
-					 desc + (desc->offset8 << 3));
-				switch (desc->type) {
-				case VM_PKT_COMP:
-					netvsc_send_completion(net_device,
-								channel,
-								device, desc);
-					break;
-
-				case VM_PKT_DATA_USING_XFER_PAGES:
-					netvsc_receive(net_device, channel,
-						       device, desc);
-					break;
-
-				case VM_PKT_DATA_INBAND:
-					netvsc_receive_inband(device,
-							      net_device,
-							      nvmsg);
-					break;
-
-				default:
-					netdev_err(ndev,
-						   "unhandled packet type %d, "
-						   "tid %llx len %d\n",
-						   desc->type, request_id,
-						   bytes_recvd);
-					break;
-				}
+				netvsc_process_raw_pkt(device,
+						       channel,
+						       net_device,
+						       ndev,
+						       request_id,
+						       desc);
+
 
 			} else {
 				/*
-- 
1.7.4.1
