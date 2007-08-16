From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [PATCH 2.6.24 4/5]S2io: Check for CARD_DOWN before handling traffic
Date: 15 Aug 2007 17:12:29 -0700
Message-ID: <1187223149.23940.337.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, support@neterion.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:49014 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761144AbXHOWUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 18:20:55 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Added check to return from the traffic handling function, if the card status 
  is DOWN.

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Signed-off-by: Santosh Rastapur <santosh.rastapur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp patch3/drivers/net/s2io.c patch4/drivers/net/s2io.c
--- patch3/drivers/net/s2io.c	2007-08-15 08:57:32.000000000 -0700
+++ patch4/drivers/net/s2io.c	2007-08-15 08:42:14.000000000 -0700
@@ -2927,6 +2927,11 @@ static int s2io_poll(struct net_device *
 	int i;
 
 	atomic_inc(&nic->isr_cnt);
+	if (unlikely(atomic_read(&nic->card_state) == CARD_DOWN)) {
+		atomic_dec(&nic->isr_cnt);
+		return IRQ_NONE;
+	}
+
 	mac_control = &nic->mac_control;
 	config = &nic->config;
 
@@ -3062,12 +3067,6 @@ static void rx_intr_handler(struct ring_
 	struct RxD3* rxdp3;
 
 	spin_lock(&nic->rx_lock);
-	if (atomic_read(&nic->card_state) == CARD_DOWN) {
-		DBG_PRINT(INTR_DBG, "%s: %s going down for reset\n",
-			  __FUNCTION__, dev->name);
-		spin_unlock(&nic->rx_lock);
-		return;
-	}
 
 	get_info = ring_data->rx_curr_get_info;
 	get_block = get_info.block_index;
@@ -4404,6 +4403,10 @@ static irqreturn_t s2io_msix_ring_handle
 	struct s2io_nic *sp = ring->nic;
 
 	atomic_inc(&sp->isr_cnt);
+	if (unlikely(atomic_read(&sp->card_state) == CARD_DOWN)){
+		atomic_dec(&sp->isr_cnt);
+		return IRQ_HANDLED;
+	}
 
 	rx_intr_handler(ring);
 	s2io_chk_rx_buffers(sp, ring->ring_no);
@@ -4418,6 +4421,10 @@ static irqreturn_t s2io_msix_fifo_handle
 	struct s2io_nic *sp = fifo->nic;
 
 	atomic_inc(&sp->isr_cnt);
+	if (unlikely(atomic_read(&sp->card_state) == CARD_DOWN)){
+		atomic_dec(&sp->isr_cnt);
+		return IRQ_HANDLED;
+	}
 	tx_intr_handler(fifo);
 	atomic_dec(&sp->isr_cnt);
 	return IRQ_HANDLED;
@@ -4896,6 +4903,11 @@ static irqreturn_t s2io_isr(int irq, voi
 		return IRQ_NONE;
 
 	atomic_inc(&sp->isr_cnt);
+	if (unlikely(atomic_read(&sp->card_state) == CARD_DOWN)) {
+		atomic_dec(&sp->isr_cnt);
+		return IRQ_NONE;
+	}
+
 	mac_control = &sp->mac_control;
 	config = &sp->config;
 



