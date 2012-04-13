From: Tony Zelenoff <antonz@parallels.com>
Subject: [PATCH 2/9] atl1: make driver napi compatible
Date: Fri, 13 Apr 2012 20:09:47 +0400
Message-ID: <1334333394-38404-3-git-send-email-antonz@parallels.com>
References: <1334333394-38404-1-git-send-email-antonz@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <antonz@parallels.com>, <netdev@vger.kernel.org>,
	<jcliburn@gmail.com>, <csnook@redhat.com>, <khorenko@parallels.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:54695 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753671Ab2DMQJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 12:09:59 -0400
In-Reply-To: <1334333394-38404-1-git-send-email-antonz@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is first step, here there is no fine interrupt
disabling which cause TX/ERR interrupts stalling when
RX scheduled ints processed.

Signed-off-by: Tony Zelenoff <antonz@parallels.com>
---
 drivers/net/ethernet/atheros/atlx/atl1.c |   46 ++++++++++++++++++++++++++----
 drivers/net/ethernet/atheros/atlx/atl1.h |    1 +
 2 files changed, 41 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 6438239..d39c1b9 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -1917,7 +1917,7 @@ next:
 	return num_alloc;
 }
 
-static void atl1_intr_rx(struct atl1_adapter *adapter)
+static int atl1_intr_rx(struct atl1_adapter *adapter, int budget)
 {
 	int i, count;
 	u16 length;
@@ -1933,7 +1933,7 @@ static void atl1_intr_rx(struct atl1_adapter *adapter)
 
 	rrd_next_to_clean = atomic_read(&rrd_ring->next_to_clean);
 
-	while (1) {
+	while (count <= budget) {
 		rrd = ATL1_RRD_DESC(rrd_ring, rrd_next_to_clean);
 		i = 1;
 		if (likely(rrd->xsz.valid)) {	/* packet valid */
@@ -2032,7 +2032,7 @@ rrd_ok:
 
 			__vlan_hwaccel_put_tag(skb, vlan_tag);
 		}
-		netif_rx(skb);
+		netif_receive_skb(skb);
 
 		/* let protocol layer free skb */
 		buffer_info->skb = NULL;
@@ -2065,6 +2065,8 @@ rrd_ok:
 		iowrite32(value, adapter->hw.hw_addr + REG_MAILBOX);
 		spin_unlock(&adapter->mb_lock);
 	}
+
+	return count;
 }
 
 static void atl1_intr_tx(struct atl1_adapter *adapter)
@@ -2439,6 +2441,33 @@ static netdev_tx_t atl1_xmit_frame(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 }
 
+static int atl1_rx_clean(struct napi_struct *napi, int budget)
+{
+	struct atl1_adapter *adapter = container_of(napi, struct atl1_adapter, napi);
+	int work_done = atl1_intr_rx(adapter, budget);
+
+	/* Let's come again to process some more packets */
+	if (work_done >= budget)
+		return work_done;
+
+	napi_complete(napi);
+	/* re-enable Interrupt */
+	iowrite32(ISR_DIS_SMB | ISR_DIS_DMA, adapter->hw.hw_addr + REG_ISR);
+	return work_done;
+}
+
+static inline int atl1_sched_rx(struct atl1_adapter* adapter)
+{
+	if (likely(napi_schedule_prep(&adapter->napi))) {
+		__napi_schedule(&adapter->napi);
+		return 1;
+	}
+
+	dev_printk(KERN_ERR, &adapter->pdev->dev,
+		   "rx: INTs must be disabled!");
+	return 0;
+}
+
 /*
  * atl1_intr - Interrupt Handler
  * @irq: interrupt number
@@ -2503,8 +2532,9 @@ static irqreturn_t atl1_intr(int irq, void *data)
 			atl1_intr_tx(adapter);
 
 		/* rx event */
-		if (status & ISR_CMB_RX)
-			alt1_intr_rx(adapter);
+		if (status & ISR_CMB_RX && atl1_sched_rx(adapter))
+			/* Go away with INTs disabled */
+			return IRQ_HANDLED;
 
 		/* rx exception */
 		if (unlikely(status & (ISR_RXF_OV | ISR_RFD_UNRUN |
@@ -2515,7 +2545,8 @@ static irqreturn_t atl1_intr(int irq, void *data)
 					&adapter->pdev->dev,
 					"rx exception, ISR = 0x%x\n",
 					status);
-			atl1_intr_rx(adapter);
+			if (atl1_sched_rx(adapter))
+				return IRQ_HANDLED;
 		}
 
 		if (--max_ints < 0)
@@ -2600,6 +2631,7 @@ static s32 atl1_up(struct atl1_adapter *adapter)
 	if (unlikely(err))
 		goto err_up;
 
+	napi_enable(&adapter->napi);
 	atlx_irq_enable(adapter);
 	atl1_check_link(adapter);
 	netif_start_queue(netdev);
@@ -2616,6 +2648,7 @@ static void atl1_down(struct atl1_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 
+	napi_disable(&adapter->napi);
 	netif_stop_queue(netdev);
 	del_timer_sync(&adapter->phy_config_timer);
 	adapter->phy_timer_pending = false;
@@ -2972,6 +3005,7 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 
 	netdev->netdev_ops = &atl1_netdev_ops;
 	netdev->watchdog_timeo = 5 * HZ;
+	netif_napi_add(netdev, &adapter->napi, atl1_rx_clean, 64);
 
 	netdev->ethtool_ops = &atl1_ethtool_ops;
 	adapter->bd_number = cards_found;
diff --git a/drivers/net/ethernet/atheros/atlx/atl1.h b/drivers/net/ethernet/atheros/atlx/atl1.h
index e04bf4d..b55084c 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.h
+++ b/drivers/net/ethernet/atheros/atlx/atl1.h
@@ -758,6 +758,7 @@ struct atl1_adapter {
 	u16 link_speed;
 	u16 link_duplex;
 	spinlock_t lock;
+	struct napi_struct napi;
 	struct work_struct reset_dev_task;
 	struct work_struct link_chg_task;
 
-- 
1.7.1
