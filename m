From: Tony Zelenoff <antonz@parallels.com>
Subject: [PATCH 8/9] atl1: do not process interrupts in cycle in handler
Date: Fri, 13 Apr 2012 20:09:53 +0400
Message-ID: <1334333394-38404-9-git-send-email-antonz@parallels.com>
References: <1334333394-38404-1-git-send-email-antonz@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <antonz@parallels.com>, <netdev@vger.kernel.org>,
	<jcliburn@gmail.com>, <csnook@redhat.com>, <khorenko@parallels.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:54722 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754758Ab2DMQJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 12:09:59 -0400
In-Reply-To: <1334333394-38404-1-git-send-email-antonz@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As the rx/tx handled inside napi handler, the cycle is
not needed now, because only the rx/tx need such kind of
processing.

Signed-off-by: Tony Zelenoff <antonz@parallels.com>
---
 drivers/net/ethernet/atheros/atlx/atl1.c |  101 ++++++++++++++----------------
 1 files changed, 46 insertions(+), 55 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 5781597..3c57a30 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -2499,77 +2499,68 @@ static irqreturn_t atl1_intr(int irq, void *data)
 {
 	struct atl1_adapter *adapter = netdev_priv(data);
 	u32 status;
-	int max_ints = 10;
 
 	status = adapter->cmb.cmb->int_stats;
 	if (!status)
 		return IRQ_NONE;
 
-	do {
-		/* clear CMB interrupt status at once */
-		adapter->cmb.cmb->int_stats = 0;
-
-		if (status & ISR_GPHY)	/* clear phy status */
-			atlx_clear_phy_int(adapter);
+	/* clear CMB interrupt status at once */
+	adapter->cmb.cmb->int_stats = 0;
 
-		/* clear ISR status, and Enable CMB DMA/Disable Interrupt */
-		iowrite32(status | ISR_DIS_INT, adapter->hw.hw_addr + REG_ISR);
+	if (status & ISR_GPHY)	/* clear phy status */
+		atlx_clear_phy_int(adapter);
 
-		/* check if SMB intr */
-		if (status & ISR_SMB)
-			atl1_inc_smb(adapter);
+	/* clear ISR status, and Enable CMB DMA/Disable Interrupt */
+	iowrite32(status | ISR_DIS_INT, adapter->hw.hw_addr + REG_ISR);
 
-		/* check if PCIE PHY Link down */
-		if (status & ISR_PHY_LINKDOWN) {
-			if (netif_msg_intr(adapter))
-				dev_printk(KERN_DEBUG, &adapter->pdev->dev,
-					"pcie phy link down %x\n", status);
-			if (netif_running(adapter->netdev)) {	/* reset MAC */
-				atlx_irq_disable(adapter);
-				schedule_work(&adapter->reset_dev_task);
-				return IRQ_HANDLED;
-			}
-		}
+	/* check if SMB intr */
+	if (status & ISR_SMB)
+		atl1_inc_smb(adapter);
 
-		/* check if DMA read/write error ? */
-		if (status & (ISR_DMAR_TO_RST | ISR_DMAW_TO_RST)) {
-			if (netif_msg_intr(adapter))
-				dev_printk(KERN_DEBUG, &adapter->pdev->dev,
-					"pcie DMA r/w error (status = 0x%x)\n",
-					status);
+	/* check if PCIE PHY Link down */
+	if (status & ISR_PHY_LINKDOWN) {
+		if (netif_msg_intr(adapter))
+			dev_printk(KERN_DEBUG, &adapter->pdev->dev,
+				"pcie phy link down %x\n", status);
+		if (netif_running(adapter->netdev)) {	/* reset MAC */
 			atlx_irq_disable(adapter);
 			schedule_work(&adapter->reset_dev_task);
 			return IRQ_HANDLED;
 		}
+	}
 
-		/* link event */
-		if (status & ISR_GPHY) {
-			adapter->soft_stats.tx_carrier_errors++;
-			atl1_check_for_link(adapter);
-		}
-
-		/* transmit or receive event */
-		if (status & (ISR_CMB_TX | ISR_CMB_RX) &&
-		    atl1_sched_rings_clean(adapter))
-			break;
-
-		/* rx exception */
-		if (unlikely(status & (ISR_RXF_OV | ISR_RFD_UNRUN |
-			ISR_RRD_OV | ISR_HOST_RFD_UNRUN |
-			ISR_HOST_RRD_OV))) {
-			if (netif_msg_intr(adapter))
-				dev_printk(KERN_DEBUG,
-					&adapter->pdev->dev,
-					"rx exception, ISR = 0x%x\n",
-					status);
-			if (atl1_sched_rings_clean(adapter))
-				break;
-		}
-
-		if (--max_ints < 0)
-			break;
-
-	} while ((status = adapter->cmb.cmb->int_stats));
+	/* check if DMA read/write error ? */
+	if (status & (ISR_DMAR_TO_RST | ISR_DMAW_TO_RST)) {
+		if (netif_msg_intr(adapter))
+			dev_printk(KERN_DEBUG, &adapter->pdev->dev,
+				"pcie DMA r/w error (status = 0x%x)\n",
+				status);
+		atlx_irq_disable(adapter);
+		schedule_work(&adapter->reset_dev_task);
+		return IRQ_HANDLED;
+	}
+
+	/* link event */
+	if (status & ISR_GPHY) {
+		adapter->soft_stats.tx_carrier_errors++;
+		atl1_check_for_link(adapter);
+	}
+
+	/* transmit or receive event */
+	if (status & (ISR_CMB_TX | ISR_CMB_RX))
+	    atl1_sched_rings_clean(adapter);
+
+	/* rx exception */
+	if (unlikely(status & (ISR_RXF_OV | ISR_RFD_UNRUN |
+		ISR_RRD_OV | ISR_HOST_RFD_UNRUN |
+		ISR_HOST_RRD_OV))) {
+		if (netif_msg_intr(adapter))
+			dev_printk(KERN_DEBUG,
+				&adapter->pdev->dev,
+				"rx exception, ISR = 0x%x\n",
+				status);
+		atl1_sched_rings_clean(adapter);
+	}
 
 	/* re-enable Interrupt */
 	iowrite32(ISR_DIS_SMB | ISR_DIS_DMA, adapter->hw.hw_addr + REG_ISR);
-- 
1.7.1
