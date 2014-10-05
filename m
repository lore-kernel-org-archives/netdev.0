From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH net 1/1] hyperv: Fix a bug in netvsc_send()
Date: Sun,  5 Oct 2014 10:42:51 -0700
Message-ID: <1412530971-29897-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com
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

After the packet is successfully sent, we should not touch the packet 
as it may have been freed. This patch is based on the work done by
Long Li <longli@microsoft.com>.

David, please queue this up for stable.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
Reported-by: Sitsofe Wheeler <sitsofe@yahoo.com>
---
 drivers/net/hyperv/netvsc.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 977984b..7d76c95 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -717,6 +717,7 @@ int netvsc_send(struct hv_device *device,
 	unsigned int section_index = NETVSC_INVALID_INDEX;
 	u32 msg_size = 0;
 	struct sk_buff *skb;
+	u16 q_idx = packet->q_idx;
 
 
 	net_device = get_outbound_net_device(device);
@@ -781,24 +782,24 @@ int netvsc_send(struct hv_device *device,
 
 	if (ret == 0) {
 		atomic_inc(&net_device->num_outstanding_sends);
-		atomic_inc(&net_device->queue_sends[packet->q_idx]);
+		atomic_inc(&net_device->queue_sends[q_idx]);
 
 		if (hv_ringbuf_avail_percent(&out_channel->outbound) <
 			RING_AVAIL_PERCENT_LOWATER) {
 			netif_tx_stop_queue(netdev_get_tx_queue(
-					    ndev, packet->q_idx));
+					    ndev, q_idx));
 
 			if (atomic_read(&net_device->
-				queue_sends[packet->q_idx]) < 1)
+				queue_sends[q_idx]) < 1)
 				netif_tx_wake_queue(netdev_get_tx_queue(
-						    ndev, packet->q_idx));
+						    ndev, q_idx));
 		}
 	} else if (ret == -EAGAIN) {
 		netif_tx_stop_queue(netdev_get_tx_queue(
-				    ndev, packet->q_idx));
-		if (atomic_read(&net_device->queue_sends[packet->q_idx]) < 1) {
+				    ndev, q_idx));
+		if (atomic_read(&net_device->queue_sends[q_idx]) < 1) {
 			netif_tx_wake_queue(netdev_get_tx_queue(
-					    ndev, packet->q_idx));
+					    ndev, q_idx));
 			ret = -ENOSPC;
 		}
 	} else {
-- 
1.7.4.1
