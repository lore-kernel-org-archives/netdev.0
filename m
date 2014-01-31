From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH 2/2] Drivers: net: hyperv: Cleanup the receive path
Date: Fri, 31 Jan 2014 08:25:17 -0800
Message-ID: <1391185517-5698-2-git-send-email-kys@microsoft.com>
References: <1391185478-5655-1-git-send-email-kys@microsoft.com>
 <1391185517-5698-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1391185517-5698-1-git-send-email-kys@microsoft.com>
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

Make the receive path a little more efficient by parameterizing the
required state rather than re-establishing that state.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/netvsc.c |   29 +++++++++++++----------------
 1 files changed, 13 insertions(+), 16 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 03a2c6e..7fa2bba 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -432,17 +432,14 @@ static inline u32 hv_ringbuf_avail_percent(
 	return avail_write * 100 / ring_info->ring_datasize;
 }
 
-static void netvsc_send_completion(struct hv_device *device,
+static void netvsc_send_completion(struct netvsc_device *net_device,
+				   struct hv_device *device,
 				   struct vmpacket_descriptor *packet)
 {
-	struct netvsc_device *net_device;
 	struct nvsp_message *nvsp_packet;
 	struct hv_netvsc_packet *nvsc_packet;
 	struct net_device *ndev;
 
-	net_device = get_inbound_net_device(device);
-	if (!net_device)
-		return;
 	ndev = net_device->ndev;
 
 	nvsp_packet = (struct nvsp_message *)((unsigned long)packet +
@@ -561,13 +558,13 @@ int netvsc_send(struct hv_device *device,
 }
 
 static void netvsc_send_recv_completion(struct hv_device *device,
+					struct netvsc_device *net_device,
 					u64 transaction_id, u32 status)
 {
 	struct nvsp_message recvcompMessage;
 	int retries = 0;
 	int ret;
 	struct net_device *ndev;
-	struct netvsc_device *net_device = hv_get_drvdata(device);
 
 	ndev = net_device->ndev;
 
@@ -653,14 +650,15 @@ static void netvsc_receive_completion(void *context)
 
 	/* Send a receive completion for the xfer page packet */
 	if (fsend_receive_comp)
-		netvsc_send_recv_completion(device, transaction_id, status);
+		netvsc_send_recv_completion(device, net_device, transaction_id,
+					status);
 
 }
 
-static void netvsc_receive(struct hv_device *device,
-			    struct vmpacket_descriptor *packet)
+static void netvsc_receive(struct netvsc_device *net_device,
+			struct hv_device *device,
+			struct vmpacket_descriptor *packet)
 {
-	struct netvsc_device *net_device;
 	struct vmtransfer_page_packet_header *vmxferpage_packet;
 	struct nvsp_message *nvsp_packet;
 	struct hv_netvsc_packet *netvsc_packet = NULL;
@@ -673,9 +671,6 @@ static void netvsc_receive(struct hv_device *device,
 
 	LIST_HEAD(listHead);
 
-	net_device = get_inbound_net_device(device);
-	if (!net_device)
-		return;
 	ndev = net_device->ndev;
 
 	/*
@@ -741,7 +736,7 @@ static void netvsc_receive(struct hv_device *device,
 		spin_unlock_irqrestore(&net_device->recv_pkt_list_lock,
 				       flags);
 
-		netvsc_send_recv_completion(device,
+		netvsc_send_recv_completion(device, net_device,
 					    vmxferpage_packet->d.trans_id,
 					    NVSP_STAT_FAIL);
 
@@ -825,11 +820,13 @@ static void netvsc_channel_cb(void *context)
 				desc = (struct vmpacket_descriptor *)buffer;
 				switch (desc->type) {
 				case VM_PKT_COMP:
-					netvsc_send_completion(device, desc);
+					netvsc_send_completion(net_device,
+								device, desc);
 					break;
 
 				case VM_PKT_DATA_USING_XFER_PAGES:
-					netvsc_receive(device, desc);
+					netvsc_receive(net_device,
+							device, desc);
 					break;
 
 				default:
-- 
1.7.4.1
