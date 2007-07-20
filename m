From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Subject: [PATCH 9/10] ps3: fix rare issue that reenabling rx DMA fails
Date: Fri, 20 Jul 2007 17:35:54 +0900
Message-ID: <20070720173431.67A1.MOKUNO@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MGW2.Sony.CO.JP ([137.153.0.14]:37548 "EHLO mgw2.sony.co.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765358AbXGTIf5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jul 2007 04:35:57 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed rare issue that 'lv1_net_start_rx_dma failed, status=-9" was shown
in dmesg.  This meant restarting rx DMA had been rejected by the hypervisor.
This issue would caused if the guest os requested starting DMA when 
the hypervisor thought the DMA was in progress.
The state machine for DMA status of the hypervisor would be updated
by processing interrupt in the hypervisor.
Thus we should wait for the interrupt delivery before restarting
DMA.

Signed-off-by: Masakazu Mokuno <mokuno@sm.sony.co.jp>
---
 drivers/net/ps3_gelic_net.c |    9 +++++++--
 drivers/net/ps3_gelic_net.h |    1 +
 2 files changed, 8 insertions(+), 2 deletions(-)

--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -943,8 +943,8 @@ refill:
 	descr->prev->next_descr_addr = descr->bus_addr;
 
 	if (dmac_chain_ended) {
-		gelic_net_enable_rxdmac(card);
-		dev_dbg(ctodev(card), "reenable rx dma\n");
+		card->rx_dma_restart_required = 1;
+		dev_dbg(ctodev(card), "reenable rx dma scheduled\n");
 	}
 
 	return 1;
@@ -1020,6 +1020,11 @@ static irqreturn_t gelic_net_interrupt(i
 	if (!status)
 		return IRQ_NONE;
 
+	if (card->rx_dma_restart_required) {
+		card->rx_dma_restart_required = 0;
+		gelic_net_enable_rxdmac(card);
+	}
+
 	if (status & GELIC_NET_RXINT) {
 		gelic_net_rx_irq_off(card);
 		netif_rx_schedule(netdev);
--- a/drivers/net/ps3_gelic_net.h
+++ b/drivers/net/ps3_gelic_net.h
@@ -207,6 +207,7 @@ struct gelic_net_card {
 
 	struct gelic_net_descr_chain tx_chain;
 	struct gelic_net_descr_chain rx_chain;
+	int rx_dma_restart_required;
 	/* gurad dmac descriptor chain*/
 	spinlock_t chain_lock;
 

--
Masakazu MOKUNO

