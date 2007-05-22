From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH] s2io: don't run MSI handlers if device is offline.
Date: Tue, 22 May 2007 17:50:29 -0500
Message-ID: <20070522225029.GS5921@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-pci@atrey.karlin.mff.cuni.cz, netdev@vger.kernel.org,
	Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>,
	Sivakumar Subramani <sivakumar.subramani@neterion.com>,
	Sreenivasa Honnur <sreenivasa.honnur@neterion.com>,
	Rastapur Santosh <santosh.rastapur@neterion.com>,
	Wen Xiong <wenxiong@us.ibm.com>
To: Jeff Garzik <jgarzik@pobox.com>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:53227 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756373AbXEVWub (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 May 2007 18:50:31 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4MMoVnA027765
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 18:50:31 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4MMoVMa558284
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 18:50:31 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4MMoU52021702
	for <netdev@vger.kernel.org>; Tue, 22 May 2007 18:50:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Don't run any of the MSI handlers if the channel is off;
also don't gather device statatistics. Also, netif_wake 
not needed, per suggestions from
Sivakumar Subramani <sivakumar.subramani@neterion.com>.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>
Cc: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Cc: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Cc: Rastapur Santosh <santosh.rastapur@neterion.com>
Cc: Wen Xiong <wenxiong@us.ibm.com>

----
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index e46e164..871c37c 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -4202,6 +4202,9 @@ static irqreturn_t s2io_msi_handle(int i
 	struct mac_info *mac_control;
 	struct config_param *config;
 
+	if (pci_channel_offline(sp->pdev))
+		return IRQ_NONE;
+
 	atomic_inc(&sp->isr_cnt);
 	mac_control = &sp->mac_control;
 	config = &sp->config;
@@ -4232,6 +4235,9 @@ static irqreturn_t s2io_msix_ring_handle
 	struct ring_info *ring = (struct ring_info *)dev_id;
 	struct s2io_nic *sp = ring->nic;
 
+	if (pci_channel_offline(sp->pdev))
+		return IRQ_NONE;
+
 	atomic_inc(&sp->isr_cnt);
 
 	rx_intr_handler(ring);
@@ -4246,6 +4252,9 @@ static irqreturn_t s2io_msix_fifo_handle
 	struct fifo_info *fifo = (struct fifo_info *)dev_id;
 	struct s2io_nic *sp = fifo->nic;
 
+	if (pci_channel_offline(sp->pdev))
+		return IRQ_NONE;
+
 	atomic_inc(&sp->isr_cnt);
 	tx_intr_handler(fifo);
 	atomic_dec(&sp->isr_cnt);
@@ -4428,6 +4437,9 @@ static void s2io_updt_stats(struct s2io_
 	u64 val64;
 	int cnt = 0;
 
+	if (pci_channel_offline(sp->pdev))
+		return;
+
 	if (atomic_read(&sp->card_state) == CARD_UP) {
 		/* Apprx 30us on a 133 MHz bus */
 		val64 = SET_UPDT_CLICKS(10) |
@@ -8122,5 +8134,4 @@ static void s2io_io_resume(struct pci_de
 	}
 
 	netif_device_attach(netdev);
-	netif_wake_queue(netdev);
 }
