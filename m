From: "Sivakumar Subramani" <Sivakumar.Subramani@neterion.com>
Subject: RE: [PATCH] s2io: don't run MSI handlers if device is offline.
Date: Wed, 23 May 2007 01:03:57 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77019D4ED3@nekter>
References: <20070522225029.GS5921@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-pci@atrey.karlin.mff.cuni.cz>, <netdev@vger.kernel.org>,
	"Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>,
	"Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>,
	"Rastapur Santosh" <santosh.rastapur@neterion.com>,
	"Wen Xiong" <wenxiong@us.ibm.com>,
	"Leonid Grossman" <Leonid.Grossman@neterion.com>,
	"Sriram Rapuru" <Sriram.Rapuru@neterion.com>
To: "Linas Vepstas" <linas@austin.ibm.com>,
	"Jeff Garzik" <jgarzik@pobox.com>, "Andrew Morton" <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:23111 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755522AbXEWFD4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2007 01:03:56 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070522225029.GS5921@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix looks good. No comments.
~Siva 

-----Original Message-----
From: Linas Vepstas [mailto:linas@austin.ibm.com] 
Sent: Wednesday, May 23, 2007 4:20 AM
To: Jeff Garzik; Andrew Morton
Cc: linux-pci@atrey.karlin.mff.cuni.cz; netdev@vger.kernel.org;
Ramkrishna Vepa; Sivakumar Subramani; Sreenivasa Honnur; Rastapur
Santosh; Wen Xiong
Subject: [PATCH] s2io: don't run MSI handlers if device is offline.


Don't run any of the MSI handlers if the channel is off; also don't
gather device statatistics. Also, netif_wake not needed, per suggestions
from Sivakumar Subramani <sivakumar.subramani@neterion.com>.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Cc: Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>
Cc: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Cc: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Cc: Rastapur Santosh <santosh.rastapur@neterion.com>
Cc: Wen Xiong <wenxiong@us.ibm.com>

----
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c index
e46e164..871c37c 100644
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
