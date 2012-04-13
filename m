From: Tony Zelenoff <antonz@parallels.com>
Subject: [PATCH 3/9] atl1: add napi process of tx interrupts
Date: Fri, 13 Apr 2012 20:09:48 +0400
Message-ID: <1334333394-38404-4-git-send-email-antonz@parallels.com>
References: <1334333394-38404-1-git-send-email-antonz@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <antonz@parallels.com>, <netdev@vger.kernel.org>,
	<jcliburn@gmail.com>, <csnook@redhat.com>, <khorenko@parallels.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:54709 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754176Ab2DMQJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 12:09:59 -0400
In-Reply-To: <1334333394-38404-1-git-send-email-antonz@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the tx ints processing same as rx ones via napi.
The idea got from e1000. The interrupt disabling is
still not fine grained.

Signed-off-by: Tony Zelenoff <antonz@parallels.com>
---
 drivers/net/ethernet/atheros/atlx/atl1.c |   27 ++++++++++++++++-----------
 1 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index d39c1b9..a8935df 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -2069,12 +2069,13 @@ rrd_ok:
 	return count;
 }
 
-static void atl1_intr_tx(struct atl1_adapter *adapter)
+static int atl1_intr_tx(struct atl1_adapter *adapter)
 {
 	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
 	struct atl1_buffer *buffer_info;
 	u16 sw_tpd_next_to_clean;
 	u16 cmb_tpd_next_to_clean;
+	int count = 0;
 
 	sw_tpd_next_to_clean = atomic_read(&tpd_ring->next_to_clean);
 	cmb_tpd_next_to_clean = le16_to_cpu(adapter->cmb.cmb->tpd_cons_idx);
@@ -2094,12 +2095,16 @@ static void atl1_intr_tx(struct atl1_adapter *adapter)
 
 		if (++sw_tpd_next_to_clean == tpd_ring->count)
 			sw_tpd_next_to_clean = 0;
+
+		count++;
 	}
 	atomic_set(&tpd_ring->next_to_clean, sw_tpd_next_to_clean);
 
 	if (netif_queue_stopped(adapter->netdev) &&
 	    netif_carrier_ok(adapter->netdev))
 		netif_wake_queue(adapter->netdev);
+
+	return count;
 }
 
 static u16 atl1_tpd_avail(struct atl1_tpd_ring *tpd_ring)
@@ -2441,11 +2446,14 @@ static netdev_tx_t atl1_xmit_frame(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 }
 
-static int atl1_rx_clean(struct napi_struct *napi, int budget)
+static int atl1_rings_clean(struct napi_struct *napi, int budget)
 {
 	struct atl1_adapter *adapter = container_of(napi, struct atl1_adapter, napi);
 	int work_done = atl1_intr_rx(adapter, budget);
 
+	if (atl1_intr_tx(adapter))
+		work_done = budget;
+
 	/* Let's come again to process some more packets */
 	if (work_done >= budget)
 		return work_done;
@@ -2456,7 +2464,7 @@ static int atl1_rx_clean(struct napi_struct *napi, int budget)
 	return work_done;
 }
 
-static inline int atl1_sched_rx(struct atl1_adapter* adapter)
+static inline int atl1_sched_rings_clean(struct atl1_adapter* adapter)
 {
 	if (likely(napi_schedule_prep(&adapter->napi))) {
 		__napi_schedule(&adapter->napi);
@@ -2527,12 +2535,9 @@ static irqreturn_t atl1_intr(int irq, void *data)
 			atl1_check_for_link(adapter);
 		}
 
-		/* transmit event */
-		if (status & ISR_CMB_TX)
-			atl1_intr_tx(adapter);
-
-		/* rx event */
-		if (status & ISR_CMB_RX && atl1_sched_rx(adapter))
+		/* transmit or receive event */
+		if (status & (ISR_CMB_TX | ISR_CMB_RX) &&
+		    atl1_sched_rings_clean(adapter))
 			/* Go away with INTs disabled */
 			return IRQ_HANDLED;
 
@@ -2545,7 +2550,7 @@ static irqreturn_t atl1_intr(int irq, void *data)
 					&adapter->pdev->dev,
 					"rx exception, ISR = 0x%x\n",
 					status);
-			if (atl1_sched_rx(adapter))
+			if (atl1_sched_rings_clean(adapter))
 				return IRQ_HANDLED;
 		}
 
@@ -3005,7 +3010,7 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 
 	netdev->netdev_ops = &atl1_netdev_ops;
 	netdev->watchdog_timeo = 5 * HZ;
-	netif_napi_add(netdev, &adapter->napi, atl1_rx_clean, 64);
+	netif_napi_add(netdev, &adapter->napi, atl1_rings_clean, 64);
 
 	netdev->ethtool_ops = &atl1_ethtool_ops;
 	adapter->bd_number = cards_found;
-- 
1.7.1
