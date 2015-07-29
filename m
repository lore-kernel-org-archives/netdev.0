From: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
Subject: [PATCH net 09/11] net: thunderx: Fix crash when changing rss with
 mutliple traffic flows
Date: Wed, 29 Jul 2015 16:49:44 +0300
Message-ID: <1438177787-20940-10-git-send-email-aleksey.makarov@caviumnetworks.com>
References: <1438177787-20940-1-git-send-email-aleksey.makarov@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Robert Richter <rric@kernel.org>, David Daney <david.daney@cavium.com>,
 Sunil Goutham <Sunil.Goutham@caviumnetworks.com>,
 Aleksey Makarov <aleksey.makarov@caviumnetworks.com>,
 linux-kernel@vger.kernel.org,
 Robert Richter <robert.richter@caviumnetworks.com>,
 Sunil Goutham <sgoutham@cavium.com>, linux-arm-kernel@lists.infradead.org
To: <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1438177787-20940-1-git-send-email-aleksey.makarov@caviumnetworks.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

This fixes a crash when changing rss with multiple traffic flows.

While interface teardown, disable tx queues after all NAPI threads
are done. If done otherwise tx queues might be woken up inside NAPI
if any CQE_TX are processed.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
Signed-off-by: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_main.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index abee2d7..c7a29a3 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -234,7 +234,7 @@ static void  nicvf_handle_mbx_intr(struct nicvf *nic)
 				    nic->duplex == DUPLEX_FULL ?
 				"Full duplex" : "Half duplex");
 			netif_carrier_on(nic->netdev);
-			netif_tx_wake_all_queues(nic->netdev);
+			netif_tx_start_all_queues(nic->netdev);
 		} else {
 			netdev_info(nic->netdev, "%s: Link is Down\n",
 				    nic->netdev->name);
@@ -551,7 +551,7 @@ done:
 	if (tx_done) {
 		txq = netdev_get_tx_queue(netdev, cq_idx);
 		if (netif_tx_queue_stopped(txq)) {
-			netif_tx_wake_queue(txq);
+			netif_tx_start_queue(txq);
 			nic->drv_stats.txq_wake++;
 			if (netif_msg_tx_err(nic))
 				netdev_warn(netdev,
@@ -845,7 +845,7 @@ static netdev_tx_t nicvf_xmit(struct sk_buff *skb, struct net_device *netdev)
 		return NETDEV_TX_OK;
 	}
 
-	if (!nicvf_sq_append_skb(nic, skb) && !netif_tx_queue_stopped(txq)) {
+	if (!netif_tx_queue_stopped(txq) && !nicvf_sq_append_skb(nic, skb)) {
 		netif_tx_stop_queue(txq);
 		nic->drv_stats.txq_stop++;
 		if (netif_msg_tx_err(nic))
@@ -871,7 +871,6 @@ int nicvf_stop(struct net_device *netdev)
 	nicvf_send_msg_to_pf(nic, &mbx);
 
 	netif_carrier_off(netdev);
-	netif_tx_disable(netdev);
 
 	/* Disable RBDR & QS error interrupts */
 	for (qidx = 0; qidx < qs->rbdr_cnt; qidx++) {
@@ -906,6 +905,8 @@ int nicvf_stop(struct net_device *netdev)
 		kfree(cq_poll);
 	}
 
+	netif_tx_disable(netdev);
+
 	/* Free resources */
 	nicvf_config_data_transfer(nic, false);
 
-- 
2.4.6
