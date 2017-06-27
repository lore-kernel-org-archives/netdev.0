From: Joe Perches <joe@perches.com>
Subject: [PATCH] cavium: thunder: Remove duplicate "netdev->name" logging output
Date: Tue, 27 Jun 2017 03:56:54 -0700
Message-ID: <0ac1a144114eecd8c469027d6c91f453d61e1ade.1498560984.git.joe@perches.com>
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Sunil Goutham <sgoutham@cavium.com>,
        Robert Richter <rric@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0038.hostedemail.com ([216.40.44.38]:33150 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752112AbdF0K46 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 06:56:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using netdev_<level>(netdev, "%s: ...", netdev->name) duplicates the
name in the output.  Remove those uses.

Miscellanea:

o Use the netif_<level> convenience macros at the same time

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   | 33 ++++++++--------------
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c |  8 ++----
 2 files changed, 15 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index 573755b0a51b..49b80da51ba7 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -227,15 +227,14 @@ static void  nicvf_handle_mbx_intr(struct nicvf *nic)
 		nic->speed = mbx.link_status.speed;
 		nic->mac_type = mbx.link_status.mac_type;
 		if (nic->link_up) {
-			netdev_info(nic->netdev, "%s: Link is Up %d Mbps %s\n",
-				    nic->netdev->name, nic->speed,
+			netdev_info(nic->netdev, "Link is Up %d Mbps %s duplex\n",
+				    nic->speed,
 				    nic->duplex == DUPLEX_FULL ?
-				"Full duplex" : "Half duplex");
+				    "Full" : "Half");
 			netif_carrier_on(nic->netdev);
 			netif_tx_start_all_queues(nic->netdev);
 		} else {
-			netdev_info(nic->netdev, "%s: Link is Down\n",
-				    nic->netdev->name);
+			netdev_info(nic->netdev, "Link is Down\n");
 			netif_carrier_off(nic->netdev);
 			netif_tx_stop_all_queues(nic->netdev);
 		}
@@ -721,8 +720,7 @@ static void nicvf_rcv_pkt_handler(struct net_device *netdev,
 		return;
 
 	if (netif_msg_pktdata(nic)) {
-		netdev_info(nic->netdev, "%s: skb 0x%p, len=%d\n", netdev->name,
-			    skb, skb->len);
+		netdev_info(nic->netdev, "skb 0x%p, len=%d\n", skb, skb->len);
 		print_hex_dump(KERN_INFO, "", DUMP_PREFIX_OFFSET, 16, 1,
 			       skb->data, skb->len, true);
 	}
@@ -854,10 +852,8 @@ static int nicvf_cq_intr_handler(struct net_device *netdev, u8 cq_idx,
 			netif_tx_wake_queue(txq);
 			nic = nic->pnicvf;
 			this_cpu_inc(nic->drv_stats->txq_wake);
-			if (netif_msg_tx_err(nic))
-				netdev_warn(netdev,
-					    "%s: Transmit queue wakeup SQ%d\n",
-					    netdev->name, txq_idx);
+			netif_warn(nic, tx_err, netdev,
+				   "Transmit queue wakeup SQ%d\n", txq_idx);
 		}
 	}
 
@@ -928,9 +924,8 @@ static void nicvf_handle_qs_err(unsigned long data)
 
 static void nicvf_dump_intr_status(struct nicvf *nic)
 {
-	if (netif_msg_intr(nic))
-		netdev_info(nic->netdev, "%s: interrupt status 0x%llx\n",
-			    nic->netdev->name, nicvf_reg_read(nic, NIC_VF_INT));
+	netif_info(nic, intr, nic->netdev, "interrupt status 0x%llx\n",
+		   nicvf_reg_read(nic, NIC_VF_INT));
 }
 
 static irqreturn_t nicvf_misc_intr_handler(int irq, void *nicvf_irq)
@@ -1212,10 +1207,8 @@ static netdev_tx_t nicvf_xmit(struct sk_buff *skb, struct net_device *netdev)
 			netif_tx_wake_queue(txq);
 		} else {
 			this_cpu_inc(nic->drv_stats->txq_stop);
-			if (netif_msg_tx_err(nic))
-				netdev_warn(netdev,
-					    "%s: Transmit ring full, stopping SQ%d\n",
-					    netdev->name, qid);
+			netif_warn(nic, tx_err, netdev,
+				   "Transmit ring full, stopping SQ%d\n", qid);
 		}
 		return NETDEV_TX_BUSY;
 	}
@@ -1600,9 +1593,7 @@ static void nicvf_tx_timeout(struct net_device *dev)
 {
 	struct nicvf *nic = netdev_priv(dev);
 
-	if (netif_msg_tx_err(nic))
-		netdev_warn(dev, "%s: Transmit timed out, resetting\n",
-			    dev->name);
+	netif_warn(nic, tx_err, dev, "Transmit timed out, resetting\n");
 
 	this_cpu_inc(nic->drv_stats->tx_timeout);
 	schedule_work(&nic->reset_task);
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index 2b181762ad49..d4496e9afcdf 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -1811,11 +1811,9 @@ void nicvf_update_sq_stats(struct nicvf *nic, int sq_idx)
 /* Check for errors in the receive cmp.queue entry */
 int nicvf_check_cqe_rx_errs(struct nicvf *nic, struct cqe_rx_t *cqe_rx)
 {
-	if (netif_msg_rx_err(nic))
-		netdev_err(nic->netdev,
-			   "%s: RX error CQE err_level 0x%x err_opcode 0x%x\n",
-			   nic->netdev->name,
-			   cqe_rx->err_level, cqe_rx->err_opcode);
+	netif_err(nic, rx_err, nic->netdev,
+		  "RX error CQE err_level 0x%x err_opcode 0x%x\n",
+		  cqe_rx->err_level, cqe_rx->err_opcode);
 
 	switch (cqe_rx->err_opcode) {
 	case CQ_RX_ERROP_RE_PARTIAL:
-- 
2.10.0.rc2.1.g053435c
