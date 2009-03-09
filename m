From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 04/12] qlge: Add support for GRO.
Date: Mon,  9 Mar 2009 13:59:20 -0700
Message-ID: <1236632368-22079-5-git-send-email-ron.mercer@qlogic.com>
References: <1236632368-22079-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:18643 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753500AbZCIVDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 17:03:08 -0400
In-Reply-To: <1236632368-22079-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   30 ++++++++++++++++++++----------
 1 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 498d4bf..339e1da 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1507,6 +1507,8 @@ static void ql_process_mac_rx_intr(struct ql_adapter *qdev,
 {
 	struct net_device *ndev = qdev->ndev;
 	struct sk_buff *skb = NULL;
+	u16 vlan_id = (le16_to_cpu(ib_mac_rsp->vlan_id) &
+			IB_MAC_IOCB_RSP_VLAN_MASK)
 
 	QL_DUMP_IB_MAC_RSP(ib_mac_rsp);
 
@@ -1562,16 +1564,23 @@ static void ql_process_mac_rx_intr(struct ql_adapter *qdev,
 
 	qdev->stats.rx_packets++;
 	qdev->stats.rx_bytes += skb->len;
-	skb_record_rx_queue(skb, rx_ring - &qdev->rx_ring[0]);
-	if (qdev->vlgrp && (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_V)) {
-		QPRINTK(qdev, RX_STATUS, DEBUG,
-			"Passing a VLAN packet upstream.\n");
-		vlan_hwaccel_receive_skb(skb, qdev->vlgrp,
-				le16_to_cpu(ib_mac_rsp->vlan_id));
+	skb_record_rx_queue(skb,
+		rx_ring->cq_id - qdev->rss_ring_first_cq_id);
+	if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
+		if (qdev->vlgrp &&
+			(ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_V) &&
+			(vlan_id != 0))
+			vlan_gro_receive(&rx_ring->napi, qdev->vlgrp,
+				vlan_id, skb);
+		else
+			napi_gro_receive(&rx_ring->napi, skb);
 	} else {
-		QPRINTK(qdev, RX_STATUS, DEBUG,
-			"Passing a normal packet upstream.\n");
-		netif_receive_skb(skb);
+		if (qdev->vlgrp &&
+			(ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_V) &&
+			(vlan_id != 0))
+			vlan_hwaccel_receive_skb(skb, qdev->vlgrp, vlan_id);
+		else
+			netif_receive_skb(skb);
 	}
 }
 
@@ -1774,7 +1783,7 @@ static int ql_napi_poll_msix(struct napi_struct *napi, int budget)
 		rx_ring->cq_id);
 
 	if (work_done < budget) {
-		__napi_complete(napi);
+		napi_complete(napi);
 		ql_enable_completion_interrupt(qdev, rx_ring->irq);
 	}
 	return work_done;
@@ -3840,6 +3849,7 @@ static int __devinit qlge_probe(struct pci_dev *pdev,
 			  | NETIF_F_TSO_ECN
 			  | NETIF_F_HW_VLAN_TX
 			  | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER);
+	ndev->features |= NETIF_F_GRO;
 
 	if (test_bit(QL_DMA64, &qdev->flags))
 		ndev->features |= NETIF_F_HIGHDMA;
-- 
1.6.0.2

